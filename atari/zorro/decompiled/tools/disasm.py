#!/usr/bin/env python3
"""Generate a rebuildable MADS source (zorro.asm) from the original XEX.

Usage: python3 disasm.py ORIGINAL.xex OUTDIR
Writes OUTDIR/zorro.asm and OUTDIR/data/*.bin. Assembling zorro.asm gives
back the original file byte for byte (see build.sh).

Code is found by recursive descent from the entry points below: the start,
the interrupt handlers the game installs, and the object handler table that
the main loop calls through a patched JSR. Anything not reached is emitted as
data. Names and comments come from symbols.py.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from opcodes import OPS, SIZE                       # noqa: E402
from trace import trace, operand, BRANCHES                    # noqa: E402
from xex import load, segments                      # noqa: E402
import symbols as S                                 # noqa: E402

# parts of the file that are written out as source (the rest goes to data/)
SOURCE_RANGES = [(0x0480, 0x3D7F), (0x5BE8, 0x84E7)]


def in_source(a):
    return any(lo <= a <= hi for lo, hi in SOURCE_RANGES)


def hexb(v):
    return '$%02X' % v


def hexw(v):
    return '$%04X' % v


class Disasm:
    def __init__(self, ram, loaded):
        self.ram = ram
        tab = S.handler_table(ram)
        entries = [0x0480] + sorted(set(tab)) + S.EXTRA_ENTRIES
        def valid(a):
            return in_source(a) and not any(lo <= a <= hi for lo, hi in S.DATA_RANGES)
        while True:
            code, targets, vec_sets = trace(ram, entries, valid)
            pend = {}
            for at, vec, half, val in vec_sets:
                pend.setdefault(vec, {})[half] = val
            new = [h['lo'] | h['hi'] << 8 for h in pend.values()
                   if 'lo' in h and 'hi' in h]
            new = [t for t in new if t not in entries and in_source(t)]
            if not new:
                break
            entries += new
        self.code = code
        self.entries = entries
        self.start = {}                     # byte -> start of its instruction
        for a, n in code.items():
            for k in range(n):
                self.start[a + k] = a
        self.labels = dict(S.NAMES)
        self.arrays = []                    # (base, size, name)
        for base, (name, size) in S.ARRAYS.items():
            self.arrays.append((base, size, name))
            if in_source(base):
                self.labels[base] = name
        self.arrays.sort()
        self.jsr_targets = set()
        self.symbolic_imm = {}              # insn addr -> '<label' / '>label'
        self.word_ptrs = set(S.WORD_POINTERS)
        self.lohi = {}                      # data addr -> ('<'|'>', target)
        for lo, hi, n in S.SPLIT_TABLES:
            for i in range(n):
                t = ram[lo + i] | ram[hi + i] << 8
                self.lohi[lo + i] = ('<', t)
                self.lohi[hi + i] = ('>', t)
        for a in S.WORD_POINTERS:
            self.ref(self.word(a))
        self.be_ptrs = set(S.BE_POINTERS)
        for a in S.BE_POINTERS:
            self.ref(self.ram[a] << 8 | self.ram[a + 1])
        for lo, hi, n in S.SPLIT_TABLES:
            for i in range(n):
                self.ref(ram[lo + i] | ram[hi + i] << 8)
        self.strings = set(S.STRINGS)
        self.scan_code()
        self.dl = {}                        # display list instructions
        for lo, hi in S.DISPLAY_LISTS:
            self.scan_dl(lo, hi)

    def scan_dl(self, lo, hi):
        """Split a display list into instructions for dta output. An LMS
        address gets its own entry so a label can point at it."""
        ram = self.ram
        a = lo
        while a <= hi:
            b = ram[a]
            mode = b & 0x0F
            if mode == 1 or (mode >= 2 and b & 0x40):   # JMP/JVB or LMS
                self.dl[a] = ('op', 1, '$%02X' % b)
                t = self.sym_dl(self.word(a + 1))
                if a + 2 in self.labels:            # the high byte is patched
                    self.dl[a + 1] = ('lo', 1, 'l(%s)' % t)
                    self.dl[a + 2] = ('hi', 1, 'h(%s)' % t)
                else:
                    self.dl[a + 1] = ('addr', 2, 'a(%s)' % t)
                a += 3
                continue
            n = 1
            while a + n <= hi and ram[a + n] == b and a + n not in self.labels \
                    and n < 16:
                n += 1
            self.dl[a] = ('op', n, ','.join(['$%02X' % b] * n))
            a += n

    def sym_dl(self, v):
        if in_source(v):
            self.ref(v)
        return '$%04X' % v if not in_source(v) and v not in S.EQU else self.sym(v)

    def word(self, a):
        return self.ram[a] | self.ram[a + 1] << 8

    # ------------------------------------------------------------ labels
    def in_array(self, v, indexed=False):
        """(name, offset) if v is inside a named array (or just before one,
        for an indexed access such as obj_x-1,x)."""
        if indexed:
            for base, size, name in self.arrays:
                if v == base - 1:
                    return name, -1
        for base, size, name in self.arrays:
            if base <= v < base + size:
                return name, v - base
        return None

    def ref(self, v, kind='D', indexed=False):
        """Make sure address v in the source has a label; return nothing."""
        if not in_source(v):
            return
        if v not in self.start and self.in_array(v, indexed):
            return
        base = self.start.get(v, v)
        if base not in self.labels:
            if base in self.code:
                self.labels[base] = ('S%04X' if kind == 'S' else 'L%04X') % base
            else:
                self.labels[base] = 'D%04X' % base

    def sym(self, v, zp_ok=False, indexed=False):
        """Symbolic form of address v."""
        arr = None if v in self.start else self.in_array(v, indexed)
        if arr:
            name, k = arr
            return name if k == 0 else '%s%+d' % (name, k)
        if in_source(v):
            base = self.start.get(v, v)
            name = self.labels[base]
            return name if base == v else '%s+%d' % (name, v - base)
        if v in S.EQU:
            return S.EQU[v]
        if v - 1 in S.EQU and S.EQU[v - 1] not in S.NO_PLUS1:
            return S.EQU[v - 1] + '+1'
        return hexb(v) if v < 0x100 and zp_ok else hexw(v)

    def scan_code(self):
        ram = self.ram
        order = sorted(self.code)
        for a in order:
            op, mode, n, v = operand(ram, a)
            if op == 'jsr':
                self.jsr_targets.add(v)
                self.ref(v, 'S')
            elif n == 3 or mode == 'rel':
                self.ref(v, indexed=mode in ('abx', 'aby'))
        # immediate address pairs: lda #<x ... ldy/ldx #>x (A/Y for PrintAt,
        # A/X for the room copier) and lda #<x sta p / lda #>x sta p+1
        for i, a in enumerate(order):
            op, mode, n, v = operand(ram, a)
            if mode != 'imm' or a in self.symbolic_imm:
                continue
            if a in S.FORCE_POINTERS:           # lda #<x / ldy #>x by hand
                target = v | ram[S.FORCE_POINTERS[a] + 1] << 8
                self.ref(target)
                self.symbolic_imm[a] = ('<', target)
                self.symbolic_imm[S.FORCE_POINTERS[a]] = ('>', target)
                continue
            # look at the next 4 instructions in straight-line code
            seq = []
            p = a
            for _ in range(5):
                if p not in self.code:
                    break
                seq.append(p)
                p += self.code[p]
            hi_at = None
            if op == 'lda' and len(seq) > 1:
                op2, m2, _, v2 = operand(ram, seq[1])
                if m2 == 'imm' and op2 in ('ldy', 'ldx') and len(seq) > 2:
                    op3 = operand(ram, seq[2])[0]
                    t = v | v2 << 8
                    if (op3 in ('jsr', 'jmp') or op3 in BRANCHES
                            or S.SPRITES[0] <= t <= S.SPRITES[1]):
                        hi_at = seq[1]
                elif op2 in ('sta',) and m2 in ('zp', 'abs') and len(seq) > 3:
                    op3, m3, _, v3 = operand(ram, seq[2])
                    op4, m4, _, v4 = operand(ram, seq[3])
                    if (op3 == 'lda' and m3 == 'imm' and op4 == 'sta'
                            and m4 == m2 and v4 == v2 + 1):
                        hi_at = seq[2]
            if hi_at is None:
                continue
            target = v | ram[hi_at + 1] << 8
            if target in S.NOT_POINTERS.get(a, ()) or a in S.NOT_POINTERS:
                continue
            if in_source(target):
                self.ref(target)
                self.symbolic_imm[a] = ('<', target)
                self.symbolic_imm[hi_at] = ('>', target)

    # ------------------------------------------------------------ output
    def fmt_insn(self, a):
        ram = self.ram
        op, mode, n, v = operand(ram, a)
        if mode in ('imp',):
            return op
        if mode == 'acc':
            return op
        if mode == 'imm':
            if a in self.symbolic_imm:
                half, t = self.symbolic_imm[a]
                return '%s #%s%s' % (op, half, self.sym(t))
            if a in S.IMM_EQU:
                return '%s #%s' % (op, S.IMM_EQU[a])
            return '%s #%s' % (op, hexb(v))
        if mode == 'rel':
            return '%s %s' % (op, self.sym(v))
        if mode in ('zp', 'zpx', 'zpy', 'izx', 'izy'):
            s = self.sym(v, zp_ok=True, indexed=mode in ('zpx', 'zpy'))
            return {
                'zp': '%s %s', 'zpx': '%s %s,x', 'zpy': '%s %s,y',
                'izx': '%s (%s,x)', 'izy': '%s (%s),y'}[mode] % (op, s)
        s = S.OPERAND_EQU.get(a) or self.sym(v, indexed=mode in ('abx', 'aby'))
        w = '.w' if v < 0x100 else ''
        if mode == 'abs':
            return '%s%s %s' % (op, w, s)
        if mode == 'abx':
            return '%s%s %s,x' % (op, w, s)
        if mode == 'aby':
            return '%s%s %s,y' % (op, w, s)
        if mode == 'ind':
            return '%s (%s)' % (op, s)
        raise ValueError(mode)

    def emit_range(self, out, lo, hi):
        ram = self.ram
        a = lo
        while a <= hi:
            name = self.labels.get(a)
            if a in S.HEADER:
                out.append('')
                for line in S.HEADER[a].splitlines():
                    out.append('; ' + line if line else ';')
            if a in self.code:
                if name and (a in self.jsr_targets or a in S.PROC_DOC):
                    out.append('')
                    if a in S.PROC_DOC:
                        for line in S.PROC_DOC[a].splitlines():
                            out.append('; ' + line)
                text = self.fmt_insn(a)
                cm = S.COMMENTS.get(a)
                line = '%-15s %s' % (name or '', text)
                line = (name or '') + '\t' + text if name and len(name) >= 8 \
                    else ('%-8s' % (name or '')) + '\t' + text
                if cm:
                    line = '%-40s; %s' % (line.expandtabs(8), cm)
                out.append(line)
                a += self.code[a]
                continue
            # data: run until the next label, code start or range end
            b = a + 1
            while b <= hi and b not in self.labels and b not in self.code \
                    and b not in S.HEADER:
                b += 1
            self.emit_data(out, a, b - 1, name)
            a = b

    def emit_data(self, out, a, b, name):
        ram = self.ram
        first = True
        cm = S.COMMENTS.get(a)
        while a <= b:
            lab = (name or '') if first else ''
            if a in self.strings:
                e = a + 1
                while ram[e] < 0x80:
                    e += 1
                out.append('; column %d: "%s"' % (ram[a], decode_text(ram[a + 1:e])))
                for k in range(a, e + 1, 16):
                    body = ','.join(hexb(x) for x in ram[k:min(k + 16, e + 1)])
                    out.append('%-8s\tdta %s' % (lab if k == a else '', body))
                a = e + 1
                first = False
                continue
            if a in self.lohi:
                items = []
                while a <= b and a in self.lohi and len(items) < 8:
                    half, t = self.lohi[a]
                    items.append('%s(%s)' % ('l' if half == '<' else 'h', self.sym(t)))
                    a += 1
                out.append('%-8s\tdta %s' % (lab, ','.join(items)))
                first = False
                continue
            if a in self.dl:
                kind, n, text = self.dl[a]
                line = '%-8s\tdta %s' % (lab, text)
                out.append(line)
                a += n
                first = False
                continue
            if a in self.be_ptrs:
                t = self.ram[a] << 8 | self.ram[a + 1]
                out.append('%-8s\tdta h(%s),l(%s)' % (lab, self.sym(t), self.sym(t)))
                a += 2
                first = False
                continue
            if a in self.word_ptrs:
                out.append('%-8s\tdta a(%s)' % (lab, self.sym(self.word(a))))
                a += 2
                first = False
                continue
            n = 16 - (a & 15) if b - a >= 16 - (a & 15) else b - a + 1
            n = min(n, b - a + 1)
            # stop before a string / pointer that starts inside this line
            for k in range(1, n):
                if (a + k in self.strings or a + k in self.lohi or a + k in self.word_ptrs
                        or a + k in self.be_ptrs or a + k in self.dl):
                    n = k
                    break
            line = '%-8s\tdta %s' % (lab, ','.join(hexb(x) for x in ram[a:a + n]))
            if first and cm:
                line = '%-40s; %s' % (line.expandtabs(8), cm)
            out.append(line)
            a += n
            first = False


def decode_text(bs):
    """Text as stored for PrintAt: codes < $20 are EORed with $10, the rest
    are ANTIC internal codes."""
    s = ''
    for c in bs:
        c = c ^ 0x10 if c < 0x20 else c
        if c < 0x40:
            s += chr(c + 0x20)
        elif 0x61 <= c <= 0x7A:
            s += chr(c)
        else:
            s += '\\x%02x' % c
    return s.replace('"', "'")


def main():
    src, outdir = sys.argv[1], sys.argv[2]
    ram, loaded = load(src)
    raw = open(src, 'rb').read()
    segs = list(segments(raw))
    d = Disasm(ram, loaded)
    seen = {}
    for name in list(d.labels.values()) + list(S.EQU.values()) + \
            [n for n, _ in S.ARRAYS.values()]:
        if name.upper() in seen and seen[name.upper()] != name:
            sys.exit('label clash (MADS ignores case): %s / %s'
                     % (name, seen[name.upper()]))
        seen[name.upper()] = name
    os.makedirs(os.path.join(outdir, 'data'), exist_ok=True)
    for f in os.listdir(os.path.join(outdir, 'data')):
        if f.startswith('rom_') and f.endswith('.bin'):
            os.remove(os.path.join(outdir, 'data', f))

    out = S.PREAMBLE.rstrip('\n').splitlines()
    out.append('')
    out.append('; ---- hardware, OS and RAM outside the program')
    for addr in sorted(S.EQU):
        name = S.EQU[addr]
        line = '%-15s = %s' % (name, hexb(addr) if addr < 0x100 else hexw(addr))
        if name in S.EQU_COMMENTS:
            line = '%-31s; %s' % (line, S.EQU_COMMENTS[name])
        out.append(line)
    out.append('')
    out.append('; ---- variables and arrays outside the program image')
    for addr in sorted(S.ARRAYS):
        name, size = S.ARRAYS[addr]
        if not in_source(addr):
            out.append('%-15s = %s\t; %d byte%s' % (
                name, hexb(addr) if addr < 0x100 else hexw(addr), size,
                '' if size == 1 else 's'))
    out.append('')
    out.extend(S.LOADER.rstrip('\n').splitlines())

    # the six chunks for the RAM under the OS ROM
    rom_chunks = [(s, blk) for s, blk, _ in segs[1:13] if s != 0x02E2]
    for i, (s, blk) in enumerate(rom_chunks):
        dst = segs[0][1][i] * 256           # cc_dst table of the copier
        name = 'rom_%04x.bin' % dst
        open(os.path.join(outdir, 'data', name), 'wb').write(blk)
        out.append('')
        out.append('; chunk %d: $%04X-$%04X, copied under the OS ROM to $%04X-$%04X'
                   % (i + 1, s, s + len(blk) - 1, dst, dst + len(blk) - 1))
        out.append('\tdta a($FFFF),a($%04X),a($%04X)' % (s, s + len(blk) - 1))
        out.append("\tins 'data/%s'" % name)
        out.append('\tdta a(INITAD),a(INITAD+1),a(CopyChunk)')

    out.append('')
    out.append(S.MAIN_BANNER.rstrip('\n'))
    out.append('\tdta a($FFFF),a(Start+$1000),a(main_end+$1000-1)')
    out.append('\torg $0480')
    d.emit_range(out, 0x0480, 0x3D7F)
    out.append('main_end')
    out.append('')
    out.append(S.UPPER_BANNER.rstrip('\n'))
    out.append('\tdta a($FFFF),a(upper_start),a(upper_end-1)')
    out.append('\torg $5BE8')
    out.append('upper_start')
    d.emit_range(out, 0x5BE8, 0x84E7)
    out.append('upper_end')

    out.append('')
    out.extend(S.RUN_STUB.rstrip('\n').splitlines())
    open(os.path.join(outdir, 'zorro.asm'), 'w').write('\n'.join(out) + '\n')
    print('code bytes: %d, labels: %d' % (sum(d.code.values()), len(d.labels)))


def raw_segment(segs, start):
    for s, blk, _ in segs:
        if s == start:
            return blk
    raise KeyError(start)


if __name__ == '__main__':
    main()
