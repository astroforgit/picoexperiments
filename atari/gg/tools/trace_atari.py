#!/usr/bin/env python3
"""Trace gng.xex in the Atari model by runtime labels: trace_atari.py STEPS [SKIP]"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari, load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
inv = {}
for k, v in lab.items():
    inv.setdefault(v, k)
a = Atari(os.path.join(HERE, 'gng.xex'))
a.boot()
cpu = a.cpu
steps = int(sys.argv[1])
skip = int(sys.argv[2]) if len(sys.argv) > 2 else 0
seq = []
last = None
hist = []
for i in range(steps):
    pc = cpu.pc
    hist.append(pc)
    if len(hist) > 50:
        hist.pop(0)
    if i >= skip and pc in inv and inv[pc] != last:
        last = inv[pc]
        seq.append(f'{inv[pc]}@{i}')
    if pc == 0 or (0xD000 <= pc < 0xD800):
        print('bad pc', hex(pc), 'at step', i)
        break
    cpu.step()
print(' '.join(seq[-120:]))
print('last pcs', ' '.join(f'{p:04x}' for p in hist))
