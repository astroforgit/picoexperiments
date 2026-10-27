# Pilka — Arlasoft Soccer / Atari XL/XE + VBXE

Work-in-progress native 6502 conversion of the supplied `arlasoc.d64`, using
player and ball graphics extracted from the supplied Amiga SWOS 25/26 archive.
Pitch geometry and match rules come from the C64 game. Grass pixels come from
SWOS. Pitch advertising is replaced by pixel-art flowers and Atari Fuji symbols.
**Music and sound playback are disabled.**

## Build and launch

```sh
./build.sh
./run.sh
```

`build.sh` produces `pilka.xex`. It requires MADS, Python 3, py65, Pillow and
NumPy. `run.sh` uses the existing workspace Atari VBXE toolkit / Altirra profile.
Target: PAL Atari XL/XE, 64 KB RAM, VBXE FX 1.2x with 512 KB VRAM. The loader
probes `$D600` and `$D700`. NTSC match timing has not been validated.

Joystick 1 maps to C64 joystick port 2. Joystick 2 maps to C64 port 1.
Use joystick directions in the original options menu; fire starts a match.
The original menu offers controller assignment, formation, shirts and strength.

## Implementation

The C64 6502 program is retained at its own addresses, rather than rewritten
as a different football simulation. `analysis/arlasoc-disassembly.txt` contains
reachable assembly reconstructed from execution coverage and branch traversal;
it is not a high-level C decompilation. `gen/patches.json` records hardware
operand changes. The bridge supplies input, frame interrupts and VBXE
drawing. Its resident code is in the C64's VIC-only charset RAM
(`$F000-$F7FF`, expanded to VRAM first) and unused sprite-pattern RAM
(`$CC40-$CFFF`). Small tables are at `$DD10`. Boot-only code runs from
`$F800` and is then replaced by the game's own `$F800-$FFFF` code, staged in
VRAM at `$5F000`. The hidden-I/O menu table is relocated to `$C900`.

The renderer uses double buffers, cached character cells, transparent SWOS
player/ball blits and a separate advertising strip. Compose and sprite blits
run as one chained BCB list while the CPU continues; the VBI shows a picture
only when the blitter has finished. When the game loop is late, drawing is
skipped so the C64 logic keeps its 50 Hz rate. Each picture compares a
quarter of the screen (colour RAM: five rows). The C64 game scrolls by
copying its screen shifted by one character and flipping `$D018`. The NMI
records that copy's direction (`$11DB`, index into the game's offset table
at `$1471`). The renderer then moves the char layer and caches by one cell
with precomputed BCB lists and compares all cells.
C64 player frames 32-63 (32 + 4 x direction + phase, directions clockwise
from up) map to the SWOS running frames for the same direction. SWOS
sprites are anchored so that figures and the ball line up with the C64
sprite pixels, putting the ball at the player's feet. Frames above 63
(tackles, falls, goalkeeper poses) are not drawn yet. Kit and goalkeeper
presentation still need refinement.

## Reproducing analysis and asset extraction

```sh
python3 tools/extract_c64.py
7z x -aos -oamiga SensibleWorldOfSoccer2526_v2.3.lha
python3 tools/extract_swos.py
python3 tools/preview_swos.py
python3 tools/coverage.py
./build.sh
python3 tools/test_port.py
python3 tools/test_renderer.py
python3 tools/check_layer.py     # char layer/cache consistency during play
python3 tools/speed.py           # game-loop rate and render cost
```

The RNC1/RNC2 extractors validate compressed and decoded CRCs. All 34 graphics
files have passed those checks. Four player sheets are exported as indexed
pixels; pitch map 1 is also decoded to a full-pitch preview.

The headless models in `tools/reference` are adapted from the sibling `gg`
conversion. `nmos.py` adds the LAX instructions used by this game to py65.
The model does not replace testing in Altirra or on real hardware. Complete
matches, every menu mode, goal/restart handling and real-hardware timing are
not yet validated. Test-only `check_logic.py` temporarily bypasses rendering;
its results are not display-performance measurements.

## Sources

- C64 game: the user-supplied `arlasoc.d64` (Arlasoft Soccer).
- Amiga graphics: the user-supplied `SensibleWorldOfSoccer2526_v2.3.lha`.
- SWOS layouts and palette: `SWOS-RE-main/SWOS-RE-main`.
- VBXE bridge/loader and headless model references: sibling `../gg` project.
- RNC decoder adaptations: ScummVM, GPL-3.0-or-later; see decoder file headers.
- Flowers and Atari-symbol banner pixel patterns: `tools/make_banners.py`.

No source archives or sibling projects are modified by the build.

## Latest smoke run

The current build passed 900 PAL frames at `$D600` and 200 at `$D700`.
Checks cover startup, exact banner upload, execution without unexpected BRK or
unsupported opcodes, VBXE drawing, and silent POKEY output. These are headless
smoke tests, not full-match or real-machine validation.

## Renderer correction

The renderer now waits for blitter completion before modifying its shared BCB,
uses table-based tile addresses, avoids computing destinations for unchanged cells,
and blits only the visible 16x16 player area. The unused C64 sound update is skipped.
The 400-frame headless profile averaged 114,288 CPU cycles per render versus
142,907 before these changes (about 20% less); this is not a real-machine FPS claim.
The emulator checks reject shared BCB writes during a blit and OS ROM re-enabling
while executing the runtime underneath it. Fine scrolling and frame pacing remain
unfinished, so the game is still an early conversion.
