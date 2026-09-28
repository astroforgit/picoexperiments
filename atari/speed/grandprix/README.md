# SPEEDMAZA GRAND PRIX

A race for up to three cars on Atari XL/XE, made from
[SPEEDMAZA RACE](../race). It keeps SpeedMaza's look: status bar, DLI colour
bands, two-colour tracks with walls pulsing to the music, and the "MAZA
PASSED!" screen. It races on the four tracks of the PICO-8 "1k racing" game
([`../picospeed.txt`](../picospeed.txt)), drawn twice the PICO-8 size, with
S-bends on the straights and a road wide enough for three cars.

![tracks](gen/tracks_preview.png)

## Options screen

Joystick up/down picks a line, left/right changes it. Fire, SPACE or START
starts the race.

| Option | Choices |
|---|---|
| PLAYERS | 1 (you + 2 computer cars) or 2 (joysticks 1 and 2 + 1 computer car) |
| TRACK | 1–4 |
| LAPS | 1–5 |
| DIFFICULTY | EASY, NORMAL or HARD: how fast the computer cars drive, how much they brake before bends, and how hard they chase you |
| SPEED | SLOW, NORMAL or FAST: start speed, how fast it grows, and its limit |
| OIL | ON or OFF: oil patches on the road |
| FLASH | How much the screen flashes. NONE: steady colours. SOFT: the walls pulse gently with the music, nothing flashes. NORMAL: as in SpeedMaza, the pulsing grows and the road and borders flash late in the race. HARD: the same, four times sooner |

The HI SCORE is the best human score.

## Racing

- **Start:** 3-2-1-GO with beeps. The bottom lines show the track and the
  number of laps.
- **Controls:** joystick left/right steers. Up/down makes the car a little
  faster/slower (±25%). Everybody's speed also grows with time, as in
  SpeedMaza.
- **Walls:** you can't leave the road. The car bangs (noise), bounces back,
  turns a little towards the track, is slowed for half a second, and loses
  **25 points**.
- **Other cars:** cars that touch swap speeds and are pushed apart (thud).
- **Oil** (grey patches): the car slides with almost no grip for a moment
  and wobbles.
- **The screen** follows you in 1-player mode, and the leading human in
  2-player mode.
- **Falling behind (2 players):** if the trailing player drops off the
  screen, they come back just behind the leader, on the leader's lap, and
  lose **100 points**.
- **Computer cars** are never put back. They drive on out of sight with the
  same physics and walls (the game checks their position against the
  track), take their checkpoints and laps, and reappear when they catch up
  or are caught.
- **Points:** +10 per checkpoint (about 110–130 per lap). The winner of a
  race gets **+1000**, second place **+500**.
- **End of a race:** it ends a moment after the second car finishes. The
  results screen lists the cars by points.
- **ESC** goes back to the options.

The status bar shows the race time. The two lines at the bottom show each
car's points and lap (or its place), in the car's colour: orange (P1), blue
(P2 or AI) and green (AI).

## Build and run

```sh
../decompiled/build.sh regen      # once: makes ../decompiled/unpacked.bin
./run.sh                           # play (builds grandprix.xex if needed)
./run.sh rebuild                   # rebuild, then play
./run.sh auto                      # watch a self-driving race (testing)
```

Needs `mads`, and Python 3 with numpy and Pillow. XL/XE with BASIC off (the
file switches BASIC off while loading).

## How it works

- **Tracks.** `tools/make_data.py` draws each PICO-8 track into an ANTIC
  mode 8 map, as the race does, and stores every row as its road spans.
  Most rows are stored as small changes from the row above. That stream and
  the checkpoint tables are packed with a small LZ77 variant, about 2 KB per
  track, 8 KB for all four.
  - Three packed tracks load at `$6000` and are moved to `$0700-$1FFF` at
    start-up, where DOS was; the fourth sits after the code.
  - When a race starts, `LoadTrack` unpacks the chosen track to `$6000` and
    rebuilds the rows in the work area at `$3000`. From there they are
    unpacked into the ring of 32 rows as the screen scrolls.
  - The generator checks that its Python copy of this rebuild gives the
    same rows, and the 6502 code was checked against it in a simulator.
- **Computer cars.** They steer towards the next checkpoint. Their throttle
  is: difficulty level, minus braking by the sharpness of the next bends
  (precomputed per checkpoint), plus a rubber band (faster when behind the
  best human, slower when ahead).
  - Off the screen there are no collision registers, so each frame their
    centre is looked up in the track's span rows (`OnRoad`), and a wall
    bounces them as on screen.
  - After any wall hit a car also steps a few pixels towards its next
    checkpoint, which becomes its safe place, so a car pressed against a
    wall always gets back onto the road.
- **Oil.** Patches are drawn into the rows as they are unpacked (colour 1).
  The PnPF collision bit for colour 1 makes a car slide.
- **Sound.** Effects play on channel 4, written right after the RMT player
  each frame, so they sound over the music.
- **The rest** is as in the first version: players 0-2 are the cars,
  hardware collisions for walls and cars, respawn from the leader's
  position history, and two text lines under the track.

## Tuning

At the top of `grandprix.asm`: `TURN`, `THR_MAX`, `GRIP_*`, `OIL_TIME`,
`STUN_*`, `COUNT_STEP` and `PT_*` (points). Next to the options screen:
`spdStart/spdAcc/spdMax` (the SPEED choices), `optDefault` (the options at
power-on) and `aiLevel/aiBrake/aiBand` (the DIFFICULTY choices).

In `tools/make_data.py`: `SCALE`, `ROAD_R`, `WIGGLE_*` (track shape), `GRID`
(starting places) and `OIL` (patches per track).

For testing, `mads grandprix.asm -d:AUTOPILOT=1 -d:TESTOPT=1` builds a
self-driving 1-lap race.
