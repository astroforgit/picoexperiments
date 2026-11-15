#!/usr/bin/env python3
"""compare.py SCRIPT FRAMES EVERY OUT: the C64 model and the Atari port from
power-on with the same joystick script, indexed by C64 frames.

SCRIPT: 'frame:joy,...' with joy as C64 port bits (low = pressed: $FE up,
$FD down, $FB left, $F7 right, $EF fire). Writes OUT-NNNN.png (C64 left,
Atari right) and prints the witch sprite's position on both.
"""
import os
import sys
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cauldron import Cauldron  # noqa: E402
import vic  # noqa: E402
from atari_emu import Atari, load_labels  # noqa: E402
from atari_snap import save_snap  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def script(text):
    ev = sorted((int(f), int(j, 0)) for f, j in (x.split(':') for x in text.split(',') if x))

    def joy(f):
        v = 0xFF
        for t, j in ev:
            if t <= f:
                v = j
        return v
    return joy


def atari_input(j):
    stick = j & 15
    return dict(stick=stick, trig=0 if j & 0x10 else 1)


def main():
    joy = script(sys.argv[1])
    frames, every, out = int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
    lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
    c = Cauldron()
    a = Atari(os.path.join(HERE, 'cauldron.xex'))
    a.boot()
    cf = lab['C64_FRAME']
    cpu = a.cpu
    n = 0                                   # C64 frames run on the Atari
    for f in range(frames):
        c.joy2 = joy(f)
        c.run(19656)
        # the Atari until its C64 frame f has run
        a.set_input(**atari_input(joy(n)))
        while n <= f:
            pc = cpu.pc
            a.run_until(cpu.processorCycles + 1)
            if pc == cf:
                n += 1
                a.set_input(**atari_input(joy(n)))
            if cpu.processorCycles >= a.next_frame:
                a.next_frame += a.frame_cycles
                a.vblank()
        if (f + 1) % every == 0:
            r = a.mem.ram
            print(f'{f + 1:5} C64 witch {c.vic[0] | (c.vic[0x10] & 1) << 8:3},{c.vic[1]:3} scroll {c.mem.ram[0x63]} | '
                  f'Atari {r[0xDE00] | (r[0xDE10] & 1) << 8:3},{r[0xDE01]:3} scroll {r[0x63]}  (Atari frame {a.frame})',
                  flush=True)
            left = vic.to_image(vic.render(c), 1).crop((32, 35, 352, 235))
            right = a.screenshot(scale=1).crop((0, 20, 320, 220))
            img = Image.new('RGB', (640, 200))
            img.paste(left, (0, 0))
            img.paste(right, (320, 0))
            img.resize((1280, 400), Image.NEAREST).save(f'{out}-{f + 1:04d}.png')
    save_snap(a, out + '-atari.pkl')
    c.save(out + '-c64.snap')


if __name__ == '__main__':
    main()
