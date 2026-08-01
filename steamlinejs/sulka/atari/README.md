# Sulka VBXE

This is a self-contained Atari XL/XE + VBXE interpretation of **Sulka**. It
recreates the original game's central ideas with native 6502 code:

- left/right platform movement and jumping;
- directional gravity lines that reverse gravity while retaining controlled
  vertical momentum;
- collectible keys and locked exits;
- spikes, death, and instant level restart;
- all 24 rooms in the original playable progression, including the halfway
  transition and ending.

Tutorial level 1 is reconstructed from the original GameMaker room coordinates:
three isolated ascending platforms lead from the bird's starting point to the
door. Its palette and 10×12 bird sprite are transcribed from
`Sulka_texture_0.png`; the sprite mirrors horizontally while moving and flips
vertically with gravity.

All graphics are drawn at runtime with the VBXE blitter. The PNG is a visual
reference and is not needed at runtime. Sound is intentionally omitted.

Rendering follows the repository's Porter VBXE technique: the static room is
cached in VBXE memory, copied into a hidden framebuffer, and combined with the
bird before the XDL switches buffers during vertical blank. The displayed
framebuffer is never modified in place.

Movement uses two one-pixel collision steps per displayed frame. Vertical
motion retains quarter-pixel accumulation, with a 5-pixel initial jump speed,
0.5-pixel/frame² gravity, and a 12-pixel maximum fall speed. This runs the
original GameMaker motion at approximately twice its elapsed-time rate while
keeping the same jump height.

As in the original game, a gravity line triggers only when crossed in the
current gravity direction: while falling under normal gravity or while rising
under inverted gravity. Crossing it during a jump in the opposite direction
does not flip gravity. The strongest crossing speed is remembered until Sulka
hits a solid surface, preserving the height of repeated hands-off oscillations
through the line.

Gameplay graphics are transcribed from `../Sulka_texture_0.png`: the player
uses the original two-frame idle and four-frame walking animations, while the
platforms, locked/open doors, keys, gravity-line dashes, and spikes use the
original pixel shapes and colours. Rendering remains double buffered, so these
animations are assembled entirely in the hidden framebuffer.

Moving `oFlySpike` enemies use the original cyan 10×10 cross sprite and its
smaller collision box. The sprite is uploaded to VBXE memory once and drawn
with one transparent blit per enemy, avoiding a frame-rate drop in rooms that
contain moving hazards.

The included stages follow the complete original room progression:
`rTuto1`–`rTuto5`, `rViiva0`–`rViiva6`, the halfway transition,
`rKey1`–`rKey5`, `rGrav1`–`rGrav5`, and `rEnding`. Collision blocks, doors,
hazards, moving fly-spikes, gravity lines, inverted exits, and the `rViiva0`
falling/nest finish are converted from the coordinates and scales embedded in
`Sulka.js`.

Crossing a vertical screen edge is fatal only when gravity continues to pull
Sulka away from the room. If Sulka passes below the room with upward gravity,
or above it with downward gravity, play continues off-screen and gravity can
bring the bird back. Horizontal steering remains available during recovery.

## Requirements

- Atari XL/XE with a VBXE running a compatible FX 1.2x core;
- MADS assembler to rebuild the executable.

## Build

From this directory:

```sh
mads sulka-vbxe.asm -o:sulka-vbxe.xex
```

## Controls

- Joystick left/right or `A`/`D`: move
- Joystick fire, `Space`, or `W`: jump
- `SELECT` or `R`: restart the current level
- `1`: jump to the final room (temporary debug shortcut)
- `2`: advance to the next room (temporary debug shortcut)
- Fire or `Space` after completing the game: replay

If VBXE is not detected at either the `$D6xx` or `$D7xx` register page, the
program displays `VBXE REQUIRED` and stops.
