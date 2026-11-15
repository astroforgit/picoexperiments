#!/usr/bin/env python3
"""Conservative Zaxxon-family backward-stream recovery and family-specific audit.

Probe is read-only for game folders. Publication follows guarded dual replay,
MADS assembly and pure packed reconstruction preflight in temporary storage.
Unknown cores, loader context and previously recovered/curated projects are skipped.
"""
from pathlib import Path
import argparse,concurrent.futures,hashlib,json,os,subprocess,tempfile,time
from py65.devices.mpu6502 import MPU
from disasm import parse,instruction,dta
from opcodes import OPS,SIZE
from recover_common import trace
from rebuild_stages import reconstruct
ROOT=Path(__file__).resolve().parents[1]
FAMILY='backward-zaxxon-v1'
SIGNATURE=bytes.fromhex('a20cb52048ca10faa90085208421a000b120')
TEMPLATE=bytes.fromhex('8e3340a20cb52048ca10faa90085208421a000b120aa8522852ca52038e522b002c6218520b120999d79c8cad0f7a205a000a520d002c621c6208af007b1209522ca10eee898290ff0148a4abeff782a2629ca10fa793379aaa5297967799968798a993479a20420a740990079c8c034d0d2a00020fe40a2f368952de8d0fa60a9008529e00190414623d037488422a000b12008a421c425d018a420c424d01248a52c18699c8520a9796900852168189008a420d002c621c620a4222890136a8523682a2629cad0bf60cac627c62b88b12a912698d0f88ad0f088e820af404ac890f8f02bc011b059beff7820a7407933798528a52979677948d006a428c0049002a003be694120a740796c41a8a528e5269002c62749ff8526c001b0034cb440be007920a7407934799003e629186526852aa5297968796527852b68aaa428909260020404302010')
REL={1:12,104:128,117:215,221:136,237:128,261:322,264:128,267:325,287:141,293:128}
TABLE={40:157,77:-1,86:51,92:103,95:104,99:52,107:0,234:-1,240:51,247:103,290:0,296:52,310:104}
PC_OFFSETS=set();_a=0
while _a<323:
 PC_OFFSETS.add(_a);_a+=SIZE[OPS[TEMPLATE[_a]][1]]
def sha(data):return hashlib.sha256(data).hexdigest()
def word(memory,a):return memory[a]|memory[a+1]<<8
def touches_io(lo,hi):return lo<0xd800 and hi>0xd000

def validate_core(memory,core,owners=None):
 if core<0x200 or core+329>65536 or touches_io(core,core+329):return None
 actual=bytes(memory[core:core+329])
 if len(actual)!=329:return None
 table=word(actual,40)-157
 if table<0x100 or table+157>65536 or touches_io(table,table+157) or not (table+157<=core or table>=core+329):return None
 expected=bytearray(TEMPLATE)
 for i,v in REL.items():expected[i:i+2]=(core+v).to_bytes(2,'little')
 for i,v in TABLE.items():expected[i:i+2]=(table+v).to_bytes(2,'little')
 expected[165]=(table+156)&255;expected[169]=(table+156)>>8
 if actual!=expected:return None
 if owners is not None and any(a not in owners for a in range(core,core+329)):return None
 return table

def cores(memory,owners):
 at=0;b=bytes(memory)
 while True:
  at=b.find(SIGNATURE,at)
  if at<0:return
  core=at-3;table=validate_core(memory,core,owners)
  if table is not None:yield core,table
  at+=1

def reachable_calls(memory,owners,entry,valid_cores,diagnostics=None):
 """Static loaded-code paths with conservative constant register propagation.

 Known X/Y values survive simple instructions/branches, never unknown loads or
 subroutine returns. Fixed immediate-XY wrappers falling into a core are covered.
 No arbitrary loader code is emulated and no memory stores are synthesized.
 """
 todo=[(entry,None,None,None,-1)];seen=set();found=set()
 while todo and len(seen)<24000:
  pc,a,x,y,caller=todo.pop();state=(pc,a,x,y,caller)
  if state in seen or pc not in owners:continue
  seen.add(state)
  if pc in valid_cores:
   if x is not None and y is not None:found.add((caller,pc,x|y<<8))
   continue
  if memory[pc] not in OPS:continue
  op,mode=OPS[memory[pc]];n=SIZE[mode]
  if pc+n>65536 or any(pc+k not in owners for k in range(n)):continue
  val=int.from_bytes(memory[pc+1:pc+n],'little');nextpc=pc+n
  if op in ('jsr','jmp'):
   if mode!='abs':continue
   if val in valid_cores and x is not None and y is not None:found.add((pc,val,x|y<<8))
   if op=='jsr':todo.append((nextpc,None,None,None,caller))
   todo.append((val,a,x,y,pc))
   continue
  if op in ('rts','rti','brk'):continue
  if mode=='rel':todo.append(((nextpc+(val if val<128 else val-256))&65535,a,x,y,caller))
  if op=='lda':a=val if mode=='imm' else None
  elif op=='ldx':x=val if mode=='imm' else None
  elif op=='ldy':y=val if mode=='imm' else None
  elif op=='tax':x=a
  elif op=='tay':y=a
  elif op=='txa':a=x
  elif op=='tya':a=y
  elif op=='tsx':x=None
  elif op=='inx':x=None if x is None else (x+1)&255
  elif op=='dex':x=None if x is None else (x-1)&255
  elif op=='iny':y=None if y is None else (y+1)&255
  elif op=='dey':y=None if y is None else (y-1)&255
  elif op in ('and','ora','eor'):
   if mode!='imm' or a is None:a=None
   elif op=='and':a&=val
   elif op=='ora':a|=val
   else:a^=val
  elif op in ('adc','sbc','pla'):a=None
  elif op in ('asl','lsr','rol','ror') and mode in ('acc','imp'):a=None
  todo.append((nextpc,a,x,y,caller))
 if diagnostics is not None:diagnostics.update(abstract_states=len(seen),scan_truncated=bool(todo))
 return sorted(found)

