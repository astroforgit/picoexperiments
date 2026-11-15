#!/usr/bin/env python3
"""bankvars.py SNAP NAME[:N] ...: bank R variables of a model snapshot."""
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_emu import load_labels  # noqa: E402
from atari_snap import load_snap  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1])
for item in sys.argv[2:]:
    name, _, n = item.partition(':')
    n = int(n or 1)
    addr = lab[name.upper()]
    if addr >= 0xE000:
        data = a.vram[0x7C000 + addr - 0xE000:0x7C000 + addr - 0xE000 + n]
    else:
        data = a.mem.ram[addr:addr + n]
    print(f'{name:10} ' + ' '.join(f'{int(x):02x}' for x in data))
