; ------------------------------------------------------------------
; Bank I: VBXE set-up, run once at start-up
; ------------------------------------------------------------------
        org $E000
ibank_start
; ------------------------------------------------------------------
; set-up (once, from rt_boot, the OS off, bank R mapped)
; ------------------------------------------------------------------
bank_init
        lda #0
vi_0    sta VBX+VB_VCTL
vi_1    sta VBX+VB_IRQC
        sta COLBK
        sta DMACTL
        lda #3
        sta SKCTL
        ; clear framebuffers and layer, the wake-up BCB
        lda #MEMB_ON|(V_DUMMY>>14)
        jsr i_memb
        ldx #21*4-1
bi_c    lda clear_bcbs,x
        sta WIN+(V_DUMMY&$3FFF)+$40,x
        dex
        bpl bi_c
        ldx #20
bi_d    lda dummy_bcb,x
        sta WIN+(V_DUMMY&$3FFF),x
        dex
        bpl bi_d
        lda #<(V_DUMMY+$40)
        ldx #>(V_DUMMY+$40)
        ldy #^(V_DUMMY+$40)
        jsr i_blit
        ; XDLs: one segment, palette 1
        ldx #0
bi_x    lda xdl0,x
        sta WIN+(V_XDL&$3FFF),x
        lda xdl1,x
        sta WIN+(V_XDL&$3FFF)+$80,x
        inx
        cpx #15
        bne bi_x
        ; update slots: fixed fields
        lda #LW
        jsr i_memb
        lda #<REGW
        sta ZP
        lda #>REGW
        sta ZP+1
        lda #<NUPD
        sta t0
        lda #>NUPD
        sta t1
bi_u    lda ZP
        sec
        sbc #21
        sta ZP
        bcs bi_u1
        dec ZP+1
bi_u1   ldy #20
bi_u2   lda upd_bcb,y
        sta (ZP),y
        dey
        bpl bi_u2
        lda t0
        bne bi_u3
        dec t1
bi_u3   dec t0
        lda t0
        ora t1
        bne bi_u
        jsr list_init
        lda #0
        jsr i_memb
        lda #$FF
        sta ready
        lda #0
        sta shown
        sta shift_n
        lda #<V_XDL
vi_a    sta VBX+VB_XDL0
        lda #>V_XDL
vi_b    sta VBX+VB_XDL0+1
        lda #^V_XDL
vi_e    sta VBX+VB_XDL0+2
        lda #1
vi_d    sta VBX+VB_VCTL         ; XDL on
        rts

i_memb
vi_m    sta VBX+VB_MEMB
        rts
i_blit
vi_f    sta VBX+VB_BLAD
vi_g    stx VBX+VB_BLAD+1
vi_h    sty VBX+VB_BLAD+2
        lda #1
vi_k    sta VBX+VB_BLIT
vi_l    lda VBX+VB_BLIT
        bne vi_l
        rts

dummy_bcb
        dta <(V_DUMMY+32),>(V_DUMMY+32),^(V_DUMMY+32), 0,0, 0
        dta <(V_DUMMY+33),>(V_DUMMY+33),^(V_DUMMY+33), 0,0, 0, 0,0, 0, $FF,0, 0,0,0, 0
clear_bcbs
        dta 0,0,0, 0,0, 0, <V_FB0,>V_FB0,^V_FB0, <320,>320, 1, <319,>319, 199, 0,PX_BRD, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_FB1,>V_FB1,^V_FB1, <320,>320, 1, <319,>319, 199, 0,PX_BRD, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_CL,>V_CL,^V_CL, <320,>320, 1, <319,>319, 199, 0,PX_BG, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_SCR,>V_SCR,^V_SCR, <512,>512, 1, <511,>511, 7, 0,0, 0,0,0, 0
upd_bcb dta 0,0,0, 8,0, 1, 0,0,0, <320,>320, 1, 7,0, 7, $FF,0, 0,0,0, 8
xdl0    dta $24,$00,19, $62,$88,199, <V_FB0,>V_FB0,^V_FB0, <320,>320, $11,$FF
xdl1    dta $24,$00,19, $62,$88,199, <V_FB1,>V_FB1,^V_FB1, <320,>320, $11,$FF


