# Ghosts'n Goblins Arcade for Atari XL/XE + VBXE

This is a conversion of the C64 game *Ghosts'n Goblins Arcade* (Nostalgia,
2015; disk image `GhostNGoblinsArcade_N0S_FL_Universal.d64`). The Atari runs
the **original C64 program**: every level, enemy, weapon, the bosses, the
options and trainer menu, the title and attract mode, the map between levels
and the high score table come from the game's own 6502 code. The Atari side
emulates the C64 hardware the game uses. The VIC-II picture is redrawn by the
VBXE blitter, the SID by POKEY, and the CIA joystick and keyboard ports by the
Atari's.

It needs an Atari XL/XE with 64 KB and a VBXE with an FX 1.2x core at `$D600`
or `$D700`. PAL and NTSC machines both run the game at the C64's 50 game
frames per second (NTSC skips one tick in six).

## Controls

| C64 | Atari |
|---|---|
| joystick in port 2 | joystick 1 |
| RETURN | RETURN or START |
| RUN/STOP (pause) | ESC |
| Q (quit the game while paused) | Q |
| SPACE (title screen: sound effects on/off) | SPACE |
| left arrow (trainer: skip the level) | TAB |
| 1-5 (trainer: choose the weapon) | 1-5 |
| other letters, digits, F1 / F3 | the same keys, `<` / `>` |

The options menu is the game's own: move with the joystick, fire changes an
option or starts the game. "PLAY ORIGINAL INSTEAD" has no effect in this
release of the game (on the C64 too; file `0B` is never loaded).

## Build and run

```sh
./build.sh     # -> gng.xex
./run.sh       # build, then start the persistent Altirra VBXE profile
```

The build needs MADS 2.x and Python 3 with `py65`, `numpy` and `Pillow`.
`tools/d64.py` extracts the disk files into `disk/`. The analysis results
the build uses are kept in `gen/`:

- `gen/loads.json` lists what each disk file writes when it is loaded
  (`tools/extract.py`);
- `gen/entry.snap` is the C64 state at the program's entry point, after the
  intro has loaded the main program and the menu (`tools/gng.py`);
- `gen/cov-*.json` are coverage runs of the C64 model (`tools/coverage.py`
  per scenario), from which `tools/codemap.py` makes `gen/codemap.json`, the
  code map with every reference to the C64 chips and the KERNAL.

These take a few minutes each to remake and only change if the analysis
tools change.

## How it works

**Running the C64 program.** The Atari starts from the RAM image of the C64
at `JMP $0800` (the intro's loading picture and its music are skipped: they
only cover the disk loading). The C64 code stays at its addresses. The
runtime lives in memory the game never touches after its boot: `$C300-$CFFF`
(the C64 keeps sprite graphics there, which only the VIC reads), variables in
`$DC10-$DFFF`, and four 4 KB code banks in VRAM, switched into
`$E000-$EFFF` by MEMAC-A.

**Patches.** `tools/patch.py` changes each instruction that touches the C64
chips (about 300 in the main program, 13 in each level and title file):

- VIC-II and SID registers go to shadows at `$DE00` and `$DF00` with the
  same low address byte, so the instruction itself only gets a new operand;
- reads of the raster line, the joystick and keyboard ports, stores to colour
  RAM and to a SID control register go through small stubs;
- busy waits for a raster line become calls to `wait_line`, which waits for
  that line of a virtual raster (line 0 when the vertical blank work ends,
  line 311 at the next vertical blank) and draws the screen meanwhile;
- KERNAL calls of the options menu (CHROUT, PLOT, GETIN) go to replacements.

**Loading.** The disk files are stored in VRAM. The game's own loader is
replaced: its decruncher runs unchanged, its byte fetch reads VRAM, and its
stores into the VIC bank (`$C000-$FFFF`, partly under the C64's I/O area)
go to a VRAM image of that bank. Each loaded file then gets its patches.
High scores saved by the game are kept in VRAM for the session.

**Raster interrupts.** At each vertical blank the NMI runs the game's raster
interrupt handlers in raster order, as the C64 would have run them during
the frame, and records the VIC registers and sprite pointers after each one
(a log in VRAM). The sprite multiplexer and the HUD split are reproduced
from that log.

**Picture.** The C64 screen is kept as a 320×200 character layer in VRAM.
Each character row is a ring buffer, so a coarse scroll only changes the
row's offset and draws the column that came in. While the game waits for its
next frame, the runtime compares screen RAM with a shadow copy and queues
tile blits for the cells that changed. It also turns the newest interrupt log
into raster regions and sprite instances and builds the blitter list for the
next picture: the character layer is copied into the framebuffer per region
with its fine scroll, border and blank areas are filled, then the sprites are
drawn. Pixels are palette indices that encode which colour register they use,
so colour changes only rewrite the palette. Each region gets one of three
overlay palettes, selected per line range by the XDL.

**Sound.** The game's sound effects are on SID voice 3. It plays on POKEY
channels 1+2 joined (16-bit pitch), with the SID envelope modelled per frame.
The music voices (1 and 2) are not converted yet.

## Verification

```sh
python3 tools/atari_snap.py save 300 gen/snap/menu300.pkl
bash tools/make_snaps.sh                     # attract mode and level 1 snapshots
python3 tools/verify_render.py gen/snap/game1900.pkl 100 --every 4
python3 tools/level_test.py /tmp/levels 1 2 3 4 5 6
python3 tools/bench.py                       # pictures and game ticks per frame
```

- `tools/c64.py`, `tools/gng.py` and `tools/vic.py` are a headless C64 model
  (py65 CPU, VIC-II and CIA registers, raster IRQs, the loader replaced by
  traps that read the disk files) and a VIC-II renderer.
- `tools/atari_emu.py` is a headless Atari + VBXE model (from the Double
  Dragon port). `tools/verify_render.py` renders every composed picture's
  interrupt log with `tools/vic.py` over the same C64 memory and compares it
  with the VBXE framebuffer pixel by pixel. In the six levels the pictures
  match exactly or differ in a few HUD digits (one picture of delay).
- `tools/level_test.py` starts each level through the trainer options,
  `tools/skip_test.py` skips through levels, `tools/gameover_test.py` plays
  without trainers until the game is over.
- `tools/nmi_phase.py`, `tools/compose_prof.py` and `tools/main_prof.py`
  profile the vertical blank, the composition of a picture and the time
  between frames.

Checked in Altirra 4.40 (NTSC + VBXE): the menu, the title and attract mode,
starting a game, walking, scrolling and the enemies of level 1.

## Known limitations

- The picture is redrawn about every second frame in level 1 (25 per second
  on PAL), less in busy scenes; the game itself always runs at full speed.
- The music is silent (only sound effects play). SPACE on the title screen
  turns the sound effects off, as on the C64.
- Disk accesses are fast but the decruncher takes a few seconds at the start
  of a level.