def snapshots(data):
 parts,warning=parse(data)
 if warning:raise ValueError(warning)
 memory=bytearray(65536);owners={};first=None;last_segment=max((i for i,p in enumerate(parts) if p['kind']=='segment'),default=-1)
 for index,p in enumerate(parts):
  if p['kind']!='segment':continue
  a=p['address'];n=len(p['data']);memory[a:a+n]=p['data'];owners.update({a+i:p['offset']+4+i for i in range(n)})
  if first is None:first=a
  init=a<=0x2e3<a+n and 0x2e2 in owners
  if init:yield index,word(memory,0x2e2),'INITAD',memory,owners
  if index==last_segment:
   entry=word(memory,0x2e0) if 0x2e0 in owners and 0x2e1 in owners else first
   yield index,entry,'RUNAD' if 0x2e0 in owners and 0x2e1 in owners else 'default_entry',memory,owners
  if init:owners.pop(0x2e2,None);owners.pop(0x2e3,None)

def stack_setup(table,reserved_end,stack_context,default_sp):
 if table>=0x200:return default_sp,[]
 if not stack_context or stack_context.get('kind')!='prefix_TXS_FF_then_JSR' or stack_context.get('entry_sp')!=0xfd or stack_context.get('reset_value')!=0xff:
  raise ValueError('Stack workspace requires a proven TXS $FF reset and decoder JSR entry SP $FD')
 live=[0x1fe,0x1ff]
 if stack_context.get('prior_caller_live_bytes')!=live:raise ValueError('Prior caller frame not proven')
 if any(table<=a<reserved_end for a in live):raise ValueError('Workspace collides with prior caller stack bytes')
 return 0xfd,live

def check_stack_workspace(cpu,table,reserved_end,prior_live):
 if any(table<=a<reserved_end for a in prior_live):raise ValueError('Workspace collides with prior caller stack bytes')
 opcode=cpu.memory[cpu.pc];addresses=[]
 if opcode in (0x48,0x08):addresses=[0x100+cpu.sp]
 elif opcode==0x20:addresses=[0x100+cpu.sp,0x100+((cpu.sp-1)&255)]
 elif opcode in (0x68,0x28):addresses=[0x100+((cpu.sp+1)&255)]
 elif opcode==0x60:addresses=[0x100+((cpu.sp+1)&255),0x100+((cpu.sp+2)&255)]
 if any(a in prior_live for a in addresses):raise ValueError('Decoder stack access collides with prior caller frame')
 if any(table<=a<reserved_end for a in addresses):raise ValueError('Workspace collides with live decoder stack access')
 return addresses

