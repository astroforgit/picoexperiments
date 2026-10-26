import sys,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
r=load_labels(ROOT/'gen/runtime.asm.lab');a=Atari(ROOT/'pilka.xex');a.boot()
while a.cpu.pc!=0x975b:a.cpu.step()
a.next_frame=a.cpu.processorCycles+a.frame_cycles
step=a.cpu.step;start=None;ret=None;cost=[]
def profile():
 global start,ret
 if a.cpu.pc==r['RENDER']:
  start=a.cpu.processorCycles
  sp=a.cpu.sp;ret=(a.mem[0x100+((sp+1)&255)]|a.mem[0x100+((sp+2)&255)]<<8)+1
 elif start is not None and a.cpu.pc==ret:
  cost.append(a.cpu.processorCycles-start);start=None
 return step()
a.cpu.step=profile
for f in range(1200):
 a.set_input(trig=100<=f<125,stick=7 if f>600 else 15);a.run_frames(1)
print(json.dumps({'renders':len(cost),'cycles_mean':sum(cost)//len(cost),'cycles_min':min(cost),'cycles_max':max(cost),'last20_mean':sum(cost[-20:])//len(cost[-20:])}))

print('sprite colours',sorted(set(a.mem.ram[0xb6:0xcd])))
print('sprite frames',list(a.mem.ram[0xcd:0xe4]))
print('sprite y',list(a.mem.ram[0xe4:0xfb]))
a.screenshot(ROOT/'analysis/profile-final.png',scale=2)
