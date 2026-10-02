#!/usr/bin/env python3
"""Run assembled 6502 routines against a small VBXE/POKEY register model.

Optional test dependency: py65. Run after build.sh. This checks framebuffer
contents and POKEY register envelopes; it does not emulate video/audio timing.
"""
from pathlib import Path
from py65.devices.mpu6502 import MPU

ROOT = Path(__file__).resolve().parents[1]
LABELS = {parts[2].lower(): int(parts[1], 16)
          for line in (ROOT / 'porter-vbxe.lab').read_text().splitlines()
          if len(parts := line.split()) == 3}


class Memory:
    def __init__(self):
        self.ram = bytearray(65536)
        self.vram = bytearray(0x80000)
        self.bank = 0
        self.blits = []
        self.audio_writes = []

    def __getitem__(self, address):
        if address == 0xd640:
            return 0x10
        if address == 0xd641:
            return 0x20
        if address == 0xd653:
            return 0
        if self.bank & 0x80 and 0x4000 <= address < 0x8000:
            return self.vram[(self.bank & 31) * 0x4000 + address - 0x4000]
        return self.ram[address]

    def __setitem__(self, address, value):
        if self.bank & 0x80 and 0x4000 <= address < 0x8000:
            self.vram[(self.bank & 31) * 0x4000 + address - 0x4000] = value
            return
        self.ram[address] = value
        if address in (0xd201, 0xd203, 0xd205, 0xd207):
            self.audio_writes.append((address, value, cpu.processorCycles))
        if address == 0xd65d:
            self.bank = value
        if address == 0xd653 and value == 1:
            self.blit()

    def blit(self):
        ptr = int.from_bytes(self.ram[0xd650:0xd653], 'little')
        b = self.vram[ptr:ptr + 21]
        source = int.from_bytes(b[0:3], 'little')
        target = int.from_bytes(b[6:9], 'little')
        sp = int.from_bytes(b[3:5], 'little', signed=True)
        dp = int.from_bytes(b[9:11], 'little', signed=True)
        sx = b[5] if b[5] < 128 else b[5] - 256
        dx = b[11] if b[11] < 128 else b[11] - 256
        width = int.from_bytes(b[12:14], 'little') + 1
        height = b[14] + 1
        assert b[20] in (0, 1), 'test model supports copy and transparent copy'
        self.blits.append((source, target, width, height))
        for y in range(height):
            for x in range(width):
                pixel = self.vram[source + y * sp + x * sx]
                if pixel or b[20] == 0:
                    self.vram[target + y * dp + x * dx] = pixel


mem = Memory()
cpu = MPU(memory=mem)


def call(name):
    cpu.sp = 0xff
    cpu.stPushWord(0x05ff)
    cpu.pc = LABELS[name] if isinstance(name, str) else name
    for _ in range(2000000):
        if cpu.pc == 0x0600:
            return
        if cpu.pc == LABELS['wait_vbl']:
            # Model one completed vertical blank rather than spinning for a TV.
            cpu.pc = cpu.stPopWord() + 1
        else:
            cpu.step()
    raise AssertionError(f'{name} did not return')


def setvar(name, value):
    mem[LABELS[name]] = value


def getvar(name):
    return mem[LABELS[name]]


def load_xex():
    data = (ROOT / 'porter-vbxe.xex').read_bytes()
    pos = 0
    while pos < len(data):
        start = int.from_bytes(data[pos:pos + 2], 'little')
        pos += 2
        if start == 0xffff:
            continue
        end = int.from_bytes(data[pos:pos + 2], 'little')
        pos += 2
        size = end - start + 1
        assert 0 < size <= 65536
        mem.ram[start:end + 1] = data[pos:pos + size]
        pos += size
        if start <= 0x2e2 and end >= 0x2e3:
            call(int.from_bytes(mem.ram[0x2e2:0x2e4], 'little'))
    assert pos == len(data)


load_xex()
background = b''.join((ROOT / f'data/background-{i}.dat').read_bytes() for i in range(4))
assert mem.vram[0x40000:0x50000] == background, 'background INIT upload'
assert mem.bank == 0, 'INIT releases MEMAC'
call('vbxe_init')
for label in ('xdl_data_a', 'xdl_data_b'):
    lines = mem.ram[LABELS[label] + 5] + 1
    assert lines == 200, 'XDL must not display uninitialized framebuffer tail'
