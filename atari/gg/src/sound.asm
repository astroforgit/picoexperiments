; ------------------------------------------------------------------
; SID -> POKEY, once per frame from the SID shadow (the game's player
; writes it during the IRQ chain).
; For now only the sound effects play: the game puts them on SID voice 3
; (voices 1 and 2 are the music). Voice 3 -> channels 1+2 joined (16 bits,
; 1.79 MHz). The 8-bit path (64 kHz, notes below its range raised by
; octaves) is for the music voices later.
; Tone waveforms play as pure tones, noise as POKEY 17-bit noise. The
; ADSR envelope is modelled per frame; gate changes inside a frame are
; seen through the write stubs (gor = OR, gand = AND of the values).
; ------------------------------------------------------------------
        icl '../gen/sound-tables.asm'

snd_init
        lda #$50                ; ch1 1.79 MHz, ch1+2 joined
        sta AUDCTL
        lda #0
        ldx #7
sn_i0   sta AUDF1,x
        dex
        bpl sn_i0
        ldx #2
sn_i1   sta env_lo,x
        sta env_hi,x
        sta pgate,x
        lda #3
        sta est,x
        lda #0
        dex
        bpl sn_i1
        jmp gate_clear

gate_clear
        ldx #20
gc_l    lda #0
        sta gor,x
        lda #$FF
        sta gand,x
        dex
        bpl gc_l
        rts

snd_frame
        lda #FIRST_VOICE
        sta sv
sf_v    ldx sv
        lda voff,x
        tay                     ; Y = register base of the voice
        ; gate events
        lda SID+4,y
        and #1
        sta sn_g                ; final gate
        lda gor+4,y
        and #1
        beq sf_ng               ; never on this frame
        lda pgate,x
        beq sf_att              ; off -> on
        lda gand+4,y
        and #1
        bne sf_ng               ; stayed on
sf_att  lda #0
        sta est,x
sf_ng   lda sn_g
        bne sf_g1
        lda est,x
        cmp #3
        beq sf_g1
        lda #3                  ; released
        sta est,x
sf_g1   lda sn_g
        sta pgate,x
        ; envelope
        lda est,x
        beq sf_attack
        cmp #1
        beq sf_decay
        cmp #2
        beq sf_sus
        ; release
        lda SID+6,y
        and #15
        jsr sf_down
        jmp sf_out
sf_attack
        lda SID+5,y
        lsr
        lsr
        lsr
        lsr
        tay
        lda env_lo,x
        clc
        adc ainc_lo,y
        sta env_lo,x
        lda env_hi,x
        adc ainc_hi,y
        bcs sf_top
        sta env_hi,x
        jmp sf_out0
sf_top  lda #$FF
        sta env_hi,x
        lda #1
        sta est,x
        jmp sf_out0
sf_decay
        lda SID+5,y
        and #15
        jsr sf_down
        ; reached sustain?
        ldy sv
        lda voff,y
        tay
        lda SID+6,y
        and #$F0
        sta sn_t
        lsr
        lsr
        lsr
        lsr
        ora sn_t                ; S * 17
        cmp env_hi,x
        bcc sf_out
        sta env_hi,x
        lda #0
        sta env_lo,x
        lda #2
        sta est,x
        jmp sf_out
sf_sus  lda SID+6,y
        and #$F0
        sta sn_t
        lsr
        lsr
        lsr
        lsr
        ora sn_t
        sta env_hi,x
        jmp sf_out
; A = rate: env -= dinc[A], not below 0
sf_down tay
        lda env_lo,x
        sec
        sbc dinc_lo,y
        sta env_lo,x
        lda env_hi,x
        sbc dinc_hi,y
        bcs sf_d1
        lda #0
        sta env_lo,x
sf_d1   sta env_hi,x
        rts
sf_out0
sf_out  ; volume = (env/16) * master / 16
        ldy sv
        lda voff,y
        tay
        lda SID+4,y
        and #$08                ; test bit: silent
        bne sf_mute
        lda SID+4,y
        and #$F0
        beq sf_mute             ; no waveform
        lda env_hi,x
        lsr
        lsr
        lsr
        lsr
        sta sn_t
        lda SID+$18
        and #15
        sta sn_t+1
        lda #0
        ldy #4
sf_mul  lsr sn_t+1
        bcc sf_m1
        clc
        adc sn_t
sf_m1   asl sn_t
        dey
        bne sf_mul
        lsr
        lsr
        lsr
        lsr
        sta sn_vol
        jmp sf_freq
