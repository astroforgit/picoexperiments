#!/usr/bin/env python3
"""Build gng.xex (Ghosts'n Goblins Arcade, Atari XL/XE + VBXE).

Inputs (all derived from the D64 and kept in gen/ so a build is quick):
  disk/*.prg          the disk files (tools/d64.py)
  gen/loads.json      what each file writes when loaded (tools/extract.py)
  gen/entry.snap      the C64 state at JMP $0800 (tools/gng.py)
  gen/codemap.json    code map and I/O references (tools/codemap.py, which
                      reads the coverage runs gen/cov-*.json)
Steps: patches and stubs -> runtime assembly -> RAM image -> VRAM payload
-> XEX.
"""
import hashlib
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from dis6502 import OPS, MODES  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GEN = os.path.join(ROOT, 'gen')
SRC = os.path.join(ROOT, 'src')
DISK = os.path.join(ROOT, 'disk')
MADS = os.environ.get('MADS', 'mads')
OUT = os.path.join(ROOT, 'gng.xex')

V_STAGE, V_RTIMG, V_VIC, V_FILES, V_SAVE = 0x00000, 0x10000, 0x68000, 0x6CA00, 0x6C800
VRAM_END = 0x80000
STAGE = 0x8000
# files the Atari loads at run time (08 intro, 09 main and 0A menu are in the RAM image)
RUNTIME_FILES = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x0B, 0x0C,
                 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12]
CODE_UNITS = ['06', '0D', '0E', '0F', '10', '11', '12']


def run(*cmd, cwd=ROOT):
    r = subprocess.run([str(c) for c in cmd], cwd=cwd, capture_output=True, text=True)
    if r.returncode or 'ERROR' in r.stdout or 'Error' in r.stdout:
        sys.exit(f'{" ".join(map(str, cmd))} failed:\n{r.stdout}{r.stderr}')
    return r.stdout


def assemble(src, *opts):
    """MADS, turning out-of-range short branches into long ones (jeq...)."""
    for _ in range(40):
        r = subprocess.run([MADS, src, *opts], cwd=SRC, capture_output=True, text=True)
        hits = re.findall(r'^(\S+\.asm) \((\d+)\) ERROR: Branch out of range', r.stdout, re.M)
        if not hits:
            if r.returncode or 'ERROR' in r.stdout:
                sys.exit(f'mads {src} failed:\n{r.stdout}{r.stderr}')
            return r.stdout
        for name, line in set(hits):
            path = os.path.join(SRC, name)
            lines = open(path).read().split('\n')
            i = int(line) - 1
            lines[i] = re.sub(r'\b(beq|bne|bcc|bcs|bmi|bpl|bvc|bvs)\b', lambda m: 'j' + m.group(1)[1:],
                              lines[i], count=1)
            open(path, 'w').write('\n'.join(lines))
    sys.exit('mads: branches did not settle')


def labels(path):
    out = {}
    for line in open(path).read().splitlines():
        p = line.split()
        if len(p) == 3:
            try:
                out[p[2].upper()] = int(p[1], 16)
            except ValueError:
                pass
    return out


def xex_segments(data):
    p, segs = 0, []
    while p < len(data):
        s = int.from_bytes(data[p:p + 2], 'little'); p += 2
        if s == 0xFFFF:
            continue
        e = int.from_bytes(data[p:p + 2], 'little'); p += 2
        segs.append((s, data[p:p + e - s + 1])); p += e - s + 1
    return segs


def seg(start, data):
    return start.to_bytes(2, 'little') + (start + len(data) - 1).to_bytes(2, 'little') + bytes(data)


def evaluate(expr, lab):
    v = 0
    for term in expr.split('+'):
        term = term.strip()
        if term.startswith('$'):
            v += int(term[1:], 16)
        elif term.isdigit():
            v += int(term)
        else:
            v += lab[term.upper()]
    return v


def resolve(patch_bytes, lab):
    out = []
    for b in patch_bytes:
        if isinstance(b, int):
            out.append(b)
        elif b.startswith('<'):
            out.append(evaluate(b[1:], lab) & 0xFF)
        elif b.startswith('>'):
            out.append(evaluate(b[1:], lab) >> 8 & 0xFF)
        else:
            raise ValueError(b)
    return out


