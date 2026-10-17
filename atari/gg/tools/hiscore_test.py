#!/usr/bin/env python3
"""High score entry: start a game, give it one life and a score of 6000 (BCD
at $07F0/$07F1), walk into the enemies until the game is over, then fire
then enters a name (three letters left of END) and runs FRAMES more frames.
Prints the table at $61AE (names) / $61EE (scores). hiscore_test.py OUTDIR FRAMES"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, save_snap, parse_inputs  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out = sys.argv[1]
os.makedirs(out, exist_ok=True)
a = load_snap(os.path.join(HERE, 'gen', 'snap', 'menu300.pkl'))
r = a.mem.ram
r[0xFA] = 9
f = a.frame
a.run_frames(900, inputs=parse_inputs(','.join(f'{f + k}:15:1,{f + k + 10}:15:0' for k in range(20, 900, 60))))
r[0x07F0], r[0x07F1], r[0x07F2] = 0x00, 0x60, 1


def table():
    names = ''.join(chr(c - 0x66 + 0x40) if 0x66 < c < 0x80 else ' ' for c in r[0x61AE:0x61EE])
    scores = [f'{r[0x61EE + 2 * i]:02x}{r[0x61EF + 2 * i]:02x}' for i in range(8)]
    return ' | '.join(f'{names[8 * i:8 * i + 8]} {scores[i]}' for i in range(8))


f = a.frame
inp = parse_inputs(','.join(f'{f + k * 40}:7:{k % 8 == 7:d}' for k in range(1000)))
# until the name entry starts (cursor on END, $0801 = $58)
k = 0
while not (r[0x50] == 0xF0 and r[0x60] == 0x80 and r[0x0801] == 0x58):
    a.run_frames(10, inputs=inp)
    if a.frame % 300 < 10:
        a.screenshot(os.path.join(out, f'hs{k:02d}.png'))
        k += 1
        print('frame', a.frame, 'lives', r[0x07F2], flush=True)
print('name entry at frame', a.frame, flush=True)
# release, three letters left, fire, back to END, fire
seq = [(15, 0, 40)] + [(11, 0, 8), (15, 0, 12)] * 3 + [(15, 1, 8), (15, 0, 30)] + \
      [(7, 0, 8), (15, 0, 12)] * 3 + [(15, 1, 8), (15, 0, 30)]
f = a.frame
ev = []
for st, tr, n in seq:
    ev.append(f'{f}:{st}:{tr}')
    f += n
a.run_frames(f - a.frame, inputs=parse_inputs(','.join(ev)))
a.screenshot(os.path.join(out, 'hs_name.png'))
print(table(), flush=True)
a.run_frames(int(sys.argv[2]), inputs=parse_inputs(''))
a.screenshot(os.path.join(out, 'hs_after.png'))
print(table())
save_snap(a, os.path.join(out, 'hs.pkl'))
