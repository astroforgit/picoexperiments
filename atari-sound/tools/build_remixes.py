#!/usr/bin/env python3
"""Three ASMA remix studies: original instruments/rhythm, newly composed leads."""
import argparse
from collections import Counter
import ctypes as ct
import json
import math
from pathlib import Path
import re
import struct
import subprocess
import tempfile
import convert

ROOT = Path(__file__).resolve().parents[1]
TRACKS = [
    dict(id='draconus', title='Draconus', remix='Emberflight',
         source='Composers/Gilmore_Adam/Draconus.sap', frames=1280, lead=2, step=10,
         # Four original motifs, in semitones above each backing chord root.
         motifs=[[12,19,15,10,12,7,10,15,19,17,15,12,10,7,10,12],
                 [19,15,12,15,17,19,22,19,17,15,12,10,7,10,12,15],
                 [7,12,15,19,17,15,10,12,15,12,7,10,12,15,17,19],
                 [22,19,17,15,19,15,12,10,15,12,10,7,10,7,3,0]]),
    dict(id='commando', title='Commando', remix='Night Patrol',
         source='Games/Commando.sap', frames=1728, lead=3, step=12,
         motifs=[[12,15,19,15,22,19,17,15,12,7,10,12,15,12,10,7],
                 [19,22,24,22,19,17,15,12,10,12,15,17,19,15,12,7],
                 [12,19,17,15,10,12,7,10,15,19,22,19,17,15,12,10],
                 [24,22,19,17,15,12,10,7,10,12,15,10,7,3,7,0]]),
    dict(id='warhawk', title='Warhawk', remix='Afterburner',
         source='Composers/Hubbard_Rob/Warhawk.sap', frames=1124, lead=2, step=281/16,
         motifs=[[12,15,19,22,19,17,15,12,10,12,17,15,19,15,10,7],
                 [19,17,15,10,12,15,19,24,22,19,17,15,12,10,7,10],
                 [12,7,10,15,17,19,15,12,10,15,12,7,3,7,10,12],
                 [24,22,19,15,22,19,17,12,19,15,12,10,7,10,3,0]]),
]


def api(path):
    lib = ct.CDLL(str(path))
    for name, result, args in [
        ('Pico_New', ct.c_void_p, []), ('ASAP_Delete', None, [ct.c_void_p]),
        ('ASAP_Load', ct.c_bool, [ct.c_void_p, ct.c_char_p, ct.c_void_p, ct.c_int]),
        ('ASAP_PlaySong', ct.c_bool, [ct.c_void_p, ct.c_int, ct.c_int]),
        ('ASAP_Generate', ct.c_int, [ct.c_void_p, ct.c_void_p, ct.c_int, ct.c_int]),
        ('Pico_Frame', None, [ct.c_void_p, ct.c_void_p]),
    ]:
        f = getattr(lib, name)
        f.restype, f.argtypes = result, args
    return lib


def load(lib, player, path, song=None):
    data = path.read_bytes()
    if song is None:
        match = re.search(rb'^DEFSONG (\d+)',data.split(b'\xff\xff')[0],re.M)
        song = int(match[1]) if match else 0
    if not lib.ASAP_Load(player, str(path).encode(), data, len(data)) or not lib.ASAP_PlaySong(player, song, -1):
        raise ValueError(f'ASAP could not initialize {path}')


def capture(lib, path, count, song=None):
    player = lib.Pico_New()
    try:
        load(lib, player, path, song)
        registers = ct.create_string_buffer(10)
        output = []
        for _ in range(count):
            lib.Pico_Frame(player, registers)
            assert registers.raw[9] == 3, 'Dynamic SKCTL needs an extended player'
            output.append(registers.raw[:9])
        return output
    finally:
        lib.ASAP_Delete(player)


def pitch(divider):
    return 69+12*math.log2(convert.CLOCK/(56*(divider+1))/440)


def tonal(frame, channel):
    c = frame[channel*2+1]
    return bool(c & 15) and c & 0xb0 == 0xa0


