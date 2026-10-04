; ------------------------------------------------------------------
; NES APU -> POKEY. The game's sound driver writes the APU registers
; into a RAM copy at $0A00 (register $40xx at $0Axx) and calls
; convert_audio once per game frame. A non-zero $4003/$4007/$400B/$400F
; means a new note (the converter clears them, as the SNES port's did).
; Pulse 1/2 -> POKEY 1/2, triangle -> 3, noise -> 4; 8-bit, 64 kHz clock.
; Length counters, envelopes and the linear counter are stepped per call.
; ------------------------------------------------------------------
APU     = $0A00

convert_audio
        php
        pha
        txa
        pha
        tya
        pha
        cld
        ldx #0                  ; pulse 1
        jsr pulse
        ldx #1                  ; pulse 2
        jsr pulse
        jsr triangle
        jsr noise
        pla
        tay
        pla
        tax
        pla
        plp
        rts

reset_2a03_audio
        pha
        lda #0
        sta AUDC1
        sta AUDC1+2
        sta AUDC1+4
        sta AUDC1+6
        sta s_len
        sta s_len+1
        sta s_len+2
        sta s_len+3
        pla
        rts

; X = 0/1: registers at APU+4X
pulse   txa
        asl
        asl
        sta pu_y
        tay                     ; register offset
        lda APU+3,y
        beq pu_1
        ; new note: length, timer high, envelope restart
        pha
        and #7
        sta s_hi,x
        pla
        lsr
        lsr
        lsr
        sty pu_y
        tay
        lda len_tab,y
        sta s_len,x
        ldy pu_y
        lda #1
        sta s_start,x
        lda #0
        sta APU+3,y
pu_1    lda APU+$15
        and bit_tab,x
        bne pu_2
        sta s_len,x             ; channel disabled
pu_2    lda APU,y
        jsr envelope            ; A = volume after envelope/length
        sta s_vol
        ldy pu_y
        ; timer: below 8 the NES pulse is silent
        lda APU+2,y
        sta s_t
        lda s_hi,x
        sta s_t+1
        bne pu_3
        lda s_t
        cmp #8
        bcs pu_3
        lda #0
        sta s_vol
pu_3    lda #0
        sta s_oct               ; pulse: f = CPU / (16 (t+1))
        jsr timer_audf
        txa
        asl
        tay
        lda s_audf
        sta AUDF1,y
        lda s_vol
        ora #$A0                ; pure tone
        sta AUDC1,y
        rts
pu_y    dta 0

; A = $4000-style register (--LC VVVV), X = channel; steps the envelope
; (4 quarter frames) and the length counter (2 half frames).
; Returns A = output volume (0 when the length counter is 0).
envelope
        sta s_reg
        lda s_start,x
        beq ev_1
        lda #0
        sta s_start,x
        lda #15
        sta s_env,x
        lda s_reg
        and #15
        sta s_div,x
        jmp ev_len
ev_1    ldy #4
ev_q    lda s_div,x
        beq ev_clk
        dec s_div,x
        jmp ev_n
ev_clk  lda s_reg
        and #15
        sta s_div,x
        lda s_env,x
        beq ev_loop
        dec s_env,x
        jmp ev_n
ev_loop lda s_reg
        and #$20
        beq ev_n
        lda #15
        sta s_env,x
ev_n    dey
        bne ev_q
ev_len  lda s_reg
        and #$20                ; halt flag
        bne ev_out
        lda s_len,x
        sec
        sbc #2
        bcs ev_l1
        lda #0
ev_l1   sta s_len,x
ev_out  lda s_len,x
        beq ev_rts
        lda s_reg
        and #$10
        beq ev_env
        lda s_reg
        and #15
        rts
ev_env  lda s_env,x
ev_rts  rts

triangle
        ldx #2
        lda APU+$0B
        beq tr_1
        pha
        and #7
        sta s_hi+2
        pla
        lsr
        lsr
        lsr
        tay
        lda len_tab,y
        sta s_len+2
        lda #1
        sta s_start+2           ; linear counter reload
        lda #0
        sta APU+$0B
tr_1    lda APU+$15
        and #4
        bne tr_2
        sta s_len+2
tr_2    ; linear counter: 4 quarter-frame clocks
        ldy #4
tr_q    lda s_start+2
        beq tr_dec
        lda APU+$08
        and #$7F
        sta s_lin
        lda APU+$08
        bmi tr_n                ; control set: keep reloading
        lda #0
        sta s_start+2
        beq tr_n
tr_dec  lda s_lin
        beq tr_n
        dec s_lin
tr_n    dey
        bne tr_q
        ; length counter (halted by the control flag)
        lda APU+$08
        bmi tr_3
        lda s_len+2
        sec
        sbc #2
        bcs tr_l
        lda #0
tr_l    sta s_len+2
tr_3    lda #0
        sta s_vol
        lda s_len+2
        beq tr_4
        lda s_lin
        beq tr_4
        lda #TRI_VOL
        sta s_vol
tr_4    lda APU+$0A
        sta s_t
        lda s_hi+2
        sta s_t+1
        lda #1
        sta s_oct               ; triangle: one octave below a pulse
        jsr timer_audf
        lda s_audf
        sta AUDF1+4
        lda s_vol
        ora #$A0
        sta AUDC1+4
        rts
TRI_VOL = 9

noise   ldx #3
        lda APU+$0F
        beq no_1
        lsr
        lsr
        lsr
        tay
        lda len_tab,y
        sta s_len+3
        lda #1
        sta s_start+3
        lda #0
        sta APU+$0F
no_1    lda APU+$15
        and #8
        bne no_2
        sta s_len+3
no_2    lda APU+$0C
        jsr envelope
        ora #$80                ; noise
        sta AUDC1+6
        lda APU+$0E
        and #15
        tay
        lda noise_tab,y
        sta AUDF1+6
        rts

; s_t = 11-bit timer, s_oct = 0 pulse / 1 triangle -> s_audf for POKEY's
; 64 kHz clock: AUDF+1 = (t+1) * pitch_k / 512 (* 2 for the triangle),
; raised by octaves until it fits in 8 bits.
timer_audf
        inc s_t
        bne ta_1
        inc s_t+1
ta_1    lda #0
        sta s_p
        sta s_p+1
        sta s_p+2
        sta s_m+2
        lda s_t
        sta s_m
        lda s_t+1
        sta s_m+1
        lda pitch_k
        sta s_k
        ldy #8
ta_mul  lsr s_k
        bcc ta_sh
        lda s_p
        clc
        adc s_m
        sta s_p
        lda s_p+1
        adc s_m+1
        sta s_p+1
        lda s_p+2
        adc s_m+2
        sta s_p+2
ta_sh   asl s_m
        rol s_m+1
        rol s_m+2
        dey
        bne ta_mul
        ; value = p >> (9 - oct): keep p+1/p+2 as a 16-bit number
        lda s_oct
        bne ta_oct
        lsr s_p+2
        ror s_p+1
ta_oct  lda s_p+2               ; while value > 256: next octave up
        beq ta_ok
        cmp #1
        bne ta_up
        lda s_p+1
        beq ta_ok               ; exactly 256
ta_up   lsr s_p+2
        ror s_p+1
        jmp ta_oct
ta_ok   lda s_p+1
        sec
        sbc #1
        bcs ta_2
        lda #0
ta_2    sta s_audf
        rts

; NES length counter values (in half frames)
len_tab dta 10,254,20,2,40,4,80,6,160,8,60,10,14,12,26,14
        dta 12,16,24,18,48,20,96,22,192,24,72,26,16,28,32,30
; NES noise periods mapped to POKEY 64 kHz dividers
noise_tab dta 0,0,0,0,1,2,3,4,6,8,13,17,26,35,72,144
bit_tab dta 1,2,4,8
