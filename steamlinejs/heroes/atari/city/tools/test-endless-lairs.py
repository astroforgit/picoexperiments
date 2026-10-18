#!/usr/bin/env python3
"""Verify native unlimited entry, escalating stats/rewards, unlocks and hidden counter."""
import importlib.util,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
def unit(m,key,i):return m.mem.ram[r.LABELS['battle.'+key]+i]
for page in [0xd600,0xd700]:
 m=r.Machine(page)
 for region,location in enumerate([0,1,2,4]):
  m.call('new_city');m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4]=bytes([3]*4);m.put('selected_location',location)
  for wins in [0,1,2,3,4,5,9,10,30,90,254,255]:
   m.mem.ram[r.LABELS['region_wins']+region]=wins;m.put('battle.encounter_seed',1);m.call('battle.start')
   assert m.get('battle.contract')==region*3+min(wins,2)
   hpbonus=min(90,max(0,wins-2));dmgbonus=min(8,hpbonus//3)
   assert m.get('battle.enemy_hp_bonus')==hpbonus and m.get('battle.enemy_damage_bonus')==dmgbonus
   for i in range(m.get('battle.unit_count')):
    typ=unit(m,'unit_type',i);base=m.mem.ram[r.LABELS['battle.type_hp']+typ]
    assert unit(m,'unit_hp',i)==(min(99,base+hpbonus) if unit(m,'unit_team',i) else base)
   contract=m.get('battle.contract');base=m.mem.ram[r.LABELS['battle.reward_lo']+contract]+256*m.mem.ram[r.LABELS['battle.reward_hi']+contract]
   before=m.get('gold',2);m.call('battle.award')
   assert m.get('battle.reward',2)==base+hpbonus*10
   assert m.get('gold',2)==min(65535,before+base+hpbonus*10)
   assert m.mem.ram[r.LABELS['region_wins']+region]==min(255,wins+1)
   m.call('can_enter_battle');assert m.cpu.p&1 # Still open even at the counter/storage limit.
 # Demonstrate an extended victory chain beyond the former three-fight ceiling.
 m.call('new_city');m.put('selected_location',0)
 for wins in range(40):
  m.call('battle.start');assert m.get('screen_mode')==2
  m.call('battle.award');assert m.mem.ram[r.LABELS['region_wins']]==wins+1
  m.call('show_map')
 m.put('selected_location',1);m.call('can_enter_battle');assert m.cpu.p&1
 # Scaled damage and Vampire healing use the real elevated enemy stats.
 m.call('new_city');m.mem.ram[r.LABELS['region_wins']]=5;m.put('selected_location',0);m.call('battle.start')
 enemy=m.get('battle.hero_count');m.mem.ram[r.LABELS['battle.unit_type']+enemy]=25;m.mem.ram[r.LABELS['battle.unit_hp']+enemy]=5
 m.put('battle.attacker_unit',enemy);m.put('battle.defender_unit',0);m.call('battle.compute_damage');assert m.get('battle.attack_damage')==3
 m.call('battle.attack_units');assert m.mem.ram[r.LABELS['battle.unit_hp']+enemy]==6
 m.put('battle.attacker_unit',1);m.put('battle.defender_unit',enemy);m.call('battle.compute_damage');assert m.get('battle.attack_damage')==2
 # Reward growth must saturate rather than wrap with large imported rewards.
 m.mem.ram[r.LABELS['battle.reward_lo']+2]=250;m.mem.ram[r.LABELS['battle.reward_hi']+2]=255
 m.call('battle.award');assert m.get('battle.reward',2)==65535 and m.get('gold',2)==65535
 # First two wins do not unlock the next lair; the third does.
 m.put('selected_location',1)
 for wins in [0,1,2,3]:
  m.mem.ram[r.LABELS['region_wins']]=wins;m.call('can_enter_battle');assert bool(m.cpu.p&1)==(wins>=3)
 m.call('new_city');m.call('show_map');m.put('selected_location',0);m.call('map_confirm');m.call('draw_encounters')
 start=m.get('front_bank')*65536;pixels=m.mem.vram[start:start+64000]
 assert all(pixels[y*320+x]==7 for y in range(105,113) for x in range(32,132))
 m.cpu.a=2;m.call('map_choice_enabled');assert not m.cpu.p&1 # No flat practice bypass.
 if '--screens' in sys.argv and page==0xd600:
  from PIL import Image
  out=Path(sys.argv[sys.argv.index('--screens')+1]);out.mkdir(parents=True,exist_ok=True)
  im=Image.frombytes('P',(320,200),bytes(pixels));im.putpalette(m.mem.palette);im.save(out/'endless-lair-popup.png')
 print(f'PASS ${page:04X}: 40 consecutive battles, unlock after third win, HP/damage escalation, higher rewards, safe 10+/255 win counters, no WINS counter or flat practice action.')
