#!/usr/bin/env python3
"""Recover recognized Homesoft compressed stages, with conservative status reporting.

This does not claim semantic decompilation or playable rebuilt games. Each emitted
stage is real unpacked memory, reassembled by MADS and checked byte for byte.
Original XEX files and individually curated reconstructions are never changed.
"""
import argparse,concurrent.futures,hashlib,json,os,struct,subprocess,time
from pathlib import Path
from py65.devices.mpu6502 import MPU
from disasm import parse,instruction,dta
from opcodes import OPS,SIZE
from rebuild_stages import rebuild
ROOT=Path(__file__).resolve().parents[1]
SIGNATURE=bytes.fromhex('aa f0 56 a9 7f 90 01 e8 e8 85 0c b1 0c 99')

BASE = 0x8000
TEMPLATE_90 = bytes.fromhex(
    'aa f0 56 a9 7f 90 01 e8 e8 85 0c b1 0c 99 80 80 '
    'c8 d0 05 e6 0d ee 0f 80 ca d0 f0 06 0b d0 15 06 '
    '0a d0 07 38 20 4e 80 2a 85 0a a9 01 90 04 20 4e '
    '80 2a 85 0b 20 4e 80 a2 01 90 d2 4a d0 c7 20 4e '
    '80 b0 bd a8 20 4e 80 85 0d 8d 0f 80 90 e6 ad ff '
    'ff ee 4f 80 d0 03 ee 50 80 60'
)
TEMPLATE_103 = (TEMPLATE_90[:2] + b'\x63' + TEMPLATE_90[3:81] + bytes.fromhex(
    '48 a9 00 8d ff ff ee 4f 80 ee 55 80 d0 06 ee 50 80 ee 56 80 68 60'
))
# Operand byte offset -> displacement from the indirect backreference ZP pair.
ZP_OPERANDS = {10: 0, 12: 0, 20: 1, 28: -1, 32: -2, 41: -2, 51: -1, 72: 1}
# Low-byte operand offsets -> required target offset within assembled routine.
COMMON_ABSOLUTE = {22: 15, 37: 78, 47: 78, 53: 78, 63: 78, 69: 78, 74: 15}
ABSOLUTE_90 = {**COMMON_ABSOLUTE, 82: 79, 87: 80}
ABSOLUTE_103 = {**COMMON_ABSOLUTE, 88: 79, 91: 85, 96: 80, 99: 86}
MUTABLE_90 = (14, 15, 79, 80)
MUTABLE_103 = (*MUTABLE_90, 85, 86)


def word_zp(memory, address):
    """Match the 6502's zero-page pointer wrap for ($FF),Y."""
    address &= 0xff
    return memory[address] | memory[(address + 1) & 0xff] << 8


def is_core(memory, core, expected_base=None):
    if core < 0 or core + 14 > len(memory):
        return False
    variant = memory[core + 2]
    if variant == 0x56:
        template, absolute, mutable = TEMPLATE_90, ABSOLUTE_90, MUTABLE_90
    elif variant == 0x63:
        template, absolute, mutable = TEMPLATE_103, ABSOLUTE_103, MUTABLE_103
    else:
        return False
    actual = bytes(memory[core:core + len(template)])
    if len(actual) != len(template):
        return False
    base = ((actual[37] | actual[38] << 8) - 78) & 0xffff
    if expected_base is not None and base != expected_base:
        return False
    # The emulator's recognized code interval is contiguous, never wrapping.
    if base + len(template) > 0x10000:
        return False
    expected = bytearray(template)
    zp = actual[10]
    for offset, displacement in ZP_OPERANDS.items():
        expected[offset] = (zp + displacement) & 0xff
    for offset, target in absolute.items():
        address = base + target
        expected[offset:offset + 2] = address.to_bytes(2, 'little')
    for offset in mutable:
        expected[offset] = actual[offset]
    return actual == expected


def core_offsets(memory):
    data = bytes(memory)
    at = 0
    while True:
        at = data.find(b'\xaa\xf0', at)
        if at < 0:
            return
        if is_core(data, at):
            yield at
        at += 1



def word(memory,a):return memory[a]|memory[a+1]<<8

