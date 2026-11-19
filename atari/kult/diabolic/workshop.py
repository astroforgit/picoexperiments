"""Validated Diabolic projects, catalog and native export shared by CLI and UI."""
import functools,json,os,threading,sys,importlib.util
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent.parent/'editor'))
from assets import project as original_project,word
ROOT=Path(__file__).resolve().parent
LOCK=threading.Lock()
def pixels(data,width,height):
    return [(data[y*(width//8)+x//8]>>(7-x%8))&1 for y in range(height) for x in range(width)]
def pack(frame,width,height):
    return bytes(sum(frame[y*width+x+i]<<(7-i) for i in range(8)) for y in range(height) for x in range(0,width,8))
@functools.lru_cache(maxsize=1)
def catalog():
    generated=json.loads((ROOT/'art/designs.json').read_text());ram=original_project('kult')['banks']['ram']
    enemies=[dict(id=f'original-{i}',name=f'Original enemy {i+1:02}',width=16,height=16,source='Kult',frames=[pixels(ram[0x4f80+i*128+f*32:0x4fa0+i*128+f*32],16,16) for f in range(4)]) for i in range(32)]
    orb=dict(id='boss-orb',name='Boss orb',width=16,height=16,frames=[[int(15<=(x-7.5)**2+(y-7.5)**2<=36 or ((x-5)**2+(y-5)**2<=2)) for y in range(16) for x in range(16)]])
    return {'projectiles':[orb], 'bosses':json.loads((ROOT/'art/bosses/catalog.json').read_text()), 'ships':[v for v in generated if v['width']==40], 'enemies':enemies+[v for v in generated if v['width']==16]+json.loads((ROOT/'art/imported-enemies.json').read_text())+json.loads((ROOT/'art/redesigned-enemies.json').read_text())}
def aggressive_motion(row):
    return [max(-128,min(127,(1 if n>=0 else -1)*((abs(n)*3+1)//2))) if i<4 else n for i,n in enumerate(row)]
def default_project():
    ram=original_project('kult')['banks']['ram']
    signed=lambda b:b if b<128 else b-256
    return dict(version=1,ship='ship-2',slots=[f'redesign-{i}' for i in range(32)],
      waves=[[list(ram[0x4400+s*192+w*4:0x4404+s*192+w*4]) for w in range(48)] for s in range(8)],
      motions=[aggressive_motion([signed(b) for b in ram[0x7310+i*8:0x7318+i*8]]) for i in range(32)],
      boss=dict(pattern=0,difficulty=1,design='boss-bone-dragon'),firing=dict(mode=2,interval=18,speed=3),encounters=[[0,0,1,0,2,0,3,4,0,0,6,7]+[0]*36 for _ in range(8)])
def integer(v,lo,hi):
    if type(v)!=int or not lo<=v<=hi:raise ValueError(f'Expected integer {lo}..{hi}')
    return v
def validate(value):
    if isinstance(value,dict) and 'boss' not in value:value=dict(value,boss=dict(pattern=0,difficulty=1))
    if isinstance(value,dict) and isinstance(value.get('boss'),dict) and 'design' not in value['boss']:value=dict(value,boss=dict(value['boss'],design='boss-bone-dragon'))
    if isinstance(value,dict) and isinstance(value.get('boss'),dict) and value['boss'].get('design')=='boss-original-dragon':value=dict(value,boss=dict(value['boss'],design='boss-insect-queen'))
    if isinstance(value,dict) and 'encounters' not in value:value=dict(value,encounters=[[0]*48 for _ in range(8)])
    if not isinstance(value,dict) or set(value)!={'version','ship','slots','waves','motions','firing','encounters','boss'}:raise ValueError('Invalid Diabolic project fields')
    if value['version']!=1:raise ValueError('Unsupported project version')
    encounters=value['encounters']
    if not isinstance(encounters,list) or len(encounters)!=8:raise ValueError('Expected 8 encounter sectors')
    for sector in encounters:
        if not isinstance(sector,list) or len(sector)!=48:raise ValueError('Expected 48 encounter types')
        for kind in sector:
            integer(kind,0,7)
            if kind==5:raise ValueError("Encounter 5 is reserved")
    lib=catalog()
    if value['ship'] not in {a['id'] for a in lib['ships']}:raise ValueError('Unknown ship')
    slots=value['slots'];known={a['id'] for a in lib['enemies']}
    if not isinstance(slots,list) or len(slots)!=32 or any(not isinstance(v,str) or v not in known for v in slots):raise ValueError('Choose 32 valid enemy slots')
    waves=value['waves']
    if not isinstance(waves,list) or len(waves)!=8:raise ValueError('Expected 8 sectors')
    for sector in waves:
        if not isinstance(sector,list) or len(sector)!=48:raise ValueError('Expected 48 waves per sector')
        for wave in sector:
            if not isinstance(wave,list) or len(wave)!=4:raise ValueError('Invalid wave')
            for i,n in enumerate(wave):integer(n,1 if i==3 else 0,16 if i==3 else 31)
    motions=value['motions']
    if not isinstance(motions,list) or len(motions)!=32:raise ValueError('Expected 32 movement paths')
    for row in motions:
        if not isinstance(row,list) or len(row)!=8:raise ValueError('Movement paths need eight parameters')
        for n in row:integer(n,-128,127)
    fire=value['firing']
    if not isinstance(fire,dict) or set(fire)!={'mode','interval','speed'}:raise ValueError('Invalid firing settings')
    integer(fire['mode'],0,2);integer(fire['interval'],12,180);integer(fire['speed'],1,4)
    boss=value['boss']
    if not isinstance(boss,dict) or set(boss)!={'pattern','difficulty','design'}:raise ValueError('Invalid boss attacks')
    integer(boss['pattern'],0,6);integer(boss['difficulty'],0,2)
    if not isinstance(boss['design'],str) or boss['design'] not in {b['id'] for b in lib['bosses']}:raise ValueError('Unknown boss design')
    return json.loads(json.dumps(value))
def load_project():
    file=ROOT/'game-project.json'
    return validate(json.loads(file.read_text())) if file.exists() else default_project()
def apply_project(ram,value):
    value=validate(value);lib=catalog()
    ship=next(v for v in lib['ships'] if v['id']==value['ship'])
    for f,frame in enumerate(ship['frames']):
        raw=pack(frame,40,16);base=word(ram,0x7450+f*2)
        for shift in range(4):
            aligned=b''.join((int.from_bytes(raw[y*5:y*5+5],'big')>>(shift*2)).to_bytes(5,'big') for y in range(16))
            ram[base+shift*80:base+(shift+1)*80]=aligned
    enemies={v['id']:v for v in lib['enemies']}
    for slot,id in enumerate(value['slots']):
        for f,frame in enumerate(enemies[id]['frames']):ram[0x4f80+slot*128+f*32:0x4fa0+slot*128+f*32]=pack(frame,16,16)
    for sector,waves in enumerate(value['waves']):
        for w,record in enumerate(waves):
            encoded=list(record);encoded[1]|=value['encounters'][sector][w]<<5
            ram[0x4400+sector*192+w*4:0x4404+sector*192+w*4]=bytes(encoded)
    for i,motion in enumerate(value['motions']):ram[0x7310+i*8:0x7318+i*8]=bytes(n&255 for n in motion)
    for pattern,row in enumerate(drop_patterns(original_project('kult')['banks']['ram'])):
        ram[0x4a00+pattern*8:0x4a08+pattern*8]=bytes(row)
    # Redesigned meteor and skull, independent of ordinary enemy slot assignments.
    original=original_project('kult')['banks']['ram']
    ram[0x2f00:0x2f80]=b''.join(pack(f,16,16) for f in enemies['redesign-14']['frames'])
    ram[0x2f80:0x2f88]=bytes(int(f'{b:08b}'[::-1],2) for b in original[0x7278:0x7280])
    # Keep the original eight hit targets invisible; the guardian blitter draws
    # the 64x64 appearance with a central 64x32 damage area.
    ram[0x2e00:0x2f00]=bytes(256)
    boss=next(b for b in lib['bosses'] if b['id']==value['boss']['design'])
    for f,frame in enumerate(boss['frames']):
        for tile in range(16):
            pixels=[frame[(tile//4*16+y)*64+tile%4*16+x] for y in range(16) for x in range(16)]
            at=0x800+f*512+tile*32
            ram[at:at+32]=pack(pixels,16,16)
    ram[0x1000:0x1040]=bytes(i+1 if any(ram[0x800+i*32:0x820+i*32]) else 0 for i in range(64))
    # End-of-level guardian: replace every original dragon tile and frame map.
    queen=next(b for b in lib['bosses'] if b['id']=='boss-insect-queen')
    tiles=[];maps=[]
    for frame in queen['frames']:
        for tile in range(16):
            raw=pack([frame[(tile//4*16+y)*64+tile%4*16+x] for y in range(16) for x in range(16)],16,16)
            if not any(raw):maps.append(0);continue
            if raw not in tiles:tiles.append(raw)
            maps.append(tiles.index(raw)+1)
    assert len(tiles)<=56, 'Guardian tile bank overflow'
    ram[0x1040:0x1740]=b''.join(tiles)+bytes(0x700-len(tiles)*32)
    ram[0x1740:0x1780]=bytes(maps)
    ram[0xfcfe:0xfd00]=bytes([0x40,0x10])
    ram[0xfd02:0xfd04]=bytes([0x40,0x17])
    ram[0xdac0:0xdf00]=bytes(0x440)
    ram[0xfed2:0xff12]=bytes(64)
    # Original enemy 18, four animation frames and all four two-pixel alignments.
    source=original[0x4f80+17*128:0x4f80+18*128]
    for frame in range(4):
        for alignment in range(4):
            address=0x2000+(frame*4+alignment)*48
            ram[0x2da0+frame*4+alignment]=address&255
            ram[0x2db0+frame*4+alignment]=address>>8
            for row in range(16):
                bits=((source[frame*32+row*2]<<8)|source[frame*32+row*2+1])<<(8-alignment*2)
                ram[address+row*3:address+row*3+3]=bits.to_bytes(3,'big')
    # Static rounded orbs and the existing meteor, with all four alignments.
    orb=[int(15<=(x-7.5)**2+(y-7.5)**2<=36 or ((x-5)**2+(y-5)**2<=2)) for y in range(16) for x in range(16)]
    for base,frame in ((0x680,orb),(0x740,enemies['redesign-14']['frames'][0])):
        raw=pack(frame,16,16)
        for alignment in range(4):
            for row in range(16):
                bits=int.from_bytes(raw[row*2:row*2+2],'big')<<(8-alignment*2)
                ram[base+alignment*48+row*3:base+alignment*48+row*3+3]=bits.to_bytes(3,'big')
    formations=json.loads((ROOT.parent/'editor/boss-formations.json').read_text())
    for i,f in enumerate(formations,1):
        ram[0x2300+i]=f['doubleTime'];ram[0x2310+i]=f['phase'];ram[0x2320+i]=f['rowShift'];ram[0x2350+i]=f['xPhase']
        ram[0x2330+(i-1)*2:0x2332+(i-1)*2]=bytes(f['soloGuards'])
        ram[0x2340+(i-1)*2:0x2342+(i-1)*2]=bytes(f['mixedGuards'])
    ram[0x2d74:0x2d76]=bytes(value['boss'][k] for k in ('pattern','difficulty'))
    ram[0x2d00:0x2d03]=bytes(value['firing'][k] for k in ('mode','interval','speed'))
def drop_patterns(ram):
    """Two awards maximum: clocks in 24/32 patterns, bombs in 4/32."""
    result=[]
    for pattern in range(32):
        row=[v if 0<v<6 else 0 for v in ram[0x4a00+pattern*8:0x4a08+pattern*8]]
        eligible=[i for i,v in enumerate(row) if v]
        keep=eligible if len(eligible)<=2 else [eligible[len(eligible)//3],eligible[2*len(eligible)//3]]
        row=[v if i in keep else 0 for i,v in enumerate(row)]
        if pattern%4!=3 or pattern%8==7:
            slot=keep[0] if keep else 2
            row[slot]=6 if pattern%4!=3 else 7 # pickup indices 5 clock / 6 bomb
        result.append(row)
    return result

def public():
    ram=original_project('kult')['banks']['ram']
    from hud_art import build_hud
    hud_ram=bytearray(65536)
    build_hud(hud_ram, write_patterns=False)
    drops=drop_patterns(ram)
    guardian=next(b for b in catalog()['bosses'] if b['id']=='boss-insect-queen')['frames'][0]
    from bullet_waves import measure
    applied=load_project()
    return dict(bossFormations=json.loads((ROOT.parent/'editor/boss-formations.json').read_text()),bulletWaves=measure(applied,ram[0x7164:0x7264]),guardian=guardian,mainBoss='boss-insect-queen',hud=list(hud_ram[0x6684:0x6a84]),digits=list(ram[0x4c00:0x4c50]),drops=drops,pickups=json.loads((ROOT/'art/pickups.json').read_text()),project=applied,defaults=default_project(),catalog=catalog(),playerBullet=[int(f'{b:08b}'[::-1],2) for b in ram[0x7278:0x7280]],sine=list(ram[0x7164:0x7264]))
def export(value,apply=False):
    spec=importlib.util.spec_from_file_location("diabolic_native_build",ROOT/"build.py")
    builder=importlib.util.module_from_spec(spec);spec.loader.exec_module(builder)
    create_runtime,package=builder.create_runtime,builder.package
    settings=validate(value)
    with LOCK:
        p,ram,_,_=create_runtime(settings)
        binary=package(p,ram)
        if apply:
            (ROOT/'game-project.json.tmp').write_text(json.dumps(settings,indent=2)+'\n')
            (ROOT/'kult-diabolic.xex.tmp').write_bytes(binary)
            os.replace(ROOT/'kult-diabolic.xex.tmp',ROOT/'kult-diabolic.xex')
            os.replace(ROOT/'game-project.json.tmp',ROOT/'game-project.json')
        return binary
