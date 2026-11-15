# Kult and CETAS — recovered 6502 assembly

Two separate projects following the local Zorro and Agent USA examples:
MADS assembly, named entry points, retained data, regeneration tools and
byte-exact build checks. Original source names and high-level source code
cannot be recovered from these binaries. Semantic annotation is **partial**;
this is not yet as thoroughly explained as those two reference projects.

- [Kult](kult/README.md): packed executable and recovered runtime assembly.
- [CETAS](cetas/README.md): game, introduction, disk loader, boot code and
  all five decompressed resources.

The original `../Kult (v1).xex` and `../CETAS (WIP).ATR` are unchanged.

A [graphics editor for both games](../editor/README.md) is now available, with
sprite/character editing, PNG exchange and validated XEX/ATR exports.

## Build

Requires Python 3, `py65`, and MADS (tested here with the installed assembler).
Pillow is required only for previews.

```sh
./build.sh             # assemble sources, replay decompressors, verify all bytes
./build.sh regen       # overwrite generated assembly from the original inputs
python3 tools/render.py
```

Set `MADS=/path/to/mads` if necessary. Edit `tools/symbols.py` for persistent
names/comments; edit assembly directly for experiments, without `regen`.
Build verification intentionally fails after changing game bytes. MADS outputs
already produced remain available, but the disk packaging step requires the
reference sizes and hashes. There is no general-purpose recompressor here.

## What was verified

- Kult's 35,097-byte packed XEX rebuilds exactly.
- Its 39,554 recovered runtime bytes assemble exactly and agree with replay
  of the original 6502 depacker. Hardware writes are excluded from this image.
- CETAS's game and introduction assemble back to their exact executable files.
- All eight DOS files, all three boot sectors and the entire 92,176-byte ATR
  rebuild exactly, including sector-chain trailers, padding and unused space.
- All five compressed CETAS resources are fully consumed by the original
  decoder, with sequential output and checked backreferences. Replaying their
  rebuilt compressed files reproduces the assembled unpacked resources.

`analysis.json` records hashes, loaded spans, entry points, coverage, disk file
chains and unresolved jumps. `verification.json` records the successful checks.
Decoded instruction counts measure conservative tracing, not how much of each
game has been understood. Unknown bytes remain `dta`, rather than guessed code.
Self-modifying calls and unvisited paths require further work.

**No full Atari gameplay/emulator test was run.** CPU loader replay is not a
simulation of the video/audio hardware or a gameplay test. The images are asset
previews, not screenshots. Neutral diagnostic colours do not reproduce the
original Atari palette.

## Tools and provenance

`archive.py`, `opcodes.py` and `atr.py` reuse the existing local
`atari/collection/tools` implementations. `source.py` follows the recursive
control-flow approach used in the Zorro project, adding scoped names from
`symbols.py`. `recover.py` executes the supplied decoders using py65;
`generate.py` extracts and emits source; `build.py` assembles and verifies it.

Packed/archive sources and recovered sources are distinct views. In particular,
editing Kult's recovered `kult.asm` does **not** recompress it into `packed.asm`.
The build verifies that both views agree for the unmodified reference. CETAS's
`cetas.asm` and `intro.asm` directly supply the executable payloads in its rebuilt
disk; its packed resources have separate unpacked views.