setvar('front_bank', 1)
setvar('back_bank', 3)
call('init_game')
setvar('game_mode', 1)
# Both initial buffer states differ: A has title art, B is cleared.
for frame in range(6):
    call('draw_game')
    shown = getvar('front_bank') << 16
    for y in range(200):
        row = mem.vram[shown + y * 320:shown + (y + 1) * 320]
        expected = background[y * 320:(y + 1) * 320]
        if 4 <= y < 196:
            assert row[:64] == expected[:64] and row[256:] == expected[256:]
        else:
            assert row == expected
    assert all(not 16 <= p < 48 for p in mem.vram[shown:shown + 64000]), 'no title pixels'
    assert any(p >= 48 for p in mem.vram[0x20000:0x29000]), 'scenery under transparent room tiles'
assert getvar('background_pending') == 0
assert sum(w == 320 and h == 200 for _, _, w, h in mem.blits) == 2
assert mem.vram[0x40000:0x50000] == background, 'background stays immutable'
# Restart after end-screen drawing dirties one buffer.
call('draw_end')
call('init_game')
for _ in range(2):
    call('draw_game')
assert getvar('background_pending') == 0
print('PASS: INIT upload, six alternating frames, transparent scenery, end/restart')

setvar('sound_enabled', 1)
for effect, duration in [('sfx_jump', 12), ('sfx_teleport', 3)]:
    before = cpu.processorCycles
    call(effect)
    assert cpu.processorCycles - before < 500, 'attack must start in under 0.3 ms'
    assert mem.ram[0xd203] & 15, 'first sample must play before the first VBI'
    pitches = []
    for tick in range(duration):
        if tick == 3:
            cpu.a = 3
            call('start_sound')  # landing must not interrupt the action voice
        assert mem.ram[0xd203] & 15, (effect, tick, 'premature silence')
        assert mem.ram[0xd203] & 0xf0 == 0xa0
        pitches.append(mem.ram[0xd202])
        call('sound_update')
    assert mem.ram[0xd203] == 0, effect + ' must stop'
    if effect == 'sfx_jump':
        assert all(a > b for a, b in zip(pitches, pitches[1:])), 'rising jump pitch'
    else:
        assert pitches == [0x2c, 0x4b, 0x6a]
call('sfx_teleport')
call('sound_update')
setvar('option_latch', 0)
mem.ram[0xd01f] = 3  # OPTION pressed
call('update_sound_toggle')
assert getvar('sound_enabled') == getvar('action_frames') == 0
call('sound_update')
assert mem.ram[0xd201] == mem.ram[0xd203] == 0
call('sfx_jump')
assert getvar('action_frames') == 0
print('PASS: jump sweep, Robbo teleport cadence, independent landing sound, mute')

# Exercise actual idle physics: gravity used to replay landing sound every
# other frame, producing an almost continuous tone while standing still.
call('init_game')
setvar('sound_enabled', 1)
for name in ('joy_state', 'joy_pressed', 'space_pressed'):
    setvar(name, 0)
for frame in range(180):
    setvar('frame', frame & 255)
    call('update_player')
    call('sound_update')
    if frame >= 60:
        assert getvar('p_ground') == 1
        assert getvar('p_dy') == 0
        assert mem.ram[0xd201] & 15 == 0, 'idle must not retrigger landing noise'
        assert mem.ram[0xd203] & 15 == 0

# Drive the actual interrupt entry points while the main/gameplay loop is
# deliberately stopped. Effects must start without executing update_player.
def vbi():
    mem.ram[0xfffa:0xfffc] = LABELS['nmi'].to_bytes(2, 'little')
    mem.ram[0xd40f] = 0x40
    cpu.pc = 0x0600
    cpu.sp = 0xff
    cpu.nmi()
    for _ in range(10000):
        if cpu.pc == 0x0600:
            return
        cpu.step()
    raise AssertionError('VBI did not return')

setvar('game_mode', 1)
setvar('audio_fire_prev', 1)
mem.ram[0xd300] = 0xff
mem.ram[0xd010] = 0  # physical joystick trigger edge
mem.audio_writes.clear()
vbi()
assert mem.ram[0xd203] & 15 and mem.ram[0xd202] == 112
assert getvar('jump_pending') == 1
call('read_joystick')
mem.audio_writes.clear()
call('update_player')
assert not any(a == 0xd203 and v & 15 for a, v, _ in mem.audio_writes)
assert getvar('p_dy') & 128
for _ in range(20):
    vbi()
assert mem.ram[0xd203] == 0, 'holding the trigger must not restart the cue'
mem.ram[0xd010] = 1
vbi()
mem.ram[0xd010] = 0
vbi()
assert mem.ram[0xd202] == 112, 'a new press starts a new attack'
mem.ram[0xd010] = 1
vbi()

