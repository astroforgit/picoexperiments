# Grapple VBXE Level Editor

A dependency-free browser editor for the Atari VBXE `12 × 240` Grapple map.
It exports a VBXE-focused `world.json` consumed by
`grapple/atari/generate_assets.js`; browser-game compatibility is no longer a
goal.

## Start

From the repository root:

```sh
./grapple/editor/run-editor.sh
```

The editor opens World 8, the current default map, at
<http://127.0.0.1:8090/grapple/editor/?world=/steamlinejs/world.json&revision=world-8>.
The revision keeps an older browser autosave from replacing the current
default. An alternative port can be supplied as the first argument.

## Editing

- Paint with the left mouse button and erase with the right mouse button.
- Use Brush, Erase, Fill, or Pick from the tool panel.
- The palette only contains elements implemented by the VBXE game: walls,
  checkpoints, moving bricks, cannons, spikes, thwomps, and lava. Browser-only
  bats and the boss are removed when an old map is loaded.
- Lava is an ordinary single-cell tile. Paint, fill, pick, and erase it exactly
  like spikes; there is no rectangle-selection mode or four-area limit. The
  compact 6502 data table supports up to 85 lava tiles.
- Select a moving brick or cannon to set defaults before painting. Use **Pick**
  on a placed moving brick or cannon to edit that individual entity.
- Every brick has an editable unique ID. Use **Pick** to inspect it. IDs survive
  export/import, autosave and undo/redo; duplicates are rejected.
- Each moving brick stores its own cardinal direction and movement speed.
- Chasing bricks (Thwomps) have individual maximum chase speeds, from 50 to
  500 px/s in steps of 50. Their direction follows the player automatically.
- Each cannon stores its own diagonal firing direction and bullet speed.
- Press `R` to rotate the selected entity. Moving-brick arrows show travel
  direction and dashed tracks use each cannon's configured bullet speed.
- Dashed cannonball tracks are enabled by default and can be hidden with the
  **Cannon tracks** checkbox.
- Click or drag in the overview to scroll through the full-height level. The
  mouse wheel over the overview moves eight rows at a time.
- Undo and redo use `Ctrl+Z` and `Ctrl+Y`.

The editor autosaves changes in browser storage. **Export world.json** creates
a normal JSON download. To use it in the game, replace
`grapple/bin/assets/world.json` with the exported file and rebuild Atari:

```sh
./grapple/atari/build.sh
```

The exported format sets `grappleEditor.version` to `3`. Lava is stored as tile
18. Every occupied cell has a unique persistent `id`. Moving and chasing bricks store
`speed`, while cannon cells store `bulletSpeed`;
both retain `rot` for direction. Loading an older map converts its legacy lava
rectangles to tile-18 cells automatically.

Moving blocks default to an Atari-tuned 64 pixels/second and cannonballs to
350 pixels/second. Individually saved speed overrides are preserved.

## Assets tab

The **Assets** tab lists every character the VBXE game ships, with each
animation from `../src/player.ts` running at its real frame rate. Link
straight to it with `?view=assets`.

Sprites are drawn in the colours the Atari actually uses, not the browser's.
The tab's classifiers mirror `../atari/generate_assets.js` branch for branch,
so a frame can be judged before spending a build on it; `assets-core.test.cjs`
holds them to that by comparing against the generated `*-assets.bin`. Untick
**Atari VBXE colours** to see the original two-colour source art instead.

Hero frames are captioned with both numbers that matter: the source frame in
`player.png` and the slot `choose_hero_frame` stores in `hero_frame`.

### Designing a new character

The right-hand workshop edits a replacement hero. Presets are starting points
rather than finished designs, and each is additive — it only writes into empty
pixels, so the original poses, which are the part worth keeping, cannot be
damaged. Pick a pen, choose any of the sixteen frames, and paint.

**Export player.png** writes the 80x64 sheet the pipeline already consumes, in
its own two colours: pure red for hair, white for body. Drop it over
`grapple/bin/assets/player.png` and run `grapple/atari/build.sh`. Boots,
palette packing and the run cycle follow automatically, with no generator
change — the export of an unedited hero reproduces `player.png` pixel for
pixel, which is what makes that claim testable.

## Browser playtesting

Click **Playtest** (or press `P`) to play the current edits immediately. No
export, Atari build, emulator, or page reload is needed. The playtest takes a
snapshot, so moving enemies and collected flags do not change the edited map.

