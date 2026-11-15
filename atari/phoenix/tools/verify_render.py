#!/usr/bin/env python3
"""Compare every composed Atari frame with the reference renderer.

At each call of compose the arcade RAM, scroll and palette are captured;
when the blitter has finished, the back framebuffer is compared pixel by
pixel (as RGB through the VBXE palette) with tools/render.py's picture of the
captured state, cut to the rows the Atari shows (0-2 and 4-30).

usage: verify_render.py FRAMES [--every N] [--ntsc] [--skip N]
"""
import sys
from pathlib import Path
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
from atari_emu import load_labels  # noqa: E402
from run_emu import make  # noqa: E402
from profile import joy_script  # noqa: E402
import render  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
ROWS = list(range(0, 3)) + list(range(4, 31))


def expected(ram, scroll, pal):
    img = render.render(ram, pal << 1, scroll)
    return np.concatenate([img[r * 8:r * 8 + 8] for r in ROWS])


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 600
    every = int(sys.argv[sys.argv.index("--every") + 1]) if "--every" in sys.argv else 10
    skip = int(sys.argv[sys.argv.index("--skip") + 1]) if "--skip" in sys.argv else 0
    a = make(pal="--ntsc" not in sys.argv)
    lab = load_labels(ROOT / "gen" / "runtime.lab")
    comp = lab["COMPOSE"]
    cpu = a.cpu
    ram = a.mem.ram
    snap = {}
    orig = cpu.step

    def step():
        if cpu.pc == comp and "want" in snap:
            snap.pop("want")
            snap["ram"] = bytes(ram[0x4000:0x5000])
            snap["scroll"] = ram[0xA3]
            snap["pal"] = ram[0xA2]
            snap["back"] = ram[0xA7]
            snap["at"] = a.frame
        return orig()
    cpu.step = step
    inp = joy_script()
    if "--invincible" in sys.argv:
        a.run_frames(30)                     # the runtime is in place
        a.mem.ram[load_labels(ROOT / "gen" / "phoenix.lab")["Z_0CC4"]] = 0x60
    bad = 0
    checked = 0
    out = ROOT / "shots" / "verify"
    out.mkdir(parents=True, exist_ok=True)
    while a.frame < frames:
        a.set_input(**inp(a.frame))
        if skip and a.frame > 400 and a.frame % skip == 0 and ram[0x43A4] == 3:
            st = ram[0x43B8] & 15
            if st in (1, 3):
                ram[0x43BA] = 1
            elif st in (5, 7):
                ram[0x43BB] = 1
            elif st >= 9:
                ram[0x43A4] = 6
        if a.frame % every == 0 and "ram" not in snap:
            snap["want"] = 1
        a.run_frames(1)
        if a.frame % 250 == 0:
            print(f"frame {a.frame}: stage {ram[0x43B8]:02X} state {ram[0x43A4]:02X} "
                  f"play {ram[0x43A2]} pc ${cpu.pc:04x}, {checked} checked", flush=True)
        if "ram" in snap and a.frame > snap["at"]:
            while cpu.processorCycles < a.blit_busy_until:
                cpu.step()
            s = snap
            snap = {}
            exp = expected(s["ram"], s["scroll"], s["pal"])
            fb = 0x20000 + s["back"] * 0x10000
            pix = a.vram[fb:fb + 256 * 240].reshape(240, 256)[:, 24:232]
            got = a.palette[1][pix]
            got[pix == 0] = 0
            diff = np.any(got != exp, axis=2)
            checked += 1
            if diff.any():
                bad += 1
                ys, xs = np.nonzero(diff)
                print(f"frame {s['at']}: {diff.sum()} pixels differ, first at x={xs[0]} y={ys[0]} "
                      f"(rows {sorted(set(int(y) // 8 for y in ys))[:8]})")
                if bad <= 5:
                    from PIL import Image
                    both = np.concatenate([exp, got, (diff[:, :, None] * 255).repeat(3, 2).astype(np.uint8)], axis=1)
                    Image.fromarray(both).resize((both.shape[1] * 2, both.shape[0] * 2)).save(out / f"diff_{s['at']:05d}.png")
    print(f"{checked} frames checked, {bad} differ")


if __name__ == "__main__":
    main()
