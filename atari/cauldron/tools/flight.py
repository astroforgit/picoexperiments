#!/usr/bin/env python3
"""flight.py C64SNAP ATARISNAP: from snapshots at the cottage, hold up until the
witch is above line 100, then right for 150 frames. Prints the climb time
and the landscape scroll (coarse steps of the map pointer $AC) on both."""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cauldron import Cauldron  # noqa: E402
from atari_emu import load_labels  # noqa: E402
from atari_snap import load_snap  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def run(step, read, frames=400):
    climb = None
    phase = 'up'
    t_right = 0
    pos = []
    for f in range(frames):
        y = read(0xD001)
        if phase == 'up' and y <= 100:
            climb, phase, t_right = f, 'right', f
        step(0xFE if phase == 'up' else 0xF7)
        if phase == 'right':
            pos.append(read(0xAC) | read(0xAD) << 8)
            if f - t_right >= 150:
                break
    return climb, pos


def main():
    c = Cauldron()
    c.restore(sys.argv[1])

    def c_step(j):
        c.joy2 = j
        c.run(19656)

    def c_read(a):
        return c.vic[a & 0x3F] if 0xD000 <= a < 0xD040 else c.mem.ram[a]
    print('C64  ', summary(*run(c_step, c_read)))
    a = load_snap(sys.argv[2])
    lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
    cf = lab['C64_FRAME']
    cpu = a.cpu

    def a_step(j):
        a.set_input(stick=j & 15, trig=0)
        while True:
            pc = cpu.pc
            a.run_until(cpu.processorCycles + 1)
            if cpu.processorCycles >= a.next_frame:
                a.next_frame += a.frame_cycles
                a.vblank()
            if pc == cf:
                return

    def a_read(addr):
        return a.mem.ram[0xDE00 + (addr & 0x3F)] if 0xD000 <= addr < 0xD040 else a.mem.ram[addr]
    print('Atari', summary(*run(a_step, a_read)))


def summary(climb, pos):
    if climb is None:
        return 'did not climb above line 100'
    steps = sum(1 for p, q in zip(pos, pos[1:]) if p != q)
    return f'climb {climb} frames, map pointer changes in 150 frames: {steps} ({pos[0]:04X} -> {pos[-1]:04X})'


if __name__ == '__main__':
    main()
