"""DOS 2 sector-chain reader; validates file IDs, lengths and cycles."""
import struct
def sector(d,n):
 size=int.from_bytes(d[4:6],'little');off=16+(n-1)*128 if n<=3 else 16+384+(n-4)*size
 b=d[off:off+(128 if n<=3 else size)]
 if len(b)!=(128 if n<=3 else size):raise ValueError('sector out of range')
 return b
def files(d):
 for ix in range(64):
  e=sector(d,361+ix//8)[ix%8*16:ix%8*16+16]
  if e[0]==0:break
  if e[0]&128:continue
  if not e[0]&64:raise ValueError(('flags',e))
  count,start=struct.unpack('<HH',e[1:5]);n=start;seen=set();out=bytearray()
  while n:
   if n in seen:raise ValueError('cycle')
   seen.add(n);b=sector(d,n)
   if b[-1]>len(b)-3:raise ValueError('size')
   if b[-3]>>2 != ix:raise ValueError(('file id',ix,n,b[-3]))
   out+=b[:b[-1]];n=((b[-3]&3)<<8)|b[-2]
  if len(seen)!=count:raise ValueError(('count',count,len(seen)))
  yield e[5:13].decode('ascii').strip()+'.'+e[13:16].decode('ascii').strip(),bytes(out),start,count
