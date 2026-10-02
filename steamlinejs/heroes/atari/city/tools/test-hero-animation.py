#!/usr/bin/env python3
"""Verify all packed hero poses decode correctly and motion changes art and position."""
import importlib.util,json
from pathlib import Path
spec=importlib.util.spec_from_file_location('runtime',Path(__file__).with_name('test-runtime.py'))
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
ROOT=r.ROOT
layout=json.loads((ROOT/'generated/hero-animation-layout.json').read_text())

def expected(m,pose):
 a=layout['addresses'][pose];data=m.mem.vram[a:a+layout['lengths'][pose]];i=0;pairs=[]
 while data[i]:
  token=data[i];i+=1
  if token<128:pairs+=data[i:i+token];i+=token
  elif token<192:pairs += [0]*((token&63)+1)
  else:pairs += [data[i]]*((token&63)+1);i+=1
 assert len(pairs)==448
 pal=r.LABELS['battle.hero_palette']+(pose//6)*16
 return bytes(m.mem.ram[pal+n] for v in pairs for n in (v>>4,v&15))

def check(page,capture=False):
 m=r.Machine(page);m.put('army_count',1);m.put('army_units',0);m.put('selected_location',0);m.call('battle.start')
 m.put('battle.animation_active',1);m.put('battle.animation_unit',0);m.put('battle.draw_id',0)
 for unit in range(28):
  m.put('battle.unit_type',unit)
  for frame in range(6):
   m.put('battle.animation_active',int(frame<4));m.put('battle.attacker_unit',0)
   m.put('battle.attack_frame',8 if frame==4 else 4 if frame==5 else 0)
   m.put('battle.animation_step',frame)
   m.put('render_bank',m.get('back_bank'));m.put('calc_x',20,2);m.put('calc_y',40)
   m.cpu.a=unit;m.call('battle.hero_sprite')
   pose=m.mem.ram[r.LABELS['battle.hero_set']+unit]+frame
   assert bytes(m.mem.vram[0x7e000:0x7e380])==expected(m,pose),(page,unit,frame)
 # Real move: same unit, changing full-body frames AND ground position.
 m.put('battle.animation_active',0);m.put('battle.attack_frame',0);m.put('battle.unit_type',0)
 m.put('battle.animation_from',0);m.put('battle.animation_to',1)
 m.mem.hero_blits.clear();m.call('battle.animate_move')
 assert len({p for _,p in m.mem.hero_blits})>=2
 assert len({d%65536 for d,_ in m.mem.hero_blits})>=4
 # Melee attacker changes poses and lunges; it is not only a flashing defender.
 m.put('battle.attacker_unit',0);m.put('battle.defender_unit',1)
 m.mem.ram[r.LABELS['battle.unit_cell']+1]=1
 m.mem.hero_blits.clear();m.call('battle.animate_attack')
 assert m.get('battle.attack_ranged')==0
 assert len({p for _,p in m.mem.hero_blits})>=2
 assert len({d%65536 for d,_ in m.mem.hero_blits})>=3
 # Ranged attack marks a projectile and advances it toward its actual target.
 m.put('battle.unit_type',3);m.mem.ram[r.LABELS['battle.unit_cell']+1]=3
 m.call('battle.prepare_projectile');assert m.get('battle.attack_ranged')==1
 x=m.get('battle.projectile_x');m.call('battle.advance_projectile')
 assert m.get('battle.projectile_x')>x
 if capture:
  # A contact sheet/GIF contains actual emulated framebuffers, not mocked sprites.
  from PIL import Image
  m.put('battle.unit_type',0);m.put('battle.unit_cell',16)
  m.mem.ram[r.LABELS['battle.unit_cell']+1]=20
  m.put('battle.cursor_cell',16);m.put('battle.animation_active',1)
  m.put('battle.animation_unit',0);m.put('battle.animation_x',104);m.put('battle.animation_y',90)
  frames=[]
  for phase in range(6):
   m.put('battle.animation_step',phase);m.screenshot(f'hero-walk-{phase}.png')
   frames.append(Image.open(ROOT/'generated'/f'hero-walk-{phase}.png').convert('RGB').resize((960,600),Image.Resampling.NEAREST))
  frames[0].save(ROOT/'generated/hero-walk.gif',save_all=True,append_images=frames[1:],duration=180,loop=0)
  m.put('battle.animation_active',0);m.screenshot('battle-full-body.png')
 print(f'PASS ${page:04X}: all 168 unit/pose mappings decode, full-body walk frames, melee lunge/poses and ranged projectile.')
if __name__=='__main__':
 check(0xd600,True);check(0xd700)
