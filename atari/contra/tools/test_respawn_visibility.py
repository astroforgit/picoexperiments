"""Check spawn and genuine death/respawn handling under paced PAL and NTSC.

Start with real menu input. A test-only breakpoint redirects one normal player
update to the game's kill_player routine, then the game performs its own death
animation, life loss and respawn. Observe completed game NMIs after a sprite has been assigned, never mid-update.
The first initialization tick precedes assignment of the player sprite.
"""
from pathlib import Path
import json,hashlib
from atari_emu import Atari
from build import labels
R=Path(__file__).resolve().parents[1];L=labels(R/'gen/runtime.lab');N=labels(R/'gen/nes.lab')
records=[]
for pal,page in [(True,0xd6),(False,0xd7)]:
 a=Atari(R/'contra.xex',pal=pal,vbxe_page=page);a.boot()
 phase='spawn';kill=False;counts={'spawn':0,'respawn':0};palettes={'spawn':set(),'respawn':set()};death_seen=False
 step=a.cpu.step
 def observed_step():
  global phase,kill,death_seen
  ram=a.mem.ram
  if kill and a.cpu.pc==N['PLAYER_STATE_ROUTINE_01'] and a.cpu.x==0:
   a.cpu.pc=N['KILL_PLAYER'];kill=False;phase='respawn'
  if a.cpu.pc==L['NM_GAME_DONE'] and ram[N['GAME_ROUTINE_INDEX']]==5:
   death_seen |= ram[N['PLAYER_STATE']]==2
   if ram[N['PLAYER_STATE']]==1 and ram[N['NEW_LIFE_INVINCIBILITY_TIMER']] and not ram[N['PLAYER_HIDDEN']] and ram[N['PLAYER_SPRITE_CODE']]:
    assert ram[N['PLAYER_SPRITES']]!=0,(pal,phase,'invisible protected player',ram[N['FRAME_COUNTER']],ram[N['NEW_LIFE_INVINCIBILITY_TIMER']],ram[N['PLAYER_SPRITE_CODE']])
    assert ram[N['SPRITE_ATTR']]&4,(pal,phase,'missing protection palette')
    counts[phase]+=1;palettes[phase].add(ram[N['SPRITE_ATTR']]&7)
  step()
 a.cpu.step=observed_step
 for _ in range(1200):
  a.run_frames(1)
  if a.mem.ram[N['GAME_ROUTINE_INDEX']]==1 and a.mem.ram[N['HORIZONTAL_SCROLL']]==0:break
 else:raise AssertionError('title timeout')
 a.set_input(trig=1);a.run_frames(5);a.set_input()
 for _ in range(1600):
  a.run_frames(1)
  if counts['spawn']>20 and a.mem.ram[N['NEW_LIFE_INVINCIBILITY_TIMER']]==0:break
 else:raise AssertionError('initial immunity did not run/expire')
 assert palettes['spawn']=={4,5}
 kill=True
 for _ in range(700):
  a.run_frames(1)
  if counts['respawn']>=40:break
 else:raise AssertionError('respawn immunity not observed')
 assert death_seen and palettes['respawn']=={4,5}
 a.cpu.step=step
 a.screenshot(R/f'gen/respawn-{("pal" if pal else "ntsc")}.png')
 rec={'standard':'PAL' if pal else 'NTSC','vbxe_page':hex(page),'visible_protected_updates':counts,'death_animation_seen':death_seen,'both_palette_phases':True}
 records.append(rec);print('PASS',rec,flush=True)
(R/'gen/respawn-visibility.json').write_text(json.dumps({'sha256':hashlib.sha256((R/'contra.xex').read_bytes()).hexdigest(),'cases':records},indent=2)+'\n')
