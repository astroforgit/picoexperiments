        icl 'vars.asm'
        icl '../gen/rt-labels.asm'
        icl '../gen/pause-state.asm'
        org $c000
pause_check
        lda $d20f
        and #4
        bne released
        lda $d209
        and #$3f
        cmp #28
        bne released
        lda match_escape
        bne inactive
        inc match_escape
        jmp open_popup
released
        lda #0
        sta match_escape
inactive
        lda #0
        rts
open_popup
        lda #1
        sta league_screen
settle
        lda pending
        bne settle
        jsr BLIT_WAIT
        lda $20
        pha
        lda $21
        pha
        lda #0
        sta restore
        jsr copy_area
        lda front
        asl
        asl
        ora #$81
        jsr MEMB
        lda #0
        sta $20
        lda #$50
        sta $21
        lda #<bitmap
        ldy #>bitmap
        ldx league_match
        cpx #1
        beq choose_bitmap
        lda #<friendly_bitmap
        ldy #>friendly_bitmap
choose_bitmap
        sta read_bits+1
        sty read_bits+2
        ldx #5
        stx count
bitmap_page
        ldx #0
read_bits
        lda bitmap,x
        sta bits
        txa
        pha
        ldx #8
pixel
        asl bits
        lda #$10
        bcc dark
        lda #$18
dark
        ldy #0
        sta ($20),y
        inc $20
        bne pixel_next
        inc $21
pixel_next
        dex
        bne pixel
        pla
        tax
        inx
        bne read_bits
        inc read_bits+2
        dec count
        bne bitmap_page
; Require release before accepting either confirmation or cancellation.
release_wait
        lda $d20f
        and #4
        beq release_wait
        lda joy1
        and #16
        beq release_wait
answer_wait
        lda $d20f
        and #4
        bne check_fire
        lda $d209
        and #$3f
        cmp #28
        beq resume
check_fire
        lda joy1
        and #16
        bne answer_wait
        lda #1
        sta match_abort
        lda league_match
        cmp #2
        bne check_season
        ldx #10
restore_classic_options
        lda classic_settings,x
        sta $92b7,x
        dex
        bpl restore_classic_options
        jmp stop_done
check_season
        cmp #1
        bne stop_done
        lda #$9e
        jsr MEMB
        ldx #0
        lda SEASON_TEAM
        cmp HOME_TEAM
        beq home_forfeit
        inx
home_forfeit
        lda #0
        sta $010e,x
        txa
        eor #1
        tax
        lda #3
        sta $010e,x
        ldx #21
        lda #0
clear_goals
        sta LEAGUE_MATCH_SCORERS,x
        dex
        bpl clear_goals
stop_done
        lda #1
        bne finish
resume
        lda #1
        sta restore
        jsr copy_area
        lda #0
finish
        sta answer
        lda #0
        jsr MEMB
        sta league_screen
        lda #1
        sta first
        lda frames
        sta lastwait
        pla
        sta $21
        pla
        sta $20
        lda answer
        rts
; Keep the covered pixels in the idle framebuffer. Both ranges are in
; one 16K MEMAC window. No game logic or C64 timer runs while paused.
copy_area
        lda #0
        sta $20
        lda #$50
        sta $21
        lda #40
        sta count
copy_page
        lda front
        ldx restore
        beq source_ready
        lda back
source_ready
        asl
        asl
        ora #$81
        jsr MEMB
        ldy #0
read_page
        lda ($20),y
        sta buffer,y
        iny
        bne read_page
        lda back
        ldx restore
        beq dest_ready
        lda front
dest_ready
        asl
        asl
        ora #$81
        jsr MEMB
        ldy #0
write_page
        lda buffer,y
        sta ($20),y
        iny
        bne write_page
        inc $21
        dec count
        bne copy_page
        rts
restore dta 0
answer dta 0
count dta 0
bits dta 0
buffer .ds 256
bitmap ins '../gen/pause-bitmap.bin'
friendly_bitmap ins '../gen/pause-friendly.bin'
        ert * > $d000
