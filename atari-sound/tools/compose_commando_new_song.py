"""Paper Lantern Parade: a new waltz using Commando's instrument colours.

The score is independent of the source game: all four parts, harmony, metre,
rhythms and form are newly written. Only individual envelopes and one isolated
noise hit are sampled from the original register stream.
"""
import math
import build_remixes as b

SOURCE = 'asma/asma/Games/Commando.sap'
SOURCE_SONG = 0
ID = 'commando-instruments-paper-lantern-parade'
TITLE = 'Commando'
REMIX_TITLE = 'Paper Lantern Parade'
LEAD = 3
UNIT = 6
BAR = 12 * UNIT

# One explicitly written 3/4 bar per string, in sixteenth-note units.
INTRO = [
    '-:4 B4:2 D5:2 G5:4', 'F#5:4 D5:4 -:4',
    '-:4 E5:2 G5:2 B5:4', 'A5:4 G5:4 -:4',
    'E5:4 G5:4 C6:4', 'B5:4 A5:2 G5:2 E5:4',
    'F#5:4 A5:4 D6:4', 'A5:4 F#5:4 -:4',
]
VERSE = [
    'B4:3 D5:1 G5:4 F#5:2 D5:2', 'E5:6 D5:2 B4:2 -:2',
    'G5:3 B5:1 A5:4 G5:2 E5:2', 'F#5:4 E5:2 D5:2 B4:4',
    'E5:3 G5:1 C6:4 B5:2 G5:2', 'A5:6 G5:2 E5:2 -:2',
    'F#5:4 A5:2 D6:2 C6:2 A5:2', 'F#5:4 E5:2 D5:2 -:4',
    'B4:2 D5:2 G5:3 A5:1 B5:4', 'A5:4 G5:4 D5:2 -:2',
    'G5:2 B5:2 E6:4 D6:2 B5:2', 'A5:6 G5:2 F#5:2 E5:2',
    'E5:2 G5:2 C6:3 D6:1 E6:4', 'D6:4 C6:2 B5:2 A5:4',
    'A5:4 F#5:2 A5:2 D6:2 C6:2', 'B5:4 A5:2 F#5:2 G5:4',
]
HOOK = [
    'D6:6 B5:2 G5:4', 'A5:3 B5:1 D6:4 B5:2 -:2',
    'E6:4 D6:2 B5:2 G5:4', 'A5:6 B5:2 E6:4',
    'E6:4 D6:2 C6:2 G5:4', 'A5:3 G5:1 E5:4 G5:4',
    'F#5:2 A5:2 D6:4 C6:2 A5:2', 'B5:4 A5:2 F#5:2 G5:4',
    'D6:4 G6:2 F#6:2 D6:4', 'E6:3 D6:1 B5:4 A5:4',
    'E6:6 D6:2 B5:4', 'A5:4 G5:2 E5:2 B5:4',
    'C6:3 D6:1 E6:4 D6:2 C6:2', 'A5:6 G5:2 E5:4',
    'F#5:4 A5:2 D6:2 C6:2 A5:2', 'B5:4 A5:2 F#5:2 G5:4',
]
MINOR = [
    'B5:8 G5:2 E5:2', 'F#5:4 G5:4 B5:2 -:2',
    'C6:6 B5:2 A5:4', 'G5:4 E5:4 A5:4',
    'A5:8 F#5:2 D5:2', 'E5:4 F#5:2 A5:2 C6:4',
    'B5:4 A5:2 G5:2 F#5:4', 'D#5:6 F#5:2 B5:4',
    'E6:6 D6:2 B5:4', 'G5:4 B5:2 D6:2 E6:4',
    'C6:8 A5:4', 'G5:6 E5:2 C5:4',
    'F#5:4 A5:2 D6:2 E6:4', 'D6:4 C6:2 A5:2 F#5:4',
    'B5:3 A5:1 G5:4 F#5:4', 'D#5:4 F#5:4 B5:2 -:2',
]
QUIET = [
    'E5:8 B4:4', 'G5:6 F#5:2 E5:4',
    'E5:4 A5:6 -:2', 'G5:4 E5:4 C5:4',
    'D5:6 F#5:2 A5:4', 'G5:4 F#5:4 E5:4',
    'F#5:4 B5:6 -:2', 'D#5:4 F#5:4 -:4',
]
DEVELOPMENT = [
    'E5:2 G5:2 B5:4 D6:2 B5:2', 'A5:4 G5:2 E5:2 C5:4',
    'F#5:2 A5:2 D6:4 E6:2 D6:2', 'B5:4 A5:2 G5:2 D5:4',
    'G5:3 A5:1 B5:2 D6:2 E6:4', 'C6:4 B5:2 A5:2 E5:4',
    'A5:2 F#5:2 D5:2 F#5:2 A5:2 C6:2', 'B5:4 D6:4 G6:4',
    'E6:2 D6:2 B5:3 A5:1 G5:4', 'A5:2 C6:2 E6:4 G6:2 E6:2',
    'F#6:3 E6:1 D6:2 A5:2 F#5:4', 'G5:4 B5:2 D6:2 B5:4',
    'B5:2 G5:2 E5:2 G5:2 B5:4', 'C6:2 A5:2 E5:4 G5:2 A5:2',
    'F#5:2 A5:2 D6:4 C6:2 A5:2', 'B5:4 A5:2 F#5:2 G5:4',
]
CODA = [
    'D6:6 B5:2 G5:4', 'A5:4 B5:2 D6:2 B5:4',
    'E6:4 D6:2 B5:2 G5:4', 'A5:4 G5:4 E5:4',
    'C6:6 B5:2 G5:4', 'A5:4 G5:2 E5:2 C5:4',
    'F#5:4 A5:2 D6:2 C6:2 A5:2', 'B5:4 A5:2 F#5:2 G5:4',
    'E6:8 C6:4', 'A5:4 G5:4 E5:4',
    'D6:6 C6:2 A5:4', 'F#5:4 A5:4 D6:4',
    'B5:4 G5:4 D5:4', 'C6:4 B5:4 A5:4',
    'F#5:4 A5:2 D6:2 G5:4', 'G5:12',
]
CHORDS = {
    'G': ('G3', 'B3', 'D4'), 'Em': ('E3', 'G3', 'B3'),
    'C': ('C3', 'E3', 'G3'), 'Am': ('A3', 'C4', 'E4'),
    'D': ('D3', 'F#3', 'A3'), 'B': ('B3', 'D#4', 'F#4'),
}
MAJOR = ['G', 'G', 'Em', 'Em', 'C', 'Am', 'D', 'G']
MINOR_HARMONY = ['Em', 'Em', 'Am', 'C', 'D', 'D', 'B', 'B']
MOVING = ['Em', 'Am', 'D', 'G', 'Em', 'Am', 'D', 'G']
FORM = [
    ('Lanterns are lit', INTRO, MAJOR, 'intro'),
    ('Paper Lantern Parade', VERSE, MAJOR, 'verse'),
    ('Across the square', HOOK, MAJOR, 'hook'),
    ('Letters from far away', MINOR, MINOR_HARMONY, 'minor'),
    ('The empty courtyard', QUIET, MINOR_HARMONY, 'quiet'),
    ('Wind in the ribbons', DEVELOPMENT, MOVING, 'development'),
    ('One more turn', VERSE, MAJOR, 'variation'),
    ('Everyone comes home', HOOK, MAJOR, 'return'),
    ('The last lantern', CODA, MAJOR, 'coda'),
]


