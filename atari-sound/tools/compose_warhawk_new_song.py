"""Copper Skyline: a new song made with isolated Warhawk instrument attacks.

The original tune and accompaniment are never used. New Eb-major melodies,
walking bass, offbeat chord plucks and sparse backbeats form a complete score.
"""
import build_remixes as b

SOURCE = 'asma/asma/Composers/Hubbard_Rob/Warhawk.sap'
ID = 'warhawk-instruments-copper-skyline'
TITLE = 'Warhawk'
REMIX_TITLE = 'Copper Skyline'
LEAD = 2
UNIT = 6
BAR = 16 * UNIT

MAIN = [
    'G5:3 -:1 Bb5:2 G5:2 F5:3 Eb5:1 G5:2 Bb5:2',
    'C6:4 Bb5:2 G5:2 F5:4 Eb5:2 -:2',
    'G5:3 -:1 Eb5:2 G5:2 C6:4 Bb5:2 G5:2',
    'Ab5:6 G5:2 Eb5:2 D5:2 C5:2 -:2',
    'C6:3 Bb5:1 Ab5:2 Eb5:2 F5:4 Ab5:2 C6:2',
    'D6:4 C6:2 Bb5:2 Ab5:4 F5:2 -:2',
    'G5:3 -:1 Bb5:2 D6:2 C6:2 Bb5:2 G5:2 Eb5:2',
    'F5:4 D5:2 F5:2 Eb5:6 -:2',
]
ANSWER = [
    'Bb5:6 G5:2 Eb5:4 F5:2 G5:2',
    'D6:4 C6:2 Bb5:2 G5:4 Eb5:2 -:2',
    'Eb6:6 D6:2 C6:4 Bb5:2 G5:2',
    'F5:4 Ab5:2 G5:2 Eb5:4 C5:2 -:2',
    'Ab5:4 C6:2 Eb6:2 D6:3 C6:1 Bb5:2 Ab5:2',
    'F5:6 Bb5:2 D6:4 C6:2 -:2',
    'Bb5:4 G5:2 Eb5:2 G5:3 Bb5:1 Eb6:4',
    'D6:2 C6:2 Bb5:4 Ab5:2 F5:2 Eb5:2 -:2',
]
BRIDGE = [
    'Eb5:6 G5:2 C6:4 D6:2 Eb6:2',
    'D6:4 C6:2 G5:2 Eb5:6 -:2',
    'F5:6 Ab5:2 C6:4 Eb6:2 C6:2',
    'Bb5:4 Ab5:4 G5:2 F5:2 C5:2 -:2',
    'D5:4 G5:2 Bb5:2 D6:4 C6:2 Bb5:2',
    'Ab5:3 G5:1 F5:2 D5:2 G5:6 -:2',
    'Ab5:4 C6:2 Eb6:2 C6:4 Ab5:2 F5:2',
    'G5:4 B5:2 D6:2 F6:4 D6:2 B5:2',
]
QUIET = [
    'C5:4 G5:4 Eb6:6 -:2', 'Bb4:4 G5:4 D6:6 -:2',
    'Ab4:4 C5:4 F5:6 -:2', 'G4:4 C5:4 Eb5:6 -:2',
    'Bb4:4 D5:4 G5:6 -:2', 'Ab4:4 C5:4 F5:6 -:2',
    'C5:4 Eb5:4 Ab5:6 -:2', 'B4:4 D5:4 G5:6 -:2',
]
DEVELOP = [
    'C5:2 Eb5:2 G5:2 C6:2 Eb6:3 D6:1 C6:2 Bb5:2',
    'G5:3 Eb5:1 C5:2 Eb5:2 G5:4 Bb5:2 G5:2',
    'F5:2 Ab5:2 C6:2 F6:2 Eb6:3 C6:1 Ab5:2 F5:2',
    'G5:2 Ab5:2 Bb5:3 C6:1 Eb6:4 C6:2 G5:2',
    'D5:2 G5:2 Bb5:2 D6:2 F6:4 Eb6:2 D6:2',
    'C6:3 Bb5:1 G5:2 D5:2 F5:4 G5:2 Bb5:2',
    'Ab5:2 C6:2 Eb6:4 C6:2 Ab5:2 F5:2 Ab5:2',
    'G5:2 B5:2 D6:2 F6:2 Eb6:2 D6:2 B5:2 -:2',
]
INTRO = [
    '-:8 G5:4 Bb5:2 -:2', 'F5:4 Eb5:4 -:8',
    '-:8 Eb5:4 G5:2 -:2', 'C6:4 Bb5:4 -:8',
    'Ab5:4 -:4 C6:4 -:4', 'Bb5:4 -:4 F5:4 -:4',
    'G5:3 -:1 Bb5:2 G5:2 F5:4 Eb5:2 -:2',
    'D5:4 F5:4 Bb5:4 -:4',
]
CODA = [
    'G5:3 -:1 Bb5:2 G5:2 F5:3 Eb5:1 G5:2 Bb5:2',
    'C6:4 Bb5:2 G5:2 F5:4 Eb5:2 -:2',
    'G5:4 C6:2 Eb6:2 D6:4 C6:2 G5:2',
    'Ab5:4 G5:4 Eb5:4 -:4',
    'C6:6 Bb5:2 Ab5:4 Eb5:4',
    'F5:4 Bb5:2 D6:2 C6:4 Bb5:2 F5:2',
    'G5:4 Bb5:4 Eb6:4 Bb5:2 G5:2', 'Eb5:16',
]
CHORDS = {
    'Eb': (39, 43, 46), 'Cm': (36, 39, 43),
    'Ab': (44, 48, 51), 'Bb': (34, 38, 41),
    'Fm': (41, 44, 48), 'Gm': (43, 46, 50), 'G7': (43, 47, 50),
}
A_HARMONY = ['Eb', 'Eb', 'Cm', 'Cm', 'Ab', 'Bb', 'Eb', 'Bb']
B_HARMONY = ['Cm', 'Cm', 'Fm', 'Cm', 'Gm', 'Fm', 'Ab', 'G7']
FORM = [
    ('Lights on the tram line', 8, 'intro'), ('Copper Skyline', 16, 'main'),
    ('Windows above the street', 16, 'answer'), ('Blue hour', 8, 'quiet'),
    ('The late train', 16, 'bridge'), ('Across the viaduct', 8, 'develop'),
    ('A city full of lights', 16, 'return'), ('Home before dawn', 8, 'coda'),
]


