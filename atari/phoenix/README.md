# Phoenix for Atari XL/XE + VBXE

This is an Atari XL/XE + VBXE conversion of the Amiga version of *Phoenix*,
`phoenix500` by jotd (in [`src/phoenix-main`](src/phoenix-main)). Like the
Amiga version, it runs the arcade game's own program. The Amiga version
transcoded the arcade's 8085 code to 68000 code. This build recompiles the
same code to 6502 code. The graphics, the sounds and music, and the gameplay
changes come from the Amiga version.

Everything in the arcade game is here: the attract mode, one-player and
two-player games, the two bird waves, the two vulture (phoenix) waves, the
mothership, the shield, the bonus lives and the high score.

It needs an Atari XL/XE with 64 KB and a VBXE with an FX 1.2x core at `$D600`
or `$D700`. It runs at the arcade's 60 game ticks per second on both PAL and
NTSC.

## Build and run

```sh
./build.sh      # -> phoenix.xex (and gen/phoenix-arcade.xex, see Verification)
./run.sh        # build, then start the persistent Altirra VBXE profile
```

The build needs MADS 2.x and Python 3 with `numpy` and `Pillow`. The test
tools also need `py65`. Every input comes from the Amiga sources, and nothing
is downloaded:

- the arcade ROM from `src/game_rom.68k`, with the Amiga text "PRESS FIRE"
  instead of "INSERT COIN";
- the tiles from the Amiga version's recoloured graphics
  (`assets/tiles/aga`);
- the sound effects from `assets/sounds/*.wav`;
- the music from `assets/sounds/phoenix_conv.mod`.

The recompiler also reads `gen/trace.json`, the coverage record of the
reference model, which is kept in the repository. `python3 tools/coverage.py`
rebuilds it in about 10 minutes.

## Controls

| Action | Joystick | Keyboard |
| --- | --- | --- |
| move | left / right | |
| fire | fire | |
| shield | down, or button 2 of a two-button joystick | SPACE, SHIFT |
| insert a coin, then start a one-player game | fire (on the title screens) | OPTION = coin, START = 1 player |
| start a two-player game | | SELECT (needs 2 credits) |

On the title screens, the first press of fire inserts a coin and the next
press starts a game. Joystick up also starts a one-player game. Fire must be
released after a game ends before it inserts a coin again. A console key
counts only after the game has seen it released once, because Altirra holds a
key while it boots. Like the Amiga version, the game has 3 lives and bonus
lives at 3,000 and 30,000 points.

A two-button joystick is detected on the paddle lines, as in the Lair and
Double Dragon ports. Don't hold its buttons while the game loads.

## How it works

### Recompiling the arcade code

`tools/translate.py` disassembles the 16 KB arcade ROM from its entry point,
its jump tables, and the addresses that the reference model executed. It then
writes each 8080 instruction as 6502 code (`gen/game.asm`, about 16 KB):

- The 8080 A register is the 6502 accumulator. B, C, D, E, H and L are in
  zero page, arranged so that `(HL)` is `(zL),y` with Y always 0.
- The Z and S flags are the 6502 Z and N flags. The carry is the 6502 carry.
  A 6502 subtraction leaves the carry inverted, so an analysis gives each
  instruction that sets the carry a polarity, and every branch, ADC, SBC and
  rotate that reads the carry uses the right one. No fix-up code was needed.
- An analysis of which values are still needed later works across calls,
  returns and jump tables. A 6502 sequence that destroys a flag or A saves
  it only where the 8080 code still needs it.
- BCD score arithmetic (`ADD`/`ADC` followed by `DAA`) uses the 6502
  decimal mode. The two `DAA`s that adjust a plain binary value use small
  routines.
- `JP (HL)` jump tables compare HL with the known targets. The trick at
  `$0EE3` (`POP HL; POP HL; JP (HL)`, which returns two levels) becomes
  `PLA PLA RTS`. The arcade stack is the 6502 stack.
- Some arcade code pushes a code address and reaches it with `RET`. One case
  is the computed jump into the unrolled copy loop at `$3520`. The other is
  the per-state handler chain built from the table at `$3F00`. At these
  `PUSH BC`s the 6502 pushes the address of the translated code instead. The
  analysis follows the same paths.
- If the arcade code jumps through an illegal table slot, the arcade board
  reboots. The Atari version restarts the game too.
- The ROM data tables stay at their arcade addresses, `$0400-$3FFF`. The
  arcade RAM is at `$4000-$4FFF`.
- Stores through HL, DE or BC call a small routine that does four things.
  It ignores writes to ROM, which the arcade code makes and the arcade board
  ignores. It queues changed video RAM tiles. It writes plain RAM directly.
  It sends writes to the video, scroll and sound registers to their handlers.
- The vertical-blank wait at `$0080` becomes `rt_frame`. The routine at
  `$0460` that copies the shared variables between the players' RAM banks is
  replaced. The second RAM bank lives in VRAM and is swapped with the bank at
  `$4000`.
- The copyright check at `$1DF0` returns. The Amiga ROM image has its `HALT`
  removed.

`tools/patches.py` lists every change to the arcade code.

### Display

