"""Glass Horizon: a new composition borrowing Ninja Commando instruments only.

Every pitch, note placement, chord, bass pattern and structural choice is new.
Only isolated attack/decay shapes and a small vibrato cycle are extracted from
Adam Gilmore's source. No original music frame or backing phrase is replayed.
"""
from pathlib import Path
import build_remixes as b
import convert

SOURCE = 'asma/asma/Composers/Gilmore_Adam/Ninja_Commando.sap'
ID = 'ninja-instruments-glass-horizon'
TITLE = 'Ninja Commando'
REMIX_TITLE = 'Glass Horizon'
LEAD = 3
UNIT = 7
BAR = 16*UNIT

# Explicitly written sixteenth-note durations, in 4/4 at about 107 BPM.
THEME = [
    'C#5:4 G#5:2 E5:2 D#5:6 E5:2',
    'G#4:2 B4:2 C#5:4 E5:6 -:2',
    'A4:4 E5:2 C#5:2 B4:4 C#5:2 E5:2',
    'G#5:6 F#5:2 E5:4 B4:2 -:2',
    'F#4:4 C#5:2 A4:2 G#4:6 A4:2',
    'C#5:4 E5:4 A5:6 -:2',
    'F#5:3 D#5:1 B4:4 D#5:4 F#5:4',
    'E5:4 D#5:2 C#5:2 B4:6 -:2',
]
THEME_ANSWER = [
    'E5:6 G#5:2 C#6:4 B5:2 G#5:2',
    'E5:4 D#5:2 C#5:2 G#4:4 B4:4',
    'C#5:4 A5:4 G#5:2 E5:2 C#5:4',
    'B4:2 E5:2 G#5:4 B5:6 -:2',
    'A5:4 G#5:2 F#5:2 C#5:4 E5:4',
    'E5:4 C#5:2 B4:2 A4:6 -:2',
    'D#5:4 F#5:2 B5:2 A5:4 F#5:4',
    'D#5:6 E5:2 F#5:4 D#5:2 -:2',
]
HOOK = [
    'E5:6 B5:2 G#5:4 F#5:4',
    'D#5:4 F#5:2 B5:2 A5:4 F#5:4',
    'G#5:6 E5:2 C#5:4 E5:4',
    'A5:4 G#5:2 E5:2 C#5:6 -:2',
    'B4:4 E5:2 G#5:2 B5:4 G#5:4',
    'F#5:6 D#5:2 B4:4 D#5:4',
    'A4:4 C#5:4 F#5:6 E5:2',
    'D#5:4 F#5:2 A5:2 B5:6 -:2',
]
HIGH_HOOK = [
    'G#5:6 B5:2 E6:4 D#6:4',
    'B5:4 F#5:2 D#5:2 F#5:4 A5:4',
    'G#5:4 C#6:4 B5:2 G#5:2 E5:4',
    'C#6:6 B5:2 A5:4 G#5:2 E5:2',
    'B5:4 G#5:2 E5:2 G#5:4 B5:4',
    'D#6:6 B5:2 F#5:4 D#5:4',
    'F#5:4 A5:2 C#6:2 A5:4 F#5:4',
    'D#5:4 F#5:4 B5:6 -:2',
]
MIDDLE = [
    'A4:6 C#5:2 E5:4 F#5:4',
    'G#5:8 E5:4 C#5:4',
    'E5:4 C#5:2 B4:2 A4:6 -:2',
    'B4:4 D#5:4 F#5:4 A5:4',
    'C#6:4 A5:2 G#5:2 F#5:4 E5:4',
    'C#5:8 E5:4 A5:4',
    'G#5:6 F#5:2 E5:4 B4:4',
    'G#4:4 C5:4 D#5:6 -:2',
]
QUIET = [
    'E5:8 C#5:4 A4:4', 'B4:4 E5:4 G#5:6 -:2',
    'F#5:8 D#5:4 B4:4', 'C#5:4 E5:4 G#5:6 -:2',
    'A5:6 E5:2 C#5:4 B4:4', 'A4:4 C#5:4 F#5:6 -:2',
    'G#4:4 C5:4 D#5:4 F#5:4', 'E5:8 C#5:6 -:2',
]
BUILD = [
    'F#4:2 -:2 A4:2 -:2 C#5:4 E5:4',
    'A4:2 C#5:2 E5:4 F#5:4 A5:4',
    'G#4:2 B4:2 E5:2 -:2 G#5:4 B5:4',
    'F#5:3 A5:1 B5:4 D#6:4 B5:4',
    'F#5:2 A5:2 C#6:2 A5:2 F#5:4 E5:4',
    'E5:2 C#5:2 A4:2 C#5:2 E5:4 A5:4',
    'F#5:2 B5:2 A5:2 F#5:2 D#5:4 B4:4',
    'G#4:2 C5:2 D#5:2 G#5:2 F#5:4 D#5:2 -:2',
]
SOLO = [
    'A5:3 E5:1 C#5:2 E5:2 A5:4 B5:2 C#6:2',
    'B5:4 A5:2 F#5:2 D#5:2 F#5:2 B5:4',
    'G#5:2 B5:2 D#6:4 F#6:2 D#6:2 B5:4',
    'E6:4 D#6:2 C#6:2 B5:4 G#5:4',
    'A5:2 C#6:2 E6:4 C#6:2 A5:2 F#5:4',
    'E5:2 A5:2 C#6:3 B5:1 A5:4 G#5:2 E5:2',
    'G#5:4 C6:2 D#6:2 F#6:4 D#6:4',
    'C6:4 G#5:2 F#5:2 D#5:4 C5:2 -:2',
]
CODA = [
    'E5:6 B5:2 G#5:4 F#5:4',
    'D#5:4 F#5:2 B5:2 A5:4 F#5:4',
    'G#5:8 E5:4 C#5:4',
    'A5:6 G#5:2 E5:4 C#5:4',
    'F#5:4 E5:2 C#5:2 A4:4 C#5:4',
    'B4:4 D#5:4 F#5:4 B5:4',
    'G#5:4 F#5:2 D#5:2 C5:4 G#4:4',
    'C#5:16',
]

