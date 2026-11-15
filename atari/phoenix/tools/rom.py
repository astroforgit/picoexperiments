"""Extract the arcade program ROM (16 KB) from the Amiga port's game_rom.68k."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
AMIGA = ROOT / "src" / "phoenix-main"


def load_rom():
    data = bytearray()
    skip = False      # take the Amiga branch ("PRESS FIRE" instead of "INSERT COIN")
    for line in (AMIGA / "src" / "game_rom.68k").read_text().splitlines():
        line = line.split("|")[0].strip()
        if line.startswith(".else"):
            skip = True
        elif line.startswith(".endif"):
            skip = False
        elif line.startswith(".byte") and not skip:
            data += bytes(int(v, 16) for v in re.findall(r"0x([0-9a-fA-F]+)", line))
    data += b"\x08" * (0x4000 - len(data))   # last byte missing from game_rom.68k
    assert len(data) == 0x4000, hex(len(data))
    return bytes(data)


def z80_labels():
    """Label names from the commented Z80 disassembly, keyed by address."""
    labels = {}
    lines = (AMIGA / "src" / "phoenix_z80.asm").read_text().splitlines()
    for i, line in enumerate(lines):
        m = re.match(r"^([A-Za-z_][A-Za-z_0-9]*):\s*$", line)
        if not m:
            continue
        for nxt in lines[i + 1:i + 6]:
            a = re.match(r"^([0-9A-F]{4}):", nxt)
            if a:
                labels.setdefault(int(a.group(1), 16), m.group(1))
                break
    return labels


if __name__ == "__main__":
    rom = load_rom()
    (ROOT / "gen" / "phoenix.rom").write_bytes(rom)
    labs = z80_labels()
    print(len(rom), "bytes,", len(labs), "labels")
