; Night audio. See tools/sounds.py and tools/samples.py.
; Random one-shots use channels 2-4 as a 46-level DAC, with the timer off
; during bounded silent pauses. They are stored in spare VBXE memory; the
; main loop copies the next one into a CPU RAM playback buffer during the
; pause (sound_load), so the IRQ never touches MEMAC. Legacy loop/synth
; modes keep their samples in CPU RAM.
; Channel 1 supplies the silent sample timer. Reset both POKEY banks.
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
        lda $d20a
        ora #1
        sta sound_seed
        .if CLIP_HQ
        jsr next_silence
        .endif
        .if AMBIENT_HQ
        ldx #0
        jsr ambient_set_chunk
        .else
        .if WIND_PCM
        mwa #WIND_START wind_ptr
        .endif
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
        lda sound_active
        beq sound_done
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
        .if CLIP_HQ
        lda clip_on
        beq clip_hq_idle
        lda irq_mask
        bne sound_done
        jmp pcm_on
; The pause holds at zero until sound_load has the chosen clip in RAM.
clip_hq_idle
        lda silence_left
        beq clip_hq_ready
        dec clip_clock
        bne sound_done
        lda #50
        sta clip_clock
        dec silence_left
        bne sound_done
clip_hq_ready
        lda load_state
        cmp #LOAD_READY
        bne sound_done
        jmp clip_hq_start
        .else
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
        .endif
sound_done
        rts
; X = clip. The IRQ reads it through self-modified addresses.
        .if CLIP_HQ
; Play the loaded clip from the start of the playback buffer.
clip_hq_start
        lda #LOAD_IDLE
        sta load_state
        ldx load_clip
        lda clip_end_lo,x
        sta clip_end
        lda clip_end_hi,x
        sta clip_end+1
        lda clip_last_seg,x
        sta clip_last
        ldx #0
        jsr clip_set_seg
        lda #1
        sta clip_on
        jmp pcm_on
; X = buffer segment. The last one stops at the clip's end, not its own.
clip_set_seg
        stx clip_seg
        lda #0
        sta clip_ptr
        lda seg_start_hi,x
        sta clip_ptr+1
        cpx clip_last
        beq clip_seg_last
        lda #0
        sta clip_limit_lo
        lda seg_end_hi,x
        sta clip_limit_hi
        rts
clip_seg_last
        lda clip_end
        sta clip_limit_lo
        lda clip_end+1
        sta clip_limit_hi
        rts
clip_seg dta 0
clip_last dta 0
        .elseif CLIP_COUNT
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
        .endif

; Timer 1: one sample per stream per tick, high nibble then low nibble.
; Each stream keeps its own nibble phase, so a clip always starts complete.
irq
        .if AMBIENT_HQ
        pha
        txa
        pha
        lda #0
        sta $d20e
        lda irq_mask
        sta $d20e
ambient_ptr = *+1
        ldx $ffff
        lda ambient_dac_0,x
        sta $d203
        lda ambient_dac_1,x
        sta $d205
        lda ambient_dac_2,x
        sta $d207
        inc ambient_ptr
        bne ambient_check_end
        inc ambient_ptr+1
ambient_check_end
        lda ambient_ptr
ambient_limit_lo = *+1
        cmp #0
        bne ambient_irq_done
        lda ambient_ptr+1
ambient_limit_hi = *+1
        cmp #0
        bne ambient_irq_done
        ldx ambient_chunk
        inx
        cpx #AMBIENT_CHUNKS
        bcc ambient_next_chunk
        ldx #0
ambient_next_chunk
        jsr ambient_set_chunk
ambient_irq_done
        pla
        tax
        pla
        rti
ambient_set_chunk
        stx ambient_chunk
        lda ambient_start_lo,x
        sta ambient_ptr
        lda ambient_start_hi,x
        sta ambient_ptr+1
        lda ambient_end_lo,x
        sta ambient_limit_lo
        lda ambient_end_hi,x
        sta ambient_limit_hi
        rts
