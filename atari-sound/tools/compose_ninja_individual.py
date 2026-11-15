"""Hand-scored Ninja Commando arrangement: Moonlit Pursuit.

The source has a joined 16-bit bass on voices 1+2, a chord ostinato on
voice 3, and its actual melody on voice 4.  This score deliberately keeps
the bass/ostinato vocabulary and writes a new voice-4 composition.
"""
from pathlib import Path
import build_remixes
import convert

ROOT = Path(__file__).resolve().parents[1]
SOURCE = 'asma/asma/Composers/Gilmore_Adam/Ninja_Commando.sap'
ID = 'ninja-commando-moonlit-pursuit'
TITLE = 'Ninja Commando'
REMIX_TITLE = 'Moonlit Pursuit'
LEAD = 3
TICK = 5                         # Sixteenth note, native source tempo.
BAR = 16*TICK

# Each string is one explicitly scored 4/4 bar.  A dash is a rest, and
# durations are sixteenth notes.  There is no random melody generation.
INTRO = [
    '-:8 D5:4 F5:2 A5:2', 'G5:6 F5:2 D5:4 -:4',
    '-:8 Bb4:4 D5:2 F5:2', 'E5:4 C5:4 D5:6 -:2',
    'D5:6 F5:2 A5:4 -:4', 'G5:4 D5:2 F5:2 A5:4 -:4',
    'F5:4 D5:4 Bb4:4 D5:4', 'E5:4 C5:4 A4:4 -:4',
]
VERSE = [
    'D5:3 -:1 D5:2 F5:2 A5:4 F5:2 E5:2',
    'D5:6 G5:2 F5:2 D5:2 -:4',
    'Bb4:4 D5:2 F5:2 A5:3 -:1 F5:2 D5:2',
    'E5:4 G5:2 E5:2 C5:4 D5:2 -:2',
    'D5:3 -:1 F5:2 A5:2 C6:4 A5:2 F5:2',
    'G5:6 A5:2 F5:2 E5:2 D5:4',
    'Bb5:4 A5:2 F5:2 D5:4 F5:2 E5:2',
    'E5:2 F5:2 D5:8 -:4',
    'D5:2 F5:2 A5:3 -:1 F5:4 E5:2 D5:2',
    'G5:4 A5:2 G5:2 F5:4 D5:2 -:2',
    'Bb4:2 D5:2 F5:4 A5:2 F5:2 D5:4',
    'C5:4 E5:2 G5:2 E5:3 -:1 D5:4',
    'A5:6 F5:2 D5:4 F5:2 A5:2',
    'G5:3 -:1 D5:2 F5:2 A5:4 G5:2 F5:2',
    'Bb5:3 -:1 A5:2 F5:2 D5:2 F5:2 A5:4',
    'G5:4 E5:4 D5:6 -:2',
]
HOOK = [
    'D5:6 F5:2 A5:4 G5:2 F5:2',
    'G5:4 D5:2 F5:2 A5:6 -:2',
    'Bb5:4 A5:2 F5:2 D5:4 F5:4',
    'E5:4 G5:4 C6:4 Bb5:2 A5:2',
    'Bb5:6 F5:2 D5:4 F5:2 Bb5:2',
    'C6:4 G5:4 E5:4 D5:4',
    'A5:4 F5:4 E5:2 D5:2 F5:4',
    'E5:2 F5:2 D5:8 -:4',
    'D5:4 A5:2 F5:2 D6:4 C6:2 A5:2',
    'G5:6 A5:2 F5:4 D5:4',
    'Bb5:4 D6:2 Bb5:2 A5:4 F5:4',
    'E5:4 G5:2 C6:2 G5:4 E5:2 -:2',
    'D6:6 Bb5:2 F5:4 D5:2 F5:2',
    'E5:4 G5:2 C6:2 D6:4 C6:4',
    'A5:4 F5:2 E5:2 D5:4 F5:2 A5:2',
    'G5:2 F5:2 E5:2 F5:2 D5:6 -:2',
]
SECOND = [
    'F5:8 E5:2 D5:2 A4:4',
    'A4:4 C5:4 F5:6 -:2',
    'E5:6 C5:2 A4:4 C5:4',
    'D5:4 G5:6 E5:2 C5:4',
    'D5:8 F5:4 A5:4',
    'C6:6 A5:2 F5:4 A5:4',
    'E5:4 A5:4 C6:4 B5:2 A5:2',
    'G5:6 E5:2 D5:4 -:4',
    'F5:6 A5:2 D6:4 C6:2 A5:2',
    'A5:8 G5:2 F5:2 C5:4',
    'E5:4 C5:2 A4:2 C5:4 E5:4',
    'G5:6 D5:2 C5:4 E5:4',
    'F5:6 E5:2 D5:4 A4:2 D5:2',
    'F5:4 A5:4 C6:6 -:2',
    'E6:4 C6:4 A5:4 E5:4',
    'G5:4 E5:2 D5:2 C5:4 -:4',
]
LANTERNS = [
    'D4:4 A4:4 F5:6 -:2', 'F4:4 C5:4 A5:6 -:2',
    'A4:4 E5:4 C6:6 -:2', 'C5:4 G5:4 D5:6 -:2',
    'D5:6 F5:2 A5:4 -:4', 'A5:4 F5:4 C5:4 -:4',
    'E5:4 C5:4 A4:4 C5:4', 'G4:4 C5:4 D5:6 -:2',
]
BUILD = [
    'D5:4 -:4 F5:4 -:4', 'G5:4 -:4 B5:4 -:4',
    'G5:2 B5:2 D6:4 B5:2 A5:2 G5:4',
    'F5:4 D5:4 A4:4 C5:4',
    'D5:2 D5:2 F5:2 A5:2 C6:2 A5:2 F5:2 D5:2',
    'G5:2 G5:2 B5:2 D6:2 F6:2 D6:2 B5:2 G5:2',
    'E5:2 G5:2 B5:2 D6:2 C6:2 B5:2 A5:2 G5:2',
    'A5:2 F5:2 D5:2 F5:2 A5:2 C6:2 D6:2 -:2',
]
DEVELOPMENT = [
    'D5:2 F5:2 A5:4 C6:2 A5:2 F5:4',
    'G5:3 A5:1 B5:2 D6:2 B5:4 G5:4',
    'E5:2 G5:2 B5:2 D6:2 E6:4 D6:2 B5:2',
    'A5:4 F5:2 E5:2 D5:4 C5:2 D5:2',
    'F5:6 A5:2 D6:2 C6:2 A5:2 F5:2',
    'B5:6 A5:2 G5:2 D5:2 G5:2 B5:2',
    'D6:4 B5:2 G5:2 E5:4 G5:2 A5:2',
    'F5:2 A5:2 D6:4 A5:2 F5:2 D5:4',
    'D6:4 A5:1 F5:1 D5:2 F5:4 A5:4',
    'D6:3 B5:1 G5:2 B5:2 A5:4 G5:4',
    'B5:2 D6:2 E6:3 D6:1 B5:2 A5:2 G5:4',
    'A5:4 F5:2 E5:2 D5:6 -:2',
    'D5:2 F5:2 A5:2 C6:2 D6:4 C6:2 A5:2',
    'G5:2 B5:2 D6:2 F6:2 E6:4 D6:2 B5:2',
    'E6:4 D6:2 B5:2 A5:2 G5:2 E5:4',
    'F5:2 A5:2 D6:4 C6:2 A5:2 D5:2 -:2',
]
FINALE = [
    'D5:6 F5:2 A5:4 G5:2 F5:2',
    'G5:4 D5:2 F5:2 A5:6 -:2',
    'Bb5:4 A5:2 F5:2 D5:4 F5:4',
    'E5:4 G5:4 C6:4 A5:4',
    'Bb5:6 F5:2 D5:4 F5:4',
    'C6:4 G5:4 E5:4 C5:4',
    'D5:4 F5:2 A5:2 D6:6 A5:2',
    'D5:16',
]


