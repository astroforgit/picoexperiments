#!/usr/bin/env python3
"""speed.py SNAP [FRAMES] [INPUTS]: C64 frames run, pictures shown and main loop time per Atari frame."""
import os
import sys
from collections import Counter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import load_labels  # noqa: E402
from atari_snap import load_snap, parse_inputs  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1])
n = int(sys.argv[2]) if len(sys.argv) > 2 else 50
inp = parse_inputs(sys.argv[3]) if len(sys.argv) > 3 else None
cf, rd, nw = lab['C64_FRAME'], lab['RENDER'], lab['NMI_WORK']
cnt = Counter()
where = Counter()
cpu = a.cpu
busy = lab['IRQ_BUSY']
end = a.frame + n
shown0 = 0
last_ready = None
while a.frame < end:
    if inp:
        a.set_input(**inp(a.frame))
    f = a.frame
    while a.frame == f:
        pc = cpu.pc
        if pc == cf:
            cnt['c64'] += 1
        elif pc == rd and a.mems == 0xFC:
            cnt['render'] += 1
        c0 = cpu.processorCycles
        if a.mem.ram[busy]:
            k = 'irq-game' if 0x8000 <= pc < 0xAA30 else ('irq-bank' if pc >= 0xE000 else 'irq-A')
        elif pc >= 0xE000 and a.mems & 0x80:
            k = 'nmi'
        else:
            k = 'main'
        a.run_until(c0 + 1)
        where[k] += cpu.processorCycles - c0
        if cpu.processorCycles >= a.next_frame:
            a.next_frame += a.frame_cycles
            a.vblank()
tot = sum(where.values())
fine = Counter()
print(f'{n} frames: C64 frames {cnt["c64"]}, pictures {cnt["render"]}; cycles: ' +
      ', '.join(f'{k} {100 * v / tot:.0f}%' for k, v in where.items()))
