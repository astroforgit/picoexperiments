#!/usr/bin/env python3
"""Actual 6502 bankruptcy checks, display, blocked controls and restart input."""
import importlib.util,sys
from pathlib import Path
sp=importlib.util.spec_from_file_location('r',Path(__file__).with_name('test-runtime.py'));r=importlib.util.module_from_spec(sp);sp.loader.exec_module(r)
def situation(m,gold,levels,empty=True):
 m.call('new_city')
 if empty:m.call('clear_army')
 m.mem.ram[r.LABELS['building_levels']:r.LABELS['building_levels']+5]=bytes(levels)
 m.put('gold',gold,2);m.put('secondary_cost',1234,2)
def check(m,expected):
 m.call('check_game_over');assert (m.get('screen_mode')==3)==expected
 assert m.get('secondary_cost',2)==1234,'Checking bankruptcy must not corrupt popup prices'
for page in [0xd600,0xd700]:
 m=r.Machine(page)
 situation(m,0,[2,0,0,0,0],False);check(m,False) # Broke players with soldiers can still fight.
 for gold,lvl,expected in [(24,[2,0,0,0,0],True),(25,[2,0,0,0,0],False),(59,[3,0,0,0,0],True),(60,[3,0,0,0,0],False),(25,[3,1,0,0,0],False),(20,[3,0,1,0,0],False),(14,[2,0,0,3,0],True),(15,[2,0,0,3,0],False),(10,[3,0,0,3,0],True)]:
  situation(m,gold,lvl);check(m,expected)
 # Compare the full 16-bit price, with equality affordable.
 lo=r.LABELS['unit_price_lo']+2;hi=r.LABELS['unit_price_hi']+2;old=(m.mem.ram[lo],m.mem.ram[hi]);m.mem.ram[lo]=44;m.mem.ram[hi]=1
 situation(m,299,[3,0,0,0,0]);check(m,True)
 situation(m,300,[3,0,0,0,0]);check(m,False)
 m.mem.ram[lo],m.mem.ram[hi]=old
 # Wait for the battle result/reward; do not interrupt an active battle.
 situation(m,0,[2,0,0,0,0]);m.put('screen_mode',2);m.put('battle.game_state',0);check(m,False)
 m.put('battle.game_state',2);check(m,True)
 # Direction/cancel cannot escape defeat, and confirmation starts a genuinely new city.
 m.cpu.a=1;m.call('navigate');m.call('close_popup');assert m.get('screen_mode')==3
 m.call('draw_city');assert m.get('dirty')==0
 if '--screens' in sys.argv and page==0xd600:
  from PIL import Image
  out=Path(sys.argv[sys.argv.index('--screens')+1]);out.mkdir(parents=True,exist_ok=True)
  start=m.get('front_bank')*65536;im=Image.frombytes('P',(320,200),bytes(m.mem.vram[start:start+64000]));im.putpalette(m.mem.palette);im.save(out/'game-over.png')
 m.mem.ram[r.LABELS['region_wins']]=10;m.release();m.fire();assert m.get('screen_mode')==0 and m.get('gold',2)==50 and m.get('army_count')==2 and m.array('army_units')==[1,1,255,255,255]
 assert bytes(m.mem.ram[r.LABELS['region_wins']:r.LABELS['region_wins']+4])==bytes(4)
 m.idle(3);assert m.get('popup_open')==0 # Held restart Fire cannot buy/open the next popup.
 m.release();m.fire();assert m.get('popup_open')==1;m.release()
 # Verify the real main loop calls the rule automatically.
 situation(m,0,[2,0,0,0,0]);m.cpu.pc=r.LABELS['main_loop'];m.cpu.step();m.run_until(r.LABELS['main_loop']);assert m.get('screen_mode')==3 and m.get('dirty')==0
 print(f'PASS ${page:04X}: empty-army bankruptcy, all recruit lines, highest tiers, Chapel discount, 16-bit prices, live-army exemption, result timing, real main-loop trigger, rendered game over and safe fresh-game restart.')
