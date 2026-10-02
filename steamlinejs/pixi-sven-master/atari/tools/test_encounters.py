#!/usr/bin/env python3
"""Regression checks for the interaction and dog feedback."""
from test_runtime import Machine, LABELS
m=Machine();m.start();m.call('restart')
def at(name,i=0):return m.mem.ram[LABELS[name]+i]
def put(name,i,v):m.mem.ram[LABELS[name]+i]=v
for facing in range(4):
    m.call('restart');m.put('px',at('sheep_x'));m.put('py',at('sheep_y'))
    m.put('direction',facing*4);m.put('fire',1);m.put('fire_pending',1);m.put('moving',0)
    m.put('dog_clock',110)
    m.call('interact');assert m.get('dog_alert')==100
    assert at('sheep_direction')==facing
    m.call('update_sheep');assert at('sheep_direction')==facing
    m.call('build_actors')
    assert 69+5*facing<=at('actor_tile')<74+5*facing and at('actor_tile',8)==255
    old=at('enemy_x');m.put('world_tick',1);m.call('update_enemies')
    assert at('enemy_x')!=old,'alert must interrupt rest and move on odd ticks'
    for _ in range(62):m.call('interact')
    assert m.get('score')==0,'sunny interaction must take 64 ticks'
    m.call('interact');assert m.get('score')==1
    m.call('build_actors');assert at('actor_tile')==255 and at('actor_tile',8)!=255
    m.call('render')
    if facing==3:m.screenshot('interaction-finished.png')
# Diagonal pursuit keeps one heading instead of switching every vertical step.
m.call('restart');m.put('px',200);m.put('py',130);m.put('dog_alert',100)
headings=[]
for tick in range(20):
    m.put('world_tick',tick);m.call('update_enemies');headings.append(at('enemy_direction'))
assert set(headings)=={3},headings
# Release immediately restores the ordinary sheep and a single Sven.
m.call('restart');m.put('px',at('sheep_x'));m.put('py',at('sheep_y'))
m.put('fire',1);m.put('moving',0);m.call('interact')
m.put('fire',0);m.call('interact');m.call('build_actors')
assert 20<=at('actor_tile')<=23 and at('actor_tile',8)!=255
print('PASS interaction feedback: all four locked directions, slower progress, no duplicate Sven, dog interrupts rest, fast pursuit and stable diagonal heading')
