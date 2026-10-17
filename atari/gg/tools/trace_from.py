#!/usr/bin/env python3
"""Run to frame F with input, then log runtime-label transitions (main and NMI):
trace_from.py F STEPS [GNG_INPUT env like run_atari]"""
import collections
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari  # noqa: E402
from nmi_prof import bank_labels, where  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
bl = bank_labels()
a = Atari(os.path.join(HERE, 'gng.xex'))
a.boot()
inputs = {}
for item in filter(None, os.environ.get('GNG_INPUT', '').split(',')):
    f, st, tr = item.split(':')
    inputs[int(f)] = (int(st, 0), int(tr))
state = {'stick': 15, 'trig': 0}


def inp(frame):
    if frame in inputs:
        state['stick'], state['trig'] = inputs[frame]
    return dict(stick=state['stick'], trig=state['trig'])


a.run_frames(int(sys.argv[1]), inputs=inp)
cpu = a.cpu
last = None
seq = []
hist = collections.deque(maxlen=40)
for i in range(int(sys.argv[2])):
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
    pc = cpu.pc
    hist.append(pc)
    name = where(bl, pc, a.mems) if 0xC300 <= pc < 0xF000 else f'game_{pc >> 8:02X}'
    if name != last:
        seq.append(name)
        last = name
    if pc == 0x5806:
        break
    cpu.step()
print(' '.join(seq[-150:]))
print('last', ' '.join(f'{p:04x}' for p in hist))
