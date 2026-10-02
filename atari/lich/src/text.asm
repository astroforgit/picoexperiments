; ------------------------------------------------------------------
; Text.  Strings are glyph numbers ending in $ff (see make_data.py).
; pr() draws through a cache: each distinct (string, colours) pair is
; rendered once by the blitter into a 256x8 slot of VRAM, glyph by
; glyph, and every later pr() of it is a single clipped blit.
; ------------------------------------------------------------------
sb_n    dta 0
txt_c1  dta 7
txt_c2  dta $ff         ; shadow colour, $ff = none

; ---------------------------------------------------------- builder
sb_clear
        lda #0
        sta sb_n
        rts

; append the string at (sp)
sb_str  ldy #0
sbs_l   lda (sp),y
        cmp #$ff
        beq sbs_d
        jsr sb_glyph
        iny
        bne sbs_l
sbs_d   rts

; append glyph A (keeps X, Y)
sb_glyph
        stx sbg_x
        ldx sb_n
        cpx #46
        bcs sbg_full
        sta strbuf,x
        inc sb_n
sbg_full
        ldx sbg_x
        rts
sbg_x   dta 0

; append A as a signed decimal number (-128..127)
sb_snum cmp #$80
        bcc sb_num
        eor #$ff
        clc
        adc #1
        pha
        lda #G_MINUS
        jsr sb_glyph
        pla
; append A as an unsigned decimal number
sb_num  sta m_r
        lda #0
        sta m_r+1
; append m_r (16 bit unsigned)
sb_num16
        ldx #0              ; digits pushed
sbn_div lda #0
        ldy #16
sbn_l   asl m_r
        rol m_r+1
        rol
        cmp #10
        bcc sbn_s
        sbc #10
        inc m_r
sbn_s   dey
        bne sbn_l
        pha
        inx
        lda m_r
        ora m_r+1
        bne sbn_div
sbn_out pla
        clc
        adc #G_0
        jsr sb_glyph
        dex
        bne sbn_out
        rts

; terminate the builder string; sp -> strbuf
sb_end  ldx sb_n
        lda #$ff
        sta strbuf,x
        mwa #strbuf sp
        rts

; copy the builder string (terminated) to (ptr2), max 47 glyphs
sb_copy jsr sb_end
        ldy #0
sbc_l   lda strbuf,y
        sta (ptr2),y
        cmp #$ff
        beq sbc_d
        iny
        cpy #47
        bne sbc_l
        lda #$ff
        sta (ptr2),y
sbc_d   rts

; ---------------------------------------------------------- tlen
; A = pixel width of the string at (sp)
tlen    ldy #0
        lda #0
        sta tl_w
tl_l    lda (sp),y
        cmp #$ff
        beq tl_d
        tax
        lda tl_w
        clc
        adc glyph_k,x
        sta tl_w
        iny
        cpy #47
        bne tl_l
tl_d    lda tl_w
        rts
tl_w    dta 0

; ---------------------------------------------------------- pr
; pr(sp, bx, by, txt_c1, txt_c2)
text_draw
        jsr tc_lookup
        lda tc_w,x
        beq td_none
        clc
        adc #3
        sta bw
        lda #0
        rol
        sta bw+1
        lda #6
        ldy txt_c2
        bmi td_1
        lda #7
td_1    sta bh
        lda #0
        sta bh+1
        sta bsrc
        sta bxor
        txa
        asl
        asl
        asl
        sta bsrc+1
        lda #^VR_TEXT
        sta bsrc+2
        lda #1
        sta bssx
        sta bmode
        lda #8
        sta bssy
        lda #$ff
        sta band
        jmp blit_fb
td_none rts

; find or render the cache slot of (sp, txt_c1, txt_c2) -> X
tc_lookup
        ; a memo by pointer saves hashing and comparing; not for the
        ; builder or the floaters (rewritten every frame).  Code that
        ; rewrites other texts calls memo_flush.
        lda sp+1
        cmp #>fl_end
        jcc tcl_full
        bne tcl_m1
        lda sp
        cmp #<fl_end
        jcc tcl_full
tcl_m1  lda sp
        sec
        sbc #<strbuf
        tax
        lda sp+1
        sbc #>strbuf
        bne tcl_m2
        cpx #64
        bcc tcl_full
tcl_m2  lda sp
        lsr
        eor sp
        eor txt_c1
        and #63
        tay
        sty tc_m
        lda mm_lo,y
        cmp sp
        bne tcl_mfull
        lda mm_hi,y
        cmp sp+1
        bne tcl_mfull
        lda mm_c1,y
        cmp txt_c1
        bne tcl_mfull
        lda mm_c2,y
        cmp txt_c2
        bne tcl_mfull
        ldx mm_slot,y
        lda mm_gen,y
        cmp tc_gen,x
        bne tcl_mfull
        lda tc_clock
        sta tc_age,x
        rts
tcl_mfull
        jsr tcl_full
        ldy tc_m
        lda sp
        sta mm_lo,y
        lda sp+1
        sta mm_hi,y
        lda txt_c1
        sta mm_c1,y
        lda txt_c2
        sta mm_c2,y
        txa
        sta mm_slot,y
        lda tc_gen,x
        sta mm_gen,y
        rts
tc_m    dta 0
memo_flush
        lda #0
        ldx #63
mf_l    sta mm_hi,x
        dex
        bpl mf_l
        rts
tcl_full
        ; hash
        ldy #0
        lda #0
