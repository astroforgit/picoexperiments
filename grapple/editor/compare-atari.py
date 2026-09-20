#!/usr/bin/env python3
"""Compare browser movement and chamber chase with the assembled Atari routines.

Requires Node.js, py65 and a current ../atari/grapple-vbxe.xex + .lab build.
No video or hardware timing emulation is involved.
"""
import json
import os
import subprocess
from pathlib import Path
from py65.devices.mpu6502 import MPU

ROOT = Path(__file__).resolve().parent
ATARI = Path(os.environ.get('BUILD_DIR', ROOT.parent / 'atari')).resolve()
labels = {p[2].lower(): int(p[1], 16)
          for line in (ATARI / 'grapple-vbxe.lab').read_text().splitlines()
          if len(p := line.split()) == 3}
memory = bytearray(65536)
data = (ATARI / 'grapple-vbxe.xex').read_bytes()
offset = 0
while offset < len(data):
    start = int.from_bytes(data[offset:offset + 2], 'little')
    offset += 2
    if start == 65535:
        continue
    end = int.from_bytes(data[offset:offset + 2], 'little')
    offset += 2
    length = end - start + 1
    memory[start:end + 1] = data[offset:offset + length]
    offset += length
cpu = MPU(memory=memory)


def put(name, value, size=1):
    at = labels[name]
    memory[at:at + size] = value.to_bytes(size, 'little')


def get(name, size=1, signed=False):
    at = labels[name]
    return int.from_bytes(memory[at:at + size], 'little', signed=signed)


def call(name):
    cpu.sp = 255
    cpu.stPushWord(0x05ff)
    cpu.pc = labels[name]
    for _ in range(500000):
        if cpu.pc == 0x0600:
            return
        cpu.step()
    raise AssertionError(f'{name} did not return')


scenarios = []
memory[labels['world_map']:labels['world_map'] + 2880] = bytes(2880)
memory[labels['lava_map']:labels['lava_map'] + 2880] = bytes(2880)
for y in (300, 1100):
    put('respawn_x', 80)
    put('respawn_y', y, 2)
    call('reset_player')
    memory[0xd01f] = 7
    memory[0x02fc] = 255
    put('old_console', 7)
    directions = ['right'] * 8 + [''] * 7 + ['up'] * 12 + [''] * 9 + ['left'] * 5 + ['down'] * 9
    trace = []
    for direction in directions:
        memory[0xd300] = {'right': 7, 'left': 11, 'up': 14, 'down': 13, '': 15}[direction]
        call('read_input')
        call('update_player')
        trace.append([get('player_x', 2) / 256, get('player_y', 3) / 256,
                      get('vel_x', 2, True) / 256, get('vel_y', 2, True) / 256,
                      get('grapple_state'), get('grapple_cooldown')])
    scenarios.append({'y': y, 'directions': directions, 'trace': trace})

memory[labels['world_map']:labels['world_map'] + 2880] = (ATARI / 'world-map.bin').read_bytes()
call('reset_thwomps')
chase = []
for x, y, count in [(136, 512, 20), (136, 672, 65), (72, 672, 40)]:
    put('player_x', x * 256, 2)
    put('player_y', y * 256, 3)
    for _ in range(count):
        call('update_thwomps')
        actors = []
        for i in range(labels['thwomp_count']):
            at = labels['thwomp_state'] + i * labels['thwomp_size']
            b = memory[at:at + 10]
            actors.append([int.from_bytes(b[0:2], 'little') / 256,
                           int.from_bytes(b[2:5], 'little') / 256,
                           b[5], b[6], int.from_bytes(b[8:10], 'little') / 256])
        chase.append(actors)

script = r'''
const fs=require('fs'), assert=require('assert/strict'), Game=require('./atari-physics.js');
const ref=JSON.parse(fs.readFileSync(0,'utf8'));
for(const s of ref.scenarios){
  const cells=Array.from({length:2880},(_,i)=>({x:i%12,y:Math.floor(i/12),tile:-1,rot:0}));
  const game=new Game(cells,{x:80,y:s.y});
  s.directions.forEach((direction,i)=>{
    game.input(direction ? {[direction]:true} : {});game.movePlayer();
    const p=game.player;
    assert.deepEqual([p.x,p.y,p.vx,p.vy,game.hook ? (game.hook.pulling ? 2 : 1) : 0,game.cooldown],s.trace[i],`player y=${s.y} tick ${i}`);
  });
}
const cells=JSON.parse(fs.readFileSync(process.env.WORLD_PATH || '../bin/assets/world.json')).layers[0].tiles;
const game=new Game(cells);let i=0;
for(const [x,y,count] of [[136,512,20],[136,672,65],[72,672,40]]){
  game.player={x,y};
  for(let tick=0;tick<count;tick++){
    game.moveThwomps();
    assert.deepEqual(game.thwomps.map(t=>[t.x,t.y,t.state,t.timer,t.speed]),ref.chase[i],`chamber tick ${i}`);i++;
  }
}
console.log('PASS: 100 player ticks and 125 nine-thwomp chamber ticks match the assembled Atari routines');
'''
subprocess.run(['node', '-e', script], cwd=ROOT,
               input=json.dumps({'scenarios': scenarios, 'chase': chase}), text=True, check=True)
