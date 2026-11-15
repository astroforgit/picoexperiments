"""Reference model of the Phoenix arcade board (CPU + memory map + video RAM).

Used to get ground truth for the 6502 translation: which ROM bytes are read
as data, where the I/O registers are accessed, the CPU time per frame, and the
RAM contents after every frame for comparison with the Atari build.

Memory map (from the Amiga port's notes and MAME):
  0000-3FFF ROM
  4000-4FFF RAM, two banks (bit 0 of the 50xx register)
  50xx video register (bit 0 RAM bank, bit 1 palette)
  58xx background scroll
  60xx / 68xx sound A / B
  70xx IN0 (bit 0 coin, 1 start1, 2 start2, 4-7 fire/right/left/shield, active low)
  78xx DSW0 (bit 7 = 0 during vertical blank)
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from i8080 import CPU  # noqa: E402
from rom import load_rom  # noqa: E402

FRAME_CYCLES = 2750000 // 60      # 8085 at 2.75 MHz, 60 Hz
VBLANK_CYCLES = FRAME_CYCLES * 32 // 262

# IN0 bits (active low)
COIN, START1, START2, FIRE, RIGHT, LEFT, SHIELD = 0x01, 0x02, 0x04, 0x10, 0x20, 0x40, 0x80


class Board:
    def __init__(self, dsw=0x60, trace=False):
        self.rom = load_rom()
        self.banks = [bytearray(0x1000), bytearray(0x1000)]
        self.bank = 0
        self.video = 0
        self.scroll = 0
        self.sound = [0, 0]
        self.dsw = dsw
        self.inputs = 0           # active-high mask of pressed IN0 bits
        self.cpu = CPU(self)
        self.trace = trace
        self.rom_reads = {}       # addr -> set of pcs
        self.io = {}              # (pc, kind) -> count
        self.pcs = set()
        self.frame = 0
        self.frame_start = 0
        self.busy = []            # cycles used per frame before waiting for vblank
        self.on_frame = None
        self.cpu.pc = 0
        self.ipc = 0

    # memory interface ---------------------------------------------------
    def read(self, a):
        if a < 0x4000:
            if self.trace:
                self.rom_reads.setdefault(a, set()).add(self.ipc)
            return self.rom[a]
        if a < 0x5000:
            return self.banks[self.bank][a - 0x4000]
        if self.trace:
            self.io[(self.ipc, "r%X" % (a >> 11))] = self.io.get((self.ipc, "r%X" % (a >> 11)), 0) + 1
        if 0x7000 <= a < 0x7800:
            return (~self.inputs) & 0xFF
        if 0x7800 <= a < 0x8000:
            in_frame = self.cpu.cycles - self.frame_start
            vb = 0 if in_frame >= FRAME_CYCLES - VBLANK_CYCLES else 0x80
            return (self.dsw & 0x7F) | vb
        return 0xFF

    def write(self, a, v):
        if 0x4000 <= a < 0x5000:
            self.banks[self.bank][a - 0x4000] = v
            return
        if a < 0x4000:
            return
        if self.trace:
            k = (self.ipc, "w%X" % (a >> 11))
            self.io[k] = self.io.get(k, 0) + 1
        if 0x5000 <= a < 0x5800:
            self.video = v
            self.bank = v & 1
        elif 0x5800 <= a < 0x6000:
            self.scroll = v
        elif 0x6000 <= a < 0x6800:
            self.sound[0] = v
        elif 0x6800 <= a < 0x7000:
            self.sound[1] = v

    # running --------------------------------------------------------------
    def run_frames(self, n, inputs=None):
        """Run n frames. inputs: callable(frame) -> IN0 pressed mask."""
        cpu = self.cpu
        for _ in range(n):
            if inputs:
                self.inputs = inputs(self.frame)
            end = self.frame_start + FRAME_CYCLES
            first_wait = None
            while cpu.cycles < end:
                if self.trace:
                    self.pcs.add(cpu.pc)
                    self.ipc = cpu.pc
                if first_wait is None and cpu.pc == 0x0080:
                    first_wait = cpu.cycles - self.frame_start
                cpu.step()
            self.busy.append(first_wait)
            self.frame_start = end
            self.frame += 1
            if self.on_frame:
                self.on_frame(self)

    def ram(self, bank=None):
        return bytes(self.banks[self.bank if bank is None else bank])


if __name__ == "__main__":
    b = Board(trace=True)
    script = {}

    def inp(f):
        if 300 <= f < 305:
            return COIN
        if 400 <= f < 405:
            return START1
        if f > 450:
            m = FIRE if (f // 7) % 2 else 0
            m |= LEFT if (f // 90) % 2 else RIGHT
            if f % 500 == 0:
                m |= SHIELD
            return m
        return 0

    b.run_frames(int(sys.argv[1]) if len(sys.argv) > 1 else 3000, inp)
    busy = [x for x in b.busy if x is not None]
    print("frames", b.frame, "pcs", len(b.pcs))
    print("busy cycles/frame max %d avg %d (frame %d)" % (max(busy), sum(busy) // len(busy), FRAME_CYCLES))
    import collections
    hist = collections.Counter(min(x // 5000, 9) for x in busy)
    print(sorted(hist.items()))
