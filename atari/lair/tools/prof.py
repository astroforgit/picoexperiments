#!/usr/bin/env python3
"""CPU profile of the bot's play: the share of cycles per routine.

    python3 tools/prof.py [warmup_frames] [frames]
"""
import sys
from collections import Counter
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
import play
from emu import load_labels

HERE = Path(__file__).resolve().parent.parent
L = load_labels(HERE / 'lair.lab')
addrs = sorted((v, k) for k, v in L.items() if 0x2000 <= v < 0x9000 and not k.startswith(('?', '@')))
import bisect
keys = [v for v, _ in addrs]


def name(pc):
    i = bisect.bisect_right(keys, pc) - 1
    return addrs[i][1] if i >= 0 else hex(pc)


warm = int(sys.argv[1]) if len(sys.argv) > 1 else 700
n = int(sys.argv[2]) if len(sys.argv) > 2 else 200
a = play.run(warm, god=True, stage=int(sys.argv[3]) if len(sys.argv) > 3 else 1)
c = Counter()
orig = a.step
def step():
    pc = a.cpu.pc
    c0 = a.cpu.processorCycles
    orig()
    c[name(pc)] += a.cpu.processorCycles - c0
a.step = step
play_run = play.run
a.run_frames(n, lambda f: dict(stick=7, trig=(f // 4) % 2))
tot = sum(c.values())
for k, v in c.most_common(40):
    print(f'{k:16s} {100 * v / tot:5.1f}%')
