#!/usr/bin/env python3
"""Pixel oracle. Plays the port in the headless model and compares every
picture it shows with an independent C64 rendering (VIC-II rules: 38-column,
24-row window, fine scroll, multicolour text, sprite order, sprites behind
foreground) of the game state the renderer sampled. Generated advertising
cells are excluded. Also reports game-loop and picture rates.

  python3 tools/test_renderer.py [frames]   (SCRIPT=a|up|down|rnd, PAGE=d6|d7,
                                             OUT=dir EVERY=n to save pictures)"""
import sys,os
from pathlib import Path
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools/reference'));sys.path.insert(0,str(ROOT/'tools'))
from atari_emu import Atari,load_labels
from vic import PEPTO
from build_assets import FGI
OUT=Path(os.environ.get('OUT',ROOT/'analysis/pictures'))
FR=int(sys.argv[1]) if len(sys.argv)>1 else 1500
r=load_labels(ROOT/'gen/runtime.asm.lab');rr=load_labels(ROOT/'gen/render.asm.lab')
a=Atari(ROOT/'pilka.xex',vbxe_page=int(os.environ.get('PAGE','d6'),16));a.boot()
while a.cpu.pc!=0x975b:a.cpu.step()
a.next_frame=a.cpu.processorCycles+a.frame_cycles
src=(ROOT/'analysis/unpacked-64k.bin').read_bytes()
m=a.mem.ram
def snap():
 ram=bytearray(m);ram[0xc000:0xd000]=a.vram[0x7c000:0x7d000].tobytes()
 return dict(ram=bytes(ram),frame=a.frame)
