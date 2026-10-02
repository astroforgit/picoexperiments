#!/usr/bin/env python3
import importlib.util
from pathlib import Path
s=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(s);s.loader.exec_module(r)
def tick(m,n):m.mem.ram[0x13]=(n>>8)&255;m.mem.ram[0x14]=n&255
def check(page,capture=False):
 m=r.Machine(page);m.put('selected_location',0);m.call('battle.start');m.put('battle.cursor_cell',0)
 tick(m,100);m.fire();assert m.get('battle.unit_acted')==0
 m.idle(15);assert m.get('battle.unit_acted')==0,'Held Fire must not skip'
 m.release();tick(m,110);m.fire();assert m.get('battle.unit_acted')==1 and m.get('battle.selected_unit')==1
 m.release();tick(m,115);m.fire();assert m.mem.ram[r.LABELS['battle.unit_acted']+1]==0,'Third press only arms the next unit'
 m.release()
 m.call('battle.start');tick(m,200);m.call('battle.confirm');tick(m,245);m.call('battle.confirm');assert m.get('battle.unit_acted')==0,'Expired pair'
 m.cpu.x=3;m.call('battle.navigate');m.put('battle.cursor_cell',0);tick(m,250);m.call('battle.confirm');assert m.get('battle.unit_acted')==0,'Navigation resets pair'
 # Crossing the low clock-byte boundary still recognizes a quick pair.
 m.call('battle.start');tick(m,0x12fa);m.call('battle.confirm');tick(m,0x1304);m.call('battle.confirm');assert m.get('battle.unit_acted')==1
 # A full 256-tick wrap is not a quick second press.
 m.call('battle.start');tick(m,300);m.call('battle.confirm');tick(m,556);m.call('battle.confirm');assert m.get('battle.unit_acted')==0
 m.call('battle.start');m.put('battle.unit_hp',2);m.put('battle.unit_move_left',1)
 m.call('battle.draw');assert m.get('battle.info_id')==0
 a=r.LABELS['battle.stats_line'];assert bytes(m.mem.ram[a+2:a+7])==b' 2/ 3'
 assert bytes(m.mem.ram[a+12:a+15])==b'1/2'
 # Hovered enemies get the panel; empty ground falls back to the selected ally.
 m.put('battle.cursor_cell',m.mem.ram[r.LABELS['battle.unit_cell']+2]);m.call('battle.draw');assert m.get('battle.info_id')==2
 m.put('battle.cursor_cell',1);m.call('battle.draw');assert m.get('battle.info_id')==0
 if capture:m.screenshot('battle-readable-stats.png')
 print(f'PASS ${page:04X}: double Fire, held input, timeout, navigation reset, clock wrap and focused HUD.')
if __name__=='__main__':check(0xd600,True);check(0xd700)
