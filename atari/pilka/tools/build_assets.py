#!/usr/bin/env python3
from pathlib import Path
import struct
from PIL import Image
from preview_swos import PALETTE
ROOT=Path(__file__).resolve().parents[1]

def build():
 ram=(ROOT/'analysis/unpacked-64k.bin').read_bytes()
 pitch=(ROOT/'assets/swos/unpacked/SWCPICH1.MAP').read_bytes()
 offsets=struct.unpack('>2310I',pitch[:9240])
 pitch_pixels=bytearray(672*880)
 for cell,offset in enumerate(offsets):
  tile=pitch[9240+offset:9240+offset+128]
  for y in range(16):
   for x in range(16):
    v=sum(((tile[y*8+p*2+x//8]>>(7-x%8))&1)<<p for p in range(4))
    pitch_pixels[(cell//42*16+y)*672+cell%42*16+x]=v
 im=Image.frombytes('P',(672,880),bytes(pitch_pixels));im.putpalette(PALETTE+[0]*(768-len(PALETTE)))
 im.save(ROOT/'assets/swos/pitch.png')
 atlas=bytearray()
 # Glyph cells: colour*16384 + character*64. Dynamic VIC palette entries 0..2.
 for color in range(16):
  for char in range(256):
   for y,row in enumerate(ram[0xf000+char*8:0xf000+char*8+8]):
    for x in range(8):
     if color<8:v=16+color if row & (128>>x) else 3
     else:
      q=(row>>(6-(x//2)*2))&3
      v=(3,1,2,16+(color&7))[q]
     if color==9 and char<203 and v==3:
      v=48+pitch_pixels[(304+y)*672+208+x]
     atlas.append(v)
 # Deduplicate the atlas to reserve a clean background at $20000.
 unique={};packed=bytearray();addresses=[]
 for start in range(0,len(atlas),64):
  tile=bytes(atlas[start:start+64])
  if tile not in unique:
   unique[tile]=0x30000+len(packed);packed.extend(tile)
  addresses.append(unique[tile])
 assert len(packed)<=0x30000
 (ROOT/'gen/tiles.bin').write_bytes(packed)
 (ROOT/'gen/tile-addresses.bin').write_bytes(bytes((a>>shift)&255 for shift in (0,8,16) for a in addresses))
 # C64 player frames are 32+4*direction+phase, directions clockwise from
 # up (measured from movement in play); phase 0 stands, 1 and 3 are strides
 # (2 is unused). SWOS keeps three running frames per direction on 16x16
 # cells of CJCTEAM1: row 0 up, down, right, left; row 1 down-left,
 # down-right, up-left, up-right (sprites 227-250 in SWOS2/Data.c), cycled
 # as neutral, stride, neutral, other stride.
 swos_cell=[(0,0),(9,1),(6,0),(3,1),(3,0),(0,1),(9,0),(6,1)]
 sheet=Image.open(ROOT/'assets/swos/indexed/CJCTEAM1.png')
 spr=bytearray(65536)
 for team in range(2):
  for frame in range(32):
   col,row=swos_cell[frame//4];col+=(0,1,0,2)[frame%4]
   crop=sheet.crop((col*16,row*16,col*16+16,row*16+16))
   for y in range(16):
    for x in range(16):
     v=crop.getpixel((x,y))
     # The source sheet uses palette indices as kit masks, recolored at runtime in SWOS.
     v={10:10 if team==0 else 11,11:2,15:2,13:4}.get(v,v)
     if v:spr[(team*32+frame)*256+y*16+x]=32+v
 bits=(ROOT/'assets/swos/unpacked/CJCBITS.RAW').read_bytes()
 for y in range(8):
  for x in range(8):
   v=sum(((bits[(48+y)*160+p*40+x//8]>>(7-x%8))&1)<<p for p in range(4))
   spr[0xff00+y*8+x]=32+v if v else 0
 (ROOT/'gen/sprites.bin').write_bytes(spr)
 # Ball uses its own small opaque white shape, from the original C64 pointer later.
 return atlas,spr
if __name__=='__main__':build()
