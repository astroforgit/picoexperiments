#!/usr/bin/env python3
"""Execute the actual assembled 6502 city with a functional VBXE model.
Checks logic, loader, palette and blitter bounds, not real raster/DMA timing.
Requires py65; Pillow is used only to capture rendered emulated framebuffers.
"""
from pathlib import Path
import json
from py65.devices.mpu6502 import MPU

ROOT = Path(__file__).resolve().parents[1]
LABELS = {p[2].lower(): int(p[1], 16) for line in (ROOT/'generated/city-vbxe.lab').read_text().splitlines() if len(p := line.split()) == 3}

IDLE_CACHES=json.loads((ROOT/'generated/hero-animation-layout.json').read_text()).get('idleCaches',[])

class Memory:
    def __init__(self, page):
        self.ram = bytearray(65536)
        self.vram = bytearray(0x80000)
        self.palette = bytearray(768)
        self.page, self.bank, self.color = page, 0, 0
        self.blits = 0
        self.portrait_blits = []
        self.hero_blits = []
        self.ram[0xd010] = 1
        self.ram[0xd300] = 255
        self.ram[0xd01f] = 7
        self.ram[0xd20f] = 255

    def __getitem__(self, a):
        if self.page and a == self.page+0x40: return 0x10
        if self.page and a == self.page+0x53: return 0
        if 0x9000 <= a < 0xa000 and self.bank & 128:
            return self.vram[(self.bank & 127)*4096+a-0x9000]
        return self.ram[a]

    def __setitem__(self, a, v):
        if 0x9000 <= a < 0xa000 and self.bank & 128:
            self.vram[(self.bank & 127)*4096+a-0x9000] = v
            return
        self.ram[a] = v
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
            src = int.from_bytes(b[:3], 'little')
            dst = int.from_bytes(b[6:9], 'little')
            sp = int.from_bytes(b[3:5], 'little')
            dp = int.from_bytes(b[9:11], 'little')
            w = int.from_bytes(b[12:14], 'little')+1
            h = b[14]+1
            if 0x40000 <= src < 0x44000 and w == 32 and h == 28:
                self.portrait_blits.append((src,dst))
            if src == 0x7e000 and w == 32 and h == 28:
                self.hero_blits.append((dst,bytes(self.vram[src:src+896])))
            assert b[20] in (0,1) and b[5] == b[11] == 1
            assert not any(b[17:20])
            if self.ram[self.page+0x40] & 1:
                xdl = int.from_bytes(self.ram[self.page+0x41:self.page+0x44], 'little')
                front = int.from_bytes(self.vram[xdl+3:xdl+6], 'little')//65536
                assert dst//65536 != front, 'Drawing into the displayed framebuffer'
            if dst in IDLE_CACHES:
                assert src==0x7e000 and (w,h,sp,dp)==(32,28,32,32)
                assert (b[15],b[16],b[20])==(255,0,0)
            else:
                assert dst//65536 in (0,1)
                assert dst%65536//320+h <= 200, (dst,w,h)
                assert dst%65536%320+w <= 320, (dst,w,h)
            assert src+(h-1)*sp+w <= 0x80000
            for y in range(h):
                row = self.vram[src+y*sp:src+y*sp+w]
                if b[15] == 0 and b[20] == 0:
                    self.vram[dst+y*dp:dst+y*dp+w] = bytes([b[16]])*w
                elif b[20] == 0 and b[15] == 255 and b[16] == 0:
                    self.vram[dst+y*dp:dst+y*dp+w] = row
                else:
                    for x, pixel in enumerate(row):
                        if b[20] == 0 or pixel:
                            self.vram[dst+y*dp+x] = (pixel & b[15]) ^ b[16]
            self.blits += 1