def unpack(ram,core,source,loaded=None):
    if not is_core(ram,core,expected_base=core):raise ValueError('Unknown depacker variant')
    core_size=103 if ram[core+2]==0x63 else 90
    zp=ram[core+10]
    cpu=MPU(memory=list(ram));cpu.memory[core+79]=source&255;cpu.memory[core+80]=source>>8
    if core_size==103:
        if bytes(ram[core+81:core+85])!=bytes.fromhex('48 a9 00 8d'):raise ValueError('Unknown input-clearing implementation')
        cpu.memory[core+85]=source&255;cpu.memory[core+86]=source>>8
    cpu.pc=core+35;cpu.sp=0xfd;cpu.memory[0x1fe]=0xfe;cpu.memory[0x1ff]=0x02
    writes=[];written=set();have_destination=False;literals=[];previous=None;last_read=None
    for steps in range(2_000_000):
        if cpu.pc==0x02ff:break
        if not core<=cpu.pc<core+core_size:raise ValueError('Depacker escaped recognized code')
        if cpu.pc==core+78:
            last_read=word(cpu.memory,core+79)
            if loaded is not None and last_read not in loaded:raise ValueError('Compressed stream reads unloaded memory')
            if cpu.memory[last_read]!=ram[last_read]:raise ValueError('Compressed stream requires memory changed by its own output')
        if cpu.pc==core+11:
            ref=(word_zp(cpu.memory,zp)+cpu.y)&65535
            if ref not in written:raise ValueError(f'Backreference requires prior loader RAM at ${ref:04X}')
        if cpu.pc==core+73:have_destination=True
        if cpu.pc==core+13:
            if not have_destination:raise ValueError('Stream depends on an initial destination/register value')
            dest=(word(cpu.memory,core+14)+cpu.y)&65535
            if dest<0x200 or core<=dest<core+core_size:raise ValueError('Output overlaps stack, zero page or active depacker')
            writes.append(dest);written.add(dest)
            if previous==core+57:literals.append((last_read,dest))
        previous=cpu.pc;cpu.step()
    else:raise ValueError('Depacker instruction limit reached')
    if not writes or len(set(writes))!=len(writes):raise ValueError('Empty or overlapping depacker output')
    spans=[]
    for a in sorted(writes):
        if spans and spans[-1][1]==a:spans[-1][1]=a+1
        else:spans.append([a,a+1])
    return bytes(cpu.memory),spans,literals,steps

def trace(ram,spans,seeds):
    valid=set(a for lo,hi in spans for a in range(lo,hi));code={};occupied={};todo=list(seeds);conflicts=set()
    while todo:
        a=todo.pop()
        while a in valid and a not in code and ram[a] in OPS:
            op,mode=OPS[ram[a]];n=SIZE[mode]
            if any(a+k not in valid for k in range(n)):break
            for k in range(n):
                if a+k in occupied:conflicts.update([a,occupied[a+k]])
                occupied[a+k]=a
            code[a]=n;v=int.from_bytes(ram[a+1:a+n],'little')
            if mode=='rel':todo.append((a+2+(v if v<128 else v-256))&65535)
            if op=='jsr':todo.append(v)
            if op=='jmp':
                if mode=='abs':todo.append(v)
                break
            if op in ('rts','rti','brk'):break
            a+=n
    for a in conflicts:code.pop(a,None)
    return code,len(conflicts)

def tail_table_sources(ram,loaded,call):
    """Recognize bounded XY pointer-table loops, including tables after the core.

    This discovers candidates, not executed stages. Every resulting stream still
    needs strict decoder-body validation and independent guarded replay.
    """
    if call<9 or call+18>65536:return []
    if bytes(ram[call-9:call-7])!=b'\x8a\x48':return []  # TXA/PHA saves table index
    if (ram[call-7],ram[call-4],ram[call-1],ram[call])!=(0xbd,0xbc,0xaa,0x20):return []
    table=word(ram,call-6)
    if word(ram,call-3)!=table+1:return []
    tail=bytes(ram[call+3:call+18])
    if tail[:5]==bytes.fromhex('68 aa e8 e8 e0') and tail[6:8]==bytes.fromhex('90 ec'):
        count=tail[5];end=call+11
    elif (tail[:5]==bytes.fromhex('68 d0 05 48 20') and
          tail[7:12]==bytes.fromhex('68 aa e8 e8 e0') and tail[13:15]==bytes.fromhex('90 e5')):
        # First item may call its freshly unpacked entry; both paths restore X.
        count=tail[12];end=call+18
    else:return []
    if not 0<count<=128 or count%2 or table+count>65536:return []
    if any(a not in loaded for a in range(call-9,end)):return []
    if any(a not in loaded for a in range(table,table+count)):return []
    return [word(ram,a) for a in range(table,table+count,2)]

