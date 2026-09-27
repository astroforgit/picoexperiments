# SPEEDMAZA RACE

SpeedMaza (2014, Jakub Husák) turned into a one-lap race on the rounded
track of the PICO-8 "1k racing" game ([`../picospeed.txt`](../picospeed.txt)),
for Atari XL/XE.

- **Taken from SpeedMaza** (ported from [`../decompiled`](../decompiled)):
  - the title screen, the HI SCORE line and the digit font;
  - the DLI colour bars and the status line;
  - the SPEED and DISTANCE bars;
  - the chunky ANTIC mode 8 scrolling view with two colours: black road,
    and walls that pulse with the music and flash later in the race;
  - the crash screen, the "MAZA PASSED!" screen and the RMT music.
- **Taken from PICO-8:** track 1 and the car. The car is the PICO-8 outline
  (a long rectangle with a square inside) in orange, and it drifts the same
  way: its velocity follows its heading with limited grip.
- **Rules as in SpeedMaza:**
  - Press fire or SPACE to start.
  - The car drives by itself and keeps getting faster.
  - Touching a wall is a crash.
  - Finishing the lap shows "MAZA PASSED!".
  - The status line shows the time in tenths of a second. The best
    (lowest) time appears on the title screen.
  - ESC returns to the title screen.
- **Controls:** joystick left and right steer, as in the PICO-8 game. There
  is no gas or brake.

## Build and run

```sh
../decompiled/build.sh regen      # once: makes ../decompiled/unpacked.bin
./build.sh                         # -> race.xex
./build.sh auto                    # -> race_auto.xex, drives itself (testing)
```

`./run.sh` starts the game in Altirra, building it first if needed.
`./run.sh auto` runs the self-driving build; `./run.sh rebuild` rebuilds, then plays.

Run `race.xex` in Altirra or on a real XL/XE with BASIC off (the file
switches BASIC off while loading, as the tables live at `$A000`).

Needs `mads`, and Python 3 with numpy and Pillow.

## Files

| File | What it is |
|---|---|
| `race.asm` | The game, MADS assembler |
| `tools/make_data.py` | Draws the PICO-8 track into the map, makes the car sprites, checkpoints and sine tables, and copies SpeedMaza's pictures and music |
| `gen/` | Generated tables, plus `track_preview.png` and `car_preview.png` to look at |
| `data/` | Generated binary data included by `race.asm` |

## How it works

- **Track.** PICO-8 draws the track as discs of radius 28 along a centre line
  that bends by the character codes of a string. `make_data.py` rebuilds
  that line and marks every mode 8 pixel inside a disc as road (background),
  everything else as wall (colour 3).
  - The map is 84 × 192 bytes in four 4K pages at `$6000`, so no display
    line crosses a 4K boundary.
  - One PICO-8 pixel becomes 0.95 colour clocks across and 1.52 scan lines
    down, so bends stay round.
- **Screen.** There are two game display lists at `$5C00` and `$5C80`: the
  SpeedMaza status line, then 27 mode 8 lines, each with its own LMS
  address. Each frame the program fills the hidden one, then switches to it
  in the vertical blank, together with HSCROL and VSCROL. The car stays in
  the middle of the screen and the track scrolls under it.
- **Car.** Players 0 and 3 draw the car, from 32 pre-rotated frames. The
  crash test is SpeedMaza's: a hardware collision between those players and
  colour 3.
- **Progress.** 130 checkpoints along the centre line, taken in order, fill
  the DISTANCE bar. The last checkpoint is the start line.

## Tuning

These constants are at the top of `race.asm`:

| Constant | What it sets |
|---|---|
| `SPEED_START`, `SPEED_ACC` | Starting speed and how fast it grows |
| `TURN` | Steering rate |
| `GRIP_MAX`, `GRIP_MIN` | How much the car slides at low and high speed |
| `FX1`…`FX5` | When the colour effects start |
| `CAR_COLOR` | Car colour |

With the defaults, the autopilot finishes a lap in about 25 seconds.
