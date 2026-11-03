; Bait lifecycle. Timers count PAL VBIs, not rendering updates.
bite_vblank
        lda state
        cmp #5
        bne bite_clock_done
        lda popup_active
        ora bite_loading
        bne bite_clock_done
        inc bite_phase
        lda bite_timer
        ora bite_timer+1
        beq bite_clock_done
        lda bite_timer
        bne bite_clock_low
        dec bite_timer+1
bite_clock_low
        dec bite_timer
bite_clock_done
        rts

; A is a percentage. C clear = success. Uniform 0..99 via rejection;
; a nonzero 255-state LFSR supplies each accepted result exactly twice.
chance_percent
        sta bite_chance
chance_retry
        jsr random_byte
        cmp #201
        bcs chance_retry
        sec
        sbc #1
        cmp #100
        bcc chance_compare
        sbc #100
chance_compare
        cmp bite_chance
        rts

new_wait
        lda #5
        sta state
        lda #$ff
        sta caught
        jmp quiet_start
quiet_start
        lda #1
        sta bite_loading
        lda #0
        sta bite_stage
        sta bite_phase
        sta tilt
        jsr random_byte
        sec
        sbc #1
quiet_modulo
        cmp #QUIET_CHOICES
        bcc quiet_index
        sbc #QUIET_CHOICES
        jmp quiet_modulo
quiet_index
        tax
        lda quiet_time_lo,x
        sta bite_timer
        lda quiet_time_hi,x
        sta bite_timer+1
        lda #0
        sta bite_loading
        jmp bite_place

; A = 1..5 scenario index. Use only while bait remains.
scenario_start
        pha
        lda #1
        sta bite_loading
        pla
        sta bite_stage
        tax
        lda scenario_time_lo,x
        sta bite_timer
        lda scenario_time_hi,x
        sta bite_timer+1
        lda #0
        sta bite_phase
        sta bite_loading
        jmp bite_place
lose_bait
        lda #0
        sta bait_present
        sta bite_stage
        sta bite_timer
        sta bite_timer+1
        jmp bite_place

waiting
; Expiry wins over a late input: a dive is catchable for only its timed window.
        lda bait_present
        beq bite_check_strike
        lda bite_timer
        ora bite_timer+1
        bne bite_check_strike
        lda bite_stage
        beq bite_choose
        tax
        lda scenario_missed,x
        jsr chance_percent
        bcc bite_lost
        lda bite_stage
        cmp #1
        bne bite_quiet
        lda #ESCALATION_PERCENT
        jsr chance_percent
        bcs bite_quiet
        lda #2
        jsr scenario_start
        jmp bite_check_strike
bite_quiet
        jsr quiet_start
        jmp bite_check_strike
bite_lost
        jsr lose_bait
        jmp bite_check_strike
bite_choose
        jsr random_byte
        and #63
        tax
        lda scenario_pick,x
        jsr scenario_start
bite_check_strike
        lda press_edge
        bne bite_strike
        jmp bite_place
bite_strike
        lda bait_present
        beq start_reel
        ldx bite_stage
        lda scenario_catch,x
        jsr chance_percent
        bcs bite_failed
        lda #0
        sta caught
        sta bait_present
        jmp start_reel
bite_failed
        ldx bite_stage
        lda scenario_failed,x
        jsr chance_percent
        bcs start_reel
        lda #0
        sta bait_present
start_reel
        lda #0
        sta tilt
        lda #REEL_HOME_X
        sta goal_x
        lda #REEL_HOME_Y
        sta goal_y
        jsr aim
        lda #16
        sta phase
        lda #3
        sta state
        rts

bite_place
        lda base_x
        sta float_x
        lda base_y
        sta float_y
        lda #0
        sta tilt
        lda bait_present
        beq bite_place_done
        lda bite_stage
        beq bite_place_done
        cmp #2
        beq bite_place_done ; whole float is clipped in draw_float
        cmp #5
        beq bite_sideways
        lda bite_phase
        lsr
        lsr
        lsr
        and #7
        tax
        lda float_x
        clc
        adc gentle_sway,x
        sta float_x
        lda bite_stage
        cmp #4
        beq bite_place_done ; false alarm: sway only
        lda bite_phase
        and #31
        cmp #20
        bcc bite_place_done
        inc float_y
bite_place_done
        rts
bite_sideways
        lda bite_phase
        lsr
        lsr
        lsr
        and #7
        clc
        adc float_x
        sta float_x
        inc float_y
        rts
gentle_sway dta 0,0,1,1,0,0,255,255
bait_present dta 1
bite_stage dta 0
bite_timer dta a(0)
bite_phase dta 0
bite_loading dta 0
bite_chance dta 0
bobber_waterline dta 0
