"""Check the editor-selected tiny star mask and slow star motion."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parents[1]/'lair/tools'))
from emu import Atari,load_labels
from PIL import Image
sys.path.insert(0,str(ROOT/'tools'))
from scene_model import load_scene
L=load_labels(ROOT/'star-fisher.lab')
a=Atari(ROOT/'star-fisher.xex');a.boot();a.run_frames(15);r=a.mem.ram
r[L['DRAW_BANK']]=0xa0;r[L['PX']]=240;r[L['PY']]=140;r[L['COLOR']]=250
a.vram[0x20000:0x20000+76800]=0
a.call(L['STAR'])
assert (r[L['PX']],r[L['PY']])==(240,140)
points={(i%320-240,i//320-140) for i,p in enumerate(a.vram[0x20000:0x20000+76800]) if p}
scene=load_scene(Image.open(ROOT/'assets/editor-base.png').getpalette())
asset=next(a for a in scene['assets'] if a['id']==scene['gameStar'])
expected={(i%asset['width']-asset['width']//2,i//asset['width']-asset['height']//2) for i,c in enumerate(asset['pixels']) if c}
assert points==expected, 'Native sprite must exactly match the editor-selected mask'
assert 1<=len(points)<=2
print('PASS editor-selected caught-star mask, pixel bounds and preserved anchor')
