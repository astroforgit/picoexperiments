; ------------------------------------------------------------------
; Vertical blank: show the finished frame, compose the next one with
; the blitter, read the controls, then run the game's NMI handler.
; ------------------------------------------------------------------

; ---- used inside the VBI (below $4000: MEMAC-B may cover $4000-$7FFF)
phys_page dta >NT_A,>NT_B
phys_row32 dta 0,32
phys_row128 dta 0,128
bitmask dta 1,2,4,8,16,32,64,128

; A = PRG bank for $8000-$BFFF
prg_bank
        and #7
        asl
        asl
        ora #$80
pb_mems sta VBX+VB_MEMS
        rts

nmi     pha
        txa
        pha
        tya
        pha
        ldx nmi_depth           ; remember the window of the interrupted context
        inx
        stx nmi_depth
        lda memb_sh
        sta memb_save,x
        bit NMIST
        bpl nmi_vbi
        ; display list interrupt: a game tick on PAL (6 per 5 frames)
        sta NMIRES
        lda in_vbi
        beq nmi_chain
        inc ticks_owed          ; arrived during our VBI work: run it after
        jmp nc_skip
nmi_vbi sta NMIRES
        cld
        lda in_vbi
        beq nm_go
        jmp nc_skip             ; our own work overran a frame: skip this tick
nm_go   inc in_vbi
        ldx #7
nm_s    lda ZP,x
        sta zp_save,x
        dex
        bpl nm_s
        jsr vbi_work
        ldx #7
nm_r    lda zp_save,x
        sta ZP,x
        dex
        bpl nm_r
        dec in_vbi
        ; game tick: every VBI on NTSC; on PAL the VBI of frames 0 and 4
        ; of the 5-frame cycle, the others come from display list interrupts
        lda tick_mode
        beq nmi_chain
        ldx tick_phase
        lda vbi_tick,x
        clc
        adc ticks_owed
        inx
        cpx #5
        bcc nm_ph
        ldx #0
nm_ph   stx tick_phase
        tay
        lda dl_lo,x             ; the display list of the next frame
        sta DLISTL
        lda dl_hi,x
        sta DLISTH
        tya
        beq nc_skip
        sec
        sbc #1
        sta ticks_owed
nmi_chain
        bit nmi_on
        bpl nc_skip
        ; with $0100=0 the game's NMI would only end the FC80 wait loop;
        ; wait_vblank replaces that loop
        lda $0100
        and #$C0
        bne nc_go
        lda #1                  ; $0100 = 0: wait_vblank (FC80) is waiting
        sta vbl_seen
        bne nc_skip
nc_go   lda #0                  ; the game's NMI calls services in $4000-$7FFF
        sta memb_sh
mb_7    sta VBX+VB_MEMB
        ; turn our saved Y, X, A into a return frame to nmi_tramp, so that
        ; the game's RTI comes back here first (no shared temporaries)
        tsx
        lda $0103,x             ; A
        pha
        lda $0102,x             ; X
        pha
        ldy $0101,x             ; Y
        lda #>nmi_tramp
        sta $0103,x
        lda #<nmi_tramp
        sta $0102,x
        lda #$24
        sta $0101,x
        pla
        tax
        pla
        jmp NES_NMI
nc_skip ldx nmi_depth
        lda memb_save,x
        sta memb_sh
mb_9    sta VBX+VB_MEMB
        dec nmi_depth
        pla
        tay
        pla
        tax
        pla
nc_rti  rti
vbi_tick dta 1,0,0,0,1
nmi_tramp
        pha
        txa
        pha
        ldx nmi_depth
        lda memb_save,x
        sta memb_sh
mb_8    sta VBX+VB_MEMB
        dec nmi_depth
        pla
        tax
        pla
        rti

; the game reset its stack (E0E5): no NMI frame of ours is left on it
stack_reset
        cli                     ; it left the NMI without RTI: let the keyboard IRQ in
        lda #0
        sta nmi_depth
        sta in_vbi
        sta memb_sh
mb_10   sta VBX+VB_MEMB
        rts

vbi_work
        inc vframe
        jsr read_input
        jsr sound_vbi
vw_busy lda VBX+VB_BLIT
        bne vw_drop             ; the blitter has not finished the last frame
        lda pending
        beq vw_1
        jsr flip
vw_1    jsr title_credit
        jsr compose
        lda ACTIVE_NES_BANK     ; the expander borrowed the PRG window
        jsr prg_bank
vw_exit ldx nmi_depth             ; the interrupted context's window (or none:
        lda memb_save,x         ; code in $4000-$7FFF must be visible again)
        sta memb_sh
mb_4    sta VBX+VB_MEMB
        rts
vw_drop inc drops
        jmp vw_exit

; ------------------------------------------------------------------
; FC80 replacement: wait for the next NMI, expanding tiles meanwhile.
; The game's NMI handler did nothing else in this mode ($0100 = 0).
; ------------------------------------------------------------------
wait_vblank
        stx wv_x
        sty wv_y
        pha
        lda $0100
        pha
        lda #0
        sta vbl_seen
        sta $0100
        lda PPU_CONTROL_STATE
        ora #$80
        sta PPU_CONTROL_STATE
        sta nmi_on
wv_1    cli                     ; (the game may wait with I set; only the keyboard uses IRQ)
        jsr idle_step
        lda vbl_seen
        beq wv_1
        lda PPU_CONTROL_STATE
        and #$7F
        sta PPU_CONTROL_STATE
        sta nmi_on
        ldx wv_x
        ldy wv_y
        pla
        sta $0100
        pla
        rts

