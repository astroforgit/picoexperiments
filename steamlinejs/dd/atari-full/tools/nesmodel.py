#!/usr/bin/env python3
"""Reference model: the translated banks running on a modelled NES platform.

The services implement the behaviour the Atari runtime must reproduce.
Used for screenshots, coverage traces and relocation checks; it is not an
emulator of the Atari runtime itself.
"""
from collections import defaultdict
from pathlib import Path
import json
import sys
from py65.devices.mpu6502 import MPU

ROOT = Path(__file__).resolve().parents[1]
GEN = ROOT / 'gen'
sys.path.insert(0, str(ROOT / 'tools'))
from translate import SERVICES, vector, RAM_SYMBOLS  # noqa: E402

FRAME = 29780
SNES_SRC = ROOT.parent / 'double-dragon-snes-main/double-dragon-snes-main/src'


def load_labels(path):
    out = {}
    for line in Path(path).read_text().splitlines():
        p = line.split()
        if len(p) == 3:
            try:
                out[p[2]] = int(p[1], 16)
            except ValueError:
                pass
    return out


class Memory:
    def __init__(self, m):
        self.m = m
        self.ram = bytearray(0x8000)
        self.banks = [bytearray((GEN / f'bank{i}.bin').read_bytes()) for i in range(8)]
        self.bank = 6
        self.poison = None          # (lo, hi): bank-7 range that must never be touched
        self.reads = None           # optional data-read tracer

    def __getitem__(self, a):
        if a < 0x8000:
            if a == RAM_SYMBOLS['RDNMI']:
                return 0x80
            return self.ram[a]
        if a < 0xC000:
            v = self.banks[self.bank][a - 0x8000]
            b = self.bank
        else:
            if self.poison and self.poison[0] <= a < self.poison[1]:
                raise RuntimeError(f'access to relocated range ${a:04x} from pc ${self.m.cpu.pc:04x}')
            v = self.banks[7][a - 0xC000]
            b = 7
        if self.reads is not None:
            self.reads[(self.m.cur_bank, self.m.cpu.pc)].add((b, a))
        return v

    def __setitem__(self, a, v):
        if a >= 0x8000:
            raise RuntimeError(f'ROM write ${a:04x}=${v:02x} at pc ${self.m.cpu.pc:04x}')
        self.ram[a] = v
        self.m.writes += 1


class PPU:
    """NES video memory with MMC1 mirroring; enough for nametables and palette."""
    def __init__(self):
        self.nt = [bytearray(0x400), bytearray(0x400)]   # physical nametables A, B
        self.pal = bytearray(32)
        self.addr = 0
        self.inc = 1
        self.mirror = 3          # MMC1 control & 3: 2 vertical, 3 horizontal
        self.dirty_frames = 0

    def phys(self, a):
        a &= 0x0FFF
        n = a >> 10
        if self.mirror == 3:
            p = n >> 1
        elif self.mirror == 2:
            p = n & 1
        else:
            p = self.mirror & 1
        return self.nt[p], a & 0x3FF

    def write(self, a, v):
        a &= 0x3FFF
        if a >= 0x3F00:
            i = a & 31
            if i & 3 == 0:
                i &= 0x0F       # $3F10/14/18/1C mirror $3F00/04/08/0C
            self.pal[i] = v & 0x3F
        elif a >= 0x2000:
            t, o = self.phys(a)
            t[o] = v
        # pattern-table writes ($0000-$1FFF) go to CHR ROM: ignored

    def read(self, a):
        a &= 0x3FFF
        if a >= 0x3F00:
            i = a & 31
            if i & 3 == 0:
                i &= 0x0F
            return self.pal[i]
        if a >= 0x2000:
            t, o = self.phys(a)
            return t[o]
        return 0


