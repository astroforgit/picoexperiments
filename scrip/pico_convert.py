#!/usr/bin/env python3
from pathlib import Path
from PIL import Image
import argparse, re, unicodedata, xml.etree.ElementTree as ET

ROOT=Path('.'); TABLE=('\n 0123456789abcdefghijklmnopqrstuvwxyz!#%(){}[]<>+=/*:;.,~_').encode('latin-1')
class BR:
    def __init__(s,d): s.d=d; s.p=0
    def b(s): v=(s.d[s.p>>3]>>(s.p&7))&1; s.p+=1; return v
    def n(s,k): return sum(s.b()<<i for i in range(k))

def cart_bytes(p):
    img=Image.open(p).convert('RGBA'); o=bytearray()
    for r,g,b,a in img.getdata(): o.append(((a&3)<<6)|((r&3)<<4)|((g&3)<<2)|(b&3))
    return bytes(o)

def dec_new(c):
    ln=(c[0x4304]<<8)|c[0x4305]; d=c[0x4308:0x4308+(((c[0x4306]<<8)|c[0x4307])-8)]; br=BR(d); mtf=list(range(256)); o=bytearray()
    while len(o)<ln:
        if br.b():
            u=0
            while br.b(): u+=1
            i=br.n(4+u)+(((1<<u)-1)<<4); v=mtf.pop(i); mtf.insert(0,v); o.append(v)
        else:
            first=br.b(); ob=15
            if first: ob=5 if br.b() else 10
            off=br.n(ob)+1
            if ob==10 and off==1:
                while len(o)<ln:
                    v=br.n(8)
                    if v==0: break
                    o.append(v)
            else:
                rl=3
                while True:
                    part=br.n(3); rl+=part
                    if part!=7: break
                for _ in range(rl):
                    o.append(o[-off])
                    if len(o)>=ln: break
    return bytes(o[:ln])

def dec_old(c):
    ln=(c[0x4304]<<8)|c[0x4305]; i=0x4308; o=bytearray()
    while len(o)<ln:
        b=c[i]; i+=1
        if b==0: o.append(c[i]); i+=1
        elif b<=0x3b: o.append(TABLE[b-1])
        else:
            b2=c[i]; i+=1; off=(b-0x3c)*16+(b2&15); rl=(b2>>4)+2
            for _ in range(rl): o.append(o[-off])
    return bytes(o[:ln])

def code_bytes(c):
    h=c[0x4300:0x4304]
    return ('new',dec_new(c)) if h==b'\x00pxa' else ('old',dec_old(c)) if h==b':c:\x00' else ('plain',c[0x4300:0x8000].split(b'\x00',1)[0])

def hx(bs,swap=False): return ''.join(f'{b&15:x}{b>>4:x}' if swap else f'{b:02x}' for b in bs)

def build_p8(c):
    fmt,code=code_bytes(c); ver=c[0x8000] or 8; p=[f'pico-8 cartridge // http://www.pico-8.com\nversion {ver}\n__lua__\n'.encode(),code]
    if not code.endswith(b'\n'): p.append(b'\n')
    p+= [b'__gfx__\n']+[f'{hx(c[y*64:(y+1)*64],True)}\n'.encode() for y in range(128)]
    p+= [b'__gff__\n']+[f'{hx(c[0x3000+y*128:0x3000+(y+1)*128])}\n'.encode() for y in range(2)]
    p+= [b'__map__\n']+[f'{hx(c[0x2000+y*128:0x2000+(y+1)*128])}\n'.encode() for y in range(32)]
    p.append(b'__sfx__\n')
    for sid in range(64):
        b=0x3200+sid*68; line=[hx(c[b+64:b+68])]
        for n in range(32):
            lo,hi=c[b+n*2],c[b+n*2+1]; pitch=lo&0x3f; wave=((lo>>6)&3)|((hi&1)<<2)|(8 if hi&0x80 else 0); vol=(hi>>1)&7; fx=(hi>>4)&7
            line.append(f'{pitch:02x}{wave:x}{vol:x}{fx:x}')
        p.append((''.join(line)+'\n').encode())
    p.append(b'__music__\n')
    for pid in range(64):
        r=c[0x3100+pid*4:0x3104+pid*4]; fl=((r[0]>>7)&1)|(((r[1]>>7)&1)<<1)|(((r[2]>>7)&1)<<2)
        ch=' '.join(f'{(0x41+i):02x}' if b&0x40 else f'{b&0x3f:02x}' for i,b in enumerate(r)); p.append(f'{fl:02x} {ch}\n'.encode())
    return fmt,b''.join(p),code

