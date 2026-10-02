# Grapple worlds saved in SteamlineJS

`steamlinejs/world.json` is a Grapple platform map, not a Streamline trunk-puzzle
level. Its matching editor and Atari runtime live under `grapple/`.
The current default map is the editor export originally saved as
`atari/world (8).json`. Its matching build is in `world-builds/world-8/`.
The earlier source JSON and game binary remain in `world-builds/original/`.

Run `./grapple/editor/run-editor.sh` from the repository root, then visit
<http://127.0.0.1:8090/steamlinejs/world-editor.html> for both maps and downloads.
Pick a placed brick to edit its unique ID; moving bricks also have direction
and speed. Chasing bricks have a maximum speed (50–500 px/s, increments of 50)
and automatically choose their attack direction. Export preserves these fields.

## Requested filled map: Grapple Trailblazer

`world-trailblazer.json` preserves the original 240-row map and fills the long
lower empty shaft with six alternating grapple chambers at rows 165, 177,
189, 201, 213 and 233. Each has a three-tile opening and a checkpoint, plus a spike
away from the opening. Existing sections have wider alternate passages and
slower hazards. There are 19 checkpoints; the final flag is at row 231.
No rows are removed. Gentle Descent below is an optional earlier shorter map.

```sh
node steamlinejs/make-trailblazer-world.js
node grapple/atari/build_world.js steamlinejs/world-trailblazer.json steamlinejs/world-builds/trailblazer grapple-trailblazer-vbxe
node steamlinejs/verify-gentle-world.js world-trailblazer.json trailblazer-playthrough.json
python3 steamlinejs/verify-world-atari.py world-builds/trailblazer trailblazer-playthrough.json
```

The continuous Trailblazer replay reaches all 19 flags in 907 PAL ticks (18.14
simulated seconds), with zero deaths in both browser physics and the assembled
6502 game. This is an optimal recorded route, not a first-time-player estimate.

## Builds

- `world-builds/world-8/grapple-world-8-vbxe.xex`: the current default map,
  with revised terrain around rows 131–136 and updated mover, cannon and
  chasing-brick speeds. It retains 17 safe checkpoint teleport destinations.
- `world-builds/world-7/grapple-world-7-vbxe.xex`: the preceding editor map,
  with 11 movers, five cannons, 84 spikes, nine chasing bricks, 17 checkpoints
  and 83 lava tiles. All flags retain generated safe teleport destinations.
- `world-builds/world-6/grapple-world-6-vbxe.xex`: the preceding editor map. It
  differs from World 5 by one removed lava tile at `(8,174)`. All 17 flags use
  generated safe adjacent destinations for keyboard teleporting and respawns.
- `world-builds/world-5/grapple-world-5-vbxe.xex`: the preceding editor map,
  with 11 movers, five cannons, 84 spikes, 11 chasing bricks, 17 checkpoints
  and 84 lava tiles.
- `world-builds/world-4/grapple-world-4-vbxe.xex`: the preceding editor map,
  with 10 movers, five cannons, 84 spikes, 11 chasing bricks, 16 checkpoints
  and 85 lava tiles. Keyboard `1`/`2` move exactly once to the next/previous
  checkpoint per physical key press, without racing through flags on repeat.
- `world-builds/world-3/grapple-world-3-vbxe.xex`: the preceding editor map,
  with full-speed movement in the blue area.
- `world-builds/world-2/grapple-world-2-vbxe.xex`: the preceding editor map,
  retained with its matching build. The Atari engine supports up to 127 spikes.
- `world-builds/trailblazer/grapple-trailblazer-vbxe.xex`: **Grapple Trailblazer**,
  the requested filled, full-height world.

- `world-builds/original/streamline-world-vbxe.xex`: the supplied world, including
  its eight movers, ten chasing bricks, 50 spikes and 13 checkpoints.
- `world-builds/gentle-descent/grapple-gentle-descent-vbxe.xex`: **Grapple Gentle
  Descent**, generated from the supplied world. Removes 70 empty shaft rows,
  connects the original checkpoint sequence with wider alternate passages,
  clears hazards close to those passages, and retains one mover, one cannon,
  one chasing brick, nine spikes and 20 lava tiles. Remaining movers run at
  32 px/s, cannonballs at 150 px/s and chasing bricks at 100 px/s.

Gentle Descent ends at the final flag in row 161. The engine has no separate
victory screen. The map keeps a 12×240 storage grid for editor/runtime
compatibility; unused rows below the shortened level are solid padding.
Water still occupies the engine's fixed Y=984–1608 band.

Build from the repository root (Node.js and MADS required):

```sh
node steamlinejs/make-gentle-world.js
node grapple/atari/build_world.js steamlinejs/world.json steamlinejs/world-builds/original streamline-world-vbxe
node grapple/atari/build_world.js steamlinejs/world-gentle-descent.json steamlinejs/world-builds/gentle-descent grapple-gentle-descent-vbxe
```

Each folder contains generated assets, assembly/labels, the input world and an
ID-to-native-slot inventory. Only the named release XEX and ID inventories are
kept as deliverables; other build intermediates are reproducible.
Load the XEX in an Atari XL/XE emulator configured with VBXE FX, or compatible
hardware. The gameplay controls are the same Grapple joystick controls.

## Verification

```sh
node grapple/editor/physics.test.js
node steamlinejs/verify-gentle-world.js
python3 steamlinejs/verify-world-atari.py  # requires py65
```

The deterministic playthrough visits all 13 flags continuously in 633 PAL ticks
(12.66 simulated seconds), with zero deaths. The same inputs pass on the actual
assembled NMOS 6502 gameplay routines, including actor/hazard updates and
checkpoint collisions. The input recording is `gentle-descent-playthrough.json`.
This is an automated optimal route, not an estimate of a new player's time.
Native chase speed caps were also checked at 50, 100, 200 and 500 px/s.

All three XEX files pass segment-overlap and generated-asset checks. The default
Grapple world also passes the existing CPU movement/rendering/chase regressions.
Browser UI tests verify ID edits, direction/speed, undo/redo and JSON round trips.
CPU tests do not emulate VBXE video timing; these new builds have not been
visually tested in a full-machine emulator or on physical Atari hardware.
