#!/usr/bin/env python3
import collections,json,sys
from trace_game import create,ROOT
from py65.disassembler import Disassembler
c=create();c.log_io=True
pcs=collections.Counter();writes=collections.Counter();reads=collections.Counter();ops={}
original_step=c.cpu.step
original_get=type(c.mem).__getitem__;original_set=type(c.mem).__setitem__
def get(self,a):
 reads[a]+=1
 return original_get(self,a)
def put(self,a,v):
 writes[a]+=1
 return original_set(self,a,v)
type(c.mem).__getitem__=get;type(c.mem).__setitem__=put
def step():
 p=c.cpu.pc;pcs[p]+=1
 if c.cpu.disassemble[c.mem.ram[p]][0]=='???':raise RuntimeError(f'Unmodelled opcode at {p:04x}')
 if p not in ops:
  n,s=Disassembler(c.cpu).instruction_at(p);ops[p]=[list(c.mem.ram[p:p+n]),s]
 return original_step()
c.cpu.step=step
for f in range(900):
 c.joy2=0xef if 150<=f<160 else (0xff if f<350 else [0xf7,0xfb,0xfe,0xfd,0xef,0xe7,0xff][(f//90)%7])
 c.run(19656)
 if f%300==299:print(f,hex(c.cpu.pc),len(pcs),flush=True)
(ROOT/'analysis/coverage.json').write_text(json.dumps({'pc':pcs,'writes':writes,'reads':reads,'ops':ops,'io':[[*k,v] for k,v in c.io_log.items()]}))
print('pages exec', sorted({p>>8 for p in pcs}));print('writes high',[(hex(p),sum(n for a,n in writes.items() if a>>8==p)) for p in range(0xc0,0x100)])
