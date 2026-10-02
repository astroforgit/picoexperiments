#!/usr/bin/env python3
"""Replay Gentle Descent inputs on the actual assembled NMOS 6502 routines.
Does not emulate VBXE display timing. Requires py65.
"""
import json
import sys
from pathlib import Path
from py65.devices.mpu6502 import MPU
ROOT = Path(__file__).resolve().parent
BUILD = ROOT / (sys.argv[1] if len(sys.argv)>1 else 'world-builds/gentle-descent')
labels = {p[2].lower(): int(p[1], 16) for line in (BUILD/'grapple-vbxe.lab').read_text().splitlines() if len(p := line.split()) == 3}
ram = bytearray(65536)
data = (BUILD/'grapple-vbxe.xex').read_bytes()
pos = 0
while pos < len(data):
    start = int.from_bytes(data[pos:pos+2], 'little'); pos += 2
    if start == 65535: continue
    end = int.from_bytes(data[pos:pos+2], 'little'); pos += 2
    size = end-start+1
    ram[start:end+1] = data[pos:pos+size]; pos += size
cpu = MPU(memory=ram)
deaths = 0

def call(name, count_deaths=True):
    global deaths
    cpu.sp = 255; cpu.stPushWord(0x5ff); cpu.pc = labels[name]
    for _ in range(500000):
        if cpu.pc == 0x600: return
        if count_deaths and cpu.pc == labels['reset_player']: deaths += 1
        cpu.step()
    raise AssertionError(name + ' did not return')

call('reset_player', False)
ram[0xd01f] = 7; ram[0x02fc] = 255; ram[labels['old_console']] = 7
visited = set(); ticks = 0
report = json.loads((ROOT/(sys.argv[2] if len(sys.argv)>2 else 'gentle-descent-playthrough.json')).read_text())
for key, duration in report['actions']:
    for _ in range(duration):
        ram[0xd300] = [14,7,13,11,15][key]
        for routine in ['read_input','update_movers','update_thwomps','update_cannons','update_cannonballs','update_player','check_player_checkpoints','check_player_movers','check_player_thwomps','check_player_hazards','check_player_cannonballs','update_camera']:
            call(routine)
        cp = ram[labels['checkpoint_current']]
        if cp != 255: visited.add(cp//4)
        ram[labels['frame_counter']] = (ram[labels['frame_counter']]+1)%256
        ticks += 1
assert deaths == 0, (deaths, ticks, visited)
assert len(visited) == labels['checkpoint_count'], (visited, labels['checkpoint_count'])
print(f'PASS: assembled 6502 replay: {ticks} ticks, {len(visited)} checkpoints, zero deaths')

# Each chasing block uses its own configured speed cap, including below start speed.
ram[labels['world_map']:labels['world_map']+2880] = bytes(2880)
for cap in (1,2,4,10):
    call('reset_thwomps')
    at = labels['thwomp_state']
    ram[at:at+11] = bytes([0,80,0,44,1,1,0,2,0,0,cap])
    for tick in range(1,13):
        call('update_thwomps')
        assert ram[at+9] == min(tick,cap), (cap,tick,ram[at+9])
print('PASS: native chase caps at 50, 100, 200 and 500 px/s')
