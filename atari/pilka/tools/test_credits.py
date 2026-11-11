#!/usr/bin/env python3
"""Check credits navigation, rendered text and modal input in the built XEX."""
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools/reference'))
from atari_emu import Atari, load_labels
r = load_labels(ROOT / 'gen/runtime.asm.lab')
l = load_labels(ROOT / 'gen/league.asm.lab')
a = Atari(ROOT / 'pilka.xex')
a.boot()
while a.cpu.pc != 0x975b: a.cpu.step()
a.next_frame = a.cpu.processorCycles + a.frame_cycles

def state(name): return int(a.vram[0x74000+l[name]])
def press(stick=15, fire=False, key=None):
    a.set_input(stick=stick, trig=fire, **({'key':key} if key is not None else {}))
    a.run_frames(7)
    a.set_input()
    a.run_frames(7)
def check_text(row, col, text):
    glyphs = bytes(ord(c)+0x98 if 'A'<=c<='Z' else 0xfd for c in text)
    start=0x7b800+row*40+col
    assert bytes(a.vram[start:start+len(glyphs)]) == glyphs, text

a.run_frames(24)
check_text(23,12,'GAME BY ASTROFOR')
check_text(12,3,'CREDITS')
press(stick=14)
assert state('SELECTION') == 3
preview=ROOT/'analysis/credits-preview'
preview.mkdir(exist_ok=True)
a.screenshot(preview/'main.png',scale=2)
season=bytes(a.vram[0x7b000:0x7b003])
press(fire=True)
assert state('MENU_PAGE') == 11
check_text(7,5,'CREDITS')
check_text(12,5,'AMIGA SENSIBLE WORLD OF SOCCER')
check_text(15,5,'ARLASOFT SOCCER BY ARLASOFT')
a.screenshot(preview/'credits.png',scale=2)
for stick in (13,14,7,11):
    press(stick=stick)
    assert state('MENU_PAGE') == 11 and state('SELECTION') == 3
assert a.mem.ram[r['LEAGUE_SCREEN']] and not a.mem.ram[r['LEAGUE_MATCH']]
press(fire=True)
assert state('MENU_PAGE') == 0 and state('SELECTION') == 3
press(fire=True)
assert state('MENU_PAGE') == 11
press(key=28)
assert state('MENU_PAGE') == 0 and state('SELECTION') == 3
assert bytes(a.vram[0x7b000:0x7b003]) == season
press(stick=13)
assert state('SELECTION') == 0
print('PASS: author footer, last Credits item, popup text, modal directions, Fire/Escape return, season unchanged')
