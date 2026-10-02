#!/usr/bin/env python3
"""Differential tests: native terrain queries versus assembled source bank 5."""
import json
import random
import unittest
from py65.devices.mpu6502 import MPU
from build_source_engine import OUT
from build_source_terrain import BASE, START, END, COUNTS, relocate


class CheckedMemory:
    """Trap every unexpected read/write instead of returning plausible zeroes."""
    def __init__(self, ram, rom, base):
        self.ram = bytearray(ram)
        self.rom, self.base = rom, base
        self.written = set()

    def __getitem__(self, address):
        if self.base <= address < self.base + len(self.rom):
            return self.rom[address-self.base]
        if 0 <= address < len(self.ram):
            return self.ram[address]
        raise AssertionError(f'unexpected read ${address:04x}')

    def __setitem__(self, address, value):
        if not 0 <= address < len(self.ram):
            raise AssertionError(f'unexpected write ${address:04x}')
        self.ram[address] = value
        self.written.add(address)


def execute(ram, rom, base, entry, registers):
    memory = CheckedMemory(ram, rom, base)
    cpu = MPU(memory=memory, pc=entry)
    cpu.a, cpu.x, cpu.y, cpu.p = registers
    cpu.stPushWord(0x0ffe)
    for _ in range(5000):
        if cpu.pc == 0x0fff:
            return cpu, memory
        if not base <= cpu.pc < base + len(rom):
            raise AssertionError(f'execution escaped terrain at ${cpu.pc:04x}')
        cpu.step()
    raise AssertionError('terrain query did not terminate')


class TerrainTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.bank = (OUT / 'bank5.bin').read_bytes()
        _, cls.patches = relocate(cls.bank)
        cls.native = (OUT / 'terrain-assembled.bin').read_bytes()

    def compare(self, ram, entry, registers=(0x53, 0, 0x97, 0x20), base=BASE):
        native = self.native if base == BASE else relocate(self.bank, base)[0]
        source_cpu, source = execute(ram, self.bank, 0x8000, entry, registers)
        cpu, actual = execute(ram, native, base, base+entry-START, registers)
        self.assertEqual((cpu.a, cpu.x, cpu.y, cpu.p, cpu.sp),
                         (source_cpu.a, source_cpu.x, source_cpu.y, source_cpu.p, source_cpu.sp))
        self.assertEqual(actual.written, source.written)
        # Only scratch pointer values are expected to differ after relocation.
        for pointer in (0x29, 0x2b):
            original = source.ram[pointer] | source.ram[pointer+1] << 8
            got = actual.ram[pointer] | actual.ram[pointer+1] << 8
            if START <= original < END and got == base+original-START:
                actual.ram[pointer:pointer+2] = source.ram[pointer:pointer+2]
        # JSR return addresses naturally differ. The source stack is private.
        self.assertEqual(actual.ram[:0x100], source.ram[:0x100])
        self.assertEqual(actual.ram[0x200:], source.ram[0x200:])
        self.assertEqual(cpu.processorCycles, source_cpu.processorCycles)
        return bool(cpu.p & cpu.CARRY), actual

    @staticmethod
    def inputs(stage, section, x, depth, height, slot=0):
        ram = bytearray(0x800)
        ram[0x3d], ram[0x3e], ram[0x49] = stage, section, slot
        ram[0x15] = depth
        ram[0x25:0x27] = x.to_bytes(2, 'little')
        ram[0x27:0x29] = height.to_bytes(2, 'little')
        ram[0x23:0x25] = max(0, x-2).to_bytes(2, 'little')
        ram[0x37a] = depth
        ram[0x5a+slot], ram[0x62+slot] = x & 255, x >> 8
        return ram

    def test_boundary_edges_all_sections_layers_and_slots(self):
        # Every piecewise boundary endpoint, including both adjacent pixels;
        # combine with depth/height edges and both mission-4 height layers.
        rng = random.Random(0x6502)
        total = hits = 0
        def word(a):
            return self.bank[a-0x8000] | self.bank[a-0x8000+1] << 8
        for stage, count in enumerate(COUNTS):
            for section in range(count):
                xs = {0, 1, 255, 256, 511, 512, 1023, 2047}
                for layer in range(2):
                    root = word(0xb0f4+stage*4+layer*2)
                    record = word(root+section*4)
                    if record:
                        while True:
                            edge = word(record)
                            if edge == 65535:
                                break
                            xs.update(v for v in (edge-1, edge, edge+1) if v >= 0)
                            record += 12
                for x in sorted(xs):
                    for depth in (0, 1, 47, 48, 49, 79, 80, 95, 96, 97, 127, 128, 254, 255):
                        for height in (0, 7, 8, 159, 160, 255, 256):
                            slot = total % 8
                            ram = self.inputs(stage, section, x, depth, height, slot)
                            regs = (rng.randrange(256), slot, rng.randrange(256),
                                    (0x20 | rng.randrange(256)) & ~0x18)
                            hit, _ = self.compare(ram, 0xb000, regs)
                            hits += hit
                            total += 1
        self.assertGreater(hits, 100)
        self.assertLess(hits, total)
        self.boundary_cases = total
        print(f'Compared {total} boundary queries ({hits} collisions).')

    def test_support_edges_and_falling_height_tolerance(self):
        rng = random.Random(0xb3ec)
        hits = misses = 0
        for stage, count in enumerate(COUNTS):
            for section in range(count):
                for _ in range(1000):
                    x = rng.randrange(2048)
                    height = rng.randrange(513)
                    depth = (0, 0x60, 0x5f, 0x61)[rng.randrange(4)]
                    hit, _ = self.compare(self.inputs(stage, section, x, depth, height), 0xb3ec)
                    hits += hit
                    misses += not hit
        self.assertGreater(hits, 0)
        self.assertGreater(misses, hits)
        # Street platform: x must be > $160 and <= $1ef; height difference
        # must be 0..7. These assertions are independent, hand-decoded fixtures.
        for x in (0x160, 0x161, 0x1ef, 0x1f0):
            for height in (0x48, 0x49, 0x4f, 0x50, 0x51):
                hit, result = self.compare(self.inputs(0, 0, x, 0x60, height), 0xb3ec)
                expected = 0x160 < x <= 0x1ef and 0x49 <= height <= 0x50
                self.assertEqual(hit, expected, (x, height))
                if hit:
                    self.assertEqual(result.ram[0x27:0x29], b'\x50\x00')
        print(f'Compared 11000 support queries ({hits} contacts), plus exact edge fixtures.')

    def test_source_wall_clamps_depth_and_preserves_registers(self):
        for depth, expected in ((0x2f, 0x30), (0x30, 0x30), (0x60, 0x60), (0x61, 0x60)):
            hit, result = self.compare(self.inputs(0, 0, 100, depth, 0), 0xb000)
            self.assertEqual(hit, depth != expected)
            self.assertEqual(result.ram[0x15], expected)

    def test_vertical_wall_faces_all_rectangle_edges(self):
        def word(a):
            return self.bank[a-0x8000] | self.bank[a-0x8000+1] << 8
        cases = 0
        for stage, count in enumerate(COUNTS):
            root = word(0xb78e + stage*2)
            if not root:
                hit, _ = self.compare(self.inputs(stage, 0, 400, 0, 100), 0xb6fd)
                self.assertFalse(hit)
                continue
            for section in range(count):
                depth = self.bank[root+section*3-0x8000]
                if depth == 255:
                    hit, _ = self.compare(self.inputs(stage, section, 400, 0, 100), 0xb6fd)
                    self.assertFalse(hit)
                    continue
                record = word(root+section*3+1)
                while word(record) < 0x8000:
                    left, right, bottom, top = [word(record+i) for i in (0, 2, 4, 6)]
                    for x in {left, left+1, right, right+1}:
                        for height in {max(0, bottom-1), bottom, top, top+1}:
                            for lane in {depth, (depth-1)&255, (depth+1)&255}:
                                self.compare(self.inputs(stage, section, x, lane, height), 0xb6fd)
                                cases += 1
                    record += 9
        # First street face: x is (320,352], height is [72,256], lane 96.
        # It pushes rightward to 352, preserving height and depth.
        for x in (320,321,352,353):
            for height in (71,72,256,257):
                hit, result = self.compare(self.inputs(0,0,x,96,height), 0xb6fd)
                self.assertEqual(hit, 320 < x <= 352 and 72 <= height <= 256)
                if hit:
                    self.assertEqual(int.from_bytes(result.ram[0x25:0x27], 'little'),352)
        print(f'Compared {cases} wall rectangle edge queries, plus exact street fixtures.')

    def test_artifact_and_second_native_address(self):
        self.assertEqual((OUT / 'terrain.bin').read_bytes(), self.native)
        self.assertEqual(relocate(self.bank)[0], self.native)
        manifest = json.loads((OUT / 'terrain.json').read_text())
        self.assertEqual(manifest['relocations'], self.patches)
        for entry in (0xb000, 0xb3ec, 0xb6fd):
            self.compare(self.inputs(0, 0, 0x170, 0x60, 0x50), entry, base=0x6000)

    def test_unknown_external_code_target_is_rejected(self):
        bank = bytearray(self.bank)
        bank[0xb051-0x8000:0xb054-0x8000] = bytes((0x20, 0x00, 0xd0))
        with self.assertRaisesRegex(ValueError, 'escapes terrain'):
            relocate(bank)
        bank[0xb052-0x8000:0xb054-0x8000] = bytes((0x00, 0x20))
        with self.assertRaisesRegex(ValueError, 'escapes terrain'):
            relocate(bank)
        with self.assertRaisesRegex(ValueError, 'page-aligned'):
            relocate(self.bank, BASE+1)


if __name__ == '__main__':
    unittest.main()
