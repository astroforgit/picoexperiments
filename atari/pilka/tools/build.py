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

def bcb(src,ssy,ssx,dst,dsy,dsx,w,h,andm=255,xorm=0,zoom=0,ctrl=0):
 ssy&=0x1fff;dsy&=0x1fff
 return bytes([src&255,src>>8&255,src>>16,ssy&255,ssy>>8,ssx&255,dst&255,dst>>8&255,dst>>16,dsy&255,dsy>>8,dsx&255,(w-1)&255,(w-1)>>8,h-1,andm,xorm,0,zoom,0,ctrl])

def main():
 from build_assets import FGI,SHOWN
 from preview_swos import PALETTE as SWOS
 assets()
 banners()
 # Fixed palette entries (index, R, G, B; index 0 ends): character colours
 # and sprite colours. Entries that follow VIC registers are set at run time.
 pal=bytearray()
 for c,rgb in enumerate(SHOWN):
  pal+=bytes([FGI[c],*rgb]);pal+=bytes([0x60+c,*rgb])
 (GEN/'palette.bin').write_bytes(bytes(pal)+b'\0')
 def dta(name,values):
  values=list(values)
  return ''.join((name if i==0 else '')+' dta '+','.join(str(v) for v in values[i:i+16])+'\n' for i in range(0,len(values),16))
 t=dta('row40lo',[(i*40)&255 for i in range(25)])+dta('row40hi',[(i*40)>>8 for i in range(25)])
 t+=dta('row10',[i*10 for i in range(25)])
 t+=dta('ylo',[(i*320)&255 for i in range(200)])+dta('yhi',[(i*320)>>8 for i in range(200)])
 t+=dta('mul24lo',[(i*24)&255 for i in range(21)])+dta('mul24hi',[(i*24)>>8 for i in range(21)])
 t+=dta('ban_lo',[(i*64)&255 for i in range(40)])+dta('ban_mid',[0x80+((i*64)>>8) for i in range(40)])
 t+=dta('b0lut',[(i&3)<<6 for i in range(24)])+dta('b2lut',[i>>2 for i in range(24)])
 for n,i in (('c64r',0),('c64g',1),('c64b',2)):t+=dta(n,[c[i] for c in SHOWN])
 t+=dta('grassrgb',[v for k in (0,7,9) for v in SWOS[k*3:k*3+3]])
 (GEN/'render-tables.asm').write_text(t)
 # Label each bridge hardware operand to relocate precisely for a D700 VBXE.
 source=(SRC/'runtime.asm').read_text();source=re.sub(r'^vbrel_\d+\n','',source,flags=re.M)
 count=0;lines=[]
 for line in source.splitlines():
  if re.search(r'^\s+(?:sta|lda|ldx|ldy|stx|sty)\s+\$d6[45][0-9a-f]\b',line,re.I):
   lines.append(f'vbrel_{count}');count+=1
  lines.append(line)
 (SRC/'runtime.asm').write_text('\n'.join(lines)+'\n')
 (GEN/'relocs.asm').write_text(f'RELOC_COUNT = {count}\nreloc_lo dta '+','.join(f'<(vbrel_{i}+2)' for i in range(count))+'\nreloc_hi dta '+','.join(f'>(vbrel_{i}+2)' for i in range(count))+'\n')
 labels=assemble('runtime.asm')
 (GEN/'rt-labels.asm').write_text(''.join(f"{n} = ${labels[n]:04x}\n" for n in ('MEMB','BLIT_AT','BLIT_WAIT')))
 assemble('render.asm')
 original=(ROOT/'analysis/unpacked-64k.bin').read_bytes()
 ram=bytearray(original);ram[0]=0x2f
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
 def jsr(pc,label):ram[pc:pc+3]=b'\x20'+struct.pack('<H',labels[label])
 # The frame wait, and the game-loop point where sprites have just been
 # sorted (JSR $85E4): the renderer draws there, then the logic runs.
 ram[0x97b7:0x97ba]=b'\x4c'+struct.pack('<H',labels['FRAME_WAIT'])
 jsr(0x973c,'GAME_HOOK')
 jsr(0x93b3,'MENU_FRAME')
 jsr(0x1269,'FLIP_HOOK')                    # was LDA $11E5 (the hook ends with it)
 # The game slices its screen copy by the raster position.
 jsr(0x242f,'RASTER9');ram[0x2432:0x2435]=b'\x4c\x3a\x24'
 ram[0x9289:0x928c]=b'\xea\xea\xea' # Omit C64 sound update while audio is disabled.
 ram[0x9a44]=0x60 # SID envelope synchronisation has no Atari counterpart.
 # The C64 keeps data in the RAM under its I/O area ($D000-$DFFF), read
 # with I/O banked out. The Atari has hardware, colour RAM and the bridge's
 # variables there, so that data moves:
 # - the menu copies 768 bytes from $D780 to $BD00: source now $C900;
 ram[0xc900:0xcc00]=original[0xd780:0xda80]
 ram[0x93ec]=0x00
 ram[0x93f0]=0xc9
 # - formation records (35 bytes each, $9C98): indices 0-$20 at $DA7D...,
 #   $21-$28 at $C980,$CA80..$CF80,$D080 (inside sprite-pattern RAM that the
 #   bridge reuses). Both tables move into the bridge (rec0, rec1).
 assert ram[0x9ca2:0x9ca8]==bytes([0xa9,0xda,0x85,0x17,0xa9,0x7d]) and ram[0x9cb0:0x9cb9]==bytes([0x98,0x69,0xa7,0x85,0x17,0xa9,0x80,0xd0,0x12])
 ram[0x9ca3]=labels['REC0']>>8;ram[0x9ca7]=labels['REC0']&255
 jsr(0x9cb0,'REC1PTR');ram[0x9cb3:0x9cb6]=b'\x4c\xcb\x9c'
 # Game code at $F800-$FFF9 is restored from VRAM $5F000 by finish_boot
 # after the boot-only part of the runtime (loaded there) has run.
 game_top=bytes(ram[0xf800:0x10000])
 for addr,data in segments((GEN/'runtime.asm.obx').read_bytes()):
  if data:ram[addr:addr+len(data)]=data
 ram[labels['REC0']:labels['REC0']+1155]=original[0xda7d:0xda7d+1155]
 for k in range(8):
  at=0xc980+0x100*k;ram[labels['REC1']+35*k:labels['REC1']+35*k+35]=original[at:at+35]
 # The renderer bank is VRAM $7D000: the image's slot for $D000-$DFFF,
 # which is never copied to RAM.
 render=bytearray(4096)
 for addr,data in segments((GEN/'render.asm.obx').read_bytes()):
  if data and 0xc000<=addr<0xd000:render[addr-0xc000:addr-0xc000+len(data)]=data
 ram[0xd000:0xe000]=render
 (GEN/'ram.bin').write_bytes(ram)
 (GEN/'patches.json').write_text(json.dumps(patches,indent=2)+'\n')
 # A traced disassembly, with data left as bytes. Does not claim high-level C recovery.
 listing=['; Arlasoft Soccer: reachable disassembly from the supplied C64 PRG.','; Original addresses; uncertain/unreached regions remain binary data.']
 for pc,(n,txt) in sorted(ops.items()):listing.append(f'{pc:04X}  {bytes(cpu.memory[pc:pc+n]).hex(" "):8}  {txt}')
 (ROOT/'analysis/arlasoc-disassembly.txt').write_text('\n'.join(listing)+'\n')
 (GEN/'boot-defs.asm').write_text(f"RT_BOOT = ${labels['RT_BOOT']:04x}\n")
 boot=assemble('boot.asm');out=bytearray(b'\xff\xff')+(GEN/'boot.asm.obx').read_bytes()
 out+=segment(0x2e2,struct.pack('<H',boot['DETECT']))
 # VRAM $6F000: display lists, compare list and tile slots (see render.asm).
 PREV,COLR,ROWF,SEGF,DIFF,LAYER=0x6e000,0x6e800,0x6f040,0x6f060,0x6f240,0x20000
 sprites=bytearray((GEN/'sprites.bin').read_bytes())
 def put(at,data):
  assert not any(sprites[at-0x60000:at-0x60000+len(data)]);sprites[at-0x60000:at-0x60000+len(data)]=data
 for k in (0,1):   # 20 blank lines, then 200 lines of framebuffer k
  put(0x6f000+32*k,bytes([0x74,0x08,19,0,0,0,0x40,1,0x11,0xff, 0x62,0x88,199,0,0,k,0x40,1,0x11,0xff]))
 put(0x6f0e0,bcb(0,0,0,PREV,500,1,500,4,andm=0))
 cmpl=[bcb(PREV,500,1,PREV+1000,500,1,500,2,ctrl=8),
       bcb(COLR,500,1,COLR+1000,500,1,500,2,ctrl=8),
       bcb(PREV,40,1,DIFF,40,1,40,25,ctrl=8),            # source += ring origin
       bcb(0x7c000,40,1,DIFF,40,1,40,25,ctrl=8|5),       # XOR the C64 screen
       bcb(0,0,0,ROWF,160,1,160,1,andm=0,ctrl=8),
       bcb(DIFF,40,1,ROWF,1,0,40,25,ctrl=8|3)]           # OR each row into one byte
 cmpl+=[bcb(DIFF+8*k,40,1,SEGF+25*k,1,0,8,25,ctrl=(8 if k<4 else 0)|3) for k in range(5)]
 put(0x6f120,b''.join(cmpl))
 assert 0x6f120+21*len(cmpl)<=DIFF
 NT=120
 put(0x70000-21*NT,bcb(0,8,1,LAYER,320,1,8,8,ctrl=8)*NT)
 # Lists of VRAM $70000 (copied from $10A00 at boot): all slots draw nothing.
 piece=bcb(LAYER,320,1,0,320,1,1,1,andm=0,ctrl=9);sprite=bcb(0x60000,24,1,0,320,1,1,1,andm=0,ctrl=9)
 lists=piece*4+sprite*4+piece*16+sprite*26
 assert len(lists)<=1280
 payloads=[(0x30000,(GEN/'tiles.bin').read_bytes()),(0x60000,bytes(sprites)),(0x6c000,(GEN/'tile-map.bin').read_bytes()),(0x70000,ram),(0x5f000,game_top),(0x10000,(GEN/'banners.bin').read_bytes()+lists)]
 for dest,data in payloads:
  for offset in range(0,len(data),4096):
   address=dest+offset;chunk=data[offset:offset+4096];chunk+=bytes(4096-len(chunk))
   out+=segment(0x7ffd,address.to_bytes(3,'little')+chunk)
   out+=segment(0x2e2,struct.pack('<H',boot['UPLOAD']))
 out+=segment(0x2e0,struct.pack('<H',boot['STARTER']))
 (ROOT/'pilka.xex').write_bytes(out)
 print(f'Built pilka.xex: {len(out)} bytes, {len(ops)} decoded instructions, {len(patches)} hardware patches.')
if __name__=='__main__':main()
