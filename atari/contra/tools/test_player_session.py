"""Prove real menu/input operation and protected VRAM integrity during play.

Follows atari/howtotestgame/README.md: no game-state pokes, label-based
addresses, randomized VRAM, exact pause/input assertions and a guard negative
control. Timing and image hashes are evidence, not real-hardware certification.
"""
from pathlib import Path
import argparse,hashlib,json,pickle
import numpy as np
from atari_emu import Atari
from build import labels

def main():
 p=argparse.ArgumentParser();p.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1]);p.add_argument('--ntsc',action='store_true');p.add_argument('--d700',action='store_true');p.add_argument('--seed',type=int,default=23);p.add_argument('--stress',type=int,default=300);args=p.parse_args()
 r=args.root;L=labels(r/'gen/runtime.lab');N=labels(r/'gen/nes.lab')
 out=r/'gen'/('player-session-'+('ntsc' if args.ntsc else 'pal')+('-d700' if args.d700 else '-d600'));out.mkdir(exist_ok=True)
 a=Atari(r/'contra.xex',pal=not args.ntsc,vbxe_page=0xd7 if args.d700 else 0xd6)
 a.vram[:]=np.random.default_rng(args.seed).integers(0,256,len(a.vram),dtype=np.uint8);a.boot()
 for _ in range(2000000):
  if a.cpu.pc==L['NES_RESET']:break
  a.cpu.step()
 else:raise AssertionError('startup did not finish')
 baseline=a.vram.copy();protected=np.ones(len(a.vram),dtype=bool)
 sizes={'V_SLOT_BG':256*64,'V_NT_A':256*240,'V_NT_B':256*240,'V_FB0':256*240,'V_FB1':256*240,'V_CHRIDX':8192,'V_SLOT_OBJ':256*128,'V_SCRATCH':1,'V_LIST0':L['NSLOTS']*21,'V_LIST1':L['NSLOTS']*21}
 for name,size in sizes.items():protected[L[name]:L[name]+size]=False
 # XDLs are initialized before the baseline; game only changes their register pointer.
 def guard():
  changed=np.flatnonzero((a.vram!=baseline)&protected)
  assert not len(changed),f'protected VRAM changed at ${int(changed[0]):05x}'
 # Prove this test catches corruption rather than masking all of VRAM.
 addr=L['V_PRG'];a.vram[addr]^=1
 try:guard()
 except AssertionError:pass
 else:raise AssertionError('guard negative control failed')
 a.vram[addr]^=1;guard()
 hashes=[];states=[]
 def val(name):return a.mem.ram[N[name]]
 def step(n=1,**inputs):
  a.set_input(**inputs)
  for _ in range(n):
   a.run_frames(1);guard()
   if a.frame%30==0:hashes.append([a.frame,hashlib.sha256(a.screenshot(scale=1).tobytes()).hexdigest()])
 def until(fn,budget,description):
  for _ in range(budget):
   step()
   if fn():states.append([description,a.frame]);print(description,a.frame,flush=True);return
  raise AssertionError(description+' timed out')
 until(lambda:val('GAME_ROUTINE_INDEX')==1 and val('HORIZONTAL_SCROLL')==0,1200,'title menu')
 step(8);assert val('PLAYER_MODE')==0
 step(5,consol=5);step(5);assert val('PLAYER_MODE')==1,'SELECT did not choose two players'
 a.screenshot(out/'menu.png')
 step(5,key=0x0c);step(5) # RETURN enters through the keyboard IRQ path.
 until(lambda:val('GAME_ROUTINE_INDEX')==5 and val('LEVEL_ROUTINE_INDEX')==4 and a.mem.ram[L['SCENE_READY']] and not a.mem.ram[L['IN_VBI']],1600,'two-player game')
 assert val('DEMO_MODE')==0 and val('PLAYER_MODE_1D')&4
 assert val('P2_GAME_OVER_STATUS')==0
 step(25)
 bullets=False;positions=set();flips=len(a.xdl_addr_log);start=a.frame
 for f in range(90):
  step(stick=7,trig=1,stick1=7,trig1=1,shift=20<=f<40)
  if f in (10,30):
   assert a.mem.ram[L['NES_BUTTONS']]==(0xc1 if f==30 else 0x41),'player 1 shoot/jump mapping'
   assert a.mem.ram[L['NES_BUTTONS2']]==0x41,'player 2 right/fire mapping'
  positions.add((val('SPRITE_X_POS'),val('SPRITE_Y_POS')))
  bullets |= any(a.mem.ram[N['PLAYER_BULLET_ROUTINE']:N['PLAYER_BULLET_ROUTINE']+16])
 assert bullets and len(positions)>4
 assert a.mem.ram[N['SPRITE_X_POS']+1]>32
 gameplay_flips=(len(a.xdl_addr_log)-flips)//3
 step(5,consol=6);step(8);assert val('PAUSE_STATE')==1
 position=bytes(a.mem.ram[N['SPRITE_X_POS']:N['SPRITE_X_POS']+2])+bytes(a.mem.ram[N['SPRITE_Y_POS']:N['SPRITE_Y_POS']+2])
 step(30,stick=7,stick1=11,trig=1,trig1=1,shift=True)
 assert position==bytes(a.mem.ram[N['SPRITE_X_POS']:N['SPRITE_X_POS']+2])+bytes(a.mem.ram[N['SPRITE_Y_POS']:N['SPRITE_Y_POS']+2]),'paused players moved'
 step(5,consol=6);step(8);assert val('PAUSE_STATE')==0
 for f in range(args.stress):step(stick=7 if f%120<90 else 11,trig=1,shift=f%60<12,stick1=7,trig1=1)
 assert a.mem.ram[0x4000:0x8000]==(r/'gen/contra.bin').read_bytes()[-16384:]
 assert any(row[ch]&15 for row in a.pokey_log for ch in (1,3,5,7)),'no audible POKEY channel volume'
 a.screenshot(out/'game.png')
 with (out/'session.pkl').open('wb') as f:pickle.dump(a,f)
 report={'sha256':hashlib.sha256(a.xex).hexdigest(),'video_frames':a.frame,'seed':args.seed,'states':states,'two_player_menu':True,'exact_shoot_jump_input_bits':True,'pokey_volume_active':True,'return_keyboard_start':True,'pause_resume':True,'guard_negative_control':True,'protected_vram_bytes':int(protected.sum()),'protected_vram_unchanged':True,'fixed_game_bank_intact':True,'gameplay_pictures_in_90_frames':gameplay_flips,'screenshot_hashes':hashes,'xdl_writes':a.xdl_addr_log}
 (out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('PASS real-input session and VRAM guards',flush=True)
if __name__=='__main__':main()
