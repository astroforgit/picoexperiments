#!/usr/bin/env python3
"""Run N frames, then dump renderer state: atari_dump.py N"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari, load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = Atari(os.path.join(HERE, 'gng.xex'))
a.boot()
a.run_frames(int(sys.argv[1]))
r, v = a.mem.ram, a.vram


def arr(n, k=25):
    return [r[lab[n] + i] for i in range(k)]


def barr(n, bank, k=25):
    base = (bank << 12) + (lab[n] - 0xE000)
    return list(v[base:base + k])


for n in ('ROW_MD', 'ROW_CS', 'ROW_SCR_HI', 'ROW_OFF'):
    print(n, arr(n))
for n in ('ROW_FORCE', 'ROW_DCS', 'ROW_DMD', 'ROW_PRIO'):
    print(n, barr(n, 0x7B))
for n in ('IDLE_RAN', 'IN_IDLE', 'UPD_N', 'UPD_BUSY', 'COL_DIRTY', 'CS_DIRTY', 'NREGION', 'TICKS', 'VFRAME', 'DROPS'):
    print(n, r[lab[n]], end='  ')
print()
print('VIC 11/16/18/15', ' '.join(f'{r[0xde00 + x]:02x}' for x in (0x11, 0x16, 0x18, 0x15)), 'dd00', hex(r[0xdd00]), '$01', hex(r[1]))
scr = (r[0x288] << 8) if r[0x288] else 0x7000
for row in range(0, 25, 3):
    print(f'{row:2}', bytes(r[scr + row * 40:scr + row * 40 + 40]))
