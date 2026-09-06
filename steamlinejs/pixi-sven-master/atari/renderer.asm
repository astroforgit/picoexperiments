; One opaque background copy, then actors sorted by their baseline.
; All sprites share dimensions and a bottom-center anchor.
render
        ldx #20
bg_command
        lda background_bcb,x
        sta command,x
        dex
        bpl bg_command
        lda back
        sta command+8
        jsr blit
        lda #0
        sta entity
        sta player_drawn
entity_loop
        ldy entity
        ldx depth_order,y
        lda player_drawn
        bne draw_sheep
        lda sheep_y,x
        cmp py
        bcc draw_sheep
        jsr draw_player
        ldy entity
        ldx depth_order,y
draw_sheep
        lda alive,x
        beq next_entity
        lda sheep_x,x
        sta draw_x
        lda sheep_y,x
        sta draw_y
        lda alive,x
        cmp #2
        beq draw_smoke
        lda #20
        jsr sprite
        jmp next_entity
draw_smoke
        lda vanish,x
        tax
        lda smoke_frames,x
        jsr sprite
next_entity
        inc entity
        lda entity
        cmp #8
        bne entity_loop
        lda player_drawn
        bne present
        jsr draw_player
present
        jsr wait_blit
        lda $14
wait_frame
        cmp $14
        beq wait_frame
        ldy #$41
        lda back
        beq show_a
        lda #20
show_a  sta (reg),y
        lda back
        eor #1
        sta back
        lda score
        clc
        adc #16
        sta status+6
        lda seconds
        ldx #0
subtract_tens
        cmp #10
        bcc digits
        sec
        sbc #10
        inx
        bne subtract_tens
digits  clc
        adc #16
        sta status+21
        txa
        clc
        adc #16
        sta status+20
        rts

draw_player
        lda #1
        sta player_drawn
        lda px
        sta draw_x
        lda py
        sta draw_y
        lda moving
        beq idle_sprite
        lda phase
        lsr
        lsr
        lsr
        and #3
        ora direction
        jmp sprite
idle_sprite
        lda direction
        lsr
        lsr
        clc
        adc #16
sprite
        tax
        lda sprite_lo,x
        sta command
        lda sprite_hi,x
        sta command+1
        lda sprite_bank,x
        sta command+2
        lda #SPRITE_W
        sta command+3
        lda #0
        sta command+4
        sta command+13
        lda #SPRITE_W-1
        sta command+12
        lda #SPRITE_H-1
        sta command+14
        lda #1
        sta command+20
        ; Constant-time Y*320+X, replacing up to 148 repeated additions.
        ldx draw_y
        clc
        lda row_lo,x
        adc draw_x
        sta command+6
        lda row_hi,x
        adc #0
        sta command+7
blit
        jsr wait_blit
        jsr map_control
        ldx #20
copy_command
        lda command,x
        sta $9100,x
        dex
        bpl copy_command
        ldy #$53
        lda #1
        sta (reg),y
        rts
wait_blit
        ldy #$53
blit_busy
        lda (reg),y
        bne blit_busy
        rts
map_control
        ldy #$5f
        lda #$ff
        sta (reg),y
        rts

back dta 1
entity dta 0
player_drawn dta 0
draw_x dta 0
draw_y dta 0
depth_order dta 2,0,1,3,4,5,7,6
smoke_frames :42 dta 24+(#/3)
row_lo :200 dta <(#*320)
row_hi :200 dta >(#*320)
sprite_lo :SPRITE_COUNT dta <($2fa00+#*SPRITE_SIZE)
sprite_hi :SPRITE_COUNT dta >($2fa00+#*SPRITE_SIZE)
sprite_bank :SPRITE_COUNT dta ^($2fa00+#*SPRITE_SIZE)
background_bcb
        dta $00,$00,$02,a(320),1
        dta $00,$00,$00,a(320),1
        dta a(319),199,$ff,0,0,0,0,0
command :21 dta 0
xdls
        dta $74,$08,7,0,0,0,a(320),$11,$ff
        dta $62,$88,199,0,0,0,a(320),$11,$ff
        dta $74,$08,7,0,0,1,a(320),$11,$ff
        dta $62,$88,199,0,0,1,a(320),$11,$ff
palette ins 'generated/palette.bin'
; ANTIC underlay blank during the meadow; two 40-column rows beneath it.
display_list
        :26 dta $70
        dta $42,a(status),$02,$41,a(display_list)
status
        dta d'SHEEP 0/8     TIME  90    SVEN VBXE     '
        dta d'                                        '
        ert *-status <> 80
messages_lo dta <ready,<playing,<won,<timeout,<paused
messages_hi dta >ready,>playing,>won,>timeout,>paused
ready   dta d'FIRE TO START - JOYSTICK OR WASD TO MOVE'
playing dta d'FIRE COLLECT / P PAUSE / R RESTART      '
won     dta d'ALL SHEEP FOUND! FIRE TO PLAY AGAIN     '
timeout dta d'TIME UP! FIRE TO TRY AGAIN              '
paused  dta d'PAUSED - P/SELECT RESUME - R RESTART    '
missing dta d'VBXE FX REQUIRED AT D600 OR D700        '
