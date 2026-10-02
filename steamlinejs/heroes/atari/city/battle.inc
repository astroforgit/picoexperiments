.local battle
CELLS=42
COLS=7
MAX_UNITS=12
TEAM_HERO=0
TEAM_ENEMY=1
battle_data_resume equ *
        org $7000
        icl 'generated/battle-content.inc'
battle_data_end equ *
        ert battle_data_end>$8000
        org battle_data_resume
game_state dta 0
selected_unit dta 0
cursor_cell dta 0
unit_count dta 0
turn_number dta 1
region dta 0
contract dta 0
hero_count dta 0
init_index dta 0
reward dta a(0)
reward_committed dta 0
unit_type :12 dta 0
unit_team :12 dta 0
unit_cell :12 dta 0
unit_hp :12 dta 0
unit_acted :12 dta 0
unit_moved :12 dta 0
unit_move_left :12 dta 0
terrain :42 dta 0

.proc start
        jsr can_enter_battle
        bcs ?yes
        rts
?yes    mva #2 screen_mode
        mva #0 popup_open
        sta game_state
        sta unit_count
        sta reward_committed
        sta animation_active
        sta attack_flash
        sta attack_frame
        sta enemy_busy
        mva #255 click_unit
        mwa #0 reward
        mva #0 idle_next
        ldx #IDLE_CACHE_COUNT-1
?cache  mva #255 idle_ids,x
        dex
        bpl ?cache
        mva #1 turn_number
        ldx selected_location
        lda location_region,x
        sta region
        tax
        lda region_wins,x
        cmp #3
        bcc ?stage
        lda #2
?stage  sta contract
        lda region
        asl
        clc
        adc region
        clc
        adc contract
        sta contract
        ldx #41
?clear  mva #0 terrain,x
        dex
        bpl ?clear
        mva #1 terrain+10
        sta terrain+31
        ldx #11
?units  mva #0 unit_hp,x
        dex
        bpl ?units
        mva #0 init_index
?hero   ldx init_index
        lda army_units,x
        cmp #255
        beq ?next
        ldy deploy_cells,x
        ldx #0
        jsr add_unit
?next   inc init_index
        lda init_index
        cmp army_capacity
        bne ?hero
        mva unit_count hero_count
        ldx contract
        lda enemy_ptr_lo,x
        sta data_ptr
        lda enemy_ptr_hi,x
        sta data_ptr+1
        ldy #0
?enemy  lda (data_ptr),y
        cmp #255
        beq ?ready
        sta add_type
        iny
        lda (data_ptr),y
        sta add_cell
        iny
        tya
        pha
        lda add_type
        ldy add_cell
        ldx #1
        jsr add_unit
        pla
        tay
        jmp ?enemy
?ready  mva #0 selected_unit
        mva unit_cell cursor_cell
        mva #1 dirty
        rts
.endp
deploy_cells dta 0,7,14,21,28
add_type dta 0
add_cell dta 0

; A type, X team, Y cell
.proc add_unit
        sta add_type
        stx add_team
        sty add_cell
        ldx unit_count
        cpx #MAX_UNITS
        bcs ?full
        lda add_type
        sta unit_type,x
        tay
        lda add_team
        sta unit_team,x
        lda add_cell
        sta unit_cell,x
        lda type_hp,y
        sta unit_hp,x
        lda type_move,y
        sta unit_move_left,x
        lda #0
        sta unit_acted,x
        sta unit_moved,x
        inc unit_count
        txa
        sec
        rts
?full   clc
        rts
.endp
add_team dta 0

;==============================================================================
; Hex and occupancy helpers
;==============================================================================
target_cell dta 0
target_unit dta 0
lookup_cell dta 0
source_cell dta 0
test_cell   dta 0
test_dir    dta 0
test_cost   dta 0
action_move_cost dta 0

; A cell -> C set and X unit, or C clear.
.proc unit_at
        sta lookup_cell
        ldx #0
?loop   cpx unit_count
        bcs ?none
        lda unit_hp,x
        beq ?next
        lda unit_cell,x
        cmp lookup_cell
        beq ?found
?next   inx
        bne ?loop
?found  sec
        rts
?none   clc
        rts
