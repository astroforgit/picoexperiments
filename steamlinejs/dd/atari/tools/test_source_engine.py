#!/usr/bin/env python3
"""Check recovered source layout and execute original campaign/movement code."""
import hashlib
import json
import unittest

from build_source_engine import SOURCE, OUT, translate
from source_machine import Machine


class SourceEngineTests(unittest.TestCase):
    def test_all_banks_match_manifest_and_inputs(self):
        manifest = json.loads((OUT / 'manifest.json').read_text())
        self.assertEqual([record['bank'] for record in manifest['banks']], list(range(8)))
        for record in manifest['banks']:
            bank = record['bank']
            data = (OUT / f'bank{bank}.bin').read_bytes()
            self.assertEqual(len(data), 0x4000)
            self.assertEqual(hashlib.sha256(data).hexdigest(), record['sha256'])
            self.assertEqual(hashlib.sha256((SOURCE / f'bank{bank}.asm').read_bytes()).hexdigest(),
                             record['source_sha256'])

    def test_data_banks_are_byte_exact(self):
        # These banks contain only literal bytes. Bank 5/6 must instead be
        # assembled: dropping their non-.byte lines shifts gameplay code.
        for bank in range(5):
            values = []
            for line in (SOURCE / f'bank{bank}.asm').read_text().splitlines():
                code = line.split(';', 1)[0].strip()
                if code.startswith('.byte '):
                    values.extend(int(item.strip()[1:], 16) for item in code[6:].split(','))
            self.assertEqual(bytes(values), (OUT / f'bank{bank}.bin').read_bytes())

    def test_services_are_explicit_and_msu_disabled(self):
        services = {}
        for bank in range(8): translate(bank, services)
        self.assertNotIn('msu_check', services)
        self.assertEqual(len(services), len(set(services.values())))
        with self.assertRaisesRegex(RuntimeError, 'unimplemented hardware service'):
            Machine().service('unknown_service')

    def test_all_eleven_original_sections_initialize(self):
        records = []
        m = Machine().mem
        section_counts = [m[0xe76f+i] for i in range(4)]
        self.assertEqual(section_counts, [2, 1, 4, 4])
        expected_records = [0x9c97, 0x9ce2, 0x9d00, 0x9d3c, 0x9d96, 0x9dff,
                            0x9e59, 0x9e77, 0x9ed1, 0x9ee0, 0x9f49]
        for stage, count in enumerate(section_counts):
            for section in range(count):
                machine = Machine()
                m = machine.mem
                m[0x3d], m[0x3e] = stage, section
                m[0x33] = 1
                m[0x47] = 0x10  # original camera-initialization flag
                original_sp = machine.cpu.sp
                machine.call(0x9924)
                self.assertEqual(machine.cpu.sp, original_sp)
                self.assertEqual(m.bank, 6)
                self.assertEqual(m[0x4a], 0x80)
                records.append(m.word(0x25))
        self.assertEqual(records, expected_records)

    def test_original_signed_position_integration(self):
        for routine, offsets in ((0xde78, (0x52, 0x5a, 0x62)),
                                 (0xde99, (0x6a, 0x72, 0x7a))):
            for slot in range(8):
                for position in (0, 0x123456, 0xfffff0):
                    for delta in (-32768, -257, -1, 0, 1, 511, 32767):
                        machine = Machine()
                        m = machine.mem
                        machine.cpu.x = slot
                        for shift, offset in enumerate(offsets):
                            m[offset+slot] = (position >> (shift*8)) & 255
                        src = 0x25 if routine == 0xde78 else 0x27
                        m[src], m[src+1] = delta & 255, (delta >> 8) & 255
                        machine.call(routine)
                        actual = sum(m[offset+slot] << (shift*8)
                                     for shift, offset in enumerate(offsets))
                        self.assertEqual(actual, (position+delta) & 0xffffff)

    def test_music_requests_never_enter_audio_bank(self):
        for command in (0, 0x1f, 0x20, 0x21, 0x2b, 0xff):
            machine = Machine()
            machine.cpu.a = command
            machine.call(0xfbe1)
            self.assertEqual(machine.effects, [])
            self.assertEqual(machine.mem.bank, 6)
        machine = Machine()
        machine.cpu.a = 0x0a
        machine.call(0xfbe1)
        self.assertEqual(machine.effects, [(0, 0x0a)])
        self.assertNotIn((5, 0x8000), machine.visited)

    def test_vblank_barrier_preserves_game_state(self):
        machine = Machine()
        machine.mem[0xff] = 0x90
        machine.mem[0x100] = 0xc0
        machine.cpu.a = 0x42
        machine.call(0xfc80)
        self.assertEqual(machine.frames, 1)
        self.assertEqual(machine.mem[0xff], 0x10)
        self.assertEqual(machine.mem[0x100], 0xc0)
        self.assertEqual(machine.cpu.a, 0x42)


if __name__ == '__main__':
    unittest.main()
