; ------------------------------------------------------------------
; PICO-8 sfx/music player on POKEY, run from the vertical blank
; (from the Celeste port).  Music uses the channels its patterns
; enable; a sound effect takes channel 3 or 2 when free, else 3.
; sfx(A) and music(A) queue requests for the next vertical blank.  One PICO-8 sfx "speed" unit is
; 183/22050 s; snd_addl/h is that many units per VBL in 8.8.
; ------------------------------------------------------------------


sound_init
        lda snd_add
        sta snd_addl
        lda #0
        sta AUDCTL
        ldx #7
si_clr  sta AUDF1,x
        dex
        bpl si_clr
        lda #3
        sta SKCTL
        ldx #3
        lda #0
si_ch   sta ch_on,x
        sta ch_pitch,x
        dex
        bpl si_ch
        sta mus_on
        lda #$ff
        sta sfx_q
        sta sfx_q+1
        lda #2
        sta snd_addh
        rts

sound_tick
        lda mus_req
        cmp #$ff
        beq st_nm
        ldx #$ff
        stx mus_req
        cmp #$fe
        bne st_ms
        jsr music_stop
        jmp st_nm
st_ms   sta mus_pat
        sta mus_loop
        lda #1
        sta mus_on
        jsr pattern_start
st_nm   lda sfx_q
        cmp #$ff
        beq st_s2
        ldx #$ff
        stx sfx_q
        jsr sfx_start
st_s2   lda sfx_q+1
        cmp #$ff
        beq st_ns
        ldx #$ff
        stx sfx_q+1
        jsr sfx_start
st_ns   lda #0
        sta pat_done
        ldx #0
st_adv  lda ch_on,x
        beq st_a1
        jsr chan_advance
st_a1   inx
        cpx #4
        bne st_adv
        lda pat_done
        beq st_out
        jsr pattern_next
st_out  ldx #0
st_o    jsr chan_output
        inx
        cpx #4
        bne st_o
        inc snd_frame
        rts

music_stop
        lda #0
        sta mus_on
        ldx #3
ms_l    lda ch_sfx,x
        bne ms_n
        sta ch_on,x
ms_n    dex
        bpl ms_l
        rts

; start sound effect A on a free channel (3, then 2), else on 3
sfx_start
        ldx #3
        ldy ch_on+3
        beq ss_go
        ldx #2
        ldy ch_on+2
        beq ss_go
        ldx #3
ss_go   pha
        lda #1
        sta ch_sfx,x
        pla
        jmp chan_start

; sfx(A): queue a sound effect (keeps X, Y)
sfx     pha
        lda sfx_q
        cmp #$ff
        bne sfx_2
        pla
        sta sfx_q
        rts
sfx_2   pla
        sta sfx_q+1
        rts

; music(A): the music is not played in this port (keeps X, Y)
music   rts

; X = channel, A = sfx number
chan_start
        tay
        lda sfx_ptr_lo,y
        sta ch_pl,x
        sta snd_p
        lda sfx_ptr_hi,y
        sta ch_ph,x
        sta snd_p+1
        ldy #64
        lda (snd_p),y
        sta ch_spd,x
        iny
        lda (snd_p),y
        sta ch_ls,x
        iny
        lda (snd_p),y
        sta ch_le,x
        lda #0
        sta ch_note,x
        sta ch_accl,x
        sta ch_acch,x
        lda #1
        sta ch_on,x
; fetch the current note of channel X
load_note
        lda ch_pitch,x
        sta ch_prev,x
        lda ch_pl,x
        sta snd_p
        lda ch_ph,x
        sta snd_p+1
        lda ch_note,x
        asl
        tay
        lda (snd_p),y
        pha
        and #$3f
        sta ch_pitch,x
        pla
        and #$40
        sta ch_noise,x
        iny
        lda (snd_p),y
        pha
        and #7
        sta ch_vol,x
        pla
        lsr
        lsr
        lsr
        lsr
        and #7
        sta ch_fx,x
        rts

chan_advance
        lda ch_accl,x
        clc
        adc snd_addl
        sta ch_accl,x
        lda ch_acch,x
        adc snd_addh
        sta ch_acch,x
ca_loop lda ch_acch,x
        cmp ch_spd,x
        bcc ca_done
        sbc ch_spd,x
        sta ch_acch,x
        ; the pattern leader counts notes
        lda mus_on
        beq ca_nl
        cpx ch_lead
        bne ca_nl
        inc mus_cnt
        lda mus_cnt
        cmp mus_len
        bcc ca_nl
        lda #1
        sta pat_done
ca_nl   inc ch_note,x
        lda ch_le,x
        cmp ch_ls,x
        beq ca_nolp
        bcc ca_nolp
        lda ch_note,x
        cmp ch_le,x
        bcc ca_ok
        lda ch_ls,x
        sta ch_note,x
        jmp ca_ok
ca_nolp lda ch_note,x
        cmp #32
        bcc ca_ok
        lda #0
        sta ch_on,x
        sta ch_sfx,x
        rts
ca_ok   jsr load_note
        jmp ca_loop
ca_done rts

; (A * elapsed) / speed for channel X -> A   (VBI scratch only)
scale_t sta snd_t
        lda ch_acch,x
        sta snd_t+1
        lda #0
        sta snd_t+2         ; product hi
        ldy #8
