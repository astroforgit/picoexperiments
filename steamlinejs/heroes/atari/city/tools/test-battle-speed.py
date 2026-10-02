#!/usr/bin/env python3
"""Cache correctness, cycle-count regression and live numeric HUD checks."""
import importlib.util,json
from pathlib import Path
spec=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
def check(page,capture=False):
 m=r.Machine(page);m.mem.ram[r.LABELS['army_units']:r.LABELS['army_units']+5]=bytes([1,2,4,8,14]);m.put('army_count',5)
 m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4]=bytes([3,3,3,2]);m.put('selected_location',4);m.call('battle.start')
 m.put('battle.enemy_busy',1)
 cache=r.LABELS['battle.idle_ids'];count=len(r.IDLE_CACHES);m.mem.ram[cache:cache+count]=bytes([255]*count);m.put('battle.pose_cached',255)
 start=m.cpu.processorCycles;m.call('battle.draw');cold=m.cpu.processorCycles-start
 start=m.cpu.processorCycles;m.call('battle.draw');warm=m.cpu.processorCycles-start
 assert warm<cold*.65,(page,cold,warm)
 # Reused idle images equal the decompressed cache; immutable slot contents survive draw.
 layout=json.loads((r.ROOT/'generated/hero-animation-layout.json').read_text())
 images=[bytes(m.mem.vram[a:a+896]) for a in layout['idleCaches']]
 m.call('battle.draw');assert images==[bytes(m.mem.vram[a:a+896]) for a in layout['idleCaches']]
 m.put('render_bank',m.get('back_bank'));m.put('battle.enemy_busy',0);m.put('battle.info_y',161);m.put('battle.unit_hp',2);m.put('battle.unit_move_left',1)
 m.cpu.x=0;m.call('battle.info');a=r.LABELS['battle.stats_line'];text=bytes(m.mem.ram[a:a+18]).decode().replace('\x00',' ');assert text=='HP 2/ 3 A2 M1/2 S0',text
 m.put('battle.unit_acted',1);m.cpu.x=0;m.call('battle.info');assert m.mem.ram[a+12]==ord('0')
 m.put('battle.unit_acted',0)
 if capture:m.screenshot('battle-fast-hud.png')
 # A ninth idle design must not evict the eight hot entries and cause thrashing.
 m.put('render_bank',m.get('back_bank'));m.put('battle.animation_active',0);m.put('battle.attack_frame',0)
 m.put('calc_x',20,2);m.put('calc_y',40)
 for unit in range(28):m.cpu.a=unit;m.put('battle.draw_id',0);m.call('battle.hero_sprite')
 hot=bytes(m.mem.ram[cache:cache+count]);assert m.get('battle.idle_next')==count
 for unit in range(28):m.cpu.a=unit;m.call('battle.hero_sprite')
 assert bytes(m.mem.ram[cache:cache+count])==hot

 print(f'PASS ${page:04X}: cached redraw {warm:,} vs cold {cold:,} CPU cycles ({cold/warm:.1f}x); live HP/AP/damage/shooting stats.')
if __name__=='__main__':check(0xd600,True);check(0xd700)
