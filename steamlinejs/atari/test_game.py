#!/usr/bin/env python3
"""Compare assembled NMOS 6502 code with the original JavaScript Player.
Requires py65 (pip install py65). No Atari OS ROM or GUI is needed.
"""
import json
import pathlib
import subprocess
from py65.devices.mpu6502 import MPU

ROOT = pathlib.Path(__file__).resolve().parent
symbols = {}
for line in (ROOT / 'streamline-atari.lab').read_text().splitlines():
    parts = line.split()
    if len(parts) == 3 and parts[0] == '00':
        symbols[parts[2].lower()] = int(parts[1], 16)

def machine():
    cpu = MPU()
    data = (ROOT / 'streamline-atari.xex').read_bytes()
    pos = 0
    while pos < len(data):
        start = int.from_bytes(data[pos:pos+2], 'little'); pos += 2
        if start == 65535:
            continue
        end = int.from_bytes(data[pos:pos+2], 'little'); pos += 2
        cpu.memory[start:end+1] = data[pos:pos+end-start+1]
        pos += end-start+1
    return cpu

def call(cpu, name, a=0):
    cpu.a = a
    cpu.sp = 0xff
    cpu.stPushWord(0x05ff)
    cpu.pc = symbols[name]
    count = 0
    while cpu.pc != 0x600:
        cpu.step(); count += 1
        if count > 1000000:
            raise AssertionError(f'{name} hung at ${cpu.pc:04x}')
    return bool(cpu.p & 1)

def setv(cpu, name, value): cpu.memory[symbols[name]] = value

def get(cpu, name): return cpu.memory[symbols[name]]

def load(cpu, case):
    rows = case['text'].split('\n')
    cells = ['.@E#PRX%^>v<LK'.index(c) for c in ''.join(rows)]
    cpu.memory[0x7c00:0x7c02+len(cells)] = [len(rows[0]), len(rows)] + cells
    # Use the normal initialization path with a supplied fixture level.
    cpu.memory[symbols['level_ptr_lo']] = 0
    cpu.memory[symbols['level_ptr_hi']] = 0x7c
    setv(cpu, 'level_number', 0)
    call(cpu, 'init_level')

# The title must display the converted bitmap before gameplay replaces its RAM.
title = machine()
bitmap = (ROOT / 'title-screen.bin').read_bytes()
assert len(bitmap) == 7296
assert bytes(title.memory[0x4000:0x4000+len(bitmap)]) == bitmap
call(title, 'setup_title')
assert title.memory[0x230] | (title.memory[0x231] << 8) == symbols['title_display_list']
assert title.memory[0x2c5] == 0x0e and title.memory[0x2c6] == 0
assert title.memory[0xd017] == 0x0e and title.memory[0xd018] == 0
assert title.memory[0x2c8] == 0
assert title.memory[0xd40e] == 0x40
display = symbols['title_display_list']
assert title.memory[display:display+6] == [0x70,0x70,0x70,0x4f,0x00,0x40]
assert title.memory[display+101:display+104] == [0x4f,0x00,0x50]
# Replace the frame wait with RTS so all three start controls are CPU-testable.
for fire, console, key in [(0,7,0xff),(1,6,0xff),(1,7,0x21)]:
    title = machine()
    title.memory[symbols['wait_frame']] = 0x60
    title.memory[0xd010] = fire
    title.memory[0xd01f] = console
    title.memory[0x2fc] = key
    call(title, 'wait_title_start')
    assert title.memory[0x2fc] == 0xff
print('PASS: native title bitmap, display list, palette and start controls.')

