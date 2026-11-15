; ------------------------------------------------------------------
; Phoenix for Atari XL/XE + VBXE: runtime for the translated arcade code
;
; The arcade program (tools/translate.py -> gen/game.asm) runs at $6000.
; Its video RAM writes queue tiles; once per game frame rt_frame turns the
; queue into blitter commands that redraw the tiles in the fg/bg layer
; bitmaps, then composes the scrolled background and the foreground into
; the back framebuffer, which is shown at the next vertical blank.
; ------------------------------------------------------------------
        icl 'defs.asm'

; ================================================================ game code
        org $6000
        icl '../gen/game.asm'
        .print 'game code end: ', *
        icl '../gen/sound.asm'
        icl '../gen/data.asm'
        .print 'data end: ', *
        ert * > $D000
        ert * > $D000

; ================================================================ runtime
        org $D800

; ---- start: entered from the loader with the OS off, A = VBXE page
start   sei
        cld
        ldx #$FF
        txs
        sta vbxe_hi
        lda #0
        sta NMIEN
        sta DMACTL
        sta IRQEN
        lda #$FE
        sta PORTB
        jsr vbxe_patch
        ; zero page and the arcade RAM
        lda #0
        ldx #$80
st_z    sta $00,x
        inx
        bne st_z
        tax
st_r    :16 sta ZRAM+#*$100,x
        inx
        bne st_r
        ; POKEY and GTIA
        lda #0
        sta AUDCTL
        ldx #7
st_au   sta AUDF1,x
        dex
        bpl st_au
        lda #3
        sta SKCTL
        lda #0
        sta GRACTL
        sta PRIOR
        sta COLBK
        ; PAL: one game tick in six runs without waiting (60 Hz game)
        lda #131                ; NTSC: 262 lines, a tick per frame
        sta tk_fr
        sta tk_per
        lda PAL
        and #$0E
        bne st_ntsc
        inc is_pal
        lda #156                ; PAL: 312 lines, 6 ticks in 5 frames
        sta tk_fr
        lda #130
        sta tk_per
st_ntsc
        ; tile shadows: unknown ($FF), so the first rescan draws everything
        lda #$FF
        ldx #0
st_sh   :8 sta SHADOW+#*$100,x
        inx
        bne st_sh
        ldx #31
        lda fg_blank+$FF
        beq st_rc1
        lda #0
        beq st_rc2
st_rc1  lda #26
st_rc2  sta row_cnt,x
        dex
        bpl st_rc2
        lda #1
        sta rescan
        jsr rescan_reset
        jsr gfx_init
        jsr snd_init
        lda #30
        sta pot_wait
        lda #$40                ; VBI only
        sta NMIEN
        ldy #0
        jmp z_0000

; ---- move every VBXE register operand to the detected page
vbxe_patch
        lda vbxe_hi
        cmp #>VBX
        beq vp_rts
        ldx #0
vp_1    lda vbxe_sites,x
        sta rp
        lda vbxe_sites+1,x
        sta rp+1
        ora rp
        beq vp_rts
        ldy #0
        lda vbxe_hi
        sta (rp),y
        inx
        inx
        bne vp_1
        inc vp_1+2
        inc vp_1+7
        bne vp_1
vp_rts  rts

; ------------------------------------------------------------------
; VBXE set-up: window, cleared bitmaps, list slots, XDLs, palette
; ------------------------------------------------------------------
gfx_init
        lda #0
        sta VB_VCTL
        sta VB_IRQC
        lda #MEMC_WIN
        sta VB_MEMC
        lda #BANK_LIST
        sta VB_MEMS
        ldx #5*21-1
gi_c    lda clear_list,x
        sta WIN,x
        dex
        bpl gi_c
        lda #<V_LIST
        sta VB_BLAD0
        lda #>(V_LIST&$FFFF)
        sta VB_BLAD1
        lda #V_LIST>>16
        sta VB_BLAD2
        lda #1
        sta VB_BLIT
gi_w    lda VB_BLIT
        bne gi_w
        ; fixed fields of every slot
        ldx #0
gi_s    lda slot_lo,x
        sta rp
        lda slot_hi,x
        sta rp+1
        ldy #20
        cpx #SLOT_BG
        bcs gi_s1
