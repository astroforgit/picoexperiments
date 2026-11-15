#!/usr/bin/env python3
"""survey_report.py NPZ...: summarise survey runs (unused memory, I/O sites)."""
import sys
import numpy as np


def runs(mask, base=0):
    out, s = [], None
    for a in range(len(mask)):
        if mask[a] and s is None:
            s = a
        if not mask[a] and s is not None:
            out.append((base + s, base + a - 1)); s = None
    if s is not None:
        out.append((base + s, base + len(mask) - 1))
    return out


d = [np.load(p) for p in sys.argv[1:]]
rd = sum(x['read'] for x in d); wr = sum(x['write'] for x in d); ex = sum(x['exec'] for x in d)
used = (rd + wr + ex) > 0
print('unused >=256:', ' '.join(f'{a:04x}-{b:04x}' for a, b in runs(~used) if b - a >= 255))
print('VIC bank writes:', ' '.join(f'{a:04x}-{b:04x}' for a, b in runs(wr[0x4000:0x8000] > 0, 0x4000)))
print('exec:', ' '.join(f'{a:04x}-{b:04x}' for a, b in runs(ex > 0) if b - a > 2))
io = set()
for x in d:
    io |= set(map(tuple, x['io'].tolist()))
pcs = {}
for pc, a, w in io:
    if not (0xD800 <= a < 0xDC00):
        pcs.setdefault((a, w), set()).add(pc)
for k in sorted(pcs):
    print(f'{k[0]:04x}', 'wr' if k[1] else 'rd', ' '.join(f'{p:04x}' for p in sorted(pcs[k])))
cr = {pc for pc, a, w in io if 0xD800 <= a < 0xDC00}
print('colour RAM pcs', ' '.join(f'{p:04x}' for p in sorted(cr)))