def indexed_helper_source(ram,loaded,pc,accumulator,wrapper):
    """Resolve only the complete ASL/TAX/two-table-loads/TAX/JMP helper."""
    if accumulator is None or pc<0 or pc+12>65536:return None
    if any(a not in loaded for a in range(pc,pc+12)):return None
    body=ram[pc:pc+12]
    if bytes(body[:3])!=b'\x0a\xaa\xbd' or (body[5],body[8],body[9])!=(0xbc,0xaa,0x4c):return None
    table=word(body,3)
    if word(body,6)!=table+1 or word(body,10)!=wrapper:return None
    address=table+((accumulator<<1)&255)
    if address+1>65535 or address not in loaded or address+1 not in loaded:return None
    return word(ram,address)

def candidates(ram,loaded,core):
    """Collect every recognized call site, including tail calls and fixed entries."""
    found={}
    def add(source,call=None):
        if source in loaded and source!=0xffff:
            calls=found.setdefault(source,[])
            if call is not None and call not in calls:calls.append(call)
    source=word(ram,core+79)
    direct=[a for a in loaded if a+2<65536 and ram[a] in (0x20,0x4c) and word(ram,a+1)==core+35]
    if source in loaded and source!=0xffff:
        add(source)
        for call in direct:add(source,call)
    wrapper=core-(34 if ram[core+2]==0x63 else 28)
    first_pointer=core+(85 if ram[core+2]==0x63 else 79)
    valid_wrapper=(wrapper>=0 and ram[wrapper]==0x8e and ram[wrapper+3]==0x8c
        and word(ram,wrapper+1)==first_pointer and word(ram,wrapper+4)==first_pointer+1)
    short=core-9
    if not valid_wrapper and ram[core+2]==0x56 and short>=0:
        expected=b'\x8e'+(core+79).to_bytes(2,'little')+b'\x8c'+(core+80).to_bytes(2,'little')+b'\x4c'+(core+35).to_bytes(2,'little')
        if bytes(ram[short:core])==expected and all(a in loaded for a in range(short,core)):
            wrapper=short;valid_wrapper=True
    if not valid_wrapper:return list(found.items())
    if wrapper>=4 and (ram[wrapper-4],ram[wrapper-2]) in ((0xa2,0xa0),(0xa0,0xa2)):
        source=(ram[wrapper-3]|ram[wrapper-1]<<8) if ram[wrapper-4]==0xa2 else (ram[wrapper-1]|ram[wrapper-3]<<8)
        add(source)
        for a in loaded:
            if a+2<65536 and ram[a] in (0x20,0x4c) and word(ram,a+1)==wrapper-4:add(source,a)
    for a in sorted(loaded):
        if a<4 or a+2>=65536 or ram[a] not in (0x20,0x4c) or word(ram,a+1)!=wrapper:continue
        for source in tail_table_sources(ram,loaded,a):add(source,a)
        if a>=7 and ram[a-7]==0xbd and ram[a-4]==0xbc and ram[a-1]==0xaa:
            table=word(ram,a-6)
            if word(ram,a-3)==table+1 and 0<wrapper-table<=128 and (wrapper-table)%2==0:
                for at in range(table,wrapper,2):add(word(ram,at),a)
                continue
        prev=ram[a-4:a]
        if prev[0]==0xa2 and prev[2]==0xa0:add(prev[1]|prev[3]<<8,a)
        elif prev[0]==0xa0 and prev[2]==0xa2:add(prev[3]|prev[1]<<8,a)
    # Bounded constant propagation from documented OS INIT/RUN vectors. Memory
    # reads and unknown calls discard register values; both branch paths are
    # explored. These are candidates only: guarded replay remains mandatory.
    entries=[word(ram,v) for v in (0x2e0,0x2e2) if v in loaded and v+1 in loaded]
    todo=[(a,None,None,None) for a in entries];seen=set()
    while todo and len(seen)<2000:
        pc,a,x,y=todo.pop();state=(pc,a,x,y)
        if state in seen or pc not in loaded or not 0<=pc<65536:continue
        seen.add(state)
        if pc==wrapper:
            if x is not None and y is not None:add(x|(y<<8))
            continue
        helper_source=indexed_helper_source(ram,loaded,pc,a,wrapper)
        if helper_source is not None:
            add(helper_source,pc+9)
            continue
        if ram[pc] not in OPS:continue
        op,mode=OPS[ram[pc]];n=SIZE[mode]
        if any(pc+k not in loaded or pc+k>=65536 for k in range(n)):continue
        val=int.from_bytes(ram[pc+1:pc+n],'little');nextpc=pc+n
        if op in ('rts','rti','brk'):continue
        if op in ('jsr','jmp'):
            if mode=='abs':
                if val==wrapper and x is not None and y is not None:add(x|(y<<8),pc)
                else:todo.append((val,a,x,y))
            if op=='jsr':todo.append((nextpc,None,None,None))
            continue
        if mode=='rel':todo.append(((pc+2+(val if val<128 else val-256))&65535,a,x,y))
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
        todo.append((nextpc,a,x,y))
    return list(found.items())

