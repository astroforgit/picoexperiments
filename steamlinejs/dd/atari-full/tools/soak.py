#!/usr/bin/env python3
"""Long automated run of double-dragon.xex in the Atari model.

An invincible bot (player 1 health and the timer are held at their
maximum by poking RAM, test-only) walks right, fights and climbs, so the
run reaches later sections and missions. Checks that the game keeps
running (game NMIs, frames composed, the CPU stays in known code) and
saves a screenshot whenever the mission or section changes.

soak.py FRAMES [--ntsc] [--modeb] [--seed N] [--verify-every N]
"""
import random
import sys
from pathlib import Path
from atari_emu import Atari, load_labels

ROOT = Path(__file__).resolve().parents[1]


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 6000
    seed = int(sys.argv[sys.argv.index('--seed') + 1]) if '--seed' in sys.argv else 1
    a = Atari(ROOT / 'double-dragon.xex', pal='--ntsc' not in sys.argv)
    a.boot()
    lab = load_labels(ROOT / 'gen/runtime.lab')
    r = a.mem.ram
    rnd = random.Random(seed)
    modeb = '--modeb' in sys.argv

    def inputs(f):
        if f < 700:
            if f in range(380, 386):
                return dict(consol=6)
            if modeb and (f in range(440, 446) or f in range(470, 476)):
                return dict(consol=5)
            if f in range(600, 606):
                return dict(consol=6)
            return {}
        if f % 1200 < 4:
            return dict(consol=6)          # continue after a game over
        # hunt the nearest active enemy (object slots 1-7): line up in depth,
        # walk to it, then attack facing it; with none left, walk right
        px = r[0x5A] | r[0x62] << 8
        py = r[0x72] | r[0x7A] << 8
        best = None
        for k in range(1, 8):
            if r[0x4A + k] & 0x80 and r[0x3B4 + k]:
                ex = r[0x5A + k] | r[0x62 + k] << 8
                ey = r[0x72 + k] | r[0x7A + k] << 8
                d = abs(ex - px) + abs(ey - py)
                if best is None or d < best[0]:
                    best = (d, ex - px, ey - py)
        if best is None or rnd.random() < 0.05:
            return dict(stick=rnd.choice([7, 7, 7, 6, 5]), trig=f % 8 < 2)
        _, dx, dy = best
        stick = 15
        if dy < -3:
            stick &= 14                 # up
        elif dy > 3:
            stick &= 13                 # down
        if abs(dx) > 22:
            stick &= 11 if dx < 0 else 7
        if stick != 15:
            return dict(stick=stick)
        face = 11 if dx < 0 else 7
        k = f % 16
        if k < 2:
            return dict(stick=face)
        return dict(trig=k in (4, 5) or k in (10, 11), shift=k in (12, 13))

    seen = set()
    last_nmi = [0]
    cpu = a.cpu
    counts = {'nmi': 0}

    def ru(t):
        while cpu.processorCycles < t:
            pc = cpu.pc
            if pc == 0xFF16:
                counts['nmi'] += 1
            cpu.step()
    a.run_until = ru
    for f in range(frames):
        a.run_frames(1, inputs)
        if f > 700:
            r[0x03B4] = 64          # test only: player 1 health
            r[0x0505] = 0x99        # and the timer
        key = (r[0x3D], r[0x3E])
        if key not in seen and f > 700:
            seen.add(key)
            a.screenshot(ROOT / f'gen/soak-m{key[0]}-s{key[1]}.png')
            print(f'frame {a.frame}: mission {key[0]} section {key[1]}  nmis {counts["nmi"]} '
                  f'drops {r[lab["DROPS"]]}', flush=True)
        if f % 500 == 0:
            if counts['nmi'] == last_nmi[0] and f > 0:
                print(f'frame {a.frame}: no game NMI for 500 frames, pc ${cpu.pc:04x}')
                a.screenshot(ROOT / 'gen/soak-stuck.png')
                sys.exit(1)
            last_nmi[0] = counts['nmi']
    a.screenshot(ROOT / 'gen/soak-end.png')
    print(f'done: {frames} frames, {counts["nmi"]} game NMIs, sections seen {sorted(seen)}')


if __name__ == '__main__':
    main()
