#!/usr/bin/env python3
"""A compact painted galaxy; broad clouds survive 4x display enlargement."""
from pathlib import Path
from PIL import Image,ImageOps
ROOT=Path(__file__).resolve().parent.parent
PALETTE=[(0,0,0),(3,3,12),(8,7,23),(15,12,38),(24,19,56),(35,27,70),(50,36,85),(70,45,100),(92,61,116),(112,78,130),(7,24,36),(10,38,50),(16,55,65),(25,70,78),(43,77,96),(70,87,116)]
def main():
    im=ImageOps.fit(Image.open(ROOT/'assets/galaxy-painted-source.png').convert('RGB'),(56,35),Image.Resampling.LANCZOS)
    # A fixed palette preserves paint hues rather than reducing them to grey.
    pixels=[]
    for y in range(35):
        for x in range(56):
            fade=min(1,x/2,(55-x)/2,y/2,(34-y)/2)
            rgb=tuple(min(255,round(c*1.15*fade)) for c in im.getpixel((x,y)))
            pixels.append(min(range(16),key=lambda i:sum((a-b)**2 for a,b in zip(rgb,PALETTE[i]))))
    packed=bytes((pixels[i]<<4)|pixels[i+1] for i in range(0,len(pixels),2))
    lines=['; Painted galaxy, 56x35, packed high/low nibble pixels.','galaxy_packed']
    for i in range(0,len(packed),24):lines.append('        dta '+','.join(f'${n:02X}' for n in packed[i:i+24]))
    (ROOT/'atari/generated/sojka-galaxy.inc').write_text('\n'.join(lines)+'\n')
    (ROOT/'atari/generated/sojka-galaxy-palette.inc').write_text('\n'.join('        dta '+','.join(map(str,(64+i,*rgb))) for i,rgb in enumerate(PALETTE))+'\n')
    im.putdata([PALETTE[i] for i in pixels]);im.resize((224,140),Image.Resampling.NEAREST).save(ROOT/'assets/galaxy-painted-vbxe.png')
    print(f'Generated painted galaxy: {len(packed)} bytes.')
if __name__=='__main__':main()
