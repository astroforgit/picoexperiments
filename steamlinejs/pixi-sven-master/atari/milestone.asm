; First researched milestone. Tuning is an adaptation, not original constants.
; Hold fire beside a sheep to fill four progress segments. A fresh fire press
; outside interaction range whistles, calming nearby sheep (two-second cooldown).
init_milestone
        lda #3
        sta lives
        lda #0
        sta points
        sta points+1
        sta world_tick
        sta invulnerable
        sta stun_ticks
        sta water_cooldown
        sta whistle_cooldown
        sta work_ticks
        sta battle_ticks
        sta patrol_target
        sta dog_clock
        sta dog_alert
        sta spawn_index
        sta speed_ticks
        sta shock_ticks
        sta shock_cooldown
        lda #1
        sta mushroom_alive
        sta mushroom_alive+1
        lda #255
        sta target
        sta previous_target
        lda #18
        sta enemy_x
        lda #82
        sta enemy_y
        lda #235
        sta enemy_x+1
        lda #48
        sta enemy_y+1
        ldx #7
init_mood
        lda sheep_home_x,x
        sta sheep_x,x
        sta pasture_x,x
        lda sheep_home_y,x
        sta sheep_y,x
        sta pasture_y,x
        txa
        and #3
        sta sheep_direction,x
        lda #0
        sta sheep_reaction,x
        sta devil_seconds,x
        lda initial_age,x
        sta sheep_age,x
        lda #0
        sta progress,x
        dex
        bpl init_mood
        rts

age_sheep
        ldx #7
age_loop
        lda alive,x
        cmp #1
        bne age_next
        lda devil_seconds,x
        beq age_normally
        dec devil_seconds,x
        bne age_next
        lda #20                    ; exhausted devils become approachable again
        sta sheep_age,x
        lda sheep_x,x
        sta pasture_x,x
        lda sheep_y,x
        sta pasture_y,x
        jmp age_next
age_normally
        inc sheep_age,x
        lda sheep_age,x
        cmp #52
        bcc age_next
        lda #52
        sta sheep_age,x
        lda #8
        sta devil_seconds,x
age_next
        dex
        bpl age_loop
        rts

update_protection
        lda fire_click_ticks
        beq click_window_done
        dec fire_click_ticks
click_window_done
        lda invulnerable
        beq no_protection
        dec invulnerable
no_protection
        lda stun_ticks
        beq no_stun
        dec stun_ticks
        lda #0
        sta moving
no_stun
        lda water_cooldown
        beq no_water_cooldown
        dec water_cooldown
no_water_cooldown
        lda whistle_cooldown
        beq no_whistle_cooldown
        dec whistle_cooldown
no_whistle_cooldown
        rts

; A/Y are a sprite's top-left; sample the center of its feet in the 1bpp map.
point_is_water
        clc
        adc #28
        sta foot_x
        lda #0
        rol
        sta foot_x+1
        tya
        clc
        adc #31
        tax
        lda water_row_lo,x
        sta src
        lda water_row_hi,x
        sta src+1
        lda foot_x
        and #7
        tax
        lda water_bits,x
        sta water_bit
        lda foot_x
        lsr
        lsr
        lsr
        ldx foot_x+1
        beq water_column
        ora #32
water_column
        tay
        lda (src),y
        and water_bit
        beq dry_ground
        sec
        rts
dry_ground
        clc
        rts

check_water
        lda water_cooldown
        bne water_done
        lda px
        ldy py
        jsr point_is_water
        bcc water_done
        lda world_tick
        eor px
        eor py
        and #3
        sta spawn_index
        jsr safe_spawn
        lda #50
        sta water_cooldown
        sta invulnerable
        lda #0
        sta work_ticks
        lda #12
        sta sound_ticks
        lda #100
        sta sound_pitch
water_done
        rts

; Fixed safe sites are spread far enough that two enemies cannot block all four.
safe_spawn
        inc spawn_index
        lda spawn_index
        and #3
        sta spawn_index
        tax
        lda spawn_x,x
        sta test_x
        lda spawn_y,x
        sta test_y
        ldx #1
spawn_check
        lda enemy_x,x
        sta other_x
        lda enemy_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        cmp #36
        bcs spawn_next
        lda distance_y
        cmp #24
        bcc safe_spawn
