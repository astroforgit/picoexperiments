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

## Editor

`editor/index.html` is a web editor for the game data. Open it in a browser; it works offline
from the file system. It edits a game description (`game.json`):

- **Rules:** every generator and game parameter (room counts and sizes, room types per floor,
  trap, pot, door, curse, bless and enchant chances, level-up gains, the boss floor...), the
  monster budget, mimics and treasure rooms per floor, and the experience table.
- **Monsters:** all entity types, with animated previews and editable stats, sprites and
  abilities. Below them are the monsters of other games (Porklike, BulbaRogue, Crocolike,
  The Demon Within, or any `.p8` loaded with "Load a .p8 cart"), with their stats and
  animations. "Add to game" copies a monster's 4 frames to the second sprite page and adds it
  as a new monster; its special mechanics become abilities.
- **Items:** names, sprites, attack, healing, the floor they appear from, and where they are
  found. Items can be added.
- **Floors & maps:** hand-made 128×32 maps (paint ground, walls, the start, stairs, props and
  monsters) and which floors use them instead of the generator. Maps of other games can be
  selected on their own map and converted, tile by tile (walls by sprite flag, single tiles
  overridable: stairs, start, spikes, doors...).
- **Sprites, Furniture, Texts:** both sprite pages with a pixel editor and the sprite flags, the
  3×3 furniture pieces of the rooms, and every text of the game (checked against the font).
- **Export:** checks the data and downloads `game.json`.

Put the exported file into `data/game.json` and run `./build.sh`. Without changes it builds the
original game: `tools/regress.py` compares the generated floors 1-8 (map, fog and every entity)
with another build, and they are identical.

### Monster abilities

| Ability | Effect | From |
| --- | --- | --- |
| poison, paralyze, bolt, blink, boss | as in the cartridge (toxic rat, ghost, eyeball, imp, Raq'zul) | Lich King |
| flee | runs away from the hero | Lich King (box), Crocolike (scared) |
| treasure | drops blessed food when killed | Lich King (box) |
| stun | the first hit stuns the hero instead of hurting | Crocolike, BulbaRogue |
| curse | the first hit makes the hero forget the explored map | Crocolike |
| vampire | heals itself by its attack (30%) | Crocolike (vamp) |
| steal_item | the first hit steals a backpack item | Crocolike (stealitm) |
| steal_weapon | the first hit steals the weapon in hand | Crocolike (stealeqp) |
| slow | moves every other turn | Crocolike, BulbaRogue |
| still | never moves, hits what is next to it | Porklike (weed) |
| pounce | leaps along a free row or column to the hero | Porklike (kong) |
| summon | summons a monster every 3rd turn and keeps away | Porklike (queen) |
| hunter | always knows where the hero is | Porklike (reaper) |
| blind | the hero sees only 1 tile for 5 turns | Porklike |
| invisible | only seen when next to the hero | Porklike |

Their numbers (turns, chances, the summoned monster) are parameters in the Rules tab.
`tools/test_abilities.py ability...` builds a test room per ability and reports what happens.

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

`tools/lichdata.py` builds the game description from the cartridge (the default
`data/game.json`, written when missing). `tools/make_data.py` turns `data/game.json` into:

- `data/gfx.bin` and `data/gfx2.bin`: the two sprite pages (4 bpp).
- `data/floors.bin`: the hand-made floors, run-length encoded (at most 8K).
- `data/stage.bin`: the font masks and the three XDLs.
- `data/sfx.bin`: the sound effects.
- `gen/params.asm`: the rules, as `P_...` constants.
- `gen/tables.asm`: the monster, ability and item tables, loot lists, per-floor tables, the
  map pieces, sprite flags, palettes, the fade table and the glyph widths.
- `gen/strings.asm`: every text of the game, encoded as glyph numbers of the cart's own
  proportional font.

`tools/make_editor_assets.py` writes `editor/assets.js` (the default game and the bundled
library carts).

## How it works

- **Memory.** Once loaded, the program switches the OS ROM off and runs its own NMI
  handler. The tile map, fog, the per-tile entity lists and the sound effects live in the
  RAM under the ROM.
- **Data-driven rules.** The generator, items and monster behaviour read the constants and
  tables generated from `data/game.json`. Monsters can use a second sprite page (VRAM
  `$38000`: raw, dark and flash copies) and hand-made floors are unpacked from VRAM `$3E000`
  into the map instead of generating it.
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
`data/sfx.bin`; they are copied into the RAM under the OS ROM ($C900, $FD00) while the
program loads. `music()` does nothing, and `SOUND = 0` in `lich.asm` silences
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
