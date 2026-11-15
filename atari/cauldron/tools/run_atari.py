#!/usr/bin/env python3
"""run_atari.py FRAMES OUTPREFIX [EVERY] [INPUTS]: boot cauldron.xex in the
model, screenshot every EVERY frames, print where the CPU is."""
import os
import sys
import time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari, load_labels  # noqa: E402
from atari_snap import parse_inputs, save_snap  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    frames, out = int(sys.argv[1]), sys.argv[2]
    every = int(sys.argv[3]) if len(sys.argv) > 3 else frames
    inp = parse_inputs(sys.argv[4] if len(sys.argv) > 4 else '')
    a = Atari(os.path.join(HERE, 'cauldron.xex'), pal=os.environ.get('CAULDRON_NTSC') != '1')
    a.boot()
    t = time.time()
    for f in range(0, frames, every):
        a.run_frames(every, inputs=inp)
        a.screenshot(f'{out}-{a.frame}.png')
        print(f'frame {a.frame} pc ${a.cpu.pc:04X} irqs {getattr(a, "irq_count", 0)} lists {a.blit_lists} '
              f'{round(time.time() - t)}s', flush=True)
    save_snap(a, out + '.pkl')


if __name__ == '__main__':
    main()
