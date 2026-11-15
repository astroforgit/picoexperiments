#!/usr/bin/env python3
"""Guarded recovery of the 341-byte Fiji backward-table decoder family.

The complete decoder is matched, including self references, table references,
constant bytes and one of two observed ZP-restore loops. No arbitrary loader or
OS code executes. Direct INIT entry, exact constant display/clock prefixes and
bounded four-byte pointer-record loops establish supported call contexts.
Unsupported earlier INIT routines, relocation and banking remain unresolved.
Default operation is read-only; --publish requires an explicit inventory.

compressed_source is the inclusive packed-input END, not its start. The decoder
loads lower-bound/end words from its own four-byte pointer record, preserves a
packed tail in scratch RAM and generates its decoding tables. Input provenance
follows that tail copy. Prior output/scratch, unknown INIT continuations and XE
bank changes invalidate stale original-file memory. These are partial recovered
images, not a claim that an entire executable is unpacked or playable.

Run --audit games/SLUG for independent context replay and source-only assembly.
The generated build.sh assembles every stage before invoking the collection's
pure packed-byte verifier; generated .bin files are not required inputs.
"""
import argparse, collections, concurrent.futures, hashlib, json, os, shutil
import subprocess, tempfile, time
from pathlib import Path
from py65.devices.mpu6502 import MPU
from disasm import parse, instruction, dta
from recover_common import trace
from rebuild_stages import reconstruct

ROOT = Path(__file__).resolve().parents[1]
FAMILY = 'backward-fiji-v1'
PREFIX = bytes.fromhex('a20bb52048e004b005bd')
TEMPLATE = bytes.fromhex(
    'a20bb52048e004b005bd00059520ca10f1a000b122aa8524a52238e5248522a523e900'
    '8523b12299f606c8cad0f788981869f68dba05a90669008dbe05a203a000a522d002c6'
    '23c622e000f005b1229d2400ca10ece8e898290ff0148a4abe58062a2629ca10fa798c'
    '06aaa52979c00699c1068a998d06a204209605995906c8c034d0d2a00020e705a20b68'
    '9520ca10fa60a9008529e001903b4625d031488424a000b1220848a424a523c521d010'
    'a522c520d00aa9ff8522a9ff8523d008a522d002c623c622682890136a8525682a2629'
    'cad0c560cac627c62b88b12a912698d0f88ad0f088e8209e054ac890f8f02bc011b059'
    'be5806209605798c068528a52979c00648d006a428c0049002a003be5206209605795506'
    'a8a528e5269002c62749ff8526c001b0034ca305be5906209605798d069003e629186526'
    '852aa52979c1066527852b68aaa428909260020404302010')
SELF_WORDS = {52:182, 59:186, 122:146, 135:227, 233:154,
              249:146, 273:334, 276:146, 279:337, 299:159, 305:146}
TABLE_WORDS = {95:0, 104:52, 110:104, 113:105, 117:53, 125:1,
               246:0, 252:52, 259:104, 302:1, 308:53, 322:105}


def word(memory, a):
    return memory[a] | memory[a+1] << 8


def identify(memory, core):
    if not 0x200 <= core <= 65536-len(TEMPLATE):
        raise ValueError('Decoder address is outside supported contiguous RAM')
    actual = bytes(memory[core:core+len(TEMPLATE)])
    if not actual.startswith(PREFIX):
        raise ValueError('Decoder prefix mismatch')
    pointers, tail, tables = word(actual,10), word(actual,40), word(actual,95)
    expected = bytearray(TEMPLATE)
    for off, delta in SELF_WORDS.items():
        expected[off:off+2] = (core+delta).to_bytes(2,'little')
    for off, delta in TABLE_WORDS.items():
        target = tables+delta
        if target > 65535: raise ValueError('Table address wraps RAM')
        expected[off:off+2] = target.to_bytes(2,'little')
    expected[10:12] = pointers.to_bytes(2,'little')
    expected[40:42] = tail.to_bytes(2,'little')
    expected[50], expected[55] = tail & 255, tail >> 8
    restore = actual[0x89:0x91]
    if restore not in (bytes.fromhex('a20b689520ca10fa'), bytes.fromhex('a2f468952ce8d0fa')):
        raise ValueError('Unknown ZP restoration loop')
    expected[0x89:0x91] = restore
    if actual != expected:
        differing = [i for i,(a,b) in enumerate(zip(actual,expected)) if a!=b]
        raise ValueError('Complete decoder mismatch at offsets '+str(differing[:12]))
    if min(pointers,tables,tail)<0x200 or pointers+4 > 65536 or tables+158 > 65536 or tail+256 > 65536:
        raise ValueError('Decoder workspace wraps RAM')
    for lo,hi in ((core,core+341),(pointers,pointers+4),(tables,tables+158),(tail,tail+256)):
        if lo<0xd800 and hi>0xd000:raise ValueError('Decoder/workspace intersects hardware I/O')
    return {'pointers':pointers, 'tail':tail, 'tables':tables,
            'restore_loop':restore.hex(), 'decoder_sha256':hashlib.sha256(actual).hexdigest()}