def midi(name):
    if name == '-':
        return None
    pitch = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}[name[0]]
    if len(name) == 3:
        pitch += {'#': 1, 'b': -1}[name[1]]
    return 12 * (int(name[-1]) + 1) + pitch


def parse(text):
    events = [(int(duration), midi(note)) for note, duration in
              (token.split(':') for token in text.split())]
    assert sum(duration for duration, _ in events) == 16, text
    return events


def cells(events, start, part, score, section):
    result = []
    for units, pitch in events:
        length = units * UNIT
        score.append(dict(frame=start + len(result), frames=length, midi=pitch,
                          part=part, section=section))
        result.extend((pitch, age, length) for age in range(length))
    assert len(result) == BAR
    return result


def divisor(pitch, detune=0):
    frequency = 440 * 2 ** ((pitch + detune - 69) / 12)
    return max(0, min(255, round(b.convert.CLOCK / (56 * frequency) - 1)))


def compose(lib):
    source = b.capture(lib, b.ROOT / SOURCE, 26)
    assert all(frame[8] == 0x50 for frame in source)
    lead_envelope = [frame[5] & 15 for frame in source[:9]]
    bass_envelope = [frame[3] & 15 for frame in source[:8]]
    pluck_envelope = [frame[7] & 15 for frame in source[1:8]]
    vibrato = [(b.pitch(frame[4]) - b.pitch(42)) * .55 for frame in source[9:17]]
    drum_hit = [list(frame[:4]) for frame in source[17:26]]
    frames, sections, notes, bars, percussion = [], [], [], [], []
    for section, (name, count, kind) in enumerate(FORM):
        sections.append(dict(name=name, frame=len(frames)))
        harmony = B_HARMONY if kind in ('quiet', 'bridge', 'develop') else A_HARMONY
        for bar in range(count):
            pos = bar % 8
            chord = 'Eb' if kind == 'coda' and pos == 7 else harmony[pos]
            root, third, fifth = CHORDS[chord]
            notation = (INTRO if kind == 'intro' else ANSWER if kind == 'answer' else
                        QUIET if kind == 'quiet' else BRIDGE if kind == 'bridge' else
                        DEVELOP if kind == 'develop' else CODA if kind == 'coda' else MAIN)[pos]
            if kind == 'bridge' and bar >= 8:
                notation = DEVELOP[pos] if pos in (0, 3, 6, 7) else BRIDGE[pos]
            if kind == 'return' and bar >= 8:
                notation = ANSWER[pos] if pos in (1, 3, 4, 6) else MAIN[pos]
            melody = parse(notation)
            bass = [(3, root), (1, None), (2, fifth), (2, root + 12),
                    (3, third), (1, None), (2, fifth), (2, root)]
            if kind in ('intro', 'quiet'):
                bass = [(6, root), (2, None), (6, fifth), (2, None)]
            elif kind == 'develop':
                bass = [(2, root), (2, third), (2, fifth), (2, root + 12),
                        (2, fifth), (2, third), (2, root), (2, fifth)]
            elif pos == 7:
                next_root = CHORDS[harmony[0]][0]
                bass = [(4, root), (2, third), (2, fifth), (4, root + 12),
                        (2, next_root - 2), (2, next_root - 1)]
            # Offbeat chord plucks answer the sung lead, independently scored.
            chords = [(2, None), (2, third + 24), (2, fifth + 24), (2, None),
                      (2, root + 24), (2, None), (2, fifth + 24), (2, third + 24)]
            if kind in ('intro', 'quiet'):
                chords = [(4, None), (4, third + 24), (4, None), (4, fifth + 24)]
            elif kind == 'bridge':
                chords = [(2, None), (2, fifth + 24), (4, third + 24),
                          (2, None), (2, root + 24), (4, fifth + 24)]
            drum_positions = []
            if kind not in ('intro', 'quiet'):
                drum_positions = [4, 12]
                if kind in ('develop', 'return') and pos == 7:
                    drum_positions = [4, 11, 14]
            elif kind == 'intro' and bar >= 6:
                drum_positions = [12]
            start = len(frames)
            lead_cells = cells(melody, start, 'lead', notes, section)
            bass_cells = cells(bass, start, 'bass', notes, section)
            chord_cells = cells(chords, start, 'chord_plucks', notes, section)
            bars.append(dict(frame=start, frames=BAR, chord=chord, section=section,
                             melody=melody, bass=bass, chord_plucks=chords,
                             drum_sixteenths=drum_positions))
            for position in drum_positions:
                percussion.append(dict(frame=start + position * UNIT, frames=len(drum_hit),
                                       instrument='native joined-voice short noise hit',
                                       source_frame=17, part='bass-channel interruption', section=section))
            gain = .56 if kind in ('intro', 'quiet') else .83 if kind == 'bridge' else 1
            if kind == 'develop':
                gain *= .72 + .28 * bar / 7
            if kind == 'coda' and bar >= 4:
                gain *= 1 - (bar - 4) * .12
            for tick in range(BAR):
                regs = [0, 0, 0, 0, 0, 0, 0, 0, 0x50]
                pitch, age, length = bass_cells[tick]
                if pitch is not None:
                    frequency = 440 * 2 ** ((pitch - 69) / 12)
                    value = max(0, min(65535, round(b.convert.CLOCK / (30 * frequency) - 7)))
                    level = bass_envelope[min(age, 7)] * .7 * gain
                    if age >= length - 2:
                        level *= (length - 1 - age) / 2
                    regs[0], regs[2], regs[3] = value & 255, value >> 8, 0xc0 | round(level)
                pitch, age, length = lead_cells[tick]
                if pitch is not None:
                    regs[4] = divisor(pitch, vibrato[age % 8] if age >= 6 else 0)
                    level = lead_envelope[min(age, 8)] * .85 * gain
                    if age >= length - 3:
                        level *= (length - 1 - age) / 3
                    regs[5] = 0xa0 | round(level)
                pitch, age, length = chord_cells[tick]
                if pitch is not None:
                    regs[6] = divisor(pitch)
                    level = pluck_envelope[min(age, 6)] * .65 * gain
                    if age > 10:
                        level = 0
                    regs[7] = 0xa0 | round(level)
                for position in drum_positions:
                    age = tick - position * UNIT
                    if 0 <= age < len(drum_hit):
                        regs[:4] = drum_hit[age]
                        regs[3] = (regs[3] & 0xf0) | round((regs[3] & 15) * .45 * gain)
                        break
                if kind == 'coda' and bar == 7:
                    fade = max(0, 1 - tick / (BAR - 1))
                    for control in (3, 5, 7):
                        regs[control] = (regs[control] & 0xf0) | round((regs[control] & 15) * fade)
                frames.append(bytes(regs))
    assert len(frames) == 9216
    score = dict(
        short_description='A new Eb-major city song: offbeat chord plucks, warm bass, a C-minor night passage and bright return.',
        description=('An independently scored, three-minute song in Eb major. A clipped two-bar '
                     'hook opens into a broad answering melody, then moves through a quiet '
                     'C-minor night scene, a contrasting F-minor/G7 bridge, a running development '
                     'and a varied final chorus. All melodies, chord progressions, bass lines, '
                     'offbeat chord patterns, drum placement and form are new. Only short '
                     'instrument attacks and one isolated noise hit come from Warhawk.'),
        source=SOURCE, source_subsong=0, title=TITLE, remix=REMIX_TITLE,
        composition='standalone original score using borrowed instrument palette',
        preservation=('Rob Hubbard instrument character only: nine-frame lead attack, eight-frame '
                      'joined distortion-C bass attack, seven-frame chord pluck, a softened '
                      'eight-frame vibrato and one nine-frame noise hit. Source musical phrases '
                      'and rhythmic placement are not reused.'),
        key='Eb major; C minor, F minor and G7 contrast', meter='4/4',
        tempo_bpm=60 * b.convert.FPS / (4 * UNIT), sixteenth_frames=UNIT,
        duration_seconds=len(frames) / b.convert.FPS, lead_channel=3,
        notes=notes, bars=bars, sections=sections, percussion=percussion,
        instrument_sources=dict(lead=dict(frame=0, frames=9, channel=3),
                                bass=dict(frame=0, frames=8, channels=[1, 2]),
                                pluck=dict(frame=1, frames=7, channel=4),
                                vibrato=dict(frame=9, frames=8, channel=3),
                                noise_hit=dict(frame=17, frames=9, channels=[1, 2])),
        instruments=dict(lead_envelope=lead_envelope, bass_envelope=bass_envelope,
                         pluck_envelope=pluck_envelope, vibrato_semitones=vibrato,
                         noise_hit=drum_hit),
        allowed_changed_registers=list(range(8)),
    )
    return frames, score, sections
