; bank IDLE: char layer upkeep (main context)

ts_cs   :NSLOT dta $FF          ; charset address high byte ($FF = free)
ts_kind :NSLOT dta 0
ts_age  :NSLOT dta 0
ts_mid  :NSLOT dta <([[V_TILE>>14]+#]<<6)
ts_hi   :NSLOT dta [[V_TILE>>14]+#]>>2
ts_memb :NSLOT dta MEMB_ON|[[V_TILE>>14]+#]
ts_exl  :NSLOT dta <(ts_exp+#*32)
ts_exh  :NSLOT dta >(ts_exp+#*32)
ts_exp  .ds NSLOT*32            ; expanded-tile bits

shd_lo  :12 dta <($0400+#*40)
        :12 dta <($1A00+#*40)
        dta <shd24
shd_hi  :12 dta >($0400+#*40)
        :12 dta >($1A00+#*40)
        dta >shd24
shd24   .ds 40
cl_lo   :25 dta <(V_CL+#*2560)
cl_mid  :25 dta >(V_CL+#*2560)
cl_hi   :25 dta ^(V_CL+#*2560)
render_init
        lda #0
        sta bl
        sta run
        sta pending
        sta upd_cnt
        sta upd_cnt+1
        sta shown
        sta pending
        sta log_w
        sta log_new
        sta rr
        sta sp_next
        sta col_row
        sta reg_used
        sta reg_used+1
        sta cs_dirty
        sta anim_dirty
        lda #$FF
        sta col_dirty
        sta spr_want
        ldx #5
ri_ps   sta pal_sig,x
        dex
        bpl ri_ps
        ldx #24
ri_r    lda #0
        sta row_off,x
        sta row_prio,x
        sta row_anim,x
        lda #1
        sta row_force,x
        sta fp_any
        lda #$FF
        sta row_dcs,x
        sta row_dmd,x
        lda #MD_BLANK
        sta row_md,x
        dex
        bpl ri_r
        lda #NUPD+NREG-1        ; no sprites yet: the last region slot ends
        sta endslot
        sta endslot+1
        lda #$FF
        sta bl
        sta ready
        sta log_busy
        jsr inval_all
        lda #0
        sta nregion
        rts

; the list bl is empty: next update slot is the last one
; everything cached is stale (after a load)
render_loaded
inval_all
        lda #2
        sta reg_dirty
        sta sc_flush
        ldx #7
        lda #$FF
ia_e    sta rse_cp,x
        dex
        bpl ia_e
        ldx #NSLOT-1
ia_t    lda #$FF
        sta ts_cs,x
        dex
        bpl ia_t
        ldx #NSPR-1
        lda #0
ia_s    sta spr_tag,x
        dex
        bne ia_s
        sta spr_tag
        ldx #24
        lda #1
ia_r    sta row_force,x
        sta fp_any
        dex
        bpl ia_r
        lda #$FF
        sta col_dirty
        lda #0
        sta sp_next
        rts

; ------------------------------------------------------------------
; main context: keep the char layer up to date (called while the game
; waits for its next frame)
; ------------------------------------------------------------------
idle_step
        lda cs_dirty
        beq is_1
        lda #0
        sta cs_dirty
        jmp inval_tiles
is_1    lda anim_dirty
        beq is_2
        jmp do_anim
is_2    lda col_dirty
        beq is_3
        jmp colour_pass
is_3    jsr list_get            ; a list to put updates and the picture in
        bcc is_l
        jmp pre_expand
is_l    lda upd_cnt,x
        cmp #NUPD-40
        bcs is_comp             ; no room for another row
        lda is_rows
        cmp #25
        bcs is_comp             ; enough rows since the last picture
        ; forced or priority rows first, then the new columns of a scroll
        ; (fp_any / edge_any: some row may be flagged; cleared before the
        ; scan, so that a row flagged meanwhile sets them again)
        lda fp_any
        beq is_e0
        lda #0
        sta fp_any
        ldx #24
is_f    lda row_force,x
        ora row_prio,x
        bne is_fy
        dex
        bpl is_f
is_e0   lda edge_any
        beq is_rr1
        lda #0
        sta edge_any
        ldx #24
is_e    lda row_edge,x
        bne is_ey
        dex
        bpl is_e
is_rr1
        ; then the picture, after at least one round-robin row
        lda log_new
        beq is_rr0
        lda is_rrd
        cmp #3                  ; three round-robin rows per picture
        bcs is_comp
is_rr0  inc is_rrd
        ldx rr
        inx
        cpx #25
        bcc is_rr
        ldx #0
is_rr   stx rr
is_row  inc is_rows
        lda #0
        sta dr_c0
        lda #40
        sta dr_c1
        lda #0
        sta row_edge,x
        jmp diff_row
is_edge pha
        lda #0
        sta row_edge,x
        pla
        ldy #0                  ; columns 0-1
        cmp #2
        beq is_e2
        ldy #38                 ; columns 38-39
is_e2   sty dr_c0
        iny
        iny
        sty dr_c1
        jmp diff_row
is_comp lda #0
        sta is_rows
        sta is_rrd
        jsr compose_main
        bcs is_x
        jmp pre_expand          ; (no new log yet)
is_x    rts
is_fy   lda #1
        sta fp_any
        jmp is_row
is_ey   pha
        lda #1
        sta edge_any
        pla
        jmp is_edge
is_rows dta 0
is_rrd  dta 0
fp_any  dta 1
edge_any dta 1

; the game rewrote charset memory: all tiles expanded from RAM charsets
; are stale
inval_tiles
        ldx #NSLOT-1
it_l    lda #$FF
        sta ts_cs,x
        dex
        bpl it_l
        ldx #24
        lda #1
it_r    sta row_force,x
        sta fp_any
        dex
        bpl it_r
        rts

; animated characters swapped: re-expand them, redraw cells that use them
do_anim lda anim_dirty
        ldx #0
        stx anim_dirty
        lsr
        bcc da_2
        pha
        lda #$FA
        jsr anim_chars
        pla
da_2    lsr
        bcc da_end
        lda #$FC
        jsr anim_chars
da_end  rts
; chars A, A+1
anim_chars
        sta da_c
        ; clear their expanded bits in every slot
        ldx #NSLOT-1
dac_s   lda ts_exl,x
        sta ZP
        lda ts_exh,x
        sta ZP+1
        lda da_c
        lsr
        lsr
        lsr
        tay
        lda da_c
        and #7
        sta da_b
        stx da_x
        tax
        lda bit8r,x
        sta da_m
        inx
        cpx #8
        bcc dac_1
        ; second char in the next byte
        lda (ZP),y
        eor #$FF
        ora da_m
        eor #$FF
        sta (ZP),y
        iny
        lda (ZP),y
        and #$FE
        sta (ZP),y
        jmp dac_n
dac_1   lda bit8r,x
        ora da_m
        eor #$FF
        and (ZP),y
        sta (ZP),y
dac_n   ldx da_x
        dex
        bpl dac_s
        ; shadow entries with these chars no longer match. row_anim stays
        ; set while the row shows any animated char (redrawn cells set it
        ; again when they are emitted)
        ldx #24
dac_r   lda row_anim,x
        beq dac_rn
        lda shd_lo,x
        sta ZP
        lda shd_hi,x
        sta ZP+1
        lda #0
        sta row_anim,x
        ldy #39
dac_c   lda (ZP),y
        cmp #$FA
        bcc dac_cn
        cmp #$FE
        bcs dac_cn
        sta row_anim,x
        sec
        sbc da_c
        cmp #2
        bcs dac_cn
        lda (ZP),y
        eor #$FF
        sta (ZP),y
        lda #1
        sta row_prio,x
        sta fp_any
dac_cn  dey
        bpl dac_c
dac_rn  dex
        bpl dac_r
        rts
da_c    dta 0
da_b    dta 0
da_x    dta 0
da_m    dta 0

; colour RAM changed: compare one row with the colour shadow; changed cells
; get their screen shadow invalidated so that the diff redraws them
colour_pass
        ldx col_row
        lda #MEMB_ON|(V_COLSH>>14)
        jsr vbx_memb_a
        lda row40_lo,x
        clc
        adc #<(WIN+(V_COLSH&$3FFF))
        sta cp_cs+1
        sta cp_cs2+1
        lda row40_hi,x
        adc #>(WIN+(V_COLSH&$3FFF))
        sta cp_cs+2
        sta cp_cs2+2
        lda row40_lo,x
        sta cp_cr+1
        sta cp_cr2+1
        lda row40_hi,x
        clc
        adc #>$D800
        sta cp_cr+2
        sta cp_cr2+2
        lda shd_lo,x
        sta ZP
        lda shd_hi,x
        sta ZP+1
        lda row_off,x
        sta cp_off
        ldy #39
cp_l
cp_cr   lda $D800,y
        and #15
cp_cs   cmp WIN,y
        beq cp_n
cp_cr2  lda $D800,y
        and #15
cp_cs2  sta WIN,y
        ; invalidate the shadow cell at ring position (y + off) mod 40
        sty cp_y
        tya
        clc
        adc cp_off
        cmp #40
        bcc cp_1
        sbc #40
cp_1    tay
        lda (ZP),y
        eor #$FF
        sta (ZP),y
        ldy cp_y
        lda #1
        sta row_prio,x
        sta fp_any
cp_n    dey
        bpl cp_l
        lda #0
        jsr vbx_memb_a
        inx
        cpx #25
        bcc cp_2
        ldx #0
        lda #0
        sta col_dirty
cp_2    stx col_row
        rts
cp_off  dta 0
cp_y    dta 0

; compare row X of the screen with its shadow and queue tile blits
diff_row
        stx dr_r
        lda #0
        sta row_prio,x
        lda row_md,x
        cmp #MD_BLANK
        bne dr_0
        sta row_dmd,x
        lda #0
        sta row_force,x
        rts
dr_0    ; drawn with a different charset or mode: redraw it all
        lda row_cs,x
        cmp row_dcs,x
        bne dr_f
        lda row_md,x
        cmp row_dmd,x
        beq dr_1
dr_f    lda row_cs,x
        sta row_dcs,x
        lda row_md,x
        sta row_dmd,x
        lda #1
        sta row_force,x
        sta fp_any
dr_1    ; screen line: copy it when it is under the window (menu screen)
        lda row_scr_lo,x
        sta dr_s+1
        lda row_scr_hi,x
        sta dr_s+2
        lda shd_lo,x
        sta ZP
        lda shd_hi,x
        sta ZP+1
        lda row40_lo,x
        sta dr_c+1
        lda row40_hi,x
        clc
        adc #>$D800
        sta dr_c+2
        lda #0                  ; the screen may be under the window
        jsr vbx_memb_a
        ldy #39
dr_cp
dr_s    lda $FFFF,y
        sta dr_line,y
        dey
        bpl dr_cp
        ; tile slots of this row's charset
        lda row_cs,x
        sta dr_cs
        lda row_md,x
        sta dr_md
        lda #$FF
        sta dr_slot             ; MC / ECM slot
        sta dr_slot+1           ; hires slot
        ; the update slots are written with the list window on
        lda #MEMB_LST
        jsr vbx_memb_a
        ldx dr_r
        lda row_off,x
        sta dr_off
        lda dr_c0
        sta dr_col
        ; whole row, not forced: the fast compare
        lda row_force,x
        bne dr_loop
        lda dr_c0
        bne dr_loop
        lda dr_c1
        cmp #40
        bne dr_loop
        jmp dr_fast
dr_loop ldy dr_col
        lda dr_line,y
        sta dr_ch
        tya
        clc
        adc dr_off
        cmp #40
        bcc dr_2
        sbc #40
dr_2    sta dr_ring
        tay
        ldx dr_r
        lda row_force,x
        bne dr_draw
        lda dr_ch
        cmp (ZP),y
        beq dr_next
dr_draw jsr emit_cell
        jcs dr_abort
        ldy dr_ring
        lda dr_ch
        sta (ZP),y
dr_next inc dr_col
        lda dr_col
        cmp dr_c1
        bcc dr_loop
        lda #0
        jsr vbx_memb_a
        ldx dr_r
        lda #0
        sta row_force,x
        rts
; fast compare of the copied line with the shadow ring: two straight
; segments (screen 0..39-off = ring off..39, screen 40-off..39 = ring
; 0..off-1); only cells that differ take the slow path
dr_fast lda #0
        sta fa_c0
        lda dr_off
        sta fa_r0
        lda #40
        sec
        sbc dr_off
        jsr dr_seg
        lda dr_off
        beq dr_fe
        lda #40
        sec
        sbc dr_off
        sta fa_c0
        lda #0
        sta fa_r0
        lda dr_off
        jsr dr_seg
dr_fe   lda #0
        jsr vbx_memb_a
        ldx dr_r
        lda #0
        sta row_force,x
        rts
; A cells from screen column fa_c0 / ring column fa_r0
dr_seg  tay
        dey
        lda #<dr_line
        clc
        adc fa_c0
        sta fa_l+1
        lda #>dr_line
        adc #0
        sta fa_l+2
        lda ZP
        clc
        adc fa_r0
        sta fa_s+1
        lda ZP+1
        adc #0
        sta fa_s+2
fa_l    lda $FFFF,y
fa_s    cmp $FFFF,y
        bne fa_mis
fa_nx   dey
        bpl fa_l
        rts
fa_mis  sty fa_y
        sta dr_ch
        tya
        clc
        adc fa_c0
        sta dr_col
        tya
        clc
        adc fa_r0
        sta dr_ring
        jsr emit_cell
        bcs fa_ab
        ldy dr_ring
        lda dr_ch
        sta (ZP),y
        ldy fa_y
        jmp fa_nx
fa_ab   pla                     ; leave dr_seg
        pla
        jmp dr_abort
fa_c0   dta 0
fa_r0   dta 0
fa_y    dta 0

dr_abort                        ; out of expansions: the row continues later
        lda #0
        jsr vbx_memb_a
        ldx dr_r
        lda #1
        sta row_prio,x
        sta fp_any
        rts
dr_c0   dta 0               ; screen columns to compare: dr_c0 .. dr_c1-1
dr_c1   dta 40
dr_r    dta 0
dr_off  dta 0
dr_col  dta 0
dr_ch   dta 0
dr_ring dta 0
dr_cs   dta 0
dr_md   dta 0
dr_slot dta 0,0
dr_kind dta 0
dr_and  dta 0
dr_line .ds 40

; queue the tile of cell (dr_r, dr_ring) = char dr_ch, colour from RAM
emit_cell
        jsr list_get
        bcs ec_full
        lda upd_cnt,x
        cmp #NUPD
        bcc ec_room
ec_full sec                     ; no list or it is full
        rts
ec_room ldy dr_col
dr_c    lda $D800,y
        and #15
        sta dr_cc
        ; kind and AND mask
        lda dr_md
        cmp #MD_MC
        bne ec_1
        lda dr_cc
        and #8
        beq ec_hi
        lda #KIND_MC
        ldx #0
        lda dr_cc
        ora #$70
        sta dr_and
        lda #KIND_MC
        jmp ec_k
ec_1    cmp #MD_ECM
        bne ec_hi
        lda dr_cc
        ora #$F0
        sta dr_and
        lda #KIND_ECM
        ldx #0
        jmp ec_k
ec_hi   lda dr_cc
        ora #$C0
        sta dr_and
        lda #KIND_HI
        ldx #1
ec_k    sta dr_kind
        lda dr_slot,x
        bpl ec_s
        stx ec_x
        jsr find_slot           ; A = slot for (dr_cs, dr_kind)
        ldx ec_x
        sta dr_slot,x
ec_s    sta ec_sl
        tax
        lda vframe
        sta ts_age,x
        ; expanded?
        lda dr_ch
        lsr
        lsr
        lsr
        tay
        lda ts_exl,x
        sta ZP+2
        lda ts_exh,x
        sta ZP+3
        lda dr_ch
        and #7
        tax
        lda bit8r,x
        and (ZP+2),y
        bne ec_have
        lda ex_left
        bne ec_ex
        sec                     ; no expansions left this time
        rts
ec_ex   dec ex_left
        lda bit8r,x
        ora (ZP+2),y
        sta (ZP+2),y
        jsr expand_tile
ec_have ; anim chars
        lda dr_ch
        cmp #$FA
        bcc ec_na
        cmp #$FE
        bcs ec_na
        ldx dr_r
        lda #1
        sta row_anim,x
ec_na   ; BCB: src = tile slot + ch*64, dst = CL row + ring*8, AND mask
        ldy #0
        lda dr_ch
        and #3
        lsr
        ror
        ror                     ; (ch & 3) << 6
        sta (upd_ptr),y
        ldx ec_sl
        lda dr_ch
        lsr
        lsr
        clc
        adc ts_mid,x
        iny
        sta (upd_ptr),y
        lda ts_hi,x
        iny
        sta (upd_ptr),y
        ldx dr_r
        lda dr_ring
        asl
        asl
        asl
        sta ec_t
        lda #0
        rol
        sta ec_t+1
        lda cl_lo,x
        clc
        adc ec_t
        ldy #6
        sta (upd_ptr),y
        lda cl_mid,x
        adc ec_t+1
        iny
        sta (upd_ptr),y
        lda cl_hi,x
        adc #0
        iny
        sta (upd_ptr),y
        lda dr_and
        ldy #15
        sta (upd_ptr),y
        ; commit
        lda upd_ptr
        sec
        sbc #21
        sta upd_ptr
        bcs ec_c
        dec upd_ptr+1
ec_c    ldx bl
        inc upd_cnt,x
        clc
        rts
dr_cc   dta 0
ec_x    dta 0
ec_sl   dta 0
ec_t    dta 0,0

; A = tile slot for charset dr_cs and kind dr_kind (allocated if needed)
find_slot
        ldx #NSLOT-1
fs_l    lda ts_cs,x
        cmp dr_cs
        bne fs_n
        lda ts_kind,x
        cmp dr_kind
        beq fs_hit
fs_n    dex
        bpl fs_l
        ; the slot used longest ago (that is not in the list being built)
        ldx #0
        ldy #NSLOT-1
        lda #0
        sta fs_best
fs_o    lda vframe
        sec
        sbc ts_age,y
        cmp fs_best
        bcc fs_on
        sta fs_best
        tya
        tax
fs_on   dey
        bpl fs_o
        lda dr_cs
        sta ts_cs,x
        lda dr_kind
        sta ts_kind,x
        ; no tile expanded yet
        lda ts_exl,x
        sta ZP+2
        lda ts_exh,x
        sta ZP+3
        ldy #31
        lda #0
fsl_c   sta (ZP+2),y
        dey
        bpl fsl_c
fs_hit  txa
        rts
fs_best dta 0

; expand char dr_ch of charset dr_cs as kind dr_kind into slot ec_sl
expand_tile
        ; glyph address: charset + (ECM: ch & 63) * 8
        lda dr_ch
        ldx dr_kind
        cpx #KIND_ECM
        bne et_0
        and #63
et_0    sta et_t
        lda #0
        sta et_a+1
        lda et_t
        asl
        rol et_a+1
        asl
        rol et_a+1
        asl
        rol et_a+1
        sta et_a
        lda et_a+1
        clc
        adc dr_cs
        sta et_g+2
        lda et_a
        sta et_g+1
        ; glyph bytes (window off: the charset may be under it)
        lda #0
        jsr vbx_memb_a
        ldx #7
et_g    lda $FFFF,x
        sta gl,x
        dex
        bpl et_g
        ; window on the slot, 64 bytes at ch*64
        ldx ec_sl
        lda ts_memb,x
        jsr vbx_memb_a
        lda dr_ch
        and #3
        lsr
        ror
        ror
        sta et_d+1
        lda dr_ch
        lsr
        lsr
        ora #>WIN
        sta et_d+2
        ; codes: off / on for hires and ECM
        lda dr_ch
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        tax
        lda ecm_bg,x
        sta et_off
        lda dr_kind
        cmp #KIND_HI
        bne et_1
        lda #$4F
        sta et_off
et_1    ldx #0
et_row  lda gl,x
        sta et_b
        lda dr_kind
        bne et_bits
        ; multicolour
        ldy #4
et_mc   lda #0
        asl et_b
        rol
        asl et_b
        rol
        stx et_x
        tax
        lda mc_tile,x
        ldx et_x
        jsr et_put
        jsr et_put
        dey
        bne et_mc
        jmp et_nr
et_bits ldy #8
et_hb   asl et_b
        lda et_off
        bcc et_h0
        lda #$8F
et_h0   jsr et_put
        dey
        bne et_hb
et_nr   inx
        cpx #8
        bne et_row
        lda #MEMB_LST
        jmp vbx_memb_a
et_put
et_d    sta WIN
        inc et_d+1
        rts
et_t    dta 0
et_a    dta 0,0
et_b    dta 0
et_x    dta 0
et_off  dta 0
mc_tile dta $4F,$5F,$6F,$7F
ecm_bg  dta $AF,$BF,$CF,$DF

; idle time with nothing else to do: expand a wanted sprite, else the next
; pointer of the VIC bank in multicolour
pre_expand
        rts

; the playfield draw ($3855) copied rows 0-18 from map position X/Y
scroll_notify
        txa
        sec
        sbc map_lo
        sta sn_d
        tya
        sbc map_hi
        sta sn_d+1
        stx map_lo
        sty map_hi
        lda sn_d+1
        bne sn_neg
        lda sn_d
        cmp #1
        bne sn_x
        ; one column left
        lda #2
        sta reg_dirty
        ldx #18
sn_l    lda row_off,x
        clc
        adc #1
        cmp #40
        bcc sn_l1
        lda #0
sn_l1   sta row_off,x
        lda #1
        sta row_edge,x
        sta edge_any
        dex
        bpl sn_l
        rts
sn_neg  cmp #$FF
        bne sn_x
        lda sn_d
        cmp #$FF
        bne sn_x
        lda #2
        sta reg_dirty
        ldx #18
snr_l    lda row_off,x
        sec
        sbc #1
        bcs snr_1
        lda #39
snr_1   sta row_off,x
        lda #2
        sta row_edge,x
        sta edge_any
        dex
        bpl snr_l
        rts
sn_x    ldx #18
        lda #1
snp_l    sta row_prio,x
        sta fp_any
        dex
        bpl snp_l
        rts
sn_d    dta 0,0


; ---- the IRQ chain log replayed (main context): regions and sprite instances
; FB line of the current raster line, clamped to 0..200, into A
fb_line lda rp_hi               ; (a write in a handler takes effect from
        bne fl_hi               ; the next line: line + 1 - 51)
        lda rp_lo
        beq fl_0                ; (line 0: the frame start state)
        sec
        sbc #50
        bcs fl_1
fl_0    lda #0
        rts
fl_1    cmp #200
        bcc fl_2
        lda #200
fl_2    rts
fl_hi   lda #200                ; lines 256+ are below the display
        rts

rec_palette
        ldx #5
rp_l    lda rvc+$21,x
        and #15
        sta pal_cur,x
        dex
        bpl rp_l
        rts

; a new region when the display registers changed
rec_region
        ldx nregion
        beq rr_new
        dex
        lda rvc+$11
        cmp rg_d011,x
        bne rr_chg
        lda rvc+$16
        cmp rg_d016,x
        bne rr_chg
        lda rvc+$18
        cmp rg_d018,x
        bne rr_chg
        lda rv_dd
        cmp rg_dd00,x
        bne rr_chg
        lda rvc+$20
        cmp rg_d020,x
        bne rr_chg
        lda rvc+$21             ; colours $D021-$D026 (the region's palette)
        cmp rg_d021,x
        bne rr_chg
        lda rvc+$22
        cmp rg_c22,x
        bne rr_chg
        lda rvc+$23
        cmp rg_c23,x
        bne rr_chg
        lda rvc+$24
        cmp rg_c24,x
        bne rr_chg
        lda rvc+$25
        cmp rg_c25,x
        bne rr_chg
        lda rvc+$26
        cmp rg_c26,x
        bne rr_chg
        rts
rr_chg  jsr fb_line
        cmp rg_l0,x
        beq rr_set              ; same line: replace
        inx
        cpx #NR
        bcs rr_full
rr_new  jsr fb_line
rr_set  sta rg_l0,x
        lda rvc+$11
        sta rg_d011,x
        lda rvc+$16
        sta rg_d016,x
        lda rvc+$18
        sta rg_d018,x
        lda rv_dd
        sta rg_dd00,x
        lda rvc+$20
        sta rg_d020,x
        lda rvc+$22
        sta rg_c22,x
        lda rvc+$23
        sta rg_c23,x
        lda rvc+$24
        sta rg_c24,x
        lda rvc+$25
        sta rg_c25,x
        lda rvc+$26
        sta rg_c26,x
        lda rvc+$21
        sta rg_d021,x
        inx
        stx nregion
rr_full rts

; screen base (C64 address high byte) of the current VIC state into A
scr_base
        lda rv_dd
        and #3
        eor #3
        asl
        asl
        asl
        asl
        asl
        asl                     ; bank * $40
        sta nt+1
        lda rvc+$18
        lsr
        lsr
        and #$3C                ; (d018 >> 4) * 4
        ora nt+1
        rts

; record the hardware sprites whose registers changed: the open instance
; of such a sprite ends at this line, a new one starts
rec_sprites
        lda rv_dd
        cmp rsl_dd
        beq rs_g
        sta rsl_dd
        lda #$FF
        bne rs_g2
rs_g    lda rvc+$10
        eor rsl_vic+$10
        sta rs_cm
        lda rvc+$15
        eor rsl_vic+$15
        ora rs_cm
        sta rs_cm
        lda rvc+$1C
        eor rsl_vic+$1C
        ora rs_cm
rs_g2   sta rs_cm
        lda rvc+$10
        sta rsl_vic+$10
        lda rvc+$15
        sta rsl_vic+$15
        lda rvc+$1C
        sta rsl_vic+$1C
        ; per sprite: position, colour, pointer
        ldx #7
        ldy #14
rs_c    lda rvc,y
        cmp rsl_vic,y
        bne rs_cx
        lda rvc+1,y
        cmp rsl_vic+1,y
        bne rs_cx
        lda rvc+$27,x
        cmp rsl_vic+$27,x
        bne rs_cx
        lda rv_ptr,x
        cmp rsl_ptr,x
        beq rs_cn
rs_cx   lda rvc,y
        sta rsl_vic,y
        lda rvc+1,y
        sta rsl_vic+1,y
        lda rvc+$27,x
        sta rsl_vic+$27,x
        lda rv_ptr,x
        sta rsl_ptr,x
        lda bit8r,x
        ora rs_cm
        sta rs_cm
rs_cn   dey
        dey
        dex
        bpl rs_c
        lda rs_cm
        bne rs_any
        rts
rs_any  lda rv_dd
        and #3
        eor #3
        ror
        ror
        ror
        and #$C0
        sta nt+2                ; VIC bank in bits 6-7
        jsr fb_line
        sta nt+1                ; this line on the FB
        ldx #7
rs_l    lda rs_cm
        and bit8r,x
        jeq rs_next
        ; the open instance of this sprite ends here
        lda op_on,x
        beq rs_op
        lda #0
        sta op_on,x
        lda nt+1
        cmp op_l0,x
        beq rs_op               ; no lines: nothing to draw
        sta em_l1
        jsr rs_emit
rs_op   lda rvc+$15
        and bit8r,x
        beq rs_next             ; disabled
        jsr rs_empty
        bcs rs_next             ; its graphics are empty
        txa
        asl
        tay
        lda rvc+1,y
        sta op_y,x
        lda rvc,y
        sta op_x,x
        lda rvc+$10
        and bit8r,x
        beq rs_f1
        lda #1
rs_f1   sta nt+5
        lda rvc+$1C
        and bit8r,x
        beq rs_f2
        lda #2
rs_f2   ora nt+5
        ora nt+2
        sta op_fl,x
        lda rsl_ptr,x
        sta op_ptr,x
        lda rvc+$27,x
        and #15
        sta op_col,x
        lda nt+1
        sta op_l0,x
        lda #1
        sta op_on,x
rs_next dex
        jpl rs_l
        rts

; emit sprite X's open instance (lines op_l0..em_l1); X kept
rs_emit lda op_y,x
        sta em_y
        lda op_x,x
        sta em_x
        lda op_fl,x
        sta em_fl
        lda op_ptr,x
        sta em_ptr
        lda op_col,x
        sta em_col
        lda op_l0,x
        sta em_l0
        stx em_sx
        jsr far_emit
        ldx em_sx
        rts
op_on   .ds 8
op_y    .ds 8
op_x    .ds 8
op_fl   .ds 8
op_ptr  .ds 8
op_col  .ds 8
op_l0   .ds 8

; C set when sprite X's pointer is cached as empty (same bank and mode)
rs_empty
        ; the same pointer, mode and bank as the last check of this sprite?
        lda rvc+$1C
        and bit8r,x
        ora nt+2                ; (bank in bits 6-7, multicolour != 0)
        sta rse_f
        lda rsl_ptr,x
        cmp rse_cp,x
        bne rse_full
        lda rse_f
        cmp rse_cf,x
        bne rse_full
        lda rse_cr,x
        lsr                     ; C = cached result
        rts
rse_full
        lda rsl_ptr,x
        sta rse_cp,x
        lda rse_f
        sta rse_cf,x
        jsr rse_chk
        lda #0
        rol
        sta rse_cr,x            ; (only an empty one is cached as such: see rse_chk)
        lsr
        rts
rse_chk
        lda rsl_ptr,x
        cmp #192
        bcc rse_d
        and #7
        ora #192
        tay
        lda rsl_ptr,x
        cmp spr_ptag-192,y
        bne rse_no
        jmp rse_s
rse_d   tay
rse_s
        lda spr_tag,y
        bpl rse_unk             ; not cached
        and #$40
        beq rse_no
        lda rvc+$1C
        and bit8r,x
        beq rse_1
        lda #$20
rse_1   sta rse_t
        lda spr_tag,y
        and #$23
        sta rse_t+1
        lda nt+2
        rol
        rol
        rol
        and #3
        ora rse_t
        cmp rse_t+1
        bne rse_no
        sec
        rts
rse_no  clc
        rts
rse_unk lda #$FF                ; unknown yet: check again next time
        sta rse_cp,x
        clc
        rts
rse_t   dta 0,0
rse_y   dta 0
rse_f   dta 0
rse_cp  .ds 8
rse_cf  .ds 8
rse_cr  .ds 8
rs_ru   dta 0
rs_cm   dta 0
rs_y    dta 0
rsl_dd  dta $FF
rsl_ptr .ds 8
rsl_vic .ds $2F



; ------------------------------------------------------------------
; frame composition (NMI)
; ------------------------------------------------------------------

; ------------------------------------------------------------------
; main context: compose a picture from the newest IRQ chain log
; ------------------------------------------------------------------
; Returns C set when it did (and the caller's step is used up).
compose_main
        lda log_new
        bne cm_1
cm_no   clc
        rts
cm_1    jsr list_get            ; a list to build into?
        bcs cm_no
        lda log_ri
        sta log_busy
        lda #0
        sta log_new
        ldx log_ri
        lda log_cnt,x
        sta cm_n
        ; replay: frame start, then each record
        lda #0
        sta nregion
        ldx #7
cm_s    sta op_on,x
        dex
        bpl cm_s
        jsr far_sbegin          ; sprite blits start (bank COMP)
        lda #0
        sta cm_i
cm_l    lda cm_i
        cmp cm_n
        beq cm_end
        jsr cm_read
        lda cm_i
        bne cm_take
        lda #$FF                ; the first record: every sprite is new
        sta rsl_dd
        jsr rec_region
        jsr cm_band
        bcs cm_f1
        jsr rec_sprites
cm_f1   jsr rec_palette
        jmp cm_nx
cm_take jsr rec_region
        jsr cm_band             ; no visible lines before the next record?
        bcc cm_t1
        lda #$FF                ; skip its sprites; the next one starts anew
        sta rsl_dd
        jmp cm_t2
cm_t1   jsr rec_sprites
cm_t2   lda rp_hi
        bne cm_nx
        lda rp_lo
        cmp #140
        bcs cm_nx
        jsr rec_palette
cm_nx   inc cm_i
        jmp cm_l
cm_end  lda #$FF
        sta log_busy
        ldx #7                  ; the open instances end with the frame
cm_c    lda op_on,x
        beq cm_cn
        lda #0
        sta op_on,x
        lda #200
        sta em_l1
        jsr rs_emit
cm_cn   dex
        bpl cm_c
        jsr far_rows
        jsr far_compose         ; bank COMP: regions, sprites, list ready
        lda #$FF
        sta bl                  ; next updates go into another list
        sec
        rts
cm_n    dta 0
cm_i    dta 0

; C set when the next record starts on the same FB line as this one
; (this record's state is never visible)
cm_band ldx cm_i
        inx
        cpx cm_n
        bcs cmb_no
        jsr fb_line
        sta cmb_a
        ; the next record's line: the first two bytes of its record
        lda cm_i
        clc
        adc #1
        lsr
        lsr
        sta ZP+7
        lda cm_i
        clc
        adc #1
        ror
        ror
        ror
        and #$C0
        sta ZP+6
        lda log_busy
        asl
        asl
        asl
        ora ZP+7
        clc
        adc #>(WIN+(V_LOG&$3FFF))
        sta ZP+7
        lda #MEMB_ON|(V_LOG>>14)
        jsr vbx_memb_a
        ldy #0
        lda (ZP+6),y
        sta cmb_l
        iny
        lda (ZP+6),y
        sta cmb_h
        lda #0
        jsr vbx_memb_a
        lda rp_lo               ; fb_line of the next record's line
        pha
        lda rp_hi
        pha
        lda cmb_l
        sta rp_lo
        lda cmb_h
        sta rp_hi
        jsr fb_line
        sta cmb_b
        pla
        sta rp_hi
        pla
        sta rp_lo
        lda cmb_a
        cmp cmb_b
        beq cmb_yes
cmb_no  clc
        rts
cmb_yes sec
        rts
cmb_a   dta 0
cmb_b   dta 0
cmb_l   dta 0
cmb_h   dta 0

; record cm_i of log log_ri into the mirror (rp_lo/hi, rvc, rv_dd, rv_ptr)
cm_read lda cm_i
        lsr
        lsr
        sta ZP+7
        lda cm_i
        ror
        ror
        ror
        and #$C0
        sta ZP+6
        lda log_busy            ; (the log being replayed)
        asl
        asl
        asl
        ora ZP+7
        clc
        adc #>(WIN+(V_LOG&$3FFF))
        sta ZP+7
        lda #MEMB_ON|(V_LOG>>14)
        jsr vbx_memb_a
        ldy #0
        lda (ZP+6),y
        sta rp_rec+0
        iny
        lda (ZP+6),y
        sta rp_rec+1
        iny
        lda (ZP+6),y
        sta rp_rec+2
        iny
        lda (ZP+6),y
        sta rp_rec+3
        iny
        lda (ZP+6),y
        sta rp_rec+4
        iny
        lda (ZP+6),y
        sta rp_rec+5
        iny
        lda (ZP+6),y
        sta rp_rec+6
        iny
        lda (ZP+6),y
        sta rp_rec+7
        iny
        lda (ZP+6),y
        sta rp_rec+8
        iny
        lda (ZP+6),y
        sta rp_rec+9
        iny
        lda (ZP+6),y
        sta rp_rec+10
        iny
        lda (ZP+6),y
        sta rp_rec+11
        iny
        lda (ZP+6),y
        sta rp_rec+12
        iny
        lda (ZP+6),y
        sta rp_rec+13
        iny
        lda (ZP+6),y
        sta rp_rec+14
        iny
        lda (ZP+6),y
        sta rp_rec+15
        iny
        lda (ZP+6),y
        sta rp_rec+16
        iny
        lda (ZP+6),y
        sta rp_rec+17
        iny
        lda (ZP+6),y
        sta rp_rec+18
        iny
        lda (ZP+6),y
        sta rp_rec+19
        iny
        lda (ZP+6),y
        sta rp_rec+20
        iny
        lda (ZP+6),y
        sta rp_rec+21
        iny
        lda (ZP+6),y
        sta rp_rec+22
        iny
        lda (ZP+6),y
        sta rp_rec+23
        iny
        lda (ZP+6),y
        sta rp_rec+24
        iny
        lda (ZP+6),y
        sta rp_rec+25
        iny
        lda (ZP+6),y
        sta rp_rec+26
        iny
        lda (ZP+6),y
        sta rp_rec+27
        iny
        lda (ZP+6),y
        sta rp_rec+28
        iny
        lda (ZP+6),y
        sta rp_rec+29
        iny
        lda (ZP+6),y
        sta rp_rec+30
        iny
        lda (ZP+6),y
        sta rp_rec+31
        iny
        lda (ZP+6),y
        sta rp_rec+32
        iny
        lda (ZP+6),y
        sta rp_rec+33
        iny
        lda (ZP+6),y
        sta rp_rec+34
        iny
        lda (ZP+6),y
        sta rp_rec+35
        iny
        lda (ZP+6),y
        sta rp_rec+36
        iny
        lda (ZP+6),y
        sta rp_rec+37
        iny
        lda (ZP+6),y
        sta rp_rec+38
        iny
        lda (ZP+6),y
        sta rp_rec+39
        iny
        lda (ZP+6),y
        sta rp_rec+40
        iny
        lda (ZP+6),y
        sta rp_rec+41
        iny
        lda (ZP+6),y
        sta rp_rec+42
        iny
        lda (ZP+6),y
        sta rp_rec+43
        iny
        lda (ZP+6),y
        sta rp_rec+44
        iny
        lda (ZP+6),y
        sta rp_rec+45
        iny
        lda (ZP+6),y
        sta rp_rec+46
        iny
        lda (ZP+6),y
        sta rp_rec+47
        iny
        lda (ZP+6),y
        sta rp_rec+48
        iny
        lda (ZP+6),y
        sta rp_rec+49
        iny
        lda (ZP+6),y
        sta rp_rec+50
        iny
        lda (ZP+6),y
        sta rp_rec+51
        iny
        lda (ZP+6),y
        sta rp_rec+52
        iny
        lda (ZP+6),y
        sta rp_rec+53
        iny
        lda (ZP+6),y
        sta rp_rec+54
        iny
        lda (ZP+6),y
        sta rp_rec+55
        iny
        lda (ZP+6),y
        sta rp_rec+56
        iny
        lda (ZP+6),y
        sta rp_rec+57
        iny
        lda #0
        jmp vbx_memb_a
rp_rec
rp_lo   .ds 1
rp_hi   .ds 1
rvc     .ds $2F
rv_dd   .ds 1
rv_ptr  .ds 8
        .ds LOGREC-58

; a list to build into: bl, or a free one (C clear), else C set
list_get
        lda bl
        bpl lg_ok
        ldx #0
        jsr lg_free
        bcc lg_take
        ldx #1
        jsr lg_free
        bcs lg_x
lg_take stx bl
        lda #0
        sta upd_cnt,x
        lda lst_ub_lo,x
        sta upd_ptr
        lda lst_ub_hi,x
        sta upd_ptr+1
lg_ok   ldx bl
        clc
lg_x    rts
; C clear when list X is not running or waiting to run (a list whose
; framebuffer is on screen may be rebuilt: the NMI starts it only when the
; other framebuffer is shown)
lg_free cpx ready
        beq lg_f1
        lda pending
        beq lg_f0
        cpx run
        beq lg_f1
lg_f0   clc
        rts
lg_f1   sec
        rts
