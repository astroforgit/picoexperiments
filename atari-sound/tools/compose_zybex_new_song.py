"""Aurora Transit: a new asymmetrical pop miniature with Zybex colours.

Only single-note instrument envelopes and one isolated drum attack come from
Zybex subtune 4. Melody, harmony, bass and the flowing 3+2+2 pulse are new.
"""
import build_remixes as b

SOURCE = 'asma/asma/Composers/Gilmore_Adam/Zybex.sap'
SOURCE_SONG = 4
ID = 'zybex-instruments-aurora-transit'
TITLE = 'Zybex'
REMIX_TITLE = 'Aurora Transit'
LEAD = 2
UNIT = 5
BAR = 14*UNIT

# Durations are sixteenths: each 7/8 bar has fourteen units, grouped 6+4+4.
INTRO = [
    '-:6 G#5:4 B5:4', 'F#5:6 E5:4 -:4',
    '-:6 E5:4 G#5:4', 'B5:6 A5:4 G#5:4',
    'A5:6 E5:4 C#5:4', 'B4:6 E5:4 F#5:4',
    'D#5:6 F#5:4 B5:4', 'A5:6 F#5:4 -:4',
]
VERSE = [
    'G#5:4 B5:2 E6:4 D#6:2 B5:2', 'F#5:6 G#5:2 B5:2 G#5:4',
    'E5:3 G#5:1 C#6:2 B5:4 G#5:4', 'F#5:4 E5:2 G#5:4 B5:2 -:2',
    'A5:6 G#5:2 E5:2 C#5:4', 'E5:3 F#5:1 G#5:2 B5:4 G#5:4',
    'F#5:4 D#5:2 F#5:4 B5:2 A5:2', 'G#5:6 F#5:2 D#5:2 E5:4',
    'G#5:3 B5:1 E6:2 F#6:4 E6:2 B5:2', 'G#5:6 B5:4 F#5:2 -:2',
    'C#6:4 B5:2 G#5:4 E5:4', 'F#5:3 G#5:1 B5:2 G#5:4 E5:4',
    'A5:4 C#6:2 E6:4 C#6:2 B5:2', 'G#5:6 E5:4 F#5:4',
    'F#5:2 A5:2 B5:2 D#6:4 C#6:2 A5:2', 'G#5:6 F#5:2 D#5:2 E5:4',
]
HOOK = [
    'B5:6 E6:4 D#6:2 B5:2', 'F#6:4 E6:2 B5:4 G#5:4',
    'G#5:3 B5:1 C#6:2 E6:4 G#6:4', 'F#6:6 E6:2 C#6:2 B5:4',
    'E6:4 C#6:2 A5:4 G#5:2 E5:2', 'F#5:6 G#5:4 B5:4',
    'D#6:4 C#6:2 B5:4 F#5:4', 'G#5:6 F#5:2 D#5:2 E5:4',
    'B5:4 E6:2 G#6:4 F#6:2 E6:2', 'D#6:6 B5:4 G#5:4',
    'E6:6 C#6:4 B5:2 G#5:2', 'F#5:4 G#5:2 B5:4 E6:4',
    'A5:3 C#6:1 E6:2 F#6:4 E6:2 C#6:2', 'B5:6 G#5:4 E5:4',
    'F#5:4 A5:2 B5:4 D#6:4', 'C#6:2 B5:2 G#5:2 F#5:4 E5:4',
]
NIGHT = [
    'E6:8 C#6:2 G#5:4', 'D#6:6 C#6:4 B5:4',
    'C#6:6 A5:4 E5:4', 'F#5:4 A5:2 C#6:6 -:2',
    'B5:8 G#5:2 E5:4', 'F#5:6 G#5:4 B5:4',
    'D#6:6 C#6:4 B5:4', 'G#5:4 B#5:2 D#6:4 B#5:2 G#5:2',
    'G#6:6 E6:4 C#6:4', 'D#6:4 E6:2 G#6:4 F#6:4',
    'E6:8 C#6:2 A5:4', 'C#6:6 B5:4 A5:4',
    'B5:6 G#5:4 E5:4', 'F#5:4 G#5:2 B5:4 C#6:4',
    'F#6:6 D#6:4 B5:4', 'D#6:4 B#5:2 G#5:4 -:4',
]
QUIET = [
    'C#5:6 E5:4 G#5:4', 'E5:8 D#5:2 C#5:4',
    'A4:6 C#5:4 E5:4', 'F#5:6 E5:4 C#5:4',
    'E5:8 B4:2 G#4:4', 'B4:6 E5:4 F#5:4',
    'D#5:6 F#5:4 B5:4', 'B#5:6 G#5:4 -:4',
]
BRIDGE = [
    'A5:4 C#6:2 E6:4 G#6:4', 'F#6:6 E6:4 C#6:4',
    'D#6:4 B5:2 F#5:4 A5:4', 'B5:3 C#6:1 D#6:2 F#6:4 D#6:4',
    'G#5:4 B5:2 D#6:4 F#6:4', 'E6:6 D#6:4 B5:4',
    'C#6:4 E6:2 G#6:4 E6:2 C#6:2', 'B5:6 G#5:4 E5:4',
    'E6:3 C#6:1 A5:2 C#6:4 E6:4', 'F#6:4 E6:2 C#6:4 A5:4',
    'F#5:2 A5:2 B5:2 D#6:4 F#6:4', 'E6:6 D#6:4 B5:4',
    'B5:2 D#6:2 F#6:2 G#6:4 F#6:4', 'D#6:6 B5:4 G#5:4',
    'C#6:2 E6:2 G#6:2 E6:4 C#6:4', 'D#6:4 B5:2 G#5:4 -:4',
]
FINALE = [
    'B5:6 E6:4 D#6:2 B5:2', 'F#6:4 E6:2 B5:4 G#5:4',
    'E6:6 C#6:4 B5:2 G#5:2', 'F#5:4 G#5:2 B5:4 E6:4',
    'E6:6 C#6:4 A5:4', 'B5:6 G#5:4 E5:4',
    'F#5:4 A5:2 B5:4 D#6:4', 'C#6:2 B5:2 G#5:2 F#5:4 E5:4',
    'E6:8 C#6:2 A5:4', 'F#5:6 A5:4 C#6:4',
    'D#6:6 C#6:4 B5:4', 'F#5:4 A5:2 B5:4 D#6:4',
    'E6:6 B5:4 G#5:4', 'A5:4 G#5:2 F#5:4 E5:4',
    'D#5:6 F#5:4 B5:4', 'E5:14',
]
CHORDS = {
    'E': ('E2', 'G#2', 'B2'), 'C#m': ('C#2', 'E2', 'G#2'),
    'A': ('A2', 'C#3', 'E3'), 'B': ('B2', 'D#3', 'F#3'),
    'F#m': ('F#2', 'A2', 'C#3'), 'G#m': ('G#2', 'B2', 'D#3'),
    'G#': ('G#2', 'B#2', 'D#3'),
}
BRIGHT = ['E', 'E', 'C#m', 'C#m', 'A', 'E', 'B', 'E']
DARK = ['C#m', 'C#m', 'A', 'F#m', 'E', 'E', 'B', 'G#']
CROSSING = ['A', 'A', 'B', 'B', 'G#m', 'G#m', 'C#m', 'C#m']
FORM = [
    ('The station wakes', INTRO, BRIGHT, 'intro'),
    ('Aurora Transit', VERSE, BRIGHT, 'verse'),
    ('Beyond the city lights', HOOK, BRIGHT, 'hook'),
    ('Night window', NIGHT, DARK, 'night'),
    ('Stars in the glass', QUIET, DARK, 'quiet'),
    ('Over the suspension bridge', BRIDGE, CROSSING, 'bridge'),
    ('The northern line', VERSE, BRIGHT, 'development'),
    ('First colours of morning', HOOK, BRIGHT, 'return'),
    ('Arrival', FINALE, BRIGHT, 'finale'),
]


