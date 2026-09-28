#!/usr/bin/env python3
"""Convert the workshop artwork to one indexed VBXE palette and 4K banks."""
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT.parent / 'pixi-sven-master/src/assets'
OUT = ROOT / 'generated'
OUT.mkdir(exist_ok=True)
names = [f'walk{direction}{frame}.png' for direction in ('Down', 'Up', 'Left', 'Right') for frame in (1, 4, 7, 10)] + [f'sven{d}.png' for d in ('Down', 'Up', 'Left', 'Right')] + [f'sheep{d}.png' for d in ('Down', 'Up', 'Left', 'Right')] + [f'sheepDisappear{i}.png' for i in range(1, 15)]
background = Image.open(SOURCE / 'background.jpg').convert('RGB').resize((320, 200), Image.Resampling.LANCZOS)
sprites = []
for name in names:
    original = Image.open(SOURCE / name).convert('RGBA')
    sprite = Image.new('RGBA', (56, 32))
    scaled = original.resize((round(original.width * 0.4), round(original.height * 0.4)), Image.Resampling.LANCZOS)
    assert scaled.width <= 56 and scaled.height <= 32
    sprite.alpha_composite(scaled, ((56-scaled.width)//2, 32-scaled.height))
    sprites.append(sprite)
# The source meadow's blue water is also the gameplay escape mask.
water = bytearray(200*40)
for y in range(200):
    for x in range(320):
        r,g,b = background.getpixel((x,y))
        if b > 130 and g > 100 and b > r+25 and g > r+15:
            water[y*40+x//8] |= 128 >> (x&7)
(OUT/'water-mask.bin').write_bytes(water)
# New enemy artwork: 4 columns, dog rows 0/1, shepherd rows 2/3.
enemies = Image.open(ROOT/'assets/enemies-atlas.png').convert('RGBA')
assert enemies.getchannel('A').getextrema()[0] == 0, 'Enemy atlas needs transparency'
cells=[]
for row in range(4):
    for col in range(4):
        cell=enemies.crop((col*enemies.width//4,row*enemies.height//4,(col+1)*enemies.width//4,(row+1)*enemies.height//4))
        box=cell.getchannel('A').getbbox()
        assert box
        cells.append(cell.crop(box))
for i,cell in enumerate(cells):
    group=cells[:8] if i<8 else cells[8:]
    scale=min((46 if i<8 else 36)/max(c.width for c in group),32/max(c.height for c in group))
    scaled=cell.resize((max(1,round(cell.width*scale)),max(1,round(cell.height*scale))),Image.Resampling.LANCZOS)
    frame=Image.new('RGBA',(56,32))
    frame.alpha_composite(scaled,((56-scaled.width)//2,32-scaled.height))
    sprites.append(frame)
# Small code-defined UI symbols: sun/cloud/storm and four progress segments.
for mood in range(3):
    for progress in range(5):
        frame=Image.new('RGBA',(56,32))
        d=ImageDraw.Draw(frame)
        if mood==0:
            d.line((28,0,28,8),fill='#fff188'); d.line((23,4,33,4),fill='#fff188')
            d.ellipse((25,1,31,7),fill='#ffe74b',outline='#765212')
        else:
            color='#e5eaf0' if mood==1 else '#596174'
            if mood==1:d.ellipse((22,0,28,6),fill='#ffe74b')
            d.ellipse((23,2,29,7),fill=color); d.ellipse((27,0,33,7),fill=color)
            d.rectangle((24,4,32,7),fill=color)
            if mood==2:
                for x in (25,28,31):d.line((x,8,x-1,10),fill='#98d5ff')
        d.rectangle((18,11,37,14),fill='#273024')
        for n in range(4):
            d.rectangle((19+n*5,12,21+n*5,13),fill='#f386b2' if n<progress else '#647552')
        sprites.append(frame)
# Existing combined Sven/sheep love scene, preserving the common foot anchor.
love=[Image.open(SOURCE/f'hump{direction}{n}.png').convert('RGBA') for direction in ('Down','Up','Left','Right') for n in range(1,6)]
love_scale=min(0.4,56/max(im.width for im in love),32/max(im.height for im in love))
for original in love:
    scaled=original.resize((round(original.width*love_scale),round(original.height*love_scale)),Image.Resampling.LANCZOS)
    assert scaled.width<=56 and scaled.height<=32
    frame=Image.new('RGBA',(56,32))
    frame.alpha_composite(scaled,((56-scaled.width)//2,32-scaled.height))
    sprites.append(frame)
# A short heart response preserves the four progress segments underneath.
for progress in range(5):
    frame=Image.new('RGBA',(56,32));d=ImageDraw.Draw(frame)
    d.polygon([(23,3),(25,1),(28,3),(31,1),(33,3),(33,5),(28,10),(23,5)],fill='#ff7db6',outline='#872948')
    d.rectangle((18,11,37,14),fill='#273024')
    for n in range(4):
        d.rectangle((19+n*5,12,21+n*5,13),fill='#f386b2' if n<progress else '#647552')
    sprites.append(frame)
# Import generated RGB atlas: discard border-connected neutral checker pixels
# when producing transparent VBXE indices. Keep the supplied artwork unchanged.
from collections import deque
art=Image.open(ROOT/'assets/devils-mushrooms-atlas.png').convert('RGB')
for i in range(6):
    row,col=divmod(i,4)
    cell=art.crop((col*art.width//4,row*art.height//2,(col+1)*art.width//4,(row+1)*art.height//2))
    w,h=cell.size;alpha=bytearray([255])*(w*h);q=deque()
    def checker_pixel(x,y):
        c=cell.getpixel((x,y));return min(c)>195 and max(c)-min(c)<28
    for y in range(h):
        for x in (0,w-1):
            if checker_pixel(x,y):q.append((x,y));alpha[y*w+x]=0
    for x in range(w):
        for y in (0,h-1):
            if checker_pixel(x,y):q.append((x,y));alpha[y*w+x]=0
    while q:
        x,y=q.popleft()
        for nx,ny in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
            if 0<=nx<w and 0<=ny<h and alpha[ny*w+nx] and checker_pixel(nx,ny):
                alpha[ny*w+nx]=0;q.append((nx,ny))
    cell=cell.convert('RGBA');cell.putalpha(Image.frombytes('L',(w,h),bytes(alpha)))
    cell=cell.crop(cell.getbbox())
    scale=min((35 if i<4 else 18)/cell.width,(30 if i<4 else 20)/cell.height)
    scaled=cell.resize((max(1,round(cell.width*scale)),max(1,round(cell.height*scale))),Image.Resampling.LANCZOS)
    frame=Image.new('RGBA',(56,32));frame.alpha_composite(scaled,((56-scaled.width)//2,32-scaled.height));sprites.append(frame)
# Lightning-stage progress icons and a transparent electrical effect.
for progress in range(5):
    frame=Image.new('RGBA',(56,32));d=ImageDraw.Draw(frame)
    d.polygon([(28,0),(24,6),(28,6),(26,11),(33,4),(29,4),(32,0)],fill='#ffef48',outline='#6f2138')
    d.rectangle((18,11,37,14),fill='#273024')
    for n in range(4):d.rectangle((19+n*5,12,21+n*5,13),fill='#f386b2' if n<progress else '#647552')
    sprites.append(frame)
frame=Image.new('RGBA',(56,32));d=ImageDraw.Draw(frame)
for x in (12,40):d.line([(x,4),(x-4,12),(x+2,12),(x-3,23),(x+2,28)],fill='#fff469',width=2)
d.line([(20,3),(25,0),(30,3),(35,0)],fill='#b8eeff',width=2)
sprites.append(frame)
assert len(sprites)==106
atlas = Image.new('RGB', (320, 200+32*len(sprites)), '#91ac33')
atlas.paste(background, (0, 0))
for i, sprite in enumerate(sprites):
    atlas.paste(sprite, (0, 200+32*i), sprite)
quantized = atlas.quantize(colors=254, method=Image.Quantize.MEDIANCUT)
palette = quantized.getpalette()[:254*3]
palette += [0]*(254*3-len(palette))
# Zero is transparent; 255 is the white HUD ink.
(OUT/'palette.bin').write_bytes(bytes([0, 0, 0]+palette+[255, 255, 255]))
def indexed(image):
    return image.convert('RGB').quantize(palette=quantized, dither=Image.Dither.NONE)
bg = indexed(background)
data = bytearray(v+1 for v in bg.tobytes())
for sprite in sprites:
    indices = indexed(sprite).tobytes()
    data.extend(v+1 if a >= 100 else 0 for v, a in zip(indices, sprite.getchannel('A').tobytes()))
data.extend(bytes((-len(data)) % 4096))
# Independent title palette preserves the existing meadow/sprite colors.
# Reserve $60000-$6F9FF; uploads remain contiguous from $20000.
assert 0x20000+len(data) <= 0x60000
title = Image.open(ROOT/'assets/title-screen-v3.png').convert('RGB').resize((320, 200), Image.Resampling.LANCZOS)
title = title.quantize(colors=254, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
title_palette = bytes([0, 0, 0]+title.getpalette()[:254*3]+[255, 255, 255])
assert len(title_palette) == 768
(OUT/'title-palette.bin').write_bytes(title_palette)
title_pixels = bytes(v+1 for v in title.tobytes())
data.extend(bytes(0x40000-len(data)))
data.extend(title_pixels)
data.extend(bytes((-len(data)) % 4096))
title.putpalette(title_palette)
title.putdata(title_pixels)
title.save(OUT/'title-preview.png')
# Remove only obsolete banks owned by this generator after the asset count shrinks.
for old in OUT.glob('bank-*.bin'):
    if int(old.stem.split('-')[1]) >= len(data)//4096:
        old.unlink()
lines=[]
for i in range(len(data)//4096):
    filename=f'bank-{i:02}.bin'
    (OUT/filename).write_bytes(data[i*4096:(i+1)*4096])
    lines += ['        org $8000', f'        ins "generated/{filename}"', '        ini upload_bank']
(OUT/'assets.asm').write_text('\n'.join(lines)+'\n')
preview = bg.copy()
preview.putpalette([0,0,0]+palette+[255,255,255])
preview.putdata([v+1 for v in bg.tobytes()])
preview.save(OUT/'meadow.png')
print(f'Converted background and {len(sprites)} sprites: {len(data)} bytes, {len(data)//4096} VBXE banks')
