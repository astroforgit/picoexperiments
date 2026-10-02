; Native Atari rules: four scrolling stages, three encounters per stage.
restart
        lda #0
        sta stage
        sta wave
        sta points
        sta tick
        sta fraction
        sta muted
        lda #$5d
        sta ai_random
        lda #3
        sta lives
        lda #PLAY
        sta mode
        jsr new_stage
        lda $14
        sta last_clock
        rts
new_stage
        jsr world_init
        lda #90
        sta seconds
        lda #0
        sta second_ticks
        sta wave
        jsr new_wave
        jmp respawn
new_wave
        lda #255
        sta grab_target
        ldx #2
spawn_enemy
        lda spawn_x,x
        sta enemy_x,x
        lda spawn_y,x
        sta enemy_y,x
        lda #0
        sta enemy_stun,x
        sta enemy_pose,x
        sta enemy_state,x
        sta enemy_reacted,x
        sta enemy_counter,x
        lda #4
        sta enemy_face,x
        lda spawn_delay,x
        sta enemy_cool,x
        txa
        and #1
        clc
        adc #1
        sta enemy_type,x
        lda wave
        cmp #2
        bne normal_enemy
        cpx #2
        bne normal_enemy
        lda #3
        sta enemy_type,x
normal_enemy
        lda enemy_type,x
        asl
        asl
        sta ai_index
        lda stage
        clc
        adc ai_index
        tay
        lda enemy_health_table,y
enemy_health
        sta enemy_hp,x
        dex
        bpl spawn_enemy
        lda #3
        sta remaining
        lda #45
        sta banner_ticks
        rts
respawn
        jsr release_grab
        lda #20
        sta px
        lda #174
        sta py
        lda #12
        sta health
        lda #0
        sta attack
        sta jump
        sta facing
        sta player_stun
        sta jump_cool
        lda #60
        sta immune
        rts

input
        lda $d300
        and #15
        sta stick
        lda $d010
        eor #1
        and #1
        sta fire
        lda #255
        sta key
        lda $d20f
        and #4
        bne keys_done
        lda $d209
        and #63
        sta key
        cmp #63
        bne key_d
        lda stick
        and #11
        sta stick
key_d   lda key
        cmp #58
        bne key_w
        lda stick
        and #7
        sta stick
key_w   lda key
        cmp #46
        bne key_s
        lda stick
        and #14
        sta stick
key_s   lda key
        cmp #62
        bne key_space
        lda stick
        and #13
        sta stick
key_space
        lda key
        cmp #33
        bne keys_done
        lda #1
        sta fire
keys_done
        lda #255
        sta $2fc
        lda fire
        eor old_fire
        and fire
        sta pressed
        lda fire
        sta old_fire
        lda key
        cmp old_key
        bne fresh_key
        lda #255
fresh_key
        sta key_edge
        lda key
        sta old_key
        lda $d01f
        and #7
        sta console
        eor #7
        and old_console
        sta console_edge
        lda console
        sta old_console
        lda key_edge
        cmp #40                   ; R
        beq input_restart
        lda console_edge
        and #1                    ; START
        beq input_pause
input_restart
        jmp restart
input_pause
        lda key_edge
        cmp #10                   ; P
        beq toggle_pause
        lda console_edge
        and #2
        beq input_mute
toggle_pause
        lda mode
        cmp #PLAY
        bne try_resume
        lda #PAUSE
        sta mode
        jmp input_mute
try_resume
        cmp #PAUSE
        bne input_mute
        lda #PLAY
        sta mode
input_mute
        lda key_edge
        cmp #37                   ; M
        beq toggle_mute
        lda console_edge
        and #4
        beq input_mode
toggle_mute
        lda muted
        eor #1
        sta muted
input_mode
        lda mode
        cmp #PLAY
        beq input_done
        cmp #PAUSE
        beq input_done
        lda pressed
        beq input_done
        jmp restart
input_done
        rts

; Thirty simulation ticks per second, independent of PAL/NTSC display rate.
; Present waits for VBL. A maximum four elapsed VBLs prevents long stalls
; (e.g. emulator pause) from applying a burst of unobserved player movement.
frame_time
        lda $14
        sec
        sbc last_clock
        beq time_done
        cmp #5
        bcc elapsed_ok
        lda #4
