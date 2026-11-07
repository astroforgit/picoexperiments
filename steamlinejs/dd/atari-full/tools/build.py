#!/usr/bin/env python3
"""Build double-dragon.xex.

translate -> data tables -> relocation -> runtime image -> loader -> XEX.
"""
from pathlib import Path
import hashlib
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
GEN = ROOT / 'gen'
SRC = ROOT / 'src'
TOOLS = ROOT / 'tools'
MADS = os.environ.get('MADS', 'mads')
OUT = ROOT / 'double-dragon.xex'

# VRAM placement (see src/defs.asm)
V_PRG, V_CHRIDX, V_CHRRAW = 0x00000, 0x60000, 0x64000
V_RAMIMG, V_BANK7, V_SVCIMG = 0x40000, 0x44000, 0x48000
STAGE = 0x8000


def run(*cmd, cwd=ROOT):
    r = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if r.returncode or 'ERROR' in r.stdout:
        sys.exit(f'{" ".join(map(str, cmd))} failed:\n{r.stdout}{r.stderr}')
    return r.stdout


def labels(path):
    out = {}
    for line in Path(path).read_text().splitlines():
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


def main():
    run(sys.executable, TOOLS / 'translate.py')
    run(sys.executable, TOOLS / 'make_data.py')
    print(run(sys.executable, TOOLS / 'relocate.py').strip())
    out = run(MADS, 'runtime.asm', '-o:../gen/runtime.obx', '-l:../gen/runtime.lst',
              '-t:../gen/runtime.lab', cwd=SRC)
    print('\n'.join(l for l in out.splitlines() if 'end:' in l))
    ram = bytearray(0x8000)
    for s, d in xex_segments((GEN / 'runtime.obx').read_bytes()):
        assert 0x0A00 <= s and s + len(d) <= 0x8000, f'runtime segment ${s:04x}'
        ram[s:s + len(d)] = d
    svc_end = max(s + len(d) for s, d in xex_segments((GEN / 'runtime.obx').read_bytes()))
    assert svc_end > 0x4000
    lab = labels(GEN / 'runtime.lab')
    (GEN / 'boot-defs.asm').write_text(f'RT_START = ${lab["START"]:04x}\n')
    run(MADS, 'boot-main.asm', '-o:../gen/boot.obx', '-l:../gen/boot.lst', '-t:../gen/boot.lab', cwd=SRC)
    boot = xex_segments((GEN / 'boot.obx').read_bytes())
    blab = labels(GEN / 'boot.lab')

    payloads = []
    for b in range(7):
        name = 'bank6-atari.bin' if b == 6 else f'bank{b}.bin'
        payloads.append((V_PRG + b * 0x4000, (GEN / name).read_bytes()))
    payloads.append((V_CHRIDX, (GEN / 'chr_index.bin').read_bytes()))
    payloads.append((V_CHRRAW, (GEN / 'chr_raw.bin').read_bytes()))
    payloads.append((V_RAMIMG + 0x0000, bytes(ram[:0x4000])))
    payloads.append((V_SVCIMG, bytes(ram[0x4000:svc_end])))
    payloads.append((V_BANK7, (GEN / 'bank7-atari.bin').read_bytes()))

    x = bytearray(b'\xff\xff')
    for s, d in boot:
        x += seg(s, d)
    x += seg(0x2E2, blab['DETECT'].to_bytes(2, 'little'))
    chunks = 0
    for vaddr, data in payloads:
        for off in range(0, len(data), 0x1000):
            part = data[off:off + 0x1000]
            a = vaddr + off
            hdr = bytes([a & 0xFF, (a >> 8) & 0xFF, a >> 16])
            x += seg(STAGE - 3, hdr + part.ljust(0x1000, b'\0'))
            x += seg(0x2E2, blab['UPLOAD'].to_bytes(2, 'little'))
            chunks += 1
    x += seg(0x2E0, blab['STARTER'].to_bytes(2, 'little'))
    OUT.write_bytes(x)
    (ROOT / 'double-dragon.sha256').write_text(
        hashlib.sha256(x).hexdigest() + '  double-dragon.xex\n')
    print(f'{OUT.name}: {len(x)} bytes, {chunks} VRAM chunks')


if __name__ == '__main__':
    main()