gi_st   lda tile_bcb,y
        sta (rp),y
        dey
        bpl gi_st
        bmi gi_sn
gi_s1   cpx #SLOT_FG
        bcs gi_s2
gi_sb   lda bg_bcb,y
        sta (rp),y
        dey
        bpl gi_sb
        bmi gi_sn
gi_s2   lda fg_bcb,y
        sta (rp),y
        dey
        bpl gi_s2
gi_sn   inx
        cpx #NSLOT
        bne gi_s
        lda #SLOT_BG+NBGB-1     ; the list ends after the background
        sta last_term
        jsr term_set
        ; XDLs
        lda #BANK_XDL
        sta VB_MEMS
        ldx #xdl_len-1
gi_x    lda xdl0,x
        sta WIN,x
        lda xdl1,x
        sta WIN+$40,x
        dex
        bpl gi_x
        ; palette 1 (overlay): arcade palette 0
        lda #0
        sta shown_pal
        sta comp_pal
        jsr load_palette
        ; show framebuffer 0 (cleared), compose into 1
        lda #<V_XDL
        sta VB_XDL0
        lda #>(V_XDL&$FFFF)
        sta VB_XDL1
        lda #V_XDL>>16
        sta VB_XDL2
        lda #1
        sta back
        sta VB_VCTL             ; XDL on
        ldy #0
        rts

; palette 1 <- arcade palette shown_pal (both are in VBXE colours 0-255)
load_palette
        lda #1
        sta VB_PSEL
        lda #0
        sta VB_CSEL
        tax
        lda shown_pal
        bne lp_1
lp_0    lda pal0_r,x
        sta VB_CR
        lda pal0_g,x
        sta VB_CG
        lda pal0_b,x
        sta VB_CB
        inx
        bne lp_0
        rts
lp_1    lda pal1_r,x
        sta VB_CR
        lda pal1_g,x
        sta VB_CG
        lda pal1_b,x
        sta VB_CB
        inx
        bne lp_1
        rts

; ------------------------------------------------------------------
; vertical blank: flip to the composed frame, inputs, sound
; ------------------------------------------------------------------
nmi     sta nmi_a
        stx nmi_x
        sty nmi_y
        cld
        sta NMIRES
        lda VCOUNT
        sta vc_vbi
        lda vtime
        clc
        adc tk_fr
        sta vtime
        bcc nm_0
        inc vtime+1
nm_0    lda comp_ready
        beq nm_1
        lda VB_BLIT
        bne nm_1                ; still drawing: show it next time
        lda #0
        sta comp_ready
        ldx back
        txa
        eor #1
        sta back
        lda xdl_lo,x
        sta VB_XDL0
        lda #>(V_XDL&$FFFF)
        sta VB_XDL1
        lda #V_XDL>>16
        sta VB_XDL2
        lda comp_pal
        cmp shown_pal
        beq nm_1
        sta shown_pal
        jsr load_palette
nm_1    inc vframe
        jsr read_input
        jsr snd_vbi
        lda nmi_a
        ldx nmi_x
        ldy nmi_y
irq     rti

; ------------------------------------------------------------------
; rt_frame: replaces the arcade's wait for the vertical blank.
; Game ticks are paced at 60 Hz by the beam position (VCOUNT units of two
; scanlines): every 130 units on PAL (5/6 of a frame), 131 on NTSC. A
; frame is composed when the back buffer is free; the VBI shows it.
; ------------------------------------------------------------------
rt_frame
rf_now  jsr now
        lda tk_now
        sec
        sbc tk_next
        lda tk_now+1
        sbc tk_next+1
        bmi rf_now              ; not yet
        ; late by more than a tick: do not try to catch up
        lda tk_now
        sec
        sbc tk_next
        tax
        lda tk_now+1
        sbc tk_next+1
        bne rf_late
        cpx tk_per
        bcc rf_ok
rf_late lda tk_now
        sta tk_next
        lda tk_now+1
        sta tk_next+1
rf_ok   lda tk_next
        clc
        adc tk_per
        sta tk_next
        bcc rf_c
        inc tk_next+1
rf_c    lda comp_ready
        bne rf_r
        jsr compose
rf_r    ldy #0
        rts

