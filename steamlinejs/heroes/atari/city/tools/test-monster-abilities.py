#!/usr/bin/env python3
"""Execute assembled special attacks and seeded encounter tables on both VBXE pages."""
import importlib.util,json
from pathlib import Path
spec=importlib.util.spec_from_file_location('runtime',Path(__file__).with_name('test-runtime.py'))
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
content=json.loads((r.ROOT/'content.json').read_text())
def arr(m,key,values):
 a=r.LABELS['battle.'+key];m.mem.ram[a:a+len(values)]=bytes(values)
def val(m,key,i):return m.mem.ram[r.LABELS['battle.'+key]+i]
def fixture(m,types,teams,cells,hp):
 for key in ['unit_charge','unit_raised','unit_summoned','unit_spawned','unit_acted','unit_move_left']:arr(m,key,[0]*12)
 for key,values in [('unit_type',types),('unit_team',teams),('unit_cell',cells),('unit_hp',hp)]:arr(m,key,values+[0]*(12-len(values)))
 for key,value in [('unit_count',len(types)),('hero_count',sum(t==0 for t in teams)),('game_state',0),('turn_number',1),('conversions',0),('attack_bonus',0),('ability_event',0)]:m.put('battle.'+key,value)
 arr(m,'terrain',[0]*42)
def hit(m,a,b):
 m.put('battle.attacker_unit',a);m.put('battle.defender_unit',b);m.call('battle.attack_units')
