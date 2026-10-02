#!/usr/bin/env python3
"""Arrange Porter's PICO-8 gameplay song for two quiet POKEY voices.

Keeps the original pitches, rests, pattern order and 16-tick note timing.
Transposes the bass and lead into 8-bit POKEY's usable pure-tone register.
Instrument envelopes/vibrato are handled by the VBI player, inspired by the
normal/vibrato instruments in Janusz Pelc's HK_PLAY.ASM, not its song data.
"""
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parents[1]
text = (ROOT.parent / 'porterpatch1-1.p8').read_text(encoding='latin1')
sfx = text.split('__sfx__\n')[1].split('__music__')[0].splitlines()
patterns = [line.split() for line in text.split('__music__\n')[1].splitlines()[:16]]
assert int(patterns[0][0], 16) & 1 and int(patterns[-1][0], 16) & 2
lines = ['; Generated from Porter PICO-8 music patterns 0..15.']
for ch in range(2):
    names = []
    for pattern in patterns:
        value = int(pattern[ch + 1], 16)
        names.append('music_rest' if value & 64 else f'music_sfx_{value}_ch{ch}')
    for suffix, operator in [('lo', '<'), ('hi', '>')]:
        lines += [f'music_ch{ch}_{suffix}', '        dta ' + ','.join(operator+n for n in names)]
    for sid in sorted({int(p[ch+1], 16) for p in patterns if not int(p[ch+1], 16) & 64}):
        row = sfx[sid]
        assert int(row[2:4], 16) == 16
        data = []
        for i in range(32):
            note = row[8+i*5:13+i*5]
            pitch, volume = int(note[:2], 16), int(note[3], 16)
            midi = 12 + pitch + (36 if ch == 0 else 12)
            hz = 440 * 2 ** ((midi-69)/12)
            divider = max(0, min(255, round(1773447/(56*hz)-1)))
            data += [divider, min(3 if ch == 0 else 4, math.ceil(volume / 2))]
        lines += [f'music_sfx_{sid}_ch{ch}', '        dta '+','.join(map(str,data))]
lines += ['music_rest', '        :64 dta 0']
(ROOT / 'data/music.inc.asm').write_text('\n'.join(lines)+'\n')
print('Music: original Porter gameplay patterns 0..15, two POKEY voices')
