# Porter Patch — Atari VBXE port

This is a new port based directly on `porterpatch1-1.p8`. It does not use the
old conversion's 29 isolated room snapshots.

## Improvements over `atariold`

- complete mutable 128x64 PICO-8 world map;
- original 16x16-screen camera layout and all 28 checkpoint coins;
- 12x12 pre-scaled artwork, giving a 192x192 playfield instead of 128x128;
- jump buffering, coyote time, and four-direction teleporting that remains
  available while Porter is jumping or falling after his first landing;
- red/blue switches, green keys, crumble blocks, falling rocks and rising
  feathers;
- animated hazard/clock tiles, deaths, checkpoint respawn and end sequence;
- horizontal sprite flipping through the VBXE blitter;
- event sound effects through POKEY.

## Controls

- joystick left/right: move and aim horizontally
- joystick up/down: aim vertically
- joystick trigger: jump
- `SPACE`: teleport in the aimed direction, including while airborne
- teleporting into a wall or outside the world kills Porter
- trigger or any direction on the title screen: start immediately
- the title automatically starts the game after roughly two seconds
- trigger on the end screen: restart
- Atari `OPTION`: toggle all sound on/off

## Build

Install MADS, then run:

```sh
./build.sh
```

The output is `porter-vbxe.xex`. A VBXE 1.2-compatible core is required.
