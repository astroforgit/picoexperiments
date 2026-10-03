#!/usr/bin/env python3
"""A simple bot: walks right and stabs at the nearest monster, shields when
a monster winds up.  Reports game speed (logic ticks per TV frame).

    python3 tools/play.py FRAMES [shot_every]
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from emu import Atari, load_labels
from shot import step

HERE = Path(__file__).resolve().parent.parent
L = load_labels(HERE / 'lair.lab')
S_LN = 9


def ent(a, i):
    m = a.mem.ram
    g = lambda n: m[L[n] + i]
    x = g('E_XH') << 8 | g('E_XL')
    if x > 32767:
        x -= 65536
    return dict(cls=g('E_CLS'), st=g('E_ST'), x=x, y=g('E_YL'))


def report_hang(a):
    import bisect
    from collections import Counter
    addrs = sorted((v, k) for k, v in L.items() if 0x2000 <= v < 0xc000)
    keys = [v for v, _ in addrs]
    c = Counter()
    for _ in range(30000):
        a.step()
        i = bisect.bisect_right(keys, a.cpu.pc) - 1
        c[f'{addrs[i][1]}+{a.cpu.pc - addrs[i][0]:x}'] += 1
    print('HANG at TV frame', a.frame, c.most_common(10), 'SP', a.cpu.sp)


def run(total, every=0, kh=2, seed=None, god=False, stage=1, hook=None):
    a = Atari(HERE / 'lair.xex')
    a.boot()
    if hook:
        hook(a)
    for s in '150,z,60'.split(','):
        step(a, s)
    for _ in range(kh - 2):
        step(a, 'r')
    step(a, 'z')
    m = a.mem.ram
    a.run_frames(10)
    while m[L['JN']] < stage:        # skip stages (the cart's next-stage request)
        m[L['QW']] = 3
        a.run_frames(20)
    eg = m[L['EG']]
    f0, t0 = a.frame, m[L['FRAMES']] | m[L['FRAMES'] + 1] << 8
    n = 0
    tick = 0
    while a.frame < f0 + total:
        eg = m[L['EG']]
        hero = ent(a, eg)
        mons = [ent(a, i) for i in range(40) if i != eg and 2 <= ent(a, i)['cls'] <= 11]
        stick, trig, dash = 15, 0, 0
        if mons:
            t = min(mons, key=lambda e: abs(e['x'] - hero['x']) + abs(e['y'] - hero['y']))
            dx, dy = t['x'] - hero['x'], t['y'] - hero['y']
            if any(e['st'] == S_LN and abs(e['x'] - hero['x']) < 30 for e in mons) and tick % 40 < 20:
                dash = 1
                stick &= ~(4 if dx < 0 else 8)
            elif abs(dx) > 14 or abs(dy) > 2:
                if dx < -12: stick &= ~4
                if dx > 12: stick &= ~8
                if dy < -1: stick &= ~1
                if dy > 1: stick &= ~2
                if abs(dx) <= 14:
                    stick &= ~(4 if dx < 0 else 8) if abs(dx) < 8 else 15
            else:
                if dx < 0: stick &= ~4
                else: stick &= ~8
                trig = 1 if tick % 8 < 4 else 0
        else:
            stick &= ~8
            trig = 1 if tick % 30 < 3 else 0
        a.run_frames(1, lambda f: dict(stick=stick, trig=trig, dash=dash))
        if god:
            m[L['E_PAL'] + m[L['EG']]] = 0
        # the stage results / game over wait for O
        if m[L['E_ST'] + m[L['FR']]] == 18 and tick % 60 == 0:
            a.run_frames(4, lambda f: dict(trig=1))
            a.set_input()
        tick += 1
        fr_now = m[L['FRAMES']] | m[L['FRAMES'] + 1] << 8
        if tick % 60 == 0:
            if fr_now == getattr(a, '_last_fr', None):
                report_hang(a)
                break
            a._last_fr = fr_now
        if every and tick % every == 0:
            a.screenshot(HERE / 'shots' / f'play_{n:03d}.png', scale=2)
            n += 1
    t1 = m[L['FRAMES']] | m[L['FRAMES'] + 1] << 8
    print(f'TV frames {a.frame - f0}, ticks {t1 - t0} (scene resets make this a lower bound), '
          f'stage {m[L["JN"]]}, hero hp lost {m[L["E_PAL"] + m[L["EG"]]]}, wave {m[L["LV_MR"]]}')
    return a


if __name__ == '__main__':
    run(int(sys.argv[1]) if len(sys.argv) > 1 else 1500, int(sys.argv[2]) if len(sys.argv) > 2 else 0,
        god='god' in sys.argv, stage=int(next((x[5:] for x in sys.argv if x.startswith('stage')), 1)))
