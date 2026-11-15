"""Exercise actual native Forest selection before and after its first three wins."""
import importlib.util
from pathlib import Path
s=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(s);s.loader.exec_module(r)
m=r.Machine(0xd600);ram=m.mem.ram;labels=r.LABELS
# Find a seed selecting the final-stage Nymph-only group (index 11) after unlock.
seed=next(i for i in range(256) if ram[labels['battle.forest_optional_seed']+i]==11)
for wins in range(4):
 m.put('selected_location',0);m.put('region_wins',wins);m.put('battle.encounter_seed',seed)
 m.call('battle.start')
 first=m.get('battle.hero_count');count=m.get('battle.unit_count')
 enemy=[ram[labels['battle.unit_type']+i] for i in range(first,count)]
 assert all(u==28 for u in enemy)==(wins==3),(wins,enemy)
print('PASS: assembled Atari selects mixed groups for first three Forest wins, Nymph-only group on optional return.')
