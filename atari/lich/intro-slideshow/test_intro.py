#!/usr/bin/env python3
"""Exercise the standalone XEX with the project's headless VBXE emulator."""
import json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'intro.lab');manifest=json.loads((ROOT/'data/manifest.json').read_text());raw=(ROOT/'data/vram.bin').read_bytes()
a=Atari(ROOT/'dusiolek-intro.xex');a.boot()
assert bytes(a.vram[:0x7e000])==raw[:0x7e000], 'XEX bank upload'
a.run_frames(10);r=a.mem.ram
assert r[L['SCENE']]==0
before=r[L['SCROLL']];a.run_frames(18);assert r[L['SCROLL']]>before
# Keyboard pause, holding a key must not toggle repeatedly.
a.kbcode=0x21;a.skstat=0xfb;a.run_frames(2);assert r[L['PAUSED']]==1
before=r[L['SCROLL']];a.run_frames(20);assert r[L['SCROLL']]==before
# Fire advances once even while held, and preserves paused status.
a.kbcode=0xff;a.skstat=0xff;a.run_frames(2)
a.set_input(trig=1);a.run_frames(2);assert r[L['SCENE']]==1
a.run_frames(12);assert r[L['SCENE']]==1
a.set_input();a.run_frames(2)
(ROOT/'screenshots').mkdir(exist_ok=True)
for i,m in enumerate(manifest['scenes']):
 r[L['SCENE']]=i;a.call(L['SCENE_START'])
 # Show the text entering the bottom strip.
 r[L['SCROLL']]=48;r[L['SCROLL']+1]=0;a.call(L['UPDATE_SCROLL'])
 a.screenshot(ROOT/f'screenshots/scene-{i+1}.png',scale=3)
 addr=0x7e000+i*32+16
 actual=int(a.vram[addr])+(int(a.vram[addr+1])<<8)+(int(a.vram[addr+2])<<16)
 assert actual==m['text_base']+48*256,(i,hex(actual))
 r[L['SCROLL']]=(m['scroll_end']-1)&255;r[L['SCROLL']+1]=(m['scroll_end']-1)>>8
 a.call(L['ADVANCE_SCROLL']);assert r[L['SCENE']]==(i+1)%5
 assert r[L['SCROLL']]==0 and r[L['SCROLL']+1]==0
print('PASS bank loading, scrolling, pause, held-key debounce, five scenes, automatic transitions and looping')
