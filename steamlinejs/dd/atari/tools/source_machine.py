#!/usr/bin/env python3
"""Reference execution of the supplied game logic, for developing the native port.

Uses real assembled PRG code and an explicit model of its platform services.
This is a development tool, not an Atari emulator or a replacement game engine.
Unknown opcodes and unimplemented platform calls fail immediately.
"""
from collections import Counter
import argparse
import json
from pathlib import Path
from py65.devices.mpu6502 import MPU

ROOT = Path(__file__).resolve().parents[1]
IMAGE = ROOT / 'generated/source-engine'


class Memory:
    def __init__(self):
        self.ram = bytearray(65536)
        self.banks = [(IMAGE / f'bank{i}.bin').read_bytes() for i in range(8)]
        self.bank = 6
        self.ram[0x104] = 6
        self.ppu = bytearray(0x4000)
        self.ppu_address = 0
        self.increment = 1
        self.writes = 0

    def __getitem__(self, address):
        if 0x8000 <= address < 0xc000:
            return self.banks[self.bank][address - 0x8000]
        if address >= 0xc000:
            return self.banks[7][address - 0xc000]
        if address == 0x4210:
            return 0x80
        if address == 0x2139:
            value = self.ppu[self.ppu_address & 0x3fff]
            self.ppu_address += self.increment
            return value
        return self.ram[address]

    def __setitem__(self, address, value):
        if address >= 0x8000:
            raise RuntimeError(f'unexpected ROM write: ${address:04x}')
        self.ram[address] = value
        if address == 0x2117:
            self.ppu_address = (self.ppu_address & 255) | ((value & 63) << 8)
        elif address == 0x2116:
            self.ppu_address = (self.ppu_address & 0x3f00) | value
        elif address == 0x2118:
            self.write_ppu(value)

    def write_ppu(self, value):
        self.ppu[self.ppu_address & 0x3fff] = value
        self.ppu_address = (self.ppu_address + self.increment) & 0x3fff
        self.writes += 1

    def word(self, address):
        return self[address] | self[address+1] << 8

    def select_bank(self, value):
        if not 0 <= value < 8:
            raise RuntimeError(f'invalid PRG bank {value}')
        self.bank = value
        self.ram[0x104] = value