.endp

; A cell -> C set when open.
.proc is_open
        cmp #CELLS
        bcs ?no
        sta lookup_cell
        tax
        lda terrain,x
        bne ?no
        lda lookup_cell
        jsr unit_at
        bcs ?no
        sec
        rts
?no     clc
        rts
.endp

; A source, X destination -> A distance.
.proc distance_cells
        tay
        lda distance_row_lo,y
        sta work_ptr
        lda distance_row_hi,y
        sta work_ptr+1
        txa
        tay
        lda (work_ptr),y
        and #127
        rts
.endp

.proc shot_clear
        jsr distance_cells
        lda (work_ptr),y
        and #128
        rts
.endp

; A cell, X direction -> A neighbour or FF.
.proc get_neighbour
        tay
        lda neighbour_row_lo,y
        sta work_ptr
        lda neighbour_row_hi,y
        sta work_ptr+1
        txa
        tay
        lda (work_ptr),y
        rts
.endp

; A target -> A cost 1/2 or FF. Uses selected unit and current move budget.
.proc move_cost
        sta target_cell
        jsr is_open
        bcc ?bad
        ldx selected_unit
        lda unit_cell,x
        sta source_cell
        ldx target_cell
        jsr distance_cells
        cmp #1
        beq ?one
        cmp #2
        bne ?bad
        ldx selected_unit
        lda unit_move_left,x
        cmp #2
        bcc ?bad
        lda #0
        sta test_dir
?mid   lda source_cell
        ldx test_dir
        jsr get_neighbour
        cmp #$FF
        beq ?next
        sta test_cell
        jsr is_open
        bcc ?next
        lda test_cell
        ldx target_cell
        jsr distance_cells
        cmp #1
        beq ?two
?next   inc test_dir
        lda test_dir
        cmp #6
        bcc ?mid
?bad    lda #$FF
        rts
?one    lda #1
        rts
?two    lda #2
        rts
.endp

; A cell -> A 0 invalid, 1 movement, 2 attack.
.proc action_at
        sta target_cell
        lda game_state
        bne ?none
        ldx selected_unit
        lda unit_acted,x
        bne ?none
        lda target_cell
        jsr unit_at
        bcc ?movement
        lda unit_team,x
        cmp #TEAM_ENEMY
        bne ?none
        stx target_unit
        ldx selected_unit
        lda unit_cell,x
        ldx target_cell
        jsr distance_cells
        sta test_cost
        ldx selected_unit
        ldy unit_type,x
        lda type_shoot_range,y
        bne ?shot_range
        lda #1
?shot_range
        cmp test_cost
        bcc ?none
        ldx selected_unit
        lda unit_cell,x
        ldx target_cell
        jsr shot_clear
        bne ?none
        lda #2
        rts
?movement
        ldx selected_unit
        lda unit_move_left,x
        beq ?none
        lda target_cell
        jsr move_cost
        cmp #$FF
        beq ?none
        sta test_cost
        ldx selected_unit
        lda unit_move_left,x
        cmp test_cost
        bcc ?none
        lda #1
        rts
?none   lda #0
        rts
.endp

.proc confirm_cell
        lda cursor_cell
        jsr action_at
        cmp #2
        beq ?attack
        cmp #1
        beq ?move
        rts
?attack ldx selected_unit
        stx attacker_unit
        ldx target_unit
        stx defender_unit
        jsr animate_attack
        jsr attack_units
        jsr check_result
        lda game_state
        bne ?done
        jsr finish_hero
        jmp check_result
?move   lda cursor_cell
        jsr move_cost
        sta action_move_cost
        ldx selected_unit
        stx animation_unit
        lda unit_cell,x
        sta animation_from
        lda cursor_cell
        sta animation_to
        jsr animate_move
        ldx selected_unit
        lda cursor_cell
        sta unit_cell,x
        lda #1
        sta unit_moved,x
        lda unit_move_left,x
        sec
        sbc action_move_cost
        sta unit_move_left,x
        bne ?done
        jmp finish_hero
?done   rts
.endp

.proc skip_hero
        mva #255 click_unit
        lda game_state
        bne ?done
        jmp finish_hero
