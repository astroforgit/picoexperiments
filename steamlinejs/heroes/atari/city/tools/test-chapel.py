#!/usr/bin/env python3
import importlib.util,json
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
def check(page,capture=False):
 m=r.Machine(page);assert m.get('army_capacity')==3 and m.get('gold',2)==50
 assert m.array('army_paid_lo')==[25,25,0,0,0]
 m.put('selected_plot',0);m.call('recruit');assert m.array('army_units')==[1,1,1,255,255]
 m.put('gold',2000,2);m.call('recruit');assert m.get('notice')==4 and m.get('gold',2)==2000
 for level,cost in [(1,80),(2,130),(3,190)]:
  m.put('selected_plot',3);before=m.get('gold',2);m.call('purchase')
  assert m.array('building_levels')[3]==level and m.get('gold',2)==before-cost
  assert m.get('army_capacity')==min(3+level,5)
  m.call('describe_selection');assert m.get('secondary_available')==0 and m.get('target_index')==255
  before=m.get('gold',2);army=m.array('army_units');m.call('recruit');assert m.get('gold',2)==before and m.array('army_units')==army
  if capture:
   m.put('popup_open',1);m.screenshot('chapel-level-'+str(level)+'.png');m.put('popup_open',0)
  if level<3:
   m.put('selected_plot',0);m.call('recruit');assert m.get('army_count')==3+level
 # Existing troops retain their original purchase value.
 m.put('selected_plot',10);before=m.get('gold',2);m.call('dismiss_unit');assert m.get('gold',2)==before+12
 m.put('selected_plot',0);before=m.get('gold',2);m.call('recruit');assert m.get('gold',2)==before-15 and m.array('army_paid_lo')[4]==15
 m.put('selected_plot',10);before=m.get('gold',2);m.call('dismiss_unit');assert m.get('gold',2)==before+7
 # Discounted recruit + upgrade retains its true investment for dismissal.
 m.put('selected_plot',0);m.call('purchase');m.mem.ram[r.LABELS['building_levels']]=2;m.call('recruit');m.mem.ram[r.LABELS['building_levels']]=3
 m.put('selected_plot',10);m.call('purchase');assert m.array('army_units')[4]==2 and m.array('army_paid_lo')[4]==65
 before=m.get('gold',2);m.call('dismiss_unit');assert m.get('gold',2)==before+32
 # All imported native numbers match the file (Chapel types are reserved, unavailable).
 d=json.loads((r.ROOT/'../../greenhaven-unit-balance.json').read_text())
 for i,u in enumerate(d['players']):
  if u['family']=='chapel':continue
  for key,table in [('hp','type_hp'),('damage','type_damage'),('move','type_move'),('shootRange','type_shoot_range')]:assert m.mem.ram[r.LABELS['battle.'+table]+i]==u[key]
 for i,u in enumerate(d['enemies']):
  for key,table in [('hp','type_hp'),('damage','type_damage'),('move','type_move'),('shootRange','type_shoot_range')]:assert m.mem.ram[r.LABELS['battle.'+table]+15+i]==u[key]
 # Horse types use three distinct full-body sprite sets.
 assert [m.mem.ram[r.LABELS['battle.hero_set']+i] for i in (6,7,8)]==[108,114,120]
 if capture:
  m.call('new_city');m.screenshot('chapel-locked-slots.png')
  m.mem.ram[r.LABELS['army_units']:r.LABELS['army_units']+5]=bytes([6,7,8,255,255]);m.put('army_count',3);m.put('selected_location',0);m.call('battle.start');m.screenshot('mounted-battle.png')
 print(f'PASS ${page:04X}: imported stats, mounted types, Chapel capacity, non-recruitment, discount and paid-price refunds.')
if __name__=='__main__':check(0xd600,True);check(0xd700)
