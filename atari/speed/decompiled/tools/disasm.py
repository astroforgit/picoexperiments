#!/usr/bin/env python3
"""Generate a rebuildable MADS source (speedmaza.asm) from the unpacked image.

Usage: python3 disasm.py IMAGE.bin OUTDIR
Writes OUTDIR/speedmaza.asm and OUTDIR/data/*.bin (binary blobs it includes).

Code is found by recursive descent from the Action! procedure headers and the
RMT player jump table. Action! quirks handled:
  * JSR $A0F5 (parameter copy) is followed by 3 inline bytes: .word dest, .byte n-1
  * a PROC starts with "JMP *+3"; its local variables sit just before it
  * a PROC name used as a value (e.g. VDSLST=DliGame) reads PROC+1 (JMP operand)
"""
import os
import sys

# ---------------------------------------------------------------- opcodes
OPS = {}
for line in """
ADC imm 69 zp 65 zpx 75 abs 6D abx 7D aby 79 izx 61 izy 71
AND imm 29 zp 25 zpx 35 abs 2D abx 3D aby 39 izx 21 izy 31
ASL acc 0A zp 06 zpx 16 abs 0E abx 1E
BCC rel 90
BCS rel B0
BEQ rel F0
BIT zp 24 abs 2C
BMI rel 30
BNE rel D0
BPL rel 10
BRK imp 00
BVC rel 50
BVS rel 70
CLC imp 18
CLD imp D8
CLI imp 58
CLV imp B8
CMP imm C9 zp C5 zpx D5 abs CD abx DD aby D9 izx C1 izy D1
CPX imm E0 zp E4 abs EC
CPY imm C0 zp C4 abs CC
DEC zp C6 zpx D6 abs CE abx DE
DEX imp CA
DEY imp 88
EOR imm 49 zp 45 zpx 55 abs 4D abx 5D aby 59 izx 41 izy 51
INC zp E6 zpx F6 abs EE abx FE
INX imp E8
INY imp C8
JMP abs 4C ind 6C
JSR abs 20
LDA imm A9 zp A5 zpx B5 abs AD abx BD aby B9 izx A1 izy B1
LDX imm A2 zp A6 zpy B6 abs AE aby BE
LDY imm A0 zp A4 zpx B4 abs AC abx BC
LSR acc 4A zp 46 zpx 56 abs 4E abx 5E
NOP imp EA
ORA imm 09 zp 05 zpx 15 abs 0D abx 1D aby 19 izx 01 izy 11
PHA imp 48
PHP imp 08
PLA imp 68
PLP imp 28
ROL acc 2A zp 26 zpx 36 abs 2E abx 3E
ROR acc 6A zp 66 zpx 76 abs 6E abx 7E
RTI imp 40
RTS imp 60
SBC imm E9 zp E5 zpx F5 abs ED abx FD aby F9 izx E1 izy F1
SEC imp 38
SED imp F8
SEI imp 78
STA zp 85 zpx 95 abs 8D abx 9D aby 99 izx 81 izy 91
STX zp 86 zpy 96 abs 8E
STY zp 84 zpx 94 abs 8C
TAX imp AA
TAY imp A8
TSX imp BA
TXA imp 8A
TXS imp 9A
TYA imp 98
""".strip().splitlines():
    p = line.split()
    for i in range(1, len(p), 2):
        OPS[int(p[i + 1], 16)] = (p[0].lower(), p[i])
SIZE = dict(imp=1, acc=1, imm=2, zp=2, zpx=2, zpy=2, izx=2, izy=2, rel=2,
            abs=3, abx=3, aby=3, ind=3)

