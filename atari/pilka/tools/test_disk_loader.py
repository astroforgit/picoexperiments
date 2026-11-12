#!/usr/bin/env python3
"""Execute upstream FujiNet PicoBoot with sector reads supplied by a mock SIO.
The actual 6502 file parser and every game INIT run; OS/SIO timing is not modeled.
"""
import argparse, hashlib, json, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
SOURCE='https://raw.githubusercontent.com/FujiNetWIFI/fujinet-firmware/dbbb36d7d310f85e83248524471cc1731d6f5209/data/webui/device_specific/BUILD_ATARI/picoboot.bin'
SHA256='6850ad99d911556fd640e1aca846ec6847218ffc9baf71aab4457e42bf0a5f99'
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--picoboot',type=Path,required=True,help='Upstream 384-byte picoboot.bin; source URL is in this script')
args=p.parse_args()
pb=args.picoboot.read_bytes()
assert hashlib.sha256(pb).hexdigest()==SHA256, 'Unexpected PicoBoot version'
boot=load_labels(ROOT/'gen/boot.asm.lab')
expected=Atari(ROOT/'pilka.xex');expected.boot()

def run(page=0xd6,sector_size=256,duplicate=False):
    a=Atari(ROOT/'pilka.xex',vbxe_page=page);m=a.mem.ram;c=a.cpu
    if duplicate:a.xex=b'\xff\xff'+a.xex
    loader=bytearray(pb);loader[0]=0 if sector_size==256 else 0x80
    m[0x800:0x980]=loader
    m[0x300:0x30c]=bytes([0x31,1,0x52,0x40,0,7,7,0,0x80,0,1,0])
    m[0x58:0x5a]=bytes([0,0x9c]);c.pc=0x806;c.sp=0xff
    reads=[];uploads=0
    for steps in range(10_000_000):
        if c.pc==boot['STARTER']:
            assert not duplicate
            assert bytes(a.vram)==bytes(expected.vram), 'Sector loading changed VRAM payloads'
            return dict(page=hex(page),sector_size=sector_size,reads=len(reads),uploads=uploads,result='RUN reached; VRAM identical')
        if c.pc!=0xe459 and a.mem[c.pc]==0:
            assert duplicate, f'Unexpected BRK at ${c.pc:04x}'
            assert len([s for s in reads if s>=369])<=2, (hex(c.pc),reads)
            return dict(result='Duplicate header reproduces BRK within the first two XEX sectors',pc=hex(c.pc),sectors=reads)
        assert c.pc!=boot['MSG_H'], 'VBXE detection failed'
        if c.pc==boot['UPLOAD']:uploads+=1
        if c.pc==0xe459:
            assert m[0x302]==0x52, 'Expected SIO read'
            sec=m[0x30a]|m[0x30b]<<8;reads.append(sec)
            data=bytearray(sector_size);capacity=sector_size-3
            if sec==361:
                data[0]=0x46;data[3:5]=(369).to_bytes(2,'little');data[5:16]=b'AUTORUN    '
            else:
                assert sec>=369
                offset=(sec-369)*capacity;chunk=a.xex[offset:offset+capacity]
                data[:len(chunk)]=chunk;data[-1]=len(chunk)
                if len(chunk)==capacity:data[-3]=(sec+1)>>8;data[-2]=(sec+1)&255
            dest=m[0x304]|m[0x305]<<8;m[dest:dest+sector_size]=data
            c.y=1;m[0x303]=1;c.p&=~0x80;c.pc=(c.stPopWord()+1)&65535
        else:c.step()
    raise AssertionError(f'Loader timeout at ${c.pc:04x}')

results=[run(duplicate=True)]
print(results[0],flush=True)
for size in (256,128):
    for page in (0xd6,0xd7):
        results.append(run(page,size));print(results[-1],flush=True)
(ROOT/'analysis/disk-loader-test.json').write_text(json.dumps(dict(picoboot_source=SOURCE,picoboot_sha256=SHA256,xex_sha256=hashlib.sha256((ROOT/'pilka.xex').read_bytes()).hexdigest(),results=results,limitations='Mock SIO reads; not a physical FujiNet/SD or OS timing test'),indent=2)+'\n')
print('PASS: old failure reproduced; single/double-density sector loaders deliver every upload on both VBXE pages')
