# Sójka VBXE

This is a self-contained Atari XL/XE + VBXE interpretation of the original
**Sulka**, presented here as **Sójka**. It
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

The title and ending screens use original generated pixel artwork based on the
bird protagonist. Sójka appears as an upright gothic-sepia fantasy artist with
a silk scarf. The ending places the hero safely in a nest overlooking a galaxy
and displays: “You have found a new nest with a view to the whole universe.”
The title credits Kultisti as the game author and astrofor for the Atari port.
After the title, the corrected Polish story is presented across two readable
pages. Fire or Space advances each page before level 01 begins. The story uses
a native 40-column ANTIC screen and a custom Latin-2 VGA 8×8 charset, preserving
clear Polish characters without image scaling. `generate_screens.py` converts
the title and ending into compact 160×100 VBXE RLE images and generates the
story charset and text pages.

The included stages follow the complete original room progression:
`rTuto1`–`rTuto5`, `rViiva0`–`rViiva6`, the halfway transition,
`rKey1`–`rKey5`, `rGrav1`–`rGrav5`, and `rEnding`. Fly-spike movement paths
are taken from the original per-room creation code. Touching a nest ends the
room, exactly as both `oNest` and `oNest_Final` do in Sulka.js.

Level 06 (`rViiva0`) is the final tutorial room. Its large Russian-flagged
ballistic missile moves diagonally toward the upper-right as a transparent VBXE
sprite. It is not present in the 24×14 map and therefore has no collision or
gameplay effect. When its flight reaches the upper-right endpoint, level 06
automatically advances to level 07.

Crossing a vertical screen edge is fatal only when gravity continues to pull
Sójka away from the room. If Sójka passes below the room with upward gravity,
or above it with downward gravity, play continues off-screen and gravity can
bring the bird back. Horizontal steering remains available during recovery.

## Requirements

- Atari XL/XE with a VBXE running a compatible FX 1.2x core;
- MADS assembler to rebuild the executable;
- Python 3 with Pillow to regenerate the title and ending images.

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

When `sulka-levels.asm` exists in the Sójka directory, the launcher validates
and applies that editor export first. It also synchronizes `editor/levels.js`,
so refreshing the browser editor shows the map set used in the new build. It
then rebuilds `atari/sulka-vbxe.xex` and starts it through the workspace's
Altirra launcher. Altirra uses its persistent XL/XE profile, which must have a
VBXE device configured.

## Controls

- Joystick left/right or `A`/`D`: move
- Joystick fire, `Space`, or `W`: jump
- `SELECT` or `R`: restart the current level
- Fire or `Space` after completing the game: replay

If VBXE is not detected at either the `$D6xx` or `$D7xx` register page, the
program displays `VBXE REQUIRED` and stops.

## Visual transition at the rocket

Levels 1–6, including the rocket level, use surreal grey outline ruins on pure
black and hollow warm-white architectural sketch platforms. The stronger
platform contours remain distinct from the darker ruins.

From level 7 onward, gameplay uses glossy fluorescent pink/purple plastic
platforms against a painted blue-purple/teal galaxy. This is a visual theme
change only: platform footprint (16×7), origins, collision maps, hazards,
movement, and level order stay unchanged. The editor previews both themes.

Background source assets are `assets/ukr1-line-background-source.png`,
`assets/ukr2-line-background-source.png`, and
`assets/galaxy-painted-source.png`. Their corresponding `-vbxe.png` files are
exact runtime previews. Platform assets are `assets/platform-outline-0.png`,
`platform-outline-1.png`, `platform-neon-0.png`, and `platform-neon-1.png`.
Old artwork variants and original photographs are retained.

`generate_ruins.py` packs two 112×70 line backgrounds (3920 bytes each) at
$1000 and $B000. `generate_galaxy.py` packs the painted galaxy at 56×35 (980
bytes), preserving broad brush-stroke colours within the Atari memory budget.
Both display at 224×140. At startup `ruins.asm` uploads the three images to
separate VBXE banks 4, 5, and 6. Each room draws its theme into the static cache
with one blit; no additional per-frame scenery drawing is needed.

`generate_platforms.py` produces native platform run tables. Palette entries
32–47 are grey scenery, 48–53 are warm sketch contours, 54–59 are fluorescent
plastic, and 64–79 are galaxy paint colours. `theme-data.asm` stores the compact
galaxy, palette and neon sprites at $0800–$0FFF; runtime scenery routines and
outline sprites occupy $AC00–$AFFF. Assembly assertions guard these segments.
The launcher regenerates all artwork before assembly.

Verification (requires Python Pillow, py65 and MADS):

```sh
python3 atari/verify_ruins.py
```

The test assembles in a temporary directory, checks segment overlap, executes
the upload in a 6502 model, and compares every uploaded pixel against all three
background previews. It verifies theme selection and collision-map preservation
in all 24 rooms and both platform variants on either side of the rocket.
Optional `--preview FILE.png` renders static room backgrounds from assembled
routines. This is a software rendering, not an emulator screenshot; moving
actors and the rocket are not included.

Ruins were edited using built-in imagegen with a surreal grey contour-only
prompt: pure black background and interiors, no shading or filled walls,
leaning broken towers and floating fragments. The galaxy was generated with
the same tool: a hand-painted surreal galaxy, broad flowing indigo, plum-purple
and deep teal nebula brush strokes on black space, sparse stars, a sweeping
spiral, painterly gouache/oil texture and large simple masses readable at low
resolution. It deliberately stays darker than fluorescent foreground platforms.
