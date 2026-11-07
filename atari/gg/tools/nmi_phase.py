#!/usr/bin/env python3
"""NMI time per phase from a snapshot: nmi_phase.py SNAP [NMIS]"""
import collections
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap  # noqa: E402
from atari_emu import load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1])
n = int(sys.argv[2]) if len(sys.argv) > 2 else 6
cpu, r = a.cpu, a.mem.ram
marks = {lab['T_READ_INPUT']: 'input', lab['RUN_CHAIN']: 'chain', lab['T_SND_FRAME']: 'sound',
         lab['NMI_DISPLAY']: 'display', lab['VW_IDLE']: 'idle', lab['RASTER_SYNC']: 'rsync',
         lab['NMI_OUT']: 'exit'}
done = 0
phase = None
c = collections.Counter()
rows = []
depth = 0
while done < n:
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
    pc = cpu.pc
    if pc == lab['NMI'] and not depth and not r[lab['NMI_BUSY']]:
        depth = 1
        phase = 'entry'
        c = collections.Counter()

    if depth and pc in marks:
        phase = marks[pc]
    c0 = cpu.processorCycles
    cpu.step()
    if depth:
        c[phase] += cpu.processorCycles - c0
        if pc == lab['NMI_OUT'] + 5 and not r[lab['NMI_BUSY']]:
            depth = 0
            done += 1
            print(f'{sum(c.values()):6}', dict(c), 'regions/splits', (r[lab['NREGION']], r[lab['NSPLIT']]))
