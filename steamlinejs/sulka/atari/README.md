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

All 24 stages are converted directly from the room instance data embedded in
`Sulka.js`: every wall block, key, door, spike, gravity line, nest, player
spawn, and fly-spike path is generated from the original GameMaker room
coordinates on the original 24×24 grid of 8-pixel tiles (a 192×192-pixel
room), centred on the VBXE overlay. Its palette and 10×12 bird sprite are
transcribed from `Sulka_texture_0.png`; the sprite mirrors horizontally while
moving and flips vertically with gravity.

All graphics are drawn at runtime with the VBXE blitter. The PNG is a visual
reference and is not needed at runtime. Sound is intentionally omitted.

Rendering follows the repository's Porter VBXE technique: the static room is
cached in VBXE memory, copied into a hidden framebuffer, and combined with the
bird before the XDL switches buffers during vertical blank. The displayed
framebuffer is never modified in place.

Movement resolves in one-pixel collision steps. Vertical motion retains
quarter-pixel accumulation, with a 6-pixel initial jump speed, an alternating
0.5/0.75-pixel/frame² gravity step (0.625 average), and a 12-pixel maximum fall
speed. This keeps the faster launch while allowing enough airtime for the
longer platform jumps. As in the
original GameMaker code, jump presses are buffered for 0.2 s
and a coyote-time window of 0.2 s after leaving the ground still allows a
jump. This runs the original GameMaker motion at approximately twice its
elapsed-time rate while keeping the same jump height.

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
`rKey1`–`rKey5`, `rGrav1`–`rGrav5`, and `rEnding`. Fly-spike movement paths
are taken from the original per-room creation code. Touching a nest ends the
room, exactly as both `oNest` and `oNest_Final` do in Sulka.js.

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

## Build and run in Altirra

From the `steamlinejs/sulka` directory, use the project-local launcher:

```sh
./run-emulator.sh
```

When `sulka-levels.asm` exists in the Sulka directory, the launcher validates
and applies that editor export first. It also synchronizes `editor/levels.js`,
so refreshing the browser editor shows the map set used in the new build. It
then rebuilds `atari/sulka-vbxe.xex` and starts it through the workspace's
Altirra launcher. Altirra uses its persistent XL/XE profile, which must have a
VBXE device configured.

## Controls

- Joystick left/right or `A`/`D`: move
- Joystick fire, `Space`, or `W`: jump
- `SELECT` or `R`: restart the current level
- Temporary direct level shortcuts for testing:
  - levels 1–10: `1 2 3 4 5 6 7 8 9 0`
  - levels 11–12: `Q E`
  - level 13: no key—the original empty `rKey0` transition is skipped
  - levels 14–24: `T Y U I O P S F G H J`
- Fire or `Space` after completing the game: replay

If VBXE is not detected at either the `$D6xx` or `$D7xx` register page, the
program displays `VBXE REQUIRED` and stops.
