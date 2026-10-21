; Release title, controls and enemy info. No save slot or development shortcuts.
release_ui_start
.local release_ui
.proc show
        mva #0 page
        sta choice
        sta latch
        sta neutral
        jsr prepare
        jsr enable_display      ; shows bank 0: picture and empty menu frame
        jsr draw
        jmp loop
redraw  jsr draw
loop    jsr wait_frame
        jsr input
        jeq released
        sta action
        mva #0 neutral
        lda latch
        bne loop
        mva #1 latch
        jsr action_sound
        lda page
        jeq menu
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
        cmp #1
        beq level
        cmp #4
        beq sound
        sec
        sbc #1                  ; rows 2/3 open pages 1/2
        sta page
        jmp redraw
level   inc difficulty
        lda difficulty
        cmp #3
        bcc relevel
        mva #0 difficulty
relevel jsr starting_gold
        jmp redraw
sound   jsr sfx.toggle
        jmp redraw
previous
        lda choice
        bne decrease
        mva #5 choice
decrease
        dec choice
        jmp redraw
next    inc choice
        lda choice
        cmp #5
        jcc redraw
        mva #0 choice
        jmp redraw
released
        lda neutral
        cmp #2
        jcs loop
        inc neutral
        lda neutral
        cmp #2
        jcc loop
        mva #0 latch
        jmp loop
start   jsr starting_gold
        lda #SFX_MARCH
        jsr sfx.play
        mva #1 action_latched
        sta dirty
        mva #0 release_ticks
        mva #$FF CH
        sta key_temp
        mva #2 background_bank
        rts
.endp
; Move, choose and back sound different in every menu.
.proc action_sound
        ldx action
        lda action_cue,x
        jmp sfx.play
.endp
action_cue dta SFX_CLICK,SFX_MOVE,SFX_MOVE,SFX_CLICK,SFX_BACK
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
;-----------------------------------------------------------------------------
; Title screen. The painted picture arrives in bank 1 during loading. Both
; banks get the picture with the menu frame; every change is drawn into the
; hidden bank and presented. A help/credits panel is only ever drawn over the
; hidden copy, so the other bank keeps the menu and the painting under the
; panel. Returning presents that bank and repairs the other from it.
MENU_X = 106
MENU_Y = 104
ROW_X = 110
ROW_W = 100
.proc prepare
        mva #1 background_bank
        mva #0 render_bank
        jsr copy_background_cache
        jsr frame
        mva #1 render_bank
        jsr frame
        mva #0 drawn_page
        rts
frame   jsr band
        rect MENU_X,MENU_Y,108,80,1
        rect MENU_X+2,MENU_Y+2,104,76,7
        mwa #MENU_X calc_x
        mva #MENU_Y calc_y
        mwa #108 fr_w
        mva #80 fr_h
        mva #2 fr_col
        jmp outline
.endp
.proc draw
        mva back_bank render_bank
        jsr band
        lda page
        jeq menu
        jsr panel
        lda page
        cmp #1
        beq help
        mwa #s_info text_src
        jsr heading
        jsr enemy_text
        jsr enemies
        jmp back
help    mwa #s_help text_src
        jsr heading
        mva #0 line
        mva #70 line_y
next    ldx line
        mva help_lo,x text_src
        mva help_hi,x text_src+1
        mwa #28 text_x
        mva line_y text_y
        jsr draw_text
        lda line_y
        clc
        adc #9
        sta line_y
        inc line
        lda line
        cmp #12
        bcc next
back    labeltext 229,190,s_back
        jmp show_it
menu    labeltext 241,190,s_controls
        mva #0 line
row     ldx line
        lda row_y,x
        sta calc_y
        mwa #ROW_X calc_x
        mwa #ROW_W fr_w
        mva #13 fr_h
        mva #1 fr_col
        jsr fill_rect
        lda line
        cmp choice
        bne label
        ldx line
        lda row_y,x
        sta calc_y
        mwa #ROW_X calc_x
        mwa #ROW_W fr_w
        mva #13 fr_h
        mva #2 fr_col
        jsr outline
label   ldx line
        lda row_y,x
        clc
        adc #3
        sta text_y
        lda row_lo,x
        sta text_src
        lda row_hi,x
        sta text_src+1
        cpx #1
        bne sound
        ldy difficulty
        mva battle.difficulty_label_lo,y text_src
        mva battle.difficulty_label_hi,y text_src+1