def midi(name):
    if name == '-':
        return None
    pitch_class = {'C': 0, 'D': 2, 'E': 4, 'F': 5,
                   'G': 7, 'A': 9, 'B': 11}[name[0]]
    if len(name) == 3:
        pitch_class += {'b': -1, '#': 1}[name[1]]
    return (int(name[-1])+1)*12+pitch_class


def parse_bar(text):
    events = [(midi(n), int(d)) for n, d in
              (event.split(':') for event in text.split())]
    assert sum(d for _, d in events) == 16, text
    return events


def compose(lib):
    source = build_remixes.capture(lib, ROOT/SOURCE, 3520)
    assert all(frame[8] == 0x50 for frame in source)
    # These are measured source bar boundaries, not estimated keys.
    tonic = [640, 720, 800, 880]
    hook_backing = tonic+[1920, 2000, 2080, 2160]
    second_backing = [2560, 2640, 2720, 2800]
    dorian_backing = [3200, 3280, 3360, 3440]
    plans = [
        ('Footsteps on the roof', INTRO, [0, 80, 160, 240]+tonic,
         'D minor pedal; native ostinato emerges before the bass', .55, .8, 'singing'),
        ('Moonlit pursuit', VERSE, tonic,
         'D pedal with Dm, G, Bb and C ostinato colours', .9, 1, 'singing'),
        ('Over the rooftops', HOOK, hook_backing,
         'D pedal for four bars, then Bb / C / Dm / Dm', 1, 1, 'singing'),
        ('Lanterns across the river', SECOND, second_backing,
         'Dm / F / Am / C(add9), one chord per bar', .9, .9, 'singing'),
        ('Still water', LANTERNS, second_backing,
         'Dm / F / Am / C(add9); sparse broken chords', .72, .48, 'pluck'),
        ('A distant signal', BUILD, dorian_backing,
         'Dm-C / G-F / G-F-E-C / Dm-F, introducing B natural', .85, .82, 'singing'),
        ('Chase through the gates', DEVELOPMENT, dorian_backing,
         'D Dorian over the original Dm-G bass/ostinato passage', 1, 1, 'singing'),
        ('The rooftop theme returns', HOOK, hook_backing,
         'Return to D minor: D pedal, then Bb / C / Dm / Dm', 1, 1, 'singing'),
        ('Dawn over the city', FINALE, tonic+[1920, 2000, 640, 640],
         'Bb-C turnaround followed by a two-bar D-minor resolution', .95, 1, 'singing'),
    ]
    # First 30 source frames are one complete lead attack/decay, before
    # its next same-pitch retrigger.  Reuse its native eight-frame vibrato.
    singing_envelope = [frame[7] & 15 for frame in source[1280:1310]]
    pluck_envelope = [frame[7] & 15 for frame in source[2560:2570]]
    vibrato = [build_remixes.pitch(frame[6])-74 for frame in source[1280:1288]]
    frames, sections, bars, notes = [], [], [], []
    for section_index, (name, melody, backing, harmony, gain, bed_gain, voice) in enumerate(plans):
        section_start = len(frames)
        sections.append(dict(name=name, frame=section_start))
        for bar_index, text in enumerate(melody):
            source_start = backing[bar_index % len(backing)]
            bar_start = len(frames)
            events = parse_bar(text)
            bars.append(dict(frame=bar_start, source_frame=source_start,
                             source_frame_count=BAR, section=name,
                             notation=text, harmony=harmony))
            position = 0
            for note, duration in events:
                length = duration*TICK
                notes.append(dict(frame=bar_start+position, duration_frames=length,
                                  midi=note, section=section_index, voice=voice))
                for age in range(length):
                    original = source[source_start+position+age]
                    frame = bytearray(original)
                    local_gain = gain
                    local_bed = bed_gain
                    if section_index == 5:
                        local_gain *= .72+.28*bar_index/7
                        local_bed *= .68+.32*bar_index/7
                    if section_index == 8 and bar_index == 7:
                        # Final sustained tonic settles to silence, making
                        # the restart into the quiet introduction deliberate.
                        release = max(0, (length-1-age)/(length-1))
                        local_gain *= release
                        local_bed *= release
                    for control in (3, 5):
                        frame[control] = ((frame[control] & 0xf0)
                                          | round((frame[control] & 15)*local_bed))
                    envelope = pluck_envelope if voice == 'pluck' else singing_envelope
                    level = envelope[min(age, len(envelope)-1)]
                    release_frames = min(3, max(1, length//10))
                    if age >= length-release_frames:
                        level *= (length-1-age)/release_frames
                    volume = round(level*local_gain) if note is not None else 0
                    frame[7] = 0xa0 | volume
                    if note is not None:
                        detune = vibrato[age % 8] if voice == 'singing' else 0
                        frequency = 440*2**((note+detune-69)/12)
                        frame[6] = max(0, min(255, round(convert.CLOCK/(56*frequency)-1)))
                    frames.append(bytes(frame))
                position += length
            assert position == BAR
        assert len(frames)-section_start == len(melody)*BAR
    assert len(frames) == 8960
    score = dict(
        title=TITLE, remix=REMIX_TITLE, composition='individual',
        description=('A hand-scored, three-minute pursuit in D minor: a clipped '
                     'verse, a broad rooftop hook, a contrasting river theme, '
                     'a sparse plucked interlude, Dorian development, and a '
                     'resolved return. The new melody uses the original actual '
                     'lead voice, its attack/decay and vibrato; bass and chord '
                     'ostinatos are assembled from named original phrases.'),
        source=SOURCE, source_subsong=0, lead_channel=LEAD+1,
        allowed_changed_registers=[3, 5, 6, 7],
        tempo_bpm=convert.FPS*60/(TICK*4), meter='4/4',
        sixteenth_frames=TICK, duration_seconds=len(frames)/convert.FPS,
        instrumentation=('Native joined 16-bit distortion-C bass on voices 1+2; '
                         'native chord ostinato on voice 3; newly scored pure-tone '
                         'melody on voice 4, using the source singing and plucked '
                         'envelopes. Backing volumes follow section dynamics.'),
        sections=sections, bars=bars, notes=notes,
        instruments=dict(singing_envelope=singing_envelope,
                         pluck_envelope=pluck_envelope,
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
    lib = build_remixes.api(args.library)
    frames, score, sections = compose(lib)
    args.output.mkdir(parents=True, exist_ok=True)
    player, labels = long_music.build_player()
    size = long_music.export(args.output, REMIX_TITLE, frames, sections, player, labels)
    (args.output/'score.json').write_text(json.dumps(score, indent=2)+'\n')
    (args.output/'remix-registers.bin').write_bytes(b''.join(frames))
    print(f'{REMIX_TITLE}: {len(frames)/convert.FPS:.2f}s, {len(frames)} frames, '
          f'{len(sections)} sections, {size} compressed bytes')
