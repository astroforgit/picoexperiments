#!/usr/bin/env python3
"""Execute the standalone full-resolution XEX, including actual INIT uploads."""
import importlib.util,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
labels={p[2].lower():int(p[1],16) for line in (r.ROOT/'generated/outro-full-quality.lab').read_text().splitlines() if len(p:=line.split())==3}
def machine(page):
 m=r.Machine.__new__(r.Machine);m.mem=r.Memory(page);m.cpu=r.MPU(memory=m.mem)
 data=(r.ROOT/'outro-full-quality-test.xex').read_bytes();i=0
 while i<len(data):
  start=int.from_bytes(data[i:i+2],'little');i+=2
  if start==65535:continue
  end=int.from_bytes(data[i:i+2],'little');i+=2;n=end-start+1
  for a,v in enumerate(data[i:i+n],start):m.mem[a]=v
  i+=n
  if start<=0x2e2<=end:m.call(int.from_bytes(m.mem.ram[0x2e2:0x2e4],'little'))
 m.cpu.pc=int.from_bytes(m.mem.ram[0x2e0:0x2e2],'little')
 m.run_until(labels['full_outro.wait_action'] if page else r.LABELS['no_vbxe'])
 return m
def at(m,suffix=''):m.run_until(labels['full_outro.wait_action'+suffix])
def advance(m,count=12000):
 for tick in range(count):
  if tick%1000==0:m.mem.ram[0x14]=(m.mem.ram[0x14]+1)&255
  m.cpu.step()

for register_page in (0xd600,0xd700):
 m=machine(register_page);assert m.get('upload_index')==96
 assert m.mem.palette==(r.ROOT/'generated/palette.bin').read_bytes()
 for i in range(4):
  exported=(r.ROOT/f'generated/outro-full-quality-{i+1}.bin').read_bytes()
  assert bytes(m.mem.vram[(i+2)*65536:(i+3)*65536])==exported
  assert exported[:188*320]==(r.ROOT/f'generated/story-{i+1}.bin').read_bytes()[:188*320], 'Viewer differs from full-quality game artwork/captions'
 for i in range(5):
  page=i%4
  assert m.mem.ram[labels['full_outro.page']]==page
  front=m.get('front_bank')*65536
  assert bytes(m.mem.vram[front:front+64000])==(r.ROOT/f'generated/outro-full-quality-{page+1}.bin').read_bytes()[:64000]
  if i==4:break # Three ending scenes plus game over replay to the first page.
  address,down,up=(0xd010,0,1) if i in (0,3) else (0xd20f,251,255)
  if i in (1,2):m.mem.ram[0xd209]=12 if i==1 else 33
  m.mem.ram[address]=down;advance(m);assert m.mem.ram[labels['full_outro.page']]==page
  m.mem.ram[address]=up;at(m,'.press')
  m.mem.ram[address]=down;at(m,'.finish');advance(m);assert m.mem.ram[labels['full_outro.page']]==page
  m.mem.ram[address]=up;at(m)
 print(f'PASS ${register_page:04X}: real standalone XEX uploads, shared 256-colour palette, four exact 320x200 pages including game over, Fire/Enter/Space, held-key handling and full replay.')
m=machine(None);assert m.get('hardware_ok')==0 and not m.mem.blits
print('PASS missing VBXE: text fallback and no graphics writes.')

if '--screens' in sys.argv:
 from PIL import Image
 out=Path(sys.argv[sys.argv.index('--screens')+1]);out.mkdir(parents=True,exist_ok=True)
 frames=[]
 for i in (1,2,3,4):
  im=Image.open(r.ROOT/f'generated/outro-full-quality-{i}.png').convert('RGB');im.save(out/f'story-outro-full-quality-{i}.png');frames.append(im.resize((960,600),Image.Resampling.NEAREST))
 frames[0].save(out/'story-outro-full-quality-preview.gif',save_all=True,append_images=frames[1:],duration=6500,loop=0)
