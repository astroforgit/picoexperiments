"""Pack the supplied SWOS compact font into menu-only VBXE tiles."""
# SWOS packs narrow I/1 proportionally. Our character grid has a fixed
# eight-pixel advance, so use legible five-pixel forms for those glyphs.
FIXED_WIDTH = {
    'I': ('#####', '..#..', '..#..', '..#..', '#####'),
    '1': ('..#..', '.##..', '..#..', '..#..', '#####'),
}

def build(root):
    raw=(root/'assets/swos/unpacked/CHARSET.RAW').read_bytes()
    packed=bytearray()
    themes=((0xc0,0xc1),(0xc2,0xc4))
    unique={}
    addresses=[]
    for bg,fg in themes:
        for code in range(256):
            char=chr(code-0x98) if 0xd9<=code<=0xf2 else chr(code-0xc3) if 0xf3<=code<=0xfc else ':' if code==0xfe else '-' if code==0xff else ' '
            ox=((ord(char)-32)%16)*16
            oy=((ord(char)-32)//16)*8
            tile=bytearray([bg]*64)
            if char!=' ':
                for y in range(8):
                    for x in range(8):
                        value=sum(((raw[(oy+y)*160+p*40+(ox+x)//8]>>(7-(ox+x)%8))&1)<<p for p in range(4))
                        if value == 2: tile[y*8+x]=fg
                        elif value == 8: tile[y*8+x]=0xc3
            if char in FIXED_WIDTH:
                tile=bytearray([bg]*64)
                shape=FIXED_WIDTH[char]
                # Preserve the same one-pixel shadow as the other letters.
                for y,line in enumerate(shape):
                    for x,pixel in enumerate(line):
                        if pixel == '#': tile[(y+1)*8+x+1]=0xc3
                for y,line in enumerate(shape):
                    for x,pixel in enumerate(line):
                        if pixel == '#': tile[y*8+x]=fg
            tile=bytes(tile)
            if tile not in unique:
                unique[tile]=(0x5f800+len(packed) if len(packed)<2048 else (0x78a00+len(packed)-2048 if len(packed)<3584 else 0x2fa00+len(packed)-3584))
                packed.extend(tile)
            addresses.append(unique[tile])
    assert len(packed)<=5120, len(packed) # reserved fragments beside boot code, banners and the layer
    (root/'gen/menu-font.bin').write_bytes(packed[:2048])
    (root/'gen/menu-tail.bin').write_bytes(bytes(2560)+packed[2048:3584])
    (root/'gen/menu-layer.bin').write_bytes(bytes(2560)+packed[3584:])
    addresses=[addresses[theme*256+code] for theme in range(2) for code in range(0xd9,0x100)]
    (root/'gen/menu-style.asm').write_text('menu_mid dta '+','.join(str(a>>8&255) for a in addresses)+'\nmenu_bits dta '+','.join(str((a>>16<<2)|((a&255)>>6)) for a in addresses)+'\n')
    return bytes(v for index,rgb in enumerate(((24,64,48),(255,255,221),(153,34,34),(24,40,88),(255,221,85)),0xc0) for v in (index,*rgb))
