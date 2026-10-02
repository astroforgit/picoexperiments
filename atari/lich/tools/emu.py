#!/usr/bin/env python3
"""Headless Atari + VBXE emulator for testing the Lich King port
(adapted from the Celeste port: OS-off NMI, blitter dest step x).

py65 runs the 6502; this module emulates just enough of the machine:
the OS vertical blank (RTCLOK, deferred VBI vector, XITVBV), joystick
shadow registers, POKEY writes, and VBXE's MEMAC window, palette,
blitter (modes 0/1, steps, flips) and XDL for screenshots.

    from emu import Atari
    a = Atari('celeste.xex'); a.boot()
    a.run_frames(100); a.screenshot('shot.png')
"""
from pathlib import Path
import numpy as np
from py65.devices.mpu6502 import MPU

FRAME_CYCLES = 32760        # PAL frame minus refresh with ANTIC DMA off
XITVBV = 0xE462
SETVBV = 0xE45C
CIOV = 0xE456


class Mem:
    def __init__(self, atari):
        self.a = atari
        self.ram = bytearray(65536)

    def __getitem__(self, addr):
        if 0x9000 <= addr < 0xA000:
            a = self.a
            if a.memac_on():
                return int(a.vram[(a.bank & 0x7f) * 4096 + addr - 0x9000])
        elif 0xD000 <= addr < 0xD800:
            return self.a.io_read(addr)
        return self.ram[addr]

    def __setitem__(self, addr, value):
        if 0x9000 <= addr < 0xA000:
            a = self.a
            if a.memac_on():
                a.vram[(a.bank & 0x7f) * 4096 + addr - 0x9000] = value
                return
        elif 0xD000 <= addr < 0xD800:
            self.a.io_write(addr, value)
            return
        self.ram[addr] = value