; tk_now = vtime + beam position since the last VBI
now     lda vframe
        sta tk_v
        lda VCOUNT
        sec
        sbc vc_vbi
        bcs nw_1
        adc tk_fr               ; wrapped: add the frame length
nw_1    clc
        adc vtime
        sta tk_now
        lda vtime+1
        adc #0
        sta tk_now+1
        lda vframe
        cmp tk_v
        bne now                 ; a VBI came in between
        rts

; ------------------------------------------------------------------
; compose: tiles changed since the last frame, then bg + fg -> back FB
; ------------------------------------------------------------------
compose lda #BANK_LIST
        sta VB_MEMS
        lda #TMAX
        sta slot
        jsr do_queue
        lda rescan
        beq cp_1
        jsr do_rescan
cp_1    ; background: screen lines 0-23 <- bg lines scroll+0.., 24-239 <- scroll+32..
        lda back
        clc
        adc #V_FB0>>16
        sta rt5                 ; framebuffer bits 16-18
        lda #0                  ; dst line
        sta rt0
        lda #24                 ; lines
        sta rt1
        lda scroll
        sta rt2                 ; src line
        ldx #SLOT_BG
        jsr bg_seg
        lda #24
        sta rt0
        lda #216
        sta rt1
        lda scroll
        clc
        adc #32
        sta rt2
        ldx #SLOT_BG+2
        jsr bg_seg
        ; foreground runs
        jsr term_clear
        lda #SLOT_BG+NBGB-1
        sta last_term
        lda #SLOT_FG
        sta fg_run
        ldx #0                  ; rows 0-2 -> lines 0-23
        ldy #3
        jsr fg_runs
        ldx #4                  ; rows 4-30 -> lines 24-239
        ldy #31
        jsr fg_runs
        jsr term_set
        ; start: the first used tile slot
        ldx slot
        lda slot_lo,x
        sta VB_BLAD0
        lda slot_hi,x
        sec
        sbc #>WIN
        clc
        adc #>(V_LIST&$FFFF)
        sta VB_BLAD1
        lda #V_LIST>>16
        sta VB_BLAD2
        lda #1
        sta VB_BLIT
        lda cur_pal
        sta comp_pal
        lda #1
        sta comp_ready
        rts

; one background segment in two slots (X): rt0 dst line, rt1 lines, rt2 src
bg_seg  lda #0
        sec
        sbc rt2                 ; lines before the bitmap wraps (0 = 256)
        beq bs_all
        cmp rt1
        bcs bs_all
        sta rt3                 ; first piece rt3 lines, second the rest from line 0
        jsr bs_put
        lda rt0
        clc
        adc rt3
        sta rt0
        lda rt1
        sec
        sbc rt3
        sta rt3
        lda #0
        sta rt2
        inx
        jmp bs_put
bs_all  lda rt1
        sta rt3
        jsr bs_put
        inx                     ; second piece: repeat one line of the first
        lda #1
        sta rt3
bs_put  lda slot_lo,x
        sta rp
        lda slot_hi,x
        sta rp+1
        ldy #1
        lda rt2
        sta (rp),y              ; src bits 8-15 = bg line
        ldy #7
        lda rt0
        sta (rp),y              ; dst bits 8-15 = screen line
        iny
        lda rt5
        sta (rp),y
        ldy #14
        lda rt3
        sec
        sbc #1
        sta (rp),y              ; height - 1
        rts

; fg rows X..Y-1 (consecutive on screen): one blit per run of rows that
; have visible tiles
fg_runs stx rt0
        sty rt1
fr_next ldx rt0
fr_skip cpx rt1
        bcs fr_done
        lda row_cnt,x
        bne fr_start
        inx
        bne fr_skip
fr_start stx rt2                ; first row of the run
fr_more inx
        cpx rt1
        bcs fr_end
        lda row_cnt,x
        bne fr_more
fr_end  stx rt0
        ldx fg_run
        lda slot_lo,x
        sta rp
        lda slot_hi,x
        sta rp+1
        stx last_term
        inc fg_run
        lda rt2
        asl
        asl
        asl
        ldy #1
        sta (rp),y              ; src line = row * 8
        ldx rt2
        lda row_line,x
        ldy #7
        sta (rp),y              ; dst line
        iny
        lda rt5
        sta (rp),y
        lda rt0
        sec
        sbc rt2
        asl
        asl
        asl
        sec
        sbc #1
        ldy #14
        sta (rp),y              ; height - 1
        jmp fr_next
