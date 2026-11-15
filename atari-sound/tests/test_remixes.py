import json
from pathlib import Path
import re
import unittest
from test_conversion import c, load_xex

ROOT = Path(__file__).resolve().parents[1]


class RemixTests(unittest.TestCase):
    def test_commando_wrapper_clears_inherited_pokey_clock(self):
        from py65.devices.mpu6502 import MPU
        folder = ROOT/'remixes/commando'
        raw = load_xex((folder/'ORIGINAL.XEX').read_bytes())
        raw[0xd200:0xd209] = bytes([255]*8+[0x28])

        class Bus:
            def __getitem__(self, address):
                if address == 0xd40b:
                    return (cpu.processorCycles // 114 % 312) // 2
                if address == 0xd20f:
                    return 255  # no key held
                return raw[address]

            def __setitem__(self, address, value):
                raw[address] = value

        cpu = MPU(memory=Bus(), pc=0x2000)
        cpu.sp = 255
        expected = (folder/'original-registers.bin').read_bytes()
        frame, returning = 0, None
        for _ in range(1000000):
            if cpu.pc == 0x87e1:
                returning = (raw[0x101+cpu.sp] | raw[0x102+cpu.sp] << 8)+1
            if cpu.pc == returning:
                self.assertEqual(bytes(raw[0xd200:0xd209]), expected[frame*9:frame*9+9], frame)
                frame += 1
                returning = None
                if frame == 32:
                    return
            cpu.step()
        self.fail('Commando wrapper did not play 32 frames')

    def test_new_melodies_preserve_rhythm_and_instruments(self):
        tracks = json.loads((ROOT/'remixes/catalog.json').read_text())['tracks']
        self.assertGreaterEqual(len(tracks), 3)
        for track in tracks:
            folder = ROOT/track['directory']
            if track.get('format') == 'PMZ1':
                import sys
                sys.path.insert(0,str(ROOT/'tools'))
                import long_music
                data = (folder/'REMIX.PMZ').read_bytes()
                frames = []
                pointers = [data[0xc0+i]+256*data[0x100+i]-c.BASE for i in range(data[5])]+[len(data)]
                for start,end in zip(pointers,pointers[1:]):
                    frames.extend(c.decode(long_music.unpack(data[start:end])))
            else:
                data = (folder/'REMIX.PMS').read_bytes()
                frames = list(c.decode(data[c.HEADER:]))
            original = (folder/'original-registers.bin').read_bytes()
            self.assertEqual(len(frames), track['frames'])
            self.assertEqual(len(original), len(frames)*9)
            lead = (track['lead_channel']-1)*2
            changed = 0
            for i, frame in enumerate(frames):
                source = original[i*9:i*9+9]
                allowed = track.get('allowed_changed_registers',[lead])
                self.assertEqual(bytes(frame[j] for j in range(9) if j not in allowed),
                                 bytes(source[j] for j in range(9) if j not in allowed))
                changed += source[lead] != frame[lead]
            self.assertEqual(changed, track['changed_lead_frames'])
            # A voice may rest while other source instruments play. Measure
            # melody replacement against its audible notes, not those rests.
            from build_collection import note
            audible=sum(note(original[i*9:i*9+9],track['lead_channel']-1) is not None for i in range(len(frames)))
            self.assertGreater(changed,audible*0.75)
            self.assertGreater(changed,len(frames)*0.20)
            self.assertLessEqual(len(data), 0x8000)
            self.assertEqual(load_xex((folder/'REMIX.XEX').read_bytes())[c.BASE:c.BASE+len(data)], data)

    def test_original_source_routines_match_captured_registers(self):
        from py65.devices.mpu6502 import MPU
        tracks = json.loads((ROOT/'remixes/catalog.json').read_text())['tracks']
        for track in tracks:
            folder = ROOT/track['directory']
            sap = (folder/'original.sap').read_bytes()
            self.assertEqual(sap, (ROOT/track['source']).read_bytes())
            header = sap.split(b'\xff\xff')[0].decode('ascii')
            player = int(re.search(r'^PLAYER (\w+)', header, re.M)[1], 16)
            memory = load_xex((folder/'ORIGINAL.XEX').read_bytes())
            cpu = MPU(memory=memory)

            def call(address):
                cpu.pc, cpu.sp = address, 255
                cpu.stPushWord(0x01ff)   # stop at $0200, below every original
                for _ in range(100000):
                    if cpu.pc == 0x200:
                        return
                    cpu.step()
                self.fail(f'{track["id"]}: original did not return')

            if re.search(r'^TYPE C',header,re.M):
                music=int(re.search(r'^MUSIC (\w+)',header,re.M)[1],16)
                cpu.a,cpu.x,cpu.y=0x70,music&255,music>>8
                call(player+3)
                cpu.a,cpu.x=0,track.get('original_subsong',0)
                call(player+3)
                player+=6
            else:
                init = int(re.search(r'^INIT (\w+)', header, re.M)[1], 16)
                cpu.a,cpu.x,cpu.y = track.get('original_subsong',0),0,0
                call(init)
            expected = (folder/'original-registers.bin').read_bytes()
            for frame in range(100):
                call(player)
                self.assertEqual(bytes(memory[0xd200:0xd209]), expected[frame*9:frame*9+9],
                                 (track['id'], frame))


if __name__ == '__main__':
    unittest.main()
