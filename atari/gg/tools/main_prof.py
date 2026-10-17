#!/usr/bin/env python3
"""Profile the main context (not the NMI) from a snapshot: main_prof.py SNAP FRAMES"""
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
a = load_snap(sys.argv[1])
n = int(sys.argv[2])
cpu, r = a.cpu, a.mem.ram
c = collections.Counter()
top = collections.Counter()
end = a.frame + n
# coarse buckets by entry points seen on the stack would be costly; use label ranges
groups = {'diff': ('diff_row', 'dr_', 'emit_cell', 'ec_', 'find_slot', 'fs_', 'fsl_', 'expand_tile', 'et_'),
          'compose': ('compose', 'cm_', 'cr_', 'rec_', 'rr_', 'rs_', 'rws', 'rows_state', 'fb_', 'fl_', 'so_',
                      'spr_', 'sl_', 'se_', 'csp', 'cg_', 'cl_', 'cp', 'fill', 'fc_', 'emit_reg', 'er_', 'pal',
                      'pu_', 'pr_', 'pp_', 'mul21', 'm21', 'slot', 'reg_', 'border', 'bc_', 'copy', 'ns_', 'nop',
                      'far_compose', 'list_get', 'lg_', 'rse', 'mc_', 'ex_', 'is_comp'),
          'wait': ('wait_line', 'wl_', 'raster', 'rt_', 'rn_', 'idle_wait', 'iw_', 'get_d01', 'g11'),
          }
while a.frame < end:
    if cpu.processorCycles >= a.next_frame:
        a.next_frame += a.frame_cycles
        a.vblank()
    pc = cpu.pc
    c0 = cpu.processorCycles
    cpu.step()
    if r[lab['NMI_BUSY']] or pc == lab['NMI']:
        continue
    d = cpu.processorCycles - c0
    if 0xC300 <= pc < 0xF000:
        name = where(bl, pc, a.mems) or '?'
        c[name] += d
        g = next((k for k, pre in groups.items() if name.startswith(pre)), 'other runtime')
    else:
        g = 'game'
    top[g] += d
tot = sum(top.values())
print('main context per frame:', {k: v // n for k, v in top.most_common()}, 'total', tot // n)
if "--other" in sys.argv:
    c = collections.Counter({k: v for k, v in c.items() if not any(k.startswith(p) for pre in groups.values() for p in pre)})
for k, v in c.most_common(20):
    print(f'{k:16} {v // n:7}')
