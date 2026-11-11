"""Convert the selected Compact football classic artwork to VBXE menu assets."""
from PIL import Image
import numpy as np
COLORS=((255,250,204),(0,132,10),(0,30,100),(255,201,0))
MAIN_WIDTH,MAIN_HEIGHT=100,28
HEADER_WIDTH,HEADER_HEIGHT=208,16
TITLE_ADDRESS=0x70500

def build(root, pages, pictures):
    rgb=np.array(Image.open(root/'assets/title-classic-source.png').convert('RGB'))
    # Separate the solid lettering from its dark presentation background.
    r,g,b=rgb[:,:,0],rgb[:,:,1],rgb[:,:,2]
    mask=(g>65)&((r>130)|(g.astype(int)>b.astype(int)*1.4))
    yy,xx=np.where(mask)
    x0,x1,y0,y1=xx.min(),xx.max()+1,yy.min(),yy.max()+1
    indexed=np.full(mask.shape,0xc0,dtype=np.uint8)
    indexed[mask & (r>150)&(g>180)&(b>90)]=0xd0
    indexed[mask & (r<150)]=0xd1
    indexed[mask & (r>150)&(b<90)]=0xd3
    art=Image.fromarray(indexed).crop((x0,y0,x1,y1))
    main=art.resize((MAIN_WIDTH,MAIN_HEIGHT),Image.Resampling.NEAREST)
    # The compact header places the same two word groups side by side.
    rows=np.any(np.array(art)!=0xc0,axis=1)
    groups=[]
    for y,on in enumerate(rows):
        if on and (y==0 or not rows[y-1]): start=y
        if on and (y==len(rows)-1 or not rows[y+1]): groups.append((start,y+1))
    assert len(groups)>=3, groups
    header=Image.new('L',(HEADER_WIDTH,HEADER_HEIGHT),0xc0)
    for (top,bottom),x,width in zip(groups[:2],(0,124),(116,84)):
        part=art.crop((0,top,art.width,bottom))
        nonempty=np.any(np.array(part)!=0xc0,axis=0)
        cols=np.where(nonempty)[0]
        part=part.crop((int(cols[0]),0,int(cols[-1])+1,part.height))
        header.paste(part.resize((width,14),Image.Resampling.NEAREST),(x,0))
    header_address=0x77300
    # Boot restores only the first 0x500 bytes of this list bank.
    assert 0x500+len(main.tobytes())<=4096
    pictures.append((0x70000,bytes(0x500)+main.tobytes()))
    light=bytearray((root/'gen/tiles-light.bin').read_bytes())
    # ec_pitch never reads light characters >=203; this starts at 204.
    assert len(header.tobytes())==0xd00
    light[0x3300:0x4000]=header.tobytes()
    (root/'gen/tiles-light.bin').write_bytes(light)
    (root/'gen/title-art.asm').write_text(
        f'title_lo dta <${header_address:05x},<${TITLE_ADDRESS:05x}\n'
        f'title_mid dta >${header_address:05x},>${TITLE_ADDRESS:05x}\n'
        'title_width dta 208,100\ntitle_height dta 16,28\ntitle_zoom dta 0,17\n'
        'title_dst_lo dta <(8*320+56),<(12*320+60)\n'
        'title_dst_hi dta >(8*320+56),>(12*320+60)\n')
    return bytes(v for i,color in enumerate(COLORS,0xd0) for v in (i,*color))
