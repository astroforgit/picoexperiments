; ------------------------------------------------------------------
; The KERNAL calls of the options menu: CHROUT, PLOT, GETIN, SCNKEY.
; The screen editor state lives where the KERNAL keeps it: cursor row $D6,
; column $D3, reverse flag $C7, colour $0286, screen page $0288.
; ------------------------------------------------------------------
CUR_ROW = $D6
CUR_COL = $D3
REVERSE = $C7
TXT_COL = $0286
SCR_PG  = $0288

kb_chrout
        pha
        stx kc_x
        sty kc_y
        ldx #15
kc_cl   cmp kc_ctab,x           ; colour codes
        jeq kc_col
        dex
        bpl kc_cl
        cmp #$0D
        jeq kc_cr
        cmp #$8D
        jeq kc_cr
        cmp #$93
        jeq kc_clr
        cmp #$13
        jeq kc_home
        cmp #$11
        jeq kc_down
        cmp #$91
        jeq kc_up
        cmp #$1D
        jeq kc_right
        cmp #$9D
        jeq kc_left
        cmp #$12
        jeq kc_rvon
        cmp #$92
        jeq kc_rvoff
        ; printable: PETSCII -> screen code
        cmp #$20
        jcc kc_done
        cmp #$40
        bcc kc_put
        cmp #$60
        bcc kc_m40
        cmp #$80
        bcc kc_m20
        cmp #$A0
        jcc kc_done
        cmp #$C0
        bcc kc_m40
        cmp #$FF
        bcc kc_m80
        lda #$5E
        bne kc_put
kc_m80  sec
        sbc #$40
kc_m40  sec
        sbc #$20
kc_m20  sec
        sbc #$20
kc_put  ldx REVERSE
        beq kc_p1
        ora #$80
kc_p1   pha
        jsr kc_addr
        pla
        ldy CUR_COL
        sta (ZP),y
        lda ZP+1                ; colour RAM: same offset from $D800
        sec
        sbc SCR_PG
        clc
        adc #>$D800
        sta ZP+1
        lda TXT_COL
        sta (ZP),y
        lda #$FF
        sta col_dirty
        inc CUR_COL
        lda CUR_COL
        cmp #40
        bcc kc_done
        lda #0
        sta CUR_COL
        jmp kc_down
kc_col  lda kc_cval,x
        sta TXT_COL
        jmp kc_done
kc_cr   lda #0
        sta CUR_COL
        sta REVERSE
kc_down lda CUR_ROW
        cmp #24
        bcs kc_done
        inc CUR_ROW
        jmp kc_done
kc_up   lda CUR_ROW
        beq kc_done
        dec CUR_ROW
        jmp kc_done
kc_right
        inc CUR_COL
        lda CUR_COL
        cmp #40
        bcc kc_done
        lda #0
        sta CUR_COL
        jmp kc_down
kc_left lda CUR_COL
        beq kc_done
        dec CUR_COL
        jmp kc_done
kc_rvon lda #1
        sta REVERSE
        jmp kc_done
kc_rvoff
        lda #0
        sta REVERSE
        jmp kc_done
kc_clr  lda SCR_PG
        sta ZP+1
        lda #0
        sta ZP
        ldx #4
        ldy #0
        lda #$20
kc_c1   sta (ZP),y
        iny
        bne kc_c1
        inc ZP+1
        dex
        bne kc_c1
kc_home lda #0
        sta CUR_ROW
        sta CUR_COL
kc_done ldx kc_x
        ldy kc_y
        pla
        clc
        rts
; ZP/ZP+1 = screen line of the cursor row
kc_addr lda CUR_ROW
        asl
        asl
        asl
        sta ZP                  ; row*8
        lda #0
        sta ZP+1
        lda ZP
        asl
        rol ZP+1
        asl
        rol ZP+1                ; row*32
        clc
        adc ZP
        sta ZP
        lda ZP+1
        adc SCR_PG
        sta ZP+1
        rts
kc_x    dta 0
kc_y    dta 0
kc_ctab dta $90,$05,$1C,$9F,$9C,$1E,$1F,$9E,$81,$95,$96,$97,$98,$99,$9A,$9B
kc_cval dta 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

kb_plot bcs kp_get
        stx CUR_ROW
        sty CUR_COL
        clc
        rts
kp_get  ldx CUR_ROW
        ldy CUR_COL
        rts

kb_getin stx kc_x
        ldx kq
        lda #0
        sta kq
        txa
        php
        ldx kc_x
        plp
        clc
        rts

kb_scnkey
        rts
