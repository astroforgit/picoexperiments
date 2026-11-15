# Sokoban ... in 3D! — Atari XL/XE

A native 6502 assembly adaptation of
`steamlinejs/sokonan3d/game.txt` for Atari 8-bit computers. The project uses
the same MADS/XEX structure as the games in `lkavalon-atari-main`.

## Requirements

- Atari XL/XE with at least 48 KB RAM, or an Atari 8-bit emulator
- MADS 2.x to rebuild the executable
- GNU Make (optional)

## Build

```sh
make
```

This creates `bin/sokoban-3d.xex`, ready to load in Altirra, Atari800,
Atari800MacX, or on real hardware via a suitable loader.

You can also assemble it directly:

```sh
mads main.asm -o:bin/sokoban-3d.xex
```

## Build and run

From this directory, use the one-command launcher:

```sh
./run-emulator.sh
```

It rebuilds the XEX and opens it in Altirra using the workspace Atari runner.

## Controls

- Joystick port 1: move
- Space, fire, or START: begin/continue
- Z or OPTION: undo/back one move
- R or SELECT: reset the current level

The orange crate (`C`) belongs on the orange `O`. The blue crate (`C`) belongs
on the blue `B`. A correctly placed crate changes to `*`.

Level two uses the original game's actual 3D rules. Crates and targets occupy
separate movable layers, so they can combine in one cell or separate again.
Pushing a ground-level object also carries any movable object stacked directly
above it. A player standing at height one (for example, on a wall) can instead
push only the upper object. Pushing an upper crate or target off a wall lets it
fall onto a lower object; unlike objects then combine in the same cell, so the
smaller piece appears contained by the larger one.
Objects entering the hole are removed, recreated at their own spawn point at
height two, and lowered until another object or wall supports them.

## Graphics

The gameplay renderer copies the original PuzzleScript 5×5 object pixels from
`game.txt` into a GTIA mode 10 multicolor bitmap. Pixels keep their original
positions and transparent layers; each source row is doubled vertically for a
more natural Atari display aspect. The 9×10 board occupies 45×100 bitmap pixels
and is centered in the gameplay area. Level two also draws the original
cross-cell `Top` pieces above walls, targets, crates, and the player. The 3D
renderer selects the source game's height-0, height-1, or height-2 sprite for
every movable object.

Player movement, crate pushes, and undo use dirty-cell rendering: only the old
and new entity cells (plus their level-two `Top` cells) are reconstructed. A
full bitmap refresh is reserved for level start and reset.

The source RGB colors are matched to the closest practical colors in a shared
nine-color Atari palette.
