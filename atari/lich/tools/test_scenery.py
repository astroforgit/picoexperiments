import sys,json
from pathlib import Path
root=Path(__file__).resolve().parent.parent;sys.path.insert(0,str(root/'tools'))
import shot
from emu import load_labels
L=load_labels(root/'lich.lab');g=json.loads((root/'data/game.json').read_text());a=shot.run('80,f,300,c,90');r=a.mem.ram
out=root/'shots';out.mkdir(exist_ok=True)
a.screenshot(out/'atari-renderer-fixed.png',scale=4)
a.call(L['BLIT_WAIT']);a.call(L['MEMAC_ON']);a.call(L['BCB_PREFILL'])
lit=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,1,15];dark=[0,0,1,5,1,1,13,6,4,4,9,3,13,5,1,1]
def tile(n):return [[int(c,16) for c in row[n%16*8:n%16*8+8]] for row in g['sheet'][n//16*8:n//16*8+8]]
def bake(x,y,n,fog):
 r[L['TMAP']+y*128+x]=n;r[L['FOG']+y*128+x]=fog;r[L['A0']]=x;r[L['A1']]=y
 a.call(L['BCB_BEGIN']);a.call(L['BAKE_TILE']);a.call(L['BCB_FLUSH'])
 return [[int(a.vram[0x40000+(y*8+dy)*1024+x*8+dx])&15 for dx in range(8)]for dy in range(8)]
for fog,pal in [(0,lit),(1,dark)]:
 for n in [71,75,68,70,69,14,23,46]:
  result=bake(20,10,n,fog);src=tile(n);floor=tile(1)
  expected=[[pal[src[y][x] or floor[y][x]] for x in range(8)]for y in range(8)]
  assert result==expected,(n,fog,result,expected)
# Native decorations use the same selector and pixels as browser overlays.
art=json.loads((root/'data/wall-decorations.json').read_text())
for x in [7,12]:
 y=10;r[L['TMAP']+y*128+x]=54;r[L['TMAP']+(y+1)*128+x]=2
 kind='banner' if (((x+2*y)//5+y)%2) else 'torch';rows=art[kind]+['00000000']*4
 for part,n in enumerate([54,2]):
  result=bake(x,y+part,n,0);base=tile(n)
  expected=[[int(rows[dy+part*8][dx],16) or lit[base[dy][dx]] for dx in range(8)]for dy in range(8)]
  assert result==expected,(kind,part,result,expected)
# Row cache must exactly cover static tall bases, including map boundaries.
a.call(L['INDEX_OVERHANGS']);bases={int(k)for k,v in g['overhangs'].items()if v['enabled']}
for y in range(32):assert bool(r[0xfa80+y])==any(n in bases for n in r[L['TMAP']+128*y:L['TMAP']+128*(y+1)])
print('PASS native lit/dark scenery backgrounds, torch/banner bake pixels, overhang row cache; screenshot saved.')