def midi(name):
    if name == '-':
        return None
    return (int(name[-1])+1)*12 + {'C': 0, 'D': 2, 'E': 4, 'F': 5,
        'G': 7, 'A': 9, 'B': 11}[name[0]] + (1 if '#' in name else -1 if 'b' in name else 0)


def parse(text):
    events = [(midi(note), int(length)) for note, length in
              (event.split(':') for event in text.split())]
    assert sum(length for _, length in events) == 14, text
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
    source = b.capture(lib, b.ROOT/SOURCE, 3076, song=SOURCE_SONG)
    assert all(frame[8] == 0x50 for frame in source)
    singing = [frame[7]&15 for frame in source[1152:1182]]
    pluck = [frame[5]&15 for frame in source[:6]]
    bass_envelope = [frame[3]&15 for frame in source[384:408]]
    hit = [list(frame[6:8]) for frame in source[3072:3076]]
    frames, sections, bars, notes, bass_notes, harmony_notes, percussion = [], [], [], [], [], [], []
    for si, (name, melody, chords, kind) in enumerate(FORM):
        sections.append(dict(name=name, frame=len(frames)))
        for bi, notation in enumerate(melody):
            start = len(frames)
            chord = chords[bi % len(chords)]
            if kind == 'finale' and bi >= 8:
                chord = ['A', 'F#m', 'B', 'B', 'E', 'A', 'B', 'E'][bi-8]
            root, third, fifth = map(midi, CHORDS[chord])
            melody_events = parse(notation)
            if kind == 'development' and bi < 8:
                melody_events = [(n-12 if n is not None else n, d) for n, d in melody_events]
            bass = [(root, 6), (fifth, 4), (third, 2), (fifth, 2)]
            arpeggio = [(None, 2), (third+24, 2), (fifth+24, 2),
                       (root+36, 4), (fifth+24, 2), (third+24, 2)]
            if kind in ('intro', 'quiet', 'night'):
                bass = [(root, 10), (fifth, 4)]
                arpeggio = [(None, 6), (third+24, 4), (fifth+24, 4)]
            if kind in ('bridge', 'development'):
                bass = [(root, 4), (fifth, 2), (root+12, 4), (third, 2), (fifth, 2)]
                arpeggio = [(third+24, 3), (fifth+24, 1), (root+36, 2),
                           (fifth+24, 4), (third+24, 2), (fifth+24, 2)]
            if kind == 'finale' and bi == 15:
                bass, arpeggio = [(root, 14)], [(third+24, 6), (fifth+24, 4), (root+24, 4)]
            mc = cells(melody_events, start, 'melody', notes)
            bc = cells(bass, start, 'joined bass', bass_notes)
            hc = cells(arpeggio, start, 'arpeggio', harmony_notes)
            beats = [] if kind in ('intro', 'quiet', 'night') else [(0, .22), (6, .18)]
            if kind in ('hook', 'return', 'development'):
                beats += [(10, .16)]
            if kind == 'finale' and bi >= 12:
                beats = []
            percussion.extend(dict(frame=start+when*UNIT, source_frame=3072,
                frames=4, gain=gain, channel=4) for when, gain in beats)
            gain = .55 if kind in ('intro', 'quiet') else .78 if kind == 'night' else .85
            bars.append(dict(frame=start, frames=BAR, section=si, chord=chord,
                             melody=notation, meter='7/8', accents='3+2+2'))
            for tick in range(BAR):
                regs = [0, 0, 0, 0, 0, 0, 0, 0, 0x50]
                local_gain = gain
                if kind == 'finale' and bi == 15:
                    local_gain *= max(0, 1-tick/(BAR-1))
                note, age, length = bc[tick]
                frequency = 440*2**((note-69)/12)
                # Distortion C, joined 1+2 at 1.79 MHz: thirty clock periods.
                divider = round(b.convert.CLOCK/(30*frequency)-7)
                assert 0 <= divider <= 65535
                level = bass_envelope[min(age, len(bass_envelope)-1)]
                if age >= length-3:
                    level *= (length-1-age)/3
                regs[0], regs[2] = divider&255, divider>>8
                regs[3] = 0xc0 | round(level*local_gain*.7)
                for channel, cell, envelope, balance in [(2, mc[tick], singing, 1),
                                                         (3, hc[tick], pluck, .42)]:
                    note, age, length = cell
                    if note is None:
                        continue
                    frequency = 440*2**((note-69)/12)
                    divider = round(b.convert.CLOCK/(56*frequency)-1)
                    assert 0 <= divider <= 255, (note, divider)
                    level = envelope[min(age, len(envelope)-1)]
                    if age >= length-3:
                        level *= (length-1-age)/3
                    regs[channel*2] = divider
                    regs[channel*2+1] = 0xa0 | round(level*local_gain*balance)
                for when, hit_gain in reversed(beats):
                    age = tick-when*UNIT
                    if 0 <= age < len(hit):
                        freq, control = hit[age]
                        regs[6] = freq
                        regs[7] = (control&240) | round((control&15)*hit_gain*local_gain)
                        break
                frames.append(bytes(regs))
    assert len(frames) == 8960
    score = dict(
        title=TITLE, remix=REMIX_TITLE, source=SOURCE, source_subsong=SOURCE_SONG,
        composition='standalone original score using borrowed instrument palette',
        short_description='A new E-major journey in flowing 7/8, with a C#-minor night window and luminous arrival.',
        description='New E-major composition in 7/8, grouped 3+2+2: a spacious station introduction, clipped verse, soaring chorus, lyrical C#-minor night theme, quiet interlude, A-B-G#m-C#m bridge, low-register development and a resolved return. All musical parts and rhythmic placement are newly scored.',
        preservation='Zybex subtune 4 supplies only isolated singing/plucked envelopes, the joined-bass envelope and a single four-frame percussion attack. No source melodies, harmonic sequences, bass phrases, drum patterns or song form are retained.',
        instrumentation='Native distortion-C joined bass on voices 1+2; pure singing lead on voice 3; quiet pure plucks and isolated drum attacks on voice 4. AUDCTL is fixed at 0x50.',
        key='E major, with C# minor and a G#-major dominant in the night theme',
        meter='7/8', accent_grouping='3+2+2',
        tempo_quarter_bpm=60*b.convert.FPS/(UNIT*4), sixteenth_frames=UNIT,
        duration_seconds=len(frames)/b.convert.FPS, lead_channel=3,
        sections=sections, notes=notes, bass_notes=bass_notes,
        harmony_notes=harmony_notes, percussion=percussion, bars=bars,
        allowed_changed_registers=list(range(8)),
        instrument_sources=dict(lead=dict(channel=4, frame=1152, frames=30),
            pluck=dict(channel=3, frame=0, frames=6),
            bass=dict(channel=2, frame=384, frames=24),
            percussion=dict(channel=4, frame=3072, frames=4)),
        lead_envelope=singing, bass_envelope=bass_envelope,
        harmony_envelope=pluck, noise_hit=hit)
    return frames, score, sections