; LDA $0107 / BNE: wait until the game's NMI handler clears $0107 (X, Y kept)
idle_spin
        stx wv_x
        sty wv_y
is_1    cli
        jsr idle_step
        lda $0107
        bne is_1
        ldx wv_x
        ldy wv_y
        lda $0107
        rts

; expand one tile of the current sprite or background bank, if any left
idle_step
        lda id_odone
        bne is_bg
        ldx id_ot
        inc id_ot
        bne is_o1
        inc id_odone
is_o1   lda EXPF_OBJ,x
        bne is_rts
        lda obj_bank
        cmp #32
        bcs is_rts
        sta id_bank
        ldy #MEMB_SOBJ
        jsr expand_idle
        lda obj_bank
        cmp id_bank
        bne is_rts              ; the bank changed meanwhile
        ldx id_t
        lda #1
        sta EXPF_OBJ,x
is_rts  rts
is_bg   lda id_bdone
        bne is_rts
        ldx id_bt
        inc id_bt
        bne is_b1
        inc id_bdone
is_b1   lda EXPF_BG,x
        bne is_rts
        lda bg_bank
        cmp #32
        bcs is_rts
        sta id_bank
        ldy #MEMB_SBG
        jsr expand_idle
        lda bg_bank
        cmp id_bank
        bne is_rts
        ldx id_t
        lda #1
        sta EXPF_BG,x
        rts

; like expand, but only through MEMAC-B (the game's NMI handler changes
; MEMAC-A); memb_sh holds the window so that the VBI can restore it.
; X = tile, A = CHR bank, Y = MEMAC-B value of the slot. ZP $10-$11 only.
expand_idle
        stx id_t
        sty id_memb
        sta id_b
        lda #$80 | (V_CHRIDX >> 14)
        jsr id_win
        txa
        asl
        sta $10
        lda id_b
        rol
        and #$3F
        ora #$40
        sta $11                 ; $4000 + bank*512 + tile*2
        ldy #0
        lda ($10),y
        clc
        adc #<(V_CHRRAW >> 4)
        sta id_u
        iny
        lda ($10),y
        adc #>(V_CHRRAW >> 4)
        sta id_u+1
        lsr
        lsr
        ora #$80
        jsr id_win
        lda id_u+1
        and #3
        sta $11
        lda id_u
        asl
        rol $11
        asl
        rol $11
        asl
        rol $11
        asl
        rol $11
        sta $10
        lda $11
        ora #$40
        sta $11
        ldy #15
ei_r    lda ($10),y
        sta id_buf,y
        dey
        bpl ei_r
        lda id_memb
        jsr id_win
        lda id_t
        lsr
        lsr
        ora #$40
        sta $11
        lda id_t
        and #3
        lsr
        ror
        ror
        sta $10
        ldy #0
        ldx #0
ei_w    stx id_k
        lda id_buf,x
        tax
        lda xt0,x
        sta ($10),y
        iny
        lda xt1,x
        sta ($10),y
        iny
        lda xt2,x
        sta ($10),y
        iny
        lda xt3,x
        sta ($10),y
        iny
        ldx id_k
        inx
        cpx #16
        bne ei_w
        lda #0                  ; done: window off (services live under it)
        jsr id_win
        rts
id_win  sta memb_sh             ; shadow first: an NMI restores from it
mb_5    sta VBX+VB_MEMB
        rts

; ---- show the composed frame
flip    lda #0
        sta pending
        ldx back
        lda xdl_lo,x
vf_x0   sta VBX+VB_XDL0
        lda #>(V_XDL & $FFFF)
vf_x1   sta VBX+VB_XDL0+1
        lda #V_XDL >> 16
vf_x2   sta VBX+VB_XDL0+2
        lda snap_dirty
        beq fl_1
        jsr load_palette
fl_1    lda snap_hpos
        sta HPOSP0
        lda back
        eor #1
        sta back
        rts
xdl_lo  dta <V_XDL, <(V_XDL+$40)

; overlay palette 1: $10+k shows NES palette entry k^16 (sprites, then background)
load_palette
        lda #0
        sta snap_dirty
        lda #1
lp_ps   sta VBX+VB_PSEL
        lda #$10
lp_cs   sta VBX+VB_CSEL
        ldx #0
lp_1    txa
        eor #$10
        tay
        lda PALSNAP,y
        tay
        lda nes_r,y
lp_r    sta VBX+VB_CR
        lda nes_g,y
lp_g    sta VBX+VB_CG
        lda nes_b,y
lp_b    sta VBX+VB_CB
        inx
        cpx #32
        bne lp_1
        ; the left-column mask (player 0, PF palette 0 colour 2) shows the backdrop
        lda #0
lp_ps2  sta VBX+VB_PSEL
        lda #2
lp_cs2  sta VBX+VB_CSEL
        ldy PALSNAP
        lda nes_r,y
lp_r2   sta VBX+VB_CR
        lda nes_g,y
lp_g2   sta VBX+VB_CG
        lda nes_b,y
lp_b2   sta VBX+VB_CB
        rts

; ------------------------------------------------------------------
; the title screen (nametable B, CHR bank 27): the conversion credit
; replaces "(C) 1988 TECHNOS JAPAN CORP." on row 23; the TRADEWEST logo
; (rows 20-21), "LICENSED BY" (25) and "NINTENDO OF AMERICA INC." (27)
; are removed
; ------------------------------------------------------------------
CREDIT_ROW = NT_B + 23*32
title_credit
        lda bg_bank
        cmp #TITLE_BANK
        bne tc_rts
        lda NT_B+25*32+10
        cmp #$DB                ; 'L' of LICENSED: the original screen is up
        bne tc_rts
        ldx #31
