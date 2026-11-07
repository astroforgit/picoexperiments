#!/usr/bin/env python3
"""dis.py BANK START END  - linear disassembly of a translated bank."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from dis6502 import fmt
GEN = Path(__file__).resolve().parents[1] / 'gen'
bank = int(sys.argv[1]); a = int(sys.argv[2], 16); e = int(sys.argv[3], 16)
b = (GEN / f'bank{bank}.bin').read_bytes()
base = 0xC000 if bank == 7 else 0x8000
rd = lambda x: b[x - base]
while a < e:
    s, l, t = fmt(None, a, rd)
    print(f'{a:04x}  {" ".join("%02x" % rd(a + i) for i in range(l)):9} {s}')
    a += l