def replay(data,ram,owners,core,end,variant=0,guarded=True,stack_context=None):
 table=validate_core(ram,core,owners)
 if table is None:raise ValueError('Complete decoder/context validation failed')
 if end not in owners:raise ValueError('Input-end byte is not original-file backed')
 memory=[((a*73+0xa5)&255) if variant else 0 for a in range(65536)]
 for a in owners:memory[a]=ram[a]
 cpu=MPU(memory=memory);cpu.pc=core;cpu.x=end&255;cpu.y=end>>8;cpu.a=0x9b if variant else 0;cpu.p=0xe1 if variant else 0x20;cpu.sp=0xd0 if variant else 0xfd
 initial_sp=cpu.sp
 origins=dict(owners);written=set();literals=[];last_input=None;previous=None;inputreads=set();refreads=0;destination_initialized=set();writes=[]
 tail_count=ram[end] or 256;reserved_end=table+157+tail_count
 if reserved_end>65536:raise ValueError('Tail-buffer address wraps')
 if touches_io(table,reserved_end):raise ValueError('Tail buffer overlaps Atari I/O')
 if not (reserved_end<=core or table>=core+329):raise ValueError('Tail buffer overlaps decoder')
 cpu.sp,prior_live=stack_setup(table,reserved_end,stack_context,cpu.sp);initial_sp=cpu.sp;stack_addresses=set(prior_live)
 if prior_live:
  return_address=(stack_context['call']+2)&65535;cpu.memory[0x1fe]=return_address&255;cpu.memory[0x1ff]=return_address>>8
 for steps in range(5000000):
  pc=cpu.pc;off=pc-core
  if off==127 and cpu.sp==initial_sp:break
  if off not in PC_OFFSETS:raise ValueError(f'Decoder escaped validated instruction boundary ${pc:04X}')
  stack_addresses.update(check_stack_workspace(cpu,table,reserved_end,prior_live))
  if off in (19,37,61,145):
   src=(word(cpu.memory,0x20)+cpu.y)&65535
   if guarded:
    if 0xd000<=src<0xd800:raise ValueError('Input read targets Atari I/O')
    if src not in origins:raise ValueError(f'Input lacks original-file provenance ${src:04X}')
    if cpu.memory[src]!=data[origins[src]]:raise ValueError('Input changed from archived byte')
   last_input=src
   if src in origins:inputreads.add(origins[src])
  if off==39:
   dest=table+157+cpu.y
   if last_input not in origins:raise ValueError('Tail buffer lacks provenance')
   origins[dest]=origins[last_input]
  if off==63 and cpu.x in (4,5):destination_initialized.add(cpu.x)
  if off==208:
   ref=(word(cpu.memory,0x2a)+cpu.y)&65535
   if guarded and ref not in written:raise ValueError(f'Backreference precedes emitted output ${ref:04X}')
   refreads+=1
  if off==210:
   dest=(word(cpu.memory,0x26)+cpu.y)&65535
   if guarded:
    if destination_initialized!={4,5}:raise ValueError('Output destination uses initial RAM')
    if 0xd000<=dest<0xd800:raise ValueError(f'Output targets Atari I/O ${dest:04X}')
    if dest<0x200 or core<=dest<core+329 or table<=dest<reserved_end:raise ValueError(f'Output overlaps active decoder/state ${dest:04X}')
    if dest in written:raise ValueError('Duplicate output address')
   if previous==core+189:
    if last_input not in origins:raise ValueError('Literal lacks source provenance')
    literals.append((origins[last_input],dest))
   elif previous!=core+208:raise ValueError('Unexpected output provenance')
   written.add(dest);writes.append((dest,cpu.a))
  previous=pc;cpu.step()
 else:raise ValueError('Decoder exceeded instruction budget')
 if prior_live and (cpu.memory[0x1fe]|cpu.memory[0x1ff]<<8)!=return_address:raise ValueError('Decoder changed caller return bytes')
 if not written:raise ValueError('Decoder emitted no output')
 spans=[]
 for a in sorted(written):
  if spans and spans[-1][1]==a:spans[-1][1]=a+1
  else:spans.append([a,a+1])
 image=b''.join(bytes(cpu.memory[lo:hi]) for lo,hi in spans);indices={a:i for i,a in enumerate(a for lo,hi in spans for a in range(lo,hi))};patches=[[off,indices[dest]] for off,dest in literals]
 if any(data[off]!=image[i] for off,i in patches):raise ValueError('Literal mapping differs from original')
 result={'spans':spans,'bytes':len(image),'sha256':sha(image),'literal_patches':patches,'depacker_steps':steps,'backreference_reads':refreads,'input_file_bytes_read':len(inputreads),'table_address':table,'tail_buffer_bytes':tail_count}
 if table<0x200:result['stack_partition_proof']={'entry_sp_context':stack_context,'workspace_start':table,'workspace_end_exclusive':reserved_end,'prior_caller_live_bytes':prior_live,'lowest_stack_address_accessed':min(stack_addresses),'all_stack_reads_and_writes_disjoint':True,'caller_return_address':return_address,'caller_return_bytes_preserved':True}
 return result,image,bytes(cpu.memory),writes

class ReferenceMemory(list):
 """Independent write recorder: no decoder output-instruction assumptions."""
 def __init__(self,values,core,table,reserved_end):
  super().__init__(values);self.core=core;self.table=table;self.reserved_end=reserved_end;self.output=[]
 def __setitem__(self,address,value):
  if not isinstance(address,int):raise ValueError('Unexpected reference memory operation')
  if address>=0x200 and not self.core<=address<self.core+329 and not self.table<=address<self.reserved_end:
   self.output.append((address,value&255))
  super().__setitem__(address,value)

def reference_replay(ram,owners,core,end,stack_context=None):
 """Fresh CPU and RAM; independently record every non-workspace memory write."""
 table=validate_core(ram,core,owners)
 if table is None:raise ValueError('Reference decoder validation failed')
 values=[(a*73+0xa5)&255 for a in range(65536)]
 for a in owners:values[a]=ram[a]
 memory=ReferenceMemory(values,core,table,table+157+(ram[end] or 256))
 cpu=MPU(memory=memory);cpu.pc=core;cpu.x=end&255;cpu.y=end>>8;cpu.a=0x9b;cpu.p=0xe1;cpu.sp=0xd0
 cpu.sp,prior_live=stack_setup(table,memory.reserved_end,stack_context,cpu.sp);initial_sp=cpu.sp
 if prior_live:
  return_address=(stack_context['call']+2)&65535;cpu.memory[0x1fe]=return_address&255;cpu.memory[0x1ff]=return_address>>8
 for steps in range(5000000):
  if cpu.pc==core+127 and cpu.sp==initial_sp:break
  if cpu.pc-core not in PC_OFFSETS:raise ValueError('Reference decoder escaped')
  check_stack_workspace(cpu,table,memory.reserved_end,prior_live)
  cpu.step()
 else:raise ValueError('Reference decoder exceeded instruction budget')
 if prior_live and (cpu.memory[0x1fe]|cpu.memory[0x1ff]<<8)!=return_address:raise ValueError('Reference decoder changed caller return bytes')
 addresses=sorted(a for a,v in memory.output)
 if not addresses or len(addresses)!=len(set(addresses)):raise ValueError('Reference empty/overlapping output')
 spans=[]
 for a in addresses:
  if spans and spans[-1][1]==a:spans[-1][1]=a+1
  else:spans.append([a,a+1])
 image=b''.join(bytes(memory[lo:hi]) for lo,hi in spans)
 return spans,image,memory.output,steps

