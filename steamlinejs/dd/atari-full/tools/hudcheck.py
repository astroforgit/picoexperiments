"""Count gameplay frames composed without the HUD split (PAL and NTSC)."""
from pathlib import Path
from atari_emu import Atari, load_labels
for pal in (True, False):
    a = Atari(Path('../double-dragon.xex'), pal=pal); a.boot(); r = a.mem.ram
    lab = load_labels(Path('../gen/runtime.lab'))
    inp = lambda f: dict(consol=6) if f in range(380,386) or f in range(560,566) else (dict(stick=7, trig=f%8<2) if f > 900 else {})
    a.run_frames(2000, inp)
    cpu = a.cpu; co = lab['CO_BS']; c = {'miss': 0, 'tot': 0}
    def ru(t):
        while cpu.processorCycles < t:
            if cpu.pc == co:
                c['tot'] += 1
                if r[lab['C_HUD']] == 0:
                    c['miss'] += 1
                    c.setdefault('at', []).append(a.frame)
            cpu.step()
    a.run_until = ru
    a.run_frames(600, inp)
    print('PAL' if pal else 'NTSC', 'composes', c['tot'], 'without HUD split', c['miss'], c.get('at', [])[:30])
    a.screenshot(Path('../gen/hud-%s.png' % ('pal' if pal else 'ntsc')))
