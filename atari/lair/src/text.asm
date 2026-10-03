; ------------------------------------------------------------------
; Text.  Strings are ASCII, 0-terminated (upper case prints like lower
; case).  A string is rendered once into one of 32 VRAM cache slots
; (256x16 at VR_TEXT + slot*4096): the glyph masks ($ff) in rows 1..5
; starting at column 1, and the outline mask (the glyphs moved by the
; cart's six outline offsets) in rows 8..14.  Drawing a cached string
; is then one blit for print() and two for the outlined gm().
; ------------------------------------------------------------------

; print(str_p, tx (16), ty (16), colour A)
print   sta tx_c
        lda #0
        sta tx_ol
        jmp tx_go
; gm(str_p, tx, ty, colour A): black outline, then the text
gm      sta tx_c
        lda #1
        sta tx_ol
tx_go   jsr tc_find         ; slot in A, tx_n = length
        sta tx_slot
        lda tx_n
        jeq tx_out
        ; source base = VR_TEXT + slot*4096
        lda tx_slot
        lsr
        lsr
        lsr
        lsr
        clc
        adc #2
        sta tx_sb2          ; bits 16..18
        lda tx_slot
        asl
        asl
        asl
        asl
        sta tx_sb1          ; bits 8..15
        lda tx_ol
        beq tx_body
        ; outline: rows 8..14 (one row above the text), from column 0
        lda tx_x
        sec
        sbc #1
        sta bx
        lda tx_x+1
        sbc #0
        sta bx+1
        lda tx_y
        sec
        sbc #1
        sta by
        lda tx_y+1
        sbc #0
        sta by+1
        lda #0
        sta bsrc
        lda tx_sb1
        ora #$08            ; row 8 * 256
        sta bsrc+1
        lda tx_sb2
        sta bsrc+2
        lda tx_n
        asl
        asl
        clc
        adc #2
        sta bw
        lda #0
        rol
        sta bw+1
        lda #7
        sta bh
        lda #0
        jsr vcol
        jsr tx_blit
tx_body lda tx_x
        sta bx
        lda tx_x+1
        sta bx+1
        lda tx_y
        sta by
        lda tx_y+1
        sta by+1
        lda #1
        sta bsrc
        lda tx_sb1
        ora #$01            ; row 1
        sta bsrc+1
        lda tx_sb2
        sta bsrc+2
        lda tx_n
        asl
        asl
        sta bw
        lda #0
        rol
        sta bw+1
        lda #5
        sta bh
        lda tx_c
        jsr vcol
tx_blit sta band
        lda #0
        sta bh+1
        sta bxor
        lda #1
        sta bssx
        sta bmode
        lda #8
        sta bssy
        jmp blit_cam
tx_out  rts

; ------------------------------------------------------------------
; tc_find: the cache slot holding str_p (rendering it on a miss).
; A = slot, tx_n = length.
tc_find lda #0
        sta tx_h
        tay
tf_h    lda (str_p),y
        beq tf_hd
        clc
        adc tx_h
        rol
        eor #$5a
        sta tx_h
        iny
        cpy #SLOTLEN-1
        bcc tf_h
tf_hd   sty tx_n
        inc tc_clock
        ldx #NSLOT-1
tf_l    lda tc_hash,x
        cmp tx_h
        bne tf_n
        lda tc_len,x
        cmp tx_n
        bne tf_n
        ; compare the bytes
        stx tx_s
        lda tcs_lo,x
        sta ptr
        lda tcs_hi,x
        sta ptr+1
        ldy #0
tf_c    cpy tx_n
        beq tf_hit
        lda (str_p),y
        cmp (ptr),y
        bne tf_nc
        iny
        bne tf_c
tf_nc   ldx tx_s
tf_n    dex
        bpl tf_l
        ; miss: the oldest slot
        ldx #0
        stx tx_s
        lda #0
        sta tx_age
tf_o    lda tc_clock
        sec
        sbc tc_age,x
        cmp tx_age
        bcc tf_o2
        sta tx_age
        stx tx_s
tf_o2   inx
        cpx #NSLOT
        bne tf_o
        ldx tx_s
        lda tx_h
        sta tc_hash,x
        lda tx_n
        sta tc_len,x
        lda tcs_lo,x
        sta ptr
        lda tcs_hi,x
        sta ptr+1
        ldy #0
tf_cp   lda (str_p),y
        sta (ptr),y
        beq tf_cpd
        iny
        cpy #SLOTLEN-1
        bcc tf_cp
        lda #0
        sta (ptr),y
tf_cpd  jsr tc_render
        ldx tx_s
tf_hit  ldx tx_s
        lda tc_clock
        sta tc_age,x
        txa
        rts

; render the string at str_p (tx_n glyphs) into slot tx_s
tc_render
        ; clear the slot (256x16)
        lda #0
        sta bi_src
        sta bi_src+1
        sta bi_src+2
        sta bi_ssy
        sta bi_ssy+1
        sta bi_ssx
        sta bi_and
        sta bi_xor
        sta bi_dst
        sta bi_dsy
        lda #1
        sta bi_dsy+1        ; 256
        sta bi_dsx
        lda tx_s
        asl
        asl
        asl
        asl
        sta bi_dst+1
        lda tx_s
        lsr
        lsr
        lsr
        lsr
        clc
        adc #2
        sta bi_dst+2
        lda #255
        sta bi_w
        lda #0
        sta bi_w+1
        lda #15
        sta bi_h
        lda #8
        sta bi_ctrl
        jsr bcb_raw
        ; glyphs: from VR_FONT + g*4 (stride 512) to slot row 1, column 1+4i
        lda #1
        sta bi_ssx
        lda #0
        sta bi_ssy
        lda #2
        sta bi_ssy+1        ; 512
        lda #3
        sta bi_w
        lda #4
        sta bi_h
        lda #$ff
        sta bi_and
        lda #9              ; transparent, next
        sta bi_ctrl
        lda #0
        sta tx_i
tr_g    ldy tx_i
        cpy tx_n
        beq tr_ol
        lda (str_p),y
        and #$7f
        tax
        lda asc_glyph,x
        ; src = $0c000 + g*4
        asl
        asl
        sta bi_src
        lda #0
        rol
        ora #$c0
        sta bi_src+1
        lda #0
        sta bi_src+2
        ; dst column 1 + 4i, row 1
        lda tx_i
        asl
        asl
        ora #1
        sta bi_dst
        lda tx_s
        asl
        asl
        asl
        asl
        ora #1
        sta bi_dst+1
        jsr bcb_raw
        inc tx_i
        jmp tr_g
tr_ol   ; outline: rows 0..6 copied to rows 8..14 moved by the six offsets
        lda #0
        sta bi_src
        lda tx_s
        asl
        asl
        asl
        asl
        sta bi_src+1
        lda tx_s
        lsr
        lsr
        lsr
        lsr
        clc
        adc #2
        sta bi_src+2
        lda #0
        sta bi_ssy
        lda #1
        sta bi_ssy+1        ; 256
        lda tx_n
        asl
        asl
        clc
        adc #1
        sta bi_w            ; width 4n+2 (minus one)
        lda #0
        rol
        sta bi_w+1
        lda #6
        sta bi_h
        ldx #5
tr_o    stx tx_i
        lda ol_dx,x
        sta bi_dst
        lda ol_dy,x
        clc
        adc bi_src+1
        sta bi_dst+1
        lda bi_src+2
        sta bi_dst+2
        jsr bcb_raw
        ldx tx_i
        dex
        bpl tr_o
        rts
; offsets of the outline: (1,0) (1,1) (0,1) (-1,1) (-1,0) (0,-1), as the
; linear distance (8+dy)*256+dx from the glyph rows to the outline rows
; (dx = -1 is column 255 of the row above)
ol_dx   dta 1,1,0,$ff,$ff,0
ol_dy   dta 8,9,9,8,7,7
tcs_lo  :NSLOT dta <(tc_str+#*SLOTLEN)
tcs_hi  :NSLOT dta >(tc_str+#*SLOTLEN)

; ------------------------------------------------------------------
; one outlined glyph (text particles): glyph of ASCII A at tx_x/tx_y,
; colour tx_c.  The outline masks are at VR_OFONT + g*8 (stride 512, 7 rows)
glyph_gm
        and #$7f
        tax
        lda asc_glyph,x
        sta tx_g
        ; outline
        lda tx_x
        sec
        sbc #1
        sta bx
        lda tx_x+1
        sbc #0
        sta bx+1
        lda tx_y
        sec
        sbc #1
        sta by
        lda tx_y+1
        sbc #0
        sta by+1
        lda tx_g
        asl
        asl
        asl
        sta bsrc
        lda #0
        rol
        ora #>VR_OFONT
        sta bsrc+1
        lda #^VR_OFONT
        sta bsrc+2
        lda #5
        sta bw
        lda #7
        sta bh
        lda #0
        sta bw+1
        jsr vcol
        jsr gg_blit
        ; body
        lda tx_x
        sta bx
        lda tx_x+1
        sta bx+1
        lda tx_y
        sta by
        lda tx_y+1
        sta by+1
        lda tx_g
        asl
        asl
        sta bsrc
        lda #0
        rol
        ora #>VR_FONT
        sta bsrc+1
        lda #^VR_FONT
        sta bsrc+2
        lda #3
        sta bw
        lda #5
        sta bh
        lda #0
        sta bw+1
        lda tx_c
        jsr vcol
gg_blit sta band
        lda #0
        sta bh+1
        sta bxor
        lda #1
        sta bssx
        sta bmode
        lda #9              ; 512
        sta bssy
        jmp blit_cam

; ------------------------------------------------------------------
; number formatting into numbuf (ASCII, 0-terminated)
; fmt_u16: m_n (16 bit unsigned) -> numbuf, X = length
fmt_u16 ldx #0
        stx fm_lead
        ldy #4
fu_d    lda #0
        sta fm_dig
fu_s    lda m_n
        sec
        sbc dec_lo,y
        sta tmp
        lda m_n+1
        sbc dec_hi,y
        bcc fu_put
        sta m_n+1
        lda tmp
        sta m_n
        inc fm_dig
        jmp fu_s
fu_put  lda fm_dig
        ora fm_lead
        bne fu_w
        cpy #0
        bne fu_n
fu_w    lda fm_dig
        ora #'0'
        sta numbuf,x
        inx
        sta fm_lead
fu_n    dey
        bpl fu_d
        lda #0
        sta numbuf,x
        rts
dec_lo  dta <1,<10,<100,<1000,<10000
dec_hi  dta >1,>10,>100,>1000,>10000
fm_lead dta 0
fm_dig  dta 0

; str_cat: append the string at (sp) to strbuf at offset X; X = new end
str_cat ldy #0
sc_l    lda (sp),y
        sta strbuf,x
        beq sc_d
        inx
        iny
        bne sc_l
sc_d    rts
; append numbuf
num_cat lda #<numbuf
        sta sp
        lda #>numbuf
        sta sp+1
        jmp str_cat
