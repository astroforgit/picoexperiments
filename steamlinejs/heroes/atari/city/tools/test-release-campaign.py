#!/usr/bin/env python3
"""Replay a complete shopping/tactics plan through native 6502 gameplay.
No gold, army, HP, wins or outcomes are injected. Only input selection is set.
Drawing during fights is bypassed; dedicated animation tests cover rendering.
"""
import importlib.util,json,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
native=json.loads((r.ROOT/'content.json').read_text())
family={b['id']:i for i,b in enumerate(native['buildings'])}
result=[]
for scenario in ('native-campaign-plan','native-defeat-plan'):
 plan=json.loads((r.ROOT/f'../../release/{scenario}.json').resolve().read_text())
 data=plan['config'];run=plan['run']
 for mapping in (0xd600,0xd700):
  m=r.Machine(mapping);m.put('battle.encounter_seed',run['seed'])
  # Bypass draw calls only, retaining all movement/combat/AI/economy routines.
  m.mem.ram[r.LABELS['battle.draw']]=0x60
  def arr(name,i):return m.mem.ram[r.LABELS['battle.'+name]+i]
  for fight in run['battles']:
   for e in (e for e in run['ledger'] if e['beforeFight']==fight['fight']):
    label=e['label']
    if e['action']=='build':m.put('selected_plot',family[label.split()[0]]);m.call('purchase')
    elif e['action']=='recruit':
     name=label[len('Recruit '):];u=next(u for u in data['players'] if u['name']==name)
     m.put('selected_plot',family[u['family']]);m.call('recruit')
    else:
     slot=int(label.split()[2].rstrip(':'))-1;m.put('selected_plot',6+slot);m.call('purchase')
    assert m.get('gold',2)==e['goldAfter'],(mapping,fight['fight'],label,m.get('gold',2),e['goldAfter'])
   m.put('selected_location',[0,1,2,4][fight['region']]);m.call('battle.start')
   assert m.get('screen_mode')==2
   heroes=m.get('battle.hero_count')
   for round_no in sorted(set(e['round'] for e in fight['trace'])):
    if m.get('battle.game_state'):break
    for actor in range(heroes):
     actions=[e for e in fight['trace'] if e['round']==round_no and e.get('actor')==actor]
     if not actions or not arr('unit_hp',actor) or arr('unit_team',actor):continue
     assert m.get('battle.turn_number')==round_no,(fight['fight'],round_no,m.get('battle.turn_number'))
     m.put('battle.selected_unit',actor)
     for e in actions:
      if e['action']=='move':
       assert arr('unit_cell',actor)==e['from'],(fight['fight'],e,arr('unit_cell',actor))
       m.put('battle.cursor_cell',e['to']);m.call('battle.confirm_cell')
       assert arr('unit_cell',actor)==e['to'],(fight['fight'],e)
      elif e['action']=='attack':
       target=e['target'];assert arr('unit_hp',target)==e['hpBefore'],(fight['fight'],round_no,e,arr('unit_hp',target))
       m.put('battle.cursor_cell',arr('unit_cell',target));m.call('battle.confirm_cell')
      elif e['action']=='skip':m.call('battle.skip_hero')
     if not m.get('battle.game_state') and m.get('battle.turn_number')==round_no and not arr('unit_acted',actor):
      m.put('battle.selected_unit',actor);m.call('battle.skip_hero')
   assert m.get('battle.game_state')=={'victory':1,'defeat':2}[fight['outcome']],(mapping,fight['fight'],m.get('battle.game_state'))
   assert m.get('gold',2)==fight.get('goldAfter',fight['goldBefore']),(fight['fight'],m.get('gold',2),fight.get('goldAfter',fight['goldBefore']))
   result.append(dict(scenario=scenario,mapping=hex(mapping),fight=fight['fight'],region=fight['regionName'],gold=m.get('gold',2),army=m.array('army_units')))
   if not (run['completed'] and fight['fight']==run['fights']):m.call('battle.confirm')
  assert m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4]==bytes(run['wins'])
  assert m.get('gallery.wins')==run['victories'], 'Gallery discovery must count committed wins only'
  if run['completed']:
   assert bin(m.get('gallery.collected')).count('1')==7, 'The standard route finds seven; a fourth Forest win gives the optional eighth'
   # Dispatch the real ending after the actual final kill, through the main loop.
   m.cpu.pc=r.LABELS['main_loop'];m.run_until(r.LABELS['outro.wait_action'])
   for page in range(3):
    assert m.get('outro.page')==page
    m.run_until(r.LABELS['outro.wait_action.press'])
    m.mem.ram[0xd010]=0;m.run_until(r.LABELS['outro.wait_action.finish'])
    m.mem.ram[0xd010]=1
    m.run_until(r.LABELS['outro.wait_action'] if page<2 else r.LABELS['main_loop'])
   assert m.get('screen_mode')==0 and m.get('gold',2)==r.START_GOLD and m.get('army_count')==2
  else:
   assert run['gameOver'] and m.get('army_count')==0
   m.call('check_game_over');assert m.get('screen_mode')==3
   m.call('draw_city')
   start=m.get('front_bank')*65536
   assert m.mem.vram[start:start+46080]==(r.ROOT/'generated/story-4.bin').read_bytes()[:46080]
   m.release();m.fire();assert m.get('screen_mode')==0 and m.get('army_count')==2
  print(f"PASS ${mapping:04X}: {run['strategy']}, {run['fights']} fights, real paid purchases/upgrades and native combat, {'final boss + automatic wedding outro' if run['completed'] else 'natural battle losses + illustrated bankruptcy + restart'}.",flush=True)
path=Path(sys.argv[1]) if len(sys.argv)>1 else r.ROOT/'../../release/native-campaign-results.json'
path.write_text(json.dumps(result,indent=2)+'\n')
