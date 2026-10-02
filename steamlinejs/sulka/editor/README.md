# Sójka VBXE map editor

Open `index.html` in a browser. The editor is self-contained and starts with
the exact 24 maps and moving fly-spike paths currently embedded in
`../atari/sulka-vbxe.asm`.

The maps are the VBXE runtime maps: **24 columns × 14 rows**, with one editor
cell corresponding to one 10×10-pixel VBXE tile. These are intentionally not
the original GameMaker room dimensions described in the porting notes.

## Editing

- Select a tile in the palette, then click or drag on the map.
- Right-click and drag to erase.
- Platform spike brushes place and erase two adjacent spike cells, matching one
  complete spike section in the original game and the Atari collision map.
- `[` / `]` changes rooms; the displayed palette shortcuts select tools.
- Moving fly-spikes (`F`) expose their end coordinates in the inspector. Their
  start coordinates come directly from the `F` cell.
- Work is saved automatically in browser local storage.
- JSON export is the editable backup/interchange format. JSON and editor-made
  MADS assembly files can both be imported.

The editor keeps all 24 runtime slots because the game has hard-coded
progression behavior: slot 13 (`rKey0`) is skipped and slot 24 is the ending.
It also enforces the runtime limit of two moving fly-spikes per room.

## Put an export into the Atari build

Choose **Export for MADS** to download `sulka-levels.asm`. From the
`steamlinejs/sulka` directory, put the export at `sulka-levels.asm` and run:

```sh
./run-emulator.sh
```

The launcher validates and applies `sulka-levels.asm`, assembles the updated
game, synchronizes the editor's built-in map data, and starts it in Altirra.
After the command finishes, refreshing the editor loads that exported map set.
Internally, `apply-export.js` replaces only the block between `BEGIN/END SULKA
EDITOR LEVEL DATA`; the rest of the game remains untouched. If the export file
is absent, the launcher builds the levels already embedded in the Atari source.

To verify that the built-in editor data still matches the Atari source and
round-trips through both export formats:

```sh
node editor/verify-editor.js
```
