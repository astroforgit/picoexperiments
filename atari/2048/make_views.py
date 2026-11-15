#!/usr/bin/env python3
"""Compile PicoRacer's vector courses into clipped VBXE line lists."""
from pathlib import Path
import math
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
CART = HERE.parents[1] / 'allgames/[Race]/PicoRacer-2048.p8'
raw = bytes.fromhex(''.join(CART.read_text().split('__map__\n', 1)[1].split('\n__sfx__', 1)[0].splitlines()))
assert len(raw) == 4096
COLORS = (8, 9, 10, 11, 12, 3, 14, 15)
PAL = [(0,0,0),(29,43,83),(126,37,83),(0,135,81),(171,82,54),(95,87,79),(194,195,199),(255,241,232),(255,0,77),(255,163,0),(255,236,39),(0,228,54),(41,173,255),(131,118,156),(255,119,168),(255,204,170)]


def course_points(block):
    pts = []
    x = y = direction = last_dir = 0.0
    for p in range(0, 510, 3):
        length, curve, width = block[p:p+3]
        if not length:
            break
        while length > 0:
            direction += (curve - 128) / 100
            if abs(direction - last_dir) > .09:
                direction = (direction + last_dir) / 2
                step = 16
                length -= .5
            else:
                step = 32
                length -= 1
            rad = direction * math.tau
            x += math.cos(rad) * step
            y += math.sin(rad) * step
            pts.append((x, y, math.sin(rad) * width, -math.cos(rad) * width, direction))
            last_dir = direction
    return pts


def clip(x0, y0, x1, y1):
    # Liang-Barsky, 160x160 viewport.
    dx, dy = x1-x0, y1-y0
    u0, u1 = 0.0, 1.0
    for p, q in ((-dx,x0),(dx,159-x0),(-dy,y0),(dy,159-y0)):
        if abs(p) < 1e-9:
            if q < 0: return None
        else:
            t = q/p
            if p < 0:
                u0 = max(u0,t)
            else:
                u1 = min(u1,t)
            if u0 > u1: return None
    out = (round(x0+dx*u0),round(y0+dy*u0),round(x0+dx*u1),round(y0+dy*u1))
    return bytes(max(0,min(159,v)) for v in out)


