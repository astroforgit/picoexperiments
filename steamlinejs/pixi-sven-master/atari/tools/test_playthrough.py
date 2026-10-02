#!/usr/bin/env python3
"""Play through the real assembled simulation using only joystick/fire inputs.
The controller reads actor positions as an observer; it does not alter game state.
"""
from test_runtime import Machine, LABELS

def play(rate):
    m=Machine(rate=rate)
    m.start()
    previous=(0,3)
    escape=False
    for frame in range(rate*120):
        if m.get('mode')!=1:break
        pending=[i for i in range(8) if m.mem.ram[LABELS['alive']+i]==1]
        if not pending:break
        enemies=[(m.mem.ram[LABELS['enemy_x']+i],m.mem.ram[LABELS['enemy_y']+i]) for i in range(2)]
        enemies += [(m.mem.ram[LABELS['sheep_x']+i],m.mem.ram[LABELS['sheep_y']+i]) for i in pending if m.mem.ram[LABELS['sheep_age']+i]>=52]
        px,py=m.get('px'),m.get('py')
        def target_cost(i):
            x,y=m.mem.ram[LABELS['sheep_x']+i],m.mem.ram[LABELS['sheep_y']+i]
            danger=min(abs(x-ex)+2*abs(y-ey) for ex,ey in enemies)
            return abs(x-px)+2*abs(y-py)+max(0,100-danger)*3
        sheep=m.get('previous_target')
        if sheep not in pending:sheep=min(pending,key=target_cost)
        separation=min(abs(px-x)+2*abs(py-y) for x,y in enemies)
        if m.get('invulnerable')>=25:escape=False
        elif separation<48:escape=True
        elif separation>90:escape=False
        dx=m.mem.ram[LABELS['sheep_x']+sheep]-m.get('px')
        dy=m.mem.ram[LABELS['sheep_y']+sheep]-m.get('py')
        if escape:
            candidates=[(hx,hy) for hx in (-1,0,1) for hy in (-1,0,1) if hx or hy]
            def safety(v):
                x,y=px+v[0]*20,py+v[1]*10
                if not (10<=x<=250 and 14<=y<=160):return -10000
                return min(abs(x-ex)+2*abs(y-ey) for ex,ey in enemies)
            hx,hy=max(candidates,key=safety)
            dx,dy=hx*20,hy*10
        stick=15
        if abs(dx)>3:stick &= ~(8 if dx>0 else 4)
        if abs(dy)>2:stick &= ~(2 if dy>0 else 1)
        storm=m.mem.ram[LABELS['sheep_age']+sheep]>=35
        whistle=storm and not escape and abs(dx)<65 and abs(dy)<38
        if whistle:stick=15
        m.mem.ram[0xd300]=240|stick
        m.mem.ram[0xd010]=(frame%2 if whistle else (0 if stick==15 else 1))
        m.frame()
        current=(m.get('score'),m.get('lives'))
        if current!=previous:
            print(f'{rate}Hz {frame/rate:.2f}s: sheep={current[0]}, lives={current[1]}, timer={m.get("seconds")}')
            previous=current
    assert m.get('mode')==2,(rate,m.get('mode'),m.get('score'),m.get('lives'),m.get('seconds'))
    m.call('render')
    if rate==50:m.screenshot('milestone-playthrough-win.png')
    print(f'PASS {rate}Hz: complete input-only playthrough with enemies, moods and water enabled')

if __name__=='__main__':
    for rate in (50,60):play(rate)
