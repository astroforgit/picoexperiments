#!/usr/bin/env python3
"""Integrated city-to-battle 6502 tests under the same functional VBXE model."""
import importlib.util
from pathlib import Path
spec=importlib.util.spec_from_file_location('runtime',Path(__file__).with_name('test-runtime.py'))
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)

def arr(m,name,n=12):
 a=r.LABELS['battle.'+name];return list(m.mem.ram[a:a+n])
def putarr(m,name,values):
 a=r.LABELS['battle.'+name];m.mem.ram[a:a+len(values)]=bytes(values)
def play(m,cap=300):
 # Greedy test player: attack lowest HP reachable enemy, otherwise advance.
 for _ in range(cap):
  if m.get('battle.game_state'):return m.get('battle.game_state')
  selected=m.get('battle.selected_unit');cells=arr(m,'unit_cell');hp=arr(m,'unit_hp');teams=arr(m,'unit_team')
  attacks=[];moves=[]
  for cell in range(42):
   m.cpu.a=cell;m.call('battle.action_at');kind=m.cpu.a
   if kind==2:
    target=m.get('battle.target_unit');attacks.append((hp[target],cell))
   elif kind==1:
    ds=[]
    for j in range(m.get('battle.unit_count')):
     if hp[j] and teams[j]:
      m.cpu.a=cell;m.cpu.x=cells[j];m.call('battle.distance_cells');ds.append(m.cpu.a)
    moves.append((min(ds),cell))
  if attacks:cell=min(attacks)[1]
  elif moves:cell=min(moves)[1]
  else:cell=42
  m.put('battle.cursor_cell',cell);m.call('battle.confirm')
 raise AssertionError('Battle failed to terminate')

if __name__=='__main__':
 import runpy
 runpy.run_path(str(Path(__file__).with_name('test-lowrez.py')),run_name='__main__')
