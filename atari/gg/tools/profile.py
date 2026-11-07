#!/usr/bin/env python3
"""Per-frame CPU use of the C64 game: profile.py SNAP FRAMES [joy2]

Counts cycles spent in the wait-for-frame loop ($3AB7/$3ABA), in interrupt
handlers and in the main program, and how often $0700 (frame counter) ticks.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gng import Game  # noqa: E402

g = Game(snapshot=sys.argv[1])
g.joy2 = int(sys.argv[3], 0) if len(sys.argv) > 3 else 0xFF
cpu = g.cpu
stats = []
cur = {'idle': 0, 'irq': 0, 'main': 0}
ticks = [0]
last700 = [g.mem.ram[0x700]]


def stop(c):
    return False


frames = int(sys.argv[2])
end = g.frame + frames
f = g.frame
while g.frame < end:
    pc = cpu.pc
    c0 = g.cycles
    in_irq = cpu.p & 4 and cpu.sp < 0xE0
    g.run(1)
    d = g.cycles - c0
    if pc in (0x3AB7, 0x3ABA):
        cur['idle'] += d
    elif cpu.p & 4:
        cur['irq'] += d
    else:
        cur['main'] += d
    if g.mem.ram[0x700] != last700[0]:
        last700[0] = g.mem.ram[0x700]
        ticks[0] += 1
    if g.frame != f:
        stats.append(dict(cur))
        cur = {'idle': 0, 'irq': 0, 'main': 0}
        f = g.frame
tot = 312 * 63
for k in ('idle', 'irq', 'main'):
    v = [s[k] for s in stats]
    print(f'{k:5} avg {sum(v) / len(v) / tot * 100:5.1f}%  max {max(v) / tot * 100:5.1f}%')
print('frames', len(stats), '$0700 ticks', ticks[0])
