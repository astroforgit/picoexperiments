# Romek — Atari XL/XE

A native 6502 adaptation of NinaBirb's PuzzleScript game in
[`../transition.txt`](../transition.txt). The project follows the standalone
MADS/XEX layout used by `atari/sokoban-3d`, while keeping that reference
project unchanged.

The title screen is inspired by ProHiBan's dedicated illustrated opening, but
uses original Romek artwork, a mixed bitmap/text display, an animated palette,
and a two-item menu for starting a new game or reading the game description.

## Requirements

- Atari XL/XE with at least 48 KB RAM, or a compatible emulator
- MADS 2.x
- GNU Make (optional)

## Build

```sh
make
```

The executable is written to `bin/transition.xex`.

The committed Atari bitmap can be regenerated from the full-resolution source
artwork (requires Python and Pillow):

```sh
make title-assets
```

To build and launch it through the workspace Atari runner:

```sh
./run-emulator.sh
```

The same one-command launcher is also available from the Transition project
root:

```sh
../run-emulator.sh
```

## Controls

- Joystick port 1 or arrow keys: move
- Title screen: joystick or arrow keys choose an option; Fire, SPACE, or START
  confirms
- Game description: Fire, SPACE, or START advances through the five story
  pages; the final press returns to the title menu
- Fire, SPACE, or START: begin/continue
- Z or OPTION: undo one move
- R or SELECT: restart the level

## Port details

- Includes all 21 maps from the browser/PuzzleScript version.
- Uses the original two-room, 13×13 flickscreen layout.
- Implements pushing, key/lock removal, targets and flags, hazards,
  reincarnation bodies, blocked spawn transfers, and room-object restoration.
- Uses GTIA mode 10 with ProHiBan-inspired 6×7 tiles expanded to 14 scanlines
  across three bitmap banks. The 13×13 room occupies 78 of the 80 available
  color clocks, producing near-square tiles without cropping the board.
- Walls receive outlines only on exposed sides, so adjacent wall cells form a
  continuous brick structure. Wall faces and outlines are rendered together in
  one pass. Controllable players have directional two-frame walk animation.
- Tile drawing remaps scanlines across the three 64-line bitmap banks, keeping
  players and walls intact on rows that cross scanlines 64 and 128.
- Movement uses dirty-cell rendering and a packed four-byte tile clear. The
  joystick repeats every video frame and movement audio does not block input.
- Flickscreen changes compare the new room against a cached 13×13 visual state,
  then repaint only changed cells and their immediate neighbors. The visible
  bitmap is not cleared, preventing full-screen flashes.
- The fixed nine-color palette reserves separate blue and neutral-gray entries:
  immutable/purple objects stay blue and inactive players stay gray. Remaining
  colors approximate the original PuzzleScript palette where hardware colors
  must be shared.
