"""Paper Lantern Waltz: a new score using only Draconus instrument envelopes.

All three pitched parts, harmony, rhythm and form are newly written. The SAP
supplies 40 frames of isolated instrument attacks, not a musical backing loop.
"""
import math
import build_remixes as b

SOURCE = 'asma/asma/Composers/Gilmore_Adam/Draconus.sap'
ID = 'draconus-instruments-paper-lantern-waltz'
TITLE = 'Draconus'
REMIX_TITLE = 'Paper Lantern Waltz'
LEAD = 2
UNIT = 7
BAR = 12 * UNIT

# Twelve sixteenths per 3/4 bar. These are explicit melodies, not motif seeds.
THEME = [
    'E5:3 G5:1 B5:4 A5:2 G5:2', 'F#5:2 E5:2 B4:6 -:2',
    'E5:4 G5:2 D6:2 C6:3 B5:1', 'A5:4 G5:4 E5:2 -:2',
    'D5:3 G5:1 B5:4 D6:2 B5:2', 'A5:6 F#5:2 D5:2 -:2',
    'E5:2 A5:2 C6:4 B5:2 A5:2', 'G5:4 E5:4 C5:2 -:2',
    'A4:3 C5:1 E5:4 G5:2 A5:2', 'F#5:4 D#5:2 F#5:2 B5:2 A5:2',
    'G5:3 F#5:1 E5:2 B4:2 G4:2 B4:2', 'E5:8 -:4',
]
ANSWER = [
    'B5:6 A5:2 G5:2 E5:2', 'F#5:4 D#5:2 B4:2 F#5:2 -:2',
    'G5:4 B5:2 D6:2 E6:4', 'D6:3 C6:1 B5:2 G5:4 -:2',
    'B5:2 D6:2 G6:4 F#6:2 D6:2', 'E6:4 D6:2 A5:2 F#5:4',
    'C6:4 B5:2 A5:2 E5:2 A5:2', 'B5:6 G5:2 E5:2 -:2',
    'C6:3 B5:1 A5:4 G5:2 E5:2', 'F#5:2 A5:2 B5:4 A5:2 F#5:2',
    'G5:4 B5:2 E6:2 D6:2 B5:2', 'E6:8 -:4',
]
GARDEN = [
    'B4:4 D5:2 G5:2 A5:4', 'B5:6 G5:2 D5:2 -:2',
    'A4:4 D5:2 F#5:2 A5:4', 'G5:2 F#5:2 D5:4 A4:2 -:2',
    'G4:4 C5:2 E5:2 G5:4', 'A5:3 G5:1 E5:2 D5:4 -:2',
    'B4:6 E5:2 G5:4', 'F#5:4 E5:2 B4:2 G4:4',
    'C5:4 E5:2 A5:2 G5:2 E5:2', 'D5:4 F#5:2 A5:2 C6:4',
    'B5:3 A5:1 G5:2 D5:2 B4:2 D5:2', 'G5:8 -:4',
]
QUIET = [
    'E4:4 B4:4 G5:2 -:2', 'D#4:4 B4:4 F#5:2 -:2',
    'E4:4 G4:4 B4:2 -:2', 'G4:4 C5:4 E5:2 -:2',
    'D4:4 G4:4 B4:2 -:2', 'F#4:4 A4:4 D5:2 -:2',
    'E4:4 A4:4 C5:2 -:2', 'G4:4 E5:4 B4:2 -:2',
    'A4:6 C5:2 E5:2 -:2', 'D#5:6 F#5:2 A5:2 -:2',
    'G5:4 E5:4 B4:4', 'E5:8 -:4',
]
DEVELOP = [
    'A4:2 C5:2 E5:2 A5:2 B5:2 C6:2',
    'B5:3 A5:1 G5:2 E5:2 C5:2 E5:2',
    'F#5:2 A5:2 C6:2 B5:2 A5:2 F#5:2',
    'G5:3 F#5:1 E5:4 B4:2 -:2',
    'G4:2 B4:2 D5:2 G5:2 B5:2 D6:2',
    'C6:3 B5:1 A5:2 F#5:2 D5:4',
    'E5:2 G5:2 C6:2 E6:2 D6:2 C6:2',
    'B5:4 A5:2 G5:2 E5:2 G5:2',
    'A5:2 E5:2 C5:2 E5:2 A5:2 C6:2',
    'B5:2 F#5:2 D#5:2 F#5:2 A5:2 B5:2',
    'G5:3 B5:1 E6:4 D6:2 B5:2', 'E6:8 -:4',
]
CHORDS = {
    'Em': (40, 43, 47), 'B7': (35, 39, 42),
    'C': (36, 40, 43), 'G': (43, 47, 50),
    'D': (38, 42, 45), 'Am': (45, 48, 52),
}
A_HARMONY = ['Em', 'B7', 'Em', 'C', 'G', 'D', 'Am', 'Em', 'Am', 'B7', 'Em', 'Em']
B_HARMONY = ['G', 'G', 'D', 'D', 'C', 'C', 'Em', 'Em', 'Am', 'D', 'G', 'G']
C_HARMONY = ['Am', 'C', 'B7', 'Em', 'G', 'D', 'C', 'Em', 'Am', 'B7', 'Em', 'Em']
FORM = [
    ('Lanterns being lit', 'intro'), ('Paper Lantern Waltz', 'theme'),
    ('Over the rooftops', 'answer'), ('The moonlit garden', 'garden'),
    ('One candle in the window', 'quiet'), ('Wind along the avenue', 'develop'),
    ('The garden opens', 'garden_return'), ('Lanterns in the sky', 'return'),
    ('The last light', 'coda'),
]


