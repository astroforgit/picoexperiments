#!/usr/bin/env python3
"""Level skip on the Atari model: trainer "left arrow skips the level" on,
TAB pressed in the game; screenshots after each skip. skip_test.py OUTDIR SKIPS"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, parse_inputs  # noqa: E402
from atari_emu import load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
out = sys.argv[1]
os.makedirs(out, exist_ok=True)
a = load_snap(os.path.join(HERE, 'gen', 'snap', 'menu300.pkl'))
r = a.mem.ram
r[0x9157] = 1            # invincibility
r[0x915B] = 1            # left arrow skips the level
r[0xFA] = 9
f = a.frame
a.run_frames(900, inputs=parse_inputs(f'{f + 20}:15:1,{f + 30}:15:0,{f + 800}:15:1,{f + 810}:15:0'))
a.screenshot(os.path.join(out, 'skip0.png'))
for k in range(1, int(sys.argv[2]) + 1):
    for _ in range(6):                       # TAB held for 6 frames
        a.set_input(key=0x2C)
        a.run_frames(1)
    a.set_input()
    loads = []
    for _ in range(500):
        a.run_frames(1)
        if a.cpu.pc == lab['LDR_ENTRY']:
            loads.append(a.frame)
    a.screenshot(os.path.join(out, f'skip{k}.png'))
    print('skip', k, 'frame', a.frame, 'ticks', r[lab['TICKS']], flush=True)