def ref(s):
 ram=s['ram'];menu=ram[r['MENU_MODE']]
 scr=0xc000+((ram[0x11d9]>>4)&3)*0x400
 sx=ram[0x11d7]&7;sy=ram[0x11d8]&7
 bg=[ram[0xde21+i]&15 for i in range(3)]
 pix=np.zeros((200,320),np.int16);fg=np.zeros((200,320),bool);ban=np.zeros((200,320),bool)
 for row in range(25):
  for col in range(40):
   ch=ram[scr+row*40+col];cc=ram[0xd800+row*40+col]&15
   if not menu and cc==9 and ch>=0xd9:ban[row*8:row*8+8,col*8:col*8+8]=True
   for py in range(8):
    b=src[0xf000+ch*8+py]
    for i in range(8):
     if cc&8:
      v=b>>(6-(i//2)*2)&3;c=(bg[0],bg[1],bg[2],cc&7)[v];f=v>=2
     else:
      on=b>>(7-i)&1;c=cc if on else bg[0];f=bool(on)
     pix[row*8+py,col*8+i]=c;fg[row*8+py,col*8+i]=f
 out=np.full((200,320),bg[0],np.int16);ofg=np.zeros((200,320),bool);oban=np.zeros((200,320),bool)
 dy=sy-3
 for y in range(200):
  yy=y-dy
  if 0<=yy<200:
   out[y,sx:]=pix[yy,:320-sx];ofg[y,sx:]=fg[yy,:320-sx];oban[y,sx:]=ban[yy,:320-sx]
 beh=[];frn=[]
 for i in range(23):
  if ram[0xe4+i]==0xff:break
  z=2 if (menu and i<8 and ram[0xde1d]>>i&1) else 1
  e=(ram[0x9f+i]|((ram[0xb6+i]&0x80)<<1),ram[0xe4+i],ram[0xcd+i],ram[0xb6+i]&15,z)
  (beh if ram[0xb6+i]&0x40 and len(beh)<4 else frn).append(e)
 if ram[0xde15]&0x80:
  e=(ram[0x24d8]|((ram[0xde10]&0x80)<<1),ram[0x24e0],ram[r['BALLFRAME']],ram[0xde2e]&15,1)
  (beh if ram[0x24e2]&0x80 and len(beh)<4 else frn).append(e)
 mc0,mc1=ram[0xde25]&15,ram[0xde26]&15
 frames=set()
 for lst,behind in ((beh,True),(frn,False)):
  for x,y,f,c,z in lst:
   frames.add(f)
   if not 32<=f<128:continue
   if z==2 and not(0<=x-24<=255 and 4<=y-50<155):z=1
   for ly in range(21*z):
    Y=y-50+ly
    if not 4<=Y<196:continue
    for i in range(12):
     v=src[0xc000+f*64+(ly//z)*3+i//4]>>(6-(i%4)*2)&3
     if not v:continue
     colr=(None,mc0,c,mc1)[v]
     for k in range(2*z):
      X=x-24+2*i*z+k
      if 7<=X<311 and not(behind and ofg[Y,X]):out[Y,X]=colr
 out[:4]=-1;out[196:]=-1;out[:,:7]=-1;out[:,311:]=-1
 oban[:4]=False;oban[196:]=False;oban[:,:7]=False;oban[:,311:]=False
 return out,oban,frames
pal=np.array(PEPTO+[(0,0,0)],np.uint8)
def shown():
 v=a.vregs;xdl=v[0x41]|(v[0x42]<<8)|((v[0x43]&7)<<16)
 fb=0x10000 if xdl&0x20 else 0
 idx=a.vram[fb:fb+64000].reshape(200,320)
 return idx,a.palette[1][idx]
def to_c64(idx,ram):
 lut=np.full(256,99,np.int16);lut[0]=-1
 lut[1]=ram[0xde22]&15;lut[2]=lut[3]=lut[4]=ram[0xde21]&15;lut[8]=ram[0xde23]&15
 for i in range(16):lut[FGI[i]]=i;lut[0x60+i]=i
 lut[0x20]=ram[0xde26]&15;lut[0x40]=ram[0xde25]&15
 return lut[idx]
pend=None;cur=None;last_xdl=a.vregs[0x41];pics=0;bad=0;worst=[];loops=0;renders=0;flushes=0;allframes=set();rstart=0;rcyc=[];cells=0
every=int(os.environ.get('EVERY','0'));SAVEBAD=int(os.environ.get('SAVEBAD','12'));SAVEPICS=set(int(x) for x in os.environ.get('SAVEPICS','').split(',') if x)
palerr=0
def published():
 global pics,bad,palerr
 pics+=1
 s=cur
 if s is None:return
 idx,rgb=shown();idx=idx.copy();rgb=rgb.copy()
 ram=s['ram']
 e,oban,fr=ref(s);allframes.update(fr)
 got=to_c64(idx,ram)
 d=(got!=e)&~oban;n=int(d.sum())
 # palette must show C64 colours (grass for the pitch background)
 ok=(e<0)|oban|(got!=e)|(idx>=2)&(idx<=4)&(ram[0xde21]&15==5)|np.all(rgb==pal[np.clip(e,0,16)],axis=2)
 if not ok.all():palerr+=1
 if n:
  bad+=1;worst.append((n,pics,a.frame))
 if (n and bad<=SAVEBAD) or pics in SAVEPICS or (every and pics%every==0):
  ergb=pal[e];drgb=np.zeros((200,320,3),np.uint8);drgb[d]=(255,0,0)
  im=Image.new('RGB',(960,200));im.paste(Image.fromarray(rgb),(0,0));im.paste(Image.fromarray(ergb),(320,0));im.paste(Image.fromarray(drgb),(640,0))
  OUT.mkdir(exist_ok=True);im=im.resize((1920,400),Image.NEAREST);im.save(OUT/f'p{pics:05d}_f{a.frame}_{n}.png')
step=a.cpu.step
RENDER=rr['RENDER'];FLUSH=rr['FLUSH'];EMIT=rr['EMIT_CELL'];NOPUB=r['NO_PUBLISH'];REST=rr['REST_ZP']
def hook():
 global pend,cur,last_xdl,loops,renders,flushes,rstart,cells
 pc=a.cpu.pc
 if pc==0x972c:loops+=1
 elif pc==NOPUB:
  if a.vregs[0x41]!=last_xdl:
   last_xdl=a.vregs[0x41];cur=pend;published()
 elif 0xc000<=pc<0xd000 and a.mems==0xfd:
  if pc==RENDER:pend=snap();renders+=1;rstart=a.cpu.processorCycles
  elif pc==FLUSH:flushes+=1
  elif pc==EMIT:cells+=1
  elif pc==REST:rcyc.append(a.cpu.processorCycles-rstart)
 return step()
a.cpu.step=hook
SCRIPT=os.environ.get('SCRIPT','a')
def inputs(f):
 if f<600:return dict(trig=100<=f<125)
 if SCRIPT=='a':return dict(trig=(f%160<12),stick=[7,14,11,13,6,10,9,5][(f//140)%8])
 if SCRIPT=='up':return dict(trig=(f%200<8),stick=14 if (f//300)%3<2 else 10)
 if SCRIPT=='down':return dict(trig=(f%200<8),stick=13 if (f//300)%3<2 else 5)
 return dict(trig=(f*7919%97<6),stick=[7,14,11,13,6,10,9,5,15][(f*31//90)%9])
MEAS=int(os.environ.get('MEAS','700'));l0=p0=r0=0
for f in range(FR):
 if f==MEAS:l0,p0,r0=loops,pics,len(rcyc)
 a.set_input(**inputs(f));a.run_frames(1)
worst.sort(reverse=True)
n=max(1,FR-MEAS);rc=rcyc[r0:] or [0]
print(f'pictures {pics} frames {FR} bad {bad} palette-errors {palerr} flushes {flushes} cells {cells}')
print(f'after frame {MEAS}: game loops/frame {(loops-l0)/n:.3f}, pictures/frame {(pics-p0)/n:.3f}, render cycles avg {sum(rc)//len(rc)} max {max(rc)}')
print('sprite frames',min(allframes or [0]),max(allframes or [0]),'worst',worst[:10])
assert pics>FR//3,'too few pictures'
assert bad==0 and palerr==0,'pictures differ from the C64 reference'
assert allframes and min(allframes-{0})>=32 and max(allframes)<128,'sprite frame without an image'
assert (loops-l0)/n>0.97,'game loop slower than one iteration per frame'
print('PASS: every picture matches the C64 reference; game loop at frame rate.')
