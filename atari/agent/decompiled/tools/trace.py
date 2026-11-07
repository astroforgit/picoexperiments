"""Recursive-descent code finder for the Agent USA RAM image."""
from opcodes import OPS, SIZE

BRANCHES = {'bcc', 'bcs', 'beq', 'bmi', 'bne', 'bpl', 'bvc', 'bvs'}
SETVBV = 0xE45C


def operand(ram, a):
    op, mode = OPS[ram[a]]
    n = SIZE[mode]
    if n == 2:
        v = ram[a + 1]
        if mode == 'rel':
            v = (a + 2 + (v - 256 if v > 127 else v)) & 0xFFFF
    elif n == 3:
        v = ram[a + 1] | ram[a + 2] << 8
    else:
        v = None
    return op, mode, n, v


def trace(ram, entries, valid, vectors=(), stop_after=None):
    """Follow code from entries.

    Returns (code, pairs): code maps instruction address -> length; pairs is
    a list of (lo_insn, hi_insn, vector, target) for every place that loads
    a code address into one of the given vectors with two immediates
    (lda #<x / sta vec / lda #>x / sta vec+1, in either order), or into
    the VBI with ldy #<x / ldx #>x / jsr SETVBV. valid(a) tells whether
    address a may hold code."""
    code = {}
    todo = list(entries)
    pairs = []
    vectors = set(vectors)
    stop_after = stop_after or {}
    while todo:
        a = todo.pop()
        imm = {}                 # register -> (value, insn address)
        half = {}                # vector -> {'lo'/'hi': (value, insn)}
        while True:
            if a in code or not valid(a):
                break
            if ram[a] not in OPS:
                print(f"; WARN illegal opcode {ram[a]:02X} at {a:04X}")
                break
            n = SIZE[OPS[ram[a]][1]]
            if a + n > 0x10000 or any(not valid(a + k) for k in range(n)):
                break
            op, mode, n, v = operand(ram, a)
            code[a] = n
            if mode == 'imm':
                imm[op[2]] = (v, a)
            elif op in ('sta', 'stx', 'sty') and mode in ('abs', 'zp'):
                r = op[2]
                for vec, h in ((v, 'lo'), (v - 1, 'hi')):
                    if vec in vectors and r in imm:
                        half.setdefault(vec, {})[h] = imm[r]
                        got = half[vec]
                        if 'lo' in got and 'hi' in got:
                            t = got['lo'][0] | got['hi'][0] << 8
                            pairs.append((got['lo'][1], got['hi'][1], vec, t))
                            todo.append(t)
                            del half[vec]
            elif op in ('tax', 'tay', 'txa', 'tya', 'pla', 'inx', 'iny',
                        'dex', 'dey') or (op[:2] == 'ld' and mode != 'imm'):
                r = {'tax': 'x', 'tay': 'y', 'txa': 'a', 'tya': 'a',
                     'pla': 'a', 'inx': 'x', 'dex': 'x', 'iny': 'y',
                     'dey': 'y'}.get(op, op[2])
                imm.pop(r, None)
            elif mode != 'imp' and op in ('adc', 'sbc', 'and', 'ora', 'eor',
                                          'asl', 'lsr', 'rol', 'ror'):
                imm.pop('a', None)
            if op == 'jsr':
                if v == SETVBV and 'x' in imm and 'y' in imm:
                    t = imm['y'][0] | imm['x'][0] << 8
                    pairs.append((imm['y'][1], imm['x'][1], SETVBV, t))
                    todo.append(t)
                todo.append(v)
                imm.clear()
                if v in stop_after:      # routine never returns / inline data
                    a += n + stop_after[v]
                    if stop_after[v] < 0:
                        break
                    continue
            elif op == 'jmp':
                if mode == 'abs':
                    todo.append(v)
                break
            elif op in BRANCHES:
                todo.append(v)
            elif op in ('rts', 'rti', 'brk'):
                break
            a += n
    return code, pairs