?done   rts
.endp

.proc finish_hero
        ldx selected_unit
        lda #1
        sta unit_acted,x
        ldx #0
?scan   cpx unit_count
        bcs ?enemies
        lda unit_team,x
        bne ?next
        lda unit_hp,x
        beq ?next
        lda unit_acted,x
        beq ?select
?next   inx
        bne ?scan
?select stx selected_unit
        lda unit_cell,x
        sta cursor_cell
        rts
?enemies
        jsr enemy_phase
        rts
.endp

attacker_unit dta 0
defender_unit dta 0
animation_active dta 0
animation_unit   dta 0
animation_from   dta 0
animation_to     dta 0
animation_x      dta 0
animation_y      dta 0
animation_target_x dta 0
animation_target_y dta 0
attack_flash     dta 0
attack_flash_target dta 0
attack_frame     dta 0

.proc animate_move
        ldx animation_from
        lda cell_x_lo,x
        sta animation_x
        lda cell_y,x
        sta animation_y
        ldx animation_to
        lda cell_x_lo,x
        sta animation_target_x
        lda cell_y,x
        sta animation_target_y
        lda #1
        sta animation_active
        mva #0 animation_step
?frame  jsr draw
        lda animation_x
        cmp animation_target_x
        bne ?advance
        lda animation_y
        cmp animation_target_y
        beq ?done
?advance
        inc animation_step
        jsr advance_animation_position
        jmp ?frame
?done   lda #0
        sta animation_active
        rts
.endp

.proc advance_animation_position
        lda animation_x
        cmp animation_target_x
        beq ?vertical
        bcc ?x_add
        sec
        sbc animation_target_x
        cmp #9
        bcc ?x_set
        lda animation_x
        sec
        sbc #8
        sta animation_x
        jmp ?vertical
?x_add  lda animation_target_x
        sec
        sbc animation_x
        cmp #9
        bcc ?x_set
        lda animation_x
        clc
        adc #8
        sta animation_x
        jmp ?vertical
?x_set  lda animation_target_x
        sta animation_x

?vertical
        lda animation_y
        cmp animation_target_y
        beq ?done
        bcc ?y_add
        sec
        sbc animation_target_y
        cmp #7
        bcc ?y_set
        lda animation_y
        sec
        sbc #6
        sta animation_y
        rts
?y_add  lda animation_target_y
        sec
        sbc animation_y
        cmp #7
        bcc ?y_set
        lda animation_y
        clc
        adc #6
        sta animation_y
        rts
?y_set  lda animation_target_y
        sta animation_y
?done   rts
.endp

.proc animate_attack
        mva defender_unit attack_flash_target
        jsr prepare_projectile
        mva #8 attack_frame
?frame  mva #0 attack_flash
        lda attack_frame
        cmp #3
        bcs ?draw
        and #1
        sta attack_flash
?draw   jsr draw
        jsr advance_projectile
        jsr advance_projectile
        dec attack_frame
        dec attack_frame
        bne ?frame
        mva #0 attack_flash
        rts
.endp
animation_step dta 0
.proc attack_units
        ldx attacker_unit
        ldy unit_type,x
        lda type_damage,y
        sta attack_damage
        ldx defender_unit
        lda unit_hp,x
        sec
        sbc attack_damage
        bcs ?alive
        lda #0
?alive  sta unit_hp,x
        bne ?done
        ldy unit_type,x
        lda type_summon,y
        cmp #255
        beq ?done
        mva #1 game_state
        jsr award
?done   rts
.endp
attack_damage dta 0

.proc enemy_phase
        mva #1 enemy_busy
        lda hero_count
        sta enemy_id
?enemy ldx enemy_id
        cpx unit_count
        bcs ?new_turn
        lda unit_hp,x
        beq ?next
        mva #0 enemy_attacked
        ldy unit_type,x
        mva type_move,y enemy_actions
?act    ldx enemy_id
        mva enemy_actions unit_move_left,x
        jsr enemy_act
        lda enemy_attacked
        bne ?checked
        dec enemy_actions
        bne ?act
?checked
        ldx enemy_id
        mva #1 unit_acted,x
        mva #0 unit_move_left,x
        jsr check_result
        lda game_state
        bne ?done