The arcade has two 26×32 tile layers. A scrolling background holds the stars
and the mothership. A foreground layer, with colour 0 transparent, holds
everything else. The VBXE keeps each layer as a 256×256 bitmap. The changed
tiles from the queue are drawn into these bitmaps with the blitter: the
runtime compares each one with a shadow copy and draws only tiles that
really changed. After a RAM bank switch or a full queue, every tile is
compared over a few frames.

Each frame, one blitter list then composes the picture in the back
framebuffer. The list copies the background with its vertical scroll, in up
to four pieces where it wraps. It then draws the foreground rows that have
visible tiles, with transparency. The VBI shows the finished frame.

The arcade picture is 208×256 pixels. The VBXE overlay shows 240 lines, so
tile rows 3 and 31 are left out. They are blank in almost every frame: in a
2,500-frame play-through, row 3 had something in 44 frames and row 31 in 20.
The picture is in the middle of a 256-pixel-wide overlay.

The Amiga AGA sheets draw each tile in two colourings, one for each arcade
palette. Each pixel is stored as the index of its pair of colours (46
foreground and 92 background pairs). Switching the arcade palette is then
just loading the other VBXE palette.

### Timing

On PAL, game ticks are spaced by the beam position: one every 130 VCOUNT
units (5/6 of a frame), which gives 60 ticks per second. On NTSC there is one
tick per frame. A frame is composed when the back buffer is free, so a slow
frame only delays the picture, never the game. During the bird waves the CPU
is about 70-80% busy.

### Sound

The Amiga version plays samples at its sound triggers. The same triggers start
POKEY sounds here, on the same four channels: shield and explosions, hits,
shots, and the looping sounds.

`tools/make_sound.py` turns each Amiga sample into a POKEY envelope with 50
steps per second. Each step's volume comes from the sample's level. The pitch
is its strongest frequency, played as a pure tone, unless the spectrum is
flat; then POKEY noise plays instead.

The two tunes come from the Amiga version's module, played by a small
ProTracker model with its tempo, volume slides and pattern breaks: *Jeux
Interdits* when a game starts and *Für Elise* when the mothership is
destroyed. Two voices play underneath the sound effects.

### Changes from the arcade (from the Amiga version)

- **"PRESS FIRE"** replaces "INSERT COIN".
- **Don Hodges' fix** for the score corruption ("204K bug") that happens
  when three flying birds are shot.
- **The high score updates** as the score changes, not at game over. It is
  not saved to disk.
- **Bonus lives** come at 3,000 and 30,000 points (the easiest dipswitch
  setting).
- **Not taken from the Amiga version:** the Amiga version forces the
  vultures to rise when they have not risen for a while. Its README explains
  that this works around its transcode not reproducing the arcade's
  behaviour. This build runs the arcade logic exactly (see Verification), so
  the vultures move as in the arcade.
- **Not taken from the Amiga version:** the cheat keys and command-line
  options.

## Verification

- `tools/arcade.py` and `tools/i8080.py` are a reference model of the arcade
  board (an 8080 core with the Phoenix memory map).
- `tools/coverage.py` plays all the stages on the model and records every
  executed address, ROM data read, I/O access and jump-table target in
  `gen/trace.json`. The recompiler checks itself against this record.
- `tools/lockstep.py` runs the model and the Atari build
  (`gen/phoenix-arcade.xex`, which leaves out the gameplay changes) tick by
  tick with the same inputs. It compares the whole 4 KB arcade RAM, both
  banks, after every tick.
- `tools/verify_render.py` compares every composed Atari frame, pixel by
  pixel, with a picture of the same RAM drawn by `tools/render.py`.
- `tools/profile.py` counts game ticks per second and CPU use.
  `tools/cycprof.py` shows where the cycles go.
- `tools/atari_emu.py` is the headless Atari + VBXE model from the Double
  Dragon port.

Results with the final build:

- **Game logic:** the 4 KB of arcade RAM was identical after every tick in
  long runs. The runs covered one and two players, PAL and NTSC, all the
  stage types (both bird waves, both vulture waves and the mothership) and
  the start of the second round. Two of the runs used invincibility and no
  level skipping, and passed 14,000 ticks each.
- **Level skipping:** runs that skip levels with the MAME cheat sometimes
  stopped early. In those runs the cheat had put the arcade into a state
  where its own code overwrote the stack it keeps in RAM, or jumped into
  data. The model then crashes, but the 6502, whose stack is separate, does
  not. Each run was identical up to that point.
- **Bugs these tests found and fixed:** a carry-polarity error before `RLA`,
  the threaded-code returns, and three runtime bugs in the tile rescan.
- **Speed:** 60 game ticks per second on PAL and NTSC in all stages.

Checked in Altirra 4.40 with NTSC and VBXE: loading, the title screen, coin
and start, the first bird wave, scoring and the live high score. Real
hardware has not been tested.

## Limitations

- **Sound** is a POKEY approximation of the Amiga samples.
- **The high score** is kept only until the machine is switched off.
- **Tile rows 3 and 31** are not shown.
- **Screen changes:** a full-screen change, such as a new stage or switching
  players, is drawn over a few frames.
