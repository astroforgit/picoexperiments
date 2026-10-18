; renderer code and tables in RAM (shared by the banks)
show_fb clc                     ; XDL 1 at V_XDL+$100
        adc #>V_XDL
        tax
        lda #<V_XDL
gs_0    sta VBX+VB_XDL0
        txa
gs_1    sta VBX+VB_XDL0+1
        lda #^V_XDL
gs_2    sta VBX+VB_XDL0+2
        rts

; A/X/Y = list address (19 bits)
blit_start
bs_0    sta VBX+VB_BLAD
bs_1    stx VBX+VB_BLAD+1
bs_2    sty VBX+VB_BLAD+2
        lda #1
bs_3    sta VBX+VB_BLIT
        rts
blit_wait
bw_0    lda VBX+VB_BLIT
        bne blit_wait
        rts

; A/X = window address of a list: constant fields of the update slots
; (8x8 tile copies) and the sprite slots (24-wide transparent copies)
lst_ub_lo dta <(WIN+(V_LIST0&$3FFF)), <(WIN+(V_LIST1&$3FFF))   ; update slot 0
lst_ub_hi dta >(WIN+(V_LIST0&$3FFF)), >(WIN+(V_LIST1&$3FFF))
lst_w_lo  dta <(WIN+(V_LIST0&$3FFF)), <(WIN+(V_LIST1&$3FFF))
lst_w_hi  dta >(WIN+(V_LIST0&$3FFF)), >(WIN+(V_LIST1&$3FFF))
lst_v_lo  dta <V_LIST0, <V_LIST1
lst_v_mid dta >V_LIST0, >V_LIST1
lst_v_hi  dta ^V_LIST0, ^V_LIST1
fb_lo     dta <V_FB0, <V_FB1
fb_mid    dta >V_FB0, >V_FB1
fb_hi     dta ^V_FB0, ^V_FB1
MEMB_LST  = MEMB_ON|(V_LIST0>>14)
        ert (V_LIST0>>14) <> ((V_LIST1+LST_LEN)>>14)

