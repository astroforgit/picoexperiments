"""Busy-scene profile: run right and fire from a stage checkpoint.

Reports the game ticks lost to slowdown (PAL wants 6 ticks every 5 frames,
NTSC one per frame), pictures shown and native cycles per routine group.
usage: profile_action.py checkpoint.pkl [frames]
"""
from pathlib import Path
import sys,pickle,collections,json,bisect
from build import labels
R=Path(__file__).resolve().parents[1];L=labels(R/'gen/runtime.lab')
a=pickle.load(open(sys.argv[1],'rb'));assert a.xex==(R/'contra.xex').read_bytes()
n=int(sys.argv[2]) if len(sys.argv)>2 else 600
names=[('interrupt','NMI'),('idle','RENDER_IDLE'),('flip/palette','FLIP'),('compose','COMPOSE'),('catchup','CATCH_UP'),('tiles','EMIT_TILES'),('tile','EMIT_TILE'),('bgready','BG_READY'),('objexpand','OBJ_EXPAND'),('background','EMIT_BG'),('sprites','EMIT_SPRITES'),('expand','EXPAND'),('input','READ_INPUT'),('irq','IRQ'),('keyboard','KB_READ'),('pattern','PATTERN_SELECT'),('schedule','FRAME_SCHEDULE'),('chrdirty','MARK_CHR_DIRTY'),('startup','START')]
ranges=sorted([(L[v],k) for k,v in names if v in L]+[(0xc000,'ppu'),(0xd800,'sound')]);addresses=[v for v,k in ranges]
cycles=collections.Counter();step=a.cpu.step
def prof():
 pc=a.cpu.pc;c=a.cpu.processorCycles;step();cycles[pc]+=a.cpu.processorCycles-c
a.cpu.step=prof
ticks=0;flips=len(a.xdl_addr_log);c0=a.cpu.processorCycles
for f in range(n):
 a.set_input(stick=7,trig=(f//3)&1,shift=f%40<4)
 t=a.mem.ram[0x1a];a.run_frames(1);ticks+=(a.mem.ram[0x1a]-t)&255
a.cpu.step=step
s=collections.Counter()
for pc,c in cycles.items():
 if 0x4000<=pc<0xc000:g='NES game'
 elif 0x1000<=pc<0x2800 or 0xc000<=pc<0xd000 or 0xd800<=pc<0xf000:g=ranges[bisect.bisect_right(addresses,pc)-1][1]
 else:g='other'
 s[g]+=c
want=n*6//5 if a.mem.ram[L['TICK_MODE']] else n
total=sum(s.values())
print(json.dumps({'frames':n,'ticks':ticks,'ticks_wanted':want,'lost_pct':round(100*(want-ticks)/want,1),
 'pictures':(len(a.xdl_addr_log)-flips)//3,'cycles_per_frame':total//n,
 'share_pct':{k:round(100*v/total,1) for k,v in s.most_common()}},indent=1))
