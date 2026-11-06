# Contra — Atari XL/XE + VBXE

A native 6502 conversion of the supplied **Contra (USA) NES version**. The original
program supplies the gameplay, stages, enemies, weapons, bosses, menus and ending.
The Atari runtime replaces the NES video, mapper, controller and audio hardware.
The supplied `pc_cntra.zip` is the NES-based PlayChoice-10 release, not the distinct
Konami arcade-board game; this build uses `Contra/Contra (USA).nes`.

Requires 64 KB Atari XL/XE and 512 KB VBXE with an FX 1.2x core at `$D600` or `$D700`.
The output is **`contra.xex`**. PAL and NTSC scheduling are supported. The game logic runs at
the original 60 ticks per second; pictures are paced (see *Frame pacing*).
A newly loaded stage waits for its background to be ready before play starts.

Music is disabled by default to free CPU time for rendering. Shooting, explosions,
death and pause sound effects remain enabled. The renderer now samples sprites
and scroll after background-tile work, retries if a game update interrupts the
snapshot, and uses a faster OAM copy and tile-expansion path. Completed frames
can now be presented during a vertical blank that interrupts a long game update,
without waiting for that update to finish. DLI interrupts and busy blits cannot
trigger this presentation path.

A 180-video-frame scripted scrolling test increased from 29 to 52 presented
pictures after these changes; the longest presentation gap fell from 15 to 12
video frames. These are headless-model measurements. Heavy scenes still have
uneven frame delivery; this is not a claim of a locked 50/60 FPS port.

## Frame pacing

Pictures used to be sampled whenever the compositor was free and shown at the
next vertical blank, so each one covered anything from 1 to 10 game ticks and
stayed on screen for 1 to 8 video frames: steady scrolling and movement looked
like jumps. Now a picture is sampled every `pace` game ticks and shown `pace`
ticks after its sample (`flip_due` / `sample_due` in `src/render.asm`;
`PACE_NTSC = 2`, `PACE_PAL = 3` in `src/defs.asm`):

* NTSC: 30 pictures per second, each exactly 2 ticks.
* PAL: 60 ticks in 50 frames give 20 pictures per second, each exactly 3
  ticks, shown alternately for 2 and 3 video frames.

When a picture is not finished in time it is shown at the next vertical blank
and the next sample follows it. Without game ticks (loads, NMI off) a picture
is still taken every 6 video frames. While a finished picture waits for its
vertical blank, the compositor already draws changed tiles into the nametable
bitmaps. The tile and background blits start right after the snapshot, while
the CPU writes the sprite slots; the sprites follow as a second list.

600 video frames of scripted stage-1 play (move right, shoot, jump), headless
model:

| | Pictures | Pictures covering exactly `pace` ticks | Ticks per picture |
| --- | ---: | ---: | --- |
| PAL, before | 268 | – | 1 to 10 |
| PAL, now | 218 | 178 (82%) | 3; 4-5 in tile-heavy scrolling |
| NTSC, now | 266 | 229 (86%) | 2; 3-4 in tile-heavy scrolling |

The remaining late pictures come from scrolling, when a new column of tiles
must be expanded and drawn.

## Build and run

```sh
./build.sh
./run.sh
```

The build needs Python 3, MADS 2.x and the cc65 assembler/linker (`ca65`, `ld65`).
`MADS`, `CA65` and `LD65` environment variables can specify their executable paths.
In this working directory, the build also recognizes the locally unpacked cc65
binaries under `work/cc65/usr/bin`. An exported source package requires cc65 on PATH.

Keep your supplied ROM at `Contra/Contra (USA).nes`. Its SHA-256 must be:

```
26541a5550ee22deeb3d5484e4a96130219b58cff74d068fb1eb6567fa5e5519
```

`run.sh` uses the existing `../../atari-vbxe-toolkit` Altirra launcher and persistent
VBXE profile. Alternatively load `contra.xex` directly in your configured emulator.

## Controls

| Action | Input |
| --- | --- |
| Move / aim | Joystick 1, or W A S D |
| Shoot (NES B) | Fire, O / Z / C / N |
| Jump (NES A) | Second/third joystick button, SHIFT, P / X / V / SPACE |
| Start / pause | Console START or RETURN |
| Select player count | Console SELECT on the original title menu |
| Alternate jump in one-player mode | Joystick 2 fire |
| Player 2 | Joystick 2; fire shoots, second/third button jumps |

