#!/usr/bin/env python3
"""Extract this SAP's original player; relocate RMT data and OS-overlapping RAM.

Uses legal NMOS 6502 instruction lengths for operand relocation. Source untouched.
"""
from pathlib import Path
import hashlib

LENGTHS = ('1200022012100330220002201300033032002220121033302200022013000330'
           '1200022012103330220002201300033012000220121033302200022013000330'
           '0200222010103330220022201310030022202220121033302200222013103330'
           '2200222012103330220002201300033022002220121033302200022013000330')

ROOT = Path(__file__).resolve().parents[1]

def extract():
    raw = (ROOT.parent/'Double_Dragon_Industrial_A.sap').read_bytes()
    assert hashlib.sha256(raw).hexdigest() == '6efbd912935788f1babe3dfc002fd567fed5cf0d121854d3b90122dc0f693360', 'SAP changed: re-audit relocation'
    end = raw.index(b'\xff\xff')
    header = raw[:end].decode('ascii')
    for tag in ('TYPE B', 'NTSC', 'FASTPLAY 262', 'INIT 0C80', 'PLAYER 0603'):
        assert tag in header, f'Unsupported SAP: missing {tag}'
    blocks = {}; p = end+2
    while p < len(raw):
        start = int.from_bytes(raw[p:p+2], 'little')
        stop = int.from_bytes(raw[p+2:p+4], 'little'); p += 4
        size = stop-start+1
        assert size > 0 and p+size <= len(raw)
        blocks[start] = bytearray(raw[p:p+size]); p += size
    assert {k:len(v) for k,v in blocks.items()} == {0x4000:0x12af,0xc80:9,0x390:0x7d1}
    rmt = (ROOT.parent/'Double_Dragon_Industrial_A.rmt').read_bytes()
    assert rmt[:6] == bytes.fromhex('ffff0040ae52'), 'Unsupported RMT load range'
    assert rmt[6:] == blocks[0x4000], 'RMT differs: re-audit player compatibility'
    blocks[0x4000] = bytearray(rmt[6:])
    return blocks

def relocated(blocks):
    data = bytearray(blocks[0x4000]); assert data[:4] == b'RMT4'
    delta = 0x6400  # $4000 -> $a400; player variables use $a280-$a38f.
    word = lambda p: int.from_bytes(data[p:p+2], 'little')
    inst, lo, hi, song = [word(p)-0x4000 for p in (8,10,12,14)]
    def pointer(p):
        value = word(p)
        if value:
            assert 0x4000 <= value <= 0x52ae
            data[p:p+2] = (value+delta).to_bytes(2,'little')
    for p in range(inst,lo,2): pointer(p)
    for p in range(hi-lo):
        value = data[lo+p] | data[hi+p]<<8
        if value:
            assert 0x4000 <= value <= 0x52ae
            value += delta
            data[lo+p], data[hi+p] = value&255, value>>8
    for p in range(song,len(data),4):
        if data[p] == 0xfe: pointer(p+2)  # RMT song jump
    for p in (8,10,12,14): pointer(p)
    player = bytearray(blocks[0x390])
    pc = 0x600
    while pc < 0xb61:
        pos = pc-0x390
        size = int(LENGTHS[player[pos]])
        assert size, f'Unexpected opcode at {pc:04x}'
        if size == 3:
            operand = player[pos+1] | player[pos+2]<<8
            if 0x27f <= operand < 0x390:
                pos = pc+1-0x390
                player[pos:pos+2] = (operand+0xa000).to_bytes(2,'little')
        pc += size
    assert pc == 0xb61
    return {0x390:player,0xa400:data}

if __name__ == '__main__':
    lines = ['; Music from Double_Dragon_Industrial_A.rmt; matching SAP player.']
    for address,data in relocated(extract()).items():
        lines.append(f'        org ${address:04x}')
        for p in range(0,len(data),16):
            lines.append('        dta '+','.join(f'${v:02x}' for v in data[p:p+16]))
    (ROOT/'generated/music-data.asm').write_text('\n'.join(lines)+'\n')
    print('SAP: original mono player, relocated module $a400-$b6ae, private state $a280')
