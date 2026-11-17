#!/usr/bin/env python3
"""Build a native Kult space variant, retaining the original RLE loader."""
import hashlib, json, os, random, struct, subprocess, sys
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'editor'))
from assets import project,rle,word
from recover import kult

def packed(im):
    return bytes(sum(im.getpixel((x+i,y))<<(6-i*2) for i in range(4)) for y in range(im.height) for x in range(0,im.width,4))

def ship(frame):
    # Native ANTIC F is 40 hires pixels wide, not the web's 20 colour pairs.
    im=Image.new('1',(40,16));d=ImageDraw.Draw(im)
    d.polygon([(4,1),(15,3),(23,5),(36,0),(32,5),(24,8),(10,6)],fill=0,outline=1)
    d.polygon([(4,14),(15,12),(23,10),(36,15),(32,10),(24,7),(10,9)],fill=0,outline=1)
    d.polygon([(9,6),(17,4),(26,6),(38,8),(26,10),(17,11),(9,9),(12,8)],fill=1)
    d.line([(14,7),(25,7),(32,8)],fill=0)
    d.line([(14,9),(23,9)],fill=0)
    d.line([(1+frame%3,6),(8,6)],fill=1)
    d.line([(2+frame%2,9),(8,9)],fill=1)
    return im

def ship_bytes(im):
    return bytes(sum(int(im.getpixel((x+i,y)))<<(7-i) for i in range(8)) for y in range(16) for x in range(0,40,8))

def package(p,ram):
    # Keep a literal prefix in the retired tile bank: compressing empty space too
    # aggressively lets the in-place decoder overwrite its unread input.
    # Retired map resources stay literal, preserving the original input gap.
    # 3264 literal bytes plus the preceding sprite bank preserve the later gap;
    # the remaining star tables are compressed. Replay below checks every block.
    streams=[bytearray(),bytearray()];phase=0;old=p['banks']['ram']
    for block in p['blocks']:
        a=block['start'];data=bytearray(block['data'])
        for i in range(len(data)):
            if ram[a+i]!=old[a+i]:data[i]=ram[a+i]
        if a==0x2400:
            streams[phase]+=rle(struct.pack('<HH',0x1780,0xc80))+rle(ram[0x1780:0x2400])
        streams[phase]+=rle(struct.pack('<HH',a,len(data)))
        literal=lambda values:b''.join(bytes([0xbf,v,1]) if v in (0xbf,0xcf) else bytes([v]) for v in values)
        if a==0x2400:encoded=literal(data[:3264])+rle(data[3264:])
        elif a==0x480:encoded=literal(data)
        else:encoded=rle(data)
        streams[phase]+=encoded
        if a==0xbb00:
            streams[0]+=rle(bytes(4));phase=1
    streams[1]+=rle(struct.pack('<HH',0x7fee,0xffff))
    result=bytearray(p['original'])
    for base,end,encoded in zip((0x2b00,0x8000),(0x7fee,0xb300),streams):
        assert len(encoded)<=end-base,(hex(base),len(encoded),end-base)
        offset=6+base-0x2b00;result[offset:offset+len(encoded)]=encoded
    replay,_,_,_=kult(result)
    assert replay[0x1780:0x2400]==ram[0x1780:0x2400]
    for b in p['blocks']:
        a=b['start'];n=b['size']
        if a not in (0xd301,0xbb00):assert replay[a:a+n]==ram[a:a+n],hex(a)
    return bytes(result)