elapsed_ok
        sta elapsed
        lda $14
        sta last_clock
time_loop
        clc
        lda fraction
        adc #30
        sta fraction
        cmp rate
        bcc next_elapsed
        sec
        sbc rate
        sta fraction
        lda mode
        cmp #PLAY
        bne silent_tick
        jsr update
        jsr sound
        jmp next_elapsed
silent_tick
        lda #0
        sta $d201
        sta $d203
next_elapsed
        dec elapsed
        bne time_loop
time_done
        rts

update
        inc tick
        ; Deterministic LFSR: enemies make independent, reproducible choices.
        lda ai_random
        lsr
        bcc ai_random_ready
        eor #$b8
ai_random_ready
        sta ai_random
        lda banner_ticks
        beq no_banner_tick
        dec banner_ticks
no_banner_tick
        lda immune
        beq no_immune_tick
        dec immune
no_immune_tick
        lda jump_cool
        beq no_jump_cool
        dec jump_cool
no_jump_cool
        lda jump
        beq no_jump_tick
        dec jump
        bne no_jump_tick
        lda #8
        sta jump_cool
no_jump_tick
        inc second_ticks
        lda second_ticks
        cmp #30
        bcc timer_ok
        lda #0
        sta second_ticks
        dec seconds
        bne timer_ok
        jsr lose_life
        lda #90
        sta seconds
        rts
timer_ok
        lda #0
        sta moving
        lda player_stun
        beq player_can_act
        dec player_stun
        jmp enemy_update
player_can_act
        lda attack
        beq can_move
        dec attack
        lda jump
        bne can_move
        jmp action_input
can_move
        lda stick
        and #4
        bne move_right
        lda #4
        sta facing
        lda fire
        beq left_translate
        lda jump
        beq move_right
left_translate
        lda px
        cmp #4
        bcc move_right
        dec px
        dec px
        inc moving
move_right
        lda stick
        and #8
        bne move_vertical
        lda #0
        sta facing
        lda fire
        beq right_translate
        lda jump
        beq move_vertical
right_translate
        lda px
        cmp #252
        bcs move_vertical
        inc px
        inc px
        inc moving
move_vertical
        lda fire
        bne action_input
        lda stick
        and #1
        bne move_down
        lda py
        cmp #133
        bcc move_down
        dec py
        inc moving
move_down
        lda stick
        and #2
        bne action_input
        lda py
        cmp #191
        bcs action_input
        inc py
        inc moving
action_input
        lda attack
        bne attack_tick
        lda fire
        beq enemy_update
        lda jump
        jne enemy_update       ; one attack per jump, no airborne re-trigger
        lda stick
        and #1
        bne choose_attack
        lda jump_cool
        jne enemy_update       ; landing recovery closes the infinite-jump exploit
        lda #22
        sta jump
        lda #2
        bne start_attack
choose_attack
        lda stick
        and #2
        bne choose_ground_attack
        lda #3
        bne start_attack
choose_ground_attack
        lda stick
        and #12
        cmp #12
        beq start_punch
        lda #1
        bne start_attack
start_punch
        lda #0
start_attack
        sta attack_kind
        lda #0
        ldx #2
reset_reactions
        sta enemy_reacted,x
        dex
        bpl reset_reactions
        lda attack_kind
        tay
        lda attack_duration,y
        sta attack
        lda #5
        sta fx_ticks
        lda attack_kind
        cmp #3
        bne attack_tick
        jsr try_grab
attack_tick
        lda attack
        cmp #8
        bne enemy_update
        jsr player_hit
enemy_update
        lda mode
        cmp #PLAY
        jne update_done
        lda #0
        sta entity
enemy_loop
        ldx entity
        lda enemy_hp,x
        jeq next_enemy
        lda enemy_stun,x
        beq enemy_active
        dec enemy_stun,x
        jmp next_enemy
enemy_active
        lda #0
        sta enemy_pose,x
        lda enemy_state,x
        cmp #8
        jeq enemy_held
        cmp #5
        jeq enemy_fall
        cmp #6
        jeq enemy_down
        cmp #7
        jeq enemy_rise
        cmp #1
        jeq enemy_windup
        cmp #2
        jeq enemy_recover
        cmp #3
        jeq enemy_guard
        cmp #4
        jeq enemy_dodge
        lda enemy_cool,x
        beq enemy_decide
        dec enemy_cool,x
