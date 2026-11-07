#!/usr/bin/env python3
"""Run the C64 Ghosts'n Goblins Arcade in the headless model (tools/c64.py).

The drive is replaced by high-level traps on the game's own fast loader:
the decruncher's byte fetch ($5659) and the serial byte read ($5694) are fed
straight from the files in disk/ (extracted by tools/d64.py). The KERNAL is
not present; its IRQ entry ($FF48) and the usual exits ($EA31/$EA81/$FEBC)
are emulated when the game leaves the KERNAL banked in.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from c64 import C64  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DISK = os.path.join(HERE, 'disk')


def disk_file(n):
    return open(os.path.join(DISK, f'{n & 0x7F:02X}.GA.prg'), 'rb').read()   # bit 7: a save


COLORS = {0x90: 0, 0x05: 1, 0x1C: 2, 0x9F: 3, 0x9C: 4, 0x1E: 5, 0x1F: 6, 0x9E: 7,
          0x81: 8, 0x95: 9, 0x96: 10, 0x97: 11, 0x98: 12, 0x99: 13, 0x9A: 14, 0x9B: 15}


def petscii_to_screen(ch):
    if ch < 0x20:
        return None
    if ch < 0x40:
        return ch
    if ch < 0x60:
        return ch - 0x40
    if ch < 0x80:
        return ch - 0x20
    if 0xA0 <= ch < 0xC0:
        return ch - 0x40
    if 0xC0 <= ch < 0xFF:
        return ch - 0x80
    return 0x5E


def chrout(ram, colram, ch):
    """The parts of the KERNAL screen editor the game's menu uses."""
    row, col = ram[0xD6], ram[0xD3]
    if ch in COLORS:
        ram[0x0286] = COLORS[ch]
    elif ch == 0x0D or ch == 0x8D:
        row, col = row + 1, 0
        ram[0xC7] = 0
    elif ch == 0x93:
        base = ram[0x288] << 8
        ram[base:base + 1000] = b'\x20' * 1000
        row = col = 0
    elif ch == 0x13:
        row = col = 0
    elif ch == 0x11:
        row += 1
    elif ch == 0x91:
        row = max(0, row - 1)
    elif ch == 0x1D:
        col += 1
    elif ch == 0x9D:
        col = max(0, col - 1)
    elif ch == 0x12:
        ram[0xC7] = 1
    elif ch == 0x92:
        ram[0xC7] = 0
    else:
        sc = petscii_to_screen(ch)
        if sc is not None:
            if ram[0xC7]:
                sc |= 0x80
            off = min(row, 24) * 40 + col
            ram[(ram[0x288] << 8) + off] = sc
            colram[off] = ram[0x0286] & 15
            col += 1
    if col >= 40:
        row, col = row + 1, col - 40
    ram[0xD6], ram[0xD3] = min(row, 24), col


