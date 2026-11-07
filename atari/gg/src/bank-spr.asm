; bank SPR: sprite blits and the sprite cache (main context)
; instance cs_i: visible lines, cache lookup, BCB at ZPN
spr_emit
        lda sp_lo
        sta ZPN
        lda sp_hi
        sta ZPN+1
        lda #MEMB_LST
        jsr vbx_memb_a
        lda sc_flush            ; sprite graphics changed (a load): forget all
        beq se_c0
        lda #0
        sta sc_flush
        ldx #0
        lda #$FF
se_fl   sta sc_tab,x
        sta sc_tab+$100,x
        sta sc_tab+$200,x
        sta sc_tab+$300,x
        inx
        bne se_fl
se_c0   ; the key of this instance
        lda em_y
        sta sc_key
        lda em_x
        sta sc_key+1
        lda em_fl
        sta sc_key+2
        lda em_ptr
        sta sc_key+3
        lda em_col
        sta sc_key+4
        lda em_l0
        sta sc_key+5
        lda em_l1
        sta sc_key+6
        lda win_top
        clc
        adc win_l
        sta sc_key+7
        ; entry of slot spr_n of list bl: sc_tab + (bl*64 + spr_n)*8
        lda spr_n
        cmp #NSPRB
        bcs se_go
        sta sc_p
        lda bl
        lsr
        ror
        ror                     ; bl * 64
        ora sc_p
        sta sc_p
        lda #0
        sta sc_p+1
        asl sc_p
        rol sc_p+1
        asl sc_p
        rol sc_p+1
        asl sc_p
        rol sc_p+1
        lda sc_p
        clc
        adc #<sc_tab
        sta sc_p
        lda sc_p+1
        adc #>sc_tab
        sta sc_p+1
        ldy #7
se_cmp  lda sc_key,y
        cmp (sc_p),y
        bne se_go
        dey
        bpl se_cmp
        ; the list already has this blit
        lda ZPN
        clc
        adc #21
        sta ZPN
        bcc se_c1
        inc ZPN+1
se_c1   inc spr_n
        jmp se_done
se_go   lda spr_n
        sta sc_n
        jsr so_go
        lda spr_n
        cmp sc_n
        beq se_done             ; not drawn
        lda sc_n
        cmp #NSPRB
        bcs se_done
        ldy #7                  ; remember what slot sc_n of this list draws
se_st   lda sc_key,y
        sta (sc_p),y
        dey
        bpl se_st
se_done
        lda ZPN
        sta sp_lo
        lda ZPN+1
        sta sp_hi
        lda #0
        jmp vbx_memb_a
so_go   lda spr_n
        cmp #NSPRB
        bcc so_0
        rts
so_0    ; first line on the FB: y + 1 - 51
        lda em_y
        sec
        sbc #50
        sta so_y0               ; may wrap (sprites high up)
        lda #0
        sbc #0
        sta so_y0h              ; $FF if negative
        ; visible: max(y0, l0, win_top) .. min(y0+21, l1, win_bot)
        lda em_l0
        cmp win_top
        bcs so_1
        lda win_top
so_1    sta so_a
        lda so_y0h
        bne so_2                ; y0 < 0: a stays
        lda so_y0
        cmp so_a
        bcc so_2
        sta so_a
so_2    ; end = y0 + 21
        lda so_y0
        clc
        adc #21
        sta so_b
        lda so_y0h
        adc #0
        bmi so_out              ; entirely above
        bne so_b2               ; beyond 255
        lda so_b
        cmp em_l1
        bcc so_3
so_b2   lda em_l1
        sta so_b
so_3    lda so_b
        cmp win_bot
        bcc so_4
        lda win_bot
        sta so_b
so_4    lda so_a
        cmp so_b
        bcc so_5
so_out  rts
so_5    ; x: visible when X in win_l-23 .. win_r-1
        lda em_fl
        and #1
        sta so_xh
        lda em_x
        sta so_x
        ; cache
        jsr spr_lookup
        bcs so_out              ; not available or empty
        ; source: slot*512 + (a - y0)*24 (+ left clip)
        sty so_slot
        lda so_a
        sec
        sbc so_y0
        sta so_skip             ; rows skipped at the top (0-20)
        tay
        lda mul24,y
        sta so_s
        lda #0
        sta so_s+1
        lda so_skip
        cmp #11
        bcc so_6
        inc so_s+1              ; rows 11+ : 24*11 = 264 > 255
        lda mul24,y
        sta so_s
