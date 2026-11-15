#!/usr/bin/env python3
"""trace_up.py C64SNAP ATARISNAP FRAMES JOY: the witch's Y and the game state
($6F, $2F, $CBFD) every 20 C64 frames on both machines with JOY held."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cauldron import Cauldron  # noqa: E402
from atari_snap import load_snap  # noqa: E402
from atari_emu import load_labels  # noqa: E402
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
n, joy = int(sys.argv[3]), int(sys.argv[4], 0)
c = Cauldron(); c.restore(sys.argv[1]); c.joy2 = joy
out = []
for f in range(n):
    c.run(19656)
    if f % 20 == 0:
        out.append((f, c.vic[1], c.mem.ram[0x6f], c.mem.ram[0x2f], c.mem.ram[0xcbfd]))
print('C64  ', out)
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab')); cf = lab['C64_FRAME']
a = load_snap(sys.argv[2]); cpu = a.cpu
a.set_input(stick=joy & 15, trig=0 if joy & 0x10 else 1)
out = []
for f in range(n):
    while True:
        pc = cpu.pc; a.run_until(cpu.processorCycles + 1)
        if cpu.processorCycles >= a.next_frame:
            a.next_frame += a.frame_cycles; a.vblank()
        if pc == cf:
            break
    if f % 20 == 0:
        r = a.mem.ram
        out.append((f, r[0xDE01], r[0x6f], r[0x2f], r[0xcbfd]))
print('Atari', out)
