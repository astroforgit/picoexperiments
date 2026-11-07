#!/usr/bin/env python3
"""Show where a rebuilt XEX differs from the original, segment by segment.
usage: verify.py rebuilt.xex original.xex"""
import sys
from xex import segments

a = list(segments(open(sys.argv[1], 'rb').read()))
b = list(segments(open(sys.argv[2], 'rb').read()))
if len(a) != len(b):
    print('segment count differs: %d vs %d' % (len(a), len(b)))
for (sa, da, ha), (sb, db, hb) in zip(a, b):
    if (sa, len(da), ha) != (sb, len(db), hb):
        print('segment $%04X len %d hdr %s  vs  $%04X len %d hdr %s'
              % (sa, len(da), ha, sb, len(db), hb))
        continue
    bad = [i for i in range(len(da)) if da[i] != db[i]]
    for i in bad[:20]:
        print('$%04X (file seg $%04X+%04X): %02X, expected %02X'
              % (sa + i, sa, i, da[i], db[i]))
    if len(bad) > 20:
        print('... %d differences in segment $%04X' % (len(bad), sa))
sys.exit(1 if a != b else 0)