spawn_next
        dex
        bpl spawn_check
        lda test_x
        sta px
        lda test_y
        sta py
        rts

; Absolute axis distances, valid across the full unsigned world coordinate range.
distance_xy
        lda test_x
        sec
        sbc other_x
        bcs distance_x_positive
        eor #255
        adc #1
distance_x_positive
        sta distance_x
        lda test_y
        sec
        sbc other_y
        bcs distance_y_positive
        eor #255
        adc #1
distance_y_positive
        sta distance_y
        rts

update_enemies
        lda dog_alert
        beq dog_normal_clock
        dec dog_alert
dog_normal_clock
        inc dog_clock
        lda dog_clock
        cmp #150
        bcc dog_phase
        lda #0
        sta dog_clock
dog_phase
        ldx dog_alert
        bne dog_chase
        cmp #100                   ; pursue for two seconds, rest for one
        bcs shepherd
        lda world_tick
        and #1
        bne shepherd
dog_chase
        lda enemy_x
        sta saved_x
        lda enemy_y
        sta saved_y
        lda px
        sta goal_x
        lda py
        sta goal_y
        ldx #0
        jsr enemy_step
        lda enemy_x
        ldy enemy_y
        jsr point_is_water
        bcc shepherd
        lda saved_x
        sta enemy_x
        lda saved_y
        sta enemy_y
shepherd
        lda world_tick
        and #1
        bne enemies_done
        ldx patrol_target
        lda patrol_x,x
        sta goal_x
        lda patrol_y,x
        sta goal_y
        ldx #1
        jsr enemy_step
        lda enemy_x+1
        cmp goal_x
        bne enemies_done
        lda enemy_y+1
        cmp goal_y
        bne enemies_done
        inc patrol_target
        lda patrol_target
        and #3
        sta patrol_target
enemies_done
        rts

enemy_step
        lda enemy_x,x
        cmp goal_x
        beq enemy_face_vertical
        lda #2
        bcs enemy_face_store
        lda #3
        bne enemy_face_store
enemy_face_vertical
        lda enemy_y,x
        cmp goal_y
        beq enemy_facing_done
        lda #1
        bcs enemy_face_store
        lda #0
enemy_face_store
        sta enemy_direction,x
enemy_facing_done
        lda enemy_x,x
        cmp goal_x
        beq enemy_vertical
        bcs enemy_left
        inc enemy_x,x
        jmp enemy_vertical
enemy_left
        dec enemy_x,x
enemy_vertical
        cpx #0
        bne enemy_slow_vertical
        lda dog_alert
        beq enemy_slow_vertical
        lda world_tick
        and #1
        jmp enemy_vertical_ready
enemy_slow_vertical
        lda world_tick
        and #3
enemy_vertical_ready
        bne enemy_done
        lda enemy_y,x
        cmp goal_y
        beq enemy_done
        bcs enemy_up
        inc enemy_y,x
        rts
enemy_up
        dec enemy_y,x
enemy_done
        rts

; Gentle deterministic wandering, with individual phases and a home radius.
; Nearby sheep stop to face Sven, making sustained interaction predictable.
update_sheep
        ldx #7
sheep_step_loop
        stx sheep_index
        lda alive,x
        cmp #1
        jne sheep_step_next
        cpx previous_target
        jeq sheep_step_next
        lda sheep_age,x
        cmp #35
        jcs sheep_wander
        lda sheep_reaction,x
        beq sheep_distance
        dec sheep_reaction,x
        jsr face_sven
        jmp sheep_step_next
sheep_distance
        lda px
        sta test_x
        lda py
        sta test_y
        lda sheep_x,x
        sta other_x
        lda sheep_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        cmp #29
        bcs sheep_wander
        lda distance_y
        cmp #21
        bcs sheep_wander
        jsr face_sven
        jmp sheep_step_next
sheep_wander
        lda sheep_age,x
        cmp #52
        bcs devil_wander
        cmp #35
        bcs dark_wander
        lda world_tick
        and #7
        jmp sheep_walk_clock
dark_wander
        lda world_tick
        and #3
sheep_walk_clock
        jne sheep_step_next
        lda world_tick
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc sheep_index
        and #3
        sta sheep_direction,x
        jmp sheep_walk_direction
