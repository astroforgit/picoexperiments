"""Exercise a real boss-meteor hit and the original scroll-synchronized respawn."""
import unittest
from py65.devices.mpu6502 import MPU
from build import create_runtime
from boss_lab import call

class BossRespawn(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        _, cls.ram, _, _ = create_runtime()

    def test_meteor_hit_respawns_from_every_scroll_phase_for_both_bosses(self):
        for guardian in (0,1):
            for phase in range(4):
                with self.subTest(guardian=guardian, scroll=phase):
                    c=MPU(memory=list(self.ram));m=c.memory
                    m[0xfd04]=guardian;m[0xfd0a]=100;m[0x2d20]=4;m[0x2d22]=64
                    m[0x2dc0]=5;m[0x2dc4]=2;m[0x2dc7]=3;m[0x758e]=phase
                    m[0x4e78]=3;m[0xf398]=m[0xf0bf]=m[0x2d61]=0
                    m[0xe957:0xe959]=[12,56];m[0x1bd1]=23;m[0x1bd9]=64
                    c.x=1;call(c,0x1809);self.assertEqual(m[0xf398],3)
                    # Skip only audiovisual death effects and inventory reset.
                    # Execute the actual collision, AI, scroll gate and respawn wait.
                    for address in (0xf533,0xef86,0xf200):m[address]=0x60
                    for tick in range(8):
                        call(c,0xdac0)
                        c.pc=0xde80
                        for _ in range(60):
                            if c.pc in (0xeabd,0xead8):break
                            c.step()
                        self.assertEqual(c.pc,0xeabd,'Death must advance the original scroll clock')
                        call(c,0xfb0d)
                        if not m[0xf398]:break
                    else:self.fail('Respawn stayed stuck with invisible player')
                    self.assertEqual(m[0x4e78],2)
                    self.assertEqual(m[0xe957:0xe959],[0,56])
                    # The live boss resumes with a clean entrance and no stale rocks.
                    call(c,0xdac0)
                    self.assertEqual(m[0x2dc0],8)
                    self.assertFalse(any(m[0x1be0:0x1be8]))
                    c.pc=0xde80
                    for _ in range(40):
                        if c.pc in (0xeab0,0xead8):break
                        c.step()
                    self.assertEqual(c.pc,0xead8,'Restore the fast terrain hold after respawn')

    def test_dying_player_invalidates_both_body_caches(self):
        for buffer in (0,1):
            c=MPU(memory=list(self.ram));m=c.memory
            m[0x7439]=buffer;m[0x2dd2+buffer]=1;m[0xf398]=3
            m[0xfcc6:0xfcca]=[0]*4
            call(c,0x1783)
            self.assertEqual(m[0x2dd2+buffer],0)

if __name__=='__main__':unittest.main()
