# Streamline VBXE

This directory contains an Atari XL/XE + VBXE port of **Streamline**, based on
the rules and level data recovered from `../orggame/orggame.js`.

The port is a self-contained MADS assembly program. It uses:

- a 320×200, 256-colour VBXE overlay framebuffer;
- an XDL pointing at a linear framebuffer in VBXE VRAM;
- the VBXE blitter for the board, tiles, lines, and heads;
- a transparent overlay background with an ANTIC text underlay;
- no external graphics or sound assets.

## Implemented original rules

- full sliding movement;
- solid line/body collision across all players;
- reverse-direction undo;
- explicit global undo;
- END, PAUSE, RESET, and TRAP behavior from the full original;
- paired portals;
- directional forcers;
- keys and globally unlocked locks;
- two independent lines, active-line switching, and an all-lines-on-END win;
- all 56 original levels: Basics, Force, Trials, Dual, and Scale.

The original editor, analytics, menus, and procedural infinite mode are outside
the cartridge-style port. The complete authored puzzle campaign is included.

## Build

Requirements:

- MADS 2.x available as `mads`;
- Node.js, used only to regenerate and verify the level include.

Run:

```sh
./build.sh
```

This produces:

- `streamline-vbxe.xex` — executable for Atari XL/XE with VBXE;
- `streamline-vbxe.lst` — MADS listing;
- `streamline-vbxe.lab` — symbol table;
- `levels.inc` — generated packed level data.

The executable detects an FX core at either the `$D6xx` or `$D7xx` register
page. Without a compatible VBXE FX core, it displays `VBXE REQUIRED`.

## Controls

| Action | Joystick/console | Keyboard |
|---|---|---|
| Move | Joystick 0 | `W`, `A`, `S`, `D` |
| Switch active line | Fire | Space |
| Undo | OPTION | `U` or `Z` |
| Restart level | SELECT | `R` |

Moving directly backward into the previous line segment also undoes, matching
the original game.

## Emulator setup

Enable an Atari XL/XE configuration with a VBXE FX 1.2x core, load
`streamline-vbxe.xex`, and use joystick port 0. Both common VBXE register-page
locations are detected at runtime.
