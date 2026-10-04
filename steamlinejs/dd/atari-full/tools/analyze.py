#!/usr/bin/env python3
"""Static code map of the translated banks (recursive descent).

Finds code reachable from known entry points, including jump tables of the
forms used by the game, and reports every reference into a given range.
"""
from collections import defaultdict
from pathlib import Path
import json
import sys

sys.path.insert(0, str(Path(__file__).parent))
from dis6502 import OPS, MODES, length  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
GEN = ROOT / 'gen'


class Bank:
    def __init__(self, n):
        self.n = n
        self.base = 0xC000 if n == 7 else 0x8000
        self.data = (GEN / f'bank{n}.bin').read_bytes()

    def has(self, a):
        return self.base <= a < self.base + 0x4000

    def __getitem__(self, a):
        return self.data[a - self.base]


class Analyzer:
    def __init__(self):
        self.banks = [Bank(i) for i in range(8)]
        self.code = defaultdict(set)      # bank -> instruction start addresses
        self.owned = defaultdict(set)     # bank -> every byte belonging to an instruction
        self.refs = []                    # (bank, pc, mode, operand)
        self.tables = defaultdict(set)    # bank -> table descriptors
        self.external = set()             # bank-7 calls into $8000-$BFFF
        self.problems = []

    def bank_for(self, src_bank, target):
        if target >= 0xC000:
            return 7
        if 0x8000 <= target < 0xC000:
            return None if src_bank == 7 else src_bank
        return 'ram'

    def trace(self, bank, start):
        work = [start]
        b = self.banks[bank]
        while work:
            pc = work.pop()
            while True:
                if not b.has(pc) or pc in self.code[bank]:
                    break
                op = b[pc]
                if op not in OPS:
                    self.problems.append((bank, pc, f'invalid opcode ${op:02x}'))
                    break
                n, mode = OPS[op]
                ln = length(op)
                for i in range(ln):
                    if pc + i in self.owned[bank] and pc not in self.code[bank]:
                        self.problems.append((bank, pc, 'overlapping instruction'))
                self.code[bank].add(pc)
                for i in range(ln):
                    self.owned[bank].add(pc + i)
                w = b[pc + 1] | (b[pc + 2] << 8) if ln == 3 else None
                if mode in ('abs', 'abx', 'aby', 'ind'):
                    self.refs.append((bank, pc, n, mode, w))
                if mode == 'imm':
                    self.refs.append((bank, pc, n, mode, b[pc + 1]))
                if mode == 'rel':
                    off = b[pc + 1]
                    tgt = (pc + 2 + (off - 256 if off > 127 else off)) & 0xFFFF
                    work.append(tgt)
                if n == 'jsr' or (n == 'jmp' and mode == 'abs'):
                    tb = self.bank_for(bank, w)
                    if tb == bank:
                        work.append(w)
                    elif tb == 7:
                        self.trace(7, w) if bank != 7 else work.append(w)
                    elif tb is None:
                        self.external.add(w)
                if n == 'jmp' and mode == 'ind':
                    self.indirect_table(bank, pc, w)
                if n in ('rts', 'rti', 'brk') or n == 'jmp':
                    break
                pc += ln

    def indirect_table(self, bank, pc, ptr):
        """Look back for LDA tbl,Y / STA ptr / LDA tbl2,Y / STA ptr+1."""
        b = self.banks[bank]
        found = {}
        a = pc - 1
        steps = 0
        # walk back over a short window of plausible instructions
        cands = []
        for back in range(3, 40):
            q = pc - back
            if q < b.base:
                break
            op = b[q]
            if op in (0xB9, 0xBD) and q + 3 < pc:
                st = b[q + 3]
                if st == 0x85 and b[q + 4] in (ptr & 0xFF, (ptr + 1) & 0xFF):
                    cands.append((b[q + 4] - (ptr & 0xFF), b[q + 1] | b[q + 2] << 8, q))
        lo = [c for c in cands if c[0] == 0]
        hi = [c for c in cands if c[0] == 1]
        if lo and hi:
            lo_t = max(lo, key=lambda c: c[2])[1]
            hi_t = max(hi, key=lambda c: c[2])[1]
            self.tables[bank].add((pc, lo_t, hi_t))
        else:
            self.problems.append((bank, pc, f'indirect jump via ${ptr:04x}: table not found'))

    def table_entries(self, bank, lo_t, hi_t, limit=64):
        """Read entries until the table runs into code or yields an implausible target."""
        b = self.banks[bank]
        out = []
        step = 2 if hi_t == lo_t + 1 else 1
        stop = 0x10000
        for i in range(limit):
            la, ha = lo_t + i * step, hi_t + i * step
            if not (b.has(la) and b.has(ha)):
                break
            if la in self.code[bank] or ha in self.code[bank] or max(la, ha) >= stop:
                break
            t = b[la] | b[ha] << 8
            out.append((la, t))
            if t > max(lo_t, hi_t):
                stop = min(stop, t)
        return out


def main():
    an = Analyzer()
    b7 = an.banks[7]
    entries = [0xFF16, 0xFF3D, 0xE0B1, 0xE0C5, 0xE0FF, 0xE165]
    trace = GEN / 'trace.json'
    traced = defaultdict(set)
    if trace.exists():
        for bk, pc in json.loads(trace.read_text())['executed']:
            traced[bk].add(pc)
    for e in entries:
        an.trace(7, e)
    # follow jump tables until nothing new appears
    for _ in range(10):
        before = sum(len(v) for v in an.code.values())
        for bank in list(an.tables):
            for (pc, lo, hi) in list(an.tables[bank]):
                for la, t in an.table_entries(bank, lo, hi):
                    tb = an.bank_for(bank, t)
                    if tb == bank or tb == 7:
                        an.trace(tb, t)
        for bk, pcs in traced.items():
            for pc in pcs:
                an.trace(bk, pc)
        if sum(len(v) for v in an.code.values()) == before:
            break
    print('code instructions per bank:', {k: len(v) for k, v in sorted(an.code.items())})
    print('external calls from bank 7 into $8000-$BFFF:', ' '.join(f'{a:04x}' for a in sorted(an.external)))
    print('jump tables:')
    for bank in sorted(an.tables):
        for pc, lo, hi in sorted(an.tables[bank]):
            ents = an.table_entries(bank, lo, hi)
            print(f'  bank {bank} jmp at {pc:04x}: lo {lo:04x} hi {hi:04x} n={len(ents)}')
    for p in an.problems[:50]:
        print('problem', p)
    if traced:
        for bk, pcs in sorted(traced.items()):
            missing = [pc for pc in pcs if pc not in an.code[bk]]
            print(f'bank {bk}: {len(pcs)} traced, {len(missing)} not in static map')
    return an


if __name__ == '__main__':
    main()
