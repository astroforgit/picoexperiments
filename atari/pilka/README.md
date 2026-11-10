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
operand changes. The bridge supplies input, frame interrupts and VBXE drawing.

Memory:

- `$C000-$CFFF` is a permanent MEMAC-A window on VRAM `$7C000`, so the game's
  two screens are VRAM and the blitter can read them. While a picture is
  built, the window shows VRAM `$7D000` instead: the renderer (`src/render.asm`).
- `$F000-$F7FF` (the C64's VIC-only character set) holds the interrupt, the
  VBXE access routines and the relocated formation tables; `$CC00-$CFFF`
  (unused sprite patterns) holds the game-loop hooks; `$C900-$CBFF` the
  relocated menu table. Variables are at `$DC10` and `$DC40`.
- The C64 game keeps data in the RAM *under its I/O area* and reads it with
  I/O banked out: the menu table (`$D780`) and the 35-byte formation records
  (`$DA7D-$DEFF`, and `$C980,$CA80..$CF80,$D080`). The Atari has hardware,
  colour RAM and bridge variables at those addresses, so the build moves the
  data and points the game's two readers at the copies (`tools/build.py`).

Timing: the Atari VBI plays the C64 raster interrupt (`$922E`). The game loop
is hooked where it has just sorted its sprite list (`$973C`): there the scroll
position, visible screen, sprites and ball are one consistent state, exactly
what the C64 shows in the next frame. The frame wait consumes one VBI per
loop; if the loop falls behind, pictures are skipped until it has caught up,
so game speed stays at one iteration per frame. The game's time-sliced screen
copy reads a C64-equivalent raster line derived from VCOUNT.

Renderer (one picture per game loop when the blitter keeps up):

- The character layer is a 40x25-cell ring in VRAM. A C64 coarse scroll (the
  game copies its screen shifted by one cell and flips `$D018`) only moves the
  ring origin (hook at `$1269`); nothing is copied.
- The blitter XORs the C64 screen with the characters last drawn and ORs the
  result into 25 row flags and 5x25 eight-column flags. The CPU visits only
  flagged cells and queues an 8x8 tile blit for each. Colour RAM is plain RAM,
  so the CPU compares it: all rows in the menu, one rotating row in a match
  (there, colours only change together with characters).
- One blitter list then draws the picture into the hidden framebuffer: queued
  tiles, the layer through the C64's 38-column/24-row window with fine scroll
  (up to four pieces of the ring), sprites, and for sprites with C64 "behind
  foreground" priority the foreground pixels again on top. The VBI shows the
  picture once the blitter has finished, and loads the palette entries that
  follow VIC registers at the same moment.
- Tile pixels use palette indices in which foreground colours occupy bits 3-7
  and background colours bits 0-2, so "foreground only" is a transparent blit
  with AND mask `$F8`. Every background-colour pixel carries one of three
  grass shades; the palette maps them to the SWOS grass on the pitch and to
  the plain C64 background colour elsewhere (menu).
- Advertising text cells (pitch colour, characters `$D9`+) are replaced by the
  generated strip, chosen by map column so it scrolls with the pitch.

C64 sprite frames 32-127 are converted at build time to 24x21 VRAM images
(one per 512 bytes at `$60000`). The 23 multiplexed sprites come from the
game's tables (`$9F`, `$E4`, `$CD`, `$B6`); the first `$FF` Y entry ends the
list. The ball is VIC sprite 7 and is drawn last. Sprite-colour pixels are
stored as `$FF`, and the blit's AND mask turns them into palette entry
`$60` + the sprite's C64 colour. The menu's expanded sprites use blitter zoom.

## Reproducing analysis and asset extraction

```sh
python3 tools/extract_c64.py
7z x -aos -oamiga SensibleWorldOfSoccer2526_v2.3.lha
python3 tools/extract_swos.py
python3 tools/preview_swos.py
python3 tools/coverage.py
./build.sh
python3 tools/test_port.py       # boot, menu, match start, formation data
python3 tools/test_renderer.py   # every picture against a C64 rendering
python3 tools/speed.py           # cycles per frame by routine
```

The RNC1/RNC2 extractors validate compressed and decoded CRCs. All 34 graphics
files have passed those checks. Four player sheets are exported as indexed
pixels; pitch map 1 is also decoded to a full-pitch preview.

The headless models in `tools/reference` are adapted from the sibling `gg`
conversion. `nmos.py` adds the LAX instructions used by this game to py65.
The Atari model runs each blitter list at once and models only its duration;
it rejects CPU writes to VRAM a running list uses. It does not replace
testing in Altirra or on real hardware.

## Sources

- C64 game: the user-supplied `arlasoc.d64` (Arlasoft Soccer).
- Amiga grass pixels: the user-supplied `SensibleWorldOfSoccer2526_v2.3.lha`.
- SWOS layouts and palette: `SWOS-RE-main/SWOS-RE-main`.
- VBXE bridge/loader and headless model references: sibling `../gg` project.
- RNC decoder adaptations: ScummVM, GPL-3.0-or-later; see decoder file headers.
- Flowers and Atari-symbol banner pixel patterns: `tools/make_banners.py`.

No source archives or sibling projects are modified by the build.

## Validation

`tools/test_renderer.py` plays a match and compares every picture shown with
an independent C64 rendering of the state the renderer sampled (advertising
cells excluded). Latest runs: four input scripts, 3,000-4,000 PAL frames
each, at `$D600` and `$D700`: about 13,000 pictures, no differing pixel, one
game-loop iteration per frame, 0.91-1.0 pictures per frame. `tools/test_port.py`
checks boot, menu navigation, match start, that the formation records the
game reads equal the C64 data, and silent POKEY, at both register pages.

Not validated: this renderer in Altirra or on real hardware (it relies on
MEMAC-A at `$C000` with the OS ROM off, code executed from VRAM, blitter OR/XOR
modes and a zero destination step), NTSC timing, complete matches and every
menu mode. Blitter speed in the model is an estimate, so the real picture
rate may differ. Sound remains disabled.
