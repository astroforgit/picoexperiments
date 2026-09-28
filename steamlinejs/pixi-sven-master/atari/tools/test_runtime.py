#!/usr/bin/env python3
"""Run the built XEX on py65 with deterministic OS clocks and a VBXE model.
Not a substitute for Altirra: this deliberately models no raster or DMA timing.
"""
from pathlib import Path
from py65.devices.mpu6502 import MPU
ROOT = Path(__file__).resolve().parents[1]
LABELS = {p[2].lower(): int(p[1], 16) for line in (ROOT/'generated/sven-vbxe.lab').read_text().splitlines() if len(p := line.split()) == 3}

class Memory:
    def __init__(self, page, rate):
        self.ram = bytearray(65536)
        self.vram = bytearray(0x80000)
        self.palette = bytearray(768)
        self.color = 0
        self.page = page
        self.bank = 0
        self.blits = []
        self.audio = []
        self.key = None
        self.ram[0xd014] = 1 if rate == 50 else 14
        self.ram[0xd010] = 1
        self.ram[0xd300] = 255
        self.ram[0xd01f] = 7
    def __getitem__(self, a):
        if self.page and a == self.page+0x40: return 0x10
        if self.page and a == self.page+0x53: return 0
        if a == 0xd20f: return 255 if self.key is None else 251
        if a == 0xd209: return self.key or 0
        if 0x9000 <= a < 0xa000 and self.bank & 128:
            return self.vram[(self.bank & 127)*4096+a-0x9000]
        return self.ram[a]
    def __setitem__(self, a, v):
        if 0x9000 <= a < 0xa000 and self.bank & 128:
            self.vram[(self.bank & 127)*4096+a-0x9000] = v
            return
        self.ram[a] = v
        if a == 0xd201: self.audio.append(v)
        if self.page is None: return
        if a == self.page+0x5f: self.bank = v
        if a == self.page+0x44: self.color = v
        if self.page+0x46 <= a <= self.page+0x48:
            self.palette[self.color*3+a-self.page-0x46] = v
            if a == self.page+0x48: self.color = (self.color+1) & 255
        if a == self.page+0x53 and v == 1:
            ptr = int.from_bytes(self.ram[self.page+0x50:self.page+0x53], 'little')
            assert ptr == 0x7f100
            b = self.vram[ptr:ptr+21]
            source = int.from_bytes(b[:3], 'little')
            dest = int.from_bytes(b[6:9], 'little')
            sp = int.from_bytes(b[3:5], 'little')
            dp = int.from_bytes(b[9:11], 'little')
            w = int.from_bytes(b[12:14], 'little')+1
            h = b[14]+1
            assert b[20] in (0,1) and b[5] == b[11] == 1
            assert b[15] == 255 and not any(b[16:20])
            if self.ram[self.page+0x40] & 1:
                assert dest//65536 != self.ram[self.page+0x41]//20, 'drawing into displayed framebuffer'
            assert dest//65536 in (0, 1)
            assert dest%65536//320+h <= 200
            assert dest%65536%320+w <= 320
            assert source+(h-1)*sp+w <= 0x80000
            for y in range(h):
                row = self.vram[source+y*sp:source+y*sp+w]
                if b[20] == 0:
                    self.vram[dest+y*dp:dest+y*dp+w] = row
                else:
                    for x, pixel in enumerate(row):
                        if pixel: self.vram[dest+y*dp+x] = pixel
            self.blits.append((source,dest,w,h))

