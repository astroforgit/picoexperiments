import sys
import random
import unittest
from test_conversion import ROOT, c, load_xex
sys.path.insert(0,str(ROOT/'tools'))
import long_music

class LongMusicTests(unittest.TestCase):
    def test_next_previous_follow_the_playing_section(self):
        from py65.devices.mpu6502 import MPU
        _,labels=long_music.build_player()
        memory=load_xex((ROOT/'remixes/warhawk/REMIX.XEX').read_bytes())
        cpu=MPU(memory=memory)
        for command,current,expected in [('forward',3,4),('backward',3,2),('forward',7,0),('backward',0,7)]:
            memory[labels['current']]=current
            memory[labels['selected']]=0
            cpu.pc=labels[command];cpu.sp=255
            for _ in range(3000):
                if cpu.pc==labels['wait_leave']: break
                cpu.step()
            else: self.fail('Section key did not return to frame loop')
            self.assertEqual(memory[labels['current']],expected)
            self.assertEqual(memory[labels['selected']],expected)

    def test_codec_overlap_and_window_wrap(self):
        rng=random.Random(12)
        random_data=bytes(rng.randrange(256) for _ in range(8000))
        for data in [b'a'*20000,random_data*3,(b'abcde'*819+b'!')*5]:
            self.assertEqual(long_music.unpack(long_music.pack(data)),data)

    def test_full_6502_arrangements_and_section_transitions(self):
        from py65.devices.mpu6502 import MPU
        player, labels=long_music.build_player()
        for game in ['draconus','commando','warhawk']:
            folder=ROOT/'remixes'/game
            memory=load_xex((folder/'REMIX.XEX').read_bytes())
            cpu=MPU(memory=memory)
            def call(label,a=0):
                cpu.a=a;cpu.pc=labels[label];cpu.sp=255
                cpu.stPushWord(0x5ff)
                start=cpu.processorCycles
                for _ in range(12000):
                    if cpu.pc==0x600:
                        self.assertLess(cpu.processorCycles-start,16000)
                        return
                    cpu.step()
                self.fail('Decoder did not return')
            call('init')
            reference=(folder/'remix-registers.bin').read_bytes()
            for frame in range(len(reference)//9):
                call('tick')
                self.assertEqual(bytes(memory[0xd200:0xd209]),reference[frame*9:frame*9+9],(game,frame))
            call('tick')
            self.assertEqual(bytes(memory[0xd200:0xd209]),reference[:9],game)

if __name__ == '__main__': unittest.main()
