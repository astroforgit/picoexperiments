"""Execute the supplied loaders, with bounded CPU loops and explicit I/O hooks.

py65 models the CPU, not ANTIC/POKEY or OS ROM. Kult's decoder is RAM-only;
CETAS's file-byte reader is replaced by a bounded read of an extracted DOS file.
"""
from pathlib import Path
from py65.devices.mpu6502 import MPU
from archive import parse

def word(m,a): return m[a] | m[a+1]<<8

def load(data):
    m=bytearray(65536); spans=[]
    parts,warning=parse(data)
    if warning: raise ValueError(warning)
    for p in parts:
        if p['kind']=='segment':
            a=p['address'];b=p['data'];m[a:a+len(b)]=b;spans.append((a,a+len(b)))
    return m,spans

def kult(data):
    ram,_=load(data);cpu=MPU(memory=list(ram));cpu.pc=0xbb02
    blocks=[];current=None;written={};calls=[]
    # Original RLE loader emits one byte through this entry point.
    assert bytes(ram[0xbbcf:0xbbd6])==bytes.fromhex('a0 00 8d 1a d0 91 82')
    for steps in range(3_000_000):
        if cpu.pc==0xbb5b:
            a=word(cpu.memory,0x82);size=word(cpu.memory,0xbb78)
            if size:
                current={'start':a,'size':size,'data':bytearray()};blocks.append(current)
        if cpu.pc==0xbbcf:
            a=word(cpu.memory,0x82)
            if current is None or a!=current['start']+len(current['data']):raise ValueError('noncontiguous block')
            current['data'].append(cpu.a);written[a]=cpu.a
        if cpu.pc==0xbb75:
            target=word(cpu.memory,0x82);calls.append(target)
            if target!=0x7fee:raise ValueError('unexpected INIT call')
            break
        if not 0xbb02<=cpu.pc<=0xbbdc:raise ValueError(f'loader escaped: {cpu.pc:04x}')
        cpu.step()
    else:raise ValueError('Kult decoder instruction limit')
    for b in blocks:
        if len(b['data'])!=b['size']:raise ValueError('incomplete block')
    # Entry stub survives in the original compressed buffer, outside output blocks.
    for a in range(0x7fee,0x8000):written[a]=cpu.memory[a]
    spans=[]
    for a in sorted(written):
        if 0xd000<=a<0xd800 or a in (0xbb00,0xbb01):continue
        if spans and spans[-1][1]==a:spans[-1][1]=a+1
        else:spans.append([a,a+1])
    return bytes(cpu.memory),spans,blocks,steps+1

def cetas_resource(loader,data):
    ram,_=load(loader);cpu=MPU(memory=list(ram));start=int.from_bytes(data[:2],'little')
    if data[2:5]!=bytes.fromhex('00 00 02'):raise ValueError('unexpected resource header')
    cpu.memory[0x12a4]=start&255;cpu.memory[0x12a5]=start>>8
    cpu.pc=0x130a;cpu.a=0;pos=4;writes=[];values=[]
    for steps in range(1_000_000):
        if cpu.pc==0x105c:break
        if cpu.pc==0x11ca:
            if pos>=len(data):raise ValueError('compressed input exhausted')
            cpu.a=data[pos];pos+=1;cpu.FlagsNZ(cpu.a)
            cpu.pc=(cpu.stPopWord()+1)&65535
            continue
        if cpu.pc==0x12a0: # Copy from prior decoded output only.
            src=(word(cpu.memory,0x12a1)+cpu.y)&65535
            if not start<=src<start+len(writes):raise ValueError('invalid backreference')
        if cpu.pc==0x12a3:
            dest=word(cpu.memory,0x12a4)
            if dest!=start+len(writes):raise ValueError('noncontiguous output')
            writes.append(dest);values.append(cpu.a)
        if not 0x1000<=cpu.pc<0x1400:raise ValueError('decoder escaped')
        cpu.step()
    else:raise ValueError('CETAS decoder instruction limit')
    if pos!=len(data):raise ValueError('unused compressed bytes')
    return start,bytes(values),steps+1