ambient_chunk dta 0
        .elseif CLIP_HQ
        pha
        txa
        pha
        lda #0
        sta $d20e
        lda irq_mask
        sta $d20e
clip_ptr = *+1
        ldx $ffff
        lda ambient_dac_0,x
        sta $d203
        lda ambient_dac_1,x
        sta $d205
        lda ambient_dac_2,x
        sta $d207
        inc clip_ptr
        bne clip_hq_check
        inc clip_ptr+1
clip_hq_check
        lda clip_ptr
clip_limit_lo = *+1
        cmp #0
        bne clip_hq_done
        lda clip_ptr+1
clip_limit_hi = *+1
        cmp #0
        bne clip_hq_done
        ldx clip_seg
        cpx clip_last
        beq clip_hq_end
        inx
        jsr clip_set_seg
        jmp clip_hq_done
clip_hq_end
        lda #0
        sta clip_on
        sta irq_mask
        sta $d20e
        sta $d203
        sta $d205
        sta $d207
        jsr next_silence
clip_hq_done
        pla
        tax
        pla
        rti
        .else
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
        .endif
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

; Runtime preference survives a new night. Stop IRQs before clearing the DACs.
sound_toggle
        php
        sei
        lda sound_active
        eor #1
        sta sound_active
        bne sound_toggle_done
        lda #0
        sta irq_mask
        sta $d20e
        sta $d201
        sta $d203
        sta $d205
        sta $d207
sound_toggle_done
        plp
        rts
sound_active dta SOUND_ENABLED

; Select a bounded random silence after every one-shot, including startup.
        .if CLIP_HQ
; The next clip is chosen now, so sound_load can copy it during the pause.
next_silence
        jsr sound_random
        and #127
        cmp #SILENCE_RANGE
        bcs next_silence
        clc
        adc #SILENCE_MIN
        sta silence_left
        lda #50
        sta clip_clock
next_clip
        jsr sound_random
        and #CLIP_MASK
        cmp #CLIP_COUNT
        bcs next_clip
        sta load_clip
        lda #LOAD_REQUEST
        sta load_state
        rts
silence_left dta SILENCE_MIN
        .endif

; Main loop, while it waits for a frame: copy one 256-byte page of the chosen
; clip from VBXE memory into the playback buffer. Only runs during a pause
; (the IRQ is off) and never starts a page within ~40 lines of the vertical
; blank, so presenting a frame is not delayed. Leaves the MEMAC window off.
LOAD_IDLE = 0
LOAD_REQUEST = 1
LOAD_COPY = 2
LOAD_READY = 3
LOAD_LAST_VCOUNT = 104
sound_load
        .if CLIP_HQ
        lda load_state
        cmp #LOAD_REQUEST
        beq sound_load_begin
        cmp #LOAD_COPY
        beq sound_load_page
        rts
sound_load_begin
        ldx load_clip
        lda clip_bank_index,x
        sta load_bank_index
        lda clip_bank_page,x
        sta load_src
        lda clip_pages,x
        sta load_pages
        lda #0
        sta load_page
        lda #LOAD_COPY
        sta load_state
sound_load_page
        lda $d40b
        cmp #LOAD_LAST_VCOUNT
        bcc sound_load_now
        cmp #124
        bcc sound_load_done
sound_load_now
        ldx load_bank_index
        lda audio_banks,x
        ldy #$5f
        sta (vb),y
        ldx load_page
        lda buffer_pages,x
        sta load_dst
        ldy #0
sound_load_byte
load_src = *+2
        lda $9000,y
load_dst = *+2
        sta $ff00,y
        iny
        bne sound_load_byte
        tya
        ldy #$5f
        sta (vb),y
        inc load_page
        inc load_src
        lda load_src
        cmp #$a0
        bne sound_load_count
        lda #$90
        sta load_src
        inc load_bank_index
sound_load_count
        dec load_pages
        bne sound_load_done
        lda #LOAD_READY
        sta load_state
sound_load_done
        .endif
        rts
load_state dta LOAD_IDLE
load_clip dta 0
load_bank_index dta 0
load_page dta 0
load_pages dta 0
