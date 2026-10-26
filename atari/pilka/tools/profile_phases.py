#!/usr/bin/env python3
"""Average CPU cycles spent between renderer milestones (headless model)."""
import sys,collections
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
r=load_labels(ROOT/'gen/runtime.asm.lab');a=Atari(ROOT/'pilka.xex');a.boot()
while a.cpu.pc!=0x975b:a.cpu.step()
a.next_frame=a.cpu.processorCycles+a.frame_cycles
marks=[m for m in ('RENDER','COLOUR_ROWS','SCAN_BLOCK','SCAN_DONE','COMPOSE_BACKGROUND','PLAYERS','BALL','START_LIST') if m in r]
at={r[m]:m for m in marks};step=a.cpu.step;last=[None,0];acc=collections.Counter();n=collections.Counter()
def p():
 pc=a.cpu.pc
 if pc in at and on[0]:
  m=at[pc]
  if m=='RENDER':last[0]=None
  if last[0] and last[0]!=m:acc[(last[0],m)]+=a.cpu.processorCycles-last[1];n[(last[0],m)]+=1
  if last[0]!=m:last[:]=[m,a.cpu.processorCycles]
 return step()
on=[False];a.cpu.step=p
for f in range(int(sys.argv[1]) if len(sys.argv)>1 else 700):
 if f==400:on[0]=True
 a.set_input(trig=100<=f<125 or (f>750 and f%160<12),stick=([7,14,11,13][(f//140)%4] if f>600 else 15));a.run_frames(1)
for k in acc:print(f'{k[0]:>20} -> {k[1]:<20} {acc[k]//n[k]:6d} x{n[k]}')
