#!/usr/bin/env python3
"""Cycles spent in the NMI per frame (Atari model): nmi_time.py FRAMES [START]"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari, load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = Atari(os.path.join(HERE, 'gng.xex'))
a.boot()
start = int(sys.argv[2]) if len(sys.argv) > 2 else 80
a.run_frames(start)
cpu = a.cpu
nmi, out = lab['NMI'], lab['NMI_OUT']
res = []
for f in range(int(sys.argv[1])):
    t_end = a.next_frame
    t0 = None
    tot = 0
    while cpu.processorCycles < t_end:
        pc = cpu.pc
        if pc == nmi:
            t0 = cpu.processorCycles
        cpu.step()
        if pc == out + 5 and t0 is not None:      # the RTI
            tot += cpu.processorCycles - t0
            t0 = None
    if t0 is not None:
        tot += cpu.processorCycles - t0
    a.next_frame += a.frame_cycles
    a.vblank()
    res.append(tot)
print('NMI cycles per frame:', res, 'frame', a.frame_cycles)
