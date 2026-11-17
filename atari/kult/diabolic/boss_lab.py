#!/usr/bin/env python3
"""Trace real 6502 motion and search joystick-reachable routes through boss waves.

Run after build.sh. Coordinates use native colour clocks horizontally (2 pixels)
and scanlines vertically. No shield, bomb, respawn or invulnerability is allowed
in the route search. Traces disable death solely to record the complete attack.
"""
import hashlib
import json
from pathlib import Path
from py65.devices.mpu6502 import MPU
from build import kult

ROOT = Path(__file__).resolve().parent
FORMATION_COUNT=len(json.loads((ROOT.parent/'editor/boss-formations.json').read_text()))
STARTS=((12,0),(12,28),(12,56),(12,84),(12,112),(48,28),(48,56),(48,84),(72,0),(72,112),(102,0),(102,112),(0,56),(24,14),(24,98),(60,14),(60,98),(99,112))

def call(cpu, address, limit=100000):
    cpu.pc = address
    cpu.stPushWord(0x1ff)
    for _ in range(limit):
        if cpu.pc == 0x200:
            return
        cpu.step()
    raise RuntimeError(f'6502 routine failed to return: {cpu.pc:04X}')

def move(cpu, x, y, dx, dy):
    m = cpu.memory
    m[0xe957:0xe959] = [x,y]
    m[0xd300] = 15 & ~(4 if dx < 0 else 8 if dx > 0 else 0) & ~(1 if dy < 0 else 2 if dy > 0 else 0)
    call(cpu,0xe95b)
    return tuple(m[0xe957:0xe959])

def hit(x,y,bx,by,padding=0):
    # Exact unsigned comparisons in boss-sprites.asm, plus optional margin.
    return -8-padding <= bx-x < 20+padding and -16-padding*2 <= by-y < 16+padding*2

def blocked(pos,bullets,padding=0):
    x,y=pos
    # Stay clear of the fixed 64x64 boss appearance as well as its bullets.
    if x+20>88 and x<120 and y+16>32 and y<96:
        return True
    return any(hit(x,y,b[1],b[2],padding) for b in bullets)

def trace(ram,pattern,start,ticks=294,rotation_seed=1,gap_seed=0):
    c=MPU(memory=list(ram));m=c.memory
    m[0x2d78]=rotation_seed;m[0x2d7b]=gap_seed;m[0x2d7c]=24;m[0x2d74]=pattern;m[0x2d23]=88;m[0x2d24]=48;m[0x2d70]=3;m[0xf0bf]=255
    m[0xe957:0xe959]=start
    frames=[]
    for _ in range(ticks):
        call(c,0x6550)
        frames.append([[i,m[0x1bd0+i],m[0x1bd8+i]] for i in range(8) if m[0x1be0+i]])
    return frames

def movement_graph(ram):
    c=MPU(memory=list(ram))
    # Enumerate actual native joystick transitions, including asymmetric edges.
    xs={x:{d:move(c,x,56,d,0)[0] for d in (-1,0,1)} for x in range(0,103,3)}
    ys={y:{d:move(c,12,y,0,d)[1] for d in (-1,0,1)} for y in range(0,113,2)}
    graph={(x,y):{(xs[x][dx],ys[y][dy]) for dx in (-1,0,1) for dy in (-1,0,1)} for x in xs for y in ys}
    assert move(c,12,56,1,1)==(15,62)
    return graph

def allowed_positions(frames,graph,padding=1):
    return [{pos for pos in graph if not blocked(pos,bullets,padding)} for bullets in frames]

def escape(frames,start,graph,reaction=3,padding=1,allowed=None):
    if allowed is None:allowed=allowed_positions(frames,graph,padding)
    moves={old:[(old,0)]+[(pos,2*abs(pos[0]-old[0])+abs(pos[1]-old[1])) for pos in sorted(graph[old]-{old})] for old in graph}
    pauses=set()
    for window in transition_windows(frames):
        first=window['reactionStartTick']-1
        pauses.update(range(first,first+reaction))
    # A pilot beside the larger boss must retreat during entrance warm-up.
    # Normal flight positions still wait until the first formation is visible.
    initial_wait=reaction if start[0]>68 else 24+reaction
    current={start};costs={start:0};history=[];counts=[]
    for tick,bullets in enumerate(frames):
        parents={};next_costs={};permitted=allowed[tick]
        # Prefer holding position until a move becomes necessary.
        for old in sorted(current):
            choices=[(old,0)] if tick<initial_wait or tick in pauses else moves[old]
            old_cost=costs[old]
            for pos,step_cost in choices:
                if pos not in permitted:continue
                cost=old_cost+step_cost
                if cost<next_costs.get(pos,1<<30):
                    parents[pos]=old;next_costs[pos]=cost
        history.append(parents);counts.append(len(parents));current=set(parents);costs=next_costs
        if not current:return None,counts
    end=min(current,key=lambda p:abs(p[0]-start[0])+abs(p[1]-start[1]))
    route=[]
    for parents in reversed(history):route.append(list(end));end=parents[end]
    return route[::-1],counts

