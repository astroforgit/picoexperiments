"""Intel 8080/8085 CPU core used as the reference model of the arcade board.

Only what Phoenix needs: the documented 8080 instruction set (the Z80-style
disassembly of the game uses nothing else). Flags are kept in 8080 layout
(S Z 0 AC 0 P 1 C). The memory object must provide read(addr) / write(addr, v).
"""

PARITY = [0] * 256
for _i in range(256):
    PARITY[_i] = 0 if bin(_i).count("1") & 1 else 1

CYCLES = [
    4, 10, 7, 5, 5, 5, 7, 4, 4, 10, 7, 5, 5, 5, 7, 4,
    4, 10, 7, 5, 5, 5, 7, 4, 4, 10, 7, 5, 5, 5, 7, 4,
    4, 10, 16, 5, 5, 5, 7, 4, 4, 10, 16, 5, 5, 5, 7, 4,
    4, 10, 13, 5, 10, 10, 10, 4, 4, 10, 13, 5, 5, 5, 7, 4,
] + [5] * 64 + [4] * 64 + [
    5, 10, 10, 10, 11, 11, 7, 11, 5, 10, 10, 10, 11, 17, 7, 11,
    5, 10, 10, 10, 11, 11, 7, 11, 5, 10, 10, 10, 11, 17, 7, 11,
    5, 10, 10, 18, 11, 11, 7, 11, 5, 5, 10, 4, 11, 17, 7, 11,
    5, 10, 10, 4, 11, 11, 7, 11, 5, 5, 10, 4, 11, 17, 7, 11,
]
for _op in range(0x40, 0x80):
    if (_op & 7) == 6 or ((_op >> 3) & 7) == 6:
        CYCLES[_op] = 7
CYCLES[0x76] = 7
for _op in range(0x80, 0xC0):
    if (_op & 7) == 6:
        CYCLES[_op] = 7


