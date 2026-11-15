"""8080 instruction decoder for the Phoenix ROM (Z80-style register names).

Registers are numbered as in the opcode: 0 B, 1 C, 2 D, 3 E, 4 H, 5 L, 6 M, 7 A.
Register pairs: 0 BC, 1 DE, 2 HL, 3 SP (PSW for PUSH/POP).
"""
from dataclasses import dataclass, field

RN = "BCDEHLMA"
PN = ["BC", "DE", "HL", "SP"]
ALU = ["ADD", "ADC", "SUB", "SBC", "AND", "XOR", "OR", "CP"]
CC = ["NZ", "Z", "NC", "C", "PO", "PE", "P", "M"]


@dataclass
class Ins:
    addr: int
    op: int
    size: int
    kind: str              # see decode()
    a: int = 0             # first operand (register / pair / alu op / condition)
    b: int = 0             # second operand
    imm: int = 0           # immediate / address
    text: str = ""
    succ: list = field(default_factory=list)

    @property
    def next(self):
        return self.addr + self.size


def decode(rom, addr):
    op = rom[addr]
    b1 = rom[addr + 1] if addr + 1 < len(rom) else 0
    w = b1 | ((rom[addr + 2] if addr + 2 < len(rom) else 0) << 8)

    def mk(size, kind, a=0, b=0, imm=0, text=""):
        return Ins(addr, op, size, kind, a, b, imm, text)

    if 0x40 <= op < 0x80:
        if op == 0x76:
            return mk(1, "halt", text="HALT")
        d, s = (op >> 3) & 7, op & 7
        return mk(1, "mov", d, s, text=f"LD {RN[d]},{RN[s]}")
    if 0x80 <= op < 0xC0:
        o, s = (op >> 3) & 7, op & 7
        return mk(1, "alu", o, s, text=f"{ALU[o]} {RN[s]}")
    lo, y = op & 7, (op >> 3) & 7
    if op < 0x40:
        if lo == 0:
            if op == 0:
                return mk(1, "nop", text="NOP")
            return mk(1, "bad", text=f"?{op:02X}")
        if lo == 1:
            if op & 8:
                return mk(1, "dad", y >> 1, text=f"ADD HL,{PN[y >> 1]}")
            return mk(3, "lxi", y >> 1, imm=w, text=f"LD {PN[y >> 1]},${w:04X}")
        if lo == 2:
            t = {0x02: ("stax", 0, "LD (BC),A"), 0x12: ("stax", 1, "LD (DE),A"),
                 0x0A: ("ldax", 0, "LD A,(BC)"), 0x1A: ("ldax", 1, "LD A,(DE)")}
            if op in t:
                k, p, tx = t[op]
                return mk(1, k, p, text=tx)
            k = {0x22: "shld", 0x2A: "lhld", 0x32: "sta", 0x3A: "lda"}[op]
            return mk(3, k, imm=w, text=f"{k.upper()} ${w:04X}")
        if lo == 3:
            k = "dcx" if op & 8 else "inx"
            return mk(1, k, y >> 1, text=f"{'DEC' if op & 8 else 'INC'} {PN[y >> 1]}")
        if lo == 4:
            return mk(1, "inr", y, text=f"INC {RN[y]}")
        if lo == 5:
            return mk(1, "dcr", y, text=f"DEC {RN[y]}")
        if lo == 6:
            return mk(2, "mvi", y, imm=b1, text=f"LD {RN[y]},${b1:02X}")
        k = ["rlc", "rrc", "ral", "rar", "daa", "cma", "stc", "cmc"][y]
        return mk(1, k, text=["RLCA", "RRCA", "RLA", "RRA", "DAA", "CPL", "SCF", "CCF"][y])
    if lo == 0:
        return mk(1, "rcc", y, text=f"RET {CC[y]}")
    if lo == 1:
        if op == 0xC9:
            return mk(1, "ret", text="RET")
        if op == 0xE9:
            return mk(1, "pchl", text="JP (HL)")
        if op == 0xF9:
            return mk(1, "sphl", text="LD SP,HL")
        if op == 0xF1:
            return mk(1, "pop", 3, text="POP AF")
        return mk(1, "pop", y >> 1, text=f"POP {PN[y >> 1]}")
    if lo == 2:
        return mk(3, "jcc", y, imm=w, text=f"JP {CC[y]},${w:04X}")
    if lo == 3:
        if op == 0xC3:
            return mk(3, "jmp", imm=w, text=f"JP ${w:04X}")
        if op == 0xE3:
            return mk(1, "xthl", text="EX (SP),HL")
        if op == 0xEB:
            return mk(1, "xchg", text="EX DE,HL")
        if op in (0xF3, 0xFB):
            return mk(1, "nop", text="DI/EI")
        return mk(2, "bad", text=f"?{op:02X}")
    if lo == 4:
        return mk(3, "ccc", y, imm=w, text=f"CALL {CC[y]},${w:04X}")
    if lo == 5:
        if op == 0xCD:
            return mk(3, "call", imm=w, text=f"CALL ${w:04X}")
        if op == 0xF5:
            return mk(1, "push", 3, text="PUSH AF")
        if op & 8:
            return mk(1, "bad", text=f"?{op:02X}")
        return mk(1, "push", y >> 1, text=f"PUSH {PN[y >> 1]}")
    if lo == 6:
        return mk(2, "alui", y, imm=b1, text=f"{ALU[y]} ${b1:02X}")
    return mk(1, "rst", y, imm=y * 8, text=f"RST ${y * 8:02X}")