def compose(track, original):
    result, score = [], []
    lead, step = track['lead'], track['step']
    for i, old in enumerate(original):
        new = bytearray(old)
        beat = int(i/step)
        phrase, position = divmod(beat, 16)
        if track['id'] == 'draconus':
            # Follow the actual C / Eb / F / Bb backing movement, using its
            # sustained tonal voice rather than guessing from the old lead.
            start = phrase*160
            roots = [round(pitch(f[6])) % 12 for f in original[start:start+160] if tonal(f, 3)]
            root = Counter(roots).most_common(1)[0][0] if roots else 0
        elif track['id'] == 'commando':
            root = [9, 9, 0, 0, 9, 2, 9, 9, 9][phrase % 9]
        else:
            root = 7
        note = 60+root+track['motifs'][phrase % 4][position]
        while note > 86:
            note -= 12
        if tonal(old, lead):
            # Retain the source player's sub-semitone pitch modulation. Only
            # the musical note is replaced; volumes, distortions and drums stay.
            original_pitch = pitch(old[lead*2])
            detune = original_pitch-round(original_pitch)
            frequency = 440*2**((note+detune-69)/12)
            new[lead*2] = max(0, min(255, round(convert.CLOCK/(56*frequency)-1)))
        if i == math.ceil(beat*step):
            score.append(dict(frame=i, midi=note, phrase=phrase, step=position))
        result.append(bytes(new))
    return result, score


def native_original(source, out, title, song=None):
    data = source.read_bytes()
    boundary = data.index(b'\xff\xff')
    header = data[:boundary].decode('ascii')
    def tag(key, default=None):
        m = re.search(r'^'+key+r' (.+)$', header, re.M)
        return m[1].strip() if m else default
    assert tag('TYPE') in ('B','C') and tag('FASTPLAY', '312') == '312'
    ranges = []
    pos = boundary
    while pos < len(data):
        start = int.from_bytes(data[pos:pos+2], 'little'); pos += 2
        if start == 65535:
            continue
        end = int.from_bytes(data[pos:pos+2], 'little'); pos += 2
        assert end < 0xc000, 'Original requires OS banking'
        ranges.append((start,end))
        pos += end-start+1
    base = next((a for a in [0x2000,0x4000,0x5000,0x6000,0x7000,0x8000,0x9000]
                 if all(end<a or start>=a+0x1000 for start,end in ranges)),None)
    assert base is not None, 'No safe wrapper space'
    if song is None: song=int(tag('DEFSONG','0'))
    with tempfile.TemporaryDirectory() as d:
        d = Path(d)
        lines = ['']*24
        lines[1] = '       ORIGINAL / ASMA'
        lines[3] = title.upper()
        lines[5] = tag('AUTHOR').strip('"').upper()
        lines[8] = '  ORIGINAL ATARI MUSIC ROUTINE'
        lines[10] = '  SPACE : PAUSE / RESUME'
        lines[11] = '  N / P : NEXT / PREVIOUS SUBSONG'
        lines[14] = '  CHOOSE ORIGINAL OR REMIX IN'
        lines[15] = '  THE COMPARISON WINDOW.'
        (d/'screen.bin').write_bytes(b''.join(convert.screen_text(s) for s in lines))
        asm = (ROOT/'player/sap-original.asm').read_text().replace("ins 'screen.bin'", f"ins '{d}/screen.bin'")
        asm = asm.replace('org $2000',f'org ${base:04x}').replace('ert * >= $2f00',f'ert * >= ${base+0xf00:04x}')
        asm = asm.replace('song    dta 0',f'song    dta {song}')
        if tag('TYPE') == 'C':
            init, play = int(tag('PLAYER'),16)+3,int(tag('PLAYER'),16)+6
            music=int(tag('MUSIC'),16)
            adapter=(f'type_c_init pha\n lda #$70\n ldx #${music&255:02x}\n ldy #${music>>8:02x}\n'
                     f' jsr ${init:04x}\n pla\n tax\n lda #0\n jmp ${init:04x}\n')
            asm=asm.replace('song    dta',adapter+'song    dta')
            prefix=f'SOURCE_INIT = type_c_init\nSOURCE_PLAYER = ${play:04x}\n'
        else:
            prefix = f'SOURCE_INIT = ${tag("INIT")}\nSOURCE_PLAYER = ${tag("PLAYER")}\n'
        prefix += f'SOURCE_SONGS = {tag("SONGS", "1")}\n'
        (d/'native.asm').write_text(prefix+asm)
        subprocess.run(['mads', str(d/'native.asm'), '-s', f'-o:{d}/native.obx'], check=True, capture_output=True)
        # Disable BASIC before loading source blocks that reside under its ROM.
        basic_off = bytes.fromhex('ad01d309028d01d360')
        xex = b'\xff\xff'+convert.segment(base+0xf00, basic_off)+convert.segment(0x2e2, struct.pack('<H', base+0xf00))
        xex += data[boundary:]+(d/'native.obx').read_bytes()+convert.segment(0x2e0, struct.pack('<H', base))
        (out/'ORIGINAL.XEX').write_bytes(xex)
        (out/'original.sap').write_bytes(data)
    return tag('AUTHOR').strip('"')


