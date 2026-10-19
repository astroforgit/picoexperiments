#!/usr/bin/env python3
"""Native quest progression, shuffled unique finds, Chapel UI and exact pictures."""
import importlib.util,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
def screen(m,name):
 if '--screens' not in sys.argv:return
 from PIL import Image
 out=Path(sys.argv[sys.argv.index('--screens')+1]);out.mkdir(parents=True,exist_ok=True)
 start=m.get('front_bank')*65536;im=Image.frombytes('P',(320,200),bytes(m.mem.vram[start:start+64000]));im.putpalette(m.mem.palette);im.save(out/name)
def enter(m,name,stop):
 m.cpu.sp=255;m.cpu.stPushWord(0x5ff);m.cpu.pc=r.LABELS[name];m.run_until(r.LABELS[stop])
def button(m,stop=0x600):
 m.mem.ram[0xd010]=1;m.mem.ram[0xd20f]=255;m.mem.ram[0xd01f]=7
 m.run_until(r.LABELS['gallery.wait_button.press'])
 m.mem.ram[0xd010]=0;m.run_until(r.LABELS['gallery.wait_button.finish'])
 m.mem.ram[0xd010]=1;m.run_until(stop if isinstance(stop,int) else r.LABELS[stop])
def won(m,region):
 m.put('battle.region',region);m.mem.ram[r.LABELS['region_wins']+region]+=1;m.call('gallery.record_win')
for mapping in (0xd600,0xd700):
 m=r.Machine(mapping,gallery=True)
 orders=set()
 for seed in range(1,256):
  m.put('battle.encounter_seed',seed);m.call('gallery.new_game')
  order=tuple(m.mem.ram[r.LABELS['gallery.order']:r.LABELS['gallery.order']+8]);assert sorted(order)==list(range(8));orders.add(order)
 assert len(orders)>=64
 m.call('new_city');m.put('battle.encounter_seed',0);m.call('gallery.new_game')
 won(m,0);assert m.get('gallery.notes_found')==0
 won(m,0);assert m.get('gallery.notes_found')==1 and m.get('gallery.notes_pending')==1 and m.get('gallery.collected')==0
 enter(m,'gallery.check_events','gallery.wait_button')
 if mapping==0xd600:screen(m,'gallery-painter-notes.png')
 button(m);assert m.get('gallery.notes_pending')==0
 order=list(m.mem.ram[r.LABELS['gallery.order']:r.LABELS['gallery.order']+8])
 won(m,0);assert m.get('gallery.collected')==1<<order[0] and m.get('gallery.painting_pending')==order[0]+1
 enter(m,'gallery.check_events','gallery.wait_button')
 if mapping==0xd600:screen(m,'gallery-first-discovery.png')
 button(m)
 won(m,0);m.put('gallery.painting_pending',0)
 before=(m.get('gold',2),m.get('army_count'))
 for _ in range(5):won(m,0)
 assert m.get('gallery.collected')==(1<<order[0]|1<<order[1]) and m.get('gallery.painting_pending')==0
 for region in (1,2,3):
  first,second=order[region*2:region*2+2]
  won(m,region);assert m.get('gallery.collected')&(1<<first) and not m.get('gallery.collected')&(1<<second)
  won(m,region);assert m.get('gallery.collected')&(1<<second)
  m.put('gallery.painting_pending',0)
 assert m.get('gallery.collected')==255 and before==(m.get('gold',2),m.get('army_count'))
 # Gallery is locked until the Chapel exists; navigation skips the locked row.
 m.put('selected_plot',3);m.put('popup_open',1);m.put('popup_choice',0);m.call('describe_selection');assert m.get('secondary_available')==0
 m.cpu.a=1;m.call('navigate');assert m.get('popup_choice')==2
 m.put('popup_choice',0);m.call('purchase');assert m.mem.ram[r.LABELS['building_levels']+3]==1
 m.put('popup_open',1);m.put('popup_choice',1);m.call('describe_selection');assert m.get('secondary_available')==1
 m.call('draw_city')
 if mapping==0xd600:screen(m,'gallery-chapel-button.png')
 before=(m.get('gold',2),m.get('army_count'),m.get('popup_open'),m.get('popup_choice'))
 enter(m,'gallery.open','gallery.open.loop')
 if mapping==0xd600:screen(m,'gallery-collected-list.png')
 # Activate the first collected picture via a fresh Fire.
 m.mem.ram[0xd010]=1
 for i in range(12000):
  if i%1000==0:m.mem.ram[0x14]=(m.mem.ram[0x14]+1)&255
  m.cpu.step()
 m.run_until(r.LABELS['gallery.open.loop'])
 m.mem.ram[0xd010]=0;m.run_until(r.LABELS['gallery.wait_button'])
 start=m.get('front_bank')*65536
 assert m.mem.vram[start:start+46080]==(r.ROOT/'generated/story-5.bin').read_bytes()[:46080]
 button(m,'gallery.open.loop')
 m.mem.ram[0xd20f]=251;m.mem.ram[0xd209]=28;m.run_until(0x600);m.mem.ram[0xd20f]=255
 assert before==(m.get('gold',2),m.get('army_count'),m.get('popup_open'),m.get('popup_choice'))
 m.call('new_city');assert m.get('gallery.collected')==0 and m.get('gallery.notes_found')==0
 m.put('dirty',0);m.put('action_latched',0);m.call('gallery.check_events')
 assert m.get('dirty')==0 and m.get('action_latched')==0, 'No pending event must leave normal input/drawing alone'
 m.put('battle.region',0);m.put('battle.contract',0);m.put('battle.reward_committed',0)
 m.call('battle.award');m.call('battle.award')
 assert m.get('gallery.wins')==1 and m.get('gallery.notes_found')==0, 'Committed reward must not count twice'
 m.put('battle.reward_committed',0);m.call('battle.award')
 assert m.get('gallery.wins')==2 and m.get('gallery.notes_found')==1
 print(f'PASS ${mapping:04X}: shuffled eight-item locations, notes after two wins, eight unique finds before final boss, no repeated rewards, locked Chapel, gallery/picture controls, exact full-quality artwork, campaign-state preservation and new-game reset.',flush=True)
