; ------------------------------------------------------------------
; Sound: POKEY effects and music in the VBI (data: gen/sound.asm)
;
; Four channels as the Amiga port uses them: 0 "other" (shield,
; explosion), 1 "kills", 2 "noise" (shots), 3 "loop". The two music
; voices play on channels 0 and 1 underneath the effects. Tables hold
; (AUDF, AUDC) per 1/50 s; NTSC skips every sixth frame.
; ------------------------------------------------------------------

snd_init
        lda #0
        ldx #3
si_1    sta s_on,x
        dex
        bpl si_1
        sta m_on
        sta snd_tog
        sta boss_cnt
        lda #6
        sta ntsc_cnt
        rts

; ---- VBI
snd_vbi lda is_pal
        bne sv_go
        dec ntsc_cnt
        bne sv_go
        lda #6
        sta ntsc_cnt
        rts
sv_go   ; music voices
        ldx #1
sv_m    lda #0
        sta m_c,x
        lda m_on
        beq sv_mn
        lda m_lo,x
        sta snd_vp
        lda m_hi,x
        sta snd_vp+1
        ldy #1
        lda (snd_vp),y
        sta m_c,x
        dey
        lda (snd_vp),y
        sta m_f,x
        cmp #$FF
        bne sv_madv
        lda m_c,x
        bne sv_madv
        sta m_on                ; end of the tune
        beq sv_mn
sv_madv lda m_lo,x
        clc
        adc #2
        sta m_lo,x
        bcc sv_mn
        inc m_hi,x
sv_mn   dex
        bpl sv_m
        ; effects
        ldx #3
sv_c    lda s_on,x
        beq sv_mus
sv_rd   lda s_lo,x
        sta snd_vp
        lda s_hi,x
        sta snd_vp+1
        ldy #0
        lda (snd_vp),y
        sta snd_f
        iny
        lda (snd_vp),y
        sta snd_c
        lda snd_f
        cmp #$FF
        bne sv_play
        lda snd_c
        bne sv_play
        lda s_loop,x            ; end of the effect
        beq sv_end
        lda s_slo,x
        sta s_lo,x
        lda s_shi,x
        sta s_hi,x
        jmp sv_rd
sv_end  lda #0
        sta s_on,x
        beq sv_mus
sv_play lda s_lo,x
        clc
        adc #2
        sta s_lo,x
        bcc sv_out
        inc s_hi,x
        bcs sv_out
sv_mus  lda #0
        sta snd_c
        cpx #2
        bcs sv_out
        lda m_on
        beq sv_out
        lda m_f,x
        sta snd_f
        lda m_c,x
        sta snd_c
sv_out  txa
        asl
        tay
        lda snd_f
        sta AUDF1,y
        lda snd_c
        sta AUDC1,y
        dex
        bpl sv_c
        rts

; ---- start sound A (main program)
snd_play
        cmp #SND_START_MUSIC
        beq sp_jeux
        cmp #SND_BOSS_END_MUSIC
        beq sp_elise
        tay
        ldx snd_ch,y
        lda s_on,x
        beq sp_ok
        lda snd_pri,y
        cmp s_pri,x
        bcc sp_r                ; a more important effect is playing
sp_ok   lda #0
        sta s_on,x
        lda snd_lo,y
        sta s_lo,x
        sta s_slo,x
        lda snd_hi,y
        sta s_hi,x
        sta s_shi,x
        lda snd_loop,y
        sta s_loop,x
        lda snd_pri,y
        sta s_pri,x
        tya
        sta s_id,x
        lda #1
        sta s_on,x
sp_r    ldy #0
        rts
sp_jeux ldx #0
        beq sp_mus
sp_elise
        ldx #4
sp_mus  cmp m_tune
        bne sp_m1
        ldy m_on
        bne sp_r                ; this tune is already playing
sp_m1   sta m_tune
        lda #0
        sta m_on
        lda tunes,x
        sta m_lo
        lda tunes+1,x
        sta m_hi
        lda tunes+2,x
        sta m_lo+1
        lda tunes+3,x
        sta m_hi+1
        lda #1
        sta m_on
        ldy #0
        rts
tunes   dta a(mus_jeux_a), a(mus_jeux_b), a(mus_elise_a), a(mus_elise_b)

snd_stop
        lda #0
        sta m_on
        ldx #3
ss_1    sta s_on,x
        dex
        bpl ss_1
        rts

; ------------------------------------------------------------------
; hooks called from the translated game code: all keep A, P, Y = 0
; ------------------------------------------------------------------
HOOK_IN .macro
        php
        pha
        .endm
HOOK_OUT .macro
        pla
        plp
        ldy #0
        rts
        .endm

; jsr hk_snd / dta id
hk_snd
        HOOK_IN
        tsx
        lda $0103,x
        sta snd_rp
        lda $0104,x
        sta snd_rp+1
        inc $0103,x             ; return past the id byte
        bne sh_1
        inc $0104,x
sh_1    ldy #1
        lda (snd_rp),y
        jsr snd_play
        HOOK_OUT

hk_stop
        HOOK_IN
        jsr snd_stop
        HOOK_OUT

hk_start
        HOOK_IN
        lda #0
        sta snd_tog
        lda #SND_START_MUSIC
        jsr snd_play
        HOOK_OUT

; the attack loop runs while birds attack (C = their number)
hk_attack
        HOOK_IN
        lda zC
        beq sa_off
        lda s_on+3
        beq sa_on
        lda s_id+3
        cmp #SND_ATTACK_LOOP
        beq sa_r
sa_on   lda #SND_ATTACK_LOOP
        jsr snd_play
sa_r    HOOK_OUT
sa_off  lda #0
        sta s_on+3
        HOOK_OUT

hk_vback
        HOOK_IN
        lda snd_tog
        eor #1
        sta snd_tog
        beq svb_2
        lda #SND_VULTURE_BACK_1
        bne svb_p
svb_2   lda #SND_VULTURE_BACK_2
svb_p   jsr snd_play
        HOOK_OUT

hk_bshield
        HOOK_IN
        lda snd_tog
        eor #1
        sta snd_tog
        beq sbs_2
        lda #SND_BOSS_SHIELD_SHOT_1
        bne sbs_p
sbs_2   lda #SND_BOSS_SHIELD_SHOT_2
sbs_p   jsr snd_play
        HOOK_OUT

hk_boss
        HOOK_IN
        inc boss_cnt
        lda boss_cnt
        cmp #6
        bne sbt_r
        lda #0
        sta boss_cnt
        lda #SND_BOSS
        jsr snd_play
sbt_r   HOOK_OUT

; A = extra life beep counter: a beep every 16 counts
hk_xlife
        HOOK_IN
        and #$0F
        bne sxl_r
        lda #SND_EXTRA_LIFE
        jsr snd_play
sxl_r   HOOK_OUT

; Don Hodges' fix (Amiga port): HL = $4380 (score) -> $4370 (first slot)
hook_hodges
        HOOK_IN
        lda zH
        cmp #$43
        bne hh_r
        lda zL
        cmp #$80
        bne hh_r
        lda #$70
        sta zL
hh_r    HOOK_OUT

; real-time high score (Amiga port): update_highscore after every score add
hook_hiscore
        HOOK_IN
        lda zL
        pha
        lda zH
        pha
        lda zE
        pha
        lda zD
        pha
        lda zC
        pha
        lda zB
        pha
        jsr z_02F0
        pla
        sta zB
        pla
        sta zC
        pla
        sta zD
        pla
        sta zE
        pla
        sta zH
        pla
        sta zL
        HOOK_OUT
