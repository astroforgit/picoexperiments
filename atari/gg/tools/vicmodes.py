#!/usr/bin/env python3
"""Distinct VIC configurations per phase: vicmodes.py (attract, menu, level 1 play)."""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gng  # noqa: E402
from coverage import bot  # noqa: E402

KEYS = (0x11, 0x16, 0x18, 0x1C, 0x17, 0x1D, 0x1B, 0x15, 0x21, 0x22, 0x23)


def collect(g, frames, joy, label):
    seen = collections.Counter()
    for f in range(frames):
        g.joy2 = joy(f)
        g.run(63 * 312)
        regs0, dd, log, ptrs = g.last_frame
        regs = bytearray(regs0)
        state = None
        for line, cyc, r, v in log + [(400, 0, None, 0)]:
            cur = (dd & 3,) + tuple(regs[k] for k in KEYS)
            if r is None or r == 0x40 or r < 0x40:
                seen[cur] += 1
            if r is None:
                break
            if r == 0x40:
                dd = v
            elif r < 0x40:
                regs[r] = v
    print('==', label)
    print('dd00 d011 d016 d018 d01c d017 d01d d01b d015 d021 d022 d023')
    for k, n in seen.most_common(40):
        print(' '.join(f'{x:02x}' for x in k), n)


g = gng.Game(verbose=False, snapshot=gng.menu_snapshot())
collect(g, 60, lambda f: 0xFF, 'menu')
g.mem.ram[0xFA] = 9
collect(g, 2500, lambda f: 0xEF if f in range(5, 10) else 0xFF, 'attract')
g = gng.start_game(1)
collect(g, 1500, bot(1), 'level 1')