So a one-button joystick plays with the keyboard (fire shoots, SPACE or SHIFT
jumps), a two-button joystick (Joy2B+ style, pins 5/9) plays alone, and two
joysticks work like Celeste's: joystick 1 moves and shoots, joystick 2's fire
jumps. In one-player mode joystick 2's fire counts only while joystick 1's
fire is up, so an emulator setup that maps one key to both joysticks (as
Altirra's "Arrow Keys -> Joystick (port 1)" and "(port 2)" maps together do)
shoots without jumping on every press.

Release joystick buttons while loading so the extra-button inputs can calibrate.
Use a two-button stick for simultaneous movement, aiming and jumping. The Atari
keyboard only reports one ordinary key at a time; SHIFT is independent.
The original Konami-code input handling is retained.

The title screen shows "ATARI VBXE VERSION : ASTROFOR" under "2 PLAYERS" in
place of the four copyright lines. `tools/build.py` (`title_credit`) rewrites
the title nametable in the extracted `graphic_data_02` and draws a colon into
the copyright sign's tile in `graphic_data_01`; the font has no colon.

## Implementation

* The annotated upstream disassembly reproduces all 131,072 PRG bytes of the
  supplied ROM exactly before platform changes.
* ca65/ld65 link the fixed NES bank at `$4000–$7FFF`, avoiding Atari I/O. All
  symbolic references and pointer tables relocate together. Seven switchable
  16 KB banks reside in VBXE RAM and map through MEMAC-A at `$8000–$BFFF`.
* PPU writes maintain two nametables, palette RAM and the full 8 KB writable
  pattern memory. The VBXE blitter renders background tiles, scrolling and
  8×16 sprites with transparency, flipping and screen-edge clipping.
* Changed CHR patterns invalidate the relevant tile caches. A per-row pattern index limits scans to background rows that can contain
  changed patterns. Only affected cells are marked for redraw. Sprite descriptors use an OAM
  snapshot so the game cannot change their coordinates halfway through a blit list.
* The compositor runs in the original game's idle loop. Interrupts restore the
  game bank and scratch zero-page bytes, run the NES handler, then resume rendering.
  PAL display-list interrupts provide six nominal game ticks per five video frames;
  NTSC uses vertical blank. Long loads do not accumulate an unlimited tick backlog.
* The original sound driver writes an APU shadow. Pulse, triangle and noise music
  and effects are approximated on four POKEY channels. Music requests are filtered before starting the sound driver.

## Optimization update

The preceding optimization build coalesced CHR invalidations, packs eight background-cell flags
per dirty-map byte, and replaces per-frame audio multiplication with pitch tables.
The tables cover all 8,192 PAL/NTSC pulse/triangle timer combinations and correct
the exact-256 divider case. They occupy `$DB00–$FAFF` in main RAM.

That build’s matched headless checkpoints over 100 PAL video frames measured:

| Checkpoint | Previous pictures | Current pictures | Previous game ticks | Current game ticks |
| --- | ---: | ---: | ---: | ---: |
| Stage 1 | 16 | 23 | 119 | 119 |
| Stage 2 | 9 | 12 | 105 | 110 |

The pitch routine dropped from an average of 490 to 50 modeled CPU cycles across
242 sampled timers. These are model measurements, not real-hardware frame rates.
The checkpoint benchmark replaces changed code/table bytes at an idle boundary;
the stage regression tests independently boot the final executable.

Main RAM: NES state `$0000–$07FF`; OAM snapshot `$0800–$08FF`; PAL display lists
`$0900`; runtime variables/code `$0A00–$27FF`; nametables `$2800–$2FFF`; tile flags
`$3880–$3A7F`; row pattern index `$3000–$37FF`; change bitmaps
`$3800–$387F`; tables `$3A80–$3FFF`; fixed game bank `$4000–$7FFF`; banked game code
`$8000–$BFFF`; PPU services `$C000–$CFFF`; sound services from `$D800`.

## Verification

```sh
python3 tools/test_runtime.py
python3 tools/test_levels.py
python3 tools/test_levels.py --one --ntsc --d700
```

Install test dependencies with `python3 -m pip install -r requirements-test.txt`.
Tests use `py65`, NumPy and Pillow. `test_runtime.py` checks every background and
8×16 sprite pattern at both VBXE register locations, CHR invalidation and register
preservation, then compares complete nametable and sprite compositions with an
independent NES pixel decoder. `test_levels.py` selects stages through test-only
RAM setup, skips presentation waits at the labeled score-routine entry and checks movement, bullets and displayed
frames. There is no stage-select trainer in the executable. Screenshots, snapshots,
labels, listings and reports are under `gen/`.

The verification report records the final binary hash, stage-entry/control checks,
matched-checkpoint benchmarks and clean exported-source rebuild result. Hardware
service tests also exercise randomized dirty-map packing and every pitch-table
entry. `tools/test_controls.py` checks pause/resume from the stage-1 checkpoint.

These are headless model tests, not a full game playthrough or physical-hardware
certification. Interactive Altirra verification could not be performed in this
session: the desktop automation tool failed to initialize with a workspace URI
error.

## Guide-based regression workflow

Following `../howtotestgame/README.md`, the additional checks are:

```sh
./build.sh
python3 tools/test_player_session.py
python3 tools/test_player_session.py --ntsc --d700 --seed=91
python3 tools/test_ppuctrl_variant.py
python3 tools/test_memory_layout.py
```

`test_player_session.py` starts at reset with seeded random VRAM, waits for the
real title menu, chooses two players using SELECT, and starts with Return through
the keyboard IRQ. It exercises movement, shooting, jumping and pause/resume,
then runs 300 additional frames of scripted play. It never pokes game state.
Every frame checks protected VRAM, including PRG banks, unused gaps and the XDLs;
fixed game code is checked afterward. A deliberate corruption must be caught by
the guard before the test proceeds. Image hashes and XDL presentation logs are
saved with screenshots and reports in `gen/player-session-*`.

`test_ppuctrl_variant.py` builds both versions in temporary directories and
compares 1,024 control-value/flag cases. Removing the unused X-register save and
restore preserves registers, flags and service state and saves exactly eight
modeled cycles per call (47/49 down to 39/41). This is a routine-level saving;
it is not a claim of a particular whole-game frame-rate increase.

`test_memory_layout.py` deliberately creates PRG, CHR and command-list overlaps
in temporary copies and requires assembly to fail. Production assembly checks
all adjacent VRAM allocations. Test variants never replace project source.
The earlier stage tests remain useful for rare-state coverage and are explicitly
separate from the real-menu sessions. The score-wait skip runs at an instruction
boundary: video-boundary sampling could miss every idle gap and falsely time out
a still-progressing load. Resumed runs retain earlier stage records.
Model timing excludes exact blitter/display
contention and analogue POKEY behavior, as described in the testing guide.

The music/scrolling regressions are exercised by `tools/test_no_music.py`:
all 44 music codes are rejected, shooting still creates an effect, scroll/OAM
are sampled after tile work, and a simulated mid-copy game update requires a
complete snapshot retry. Nested-VBI tests also verify that only completed blits
are presented and that the interrupted game’s bank mappings and scratch memory
are preserved. Idle audio channels skip conversion but new timer
strobes still activate their effects. `tools/test_scroll_timing.py` measures
presentation gaps during rightward movement with shooting and jumping from an
explicit snapshot/label pair, including archived versions without patching them.

## Current limitations

* Redraw rate varies with scrolling, sprite activity and CHR animation. Scene
  changes can take several seconds. Background updates can lag game logic.
* POKEY audio is an approximation. NES DMC samples and hardware pulse sweeps are
  not synthesized.
* Sprite/background priority bit 5 is not reproduced: such sprites currently draw
  in front of the background. The NES eight-sprites-per-scanline limit is not applied.
* Complete boss fights, an uninterrupted playthrough and real hardware remain
  outside the automated stage-entry checks.

## Sources

The game disassembly is [vermiceli/nes-contra-us](https://github.com/vermiceli/nes-contra-us),
pinned to the revision recorded in `upstream/REVISION`. Its source comments and
asset extraction manifest are preserved. Extracted assets come from the user's ROM.
The loader, renderer foundations, POKEY converter and headless VBXE model were
adapted from the user's `steamlinejs/dd/atari-full` conversion. Register and blitter
behavior was checked against `steamlinejs/atari/vbxe/docs/vbxe-fx-1.26-pl.pdf`.
