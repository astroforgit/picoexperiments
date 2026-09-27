# SPEEDmaza (2014, Jakub Husák) — decompiled

`../SPEEDmaza (2014)(Husak, Jakub)(PL)(en)[a].xex` is an Atari XL/XE game
written in **Action!**. It was compiled, then compressed together with its
data into a self-extracting XEX. This folder holds the unpacked program, a
disassembly that rebuilds it byte for byte, and a reconstructed Action!
source.

## The game

The logo says SPEED MAZA; the credits are "GAME/CODE/GFX/MSX: HUSAK". The maze
is always the same, generated from a fixed path of 267 steps. The camera moves
through it on its own and keeps getting faster. Press **fire or SPACE** to
turn into the next direction of the path. Touching a wall ends in a shaking
crash screen. Reaching the exit shows "MAZA PASSED!". The score is the time
survived; the best score is shown on the title screen. ESC returns to the
title screen.

Technically, the game uses:

- a 128×128-byte ANTIC mode 8 map at `$5C00`, scrolled with LMS, HSCROL and VSCROL;
- a status line taken from the top of the title picture;
- players 1 and 2 as speed and progress bars, with text drawn into them;
- player 0 as the animated "car";
- missiles as the maze's side borders;
- a DLI for the colour bars, with the maze colour pulsing to the music;
- RMT music, played by the standard RMT player at `$4C00`.

## Files

| File | What it is |
|---|---|
| `speedmaza.act` | Reconstructed Action! source, one PROC per compiled PROC |
| `speedmaza.asm` | MADS disassembly with named PROCs, variables and hardware registers |
| `speedmaza.xex` | Rebuilt, uncompressed executable (output of `build.sh`) |
| `speedmaza.lst` | MADS listing: address and bytes for every source line |
| `unpacked.bin` | 64 KB RAM image right after the original depacker finished |
| `data/*.bin` | Binary parts included by the `.asm` (pictures, music, Action! runtime) |
| `tools/unpack.py` | Runs the original depacker in a 6502 emulator (py65) |
| `tools/disasm.py` | Generates `speedmaza.asm` and `data/` from `unpacked.bin` |
| `tools/verify.py` | Checks the rebuilt XEX against `unpacked.bin` |
| `build.sh` | `./build.sh` assembles and verifies; `./build.sh regen` redoes everything |

## How the original file works

1. It loads one block of 14 213 bytes at `$2000`, plus an INIT stub at `$5800`.
   The stub clears `CH`, turns the screen off and jumps to `$2000`.
2. The depacker at `$2000` disables the OS ROM (`PORTB=$FE`) and copies itself
   to zero page and the stack page. It then unpacks `$0FFE-$BBFF`, which
   takes about 1.35 million instructions.
3. It sets `PORTB=$FF` and `NMIEN=$40`, executes `CLI`, then `JMP $433B`,
   which is the Action! `Main` PROC.

The rebuilt `speedmaza.xex` loads the same bytes directly. It adds one INIT
segment that switches BASIC off, so `$A000-$BBFF` is RAM. It then runs a
small stub at `$0680` that repeats the steps above.

## Memory map (after unpacking)

| Address | Contents |
|---|---|
| `$0FFE-$1FFF` | Title picture (mode E), "MAZA PASSED!" banner, digit font at `$1F28` |
| `$2000-$283F` | Crash picture (44 lines × 48 bytes) |
| `$2840-$2AC2` | Action! globals: display lists, labels, the maze path, sprite shapes, variables |
| `$2AC3-$4365` | Action! code: 29 PROCs; each PROC's locals sit just before it |
| `$4366-$4BFF` | RMT player variables and tables |
| `$4C00-$4FFF` | RMT player code (`JMP` table: init, play, p3, silence, setpokey) |
| `$5000-$56FF` | RMT module: title music |
| `$5700-$5BA6` | RMT module: game music; win and crash start at song lines `$25` and `$28` |
| `$5BA7` | `CARD ARRAY dirs` of `BuildMaze` (run time) |
| `$5C00-$9BFF` | Maze bitmap (built at run time) |
| `$9C00-$9FFF` | Game display list plus player/missile graphics, `PMBASE=$9C` (run time) |
| `$A000-$BBFF` | Copy of the Action! cartridge. The game uses only its runtime routines: `DIV $A090`, `MOD $A0DE`, `RSH $A0E6`, parameter copy `$A0F5`, `MoveBlock $A7B3`, `LSH $B5C0` |

## About the Action! reconstruction

Action! compiles each statement to a fixed code pattern with no
optimisation, so reading the source back is mechanical. For example:

- `IF a<b THEN` compiles to `LDA a / CMP b / BCC +3 / JMP else`.
- A `WHILE` has its test at the top.
- A `DO … UNTIL` has its test at the end.
- A `FOR` loop compares against the limit first.
- A function result is returned in `$A0`.
- A PROC with more than three bytes of parameters calls `$A0F5`, followed by
  the address and size of its locals.
- A PROC name used as a value (`vdslst=DliGame`) reads the operand of the
  `JMP` at the start of that PROC.

The statements, constants, evaluation order and variable layout in
`speedmaza.act` follow the machine code. The names and comments are mine.
Where the binary shows something unusual, it's kept and commented:

- `CallAddr`, `PlayGame`, `TitleScreen` and `Main` have no trailing `RETURN`.
- `dir=0 frame=0` is compiled as a single 16-bit store.
- `InitGameDL` writes the JVB address to the wrong place. This is harmless,
  because the OS reloads the display list pointer every frame.

**Limits:**

- `speedmaza.act` has **not been compiled**, because no Action! compiler was
  available. It was checked by reading it against the disassembly.
- `speedmaza.asm` is what has been verified: it reassembles to exactly the
  unpacked bytes. `tools/verify.py` checks every loaded byte. The only range
  left out, `$5BA7-$9FFF`, is all zeros in the original, and the game builds
  it at run time.
- The rebuilt XEX runs the same as the original in Altirra 4.40: same title
  screen, and the game starts after SPACE.
- The picture, font and music data are kept as binary files; they were not
  converted to source.
