#!/usr/bin/env python3
"""Cycle profile by routine (runtime labels; game code by 8080 routine)."""
import bisect
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from atari_emu import load_labels  # noqa: E402
from run_emu import make  # noqa: E402
from profile import joy_script  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent


def main():
    start = int(sys.argv[1]) if len(sys.argv) > 1 else 900
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 200
    a = make(pal="--ntsc" not in sys.argv)
    inp = joy_script()
    for _ in range(start):
        a.set_input(**inp(a.frame))
        a.run_frames(1)
    lab = load_labels(ROOT / "gen" / "runtime.lab")
    # routine starts: runtime labels without '_' locals, and 8080 routines (z_xxxx that are call targets)
    names = sorted((v, k) for k, v in lab.items() if not k.startswith(("_T", "Z_")))
    zs = sorted((v, k) for k, v in lab.items() if k.startswith("Z_"))
    addrs = [x for x, _ in names]
    cpu = a.cpu
    prof = Counter()
    orig = cpu.step

    def step():
        pc = cpu.pc
        c0 = cpu.processorCycles
        orig()
        d = cpu.processorCycles - c0
        if 0x6000 <= pc < 0xD000:
            prof["game code"] += d
        else:
            i = bisect.bisect_right(addrs, pc) - 1
            prof[names[i][1] if i >= 0 else "?"] += d
    cpu.step = step
    for _ in range(n):
        a.set_input(**inp(a.frame))
        a.run_frames(1)
    tot = n * a.frame_cycles
    for k, v in prof.most_common(30):
        print(f"{k:16s} {v / n:8.0f} cycles/frame {100 * v / tot:5.1f}%")


if __name__ == "__main__":
    main()