# Story breaks are keyed to completed board numbers. Restoring ANTIC forces a
# full board redraw even if the next level has the same dimensions.
story = machine()
assert bytes(story.memory[symbols['story_font']:symbols['story_font']+1024]) == (ROOT / 'story-font.bin').read_bytes()
call(story, 'setup_story')
assert story.memory[0x2c5] == 0x0e and story.memory[0x2c6] == 0
assert story.memory[0xd017] == 0x0e and story.memory[0xd018] == 0
page = symbols['story_page_0']
story.memory[symbols['text_src']] = page & 255
story.memory[symbols['text_src']+1] = page >> 8
call(story, 'render_story_page')
assert story.memory[0x7000+2] == 0  # no story heading
assert story.memory[0x7000+2*40+2] == ord('M') - 32
assert not any(code & 0x80 for code in story.memory[0x7000:0x73c0])
assert any(story.memory[0x7000:0x73c0])

story = machine()
call(story, 'setup_antic')
setv(story, 'level_number', 2)
call(story, 'init_level')
setv(story, 'cached_width', 8)
story.memory[symbols['wait_story_continue']] = 0x60
story.memory[0xd010] = 1
story.memory[0xd01f] = 7
call(story, 'next_level')
assert get(story, 'level_number') == 3 and get(story, 'story_page_index') == 1
assert get(story, 'cached_width') == get(story, 'level_width')
assert story.memory[0x230] | (story.memory[0x231] << 8) == symbols['display_list']
assert story.memory[0x2f4] == 0xe0
call(story, 'next_level')
assert get(story, 'level_number') == 4 and get(story, 'story_page_index') == 1
call(story, 'next_level')
assert get(story, 'level_number') == 5 and get(story, 'story_page_index') == 1
call(story, 'next_level')
assert get(story, 'level_number') == 6 and get(story, 'story_page_index') == 2
assert story.memory[0x230] | (story.memory[0x231] << 8) == symbols['display_list']

page = symbols['story_page_1']
story.memory[symbols['text_src']] = page & 255
story.memory[symbols['text_src']+1] = page >> 8
call(story, 'render_story_page')
assert story.memory[0x7000+2*40+2] == ord('N') - 32
assert not any(code & 0x80 for code in story.memory[0x7000:0x73c0])

for level in (7, 8):
    call(story, 'next_level')
    assert get(story, 'level_number') == level and get(story, 'story_page_index') == 2
call(story, 'next_level')
assert get(story, 'level_number') == 9 and get(story, 'story_page_index') == 3
assert story.memory[0x230] | (story.memory[0x231] << 8) == symbols['display_list']
for level in (10, 11):
    call(story, 'next_level')
    assert get(story, 'level_number') == level and get(story, 'story_page_index') == 3
call(story, 'next_level')
assert get(story, 'level_number') == 12 and get(story, 'story_page_index') == 4
assert (get(story, 'level_width'), get(story, 'level_height')) == (9, 9)
bonus_ptr = story.memory[symbols['level_ptr_lo']+12] | (story.memory[symbols['level_ptr_hi']+12] << 8)
bonus_rows = ['........E', '....#....', '....#....', '....#....',
              '....#....', '....#....', '..#####..', '....#....', '@........']
bonus_data = [9, 9] + ['.@E#PRX%^>v<LK'.index(char) for char in ''.join(bonus_rows)]
assert list(story.memory[bonus_ptr:bonus_ptr+len(bonus_data)]) == bonus_data
call(story, 'do_direction', 1)  # right along the bottom edge
call(story, 'do_direction', 0)  # up to the exit at top right
assert get(story, 'game_won') == 1
call(story, 'next_level')
assert get(story, 'level_number') == 13  # original authored level 13 follows

for page_number, first_letter in [(2, 'S'), (3, 'C')]:
    page_cpu = machine()
    page = symbols[f'story_page_{page_number}']
    page_cpu.memory[symbols['text_src']] = page & 255
    page_cpu.memory[symbols['text_src']+1] = page >> 8
    call(page_cpu, 'render_story_page')
    assert page_cpu.memory[0x7000+2*40+2] == ord(first_letter) - 32
    assert not any(code & 0x80 for code in page_cpu.memory[0x7000:0x73c0])

