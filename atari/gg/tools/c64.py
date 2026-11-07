#!/usr/bin/env python3
"""Headless C64 model used to unpack and study Ghosts'n Goblins Arcade.

py65 runs the 6510. Modelled: the $00/$01 processor port and its banking
(no ROM images: BASIC/KERNAL/char ROM areas read as RAM and accesses are
logged), VIC-II registers with a raster counter and raster IRQ, CIA1/CIA2
timers with IRQ/NMI, the joystick/keyboard matrix on CIA1, and SID register
writes (logged per frame).

The disk loader is not emulated at drive level; callers install traps
(`traps[pc] = fn`) that service load requests directly from the D64 files.
"""
from py65.devices.mpu6502 import MPU

PAL_LINES, PAL_CYC = 312, 63


class Mem:
    def __init__(self, c):
        self.c = c
        self.ram = bytearray(65536)

    def __getitem__(self, addr):
        if 0xD000 <= addr < 0xE000 and self.c.io_on():
            return self.c.io_read(addr)
        return self.ram[addr]

    def __setitem__(self, addr, v):
        if addr < 2:
            self.c.port[addr] = v
            self.ram[addr] = v
            return
        if 0xD000 <= addr < 0xE000 and self.c.io_on():
            self.c.io_write(addr, v)
            return
        if addr & 0x3F8 == 0x3F8:          # possible sprite pointer: replayed by the renderer
            c = self.c
            c.vic_log.append((c.line, c.line_cyc, 0x10000 | addr, v))
        self.ram[addr] = v


class CIA:
    def __init__(self):
        self.ta = self.tb = 0xFFFF
        self.la = self.lb = 0xFFFF
        self.cra = self.crb = 0
        self.icr_mask = 0
        self.icr = 0
        self.regs = bytearray(16)

    def tick(self, n):
        fired = False
        if self.cra & 1:
            self.ta -= n
            if self.ta < 0:
                self.icr |= 1
                self.ta = self.la + self.ta % (self.la + 1) if self.la else 0
                if self.cra & 8:
                    self.cra &= ~1
                if self.icr_mask & 1:
                    fired = True
        if self.crb & 1 and not self.crb & 0x40:
            self.tb -= n
            if self.tb < 0:
                self.icr |= 2
                self.tb = self.lb + self.tb % (self.lb + 1) if self.lb else 0
                if self.crb & 8:
                    self.crb &= ~1
                if self.icr_mask & 2:
                    fired = True
        if fired:
            self.icr |= 0x80
        return bool(self.icr & 0x80)


