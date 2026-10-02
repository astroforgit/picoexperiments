"""6502 opcode table (documented opcodes only)."""

# ---------------------------------------------------------------- opcodes
OPS = {}
for line in """
ADC imm 69 zp 65 zpx 75 abs 6D abx 7D aby 79 izx 61 izy 71
AND imm 29 zp 25 zpx 35 abs 2D abx 3D aby 39 izx 21 izy 31
ASL acc 0A zp 06 zpx 16 abs 0E abx 1E
BCC rel 90
BCS rel B0
BEQ rel F0
BIT zp 24 abs 2C
BMI rel 30
BNE rel D0
BPL rel 10
BRK imp 00
BVC rel 50
BVS rel 70
CLC imp 18
CLD imp D8
CLI imp 58
CLV imp B8
CMP imm C9 zp C5 zpx D5 abs CD abx DD aby D9 izx C1 izy D1
CPX imm E0 zp E4 abs EC
CPY imm C0 zp C4 abs CC
DEC zp C6 zpx D6 abs CE abx DE
DEX imp CA
DEY imp 88
EOR imm 49 zp 45 zpx 55 abs 4D abx 5D aby 59 izx 41 izy 51
INC zp E6 zpx F6 abs EE abx FE
INX imp E8
INY imp C8
JMP abs 4C ind 6C
JSR abs 20
LDA imm A9 zp A5 zpx B5 abs AD abx BD aby B9 izx A1 izy B1
LDX imm A2 zp A6 zpy B6 abs AE aby BE
LDY imm A0 zp A4 zpx B4 abs AC abx BC
LSR acc 4A zp 46 zpx 56 abs 4E abx 5E
NOP imp EA
ORA imm 09 zp 05 zpx 15 abs 0D abx 1D aby 19 izx 01 izy 11
PHA imp 48
PHP imp 08
PLA imp 68
PLP imp 28
ROL acc 2A zp 26 zpx 36 abs 2E abx 3E
ROR acc 6A zp 66 zpx 76 abs 6E abx 7E
RTI imp 40
RTS imp 60
SBC imm E9 zp E5 zpx F5 abs ED abx FD aby F9 izx E1 izy F1
SEC imp 38
SED imp F8
SEI imp 78
STA zp 85 zpx 95 abs 8D abx 9D aby 99 izx 81 izy 91
STX zp 86 zpy 96 abs 8E
STY zp 84 zpx 94 abs 8C
TAX imp AA
TAY imp A8
TSX imp BA
TXA imp 8A
TXS imp 9A
TYA imp 98
""".strip().splitlines():
    p = line.split()
    for i in range(1, len(p), 2):
        OPS[int(p[i + 1], 16)] = (p[0].lower(), p[i])
SIZE = dict(imp=1, acc=1, imm=2, zp=2, zpx=2, zpy=2, izx=2, izy=2, rel=2,
            abs=3, abx=3, aby=3, ind=3)
