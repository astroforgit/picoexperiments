# The Lair for Atari VBXE

This is an Atari XL/XE + VBXE port of *The Lair* by Jakub Wasilewski (@krajzeg), with
sound by Gruber (@gruber_music). The source is the PICO-8 cartridge `[BeatEmUp]/lair.p8.png`.

The whole game is ported: the title and difficulty menu, the three stages (Old Petrel
Road, Shearwater Keep, The Lair) with their waves and mini-bosses, all monsters, the
boss with its crystals, shield, summons and death sequence, pickups, combos, charged
stabs, shield parries and dashes, the stage results with score and rank, the best rank
per difficulty, and the game-over screen. POKEY plays the sound effects. The music is
switched off (see *Sound*).

It needs an Atari XL/XE (64K) with a VBXE FX core at `$D600` or `$D700`.

## Build and run

```sh
./build.sh                    # MADS -> lair.xex
./build.sh --regenerate-data  # also re-decode the cartridge and rebuild data/ and gen/
./run.sh                      # build, then start in the persistent Altirra VBXE profile
```

Regenerating the data needs Python 3 with `lupa`, `numpy` and `Pillow`.

## Controls

The buttons work as in the Celeste port: fire is PICO-8's O, the second fire is X.

| PICO-8 button | Action | Joystick | Keyboard |
| --- | --- | --- | --- |
| arrows | move; double tap: dash | joystick 0 | W A S D or the arrow keys (`-` `=` `+` `*`) |
| [z] (O) | stab, hold: charge; start, menu | fire | Z, C, N, O |
| [x] (X) | hold: shield | button 2 or 3 of a 2-button joystick (Joy2B+ style, pins 5/9), or joystick 1 fire | SHIFT, X, V, M, SPACE, RETURN |

Buttons 2 and 3 arrive on the paddle lines (POT 0 / POT 1), whose resting level depends on
the joystick (Altirra's two-button joystick reads high when pressed, Joy2B+ sticks read
low), so a press is any change from the level the line had half a second after the game
started. Don't hold these buttons while the game loads. Each input counts only after it
has been seen released once (Altirra holds OPTION while booting).

SHIFT can be held together with any other key, so the keyboard alone is playable. The
Atari keyboard reports one other key at a time.

## PICO-8 conversion

`tools/convert_cart.py` decodes the cartridge with the repository's `scrip/pico_convert.py`
and writes:

- `pico/cart.bin`: the raw 32K cartridge memory.
- `pico/lair.p8`: the text cartridge. It is identical to `allgames/[BeatEmUp]/lair.p8`.
- `pico/lair.lua`: the game code.
- `pico/lair_gfx.png` and `pico/lair_gfx_x4.png`: the sprite sheet (also
  `allgames_resources/[BeatEmUp]/lair.png`).
- `pico/lair_map.png`: the cartridge map.

`tools/make_data.py` runs the cart in the Lua shim of `tools/pico_ref.py` and reads the
tables the game builds from the live Lua state, so they are exactly the cart's values:

