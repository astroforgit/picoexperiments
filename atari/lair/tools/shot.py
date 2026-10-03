#!/usr/bin/env python3
"""Boot lair.xex headless, play a scripted input sequence, save screenshots.

    python3 tools/shot.py "script"
Steps (comma separated): N (wait N frames), z (tap O / fire), x (tap X /
shield = SHIFT), u/d/l/r[N] (tap a direction N times), H<keys>:N (hold
keys, e.g. Hr:100 or Hrz:30), s:name (screenshot to shots/name.png).
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from emu import Atari

HERE = Path(__file__).resolve().parent.parent
STICK = {'u': 14, 'd': 13, 'l': 11, 'r': 7}
DIRS = {'u': 1, 'd': 2, 'l': 4, 'r': 8}


def inputs(keys):
    m = 0
    for k in keys:
        m |= DIRS.get(k, 0)
    return dict(stick=15 & ~m, trig=1 if 'z' in keys else 0, dash=1 if 'x' in keys else 0)


def step(a, st):
    if not st:
        return
    if st.startswith('s:'):
        (HERE / 'shots').mkdir(exist_ok=True)
        a.screenshot(HERE / 'shots' / f'{st[2:]}.png', scale=3)
        print('shot', st[2:], 'frame', a.frame)
    elif st.isdigit():
        a.run_frames(int(st))
    elif st.startswith('H'):
        keys, n = st[1:].split(':')
        a.run_frames(int(n), lambda f, k=keys: inputs(k))
        a.set_input()
    elif st in ('z', 'x'):
        a.run_frames(4, lambda f, k=st: inputs(k))
        a.set_input()
        a.run_frames(4)
    elif st[0] in STICK:
        n = int(st[1:] or 1)
        for _ in range(n):
            a.run_frames(3, lambda f, k=st[0]: inputs(k))
            a.set_input()
            a.run_frames(6)


def run(script, xex=None):
    a = Atari(xex or HERE / 'lair.xex')
    a.boot()
    for st in script.split(','):
        step(a, st.strip())
    return a


if __name__ == '__main__':
    run(sys.argv[1] if len(sys.argv) > 1 else '150,s:title')
