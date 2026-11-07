; One save slot in story.SAVE_SECTOR, offered only when the single-file boot ATR
; started the game (its loader sets boot_disk). Sector: 'NYS1', data length,
; the campaign fields below, then a checksum. Staging uses the $8400 story page.
.local savegame
boot_disk dta 0                 ; 1 after the boot ATR's loader started the game
BUFFER = $8400
HEADER = 5
FIELDS = 15
SAVE_BYTES = 42
field_lo dta <gold,<difficulty,<building_levels,<army_units,<army_count
         dta <army_paid_lo,<army_paid_hi,<region_wins,<battle.encounter_seed
         dta <gallery.notes_found,<gallery.notes_pending,<gallery.painting_pending
         dta <gallery.collected,<gallery.wins,<gallery.order
field_hi dta >gold,>difficulty,>building_levels,>army_units,>army_count
         dta >army_paid_lo,>army_paid_hi,>region_wins,>battle.encounter_seed
         dta >gallery.notes_found,>gallery.notes_pending,>gallery.painting_pending
         dta >gallery.collected,>gallery.wins,>gallery.order
field_len dta 2,1,5,5,1,5,5,4,1,1,1,1,1,1,8
magic   dta c'NYS1'

; Campaign -> BUFFER, with header and checksum; then write the sector.
; C set when the disk accepted it.
.proc save
        jsr sfx.finish
        ldx #3
?magic  mva magic,x BUFFER,x
        dex
        bpl ?magic
        mva #SAVE_BYTES BUFFER+4
        mwa #BUFFER+HEADER data_ptr
        ldx #0
?field  jsr point
?copy   lda (work_ptr),y
        sta (data_ptr),y
        dey
        bpl ?copy
        jsr advance
        bne ?field
        jsr checksum
        sta BUFFER+HEADER+SAVE_BYTES
        jmp write
.endp

; Read and check the sector; on success start a fresh city and restore the
; campaign over it. C clear (nothing changed) when there is no valid save.
.proc load
        jsr sfx.finish
        mwa #story.SAVE_SECTOR story.read_sector
        mva #0 story.read_size
        jsr story.read
        bcc ?done
        ldx #3
?magic  lda BUFFER,x
        cmp magic,x
        bne ?none
        dex
        bpl ?magic
        lda BUFFER+4
        cmp #SAVE_BYTES
        bne ?none
        jsr checksum
        cmp BUFFER+HEADER+SAVE_BYTES
        bne ?none
        jsr new_city
        mwa #BUFFER+HEADER data_ptr
        ldx #0
?field  jsr point
?copy   lda (data_ptr),y
        sta (work_ptr),y
        dey
        bpl ?copy
        jsr advance
        bne ?field
        jsr capacity
        mva #1 dirty
        sec
        rts
?none   clc
?done   rts
.endp

; work_ptr = field X, Y = its last byte offset.
.proc point
        mva field_lo,x work_ptr
        mva field_hi,x work_ptr+1
        ldy field_len,x
        dey
        rts
.endp
; Step data_ptr past field X; Z set after the last field.
.proc advance
        lda field_len,x
        clc
        adc data_ptr
        sta data_ptr
        bcc ?next
        inc data_ptr+1
?next   inx
        cpx #FIELDS
        rts
.endp
.proc checksum
        lda #$A5
        ldx #SAVE_BYTES-1
?sum    clc
        adc BUFFER+HEADER,x
        dex
        bpl ?sum
        rts
.endp
; SIO write with verify of BUFFER to the save sector. C set on success.
.proc write
        mva #$31 $0300
        mva #1 $0301
        mva #$57 $0302
        mva #$80 $0303
        mwa #BUFFER $0304
        mva #7 $0306
        mwa #256 $0308
        mwa #story.SAVE_SECTOR $030A
        jsr $E459
        tya
        bmi ?failed
        sec
        rts
?failed clc
        rts
.endp

; City GAME MENU (Escape/SELECT): SAVE GAME, LOAD GAME, BACK.
.proc menu
        mva #0 choice
        sta status
        mva #1 latch
        mva #0 neutral
redraw  jsr draw
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
        beq pick
        cmp #1
        beq previous
        inc choice
        lda choice
        cmp #3
        bcc redraw
        mva #0 choice
        jmp redraw
previous
        dec choice
        bpl redraw
        mva #2 choice
        jmp redraw
pick    lda choice
        cmp #2
        beq done
        cmp #1
        beq restore
        mva #1 status            ; saving...
        jsr draw
        jsr save
        lda #2                  ; saved
        bcs report
        lda #3                  ; save failed
report  sta status
        jmp redraw
restore mva #4 status            ; loading...
        jsr draw
        jsr load
        bcs done
        mva #5 status            ; no saved game / read error
        jmp redraw
released
        inc neutral
        lda neutral
        cmp #2
        jcc loop
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

.proc draw
        mva back_bank render_bank
        jsr copy_background_cache
        rect 60,50,200,100,1
        rect 62,52,196,96,7
        rect 62,52,196,16,1
        mwa #60 calc_x
        mva #50 calc_y
        mwa #200 fr_w
        mva #100 fr_h
        mva #2 fr_col
        jsr outline
        labeltext 130,56,s_title
        mva #0 line
?row    ldx line
        lda row_y,x
        sta text_y
        mva row_lo,x text_src
        mva row_hi,x text_src+1
        mwa #110 text_x
        jsr draw_text
        lda line
        cmp choice
        bne ?next
        ldx line
        lda row_y,x
        sec
        sbc #3
        sta calc_y
        mwa #96 calc_x
        mwa #128 fr_w
        mva #14 fr_h
        mva #2 fr_col
        jsr outline
?next   inc line
        lda line
        cmp #3
        bne ?row
        ldx status
        beq ?show
        mva status_lo,x text_src
        mva status_hi,x text_src+1
        mwa #72 text_x
        mva #134 text_y
        jsr draw_text
?show   jsr wait_blit
        jmp present_back_buffer
.endp
choice  dta 0
status  dta 0
latch   dta 0
neutral dta 0
action  dta 0
line    dta 0
row_y   dta 78,94,110
row_lo  dta <s_save,<s_load,<s_back
row_hi  dta >s_save,>s_load,>s_back
status_lo dta 0,<s_saving,<s_saved,<s_save_failed,<s_loading,<s_no_save
status_hi dta 0,>s_saving,>s_saved,>s_save_failed,>s_loading,>s_no_save
s_title dta c'GAME MENU',0
s_save  dta c'SAVE GAME',0
s_load  dta c'LOAD GAME',0
s_back  dta c'BACK',0
s_saving dta c'SAVING...',0
s_saved dta c'GAME SAVED.',0
s_save_failed dta c'SAVE FAILED: DISK LOCKED?',0
s_loading dta c'LOADING...',0
s_no_save dta c'NO SAVED GAME.',0
.endl
