#!/usr/bin/env python3
"""Pictures shown and game ticks per N frames from a snapshot: rate.py SNAP N [GNG_INPUT]"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, parse_inputs  # noqa: E402
from atari_emu import load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1])
n = int(sys.argv[2])
inp = parse_inputs(sys.argv[3] if len(sys.argv) > 3 else '')
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
print(f'{n} frames: {starts[0]} pictures, {(r[lab["TICKS"]] - t0) & 255} game ticks')
