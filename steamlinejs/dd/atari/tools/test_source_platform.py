#!/usr/bin/env python3
"""Native source engine integration versus the recovered reference platform.

The host model only provides bank-window hardware and RAM. All CPU dispatch,
platform services, PPU state updates and frame scheduling run as assembled 6502.
"""
import unittest
from py65.devices.mpu6502 import MPU
from source_machine import Machine
from build_source_engine import OUT
from test_source_cpu import NativeCPU


class BankWindow:
    def __init__(self, ram, banks, bank, page):
        self.ram, self.banks, self.bank, self.page = ram, banks, bank, page
        self.switches = []

    def __getitem__(self, address):
        if isinstance(address, slice):
            return self.ram[address]
        if 0x8000 <= address < 0xc000:
            return self.banks[self.bank][address-0x8000]
        return self.ram[address]

    def __setitem__(self, address, value):
        if isinstance(address, slice):
            self.ram[address] = value
        elif address == self.page+0x5f:
            assert value & 128 and not value & 3
            self.bank = (value&127)//4
            assert self.bank < 8
            self.switches.append(self.bank)
        else:
            assert not 0x8000 <= address < 0xc000, 'source ROM write'
            assert not 0xd000 <= address < 0xd800, 'unexpected Atari hardware access'
            self.ram[address] = value


class NativePlatform(NativeCPU):
    def __init__(self, reference, page=0xd600):
        super().__init__()
        self.symbols = {p[2].lower(): int(p[1],16)
            for line in (OUT/'platform.lab').read_text().splitlines()
            if len(p := line.split()) == 3}
        image = (OUT/'platform.bin').read_bytes()
        self.memory[0x2000:0x2000+len(image)] = image
        m = reference.mem
        self.memory[0x1000:0x2000] = m.ram[:0x1000]
        self.memory[0x4000:0x8000] = m.banks[7]
        self.memory[0xc000:0xd000] = m.ppu[0x2000:0x3000]
        self.memory[0xd800:0xd900] = m.ppu[0x3f00:0x4000]
        self.memory = BankWindow(self.memory, m.banks, m.bank, page)
        self.cpu = MPU(memory=self.memory)
        self.import_state(reference.cpu)
        self.put_word('platform_reg',page)
        self.put('platform_bank',m.bank)
        self.put_word('platform_ppu_address',m.ppu_address)
        self.put('platform_increment',m.increment)
        self.put('platform_bg_chr',reference.bg_chr)
        self.put('platform_sprite_chr',reference.sprite_chr)
        self.put('platform_buttons',reference.buttons[0])
        self.put('platform_buttons',reference.buttons[1],1)
        self.put_word('platform_frames',reference.frames)
        self.put_word('platform_budget',reference.next_nmi-reference.cpu.processorCycles)

    def put(self, name, value, offset=0):
        self.memory[self.symbols[name]+offset] = value

    def word(self, name):
        p = self.symbols[name]
        return self.memory[p] | self.memory[p+1]<<8

    def put_word(self, name, value):
        self.put(name,value&255)
        self.put(name,value>>8,1)

    def run(self, label):
        sp = self.cpu.sp
        self.cpu.stPushWord(0x0ffe)
        self.cpu.pc = self.symbols[label]
        for _ in range(5000000):
            if self.cpu.pc == 0x0fff:
                assert self.cpu.sp == sp
                if self.get('fault'):
                    raise AssertionError(f'native fault {self.get("fault")} at ${self.word("vm_fault_pc"):04x}')
                return
            self.cpu.step()
        raise AssertionError(f'native execution budget exhausted at guest ${self.word("vm_pc"):04x}')


