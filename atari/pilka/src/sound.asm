; 50 Hz POKEY effects in spare space in the pause bank. Never changes MEMAC-B
; or zero-page pointers: safe from the resident VBI during rendering/pause.
        org $cd00
sound_tick
        lda menu_mode
        jne sound_menu
        lda league_screen
        jne sound_mute
        lda $97dc
        beq sound_whistle
        ldx effect_time
        beq sound_kick
        ldx effect_kind
        cpx #2
        beq sound_whistle
sound_kick
        lda #4
        sta effect_time
        lda #0
        sta effect_kind
        lda crowd_time
        bne sound_whistle
        lda #12
        sta crowd_time
sound_whistle
        lda $97de
        beq sound_goal
        cmp #4
        lda #20
        bcc whistle_length
        lda #50
whistle_length
        sta effect_time
        lda #2
        sta effect_kind
sound_goal
        lda sound_goal_pending
        beq sound_crowd
        lda #90
        sta crowd_time
sound_crowd
        ldx #CROWD_IDLE_VOLUME
        ldy #CROWD_IDLE_FREQUENCY
        lda crowd_time
        beq crowd_target
        dec crowd_time
        ldx #CROWD_ATTACK_VOLUME
        ldy #CROWD_ATTACK_FREQUENCY
        cmp #13
        bcc crowd_target
        cmp #40
        bcs crowd_goal_target
        ldx #CROWD_CELEBRATION_VOLUME
        ldy #CROWD_CELEBRATION_FREQUENCY
        bne crowd_target
crowd_goal_target
        ldx #CROWD_GOAL_VOLUME
        ldy #CROWD_GOAL_FREQUENCY
crowd_target
        lda frames
        and #3
        bne crowd_frequency
        cpx crowd_volume
        beq crowd_frequency
        bcc crowd_fade
        inc crowd_volume
        bne crowd_frequency
crowd_fade
        dec crowd_volume
crowd_frequency
        cpy crowd_freq
        beq crowd_output
        bcc crowd_lower
        inc crowd_freq
        bne crowd_output
crowd_lower
        dec crowd_freq
crowd_output
        lda crowd_freq
        sta $d202
        lda crowd_volume
        ora #$80
        sta $d203
        jmp sound_effect
sound_menu
        lda effect_kind
        cmp #1
        beq menu_clear_crowd
        lda #0
        sta effect_time
menu_clear_crowd
        lda #0
        sta crowd_time
        sta crowd_volume
        sta $d203
        lda #CROWD_IDLE_FREQUENCY
        sta crowd_freq
        lda joy1
        eor #$1f
        and #$1f
        tax
        eor sound_last_joy
        stx sound_last_joy
        and sound_last_joy
        beq sound_effect
        lda #1
        sta effect_kind
        lda #2
        sta effect_time
sound_effect
        lda #0
        sta $97dc
        sta $97de
        sta sound_goal_pending
        lda effect_time
        beq effect_silent
        dec effect_time
        ldx effect_kind
        beq kick_output
        cpx #1
        bne whistle_output
        lda #60
        sta $d200
        lda #$a3
        bne effect_output
kick_output
        clc
        asl
        asl
        asl
        asl
        adc #24
        sta $d200
        lda effect_time
        asl
        ora #$82
        bne effect_output
whistle_output
        lda frames
        and #2
        clc
        adc #15
        sta $d200
        lda effect_time
        cmp #20
        bcc whistle_tone
        and #8
        beq effect_silent
whistle_tone
        lda #$a8
        bne effect_output
effect_silent
        lda #0
effect_output
        sta $d201
        rts
sound_mute
        lda #0
        sta effect_time
        sta crowd_time
        sta crowd_volume
        sta $d201
        sta $d203
        sta $97dc
        sta $97de
        sta sound_goal_pending
        rts
effect_kind dta 0
effect_time dta 0
crowd_time dta 0
crowd_volume dta 0
crowd_freq dta CROWD_IDLE_FREQUENCY
sound_last_joy dta 0
