#!/usr/bin/env python3
"""Screenshots from an Atari model snapshot: snap_shots.py SNAP OUTDIR FRAME... (GNG_INPUT env)"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, parse_inputs, save_snap  # noqa: E402

a = load_snap(sys.argv[1])
out = sys.argv[2]
os.makedirs(out, exist_ok=True)
inp = parse_inputs(os.environ.get('GNG_INPUT', ''))
for f in sorted(int(x) for x in sys.argv[3:]):
    a.run_frames(f - a.frame, inputs=inp)
    a.screenshot(os.path.join(out, f'a{f:05d}.png'))
    if os.environ.get('GNG_SAVE'):
        save_snap(a, os.path.join(out, f'a{f:05d}.pkl'))
    print('frame', f, flush=True)
