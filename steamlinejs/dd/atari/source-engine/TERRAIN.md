# Original terrain queries: native 6502 component

`tools/build_source_terrain.py` relocates these routines from the assembled
supplied bank 5, together with their actual geometry tables:

| Query | Source entry | Native entry | Behavior |
|---|---|---|---|
| Ground-plane bounds | `$B000` | `$4000` | Piecewise depth limits, slopes, height-layer selection and source correction flags |
| Support surfaces | `$B3EC` | `$43EC` | Section/depth/page filtering and platform contact; height tolerance 0–7 pixels |
| Vertical wall faces | `$B6FD` | `$46FD` | Depth and rectangle tests, height limits, displacement to the indicated wall side |

The component occupies `$4000–$4860` (2,145 bytes). It contains no Atari/SNES
hardware accesses or unresolved service calls. Instructions keep their original
lengths and relative branches. Explicitly typed absolute operands and table
pointers are relocated; coordinates, masks, sentinel values and other data
remain untouched. Unexpected external code/data targets fail the build.

This is **not yet connected to `double-dragon-vbxe.xex`**. The component keeps
the original engine RAM ABI. It requires native engine memory ownership/OS
takeover; calling it directly while the existing adaptation's Atari OS is
active would corrupt OS scratch RAM. Its `$4000` placement also overlaps the
adaptation. Do not include it in the old executable as an independent patch.

## Calling contract

Use `JSR` to the entry with the following original RAM inputs. Addresses refer
to the original engine layout; these are not the adaptation's `px`/`py` values.
Decimal mode must be clear, as in the original engine. The native image must
remain page-aligned to preserve source page-crossing timing.

| Location | Meaning |
|---|---|
| `$3D`, `$3E` | Mission and section, using original valid campaign states |
| `$25/$26` | 16-bit world horizontal position |
| `$15` | Depth coordinate on the fighting plane |
| `$27/$28` | 16-bit height coordinate |
| `$49` | Current object slot, 0–7 |
| `$23/$24`, `$037A` | Original saved horizontal/depth values for rollback paths |
| `$5A,X`, `$62,X` | Current object's integer horizontal position |

A/X/Y and stack depth are preserved. Carry reports collision/contact. Other
flags and scratch locations follow the original routine, not a new API.
Bounds can correct `$15`, `$27/$28`, or the object's saved position depending
on source flags. Support corrects `$27/$28`; walls correct `$25/$26`.
Scratch `$16–$1A`, `$29–$2C`, `$2F` must be considered clobbered. These are
queries/corrections, not the complete movement or damage dispatcher.

The fourth mission's last section has RAM references in the support lookup;
these are deliberately preserved, not mistaken for ROM pointers. The complete
engine must provide the same state when making that query. Invalid mission or
section indices are outside the source calling contract.

## Verification

Run `bash build-source-engine.sh` from `atari/`. It builds `terrain.asm`,
`terrain.bin`, MADS's independently assembled `terrain-assembled.bin`, symbols,
and `terrain.json` with source/output hashes and every relocation.

`tools/test_source_terrain.py` executes the MADS output and original bank 5
with identical input states. It compares registers, flags, output/scratch RAM,
write addresses and cycle counts, normalizing only relocated scratch pointers
and return addresses. Memory guards fail on unexpected ROM/RAM accesses or
execution outside the component; bounded execution detects unterminated scans.

Coverage includes every campaign section and boundary endpoint, adjacent pixels,
both height layers, all eight object slots, exact street wall/platform fixtures,
wall rectangle edges and randomized support probes. A second RAM placement
checks that relocation is not accidentally specific to `$4000`. This verifies
component behavior; it is not an emulator/hardware playthrough or complete
terrain integration.
