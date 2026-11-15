; Paged intro: 8 VRAM pages of 512 bytes, 10 fixed 32-byte lines.
; Inventory text RAM is unused while the intro modal is open.
intro_start
        lda #0
        sta intro_page
        lda #1
        sta intro_active
        lda #10
        ldx #10
        jsr win_new
        jsr intro_load
        lda #108
        jsr win_finish
        lda #0
        jmp add_modal
intro_advance
        inc intro_page
        lda intro_page
        cmp #INTRO_PAGES
        bcs intro_done
        ldx modal_top
        stx w_i
        jsr intro_load
        sec
        rts
intro_done
        lda #0
        sta intro_active
        clc
        rts
intro_load
        jsr memo_flush
        lda #$34
        jsr set_bank
        lda #0
        sta ptr
        lda intro_page
        asl
        clc
        adc #$90
        sta ptr+1
        ldy #0
intro_copy
        lda (ptr),y
        sta inv_text,y
        iny
        bne intro_copy
        inc ptr+1
intro_tail
        lda (ptr),y
        sta inv_text+256,y
        iny
        cpy #64
        bne intro_tail
        lda bcb_bank
        jsr set_bank
        ldx w_i
        lda #0
        sta wn_n,x
        sta intro_line
        mwa #inv_text sp
intro_lines
        jsr win_line
        clc
        lda sp
        adc #32
        sta sp
        bcc intro_no_carry
        inc sp+1
intro_no_carry
        inc intro_line
        lda intro_line
        cmp #10
        bne intro_lines
        rts
intro_page dta 0
intro_active dta 0
intro_line dta 0