# The bass register is selected separately from the chord voice register.
# C in a G# chord is B# enharmonically: the leading tone into C# minor.
CHORDS = {
    'C#m': (37, (61, 64, 68)), 'A': (33, (57, 61, 64)),
    'E': (40, (59, 64, 68)), 'B': (35, (59, 63, 66)),
    'F#m': (42, (61, 66, 69)), 'G#': (32, (60, 63, 68)),
    'G#m': (32, (59, 63, 68)),
}
VERSE_CHORDS = ['C#m', 'C#m', 'A', 'E', 'F#m', 'A', 'B', 'B']
HOOK_CHORDS = ['E', 'B', 'C#m', 'A', 'E', 'B', 'F#m', 'B']
MIDDLE_CHORDS = ['F#m', 'C#m', 'A', 'B', 'F#m', 'A', 'E', 'G#']
QUIET_CHORDS = ['A', 'E', 'B', 'C#m', 'A', 'F#m', 'G#', 'C#m']
BUILD_CHORDS = ['F#m', 'A', 'E', 'B', 'F#m', 'A', 'B', 'G#']
SOLO_CHORDS = ['A', 'B', 'G#m', 'C#m', 'F#m', 'A', 'G#', 'G#']
CODA_CHORDS = ['E', 'B', 'C#m', 'A', 'F#m', 'B', 'G#', 'C#m']
FORM = [
    ('A line of light', 8, 'intro'),
    ('Glass Horizon - theme', 16, 'theme'),
    ('Wide open sky', 16, 'hook'),
    ('The city below', 8, 'middle'),
    ('Floating lights', 8, 'quiet'),
    ('Towards the horizon', 8, 'build'),
    ('Silver currents', 8, 'solo'),
    ('Wide open sky - return', 8, 'return'),
    ('The last reflection', 8, 'coda'),
]


def _midi(name):
    if name == '-':
        return None
    value = {'C': 0, 'D': 2, 'E': 4, 'F': 5,
             'G': 7, 'A': 9, 'B': 11}[name[0]]
    if len(name) == 3:
        value += {'#': 1, 'b': -1}[name[1]]
    return (int(name[-1])+1)*12+value


def _parse(text):
    result = [(_midi(pitch), int(duration)) for pitch, duration in
              (cell.split(':') for cell in text.split())]
    assert sum(duration for _, duration in result) == 16, text
    return result


def _cells(events, start, section, chord, output):
    cells, cursor = [], 0
    for pitch, duration in events:
        length = duration*UNIT
        output.append(dict(frame=start+cursor, frames=length, midi=pitch,
                           section=section, chord=chord))
        cells.extend((pitch, age, length) for age in range(length))
        cursor += length
    assert cursor == BAR
    return cells


def _volume(envelope, age, length, gain):
    value = envelope[min(age, len(envelope)-1)]*gain
    if age >= length-3:
        value *= (length-1-age)/3
    return max(0, min(15, round(value)))


