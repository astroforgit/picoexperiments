#!/usr/bin/env python3
"""Actual assembled damage preview, eight-frame recoil, and red point scaling."""
import importlib.util,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
def setunit(m,key,i,value):m.mem.ram[r.LABELS['battle.'+key]+i]=value
def preview(m,attacker,defender,hp,bonus=0):
 m.put('battle.attacker_unit',0);m.put('battle.defender_unit',1)
 setunit(m,'unit_type',0,attacker);setunit(m,'unit_type',1,defender);setunit(m,'unit_hp',1,hp);m.put('battle.attack_bonus',bonus)
 address=r.LABELS['battle.draw'];saved=m.mem.ram[address];m.mem.ram[address]=0x60
 step=m.cpu.step;seen=[]
 def observe():
  if m.cpu.pc==address:seen.append((m.get('battle.attack_frame'),m.get('battle.impact_damage')))
  step()
 m.cpu.step=observe
 try:m.call('battle.animate_attack')
 finally:m.cpu.step=step;m.mem.ram[address]=saved
 assert [frame for frame,damage in seen]==list(range(8,0,-1))
 assert m.mem.ram[r.LABELS['battle.unit_hp']+1]==hp and m.get('battle.attack_bonus')==bonus
 assert m.get('battle.impact_damage')==0 and m.get('battle.attack_frame')==0
 return seen[0][1]
for page in [0xd600,0xd700]:
 m=r.Machine(page);m.put('selected_location',0);m.put('battle.encounter_seed',1);m.call('battle.start')
 assert preview(m,1,15,9)==2
 assert preview(m,2,15,1)==1 # Overkill shows actual HP lost.
 assert preview(m,4,18,9)==0 # Skeleton arrow immunity.
 assert preview(m,12,18,9)==2 # Magic ignores it.
 assert preview(m,21,1,9,2)==5 # Prepared Ogre.
 assert preview(m,22,18,3)==0 # Summoning is not damage.
 m.put('battle.attack_bonus',0);m.put('render_bank',m.get('back_bank'));m.put('battle.animation_active',0)
 for defender,attacker,direction in [(1,0,1),(0,1,-1)]:
  setunit(m,'unit_cell',0,15);setunit(m,'unit_cell',1,16);setunit(m,'unit_type',0,1);setunit(m,'unit_type',1,15)
  setunit(m,'unit_team',0,0);setunit(m,'unit_team',1,1)
  m.put('battle.attacker_unit',attacker);m.put('battle.defender_unit',defender);m.put('battle.draw_id',defender)
  base=72 if defender==0 else 104
  for frame in range(8,0,-1):
   m.put('battle.attack_frame',frame);m.put('battle.impact_damage',3);m.call('battle.fighter')
   recoil=[0,1,3,5,0,0,0,0][frame-1]
   assert m.get('battle.foot_x')==base+direction*recoil,(page,defender,frame)
  for damage in [1,2,3,4,5,9]:
   for frame in [8,4,3,2,1,0]:
    bank=m.get('back_bank');start=bank*65536;m.mem.vram[start:start+64000]=bytes(64000)
    m.put('battle.draw_id',defender);m.put('battle.foot_x',base);m.put('battle.foot_y',90)
    m.put('battle.impact_damage',damage);m.put('battle.attack_frame',frame);m.call('battle.hit_dot')
    size=2*min(4,damage)-1
    assert m.mem.vram[start:start+64000].count(9)==(size*size if frame in [2,3,4] else 0),(page,damage,frame)
 print(f'PASS ${page:04X}: actual HP/armor/Ogre damage preview without mutation; eight attack frames; both teams recoil/recover; 1/3/5/7 pixel red impacts; summons suppressed.')
 if '--preview' in sys.argv and page==0xd600:
  from PIL import Image
  out=Path(sys.argv[sys.argv.index('--preview')+1]);out.mkdir(parents=True,exist_ok=True)
  m.call('new_city');m.put('selected_location',0);m.put('battle.encounter_seed',1);m.call('battle.start')
  setunit(m,'unit_cell',0,16);setunit(m,'unit_cell',2,17);m.put('battle.cursor_cell',17)
  m.put('battle.attacker_unit',0);m.put('battle.defender_unit',2);m.put('battle.impact_damage',3);m.put('battle.attack_ranged',0)
  frames=[]
  for frame in [0,8,7,6,5,4,3,2,1,0]:
   m.put('battle.attack_frame',frame);m.call('battle.draw');start=m.get('front_bank')*65536
   im=Image.frombytes('P',(320,200),bytes(m.mem.vram[start:start+64000]));im.putpalette(m.mem.palette)
   frames.append(im.convert('RGB').resize((960,600),Image.Resampling.NEAREST))
  frames[0].save(out/'hit-impact-preview.gif',save_all=True,append_images=frames[1:],duration=[500]+[120]*8+[500],loop=0)
  frames[5].save(out/'hit-impact-frame.png')
