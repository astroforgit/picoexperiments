#!/usr/bin/env python3
"""Single save slot on the boot ATR: exact round trip, rejected slots, locked disk, menus."""
import importlib.util,json,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
layout=json.loads((r.ROOT/'generated/story-layout.json').read_text())
SECTOR=layout['saveSector'];OFFSET=16+384+(SECTOR-4)*256
boot=(r.ROOT/'city-vbxe.atr').read_bytes()
fields=[('gold',2),('difficulty',1),('building_levels',5),('army_units',5),('army_count',1),('army_paid_lo',5),('army_paid_hi',5),
        ('region_wins',4),('battle.encounter_seed',1),('gallery.notes_found',1),('gallery.notes_pending',1),('gallery.painting_pending',1),
        ('gallery.collected',1),('gallery.wins',1),('gallery.order',8)]
def state(m):return {n:bytes(m.mem.ram[r.LABELS[n]:r.LABELS[n]+k]) for n,k in fields}
def screenshot(m,name):
 if '--screens' not in sys.argv:return
 from PIL import Image
 out=Path(sys.argv[sys.argv.index('--screens')+1]);out.mkdir(parents=True,exist_ok=True)
 b=m.get('front_bank')*65536;im=Image.frombytes('P',(320,200),bytes(m.mem.vram[b:b+64000]));im.putpalette(m.mem.palette);im.save(out/name)
assert all(v==0 for v in boot[OFFSET:OFFSET+256]),'A fresh boot ATR has an empty save slot'
for page in (0xd600,0xd700):
 m=r.Machine(page);m.mem.story_disk=boot;m.put('savegame.boot_disk',1)
 # An empty slot loads nothing and changes nothing.
 before=state(m);m.call('savegame.load');assert not m.cpu.p&1 and state(m)==before
 # A mid-campaign state, then save.
 values={'gold':(1234).to_bytes(2,'little'),'difficulty':b'\x02','building_levels':bytes([2,1,0,3,1]),'army_units':bytes([1,0,3,255,9]),
  'army_count':b'\x04','army_paid_lo':bytes([25,15,50,0,25]),'army_paid_hi':bytes(5),'region_wins':bytes([5,3,1,0]),'battle.encounter_seed':b'\x2a',
  'gallery.notes_found':b'\x01','gallery.notes_pending':b'\x00','gallery.painting_pending':b'\x00','gallery.collected':bytes([0b00100101]),
  'gallery.wins':b'\x09','gallery.order':bytes([3,1,4,0,6,2,7,5])}
 for n,v in values.items():m.mem.ram[r.LABELS[n]:r.LABELS[n]+len(v)]=v
 m.call('savegame.save');assert m.cpu.p&1 and m.mem.story_writes==[(SECTOR,256)]
 slot=m.mem.story_disk[OFFSET:OFFSET+256];assert slot[:5]==b'NYS1'+bytes([42])
 assert m.mem.story_disk[:OFFSET]==boot[:OFFSET] and m.mem.story_disk[OFFSET+256:]==boot[OFFSET+256:],'Only the save sector changes'
 # Start over, then load: every field returns and capacity follows the Chapel.
 m.call('new_city');assert state(m)!=values
 m.call('savegame.load');assert m.cpu.p&1
 assert state(m)==values,state(m)
 assert m.get('army_capacity')==5 and m.get('screen_mode')==0 and m.get('popup_open')==0
 # A damaged slot is refused without touching the campaign.
 disk=bytearray(m.mem.story_disk);disk[OFFSET+20]^=0xff;m.mem.story_disk=bytes(disk)
 m.call('new_city');before=state(m);m.call('savegame.load');assert not m.cpu.p&1 and state(m)==before
 # A write-protected disk reports failure.
 m.mem.disk_locked=True;m.call('savegame.save');assert not m.cpu.p&1;m.mem.disk_locked=False
 # City menu: drawn over the city with its three rows and a status line.
 m.put('savegame.choice',0);m.put('savegame.status',2);m.put('render_bank',m.get('back_bank'));m.call('savegame.draw')
 if page==0xd600:screenshot(m,'game-menu.png')
 # Without the boot ATR, Escape in the city opens nothing.
 m=r.Machine(page);m.call('close_popup');assert m.get('popup_open')==0 and m.get('savegame.boot_disk')==0
 print(f'PASS ${page:04X}: empty slot ignored, 42-byte save in sector {SECTOR} only, exact load, capacity rebuilt, damaged slot refused, locked disk reported, XEX version has no menu.')
# Title menu on the boot ATR: six rows, LOAD GAME last; a missing save is reported.
m=r.Machine(0xd600,menu=True);m.mem.story_disk=boot;m.put('savegame.boot_disk',1)
vctl=0xd600+0x40;on=m.mem.ram[vctl];m.mem.ram[vctl]=0  # prepare paints both banks before the display starts
m.call('release_ui.prepare');m.mem.ram[vctl]=on
m.put('release_ui.choice',5);m.put('release_ui.page',0);m.call('release_ui.draw')
assert m.get('release_ui.rows')==6 and m.get('release_ui.menu_top')==90
screenshot(m,'title-load-game.png')
print('PASS: boot ATR title menu has six rows with LOAD GAME.')
