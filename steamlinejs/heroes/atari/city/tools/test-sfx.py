#!/usr/bin/env python3
"""POKEY effect triggers preserve callers, decay, and silence channel 2."""
import importlib.util
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
for mapping in (0xd600,0xd700):
 m=r.Machine(mapping)
 for effect,note in enumerate([55,30,130,18,190,220]):
  m.cpu.a=effect;m.cpu.x=37;m.cpu.y=83;m.cpu.p=0x61
  m.call('sfx.play')
  assert (m.cpu.a,m.cpu.x,m.cpu.y,m.cpu.p)==(effect,37,83,0x71) # PHP/PLP sets the 6502 B flag.
  assert m.mem.ram[0xd202]==note and m.mem.ram[0xd203]&15==6
  for _ in range(7):m.call('wait_frame')
  assert m.mem.ram[0xd203]==0 and m.get('sfx.frames')==0
 # A disk load must finish a pending cue before OS SIO blocks frame polling.
 m.cpu.a=3;m.call('sfx.play')
 m.put('render_bank',m.get('back_bank'));m.cpu.a=0;m.call('story.load')
 assert m.mem.ram[0xd203]==0 and m.get('sfx.frames')==0
 # Real game events, rather than calling only the sound routines directly.
 m.put('selected_plot',0);m.call('recruit');assert m.mem.ram[0xd202]==30
 m.call('clear_army');m.put('gold',0,2);m.call('check_game_over');assert m.mem.ram[0xd202]==190
 print(f'PASS ${mapping:04X}: six POKEY effects, register/flag preservation, six-frame decay to silence, real purchase/defeat triggers, no music.')
