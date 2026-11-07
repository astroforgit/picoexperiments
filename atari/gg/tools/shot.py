#!/usr/bin/env python3
"""Run the C64 game and save reference screenshots: shot.py OUTDIR F1 F2 ...

Input script (optional, env GNG_INPUT): 'frame:joy2[,frame:joy2...]' where
joy2 is the CIA bits value (e.g. 0xef = fire held). GNG_SNAP=file starts
from a snapshot (frames then count from it); GNG_SAVE=1 saves a snapshot
next to every screenshot.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gng import Game  # noqa: E402
from vic import render, to_image  # noqa: E402


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    frames = sorted(int(f) for f in sys.argv[2:])
    inputs = {}
    for item in filter(None, os.environ.get('GNG_INPUT', '').split(',')):
        f, v = item.split(':')
        inputs[int(f)] = int(v, 0)
    g = Game(snapshot=os.environ.get('GNG_SNAP'))
    f0 = g.frame
    for target in frames:
        while g.frame - f0 < target:
            k = g.frame - f0
            if k in inputs:
                g.joy2 = inputs[k]
            g.run(63)
        to_image(render(g), 2).save(os.path.join(out, f'f{target:05d}.png'))
        print('frame', target, 'pc', hex(g.cpu.pc))
        if os.environ.get('GNG_SAVE'):
            g.save(os.path.join(out, f'f{target:05d}.snap'))


if __name__ == '__main__':
    main()
