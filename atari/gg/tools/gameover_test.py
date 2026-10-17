#!/usr/bin/env python3
"""No trainers: walk right into the enemies (firing now and then) until the game is over; screenshots
every 300 frames. gameover_test.py OUTDIR FRAMES"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, parse_inputs  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out = sys.argv[1]
os.makedirs(out, exist_ok=True)
a = load_snap(os.path.join(HERE, 'gen', 'snap', 'menu300.pkl'))
a.mem.ram[0xFA] = 9
f = a.frame
a.run_frames(900, inputs=parse_inputs(f'{f + 20}:15:1,{f + 30}:15:0,{f + 800}:15:1,{f + 810}:15:0'))
f = a.frame
# walk right; fire now and then (the map shown after a death waits for it)
inp = parse_inputs(','.join(f'{f + k * 40}:7:{k % 8 == 7:d}' for k in range(1000)))
for k in range(int(sys.argv[2]) // 300):
    a.run_frames(300, inputs=inp)
    a.screenshot(os.path.join(out, f'go{k:02d}.png'))
    print('frame', a.frame, 'lives $07f2', a.mem.ram[0x07F2], flush=True)