sound   cpx #4
        bne say
        lda sfx.enabled
        bne say
        mwa #s_sound_off text_src
say     jsr centered
        inc line
        lda line
        cmp #5
        jcc row
show_it jsr wait_blit
        jsr present_back_buffer
        lda drawn_page
        ldx page
        stx drawn_page
        cmp #0
        beq done
        txa
        bne done
        ; Back from a panel: the hidden bank still shows it; copy the menu.
        mva front_bank background_bank
        mva back_bank render_bank
        jsr copy_background_cache
        jsr wait_blit
done    rts
.endp
; Enemy info page: names and abilities beside each sprite cell.
.proc enemy_text
        mva #0 line
next    ldx line
        lda info_x,x
        clc
        adc #36
        sta text_x
        mva #0 text_x+1
        lda info_y,x
        sta text_y
        mva battle.info_name_lo,x text_src
        mva battle.info_name_hi,x text_src+1
        jsr draw_text
        ldx line
        lda info_x,x
        clc
        adc #36
        sta text_x
        mva #0 text_x+1
        lda info_y,x
        clc
        adc #11
        sta text_y
        mva info_a_lo,x text_src
        mva info_a_hi,x text_src+1
        jsr draw_text
        ldx line
        lda info_x,x
        clc
        adc #36
        sta text_x
        mva #0 text_x+1
        lda info_y,x
        clc
        adc #20
        sta text_y
        mva info_b_lo,x text_src
        mva info_b_hi,x text_src+1
        jsr draw_text
        inc line
        lda line
        cmp #6
        bcc next
        rts
.endp
; Enemy sprites (first walk frame) into render_bank.
.proc enemies
        mva #0 line
next    ldx line
        lda info_x,x
        sta calc_x
        mva #0 calc_x+1
        lda info_y,x
        sta calc_y
        ; Borrow the battle walk-cycle path; it bypasses the idle cache.
        mva #1 battle.animation_active
        mva #0 battle.animation_unit
        sta battle.draw_id
        sta battle.attack_frame
        sta battle.animation_step
        ldx line
        lda battle.info_type,x
        jsr battle.hero_sprite
        inc line
        lda line
        cmp #6
        bcc next
        mva #0 battle.animation_active
        jmp wait_blit
.endp
info_x dta 20,20,20,160,160,160
info_y dta 72,108,144,72,108,144
info_a_lo dta <i0a,<i1a,<i2a,<i3a,<i4a,<i5a
info_a_hi dta >i0a,>i1a,>i2a,>i3a,>i4a,>i5a
info_b_lo dta <i0b,<i1b,<i2b,<i3b,<i4b,<i5b
info_b_hi dta >i0b,>i1b,>i2b,>i3b,>i4b,>i5b
i0a dta c'IMMUNE TO ARROWS',0
i0b dta c'USE MAGIC/BLADES',0
i1a dta c'ITS VICTIMS RISE',0
i1b dta c'AS ZOMBIES',0
i2a dta c'HEALS 1 HP WITH',0
i2b dta c'EVERY BITE',0
i3a dta c'WINDS UP A +2',0
i3b dta c'BLOW: STEP AWAY',0
i4a dta c'HOPS AWAY AFTER',0
i4b dta c'EACH ATTACK',0
i5a dta c'SUMMONS SKELETONS',0
i5b dta c'SLAY HIM TO WIN',0
; Bottom bar, like the city HUD: dark band with a gold rule and the credit.
.proc band
        rect 0,186,320,14,1
        rect 0,186,320,1,2
        labeltext 8,190,s_author
        labeltext 148,190,s_version
        rts
.endp
; Popup-style page frame below the logo.
.proc panel
        rect 16,48,288,136,1
        rect 18,50,284,132,7
        rect 18,50,284,16,1
        mwa #16 calc_x
        mva #48 calc_y
        mwa #288 fr_w
        mva #136 fr_h
        mva #2 fr_col
        jmp outline
.endp
.proc heading
        mva #55 text_y
        jmp centered
.endp
; Draw text_src centred on the screen at text_y (6-pixel glyph advance).
.proc centered
        ldy #0
count   lda (text_src),y
        beq measured
        iny
        bne count
measured
        tya
        asl
        sta mark_y
        tya
        clc
        adc mark_y
        sta mark_y              ; 3 * length = half the 6-pixel advance
        lda #160
        sec
        sbc mark_y
        sta text_x
        mva #0 text_x+1
        jmp draw_text
