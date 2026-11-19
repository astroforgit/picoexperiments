import unittest
from py65.devices.mpu6502 import MPU
from build import create_runtime
from boss_lab import call
from sound_effects import INSTRUMENTS

class SoundEffects(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.original, cls.ram, _, _ = create_runtime()

    def trace(self, memory, instrument, base):
        cpu = MPU(memory=list(memory));cpu.x=1;cpu.y=instrument;cpu.a=base
        call(cpu,0xF533)
        result=[]
        for _ in range(64):
            call(cpu,0xF51A)
            result.append(tuple(cpu.memory[0xD200:0xD209]))
        return result

    def test_effects_are_distinct_and_decay_without_changing_driver(self):
        self.assertEqual(self.ram[0xF51A:0xF60B],self.original['banks']['ram'][0xF51A:0xF60B])
        for instrument,base in ((0,24),(2,8),(3,40),(4,8)):
            trace=self.trace(self.ram,instrument,base)
            self.assertNotEqual(trace,self.trace(self.original['banks']['ram'],instrument,base))
            self.assertTrue(any(row[3]&15 for row in trace[:4]))
            self.assertTrue(all((row[3]&15)==0 for row in trace[40:]))
            self.assertTrue(all(row[8]==0 for row in trace))
            self.assertGreater(len({row[2] for row in trace[:16]}),2)

    def test_instrument_sequences_keep_original_bounds_and_silent_loops(self):
        for instrument,(_,pitch,volume) in INSTRUMENTS.items():
            for table,values in ((0xF636,pitch),(0xF640,volume)):
                pointer=int.from_bytes(self.ram[table+2*instrument:table+2*instrument+2],'little')
                self.assertEqual(self.ram[pointer+len(values)],255)
            self.assertEqual(volume[self.ram[0xF64F+instrument]],0)
        self.assertEqual(self.ram[0xF391],3)
        self.assertEqual(self.ram[0xFA86],0)

if __name__=='__main__':unittest.main()
