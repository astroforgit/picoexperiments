"""Known asset layouts and exporters for the supplied Kult and CETAS releases."""
import base64, functools, struct, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'decompiled/tools'))
from recover import kult, cetas_resource, load
from archive import parse
from atr import files,sector

def word(b,a):return int.from_bytes(b[a:a+2],'little')
def b64(b):return base64.b64encode(b).decode()
def asset(id,name,bank,offset,width,height,bpp=2,**extra):
    return dict(id=id,name=name,bank=bank,offset=offset,width=width,height=height,bpp=bpp,**extra)

@functools.lru_cache(maxsize=2)
def project(game):
    assets=[]
    if game=='kult':
        original=(ROOT.parent/'Kult (v1).xex').read_bytes();ram,_,blocks,_=kult(original)
        banks={'ram':ram}
        for i in range(256):assets.append(asset(f'char-{i}',f'Character {i:03}', 'ram',0xc800+8*i,8,8,1,category='Characters'))
        for frame in range(4):
            base=word(ram,0x7450+frame*2)
            for shift in range(4):assets.append(asset(f'player-{frame}-{shift}',f'Player frame {frame+1} · alignment {shift}', 'ram',base+shift*80,20,16,category='Player sprites',group=f'player-{frame}',shift=shift))
        # $F16B selects $4F80 + design*128; $F0C4 expands each 32-byte
        # 8x16 frame into four 12x16 horizontal alignment variants at runtime.
        collections=[]
        for design in range(33):
            ids=[]
            for frame in range(4):
                id=f'enemy-{design}-{frame}';ids.append(id)
                assets.append(asset(id,f'Enemy {design+1:02} · frame {frame+1}' if design<32 else f'Effect set 33 · frame {frame+1}', 'ram',0x4f80+design*128+frame*32,8,16,category='Enemy sprites' if design<32 else 'Effects',animation=[f'enemy-{design}-{i}' for i in range(4)]))
            collections.append({'name':f'Enemy {design+1:02}' if design<32 else 'Effect set 33','ids':ids,'kind':'animation' if design<32 else 'variants'})
        # $FD84 draws 16 rows of 2 bytes, indexed from the pointer at $FCFE.
        for i in range(34):assets.append(asset(f'tile-{i}',f'Game tile {i+1:02}', 'ram',0xdac0+i*32,8,16,category='Game tiles'))
        # Confirmed five-entry menu palette table read by $C390.
        palettes=[{'name':f'Menu palette {i+1}','bank':'ram','offset':0xc402+i*5,'size':5} for i in range(5)]
        return {'original':original,'banks':banks,'assets':assets,'palettes':palettes,'blocks':blocks,'collections':collections}
    if game!='cetas':raise ValueError('Unknown game')
    original=(ROOT.parent/'CETAS (WIP).ATR').read_bytes();fs={name.rstrip('.'):data for name,data,_,_ in files(original)}
    ram,_=load(fs['E']);banks={'game':bytes(ram)}
    for name in 'ABCDF':banks[name]=cetas_resource(fs['AUTO'],fs[name])[1]
    for name,title in zip('ABCD',['Publisher logo','Monochrome logo','Credits','Title screen']):
        assets.append(asset('picture-'+name,title,name,0,160,192,category='Pictures'))
    for i in range(118):assets.append(asset(f'char-{i}',f'Status character {i:03}','game',0x5000+i*8,8,8,1,category='Characters'))
    # The renderer ($2C06/$2D3F) reads 7 header bytes, then width*height
    # consecutive 2-bit pixels, drawing upwards one scanline at a time.
    pointers={}
    ram=bytearray(ram);ram[0xe010:0xe010+len(banks['F'])]=banks['F']
    for a,end in [(0x2c4a,0x2c76),(0x2d67,0x2df5)]:
        for at in range(a,end,2):
            p=word(ram,at);w,h=ram[p+1:p+3]
            if not (1<=w<=48 and 1<=h<=192):continue
            bank='F' if 0xe010<=p<0xe010+len(banks['F']) else 'game'
            offset=p+7-(0xe010 if bank=='F' else 0)
            if offset+w*h>len(banks[bank]):continue
            if not (bank=='F' or 0x5428<=p<0x6c72):continue
            if p not in pointers:
                pointers[p]=asset(f'sprite-{p:04x}',f'Sprite ${p:04X}',bank,offset,w*4,h,flipY=True,category='Sprites',address=p,header=list(ram[p:p+7]))
    collections=[]
    for object_type in range(2,19):
        ids=list(dict.fromkeys(f'sprite-{word(ram,0x2d67+(object_type-1)*8+shift*2):04x}' for shift in range(4)))
        ids=[id for id in ids if any(a['id']==id for a in pointers.values())]
        collections.append({'name':f'Object type {object_type:02}', 'ids':ids, 'kind':'variants'})
        for a in pointers.values():
            if a['id'] in ids:
                a.setdefault('objectTypes',[]).append(object_type)
                a.setdefault('animation',ids)
    for a in pointers.values():
        if a.get('objectTypes'):a['name']+=' · type '+', '.join(map(str,a['objectTypes']))
    assets+=list(pointers.values())
    palettes=[]
    return {'original':original,'banks':banks,'assets':assets,'palettes':palettes,'files':fs,'collections':collections}

def public(game):
    p=project(game)
    return {'game':game,'version':1,'assets':p['assets'],'palettes':p['palettes'],'collections':p['collections'],'banks':{k:b64(v) for k,v in p['banks'].items()}}