def prove(data,ram,owners,core,end,stack_context=None):
 result,image,memory,writes=replay(data,ram,owners,core,end,0,True,stack_context)
 spans,other,other_writes,steps=reference_replay(ram,owners,core,end,stack_context)
 if image!=other or writes!=other_writes or result['spans']!=spans or result['depacker_steps']!=steps:raise ValueError('Independent reference memory-write replay differs')
 result.update(decoder_family=FAMILY,guarded_replay=True,independent_compressed_stream_verified=True,independent_replay='fresh CPU and independent memory-write recorder; different unused RAM, accumulator, status/carry and stack; identical output write sequence, image, spans and step count',contextual_proof={'complete_decoder_bytes':329,'instruction_boundaries_validated':True,'source_reads_original_file_backed':True,'tail_copy_provenance_tracked':True,'backreferences_to_emitted_output_only':True,'destination_header_initialized':True,'unique_output_writes':True,'active_decoder_stack_tables_preserved':True,'atari_io_output_rejected':True,'independent_all_memory_write_recording':True})
 if result['table_address']<0x200:
  result['independent_replay']='fresh CPU and independent memory-write recorder with varied unused RAM/A/status; both runs use the independently proven SP $FD; caller frame and every decoder stack access are disjoint from workspace'
  result['contextual_proof']['entry_stack_and_prior_caller_frame_proven']=True
 return result,image,memory

