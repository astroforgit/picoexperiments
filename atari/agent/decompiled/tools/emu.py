#!/usr/bin/env python3
"""Small headless Atari 800XL for looking at Agent USA while it runs.

py65 runs the 6502 with a real OS ROM (any 16 KB XL OS image, for example
AltirraOS built from the Altirra sources with MADS). ANTIC is stepped one
scanline at a time: display list, DLIs, VBI, WSYNC, VCOUNT. Each scanline is
drawn with the registers as they are at that moment, so colour and font
changes made by DLIs show up. Players and missiles are drawn too; collisions,
GTIA modes, fine scrolling and sound are not emulated.

    from emu import Atari
    a = Atari('agent.xex', 'kernelxl.rom')
    a.boot()
    a.run_frames(200)
    a.screenshot('shot.png')
"""
from pathlib import Path
import random

import numpy as np
from py65.devices.mpu6502 import MPU

LINE = 114                  # CPU cycles per scanline (DMA not subtracted)
LINES = 312                 # PAL
SIOV = 0xE459
MODE_LINES = {2: 8, 3: 10, 4: 8, 5: 16, 6: 8, 7: 16, 8: 8, 9: 4, 10: 4,
              11: 2, 12: 1, 13: 2, 14: 1, 15: 1}
MODE_BYTES = {2: 40, 3: 40, 4: 40, 5: 40, 6: 20, 7: 20, 8: 10, 9: 10,
              10: 20, 11: 20, 12: 20, 13: 40, 14: 40, 15: 40}


def palette():
    """An approximate PAL palette: 16 hues x 16 lumas -> RGB."""
    pal = np.zeros((256, 3), np.uint8)
    import colorsys
    for c in range(256):
        hue, lum = c >> 4, (c & 15) / 15
        if hue == 0:
            r = g = b = lum
        else:
            h = ((hue - 1) / 15 * 360 + 200) % 360 / 360
            r, g, b = colorsys.hls_to_rgb(h, 0.1 + lum * 0.8, 0.6)
        pal[c] = [int(255 * min(1, max(0, v))) for v in (r, g, b)]
    return pal


PAL = palette()


class Mem:
    def __init__(self, atari):
        self.a = atari
        self.ram = bytearray(65536)

    def __getitem__(self, addr):
        if 0xD000 <= addr < 0xD800:
            return self.a.io_read(addr)
        if addr >= 0xC000 and self.a.portb & 1 and not 0xD000 <= addr < 0xD800:
            return self.a.rom[addr - 0xC000]
        return self.ram[addr]

    def __setitem__(self, addr, value):
        if 0xD000 <= addr < 0xD800:
            self.a.io_write(addr, value)
            return
        if addr >= 0xC000 and self.a.portb & 1:
            return
        self.ram[addr] = value