class Atari:
    def __init__(self, xex, pal=True, vbxe_page=0xD6):
        self.xex = Path(xex).read_bytes()
        self.mem = Mem(self)
        self.cpu = MPU(memory=self.mem)
        # real VBXE memory powers up with junk; so does Altirra's
        self.vram = np.random.default_rng(1).integers(0, 256, 512 * 1024, dtype=np.uint8)
        self.vregs = bytearray(256)
        self.vbxe_page = vbxe_page
        self.bank = 0
        self.memc = 0
        self.palette = np.zeros((4, 256, 3), dtype=np.uint8)
        self.csel = 0
        self.psel = 0
        self.pal = pal
        self.pokey = bytearray(16)
        self.mem.ram[0xD301] = 0xFF        # PORTB: OS ROM on
        self.pokey_log = []
        self.frame = 0
        self.next_frame = FRAME_CYCLES
        self.in_vbi = False
        self.blits = 0
        self.blit_pixels = 0
        self.frame_blits = 0
        self.consol = 7
        self.skstat = 0xFF
        self.kbcode = 0xFF
        self.random = 0x5A
        self.xdl_writes = []
        self.blit_busy_until = 0
        self.blit_model = True  # VBXE memory: 1 access per 14.18 MHz clock

    # ------------------------------------------------------------ I/O
    def memac_on(self):
        return (self.memc & 0x08) and (self.bank & 0x80)

    def io_read(self, addr):
        page = addr >> 8
        if page == self.vbxe_page:
            reg = addr & 0xFF
            if reg == 0x40:
                return 0x10                 # FX core
            if reg == 0x53:
                return 1 if self.cpu.processorCycles < self.blit_busy_until else 0
            return self.vregs[reg]
        if addr == 0xD40F:
            return 0x40                     # NMIST: vertical blank
        if addr == 0xD014:
            return 1 if self.pal else 15
        if addr == 0xD01F:
            return self.consol
        if addr == 0xD20A:
            self.random = (self.random * 73 + 41) & 0xFF
            return self.random
        if addr == 0xD20F:
            return self.skstat
        if addr == 0xD209:
            return self.kbcode
        if addr == 0xD010:
            return self.mem.ram[0x284]
        if addr == 0xD300:
            return self.mem.ram[0x278] | 0xF0
        return self.mem.ram[addr]

    def io_write(self, addr, value):
        page = addr >> 8
        if page == self.vbxe_page:
            reg = addr & 0xFF
            self.vregs[reg] = value
            if reg == 0x5E:
                self.memc = value
            elif reg == 0x5F:
                self.bank = value
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
                self.xdl_writes.append((self.frame, reg, value))
            return
        if 0xD200 <= addr < 0xD210:
            self.pokey[addr & 15] = value
            return
        self.mem.ram[addr] = value

    # ------------------------------------------------------------ blitter
    def run_blitter(self):
        accesses = self.blit_list()
        if self.blit_model:
            # 8 VBXE clocks per 1.77 MHz CPU cycle
            self.blit_busy_until = self.cpu.processorCycles + accesses // 8

    def blit_list(self):
        """Execute the list; return the number of VBXE memory accesses."""
        accesses = 0
        v = self.vregs
        addr = v[0x50] | (v[0x51] << 8) | ((v[0x52] & 7) << 16)
        vram = self.vram
        while True:
            b = vram[addr:addr + 21].astype(np.int64)
            src = int(b[0] | (b[1] << 8) | ((b[2] & 7) << 16))
            ssy = int(b[3] | (b[4] << 8)); ssy = ssy if ssy < 32768 else ssy - 65536
            ssx = int(b[5]); ssx = ssx - 256 if ssx >= 128 else ssx
            dst = int(b[6] | (b[7] << 8) | ((b[8] & 7) << 16))
            dsy = int(b[9] | (b[10] << 8)); dsy = dsy if dsy < 32768 else dsy - 65536
            dsx = int(b[11]); dsx = dsx - 256 if dsx >= 128 else dsx
            w = int(b[12] | ((b[13] & 1) << 8)) + 1
            h = int(b[14]) + 1
            andm, xorm = int(b[15]), int(b[16])
            zoom = int(b[18])
            ctrl = int(b[20])
            mode = ctrl & 7
            assert zoom == 0 and int(b[19]) == 0, f'zoom/pattern not as programmed at ${addr:05x}'
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
                raise AssertionError(f'blitter mode {mode} not emulated')
            self.blits += 1
            self.frame_blits += 1
            self.blit_pixels += w * h
            if not ctrl & 8:
                break
            addr += 21
        return accesses

    # ------------------------------------------------------------ loading
    def call(self, addr, limit=5_000_000):
        cpu = self.cpu
        cpu.sp = 0xFF
        cpu.stPushWord(0xFFFF - 1)       # RTS lands at $FFFF
        cpu.pc = addr
        for _ in range(limit):
            if cpu.pc == 0xFFFF:
                return
            self.step()
        raise AssertionError(f'call ${addr:04x} did not return (pc=${cpu.pc:04x})')

    def boot(self):
        d = self.xex
        p = 0
        run = None
        ram = self.mem.ram
        # OS defaults a loaded program relies on
        ram[0x0224] = XITVBV & 255
        ram[0x0225] = XITVBV >> 8
        self.set_input()                # sticks centred, triggers released
        while p < len(d):
            s = int.from_bytes(d[p:p + 2], 'little'); p += 2
            if s == 0xFFFF:
                continue
            e = int.from_bytes(d[p:p + 2], 'little'); p += 2
            chunk = d[p:p + e - s + 1]; p += e - s + 1
            if s == 0x2E2:
                self.call(int.from_bytes(chunk, 'little'))
            elif s == 0x2E0:
                run = int.from_bytes(chunk, 'little')
            else:
                for i, b in enumerate(chunk):
                    self.mem[s + i] = b
        assert run is not None
        cpu = self.cpu
        cpu.sp = 0xFF
        cpu.pc = run
        self.next_frame = cpu.processorCycles + FRAME_CYCLES

    # ------------------------------------------------------------ running
    def step(self):
        cpu = self.cpu
        pc = cpu.pc
        if pc == SETVBV:
            ram = self.mem.ram
            if cpu.a == 7:
                ram[0x224] = cpu.y
                ram[0x225] = cpu.x
            else:
                ram[0x222] = cpu.y
                ram[0x223] = cpu.x
            cpu.pc = cpu.stPopWord() + 1
            return
        if pc == CIOV:
            cpu.pc = cpu.stPopWord() + 1
            return
        if pc == XITVBV:
            cpu.y = cpu.stPop()
            cpu.x = cpu.stPop()
            cpu.a = cpu.stPop()
            cpu.p = cpu.stPop()
            cpu.pc = cpu.stPopWord()
            self.in_vbi = False
            return
        cpu.step()

    def vblank(self):
        """OS VBI: RTCLOK, then the deferred vector (if the CPU allows)."""
        ram = self.mem.ram
        ram[0x14] = (ram[0x14] + 1) & 255
        if ram[0x14] == 0:
            ram[0x13] = (ram[0x13] + 1) & 255
        self.frame += 1
        cpu = self.cpu
        os_off = not (ram[0xD301] & 1)
        if os_off:
            if self.mem.ram[0xD40E] & 0x40 == 0:
                return
            vec = ram[0xFFFA] | (ram[0xFFFB] << 8)
            cpu.stPushWord(cpu.pc)
            cpu.stPush(cpu.p)
            cpu.p |= 0x04
            cpu.pc = vec
            self.pokey_log.append(bytes(self.pokey))
            return
        vec = ram[0x224] | (ram[0x225] << 8)
        if self.in_vbi:
            return
        self.in_vbi = True
        cpu.stPushWord(cpu.pc)
        cpu.stPush(cpu.p)
        cpu.stPush(cpu.a)
        cpu.stPush(cpu.x)
        cpu.stPush(cpu.y)
        cpu.pc = vec
        self.pokey_log.append(bytes(self.pokey))

    def run_frames(self, n, inputs=None):
        """Run n TV frames. inputs(frame) -> dict(stick=0..15, trig=0/1, dash=0/1)."""
        cpu = self.cpu
        end = self.frame + n
        while self.frame < end:
            if inputs:
                self.set_input(**inputs(self.frame))
            target = self.next_frame
            while cpu.processorCycles < target:
                self.step()
            self.next_frame += FRAME_CYCLES
            self.vblank()

    def set_input(self, stick=15, trig=0, dash=0):
        ram = self.mem.ram
        ram[0x278] = stick
        ram[0x284] = 0 if trig else 1
        ram[0x285] = 1
        self.skstat = 0xF7 if dash else 0xFF   # dash = SHIFT
        ram[0x270] = 228
        ram[0x271] = 228

    # ------------------------------------------------------------ video
    def screenshot(self, path=None, scale=2):
        """Render the XDL display (LR/SR graphics lines) to an RGB image."""
        from PIL import Image
        v = self.vregs
        xdl = v[0x41] | (v[0x42] << 8) | ((v[0x43] & 7) << 16)
        vram = self.vram
        lines = []
        ov_on = False
        addr = step = 0
        lr = False
        width = 320
        p = xdl
        for _ in range(256):
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
                w = int(vram[p]) & 3
                width = {0: 256, 1: 320, 2: 336}[w]
                p += 2
            if c0 & 0x02:
                ov_on = True
                lr = bool(c1 & 0x20)
            if c0 & 0x04:
                ov_on = False
            for _ in range(rpt + 1):
                if ov_on:
                    n = width // 2 if lr else width
                    row = vram[(addr + np.arange(n)) & 0x7FFFF]
                    if lr:
                        row = np.repeat(row, 2)
                    lines.append(row)
                    addr += step
                else:
                    lines.append(np.zeros(width, dtype=np.uint8))
            if c1 & 0x80 or len(lines) >= 240:
                break
        maxw = max(len(r) for r in lines)
        img = np.zeros((len(lines), maxw), dtype=np.uint8)
        for y, r in enumerate(lines):
            img[y, (maxw - len(r)) // 2:(maxw - len(r)) // 2 + len(r)] = r
        rgb = self.palette[1][img]
        rgb[img == 0] = 0                    # transparent -> COLBAK black
        im = Image.fromarray(rgb, 'RGB')
        if scale > 1:
            im = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
        if path:
            im.save(path)
        return im

    def label(self, name, labels):
        return labels[name.upper()]


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
