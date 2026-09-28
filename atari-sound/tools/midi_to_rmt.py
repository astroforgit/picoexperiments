#!/usr/bin/env python3
"""Convert a MIDI arrangement to a four-voice Raster Music Tracker module.

An existing four-channel RMT song supplies its instrument definitions. MIDI
parts are reduced to one note per POKEY voice and quantized to RMT rows.
"""
import argparse
from bisect import bisect_right
from collections import defaultdict
from dataclasses import dataclass
import json
from pathlib import Path
import struct

try:
    import mido
except ImportError as exc:
    raise SystemExit('Install the MIDI parser first: python3 -m pip install mido') from exc

PAL_FPS = 1773447 / (114 * 312)
ROOT = Path(__file__).resolve().parents[1]
DEFAULT_TEMPLATE = ROOT / 'asma/asma/Misc/Chicken_Valley.rmt'
DEFAULT_INSTRUMENTS = {'melody': 2, 'accompaniment': 7, 'bass': 0, 'kick': 4, 'snare': 5, 'hat': 6}


@dataclass(frozen=True)
class Note:
    start: float
    end: float
    pitch: int
    velocity: int
    channel: int
    uid: int


def midi_tracks(path):
    midi = mido.MidiFile(path)
    if midi.type == 2:
        raise ValueError('Asynchronous type-2 MIDI files are unsupported')
    tempo_events = [(0, 500000)]
    for track in midi.tracks:
        tick = 0
        for msg in track:
            tick += msg.time
            if msg.type == 'set_tempo':
                tempo_events.append((tick, msg.tempo))
    tempo_events.sort(key=lambda item: item[0])
    ticks = [0]
    seconds = [0.0]
    tempos = [500000]
    for tick, tempo in tempo_events:
        if tick == ticks[-1]:
            tempos[-1] = tempo
        else:
            seconds.append(seconds[-1] + (tick - ticks[-1]) * tempos[-1] / (midi.ticks_per_beat * 1000000))
            ticks.append(tick)
            tempos.append(tempo)

    def to_seconds(tick):
        i = bisect_right(ticks, tick) - 1
        return seconds[i] + (tick - ticks[i]) * tempos[i] / (midi.ticks_per_beat * 1000000)

    result = []
    uid = 0
    for number, track in enumerate(midi.tracks):
        tick = 0
        name = f'Track {number + 1}'
        active = defaultdict(list)
        notes = []
        channel_counts = defaultdict(int)
        for msg in track:
            tick += msg.time
            if msg.type == 'track_name':
                name = msg.name.strip() or name
            elif msg.type == 'note_on' and msg.velocity:
                uid += 1
                active[(msg.channel, msg.note)].append((tick, msg.velocity, uid))
                channel_counts[msg.channel] += 1
            elif msg.type in ('note_off', 'note_on'):
                key = (msg.channel, msg.note)
                if active[key]:
                    start, velocity, note_id = active[key].pop(0)
                    if tick > start:
                        notes.append(Note(to_seconds(start), to_seconds(tick), msg.note, velocity, msg.channel, note_id))
        if notes:
            result.append({'name': name, 'notes': notes, 'drums': channel_counts.get(9, 0) > sum(channel_counts.values()) / 2})
    return result


