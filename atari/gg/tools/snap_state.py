#!/usr/bin/env python3
"""Renderer state of an Atari model snapshot (after N more frames): snap_state.py SNAP [N]"""
import os
import sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap  # noqa: E402
from atari_emu import load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1])
if len(sys.argv) > 2:
    a.run_frames(int(sys.argv[2]))
r = a.mem.ram


def arr(n, k):
    return [r[lab[n] + i] for i in range(k)]


n = r[lab['NREGION']]
print('frame', a.frame, 'nregion', n, 'ticks', r[lab['TICKS']], 'drops', r[lab['DROPS']], 'pending', r[lab['PENDING']])
for k in ('RG_L0', 'RG_D011', 'RG_D016', 'RG_D018', 'RG_DD00', 'RG_D020', 'RG_D021'):
    print(f'{k:8}', ' '.join(f'{x:02x}' for x in arr(k, n)))
for k in ('ROW_MD', 'ROW_CS', 'ROW_SCR_HI', 'ROW_OFF'):
    print(f'{k:10}', ' '.join(f'{x:02x}' for x in arr(k, 25)))
ni = r[lab['NINST']]
print('instances', ni)
for i in range(ni):
    print('  y', r[lab['IN_Y'] + i], 'x', r[lab['IN_X'] + i], 'fl', hex(r[lab['IN_FL'] + i]), 'ptr', hex(r[lab['IN_PTR'] + i]),
          'col', r[lab['IN_COL'] + i], 'l0', r[lab['IN_L0'] + i], 'l1', r[lab['IN_L1'] + i])
print('VIC', ' '.join(f'{r[0xde00 + i]:02x}' for i in range(0x2f)))
print('pal_cur', arr('PAL_CUR', 6), 'win', r[lab['WIN_TOP']], r[lab['WIN_BOT']])
cl = a.vram[0x24000:0x24000 + 64000]
print('char layer non-zero pixels', int((cl != 0).sum()))