stm_l   lsr snd_t+1
        bcc stm_s
        clc
        adc snd_t
stm_s   ror
        ror snd_t+3
        dey
        bne stm_l
        sta snd_t+2         ; product = snd_t+2:snd_t+3
        ; divide by speed
        lda #0
        ldy #16
std_l   asl snd_t+3
        rol snd_t+2
        rol
        cmp ch_spd,x
        bcc std_s
        sbc ch_spd,x
        inc snd_t+3
std_s   dey
        bne std_l
        lda snd_t+3
        rts

chan_output
        txa
        asl
        sta snd_t+4         ; register offset
        lda ch_on,x
        bne co_on
        ldy snd_t+4
        lda #0
        sta AUDC1,y
        rts
co_on   lda ch_pitch,x
        sta snd_p
        lda ch_vol,x
        sta snd_p+1
        lda ch_fx,x
        cmp #1
        bne co_2
        ; slide from the previous pitch
        lda ch_pitch,x
        sec
        sbc ch_prev,x
        bcs co_1p
        lda ch_prev,x
        sec
        sbc ch_pitch,x
        jsr scale_t
        sta snd_t
        lda ch_prev,x
        sec
        sbc snd_t
        sta snd_p
        jmp co_out
co_1p   jsr scale_t
        clc
        adc ch_prev,x
        sta snd_p
        jmp co_out
co_2    cmp #3
        bne co_4
        ; drop
        lda ch_pitch,x
        jsr scale_t
        sta snd_t
        lda ch_pitch,x
        sec
        sbc snd_t
        sta snd_p
        jmp co_out
co_4    cmp #4
        bne co_5
        lda ch_vol,x
        jsr scale_t
        sta snd_p+1
        jmp co_out
co_5    cmp #5
        bne co_6
        lda ch_vol,x
        jsr scale_t
        sta snd_t
        lda ch_vol,x
        sec
        sbc snd_t
        sta snd_p+1
        jmp co_out
co_6    cmp #6
        bcc co_out
        ; arpeggio over the note's group of four
        ldy #1
        cmp #6
        beq co_6a
        ldy #2
co_6a   lda snd_frame
co_6b   lsr
        dey
        bne co_6b
        and #3
        sta snd_t
        lda ch_note,x
        and #$1c
        ora snd_t
        asl
        tay
        lda ch_pl,x
        sta snd_t+2
        lda ch_ph,x
        sta snd_t+3
        lda (snd_t+2),y
        and #$3f
        sta snd_p
co_out  ldy snd_p
        lda pitch_audf,y
        ldy ch_fx,x
        cpy #2
        bne co_nv
        ; vibrato: +-1.5%
        sta snd_t
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        sta snd_t+1
        lda snd_frame
        and #4
        beq co_vm
        lda snd_t
        clc
        adc snd_t+1
        jmp co_nv
co_vm   lda snd_t
        sec
        sbc snd_t+1
co_nv   ldy snd_t+4
        sta AUDF1,y
        lda snd_p+1
        asl
        ora #$a0
        ldy ch_noise,x
        beq co_pure
        and #$0f
        ora #$80
co_pure ldy snd_t+4
        sta AUDC1,y
        rts

; start music pattern mus_pat on its enabled channels
pattern_start
        lda mus_pat
        asl
        asl
        sta snd_t+5
        tay
        lda music_data,y
        bpl ps_1
        lda mus_pat
        sta mus_loop
ps_1    lda #$ff
        sta ch_lead
        sta snd_t+6         ; first enabled channel
        ldx #0
ps_ch   stx snd_t+7
        lda snd_t+5
        clc
        adc snd_t+7
        tay
        lda music_data,y
        and #$40
        beq ps_on
        lda ch_sfx,x
        bne ps_next
        lda #0
        sta ch_on,x
        jmp ps_next
ps_on   lda #0
        sta ch_sfx,x
        lda music_data,y
        and #$3f
        jsr chan_start
        ldx snd_t+7
        lda snd_t+6
        bpl ps_2
        stx snd_t+6
ps_2    lda ch_lead
        bpl ps_next
        lda ch_le,x
        cmp ch_ls,x
        beq ps_lead
        bcs ps_next
ps_lead stx ch_lead
ps_next ldx snd_t+7
        inx
        cpx #4
        bne ps_ch
        lda snd_t+6
        bpl ps_3
        jmp music_stop
ps_3    lda ch_lead
        bpl ps_4
        lda snd_t+6
        sta ch_lead
ps_4    ldx ch_lead
        lda #32
        ldy ch_le,x
        tya
        cmp ch_ls,x
        beq ps_5
        bcs ps_6
ps_5    lda #32
ps_6    sta mus_len
        lda #0
        sta mus_cnt
        rts

pattern_next
        lda mus_pat
        asl
        asl
        tay
        lda music_data+1,y
        bpl pn_1
        lda mus_loop
        sta mus_pat
        jmp pattern_start
pn_1    lda music_data+2,y
        bpl pn_2
        jmp music_stop
pn_2    inc mus_pat
        lda mus_pat
        cmp #64
        bcc pn_3
        jmp music_stop
pn_3    jmp pattern_start
