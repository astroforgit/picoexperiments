"""Native return-state rendering checks and an enlarged comparison image."""
from pathlib import Path
import sys
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram

def put(k,v):r[L[k]]=v
def call(k):a.call(L[k])
for k,v in [('STATE',3),('BOBBER_SELECTED',2),('BUFFER',2),('DRAW_BANK',0xa0),('BASE_Y',60),('FLOAT_X',120),('FLOAT_Y',60),('CLOUD_COUNT',0),('FRAME',32)]:put(k,v)
sheet=Image.new('RGB',(800,230),(12,18,36));d=ImageDraw.Draw(sheet);palettes=[]
for i,(name,bait,kind,caught) in enumerate([('Rainbow worm',1,0,255),('Electric worm',1,1,255),('Empty hook',0,0,255),('Caught star',0,0,0)]):
 put('BAIT_PRESENT',bait);put('WORM_TYPE',kind);put('CAUGHT',caught)
 a.vram[0x20000:0x20000+76800]=0;call('DRAW_BAIT')
 pixels=a.vram[0x20000:0x20000+76800].copy()
 if caught==0:
  assert sum(pixels==252)==4
  assert sum(pixels!=0)==14
 else:assert sum(pixels!=0)==7
 if bait:palettes.append(bytes(pixels))
 call('RENDER');a.vregs[0x41]=0;a.vregs[0x42]=0xe0;a.vregs[0x43]=7
 shot=a.screenshot(scale=1)
 sheet.paste(shot.crop((108,54,133,79)).resize((200,200),Image.Resampling.NEAREST),(i*200,30))
 d.text((i*200+12,10),name,fill=(246,218,138))
 if caught==0:shot.resize((960,720),Image.Resampling.NEAREST).save(ROOT/'screenshots/caught-star-return.png')
assert palettes[0]!=palettes[1]
# All below-water outcomes hide their bait, hook and star.
put('STATE',5)
a.vram[0x20000:0x20000+76800]=0;call('DRAW_BAIT');assert not any(a.vram[0x20000:0x20000+76800])
sheet.save(ROOT/'screenshots/return-outcomes.png')
print('PASS native rainbow/electric worm, empty hook and glowing 2x2 caught-star rendering; comparison saved')

# Verify and preview the halo pulse around an unchanged four-pixel core.
put('STATE',3);put('CAUGHT',0);put('BAIT_PRESENT',0);frames=[]
for phase in range(8):
 put('FRAME',phase*32);a.vram[0x20000:0x20000+76800]=0;call('DRAW_BAIT')
 native=a.vram[0x20000:0x20000+76800]
 assert all(native[(69+dy)*320+120+dx]==252 for dx,dy in ((0,0),(1,0),(0,1),(1,1)))
 assert sum(native==252)==(12 if phase==3 else 4)
 call('RENDER');shot=a.screenshot(scale=1)
 frames.append(shot.crop((108,54,133,79)).resize((200,200),Image.Resampling.NEAREST))
frames[0].save(ROOT/'screenshots/caught-square-glow.gif',save_all=True,append_images=frames[1:],duration=640,loop=0)
print('PASS stable four-pixel core and animated halo')
