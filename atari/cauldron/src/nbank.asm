; ------------------------------------------------------------------
; Bank N: the NMI's work (picture flip, palettes, sound) and its set-up
; ------------------------------------------------------------------
        org $E000
nbank_start
; ------------------------------------------------------------------
; NMI work (bank R): show a finished picture (XDL, palettes), sound
; ------------------------------------------------------------------
nmi_work
        jsr nmi_ticks
        lda ready
        bmi nw_s
        tax
        lda xdl_lo,x
vx_0    sta VBX+VB_XDL0
        lda xdl_mid,x
vx_1    sta VBX+VB_XDL0+1
        lda #^V_XDL
vx_2    sta VBX+VB_XDL0+2
        stx shown
        lda #$FF
        sta ready
        jsr pal_apply
nw_s    jmp snd_frame
xdl_lo  dta <V_XDL,<(V_XDL+$80)
xdl_mid dta >V_XDL,>(V_XDL+$80)

; one C64 frame per vertical blank (NTSC: 5 in 6); the main loop's time
; owed (debt) grows by its share of a frame
nmi_ticks
        lda frame_par
        eor #1
        sta frame_par
        ; one C64 frame per vertical blank (NTSC: 5 in 6)
        lda ntsc
        beq nt_t
        ldx tick_ph
        inx
        cpx #6
        bcc nt_1
        ldx #0
nt_1    stx tick_ph
        cpx #5
        beq nt_x
nt_t    inc since_r
        lda debt                ; debt += MAIN_VC - frame (main loop owed)
        clc
        adc vc_owe
        sta debt
        lda debt+1
        adc #$FF
        sta debt+1
        bpl nt_d
        cmp #$FF                ; (no credit below -64: renders stay regular)
        bne nt_c
        lda debt
        cmp #$C0
        bcs nt_d
nt_c    lda #$C0
        sta debt
        lda #$FF
        sta debt+1
nt_d
        lda ticks
        cmp #2
        bcs nt_x               ; (far behind: the game slows down)
        inc ticks
nt_x    rts

; palettes 1-3: entries whose colour changed (pal_new vs pal_cur)
pal_apply
        ldx #3*14-1
pl_l    lda pal_new,x
        cmp pal_cur,x
        beq pl_n
        sta pal_cur,x
        stx nw_x
        jsr pal_entry
        ldx nw_x
pl_n    dex
        bpl pl_l
        rts
nw_x    dta 0
nw_c    dta 0
nw_i    dta 0

; key byte X (palette X/14, field X%14) = colour A -> its palette entries
pal_entry
        and #15
        sta nw_c
        lda key_pal,x
vp_0    sta VBX+VB_PSEL
        lda key_fld,x
        tax
        lda fld_first,x
        sta nw_i
        lda fld_cnt,x
        tax                     ; entries
pe_l    lda nw_i
vp_1    sta VBX+VB_CSEL
        ldy nw_c
        lda c64_r,y
vp_2    sta VBX+VB_CR
        lda c64_g,y
vp_3    sta VBX+VB_CG
        lda c64_b,y
vp_4    sta VBX+VB_CB
        lda nw_i
        clc
        adc #4
        sta nw_i
        dex
        bne pe_l
        rts
key_pal :14 dta 1
        :14 dta 2
        :14 dta 3
key_fld :3 dta 0,1,2,3,4,5,6,7,8,9,10,11,12,13
; fields: $D020 $D021 $D022 $D023 $D025 $D026 $D027-$D02E
fld_first dta PX_BRD,PX_BG,PX_BG1,PX_FG2,PX_SPR+1,PX_SPR+3
        dta PX_SPR+2,PX_SPR+6,PX_SPR+10,PX_SPR+14,PX_SPR+18,PX_SPR+22,PX_SPR+26,PX_SPR+30
fld_cnt dta 1,1,1,1,8,8,1,1,1,1,1,1,1,1

c64_r   dta $00,$FF,$68,$70,$6F,$58,$35,$B8,$6F,$43,$9A,$44,$6C,$9A,$6C,$95
c64_g   dta $00,$FF,$37,$A4,$3D,$8D,$28,$C7,$4F,$39,$67,$44,$6C,$D2,$5E,$95
c64_b   dta $00,$FF,$2B,$B2,$86,$43,$79,$6F,$25,$00,$59,$44,$6C,$84,$B5,$95


; set-up: fixed palette entries, the rest forced on the first picture;
; raster line table; sound
n_init  ldx #1
ni_p    stx nw_x
vi_2    stx VBX+VB_PSEL
        lda #PX_MC
vi_3    sta VBX+VB_CSEL
        ldy #0
ni_p1   lda c64_r,y
vi_4    sta VBX+VB_CR
        lda c64_g,y
vi_5    sta VBX+VB_CG
        lda c64_b,y
vi_6    sta VBX+VB_CB
        iny
        cpy #8
        bne ni_p1
        ldy #0                  ; $90-$9F
ni_p2   lda c64_r,y
vi_7    sta VBX+VB_CR
        lda c64_g,y
vi_8    sta VBX+VB_CG
        lda c64_b,y
vi_9    sta VBX+VB_CB
        iny
        cpy #16
        bne ni_p2
        ldx nw_x
        inx
        cpx #4
        bne ni_p
        ldx #3*14-1
ni_pc   lda #$FF
        sta pal_cur,x
        lda #0
        sta pal_new,x
        dex
        bpl ni_pc
        jsr pal_apply
        lda PAL                 ; GTIA: 1 = PAL, 15 = NTSC
        and #$0E
        cmp #$0E
        bne ni_pal
        lda #1
        sta ntsc
ni_pal  ldx ntsc                ; VCOUNT units per frame, the main loop's due
        lda vcf_t,x
        sta vc_frame
        lda owe_t,x
        sta vc_owe
        ldx #155
ni_v    lda ntsc
        bne ni_vn
        lda vline_pal,x
        jmp ni_v1
ni_vn   lda vline_ntsc,x
ni_v1   sta vline,x
        dex
        cpx #$FF
        bne ni_v
        lda #$FF
        sta ready
        lda #1
        sta snd_on
        jmp snd_init

vcf_t   dta 156,131
owe_t   dta <(MAIN_VC-156),<(MAIN_VC-131)

        icl 'sound.asm'
        icl '../gen/vline.asm'
        .print 'bank N end: ', *
        ert * > $FFFA
        org $FFFA
        dta a(nmi), a(rt_boot), a(irq)
