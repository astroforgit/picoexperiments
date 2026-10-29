; Loaded after staging into unused RAM after the entity arrays ($bdc0-$bfff).
; Static overhang row index: avoids scanning empty map rows on every frame.
index_overhangs
        lda #0
        sta scn_si_row
scn_si_y    ldx scn_si_row
        lda #0
        sta $fa80,x
        ldy #0
scn_si_x    ldx scn_si_row
        jsr mget
        jsr find_overhang
        bcc scn_si_next
        ldx scn_si_row
        lda #1
        sta $fa80,x
        bne scn_si_endrow
scn_si_next iny
        bpl scn_si_x
scn_si_endrow inc scn_si_row
        lda scn_si_row
        cmp #32
        bne scn_si_y
        rts
scn_si_row dta 0

; Floor under cutout map scenery. Actors retain fully transparent sprites.
scenery_underlay
        lda tmp+1
        cmp #4
        bcc scn_su_ret
        cmp #16
        bcc scn_su_floor
        cmp #21
        bcc scn_su_ret
        cmp #32
        bcc scn_su_floor
        cmp #46
        bcc scn_su_ret
        cmp #48
        bcc scn_su_floor
        cmp #64
        bcc scn_su_ret
        cmp #76
        bcc scn_su_floor
        cmp #80
        bcc scn_su_ret
        cmp #92
        bcs scn_su_ret
scn_su_floor
        lda #8
        sta bsrc
        ldx tmp+2
        lda bk_sheet,x
        sta bsrc+1
        lda #1
        sta bsrc+2
        sta bssx
        lda #7
        sta bssy
        lda #255
        sta band
        lda #0
        sta bxor
        lda #10
        sta tmp
        jsr blit_emit
        lda #1
        sta bmode
scn_su_ret  rts

; Decorate baked front walls, not the per-frame entity list.
scenery_decor
        .if WALL_DECOR = 0
        rts
        .else
        lda #0
        sta scn_sd_bottom
        lda a1
        sta scn_sd_row
        lda tmp+1
        cmp #54
        beq scn_sd_front
        cmp #55
        beq scn_sd_front
        cmp #2
        beq scn_sd_below
        cmp #35
        beq scn_sd_below
        cmp #39
        beq scn_sd_below
        cmp #43
        jne scn_sd_ret
scn_sd_below
        inc scn_sd_bottom
        dec scn_sd_row
        ldx scn_sd_row
        ldy a0
        jsr mget
        cmp #54
        beq scn_sd_position
        cmp #55
        jne scn_sd_ret
        beq scn_sd_position
scn_sd_front
        ldx a1
        inx
        ldy a0
        jsr mget
        cmp #2
        beq scn_sd_position
        cmp #35
        beq scn_sd_position
        cmp #39
        beq scn_sd_position
        cmp #43
        jne scn_sd_ret
scn_sd_position
        lda #0
        sta scn_sd_q
        lda scn_sd_row
        asl
        clc
        adc a0
scn_sd_mod  cmp #5
        bcc scn_sd_rem
        sbc #5
        inc scn_sd_q
        bne scn_sd_mod
scn_sd_rem  cmp #2
        jne scn_sd_ret
        lda scn_sd_q
        clc
        adc scn_sd_row
        and #1
        asl
        ora scn_sd_bottom
        asl
        asl
        asl
        clc
        adc #96
        sta bsrc
        lda tmp+2
        asl
        asl
        asl
        asl
        asl
        clc
        adc #$9c
        sta bsrc+1
        lda #3
        sta bsrc+2
        lda #1
        sta bssx
        sta bmode
        lda #7
        sta bssy
        lda #255
        sta band
        lda #0
        sta bxor
        lda #10
        sta tmp
        jmp blit_emit
scn_sd_ret  rts
scn_sd_bottom dta 0
scn_sd_row dta 0
scn_sd_q dta 0
        .endif
