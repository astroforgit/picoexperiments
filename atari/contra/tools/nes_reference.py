"""Small original-ROM oracle for Contra's upload and gameplay routines.
Not an Atari emulator; used to distinguish game data from port rendering bugs.
"""
from pathlib import Path
from py65.devices.mpu6502 import MPU
R=Path(__file__).resolve().parents[1]
class Memory:
 def __init__(self):
  self.prg=(R/'Contra/Contra (USA).nes').read_bytes()[16:];self.bank=0;self.ram=bytearray(2048);self.chr=bytearray(8192);self.nt=bytearray(2048);self.pal=bytearray(32);self.apu=bytearray(24);self.addr=0;self.latch=0;self.ctrl=0;self.mask=0;self.scroll=[0,0];self.buttons=[0,0];self.shift=[0,0]
 def __getitem__(self,a):
  if a<0x2000:return self.ram[a&2047]
  if a<0x4000:
   r=a&7
   if r==2:self.latch=0;return 0x80
   if r==7:raise AssertionError('unexpected PPU read')
   return 0
  if a in (0x4016,0x4017):
   i=a-0x4016;v=(self.shift[i]>>7)&1;self.shift[i]=(self.shift[i]<<1)&255;return v
  if a>=0x8000:return self.prg[(7 if a>=0xc000 else self.bank)*16384+(a&16383)]
  return 0
 def __setitem__(self,a,v):
  if a<0x2000:self.ram[a&2047]=v
  elif a<0x4000:
   r=a&7
   if r==0:self.ctrl=v
   elif r==1:self.mask=v
   elif r==5:self.scroll[self.latch]=v;self.latch^=1
   elif r==6:
    if not self.latch:self.addr=(v&63)<<8
    else:self.addr=(self.addr&0x3f00)|v
    self.latch^=1
   elif r==7:
    p=self.addr&16383
    if p<8192:self.chr[p]=v
    elif p<0x3f00:self.nt[p&2047]=v
    else:
     i=p&31
     if i&3==0:i&=15
     self.pal[i]=v&63
    self.addr=(self.addr+(32 if self.ctrl&4 else 1))&16383
  elif a==0x4016:self.shift=self.buttons[:]
  elif a<0x4018:self.apu[a-0x4000]=v
  elif a>=0x8000:self.bank=v&7
class NES:
 def __init__(self):
  self.mem=Memory();self.cpu=MPU(memory=self.mem);self.cpu.pc=self.mem[0xfffc]|self.mem[0xfffd]<<8
  # Original forever_loop is the final JMP before the NMI entry vector.
  nmi=self.mem[0xfffa]|self.mem[0xfffb]<<8;self.idle=self.mem[nmi-2]|self.mem[nmi-1]<<8
  self.finish()
 def finish(self):
  for _ in range(2000000):
   if self.cpu.pc==self.idle:return
   self.cpu.step()
  raise AssertionError(hex(self.cpu.pc))
 def frame(self):self.cpu.nmi();self.finish()
if __name__=='__main__':
 n=NES();n.frame();n.mem.ram[0x18]=4
 for f in range(200):
  if n.mem.ram[0x2c]==2:n.mem.ram[0x2a]=0;n.mem.ram[0x2b]=0
  n.frame()
  if n.mem.ram[0x2c]==4:break
 (R/'gen/reference-chr.bin').write_bytes(n.mem.chr);(R/'gen/reference-nt.bin').write_bytes(n.mem.nt)
 print('Reference stage 1 ready:',f,'ticks; blank tile',list(n.mem.chr[4096:4112]),'OAM',list(n.mem.ram[512:528]))
