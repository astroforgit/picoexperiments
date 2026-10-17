; renderer variables ($DD10-$DDFF)
bl        .ds 1         ; list/framebuffer being built for the next picture
run       .ds 1         ; list/framebuffer the blitter is drawing
pending   .ds 1         ; run is to be shown when the blitter is done
upd_cnt   .ds 2         ; per list: committed char-layer updates
spr_n     .ds 1         ; sprite blits this frame
endslot   .ds 2         ; per list: tail slot that ends the list
reg_used  .ds 2         ; per list: region slots written last time
pal_sig   .ds 6         ; d021-d026 the palette was made for
pal_cur   .ds 6         ; d021-d026 of the frame being composed
reg_dirty .ds 1         ; region blits must be rebuilt (in both lists)
rr        .ds 1         ; round-robin row of the idle diff
sp_next   .ds 1         ; idle sprite pre-expansion: next pointer
spr_want  .ds 1         ; a sprite was missing this frame (pointer)
ex_budget .ds 1         ; sprite expansions allowed in this NMI
win_top   .ds 1         ; display window (FB lines) of the frame
win_bot   .ds 1
win_l     .ds 1         ; sprite X visible range (38/40 columns)
win_r     .ds 2
col_row   .ds 1         ; colour pass: next row
gl        .ds 8         ; glyph bytes of the tile being expanded
sp_raw    .ds 63        ; raw sprite being expanded
tmp       .ds 8
        ; NMI scratch
nt        .ds 8