devil_wander
        lda world_tick
        and #1
        jne sheep_step_next
        jsr face_sven
        ; Brief sideways runs break up the otherwise direct pursuit.
        lda world_tick
        and #$30
        cmp #$30
        bne sheep_walk_direction
        txa
        and #3
        sta sheep_direction,x
sheep_walk_direction
        lda sheep_direction,x
        tay
        lda sheep_x,x
        sta saved_x
        clc
        adc wander_dx,y
        sta sheep_x,x
        lda sheep_y,x
        sta saved_y
        clc
        adc wander_dy,y
        sta sheep_y,x
        cmp #14
        bcc sheep_revert
        cmp #161
        bcs sheep_revert
        lda sheep_x,x
        cmp #10
        bcc sheep_revert
        cmp #251
        bcs sheep_revert
        sta test_x
        lda sheep_age,x
        cmp #52
        bcs sheep_check_water
        lda sheep_y,x
        sta test_y
        lda pasture_x,x
        sta other_x
        lda pasture_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        cmp #13
        bcs sheep_revert
        lda distance_y
        cmp #9
        bcs sheep_revert
sheep_check_water
        lda sheep_x,x
        ldy sheep_y,x
        jsr point_is_water
        ldx sheep_index
        bcc sheep_step_next
sheep_revert
        lda saved_x
        sta sheep_x,x
        lda saved_y
        sta sheep_y,x
sheep_step_next
        ldx sheep_index
        dex
        jpl sheep_step_loop
        rts

; Use the dominant axis, retaining the last facing at exact overlap.
face_sven
        lda px
        sta test_x
        lda py
        sta test_y
        lda sheep_x,x
        sta other_x
        lda sheep_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        ora distance_y
        beq facing_done
        lda distance_x
        cmp distance_y
        bcc face_vertical
        lda px
        cmp sheep_x,x
        lda #2
        bcc facing_store
        lda #3
        bne facing_store
face_vertical
        lda py
        cmp sheep_y,x
        lda #1
        bcc facing_store
        lda #0
facing_store
        sta sheep_direction,x
facing_done
        rts

find_target
        lda #255
        sta target
        sta best_distance
        lda px
        sta test_x
        lda py
        sta test_y
        ldx #7
find_loop
        lda alive,x
        cmp #1
        bne find_next
        lda sheep_age,x
        cmp #35                    ; dark clouds refuse interaction
        bcs find_next
        lda sheep_x,x
        sta other_x
        lda sheep_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        cmp #19
        bcs find_next
        lda distance_y
        cmp #13
        bcs find_next
        clc
        adc distance_x
        cmp best_distance
        bcs find_next
        sta best_distance
        stx target
find_next
        dex
        bpl find_loop
        rts

interact
        jsr find_target
        lda stun_ticks
        jne cancel_work
        lda whistle_pending
        jne try_whistle
        lda fire
        jeq cancel_work
        lda moving
        jne cancel_work
        ldx target
        jmi cancel_work
        cpx previous_target
        beq same_target
        stx previous_target
        lda direction
        lsr
        lsr
        sta sheep_direction,x
        lda #100
        sta dog_alert
        lda #0
        sta work_ticks
same_target
        lda #0
        sta fire_pending
        inc work_ticks
        lda sheep_age,x
        cmp #20
        lda #16                    ; sun: 1.28 sec; cloud: 1.92 sec
        bcc work_limit
        lda #24
work_limit
        cmp work_ticks
        bne interact_done
        lda #0
        sta work_ticks
        inc progress,x
        lda progress,x
        cmp #4
        bcc interact_done
        lda #2
        sta alive,x
        lda #255
        sta previous_target
        inc score
        ; 25 points and a two-second bonus, capped at 99 seconds.
        clc
        lda points
        adc #25
        sta points
        bcc points_done
        inc points+1
points_done
        lda seconds
        cmp #98
        bcs bonus_cap
        clc
        adc #2
        jmp bonus_store
bonus_cap
        lda #99
bonus_store
        sta seconds
        lda #12
        sta sound_ticks
        lda #60
        sta sound_pitch
        lda score
        cmp #8
        bne interact_done
        lda #MODE_WIN
        sta mode
        lda #30
        sta sound_ticks
        sta sound_pitch
        jsr refresh_message
interact_done
        rts
