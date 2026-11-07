#!/usr/bin/env python3
"""Motion per displayed frame: horizontal shift of the playfield background
(rows of ground, lines 120-140) and of the HUD between consecutive frames.
smooth.py SNAP FRAMES [GNG_INPUT]"""
import os
import sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, parse_inputs  # noqa: E402


def shot(a):
    im = a.screenshot(scale=1)
    return np.asarray(im.convert('L'), dtype=np.int16)


def shift(p, q):
    best, bd = None, 0
    for d in range(-8, 9):
        a = p[:, 16 + d:304 + d]
        b = q[:, 16:304]
        e = np.abs(a - b).mean()
        if best is None or e < best:
            best, bd = e, d
    return bd


a = load_snap(sys.argv[1])
inp = parse_inputs(os.environ.get('GNG_INPUT', ''))
prev = None
out = []
for _ in range(int(sys.argv[2])):
    a.run_frames(1, inputs=inp)
    s = shot(a)
    if prev is not None:
        out.append((shift(s[140:160], prev[140:160]), shift(s[-36:-20], prev[-36:-20])))
    prev = s
print('ground:', ''.join(str(abs(g)) if g >= 0 else '-' for g, _ in out))
print('hud:   ', ''.join(str(abs(h)) for _, h in out))