class Machine:
    def __init__(self, page=0xd600, rate=50):
        self.mem = Memory(page,rate)
        self.cpu = MPU(memory=self.mem)
        data = (ROOT/'sven-vbxe.xex').read_bytes()
        i = 0
        self.uploads = 0
        while i < len(data):
            start = int.from_bytes(data[i:i+2], 'little'); i += 2
            if start == 65535: continue
            end = int.from_bytes(data[i:i+2], 'little'); i += 2
            n = end-start+1
            assert n > 0 and i+n <= len(data)
            for a, value in enumerate(data[i:i+n], start): self.mem[a] = value
            i += n
            if start <= 0x2e2 <= end:
                self.call(int.from_bytes(self.mem.ram[0x2e2:0x2e4], 'little'))
                self.uploads += 1
        self.cpu.pc = LABELS['main']
        self.run_until(LABELS['loop' if page else 'no_vbxe'])
    def clock(self, count):
        value = (int.from_bytes(self.mem.ram[0x13:0x15], 'big')+count) & 65535
        self.mem.ram[0x13:0x15] = value.to_bytes(2, 'big')
    def run_until(self, stop, limit=2000000):
        for _ in range(limit):
            if self.cpu.pc == stop: return
            if self.cpu.pc == LABELS['wait_frame']: self.clock(1)
            self.cpu.step()
        raise AssertionError(f'CPU stuck at {self.cpu.pc:04x}, expected {stop:04x}')
    def call(self, name):
        self.cpu.sp = 255
        self.cpu.stPushWord(0x05ff)
        self.cpu.pc = LABELS[name] if isinstance(name,str) else name
        start = self.cpu.processorCycles
        self.run_until(0x600)
        return self.cpu.processorCycles-start
    def get(self, name): return self.mem.ram[LABELS[name]]
    def put(self, name, value): self.mem.ram[LABELS[name]] = value
    def frame(self, count=1):
        self.call('poll_input')
        self.clock(count)
        self.call('advance_time')
    def text(self):
        return ''.join(chr(v+32) for v in self.mem.ram[LABELS['status']:LABELS['status']+80])
    def start(self):
        self.mem.ram[0xd010] = 0
        self.frame()
        self.mem.ram[0xd010] = 1
        self.frame()
        assert self.get('mode') == 1
    def screenshot(self, name):
        from PIL import Image
        page = self.mem.ram[self.mem.page+0x41]//20
        pixels = self.mem.vram[page*65536:page*65536+64000]
        im = Image.frombytes('P',(320,200),bytes(pixels))
        im.putpalette(bytes(self.mem.palette))
        im.save(ROOT/'generated'/name)

