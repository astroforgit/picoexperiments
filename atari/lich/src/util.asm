; ------------------------------------------------------------------
; Helpers: random numbers, multiply, map access, distances.
; ------------------------------------------------------------------

; rnd16 -> rnd_lo/rnd_hi (also A = rnd_hi).  16-bit xorshift (7,9,8)
; mixed with POKEY's RANDOM.
rnd_lo  dta 0
rnd_hi  dta 0
rnd16   lda rng+1
        lsr
        lda rng
        ror
        eor rng+1
        sta rng+1
        ror
        eor rng
        sta rng
        eor rng+1
        sta rng+1
        lda rng
        eor RANDOM
        sta rnd_lo
        lda rng+1
        sta rnd_hi
        rts

; A = intrnd(A) = flr(rnd(A)), A = 0..255 (0 -> 0).  Keeps X, Y.
intrnd  sta ir_n
        stx ir_x
        jsr rnd16           ; A = rnd_hi
        sta ir_t
        lda #0
        sta ir_t+1
        sta ir_a
        sta ir_a+1
ir_l    lsr ir_n            ; rnd_hi * n, one step per bit of n
        bcc ir_s
        lda ir_a
        clc
        adc ir_t
        sta ir_a
        lda ir_a+1
        adc ir_t+1
        sta ir_a+1
ir_s    asl ir_t
        rol ir_t+1
        lda ir_n
        bne ir_l
        lda ir_a+1          ; flr(rnd * n), 8-bit random fraction
        ldx ir_x
        rts
ir_a    dta 0,0
ir_n    dta 0
ir_x    dta 0
ir_y    dta 0
ir_t    dta 0,0

; flr(rnd(A/2)) for the loop counts rnd(r.w/2)
intrnd_half
        jsr intrnd_frac
        lsr
        rts
; A -> rnd(A) scaled by 2: returns flr(rnd(A)*2) - helper for halves
intrnd_frac
        asl
        bcc irf_1
        lda #255
irf_1   jmp intrnd

; C=1 when chance(p) succeeds: rnd16 < A:X (A = high, X = low)
chance  sta ch_hi
        stx ch_lo
        jsr rnd16
        lda rnd_lo
        cmp ch_lo
        lda rnd_hi
        sbc ch_hi
        ; C=0 when rnd < p
        bcc chc_yes
        clc
        rts
chc_yes sec
        rts
ch_hi   dta 0
ch_lo   dta 0

; chance with p = A/256 (A = 0..255)
chance8 ldx #0
        jmp chance

; m_r = m_a * m_b (8x8 -> 16), keeps X, Y
mul8    lda #0
        sta m_r+1
        stx mul_x
        ldx #8
mu_l    lsr m_b
        bcc mu_s
        clc
        adc m_a
mu_s    ror
        ror m_r
        dex
        bne mu_l
        sta m_r+1
        ldx mul_x
        rts
mul_x   dta 0

; ptr = TMAP + X*128 (X = ty); Y stays the column
tile_ofs
        lda row_lo,x
        sta ptr
        lda row_hi,x
        sta ptr+1
        rts
row_lo
        .rept 32
        dta <(TMAP+#*128)
        .endr
row_hi
        .rept 32
        dta >(TMAP+#*128)
        .endr

; A = mget(Y = tx, X = ty), 0 outside the map; flags follow A.  Keeps X, Y.
mget    cpy #128
        bcs mg_out
        cpx #32
        bcs mg_out
        lda row_lo,x
        sta ptr
        lda row_hi,x
        sta ptr+1
        lda (ptr),y
        rts
mg_out  lda #0
        rts
mg_x    dta 0

; mset(Y = tx, X = ty, A).  Keeps X, Y.
mset    cpy #128
        bcs ms_out
        cpx #32
        bcs ms_out
        pha
        lda row_lo,x
        sta ptr
        lda row_hi,x
        sta ptr+1
        pla
        sta (ptr),y
ms_out  rts

; fog value at (Y, X) -> A (2 outside the map)
fog_get cpy #128
        bcs fg_out
        cpx #32
        bcs fg_out
        stx mg_x
        jsr tile_ofs
        lda ptr+1
        clc
        adc #>(FOG-TMAP)
        sta ptr+1
        lda (ptr),y
        ldx mg_x
        rts
fg_out  lda #2
        rts

; is_floor(A): Z=1 (beq) when the tile is floor
is_floor
        cmp #1
        beq if_yes
        cmp #2
        beq if_yes
        cmp #32
        bcc if_no
        cmp #45
        bcs if_no
if_yes  lda #0
        rts
if_no   lda #1
        rts

; m_r = dx*dx + dy*dy for dx = A, dy = X (signed, |v| < 128)
dist2   jsr abs8
        tay
        txa
        jsr abs8
        tax
        lda sq_lo,y
        clc
        adc sq_lo,x
        sta m_r
        lda sq_hi,y
        adc sq_hi,x
        sta m_r+1
        rts
abs8    cmp #$80
        bcc ab_d
        eor #$ff
        adc #0              ; C=1 here: +1
ab_d    and #$7f
        rts

; squares 0..127
sq_lo
        .rept 128
        dta <(#*#)
        .endr
sq_hi
        .rept 128
        dta >(#*#)
        .endr

; m_r = distance^2 between (A, X) and (Y, tmp): tile coordinates
dist2_pts
        sty d2_y
        sec
        sbc d2_y
        pha
        txa
        sec
        sbc tmp
        tax
        pla
        jmp dist2
d2_y    dta 0

; sign of A -> -1/0/1
ssgn    cmp #0
        beq sg_d
        bmi sg_n
        lda #1
        rts
sg_n    lda #$ff
sg_d    rts