story = machine()
story.memory[symbols['wait_frame']] = 0x60
story.memory[0xd010] = 0  # still holding fire from the level win
story.memory[0xd01f] = 7
story.memory[0xd20f] = 0xff  # no key held
story.memory[0x2fc] = 0xff
story.sp = 0xff
story.stPushWord(0x05ff)
story.pc = symbols['wait_story_continue']
frames = 0
for _ in range(1000):
    if story.pc == symbols['wait_frame']:
        frames += 1
        if frames == 3:
            story.memory[0xd010] = 1  # release
        if frames == 6:
            story.memory[0xd010] = 0  # new press
    story.step()
    if story.pc == 0x600:
        break
assert story.pc == 0x600 and frames >= 6, 'story dismissed without a fresh press'

# Holding Space across story pages must not skip the next text.
# The OS may keep posting repeats to CH while SKSTAT still says key down.
story = machine()
story.memory[symbols['wait_frame']] = 0x60
story.memory[0xd010] = 1
story.memory[0xd01f] = 7
story.memory[0xd20f] = 0xfb  # Space held (SKSTAT bit 2 is active low)
story.memory[0x2fc] = 0x21
story.sp = 0xff
story.stPushWord(0x05ff)
story.pc = symbols['wait_story_continue']
frames = 0
for _ in range(1000):
    if story.pc == symbols['wait_frame']:
        frames += 1
        if frames == 2:
            story.memory[0x2fc] = 0x21  # key repeat from the previous page
        if frames == 3:
            story.memory[0xd20f] = 0xff  # release Space
        if frames == 6:
            story.memory[0xd20f] = 0xfb  # press Space again
            story.memory[0x2fc] = 0x21
    story.step()
    if story.pc == 0x600:
        break
assert story.pc == 0x600 and frames >= 6, 'story dismissed on held/repeating Space'
print('PASS: four story pages, bonus cross board and original campaign order.')

cases = json.loads(subprocess.check_output(['node', str(ROOT / 'reference_trace.js')]))
cpu = machine()
# Rendering is tested separately below; run the full movement dispatch cheaply.
cpu.memory[symbols['draw_everything']] = 0x60
cpu.memory[symbols['draw_status']] = 0x60
checks = 0
for case_index, case in enumerate(cases):
    load(cpu, case)
    for step, expected in enumerate(case['states']):
        a = expected['action']
        if a == 6: call(cpu, 'init_level')
        elif a == 5: call(cpu, 'undo_move')
        elif a == 4: call(cpu, 'switch_player')
        else: call(cpu, 'do_direction', a)
        paths = [list(cpu.memory[symbols[f'path{p}']:symbols[f'path{p}']+cpu.memory[symbols['path_len']+p]])
                 for p in range(get(cpu, 'player_count'))]
        actual = dict(paths=paths, active=get(cpu,'active_player'), moves=get(cpu,'history_count'),
                      won=get(cpu,'game_won'), key=call(cpu,'is_key_collected'))
        wanted = {k:v for k,v in expected.items() if k != 'action'}
        assert actual == wanted, f'case {case_index}, step {step}, action {a}:\n{actual}\n!=\n{wanted}'
        checks += 1
print(f'PASS: {checks} actions match original JavaScript across {len(cases)} campaign/feature cases.')

