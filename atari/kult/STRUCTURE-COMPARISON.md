# Kult and CETAS: structure and mechanics

This comparison concerns the supplied `Kult (v1).xex` and `CETAS (WIP).ATR`.
Findings come from recovered 6502 code and data, with isolated CPU execution
for decoding and sprite expansion. They do not establish that the WIP game
has every intended feature, or replace a full gameplay playthrough.
Addresses below refer to recovered game memory, not offsets in the files.

## Shared approach

Both are Atari 6502 action/shooting programs with software-drawn four-colour
sprites, direct display/interrupt control, and music code. Both keep object
properties in parallel arrays, use pointer tables to select graphics, and
modify instruction operands at runtime. Both account for horizontal pixel
alignment when drawing packed two-bit pixels. These are common techniques;
the inspected code does not establish that they share an engine.

## Main differences

| Area | Kult | CETAS |
|---|---|---|
| Packaging | One XEX with two outer RLE streams and separately compressed map data | A disk with resident loader AUTO, introduction XAUTORUN, game E and separate graphics resources A–F |
| Runtime organization | Substantial code under the Atari ROM area; tightly connected scrolling, wave and sprite routines | Central scheduler dispatching object types to separate handlers, plus a spawn script interpreter |
| Enemy content | 32 enemy designs, each with four 8×16 logical-pixel source frames; a separate four-frame effect set | Variable-sized sprite records shared by object types; 44 unique graphics records across the inspected sprite tables |
| Alignment | Enemy frames expand into four shifted drawing copies at runtime | Sprite pointers select stored horizontal-position variants; repeated pointers mean some types reuse the same image |
| Progression | Eight stage wave tables, each holding 48 fixed-size records | Bytecode-like spawn stream with delays, control operations and custom calls |
| Object capacity | Eight enemy slots and a separate six-slot projectile area | Scheduler visits 17 slots, with slot zero assigned to the player |
| Movement | Formation and motion tables, including sine-based coordinate generation | Type-specific update routines; player moves in steps of two X units and four Y units |
| Collision | Player collision includes a test of saved background pixel bytes | Projectile/object collision uses header-defined rectangular bounds |
| Background rendering | Scrolling buffers with 64-byte stride, tile drawing, fine scrolling and buffer switching | Sprite renderer advances upward through screen memory at a 48-byte row stride |

An object type is a behaviour/state ID, not necessarily a different enemy.
CETAS includes projectile and effect/state handlers in the same system.
Consequently the editor labels its gallery **Object type 02–18**, without
inventing enemy names. Kult gallery labels **Enemy 01–32** correspond to
zero-based design IDs 0–31; **Effect set 33** corresponds to ID 32.

## Kult evidence

- `$F16B/$F16D` selects `$4F80 + design * 128` and expands four consecutive
  32-byte frames through `$F0C4`. The source bank occupies `$4F80–$5FFF`,
  including the extra effect set. Each source row has two bytes. Expansion
  appends a blank byte and generates three further copies shifted by two,
  four and six bits. Runtime slot pointers are at `$EF31`.
- `$4400–$49FF` contains eight groups of 48 four-byte wave records. All design
  IDs 0–31 occur here. `$FB5F` selects a stage using a 192-byte stride;
  `$FBBA` reads the current wave. Fields select design, motion, formation,
  and a delay/state value. The formation selection indexes eight-byte entries
  at `$4A00`; motion selection indexes entries at `$7310`.
- `$E7A4` processes eight enemy coordinates, using the lookup at `$7164` and
  phase parameters around `$7410`. This supports curved/periodic movement;
  it is not a claim that every movement path uses the same formula.
- Enemy state is around `$74E0`, projectile state around `$74E8`; player
  position is stored at `$E957/$E958`. `$F22F` handles firing, and weapon
  configuration bytes include `$F24D/$F24E`. `$F980` participates in pickup
  detection. Exact player-facing pickup and weapon names remain unassigned.
- `$F940` tests saved background pixels across 16 rows for player collision;
  the subsequent path updates player/life state. This differs from testing
  only a pair of rectangular object bounds. Other collision paths also exist.
- Buffers at `$8000/$A000`, switching at `$E937` and display-list interrupt
  work at `$EA73` support the scrolling display. `$FD84` draws larger composed
  graphics using the tile bank at `$DAC0`.
- The map decoder at `$0300` accepts eight packed streams selected through
  `$C217`; each produces 2,048 bytes at `$1C00–$23FF`. This is a second layer
  of compression inside the already unpacked XEX.

## CETAS evidence

- Main loop `$235D` invokes object update `$237C` and spawn interpreter `$ABE1`.
  The scheduler scans slots 0–16, with property arrays starting around `$0C00`.
  Handler selection uses the table at `$2DF5` and patches the call at `$23B7`.
- `$24FB` handles player input/movement. `$2EB5` allocates the player projectile
  in slot 1 when available, using type 6. States/types 7 and 8 also occur in
  expiration/effect processing; they should not be counted as enemy species.
- The spawn stream starts at `$AA04`, with cursor in `$AF/$B0`. The interpreter
  handles delays and special bytes including `$FF`, `$FE`, `$FD`, and `$FA`;
  the last can dispatch a custom call. It is more flexible than Kult's fixed
  four-byte wave record, though the two systems serve similar spawning roles.
- `$2C06` reads seven-byte sprite headers: horizontal drawing offset, byte
  width, height, then collision X offset, Y offset, width and height.
  `$2D3F` draws rows upward, explaining the editor's bottom-up storage handling.
- `$2E1B` tests rectangular overlap using the collision offsets and dimensions.
  The projectile path scans slots 8–16 and excludes particular states.
  Sprite artwork can therefore change without automatically changing its
  collision rectangle; the graphics editor preserves these headers.
- `$2C4A–$2C75` contains player-related sprite pointers; the table beginning
  `$2D67` provides four position variants per object type. Shared pointers are
  deduplicated in the editor, so editing one record affects all its users.
- A–D decode to 7,680-byte pictures; F decodes to 6,480 bytes and is copied
  under ROM. These staged disk resources differ from Kult's single-file
  outer decompression. Music occupies separate ranges from core game logic.

## What the editor changes

Kult enemy edits affect the source frames, so the original game generates
matching shifted copies automatically. CETAS edits affect individual stored
sprite variants; other variants may need matching edits. Neither editor
currently edits wave records, spawn scripts, movement routines, collision
headers or game rules. Preview colours and animation rate are illustrative;
they do not emulate the games' interrupt-driven display or timing.