def loader_prefix(data,ram,owners,entry,variant=0):
 """Execute only a known-value loader prefix; stop before unmodeled behavior.

 Register/flag/byte initialization is tracked separately from file provenance.
 Only copied original bytes retain provenance. RTC waiting has an exact checked
 summary; hardware reads and bank-select values other than $FE/$FF stop replay.
 """
 values=[((a*37+0xa5)&255) if variant else 0 for a in range(65536)]
 for a in owners:values[a]=ram[a]
 cpu=MPU(memory=values);cpu.pc=entry;cpu.sp=0xd0 if variant else 0xfd;cpu.p=0xe1 if variant else 0x20
 origins=dict(owners);initialized=set(owners);known={'a':False,'x':False,'y':False};reg_origin={'a':None,'x':None,'y':None};flags=set();writes=[];calls=[];helpers=[];portb=None;stack_reset=None;call_stacks={};invalidated=set();return_frame_intact=True;reason='instruction budget';trace_bytes=bytearray()
 branch_flags={'beq':'Z','bne':'Z','bpl':'N','bmi':'N','bcc':'C','bcs':'C','bvc':'V','bvs':'V'}
 def store(address,value,origin,caller_sensitive=True):
  nonlocal return_frame_intact
  if caller_sensitive and 0x100<=address<0x200:return_frame_intact=False
  writes.append((address,value,origin));initialized.add(address);cpu.memory[address]=value
  if origin is None:origins.pop(address,None)
  else:
   if data[origin]!=value:raise ValueError('Loader copy lost original-byte provenance')
   origins[address]=origin
 def wait_summary():
  known['a']=False;reg_origin['a']=None;cpu.a=0xa5 if variant else 0x5a;cpu.p&=~2;flags.difference_update(('N','Z','C'));flags.add('Z')
 for steps in range(200000):
  pc=cpu.pc
  if touches_io(pc,pc+1) or (pc>=0xc000 and portb!=0xfe):reason='instruction fetch requires unmodeled hardware/ROM';break
  if pc not in initialized or cpu.memory[pc] not in OPS:reason='instruction fetch not initialized or unsupported';break
  if pc+6<=65536 and not touches_io(pc,pc+6) and (pc+6<=0xc000 or portb==0xfe) and all(a in origins for a in range(pc,pc+6)) and bytes(cpu.memory[pc:pc+6])==bytes.fromhex('a514c514f0fc'):
   helpers.append({'kind':'exact_inline_RTC_wait','address':pc});trace_bytes.extend(pc.to_bytes(2,'little')+bytes(cpu.memory[pc:pc+6]));wait_summary();cpu.pc+=6;continue
  op,mode=OPS[cpu.memory[pc]];n=SIZE[mode]
  if pc+n>65536 or any(a not in initialized for a in range(pc,pc+n)) or touches_io(pc,pc+n) or (pc+n>0xc000 and portb!=0xfe):reason='instruction operand not initialized or requires hardware/ROM';break
  val=int.from_bytes(cpu.memory[pc+1:pc+n],'little');trace_bytes.extend(pc.to_bytes(2,'little')+bytes(cpu.memory[pc:pc+n]));address=None
  if mode in ('abs','abx','aby','zp','zpx','zpy'):
   address=val
   if mode in ('abx','zpx'):
    if not known['x']:reason='unproven X index';break
    address+=cpu.x
   if mode in ('aby','zpy'):
    if not known['y']:reason='unproven Y index';break
    address+=cpu.y
   address&=255 if mode in ('zp','zpx','zpy') else 65535
  elif mode not in ('imp','acc','imm','rel') and op not in ('jmp','jsr'):
   reason='unsupported addressing mode';break
  if op in ('jsr','jmp'):
   if mode!='abs':reason='indirect control flow';break
   if op=='jsr' and pc<0x200:reason='call instruction overlaps stack page';break
   if touches_io(val,val+1) or (val>=0xc000 and portb!=0xfe):reason='control transfer requires hardware/ROM';break
   core=validate_core(cpu.memory,val,origins)
   if core is not None:
    if known['x'] and known['y']:
     calls.append((pc,val,cpu.x|cpu.y<<8));reason='validated decoder call'
     if op=='jsr' and stack_reset and stack_reset['value']==255 and cpu.sp==255:call_stacks[str(pc)]={'kind':'prefix_TXS_FF_then_JSR','reset_pc':stack_reset['pc'],'reset_value':255,'call':pc,'entry_sp':253,'prior_caller_live_bytes':[510,511]}
    else:reason='decoder arguments not proven'
    break
   helper=bytes(cpu.memory[val:val+10]);helper_range=set(range(val,val+10));helper_writes={0x22f}|({0x100+cpu.sp,0x100+((cpu.sp-1)&255)} if stack_reset else set(range(0x100,0x200)))
   if op=='jsr' and not helper_range.intersection(helper_writes) and val+10<=65536 and not touches_io(val,val+10) and (val+10<=0xc000 or portb==0xfe) and all(a in origins for a in range(val,val+10)) and helper in (bytes.fromhex('8e2f02a514c514f0fc60'),bytes.fromhex('8d2f02a514c514f0fc60')):
    register='x' if helper[0]==0x8e else 'a'
    if not known[register]:reason='DMA helper argument unproven';break
    if stack_reset is None:
     for address in range(0x100,0x200):origins.pop(address,None);initialized.discard(address);invalidated.add(address)
    else:
     return_address=pc+2;store(0x100+cpu.sp,return_address>>8,None,False);store(0x100+((cpu.sp-1)&255),return_address&255,None,False)
    store(0x22f,getattr(cpu,register),reg_origin[register]);helpers.append({'kind':'exact_DMA_RTC_helper','address':val,'call':pc,'stack_effect':'two exact JSR return-byte writes' if stack_reset else 'unknown SP: all stack-page ownership invalidated'});wait_summary();cpu.pc=pc+3;continue
   if op=='jsr':reason='unmodeled subroutine';break
   cpu.pc=val;continue
  if op in ('rts','rti','brk'):reason='modeled RTS return' if op=='rts' and return_frame_intact else 'unproven caller return or terminal instruction';break
  if op in branch_flags:
   if branch_flags[op] not in flags:reason='branch condition unproven';break
  elif op in ('lda','ldx','ldy'):
   register=op[-1]
   if mode!='imm':
    if address is None or address not in initialized or touches_io(address,address+1) or (address>=0xc000 and portb!=0xfe):reason='read requires uninitialized RAM or hardware/ROM';break
   known[register]=True;reg_origin[register]=origins.get(address) if mode!='imm' else None;flags.update(('N','Z'))
  elif op in ('sta','stx','sty'):
   register=op[-1]
   if address is None or not known[register]:reason='store value/address unproven';break
   value=getattr(cpu,register)
   if touches_io(address,address+1):
    if address not in (0xd301,0xd40e,0xd409):reason='unmodeled hardware write';break
    if address==0xd301:
     if value not in (0xfe,0xff):reason='banked memory configuration unsupported';break
     portb=value
   elif address>=0xc000 and portb!=0xfe:reason='store requires ROM-disabled RAM';break
   store(address,value,reg_origin[register])
  elif op in ('inx','dex','iny','dey'):
   register=op[-1]
   if not known[register]:reason='register arithmetic uses initial value';break
   reg_origin[register]=None;flags.update(('N','Z'))
  elif op in ('tax','tay','txa','tya'):
   source_register=op[1];target_register=op[2]
   if not known[source_register]:reason='register transfer uses unknown value';break
   known[target_register]=True;reg_origin[target_register]=reg_origin[source_register];flags.update(('N','Z'))
  elif op=='txs':
   if not known['x']:reason='stack initialization unknown';break
   stack_reset={'pc':pc,'value':cpu.x};return_frame_intact=False
  elif op in ('inc','dec'):
   if address is None or address not in initialized or touches_io(address,address+1) or (address>=0xc000 and portb!=0xfe):reason='memory arithmetic unproven or requires hardware/ROM';break
   value=(cpu.memory[address]+(1 if op=='inc' else -1))&255
   if 0x100<=address<0x200:return_frame_intact=False
   writes.append((address,value,None));origins.pop(address,None);flags.update(('N','Z'))
  elif op in ('cmp','cpx','cpy'):
   register='a' if op=='cmp' else op[-1]
   if not known[register]:reason='comparison register unknown';break
   if mode!='imm' and (address is None or address not in initialized or touches_io(address,address+1) or (address>=0xc000 and portb!=0xfe)):reason='comparison memory unproven';break
   flags.update(('N','Z','C'))
  elif op in ('clc','sec'):flags.add('C')
  elif op not in ('sei','cli','cld','nop'):
   reason='unsupported loader instruction '+op;break
  cpu.step()
 copied={address:origin for address,value,origin in writes if origin is not None and not touches_io(address,address+1)}
 ranges=[]
 for address,origin in sorted(copied.items()):
  if ranges and address==ranges[-1][1] and origin==ranges[-1][2]+address-ranges[-1][0]:ranges[-1][1]+=1
  else:ranges.append([address,address+1,origin])
 proof={'entry':entry,'stop_pc':cpu.pc,'stop_reason':reason,'instructions':steps,'original_byte_copy_ranges':ranges,'copied_bytes':len(copied),'trace_sha256':sha(trace_bytes),'writes_sha256':sha(json.dumps(writes,separators=(',',':')).encode()),'exact_hardware_wait_summaries':helpers,'portb_at_stop':portb,'known_value_and_flag_checks':True,'observed_call_stack_contexts':call_stacks,'invalidated_addresses':sorted(invalidated),'original_caller_return_frame_preserved':return_frame_intact}
 return bytes(cpu.memory),origins,writes,calls,proof

