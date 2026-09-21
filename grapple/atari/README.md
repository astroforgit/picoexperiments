# Grapple — Atari VBXE scrolling port

This native Atari XL/XE + VBXE milestone combines the original hero and
grapple movement with a scrolling version of the browser game's full
12×240-tile map.

## Fidelity in this milestone

- the original 16 hero frames used by idle, run, horizontal grapple, rise,
  fall, and death states are converted directly from
  `../bin/assets/player.png`;
- the artwork is nearest-neighbour doubled to 32×32 VBXE pixels;
- the browser game's five-frame run cycle (original frames 5–9) plays while
  the hero is grounded and moving faster than the same 20 pixels/second
  threshold the other animation states use; earlier milestones fell through
  to the idle frames whenever she ran. Five frames do not fit a power-of-two
  phase mask, so the cycle steps once per animation phase and wraps by hand,
  holding the browser's 12 fps cadence;
- `./run-character.sh` builds and runs an alternative hero without replacing
  the default build. It defaults to PixelCharacterV1 and takes any other sheet
  as its argument; `--build-only` skips the emulator. Each character is
  assembled into `builds/<sheet name>/`;
- `BUILD_DIR` sends a whole build elsewhere. The assembly is copied there
  before assembling, because mads resolves `icl` and `ins` relative to the
  directory holding the source file — assembling in place would silently pick
  up this directory's generated files and build the wrong character;
- the hero's sheet can mark regions with flat colours instead of drawing them:
  red is hair, white the top, green the legs, and blue the skin. A sheet using
  only red and white keeps the older two-colour reading. `PLAYER_SHEET` picks
  the sheet, and her colours are emitted into the generated
  `player-palette.asm`, so switching character switches palette with it. See
  `../design/PixelCharacterV1/` for a converted alternative;
- the hero has palette entries of her own — hair, top, legs, and skin — so a
  character can be restyled without disturbing the white shared by spikes,
  checkpoints, and mover outlines. The original art is two-colour, red hair on
  a white body, and it keeps exactly those colours: its top and legs are both
  painted that same white, so the boots the generator derives from the lowest
  three rows stay invisible unless a character gives them a colour;
- directional input shoots a four-way grapple, as in the browser game;
- the hero stops while the hook extends at an Atari-tuned 1,200 logical
  pixels/second;
- a wall hit pulls the hero at an Atari-tuned 350 logical pixels/second;
- releasing the direction removes the grapple but preserves momentum;
- player gravity is an Atari-tuned 1,600 logical pixels/second squared, with
  the original 400 pixels/second vertical speed limit and ground friction;
- collision uses the original narrow 8×12 player body inside the 16×16 art;
- the original solid map cells are converted directly from
  `../bin/assets/world.json` into a compact 2,880-byte map;
- the 3,824-pixel-tall world uses 16.8-bit player coordinates and a smooth
  pixel-following camera;
- terrain uses inexpensive horizontal solid runs with depth colours changing
  from black through white, brown, blue, grey, and green; the 64-pixel colour
  transitions are approximated in 16-pixel bands;
- per-tile outlines are disabled: that extra pass exceeded the Atari CPU
  budget. The 320×200 double buffers and depth colours are retained;
- moving blocks are generated from tile entity 13, keep their
  editor positions and directions, default to an Atari-tuned 64
  pixels/second, support an individual editor-defined speed, and
  reverse when they hit the map; their interiors are black with the original
  white outlines;
- moving-block physics activates near the viewport, keeping distant blocks at
  their authored positions while avoiding unnecessary map collision probes;
- the original moving-block pair is in the row-77 chamber at world Y=1,224;
  three more are in rows 90–94 and one is the piston in the row-174 corridor;
- touching a moving block silently resets the player to the active checkpoint
  (or the entrance before a checkpoint is activated);
- up to 127 spike entities are generated at their map positions
  and fixed rotations using the original `spikes.png` artwork; spikes never
  animate or change frame;
- lava is generated as independent 16×16 tile-18 cells, like spikes; older
  four-rectangle maps are rasterized to the same tile format during builds;
- lava cancels the grapple as soon as the hook enters it, so the hook cannot
  pass through lava and attach to a wall beyond it; a broken hook prevents
  another shot for the original 0.7 simulation seconds;
- touching spikes or lava silently resets the player to the active respawn point;
- all cannons keep their editor positions and rotations;
  nearby cannons fire once per second, default to an Atari-tuned 350
  pixels/second, and support an individual editor-defined bullet speed, with
  projectile gravity, horizontal drag, wall impact, and deadly player contact;
