#!/usr/bin/env python3
"""Find the first 8080 instruction where the Atari build and the reference differ.

Runs tools/lockstep.py's two machines to the start of tick T, then follows
the Atari CPU from one translated instruction label (z_XXXX) to the next,
stepping the reference to the same 8080 address each time, and compares the
8080 registers B-L and the arcade RAM after every instruction.

usage: finestep.py TICK [--seed N] [--players 2] [--skip N]
"""
import collections
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import lockstep as LS  # noqa: E402
from atari_emu import load_labels  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent


def main():
    tick = int(sys.argv[1])
    seed = int(sys.argv[sys.argv.index("--seed") + 1]) if "--seed" in sys.argv else 1
    players = 2 if "--players" in sys.argv else 1
    skip = int(sys.argv[sys.argv.index("--skip") + 1]) if "--skip" in sys.argv else 0
    inp = LS.script(seed, players)
    ref = LS.RefTicks()
    atr = LS.AtariTicks()
    for t in range(tick):
        m = inp(t)
        if skip and t > 400 and t % skip == 0:
            LS.ref_poke(ref)()
            LS.atr_poke(atr)()
        ref.tick(m)
        atr.tick(m)
    print(f"at tick {tick}")
    m = inp(tick)
    if skip and tick > 400 and tick % skip == 0:
        LS.ref_poke(ref)()
        LS.atr_poke(atr)()
    lab = load_labels(ROOT / "gen" / "phoenix-arcade.lab")
    z = {}
    for k, v in lab.items():
        if k.startswith("Z_"):
            z.setdefault(v, set()).add(int(k[2:], 16))
    a = atr.a
    a.mem.ram[0xB1] = m
    ref.b.inputs = m
    cpu = a.cpu
    rcpu = ref.cpu
    rcpu.pc = 0x008E
    ram = a.mem.ram
    hist = collections.deque(maxlen=30)
    started = False
    for n in range(3_000_000):
        pc = cpu.pc
        if pc in z and 0x008E in z[pc]:
            started = True
        if started and pc in z:
            zset = z[pc]
            k = 0
            while rcpu.pc not in zset:
                hist.append(f"    ref {rcpu.pc:04X}")
                rcpu.step()
                k += 1
                if k > 20:
                    print("reference did not reach", [hex(x) for x in zset], "atari pc", hex(pc),
                          "stack", [hex(ram[0x100 + j]) for j in range(cpu.sp + 1, 256)])
                    for h in hist:
                        print(h)
                    return
            zpc = rcpu.pc
            # compare state at the start of 8080 instruction zpc
            r = rcpu.r
            regs = {"B": (r[0], ram[0x85]), "C": (r[1], ram[0x84]), "D": (r[2], ram[0x83]),
                    "E": (r[3], ram[0x82]), "H": (r[4], ram[0x81]), "L": (r[5], ram[0x80])}
            bad = [f"{k}: arcade {v[0]:02X} atari {v[1]:02X}" for k, v in regs.items() if v[0] != v[1]]
            bank = ref.b.bank
            rr = ref.ram(bank)
            xr = atr.ram(bank)
            if bytes(rr[:0xBC0]) != bytes(xr[:0xBC0]):
                diff = [i for i in range(0xBC0) if rr[i] != xr[i]]
                bad.append("RAM " + " ".join(f"${0x4000 + i:04X}:{rr[i]:02X}/{xr[i]:02X}" for i in diff[:8]))
            if bad:
                print(f"before {zpc:04X}: " + "; ".join(bad))
                for h in hist:
                    print(h)
                return
            hist.append(f"{zpc:04X} A={rcpu.r[7]:02X}/{cpu.a:02X} HL={r[4]:02X}{r[5]:02X} "
                        f"Z={rcpu.f_z} C={rcpu.f_c}")
            if zpc == 0x0080 and n > 10:
                print("tick finished without a difference")
                return
        a_step(a)
    print("no end")


def a_step(a):
    cpu = a.cpu
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
    cpu.step()


if __name__ == "__main__":
    main()
