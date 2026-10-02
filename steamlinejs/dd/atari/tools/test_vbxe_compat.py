#!/usr/bin/env python3
"""Real 6502 XEX loading with FX register/window variants and loader handoff.
The model checks addressing and data integrity, not electrical/raster timing.
"""
from test_runtime import Memory, Machine, LABELS, XEX, MPU, ROOT

def segments():
    p=0
    while p<len(XEX):
        start=int.from_bytes(XEX[p:p+2],'little');p+=2
        if start==65535: continue
        end=int.from_bytes(XEX[p:p+2],'little');p+=2
        size=end-start+1
        assert size>0 and p+size<=len(XEX)
        yield start,end,XEX[p:p+size]
        p+=size

def before_init(machine):
    m=machine.mem
    m.ram[0xcb:0xd1]=bytes(range(0x31,0x37))
    machine.cpu.a,machine.cpu.x,machine.cpu.y=0x35,0x67,0x89
    machine.loader_port=m.ram[0xd301]

def loader_handoff(machine):
    m=machine.mem
    assert m.memc == 0 and m.bank == 0 and m.memb == 0, 'INIT left a VBXE window mapped over loader RAM'
    assert m.ram[0xcb:0xd1]==bytes(range(0x31,0x37)), 'INIT damaged loader zero page'
    assert (machine.cpu.a,machine.cpu.x,machine.cpu.y)==(0x35,0x67,0x89)
    assert m.ram[0xd301]==machine.loader_port, 'INIT changed loader ROM/extended bank'
    before=bytes(m.vram)
    # A disk loader can use underlying RAM here between INIT calls.
    for a in range(0xb000,0xb040): m[a]=0xa5
    assert bytes(m.vram)==before, 'loader scratch writes corrupted uploaded graphics'
    # The loader is free to select a different window/bank before another INIT.
    # Neither window covers the upload routine at $9000 or staging at $8000.
    m.memc=0x4a; m.bank=0x9c; m.memb=0x9f


def probe(page,core,revision,decoy=False):
    m=Machine.__new__(Machine)
    m.mem=Memory(page,50,revision,core);m.cpu=MPU(memory=m.mem)
    if decoy:
        m.mem.ram[0xd640]=0x10;m.mem.ram[0xd641]=0x11
    for start,end,data in segments():
        if start<=LABELS['detect_vbxe']<=end:
            m.mem.ram[start:end+1]=data
    m.call('detect_vbxe')
    return m

if __name__=='__main__':
    report=[]
    # The only low-address records are the standard Atari OS RUNAD/INITAD vectors.
    for start,end,data in segments():
        assert start>=0x3000 or (start,end) in ((0x2e0,0x2e1),(0x2e2,0x2e3)), (start,end)
        assert not (start<=0x1ff and end>=0x100), 'XEX overwrites the CPU stack'
    assert LABELS['upload_bank']==0x9000
    report.append('XEX audit: no stack/zero-page payload or code below $3000; INIT uploader at $9000: PASS')
    for page in (0xd600,0xd700):
        for rev in (0x20,0x21,0x24,0x26,0x2f,0xa0,0xa1,0xa4,0xa6,0xaf):
            m=probe(page,0x10,rev,decoy=page==0xd700)
            assert m.get('detected_page')==page>>8 and m.cpu.p&1
            assert not m.mem.hardware_writes, 'detection must be read-only'
        for core,rev in ((0x11,0x26),(0x10,0x10),(0x10,0x30),(0x10,0xff),(0xff,0xff)):
            m=probe(page,core,rev)
            assert m.get('detected_page')==0 and not m.cpu.p&1
            assert not m.mem.hardware_writes
    report.append('Read-only detection: D600/D700, FX 1.2x, RAMBO bit masked; GTIA/old/unknown cores rejected; incompatible D600 skipped: PASS')
    for page in (0xd600,0xd700):
        for rev in (0x20,0x24,0x26,0xa6):
            rate=60 if rev in (0x24,0xa6) else 50
            memory=Memory(page,rate,rev)
            # A stale window over future runtime RAM, and BASIC initially enabled.
            memory.memc=0x4a;memory.bank=0xbd;memory.memb=0x9f
            memory.ram[0xd301]=0xed if rev&128 else 0xfd
            m=Machine(page,rate,memory=memory,before_init=before_init,after_init=loader_handoff)
            assert m.uploads==97 and m.get('detected_page')==page>>8
            assert m.mem.ram[0xd301]==255 and m.mem.memc==0xb8 and m.mem.bank==255
            assert m.get('mode')==0
            m.frame(fire=True)
            x=m.get('px')
            for _ in range(8): m.frame(stick=7)
            assert m.get('mode')==1 and m.get('px')>x
            # Runtime re-establishes MEMC as well as selecting the control bank.
            m.mem.memc=0xa1;m.mem.bank=0x31
            m.call('render')
            assert m.mem.memc==0xb8 and m.mem.bank==255
            message=f'Boot/upload/start/move/render at ${page:04X}, FX ${rev:02X}, {rate} Hz, BASIC/stale windows/loader scratch: PASS'
            print(message,flush=True);report.append(message)
    for core,rev in ((0x11,0x26),(0x10,0x10),(0x10,0x30)):
        m=Machine(0xd700,memory=Memory(0xd700,50,rev,core))
        assert m.mem.blits==0 and not m.mem.hardware_writes
        assert m.get('detected_page')==0
    report.append('Unsupported cores reach the native error screen without VRAM writes or blitter use: PASS')
    (ROOT/'generated/vbxe-compatibility-results.txt').write_text('\n'.join(report)+'\n')
    print('\n'.join(report[:2]+report[-1:]),flush=True)
