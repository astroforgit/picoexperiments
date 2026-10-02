#!/usr/bin/env python3
import importlib.util,json
from pathlib import Path
spec=importlib.util.spec_from_file_location('battle_tests',Path(__file__).with_name('test-battle.py'))
b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b);r=b.r
content=json.loads((r.ROOT/'content.json').read_text())
def play_logic(m):
 # Animation rendering is covered by test-hero-animation.py.
 a=r.LABELS['battle.draw'];saved=m.mem.ram[a];m.mem.ram[a]=0x60
 try:return b.play(m)
 finally:m.mem.ram[a]=saved

def check(page,capture=False):
 m=r.Machine(page)
 assert m.get('gold',2)==50 and m.array('army_units')==[1,1,255,255,255]
 assert m.array('building_levels')==[2,0,0,0,0] and m.get('army_count')==2
 assert m.mem.vram[0x20000:0x7f000]==(r.ROOT/'generated/vram.bin').read_bytes()
 m.fire();assert m.get('popup_open')==1;m.idle(60);assert m.get('gold',2)==50
 m.release();m.call('close_popup')
 m.put('selected_location',0);m.call('battle.start');assert play_logic(m)==1
 assert m.get('gold',2)==100 and m.mem.ram[r.LABELS['region_wins']]==1
 m.call('battle.award');assert m.get('gold',2)==100
 if capture:m.screenshot('lowrez-first-victory.png')
 m.call('new_city');m.put('selected_plot',0);m.call('describe_selection')
 m.key(0x0c);m.key(0x3e);m.key(0x0c)
 assert m.array('army_units')==[1,1,1,255,255] and m.get('gold',2)==25
 m.put('selected_plot',8);m.call('dismiss_unit')
 assert m.array('army_units')==[1,1,255,255,255] and m.get('gold',2)==37
 assert list(m.mem.ram[r.LABELS['battle.type_move']:r.LABELS['battle.type_move']+15])==sum((x['move'] for x in content['buildings']),[])
 m.call('new_city');m.mem.ram[r.LABELS['building_levels']+3]=2;m.call('capacity');m.mem.ram[r.LABELS['army_units']:r.LABELS['army_units']+5]=bytes([8,8,8,8,8]);m.put('army_count',5)
 total=50
 for region,location in enumerate([0,1,2,4]):
  m.put('selected_location',location)
  for stage in range(3):
   if region>=2:m.mem.ram[r.LABELS['army_units']:r.LABELS['army_units']+5]=bytes([14]*5)
   m.call('battle.start');idx=region*3+stage;assert m.get('battle.contract')==idx
   outcome=play_logic(m);assert outcome in (1,2),(page,idx)
   if outcome==2:
    # Imported user balance can defeat the greedy test player. Validate unlocks
    # and reward wiring with an explicit victory fixture, not inflated live stats.
    m.call('battle.start')
    for unit in range(m.get('battle.hero_count'),m.get('battle.unit_count')):m.mem.ram[r.LABELS['battle.unit_hp']+unit]=0
    m.call('battle.check_result');assert m.get('battle.game_state')==1
   total+=content['encounters'][idx]['reward'];assert m.get('gold',2)==total
   if capture and stage==0:m.screenshot('lowrez-region-'+str(region)+'.png')
   m.call('battle.confirm')
  assert m.mem.ram[r.LABELS['region_wins']+region]==3
 m.call('battle.start');n=m.get('battle.unit_count');warlock=b.arr(m,'unit_type').index(22)
 m.put('battle.enemy_id',warlock);m.call('battle.enemy_act');assert m.get('battle.unit_count')==n+1
 assert b.arr(m,'unit_type')[n]==26 and b.arr(m,'unit_hp')[n]==content['enemies'][11]['hp']
 m.put('battle.attacker_unit',0);m.put('battle.defender_unit',warlock);m.mem.ram[r.LABELS['battle.unit_hp']+warlock]=1
 m.call('battle.attack_units');assert m.get('battle.game_state')==1
 before=m.get('gold',2);m.call('battle.check_result');assert m.get('gold',2)==before
 print(f'PASS ${page:04X}: 50-gold start, opening victory, recruit/refund, 12 contracts, summoning and boss victory.')
if __name__=='__main__':
 check(0xd600,True);check(0xd700)
 missing=r.Machine(None);assert missing.get('hardware_ok')==0 and not missing.mem.blits
