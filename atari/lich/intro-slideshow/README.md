# Dusiołek — illustrated intro subproject

A separate Atari XL/XE + VBXE slideshow. It does not modify or start the game.
Five generated illustrations accompany the supplied Polish poem. Text scrolls
upward through a 48-pixel strip below the current picture; the next illustration
appears after its text finishes. After scene five the presentation loops.

- `dusiolek-intro.xex`: standalone executable, requires VBXE with 512 KB VRAM.
- `index.html`: offline browser preview with the same converted pictures/text.
- `assets/scene-1.png` … `scene-5.png`: full-resolution illustrations.
- `assets/prompts.json`: exact generation prompts; generated using the built-in imagegen tool.
- `poem.txt`: editable text source. Verse groups are configured in `build_assets.py`.
- `assets/font.json`: extracted game font, including Polish characters.

## Controls

Atari: fire or Return skips to the next scene; Space or C pauses/resumes.
Browser: Enter/right arrow skips; Space pauses; R restarts; buttons also work.
The presentation is silent. PAL and NTSC scrolling speeds are approximately equal.

## Build and run

Requires Python 3, Pillow and MADS on PATH:

```sh
./build.sh
./run.sh
```

`run.sh` uses the parent repository's VBXE Altirra launcher. Outside that repository,
open `dusiolek-intro.xex` in a VBXE-enabled emulator instead. The browser preview
can be opened directly from disk without a server.

## Native format

Pictures are 256×160, sharing a 256-entry palette. Text uses the game's pixel
font at 2× size. The VBXE XDL displays an image followed by a scrolling raster;
only its text address changes each step, so there is no per-frame image copying.
Picture/text rasters occupy VRAM below `$7e000`; XDLs live at `$7e000`.
The executable streams 4 KB banks through `$a000` during loading, so the large
illustrations do not require expanded CPU RAM. Code starts at `$2000`.
`data/manifest.json` records scene offsets and text lengths.

The pictures illustrate the forest, stream, goblin, wizard's spell and dungeon;
they do not depict sexual assault. The supplied poem is retained, with whitespace
normalized and quotation marks adapted to the game's font.

Validation: `python3 test_intro.py` uses the parent game's headless VBXE emulator.
