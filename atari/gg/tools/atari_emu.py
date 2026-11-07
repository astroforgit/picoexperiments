#!/usr/bin/env python3
"""Headless Atari XL/XE + VBXE FX model for testing the Ghosts'n Goblins port.

Adapted from atari/lair/tools/emu.py. py65 runs the 6502. Modelled:
MEMAC-A (any base/size) and MEMAC-B, PORTB (OS ROM off = RAM), ANTIC NMI
(VBI through $FFFA when the OS is off), POKEY input/keyboard registers,
GTIA triggers/console, and the VBXE palette, XDL and blitter (modes 0/1,
AND/XOR masks, signed steps) with a busy-time model.

No OS ROM image is used: XEX segments are written straight to memory and
INIT routines must not call the OS (the boot code never does).
"""
import os
from pathlib import Path
import numpy as np
from py65.devices.mpu6502 import MPU

# blitter VRAM accesses per CPU cycle (GNG_BLIT_RATE; real VBXE: fewer, the display shares VRAM)
BLIT_RATE = float(os.environ.get('GNG_BLIT_RATE', '8'))
PAL_FRAME = 312 * 114 - 312 * 9      # ANTIC DMA off: only refresh cycles stolen
NTSC_FRAME = 262 * 114 - 262 * 9


class Mem:
    def __init__(self, a):
        self.a = a
        self.ram = bytearray(65536)

    def _window(self, addr):
        a = self.a
        if a.mems & 0x80 and a.memc & 0x08:
            base = (a.memc >> 4) << 12
            size = 0x1000 << (a.memc & 3)
            if base <= addr < base + size and addr < 0x10000:
                shift = 12 + (a.memc & 3)
                bank = (a.mems & 0x7F) >> (a.memc & 3)
                return ((bank << shift) + (addr - base)) & 0x7FFFF
        if a.memb & 0x80 and 0x4000 <= addr < 0x8000:
            return ((a.memb & 0x1F) << 14) + (addr - 0x4000)
        return None

    def __getitem__(self, addr):
        if 0xD000 <= addr < 0xD800:
            return self.a.io_read(addr)
        w = self._window(addr)
        if w is not None:
            return int(self.a.vram[w])
        return self.ram[addr]

    def __setitem__(self, addr, value):
        if 0xD000 <= addr < 0xD800:
            self.a.io_write(addr, value)
            return
        w = self._window(addr)
        if w is not None:
            self.a.vram[w] = value
            self.a.memac_writes += 1
            return
        self.ram[addr] = value


