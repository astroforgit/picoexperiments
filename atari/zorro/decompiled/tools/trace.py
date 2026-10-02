"""Recursive-descent code finder for the Zorro RAM image."""
from opcodes import OPS, SIZE

BRANCHES = {'bcc', 'bcs', 'beq', 'bmi', 'bne', 'bpl', 'bvc', 'bvs'}
VECTORS = {0x0200: 'VDSLST', 0x0222: 'VVBLKI', 0x0224: 'VVBLKD',
           0x0216: 'VIMIRQ', 0x0208: 'VKEYBD', 0x020A: 'VSERIN',
           0x0210: 'VTIMR1', 0x0212: 'VTIMR2', 0x0214: 'VTIMR4',
           0x000A: 'DOSVEC', 0x000C: 'DOSINI', 0x0202: 'VPRCED',
           0x0206: 'VBREAK', 0xFFFA: 'NMI', 0xFFFC: 'RESET', 0xFFFE: 'IRQ'}


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


def trace(ram, entries, valid, stop_after=None):
    """Return (code: dict addr->len, targets: set, refs: dict addr->set,
    vec_sets: list). valid(a) tells whether address a may hold code."""
    code = {}
    targets = set(entries)
    todo = list(entries)
    vec_sets = []
    stop_after = stop_after or {}
    while todo:
        a = todo.pop()
        imm = {}                 # register -> last immediate value
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
                imm[op[2]] = v
            elif op in ('sta', 'stx', 'sty') and mode in ('abs', 'zp'):
                r = op[2]
                if v in VECTORS and r in imm:
                    vec_sets.append((a, v, 'lo', imm[r]))
                if v - 1 in VECTORS and r in imm:
                    vec_sets.append((a, v - 1, 'hi', imm[r]))
            elif op in ('tax', 'tay', 'txa', 'tya', 'pla') or mode in ('zp', 'abs', 'abx', 'aby', 'zpx', 'zpy', 'izx', 'izy') and op[:2] == 'ld':
                imm.pop(op[1] if op in ('tax', 'tay') else (op[2] if op[:2] == 'ld' else 'a'), None)
            if op == 'jsr':
                targets.add(v)
                todo.append(v)
                if v in stop_after:      # routine never returns / inline data
                    a += n + stop_after[v]
                    if stop_after[v] < 0:
                        break
                    continue
            elif op == 'jmp':
                if mode == 'abs':
                    targets.add(v)
                    todo.append(v)
                break
            elif op in BRANCHES:
                targets.add(v)
                todo.append(v)
            elif op in ('rts', 'rti', 'brk'):
                break
            a += n
    return code, targets, vec_sets