fr_done rts

; the BCB last_term ends the list / continues it
term_set
        ldx last_term
        jsr term_ptr
        and #7
        sta (rp),y
        rts
term_clear
        ldx last_term
        jsr term_ptr
        ora #8
        sta (rp),y
        rts
term_ptr lda slot_lo,x
        sta rp
        lda slot_hi,x
        sta rp+1
        ldy #20
        lda (rp),y
        rts

; ---- queued tile addresses
do_queue
dq_loop ldx q_head
        cpx q_tail
        beq dq_done
        lda slot
        beq dq_done
        lda Q_LO,x
        sta rp
        lda Q_HI,x
        sta rp+1
        inx
        stx q_head
        jsr tile_update
        jmp dq_loop
dq_done rts

; ---- compare the arcade video RAM with the shadows (after a bank switch
; or a queue overflow); at most 3 pages per frame
do_rescan
        lda #3
        sta cnt
rs_page lda rs_hi
        sta rp+1
        and #$0B
        tax
        lda shpage,x
        sta rp2+1
        lda #0
        sta rp
        sta rp2
        ldx #0                  ; end of the page: 0 = 256, $40 for the last
        lda rs_hi
        and #3
        cmp #3
        bne rs_e
        ldx #$40
rs_e    stx rs_lim
        ldy rs_pos
rs_cmp  lda (rp),y
        cmp (rp2),y
        bne rs_diff
rs_nx   iny
        cpy rs_lim
        bne rs_cmp
        ; page done
        lda #0
        sta rs_pos
        inc rs_hi
        lda rs_hi
        cmp #$44
        bne rs_p2
        lda #$48
        sta rs_hi
rs_p2   cmp #$4C
        beq rs_end
        dec cnt
        bne rs_page
        rts
rs_end  lda #0
        sta rescan
        jsr rescan_reset
        rts
rs_diff lda slot
        beq rs_full
        sty rs_pos
        sty rp
        jsr tile_update
        ldy rs_pos
        lda rs_hi
        sta rp+1
        lda #0
        sta rp
        sta rp2                 ; tile_update moved both pointers
        jmp rs_nx
rs_full sty rs_pos              ; out of tile slots: continue next frame
        rts
rescan_reset
        lda #0
        sta rs_pos
        lda #$40
        sta rs_hi
        rts

; ---- redraw the tile at arcade address rp if it differs from its shadow
tile_update
        ldy #0
        lda (rp),y
        sta code
        lda rp+1
        and #$0B
        tax
        lda shpage,x
        sta rp2+1
        lda rp
        sta rp2
        lda code
        cmp (rp2),y
        bne tu_new
        rts
tu_new  lda (rp2),y
        sta rt3                 ; old code
        lda code
        sta (rp2),y
        dec slot
        ldx slot
        lda slot_lo,x
        sta rp3
        lda slot_hi,x
        sta rp3+1
        ; src: tiles + code * 64 (bits 16-18 = 4 are in the template)
        lda code
        and #3
        tax
        lda lo64,x
        sta (rp3),y
        iny
        lda code
        lsr
        lsr
        sta rt4
        lda rp+1
        and #8
        beq tu_fg
        lda rt4
        ora #$40                ; bg tiles at $44000
        sta (rp3),y
        ldy #8
        lda #V_BG>>16
        sta (rp3),y
        jmp tu_dst
tu_fg   lda rt4
        sta (rp3),y
        ldy #8
        lda #V_FG>>16
        sta (rp3),y
        ; count the visible tiles of each fg row
        ldx rt3
        lda fg_blank,x
        sta rt4
        ldx code
        lda fg_blank,x
        cmp rt4
        beq tu_dst
        ldx rp
        ldy row_of,x
        tax
        beq tu_inc
        lda row_cnt,y
        sec
        sbc #1
        sta row_cnt,y
        jmp tu_dst
tu_inc  lda row_cnt,y
        clc
        adc #1
        sta row_cnt,y
