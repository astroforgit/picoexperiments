; Release title, controls and credits. No save slot or development shortcuts.
release_ui_start
.local release_ui
.proc show
        mva #0 page
        sta choice
        sta latch
        sta neutral
redraw  jsr draw
loop    jsr wait_frame
        jsr input
        beq released
        sta action
        mva #0 neutral
        lda latch
        bne loop
        mva #1 latch
        lda #0
        jsr sfx.play
        lda page
        beq menu
        lda action
        cmp #3
        bcc loop
        mva #0 page
        jmp redraw
menu    lda action
        cmp #1
        beq previous
        cmp #2
        beq next
        cmp #3
        bne loop
        lda choice
        beq start
        sta page
        jmp redraw
previous
        lda choice
        bne decrease
        mva #3 choice
decrease
        dec choice
        jmp redraw
next    inc choice
        lda choice
        cmp #3
        bcc redraw
        mva #0 choice
        jmp redraw
released
        lda neutral
        cmp #2
        bcs loop
        inc neutral
        lda neutral
        cmp #2
        bcc loop
        mva #0 latch
        jmp loop
start   mva #1 action_latched
        sta dirty
        mva #0 release_ticks
        mva #$FF CH
        sta key_temp
        rts
.endp
; One logical menu event; held keys and sticks require two neutral polls.
.proc input
        mva #$FF menu_key
        lda CH
        cmp #$FF
        beq raw
        and #$3F
        sta menu_key
raw     mva #$FF CH
        lda SKSTAT
        and #4
        bne fire
        lda KBCODE
        and #$3F
        sta menu_key
fire    lda STRIG0
        and #1
        beq confirm
        lda menu_key
        cmp #12
        beq confirm
        cmp #33
        beq confirm
        cmp #28
        beq back
        lda CONSOL
        and #2
        beq back
        lda PORTA
        and #15
        cmp #14
        beq up
        cmp #13
        beq down
        lda menu_key
        cmp #$2E
        beq up
        cmp #$0E
        beq up
        cmp #$3E
        beq down
        cmp #$0F
        beq down
        lda #0
        rts
up      lda #1
        rts
down    lda #2
        rts
confirm lda #3
        rts
back    lda #4
        rts
.endp
.proc draw
        mva back_bank render_bank
        jsr copy_background_cache
        rect 12,26,296,158,1
        rect 12,26,296,1,2
        rect 12,183,296,1,2
        lda page
        bne other
        jmp title
other   cmp #1
        bne credits
        jmp help
credits
        labeltext 139,43,s_credits
        labeltext 106,70,s_title
        labeltext 94,99,s_author
        labeltext 82,119,s_work
        labeltext 106,134,s_design
        jmp footer
help    labeltext 127,36,s_help
        mwa #help_lo text_src
        mva #0 line
        mva #53 line_y
next    ldx line
        mva help_lo,x text_src
        mva help_hi,x text_src+1
        mwa #25 text_x
        mva line_y text_y
        jsr draw_text
        lda line_y
        clc
        adc #10
        sta line_y
        inc line
        lda line
        cmp #12
        bcc next
footer  labeltext 82,171,s_back
        jmp present
title   jsr logo
        labeltext 94,77,s_author
        labeltext 121,105,s_start
        labeltext 121,125,s_help
        labeltext 121,145,s_credits
        lda choice
        asl
        asl
        sta mark_y
        asl
        asl
        clc
        adc mark_y
        adc #105
        sta text_y
        mwa #103 text_x
        mwa #s_mark text_src
        jsr draw_text
        labeltext 70,169,s_controls
present jsr wait_blit
        jmp present_back_buffer
.endp
.proc logo
        mva #0 column
nextcol ldx column
        mva logo_data,x bits
        mva #0 row
nextrow lsr bits
        bcc blank
        lda column
        asl
        clc
        adc #46
        sta calc_x
        lda #0
        adc #0
        sta calc_x+1
        lda row
        asl
        clc
        adc #48
        sta calc_y
        mwa #2 fr_w
        mva #2 fr_h
        mva #2 fr_col
        jsr fill_rect
blank   inc row
        lda row
        cmp #7
        bcc nextrow
        inc column
        lda column
        cmp #114
        bcc nextcol
        rts
.endp
page dta 0
choice dta 0
latch dta 0
neutral dta 0
action dta 0
menu_key dta 0
line dta 0
line_y dta 0
mark_y dta 0
column dta 0
row dta 0
bits dta 0
s_title dta c'PRINCE AND THE NIMF',0
s_author dta c'EVERYTHING BY ASTROFOR',0
s_work dta c'GAME, CODE, ART AND STORY',0
s_design dta c'DESIGN AND BALANCE',0
s_start dta c'START GAME',0
s_help dta c'HOW TO PLAY',0
s_credits dta c'CREDITS',0
s_mark dta c'>',0
s_controls dta c'UP/DOWN: SELECT  FIRE: CHOOSE',0
s_back dta c'FIRE / ESC: BACK TO MENU',0
help_lo dta <h0,<h1,<h2,<h3,<h4,<h5,<h6,<h7,<h8,<h9,<h10,<h11
help_hi dta >h0,>h1,>h2,>h3,>h4,>h5,>h6,>h7,>h8,>h9,>h10,>h11
h0 dta c'BUILD AN ARMY TO RESCUE THE NIMF.',0
h1 dta c'JOYSTICK / WASD / ARROWS: MOVE',0
h2 dta c'FIRE / ENTER / SPACE: CHOOSE',0
h3 dta c'ESC / SELECT: BACK OR RETREAT',0
h4 dta c'PALACE: BUILD, RECRUIT AND UPGRADE',0
h5 dta c'CHAPEL: UNLOCK MORE ARMY SLOTS',0
h6 dta c'THREE WINS UNLOCK THE NEXT LAIR',0
h7 dta c'IN BATTLE: MOVE, ATTACK OR SKIP',0
h8 dta c'DOUBLE FIRE ON A SOLDIER: SKIP',0
h9 dta c'DEAD SOLDIERS ARE LOST FOREVER',0
h10 dta c'NO ARMY AND NO RECRUIT GOLD: GAME OVER',0
h11 dta c'KILL THE NECROMANCER TO RESCUE HER',0
        icl 'generated/release-logo.inc'
.endl

; Short POKEY sound effects only. The OS keyboard channel and AUDCTL are untouched.
.local sfx
.proc play
        php
        pha
        txa
        pha
        tya
        pha
        tsx
        lda $0103,x             ; caller's A, saved beneath X and Y
        tax
        lda notes,x
        sta $D202
        mva controls,x control
        mva #6 frames
        ora control
        sta $D203
        pla
        tay
        pla
        tax
        pla
        plp
        rts
.endp
.proc tick
        php
        pha
        lda frames
        beq done
        dec frames
        beq mute
        lda frames
        ora control
        sta $D203
        jmp done
mute    mva #0 $D203
done    pla
        plp
        rts
.endp
.proc finish
        ; Drain a short cue before blocking OS disk reads, so it cannot sustain
        ; for the duration of loading a full picture.
        lda frames
        beq done
        jsr wait_frame
        jmp finish
done    rts
.endp
; click, purchase, impact, victory, defeat, unavailable
notes dta 55,30,130,18,190,220
controls dta $A0,$A0,$80,$A0,$80,$A0
frames dta 0
control dta 0
.endl
        icl 'gallery.inc'
release_ui_end
        ert release_ui_end>$C000