- all thwomps are generated from tile entity 17; walls and other
  thwomps block their four-way line of sight, and a clear view makes them
  attack at 150 pixels/second, accelerate at 2,500 pixels/second squared,
  and reach up to 500 pixels/second;
- thwomps detect and pursue the player even outside the short
  viewport; only drawing is culled, so attacks from the left shaft and
  upper chambers can reach the player;
- wall impacts advance to the last free pixel before sleeping, allowing
  16-pixel blocks to turn into the original 16-pixel shafts;
- thwomps use the original awake, active, and sleep artwork, collide with the
  map and one another, sleep for the original 0.7 seconds after impact, and
  reset the player on contact;
- all checkpoints keep their editor positions and rotations;
  touching one raises its flag, lowers the previously active flag, and makes
  it the respawn point for hazard deaths and manual resets;
- hero, mover, rotated spike, cannon, cannonball, thwomp, and checkpoint
  graphics are packed in the XEX and expanded directly into VBXE memory,
  avoiding overlap with the Atari text screen.
- adjacent cave tiles are rendered as horizontal runs instead of individual
  blocks, substantially reducing per-frame VBXE blitter commands.

The original player class has dormant run/jump actions used by the boss AI,
but normal player input only operates the grapple. This prototype keeps that
distinction. Bats, the boss, dialogue, music, and sound remain unimplemented.

The original water region (world Y=984..1608) remains visible in cyan, but uses
the same player, grapple, gravity, and cooldown speed as the black regions.
Water is currently a solid backdrop;
translucency over sprites, bubbles, ripples, and splash effects remain to do.
The viewport remains 160×100 logical pixels, versus the original 160×240.
Physics is tuned for PAL 50 Hz; NTSC timing and real blitter performance need
emulator/hardware validation.

## Level layout

`../bin/assets/world.json` is the current default VBXE level exported from the
editor. The supplied original and an earlier reworked map are kept in
`../bin/assets/backups/`. In the earlier reworked map rows 0–103 are the
original gauntlet, minus a few redundant entities that were moved down so the
formerly empty lower half (rows 104–124 and 156–237, the browser game's bat and
boss areas) could be built out within the native entity budget:

- rows 104–124: two warm-up rooms with lava veins in the wall and a lava lake;
  only some rows allow a hook to reach the far wall without breaking;
- rows 156–170: alternating lava ledges (a hook that crosses lava breaks and
  the player free-falls for 0.7 s), ending in a bait-and-run thwomp room;
- rows 173–177: a spiked corridor with a vertical piston block;
- rows 178–193: a lava-veined shaft with a cannon whose arc crosses the only
  stone landing gap;
- rows 194–217: a one-tile thwomp shaft with side pockets; the thwomp must be
  baited twice, then the final checkpoint sits in a sheltered pocket.

Entities were rebalanced, not added: 41 spikes, 9 thwomps, 6 movers, 3 cannons,
11 checkpoints, 78 of the 85 lava tiles. Every checkpoint-to-checkpoint section
was verified reachable with the editor's physics (`../editor/atari-physics.js`)
by an automated search, and the thwomp/cannon sections were also replayed with
non-frame-perfect inputs.

## Controls

- joystick directions: shoot/hold the grapple in that direction;
- release the joystick: release the grapple and keep momentum;
- keyboard `1`: move once to the next checkpoint flag;
- keyboard `2`: move once to the previous checkpoint flag;
- teleports and respawns use a generated safe empty tile beside each flag;
- SELECT or `R`: reset to the active checkpoint, or the entrance before one is activated.

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

## Verification

`build.sh` verifies generated assets, entity data, terrain tables, required
symbols, and non-overlapping XEX segments. Optional assembled-code tests use
Python 3 and `py65`:

```sh
python3 test_runtime.py
```

These tests compare terrain/water pixels against an independent pixel
reference and exercise movement, full-speed water boundaries, ground friction, hook speed,
break recovery, thwomp acceleration, offscreen attacks, wall occlusion, and
the authored chamber’s right/down/left chase. They capture rectangle fills and do not emulate TV timing
or the VBXE blitter.

## Performance

Tile-row addresses are precomputed, and hook/lava collision uses a direct
tile lookup instead of scanning all lava entities for each hook pixel. Ground
friction skips collision probes when horizontal velocity is zero.

Across four sampled depths, terrain traversal now costs about 10,000 CPU
cycles versus 34,000–40,000 with the outline pass. These measurements exclude
rectangle-fill execution and blitter waits; they are not a measured frame rate.
The runtime tests enforce CPU-cycle limits for terrain and hook traversal.
