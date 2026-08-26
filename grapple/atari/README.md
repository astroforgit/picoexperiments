# Grapple — Atari VBXE scrolling prototype

This native Atari XL/XE + VBXE milestone combines the original hero and
grapple movement with a simple scrolling version of the browser game's full
12×240-tile map.

## Fidelity in this milestone

- the original 16 hero frames used by idle, horizontal grapple, rise, fall,
  and death states are converted directly from `../bin/assets/player.png`;
- the artwork is nearest-neighbour doubled to 32×32 VBXE pixels;
- directional input shoots a four-way grapple, as in the browser game;
- the hero stops while the hook extends at an Atari-tuned 1,200 logical
  pixels/second;
- a wall hit pulls the hero at 350 logical pixels/second, increased from the
  browser game's 200 so the tall map can be traversed faster on Atari;
- releasing the direction removes the grapple but preserves momentum;
- player gravity is an Atari-tuned 1,600 logical pixels/second squared—twice
  the browser value—with the original 400 pixels/second vertical speed limit;
- collision uses the original narrow 8×12 player body inside the 16×16 art;
- the original solid map cells are converted directly from
  `../bin/assets/world.json` into a compact 2,880-byte map;
- the 3,824-pixel-tall world uses 16.8-bit player coordinates and a smooth
  pixel-following camera;
- visible map cells are drawn as simple cave blocks into flicker-free 320×200,
  256-colour double buffers.
- all six original moving blocks are generated from tile entity 13, retain
  their original positions and directions, default to an Atari-tuned 64
  pixels/second, support an individual editor-defined speed, and
  reverse when they hit the map; their dark interior uses a stronger red
  contrast on Atari so the original white outline remains easy to see;
- moving-block physics activates near the viewport, keeping distant blocks at
  their authored positions while avoiding unnecessary map collision probes;
- the first original moving-block pair is in the row-77 chamber at world
  Y=1,224; the other four are in rows 90–94;
- touching a moving block silently resets the current prototype to the level
  entrance, matching the original block's deadly behavior without sound.
- all 41 original spike entities are generated at their exact map positions
  and fixed rotations using the original `spikes.png` artwork; spikes never
  animate or change frame;
- lava is generated as independent 16×16 tile-18 cells, like spikes; older
  four-rectangle maps are rasterized to the same tile format during builds;
- lava cancels the grapple as soon as the hook enters it, so the hook cannot
  pass through lava and attach to a wall beyond it;
- touching spikes or lava silently resets the player to the level entrance;
- all three original cannons retain their source-map positions and rotations;
  nearby cannons fire once per second, default to an Atari-tuned 350
  pixels/second, and support an individual editor-defined bullet speed, with
  projectile gravity, horizontal drag, wall impact, and deadly player contact;
- all nine original thwomps are generated from tile entity 17; walls and other
  thwomps block their four-way line of sight, and a clear view makes them
  attack immediately at 150 pixels/second, accelerate at an Atari-tuned 2,500
  pixels/second squared, and reach up to 500 pixels/second;
- thwomps use the original awake, active, and sleep artwork, collide with the
  map and one another, sleep for the original 0.7 seconds after impact, and
  reset the player on contact;
- all 11 original checkpoints retain their map positions and rotations;
  touching one raises its flag, lowers the previously active flag, and makes
  it the respawn point for hazard deaths and manual resets;
- hero, mover, rotated spike, cannon, cannonball, thwomp, and checkpoint
  graphics are packed in the XEX and expanded directly into VBXE memory,
  avoiding overlap with the Atari text screen.
- adjacent cave tiles are rendered as horizontal runs instead of individual
  blocks, substantially reducing per-frame VBXE blitter commands.

The original player class has dormant run/jump actions used by the boss AI,
but normal player input only operates the grapple. This prototype keeps that
distinction. Enemies other than moving blocks, cannons, and thwomps, plus
water, dialogue, music, and sound are intentionally omitted from this
milestone.

## Controls

- joystick directions: shoot/hold the grapple in that direction;
- release the joystick: release the grapple and keep momentum;
- SELECT or `R`: reset to the original level entrance.

## Build

MADS 2.x and Node.js are required:

```sh
./build.sh
```

The result is `grapple-vbxe.xex`. Enable a VBXE FX 1.2x core at either `$D6xx`
or `$D7xx` in the Atari emulator before loading it.

## Run in Altirra

From the repository root, build, verify, and launch the game with:

```sh
./grapple/atari/run-emulator.sh
```

The runner can also be called from any other working directory. It uses the
saved VBXE Altirra configuration managed by `atari-vbxe-toolkit`.
