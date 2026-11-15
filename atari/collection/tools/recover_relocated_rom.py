#!/usr/bin/env python3
"""Recover exact file-backed copies beneath ROM; this is relocation, not decompression.

Only the complete 95-byte table/copy helper is supported. An unsupported INIT
invalidates its state. Every copy is compared with two fresh py65 executions
that reject reads of unknown memory and unexpected writes. No OS ROM is assumed.
The helper must fit unbanked ordinary RAM, and input must stay below the XE bank
window. Successful calls preserve the entire helper except its index byte.
"""
from pathlib import Path
import argparse,hashlib,json,tempfile,subprocess,os,shutil
from py65.devices.mpu6502 import MPU
from disasm import parse,dta
from rebuild_stages import reconstruct
ROOT=Path(__file__).resolve().parents[1]
BODY=bytes.fromhex('78a0008c0ed4a9fe8d01d3ad3a230a0aaabd3b2385c0bd3c2385c1a92485c384c2b1c291c0e6c0d002e6c1e6c2d002e6c3bd3e23c5c1d0e9bd3d23c5c0d0e2ee3a23a9ff8d01d3a9408d0ed45860')
OPERANDS=(29,35,40,67,74,81)
def sha(b):return hashlib.sha256(b).hexdigest()
def body(base):
 b=bytearray(17)+bytearray(BODY)
 for p in OPERANDS:b[p:p+2]=(int.from_bytes(b[p:p+2],'little')-0x233a+base).to_bytes(2,'little')
 return bytes(b[17:])
def helper_address_supported(base):
 return (0x200<=base and base+95<=0x4000) or (0x8000<=base and base+95<=0xa000)
def identify(data,base):return helper_address_supported(base) and len(data)==95 and data[0]==0 and data[17:]==body(base)
def replay(base,helper,payload,lo,hi,variant):
 if not helper_address_supported(base):raise ValueError('Helper overlaps protected or banked memory')
 if 0x2400+len(payload)>0x4000:raise ValueError('Input crosses unproved XE bank window')
 class Memory:
  def __init__(self):self.data=bytearray([variant]*65536);self.known=set();self.writes=[]
  def load(self,a,b):self.data[a:a+len(b)]=b;self.known.update(range(a,a+len(b)))
  def __getitem__(self,a):
   if a not in self.known:raise ValueError('Unknown memory read at $%04X'%a)
   return self.data[a]
  def __setitem__(self,a,v):
   if not (lo<=a<hi or a in (base,0xc0,0xc1,0xc2,0xc3,0xd301,0xd40e)):raise ValueError('Unexpected write at $%04X'%a)
   self.data[a]=v;self.known.add(a);self.writes.append((a,v))
 m=Memory();m.load(base,helper);m.load(0x2400,payload);sp=0xa0 if variant else 0xfd;m.load(0x100+sp+1,bytes((0xff,0x04)))
 cpu=MPU(memory=m,pc=base+17);cpu.sp=sp;cpu.a=variant;cpu.x=variant;cpu.y=variant;cpu.p=variant
 steps=0
 while cpu.pc!=0x500:
  if not base+17<=cpu.pc<base+95:raise ValueError('Helper escaped its validated code')
  cpu.step();steps+=1
  if steps>(hi-lo)*20+100:raise ValueError('Copy did not return within bound')
 output=[(a,v) for a,v in m.writes if lo<=a<hi]
 if output!=list(zip(range(lo,hi),payload)):raise ValueError('CPU copy differs from file-backed image')
 hardware=[(a,v) for a,v in m.writes if a in (0xd301,0xd40e)]
 if hardware!=[(0xd40e,0),(0xd301,0xfe),(0xd301,0xff),(0xd40e,0x40)]:raise ValueError('Unexpected banking sequence')
 if m.data[base]!=helper[0]+1:raise ValueError('Unexpected table index')
 if bytes(m.data[base+1:base+95])!=helper[1:]:raise ValueError('Copy changed its helper table or code')
 return steps