- **Play from here**: click a free map cell to start there. Invalid or hazardous
  start cells are rejected. This temporary test start does not alter the Atari
  entrance in the exported map.
- **Start at**: choose the level entrance, any placed checkpoint, or the picked
  test position.
- **Arrows / WASD**: shoot and hold the grapple; release to retain momentum.
  On-screen direction buttons also support touch.
- **Space** pauses or resumes; **.** advances one frame while paused.
- **R / Respawn** returns to the active checkpoint, or the test start.
  **Restart test** clears checkpoints and deaths and returns to the test start.
- **Show collision boxes** helps inspect narrow passages and hazard boundaries.
- **Edit at player position** closes the playtest and scrolls the editor to that
  location. Escape returns to the editor without changing its scroll position.
- Switching tabs or leaving the browser window pauses the simulation and clears
  held controls, preventing unwanted movement when returning.

The simulation uses the current Atari tuning: 50 fixed updates per second,
350 px/s pulling, 1,200 px/s hook extension, 1,600 px/s² gravity, an 8×12 player
body, momentum, ground friction, half-speed water, a 0.7-second broken-hook
cooldown, deadly hazards, checkpoint respawning, eight cannonball slots, and
per-entity mover/cannon speeds. Thwomps activate offscreen and settle against
walls so they can turn into narrow shafts. Water stays at its Atari coordinates
(Y=984..1608); it is not an editable tile.

This is a browser simulation of the rules, not a hardware emulator. Real Atari
frame drops, display timing, exact sprite clipping, and some subpixel edge cases
are not reproduced. The preview deliberately keeps a stable simulation rate.

## Editing improvements and export compatibility

The **Atari export** panel shows entity counts against the current native build:
1–31 movers, 1–28 cannons, 1–63 spikes, 1–23 thwomps, 1–63 checkpoints, and
0–85 lava cells. Counts come from the map. Combined entity tables must also
fit below $8F00; the assembler checks this. The browser
preview supports different counts so you can experiment; JSON export still works,
but counts outside these ranges need correcting before the native build.

Undo/redo shortcuts leave text fields alone and are disabled during playtesting.
Maps containing duplicate cell coordinates are rejected on import. The layout
also adapts to smaller screens, with touch controls in the playtest.

## Hosting online

Everything runs as static HTML, CSS, JavaScript, and assets. The local URL above
already provides in-browser editing and testing. To host it on a static website,
keep `grapple/editor/` and `grapple/bin/assets/` at the same relative paths and
serve `/grapple/editor/`. No backend or npm dependencies are required at runtime.
Autosaves stay in that browser's storage; use JSON export to transfer maps.

## Tests

```sh
node grapple/editor/physics.test.js
# Reachability search from each checkpoint to the next (slow; EXP= raises the budget)
node grapple/editor/reachability.js grapple/bin/assets/world.json 6,7,8,9,10
# Optional: requires py65 and a current Atari build
python3 grapple/editor/compare-atari.py
# Optional: requires Playwright and the editor server
node grapple/editor/browser.test.cjs
# Assets tab core, against a current Atari build; no browser needed
node grapple/editor/assets-core.test.cjs
# Optional: Assets tab UI, requires Playwright and the editor server
node grapple/editor/assets.test.cjs
```

The assembly comparison checks 100 player ticks and 125 ticks of the nine-thwomp
chamber chase against the compiled 6502 routines. The UI smoke test exercises
play/pause/step, checkpoint starts, picking a test location, returning to editing,
undo/redo, export, and isolation of the edited map from the running simulation.

## SteamlineJS world builds

The platform map saved at `steamlinejs/world.json` uses this Grapple engine.
Open `/steamlinejs/world-editor.html` for links to edit/playtest the supplied map
and Trailblazer, plus the original and modified VBXE downloads. The separate Streamline trunk
puzzle remains at `/steamlinejs/`.

Build any compatible world without replacing the default game:

```sh
node grapple/atari/build_world.js steamlinejs/world.json steamlinejs/world-builds/original streamline-world-vbxe
```

Each output folder includes `entity-index.json`, mapping persistent IDs to the
native per-type actor slots. The `?world=/path/to/world.json` editor option loads
another map and gives it a separate browser autosave.
