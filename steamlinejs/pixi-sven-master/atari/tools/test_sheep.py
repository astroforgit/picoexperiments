#!/usr/bin/env python3
"""Behavior checks against the assembled sheep routines and renderer."""
from test_runtime import Machine, LABELS

def check(rate):
    m=Machine(rate=rate);m.start();m.call('restart')
    def at(name,i=0):return m.mem.ram[LABELS[name]+i]
    def put(name,i,value):m.mem.ram[LABELS[name]+i]=value
    def positions():return [(at('sheep_x',i),at('sheep_y',i)) for i in range(8)]
    homes=positions();seen=set()
    m.put('px',250);m.put('py',160)
    for tick in range(512):
        m.put('world_tick',tick%256);m.call('update_sheep')
        for i,(x,y) in enumerate(positions()):
            if (x,y)!=homes[i]:seen.add(i)
            assert abs(x-homes[i][0])<=12 and abs(y-homes[i][1])<=8
            m.cpu.a=x;m.cpu.y=y;m.call('point_is_water')
            assert not m.cpu.p&1, ('sheep entered water',i,x,y)
    assert seen==set(range(8)),seen
    m.call('restart');assert positions()==homes
    # Four approaches select the matching ordinary and combined frames.
    x,y=homes[1]
    for direction,(dx,dy) in enumerate(((0,10),(0,-10),(-15,0),(15,0))):
        m.put('px',x+dx);m.put('py',y+dy)
        for tick in range(16):m.put('world_tick',tick);m.call('update_sheep')
        assert positions()[1]==(x,y) and at('sheep_direction',1)==direction
        m.call('build_actors');assert at('actor_tile',1)==20+direction
        m.put('previous_target',1);m.call('build_actors')
        assert 69+direction*5<=at('actor_tile',1)<74+direction*5
        m.put('previous_target',255)
    # A whistle outside interaction range calms and visibly attracts sheep.
    m.put('px',x+35);m.put('py',y);m.put('fire',1);m.put('fire_pending',1)
    m.put('moving',0);m.put('whistle_pending',1);put('sheep_age',1,45);m.call('interact')
    assert at('sheep_reaction',1)==75 and at('sheep_age',1)==21
    assert at('sheep_direction',1)==3
    m.call('render')
    if rate==50:m.screenshot('sheep-whistle.png')
    assert any(b[0]>=0x2fa00+89*56*32 for b in m.mem.blits)
    reaction_position=positions()[1]
    for _ in range(75):m.call('update_sheep')
    assert positions()[1]==reaction_position and at('sheep_reaction',1)==0
    # Pause freezes position, facing and reaction timers together.
    put('sheep_reaction',1,50);m.put('mode',4)
    frozen=(positions(),at('sheep_reaction',1),at('sheep_direction',1))
    m.frame(rate*3)
    assert frozen==(positions(),at('sheep_reaction',1),at('sheep_direction',1))
    m.call('restart');assert positions()==homes and not any(at('sheep_reaction',i) for i in range(8))
    print(f'PASS {rate}Hz sheep: wandering, dry bounds, approach/facing, four love directions, whistle hearts/expiry, pause and restart')

if __name__=='__main__':
    for rate in (50,60):check(rate)