def validate(game,edits):
    p=project(game);banks={k:bytearray(v) for k,v in p['banks'].items()};allowed={k:set() for k in banks}
    for a in p['assets']:
        n=a['width']*a['height']*a['bpp']//8
        allowed[a['bank']].update(range(a['offset'],a['offset']+n))
    for pal in p['palettes']:allowed[pal['bank']].update(range(pal['offset'],pal['offset']+pal['size']))
    if not isinstance(edits,dict):raise ValueError('Invalid edits')
    for bank,changes in edits.items():
        if bank not in banks or not isinstance(changes,dict):raise ValueError('Unknown bank')
        for offset,value in changes.items():
            a=int(offset)
            if a not in allowed[bank] or type(value)!=int or not 0<=value<=255:raise ValueError('Edit outside known assets')
            banks[bank][a]=value
    return banks

def rle(data):
    out=bytearray();i=0
    while i<len(data):
        n=1
        while n<256 and i+n<len(data) and data[i+n]==data[i]:n+=1
        v=data[i]
        if v==0 and n>=2:out+=bytes([0xcf,n&255])
        elif v in (0xbf,0xcf) or n>=4:out+=bytes([0xbf,v,n&255])
        else:out+=bytes([v])*n
        i+=n
    return bytes(out)

def export_kult(banks):
    p=project('kult');old=p['banks']['ram'];new=banks['ram']
    if new==old:return p['original']
    streams=[bytearray(),bytearray()];phase=0
    for block in p['blocks']:
        a=block['start'];data=bytearray(block['data'])
        for i in range(len(data)):
            if new[a+i]!=old[a+i]:data[i]=new[a+i]
        streams[phase]+=struct.pack('<HH',a,len(data))+data
        if a==0xbb00:
            streams[0]+=bytes(4);phase=1
    streams[1]+=struct.pack('<HH',0x7fee,0xffff)
    result=bytearray(p['original'])
    for base,end,data in zip([0x2b00,0x8000],[0x7fee,0xb300],streams):
        encoded=rle(data)
        if len(encoded)>end-base:raise ValueError(f'Kult graphics exceed packed space by {len(encoded)-(end-base)} bytes. Simplify pixels or undo changes.')
        offset=6+base-0x2b00;result[offset:offset+len(encoded)]=encoded
    ram,_,_,_=kult(result)
    for a in range(65536):
        if new[a]!=old[a] and ram[a]!=new[a]:raise ValueError('Kult export failed depacker verification')
    # Compare every recovered block, not only edited positions.
    for block in p['blocks']:
        a=block['start']
        if a in (0xd301,0xbb00):continue
        if ram[a:a+block['size']]!=new[a:a+block['size']]:raise ValueError('Kult export changed unrelated runtime bytes')
    return bytes(result)

def patch_xex(data,old,new):
    result=bytearray(data)
    for p in parse(data)[0]:
        if p['kind']=='segment':
            a=p['address'];n=len(p['data']);off=p['offset']+4
            result[off:off+n]=new[a:a+n]
    return bytes(result)

def export_cetas(banks):
    p=project('cetas');changed={}
    if banks['game']!=p['banks']['game']:changed['E']=patch_xex(p['files']['E'],p['banks']['game'],banks['game'])
    for name,start in zip('ABCDF',[0x8010,0x2010,0x4010,0x6010,0xa010]):
        if banks[name]!=p['banks'][name]:
            # The resident loader accepts ordinary uncompressed load segments.
            changed[name]=struct.pack('<HH',start,start+len(banks[name])-1)+banks[name]
    if not changed:return p['original']
    disk=bytearray(p['original']);occupied={0,1,2,3,360,*range(361,369),720};entries={}
    for ix in range(64):
        off=16+360*128+ix*16;e=disk[off:off+16]
        if e[0]==0:break
        if not e[0]&64 or e[0]&128:continue
        name=(e[5:13].decode().strip()+'.'+e[13:16].decode().strip()).rstrip('.')
        chain=[];n=word(e,3)
        while n:
            chain.append(n);occupied.add(n);b=sector(disk,n);n=((b[-3]&3)<<8)|b[-2]
        entries[name]=(ix,off,chain)
    free=[n for n in range(4,720) if n not in occupied]
    for name,data in changed.items():
        ix,off,chain=entries[name];count=(len(data)+124)//125
        if count>len(chain):
            need=count-len(chain)
            if need>len(free):raise ValueError('Not enough free disk sectors')
            chain=chain+free[:need];free=free[need:]
        else:
            free+=chain[count:];chain=chain[:count]
        for i,n in enumerate(chain):
            chunk=data[i*125:(i+1)*125];nxt=chain[i+1] if i+1<count else 0
            block=chunk+bytes(125-len(chunk))+bytes([(ix<<2)|(nxt>>8),nxt&255,len(chunk)])
            disk[16+(n-1)*128:16+n*128]=block
        disk[off+1:off+5]=struct.pack('<HH',count,chain[0])
    vt=16+359*128;disk[vt+3:vt+5]=len(free).to_bytes(2,'little');disk[vt+10:vt+100]=bytes(90)
    for n in free:disk[vt+10+n//8]|=0x80>>(n%8)
    # Validate directory counts, IDs, chains and every file after allocation.
    actual={n.rstrip('.'):b for n,b,_,_ in files(disk)}
    if actual!={**p['files'],**changed}:raise ValueError('Disk verification failed')
    return bytes(disk)

def export(game,edits):
    banks=validate(game,edits)
    return export_kult(banks) if game=='kult' else export_cetas(banks)
