#!/usr/bin/env python3
"""Compare the Atari build with the arcade reference, game tick by game tick.

Both run the same input script (IN0 bits per tick). A tick starts when the
arcade code waits for the vertical blank ($0080 on the arcade, rt_frame on
the Atari). After every tick the 4 KB arcade RAM (both banks) is compared,
except the arcade stack ($4BC0-$4BFF), which the 6502 does not use.

usage: lockstep.py TICKS [--seed N] [--players 2] [--skip N] [--every N]
"""
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from arcade import Board, COIN, START1, START2, FIRE, LEFT, RIGHT, SHIELD  # noqa: E402
from atari_emu import load_labels  # noqa: E402
from run_emu import make  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
IGNORE = set(range(0xBC0, 0xC00))
from patches import CODE_PUSH  # noqa: E402
CODE_TARGETS = {t for ts, _ in CODE_PUSH.values() for t in ts}


class StackClobbered(RuntimeError):
    pass


def script(seed, players):
    rng = random.Random(seed)
    st = {"m": 0, "until": 0}

    def f(t):
        if t in range(200, 204) or t in range(210, 214):
            return COIN
        if 300 <= t < 304:
            return START2 if players == 2 else START1
        if t < 320:
            return 0
        if t >= st["until"]:
            m = FIRE if rng.random() < 0.5 else 0
            r = rng.random()
            m |= LEFT if r < 0.4 else RIGHT if r < 0.8 else 0
            if rng.random() < 0.05:
                m |= SHIELD
            st["m"], st["until"] = m, t + rng.randint(2, 30)
        m = st["m"]
        if t % 3 == 0:
            m &= ~FIRE
        return m
    return f


class RefTicks:
    """The arcade board, stepped one tick (one call of $0080) at a time."""

    def __init__(self):
        self.b = Board()
        self.cpu = self.b.cpu
        self.ticks = 0
        # boot until the first wait
        while self.cpu.pc != 0x0080:
            self.cpu.step()

    def valid_return(self, t):
        """t follows a CALL/RST, or is a pushed code address (threaded code)."""
        rom = self.b.rom
        if t in CODE_TARGETS:
            return True
        if t >= 3 and (rom[t - 3] == 0xCD or rom[t - 3] & 0xC7 == 0xC4):
            return True
        return t >= 1 and rom[t - 1] & 0xC7 == 0xC7

    def tick(self, inputs):
        self.b.inputs = inputs
        cpu = self.cpu
        # skip the vblank wait itself (0080-008D) and run to the next one
        cpu.pc = 0x008E
        n = 0
        while cpu.pc != 0x0080:
            op = self.b.rom[cpu.pc] if cpu.pc < 0x4000 else 0
            if op == 0xC9 or (op & 0xC7 == 0xC0 and cpu.cond((op >> 3) & 7)):
                t = self.b.read(cpu.sp) | (self.b.read(cpu.sp + 1) << 8)
                if not self.valid_return(t) and cpu.pc not in (0x0EE5,):
                    raise StackClobbered(f"reference: RET at {cpu.pc:04X} to {t:04X}, "
                                         "its stack in RAM was overwritten")
            cpu.step()
            n += 1
            if n > 2_000_000:
                raise RuntimeError("reference: no wait")
        self.ticks += 1

    def ram(self, bank):
        return self.b.banks[bank]


class AtariTicks:
    def __init__(self, pal=True):
        self.a = make(pal=pal, xex=ROOT / "gen" / "phoenix-arcade.xex")
        lab = load_labels(ROOT / "gen" / "phoenix-arcade.lab")
        self.rt_frame = lab["RF_C"]       # rt_frame, after its wait
        self.rt_in0 = lab["RT_IN0"]
        self.read_input = lab["READ_INPUT"]
        self.cur_bank = 0xA1
        a = self.a
        self.cpu = a.cpu
        self.vram_b1 = 0x48000
        self.run_to_frame()
        # after the loader has copied the runtime into place:
        a.mem.ram[self.read_input] = 0x60       # RTS: inputs come from the script

    def run_to_frame(self):
        """Run until the CPU enters rt_frame (the start of the arcade's wait)."""
        a = self.a
        cpu = a.cpu
        start = a.frame
        while True:
            if a.frame - start > 100:
                raise RuntimeError(f"atari: no game tick for 100 frames (pc ${cpu.pc:04x})")
            # run in small slices so we stop right at rt_frame
            target = a.next_frame
            while cpu.processorCycles < target:
                if cpu.pc == self.rt_frame:
                    return
                cpu.step()
            a.next_frame += a.frame_cycles
            a.vblank()

    def tick(self, inputs):
        a = self.a
        a.mem.ram[0xB1] = inputs
        cpu = a.cpu
        cpu.step()                      # leave rt_frame's first instruction
        self.run_to_frame()

    def ram(self, bank):
        a = self.a
        if a.mem.ram[self.cur_bank] == bank:
            return a.mem.ram[0x4000:0x5000]
        return bytes(a.vram[self.vram_b1:self.vram_b1 + 0x1000])


