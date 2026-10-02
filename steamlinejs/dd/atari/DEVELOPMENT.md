# Implementation notes

## Source conversion

`tools/make_assets.py` parses literal `.byte` data from the supplied assembly.
It validates byte values and bank sizes. The build has no network dependencies.
`generated/manifest.json` records hashes of every source bank used.

The 32 SNES CHR sets contain 256 8×8 tiles each. Each tile is 32 bytes, with
interleaved bitplanes 0/1 in bytes 0–15 and planes 2/3 in bytes 16–31. They
are decoded to linear palette indices for the VBXE blitter.

Main-game fighter poses are in PRG bank 3. An `$FE` record supplies a count
and pointers to attributes, tile indices and signed-X/foot-relative-Y pairs.
Subsequent short records supply a count, constant attribute and tile/coordinate
pointers; these are needed to complete the legs. Tile horizontal/vertical flip
bits are honored. Conditional weapon records are not used. Selected poses are
flattened into 64×56 transparent sprites and mirrored for both directions.
PRG bank 4 contains a different pose set and is used only by the optional audit.

Screen row pointers run bottom to top. This adaptation takes rows 5–29 and
32 tile columns from each source room. Four adjacent rooms are joined at their
native tile resolution into a 1024×200 map, with a 320-pixel camera viewport.
Background selections:

| Stage | PRG data bank | Screen table words | CHR set |
|---|---|---|---|
| Streets | 0 | 0, 2, 4, 6 | 16 |
| Industrial | 0 | 8, 10, 12, 14 | 18 |
| Caves | 0 | 18, 20, 22, 24 | 20 |
| Hideout | 1 | 6, 8, 10, 12 | 22 |

Original attribute palettes are replaced by a common Atari palette with four
colors per backdrop and separate fighter palettes. The ASCII message font is
Pillow's built-in bitmap font; pinning Pillow makes regeneration reproducible.
`python3 tools/make_assets.py --audit` generates additional source contact sheets.

## Memory

| Address | Contents |
|---|---|
| CPU `$9000`–`$90E3` | XEX INIT loader, VBXE detection and upload cursor |
| CPU `$3000`–below `$8000` | Runtime, state, palette, display list and HUD |
| CPU `$8000`–`$8FFF` | Reused XEX asset staging area |
| CPU `$B000`–`$BFFF` | CPU-only VBXE MEMAC window; BASIC disabled |
| VRAM `$00000`, `$10000` | Two 320×200 framebuffers |
| VRAM `$20000`–`$2FFFF` | Four 256-tile atlases, 16 KB each |
| VRAM `$30000`–`$61FFF` | Current stage's 1024×200 panorama cache |
| VRAM `$62000`–`$7DFFF` | 32 fighter sprites, 3,584 bytes each |
| VRAM `$7E000`–`$7EFBF` | ASCII 32–73, 42 8×12 glyphs |
| VRAM `$0FA00`–`$0FFFF` | ASCII 74–89, in framebuffer 0 padding |
| VRAM `$1FA00`–`$1FC3F` | ASCII 90–95, in framebuffer 1 padding |
| VRAM `$7F000` | Two XDLs |
| VRAM `$7F100` | Blitter command block |

The 97 4 KB asset segments each execute an INIT routine, copying through MEMAC.
Each segment explicitly selects its bank; the last two populate font fragments
outside the visible 64000-byte framebuffer area. The tests verify that rendering
does not overwrite those fragments.
The runtime then uses indirect VBXE register access, so D6/D7 detection does not
require patching hundreds of instruction operands. The OS VBI and ROM font
remain active; BASIC is disabled. The renderer waits for the previous blit before
rewriting its command block, draws into the hidden framebuffer and changes the
XDL pointer at VBL. This follows the neighboring Sven and Streamline ports.

`world.asm` rebuilds the panorama from a 128×25 CPU tile map when changing stages.
It issues 3,200 8×8 tile blits with destination pitch 1024. The first stage is
prebuilt by the asset generator for a fast initial load. Stage transitions retain
the previous framebuffer while building the new cache. Ordinary frames need
only one background blit, regardless of scroll position. The source address is
`$30000 + camera_x`, with source pitch 1024 and destination pitch 320.

Encounters lock the camera at X=0, 256 and 512. After the last group, the camera
can advance to its maximum X=704; Billy must then reach the right edge to move
to the next stage. Backtracking within the viewport is allowed, but the camera
does not move backward. Respawn retains the camera and current encounter;
restarting the campaign restores the street cache and camera X=0.

## Earlier adaptation and full-source follow-up

Game logic is newly written 6502 assembly. Porting the original engine further
requires relocating banked NES code and RAM, preserving mapper changes, replacing
PPU/APU accesses and translating its scrolling, collision and encounter scripts.
Those tasks are not hidden behind stubs in this implementation. The current
executable is a playable scrolling campaign, not evidence of original-game
feature parity.

The current requested target is a complete source-based conversion without
music. [SOURCE-PORT.md](SOURCE-PORT.md) tracks the new engine recovery and native
graphics work, its verification, and the hardware integration still required.

See [COMPATIBILITY.md](COMPATIBILITY.md) for the checked VBXE register contract,
loader handoff, and configuration tests.
