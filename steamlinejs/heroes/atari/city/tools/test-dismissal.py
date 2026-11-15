"""Two full refunds then one 20% fee, repeating across army slots."""
import importlib.util
from pathlib import Path
spec=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
for page in (0xd600,0xd700):
 m=r.Machine(page);m.call('clear_army');m.put('gold',1000,2)
 for i in range(9):
  slot=i%5;unit=(0,1,2)[i%3];price=(15,25,60)[unit]
  m.mem.ram[r.LABELS['army_units']+slot]=unit;m.mem.ram[r.LABELS['army_paid_lo']+slot]=price
  m.put('army_count',1);m.put('selected_plot',6+slot)
  before=m.get('gold',2);cycle=m.get('dismiss_cycle');m.call('describe_selection')
  fee=(price+4)//5 if cycle==2 else 0
  assert m.get('secondary_cost',2)==price-fee
  m.call('describe_selection');assert m.get('dismiss_cycle')==cycle,'Preview must not advance cycle'
  m.call('dismiss_unit');assert m.get('gold',2)==before+price-fee
  assert m.get('dismiss_cycle')==(i+1)%3 and m.get('army_count')==0
  m.call('dismiss_unit');assert m.get('dismiss_cycle')==(i+1)%3,'Empty slot must not advance cycle'
 m.call('new_city');assert m.get('dismiss_cycle')==0
 print(f'PASS ${page:04X}: nine dismissals, every third charged, exact refunds, independent slots, previews/empty slots do not advance, new-game reset.')
