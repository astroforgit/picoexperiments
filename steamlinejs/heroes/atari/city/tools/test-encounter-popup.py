#!/usr/bin/env python3
"""Native encounter controls must match battle/practice availability."""
import importlib.util,json,sys
from pathlib import Path
spec=importlib.util.spec_from_file_location('runtime',Path(__file__).with_name('test-runtime.py'))
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
def enabled(m,choice):
 m.cpu.a=choice;m.call('map_choice_enabled');return bool(m.cpu.p&1)
def open_popup(m,location):
 m.call('show_map');m.put('selected_location',location);m.call('map_confirm');assert m.get('popup_open')==1
for page in [0xd600,0xd700]:
 m=r.Machine(page)
 for location in [0,1,2,4]:
  for unlocked in [False,True]:
   for army in [False,True]:
    m.call('new_city')
    if unlocked:m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4]=bytes([3]*4)
    if not army:m.call('clear_army')
    m.put('selected_location',location)
    ready=army and (location==0 or unlocked)
    practice=army and location==0   # Dark Forest duel
    allowed=({0} if ready else set())|{1}|({2} if practice else set())
    for c in range(3):assert enabled(m,c)==(c in allowed),(page,location,unlocked,army,c)
    open_popup(m,location);assert m.get('popup_choice')==(0 if ready else 1)
    for direction in range(4):
     seen=set()
     for _ in range(6):
      m.cpu.x=direction;m.call('map_navigate');seen.add(m.get('popup_choice'))
     assert seen==allowed,(page,location,unlocked,army,direction,seen,allowed)
    for c in set(range(3))-allowed:
     before=(m.get('gold',2),bytes(m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4]))
     m.put('popup_choice',c);m.call('map_confirm');assert m.get('screen_mode')==1 and m.get('popup_open')==1
     assert before==(m.get('gold',2),bytes(m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4]))
    m.put('popup_choice',1);m.call('map_confirm');assert m.get('popup_open')==0
 # A duel: one random duel.json enemy (by RANDOM & 31), its own header, that enemy's
 # purse and no region progress or paintings; the next normal fight uses the contract.
 duel=json.loads((r.ROOT/'../../duel.json').resolve().read_text())
 slots=[i for i,e in enumerate(duel['enemies']) for _ in range(e['weight'])];ids=[e['id'] for e in json.loads((r.ROOT/'content.json').read_text())['enemies']]
 seen=set()
 for random in list(range(32))+[255]:
  m.call('new_city');m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4]=bytes([7,0,0,0])
  m.mem.ram[0xd20a]=random;open_popup(m,0);m.put('popup_choice',2);m.call('map_confirm')
  assert m.get('screen_mode')==2 and m.get('battle.duel')==1
  pick=duel['enemies'][slots[random&31]];seen.add(pick['enemy'])
  enemies=[i for i in range(m.get('battle.unit_count')) if m.mem.ram[r.LABELS['battle.unit_team']+i]==1]
  assert len(enemies)==1 and m.mem.ram[r.LABELS['battle.unit_type']+enemies[0]]==15+ids.index(pick['enemy']),(random,pick)
  m.call('battle.title_pointer');assert m.get('text_src',2)==r.LABELS['battle.s_duel_title']
  wins=bytes(m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4]);m.put('gold',0,2);m.put('battle.reward_committed',0)
  m.call('battle.award');assert m.get('gold',2)==pick['reward'] and wins==bytes(m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4])
 assert seen=={e['enemy'] for e in duel['enemies']},seen
 assert m.get('gallery.painting_pending')==0
 m.call('show_map');open_popup(m,0);m.put('popup_choice',0);m.call('map_confirm');assert m.get('battle.duel')==0
 assert sum(m.mem.ram[r.LABELS['battle.unit_team']+i]==1 for i in range(m.get('battle.unit_count')))>1
 # Verify the actual rendered disabled Fight has no active gold outline.
 m.call('new_city');open_popup(m,1);m.call('draw_encounters');bank=m.get('front_bank')
 pixels=m.mem.vram[bank*65536:bank*65536+64000]
 button=[pixels[y*320+x] for y in range(134,149) for x in range(32,151)]
 assert 2 not in button and button.count(7)>1000
 if '--screens' in sys.argv and page==0xd600:
  from PIL import Image
  output=Path(sys.argv[sys.argv.index('--screens')+1]);output.mkdir(parents=True,exist_ok=True)
  def save(name):
   m.call('draw_encounters');start=m.get('front_bank')*65536;im=Image.frombytes('P',(320,200),bytes(m.mem.vram[start:start+64000]));im.putpalette(m.mem.palette);im.save(output/name)
  save('encounter-popup-locked.png')
  m.call('new_city');m.mem.ram[r.LABELS['region_wins']]=1;open_popup(m,0);save('encounter-popup-ready.png')
 print(f'PASS ${page:04X}: locked/no-army controls disabled; default Back; all directions skip unavailable Fight/Duel; Dark Forest duel vs one weighted random enemy with its own purse and no progress; enabled actions return after unlock; disabled button pixels have no active outline.')
