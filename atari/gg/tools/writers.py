#!/usr/bin/env python3
"""Which instructions write the screen/charset area $F000-$FFFF (and colour RAM):
writers.py SCENARIO   (attract | levelN)"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gng  # noqa: E402
from coverage import bot  # noqa: E402

scen = sys.argv[1]
hits = collections.defaultdict(lambda: [0x10000, 0, 0])
g = gng.Game(verbose=False, snapshot=gng.menu_snapshot())
base = type(g.mem)


class WMem(base):
    def __setitem__(self, a, v):
        pc = g.cpu.pc
        if not 0x5400 <= pc < 0x5800:
            if a >= 0xF000 or (0xD800 <= a < 0xDC00 and g.io_on()):
                e = hits[pc]
                e[0] = min(e[0], a); e[1] = max(e[1], a); e[2] += 1
        base.__setitem__(self, a, v)


g.mem.__class__ = WMem
if scen == 'attract':
    g.mem.ram[0xFA] = 9
    for f in range(4000):
        g.joy2 = 0xEF if f in range(5, 10) else 0xFF
        g.run(63 * 312)
else:
    lv = int(scen[5:])
    g = gng.start_game(lv, invincible=False, lives=False, time=False, game=g)
    j = bot(lv)
    for f in range(4000):
        g.joy2 = j(f)
        g.run(63 * 312)
for pc, (lo, hi, n) in sorted(hits.items()):
    print(f'${pc:04X} ${lo:04X}-${hi:04X} x{n}')