class Machine:
    def __init__(self, atari=False):
        self.writes = 0
        self.cur_bank = 7
        self.mem = Memory(self)
        if atari:
            # the Atari layout: patched banks, block relocated to RAM, old range poisoned
            for b in (6, 7):
                self.mem.banks[b] = bytearray((GEN / f'bank{b}-atari.bin').read_bytes())
            blk = (GEN / 'reloc.bin').read_bytes()
            self.mem.ram[0x3000:0x3000 + len(blk)] = blk
            self.mem.poison = (0xCFA1, 0xD80F)
        self.cpu = MPU(memory=self.mem)
        self.ppu = PPU()
        self.labels = load_labels(GEN / 'bank7.lab')
        self.svc = {vector(n): n for n in SERVICES}
        self.buttons = 0
        self.frames = 0
        self.next_nmi = FRAME
        self.nmi_enabled = False
        self.bg_chr = 0
        self.obj_chr = 0
        self.mask = 0
        self.latch = (0, 0, 0)       # scroll x, scroll y, PPUCTRL at FCBF
        self.hud = None
        self.frame_log = []
        self.effects = []
        self.executed = None         # optional set of (bank, pc)
        self.indirect = None         # optional dict pc -> targets
        self.idle = {}
        self.chr_switches = []
        self.cycles_busy = 0
        self.busy_per_frame = []
        self.oam_snapshot = bytes(256)
        self.view = None
        c = self.cpu
        c.sp = 0xFF
        c.pc = 0xFF3D                # NES reset routine (the vector's JMP target)
        c.p |= c.INTERRUPT
        self.mem.ram[0x100] = 0

    # ------------------------------------------------------------------ CPU
    def rts(self):
        self.cpu.pc = (self.cpu.stPopWord() + 1) & 0xFFFF

    def nz(self, v):
        self.cpu.FlagsNZ(v & 255)
        return v & 255

    def step(self):
        c, m = self.cpu, self.mem
        pc = c.pc
        self.cur_bank = m.bank if pc < 0xC000 else 7
        if self.executed is not None:
            self.executed.add((self.cur_bank, pc))
        if pc in self.svc:
            name = self.svc[pc]
            getattr(self, 's_' + name)()
            if name not in ('dd_one_off_update',):
                pass
            c.processorCycles += 30
            return
        op = m[pc]
        if op in (0x6C,) and self.indirect is not None:
            ptr = m[pc + 1] | m[pc + 2] << 8
            tgt = m[ptr] | m[(ptr & 0xFF00) | ((ptr + 1) & 0xFF)] << 8
            self.indirect[(self.cur_bank, pc)].add((m.bank if tgt < 0xC000 else 7, tgt))
        # idle detection: a backward branch revisited with no RAM writes
        if op in (0xD0, 0xF0, 0x10, 0x30, 0x90, 0xB0, 0x50, 0x70):
            off = m[pc + 1]
            if off >= 0x80 and off >= 0xF0:
                key = pc
                state = (self.writes, c.a, c.x, c.y, c.p)
                if self.idle.get(key) == state:
                    if c.processorCycles < self.next_nmi:
                        c.processorCycles = self.next_nmi
                self.idle[key] = state
        before = c.processorCycles
        c.step()
        if c.processorCycles - before > 0:
            self.cycles_busy += c.processorCycles - before
        if c.processorCycles >= self.next_nmi:
            self.end_frame()

    def end_frame(self):
        c = self.cpu
        self.next_nmi += FRAME
        self.frames += 1
        self.busy_per_frame.append(self.cycles_busy)
        self.cycles_busy = 0
        self.idle.clear()
        # the frame just displayed: OAM DMA happens at the start of NMI
        self.oam_snapshot = bytes(self.mem.ram[0x200:0x300])
        self.view = (self.latch, self.hud, self.mask, self.bg_chr, self.obj_chr,
                     self.ppu.mirror)
        self.hud = None
        self.input_hook()
        if self.nmi_enabled:
            c.stPushWord(c.pc)
            c.stPush(c.p & ~c.BREAK)
            c.p |= c.INTERRUPT
            c.pc = 0xFF16

    def input_hook(self):
        pass

    def run_frames(self, n, limit=None):
        end = self.frames + n
        while self.frames < end:
            self.step()

    # ------------------------------------------------------------ services
    def ppu_write(self, v):
        self.ppu.write(self.mem.ram[0x0A41] << 8 | self.mem.ram[0x0A40], v)
        a = ((self.mem.ram[0x0A41] << 8 | self.mem.ram[0x0A40]) + self.ppu.inc) & 0xFFFF
        self.mem.ram[0x0A40], self.mem.ram[0x0A41] = a & 255, a >> 8

    def s_ppu_w_a(self): self.ppu_write(self.cpu.a); self.rts()
    def s_ppu_w_x(self): self.ppu_write(self.cpu.x); self.rts()
    def s_ppu_w_y(self): self.ppu_write(self.cpu.y); self.rts()

    def s_ppu_r_a(self):
        # NES $2007 reads are buffered; the game only does a dummy read here.
        a = self.mem.ram[0x0A41] << 8 | self.mem.ram[0x0A40]
        self.cpu.a = self.nz(self.ppu.read(a))
        a = (a + self.ppu.inc) & 0xFFFF
        self.mem.ram[0x0A40], self.mem.ram[0x0A41] = a & 255, a >> 8
        self.rts()

    def set_inc(self, bit):
        self.ppu.inc = 32 if bit else 1

    def s_set_vram_increment_based_on_a_and_store(self):
        m = self.mem
        bit = m.ram[0x15] & 4
        self.set_inc(bit)
        self.cpu.a = self.nz((m.ram[0xFF] & ~4) | bit)
        m.ram[0xFF] = self.cpu.a
        self.rts()

    def s_set_vram_increment_to_1_and_store(self):
        m = self.mem
        self.set_inc(0)
        self.cpu.a = self.nz(m.ram[0xFF] & ~4)
        m.ram[0xFF] = self.cpu.a
        self.rts()

    def s_set_vram_increment_to_32_no_store(self):
        self.set_inc(4)
        self.cpu.a = self.nz(self.mem.ram[0xFF] | 4)
        self.rts()

    def s_change_write_increment_based_on_carry_flag(self):
        m = self.mem
        bit = 4 if self.cpu.p & self.cpu.CARRY else 0
        self.set_inc(bit)
        self.cpu.a = self.nz((m.ram[0xFF] & ~4) | bit)
        m.ram[0xFF] = self.cpu.a
        self.rts()

    def s_store_vmaddh_to_proper_range(self):
        self.mem.ram[0x0A41] = self.cpu.a
        self.rts()

    def s_restore_ppu_control_from_a(self):
        self.mem.ram[0xFF] = self.cpu.a
        self.nmi_enabled = bool(self.cpu.a & 0x80)
        self.rts()

    s_change_ppu_vblank_status = s_restore_ppu_control_from_a

    def s_enable_nmi_and_store(self):
        self.cpu.a = self.nz(self.mem.ram[0xFF] | 0x80)
        self.mem.ram[0xFF] = self.cpu.a
        self.nmi_enabled = True
        self.rts()

    def s_disable_nmi_and_store(self):
        self.cpu.a = self.nz(self.mem.ram[0xFF] & 0x7F)
        self.mem.ram[0xFF] = self.cpu.a
        self.nmi_enabled = False
        self.rts()

    def mask_op(self, op, bits):
        m = self.mem
        v = (m.ram[0xFE] | bits) if op else (m.ram[0xFE] & ~bits & 255)
        m.ram[0xFE] = v
        self.cpu.a = self.nz(v)
        self.mask = v
        self.rts()

    def s_disable_sprites_and_bg_and_store(self): self.mask_op(0, 0x18)
    def s_enable_bg_and_sprites_and_store(self): self.mask_op(1, 0x18)
    def s_disable_sprites_and_store(self): self.mask_op(0, 0x10)
    def s_enable_sprites_and_store(self): self.mask_op(1, 0x10)
    def s_disable_bg_and_store(self): self.mask_op(0, 0x08)
    def s_enable_bg_and_store(self): self.mask_op(1, 0x08)

    def s_augment_input(self):
        m = self.mem
        m.ram[0xF5] = self.buttons
        m.ram[0xF6] = 0
        m.ram[0x00] = 0
        m.ram[0x01] = 0
        self.cpu.x = 0
        self.cpu.a = self.nz(0)
        self.rts()

    def s_handle_mmc1_control_register(self):
        # A holds PPU_CONTROL_STATE (returned to the caller unchanged)
        self.ppu.mirror = self.mem.ram[0x0108] & 3
        self.rts()

    def s_prg_bank(self):
        v = self.cpu.a & 0x0F
        if v > 7:
            raise RuntimeError(f'PRG bank {v}')
        self.mem.bank = v
        self.rts()

    def s_bankswitch_obj_chr_data(self):
        self.obj_chr = self.cpu.a & 31
        self.chr_switches.append((self.frames, 'obj', self.obj_chr))
        self.rts()

    def s_check_for_bg_chr_bankswap(self):
        self.bg_chr = self.cpu.a & 31
        self.chr_switches.append((self.frames, 'bg', self.bg_chr))
        self.rts()

    def s_check_for_initial_obj_loads(self): self.rts()
    def s_convert_nes_attributes_and_immediately_dma_them(self): self.rts()
    def s_do_critical_snes_nmi_chores(self): self.rts()

    def s_reset_2a03_audio(self): self.rts()

    def s_convert_audio(self):
        self.rts()

    def s_dd_update_row_attributes(self):
        self.cpu.a = self.nz(0)
        self.mem.ram[0x1C] = 0
        self.rts()

    def s_dd_one_off_update(self):
        c, m = self.cpu, self.mem
        ret = c.stPopWord()
        m.ram[0x1F] = c.stPop()
        c.a = self.nz(c.stPop())
        m.ram[0x1E] = c.a
        c.pc = (ret + 1) & 0xFFFF

    def s_dd_update_column_attributes(self):
        c, m = self.cpu, self.mem
        if c.x >= 0x1E:
            c.x = 0
            m.ram[0x1F] = (m.ram[0x1F] + 1) & 255
        m.ram[0x1E] = c.x
        m.ram[0x08] = self.nz(m.ram[0x08] - 1)
        self.rts()

    def s_clear_bg_vm_jsl(self):
        # NES: fill $2000, $2400 and $2800 (four nametables incl. attributes) with 0
        for t in self.ppu.nt:
            t[:] = bytes(0x400)
        self.rts()

    def s_full_attribute_copy_from_0628(self):
        m = self.mem
        for i in range(0x40):
            self.ppu.write(0x23C0 + i, m.ram[0x628 + i])
            self.ppu.write(0x2BC0 + i, m.ram[0x668 + i])
        self.rts()

    def s_set_bottom_3_rows_of_attributes_to_55(self):
        for i in range(24):
            self.ppu.write(0x2BE8 + i, 0x55)
        self.rts()

    def s_write_palette_data(self):
        m = self.mem
        off, cnt = m.ram[0x8A7], m.ram[0x8A6]
        src = m.ram[2] | m.ram[3] << 8
        for i in range(cnt):
            self.ppu.write(0x3F00 + off + i, m[src + i])
        self.cpu.p |= self.cpu.CARRY
        self.rts()

    def s_write_8_palette_entries_from_f1b6(self):
        for i in range(8):
            self.ppu.write(0x3F10 + i, self.mem[0xF1B6 + i])
        self.rts()

    def s_write_tile_and_attribute_rewrite(self):
        m = self.mem
        x = self.cpu.x
        p = m[0x8000 + x] | m[0x8001 + x] << 8
        for _ in range(100000):
            count = m[p]
            if count == 0:
                hi = m[p + 1]
                if hi == 0:
                    idx = m.ram[0x16]
                    if 5 <= idx < 13:
                        idx += 12
                        m.ram[0x16] = idx
                        # rewrite_c25a: select the continuation's bank and stream
                        x = m[0xC20D + idx]
                        m.ram[0x4F4] = m[0xC226 + idx]
                        m.bank = m[0xC240 + idx] & 0x0F
                        m.ram[0x104] = m.bank
                        if idx == 0x10:
                            m.ram[0x108] = 0x1E
                            self.ppu.mirror = 2
                        p = m[0x8000 + x] | m[0x8001 + x] << 8
                        continue
                    break
                m.ram[0x0A41] = hi
                m.ram[0x0A40] = m[p + 2]
                bit = (m[p + 3] << 2) & 4
                self.set_inc(bit)
                m.ram[0xFF] = (m.ram[0xFF] & ~4 & 255) | bit
                p += 4
            else:
                n = m[p + 1]
                for _ in range(count):
                    for i in range(n):
                        self.ppu_write(m[p + 2 + i])
                p += 2 + n
        else:
            raise RuntimeError('unterminated tile stream')
        # the stream code's tail at C27C: LDA #$06; JSR $FEEE; RTS
        self.cpu.pc = 0xC27C if False else self.cpu.pc
        self.rts()

    def s_latch_scroll(self):
        m = self.mem
        self.latch = (m.ram[0xFD], m.ram[0xFC], m.ram[0xFF])
        self.rts()

    def s_hud_scroll(self):
        m = self.mem
        if m.ram[0x3B] & 1:
            nt = 0
            v = m.ram[0xFF] & 0xFC
        else:
            nt = 2
            v = (m.ram[0xFF] & 0xFC) | 2
        m.ram[0xFF] = v
        self.hud = nt
        self.cpu.a = self.nz(v)
        self.rts()

    # ------------------------------------------------------------ screenshot
    def chr_tiles(self, bank):
        if not hasattr(self, '_chr'):
            self._chr = load_chr()
        return self._chr[bank]

    def render(self):
        """Render the last completed frame as a 256x240 palette-index image."""
        import numpy as np
        (sx, sy, ctrl), hud, mask, bgc, objc, mirror = self.view
        img = np.zeros((240, 256), dtype=np.uint8)
        bg = self.chr_tiles(bgc)
        nt_base = ctrl & 3
        split = self.oam_snapshot[0] + 5 if hud is not None else 240
        ppu = self.ppu
        saved = ppu.mirror
        ppu.mirror = mirror
        for y in range(240):
            if y < split:
                yy0, xx0, base = sy, sx, nt_base
                yy = y + yy0
            else:
                base, xx0 = hud, 0
                yy = 202 + (y - split)
            for x in range(256):
                xx = x + xx0
                n = base ^ (1 if xx >= 256 else 0) ^ (2 if yy >= 240 else 0)
                X, Y = xx & 255, yy % 240
                t, o = ppu.phys(0x2000 + n * 0x400)
                tile = t[o + (Y >> 3) * 32 + (X >> 3)]
                attr = t[o + 0x3C0 + (Y >> 5) * 8 + (X >> 5)]
                sh = ((Y >> 4) & 1) * 4 + ((X >> 4) & 1) * 2
                c = bg[tile][(Y & 7) * 8 + (X & 7)]
                img[y, x] = ppu.pal[((attr >> sh) & 3) * 4 + c] if c else ppu.pal[0]
        ppu.mirror = saved
        if not mask & 2:
            img[:, :8] = ppu.pal[0]
        if mask & 0x10:
            spr = self.chr_tiles(objc)
            o = self.oam_snapshot
            for i in range(63, -1, -1):
                y, t, a, x = o[i * 4:i * 4 + 4]
                if y >= 0xEF:
                    continue
                for dy in range(8):
                    for dx in range(8):
                        c = spr[t][(7 - dy if a & 128 else dy) * 8 + (7 - dx if a & 64 else dx)]
                        if c and x + dx < 256 and y + 1 + dy < 240:
                            if a & 0x20:
                                continue
                            img[y + 1 + dy, x + dx] = ppu.pal[0x10 + (a & 3) * 4 + c]
        return img

    def screenshot(self, path, scale=2):
        from PIL import Image
        img = self.render()
        im = Image.fromarray(img, 'P')
        im.putpalette(nes_palette_rgb())
        im = im.resize((256 * scale, 240 * scale), Image.NEAREST)
        im.save(path)