.endp
row_y dta 109,123,137,151,165
row_lo dta <s_start,<s_start,<s_help,<s_info,<s_sound_on
row_hi dta >s_start,>s_start,>s_help,>s_info,>s_sound_on
drawn_page dta 0
page dta 0
choice dta 0
latch dta 0
neutral dta 0
action dta 0
menu_key dta 0
line dta 0
line_y dta 0
mark_y dta 0
s_author dta c'AUTHOR: ASTROFOR',0
        icl 'generated/version.inc'
s_start dta c'START GAME',0
s_help dta c'HOW TO PLAY',0
s_info dta c'ENEMY INFO',0
s_sound_on dta c'SOUND: ON',0
s_sound_off dta c'SOUND: OFF',0
s_controls dta c'FIRE: CHOOSE',0
s_back dta c'FIRE/ESC: BACK',0
help_lo dta <h0,<h1,<h2,<h3,<h4,<h5,<h6,<h7,<h8,<h9,<h10,<h11
help_hi dta >h0,>h1,>h2,>h3,>h4,>h5,>h6,>h7,>h8,>h9,>h10,>h11
h0 dta c'BUILD AN ARMY TO RESCUE THE NYMPH.',0
h1 dta c'JOYSTICK / WASD / ARROWS: MOVE',0
h2 dta c'FIRE / ENTER / SPACE: CHOOSE',0
h3 dta c'ESC / SELECT: BACK OR RETREAT',0
h4 dta c'PALACE: BUILD, RECRUIT AND UPGRADE',0
h5 dta c'CHAPEL: UNLOCK MORE ARMY SLOTS',0
h6 dta c'THREE WINS UNLOCK THE NEXT LAIR',0
h7 dta c'IN BATTLE: RETREAT COSTS 1/3 OF PRIZE',0
h8 dta c'DOUBLE FIRE ON A SOLDIER: SKIP',0
h9 dta c'DEAD SOLDIERS ARE LOST FOREVER',0
h10 dta c'NO ARMY AND NO RECRUIT GOLD: GAME OVER',0
h11 dta c'KILL THE NECROMANCER TO RESCUE HER',0
.endl

;-----------------------------------------------------------------------------
; Short POKEY sound effects only. The OS keyboard channel and AUDCTL are untouched;
; SIO keeps channels 3/4. Each cue is a list of per-frame (AUDF, AUDC) pairs with
; quiet pure tones and bell-like decays; AUDF 0 ends it. Channel 2 plays the cue,
; channel 1 repeats it ECHO_DELAY frames later at half volume for a softer sound.
ECHO_DELAY = 4
.local sfx
.proc play
        php
        pha
        txa
        pha
        tya
        pha
        lda enabled
        beq off
        tsx
        lda $0103,x             ; caller's A, saved beneath X and Y
        tax
        lda cue_lo,x
        sta cursor
        sta echo
        lda cue_hi,x
        sta cursor+1
        sta echo+1
        mva #1 frames
        sta main_on
        mva #ECHO_DELAY delay
        mva #0 $D201
        jsr step
off     pla
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
        lda main_on
        beq echoing
        jsr step
echoing lda delay
        beq repeat
        dec delay
        jmp done
repeat  jsr echo_step
done    pla
        plp
        rts
.endp
; Main voice. Uses A only; callers keep X and Y.
.proc step
        lda cursor
        sta freq+1
        sta ctrl+1
        lda cursor+1
        sta freq+2
        sta ctrl+2
        inc ctrl+1
        bne freq
        inc ctrl+2
freq    lda $FFFF
        beq stop
        sta $D202
ctrl    lda $FFFF
        sta $D203
        lda cursor
        clc
        adc #2
        sta cursor
        bcc done
        inc cursor+1
done    rts
stop    sta main_on
        sta $D203
        rts
.endp
; Echo voice: same pairs, volume (v+1)/2. The cue is over when it ends.
.proc echo_step
        lda echo
        sta freq+1
        sta ctrl+1
        lda echo+1
        sta freq+2
        sta ctrl+2
        inc ctrl+1
        bne freq
        inc ctrl+2
freq    lda $FFFF
        beq stop
        sta $D200
ctrl    lda $FFFF
        sta shape
        and #15
        beq quiet
        clc
        adc #1
        lsr
