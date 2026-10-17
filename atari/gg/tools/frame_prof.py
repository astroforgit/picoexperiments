#!/usr/bin/env python3
"""Main-context cycles by label over N frames, per composed picture.
frame_prof.py SNAP [N] (GNG_INPUT)"""
import collections
import os
import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from atari_snap import load_snap, parse_inputs  # noqa: E402
from atari_emu import load_labels  # noqa: E402
from nmi_prof import bank_labels, where  # noqa: E402

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
lab = load_labels(os.path.join(HERE, 'gen', 'runtime.lab'))
bl = bank_labels()
a = load_snap(sys.argv[1])
n = int(sys.argv[2]) if len(sys.argv) > 2 else 100
inp = parse_inputs(os.environ.get('GNG_INPUT', ''))
cpu, r = a.cpu, a.mem.ram
c = collections.Counter()
pics = 0
nmi = 0
for _ in range(n):
    a.set_input(**inp(a.frame))
    te = a.next_frame
    while cpu.processorCycles < te:
        pc = cpu.pc
        if pc == lab['CM_END'] and a.mems == 0xFB:
            pics += 1
        c0 = cpu.processorCycles
        cpu.step()
        d = cpu.processorCycles - c0
        if r[lab['NMI_BUSY']] or pc == lab['NMI']:
            nmi += d
            continue
        c[where(bl, pc, a.mems) if pc >= 0xC300 else 'game'] += d
    a.next_frame += a.frame_cycles
    a.vblank()
tot = sum(c.values())
print(f'{n} frames: {pics} pictures composed; per frame: NMI {nmi // n}, main {tot // n}')
p = max(pics, 1)
print('per picture:', ', '.join(f'{k} {v // p}' for k, v in c.most_common(40)))
if os.environ.get('PROF_GROUPS'):
    fam = [('diff', ('diff_row', 'dr_', 'emit_cell', 'ec_', 'find_slot', 'fs_', 'fsl_', 'is_', 'list_get', 'lg_', 'fa_',
                     'expand_tile', 'et_')),
           ('read', ('cm_read',)),
           ('sprites', ('rec_sprites', 'rs_', 'rse', 'spr_', 'so_', 'se_', 'sl_', 'sfb', 'far_emit')),
           ('regions', ('rec_region', 'rr_', 'cm_band', 'cmb', 'er_', 'emit_reg', 'fill', 'fc_', 'copy', 'cg_', 'bc_',
                        'border', 'nop', 'ns_', 'reg_', 'm21', 'mul21')),
           ('rows', ('rows_state', 'rws', 'far_rows')),
           ('palette', ('pal', 'pg_', 'pf_', 'pu_', 'rec_palette', 'rp_')),
           ('lists', ('compose', 'cl_', 'cm_', 'fb_', 'fl_', 'far_compose')),
           ('colour', ('colour_pass', 'cp_')), ('anim', ('do_anim', 'dac_', 'anim')),
           ('glue', ('co_', 'cr_', 'cc_', 'iw_', 'idle_wait', 't_idle', 'vm_', 'vbx_memb', 'mema_set', 'get_d', 'g01',
                     'g11', 'wl_', 'rt_', 'raster', 's0', 'col_mark', 'hook'))]
    g = collections.Counter()
    other = collections.Counter()
    for k, v in c.items():
        nm = next((f for f, pre in fam if k.startswith(pre)), 'game' if k == 'game' else 'other')
        g[nm] += v
        if nm == 'other':
            other[k] += v
    print('groups per picture:', {k: v // p for k, v in g.most_common()})
    print('other:', ', '.join(f'{k} {v // p}' for k, v in other.most_common(12)))
