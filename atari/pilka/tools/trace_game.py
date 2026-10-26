#!/usr/bin/env python3
"""Run decompressed Arlasoft Soccer in the sibling conversion's C64 model."""
import sys,json
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent/'reference'))
from c64 import C64
ROOT=Path(__file__).resolve().parents[1]

def create():
 s=json.loads((ROOT/'analysis/manifest.json').read_text());c=C64()
 c.mem.ram[:]=(ROOT/'analysis/unpacked-64k.bin').read_bytes()
 c.mem.ram[0]=0x2f;c.port[:]=c.mem.ram[:2]
 for k,v in s['cpu'].items():setattr(c.cpu,k,v)
 c.vic[0x11]=0x1b;c.vic[0x16]=0xc8;c.vic[0x18]=0x14
 c.cia2.regs[0]=0x3f
 return c

if __name__=='__main__':
 from PIL import Image
 from vic import render,PAL
 c=create();c.log_io=True
 for f in range(600):
  c.joy2=0xef if 150<=f<160 or 300<=f<310 or 450<=f<460 else 0xff
  c.run(19656)
  if f in (119,249,399,599):
   Image.fromarray(PAL[render(c)]).save(ROOT/f'analysis/c64-{f}.png')
   print(f,hex(c.cpu.pc),hex(c.vic[0x11]),flush=True)
 (ROOT/'analysis/trace-ram.bin').write_bytes(c.mem.ram)
 (ROOT/'analysis/trace-io.json').write_text(json.dumps([[*k,v] for k,v in c.io_log.items()]))
