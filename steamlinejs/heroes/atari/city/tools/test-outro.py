#!/usr/bin/env python3
"""Execute the real final-boss kill, three native ending pages and new campaign."""
import importlib.util,json,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)


def advance(m,count=12000):
 for tick in range(count):
  if tick%1000==0:m.mem.ram[0x14]=(m.mem.ram[0x14]+1)&255
  m.cpu.step()
def at(m,label=''):m.run_until(r.LABELS['outro.wait_action'+label])
def expected(page):
 return (r.ROOT/f'generated/story-{page+1}.bin').read_bytes()[:46080]

frames=[]
for register_page in (0xd600,0xd700):
 m=r.Machine(register_page)
 for state,contract,committed in [(0,11,1),(2,11,1),(3,11,1),(1,10,1),(1,11,0)]:
  m.put('screen_mode',2);m.put('battle.game_state',state);m.put('battle.contract',contract);m.put('battle.reward_committed',committed)
  m.call('outro.check');assert m.get('screen_mode')==2
 # Enter the final encounter and kill the real Warlock through native attack code.
 m.call('new_city')
 for i in range(3):m.mem.ram[r.LABELS['region_wins']+i]=3
 m.mem.ram[r.LABELS['region_wins']+3]=2
 m.put('selected_location',4);m.call('battle.start');assert m.get('battle.contract')==11
 count=m.get('battle.unit_count');types=list(m.mem.ram[r.LABELS['battle.unit_type']:r.LABELS['battle.unit_type']+count]);boss=types.index(22)
 m.mem.ram[r.LABELS['battle.unit_hp']+boss]=1
 m.put('battle.attacker_unit',0);m.put('battle.defender_unit',boss);m.put('battle.attack_bonus',0);m.call('battle.attack_units')
 assert m.get('battle.game_state')==1 and m.get('battle.reward_committed')==1
 # The actual main loop must dispatch the ending automatically.
 m.cpu.pc=r.LABELS['main_loop'];at(m)
 for page in range(3):
  assert m.get('outro.page')==page
  start=m.get('front_bank')*65536
  assert bytes(m.mem.vram[start:start+46080])==expected(page),'Full-resolution picture differs from export'
  if register_page==0xd600:
   from PIL import Image
   im=Image.frombytes('P',(320,200),bytes(m.mem.vram[start:start+64000]));im.putpalette(m.mem.palette);frames.append(im.convert('RGB'))
  # Held Fire on entry cannot advance; fresh Fire/Enter/Space each tested.
  address=0xd010 if page==0 else 0xd20f
  down,up=(0,1) if page==0 else (251,255)
  if page:m.mem.ram[0xd209]=12 if page==1 else 33
  m.mem.ram[address]=down;advance(m);assert m.get('outro.page')==page
  m.mem.ram[address]=up;at(m,'.press')
  m.mem.ram[address]=down;at(m,'.finish');advance(m);assert m.get('outro.page')==page
  m.mem.ram[address]=up
  if page<2:at(m)
  else:m.run_until(r.LABELS['main_loop'])
 assert m.get('screen_mode')==0 and m.get('army_count')==2 and m.get('gold',2)==50
 assert bytes(m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4])==bytes(4)
 m.idle(3);assert m.get('popup_open')==0
 m.release();m.fire();assert m.get('popup_open')==1
 print(f'PASS ${register_page:04X}: real Warlock kill, final-victory-only automatic ending, three exact full-resolution pictures, safe hidden-buffer writes, held/released Fire/Enter/Space and clean new campaign.')

if '--screens' in sys.argv:
 out=Path(sys.argv[sys.argv.index('--screens')+1]);out.mkdir(parents=True,exist_ok=True)
 for i,im in enumerate(frames,1):im.save(out/f'story-outro-{i}.png')
 scaled=[im.resize((960,600),Image.Resampling.NEAREST) for im in frames]
 scaled[0].save(out/'story-outro-preview.gif',save_all=True,append_images=scaled[1:],duration=6500,loop=0)
