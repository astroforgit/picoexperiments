; Special rules shared by every native attack. Vampire keeps the dark sprite ID.
attack_damage dta 0
attack_bonus dta 0
actual_damage dta 0

.proc attack_units
        ldx attacker_unit
        ldy unit_type,x
        lda type_damage,y
        clc
        adc attack_bonus
        sta attack_damage
        mva #0 attack_bonus
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
?damage ldx defender_unit
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
        lda unit_hp,x
        cmp type_hp,y
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
