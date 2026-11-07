#!/usr/bin/env python3
"""Skip every soldier through raw Fire input without losing the second press to redraw."""
import importlib.util
from pathlib import Path
spec=importlib.util.spec_from_file_location('runtime',Path(__file__).with_name('test-runtime.py'))
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
def clock(m,t):m.mem.ram[0x13]=(t>>8)&255;m.mem.ram[0x14]=t&255
for page in [0xd600,0xd700]:
 m=r.Machine(page)
 for count in [2,3,4,5]:
  m.mem.ram[r.LABELS['army_units']:r.LABELS['army_units']+5]=bytes([1]*count+[255]*(5-count))
  m.put('army_count',count);m.put('army_capacity',count)
  m.put('selected_location',0);m.put('battle.encounter_seed',1);m.call('battle.start')
  # Paint the initial battle, just as the main loop does before accepting clicks.
  m.call('battle.draw')
  initial=list(m.mem.ram[r.LABELS['battle.unit_cell']:r.LABELS['battle.unit_cell']+m.get('battle.unit_count')])
  for soldier in range(count):
   assert m.get('battle.selected_unit')==soldier
   t=100+soldier*100
   clock(m,t);m.release();m.put('dirty',0);m.fire()
   assert m.get('battle.unit_acted')==int(soldier>0)
   # No visual change on the first tap: blocking repaint would swallow rapid input.
   assert m.get('dirty')==0, 'Arming a double-Fire on the selected soldier must not redraw'
   m.idle(3)
   assert m.get('battle.selected_unit')==soldier, 'Held Fire must not skip'
   clock(m,t+4);m.release()
   clock(m,t+10);m.fire();m.release()
   assert m.get('battle.turn_number')==(2 if soldier==count-1 else 1)
   if soldier<count-1:assert m.get('battle.selected_unit')==soldier+1
  assert m.get('battle.enemy_busy')==0
  assert all(m.mem.ram[r.LABELS['battle.unit_acted']+i]==0 for i in range(count))
  current=list(m.mem.ram[r.LABELS['battle.unit_cell']:r.LABELS['battle.unit_cell']+m.get('battle.unit_count')])
  assert current[count:]!=initial[count:], 'Enemies must actually move after the last skip'
  # Selecting a different soldier still needs a visible focus update.
  m.put('battle.cursor_cell',7);m.put('dirty',0);clock(m,1000);m.fire();m.release()
  assert m.get('battle.selected_unit')==1 and m.get('dirty')==1
 print(f'PASS ${page:04X}: raw double-Fire skips all 2..5 soldiers, held Fire stays safe, last skip runs enemy movement and starts round 2; selecting another soldier redraws.')