class CPU:
    def __init__(self, mem):
        self.mem = mem
        self.r = [0] * 8          # B C D E H L (M unused) A
        self.f_s = self.f_z = self.f_ac = self.f_p = self.f_c = 0
        self.pc = 0
        self.sp = 0
        self.cycles = 0
        self.hook = {}            # pc -> callable(cpu) run before the instruction

    # register helpers ------------------------------------------------
    def hl(self):
        return (self.r[4] << 8) | self.r[5]

    def get_rp(self, i):
        r = self.r
        if i == 0:
            return (r[0] << 8) | r[1]
        if i == 1:
            return (r[2] << 8) | r[3]
        if i == 2:
            return (r[4] << 8) | r[5]
        return self.sp

    def set_rp(self, i, v):
        v &= 0xFFFF
        r = self.r
        if i == 0:
            r[0], r[1] = v >> 8, v & 0xFF
        elif i == 1:
            r[2], r[3] = v >> 8, v & 0xFF
        elif i == 2:
            r[4], r[5] = v >> 8, v & 0xFF
        else:
            self.sp = v

    def get_f(self):
        return (self.f_s << 7) | (self.f_z << 6) | (self.f_ac << 4) | (self.f_p << 2) | 2 | self.f_c

    def set_f(self, v):
        self.f_s = (v >> 7) & 1
        self.f_z = (v >> 6) & 1
        self.f_ac = (v >> 4) & 1
        self.f_p = (v >> 2) & 1
        self.f_c = v & 1

    def szp(self, v):
        self.f_s = v >> 7
        self.f_z = 1 if v == 0 else 0
        self.f_p = PARITY[v]

    def getr(self, i):
        if i == 6:
            return self.mem.read(self.hl())
        return self.r[i]

    def setr(self, i, v):
        if i == 6:
            self.mem.write(self.hl(), v)
        else:
            self.r[i] = v

    def push(self, v):
        self.sp = (self.sp - 2) & 0xFFFF
        self.mem.write(self.sp, v & 0xFF)
        self.mem.write((self.sp + 1) & 0xFFFF, v >> 8)

    def pop(self):
        v = self.mem.read(self.sp) | (self.mem.read((self.sp + 1) & 0xFFFF) << 8)
        self.sp = (self.sp + 2) & 0xFFFF
        return v

    def cond(self, c):
        if c == 0:
            return not self.f_z
        if c == 1:
            return self.f_z
        if c == 2:
            return not self.f_c
        if c == 3:
            return self.f_c
        if c == 4:
            return not self.f_p
        if c == 5:
            return self.f_p
        if c == 6:
            return not self.f_s
        return self.f_s

    # ALU ---------------------------------------------------------------
    def alu(self, op, v):
        a = self.r[7]
        if op == 0 or op == 1:          # ADD / ADC
            c = self.f_c if op == 1 else 0
            res = a + v + c
            self.f_ac = 1 if ((a & 0xF) + (v & 0xF) + c) > 0xF else 0
            self.f_c = res >> 8
            res &= 0xFF
            self.szp(res)
            self.r[7] = res
        elif op in (2, 3, 7):           # SUB / SBC / CP
            c = self.f_c if op == 3 else 0
            res = a - v - c
            self.f_ac = 0 if ((a & 0xF) - (v & 0xF) - c) < 0 else 1
            self.f_c = 1 if res < 0 else 0
            res &= 0xFF
            self.szp(res)
            if op != 7:
                self.r[7] = res
        elif op == 4:                   # AND
            res = a & v
            self.f_ac = 1 if ((a | v) & 8) else 0
            self.f_c = 0
            self.szp(res)
            self.r[7] = res
        elif op == 5:                   # XOR
            res = a ^ v
            self.f_ac = self.f_c = 0
            self.szp(res)
            self.r[7] = res
        else:                           # OR
            res = a | v
            self.f_ac = self.f_c = 0
            self.szp(res)
            self.r[7] = res

    def fetch(self):
        v = self.mem.read(self.pc)
        self.pc = (self.pc + 1) & 0xFFFF
        return v

    def fetch16(self):
        lo = self.fetch()
        return lo | (self.fetch() << 8)

    # main step ---------------------------------------------------------
    def step(self):
        h = self.hook.get(self.pc)
        if h is not None and h(self):
            return
        op = self.fetch()
        self.cycles += CYCLES[op]
        r = self.r
        if 0x40 <= op < 0x80:
            if op == 0x76:
                raise RuntimeError("HALT at %04X" % ((self.pc - 1) & 0xFFFF))
            self.setr((op >> 3) & 7, self.getr(op & 7))
            return
        if 0x80 <= op < 0xC0:
            self.alu((op >> 3) & 7, self.getr(op & 7))
            return
        if op < 0x40:
            lo = op & 7
            y = (op >> 3) & 7
            if lo == 0:
                if op == 0:
                    return
                raise RuntimeError("bad opcode %02X at %04X" % (op, (self.pc - 1) & 0xFFFF))
            if lo == 1:
                if op & 8:              # ADD HL,rp
                    res = self.hl() + self.get_rp(y >> 1)
                    self.f_c = res >> 16
                    self.set_rp(2, res)
                else:
                    self.set_rp(y >> 1, self.fetch16())
                return
            if lo == 2:
                if op == 0x02:
                    self.mem.write(self.get_rp(0), r[7])
                elif op == 0x12:
                    self.mem.write(self.get_rp(1), r[7])
                elif op == 0x0A:
                    r[7] = self.mem.read(self.get_rp(0))
                elif op == 0x1A:
                    r[7] = self.mem.read(self.get_rp(1))
                elif op == 0x22:
                    a = self.fetch16()
                    self.mem.write(a, r[5])
                    self.mem.write((a + 1) & 0xFFFF, r[4])
                elif op == 0x2A:
                    a = self.fetch16()
                    r[5] = self.mem.read(a)
                    r[4] = self.mem.read((a + 1) & 0xFFFF)
                elif op == 0x32:
                    self.mem.write(self.fetch16(), r[7])
                else:
                    r[7] = self.mem.read(self.fetch16())
                return
            if lo == 3:
                d = -1 if op & 8 else 1
                self.set_rp(y >> 1, self.get_rp(y >> 1) + d)
                return
            if lo == 4 or lo == 5:
                v = self.getr(y)
                if lo == 4:
                    res = (v + 1) & 0xFF
                    self.f_ac = 1 if (res & 0xF) == 0 else 0
                else:
                    res = (v - 1) & 0xFF
                    self.f_ac = 0 if (res & 0xF) == 0xF else 1
                self.szp(res)
                self.setr(y, res)
                return
            if lo == 6:
                self.setr(y, self.fetch())
                return
            # lo == 7: rotates and misc
            a = r[7]
            if y == 0:                  # RLC
                self.f_c = a >> 7
                r[7] = ((a << 1) | self.f_c) & 0xFF
            elif y == 1:                # RRC
                self.f_c = a & 1
                r[7] = (a >> 1) | (self.f_c << 7)
            elif y == 2:                # RAL
                c = self.f_c
                self.f_c = a >> 7
                r[7] = ((a << 1) | c) & 0xFF
            elif y == 3:                # RAR
                c = self.f_c
                self.f_c = a & 1
                r[7] = (a >> 1) | (c << 7)
            elif y == 4:                # DAA
                corr = 0
                c = self.f_c
                if (a & 0xF) > 9 or self.f_ac:
                    corr = 6
                if a > 0x99 or c:
                    corr |= 0x60
                    c = 1
                self.f_ac = 1 if ((a & 0xF) + (corr & 0xF)) > 0xF else 0
                res = (a + corr) & 0xFF
                self.f_c = c
                self.szp(res)
                r[7] = res
            elif y == 5:                # CMA
                r[7] = a ^ 0xFF
            elif y == 6:                # STC
                self.f_c = 1
            else:                       # CMC
                self.f_c ^= 1
            return
        # 0xC0 - 0xFF
        lo = op & 7
        y = (op >> 3) & 7
        if lo == 0:                     # Rcc
            if self.cond(y):
                self.cycles += 6
                self.pc = self.pop()
            return
        if lo == 1:
            if op == 0xC9:
                self.pc = self.pop()
            elif op == 0xE9:
                self.pc = self.hl()
            elif op == 0xF9:
                self.sp = self.hl()
            elif op == 0xF1:
                v = self.pop()
                r[7] = v >> 8
                self.set_f(v & 0xFF)
            else:
                self.set_rp(y >> 1, self.pop())
            return
        if lo == 2:                     # Jcc
            a = self.fetch16()
            if self.cond(y):
                self.pc = a
            return
        if lo == 3:
            if op == 0xC3:
                self.pc = self.fetch16()
            elif op == 0xE3:            # XTHL
                v = self.mem.read(self.sp) | (self.mem.read(self.sp + 1) << 8)
                self.mem.write(self.sp, r[5])
                self.mem.write(self.sp + 1, r[4])
                r[4], r[5] = v >> 8, v & 0xFF
            elif op == 0xEB:
                r[2], r[4] = r[4], r[2]
                r[3], r[5] = r[5], r[3]
            elif op in (0xF3, 0xFB):
                pass
            else:
                raise RuntimeError("I/O opcode %02X at %04X" % (op, (self.pc - 1) & 0xFFFF))
            return
        if lo == 4:                     # Ccc
            a = self.fetch16()
            if self.cond(y):
                self.cycles += 6
                self.push(self.pc)
                self.pc = a
            return
        if lo == 5:
            if op == 0xCD:
                a = self.fetch16()
                self.push(self.pc)
                self.pc = a
            elif op == 0xF5:
                self.push((r[7] << 8) | self.get_f())
            elif op & 8:
                raise RuntimeError("bad opcode %02X" % op)
            else:
                self.push(self.get_rp(y >> 1))
            return
        if lo == 6:
            self.alu(y, self.fetch())
            return
        self.push(self.pc)              # RST
        self.pc = y * 8