def core_offsets(memory):
    raw=bytes(memory); at=0
    while True:
        at=raw.find(PREFIX,at)
        if at<0:return
        yield at
        at+=1


def context(ram, owners, entry, core, with_registers=False):
    """Recognize constant display setup and exact RTCLOK waits, never banking.

    The wait is an explicit OS clock event, not a guessed RAM value. Its loaded
    register becomes unknown. Decoder setup overwrites incoming A/X/Y/flags.
    Recorded writes are applied separately and lose provenance if changed.
    """
    pc=entry; visited=[];registers={'a':None,'x':None,'y':None};writes=[];waits=[]
    def result(call,ret):
        record={'entry':entry,'prefix':visited,'call':call,'return_pc':ret}
        if writes or waits:record.update(context_kind='display_clock_prefix_v1',display_writes=writes,clock_waits=waits)
        if with_registers:record['known_registers']=dict(registers)
        return record
    for _ in range(64):
        if pc==core:return result(None,None)
        if pc in visited or pc not in owners:break
        visited.append(pc);op=ram[pc]
        wait=bytes(ram[pc:pc+6])
        if wait in (bytes.fromhex('a514c514f0fc'),bytes.fromhex('a614e414f0fc')):
            if any(a not in owners for a in range(pc,pc+6)):break
            registers['a' if op==0xa5 else 'x']=None
            waits.append({'address':pc,'bytes':wait.hex(),'effect':'RTCLOK advances; loaded register and comparison flags are not assumed'})
            pc+=6;continue
        if op in (0x20,0x4c):
            if pc+1 not in owners or pc+2 not in owners:break
            target=word(ram,pc+1)
            if target==core:
                return result(pc,pc+3 if op==0x20 else None)
            if op==0x4c:pc=target;continue
            break
        if op in (0xa9,0xa2,0xa0):
            if pc+1 not in owners:break
            registers[{0xa9:'a',0xa2:'x',0xa0:'y'}[op]]=ram[pc+1]
            pc+=2
        elif op in (0x8d,0x8e,0x8c):
            if pc+1 not in owners or pc+2 not in owners:break
            address=word(ram,pc+1);value=registers[{0x8d:'a',0x8e:'x',0x8c:'y'}[op]]
            # PORTB and all other hardware registers remain unsupported. D400
            # zero is a deliberate DMA-disable side effect, never a RAM byte.
            if (address,value) not in ((0x022f,0),(0xd400,0),(0x02fc,255)):break
            writes.append({'instruction':pc,'address':address,'value':value,'hardware':address==0xd400})
            pc+=3
        elif op in (0xca,0xe8,0x88,0xc8):
            reg='x' if op in (0xca,0xe8) else 'y'
            registers[reg]=None if registers[reg] is None else (registers[reg]+(1 if op in (0xe8,0xc8) else -1))&255
            pc+=1
        elif op in (0xaa,0xa8,0x8a,0x98):
            dest,source={0xaa:('x','a'),0xa8:('y','a'),0x8a:('a','x'),0x98:('a','y')}[op]
            registers[dest]=registers[source];pc+=1
        elif op in (0xea,0xd8,0x78,0x58):pc+=1
        else:break
    raise ValueError('INIT does not reach decoder through a supported unmodified context')


