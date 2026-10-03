#!/usr/bin/env python3
"""Generate a rebuildable MADS source (agent.asm) from the original XEX.

Usage: python3 disasm.py ORIGINAL.xex OUTDIR
Writes OUTDIR/agent.asm. Assembling it gives back the original file byte for
byte (see build.sh).

Code is found by recursive descent from the entry points: the two loader
stubs, the game start, every handler table and every interrupt handler that
the code installs with two immediates (DLI chains, the VBI). Anything not
reached is emitted as data. Names and comments come from symbols.py.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from trace import trace, operand, BRANCHES          # noqa: E402
from xex import load, RELOC_SRC, RELOC_DST, RELOC_LEN  # noqa: E402
import symbols as S                                 # noqa: E402

# runtime address ranges written out as source. $0800-$100F is stored in
# the file at $2200-$2A0F and moved down by the loader stub.
RELOC = (RELOC_DST, RELOC_DST + RELOC_LEN - 1)
MAIN = (0x2A10, 0xB87F)
SOURCE_RANGES = [RELOC, MAIN]
# addresses that get labels; $B800-$BFFF is a work area once the game runs
# (the loader stub there is overwritten), so references to it stay numeric
LABEL_RANGES = [RELOC, (0x2A10, 0xB7FF)]


def in_source(a):
    return any(lo <= a <= hi for lo, hi in LABEL_RANGES)


def hexb(v):
    return '$%02X' % v


def hexw(v):
    return '$%04X' % v


def is_text(c):
    """ANTIC internal code allowed in a text run: space, ! , - . / digits
    : ? letters."""
    return c in (0x00, 0x01, 0x0C, 0x0D, 0x0E, 0x0F, 0x1A, 0x1F) or \
        0x10 <= c <= 0x19 or 0x21 <= c <= 0x3A or 0x61 <= c <= 0x7A


def text_char(c):
    return chr(c + 0x20) if c < 0x40 else chr(c)


class Disasm:
    def __init__(self, ram):
        self.ram = ram
        entries = list(S.ENTRIES)
        for t, n in S.WORD_TABLES:
            entries += [self.word(t + 2 * i) for i in range(n)
                        if self.word(t + 2 * i) and t + 2 * i not in S.NOT_ENTRIES]
        for lo, hi, n in S.SPLIT_CODE_TABLES:
            entries += [ram[lo + i] | ram[hi + i] << 8 for i in range(n)]

        data = list(S.DATA_RANGES)
        for t, n in S.WORD_TABLES + S.DATA_WORD_TABLES:
            data.append((t, t + 2 * n - 1))
        for lo, hi, n in S.SPLIT_CODE_TABLES + S.SPLIT_TABLES:
            data += [(lo, lo + n - 1), (hi, hi + n - 1)]

        def valid(a):
            return (0x2A20 <= a < 0xB820
                    and not any(lo <= a <= hi for lo, hi in data))
        self.code, self.pairs = trace(ram, entries, valid, S.VECTORS)
        self.start = {}                     # byte -> start of its instruction
        for a, n in self.code.items():
            for k in range(n):
                self.start[a + k] = a
        for t, n in S.WORD_TABLES + S.DATA_WORD_TABLES:
            self.start[t + 1] = t       # tab+1,y reads the high bytes
        for t, stride in S.CITY_TABLES:
            if stride == 2:
                self.start[t + 1] = t
        self.labels = dict(S.NAMES)
        self.arrays = []                    # (base, size, name)
        for base, (name, size) in S.ARRAYS.items():
            self.arrays.append((base, size, name))
            if in_source(base):
                self.labels[base] = name
        self.arrays.sort()
        self.jsr_targets = set()
        self.symbolic_imm = {}              # insn addr -> ('<'|'>', target)
        for lo_at, hi_at, vec, t in self.pairs:
            self.symbolic_imm[lo_at] = ('<', t)
            self.symbolic_imm[hi_at] = ('>', t)
            self.ref(t, 'S')
        for t, fmt in S.TABLE_LABELS.items():
            n = dict(S.DATA_WORD_TABLES)[t]
            for i in range(n):
                w = self.word(t + 2 * i)
                if in_source(w) and w not in self.labels:
                    self.labels[w] = fmt % i
        self.city_name = {}                 # city number -> name
        t, n = S.NAME_TABLE
        self.names = {}                     # name string addr -> city
        for i in range(1, n):
            a = self.word(t + 2 * i)
            e = a
            while ram[e] != 0xFF:
                e += 1
            self.names[a] = i
            self.city_name[i] = ''.join(text_char(c) for c in ram[a:e])
        t, n = S.LINK_TABLE
        self.links = {self.word(t + 2 * i): i for i in range(1, n)}
        self.city_rows = {}                 # addr -> (city, stride)
        for base, stride in S.CITY_TABLES:
            for i in range(n):
                self.city_rows[base + stride * i] = (i, stride)
        self.word_ptrs = set()
        for t, n in S.WORD_TABLES + S.DATA_WORD_TABLES:
            for i in range(n):
                self.word_ptrs.add(t + 2 * i)
                self.ref(self.word(t + 2 * i))
        self.lohi = {}                      # data addr -> ('<'|'>', target)
        for lo, hi, n in S.SPLIT_CODE_TABLES + S.SPLIT_TABLES:
            for i in range(n):
                t = ram[lo + i] | ram[hi + i] << 8
                self.lohi[lo + i] = ('<', t)
                self.lohi[hi + i] = ('>', t)
                self.ref(t)
        self.scan_code()
        self.dl = {}                        # display list instructions
        for a in S.DISPLAY_LISTS:
            self.scan_dl(a)
        self.msgs = {}                      # message addr -> number
        for t, n in S.MESSAGE_TABLES:
            for i in range(n):
                m = self.word(t + 2 * i)
                self.msgs[m] = i
                if self.labels.get(m, 'D')[0] == 'D':
                    self.labels[m] = 'msg_%d' % i
        self.text = {}                      # data addr -> length of text run
        for lo, hi in S.TEXT_RANGES:
            self.find_text(lo, hi)

    def word(self, a):
        return self.ram[a] | self.ram[a + 1] << 8

    # ------------------------------------------------------------ scanning
    def scan_dl(self, a):
        """Split a display list into instructions, up to its JVB."""
        ram = self.ram
        if self.labels.get(a, 'D')[0] == 'D':
            self.labels[a] = 'dlist_%04x' % a
        while True:
            b = ram[a]
            mode = b & 0x0F
            if mode == 1 or (mode >= 2 and b & 0x40):   # JMP/JVB or LMS
                t = self.word(a + 1)
                self.ref(t)
                if a + 1 in self.labels or a + 2 in self.labels:
                    # the code patches the address: one line per byte
                    self.dl[a] = (1, '$%02X' % b)
                    self.dl[a + 1] = (1, 'l(%s)' % self.sym(t))
                    self.dl[a + 2] = (1, 'h(%s)' % self.sym(t))
                else:
                    self.dl[a] = (3, '$%02X,a(%s)' % (b, self.sym(t)))
                a += 3
                if b == 0x41:
                    return
                continue
            n = 1
            while ram[a + n] == b and a + n not in self.labels and n < 16:
                n += 1
            self.dl[a] = (n, ','.join(['$%02X' % b] * n))
            a += n

    def find_text(self, lo, hi):
        """Mark runs of screen text: allowed codes only, mostly letters, no
        character four times in a row, not inside a display list."""
        ram = self.ram
        dl = set()
        for a, (n, _) in self.dl.items():
            dl.update(range(a, a + n))
        a = lo
        while a <= hi:
            if not is_text(ram[a]) or ram[a] == 0 or a in dl:
                a += 1
                continue
            b = a
            while b <= hi and is_text(ram[b]) and b not in dl and not (
                    ram[b] == 0 and ram[b + 1] == 0 and ram[b + 2] == 0):
                b += 1
            while ram[b - 1] == 0:
                b -= 1
            run = ram[a:b]
            letters = sum(1 for c in run if 0x61 <= c <= 0x7A or 0x21 <= c <= 0x3A)
            solid = sum(1 for c in run if c)
            repeat = any(run[i] == run[i + 1] == run[i + 2] == run[i + 3] != 0
                         for i in range(len(run) - 3))
            if letters >= 4 and letters * 3 >= solid * 2 and not repeat:
                self.text[a] = b - a
            a = b

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
        for a, (lo_at, hi_at) in S.FORCE_POINTERS.items():
            t = ram[lo_at + 1] | ram[hi_at + 1] << 8
            self.symbolic_imm[lo_at] = ('<', t)
            self.symbolic_imm[hi_at] = ('>', t)
            self.ref(t)
        # lda #<x / sta p / lda #>x / sta p+1 with x inside the program
        for i, a in enumerate(order):
            op, mode, n, v = operand(ram, a)
            if op != 'lda' or mode != 'imm' or a in self.symbolic_imm:
                continue
            seq = []
            p = a
            for _ in range(4):
                if p not in self.code:
                    break
                seq.append(p)
                p += self.code[p]
            if len(seq) < 4:
                continue
            o2, o3, o4 = (operand(ram, s) for s in seq[1:])
            if (o2[0] == 'sta' and o2[1] in ('zp', 'abs') and o3[0] == 'lda'
                    and o3[1] == 'imm' and o4[0] == 'sta' and o4[1] == o2[1]
                    and o4[3] == o2[3] + 1):
                t = v | o3[3] << 8
                if in_source(t) and a not in S.NOT_POINTERS and t >= 0x0800:
                    self.ref(t)
                    self.symbolic_imm[a] = ('<', t)
                    self.symbolic_imm[seq[2]] = ('>', t)

    # ------------------------------------------------------------ labels
    def in_array(self, v, indexed=False):
        if indexed:
            for base, size, name in self.arrays:
                if v == base - 1:
                    return name, -1
        for base, size, name in self.arrays:
            if base <= v < base + size:
                return name, v - base
        return None

    def ref(self, v, kind='D', indexed=False):
        """Make sure address v in the source has a label."""
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

    def sym(self, v, zp_ok=False, indexed=False, write=False):
        if write and v in S.EQU_W:
            return S.EQU_W[v]
        arr = None if v in self.start and in_source(v) \
            else self.in_array(v, indexed)
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

    # ------------------------------------------------------------ output
    def fmt_insn(self, a):
        ram = self.ram
        if a in S.INSN_TEXT:
            return S.INSN_TEXT[a]
        op, mode, n, v = operand(ram, a)
        if mode in ('imp', 'acc'):
            return op
        if mode == 'imm':
            if a in self.symbolic_imm:
                half, t = self.symbolic_imm[a]
                st = self.sym(t)
                if '+' in st or '-' in st:
                    st = '(%s)' % st
                return '%s #%s%s' % (op, half, st)
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
        s = self.sym(v, indexed=mode in ('abx', 'aby'),
                     write=op in ('sta', 'stx', 'sty'))
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
                line = (name or '') + '\t' + text if name and len(name) >= 8 \
                    else ('%-8s' % (name or '')) + '\t' + text
                if cm:
                    line = with_comment(line, cm)
                out.append(line)
                a += self.code[a]
                continue
            b = a + 1
            while b <= hi and b not in self.labels and b not in self.code \
                    and b not in S.HEADER:
                b += 1
            self.emit_data(out, a, b - 1, name)
            a = b

    def emit_message(self, out, a, b):
        emit_message_lines(out, self.ram, a, b)

    def emit_data(self, out, a, b, name):
        ram = self.ram
        first = True
        cm = S.COMMENTS.get(a)
        while a <= b:
            lab = (name or '') if first else ''
            if a in self.msgs and a + ram[a] <= b:
                n = ram[a]
                out.append('%-8s\tdta %d%s' % (lab, n, '\t\t; length'))
                self.emit_message(out, a + 1, a + n)
                a += n + 1
                first = False
                continue
            if a in self.names:
                e = a
                while ram[e] != 0xFF:
                    e += 1
                if e <= b:
                    out.append('%-8s\tdta %s' % (
                        lab, ','.join(text_line(ram, a, e - 1) + ['$FF'])))
                    a = e + 1
                    first = False
                    continue
            if a in self.links:
                e = a
                while ram[e]:
                    e += 2
                if e <= b:
                    city = self.links[a]
                    out.append('; %s:' % self.city_name[city])
                    for k in range(a, e, 2):
                        dst, info = ram[k], ram[k + 1]
                        out.append('%-8s\tdta %3d,$%02X%s; %-18s slot %2d, %s, %s' % (
                            lab if k == a else '', dst, info, ' ' * (4),
                            self.city_name.get(dst & 0x7F, '?'),
                            info & 15, 'ride %d' % (info >> 4),
                            'west' if self.ram[0xA443 + 2 * (dst & 0x7F)] <
                            self.ram[0xA443 + 2 * city] else 'east'))
                    out.append('\tdta 0')
                    a = e + 1
                    first = False
                    continue
            if a in self.city_rows:
                city, stride = self.city_rows[a]
                if a + stride - 1 <= b:
                    vals = ','.join(hexb(x) if stride == 2 else hexb(x)
                                    for x in ram[a:a + stride])
                    if stride == 2:
                        vals = ','.join('%d' % x for x in ram[a:a + stride])
                    out.append('%-8s\tdta %-12s; %3d %s' % (
                        lab, vals, city, self.city_name.get(city, '-')))
                    a += stride
                    first = False
                    continue
            if a in self.text and a + self.text[a] - 1 <= b:
                n = self.text[a]
                s = ''.join(text_char(c) for c in ram[a:a + n])
                q = "'" if "'" not in s else '"'
                out.append("%-8s\tdta d%s%s%s" % (lab, q, s, q))
                a += n
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
            if a in self.dl and a + self.dl[a][0] - 1 <= b:
                n, text = self.dl[a]
                out.append('%-8s\tdta %s' % (lab, text))
                a += n
                first = False
                continue
            if a in self.word_ptrs and a + 1 <= b:
                items = []
                while a + 1 <= b and a in self.word_ptrs and len(items) < 4:
                    items.append('a(%s)' % self.sym(self.word(a)))
                    a += 2
                out.append('%-8s\tdta %s' % (lab, ','.join(items)))
                first = False
                continue
            # a run of zeros: one .ds-like line
            z = a
            while z <= b and ram[z] == 0 and z not in self.text:
                z += 1
            if z - a >= 32:
                out.append('%-8s\t:%d dta 0' % (lab, z - a))
                a = z
                first = False
                continue
            n = 16 - (a & 15)
            n = min(n, b - a + 1)
            for k in range(1, n):
                if (a + k in self.text or a + k in self.lohi
                        or a + k in self.names or a + k in self.links
                        or a + k in self.city_rows
                        or a + k in self.word_ptrs or a + k in self.dl):
                    n = k
                    break
            line = '%-8s\tdta %s' % (lab, ','.join(hexb(x) for x in ram[a:a + n]))
            if first and cm:
                line = with_comment(line, cm)
            out.append(line)
            a += n
            first = False


def with_comment(line, cm):
    """Append '; cm' at column 40, keeping the line's own tabs."""
    width = len(line.expandtabs(8))
    return line + ' ' * max(1, 40 - width) + '; ' + cm