tu_dst  ; dst: row * 8 lines, column * 8
        ldy #7
        ldx rp
        lda row8,x
        sta (rp3),y
        lda rp+1
        and #3
        tax
        lda col_hi,x
        ldx rp
        ora col_lo,x
        tax
        lda colx,x
        ldy #6
        sta (rp3),y
        ldy #0
        rts

; ------------------------------------------------------------------
; stores from the arcade code: A = value (kept), C kept, X and N/Z lost
; ------------------------------------------------------------------
st_hl   ldy zH
        ldx ptype,y
        ldy #0
        dex
        bmi sh_r             ; ROM or unmapped: ignored
        bne sh_2
        sta (zL),y              ; RAM
sh_r    rts
sh_2    dex
        bne sh_3
sh_v    eor (zL),y              ; video RAM: queue the tile if it changes
        beq sh_s               ; (EOR keeps C)
        eor (zL),y
        sta (zL),y
        ldx q_tail
        sta sv_a
        lda zL
        sta Q_LO,x
        lda zH
        sta Q_HI,x
        inx
        txa
        eor q_head
        beq sh_o
        stx q_tail
        lda sv_a
        rts
sh_o    jmp qp_over
sh_s    eor (zL),y              ; unchanged: A back
        rts
sh_3    dex
        bne sh_io
        bit zL                  ; video RAM + variables: tiles below $40
        bmi sh_n
        bvc sh_v
sh_n    sta (zL),y
        rts
sh_io   jmp io_disp

st_de   ldy zD
        ldx ptype,y
        ldy #0
        dex
        bmi sd_r             ; ROM or unmapped: ignored
        bne sd_2
        sta (zE),y              ; RAM
sd_r    rts
sd_2    dex
        bne sd_3
sd_v    eor (zE),y              ; video RAM: queue the tile if it changes
        beq sd_s               ; (EOR keeps C)
        eor (zE),y
        sta (zE),y
        ldx q_tail
        sta sv_a
        lda zE
        sta Q_LO,x
        lda zD
        sta Q_HI,x
        inx
        txa
        eor q_head
        beq sd_o
        stx q_tail
        lda sv_a
        rts
sd_o    jmp qp_over
sd_s    eor (zE),y              ; unchanged: A back
        rts
sd_3    dex
        bne sd_io
        bit zE                  ; video RAM + variables: tiles below $40
        bmi sd_n
        bvc sd_v
sd_n    sta (zE),y
        rts
sd_io   jmp io_disp

st_bc   ldy zB
        ldx ptype,y
        ldy #0
        dex
        bmi sb_r             ; ROM or unmapped: ignored
        bne sb_2
        sta (zC),y              ; RAM
sb_r    rts
sb_2    dex
        bne sb_3
sb_v    eor (zC),y              ; video RAM: queue the tile if it changes
        beq sb_s               ; (EOR keeps C)
        eor (zC),y
        sta (zC),y
        ldx q_tail
        sta sv_a
        lda zC
        sta Q_LO,x
        lda zB
        sta Q_HI,x
        inx
        txa
        eor q_head
        beq sb_o
        stx q_tail
        lda sv_a
        rts
sb_o    jmp qp_over
sb_s    eor (zC),y              ; unchanged: A back
        rts
sb_3    dex
        bne sb_io
        bit zC                  ; video RAM + variables: tiles below $40
        bmi sb_n
        bvc sb_v
sb_n    sta (zC),y
        rts
sb_io   jmp io_disp

; queue a changed tile address (A, C kept)
; fixed addresses: X = low byte
q_push_40
        stx q_lx2
        ldx #$40
        jmp q_pfix
q_push_41
        stx q_lx2
        ldx #$41
        jmp q_pfix
q_push_42
        stx q_lx2
        ldx #$42
        jmp q_pfix
q_push_43
        stx q_lx2
        ldx #$43
        jmp q_pfix
q_push_48
        stx q_lx2
        ldx #$48
        jmp q_pfix
q_push_49
        stx q_lx2
        ldx #$49
        jmp q_pfix
q_push_4a
        stx q_lx2
        ldx #$4A
        jmp q_pfix
q_push_4b
        stx q_lx2
        ldx #$4B
q_pfix  sta sv_a
        lda q_lx2
