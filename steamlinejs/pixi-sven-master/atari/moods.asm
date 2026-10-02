; Additional mechanics from the supplied notes; explicit adaptation tuning.
update_effects
        lda shock_cooldown
        beq effect_shock
        dec shock_cooldown
effect_shock
        lda shock_ticks
        beq effect_speed
        dec shock_ticks
        bne effect_speed
        jsr refresh_message
effect_speed
        lda speed_ticks
        beq effects_done
        dec speed_ticks
        bne effects_done
        jsr refresh_message
effects_done
        rts

electrical_hit
        lda mode
        cmp #MODE_PLAY
        bne effects_done
        lda shock_cooldown
        bne effects_done
        lda #100
        sta stun_ticks
        sta shock_ticks
        lda #125
        sta shock_cooldown
        lda points
        sec
        sbc #10
        bcs shock_points
        lda #0
shock_points
        sta points
        lda #20
        sta sound_ticks
        lda #210
        sta sound_pitch
        lda #0
        sta work_ticks
        sta moving
        sta fire_pending
        sta whistle_pending
        lda #255
        sta previous_target
        ; No life loss, teleport, or enemy protection: enemies remain dangerous.
        jmp refresh_message

check_mushrooms
        lda mode
        cmp #MODE_PLAY
        bne mushrooms_done
        lda px
        sta test_x
        lda py
        sta test_y
        ldx #1
mushroom_loop
        lda mushroom_alive,x
        beq mushroom_next
        lda mushroom_x,x
        sta other_x
        lda mushroom_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        cmp #12
        bcs mushroom_next
        lda distance_y
        cmp #8
        bcs mushroom_next
        lda #0
        sta mushroom_alive,x
        cpx #1
        beq foul_mushroom
        lda #250
        sta speed_ticks
        lda #12
        sta sound_ticks
        lda #35
        sta sound_pitch
        jsr refresh_message
mushroom_next
        dex
        bpl mushroom_loop
mushrooms_done
        rts
foul_mushroom
        ldx #7
odor_loop
        lda alive,x
        cmp #1
        bne odor_next
        lda sheep_x,x
        sta other_x
        lda sheep_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        cmp #70
        bcs odor_next
        lda distance_y
        cmp #42
        bcs odor_next
        lda sheep_age,x
        cmp #50
        bcs odor_next
        lda #50
        sta sheep_age,x
        lda #0
        sta sheep_reaction,x
odor_next
        dex
        bpl odor_loop
        lda #15
        sta sound_ticks
        lda #150
        sta sound_pitch
        jmp cancel_work

speed_ticks dta 0
shock_ticks dta 0
shock_cooldown dta 0
devil_seconds :8 dta 0
mushroom_alive dta 1,1
mushroom_x dta 105,225
mushroom_y dta 90,115
shocked_message dta d'SHOCKED! -10 POINTS / WATCH THE DOG!    '
boost_message dta d'SPEED BOOST! / DOUBLE FIRE TO WHISTLE  '
