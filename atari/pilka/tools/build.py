#!/usr/bin/env python3
import sys,struct,json,re,subprocess,hashlib
from pathlib import Path
from py65.devices.mpu6502 import MPU
from py65.disassembler import Disassembler
from build_assets import build as assets
from preview_swos import PALETTE
from make_banners import build as banners
ROOT=Path(__file__).resolve().parents[1]
GEN=ROOT/'gen';SRC=ROOT/'src'
sys.path.insert(0,str(ROOT/'tools/reference'))
from vic import PEPTO
from nmos import extend

def assemble(name):
 for _ in range(20):
  p=subprocess.run(['mads',str(SRC/name),'-o:'+str(GEN/(name+'.obx')),'-t:'+str(GEN/(name+'.lab'))],capture_output=True,text=True)
  hits=re.findall(r'([^\n ]+\.asm) \((\d+)\) ERROR: Branch out of range',p.stdout)
  if hits:
   for filename,num in hits:
    file=SRC/Path(filename).name;lines=file.read_text().splitlines();i=int(num)-1
    lines[i]=re.sub(r'\b(bne|beq|bcc|bcs|bmi|bpl|bvc|bvs)\b',lambda m:'j'+m[0][1:],lines[i]);file.write_text('\n'.join(lines)+'\n')
   continue
  if p.returncode:raise RuntimeError(p.stdout+p.stderr)
  labels={}
  for line in (GEN/(name+'.lab')).read_text().splitlines():
   t=line.split()
   if len(t)==3:
    try:labels[t[2]]=int(t[1],16)
    except ValueError:pass
  return labels
 raise RuntimeError('Branches failed to settle')

def segments(data):
 p=0
 while p<len(data):
  start=int.from_bytes(data[p:p+2],'little');p+=2
  if start==65535:continue
  end=int.from_bytes(data[p:p+2],'little');p+=2
  yield start,data[p:p+end-start+1];p+=end-start+1

def segment(a,b):return struct.pack('<HH',a,a+len(b)-1)+bytes(b)

