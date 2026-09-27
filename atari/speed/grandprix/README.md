# SPEEDMAZA GRAND PRIX

A 3-car, 3-lap race for Atari XL/XE, made from
[SPEEDMAZA RACE](../race). It keeps SpeedMaza's look: status bar, DLI colour
bars, two-colour track with walls pulsing to the music, and the "MAZA
PASSED!" screen. It uses the curvy PICO-8 track, drawn twice the PICO-8 size
with a road wide enough for three cars.

## Playing

On the title screen, move the joystick or press SELECT to choose:

- **1 PLAYER:** you against two computer cars.
- **2 PLAYERS:** joystick 1 and joystick 2, plus one computer car.

Press fire, SPACE or START to go to the grid. Press fire again to start the
race. ESC goes back to the title.

| Joystick | What it does |
|---|---|
| Left / right | Steer |
| Up / down | A little faster / slower (up to ±25%) |

Everybody's speed also grows with time, as in SpeedMaza, up to a limit.

- **Walls:** you can't leave the road. Hitting a wall bounces the car back
  onto the road, turns it a little towards the track, slows it down for half
  a second, and costs **25 points**.
- **Other cars:** when two cars touch, they swap speeds and are pushed apart,
  so ramming someone from behind shoves them forward and slows you down.
- **Falling behind:** the screen follows the leader. A car that drops off the
  screen comes back just behind the leader, pointing the right way and on the
  leader's lap, and loses **100 points**.
- **Points:** +10 for every checkpoint (about 130 per lap). The winner gets
  **+1000**, second place **+500**.
- **End of the race:** a moment after the second car finishes, the results
  screen lists the cars by points. The best human score becomes the HI SCORE
  on the title screen.

The status bar shows the race time. The two lines at the bottom show each
car's points and lap (or its place once it has finished), in the car's
colour: orange (P1), blue (P2 or AI) and green (AI).

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

It uses the same engine as [SPEEDMAZA RACE](../race/README.md): a compressed
map unpacked into a ring of rows, two display lists switched in the vertical
blank, and the PICO-8 drift physics. The differences:

- **Cars.** Players 0-2 draw the three cars (8 pixels wide, 32 directions).
  Each car's state is kept in arrays and copied to the zero-page working set
  for the physics.
- **Collisions.** Hardware collision registers are used: P*n*PF for walls and
  P*n*PL between cars. They describe the frame just shown, so the game
  remembers where each car was shown. The last shown place without a wall
  hit is where a car goes back to.
- **Screen.** The display list has the SpeedMaza status bar, 23 mode 8 track
  lines, then two mode 6 text lines. A second DLI sets the car colours for
  the text lines.
- **Camera and respawn.** The camera follows the leader: most laps, then most
  checkpoints. Every 4 frames each car remembers its position. A car that
  falls off the screen is put where the leader was 8 frames earlier.
- **Computer cars.** They steer towards the next checkpoint, as the race's
  autopilot does. The second one drives slightly slower.

## Tuning

Constants at the top of `grandprix.asm`:

| Constant | What it sets |
|---|---|
| `LAPS` | Number of laps |
| `SPEED_START`, `SPEED_ACC`, `SPEED_MAX` | Starting speed, how fast it grows, and its limit |
| `THR_MAX` | How much up/down changes the speed |
| `TURN` | Steering rate |
| `STUN_WALL`, `STUN_BUMP` | How long a car stays slowed after a hit |
| `AI_THR`, `AI2_THR` | Speed of the computer cars |
| `PT_*` | Points |

In `tools/make_data.py`, `SCALE`, `ROAD_R` and `WIGGLE_*` set the track, and
`GRID` sets the starting places.

With the defaults a lap takes about a minute and the race about 3 minutes.
