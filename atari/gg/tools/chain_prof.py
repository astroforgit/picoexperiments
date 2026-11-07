#!/usr/bin/env python3
"""Profile the IRQ chain phase of the NMI: chain_prof.py SNAP [N]"""
import collections
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap  # noqa: E402
from atari_emu import load_labels  # noqa: E402
from nmi_prof import bank_labels, where  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
bl = bank_labels()
a = load_snap(sys.argv[1])
n = int(sys.argv[2]) if len(sys.argv) > 2 else 3
cpu = a.cpu
c = collections.Counter()
calls = collections.Counter()
inchain = False
done = 0
fn = {v: k for k, v in lab.items() if k in ('SPLIT_TAKE', 'SPLIT_BEGIN', 'SPLIT_END', 'REC_REGION', 'REC_SPRITES',
                                              'ROWS_STATE', 'REC_PALETTE', 'CALL_IRQ', 'FB_LINE', 'SCR_BASE')}
while done < n:
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
    pc = cpu.pc
    if pc == lab['RUN_CHAIN']:
        inchain = True
    if pc == lab['T_SND_FRAME']:
        if inchain:
            done += 1
        inchain = False
    if inchain and pc in fn:
        calls[fn[pc]] += 1
    c0 = cpu.processorCycles
    cpu.step()
    if inchain:
        c[where(bl, pc, a.mems) if 0xC300 <= pc < 0xF000 else f'game {pc >> 8:02X}'] += cpu.processorCycles - c0
print('calls per chain', {k: v / n for k, v in calls.items()})
print('total', sum(c.values()) // n)
for k, v in c.most_common(25):
    print(f'{k:16} {v // n:7}')
