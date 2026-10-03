; ------------------------------------------------------------------
; Arithmetic: quarter-square multiply, fixed-point helpers, division,
; vector normalisation (the cart's ho() and ij()), random numbers.
;
; Fixed point: speeds and short distances are signed 8.8 (lo = fraction).
; Positions are 24 bit (fraction, int lo, int hi).
; ------------------------------------------------------------------

; build the quarter-square tables sq4_lo/hi[n] = n*n/4, n = 0..511
; tmp/tmp+1 = n, tmp+2..tmp+4 = n*n (exact)
make_squares
        lda #0
        ldx #4
msq_z   sta tmp,x
        dex
        bpl msq_z
msq_l   ; store (n*n) >> 2
        lda tmp+4
        lsr
        sta tmp+7
        lda tmp+3
        ror
        sta tmp+6
        lda tmp+2
        ror
        sta tmp+5
        lsr tmp+7
        ror tmp+6
        ror tmp+5
        ldx tmp
        lda tmp+1
        bne msq_h
        lda tmp+5
        sta sq4_lo,x
        lda tmp+6
        sta sq4_hi,x
        jmp msq_n
msq_h   lda tmp+5
        sta sq4_lo+256,x
        lda tmp+6
        sta sq4_hi+256,x
msq_n   ; n*n += 2n + 1
        lda tmp
        asl
        sta tmp+5
        lda tmp+1
        rol
        sta tmp+6
        lda tmp+5
        sec
        adc tmp+2
        sta tmp+2
        lda tmp+6
        adc tmp+3
        sta tmp+3
        lda #0
        adc tmp+4
        sta tmp+4
        inc tmp
        bne msq_c
        inc tmp+1
msq_c   lda tmp+1
        cmp #2
        bne msq_l
        rts

; umul8: A * X -> m_hi:m_lo (unsigned).  Keeps nothing.
umul8   stx m_t
        sta m_s
        sec
        sbc m_t
        bcs um_p
        eor #$ff
        adc #1
um_p    tay
        lda m_s
        clc
        adc m_t
        tax
        bcs um_h
        lda sq4_lo,x
        sec
        sbc sq4_lo,y
        sta m_lo
        lda sq4_hi,x
        sbc sq4_hi,y
        sta m_hi
        rts
um_h    lda sq4_lo+256,x
        sec
        sbc sq4_lo,y
        sta m_lo
        lda sq4_hi+256,x
        sbc sq4_hi,y
        sta m_hi
        rts

; mulf: signed 8.8 m_v (lo,hi) * unsigned fraction A/256 -> m_v.
; A = 0 means 1.0 (unchanged).
mulf    cmp #0
        beq mf_one
        sta m_f
        lda m_v+1
        php
        bpl mf_pos
        lda #0
        sec
        sbc m_v
        sta m_v
        lda #0
        sbc m_v+1
        sta m_v+1
mf_pos  lda m_v+1
        bne mf_2
        lda m_v
        ldx m_f
        jsr umul8           ; |v| < 1: (lo*f) >> 8
        lda m_hi
        sta m_v
        lda #0
        sta m_v+1
        jmp mf_sg
mf_2    lda m_v
        ldx m_f
        jsr umul8
        lda m_hi
        sta m_r             ; (lo*f) >> 8
        lda m_v+1
        ldx m_f
        jsr umul8
        lda m_lo
        clc
        adc m_r
        sta m_v
        lda m_hi
        adc #0
        sta m_v+1
mf_sg   plp
        bpl mf_one
        lda #0
        sec
        sbc m_v
        sta m_v
        lda #0
        sbc m_v+1
        sta m_v+1
mf_one  rts

; mulu: signed 8.8 m_v * unit factor m_u (signed, magnitude 0..256) -> m_v
mulu    lda m_u+1
        beq mu_pos
        cmp #1
        beq mu_one          ; +1.0
        ; negative: -1.0 ($ff00) or -(1..255)
        lda m_u
        beq mu_neg1
        lda #0
        sec
        sbc m_u
        jsr mulf
        jmp neg_v
mu_neg1 jmp neg_v
mu_pos  lda m_u
        beq mu_zero
        jmp mulf
mu_zero sta m_v
        sta m_v+1
mu_one  rts

neg_v   lda #0
        sec
        sbc m_v
        sta m_v
        lda #0
        sbc m_v+1
        sta m_v+1
        rts

; muls: signed 8.8 m_v * signed 8.8 m_w -> m_v (both magnitudes < 128)
muls    lda m_w+1
        eor m_v+1
        php
        lda m_v+1
        bpl ms1
        jsr neg_v
ms1     lda m_w+1
        bpl ms2
        lda #0
        sec
        sbc m_w
        sta m_w
        lda #0
        sbc m_w+1
        sta m_w+1
ms2     ; (vh.vl * wh.wl) >> 8 = vh*wh*256 + vh*wl + vl*wh + (vl*wl)>>8
        lda m_v
        ldx m_w
        jsr umul8
        lda m_hi
        sta m_r
        lda #0
        sta m_r+1
        sta m_r+2
        lda m_v+1
        ldx m_w
        jsr umul8
        jsr ms_acc
        lda m_v
        ldx m_w+1
        jsr umul8
        jsr ms_acc
        lda m_v+1
        ldx m_w+1
        jsr umul8
        lda m_lo
        clc
        adc m_r+1
        sta m_v+1
        lda m_r
        sta m_v
        plp
        bpl ms3
        jmp neg_v
ms3     rts
ms_acc  lda m_lo
        clc
        adc m_r
        sta m_r
        lda m_hi
        adc m_r+1
        sta m_r+1
        rts

; div16: m_n (16 bit) / m_d (16 bit, nonzero) -> m_q (16 bit), m_n = remainder
div16   lda #0
        sta m_q
        sta m_q+1
        sta m_rm
        sta m_rm+1
        ldx #16
d16_l   asl m_n
        rol m_n+1
        rol m_rm
        rol m_rm+1
        lda m_rm
        sec
        sbc m_d
        tay
        lda m_rm+1
        sbc m_d+1
        bcc d16_s
        sta m_rm+1
        sty m_rm
d16_s   rol m_q
        rol m_q+1
        dex
        bne d16_l
        rts

; frac_div: A = min * 256 / max for 16 bit m_n (min) <= m_d (max), max > 0
; (8 bit result, 255 when equal)
frac_div
        lda m_n
        sta m_rm
        lda m_n+1
        sta m_rm+1
        lda #0
        sta m_q
        ldx #8
fd_l    asl m_rm
        rol m_rm+1
        bcs fd_sub          ; 17th bit set: certainly >= max
        lda m_rm
        cmp m_d
        lda m_rm+1
        sbc m_d+1
        bcc fd_s
fd_sub  lda m_rm
        sec
        sbc m_d
        sta m_rm
        lda m_rm+1
        sbc m_d+1
        sta m_rm+1
        sec
fd_s    rol m_q
        dex
        bne fd_l
        lda m_q
        rts

; ------------------------------------------------------------------
; Vector from (nx0,ny0) to (nx1,ny1): positions as 24 bit x (frac, lo, hi)
; and 16 bit y (frac, int).  Callers fill nv_dx (24 bit) / nv_dy (24 bit)
; with the differences; vnorm computes:
;   nv_ux, nv_uy  unit vector, signed, magnitude 0..256 (1.0 = 256)
;   nv_d          length, 8.8 unsigned (saturates at 255.99)
; A zero vector gives a zero unit vector and length 0 (as PICO-8: 0*huge).
; ------------------------------------------------------------------
vnorm   lda #0
        sta nv_sx
        sta nv_sy
        ; |dx|
        lda nv_dx+2
        bpl vn_1
        inc nv_sx
        lda #0
        sec
        sbc nv_dx
        sta nv_dx
        lda #0
        sbc nv_dx+1
        sta nv_dx+1
        lda #0
        sbc nv_dx+2
        sta nv_dx+2
vn_1    lda nv_dy+2
        bpl vn_2
        inc nv_sy
        lda #0
        sec
        sbc nv_dy
        sta nv_dy
        lda #0
        sbc nv_dy+1
        sta nv_dy+1
        lda #0
        sbc nv_dy+2
        sta nv_dy+2
vn_2    ; scale down until both fit 16 bit (shift count in nv_sh)
        lda #0
        sta nv_sh
vn_3    lda nv_dx+2
        ora nv_dy+2
        beq vn_4
        lsr nv_dx+2
        ror nv_dx+1
        ror nv_dx
        lsr nv_dy+2
        ror nv_dy+1
        ror nv_dy
        inc nv_sh
        jmp vn_3
vn_4    ; max / min
        lda nv_dx
        cmp nv_dy
        lda nv_dx+1
        sbc nv_dy+1
        bcc vn_ymax
        ; x is the major axis
        lda nv_dx
        ora nv_dx+1
        bne vn_xnz
        ; zero vector
        lda #0
        sta nv_ux
        sta nv_ux+1
        sta nv_uy
        sta nv_uy+1
        sta nv_d
        sta nv_d+1
        rts
vn_xnz  lda nv_dy
        sta m_n
        lda nv_dy+1
        sta m_n+1
        lda nv_dx
        sta m_d
        lda nv_dx+1
        sta m_d+1
        jsr frac_div
        tax
        lda nrm_maj_lo,x
        sta nv_ux
        lda nrm_maj_hi,x
        sta nv_ux+1
        lda nrm_min,x
        sta nv_uy
        lda #0
        sta nv_uy+1
        jmp vn_len
vn_ymax lda nv_dx
        sta m_n
        lda nv_dx+1
        sta m_n+1
        lda nv_dy
        sta m_d
        lda nv_dy+1
        sta m_d+1
        jsr frac_div
        tax
        lda nrm_maj_lo,x
        sta nv_uy
        lda nrm_maj_hi,x
        sta nv_uy+1
        lda nrm_min,x
        sta nv_ux
        lda #0
        sta nv_ux+1
vn_len  ; length = max * nrm_len[r] (1 + fraction)
        lda nrm_len,x
        sta m_f
        lda m_d
        sta m_v
        lda m_d+1
        sta m_v+1
        ; max*(1+f) = max + max*f  (max as unsigned 8.8 < 256.0)
        lda m_v
        ldx m_f
        jsr umul8
        lda m_hi
        sta m_r
        lda m_v+1
        ldx m_f
        jsr umul8
        lda m_lo
        clc
        adc m_r
        sta m_r
        lda m_hi
        adc #0
        sta m_r+1
        lda m_v
        clc
        adc m_r
        sta nv_d
        lda m_v+1
        adc m_r+1
        sta nv_d+1
        bcs vn_sat
        ; undo the scaling of the length
        ldx nv_sh
        beq vn_sg
vn_sl   asl nv_d
        rol nv_d+1
        bcs vn_sat
        dex
        bne vn_sl
        jmp vn_sg
vn_sat  lda #$ff
        sta nv_d
        sta nv_d+1
vn_sg   ; apply the signs to the unit vector
        lda nv_sx
        beq vn_s1
        lda #0
        sec
        sbc nv_ux
        sta nv_ux
        lda #0
        sbc nv_ux+1
        sta nv_ux+1
vn_s1   lda nv_sy
        beq vn_s2
        lda #0
        sec
        sbc nv_uy
        sta nv_uy
        lda #0
        sbc nv_uy+1
        sta nv_uy+1
vn_s2   rts

; ------------------------------------------------------------------
; random numbers: 16 bit xorshift
; rnd8: A = 0..255 (keeps X, Y)
rnd8    lda rng+1
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
        eor RANDOM
        rts

; rnd_mul: A = rnd8 * A / 256  (0..A-1)
rnd_mul sta m_f
        jsr rnd8
        ldx m_f
        jsr umul8
        lda m_hi
        rts

; rnd_v: m_v = rnd() * m_v  (m_v signed 8.8)
rnd_v   jsr rnd8
        jmp mulf_nz
mulf_nz cmp #0
        bne mf_go
        sta m_v
        sta m_v+1
        rts
mf_go   jmp mulf

; chance_c: C = 1 when the event happens
chance_c
        sta m_f
        jsr rnd8
        cmp m_f
        bcc cc_yes
        clc
        rts
cc_yes  sec
        rts

; chance16: event with probability m_n/65536 (m_n 16 bit). C = 1 when it happens
chance16
        jsr rnd8
        sta m_r
        jsr rnd8
        cmp m_n+1
        bcc c16_y
        bne c16_n
        lda m_r
        cmp m_n
        bcc c16_y
c16_n   clc
        rts
c16_y   sec
        rts

; ------------------------------------------------------------------
; PICO-8 sin/cos of a byte angle (turns * 256) -> m_u (signed, 256 = 1)
psin    tax
        lda sin_lo,x
        sta m_u
        lda sin_hi,x
        sta m_u+1
        rts
pcos    clc
        adc #192
        jmp psin

; 8.8 signed m_v *= 2^-A  (arithmetic shift right A times)
asr_v   tax
        beq asv_d
av_l    lda m_v+1
        cmp #$80
        ror m_v+1
        ror m_v
        dex
        bne av_l
asv_d   rts

; mod_frames: A = frames mod X (X = 1..255), Z set by the result
mod_frames
        lda frames
        sta m_n
        lda frames+1
        sta m_n+1
; mod8: A = m_n (16 bit) mod X; m_q = the quotient (16 bit)
mod8    stx m_d
        lda #0
        ldy #16
md8_l   asl m_n
        rol m_n+1
        rol
        bcs md8_s
        cmp m_d
        bcc md8_n
md8_s   sbc m_d
        inc m_n             ; quotient bit (m_n was shifted left)
md8_n   dey
        bne md8_l
        sta m_rm
        ldx m_n
        stx m_q
        ldx m_n+1
        stx m_q+1
        tax                 ; Z from the remainder
        rts
