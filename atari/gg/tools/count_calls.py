#!/usr/bin/env python3
"""Count executions of bank/code labels per frame: count_calls.py START FRAMES label..."""
import collections
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari  # noqa: E402
from nmi_prof import bank_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
bl = bank_labels()
want = {}
for bank, lst in bl.items():
    for addr, name in lst:
        if name in sys.argv[3:]:
            want[(bank, addr)] = name
a = Atari(os.path.join(HERE, 'gng.xex'))
a.boot()
a.run_frames(int(sys.argv[1]))
cpu = a.cpu
for f in range(int(sys.argv[2])):
    c = collections.Counter()
    t = a.next_frame
    while cpu.processorCycles < t:
        pc = cpu.pc
        if 0xC300 <= pc < 0xF000:
            k = (a.mems if pc >= 0xE000 else 0, pc)
            if k in want:
                c[want[k]] += 1
        cpu.step()
    a.next_frame += a.frame_cycles
    a.vblank()
    print(a.frame, dict(c))
