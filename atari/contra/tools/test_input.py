"""Input regressions: no phantom buttons from the POT scan, menus by joystick.

The emulator models POKEY's POT counting (one count per scan line after
POTGO), so a scan restarted by a mid-frame DLI tick reads half-counted
lines, which the runtime once took for a held jump button on PAL.
"""
from pathlib import Path
from atari_emu import Atari
from build import labels
R=Path(__file__).resolve().parents[1];L=labels(R/'gen/runtime.lab')
GAME_ROUTINE,PLAYER_MODE=0x18,0x22
def press(a,frames=4,**k):a.set_input(**k);a.run_frames(frames);a.set_input()
report={}
for pal in (True,False):
 name='pal' if pal else 'ntsc'
 a=Atari(R/'contra.xex',pal=pal,vbxe_page=0xd6);a.boot()
 press(a,200,trig=1)                      # fire held while loading must not count
 a.run_frames(200)
 assert a.mem.ram[GAME_ROUTINE]==1,(name,'title not reached',a.mem.ram[GAME_ROUTINE])
 menu=lambda:(a.mem.ram[PLAYER_MODE],a.mem.ram[0x09FC])
 for stick,want in [(0xd,(1,0)),(0xd,(0,1)),(0xd,(0,1)),(0xe,(1,0)),(0xe,(0,0)),(0xe,(0,0))]:
  press(a,stick=stick);a.run_frames(10)   # down moves the cursor down, up moves it up
  assert menu()==want,(name,hex(stick),menu(),want)
 press(a,trig=1);a.run_frames(600)        # fire = Start
 assert a.mem.ram[GAME_ROUTINE]==5,(name,'fire did not start the game')
 held=0
 for _ in range(300):a.run_frames(1);held+=a.mem.ram[L['NES_BUTTONS']]!=0
 assert held==0,(name,'phantom buttons in',held,'gameplay frames')
 report[name]={'idle_frames_without_buttons':300,'joystick_select':True,'fire_starts_game':True}
print('PASS',report)