enemy_decide
        jsr distances
        lda px
        cmp enemy_x,x
        bcc face_left
        lda #0
        beq save_enemy_face
face_left
        lda #4
save_enemy_face
        sta enemy_face,x
        ; React only to the visible start of a frontal swing, not its hit.
        lda enemy_cool,x
        bne enemy_approach
        lda attack
        cmp #9
        bcc enemy_approach
        lda dx
        cmp #48
        bcs enemy_approach
        lda dy
        cmp #14
        bcs enemy_approach
        lda enemy_face,x
        cmp facing
        beq enemy_approach     ; cannot block a hit from behind
        lda enemy_reacted,x
        bne enemy_approach
        inc enemy_reacted,x    ; one decision per swing, not a roll every tick
        lda ai_random
        eor entity
        and #3
        bne enemy_approach
        lda enemy_type,x
        cmp #2
        beq choose_dodge
        cmp #3
        beq enemy_approach     ; Abobo presses forward instead of blocking
        lda #3
        sta enemy_state,x
        lda #0
        sta enemy_counter,x
        ; Hold through this swing's impact (attack == 8), plus two ticks.
        lda attack
        sec
        sbc #6
        sta enemy_cool,x
        jmp next_enemy
choose_dodge
        lda #4
        sta enemy_state,x
        lda #8
        sta enemy_cool,x
        jmp next_enemy
enemy_approach
        lda py
        sta ai_target_y
        ; One opponent tries to get behind Billy on a separate depth lane.
        ; At the left edge it approaches normally rather than getting stuck.
        cpx #1
        bne enemy_lane
        lda px
        cmp #26
        bcc enemy_lane
        lda enemy_x,x
        clc
        adc #10
        bcs enemy_flank
        cmp px
        bcc enemy_lane
enemy_flank
        lda py
        cmp #169
        bcs flank_up
        clc
        adc #20
        bne flank_target
flank_up
        sec
        sbc #20
flank_target
        sta ai_target_y
        jsr enemy_depth_step
        jsr distances
        lda dy
        cmp #14
        jcc next_enemy
        lda enemy_x,x
        cmp #5
        jcc next_enemy
        dec enemy_x,x
        jmp next_enemy
enemy_lane
        lda dx
        cmp #60
        bcc approach_depth
        lda py
        clc
        adc approach_lane,x
        cmp #133
        bcs lane_bottom
        lda #133
lane_bottom
        cmp #191
        bcc lane_save
        lda #190
lane_save
        sta ai_target_y
approach_depth
        jsr enemy_depth_step
        jsr distances
        ldy enemy_type,x
        lda dx
        cmp enemy_reach,y
        bcc enemy_try_attack
        ; Abobo is slower, Linda occasionally takes an extra step.
        cpy #3
        bne enemy_step
        lda tick
        and #3
        jeq next_enemy
enemy_step
        jsr enemy_horizontal_step
        ldy enemy_type,x
        cpy #2
        jne next_enemy
        lda tick
        and #3
        jne next_enemy
        jsr enemy_horizontal_step
        jmp next_enemy
enemy_try_attack
        lda dy
        cmp #9
        jcs next_enemy
        lda enemy_cool,x
        jne next_enemy
        lda #1
        sta enemy_state,x
        lda enemy_startup,y
        sta enemy_cool,x
        lda #2
        sta enemy_pose,x
        jmp next_enemy
enemy_windup
        lda #2
        sta enemy_pose,x
        dec enemy_cool,x
        jne next_enemy
        ; Attack direction is committed. Leaving the lane or crossing behind
        ; the attacker makes it miss; there is no tracking at impact time.
        lda #2
        sta enemy_state,x
        ldy enemy_type,x
        lda enemy_miss_recovery,y
        sta enemy_cool,x
        jsr distances
        lda dy
        cmp #9
        jcs next_enemy
        lda dx
        cmp enemy_reach,y
        jcs next_enemy
        lda px
        cmp enemy_x,x
        bcc impact_left
        lda enemy_face,x
        jne next_enemy
        jmp impact_check
