#!/usr/bin/env python3
"""Compare two builds: generated floors (map, fog, entities) must be identical.

    python3 tools/regress.py ref.xex ref.lab [new.xex new.lab]
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from emu import Atari, load_labels

HERE = Path(__file__).resolve().parent.parent


def snapshot(xex, lab, depth):
    L = load_labels(lab)
    a = Atari(xex)
    a.boot()
    a.run_frames(100)
    a.run_frames(4, lambda f: dict(trig=1)); a.set_input(); a.run_frames(300)
    r = a.mem.ram
    while a.cpu.pc != L['MAIN_LOOP']:
        a.step()
    r[L['PL_DEPTH']] = depth
    for lab_ in ('MAIN_LOOP', 'BCB_FLUSH', 'MAKE_NEW_LEVEL'):
        a.cpu.stPushWord(L[lab_] - 1)
    a.cpu.pc = L['BCB_BEGIN']
    while a.cpu.pc != L['MAIN_LOOP']:
        a.step()
        if a.cpu.processorCycles > a.next_frame:
            a.next_frame += 32760
            a.vblank()
    tm = bytes(r[L['TMAP']:L['TMAP'] + 4096])
    fog = bytes(r[L['FOG']:L['FOG'] + 4096])
    ents = []
    for i in range(r[L['ENT_N']]):
        e = r[L['ENT_LIST'] + i]
        ents.append(tuple(r[L[k] + e] for k in ('E_ID', 'E_TX', 'E_TY', 'E_HP', 'E_ATK', 'E_FL', 'E_FBASE', 'E_LOGIC')))
    return tm, fog, ents


if __name__ == '__main__':
    ref = sys.argv[1], sys.argv[2]
    new = (sys.argv[3], sys.argv[4]) if len(sys.argv) > 4 else (HERE / 'lich.xex', HERE / 'lich.lab')
    ok = True
    for d in range(1, 9):
        a = snapshot(*ref, d)
        b = snapshot(*new, d)
        same = [x == y for x, y in zip(a, b)]
        print(f'floor {d}: map {"same" if same[0] else "DIFF"}, fog {"same" if same[1] else "DIFF"},'
              f' entities {"same" if same[2] else "DIFF"} ({len(b[2])})')
        ok &= all(same)
    print('IDENTICAL' if ok else 'DIFFERENT')
