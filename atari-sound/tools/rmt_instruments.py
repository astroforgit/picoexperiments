"""Trigger real RMT instruments in isolation using the local RMT/ASAP format.

Format references: local rmtplayr.asm and ASAPInfo_ParseRmtSong in ASAP.
No fragments from a mixed song are interpreted as instrument attacks.
"""
import hashlib
import math
from pathlib import Path
from statistics import median
import struct
import tempfile
import build_remixes as b

ROOT = Path(__file__).resolve().parents[1]


def module_bytes(raw):
    if raw[:3] == b'RMT':
        start = int.from_bytes(raw[8:10], 'little')-16
        raw = b'\xff\xff'+struct.pack('<HH', start, start+len(raw)-1)+raw
    return raw


def isolated(raw, instrument, note):
    start, end = struct.unpack_from('<HH', raw, 2)
    data = bytearray(raw[:6+end-start+1])
    def address(): return start+len(data)-6
    lo = address(); data.append(0)
    hi = address(); data.append(0)
    track = address()
    data.extend(struct.pack('<H', note+(15 << 6)+(instrument << 10))+bytes([62, 63, 255]))
    song = address()
    data.extend([0, 255, 255, 255, 254, 0, song & 255, song >> 8])
    data[lo-start+6], data[hi-start+6] = track & 255, track >> 8
    struct.pack_into('<HHH', data, 16, lo, hi, song)
    struct.pack_into('<H', data, 4, address()-1)
    # A single independent voice, also for stereo module instrument definitions.
    data[9], data[10], data[11] = 52, 64, 8
    return data


def sounding_pitch(frames):
    audible = [f for f in frames[4:24] if f[1]&15]
    if not audible: return None
    return median(69+12*math.log2(b.convert.CLOCK/(56*(f[0]+1))/440) for f in audible)


def compatible(frames):
    if any(f[8] or any(f[j]&15 for j in (3, 5, 7)) for f in frames): return False
    if any(f[1]&240 != 160 for f in frames if f[1]&15): return False
    if sum(bool(f[1]&15) for f in frames[:32]) < 28: return False
    if min(f[1]&15 for f in frames[:3]) < 2: return False
    pitches = [69+12*math.log2(b.convert.CLOCK/(56*(f[0]+1))/440) for f in frames[4:24] if f[1]&15]
    # Reject fixed chord/arpeggio instruments which would replace the PICO melody.
    return bool(pitches) and max(pitches)-min(pitches) < 1.5


def extract(library):
    lib = b.api(library)
    paths = sorted((ROOT/'asma').rglob('*.rmt'))+sorted((ROOT.parent/'steamlinejs/atari/vbxe/examples/gacek').glob('*.rmt'))
    bank = dict(version=2, method='Real RMT instruments triggered individually at 61 pitches in ASAP',
                sources=[], voices=[], skipped=[])
    with tempfile.TemporaryDirectory() as temp:
        path = Path(temp)/'instrument.rmt'
        for source in paths:
            original = source.read_bytes(); raw = module_bytes(original)
            offset = int.from_bytes(raw[2:4], 'little')-6
            table = int.from_bytes(raw[14:16], 'little')-offset
            count = min(64, (int.from_bytes(raw[16:18], 'little')-offset-table)//2)
            sid = len(bank['sources'])
            bank['sources'].append(dict(path=str(source.relative_to(ROOT.parent)),
                                       title=source.stem.replace('_', ' '), sha256=hashlib.sha256(original).hexdigest()))
            for inst in range(count):
                if not int.from_bytes(raw[table+inst*2:table+inst*2+2], 'little'): continue
                def capture(note):
                    path.write_bytes(isolated(raw, inst, note))
                    return b.capture(lib, path, 96)
                try:
                    low, high = capture(12), capture(24)
                    if not compatible(low) or not compatible(high): continue
                    if abs(sounding_pitch(high)-sounding_pitch(low)-12) > .5: continue
                    samples = {}
                    for note in range(61):
                        frames = capture(note)
                        if not compatible(frames): continue
                        pitch = sounding_pitch(frames)
                        if abs(pitch-round(pitch)) > .4: continue
                        key = str(round(pitch)-12)  # PICO pitch numbers
                        samples[key] = b''.join(f[:2] for f in frames).hex()
                    if len(samples) < 24: continue
                    bank['voices'].append(dict(id=f'rmt-{sid}-{inst}', source=sid, instrument=inst,
                                               peak=max(f[1]&15 for f in low), samples=samples,
                                               sustain=round(median(f[1]&15 for f in low[8:24])/15, 3)))
                except (ValueError, AssertionError) as exc:
                    bank['skipped'].append(dict(source=sid, instrument=inst, reason=str(exc)))
            print(source.name, 'usable instruments:', sum(v['source'] == sid for v in bank['voices']), flush=True)
    if not bank['voices']: raise RuntimeError('No independently pitched RMT instruments found')
    return bank
