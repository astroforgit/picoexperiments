#!/usr/bin/env python3
"""Pack all 32 original CHR sets for the native VBXE tile-cache backend.

Packets: 0..127 -> length+1 literals; 128..255 -> (control&127)+1
copies of the following byte. Each independently decoded set is 4096 bytes
of NES two-plane tile data. There is no sentinel value or truncated packet.
"""
from pathlib import Path
import hashlib
import json
from make_assets import raw
from build_source_engine import OUT


def pack(data):
    result = bytearray()
    cursor = 0
    while cursor < len(data):
        end = cursor+1
        while end < len(data) and end-cursor < 128 and data[end] == data[cursor]:
            end += 1
        if end-cursor >= 3:
            result.extend((0x80 | (end-cursor-1), data[cursor]))
            cursor = end
            continue
        start = cursor
        cursor = end
        while cursor < len(data) and cursor-start < 128:
            if cursor+2 < len(data) and data[cursor] == data[cursor+1] == data[cursor+2]:
                break
            cursor += 1
        result.append(cursor-start-1)
        result.extend(data[start:cursor])
    return bytes(result)


def unpack(data, length):
    result = bytearray()
    cursor = 0
    while len(result) < length:
        if cursor >= len(data): raise ValueError('truncated control')
        control = data[cursor]
        cursor += 1
        size = (control & 127)+1
        if len(result)+size > length: raise ValueError('packet exceeds output size')
        if control & 128:
            if cursor >= len(data): raise ValueError('truncated run')
            result.extend([data[cursor]]*size)
            cursor += 1
        else:
            if cursor+size > len(data): raise ValueError('truncated literals')
            result.extend(data[cursor:cursor+size])
            cursor += size
    if cursor != len(data): raise ValueError('trailing data')
    return bytes(result)


def sets():
    for bank in range(8):
        snes = raw(f'chrom-tiles-{bank}.asm')
        if len(snes) != 32768: raise ValueError(f'CHR bank {bank}: wrong size')
        for quadrant in range(4):
            nes = bytearray()
            for index in range(256):
                tile = snes[quadrant*8192+index*32:quadrant*8192+(index+1)*32]
                if any(tile[16:]): raise ValueError('CHR uses more than the original two bitplanes')
                nes.extend(tile[0:16:2])
                nes.extend(tile[1:16:2])
            yield bytes(nes)


def build():
    OUT.mkdir(parents=True, exist_ok=True)
    payload = bytearray()
    records = []
    for index, data in enumerate(sets()):
        compressed = pack(data)
        if unpack(compressed, 4096) != data: raise ValueError('roundtrip mismatch')
        records.append({'set': index, 'offset': len(payload), 'size': len(compressed),
                        'sha256': hashlib.sha256(data).hexdigest()})
        payload.extend(compressed)
    (OUT / 'chr-packed.bin').write_bytes(payload)
    (OUT / 'chr-packed.json').write_text(json.dumps(records, indent=2)+'\n')
    print(f'All 32 CHR sets: 131072 -> {len(payload)} bytes, lossless.')


if __name__ == '__main__':
    build()