- `gen/tables.asm`: the classes with their inheritance resolved, the state handler of
  every class and state (named after the cart's Lua functions), the sprite layouts,
  hitboxes, animation layouts, difficulties, stages, map layers, waves, mini-boss and
  boss summon lists, texts, the floor scroll offsets and the sprite flags.
- `gen/hi.asm`: tables that live under the OS ROM: the sound effects and music, the
  palette banks, sine, vector normalisation and square root tables.
- `gen/params.asm`: class, state, bank and other constants.
- `data/gfx.bin` and `data/vr_*.bin`: the sprite sheet and the VRAM images (font masks,
  outlined font, XDLs, the moons, the sea reflection rows, shadows, puddles, the floor
  strips of each stage and the map), staged into VBXE memory while the XEX loads
  (`gen/load.asm`).

## How it works

- **Memory.** Once loaded, the program switches the OS ROM off and runs its own NMI
  handler. Globals, the text cache keys and the floor offsets live in the RAM under the
  ROM at `$C000`; tables, sound effects and the music player at `$A000-$BFFF` and
  `$DC00-$FFF9`. Entities (40), particle systems (24) and particles (160) are struct-of-
  array tables at `$0400-$1FFF`.
- **Game logic.** `src/states.asm` (the hero, damage, pickups), `src/monsters.asm`,
  `src/boss.asm` and `src/level.asm` translate the Lua closely, at the cart's 60
  updates per second (`_update60`): the vertical blank counts 60 ticks per second on PAL
  and NTSC, and the main loop runs up to four updates per drawn frame. State times are
  kept in frames (the cart's `t` is in half frames). Positions are 24 bit fixed point
  (8 fraction bits), speeds 8.8. The cart's class tables become per-class constant
  arrays, and each class/state pair dispatches to the handler named after the Lua
  function. Quirks of the cart are kept: monsters that are not in front of the hero
  aim straight below him (`local d,a=ij(m,eg)rnd()` leaves the angle nil).
- **Display.** The VBXE low resolution overlay at narrow width shows the 128x128
  PICO-8 screen; even rows are shown on two TV lines and odd rows on one. Three
  framebuffers let the CPU build the next frame while the previous one waits for the
  vertical blank.
- **Palettes.** Sprite pixels are stored as `$F0 | colour` (colour 0 as 3, since 3 is
  the transparent colour), and the blitter's AND mask picks one of 16 palette banks of
  16 entries per blit: hit flashes, fades, the torch flicker of stages 2 and 3. The
  captain's and the fire spitter's recolouring use two more copies of the sheet. The
  screen palette effects of the boss rewrite the VBXE palette in the vertical blank.
- **Drawing.** Drawables are sorted by layer (y) every frame, as the cart's `qm()` does.
  Each primitive becomes a blitter command; commands are written into two alternating
  lists in VBXE memory, and a slot rewrites only the fields that differ from what it
  held before. The floor rows, the sea reflection and the health boxes are drawn into
  VRAM caches only when they change and copied with one blit per frame. Text is
  rendered once per distinct string into a VRAM cache (glyph and outline masks), so the
  cart's outlined text costs two blits. Shadows, moons and puddles are pre-drawn images.
- **Disintegration.** A dying monster is drawn by the blitter into a scratch buffer,
  read back through MEMAC and turned into particles, as the cart does with `pget()`.
- **Speed.** Normal fights run at full speed. Crowded boss fights with many
  disintegrating monsters slow down to about 70-80%.

### Differences from the cartridge

- **Music** is not played.
- **Random numbers** come from a 16-bit xorshift mixed with POKEY's `RANDOM`, with 8-bit
  fractions; the odds are the cart's, the sequences are not.
- **Small rounding.** Speeds use 8 fraction bits, particle friction is applied every
  second update with the squared factor, and the floor rows use precomputed half-pixel
  scroll offsets. The difference is not visible.
- **Game over.** The screen melts with fewer pixels per frame than the cart's 751.
- **Saving.** The best ranks are kept until the machine is switched off.

## Sound

`src/sound.asm` is the POKEY player of the Celeste and Lich King ports, with requests
queued for the vertical blank and the cart's `kl()` priority rule for channels 2 and 3.
The fight jingles change the loop points of sfx 33 and 34, as the cart does with
`poke`. The music player is still in the file; `PLAY_MUSIC = 1` in `lair.asm` switches it
on. `SOUND = 0` silences everything.

## Testing tools

- `tools/pico_ref.py`: runs the original Lua with a PICO-8 shim (lupa) that draws, so the
  original can be looked at: `python3 tools/pico_ref.py "120,s:title,z,60,s:menu"`
  writes `shots/ref_*.png`.
- `tools/emu.py`: a headless py65 Atari with enough VBXE emulation for testing (MEMAC,
  the blitter, the palette, XDL screenshots), adapted from the Lich King port.
- `tools/shot.py "script"`: plays an input script and saves screenshots to `shots/`.
- `tools/play.py FRAMES [EVERY] [god] [stageN]`: a bot that walks, stabs and shields;
  it reports the game speed (updates per TV frame) and detects hangs.
- `tools/prof.py`: a CPU profile of the bot's play.
- `tools/longbranch.py`: assembles and turns out-of-range branches into long branches.

The game has been played through all three stages, the boss fight, its death sequence,
the results and the return to the title in `tools/emu.py`. It has not yet been run on
real hardware or in Altirra.