tc_mv   lda #0
        sta NT_B+20*32,x
        sta NT_B+21*32,x
        sta NT_B+25*32,x
        sta NT_B+27*32,x
        lda credit_text,x
        sta CREDIT_ROW,x
        dex
        bpl tc_mv
        lda #$FF                ; redraw rows 20-27 (nametable B = physical 1)
        ldx #31
tc_d    sta DIRTY+128+20*4,x
        dex
        bpl tc_d
        lda #1
        ldx #7
tc_r    sta ROWDIRTY+32+20,x
        dex
        bpl tc_r
        sta any_dirty
tc_rts  rts
; "ATARI VBXE CONVERSION ASTROFOR" in the title font (A = $D0)
credit_text
        dta 0
        dta $D0,$E3,$D0,$E1,$D8, 0, $E5,$D1,$E7,$D4, 0
        dta $D2,$DE,$DD,$E5,$D4,$E1,$E2,$D8,$DE,$DD, 0
        dta $D0,$E2,$E3,$E1,$DE,$D5,$DE,$E1, 0

; ------------------------------------------------------------------
; compose the frame the NES displayed last: dirty tiles into the
; nametable bitmaps, the scrolled background (and HUD), the sprites.
; ------------------------------------------------------------------
compose lda hud_on               ; HUD split this frame? A frame in which the
        beq co_nh               ; game's handler did not run (lag) keeps the
        lda #0                  ; last split; 8 frames without one end it
        sta hud_on
        sta hud_age
        lda #1
        bne co_h
co_nh   lda hud_age
        cmp #8
        bcs co_h0
        inc hud_age
        lda c_hud
        jmp co_h
co_h0   lda #0
co_h    sta c_hud
        lda hud_nt
        sta c_hudnt
        lda PPU_MASK_STATE
        sta c_mask
        lda lat_x
        sta c_x
        lda lat_y
        sta c_y
        lda lat_ctrl
        sta c_ctrl
        ldx #EXP_BUDGET
        lda c_mask
        and #$18
        bne co_1
        ldx #EXP_BUDGET_DARK    ; nothing visible: catch up on tiles
co_1    stx budget
        ldx back
        lda list_memb,x
        sta c_memb
        sta memb_sh
mb_1    sta VBX+VB_MEMB
        lda #MAXT
        sta tslot
        lda any_dirty
        beq co_2
        lda #EXP_BUDGET_DARK    ; tiles waiting: catch up quickly
        sta budget
        jsr emit_tiles
        lda any_dirty
        beq co_2
        jmp catch_up            ; still behind: keep the old picture
co_2    lda cu_flag
        beq co_2b
        lda cu_patched
        cmp back
        bne co_2b
        lda #0
        sta cu_flag
        ldx #MAXT-1
        lda slot_lo,x
        sta ZP
        lda slot_hi,x
        sta ZP+1
        ldy #20
        lda #8
        sta (ZP),y              ; the tiles continue into the background slots
co_2b   jsr emit_bg
        jsr emit_sprites
        ; start the list at the first used tile slot
        ldx tslot
        lda slot_lo,x
        clc
        adc #<(V_LIST0 - LISTCPU)
co_bl0  sta VBX+VB_BLAD
        lda slot_hi,x
        adc #>(V_LIST0 - LISTCPU)
co_bl1  sta VBX+VB_BLAD+1
        ldx back
        lda list_hi,x
co_bl2  sta VBX+VB_BLAD+2
        lda #1
co_bs   sta VBX+VB_BLIT
        ; palette and left column of this frame
        lda pal_dirty
        beq co_3
        lda #0
        sta pal_dirty
        ldx #31
co_p    lda PALSH,x
        sta PALSNAP,x
        dex
        bpl co_p
        lda #1
        sta snap_dirty
co_3    ldx #0
        lda c_mask
        and #2
        bne co_4
        ldx #64                 ; NES left 8 pixels hidden
co_4    stx snap_hpos
        lda #1
        sta pending
        rts

list_memb dta MEMB_LIST0, MEMB_LIST1
list_hi dta V_LIST0 >> 16, V_LIST1 >> 16
EXP_BUDGET = 4
EXP_BUDGET_DARK = 12

; more tiles changed than one frame can draw (a new screen): blit only the
; tiles, ending the list at the last tile slot, and do not flip
catch_up
        ldx tslot
        cpx #MAXT
        beq cu_none
        ldx #MAXT-1
        lda slot_lo,x
        sta ZP
        lda slot_hi,x
        sta ZP+1
        ldy #20
        lda #0
        sta (ZP),y              ; end of the list
        ldx back
        stx cu_patched          ; restored by the next full compose
        inx
        stx cu_flag
        ldx tslot
        lda slot_lo,x
        clc
        adc #<(V_LIST0 - LISTCPU)
cu_bl0  sta VBX+VB_BLAD
        lda slot_hi,x
        adc #>(V_LIST0 - LISTCPU)
cu_bl1  sta VBX+VB_BLAD+1
        ldx back
        lda list_hi,x
cu_bl2  sta VBX+VB_BLAD+2
        lda #1
cu_bs   sta VBX+VB_BLIT
cu_none rts

; ---- dirty tiles, written into tile slots MAXT-1 downwards
emit_tiles
        lda #0
        sta et_p
        sta et_bcol
et_np   ldx et_p
        lda phys_row32,x
        sta et_ri
        lda phys_row128,x
        sta et_di
        lda #0
        sta et_r
