#!/usr/bin/env python3
"""The former development O shortcut must be inert in the release game."""
import importlib.util
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
for mapping in (0xd600,0xd700):
 m=r.Machine(mapping)
 for mode in range(4):
  m.call('new_city')
  if mode==1:m.call('show_map')
  elif mode==2:m.put('selected_location',0);m.call('battle.start')
  elif mode==3:m.call('clear_army');m.put('gold',0,2);m.call('check_game_over')
  before=(m.get('screen_mode'),m.get('gold',2),m.get('army_count'),m.get('popup_open'))
  for code in (0x08,0x48):m.key(code)
  assert before==(m.get('screen_mode'),m.get('gold',2),m.get('army_count'),m.get('popup_open'))
 assert 'outro.preview' not in r.LABELS
 print(f'PASS ${mapping:04X}: O shortcut removed in city, map, battle and game over; raw/buffered uppercase input is inert.')