def main():
 assets()
 banners()
 for name,data in [("tile-lo",[(i*64)&255 for i in range(256)]),("tile-hi",[i//4 for i in range(256)]),("color-lo",[(i*64)&255 for i in range(16)]),("color-hi",[2+i//4 for i in range(16)]),("y-lo",[(i*320)&255 for i in range(256)]),("y-hi",[((i*320)>>8)&255 for i in range(256)]),("cache-lo",[(i*40)&255 for i in range(25)]),("cache-hi",[0xa0+((i*40)>>8) for i in range(25)])]: (GEN/(name+".bin")).write_bytes(bytes(data))
 rgb=[(0,0,0)]*16+PEPTO+[tuple(PALETTE[i:i+3]) for i in range(0,48,3)]*2
 (GEN/'palette.bin').write_bytes(bytes(v for c in rgb for v in c))
 for n,i in [('r',0),('g',1),('b',2)]: (GEN/f'c64-{n}.bin').write_bytes(bytes(c[i] for c in PEPTO))
 # Label each bridge hardware operand to relocate precisely for a D700 VBXE.
 source=(SRC/'runtime.asm').read_text();source=re.sub(r'^vbrel_\d+\n','',source,flags=re.M)
 count=0;lines=[]
 for line in source.splitlines():
  if re.search(r'\b(?:sta|lda|ldx|ldy|stx|sty)\s+\$d6[45][0-9a-f]\b',line,re.I):
   lines.append(f'vbrel_{count}');count+=1
  lines.append(line)
 (SRC/'runtime.asm').write_text('\n'.join(lines)+'\n')
 (GEN/'relocs.asm').write_text(f'RELOC_COUNT = {count}\nreloc_lo dta '+','.join(f'<(vbrel_{i}+2)' for i in range(count))+'\nreloc_hi dta '+','.join(f'>(vbrel_{i}+2)' for i in range(count))+'\n')
 labels=assemble('runtime.asm')
 ram=bytearray((ROOT/'analysis/unpacked-64k.bin').read_bytes());ram[0]=0x2f
 cov=json.loads((ROOT/'analysis/coverage.json').read_text())
 # Recursive traversal from all observed instructions includes untaken branches.
 cpu=extend(MPU(memory=list(ram)));dis=Disassembler(cpu);ops={};pending=[int(k) for k in cov['ops']]
 while pending:
  pc=pending.pop()
  while pc not in ops and (0x800<=pc<0xf000 or 0xf800<=pc<0xfffa):
   n,txt=dis.instruction_at(pc);op=ram[pc];mn,mode=cpu.disassemble[op]
   if mn=='???' or op==0:break
   ops[pc]=(n,txt)
   if mode=='rel':pending.append((pc+2+(ram[pc+1] if ram[pc+1]<128 else ram[pc+1]-256))&65535)
   if op in (0x20,0x4c):pending.append(ram[pc+1]+256*ram[pc+2])
   if op in (0x4c,0x6c,0x60,0x40):break
   pc+=n
 patches=[]
 for pc,(n,txt) in sorted(ops.items()):
  if n!=3:continue
  op=ram[pc];addr=ram[pc+1]+256*ram[pc+2];new=addr;mn,mode=cpu.disassemble[op]
  if mode not in ('abs','abx','aby'):continue
  if 0xd000<=addr<=0xd03f:
   new=addr+0xe00
   if addr==0xd012 and mn in ('LDA','LDX','LDY','CMP','CPX','CPY'):new=0xd40b
  elif 0xd400<=addr<=0xd41f:
   new=addr+0xb00
   if mn in ('LDA','LDX','LDY'):new=0xd20a
  elif addr in (0xdc00,0xdc01) and mn in ('LDA','LDX','LDY','AND','ORA','CMP'):new=0xdd90+addr-0xdc00
  elif addr in (0xdc04,0xdc05,0xdd04,0xdd05) and mn in ('LDA','LDX','LDY','EOR'):new=0xd20a
  elif addr in (0xfffa,0xfffb):new=0xdd82+addr-0xfffa
  elif addr in (0xfffe,0xffff):new=0xdd80+addr-0xfffe
  if new!=addr:
   ram[pc+1:pc+3]=struct.pack('<H',new);patches.append({'pc':pc,'original':txt,'target':new})
 # Replace raster-dependent frame synchronisation, and SID oscillator wait.
 for pc,target in [(0x97b7,labels['FRAME_WAIT'])]:ram[pc:pc+3]=b'\x4c'+struct.pack('<H',target)
 ram[0x9289:0x928c]=b'\xea\xea\xea' # Omit C64 sound update while audio is disabled.
 ram[0x9a44]=0x60 # SID envelope synchronisation has no Atari counterpart.
 # The C64 menu copies 768 bytes hidden beneath I/O into BD00. Atari has
 # no equivalent RAM behind its hardware; relocate that source to VIC-only RAM.
 ram[0xc900:0xcc00]=bytes(cpu.memory[0xd780:0xda80])
 ram[0x93ec]=0x00
 ram[0x93f0]=0xc9
 # Self-modifying renderer code is separate from C64's preserved code/data.
 # Game code at $F800-$FFF9 is restored from VRAM $5F000 by rt_boot after
 # the boot-only part of the runtime (loaded there) has run.
 game_top=bytes(ram[0xf800:0x10000])
 for addr,data in segments((GEN/'runtime.asm.obx').read_bytes()):ram[addr:addr+len(data)]=data
 (GEN/'ram.bin').write_bytes(ram)
 (GEN/'patches.json').write_text(json.dumps(patches,indent=2)+'\n')
 # A traced disassembly, with data left as bytes. Does not claim high-level C recovery.
 listing=['; Arlasoft Soccer: reachable disassembly from the supplied C64 PRG.','; Original addresses; uncertain/unreached regions remain binary data.']
 for pc,(n,txt) in sorted(ops.items()):listing.append(f'{pc:04X}  {bytes(cpu.memory[pc:pc+n]).hex(" "):8}  {txt}')
 (ROOT/'analysis/arlasoc-disassembly.txt').write_text('\n'.join(listing)+'\n')
 (GEN/'boot-defs.asm').write_text(f"RT_BOOT = ${labels['RT_BOOT']:04x}\n")
 boot=assemble('boot.asm');out=bytearray(b'\xff\xff')+(GEN/'boot.asm.obx').read_bytes()
 out+=segment(0x2e2,struct.pack('<H',boot['DETECT']))
 # Compose/sprite BCB list template at $6F200; the runtime fills only the
 # per-frame fields (see compose_background and add_sprite).
 def bcb(src,ssy,dst,w,h,ctrl):
  return bytes([src&255,src>>8&255,src>>16,ssy&255,ssy>>8,1,dst&255,dst>>8&255,dst>>16,320&255,320>>8,1,(w-1)&255,(w-1)>>8,h-1,255,0,0,0,0,ctrl])
 sprites=bytearray((GEN/'sprites.bin').read_bytes())
 template=bcb(0x20000,320,8+8*320,304,184,8)+bcb(0x20000,320,0,320,8,8)+b''.join(bcb(0x60000,16,0,16,16,9) for _ in range(25))
 assert not any(sprites[0xf200:0xf200+len(template)]) and 0xf200+len(template)<=0xf500
 sprites[0xf200:0xf200+len(template)]=template
 # Picture moves for each C64 scroll direction (runtime shift_picture):
 # rows 1-24 of the four 40x25 cell caches ($74000-$74FFF), then of the
 # char layer ($20000, 320 bytes per line). In-place copies run forwards
 # when the source lies after the destination, otherwise backwards.
 def move(base,stride,cell,dx,dy,last):
  c0,r0=max(0,-dx),1+max(0,-dy);w,h=(40-abs(dx))*cell,(24-abs(dy))*cell
  d=base+r0*cell*stride+c0*cell;src=d+(dy*stride+dx)*cell
  step=1
  if dy*stride+dx<0:d+=(h-1)*stride+w-1;src+=(h-1)*stride+w-1;step=-1
  sy=(step*stride)&0x1fff;sx=step&255
  return bytes([src&255,src>>8&255,src>>16,sy&255,sy>>8,sx,d&255,d>>8&255,d>>16,sy&255,sy>>8,sx,(w-1)&255,(w-1)>>8,h-1,255,0,0,0,0,0 if last else 8])
 for k,code in enumerate([8,9,49,89,88,87,47,7]):
  off=code-48;dy=(off+60)//40-1 if off else 0;dx=off-40*dy
  assert abs(dx)<=1 and abs(dy)<=1 and (dx or dy)
  lst=b''.join(move(0x74000+i*0x400,40,1,dx,dy,i==3) for i in range(4))+move(0x20000,320,8,dx,dy,True)
  at=0xf500+k*128;assert not any(sprites[at:at+len(lst)]);sprites[at:at+len(lst)]=lst
 payloads=[(0x30000,(GEN/'tiles.bin').read_bytes()),(0x60000,bytes(sprites)),(0x6c000,(GEN/'tile-addresses.bin').read_bytes()),(0x70000,ram),(0x5f000,game_top),(0x10000,(GEN/'banners.bin').read_bytes())]
 for dest,data in payloads:
  for offset in range(0,len(data),4096):
   address=dest+offset;chunk=data[offset:offset+4096];chunk+=bytes(4096-len(chunk))
   out+=segment(0x7ffd,address.to_bytes(3,'little')+chunk)
   out+=segment(0x2e2,struct.pack('<H',boot['UPLOAD']))
 out+=segment(0x2e0,struct.pack('<H',boot['STARTER']))
 (ROOT/'pilka.xex').write_bytes(out)
 print(f'Built pilka.xex: {len(out)} bytes, {len(ops)} decoded instructions, {len(patches)} hardware patches.')
if __name__=='__main__':main()
