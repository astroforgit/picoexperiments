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
for line in (ROOT / 'bimbaj.lab').read_text().splitlines():
    parts = line.split()
    if len(parts) == 3 and parts[0] == '00':
        symbols[parts[2].lower()] = int(parts[1], 16)

# The campaign as compiled from bimbaj.json by the shared format module.
campaign = json.loads(subprocess.check_output(['node', '-e',
    'const f=require("./bimbaj-format");'
    'console.log(JSON.stringify(f.compile(require("./bimbaj.json"))))'], cwd=ROOT))
assert not campaign['errors'], campaign['errors']
LEVELS = campaign['levels']
BREAKS = campaign['breaks']
PAGES = [page for pause in BREAKS for page in pause['pages']]

class BankedMemory(list):
    """PORTB bit 0 set: $C000-$CFFF and $D800-$FFFF read as OS ROM ($A5)
    and ignore writes, so bank data is only reachable with the ROM off."""
    def _rom(self, addr):
        return (0xc000 <= addr < 0xd000 or addr >= 0xd800) and list.__getitem__(self, 0xd301) & 1
    def __getitem__(self, addr):
        if type(addr) is int and self._rom(addr):
            return 0xa5
        return list.__getitem__(self, addr)
    def __setitem__(self, addr, value):
        if type(addr) is int and self._rom(addr):
            return
        list.__setitem__(self, addr, value)

def machine(banked=False):
    cpu = MPU()
    if banked:
        cpu.memory = BankedMemory(cpu.memory)
        cpu.memory[0xd301] = 0xff
    data = (ROOT / 'bimbaj.xex').read_bytes()
    pos = 0
    while pos < len(data):
        start = int.from_bytes(data[pos:pos+2], 'little'); pos += 2
        if start == 65535:
            continue
        end = int.from_bytes(data[pos:pos+2], 'little'); pos += 2
        cpu.memory[start:end+1] = data[pos:pos+end-start+1]
        pos += end-start+1
        if start <= 0x2e2 <= end:
            # The real INIT routine copies the staged chunk under the ROM.
            call(cpu, 'bank_loader')
            assert cpu.memory[0xd40e] == 0x40 and not cpu.p & 4
    return cpu

def pointer(cpu, table, index):
    return cpu.memory[symbols[table+'_lo']+index] | (cpu.memory[symbols[table+'_hi']+index] << 8)

def show_page(cpu, index):
    page = pointer(cpu, 'story_page', index)
    cpu.memory[symbols['text_src']] = page & 255
    cpu.memory[symbols['text_src']+1] = page >> 8
    call(cpu, 'render_story_page')

def expected_page_index(completed):
    index = 0
    for pause in BREAKS:
        if pause['after'] <= completed:
            index = sum(len(b['pages']) for b in BREAKS if b['after'] <= pause['after'])
    return index

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
# Every page, read from under the ROM, matches the editor's layout exactly.
for index, page in enumerate(PAGES):
    story = machine(banked=True)
    show_page(story, index)
    screen = [[0] * 40 for _ in range(24)]
    for row, col, line in page['layout']:
        for offset, char in enumerate(line):
            code = ord(char) - 32 if ' ' <= char <= '~' else 96 + 'ĄĆĘŁŃÓŚŹŻąćęłńóśźż–'.index(char)
            screen[row][col+offset] = code
    assert list(story.memory[0x7000:0x7000+960]) == sum(screen, []), f'story page {index+1}'
    assert story.memory[0xd40e] == 0x40 and story.memory[0x22f] == 0x22 and not story.p & 4

# Walk the whole campaign: pauses appear after the right levels and every
# board is fetched from under the ROM into level_buffer.
story = machine(banked=True)
assert story.memory[0xc000] == 0xa5 and story.memory[0xd301] == 0xff
story.memory[symbols['wait_story_continue']] = 0x60
story.memory[0xd010] = 1
story.memory[0xd01f] = 7
call(story, 'setup_antic')
setv(story, 'level_number', 0)
call(story, 'maybe_story_pause')  # as main does before the first level
assert get(story, 'story_page_index') == expected_page_index(0)
call(story, 'init_level')
for completed in range(1, len(LEVELS) + 1):
    setv(story, 'cached_width', 99)
    call(story, 'next_level')
    assert get(story, 'level_number') == completed
    assert get(story, 'story_page_index') == expected_page_index(completed), f'after level {completed}'
    assert story.memory[0x230] | (story.memory[0x231] << 8) == symbols['display_list']
    assert story.memory[0x2f4] == 0xe0 and story.memory[0xd40e] == 0xc0
    if completed < len(LEVELS):
        level = LEVELS[completed]['bytes']
        assert list(story.memory[symbols['level_buffer']:symbols['level_buffer']+len(level)]) == level
        assert story.memory[symbols['level_ptr']] | (story.memory[symbols['level_ptr']+1] << 8) == symbols['level_buffer']
        assert get(story, 'cached_width') == get(story, 'level_width')
assert get(story, 'game_complete') == 1

# Texts at the very start and end of the list: the campaign start and the
# last completed level both look up breaks like any other.
story = machine()
story.memory[symbols['wait_story_continue']] = 0x60
call(story, 'setup_antic')
story.memory[symbols['story_break_level']] = 0
setv(story, 'level_number', 0)
call(story, 'maybe_story_pause')
assert get(story, 'story_page_index') == len(BREAKS[0]['pages'])
story.memory[symbols['story_break_level']] = len(LEVELS)
setv(story, 'level_number', len(LEVELS) - 1)
setv(story, 'story_page_index', 0)
call(story, 'init_level')
call(story, 'next_level')
assert get(story, 'story_page_index') == len(BREAKS[0]['pages']) and get(story, 'game_complete') == 1

# The elephant's bonus board, if it is in the campaign, is solvable as built.
bonus = [i for i, level in enumerate(LEVELS) if level['name'].startswith('Elephant bonus')]
if bonus:
    story = machine()
    setv(story, 'level_number', bonus[0])
    call(story, 'init_level')
    assert (get(story, 'level_width'), get(story, 'level_height')) == (9, 9)
    call(story, 'do_direction', 1)  # right along the bottom edge
    call(story, 'do_direction', 0)  # up to the exit at top right
    assert get(story, 'game_won') == 1

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
print(f'PASS: {len(PAGES)} story pages, {len(BREAKS)} breaks and {len(LEVELS)} levels in bimbaj.json order.')

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
for level in range(len(LEVELS)):
    cpu = machine()
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
    # A 20-row board (10 rows of 2x2 tiles) replaces the top and bottom frame.
    if h*get(cpu,'tile_rows')==20: assert get(cpu,'board_y')==0
    else: assert 1<=get(cpu,'board_y') and get(cpu,'board_y')+h*get(cpu,'tile_rows')<=19
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
print(f'PASS: all {len(LEVELS)} boards use bounded row fonts, adaptive zoom and preserved player state.')

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
cpu.memory[symbols['wait_story_continue']] = 0x60
load(cpu,dict(text='@..E'))
setv(cpu,'ch',0x3a); call(cpu,'read_keyboard')
assert get(cpu,'game_won') == 1
call(cpu,'next_level'); assert get(cpu,'level_number') == 1
setv(cpu,'level_number',len(LEVELS)-1); call(cpu,'next_level')
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

# A fixed board, so editing the campaign's first level cannot break the test.
cpu=machine();call(cpu,'setup_antic');load(cpu,dict(text='....E\n...#.\n.....\n.#...\n..#..\n@....'))
call(cpu,'draw_everything')
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
