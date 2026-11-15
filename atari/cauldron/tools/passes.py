#!/usr/bin/env python3
"""passes.py C64SNAP ATARISNAP FRAMES [ADDR] [JOY]: executions of ADDR (default
$8433, once per main loop pass) per C64 frame on both machines."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cauldron import Cauldron  # noqa: E402
from atari_snap import load_snap  # noqa: E402
from atari_emu import load_labels  # noqa: E402
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
n = int(sys.argv[3]); addr = int(sys.argv[4], 16) if len(sys.argv) > 4 else 0x8433
joy = int(sys.argv[5], 0) if len(sys.argv) > 5 else 0xFF
c = Cauldron(); c.restore(sys.argv[1]); c.joy2 = joy; cpu = c.cpu; k = 0
for f in range(n):
    end = c.cycles + 19656
    while c.cycles < end:
        if cpu.pc == addr:
            k += 1
        c.run(1)
print(f'C64   {k / n:.2f}')
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab')); cf = lab['C64_FRAME']
a = load_snap(sys.argv[2]); cpu = a.cpu; k = 0; t = 0
a.set_input(stick=joy & 15, trig=0 if joy & 0x10 else 1)
while t < n:
    pc = cpu.pc
    if pc == addr:
        k += 1
    if pc == cf:
        t += 1
    a.run_until(cpu.processorCycles + 1)
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles; a.vblank()
print(f'Atari {k / n:.2f}')
