"""Pixel oracle for pitch, HUD, fine scrolling, clipping, teams, and VBI flips."""
import sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
r=load_labels(ROOT/'gen/runtime.asm.lab');a=Atari(ROOT/'pilka.xex');a.boot()
while a.cpu.pc!=0x975b:a.cpu.step()
a.nmien=0
source=(ROOT/'analysis/unpacked-64k.bin').read_bytes()
from PIL import Image
grass=np.array(Image.open(ROOT/'assets/swos/pitch.png'))[304:312,208:216]
sprites=np.frombuffer((ROOT/'gen/sprites.bin').read_bytes(),dtype=np.uint8)
banners=np.frombuffer((ROOT/'gen/banners.bin').read_bytes(),dtype=np.uint8).reshape(40,8,8)
chars=np.array([(i*13+i//40)%203 for i in range(1000)],dtype=np.uint8).reshape(25,40)
colors=np.full((25,40),9,dtype=np.uint8)
# Include genuine advertising signatures and mixed text/multicolour cells.
chars[2,5:9]=[217,234,228,217]
colors[0]=np.arange(40)%16

def expected_pitch():
 out=np.zeros((200,320),dtype=np.uint8)
 for y in range(25):
  banner=any(list(chars[y,x:x+4])==[217,234,228,217] for x in range(37))
  for x in range(40):
   char=int(chars[y,x]);color=int(colors[y,x]);tile=np.zeros((8,8),dtype=np.uint8)
   if banner:tile=banners[x]
   else:
    for v in range(8):
     bits=source[0xf000+char*8+v]
     for u in range(8):
      q=(bits>>(6-u//2*2))&3
      value=(16+color if bits&(128>>u) else 3) if color<8 else (3,1,2,16+(color&7))[q]
      if color==9 and char<203 and value==3:value=48+int(grass[v,u])
      tile[v,u]=value
   out[y*8:y*8+8,x*8:x*8+8]=tile
 return out

pitch=expected_pitch();cases=0
# Cover all four edges, both X high-bit values, both teams, non-player sprites,
# all fine-scroll values, movement over unchanged pitch, and tile changes.
positions=[(12,100),(13,100),(27,100),(28,100),(255,100),(256,100),(316,100),(331,100),(332,100),
           (120,41),(120,42),(120,56),(120,57),(120,225),(120,240),(120,241),(120,130)]
for k,(rawx,rawy) in enumerate(positions*2):
 sx=k%8;sy=(k*3)%8;color=7 if k%2 else 15;frame=32+k%32
 if k==len(positions)*2-1:frame=85
 a.mem.ram[0xc000:0xc3e8]=chars.tobytes();a.mem.ram[0xd800:0xdbe8]=colors.tobytes()
 a.mem.ram[0xde18]=0;a.mem.ram[0xde11]=0x18|sy;a.mem.ram[0xde16]=0xc0|sx
 a.mem.ram[0xde21]=0;a.mem.ram[0xde15]=0 # ball disabled in these cases
 a.mem.ram[0xe4:0xfb]=bytes([255]*23);a.mem.ram[0xcd:0xe4]=bytes(23)
 a.mem.ram[0x9f]=rawx&255;a.mem.ram[0xb6]=color|(128 if rawx>=256 else 0)
 a.mem.ram[0xcd]=frame;a.mem.ram[0xe4]=rawy
 previous_xdl=a.vregs[0x41]
 a.call(r['RENDER'])
 assert a.vregs[0x41]==previous_xdl,'Frame published outside VBI'
 actual_bg=a.vram[0x20000:0x2fa00].reshape(200,320)
 assert np.array_equal(actual_bg,pitch),f'Pitch pixels differ in case {k}: {np.count_nonzero(actual_bg!=pitch)}'
 expected=np.zeros((200,320),dtype=np.uint8)
 expected[8:192,8:312]=pitch[11-sy:195-sy,8-sx:312-sx]
 expected[:8]=pitch[:8]
 if frame<64:
  spr=sprites[((frame-32)+(32 if color==7 else 0))*256:((frame-32)+(32 if color==7 else 0))*256+256].reshape(16,16)
  dx=rawx-20;dy=rawy-49
  for y in range(16):
   for x in range(16):
    if 8<=dx+x<312 and 8<=dy+y<192 and spr[y,x]:expected[dy+y,dx+x]=spr[y,x]
 back=a.mem.ram[r['BACK']];actual=a.vram[back*65536:back*65536+64000].reshape(200,320)
 if not np.array_equal(actual,expected):
  diff=np.argwhere(actual!=expected);raise AssertionError(f'Composite case {k} at {(rawx,rawy)}: {len(diff)} pixels, first {diff[:5].tolist()}')
 # Simulate an actual NMI to publish, rather than editing front/pending directly.
 a.cpu.processorCycles=max(a.cpu.processorCycles,a.blit_busy_until) # queued blits done
 a.mem.ram[r['BUSY']]=1;a.cpu.pc=0x0200;a.cpu.p|=4;a.nmien=0x40;a.vblank()
 for _ in range(1000):
  if a.cpu.pc==0x0200:break
  a.cpu.step()
 else:raise AssertionError('NMI did not return')
 a.mem.ram[r['BUSY']]=0;a.nmien=0
 assert a.vregs[0x41]==back*32 and a.mem.ram[r['PENDING']]==0
 cases+=1
print(f'PASS: {cases} exact pixel comparisons, clean pitch caching, fine scroll, HUD, teams, edge clipping, VBI-only publication.')
