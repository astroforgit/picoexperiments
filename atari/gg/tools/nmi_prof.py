#!/usr/bin/env python3
"""Profile the NMI by routine (Atari model): nmi_prof.py FRAMES [START]"""
import collections
import os
import re
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari, load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BANKS = {'BANK_INIT': 0xFA, 'BANK_IDLE': 0xFB, 'BANK_SPLIT': 0xFC, 'BANK_COMP': 0xFD, 'BANK_SPR': 0xFF}


def bank_labels():
    """{bank or 0: sorted [(addr, label)]} of code labels from the listing."""
    out = collections.defaultdict(list)
    bank = 0
    pat = re.compile(r'^\s*\d+\s+([0-9A-F]{4})(?: [0-9A-F]{2})*\t+([a-z_][a-z_0-9]*)\b')
    for line in open(os.path.join(HERE, 'gen', 'runtime.lst'), errors='replace'):
        m = pat.match(line)
        if not m:
            continue
        addr, name = int(m.group(1), 16), m.group(2)
        if name.upper() in BANKS:
            bank = BANKS[name.upper()]
        if addr >= 0xE000:
            out[bank].append((addr, name))
        elif addr >= 0xC300:
            out[0].append((addr, name))
    for k in out:
        out[k].sort()
    return out


def where(bl, pc, mems):
    lst = bl[mems] if 0xE000 <= pc < 0xF000 else bl[0]
    best = None
    for a, n in lst:
        if a <= pc:
            best = n
        else:
            break
    return best


if __name__ == '__main__':
    lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
    bl = bank_labels()
    a = Atari(os.path.join(HERE, 'gng.xex'))
    a.boot()
    a.run_frames(int(sys.argv[2]) if len(sys.argv) > 2 else 80)
    cpu = a.cpu
    c = collections.Counter()
    busy = lab['NMI_BUSY']
    for f in range(int(sys.argv[1])):
        t_end = a.next_frame
        while cpu.processorCycles < t_end:
            c0 = cpu.processorCycles
            pc = cpu.pc
            cpu.step()
            if a.mem.ram[busy] or pc == lab['NMI']:
                if 0xC300 <= pc < 0xF000:
                    c[where(bl, pc, a.mems)] += cpu.processorCycles - c0
                else:
                    c[f'game ${pc & 0xFF00:04X}'] += cpu.processorCycles - c0
        a.next_frame += a.frame_cycles
        a.vblank()
    tot = sum(c.values())
    for k, v in c.most_common(30):
        print(f'{k:20} {v / int(sys.argv[1]):8.0f} {100 * v / tot:5.1f}%')
