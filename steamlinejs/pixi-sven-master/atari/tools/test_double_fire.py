#!/usr/bin/env python3
"""Exercise real fire/keyboard edges rather than injecting whistle requests."""
from test_runtime import Machine, LABELS
for rate in (50,60):
    for keyboard in (False,True):
        m=Machine(rate=rate);m.start();m.call('restart')
        m.put('px',130);m.put('py',56)
        m.mem.ram[LABELS['sheep_age']+1]=35
        def button(down,frames=2):
            if keyboard:m.mem.key=33 if down else None
            else:m.mem.ram[0xd010]=0 if down else 1
            for _ in range(frames):m.frame()
        button(False);button(True)
        assert m.get('whistle_cooldown')==0,'single fire must not whistle'
        button(False);button(True)
        assert m.get('whistle_cooldown')>0,'double fire must whistle'
        reaction=m.mem.ram[LABELS['sheep_reaction']+1]
        assert reaction>0
        button(True,rate//2)
        assert m.get('whistle_cooldown')<85,'held fire must not retrigger'
        button(False);m.call('restart');m.put('px',130);m.put('py',56)
        button(True);button(False,rate//2);button(True)
        assert m.get('whistle_cooldown')==0,'late second click must not whistle'
        button(False);m.call('restart')
        # Starting/restarting clears any unfinished double click.
        assert m.get('fire_click_ticks')==0 and m.get('whistle_pending')==0
        button(True);button(False)
        m.mem.key=10;m.frame();m.mem.key=None;m.frame()
        assert m.get('mode')==4 and m.get('fire_click_ticks')==0
        m.mem.key=10;m.frame();m.mem.key=None;m.frame()
        button(True)
        assert m.get('whistle_cooldown')==0,'pause must discard first click'
        print(f'PASS double-fire {rate}Hz {"Space" if keyboard else "joystick"}: single, double, held, expiry, restart and pause')
