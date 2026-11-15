import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from test_conversion import load_xex

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('arrange', ROOT/'tools/arrange.py')
a = importlib.util.module_from_spec(spec)
spec.loader.exec_module(a)


class ArrangementTests(unittest.TestCase):
    def test_porter_matches_original_6502_music_player(self):
        """Compare all 3,200 gameplay frames against the actual Porter routines."""
        from py65.devices.mpu6502 import MPU
        original = ROOT.parent/'steamlinejs/porter/atari'
        cart = json.loads((ROOT/'mscsrc/porterpatch1-1/source-music.json').read_text())
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory)
            source = '''audf3 = $d204
audf4 = $d206
audc3 = $d205
audc4 = $d207
music_ptr = $f4
MODE_END = 255
 org $2000
'''+f" icl '{original}/music-player.asm'\n icl '{original}/data/music.inc.asm'\n"+'''
sound_enabled dta 1
game_mode dta 0
music_tick dta 0
music_pattern dta 0
music_row dta 0
music_pitch dta 0,0
music_volume dta 0,0
'''
            (path/'reference.asm').write_text(source)
            subprocess.run(['mads', str(path/'reference.asm'), '-s', f'-o:{path}/reference.obx',
                            f'-t:{path}/reference.lab'], check=True, capture_output=True)
            labels = {p[2].lower(): int(p[1], 16) for line in (path/'reference.lab').read_text().splitlines()
                      if len(p := line.split()) == 3}
            memory = load_xex((path/'reference.obx').read_bytes())
            cpu = MPU(memory=memory)
            for pattern in cart['music'][:16]:
                for expected in a.porter_reference_frames(pattern, cart['sfx']):
                    cpu.pc, cpu.sp = labels['music_update'], 255
                    cpu.stPushWord(0x05ff)
                    for _ in range(10000):
                        if cpu.pc == 0x600:
                            break
                        cpu.step()
                    else:
                        self.fail('Reference music update did not return')
                    self.assertEqual(bytes(memory[0xd204:0xd208]), expected[4:8])

    def test_arranged_instruments_are_quiet_and_noise_is_short(self):
        for name in ['pushamo', 'porklike', 'celeste-classic-2']:
            cart = json.loads((ROOT/'mscsrc'/name/'source-music.json').read_text())
            profile = a.make_arrangement(cart, name)
            for s in cart['sfx']:
                if any(n[1] == 6 and n[2] for n in s['notes']):
                    break
            fixture = dict(speed=32, loop_start=0, loop_end=0,
                           notes=[[24, 6, 7, 0]]+[[0, 0, 0, 0]]*31)
            self.assertEqual(a.soft_voice(0, 4/a.FPS, [fixture], profile['channels'][0]), (0, 0))
            for p in cart['music']:
                for frame in a.render(p, cart['sfx'], 100, profile):
                    self.assertEqual(frame[8], 0)
                    self.assertTrue(all((frame[i]&15) <= 4 for i in (1, 3, 5, 7)))
                    self.assertTrue(all((frame[i]&240) in (0, 128, 160) for i in (1, 3, 5, 7)))


if __name__ == '__main__':
    unittest.main()