sf_mute lda #0
        sta sn_vol
sf_freq ; distortion
        ldy sv
        lda voff,y
        tay
        lda SID+4,y
        bmi sf_noise
        lda #$A0
        bne sf_d
sf_noise
        lda #$80
sf_d    ora sn_vol
        sta sn_c
        ; frequency: normalise F to 1mmm mmmm xxxx xxxx, s = shifts
        lda SID,y
        sta sn_f
        lda SID+1,y
        sta sn_f+1
        ora sn_f
        bne sf_f1
        lda #0
        sta sn_c                ; F = 0: silent
        jmp sf_put
sf_f1   lda #0
        sta sn_s
sf_n    lda sn_f+1
        bmi sf_n1
        asl sn_f
        rol sn_f+1
        inc sn_s
        bne sf_n
sf_n1   and #$7F
        tay
        lda rcp_lo,y
        sta sn_r
        lda rcp_hi,y
        sta sn_r+1              ; (N8+1)*256 / 2^s
        ldx sv
        lda ch_16,x
        jeq sf_8bit
        ; 16 bits: N + 7 = rcp * 7 * 2^s / 64
        lda sn_r
        sta sn_p
        lda sn_r+1
        sta sn_p+1
        lda #0
        sta sn_p+2
        ; *7 = *8 - *1
        ldy #3
sf_x8   asl sn_p
        rol sn_p+1
        rol sn_p+2
        dey
        bne sf_x8
        lda sn_p
        sec
        sbc sn_r
        sta sn_p
        lda sn_p+1
        sbc sn_r+1
        sta sn_p+1
        lda sn_p+2
        sbc #0
        sta sn_p+2
        ; shift by s - 6
        lda sn_s
        sec
        sbc #6
        beq sf_16d
        bcc sf_16r
        tay
sf_16l  asl sn_p
        rol sn_p+1
        rol sn_p+2
        dey
        bne sf_16l
        jmp sf_16d
sf_16r  eor #$FF
        clc
        adc #1
        tay
sf_16s  lsr sn_p+2
        ror sn_p+1
        ror sn_p
        dey
        bne sf_16s
sf_16d  ; too low (does not fit 16 bits): an octave up
        lda sn_p+2
        beq sf_16e
        lsr sn_p+2
        ror sn_p+1
        ror sn_p
        jmp sf_16d
sf_16e  lda sn_p
        sec
        sbc #7
        sta sn_p
        bcs sf_16f
        dec sn_p+1
sf_16f  lda sn_p
        sta AUDF1
        lda sn_p+1
        sta AUDF2
        lda #0
        sta AUDC1
        lda sn_c
        sta AUDC2
        ldx sv                  ; (sf_next expects nothing in X)
        jmp sf_next
sf_8bit ; 8 bits: N + 1 = rcp * 2^s / 256, octaves up while it is > 256
        lda sn_r
        sta sn_p
        lda sn_r+1
        sta sn_p+1
        lda #0
        sta sn_p+2
        ldy sn_s
        beq sf_8d
sf_8l   asl sn_p
        rol sn_p+1
        rol sn_p+2
        dey
        bne sf_8l
sf_8d   lda sn_p+2              ; N+1 must be <= 256: p < 65536
        beq sf_8e
        lsr sn_p+2
        ror sn_p+1
        ror sn_p
        jmp sf_8d
sf_8e   lda sn_p                ; N = round(p / 256) - 1
        clc
        adc #$80
        lda sn_p+1
        adc #0
        bcs sf_8max
        sec
        sbc #1
        jmp sf_8h
sf_8max lda #$FF
sf_8h   ldx sv
        ldy ch_f,x
        sta AUDF1,y
        lda sn_c
        sta AUDC1,y
sf_next inc sv
        lda sv
        cmp #3
        beq sf_done
        jmp sf_v
sf_done jmp gate_clear
sf_put  ldx sv
        lda ch_16,x
        beq sf_p8
        lda #0
        sta AUDC2
        sta AUDC1
        jmp sf_next
sf_p8   ldy ch_f,x
        lda #0
        sta AUDC1,y
        jmp sf_next
FIRST_VOICE = 2                 ; 0 when the music voices play too
voff    dta 0,7,14
ch_16   dta 0,0,1               ; voice on the 16-bit channel pair
ch_f    dta 2,4,6               ; else: AUDFx offset of its 8-bit channel
