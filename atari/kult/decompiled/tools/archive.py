#!/usr/bin/env python3
"""Conservative, file-offset-aware 6502 disassembly to byte-exact MADS source.

Preserves segment order, repeated writes, markers and non-XEX trailing bytes.
Traces the loaded bytes at INIT stages and at RUN; does not execute loaders.
"""
import json
from pathlib import Path
from opcodes import OPS, SIZE


def parse(data):
    parts=[];i=0;warning=None
    while i<len(data):
        start=i
        if data[i:i+2]==b'\xff\xff':
            parts.append(dict(kind='marker',offset=i,data=data[i:i+2]));i+=2;continue
        if i+4>len(data):
            warning=f'Trailing {len(data)-i} byte(s), preserved verbatim.';break
        lo=int.from_bytes(data[i:i+2],'little');hi=int.from_bytes(data[i+2:i+4],'little')
        if hi<lo or i+4+hi-lo+1>len(data):
            warning=f'Unparsed tail at file offset ${i:06X}, preserved verbatim.';break
        i+=4
        parts.append(dict(kind='segment',offset=start,address=lo,data=data[i:i+hi-lo+1]))
        i+=hi-lo+1
    if i<len(data):parts.append(dict(kind='tail',offset=i,data=data[i:]))
    return parts,warning


def analyse(parts):
    ram=bytearray(65536);owner=[None]*65536;code={};entries=[];stops=[];first=None
    def trace(entry,reason):
        entries.append(dict(address=entry,reason=reason))
        todo=[entry];visited=set()
        while todo:
            a=todo.pop()
            while 0<=a<65536 and a not in visited and owner[a] is not None:
                visited.add(a);origin=owner[a]
                if ram[a] not in OPS:
                    stops.append(dict(address=a,reason='undocumented opcode',file_offset=origin));break
                op,mode=OPS[ram[a]];n=SIZE[mode]
                if a+n>65536 or any(owner[a+k]!=origin+k for k in range(n)):break
                code[origin]=(a,n)
                v=int.from_bytes(ram[a+1:a+n],'little')
                if mode=='rel':todo.append((a+2+(v if v<128 else v-256))&65535)
                if op=='jsr':todo.append(v)
                if op=='jmp':
                    if mode=='abs':todo.append(v)
                    else:stops.append(dict(address=a,reason='indirect jump: target requires runtime analysis',file_offset=origin))
                    break
                if op in ('brk','rts','rti'):break
                a+=n
    for p in parts:
        if p['kind']!='segment':continue
        a=p['address'];b=p['data'];end=a+len(b)
        if first is None:first=a
        ram[a:end]=b;owner[a:end]=range(p['offset']+4,p['offset']+4+len(b))
        if a<=0x2e3<end and owner[0x2e2] is not None:
            trace(int.from_bytes(ram[0x2e2:0x2e4],'little'),'INITAD after segment')
            # DOS clears INITAD for each subsequent load stage.
            owner[0x2e2]=owner[0x2e3]=None
    if owner[0x2e0] is not None and owner[0x2e1] is not None:
        trace(int.from_bytes(ram[0x2e0:0x2e2],'little'),'RUNAD')
    elif first is not None:trace(first,'default first-segment entry (no explicit RUNAD)')
    # Overlapping instruction interpretations cannot both be emitted as mnemonics.
    occupied={};conflicts=set()
    for off,(a,n) in code.items():
        for k in range(n):
            if off+k in occupied:conflicts.update([off,occupied[off+k]])
            occupied[off+k]=off
    for off in conflicts:del code[off]
    return code,entries,stops,len(conflicts)


def dta(data):
    return '    dta '+','.join(f'${b:02X}' for b in data)


def instruction(data,a):
    op,mode=OPS[data[0]];v=int.from_bytes(data[1:],'little')
    if mode in ('imp','acc'):return op
    if mode=='rel':
        delta=2+(v if v<128 else v-256)
        return f'{op} *{delta:+d}'
    val=f'${v:02X}' if SIZE[mode]==2 else f'${v:04X}'
    if mode in ('abs','abx','aby') and v<256:op+='.w'
    arg={'imm':'#{}','zp':'{}','zpx':'{},x','zpy':'{},y','abs':'{}','abx':'{},x','aby':'{},y','izx':'({},x)','izy':'({}),y','ind':'({})'}[mode].format(val)
    return f'{op} {arg}'


def generate(original,out,title):
    data=Path(original).read_bytes();out=Path(out);out.mkdir(parents=True,exist_ok=True)
    parts,warning=parse(data);code,entries,stops,conflicts=analyse(parts)
    lines=[f'; {title}', '; Automatically traced 6502 source; unidentified bytes remain DTA.',
           '; Packed/relocated runtime code is NOT recovered by this static pass.',
           '; Labels identify file segments and CPU addresses, not inferred game roles.',
           '; Original segment headers and all bytes are retained for exact rebuilding.',
           '    opt h-','    org $0000','']
    segments=[]
    for idx,p in enumerate(parts):
        b=p['data'];offset=p['offset']
        if p['kind']!='segment':
            lines.append(f'; {p["kind"]} at file offset ${offset:06X}')
            # Keep raw tails within the assembler's 16-bit address space.
            lines.append('    org $0000')
            for i in range(0,len(b),16):lines.append(dta(b[i:i+16]))
            continue
        a=p['address'];end=a+len(b)-1
        lines.extend(['',f'; Segment {idx}: ${a:04X}-${end:04X}; file offset ${offset:06X}',
                      '    org $0000',f'    dta a(${a:04X}),a(${end:04X})',f'    org ${a:04X}'])
        i=0;count=0
        while i<len(b):
            off=offset+4+i;at=a+i
            if off in code:
                n=code[off][1]
                lines.append(f'S{idx:03d}_{at:04X}: {instruction(b[i:i+n],at):24s} ; {b[i:i+n].hex(" ").upper()}')
                i+=n;count+=n
            else:
                n=1
                while n<16 and i+n<len(b) and off+n not in code:n+=1
                lines.append(dta(b[i:i+n])+f' ; ${at:04X} unidentified data/code')
                i+=n
        segments.append(dict(index=idx,start=a,end=end,file_offset=offset,bytes=len(b),traced_code_bytes=count))
    (out/'game.asm').write_text('\n'.join(lines)+'\n')
    report=dict(source_bytes=len(data),traced_code_bytes=sum(s['traced_code_bytes'] for s in segments),segments=segments,entry_points=entries,unresolved_control_flow=stops,overlapping_instructions_preserved_as_data=conflicts,parse_warning=warning,analysis='static; loaders are not executed; game semantics are not annotated')
    (out/'analysis.json').write_text(json.dumps(report,indent=2)+'\n')
    return report

if __name__=='__main__':
    import argparse
    p=argparse.ArgumentParser();p.add_argument('original');p.add_argument('output');p.add_argument('--title',default='Atari executable');a=p.parse_args()
    generate(a.original,a.output,a.title)