tcl_h   sta tc_h
        lda (sp),y
        cmp #$ff
        beq tcl_hd
        lda tc_h
        asl
        adc #0
        eor (sp),y
        iny
        cpy #47
        bne tcl_h
        lda tc_h
tcl_hd  lda txt_c1
        jsr vcol
        sta tc_k1
        lda txt_c2
        bmi tcl_c2
        jsr vcol
tcl_c2  sta tc_k2
        ; search
        ldx #NSLOT-1
tcl_s   lda tc_hash,x
        cmp tc_h
        bne tcl_n
        lda tc_c,x
        cmp tc_k1
        bne tcl_n
        lda tc_c2,x
        cmp tc_k2
        bne tcl_n
        lda tcs_lo,x
        sta ptr2
        lda tcs_hi,x
        sta ptr2+1
        ldy #0
tcl_cmp lda (sp),y
        cmp (ptr2),y
        bne tcl_n
        cmp #$ff
        beq tcl_hit
        iny
        cpy #47
        bne tcl_cmp
tcl_hit lda tc_clock
        sta tc_age,x
        rts
tcl_n   dex
        bpl tcl_s
        ; miss: evict the least recently used slot
        ldx #NSLOT-1
        lda #0
        sta tc_best
        sta tc_bi
tcl_lru lda tc_clock
        sec
        sbc tc_age,x
        cmp tc_best
        bcc tcl_ln
        sta tc_best
        stx tc_bi
tcl_ln  dex
        bpl tcl_lru
        ldx tc_bi
        inc tc_gen,x
        lda tc_clock
        sta tc_age,x
        lda tc_h
        sta tc_hash,x
        lda tc_k1
        sta tc_c,x
        lda tc_k2
        sta tc_c2,x
        stx tc_bi
        ; copy the string and measure it
        lda tcs_lo,x
        sta ptr2
        lda tcs_hi,x
        sta ptr2+1
        ldy #0
        sty tc_wd
tcl_cp  lda (sp),y
        sta (ptr2),y
        cmp #$ff
        beq tcl_cpd
        tax
        lda tc_wd
        clc
        adc glyph_k,x
        sta tc_wd
        iny
        cpy #47
        bne tcl_cp
        lda #$ff
        sta (ptr2),y
tcl_cpd ldx tc_bi
        lda tc_wd
        sta tc_w,x
        beq tcl_ret
        ; render: clear, shadow pass, colour pass
        jsr tc_clear
        lda tc_k2
        bmi tcl_nos
        sta tc_col
        lda #1
        sta tc_row
        jsr tc_pass
tcl_nos lda tc_k1
        sta tc_col
        lda #0
        sta tc_row
        jsr tc_pass
tcl_ret ldx tc_bi
        rts
tc_h    dta 0
tc_k1   dta 0
tc_k2   dta 0
tc_best dta 0
tc_bi   dta 0
tc_wd   dta 0
tc_col  dta 0
tc_row  dta 0
tc_x    dta 0

; slot tc_bi: dst = VR_TEXT + slot*2048 (+256 for the shadow row)
tc_dst  lda tc_bi
        asl
        asl
        asl
        clc
        adc tc_row
        sta bi_dst+1
        lda #^VR_TEXT
        sta bi_dst+2
        rts

tc_clear
        lda #0
        sta tc_row
        jsr tc_dst
        lda #0
        sta bi_dst
        sta band
        sta bxor
        sta bssx
        sta bssy
        sta bmode
        sta bsrc
        sta bsrc+1
        sta bsrc+2
        sta bw+1
        sta bh+1
        lda tc_wd
        clc
        adc #3
        sta bw
        bcc tcc_1
        inc bw+1
tcc_1   lda #8
        sta bh
        sta tmp             ; dest step 256
        jmp blit_emit

; blit every glyph of slot tc_bi's string in colour tc_col at row tc_row
tc_pass lda #0
        sta tc_x
        sta tc_i
tcp_l   ldx tc_bi
        lda tcs_lo,x
        sta ptr2
        lda tcs_hi,x
        sta ptr2+1
        ldy tc_i
        lda (ptr2),y
        cmp #$ff
        beq tcp_d
        sta tc_g
        cmp #G_SPACE
        beq tcp_n
        ; source VR_FONT + g*4, step 512
        asl
        asl
        sta bsrc
        lda #0
        rol
        clc
        adc #>VR_FONT
        sta bsrc+1
        lda #^VR_FONT
        sta bsrc+2
        jsr tc_dst
        lda tc_x
        sta bi_dst
        lda #3
        sta bw
        lda #6
        sta bh
        lda #0
        sta bw+1
        sta bh+1
        sta bxor
        lda #1
        sta bssx
        sta bmode
        lda #9
        sta bssy
        lda tc_col
        sta band
        lda #8
        sta tmp
        jsr blit_emit
tcp_n   ldx tc_g
        lda tc_x
        clc
        adc glyph_k,x
        sta tc_x
        inc tc_i
        lda tc_i
        cmp #47
        bne tcp_l
tcp_d   rts
tc_i    dta 0
tc_g    dta 0

; string slot addresses
tcs_lo
        .rept NSLOT
        dta <(tc_str+#*SLOTLEN)
        .endr
tcs_hi
        .rept NSLOT
        dta >(tc_str+#*SLOTLEN)
        .endr

; pr() helpers: text at (A=x, X=y) screen position, colours txt_c1/txt_c2
pr_at   sta bx
        stx by
        lda #0
        sta bx+1
        sta by+1
        jmp text_draw