def relocated_snapshots(data):
 """Replay safe prefixes, retaining their original-byte copy provenance."""
 parts,warning=parse(data)
 if warning:raise ValueError(warning)
 ram=bytearray(65536);owners={};first=None;last=max(i for i,p in enumerate(parts) if p['kind']=='segment');history=[]
 for index,p in enumerate(parts):
  if p['kind']!='segment':continue
  a=p['address'];n=len(p['data']);ram[a:a+n]=p['data'];owners.update({a+i:p['offset']+4+i for i in range(n)})
  if first is None:first=a
  init=a<=0x2e3<a+n and 0x2e2 in owners
  if init:
   entry=word(ram,0x2e2);before=bytes(ram);before_owners=dict(owners)
   memory,origins,writes,calls,proof=loader_prefix(data,ram,owners,entry)
   other,other_origins,other_writes,other_calls,other_proof=loader_prefix(data,ram,owners,entry,1)
   if writes!=other_writes or calls!=other_calls or proof!=other_proof:raise ValueError('Independent loader-prefix replay differs')
   # Preserve deterministic writes only; untouched unspecified RAM never becomes evidence.
   for address in proof['invalidated_addresses']:owners.pop(address,None)
   for address,value,origin in writes:
    ram[address]=value
    if origin is None:owners.pop(address,None)
    else:owners[address]=origin
   proof['independent_replay']=True;history.append(proof)
   # Static continuation uses the archived instruction bytes; copied code is added.
   call_ram=bytearray(before);call_owners=dict(before_owners)
   for address,value,origin in writes:
    if origin is not None:call_ram[address]=value;call_owners[address]=origin
   yield index,entry,'INITAD',ram,owners,{'loader_prefixes':list(history),'observed_calls':calls,'call_ram':call_ram,'call_owners':call_owners}
   # No assumptions about writes by decoder/game/unknown continuation are carried into a later INIT.
   if proof['stop_reason']!='modeled RTS return':owners.clear()
  if index==last:
   entry=word(ram,0x2e0) if 0x2e0 in owners and 0x2e1 in owners else first
   yield index,entry,'RUNAD' if 0x2e0 in owners and 0x2e1 in owners else 'default_entry',ram,owners,{'loader_prefixes':list(history),'observed_calls':[],'call_ram':ram,'call_owners':owners}
  if init:owners.pop(0x2e2,None);owners.pop(0x2e3,None)


