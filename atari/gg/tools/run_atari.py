#!/usr/bin/env python3
"""Boot gng.xex in the headless Atari model and save screenshots:
run_atari.py OUTDIR FRAME [FRAME...]   (env GNG_INPUT: 'frame:stick:trig,...')"""
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    frames = sorted(int(f) for f in sys.argv[2:])
    a = Atari(os.path.join(HERE, 'gng.xex'), pal=True)
    t0 = time.time()
    a.boot()
    print('booted in', round(time.time() - t0, 1), 's, pc', hex(a.cpu.pc))
    inputs = {}
    for item in filter(None, os.environ.get('GNG_INPUT', '').split(',')):
        f, st, tr = item.split(':')
        inputs[int(f)] = (int(st, 0), int(tr))
    state = {'stick': 15, 'trig': 0}

    def inp(frame):
        if frame in inputs:
            state['stick'], state['trig'] = inputs[frame]
        return dict(stick=state['stick'], trig=state['trig'])

    for f in frames:
        a.run_frames(f - a.frame, inputs=inp)
        a.screenshot(os.path.join(out, f'a{f:05d}.png'))
        print('frame', f, 'pc', hex(a.cpu.pc), 'drops', a.mem.ram[0xDC10 + 0], 'blits', a.blits,
              round(time.time() - t0, 1), 's', flush=True)


if __name__ == '__main__':
    main()