# Execute the actual display setup and renderer for every authored level.
for original_level in range(56):
    level = original_level + (original_level >= 12)
    cpu = machine()
    ptr = cpu.memory[symbols['level_ptr_lo']+level] | (cpu.memory[symbols['level_ptr_hi']+level]<<8)
    rows = cases[original_level]['text'].split('\n')
    packed = [len(rows[0]),len(rows)] + ['.@E#PRX%^>v<LK'.index(c) for c in ''.join(rows)]
    assert list(cpu.memory[ptr:ptr+len(packed)]) == packed, f'Level {level} differs from original'
    call(cpu, 'setup_antic')
    setv(cpu,'level_number',level)
    call(cpu,'init_level')
    before = list(cpu.memory)
    call(cpu,'draw_everything')
    writes = {i for i,(a,b) in enumerate(zip(before,cpu.memory)) if a != b}
    allowed = lambda i: (0xcb<=i<=0xd7 or 0x100<=i<0x200 or 0x2000<=i<0x73c0
                         or 0x7800<=i<0x7c00 or 0x7d00<=i<0x7da0 or 0x8000<=i<0xa000)
    assert all(allowed(i) for i in writes), f'Unexpected renderer writes: {[hex(i) for i in writes if not allowed(i)]}'
    assert any(cpu.memory[0x7050:0x7370]), f'Blank board on level {level}'
    assert get(cpu,'active_player') == 0
    assert cpu.memory[0x2f4] == 0xe0
    assert cpu.memory[symbols['display_list']:symbols['display_list']+3] == [0x70]*3
    w,h = get(cpu,'level_width'),get(cpu,'level_height')
    assert 1<=get(cpu,'board_y') and get(cpu,'board_y')+h*get(cpu,'tile_rows')<=19
    assert 1<=get(cpu,'board_x') and get(cpu,'board_x')+w*get(cpu,'tile_cols')<=39
    if w<=6 and h<=6:
        assert get(cpu,'tile_cols') == 3 and get(cpu,'tile_rows') == 3
    # Every tile's source glyphs must reach the selected character-row font.
    for y in range(h):
        for x in range(w):
            col=get(cpu,'board_x')+x*get(cpu,'tile_cols')
            row=get(cpu,'board_y')+y*get(cpu,'tile_rows')
            page=cpu.memory[symbols['font_pages']+row]<<8
            assert any(cpu.memory[page+col*8:page+(col+get(cpu,'tile_cols'))*8])
print('PASS: all 56 boards use bounded row fonts, adaptive zoom and preserved player state.')

# Exercise all 21 DLI entries, including footer restoration and frame wrap.
cpu=machine();call(cpu,'setup_antic');call(cpu,'init_level');call(cpu,'draw_everything')
for row in range(21):
    cpu.a,cpu.x,cpu.y=0x5a,0x13,0xa5
    cpu.sp=0xff
    cpu.stPushWord(0x600)
    cpu.stPush(cpu.p)
    cpu.pc=symbols['display_interrupt']
    for _ in range(100):
        cpu.step()
        if cpu.pc==0x600: break
    assert cpu.pc==0x600 and cpu.sp==0xff
    assert (cpu.a,cpu.x,cpu.y)==(0x5a,0x13,0xa5)
    assert cpu.memory[0xd409]==cpu.memory[symbols['font_pages']+row]
    for reg,table in [(0xd018,'dli_blue'),(0xd019,'dli_copper'),(0xd016,'dli_stone')]:
        assert cpu.memory[reg]==cpu.memory[symbols[table]+row]
assert get(cpu,'dli_index')==0 and cpu.memory[0xd409]==0xe0
assert cpu.memory[0x224] | (cpu.memory[0x225]<<8) == symbols['frame_interrupt']
setv(cpu,'dli_index',9)
cpu.memory[0xe462]=0x60  # stand-in for the OS VBI exit in this CPU-only test
call(cpu,'frame_interrupt')
assert get(cpu,'dli_index')==0
print('PASS: DLI font/palette changes, register preservation and footer/frame restoration.')

# Input paths, restart and transitions operate on the assembled executable.
cpu=machine();call(cpu,'setup_antic');call(cpu,'init_level')
load(cpu,dict(text='@..E'))
setv(cpu,'ch',0x3a); call(cpu,'read_keyboard')
assert get(cpu,'game_won') == 1
call(cpu,'next_level'); assert get(cpu,'level_number') == 1
setv(cpu,'level_number',56); call(cpu,'next_level')
assert get(cpu,'game_complete') == 1
# A full path must roll the whole attempted move back, keeping undo consistent.
load(cpu,dict(text='@R..E'))
setv(cpu,'path_len',254)
cpu.memory[symbols['path0']:symbols['path0']+254]=[0]*254
call(cpu,'do_direction',1)
assert get(cpu,'path_len') == 254 and get(cpu,'history_count') == 0
assert get(cpu,'storage_full') == 1
load(cpu,dict(text='@..E'))
setv(cpu,'history_count',255)
call(cpu,'do_direction',1)
assert get(cpu,'path_len') == 1 and get(cpu,'history_count') == 255
assert get(cpu,'storage_full') == 1
print('PASS: keyboard, win/next-level/campaign completion, and path-capacity rollback.')

