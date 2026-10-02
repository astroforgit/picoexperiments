#!/usr/bin/env python3
"""Sample the program counter for 200 frames after a shot.py script; prints
the hottest routines (labels without a local suffix)."""
import sys, bisect, collections
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from emu import load_labels
import shot
L = load_labels(Path(__file__).resolve().parent.parent / 'lich.lab')
inv = sorted((v, k) for k, v in L.items() if 0x2000 <= v < 0x9000)
keys = [v for v, k in inv]
a = shot.run(sys.argv[1])
c = collections.Counter()
end = a.frame + 200
while a.frame < end:
    t = a.next_frame
    while a.cpu.processorCycles < t:
        i = bisect.bisect_right(keys, a.cpu.pc) - 1
        c[inv[i][1]] += 1
        a.step()
    a.next_frame += 32760
    a.vblank()
tot = sum(c.values())
for k, v in c.most_common(25):
    print(f'{k:20s} {100 * v / tot:5.1f}%')
