# Curse of the Lich King for Atari VBXE

This is an Atari XL/XE + VBXE port of *Curse of the Lich King* (v1.2) by Johan Peitz, with
audio by Gruber. The source is the PICO-8 cartridge `[RPG]/Curse of the Lich King.p8.png`.

The whole game is ported: the title screen, the procedurally generated floors 1 to 8,
monsters and their AI, fog of war, props, items, the backpack, the altar, anvil and well,
the floor 8 boss, death and victory. POKEY plays the sound effects. The music is not
played (see *Sound*).

It needs an Atari XL/XE (64K) with a VBXE FX core at `$D600` or `$D700`.

## Build and run

```sh
./build.sh                    # MADS -> lich.xex
./build.sh --regenerate-data  # also re-decode the cartridge and rebuild data/ and gen/
./run.sh                      # build, then start in the persistent Altirra VBXE profile
```

## Controls

| PICO-8 button | Joystick | Keyboard |
| --- | --- | --- |
| Move, menu cursor | joystick 0 | arrow keys (`-` `=` `+` `*`) or W A S D |
| X: backpack, select, start | fire | X, V, M, SPACE, RETURN |
| O: close | — | C, Z, N, ESC |

The game is playable with a one-button joystick:

- Fire also closes a message box that has no cursor.
- In the backpack and its item menu, pushing left closes the menu.

Each button counts only after it has been seen released once. A held button repeats like
PICO-8's `btnp()`: 15 ticks after the press, then every 4 ticks.

## PICO-8 conversion

`tools/convert_cart.py` decodes the cartridge with the repository's `scrip/pico_convert.py`
and writes:

- `pico/cart.bin`: the raw 32K cartridge memory.
- `pico/lich.p8`: the text cartridge. It is identical to `allgames/[RPG]/Curse of the Lich King.p8`.
- `pico/lich.lua`: the game code.
- `pico/lich_gfx.png` and `pico/lich_gfx_x4.png`: the sprite sheet.
- `pico/lich_map.png`: the cartridge map, which holds the title background.

`tools/make_data.py` turns `cart.bin` and the Lua source into:

- `data/gfx.bin`: the sprite sheet (4 bpp).
- `data/stage.bin`: the font masks and the three XDLs.
- `data/sfx.bin`: the sound effects.
- `gen/tables.asm`: the monster and item tables, the map pieces, sprite flags, palettes,
  the fade table and the glyph widths.
- `gen/strings.asm`: every text of the game, encoded as glyph numbers of the cart's own
  proportional font.

## How it works

- **Memory.** Once loaded, the program switches the OS ROM off and runs its own NMI
  handler. The tile map, fog and the per-tile entity lists live in the RAM under the ROM.
- **Display.** VBXE low-resolution overlay at narrow width shows the 128×128 PICO-8
  screen. Even rows are shown on two lines and odd rows on one, so the screen looks
  square. Three framebuffers (`$00000`, `$04000` and `$30000`) let the CPU draw the next
  frame while the previous one waits for the vertical blank.
- **Palettes.** The sprite sheet is expanded at load time into four 8-bit copies, one per
  palette the game uses: raw, lit (`pal(14,1)`), dark (fog) and the white hit flash.
  Mirrored sprites use a negative blitter source step. The screen fade rewrites the VBXE
  palette.
- **Map and fog.** The level is baked into a 1024×256 VRAM image, `$40000`–`$7FFFF`. A tile
  is re-drawn there only when its fog state changes. Each frame copies the visible
  17×17-tile window with one blit.
- **Text.** Each distinct (string, colours) pair is rendered glyph by glyph once, into one
  of 32 VRAM slots of 256×8 pixels. After that, every `pr()` of it is a single clipped
  blit. Lookups by string pointer skip hashing for texts that do not change every frame.
- **Blitter lists.** Two command lists (`$0E000` and `$0F000`) alternate, so the next
  list is built while the blitter runs the previous one. All drawing is clipped in
  software to the PICO-8 `clip()` rectangle.
- **HUD.** The HUD box is drawn off screen, in framebuffer 3 at `$34000`, whenever a value
  changes. Every frame it is copied with a single blit.
- **Game logic.** `src/level.asm`, `src/entity.asm`, `src/items.asm`, `src/windows.asm` and
  `src/game.asm` translate the Lua closely. The game runs at the original 30 ticks per
  second: PAL paces 3 ticks per 5 frames, NTSC 1 tick every 2 frames. Distances are
  compared as squares, so no square roots are needed.
- **Speed.** Every screen holds 30 ticks per second, except while walking on floor 8 with
  about 190 entities, which runs at about 85% of that. Generating a floor takes about 0.7 s
  on floor 1 and 2 s on floor 8, behind the fade to black.

### Differences from the cartridge

- **Music.** The music is not played.
- **Item menu cursor.** The item menu (use/equip/discard) gets a cursor. The cartridge
  never sets one, so its items could not be selected.
- **Hero on the first turn.** The hero is entered in the occupancy lists when a floor
  starts. The cart only adds it after its first move.
- **Random numbers.** They come from a 16-bit xorshift mixed with POKEY's `RANDOM`, and
  `flr(rnd(n))` uses an 8-bit fraction. Game outcomes therefore differ from PICO-8's
  random sequence, but not in their odds.
- **Text widths.** These use the real glyph widths from the start. The cartridge uses
  width 4 for a glyph until it has drawn that glyph once.

## Sound

`src/sound.asm` is the POKEY player from the Celeste port. It plays the cart's sound
effects on channels 3 and 2, with PICO-8's timing and its pitch, volume, noise, slide,
fade and arpeggio effects. Only the sound effects (6 and 32 to 63) are kept in
`data/sfx.bin`. `music()` does nothing, and `SOUND = 0` in `lich.asm` silences
everything.

A second joystick button on POT 0 can be enabled with `USE_POT = 1`. It is off because
Altirra's paddle readings are not stable enough to use without a paddle attached.

## Testing tools

These run the game headless in `tools/emu.py`, a py65 Atari with enough VBXE emulation:
MEMAC, the blitter with a timing model, the palette and XDL screenshots. It is adapted
from the Celeste port.

- `tools/shot.py "script"`: plays an input script and saves screenshots to `shots/`. The
  steps are frames, `f` (fire), `c` (close), `u`/`d`/`l`/`r` (moves) and `s:name`
  (screenshot).
- `tools/deep.py N "script"`: the same, after regenerating the level at floor N.
- `tools/bot.py turns seed [depth [strong]]`: a bot that plays the game. It finds paths
  to monsters, props and stairs, equips weapons and eats. It has played several floors,
  died (the death box and return to the title), and killed Raq'zul on floor 8 (the
  victory sequence).
- `tools/fuzz.py`: random input, and reports where the CPU stalls.
- `tools/rate.py` and `tools/prof.py`: game ticks per 300 frames, and a CPU profile.
- `tools/pico_ref.py`: runs the original Lua generator through a PICO-8 shim (lupa). It
  measured the entity counts (up to about 200 on floor 8) used to size the tables.

The game has also been run in Altirra 4.40 (NTSC, VBXE at `$D600`). It shows the title,
starts the game and plays there.
