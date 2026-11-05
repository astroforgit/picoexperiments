; Bait lifecycle. Timers count PAL VBIs, not rendering updates.
bite_vblank
        lda popup_active
        ora bite_loading
        bne dive_clock_done
        lda state
        cmp #STATE_GAME_OVER
        beq dive_clock_done
        cmp #4
        beq dive_clock_done
        cmp #7
        bcs dive_clock_done
        lda dive_timer
        ora dive_timer+1
        beq dive_clock_done
        lda dive_timer
        bne dive_clock_low
        dec dive_timer+1
dive_clock_low
        dec dive_timer
dive_clock_done
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
        lda interest_bonus
        beq quiet_loaded
        lda #<FOLLOWUP_FRAMES
        sta bite_timer
        lda #>FOLLOWUP_FRAMES
        sta bite_timer+1
quiet_loaded
        lda #0
        sta bite_loading
        jmp bite_place

; A = 1..7 scenario index. Use only while bait remains.
scenario_start
        cmp #2
        bne scenario_allowed
        pha
        lda dive_timer
        ora dive_timer+1
        beq dive_allowed
        pla
        jmp quiet_start
dive_allowed
        pla
scenario_allowed
        pha
        lda #1
        sta bite_loading
        pla
        sta bite_stage
        cmp #2
        bne scenario_load_time
        lda #<DIVE_INTERVAL_FRAMES
        sta dive_timer
        lda #>DIVE_INTERVAL_FRAMES
        sta dive_timer+1
        lda #2
scenario_load_time
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
        jsr bite_place
        lda worms_spare
        bne lost_bait_done
        jmp game_over_enter
lost_bait_done
        rts

waiting
; Expiry wins over a late input: a dive is catchable for only its timed window.
        lda bait_present
        bne bite_check_timer
        jmp bite_check_strike
bite_check_timer
        lda bite_timer
        ora bite_timer+1
        beq bite_expired
        jmp bite_check_strike
bite_expired
        lda bite_stage
        beq bite_choose
        tax
        lda scenario_missed,x
        jsr pressure_chance
        jsr chance_percent
        bcc bite_lost
        lda bite_stage
        cmp #1
        beq build_interest
        cmp #3
        beq build_interest
        cmp #5
        bcc bite_quiet
build_interest
        lda interest_bonus
        cmp #50
        bcs interest_built
        clc
        adc #INTEREST_STEP
        cmp #51
        bcc interest_store
        lda #50
interest_store
        sta interest_bonus
interest_built
        lda dive_timer
        ora dive_timer+1
        bne bite_quiet
        lda #ESCALATION_PERCENT
        jsr pressure_chance
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
        lda state
        cmp #STATE_GAME_OVER
        bne bite_check_strike
        rts
bite_choose
        ldx difficulty
        lda activity_chance,x
        jsr chance_percent
        bcc bite_activity
        jmp quiet_start
bite_activity
        lda interest_bonus
        beq bite_normal_choice
        lda #REPEAT_TAKE_PERCENT
        jsr pressure_chance
        jsr chance_percent
        bcs bite_normal_choice
        jsr random_byte
        and #1
        beq repeat_gentle
        lda #5
        bne repeat_start
repeat_gentle
        lda #1
repeat_start
        jsr scenario_start
        jmp bite_check_strike
bite_normal_choice
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
        jsr difficulty_catch
        jsr chance_percent
        bcs bite_failed
        lda #0
        sta caught
        sta bait_present
        jmp start_reel
bite_failed
        ldx bite_stage
        lda scenario_failed,x
        jsr pressure_chance
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
        cmp #6
        beq bite_repeated
        cmp #7
        beq bite_heavy
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
bite_repeated
        lda bite_phase
        lsr
        lsr
        and #7
        tax
        lda float_x
        clc
        adc gentle_sway,x
        sta float_x
        lda repeat_dip,x
        clc
        adc float_y
        sta float_y
        rts
bite_heavy
        lda bite_phase
        lsr
        lsr
        lsr
        and #7
        tax
        lda heavy_sway,x
        clc
        adc float_x
        sta float_x
        lda repeat_dip,x
        clc
        adc float_y
        sta float_y
        rts
repeat_dip dta 0,1,2,1,0,1,2,1
heavy_sway dta 0,2,3,2,0,254,253,254
gentle_sway dta 0,0,1,1,0,0,255,255
bait_present dta 1
bite_stage dta 0
bite_timer dta a(0)
bite_phase dta 0
bite_loading dta 0
bite_chance dta 0
bobber_waterline dta 0

; Repeated interest raises risk and aggression by five percentage points.
; Zero remains zero (quiet water and false alarms never consume a worm).
pressure_chance
        cmp #0
        beq pressure_done
        clc
        adc interest_bonus
        cmp #101
        bcc pressure_done
        lda #100
pressure_done
        rts

; Switching bait at home swaps the attached worm back into its own stock.
equip_worm
        tax
        lda state
        ora popup_active
        bne equip_done
        lda worm_stock,x
        beq equip_done
        lda bait_present
        beq equip_empty
        cpx worm_type
        beq equip_done
        ldy worm_type
        lda worm_stock,y
        clc
        adc #1
        sta worm_stock,y
        dec worm_stock,x
        stx worm_type
        rts
equip_empty
        dec worm_stock,x
        dec worms_spare
        stx worm_type
        lda #1
        sta bait_present
        lda #0
        sta interest_bonus
        lda #$ff
        sta caught
equip_done
        rts
worms_spare dta 4
worm_stock dta 2,2
worm_type dta 0
interest_bonus dta 0

; Replace only lost/consumed bait; fall back to the other type if exhausted.
auto_rebait
        lda bait_present
        bne rebait_done
        lda worms_spare
        beq rebait_done
        ldx worm_type
        lda worm_stock,x
        bne rebait_type_ready
        txa
        eor #1
        tax
        lda worm_stock,x
        beq rebait_done
rebait_type_ready
        dec worm_stock,x
        dec worms_spare
        stx worm_type
        lda #1
        sta bait_present
rebait_done
        rts
dive_timer dta a(DIVE_INTERVAL_FRAMES)

; Difficulty changes probabilities only, not clocks or physical movement.
activity_chance dta 100,75,40
difficulty_catch
        ldx difficulty
        cpx #1
        beq difficulty_catch_done
        cpx #2
        bne difficulty_easy
        lsr
        rts
difficulty_easy
        sta catch_base
        lsr
        lsr
        clc
        adc catch_base
        cmp #101
        bcc difficulty_catch_done
        lda #100
difficulty_catch_done
        rts
catch_base dta 0
