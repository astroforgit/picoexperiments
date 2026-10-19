#!/usr/bin/env python3
"""Raw/buffered O launches a reversible ending preview from each game screen."""
import importlib.util
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)

def at(m,label=''):m.run_until(r.LABELS['outro.wait_action'+label])
def advance(m,count=12000):
 for tick in range(count):
  if tick%1000==0:m.mem.ram[0x14]=(m.mem.ram[0x14]+1)&255
  m.cpu.step()
def snapshot(m):
 names={'screen_mode':1,'gold':2,'building_levels':5,'army_units':5,'army_paid_lo':5,'army_paid_hi':5,'army_count':1,'army_capacity':1,'region_wins':4,'selected_plot':1,'selected_location':1,'popup_open':1,'popup_choice':1}
 if m.get('screen_mode')==2:
  names.update({f'battle.{s}':1 for s in ['unit_count','hero_count','turn_number','game_state','selected_unit','contract','encounter_seed','reward_committed']})
  names.update({f'battle.{s}':12 for s in ['unit_type','unit_team','unit_cell','unit_hp','unit_acted','unit_charge','unit_spawned']})
 return {n:bytes(m.mem.ram[r.LABELS[n]:r.LABELS[n]+length]) for n,length in names.items()}

for register_page,mode,buffered in [(0xd600,0,True),(0xd600,2,False),(0xd700,1,False),(0xd700,3,True)]:
 m=r.Machine(register_page)
 if mode==0:m.put('gold',321,2);m.fire();m.release() # Preserve an open palace popup.
 elif mode==1:m.call('show_map');m.put('selected_location',2)
 elif mode==2:m.put('selected_location',0);m.call('battle.start')
 else:m.call('clear_army');m.put('gold',0,2);m.call('check_game_over')
 m.call('draw_city');before=snapshot(m)
 m.mem.ram[0xd209]=0x48 # Uppercase O must normalize to the same Atari code.
 m.mem.ram[0xd20f]=251
 m.mem.ram[0x2fc]=0x48 if buffered else 255
 m.cpu.sp=255;m.cpu.stPushWord(0x05ff);m.cpu.pc=r.LABELS['poll_input'];at(m)
 assert m.get('outro.preview_mode')==1
 for page in range(3):
  assert m.get('outro.page')==page
  at(m,'.press');advance(m);assert m.get('outro.page')==page,'Holding O must not advance pictures'
  m.mem.ram[0xd010]=0;at(m,'.finish');advance(m);assert m.get('outro.page')==page
  m.mem.ram[0xd010]=1
  if page<2:at(m)
  else:m.run_until(0x600)
 assert m.get('outro.preview_mode')==0 and before==snapshot(m),'Preview must preserve the entire campaign/battle state'
 m.idle(4) # O remains held; it must not relaunch or act as Fire.
 assert before==snapshot(m)
 m.mem.ram[0xd20f]=255;m.mem.ram[0x2fc]=255;m.idle(2)
 assert m.get('action_latched')==0
 m.call('draw_city');assert before==snapshot(m) and m.get('dirty')==0
 print(f'PASS ${register_page:04X}, screen {mode}: raw/buffered uppercase O, three pages, held-key suppression, return and redraw with campaign/popup/battle state intact.')