def midi(name):
    if name == '-':
        return None
    value = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}[name[0]]
    if len(name) == 3:
        value += {'#': 1, 'b': -1}[name[1]]
    return 12 * (int(name[-1]) + 1) + value


def parse(text):
    result = [(int(duration), midi(note)) for note, duration in
              (token.split(':') for token in text.split())]
    assert sum(duration for duration, _ in result) == 12, text
    return result


def cells(events, start, part, score, section):
    result = []
    for units, pitch in events:
        duration = units * UNIT
        score.append(dict(frame=start + len(result), frames=duration, midi=pitch,
                          part=part, section=section))
        result.extend((pitch, age, duration) for age in range(duration))
    assert len(result) == BAR
    return result


def tone_divisor(pitch, detune=0):
    frequency = 440 * 2 ** ((pitch + detune - 69) / 12)
    return max(0, min(255, round(b.convert.CLOCK / (56 * frequency) - 1)))


def compose(lib):
    source = b.capture(lib, b.ROOT / SOURCE, 40)
    assert all(frame[8] == 0x50 for frame in source)
    lead_envelope = [frame[5] & 15 for frame in source[:10]]
    bass_envelope = [frame[3] & 15 for frame in source[:10]]
    swell_envelope = [frame[7] & 15 for frame in source[:16]]
    vibrato = [b.pitch(frame[6]) - b.pitch(241) for frame in source[:8]]
    frames, sections, notes, bars = [], [], [], []
    for section, (name, kind) in enumerate(FORM):
        sections.append(dict(name=name, frame=len(frames)))
        harmony = B_HARMONY if kind in ('garden', 'garden_return') else C_HARMONY if kind == 'develop' else A_HARMONY
        for bar in range(12):
            chord = harmony[bar]
            root, third, fifth = CHORDS[chord]
            notation = (GARDEN if kind in ('garden', 'garden_return') else
                        ANSWER if kind == 'answer' else QUIET if kind in ('intro', 'quiet') else
                        DEVELOP if kind == 'develop' else THEME)[bar]
            melody = parse(notation)
            if kind == 'intro' and bar < 4:
                melody = [(8, None), (2, third + 24), (2, None)]
            if kind == 'garden_return' and bar >= 8:
                melody = [(duration, pitch + 12 if pitch is not None else None)
                          for duration, pitch in melody]
            if kind == 'return' and bar in (2, 4, 6, 10):
                melody = parse(ANSWER[bar])
            if kind == 'coda' and bar >= 8:
                melody = [parse('A5:4 C6:2 B5:2 A5:2 E5:2'),
                          parse('F#5:4 D#5:2 B4:2 F#5:4'),
                          parse('G5:2 B5:2 E6:4 B5:2 G5:2'),
                          parse('E5:12')][bar - 8]

            # A newly scored waltz bass. Nothing is sliced out of the source.
            bass = [(4, root), (4, fifth), (4, third)]
            if kind in ('intro', 'quiet'):
                bass = [(8, root), (4, fifth)]
            elif kind == 'develop':
                bass = [(3, root), (1, None), (2, fifth), (2, root + 12), (4, third)]
            elif bar % 4 == 3:
                bass = [(6, root), (2, fifth), (2, third), (2, root + 12)]

            # The third voice answers in long chord tones; there are no drums.
            counter = [(8, third + 12), (4, fifth + 12)]
            if kind in ('intro', 'quiet'):
                counter = [(12, fifth + 12)]
            elif kind in ('answer', 'garden_return', 'return'):
                counter = [(4, fifth + 12), (4, third + 12), (4, root + 24)]
            elif kind == 'develop':
                counter = [(6, third + 12), (2, fifth + 12), (4, root + 24)]
            start = len(frames)
            lead_cells = cells(melody, start, 'lead', notes, section)
            bass_cells = cells(bass, start, 'bass', notes, section)
            counter_cells = cells(counter, start, 'countervoice', notes, section)
            bars.append(dict(frame=start, frames=BAR, chord=chord, section=section,
                             melody=melody, bass=bass, countervoice=counter))
            gain = .57 if kind in ('intro', 'quiet') else .83 if kind == 'garden' else 1
            if kind == 'develop':
                gain *= .7 + .3 * bar / 11
            if kind == 'coda' and bar >= 8:
                gain *= 1 - (bar - 8) * .14
            for tick in range(BAR):
                regs = [0, 0, 0, 0, 0, 0, 0, 0, 0x50]
                pitch, age, length = bass_cells[tick]
                if pitch is not None:
                    frequency = 440 * 2 ** ((pitch - 69) / 12)
                    divider = max(0, min(65535, round(b.convert.CLOCK / (30 * frequency) - 7)))
                    level = bass_envelope[min(age, 9)] * .6 * gain
                    if age >= length - 3:
                        level *= (length - 1 - age) / 3
                    regs[0], regs[2], regs[3] = divider & 255, divider >> 8, 0xc0 | round(level)
                pitch, age, length = lead_cells[tick]
                if pitch is not None:
                    regs[4] = tone_divisor(pitch)
                    level = lead_envelope[min(age, 9)] * .8 * gain
                    if age >= length - 4:
                        level *= (length - 1 - age) / 4
                    regs[5] = 0xa0 | round(level)
                pitch, age, length = counter_cells[tick]
                regs[6] = tone_divisor(pitch, vibrato[age % 8])
                level = swell_envelope[min(age, 15)] * .35 * gain
                if age >= length - 4:
                    level *= (length - 1 - age) / 4
                regs[7] = 0xa0 | round(level)
                if kind == 'coda' and bar == 11:
                    fade = max(0, 1 - tick / (BAR - 1))
                    for control in (3, 5, 7):
                        regs[control] = (regs[control] & 0xf0) | round((regs[control] & 15) * fade)
                frames.append(bytes(regs))
    assert len(frames) == 9072
    score = dict(
        short_description='An E-minor waltz with a glassy theme, a G-major garden, a quiet candlelit passage and return.',
        description=('An independently scored three-minute waltz in E minor. A rising third/fifth hook '
                     'is answered by a wider lyrical theme; a G-major garden introduces a contrasting '
                     'melody, then a sparse interlude and A-minor/B7 development lead to a varied '
                     'reprise and a settled tonic ending. Bass, countervoice, harmony and three-beat '
                     'rhythm are all new. Draconus contributes only isolated instrument envelopes.'),
        source=SOURCE, source_subsong=0, title=TITLE, remix=REMIX_TITLE,
        composition='standalone original score using borrowed instrument palette',
        preservation=('Adam Gilmore instrument character only: ten-frame pure-lead and joined '
                      'distortion-C bass attacks, plus a sixteen-frame swell and eight-frame vibrato. '
                      'No original notes, bass patterns, chord progression, drum placement or backing phrases.'),
        key='E minor, contrasting G major, with A minor and B7 development', meter='3/4',
        tempo_bpm=60 * b.convert.FPS / (4 * UNIT), sixteenth_frames=UNIT,
        duration_seconds=len(frames) / b.convert.FPS, lead_channel=3,
        notes=notes, bars=bars, sections=sections, percussion=[],
        instrument_sources=dict(lead=dict(frame=0, frames=10, channel=3),
                                bass=dict(frame=0, frames=10, channels=[1, 2]),
                                swell=dict(frame=0, frames=16, channel=4),
                                vibrato=dict(frame=0, frames=8, channel=4)),
        instruments=dict(lead_envelope=lead_envelope, bass_envelope=bass_envelope,
                         swell_envelope=swell_envelope, vibrato_semitones=vibrato),
        allowed_changed_registers=list(range(8)),
    )
    return frames, score, sections
