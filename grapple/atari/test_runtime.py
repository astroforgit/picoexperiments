#!/usr/bin/env python3
"""Exercise assembled routines with py65; no TV/blitter timing emulation.

Run after build.sh with py65 on PYTHONPATH. Rectangle fills are captured at
the existing fill_rect boundary to check terrain/water pixels and clipping.
"""
from pathlib import Path
import os
from py65.devices.mpu6502 import MPU

ROOT = Path(os.environ.get('BUILD_DIR', Path(__file__).resolve().parent)).resolve()
LABELS = {p[2].lower(): int(p[1], 16)
          for line in (ROOT / 'grapple-vbxe.lab').read_text().splitlines()
          if len(p := line.split()) == 3}
ram = bytearray(65536)
data = (ROOT / 'grapple-vbxe.xex').read_bytes()
pos = 0
while pos < len(data):
    start = int.from_bytes(data[pos:pos + 2], 'little')
    pos += 2
    if start == 65535:
        continue
    end = int.from_bytes(data[pos:pos + 2], 'little')
    pos += 2
    size = end - start + 1
    assert size > 0 and pos + size <= len(data)
    ram[start:end + 1] = data[pos:pos + size]
    pos += size
cpu = MPU(memory=ram)
pixels = bytearray(320 * 200)
fills = 0


def get(name, size=1):
    at = LABELS[name]
    return int.from_bytes(ram[at:at + size], 'little')


def put(name, value, size=1):
    at = LABELS[name]
    ram[at:at + size] = (value % (1 << (size * 8))).to_bytes(size, 'little')


def call(name):
    global fills
    cpu.sp = 255
    cpu.stPushWord(0x05ff)
    cpu.pc = LABELS[name]
    for _ in range(300000):
        if cpu.pc == 0x0600:
            return
        if cpu.pc == LABELS['fill_rect']:
            x, y = get('calc_x', 2), get('calc_y')
            w, h = get('fr_w', 2), get('fr_h')
            assert 0 < w <= 320 and 0 < h <= 200, (x, y, w, h)
            assert x + w <= 320 and y + h <= 200, (x, y, w, h)
            for row in range(y, y + h):
                pixels[row * 320 + x:row * 320 + x + w] = bytes([get('fr_col')]) * w
            fills += 1
            cpu.pc = cpu.stPopWord() + 1
        else:
            cpu.step()
    raise AssertionError(f'{name} did not return at ${cpu.pc:04x}')


# Independent pixel oracle for the inexpensive depth-coloured terrain runs.
world = (ROOT / 'world-map.bin').read_bytes()
colors = (ROOT / 'terrain-colors.bin').read_bytes()


def solid(x, y):
    tx, ty = (x + 16) // 16, (y + 16) // 16
    return 0 <= tx < 12 and 0 <= ty < 240 and world[ty * 12 + tx] != 0