# Raise an actual keyboard IRQ, then deliver the next VBI (<=20ms PAL).
mem.ram[0xfffe:0x10000] = LABELS['irq_keyboard'].to_bytes(2, 'little')
mem.ram[0xd20e] = 0xbf
mem.ram[0xd209] = LABELS['key_space']
cpu.pc = 0x0600
cpu.sp = 0xff
cpu.p &= ~4
cpu.irq()
for _ in range(1000):
    if cpu.pc == 0x0600:
        break
    cpu.step()
assert getvar('space_pending') == getvar('audio_tele_pending') == 1
vbi()
assert mem.ram[0xd202] == 0x2c and mem.ram[0xd203] & 15
call('read_keyboard')
mem.audio_writes.clear()
call('update_player')
assert not any(a == 0xd203 and v & 15 for a, v, _ in mem.audio_writes), 'completion must be silent'
print('PASS: raw joystick/keyboard interrupt feedback with main loop stopped; no held/completion replay')

# A main-loop read just before VBI used to synthesize a FIRE edge and then
# replay it from jump_pending on the next frame. There is now one producer.
setvar('jump_pending', 0)
setvar('joy_state', 0)
setvar('audio_fire_prev', 1)
mem.ram[0xd010] = 0
call('read_joystick')
assert not getvar('joy_pressed') & 16
vbi()
call('read_joystick')
assert getvar('joy_pressed') & 16
call('read_joystick')
assert not getvar('joy_pressed') & 16
# A complete short press during rendering survives release until consumed.
mem.ram[0xd010] = 1
vbi()
mem.ram[0xd010] = 0
vbi()
mem.ram[0xd010] = 1
vbi()
call('read_joystick')
assert getvar('joy_pressed') & 16
call('read_joystick')
assert not getvar('joy_pressed') & 16

# A second keyboard IRQ immediately after the atomic consume must survive.
setvar('space_pending', 1)
cpu.pc = LABELS['read_keyboard']
cpu.sp = 0xff
cpu.stPushWord(0x05ff)
cpu.step()  # consume the first event with one LSR instruction
setvar('space_pending', 1)  # second IRQ arrives here
while cpu.pc != 0x0600:
    cpu.step()
assert getvar('space_pressed') == getvar('space_pending') == 1
call('read_keyboard')
assert getvar('space_pressed') == 1 and getvar('space_pending') == 0
print('PASS: one event per trigger press, short press retained, no lost keyboard IRQ')

# Isolated safe platform for action-chaining tests, with all actors far away.
saved_world = bytes(mem.ram[0x8000:0xa000])
def platform():
    call('init_game')
    mem.ram[0x8000:0xa000] = bytes(8192)
    mem.ram[0x8000+12*128:0x8000+13*128] = bytes([64])*128
    mem.ram[LABELS['coin_alive']:LABELS['coin_alive']+28] = bytes(28)
    for label, count in [('rock_y_hi',5),('feather_y_hi',16)]:
        mem.ram[LABELS[label]:LABELS[label]+count] = bytes([255])*count
    for name, value in [('p_x',40),('p_x+1',0),('p_y',88),('p_y+1',0)]:
        base = name.split('+')[0]
        mem[LABELS[base] + (1 if '+' in name else 0)] = value
    for name, value in [('p_ground',1),('p_dy',0),('p_coyote',0),
                        ('game_mode',1),('frame',1),('cam_x',0),('cam_y',0),
                        ('audio_fire_prev',1),('jump_pending',0),('space_pending',0),
                        ('space_pressed',0),('joy_state',0)]:
        setvar(name,value)
    mem.ram[0xd300] = 0xf7  # aim right
    mem.ram[0xd010] = 1

def action_frame(jump=False, teleport=False):
    mem.ram[0xd010] = 0 if jump else 1
    if teleport:
        setvar('space_pending',1)
        setvar('audio_tele_pending',1)
    vbi()
    call('read_joystick')
    call('read_keyboard')
    before = cpu.processorCycles
    call('update_player')
    return cpu.processorCycles-before

platform()
action_frame(jump=True)
assert getvar('p_dy') & 128
cycles = action_frame(teleport=True)
assert getvar('teleports') == 1 and getvar('p_dy') & 128 and not getvar('p_ground')
assert getvar('p_x') >= 72 and cycles < 20000, 'open-air teleport must skip slow support scan'
platform()
action_frame(jump=True, teleport=True)
assert getvar('teleports') == 1 and getvar('p_dy') & 128 and getvar('p_y') < 88
platform()
action_frame(teleport=True)
action_frame(jump=True)
assert getvar('teleports') == 1 and getvar('p_dy') & 128
mem.ram[0x8000:0xa000] = saved_world
print('PASS: jump then teleport, simultaneous combo, teleport then jump; upward momentum preserved')

