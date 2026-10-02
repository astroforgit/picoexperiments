; Two independent POKEY instruments on voices 3/4. Original Porter score;
; per-VBL volume shaping and restrained vibrato inspired by HK_PLAY.ASM.
; No AUDCTL changes: effects on voices 1/2 keep their tuning and priority.
music_update
        lda sound_enabled
        beq music_silent
        lda game_mode
        cmp #MODE_END
        beq music_silent
        lda music_tick
        beq music_next_note
        dec music_tick
        jmp music_instruments
music_silent
        lda #0
        sta audc3
        sta audc4
        rts
music_next_note
        ldx music_pattern
        lda music_ch0_lo,x
        sta music_ptr
        lda music_ch0_hi,x
        sta music_ptr+1
        lda music_row
        asl
        tay
        lda (music_ptr),y
        sta music_pitch
        iny
        lda (music_ptr),y
        sta music_volume
        lda music_ch1_lo,x
        sta music_ptr
        lda music_ch1_hi,x
        sta music_ptr+1
        dey
        lda (music_ptr),y
        sta music_pitch+1
        iny
        lda (music_ptr),y
        sta music_volume+1
        ; PICO speed 16 = 1/8 second: 6,6,6,7 PAL VBLs per note.
        lda music_row
        and #3
        cmp #3
        lda #5
        adc #0
        sta music_tick
        inc music_row
        lda music_row
        cmp #32
        bne music_instruments
        lda #0
        sta music_row
        inc music_pattern
        lda music_pattern
        and #15
        sta music_pattern
music_instruments
        lda music_pitch
        sta audf3
        lda music_tick
        and #2
        lsr
        clc
        adc music_pitch+1
        sta audf4                  ; a one-divider vibrato on the soft lead
        ldx #0
        jsr music_envelope
        sta audc3
        inx
        jsr music_envelope
        sta audc4
        rts
music_envelope
        lda music_volume,x
        beq @music_envelope_done
        ldy music_tick
        cpy #3
        bcs @music_envelope_tone
        sec
        sbc #1                     ; leave breathing space at each note tail
@music_envelope_tone
        ora #$a0
@music_envelope_done
        rts
