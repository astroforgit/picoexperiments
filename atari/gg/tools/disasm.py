#!/usr/bin/env python3
"""Disassemble a range of a 64 KB memory dump: dis.py dump.bin START [END]."""
import sys
from dis6502 import fmt


def dis(mem, start, end):
    pc = start
    while pc < end:
        s, ln, _ = fmt(mem, pc, lambda a: mem[a & 0xFFFF])
        ln = ln or 1
        raw = ' '.join(f'{mem[(pc + i) & 0xFFFF]:02x}' for i in range(ln))
        print(f'{pc:04x}  {raw:9} {s}')
        pc += ln


if __name__ == '__main__':
    m = open(sys.argv[1], 'rb').read()
    s = int(sys.argv[2], 16)
    e = int(sys.argv[3], 16) if len(sys.argv) > 3 else s + 0x100
    dis(m, s, e)
