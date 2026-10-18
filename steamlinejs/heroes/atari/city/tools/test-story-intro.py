#!/usr/bin/env python3
"""Run actual XEX startup, story images and input transitions on both VBXE pages."""
import importlib.util
import sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('runtime',Path(__file__).with_name('test-runtime.py'))
r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)

def advance(m,count=20000):
    for tick in range(count):
        if tick%1000==0:m.mem.ram[0x14]=(m.mem.ram[0x14]+1)&255
        m.cpu.step()

def at(m,label):m.run_until(r.LABELS['story_intro.wait_action'+label])

for page in (0xd600,0xd700):
    m=r.Machine(page,story=True)
    assert m.get('front_bank')==0
    assert m.mem.ram[page+0x40]&1
    temporary_code=bytes(m.mem.ram[r.LABELS['story_intro']:r.LABELS['story_intro_end']])
    for picture in (1,2,3):
        expected=(r.ROOT/f'generated/intro-{picture}.bin').read_bytes()
        assert bytes(m.mem.vram[(picture-1)*65536:picture*65536])==expected
    # A held button at boot must leave the first picture visible.
    m.mem.ram[0xd010]=0;advance(m)
    assert m.get('front_bank')==0
    m.mem.ram[0xd010]=1;at(m,'.press')
    m.mem.ram[0xd010]=0;at(m,'.finish');advance(m)
    assert m.get('front_bank')==0,'Held Fire must not skip the second page'
    m.mem.ram[0xd010]=1;at(m,'')
    assert m.get('front_bank')==1
    xdl=int.from_bytes(m.mem.ram[page+0x41:page+0x44],'little')
    assert int.from_bytes(m.mem.vram[xdl+3:xdl+6],'little')==65536
    # Test Enter on D600 and Space on D700, including holding across the page.
    m.mem.ram[0xd209]=12 if page==0xd600 else 33
    m.mem.ram[0xd20f]=251;advance(m)
    assert m.get('front_bank')==1
    m.mem.ram[0xd20f]=255;at(m,'.press')
    m.mem.ram[0xd20f]=251;at(m,'.finish');advance(m)
    assert m.get('front_bank')==1
    m.mem.ram[0xd20f]=255;at(m,'')
    assert m.get('front_bank')==0
    expected=(r.ROOT/'generated/intro-3.bin').read_bytes()[:64000]
    assert bytes(m.mem.vram[:64000])==expected,'Third picture must be copied from temporary city cache'
    xdl=int.from_bytes(m.mem.ram[page+0x41:page+0x44],'little')
    assert int.from_bytes(m.mem.vram[xdl+3:xdl+6],'little')==0
    m.mem.ram[0xd20f]=251;advance(m)
    assert m.get('front_bank')==0
    m.mem.ram[0xd20f]=255;at(m,'.press')
    m.mem.ram[0xd20f]=251;at(m,'.finish');advance(m)
    m.mem.ram[0xd20f]=255;m.mem.ram[0x2fc]=12
    m.resume_after_story()
    assert m.get('upload_index')==127
    assert bytes(m.mem.vram[0x20000:0x7f000])==(r.ROOT/'generated/vram.bin').read_bytes(),'All temporary scenery memory must be reclaimed'
    start,end=r.LABELS['story_intro'],r.LABELS['story_intro_end']
    assert bytes(m.mem.ram[start:end])!=temporary_code,'Intro code must be overwritten'
    # The bytes now occupying the intro code are exactly the battle-table data
    # from the final XEX segment, not a reserved or merely cleared buffer.
    data=m.loader_data;i=0
    while i<len(data):
        seg=int.from_bytes(data[i:i+2],'little');i+=2
        if seg==65535:continue
        last=int.from_bytes(data[i:i+2],'little');i+=2;n=last-seg+1
        if seg==0x6000 and last==r.LABELS['runtime_data_end']-1:
            assert bytes(m.mem.ram[start:end])==data[i+start-seg:i+end-seg]
        i+=n
    assert m.get('gold',2)==50 and m.get('army_count')==2
    assert m.get('screen_mode')==0 and m.get('popup_open')==0
    m.idle(3);assert m.get('popup_open')==0
    m.release();m.fire();assert m.get('popup_open')==1
    print(f'PASS ${page:04X}: three exact story pictures, correct XDL switching, held/released Fire/Enter/Space, resumed XEX loading, all intro RAM/VRAM reclaimed and clean palace controls.')

if '--screens' in sys.argv:
    from PIL import Image
    out=Path(sys.argv[sys.argv.index('--screens')+1]);out.mkdir(parents=True,exist_ok=True)
    pages=[]
    for i in (1,2,3):
        im=Image.open(r.ROOT/f'generated/intro-{i}.png').convert('RGB')
        im.save(out/f'story-intro-{i}.png');pages.append(im.resize((960,600),Image.Resampling.NEAREST))
    pages[0].save(out/'story-intro-preview.gif',save_all=True,append_images=pages[1:],duration=4500,loop=0)