for page in [0xd600,0xd700]:
 m=r.Machine(page)
 # Actual UI and animation drawing are covered separately; keep combat tests fast.
 m.mem.ram[r.LABELS['battle.draw']]=0x60
 # Vampire heals on damage and never exceeds max HP.
 fixture(m,[1,25],[0,1],[0,1],[4,3]);hit(m,1,0)
 assert val(m,'unit_hp',0)==2 and val(m,'unit_hp',1)==4
 hit(m,1,0);assert val(m,'unit_hp',1)==5
 fixture(m,[1,25],[0,1],[0,1],[9,5]);hit(m,1,0);assert val(m,'unit_hp',1)==5
 # Soldier conversion reuses its cell/slot, has 2 HP and cannot act this round.
 fixture(m,[1,1,1,19],[0,0,0,1],[0,7,14,1],[2,2,2,5]);hit(m,3,0)
 assert val(m,'unit_team',0)==1 and val(m,'unit_type',0)==19 and val(m,'unit_hp',0)==2
 assert val(m,'unit_spawned',0)==1 and m.get('battle.conversions')==1
 hit(m,0,1);assert val(m,'unit_hp',1)==0 and val(m,'unit_team',1)==0
 arr(m,'unit_hp',[2,2,2,5]);hit(m,3,1);assert m.get('battle.conversions')==2
 hit(m,3,2);assert val(m,'unit_hp',2)==0 and val(m,'unit_team',2)==0
 # Skeleton resists physical arrows, not magic; minimum damage is 1.
 fixture(m,[4,18],[0,1],[0,1],[4,3]);hit(m,0,1);assert val(m,'unit_hp',1)==2
 fixture(m,[12,18],[0,1],[0,1],[4,3]);hit(m,0,1);assert val(m,'unit_hp',1)==1
 fixture(m,[3,18],[0,1],[0,1],[4,3]);hit(m,0,1);assert val(m,'unit_hp',1)==2
 # Ogre prepares, attacks marked cell next phase, and loses attack if victim moved.
 fixture(m,[2,21],[0,1],[0,1],[6,7]);m.put('battle.enemy_id',1);m.call('battle.enemy_act')
 assert val(m,'unit_hp',0)==6 and val(m,'unit_charge',1)==1
 m.call('battle.enemy_act');assert val(m,'unit_hp',0)==1 and val(m,'unit_charge',1)==0
 fixture(m,[2,21],[0,1],[0,1],[6,7]);m.put('battle.enemy_id',1);m.call('battle.enemy_act');arr(m,'unit_cell',[7,1]);m.call('battle.enemy_act');assert val(m,'unit_hp',0)==6 and val(m,'unit_cell',1)==1
 # Imp retreats to an open adjacent cell, increasing its distance from the victim.
 fixture(m,[2,23],[0,1],[0,1],[6,4]);hit(m,1,0);assert val(m,'unit_cell',1)==2 and val(m,'unit_hp',0)==4
 # Warlock: delayed skeletons, two alive, delayed actions, recycled full slots.
 fixture(m,[2,22],[0,1],[0,6],[6,9]);m.put('battle.enemy_id',1);m.call('battle.enemy_act');assert m.get('battle.unit_count')==2
 m.put('battle.turn_number',2);m.call('battle.enemy_act');assert m.get('battle.unit_count')==3 and val(m,'unit_type',2)==18 and val(m,'unit_spawned',2)==2
 m.call('battle.enemy_act');m.call('battle.enemy_act');assert m.get('battle.unit_count')==4
 fixture(m,[2,22]+[18]*10,[0]+[1]*11,[0,6,1,2,3,4,5,7,8,9,10,11],[6,9]+[0]*10)
 m.put('battle.turn_number',2);m.put('battle.enemy_id',1);m.call('battle.enemy_act');assert m.get('battle.unit_count')==12 and val(m,'unit_hp',2)==3
 # New campaign, gates, exact compiled weighted picks, retries, one-time rewards.
 m.call('new_city');m.put('battle.encounter_seed',1)
 for region,location in enumerate([0,1,2,4]):
  m.put('selected_location',location);m.call('can_enter_battle');assert bool(m.cpu.p&1)==(region==0)
  if region: m.mem.ram[r.LABELS['region_wins']+region-1]=3
  m.call('can_enter_battle');assert m.cpu.p&1
 for contract in range(12):
  region,stage=divmod(contract,3)
  for previous in range(region):m.mem.ram[r.LABELS['region_wins']+previous]=3
  m.put('selected_location',[0,1,2,4][region]);m.mem.ram[r.LABELS['region_wins']+region]=stage
  for seed in range(256):
   m.put('battle.encounter_seed',seed);m.call('battle.start');assert m.get('battle.contract')==contract
   lo=m.mem.ram[r.LABELS['battle.seed_ptr_lo']+contract];hi=m.mem.ram[r.LABELS['battle.seed_ptr_hi']+contract];variant=m.mem.ram[(hi<<8)+lo+seed]
   lo=m.mem.ram[r.LABELS['battle.enemy_ptr_lo']+variant];hi=m.mem.ram[r.LABELS['battle.enemy_ptr_hi']+variant];p=(hi<<8)+lo
   enemies=[]
   while m.mem.ram[p]!=255:enemies.append(m.mem.ram[p]);p+=2
   assert [val(m,'unit_type',i) for i in range(m.get('battle.hero_count'),m.get('battle.unit_count'))]==enemies
 # Retry preserves seed and group; defeat/retreat award nothing.
 m.call('new_city');m.put('selected_location',0);m.put('battle.encounter_seed',13);m.call('battle.start');first=[val(m,'unit_type',i) for i in range(m.get('battle.unit_count'))];m.call('battle.start');assert first==[val(m,'unit_type',i) for i in range(m.get('battle.unit_count'))]
 m.put('battle.game_state',1);m.call('battle.award');gold=m.get('gold',2);assert gold==100 and m.get('battle.encounter_seed')==14
 m.call('battle.award');assert m.get('gold',2)==gold
 # The old Practice choice cannot be selected or confirmed.
 m.put('popup_open',1);m.put('popup_choice',2);m.call('show_map');m.put('popup_open',1);m.call('map_confirm');assert m.get('screen_mode')==1
 m.put('popup_choice',0);m.call('map_confirm');assert m.get('screen_mode')==2 and m.get('battle.contract')==1
 print(f'PASS ${page:04X}: all six abilities, conversion/summon caps and delays, 3072 native seed selections, region gates, retry, awards, and practice menu.')
