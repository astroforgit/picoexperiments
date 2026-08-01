# Heroes of Lowrez — Atari VBXE prototype

This is a native 6502/MADS port of the browser prototype in `../web`. It uses
the same deliberately small data model: a fixed 7×6 odd-row hex board, byte
arrays for terrain and units, four table-driven battles, and deterministic
enemy turns.

## Implemented

- flicker-free 320×200, 256-colour VBXE FX overlay using two 64 KB
  framebuffers and an XDL swap at vertical blank;
- the exact reduced grass tile and six-frame sprite sheet used by `../web`,
  converted to palette-indexed VBXE data at the web renderer's 28×46
  nearest-neighbour display size and embedded in the XEX;
- four battles and the web version's hero/enemy statistics;
- knight and archer heroes, minibeasts, skeleton warriors, skeleton archers,
  ogres, bats, imps, and the warlock;
- two-action hero turns: move one hex and then move, attack, or skip;
- direct two-hex movement consumes the complete turn;
- darker radius-one movement fields after the first step;
- tapered grass-textured hexes: 84% brightness for the initial range and a
  closely related 82% for final one-step choices;
- white bracket cursor on empty and occupied cells, changing to red only for a
  valid enemy target;
- original-style lower HUD with pixel `SKIP`/`FLAG` labels plus movement,
  sword-damage, heart, and HP indicators; hovering any unit shows that unit's
  statistics;
- melee and ranged attack validation (only archers/ranged units shoot);
- automatic hero order and deterministic enemy phase;
- warlock imp summoning in battle 4;
- active-hero pixel bounce and attack-target cursor;
- pixel-stepped movement animation for heroes and enemies, with enemy actions
  played sequentially;
- an eight-frame hit flash that makes melee and ranged attacks readable;
- VBXE detection at both `$D6xx` and `$D7xx`.

The complete frame is always assembled in the hidden buffer. A cached textured
background is restored with one blit, dynamic graphics are added, and the XDL
switches buffers at vertical blank. The displayed buffer is never changed while
VBXE scans it. Units and trees are transparent VBXE blits from the original web
sprite sheet; darker movement hexes, cursor, HP bars, and hit flashes are native
overlays. No PNG decoder or runtime asset files are required on the Atari.

## Build

Requirements: MADS 2.x as `mads`, plus Node.js for generated lookup tables.

```sh
./build.sh
```

This creates `heroes-vbxe.xex`, a listing, a label file, `battle-data.inc`,
`assets.bin`, and `asset-palette.inc`. Asset generation reads the original PNGs
directly using Node's built-in zlib support; it has no third-party dependency.

## Controls

- Joystick: move the hex cursor
- Fire: move or attack the selected cell
- Space: skip the active hero
- `1` / `2`: previous / next battle
- `R` or SELECT: restart the current battle

The program requires a compatible VBXE FX 1.2x core.