class Machine:
    def __init__(self, page=0xd600):
        self.mem = Memory(page)
        self.cpu = MPU(memory=self.mem)
        data = (ROOT/'city-vbxe.xex').read_bytes()
        i = 0
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
        self.cpu.pc = LABELS['main']
        self.run_until(LABELS['main_loop' if page else 'no_vbxe'])

    def run_until(self, stop, limit=4000000):
        for tick in range(limit):
            if self.cpu.pc == stop: return
            if tick % 1000 == 0: self.mem.ram[0x14] = (self.mem.ram[0x14]+1) & 255
            self.cpu.step()
        raise AssertionError(f'CPU stuck at {self.cpu.pc:04x}, expected {stop:04x}')

    def call(self, name):
        self.cpu.sp = 255
        self.cpu.stPushWord(0x05ff)
        self.cpu.pc = LABELS[name] if isinstance(name,str) else name
        self.run_until(0x600)

    def get(self, name, n=1):
        a=LABELS[name]
        return int.from_bytes(self.mem.ram[a:a+n], 'little')

    def put(self, name, value, n=1):
        a=LABELS[name]
        self.mem.ram[a:a+n] = value.to_bytes(n, 'little')

    def array(self, name):
        a=LABELS[name]
        return list(self.mem.ram[a:a+5])

    def key(self, value):
        self.key_down(value)
        self.key_up()

    def key_down(self, value):
        self.mem.ram[0xd209] = value
        self.mem.ram[0xd20f] = 251
        self.mem.ram[0x2fc] = value
        self.call('poll_input')

    def key_up(self):
        self.mem.ram[0xd20f] = 255
        self.idle(2)

    def idle(self, frames=120):
        for _ in range(frames): self.call('poll_input')

    def stick(self, value):
        self.mem.ram[0xd300] = value
        self.call('poll_input')

    def fire(self):
        self.mem.ram[0xd010] = 0
        self.call('poll_input')

    def release(self):
        self.mem.ram[0xd010] = 1
        self.idle(2)

    def screenshot(self, name):
        from PIL import Image
        self.call('draw_city')
        start=self.get('front_bank')*65536
        im=Image.frombytes('P',(320,200),bytes(self.mem.vram[start:start+64000]))
        im.putpalette(self.mem.palette)
        im.save(ROOT/'generated'/name)

def check(page, capture=False):
    import json
    content=json.loads((ROOT/'content.json').read_text())
    m=Machine(page)
    assert m.get('upload_index')==127
    assert m.mem.vram[0x20000:0x7f000]==(ROOT/'generated/vram.bin').read_bytes()
    assert m.mem.palette==(ROOT/'generated/palette.bin').read_bytes()
    assert m.array('building_levels')==[b['startLevel'] for b in content['buildings']]
    assert m.array('army_units')==content['startingArmy']
    assert m.get('gold',2)==content['startingGold']
    if capture:m.screenshot('city-start.png')
    m.fire();assert m.get('popup_open')==1
    m.idle(120);assert m.get('popup_open')==1 and m.get('gold',2)==50
    m.release();m.call('close_popup')
    # Every building/unit tier: purchase, recruit, upgrade, dismiss and accounting.
    m.call('clear_army');m.put('gold',60000,2)
    m.mem.ram[LABELS['building_levels']:LABELS['building_levels']+5]=bytes(5)
    expected=60000
    for family,building in enumerate(content['buildings']):
        if building.get('support'):continue
        for tier in range(3):
            m.put('selected_plot',family);m.call('purchase')
            expected-=building['costs'][tier]
            assert m.array('building_levels')[family]==tier+1
            m.call('recruit');expected-=building['recruitCosts'][tier]
            assert m.array('army_units')[0]==family*3+tier
            m.put('selected_plot',6);m.call('dismiss_unit')
            expected+=building['recruitCosts'][tier]//2
            assert m.array('army_units')==[255]*5 and m.get('army_count')==0
            assert m.get('gold',2)==expected
    m.call('new_city');m.put('gold',130,2);m.put('selected_plot',0);m.call('purchase')
    assert m.array('building_levels')[0]==3 and m.get('gold',2)==0
    m.put('gold',50,2);m.put('selected_plot',6);m.call('purchase')
    assert m.array('army_units')==[2,1,255,255,255] and m.get('gold',2)==0
    # Insufficient funds is non-mutating.
    m.put('selected_plot',0);m.call('recruit');assert m.get('notice')==1
    before=(m.array('army_units'),m.get('gold',2));m.call('show_map');m.call('show_city')
    assert before==(m.array('army_units'),m.get('gold',2))
    print(f'PASS ${page:04X}: loader, palette, startup, held Fire, all 12 recruit tiers, prices, refunds and independent upgrades.')

if __name__=='__main__':
    check(0xd600,True);check(0xd700)
    missing=Machine(None)
    assert missing.get('hardware_ok')==0 and not missing.mem.blits
    print('PASS missing VBXE: text fallback, no graphics writes.')