def midi(name):
    if name == '-':
        return None
    return (int(name[-1])+1)*12 + {'C': 0, 'D': 2, 'E': 4, 'F': 5,
        'G': 7, 'A': 9, 'B': 11}[name[0]] + (1 if '#' in name else -1 if 'b' in name else 0)


def parse(text):
    events = [(midi(note), int(length)) for note, length in
              (event.split(':') for event in text.split())]
    assert sum(length for _, length in events) == 12, text
    return events


def cells(events, start, part, score):
    output = []
    for note, units in events:
        score.append(dict(frame=start+len(output), frames=units*UNIT,
                          midi=note, part=part))
        output.extend((note, age, units*UNIT) for age in range(units*UNIT))
    assert len(output) == BAR
    return output


def compose(lib):
    source = b.capture(lib, b.ROOT/SOURCE, 1160, song=0)
    assert all(frame[8] == 0 for frame in source)
    # The selected attacks contain no source pitch sequence or note retriggers.
    lead = [frame[7] & 15 for frame in source[:18]]
    low = [frame[5] & 15 for frame in source[:24]]
    accent = [frame[7] & 15 for frame in source[18:24]]
    hit = [list(frame[4:6]) for frame in source[1152:1160]]
    frames, sections, bars, notes, bass_notes, harmony_notes, percussion = [], [], [], [], [], [], []
    for si, (name, melody, chords, kind) in enumerate(FORM):
        sections.append(dict(name=name, frame=len(frames)))
        for bi, notation in enumerate(melody):
            start = len(frames)
            chord = chords[bi % len(chords)]
            if kind == 'coda' and bi >= 8:
                chord = ['C', 'Am', 'D', 'D', 'G', 'C', 'D', 'G'][bi-8]
            root, third, fifth = map(midi, CHORDS[chord])
            lead_events = parse(notation)
            if kind == 'variation' and bi < 8:
                lead_events = [(n-12 if n is not None else n, d) for n, d in lead_events]
            bass = [(root, 6), (fifth, 2), (third, 2), (fifth, 2)]
            harmony = [(None, 4), (third+12, 3), (fifth+12, 1), (third+12, 4)]
            if kind in ('intro', 'quiet'):
                bass = [(root, 8), (fifth, 4)]
                harmony = [(None, 4), (third+12, 4), (fifth+12, 4)]
            if kind == 'development':
                bass = [(root, 3), (fifth, 1), (root+12, 4), (third, 2), (fifth, 2)]
                harmony = [(third+12, 2), (fifth+12, 2), (root+24, 4), (fifth+12, 2), (third+12, 2)]
            if kind == 'coda' and bi == 15:
                bass, harmony = [(root, 12)], [(third+12, 6), (root+12, 6)]
            mc = cells(lead_events, start, 'melody', notes)
            bc = cells(bass, start, 'bass', bass_notes)
            hc = cells(harmony, start, 'harmony', harmony_notes)
            beats = [] if kind in ('intro', 'quiet') else [(0, .22), (8, .14)]
            if kind in ('hook', 'return'):
                beats += [(4, .18)]
            if kind == 'development' and bi in (7, 15):
                beats += [(10, .18)]
            if kind == 'coda' and bi >= 12:
                beats = []
            percussion.extend(dict(frame=start+when*UNIT, source_frame=1152,
                frames=8, gain=gain, channel=2) for when, gain in beats)
            gain = .65 if kind in ('intro', 'quiet') else .85 if kind == 'minor' else 1
            bars.append(dict(frame=start, frames=BAR, section=si, chord=chord,
                             melody=notation, meter='3/4'))
            for tick in range(BAR):
                regs = [0]*9
                local_gain = gain
                if kind == 'coda' and bi == 15:
                    local_gain *= max(0, 1-tick/(BAR-1))
                for channel, cell, envelope, balance in [(0, bc[tick], low, .66),
                         (2, hc[tick], accent, .4), (3, mc[tick], lead, 1.0)]:
                    note, age, length = cell
                    if note is None:
                        continue
                    frequency = 440*2**((note-69)/12)
                    divider = round(b.convert.CLOCK/(56*frequency)-1)
                    assert 0 <= divider <= 255, (note, divider)
                    level = envelope[min(age, len(envelope)-1)]
                    if channel == 3 and age > len(envelope)-1:
                        level = 3  # Sustain the new longer notes softly.
                    if age >= length-3:
                        level *= (length-1-age)/3
                    regs[channel*2] = divider
                    regs[channel*2+1] = 0xe0 | round(level*local_gain*balance)
                for when, hit_gain in reversed(beats):
                    age = tick-when*UNIT
                    if 0 <= age < len(hit):
                        freq, control = hit[age]
                        regs[2] = freq
                        regs[3] = (control & 240) | round((control & 15)*hit_gain*local_gain)
                        break
                frames.append(bytes(regs))
    assert len(frames) == 9216
    score = dict(
        title=TITLE, remix=REMIX_TITLE, source=SOURCE, source_subsong=0,
        composition='standalone original score using borrowed instrument palette',
        short_description='A new G-major lantern waltz, with a soaring refrain and a wistful E-minor letter.',
        description='New 3/4 composition in G major: a playful rising verse, a broad high refrain, an E-minor letter, a quiet courtyard, a moving Em-Am-D-G development, a low-register variation and a resolved return. All melodies, harmony, bass lines, rhythms and form are newly scored.',
        preservation='Commando supplies only its distortion-E attack/decay colours and one quiet isolated noise hit. No source melody, backing phrase, chord sequence, drum pattern or song structure is retained.',
        instrumentation='Independent bright E-distortion melody, round lower E-distortion bass, soft E-distortion chord voice, and a quiet sampled single percussion hit. AUDCTL remains 0; all parts are independently scored.',
        key='G major, with an E-minor contrasting theme', meter='3/4',
        tempo_bpm=60*b.convert.FPS/(UNIT*4), sixteenth_frames=UNIT,
        duration_seconds=len(frames)/b.convert.FPS, lead_channel=4,
        sections=sections, notes=notes, bass_notes=bass_notes,
        harmony_notes=harmony_notes, percussion=percussion, bars=bars,
        allowed_changed_registers=list(range(8)),
        instrument_sources=dict(lead=dict(channel=4, frame=0, frames=18),
            bass=dict(channel=3, frame=0, frames=24),
            chord=dict(channel=4, frame=18, frames=6),
            percussion=dict(channel=3, frame=1152, frames=8)),
        lead_envelope=lead, bass_envelope=low, harmony_envelope=accent,
        noise_hit=hit)
    return frames, score, sections
