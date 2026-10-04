import sys
from pathlib import Path
from atari_emu import Atari, load_labels
for pal in (True, False):
    a = Atari(Path('../double-dragon.xex'), pal=pal)
    a.boot()
    lab = load_labels(Path('../gen/runtime.lab'))
    count = [0]
    cpu = a.cpu
    nes_nmi = 0xFF16
    def ru(t):
        while cpu.processorCycles < t:
            if cpu.pc == nes_nmi: count[0] += 1
            cpu.step()
    a.run_until = ru
    a.run_frames(300)
    c0 = count[0]
    a.run_frames(250)
    print('PAL' if pal else 'NTSC', 'game NMIs in 250 frames:', count[0] - c0, 'DLIs', a.dli_count, 'drops', a.mem.ram[lab['DROPS']], 'per second', (count[0]-c0) * (50 if pal else 60) / 250)