# A full 64-second original score loop: all 16 patterns, both voices, while
# arbitrary effects continue to play. Music cannot touch voices 1/2 or AUDCTL.
setvar('game_mode', 1)
for name in ('music_row', 'music_pattern', 'music_tick'):
    setvar(name, 0)
notes = set()
for tick in range(3200):
    mem.ram[0xd201] = 0xa6
    mem.ram[0xd203] = 0xa7
    mem.ram[0xd208] = 0
    call('music_update')
    notes.add((mem.ram[0xd204], mem.ram[0xd206]))
    assert mem.ram[0xd201] == 0xa6 and mem.ram[0xd203] == 0xa7
    assert mem.ram[0xd208] == 0
    assert mem.ram[0xd205] & 15 <= 3 and mem.ram[0xd207] & 15 <= 4
assert getvar('music_pattern') == 0 and getvar('music_row') == 0 and getvar('music_tick') == 0
assert len(notes) > 10
setvar('sound_enabled', 0)
call('music_update')
assert mem.ram[0xd205] == mem.ram[0xd207] == 0
print('PASS: complete Porter music loop, quiet instruments, independent effects, mute')

# A loader can leave channels 3/4 active. The game owns POKEY after startup.
mem.ram[0xd205] = 0xaf
mem.ram[0xd207] = 0xcf
cpu.pc = LABELS['start']
cpu.sp = 0xff
for _ in range(2000000):
    if cpu.pc == LABELS['main_loop']:
        break
    cpu.step()
else:
    raise AssertionError('startup did not reach main loop')
assert all(mem.ram[a] == 0 for a in (0xd201, 0xd203, 0xd205, 0xd207, 0xd208))
assert getvar('action_lock') == 0
print('PASS: startup silences all four POKEY voices and resets audio control')

# An actor/aim marker near x=127 extends ten scaled pixels past the room.
# Fill its source with opaque pixels to make any spill unambiguous.
setvar('game_mode', 1)
setvar('cam_x', 0)
setvar('cam_y', 0)
call('background_to_screen')
call('set_screen_target')
shape = mem.ram[LABELS['sprite_addr_lo']+1] | mem.ram[LABELS['sprite_addr_hi']+1] << 8
saved_shape = bytes(mem.vram[shape:shape+144])
mem.vram[shape:shape+144] = bytes([7])*144
for coord in ('actor_x','actor_y'):
    setvar(coord,127)
    mem[LABELS[coord]+1] = 0
cpu.a = 1
call('draw_world_actor')
assert mem.blits[-1][2:] == (2,2), 'world blit must clip at room right/bottom'
screen = getvar('back_bank') << 16
for y in range(200):
    row = mem.vram[screen+y*320:screen+(y+1)*320]
    bg = background[y*320:(y+1)*320]
    assert row[256:] == bg[256:], 'no sprite pixels in persistent right border'
    if y >= 196:
        assert row == bg, 'no sprite pixels beneath the room'
mem.vram[shape:shape+144] = saved_shape
print('PASS: edge actor/teleport-marker clipped; right and bottom borders intact')

# Actual later-room geometry with a clear airborne correction but no floor.
# Previously the support-only search rejected these and killed Porter.
original_world = (ROOT / 'data/world.dat').read_bytes()
for room, x, y in [(3,302,88),(7,814,88),(10,174,216),(12,398,176)]:
    mem.ram[0x8000:0xa000] = original_world
    setvar('cam_x', ((room-1)%8)*16)
    setvar('cam_y', ((room-1)//8)*16)
    for name, value in [('p_x',x),('p_y',y-4)]:
        mem.ram[LABELS[name]:LABELS[name]+2] = value.to_bytes(2,'little')
    setvar('p_dy',0xfc)
    setvar('p_ground',0)
    setvar('joy_state',1)  # UP held after the first jump frame
    call('try_teleport')
    assert mem.ram[LABELS['p_y']+1] != 2, ('airborne teleport incorrectly rejected',room)
    call('player_inside_solid')
    assert not cpu.p & 1, ('corrected destination still solid',room)
    assert getvar('p_dy') == 0xfc and getvar('p_ground') == 0
print('PASS: UP teleports during jumps in rooms 3, 7, 10 and 12, without requiring a floor')

setvar('sound_enabled',1)
setvar('game_mode',0)
for name in ('music_row','music_pattern','music_tick'):
    setvar(name,0)
call('music_update')
assert mem.ram[0xd205] & 15, 'title music should start immediately'
row = getvar('music_row')
setvar('game_mode',1)
call('music_update')
assert getvar('music_row') == row, 'title music continues into gameplay'
print('PASS: title music starts and continues seamlessly into gameplay')
