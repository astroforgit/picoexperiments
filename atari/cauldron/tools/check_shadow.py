#!/usr/bin/env python3
"""check_shadow.py SNAP [PICTURES]: after each picture's diff, rows whose
shadow (ring-mapped) differs from screen/colour RAM while not marked dirty."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap  # noqa: E402
from atari_emu import load_labels  # noqa: E402
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
a = load_snap(sys.argv[1]); cpu = a.cpu
n = int(sys.argv[2]) if len(sys.argv) > 2 else 10
B = 0x7C000 - 0xE000
target = lab['PALETTES']                    # (right after diff_rows)
done = 0
while done < n:
    if cpu.pc == target and a.mems == 0xFC:
        done += 1
        ram = a.mem.ram
        bad = []
        for r in range(25):
            off = int(a.vram[B + lab['ROWOFF'] + r])
            if ram[lab['ROWD'] + r] or ram[lab['EDGE'] + r]:
                continue
            for c in range(40):
                p = (c + off) % 40
                s = int(a.vram[B + 0xF570 + r * 40 + p]); k = int(a.vram[B + 0xF958 + r * 40 + p])
                if s != ram[0x4000 + r * 40 + c] or k != ram[0xD800 + r * 40 + c]:
                    bad.append((r, c))
        print(a.frame, 'stale cells:', len(bad), bad[:8])
    a.run_until(cpu.processorCycles + 1)
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles; a.vblank()
