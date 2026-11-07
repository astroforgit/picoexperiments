#!/usr/bin/env python3
"""Profile complete NMIs from a snapshot: nmi_prof2.py SNAP [NMIS]"""
import collections
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap  # noqa: E402
from atari_emu import load_labels  # noqa: E402
from nmi_prof import bank_labels, where  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
bl = bank_labels()
a = load_snap(sys.argv[1])
n = int(sys.argv[2]) if len(sys.argv) > 2 else 4
cpu, r = a.cpu, a.mem.ram
c = collections.Counter()
lens = []
depth = 0
t0 = 0
done = 0
while done < n:
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
    pc = cpu.pc
    if pc == lab['NMI'] and depth == 0 and not r[lab['NMI_BUSY']]:
        depth = 1
        t0 = cpu.processorCycles
    c0 = cpu.processorCycles
    cpu.step()
    if depth:
        c[where(bl, pc, a.mems) if 0xC300 <= pc < 0xF000 else 'game'] += cpu.processorCycles - c0
        if pc == lab['NMI_OUT'] + 5 and not r[lab['NMI_BUSY']]:
            depth = 0
            lens.append(cpu.processorCycles - t0)
            done += 1
tot = sum(c.values())
print('NMI lengths', lens)
for k, v in c.most_common(30):
    print(f'{k:16} {v // n:7} {100 * v / tot:5.1f}%')