def scenery(ram,rng,write_files=True):
    # Every star has its own randomly placed horizontal position. No missile
    # columns, repeated diagonal grids or evenly spaced vertical sequences.
    placed=[]
    stars=[]
    for lane,count,mask in ((0,8,(8,8)),(1,16,(8,8)),(2,32,(8,8))):
        height=len(mask);occupied=set()
        for i in range(count):
            choices=[y for y in range(43,166-height) if not occupied.intersection(range(y-1,y+height+1))]
            if not choices:raise ValueError('Star layout cannot fit')
            y=rng.choice(choices)
            occupied.update(range(y,y+height))
            best=[]
            for x in range(62,188):
                distance=min(((x-px)**2+((y-py)*.7)**2 for px,py in placed),default=99999)
                best.append((distance,x))
            # Choose among dispersed candidates; do not force rows or columns.
            best.sort(reverse=True)
            x=rng.choice(best[:max(12,len(best)//3)])[1]
            placed.append((x,y));stars.append(dict(lane=lane,x=x,y=y,height=height))
            for dy,bits in enumerate(mask):
                ram[0x3400+lane*256+y+dy]=bits
                ram[0x3800+lane*256+y+dy]=x
    # Retain full round glyphs, then clip only pixels outside the sky's edges.
    for x in range(256):
        ram[0x2c00+x]=sum(0x80>>bit for bit in range(8) if 64<=x+bit<192)
    ram[0x2800:0x2c00]=ram[0x3400:0x3800]
    for lane in range(4):
        for y in range(256):
            x=ram[0x3800+lane*256+y]
            ram[0x3400+lane*256+y]&=ram[0x2c00+x]
    if write_files:(ROOT/'star-layout.json').write_text(json.dumps(stars,indent=2)+'\n')

def create_runtime(settings=None,assemble=False,write_files=False):
    p=project('kult');old=p['banks']['ram'];ram=bytearray(old)
    # Retire all building tiles, retaining black space in the scrolling buffers,
    # and reuse the remainder for PM DMA and the small 6502 extension.
    ram[0x2400:0x4400]=bytes(0x2000)
    ram[0x1800:0x2400]=bytes(0xc00)
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'mixed.asm'),'-o:'+str(ROOT/'mixed.bin')],check=True,stdout=subprocess.PIPE)
    mixed=(ROOT/'mixed.bin').read_bytes();assert len(mixed)<=224
    ram[0x2420:0x2420+len(mixed)]=mixed # Preserve the 32-byte black terrain tile at $2400.
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'boss-sprites.asm'),'-o:'+str(ROOT/'boss-sprites.bin')],check=True,stdout=subprocess.PIPE)
    sprite_code=(ROOT/'boss-sprites.bin').read_bytes()
    assert len(sprite_code)<=0x380
    ram[0x1800:0x1800+len(sprite_code)]=sprite_code
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'meteors.asm'),'-o:'+str(ROOT/'meteors.bin')],check=True,stdout=subprocess.PIPE)
    meteor_code=(ROOT/'meteors.bin').read_bytes()
    assert len(meteor_code)<=0xa0
    ram[0x2360:0x2360+len(meteor_code)]=meteor_code
    # Reuse retired compressed terrain sources for guardian-format resources.
    ram[0x480:0x1781]=bytes(0x1301)
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'boss-art.asm'),'-o:'+str(ROOT/'boss-art.bin')],check=True,stdout=subprocess.PIPE)
    art_code=(ROOT/'boss-art.bin').read_bytes()
    assert len(art_code)<=0x200
    ram[0x480:0x480+len(art_code)]=art_code
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'boss-cache.asm'),'-o:'+str(ROOT/'boss-cache.bin')],check=True,stdout=subprocess.PIPE)
    cache=(ROOT/'boss-cache.bin').read_bytes()
    assert len(cache)<=0x80
    ram[0x1780:0x1800]=cache+bytes(0x80-len(cache))
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'boss-tools.asm'),'-o:'+str(ROOT/'boss-tools.bin')],check=True,stdout=subprocess.PIPE)
    helpers=(ROOT/'boss-tools.bin').read_bytes()
    assert len(helpers)<=0x180
    ram[0x300:0x480]=helpers+bytes(0x180-len(helpers))
    rng=random.Random(0xD1AB)
    # Blank terrain eliminates competing sideways motion. Stars use PM DMA.
    scenery(ram,rng,write_files)
    frames=[]
    for f in range(4):
        im=ship(f);frames.append(im)
        base=word(old,0x7450+f*2)
        for shift in range(4):
            aligned=Image.new('1',(40,16));aligned.paste(im,(shift*2,0))
            ram[base+shift*80:base+(shift+1)*80]=ship_bytes(aligned)
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'space.asm'),'-o:'+str(ROOT/'space.bin'),'-l:'+str(ROOT/'space.lst')],check=True,stdout=subprocess.PIPE)
    code=(ROOT/'space.bin').read_bytes();ram[0x4000:0x4000+len(code)]=code
    assert 0x4000+len(code)<=0x43ff
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'encounters.asm'),'-o:'+str(ROOT/'encounters.bin'),'-l:'+str(ROOT/'encounters.lst')],check=True)
    extra=(ROOT/'encounters.bin').read_bytes();ram[0x3b00:0x3b00+len(extra)]=extra
    assert 0x3b00+len(extra)<=0x3f50
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'debug.asm'),'-o:'+str(ROOT/'debug.bin')],check=True,stdout=subprocess.PIPE)
    debug=(ROOT/'debug.bin').read_bytes()
    assert len(debug)<=0xb0
    ram[0x3f50:0x3f50+len(debug)]=debug
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'boss.asm'),'-o:'+str(ROOT/'boss.bin'),'-l:'+str(ROOT/'boss.lst')],check=True,stdout=subprocess.PIPE)
    boss_code=(ROOT/'boss.bin').read_bytes()
    assert len(boss_code)<=0x134
    # Model-redesigned weapon and shield collectibles, in native 3-byte rows.
    pickups=json.loads((ROOT/'art/pickups.json').read_text())
    for i,icon in enumerate(pickups):
        frame=icon['frames'][0];address=word(ram,0x7264+i*2)
        raw=bytes(sum(frame[y*16+x+k]<<(7-k) for k in range(8)) for y in range(16) for x in (0,8))
        ram[address:address+48]=b''.join(raw[y*2:y*2+2]+b'\x00' for y in range(16))
    ring=Image.new('1',(44,20));ImageDraw.Draw(ring).ellipse((0,0,43,19),outline=1)
    points=[(x,y) for y in range(20) for x in range(44) if ring.getpixel((x,y))]
    assert len(points)<128
    ram[0x2b00:0x2b00+len(points)]=bytes(x for x,y in points)
    ram[0x2b80:0x2b80+len(points)]=bytes(y for x,y in points)
    ram[0x2d68]=len(points)
    ram[0x4e7b]=0
    from hud_art import build_hud
    build_hud(ram)
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'hud.asm'),'-o:'+str(ROOT/'hud.bin'),'-l:'+str(ROOT/'hud.lst')],check=True)
    hud=(ROOT/'hud.bin').read_bytes()
    ram[0x6384:0x6684]=hud+bytes(768-len(hud))
    assert 0x6384+len(hud)<=0x6550
    ram[0x6550:0x6550+len(boss_code)]=boss_code
    # Replace the top bitmap with 24 blank scanlines, preserving sky timing.
    for dl in (0x6001,0x61c3):
        target=dl+26
        ram[dl:dl+6]=bytes([0x70,0x70,0x70,0x01,target&255,target>>8])

    patches={
        0xF914:('207efc','208317'), # retain unchanged body pixels in each framebuffer
        0xEAAD:('ce8e75','4c80de'), # hold retired terrain scrolling during bosses
        0xF91C:('20f9e7','20a0de'), # avoid obsolete terrain copies in sub-boss fights
        0xEB52:('b9e074','208604'), # skip rendering invisible sub-boss collision targets
        0xFCAB:('ac08fd','4c8904'), # fast full-width boss erasure
        0xF80E:('2083fe','20c0da'), # shared boss action controller
        0xF819:('203ffe','200c03'), # guardian damage gate and moving target
        0xFB8C:('a207a900','4c0f03ea'), # retain active sub-boss while it retreats
        0xFC9B:('8d08fd','201803'), # clip guardian background erasure at right edge
        0xFDAD:('a210a000','4c8304ea'), # clip tile copies at right sky edge
        0xF925:('20d5fd','208004'), # shared 64x64 animated guardian/sub-boss renderer
        0xC1FF:('200003','eaeaea'), # retired terrain decoder: reserve 1800-23FF for full-size bullet sprites
        0xF8DE:('a0','60'), # retired progress-bar reset must not erase HUD/bomb code

        0xEB25:('a0008c','4c46eb'), # remove wave mini-map plotting
        0xED1C:('a0','60'), # remove mini-map clearing
        0xF801:('208cfb','20503f'), # TEMP DEBUG: 1 skips to sector's first skull wave
        0xF814:('d003','eaea'), # bombs also available during guardian encounters

        0xF891:('8d774e','208763'), # initialize independent bombs and shields
        0xF39D:('a2','60'), # obsolete four-weapon HUD renderer
        0xF81F:('2020f42066f42075f4208cf420adf420c1f4','eaeaeaeaeaeaeaeaeaeaeaeaeaeaeaeaeaea'),
        0xF48D:('90','0e'), 0xF491:('64','68'), # score at x80,y12
        0xF476:('a2','72'), 0xF47A:('64','69'), # stage at x112,y23

        0xEE11:('adbeed','20213b'), # clip enemy drawing at framebuffer bottom
        0xED7A:('aebeed','20243b'), # clip restoration identically
        0xF90B:('20a7ec','200018'), # erase old shield from current backbuffer
        0xF93C:('2005ec','200318'), # tight shield ellipse after sprites
        0xF92B:('adbff0','20183b'), # keep ship visible inside shield

        0xF7FB:('201af5','20123b'), # Space shield before collision, including guardians
        0xF890:('01','03'),         # start with three shields
        0xFA04:('05','04'),         # pickup stock cap: three
        0xF420:('a9','60'),         # remove old stacked bomb icons
        0xF46F:('76','77'),         # former bonus digits now display shield count

        0xF81C:('20e5f3','208463'), # boss HP in the former fuel meter

        0xF841:('aebcf8','4c5bf8'), # skip depletion and empty-fuel death
        0xF3E5:('ad','60'),         # remove gauge updater
        0xC1B4:('8d7b4e','eaeaea'), # no stage fuel refill
        0xF886:('8d7b4e','eaeaea'), # no new-game fuel refill
        0xFA13:('8d7b4e','eaeaea'), # obsolete pickup cannot restore fuel

        0xFC22:('206bf1','20003b'), # select wave encounter and graphics
        0xF7F2:('20a4e7','20033b'), # normal, meteor or sub-boss motion
        0xEB60:('bd3c74','20063b'), # composite boss tile selection
        0xFA64:('de8675','20093b'), # immunity / shared boss health
        0xF816:('2061f3','200c3b'), # bombs obey encounter rules

        0xEBB1:('d003','eaea'), # always advance formation twice per update
        0xFC1B:('80','60'),     # spawn closer to the right edge

        0xF764:('73','0c'),
        0xF769:('ea','40'),
        0xC126:('2062c3','4c55c1'), # skip title/menu loop, enter normal game setup
        0xC23B:('20','60'),         # skip stage announcement / fire prompt

        0xF746:('20d6e9','200040'), # graphics initialization
        0xF834:('2008f9','200340'), # per-game-frame parallax
        0xC41B:('adf1c3','200640'), # disable hardware scenery in menus
        0xE843:('2005e9','200940'), # replace building tile selection
        0xF75F:('21','3d'),        # enable single-line player DMA
        0xF975:('c900','29aa'),    # pixel 01 stars cannot cause collisions
    }
    for at,(expected,new) in patches.items():
        assert old[at:at+len(bytes.fromhex(expected))]==bytes.fromhex(expected),hex(at)
        ram[at:at+len(bytes.fromhex(new))]=bytes.fromhex(new)
    from workshop import apply_project, default_project
    apply_project(ram,settings if settings is not None else default_project())
    if assemble:subprocess.run([os.environ.get('MADS','mads'),str(ROOT/'boss-ai.asm'),'-o:'+str(ROOT/'boss-ai.bin')],check=True,stdout=subprocess.PIPE)
    ai=(ROOT/'boss-ai.bin').read_bytes()
    assert len(ai)<=0x440
    ram[0xdac0:0xdf00]=ai+bytes(0x440-len(ai))
    return p,ram,patches,frames