et_row  ldx et_ri
        lda ROWDIRTY,x
        beq et_nextrow
        lda #0
        sta et_b
et_byte lda et_di
        clc
        adc et_b
        tax
        lda DIRTY,x
        beq et_nextbyte
        sta et_v
        ldy #0
et_bit  lsr et_v
        bcc et_nb
        ; tile at column et_b*8+y
        sty et_k
        tya
        ora et_bcol
        sta et_c
        lda tslot
        beq et_full
        jsr emit_tile
        bcs et_full2            ; expansion budget exhausted
        lda et_di
        clc
        adc et_b
        tax
        ldy et_k
        lda DIRTY,x
        and notmask,y
        sta DIRTY,x
        ldy et_k
et_nb   iny
        lda et_v
        bne et_bit
et_nextbyte
        lda et_b
        clc
        adc #1
        sta et_b
        asl
        asl
        asl
        sta et_bcol
        lda et_b
        cmp #4
        bne et_byte
        lda #0
        sta et_bcol
        ldx et_ri
        sta ROWDIRTY,x
et_nextrow
        lda #0
        sta et_bcol
        lda et_di
        clc
        adc #4
        sta et_di
        inc et_ri
        inc et_r
        lda et_r
        cmp #30
        beq et_pdone
        jmp et_row
et_pdone
        inc et_p
        lda et_p
        cmp #2
        beq et_alldone
        jmp et_np
et_alldone
        lda #0
        sta any_dirty
        rts
et_full2
et_full lda #0
        sta et_bcol
        rts                     ; any_dirty stays set: continue next frame
notmask dta $FE,$FD,$FB,$F7,$EF,$DF,$BF,$7F

; emit a tile BCB for physical nametable et_p, row et_r, column et_c.
; C=1 if the tile could not be expanded this frame.
emit_tile
        ; shadow row address
        ldx et_p
        lda phys_page,x
        sta ZP+1
        lda et_r
        lsr
        lsr
        lsr
        clc
        adc ZP+1
        sta ZP+1                ; page = base + row/8
        lda et_r
        asl
        asl
        asl
        asl
        asl
        ora et_c
        sta ZP
        ldy #0
        lda (ZP),y
        sta et_tile
        ; attribute byte: base + $3C0 + (row/4)*8 + col/4
        ldx et_p
        lda phys_page,x
        clc
        adc #3
        sta ZP+3
        lda et_r
        lsr
        lsr
        asl
        asl
        asl
        sta ZP+2
        lda et_c
        lsr
        lsr
        ora ZP+2
        ora #$C0
        sta ZP+2
        lda (ZP+2),y
        sta et_attr
        lda et_r
        and #2
        asl
        sta et_sh
        lda et_c
        and #2
        ora et_sh
        tax                     ; shift 0,2,4,6
        lda et_attr
et_sh1  dex
        bmi et_sh2
        lsr
        jmp et_sh1
et_sh2  and #3
        asl
        asl
        ora #3
        sta et_and
        ; make sure the tile is expanded
        ldx et_tile
        jsr bg_ready
        bcs et_rts
        ; BCB for the next slot downwards
        dec tslot
        ldx tslot
        lda slot_lo,x
        sta ZP
        lda slot_hi,x
        sta ZP+1
        ldy #0
        lda et_tile
        and #3
        lsr
        ror
        ror
        sta (ZP),y              ; src lo = (tile&3)<<6
        iny
        lda et_tile
        lsr
        lsr
        ora #>(V_SLOT_BG & $FFFF)
        sta (ZP),y
        iny
        lda #V_SLOT_BG >> 16
        sta (ZP),y
        ldy #6
        lda et_c
        asl
        asl
        asl
        sta (ZP),y              ; dst lo = col*8
        iny
        lda et_r
        asl
        asl
        asl
        sta (ZP),y              ; dst mid = row*8
        iny
        lda et_p
        clc
        adc #V_NT_A >> 16
        sta (ZP),y
        ldy #15
        lda et_and
        sta (ZP),y
        clc
et_rts  rts

; ---- X = background tile: C=0 when expanded (expanding it if allowed)
bg_ready
        lda EXPF_BG,x
        bne br_ok
        lda budget
        beq br_no
        dec budget
        lda #1
        sta EXPF_BG,x
        lda bg_bank
        ldy #MEMB_SBG
        jsr expand
        lda c_memb
        sta memb_sh
mb_2    sta VBX+VB_MEMB
br_ok   clc
        rts
br_no   sec
        rts

; ---- Y = sprite tile not yet expanded: expand it if allowed (C=1: not now).
; X and the BCB pointer are kept.
obj_expand
        lda budget
        beq br_no
        dec budget
        lda #1
        sta EXPF_OBJ,y
        stx oe_x
        lda ZP
        pha
        lda ZP+1
        pha
        tya
        tax
        lda obj_bank
        ldy #MEMB_SOBJ
        jsr expand
        lda c_memb
        sta memb_sh
mb_3    sta VBX+VB_MEMB
        pla
        sta ZP+1
        pla
        sta ZP
        ldx oe_x
        clc
        rts

; ---- background and HUD rectangles (slots BG0..BG0+5)
emit_bg lda #0
        sta eb_n
        ; split line
        lda #240
        sta eb_s
        lda c_hud
        beq eb_1
        lda $0200               ; sprite 0 marks the split
        clc
        adc #5
        cmp #240
        bcs eb_1
        sta eb_s
eb_1    lda c_mask
        and #8
        bne eb_2
        ; background off: backdrop fill
        jsr eb_fill
        jmp eb_pad