def replay_route(ram,pattern,start,route,frames):
    c=MPU(memory=list(ram));m=c.memory
    m[0x2d78]=1;m[0x2d7c]=24;m[0x2d74]=pattern;m[0x2d23]=88;m[0x2d24]=48;m[0x2d70]=3
    m[0xe957:0xe959]=start;m[0xf0bf]=m[0xf398]=m[0x2d61]=0
    for tick,pos in enumerate(route):
        old=tuple(m[0xe957:0xe959])
        command=next(( (dx,dy) for dx in (-1,0,1) for dy in (-1,0,1) if move(c,*old,dx,dy)==tuple(pos)),None)
        assert command is not None,(old,pos)
        move(c,*old,*command)
        call(c,0x6550)
        actual=[[i,m[0x1bd0+i],m[0x1bd8+i]] for i in range(8) if m[0x1be0+i]]
        assert actual==frames[tick],(pattern,start,tick,'trace mismatch')
        assert m[0xf398]==0,(pattern,start,tick,'native collision')
        assert not blocked(tuple(pos),actual),(pattern,start,tick,'boss collision')


def safe_bands(bullets,x=12):
    bands=[]
    for y in range(113):
        if not blocked((x,y),bullets):
            if bands and bands[-1][1]==y-1:bands[-1][1]=y
            else:bands.append([y,y])
    return bands

def pressure(frames):
    measured=[]
    for tick,bs in enumerate(frames):
        bands=safe_bands(bs)
        danger=113-sum(b-a+1 for a,b in bands)
        measured.append((danger,tick,bands))
    danger,tick,bands=max(measured,key=lambda v:v[0])
    assert danger>=97 and len(bands)==1, (danger,bands)
    return dict(tick=tick+1,blockedPercent=round(danger/113*100,1),safeBands=bands,xPixels=24)


def transition_windows(frames):
    def groups(guards):
        result=[]
        for t,bs in enumerate(frames):
            active=any((i>=6)==guards and -9<=x-12<21 for i,x,y in bs)
            if active:
                if result and result[-1][1]==t-1:result[-1][1]=t
                else:result.append([t,t])
        return result
    front=groups(False);tails=groups(True);windows=[]
    for previous,next_wave in zip(front,front[1:]):
        tail=next(g for g in tails if previous[0]<=g[0]<next_wave[0])
        before=[y for y in range(113) if not blocked((12,y),frames[previous[0]],1)]
        after=[y for y in range(113) if not blocked((12,y),frames[next_wave[0]],1)]
        required=(min(abs(a-b) for a in before for b in after)+5)//6
        available=next_wave[0]-tail[1]
        assert required+3<=available,(required,available)
        windows.append(dict(nextRushTick=next_wave[0]+1,availableUpdates=available,minimumMoveUpdates=required,reactionAllowance=3,reactionStartTick=tail[1]+2,maxReactionUpdates=available-required))
    assert all(w['maxReactionUpdates']<=4 for w in windows), ('Too much preparation time',windows)
    return windows


def build_report(ram):
    graph=movement_graph(ram);scenarios=[]
    for pattern in range(FORMATION_COUNT+1):
        frames=trace(ram,pattern,(12,56))
        allowed=allowed_positions(frames,graph)
        for x in (12,48,72,102):
            assert not any(all(not blocked((x,y),bs) for bs in frames) for y in range(113)), ('Idle safe spot',pattern,x)
        for x,y in STARTS:
            route,counts=escape(frames,(x,y),graph,allowed=allowed)
            if route:
                replay_route(ram,pattern,(x,y),route,frames)
            idle=next((i+1 for i,bs in enumerate(frames) if blocked((x,y),bs)),None)
            scenarios.append(dict(pattern=pattern,start=[x,y],frames=frames,route=route,
                initialWaitUpdates=3 if x>68 else 27,reachable=counts,idleHitTick=idle,passable=route is not None,pressure=pressure(frames),transitions=transition_windows(frames),
                safety=[dict(safePlaces=len(safe_bands(bs)),safeBands=safe_bands(bs),dangerPercent=round((113-sum(b-a+1 for a,b in safe_bands(bs)))/113*100,1)) for bs in frames]))
    return dict(executableSha256=hashlib.sha256((ROOT/'kult-diabolic.xex').read_bytes()).hexdigest(),
        units='X: Atari colour clocks (2 pixels); Y: pixels',
        ship=dict(width=40,height=16,stepX=6,stepY=6,xRange=[0,204],yRange=[0,112]),
        bullet=dict(width=16,height=16,stepX=24,maxStepY=4),
        reactionUpdates=3,safetyMarginPixels=2,cycleUpdates=30,warningUpdates=24,openingHeight=32,formationUpdates=16,chargeUpdates=2,guardDelay=16,rushStep=24,
        timingNote='Update timing depends on emulator and rendering load. Seconds use the adjustable preview rate, not a claimed fixed Atari frame rate.',
        scenarios=scenarios)

def main():
    ram=kult((ROOT/'kult-diabolic.xex').read_bytes())[0]
    report=build_report(ram)
    out=ROOT.parent/'editor/boss-lab-data.json'
    # Share native traces between starting positions instead of duplicating them.
    report['patterns']={}
    for scenario in report['scenarios']:
        shared={key:scenario.pop(key) for key in ('frames','safety','transitions','pressure')}
        report['patterns'].setdefault(str(scenario['pattern']),shared)
    temp=out.with_suffix('.json.tmp')
    temp.write_text(json.dumps(report,separators=(',',':'))+'\n')
    temp.replace(out)
    failed=[(s['pattern'],s['start']) for s in report['scenarios'] if not s['passable']]
    print(f"Native traces: {len(report['scenarios'])}; escape routes: {len(report['scenarios'])-len(failed)}; failures: {failed}")
    print(out)
    if failed:raise SystemExit(1)
if __name__=='__main__':main()
