#!/usr/bin/env python3
"""Boot lich.xex headless, play a scripted input sequence, save screenshots.

    python3 tools/shot.py [frames] [script]
script: comma-separated steps "N" (wait N frames), "f" (fire), "u/d/l/r" (tap
direction), "c" (close key C), "s:name" (screenshot to shots/name.png).
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from emu import Atari

HERE = Path(__file__).resolve().parent.parent
STICK = {'u': 14, 'd': 13, 'l': 11, 'r': 7}

def step(a, step):
    if not step:
        return
    if step.startswith('s:'):
        a.screenshot(HERE / 'shots' / f'{step[2:]}.png', scale=3)
        print('shot', step[2:], 'frame', a.frame)
    elif step.isdigit():
        a.run_frames(int(step))
    elif step == 'f':
        a.run_frames(4, lambda f: dict(trig=1))
        a.set_input()
        a.run_frames(4)
    elif step == 'c':
        a.kbcode, a.skstat = 0x12, 0xFB
        a.run_frames(4)
        a.kbcode, a.skstat = 0xFF, 0xFF
        a.run_frames(4)
    elif step[0] in STICK:
        n = int(step[1:] or 1)
        for _ in range(n):
            a.run_frames(4, lambda f, s=STICK[step[0]]: dict(stick=s))
            a.set_input()
            a.run_frames(12)


def run(script):
    a = Atari(HERE / 'lich.xex')
    a.boot()
    for st in script.split(','):
        step(a, st.strip())
    return a


if __name__ == '__main__':
    a = run(sys.argv[1] if len(sys.argv) > 1 else '150,s:title')
