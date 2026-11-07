#!/usr/bin/env python3
"""Run the streamed gallery XEX: exact pages, constant caches and missing media."""
import importlib.util,json,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
labels={p[2].lower():int(p[1],16) for line in (r.ROOT/'generated/outro-full-quality.lab').read_text().splitlines() if len(p:=line.split())==3}
layout=json.loads((r.ROOT/'generated/outro-full-quality-layout.json').read_text())
count=layout['pictureCount'];offset=layout.get('pageOffset',4)
disk=r.ROOT/'generated'/('heroes-story.atr' if layout['requires']=='prince-and-the-nymph.atr' else layout['requires'])
def machine(page,missing_disk=False,wrong_disk=False):
 m=r.Machine.__new__(r.Machine);m.mem=r.Memory(page);m.cpu=r.MPU(memory=m.mem)
 m.mem.story_disk=disk.read_bytes()
 if wrong_disk:m.mem.story_disk=(r.ROOT/'generated/heroes-story.atr').read_bytes()
 if missing_disk:m.mem.story_disk=None
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
def next_page(m,i):
 address,down,up=(0xd20f,251,255) if i in (1,2) else (0xd010,0,1)
 if i in (1,2):m.mem.ram[0xd209]=12 if i==1 else 33
 m.mem.ram[address]=down;advance(m)
 m.mem.ram[address]=up;at(m,'.press')
 m.mem.ram[address]=down;at(m,'.finish');advance(m)
 m.mem.ram[address]=up;at(m)
for register_page in (0xd600,0xd700):
 m=machine(register_page);assert m.get('upload_index')==63
 immutable=bytes(m.mem.vram[0x20000:0x7f000])
 assert m.mem.palette==(r.ROOT/'generated/palette.bin').read_bytes()
 for i in range(count+1):
  page=i%count;assert m.mem.ram[labels['full_outro.page']]==page
  front=m.get('front_bank')*65536
  assert bytes(m.mem.vram[front:front+64000])==(r.ROOT/f'generated/outro-full-quality-{page+1}.bin').read_bytes()[:64000]
  assert bytes(m.mem.vram[0x20000:0x7f000])==immutable,'An image cache was allocated outside the screen buffers'
  sector=layout['sectors'][page+offset]
  assert m.mem.story_reads[-251:]==[(3,128)]+[(s,256) for s in range(sector,sector+250)]
  if i<count:next_page(m,i)
 print(f'PASS ${register_page:04X}: {count} exact disk-streamed pages, full replay, Fire/Enter/Space and held-key handling, 256-byte staging, zero resident image caches.',flush=True)
m=machine(0xd600,True);assert m.mem.ram[labels['full_outro.load_ok']]==0
m.mem.story_disk=disk.read_bytes();next_page(m,0)
assert m.mem.ram[labels['full_outro.page']]==0 and m.mem.ram[labels['full_outro.load_ok']]==1
m=machine(None);assert m.get('hardware_ok')==0 and not m.mem.blits
print('PASS: missing disk retries the same picture after attachment; missing VBXE uses the text fallback.')
if layout.get('configFile')=='galleryartist-content.json':
 m=machine(0xd600,wrong_disk=True)
 assert m.mem.ram[labels['full_outro.load_ok']]==0,'Accepted the unrelated main-game disk'
 print('PASS: artist viewer rejects the main-game disk instead of displaying unrelated pictures.')
if '--screens' in sys.argv:
 from PIL import Image
 out=Path(sys.argv[sys.argv.index('--screens')+1]);out.mkdir(parents=True,exist_ok=True);frames=[]
 for i in range(1,count+1):
  im=Image.open(r.ROOT/f'generated/outro-full-quality-{i}.png').convert('RGB');im.save(out/f'gallery-native-{i}.png');frames.append(im.resize((960,600),Image.NEAREST))
 frames[0].save(out/'gallery-preview.gif',save_all=True,append_images=frames[1:],duration=5000,loop=0)
