#!/usr/bin/env python3
"""Run the C64 model for N frames from a snapshot (or boot) and save PNGs."""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cauldron import Cauldron
import vic

def main():
    src, frames, out = sys.argv[1], int(sys.argv[2]), sys.argv[3]
    every = int(sys.argv[4]) if len(sys.argv) > 4 else frames
    c = Cauldron()
    if src != 'boot':
        c.restore(src)
    for f in range(frames):
        c.run(19656)
        if (f + 1) % every == 0:
            vic.to_image(vic.render(c), 2).save(f'{out}-{c.frame}.png')
    c.save(out + '.snap')

if __name__ == '__main__':
    main()