eb_2    ; X0 = c_x + 256*(ctrl&1); split column xs = 256 - c_x
        lda c_ctrl
        and #3
        sta eb_nt
        lda c_y
        cmp #240
        bcc eb_3
        lda #0                  ; out-of-range Y: treat as 0
        sta c_y
eb_3    lda #240
        sec
        sbc c_y
        sta eb_ys               ; first row coming from the next nametable down
        ; upper strip: lines 0 .. min(ys, s)-1
        lda #0
        sta eb_y
        lda eb_ys
        cmp eb_s
        bcc eb_4
        lda eb_s
eb_4    sta eb_h
        lda c_y
        sta eb_sy
        lda eb_nt
        sta eb_cur
        jsr eb_strip
        ; lower strip: lines ys .. s-1
        lda eb_ys
        cmp eb_s
        bcs eb_hud
        sta eb_y
        lda eb_s
        sec
        sbc eb_ys
        sta eb_h
        lda #0
        sta eb_sy
        lda eb_nt
        eor #2
        sta eb_cur
        jsr eb_strip
eb_hud  lda eb_s
        cmp #240
        bcs eb_pad
        ; HUD: logical nametable c_hudnt, source rows from 200, no scroll
        sta eb_y
        lda #0
        sta eb_sx
        sta eb_dx
        sta eb_w                ; width 256
        lda c_hudnt
        sta eb_cur
        lda #200
        sta eb_sy
        lda #240
        sec
        sbc eb_s                ; HUD lines
        cmp #41
        bcc eb_h1
        ; more than 40 lines: rows 200..239, then the next nametable down
        pha
        lda #40
        sta eb_h
        jsr eb_rect
        lda eb_y
        clc
        adc #40
        sta eb_y
        lda #0
        sta eb_sy
        lda eb_cur
        eor #2
        sta eb_cur
        pla
        sec
        sbc #40
eb_h1   sta eb_h
        jsr eb_rect
eb_pad  lda eb_n
        cmp #NBG
        bcs eb_rts
        jsr eb_noop
        jmp eb_pad
eb_rts  rts

; one horizontal strip of the playfield: eb_y, eb_h, source row eb_sy,
; logical nametable eb_cur; splits at the horizontal wrap
eb_strip
        lda eb_h
        beq eb_rts
        lda c_x
        sta eb_sx
        lda #0
        sta eb_dx
        lda c_x
        beq es_full
        lda #0
        sec
        sbc c_x
        sta eb_w                ; 256 - x
        jsr eb_rect
        lda eb_w
        sta eb_dx
        lda c_x
        sta eb_w                ; remaining width = x
        lda #0
        sta eb_sx
        lda eb_cur
        eor #1
        sta eb_cur
        jsr eb_rect
        lda eb_cur
        eor #1
        sta eb_cur
        rts
es_full lda #0
        sta eb_w
        jmp eb_rect

; write a copy BCB: source logical nametable eb_cur at (eb_sx, eb_sy),
; destination (eb_dx, eb_y), width eb_w (0 = 256), height eb_h. The other
; fields of the background slots are fixed (init_list).
eb_rect jsr eb_ptr
        ldy #0
        lda eb_sx
        sta (ZP),y
        iny
        lda eb_sy
        sta (ZP),y
        iny
        lda eb_cur
        asl
        asl
        tax
        lda nt_physof+$20,x
        clc
        adc #V_NT_A >> 16
        sta (ZP),y
        ldy #6
        lda eb_dx
        sta (ZP),y
        iny
        lda eb_y
        sta (ZP),y
        iny
        lda back
        clc
        adc #V_FB0 >> 16
        sta (ZP),y
        ldy #12
        lda eb_w
        sec
        sbc #1
        sta (ZP),y              ; width-1 (0 -> 255)
        ldy #14
        lda eb_h
        sec
        sbc #1
        sta (ZP),y
        iny
        lda #$FF
        sta (ZP),y              ; AND
        iny
        lda #0
        sta (ZP),y              ; XOR
        inc eb_n
        rts

; backdrop fill of the whole frame / an empty 1x1 copy to the scratch pixel
eb_fill ldx #0
        beq eb_tpl
eb_noop ldx #eb_t_noop-eb_t_fill
eb_tpl  jsr eb_ptr
        ldy #0
eb_t1   lda eb_t_fill,x
        sta (ZP),y
        inx
        iny
        cpy #3
        bne eb_t1
        ldy #6
eb_t2   lda eb_t_fill,x
        sta (ZP),y
        inx
        iny
        cpy #9
        bne eb_t2
        ldy #12
        lda eb_t_fill,x
        sta (ZP),y
        inx
        ldy #14
eb_t3   lda eb_t_fill,x
        sta (ZP),y
        inx
        iny
        cpy #17
        bne eb_t3
        cpx #eb_t_noop-eb_t_fill+1  ; the fill goes to the back buffer
        bcs eb_t4
        lda back
        clc
        adc #V_FB0 >> 16
        ldy #8
        sta (ZP),y
eb_t4   inc eb_n
        rts
; src(3) dst(3) w-1 h-1 and xor
eb_t_fill dta 0,0,0, 0,0,0, 255, 239, 0,$20
eb_t_noop dta <V_SCRATCH,>(V_SCRATCH&$FFFF),V_SCRATCH>>16
        dta <V_SCRATCH,>(V_SCRATCH&$FFFF),V_SCRATCH>>16, 0, 0, $FF,0

eb_ptr  lda eb_n                 ; X kept
        clc
        adc #BG0
        tay
        lda slot_lo,y
        sta ZP
        lda slot_hi,y
        sta ZP+1
        rts

