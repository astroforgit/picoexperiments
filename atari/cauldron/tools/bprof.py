#!/usr/bin/env python3
"""bprof.py SNAP FRAMES: cycles per label in bank R (bank-aware), plus totals."""
import os, re, sys, bisect
from collections import Counter
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap  # noqa: E402
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# labels of bank R from the listing
labs = []
bank = None
pat = re.compile(r'^\s*\d+\s+([0-9A-F]{4})\s+(?:[0-9A-F]{2} ?)*\s*([A-Za-z_][A-Za-z0-9_]*)\b')
for line in open(os.path.join(HERE, 'gen', 'runtime.lst'), errors='replace'):
    if 'rbank_start' in line:
        bank = 'R'
    elif 'nbank_start' in line:
        bank = 'N'
    m = pat.match(line)
    if m and bank == 'R':
        addr = int(m.group(1), 16)
        name = m.group(2)
        if addr >= 0xE000 and not re.match(r'^(lda|sta|ldx|ldy|jsr|jmp|dta|inc|dec|and|ora|cmp|bne|beq|rts|txa|tax|clc|sec|adc|sbc|lsr|asl|rol|ror|bcc|bcs|bpl|bmi|iny|inx|dex|dey|pha|pla|tya|tay|stx|sty|eor|cpx|cpy|bit|php|plp|jne|jeq|jcc|jcs)$', name, re.I):
            labs.append((addr, name))
labs.sort()
addrs = [a for a, _ in labs]
a = load_snap(sys.argv[1])
n = int(sys.argv[2])
cnt = Counter()
cpu = a.cpu
end = a.frame + n
while a.frame < end:
    pc = cpu.pc
    c0 = cpu.processorCycles
    a.run_until(c0 + 1)
    d = cpu.processorCycles - c0
    if pc >= 0xE000 and a.mems == 0xFC:
        i = bisect.bisect_right(addrs, pc) - 1
        cnt[labs[i][1] if i >= 0 else '?'] += d
    elif pc >= 0xE000 and a.mems & 0x80:
        cnt['(bank N/I)'] += d
    elif 0x8000 <= pc < 0xAA30:
        cnt['(game)'] += d
    else:
        cnt['(code A)'] += d
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
tot = sum(cnt.values())
for k, v in cnt.most_common(30):
    print(f'{k:14} {100 * v / tot:5.1f}% {v // n:6} per frame')
