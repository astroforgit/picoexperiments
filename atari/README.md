# Atari 8-bit version

The native Atari XL/XE adaptation is in [`sokoban-3d`](sokoban-3d). It is a
6502 assembly project built with MADS, matching the layout of the reference
projects in `lkavalon-atari-main`.

Build it with:

```sh
make -C atari/sokoban-3d
```

The resulting emulator-ready executable is `sokoban-3d/bin/sokoban-3d.xex`.

## Curse of the Lich King (VBXE)

A VBXE port of the PICO-8 roguelike *Curse of the Lich King* is in [`lich`](lich). It
needs a VBXE FX core. Build it with `./build.sh` in that folder, or build and start it in
Altirra with `./run.sh`. The output is `lich/lich.xex`.

## The Lair (VBXE)

A VBXE port of the PICO-8 beat 'em up *The Lair* is in [`lair`](lair). It needs a VBXE FX
core. Build it with `./build.sh` in that folder, or build and start it in Altirra with
`./run.sh`. The output is `lair/lair.xex`.

## Phoenix (VBXE)

A VBXE conversion of the Amiga version of the arcade game *Phoenix* is in
[`phoenix`](phoenix). It runs the arcade's own program, recompiled from 8080
to 6502 code, with the Amiga version's graphics, sounds and music. It needs a
VBXE FX core. Build it with `./build.sh` in that folder, or build and start it
in Altirra with `./run.sh`. The output is `phoenix/phoenix.xex`.

## Cauldron (VBXE)

A VBXE conversion of the C64 game *Cauldron* (Palace Software, 1985) is in
[`cauldron`](cauldron). It runs the C64 program itself; the VBXE blitter
redraws the VIC-II picture (with the sprite collisions the game uses) and
POKEY plays the SID. It needs a VBXE FX core. Build it with `./build.sh` in
that folder, or build and start it in Altirra with `./run.sh`. The output
is `cauldron/cauldron.xex`.
