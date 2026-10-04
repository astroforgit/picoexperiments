"""Mode B 2-player: player 2 walks left with joystick 2 and punches."""
from pathlib import Path
from atari_emu import Atari, load_labels
a = Atari(Path('../double-dragon.xex')); a.boot()
r = a.mem.ram
def inputs(f):
    if f in range(380, 386) or f in range(640, 646) or f in range(760, 766): return dict(consol=6)
    for k in range(3):
        if f in range(440 + 30*k, 446 + 30*k): return dict(consol=5)
    if f > 900: return dict(stick1=11, trig1=1 if f % 6 < 2 else 0)
    return {}
a.run_frames(900, inputs)
print('players', r[0x30], 'modeB', r[0x32], 'F6', hex(r[0xF6]))
xs = []
for i in range(6):
    a.run_frames(40, inputs)
    xs.append((r[0x5A] | r[0x62] << 8, r[0x5B] | r[0x63] << 8))
    print(a.frame, 'F8', hex(r[0xF8]), 'b2', hex(r[0x0B80]), 'p1 x', xs[-1][0], 'p2 x', xs[-1][1])
a.screenshot(Path('../gen/two-player.png'))
