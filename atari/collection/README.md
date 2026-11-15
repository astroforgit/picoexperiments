# Homesoft Atari 8-bit collection — MADS disassembly workspace

The archive contains **4,910 selectable game entries on 502 disks**, plus
33 supporting files grouped with six games and one unlisted supplemental file.
Each selectable game has its own title-based folder under `games/`. Names come
from the archive's `GAMES.TXT`, matched to DOS files through the original disk
menu's start-sector pointers. Duplicate titles have disk/slot suffixes, so no
versions overwrite each other. `catalogue.csv` is the searchable index;
`manifest.json` records titles, origins, sizes and SHA-256 hashes.

## Individually reconstructed games

**River Raid** is now unpacked, annotated and gameplay-tested. See
[`games/river-raid/README.md`](games/river-raid/README.md) and its
`decompiled/river-raid.asm`. Its full 8 KB image rebuilds exactly; PAL and NTSC
checks cover movement, firing, scoring, fuel, collisions and restart. The packed
rebuild also matches the original executable and recorded emulator outputs.

**Boulder Dash** and **Donkey Kong** now also have unpacked MADS projects,
partial semantic annotation, byte-exact rebuilds and PAL/NTSC emulator tests.
See their `games/<name>/decompiled/README.md` files. Donkey Kong includes the
separate loading screen and the release-specific runtime patch found by testing.

**Draconus, Zybex, Bruce Lee and Red Max** also have individually reconstructed MADS projects, uncompressed executables and byte-exact packed rebuilds. Each was smoke-tested for 3,600 frames per variant in PAL and NTSC. Source annotation remains partial. Red Max includes eight recovered compressed streams and its original uncompressed entry image. See each game’s `decompiled/README.md`.

**Dropzone, International Karate and Ballblazer** now also have individually reconstructed MADS projects and PAL/NTSC smoke tests, developed in parallel. Packed builds match the originals exactly. Uncompressed loading can change random/gameplay timing; each project documents the comparisons actually passed. Annotation remains partial.

**Archon, Pac-Man and Pole Position** have also been individually reconstructed and smoke-tested in PAL and NTSC. Archon and Pac-Man preserve release-specific runtime helpers outside the compressed images. Uncompressed gameplay checkpoint images match the originals in both standards; coverage remains limited to the scripted tests documented by each project.

**Montezuma’s Revenge, River Rescue, Pitfall, Pitfall II, Frogger, Q-Bert, Choplifter, Robotron 2084, Zaxxon, Star Raiders, and two Rescue on Fractalus releases** also have individual reconstruction notes and targeted PAL/NTSC checks. Star Raiders records the original-matched START/reset display diagnostics explicitly. **The Goonies** is reconstructed as a disk-dependent project: its executable, ten support files and complete ATR rebuild exactly, and mounted-disk tests match the original. These are partial annotations and scoped gameplay tests.

## Collection-wide deeper recovery

`progress.csv`, `progress.json` and `PROGRESS.txt` are the current per-game index.
Recognized compressed stages are recovered into
`games/<name>/decompiled/recovered-stages/`. These contain actual unpacked memory,
not just a listing of compressed bytes. Each stage assembles exactly with MADS;
`build.sh` also reconstructs and checks the original packed executable. Runtime
instruction traces supplement static control-flow decoding where available.

These automatic projects are **not fully annotated games**. Unreached code and
data remain DTA, indirect/overlay paths can be incomplete, and semantic names
need manual work. Some projects contain only a subset of the game’s load stages;
nested compression may still remain. Unverified candidates were moved to
`needs-loader-context/` and excluded from builds and source counts.
Generic PAL emulator comparisons are tracked separately from
the individual gameplay smoke tests. Matching an original that errors or barely
changes its screen is flagged for review, not called successful gameplay.

The statistics and static-analysis description below refer to the original
archive listings (`decompiled/game.asm`). `tools/extract.py` preserves curated
projects marked `decompiled/reconstruction.json`. Their dedicated build scripts
assemble the recovered source. Automatic projects additionally build their
recovered stages when invoked through `decompiled/build.sh`.

Runtime-backed original-file listings are also available as `runtime-archive.asm`
for eligible projects. They identify observed instructions only when their bytes
match a unique location in the original file, and rebuild that file exactly.
They do not represent decompression; progress records them separately.