# Match the rendered elephant to its first outgoing segment, at every zoom.
def assert_face(cpu, cell, expected_tile):
    width=get(cpu,'level_width')
    col=get(cpu,'board_x')+(cell%width)*get(cpu,'tile_cols')
    row=get(cpu,'board_y')+(cell//width)*get(cpu,'tile_rows')
    size=['small','medium','large'][get(cpu,'zoom')]
    source=symbols[f'tile_{size}_{expected_tile}']
    offset=0
    for dy in range(get(cpu,'tile_rows')):
        page=cpu.memory[symbols['font_pages']+row+dy]<<8
        for dx in range(get(cpu,'tile_cols')):
            dest=page+(col+dx)*8
            assert list(cpu.memory[dest:dest+8]) == list(cpu.memory[source+offset:source+offset+8]), (size,cell,expected_tile)
            offset+=8

for size in [3,7,10]:
    root=(size//2)*size+size//2
    cells=['.']*(size*size);cells[root]='@'
    case=dict(text='\n'.join(''.join(cells[y*size:(y+1)*size]) for y in range(size)))
    for delta,bend,face in [(-size,1,33),(1,size,34),(size,-1,31),(-1,-size,32)]:
        cpu=machine();call(cpu,'setup_antic');load(cpu,case)
        setv(cpu,'path_len',3)
        cpu.memory[symbols['path0']:symbols['path0']+3]=[root,root+delta,root+delta+bend]
        call(cpu,'draw_everything');assert_face(cpu,root,face)
        setv(cpu,'history_count',1);setv(cpu,'history_player',0);setv(cpu,'history_length',1)
        call(cpu,'undo_move');call(cpu,'draw_everything');assert_face(cpu,root,31)

cpu=machine();call(cpu,'setup_antic');load(cpu,dict(text='@..\n.R.\n...'))
setv(cpu,'path_len',4)
cpu.memory[symbols['path0']:symbols['path0']+4]=[0,1,4,5]
call(cpu,'draw_everything');assert_face(cpu,4,34);assert_face(cpu,0,1)
print('PASS: elephant faces its outgoing segment in all four directions and zooms, including bends, undo and reset.')

# Exercise the actual PORTA/STRIG0 reader, not only keyboard movement.
for raw,head in [(14,1),(7,5),(13,7),(11,3),(6,5),(5,5),(10,3),(9,3)]:
    cpu=machine();load(cpu,dict(text='...\n.@.\n...'))
    cpu.memory[symbols['draw_everything']]=0x60
    cpu.memory[symbols['draw_status']]=0x60
    cpu.memory[0xd010]=1
    cpu.memory[0xd300]=0xf0|raw
    call(cpu,'read_joystick')
    assert get(cpu,'path_len')==2 and cpu.memory[symbols['path0']+1]==head, raw
    assert get(cpu,'history_count')==1
    call(cpu,'read_joystick')
    assert get(cpu,'history_count')==1, 'held joystick retriggered'
    # Diagonal/cardinal wobble in the same normalized direction is one press.
    cpu.memory[0xd300]=0xa0|get(cpu,'old_stick')
    call(cpu,'read_joystick');assert get(cpu,'history_count')==1
    cpu.memory[0xd300]=0xff
    call(cpu,'read_joystick');assert get(cpu,'old_stick')==15
    cpu.memory[0xd300]=0xf0|{1:13,5:11,7:14,3:7}[head]
    call(cpu,'read_joystick');assert get(cpu,'history_count')==0

cpu=machine();load(cpu,dict(text='@@.\n...\n..E'))
cpu.memory[symbols['draw_everything']]=0x60
cpu.memory[0xd300]=0xff
cpu.memory[0xd010]=0
call(cpu,'read_joystick');assert get(cpu,'active_player')==1
call(cpu,'read_joystick');assert get(cpu,'active_player')==1
cpu.memory[0xd010]=1;call(cpu,'read_joystick')
cpu.memory[0xd010]=0;call(cpu,'read_joystick');assert get(cpu,'active_player')==0
print('PASS: joystick directions/diagonals, release/hold, analog wobble, reverse undo and fire switching.')

# Record every store, including stores of the same value, to catch transient
# erase/repaint flicker that final screenshots and memory snapshots miss.
class RecordingMemory(list):
    def __init__(self, contents):
        super().__init__(contents)
        self.writes=[]
    def __setitem__(self, key, value):
        if isinstance(key,int): self.writes.append((key,value))
        super().__setitem__(key,value)

def is_visible(addr):
    return 0x4000<=addr<0x73c0 or 0x8000<=addr<0xa000

def frame(cpu):
    return bytes(cpu.memory[0x4000:0x73c0]+cpu.memory[0x8000:0xa000])

cpu=machine();call(cpu,'setup_antic');call(cpu,'init_level');call(cpu,'draw_everything')
original_frame=frame(cpu)
cpu.memory=RecordingMemory(cpu.memory)
call(cpu,'draw_everything')
assert not any(is_visible(a) for a,v in cpu.memory.writes), 'unchanged redraw touched the screen'
old_cache=list(cpu.memory[symbols['cached_tiles']:symbols['cached_tiles']+256])
before=list(cpu.memory)
cpu.memory.writes.clear()
call(cpu,'do_direction',1)
dirty={i for i in range(get(cpu,'level_cells')) if old_cache[i]!=cpu.memory[symbols['cached_tiles']+i]}
assert dirty==set(range(25,30)), dirty
allowed=set()
for cell in dirty:
    row=get(cpu,'board_y')+(cell//get(cpu,'level_width'))*get(cpu,'tile_rows')
    col=get(cpu,'board_x')+(cell%get(cpu,'level_width'))*get(cpu,'tile_cols')
    for dy in range(get(cpu,'tile_rows')):
        page=cpu.memory[symbols['font_pages']+row+dy]<<8
        for dx in range(get(cpu,'tile_cols')):
            allowed.update(range(page+(col+dx)*8,page+(col+dx+1)*8))
            allowed.add(0x7050+(row+dy)*40+col+dx)
for addr,value in cpu.memory.writes:
    if not is_visible(addr): continue
    if 0x7000<=addr<0x7050 or 0x7370<=addr<0x73c0:
        assert value != before[addr], 'status text was erased or unnecessarily rewritten'
    else:
        assert addr in allowed, f'unchanged tile/frame was rewritten at ${addr:04x}'
cpu.memory.writes.clear();call(cpu,'draw_everything')
assert not any(is_visible(a) for a,v in cpu.memory.writes)
call(cpu,'undo_move');call(cpu,'draw_everything')
assert frame(cpu)==original_frame, 'undo left stale graphics'

# Incremental rendering must equal a full repaint after rule-driven changes.
for text in ['@K.P.E\n...L..','@P.R..E','@.%#%P.E','@..E\n@..E']:
    cpu=machine();call(cpu,'setup_antic');load(cpu,dict(text=text));call(cpu,'draw_everything')
    for action in [1,1,5,4,1,5,6]:
        if action==5: call(cpu,'undo_move')
        elif action==4: call(cpu,'switch_player')
        elif action==6: call(cpu,'init_level')
        else: call(cpu,'do_direction',action)
        call(cpu,'draw_everything')
        incremental=frame(cpu)
        setv(cpu,'cached_width',0);call(cpu,'draw_everything')
        assert frame(cpu)==incremental, (text,action)
print('PASS: unchanged cells/status receive no display writes; moves touch only dirty tiles; undo/reset/keys/portals/dual match full repaint.')
