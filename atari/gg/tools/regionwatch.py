#!/usr/bin/env python3
"""Report non-loader CPU accesses to a region from boot through a level start:
regionwatch.py LO HI [level]"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gng  # noqa: E402

lo, hi = int(sys.argv[1], 16), int(sys.argv[2], 16)
level = int(sys.argv[3]) if len(sys.argv) > 3 else 1
hits = collections.Counter()


def watch(g):
    base = type(g.mem)

    class WMem(base):
        def __getitem__(self, a):
            if lo <= a <= hi and not 0x5400 <= g.cpu.pc < 0x5800 and not (0xD000 <= a < 0xE000 and g.io_on()):
                hits[(g.cpu.pc, 'r', a & 0xFF00, g.loads[-1][1] if g.loads else -1)] += 1
            return base.__getitem__(self, a)

        def __setitem__(self, a, v):
            if lo <= a <= hi and not 0x5400 <= g.cpu.pc < 0x5800 and not (0xD000 <= a < 0xE000 and g.io_on()):
                hits[(g.cpu.pc, 'w', a & 0xFF00, g.loads[-1][1] if g.loads else -1)] += 1
            base.__setitem__(self, a, v)
    g.mem.__class__ = WMem


g = gng.Game(verbose=False)
watch(g)
f0 = g.frame
while not g.loads or g.loads[-1][1] != 0x0A:
    k = g.frame - f0
    g.joy2 = 0xEF if k % 400 in range(200, 210) else 0xFF
    g.run(63 * 312)
g.run(63 * 312 * 150)
g2 = gng.Game(verbose=False, snapshot=gng.menu_snapshot())
watch(g2)
g2 = gng.start_game(level, game=g2)
g2.joy2 = 0xF7
g2.run(63 * 312 * 300)
for (pc, k, page, ld), n in sorted(hits.items()):
    print(f'pc ${pc:04X} {k} page ${page:04X} after load {ld:02X}: {n}')