def _pure(pitch, detune=0):
    frequency = 440*2**((pitch+detune-69)/12)
    return max(0, min(255, round(convert.CLOCK/(56*frequency)-1)))


def compose(lib):
    source = b.capture(lib, b.ROOT/SOURCE, 2570)
    # Copy instrument properties only: none of their note values or placements.
    bass_envelope = [frame[3] & 15 for frame in source[640:650]]
    chord_envelope = [frame[5] & 15 for frame in source[0:24]]
    lead_envelope = [frame[7] & 15 for frame in source[1280:1310]]
    pluck_envelope = [frame[7] & 15 for frame in source[2560:2570]]
    vibrato = [b.pitch(frame[6])-74 for frame in source[1280:1288]]
    frames, sections, notes, bass_notes, harmony_notes, bars = [], [], [], [], [], []
    for section, (name, count, kind) in enumerate(FORM):
        sections.append(dict(name=name, frame=len(frames)))
        for number in range(count):
            position = number % 8
            if kind == 'theme':
                melody = (THEME if number < 8 else THEME_ANSWER)[position]
                chord = VERSE_CHORDS[position]
            elif kind in ('hook', 'return'):
                melody = (HOOK if number < 8 else HIGH_HOOK)[position]
                chord = HOOK_CHORDS[position]
            elif kind in ('intro', 'quiet'):
                melody = QUIET[position]
                chord = QUIET_CHORDS[position]
            elif kind == 'middle':
                melody, chord = MIDDLE[position], MIDDLE_CHORDS[position]
            elif kind == 'build':
                melody, chord = BUILD[position], BUILD_CHORDS[position]
            elif kind == 'solo':
                melody, chord = SOLO[position], SOLO_CHORDS[position]
            else:
                melody, chord = CODA[position], CODA_CHORDS[position]
            lead = _parse(melody)
            if kind == 'intro':
                # Each introduction bar hints at one new melody note, then
                # lets the newly scored chord/bass parts establish the pulse.
                lead = [(None, 8), (lead[0][0], 6), (None, 2)]
            start = len(frames)
            root, voicing = CHORDS[chord]
            next_chord = (VERSE_CHORDS if kind == 'theme' else
                          HOOK_CHORDS if kind in ('hook', 'return') else
                          QUIET_CHORDS if kind in ('intro', 'quiet') else
                          MIDDLE_CHORDS if kind == 'middle' else
                          BUILD_CHORDS if kind == 'build' else
                          SOLO_CHORDS if kind == 'solo' else CODA_CHORDS)[(position+1) % 8]
            # New, syncopated bass parts. No source bass melody is consulted.
            fifth = root+7
            if kind in ('intro', 'quiet'):
                bass = [(root, 6), (None, 2), (fifth, 6), (None, 2)]
            elif kind == 'middle':
                bass = [(root, 4), (fifth, 4), (root+12, 4), (fifth, 4)]
            elif kind in ('build', 'solo'):
                bass = [(root, 3), (fifth, 1), (root+12, 2), (None, 2),
                        (root, 3), (fifth, 1), (root+12, 2), (CHORDS[next_chord][0], 2)]
            else:
                bass = [(root, 3), (None, 1), (fifth, 2), (root+12, 2),
                        (root, 3), (None, 1), (fifth, 2), (root+12, 2)]
            # Chord notes have their own composed rhythm and octave register.
            low, middle, high = voicing
            if kind in ('intro', 'quiet'):
                harmony = [(low, 4), (middle, 4), (high, 4), (middle, 4)]
            elif kind in ('hook', 'return'):
                harmony = [(None, 2), (middle, 2), (high, 2), (low+12, 2),
                           (None, 2), (middle, 2), (high, 2), (middle, 2)]
            elif kind == 'solo':
                harmony = [(low, 2), (middle, 2), (high, 4),
                           (middle, 2), (high, 2), (low+12, 4)]
            else:
                harmony = [(None, 2), (low, 2), (middle, 2), (high, 2),
                           (None, 2), (high, 2), (middle, 2), (low, 2)]
            if kind == 'coda' and position == 7:
                bass = [(root, 16)]
                harmony = [(low, 4), (middle, 4), (high, 8)]
            melody_cells = _cells(lead, start, section, chord, notes)
            bass_cells = _cells(bass, start, section, chord, bass_notes)
            harmony_cells = _cells(harmony, start, section, chord, harmony_notes)
            bars.append(dict(frame=start, frames=BAR, chord=chord, section=section,
                             melody=melody, meter='4/4'))
            gain = .52 if kind in ('intro', 'quiet') else .8 if kind == 'middle' else 1
            if kind == 'build':
                gain = .68+.32*number/7
            for tick in range(BAR):
                # Construct all registers from the new score: no copied frames.
                regs = [0, 0, 0, 0, 0, 0, 0, 0, 0x50]
                pitch, age, length = bass_cells[tick]
                if pitch is not None:
                    frequency = 440*2**((pitch-69)/12)
                    divider = max(0, min(65535, round(convert.CLOCK/(30*frequency)-7)))
                    regs[0], regs[2] = divider & 255, divider >> 8
                    regs[3] = 0xc0 | _volume(bass_envelope, age, length, gain*.85)
                pitch, age, length = harmony_cells[tick]
                if pitch is not None:
                    regs[4] = _pure(pitch)
                    regs[5] = 0xa0 | _volume(chord_envelope, age, length, gain*.40)
                pitch, age, length = melody_cells[tick]
                if pitch is not None:
                    voice = pluck_envelope if kind == 'quiet' else lead_envelope
                    detune = vibrato[(age//2) % 8]*.65 if age >= 8 and kind != 'quiet' else 0
                    regs[6] = _pure(pitch, detune)
                    regs[7] = 0xa0 | _volume(voice, age, length, gain*.82)
                if kind == 'coda' and position == 7:
                    fade = max(0, 1-tick/(BAR-1))
                    for control in (3, 5, 7):
                        regs[control] = (regs[control] & 240) | round((regs[control] & 15)*fade)
                frames.append(bytes(regs))
    assert len(frames) == 9856
    score = dict(
        short_description=('A new C#-minor song opening into E major, with a '
                           'syncopated bass groove, broad sky theme and quiet interlude.'),
        description=('An independently scored 88-bar composition at about 107 BPM. '
                     'The C#-minor verse opens into an E-major chorus, then moves '
                     'through a lyrical F#-minor middle, a sparse plucked passage '
                     'and a harmonic-minor development before the final return. '
                     'Every lead note, chord voicing, bass rhythm and song section '
                     'is newly written; no Ninja Commando backing phrase is used.'),
        composition='standalone original score using borrowed instrument palette',
        preservation='Short instrument envelopes and vibrato only; no source melody, harmony, bass rhythm or backing frames.',
        key='C# minor / E major; G# major dominant', meter='4/4',
        tempo_bpm=60*convert.FPS/(UNIT*4), duration_seconds=len(frames)/convert.FPS,
        notes=notes, bass_notes=bass_notes, harmony_notes=harmony_notes,
        percussion=[],
        percussion_description=('No independent noise drum is added: the source '
                                'palette has a joined bass and two tonal voices. '
                                'The new percussive bass articulation supplies the groove.'),
        bars=bars, sections=sections, form=FORM,
        allowed_changed_registers=list(range(8)),
        provenance=dict(
            source=SOURCE, source_subsong=0, author='Adam Gilmore',
            instrument_sources=dict(
                bass=dict(channel=2, frame=640, frames=10, retained='distortion C, attack/decay'),
                chord=dict(channel=3, frame=0, frames=24, retained='pure-tone attack/decay only'),
                lead=dict(channel=4, frame=1280, frames=30, retained='pure-tone attack/decay'),
                pluck=dict(channel=4, frame=2560, frames=10, retained='short plucked envelope'),
                vibrato=dict(channel=4, frame=1280, frames=8, retained='relative detuning, slowed and reduced')),
            newly_composed=['melody', 'chords', 'bassline', 'chord rhythm', 'tempo', 'form']),
        instruments=dict(bass_envelope=bass_envelope, chord_envelope=chord_envelope,
                         lead_envelope=lead_envelope, pluck_envelope=pluck_envelope,
                         vibrato_semitones=vibrato),
    )
    return frames, score, sections


if __name__ == '__main__':
    import argparse
    import json
    import long_music
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    lib = b.api(args.library)
    frames, score, sections = compose(lib)
    args.output.mkdir(parents=True, exist_ok=True)
    player, labels = long_music.build_player()
    size = long_music.export(args.output, REMIX_TITLE, frames, sections, player, labels)
    (args.output/'score.json').write_text(json.dumps(score, indent=2)+'\n')
    (args.output/'remix-registers.bin').write_bytes(b''.join(frames))
    print(f'{REMIX_TITLE}: {len(frames)/convert.FPS:.2f}s, {len(frames)} frames, '
          f'{len(sections)} sections, {size} compressed bytes')
