#!/usr/bin/env python3
"""Start each level on the Atari model (trainer options set in the menu's
RAM, as the options menu would), take screenshots and compare pictures.

level_test.py [--still] OUTDIR LEVEL [LEVEL ...]   (--still: stand and fire)    (needs gen/snap/menu300.pkl:
  python3 tools/atari_snap.py save 300 gen/snap/menu300.pkl)
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, save_snap, parse_inputs  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    args = sys.argv[1:]
    still = '--still' in args
    args = [x for x in args if x != '--still']
    out = args[0]
    os.makedirs(out, exist_ok=True)
    for lv in map(int, args[1:]):
        a = load_snap(os.path.join(HERE, 'gen', 'snap', 'menu300.pkl'))
        r = a.mem.ram
        r[0x9157] = 1            # invincibility
        r[0x915A] = 0x80 + lv    # starting level
        r[0xFA] = 9              # cursor on START GAME
        f = a.frame
        # fire on the menu, then fire now and then in the attract mode until
        # the level runs (a single press at a fixed frame depends on timing)
        a.run_frames(900, inputs=parse_inputs(','.join(f'{f + k}:15:1,{f + k + 10}:15:0' for k in range(20, 900, 60))))
        # walk right, jump now and then
        if still:
            steps = ','.join(f'{a.frame + k * 50}:15:1,{a.frame + k * 50 + 10}:15:0' for k in range(12))
        else:
            steps = ','.join(f'{a.frame + k * 50}:7:{k % 3 == 0:d},{a.frame + k * 50 + 30}:6:0' for k in range(12))
        inp = parse_inputs(steps)
        for k in range(4):
            a.run_frames(150, inputs=inp)
            a.screenshot(os.path.join(out, f'level{lv}_{k}.png'))
        snap = os.path.join(out, f'level{lv}.pkl')
        save_snap(a, snap)
        print(f'level {lv}: frame {a.frame}', flush=True)
        res = subprocess.run([sys.executable, os.path.join(HERE, 'tools', 'verify_render.py'), snap, '60',
                              '--every', '5', '--out', os.path.join(out, f'v{lv}')],
                             capture_output=True, text=True)
        print('  ' + res.stdout.strip().splitlines()[-1] if res.stdout.strip() else res.stderr[-500:], flush=True)


if __name__ == '__main__':
    main()
