# Grapple — Atari VBXE movement prototype

This is the first native Atari XL/XE + VBXE milestone for the game in the
parent directory. It deliberately contains one fixed room and concentrates on
the original hero, animation, gravity, collision, and grapple movement.

## Fidelity in this milestone

- the original 16 hero frames used by idle, horizontal grapple, rise, fall,
  and death states are converted directly from `../bin/assets/player.png`;
- the artwork is nearest-neighbour doubled to 32×32 VBXE pixels;
- directional input shoots a four-way grapple, as in the browser game;
- the hero stops while the hook extends at 800 logical pixels/second;
- a wall hit pulls the hero at 200 logical pixels/second;
- releasing the direction removes the grapple but preserves momentum;
- gravity is 800 logical pixels/second squared, with the original 400
  pixels/second vertical speed limit;
- collision uses the original narrow 8×12 player body inside the 16×16 art;
- the room is rendered into flicker-free 320×200, 256-colour double buffers.

The original player class has dormant run/jump actions used by the boss AI,
but normal player input only operates the grapple. This prototype keeps that
distinction.

## Controls

- joystick directions: shoot/hold the grapple in that direction;
- release the joystick: release the grapple and keep momentum;
- SELECT or `R`: reset the room.

## Build

MADS 2.x and Node.js are required:

```sh
./build.sh
```

The result is `grapple-vbxe.xex`. Enable a VBXE FX 1.2x core at either `$D6xx`
or `$D7xx` in the Atari emulator before loading it.