def discover_base(folder,snapshot_provider=snapshots):
 data=(folder/'original.xex').read_bytes();stages=[];images=[];errors=[];seen=set();valid_count=0;call_count=0;scans=[]
 for snapshot in snapshot_provider(data):
  index,entry,kind,ram,owners=snapshot[:5];extra=snapshot[5] if len(snapshot)>5 else None
  valid=dict(cores(ram,owners));valid_count=max(valid_count,len(valid))
  scan={'segment_index':index,'entry':entry,'entry_kind':kind};calls=reachable_calls(extra['call_ram'] if extra else ram,extra['call_owners'] if extra else owners,entry,valid,scan)
  if extra:
   calls=sorted(set(extra['observed_calls']))
   if extra['loader_prefixes']:
    scan.update(prefix_stop_pc=extra['loader_prefixes'][-1]['stop_pc'],prefix_stop_reason=extra['loader_prefixes'][-1]['stop_reason'])
  scans.append(scan);call_count+=len(calls)
  for call,core,end in calls:
   key=(core,end,sha(ram),tuple(sorted(owners.items())))
   if key in seen:continue
   seen.add(key)
   try:
    stack_context=extra['loader_prefixes'][-1].get('observed_call_stack_contexts',{}).get(str(call)) if extra and extra['loader_prefixes'] else None
    stage,image,memory=prove(data,ram,owners,core,end,stack_context)
    # Collapse repeated load-time observations of exactly the same stream and output.
    duplicate=next((s for s in stages if s['sha256']==stage['sha256'] and s['spans']==stage['spans'] and s['literal_patches']==stage['literal_patches']),None)
    context={'segment_index':index,'entry':entry,'entry_kind':kind,'call':call,'decoder':core,'compressed_end':end,'argument_proof':('fully known loader prefix reached this call' if extra else 'static constant propagation; subroutine returns invalidate registers')}
    if extra:context['loader_prefix_proof']=extra['loader_prefixes'];context['scope']='Only this reached decoder invocation is modeled; its continuation and subsequent INIT state are not assumed.'
    if duplicate is not None:duplicate['loader_contexts'].append(context);continue
    stage.update(depacker_address=core,compressed_source=end,compressed_source_meaning='inclusive backward input end',loader_contexts=[context])
    seeds=[];pc=call+3
    if call>=0 and ram[call]==0x20:
     for _ in range(12):
      if pc not in owners or ram[pc] not in OPS:break
      op,mode=OPS[ram[pc]];n=SIZE[mode]
      if any(pc+k not in owners for k in range(n)):break
      if op in ('jmp','jsr') and mode=='abs':
       dest=word(ram,pc+1)
       if any(lo<=dest<hi for lo,hi in stage['spans']):seeds.append(dest)
      if op in ('jmp','rts','rti','brk'):break
      pc+=n
    stage['entry_seeds']=sorted(set(seeds));code,conflicts=trace(memory,stage['spans'],seeds)
    stage.update(code_bytes=sum(code.values()),instructions=len(code),overlapping_decodes_discarded=conflicts)
    stages.append(stage);images.append((image,memory,code))
   except (ValueError,IndexError) as exc:errors.append({'segment_index':index,'entry':entry,'core':core,'compressed_end':end,'call':call,'error':str(exc)})
 return {'folder':'games/'+folder.name,'title':folder.name,'decoder_family':FAMILY,'original_sha256':sha(data),'stages':stages,'errors':errors,'validated_cores_in_context':valid_count,'reachable_supported_calls':call_count,'loader_context_scans':scans,'limitations':['Automatic partial control-flow recovery only; no semantic annotation, standalone uncompressed executable or gameplay validation.','Unknown decoder variants, runtime relocation and caller arguments without provable register constants remain unresolved.','Static loader paths establish call candidates; arbitrary OS/game initialization is not executed. Each context scan is bounded to 24,000 abstract states and truncation is reported.']},images,data

def discover(folder):
 primary=discover_base(folder)
 if primary[0]['stages']:return primary
 recovered=discover_base(folder,relocated_snapshots)
 recovered[0]['discovery_mode']='known_value_loader_prefix_fallback'
 recovered[0]['primary_discovery_errors']=primary[0]['errors']
 return recovered

def source(stage,memory,code,title):
 lines=[f'; {title}: independently replayed {FAMILY} stage.','; Automatic address labels only. Undecoded bytes remain DTA.','; No complete code discovery, semantic annotation or standalone playability claimed.','    opt h-']
 for lo,hi in stage['spans']:
  lines.append(f'    org ${lo:04X}');a=lo
  while a<hi:
   if a in code:n=code[a];lines.append(f'L{a:04X}: {instruction(memory[a:a+n],a)}')
   else:
    n=1
    while n<16 and a+n<hi and a+n not in code:n+=1
    lines.append(dta(memory[a:a+n])+f' ; ${a:04X}')
   a+=n
 return '\n'.join(lines)+'\n'

