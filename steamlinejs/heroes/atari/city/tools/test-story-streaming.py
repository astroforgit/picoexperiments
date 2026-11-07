#!/usr/bin/env python3
"""Exercise disk-to-VBXE copying, version checks and missing media behavior."""
import importlib.util,json
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
layout=json.loads((r.ROOT/'generated/story-layout.json').read_text())
for page in (0xd600,0xd700):
 m=r.Machine(page)
 assets=bytes(m.mem.vram[0x20000:])
 for picture,start in enumerate(layout['sectors']):
  m.put('render_bank',m.get('back_bank'));m.cpu.a=picture
  m.mem.story_reads=[];m.call('story.load')
  assert m.cpu.p&1,'Valid disk rejected'
  assert m.mem.story_reads==[(3,128)]+[(s,256) for s in range(start,start+250)]
  bank=m.get('back_bank')*65536
  assert m.mem.vram[bank:bank+64000]==(r.ROOT/f'generated/story-{picture+1}.bin').read_bytes()
  assert bytes(m.mem.vram[0x20000:])==assets,'Story page changed gameplay graphics'
 for disk in (None,bytes(len(m.mem.story_disk)),m.mem.story_disk[:2000]):
  m.mem.story_disk=disk;m.cpu.a=0;m.call('story.load');assert not m.cpu.p&1
 print(f'PASS ${page:04X}: twelve exact 320x200 story/gallery pages, correct sector sizes/ranges, untouched gameplay VRAM, missing/wrong/truncated disk handling.')