def has_foreign_decoder(report):
    families=[report.get('decoder_family')]+[s.get('decoder_family') for s in report.get('stages',[])]
    return any(f not in (None,'homesoft-forward') for f in families)

def recover(rec):
    folder=ROOT/rec['folder'];out=folder/'decompiled/recovered-stages'
    result={'folder':rec['folder'],'title':rec['title'],'stages':[],'limitations':['Automatic stage recovery; no semantic annotation or gameplay validation.']}
    if (folder/'decompiled/reconstruction.json').exists():
        result['status']='curated_reconstruction_preserved';return result
    previous=out/'recovery.json'
    if previous.exists() and has_foreign_decoder(json.loads(previous.read_text())):
        result['status']='foreign_decoder_preserved';return result
    data=(folder/'original.xex').read_bytes();parts,warning=parse(data)
    if next(core_offsets(data),None) is None:result['status']='unrecognized_compression_or_uncompressed';return result
    ram=bytearray(65536);loaded=set();owners={};seen=set();errors=[]
    for part in parts:
        if part['kind']!='segment':continue
        a=part['address'];b=part['data'];ram[a:a+len(b)]=b;loaded.update(range(a,a+len(b)));owners.update({a+i:part['offset']+4+i for i in range(len(b))})
        # Analyze after each INIT stage and the final segment. Don't execute arbitrary OS/game code.
        if not (a<=0x2e3<a+len(b) or part is parts[-1]):continue
        for core in core_offsets(ram):
            if core<0x200:continue
            for source,calls in candidates(ram,loaded,core):
                key=(core,source,hashlib.sha256(ram[source:]).hexdigest())
                if key in seen:continue
                seen.add(key)
                try:
                    image,spans,literals,steps=unpack(ram,core,source,loaded)
                    seeds=[]
                    # Only code immediately following a proven depacker call supplies direct entry seeds.
                    for call in calls:
                        if ram[call]!=0x20:continue
                        pc=call+3
                        for _ in range(12):
                            if pc not in loaded or ram[pc] not in OPS:break
                            op,mode=OPS[ram[pc]];n=SIZE[mode]
                            if op in ('jmp','jsr') and mode=='abs':
                                dest=word(ram,pc+1)
                                if any(lo<=dest<hi for lo,hi in spans):seeds.append(dest)
                            if op in ('jmp','rts','rti','brk'):break
                            pc+=n
                    code,conflicts=trace(image,spans,seeds)
                    idx=len(result['stages'])+1;name=f'stage-{idx:02d}';out.mkdir(exist_ok=True)
                    expected=b''.join(image[lo:hi] for lo,hi in spans)
                    indexes={address:offset for offset,address in enumerate(a for lo,hi in spans for a in range(lo,hi))}
                    patches=[]
                    for packed_address,dest in literals:
                        if packed_address not in owners:raise ValueError('Literal read from unloaded input')
                        off=owners[packed_address]
                        if data[off]!=image[dest]:raise ValueError('Literal needs additional loader execution')
                        patches.append([off,indexes[dest]])
                    lines=[f'; {rec["title"]}: recovered compressed stage {idx}',
                        '; Real depacker output. Automatic control-flow labels only.',
                        '; No claim of complete code discovery, semantic annotation or standalone playability.',
                        '    opt h-']
                    for lo,hi in spans:
                        lines.append(f'    org ${lo:04X}');at=lo
                        while at<hi:
                            if at in code:
                                n=code[at];lines.append(f'L{at:04X}: {instruction(image[at:at+n],at)}');at+=n
                            else:
                                n=1
                                while n<16 and at+n<hi and at+n not in code:n+=1
                                lines.append(dta(image[at:at+n])+f' ; ${at:04X}');at+=n
                    (out/(name+'.asm')).write_text('\n'.join(lines)+'\n')
                    proc=subprocess.run([os.environ.get('MADS','mads'),name+'.asm','-o:'+name+'.bin'],cwd=out,capture_output=True,text=True,timeout=30)
                    if proc.returncode:raise ValueError(proc.stdout[-1200:]+proc.stderr[-1200:])
                    actual=(out/(name+'.bin')).read_bytes()
                    if actual!=expected:raise ValueError('MADS output differs from recovered stage')
                    result['stages'].append(dict(source=name+'.asm',binary=name+'.bin',depacker_address=core,compressed_source=source,spans=spans,bytes=len(expected),code_bytes=sum(code.values()),instructions=len(code),entry_seeds=sorted(set(seeds)),overlapping_decodes_discarded=conflicts,depacker_steps=steps,sha256=hashlib.sha256(actual).hexdigest(),mads_byte_exact=True,independent_compressed_stream_verified=True,literal_patches=patches))
                except Exception as e:errors.append(dict(core=core,source=source,error=str(e)))
    result['status']='stages_recovered_and_mads_verified' if result['stages'] else 'recognized_loader_needs_manual_recovery'
    if errors:result['errors']=errors
    if result['stages']:
        (out/'recovery.json').write_text(json.dumps(result,indent=2)+'\n')
        result['original_sha256']=hashlib.sha256(data).hexdigest()
        (out/'recovery.json').write_text(json.dumps(result,indent=2)+'\n')
        rebuild(out)
        result['packed_xex_byte_exact']=True
        (out/'build.sh').write_text('#!/bin/sh\nset -eu\ncd "$(dirname "$0")"\n'+''.join(f'mads {s["source"]} -o:{s["binary"]}\n' for s in result['stages'])+'python3 ../../../..//tools/rebuild_stages.py .\n')
    for stage in result['stages']:stage.pop('literal_patches',None)
    return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--jobs',type=int,default=4);p.add_argument('--game');p.add_argument('--retry-unrecovered',action='store_true');args=p.parse_args()
    games=json.loads((ROOT/'manifest.json').read_text())['games']
    if args.game:games=[r for r in games if r['folder']=='games/'+args.game]
    if args.retry_unrecovered:
        previous=json.loads((ROOT/'recovery-progress.json').read_text())
        pending={r['folder'] for r in previous['games'] if r['status']=='recognized_loader_needs_manual_recovery'}
        games=[r for r in games if r['folder'] in pending]
    results=[];start=time.time()
    with concurrent.futures.ProcessPoolExecutor(max_workers=args.jobs) as pool:
        for result in pool.map(recover,games):
            results.append(result)
            if len(results)%100==0:print(f'{len(results)}/{len(games)} examined; {sum(bool(r["stages"]) for r in results)} with recovered stages',flush=True)
    summary={'games_examined':len(results),'games_with_recovered_stages':sum(bool(r['stages']) for r in results),'stages':sum(len(r['stages']) for r in results),'recovered_bytes':sum(s['bytes'] for r in results for s in r['stages']),'decoded_code_bytes':sum(s['code_bytes'] for r in results for s in r['stages']),'elapsed_seconds':round(time.time()-start,1)}
    report=ROOT/('recovery-'+args.game+'.json' if args.game else ('recovery-retry.json' if args.retry_unrecovered else 'recovery-progress.json'));report.write_text(json.dumps({'summary':summary,'games':results},indent=2)+'\n');print(json.dumps(summary,indent=2))
if __name__=='__main__':main()
