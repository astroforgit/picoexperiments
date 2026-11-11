"""Extract verified crowd parameters from the supplied R90 XEX, without importing its engine."""
import hashlib,json,struct
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=ROOT/'alter/Atari_Soccer_VBXE_R90.xex'
b=p.read_bytes();v=bytearray(512*1024);bank=0;i=0
while i<len(b):
    a=struct.unpack_from('<H',b,i)[0];i+=2
    if a==65535:continue
    end=struct.unpack_from('<H',b,i)[0];i+=2
    data=b[i:i+end-a+1];i+=len(data)
    if a==0x6f0:bank=data[0]
    if a==0x8000 and len(data)==16384:v[bank*16384:(bank+1)*16384]=data
code=v[0x6aec0:0x6af42]
assert bytes.fromhex('8d02d2') in code and bytes.fromhex('09808d03d2') in code
parameters={}
for name,offset in [('idle',0x6aecb),('attack',0x6aef8),('goal',0x6aef2),('celebration',0x6aeec)]:
    assert v[offset]==0xa2 and v[offset+2]==0xa0
    parameters[name]={'volume':v[offset+1],'frequency':v[offset+3]}
result={'source':str(p.relative_to(ROOT)),'sha256':hashlib.sha256(b).hexdigest(),
        'routine_vram':'0x6aec0','distortion':128,'parameters':parameters,
        'notes':'R90 ramps volume one step every four ticks, frequency one step per tick.'}
(ROOT/'assets/sound/alter-crowd.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(parameters))
