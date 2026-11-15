#!/usr/bin/env python3
"""atari_state.py SNAP [FRAMES]: runtime variables and a PC profile."""
import os
import sys
from collections import Counter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import load_labels  # noqa: E402
from atari_snap import load_snap  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1])
n = int(sys.argv[2]) if len(sys.argv) > 2 else 2
ram = a.mem.ram
for v in ('TICKS', 'IRQ_BUSY', 'KICK_ON', 'CHAIN_ON', 'READY', 'SHOWN', 'NLOG', 'IN_C64', 'SS_LATCH',
          'SB_LATCH', 'IRQ_LOST', 'SHIFT_N'):
    print(f'{v.lower()}={ram[lab[v]]:02x}', end=' ')
print()
print('VIC', bytes(ram[0xDE00:0xDE2F]).hex())
pcs = Counter()
cpu = a.cpu
end = a.frame + n
while a.frame < end:
    t = cpu.processorCycles + 200
    a.run_until(t)
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
    pcs[cpu.pc & 0xFFF0] += 1
print(' '.join(f'{p:04x}:{c}' for p, c in pcs.most_common(20)))
