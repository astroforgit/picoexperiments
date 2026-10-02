#!/usr/bin/env python3
"""Assembled mechanics: devil lifecycle, shocks, mushrooms and recovery."""
from test_runtime import Machine, LABELS

def test(rate):
    m=Machine(rate=rate);m.start();m.call('restart')
    def at(n,i=0):return m.mem.ram[LABELS[n]+i]
    def put(n,i,v):m.mem.ram[LABELS[n]+i]=v
    def park():
        put('enemy_x',0,245);put('enemy_y',0,155)
        put('enemy_x',1,240);put('enemy_y',1,155)
    for age,expected in ((19,20),(34,35),(49,50),(51,52)):
        put('sheep_age',0,age);put('devil_seconds',0,0);m.call('age_sheep')
        assert at('sheep_age')==expected
    assert at('devil_seconds')==8
    for _ in range(8):m.call('age_sheep')
    assert at('sheep_age')==20 and at('devil_seconds')==0
    assert at('pasture_x')==at('sheep_x') and at('pasture_y')==at('sheep_y')
    # Dark-cloud sheep take steps on ticks when calm sheep remain still.
    m.call('restart');m.put('px',250);m.put('py',160);m.put('world_tick',4)
    pos=(at('sheep_x'),at('sheep_y'));m.call('update_sheep')
    assert (at('sheep_x'),at('sheep_y'))==pos
    put('sheep_age',0,35);m.call('update_sheep')
    assert (at('sheep_x'),at('sheep_y'))!=pos
    # Refusal at dark clouds; final lightning cannot be whistled away.
    m.put('px',at('sheep_x'));m.put('py',at('sheep_y'))
    for age in (35,49,50,52):
        put('sheep_age',0,age);m.call('find_target');assert m.get('target')==255
    m.put('px',at('sheep_x')+35)
    for age,expected in ((49,25),(50,50),(52,52)):
        put('sheep_age',0,age);m.put('whistle_cooldown',0);m.put('whistle_pending',1)
        m.call('interact');assert at('sheep_age')==expected
    # A shock subtracts points once, freezes in place, and leaves enemy danger.
    m.call('restart');park();put('sheep_age',0,52);put('devil_seconds',0,8)
    m.put('px',at('sheep_x'));m.put('py',at('sheep_y'));m.put('points',25)
    pos=(m.get('px'),m.get('py'));m.call('check_hazards')
    assert m.get('lives')==3 and m.get('points')==15 and m.get('stun_ticks')==100
    assert (m.get('px'),m.get('py'))==pos and m.get('invulnerable')==0
    m.call('check_hazards');assert m.get('points')==15
    m.put('stick',7);m.call('game_tick');assert (m.get('px'),m.get('py'))==pos
    m.put('world_tick',2);m.call('render')
    if rate==50:m.screenshot('devil-shock.png')
    put('enemy_x',0,m.get('px'));put('enemy_y',0,m.get('py'));m.call('check_hazards')
    assert m.get('lives')==2 and m.get('shock_ticks')==0
    m.put('points',5);m.put('shock_cooldown',0);m.call('electrical_hit');assert m.get('points')==0
    # Good mushroom consumes once and doubles movement, then expires.
    m.call('restart');park();m.put('px',at('mushroom_x'));m.put('py',at('mushroom_y'))
    m.call('check_mushrooms');assert m.get('speed_ticks')==250 and at('mushroom_alive')==0
    m.put('px',120);m.put('py',70);m.put('stick',7);m.put('fire',0)
    m.call('game_tick');assert m.get('px')==124
    m.put('speed_ticks',1);m.call('game_tick');assert m.get('speed_ticks')==0 and m.get('px')==126
    # Foul mushroom affects nearby sheep only and does not shorten existing devils.
    m.call('restart');m.put('px',at('mushroom_x',1));m.put('py',at('mushroom_y',1))
    put('sheep_x',0,m.get('px')-20);put('sheep_y',0,m.get('py'))
    put('sheep_x',1,30);put('sheep_y',1,30)
    m.call('check_mushrooms');assert at('mushroom_alive',1)==0 and at('sheep_age')==50
    assert at('sheep_age',1)==4
    m.call('age_sheep');m.call('age_sheep');assert at('sheep_age')==52
    m.call('build_actors');assert 94<=at('actor_tile')<=97
    m.call('render')
    if rate==50:m.screenshot('devil-mushrooms.png')
    # Devils roam beyond normal home bounds but cannot leave the screen/water.
    m.put('px',140);m.put('py',100)
    for tick in range(256):
        m.put('world_tick',tick);m.call('update_sheep')
        for i in range(8):
            assert 10<=at('sheep_x',i)<=250 and 14<=at('sheep_y',i)<=160
    m.put('mode',4);m.put('speed_ticks',80);m.put('shock_ticks',30)
    frozen=(m.get('speed_ticks'),m.get('shock_ticks'),at('devil_seconds'))
    m.frame(rate*3);assert frozen==(m.get('speed_ticks'),m.get('shock_ticks'),at('devil_seconds'))
    m.call('restart');assert m.get('speed_ticks')==m.get('shock_ticks')==0
    assert at('mushroom_alive')==at('mushroom_alive',1)==1
    assert not any(at('devil_seconds',i) for i in range(8))
    print(f'PASS {rate}Hz moods: four stages, devil recovery, refusal/whistle boundary, shock stun/points/enemy vulnerability, mushrooms/speed, bounds, pause and restart')
if __name__=='__main__':
    for rate in (50,60):test(rate)
