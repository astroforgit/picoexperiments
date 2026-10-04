#!/usr/bin/env python3
"""Move bank 7's $CFA1-$D80E out of the Atari I/O area ($D000-$D7FF).

The block becomes a RAM copy at RELOC. References are found by the static
code map (tools/analyze.py) and the coverage trace; each patch is listed
explicitly below and checked, so an unexpected reference fails the build.

Outputs gen/reloc.bin and gen/bank{6,7}-atari.bin.
"""
from pathlib import Path
import contextlib
import io
import json
import sys

sys.path.insert(0, str(Path(__file__).parent))
import analyze  # noqa: E402
from dis6502 import OPS, MODES  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
GEN = ROOT / 'gen'
S, E = 0xCFA1, 0xD80F
RELOC = 0x3000
OFF = RELOC - S

# Word tables inside the block (address of first entry, entries)
TABLES = [(0xD0AD, 4), (0xD0CC, 12), (0xD6DA, 2), (0xD75E, 11),
          (0xD790, 10), (0xD7CB, 10), (0xD7FB, 10)]
# LDA #>ret / PHA / LDA #<ret / PHA pushing a return address inside the block
PUSHES = [(0xD09C, 0xD09F)]
# Calls into the block from outside it: (bank, address of the JSR/JMP)
EXTERNAL = [(7, 0xC438), (7, 0xE5E4), (6, 0xAFE1), (6, 0xB0B9), (6, 0xB122), (6, 0xBC1F)]


def code_map():
    an = analyze.Analyzer()
    trace = GEN / 'trace.json'
    t = json.loads(trace.read_text()) if trace.exists() else {'executed': []}
    with contextlib.redirect_stdout(io.StringIO()):
        for e in [0xFF16, 0xFF3D, 0xE0B1, 0xE0C5, 0xE0FF, 0xE165, 0xD5E0]:
            an.trace(7, e)
        for b, pc in t['executed']:
            an.trace(b, pc)
        for _ in range(6):
            for bank in list(an.tables):
                for (pc, lo, hi) in list(an.tables[bank]):
                    for la, tt in an.table_entries(bank, lo, hi):
                        tb = an.bank_for(bank, tt)
                        if tb in range(8):
                            an.trace(tb, tt)
    return an


def main():
    an = code_map()
    banks = {b: bytearray((GEN / f'bank{b}.bin').read_bytes()) for b in (6, 7)}
    b7 = banks[7]
    rd = lambda a: b7[a - 0xC000]

    block = bytearray(b7[S - 0xC000:E - 0xC000])

    def wr_block(a, v):
        block[a - S] = v

    patched = set()
    # 1. absolute operands inside the block that point into it
    for (b, pc, n, mode, w) in an.refs:
        if b == 7 and S <= pc < E and mode != 'imm' and S <= w < E:
            nw = w + OFF
            wr_block(pc + 1, nw & 0xFF)
            wr_block(pc + 2, nw >> 8)
            patched.add(pc)
    # relative branches must stay inside
    for pc in an.code[7]:
        op = rd(pc)
        if MODES[OPS[op][1]] == 1 and OPS[op][1] == 'rel':
            off = rd(pc + 1)
            tgt = (pc + 2 + (off - 256 if off > 127 else off)) & 0xFFFF
            if (S <= pc < E) != (S <= tgt < E):
                sys.exit(f'branch across the block boundary at ${pc:04x}')
    # 2. word tables
    for start, n in TABLES:
        for i in range(n):
            a = start + 2 * i
            w = rd(a) | rd(a + 1) << 8
            if S <= w < E:
                nw = w + OFF
                wr_block(a, nw & 0xFF)
                wr_block(a + 1, nw >> 8)
    # 3. pushed return addresses
    for hi_at, lo_at in PUSHES:
        assert rd(hi_at - 1) == 0xA9 and rd(lo_at - 1) == 0xA9
        w = rd(hi_at) << 8 | rd(lo_at)
        assert S <= w < E
        nw = w + OFF
        wr_block(hi_at, nw >> 8)
        wr_block(lo_at, nw & 0xFF)
    # 4. calls from outside
    for b, at in EXTERNAL:
        data = banks[b]
        base = 0xC000 if b == 7 else 0x8000
        op = data[at - base]
        w = data[at - base + 1] | data[at - base + 2] << 8
        assert op in (0x20, 0x4C) and S <= w < E, f'unexpected bytes at {b}:{at:04x}'
        nw = w + OFF
        data[at - base + 1] = nw & 0xFF
        data[at - base + 2] = nw >> 8
    # every reference found by the code map must be one of the above
    for (b, pc, n, mode, w) in an.refs:
        if mode != 'imm' and S <= w < E and not (b == 7 and S <= pc < E):
            if (b, pc) not in EXTERNAL:
                sys.exit(f'unhandled reference to ${w:04x} at bank {b} ${pc:04x}')
    for (b, pc, n, mode, v) in an.refs:
        if mode == 'imm' and b == 7 and S <= pc < E and 0xCF <= v <= 0xD8:
            if pc + 1 not in [h for h, _ in PUSHES]:
                sys.exit(f'unhandled immediate #${v:02x} at ${pc:04x}')
    # data bytes of the block that look like pointers into it, but are not patched
    data_bytes = [a for a in range(S, E) if a not in an.owned[7]]
    in_tables = {start + i for start, n in TABLES for i in range(2 * n)}
    for a in data_bytes:
        if a in in_tables or a + 1 >= E:
            continue
        w = rd(a) | rd(a + 1) << 8
        if S + 0x5F <= w < E and (a + 1) not in an.owned[7]:
            print(f'note: data word ${w:04x} at ${a:04x} left unchanged')
    # wait loops: FC80 (wait for the next NMI) and LDA $0107 / BNE spins
    from translate import vector
    b7 = banks[7]
    assert b7[0xFC80 - 0xC000] == 0x48, 'FC80 moved'
    w = vector('wait_vblank')
    b7[0xFC80 - 0xC000:0xFC83 - 0xC000] = bytes([0x4C, w & 0xFF, w >> 8])
    w = vector('idle_spin')
    for at in (0xE656, 0xE79D, 0xE87D):
        assert bytes(b7[at - 0xC000:at - 0xC000 + 5]) == bytes([0xAD, 0x07, 0x01, 0xD0, 0xFB]), hex(at)
        b7[at - 0xC000:at - 0xC000 + 5] = bytes([0x20, w & 0xFF, w >> 8, 0xEA, 0xEA])
    (GEN / 'reloc.bin').write_bytes(block)
    for b, data in banks.items():
        (GEN / f'bank{b}-atari.bin').write_bytes(data)
    print(f'relocated ${S:04x}-${E - 1:04x} to ${RELOC:04x}: {len(patched)} operands, '
          f'{len(TABLES)} tables, {len(EXTERNAL)} external calls')


if __name__ == '__main__':
    main()
