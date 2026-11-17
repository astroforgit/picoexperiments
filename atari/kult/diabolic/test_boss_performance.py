"""Cycle budgets and rendering guards for the native boss hot paths."""
import unittest
from py65.devices.mpu6502 import MPU
from build import create_runtime, package, kult
from boss_lab import call


class BossPerformance(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        _, cls.ram, _, _ = create_runtime()

    def scene(self):
        c = MPU(memory=list(self.ram))
        m = c.memory
        m[0xfd04] = 0
        m[0x80:0x82] = [0, 0x44]
        m[0x4401] = 128
        m[0xfb8a] = 0
        m[0xfc09] = 8
        c.a = 7
        call(c, 0x3b00)
        m[0x7e:0x80] = [0, 0x60]
        m[0x7439] = m[0x7446] = 0
        m[0x2dc0] = m[0x2dc4] = 1
        m[0x2d23:0x2d25] = [88, 48]
        m[0x2dc8] = 0
        m[0xf0bf] = 255
        for y in range(128):
            m[0x6000+y*3:0x6002+y*3] = list((0x8000+y*64).to_bytes(2, 'little'))
        call(c, 0xec4b)
        call(c, 0x0312)
        m[0x1be0:0x1be8] = [1]*6 + [0, 0]
        m[0x1bd0:0x1bd8] = [20, 32, 44, 56, 68, 80, 0, 0]
        m[0x1bd8:0x1be0] = [0, 20, 40, 60, 80, 100, 0, 0]
        return c

    def test_cache_code_survives_original_loader(self):
        original, ram, _, _ = create_runtime()
        decoded = kult(package(original, ram))[0]
        self.assertEqual(decoded[0x1780:0x1800], ram[0x1780:0x1800])

    def test_six_orb_render_and_restore_cycle_budget(self):
        c = self.scene()
        start = c.processorCycles
        for address in (0x480, 0xeb25, 0x1803, 0x1800, 0xed0d, 0xfc7e):
            call(c, address)
        # Previous renderer: 95,352 cycles for this exact workload.
        self.assertLess(c.processorCycles-start, 45000)

    def test_invisible_targets_keep_collision_state_without_bitmap_work(self):
        c = self.scene()
        targets = c.memory[0x7462:0x7472].copy()
        states = c.memory[0x74e0:0x74e8].copy()
        bitmap = c.memory[0x8000:0xc000].copy()
        call(c, 0xeb25)
        self.assertEqual(c.memory[0x8000:0xc000], bitmap)
        self.assertEqual(c.memory[0x7462:0x7472], targets)
        self.assertEqual(c.memory[0x74e0:0x74e8], states)
        self.assertEqual(c.memory[0x74a8:0x74c8], [0]*32)

    def test_actor_gate_preserves_ordinary_enemies_death_and_rewards(self):
        for mode, hp, dying, guardian in ((0,64,0,0), (4,0,0,0), (4,64,3,0), (4,64,0,1)):
            for state in (0, 16, 128):
                c = self.scene()
                m = c.memory
                m[0x2d20],m[0x2d22],m[0xf398],m[0xfd04] = mode,hp,dying,guardian
                c.y = 3
                m[0x2d21] = 1 # Existing ordinary formation has run its motion.
                m[0x74e3] = state
                call(c, 0x486)
                self.assertEqual(c.a, state)
                self.assertEqual(c.y, 3)

    def test_body_cache_reuses_each_buffer_and_invalidates_motion_and_death(self):
        for buffer, guardian in ((0,0), (1,0), (0,1), (1,1)):
            c = self.scene()
            m = c.memory
            m[0xfd04] = guardian
            m[0xfd0a] = 64
            base = 0x8000 + buffer*8192
            m[0x7439] = buffer
            m[base:base+8192] = [0]*8192
            for y in range(128):
                m[0x6000+y*3:0x6002+y*3] = list((base+y*64).to_bytes(2, 'little'))
            call(c, 0x1783)
            call(c, 0x480)
            bitmap = m[base:base+8192].copy()
            self.assertTrue(any(bitmap))
            start = c.processorCycles
            call(c, 0x1783)
            call(c, 0x480)
            self.assertLess(c.processorCycles-start, 500)
            self.assertEqual(m[base:base+8192], bitmap)
            m[0x2dc8] = 1
            call(c, 0x1783)
            self.assertFalse(any(m[base:base+8192]))
            call(c, 0x480)
            self.assertNotEqual(m[base:base+8192], bitmap)
            m[0x2dc0] = 3
            m[0x2d23] = 126
            call(c, 0x1783)
            call(c, 0x480)
            self.assertTrue(any(m[base:base+8192]))
            m[0x2d22] = m[0xfd0a] = 0
            call(c, 0x1783)
            call(c, 0x480)
            self.assertFalse(any(m[base:base+8192]))

    def test_terrain_scroll_holds_only_during_live_bosses(self):
        for mode, hp, guardian, held in ((4,64,0,True), (0,0,1,True), (4,0,0,False), (1,64,0,False), (0,0,0,False)):
            c = self.scene()
            m = c.memory
            m[0x2d20],m[0x2d22],m[0xfd04] = mode,hp,guardian
            m[0x758e] = 2
            c.pc = 0xde80
            for _ in range(40):
                if c.pc in (0xead8, 0xeab0): break
                c.step()
            self.assertEqual(c.pc, 0xead8 if held else 0xeab0)
            self.assertEqual(m[0x758e], 2 if held else 1)

if __name__ == '__main__':
    unittest.main()
