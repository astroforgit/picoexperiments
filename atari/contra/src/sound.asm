; ------------------------------------------------------------------
; NES APU -> POKEY. The game's sound driver writes the APU registers
; into a RAM copy at $0A00 (register $40xx at $0Axx) and calls
; convert_audio once per game frame. Timer-high writes are recorded
; separately from their values: writing zero also starts a new note.
; Pulse 1/2 -> POKEY 1/2, triangle -> 3, noise -> 4; 8-bit, 64 kHz clock.
; Length counters, envelopes and the linear counter are stepped per call.
; Contra music and effects share the original APU driver. DMC samples
; and hardware pulse sweeps are not synthesized by this converter.
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
        jsr effect_pulse
        ldx #1                  ; pulse 2
        jsr effect_pulse
        ldx #2
        jsr effect_active
        bcc ca_noise
        jsr triangle
ca_noise
        ldx #3
        jsr effect_active
        bcc ca_done
        jsr noise
ca_done
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
        lda s_trigger,x
        beq pu_1
        lda APU+3,y
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
        sta s_trigger,x
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
        lda s_vol
        sta s_vol
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
        lda s_trigger+2
        beq tr_1
        lda APU+$0B
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
        sta s_trigger+2
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
        lda s_trigger+3
        beq no_1
        lda APU+$0F
        lsr
        lsr
        lsr
        tay
        lda len_tab,y
        sta s_len+3
        lda #1
        sta s_start+3
        lda #0
        sta s_trigger+3
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

; C = 1 when effect track 4+X owns this channel. Otherwise clear both
; POKEY output and converter state, so a finished effect cannot ring on.
effect_pulse
        jsr effect_active
        bcc ep_done
        jmp pulse
ep_done rts

effect_active
        lda APU+$15
        and sound_bit,x
        beq ea_silent
        lda s_trigger,x
        ora s_len,x
        bne ea_yes
ea_silent
        txa
        asl
        tay
        lda #0
        sta AUDC1,y
        clc
        rts
ea_yes  sec
        rts
sound_bit dta 1,2,4,8

; s_t = 11-bit timer, s_oct = 0 pulse / 1 triangle -> s_audf for POKEY's
; 64 kHz clock: AUDF+1 = (t+1) * pitch_k / 512 (* 2 for the triangle),
; raised by octaves until it fits in 8 bits.
timer_audf
        ; Select PAL/NTSC and pulse/triangle table. No scratch zero page:
        ; audio runs inside the NMI while the compositor is suspended.
        lda pitch_k
        cmp #146
        lda #0
        rol
        asl
        ora s_oct
        tay
        lda pitch_pages,y
        clc
        adc s_t+1
        sta ta_lookup+2
        ldy s_t
ta_lookup
        lda pitch_table,y
        sta s_audf
        rts
pitch_pages dta >pitch_table, >(pitch_table+$800)
        dta >(pitch_table+$1000), >(pitch_table+$1800)

; NES length counter values (in half frames)
len_tab dta 10,254,20,2,40,4,80,6,160,8,60,10,14,12,26,14
        dta 12,16,24,18,48,20,96,22,192,24,72,26,16,28,32,30
; NES noise periods mapped to POKEY 64 kHz dividers
noise_tab dta 0,0,0,0,1,2,3,4,6,8,13,17,26,35,72,144
bit_tab dta 1,2,4,8

