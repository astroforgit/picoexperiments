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

# Displayed colour of each of the 16 C64 colours, as 12-bit Amiga RGB.
# Taken from the SWOS game palette (preview_swos.COLORS) wherever it has a
# counterpart; SWOS has no cyan and a single grey, so cyan and the two other
# greys are plain Amiga-style values.
AMIGA12=[0x000,0xfff,0xf00,0x0cc,0x702,0x250,0x00f,0xff0,
         0xa40,0x721,0xf71,0x444,0x666,0x380,0x88f,0x999]
SHOWN=[tuple(((c>>s)&15)*17 for s in (8,4,0)) for c in AMIGA12]

# Amiga-style dressing of the match graphics (pitch colour 9 only):
# - crowd characters: every lit pixel pair takes one of several colours;
# - the stand structure (multicolour 1, yellow on the C64) is shown grey;
# - pitch characters exist a second time with lighter grass (indices 5-7)
#   for the mowing stripes.
CROWD_CHARS=[3,4,5]+list(range(0xcc,0xd3))   # top stand, bottom stand
CROWD=[1,7,2,6,14,10,1,15,7,1]         # C64 colour numbers
STAND12=0x999                          # shown instead of yellow multicolour 1
LIGHT12=[0x370,0x260,0x480]            # lighter grass for shades 2,3,4
def striped(ch):                       # pitch characters; 1-7 are stand
 return ch==0 or 8<=ch<203
STRIPE_ROWS=4                          # stripe height in characters

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
      if color==9 and char in CROWD_CHARS and q in (1,3):
       u,w=x//2,y//2;v=FGI[CROWD[(char*7+u*5+w*3+u*w)%len(CROWD)]]
     atlas.append(v)
 unique={};packed=bytearray();addresses=[]
 for start in range(0,len(atlas),64):
  tile=bytes(atlas[start:start+64])
  if tile not in unique:
   unique[tile]=0x30000+len(packed);packed.extend(tile)
  addresses.append(unique[tile])
 assert len(packed)<=0x2f000,len(packed)
 (ROOT/'gen/tiles.bin').write_bytes(packed)
 # Colour 9 again with the lighter grass shades: character*64, VRAM $74000.
 (ROOT/'gen/tiles-light.bin').write_bytes(bytes(v+3 if 2<=v<=4 else v for v in atlas[9*16384:10*16384]))
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
