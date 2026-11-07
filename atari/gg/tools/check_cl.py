#!/usr/bin/env python3
"""Compare the Atari char layer with the screen it should show: check_cl.py N"""
import os
import sys
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari, load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = Atari(os.path.join(HERE, 'gng.xex'))
a.boot()
a.run_frames(int(sys.argv[1]))
r, v = a.mem.ram, a.vram
cl = v[0x24000:0x24000 + 64000].reshape(200, 320)
md = [r[lab['ROW_MD'] + i] for i in range(25)]
cs = [r[lab['ROW_CS'] + i] for i in range(25)]
scr = [r[lab['ROW_SCR_HI'] + i] << 8 | r[lab['ROW_SCR_LO'] + i] for i in range(25)]
off = [r[lab['ROW_OFF'] + i] for i in range(25)]


def expect(row, col):
    ch = r[scr[row] + col]
    cc = r[0xD800 + row * 40 + col] & 15
    m = md[row]
    base = cs[row] << 8
    out = np.zeros((8, 8), dtype=np.uint8)
    if m == 2:      # ECM
        g = base + (ch & 63) * 8
        for y in range(8):
            b = r[g + y]
            for x in range(8):
                out[y, x] = (0x80 | cc) if b >> (7 - x) & 1 else ((0xA0 + (ch >> 6) * 16) | cc)
    elif m == 1 and cc & 8:
        g = base + ch * 8
        for y in range(8):
            b = r[g + y]
            for x in range(4):
                p = b >> (6 - 2 * x) & 3
                out[y, 2 * x:2 * x + 2] = 0x40 | p << 4 | cc
    else:
        g = base + ch * 8
        for y in range(8):
            b = r[g + y]
            for x in range(8):
                out[y, x] = (0x80 | cc) if b >> (7 - x) & 1 else (0x40 | cc)
    return out


bad = 0
for row in range(25):
    if md[row] == 3:
        continue
    for col in range(40):
        ring = (col + off[row]) % 40
        got = cl[row * 8:row * 8 + 8, ring * 8:ring * 8 + 8]
        e = expect(row, col)
        if not np.array_equal(got, e):
            bad += 1
            if bad <= 8:
                ch = r[scr[row] + col]
                print(f'row {row} col {col} ch ${ch:02X}: got', got[0].tolist(), 'want', e[0].tolist())
print('bad cells', bad)
