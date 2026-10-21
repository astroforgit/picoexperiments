; Dark Forest duel (duel.json): a normal battle with the current army against
; one weak enemy, any time. A small fixed purse; no lair escalation, region
; progress or paintings. Also the map scout report with its three buttons.
; Resident with the release UI at $A000+, outside the full main code area.

        .local battle
duel dta 0                      ; 1 while the current battle is a duel
; After set_difficulty: a duel enemy never escalates.
.proc duel_setup
        lda duel
        beq ?done
        mva #0 enemy_hp_bonus
        sta enemy_damage_bonus
?done   rts
.endp
; C set when the duel enemy was placed instead of the contract's group.
.proc duel_enemy
        lda duel
        beq ?no
        lda #DUEL_TYPE
        ldy #DUEL_CELL
        ldx #1
        jsr add_unit
        sec
        rts
?no     clc
        rts
.endp
; C set when a won duel was paid (difficulty-scaled purse).
.proc duel_award
        lda duel
        beq ?no
        mwa #DUEL_REWARD reward
        jsr scale_reward
        clc
        lda gold
        adc reward
        sta gold
        lda gold+1
        adc reward+1
        sta gold+1
        bcc ?yes
        mwa #65535 gold
?yes    sec
        rts
?no     clc
        rts
.endp
; Battle header text.
.proc title_pointer
        lda duel
        beq ?contract
        mwa #s_duel_title text_src
        rts
?contract
        ldx contract
        mva contract_name_lo,x text_src
        mva contract_name_hi,x text_src+1
        rts
.endp
s_duel_title dta c'DARK FOREST DUEL',0
        .endl

; C set when the selected map location offers a duel: Dark Forest with an army.
.proc can_duel
        lda selected_location
        bne ?no
        lda army_count
        beq ?no
        sec
        rts
?no     clc
        rts
.endp

.proc draw_scout_report
        rect 22,28,280,140,1
        rect 24,30,276,136,7
        rect 24,30,276,16,1
        mwa #22 calc_x
        mva #28 calc_y
        mwa #280 fr_w
        mva #140 fr_h
        mva #2 fr_col
        jsr outline
        jsr location_name_pointer
        mwa #32 text_x
        mva #34 text_y
        jsr draw_text
        labeltext 32,54,s_scout
        ldx selected_location
        lda location_desc_lo,x
        sta text_src
        lda location_desc_hi,x
        sta text_src+1
        mwa #32 text_x
        mva #72 text_y
        jsr draw_text
        ldx selected_location
        lda location_detail_lo,x
        sta text_src
        lda location_detail_hi,x
        sta text_src+1
        mwa #32 text_x
        mva #88 text_y
        jsr draw_text
        lda selected_location
        bne ?status
        labeltext 32,104,s_duel_hint
?status jsr can_enter_battle
        bcs ?ready
        lda army_count
        beq ?no_army
        labeltext 32,119,s_locked
        jmp ?buttons
?no_army
        labeltext 32,119,s_recruit_first
        jmp ?buttons
?ready  labeltext 32,119,s_ready
?buttons
        jsr can_enter_battle
        bcc ?fight_off
        rect 32,134,80,15,1
        labeltext 57,138,s_fight
        jmp ?duel
?fight_off
        ; Blend the disabled control into the panel; it cannot receive focus.
        rect 32,134,80,15,7
        labeltext 54,138,s_disabled
?duel   jsr can_duel
        bcc ?back
        rect 120,134,80,15,1
        labeltext 148,138,s_duel
?back   rect 208,134,80,15,1
        labeltext 236,138,s_back
        lda popup_choice
        jsr map_choice_enabled
        bcc ?done
        ldx popup_choice
        lda map_button_x,x
        sta calc_x
        mva #0 calc_x+1
        mva #134 calc_y
        mwa #80 fr_w
        mva #15 fr_h
        mva #2 fr_col
        jmp outline
?done   rts
.endp
map_button_x dta 32,208,120     ; choices: 0 fight, 1 back, 2 duel
s_duel dta c'DUEL',0
s_duel_hint dta c'DUEL: ONE MINIBEAST FOR A SMALL PURSE.',0