?next   inc enemy_id
        jmp ?enemy

?new_turn
        inc turn_number
        ldx #0
?reset  cpx unit_count
        bcs ?select
        lda #0
        sta unit_acted,x
        sta unit_moved,x
        ldy unit_type,x
        lda type_move,y
        sta unit_move_left,x
        inx
        bne ?reset
?select ldx #0
?hero   cpx unit_count
        bcs ?done
        lda unit_team,x
        bne ?hn
        lda unit_hp,x
        bne ?found
?hn     inx
        bne ?hero
?found  stx selected_unit
        lda unit_cell,x
        sta cursor_cell
?done   mva #0 enemy_busy
        rts
.endp

enemy_actions  dta 0
enemy_id       dta 0
enemy_target   dta 0
enemy_best     dta 0
enemy_best_dist dta 0

.proc enemy_act
        ldx enemy_id
        ldy unit_type,x
        lda type_summon,y
        cmp #255
        beq ?normal
        jmp summon_enemy
?normal
        ; Find closest living hero.
        lda #$FF
        sta enemy_target
        lda #$7F
        sta enemy_best_dist
        ldx #0
?hero   cpx hero_count
        bcs ?have
        lda unit_hp,x
        beq ?next
        stx scan_id
        ldx enemy_id
        lda unit_cell,x
        ldy scan_id
        ldx unit_cell,y
        jsr distance_cells
        cmp enemy_best_dist
        bcs ?restore
        sta enemy_best_dist
        lda scan_id
        sta enemy_target
?restore
        ldx scan_id
?next   inx
        jmp ?hero

?have   lda enemy_target
        cmp #$FF
        bne ?has_target
        rts
?has_target
        ldx enemy_id
        ldy unit_type,x
        lda type_shoot_range,y
        bne ?shot_range
        lda #1
?shot_range
        cmp enemy_best_dist
        bcc ?move
        ldx enemy_id
        lda unit_cell,x
        ldy enemy_target
        ldx unit_cell,y
        jsr shot_clear
        bne ?move
        lda enemy_id
        sta attacker_unit
        lda enemy_target
        sta defender_unit
        mva #1 enemy_attacked
        jsr animate_attack
        jmp attack_units

?move   lda #$FF
        sta enemy_best
        lda enemy_best_dist
        sta candidate_dist
        lda #0
        sta test_dir
?dir    ldx enemy_id
        lda unit_cell,x
        ldx test_dir
        jsr get_neighbour
        cmp #$FF
        beq ?dn
        sta test_cell
        jsr is_open
        bcc ?dn
        ldy enemy_target
        ldx unit_cell,y
        lda test_cell
        jsr distance_cells
        cmp candidate_dist
        bcs ?dn
        sta candidate_dist
        lda test_cell
        sta enemy_best
?dn     inc test_dir
        lda test_dir
        cmp #6
        bcc ?dir
        lda enemy_best
        cmp #$FF
        beq ?done
        ldx enemy_id
        stx animation_unit
        lda unit_cell,x
        sta animation_from
        lda enemy_best
        sta animation_to
        jsr animate_move
        ldx enemy_id
        lda enemy_best
        sta unit_cell,x
?done   rts
.endp
.proc summon_enemy
        sta summon_kind
        mva #1 enemy_attacked
        mva #0 summon_cell
?scan   lda summon_cell
        jsr is_open
        bcc ?next
        ldx enemy_id
        lda unit_cell,x
        ldx summon_cell
        jsr distance_cells
        sta summon_distance
        ldx enemy_id
        ldy unit_type,x
        lda type_range,y
        cmp summon_distance
        bcc ?next
        lda summon_kind
        ldx #1
        ldy summon_cell
        jsr add_unit
        bcc ?done
        sta defender_unit
        mva enemy_id attacker_unit
        jsr animate_attack
        rts
?next   inc summon_cell
        lda summon_cell
        cmp #42
        bcc ?scan
?done   rts
.endp
summon_kind dta 0
summon_cell dta 0
summon_distance dta 0
scan_id        dta 0
candidate_dist dta 0

.proc check_result
        lda game_state
        beq ?active
        rts
