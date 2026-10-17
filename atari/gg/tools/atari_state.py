#!/usr/bin/env python3
"""Run gng.xex N frames in the Atari model and print runtime variables:
atari_state.py N [name ...]"""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import Atari, load_labels  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = Atari(os.path.join(HERE, 'gng.xex'))
a.boot()
n = int(sys.argv[1])
names = [x.upper() for x in sys.argv[2:]] or ['VFRAME', 'TICKS', 'DROPS', 'NMI_BUSY', 'PENDING', 'UPD_N', 'NREGION', 'NINST']
for f in range(0, n, max(1, n // 5)):
    a.run_frames(max(1, n // 5))
    print(f'frame {a.frame:4} pc ${a.cpu.pc:04X} blits {a.blits:5} nmi {a.nmi_count}',
          ' '.join(f'{k.lower()}={a.mem.ram[lab[k]]}' for k in names), flush=True)
