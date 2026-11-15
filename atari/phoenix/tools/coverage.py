"""Run the arcade reference through all stages and record what the code does.

Writes gen/trace.json with:
  pcs        every executed instruction address
  rom_reads  pc -> [lowest, highest] ROM address read as data at that pc
  io         "pc kind" -> count (kind r7/rF = IN0/DSW reads, wA/wB/wC/wD/... writes)
  low_writes pc -> count of writes below 0x4000 (ignored by the arcade board)
  jp_hl      pc of JP (HL) -> list of targets
  busy       cycles per frame before the first vblank wait
"""
import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from arcade import Board, COIN, START1, START2, FIRE, LEFT, RIGHT, SHIELD  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent


class TraceBoard(Board):
    def __init__(self, **kw):
        super().__init__(trace=True, **kw)
        self.low_writes = {}
        self.jp_hl = {}
        self.rom_rng = {}

    def read(self, a):
        if a < 0x4000 and not (self.ipc <= a < self.ipc + 3):
            pc = self.ipc
            r = self.rom_rng.get(pc)
            self.rom_rng[pc] = [a, a] if r is None else [min(r[0], a), max(r[1], a)]
            return self.rom[a]
        return super().read(a)

    def write(self, a, v):
        if a < 0x4000:
            self.low_writes[self.ipc] = self.low_writes.get(self.ipc, 0) + 1
        super().write(a, v)


def run(seed, frames, players=1, skip_every=0, invincible=True, cocktail=False, extra=None):
    b = TraceBoard()
    rng = random.Random(seed)
    cpu = b.cpu

    def jp_hook(c):
        t = c.hl()
        b.jp_hl.setdefault(c.pc, set()).add(t)
        return False

    for pc in (0x040D, 0x0734, 0x0758, 0x080F, 0x0EE5):
        cpu.hook[pc] = jp_hook

    if invincible:
        def inv(c):
            c.pc = c.pop()
            c.cycles += 10
            return True
        cpu.hook[0x0CC4] = inv

    state = {"held": 0, "until": 0}

    def inp(f):
        if f in range(200, 204) or f in range(210, 214):
            return COIN
        if 300 <= f < 304:
            return START2 if players == 2 else START1
        if f < 320:
            return 0
        if f >= state["until"]:
            m = 0
            if rng.random() < 0.5:
                m |= FIRE
            r = rng.random()
            m |= LEFT if r < 0.4 else RIGHT if r < 0.8 else 0
            if rng.random() < 0.05:
                m |= SHIELD
            state["held"] = m
            state["until"] = f + rng.randint(2, 30)
        m = state["held"]
        if f % 3 == 0:
            m &= ~FIRE
        if (f % 4000) in range(3000, 3004) and not invincible:
            m |= COIN
        return m

    def on_frame(bd):
        if skip_every and bd.frame % skip_every == 0 and bd.frame > 400:
            ram = bd.banks[bd.bank]
            st = ram[0x3B8] & 0x0F
            if st in (1, 3):
                ram[0x3BA] = 0
            elif st in (5, 7):
                ram[0x3BB] = 0
            elif st >= 9 and ram[0x3A4] == 3:
                ram[0x3A4] = 6
        if extra:
            extra(bd)
    b.on_frame = on_frame
    b.run_frames(frames, inp)
    return b


def main():
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 6000
    runs = [
        dict(seed=1, frames=frames, skip_every=900),
        dict(seed=2, frames=frames, players=2, skip_every=700, invincible=False),
        dict(seed=3, frames=frames, invincible=False),
        dict(seed=4, frames=frames, skip_every=1300),
    ]
    pcs, rom, io, low, jp = set(), {}, {}, {}, {}
    busy = []
    for cfg in runs:
        b = run(**cfg)
        pcs |= b.pcs
        for pc, (lo, hi) in b.rom_rng.items():
            if pc in rom:
                rom[pc] = [min(rom[pc][0], lo), max(rom[pc][1], hi)]
            else:
                rom[pc] = [lo, hi]
        for k, v in b.io.items():
            key = "%04X %s" % k
            io[key] = io.get(key, 0) + v
        for k, v in b.low_writes.items():
            low[k] = low.get(k, 0) + v
        for k, v in b.jp_hl.items():
            jp.setdefault(k, set()).update(v)
        busy += [x for x in b.busy if x is not None]
        print(cfg, "pcs", len(b.pcs), "stage", hex(b.banks[b.bank][0x3B8]), "score",
              bytes(b.banks[b.bank][0x384:0x388]).hex())
    out = {
        "pcs": sorted(pcs),
        "rom_reads": {"%04X" % k: v for k, v in sorted(rom.items())},
        "io": io,
        "low_writes": {"%04X" % k: v for k, v in sorted(low.items())},
        "jp_hl": {"%04X" % k: sorted(v) for k, v in sorted(jp.items())},
        "busy_max": max(busy),
        "busy_avg": sum(busy) // len(busy),
    }
    (ROOT / "gen" / "trace.json").write_text(json.dumps(out, indent=1))
    print("pcs", len(pcs), "busy max", max(busy), "avg", out["busy_avg"])


if __name__ == "__main__":
    main()