def prepare_context(ram,owners,call,core):
    """Apply only proved prefix writes; no synthetic byte becomes file input."""
    image=bytearray(ram);provenance=dict(owners);layout=identify(ram,core)
    record=call.get('pointer_copy')
    if record:
        src,dst=record['source'],record['destination']
        if dst!=layout['pointers'] or not (dst+4<=core or dst>=core+341):
            raise ValueError('Pointer record copy overlaps decoder or targets wrong record')
        for i in range(4):
            if src+i not in owners or 0xd000<=src+i<0xd800:
                raise ValueError('Pointer table lacks original-file provenance')
        values=bytes(ram[src:src+4]);origins=[owners[src+i] for i in range(4)]
        for i in range(4):image[dst+i]=values[i];provenance[dst+i]=origins[i]
    lower,end=word(image,layout['pointers']),word(image,layout['pointers']+2)
    if call.get('clock_waits'):
        for a in range(0x12,0x15):
            if lower<=a<=end:raise ValueError('Clock wait overlaps compressed input')
            provenance.pop(a,None)
    for write in call.get('display_writes',[]):
        a,v=write['address'],write['value']
        if write['hardware']:continue
        if core<=a<core+341 or layout['pointers']<=a<layout['pointers']+4 or lower<=a<=end:
            raise ValueError('Display prefix writes decoder or compressed input')
        if image[a]!=v:provenance.pop(a,None)
        image[a]=v
    return image,provenance


