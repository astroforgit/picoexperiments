"""Format, music semantics, and actual assembled 6502 decoder regression tests."""
import importlib.util
import json
from pathlib import Path
import random
import struct
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('convert', ROOT/'tools/convert.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)


def load_xex(binary):
    memory = bytearray(65536)
    pos = 0
    while pos < len(binary):
        start = int.from_bytes(binary[pos:pos+2], 'little')
        pos += 2
        if start == 65535:
            continue
        end = int.from_bytes(binary[pos:pos+2], 'little')
        pos += 2
        assert end >= start and pos+end-start+1 <= len(binary)
        memory[start:end+1] = binary[pos:pos+end-start+1]
        pos += end-start+1
    assert pos == len(binary)
    return memory


class ConversionTests(unittest.TestCase):
    def test_codec(self):
        rng = random.Random(42)
        frames = [bytes(9)]*600
        for _ in range(100):
            frames += [bytes(rng.randrange(256) for _ in range(9))]*rng.randrange(1, 300)
        self.assertEqual(list(c.decode(c.encode(frames))), frames)
        self.assertEqual(list(c.decode(c.encode([]))), [])

    def test_music_duration(self):
        sfx = [c.blank_sfx() for _ in range(64)]
        sfx[0].update(speed=8, loop_start=0, loop_end=16)
        sfx[1].update(speed=12, loop_start=24)
        p = dict(flags=0, channels=[0, 1, 64, 64])
        self.assertEqual(c.duration_ticks(p, sfx), 24*12)
        sfx[1].update(loop_start=0, loop_end=8)
        self.assertEqual(c.duration_ticks(p, sfx), 32*12)

    def test_flow(self):
        music = [dict(flags=0, channels=[0, 64, 64, 64]) for _ in range(64)]
        music[2]['flags'] = 1
        music[5]['flags'] = 2
        self.assertEqual(c.successor(5, music), 2)
        music[5]['flags'] = 6
        self.assertIsNone(c.successor(5, music))
        music[7]['channels'] = [64]*4
        self.assertIsNone(c.successor(6, music))
        self.assertIsNone(c.successor(63, music))

    def test_pitch_and_rests(self):
        sfx = [c.blank_sfx() for _ in range(64)]
        sfx[0]['notes'][0] = [33, 3, 7, 0]  # A2 = 110 Hz
        f, v, w = c.voice(0, 0, sfx)
        self.assertAlmostEqual(f, 110)
        regs = c.pokey_frame([(f, v, w)]+[(0, 0, 0)]*3)
        divisor = 114 if regs[8] else 28
        actual = c.CLOCK/(2*divisor*(regs[0]+1))
        self.assertLess(abs(actual-110), 1)
        self.assertTrue(regs[1] & 15)
        self.assertEqual(regs[3:8:2], bytes(3))
        self.assertEqual(c.voice(0, 33*c.TICK, sfx)[1], 0)

    def test_png_text_equivalence(self):
        from PIL import Image
        with tempfile.TemporaryDirectory() as d:
            d = Path(d)
            raw = bytearray(160*205)
            raw[0x3100:0x3200] = bytes([64])*256
            raw[0x3100:0x3104] = bytes([128, 65, 66, 67])
            raw[0x3200:0x3202] = bytes([33 | 0xc0, 14])
            raw[0x3241] = 8
            im = Image.new('RGBA', (160, 205))
            im.putdata([((b >> 4) & 3, (b >> 2) & 3, b & 3, (b >> 6) & 3) for b in raw])
            im.save(d/'test.p8.png')
            (d/'test.p8').write_text('pico-8 cartridge // test\nversion 42\n__sfx__\n'
                                     '00080000'+'21370'+'00000'*31+'\n__music__\n01 00 41 42 43\n')
            a, _ = c.parse_cart(d/'test.p8.png')
            b, _ = c.parse_cart(d/'test.p8')
            self.assertEqual(a, b)

    def test_all_exported_banks(self):
        catalog = json.loads((ROOT/'catalog.json').read_text())
        self.assertEqual(catalog['summary']['errors'], 0)
        for game in catalog['games']:
            folder = ROOT/game['directory']
            manifest = json.loads((folder/'manifest.json').read_text())
            for bank in manifest['banks']:
                data = (folder/(bank['file']+'.PMS')).read_bytes()
                self.assertLessEqual(len(data), c.MAX_BANK)
                self.assertEqual(data[:4], b'PMS1')
                self.assertEqual(data[5], len(bank['entries']))
                for i, e in enumerate(bank['entries']):
                    pointer = data[0xc0+i]+256*data[0x100+i]-c.BASE
                    self.assertGreaterEqual(pointer, c.HEADER)
                    self.assertLess(pointer, len(data))
                    self.assertTrue(data[0x80+i] == 255 or data[0x80+i] < data[5])
                    decoded = list(c.decode(data[pointer:]))
                    self.assertEqual(len(decoded), e['frames'])
                    self.assertTrue(all(f[8] in (0, 1) for f in decoded))
                memory = load_xex((folder/(bank['file']+'.XEX')).read_bytes())
                self.assertEqual(memory[c.BASE:c.BASE+len(data)], data)

    def test_6502_playback(self):
        from py65.devices.mpu6502 import MPU
        labels = {p[2].lower(): int(p[1], 16) for line in (ROOT/'player/player.lab').read_text().splitlines()
                  if len(p := line.split()) == 3}
        rng = random.Random(123)
        frames = [bytes([rng.randrange(256) for _ in range(8)]+[rng.randrange(2)]) for _ in range(90)]
        frames = [frames[0]]*260 + frames + [frames[-1]]*520
        data = bytearray(c.HEADER)
        data[5] = 2
        pointer = c.BASE+c.HEADER
        stream = c.encode(frames)
        for i, at in enumerate((pointer, pointer+len(stream))):
            data[0xc0+i], data[0x100+i] = at & 255, at >> 8
        data[0x80:0x82] = bytes([1, 255])
        data.extend(stream + c.encode([bytes(9)]*3))
        memory = load_xex((ROOT/'player/player.obx').read_bytes())
        memory[c.BASE:c.BASE+len(data)] = data
        cpu = MPU(memory=memory)

        def call(label, a=0):
            cpu.a, cpu.pc, cpu.sp = a, labels[label], 255
            cpu.stPushWord(0x05ff)
            cycles = cpu.processorCycles
            for _ in range(10000):
                if cpu.pc == 0x600:
                    self.assertLess(cpu.processorCycles-cycles, 2200)
                    return
                cpu.step()
            self.fail('6502 routine did not return')

        call('init')
        for expected in frames + [bytes(9)]*3:
            call('tick')
            self.assertEqual(bytes(memory[0xd200:0xd209]), expected)
        call('tick')
        self.assertEqual(memory[labels['stopped']], 1)
        self.assertEqual(memory[0xd201:0xd208:2], bytes(4))
        call('init')
        call('tick')
        saved_ptr = bytes(memory[0xf0:0xf2])
        memory[labels['paused']] = 1
        call('silence')
        call('tick')
        self.assertEqual(bytes(memory[0xf0:0xf2]), saved_ptr)
        self.assertEqual(memory[0xd201:0xd208:2], bytes(4))
        memory[labels['paused']] = 0
        call('tick')
        self.assertEqual(memory[0xd200:0xd209], frames[0])
        # Follow a real backward loop and exercise nonzero SAP subsong init.
        memory[c.BASE+0x81] = 1
        call('init', 1)
        for _ in range(10):
            call('tick')
        self.assertEqual(memory[labels['stopped']], 0)
        self.assertEqual(memory[labels['current']], 1)

    def test_6502_loader_and_controls(self):
        from py65.devices.mpu6502 import MPU
        labels = {p[2].lower(): int(p[1], 16) for line in (ROOT/'player/loader.lab').read_text().splitlines()
                  if len(p := line.split()) == 3}
        memory = load_xex((ROOT/'PLAYER.XEX').read_bytes())
        data = bytearray(c.HEADER)
        data[:6] = b'PMS1\1\2'
        data[8:48] = c.screen_text('Loader test')
        data[0x40:0x42] = bytes([10, 11])
        data[0x80:0x82] = bytes([255, 255])
        at = c.BASE+c.HEADER
        data[0xc0:0xc2] = bytes([at & 255]*2)
        data[0x100:0x102] = bytes([at >> 8]*2)
        data.extend(c.encode([bytes([20, 165, 0, 0, 0, 0, 0, 0, 1])]*10))
        cpu = MPU(memory=memory)
        cpu.pc = int.from_bytes(memory[0x2e0:0x2e2], 'little')
        commands = []
        for _ in range(20000):
            if cpu.pc == labels['wait_leave']:
                break
            if cpu.pc == 0xe456:
                command = memory[0x342+cpu.x]
                commands.append(command)
                cpu.y = 1
                if command == 5:
                    address = int.from_bytes(memory[0x344:0x346], 'little')
                    memory[address:address+11] = b'D:MUSIC.PMS\x9b'
                elif command == 7:
                    memory[c.BASE:c.BASE+len(data)] = data
                    cpu.y = 136
                cpu.pc = cpu.stPopWord()+1
            else:
                cpu.step()
        else:
            self.fail('DOS loader failed to reach playback')
        self.assertEqual(commands, [9, 5, 3, 7, 12])
        screen = labels['screen']
        self.assertEqual(memory[screen+120:screen+160], data[8:48])
        self.assertEqual(memory[screen+440:screen+471], c.screen_text('       SPACE : PAUSE / RESUME')[:31])
        memory[0xd20f] = 255         # no physical key held in this memory model

        def console(value):
            memory[0xd01f] = value
            cpu.pc = labels['controls']
            for _ in range(5000):
                if cpu.pc == labels['wait_leave']:
                    return
                cpu.step()
            self.fail('console handler did not return')

        console(5)
        self.assertEqual(memory[labels['current']], 1)
        self.assertEqual(memory[screen+295:screen+297], c.screen_text('0B')[:2])
        console(3)
        self.assertEqual(memory[labels['current']], 0)
        console(6)
        self.assertEqual(memory[labels['paused']], 1)
        console(6)
        self.assertEqual(memory[labels['paused']], 1)  # no repeat while held
        console(7)
        console(6)
        self.assertEqual(memory[labels['paused']], 0)

        def key(code):
            memory[0xd20f] = 255 if code is None else 251
            if code is not None:
                memory[0xd209] = code
            console(7)

        key(0x23)
        self.assertEqual(memory[labels['current']], 1)
        key(0x23)
        self.assertEqual(memory[labels['current']], 1)  # no repeat when held
        key(None)
        key(0x4a)                  # Shift+P also works
        self.assertEqual(memory[labels['current']], 0)
        key(None)
        key(0x21)
        self.assertEqual(memory[labels['paused']], 1)
        key(None)
        key(0x21)
        self.assertEqual(memory[labels['paused']], 0)


if __name__ == '__main__':
    unittest.main()