quiet   sta level
        lda shape
        and #$F0
        ora level
        sta $D201
        lda echo
        clc
        adc #2
        sta echo
        bcc done
        inc echo+1
done    rts
stop    sta frames
        sta $D201
        sta $D203
        rts
.endp
; Title menu SOUND: ON/OFF. Turning it off silences a cue already playing;
; turning it on confirms with a click.
.proc toggle
        lda enabled
        eor #1
        sta enabled
        beq mute
        lda #SFX_CLICK
        jmp play
mute    sta frames
        sta main_on
        sta $D201
        sta $D203
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
; Cue numbers: SFX_CLICK..SFX_SPARKLE below the .local block.
cue_lo  dta <click,<coin,<thud,<fanfare,<lament,<denied,<move,<back,<fall,<march,<retreat,<sparkle
cue_hi  dta >click,>coin,>thud,>fanfare,>lament,>denied,>move,>back,>fall,>march,>retreat,>sparkle
; Generated from note names and envelopes (C5=60 E5=47 G5=40 A5=35 C6=29 at 64 kHz):
; tick, E5-A5 "ding-dong", soft falling tock, C-E-G-C chime, G-E-C sigh, A-F bump.
click   dta 30,$A2,30,$A1,30,$A1,0
coin    dta 47,$A4,47,$A3,47,$A3,47,$A2,35,$A4,35,$A4,35,$A3,35,$A3,35,$A3,35,$A2
        dta 35,$A2,35,$A2,35,$A2,35,$A1,35,$A1,35,$A1,35,$A1,35,$A1,0
thud    dta 60,$A3,75,$A3,90,$A2,105,$A1,120,$A1,0
fanfare dta 60,$A4,60,$A3,60,$A2,60,$A2,47,$A4,47,$A3,47,$A2,47,$A2,40,$A4,40,$A3
        dta 40,$A2,40,$A2,29,$A4,29,$A4,29,$A3,29,$A3,29,$A3,29,$A2,29,$A2,29,$A2
        dta 29,$A2,29,$A1,29,$A1,29,$A1,29,$A1,29,$A1,29,$A1,29,$A1,0
lament  dta 81,$A3,81,$A3,81,$A3,81,$A2,81,$A2,81,$A2,81,$A1,81,$A1,96,$A3,96,$A3
        dta 96,$A3,96,$A2,96,$A2,96,$A2,96,$A1,96,$A1,121,$A3,121,$A3,121,$A3,121,$A3
        dta 121,$A2,121,$A2,121,$A2,121,$A2,121,$A1,121,$A1,121,$A1,121,$A1,0
denied  dta 71,$A3,71,$A2,71,$A1,71,$A0,91,$A3,91,$A2,91,$A2,91,$A1,91,$A1,0
; Cursor tick, A-E "back", falling knock-out glide, C-G-C battle call,
; E-C-A retreat, quick C-E-G-C sparkle for a discovered painting.
move    dta 36,$A2,36,$A1,0
back    dta 35,$A3,35,$A2,47,$A3,47,$A2,47,$A2,47,$A1,47,$A1,0
fall    dta 47,$A3,55,$A3,64,$A3,75,$A2,88,$A2,103,$A2,121,$A1,140,$A1,0
march   dta 121,$A3,121,$A2,81,$A3,81,$A2,60,$A3,60,$A3,60,$A3,60,$A2,60,$A2,60,$A2
        dta 60,$A2,60,$A1,60,$A1,60,$A1,60,$A1,60,$A1,0
retreat dta 47,$A3,47,$A3,47,$A2,60,$A3,60,$A3,60,$A2,71,$A3,71,$A3,71,$A2,71,$A2
        dta 71,$A2,71,$A1,71,$A1,71,$A1,71,$A1,0
sparkle dta 60,$A3,60,$A2,47,$A3,47,$A2,40,$A3,40,$A2,29,$A4,29,$A3,29,$A3,29,$A3
        dta 29,$A2,29,$A2,29,$A2,29,$A2,29,$A2,29,$A1,29,$A1,29,$A1,29,$A1,29,$A1
        dta 29,$A1,0
cursor  dta a(0)
echo    dta a(0)
frames  dta 0
enabled dta 1
main_on dta 0
delay   dta 0
shape   dta 0
level   dta 0
.endl
        icl 'gallery.inc'
        icl 'duel.inc'
release_ui_end
        ert release_ui_end>$C000
