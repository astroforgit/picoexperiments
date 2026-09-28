# Streamline: Trunk! for standard Atari

A standard Atari XL/XE port of the 56 original Streamline levels plus one
elephant-designed bonus board. The player is
an elephant's extending trunk, with a flared tip and two nostrils. In Dual
levels the elephants are blue and copper. No VBXE hardware is required.

The renderer uses ANTIC 4 custom characters. Small boards use 3x3-character
(24x24 display-pixel) tiles, medium boards use 2x2 and large boards use 1x1.
These square proportions account for ANTIC 4's double-width pixels: elephant
heads, rings and boulders no longer look squashed. All 57 boards fit without
scrolling.

Quiet charcoal floors, amber boulders, cyan elephant trunks and a gold frame
use five colours per character row. Soft three-step gradients shade the actors;
the floor stays neutral so the actor gradients remain easy to read. Display-list interrupts change the palette shades
and character font on each row. Twenty private row fonts allow detailed large
tiles without a shared font's 128-character limit. The status and controls use
ANTIC 2 with the ROM font. Code, boards, paths, tile atlases and fonts fit below
$C000 on a 64K XL/XE; the Atari OS remains enabled for keyboard and frame timing.

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

`run-emulator` builds `streamline-atari.xex` and runs Atari800 when installed.
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
To add more pages, add an entry to `story_pauses.json` with a one-based
`after_level` and `text`. Use blank lines for paragraph breaks. The build wraps
and paginates the text; entries with the same `after_level` become successive
pages. It creates a Polish character font and produces
`story-preview.png` for review. The source is the system's Unicode VGA 8x8
console font (`/usr/share/consolefonts/Uni2-VGA8.psf.gz`).

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
after level 57, fire or R restarts the campaign.

The movement core was checked against the recovered original JavaScript
`Player` methods. The port preserves sliding, collisions, pause/reset/trap,
portals, forcers, key/lock, global undo and the authored level data. The browser
menus, editor, progress saving and procedural infinite mode are not included.
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
