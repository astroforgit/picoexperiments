# Babajaga — Atari game sketch

**Babajaga** is a native Atari graphics prototype built on the recovered
`CETAS (WIP).ATR` engine. The player is a young adult witch flying right on a
broomstick, with a pointed hat, flowing hair/cape, boots and spell projectiles.

## Play

From your WSL command line, run:

```sh
/home/marcin/tmp/pico/atari/babajaga/run-emulator.sh
```

This starts the installed Windows Altirra with `babajaga.atr`, using the
shared emulator discovery helper and a separate standard-Atari INI file.
It uses `/disk` (ATR boot), an 800XL with 64 KB and PAL, and disables BASIC
and expansion devices. Your normal VBXE configuration is untouched. It runs
the current built disk; use `./build.sh` first after changing artwork.

Mount **babajaga.atr** as drive D1 in an Atari XL/XE emulator or an Atari disk
loading device and boot it. Use joystick port 1 to move; Fire starts/fires.
If the emulator offers a BASIC switch, disable BASIC when booting. The
original CETAS introduction/loading sequence remains: press Fire to advance
where requested. Babajaga's new title appears at the title-picture stage.

This is a disk game, not a standalone XEX. It depends on the resident loader
and staged graphics loads. Keep the ATR intact.

## What changed

- All ten distinct player sprite records: eight flight/alignment variants
  and two hit/death poses. All original pointer choices now use witch art.
- All four player-projectile position variants now show a small spell spark.
- Resource D is a new BABAJAGA title with moon, forest and broomstick artwork.
- Resource F is a matching "FLY AGAIN" end-screen image.

The sprites retain the original packed two-bit format, bottom-up row order,
record sizes and collision headers. Animation selection, joystick movement,
shooting, collisions, enemy script, music, loading and executable code are
unchanged. The original enemy designs and introduction/credits remain: this
is the requested player/theme sketch, not a complete fantasy conversion.
The old fish-sized collision rectangles are retained, including transparent
space around the new silhouette.

PNG previews use an illustrative purple/gold palette. Actual Atari colours
come from the unchanged CETAS display routines and can differ. Pixel aspect
is wide on Atari; `witch.png` and `title.png` show that proportion.

## Files

- `babajaga.atr`: 92,176-byte bootable-format Atari disk image.
- `build.py`: editable native pixel-art generator and validated disk builder.
- `babajaga-editor.json`: player/spell/title edits for the existing pixel
  workshop. Choose CETAS, then Open project. This project intentionally omits
  F, which the current editor does not expose; the full build adds it.
- `witch.png`, `sprites.png`, `title.png`: artwork previews.
- `manifest.json`: output/input hashes, modified files and player record list.
- `test_build.py`: disk, original-loader, CPU and editor-project checks.

## Rebuild

From this directory:

```sh
./build.sh
```

Requires Python 3, Pillow and py65, plus the sibling `../kult` recovery/editor
sources and original CETAS ATR. The build never changes that original disk.
It regenerates E, D and F, preserving all other files and the boot sectors;
sector allocation and every extracted file are validated by the exporter.

## Validation and limits

Checks exercise all player animation/position selections, compare movement and
firing against the original 6502 handler, verify unchanged sprite headers and
non-graphics bytes, load both replacement pictures through the original AUTO
loader, and validate the editor project. Disk-sector chains and file contents
are verified after export. Altirra 4.40 disk boot through the introduction has now been verified;
`verification/boot.png` and `verification/boot.log` record that check. A full
gameplay playthrough and real-hardware testing have not been performed.

## Separate standard-Atari configuration

The launcher now uses a private portable configuration, `altirra-standard.ini`,
created once from `altirra-standard-defaults.ini`. It does **not** load or write
the Windows registry settings used by your VBXE games. Changes made in this
separate emulator window are saved to this file on normal exit. The normal
VBXE runners continue using their existing settings.

Standard defaults: 800XL, 64 KB, PAL, 6502 at 1x, one POKEY, 100% hardware frame
rate, turbo off, BASIC off, no expansion devices/VBXE, 80 ms audio latency plus
100 ms extra buffer. Disk/serial sound effects are off; game music is enabled.
Arrow keys move and **left Ctrl is Fire**, with gamepad and numpad mappings
also enabled. The launcher always enforces standard hardware/PAL and removes
expansion devices in this private configuration.

The same runner can boot other standard Atari images:

```sh
./run-emulator.sh /path/to/game.atr
./run-emulator.sh /path/to/game.xex
```

ATR uses `/disk`; XEX uses `/run`. With no filename it runs Babajaga.
To inspect arguments without launching, append `-PrintCommand`.

### Music diagnosis

The earlier temporary-profile launcher inherited the VBXE profile: temporary
meant “do not save changes”, **not** “start with independent settings”. The
saved configuration had VBXE enabled and 20 ms audio latency plus 20 ms extra
buffer. Speed was already 100%, turbo was off, and CPU clock was 1x. Thus there
was no evidence of a saved speed multiplier error. Low buffers are a plausible
cause of audio breakup under scheduling/load, not a confirmed listening result.

The separate profile removes that dependency and uses more tolerant buffering.
`verification/timing.json` records a timed PAL run, excluding startup from its
steady interval. `verification/music-integrity.json` confirms that Babajaga's
introduction executable and game music code/tables/data match CETAS exactly.
Music playback quality at the physical speakers still needs a listening check;
these checks do not prove the audible symptom has disappeared.