def stage_skip(rd, wr):
    if rd(0x3A4) != 3:          # only while playing: elsewhere the cheat can crash the game
        return
    st = rd(0x3B8) & 0x0F
    if st in (1, 3):
        wr(0x3BA, 1)
    elif st in (5, 7):
        wr(0x3BB, 1)
    elif st >= 9:
        wr(0x3A4, 6)


def ref_poke(ref):
    ram = ref.b.banks[ref.b.bank]

    def f():
        stage_skip(lambda o: ram[o], lambda o, v: ram.__setitem__(o, v))
    return f


def atr_poke(atr):
    ram = atr.a.mem.ram

    def f():
        stage_skip(lambda o: ram[0x4000 + o], lambda o, v: ram.__setitem__(0x4000 + o, v))
    return f


def main():
    ticks = int(sys.argv[1]) if len(sys.argv) > 1 else 1000
    seed = int(sys.argv[sys.argv.index("--seed") + 1]) if "--seed" in sys.argv else 1
    players = 2 if "--players" in sys.argv else 1
    inp = script(seed, players)
    ref = RefTicks()
    atr = AtariTicks(pal="--ntsc" not in sys.argv)
    if "--invincible" in sys.argv:
        # the player cannot be hit: $0CC4 returns at once on both machines
        def inv(c):
            c.pc = c.pop()
            c.cycles += 10
            return True
        ref.cpu.hook[0x0CC4] = inv
        lab = load_labels(ROOT / "gen" / "phoenix-arcade.lab")
        atr.a.mem.ram[lab["Z_0CC4"]] = 0x60
    skip = int(sys.argv[sys.argv.index("--skip") + 1]) if "--skip" in sys.argv else 0
    replay = None
    if "--replay" in sys.argv:
        import json
        replay = json.loads(Path(sys.argv[sys.argv.index("--replay") + 1]).read_text())
        ticks = min(ticks, len(replay) - 1)
    for t in range(ticks):
        m = inp(t)
        if replay:
            # recorded on the Atari: entry k is the input of tick k-1 and a poke made before it
            m, poke = replay[t + 1]
            if poke:
                ref.b.banks[ref.b.bank][poke[0]] = poke[1]
                atr.a.mem.ram[0x4000 + poke[0]] = poke[1]
        if skip and t > 400 and t % skip == 0:
            # end the stage early in both machines (MAME's level-skip cheat)
            for poke in (ref_poke(ref), atr_poke(atr)):
                poke()
        try:
            ref.tick(m)
        except RuntimeError as e:
            if "bad opcode" not in str(e) and not isinstance(e, StackClobbered):
                raise
            print(f"tick {t}: the reference arcade crashed ({e}); stopping")
            print(f"{t} ticks identical")
            return 0
        except StackClobbered as e:
            print(f"tick {t}: {e}; stopping (the 6502 stack is not in the arcade RAM)")
            print(f"{t} ticks identical")
            return 0
        atr.tick(m)
        for bank in (0, 1):
            r, x = ref.ram(bank), atr.ram(bank)
            diff = [i for i in range(0x1000) if r[i] != x[i] and i not in IGNORE]
            if diff:
                print(f"tick {t}: bank {bank}: {len(diff)} bytes differ")
                for i in diff[:24]:
                    print(f"  ${0x4000 + i:04X}: arcade {r[i]:02X} atari {x[i]:02X}")
                return 1
        if t % 500 == 0:
            print(f"tick {t} ok, stage {ref.ram(ref.b.bank)[0x3B8]:02X}")
    print(f"{ticks} ticks identical")
    return 0


if __name__ == "__main__":
    sys.exit(main())
