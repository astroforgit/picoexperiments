#!/usr/bin/env python3
"""Execute the native address bridge; compare every official source opcode."""
import random
import unittest
from py65.devices.mpu6502 import MPU
from build_source_engine import OUT


def labels():
    return {p[2].lower(): int(p[1],16)
            for line in (OUT/'cpu.lab').read_text().splitlines()
            if len(p := line.split()) == 3}


class NativeCPU:
    def __init__(self, guest=None):
        self.symbols = labels()
        self.memory = bytearray(65536)
        code = (OUT/'cpu.bin').read_bytes()
        self.memory[0x2000:0x2000+len(code)] = code
        if guest is not None:
            self.memory[0x1000:0x2000] = guest[:0x1000]
            self.memory[0x4000:0x8000] = guest[0xc000:]
            self.memory[0x8000:0xc000] = guest[0x8000:0xc000]
        self.cpu = MPU(memory=self.memory)

    def set(self, name, value):
        self.memory[self.symbols['vm_'+name]] = value

    def get(self, name):
        return self.memory[self.symbols['vm_'+name]]

    def import_state(self, cpu):
        for name in ('a','x','y','p','sp'):
            self.set(name, getattr(cpu,name))
        address = self.symbols['vm_pc']
        self.memory[address:address+2] = cpu.pc.to_bytes(2,'little')

    def state(self):
        p = self.symbols['vm_pc']
        return tuple(self.get(name) for name in ('a','x','y','p','sp')) + (
            int.from_bytes(self.memory[p:p+2],'little'),)

    def call(self, label='vm_step'):
        saved_sp = self.cpu.sp
        self.cpu.stPushWord(0x0ffe)
        self.cpu.pc = self.symbols[label]
        before = self.cpu.processorCycles
        for _ in range(2000):
            if self.cpu.pc == 0x0fff:
                assert self.cpu.sp == saved_sp, 'host stack imbalance'
                return self.cpu.processorCycles-before
            self.cpu.step()
        raise AssertionError(f'native bridge did not return at ${self.cpu.pc:04x}')


