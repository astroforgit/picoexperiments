#!/usr/bin/env python3
"""Convert five generated pictures and the poem to an indexed VBXE slideshow."""
import json,re,base64
from pathlib import Path
from PIL import Image,ImageOps
ROOT=Path(__file__).resolve().parent
D=ROOT/'data';G=ROOT/'gen';D.mkdir(exist_ok=True);G.mkdir(exist_ok=True)
W,H,PANEL=256,160,48
font=json.loads((ROOT/'assets/font.json').read_text())
images=[ImageOps.fit(Image.open(ROOT/f'assets/scene-{i+1}.png').convert('RGB'),(W,H),method=Image.Resampling.LANCZOS)for i in range(5)]
montage=Image.new('RGB',(W,H*5))
for i,im in enumerate(images):montage.paste(im,(0,i*H))
shared=montage.quantize(colors=252,method=Image.Quantize.MEDIANCUT)
palette=[0,0,0, 13,17,30, 255,235,195, 70,46,61]+shared.getpalette()[:252*3]
vram=bytearray(0x7f000);meta=[]
def indexed(im):
 q=im.quantize(palette=shared,dither=Image.Dither.NONE)
 b=bytes(n+4 for n in q.tobytes());p=Image.frombytes('P',im.size,b);p.putpalette(palette);return p,b
def enc(s):return ''.join('^'+c.lower()if c.isupper()else c for c in s.replace('„','"').replace('”','"'))
def keys(s):return [k if k.startswith('^')else k+' 'for k in re.findall(r'\^.|[^\^]',s)]
def width(s):return sum(font[k]['width']*2 for k in keys(s))
def wrap(verses):
 rows=[]
 for verse in verses:
  row=''
  for word in enc(verse).split():
   trial=(row+' '+word).strip()
   if row and width(trial)>244:rows.append(row);row=word
   else:row=trial
  rows.append(row)
 return rows
def text_bitmap(rows):
 im=Image.new('P',(W,PANEL*2+len(rows)*14),1);im.putpalette(palette)
 for j,row in enumerate(rows):
  x=6;y=PANEL+j*14
  for k in keys(row):
   glyph=font[k]
   for dy in [1,0]:
    for i,on in enumerate(glyph['pixels']):
     if on:
      for xx in range(2):
       for yy in range(2):im.putpixel((x+(i%3)*2+xx,y+(i//3)*2+yy+dy),3 if dy else 2)
   x+=glyph['width']*2
 return im
poem=(ROOT/'poem.txt').read_text().splitlines();cuts=[0,4,8,12,18,len(poem)]
text_base=5*W*H
for i,im in enumerate(images):
 pic,pixels=indexed(im);image_base=i*W*H;vram[image_base:image_base+len(pixels)]=pixels
 rows=wrap(poem[cuts[i]:cuts[i+1]]);text=text_bitmap(rows);raw=text.tobytes();end=text_base+len(raw)
 if end>0x7e000:raise ValueError('Slideshow exceeds VRAM: shorten text or reduce font size')
 vram[text_base:end]=raw
 # SR narrow: 16 top border lines, 160 picture lines, 48 scrolling text lines.
 xdl=bytes([0x24,0x08,15,0x10,0xff,0x62,0,159,image_base&255,(image_base>>8)&255,image_base>>16,0,1,0x62,0x80,47,text_base&255,(text_base>>8)&255,text_base>>16,0,1])
 vram[0x7e000+i*32:0x7e000+i*32+len(xdl)]=xdl
 pic.save(D/f'scene-{i+1}.png');text.save(D/f'text-{i+1}.png')
 meta.append({'scene':i+1,'image_base':image_base,'text_base':text_base,'rows':rows,'scroll_end':text.height-PANEL,'text_height':text.height})
 text_base=end
(D/'vram.bin').write_bytes(vram)
(D/'manifest.json').write_text(json.dumps({'width':W,'image_height':H,'panel_height':PANEL,'used_vram':text_base,'scenes':meta},ensure_ascii=False,indent=2)+'\n')
parts=[]
for c in range(3):parts.append('palette_'+str(c)+' dta '+','.join(str(palette[i+c])for i in range(0,768,3)))
for key,values in [('text_mid',[(m['text_base']>>8)&255 for m in meta]),('text_hi',[m['text_base']>>16 for m in meta]),('scroll_lo',[m['scroll_end']&255 for m in meta]),('scroll_hi',[m['scroll_end']>>8 for m in meta])]:parts.append(key+' dta '+','.join(map(str,values)))
(G/'tables.asm').write_text('\n'.join(parts)+'\n')
(G/'loads.asm').write_text('\n'.join(f"        org $a000\n        ins 'data/vram.bin',{bank*4096},4096\n        ini upload_bank"for bank in range(127))+'\n')
# Embedded bitmaps let the preview work from file:// without fetch permissions.
def url(p):return 'data:image/png;base64,'+base64.b64encode(p.read_bytes()).decode()
preview={'scenes':[dict(m,image=url(D/f'scene-{i+1}.png'),text=url(D/f'text-{i+1}.png'))for i,m in enumerate(meta)]}
(ROOT/'preview-data.js').write_text('const INTRO_DATA = '+json.dumps(preview)+';\n')
print('Five scenes; text rows:',[len(m['rows'])for m in meta],'; VRAM:',text_base,'/ 516096 bytes')
