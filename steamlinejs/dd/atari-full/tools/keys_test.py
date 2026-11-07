"""Keyboard: RETURN opens the menu and starts; in game D walks right, O punches, P kicks."""
from pathlib import Path
from atari_emu import Atari, load_labels
a = Atari(Path('../double-dragon.xex')); a.boot(); r = a.mem.ram
lab = load_labels(Path('../gen/runtime.lab'))
RET, D, O, P = 0x0C, 0x3A, 0x08, 0x0A
def inp(f):
    if f in range(400, 404) or f in range(600, 604): return dict(key=RET)
    if f > 1700:
        k = (f - 1700) % 30
        if k < 12: return dict(key=D)
        if k in (14, 15): return dict(key=O)
        if k in (22, 23): return dict(key=P)
    return {}
a.run_frames(460, inp); print('after RETURN: $100', hex(r[0x100]), 'irq st', hex(a.irqst))
a.run_frames(1700 - a.frame, inp); print('in game: $100', hex(r[0x100]), 'x', r[0x5A] | r[0x62] << 8)
seen = set()
for i in range(90):
    a.run_frames(1, inp); seen.add(r[lab['NES_BUTTONS']])
print('player x after keys', r[0x5A] | r[0x62] << 8, 'button values seen', sorted(hex(v) for v in seen))
