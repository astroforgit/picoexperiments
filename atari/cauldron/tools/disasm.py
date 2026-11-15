#!/usr/bin/env python3
"""dis.py SNAP START [COUNT]: disassemble memory of a C64 snapshot."""
import sys, os, pickle
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dis6502 import fmt
st = pickle.load(open(sys.argv[1], 'rb'))
m = st['ram']
pc = int(sys.argv[2], 16)
for _ in range(int(sys.argv[3]) if len(sys.argv) > 3 else 40):
    s, l, t = fmt(m, pc, lambda a: m[a & 0xFFFF])
    print(f'{pc:04x}  {" ".join(f"{m[pc+i]:02x}" for i in range(l)):9} {s}')
    pc += l
