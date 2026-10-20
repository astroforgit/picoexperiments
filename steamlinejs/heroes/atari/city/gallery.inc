; Eight unique portraits: locations shuffled per campaign, no duplicate rewards.
.local gallery
.proc new_game
        mva #0 notes_found
        sta notes_pending
        sta painting_pending
        sta collected
        sta wins
        ldx #7
init    txa
        sta order,x
        dex
        bpl init
        lda battle.encounter_seed
        bne seed
        lda #1
seed    sta shuffle_rng
        mva #7 shuffle_index
pick    asl shuffle_rng
        bcc ready
        lda shuffle_rng
        eor #$1D
        sta shuffle_rng
ready   lda shuffle_rng
        and #7
        cmp shuffle_index
        beq swap
        bcs pick
swap    tay
        ldx shuffle_index
        lda order,x
        pha
        mva order,y order,x
        pla
        sta order,y
        dec shuffle_index
        bne pick
        rts
.endp
.proc record_win
        lda wins
        cmp #255
        beq quest
        inc wins
quest   lda notes_found
        bne portrait
        lda wins
        cmp #NOTES_AFTER_WINS
        bcc done
        mva #1 notes_found
        sta notes_pending
        rts
portrait
        ldx battle.region
        lda region_wins,x
        cmp #REGION_WINS_TO_FIND
        bcc done
        txa
        asl
        tax
        ldy order,x
        lda bits,y
        and collected
        beq found
        inx
        ldy order,x
        lda bits,y
        and collected
        bne done
found
        lda bits,y
        ora collected
        sta collected
        tya
        clc
        adc #1
        sta painting_pending
done    rts
.endp
.proc check_events
        lda notes_pending
        ora painting_pending
        bne active
        rts
active  lda notes_pending
        beq painting
        mva #0 notes_pending
        jsr draw_notes
        lda #SFX_SPARKLE
        jsr sfx.play
        jsr wait_button
painting
        lda painting_pending
        beq done
        sec
        sbc #1
        sta selection
        mva #0 painting_pending
        jsr picture
        lda #SFX_SPARKLE
        jsr sfx.play
        jsr wait_button
done    mva #1 dirty
        mva #1 action_latched
        mva #0 release_ticks
        mva #$FF CH
        sta key_temp
        rts
.endp
.proc open
        lda building_levels+3
        jeq done
        mva #0 selection
        jsr seek_next
        mva #1 latch
        mva #0 neutral
redraw  jsr draw_list
loop    jsr wait_frame
        jsr release_ui.input
        beq released
        sta action
        mva #0 neutral
        lda latch
        bne loop
        mva #1 latch
        jsr release_ui.action_sound
        lda action
        cmp #4
        beq done
        cmp #3
        beq view
        cmp #1
        beq previous
        inc selection
        jsr seek_next
        jmp redraw
previous
        lda selection
        bne decrease
        mva #9 selection
decrease
        dec selection
        jsr seek_previous
        jmp redraw
view    lda selection
        cmp #8
        beq done
        jsr picture
        jsr wait_button
        mva #0 latch
        jmp redraw
released
        inc neutral
        lda neutral
        cmp #2
        bcc loop
        mva #2 neutral
        mva #0 latch
        jmp loop
done    mva #1 dirty
        sta action_latched
        mva #0 release_ticks
        mva #$FF CH
        sta key_temp
        rts
.endp
.proc seek_next
        lda selection
        cmp #9
        bcc test
        mva #0 selection
test    cmp #8
        beq done
        ldx selection
        lda bits,x
        and collected
        bne done
        inc selection
        jmp seek_next
done    rts
.endp
.proc seek_previous
        lda selection
        cmp #8
        beq done
        tax
        lda bits,x
        and collected
        bne done
        lda selection
        bne decrement
        mva #9 selection
decrement
        dec selection
        jmp seek_previous
done    rts
.endp
.proc picture
        mva back_bank render_bank
        lda selection
        clc
        adc #4
        jsr story.load
        labeltext 79,190,s_picture_back
        jsr wait_blit
        jmp present_back_buffer
.endp
.proc draw_list
        mva back_bank render_bank
        jsr copy_background_cache
        rect 12,18,296,174,1
        labeltext 127,28,s_gallery
        labeltext 100,45,s_master
        mva #48 count_char
        ldx #7
count   lda bits,x
        and collected
        beq next
        inc count_char
