#!/usr/bin/env python3
"""Exercise the built 6502 sound engine and its bank-switch bridge."""
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools/reference'))
from atari_emu import Atari, load_labels
r = load_labels(ROOT / 'gen/runtime.asm.lab')
s = load_labels(ROOT / 'gen/pause.asm.lab')
for page in (0xd6, 0xd7):
    a = Atari(ROOT / 'pilka.xex', vbxe_page=page)
    a.boot()
    for _ in range(2_000_000):
        if a.cpu.pc == 0x975b: break
        a.cpu.step()
    else: raise AssertionError('Startup failed')
    ram = a.mem.ram
    def tick(count=1):
        for _ in range(count):
            banks = (a.mems, a.memb)
            zp = bytes(ram[:256])
            ram[r['FRAMES']] = (ram[r['FRAMES']] + 1) & 255
            a.call(r['SOUND_BRIDGE'])
            assert banks == (a.mems, a.memb), 'Audio changed graphics banks'
            assert bytes(ram[:256]) == zp, 'Audio changed zero page'
            assert not any(a.pokey[4:9]) and a.irqen == 0
    def value(name): return int(a.vram[0x67000 + s[name]])
    ram[r['MENU_MODE']] = 0
    ram[r['LEAGUE_SCREEN']] = 0
    ram[0x97dd] = 17
    tick(12)
    assert a.pokey[2:4] == bytes((54, 0x82))
    ram[0x97dc] = 1
    tick()
    assert a.pokey[1] & 15 and value('EFFECT_KIND') == 0
    assert ram[0x97dc] == 0 and ram[0x97dd] == 17
    tick(4)
    assert a.pokey[1] == 0
    ram[0x97de] = 1
    tick()
    assert a.pokey[1] == 0xa8
    ram[0x97dc] = 2
    tick()
    assert value('EFFECT_KIND') == 2 and value('EFFECT_TIME') == 18
    tick(19)
    assert a.pokey[1] == 0
    ram[0x97dc] = 1
    tick()
    assert value('EFFECT_KIND') == 0 and a.pokey[1] & 15
    ram[0x97de] = 4
    tick()
    assert value('EFFECT_TIME') == 49
    tick(50)
    assert a.pokey[1] == 0
    ram[r['SOUND_GOAL_PENDING']] = 1
    tick(40)
    assert a.pokey[2:4] == bytes((33, 0x8a))
    tick(100)
    assert a.pokey[2:4] == bytes((54, 0x82))
    ram[0x97de] = 1
    tick()
    ram[r['LEAGUE_SCREEN']] = 1
    tick()
    assert a.pokey[1] == a.pokey[3] == 0
    ram[r['MENU_MODE']] = 1
    ram[r['JOY1']] = 31
    tick(3)
    assert a.pokey[1] == a.pokey[3] == 0
    ram[r['JOY1']] = 30
    tick()
    assert a.pokey[1] == 0xa3
    tick(3)
    assert a.pokey[1] == 0, 'Held input repeated menu click'
    ram[r['MENU_MODE']] = 0
    ram[r['LEAGUE_SCREEN']] = 0
    ram[0x97de] = 1
    tick()
    ram[r['MENU_MODE']] = 1
    tick()
    assert a.pokey[1] == 0, 'Whistle continued into menu'
    print(f'PASS ${page:02X}: crowd, kicks, whistles, goals, pause/menu, priorities, bank/ZP safety')