def load_chr():
    """32 banks of 256 tiles, each tile a list of 64 two-bit pixels."""
    import re
    banks = []
    for f in range(8):
        data = bytearray()
        for line in (SNES_SRC / f'chrom-tiles-{f}.asm').read_text().splitlines():
            line = line.split(';', 1)[0].strip()
            if line.lower().startswith('.byte'):
                data += bytes(int(v.strip()[1:], 16) for v in line[5:].split(',') if v.strip())
        for b in range(4):
            tiles = []
            for t in range(256):
                i = (b * 256 + t) * 32
                px = []
                for y in range(8):
                    p0, p1 = data[i + y * 2], data[i + y * 2 + 1]
                    for x in range(8):
                        px.append(((p0 >> (7 - x)) & 1) | (((p1 >> (7 - x)) & 1) << 1))
                tiles.append(px)
            banks.append(tiles)
    return banks


def nes_palette_rgb():
    import re
    vals = []
    for line in (SNES_SRC / 'palette_lookup.asm').read_text().splitlines():
        line = line.split(';', 1)[0].strip()
        if line.lower().startswith('.byte'):
            vals += [int(v.strip()[1:], 16) for v in line[5:].split(',') if v.strip()]
    pal = []
    for i in range(64):
        w = vals[i * 2] | vals[i * 2 + 1] << 8
        pal += [(w & 31) * 255 // 31, ((w >> 5) & 31) * 255 // 31, ((w >> 10) & 31) * 255 // 31]
    return pal + [0] * (768 - len(pal))


if __name__ == '__main__':
    m = Machine()
    m.mem.ram[0x103] = 0x53 if '--skip' in sys.argv else 0
    script = {120: 0x10}

    def inp():
        f = m.frames
        m.buttons = 0x10 if 120 <= f < 126 else (0x81 if f >= 250 else 0)
    m.input_hook = inp
    n = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 400
    m.run_frames(n)
    m.screenshot(ROOT / 'gen' / 'model.png')
    print('frames', m.frames, 'stage', m.mem.ram[0x3D], m.mem.ram[0x3E],
          'busy max', max(m.busy_per_frame[60:]), 'avg', sum(m.busy_per_frame[60:]) // max(1, len(m.busy_per_frame[60:])))
    print('chr', m.chr_switches[:20])