def patch_table(patches, lab):
    """Records (lo, hi, len, bytes) merged into runs, then lo, hi, 0."""
    out = bytearray()
    runs = []
    for a, b in sorted(patches):
        b = resolve(b, lab)
        if runs and runs[-1][0] + len(runs[-1][1]) == a and len(runs[-1][1]) + len(b) < 256:
            runs[-1][1].extend(b)
        else:
            runs.append([a, list(b)])
    for a, b in runs:
        out += bytes([a & 0xFF, a >> 8, len(b)]) + bytes(b)
    return bytes(out + b'\0\0\0')


BANKS = ['BANK_INIT', 'BANK_IDLE', 'BANK_SPLIT', 'BANK_COMP', 'BANK_SPR']
BANK_MEMS = [0xFA, 0xFB, 0xFC, 0xFD, 0xFF]       # MEMAC-A values ($80 | 4K bank)


def vbx_operands(lst_path):
    """(address of the high byte, MEMAC-A bank or 0) of absolute VBXE register operands."""
    out = []
    pat = re.compile(r'^\s*\d+\s+([0-9A-F]{4})\s+((?:[0-9A-F]{2} ?)+)')
    bank = 0
    for line in open(lst_path, errors='replace').read().splitlines():
        for i, name in enumerate(BANKS):
            if re.search(r'\b' + name + r'\b', line, re.I) and not line.strip().startswith(';'):
                bank = BANK_MEMS[i]
        m = pat.match(line)
        if not m:
            continue
        addr = int(m.group(1), 16)
        b = [int(x, 16) for x in m.group(2).split()]
        if len(b) == 3 and b[0] in OPS and MODES[OPS[b[0]][1]] == 2 and b[2] == 0xD6 and 0x40 <= b[1] < 0x60:
            out.append((addr + 2, bank if addr >= 0xE000 else 0))
    return out


def check_banks(lst_path):
    """Fail on absolute operands that name a label of another code bank."""
    pat = re.compile(r'^\s*\d+\s+([0-9A-F]{4})\s+((?:[0-9A-F]{2} ?)+)\s*(.*)$')
    lines = open(lst_path, errors='replace').read().splitlines()
    owner, bank, parsed = {}, None, []
    for line in lines:
        for i, name in enumerate(BANKS):
            if re.match(r'^\s*\d+\s+E000\s+' + name + r'\b', line, re.I) or \
               re.match(r'^\s*\d+\s+' + name + r'\b', line, re.I):
                bank = i
        m = pat.match(line)
        if not m:
            continue
        addr = int(m.group(1), 16)
        src = m.group(3).split(';')[0]
        if addr >= 0xE000 and bank is not None:
            lm = re.match(r'^([A-Za-z_][A-Za-z_0-9]*)', src)
            if lm:
                owner.setdefault(lm.group(1).upper(), bank)
            parsed.append((bank, addr, [int(x, 16) for x in m.group(2).split()], src))
    bad = []
    for bank, addr, b, src in parsed:
        if len(b) == 3 and b[0] in OPS and MODES[OPS[b[0]][1]] == 2:
            w = b[1] | b[2] << 8
            if 0xE000 <= w < 0xF000:
                parts = src.split(None, 2)
                operand = parts[-1] if parts else ''
                for ident in re.findall(r'[A-Za-z_][A-Za-z_0-9]*', operand):
                    ob = owner.get(ident.upper())
                    if ob is not None and ob != bank:
                        bad.append(f'{BANKS[bank]} ${addr:04X}: {src.strip()} -> {BANKS[ob]}')
    if bad:
        sys.exit('cross-bank references:\n' + '\n'.join(bad))


def sound_tables():
    k8 = 63337 / (2 * 985248 / 16777216)
    rcp = [round(k8 / (m + 0.5)) for m in range(128, 256)]
    att = [2, 8, 16, 24, 38, 56, 68, 80, 100, 250, 500, 800, 1000, 3000, 5000, 8000]
    ainc = [min(0xFFFF, round(255 * 20 * 256 / t)) for t in att]
    dinc = [min(0xFFFF, round(255 * 20 * 256 / (3 * t))) for t in att]
    lines = ['; generated by tools/build.py']
    for name, vals in (('rcp', rcp), ('ainc', ainc), ('dinc', dinc)):
        for part, f in (('lo', lambda v: v & 255), ('hi', lambda v: v >> 8)):
            lines.append(f'{name}_{part}')
            for i in range(0, len(vals), 16):
                lines.append('        dta ' + ','.join(f'${f(v):02X}' for v in vals[i:i + 16]))
    return '\n'.join(lines) + '\n'