class Game(C64):
    def extra_state(self):
        return {'stream': self.stream, 'spos': self.spos, 'loads': self.loads}

    def __init__(self, verbose=True, snapshot=None):
        super().__init__()
        self.verbose = verbose
        self.stream = b''
        self.spos = 0
        self.loads = []
        self.load_prg(open(os.path.join(DISK, 'boot.prg'), 'rb').read())
        self.mem.ram[0x02A6] = 1          # PAL
        self.mem.ram[0xBA] = 8
        self.cpu.pc = 0x080D
        self.cpu.sp = 0xF6
        self.capture = None
        self.install_traps()
        if snapshot:
            self.restore(snapshot)
        else:
            self.run(10_000_000, stop=lambda c: c.cpu.pc == 0x0800)

    # ---- helpers ----
    def rts(self):
        cpu = self.cpu
        lo = cpu.stPop()
        hi = cpu.stPop()
        cpu.pc = ((hi << 8) | lo) + 1 & 0xFFFF

    def install_traps(self):
        t = self.traps
        t[0x185B] = self.t_install
        t[0x55DE] = self.t_load
        t[0x5720] = self.t_rts          # send file id to the drive
        t[0x5653] = self.t_rts          # wait for the drive
        t[0x5659] = self.t_getbyte
        t[0x5694] = self.t_serial
        t[0x5676] = self.t_block
        t[0x56DB] = self.t_raw_load
        t[0x56FF] = self.t_save
        self.saved = {}
        for a in (0xEA31, 0xEA81, 0xFEBC):
            t[a] = self.t_kexit
        t[0xFF9F] = self.t_kernal_rts     # SCNKEY
        t[0xFFE4] = self.t_getin          # GETIN
        t[0xFFD2] = self.t_chrout         # CHROUT
        t[0xFFF0] = self.t_plot           # PLOT
        self.key_queue = []

    def t_kernal_rts(self, c):
        if not self.kernal_on():
            return None
        self.rts()
        return 'again'

    def t_chrout(self, c):
        if not self.kernal_on():
            return None
        chrout(self.mem.ram, self.colram, c.cpu.a)
        self.rts()
        return 'again'

    def t_plot(self, c):
        if not self.kernal_on():
            return None
        ram, cpu = self.mem.ram, c.cpu
        if cpu.p & 1:
            cpu.x, cpu.y = ram[0xD6], ram[0xD3]
        else:
            ram[0xD6], ram[0xD3] = cpu.x, cpu.y
        self.rts()
        return 'again'

    def t_getin(self, c):
        if not self.kernal_on():
            return None
        c.cpu.a = self.key_queue.pop(0) if self.key_queue else 0
        c.cpu.p = c.cpu.p & ~2 | (2 if c.cpu.a == 0 else 0)
        self.rts()
        return 'again'

    def t_rts(self, c):
        self.rts()
        return 'again'

    def t_install(self, c):
        c.cpu.a = 0
        self.rts()
        return 'again'

    def t_load(self, c):
        cpu = self.cpu
        n, segs, mode = cpu.a, cpu.y, cpu.x
        if self.capture is not None:
            self.capture_start(n, segs, mode)
        self.stream = disk_file(n)
        self.spos = 0
        self.loads.append((self.frame, n, segs, mode))
        if self.verbose:
            print(f'[frame {self.frame}] load {n:02X} segs={segs} mode={mode}')
        return None                      # run the original code (traps below feed it)

    # ---- recording what each load writes (tools/extract.py) ----
    def capture_start(self, n, segs, mode):
        ret = self.mem.ram[0x100 + self.cpu.sp + 1] | self.mem.ram[0x100 + self.cpu.sp + 2] << 8
        self.capture.append({'file': n, 'segs': segs, 'mode': mode, 'frame': self.frame,
                             'writes': {}, 'ret': ret + 1, 'sp': self.cpu.sp, 'port': None})
        mem = self.mem
        base = type(mem)
        game = self
        rec = self.capture[-1]

        class CMem(base):
            def __setitem__(self, a, v):
                if 0x5400 <= game.cpu.pc < 0x5800 and a >= 0x0200 and not (0x0500 <= a < 0x0700):
                    io = 0xD000 <= a < 0xE000 and game.io_on()
                    rec['writes'][a] = (v, io)
                base.__setitem__(self, a, v)

        mem.__class__ = CMem
        self.traps[rec['ret']] = self.capture_end

    def capture_end(self, c):
        rec = self.capture[-1]
        if self.cpu.sp != (rec['sp'] + 2) & 0xFF:
            return None
        del self.traps[rec['ret']]
        self.mem.__class__ = self.mem.__class__.__mro__[1]
        rec['port'] = self.port[1]
        return None

    def next_byte(self):
        if self.spos < len(self.stream):
            v = self.stream[self.spos]
        else:
            v = 0
        self.spos += 1
        return v

    def t_getbyte(self, c):
        c.cpu.a = self.next_byte()
        self.rts()
        return 'again'

    def t_block(self, c):
        # start of a drive block; nothing to fetch in the HLE stream
        self.rts()
        return 'again'

    def t_serial(self, c):
        mem = self.mem.ram
        if mem[0x56C6] == 0x99:          # block-fill mode: the HLE stream needs no buffer
            self.rts()
            return 'again'
        v = self.next_byte()
        if mem[0x56E4] == 0x49:          # raw loads undo the EOR applied on the way in
            v ^= 0
        c.cpu.a = v
        self.rts()
        return 'again'

    def t_raw_load(self, c):
        # mode 1: plain file, EOR $B3, destination from its first two bytes ($C3/$C4)
        ram = self.mem.ram
        a = ram[0xC3] | ram[0xC4] << 8
        data = self.stream[self.spos:]
        for i, b in enumerate(data):
            ram[(a + i) & 0xFFFF] = b ^ 0xB3
        a += len(data)
        ram[0xC3], ram[0xC4] = a & 0xFF, a >> 8 & 0xFF
        self.spos = len(self.stream)
        self.rts()
        return 'again'

    def t_save(self, c):
        # mode 2: write memory from ($C3/$C4) up to $6200 back to the file (high scores)
        ram = self.mem.ram
        a = ram[0xC3] | ram[0xC4] << 8
        self.saved[self.loads[-1][1]] = bytes(ram[a:0x6200])
        if self.verbose:
            print(f'[frame {self.frame}] save ${a:04X}-$61FF')
        self.rts()
        return 'again'

    def t_kexit(self, c):
        cpu = self.cpu
        if not self.kernal_on():
            return None
        if cpu.pc == 0xEA31:
            self.cia1.icr = 0
        cpu.y = cpu.stPop()
        cpu.x = cpu.stPop()
        cpu.a = cpu.stPop()
        cpu.p = cpu.stPop() | cpu.UNUSED
        lo = cpu.stPop()
        hi = cpu.stPop()
        cpu.pc = hi << 8 | lo
        return 'again'

    def interrupt(self, vector):
        cpu = self.cpu
        if self.kernal_on():
            cpu.stPushWord(cpu.pc)
            cpu.stPush((cpu.p & ~cpu.BREAK) | cpu.UNUSED)
            cpu.p |= cpu.INTERRUPT
            if vector == 0xFFFE:
                cpu.stPush(cpu.a)
                cpu.stPush(cpu.x)
                cpu.stPush(cpu.y)
                cpu.pc = self.mem.ram[0x314] | self.mem.ram[0x315] << 8
            else:
                cpu.pc = self.mem.ram[0x318] | self.mem.ram[0x319] << 8
            return
        super().interrupt(vector)


