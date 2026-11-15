# Cauldron for Atari XL/XE + VBXE

This is a conversion of the C64 game *Cauldron* (Palace Software, 1985; disk
image `Cauldron.d64`). The Atari runs the **original C64 program**: the
title sequence and its music, the scroll menu, the flight over the
landscape, the bats and the other creatures, the caves, the magic, the
score and the hags are all the game's own 6502 code. The Atari side
emulates the C64 hardware the game uses: the VIC-II picture is redrawn by
the VBXE blitter (including the sprite collisions the game depends on), the
SID by POKEY, and the joystick port by the Atari's.

It needs an Atari XL/XE with 64 KB and a VBXE with an FX 1.2x core at
`$D600` or `$D700`. PAL and NTSC machines both run the game at the C64's
50 frames per second (NTSC skips one game frame in six).

## Controls

| C64 | Atari |
|---|---|
| joystick in port 2 | joystick 1 |

The game uses only the joystick and its button (the button starts the game
from the title; up takes the witch off the ground).

## Build and run

```sh
./build.sh     # -> cauldron.xex
./run.sh       # build, then start the persistent Altirra VBXE profile
```

The build needs MADS 2.x and Python 3 with `py65` and `numpy` (`Pillow` for
the test tools). `tools/d64.py` extracts the disk files into `disk/`:
`CAULDRON` (a crack intro, not used), `CAU_CODE` (the loader) and `PALACE`
(the game, `$0F00-$CF02`). The loader copies 8 KB of game data under the
KERNAL (`$E000-$FFFF`), loads `PALACE` and starts it at `$800A`; the build
recreates that state with the C64 model (`tools/cauldron.py`).

`gen/codemap.json` is the code map of the game (`tools/codemap.py`, from
the survey runs of `tools/survey.py`); the build reads it to find every
instruction that touches the C64 chips.

## How it works

**Running the C64 program.** The game's code is `$800A-$AA2F`; everything
else is data, so the program stays at its own addresses. The runtime uses
memory the game never touches: code A at `$0200-$0D37` (stubs, hooks, the
NMI and IRQ entries, the C64 IRQ runner), variables at `$DC10-$DFFF`, and
three 8 KB code banks in VRAM switched into `$E000-$FFFF` by MEMAC-A: R (the
renderer), N (vertical blank: picture flip, palettes, sound) and I (set-up).

**Patches.** `tools/patch.py` rewrites each instruction that touches the
C64 chips (about 320). VIC-II and SID registers go to shadows at `$DE00` and
`$DF00` with the same low address byte; reads of the raster, of the
collision latches, of the SID's random oscillator and of the joystick port,
and the IRQ acknowledge, become calls to stubs. Stores into screen and
colour RAM go through small trampolines that mark the rows they reach;
stores into the charsets mark the characters that really changed (the game
animates its scenery by redrawing glyphs). The game's coarse scroll
routines are hooked so the renderer can shift the scrolled band instead of
redrawing it.

**Raster interrupts.** At each vertical blank the NMI counts a C64 frame
and wakes the IRQ with a one-pixel blit. The IRQ (the blitter's end-of-list
interrupt) runs the game's raster IRQ handlers in raster order, as the C64
would have run them during the frame, and logs the VIC registers after
each one. Running them from a real IRQ keeps the game's own `SEI`/`CLI`
sections intact. The game's main loop runs whenever the IRQ does not.

**Picture.** The C64 screen is kept as a 320x200 character layer in VRAM.
Rows the game wrote are compared with shadow copies of screen and colour
RAM, and changed cells are blitted from tiles expanded from the charsets
(multicolour and hires versions, re-expanded when the game animates a
glyph; tiles of glyphs not on screen are expanded only when needed). A
coarse scroll shifts the layer band with one blit and turns the shadow
rows into rings, so only the new columns are compared. Each picture copies
the layer into the back framebuffer per raster region (fine scroll, 38
columns, blanking) and draws the sprites from a cache of expanded sprite
images, sprite 7 first so that sprite 0 is on top. Sprites behind the
foreground are patched with the layer's foreground pixels. Pixel values
are palette indices that say which colour register they use, so colour
changes only rewrite the palettes; each region uses one of the three
overlay palettes.

**Collisions.** The game reacts to the VIC's sprite collisions (the witch
touching the landscape, bats hitting her). Before the sprites are drawn,
each sprite is XORed into the framebuffer with the blitter's collision
detection set to character foreground pixels, then XORed again (the
framebuffer is unchanged); the code of that blitter run tells whether the
sprite touched the foreground, and in which region (its raster line). The
sprites are then drawn with detection set to sprite pixels, which gives
the sprite-sprite collisions. The IRQ at the end of each run reads the
result. The game gets the collisions as the C64 would give them: latched
in `$D01E/$D01F` and as collision interrupts at the line where they
happened, a frame later.

**Game speed.** The game advances its animations once per pass of its
main loop, so its speed depends on how much time that loop gets. The IRQ
measures the time it takes (VCOUNT and the vertical blank count) and a new
picture starts only when the main loop has had about what a C64 would give
it (`MAIN_VC` in `src/runtime.asm`, about 13K cycles per frame). In busy
scenes this gives 10-17 pictures per second; the game itself runs at the
C64's speed.

**Sound.** The SID's three voices play on POKEY: voice 3 on channels 1+2
joined (16 bits), voices 1 and 2 on channels 3 and 4 (8 bits). The ADSR
envelope is modelled per frame; noise plays as POKEY noise.

## Verification

```sh
python3 tools/compare.py "650:0xEF,700:0xFF" 1200 100 /tmp/c   # C64 vs Atari, side by side
python3 tools/verify_render.py /tmp/c-atari.pkl /tmp/v.png     # framebuffer vs the VIC renderer
python3 tools/passes.py /tmp/c-c64.snap /tmp/c-atari.pkl 40 9b5e  # main loop passes per frame
python3 tools/speed.py /tmp/c-atari.pkl 40                     # where the time goes
python3 tools/bprof.py /tmp/c-atari.pkl 12                     # renderer profile
```

- `tools/c64.py`, `tools/cauldron.py` and `tools/vic.py` are a headless C64
  model (py65, VIC-II and CIA registers, raster IRQs, VIC sprite
  collisions) and a VIC-II renderer. `tools/atari_emu.py` is a headless
  Atari + VBXE model (from the Ghosts'n Goblins port, with the blitter's
  end-of-list IRQ, collision detection and XOR mode added).
- `tools/compare.py` runs both from power-on with the same joystick script,
  indexed by C64 frames, and saves both machines' states at the end.
- `tools/verify_render.py` captures the C64 memory when a picture's render
  starts and compares the shown framebuffer with `tools/vic.py` pixel by
  pixel (the title, the landscape while scrolling and a cave room match
  exactly or differ in a few pixels).
- `tools/check_shadow.py` checks the renderer's shadows against screen and
  colour RAM after each picture; `tools/flight.py` and `tools/trace_up.py`
  compare the witch's movement on both machines.

The model snapshots contain the runtime: remake them after a build.

## Known limitations

- Not yet checked in Altirra or on real hardware (only in the headless
  models).
- Sprites are drawn over the 7-pixel left and 9-pixel right borders of the
  38-column regions (the C64 hides them there).
- The picture is redrawn 10-17 times per second in busy scenes (the game
  itself keeps the C64's speed).
- SID waveforms other than noise play as pure tones; filters are ignored.
