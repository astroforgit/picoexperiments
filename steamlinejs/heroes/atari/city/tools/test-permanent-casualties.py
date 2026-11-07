#!/usr/bin/env python3
"""A killed or converted battlefield soldier cannot return to the campaign army."""
import importlib.util
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
def setunit(m,key,i,value):m.mem.ram[r.LABELS['battle.'+key]+i]=value
def setup(m):
 m.call('new_city');m.mem.ram[r.LABELS['army_units']:r.LABELS['army_units']+5]=bytes([1,255,4,255,1]);m.put('army_count',3)
 m.mem.ram[r.LABELS['army_paid_lo']:r.LABELS['army_paid_lo']+5]=bytes([25,0,50,0,25]);m.mem.ram[r.LABELS['building_levels']+3]=2;m.call('capacity')
 m.put('selected_location',0);m.put('battle.encounter_seed',1);m.call('battle.start')
 assert [m.mem.ram[r.LABELS['battle.hero_army_slot']+i] for i in range(3)]==[0,2,4]
def kill(m,hero,zombie=False):
 attacker=m.get('battle.hero_count');setunit(m,'unit_type',attacker,19 if zombie else 15)
 setunit(m,'unit_hp',hero,1);m.put('battle.attacker_unit',attacker);m.put('battle.defender_unit',hero);m.call('battle.attack_units')
for page in [0xd600,0xd700]:
 m=r.Machine(page)
 for result in ['win','defeat','retreat']:
  setup(m);gold=m.get('gold',2);kill(m,1);setunit(m,'unit_hp',0,2)
  assert m.array('army_units')==[1,255,255,255,1] and m.get('army_count')==2
  assert m.array('army_paid_lo')[2]==0 and m.array('army_paid_hi')[2]==0 and m.get('gold',2)==gold
  if result=='win':
   for i in range(m.get('battle.hero_count'),m.get('battle.unit_count')):setunit(m,'unit_hp',i,0)
   m.call('battle.check_result');assert m.get('battle.game_state')==1
  elif result=='defeat':
   kill(m,0);kill(m,2);m.call('battle.check_result');assert m.get('battle.game_state')==2
   assert m.get('army_count')==0
  else:m.put('popup_open',1);m.put('popup_choice',1);m.call('battle.confirm');assert m.get('battle.game_state')==3
  m.call('battle.confirm');assert m.get('screen_mode')==1
  assert m.array('army_units')[2]==255
  if result!='defeat':
   m.call('battle.start');assert m.get('battle.hero_count')==2
   assert [m.mem.ram[r.LABELS['battle.hero_army_slot']+i] for i in range(2)]==[0,4]
   assert m.mem.ram[r.LABELS['battle.unit_hp']]==4 # A living survivor recovers HP.
  else:m.call('can_enter_battle');assert not m.cpu.p&1
 setup(m);kill(m,1,True);assert m.array('army_units')[2]==255 and m.get('army_count')==2
 assert m.mem.ram[r.LABELS['battle.unit_type']+1]==19 and m.mem.ram[r.LABELS['battle.unit_team']+1]==1
 m.put('battle.defender_unit',1);m.call('battle.attack_units');assert m.get('army_count')==2 # No double removal.
 # Enemy deaths never alter army slots or refund money.
 setup(m);before=m.array('army_units');m.put('battle.attacker_unit',0);m.put('battle.defender_unit',3);setunit(m,'unit_hp',3,1);m.call('battle.attack_units');assert m.array('army_units')==before and m.get('army_count')==3
 print(f'PASS ${page:04X}: original slot mapping with gaps, immediate permanent deaths, victory/defeat/retreat persistence, no refunds, zombie conversions, no double removal, living survivor recovery and empty-army battle lock.')
