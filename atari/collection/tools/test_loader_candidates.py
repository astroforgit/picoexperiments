"""Regression for three real Rescue loader streams and unknown-register safety."""
from pathlib import Path
from disasm import parse
from recover_common import candidates
ROOT=Path(__file__).resolve().parents[1]
ram=bytearray(65536);loaded=set()
for part in parse((ROOT/'games/rescue-on-fractalus/original.xex').read_bytes())[0]:
    if part['kind']!='segment':continue
    lo=part['address'];data=part['data'];ram[lo:lo+len(data)]=data;loaded.update(range(lo,lo+len(data)))
    if lo==0x2e2:break
found=dict(candidates(ram,loaded,0x2a3b))
assert {0x2000,0x3b00,0x6093} <= found.keys()
assert 0x2aa6 in found[0x3b00] and 0x2aad in found[0x6093] and 0x2ab4 in found[0x2000]
# Replace INX after LDX #$FF with TSX: SP is not known, so that source must
# no longer be inferred. Adjacent explicit argument and tail calls still work.
ram[0x2a9a]=0xba
found=dict(candidates(ram,loaded,0x2a3b))
assert 0x3b00 not in found and {0x2000,0x6093} <= found.keys()
print('INIT constants, adjacent arguments, tail calls and unknown register rejection: PASS')
