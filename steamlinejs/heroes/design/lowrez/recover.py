"""Recover local Heroes of Lowrez v4 resources to /tmp/lowrez-extracted.
Requires system liblz4. Does not execute recovered Lua.
Format reference: Defold 1.2.170 resource_archive.cpp and dlib/crypt.cpp.
"""
import struct,pathlib,ctypes,ctypes.util
p=pathlib.Path(__file__).resolve().parents[2]; b=(p/'game.arci0').read_bytes(); d=(p/'game.arcd0').read_bytes()+(p/'game.arcd1').read_bytes()
out=pathlib.Path('/tmp/lowrez-extracted');out.mkdir(exist_ok=True)
k=struct.unpack('>4I',b'aQj8CScgNP4VsfXK');mask=0xffffffff
lib=ctypes.CDLL(ctypes.util.find_library('lz4'))
def decrypt(data):
 result=bytearray(data)
 for pos in range(0,len(data),8):
  a=0;c=pos//8;s=0
  for _ in range(32):
   a=(a+((((c<<4)^(c>>5))+c)^(s+k[s&3])))&mask
   s=(s+0x9e3779b9)&mask
   c=(c+((((a<<4)^(a>>5))+a)^(s+k[(s>>11)&3])))&mask
  for j,v in enumerate(struct.pack('>2I',a,c)[:len(data)-pos]):result[pos+j]^=v
 return bytes(result)
for i in range(133):
 offset,size,compressed,flags=struct.unpack_from('>4I',b,8560+16*i)
 data=d[offset:offset+(size if compressed==mask else compressed)]
 if flags&1:data=decrypt(data)
 if compressed!=mask:
  buf=ctypes.create_string_buffer(size);n=lib.LZ4_decompress_safe(data,buf,len(data),size);assert n==size,(i,n,size);data=buf.raw
 (out/f'{i:03}.bin').write_bytes(data)
 if flags&1:print(i,len(data),repr(data[:160]))
def varint(data,pos):
 n=0;shift=0
 while True:
  v=data[pos];pos+=1;n|=(v&127)<<shift
  if v<128:return n,pos
  shift+=7
def fields(data):
 pos=0;result={}
 while pos<len(data):
  tag,pos=varint(data,pos);wire=tag&7
  if wire==2:
   size,pos=varint(data,pos);v=data[pos:pos+size];pos+=size
  elif wire==0:v,pos=varint(data,pos)
  elif wire in (1,5):size={1:8,5:4}[wire];v=data[pos:pos+size];pos+=size
  else:raise ValueError(wire)
  result.setdefault(tag>>3,[]).append(v)
 return result
for i in range(133):
 if struct.unpack_from('>4I',b,8560+16*i)[3]&1:
  f=fields(fields((out/f'{i:03}.bin').read_bytes())[1][0]);print(i,[(k,repr(v)[:100]) for k,v in f.items() if k!=1]);(out/f'{i:03}.lua').write_bytes(f[1][0])
