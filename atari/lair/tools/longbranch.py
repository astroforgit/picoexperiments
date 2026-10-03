#!/usr/bin/env python3
"""Assemble; turn out-of-range short branches into MADS long branches."""
import re, subprocess, sys
from pathlib import Path
here = Path(__file__).resolve().parent.parent
for _ in range(20):
    out = subprocess.run(['mads', 'lair.asm', '-o:lair.xex', '-t:lair.lab', '-l:lair.lst'],
                         cwd=here, capture_output=True, text=True).stdout
    hits = re.findall(r'^(\S+\.asm) \((\d+)\) ERROR: Branch out of range', out, re.M)
    if not hits:
        print(out[-3000:]); sys.exit(0)
    for name, line in set(hits):
        path = next(p for p in [here / name, here / 'src' / name] if p.exists())
        lines = path.read_text().split('\n')
        i = int(line) - 1
        new = re.sub(r'\b(beq|bne|bcc|bcs|bmi|bpl)\b', lambda m: 'j' + m.group(1)[1:], lines[i], count=1)
        print(f'{name}:{line}: {lines[i].strip()} -> {new.strip()}')
        lines[i] = new
        path.write_text('\n'.join(lines))
