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
    return {'ships':[v for v in generated if v['width']==40], 'enemies':enemies+[v for v in generated if v['width']==16]+json.loads((ROOT/'art/imported-enemies.json').read_text())+json.loads((ROOT/'art/redesigned-enemies.json').read_text())}
def aggressive_motion(row):
    return [max(-128,min(127,(1 if n>=0 else -1)*((abs(n)*3+1)//2))) if i<4 else n for i,n in enumerate(row)]
def default_project():
    ram=original_project('kult')['banks']['ram']
    signed=lambda b:b if b<128 else b-256
    return dict(version=1,ship='ship-2',slots=[f'redesign-{i}' for i in range(32)],
      waves=[[list(ram[0x4400+s*192+w*4:0x4404+s*192+w*4]) for w in range(48)] for s in range(8)],
      motions=[aggressive_motion([signed(b) for b in ram[0x7310+i*8:0x7318+i*8]]) for i in range(32)],
      boss=dict(pattern=0,difficulty=1),firing=dict(mode=2,interval=18,speed=3),encounters=[[0,0,1,0,2,0,3,4]+[0]*40 for _ in range(8)])
def integer(v,lo,hi):
    if type(v)!=int or not lo<=v<=hi:raise ValueError(f'Expected integer {lo}..{hi}')
    return v
def validate(value):
    if isinstance(value,dict) and 'boss' not in value:value=dict(value,boss=dict(pattern=0,difficulty=1))
    if isinstance(value,dict) and 'encounters' not in value:value=dict(value,encounters=[[0]*48 for _ in range(8)])
    if not isinstance(value,dict) or set(value)!={'version','ship','slots','waves','motions','firing','encounters','boss'}:raise ValueError('Invalid Diabolic project fields')
    if value['version']!=1:raise ValueError('Unsupported project version')
    encounters=value['encounters']
    if not isinstance(encounters,list) or len(encounters)!=8:raise ValueError('Expected 8 encounter sectors')
    for sector in encounters:
        if not isinstance(sector,list) or len(sector)!=48:raise ValueError('Expected 48 encounter types')
        for kind in sector:integer(kind,0,4)
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
    if not isinstance(boss,dict) or set(boss)!={'pattern','difficulty'}:raise ValueError('Invalid boss attacks')
    integer(boss['pattern'],0,3);integer(boss['difficulty'],0,2)
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
    # Each nonzero drop-table entry belongs to one of eight enemies.
    # Retain at most two original awards per pattern, spread through the wave.
    for pattern in range(32):
        start=0x4a00+pattern*8
        for i in range(8):
            if ram[start+i]>=6:ram[start+i]=0  # remove fuel and score-only bonus packages
        eligible=[i for i in range(8) if ram[start+i]]
        keep=set(eligible if len(eligible)<=2 else (eligible[len(eligible)//3],eligible[2*len(eligible)//3]))
        for i in range(8):
            if i not in keep:ram[start+i]=0
    # Redesigned meteor and skull, independent of ordinary enemy slot assignments.
    original=original_project('kult')['banks']['ram']
    ram[0x2f00:0x2f80]=b''.join(pack(f,16,16) for f in enemies['redesign-14']['frames'])
    ram[0x2f80:0x2f88]=bytes(int(f'{b:08b}'[::-1],2) for b in original[0x7278:0x7280])
    head=enemies['redesign-19']['frames'][0]
    for tile in range(8):
        frame=[head[((tile//4*16+y)//2)*16+(tile%4*16+x)//4] for y in range(16) for x in range(16)]
        ram[0x2e00+tile*32:0x2e20+tile*32]=pack(frame,16,16)
    ram[0x2d74:0x2d76]=bytes(value['boss'][k] for k in ('pattern','difficulty'))
    ram[0x2d00:0x2d03]=bytes(value['firing'][k] for k in ('mode','interval','speed'))
def public():
    ram=original_project('kult')['banks']['ram']
    from hud_art import build_hud
    hud_ram=bytearray(65536)
    build_hud(hud_ram, write_patterns=False)
    drops=[]
    for pattern in range(32):
        row=[v if v<6 else 0 for v in ram[0x4a00+pattern*8:0x4a08+pattern*8]]
        eligible=[i for i,v in enumerate(row) if v]
        keep=eligible if len(eligible)<=2 else [eligible[len(eligible)//3],eligible[2*len(eligible)//3]]
        drops.append([v if i in keep else 0 for i,v in enumerate(row)])
    guardian=[]
    for y in range(64):
        for x in range(32):
            tile=ram[0xfed2+(y//16)*4+x//8]
            at=0xdac0+(tile-1)*32+(y%16)*2+(x%8)//4
            guardian.append(((ram[at]>>(6-(x%4)*2))&3) if tile else 0)
    return dict(guardian=guardian,hud=list(hud_ram[0x6684:0x6a84]),digits=list(ram[0x4c00:0x4c50]),drops=drops,pickups=json.loads((ROOT/'art/pickups.json').read_text()),project=load_project(),defaults=default_project(),catalog=catalog(),playerBullet=[int(f'{b:08b}'[::-1],2) for b in ram[0x7278:0x7280]],sine=list(ram[0x7164:0x7264]))
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
