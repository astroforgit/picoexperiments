"""Native bait pixels, animation, attachment and loss/dive visibility."""
from pathlib import Path
import sys
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
L=load_labels(ROOT/'star-fisher.lab');a=Atari(ROOT/'star-fisher.xex');a.boot();r=a.mem.ram

def put(k,v):r[L[k]]=v
def call(k):a.call(L[k])
for k,v in [('BUFFER',2),('DRAW_BANK',0xa0),('FLOAT_X',120),('FLOAT_Y',90),('BASE_Y',90),('CAUGHT',255),('WORM_TYPE',0)]:put(k,v)
frames=[]
for selected in range(16):
 put('BOBBER_SELECTED',selected)
 for state in (0,2,3,5):
  for bait,stage in ((1,0),(0,0),(1,2)):
   for k,v in [('STATE',state),('BAIT_PRESENT',bait),('BITE_STAGE',stage)]:put(k,v)
   call('DRAW_FLOAT')
   for phase in range(8):
    put('FRAME',phase*32);a.vram[0x20000:0x20000+76800]=0;call('DRAW_BAIT')
    expected=bytearray(76800)
    if state!=5:
     y=90+r[L['BOBBER_HEIGHT']+selected]
     for dy in range(3):expected[(y+dy)*320+120]=254
     if bait:
      for i,(dx,dy) in enumerate(((0,3),(0,4),(1,5),(1,6))):expected[(y+dy)*320+120+dx]=r[L['BAIT_COLORS']+phase*4+i]
     else:
      for dx,dy in ((0,3),(0,4),(1,4),(1,3)):expected[(y+dy)*320+120+dx]=251
    assert bytes(a.vram[0x20000:0x20000+76800])==expected,(selected,state,bait,stage,phase)
# Actual native scene, with a magnified crop for reviewing its tiny bait.
a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram
put('BUFFER',2);put('DRAW_BANK',0xa0)
for k,v in [('STATE',5),('BAIT_PRESENT',1),('BITE_STAGE',0),('BOBBER_SELECTED',2),('BASE_X',120),('BASE_Y',60),('FLOAT_X',120),('FLOAT_Y',60),('CLOUD_COUNT',0)]:put(k,v)
for phase in range(8):
 put('FRAME',phase*32);call('RENDER')
 a.vregs[0x41]=0;a.vregs[0x42]=0xe0;a.vregs[0x43]=7
 shot=a.screenshot(scale=1)
 frames.append(shot.crop((108,53,135,81)).resize((270,280),Image.Resampling.NEAREST))
 if phase==1:shot.resize((960,720),Image.Resampling.NEAREST).save(ROOT/'screenshots/rainbow-bait-game.png')
frames[0].save(ROOT/'screenshots/rainbow-bait-closeup.gif',save_all=True,append_images=frames[1:],duration=640,loop=0)
print('PASS all 16 bait attachments, four-pixel rainbow cycle, empty-hook/waiting visibility; native previews saved')
