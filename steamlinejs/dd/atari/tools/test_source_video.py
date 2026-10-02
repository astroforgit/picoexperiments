#!/usr/bin/env python3
"""Execute the separate XEX loader and native VBXE source-state renderer."""
import json
import random
import unittest
from pathlib import Path
from py65.devices.mpu6502 import MPU
from PIL import Image
from test_runtime import Memory as VBXEMemory
from build_source_engine import ROOT, OUT
from pack_source_chr import sets


class Memory(VBXEMemory):
    def __init__(self,page):
        super().__init__(page,50)
        self.vcount = 0

    def __getitem__(self,address):
        if address == 0xd40b:
            self.vcount += 1
            return (self.vcount//4)%156
        return super().__getitem__(address)

    def blit(self):
        p = int.from_bytes(self.ram[self.page+0x50:self.page+0x53],'little')
        assert p == 0x7f100
        b = self.vram[p:p+21]
        src,dst = int.from_bytes(b[:3],'little'),int.from_bytes(b[6:9],'little')
        sy = int.from_bytes(b[3:5],'little',signed=True)
        sx = b[5] if b[5]<128 else b[5]-256
        width,height = int.from_bytes(b[12:14],'little')+1,b[14]+1
        assert int.from_bytes(b[9:11],'little') == 256 and b[11] == 1
        assert dst>>16 in (6,7)
        assert (dst&255)+width <= 256
        assert ((dst>>8)&255)+height <= 240
        assert b[20] in (0,1) and not any(b[17:20])
        if self.ram[self.page+0x40]&1:
            visible = 6+(self.ram[self.page+0x41]//10)
            assert dst>>16 != visible, 'renderer wrote displayed framebuffer'
        for y in range(height):
            for x in range(width):
                source = src+y*sy+x*sx
                assert 0 <= source < 0x80000
                color = (self.vram[source]&b[15]) ^ b[16]
                if color or b[20] == 0:
                    self.vram[dst+y*256+x] = color
        self.blits += 1


class Preview:
    def __init__(self,page=0xd600):
        self.mem = Memory(page)
        self.cpu = MPU(memory=self.mem)
        self.labels = {}
        for name in ('runtime','video','preview'):
            self.labels.update({p[2].lower():int(p[1],16)
                for line in (OUT/(name+'.lab')).read_text().splitlines()
                if len(p:=line.split())==3})
        xex = (ROOT/'double-dragon-source-preview.xex').read_bytes()
        position = 0
        self.uploads = []
        while position < len(xex):
            start = int.from_bytes(xex[position:position+2],'little'); position += 2
            if start == 65535:
                continue
            end = int.from_bytes(xex[position:position+2],'little'); position += 2
            size = end-start+1
            assert size>0 and position+size<=len(xex)
            assert start>=0x3000 or start in (0x2e0,0x2e2), 'payload overlaps loader scratch RAM'
            for address,value in enumerate(xex[position:position+size],start):
                self.mem[address] = value
            position += size
            if start <= 0x2e2 <= end:
                entry = int.from_bytes(self.mem.ram[0x2e2:0x2e4],'little')
                if entry == self.labels['upload_bank']:
                    bank = self.mem.ram[self.labels['upload_index']]
                    expected = bytes(self.mem.ram[0x8000:0x9000])
                    self.call(entry)
                    assert self.mem.vram[bank*4096:(bank+1)*4096] == expected
                    self.uploads.append(bank)
                else:
                    self.call(entry)
        self.cpu.pc = int.from_bytes(self.mem.ram[0x2e0:0x2e2],'little')
        self.until(self.labels['video_loop'])

    def until(self,pc,limit=5000000):
        for _ in range(limit):
            if self.cpu.pc == pc:
                return
            self.cpu.step()
        raise AssertionError(f'preview stuck at ${self.cpu.pc:04x}, expected ${pc:04x}')

    def call(self,entry):
        old = self.cpu.pc
        sp = self.cpu.sp
        self.cpu.stPushWord(0x0ffe)
        self.cpu.pc = self.labels[entry] if isinstance(entry,str) else entry
        self.until(0x0fff)
        assert self.cpu.sp == sp
        self.cpu.pc = old

    def set(self,name,value):
        self.mem.ram[self.labels[name]] = value

    def displayed(self):
        bank = 6+self.mem.ram[self.mem.page+0x41]//10
        return bytes(self.mem.vram[bank*65536:bank*65536+61440])


def tiles(raw):
    return [bytes((((raw[t*16+y]>>(7-x))&1) | (((raw[t*16+8+y]>>(7-x))&1)<<1))
                  for y in range(8) for x in range(8)) for t in range(256)]


def expected(memory,bg,sprites):
    result = bytearray([1])*61440
    if memory[0x10fe]&8:
        for y in range(240):
            for x in range(256):
                wx,wy = x+memory[0x10fd],y+memory[0x10fc]
                nt = (memory[0x10ff]&3) ^ ((wx//256)&1) ^ (((wy//240)&1)<<1)
                wx %= 256; wy %= 240
                base = 0xc000+nt*0x400
                tile = memory[base+(wy//8)*32+wx//8]
                attr = memory[base+0x3c0+(wy//32)*8+wx//32]
                shift = ((wy//16)&1)*4+((wx//16)&1)*2
                color = bg[tile][(wy&7)*8+(wx&7)]
                result[y*256+x] = 1+(((attr>>shift)&3)*4+color if color else 0)
    if memory[0x10fe]&16:
        for index in range(63,-1,-1):
            y,tile,attr,x = memory[0x1200+index*4:0x1204+index*4]
            for dy in range(8):
                for dx in range(8):
                    color = sprites[tile][(7-dy if attr&128 else dy)*8+(7-dx if attr&64 else dx)]
                    if color and x+dx<256 and y+1+dy<240:
                        result[(y+1+dy)*256+x+dx] = 17+(attr&3)*4+color
    return bytes(result)


class SourceVideoTests(unittest.TestCase):
    def test_loader_both_vbxe_pages(self):
        manifest = json.loads((OUT/'preview.json').read_text())
        for page in (0xd600,0xd700):
            machine = Preview(page)
            self.assertEqual(machine.uploads,manifest['asset_pages'])
            self.assertEqual(machine.mem.ram[0x4000:0x8000],(OUT/'bank7.bin').read_bytes())
            self.assertEqual(machine.mem.ram[0xd301],0xfe)
            self.assertEqual(machine.mem.ram[0xd40e],0)
            self.assertEqual(machine.mem.ram[0xd20e],0)
            self.assertEqual(machine.mem.memb,0)
            self.assertEqual(machine.mem.memc,0x8a)
            self.assertEqual(machine.mem.bank,0x98)

    def test_native_render_matches_source_pixels_scroll_palettes_and_flips(self):
        machine = Preview()
        rng = random.Random(0x256240)
        graphics = [tiles(data) for data in sets()]
        memory = machine.mem.ram
        memory[0xc000:0xd000] = rng.getrandbits(32768).to_bytes(4096,'little')
        memory[0xd800:0xd820] = bytes(range(32))
        for index in range(64):
            memory[0x1200+index*4] = 255
        for index,(attr,x,y) in enumerate(((0,0,0),(64,32,3),(128,250,230),(192,250,238))):
            memory[0x1200+index*4:0x1204+index*4] = bytes((y,17+index,attr|(index&3),x))
        for index,(sx,sy,nt,mask) in enumerate(((0,0,0,24),(3,5,1,24),(255,239,2,24),
                                             (7,255,3,24),(0,0,0,8),(0,0,0,16),(0,0,0,0))):
            bg,sp = (16+index)%32,index%16
            machine.set('platform_bg_chr',bg)
            machine.set('platform_sprite_chr',sp)
            memory[0x10fd],memory[0x10fc],memory[0x10ff],memory[0x10fe] = sx,sy,nt,mask
            want = expected(memory,graphics[bg],graphics[sp])
            machine.call('video_render')
            self.assertEqual(machine.displayed(),want,(sx,sy,nt,mask))
            self.assertEqual(machine.mem.memb,0)
            self.assertEqual(machine.mem.bank,0x98)
        # A visible model artifact, explicitly named as such.
        image = Image.frombytes('P',(256,240),want)
        image.putpalette(machine.mem.palette)
        image.save(OUT/'native-video-model.png')


if __name__ == '__main__':
    unittest.main()