def write_remix(folder, title, frames, player, labels):
    data = bytearray(convert.HEADER)
    data[:6] = b'PMS1\1\1'
    data[8:48] = convert.screen_text(title)
    data[0xc0], data[0x100] = (convert.BASE+convert.HEADER) & 255, (convert.BASE+convert.HEADER) >> 8
    data.extend(convert.encode(frames))
    assert len(data) <= convert.MAX_BANK, 'Remix exceeds Atari memory budget'
    (folder/'REMIX.PMS').write_bytes(data)
    binary = player+convert.segment(convert.BASE, data)
    (folder/'REMIX.XEX').write_bytes(binary+convert.segment(0x2e0, struct.pack('<H', labels['start'])))
    seconds = len(frames)/convert.FPS
    header = (f'SAP\r\nAUTHOR "<?>"\r\nNAME "{title}"\r\nDATE "2026"\r\nTYPE B\r\n'
              f'INIT {labels["init"]:04X}\r\nPLAYER {labels["tick"]:04X}\r\n'
              f'TIME {int(seconds)//60:02}:{seconds%60:06.3f} LOOP\r\n')
    (folder/'remix.sap').write_bytes(header.encode()+binary)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--library', required=True, type=Path, help='ASAP shared library with Pico_Frame export')
    args = p.parse_args()
    lib = api(args.library)
    player, labels = convert.build_player('mads')
    catalog = []
    for track in TRACKS:
        folder = ROOT/'remixes'/track['id']
        folder.mkdir(parents=True, exist_ok=True)
        source = ROOT/'asma/asma'/track['source']
        original = capture(lib, source, track['frames'])
        remix, score = compose(track, original)
        author = native_original(source, folder, track['title'])
        write_remix(folder, track['remix'], remix, player, labels)
        audible = sum(tonal(f, track['lead']) for f in original)
        changes = sum(a[track['lead']*2] != b[track['lead']*2] for a,b in zip(original, remix))
        assert changes > audible*.5, 'Lead has not changed enough to be a new arrangement'
        for a,b in zip(original, remix):
            assert all(a[j] == b[j] for j in range(9) if j != track['lead']*2)
        duration = len(remix)/convert.FPS
        item = dict(id=track['id'], title=track['title'], remix=track['remix'], author=author,
                    directory=f'remixes/{track["id"]}', source=str(source.relative_to(ROOT)),
                    duration_seconds=duration, frames=len(remix), lead_channel=track['lead']+1,
                    changed_lead_frames=changes, original_subsong=0,
                    preservation='All volume, distortion, bass, percussion and AUDCTL frames retained; lead AUDF rewritten.')
        (folder/'score.json').write_text(json.dumps(dict(track=track, notes=score), indent=2)+'\n')
        (folder/'manifest.json').write_text(json.dumps(item, indent=2)+'\n')
        (folder/'original-registers.bin').write_bytes(b''.join(original))
        catalog.append(item)
        print(f'{track["title"]} -> {track["remix"]}: {duration:.2f}s, {changes}/{audible} lead frames changed')
    (ROOT/'remixes/catalog.json').write_text(json.dumps(dict(tracks=catalog), indent=2)+'\n')


if __name__ == '__main__':
    main()
