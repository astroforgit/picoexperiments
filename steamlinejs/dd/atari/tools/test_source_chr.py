#!/usr/bin/env python3
"""Execute the native 6502 decoder on every original graphics set."""
import unittest
from py65.devices.mpu6502 import MPU
from build_source_engine import OUT
from pack_source_chr import pack, unpack, sets
from make_assets import raw, tile


def native_decode(data, size):
    memory = bytearray(65536)
    decoder = (OUT / 'unpack.bin').read_bytes()
    memory[0x1000:0x1000+len(decoder)] = decoder
    memory[0x3000:0x3000+len(data)] = data
    memory[0x5ff0:0x6000] = bytes([0xa5])*16
    memory[0x6000+size:0x6010+size] = bytes([0xa5])*16
    for pointer, value in ((0xe0, 0x3000), (0xe2, 0x3000+len(data)),
                           (0xe4, 0x6000), (0xe6, 0x6000+size)):
        memory[pointer:pointer+2] = value.to_bytes(2, 'little')
    cpu = MPU(memory=memory, pc=0x1000)
    cpu.stPushWord(0x1fff)
    for _ in range(1000000):
        if cpu.pc == 0x2000: break
        cpu.step()
    else:
        raise AssertionError(f'decoder did not return at ${cpu.pc:04x}')
    assert memory[0x5ff0:0x6000] == bytes([0xa5])*16
    assert memory[0x6000+size:0x6010+size] == bytes([0xa5])*16
    return bytes(memory[0x6000:0x6000+size]), bool(cpu.p & cpu.CARRY)


class SourceChrTests(unittest.TestCase):
    def test_native_expansion_preserves_every_source_pixel(self):
        code = (OUT / 'expand.bin').read_bytes()
        sources = [raw(f'chrom-tiles-{bank}.asm') for bank in range(8)]
        for index, data in enumerate(sets()):
            memory = bytearray(65536)
            memory[0x1200:0x1200+len(code)] = code
            memory[0x3000:0x4000] = data
            memory[0xe0:0xe4] = bytes([0, 0x30, 0, 0x80])
            memory[0x7fff] = memory[0xc000] = 0xa5
            cpu = MPU(memory=memory, pc=0x1200)
            cpu.stPushWord(0x1fff)
            for _ in range(300000):
                if cpu.pc == 0x2000: break
                cpu.step()
            else:
                self.fail('expansion did not return')
            expected = bytes(value for number in range(256)
                             for value in tile(sources[index//4], (index%4)*256+number))
            self.assertEqual(memory[0x8000:0xc000], expected)
            self.assertEqual(memory[0x7fff], 0xa5)
            self.assertEqual(memory[0xc000], 0xa5)

    def test_all_32_source_sets_on_native_6502(self):
        images = list(sets())
        self.assertEqual(len(images), 32)
        for index, data in enumerate(images):
            with self.subTest(chr_set=index):
                packed = pack(data)
                self.assertEqual(unpack(packed, len(data)), data)
                actual, error = native_decode(packed, len(data))
                self.assertFalse(error)
                self.assertEqual(actual, data)

    def test_packet_boundaries(self):
        for data in (b'', bytes([7]), bytes([7])*128, bytes([7])*129,
                     bytes(range(128)), bytes(range(256))*16):
            packed = pack(data)
            self.assertEqual(unpack(packed, len(data)), data)
            actual, error = native_decode(packed, len(data))
            self.assertFalse(error)
            self.assertEqual(actual, data)

    def test_malformed_data_returns_error_without_overrun(self):
        for data, length in ((b'', 1), (b'\x80', 1), (b'\x01\x12', 2),
                             (b'\xff\x42', 127), (b'\x00\x42\x80', 1),
                             (b'\x00\x42', 0)):
            with self.assertRaises(ValueError): unpack(data, length)
            _, error = native_decode(data, length)
            self.assertTrue(error)


if __name__ == '__main__':
    unittest.main()