class Atari:
    def __init__(self, xex, pal=True, vbxe_page=0xD6):
        self.xex = Path(xex).read_bytes()
        self.mem = Mem(self)
        self.cpu = MPU(memory=self.mem)
        self.vram = np.random.default_rng(1).integers(0, 256, 512 * 1024, dtype=np.uint8)
        self.vregs = bytearray(256)
        self.vbxe_page = vbxe_page
        self.memc = 0
        self.mems = 0
        self.memb = 0
        self.memac_writes = 0
        self.palette = np.zeros((4, 256, 3), dtype=np.uint8)
        self.csel = 0
        self.psel = 0
        self.pal = pal
        self.frame_cycles = PAL_FRAME if pal else NTSC_FRAME
        self.pokey = bytearray(16)
        self.pokey_log = []
        self.portb = 0xFF
        self.nmien = 0
        self.nmist = 0
        self.frame = 0
        self.next_frame = self.frame_cycles
        self.blits = 0
        self.blit_busy_until = 0
        self.consol = 7
        self.skstat = 0xFF
        self.kbcode = 0xFF
        self.in_stick = 15
        self.in_stick1 = 15
        self.in_trig0 = 1
        self.in_trig1 = 1
        self.in_pot = [228, 228]
        self.random = 0x5A
        self.xdl_addr_log = []
        self.nmi_count = 0
        self.dlist = 0
        self.dmactl = 0
        self.dli_count = 0
        self.irqen = 0
        self.irqst = 0xFF
        self.last_key = None
        self.busy_at_vbi = []
        self.idle_pc = None

    # ------------------------------------------------------------ I/O
    def io_read(self, addr):
        page = addr >> 8
        if page == self.vbxe_page:
            reg = addr & 0xFF
            if reg == 0x40:
                return 0x10                 # FX core
            if reg == 0x41:
                return 0x26                 # minor revision 1.26
            if reg == 0x53:
                return 1 if self.cpu.processorCycles < self.blit_busy_until else 0
            if reg == 0x5E:
                return self.memc
            if reg == 0x5F:
                return self.mems
            if reg == 0x5D:
                return 0xFF
            return self.vregs[reg]
        if page in (0xD6, 0xD7):
            return 0xFF
        if addr == 0xD40F:
            return self.nmist
        if addr == 0xD40B:                  # VCOUNT
            # the frame starts at the VBI (scanline 248); VCOUNT = scanline / 2
            lines = 312 if self.pal else 262
            per = self.frame_cycles / lines
            c = int((self.cpu.processorCycles - (self.next_frame - self.frame_cycles)) / per)
            return ((c + 248) % lines) // 2
        if addr == 0xD014:
            return 1 if self.pal else 15
        if addr == 0xD01F:
            return self.consol
        if addr == 0xD20A:
            self.random = (self.random * 73 + 41) & 0xFF
            return self.random
        if addr == 0xD20F:
            return self.skstat
        if addr == 0xD20E:
            return self.irqst
        if addr == 0xD209:
            return self.kbcode
        if addr in (0xD200, 0xD201):
            return self.in_pot[addr & 1]
        if addr == 0xD010:
            return self.in_trig0
        if addr == 0xD011:
            return self.in_trig1
        if addr == 0xD300:
            return self.in_stick | (self.in_stick1 << 4)
        if addr == 0xD301:
            return self.portb
        return 0xFF

    def io_write(self, addr, value):
        page = addr >> 8
        if page == self.vbxe_page:
            reg = addr & 0xFF
            self.vregs[reg] = value
            if reg == 0x5E:
                self.memc = value
            elif reg == 0x5F:
                self.mems = value
            elif reg == 0x5D:
                self.memb = value
            elif reg == 0x44:
                self.csel = value
            elif reg == 0x45:
                self.psel = value & 3
            elif reg in (0x46, 0x47, 0x48):
                self.palette[self.psel, self.csel, reg - 0x46] = value
                if reg == 0x48:
                    self.csel = (self.csel + 1) & 0xFF
            elif reg == 0x53 and value & 1:
                self.run_blitter()
            elif reg in (0x41, 0x42, 0x43):
                self.xdl_addr_log.append((self.frame, reg, value))
            return
        if 0xD200 <= addr < 0xD210:
            self.pokey[addr & 15] = value
            if addr == 0xD20E:
                self.irqen = value
                self.irqst |= ~value & 0xFF   # disabled sources read as idle
            return
        if addr == 0xD301:
            self.portb = value
            return
        if addr == 0xD40E:
            self.nmien = value
            return
        if addr == 0xD402:
            self.dlist = (self.dlist & 0xFF00) | value
            return
        if addr == 0xD403:
            self.dlist = (self.dlist & 0xFF) | value << 8
            return
        if addr == 0xD400:
            self.dmactl = value
            return
        if addr == 0xD40F:
            self.nmist = 0
            return

    # ------------------------------------------------------------ blitter
    def run_blitter(self):
        if self.cpu.processorCycles < self.blit_busy_until:
            raise AssertionError('blitter started while busy')
        accesses = self.blit_list()
        self.blit_busy_until = self.cpu.processorCycles + int(accesses / BLIT_RATE)

    def blit_list(self):
        accesses = 0
        v = self.vregs
        addr = v[0x50] | (v[0x51] << 8) | ((v[0x52] & 7) << 16)
        vram = self.vram
        for _ in range(4096):
            b = vram[addr:addr + 21].astype(np.int64)
            src = int(b[0] | (b[1] << 8) | ((b[2] & 7) << 16))
            ssy = int(b[3] | (b[4] << 8)) & 0x1FFF
            ssy = ssy - 0x2000 if ssy >= 0x1000 else ssy
            ssx = int(b[5]); ssx = ssx - 256 if ssx >= 128 else ssx
            dst = int(b[6] | (b[7] << 8) | ((b[8] & 7) << 16))
            dsy = int(b[9] | (b[10] << 8)) & 0x1FFF
            dsy = dsy - 0x2000 if dsy >= 0x1000 else dsy
            dsx = int(b[11]); dsx = dsx - 256 if dsx >= 128 else dsx
            w = int(b[12] | ((b[13] & 1) << 8)) + 1
            h = int(b[14]) + 1
            andm, xorm = int(b[15]), int(b[16])
            zoom, patt = int(b[18]), int(b[19])
            ctrl = int(b[20])
            mode = ctrl & 7
            assert zoom == 0 and patt == 0, f'zoom/pattern used at ${addr:05x}'
            ys = np.arange(h)[:, None]
            xs = np.arange(w)[None, :]
            si = (src + ys * ssy + xs * ssx) & 0x7FFFF
            di = (dst + ys * dsy + xs * dsx) & 0x7FFFF
            s = (vram[si] & andm) ^ xorm
            accesses += 21
            if mode == 0:
                vram[di] = s
                accesses += w * h * (1 if andm == 0 else 2)
            elif mode == 1:
                m = s != 0
                vram[di[m]] = s[m]
                accesses += (w * h if andm else 0) + int(m.sum())
            else:
                raise AssertionError(f'blitter mode {mode}')
            self.blits += 1
            if not ctrl & 8:
                break
            addr += 21
        else:
            raise AssertionError('blitter list did not terminate')
        return accesses

    # ------------------------------------------------------------ loading
    def call(self, addr, limit=20_000_000):
        cpu = self.cpu
        cpu.sp = 0xFF
        cpu.stPushWord(0xFFFF - 1)
        cpu.pc = addr
        for _ in range(limit):
            if cpu.pc == 0xFFFF:
                return
            cpu.step()
        raise AssertionError(f'INIT ${addr:04x} did not return (pc=${cpu.pc:04x})')

    def boot(self):
        d = self.xex
        p = 0
        run = None
        while p < len(d):
            s = int.from_bytes(d[p:p + 2], 'little'); p += 2
            if s == 0xFFFF:
                continue
            e = int.from_bytes(d[p:p + 2], 'little'); p += 2
            chunk = d[p:p + e - s + 1]; p += e - s + 1
            for i, b in enumerate(chunk):
                self.mem[s + i] = b
            if s <= 0x2E2 <= e:
                self.call(self.mem.ram[0x2E2] | self.mem.ram[0x2E3] << 8)
                self.mem.ram[0x2E2] = self.mem.ram[0x2E3] = 0
            if s <= 0x2E0 <= e:
                run = self.mem.ram[0x2E0] | self.mem.ram[0x2E1] << 8
        assert run is not None, 'no RUN address'
        self.cpu.sp = 0xFF
        self.cpu.pc = run
        self.next_frame = self.cpu.processorCycles + self.frame_cycles

    # ------------------------------------------------------------ running
    def vblank(self):
        self.frame += 1
        cpu = self.cpu
        if self.nmien & 0x40:
            self.nmist = 0x40
            vec = self.mem.ram[0xFFFA] | (self.mem.ram[0xFFFB] << 8)
            cpu.stPushWord(cpu.pc)
            cpu.stPush((cpu.p | 0x20) & ~0x10)
            cpu.p |= 0x04
            cpu.pc = vec
            self.nmi_count += 1
        self.pokey_log.append(bytes(self.pokey))

    def dli_lines(self):
        """Scanlines (8..247) after which the display list requests a DLI."""
        if not (self.dmactl & 0x20 and self.nmien & 0x80):
            return []
        out, line, p = [], 8, self.dlist
        for _ in range(240):
            ins = self.mem.ram[p]
            p += 1
            if ins & 0x0F == 1:          # jump (JVB ends the frame)
                if ins & 0x40:
                    break
                p = self.mem.ram[p] | self.mem.ram[p + 1] << 8
                continue
            if ins & 0x0F == 0:
                n = ((ins >> 4) & 7) + 1
            else:
                raise AssertionError('only blank lines are modelled')
            line += n
            if ins & 0x80:
                out.append(line - 1)
            if line >= 248:
                break
        return out

    def run_until(self, target):
        cpu = self.cpu
        while cpu.processorCycles < target:
            if not self.irqst & 0x40 and self.irqen & 0x40 and not cpu.p & 0x04:
                cpu.stPushWord(cpu.pc)
                cpu.stPush((cpu.p | 0x20) & ~0x10)
                cpu.p |= 0x04
                cpu.pc = self.mem.ram[0xFFFE] | self.mem.ram[0xFFFF] << 8
            cpu.step()

    def run_frames(self, n, inputs=None):
        cpu = self.cpu
        end = self.frame + n
        lines_per = self.frame_cycles / (312 if self.pal else 262)
        vbl_lines = (312 if self.pal else 262) - 248
        while self.frame < end:
            if inputs:
                self.set_input(**inputs(self.frame))
            start = self.next_frame - self.frame_cycles
            if not self.irqst & 0x40 and self.irqen & 0x40 and not cpu.p & 0x04:
                cpu.stPushWord(cpu.pc)
                cpu.stPush((cpu.p | 0x20) & ~0x10)
                cpu.p |= 0x04
                cpu.pc = self.mem.ram[0xFFFE] | self.mem.ram[0xFFFF] << 8
            # the display list is read when the frame's display starts (line 8)
            self.run_until(start + int((vbl_lines + 8) * lines_per))
            for line in self.dli_lines():
                self.run_until(start + int((vbl_lines + line + 1) * lines_per))
                self.nmist = 0x80
                cpu.stPushWord(cpu.pc)
                cpu.stPush((cpu.p | 0x20) & ~0x10)
                cpu.p |= 0x04
                cpu.pc = self.mem.ram[0xFFFA] | self.mem.ram[0xFFFB] << 8
                self.dli_count += 1
            self.run_until(self.next_frame)
            self.next_frame += self.frame_cycles
            self.vblank()

    def set_input(self, stick=15, trig=0, trig1=0, consol=7, key=None, shift=False, pot=0, stick1=15):
        self.in_stick = stick
        self.in_stick1 = stick1
        self.in_trig0 = 0 if trig else 1
        self.in_trig1 = 0 if trig1 else 1
        self.consol = consol
        self.in_pot = [1 if pot & 1 else 228, 1 if pot & 2 else 228]
        sk = 0xFF
        if shift:
            sk &= ~0x08
        if key is not None:
            sk &= ~0x04
            self.kbcode = key
            if key != self.last_key and self.irqen & 0x40:
                self.irqst &= ~0x40          # keyboard IRQ pending
        self.last_key = key
        self.skstat = sk

    # ------------------------------------------------------------ video
    def screenshot(self, path=None, scale=2):
        from PIL import Image
        v = self.vregs
        xdl = v[0x41] | (v[0x42] << 8) | ((v[0x43] & 7) << 16)
        vram = self.vram
        lines = []
        ov_on = False
        addr = step = 0
        width = 320
        pal_sel = 1
        p = xdl
        for _ in range(512):
            c0, c1 = int(vram[p]), int(vram[p + 1]); p += 2
            rpt = 0
            if c0 & 0x20:
                rpt = int(vram[p]); p += 1
            if c0 & 0x40:
                addr = int(vram[p]) | int(vram[p + 1]) << 8 | (int(vram[p + 2]) & 7) << 16
                step = int(vram[p + 3]) | (int(vram[p + 4]) & 15) << 8
                p += 5
            if c0 & 0x80:
                p += 2
            if c1 & 0x01:
                p += 1
            if c1 & 0x02:
                p += 5
            if c1 & 0x04:
                p += 4
            if c1 & 0x08:
                a0 = int(vram[p])
                width = {0: 256, 1: 320, 2: 336}.get(a0 & 3, 320)
                pal_sel = (a0 >> 4) & 3
                p += 2
            if c0 & 0x02:
                ov_on = True
            if c0 & 0x04:
                ov_on = False
            for _ in range(rpt + 1):
                if ov_on:
                    row = vram[(addr + np.arange(width)) & 0x7FFFF]
                    lines.append((row, pal_sel))
                    addr += step
                else:
                    lines.append((np.zeros(width, dtype=np.uint8), pal_sel))
            if c1 & 0x80 or len(lines) >= 240:
                break
        h = len(lines)
        maxw = max(len(r) for r, _ in lines)
        rgb = np.zeros((h, maxw, 3), dtype=np.uint8)
        for y, (r, ps) in enumerate(lines):
            x0 = (maxw - len(r)) // 2
            rgb[y, x0:x0 + len(r)] = self.palette[ps][r]
            rgb[y, x0:x0 + len(r)][r == 0] = 0
        im = Image.fromarray(rgb, 'RGB')
        if scale > 1:
            im = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
        if path:
            im.save(path)
        return im


def load_labels(path):
    labels = {}
    for line in Path(path).read_text().splitlines():
        parts = line.split()
        if len(parts) == 3:
            try:
                labels[parts[2].upper()] = int(parts[1], 16)
            except ValueError:
                pass
    return labels
