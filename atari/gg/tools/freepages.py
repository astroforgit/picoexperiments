#!/usr/bin/env python3
"""Pages never accessed (CPU, excluding the loader) after the entry point:
menu, attract mode and a level-1 game with deaths. freepages.py"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gng  # noqa: E402
from coverage import bot  # noqa: E402

used = bytearray(65536)
g = gng.Game(verbose=False, snapshot=gng.entry_snapshot())
base = type(g.mem)


class UMem(base):
    def __getitem__(self, a):
        if not 0x5400 <= g.cpu.pc < 0x5800:
            used[a] |= 1
        return base.__getitem__(self, a)

    def __setitem__(self, a, v):
        if not 0x5400 <= g.cpu.pc < 0x5800:
            used[a] |= 2
        base.__setitem__(self, a, v)


g.mem.__class__ = UMem
g.run(63 * 312 * 150)                      # menu
g.mem.ram[0xFA] = 9
for f in range(3000):                       # attract, then a game with deaths
    g.joy2 = 0xEF if f % 400 in range(10, 15) else 0xFF
    g.run(63 * 312)
j = bot(7)
for f in range(3000):
    g.joy2 = j(f)
    g.run(63 * 312)
free = [p for p in range(256) if not any(used[p * 256:p * 256 + 256])]
print('free pages:', ' '.join(f'{p:02X}' for p in free))
for p in (0x02, 0x03, 0x04, 0x05):
    print(f'page {p:02X} used bytes:', ' '.join(f'{a & 255:02X}' for a in range(p * 256, p * 256 + 256) if used[a]))
zp = [a for a in range(256) if not used[a]]
print('free zero page:', ' '.join(f'{a:02X}' for a in zp))
