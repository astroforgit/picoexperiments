"""Check MIDI timing and the generated RMT module layout."""
import struct
import sys
import tempfile
from pathlib import Path
import unittest

import mido

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
import midi_to_rmt


class MidiToRmtTests(unittest.TestCase):
    def test_tempo_map_and_named_parts(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'tempo.mid'
            song = mido.MidiFile(type=1, ticks_per_beat=480)
            timing = mido.MidiTrack()
            timing.append(mido.MetaMessage('set_tempo', tempo=500000, time=0))
            timing.append(mido.MetaMessage('set_tempo', tempo=1000000, time=480))
            song.tracks.append(timing)
            lead = mido.MidiTrack()
            lead.append(mido.MetaMessage('track_name', name='Melody'))
            lead.append(mido.Message('note_on', note=60, velocity=100, channel=0, time=0))
            lead.append(mido.Message('note_off', note=60, velocity=0, channel=0, time=960))
            song.tracks.append(lead)
            song.save(path)
            parts = midi_to_rmt.choose_parts(midi_to_rmt.midi_tracks(path))
            self.assertEqual(parts[0]['name'], 'Melody')
            self.assertAlmostEqual(parts[0]['notes'][0].end, 1.5)

    def test_module_reuses_instruments_without_old_song(self):
        note = midi_to_rmt.Note(0, 0.5, 72, 100, 0, 1)
        parts = [{'name': 'Melody', 'notes': [note]}, None, None, None]
        template = midi_to_rmt.DEFAULT_TEMPLATE
        original = template.read_bytes()
        module, report = midi_to_rmt.make_module(template, parts, 8)
        start = struct.unpack_from('<H', module, 2)[0]
        old_end = struct.unpack_from('<H', original, 4)[0]
        inst_table, track_lo, track_hi, song = struct.unpack_from('<HHHH', module, 14)
        self.assertEqual((track_lo - inst_table) // 2, 8)
        self.assertEqual(track_hi - track_lo, 36)
        self.assertEqual(module[6:10], b'RMT4')
        self.assertLess(len(module), len(original))
        self.assertLess(struct.unpack_from('<H', module, 4)[0], old_end)
        self.assertEqual(module[song - start + 6:song - start + 10], bytes(range(4)))
        self.assertEqual(report['retained_note_onsets'], 1)
        self.assertEqual(report['dropped_notes'], 0)


if __name__ == '__main__':
    unittest.main()