for camera in [0, 151, 179, 180, 183, 399, 447, 885, 983, 984,
               1000, 1099, 1223, 1509, 1607, 1608, 1699, 3199, 3724]:
    put('camera_y', camera, 2)
    call('clear_view')
    call('draw_water')
    call('draw_map')
    for sy in range(100):
        wy = camera + sy
        for x in range(160):
            color = 24 if 984 <= wy < 1608 else 1
            if solid(x, wy):
                color = colors[(wy + 16) // 16]
            for dy in (0, 1):
                at = (sy * 2 + dy) * 320 + x * 2
                assert pixels[at:at + 2] == bytes([color, color]), (camera, x, sy)
print(f'PASS: terrain/depth/water pixels and viewport clipping ({fills} fills)')

# Isolate movement in an open map, retaining the runtime boundary checks.
at = LABELS['world_map']
ram[at:at + 2880] = bytes(2880)


def player(y):
    put('player_x', 80 * 256, 2)
    put('player_y', y * 256, 3)
    for name in ('vel_x', 'vel_y'):
        put(name, 0, 2)
    for name in ('grapple_state', 'grapple_cooldown', 'water_phase'):
        put(name, 0)


# Exercise a spike beyond the old 63-entity limit. A hit must traverse the
# complete field-array table and reset the player to the selected checkpoint.
spike_data = (ROOT / 'spike-data.bin').read_bytes()
spike_count = LABELS['spike_count']
assert spike_count > 64 and len(spike_data) == spike_count * 4
spike_index = 64
spike_x = spike_data[spike_index]
spike_y = (spike_data[spike_count + spike_index] +
           spike_data[spike_count * 2 + spike_index] * 256)
put('respawn_x', 37)
put('respawn_y', 333, 2)
player(spike_y)
put('player_x', spike_x * 256, 2)
call('check_player_hazards')
assert get('player_x', 2) == 37 * 256 and get('player_y', 3) == 333 * 256
put('respawn_x', 56)
put('respawn_y', 152, 2)
print('PASS: spike collision beyond the former 63-entity limit')


ram[0xd300] = 15              # neutral joystick
ram[0xd01f] = 7               # no console key
put('old_console', 7)


def press_key(code):
    ram[0xd20f] = 0            # SKSTAT: physical key held
    ram[0xd209] = code         # KBCODE
    ram[0x02fc] = code
    call('read_input')
    assert ram[0x02fc] == 255
    selected = get('checkpoint_current')
    ram[0x02fc] = code         # simulate an OS repeat while still held
    call('read_input')
    assert get('checkpoint_current') == selected
    ram[0xd20f] = 4            # release before the next distinct press
    ram[0x02fc] = 255
    call('read_input')


checkpoint_data = (ROOT / 'checkpoint-teleport-data.bin').read_bytes()


def assert_checkpoint_spawn(checkpoint_number):
    offset = checkpoint_number * 4
    expected_x = checkpoint_data[offset]
    expected_y = checkpoint_data[offset + 1] + checkpoint_data[offset + 2] * 256
    assert get('checkpoint_current') == offset
    assert get('player_x', 2) == expected_x * 256
    assert get('player_y', 3) == expected_y * 256
    call('check_player_checkpoints')
    call('check_player_movers')
    call('check_player_thwomps')
    call('check_player_hazards')
    call('check_player_cannonballs')
    assert get('checkpoint_current') == offset
    assert get('player_x', 2) == expected_x * 256
    assert get('player_y', 3) == expected_y * 256


press_key(0x1f)               # 1: first/next flag
assert_checkpoint_spawn(0)
for checkpoint_number in range(1, LABELS['checkpoint_count']):
    press_key(0x1f)
    assert_checkpoint_spawn(checkpoint_number)
press_key(0x1f)               # next wraps to first flag
assert_checkpoint_spawn(0)
press_key(0x1e)               # previous wraps to final flag
last_checkpoint = (LABELS['checkpoint_count'] - 1) * 4
assert get('checkpoint_current') == last_checkpoint
expected_x = checkpoint_data[last_checkpoint]
expected_y = (checkpoint_data[last_checkpoint + 1] +
              checkpoint_data[last_checkpoint + 2] * 256)
assert get('player_x', 2) == expected_x * 256
assert get('player_y', 3) == expected_y * 256
put('checkpoint_current', 255)
put('respawn_x', 56)
put('respawn_y', 152, 2)
call('reset_player')
print('PASS: keyboard 1/2 select next/previous checkpoint with wrapping')


for y, wet in [(983, 0), (984, 0), (985, 1), (1608, 1), (1619, 1), (1620, 0)]:
    player(y)
    call('detect_player_water')
    assert get('player_in_water') == wet, (y, wet)

for y, ticks in [(300, 10), (1100, 10)]:
    player(y)
    for _ in range(10):
        call('update_player')
    assert get('vel_y', 2) == ticks * 164
    assert get('player_y', 3) == y * 256 + 164 * ticks * (ticks + 1) // 2

# The blue water is visual only; ground friction still stops at zero without
# reversing residual momentum.
for wet in (0, 1):
    player(1100 if wet else 304)
    put('player_in_water', wet)
    if not wet:
        ram[at + 20 * 12 + 5] = 1  # left foot on row beginning at Y=304
    cases = ([(50, 50), (-50, -50), (1024, 1024), (-1024, -1024)] if wet else
             [(50, 0), (-50, 0), (1024, 922), (-1024, -922)])
    for velocity, expected in cases:
        put('vel_x', velocity, 2)
        call('apply_player_drag')
        result = get('vel_x', 2)
        assert result == expected % 65536, (wet, velocity, result)
    ram[at + 20 * 12 + 5] = 0

# Pull uses the declared original speed; each cardinal direction is exercised.
for direction, dx, dy in [(0, 0, -7), (1, 7, 0), (2, 0, 7), (3, -7, 0)]:
    player(300)
    put('grapple_state', 2)
    put('grapple_dir', direction)
    call('update_player')
    assert get('player_x', 2) == (80 + dx) * 256
    assert get('player_y', 3) == (300 + dy) * 256

player(300)
put('grapple_state', 1)
put('grapple_dir', 1)
put('hook_x', 80)
put('hook_y', 294, 2)
call('advance_hook')
assert get('hook_x') == 104, '1200 px/s hook'

player(1100)
put('grapple_state', 1)
put('grapple_dir', 1)
put('hook_x', 80)
put('hook_y', 1094, 2)
for tick in range(2):
    call('update_player')
    assert get('hook_x') == 80 + (tick + 1) * 24, 'water must not slow the hook'

player(300)
put('grapple_state', 1)
put('grapple_dir', 1)
put('hook_x', 96)
put('hook_y', 294, 2)

# Put a lava cell directly in the hook path; holding direction cannot refire.
lava = LABELS['lava_map']
ram[lava + 19 * 12 + 7] = 1
call('advance_hook')
assert get('grapple_state') == 0 and get('grapple_cooldown') == 35
ram[0xd300] = 7  # hold right
ram[0xd01f] = 7
ram[0x02fc] = 255
put('old_console', 7)
for tick in range(35):
    call('read_input')
    assert get('grapple_state') == 0
    call('update_player')
assert get('grapple_cooldown') == 0
call('read_input')
assert get('grapple_state') == 1
print('PASS: Atari movement, full-speed water, hook speed and break cooldown')

# Active thwomps accelerate from rest and stop accelerating at 500 px/s.
state = LABELS['thwomp_state']
thwomp_count = LABELS['thwomp_count']
ram[state:state + thwomp_count * 11] = bytes(thwomp_count * 11)
for i in range(thwomp_count):
    ram[state + i * 11 + 10] = 10
    ram[state + i * 11 + 1] = 80
    ram[state + i * 11 + 3:state + i * 11 + 5] = (2000).to_bytes(2, 'little')
ram[state + 3:state + 5] = (300).to_bytes(2, 'little')
ram[state + 5] = 1  # active
ram[state + 7] = 2  # down
for tick in range(1, 22):
    y = int.from_bytes(ram[state + 3:state + 5], 'little')
    put('camera_y', y - 50, 2)
    call('update_thwomps')
    speed = int.from_bytes(ram[state + 8:state + 10], 'little')
    assert speed == min(tick * 256, 2560), (tick, speed)
print('PASS: thwomp acceleration and terminal speed')

# Performance regression bounds count real 6502 instructions in the routines.
# fill_rect is intercepted, so terrain totals exclude its cost and blitter waits.
ram[LABELS['world_map']:LABELS['world_map'] + 2880] = world
for camera in (180, 1000, 1700, 3200):
    put('camera_y', camera, 2)
    begin = cpu.processorCycles
    call('draw_map')
    cycles = cpu.processorCycles - begin
    assert cycles < 15000, (camera, cycles)
    print(f'Terrain CPU cycles excluding fills: Y={camera}, {cycles}')
ram[lava:lava + 2880] = (ROOT / 'lava-map.bin').read_bytes()
ram[LABELS['world_map']:LABELS['world_map'] + 2880] = bytes(2880)
player(300)
put('hook_x', 80)
put('hook_y', 294, 2)
put('grapple_dir', 1)
begin = cpu.processorCycles
call('advance_hook')
cycles = cpu.processorCycles - begin
assert cycles < 14000, cycles
print(f'Hook CPU cycles (24 pixels): {cycles}')

# Authored chamber regression: the left shaft block is above the short Atari
# viewport when the player reaches the lower corridor, but must still attack.
thwomp_data = (ROOT / 'thwomp-data.bin').read_bytes()


def thwomp_state_at(x, y):
    for index in range(thwomp_count):
        offset = index * 4
        authored_y = thwomp_data[offset + 1] + thwomp_data[offset + 2] * 256
        if thwomp_data[offset] == x and authored_y == y:
            return state + index * 11
    raise AssertionError(f'authored thwomp at ({x},{y}) is missing')


ram[LABELS['world_map']:LABELS['world_map'] + 2880] = world
call('reset_thwomps')
player(672)
put('player_x', 24 * 256, 2)
put('camera_y', 614, 2)
call('update_thwomps')
left_block = thwomp_state_at(24, 568)
assert ram[left_block + 5] == 1 and ram[left_block + 7] == 2
for _ in range(12):
    call('update_thwomps')
assert int.from_bytes(ram[left_block + 3:left_block + 5], 'little') > 614

# Offscreen detection must still respect intervening walls.
call('reset_thwomps')
player(900)
put('player_x', 24 * 256, 2)
put('camera_y', 842, 2)
call('update_thwomps')
assert ram[left_block + 5] == 0

# The top block must reach the exact right wall, turn down its 16px shaft,
# reach the exact floor, and then pursue the player left across the corridor.
top_block = thwomp_state_at(104, 504)
call('reset_thwomps')
player(512)
put('player_x', 136 * 256, 2)
put('camera_y', 450, 2)
for _ in range(20):
    call('update_thwomps')
assert ram[top_block + 1] == 136 and ram[top_block + 5] == 2
player(672)
put('player_x', 136 * 256, 2)
put('camera_y', 614, 2)
peak = 0
for _ in range(65):
    begin = cpu.processorCycles
    call('update_thwomps')
    peak = max(peak, cpu.processorCycles - begin)
assert int.from_bytes(ram[top_block + 3:top_block + 5], 'little') == 664
assert ram[top_block + 5] == 2
put('player_x', 72 * 256, 2)
for _ in range(40):
    call('update_thwomps')
assert ram[top_block + 1] == 24 and ram[top_block + 7] == 3
ai_cycle_limit = 18000 + max(0, LABELS['thwomp_count'] - 10) * 1500
assert peak < ai_cycle_limit, (peak, ai_cycle_limit)
print(f'PASS: offscreen attack, wall occlusion and two-turn chamber chase ({peak} peak AI cycles)')

# Hero animation states. The browser game's five-frame run cycle (original
# frames 5..9, slots 4..8) is the one the port used to skip: grounded
# horizontal movement fell through to the idle frames.
IDLE, RUN, JUMP, FALL, GRAPPLE = range(5)
STATE_SLOTS = {IDLE: {0, 1, 2, 3}, RUN: {4, 5, 6, 7, 8},
               JUMP: {9, 10}, FALL: {11, 12}, GRAPPLE: {14, 15}}


def animate(vel_x=0, vel_y=0, grapple=0, direction=0, phase=0):
    put('grapple_state', grapple)
    put('grapple_dir', direction)
    put('vel_x', vel_x & 0xFFFF, 2)
    put('vel_y', vel_y & 0xFFFF, 2)
    put('frame_counter', (phase * 4) & 0xFF)
    call('choose_hero_frame')
    return get('hero_frame')


def assert_state(state, **kwargs):
    slot = animate(**kwargs)
    assert slot in STATE_SLOTS[state], (state, slot, kwargs)
    return slot


# 20 px/s is the browser threshold: 0.4 px/frame at PAL 50 Hz, 103 in 8.8.
assert_state(IDLE, vel_x=0)
assert_state(IDLE, vel_x=102)
assert_state(IDLE, vel_x=-102)
assert_state(RUN, vel_x=103)
assert_state(RUN, vel_x=-103)
assert_state(RUN, vel_x=0x0200)
assert_state(RUN, vel_x=-0x0200)

# Airborne and grappling states still win over horizontal speed.
assert_state(JUMP, vel_x=0x0200, vel_y=-0x0100)
assert_state(FALL, vel_x=0x0200, vel_y=0x0200)
assert_state(GRAPPLE, vel_x=0x0200, grapple=1, direction=LABELS.get('dir_right', 2))

# Idle still cycles its four frames on the phase, as before.
assert [animate(phase=p) for p in range(5)] == [0, 1, 2, 3, 0]

# The run cycle must visit all five frames and wrap cleanly: five is not a
# power of two, so a phase mask would have stuttered at the wrap.
put('run_phase', 0)
put('run_last_phase', 0)
cycle = [animate(vel_x=0x0200, phase=p) for p in range(12)]
assert cycle == [4, 5, 6, 7, 8, 4, 5, 6, 7, 8, 4, 5], cycle

# Frames only advance when the phase does, so the cadence stays at 12.5 fps
# rather than stepping once per 50 Hz frame. The first call here advances
# because the phase moved; the repeats at the same phase must all hold.
put('run_phase', 0)
put('run_last_phase', 0)
held = [animate(vel_x=0x0200, phase=3) for _ in range(4)]
assert held == [5, 5, 5, 5], held
print('PASS: idle, run, jump, fall and grapple frame selection')
