#!/usr/bin/env python3
"""Play-through consistency check: after every picture, each char-layer cell
must hold the tile its cache entry names, and after a full scan the raw
cache must equal the C64 screen. Catches bad picture moves on scroll flips."""
import sys
import numpy as np
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
r=load_labels(ROOT/'gen/runtime.asm.lab');a=Atari(ROOT/'pilka.xex');a.boot()
while a.cpu.pc!=0x975b:a.cpu.step()
a.next_frame=a.cpu.processorCycles+a.frame_cycles
start_screen={};blocks=[0];v=a.vram;bad_layer=bad_raw=checks=flips=0
def tile(ch,col,c):
 if col==16:base=0x78000+c*64
 else:base=int(v[0x6c000+col*256+ch])|int(v[0x6d000+col*256+ch])<<8|int(v[0x6e000+col*256+ch])<<16
 return v[base:base+64].reshape(8,8)
def check():
 global bad_layer,bad_raw,checks
 checks+=1
 cells=[]
 layer=v[0x20000:0x20000+64000].reshape(200,320)
 chars=v[0x74000:0x74000+1000];cols=v[0x74400:0x74400+1000]
 for i in range(1000):
  rr,c=divmod(i,40)
  if cols[i]>16:continue   # never drawn yet
  if not np.array_equal(layer[rr*8:rr*8+8,c*8:c*8+8],tile(int(chars[i]),int(cols[i]),c)):bad_layer+=1;cells.append((rr,c))
 if cells and '-v' in sys.argv and not hasattr(check,'shown'):
  check.shown=1;print('first bad picture',checks,'after moves',flips,'rows',sorted(set(x for x,_ in cells)),'n',len(cells),'cols',sorted(set(y for _,y in cells))[:12])
 if blocks[0]==4:
  m=a.mem.ram;base=m[r['SCRHI']]<<8
  now=np.frombuffer(bytes(m[base:base+1000]),np.uint8)
  # Cells the game changed while the picture was being built are caught by
  # later scans; only cells unchanged since the render started must match.
  stale=(now!=v[0x74800:0x74800+1000])&(now==start_screen.get(base,now))
  n=int(stale.sum());bad_raw+=n
  if n and '-v' in sys.argv:print('stale raw',n,'rows',sorted(set(int(i)//40 for i in np.nonzero(stale)[0])),'picture',checks,'full via NMI',m[r['RENDER_FULL']],'moves',flips)
step=a.cpu.step
def p():
 global flips
 if a.cpu.pc==r['SHIFT_FOUND']:flips+=1
 if a.cpu.pc==r['SCAN_BLOCK']:blocks[0]+=1
 if a.cpu.pc==r['RENDER']:
  blocks[0]=0
  m=a.mem.ram;start_screen.clear()
  for b in(0xc000,0xc400):start_screen[b]=np.frombuffer(bytes(m[b:b+1000]),np.uint8).copy()
 if a.cpu.pc==r['START_LIST']:check()
 return step()
a.cpu.step=p
args=[x for x in sys.argv[1:] if x[0]!='-']
for f in range(int(args[0]) if args else 1500):
 a.set_input(trig=100<=f<125 or (f>750 and f%160<12),stick=([7,14,11,13][(f//140)%4] if f>600 else 15));a.run_frames(1)
print(f'{checks} pictures, {flips} picture moves, {bad_layer} cells not matching their cache, {bad_raw} raw-cache cells stale after full scans')
assert bad_layer==0 and bad_raw==0
