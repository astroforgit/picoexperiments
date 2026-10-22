#!/usr/bin/env python3
"""Boot the single-disk ATR: the real boot sectors must stream the game exactly."""
import importlib.util,json
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
layout=json.loads((r.ROOT/'generated/story-layout.json').read_text())
disk=(r.ROOT/'city-vbxe.atr').read_bytes()
story=(r.ROOT/'generated/heroes-story.atr').read_bytes()
pictures=slice(16+256,16+384+(layout['xexSector']-4)*256)
assert disk[pictures]==story[pictures],'Story signature or pictures moved'

def reference(page):
    """The XEX applied directly, with the same INIT calls, stopped at RUNAD."""
    m=r.Machine.__new__(r.Machine);m.mem=r.Memory(page);m.cpu=r.MPU(memory=m.mem)
    data=(r.ROOT/'city-vbxe.xex').read_bytes();i=0;inits=[]
    while i<len(data):
        start=int.from_bytes(data[i:i+2],'little');i+=2
        if start==65535:continue
        end=int.from_bytes(data[i:i+2],'little');i+=2
        for a,v in enumerate(data[i:i+end-start+1],start):m.mem[a]=v
        i+=end-start+1
        if start<=0x2e2<=end:
            entry=int.from_bytes(m.mem.ram[0x2e2:0x2e4],'little');inits.append(entry)
            if entry==r.LABELS['story_intro'] and page:m.put('upload_index',16)
            else:m.call(entry)
    return m,inits

def boot(page,entries):
    m=r.Machine.__new__(r.Machine);m.mem=r.Memory(page);m.cpu=r.MPU(memory=m.mem)
    m.mem.story_disk=disk
    m.mem.ram[0x700:0x800]=disk[16:16+256]  # what the OS boot reads from sectors 1-2
    m.mem.ram[0xd301]=0xfd                   # BASIC enabled at power-on
    m.cpu.sp=255;m.cpu.stPushWord(0x05ff);m.cpu.pc=0x706;inits=[]
    for tick in range(60000000):
        pc=m.cpu.pc
        if pc==r.LABELS['main']:return m,inits
        if pc==0xe459:m.sio_read();continue
        if pc==r.LABELS['story_intro'] and page:
            # Same skip of the blocking picture intro as the gameplay fixtures.
            inits.append(pc);m.put('upload_index',16);m.cpu.pc=m.cpu.stPopWord()+1;continue
        if pc in entries:inits.append(pc)
        m.cpu.step()
    raise AssertionError(f'Boot stuck at {m.cpu.pc:04x}')

for page in (0xd600,0xd700,None):
    want,want_inits=reference(page)
    got,got_inits=boot(page,set(want_inits))
    assert got_inits==want_inits,'INIT sequence differs'
    assert got.mem.ram[0xd301]&2,'BASIC left enabled'
    flag=r.LABELS['savegame.boot_disk'];assert got.mem.ram[flag]==1 and want.mem.ram[flag]==0,'Boot loader must flag the boot disk'
    want.mem.ram[flag]=1
    assert got.mem.ram[0x2000:0xc000]==want.mem.ram[0x2000:0xc000],'Loaded RAM differs'
    assert got.mem.vram==want.mem.vram,'Uploaded VRAM differs'
    reads=got.mem.story_reads
    assert reads==[(s,256) for s in range(layout['xexSector'],layout['xexSector']+len(reads))]
    got.cpu.sp=255;got.mem.story_reads=[]
    if page:
        got.put('render_bank',got.get('back_bank'));got.cpu.a=3;got.call('story.load')
        assert got.cpu.p&1,'Game-over picture not found on the single disk'
        assert got.mem.story_reads[0]==(3,128)
    print(f'PASS {"$%04X"%page if page else "no VBXE"}: {len(reads)} sectors booted, {len(got_inits)} INITs, RAM/VRAM identical to the XEX, pictures load from the same disk, save/load enabled.')
