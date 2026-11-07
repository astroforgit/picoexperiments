# Pilka — Arlasoft Soccer / Atari XL/XE + VBXE

Work-in-progress native 6502 conversion of the supplied `arlasoc.d64`.
Players, goalkeepers and the ball use the original C64 sprites. Pitch geometry
and match rules come from the C64 game. Grass pixels come from the supplied
Amiga SWOS 25/26 archive. Pitch advertising is replaced by pixel-art flowers and Atari Fuji symbols.
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

The renderer uses double buffers, cached character cells, transparent C64
sprite blits and a separate advertising strip. Compose and sprite blits
run as one chained BCB list while the CPU continues; the VBI shows a picture
only when the blitter has finished. Rendering runs at the match frame wait
and at the original menu's input-loop boundary, never from an interrupt in
partially updated game code. While rendering, the VBI still samples joysticks
and publishes completed pictures, but defers the C64 IRQ's video-state updates.
This keeps the screen base, fine scroll and ball position stable during composition.
Each picture compares all 1,000 characters and colours and blits only dirty cells;
colour-only menu changes and updates across multiple screen quarters appear together.
The C64 game scrolls by copying its screen shifted by one character and flipping
`$D018`. The NMI records that copy's direction (`$11DB`, index into the game's
offset table at `$1471`). The renderer moves the char layer and caches by one
cell with precomputed BCB lists before comparing all cells. Frame pacing remains
limited by CPU rendering cost; this does not guarantee 50 Hz game logic.

C64 sprite frames 32-127 are converted at build time to 24x21 VRAM images
(one per 512 bytes at `$60000`). The 23 multiplexed sprites come from the
game's tables (`$9F`, `$E4`, `$CD`, `$B6`). The first `$FF` Y entry terminates
the list: subsequent slots contain stale data and must not be drawn. The ball
is VIC sprite 7. Each
is drawn at the C64 position (X-24, Y-50). Sprite-colour pixels are stored
as `$FF`, and the blit's AND mask turns them into palette entry `$60` + the
sprite's C64 colour. Multicolours `$D025`/`$D026` are palette entries `$40`
and `$20`, updated each picture.

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
- Amiga grass pixels: the user-supplied `SensibleWorldOfSoccer2526_v2.3.lha`.
- SWOS layouts and palette: `SWOS-RE-main/SWOS-RE-main`.
- VBXE bridge/loader and headless model references: sibling `../gg` project.
- RNC decoder adaptations: ScummVM, GPL-3.0-or-later; see decoder file headers.
- Flowers and Atari-symbol banner pixel patterns: `tools/make_banners.py`.

No source archives or sibling projects are modified by the build.

## Renderer fixes and validation

The original options menu now renders from its own loop, independently of the
pending SID sound request (`$97DD`). The menu keeps the original title/credits,
and palette entry 3 follows the C64 background colour used by the tile atlas.
The renderer stops at the sprite-list terminator, restores the pitch before
sprites on each picture, and compares all character and colour cells per picture.
Player images use the full original 24x21 sprite, clipped at the viewport edges.

Regression tests cover stale visible sprites after the terminator, simultaneous
character changes in different screen quarters, colour-only changes on all rows,
menu advertising preservation, fine scrolling, edge clipping and VBI-only
publication. Integration tests exercise visible menu startup with a pending
sound request, joystick menu navigation and fire-to-start. They also reject
unexpected opcodes, shared BCB writes during a blit, OS ROM re-enabling under
runtime code, and non-silent POKEY output.

These are headless checks, not full-machine validation. Sprite expansion in the
menu previews, full matches, every menu mode and real-hardware frame pacing
still need further work or validation. Sound remains disabled.

Latest validation: 1,000 PAL frames at `$D600`, 300 at `$D700`, and 70 exact
pixel comparisons. A 1,200-frame layer check exercised 452 pictures and 183
scroll moves with zero cache/layer mismatches. The 400-frame measured portion
of `python3 tools/speed.py 800` completed 375 game-loop iterations and 168
renders (about 46.9 logic iterations/s and 21 pictures/s in this PAL headless
model); these figures are not a real-hardware benchmark.
