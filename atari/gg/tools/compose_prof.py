#!/usr/bin/env python3
"""Cost of one picture (compose_main) by phase: compose_prof.py SNAP [N]"""
import collections
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap  # noqa: E402
from atari_emu import load_labels  # noqa: E402
from nmi_prof import bank_labels, where  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
bl = bank_labels()
P = [('cm_read', 'read'), ('cm_band', 'band'), ('cmb', 'band'), ('rec_region', 'region'), ('rr_', 'region'),
     ('rec_sprites', 'sprites-rec'), ('rs_', 'sprites-rec'), ('rse', 'sprites-rec'), ('rec_palette', 'pal'),
     ('rp_l', 'pal'), ('rows_state', 'rows'), ('rws', 'rows'), ('far_', 'calls'), ('pal_', 'pal'), ('pu_', 'pal'),
     ('compose_sprites', 'sprites-emit'), ('csp', 'sprites-emit'), ('spr_one', 'sprites-emit'),
     ('so_', 'sprites-emit'), ('spr_addr', 'sprites-emit'), ('slot_ptr', 'sprites-emit'),
     ('spr_lookup', 'lookup'), ('sl_', 'lookup'), ('spr_expand', 'expand'), ('se_', 'expand'),
     ('compose', 'regions-emit'), ('cg_', 'regions-emit'), ('cl_', 'regions-emit'), ('copy', 'regions-emit'),
     ('cp', 'regions-emit'), ('fill', 'regions-emit'), ('fc_', 'regions-emit'), ('emit_reg', 'regions-emit'),
     ('er_', 'regions-emit'), ('slot_adv', 'regions-emit'), ('border', 'regions-emit'), ('bc_', 'regions-emit'),
     ('fb_row', 'fbrow'), ('fb_line', 'replay'), ('fl_', 'replay'), ('compose_main', 'replay'), ('cm_', 'replay'),
     ('mul21', 'list'), ('m21', 'list')]
a = load_snap(sys.argv[1])
n = int(sys.argv[2]) if len(sys.argv) > 2 else 6
cpu, r = a.cpu, a.mem.ram
cm = [x for x, nm in bl[0xFB] if nm == 'compose_main'][0]
c = collections.Counter()
done = 0
depth = None
while done < n:
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
    pc = cpu.pc
    if depth is None and pc == cm and a.mems == 0xFB and r[lab['LOG_NEW']] and r[lab['READY']] == 255:
        depth = cpu.sp
    c0 = cpu.processorCycles
    cpu.step()
    if depth is not None:
        if not r[lab['NMI_BUSY']] and pc != lab['NMI']:
            nm = where(bl, pc, a.mems) if 0xC300 <= pc < 0xF000 else 'game'
            c[next((v for k, v in P if nm.startswith(k)), nm)] += cpu.processorCycles - c0
        if cpu.sp > depth:
            depth = None
            done += 1
print('per picture', sum(c.values()) // n)
raw = collections.Counter()
for k, v in c.most_common(14):
    print(f'{k:14} {v // n:6}')
