# Double Dragon for Atari XL/XE + VBXE

This port runs the **original NES game code** on the Atari's 6502. The VBXE
reproduces the NES picture. The game logic is not rewritten: every mission,
enemy, move, weapon, the bosses, Mode B (the one-on-one fighting mode), the
experience levels, the title and menus, and the music and sound effects come from
the game's own program.

The code is taken from the SNES port in `../double-dragon-snes-main`, whose
eight PRG banks are the NES program with its PPU, APU and mapper accesses
turned into calls. The Atari build replaces those calls with a runtime that
emulates the NES video hardware with VBXE bitmaps and the blitter, and its
sound chip with POKEY.

The earlier adaptation in `../atari` is a separate, rewritten game and is
left unchanged.

Requires an Atari XL/XE with 64 KB and a VBXE with an FX 1.2x core (512 KB
VRAM) at `$D600` or `$D700`. Both PAL and NTSC machines run the game at its
original 60 game frames per second.

## Controls

The controls follow the Celeste and Lair ports: a second fire button on a
2-button joystick (Joy2B+ style, pins 5/9), joystick 2's fire, or the
keyboard.

| NES | Action | Joystick | Keyboard |
|---|---|---|---|
| D-pad | walk (depth too), climb | joystick 1 | W A S D |
| B | punch | fire | O, Z, C, N |
| A | kick | button 2 or 3 of a 2-button joystick, or joystick 2's fire (one-player games) | P, X, V, M, SPACE, SHIFT |
| A+B | jump | fire + second button | punch key + kick key |
| Start | start, pause | START | RETURN |
| Select | choose the mode | SELECT | |

On the title screen fire (or START/RETURN) opens the mode menu. On the
menu, joystick up/down (or SELECT) moves the heart and fire (or
START/RETURN) begins. In two-player games player 2 uses joystick 2: fire is
punch and button 2/3 of a 2-button joystick is kick.

Every key press is caught by a keyboard interrupt, so short taps are never
missed. W/A/S/D stay held until the keyboard is idle or the opposite
direction is pressed. The Atari keyboard reports only one key at a time, so
for a keyboard jump press the punch and kick keys together, or hold SHIFT
and tap a punch key. A joystick button counts only after it has been seen
released once (Altirra holds a console key while booting). A
second/third button is a change from the level its line had when the game
started, because the wiring differs (Altirra's two-button joystick reads
high when pressed, Joy2B+ sticks read low). Don't hold these buttons while
the game loads.

Below the logo the title screen shows only the "ATARI VBXE CONVERSION
ASTROFOR" credit. The copyright, TRADEWEST and Nintendo licence lines are
removed.

The moves are the NES game's: punches and kicks, back kick (kick away from the enemy), jump
kick, grabs (walk into a dazed enemy), knee, throw, the elbow and the spinning
kick that are learned with experience, picking up and using weapons. See the
NES manual for the full list.

## Build and run

Requirements: MADS 2.x, Python 3.8+ with `py65`, `numpy` and `Pillow` (the
last three only for the test tools).

```sh
./build.sh            # -> double-dragon.xex
./run-emulator.sh     # build and start the persistent Altirra VBXE profile
```

The build reads the SNES port's sources directly; nothing is downloaded.
Outputs and listings go to `gen/`.

## How it works

**Memory.** PRG banks 0-6 are uploaded into VRAM while the XEX loads and are
mapped at `$8000-$BFFF` by the VBXE's MEMAC-A window. An MMC1 bank switch is
a single register write. The fixed bank 7 lives in the RAM under the OS ROM
at `$C000`. The NES RAM `$0000-$07FF` is used as is. The runtime occupies
`$0A00-$3FFF`, and its game-side services `$4000-$4FFF`.

**The I/O hole.** Bank 7's `$CFA1-$D80E` overlaps the Atari's hardware
registers at `$D000-$D7FF`. `tools/relocate.py` moves the block to `$3000`
and patches every reference. It builds a static code map of all eight banks
(recursive disassembly with jump-table detection) and checks it against
execution traces of the reference model. The build fails if it finds a
reference it does not account for. The patches are 50 operands, 7 jump and
pointer tables, a pushed return address, and 6 calls from banks 6 and 7.

**Video.** PPU writes go to RAM copies of the two nametables and mark the
changed tiles dirty. Every vertical blank the runtime builds a blitter list:

1. Changed tiles are drawn into two 256×240 nametable bitmaps in VRAM.
2. The visible window is copied to the back framebuffer. This takes up to
   four rectangles for the horizontal and vertical wrap, plus the HUD below
   the sprite-0 split, reproduced from what the NES code set.
3. All 64 sprites are drawn. Flips use negative blitter steps, palettes use
   the AND mask, and transparency uses blitter mode 1.

The finished frame is shown by switching the XDL. Tiles are expanded from
2-bit CHR into 8-bit VRAM on demand. Most of that happens while the game
code is waiting for the next frame. The NES "show the left 8 pixels" setting
is done with player 0 in front of the overlay.

**HUD.** The game draws the HUD below a split made with sprite 0. Frames in
which its frame handler did not run (lag frames) keep the last split, so the
HUD does not flicker.

**Timing.** The game's NMI handler runs once per game frame. On NTSC this is
every vertical blank. On PAL, display list interrupts add one tick so that
there are 6 ticks in 5 frames (60 per second).

**Sound.** The NES sound driver runs unchanged. Its APU registers become
POKEY values each frame: pulses on channels 1-2, triangle on 3 (moved up
octaves where POKEY's 8-bit divider cannot reach), and noise on 4. Envelopes,
length counters and the triangle's linear counter are modelled.

## Verification

```sh
python3 tools/verify_render.py 2500 --every 50          # PAL, Mode A
python3 tools/verify_render.py 2500 --every 50 --ntsc
python3 tools/verify_render.py 2000 --every 40 --modeb
python3 tools/soak.py 20000                             # long bot run
```

- `tools/atari_emu.py` is a headless Atari + VBXE model: py65 CPU, MEMAC-A
  and -B, blitter with a timing model, XDL, ANTIC display list interrupts
  and POKEY.
- `verify_render.py` renders the NES state each composed frame was made from,
  using the NES PPU's rules, and compares the Atari framebuffer pixel by
  pixel.
- `soak.py` plays with an invincible bot (a test-only RAM poke) and stops
  if the game stops running.
- `tools/nesmodel.py` runs the same banks against a modelled NES. It was
  used for the coverage traces (`tools/coverage.py` writes `gen/trace.json`,
  which `relocate.py` uses to extend its code map).
- `tools/vbi_profile.py` shows where the vertical-blank work spends its
  cycles, `tools/tickrate.py` counts game ticks per second on PAL and NTSC,
  and `tools/two_player.py` drives player 2 with the second joystick.
- `tools/analyze.py` and `tools/disasm.py` are the static code map and a
  plain disassembler for the banks.
- `tools/altirra-keys.ps1` sends keys to Altirra and captures its window.

Checked in Altirra 4.40 (NTSC + VBXE FX 1.26): loading, the title, menu and
gameplay. Real hardware has not been tested.

## Limitations

- **Sound.** POKEY approximates the NES APU. There is no sweep unit and no
  DMC samples, and very low triangle notes are moved up an octave.
- **Screen changes.** A full-screen redraw is drawn over a few frames while
  the old picture stays up, so new screens appear slightly later than on the
  NES.
- **Sprite limits.** All sprites are drawn, so the NES 8-sprites-per-line
  flicker does not occur.
- **Loading time.** The XEX is about 260 KB.
