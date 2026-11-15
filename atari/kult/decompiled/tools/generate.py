#!/usr/bin/env python3
"""Regenerate recovered source and provenance from the two untouched inputs."""
import hashlib,json
from pathlib import Path
from archive import generate,parse
from atr import files,sector
from recover import kult,cetas_resource,load
from source import emit
import symbols as S
ROOT=Path(__file__).resolve().parents[1]
def sha(b):return hashlib.sha256(b).hexdigest()
def savejson(path,x):path.write_text(json.dumps(x,indent=2)+'\n')
def main():
    src=ROOT.parent
    packed=(src/'Kult (v1).xex').read_bytes();disk=(src/'CETAS (WIP).ATR').read_bytes()
    meta={'originals':{'Kult (v1).xex':sha(packed),'CETAS (WIP).ATR':sha(disk)},'kult':{},'cetas':{}}
    k=ROOT/'kult';c=ROOT/'cetas';k.mkdir(exist_ok=True);(c/'files').mkdir(parents=True,exist_ok=True)
    generate(src/'Kult (v1).xex',k,'Kult packed archive: exact original-file source')
    (k/'game.asm').replace(k/'packed.asm')
    ram,spans,blocks,steps=kult(packed)
    (k/'memory.bin').write_bytes(ram)
    report=emit(k/'kult.asm',ram,spans,S.KULT_SEEDS,S.KULT_NAMES,S.KULT_COMMENTS,'Kult: recovered runtime')
    report.update(decoder_instructions=steps,sha256=sha(b''.join(ram[lo:hi] for lo,hi in spans)),blocks=[{'start':b['start'],'size':b['size'],'sha256':sha(b['data'])} for b in blocks])
    meta['kult']=report
    # Disk skeleton retains metadata, sector trailers, padding and unallocated sectors.
    skeleton=bytearray(disk);entries=[]
    for name,data,start,count in files(disk):
        name=name.rstrip('.');(c/'files'/name).write_bytes(data);chain=[];n=start;pos=0
        while n:
            b=sector(disk,n);used=b[-1];off=16+(n-1)*128
            chain.append({'sector':n,'offset':off,'used':used})
            skeleton[off:off+used]=bytes(used);pos+=used;n=((b[-3]&3)<<8)|b[-2]
        if pos!=len(data):raise ValueError('sector chain mismatch')
        entries.append({'name':name,'size':len(data),'sha256':sha(data),'chain':chain})
    (c/'disk-layout.bin').write_bytes(skeleton)
    meta['cetas']['files']=entries
    loader=(c/'files/AUTO').read_bytes()
    generate(c/'files/AUTO',c/'loader','CETAS resident disk loader and setup')
    # Every executable byte is represented in the enhanced runtime source.
    for name,stem,seeds,names,comments in [('E','cetas',S.CETAS_SEEDS,S.CETAS_NAMES,S.CETAS_COMMENTS),('XAUTORUN','intro',S.INTRO_SEEDS,S.INTRO_NAMES,S.INTRO_COMMENTS)]:
        data=(c/'files'/name).read_bytes();ram,spans=load(data)
        report=emit(c/(stem+'.asm'),ram,spans,seeds,names,comments,'CETAS '+stem)
        report['sha256']=sha(b''.join(ram[lo:hi] for lo,hi in spans))
        report['file']=name
        report['parts']=[{'kind':p['kind'],'offset':p['offset'],'address':p.get('address'),'size':len(p['data']),'literal':p['data'].hex() if p['kind']!='segment' else None} for p in parse(data)[0]]
        meta['cetas'][stem]=report
        (c/(stem+'-memory.bin')).write_bytes(ram)
    resources=[]
    for name in 'ABCDF':
        a,b,n=cetas_resource(loader,(c/'files'/name).read_bytes());mem=bytearray(65536);mem[a:a+len(b)]=b
        emit(c/(name.lower()+'-unpacked.asm'),mem,[(a,a+len(b))],[],title='CETAS resource '+name+' (unpacked data)')
        (c/(name.lower()+'-unpacked.bin')).write_bytes(b)
        # Preserve packed token streams as editable assembler data too.
        emit(c/(name.lower()+'-packed.asm'),(c/'files'/name).read_bytes(),[(0,len((c/'files'/name).read_bytes()))],[],title='CETAS resource '+name+' (original compression tokens)')
        resources.append({'name':name,'start':a,'size':len(b),'sha256':sha(b),'decoder_instructions':n})
    meta['cetas']['resources']=resources
    ram=bytearray(65536);ram[0x7c4:0x944]=disk[16:400]
    meta['cetas']['boot']=emit(c/'boot.asm',ram,[(0x7c4,0x944)],[0x7ca,0x862],{0x7ca:'BootEntry',0x862:'BootInit'},title='CETAS boot sectors (header included)')
    meta['cetas']['boot']['sha256']=sha(disk[16:400])
    savejson(ROOT/'analysis.json',meta)
    print('Recovered Kult and CETAS sources; see analysis.json for coverage and unresolved paths.')
if __name__=='__main__':main()
