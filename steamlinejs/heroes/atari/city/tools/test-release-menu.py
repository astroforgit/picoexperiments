#!/usr/bin/env python3
"""Boot the real release menu, exercise all pages and check clean input handoff."""
import importlib.util,json,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
def screen(m,name):
 if '--screens' not in sys.argv:return
 from PIL import Image
 out=Path(sys.argv[sys.argv.index('--screens')+1]);out.mkdir(parents=True,exist_ok=True)
 base=m.get('front_bank')*65536;im=Image.frombytes('P',(320,200),bytes(m.mem.vram[base:base+64000]));im.putpalette(m.mem.palette);im.save(out/name)
def event(m,key):
 m.mem.ram[0xd209]=key;m.mem.ram[0xd20f]=251
 m.run_until(r.LABELS['release_ui.show.redraw']);m.run_until(r.LABELS['release_ui.show.loop'])
 m.mem.ram[0xd20f]=255
 for i in range(10000):
  if i%1000==0:m.mem.ram[0x14]=(m.mem.ram[0x14]+1)&255
  m.cpu.step()
 m.run_until(r.LABELS['release_ui.show.loop'])
for mapping in (0xd600,0xd700):
 m=r.Machine(mapping,menu=True);assert m.get('release_ui.page')==0
 assert m.get('difficulty')==1 and m.get('gold',2)==50,'Medium is the default'
 if mapping==0xd600:screen(m,'prince-and-the-nymph-title.png')
 event(m,0x3e);assert m.get('release_ui.choice')==1
 levels=json.loads((Path(__file__).resolve().parents[3]/'difficulty.json').read_text())['levels']
 for level in (2,0,1):
  gold=levels[level]['startingGold']
  event(m,12);assert m.get('release_ui.page')==0 and m.get('difficulty')==level and m.get('gold',2)==gold
  if mapping==0xd600 and level==2:screen(m,'prince-and-the-nymph-level-hard.png')
 event(m,0x3e);assert m.get('release_ui.choice')==2
 event(m,12);assert m.get('release_ui.page')==1
 if mapping==0xd600:screen(m,'prince-and-the-nymph-instructions.png')
 event(m,28);assert m.get('release_ui.page')==0
 event(m,0x3e);assert m.get('release_ui.choice')==3
 event(m,33);assert m.get('release_ui.page')==2
 if mapping==0xd600:screen(m,'prince-and-the-nymph-credits.png')
 event(m,12);assert m.get('release_ui.page')==0
 event(m,0x3e);assert m.get('release_ui.choice')==4
 event(m,12);assert m.get('release_ui.page')==0 and m.get('sfx.enabled')==0
 assert m.mem.ram[0xd203]==0 and m.mem.ram[0xd201]==0 and m.get('sfx.frames')==0
 if mapping==0xd600:screen(m,'prince-and-the-nymph-sound-off.png')
 pc,sp,stack=m.cpu.pc,m.cpu.sp,bytes(m.mem.ram[0x100:0x200]);m.cpu.a=1;m.call('sfx.play');m.cpu.pc,m.cpu.sp=pc,sp;m.mem.ram[0x100:0x200]=stack
 assert m.mem.ram[0xd203]==0 and m.get('sfx.frames')==0,'Sound off is silent'
 event(m,33);assert m.get('sfx.enabled')==1 and m.get('release_ui.page')==0
 event(m,0x3e);assert m.get('release_ui.choice')==0
 # Hold the Start press during handoff; no city popup/purchase may occur.
 m.mem.ram[0xd010]=0;m.run_until(r.LABELS['main_loop'])
 assert m.get('army_count')==2 and m.get('gold',2)==50
 m.idle(4);assert m.get('popup_open')==0
 m.release();m.fire();assert m.get('popup_open')==1
 assert b'PRINCE AND THE NYMPH\0' in m.mem.ram
 assert b'AUTHOR: ASTROFOR\0' in m.mem.ram
 print(f'PASS ${mapping:04X}: actual boot/title, level cycle, instructions, credits, sound on/off, menu wrap, Enter/Space/Escape, exact credit and safe held-Fire handoff.')