; ---- sprites: slot j draws OAM entry 63-j (sprite 0 ends on top). Each
; list caches what its slots draw (SC_*: y, tile, attribute, x; attribute
; bit 5 = hidden) and only the changed BCB fields are written. A hidden
; slot has AND mask 0: in blitter mode 1 it writes nothing.
emit_sprites
        ldy #0
        ldx back
        beq es_0
        ldy #64
es_0    lda slot_lo+SPR0
        sta ZP
        lda slot_hi+SPR0
        sta ZP+1
        lda c_mask
        and #$10
        bne es_go
        ; sprites off: hide every slot
        ldx #64
es_off  jsr es_hide1
        jsr es_inc
        iny
        dex
        bne es_off
        rts
es_go   ldx #252                ; OAM offset of entry 63; Y = cache index
es_loop lda $0200,x
        cmp #$EF
        bcs es_hide             ; off screen
        lda $0202,x
        and #$20
        beq es_vis              ; (bit 5: behind the background: only the HUD marker)
es_hide lda SC_A,y
        and #$20
        bne es_hn
        jsr es_hide1
es_hn   jmp es_next
es_vis  lda $0201,x
        cmp SC_T,y
        bne es_s
        lda $0202,x
        eor SC_A,y
        and #$D0                ; flips changed, or the source must be rewritten
        beq es_px
es_s    jsr es_wsrc
        bcs es_hide             ; tile not expanded yet
es_px   lda $0203,x             ; x
        cmp SC_X,y
        beq es_py
        sta SC_X,y
        sty es_cy
        ldy #6
        sta (ZP),y
        ldy es_cy
        cmp #249
        bcs es_wc
        lda SC_A,y
        and #4
        beq es_py
es_wc   jsr es_wclip
es_py   lda $0200,x             ; y
        cmp SC_Y,y
        beq es_pal
        sta SC_Y,y
        sty es_cy
        ldy #7
        clc
        adc #1
        sta (ZP),y
        ldy es_cy
        cmp #233
        bcs es_hc
        lda SC_A,y
        and #8
        beq es_pal
es_hc   jsr es_hclip
es_pal  lda $0202,x
        eor SC_A,y
        and #$23                ; palette changed or the slot was hidden
        beq es_next
        jsr es_wpal
es_next lda ZP
        clc
        adc #21
        sta ZP
        bcc es_n1
        inc ZP+1
es_n1   iny
        txa
        sec
        sbc #4
        tax
        bcc es_end
        jmp es_loop
es_end  rts
es_inc  lda ZP
        clc
        adc #21
        sta ZP
        bcc es_i1
        inc ZP+1
es_i1   rts

es_hide1
        lda SC_A,y
        ora #$20
        sta SC_A,y
        lda #0
        sty es_cy
        ldy #15
        sta (ZP),y              ; AND 0: draws nothing
        ldy es_cy
        rts

es_wpal lda $0202,x
        and #$C3
        sta es_f
        lda SC_A,y
        and #$1C                ; keep source-rewrite and clip flags
        ora es_f
        sta SC_A,y
        lda es_f
        and #3
        asl
        asl
        ora #$13
        sty es_cy
        ldy #15
        sta (ZP),y
        ldy es_cy
        rts

; width for x = SC_X (clipped at the right edge); flag bit 2
es_wclip
        lda SC_X,y
        cmp #249
        bcc ewc_7
        eor #$FF                ; 255 - x
        pha
        lda SC_A,y
        ora #4
        bne ewc_w
ewc_7   lda #7
        pha
        lda SC_A,y
        and #$FB
ewc_w   sta SC_A,y
        pla
        sty es_cy
        ldy #12
        sta (ZP),y
        ldy es_cy
        rts

; height for y = SC_Y (clipped at the bottom); flag bit 3
es_hclip
        lda SC_Y,y
        cmp #232
        bcc ehc_7
        sta es_f
        lda #238
        sec
        sbc es_f
        pha
        lda SC_A,y
        ora #8
        bne ehc_w
ehc_7   lda #7
        pha
        lda SC_A,y
        and #$F7
ehc_w   sta SC_A,y
        pla
        sty es_cy
        ldy #14
        sta (ZP),y
        ldy es_cy
        rts

; source: tile and flips (X = OAM offset, Y = cache index; both kept)
es_wsrc lda $0201,x
        sta es_t
        sty es_cy
        tay
        lda EXPF_OBJ,y
        bne ews_e
        jsr obj_expand
        ldy es_cy
        bcc ews_e
        rts                     ; C=1: no expansion budget left this frame
ews_e   ldy es_cy
        lda es_t
        sta SC_T,y
        lda SC_A,y
        and #$EF
        sta SC_A,y
        lda $0202,x
        eor SC_A,y
        and #$C0
        beq ews_1
        eor SC_A,y
        sta SC_A,y              ; new flips
        asl                     ; C = vertical flip
        php
        ldy #3
        lda #8
        bcc ews_a
        lda #$F8
ews_a   sta (ZP),y
        iny
        lda #0
        bcc ews_b
        lda #$1F
ews_b   sta (ZP),y
        iny
        plp
        ldy es_cy
        lda SC_A,y
        asl
        asl                     ; C = horizontal flip
        lda #1
        bcc ews_c
        lda #$FF
ews_c   ldy #5
        sta (ZP),y
ews_1   ldy es_cy
        lda SC_A,y
        asl                     ; C = vertical flip
        lda #0
        bcc ews_2
        lda #56
ews_2   sta es_f
        lda SC_A,y
        and #$40
        beq ews_3
        lda #7
        ora es_f
        sta es_f
