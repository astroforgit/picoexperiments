#!/usr/bin/env python3
"""Run C64 Cauldron (Palace Software, 1985) in the headless model (tools/c64.py).

The state after CAU_CODE is built directly: $0900-$28FF of CAU_CODE copied to
$E000-$FFFF (RAM under the KERNAL), PALACE loaded at its file address, $AC03 =
$0B, then JMP $800A with the KERNAL still banked in ($01 = $37).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from c64 import C64  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DISK = os.path.join(HERE, 'disk')


def disk(name):
    return open(os.path.join(DISK, name + '.prg'), 'rb').read()


class Cauldron(C64):
    def __init__(self):
        super().__init__()
        ram = self.mem.ram
        code = disk('CAU_CODE')
        ram[0x0801:0x0801 + len(code) - 2] = code[2:]
        ram[0xE000:0x10000] = ram[0x0900:0x2900]
        self.load_prg(disk('PALACE'))
        ram[0xAC03] = 0x0B
        self.port[:] = bytes([0x2F, 0x37])
        ram[0] = 0x2F
        ram[1] = 0x37
        self.kernal_calls = {}
        self.collide = True       # (the game reacts to sprite collisions)
        cpu = self.cpu
        cpu.pc = 0x800A
        cpu.sp = 0xF6
        cpu.p = 0x24
        # CIA1 timer A runs the KERNAL's 60 Hz IRQ at power-on
        self.cia1.la = self.cia1.ta = 0x4025
        self.cia1.cra = 0x11 & 0xEF | 1
        self.cia1.icr_mask = 1
        self.cia2.regs[0] = 0x97
        self.vic[0x18] = 0x15
        self.vic[0x11] = 0x1B
        self.vic[0x16] = 0xC8

    def run(self, max_cycles, stop=None):
        return super().run(max_cycles, stop)