def norm(s):
    s=unicodedata.normalize('NFKC',s).casefold(); s=re.sub(r'\.(p8|png)$','',s); s=re.sub(r'\s*\([^)]*\)$','',s); s=re.sub(r'[^0-9a-z]+',' ',s)
    return re.sub(r'\s+',' ',s).strip()

def manual_info(manual,title):
    if not manual: return 'No description available in repository manuals.','N/A'
    t=manual.read_bytes().decode('utf-8','replace'); urls=[u.rstrip(').,]') for u in re.findall(r'https?://\S+',t)]; url=next((u for u in urls if 'lexaloffle.com' in u), urls[0] if urls else 'N/A')
    if url=='N/A':
        m=re.search(r'Cart\s+#([^\s|]+)',t,re.I)
        if m: url=f'https://www.lexaloffle.com/bbs/?pid={m.group(1)}'
    paras=[]; cur=[]
    for raw in t.replace('\r','').split('\n'):
        s=raw.strip()
        if s: cur.append(s)
        elif cur: paras.append(' '.join(cur)); cur=[]
    if cur: paras.append(' '.join(cur))
    title_n=norm(title); bad=('cart #','by ','http://','https://','update:','updates:','todo:')
    for p in paras:
        q=re.sub(r'\s+',' ',p).strip(); l=q.casefold()
        if not q or q.isdigit() or norm(q)==title_n or l.startswith(bad) or re.fullmatch(r'v[0-9].*',l): continue
        q=re.sub(r'https?://\S+','',q).strip(); return (q[:277].rsplit(' ',1)[0]+'...' if len(q)>280 else q),url
    return 'No description available in repository manuals.',url

def load_meta(root):
    gm={}; ex={}; nm={}; g=root/'gamelist.xml'; m=root/'manuals'
    if g.exists():
        for e in ET.parse(g).getroot().findall('game'):
            p=(e.findtext('path') or '').strip()
            if p.startswith('./'): p=p[2:]
            if p.endswith('.p8.png'): gm[p]={'name':(e.findtext('name') or '').strip(),'genre':(e.findtext('genre') or '').strip()}
    if m.exists():
        for f in m.glob('*.txt'): ex[f.stem]=f; nm.setdefault(norm(f.stem),[]).append(f)
    return gm,ex,nm

def pick_manual(stem,name,ex,nm):
    for c in {stem,re.sub(r'\s*\([^)]*\)$','',stem),name,name.replace(':',' - '),name.replace(' - ',': ')}:
        if c in ex: return ex[c]
    for c in [stem,name]:
        ms=nm.get(norm(c))
        if ms: return ms[0]

def main():
    ap=argparse.ArgumentParser(description='Convert PICO-8 .p8.png carts into allgames.txt and mirrored .p8 files.')
    ap.add_argument('--root',default='.',help='Project root'); ap.add_argument('--txt',default='allgames.txt'); ap.add_argument('--out',default='allgames'); ap.add_argument('--descriptions',default='descriptions.txt')
    a=ap.parse_args(); root=Path(a.root); gm,ex,nm=load_meta(root); out=root/a.out; out.mkdir(exist_ok=True)
    txt=[]; desc=['PICO-8 game descriptions and links','']; count=0
    for png in sorted(root.rglob('*.p8.png')):
        rel=png.relative_to(root).as_posix(); cart=cart_bytes(png); fmt,p8,code=build_p8(cart); name=gm.get(rel,{}).get('name') or png.stem.replace('.p8',''); genre=gm.get(rel,{}).get('genre') or png.parent.name
        p8path=out/png.relative_to(root).with_suffix(''); p8path.parent.mkdir(parents=True,exist_ok=True); p8path.write_bytes(p8)
        txt += ['-- ========================================',f'-- game: {name}',f'-- source: {rel}','-- ========================================',code.decode('latin-1') + ('' if code.endswith(b'\n') else '\n'),'']
        d,u=manual_info(pick_manual(png.stem.replace('.p8',''),name,ex,nm),name)
        desc += ['='*72,f'Game: {name}',f'Category: {genre}',f'P8 file: {p8path.relative_to(out).as_posix()}',f'Original PNG: {rel}',f'Web link: {u}',f'Description: {d}','']
        count+=1
    (root/a.txt).write_text('\n'.join(txt),encoding='utf-8'); (out/a.descriptions).write_text('\n'.join(desc),encoding='utf-8')
    print(f'Converted {count} carts -> {a.txt}, {a.out}/, {a.out}/{a.descriptions}')

if __name__=='__main__': main()