ews_3   lda es_t
        and #3
        lsr
        ror
        ror
        ora es_f
        ldy #0
        sta (ZP),y
        iny
        lda es_t
        lsr
        lsr
        ora #>(V_SLOT_OBJ & $FFFF)
        sta (ZP),y
        ldy es_cy
        clc
        rts

; ------------------------------------------------------------------
; expand tile X of NES CHR bank A into the slot selected by MEMAC-B
; value Y. Uses MEMAC-A for the CHR index and raw tiles.
; ------------------------------------------------------------------
expand  sty ex_memb
        stx ex_t
        sta ex_b
        lda #MEMS_IDX
ex_ms1  sta VBX+VB_MEMS
        ; index entry at $8000 + bank*512 + tile*2
        lda ex_t
        asl
        sta ZP
        lda ex_b
        rol
        ora #$80
        sta ZP+1
        ldy #0
        lda (ZP),y
        sta ZP+2
        iny
        lda (ZP),y
        sta ZP+3                ; unique tile number
        ; raw address in 16-byte units: (V_CHRRAW >> 4) + id
        lda ZP+2
        clc
        adc #<(V_CHRRAW >> 4)
        sta ZP+2
        lda ZP+3
        adc #>(V_CHRRAW >> 4)
        sta ZP+3
        and #$FC                ; 16K bank = units >> 10
        ora #$80
ex_ms2  sta VBX+VB_MEMS
        ; offset = (units & $3FF) << 4
        lda ZP+3
        and #3
        sta ZP+1
        lda ZP+2
        asl
        rol ZP+1
        asl
        rol ZP+1
        asl
        rol ZP+1
        asl
        rol ZP+1
        sta ZP
        lda ZP+1
        ora #$80
        sta ZP+1
        ; destination: $4000 + tile*64 in the slot bank
        lda ex_memb
        sta memb_sh
ex_mb   sta VBX+VB_MEMB
        lda ex_t
        lsr
        lsr
        ora #$40
        sta ZP+3
        lda ex_t
        and #3
        lsr
        ror
        ror
        sta ZP+2
        ; 16 index bytes -> 64 pixels
        ldy #0
        sty ex_o
ex_loop ldy ex_i
        lda (ZP),y
        tax
        ldy ex_o
        lda xt0,x
        sta (ZP+2),y
        iny
        lda xt1,x
        sta (ZP+2),y
        iny
        lda xt2,x
        sta (ZP+2),y
        iny
        lda xt3,x
        sta (ZP+2),y
        iny
        sty ex_o
        inc ex_i
        lda ex_i
        cmp #16
        bne ex_loop
        lda #0
        sta ex_i
        rts

; ------------------------------------------------------------------
; controls -> NES pad bits (A B Select Start Up Down Left Right)
; Player 1: joystick 0; fire = B (punch). A (kick): SHIFT, any key, the
; second/third button of a 2-button joystick (Joy2B+, POT 0/1) and, in
; one-player games, joystick 1's fire. Both = jump.
; Player 2 (two-player games, $30 = 2): joystick 1, fire = B, POT 2/3 = A.
; START = Start (Select on the intro), SELECT = Select.
; A source counts once it has been seen released (Altirra holds a console
; key while booting; an unused POT line may read as pressed). A POT button
; is a change from the level the line had once the first scans finished.
; ------------------------------------------------------------------
read_input
        ldx #3
ri_p    lda POT0,x
        sta pot_val,x
        dex
        bpl ri_p
        sta POTGO
        lda PORTA
        and #$0F
        tax
        lda stick_tab,x
        sta ri_b
        lda PORTA
        lsr
        lsr
        lsr
        lsr
        tax
        lda stick_tab,x
        sta ri_b2
        ; player 1 fire = B
        lda TRIG0
        cmp #1                  ; C = 0 when pressed
        ldx #0
        jsr src_chk
        bcc ri_1
        lda ri_b
        ora #$40
        sta ri_b
ri_1    ; player 1 A
        lda SKSTAT
        and #8                  ; SHIFT
        cmp #1
        ldx #1
        jsr src_chk
        bcs ri_a1
        ldx #0
        jsr pot_btn
        ldx #3
        jsr src_chk
        bcs ri_a1
        ldx #1
        jsr pot_btn
        ldx #4
        jsr src_chk
        bcs ri_a1
        lda $30
        cmp #2
        beq ri_2                ; two players: joystick 1 belongs to player 2
        lda TRIG1
        cmp #1
        ldx #5
        jsr src_chk
        bcc ri_2
ri_a1   lda ri_b
        ora #$80
        sta ri_b
ri_2    ; player 2
        lda $30
        cmp #2
        beq ri_p2
        lda #0
        sta ri_b2
        beq ri_con
ri_p2   lda TRIG1
        cmp #1
        ldx #5
        jsr src_chk
        bcc ri_3
        lda ri_b2
        ora #$40
        sta ri_b2
ri_3    ldx #2
        jsr pot_btn
        ldx #6
        jsr src_chk
        bcs ri_a2
        ldx #3
        jsr pot_btn
        ldx #7
        jsr src_chk
        bcc ri_con
ri_a2   lda ri_b2
        ora #$80
        sta ri_b2
ri_con  jsr kb_read             ; W/A/S/D, punch/kick keys, RETURN
        ora ri_b
        sta ri_b
        lda CONSOL
        lsr
        bcs ri_c3
        tax
        ldy #$10                ; START = Start ...
        lda $0100
        cmp #$80
        bne ri_s
        ldy #$20                ; ... but Select on the intro, which only takes Select
ri_s    tya
        ora ri_b
        sta ri_b
        txa
