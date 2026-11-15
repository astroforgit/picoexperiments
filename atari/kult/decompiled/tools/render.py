#!/usr/bin/env python3
"""Render decoded assets, not emulated screenshots. Pillow only."""
from pathlib import Path
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
PALETTE=[(8,12,20),(70,83,101),(151,165,183),(244,239,218)]
def bitmap(data,width=160):
    height=len(data)*4//width;im=Image.new('RGB',(width,height));px=im.load()
    for i,b in enumerate(data):
        for j in range(4):px[(i*4+j)%width,(i*4+j)//width]=PALETTE[(b>>(6-2*j))&3]
    return im

def atlas(data,columns=32):
    count=len(data)//8;im=Image.new('RGB',(columns*10,((count+columns-1)//columns)*10),(25,30,38));px=im.load()
    for ch in range(count):
        for y in range(8):
            for x in range(8):px[ch%columns*10+x,ch//columns*10+y]=PALETTE[3 if data[ch*8+y]&(128>>x) else 0]
    return im.resize((im.width*2,im.height*2),Image.Resampling.NEAREST if hasattr(Image,'Resampling') else Image.NEAREST)

def main():
    sheet=Image.new('RGB',(672,840),(25,30,38));d=ImageDraw.Draw(sheet)
    for index,name in enumerate('abcd'):
        im=bitmap((ROOT/'cetas'/(name+'-unpacked.bin')).read_bytes()).resize((320,384),Image.NEAREST)
        x=8+(index%2)*336;y=8+(index//2)*420;d.text((x,y),'CETAS resource '+name.upper()+' | diagnostic palette',fill='white');sheet.paste(im,(x,y+22))
    sheet.save(ROOT/'cetas/pictures.png')
    atlas((ROOT/'kult/memory.bin').read_bytes()[0xc800:0xd000]).save(ROOT/'kult/characters.png')
    atlas((ROOT/'cetas/f-unpacked.bin').read_bytes()).save(ROOT/'cetas/graphics-resource.png')
if __name__=='__main__':main()