impact_left
        lda enemy_face,x
        jeq next_enemy
impact_check
        lda immune
        jne next_enemy
        ; Only the high portion of the jump evades a grounded strike.
        lda jump
        cmp #6
        bcc enemy_damage
        cmp #18
        jcc next_enemy
enemy_damage
        jsr release_grab       ; another enemy can break Billy's hold
        lda enemy_recovery,y
        sta enemy_cool,x       ; connecting attacks recover sooner than misses
        lda health
        sec
        sbc enemy_damage_table,y
        bcc enemy_lethal
        beq enemy_lethal
        sta health
        lda #14
        sta immune
        lda #8
        sta player_stun
        sta fx_ticks
        lda #0
        sta attack
        sta jump
        lda #8
        sta jump_cool
        ; Knock Billy away without wrapping at a screen edge.
        lda enemy_face,x
        bne knock_player_left
        lda px
        clc
        adc #6
        bcc knock_player_right_limit
        lda #252
knock_player_right_limit
        cmp #253
        bcc knock_player_save
        lda #252
        bne knock_player_save
knock_player_left
        lda px
        sec
        sbc #6
        bcs knock_player_save
        lda #0
knock_player_save
        sta px
        jmp next_enemy
enemy_lethal
        lda #0
        sta health
        jsr lose_life
        jmp update_done        ; never let other enemies hit a new life this tick
enemy_recover
        dec enemy_cool,x
        jne next_enemy
        lda #0
        sta enemy_state,x
        jmp next_enemy
enemy_guard
        lda #2
        sta enemy_pose,x
        dec enemy_cool,x
        jne next_enemy
        lda enemy_counter,x
        beq guard_finished
        lda #0
        sta enemy_counter,x
        ; A real block earns a counter, but never track a player crossing behind.
        jsr distances
        lda dy
        cmp #9
        bcs guard_finished
        ldy enemy_type,x
        lda dx
        cmp enemy_reach,y
        bcs guard_finished
        lda px
        cmp enemy_x,x
        bcc counter_left
        lda enemy_face,x
        bne guard_finished
        beq counter_ready
counter_left
        lda enemy_face,x
        beq guard_finished
counter_ready
        lda #0
        sta enemy_cool,x
        jmp enemy_try_attack  ; full species windup, never instant damage
guard_finished
        lda #0
        sta enemy_state,x
        lda #12
        sta enemy_cool,x
        jmp next_enemy
enemy_dodge
        lda py
        cmp enemy_y,x
        bcc dodge_down
        lda #133
        bne dodge_target
dodge_down
        lda #190
dodge_target
        sta ai_target_y
        jsr enemy_depth_step
        dec enemy_cool,x
        jne next_enemy
        lda #0
        sta enemy_state,x
        lda #6
        sta enemy_cool,x
next_enemy
        inc entity
        lda entity
        cmp #3
        jne enemy_loop
        jmp world_update
update_done
        rts

enemy_depth_step
        lda ai_target_y
        cmp enemy_y,x
        beq depth_done
        bcc depth_up
        inc enemy_y,x
        rts
depth_up
        dec enemy_y,x
depth_done
        rts
enemy_horizontal_step
        lda enemy_face,x
        beq step_right
        lda enemy_x,x
        beq step_done
        dec enemy_x,x
        rts
step_right
        lda enemy_x,x
        cmp #252
        bcs step_done
        inc enemy_x,x
step_done
        rts

; X identifies the enemy. Keep directional and depth checks independent.
distances
        lda px
        sec
        sbc enemy_x,x
        bcs positive_dx
        eor #255
        clc
        adc #1
positive_dx
        sta dx
        lda py
        sec
        sbc enemy_y,x
        bcs positive_dy
        eor #255
        clc
        adc #1
positive_dy
        sta dy
        rts
; Knockdown states: 5 falling, 6 prone, 7 getting up.
; Facing is locked toward the hitter; recoil travels in the other direction.
enemy_fall
        lda #3
        sta enemy_pose,x
        lda enemy_face,x
        beq fall_left
        lda enemy_x,x
        cmp #251
        bcs fall_right_edge
        clc
        adc #2
        jmp fall_position
fall_right_edge
        lda #252
        bne fall_position
