#!/usr/bin/env python3
"""Recursive-descent code map of the game image: codemap.py SNAP [extra entry hex...]

Follows branches, JSR and JMP from the entry points ($800A, the IRQ $A385,
the NMI $A5F4, the targets of the two JMP ($004A) tables at $B190 and
$B174) and from every executed address in the survey runs (gen/survey*.npz,
tools/survey.py). Prints unknown-target indirect jumps and every
instruction with an absolute operand in $D000-$DFFF. Writes
gen/codemap.json, which the build reads.
"""
import os, sys, pickle, json
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dis6502 import OPS, MODES, fmt

BRANCH = {'bpl', 'bmi', 'bvc', 'bvs', 'bcc', 'bcs', 'bne', 'beq'}


def build(ram, entries):
    code = {}
    todo = list(entries)
    ind = set()
    while todo:
        pc = todo.pop()
        while pc not in code:
            op = ram[pc]
            if op not in OPS:
                print(f'bad opcode {op:02x} at {pc:04x}', file=sys.stderr)
                break
            n, m = OPS[op]
            ln = 1 + MODES[m]
            code[pc] = ln
            w = ram[(pc + 1) & 0xFFFF] | ram[(pc + 2) & 0xFFFF] << 8
            if n in BRANCH:
                b = ram[pc + 1]
                todo.append((pc + 2 + (b - 256 if b > 127 else b)) & 0xFFFF)
            elif n == 'jsr':
                todo.append(w)
            elif n == 'jmp':
                if m == 'abs':
                    todo.append(w)
                else:
                    ind.add((pc, w))
                break
            if n in ('rts', 'rti', 'brk'):
                break
            pc = (pc + ln) & 0xFFFF
    return code, ind


def main():
    st = pickle.load(open(sys.argv[1], 'rb'))
    ram = st['ram']
    entries = [0x800A, 0xA385, 0xA5F4] + [int(x, 16) for x in sys.argv[2:]]
    # JMP ($004A) tables: $2F states (8 entries at $B190), $6F states (13 at
    # $B176; entry 0 is not code)
    entries += [ram[0xB190 + 2 * i] | ram[0xB191 + 2 * i] << 8 for i in range(8)]
    entries += [ram[0xB176 + 2 * i] | ram[0xB177 + 2 * i] << 8 for i in range(13)]
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    gen = os.path.join(root, 'gen')
    for f in sorted(os.listdir(gen)):
        if f.startswith('survey') and f.endswith('.npz'):
            ex = np.load(os.path.join(gen, f))['exec']
            entries += [int(a) for a in np.nonzero(ex)[0]]
    code, ind = build(ram, entries)
    print('instructions', len(code))
    for pc, w in sorted(ind):
        print(f'indirect jmp at {pc:04x} via {w:04x}')
    io = []
    for pc in sorted(code):
        op = ram[pc]
        n, m = OPS[op]
        if MODES[m] == 2 and m != 'ind':
            w = ram[pc + 1] | ram[pc + 2] << 8
            if 0xD000 <= w < 0xE000 and not 0xD800 <= w < 0xDC00:
                io.append((pc, n, m, w))
    for pc, n, m, w in io:
        print(f'{pc:04x} {n} {m} {w:04x}')
    json.dump({'code': {f'{k:04x}': v for k, v in code.items()}}, open(os.path.join(gen, 'codemap.json'), 'w'))


if __name__ == '__main__':
    main()
