#!/usr/bin/env python3
"""CPU cycles per frame by renderer routine, game and idle time (headless model)."""
import sys,collections
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
r=load_labels(ROOT/'gen/runtime.asm.lab');rr=load_labels(ROOT/'gen/render.asm.lab')
a=Atari(ROOT/'pilka.xex');a.boot()
while a.cpu.pc!=0x975b:a.cpu.step()
a.next_frame=a.cpu.processorCycles+a.frame_cycles
names=['RENDER','COMPARE','PAL_KEYS','SPRITES','CELLS','ROWS','COLOUR_ROW','COLOURS_DONE','OVERLAYS','START','SETUP_ROW','EMIT_CELL','FLUSH','SETUP_PIECES','EMIT_PIECES','DRAW_SPRITE','PUTRGB','NOOP']
reg=sorted((rr[n],n) for n in names)
import bisect
keys=[k for k,_ in reg]
b=collections.Counter();step=a.cpu.step;meas=False;renders=0;nmi=0
def h():
    global renders
    pc=a.cpu.pc;c=a.cpu.processorCycles;res=step()
    if meas:
        d=a.cpu.processorCycles-c
        if 0xc000<=pc<0xd000 and a.mems==0xfd:
            if pc==rr['RENDER']:renders+=1
            b[reg[bisect.bisect_right(keys,pc)-1][1]]+=d
        elif a.mems==0xfd:b['bridge(wait/memb)']+=d
        elif pc>=0xf000 and pc<0xf100:b['nmi']+=d
        elif pc>=0xcc00 and pc<0xcd00:b['hooks/wait']+=d
        else:b['game']+=d
    return res
a.cpu.step=h
for f in range(1100):
    if f==700:meas=True
    a.set_input(trig=(100<=f<125) or (f>=600 and f%160<12),stick=15 if f<600 else [7,14,11,13,6,10,9,5][(f//140)%8]);a.run_frames(1)
print('renders',renders,'blit cycles/frame',a.blit_cycles//1100)
for k,v in b.most_common():print(f'{k:20} {v/400:8.0f}/frame {v/max(1,renders):8.0f}/render')
