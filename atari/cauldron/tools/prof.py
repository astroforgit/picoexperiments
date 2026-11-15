#!/usr/bin/env python3
"""prof.py SNAP FRAMES: cycles per runtime routine (labels) and game code."""
import os, sys, bisect
from collections import Counter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import load_labels  # noqa: E402
from atari_snap import load_snap  # noqa: E402
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
names = sorted((v, k) for k, v in lab.items() if '_' not in k[2:3] and len(k) > 4 or k in ('NMI', 'IRQ'))
addrs = [v for v, _ in names]
a = load_snap(sys.argv[1])
n = int(sys.argv[2])
cnt = Counter()
cpu = a.cpu
end = a.frame + n
while a.frame < end:
    pc = cpu.pc
    c0 = cpu.processorCycles
    a.run_until(c0 + 1)
    if 0x8000 <= pc < 0xAA30:
        k = 'game'
    else:
        i = bisect.bisect_right(addrs, pc) - 1
        k = names[i][1] if i >= 0 else '?'
    cnt[k] += cpu.processorCycles - c0
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
tot = sum(cnt.values())
for k, v in cnt.most_common(30):
    print(f'{k:16} {100 * v / tot:5.1f}%  {v // n} per frame')