Verified shared-runtime relocation views are available in `decompiled/relocated-runtime/`
for supported RAM-under-ROM loaders. These place original file bytes at their
runtime addresses and include independent copy replay, MADS builds and runtime
instruction evidence. They are counted separately from unpacked gameplay;
recovering a shared runtime does not mean its game-specific program is understood.

## Verified results

All **4,910 MADS builds match their extracted originals byte for byte**.
All **4,944 DOS files** and **502 retained disk images** were compared against
the supplied archive. `verification.json` records the complete results.
These checks do not imply that the packed gameplay code has been recovered.

## Build a game

```sh
cd games/zorro/decompiled
./build.sh
```

The script assembles `game.asm` using MADS, writes `game.xex` and `game.lst`, and
compares every byte with `../original.xex`. Set `MADS=/path/to/mads` if needed.
A deliberately modified game will fail that comparison; its assembled output
still exists for testing. The checked-in/generated source has no dependency on
the original binary: all payload bytes appear as instructions or `dta` lines.
The original load addresses and header lengths are fixed. Same-size patches
preserve that layout; structural changes require updating addresses, branches,
and segment lengths yourself.

## What has and has not been recovered

The original `game.asm` files are **automated static disassemblies**, not recovered
original sources or hand-annotated gameplay engines. The folder/build structure follows the Agent
USA and Zorro examples, but their semantic analysis is not reproduced here.
Many Homesoft executables contain compressed games and loader/decompressor code.
This pass follows documented 6502 instructions from INIT/RUN vectors in each
load stage; it does not execute the decompressors or recover runtime memory.
Unidentified code and data remain explicit `dta` bytes. Generated labels identify
segment and CPU address; they do not invent routine or variable meanings.

The static pass identifies 6,282,698 instruction bytes out of 88,869,640
executable-file bytes (7.07%). This proportion describes the initial static
archive listings; see progress.json for subsequent unpacked and runtime recovery.

Every game's `decompiled/analysis.json` reports code coverage, load segments,
entry points and unresolved indirect transfers. Static paths can include data
when routines use inline parameters or change return addresses. Undocumented
opcodes, relocated code, banked memory, self-modification, dynamically installed
interrupts and jump tables require further per-game work. Byte identity proves
that the source preserves the executable, **not** that all gameplay code has been
identified or understood. Emulator validation of later recovery work is recorded
separately in the per-game evidence and collection progress.

For an Agent/Zorro-level reconstruction, the remaining work per title is to run
its loader in an Atari emulator, capture/decompress the appropriate memory banks,
trace the actual game and interrupts, identify code/data boundaries, and annotate
routines, variables and graphics. Keep that runtime view separate from the packed
file view, or implement the original compressor to preserve exact rebuilding.

## Disk-dependent games

The unmodified ATR images are retained in `disks/`. Games with auxiliary files
keep those files under their own `supporting/` directory with their original DOS
names. Some loaders read fixed disk sectors; launch such games from the original
ATR menu. Copying the extracted XEX alone does not necessarily make them standalone.
The unlisted `ATABLAST.DAT` on disk 428 is retained in `supplemental/disk-428/`;
it is not silently assigned to an unrelated game.

The archive remains untouched. The one trailing byte in `HIVMANIA.COM` is
preserved and reported rather than discarded.

## Tools and reproducibility

Requires Python 3 and MADS. The basic archive listing needs no extra Python
packages; deeper recovery tools use the dependencies in `requirements.txt`.

```sh
# Regenerate everything from the archive (overwrites generated sources):
python3 tools/extract.py

# Build a downloaded source bundle without separate archive/disk inputs:
python3 tools/verify_all.py --jobs 4 --sources-only

# Assemble and byte-compare every game, and recheck every extracted file:
python3 tools/verify_all.py --jobs 4

# Regenerate only one source (overwrites manual edits):
cd games/zorro/decompiled
./build.sh regen
```

`verification.json` records the individual rebuild results and disk extraction
checks. The verifier checks the archive hash, every retained disk image, all
extracted DOS files and every rebuilt game. The DOS reader checks sector-chain
lengths, file IDs, bounds and cycles. The generator preserves segment order and
repeated writes, keeping identical CPU addresses in different segments distinct.

`tools/opcodes.py` is reused from the local Zorro project. `tools/atr.py` implements
the sector layout documented in [OSS OS/A+](https://atariwiki.org/wiki/attach/OSS%20A%2B%202/OS_A_Plus_June_83_rev.pdf).
The Homesoft menu mapping was inspected directly in the supplied boot/menu bytes.
