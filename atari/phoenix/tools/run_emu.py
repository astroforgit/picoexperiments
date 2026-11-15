#!/usr/bin/env python3
"""Run phoenix.xex in the headless model and save screenshots.

usage: run_emu.py FRAMES [--shots N] [--ntsc]
"""
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from atari_emu import Atari, load_labels  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent


def make(pal=True, xex=None):
    a = Atari(xex or ROOT / "phoenix.xex", pal=pal)
    a.boot()
    return a


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    every = 50
    if "--shots" in sys.argv:
        every = int(sys.argv[sys.argv.index("--shots") + 1])
    a = make(pal="--ntsc" not in sys.argv)
    out = ROOT / "shots" / "emu"
    out.mkdir(parents=True, exist_ok=True)
    t = time.time()
    lab = load_labels(ROOT / "gen" / "runtime.lab")
    for f in range(0, frames, every):
        a.run_frames(every)
        a.screenshot(out / f"f{a.frame:05d}.png")
        print(f"frame {a.frame} pc ${a.cpu.pc:04x} blits {a.blits} ({time.time() - t:.0f}s)")
    return a


if __name__ == "__main__":
    main()
