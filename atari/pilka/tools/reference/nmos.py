"""Undocumented NMOS instructions used by Arlasoft Soccer, missing in py65.

LAX absolute is stable on the C64 6510 and Atari NMOS 6502. The immediate
form is only used as LAX #0, for which the otherwise unstable form is zero.
"""
def extend(cpu):
    cpu.instruct=list(cpu.instruct)
    cpu.cycletime=list(cpu.cycletime)
    cpu.extracycles=list(cpu.extracycles)
    cpu.disassemble=list(cpu.disassemble)
    def lax_abs(m):
        m.a=m.x=m.ByteAt(m.WordAt(m.pc));m.FlagsNZ(m.a);m.pc+=2
    def lax_zero(m):
        value=m.ByteAt(m.pc)
        if value!=0:raise ValueError('Unmodelled unstable LAX immediate operand')
        m.a=m.x=0;m.FlagsNZ(0);m.pc+=1
    for op,fn,mode,cycles in [(0xaf,lax_abs,'abs',4),(0xab,lax_zero,'imm',2)]:
        cpu.instruct[op]=fn;cpu.cycletime[op]=cycles;cpu.extracycles[op]=0
        cpu.disassemble[op]=('LAX',mode)
    return cpu
