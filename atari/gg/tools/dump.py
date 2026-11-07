#!/usr/bin/env python3
"""Run the game N frames (optional GNG_INPUT like shot.py) and dump RAM: dump.py N OUT.bin"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gng import Game  # noqa: E402

g = Game()
f0 = g.frame
inputs = {}
for item in filter(None, os.environ.get('GNG_INPUT', '').split(',')):
    f, v = item.split(':')
    inputs[int(f)] = int(v, 0)
while g.frame - f0 < int(sys.argv[1]):
    k = g.frame - f0
    if k in inputs:
        g.joy2 = inputs[k]
    g.run(63)
open(sys.argv[2], 'wb').write(bytes(g.mem.ram))
print('pc', hex(g.cpu.pc), '$01', hex(g.port[1]))