# ---------------------------------------------------------------- symbols
EQU = {  # hardware, OS and Action! runtime symbols (not part of the image)
    0x0011: "BRKKEY", 0x0014: "RTCLOK", 0x004D: "ATRACT",
    0x0082: "rt_ptr", 0x0083: "rt_ptr+1", 0x0084: "rt_arg", 0x0085: "rt_arg+1",
    0x0086: "rt_res", 0x0087: "rt_res+1",
    0x00A0: "arg0", 0x00A1: "arg1", 0x00A2: "arg2", 0x00A3: "arg3",
    0x00A4: "arg4", 0x00A5: "arg5",
    0x00AA: "tmp0", 0x00AB: "tmp0+1", 0x00AC: "tmp1", 0x00AD: "tmp1+1",
    0x00AE: "tmp2", 0x00AF: "tmp2+1",
    0x0200: "VDSLST", 0x0201: "VDSLST+1", 0x022B: "SRTIMR", 0x022F: "SDMCTL",
    0x0230: "SDLSTL", 0x0231: "SDLSTL+1", 0x026F: "GPRIOR",
    0x0284: "STRIG0", 0x02C0: "PCOLR0", 0x02C4: "COLOR0", 0x02FC: "CH",
    0x03E8: "dli_colpf0", 0x03E9: "dli_colpf1", 0x03EA: "dli_colpf2",
    0x03EB: "dli_colbk",
    0xD000: "HPOSP0", 0xD004: "HPOSM0", 0xD00C: "SIZEM", 0xD016: "COLPF0",
    0xD017: "COLPF1", 0xD018: "COLPF2", 0xD01A: "COLBK", 0xD01D: "GRACTL",
    0xD01E: "HITCLR", 0xD20A: "RANDOM", 0xD301: "PORTB", 0xD404: "HSCROL",
    0xD405: "VSCROL", 0xD407: "PMBASE", 0xD40A: "WSYNC", 0xD40B: "VCOUNT",
    0xD40E: "NMIEN",
    0x5BA7: "DIRS", 0x5C00: "MAZE", 0x9C00: "GAME_DL", 0x9C01: "GAME_DL+1",
    0x9C02: "GAME_DL+2",
    # Action! cartridge runtime copied to $A000-$BBFF by the packer
    0xA090: "ACT_DIV", 0xA0DE: "ACT_MOD", 0xA0E6: "ACT_RSH", 0xA0F5: "ACT_PARAMS",
    0xA7B3: "ACT_MOVEBLOCK", 0xB5C0: "ACT_LSH",
}
EQU_COMMENTS = {
    "ACT_DIV": "CARD A:X / rt_arg -> A:X",
    "ACT_MOD": "CARD A:X MOD rt_arg -> A:X",
    "ACT_RSH": "A:X RSH rt_arg",
    "ACT_LSH": "A:X LSH rt_arg",
    "ACT_PARAMS": "copy arg0.. to PROC locals; followed by .word dest, .byte n-1",
    "ACT_MOVEBLOCK": "MoveBlock(dest=A:X, src=arg2/3, size=arg4/5)",
    "DIRS": "CARD ARRAY dirs of BuildMaze (outside the program image)",
    "MAZE": "maze bitmap 128x128 bytes, ANTIC mode 8, built at run time",
    "GAME_DL": "game display list and PM graphics (PMBASE=$9C), built at run time",
    "dli_colpf0": "colours the game DLI writes to the playfield",
}

