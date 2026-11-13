#!/usr/bin/env python3
"""Trace real game input, players, camera targets and published XDL in the headless model."""
import argparse,csv,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/reference'))
from atari_emu import Atari,load_labels
p=argparse.ArgumentParser()
p.add_argument('--case',choices=['neutral','left-release','port2-left','ntsc','fire-recover','wait-recover'],default='left-release')
p.add_argument('--frames',type=int,default=1000)
args=p.parse_args()
r=load_labels(ROOT/'gen/runtime.asm.lab');a=Atari(ROOT/'pilka.xex',pal=args.case!='ntsc');a.boot();m=a.mem.ram
for _ in range(2_000_000):
    if a.cpu.pc==0x975b:break
    a.cpu.step()
else:raise AssertionError('Boot failed')
a.next_frame=a.cpu.processorCycles+a.frame_cycles
def press(stick=15,fire=False):
    a.set_input(stick=stick,trig=fire);a.run_frames(7);a.set_input();a.run_frames(7)
a.run_frames(24);press(fire=True);press(fire=True);press(fire=True)
for _ in range(100):
    a.run_frames(2)
    if not m[r['MENU_MODE']]:break
assert not m[r['MENU_MODE']], 'Match did not start'
loops=0
original_step=a.cpu.step
def step():
    global loops
    if a.cpu.pc==r['GAME_HOOK']:loops+=1
    return original_step()
a.cpu.step=step
out=ROOT/'analysis/camera-traces';out.mkdir(exist_ok=True)
rows=[]
def word(lo,hi):return int(m[lo])+(int(m[hi])<<8)
for frame in range(args.frames):
    # Neutral start, sustained left, release, then right to test recovery.
    phase='neutral' if frame<100 else 'left' if frame<500 else 'release' if frame<650 else 'right'
    stick=15 if args.case in ('neutral','port2-left') else 11 if phase=='left' else 7 if phase=='right' and args.case not in ('fire-recover','wait-recover') else 15
    stick2=11 if args.case=='port2-left' and phase=='left' else 15
    # Pulsed kick/switch starts play; do not hold fire while testing release.
    fire=(frame%90<3) and phase not in ('release',)
    if args.case=='wait-recover' and frame>=500:fire=False
    a.set_input(stick=stick,stick1=stick2,trig=fire)
    a.run_frames(1)
    player=int(m[0x012d]);valid=player<22
    player2=int(m[0x012e]);valid2=player2<22
    rows.append(dict(frame=frame,phase=phase,port_a=a.mem[0xd300],joy1=m[r['JOY1']],joy2=m[r['JOY2']],engine_joy1=m[0x082b],engine_joy2=m[0x082a],controller0=m[0xe282],controller1=m[0xe283],player=player,player_x=word(0x049a+player,0x0500+player) if valid else -1,player_y=word(0x04b0+player,0x0516+player) if valid else -1,player2=player2,player2_x=word(0x049a+player2,0x0500+player2) if valid2 else -1,player2_y=word(0x04b0+player2,0x0516+player2) if valid2 else -1,ball_x=word(0x24d1,0x24d2),ball_y=word(0x24d9,0x24da),map_x=m[0xe80e],map_y=m[0xe80f],map_hi_x=m[0xe810],map_hi_y=m[0xe811],target_x=word(0xe81a,0xe81c),target_y=word(0xe81b,0xe81d),camera_dx=m[0xe816],camera_dy=m[0xe817],ring_x=m[r['OX']],ring_y=m[r['OY']],fine_x=m[0x11d7],fine_y=m[0x11d8],state=m[0x974d],loops=loops,front=m[r['FRONT']],xdl=a.vregs[0x41]|a.vregs[0x42]<<8|a.vregs[0x43]<<16,pc=a.cpu.pc))
    if frame in (99,499,649,args.frames-1):a.screenshot(out/f'{args.case}-{frame}.png',scale=1)
with (out/f'{args.case}.csv').open('w',newline='') as f:
    writer=csv.DictWriter(f,fieldnames=rows[0]);writer.writeheader();writer.writerows(rows)
summary=dict(case=args.case,frames=args.frames,loops=loops,phases={},limitations='Headless PAL/NTSC timing model; not a trace from the reporting user')
for phase in ('neutral','left','release','right'):
    data=[d for d in rows if d['phase']==phase]
    if data:summary['phases'][phase]=dict(joy1=sorted(set(d['joy1']&15 for d in data[2:])),joy2=sorted(set(d['joy2']&15 for d in data[2:])),map_x_range=[min(d['map_x'] for d in data),max(d['map_x'] for d in data)],target_x_range=[min(d['target_x'] for d in data),max(d['target_x'] for d in data)],loops=data[-1]['loops']-data[0]['loops'],last=data[-1])
assert all(d['xdl'] in (0x6f000,0x6f020) for d in rows)
assert all(d['ring_x']<40 and d['ring_y']<25 for d in rows)
(out/f'{args.case}.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary),flush=True)
