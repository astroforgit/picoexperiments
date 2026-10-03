; ------------------------------------------------------------------
; PICO-8 sfx/music player on POKEY, run from the vertical blank
; (adapted from the Celeste and Lich King ports).  The four PICO-8
; channels map to the four POKEY channels.  Requests from the game go
; through a small queue that the vertical blank empties.  One PICO-8 sfx
; speed unit is 183/22050 s; snd_addl/h is that many units per frame (8.8).
; Sound effect data (64 x 68 bytes at SFXDATA): 32 notes of 2 bytes
; (pitch | $40 for noise, volume | effect << 4), speed, loop start, loop end.
; ------------------------------------------------------------------
SQN     = 8
RQ_SFX  = 1
RQ_STOP = 2
RQ_MUS  = 3

sound_init
        lda snd_add
        sta snd_addl
        lda #2
        sta snd_addh
        lda #0
        sta AUDCTL
        ldx #7
si_clr  sta AUDF1,x
        dex
        bpl si_clr
        lda #3
        sta SKCTL
        ldx #3
si_ch   lda #0
        sta ch_on,x
        sta ch_pitch,x
        sta ch_mus,x
        lda #$ff
        sta ch_sfx,x
        dex
        bpl si_ch
        lda #0
        sta mus_on
        sta sq_head
        sta sq_tail
        rts

; ---------------------------------------------------------- requests
; queue a request: A = type, X = channel, Y = number; sq_off = offset
sq_put  pha
        stx sq_t
        lda sq_head
        clc
        adc #1
        and #SQN-1
        cmp sq_tail
        beq sq_full
        pla
        ldx sq_head
        sta sq_ty,x
        tya
        sta sq_n,x
        lda sq_t
        sta sq_ch,x
        lda sq_off
        sta sq_of,x
        lda #0
        sta sq_off
        txa
        clc
        adc #1
        and #SQN-1
        sta sq_head
        rts
sq_full pla
        rts
sq_t    dta 0
sq_off  dta 0
sq_head dta 0
sq_tail dta 0

; sfx(A, X) on channel X (keeps nothing)
sfx_ch  tay
        lda #RQ_SFX
        jmp sq_put
; sfx(A, X, Y): with a start offset (notes)
sfx_full
        sty sq_off
        tay
        lda #RQ_SFX
        jmp sq_put
; sfx(-1, A): stop channel A
sfx_stop
        tax
        ldy #0
        lda #RQ_STOP
        jmp sq_put
; music(A): A = $ff stops (keeps X, Y)
music   .if PLAY_MUSIC
        stx mu_x
        sty mu_y
        tay
        ldx #0
        lda #RQ_MUS
        jsr sq_put
        ldx mu_x
        ldy mu_y
        .endif
        rts
mu_x    dta 0
mu_y    dta 0

; kl(n): play sfx n on channel 2 or 3 if its priority is high enough
; (keeps X, Y)
kl      stx kl_x
        sty kl_y
        sta kl_n
        lda o_
        bne kl_d
        ; dl2, dl3 = qz[stat(18)+2], qz[stat(19)+2]
        ldx ch_sfx+2
        inx                 ; $ff -> 0
        lda qz,x
        sta kl_2
        ldx ch_sfx+3
        inx
        lda qz,x
        sta kl_3
        ; ch = dl2 < dl3 and 2 or 3; min = min(dl2, dl3)
        ldx #3
        lda kl_3
        cmp kl_2
        bcc kl_m            ; dl3 < dl2: min dl3, ch 3
        beq kl_m
        ldx #2
        lda kl_2
kl_m    sta kl_mn
        ldy kl_n
        lda qz+1,y
        cmp kl_mn
        bcc kl_d
        lda kl_n
        jsr sfx_ch
kl_d    ldx kl_x
        ldy kl_y
        rts
kl_x    dta 0
kl_y    dta 0
kl_n    dta 0
kl_2    dta 0
kl_3    dta 0
kl_mn   dta 0