# name, and optional header comment for PROCs
NAMES = {
    # globals ------------------------------------------------------------
    0x2840: "titlePic", 0x2842: "dlTitle_data", 0x28AF: "dlTitle",
    0x28B1: "dlCrash_data", 0x28EC: "dlCrash", 0x28EE: "dlWin_data",
    0x290B: "dlWin", 0x290D: "barTxt1_data", 0x292A: "barTxt1",
    0x292C: "barTxt2_data", 0x2957: "barTxt2",
    0x2959: "hposp", 0x295B: "m0pf", 0x295D: "hposm", 0x295F: "p0pf",
    0x2961: "color", 0x2963: "pcolr", 0x2965: "strig",
    0x2967: "cx", 0x2969: "cy", 0x296B: "scrX", 0x296D: "scrY",
    0x296F: "rowPhase", 0x2971: "rowAdr", 0x2973: "score", 0x2975: "best",
    0x2977: "pathLen", 0x2979: "path_data", 0x2A85: "path",
    0x2A87: "shapes_data", 0x2AA7: "shapes",
    0x2AA9: "gi", 0x2AAA: "gk", 0x2AAC: "g_unused1", 0x2AAE: "gp", 0x2AB0: "gq",
    0x2AB2: "gr", 0x2AB4: "gofs", 0x2AB6: "dliCycle", 0x2AB7: "dliLine",
    0x2AB8: "g_unused2", 0x2ABB: "dliCol", 0x2ABC: "g_unused3",
    # PROC locals (Action! puts them in front of the PROC) -------------
    0x2C59: "Wait_n", 0x2C74: "WaitLine_l", 0x2C87: "CarveH_o", 0x2D4D: "CarveV_o",
    0x2E6E: "CallAddr_a", 0x2E7C: "BuildMaze_p", 0x2E7E: "BuildMaze_q",
    0x2E80: "BuildMaze_i", 0x2E82: "BuildMaze_dirs", 0x2E84: "BuildMaze_x",
    0x3142: "InitGameDL_i",
    0x3382: "DrawDigit_dst", 0x3384: "DrawDigit_d", 0x3385: "DrawDigit_src",
    0x3387: "DrawDigit_p", 0x3389: "DrawDigit_i",
    0x3439: "PrintNum_dst", 0x343B: "PrintNum_n", 0x343D: "PrintNum_i",
    0x34B6: "DrawBars_a", 0x34B7: "DrawBars_b", 0x34B8: "DrawBars_init",
    0x34B9: "DrawBars_t", 0x34BA: "DrawBars_topB", 0x34BB: "DrawBars_topA",
    0x372C: "InitPM_p",
    0x3887: "GetInput_key", 0x3888: "GetInput_trig", 0x3889: "GetInput_x",
    0x388A: "GetInput_delay",
    0x3960: "Play_dir", 0x3961: "Play_frame", 0x3962: "Play_key",
    0x3963: "Play_speed", 0x3965: "Play_idx", 0x3967: "Play_spd10",
    0x3969: "Play_accX", 0x396B: "Play_accY", 0x396D: "Play_stepX",
    0x396E: "Play_stepY", 0x396F: "Play_dx_data", 0x3974: "Play_dx",
    0x3976: "Play_dy_data", 0x397B: "Play_dy", 0x397D: "Play_tick",
    0x3F3C: "Title_p", 0x3F3E: "Title_key", 0x407B: "Win_p",
    0x416A: "Crash_p", 0x416C: "Crash_n", 0x416D: "Crash_c", 0x433A: "Main_r",
    # PROCs ----------------------------------------------------------------
    0x2AC3: "DliTitle", 0x2B62: "DliGame", 0x2C13: "DliWin", 0x2C5A: "Wait",
    0x2C75: "WaitLine", 0x2C88: "CarveH", 0x2D19: "CarveLeft",
    0x2D33: "CarveRight", 0x2D4E: "CarveV", 0x2DDF: "CarveUp",
    0x2DF9: "CarveDown", 0x2E13: "MarkCell", 0x2E70: "CallAddr",
    0x2E86: "BuildMaze", 0x30A6: "HidePM", 0x3143: "InitGameDL",
    0x3252: "ScrollMaze", 0x338A: "DrawDigit", 0x343E: "PrintNum",
    0x34BC: "DrawBars", 0x372E: "InitPM", 0x388B: "GetInput",
    0x392F: "AnyKey", 0x3948: "StopAll", 0x397F: "PlayGame",
    0x3F3F: "TitleScreen", 0x407D: "WinScreen", 0x416E: "CrashScreen",
    0x433B: "Main",
    # RMT player -----------------------------------------------------------
    0x4C00: "RMT_INIT", 0x4C03: "RMT_PLAY", 0x4C06: "RMT_P3",
    0x4C09: "RMT_SILENCE", 0x4C0C: "RMT_SETPOKEY", 0x494A: "RMT_VAR_494A",
}

