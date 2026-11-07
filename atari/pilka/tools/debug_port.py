import sys,collections,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari
from py65.disassembler import Disassembler
class Stop(Exception):pass
a=Atari(ROOT/'pilka.xex');a.boot();q=collections.deque(maxlen=30);orig=a.cpu.step;dis=Disassembler(a.cpu)
def step():
 pc=a.cpu.pc
 if pc<0xf000 and a.nmien:
  q.append((hex(pc),dis.instruction_at(pc)[1],a.cpu.sp))
  if a.mem[pc]==0:
   print('BRK',list(q),flush=True);raise Stop()
 return orig()
a.cpu.step=step
try:
 for f in range(600):
  a.set_input(trig=300<=f<330);a.run_frames(1)
  if f==299:
   (ROOT/'analysis/atari-ram.bin').write_bytes(a.mem.ram)
   (ROOT/'analysis/atari-vram.bin').write_bytes(a.vram.tobytes())
   print('VIC',a.mem.ram[0xde00:0xde40].hex(),'SCREEN',a.mem.ram[0xc000:0xc050].hex(),flush=True)
except Stop:pass
