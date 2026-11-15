#!/usr/bin/env python3
"""Build phoenix.xex: translate -> data -> runtime (MADS) -> loader -> XEX."""
from pathlib import Path
import json
import os
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
GEN = ROOT / "gen"
ASM = ROOT / "asm"
TOOLS = ROOT / "tools"
MADS = os.environ.get("MADS", "mads")
OUT = ROOT / "phoenix.xex"

V_FGT, V_BGT, V_STAGE = 0x40000, 0x44000, 0x50000
STAGE = 0x8000


def run(*cmd, cwd=ROOT, check=True):
    r = subprocess.run([str(c) for c in cmd], cwd=cwd, capture_output=True, text=True)
    if check and (r.returncode or "ERROR" in r.stdout):
        sys.exit(f'{" ".join(map(str, cmd))} failed:\n{r.stdout[-4000:]}{r.stderr}')
    return r


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
        s = int.from_bytes(data[p:p + 2], "little"); p += 2
        if s == 0xFFFF:
            continue
        e = int.from_bytes(data[p:p + 2], "little"); p += 2
        segs.append((s, data[p:p + e - s + 1])); p += e - s + 1
    return segs


def seg(start, data):
    return start.to_bytes(2, "little") + (start + len(data) - 1).to_bytes(2, "little") + bytes(data)


def assemble_runtime():
    """Assemble; out-of-range branches in game.asm become long branches."""
    lb = GEN / "longbranch.json"
    long = set(json.loads(lb.read_text())) if lb.exists() else set()
    for _ in range(30):
        r = run(MADS, "runtime.asm", "-o:../gen/runtime.obx", "-l:../gen/runtime.lst",
                "-t:../gen/runtime.lab", cwd=ASM, check=False)
        hits = re.findall(r"game\.asm \((\d+)\) ERROR: Branch out of range", r.stdout)
        if not hits:
            if r.returncode or "ERROR" in r.stdout:
                sys.exit("mads failed:\n" + r.stdout[-4000:])
            return r.stdout
        lines = (GEN / "game.asm").read_text().split("\n")
        for h in hits:
            m = re.search(r"; (b\d+)", lines[int(h) - 1])
            long.add(m.group(1))
        lb.write_text(json.dumps(sorted(long)))
        run(sys.executable, TOOLS / "translate.py")
    sys.exit("long branch fixing did not converge")


def vbxe_sites():
    """Operand high bytes of every absolute access to $D640-$D65F."""
    sites = []
    for line in (GEN / "runtime.lst").read_text().splitlines():
        m = re.match(r"\s*\d+\s+([0-9A-F]{4})\s+([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2})\s", line)
        if m and m.group(4) == "D6" and 0x40 <= int(m.group(3), 16) <= 0x5F:
            sites.append(int(m.group(1), 16) + 2)
    return sites


def main():
    # the arcade variant (no gameplay changes) is for tools/lockstep.py
    os.environ["PHOENIX_VARIANT"] = "arcade"
    build(GEN / "phoenix-arcade.xex")
    os.environ["PHOENIX_VARIANT"] = "amiga"
    build(OUT)


def build(out_path):
    run(sys.executable, TOOLS / "translate.py")
    run(sys.executable, TOOLS / "make_data.py")
    run(sys.executable, TOOLS / "make_sound.py")
    (GEN / "vbxe_sites.asm").write_text("")
    assemble_runtime()
    sites = vbxe_sites()
    (GEN / "vbxe_sites.asm").write_text("".join(f"        dta a(${a:04X})\n" for a in sites))
    out = assemble_runtime()
    assert vbxe_sites() == sites
    print("\n".join(l.strip() for l in out.splitlines() if "end:" in l))
    lab = labels(GEN / "runtime.lab")

    ram = bytearray(0x10000)
    for s, d in xex_segments((GEN / "runtime.obx").read_bytes()):
        assert s >= 0x6000, f"runtime segment ${s:04x}"
        ram[s:s + len(d)] = d
    rom = (GEN / "phoenix.rom").read_bytes()
    ram[0x0400:0x4000] = rom[0x0400:0x4000]

    (GEN / "boot-defs.asm").write_text(f"RT_START = ${lab['START']:04x}\n")
    run(MADS, "boot.asm", "-o:../gen/boot.obx", "-l:../gen/boot.lst", "-t:../gen/boot.lab", cwd=ASM)
    boot = xex_segments((GEN / "boot.obx").read_bytes())
    blab = labels(GEN / "boot.lab")

    payloads = [(V_FGT, (GEN / "fgtiles.bin").read_bytes()),
                (V_BGT, (GEN / "bgtiles.bin").read_bytes())]
    for lo, hi in ((0x0000, 0x4000), (0x6000, 0xD000), (0xD000, 0x10000)):
        payloads.append((V_STAGE + lo, bytes(ram[lo:hi])))

    x = bytearray(b"\xff\xff")
    loader = [(s, d) for s, d in boot if s >= 0x9000]
    starter = [(s, d) for s, d in boot if s < 0x9000]
    for s, d in loader:
        x += seg(s, d)
    x += seg(0x2E2, blab["DETECT"].to_bytes(2, "little"))
    chunks = 0
    for vaddr, data in payloads:
        for off in range(0, len(data), 0x1000):
            part = data[off:off + 0x1000]
            if not any(part):
                continue
            a = vaddr + off
            hdr = bytes([a & 0xFF, (a >> 8) & 0xFF, a >> 16])
            x += seg(STAGE - 3, hdr + part.ljust(0x1000, b"\0"))
            x += seg(0x2E2, blab["UPLOAD"].to_bytes(2, "little"))
            chunks += 1
    for s, d in starter:
        x += seg(s, d)
    x += seg(0x2E0, blab["STARTER"].to_bytes(2, "little"))
    out_path.write_bytes(x)
    (GEN / f"{out_path.stem}.lab").write_text((GEN / "runtime.lab").read_text())
    print(f"{out_path.name}: {len(x)} bytes, {chunks} VRAM chunks, {len(sites)} VBXE register sites")


if __name__ == "__main__":
    main()