class C64:
    def __init__(self):
        self.mem = Mem(self)
        self.cpu = MPU(memory=self.mem)
        self.port = bytearray([0x2F, 0x37])
        self.colram = bytearray(1024)
        self.vic = bytearray(64)
        self.vic_irq = 0
        self.d019_read = (-1, 0)
        self.raster_cmp = 0
        self.sid = bytearray(32)
        self.sid_log = []
        self.cia1, self.cia2 = CIA(), CIA()
        self.joy2 = 0xFF          # bits: 0 up 1 down 2 left 3 right 4 fire (low = pressed)
        self.joy1 = 0xFF
        self.keys = set()         # (row, col) pressed
        self.cycles = 0
        self.line = 0
        self.line_cyc = 0
        self.frame = 0
        self.traps = {}
        self.io_log = {}          # (pc, addr, 'r'/'w') -> count
        self.log_io = False
        self.frame_hook = None
        self.vic_log = []         # (line, cycle, reg, value) this frame
        self.last_frame = None    # (regs at frame start, dd00, log) of the last full frame
        self.frame_regs = (bytes(64), 0x3F)
        self.frame_ptrs = {}

    def io_on(self):
        p = self.port[1] | ~self.port[0] & 0xFF
        return (p & 3) != 0 and (p & 4) != 0

    def sprite_ptrs(self):
        """Sprite pointer bytes of the current screen (frame-start state for the renderer)."""
        bank = (3 - (self.cia2.regs[0] & 3)) * 0x4000
        scr = bank + ((self.vic[0x18] >> 4) & 15) * 0x400
        return {scr + 0x3F8 + i: self.mem.ram[scr + 0x3F8 + i] for i in range(8)}

    def kernal_on(self):
        p = self.port[1] | ~self.port[0] & 0xFF
        return bool(p & 2)

    # ---- I/O ----------------------------------------------------------
    def _log(self, addr, kind):
        if self.log_io:
            k = (self.cpu.pc, addr, kind)
            self.io_log[k] = self.io_log.get(k, 0) + 1

    def io_read(self, addr):
        self._log(addr, 'r')
        if addr < 0xD400:
            r = addr & 0x3F
            if r == 0x11:
                return (self.vic[0x11] & 0x7F) | ((self.line >> 1) & 0x80)
            if r == 0x12:
                return self.line & 0xFF
            if r == 0x19:
                v = self.vic_irq | (0x80 if self.vic_irq & self.vic[0x1A] else 0) | 0x70
                self.d019_read = (self.cycles, v)
                return v
            if r == 0x1E or r == 0x1F:
                v = self.vic[r]
                self.vic[r] = 0
                return v
            if r >= 0x2F:
                return 0xFF
            return self.vic[r]
        if addr < 0xD800:
            r = addr & 0x1F
            if r == 0x1B:
                return (self.cycles * 7) & 0xFF
            if r == 0x19 or r == 0x1A:
                return 0xFF
            return 0
        if addr < 0xDC00:
            return self.colram[addr & 0x3FF]
        if addr < 0xDD00:
            return self.cia_read(self.cia1, addr & 15, 1)
        if addr < 0xDE00:
            return self.cia_read(self.cia2, addr & 15, 2)
        return 0xFF

    def cia_read(self, cia, r, n):
        if n == 1 and r == 0:
            v = self.joy2
            cols = cia.regs[1] if False else 0xFF
            return v & self._keys_rows_for(cia.regs[0] if cia.regs[2] else 0xFF, cols, True)
        if n == 1 and r == 1:
            v = self.joy1
            return v & self._keys_cols(cia.regs[0])
        if r == 4:
            return cia.ta & 0xFF
        if r == 5:
            return cia.ta >> 8 & 0xFF
        if r == 6:
            return cia.tb & 0xFF
        if r == 7:
            return cia.tb >> 8 & 0xFF
        if r == 13:
            v = cia.icr
            cia.icr = 0
            return v
        if r == 14:
            return cia.cra
        if r == 15:
            return cia.crb
        return cia.regs[r]

    def _keys_rows_for(self, colsel, _c, _x):
        return 0xFF

    def _keys_cols(self, rowsel):
        v = 0xFF
        for row, col in self.keys:
            if not rowsel & (1 << row):
                v &= ~(1 << col)
        return v & 0xFF

    def io_write(self, addr, v):
        self._log(addr, 'w')
        if addr < 0xD400:
            r = addr & 0x3F
            self.vic_log.append((self.line, self.line_cyc, r, v))
            if r == 0x19:
                # read-modify-write instructions write the old value first
                if self.d019_read[0] == self.cycles:
                    v |= self.d019_read[1]
                self.vic_irq &= ~v
                return
            if r == 0x12:
                self.raster_cmp = (self.raster_cmp & 0x100) | v
            if r == 0x11:
                self.raster_cmp = (self.raster_cmp & 0xFF) | (v & 0x80) << 1
            if r < 0x2F:
                self.vic[r] = v
            return
        if addr < 0xD800:
            self.sid[addr & 0x1F] = v
            self.sid_log.append((self.frame, self.line, addr & 0x1F, v))
            return
        if addr < 0xDC00:
            self.colram[addr & 0x3FF] = v & 0x0F
            return
        if addr < 0xDE00:
            cia = self.cia1 if addr < 0xDD00 else self.cia2
            r = addr & 15
            if r == 4:
                cia.la = cia.la & 0xFF00 | v
            elif r == 5:
                cia.la = cia.la & 0xFF | v << 8
                if not cia.cra & 1:
                    cia.ta = cia.la
            elif r == 6:
                cia.lb = cia.lb & 0xFF00 | v
            elif r == 7:
                cia.lb = cia.lb & 0xFF | v << 8
                if not cia.crb & 1:
                    cia.tb = cia.lb
            elif r == 0 and cia is self.cia2:
                self.vic_log.append((self.line, self.line_cyc, 0x40, v))
            elif r == 13:
                if v & 0x80:
                    cia.icr_mask |= v & 0x1F
                else:
                    cia.icr_mask &= ~v
            elif r == 14:
                if v & 0x10:
                    cia.ta = cia.la
                cia.cra = v & 0xEF
            elif r == 15:
                if v & 0x10:
                    cia.tb = cia.lb
                cia.crb = v & 0xEF
            cia.regs[r] = v

    # ---- snapshots ----
    STATE = ('port', 'vic', 'vic_irq', 'raster_cmp', 'sid', 'joy1', 'joy2', 'cycles', 'line',
             'line_cyc', 'frame', 'vic_log', 'last_frame', 'frame_regs', 'frame_ptrs', 'colram')

    def save(self, path):
        import pickle
        cpu = self.cpu
        st = {k: getattr(self, k) for k in self.STATE}
        st['ram'] = bytes(self.mem.ram)
        st['cpu'] = (cpu.pc, cpu.a, cpu.x, cpu.y, cpu.sp, cpu.p, cpu.processorCycles)
        st['cia'] = (vars(self.cia1), vars(self.cia2))
        st.update(self.extra_state())
        with open(path, 'wb') as f:
            pickle.dump(st, f)

    def restore(self, path):
        import pickle
        with open(path, 'rb') as f:
            st = pickle.load(f)
        self.mem.ram[:] = st.pop('ram')
        cpu = self.cpu
        cpu.pc, cpu.a, cpu.x, cpu.y, cpu.sp, cpu.p, cpu.processorCycles = st.pop('cpu')
        a, b = st.pop('cia')
        vars(self.cia1).update(a)
        vars(self.cia2).update(b)
        for k, v in st.items():
            setattr(self, k, v)

    def extra_state(self):
        return {}

    # ---- execution ----------------------------------------------------
    def load_prg(self, data):
        a = data[0] | data[1] << 8
        self.mem.ram[a:a + len(data) - 2] = data[2:]
        return a, a + len(data) - 2

    def interrupt(self, vector):
        cpu = self.cpu
        cpu.stPushWord(cpu.pc)
        cpu.stPush((cpu.p & ~cpu.BREAK) | cpu.UNUSED)
        cpu.p |= cpu.INTERRUPT
        cpu.pc = self.mem[vector] | self.mem[vector + 1] << 8

    def advance(self, n):
        self.cycles += n
        self.line_cyc += n
        while self.line_cyc >= PAL_CYC:
            self.line_cyc -= PAL_CYC
            self.line += 1
            if self.line >= PAL_LINES:
                self.line = 0
                self.frame += 1
                self.last_frame = (self.frame_regs[0], self.frame_regs[1], self.vic_log,
                                   self.frame_ptrs)
                self.vic_log = []
                self.frame_regs = (bytes(self.vic), self.cia2.regs[0])
                self.frame_ptrs = self.sprite_ptrs()
                if self.frame_hook:
                    self.frame_hook(self)
            if self.line == self.raster_cmp:
                self.vic_irq |= 1
        a = self.cia1.tick(n)
        b = self.cia2.tick(n)
        return a, b

    def run(self, max_cycles, stop=None):
        cpu = self.cpu
        end = self.cycles + max_cycles
        traps = self.traps
        nmi_prev = False
        while self.cycles < end:
            pc = cpu.pc
            if pc in traps:
                r = traps[pc](self)
                if r == 'stop':
                    return pc
                if r == 'again':
                    continue
            if pc >= 0xE000 and self.kernal_on():
                raise RuntimeError(f'unhandled KERNAL call ${pc:04X}')
            if stop and stop(self):
                return cpu.pc
            c0 = cpu.processorCycles
            cpu.step()
            irq_cia, nmi_cia = self.advance(cpu.processorCycles - c0)
            if nmi_cia and not nmi_prev:
                self.interrupt(0xFFFA)
            nmi_prev = nmi_cia
            if not cpu.p & cpu.INTERRUPT and (irq_cia or (self.vic_irq & self.vic[0x1A] & 0x0F)):
                self.interrupt(0xFFFE)
        return None