class Atari:
    def __init__(self, xex, rom):
        self.xex = Path(xex).read_bytes()
        self.rom = Path(rom).read_bytes()
        assert len(self.rom) == 16384, 'need a 16 KB XL OS ROM'
        self.mem = Mem(self)
        self.cpu = MPU(memory=self.mem)
        self.hw = bytearray(0x800)          # last value written to $D000-$D7FF
        self.portb = 0xFF
        self.line = 0
        self.line_start = 0                 # CPU cycle the current line began
        self.frame = 0
        self.nmist = 0
        self.stick = 15
        self.trig = 1
        self.consol = 7
        self.rng = random.Random(1)
        self.img = np.zeros((LINES, 384), np.uint8)
        self.dl = None                      # ANTIC state, see antic_line()
        self.hooks = {}                     # pc -> function(atari)
        self.trace_pc = None                # set() to collect executed PCs

    # ------------------------------------------------------------ I/O
    def io_read(self, a):
        page, r = a >> 8, a & 0xFF
        if page == 0xD0:
            r &= 0x1F
            if r == 0x10:
                return self.trig
            if 0x11 <= r <= 0x13:
                return 1 if r < 0x13 else 0         # TRIG3=0: no cartridge
            if r == 0x14:
                return 1                            # PAL
            if r == 0x1F:
                return self.consol
            return 0                                # collisions
        if page == 0xD2:
            r &= 0x0F
            if r == 0x0A:
                return self.rng.randrange(256)
            if r == 0x09:
                return self.hw[0x209]
            if r in (0x0E, 0x0F):
                return 0xFF
            return 0xFF
        if page == 0xD3:
            r &= 3
            if r == 0:
                return self.stick | 0xF0
            if r == 1:
                return self.portb
            return 0x3C
        if page == 0xD4:
            r &= 0x0F
            if r == 0x0B:
                return (self.line >> 1) & 0xFF
            if r == 0x0F:
                return self.nmist | 0x1F
            return 0xFF
        return 0xFF

    def io_write(self, a, v):
        page, r = a >> 8, a & 0xFF
        if page == 0xD0:
            self.hw[0x000 + (r & 0x1F)] = v
        elif page == 0xD2:
            self.hw[0x200 + (r & 0x0F)] = v
        elif page == 0xD3:
            if r & 3 == 1:
                self.portb = v
        elif page == 0xD4:
            r &= 0x0F
            self.hw[0x400 + r] = v
            if r == 0x0A:                           # WSYNC
                self.wsync = True
            elif r == 0x0F:                         # NMIRES
                self.nmist = 0

    def reg(self, a):
        return self.hw[a - 0xD000]

    # ------------------------------------------------------------ loading
    def boot(self, frames=120):
        """Cold start the OS (no disk: SIO calls fail), then load the XEX the
        way DOS would and jump to its RUN address."""
        cpu = self.cpu
        cpu.reset()
        cpu.pc = self.rom[0xFFFC - 0xC000] | self.rom[0xFFFD - 0xC000] << 8
        self.hooks[SIOV] = self._sio_fail
        self.run_frames(frames)
        d = self.xex
        p = 0
        run = None
        ram = self.mem.ram
        while p < len(d):
            s = d[p] | d[p + 1] << 8
            p += 2
            if s == 0xFFFF:
                continue
            e = d[p] | d[p + 1] << 8
            p += 2
            chunk = d[p:p + e - s + 1]
            p += e - s + 1
            if s == 0x2E0:
                run = chunk[0] | chunk[1] << 8
            elif s == 0x2E2:
                raise NotImplementedError('INIT segments')
            else:
                ram[s:s + len(chunk)] = chunk
        cpu.sp = 0xFF
        cpu.p &= ~0x04
        cpu.pc = run

    @staticmethod
    def _sio_fail(a):
        cpu = a.cpu
        cpu.y = 0x8A                                # timeout
        cpu.p |= 0x80
        cpu.pc = cpu.stPopWord() + 1

    # ------------------------------------------------------------ running
    def run_frames(self, n):
        for _ in range(n):
            self.run_frame()

    def run_frame(self):
        for _ in range(LINES):
            self.run_line()
        self.frame += 1

    def run_line(self):
        cpu = self.cpu
        line = self.line
        dli = self.antic_line(line)
        end = self.line_start + LINE
        self.wsync = False
        rendered = False
        nmi_at = None
        if line == 248:
            nmi_at = ('vbi', self.line_start + 8)
        elif dli:
            nmi_at = ('dli', self.line_start + 8)
        while cpu.processorCycles < end:
            t = cpu.processorCycles - self.line_start
            if not rendered and t >= 20:
                self.render_line(line)
                rendered = True
            if nmi_at and cpu.processorCycles >= nmi_at[1]:
                kind = nmi_at[0]
                nmi_at = None
                en = self.hw[0x40E]
                if kind == 'vbi':
                    self.nmist = 0x40
                    if en & 0x40:
                        cpu.nmi()
                else:
                    self.nmist = 0x80
                    if en & 0x80:
                        cpu.nmi()
            pc = cpu.pc
            if self.trace_pc is not None:
                self.trace_pc.add(pc)
            h = self.hooks.get(pc)
            if h:
                h(self)
                continue
            cpu.step()
            if self.wsync:
                self.wsync = False
                ws = self.line_start + 105
                if cpu.processorCycles < ws:
                    cpu.processorCycles = ws
                elif cpu.processorCycles < end:
                    cpu.processorCycles = end + 105 - LINE  # rare: next line
        if not rendered:
            self.render_line(line)
        self.line_start = end
        self.line = (line + 1) % LINES

    # ------------------------------------------------------------ ANTIC
    def antic_line(self, line):
        """Advance the display list by one scanline. Returns True when a DLI
        is due on this line."""
        ram = self.mem.ram
        if line == 8:
            self.dl = dict(pc=self.reg(0xD402) | self.reg(0xD403) << 8,
                           left=0, mode=0, msc=0, row=0, ir=0, done=False)
        st = self.dl
        if st is None or line < 8 or line >= 248 or st['done'] \
                or not self.hw[0x400] & 0x20:
            self.cur = None
            return False
        if st['left'] == 0:                       # fetch an instruction
            pc = st['pc']
            ir = ram[pc]
            pc += 1
            mode = ir & 15
            if mode == 1:
                st['pc'] = ram[pc] | ram[pc + 1] << 8
                if ir & 0x40:                     # JVB: wait for VBI
                    st['done'] = True
                    self.cur = None
                    return bool(ir & 0x80)
                st['left'], st['mode'] = 1, 0
            elif mode == 0:
                st['left'], st['mode'] = ((ir >> 4) & 7) + 1, 0
                st['pc'] = pc
            else:
                if ir & 0x40:
                    st['msc'] = ram[pc] | ram[pc + 1] << 8
                    pc += 2
                elif 'bytes' in st:                 # after the last mode line
                    st['msc'] += st['bytes']
                st['pc'] = pc
                st['mode'] = mode
                st['bytes'] = MODE_BYTES[mode] * (4, 4, 5, 6)[self.hw[0x400] & 3] // 5
                st['left'] = MODE_LINES[mode]
            st['ir'] = ir
            st['row'] = 0
        else:
            st['row'] += 1
        st['left'] -= 1
        self.cur = (st['mode'], st['msc'], st['row'])
        return bool(st['ir'] & 0x80) and st['left'] == 0

    # ------------------------------------------------------------ GTIA
    def render_line(self, line):
        out = self.img[line]
        hw = self.hw
        bak = hw[0x1A]
        out[:] = bak
        cur = getattr(self, 'cur', None)
        if line < 8 or line >= 248:
            return
        if cur and cur[0]:
            self.draw_playfield(out, *cur)
        self.draw_pm(out, line)

    def draw_playfield(self, out, mode, msc, row):
        ram = self.mem.ram
        hw = self.hw
        pf = [hw[0x1A], hw[0x16], hw[0x17], hw[0x18], hw[0x19]]
        width = self.hw[0x400] & 3
        nbytes = MODE_BYTES[mode] * (4, 4, 5, 6)[width] // 5
        x0 = {1: 64, 2: 32, 3: 16}.get(width, 32)       # pixel of byte 0
        data = ram[msc:msc + nbytes] if msc + nbytes <= 0x10000 else bytes(nbytes)
        chb = hw[0x409]
        chactl = hw[0x401]
        data = bytes(data)
        if chb >= 0xC0 and self.portb & 1 and not 0xD0 <= chb < 0xD8:
            ram = b'\0' * 0xC000 + self.rom      # font in the OS ROM
        px = []
        if mode in (2, 3):
            base = (chb & 0xFE) << 8
            hi = (pf[3] & 0xF0) | (pf[2] & 0x0F)
            for c in data:
                r = row if mode == 2 else (row if row < 8 else 0)
                g = ram[(base + (c & 0x7F) * 8 + r) & 0xFFFF]
                if c & 0x80 and chactl & 2:
                    g ^= 0xFF
                for b in range(7, -1, -1):
                    px.append(hi if g >> b & 1 else pf[3])
            scale = 1
        elif mode in (4, 5):
            base = (chb & 0xFE) << 8
            r = row if mode == 4 else row >> 1
            for c in data:
                g = ram[(base + (c & 0x7F) * 8 + r) & 0xFFFF]
                for b in (6, 4, 2, 0):
                    v = g >> b & 3
                    col = pf[0] if v == 0 else pf[v] if v < 3 else (pf[4] if c & 0x80 else pf[3])
                    px += [col, col]
            scale = 1
        elif mode in (6, 7):
            base = (chb & 0xFE) << 8
            r = row if mode == 6 else row >> 1
            for c in data:
                g = ram[(base + (c & 0x3F) * 8 + r) & 0xFFFF]
                col = pf[1 + (c >> 6)]
                for b in range(7, -1, -1):
                    px.append(col if g >> b & 1 else pf[0])
            scale = 2
        elif mode in (8, 10, 13, 14):           # 4-colour bitmaps
            w = {8: 4, 10: 2, 13: 1, 14: 1}[mode]
            for c in data:
                for b in (6, 4, 2, 0):
                    px += [pf[c >> b & 3]] * w
            scale = 2
        else:                                   # 2-colour bitmaps
            if mode == 15:
                hi = (pf[3] & 0xF0) | (pf[2] & 0x0F)
                for c in data:
                    for b in range(7, -1, -1):
                        px.append(hi if c >> b & 1 else pf[3])
                scale = 1
            else:
                w = {9: 4, 11: 2, 12: 2}[mode]
                for c in data:
                    for b in range(7, -1, -1):
                        px += [pf[1] if c >> b & 1 else pf[0]] * w
                scale = 2
        arr = np.array(px, np.uint8)
        if scale == 2:
            arr = np.repeat(arr, 2)
        n = min(len(arr), 384 - x0)
        out[x0:x0 + n] = arr[:n]

    def draw_pm(self, out, line):
        """Players and missiles. With DMA on, the bytes come from PMBASE;
        with DMA off, from GRAFP0-3/GRAFM as the program last wrote them."""
        hw = self.hw
        dmactl = hw[0x400]
        gractl = hw[0x01D]
        ram = self.mem.ram
        single = dmactl & 0x10
        base = hw[0x407] << 8
        y = line if single else line >> 1
        if single:
            base &= 0xF800
            mbase, pstep = base + 0x300, 0x100
        else:
            base &= 0xFC00
            mbase, pstep = base + 0x180, 0x80
        if gractl & 1:
            m = ram[mbase + y] if dmactl & 4 else 0
            hw[0x011] = m
        m = hw[0x011]
        sm = hw[0x00C]
        for i in range(4):
            bits = m >> (2 * i) & 3
            if not bits:
                continue
            w = (1, 2, 1, 4)[sm >> (2 * i) & 3]
            x = hw[0x004 + i]
            for k, bit in enumerate((2, 1)):
                if bits & bit:
                    xs = (x + k * w - 32) * 2
                    out[max(0, xs):max(0, xs + 2 * w)] = hw[0x012 + i]
        for i in (3, 2, 1, 0):                  # player 0 on top
            if gractl & 2:
                hw[0x00D + i] = ram[mbase + pstep * (i + 1) + y] if dmactl & 8 else 0
            g = hw[0x00D + i]
            if not g:
                continue
            w = (1, 2, 1, 4)[hw[0x008 + i] & 3]
            x = hw[0x000 + i]
            col = hw[0x012 + i]
            for b in range(8):
                if g >> (7 - b) & 1:
                    xs = (x + b * w - 32) * 2
                    if xs < 384:
                        out[max(0, xs):max(0, xs + 2 * w)] = col

    def screenshot(self, path=None, scale=2):
        from PIL import Image
        rgb = PAL[self.img[16:248]]
        im = Image.fromarray(rgb, 'RGB')
        im = im.resize((384 * scale // 2 * 2, 232 * scale), Image.NEAREST)
        if path:
            im.save(path)
        return im

    # ------------------------------------------------------------ input
    def key(self, code):
        """Press a key: put its keyboard code into CH, as the OS IRQ would."""
        self.mem.ram[0x2FC] = code