PROC_DOC = {
    "DliTitle": "INTERRUPT: title screen DLI - rolling COLPF2 stripes, COLBK bands",
    "DliGame": "INTERRUPT: game DLI - status bar colour bars, then maze colours",
    "DliWin": "INTERRUPT: 'maza passed' screen DLI - rolling COLPF2",
    "Wait": "PROC Wait(BYTE n) - wait n frames (RTCLOK)",
    "WaitLine": "PROC WaitLine(BYTE l) - wait until VCOUNT>l (never called)",
    "CarveH": "PROC CarveH(BYTE o) - clear 2 words of maze at (cx+o,cy)",
    "CarveLeft": "PROC CarveLeft() - cx==-2, carve",
    "CarveRight": "PROC CarveRight() - carve, cx==+2",
    "CarveV": "PROC CarveV(BYTE o) - clear 2 rows of maze at (cx,cy+o)",
    "CarveUp": "PROC CarveUp() - cy==-2, carve",
    "CarveDown": "PROC CarveDown() - carve, cy==+2",
    "MarkCell": "PROC MarkCell() - put $5555 (colour 1 = start/exit) at (cx,cy)",
    "CallAddr": "PROC CallAddr(CARD a) - JMP (a); used to call dirs(d)",
    "BuildMaze": "PROC BuildMaze() - fill MAZE with walls, carve the fixed path",
    "HidePM": "PROC HidePM() - players/missiles off screen, GRACTL=0",
    "InitGameDL": "PROC InitGameDL() - build display list at GAME_DL",
    "ScrollMaze": "PROC ScrollMaze() - set LMS/HSCROL/VSCROL from scrX,scrY",
    "DrawDigit": "PROC DrawDigit(CARD dst, BYTE d) - 8x8 digit from title picture",
    "PrintNum": "PROC PrintNum(CARD dst, CARD n) - 5 digit number",
    "DrawBars": "PROC DrawBars(BYTE a, b, init) - speed/progress bars in P1/P2",
    "InitPM": "PROC InitPM() - player/missile graphics setup for the game",
    "GetInput": "BYTE FUNC GetInput() - $21 on fire, key code, or $FF",
    "AnyKey": "BYTE FUNC AnyKey() - 1 if GetInput()#$FF",
    "StopAll": "PROC StopAll() - DLI off, screen off, music off",
    "PlayGame": "BYTE FUNC PlayGame() - main game loop; 1=passed 2=crash $1C=ESC",
    "TitleScreen": "PROC TitleScreen() - title, hi-score, waits for a key",
    "WinScreen": "PROC WinScreen() - 'MAZA PASSED!' screen",
    "CrashScreen": "PROC CrashScreen() - shaking crash picture",
    "Main": "PROC Main() - DO TitleScreen() r=PlayGame() ... OD",
}

# 16-bit words in data that hold addresses (emit as dta a(label))
POINTERS = [0x2840, 0x28AF, 0x28EC, 0x290B, 0x292A, 0x2957, 0x2959, 0x295B,
            0x295D, 0x295F, 0x2961, 0x2963, 0x2965, 0x2A85, 0x2AA7, 0x2E82,
            0x3974, 0x397B]
EQU[0x1000] = "TITLE_PIC"
EQU_COMMENTS["TITLE_PIC"] = "title picture / fonts (data/title_pic.bin)"

# memory layout of the rebuilt program
REGIONS = [
    (0x0FFE, 0x1FFF, "bin", "title_pic.bin", "title bitmap, 'MAZA PASSED!' banner, digit font"),
    (0x2000, 0x283F, "bin", "crash_pic.bin", "crash picture (44 lines x 48 bytes)"),
    (0x2840, 0x4365, "code", None, "Action! program: globals, then PROCs"),
    (0x4366, 0x4FFF, "code", None, "RMT player: variables, tables, code at $4C00"),
    (0x5000, 0x56FF, "bin", "music_title.bin", "RMT module: title music"),
    (0x5700, 0x5BA6, "bin", "music_game.bin", "RMT module: game / win / crash music"),
    (0xA000, 0xBBFF, "bin", "action_runtime.bin", "Action! cartridge image (runtime library)"),
]
PROC_HEADS = [a for a, n in NAMES.items() if n in PROC_DOC]
RMT_ENTRIES = [0x4C00, 0x4C03, 0x4C06, 0x4C09, 0x4C0C]


