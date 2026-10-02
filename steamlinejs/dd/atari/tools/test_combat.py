#!/usr/bin/env python3
"""Combat regressions executed against the assembled Atari 6502 game."""
from test_runtime import Machine
from copy import deepcopy


def arena(kind=1, slot=0):
    # Boot/upload once; each scenario still gets isolated CPU/RAM/VRAM state.
    if not hasattr(arena, 'booted'):
        arena.booted = Machine()
    m = deepcopy(arena.booted)
    m.call('restart')
    m.set('px', 100); m.set('py', 170)
    m.set('immune', 0); m.set('stick', 15); m.set('fire', 0)
    for i in range(3): m.set('enemy_hp', 0, i)
    m.set('remaining', 1)
    for name, value in [('enemy_type',kind), ('enemy_hp',32), ('enemy_x',124),
                        ('enemy_y',170), ('enemy_face',4), ('enemy_state',0),
                        ('enemy_cool',0), ('enemy_stun',0)]:
        m.set(name, value, slot)
    return m


def ticks(m, count):
    for _ in range(count): m.call('update')


def check():
    report = []
    for kind in (1,2):
        for facing, px, ex, landing in ((0,100,116,82),(4,100,84,118),
                                       (0,10,26,4),(4,245,229,252)):
            m = arena(kind); m.set('px',px); m.set('enemy_x',ex)
            m.set('facing',facing); m.set('enemy_state',2); m.set('enemy_cool',19)
            m.set('stick',13); m.set('fire',1)
            ticks(m,1); m.set('fire',0); m.set('stick',15)
            assert m.get('attack_kind') == 3 and m.get('grab_target') == 0
            assert m.get('enemy_state') == 8
            m.call('build_actors')
            assert m.get('actor_tile') == facing+2
            assert m.get('actor_tile',1) == kind*8+m.get('enemy_face')+2
            ticks(m,9)
            assert m.get('enemy_hp') == 32 and m.get('enemy_x') == ex
            assert m.get('health') == 12 and m.get('enemy_state') == 8
            ticks(m,1)
            assert m.get('enemy_hp') == 28 and m.get('enemy_state') == 5
            recoil = -2 if facing == 0 else 2
            assert m.get('enemy_x') == max(4,min(252,landing+recoil))
            assert m.get('grab_target') == 255
            m.call('player_hit')
            assert m.get('enemy_hp') == 28, 'throw damaged twice'
    for invalid in ('boss','active','guard','down','behind','depth','range'):
        m = arena(3 if invalid == 'boss' else 1)
        m.set('enemy_x',116); m.set('enemy_state',2); m.set('enemy_cool',19)
        if invalid == 'active': m.set('enemy_state',0)
        elif invalid == 'guard': m.set('enemy_state',3)
        elif invalid == 'down': m.set('enemy_state',6)
        elif invalid == 'behind': m.set('enemy_x',84)
        elif invalid == 'depth': m.set('enemy_y',179)
        elif invalid == 'range': m.set('enemy_x',119)
        m.set('stick',13); m.set('fire',1); ticks(m,1)
        assert m.get('grab_target') == 255, invalid
        assert m.get('attack_kind') == 3 and m.get('attack') == 18
        m.call('player_hit'); assert m.get('enemy_hp') == 32
    m = arena(); m.set('enemy_x',116); m.set('enemy_stun',3)
    m.call('try_grab'); assert m.get('enemy_state') == 8
    m.call('lose_life')
    assert m.get('grab_target') == 255 and m.get('enemy_state') != 8
    for reset in ('new_wave','restart'):
        m = arena(); m.set('enemy_x',116); m.set('enemy_stun',3)
        m.call('try_grab'); m.call(reset)
        assert m.get('grab_target') == 255
        assert all(m.get('enemy_state',i) != 8 for i in range(3))
    m = arena(); m.set('enemy_x',116); m.set('enemy_state',2)
    m.set('stick',13); m.set('fire',1); ticks(m,1)
    for name,value in [('enemy_hp',32),('enemy_type',1),('enemy_x',124),
                       ('enemy_y',170),('enemy_face',4),('enemy_state',1),('enemy_cool',1)]:
        m.set(name,value,1)
    ticks(m,1)
    assert m.get('health') == 10 and m.get('attack') == 0
    assert m.get('grab_target') == 255 and m.get('enemy_state') == 2
    m = arena(); m.set('enemy_x',116); m.set('enemy_state',2)
    m.set('enemy_hp',4); m.set('attack_kind',3); m.call('try_grab'); m.call('player_hit')
    assert m.get('remaining') == 0 and m.get('points') == 1
    m.call('player_hit'); assert m.get('points') == 1
    m = arena()
    for i, ex in enumerate((118,110,114)):
        m.set('enemy_x',ex,i); m.set('enemy_hp',32,i)
        m.set('enemy_type',1,i); m.set('enemy_state',2,i); m.set('enemy_y',170,i)
    m.call('try_grab')
    assert m.get('grab_target') == 1
    assert [m.get('enemy_state',i) for i in range(3)] == [2,8,2]
    report.append('Grab/throw: input, vulnerable target selection, hold timing, damage, recoil bounds, interruption and lethal release: PASS')
    # Drive the actual input/windup path: a forced guard fixture alone misses
    # guards expiring before a long kick's impact.
    for stick, expected_hp in ((15,32), (7,31), (14,29)):
        m = arena(); m.set('ai_random',8)
        m.set('stick',stick); m.set('fire',1)
        m.call('update'); m.set('fire',0); m.set('stick',15)
        assert m.get('enemy_state') == 3
        ticks(m, m.get('attack')-8)
        assert m.get('enemy_hp') == expected_hp
        if stick == 15:
            assert m.get('enemy_counter') == 1
            ticks(m,m.get('enemy_cool'))
            assert m.get('enemy_state') == 1 and m.get('health') == 12
            assert m.get('enemy_cool') == m.get('enemy_startup',1)
            ticks(m,4)
            assert m.get('health') == 12, 'instant block counter'
            ticks(m,1)
            assert m.get('health') == 10
        else:
            assert m.get('enemy_counter') == 0, 'interrupted guard retained counter'
    for escape in ('behind','depth','range'):
        m = arena(); m.set('enemy_state',3); m.set('enemy_cool',1)
        m.set('attack_kind',0); m.call('player_hit')
        assert m.get('enemy_counter') == 1
        if escape == 'behind': m.set('px',140)
        elif escape == 'depth': m.set('py',145)
        else: m.set('px',60)
        ticks(m,1)
        assert m.get('enemy_state') == 0 and m.get('health') == 12
        assert m.get('enemy_counter') == 0
    m = arena(); m.set('enemy_state',3); m.set('enemy_cool',1)
    ticks(m,1)
    assert m.get('enemy_state') == 0, 'guard without contact earned a counter'
    m = arena(); m.set('attack',16); m.set('ai_random',2)
    ticks(m,1)
    assert m.get('enemy_reacted') == 1 and m.get('enemy_state') != 3
    m.set('enemy_state',0); m.set('enemy_cool',0); m.set('ai_random',8)
    ticks(m,1)
    assert m.get('enemy_state') != 3, 'second reaction roll on same swing'
    m.set('attack',0); m.set('enemy_state',0); m.set('enemy_cool',0)
    m.set('ai_random',8); m.set('fire',1)
    ticks(m,1)
    assert m.get('enemy_state') == 3, 'fresh swing did not reset reaction'
    for kind in (1,2,3):
        for miss in (False,True):
            m = arena(kind); ticks(m,1)
            if miss: m.set('py',145)
            ticks(m,m.get('enemy_startup',kind))
            recovery = m.get('enemy_recovery',kind)+(6 if miss else 0)
            assert m.get('enemy_state') == 2 and m.get('enemy_cool') == recovery
            ticks(m,recovery-1)
            assert m.get('enemy_state') == 2
            ticks(m,1)
            assert m.get('enemy_state') == 0
        m = arena(kind); m.set('enemy_state',2)
        m.set('enemy_cool',m.get('enemy_miss_recovery',kind))
        m.set('attack_kind',0); m.call('player_hit')
        assert m.get('enemy_hp') == 31 and m.get('enemy_state') == 0
        assert m.get('enemy_stun') > 0, 'recovery could not be punished'
    report.append('Timed guards, earned/escapable counters, one reaction per swing, longer missed-swing recovery: PASS')
    for kind in (1, 2, 3):
        for facing, x, px, end in ((0,124,100,136), (4,76,100,64),
                                   (0,250,230,252), (4,5,25,4)):
            m = arena(kind)
            m.set('px',px); m.set('enemy_x',x)
            m.set('facing',facing); m.set('attack_kind',2)
            m.set('enemy_state',1); m.set('enemy_cool',1)
            m.call('player_hit')
            assert m.get('enemy_hp') == 29 and m.get('enemy_state') == 5
            assert m.get('enemy_pose') == 3 and m.get('enemy_stun') == 0
            hp = m.get('health')
            m.call('player_hit')
            assert m.get('enemy_hp') == 29, 'falling enemy took another hit'
            m.call('build_actors')
            assert m.get('actor_tile',1) == kind*8+(facing ^ 4)+3
            ticks(m,6)
            assert m.get('enemy_x') == end and m.get('enemy_state') == 6
            for state, duration in ((6,22), (7,10)):
                for _ in range(duration):
                    assert m.get('enemy_state') == state
                    for attack_kind in (0,1,2):
                        m.set('attack_kind',attack_kind); m.call('player_hit')
                        assert m.get('enemy_hp') == 29
                    m.call('update')
                    assert m.get('enemy_x') == end and m.get('health') == hp
                    m.call('build_actors')
                    if m.get('enemy_state') != 0:
                        pose = 3 if state == 6 else 1
                        assert m.get('actor_tile',1) == kind*8+(facing ^ 4)+pose
            assert m.get('enemy_state') == 0
            m.set('px', max(4,end-24)); m.set('enemy_face',4)
            ticks(m,30)
            assert m.get('health') < hp, 'enemy failed to resume attacking'
    for attack_kind in (0,1):
        m = arena(); m.set('attack_kind',attack_kind); m.call('player_hit')
        assert m.get('enemy_state') == 0 and m.get('enemy_stun') == 7
    m = arena(); m.set('enemy_hp',3); m.set('attack_kind',2)
    m.call('player_hit')
    assert m.get('enemy_hp') == 0 and m.get('remaining') == 0
    m.call('new_wave')
    assert all(m.get('enemy_state',i) == 0 for i in range(3))
    assert all(m.get('enemy_reacted',i) == m.get('enemy_counter',i) == 0 for i in range(3))
    report.append('Jump-kick knockdown: all species, recoil edges, protected prone/get-up, AI resumes, lethal hit/wave reset: PASS')
    for kind, damage in ((1,2), (2,2), (3,5)):
        m = arena(kind)
        hp = m.get('health')
        m.call('update')
        startup = m.get('enemy_startup',kind)
        assert m.get('enemy_state') == 1 and m.get('health') == hp
        ticks(m, startup-1)
        assert m.get('health') == hp, 'damage before committed strike'
        m.call('update')
        assert m.get('health') == hp-damage, (kind, m.get('health'))
        assert m.get('player_stun') == 8 and m.get('enemy_state') == 2
        ticks(m, 10)
        assert m.get('health') == hp-damage, 'multiple damage events during recovery'
    report.append('Distinct startup/recovery; Williams/Linda 2 damage, Abobo 5; single impact: PASS')
    for move in ('depth', 'behind'):
        m = arena()
        m.call('update')
        hp = m.get('health')
        m.set('py',150) if move == 'depth' else m.set('px',150)
        ticks(m, 5)
        assert m.get('health') == hp and m.get('enemy_state') == 2
    report.append('Committed attacks miss when Billy leaves the lane or moves behind the attacker: PASS')
    for phase, hit in ((22,True), (18,False), (12,False), (6,True), (1,True)):
        m = arena()
        m.set('enemy_state',1); m.set('enemy_cool',1); m.set('jump',phase)
        m.call('update')
        assert (m.get('health') < 12) == hit, (phase,m.get('health'))
    m = arena()
    m.set('enemy_hp',0); m.set('remaining',1)
    m.set('stick',14); m.set('fire',1)
    m.call('update')
    assert m.get('jump') == 22 and m.get('attack_kind') == 2
    ticks(m,22)
    assert m.get('jump') == 0 and m.get('jump_cool') == 8
    ticks(m,7)
    assert m.get('jump') == 0, 'held fire bypassed landing recovery'
    m.call('update')
    assert m.get('jump') == 22
    report.append('Jump launch/landing are vulnerable; held jump kick cannot skip landing recovery: PASS')
    for kind, expected in ((0,32), (1,31), (2,29)):
        m = arena()
        m.set('enemy_state',3); m.set('enemy_cool',6)
        m.set('attack_kind',kind); m.set('facing',0)
        m.call('player_hit')
        assert m.get('enemy_hp') == expected
    m = arena()
    m.set('enemy_state',3); m.set('enemy_face',0)
    m.set('attack_kind',0); m.call('player_hit')
    assert m.get('enemy_hp') == 31, 'guard incorrectly protected the rear'
    report.append('Frontal guard blocks punches, takes kick chip damage, and loses to jump kicks/rear hits: PASS')
    for kind, state in ((1,3), (2,4)):
        m = arena(kind)
        m.set('attack',12); m.set('ai_random',8)
        m.call('update')
        assert m.get('enemy_state') == state, (kind, m.get('enemy_state'))
        if kind == 2:
            y = m.get('enemy_y'); ticks(m,5)
            assert m.get('enemy_y') != y
    m = arena(slot=1)
    m.set('enemy_x',150,1)
    ticks(m,80)
    assert m.get('enemy_x',1) < m.get('px'), 'flanker never got behind Billy'
    report.append('Visible windup reactions, Linda sidestep, and depth-lane flanking: PASS')
    m = arena(3)
    m.set('attack',10); m.set('enemy_state',1); m.set('enemy_cool',1)
    m.set('health',4)
    m.call('update')
    assert m.get('lives') == 2 and m.get('health') == 12
    assert m.get('attack') == m.get('player_stun') == 0
    for _ in range(2):
        m.set('immune',0); m.set('health',1); m.set('px',100); m.set('py',170)
        m.set('enemy_state',1); m.set('enemy_cool',1)
        m.call('update')
    assert m.get('mode') == 3 and m.get('health') == 0
    report.append('Heavy damage saturates at zero; respawn and game over cannot underflow health: PASS')
    print('\n'.join(report))
    return report


if __name__ == '__main__':
    check()
