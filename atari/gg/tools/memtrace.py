#!/usr/bin/env python3
"""Trace accesses to $C000-$FFFF: memtrace.py SNAP FRAMES [joy2-script]

Prints, per instruction address, the regions it reads/writes in the VIC bank
and $D000-$DFFF (as I/O or as RAM), and the $01 values seen.
"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gng import Game  # noqa: E402

g = Game(snapshot=sys.argv[1], verbose=True)
frames = int(sys.argv[2])
script = {}
for item in filter(None, (sys.argv[3] if len(sys.argv) > 3 else '').split(',')):
    f, v = item.split(':')
    script[int(f)] = int(v, 0)
acc = collections.defaultdict(lambda: [0x10000, -1, 0])
ports = collections.Counter()
mem = g.mem
orig_get, orig_set = type(mem).__getitem__, type(mem).__setitem__


class TMem(type(mem)):
    def __getitem__(self, a):
        if a >= 0xC000:
            k = (g.cpu_pc, 'r', 'io' if 0xD000 <= a < 0xE000 and g.io_on() else 'ram', a >> 8)
            e = acc[k]
            e[0] = min(e[0], a); e[1] = max(e[1], a); e[2] += 1
        return orig_get(self, a)

    def __setitem__(self, a, v):
        if a >= 0xC000:
            k = (g.cpu_pc, 'w', 'io' if 0xD000 <= a < 0xE000 and g.io_on() else 'ram', a >> 8)
            e = acc[k]
            e[0] = min(e[0], a); e[1] = max(e[1], a); e[2] += 1
        if a == 1:
            ports[v] += 1
        orig_set(self, a, v)


mem.__class__ = TMem
g.cpu_pc = 0
f0 = g.frame
while g.frame - f0 < frames:
    k = g.frame - f0
    if k in script:
        g.joy2 = script[k]
    g.cpu_pc = g.cpu.pc
    g.run(1)
by_pc = collections.defaultdict(list)
for (pc, rw, kind, page), (lo, hi, n) in acc.items():
    by_pc[(pc, rw, kind)].append((lo, hi, n))
for (pc, rw, kind), lst in sorted(by_pc.items()):
    lo = min(x[0] for x in lst); hi = max(x[1] for x in lst); n = sum(x[2] for x in lst)
    print(f'{pc:04x} {rw} {kind:3} ${lo:04x}-${hi:04x} x{n}')
print('$01 writes:', {hex(k): v for k, v in ports.items()})
