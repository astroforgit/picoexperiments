#!/usr/bin/env python3
"""Sample the main program's PC in the Atari model: atari_where.py FRAMES SAMPLE_FRAMES"""
import collections
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari, load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
inv = sorted((v, k) for k, v in lab.items() if 0xC300 <= v < 0xD000)
a = Atari(os.path.join(HERE, 'gng.xex'))
a.boot()
a.run_frames(int(sys.argv[1]))
c = collections.Counter()
end = a.frame + int(sys.argv[2])
cpu = a.cpu
while a.frame < end:
    t = a.next_frame
    while cpu.processorCycles < t:
        for _ in range(97):
            cpu.step()
        c[cpu.pc] += 1
    a.next_frame += a.frame_cycles
    a.vblank()
for pc, n in c.most_common(25):
    near = [k for v, k in inv if v <= pc][-1:] if 0xC300 <= pc < 0xD000 else ''
    print(f'${pc:04X} {n:5} {near}')