def discover(game):
 raw=(game/'original.xex').read_bytes();parts,warning=parse(raw)
 if warning:raise ValueError(warning)
 ram=bytearray(65536);owners={};active=None;stages=[];images={};errors=[]
 for index,p in enumerate(parts):
  if p['kind']!='segment':continue
  a=p['address'];data=p['data'];ram[a:a+len(data)]=data;owners.update({a+i:p['offset']+4+i for i in range(len(data))})
  if identify(data,a):active=(a,0)
  if not a<=0x2e3<a+len(data):continue
  entry=int.from_bytes(ram[0x2e2:0x2e4],'little')
  if active is None or entry!=active[0]+17 or 0x2e2 not in owners:
   active=None;owners.clear();continue
  owners.pop(0x2e2,None);owners.pop(0x2e3,None)
  base,slot=active
  try:
   if slot>=4 or ram[base]!=slot or bytes(ram[base+17:base+95])!=body(base):raise ValueError('Copy helper state changed')
   helper=bytes(ram[base:base+95]);at=1+slot*4;lo=int.from_bytes(helper[at:at+2],'little');hi=int.from_bytes(helper[at+2:at+4],'little');n=hi-lo
   if not 0xc000<=lo<hi<=0x10000 or lo<0xd800 and hi>0xd000:raise ValueError('Destination is not a supported RAM-under-ROM span')
   if 0x2400+n>0x4000:raise ValueError('Input crosses unproved XE bank window')
   if any(x not in owners for x in range(0x2400,0x2400+n)):raise ValueError('Input is not entirely file-backed')
   if lo<base+95 and hi>base:raise ValueError('Output overwrites helper')
   payload=bytes(ram[0x2400:0x2400+n])
   if any(raw[owners[0x2400+i]]!=v for i,v in enumerate(payload)):raise ValueError('Input provenance changed')
   steps=replay(base,helper,payload,hi=hi,lo=lo,variant=0);other=replay(base,helper,payload,lo,hi,0xff)
   if steps!=other:raise ValueError('Replay depends on initial CPU state')
   name='relocated-%02d'%(len(stages)+1)
   stage={'source':name+'.asm','binary':name+'.bin','spans':[[lo,hi]],'bytes':n,'sha256':sha(payload),'code_bytes':0,'instructions':0,'entry_seeds':[],'helper_base':base,'table_slot':slot,'load_context_part':index,'cpu_steps':steps,'literal_patches':[[owners[0x2400+i],i] for i in range(n)],'independent_varied_state_copy_verified':True}
   stages.append(stage);images[stage['binary']]=payload;ram[base]=slot+1;active=(base,slot+1)
  except ValueError as error:errors.append({'part':index,'entry':entry,'error':str(error)});active=None;owners.clear()
 report={'folder':'games/'+game.name,'title':game.name,'original_sha256':sha(raw),'recovery_kind':'verified_runtime_relocation_not_decompression','stages':stages,'errors':errors,'limitations':['Only the shared under-ROM runtime copy is reconstructed; game-specific code/data and earlier ROM-preservation setup are not reconstructed.','These images are relocated original file bytes, not decompressed gameplay or original author source.','Exact full helper bytes and file ownership are checked; unknown INIT calls invalidate the tracked helper state.']}
 return report,images,raw

def publish(game):
 out=game/'decompiled/relocated-runtime'
 if (game/'decompiled/reconstruction.json').exists() or out.exists():return {'folder':'games/'+game.name,'status':'existing_project_preserved','stages':[]}
 report,images,raw=discover(game)
 if not report['stages']:return dict(report,status='no_supported_relocations')
 with tempfile.TemporaryDirectory(prefix='relocated-rom-') as temp:
  temp=Path(temp)
  for s in report['stages']:
   lo=s['spans'][0][0];payload=images[s['binary']];lines=['; Verified original-file bytes at their relocated runtime addresses.','; Shared runtime only; not decompression or complete game recovery.','    opt h-','    org $%04X'%lo]+[dta(payload[i:i+16]) for i in range(0,len(payload),16)]
   (temp/s['source']).write_text('\n'.join(lines)+'\n')
   p=subprocess.run([os.environ.get('MADS','mads'),s['source'],'-o:'+s['binary']],cwd=temp,capture_output=True,text=True,timeout=30)
   if p.returncode or (temp/s['binary']).read_bytes()!=payload:raise ValueError('MADS relocated image mismatch')
   s['mads_byte_exact']=True
  packed=reconstruct(report,raw,lambda n:(temp/n).read_bytes())
  (temp/'rebuilt-packed.xex').write_bytes(packed);report['status']='relocated_runtime_mads_verified';report['packed_xex_byte_exact']=True
  (temp/'recovery.json').write_text(json.dumps(report,indent=2)+'\n')
  (temp/'build.sh').write_text('#!/bin/sh\nset -eu\ncd "$(dirname "$0")"\n'+''.join('"${MADS:-mads}" '+s['source']+' -o:'+s['binary']+'\n' for s in report['stages'])+'python3 ../../../../tools/rebuild_stages.py .\n')
  (temp/'README.txt').write_text('Verified shared runtime relocation beneath ROM\n\n'+ '\n'.join(report['limitations'])+'\n\nBuild: sh build.sh\nIndependent copy audit: python3 ../../../../tools/recover_relocated_rom.py --audit "$(cd ../.. && pwd)"\n')
  if out.exists() or (game/'decompiled/reconstruction.json').exists() or (game/'original.xex').read_bytes()!=raw:raise ValueError('Project changed during preparation')
  shutil.copytree(temp,out)
 return {k:([{a:b for a,b in s.items() if a!='literal_patches'} for s in v] if k=='stages' else v) for k,v in report.items()}

def audit(game):
 saved=json.loads((game/'decompiled/relocated-runtime/recovery.json').read_text());fresh,images,raw=discover(game)
 if len(saved['stages'])!=len(fresh['stages']):raise ValueError('Relocation count changed')
 for s,f in zip(saved['stages'],fresh['stages']):
  for k in ('sha256','spans','literal_patches','helper_base','table_slot','load_context_part','cpu_steps'):
   if s[k]!=f[k]:raise ValueError('Relocation proof differs: '+k)
 reconstruct(saved,raw,lambda name:images[name]);return {'status':'independent_relocation_audit_passed','images':len(images)}
if __name__=='__main__':
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--game');p.add_argument('--audit',type=Path);p.add_argument('--publish',action='store_true');a=p.parse_args()
 if a.audit:print(json.dumps(audit(a.audit.resolve()),indent=2))
 elif a.game:
  g=ROOT/'games'/a.game;print(json.dumps(publish(g) if a.publish else discover(g)[0],indent=2))
 else:p.error('Provide --game or --audit')