def process(item):
 slug,publish,mads=item;folder=ROOT/'games'/slug;out=folder/'decompiled/recovered-stages';brief={'folder':'games/'+slug,'stages':[]}
 if (folder/'decompiled/reconstruction.json').exists():return dict(brief,status='curated_reconstruction_preserved')
 if out.exists() and any(out.iterdir()):return dict(brief,status='existing_recovered_stages_preserved')
 try:
  report,images,original=discover(folder)
  if not report['stages']:
   reason='No complete supported decoder in loaded context (different variant or runtime relocation)' if not report['validated_cores_in_context'] else ('No statically reachable caller with provable X/Y constants' if not report['reachable_supported_calls'] else 'All candidate streams failed guarded recovery')
   if report.get('discovery_mode')=='known_value_loader_prefix_fallback' and not report['reachable_supported_calls']:reason='No decoder invocation reached by a fully known loader prefix; see prefix stop diagnostics.'
   return dict(report,status='recognized_family_unresolved',unresolved_reason=reason)
  # Temporary files remain outside game folders until every source passes.
  with tempfile.TemporaryDirectory(prefix='backward-zaxxon-') as temp:
   temp=Path(temp)
   for number,(stage,(image,memory,code)) in enumerate(zip(report['stages'],images),1):
    name=f'stage-{number:02d}';stage.update(source=name+'.asm',binary=name+'.bin')
    (temp/(name+'.asm')).write_text(source(stage,memory,code,slug))
    proc=subprocess.run([mads,name+'.asm','-o:'+name+'.bin'],cwd=temp,capture_output=True,text=True,timeout=30)
    if proc.returncode:raise ValueError('MADS failed: '+proc.stdout[-1000:]+proc.stderr[-1000:])
    if (temp/(name+'.bin')).read_bytes()!=image:raise ValueError('MADS image differs from dual replay')
    stage['mads_byte_exact']=True
   rebuilt=reconstruct(report,original,lambda name:(temp/name).read_bytes())
   report.update(status='stages_recovered_and_mads_verified' if publish else 'guarded_probe_and_mads_verified',packed_xex_byte_exact=True)
   if publish:
    # Recheck protection markers and original input immediately before publication.
    if (folder/'decompiled/reconstruction.json').exists() or (out.exists() and any(out.iterdir())):raise ValueError('Project changed during verification; publication refused')
    if (folder/'original.xex').read_bytes()!=original:raise ValueError('Original changed during verification')
    (temp/'recovery.json').write_text(json.dumps(report,indent=2)+'\n')
    (temp/'rebuilt-packed.xex').write_bytes(rebuilt)
    (temp/'build.sh').write_text('#!/bin/sh\nset -eu\ncd "$(dirname "$0")"\n'+''.join('"${MADS:-mads}" '+s['source']+' -o:'+s['binary']+'\n' for s in report['stages'])+'python3 ../../../../tools/rebuild_stages.py .\n')
    (temp/'build.sh').chmod(0o755)
    out.mkdir(exist_ok=True)
    import shutil
    for path in temp.iterdir():shutil.copy2(path,out/path.name)
  return report
 except Exception as exc:return dict(brief,status='unresolved_error',error=str(exc))

def audit(folder):
 folder=Path(folder);folder=(folder if folder.is_absolute() else ROOT/folder).resolve();out=folder/'decompiled/recovered-stages';saved=json.loads((out/'recovery.json').read_text())
 if saved.get('decoder_family')!=FAMILY:raise ValueError('Wrong decoder family')
 current,images,data=discover_base(folder,relocated_snapshots if saved.get('discovery_mode')=='known_value_loader_prefix_fallback' else snapshots)
 if current['original_sha256']!=saved['original_sha256'] or len(current['stages'])!=len(saved['stages']):raise ValueError('Audit stage/input mismatch')
 for stage,(image,_,_),expected in zip(current['stages'],images,saved['stages']):
  for field in ('sha256','spans','literal_patches','loader_contexts','contextual_proof','depacker_steps'):
   if stage[field]!=expected[field]:raise ValueError('Audit differs: '+field)
  if (out/expected['binary']).read_bytes()!=image:raise ValueError('Assembled image differs from fresh audit')
 reconstruct(saved,data,lambda name:(out/name).read_bytes())
 return {'folder':str(folder),'status':'family_audit_passed','stages':len(saved['stages']),'bytes':sum(s['bytes'] for s in saved['stages'])}

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--inventory',type=Path);p.add_argument('--report',type=Path);p.add_argument('--publish',action='store_true');p.add_argument('--jobs',type=int,default=2);p.add_argument('--game');p.add_argument('--audit',type=Path);args=p.parse_args()
 if args.audit:print(json.dumps(audit(args.audit),indent=2));return
 if not args.inventory or not args.report:p.error('--inventory and --report required for corpus work')
 inventory=json.loads(args.inventory.read_text());slugs=[r['slug'] for r in inventory]
 if len(slugs)!=len(set(slugs)):p.error('Duplicate inventory slug')
 if args.game:slugs=[s for s in slugs if s==args.game]
 if any('/' in s or s in ('.','..') for s in slugs):p.error('Invalid slug')
 start=time.time();results=[];mads=os.environ.get('MADS','mads')
 with concurrent.futures.ProcessPoolExecutor(max_workers=args.jobs) as pool:
  futures={pool.submit(process,(s,args.publish,mads)):s for s in slugs}
  for future in concurrent.futures.as_completed(futures):
   result=future.result();results.append(result);print(f"{len(results)}/{len(slugs)} {result['folder']} {result['status']} {len(result['stages'])} stages",flush=True)
 results.sort(key=lambda r:r['folder'])
 summary={'games_examined':len(results),'games_with_verified_stages':sum(bool(r['stages']) for r in results),'stages':sum(len(r['stages']) for r in results),'recovered_bytes':sum(s['bytes'] for r in results for s in r['stages']),'decoded_code_bytes':sum(s['code_bytes'] for r in results for s in r['stages']),'elapsed_seconds':round(time.time()-start,1),'published':args.publish}
 args.report.parent.mkdir(parents=True,exist_ok=True);args.report.write_text(json.dumps({'decoder_family':FAMILY,'summary':summary,'games':results},indent=2)+'\n');print(json.dumps(summary,indent=2))
if __name__=='__main__':main()