; A = low byte, X = high byte
q_push  stx q_lx
        ldx q_tail
        sta Q_LO,x
        lda q_lx
        sta Q_HI,x
        inx
        txa
        eor q_head
        beq qp_over
        stx q_tail
        lda sv_a
        rts
qp_over lda #1                  ; full: compare everything instead
        sta rescan
        lda q_tail
        sta q_head
        jsr rescan_reset
        lda sv_a
        rts

; INC (HL) / DEC (HL): A and C kept, N/Z from the result
rt_inc_m
        sta sv_a
        lda (zL),y
        tax
        inx
        txa
        sta sv_r
        jsr st_hl
        lda sv_a
        ldx sv_r
        rts
rt_dec_m
        sta sv_a
        lda (zL),y
        tax
        dex
        txa
        sta sv_r
        jsr st_hl
        lda sv_a
        ldx sv_r
        rts

; ------------------------------------------------------------------
; I/O registers: X = 0 video, 1 scroll, 2 sound A, 3 sound B (A, C kept)
; ------------------------------------------------------------------
io_disp dex
        beq io_video
        dex
        beq io_scroll
        dex
        beq io_snda
        jmp io_sndb
io_scroll
        sta scroll
        rts
io_snda sta snd_a
        rts
io_sndb sta snd_b
        rts
; bit 0: RAM bank, bit 1: palette
io_video
        sta vreg
        php
        pha
        and #1
        cmp cur_bank
        beq iv_1
        jsr swap_banks
iv_1    lda vreg
        lsr
        and #1
        sta cur_pal
        lda $43B8               ; intermissions (even stages) stop the loop sound
        and #$0F
        cmp #$0A
        bcs iv_2
        lsr
        bcs iv_2
        lda #0
        sta s_on+3
iv_2
        ldy #0
        pla
        plp
        rts

; exchange the arcade RAM at $4000 with the other bank (VRAM $48000)
swap_banks
        lda #BANK_B1
        sta VB_MEMS
        ldy #0
sw_l
        .rept 16
        ldx ZRAM+#*$100,y
        lda WIN+#*$100,y
        sta ZRAM+#*$100,y
        txa
        sta WIN+#*$100,y
        .endr
        iny
        beq sw_d
        jmp sw_l
sw_d    lda cur_bank
        eor #1
        sta cur_bank
        lda #1
        sta rescan
        lda q_tail
        sta q_head
        jmp rescan_reset

; 8080 $0460: copy the variables both players share from the current RAM
; bank (B) to the other one (C), then switch to bank C. The arcade copies
; rows 0-3 of every fg column ($4000+n*$20, 4 bytes), $4380-$43B7 and the
; stack; the 6502 stack is not banked.
rt_switch_bank
        lda #BANK_B1
        sta VB_MEMS
        ldx #25
sbk_1   lda sbk_lo,x
        sta rp
        sta rp2
        lda sbk_hi,x
        sta rp+1
        clc
        adc #(>WIN)-(>ZRAM)
        sta rp2+1
        ldy #3
sbk_2   lda (rp),y
        sta (rp2),y
        dey
        bpl sbk_2
        dex
        bpl sbk_1
        ldx #$37
sbk_3   lda ZRAM+$380,x
        sta WIN+$380,x
        dex
        bpl sbk_3
        ldy #0
        lda zC
        jmp io_video

; ------------------------------------------------------------------
; input ports
; ------------------------------------------------------------------
rt_in0  lda inbits              ; IN0 is active low
        eor #$FF
        rts
; DSW0: 3 lives, bonus at 3000 and 30000, 1 coin 1 credit, not in vblank
rt_dsw  lda #$E0
        rts

; DAA after XOR A / LD A,B (C = AC = 0)
rt_daa0 ldx #0
        jmp rd_go
; DAA after INC L / LD A,(HL), C = 0: AC is set when L wrapped to x0
rt_daa_l
        ldx #0
        sta sv_a
        lda zL
        and #$0F
        bne rd_1
        ldx #6
rd_1    lda sv_a
rd_go   sta sv_a
        and #$0F
        cmp #10
        bcc rd_2
        ldx #6
rd_2    lda sv_a
        cmp #$9A
        bcc rd_3
        txa
        ora #$60
        tax
rd_3    stx sv_r
        lda sv_a
        clc
        adc sv_r
        rts

