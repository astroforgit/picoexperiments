#!/usr/bin/env python3
"""Retreat button: reachable by cursor, ends the battle and costs a third of the purse."""
import importlib.util
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
def battle(page,gold,duel=0):
 m=r.Machine(page);m.put('gold',gold,2);m.put('selected_location',0);m.put('battle.encounter_seed',1)
 m.put('battle.duel',duel);m.call('battle.start')
 for _ in range(7):m.cpu.x=1;m.call('battle.navigate')
 m.cpu.x=3;m.call('battle.navigate');assert m.get('battle.cursor_cell')==43
 # The gold focus frame must surround RETREAT, not SKIP UNIT.
 m.put('screen_mode',2);m.put('render_bank',m.get('back_bank'));m.call('draw_city');f=m.get('front_bank')*65536
 assert m.mem.vram[f+191*320+233]==2 and m.mem.vram[f+191*320+7]==7
 m.call('battle.confirm');assert m.get('battle.game_state')==3 and m.get('popup_open')==0
 return m
for page in (0xd600,0xd700):
 for difficulty,purse in ((0,50),(1,50),(2,50)):  # every level pays the same gold
  m=r.Machine(page);m.put('difficulty',difficulty);m.put('battle.contract',0);m.put('battle.duel',0)
  m.call('battle.victory_reward');assert m.get('battle.reward',2)==purse,(difficulty,m.get('battle.reward',2))
 m=battle(page,100);assert m.get('battle.reward',2)==16 and m.get('gold',2)==84  # 50 // 3
 m=battle(page,10);assert m.get('gold',2)==0                                      # never negative
 m=battle(page,100,duel=1);assert m.get('battle.reward',2)==5 and m.get('gold',2)==95  # duel purse 15
 # Escape menu retreat costs the same.
 m=r.Machine(page);m.put('gold',100,2);m.put('selected_location',0);m.put('battle.encounter_seed',1);m.call('battle.start')
 m.call('battle.cancel');m.put('popup_choice',1);m.call('battle.confirm')
 assert m.get('battle.game_state')==3 and m.get('gold',2)==84
 print(f'PASS ${page:04X}: RETREAT button reachable and highlighted, battle ends, one third of the scaled purse lost, gold floors at 0, duel and menu retreat agree.')