def text_line(ram, a, b):
    """dta items for ram[a..b]: text where possible, bytes otherwise."""
    items = []
    while a <= b:
        if is_text(ram[a]):
            e = a
            while e <= b and is_text(ram[e]):
                e += 1
            s = ''.join(text_char(c) for c in ram[a:e])
            items.append("d'%s'" % s if "'" not in s else 'd"%s"' % s)
            a = e
        else:
            items.append(hexb(ram[a]))
            a += 1
    return items


def emit_message_lines(out, ram, a, b):
    """A message body, one source line per screen line ($FF = new line)."""
    while a <= b:
        e = a
        while e <= b and ram[e] != 0xFF:
            e += 1
        items = text_line(ram, a, e - 1)
        if e <= b:
            items.append('$FF')
        out.append('\tdta ' + ','.join(items))
        a = e + 1


def main():
    src, outdir = sys.argv[1], sys.argv[2]
    image, ram = load(src)
    # bytes as they are in the file: $2A10-$2A1F is cleared at run time,
    # but the file holds something there
    ram[0x2A10:0x2A20] = image[0x2A10:0x2A20]
    d = Disasm(ram)
    seen = {}
    for name in list(d.labels.values()) + list(S.EQU.values()) + \
            [n for n, _ in S.ARRAYS.values()]:
        if name.upper() in seen and seen[name.upper()] != name:
            sys.exit('label clash (MADS ignores case): %s / %s'
                     % (name, seen[name.upper()]))
        seen[name.upper()] = name

    out = S.PREAMBLE.rstrip('\n').splitlines()
    out.append('')
    out.append('; ---- hardware, OS and RAM outside the program')
    equ = dict(S.EQU)
    equ.update({a + 0x10000: n for a, n in S.EQU_W.items()})
    for key in sorted(equ, key=lambda k: (k & 0xFFFF, k)):
        addr, name = key & 0xFFFF, equ[key]
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
    out.extend(S.FILE_START.rstrip('\n').splitlines())
    out.append('\tdta $%02X' % image[0x21FF])
    out.append('')
    out.extend(S.RELOC_BANNER.rstrip('\n').splitlines())
    out.append('\torg r:$%04X' % RELOC_DST)
    d.emit_range(out, *RELOC)
    out.append('')
    out.append('\torg $%04X' % (RELOC_SRC + RELOC_LEN))
    d.emit_range(out, *MAIN)
    out.append('')
    out.extend(S.FILE_END.rstrip('\n').splitlines())
    open(os.path.join(outdir, 'agent.asm'), 'w').write('\n'.join(out) + '\n')
    print('code bytes: %d, labels: %d' % (sum(d.code.values()), len(d.labels)))


if __name__ == '__main__':
    main()