def main():
    mem = open(sys.argv[1], "rb").read()
    outdir = sys.argv[2]
    os.makedirs(os.path.join(outdir, "data"), exist_ok=True)

    def word(a):
        return mem[a] | mem[a + 1] << 8

    # ------------------------------------------------------------ tracing
    code = {}           # addr -> ('ins', size) | ('inline', 3)
    targets = set()
    todo = list(PROC_HEADS) + RMT_ENTRIES
    while todo:
        pc = todo.pop()
        while pc not in code:
            op = mem[pc]
            if op not in OPS:
                sys.exit(f"bad opcode {op:02X} at {pc:04X}")
            mn, mode = OPS[op]
            n = SIZE[mode]
            code[pc] = ("ins", n)
            opnd = word(pc + 1) if n == 3 else mem[pc + 1]
            if mode == "rel":
                t = (pc + 2 + (opnd - 256 if opnd > 127 else opnd)) & 0xFFFF
                targets.add(t)
                todo.append(t)
            if mn == "jsr":
                if opnd == 0xA0F5:
                    code[pc + 3] = ("inline", 3)
                    pc += 6
                    continue
                if opnd < 0xA000:
                    targets.add(opnd)
                    todo.append(opnd)
            if mn == "jmp" and mode == "abs":
                targets.add(opnd)
                todo.append(opnd)
            if mn in ("rts", "rti", "jmp", "brk"):
                break
            pc += n

    # ------------------------------------------------------------ labels
    labels = dict(NAMES)
    for t in targets:
        labels.setdefault(t, f"L{t:04X}")
    inside = {}          # addr -> start of object containing it (for label+n)
    for a, (_, n) in code.items():
        for i in range(n):
            inside[a + i] = a

    def in_image(a):
        return any(lo <= a <= hi for lo, hi, *_ in REGIONS)

    # data referenced by absolute operands gets a label (or label+n)
    for a, (kind, n) in code.items():
        if kind == "ins" and n == 3:
            mn, mode = OPS[mem[a]]
            o = word(a + 1)
            if (mode != "ind" and in_image(o) and o not in inside and o not in labels and o not in EQU
                    and not (o - 1 in NAMES and o - 1 not in code)):
                labels[o] = f"D{o:04X}"

    def sym(o, zp=False):
        if o in labels and in_image(o):
            return labels[o]
        if o in EQU:
            return EQU[o]
        if o in inside and inside[o] != o and inside[o] in labels:
            return f"{labels[inside[o]]}+{o - inside[o]}"
        if o - 1 in NAMES and o - 1 not in code and in_image(o):
            return f"{NAMES[o - 1]}+1"
        return f"${o:02X}" if zp else f"${o:04X}"

    def fmt(a):
        mn, mode = OPS[mem[a]]
        n = SIZE[mode]
        o = word(a + 1) if n == 3 else (mem[a + 1] if n == 2 else None)
        if mode in ("imp",):
            return mn
        if mode == "acc":
            return f"{mn} @"
        if mode == "imm":
            return f"{mn} #${o:02X}"
        if mode == "rel":
            t = (a + 2 + (o - 256 if o > 127 else o)) & 0xFFFF
            return f"{mn} {labels[t]}"
        if mode in ("zp", "zpx", "zpy", "izx", "izy"):
            s = sym(o, zp=True)
            return {"zp": f"{mn} {s}", "zpx": f"{mn} {s},x", "zpy": f"{mn} {s},y",
                    "izx": f"{mn} ({s},x)", "izy": f"{mn} ({s}),y"}[mode]
        s = sym(o)
        force = ".a" if o < 0x100 else ""
        return {"abs": f"{mn}{force} {s}", "abx": f"{mn}{force} {s},x",
                "aby": f"{mn}{force} {s},y", "ind": f"{mn} ({s})"}[mode]

    # ------------------------------------------------------------ output
    out = []
    w = out.append
    w("; SPEEDmaza (2014) by Jakub Husak - disassembly of the unpacked program")
    w("; Generated by tools/disasm.py from the image made by tools/unpack.py.")
    w("; Assemble: mads speedmaza.asm -o:speedmaza.xex   (see build.sh)")
    w("; The program was written in Action!; speedmaza.act is the reconstructed")
    w("; Action! source for the code between DliTitle and Main.")
    w("")
    w("; ---- hardware, OS, Action! runtime")
    for a, n in sorted(EQU.items(), key=lambda x: x[0]):
        if "+" in n:
            continue
        c = EQU_COMMENTS.get(n)
        w(f"{n:<15} = ${a:04X}" + (f"\t; {c}" if c else ""))
    w("")
    w("; ---- INIT during load: OS ROM on, BASIC off, so $A000-$BFFF is RAM")
    w("\topt h+")
    w("\torg $0600")
    w("load_init\tlda #$FF")
    w("\tsta PORTB")
    w("\trts")
    w("\tini load_init")

    for lo, hi, kind, fname, desc in REGIONS:
        w("")
        w(f"; {'=' * 70}")
        w(f"; ${lo:04X}-${hi:04X}  {desc}")
        w(f"; {'=' * 70}")
        w(f"\torg ${lo:04X}")
        if kind == "bin":
            open(os.path.join(outdir, "data", fname), "wb").write(mem[lo:hi + 1])
            inner = sorted(a for a in labels if lo <= a <= hi and a not in EQU)
            w(f"\tins 'data/{fname}'")
            for a in inner:
                w(f"{labels[a]:<15} = ${a:04X}")
            continue
        a = lo
        pending = []

        def flush():
            if not pending:
                return
            for i in range(0, len(pending), 16):
                chunk = pending[i:i + 16]
                w("\tdta " + ",".join(f"${b:02X}" for b in chunk))
            pending.clear()

        while a <= hi:
            if a in labels or a in code or a in POINTERS:
                flush()
            if a in labels:
                name = labels[a]
                if name in PROC_DOC:
                    w("")
                    w(f"; {'-' * 70}")
                    w(f"; {PROC_DOC[name]}")
                    w(f"; {'-' * 70}")
                w(f"{name}")
            if a in POINTERS:
                t = word(a)
                w(f"\tdta a({sym(t)})")
                a += 2
                continue
            if a in code:
                kind2, n = code[a]
                if kind2 == "inline":
                    w(f"\tdta a({sym(word(a))}),${mem[a + 2]:02X}\t; ACT_PARAMS: dest, count-1")
                else:
                    line = fmt(a)
                    c = ""
                    if mem[a] == 0x20 and word(a + 1) in EQU:
                        c = EQU_COMMENTS.get(EQU[word(a + 1)], "")
                    w(f"\t{line}" + (f"\t; {c}" if c else ""))
                a += n
                continue
            pending.append(mem[a])
            a += 1
        flush()

    w("")
    w("; ---- RUN: what the original INIT stub + depacker did before Main")
    w("\torg $0680")
    w("start\tldx #$FF")
    w("\tstx CH")
    w("\tinx")
    w("\tstx SDMCTL")
    w("\tlda RTCLOK")
    w("st_wait\tcmp RTCLOK")
    w("\tbeq st_wait")
    w("\tlda #$40")
    w("\tsta NMIEN")
    w("\tcli")
    w("\tjmp Main")
    w("\trun start")
    open(os.path.join(outdir, "speedmaza.asm"), "w").write("\n".join(out) + "\n")
    print(f"{len(code)} code objects, {len(labels)} labels")


if __name__ == "__main__":
    main()