try_whistle
        lda whistle_pending
        beq cancel_work
        lda whistle_cooldown
        bne cancel_work
        lda #100
        sta whistle_cooldown
        lda #10
        sta sound_ticks
        lda #20
        sta sound_pitch
        ldx #7
whistle_loop
        lda alive,x
        cmp #1
        bne whistle_next
        lda sheep_x,x
        sta other_x
        lda sheep_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        cmp #70
        bcs whistle_next
        lda distance_y
        cmp #42
        bcs whistle_next
        lda sheep_age,x
        cmp #50                    ; lightning/devils cannot be whistled calm
        bcs whistle_next
        sec
        sbc #24
        bcs calm_store
        lda #0
calm_store
        sta sheep_age,x
        lda #75
        sta sheep_reaction,x
        jsr face_sven
whistle_next
        dex
        bpl whistle_loop
cancel_work
        lda #0
        sta work_ticks
        sta fire_pending
        sta whistle_pending
        lda #255
        sta previous_target
        rts

check_hazards
        lda invulnerable
        bne hazards_done
        lda px
        sta test_x
        lda py
        sta test_y
        ldx #1
hit_enemy
        lda enemy_x,x
        sta other_x
        lda enemy_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        cmp #14
        bcs hit_next_enemy
        lda distance_y
        cmp #10
        bcc enemy_contact
hit_next_enemy
        dex
        bpl hit_enemy
        ldx #7
hit_angry
        lda alive,x
        cmp #1
        bne hit_next_sheep
        lda sheep_age,x
        cmp #52
        bcc hit_next_sheep
        lda sheep_x,x
        sta other_x
        lda sheep_y,x
        sta other_y
        jsr distance_xy
        lda distance_x
        cmp #12
        bcs hit_next_sheep
        lda distance_y
        cmp #8
        jcc electrical_hit
hit_next_sheep
        dex
        bpl hit_angry
hazards_done
        rts
enemy_contact
        lda px
        sta battle_x
        lda py
        sta battle_y
        lda #42
        sta battle_ticks
        jmp take_hit
take_hit
        lda mode
        cmp #MODE_PLAY
        bne hazards_done
        dec lives
        lda #0
        sta shock_ticks
        sta speed_ticks
        lda #20
        sta sound_ticks
        lda #170
        sta sound_pitch
        lda #0
        sta work_ticks
        sta fire_pending
        sta whistle_pending
        lda #255
        sta previous_target
        lda lives
        beq no_lives
        jsr safe_spawn
        lda #100
        sta invulnerable
        lda #20
        sta stun_ticks
        jmp refresh_message
no_lives
        lda #MODE_LOSE
        sta mode
        jmp refresh_message

lives dta 3
points dta a(0)
world_tick dta 0
invulnerable dta 0
stun_ticks dta 0
water_cooldown dta 0
whistle_cooldown dta 0
work_ticks dta 0
target dta 255
previous_target dta 255
spawn_index dta 0
spawn_x dta 120,80,200,45
spawn_y dta 65,120,90,75
initial_age dta 0,4,8,2,12,6,14,10
sheep_age :8 dta 0
progress :8 dta 0
enemy_x dta 18,235
enemy_y dta 82,48
enemy_direction dta 3,2
dog_clock dta 0
patrol_target dta 0
patrol_x dta 235,65,65,235
patrol_y dta 48,48,135,135
goal_x dta 0
goal_y dta 0
saved_x dta 0
saved_y dta 0
test_x dta 0
test_y dta 0
other_x dta 0
other_y dta 0
distance_x dta 0
distance_y dta 0
foot_x dta a(0)
water_bit dta 0
water_bits dta $80,$40,$20,$10,$08,$04,$02,$01
water_row_lo :200 dta <(water_map+#*40)
water_row_hi :200 dta >(water_map+#*40)
water_map ins 'generated/water-mask.bin'

; Battle effect stays at the contact site while Sven respawns.
battle_ticks dta 0
battle_x dta 0
battle_y dta 0
sheep_home_x dta 30,95,185,232,55,165,20,205
sheep_home_y dta 44,56,42,78,101,101,138,135
sheep_direction :8 dta 0
sheep_reaction :8 dta 0
sheep_index dta 0
wander_dx dta 0,0,255,1
wander_dy dta 1,255,0,0

dog_alert dta 0

pasture_x :8 dta 0
pasture_y :8 dta 0
