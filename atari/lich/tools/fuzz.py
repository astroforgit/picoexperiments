#!/usr/bin/env python3
"""Random play: taps directions (and now and then fire / close) for a while,
reporting depth, hp, entity count and where the CPU spends time, and saving
a screenshot every N steps.  Detects hangs (no game ticks consumed).

    python3 tools/fuzz.py [steps] [seed]
"""
import random, sys, bisect, collections
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from emu import Atari, load_labels

HERE = Path(__file__).resolve().parent.parent
L = load_labels(HERE / 'lich.lab')
inv = sorted((v, k) for k, v in L.items() if 0x2000 <= v < 0x9000)
keys = [v for v, k in inv]


def name(pc):
    i = bisect.bisect_right(keys, pc) - 1
    return f'{inv[i][1]}+{pc - inv[i][0]:x}'


def main(steps=300, seed=1, shots_every=50):
    rng = random.Random(seed)
    a = Atari(HERE / 'lich.xex')
    a.boot()
    r = a.mem.ram
    a.run_frames(100)
    a.run_frames(4, lambda f: dict(trig=1)); a.set_input(); a.run_frames(300)
    for step in range(steps):
        k = rng.random()
        if k < 0.04:
            a.run_frames(4, lambda f: dict(trig=1))
        elif k < 0.10:
            a.kbcode, a.skstat = 0x12, 0xFB
            a.run_frames(4)
            a.kbcode, a.skstat = 0xFF, 0xFF
        else:
            s = rng.choice([14, 13, 11, 7])
            a.run_frames(4, lambda f: dict(stick=s))
        a.set_input()
        before = r[L['TICKS']]
        a.run_frames(10)
        if step % shots_every == 0:
            a.screenshot(HERE / 'shots' / f'fuzz_{seed}_{step}.png', scale=2)
        pl = r[L['PL']]
        hp = r[L['E_HP'] + pl]
        print(f'step {step} state {r[L["STATE"]]} depth {r[L["PL_DEPTH"]]} hp {hp - 256 if hp > 127 else hp}'
              f' ents {r[L["ENT_N"]]} phase {r[L["PHASE"]]} modal {r[L["MODAL_TOP"]]} xp {r[L["PL_XP"]]} lvl {r[L["PL_LVL"]]}', flush=True)
        if r[L['TICKS']] >= 2:
            # the main loop is behind: sample where it is
            c = collections.Counter()
            for _ in range(2000):
                for _ in range(29):
                    a.step()
                c[name(a.cpu.pc)] += 1
            print('  busy:', c.most_common(5))


if __name__ == '__main__':
    main(int(sys.argv[1]) if len(sys.argv) > 1 else 300, int(sys.argv[2]) if len(sys.argv) > 2 else 1)
