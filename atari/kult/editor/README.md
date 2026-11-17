# Kult + CETAS pixel workshop

A local browser graphics editor for both supplied Atari games. It reuses the
recovery and disk readers in `../decompiled/tools`. The original XEX and ATR
are read-only; edited games and projects are downloaded by the browser.

## Start

Requires Python 3 and `py65` (already used by the decompiler). No npm install,
network service, or build step is needed to use the editor.

```sh
cd /home/marcin/tmp/pico/atari/kult/editor
./run.sh
```

Open **http://127.0.0.1:8772**. For another port: `./run.sh --port 8773`.
Keep the terminal running while exporting. To run independently of the terminal,
use `python3 start-background.py` from this directory; rerun it after a reboot. Opening `index.html` directly is
not supported because decoding and validated export use the local server.

## Editable assets

| Game | Assets |
|---|---|
| Kult | 256 characters, 16 player sprite variants (four frames × four horizontal alignments), 128 enemy frames (32 designs × four frames), four effect frames, 34 game tiles, five menu palettes |
| CETAS | 44 unique sprites found through the game's sprite tables, 118 status characters, four full 160×192 introduction/title pictures |

These are confirmed layouts, not every byte interpreted as a sprite. The
CETAS resource F, level layouts, object scripts,
music and collision headers are not exposed as editable assets. Sprite sizes
and positions in memory remain fixed.

The UI includes pencil, connected fill, eraser, colour picker, drag strokes,
pixel grid, zoom, flips, wrapping horizontal shifts, copy/paste, clearing,
restore-original, and undo/redo (100 actions per game). Animation previews cycle the selected sprite set. The asset library can be searched and filtered.

- **Kult player sprites:** edit alignment 0, then click **Update alignment
  copies** to regenerate the three shifted versions. Do this for each animation
  frame you change. Other alignments can also be edited individually.
- **Enemy gallery:** click **All enemies & objects** to preview all 32 Kult
  enemy designs plus the effect set, or all 17 non-player CETAS object types.
  Select any thumbnail to edit it. Kult enemy alignment copies are generated
  automatically by the game from the editable source frames. CETAS columns
  are stored alignment variants; they are not necessarily animation frames.
- **CETAS sprites:** rows are stored bottom-to-top, which the editor handles.
  Shared pointers are deduplicated: editing one sprite affects every object
  referring to it. Header/collision data stays intact.
- **Preview palettes** affect only the editor/PNG appearance. They are diagnostic
  colours, not a simulation of Atari colour generation or display-list effects.
  Kult's separate menu-palette fields change the actual five-byte game tables;
  enter five hexadecimal bytes. The pixel previews do not simulate those tables.

## Saving and images

**Save project** downloads a small JSON file containing changed bytes. **Open
project** restores it for the currently selected game, as one undoable action.
The file is validated against the asset whitelist before changing anything.

Drafts are also stored locally in the browser, independently for each game.
The footer reports if browser storage is unavailable. Save a project file for
portable or long-term storage; opening a different port/browser uses different
local storage. Exported games cannot currently be reopened as editor projects;
keep the JSON file to continue editing.

**Export PNG** exports the selected asset using its current preview palette,
including wide-pixel aspect for four-colour graphics. **Import PNG** resizes to
the asset dimensions using nearest-neighbour sampling and chooses the nearest
preview colour. Transparent pixels become colour index 0. Import is undoable.

Shortcuts: **B** pencil, **F** fill, **E** eraser, **I** picker, **1–4** colours,
**Ctrl/Cmd+Z** undo, **Ctrl/Cmd+Shift+Z** or **Ctrl+Y** redo. Right-drag erases.

## Game exports

**Kult:** the two original RLE streams are regenerated within their fixed
storage ranges. The loader, load addresses and entry stub are preserved. Every
export is replayed through the original 6502 decoder and all recovered data
blocks are compared with the edited image. A change that exceeds the available
compressed space is rejected with an error; simplify pixels or undo changes.
No-edit exports are exactly the supplied XEX.

**CETAS:** edited sprites/characters are patched into executable E. Edited
pictures are stored as ordinary uncompressed load segments, which the original
resident loader accepts. The exporter retains existing file-start sectors,
extends sector chains using free sectors, and updates directory counts and the
DOS allocation bitmap. It validates every file's contents, length and chain.
The original boot code, AUTO loader and XAUTORUN introduction remain intact.
No-edit exports are exactly the supplied ATR.

