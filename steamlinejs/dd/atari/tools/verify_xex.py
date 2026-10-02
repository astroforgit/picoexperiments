#!/usr/bin/env python3
"""Fail builds that load onto the stack, OS workspace, hardware, or low DOS RAM."""
from collections import Counter
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
labels={p[2].lower():int(p[1],16) for line in (ROOT/'generated/double-dragon-vbxe.lab').read_text().splitlines() if len(p:=line.split())==3}
data=(ROOT/'double-dragon-vbxe.xex').read_bytes()
p=0; spans=Counter(); inits=[]; run=None
assert data[:2]==b'\xff\xff', 'Missing XEX header'
while p<len(data):
    assert p+2<=len(data), 'Truncated segment header'
    start=int.from_bytes(data[p:p+2],'little');p+=2
    if start==65535: continue
    assert p+2<=len(data), 'Truncated segment end'
    end=int.from_bytes(data[p:p+2],'little');p+=2
    size=end-start+1
    assert size>0 and p+size<=len(data), 'Invalid segment length'
    chunk=data[p:p+size];p+=size
    if (start,end)==(0x2e2,0x2e3): inits.append(int.from_bytes(chunk,'little'))
    elif (start,end)==(0x2e0,0x2e1): run=int.from_bytes(chunk,'little')
    else:
        assert 0x3000<=start<=end<0xa000, f'Unsafe payload ${start:04X}-${end:04X}'
        assert (0x3000<=start<=end<0x8000 or (start,end)==(0x8000,0x8fff) or 0x9000<=start<=end<0x9100), 'Segment overlaps reserved regions'
    spans[start,end]+=1
assert run==labels['main']==0x3000
assert labels['upload_bank']==0x9000
assert inits==[labels['upload_bank']]*97+[labels['prepare_runtime']], 'Incorrect multi-INIT load sequence'
assert spans[0x8000,0x8fff]==97
report='\n'.join(f'${s:04X}-${e:04X}: {n} segment(s)' for (s,e),n in spans.items())
report+='\nPASS: payload >= $3000; no stack/zero-page load; 97 uploads followed by runtime preparation.\n'
(ROOT/'generated/xex-layout.txt').write_text(report)
print(report,end='')
