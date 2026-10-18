; Special rules shared by every native attack. Vampire keeps the dark sprite ID.
attack_damage dta 0
attack_bonus dta 0
actual_damage dta 0

.proc compute_damage
        ldx attacker_unit
        ldy unit_type,x
        jsr scaled_damage
        clc
        adc attack_bonus
        sta attack_damage
        ; Only Archery Range fighters (types 3..5) fire physical arrows.
        tya
        cmp #3
        bcc ?damage
        cmp #6
        bcs ?damage
        ldx defender_unit
        ldy unit_type,x
        lda type_ability,y
        cmp #3
        bne ?damage
        lda attack_damage
        cmp #2
        bcc ?damage
        dec attack_damage
?damage rts
.endp

.proc attack_units
        jsr compute_damage
        mva #0 attack_bonus
        ldx defender_unit
        lda unit_hp,x
        beq ?done
        cmp attack_damage
        bcc ?lethal
        lda attack_damage
        sta actual_damage
        lda unit_hp,x
        sec
        sbc attack_damage
        jmp ?store
?lethal sta actual_damage
        lda #0
?store  sta unit_hp,x
        bne ?effects
        jsr lose_soldier
        ldy unit_type,x
        lda type_summon,y
        cmp #255
        beq ?raise
        mva #1 game_state
        jsr award
        rts
?raise  jsr raise_zombie
?effects
        ldx attacker_unit
        ldy unit_type,x
        lda type_ability,y
        cmp #1
        bne ?imp
        lda actual_damage
        beq ?done
        jsr scaled_hp
        sta vampire_max_hp
        lda unit_hp,x
        cmp vampire_max_hp
        bcs ?done
        inc unit_hp,x
        mva #1 ability_event
        rts
?imp    cmp #5
        bne ?done
        jmp imp_hop
?done   rts
.endp

.proc raise_zombie
        ldx attacker_unit
        ldy unit_type,x
        lda type_ability,y
        cmp #2
        bne ?done
        lda unit_raised,x
        bne ?done
        lda conversions
        cmp #2
        bcs ?done
        ldx defender_unit
        lda unit_team,x
        bne ?done
        mva #19 unit_type,x
        mva #1 unit_team,x
        sta unit_raised,x
        sta unit_acted,x
        mva #2 unit_hp,x
        mva #0 unit_charge,x
        sta unit_move_left,x
        mva turn_number unit_spawned,x
        inc conversions
        mva #2 ability_event
?done   rts
.endp

.proc release_ogre
        mva #1 enemy_attacked
        mva #0 unit_charge,x
        lda unit_mark,x
        jsr unit_at
        bcc ?done
        lda unit_team,x
        bne ?done
        stx defender_unit
        lda unit_cell,x
        tax
        ldy enemy_id
        lda unit_cell,y
        jsr distance_cells
        cmp #2
        bcs ?done
        mva enemy_id attacker_unit
        mva #2 attack_bonus
        jsr animate_attack
        jmp attack_units
?done   rts
.endp

.proc imp_hop
        mva #0 hop_dir
        ldx attacker_unit
        lda unit_cell,x
        ldy defender_unit
        ldx unit_cell,y
        jsr distance_cells
        sta hop_distance
?dir    ldx attacker_unit
        lda unit_cell,x
        ldx hop_dir
        jsr get_neighbour
        sta hop_cell
        jsr is_open
        bcc ?next
        lda hop_cell
        ldy defender_unit
        ldx unit_cell,y
        jsr distance_cells
        cmp hop_distance
        bcc ?next
        beq ?next
        ldx attacker_unit
        stx animation_unit
        mva unit_cell,x animation_from
        mva hop_cell animation_to
        jsr animate_move
        ldx attacker_unit
        mva hop_cell unit_cell,x
        mva #5 ability_event
        rts
?next   inc hop_dir
        lda hop_dir
        cmp #6
        bcc ?dir
        rts
.endp
hop_dir dta 0
hop_cell dta 0
hop_distance dta 0

; X dead battlefield unit -> permanently clear its original campaign slot.
; Keep X intact for boss/raise handling and never refund a dead soldier.
.proc lose_soldier
        cpx hero_count
        bcs ?done
        lda unit_team,x
        bne ?done
        ldy hero_army_slot,x
        cpy #5
        bcs ?done
        lda army_units,y
        cmp #255
        beq ?done
        lda #255
        sta army_units,y
        lda #0
        sta army_paid_lo,y
        sta army_paid_hi,y
        dec army_count
?done   rts
.endp

vampire_max_hp dta 0
; Unlimited entries, with a saturating counter to prevent late-game wraparound.
.proc set_difficulty
        mva #0 enemy_hp_bonus
        sta enemy_damage_bonus
        lda region_wins,x
        sec
        sbc wins_required,x
        bcc ?done
        cmp #89
        bcc ?increase
        lda #89
?increase
        clc
        adc #1
        sta enemy_hp_bonus
?damage cmp #3
        bcc ?done
        sec
        sbc #3
        inc enemy_damage_bonus
        ldy enemy_damage_bonus
        cpy #8
        bcc ?damage
?done   rts
.endp

.proc scaled_hp
        lda type_hp,y
        pha
        lda unit_team,x
        beq ?base
        pla
        clc
        adc enemy_hp_bonus
        bcs ?cap
        cmp #100
        bcc ?done
?cap    lda #99
?done   rts
?base   pla
        rts
.endp

.proc scaled_damage
        lda type_damage,y
        pha
        lda unit_team,x
        beq ?base
        pla
        clc
        adc enemy_damage_bonus
        bcs ?cap
        cmp #10
        bcc ?done
?cap    lda #9
?done   rts
?base   pla
        rts
.endp