Exports are named `kult-edited.xex` and `cetas-edited.atr`. Load the CETAS ATR as
a disk; its staged loading sequence is required. This is a graphics editor,
not an embedded Atari emulator. Loader/format tests passed; a full edited-game
playthrough on Atari hardware or an emulator has not been performed.

## Format evidence

- Kult `$C800-$CFFF`: 256 eight-byte, one-bit characters.
- Kult `$7450`: four player frame pointers; `$7458`: shift offsets
  `0,80,160,240`. The blitter at `$EEB7` draws five bytes × 16 rows. All twelve
  original shifted variants were checked against bit-shifted base frames.
- Kult `$FCFE` points to `$DAC0`; `$FD84` copies two bytes × 16 rows per tile.
  The `$DAC0-$DEFF` data block contains 34 such tiles.
- Kult `$C390`: palette fades read five-byte records starting at `$C402`.
- CETAS `$2C4A-$2C75` and `$2D67-$2DF4`: sprite pointers. `$2C06` reads seven
  header bytes, and `$2D3F` draws width × height bytes upwards through the screen.
- CETAS `$5000-$53AF`: status character bank, followed by screen data.
- CETAS A/B/C/D: decoded 40-byte × 192-row picture resources, copied by `$0ECD`.

## Tests

```sh
python3 -m unittest discover -s . -p 'test_*.py' -v
node core.test.cjs                    # Node 18+
node browser.test.cjs                 # Playwright and a running server
```

The browser test accepts `EDITOR_URL`, `PLAYWRIGHT_MODULE`, `CHROMIUM_PATH`
and `EDITOR_SCREENSHOT`. Tests cover packed pixels, bottom-up rows, asset
bounds, rejection of code edits, no-edit identity, sprite/palette/tile export,
multiple enlarged disk files, original-loader acceptance of a raw picture,
painting, history, alignment copies, PNG/project round-trips, both downloads,
draft restoration and narrow layout. A browser screenshot is in `preview.png`.

## Comparing the games

See [structure and mechanics](../STRUCTURE-COMPARISON.md) for the traced loading,
rendering, object, wave, movement and collision systems.

## Play Kult in the browser

The **Play Kult** link opens the native browser reconstruction at
http://127.0.0.1:8772/web/. It uses extracted original graphics/maps and wave
data, with adapted gameplay. See [browser edition notes](../web/README.md).
Editor drafts do not automatically change the browser game.

## Play CETAS in the browser

**Play CETAS** opens http://127.0.0.1:8772/cetas-web/ on the same local server.
It uses the recovered sprite bank, title art, spawn script and movement tables,
with browser gameplay adaptations. See [CETAS browser notes](../cetas-web/README.md).

## Diabolic wave editor and simulator

Open `/flight/` (Wave & flight editor). Each sector has a horizontally scrollable
48-card timeline with animated-design thumbnails and encounter/path/HP summaries.
Select any card to edit its wave, move it earlier/later, or copy and paste it over
another wave. These edits use the existing project JSON and Atari export format.

**Play from selected wave** runs the remaining waves of that sector, preserving
bombs, shields and weapon choice. **Loop selected wave** resumes individual path
tuning. **Play draft in browser game** opens `/web/` with a snapshot of the draft,
without changing the applied Atari game. Browser playback shares the current
native sprites, circular pickups and bottom-only HUD. Save/Open project retains
wave edits; Apply to local game rebuilds the native executable.

### Sub-boss bullet formations

Six attacks use Kult's original sine table (`$7164`): **Sine sweep**, **Cosine
arc**, **Double-sine ribbon**, **Reverse sine sweep**, **Folded arc**, and
**Braided ribbon**. Each bends the curtain horizontally and moves
the opening vertically. Ordinary enemy motion edits do not change these attacks.
Original enemy-18 projectiles keep the larger two animation frames visible.