def choose_parts(tracks):
    drums = next((t for t in tracks if t['drums']), None)
    tonal = [t for t in tracks if t is not drums]
    if not tonal:
        raise ValueError('No melodic MIDI notes found')
    def pitch(track):
        values = sorted(note.pitch for note in track['notes'])
        return values[len(values) // 2]
    bass = next((t for t in tonal if 'bass' in t['name'].lower()), min(tonal, key=pitch))
    remaining = [t for t in tonal if t is not bass]
    melody = next((t for t in remaining if any(word in t['name'].lower() for word in ('melody', 'lead'))),
                  max(remaining, key=pitch) if remaining else bass)
    remaining = [t for t in remaining if t is not melody]
    accompaniment = next((t for t in remaining if any(word in t['name'].lower() for word in ('accomp', 'harmony', 'chord'))),
                         max(remaining, key=lambda t: len(t['notes'])) if remaining else None)
    return [melody, accompaniment, bass, drums]


def quantize(notes, step, role):
    rows = defaultdict(list)
    for note in notes:
        first = max(0, round(note.start / step))
        end = max(first + 1, round(note.end / step))
        for row in range(first, end):
            rows[row].append(note)
    chosen = {}
    for row, candidates in rows.items():
        if role == 'drums':
            # MIDI channel 10: bass drum, snare, then hi-hat if simultaneous.
            onset = [n for n in candidates if round(n.start / step) == row]
            if not onset:
                continue
            chosen[row] = max(onset, key=lambda n: ({36: 3, 38: 2, 42: 1}.get(n.pitch, 0), n.velocity))
        elif role == 'bass':
            chosen[row] = min(candidates, key=lambda n: (n.pitch, -n.velocity, -n.start))
        elif role == 'melody':
            chosen[row] = max(candidates, key=lambda n: (n.pitch, n.velocity, n.start))
        else:
            chosen[row] = max(candidates, key=lambda n: (n.velocity, n.start, n.pitch))
    return chosen


def instrument_and_pitch(note, role, instruments):
    if role == 'drums':
        instrument = {36: instruments['kick'], 38: instruments['snare'], 42: instruments['hat']}.get(note.pitch, instruments['snare'])
        return instrument, {36: 12, 38: 25, 42: 42}.get(note.pitch, 25), 0
    instrument = instruments[role]
    pitch = note.pitch
    shift = 0
    while pitch < 36:
        pitch += 12
        shift += 12
    while pitch > 96:
        pitch -= 12
        shift -= 12
    return instrument, pitch - 36, shift


def note_bytes(pitch, instrument, volume):
    if not 0 <= pitch <= 60 or not 0 <= instrument < 64 or not 0 <= volume <= 15:
        raise ValueError('RMT note field outside range')
    return bytes((pitch | ((volume & 3) << 6), (instrument << 2) | (volume >> 2)))


def encode_track(rows, role, instruments, length=64):
    data = bytearray()
    previous = None
    chosen_ids = set()
    octave_shifts = 0
    for row in range(length):
        note = rows.get(row)
        if note is None:
            data.extend((61, 0) if previous is not None or row == 0 else (62, 1))
            previous = None
        elif previous == note.uid:
            data.extend((62, 1))
        else:
            instrument, pitch, shift = instrument_and_pitch(note, role, instruments)
            volume = max(2, min(10, round(note.velocity * 10 / 127)))
            data.extend(note_bytes(pitch, instrument, volume))
            chosen_ids.add(note.uid)
            octave_shifts += int(shift != 0)
            previous = note.uid
    data.append(255)
    return bytes(data), chosen_ids, octave_shifts


def make_module(template, parts, speed, instruments=DEFAULT_INSTRUMENTS):
    raw = bytearray(template.read_bytes())
    if raw[:2] != b'\xff\xff' or raw[6:10] != b'RMT4':
        raise ValueError('Template must be a four-channel RMT module with an Atari load header')
    start, end = struct.unpack_from('<HH', raw, 2)
    if len(raw) != 6 + end - start + 1:
        raise ValueError('Template has unexpected segment length')
    table = struct.unpack_from('<H', raw, 14)[0] - start + 6
    lo_table = struct.unpack_from('<H', raw, 16)[0]
    hi_table = struct.unpack_from('<H', raw, 18)[0]
    instrument_count = (lo_table - start + 6 - table) // 2
    track_capacity = hi_table - lo_table
    instrument_pointers = []
    for i in range(instrument_count):
        instrument_pointers.append(struct.unpack_from('<H', raw, table + 2 * i)[0])
    for i in set(instruments.values()):
        if not 0 <= i < instrument_count or instrument_pointers[i] == 0:
            raise ValueError(f'Template lacks instrument {i}')
    old_tracks = [raw[lo_table - start + 6 + i] + 256 * raw[hi_table - start + 6 + i]
                  for i in range(track_capacity)]
    first_track = min((pointer for pointer in old_tracks if pointer), default=0)
    if not first_track or first_track <= max(instrument_pointers) or first_track > end:
        raise ValueError('Template does not have a separate instrument block before its tracks')
    # Keep the donor's instrument definitions, discard its original tune.
    raw = raw[:first_track - start + 6]
    for i in range(track_capacity):
        raw[lo_table - start + 6 + i] = 0
        raw[hi_table - start + 6 + i] = 0
    raw[10] = 64
    raw[11] = speed
    raw[12] = 1
    step = speed / PAL_FPS
    roles = ['melody', 'accompaniment', 'bass', 'drums']
    quantized = [quantize(part['notes'], step, role) if part else {} for part, role in zip(parts, roles)]
    last_row = max((max(rows, default=0) for rows in quantized), default=0)
    lines = (last_row + 64) // 64
    if lines * 4 > min(254, track_capacity):
        raise ValueError(f'Song needs {lines * 4} tracks; template has room for {track_capacity}')
    def address():
        return start + len(raw) - 6
    retained_by_voice = [set() for _ in range(4)]
    shifted_by_voice = [0] * 4
    for line in range(lines):
        for voice, (rows, role) in enumerate(zip(quantized, roles)):
            relative = {row - line * 64: note for row, note in rows.items() if line * 64 <= row < (line + 1) * 64}
            encoded, retained, shifted = encode_track(relative, role, instruments)
            pointer = address()
            raw[lo_table - start + 6 + line * 4 + voice] = pointer & 255
            raw[hi_table - start + 6 + line * 4 + voice] = pointer >> 8
            raw.extend(encoded)
            retained_by_voice[voice].update(retained)
            shifted_by_voice[voice] += shifted
    song_address = address()
    for line in range(lines):
        raw.extend(bytes(range(line * 4, line * 4 + 4)))
    raw.extend((254, 0, song_address & 255, song_address >> 8))
    if address() > 65535:
        raise ValueError('RMT module exceeds Atari address space')
    struct.pack_into('<H', raw, 20, song_address)
    struct.pack_into('<H', raw, 4, address() - 1)
    # Each MIDI note has a stable ID, so counts exclude held rows and retriggers.
    retained = set().union(*retained_by_voice)
    voice_report = {}
    for i, (role, part) in enumerate(zip(roles, parts)):
        voice_report[role] = {'midi_track': part['name'] if part else None,
                              'source_notes': len(part['notes']) if part else 0,
                              'retained_note_onsets': len(retained_by_voice[i]),
                              'octave_shifted_onsets': shifted_by_voice[i]}
    try:
        donor_path = str(template.relative_to(ROOT))
    except ValueError:
        donor_path = str(template)
    report = {'instrument_source': donor_path, 'instrument_ids': instruments,
              'rmt_rows': lines * 64, 'row_seconds': step,
              'duration_seconds': lines * 64 * step, 'source_notes': sum(len(p['notes']) for p in parts if p),
              'retained_note_onsets': len(retained),
              'dropped_notes': sum(len(p['notes']) for p in parts if p) - len(retained),
              'voices': voice_report}
    return bytes(raw), report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('midi', type=Path)
    parser.add_argument('-o', '--output', type=Path)
    parser.add_argument('--template', type=Path, default=DEFAULT_TEMPLATE)
    parser.add_argument('--speed', type=int, default=8, help='PAL frames per RMT row (default: 8)')
    for name, default in DEFAULT_INSTRUMENTS.items():
        parser.add_argument('--' + name.replace('_', '-') + '-inst', type=int, default=default,
                            help=f'RMT instrument index for {name} (default: {default})')
    args = parser.parse_args()
    if not 1 <= args.speed <= 255:
        parser.error('--speed must be between 1 and 255')
    tracks = midi_tracks(args.midi)
    parts = choose_parts(tracks)
    instruments = {name: getattr(args, name + '_inst') for name in DEFAULT_INSTRUMENTS}
    module, report = make_module(args.template, parts, args.speed, instruments)
    output = args.output or args.midi.with_suffix('.rmt')
    output.write_bytes(module)
    output.with_suffix('.conversion.json').write_text(json.dumps(report, indent=2) + '\n')
    print(f'Wrote {output} ({len(module)} bytes)')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
