"""Minimal NMOS 6502 opcode table and helpers."""
MODES = {
 'imp':0,'acc':0,'imm':1,'zp':1,'zpx':1,'zpy':1,'izx':1,'izy':1,'rel':1,
 'abs':2,'abx':2,'aby':2,'ind':2}
OPS = {}
def _d(op, name, mode): OPS[op] = (name, mode)
for op,n,m in [
 (0x00,'brk','imp'),(0x01,'ora','izx'),(0x05,'ora','zp'),(0x06,'asl','zp'),(0x08,'php','imp'),(0x09,'ora','imm'),(0x0a,'asl','acc'),(0x0d,'ora','abs'),(0x0e,'asl','abs'),
 (0x10,'bpl','rel'),(0x11,'ora','izy'),(0x15,'ora','zpx'),(0x16,'asl','zpx'),(0x18,'clc','imp'),(0x19,'ora','aby'),(0x1d,'ora','abx'),(0x1e,'asl','abx'),
 (0x20,'jsr','abs'),(0x21,'and','izx'),(0x24,'bit','zp'),(0x25,'and','zp'),(0x26,'rol','zp'),(0x28,'plp','imp'),(0x29,'and','imm'),(0x2a,'rol','acc'),(0x2c,'bit','abs'),(0x2d,'and','abs'),(0x2e,'rol','abs'),
 (0x30,'bmi','rel'),(0x31,'and','izy'),(0x35,'and','zpx'),(0x36,'rol','zpx'),(0x38,'sec','imp'),(0x39,'and','aby'),(0x3d,'and','abx'),(0x3e,'rol','abx'),
 (0x40,'rti','imp'),(0x41,'eor','izx'),(0x45,'eor','zp'),(0x46,'lsr','zp'),(0x48,'pha','imp'),(0x49,'eor','imm'),(0x4a,'lsr','acc'),(0x4c,'jmp','abs'),(0x4d,'eor','abs'),(0x4e,'lsr','abs'),
 (0x50,'bvc','rel'),(0x51,'eor','izy'),(0x55,'eor','zpx'),(0x56,'lsr','zpx'),(0x58,'cli','imp'),(0x59,'eor','aby'),(0x5d,'eor','abx'),(0x5e,'lsr','abx'),
 (0x60,'rts','imp'),(0x61,'adc','izx'),(0x65,'adc','zp'),(0x66,'ror','zp'),(0x68,'pla','imp'),(0x69,'adc','imm'),(0x6a,'ror','acc'),(0x6c,'jmp','ind'),(0x6d,'adc','abs'),(0x6e,'ror','abs'),
 (0x70,'bvs','rel'),(0x71,'adc','izy'),(0x75,'adc','zpx'),(0x76,'ror','zpx'),(0x78,'sei','imp'),(0x79,'adc','aby'),(0x7d,'adc','abx'),(0x7e,'ror','abx'),
 (0x81,'sta','izx'),(0x84,'sty','zp'),(0x85,'sta','zp'),(0x86,'stx','zp'),(0x88,'dey','imp'),(0x8a,'txa','imp'),(0x8c,'sty','abs'),(0x8d,'sta','abs'),(0x8e,'stx','abs'),
 (0x90,'bcc','rel'),(0x91,'sta','izy'),(0x94,'sty','zpx'),(0x95,'sta','zpx'),(0x96,'stx','zpy'),(0x98,'tya','imp'),(0x99,'sta','aby'),(0x9a,'txs','imp'),(0x9d,'sta','abx'),
 (0xa0,'ldy','imm'),(0xa1,'lda','izx'),(0xa2,'ldx','imm'),(0xa4,'ldy','zp'),(0xa5,'lda','zp'),(0xa6,'ldx','zp'),(0xa8,'tay','imp'),(0xa9,'lda','imm'),(0xaa,'tax','imp'),(0xac,'ldy','abs'),(0xad,'lda','abs'),(0xae,'ldx','abs'),
 (0xb0,'bcs','rel'),(0xb1,'lda','izy'),(0xb4,'ldy','zpx'),(0xb5,'lda','zpx'),(0xb6,'ldx','zpy'),(0xb8,'clv','imp'),(0xb9,'lda','aby'),(0xba,'tsx','imp'),(0xbc,'ldy','abx'),(0xbd,'lda','abx'),(0xbe,'ldx','aby'),
 (0xc0,'cpy','imm'),(0xc1,'cmp','izx'),(0xc4,'cpy','zp'),(0xc5,'cmp','zp'),(0xc6,'dec','zp'),(0xc8,'iny','imp'),(0xc9,'cmp','imm'),(0xca,'dex','imp'),(0xcc,'cpy','abs'),(0xcd,'cmp','abs'),(0xce,'dec','abs'),
 (0xd0,'bne','rel'),(0xd1,'cmp','izy'),(0xd5,'cmp','zpx'),(0xd6,'dec','zpx'),(0xd8,'cld','imp'),(0xd9,'cmp','aby'),(0xdd,'cmp','abx'),(0xde,'dec','abx'),
 (0xe0,'cpx','imm'),(0xe1,'sbc','izx'),(0xe4,'cpx','zp'),(0xe5,'sbc','zp'),(0xe6,'inc','zp'),(0xe8,'inx','imp'),(0xe9,'sbc','imm'),(0xea,'nop','imp'),(0xec,'cpx','abs'),(0xed,'sbc','abs'),(0xee,'inc','abs'),
 (0xf0,'beq','rel'),(0xf1,'sbc','izy'),(0xf5,'sbc','zpx'),(0xf6,'inc','zpx'),(0xf8,'sed','imp'),(0xf9,'sbc','aby'),(0xfd,'sbc','abx'),(0xfe,'inc','abx')]:
    _d(op,n,m)

def length(op):
    return 1 + MODES[OPS[op][1]] if op in OPS else 0

def fmt(mem, pc, base_read):
    op = base_read(pc)
    if op not in OPS:
        return f'.byte ${op:02x}', 1, None
    n, m = OPS[op]
    ln = 1 + MODES[m]
    b1 = base_read(pc+1) if ln > 1 else 0
    b2 = base_read(pc+2) if ln > 2 else 0
    w = b1 | b2 << 8
    tgt = None
    if m == 'imp': s = n
    elif m == 'acc': s = n
    elif m == 'imm': s = f'{n} #${b1:02x}'
    elif m == 'zp': s = f'{n} ${b1:02x}'
    elif m == 'zpx': s = f'{n} ${b1:02x},x'
    elif m == 'zpy': s = f'{n} ${b1:02x},y'
    elif m == 'izx': s = f'{n} (${b1:02x},x)'
    elif m == 'izy': s = f'{n} (${b1:02x}),y'
    elif m == 'rel':
        tgt = (pc + 2 + (b1 - 256 if b1 > 127 else b1)) & 0xffff
        s = f'{n} ${tgt:04x}'
    elif m == 'abs': s = f'{n} ${w:04x}'; tgt = w
    elif m == 'abx': s = f'{n} ${w:04x},x'; tgt = w
    elif m == 'aby': s = f'{n} ${w:04x},y'; tgt = w
    elif m == 'ind': s = f'{n} (${w:04x})'; tgt = w
    return s, ln, tgt
