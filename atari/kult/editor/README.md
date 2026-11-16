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

### Boss bullet patterns

Select rotating attacks, a curved fan, a weaving stream, or a slower slalom, plus
three intensity levels. Preview boss fight opens a temporary skull encounter
without changing the selected wave. Show bullet paths projects each active shot's
trajectory. Settings persist in project JSON and Atari exports.

Both versions emit from the boss's front/mouth (head X, head Y + 16), not from
screen-wide lanes. A 24-update muzzle warning precedes four shots spaced eight
updates apart. A second train follows, then all shots drain before the next
192-update cycle. Each shot has its own age and phase, producing staggered curved
formations. Captured vertical aim is fixed for that cycle; bullets do not home.
The ship can dodge around the train instead of following a permanently safe band.

Native and browser encounters use four projectiles, with three horizontal speeds.
Fan shots spread while curving; weave shots oscillate; slalom shots make wider,
slower turns. The boss stays fixed after entering. Bombs clear bullets; browser
bombs also provide a short firing pause. Shooting Off disables boss attacks.

Tests check mouth origins, staggered launch times, stationary-player damage and
reachable routes at native ship speed. The route checks exclude flying directly
into the boss body. Native sector guardians retain their existing attacks;
browser guardians share these patterns.