so_6    ; width and left/right clipping
        lda #23
        sta so_w
        lda #0
        sta so_cl
        ; left: X < win_l -> skip win_l - X pixels
        lda so_xh
        bne so_r
        lda so_x
        cmp win_l
        bcs so_r
        lda win_l
        sec
        sbc so_x
        cmp #24
        bcs so_out
        sta so_cl
        lda #23
        sec
        sbc so_cl
        sta so_w
        lda win_l
        sta so_x
so_r    ; right: X + width > win_r -> shorten
        lda so_x
        clc
        adc so_w
        sta so_t
        lda so_xh
        adc #0
        sta so_t+1              ; last pixel x
        lda so_t+1
        cmp win_r+1
        bcc so_7
        bne so_rc
        lda so_t
        cmp win_r
        bcc so_7
so_rc   ; cut to win_r - 1
        lda win_r
        sec
        sbc so_x
        sta so_t
        lda win_r+1
        sbc so_xh
        bmi so_out2
        bne so_7
        lda so_t
        beq so_out2
        sec
        sbc #1
        sta so_w
        jmp so_7
so_out2 rts
so_7    ; BCB: src (3), dst (3), width, height, and
        ldy so_slot
        jsr spr_addr            ; ZPX..+2 = V_SPR + slot*512
        lda ZPX
        clc
        adc so_s
        sta ZPX
        lda ZPX+1
        adc so_s+1
        sta ZPX+1
        bcc so_8
        inc ZPX+2
so_8    lda ZPX
        clc
        adc so_cl
        ldy #0
        sta (ZPN),y
        lda ZPX+1
        adc #0
        iny
        sta (ZPN),y
        lda ZPX+2
        adc #0
        iny
        sta (ZPN),y
        ; dst = FB + a*368 + X (the margin is 24 = the sprite X of column 0)
        lda so_a
        jsr sfb_row
        lda ZPX
        clc
        adc so_x
        ldy #6
        sta (ZPN),y
        lda ZPX+1
        adc so_xh
        iny
        sta (ZPN),y
        lda ZPX+2
        adc #0
        iny
        sta (ZPN),y
        lda so_w
        ldy #12
        sta (ZPN),y
        lda so_b
        sec
        sbc so_a
        sec
        sbc #1
        ldy #14
        sta (ZPN),y
        lda em_col
        ora #$30
        ldy #15
        sta (ZPN),y
        lda ZPN
        clc
        adc #21
        sta ZPN
        bcc so_9
        inc ZPN+1
so_9    inc spr_n
        rts
