# Zorro editor

A browser editor for `../Zorro (1985)(Datasoft)(US).xex`. It changes the
game data in place and saves a new XEX that runs on a real Atari or in
Altirra. All addresses come from the disassembly in `../decompiled`.

```
./run.sh            # starts serve.py and opens http://localhost:8765
```

With the server running, the editor loads the game by itself and has
**Run in Altirra**, which saves `zorro_edited.xex` here and starts it. Next
time, the editor opens `zorro_edited.xex`, so your work continues. Delete
that file to start again from the original. You can also open
`index.html` directly in a browser, open the XEX with **Open XEX** and use
**Save XEX** to download the result.

On [GitHub Pages](https://astroforgit.github.io/picoexperiments/atari/zorro/editor/),
the original XEX loads automatically. **Save XEX** downloads your edited game.
To continue later, use **Open XEX** on the downloaded file. Pages cannot save
edits on the server or start Altirra, so **Run in Altirra** is available only
with `serve.py` locally.

## What you can edit

| Tab | What it changes |
|---|---|
| Tiles | Paint the room's 40 × 22 map with its 8×8 tiles, edit tile pixels, and change the room's four colours |
| Objects | Start position, room and active flag of the 58 objects (for a new game) |
| Collision | The rectangles the game tests Zorro and the objects against: move, resize, or type exact values |
| Exits | Where each exit is and which room and position it leads to |
| Sprites | Pixels of the 107 sprites the game uses |

Undo and redo cover every change (Ctrl+Z, Ctrl+Y).

## Import Graph2Font images

Click **Import Graph2Font** after loading the game, or drop a `.g2f` or `.mch`
file on it. Native Graph2Font projects work directly, including `G2FZLIB`
compressed files. Mode-5 MCH files from
[bmp2mch](https://github.com/tebe6502/bmp2mch) still work too.
Convert BMP/PNG images with bmp2mch first, for example:

```
bmp2mch picture.png -fmch -c4
```

For MCH, choose the source width (32, 40 or 48 characters) and crop origin in
character columns/rows. Standard 240-line images have their width detected automatically.
The preview shows the resulting 40 × 22 character room (320 × 176 screen
pixels). Extra pixels are cropped, smaller images are padded with the source
background colour. Five-colour and per-scanline palettes are decoded, then
mapped to the four most frequent colours in the crop, or to the current room
palette when **Match current room colours** is checked.

Native G2F decoding uses bundled [RECOIL 7.0.0](https://recoil.sourceforge.net/),
locally in the browser, with no uploads or runtime CDN dependency. It renders
multiple character sets, inverse characters, per-line colours, supported GTIA
modes and player/missile overlays. The rendered viewport is 336 × 240 pixels;
crop column 1 selects the central 320 pixels. Wide-screen content outside that
viewport is not included. Hi-res pixels are sampled at every second horizontal
pixel to match Zorro. Sprites and colour effects become static room graphics.
Some GED raster programs, PGR and VBXE layouts are unsupported by RECOIL and
produce an error without changing the XEX. Files are limited to 1 MiB.
See `vendor/RECOIL-NOTICE.txt` for source/build details and the MIT license.

**Apply to room** replaces its map and used tile slots in one undoable change.
The dialog lists rooms sharing its map, tiles or palette. Collision rectangles,
objects and exits still need manual adjustment. Images that exceed the room's
tile count or packed map capacity cannot be applied; simplify their details or
use more repeated areas. Save the result with **Save XEX**.

Run the decoder and XEX integration checks with Node.js 18 or later:

```
node mch.test.cjs
node g2f.test.cjs
```

With Playwright installed and `serve.py` running, `node mch.browser.test.cjs`
checks the import dialog in Chromium. Set `EDITOR_URL` to use another port.

## Limits

The editor only changes bytes that already exist. It never moves data or
makes the file bigger, so:

- each room's map is packed again (run-length) after every stroke, and a
  stroke that would no longer fit in the room's space in the file is
  refused. The meter under the room shows how full the map is;
- sprites keep their size, rooms keep their number of rectangles and exits,
  and tile sets keep their number of tiles;
- several rooms share data: rooms 13-19 share two maps and one tile set,
  most town rooms share a palette, and some rectangle tables overlap. The
  editor says so where it matters, because changing one changes all of them.

Some objects (platforms, the soldier, money bags) are placed by the game
when a room loads, so moving their start position has no effect. The
meaning of each collision rectangle type is not fully known. Colours are an
approximation of the NTSC palette.
