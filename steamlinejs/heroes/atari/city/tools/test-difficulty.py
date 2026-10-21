#!/usr/bin/env python3
"""Native difficulty levels match difficulty.json: starting gold and battle rewards."""
import importlib.util,json
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
levels=json.loads((Path(__file__).resolve().parents[3]/'difficulty.json').read_text())['levels']
content=json.loads((Path(__file__).resolve().parents[1]/'content.json').read_text())
assert levels[1]['startingGold']==content['startingGold'],'Medium keeps the release balance'
def scaled(v,shift):return v+(v>>shift) if shift>0 else v-(v>>-shift) if shift<0 else v
for mapping in (0xd600,0xd700):
 m=r.Machine(mapping)
 assert m.get('difficulty')==1,'Medium is the default level'
 base=None
 for level,spec in enumerate(levels):
  m.put('difficulty',level);m.call('new_city')
  assert m.get('gold',2)==spec['startingGold'],(level,m.get('gold',2))
  for contract in (0,5,11):
   m.put('battle.reward_committed',0);m.put('battle.contract',contract);m.put('battle.region',0)
   m.put('gold',0,2)
   m.call('battle.award')
   table=r.LABELS['battle.reward_lo'];reward=m.mem.ram[table+contract]+256*m.mem.ram[r.LABELS['battle.reward_hi']+contract]
   assert m.get('gold',2)==scaled(reward,spec['rewardShift']),(level,contract,m.get('gold',2),reward)
  print(f"  {spec['name']}: start {spec['startingGold']} gold, reward shift {spec['rewardShift']}")
 m.put('difficulty',1);m.call('new_city')
 print(f'PASS ${mapping:04X}: three native difficulty levels match difficulty.json; Medium is the release default.')
