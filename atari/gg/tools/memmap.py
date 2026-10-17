#!/usr/bin/env python3
"""Memory usage survey: memmap.py OUT.npz FRAMES LEVEL [LEVEL...]

Plays each level with invincibility (walk right, jump and fire) and records,
per address, CPU reads and writes by the game and writes by the loader
(decruncher code $5400-$57FF), plus every instruction address executed
and every $D000-$DFFF access made with I/O mapped.
"""
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gng import start_game  # noqa: E402


def survey(level, frames, acc):
    g = start_game(level)
    rd, wr, ld, ex, io = acc['read'], acc['write'], acc['load'], acc['exec'], acc['io']
    mem = g.mem
    base = type(mem)
    cpu = g.cpu

    class TMem(base):
        def __getitem__(self, a):
            rd[a] += 1
            if 0xD000 <= a < 0xE000 and g.io_on():
                io.add((cpu_pc[0], a, 'r'))
            return base.__getitem__(self, a)

        def __setitem__(self, a, v):
            if 0x5400 <= cpu_pc[0] < 0x5800:
                ld[a] += 1
            else:
                wr[a] += 1
            if 0xD000 <= a < 0xE000 and g.io_on():
                io.add((cpu_pc[0], a, 'w'))
            base.__setitem__(self, a, v)

    cpu_pc = [0]
    mem.__class__ = TMem
    f0 = g.frame
    while g.frame - f0 < frames:
        k = g.frame - f0
        joy = 0xF7                              # right
        if k % 90 < 4:
            joy &= ~1                           # up = jump
        if k % 23 < 3:
            joy &= ~0x10                        # fire
        if k % 600 > 450:
            joy = 0xFB if k % 40 < 20 else 0xFF  # walk back a little
        g.joy2 = joy
        end = g.cycles + 63 * 312
        while g.cycles < end:
            cpu_pc[0] = cpu.pc
            ex[cpu.pc] += 1
            g.run(1)
    print(f'level {level}: loads {[hex(x[1]) for x in g.loads]}', flush=True)


def main():
    out, frames = sys.argv[1], int(sys.argv[2])
    acc = {k: np.zeros(65536, dtype=np.int64) for k in ('read', 'write', 'load', 'exec')}
    acc['io'] = set()
    for lv in sys.argv[3:]:
        survey(int(lv), frames, acc)
    io = np.array(sorted((pc, a, 1 if k == 'w' else 0) for pc, a, k in acc['io']), dtype=np.int64)
    np.savez_compressed(out, read=acc['read'], write=acc['write'], load=acc['load'], exec=acc['exec'], io=io)


if __name__ == '__main__':
    main()
