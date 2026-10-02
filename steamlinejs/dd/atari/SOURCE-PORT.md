# Full-source Atari/VBXE conversion — in progress

The target is the complete supplied Double Dragon game, with music omitted.
The existing `double-dragon-vbxe.xex` is still the earlier adaptation. The work
described here has **not yet produced a full-game Atari executable**.

## Implemented foundation

The detailed missing-feature checklist is [PARITY.md](PARITY.md).
The original ground-plane, platform-support and vertical-wall queries now have
a relocated native component at `$4000–$4860`, using the original geometry
tables. MADS output is compared against original bank-5 execution for boundary
and contact cases. See [source-engine/TERRAIN.md](source-engine/TERRAIN.md) for
the RAM contract and limitations. These queries are not yet called by the
playable adaptation; terrain integration, pose probes and the full collision
dispatcher remain pending.

`tools/build_source_engine.py` reassembles all eight 16 KB PRG banks, including
gameplay code in banks 2, 4, 5, 6 and 7. It preserves the original addresses,
checks the source page boundaries and bank lengths, and records input/output
hashes. In particular, it assembles the instructions mixed into banks 5 and 6;
concatenating only their `.byte` lines corrupts those banks. The E300 comment
in bank 7 follows a block crossing that boundary and is checked at E307.

SNES service calls become 33 explicit JSR interfaces. Other SNES instructions
remain identifiable in this intermediate image; it is not safe to execute it
directly on an Atari. No unimplemented interface is represented as a successful
native implementation.

`tools/source_machine.py` executes the recovered game code with py65's NMOS
6502 core and a reference platform model. It handles the identified SNES STZ
at ED65 explicitly. It retains original section setup, encounter records,
movement, scrolling calculations, character logic and sprite construction.
Music requests bypass the source audio sequencer; effect requests are recorded
but not synthesized. Bank 5 remains available because it also contains game
logic, not just sound.

The runner models the FC80/FF16 VBL wait and stack-unwind operation and the
three game NMI dispatch paths. It is not a cycle-accurate NES, SNES or Atari
emulator. Service execution costs, raster effects, sprite priority, the split
HUD and SNES-specific graphics caches are not accurately reproduced. Its
screenshots are development previews, not evidence of working Atari graphics.

`tools/pack_source_chr.py` includes **all 32 CHR sets**. Their original two
bitplanes occupy 131,072 bytes, packed losslessly into 110,106 bytes. This
includes character, scenery, title and later-game graphics, not selected poses.
`source-engine/unpack.asm` is a native 6502 bounds-checked packet decoder.
`source-engine/expand.asm` expands a decoded set into 256 linear 8×8 VBXE tiles.
Tests execute both routines on every source set, checking all 524,288 pixels.

## Build and check

With the dependencies in `requirements.txt` installed and MADS in PATH:

```sh
bash build-source-engine.sh
python3 tools/source_machine.py --start --frames 1500 \
  --screenshot generated/source-engine/reference-street.png \
  --trace generated/source-engine/reference-trace.json
```

The build runs the source and native graphics tests. The reference runner
presses Start on the menu and later holds right/punch; it is not a campaign
completion bot. Its `--start` option uses the original warm-reset flag to skip
the attract demonstration. Running without it starts the cold-entry sequence.

Checks cover source integrity, every campaign section's first encounter
initialization, signed position integration for all eight object slots, music
suppression, the VBL barrier, lossless graphics decoding and malformed packets.
The source's section-count table at E76F is `[2, 1, 4, 4]`: 11 campaign sections.
Initializing each section is not the same as completing it in a playthrough.

## Required before replacing the adaptation

1. Relocate the fixed engine bank and implement bank switching. Original code
   expects C000–FFFF, overlapping Atari hardware at D000–D7FF. The source also
   uses the Atari OS's zero page and RAM; the native runtime needs OS takeover
   and interrupt ownership. Absolute accesses, indirect accesses and computed
   jumps must all preserve the original engine's virtual addresses.
2. Implement the 33 native platform interfaces and translate the remaining
   SNES instructions. Connect Atari controls, VBL timing and POKEY effects;
   never invoke the source music sequencer.
3. Connect the verified CHR decoder/expander to VBXE memory, tile/attribute
   updates, palettes, scrolling, sprite priorities, clipping and the split HUD.
   Preserve original sprite construction rather than using the old pose set.
4. Produce a separate full-source XEX and verify it in Altirra. Exercise all
   sections, weapons, throws, climbing, hazards, progression, bosses, ending
   and original player modes. Compare against reference execution, then switch
   the normal launcher only when the native executable is ready.

The old adaptation's test bot does not establish full-source compatibility.
