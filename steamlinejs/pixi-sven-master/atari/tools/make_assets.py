#!/usr/bin/env python3
"""Convert the workshop artwork to one indexed VBXE palette and 4K banks."""
from pathlib import Path
from PIL import Image
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