; an unknown jump target (the arcade code's "illegal" slots): the arcade
; board reboots there, so restart the game
rt_crash
        ldx #$FF
        txs
        cld
        jsr snd_stop
        lda #1
        sta rescan
        lda q_tail
        sta q_head
        jsr rescan_reset
        ldy #0
        jmp z_0000

; ------------------------------------------------------------------
; controls (in the VBI) -> IN0 bits, active high in inbits
;  playing: joystick left/right, fire = fire, down = shield
;  attract: fire inserts a coin, then starts a one-player game;
;  START = 1 player, SELECT = 2 players, OPTION = coin, up = 1 player
; A fire press counts in the attract mode only after a release, and a
; console key only after it was seen released once.
; ------------------------------------------------------------------
IN_COIN = $01
IN_START1 = $02
IN_START2 = $04
IN_FIRE = $10
IN_RIGHT = $20
IN_LEFT = $40
IN_SHIELD = $80

read_input
        ; second button: a 2-button joystick (Joy2B+ style) changes POT0 or
        ; POT1 from the level it had half a second after start; SPACE, SHIFT
        lda #0
        sta ri_b2
        ldx #1
ri_p    lda POT0,x
        cmp #128
        lda #0
        rol                     ; 1 = high
        ldy pot_wait
        beq ri_p2
        sta pot_rest,x          ; still settling: this is the resting level
        jmp ri_p3
ri_p2   cmp pot_rest,x
        beq ri_p3
        inc ri_b2
ri_p3   dex
        bpl ri_p
        sta POTGO
        lda pot_wait
        beq ri_pw
        dec pot_wait
ri_pw   lda SKSTAT
        and #8                  ; SHIFT
        bne ri_k0
        inc ri_b2
ri_k0   lda SKSTAT
        and #4                  ; a key is down
        bne ri_k1
        lda KBCODE
        and #$3F
        cmp #$21                ; SPACE
        bne ri_k1
        inc ri_b2
ri_k1   lda PORTA
        eor #$FF
        and #$0F
        sta ri_s                ; 1 up, 2 down, 4 left, 8 right
        lda TRIG0
        eor #1
        sta ri_f
        lda CONSOL
        eor #7
        and #7
        tax
        eor #7
        ora c_armed
        sta c_armed             ; released keys are armed
        txa
        and c_armed
        sta ri_c
        lda #0
        sta ri_m
        lda $43A2               ; game in play
        beq ri_att
        lda #0
        sta armed
        lda ri_f
        beq ri_1
        lda #IN_FIRE
        sta ri_m
ri_1    lda ri_s
        and #4
        beq ri_2
        lda ri_m
        ora #IN_LEFT
        sta ri_m
ri_2    lda ri_s
        and #8
        beq ri_3
        lda ri_m
        ora #IN_RIGHT
        sta ri_m
ri_3    lda ri_s
        and #2                  ; joystick down
        ora ri_b2               ; second button, SPACE, SHIFT
        beq ri_out
        lda ri_m
        ora #IN_SHIELD
        sta ri_m
        jmp ri_out
ri_att  lda ri_f
        bne ri_fp
        lda #1
        sta armed
        bne ri_k
ri_fp   lda armed
        beq ri_k
        lda $438F               ; credits
        bne ri_s1
        lda #IN_COIN
        sta ri_m
        bne ri_k
ri_s1   lda #IN_START1
        sta ri_m
ri_k    lda ri_c
        lsr
        bcc ri_k2
        lda ri_m
        ora #IN_START1
        sta ri_m
ri_k2   lda ri_c
        and #2
        beq ri_k3
        lda ri_m
        ora #IN_START2
        sta ri_m
ri_k3   lda ri_c
        and #4
        beq ri_k4
        lda ri_m
        ora #IN_COIN
        sta ri_m
ri_k4   lda ri_s
        lsr
        bcc ri_out
        lda ri_m
        ora #IN_START1
        sta ri_m
ri_out  lda ri_m
        sta inbits
        rts

        icl 'sound.asm'

; ------------------------------------------------------------------
; tables
; ------------------------------------------------------------------
; page types for stores: 0 ignore, 1 RAM, 2 video, 3 video + variables,
; 4 video register, 5 scroll, 6 sound A, 7 sound B
ptype   :64 dta 0
        dta 2,2,2,3, 1,1,1,1, 2,2,2,3, 1,1,1,1
        :8 dta 4
        :8 dta 5
        :8 dta 6
        :8 dta 7
        :144 dta 0
; shadow page for (address high byte & $0B)
shpage  dta >SHADOW, >SHADOW+1, >SHADOW+2, >SHADOW+3, 0,0,0,0
        dta >SHADOW+4, >SHADOW+5, >SHADOW+6, >SHADOW+7
lo64    dta 0,$40,$80,$C0
col_hi  dta 0,8,16,24
colx    :26 dta [25-#]*8
        :6 dta 0
; fg row -> screen line (row 3 and 31 are not shown)
row_line dta 0,8,16,0
        :27 dta [#+3]*8
        dta 0
row_of  :256 dta #&31
row8    :256 dta [#&31]*8
col_lo  :256 dta #>>5
slot_lo :NSLOT dta <(WIN+#*21)
slot_hi :NSLOT dta >(WIN+#*21)
sbk_lo  :26 dta <(ZRAM+#*$20)
sbk_hi  :26 dta >(ZRAM+#*$20)
xdl_lo  dta <V_XDL, <(V_XDL+$40)

; blitter command blocks
clear_list
        dta 0,0,0, 0,0, 0, <V_FG,>(V_FG&$FFFF),V_FG>>16, 0,1, 1, 255,0, 255, 0,0, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_BG,>(V_BG&$FFFF),V_BG>>16, 0,1, 1, 255,0, 255, 0,0, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_FB0,>(V_FB0&$FFFF),V_FB0>>16, 0,1, 1, 255,0, 239, 0,0, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_FB1,>(V_FB1&$FFFF),V_FB1>>16, 0,1, 1, 255,0, 239, 0,0, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_BANK1,>(V_BANK1&$FFFF),V_BANK1>>16, 0,1, 1, 255,0, 15, 0,0, 0,0,0, 0
tile_bcb dta 0,0,4, 8,0, 1, 0,0,0, 0,1, 1, 7,0, 7, $FF,0, 0,0,0, 8
bg_bcb  dta 0,0,V_BG>>16, 0,1, 1, 24,0,V_FB0>>16, 0,1, 1, 207,0, 0, $FF,0, 0,0,0, 8
fg_bcb  dta 0,0,V_FG>>16, 0,1, 1, 24,0,V_FB0>>16, 0,1, 1, 207,0, 7, $FF,0, 0,0,0, 9

; XDL: 240 lines of the 256-pixel 8-bit overlay, palette 1
xdl0    dta $62,$88, 239, <V_FB0,>(V_FB0&$FFFF),V_FB0>>16, 0,1, $10,$FF
xdl_len = * - xdl0
xdl1    dta $62,$88, 239, <V_FB1,>(V_FB1&$FFFF),V_FB1>>16, 0,1, $10,$FF

        .print 'runtime end: ', *
        ert * > SHADOW

; ---- variables (not loaded)
SHADOW  = $F000         ; 8 pages: drawn tile codes, fg then bg
row_cnt = $F800         ; visible tiles in each fg row
last_term = $F820
vbxe_hi = $F821
c_armed = $F822
ri_s    = $F824
ri_f    = $F825
ri_c    = $F826
ri_m    = $F827
q_lx2   = $F828
ri_b2   = $F829
pot_rest = $F82A
pot_wait = $F82C
s_on    = $F830         ; sound: per channel
s_lo    = $F834
s_hi    = $F838
s_slo   = $F83C
s_shi   = $F840
s_loop  = $F844
s_pri   = $F848
s_id    = $F84C
m_lo    = $F850         ; music: per voice
m_hi    = $F852
m_f     = $F854
m_c     = $F856
m_on    = $F858
m_tune  = $F859
snd_tog = $F85A
boss_cnt = $F85B
ntsc_cnt = $F85C
snd_f   = $F85D
snd_c   = $F85E

; ---- VBXE register uses (generated by build.py from the listing)
        org $F900
vbxe_sites
        icl '../gen/vbxe_sites.asm'
        dta a(0)
        ert * > $FFFA

        org $FFFA
        dta a(nmi), a(start), a(irq)