fall_left
        lda enemy_x,x
        cmp #6
        bcc fall_left_edge
        sec
        sbc #2
        jmp fall_position
fall_left_edge
        lda #4
fall_position
        sta enemy_x,x
        dec enemy_cool,x
        jne next_enemy
        lda #6
        sta enemy_state,x
        lda #22
        sta enemy_cool,x
        jmp next_enemy
enemy_down
        lda #3
        sta enemy_pose,x
        dec enemy_cool,x
        jne next_enemy
        lda #7
        sta enemy_state,x
        lda #10
        sta enemy_cool,x
        jmp next_enemy
enemy_rise
        lda #1
        sta enemy_pose,x
        dec enemy_cool,x
        jne next_enemy
        lda #0
        sta enemy_state,x
        sta enemy_pose,x
        lda #6
        sta enemy_cool,x
        jmp next_enemy
enemy_held
        lda #2
        sta enemy_pose,x
        jmp next_enemy

; Down + fire: capture the closest vulnerable lightweight in front.
try_grab
        lda #255
        sta grab_target
        lda #19
        sta grab_distance
        ldx #2
grab_scan
        lda enemy_hp,x
        beq grab_next
        lda enemy_type,x
        cmp #3
        beq grab_next
        lda enemy_state,x
        cmp #5
        bcs grab_next
        lda enemy_stun,x
        bne grab_range
        lda enemy_state,x
        cmp #2
        bne grab_next
grab_range
        jsr distances
        lda dy
        cmp #9
        bcs grab_next
        lda dx
        cmp grab_distance
        bcs grab_next
        cmp #0
        beq grab_select
        lda px
        cmp enemy_x,x
        bcc grab_right
        lda facing
        beq grab_next
        bne grab_select
grab_right
        lda facing
        bne grab_next
grab_select
        stx grab_target
        lda dx
        sta grab_distance
grab_next
        dex
        bpl grab_scan
        ldx grab_target
        bmi grab_done
        lda #8
        sta enemy_state,x
        lda #2
        sta enemy_pose,x
        lda #0
        sta enemy_stun,x
        sta enemy_counter,x
grab_done
        rts

; Preserve the attacking enemy's X and Y when interrupted.
release_grab
        txa
        pha
        ldx grab_target
        bmi release_done
        lda enemy_state,x
        cmp #8
        bne release_done
        lda #2
        sta enemy_state,x
        lda #6
        sta enemy_cool,x
        lda #0
        sta enemy_pose,x
release_done
        lda #255
        sta grab_target
        pla
        tax
        rts

throw_hit
        ldx grab_target
        bmi grab_done
        lda #255
        sta grab_target
        lda enemy_state,x
        cmp #8
        bne grab_done
        lda enemy_hp,x
        beq grab_done
        sec
        sbc #4
        jcc defeated
        jeq defeated
        sta enemy_hp,x
        ; Throw behind Billy; recoil continues away from his back.
        lda facing
        sta enemy_face,x
        beq throw_left
        lda px
        clc
        adc #18
        bcs throw_right_edge
        cmp #253
        bcc throw_position
throw_right_edge
        lda #252
        bne throw_position
throw_left
        lda px
        sec
        sbc #18
        bcc throw_left_edge
        cmp #4
        bcs throw_position
throw_left_edge
        lda #4
throw_position
        sta enemy_x,x
        lda py
        sta enemy_y,x
        lda #5
        sta enemy_state,x
        lda #6
        sta enemy_cool,x
        sta fx_ticks
        lda #3
        sta enemy_pose,x
        rts
player_hit
        lda attack_kind
        cmp #3
        jeq throw_hit
        ldx #2
hit_loop
        lda enemy_hp,x
        jeq hit_next
        lda enemy_stun,x
        jne hit_next
        lda enemy_state,x
        cmp #5
        jcs hit_next           ; no ground hits or get-up hit loops
        jsr distances
        lda dy
        cmp #13
        jcs hit_next
        lda facing
        bne hitting_left
        lda enemy_x,x
        cmp px
        jcc hit_next
        jmp hit_range
hitting_left
        lda px
        cmp enemy_x,x
        jcc hit_next