ri_c3   lsr
        bcs ri_c4
        lda ri_b
        ora #$20
        sta ri_b
ri_c4   jsr title_input
        lda ri_b
        sta nes_buttons
        lda ri_b2
        sta nes_buttons2
        rts

; On the title screen and the mode menu (background CHR bank 27) the
; joystick works too: fire opens the menu (Select, which the intro wants)
; and starts the game on the menu (Start); up/down move the menu heart
; (Select). Short pulses, so that one press does one thing.
TITLE_BANK = 27
title_input
        lda PORTA
        and #$0F
        tax
        lda TRIG0
        bne ti_rel
        lda ti_fire
        bne ti_dir              ; still held
        lda #1
        sta ti_fire
        lda #3
        sta ti_pulse_f
        bne ti_dir
ti_rel  lda #0
        sta ti_fire
ti_dir  lda stick_tab,x
        and #$0C                ; up/down
        beq ti_drel
        ldx ti_ud
        bne ti_out
        sta ti_ud
        lda #3
        sta ti_pulse_s
        bne ti_out
ti_drel sta ti_ud
ti_out  lda bg_bank
        cmp #TITLE_BANK
        bne ti_clear
        lda ri_b
        and #$B0                ; no punch or walking on these screens
        sta ri_b
        lda $0100
        cmp #$80
        bne ti_fp
        lda ri_b                ; the intro only takes Select: Start -> Select
        and #$10
        beq ti_fp
        lda ri_b
        eor #$30
        sta ri_b
ti_fp
        lda ti_pulse_f
        beq ti_s
        dec ti_pulse_f
        ldx #$10                ; menu: Start
        lda $0100
        cmp #$80
        bne ti_f
        ldx #$20                ; intro: Select
ti_f    txa
        ora ri_b
        sta ri_b
ti_s    lda ti_pulse_s
        beq ti_rts
        dec ti_pulse_s
        lda $0100
        cmp #$80
        beq ti_rts              ; on the intro only fire/START open the menu
        lda ri_b
        ora #$20
        sta ri_b
ti_rts  rts
ti_clear
        lda #0
        sta ti_pulse_f
        sta ti_pulse_s
        rts

; ------------------------------------------------------------------
; keyboard, as in the Celeste port: the keyboard IRQ queues every press.
; W/A/S/D stay held until the keyboard is idle or the opposite direction
; is pressed; punch (O Z C N), kick (P X V M SPACE) and Start (RETURN)
; give a short press. SHIFT, held, is kick (read above).
; ------------------------------------------------------------------
irq     pha
        lda IRQST
        and #$40
        bne irq_x               ; not the keyboard
        lda #0                  ; acknowledge
        sta IRQEN
        lda #$40
        sta IRQEN
        txa
        pha
        ldx kb_head
        lda KBCODE
        sta kb_ring,x
        inx
        txa
        and #7
        cmp kb_tail
        beq kb_full
        sta kb_head
kb_full pla
        tax
irq_x   pla
        rti

; A = NES bits from the keyboard
kb_read
kr_ev   ldy kb_tail
        cpy kb_head
        beq kr_end
        lda kb_ring,y
        iny
        tya
        and #7
        sta kb_tail
        lda kb_ring-1,y
        and #$3F
        ldx #key_bits-key_codes-1
kr_f    cmp key_codes,x
        beq kr_found
        dex
        bpl kr_f
        bmi kr_ev
kr_found
        cpx #4
        bcs kr_act
        lda kdir                ; a direction: held
        and key_clear,x
        ora key_bits,x
        sta kdir
        jmp kr_ev
kr_act  lda key_bits,x          ; an action: a short press
        ora kpulse
        sta kpulse
        lda #4
        sta kpulse_t
        jmp kr_ev
kr_end  lda SKSTAT
        and #4
        beq kr_held
        lda #0                  ; keyboard idle: directions released
        sta kdir
kr_held lda kpulse_t
        beq kr_np
        dec kpulse_t
        lda kdir
        ora kpulse
        rts
kr_np   sta kpulse
        lda kdir
        rts
; W S A D, then punch O Z C N, kick P X V M SPACE, Start RETURN
key_codes dta $2E,$3E,$3F,$3A, $08,$17,$12,$23, $0A,$16,$10,$25,$21, $0C
key_bits  dta $08,$04,$02,$01, $40,$40,$40,$40, $80,$80,$80,$80,$80, $10
key_clear dta $FF^$04,$FF^$08,$FF^$01,$FF^$02

; C = 0: source X pressed (raw). Returns C = 1 when pressed and the source
; has been seen released before.
src_chk bcc sc_down
        lda bitmask,x           ; released: arm it
        ora src_armed
        sta src_armed
        clc
        rts
sc_down lda bitmask,x
        and src_armed
        cmp #1                  ; C = armed
        rts

; C = 0 when POT line X differs from its resting level
pot_btn lda vframe+1
        bne pt_go
        lda vframe
        cmp #30
        bcc pt_no
pt_go   lda pot_val,x
        cmp #128
        lda #0
        rol                     ; 1 = high
        ldy pot_rest,x
        bpl pt_k
        sta pot_rest,x          ; first read: the resting level
pt_no   sec
        rts
pt_k    cmp pot_rest,x
        beq pt_no
        clc
        rts

; PORTA nibble (0 = pressed: up, down, left, right) -> NES U=8 D=4 L=2 R=1
stick_tab
        dta $0f,$07,$0b,$03,$0d,$05,$09,$01,$0e,$06,$0a,$02,$0c,$04,$08,$00

sound_vbi
        rts
