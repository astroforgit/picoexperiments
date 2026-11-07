#!/usr/bin/env python3
"""Game-loop speed: original frame waits per VBI, plus render cycle split by routine."""
import sys,json,collections
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
r=load_labels(ROOT/'gen/runtime.asm.lab');a=Atari(ROOT/'pilka.xex');a.boot()
while a.cpu.pc!=0x975b:a.cpu.step()
a.next_frame=a.cpu.processorCycles+a.frame_cycles
if '--no-render' in sys.argv:a.mem.ram[r['RENDER']]=0x60 # logic-only ceiling
regions=sorted((v,k) for k,v in r.items() if k in ('RENDER','CHAR_ROW','ROW_DIRTY','CHAR_LOOP','TILE_DIRTY','ROW_ADVANCE','COMPOSE_BACKGROUND','PLAYERS','BALL','WAIT_BLIT','BLIT','NMI','TICK','FRAME_WAIT','WAIT_TICK','BANNER_SIGNATURE'))
step=a.cpu.step;waits=0;renders=0;buckets=collections.Counter();measure=False
def counted():
 global waits,renders
 pc=a.cpu.pc
 if pc==r['FRAME_WAIT']:waits+=1
 if pc==r['RENDER']:renders+=1
 c=a.cpu.processorCycles;res=step()
 if measure:
  name='game'
  if pc>=0xf000:
   for v,k in regions:
    if pc>=v:name=k
  buckets[name]+=a.cpu.processorCycles-c
 return res
a.cpu.step=counted
args=[x for x in sys.argv[1:] if not x.startswith('--')]
frames=int(args[0]) if args else 900
for f in range(frames):
 if f==400:waits=0;renders=0;measure=True
 a.set_input(trig=100<=f<125 or (f>750 and f%160<12),stick=([7,14,11,13][(f//140)%4] if f>600 else 15))
 a.run_frames(1)
n=frames-400;total=sum(buckets.values())
print(json.dumps({'vbis':n,'game_frames':waits,'renders':renders,'speed_pct':round(100*waits/n,1),
 'game_cycles_per_frame':buckets['game']//max(1,waits),
 'render_cycles_per_render':sum(v for k,v in buckets.items() if k not in('game','WAIT_TICK','NMI','TICK','FRAME_WAIT'))//max(1,renders),
 'split_pct':{k:round(100*v/total,1) for k,v in buckets.most_common()}},indent=1))