; constant fields of the fixed lists (lists.asm); every BCB starts as a NOP
list_init
        ldx #15                 ; (sprite patches start as NOPs)
        lda #1
li_pn   sta pat_nop,x
        dex
        bpl li_pn
        ldx #0                  ; regions
li_r    stx t0
        lda li_rlo,x
        sta ZP
        lda li_rhi,x
        sta ZP+1
        txa
        and #3
        tax
        lda li_rk,x             ; template by kind
        ldx t0
        cpx #23
        bne li_put
        lda #T_BRDL             ; (the end of run 0)
li_put  jsr li_tpl
        ldx t0
        inx
        cpx #24
        bne li_r
        ldx #0                  ; runs of sprite n
li_n    stx t0
        txa
        clc
        adc #>RUNW
        sta ZP+1
        lda #0
        sta ZP
        lda #T_PRB1
        jsr li_tpl
        lda #21
        sta ZP
        lda #T_PRB2
        jsr li_tpl
        lda #48
        sta ZP
        lda #T_PRB1
        jsr li_tpl
        lda #69
        sta ZP
        lda #T_PRB2
        jsr li_tpl
        lda #96
        sta ZP
        lda #T_DRAW
        jsr li_tpl
        lda t0                  ; draw AND: codes $FC|k -> $C0+4n+k
        asl
        asl
        ora #$C3
        ldy #15
        sta (ZP),y
        lda #117
        sta ZP
        lda #T_PA
        jsr li_tpl
        lda #138
        sta ZP
        lda #T_PB
        jsr li_tpl
        ldx t0
        inx
        cpx #8
        bne li_n
        rts

; template A (offset in li_t) -> (ZP)
li_tpl  clc
        adc #20
        tax
        ldy #20
li_tl   lda li_t,x
        sta (ZP),y
        dex
        dey
        bpl li_tl
        rts
li_rlo  :24 dta <(REGW+#*21)
li_rhi  :24 dta >(REGW+#*21)
li_rk   dta T_COPY,T_GAP,T_BRD,T_BRD
li_t
T_COPY  = *-li_t
        dta 0,0,^V_CL, <320,>320, 1, <NOPD,>NOPD,^NOPD, <320,>320, 1, 0,0, 0, $FF,0, 0,0,0, 8
T_GAP   = *-li_t
        dta 0,0,0, <320,>320, 1, <NOPD,>NOPD,^NOPD, <320,>320, 1, 0,0, 0, 0,PX_BG, 0,0,0, 8
T_BRD   = *-li_t
        dta 0,0,0, <320,>320, 1, <NOPD,>NOPD,^NOPD, <320,>320, 1, 0,0, 0, 0,PX_BRD, 0,0,0, 8
T_BRDL  = *-li_t
        dta 0,0,0, <320,>320, 1, <NOPD,>NOPD,^NOPD, <320,>320, 1, 0,0, 0, 0,PX_BRD, 0,0,0, 0
T_PRB1  = *-li_t                ; XOR $FC with detection on $80-$9F
        dta 0,0,^V_SPR, 24,0, 1, <NOPD,>NOPD,^NOPD, <320,>320, 1, 0,0, 0, $FC,0, $10,0,0, 13
T_PRB2  = *-li_t                ; the same XOR: restores
        dta 0,0,^V_SPR, 24,0, 1, <NOPD,>NOPD,^NOPD, <320,>320, 1, 0,0, 0, $FC,0, 0,0,0, 5
T_DRAW  = *-li_t
        dta 0,0,^V_SPR, 24,0, 1, <NOPD,>NOPD,^NOPD, <320,>320, 1, 0,0, 0, $C3,0, $40,0,0, 9
T_PA    = *-li_t                ; character layer foreground codes
        dta 0,0,^V_CL, <320,>320, 1, <NOPD,>NOPD,^NOPD, <320,>320, 1, 0,0, 0, $9F,0, 0,0,0, 9
T_PB    = *-li_t
        dta 0,0,^V_CL, <320,>320, 1, <NOPD,>NOPD,^NOPD, <320,>320, 1, 0,0, 0, $9F,0, 0,0,0, 1