if __name__ == '__main__':
    g = Game()
    frames = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    g.run(frames * 312 * 63)
    print('pc', hex(g.cpu.pc), 'frame', g.frame)


MENU_SNAP = os.path.join(HERE, 'gen', 'menu.snap')


def menu_snapshot():
    """Snapshot of the game options menu (made once, cached in gen/)."""
    if not os.path.exists(MENU_SNAP):
        os.makedirs(os.path.dirname(MENU_SNAP), exist_ok=True)
        g = Game(verbose=False)
        f0 = g.frame
        # the intro accepts fire only after its music has played a while
        while not g.loads or g.loads[-1][1] != 0x0A:
            k = g.frame - f0
            g.joy2 = 0xEF if k % 400 in range(200, 210) else 0xFF
            g.run(63 * 312)
        g.joy2 = 0xFF
        g.run(63 * 312 * 200)
        g.save(MENU_SNAP)
    return MENU_SNAP


def start_game(level=1, invincible=True, lives=True, time=True, original=False, verbose=False,
               game=None):
    """Boot to the menu, set the trainer options and play until the game is running."""
    g = game or Game(verbose=verbose, snapshot=menu_snapshot())
    opt = g.mem.ram
    opt[0x9155] = int(original)
    opt[0x9157] = int(invincible)
    opt[0x9158] = int(lives)
    opt[0x9159] = int(time)
    opt[0x915A] = 0x80 + level
    opt[0xFA] = 9
    f0 = g.frame
    # menu -> title (fire), title -> game (fire while the attract mode runs);
    # $3618 is the in-game joystick read
    while g.frame - f0 < 5000:
        k = g.frame - f0
        g.joy2 = 0xEF if k % 100 in range(10, 16) else 0xFF
        if g.run(63 * 312, stop=lambda c: c.cpu.pc == 0x3618) is not None:
            g.joy2 = 0xFF
            return g
    raise RuntimeError('the game did not start')


ENTRY_SNAP = os.path.join(HERE, 'gen', 'entry.snap')


def entry_snapshot():
    """Snapshot at JMP $0800 after the intro's stub loaded 09 (main) and 0A (menu)."""
    if not os.path.exists(ENTRY_SNAP):
        os.makedirs(os.path.dirname(ENTRY_SNAP), exist_ok=True)
        g = Game(verbose=False)
        f0 = g.frame
        while True:
            k = g.frame - f0
            g.joy2 = 0xEF if k % 400 in range(200, 210) else 0xFF
            done = any(n == 0x0A for _, n, _, _ in g.loads)
            if g.run(63 * 312, stop=lambda c: done and c.cpu.pc == 0x0800) is not None:
                break
        g.save(ENTRY_SNAP)
    return ENTRY_SNAP