def main():
    from workshop import load_project
    p,ram,patches,frames=create_runtime(load_project(),assemble=True,write_files=True)
    old=p['banks']['ram']
    out=package(p,ram);(ROOT/'kult-diabolic.xex').write_bytes(out)
    preview=Image.new('1',(164,20))
    for f,im in enumerate(frames):preview.paste(im,(f*41,2))
    preview.resize((656,80),Image.Resampling.NEAREST).convert('RGB').save(ROOT/'ship.png')
    manifest={'original_sha256':hashlib.sha256(p['original']).hexdigest(),'output_sha256':hashlib.sha256(out).hexdigest(),'runtime_changed_bytes':sum(a!=b for a,b in zip(old,ram)),'patches':{f'{a:04X}':{'before':x,'after':y} for a,(x,y) in patches.items()},'cpu_depacker_verified':True}
    (ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    formations=json.loads((ROOT.parent/'editor/boss-formations.json').read_text())
    (ROOT.parent/'editor/boss-formations.js').write_text('// Generated from boss-formations.json by the native builder.\n(function(root){const formations='+json.dumps(formations,separators=(',',':'))+";if(typeof module!=='undefined')module.exports=formations;else root.BossFormations=formations;})(globalThis);\n")
    print('Built',ROOT/'kult-diabolic.xex','with verified original-loader replay.')
if __name__=='__main__':main()
