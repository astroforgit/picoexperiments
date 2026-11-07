#!/usr/bin/env python3
"""Static code map of the C64 game and the list of instructions to patch.

Code units:
  'entry'  the RAM image at JMP $0800 (boot remnants + files 09 and 0A),
           patched at build time;
  '06', '0D'..'12'  the title and level code files ($3C8D-$4Fxx), patched
           by the Atari loader after each load.
Seeds are the instructions executed in the coverage runs (gen/cov-*.json)
whose bytes belong to the unit. From the seeds the code is followed
recursively (branches, JSR, JMP abs). Every instruction in the map with an
absolute operand in $D000-$DFFF, or a JSR/JMP into the KERNAL area, is
reported.

Writes gen/codemap.json: {unit: {'code': [instruction addresses], 'refs':
[[pc, opcode, operand], ...]}}.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gng  # noqa: E402
from dis6502 import OPS, MODES  # noqa: E402

HERE = gng.HERE
GEN = os.path.join(HERE, 'gen')
CODE_FILES = ['06', '0D', '0E', '0F', '10', '11', '12']
LOADER_VARS = range(0x5400, 0x5800)


def file_bytes(loads, name):
    out = {}
    for a, h in loads[name]['runs']:
        b = bytes.fromhex(h)
        for i, v in enumerate(b):
            if a + i not in LOADER_VARS:
                out[a + i] = v
    return out


def entry_image():
    g = gng.Game(verbose=False, snapshot=gng.entry_snapshot())
    return bytes(g.mem.ram)


def owner_of(loads, scen_loads):
    """Owner (unit name) of each address after a scenario's sequence of loads."""
    owner = {}
    for n in scen_loads:
        name = f'{n:02X}'
        if name not in loads:
            continue
        for a in file_bytes(loads, name):
            owner[a] = name
    return owner


def follow(mem, seeds, inside):
    """Recursive descent. mem: 64K bytes; inside(addr) -> True if code may be there."""
    code = set()
    work = list(seeds)
    while work:
        pc = work.pop()
        while True:
            if pc in code or not inside(pc):
                break
            op = mem[pc]
            if op not in OPS:
                break
            name, mode = OPS[op]
            ln = 1 + MODES[mode]
            if not all(inside(pc + i) for i in range(ln)):
                break
            code.add(pc)
            w = mem[(pc + 1) & 0xFFFF] | mem[(pc + 2) & 0xFFFF] << 8
            nxt = (pc + ln) & 0xFFFF
            if mode == 'rel':
                off = mem[pc + 1]
                work.append((nxt + (off - 256 if off > 127 else off)) & 0xFFFF)
            if name == 'jsr':
                work.append(w)
            if name == 'jmp' and mode == 'abs':
                pc = w
                continue
            if name in ('rts', 'rti', 'brk') or (name == 'jmp'):
                break
            pc = nxt
    return code


def refs(mem, code):
    out = []
    for pc in sorted(code):
        op = mem[pc]
        name, mode = OPS[op]
        if mode not in ('abs', 'abx', 'aby'):
            continue
        w = mem[pc + 1] | mem[pc + 2] << 8
        if 0xD000 <= w < 0xE000:
            out.append([pc, op, w])
        elif name in ('jsr', 'jmp') and w >= 0xE000 and mode == 'abs':
            out.append([pc, op, w])
    return out


def main():
    loads = json.load(open(os.path.join(GEN, 'loads.json')))
    entry = entry_image()
    # seeds per unit from the coverage runs
    seeds = {u: set() for u in ['entry'] + CODE_FILES}
    for fn in sorted(os.listdir(GEN)):
        if not (fn.startswith('cov-') and fn.endswith('.json')):
            continue
        d = json.load(open(os.path.join(GEN, fn)))
        for pc, own, n in d['exec']:
            if own in seeds:
                seeds[own].add(pc)
            else:
                seeds['entry'].add(pc)
    out = {}
    for unit in ['entry'] + CODE_FILES:
        mem = bytearray(entry)
        if unit == 'entry':
            def inside(a):
                return 0x0002 <= a < 0xFFFA and not 0xD000 <= a < 0xE000
            # executed addresses of the boot image that are not in code files
            s = seeds['entry']
        else:
            fb = file_bytes(loads, unit)
            for a, v in fb.items():
                mem[a] = v

            def inside(a, fb=fb):
                return a in fb
            s = {pc for pc in seeds[unit] if pc in fb}
        code = follow(mem, s, inside)
        r = refs(mem, code)
        out[unit] = {'code': sorted(code), 'refs': r, 'seeds': len(s)}
        print(f'{unit:5}: seeds {len(s):5}  code {len(code):5}  refs {len(r):4}')
    with open(os.path.join(GEN, 'codemap.json'), 'w') as f:
        json.dump(out, f)


if __name__ == '__main__':
    main()
