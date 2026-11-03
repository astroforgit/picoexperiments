; Night ambience. See tools/sounds.py and tools/samples.py.
; VBI (50 Hz): synthesised wind on channel 4 and, once a second, a roll to
; start a recorded clip. Timer 1 IRQ (63337/(PCM_AUDF+1) Hz): 4-bit samples in
; volume-only mode, clips on channel 2 and the recorded wind loop on channel 3.
; Channel 1 is the silent timer. Samples are packed high nibble first.
 ; Match the ATR's hardware reset ($5229): clear both POKEY banks.
; On a single-chip Atari the second bank mirrors the first, harmlessly.
sound_init
        lda #0
        ldx #8
sound_clear
        sta $d200,x
        sta $d210,x
        dex
        bpl sound_clear
        sta clip_on
        sta clip_byte
        sta irq_mask
        sta wind_phase
        sta wind_phase+1
        sta wind_wobble
        lda #3
        sta $d20f
        sta $d21f
        lda #50
        sta clip_clock
        lda #$5b
        sta sound_seed
        .if WIND_PCM
        mwa #WIND_START wind_ptr
        .endif
        rts
; Channel 1 is the silent sample timer: set its rate, enable and restart it.
pcm_on
        lda #PCM_AUDF
        sta $d200
        lda #1
        sta irq_mask
        sta $d20e
        sta $d209
        rts
sound_vblank
        .if SOUND_ENABLED
        .if WIND_PCM
; The recorded wind starts on the first VBI, leaving sound_init a pure reset.
        lda irq_mask
        bne wind_running
        jsr pcm_on
wind_running
        .endif
        .if WIND_SYNTH
        jsr wind_step
        .endif
        .if CLIP_COUNT
        dec clip_clock
        bne sound_done
        lda #50
        sta clip_clock
        lda clip_on
        bne sound_done
        .if WIND_PCM = 0
; Nothing to play: stop the timer so idle sound costs no CPU time.
        sta irq_mask
        sta $d20e
        .endif
        jsr sound_random
        ldx #0
clip_roll
        cmp clip_chance,x
        bcc clip_start
        inx
        cpx #CLIP_COUNT
        bne clip_roll
        .endif
        .endif
sound_done
        rts
; X = clip. The IRQ reads it through self-modified addresses.
clip_start
        lda clip_lo,x
        sta clip_ptr
        lda clip_hi,x
        sta clip_ptr+1
        lda clip_end_lo,x
        sta clip_end
        lda clip_end_hi,x
        sta clip_end+1
        lda #0
        sta clip_half
        lda #1
        sta clip_on
        jmp pcm_on

; Timer 1: one sample per stream per tick, high nibble then low nibble.
; Each stream keeps its own nibble phase, so a clip always starts complete.
irq
        pha
        lda #0
        sta $d20e
        lda irq_mask
        sta $d20e
        .if WIND_PCM
        lda wind_half
        eor #1
        sta wind_half
        beq wind_low
wind_ptr = *+1
        lda $ffff
        sta wind_byte
        lsr
        lsr
        lsr
        lsr
        ora #$10
        sta $d205
        jmp pcm_clip
wind_low
        lda wind_byte
        and #$0f
        ora #$10
        sta $d205
        inc wind_ptr
        bne wind_same_page
        inc wind_ptr+1
wind_same_page
        lda wind_ptr
        cmp #<WIND_END
        bne pcm_clip
        lda wind_ptr+1
        cmp #>WIND_END
        bne pcm_clip
        lda #<WIND_START
        sta wind_ptr
        lda #>WIND_START
        sta wind_ptr+1
pcm_clip
        .endif
        lda clip_on
        beq pcm_done
        lda clip_half
        eor #1
        sta clip_half
        beq clip_low
clip_ptr = *+1
        lda $ffff
        sta clip_byte
        lsr
        lsr
        lsr
        lsr
        ora #$10
        sta $d203
        pla
        rti
clip_low
        lda clip_byte
        and #$0f
        ora #$10
        sta $d203
        inc clip_ptr
        bne clip_same_page
        inc clip_ptr+1
clip_same_page
        lda clip_ptr
        cmp clip_end
        bne pcm_done
        lda clip_ptr+1
        cmp clip_end+1
        bne pcm_done
        lda #0
        sta clip_on
pcm_done
        pla
        rti
; Wind: walk the gust table at WIND_SPEED, add random flutter every 4 frames.
wind_step
        clc
        lda wind_phase
        adc #<WIND_SPEED
        sta wind_phase
        lda wind_phase+1
        adc #>WIND_SPEED
        sta wind_phase+1
        and #63
        tax
        lda frame
        and #3
        bne wind_out
        jsr sound_random
        and #15
wind_fit
        cmp #WIND_FLUTTER+1
        bcc wind_flutter_ready
        sbc #WIND_FLUTTER+1
        jmp wind_fit
wind_flutter_ready
        sta wind_wobble
wind_out
        lda wind_freq,x
        clc
        adc wind_wobble
        bcc wind_freq_ready
        lda #255
wind_freq_ready
        sta $d206
        lda wind_vol,x
        sta $d207
        rts
; Own LFSR: the VBI never disturbs fishing or sky randomness.
sound_random
        lda sound_seed
        asl
        bcc sound_random_done
        eor #$1d
sound_random_done
        sta sound_seed
        rts
clip_clock dta 50
clip_on dta 0
clip_byte dta 0
clip_end dta a(0)
wind_byte dta 0
wind_half dta 0
clip_half dta 0
irq_mask dta 0
wind_phase dta a(0)
wind_wobble dta 0
sound_seed dta $5b