hit_range
        ldy attack_kind
        lda dx
        cmp reach,y
        jcs hit_next
        lda damage,y
        sta hit_damage
        lda enemy_state,x
        cmp #3
        bne unguarded_hit
        lda enemy_face,x
        cmp facing
        beq unguarded_hit
        cpy #2
        beq unguarded_hit      ; jump kick breaks a frontal guard
        cpy #0
        bne guard_chip
        lda #1
        sta enemy_counter,x   ; counter only after an actual blocked punch
        jmp hit_next
guard_chip
        lda #1
        sta hit_damage        ; grounded kick chips through the guard
unguarded_hit
        lda #7
        ldy enemy_type,x
        cpy #3
        bne save_hit_stun
        lda #3                ; bosses recover quickly but still take damage
save_hit_stun
        sta enemy_stun,x
        lda #0
        sta enemy_state,x
        sta enemy_counter,x
        lda #2
        sta enemy_cool,x
        lda #6
        sta fx_ticks
        lda enemy_hp,x
        sec
        sbc hit_damage
        beq defeated
        bcc defeated
        sta enemy_hp,x
        lda attack_kind
        cmp #2
        bne hit_next
        lda #0
        sta enemy_stun,x
        lda #5
        sta enemy_state,x
        lda #6
        sta enemy_cool,x
        lda #3
        sta enemy_pose,x
        lda facing
        eor #4
        sta enemy_face,x
        jmp hit_next
defeated
        lda #0
        sta enemy_hp,x
        sta enemy_state,x
        dec remaining
        inc points
        lda attack_kind
        cmp #3
        beq hit_done
hit_next
        dex
        jpl hit_loop
hit_done
        rts
lose_life
        jsr release_grab
        dec lives
        beq game_over
        jmp respawn
game_over
        lda #OVER
        sta mode
        rts

; Short combat effects only; background music is disabled.
sound
        lda #0
        sta $d201
        lda muted
        bne sound_off
        lda fx_ticks
        beq sound_off
        dec fx_ticks
        asl
        clc
        adc #8
        sta $d202
        lda #$88
        sta $d203
        rts
sound_off
        lda #0
        sta $d203
        rts

mode dta TITLE
stage dta 0
wave dta 0
points dta 0
lives dta 3
health dta 12
seconds dta 90
second_ticks dta 0
remaining dta 3
px dta 20
py dta 174
facing dta 0
moving dta 0
attack dta 0
attack_kind dta 0
grab_target dta 255
grab_distance dta 0
jump dta 0
jump_cool dta 0
player_stun dta 0
immune dta 0
tick dta 0
banner_ticks dta 0
enemy_x :3 dta 0
enemy_y :3 dta 0
enemy_type :3 dta 0
enemy_hp :3 dta 0
enemy_face :3 dta 0
enemy_pose :3 dta 0
enemy_stun :3 dta 0
enemy_cool :3 dta 0
enemy_state :3 dta 0
enemy_reacted :3 dta 0
enemy_counter :3 dta 0
; 0 approach, 1 committed windup, 2 recovery, 3 frontal guard, 4 sidestep.
; 5 fall, 6 down, 7 rise, 8 held by Billy (grab_target owns the slot).
ai_random dta $5d
ai_index dta 0
ai_target_y dta 0
hit_damage dta 0
spawn_delay dta 12,20,28
approach_lane dta 244,12,0
enemy_reach dta 0,27,33,31
enemy_startup dta 0,5,7,9
enemy_recovery dta 0,13,16,20
enemy_miss_recovery dta 0,19,22,26
enemy_damage_table dta 0,2,2,5
; Endurance tiers follow the supplied bank 6 table at $9389 (Williams,
; Linda and Abobo rows). Combat scheduling/damage are adaptation tuning.
enemy_health_table dta 0,0,0,0,8,12,16,20,8,12,16,20,32,38,38,38
spawn_x dta 225,180,250
spawn_y dta 158,183,138
reach dta 30,38,42
damage dta 1,2,3
attack_duration dta 12,16,16,18
dx dta 0
dy dta 0
stick dta 15
fire dta 0
old_fire dta 0
pressed dta 0
key dta 255
old_key dta 255
key_edge dta 255
console dta 7
old_console dta 7
console_edge dta 0
rate dta 50
fraction dta 0
last_clock dta 0
elapsed dta 0
muted dta 0
fx_ticks dta 0
