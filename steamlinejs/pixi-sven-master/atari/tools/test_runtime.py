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

def exercise(page, rate):
    m = Machine(page,rate)
    expected = b''.join(p.read_bytes() for p in sorted((ROOT/'generated').glob('bank-*.bin')))
    assert m.uploads == len(expected)//4096 == 33
    assert m.mem.vram[0x20000:0x20000+len(expected)] == expected
    assert m.mem.palette == (ROOT/'generated/palette.bin').read_bytes()
    assert m.get('rate') == rate
    m.frame(rate*5)
    assert m.get('seconds') == 90 and m.get('mode') == 0, 'title consumes time'
    m.call('render')
    assert m.text()[:40] == 'SHEEP 0/8     TIME  90    SVEN VBXE     '
    m.start()
    m.call('restart')
    # Identical one-second movement and countdown on both video standards.
    m.mem.key = 58
    x = m.get('px')
    for _ in range(rate): m.frame()
    assert m.get('px') == x+100, (rate,m.get('px'),x)
    assert m.get('seconds') == 89
    m.mem.key = None; m.frame(2)
    assert m.get('moving') == 0
    # Pause freezes game time, actor positions, effects; held P does not toggle.
    m.mem.key = 10; m.frame()
    assert m.get('mode') == 4
    old = (m.get('seconds'),m.get('px'))
    m.frame(rate*3)
    assert m.get('mode') == 4 and old == (m.get('seconds'),m.get('px'))
    m.mem.key = None; m.frame()
    m.mem.key = 10; m.frame()
    assert m.get('mode') == 1
    m.mem.key = None; m.frame()
    # OPTION toggles once per press, and silences even an active envelope.
    m.put('sound_ticks',20)
    m.mem.ram[0xd01f] = 3; m.frame(2)
    assert m.get('sound_enabled') == 0 and m.mem.ram[0xd201] == 0
    m.frame(2); assert m.get('sound_enabled') == 0
    m.mem.ram[0xd01f] = 7; m.frame(2)
    m.mem.ram[0xd01f] = 3; m.frame(2)
    assert m.get('sound_enabled') == 1
    m.mem.ram[0xd01f] = 7; m.frame(2)
    # START is an edge; holding it allows subsequent movement and time.
    m.mem.ram[0xd01f] = 6; m.frame()
    for _ in range(rate): m.frame()
    assert m.get('seconds') == 89
    m.mem.ram[0xd01f] = 7; m.frame()
    # Clock wrap and multi-frame stalls count full elapsed time.
    m.call('restart')
    m.mem.ram[0x13:0x15] = bytes([255,250])
    m.call('reset_clock')
    m.frame(rate*2+3)
    assert m.get('seconds') == 88
    # Screen boundaries, including odd coordinates and opposite joystick bits.
    m.put('px',11); m.mem.ram[0xd300] = 251
    m.frame(3); assert m.get('px') >= 10
    m.put('px',249); m.mem.ram[0xd300] = 247
    m.frame(3); assert m.get('px') <= 250
    m.put('px',120); m.mem.ram[0xd300] = 243
    m.frame(3); assert m.get('px') == 120
    m.put('py',42); m.mem.ram[0xd300] = 254
    m.frame(3); assert m.get('py') == 42
    m.put('py',148); m.mem.ram[0xd300] = 253
    m.frame(3); assert m.get('py') == 148
    m.mem.ram[0xd300] = 255
    m.call('restart')
    # Far-away fire does nothing, then collect each sheep with fresh presses.
    m.put('px',250); m.put('py',148)
    m.mem.ram[0xd010] = 0; m.frame(2)
    assert m.get('score') == 0
    for i in range(8):
        m.put('px',m.mem.ram[LABELS['sheep_x']+i])
        m.put('py',m.mem.ram[LABELS['sheep_y']+i])
        m.mem.ram[0xd010] = 1; m.frame(2)
        m.mem.ram[0xd010] = 0; m.frame(2)
        assert m.get('score') == i+1
        m.frame(2)
        assert m.get('score') == i+1, 'held fire double scores/restarts'
    assert m.get('mode') == 2
    m.call('render')
    assert m.text()[:9] == 'SHEEP 8/8'
    for _ in range(rate): m.frame()
    assert not any(m.mem.ram[LABELS['alive']:LABELS['alive']+8])
    assert m.mem.ram[0xd201] == 0, 'terminal-state audio never stops'
    m.mem.ram[0xd010] = 1; m.frame()
    m.mem.ram[0xd010] = 0; m.frame()
    assert m.get('mode') == 1 and m.get('score') == 0
    m.mem.ram[0xd010] = 1; m.frame()
    m.call('restart'); m.frame(90*rate)
    assert m.get('mode') == 3 and m.get('seconds') == 0
    m.call('render'); assert m.text()[20:22] == '00'
    # Fixed-seed input stress includes dropped renders, pauses, held fire,
    # opposing directions, console keys, and keyboard/joystick mixing.
    import random
    rng = random.Random(726)
    m.call('restart')
    for i in range(400):
        m.mem.ram[0xd300] = 240 | rng.randrange(16)
        m.mem.ram[0xd010] = rng.randrange(2)
        m.mem.ram[0xd01f] = rng.choice((7,7,7,6,5,3))
        m.mem.key = rng.choice((None,63,58,46,62,33,10,40))
        m.frame(rng.randrange(1,6))
        assert 10 <= m.get('px') <= 250 and 42 <= m.get('py') <= 148
        assert 0 <= m.get('score') <= 8 and 0 <= m.get('seconds') <= 90
        assert m.get('mode') in range(5)
        if i % 40 == 0: m.call('render')
    m.mem.key = None
    m.mem.ram[0xd300] = 255
    m.mem.ram[0xd01f] = 7
    # Verify actual draw order and independently composite all blits.
    m.call('restart'); m.call('render')
    m.mem.blits.clear()
    cycles = m.call('render')
    assert len(m.mem.blits) == 10
    ys = [b[1]%65536//320 for b in m.mem.blits[1:]]
    assert ys == sorted(ys), ys
    target = bytearray(expected[:64000])
    for source,dest,w,h in m.mem.blits[1:]:
        for y in range(h):
            for x in range(w):
                pixel = m.mem.vram[source+y*w+x]
                if pixel: target[dest%65536+y*320+x] = pixel
    displayed = m.mem.ram[page+0x41]//20
    assert m.mem.vram[displayed*65536:displayed*65536+64000] == target
    assert cycles < 20000, cycles
    if page == 0xd600 and rate == 50: m.screenshot('runtime-preview.png')
    print(f'PASS ${page:04X} {rate}Hz: uploads/palette, HUD, real-time clock, WASD, pause, START edge, bounds, collection, smoke, endings/audio, depth/buffers; render {cycles} CPU cycles (excludes DMA)')

if __name__ == '__main__':
    for page in (0xd600,0xd700):
        for rate in (50,60): exercise(page,rate)
    m = Machine(None)
    assert m.text()[40:].startswith('VBXE FX REQUIRED')
    assert not m.mem.blits
    print('PASS no VBXE: readable requirement message, no blitter writes')
