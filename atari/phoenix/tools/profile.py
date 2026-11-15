#!/usr/bin/env python3
"""Game ticks per second and frame busy time in the headless model.

Plays with the joystick (fire inserts a coin and starts, then random moves)
and reports, per block of frames, the game ticks counted by the arcade's own
counter ($439A/$439B) and how many cycles the CPU spends before waiting for
the vertical blank.

usage: profile.py FRAMES [--ntsc] [--skip N] [--shots]
"""
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from atari_emu import load_labels  # noqa: E402
from run_emu import make  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent


def joy_script(seed=7):
    rng = random.Random(seed)
    st = {"until": 0, "stick": 15, "trig": 0}

    def f(frame):
        if frame in range(150, 156) or frame in range(170, 176):
            return dict(trig=1)
        if frame < 250:
            return dict()
        if frame >= st["until"]:
            r = rng.random()
            st["stick"] = 11 if r < 0.4 else 7 if r < 0.8 else 15   # left / right / none
            if rng.random() < 0.04:
                st["stick"] &= ~2                                   # down: shield
            st["trig"] = 1 if rng.random() < 0.6 else 0
            st["until"] = frame + rng.randint(3, 30)
        trig = st["trig"] if frame % 4 else 0
        return dict(stick=st["stick"], trig=trig)
    return f


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 1500
    pal = "--ntsc" not in sys.argv
    skip = int(sys.argv[sys.argv.index("--skip") + 1]) if "--skip" in sys.argv else 0
    a = make(pal=pal)
    lab = load_labels(ROOT / "gen" / "runtime.lab")
    w0, w1 = lab["RT_FRAME"], lab["RF_OK"]
    n0 = lab["NOW"]
    cpu = a.cpu
    inp = joy_script()
    wait = [0]
    orig = cpu.step

    def step():
        pc = cpu.pc
        if w0 <= pc < w1 or n0 <= pc < n0 + 40:
            c = cpu.processorCycles
            orig()
            wait[0] += cpu.processorCycles - c
            return
        return orig()
    cpu.step = step
    ram = a.mem.ram
    last = None
    block = 100
    out = ROOT / "shots" / "prof"
    out.mkdir(parents=True, exist_ok=True)
    for f0 in range(0, frames, block):
        idle0 = wait[0]
        c0 = ram[0x439A] << 8 | ram[0x439B]
        for f in range(block):
            a.set_input(**inp(a.frame))
            if skip and a.frame > 400 and a.frame % skip == 0:
                st = ram[0x43B8] & 15
                if ram[0x43A4] != 3:
                    pass
                elif st in (1, 3):
                    ram[0x43BA] = 0
                elif st in (5, 7):
                    ram[0x43BB] = 0
                elif st >= 9:
                    ram[0x43A4] = 6
            a.run_frames(1)
        c1 = ram[0x439A] << 8 | ram[0x439B]
        idle = wait[0] - idle0             # cycles spent waiting for the tick
        busy = 1 - idle / (block * a.frame_cycles)
        print(f"frames {a.frame - block:5d}-{a.frame:5d}: ticks {(c1 - c0) & 0xFFFF:4d} "
              f"(expect {block * 6 // 5 if pal else block}), busy {busy * 100:5.1f}%, "
              f"stage {ram[0x43B8]:02X} state {ram[0x43A4]:02X} play {ram[0x43A2]}")
        if "--shots" in sys.argv:
            a.screenshot(out / f"f{a.frame:05d}.png")


if __name__ == "__main__":
    main()