class Machine:
    def __init__(self):
        self.mem = Memory()
        self.cpu = MPU(memory=self.mem, pc=0xe165)
        self.cpu.sp = 0xff
        self.services = {value: name for name, value in
                         json.loads((IMAGE / 'manifest.json').read_text())['services'].items()}
        self.calls = Counter()
        self.visited = set()
        self.buttons = [0, 0]
        self.frames = 0
        self.bg_chr = 0
        self.sprite_chr = 0
        self.effects = []
        self.mem.ram[0xff] = 0x10
        self.mem.ram[0xfe] = 0x06
        self.mem.ram[0x100] = 0xc0
        self.next_nmi = 29780

    def nz(self, value):
        self.cpu.FlagsNZ(value & 255)
        return value & 255

    def rts(self):
        self.cpu.pc = (self.cpu.stPopWord() + 1) & 65535

    def step(self):
        c, m = self.cpu, self.mem
        pc = c.pc
        self.visited.add((m.bank if pc < 0xc000 else 7, pc))
        if pc == 0xfeee:
            m.select_bank(c.a & 15)
            c.a = self.nz(m[0xff])
            self.rts()
        elif pc == 0xfbe1:
            # IDs $20 and up are music; retain only effect events for the
            # future POKEY backend. Never execute the source music sequencer.
            if 0 < c.a < 0x1f:
                self.effects.append((self.frames, c.a))
            self.rts()
        elif pc == 0xfbf8:
            self.rts()
        elif pc == 0xfc80:
            # Original FC80 temporarily sets $0100=0 and waits for the NMI
            # stack-unwind path at FF16. That path restores $0100 and A,
            # disables NMI and returns directly to the caller. Advance the
            # reference clock to that edge instead of executing a busy loop.
            c.processorCycles = self.next_nmi
            self.next_nmi += 29780
            self.frames += 1
            m[0xff] &= 127
            c.p = (c.p | c.INTERRUPT) & ~c.OVERFLOW
            self.nz(c.a)
            self.rts()
        elif pc in self.services:
            name = self.services[pc]
            self.calls[name] += 1
            return_to = (c.stPopWord() + 1) & 65535
            self.service(name)
            c.pc = return_to
        elif pc == self.label('LOCAL_EXIT_FROM_INTERRUPT'):
            c.a = c.stPop(); c.y = c.a
            c.a = c.stPop(); c.x = c.a
            c.a = c.stPop()
            c.p = c.stPop() | c.UNUSED
            c.pc = c.stPopWord()
        elif pc == self.label('LOCAL_SET_STACK_TO_1FF'):
            c.sp = 255
            c.x = self.nz(255)
            c.pc = self.label('LOCAL_RETURN_FROM_STACK_SHENANIGANS')
        elif pc == 0xed65 and m[pc] == 0x9c:
            # The supplied SNES palette routine uses STZ absolute. Handle
            # this one identified instruction, not a different CPU ISA.
            m[m.word(pc+1)] = 0
            c.pc += 3
            c.processorCycles += 4
        else:
            if c.disassemble[m[pc]][0] in ('???', 'BRK'):
                raise RuntimeError(f'unsupported opcode ${m[pc]:02x} at bank {m.bank}:${pc:04x}')
            c.step()
        if c.processorCycles >= self.next_nmi:
            self.next_nmi += 29780
            self.frames += 1
            if m[0xff] & 128:
                dispatch = {0x00: None, 0x40: 0xe0b1, 0x80: 0xe0c5, 0xc0: 0xe0ff}[m[0x100] & 0xc0]
                if dispatch is None:
                    raise RuntimeError('unimplemented NMI stack-unwind barrier')
                c.nmi()
                c.pc = dispatch

    def label(self, name):
        if not hasattr(self, 'labels'):
            self.labels = {parts[2]: int(parts[1], 16)
                for line in (IMAGE / 'bank7.lab').read_text().splitlines()
                if len(parts := line.split()) == 3}
        return self.labels[name]

    def call(self, address, limit=100000):
        self.cpu.stPushWord(0x0ffe)
        self.cpu.pc = address
        for _ in range(limit):
            if self.cpu.pc == 0x0fff:
                return
            self.step()
        raise RuntimeError(f'call ${address:04x} did not return; PC=${self.cpu.pc:04x}')

    def service(self, name):
        c, m = self.cpu, self.mem
        if name in ('enable_nmi_and_store', 'disable_nmi_and_store'):
            c.a = self.nz((m[0xff] | 128) if name.startswith('enable') else (m[0xff] & 127))
            m[0xff] = c.a
        elif name in ('restore_ppu_control_from_a', 'change_ppu_vblank_status'):
            m[0xff] = c.a
        elif name in ('disable_sprites_and_bg_and_store', 'enable_bg_and_sprites_and_store',
                      'disable_sprites_and_store', 'enable_sprites_and_store',
                      'disable_bg_and_store', 'enable_bg_and_store'):
            mask = 24 if 'sprites_and' in name or 'and_sprites' in name else (16 if 'sprites' in name else 8)
            c.a = self.nz((m[0xfe] | mask) if name.startswith('enable') else (m[0xfe] & ~mask))
            m[0xfe] = c.a
        elif name == 'augment_input':
            m[0xf5], m[0xf6] = self.buttons
            m[0], m[1] = 0, 0
            c.x = 0
            c.a = self.nz(0)
            c.p &= ~c.CARRY
        elif name in ('set_vram_increment_to_1_and_store', 'set_vram_increment_based_on_a_and_store',
                      'change_write_increment_based_on_carry_flag', 'set_vram_increment_to_32_no_store'):
            bit = 4 if name == 'set_vram_increment_to_32_no_store' else 0
            if name == 'set_vram_increment_based_on_a_and_store': bit = m[0x15] & 4
            if name == 'change_write_increment_based_on_carry_flag': bit = (c.p & c.CARRY) * 4
            m.increment = 32 if bit else 1
            c.a = self.nz((m[0xff] & ~4) | bit)
            if name != 'set_vram_increment_to_32_no_store': m[0xff] = c.a
        elif name == 'bankswitch_obj_chr_data':
            self.sprite_chr = c.a
        elif name == 'check_for_bg_chr_bankswap':
            self.bg_chr = m[0x891]
        elif name == 'store_vmaddh_to_proper_range':
            m[0x2117] = c.a
        elif name == 'handle_mmc1_control_register':
            if m[0x108] != 0x1f:
                raise RuntimeError('unsupported MMC1 mode')
        elif name == 'dd_update_row_attributes':
            c.a = self.nz(0)
            m[0x1c] = 0
        elif name == 'dd_one_off_update':
            c.a = c.stPop(); m[0x1f] = c.a
            c.a = self.nz(c.stPop()); m[0x1e] = c.a
        elif name == 'dd_update_column_attributes':
            if c.x >= 30:
                c.x = 0
                m[0x1f] = (m[0x1f]+1) & 255
            m[0x1e] = c.x
            m[0x08] = self.nz(m[0x08]-1)
        elif name == 'clear_bg_vm_jsl':
            m.ppu[0x2000:0x2c00] = bytes(0xc00)
        elif name == 'full_attribute_copy_from_0628':
            m.ppu[0x23c0:0x2400] = m.ram[0x628:0x668]
            m.ppu[0x2bc0:0x2c00] = m.ram[0x668:0x6a8]
        elif name == 'set_bottom_3_rows_of_attributes_to_55':
            m.ppu[0x2be8:0x2c00] = bytes([0x55])*24
        elif name == 'write_palette_data':
            offset, count, src = m[0x8a7], m[0x8a6], m.word(2)
            for index in range(count):
                m.ppu[0x3f00+offset+index] = m[src+index]
            c.p |= c.CARRY  # caller uses BCS as an unconditional return
        elif name == 'write_8_palette_entries_from_f1b6':
            for index in range(8): m.ppu[0x3f10+index] = m[0xf1b6+index]
        elif name == 'write_tile_and_attribute_rewrite':
            self.decompress(m.word(0x8000+c.x))
        elif name in ('check_for_initial_obj_loads', 'convert_nes_attributes_and_immediately_dma_them'):
            # SNES-only caches: NES attributes and CHR indices remain in
            # their original representation in this reference model.
            pass
        elif name in ('do_critical_snes_nmi_chores', 'reset_2a03_audio'):
            # No SNES DMA or audio processor exists in the reference model.
            pass
        else:
            raise RuntimeError(f'unimplemented hardware service: {name}')

    def decompress(self, pointer):
        m = self.mem
        for _ in range(65536):
            count = m[pointer]
            if not count:
                high = m[pointer+1]
                if not high:
                    index = m[0x16]
                    if 5 <= index < 13:
                        index += 12
                        m[0x16] = index
                        m.select_bank(m[0xc240+index])
                        pointer = m.word(0x8000+m[0xc20d+index])
                        continue
                    return
                m.ppu_address = ((high << 8) | m[pointer+2]) & 0x3fff
                m.increment = 32 if m[pointer+3] & 1 else 1
                pointer += 4
            else:
                length = m[pointer+1]
                if length == 0:
                    raise RuntimeError('invalid zero-sized graphic record')
                for _ in range(count):
                    for index in range(length): m.write_ppu(m[pointer+2+index])
                pointer += 2+length
        raise RuntimeError('unterminated graphic stream')

    def screenshot(self, path):
        from PIL import Image
        from make_assets import raw, tile
        m = self.mem
        graphics = [raw(f'chrom-tiles-{bank}.asm') for bank in range(8)]
        colors = raw('palette_lookup.asm')
        palette = []
        for index in range(64):
            value = colors[index*2] | colors[index*2+1] << 8
            palette.extend(((value & 31)*255//31, ((value >> 5) & 31)*255//31,
                            ((value >> 10) & 31)*255//31))
        palette.extend([0]*(768-len(palette)))
        image = Image.new('P', (256, 240))
        image.putpalette(palette)
        pixels = image.load()
        chr_set = self.bg_chr & 31
        tiles = [tile(graphics[chr_set//4], (chr_set%4)*256+i) for i in range(256)]
        for y in range(240):
            for x in range(256):
                xx = x + m[0xfd]
                yy = y + m[0xfc]
                nt = (m[0xff] & 3) ^ ((xx//256) & 1) ^ (((yy//240) & 1) << 1)
                xx %= 256; yy %= 240
                base = 0x2000 + nt*0x400
                number = m.ppu[base + (yy//8)*32 + xx//8]
                attr = m.ppu[base + 0x3c0 + (yy//32)*8 + xx//32]
                shift = ((yy//16)&1)*4 + ((xx//16)&1)*2
                color = tiles[number][(yy%8)*8+xx%8]
                pal_index = ((attr >> shift) & 3)*4+color if color else 0
                pixels[x, y] = m.ppu[0x3f00+pal_index] & 63
        if m[0xfe] & 16:
            chr_set = self.sprite_chr & 31
            tiles = [tile(graphics[chr_set//4], (chr_set%4)*256+i) for i in range(256)]
            for index in range(63, -1, -1):
                y, number, attr, x = m.ram[0x200+index*4:0x204+index*4]
                for dy in range(8):
                    for dx in range(8):
                        color = tiles[number][(7-dy if attr&128 else dy)*8 + (7-dx if attr&64 else dx)]
                        if color and x+dx < 256 and y+1+dy < 240:
                            pixels[x+dx, y+1+dy] = m.ppu[0x3f10+(attr&3)*4+color] & 63
        image.resize((768, 720), Image.Resampling.NEAREST).save(path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--frames', type=int, default=600)
    parser.add_argument('--start', action='store_true', help='press Start on title/menu')
    parser.add_argument('--screenshot', type=Path)
    parser.add_argument('--trace', type=Path, help='write executed source addresses for relocation auditing')
    args = parser.parse_args()
    machine = Machine()
    if args.start:
        # The source warm-reset flag skips the opening demonstration only.
        machine.mem[0x103] = 0x53
    for _ in range(args.frames*30000):
        if args.start:
            machine.buttons[0] = 0x10 if machine.frames in range(120, 130) else (0x81 if machine.frames >= 250 else 0)
        machine.step()
        if machine.frames >= args.frames:
            break
    else:
        raise RuntimeError('instruction limit reached before requested frames')
    if args.screenshot:
        machine.screenshot(args.screenshot)
    if args.trace:
        args.trace.write_text(json.dumps(sorted(machine.visited)) + '\n')
    print(json.dumps({'frames': machine.frames, 'pc': machine.cpu.pc,
                      'bank': machine.mem.bank, 'services': machine.calls,
                      'stage': machine.mem[0x3d], 'section': machine.mem[0x3e],
                      'player_state': list(machine.mem.ram[0x4a:0x52]),
                      'player_x': machine.mem[0x5a] | machine.mem[0x62] << 8,
                      'player_y': machine.mem[0x72] | machine.mem[0x7a] << 8,
                      'ppu_writes': machine.mem.writes}, indent=2))


if __name__ == '__main__':
    main()