?active
        lda #0
        sta hero_alive
        sta enemy_alive
        ldx #0
?scan   cpx unit_count
        bcs ?test
        lda unit_hp,x
        beq ?next
        lda unit_team,x
        bne ?enemy
        inc hero_alive
        jmp ?next
?enemy  inc enemy_alive
?next   inx
        bne ?scan
?test   lda enemy_alive
        bne ?heroes
        lda #1
        sta game_state
        jmp award
?heroes lda hero_alive
        bne ?done
        lda #2
        sta game_state
?done   rts
.endp
hero_alive  dta 0
enemy_alive dta 0


enemy_attacked dta 0
enemy_busy dta 0

.proc award
        lda reward_committed
        bne ?done
        mva #1 reward_committed
        ldx region
        lda region_wins,x
        cmp #3
        bcs ?repeat
        ldy contract
        lda reward_lo,y
        sta reward
        lda reward_hi,y
        sta reward+1
        inc region_wins,x
        lda region_wins,x
        cmp #3
        bne ?pay
        clc
        lda reward
        adc bonus_lo,x
        sta reward
        lda reward+1
        adc bonus_hi,x
        sta reward+1
        jmp ?pay
?repeat lda practice,x
        sta reward
        mva #0 reward+1
?pay    clc
        lda gold
        adc reward
        sta gold
        lda gold+1
        adc reward+1
        sta gold+1
        bcc ?done
        mwa #65535 gold
?done   rts
.endp

.proc navigate
        mva #255 click_unit
        lda game_state
        bne ?redraw
        lda popup_open
        beq ?board
        cpx #0
        beq ?previous
        cpx #2
        beq ?previous
        inc popup_choice
        lda popup_choice
        cmp #3
        bcc ?redraw
        mva #0 popup_choice
        jmp ?redraw
?previous
        dec popup_choice
        bpl ?redraw
        mva #2 popup_choice
        jmp ?redraw
?board  lda cursor_cell
        cmp #42
        bcc ?cell
        cpx #0
        bne ?buttons
        mva #35 cursor_cell
        jmp ?redraw
?buttons
        cpx #2
        bne ?right_button
        mva #42 cursor_cell
        jmp ?redraw
?right_button
        cpx #3
        bne ?redraw
        mva #43 cursor_cell
        jmp ?redraw
?cell   lda cursor_offsets,x
        clc
        adc cursor_cell
        tay
        lda cursor_neighbours,y
        sta cursor_cell
?redraw mva #1 dirty
        rts
.endp

.proc cancel
        mva #255 click_unit
        lda game_state
        bne ?return
        lda popup_open
        eor #1
        sta popup_open
        mva #2 popup_choice
        mva #1 dirty
        rts
?return jmp show_map
.endp

.proc confirm
        lda game_state
        beq ?playing
        jmp show_map
?playing
        lda popup_open
        beq ?cell
        mva #0 popup_open
        lda popup_choice
        cmp #1
        beq ?retreat
        cmp #0
        bne ?redraw
        jsr skip_hero
        jmp ?redraw
?retreat
        mva #3 game_state
        jmp ?redraw
?cell   lda cursor_cell
        cmp #42
        bcc ?select
        beq ?skip
        jmp cancel
?skip   jsr skip_hero
        jmp ?redraw
?select jsr unit_at
        bcc ?action
        lda unit_team,x
        bne ?action
        lda unit_acted,x
        bne ?redraw
        cpx selected_unit
        bne ?first
        cpx click_unit
        bne ?first
        lda RTCLOK+2
        sec
        sbc click_time
        sta click_elapsed
        lda RTCLOK+1
        sbc click_time+1
        bne ?first
        lda click_elapsed
        cmp #31
        bcs ?first
        jsr skip_hero
        jmp ?redraw
?first  stx selected_unit
        stx click_unit
        mva RTCLOK+2 click_time
        mva RTCLOK+1 click_time+1
        jmp ?redraw
?action mva #255 click_unit
        jsr confirm_cell
?redraw mva #1 dirty
        rts
.endp
click_unit dta 255
click_time dta a(0)
click_elapsed dta 0
        icl 'battle-render.inc'
.endl
