#!/usr/bin/env python3
"""Assemble edited sources, reconstruct containers, and compare every byte."""
import json,os,subprocess,hashlib
from pathlib import Path
from recover import kult,cetas_resource
ROOT=Path(__file__).resolve().parents[1]
def sha(b):return hashlib.sha256(b).hexdigest()
def assemble(source,dest):
    subprocess.run([os.environ.get('MADS','mads'),str(source),'-o:'+str(dest),'-l:'+str(dest.with_suffix('.lst'))],check=True,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    return dest.read_bytes()
def check(data,expected,description):
    if sha(data)!=expected:raise ValueError(description+' differs from reference SHA-256')
    print('OK:',description,len(data),'bytes')
def executable(raw,report):
    out=bytearray();pos=0
    for p in report['parts']:
        if len(out)!=p['offset']:raise ValueError('container layout changed')
        if p['kind']=='segment':
            a=p['address'];size=p['size'];out+=a.to_bytes(2,'little')+(a+size-1).to_bytes(2,'little')+raw[pos:pos+size];pos+=size
        else:out+=bytes.fromhex(p['literal'])
    if pos!=len(raw):raise ValueError('unexpected assembled size')
    return bytes(out)
def main():
    meta=json.loads((ROOT/'analysis.json').read_text());k=ROOT/'kult';c=ROOT/'cetas'
    packed=assemble(k/'packed.asm',k/'kult-packed.xex');check(packed,meta['originals']['Kult (v1).xex'],'Kult packed XEX')
    runtime=assemble(k/'kult.asm',k/'kult.bin');check(runtime,meta['kult']['sha256'],'Kult recovered runtime')
    ram,spans,_,_=kult(packed)
    if runtime!=b''.join(ram[a:b] for a,b in spans):raise ValueError('Kult decoder replay differs')
    # Disk source files are rebuilt independently of the input ATR.
    rebuilt={'AUTO':assemble(c/'loader/game.asm',c/'loader/auto.xex')}
    for stem in ('cetas','intro'):
        raw=assemble(c/(stem+'.asm'),c/(stem+'.bin'));report=meta['cetas'][stem]
        check(raw,report['sha256'],'CETAS '+stem+' runtime');rebuilt[report['file']]=executable(raw,report)
        (c/(stem+'.xex')).write_bytes(rebuilt[report['file']])
    for r in meta['cetas']['resources']:
        name=r['name'];stem=name.lower()
        rebuilt[name]=assemble(c/(stem+'-packed.asm'),c/(stem+'-packed.bin'))
        raw=assemble(c/(stem+'-unpacked.asm'),c/(stem+'-unpacked.bin'));check(raw,r['sha256'],'CETAS resource '+name)
        a,replayed,_=cetas_resource(rebuilt['AUTO'],rebuilt[name])
        if a!=r['start'] or replayed!=raw:raise ValueError('CETAS resource decoder replay differs')
    boot=assemble(c/'boot.asm',c/'boot.bin');check(boot,meta['cetas']['boot']['sha256'],'CETAS boot sectors')
    disk=bytearray((c/'disk-layout.bin').read_bytes());disk[16:400]=boot
    for entry in meta['cetas']['files']:
        data=rebuilt[entry['name']];check(data,entry['sha256'],'CETAS file '+entry['name']);pos=0
        for link in entry['chain']:
            size=link['used'];off=link['offset'];disk[off:off+size]=data[pos:pos+size];pos+=size
        if pos!=len(data):raise ValueError('file size does not match disk chain')
    (c/'cetas.atr').write_bytes(disk);check(disk,meta['originals']['CETAS (WIP).ATR'],'CETAS complete ATR')
    for name,expected in meta['originals'].items():check((ROOT.parent/name).read_bytes(),expected,'untouched input '+name)
    (ROOT/'verification.json').write_text(json.dumps({'status':'passed','checks':['MADS source assembly','original-file SHA-256 equality','Kult CPU depacker replay','CETAS CPU depacker replay with bounded input and backreferences','all eight DOS files','complete ATR including unused bytes'],'emulator_gameplay_tested':False,'originals':meta['originals']},indent=2)+'\n')
if __name__=='__main__':
    try:main()
    except subprocess.CalledProcessError as e:
        print(e.output.decode(errors='replace'));raise