def exercise(page,rate):
    m=Machine(page,rate)
    def at(name,i=0): return m.mem.ram[LABELS[name]+i]
    def put_at(name,i,value): m.mem.ram[LABELS[name]+i]=value
    def release():
        m.mem.ram[0xd010]=1
        m.frame(2)
    def hold(ticks):
        m.mem.ram[0xd010]=0
        for _ in range((ticks*rate+49)//50): m.frame()
    def park_enemies():
        put_at('enemy_x',0,245); put_at('enemy_y',0,155)
        put_at('enemy_x',1,240); put_at('enemy_y',1,155)
    expected=b''.join(p.read_bytes() for p in sorted((ROOT/'generated').glob('bank-*.bin')))
    assert m.uploads==len(expected)//4096==80
    assert m.mem.vram[0x20000:0x20000+len(expected)]==expected
    assert m.mem.palette==(ROOT/'generated/title-palette.bin').read_bytes()
    assert m.mem.blits[-1][0] == 0x60000
    title_pixels=bytes(m.mem.vram[0x60000:0x6fa00])
    for _ in range(2):
        m.call('render')
        displayed=m.mem.ram[page+0x41]//20*65536
        assert bytes(m.mem.vram[displayed:displayed+64000]) == title_pixels
    if page==0xd600 and rate==50:m.screenshot('title-runtime.png')
    assert LABELS['display_list']//1024==(LABELS['status']-1)//1024, 'ANTIC display list crosses 1 KB boundary'
    assert m.get('rate')==rate
    initial=bytes(m.mem.ram[LABELS['sheep_age']:LABELS['sheep_age']+8])
    m.frame(rate*10)
    assert m.get('seconds')==90 and m.get('mode')==0
    assert bytes(m.mem.ram[LABELS['sheep_age']:LABELS['sheep_age']+8])==initial
    m.start();m.call('restart')
    before_blits=len(m.mem.blits)
    m.call('render')
    assert m.mem.palette==(ROOT/'generated/palette.bin').read_bytes()
    assert m.mem.blits[before_blits][0] == 0x20000
    assert m.text().startswith('SHEEP 0/8 TIME 90 LIVES 3 PTS 000')
    m.call('reset_clock')  # Presentation above consumed one modeled VBL.
    assert m.get('lives')==3
    m.mem.key=58
    x=m.get('px')
    for _ in range(rate): m.frame()
    assert m.get('px')==x+100 and m.get('seconds')==89
    m.mem.key=None;m.frame(2)
    # Pause freezes enemies, mood, progress, protection and timer.
    m.mem.key=10;m.frame()
    assert m.get('mode')==4
    frozen=tuple(m.get(v) for v in ('seconds','world_tick','dog_clock','sheep_age','invulnerable'))
    m.frame(rate*10)
    assert frozen==tuple(m.get(v) for v in ('seconds','world_tick','dog_clock','sheep_age','invulnerable'))
    m.mem.key=None;m.frame();m.mem.key=10;m.frame()
    assert m.get('mode')==1
    m.mem.key=None;m.frame()
    m.mem.ram[0xd01f]=6;m.frame()
    for _ in range(rate):m.frame()
    assert m.get('seconds')==89,'held START repeats'
    m.mem.ram[0xd01f]=7;m.frame()
    # Real clock wrap and missed renders still consume every second.
    m.call('restart');m.mem.ram[0x13:0x15]=bytes([255,250]);m.call('reset_clock')
    m.frame(rate*2+3)
    assert m.get('seconds')==88 and m.get('sheep_age')==2
    # A sheep needs sustained interaction. Partial progress survives release.
    m.call('restart');park_enemies()
    m.put('px',at('sheep_x'));m.put('py',at('sheep_y'))
    release();hold(18)
    assert at('progress')==1 and m.get('score')==0
    m.call('build_actors')
    assert 69<=at('actor_tile')<=88 and at('actor_tile',8)==255
    first=at('actor_tile');m.put('world_tick',m.get('world_tick')+8);m.call('build_actors')
    assert at('actor_tile')!=first, 'love animation must advance while stationary'
    m.call('render')
    if page==0xd600 and rate==50:m.screenshot('love-interaction.png')
    release();assert at('progress')==1
    m.call('build_actors');assert 20<=at('actor_tile')<=23 and at('actor_tile',8)!=255
    hold(55)
    assert m.get('score')==1 and at('alive')==2 and m.get('points')==25
    assert m.get('seconds')>=90
    m.call('build_actors');assert at('actor_tile')==255 and at('actor_tile',8)!=255 and m.get('battle_ticks')==0
    m.call('render')
    if page==0xd600 and rate==50:m.screenshot('milestone-collection.png')
    release()
    for _ in range(rate):m.frame()
    assert at('alive')==0
    # Sun/cloud/storm aging; a fresh whistle calms within range, held fire does
    # not repeatedly whistle, and cooldown prevents repeated instant calming.
    m.call('restart');park_enemies()
    put_at('sheep_age',0,39);m.call('age_sheep');assert at('sheep_age')==40
    m.put('px',at('sheep_x')+35);m.put('py',at('sheep_y'))
    release();hold(2)
    assert at('sheep_age')==40 and m.get('whistle_cooldown')==0
    release();hold(2)
    assert at('sheep_age')==16 and m.get('whistle_cooldown')>0
    hold(5);assert at('sheep_age')==16
    release();hold(2);assert at('sheep_age')==16
    release()
    # Dangerous sheep, dog and shepherd all take one life; protection stops
    # repeated hits, safe respawns are away from enemies, third hit ends play.
    for attacker in ('sheep','dog','shepherd','dog'):
        m.put('invulnerable',0)
        if attacker=='sheep':
            m.put('px',at('sheep_x'));m.put('py',at('sheep_y'));put_at('sheep_age',0,52)
        else:
            index=0 if attacker=='dog' else 1
            put_at('enemy_x',index,m.get('px'));put_at('enemy_y',index,m.get('py'))
        contact=(m.get('px'),m.get('py'))
        old=m.get('lives');m.call('check_hazards');assert m.get('lives')==old-(attacker!='sheep')
        if attacker=='sheep':assert m.get('battle_ticks')==0
        else:
            assert m.get('battle_ticks')==42
            assert (m.get('battle_x'),m.get('battle_y'))==contact
            m.call('build_actors');assert at('actor_tile',11)==24
            m.call('render')
            if page==0xd600 and rate==50:m.screenshot('battle-'+attacker+'.png')
        m.call('check_hazards');assert m.get('lives')==old-(attacker!='sheep')
    assert m.get('mode')==3 and m.get('lives')==0
    m.call('render');assert 'NO LIVES LEFT!' in m.text()
    # Final-hit cloud animates even on the game-over screen, then disappears.
    for _ in range(21):m.call('game_tick')
    m.call('build_actors');assert at('actor_tile',11)==31
    for _ in range(21):m.call('game_tick')
    m.call('build_actors');assert at('actor_tile',11)==255
    m.call('restart');assert m.get('battle_ticks')==0
    # Visible upper puddle, lower puddle and shoreline; water never costs a life.
    for x,y in ((20,21),(19,150),(247,149)):
        m.call('restart');m.put('px',x);m.put('py',y)
        m.call('check_water')
        assert (m.get('px'),m.get('py'))!=(x,y),('missed water',x,y)
        assert m.get('lives')==3 and m.get('water_cooldown')==50
        assert m.get('invulnerable')==50
    # Dog advances toward Sven, rests on schedule; shepherd patrol changes.
    m.call('restart')
    before=at('enemy_x');shepherd=at('enemy_x',1)
    for _ in range(rate//2):m.frame()
    assert at('enemy_x')>before and at('enemy_x',1)<shepherd
    m.put('dog_clock',105)
    dog=(at('enemy_x'),at('enemy_y'))
    for _ in range(rate//4):m.frame()
    assert dog==(at('enemy_x'),at('enemy_y'))
    # Complete all eight independently of the enemy/whistle unit cases above.
    m.call('restart')
    for i in range(8):
        park_enemies()
        m.put('px',at('sheep_x',i));m.put('py',at('sheep_y',i))
        put_at('sheep_age',i,0)
        m.put('invulnerable',100)
        release();hold(70)
        assert m.get('score')==i+1,(i,m.get('score'),m.get('mode'))
    assert m.get('mode')==2 and m.get('points')==200
    for _ in range(rate):m.frame()
    assert not any(m.mem.ram[LABELS['alive']:LABELS['alive']+8])
    assert m.mem.ram[0xd201]==0
    m.call('render');assert 'PTS 200' in m.text()
    release();hold(2);assert m.get('mode')==1 and m.get('score')==0
    release();m.call('restart');m.frame(90*rate)
    assert m.get('mode')==3 and m.get('seconds')==0
    # OPTION is an edge, finite audio silences immediately when muted.
    m.call('restart');m.put('sound_ticks',20)
    m.mem.ram[0xd01f]=3;m.frame(2)
    assert m.get('sound_enabled')==0 and m.mem.ram[0xd201]==0
    m.frame(2);assert m.get('sound_enabled')==0
    m.mem.ram[0xd01f]=7;m.frame(2);m.mem.ram[0xd01f]=3;m.frame(2)
    assert m.get('sound_enabled')==1
    m.mem.ram[0xd01f]=7;m.frame(2)
    # All moving actors are sorted; icons are a separate final pass.
    m.call('restart');m.mem.blits.clear()
    cycles=m.call('render')
    assert len(m.mem.blits)==22,len(m.mem.blits)
    ys=[b[1]%65536//320 for b in m.mem.blits[1:14]]
    assert ys==sorted(ys),ys
    target=bytearray(expected[:64000])
    for source,dest,w,h in m.mem.blits[1:]:
        for y in range(h):
            for x in range(w):
                pixel=m.mem.vram[source+y*w+x]
                if pixel:target[dest%65536+y*320+x]=pixel
    displayed=m.mem.ram[page+0x41]//20
    assert m.mem.vram[displayed*65536:displayed*65536+64000]==target
    assert cycles<22000,cycles
    assert m.text()[:40].rstrip()=='SHEEP 0/8 TIME 90 LIVES 3 PTS 000'
    if page==0xd600 and rate==50:m.screenshot('runtime-preview.png')
    import random
    rng=random.Random(727)
    for i in range(500):
        m.mem.ram[0xd300]=240|rng.randrange(16)
        m.mem.ram[0xd010]=rng.randrange(2)
        m.mem.ram[0xd01f]=rng.choice((7,7,7,6,5,3))
        m.mem.key=rng.choice((None,63,58,46,62,33,10,40))
        m.frame(rng.randrange(1,6))
        assert 10<=m.get('px')<=250 and 14<=m.get('py')<=160
        assert 0<=m.get('lives')<=3 and 0<=m.get('score')<=8
        assert m.get('seconds')<=99 and m.get('mode') in range(5)
        if i%40==0:m.call('render')
    print(f'PASS ${page:04X} {rate}Hz: uploads, clock, controls, moods/progress, whistle, enemies, lives, water, score/bonus, endings, 500 stress steps, depth/buffers; render {cycles} CPU cycles excluding DMA')

if __name__=='__main__':
    for page in (0xd600,0xd700):
        for rate in (50,60):exercise(page,rate)
    m=Machine(None)
    assert m.text()[40:].startswith('VBXE FX REQUIRED') and not m.mem.blits
    print('PASS no VBXE: requirement message, no blits')
