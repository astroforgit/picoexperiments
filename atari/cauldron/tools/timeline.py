#!/usr/bin/env python3
"""timeline.py SNAP FRAMES: when pictures start, finish and are shown."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import load_labels  # noqa: E402
from atari_snap import load_snap  # noqa: E402
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1])
ev = {lab['RENDER']: 'render', lab['CS_DONE']: 'done', lab['C64_FRAME']: 'c64', lab['VX_0']: 'flip',
      lab['CHAIN_STEP']: 'step', lab['IQ_D']: 'irq-end'}
for n in ('REGIONS','ROW_CHARSETS','CHARSET_UPDATE','BAND_SHIFT','SITE_ROWS','DIFF_ROWS','PALETTES','SPRITE_PREP','PUT_UPDATES','PUT_REGIONS','PUT_RUNS','PUT_XDL','RN_C'):
    ev[lab[n]] = n.lower()
cpu = a.cpu
end = a.frame + int(sys.argv[2])
while a.frame < end:
    pc = cpu.pc
    if pc in ev:
        fs = a.next_frame - a.frame_cycles
        print(f'{a.frame:5} {cpu.processorCycles - fs:6} {ev[pc]}' +
              (f' busy-until {a.blit_busy_until - fs}' if ev[pc] in ('step', 'done') else ''))
    a.run_until(cpu.processorCycles + 1)
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