def main():
    sys.path.insert(0, os.path.join(ROOT, 'tools'))
    import gng
    for need in ('loads.json', 'codemap.json'):
        if not os.path.exists(os.path.join(GEN, need)):
            sys.exit(f'gen/{need} missing: run tools/extract.py, tools/coverage.py and tools/codemap.py')
    g = gng.Game(verbose=False, snapshot=gng.entry_snapshot())
    entry = bytearray(g.mem.ram)
    open(os.path.join(GEN, 'entry.bin'), 'wb').write(bytes(entry))
    print(run(sys.executable, os.path.join(ROOT, 'tools', 'patch.py')).strip().splitlines()[-1])
    plist = json.load(open(os.path.join(GEN, 'patchlist.json')))

    # ---- VRAM placement of the files and patch tables (sizes only)
    files = {n: open(os.path.join(DISK, f'{n:02X}.GA.prg'), 'rb').read() for n in RUNTIME_FILES}
    place = {}
    a = V_FILES
    for n in RUNTIME_FILES:
        place[n] = a
        a += len(files[n])
    ptab_size = {u: 3 + sum(3 + len(b) for _, b in plist[u]) for u in CODE_UNITS}   # upper bound
    pplace = {}
    for u in CODE_UNITS:
        pplace[int(u, 16)] = a
        a += ptab_size[u]
    assert a <= 0x7A000, f'VRAM files end ${a:05X} (code banks from $7A000)'
    print(f'files and patch tables: ${V_FILES:05X}-${a:05X}')

    def win(addr):
        return 0x80 | addr >> 14, 0x4000 + (addr & 0x3FFF)

    fl = ['; generated by tools/build.py: the disk directory (file id 0-$12)']
    cols = {k: [] for k in ('fd_bank', 'fd_lo', 'fd_hi', 'fd_len_lo', 'fd_len_hi', 'fp_bank', 'fp_lo', 'fp_hi')}
    for n in range(0x13):
        if n in place:
            bk, w = win(place[n])
            cols['fd_bank'].append(bk); cols['fd_lo'].append(w & 255); cols['fd_hi'].append(w >> 8)
            cols['fd_len_lo'].append(len(files[n]) & 255); cols['fd_len_hi'].append(len(files[n]) >> 8)
        else:
            for k in ('fd_bank', 'fd_lo', 'fd_hi', 'fd_len_lo', 'fd_len_hi'):
                cols[k].append(0)
        if n in pplace:
            bk, w = win(pplace[n])
            cols['fp_bank'].append(bk); cols['fp_lo'].append(w & 255); cols['fp_hi'].append(w >> 8)
        else:
            cols['fp_bank'].append(0); cols['fp_lo'].append(0); cols['fp_hi'].append(0)
    for k, v in cols.items():
        fl.append(f'{k:10}dta ' + ','.join(f'${x:02X}' for x in v))
    open(os.path.join(GEN, 'files.asm'), 'w').write('\n'.join(fl) + '\n')
    cpu = g.cpu
    open(os.path.join(GEN, 'entry.asm'), 'w').write(
        f'ENTRY_PC = ${cpu.pc:04X}\nENTRY_SP = ${cpu.sp:02X}\nENTRY_P = ${cpu.p | 0x24:02X}\n'
        f'ENTRY_A = ${cpu.a:02X}\nENTRY_X = ${cpu.x:02X}\nENTRY_Y = ${cpu.y:02X}\n')
    open(os.path.join(GEN, 'sound-tables.asm'), 'w').write(sound_tables())

    # ---- runtime
    out = assemble('runtime.asm', '-o:../gen/runtime.obx', '-l:../gen/runtime.lst',
                   '-t:../gen/runtime.lab')
    print('\n'.join(l.strip() for l in out.splitlines() if 'end:' in l or 'vars' in l))
    lab = labels(os.path.join(GEN, 'runtime.lab'))
    check_banks(os.path.join(GEN, 'runtime.lst'))
    rt = bytearray(0x3000)                   # image of $C000-$EFFF (code A)
    banks = []                               # images of the MEMAC-A code banks
    ram = bytearray(entry)
    ram[0xDC00:0xE000] = bytes(0x400)        # CIA RAM, variables, chip shadows
    for s, d in xex_segments(open(os.path.join(GEN, 'runtime.obx'), 'rb').read()):
        if 0xC300 <= s < 0xD000:
            assert s + len(d) <= 0xD000, f'segment ${s:04X}'
            rt[s - 0xC000:s - 0xC000 + len(d)] = d
        elif 0xE000 <= s < 0xF000:
            if s == 0xE000:
                banks.append(bytearray(0x1000))
            assert s + len(d) <= 0xF000, f'segment ${s:04X}'
            banks[-1][s - 0xE000:s - 0xE000 + len(d)] = d
        elif 0xDC10 <= s < 0xE000:
            ram[s:s + len(d)] = d             # variables with initial values
        else:
            sys.exit(f'runtime segment at ${s:04X}')
    rel = vbx_operands(os.path.join(GEN, 'runtime.lst'))
    vr = lab['VBX_RELOC']
    assert len(banks) == len(BANKS), len(banks)
    tab = b''.join(a.to_bytes(2, 'little') + bytes([bk]) for a, bk in rel) + b'\0\0\0'
    assert vr + len(tab) <= 0xD000, f'VBXE relocation table too long ({len(rel)})'
    rt[vr - 0xC000:vr - 0xC000 + len(tab)] = tab
    print(f'VBXE operands: {len(rel)}')

    # ---- RAM image of the C64 program at its entry point
    for a, b in plist['entry']:
        b = resolve(b, lab)
        ram[a:a + len(b)] = bytes(b)
    ram[0xD800:0xDC00] = bytes(g.colram)
    ram[0xDC00:0xDC10] = bytes(16)
    ram[0xDC00] = 0xFF
    ram[0xDC02] = 0xFF
    ram[0xDD00:0xDD10] = bytes(16)
    ram[0xDD00] = g.cia2.regs[0] & 0x3F | 0x00
    ram[0xDD02] = 0x3F
    ram[0xDE00:0xDE40] = bytes(g.vic)
    ram[0xDF00:0xDF20] = bytes(g.sid)
    vic_image = bytes(entry[0xC000:0x10000])

    # ---- VRAM payload
    payload = [(V_STAGE, bytes(ram)), (V_RTIMG, bytes(rt)), (V_VIC, vic_image)]
    for i, b in enumerate(banks):
        payload.append(((BANK_MEMS[i] & 0x7F) << 12, bytes(b)))
    for n in RUNTIME_FILES:
        payload.append((place[n], files[n]))
    for u in CODE_UNITS:
        t = patch_table(plist[u], lab)
        assert len(t) <= ptab_size[u]
        payload.append((pplace[int(u, 16)], t))
    blob = {}
    for addr, data in payload:
        for i, v in enumerate(data):
            blob[addr + i] = v
    chunks = sorted({a >> 12 for a in blob})
    open(os.path.join(GEN, 'boot-defs.asm'), 'w').write(f'RT_BOOT = ${lab["RT_BOOT"]:04X}\n')
    assemble('boot.asm', '-o:../gen/boot.obx', '-l:../gen/boot.lst', '-t:../gen/boot.lab')
    blab = labels(os.path.join(GEN, 'boot.lab'))
    x = bytearray(b'\xff\xff')
    for s, d in xex_segments(open(os.path.join(GEN, 'boot.obx'), 'rb').read()):
        x += seg(s, d)
    x += seg(0x2E2, blab['DETECT'].to_bytes(2, 'little'))
    for c in chunks:
        a = c << 12
        part = bytes(blob.get(a + i, 0) for i in range(0x1000))
        hdr = bytes([a & 0xFF, (a >> 8) & 0xFF, a >> 16])
        x += seg(STAGE - 3, hdr + part)
        x += seg(0x2E2, blab['UPLOAD'].to_bytes(2, 'little'))
    x += seg(0x2E0, blab['STARTER'].to_bytes(2, 'little'))
    open(OUT, 'wb').write(x)
    open(os.path.join(ROOT, 'gng.sha256'), 'w').write(hashlib.sha256(x).hexdigest() + '  gng.xex\n')
    print(f'{os.path.basename(OUT)}: {len(x)} bytes, {len(chunks)} VRAM chunks')


if __name__ == '__main__':
    main()