class SourceCPUTests(unittest.TestCase):
    def compare(self, reference, native, nmi=False):
        before = reference.processorCycles
        if nmi:
            reference.nmi()
        else:
            reference.step()
        native.call('vm_nmi' if nmi else 'vm_step')
        self.assertEqual(native.get('fault'), 0)
        self.assertEqual(native.state(), tuple(getattr(reference,n) for n in ('a','x','y','p','sp','pc')))
        self.assertEqual(native.get('cycles'), reference.processorCycles-before)
        self.assertEqual(native.memory[0x1000:0x2000], bytes(reference.memory[:0x1000]))

    def test_all_151_opcodes_registers_flags_addressing_and_cycles(self):
        rng = random.Random(0x2a03)
        opcode_count = cases = 0
        for op, (name, mode) in enumerate(MPU.disassemble):
            if name == '???':
                continue
            opcode_count += 1
            for variant in range(24):
                memory = bytearray(65536)
                memory[:0x1000] = rng.getrandbits(0x8000).to_bytes(0x1000,'little')
                pc = (0xc100,0xc1fd,0xc1fe)[variant%3]
                memory[pc:pc+3] = bytes((op,0xff,0x04))
                if mode == 'imm':
                    memory[pc+1] = (0,1,0x7f,0x80,0xff,rng.randrange(256))[variant%6]
                elif mode == 'rel':
                    memory[pc+1] = (0,1,127,128,255,rng.randrange(256))[variant%6]
                memory[0xfffa:0x10000] = bytes((0x34,0xc2,0x45,0xc2,0x56,0xc2))
                cpu = MPU(memory=memory, pc=pc)
                cpu.a = (0,1,127,128,255,rng.randrange(256))[variant%6]
                cpu.x, cpu.y, cpu.sp = rng.randrange(256), rng.randrange(256), rng.randrange(256)
                cpu.p = 0x30 | (rng.randrange(256) & 0xc7)  # binary arithmetic
                if mode in ('inx','iny'):
                    pointer = (0xff+cpu.x)&255 if mode == 'inx' else 0xff
                    memory[pointer], memory[(pointer+1)&255] = 0xff,0x04
                elif mode == 'ind':
                    memory[0x4ff], memory[0x400], memory[0x500] = 0x45,0xc3,0xee
                native = NativeCPU(memory)
                native.import_state(cpu)
                with self.subTest(op=f'{op:02x}', name=name, mode=mode, variant=variant):
                    self.compare(cpu, native)
                cases += 1
        self.assertEqual(opcode_count,151)
        print(f'Compared {cases} native instruction cases across all {opcode_count} official opcodes.')

    def test_computed_jump_and_calls_preserve_virtual_return_addresses(self):
        memory = bytearray(65536)
        memory[0xc100:0xc106] = bytes((0x20,0x00,0xd0,0x6c,0xff,0x04))
        memory[0xd000:0xd003] = bytes((0xa9,0x75,0x60))
        memory[0x4ff], memory[0x400] = 0x00,0x80
        memory[0x8000:0x8003] = bytes((0x8d,0x00,0x06))
        cpu = MPU(memory=memory,pc=0xc100)
        native = NativeCPU(memory)
        native.import_state(cpu)
        for _ in range(5):
            self.compare(cpu,native)
        self.assertEqual(native.memory[0x1600],0x75)
        self.assertEqual(native.state()[-1],0x8003)
        self.assertEqual(native.memory[0xd000],0, 'guest D000 touched Atari hardware')

    def test_nmi_uses_guest_stack_and_preserves_host_stack(self):
        for stack in (0,1,2,128,255):
            memory = bytearray(65536)
            memory[0xfffa:0xfffc] = bytes((0x00,0xd1))
            memory[0xd100] = 0x40
            cpu = MPU(memory=memory,pc=0xc567)
            cpu.sp, cpu.p = stack,0xe1
            native = NativeCPU(memory)
            native.import_state(cpu)
            self.compare(cpu,native,nmi=True)
            self.compare(cpu,native)
            self.assertEqual(cpu.pc,0xc567)

    def test_guest_decimal_flag_does_not_enable_host_decimal_arithmetic(self):
        # Ricoh 2A03 retains D but always uses binary ADC/SBC.
        for op in (0x69,0xe9):
            memory = bytearray(65536)
            memory[0xc100:0xc102] = bytes((op,0x19))
            cpu = MPU(memory=memory,pc=0xc100)
            cpu.a, cpu.p = 0x29,0x31
            native = NativeCPU(memory)
            native.import_state(cpu)
            native.set('p',cpu.p | cpu.DECIMAL)
            cpu.step()
            cpu.p |= cpu.DECIMAL
            native.call()
            self.assertEqual(native.state(),tuple(getattr(cpu,n) for n in ('a','x','y','p','sp','pc')))
            self.assertFalse(native.cpu.p & native.cpu.DECIMAL)

    def test_unsupported_io_and_rom_writes_fail_explicitly(self):
        for code, fault in ((bytes((0xad,0x18,0x21)),2), (bytes((0x8d,0,0x80)),3), (bytes((2,)),1)):
            memory = bytearray(65536)
            memory[0xc100:0xc100+len(code)] = code
            cpu = MPU(memory=memory,pc=0xc100)
            native = NativeCPU(memory)
            native.import_state(cpu)
            native.call()
            self.assertEqual(native.get('fault'),fault)
            self.assertEqual(native.memory[0xd000:0xd800],bytes(0x800))
            p = native.symbols['vm_fault_pc']
            self.assertEqual(native.memory[p:p+2],bytes((0,0xc1)))


if __name__ == '__main__':
    unittest.main()
