#!/usr/bin/env python3
"""Static recompiler: Phoenix arcade 8080 code -> 6502 (MADS source).

Register model
  Z80 A        6502 A
  B C D E H L  zero page (zL/zH, zE/zD, zC/zB pairs are little-endian
               pointers, so (HL) is "(zL),y")
  Y            always 0
  X            scratch
  Z, S flags   6502 Z, N
  C flag       6502 C, either "normal" or "inverted" (6502 subtraction sets
               C = no borrow). A carry-polarity analysis gives every
               producer of C a polarity so that every consumer sees one.

Flag and A liveness is computed interprocedurally (calls, returns and the
jump tables found by tools/coverage.py), so a template that clobbers a
6502 flag or A only saves it when the 8080 program still needs it.

Memory: ROM data stays at its 8080 address, RAM at $4000-$4FFF. Indirect
stores go through runtime routines (st_hl/st_de/st_bc) that ignore ROM
addresses, queue changed video tiles and dispatch I/O registers.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from rom import load_rom, z80_labels  # noqa: E402
from z80dec import decode, RN, CC, Ins  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
GEN = ROOT / "gen"

A, Z, S, C = 1, 2, 4, 8
ALLF = Z | S | C
FLAGBIT = {Z: 0x02, S: 0x80, C: 0x01}
ZR = {0: "zB", 1: "zC", 2: "zD", 3: "zE", 4: "zH", 5: "zL"}
PAIR_LO = {0: "zC", 1: "zE", 2: "zL"}
PAIR_HI = {0: "zB", 1: "zD", 2: "zH"}

# ---------------------------------------------------------------- patches
# replace: start -> (end, asm lines). The 8080 instructions in [start, end)
# are not emitted (they still take part in the analysis).
# before: addr -> asm lines emitted at the instruction's label.
from patches import REPLACE, BEFORE, AFTER, EXTRA_ENTRIES, JUMP_TABLES, CODE_PUSH, CONTINUE_AFTER  # noqa: E402


class Program:
    def __init__(self):
        self.rom = load_rom()
        self.trace = json.loads((GEN / "trace.json").read_text())
        self.names = z80_labels()
        self.code = {}
        self.jp_targets = {int(k, 16): set(v) for k, v in self.trace["jp_hl"].items()}
        for pc, (fmt, tab, n) in JUMP_TABLES.items():
            for e in range(n):
                if fmt == "be":
                    t = (self.rom[tab + 2 * e] << 8) | self.rom[tab + 2 * e + 1]
                else:
                    t = 0x0700 | self.rom[tab + e]
                if t < 0x4000 and self.rom[tab + (2 * e if fmt == "be" else e)] != 0xFF:
                    self.jp_targets.setdefault(pc, set()).add(t)
        for pc, ts in self.jp_targets.items():
            extra = ts - set(self.trace["jp_hl"].get("%04X" % pc, []))
            if extra:
                print(f"JP (HL) {pc:04X}: untraced targets", " ".join(f"{t:04X}" for t in sorted(extra)))
        self.discover()
        self.build_edges()

    # ------------------------------------------------------------ discovery
    def discover(self):
        work = [0x0000] + list(EXTRA_ENTRIES)
        for ts, _ in CODE_PUSH.values():
            work += ts
        work += self.trace["pcs"]
        for v in self.jp_targets.values():
            work += v
        self.call_targets = set()
        while work:
            a = work.pop()
            if a in self.code or a >= 0x4000:
                continue
            if any(st < a < e and m != "keep" for st, (e, _, m) in REPLACE.items()):
                continue
            if a in REPLACE and REPLACE[a][2] != "keep":
                end, _, mode = REPLACE[a]
                i = Ins(a, 0, end - a, "p" + mode, text=f"patch {a:04X}-{end - 1:04X}")
                self.code[a] = i
                if mode == "fall":
                    work.append(end)
                continue
            i = decode(self.rom, a)
            if i.kind in ("bad", "halt"):
                raise SystemExit(f"reached {i.text} at {a:04X}")
            self.code[a] = i
            k = i.kind
            if k in ("jmp", "jcc"):
                work.append(i.imm)
            if k in ("call", "ccc", "rst"):
                work.append(i.imm)
                self.call_targets.add(i.imm)
            if k not in ("jmp", "ret", "pchl", "sphl"):
                work.append(i.next)
        # overlapping instructions would be a decoding error
        last = -1
        for a in sorted(self.code):
            assert a >= last, f"overlap at {a:04X}"
            last = a + self.code[a].size

    def proc_rets(self, entry):
        """RET instructions reachable from entry without following calls."""
        seen, rets, work = set(), set(), [entry]
        while work:
            a = work.pop()
            if a in seen:
                continue
            seen.add(a)
            i = self.code[a]
            if i.kind in ("ret", "rcc", "pret"):
                rets.add(a)
            if i.kind in ("jmp", "jcc"):
                work.append(i.imm)
            if i.kind == "pchl" and a in self.jp_targets and a != 0x0EE5:
                work += self.jp_targets[a]
            if i.kind not in ("jmp", "ret", "pchl", "sphl", "pret"):
                work.append(i.next)
        return rets

    def build_edges(self):
        ret_sites = {}
        for i in self.code.values():
            if i.kind in ("call", "ccc", "rst"):
                for r in self.proc_rets(i.imm):
                    ret_sites.setdefault(r, set()).add(i.next)
        self.ret_sites = ret_sites
        for i in self.code.values():
            k = i.kind
            s = []
            if k in ("jmp",):
                s = [i.imm]
            elif k == "jcc":
                s = [i.imm, i.next]
            elif k in ("call", "rst"):
                s = [i.imm]
            elif k == "ccc":
                s = [i.imm, i.next]
            elif k in ("ret", "pret"):
                s = sorted(ret_sites.get(i.addr, ()))
            elif k == "rcc":
                s = sorted(ret_sites.get(i.addr, ())) + [i.next]
            elif k == "pchl":
                s = list(self.jp_targets.get(i.addr, []))
                if not s:
                    raise SystemExit(f"JP (HL) at {i.addr:04X} without known targets")
            elif k == "sphl":
                s = []
            else:
                s = [i.next]
            i.succ = [x for x in s if x in self.code]
        # threaded code: RETs that go to pushed code addresses
        for push, (targets, ret) in CODE_PUSH.items():
            if ret is not None:
                self.code[ret].succ = list(targets)
        for push, first in CONTINUE_AFTER.items():
            nxt = CODE_PUSH[push][0]
            for t in CODE_PUSH[first][0]:
                for r in self.proc_rets(t):
                    self.code[r].succ = sorted(set(self.code[r].succ) | set(nxt))
                    self.ret_sites.setdefault(r, set()).update(nxt)
        for push, (targets, ret) in CODE_PUSH.items():
            if ret is not None:
                self.ret_sites[ret] = set(targets)
        self.preds = {a: [] for a in self.code}
        for i in self.code.values():
            for x in i.succ:
                self.preds[x].append(i.addr)

    # ------------------------------------------------------------ semantics
    @staticmethod
    def use_def(i):
        k, a, b = i.kind, i.a, i.b
        if k == "mov":
            return (A if b == 7 else 0), (A if a == 7 else 0)
        if k == "mvi":
            return 0, (A if a == 7 else 0)
        if k in ("alu", "alui"):
            src = A if (k == "alu" and b == 7) else 0
            u = A | src | (C if a in (1, 3) else 0)
            d = ALLF | (A if a != 7 else 0)
            return u, d
        if k in ("inr", "dcr"):
            return (A if a == 7 else 0), Z | S | (A if a == 7 else 0)
        if k == "dad":
            return 0, C
        if k in ("rlc", "rrc"):
            return A, A | C
        if k in ("ral", "rar"):
            return A | C, A | C
        if k == "daa":
            return A | C, A | ALLF
        if k == "cma":
            return A, A
        if k == "stc":
            return 0, C
        if k == "cmc":
            return C, C
        if k in ("lda", "ldax"):
            return 0, A
        if k in ("sta", "stax"):
            return A, 0
        if k in ("jcc", "ccc", "rcc"):
            return {0: Z, 1: Z, 2: C, 3: C, 6: S, 7: S}[a], 0
        if k == "push" and a == 3:
            return A | ALLF, 0
        if k == "pop" and a == 3:
            return 0, A | ALLF
        if k == "pfall":
            return 0, A | ALLF
        return 0, 0

    def liveness(self):
        live_in = {a: 0 for a in self.code}
        live_out = {a: 0 for a in self.code}
        ud = {a: self.use_def(i) for a, i in self.code.items()}
        order = sorted(self.code, reverse=True)
        changed = True
        while changed:
            changed = False
            for a in order:
                i = self.code[a]
                if i.kind in ("ret", "rcc", "pret") and a not in self.ret_sites:
                    out = A | ALLF          # unknown caller
                else:
                    out = 0
                    for s in i.succ:
                        out |= live_in[s]
                u, d = ud[a]
                inn = u | (out & ~d)
                if out != live_out[a] or inn != live_in[a]:
                    live_out[a], live_in[a] = out, inn
                    changed = True
        self.live_out, self.live_in = live_out, live_in

    # ------------------------------------------------------------ carry
    NAT = {"ADD": "N", "ADC": "N", "SUB": "I", "SBC": "I", "CP": "I",
           "AND": "F", "XOR": "F", "OR": "F"}

    def carry_nature(self, i):
        k = i.kind
        if k in ("alu", "alui"):
            op = ["ADD", "ADC", "SUB", "SBC", "AND", "XOR", "OR", "CP"][i.a]
            if k == "alu" and i.b == 7 and op in ("SUB", "CP"):
                return "F"
            return self.NAT[op]
        if k in ("dad", "rlc", "rrc", "ral", "rar", "daa", "cmc"):
            return "N"
        if k == "pop" and i.a == 3:
            return "N"
        if k == "pfall":
            return "N"
        if k == "stc":
            return "F"
        return None

    def carry_analysis(self):
        prods = [a for a, i in sorted(self.code.items()) if self.carry_nature(i)]
        pidx = {a: n for n, a in enumerate(prods)}
        rin = {a: 0 for a in self.code}
        rout = {a: 0 for a in self.code}
        order = sorted(self.code)
        changed = True
        while changed:
            changed = False
            for a in order:
                inn = 0
                for p in self.preds[a]:
                    inn |= rout[p]
                out = (1 << pidx[a]) if a in pidx else inn
                if inn != rin[a] or out != rout[a]:
                    rin[a], rout[a] = inn, out
                    changed = True
        parent = list(range(len(prods)))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        consumers = {}
        for a, i in self.code.items():
            u, _ = self.use_def(i)
            if u & C:
                bits = rin[a]
                ids = [n for n in range(len(prods)) if bits >> n & 1]
                consumers[a] = ids
                for n in ids[1:]:
                    parent[find(n)] = find(ids[0])
        groups = {}
        for n, a in enumerate(prods):
            groups.setdefault(find(n), []).append(a)
        self.pol = {}            # producer -> emitted polarity
        self.normalize = set()   # I producers that must invert after themselves
        for members in groups.values():
            nats = {self.carry_nature(self.code[a]) for a in members}
            g = "N" if "N" in nats else "I"
            for a in members:
                nat = self.carry_nature(self.code[a])
                self.pol[a] = g
                if nat == "I" and g == "N":
                    self.normalize.add(a)
        self.cons_pol = {}
        for a, ids in consumers.items():
            pols = {self.pol[prods[n]] for n in ids}
            assert len(pols) <= 1, f"carry polarity conflict at {a:04X}"
            self.cons_pol[a] = pols.pop() if pols else "N"
        nnorm = len(self.normalize)
        print(f"carry: {len(prods)} producers, {len(consumers)} consumers, {nnorm} normalised")

    # ------------------------------------------------------------ constants
    def io_reads(self):
        """pc -> 'in0' / 'dsw' for reads of the input ports."""
        res = {}
        starts = set()
        for i in self.code.values():
            for s in i.succ:
                if s != i.next:
                    starts.add(s)
        for a in self.ret_sites.values():
            starts |= a
        regs = {}
        for a in sorted(self.code):
            i = self.code[a]
            if a in starts or (a - 1 not in self.code and True):
                pass
            if a in starts:
                regs = {}
            k = i.kind
            port = None
            if k == "lda" and i.imm >= 0x5000:
                port = i.imm
            elif (k == "mov" and i.b == 6) or (k == "alu" and i.b == 6):
                if 4 in regs:
                    port = regs[4] << 8
            if port is not None and port >= 0x5000:
                if 0x7000 <= port < 0x7800:
                    res[a] = "in0"
                elif 0x7800 <= port < 0x8000:
                    res[a] = "dsw"
                else:
                    raise SystemExit(f"read of {port:04X} at {a:04X}")
            # track constants
            if k == "mvi" and i.a != 6:
                regs[i.a] = i.imm
            elif k == "lxi" and i.a == 2:
                regs[4], regs[5] = i.imm >> 8, i.imm & 0xFF
            elif k == "lxi" and i.a in (0, 1):
                regs[i.a * 2], regs[i.a * 2 + 1] = i.imm >> 8, i.imm & 0xFF
            elif k == "mov" and i.a != 6:
                if i.b in regs:
                    regs[i.a] = regs[i.b]
                else:
                    regs.pop(i.a, None)
            elif k in ("call", "ccc", "rst", "pop", "xchg", "xthl", "lhld", "dad", "inx", "dcx"):
                regs = {} if k in ("call", "ccc", "rst") else {
                    r: v for r, v in regs.items() if r not in (0, 1, 2, 3, 4, 5)}
            elif k in ("inr", "dcr") and i.a != 6:
                regs.pop(i.a, None)
            u, d = self.use_def(i)
            if d & A and not (k == "mvi" or (k == "mov" and i.a == 7)):
                regs.pop(7, None)
        # every port read seen by the reference model must be recognised
        for key in self.trace["io"]:
            pc, kind = key.split()
            pc = int(pc, 16)
            if kind[0] == "r" and pc not in res and not in_replace(pc):
                raise SystemExit(f"unrecognised I/O read at {pc:04X} ({kind})")
        return res


def in_replace(a):
    for s, (e, _, _) in REPLACE.items():
        if s <= a < e:
            return True
    return False


# ------------------------------------------------------------------ emitter
class Emitter:
    def __init__(self, prog):
        self.p = prog
        self.out = []
        self.nlab = 0
        self.long = set(json.loads((GEN / "longbranch.json").read_text())) if (GEN / "longbranch.json").exists() else set()
        self.nbr = 0
        self.io = prog.io_reads()

    def lab(self):
        self.nlab += 1
        return f"_t{self.nlab}"

    def br(self, op, target):
        """conditional branch; long form if an earlier assembly said so."""
        self.nbr += 1
        bid = f"b{self.nbr}"
        if bid in self.long:
            return [f"j{op[1:]} {target} ; {bid}"]
        return [f"{op} {target} ; {bid}"]

    # condition -> 6502 branch taken when the 8080 condition holds
    def cond_op(self, i, c):
        if c in (0, 1):
            return "bne" if c == 0 else "beq"
        if c in (6, 7):
            return "bpl" if c == 6 else "bmi"
        if c in (2, 3):
            pol = self.p.cons_pol.get(i.addr, "N")
            carry_set = (c == 3)
            if pol == "I":
                carry_set = not carry_set
            return "bcs" if carry_set else "bcc"
        raise SystemExit(f"parity condition at {i.addr:04X}")

    NEG = {"bne": "beq", "beq": "bne", "bcc": "bcs", "bcs": "bcc", "bpl": "bmi", "bmi": "bpl"}

    def zl(self, a):
        return f"z_{a:04X}"

    # ---- operand helpers
    def src(self, r):
        """operand text for a register source used with A-ops (adc/sbc/...)."""
        if r == 6:
            return "(zL),y"
        return ZR[r]

    def template(self, i):
        """Return (lines, clobber mask, stack-touching, defines-mask)."""
        p = self.p
        k, a, b = i.kind, i.a, i.b
        L = []
        clob = 0
        stack = False
        lo = p.live_out[i.addr]
        nxt = p.code.get(i.next)
        decimal = nxt is not None and nxt.kind == "daa"

        if k == "nop":
            return [], 0, False
        if k == "mov":
            if a == b:
                return [], 0, False
            if a == 7 and b == 6:
                io = self.io.get(i.addr)
                if io:
                    return [f"jsr rt_{io}"], Z | S | C, False
                return ["lda (zL),y"], Z | S, False
            if a == 7:
                return [f"lda {ZR[b]}"], Z | S, False
            if b == 7 and a != 6:
                return [f"sta {ZR[a]}"], 0, False
            if a == 6:
                if b == 7:
                    return ["jsr st_hl"], Z | S, False
                return [f"lda {ZR[b]}", "jsr st_hl"], A | Z | S, False
            if b == 6:
                io = self.io.get(i.addr)
                if io:
                    return [f"jsr rt_{io}", f"sta {ZR[a]}"], A | Z | S | C, False
                return ["lda (zL),y", f"sta {ZR[a]}"], A | Z | S, False
            return [f"ldx {ZR[b]}", f"stx {ZR[a]}"], Z | S, False
        if k == "mvi":
            if a == 7:
                return [f"lda #${i.imm:02X}"], Z | S, False
            if a == 6:
                return [f"lda #${i.imm:02X}", "jsr st_hl"], A | Z | S, False
            return [f"ldx #${i.imm:02X}", f"stx {ZR[a]}"], Z | S, False
        if k == "lxi":
            if a == 3:
                return [], 0, False         # LD SP: the 6502 stack is set at start-up
            return [f"ldx #${i.imm & 0xFF:02X}", f"stx {PAIR_LO[a]}",
                    f"ldx #${i.imm >> 8:02X}", f"stx {PAIR_HI[a]}"], Z | S, False
        if k == "lda":
            io = self.io.get(i.addr)
            if io:
                return [f"jsr rt_{io}"], Z | S | C, False
            return [f"lda ${i.imm:04X}"], Z | S, False
        if k == "sta":
            return self.store_abs(i.imm, None)
        if k == "lhld":
            return [f"ldx ${i.imm:04X}", "stx zL", f"ldx ${i.imm + 1:04X}", "stx zH"], Z | S, False
        if k == "shld":
            l1, c1, s1 = self.store_abs(i.imm, "zL")
            l2, c2, s2 = self.store_abs(i.imm + 1, "zH")
            return l1 + l2, c1 | c2, s1 or s2
        if k == "ldax":
            return [f"lda ({PAIR_LO[a]}),y"], Z | S, False
        if k == "stax":
            return [f"jsr st_{['bc', 'de'][a]}"], Z | S, False
        if k == "inx":
            t = self.lab()
            return [f"inc {PAIR_LO[a]}", f"bne {t}", f"inc {PAIR_HI[a]}", f"{t}"], Z | S, False
        if k == "dcx":
            t = self.lab()
            return [f"ldx {PAIR_LO[a]}", f"bne {t}", f"dec {PAIR_HI[a]}", f"{t} dec {PAIR_LO[a]}"], Z | S, False
        if k in ("inr", "dcr"):
            op = "inc" if k == "inr" else "dec"
            if a == 7:
                return ["tax", "inx" if op == "inc" else "dex", "txa"], 0, False
            if a == 6:
                return [f"jsr rt_{op}_m"], 0, False
            return [f"{op} {ZR[a]}"], 0, False
        if k == "dad":
            if a == 2:
                return ["asl zL", "rol zH"], Z | S, False
            if a == 3:
                raise SystemExit(f"ADD HL,SP at {i.addr:04X}")
            return ["clc", "lda zL", f"adc {PAIR_LO[a]}", "sta zL", "lda zH",
                    f"adc {PAIR_HI[a]}", "sta zH"], A | Z | S, False
        if k in ("alu", "alui"):
            return self.alu(i, decimal)
        if k == "rlc":
            return ["cmp #$80", "rol"], Z | S, False
        if k == "rrc":
            t = self.lab()
            return ["lsr", f"bcc {t}", "ora #$80", f"{t}"], Z | S, False
        if k in ("ral", "rar"):
            # the carry goes into A: it must have the 8080 polarity
            fix = ["rol", "eor #1", "ror"] if p.cons_pol.get(i.addr, "N") == "I" else []
            return fix + ["rol" if k == "ral" else "ror"], Z | S, False
        if k == "daa":
            prev = p.code.get(i.addr - 1)
            if prev is None or not ((prev.kind == "alu" and prev.a in (0, 1)) or (prev.kind == "alui" and prev.a in (0, 1))):
                prev = p.code.get(i.addr - 2)
            if i.addr == 0x253F:
                # XOR A / LD A,B / DAA: binary -> BCD adjust with C = AC = 0
                assert p.code[0x253D].kind == "alu" and p.code[0x253D].a == 5
                return ["jsr rt_daa0"], Z | S | C, False
            if i.addr == 0x37B2:
                # INC L / LD A,(HL) / DAA, entered with C = 0: AC comes from INC L
                assert p.preds[0x37B0] == [0x3761]
                return ["jsr rt_daa_l"], Z | S | C, False
            assert prev is not None and prev.kind in ("alu", "alui") and prev.a in (0, 1), f"DAA at {i.addr:04X}"
            # the decimal-mode add did the work; NMOS Z/N are not valid in decimal mode
            return (["tax"] if lo & (Z | S) else []), 0, False
        if k == "cma":
            return ["eor #$FF"], Z | S, False
        if k == "stc":
            if not lo & C:
                return [], 0, False
            return [("sec" if p.pol[i.addr] == "N" else "clc")], 0, False
        if k == "cmc":
            return ["rol", "eor #1", "ror"], Z | S, False
        if k == "push" and i.addr in CODE_PUSH:
            assert a == 0, "code push of BC only"
            done = self.lab()
            L = []
            for t in CODE_PUSH[i.addr][0]:
                n = self.lab()
                L += ["lda zC", f"cmp #${t & 0xFF:02X}", f"bne {n}", "lda zB", f"cmp #${t >> 8:02X}",
                      f"bne {n}", f"lda #>[{self.zl(t)}-1]", "pha", f"lda #<[{self.zl(t)}-1]", "pha",
                      f"jmp {done}", f"{n}"]
            L += ["jmp rt_crash", f"{done}"]
            return L, A | Z | S | C, True
        if k == "push":
            stack = True
            if a == 3:
                if p.cons_pol.get(i.addr, "N") == "I":
                    return ["php", "sta tR", "pla", "eor #1", "pha", "lda tR", "plp", "php", "pha"], 0, True
                return ["php", "pha"], 0, True
            return [f"lda {PAIR_HI[a]}", "pha", f"lda {PAIR_LO[a]}", "pha"], A | Z | S, True
        if k == "pop":
            if a == 3:
                return ["pla", "plp"], 0, True
            return ["pla", f"sta {PAIR_LO[a]}", "pla", f"sta {PAIR_HI[a]}"], A | Z | S, True
        if k == "xchg":
            return ["ldx zL", "ldy zE", "stx zE", "sty zL", "ldx zH", "ldy zD", "stx zD", "sty zH",
                    "ldy #0"], Z | S, False
        if k == "xthl":
            return ["tsx", "sta tR", "lda $0101,x", "ldy zL", "sta zL", "tya", "sta $0101,x",
                    "lda $0102,x", "ldy zH", "sta zH", "tya", "sta $0102,x", "ldy #0", "lda tR"], Z | S, True
        raise SystemExit(f"no template for {i.text} at {i.addr:04X}")

    def store_abs(self, addr, reg):
        """store A (reg None) or a zero page register to a fixed address."""
        load = [] if reg is None else [f"lda {reg}"]
        clob = 0 if reg is None else A | Z | S
        if 0x4000 <= addr < 0x5000:
            off = addr - 0x4000
            if (off & 0x7FF) < 0x340:       # visible tile
                return load + [f"sta ${addr:04X}", f"ldx #${addr & 0xFF:02X}", f"jsr q_push_{addr >> 8:02x}"], clob | Z | S, False
            if reg is None:
                return [f"sta ${addr:04X}"], 0, False
            return [f"ldx {reg}", f"stx ${addr:04X}"], Z | S, False
        if addr < 0x4000:
            return [], 0, False
        port = {0x50: "video", 0x58: "scroll", 0x60: "snda", 0x68: "sndb"}.get(addr >> 8 & 0xF8)
        if port is None:
            raise SystemExit(f"store to {addr:04X}")
        return load + [f"jsr io_{port}"], clob | Z | S | C, False

    def alu(self, i, decimal):
        p = self.p
        op = ["ADD", "ADC", "SUB", "SBC", "AND", "XOR", "OR", "CP"][i.a]
        lo = p.live_out[i.addr]
        imm = i.kind == "alui"
        if imm:
            arg = f"#${i.imm:02X}"
        else:
            r = i.b
            if r == 7:
                arg = None
            elif r == 6:
                io = self.io.get(i.addr)
                if io:
                    raise SystemExit(f"ALU from port at {i.addr:04X}")
                arg = "(zL),y"
            else:
                arg = ZR[r]
        pol = p.pol.get(i.addr, "N")
        cpol = p.cons_pol.get(i.addr, "N")
        L = []
        clob = 0
        if arg is None:      # operand is A itself
            if op in ("AND", "OR"):
                if lo & C:
                    L = ["cmp #0"] if pol == "I" else ["ora #0", "clc"]
                else:
                    L = ["cmp #0"]
                return L, 0, False
            if op in ("XOR", "SUB"):
                L = ["lda #0"]
                if lo & C:
                    L.append("sec" if pol == "I" else "clc")
                return L, 0, False
            if op == "CP":
                L = ["sta tR", "cmp tR"]
                if lo & C and pol == "N":
                    L += ["clc"]
                return L, 0, False
            if op == "ADD" and not decimal:
                return ["asl"], 0, False
            L = ["sta tR"]
            arg = "tR"
        if op in ("ADD", "ADC"):
            if op == "ADC" and cpol != "N":
                L += ["rol", "eor #1", "ror"]
            if decimal:
                L += ["sed"]
            if op == "ADD":
                L += ["clc"]
            L += [f"adc {arg}"]
            if decimal:
                L += ["cld"]
        elif op in ("SUB", "SBC", "CP"):
            if op == "SBC" and cpol != "I":
                L += ["rol", "eor #1", "ror"]
            if op == "SUB":
                L += ["sec"]
            L += [("cmp " if op == "CP" else "sbc ") + arg]
        else:
            L += [{"AND": "and ", "XOR": "eor ", "OR": "ora "}[op] + arg]
            if lo & C:
                L += ["sec" if pol == "I" else "clc"]
        return L, clob, False

    # ---- wrapping: keep live 8080 state the template clobbers
    def wrap(self, i, L, clob, stack):
        p = self.p
        lo = p.live_out[i.addr]
        u, d = p.use_def(i)
        presA = bool(clob & A and lo & A and not d & A)
        presF = clob & ALLF & lo & ~d
        defF = d & ALLF & lo
        if not presA and not presF:
            return L
        if not presF:
            if defF & (Z | S):
                # A restore would destroy the defined Z/S: keep them via the stack
                return ["sta tA"] + L + ["php", "lda tA", "plp"]
            return ["sta tA"] + L + ["lda tA"]
        if not presA and not defF and not stack and not (d & A and False):
            return ["php"] + L + ["plp"]
        # general case: flags through tF, A through tA (or the result through tR)
        keep = 0
        for f, bit in FLAGBIT.items():
            if presF & f:
                keep |= bit
        pre = ["sta tA", "php", "pla", "sta tF", "lda tA"]
        post = []
        if d & A:
            post += ["sta tR2"]
        if defF:
            post += ["php", "pla", f"and #${0xFF ^ keep:02X}", "sta tF2",
                     "lda tF", f"and #${keep:02X}", "ora tF2", "sta tF"]
        post += ["lda tF", "pha"]
        if d & A:
            post += ["lda tR2"]
        elif presA or True:
            post += ["lda tA"]
        post += ["plp"]
        return pre + L + post

    # ---- main
    def emit(self):
        p = self.p
        O = self.out
        targets = set()
        for i in p.code.values():
            for s in i.succ:
                if s != i.next:
                    targets.add(s)
        for s in p.ret_sites.values():
            targets |= s
        targets |= set(p.call_targets)
        skip_until = -1
        for a in sorted(p.code):
            i = p.code[a]
            if a in REPLACE:
                end, lines, _ = REPLACE[a]
                O.append(f"{self.zl(a)} ; ---- patch {a:04X}-{end - 1:04X}")
                O += ["        " + x if not x.endswith(":") else x[:-1] for x in lines]
                skip_until = end
                rstart = a
                continue
            if a < skip_until:
                for q in p.preds[a]:
                    if not (rstart <= q < skip_until):
                        raise SystemExit(f"jump into replaced code at {a:04X} from {q:04X}")
                continue
            name = p.names.get(a)
            O.append(f"{self.zl(a)}" + (f"  ; {name}" if name else ""))
            if a in BEFORE:
                O += ["        " + x for x in BEFORE[a]]
            O += [x if x.startswith("_t") else "        " + x for x in self.instr(i)]
            if a in AFTER:
                O += ["        " + x for x in AFTER[a]]
        return O

    def instr(self, i):
        p = self.p
        k = i.kind
        com = f"; {i.addr:04X} {i.text}"
        if k == "jmp":
            return [f"jmp {self.zl(i.imm)} {com}"]
        if k == "jcc":
            return [x + f" {com}" if n == 0 else x for n, x in enumerate(self.br(self.cond_op(i, i.a), self.zl(i.imm)))]
        if k == "call":
            return [f"jsr {self.zl(i.imm)} {com}"]
        if k == "rst":
            return [f"jsr {self.zl(i.imm)} {com}"]
        if k == "ccc":
            t = self.lab()
            return [f"{self.NEG[self.cond_op(i, i.a)]} {t} {com}", f"jsr {self.zl(i.imm)}", f"{t}"]
        if k == "ret":
            return [f"rts {com}"]
        if k == "rcc":
            t = self.lab()
            return [f"{self.NEG[self.cond_op(i, i.a)]} {t} {com}", "rts", f"{t}"]
        if k == "pchl":
            lo = p.live_in
            for t in p.jp_targets[i.addr]:
                if lo[t] & ALLF:
                    raise SystemExit(f"flags live into JP (HL) target {t:04X}")
            L = [f"; {i.addr:04X} JP (HL)"]
            for t in sorted(p.jp_targets[i.addr]):
                n = self.lab()
                L += ["ldx zL", f"cpx #${t & 0xFF:02X}", f"bne {n}", "ldx zH", f"cpx #${t >> 8:02X}",
                      f"bne {n}", f"jmp {self.zl(t)}", f"{n}"]
            L += [f"jmp rt_crash"]
            return L
        if k == "sphl":
            return [f"jmp rt_crash {com}"]
        L, clob, stack = self.template(i)
        # carry normalisation after an inverted producer feeding a normal group
        if i.addr in p.normalize and p.live_out[i.addr] & C:
            if p.live_out[i.addr] & (Z | S):
                L = L + ["php", "sta tA", "pla", "eor #1", "pha", "lda tA", "plp"]
            else:
                L = L + ["rol", "eor #1", "ror"]
        L = self.wrap(i, L, clob, stack)
        if L:
            L[0] = L[0] + f" {com}" if not L[0].startswith("_t") else L[0]
        else:
            L = [com]
        return L


def main():
    prog = Program()
    prog.liveness()
    prog.carry_analysis()
    em = Emitter(prog)
    lines = em.emit()
    hdr = ["; generated by tools/translate.py from the Phoenix arcade ROM -- do not edit", ""]
    (GEN / "game.asm").write_text("\n".join(hdr + lines) + "\n")
    print(f"{len(prog.code)} instructions, {len(lines)} lines, {em.nbr} branches ({len(em.long)} long)")


if __name__ == "__main__":
    main()
