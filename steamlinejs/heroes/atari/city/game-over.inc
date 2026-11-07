; Only a force with no living soldiers and no affordable current recruit is lost.
.proc check_game_over
        lda screen_mode
        cmp #3
        beq ?done
        lda army_count
        bne ?done
        lda screen_mode
        cmp #2
        bne ?check
        lda battle.game_state
        beq ?done
?check  jsr can_afford_recruit
        bcs ?done
        lda #SFX_LAMENT
        jsr sfx.play
        mva #3 screen_mode
        mva #0 popup_open
        mva #1 dirty
?done   rts
.endp

; Preserve popup prices; use the highest unlocked tier and the Chapel discount.
.proc can_afford_recruit
        lda secondary_cost
        pha
        lda secondary_cost+1
        pha
        ldx #0
?building
        cpx #3
        beq ?next
        lda building_levels,x
        beq ?next
        sec
        sbc #1
        clc
        adc type_base,x
        tay
        mva unit_price_lo,y secondary_cost
        mva unit_price_hi,y secondary_cost+1
        jsr recruit_discount
        lda gold+1
        cmp secondary_cost+1
        bcc ?next
        bne ?yes
        lda gold
        cmp secondary_cost
        bcs ?yes
?next   inx
        cpx #5
        bcc ?building
        clc
        jmp ?restore
?yes    sec
?restore
        pla
        sta secondary_cost+1
        pla
        sta secondary_cost
        rts
.endp

.proc draw_game_over
        mva #0 dirty
        mva back_bank render_bank
        lda #3
        jsr story.load
        labeltext 100,190,s_restart_game
        jsr wait_blit
        jmp present_back_buffer
.endp
s_restart_game dta c'FIRE: START NEW GAME',0
