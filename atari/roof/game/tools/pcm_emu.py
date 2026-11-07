"""The shared headless Atari plus POKEY timer 1 IRQs, for sample playback tests.

Timer 1 counts the 64 kHz clock (1.77 MHz / 28) from STIMER and raises an IRQ
every AUDF1+1 ticks while IRQEN bit 0 is set. Volume-only writes to AUDC2/3
are recorded with their CPU cycle, so tests can read back the played samples.
VCOUNT ($D40B) follows the PAL beam: the frame's VBI fires at line 248.
"""
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[3]/'lair/tools'))
from emu import Atari, FRAME_CYCLES

class PcmAtari(Atari):
 def __init__(self,*args,**kwargs):
  self.irqen=0;self.next_irq=None;self.pending=False;self.irqs=0;self.pcm={0xD203:[],0xD205:[],0xD207:[]}
  super().__init__(*args,**kwargs)
 def period(self):return (self.pokey[0]+1)*28
 def io_write(self,addr,value):
  cycles=self.cpu.processorCycles if hasattr(self,'cpu') else 0
  if addr==0xD20E:
   self.irqen=value
   if not value&1:self.pending=False
  elif addr==0xD209:self.next_irq=cycles+self.period()
  elif addr in self.pcm and value&0x10:self.pcm[addr].append((cycles,value&15))
  super().io_write(addr,value)
 def io_read(self,addr):
  if addr==0xD40B:
   line=(self.cpu.processorCycles-(self.next_frame-FRAME_CYCLES))*312//FRAME_CYCLES
   return ((248+line)%312)//2
  return super().io_read(addr)
 def step(self):
  cpu=self.cpu
  if self.next_irq is not None and cpu.processorCycles>=self.next_irq:
   self.next_irq+=self.period()
   if self.irqen&1:self.pending=True
  if self.pending and not cpu.p&0x04 and not getattr(self,'in_vbi',False):
   self.pending=False;self.irqs+=1
   cpu.stPushWord(cpu.pc);cpu.stPush(cpu.p&~0x10);cpu.p|=0x04
   cpu.pc=self.mem.ram[0xFFFE]|self.mem.ram[0xFFFF]<<8
  super().step()
