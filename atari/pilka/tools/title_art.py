"""Build a small, deterministic neon title from the supplied pixel lettering."""
from PIL import Image
TITLE='RETRO FANS LEAGUE'
COLORS=((70,240,255),(220,255,255),(50,180,255),(80,65,205),(225,50,220),(255,90,190),(255,190,230),(55,20,90))

def build(root, pages, pictures):
    raw=(root/'assets/swos/unpacked/CHARSET.RAW').read_bytes()
    glyphs={}
    for char in dict.fromkeys(TITLE):
        glyph=Image.new('L',(8,8),0xc0)
        if char!=' ':
            ox=(ord(char)-32)%16*16
            oy=(ord(char)-32)//16*8
            mask=Image.new('1',(5,5))
            for y in range(5):
                for x in range(5):
                    v=sum(((raw[(oy+y)*160+p*40+(ox+x)//8]>>(7-(ox+x)%8))&1)<<p for p in range(4))
                    mask.putpixel((x,y),v==2)
            mask=mask.resize((6,7),Image.Resampling.NEAREST)
            for y in range(7):
                for x in range(6):
                    if mask.getpixel((x,y)):
                        dx=x+(6-y)//3
                        if dx+1<8: glyph.putpixel((dx+1,y+1),0xd7)
            for y in range(7):
                for x in range(6):
                    if mask.getpixel((x,y)): glyph.putpixel((x+(6-y)//3,y),0xd0+y)
        glyphs[char]=glyph.tobytes()
    addresses={}
    for index,(char,data) in enumerate(glyphs.items()):
        page,slot=divmod(index,4)
        addresses[char]=pages[page]+3840+slot*64
        address,payload=pictures[page]
        pictures[page]=(address,payload+data)
    a=[addresses[c] for c in TITLE]
    (root/'gen/title-art.asm').write_text('title_lo dta '+','.join(str(v&255) for v in a)+'\ntitle_mid dta '+','.join(str(v>>8&255) for v in a)+'\ntitle_bank dta '+','.join(str(v>>16) for v in a)+'\n')
    return bytes(v for i,rgb in enumerate(COLORS,0xd0) for v in (i,*rgb))
