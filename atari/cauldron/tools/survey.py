#!/usr/bin/env python3
"""Memory/IO survey: survey.py SNAP FRAMES OUT.npz [seed]

Plays from a snapshot with a random-walk joystick (long holds, fire bursts)
and records per address CPU reads, writes and executed opcodes, plus the set
of (pc, addr, r/w) I/O accesses and the $01 values seen.
"""
import os, sys, random, pickle
import numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cauldron import Cauldron


def main():
    snap, frames, out = sys.argv[1], int(sys.argv[2]), sys.argv[3]
    rnd = random.Random(int(sys.argv[4]) if len(sys.argv) > 4 else 1)
    c = Cauldron()
    if snap != 'boot':
        c.restore(snap)
    rd = np.zeros(65536, np.int64); wr = np.zeros(65536, np.int64); ex = np.zeros(65536, np.int64)
    io = set(); ports = set(); pcs = [0]
    base = type(c.mem)

    class T(base):
        def __getitem__(self, a):
            rd[a] += 1
            if 0xD000 <= a < 0xE000 and c.io_on():
                io.add((pcs[0], a, 0))
            return base.__getitem__(self, a)

        def __setitem__(self, a, v):
            wr[a] += 1
            if 0xD000 <= a < 0xE000 and c.io_on():
                io.add((pcs[0], a, 1))
            if a == 1:
                ports.add((pcs[0], v))
            base.__setitem__(self, a, v)
    c.mem.__class__ = T
    cpu = c.cpu
    joy, hold = 0xFF, 0
    f0 = c.frame
    while c.frame - f0 < frames:
        if hold <= 0:
            joy = 0xFF & ~(rnd.choice([0, 1, 2, 4, 8, 5, 9, 6, 10, 0x10, 0x18, 0x14, 0x11]))
            hold = rnd.randint(5, 80)
        hold -= 1
        c.joy2 = joy
        end = c.cycles + 63 * 312
        while c.cycles < end:
            pcs[0] = cpu.pc
            ex[cpu.pc] += 1
            c.run(1)
    c.mem.__class__ = base
    c.save(out + '.snap')
    np.savez_compressed(out, read=rd, write=wr, exec=ex,
                        io=np.array(sorted(io), np.int64), ports=np.array(sorted(ports), np.int64))


if __name__ == '__main__':
    main()
