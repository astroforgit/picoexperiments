#!/usr/bin/env python3
"""Steady benchmark from gen/snap/game1900.pkl: 200 frames warm-up, then
pictures and ticks over N frames while walking right and firing.
bench.py [SNAP [N]] [--still] (--still: stand and fire)"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, parse_inputs  # noqa: E402
from atari_emu import load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
still = '--still' in sys.argv
sys.argv = [x for x in sys.argv if x != '--still']
a = load_snap(sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, 'gen', 'snap', 'game1900.pkl'))
n = int(sys.argv[2]) if len(sys.argv) > 2 else 300
f0 = a.frame
st = 15 if still else 7
inp = parse_inputs(','.join(f'{f0 + k * 25}:{st}:1,{f0 + k * 25 + 4}:{st}:0' for k in range(60)))
a.run_frames(200, inputs=inp)
starts = [0]
orig = a.blit_list


def bl():
    v = a.vregs
    st = v[0x50] | v[0x51] << 8 | (v[0x52] & 7) << 16
    if 0x65000 <= st < 0x67A60:
        starts[0] += 1
    return orig()


a.blit_list = bl
r = a.mem.ram
t0 = r[lab['TICKS']]
a.run_frames(n, inputs=inp)
print(f'{n} frames: {starts[0]} pictures ({100 * starts[0] / n:.0f}%), {(r[lab["TICKS"]] - t0) & 255} ticks (mod 256)')
