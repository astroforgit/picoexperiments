#!/usr/bin/env python3
"""prof2.py SNAP FRAMES FROM TO: cycles per label (all labels) between two label addresses' entry."""
import os, sys, bisect
from collections import Counter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import load_labels  # noqa: E402
from atari_snap import load_snap  # noqa: E402
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
lo, hi = lab[sys.argv[3].upper()], lab[sys.argv[4].upper()]
names = sorted((v, k) for k, v in lab.items() if lo <= v < hi)
addrs = [v for v, _ in names]
a = load_snap(sys.argv[1])
cnt = Counter()
cpu = a.cpu
end = a.frame + int(sys.argv[2])
while a.frame < end:
    pc = cpu.pc
    c0 = cpu.processorCycles
    a.run_until(c0 + 1)
    if lo <= pc < hi and a.mems == 0xFC:
        i = bisect.bisect_right(addrs, pc) - 1
        cnt[names[i][1]] += cpu.processorCycles - c0
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
tot = sum(cnt.values())
for k, v in cnt.most_common(25):
    print(f'{k:12} {100 * v / tot:5.1f}% {v}')
