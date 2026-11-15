"""Conservative recursive 6502 disassembly, following the local Zorro approach.

No linear decoding of unknown data. Conflicting instruction interpretations
remain DTA. Symbol names describe only established roles; Lxxxx stays neutral.
"""
from opcodes import OPS,SIZE
from archive import instruction,dta
HW={0x200:'VDSLST',0x222:'VVBLKI',0x224:'VVBLKD',0x22f:'SDMCTL',0x230:'SDLSTL',0x2e0:'RUNAD',0x2e2:'INITAD',0xD010:'TRIG0',0xD01F:'CONSOL',0xD017:'COLPF1',0xD018:'COLPF2',0xD01A:'COLBK',0xD300:'PORTA',0xD301:'PORTB',0xD400:'DMACTL',0xD402:'DLISTL',0xD403:'DLISTH',0xD404:'HSCROL',0xD405:'VSCROL',0xD407:'PMBASE',0xD409:'CHBASE',0xD40A:'WSYNC',0xD40B:'VCOUNT',0xD40E:'NMIEN',0xD40F:'NMIST',0xD20E:'IRQEN',0xD20F:'SKCTL',0xE459:'SIOV',0xE456:'CIOV',0xFFFA:'NMI_VECTOR',0xFFFB:'NMI_VECTOR_HI'}

def trace(ram,spans,seeds):
    valid={a for lo,hi in spans for a in range(lo,hi)};code={};occupied={};conflicts=set();todo=list(seeds);stops=[]
    while todo:
        a=todo.pop()
        while a in valid and a not in code:
            if ram[a] not in OPS:
                stops.append({'address':a,'reason':'undocumented opcode'});break
            op,mode=OPS[ram[a]];n=SIZE[mode]
            if any(a+k not in valid for k in range(n)):break
            for k in range(n):
                if a+k in occupied:conflicts.update([a,occupied[a+k]])
                occupied[a+k]=a
            code[a]=n;v=int.from_bytes(ram[a+1:a+n],'little')
            if mode=='rel':todo.append((a+2+(v if v<128 else v-256))&65535)
            if op=='jsr':
                todo.append(v)
                if v==0xffff:stops.append({'address':a,'reason':'self-modified call placeholder; targets require separate evidence'})
            if op=='jmp':
                if mode=='abs':todo.append(v)
                else:stops.append({'address':a,'reason':'indirect jump; runtime target not inferred'})
                break
            if op in ('brk','rts','rti'):break
            a+=n
    for a in conflicts:code.pop(a,None)
    return code,stops

def emit(path,ram,spans,seeds,names=None,comments=None,title='Recovered program'):
    names=names or {};comments=comments or {};code,stops=trace(ram,spans,seeds)
    labels={a:names.get(a,f'L{a:04X}') for a in code}
    labels.update({a:n for a,n in names.items() if any(lo<=a<hi for lo,hi in spans)})
    # An address inside an instruction must not split that instruction.
    for a,n in code.items():
        for k in range(1,n):labels.pop(a+k,None)
    lines=[f'; {title}','; Recovered bytes; semantic annotation is partial. Unknown bytes remain DTA.', '    opt h-']
    used_hw={}
    body=[]
    for lo,hi in spans:
        body+=['',f'; ${lo:04X}-${hi-1:04X}',f'    org ${lo:04X}'];a=lo
        while a<hi:
            if a in comments:body+=['; '+s for s in comments[a].splitlines()]
            if a in labels:body.append(labels[a]+':')
            if a in code:
                n=code[a];op,mode=OPS[ram[a]];v=int.from_bytes(ram[a+1:a+n],'little')
                text=instruction(ram[a:a+n],a)
                if mode=='rel':
                    t=(a+2+(v if v<128 else v-256))&65535
                    if t in labels:text=op+' '+labels[t]
                elif mode in ('abs','abx','aby','ind','zp','zpx','zpy','izx','izy'):
                    sym=labels.get(v) or HW.get(v)
                    if sym:
                        if v in HW and v not in labels:used_hw[v]=sym
                        old=f'${v:04X}' if n==3 else f'${v:02X}'
                        text=text.replace(old,sym)
                body.append(f'    {text:30s} ; ${a:04X}: {ram[a:a+n].hex(" ").upper()}');a+=n
            else:
                n=1
                while n<16 and a+n<hi and a+n not in code and a+n not in labels and a+n not in comments:n+=1
                body.append(dta(ram[a:a+n])+f' ; ${a:04X}');a+=n
    lines += [f'{name} = ${a:04X}' for a,name in sorted(used_hw.items())]
    path.write_text('\n'.join(lines+body)+'\n')
    return {'bytes':sum(hi-lo for lo,hi in spans),'decoded_instruction_bytes':sum(code.values()),'instructions':len(code),'seeds':seeds,'unresolved_control_flow':stops,'spans':spans}
