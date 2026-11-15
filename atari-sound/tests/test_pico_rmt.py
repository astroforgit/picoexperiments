"""Musical constraints for the alternate PICO arrangements."""
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'tools'))
import convert
import pico_rmt


class RmtArrangementTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.bank = json.loads((ROOT/'rmt-variations/instrument-bank.json').read_text())

    def fixture(self, channels):
        cart = dict(sfx=[convert.blank_sfx() for _ in range(64)],
                    music=[dict(flags=4, channels=channels)] + [dict(flags=0, channels=[64]*4)]*63)
        for sid in range(4):
            cart['sfx'][sid].update(speed=16, notes=[[36+sid*4, 0, 7, 0]]*32)
        return cart

    def test_rests_and_spare_channels_stay_silent(self):
        cart = self.fixture([64]*4)
        settings = pico_rmt.profile(cart, 'Silent', self.bank)
        self.assertEqual(set(pico_rmt.render(cart['music'][0], cart['sfx'], 200, settings, self.bank)), {bytes(9)})
        cart = self.fixture([0, 1, 64, 64])
        settings = pico_rmt.profile(cart, 'Test', self.bank)
        for frame in pico_rmt.render(cart['music'][0], cart['sfx'], 200, settings, self.bank):
            self.assertEqual(frame[4:], bytes(5))

    def test_held_melody_does_not_collapse_into_clicks(self):
        cart = self.fixture([0, 1, 2, 3])
        for sid in range(4): cart['sfx'][sid]['speed'] = 128
        for instrument in self.bank['voices']:
            settings = pico_rmt.profile(cart, 'Test', self.bank)
            for channel in settings['channels']: channel['instrument'] = instrument['id']
            for frame in pico_rmt.render(cart['music'][0], cart['sfx'], 200, settings, self.bank):
                self.assertEqual(frame[8], 0)
                self.assertTrue(all(f & 15 for f in frame[1:8:2]))
                self.assertTrue(all(f & 240 == 160 for f in frame[1:8:2]))

    def test_tempo_and_loops_are_preserved(self):
        cart = self.fixture([0, 1, 64, 64])
        cart['music'][0]['flags'] = 3
        settings = pico_rmt.profile(cart, 'Test', self.bank)
        def renderer(pid, pattern, sfx):
            count = round(convert.duration_ticks(pattern, sfx)*convert.TICK*convert.FPS)
            return pico_rmt.render(pattern, sfx, count, settings, self.bank)
        _, entries = convert.make_entries(cart, renderer)
        self.assertEqual(sum(e['frames'] for e in entries), round(32*16*convert.TICK*convert.FPS))
        self.assertEqual(entries[-1]['next_id'], 0)
        self.assertEqual(len(list(convert.decode(entries[0]['data']))), entries[0]['frames'])

    def test_donor_choice_is_consistent_and_deterministic(self):
        cart = self.fixture([0, 1, 64, 64])
        settings = pico_rmt.profile(cart, 'Test', self.bank)
        self.assertEqual(settings, pico_rmt.profile(cart, 'Test', self.bank))
        lookup = {v['id']: v for v in self.bank['voices']}
        self.assertEqual(len({lookup[c['instrument']]['source'] for c in settings['channels']}), 1)
        self.assertFalse(settings['added_percussion'])


if __name__ == '__main__': unittest.main()