sc_key  .ds 8
sc_n    dta 0
sc_tab  .ds 2*64*8              ; per list and sprite slot: the instance it draws
so_y0   dta 0
so_y0h  dta 0
so_a    dta 0
so_b    dta 0
so_x    dta 0
so_xh   dta 0
so_slot dta 0
so_skip dta 0
so_s    dta 0,0
so_w    dta 0
so_cl   dta 0
so_t    dta 0,0
mul24   :21 dta <(#*24)

; Y = sprite slot: ZPX..+2 = V_SPR + Y*512
spr_addr
        tya
        asl
        sta ZPX+1
        lda #0
        rol
        sta ZPX+2
        lda #0
        sta ZPX
        lda ZPX+1
        clc
        adc #>V_SPR
        sta ZPX+1
        lda ZPX+2
        adc #^V_SPR
        sta ZPX+2
        rts

; ------------------------------------------------------------------
; sprite cache: slot = pointer (< 192) or 192 + (pointer & 7); tag:
; bit 7 valid, bit 6 empty, bit 5 multicolour, bits 0-1 VIC bank
; ------------------------------------------------------------------
; instance cs_i -> C clear and Y = slot, or C set (skip this frame)
spr_lookup
        lda em_fl
        and #2
        asl
        asl
        asl
        asl                     ; multicolour -> bit 5
        sta sl_t
        lda em_fl
        rol
        rol
        rol
        and #3
        ora sl_t
        ora #$80
        sta sl_t                ; wanted tag (not empty)
        lda em_ptr
        cmp #192
        bcc sl_1
        and #7
        ora #192
sl_1    tay
        lda spr_tag,y
        and #$BF
        cmp sl_t
        bne sl_miss
        cpy #192
        bcc sl_hit
        lda em_ptr
        cmp spr_ptag-192,y
        bne sl_miss
sl_hit  lda spr_tag,y
        and #$40
        bne sl_skip             ; empty sprite
        clc
        rts
sl_miss dec ex_budget
        bmi sl_skip
        sty sl_y
        lda em_ptr
        sta ex_ptr
        lda sl_t
        sta ex_tag
        jsr spr_expand          ; uses the main-context path? no: NMI-safe
        ldy sl_y
        jmp sl_hit
sl_skip lda em_ptr
        sta spr_want
        sec
        rts
sl_t    dta 0
sl_y    dta 0

; expand sprite ex_ptr with tag ex_tag into slot Y.
; Raw data: VIC bank (tag bits 0-1, 3 = $C000) + ptr*64; in bank 3 below
; $F000 it comes from the VRAM image, else from RAM.
spr_expand
        sty ex_slot
        cpy #192
        bcc se_0
        lda ex_ptr
        sta spr_ptag-192,y
se_0    ; raw address
        lda ex_ptr
        lsr
        lsr
        sta ex_a+1
        lda ex_ptr
        ror
        ror
        ror
        and #$C0
        sta ex_a                ; ptr*64 within the bank
        lda ex_tag
        and #3
        asl
        asl
        asl
        asl
        asl
        asl
        clc
        adc ex_a+1
        sta ex_a+1              ; + bank*16K
        cmp #$F0
        bcs se_ram
        cmp #$C0
        bcc se_ram
        ; VRAM image: window bank V_VIC, offset (addr - $C000)
        sec
        sbc #$C0-(>WIN)
        sta se_src+2
        lda ex_a
        sta se_src+1
        lda memb_sh
        pha
        lda #MEMB_ON|(V_VIC>>14)
        jsr vbx_memb_a
        ldx #62
se_src  lda WIN,x
        sta sp_raw,x
        dex
        bpl se_src
        pla
        jsr vbx_memb_a
        jmp se_have
se_ram  lda ex_a
        sta se_r+1
        lda ex_a+1
        sta se_r+2
        lda memb_sh
        pha
        lda #0
        jsr vbx_memb_a
        ldx #62
se_r    lda $FFFF,x
        sta sp_raw,x
        dex
        bpl se_r
        pla
        jsr vbx_memb_a
se_have ; empty?
        ldx #62
        lda #0
se_e    ora sp_raw,x
        dex
        bpl se_e
        tax
        bne se_full
        lda ex_tag
        ora #$40
        ldy ex_slot
        sta spr_tag,y
        rts
se_full ; destination window: V_SPR + slot*512
        ldy ex_slot
        jsr spr_addr            ; ZPX..+2
        lda ZPX+2
        asl
        asl
        sta ex_t
        lda ZPX+1
        rol
        rol
        rol
        and #3
        ora ex_t
        ora #MEMB_ON
        sta ex_mb               ; bank of the slot
        lda ZPX+1
        and #$3F
        ora #>WIN
        sta se_d+2
        lda ZPX
        sta se_d+1
        lda memb_sh
        pha
        lda ex_mb
        jsr vbx_memb_a
        ldx #0                  ; raw index
        ldy #0                  ; output index within the line block
se_line lda #3
        sta ex_t
se_byte lda sp_raw,x
        sta ex_b
        lda ex_tag
        and #$20
        beq se_hires
        ; multicolour: 4 double pixels
        lda #4
        sta ex_c
se_mc   lda #0
        asl ex_b
        rol
        asl ex_b
        rol
        stx ex_x
        tax
        lda mc_code,x
        ldx ex_x
        jsr se_put
        jsr se_put
        dec ex_c
        bne se_mc
        jmp se_nb
se_hires
        lda #8
        sta ex_c
se_hi   asl ex_b
        lda #0
        bcc se_h0
        lda #$2F
se_h0   jsr se_put
        dec ex_c
        bne se_hi
se_nb   inx
        dec ex_t
        bne se_byte
        cpx #63
        bne se_line
        pla
        jsr vbx_memb_a
        lda ex_tag
        ldy ex_slot
        sta spr_tag,y
        rts
se_put
se_d    sta WIN
        inc se_d+1
        bne se_p1
        inc se_d+2
se_p1   rts
mc_code dta $00,$1F,$2F,$3F
ex_slot dta 0
ex_ptr  dta 0
ex_tag  dta 0
ex_a    dta 0,0
ex_t    dta 0
ex_mb   dta 0
ex_b    dta 0
ex_c    dta 0
ex_x    dta 0

; ZPX/ZPX+1/ZPX+2 = framebuffer bl + A * 368 (A = FB line); keeps X
sfb_row  tay
        stx sfr_x
        ldx bl
        lda sfbr_lo,y
        clc
        adc fb_lo,x
        sta ZPX
        lda sfbr_mid,y
        adc fb_mid,x
        sta ZPX+1
        lda sfbr_hi,y
        adc fb_hi,x
        sta ZPX+2
        ldx sfr_x
        rts
sfr_x    dta 0
sfbr_lo  :201 dta <[#*FBW]
sfbr_mid :201 dta >[#*FBW]
sfbr_hi  :201 dta ^[#*FBW]