class NativePlatformTests(unittest.TestCase):
    def equal_state(self, reference, native):
        self.assertEqual(native.state(),tuple(getattr(reference.cpu,n) for n in ('a','x','y','p','sp','pc')))
        self.assertEqual(native.memory.ram[0x1000:0x2000],reference.mem.ram[:0x1000])
        self.assertEqual(native.memory.bank,reference.mem.bank)
        self.assertEqual(native.memory.ram[0xc000:0xd000],reference.mem.ppu[0x2000:0x3000])
        self.assertEqual(native.memory.ram[0xd800:0xd900],reference.mem.ppu[0x3f00:0x4000])
        self.assertEqual(native.word('platform_ppu_address'),reference.mem.ppu_address)
        self.assertEqual(native.memory[native.symbols['platform_increment']],reference.mem.increment)
        self.assertEqual(native.memory[native.symbols['platform_bg_chr']],reference.bg_chr)
        self.assertEqual(native.memory[native.symbols['platform_sprite_chr']],reference.sprite_chr)

    def test_each_reachable_platform_service(self):
        reference = Machine()
        for address,name in reference.services.items():
            if name == 'convert_audio':
                continue  # explicitly prohibited source audio sequencer
            with self.subTest(service=name):
                ref = Machine()
                ref.cpu.a,ref.cpu.x,ref.cpu.y = 0x53,0,0x76
                ref.mem[0x108] = 0x1f
                ref.mem[0x15] = 4
                ref.mem[0x8a6],ref.mem[0x8a7] = 8,4
                ref.mem[2],ref.mem[3] = 0xb6,0xf1
                ref.buttons = [0xa5,0x5a]
                if name == 'write_tile_and_attribute_rewrite':
                    ref.mem.select_bank(2)
                ref.cpu.pc = address
                ref.cpu.stPushWord(0x0ffe)
                native = NativePlatform(ref)
                ref.step()
                native.run('vm_step')
                self.equal_state(ref,native)

    def test_all_eleven_section_initializers_run_natively(self):
        for stage,count in enumerate((2,1,4,4)):
            for section in range(count):
                with self.subTest(stage=stage,section=section):
                    ref = Machine()
                    ref.mem[0x3d],ref.mem[0x3e] = stage,section
                    ref.mem[0x33],ref.mem[0x47] = 1,0x10
                    native = NativePlatform(ref,0xd600 if section&1 else 0xd700)
                    ref.call(0x9924)
                    native.put_word('vm_pc',0x9924)
                    sp = native.get('sp')
                    native.memory[0x1100+sp] = 0x0f
                    native.memory[0x1100+((sp-1)&255)] = 0xfe
                    native.set('sp',(sp-2)&255)
                    native.run('platform_run_call')
                    self.equal_state(ref,native)

    def test_native_frame_barrier_and_startup(self):
        ref = Machine()
        ref.mem[0x103] = 0x53
        native = NativePlatform(ref)
        for frame in range(1,5):
            for _ in range(50000):
                ref.step()
                if ref.frames == frame:
                    break
            else:
                self.fail('reference frame did not end')
            native.run('platform_run_frame')
            self.equal_state(ref,native)
            self.assertEqual(native.word('platform_frames'),frame)
            self.assertEqual(native.word('platform_budget'),ref.next_nmi-ref.cpu.processorCycles)

    def test_native_gameplay_frames_match_original_engine(self):
        ref = Machine()
        ref.mem[0x103] = 0x53
        for _ in range(12000000):
            ref.buttons[0] = 0x10 if 120 <= ref.frames < 130 else (0x81 if ref.frames >= 250 else 0)
            ref.step()
            if ref.frames >= 1100:
                break
        else:
            self.fail('reference did not reach gameplay checkpoint')
        self.assertEqual(ref.mem[0x4a],0x80)
        self.assertGreater(ref.mem[0x3b4],0)
        native = NativePlatform(ref)
        for buttons in (0,1,2,0x80,0x40,0xc0):
            ref.buttons[0] = buttons
            native.put('platform_buttons',buttons)
            next_frame = ref.frames+1
            for _ in range(50000):
                ref.step()
                if ref.frames == next_frame:
                    break
            else:
                self.fail('reference gameplay frame did not return')
            native.run('platform_run_frame')
            self.equal_state(ref,native)
            self.assertEqual(native.word('platform_budget'),ref.next_nmi-ref.cpu.processorCycles)

    def test_bank_switch_crosses_native_window_without_touching_hardware_code(self):
        for bank in range(8):
            ref = Machine()
            ref.cpu.a = bank
            native = NativePlatform(ref)
            ref.call(0xfeee)
            native.put_word('vm_pc',0xfeee)
            native.memory[0x11ff],native.memory[0x11fe] = 0x0f,0xfe
            native.set('sp',0xfd)
            native.run('platform_run_call')
            self.equal_state(ref,native)
            self.assertEqual(native.memory.switches,[bank])


if __name__ == '__main__':
    unittest.main()
