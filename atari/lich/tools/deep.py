#!/usr/bin/env python3
"""Jump to floor N (test aid): starts a game, then regenerates the level at
depth N from the top of the main loop, and continues a shot.py-like script.

    python3 tools/deep.py N "script"
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from emu import load_labels
import shot

HERE = Path(__file__).resolve().parent.parent
L = load_labels(HERE / 'lich.lab')


def goto_depth(a, n):
    r = a.mem.ram
    while a.cpu.pc != L['MAIN_LOOP']:
        a.step()
    r[L['PL_DEPTH']] = n
    cpu = a.cpu
    for lab in ('MAIN_LOOP', 'BCB_FLUSH', 'MAKE_NEW_LEVEL'):
        cpu.stPushWord(L[lab] - 1)
    cpu.pc = L['BCB_BEGIN']


def run(n, script):
    a = shot.run('100,f,300,c,40')
    goto_depth(a, n)
    a.run_frames(1)
    for step in script.split(','):
        shot.step(a, step.strip())
    return a


if __name__ == '__main__':
    a = run(int(sys.argv[1]), sys.argv[2] if len(sys.argv) > 2 else '60,s:deep')
    r = a.mem.ram
    print('depth', r[L['PL_DEPTH']], 'ents', r[L['ENT_N']])
