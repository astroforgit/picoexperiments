#!/usr/bin/env python3
"""Tile atlas, tile lookup tables and sprite images for the VBXE renderer.

Palette index layout of the character layer (see README):
  1        multicolour 1 ($D022)                        background class
  2,3,4    background colour ($D021), three shades      background class
  $08      multicolour 2 ($D023)                        foreground class
  FGI[c]   character colour c (bits 0-2 always clear)   foreground class
Foreground indices have no bit in $07 and background indices no bit in
$F8, so a transparent blit with AND mask $F8 copies exactly the pixels a
C64 sprite with "behind foreground" priority is hidden by.
"""
from pathlib import Path
import struct
from PIL import Image
from preview_swos import PALETTE
ROOT=Path(__file__).resolve().parents[1]

# Foreground ids (index = id*8). 4, 8, 12 and 13 are skipped: $20, $40 and
# $60-$6F are the sprite colours of the framebuffers.
FG_IDS=[2,3,5,6,7,9,10,11,14,15,16,17,18,19,20,21]
FGI=[i<<3 for i in FG_IDS]
BG1=1
BG2=8
SHADE={0:2,7:3,9:4}          # SWOS palette entry -> background shade index
GRASS_AT=(304,208)           # 8x8 grass cell in the decoded SWOS pitch

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
 gy,gx=GRASS_AT
 grass=[[SHADE[pitch_pixels[(gy+y)*672+gx+x]] for x in range(8)] for y in range(8)]
 atlas=bytearray()
 # Glyph cells: colour*16384 + character*64. Every background-colour pixel
 # takes the grass shade of its position, so the whole picture shares one
 # seamless background (the palette turns the shades into grass or into
 # the plain C64 background colour).
 for color in range(16):
  for char in range(256):
   for y,row in enumerate(ram[0xf000+char*8:0xf000+char*8+8]):
    for x in range(8):
     if color<8:v=FGI[color] if row & (128>>x) else grass[y][x]
     else:
      q=(row>>(6-(x//2)*2))&3
      v=(grass[y][x],BG1,BG2,FGI[color&7])[q]
     atlas.append(v)
 unique={};packed=bytearray();addresses=[]
 for start in range(0,len(atlas),64):
  tile=bytes(atlas[start:start+64])
  if tile not in unique:
   unique[tile]=0x30000+len(packed);packed.extend(tile)
  addresses.append(unique[tile])
 assert len(packed)<=0x2f000,len(packed)
 (ROOT/'gen/tiles.bin').write_bytes(packed)
 # Two bytes per (colour, character): address bits 8-15, then
 # (bank << 2) | (address bits 6-7).
 (ROOT/'gen/tile-map.bin').write_bytes(bytes((a>>8)&255 for a in addresses)+bytes(((a>>16)<<2)|((a&255)>>6) for a in addresses))
 # Original C64 multicolour sprites, frames 32-127 (players, goalkeepers,
 # tackles, falls, ball) from VIC bank $C000: 24x21 bytes per 512-byte slot.
 # Pixel pairs 01/10/11 become $40 (multicolour 0), $FF (sprite colour,
 # AND-masked to $60+colour by the runtime) and $20 (multicolour 1).
 spr=bytearray(65536)
 for frame in range(32,128):
  base=0xc000+frame*64;slot=(frame-32)*512
  for y in range(21):
   for x in range(12):
    q=(ram[base+y*3+x//4]>>(6-(x%4)*2))&3
    spr[slot+y*24+2*x]=spr[slot+y*24+2*x+1]=(0,0x40,0xff,0x20)[q]
 (ROOT/'gen/sprites.bin').write_bytes(spr)
 return atlas,spr
if __name__=='__main__':build()
