#!/usr/bin/env python3
"""Boot the real release menu, exercise all pages and check clean input handoff."""
import importlib.util,sys
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
 if mapping==0xd600:screen(m,'prince-and-the-nimf-title.png')
 event(m,0x3e);assert m.get('release_ui.choice')==1
 event(m,12);assert m.get('release_ui.page')==1
 if mapping==0xd600:screen(m,'prince-and-the-nimf-instructions.png')
 event(m,28);assert m.get('release_ui.page')==0
 event(m,0x3e);assert m.get('release_ui.choice')==2
 event(m,33);assert m.get('release_ui.page')==2
 if mapping==0xd600:screen(m,'prince-and-the-nimf-credits.png')
 event(m,12);assert m.get('release_ui.page')==0
 event(m,0x3e);assert m.get('release_ui.choice')==0
 # Hold the Start press during handoff; no city popup/purchase may occur.
 m.mem.ram[0xd010]=0;m.run_until(r.LABELS['main_loop'])
 assert m.get('army_count')==2 and m.get('gold',2)==50
 m.idle(4);assert m.get('popup_open')==0
 m.release();m.fire();assert m.get('popup_open')==1
 assert b'PRINCE AND THE NIMF\0' in m.mem.ram
 assert b'EVERYTHING BY ASTROFOR\0' in m.mem.ram
 print(f'PASS ${mapping:04X}: actual boot/title, instructions, credits, menu wrap, Enter/Space/Escape, exact credit and safe held-Fire handoff.')