next    dex
        bpl count
        labeltext 112,60,s_count
        labeltext 172,60,count_char
        labeltext 178,60,s_total
        mva #0 line
row     ldx line
        mva title_lo,x text_src
        mva title_hi,x text_src+1
        lda bits,x
        and collected
        bne name
        mwa #s_missing text_src
name    lda line
        asl
        sta row_y
        asl
        asl
        clc
        adc row_y
        adc #78
        sta text_y
        mwa #43 text_x
        jsr draw_text
        lda line
        cmp selection
        bne another
        mwa #s_mark text_src
        mwa #25 text_x
        jsr draw_text
another inc line
        lda line
        cmp #8
        bcc row
        labeltext 43,164,s_back
        lda selection
        cmp #8
        bne footer
        labeltext 25,164,s_mark
footer  labeltext 22,182,s_controls
        jsr wait_blit
        jmp present_back_buffer
.endp
.proc draw_notes
        mva back_bank render_bank
        jsr copy_background_cache
        rect 12,25,296,155,1
        labeltext 79,38,s_notes_title
        labeltext 25,65,s_note0
        labeltext 25,80,s_note1
        labeltext 25,95,s_note2
        labeltext 25,110,s_note3
        labeltext 25,125,s_note4
        labeltext 25,140,s_note5
        labeltext 79,164,s_picture_back
        jsr wait_blit
        jmp present_back_buffer
.endp
; Require release, then a fresh Fire/Enter/Space/Escape/Select and release.
.proc wait_button
        mva #0 neutral
release jsr wait_frame
        jsr release_ui.input
        bne wait_button
        inc neutral
        lda neutral
        cmp #2
        bcc release
press   jsr wait_frame
        jsr release_ui.input
        cmp #3
        bcc press
        lda #SFX_CLICK
        jsr sfx.play
        mva #0 neutral
finish  jsr wait_frame
        jsr release_ui.input
        bne held
        inc neutral
        lda neutral
        cmp #2
        bcc finish
        rts
held    mva #0 neutral
        jmp finish
.endp
; Chapel row 1 is unavailable until a Chapel exists. Navigation skips it.
.proc skip_disabled
        lda popup_open
        beq done
        lda selected_plot
        cmp #3
        bne done
        lda building_levels+3
        bne done
        lda popup_choice
        cmp #1
        bne done
        cpx #0
        beq previous
        cpx #2
        beq previous
        mva #2 popup_choice
        rts
previous mva #0 popup_choice
done    rts
.endp
.proc button_available
        lda button_index
        cmp #1
        bne yes
        lda selected_plot
        cmp #3
        bne yes
        lda building_levels+3
        bne yes
        clc
        rts
yes     sec
        rts
.endp
notes_found dta 0
notes_pending dta 0
painting_pending dta 0
collected dta 0
wins dta 0
order dta 0,1,2,3,4,5,6,7
shuffle_rng dta 1
shuffle_index dta 0
selection dta 0
line dta 0
row_y dta 0
latch dta 0
neutral dta 0
action dta 0
count_char dta c'0',0
bits dta 1,2,4,8,16,32,64,128
s_button dta c'ART GALLERY',0
s_build_first dta c'BUILD CHAPEL FOR GALLERY',0
s_gallery dta c'ART GALLERY',0
s_master dta c'MASTER GRUBBRUSH',0
s_count dta c'COLLECTED',0
s_total dta c'/8',0
s_missing dta c'UNRECOVERED PAINTING',0
s_mark dta c'>',0
s_back dta c'BACK TO CHAPEL',0
s_controls dta c'UP/DOWN: SELECT  FIRE: VIEW  ESC: BACK',0
s_picture_back dta c'FIRE / ESC: CONTINUE',0
s_notes_title dta c'THE GOBLIN MASTER',0
s_note0 dta c'OUR SCOUTS FOUND A TORN NOTEBOOK.',0
s_note1 dta c'MASTER GRUBBRUSH PAINTED OUR NIMF.',0
s_note2 dta c'BANDITS SCATTERED HIS WORK.',0
s_note3 dta c'WIN BATTLES IN EVERY LAIR TO',0
s_note4 dta c'RECOVER HIS LOST PORTRAITS.',0
s_note5 dta c'THE CHAPEL WILL DISPLAY THEM.',0
        icl 'generated/gallery-content.inc'
.endl