After a one-time 24-update entrance, six bullets form over 16 updates (following
a two-update charge), then rush left at a nominal 24 pixels/update, four times
the ship's 6 pixels/update. Trigonometric offsets slightly vary individual speed.
A new wave begins every 30 updates. Its formation overlaps the older wave's two
trailing guards. The guards are normally 16 updates behind; calibrated mixed-pattern
transitions release them one update earlier to preserve its reaction margin.
Each projectile stores its own lane and pattern so a new wave cannot alter an
older guard's path. Slots can be reused only after the previous shot exits.

The opening alternates between upper and lower positions. With a 40×16-pixel
ship and 16×16 bullets, the evaluated curtains block approximately 87–89% of
legal ship heights at X=24 pixels. The trigonometric gap width varies slightly.
No stationary height survives the sequence at the tested flight columns.
Bombs clear both generations and give a fresh entrance delay.

The boss remains fixed at X88/Y48 in native colour-clock/scanline coordinates.
The legacy difficulty value remains compatible with saved projects; its control
is hidden because these measured waves currently use a single speed.

### Boss wave test environment

Open http://127.0.0.1:8772/boss-lab/ (also linked from the flight workshop).
It displays native projectile traces, hitboxes, X/Y plots, a time scrubber,
verified escape routes and manual arrow-key dodging. Playback speed is adjustable;
wall-clock update rate depends on Atari rendering load.

Regenerate after building or applying edited paths:

```sh
python3 diabolic/boss_lab.py
```

The lab decodes the **built XEX**, measures joystick transitions from `$E95B`,
and records the actual `$6550` boss routine across three changing openings. A two-dimensional reachability search
allows a three-update reaction delay initially and at every opening transition,
with an extra two-pixel collision margin.
126 starting cases cover all six patterns and the rotating sequence. Each chosen route is
replayed through native joystick and collision code for nine waves, with no
invulnerability, shields or bombs. This establishes a route for those cases,
not a guarantee for arbitrary player movement. The native bullet collision uses
the complete 40×16 ship and 16×16 projectile bounding boxes, including transparent
corners. `test_boss_lab.py` checks the boundary comparisons against 6502 execution.

`editor/boss-lab.test.cjs` compares every native projectile position against the
browser simulation. The lab checks the XEX hash and marks traces stale after a
new export. `editor/boss-lab.browser.test.cjs` exercises the visual controls.

The acceptance test rejects a sequence without an escape route, with an idle
camping position, with less than 85% peak danger, or with an opening transition
that leaves less than three or more than four reaction updates after movement.
Measured transitions allow 12–13 updates in total; the minimum repositioning
takes 9–10. The lab reports contiguous safe bands and danger percentage for
every update, plus each transition's movement and reaction budgets. Seconds
remain conditional on the selected playback rate. `boss_lab.py` reads the built
XEX; exported traces are shared by pattern to keep the JSON artifact small.

Formation parameters and guard timings live in `editor/boss-formations.json`.
The native builder generates `boss-formations.js` and packs the same parameters
into Atari RAM, so preview/export settings share one definition. Presets 1–3
remain compatible; presets 4–6 are available in the editor and native exports.

Additional regression coverage includes every rotation entry with both opening
directions, a 24-wave continuous run, bomb resets in formation and rush phases,
invalid settings, and loader round-trips for the new presets. Negative controls
reject closed walls, empty/easy waves, excessive preparation time, and a ship
unable to move vertically. Browser tests replay every native winning joystick
route and check all 64 collision-boundary cases. The editor tests exercise all
six previews, preset persistence and browser-game handoff.

Meteor sections offer top-down (1), bottom-up (2), right-to-left (3), and alternating top/bottom (6). The mixed section uses separate columns, never crossing horizontal and vertical streams. Each lane owns one meteor; no lane can respawn until its previous meteor exits. The first meteor remains slow, spawning stops after 192 updates, and active meteors drain naturally. The default sequence adds the mixed section at wave 11. Native/browser position parity and pairwise lane separation are covered by `test_encounters.py` and `editor/meteors.test.cjs`.

### Boss appearance gallery

The flight workshop now has four animated 64×64 boss choices: Bone Dragon, Iron Manta, Void Kraken, and Insect Queen. Click a card or
use the selector, inspect its four frames, then use **Preview boss fight**.
Selection is saved in browser drafts/project files, passed to the browser game,
and written into native exports. **Apply to local game** and press **1** after
restarting Atari to see it. The main boss on **6** is now the generated Insect Queen.