def pointer_loop_contexts(ram,owners,entry,core):
    """Match a constant-X prefix and the complete finite record/call loop."""
    failures=[]
    for loop in range(entry,min(entry+64,65536-25)):
        if bytes(ram[loop:loop+3])!=bytes.fromhex('a000bd'):continue
        try:
            initialization=context(ram,owners,entry,loop,with_registers=True)
            if initialization['known_registers']['x']!=0:
                raise ValueError('Pointer loop does not have a proven initial X=0')
            if any(a not in owners for a in range(loop,loop+25)):
                raise ValueError('Pointer loop is not completely loaded and preserved')
            code=b'\xa2\x00'+bytes(ram[loop:loop+25])
            expected=bytearray.fromhex('a200a000bd0000990000e8c8c004d0f48a4820000068aae00890e7')
            if code[14] not in (0x90,0xd0):raise ValueError('Unknown record copy loop condition')
            count=code[24]
            if not 4<=count<=64 or count%4:raise ValueError('Pointer-record loop count is not bounded')
            table,pointers=word(code,5),word(code,8)
            expected[5:7]=code[5:7];expected[8:10]=code[8:10];expected[14]=code[14]
            expected[19:21]=core.to_bytes(2,'little');expected[24]=count
            if code!=expected:raise ValueError('Complete pointer-record loop mismatch')
            if pointers!=identify(ram,core)['pointers']:raise ValueError('Pointer-loop destination differs from decoder record')
            if pointers<loop+25 and pointers+4>entry:raise ValueError('Pointer copy overwrites its active caller loop')
            if table+count>65536 or any(a not in owners for a in range(table,table+count)):
                raise ValueError('Complete pointer table is not originally loaded')
            calls=[]
            for i in range(0,count,4):
                call={'entry':entry,'prefix':initialization['prefix'] if i==0 else [loop],
                      'call':loop+16,'return_pc':loop+19,'context_kind':'pointer_record_loop_v1',
                      'pointer_copy':{'source':table+i,'destination':pointers,'bytes':4,'record_index':i//4},
                      'loop_records':count//4,'after_loop':loop+25,'loop_extent':[loop,loop+25],
                      'complete_loop_bytes':code[2:].hex(),'initialization':initialization}
                if i==0:
                    for field in ('display_writes','clock_waits'):
                        if field in initialization:call[field]=initialization[field]
                calls.append(call)
            return calls
        except ValueError as exc:failures.append(str(exc))
    raise ValueError('Unsupported pointer-record caller: '+('; '.join(failures[:2]) or 'no exact loop'))


class GuardMemory(list):
    def __init__(self, ram, owners, raw, core, layout, poison):
        super().__init__(ram)
        self.defined=bytearray(65536)
        for a in owners:self.defined[a]=1
        self.origins=dict(owners);self.raw=raw;self.core=core;self.layout=layout
        self.pc=core;self.written=set();self.literals=[];self.pending=None
        self.input_offsets=set();self.table_copies=[];self.pointer_reads=[]
        self.tail_origin=None
        self.input_start=word(ram,layout['pointers'])
        self.input_end=word(ram,layout['pointers']+2)
        self.copied_tail=set()
        if self.input_start>self.input_end:raise ValueError('Compressed interval wraps or is reversed')
        for a in range(0x20,0x2c):list.__setitem__(self,a,poison)
        # The synthetic return is emulator scaffolding, never compressed input.
        for a,v in ((0x1fe,0xfe),(0x1ff,0x02)):
            list.__setitem__(self,a,v);self.defined[a]=1;self.origins.pop(a,None)

    def get(self,a):return list.__getitem__(self,a)
    def word(self,a):return self.get(a)|(self.get(a+1)<<8)

    def __getitem__(self,a):
        if isinstance(a,slice):return list.__getitem__(self,a)
        if 0xd000<=a<0xd800:raise ValueError('Decoder reads hardware I/O')
        if not self.defined[a] and not (self.pc==self.core+2 and 0x20<=a<0x2c):
            raise ValueError(f'Uninitialized RAM read ${a:04X} at ${self.pc:04X}')
        return self.get(a)

    def original(self,a):
        if 0xd000<=a<0xd800:raise ValueError('Compressed input reads hardware I/O')
        off=self.origins.get(a)
        if off is None or self.get(a)!=self.raw[off]:
            raise ValueError(f'Input ${a:04X} lacks unchanged original-file provenance')
        self.input_offsets.add(off)
        return off

    def before(self,cpu):
        self.pc=cpu.pc;rel=cpu.pc-self.core
        if not 0<=rel<335:raise ValueError('Decoder escaped fully recognized routine')
        if rel==9:
            a=self.layout['pointers']+cpu.x
            self.pointer_reads.append(self.original(a))
        elif rel in (0x13,0x25,0x4d,0xa3):
            a=(self.word(0x22)+cpu.y)&65535
            if self.core<=a<self.core+341:
                raise ValueError('Compressed input overlaps active decoder body')
            if not self.input_start<=a<=self.input_end and a not in self.copied_tail:
                raise ValueError(f'Compressed read ${a:04X} escapes declared input and copied tail')
            off=self.original(a)
            if rel==0x25:self.tail_origin=off
            if rel==0xa3:self.pending=('literal',off)
        elif rel==0xdc:
            a=(self.word(0x2a)+cpu.y)&65535
            if a not in self.written:
                raise ValueError(f'Backreference requires non-output RAM ${a:04X}')
            self.pending=('backreference',a)

    def __setitem__(self,a,v):
        if isinstance(a,slice):raise ValueError('Unexpected slice write')
        rel=self.pc-self.core
        if self.core<=a<self.core+341 and not (
                (rel==0x33 and a==self.core+0xb6) or (rel==0x3a and a==self.core+0xba)):
            raise ValueError('Decoder write overlaps active decoder body')
        if rel==0xde:
            if 0xd000<=a<0xd800:raise ValueError('Output overlaps hardware I/O')
            if a<0x200 or self.core<=a<self.core+341:
                raise ValueError('Output overlaps zero page, stack or active decoder')
            if self.layout['tables']<a<self.layout['tables']+158 or self.layout['tail']<=a<self.layout['tail']+256:
                raise ValueError('Output overlaps active table workspace')
            if a in self.written:raise ValueError('Repeated output destination')
            if self.pending is None:raise ValueError('Output has no recognized source')
            kind,source=self.pending
            if kind=='literal':
                if v!=self.raw[source]:raise ValueError('Literal value differs from original input')
                self.literals.append((source,a))
            elif source not in self.written or self.get(source)!=v:
                raise ValueError('Backreference is not already emitted output')
            self.written.add(a)
        elif 0x100<=a<=0x1ff:pass
        elif 0x20<=a<0x2c:pass
        elif rel in (0x33,0x3a) and a in (self.core+0xb6,self.core+0xba):pass
        elif rel==0x27 and self.layout['tail']<=a<self.layout['tail']+256:
            if self.tail_origin is None or v!=self.raw[self.tail_origin]:raise ValueError('Unproven tail copy')
            self.table_copies.append((self.tail_origin,a))
            self.copied_tail.add(a)
        elif rel in (0x70,0x74,0x7c) and self.layout['tables']<a<self.layout['tables']+158:pass
        else:raise ValueError(f'Unexpected decoder write ${a:04X} at ${self.pc:04X}')
        list.__setitem__(self,a,v);self.defined[a]=1;self.origins.pop(a,None)
        if rel==0x27:self.origins[a]=self.tail_origin


def unpack(ram, owners, raw, core, poison=0xa5):
    layout=identify(ram,core)
    if any(a not in owners for a in range(core,core+341)):
        raise ValueError('Decoder body is not fully loaded from original file')
    memory=GuardMemory(ram,owners,raw,core,layout,poison)
    cpu=MPU(memory=memory);cpu.pc=core;cpu.sp=0xfd;cpu.p=0x20
    for steps in range(4_000_000):
        if cpu.pc==0x02ff:break
        memory.before(cpu);cpu.step()
    else:raise ValueError('Decoder instruction budget exceeded')
    if not memory.written:raise ValueError('Decoder produced no output')
    spans=[]
    for a in sorted(memory.written):
        if spans and spans[-1][1]==a:spans[-1][1]=a+1
        else:spans.append([a,a+1])
    layout.update(input_file_offsets=sorted(memory.input_offsets),
                  pointer_file_offsets=sorted(set(memory.pointer_reads)),
                  copied_tail_bytes=len(memory.table_copies),decimal_mode=False,
                  unknown_zp_save_only=True)
    return bytes(list.__iter__(memory)),spans,memory.literals,steps,layout


def independent_replay(ram,owners,core,expected,spans,poison):
    """Plain MPU replay with a separate write recorder and varied initial state.

    This does not reuse GuardMemory or its input/backreference logic. Unloaded
    RAM, registers and flags are varied; every output store must match guarded
    replay, and every other write must stay in decoder scratch/stack/ZP.
    """
    layout=identify(ram,core)
    class Recorder(list):
        def __init__(self):
            super().__init__([poison]*65536);self.records=[];self.pc=None
        def __setitem__(self,a,v):
            list.__setitem__(self,a,v)
            if self.pc is not None:self.records.append((self.pc,a,v))
    memory=Recorder()
    for a in owners:list.__setitem__(memory,a,ram[a])
    initial_sp=0xfd if poison==0 else 0xbd
    list.__setitem__(memory,0x100+initial_sp+1,0xfe);list.__setitem__(memory,0x100+initial_sp+2,2)
    cpu=MPU(memory=memory);cpu.pc=core;cpu.sp=initial_sp
    cpu.a=poison;cpu.x=poison^0x59;cpu.y=poison^0xc3;cpu.p=(poison & 0xc7)|0x20
    for steps in range(4_000_000):
        if cpu.pc==0x02ff:break
        if not core<=cpu.pc<core+335:raise ValueError('Independent replay escaped decoder')
        memory.pc=cpu.pc;cpu.step()
    else:raise ValueError('Independent replay exceeded instruction budget')
    output={}
    for pc,a,v in memory.records:
        if core<=a<core+341 and not (
                (pc==core+0x33 and a==core+0xb6) or (pc==core+0x3a and a==core+0xba)):
            raise ValueError('Independent replay modifies decoder outside its two immediate patches')
        if pc==core+0xde:
            if a in output:raise ValueError('Independent replay repeats output')
            output[a]=v
        elif not (0x20<=a<0x2c or 0x100<=a<0x200 or a in (core+0xb6,core+0xba)
                  or layout['tables']<a<layout['tables']+158 or layout['tail']<=a<layout['tail']+256):
            raise ValueError('Independent replay writes outside permitted scratch')
    addresses={a for lo,hi in spans for a in range(lo,hi)}
    if set(output)!=addresses or any(output[a]!=expected[a] for a in addresses):
        raise ValueError('Independent replay differs from guarded decoder output')
    return steps


def source_text(title,image,spans,seeds):
    code,conflicts=trace(image,spans,seeds)
    lines=[f'; {title}: guarded Fiji backward-table recovery',
           '; Partial automatic control flow; no semantic or gameplay claim.',
           '    opt h-']
    for lo,hi in spans:
        lines.append(f'    org ${lo:04X}');at=lo
        while at<hi:
            if at in code:
                n=code[at];lines.append(f'L{at:04X}: '+instruction(image[at:at+n],at))
            else:
                n=1
                while n<16 and at+n<hi and at+n not in code:n+=1
                lines.append(dta(image[at:at+n])+f' ; ${at:04X}')
            at+=n
    return '\n'.join(lines)+'\n',code,conflicts


def recover_game(args):
    slug,publish=args[:2];audit_mode=len(args)>2 and args[2]
    game=ROOT/'games'/slug;out=game/'decompiled/recovered-stages'
    result={'folder':'games/'+slug,'decoder_family':FAMILY,'stages':[],'errors':[]}
    def protected():
        if not audit_mode and (game/'decompiled/reconstruction.json').exists():return 'curated_preserved'
        p=out/'recovery.json'
        if not audit_mode and p.exists() and json.loads(p.read_text()).get('stages'):return 'existing_recovery_preserved'
    status=protected()
    if status:result['status']=status;return result
    raw=(game/'original.xex').read_bytes();parts,warning=parse(raw)
    if warning:result.update(status='parse_warning',warning=warning);return result
    ram=bytearray(65536);owners={};unavailable=set();seen=set();identities=set();pending=[]
    metadata=json.loads((game/'metadata.json').read_text());title=metadata.get('title',slug)
    for part_index,part in enumerate(parts):
        if part['kind']!='segment':continue
        a=part['address'];b=part['data'];ram[a:a+len(b)]=b
        owners.update((a+i,part['offset']+4+i) for i in range(len(b)))
        unavailable.difference_update(range(a,a+len(b)))
        # Do not carry data from one XE bank into another. No bank contents are
        # guessed when a later PORTB write makes a different window visible.
        if a<=0xd301<a+len(b):unavailable.update(range(0x4000,0x8000))
        if not (a<=0x2e2<a+len(b) and a<=0x2e3<a+len(b)):continue
        entry=word(ram,0x2e2)
        available_owners={a:off for a,off in owners.items() if a not in unavailable}
        decoded=False;safe_return=False;changed=set()
        for core in core_offsets(ram):
            key=(core,entry,part_index)
            if key in seen:continue
            seen.add(key)
            try:
                layout=identify(ram,core)
                try:calls=[context(ram,available_owners,entry,core)]
                except ValueError:
                    calls=pointer_loop_contexts(ram,available_owners,entry,core)
                working_ram=ram;working_owners=available_owners
                for call in calls:
                    if call.get('context_kind')=='pointer_record_loop_v1' and any(a not in working_owners for a in range(*call['loop_extent'])):
                        raise ValueError('Previous output modified the pointer-record caller loop')
                    prepared_ram,prepared_owners=prepare_context(working_ram,working_owners,call,core)
                    image,spans,literals,steps,evidence=unpack(prepared_ram,prepared_owners,raw,core)
                    decoded=True
                    changed.update(w['address'] for w in call.get('display_writes',[]) if not w['hardware'])
                    if call.get('clock_waits'):changed.update(range(0x12,0x15))
                    changed.update(a for lo,hi in spans for a in range(lo,hi))
                    changed.update(range(layout['tables']+1,layout['tables']+158))
                    changed.update(range(layout['tail'],layout['tail']+evidence['copied_tail_bytes']))
                    ret=call.get('after_loop',call['return_pc'])
                    safe_return=ret is None or (ret in available_owners and ret not in changed and ram[ret]==0x60)
                    expected=b''.join(image[lo:hi] for lo,hi in spans)
                    digest=hashlib.sha256(expected).hexdigest();identity=(tuple(map(tuple,spans)),digest)
                    if identity in identities and not audit_mode:
                        working_ram=prepared_ram;working_owners={a:o for a,o in prepared_owners.items() if a not in changed}
                        continue
                    for poison in (0x00,0xff):independent_replay(prepared_ram,prepared_owners,core,image,spans,poison)
                    indexes={a:i for i,a in enumerate(a for lo,hi in spans for a in range(lo,hi))}
                    patches=[[off,indexes[dst]] for off,dst in literals]
                    seeds=[];pc=call['return_pc']
                    if pc is not None and pc+2 in owners and ram[pc] in (0x20,0x4c):
                        target=word(ram,pc+1)
                        if any(lo<=target<hi for lo,hi in spans):seeds.append(target)
                    assembly,code,conflicts=source_text(title,image,spans,seeds)
                    stage={'decoder_family':FAMILY,'depacker_address':core,
                           'compressed_source':word(prepared_ram,layout['pointers']+2),
                           'compressed_lower_bound':word(prepared_ram,layout['pointers']),
                           'compressed_source_semantics':'inclusive input end; four-byte pointer record contains lower bound then end',
                           'load_context_part':part_index,'loader_context':call,
                           'decoder_context':evidence,'spans':spans,'bytes':len(expected),
                           'sha256':digest,'code_bytes':sum(code.values()),'instructions':len(code),
                           'entry_seeds':seeds,'overlapping_decodes_discarded':conflicts,
                           'depacker_steps':steps,'literal_patches':patches,
                           'strict_decoder_body_verified':True,'independent_compressed_stream_verified':True}
                    stage['independent_varied_ram_register_replay_verified']=True
                    pending.append((stage,assembly,expected));identities.add(identity)
                    working_ram=prepared_ram;working_owners={a:o for a,o in prepared_owners.items() if a not in changed}
            except ValueError as exc:
                safe_return=False
                result['errors'].append({'core':core,'load_context_part':part_index,'entry':entry,'error':str(exc)})
        # A later stage may use only original bytes known to survive earlier
        # execution, or freshly loaded bytes. Decoder output/scratch is never
        # silently replaced with old file bytes. Unknown INIT continuations
        # conservatively invalidate all old RAM; full loader emulation is out
        # of scope. Decoder's two immediate patches need no invalidation: its
        # own matched setup overwrites both before either operand is consumed.
        if decoded and safe_return:unavailable.update(changed)
        else:unavailable.update(owners)
    if not pending:result['status']='unresolved';return result
    with tempfile.TemporaryDirectory(prefix='atari-fiji-') as temp:
        temp=Path(temp);images={};prepared=[]
        for idx,(stage,assembly,expected) in enumerate(pending,1):
            name=f'backward-fiji-{idx:02d}';stage.update(source=name+'.asm',binary=name+'.bin')
            (temp/stage['source']).write_text(assembly)
            proc=subprocess.run([os.environ.get('MADS','mads'),stage['source'],'-o:'+stage['binary']],cwd=temp,capture_output=True,text=True,timeout=30)
            if proc.returncode or (temp/stage['binary']).read_bytes()!=expected:
                raise ValueError('MADS mismatch: '+proc.stdout[-1000:]+proc.stderr[-1000:])
            stage['mads_byte_exact']=True;images[stage['binary']]=expected;prepared.append(stage)
        report={'folder':'games/'+slug,'title':title,'decoder_family':FAMILY,
                'original_sha256':hashlib.sha256(raw).hexdigest(),'stages':prepared,
                'status':'stages_recovered_and_mads_verified','errors':result['errors'],
                'limitations':['Partial automatic control flow; no semantic annotation or gameplay validation.',
                               'Only proven original-file INIT contexts are decoded; arbitrary loader execution and bank switching are unsupported.']}
        packed=reconstruct(report,raw,lambda name:images[name]);report['packed_xex_byte_exact']=True
        if publish:
            status=protected()
            if status:result['status']=status;return result
            # Never replace an unmanifested source left by earlier work.
            for s in prepared:
                if any((out/s[k]).exists() for k in ('source','binary')):
                    raise ValueError('Publication filename already exists')
            out.mkdir(exist_ok=True)
            for s in prepared:
                for field in ('source','binary'):shutil.copy2(temp/s[field],out/s[field])
            build='#!/bin/sh\nset -eu\ncd "$(dirname "$0")"\n'+''.join('"${MADS:-mads}" '+s['source']+' -o:'+s['binary']+'\n' for s in prepared)+'python3 ../../../../tools/rebuild_stages.py .\n'
            (out/'build.sh').write_text(build);(out/'build.sh').chmod(0o755)
            (out/'rebuilt-packed.xex').write_bytes(packed)
            # Manifest is committed last, after sources, binaries and recipe.
            with tempfile.NamedTemporaryFile(dir=out,prefix='.fiji-recovery-',mode='w',delete=False) as f:
                json.dump(report,f,indent=2);f.write('\n');replacement=Path(f.name)
            os.replace(replacement,out/'recovery.json')
        result['stages']=[dict(s) if audit_mode else {k:v for k,v in s.items() if k not in ('literal_patches','decoder_context')} for s in prepared]
        result['status']='published' if publish else 'probe_mads_and_packed_verified'
    return result


def audit(folder):
    """Read-only, independent full-context replay plus source-only MADS audit."""
    game=Path(folder)
    if not game.is_absolute():game=ROOT/game
    report=json.loads((game/'decompiled/recovered-stages/recovery.json').read_text())
    if report.get('decoder_family')!=FAMILY:raise ValueError('Not a Fiji-family report')
    original=(game/'original.xex').read_bytes()
    if hashlib.sha256(original).hexdigest()!=report['original_sha256']:raise ValueError('Original hash mismatch')
    replay=recover_game((game.name,False,True))
    expected={(s['load_context_part'],s['depacker_address'],s['sha256']):s for s in replay['stages']}
    images={};out=game/'decompiled/recovered-stages'
    with tempfile.TemporaryDirectory(prefix='atari-fiji-audit-') as tmp:
        for stage in report['stages']:
            key=(stage['load_context_part'],stage['depacker_address'],stage['sha256'])
            actual=expected.get(key)
            if actual is None:raise ValueError('Stage cannot be independently replayed')
            for field in ('decoder_family','compressed_source','compressed_lower_bound','spans','bytes',
                          'literal_patches','loader_context','decoder_context','entry_seeds',
                          'independent_varied_ram_register_replay_verified'):
                if stage[field]!=actual[field]:raise ValueError('Replay metadata mismatch: '+field)
            if 'runtime_matching_entries' in stage:
                if stage.get('static_code_bytes')!=actual['code_bytes']:
                    raise ValueError('Original static-code evidence changed')
            elif (stage['code_bytes'],stage['instructions'])!=(actual['code_bytes'],actual['instructions']):
                raise ValueError('Static-code metadata mismatch')
            binary=Path(tmp)/stage['binary']
            p=subprocess.run([os.environ.get('MADS','mads'),str(out/stage['source']),'-o:'+str(binary)],capture_output=True,text=True,timeout=30)
            if p.returncode:raise ValueError('Published source does not assemble: '+p.stdout[-1000:])
            images[stage['binary']]=binary.read_bytes()
        reconstruct(report,original,lambda name:images[name])
    return {'folder':str(game),'decoder_family':FAMILY,'stages':len(report['stages']),
            'status':'full_context_replay_source_mads_and_packed_verified'}


def process_record(args):
    try:return recover_game(args)
    except Exception as exc:
        return {'folder':'games/'+args[0],'decoder_family':FAMILY,'stages':[],
                'status':'preparation_failed','errors':[{'error':str(exc)}]}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inventory');parser.add_argument('--exclude-inventory')
    parser.add_argument('--audit',help='Replay and assemble an existing family report, read-only')
    parser.add_argument('--game');parser.add_argument('--publish',action='store_true')
    parser.add_argument('--jobs',type=int,default=2);parser.add_argument('--report')
    args=parser.parse_args()
    if args.audit:print(json.dumps(audit(args.audit),indent=2));return
    if not args.inventory or not args.report:parser.error('--inventory and --report are required for a probe/publication pass')
    inventory=json.loads(Path(args.inventory).read_text())
    slugs={r['slug'] for r in inventory}
    if args.exclude_inventory:slugs-={r['slug'] for r in json.loads(Path(args.exclude_inventory).read_text())}
    if args.game:slugs &= {args.game}
    start=time.time();results=[]
    with concurrent.futures.ProcessPoolExecutor(max_workers=args.jobs) as pool:
        for result in pool.map(process_record,[(s,args.publish) for s in sorted(slugs)]):
            results.append(result)
            print(result['folder'],result['status'],len(result['stages']),flush=True)
    summary={'examined':len(results),'projects_with_stages':sum(bool(r['stages']) for r in results),
             'stages':sum(len(r['stages']) for r in results),
             'bytes':sum(s['bytes'] for r in results for s in r['stages']),
             'statuses':dict(collections.Counter(r['status'] for r in results)),
             'seconds':round(time.time()-start,1),'published':args.publish}
    Path(args.report).write_text(json.dumps({'summary':summary,'games':results},indent=2)+'\n')
    print(json.dumps(summary,indent=2))


if __name__=='__main__':main()
