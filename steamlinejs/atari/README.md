# Bimbaj for standard Atari

Bimbaj is a standard Atari XL/XE puzzle game built on Streamline. It ships with
the 56 original Streamline levels, one elephant-designed bonus board and Polish
story texts between levels, and all of them can be edited in the browser
([level editor](#level-editor)). The player is
an elephant's extending trunk, with a flared tip and two nostrils. In Dual
levels the elephants are blue and copper. No VBXE hardware is required.

The renderer uses ANTIC 4 custom characters. Small boards use 3x3-character
(24x24 display-pixel) tiles, medium boards use 2x2 and large boards use 1x1.
A board 10 cells tall uses 2x2 tiles across all 20 rows and drops the top and
bottom frame.
These square proportions account for ANTIC 4's double-width pixels: elephant
heads, rings and boulders no longer look squashed. Every board fits without
scrolling.

Quiet charcoal floors, amber boulders, cyan elephant trunks and a gold frame
use five colours per character row. Soft three-step gradients shade the actors;
the floor stays neutral so the actor gradients remain easy to read. Display-list interrupts change the palette shades
and character font on each row. Twenty private row fonts allow detailed large
tiles without a shared font's 128-character limit. The status and controls use
ANTIC 2 with the ROM font. Code, paths, tile atlases and fonts fit below $C000
on a 64K XL/XE; the Atari OS remains enabled for keyboard and frame timing.

Levels and story pages live in the 14 KB of RAM under the OS ROM
(`$C000-$CFFF` and `$D800-$FFF9`). The executable stages them at `$8000` and
an INIT segment copies each chunk under the ROM while it loads. The game
switches the ROM out, with interrupts masked, only to copy the next board into
`level_buffer` or to draw a story page. Load the game from the emulator, or
from a DOS that leaves the RAM under the ROM free (not SpartaDOS X).

Moves compose the final terrain and elephants off-screen, then update only
changed tiles. The status bar also writes only changed characters. Unchanged
tiles and the frame are never cleared on a move; a full frame rebuild is needed
only when the board dimensions change or the campaign ends.

## Build and run

Requires MADS 2.x, Node.js, Python 3 and Pillow:

```sh
./build.sh
./run-emulator
```

`run-emulator` builds `bimbaj.xex` and runs Atari800 when installed.
Under WSL it launches Altirra in a separate saved 64K Atari 800XL PAL profile,
with BASIC and expansion devices disabled. Your persistent VBXE profile is
not changed. Arrow keys, numpad and USB gamepad stick/D-pad are enabled on Atari
port 1 by default. Left Ctrl, numpad 0 or a gamepad face button acts as fire.
Input changes made in Altirra persist in `altirra-standard.ini` when you close
the emulator. The defaults file is copied only on the first launch.
Set the Windows `ALTIRRA_PATH` if Altirra is outside the toolkit's
usual locations, or pass `-AltirraPath 'C:\path\Altirra64.exe'` under WSL.

The existing VBXE game remains available separately:

```sh
./run-emulator-vbxe
```

That launcher builds `streamline-vbxe.xex` and uses the existing persistent
VBXE emulator profile. Both launchers also have `.sh` versions.

The opening screen converts `elephant.png` into a monochrome ANTIC F bitmap.
Press fire, START or Space to enter the campaign. `generate_title.py` creates
`title-screen.bin` for the standard Atari build and a
`title-screen-preview.png` to inspect the conversion. The title pixels occupy
RAM that the game reuses for its character fonts after the opening screen.

After completing levels 3, 6, 9 and 12, the game pauses for Polish story pages.
Marceli's story follows level 9. After three more original levels, the elephant's
new-level announcement follows level 12 and leads into the upside-down-cross
bonus board at level 13. The original campaign continues afterward. The VBXE
build keeps its original 56 levels.
Release the level-completion button, then press fire, START or Space to continue.

## Level editor

`bimbaj.json` holds the whole campaign as one ordered list of levels and texts.
Levels are played in list order, and each text is shown after the levels above
it. A text at the top of the list appears after the title screen; a text at
the bottom appears after the last level. Consecutive texts form one break and
share its page numbering.

Edit it in the browser:

```sh
python3 editor-server.py      # then open http://localhost:8770/
```

The server listens on localhost only. It loads `bimbaj.json`; **Save** writes it
back, **Build** runs `build.sh` and **Build & run** also starts the emulator.
Opening `bimbaj-editor.html` straight from disk also works: open the JSON file
with **Open…**, then save over it (Chrome and Edge) or download a copy. Unsaved
changes are kept as a draft in the browser.

- **List**: drag cards to reorder them, or use the arrow buttons, or
  <kbd>Alt</kbd>+<kbd>↑</kbd>/<kbd>↓</kbd>. **+ Level** and **+ Text** insert after the
  selection. Cards can be duplicated or deleted; everything can be undone.
- **Levels**: paint with the left button and erase with the right button;
  <kbd>Alt</kbd>+click picks a tile. Keys <kbd>1</kbd>–<kbd>0</kbd> and
  <kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd> choose tiles. Resize, shift,
  mirror and rotate the board (arrow tiles turn with it). The editor checks the
  Atari limits: at most 20×18 and 254 cells, one or two elephants, at least one
  ring, and portals in a single pair. It also searches for the
  shortest solution, which **Show solution** plays back. **Playtest** (<kbd>P</kbd>)
  uses the same rules as the game: arrows or WASD, Space switches elephants,
  U undoes and R restarts.
- **Texts**: the preview is the exact Atari page in the story font: 36 columns,
  20 lines per page. A blank line starts a paragraph. The font has English and
  Polish letters plus `–`; typographic quotes and dashes are converted, and any
  other unsupported character is shown in red.

The header shows how full the under-ROM storage is (levels take 2 bytes plus
one per cell, a full text page up to about 800 bytes) and lists every error; the
build refuses a campaign with errors. At most 99 levels fit the status bar.

`generate_data.js` compiles the campaign through `bimbaj-format.js`, which the
editor shares, into `bimbaj-data.inc` (pointer tables) and `bimbaj-bank.inc`
(the staged under-ROM data). `bimbaj-rules.js` holds the editor's movement
rules; `test_rules.js` replays the original game's reference traces through it.
The story font comes from the system's Unicode VGA 8x8 console font
(`/usr/share/consolefonts/Uni2-VGA8.psf.gz`).

## Controls and tiles

| Action | Joystick / console | Keyboard |
|---|---|---|
| Extend trunk | Joystick 0 | W A S D |
| Switch elephant | Fire | Space |
| Undo last move | OPTION | U or Z |
| Restart level | SELECT | R |

Diagonal joystick positions resolve horizontally, keeping puzzle movement
orthogonal. Release the stick between moves; holding a direction does not
repeatedly undo or retrigger it. W A S D and Space remain available as direct
Atari keyboard controls.

Reach the hollow ring with every trunk. Bars pause a slide; a spiral retracts
the old trunk; a cross traps the tip; paired portals teleport it; arrows force
its direction. Keys open all locks. Moving toward the immediately preceding
path cell undoes the last global move, including in Dual levels. Undo also
restores retracted paths and key/lock state. Completed elephants automatically
yield control to the unfinished one. A completed level advances automatically;
after the last level, fire or R restarts the campaign.

The movement core was checked against the recovered original JavaScript
`Player` methods. The port preserves sliding, collisions, pause/reset/trap,
portals, forcers, key/lock, global undo and the authored level data. The original
browser game's menus, progress saving and procedural infinite mode are not included.
Moves render immediately rather than using the browser's tween animation.

Storage is finite: 255 path entries per elephant and 255 recorded moves.
If an attempted move would exhaust storage, it is rejected atomically and
`TRUNK MEMORY FULL` asks you to undo or restart. This prevents path corruption
or moves that cannot be undone; very long reset-heavy detours can hit this limit.

## Tests

The normal build checks the XEX structure and level inventory. For CPU tests,
install Python's `py65` package, then run:

```sh
python3 test_game.py
```

`reference_trace.js` executes the original JavaScript Player code as the oracle.
The test runs 10,116 commands across all 56 authored boards and nine feature
fixtures against the assembled NMOS 6502 code. It also executes all board
renderers, checks zoom and font bounds, verifies the display-interrupt font and
palette sequence, and exercises keyboard, level transitions, campaign completion
and storage rollback. These CPU tests do not emulate
ANTIC/GTIA timing; the Altirra launcher is provided for full-machine testing.

The gameplay build was smoke-tested in Altirra 4.40, standard XL / ATOS / PAL /
64K with expansion devices disabled: startup, the character display and
joystick-mapped arrow-key movement. The story screen has CPU and generated-image
checks, but has not yet had a new Altirra visual check.

Game graphics are editable in `generate_tiles.js`; `build.sh` regenerates
`tiles.inc`. The opening screen is converted from `elephant.png` during the
same build.

## Sound

POKEY channel 1 plays short effects, advanced once per frame by `wait_frame`:
a rising blip for each slide, a low buzz when a move is blocked, falling
blips for undo and restart, a double beep when switching elephants, noise when
a trunk lands on a cross, a chime when an elephant reaches its ring, a C-E-G-C
jingle when a level is won, and a click on the title and story pages. Each
effect is a `[AUDF, AUDC, frames]` list in the `snd_*` tables of `bimbaj.asm`.

## Board designs

The board can be drawn in several designs, each a file in `designs/`:

- **Classic** (`classic.txt`): slate floor, amber boulders and blue goals.
  Its tiles are drawn by `generate_tiles.js`.
- **Paper** (`paper.txt`): ink drawings on squared notebook paper, after the
  PICO-8 logic games Trails and Tents & Trees.
- **Brick** (`brick.txt`): dark flagstones, brick walls, gem goals, spike
  traps and barred gates, after Pikoban and Puzzle Cave.

The editor's **Design** menu switches the design. The choice is saved as
`"design"` in `bimbaj.json`, and the next build puts it into the game. The
editor draws the game's own tiles, with 2:1 pixels and the zoom the Atari
picks for the board size, so it shows what the game shows.

A design file sets the Atari colour registers: `background` (COLBK, pixel 0),
`floor` (COLPF0, pixel 1), `light` (COLPF1, pixel 2 and the status text), `blue`
and `copper` (COLPF2 or COLPF3 for pixel 3, chosen per tile) and `status`. Floor,
blue and copper take one value per character row of a tile. The `tile` blocks are
12×24 native ANTIC 4 pixels, written with the digits 0–3, where `.` lets the
floor show through. The medium zoom is sampled from them. The smallest zoom
(boards 10 or more cells across or 11 down) has hand-drawn 4×8 `small` tiles in
`classic.txt`, which other designs reuse in their own colours; each design sets
its own `small floor`. The
elephant and trunk art is shared: `elephant` maps its outline, wrinkle,
highlight and body colours onto the design's pixels. `generate_tiles.js` writes
the chosen design's colours to `theme.inc`, and every design to
`bimbaj-tiles.js` for the editor. To add a design, add another file with all 12
tiles.

## Graphics and elephant direction update

The elephant sprite now rotates as one unit on a fixed floor tile. Its trunk
ports are centered and symmetric, matching straight and bend tiles without an
extra overlaid strip. Trunk tips also rotate independently of the floor. The
palette uses dark neutral floors, softer silver highlights, cyan and amber;
this keeps the route more prominent than the background. Classic Atari
[Boulder Dash screenshots](https://spillhistorie.no/2025/06/06/how-boulder-dash-was-created/)
were reviewed for readable silhouettes and restrained scenery contrast.

`tiles-preview.svg` shows the generated native-pixel artwork. Altirra captures
are `standard-atari-new-idle.png`, `standard-atari-new-right.png`,
`standard-atari-new-undo.png` and `standard-atari-new-up.png`. This standard
XL/XE build was checked in Altirra 4.40, PAL, 64K, with VBXE disabled.
The CPU regression checks all four head orientations at all three zooms,
including bends, undo, reset tiles and dirty redraws, plus 10,116 gameplay
commands against the original JavaScript.
