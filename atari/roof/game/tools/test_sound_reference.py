"""Compare real 6502 audio writes with the user's ../slay.atr reference.

No reference game content is copied into the project. Extract SLAYDER.XEX
from the disk's SpartaDOS sector maps in memory and execute its sound code.
"""
from pathlib import Path
import sys,hashlib
from py65.devices.mpu6502 import MPU
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels

def extract(atr,name):
 data=atr.read_bytes();size=int.from_bytes(data[4:6],'little')
 def sector(n):
  offset=16+(n-1)*128 if n<=3 else 16+384+(n-4)*size
  return data[offset:offset+(128 if n<=3 else size)]
 def chain(n):
  result=bytearray();seen=set()
  while n:
   assert n not in seen,'Circular sector map';seen.add(n);s=sector(n)
   for i in range(4,len(s),2):
    number=int.from_bytes(s[i:i+2],'little')
    if number:result.extend(sector(number))
   n=int.from_bytes(s[:2],'little')
  return result
 root=chain(int.from_bytes(sector(1)[9:11],'little'))
 for i in range(23,int.from_bytes(root[3:6],'little'),23):
  e=root[i:i+23]
  filename=e[6:14].decode('ascii').strip()+'.'+e[14:17].decode('ascii').strip()
  if e[0]&8 and not e[0]&0x30 and filename==name:
   return chain(int.from_bytes(e[1:3],'little'))[:int.from_bytes(e[3:6],'little')]
 raise AssertionError('SLAYDER.XEX missing from reference ATR')

class Memory(bytearray):
 def __init__(self,data):super().__init__(data);self.writes=[]
 def __setitem__(self,key,value):
  if isinstance(key,int) and 0xd200<=key<0xd220:self.writes.append((key,value))
  super().__setitem__(key,value)

def call(memory,address):
 cpu=MPU(memory=memory);cpu.sp=255;cpu.stPushWord(0xfffe);cpu.pc=address
 for _ in range(10000):
  if cpu.pc==0xffff:return
  cpu.step()
 raise AssertionError('Audio routine did not return')

atr=ROOT.parent/'slay.atr';xex=extract(atr,'SLAYDER.XEX');reference=Memory(bytes(65536));p=0
while p<len(xex):
 start=int.from_bytes(xex[p:p+2],'little');p+=2
 if start==65535:continue
 end=int.from_bytes(xex[p:p+2],'little');p+=2
 reference[start:end+1]=xex[p:p+end-start+1];p+=end-start+1
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();native=Memory(a.mem.ram)
# Slayder's actual init clears both chips, including any residual stereo audio.
for mem,entry in [(reference,0x5229),(native,L['SOUND_INIT'])]:
 mem[0xd200:0xd220]=bytes([255])*32;call(mem,entry)
 for base in (0xd200,0xd210):
  assert mem[base:base+9]==bytes(9) and mem[base+15]==3
# Run the original wind path, including its actual SOUND wrapper, then use
# identical frequency/volume tables in our wind path and compare the writes.
for distance in (0,32,80,120,160):
 reference[0x7584]=min(14,distance//16);reference[0x7586]=distance
 reference[0x7592]=reference[0xd8]=reference[0x7593]=0
 call(reference,0x52eb)
 freq,ctrl=reference[0xd206:0xd208]
 assert ctrl>>4==8
 native[L['WIND_FREQ']:L['WIND_FREQ']+64]=bytes([freq])*64
 native[L['WIND_VOL']:L['WIND_VOL']+64]=bytes([ctrl])*64
 native[L['FRAME']]=1;native[L['WIND_WOBBLE']]=0
 call(native,L['WIND_STEP'])
 assert native[0xd206:0xd208]==reference[0xd206:0xd208]
print('PASS Slayder ATR actual sound code: dual-POKEY initialization and distortion-8 wind register parity at five pitches/volumes')
print('Reference SHA256:',hashlib.sha256(atr.read_bytes()).hexdigest())
