"""Check every difficulty roster through pointers in the assembled game."""
import importlib.util,json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('runtime',root/'tools/test-runtime.py');runtime=importlib.util.module_from_spec(spec);spec.loader.exec_module(runtime)
data=json.loads((root/'content.json').read_text())
variants=[v for region in data['encounterConfig']['regions'] for stage in region['stages'] for v in stage['variants']]
m=runtime.Machine(0xd600);ram=m.mem.ram;labels=runtime.LABELS
for level,key in enumerate(('enemies','mediumEnemies','hardEnemies')):
 assert ram[labels['battle.difficulty_group_base']+level]==level*len(variants)
 for i,v in enumerate(variants):
  slot=level*len(variants)+i
  address=ram[labels['battle.enemy_ptr_lo']+slot]+256*ram[labels['battle.enemy_ptr_hi']+slot]
  expected=[]
  for j,unit in enumerate(v[key]):expected.extend((15+next(k for k,u in enumerate(data['enemies']) if u['id']==unit),(6,13,20,27,34)[j]))
  expected.append(255)
  assert list(ram[address:address+len(expected)])==expected,(level,i,v['name'])
assert labels['battle_groups_end']<=0xc000
print(f'PASS: all {len(variants)*3} assembled difficulty rosters, shared pointers, deployment cells and table bounds.')
