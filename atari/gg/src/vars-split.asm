; the sprite instance being emitted (main context, banks IDLE -> COMP)
em_y      .ds 1         ; Y register
em_x      .ds 1         ; X register bits 0-7
em_fl     .ds 1         ; bit 0 X bit 8, bit 1 multicolour, bits 6-7 VIC bank
em_ptr    .ds 1
em_col    .ds 1
em_l0     .ds 1         ; first FB line it may show on (0-200)
em_l1     .ds 1         ; FB line where it ends (0-200)
em_sx     .ds 1         ; hardware sprite
sp_lo     .ds 1         ; window address of the next sprite slot of list bl
sp_hi     .ds 1
; region colours $D022-$D026, palette slot per region, XDL segments per list
rg_c22    .ds NR
rg_c23    .ds NR
rg_c24    .ds NR
rg_c25    .ds NR
rg_c26    .ds NR
rg_pal    .ds NR
seg_n     .ds 2
seg_ln    .ds 2*NR      ; lines of segment k of list l at [l*NR+k]
seg_pl    .ds 2*NR      ; its palette (1-3)
pslot     .ds 3*6       ; colour set held by palettes 1-3 ($FF = none)
