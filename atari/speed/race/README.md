# SPEEDMAZA RACE

SpeedMaza (2014, Jakub Husák) turned into a one-lap race for Atari XL/XE.
The track is track 1 of the PICO-8 "1k racing" game
([`../picospeed.txt`](../picospeed.txt)), drawn three times bigger, with its
straights turned into S-bends.

- **Taken from SpeedMaza** (ported from [`../decompiled`](../decompiled)):
  - the title screen, the HI SCORE line and the digit font. The logo says
    "HARD MAZA" (the big word is redrawn by `make_data.py`), and a
    "TINY MODIFICATIONS: ASTROFOR" credit, in the letters of the SpeedMaza
    credits and on three lines to fit, sits under them;
  - the DLI colour bars and the status line;
  - the SPEED and DISTANCE bars;
  - the chunky ANTIC mode 8 scrolling view with two colours: black road,
    and walls that pulse with the music and flash later in the race;
  - the crash screen, the "MAZA PASSED!" screen and the RMT music.
- **Taken from PICO-8:** the track's shape and the car. The car is the PICO-8 outline
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

- **Track.** PICO-8 draws the track along a centre line that bends by the
  character codes of a string. `make_data.py` rebuilds that line three times
  bigger and shifts its straight parts sideways along a sine, which turns
  them into S-bends; the big corners and a short start straight stay. Every
  mode 8 pixel closer than 35 PICO-8 pixels to the line is road
  (background), everything else wall (colour 3).
  - One PICO-8 pixel becomes 0.95 colour clocks across and 1.52 scan lines
    down, so bends stay round.
  - The map is 224 × 494 bytes, too big for memory. With only two colours,
    each row is stored as its road spans (first and last byte plus an edge
    mask for each), 7 KB in all.
  - The game unpacks the rows it shows into a ring of 32 rows at `$6000`,
    one 256-byte page each, so no display line crosses a 4K boundary.
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

With the defaults, the autopilot finishes a lap in about 70 seconds. A perfect
run of the original SpeedMaza maze takes about 88 seconds.

In `tools/make_data.py`, `SCALE` and `ROAD_R` set the track size and road
width, and `WIGGLE_A` and `WIGGLE_L` set how wide and how long the S-bends
are.
The map may be at most 256 bytes wide, and the compressed track must fit
below `$BC00`: `race.asm` stops with an error if it doesn't.