; ---------------------------------------------------------- VBI
sound_tick
st_q    lda sq_tail
        cmp sq_head
        beq st_qd
        tax
        lda sq_ty,x
        cmp #RQ_SFX
        bne st_q1
        lda sq_of,x
        sta snd_off
        lda sq_n,x
        pha
        lda sq_ch,x
        tax
        pla
        jsr sfx_start
        jmp st_qn
st_q1   cmp #RQ_STOP
        bne st_q2
        lda sq_ch,x
        tax
        lda #0
        sta ch_on,x
        lda #$ff
        sta ch_sfx,x
        jmp st_qn
st_q2   lda sq_n,x
        cmp #$ff
        bne st_ms
        jsr music_stop
        jmp st_qn
st_ms   sta mus_pat
        sta mus_loop
        lda #1
        sta mus_on
        jsr pattern_start
st_qn   lda sq_tail
        clc
        adc #1
        and #SQN-1
        sta sq_tail
        jmp st_q
st_qd   lda #0
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
snd_off dta 0

music_stop
        lda #0
        sta mus_on
        ldx #3
ms_l    lda ch_mus,x
        beq ms_n
        lda #0
        sta ch_on,x
        sta ch_mus,x
ms_n    dex
        bpl ms_l
        rts

; sound effect A on channel X (from note snd_off)
sfx_start
        pha
        sta ch_sfx,x
        lda #0
        sta ch_mus,x
        pla
        jmp chan_start

; X = channel, A = sfx number; starts at note snd_off
chan_start
        tay
        lda sfx_lo,y
        sta ch_pl,x
        sta snd_p
        lda sfx_hi,y
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
        lda snd_off
        and #31
        sta ch_note,x
        lda #0
        sta snd_off
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
        lda #$ff
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
        ldy #8
stm_l   lsr snd_t+1
        bcc stm_s
        clc
        adc snd_t
stm_s   ror
        ror snd_t+3
        dey
        bne stm_l
        sta snd_t+2
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
        sta snd_t+4
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

; start music pattern mus_pat on its enabled channels (not on channels
; playing a sound effect)
pattern_start
        lda mus_pat
        asl
        asl
        sta snd_t+5
        tay
        lda MUSDATA,y
        bpl ps_1
        lda mus_pat
        sta mus_loop
ps_1    lda #$ff
        sta ch_lead
        sta snd_t+6
        ldx #0
ps_ch   stx snd_t+7
        lda snd_t+5
        clc
        adc snd_t+7
        tay
        lda MUSDATA,y
        and #$40
        beq pst_on
        lda ch_mus,x
        beq pst_next
        lda #0
        sta ch_on,x
        sta ch_mus,x
        jmp pst_next
pst_on   lda ch_sfx,x
        cmp #$ff
        bne pst_next         ; a sound effect has the channel
        lda #1
        sta ch_mus,x
        lda MUSDATA,y
        and #$3f
        jsr chan_start
        ldx snd_t+7
        lda snd_t+6
        bpl ps_2
        stx snd_t+6
ps_2    lda ch_lead
        bpl pst_next
        lda ch_le,x
        cmp ch_ls,x
        beq ps_lead
        bcs pst_next
ps_lead stx ch_lead
pst_next ldx snd_t+7
        inx
        cpx #4
        bne ps_ch
        lda snd_t+6
        bpl ps_3
        ; no channel free: keep the pattern timing on a silent leader
        lda #0
        sta mus_cnt
        lda #32
        sta mus_len
        rts
ps_3    lda ch_lead
        bpl ps_4
        lda snd_t+6
        sta ch_lead
ps_4    ldx ch_lead
        lda ch_le,x
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
        lda MUSDATA+1,y
        bpl pn_1
        lda mus_loop
        sta mus_pat
        jmp pattern_start
pn_1    lda MUSDATA+2,y
        bpl pn_2
        jmp music_stop
pn_2    inc mus_pat
        lda mus_pat
        cmp #64
        bcc pn_3
        jmp music_stop
pn_3    jmp pattern_start
