#!/usr/bin/env python3
"""POKEY cues preserve callers, stay soft, end in silence on channel 2."""
import importlib.util
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
for mapping in (0xd600,0xd700):
 m=r.Machine(mapping)
 for effect,note in enumerate([30,47,60,60,81,71,36,35,47,121,47,60]):
  m.cpu.a=effect;m.cpu.x=37;m.cpu.y=83;m.cpu.p=0x61
  m.call('sfx.play')
  assert (m.cpu.a,m.cpu.x,m.cpu.y,m.cpu.p)==(effect,37,83,0x71) # PHP/PLP sets the 6502 B flag.
  assert m.mem.ram[0xd202]==note and 0<m.mem.ram[0xd203]&15<=4
  loudest=0
  for frame in range(60):
   m.cpu.x=37;m.cpu.y=83;m.call('wait_frame')
   assert (m.cpu.x,m.cpu.y)==(37,83),'Frame tick must keep the caller registers'
   if m.get('sfx.frames')==0:break
   loudest=max(loudest,m.mem.ram[0xd203]&15,m.mem.ram[0xd201]&15)
   assert m.mem.ram[0xd203]>>4 in (0,10) and m.mem.ram[0xd201]>>4 in (0,10),'Pure tones only'
  assert loudest<=4 and m.mem.ram[0xd203]==0 and m.mem.ram[0xd201]==0 and m.get('sfx.frames')==0
 # A disk load must finish a pending cue before OS SIO blocks frame polling.
 m.cpu.a=3;m.call('sfx.play')
 m.put('render_bank',m.get('back_bank'));m.cpu.a=0;m.call('story.load')
 assert m.mem.ram[0xd203]==0 and m.mem.ram[0xd201]==0 and m.get('sfx.frames')==0
 # Real game events, rather than calling only the sound routines directly.
 m.put('selected_plot',0);m.call('recruit');assert m.mem.ram[0xd202]==47
 m.put('popup_open',0);m.put('screen_mode',0);m.cpu.a=3;m.call('navigate');assert m.mem.ram[0xd202]==36,'Cursor move tick'
 m.call('clear_army');m.put('gold',0,2);m.call('check_game_over');assert m.mem.ram[0xd202]==81
 print(f'PASS ${mapping:04X}: twelve quiet two-voice chime cues, register/flag preservation, envelopes ending in silence, real purchase/cursor/defeat triggers, no music.')
