; bank INIT: VBXE set-up
; ------------------------------------------------------------------
; set-up
; ------------------------------------------------------------------
gfx_init
        lda #0
gi_1    sta VBX+VB_VCTL
gi_2    sta VBX+VB_IRQC
        ; clear the framebuffers, the char layer and the colour shadow
        lda #MEMB_ON|(V_LIST0>>14)
        jsr vbx_memb_a
        ldx #4*21-1
gi_c    lda clear_bcb,x
        sta WIN+(V_LIST0&$3FFF),x
        dex
        bpl gi_c
        lda #<V_LIST0
        ldx #>V_LIST0
        ldy #^V_LIST0
        jsr blit_start
        jsr blit_wait
        ; XDLs
        lda #MEMB_ON|(V_XDL>>14)
        jsr vbx_memb_a
        ldx #12
gi_x    lda xdl_data,x
        sta WIN+(V_XDL&$3FFF),x
        lda xdl_data+13,x
        sta WIN+(V_XDL&$3FFF)+$80,x
        dex
        bpl gi_x
        ; fixed fields of the update and sprite slots of both lists
        lda #MEMB_ON|(V_LIST0>>14)
        jsr vbx_memb_a
        lda #<(WIN+(V_LIST0&$3FFF))
        ldx #>(WIN+(V_LIST0&$3FFF))
        jsr init_list
        lda #<(WIN+(V_LIST1&$3FFF))
        ldx #>(WIN+(V_LIST1&$3FFF))
        jsr init_list
        lda #0
        jsr vbx_memb_a
        lda #0
        jsr show_fb
        lda #1
gi_4    sta VBX+VB_VCTL         ; XDL on
        rts

; A = framebuffer to show
init_list
        sta ZP
        stx ZP+1
        ldx #NUPD
il_u    ldy #20
il_u1   lda upd_bcb,y
        sta (ZP),y
        dey
        bpl il_u1
        jsr il_adv
        dex
        bne il_u
        ldx #NREG
il_r    ldy #20
il_r1   lda nop_bcb,y
        sta (ZP),y
        dey
        bpl il_r1
        jsr il_adv
        dex
        bne il_r
        ldx #NSPRB
il_s    ldy #20
il_s1   lda spr_bcb,y
        sta (ZP),y
        dey
        bpl il_s1
        jsr il_adv
        dex
        bne il_s
        rts
il_adv  lda ZP
        clc
        adc #21
        sta ZP
        bcc il_a1
        inc ZP+1
il_a1   rts

clear_bcb
        dta 0,0,0, 0,0, 0, <V_FB0,>V_FB0,^V_FB0, <FBW,>FBW, 1, <(FBW-1),>(FBW-1), FBH-1, 0,0, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_FB1,>V_FB1,^V_FB1, <FBW,>FBW, 1, <(FBW-1),>(FBW-1), FBH-1, 0,0, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_CL,>V_CL,^V_CL, <320,>320, 1, <319,>319, 199, 0,0, 0,0,0, 8
        dta 0,0,0, 0,0, 0, <V_COLSH,>V_COLSH,^V_COLSH, 200,0, 1, 199,0, 4, 0,$FF, 0,0,0, 0
upd_bcb dta 0,0,0, 8,0, 1, 0,0,0, <320,>320, 1, 7,0, 0, 0,0, 0,0,0, 9   ; (unused: no writes)
spr_bcb dta 0,0,0, 24,0, 1, 0,0,0, <FBW,>FBW, 1, 23,0, 20, $FF,0, 0,0,0, 9
V_SCR   = V_XDL+$100
nop_bcb dta <V_SCR,>V_SCR,^V_SCR, 0,0, 0, <V_SCR,>V_SCR,^V_SCR, 0,0, 0, 0,0, 0, $FF,0, 0,0,0, 8

; XDL: 20 blank lines, then 200 lines of the framebuffer (320 of 368 bytes)
xdl_data
        dta $24,$00, 19
        dta $62,$88, FBH-1, <[V_FB0+FBM],>[V_FB0+FBM],^[V_FB0+FBM], <FBW,>FBW, $11,$FF
        dta $24,$00, 19
        dta $62,$88, FBH-1, <[V_FB1+FBM],>[V_FB1+FBM],^[V_FB1+FBM], <FBW,>FBW, $11,$FF