def view_record(pts, i):
    cx, cy, _, _, direction = pts[i]
    n = len(pts)
    outer, inner, cross, start = [], [], [], []
    def line(a, b, wa, wb, target):
        x0 = 80 + (a[0]+a[2]*wa-cx)*1.25
        y0 = 80 + (a[1]+a[3]*wa-cy)*1.25
        x1 = 80 + (b[0]+b[2]*wb-cx)*1.25
        y1 = 80 + (b[1]+b[3]*wb-cy)*1.25
        clipped = clip(x0,y0,x1,y1)
        if clipped and clipped[:2] != clipped[2:]: target.append(clipped)
    for delta in range(-7,8):
        j = (i+delta) % n
        k = (j+1) % n
        a,b=pts[j],pts[k]
        if math.hypot(a[0]-b[0],a[1]-b[1]) > 96:
            continue
        for sign in (-1,1): line(a,b,sign,sign,outer)
        if -3 <= delta <= 4:
            for sign in (-.75,.75): line(a,b,sign,sign,inner)
        if -2 <= delta <= 4 and delta % 2 == 0:
            line(a,a,-.75,.75,cross)
        if j == 0 and -3 <= delta <= 4:
            line(a,a,-.75,.75,start)
    assert all(len(group)<256 for group in (outer,inner,cross,start))
    heading = round(direction*16) & 15
    color = COLORS[(i*8//n)&7]
    # One pair per nearby centerline point lets the runtime place AI racers.
    nearby = []
    for delta in range(-5,6):
        p=pts[(i+delta)%n]
        sx=round(80+(p[0]-cx)*1.25)
        sy=round(80+(p[1]-cy)*1.25)
        nearby.extend((sx if 0<=sx<160 else 255,sy if 0<=sy<160 else 255))
    perp_x=round(math.sin(direction*math.tau)*4) & 255
    perp_y=round(-math.cos(direction*math.tau)*4) & 255
    header = bytes((heading,color,len(outer),len(inner),len(cross),len(start),perp_x,perp_y,*nearby))
    return header + b''.join(outer+inner+cross+start)


courses=[]
records=[]
all_points=[]
for course in range(8):
    pts=course_points(raw[course*512:(course+1)*512])
    all_points.append(pts)
    courses.append(len(pts))
    records += [view_record(pts,i) for i in range(len(pts))]

# The two framebuffers occupy 00000-0FFFF and 50000-5FFFF; font is at 61000.
# Store vector records in 10000-4FFFF and 62000-7FFFF.
banks = list(range(0x10,0x50))+list(range(0x62,0x80))
chunks=[]
index=[]
bank_no=0
chunk=bytearray()
for record in records:
    if len(chunk)+len(record)>4096:
        chunks.append(bytes(chunk).ljust(4096,b'\0'))
        bank_no+=1
        chunk=bytearray()
    if bank_no>=len(banks):
        raise RuntimeError(f'view data exceeds VBXE RAM: {bank_no} banks')
    index.append((banks[bank_no],len(chunk)))
    chunk.extend(record)
chunks.append(bytes(chunk).ljust(4096,b'\0'))

# The original 128x128 PICO-8 sprite sheet includes the colorful title art.
gfx=CART.read_text().split('__gfx__\n',1)[1].split('\n__gff__',1)[0].splitlines()
assert len(gfx)==128 and all(len(row)==128 for row in gfx)
menu=bytes(int(pixel,16) for row in gfx for pixel in row)
assert len(menu)==16384
chunks.extend(menu[i:i+4096] for i in range(0,len(menu),4096))
assert len(chunks)<=len(banks)

# Assembly index is separated by course, allowing 16-bit segment indices.
lines=['; Generated from allgames/[Race]/PicoRacer-2048.p8 by make_views.py',
       'course_lengths']
for n in courses: lines.append(f'        dta a({n})')
lines.append('course_view_index')
for c in range(8): lines.append(f'        dta a(view_index_{c})')
start=0
for c,n in enumerate(courses):
    lines.append(f'view_index_{c}')
    for bank,off in index[start:start+n]:
        lines.append(f'        dta ${bank|0x80:02x},a(${0x9000+off:04x})')
    start+=n
(HERE/'views-index.asm').write_text('\n'.join(lines)+'\n')
for old in HERE.glob('views-??.bin'): old.unlink()
for i,chunk in enumerate(chunks): (HERE/f'views-{i:02x}.bin').write_bytes(chunk)
loader=['; Generated stage overlays. Each one is uploaded to its VBXE bank.']
for i in range(len(chunks)):
    loader.extend(('        org $8000',f'view_stage_{i:02x} ins \'views-{i:02x}.bin\'','        ini init_view_stage'))
(HERE/'views-loader.asm').write_text('\n'.join(loader)+'\n')
bank_lines=['stage_bank_table']
for bank in banks[:len(chunks)]: bank_lines.append(f'        dta ${bank|0x80:02x}')
(HERE/'views-banks.asm').write_text('\n'.join(bank_lines)+'\n')
row_lines=['; 320-byte framebuffer row addresses.','row_low']
row_lines += ['        dta '+','.join(f'${((y*320)&255):02x}' for y in range(i,min(i+16,160))) for i in range(0,160,16)]
row_lines.append('row_high')
row_lines += ['        dta '+','.join(f'${((y*320)>>8):02x}' for y in range(i,min(i+16,160))) for i in range(0,160,16)]
(HERE/'views-rows.asm').write_text('\n'.join(row_lines)+'\n')
phase=['; Smooth camera advance between source segments.','phase_table']
for heading in range(16):
    values=[]
    for step in range(12):
        rad=heading*math.tau/16
        values.extend((round(math.cos(rad)*40*step/12)&255,
                       round(math.sin(rad)*40*step/12)&255))
    phase.append('        dta '+','.join(f'${v:02x}' for v in values))
phase.append('car_vertices')
for heading in range(16):
    rad=heading*math.tau/16
    values=[]
    for x,y in ((-5,-4),(5,0),(-5,4)):
        values.extend((round(x*math.cos(rad)-y*math.sin(rad))&255,
                       round(x*math.sin(rad)+y*math.cos(rad))&255))
    phase.append('        dta '+','.join(f'${v:02x}' for v in values))
(HERE/'views-motion.asm').write_text('\n'.join(phase)+'\n')

mini=['; Simplified whole-course minimaps for the title screen.','minimap_ptrs']
mini.append('        dta '+','.join(f'a(minimap_{i})' for i in range(8)))
for i,pts in enumerate(all_points):
    sample=[pts[j*len(pts)//48] for j in range(48)]
    xs=[p[0] for p in pts];ys=[p[1] for p in pts]
    min_x,max_x=min(xs),max(xs);min_y,max_y=min(ys),max(ys)
    span=max(max_x-min_x,max_y-min_y,1)
    coords=[]
    for p in sample:
        coords.extend((round(25+(p[0]-min_x)*74/span),round(48+(p[1]-min_y)*74/span)))
    mini.append(f'minimap_{i}')
    mini.append('        dta 48')
    for j in range(0,len(coords),16):
        mini.append('        dta '+','.join(str(v) for v in coords[j:j+16]))
(HERE/'views-minimaps.asm').write_text('\n'.join(mini)+'\n')
print(f'{len(records)} views, {len(chunks)} VBXE banks, {sum(map(len,records))} vector bytes')
print('course segments:',', '.join(map(str,courses)))

# Static preview for checking the generated geometry against the PICO-8 view.
rec=records[20]
im=Image.new('RGB',(160,160),PAL[0]); draw=ImageDraw.Draw(im)
pos=30
for count,col in ((rec[2],rec[1]),(rec[3],13),(rec[4],1),(rec[5],11)):
    for _ in range(count):
        draw.line(tuple(rec[pos:pos+4]),fill=PAL[col]); pos+=4
im.save(HERE/'vector-preview.png')
