; Arlasoft Soccer native 6502 bridge. Original logic stays at original addresses.
; Runtime occupies former VIC-only graphics RAM. All art is uploaded to VBXE.
        org $dc10
busy    .ds 1
frames  .ds 1
render_phase .ds 1
front   .ds 1
back    .ds 1
vbpage  .ds 1
rowno   .ds 1
colno   .ds 1
charid  .ds 1
colorid .ds 1
sprno   .ds 1
xx      .ds 2
yy      .ds 1
idx     .ds 1
joyone  .ds 1
joytwo  .ds 1
bannerrow .ds 1
invw .ds 1
invh .ds 1
invrow .ds 1
destrow .ds 2
startframe .ds 1
scrollx .ds 1
scrolly .ds 1
pending .ds 1
clipx .ds 1
clipy .ds 1
srcskip .ds 1
lastwait .ds 1
skipped .ds 1
clears .ds 1
ptrsave .ds 2
sstep .ds 1
colbase .ds 1
colleft .ds 1
scrhi .ds 1
scanblk .ds 1
scanx .ds 1
scanbase .ds 2
scancache .ds 2
idxhi .ds 1
scanend .ds 1
scanrot .ds 1
lastscrhi .ds 1
lastd018 .ds 1
flipdir .ds 1
flipseq .ds 1
lastseq .ds 1
render_full .ds 1
rowbanner .ds 25
        org $dd80
irqvec  .ds 2
nmivec  .ds 2
        org $dd90
joy1    .ds 1
joy2    .ds 1
ptr = $fc
LIST = $7200             ; chained BCB list for compose/sprites (VRAM $6F200)

SMALL   = $dd10        ; small tables, copied from small_src at boot
banner_signature = SMALL+0
row40_lo = SMALL+4
row40_hi = SMALL+29
row_dest = SMALL+54
blk_lo = SMALL+79
blk_hi = SMALL+83
dir_dx = SMALL+87
SMALL_LEN = 95

        org $f000
nmi
        pha
        txa
        pha
        tya
        pha
        ; The game may be interrupted inside SED code; RTI restores its D flag.
        ; The runtime itself always works in binary.
        cld
        lda #0
        sta $d40f
        inc frames
        ; Publish only completed frames, during vertical blank. Both XDLs
        ; are immutable, so a frame cannot mix the old/new screen addresses.
        lda pending
        beq no_publish
vbrel_0
        lda $d653
        bne no_publish
        lda pending
        sec
        sbc #1
        sta front
        asl
        asl
        asl
        asl
        asl
vbrel_1
        sta $d641
        lda #0
        sta pending
no_publish
        lda $d300
        and #15
        ora #$10
        ldx $d010
        bne input1
        and #$ef
input1  sta joy1
        lda $d300
        lsr
        lsr
        lsr
        lsr
        ora #$10
        ldx $d011
        bne input2
        and #$ef
input2  sta joy2
        ; Respect the interrupted game's SEI critical sections.
        tsx
        lda $0104,x
        and #4
        bne skip_tick
        lda $de1a
        and #1
        beq skip_tick
        ; Like a C64 IRQ, the game's handler keeps the interrupted D flag.
        lda $0104,x
        and #8
        beq tick_binary
        sed
tick_binary
        jsr tick
skip_tick
        ; The game flips its double-buffered screen after copying it shifted
        ; by one character; $11db holds that copy's direction (0-7, see the
        ; game's offset table at $1471), or $ff.
        lda $de18
        cmp lastd018
        beq no_flip
        sta lastd018
        lda $11db
        sta flipdir
        inc flipseq
no_flip
        lda busy
        bne nmi_done
        inc busy
        lda $97dd
        bne skip_draw
        inc render_phase
        lda render_phase
        and #7
        bne skip_draw
        ; Draw one coherent snapshot with the game paused. Double buffered.
        lda $de11
        and #$10
        beq skip_draw
        lda pending
        bne skip_draw
        lda #1
        sta render_full
        jsr render
skip_draw
        dec busy
nmi_done
        pla
        tay
        pla
        tax
        pla
irq_exit
        rti

tick
        lda #>tick_return
        pha
        lda #<tick_return
        pha
        lda #$24
        pha
        jmp $922e
tick_return
        rts

; Replacement for the game's raster-dependent frame wait.
frame_wait
        php
        cld
        txa
        pha
        tya
        pha
        ; Draw only when the game loop is on time and the previous picture
        ; has been shown; otherwise keep the C64 logic at 50 Hz.
        lda pending
        bne fw_wait
        lda frames
        cmp lastwait
        beq fw_draw
        inc skipped
        lda skipped
        cmp #3
        bcc fw_wait
fw_draw
        inc busy
        lda #0
        sta render_full
        jsr render
        lda #0
        sta render_phase
        sta skipped
        dec busy
fw_wait
        lda lastwait
wait_tick
        cmp frames
        beq wait_tick
        lda frames
        sta lastwait
        pla
        tay
        pla
        tax
        lda #0
        sta $91ff
        plp
        rts

render
        lda pending
        bne render
        lda $de16
        and #7
        sta scrollx
        lda $de11
        and #7
        sta scrolly
        lda #$f4
vbrel_2
        sta $d65f
        lda #$9b
vbrel_3
        sta $d65d
        ; The previous frame's list has finished (it was published). Point
        ; the blitter back at the shared single BCB.
        jsr wait_blit
        lda #0
vbrel_4
        sta $d650
        lda #$f1
vbrel_5
        sta $d651
        lda #6
vbrel_6
        sta $d652
        lda ptr
        sta ptrsave
        lda ptr+1
        sta ptrsave+1
        lda front
        eor #1
        sta back
        lda #$a0
        sta cache_char+2
        sta save_char+2
        clc
        adc #4
        sta cache_color+2
        sta save_color+2
        lda #0
        sta cache_char+1
        sta save_char+1
        sta cache_color+1
        sta save_color+1
        ; update 3 VIC shared palette colours (all others fixed)
        ldx #0
shared_pal
        txa
vbrel_7
        sta $d644
        lda $de21,x
        and #15
        tay
        lda c64_r,y
vbrel_8
        sta $d646
        lda c64_g,y
vbrel_9
        sta $d647
        lda c64_b,y
vbrel_10
        sta $d648
        inx
        cpx #3
        bne shared_pal
        lda $de18
        and #$10
        lsr
        lsr
        ora #$c0
        sta scrhi
        ; tiles: 8x8, source stride 8, opaque
        lda #8
        sta $7103
        lda #0
        sta $7104
        sta $7114
        lda #7
        sta $710c
        sta $710e
        lda #0
        sta $710d
        sta $7106
        sta $7107
        lda #2
        sta $7108
        ; After one C64 screen flip, move the existing picture by the copy
        ; offset with the blitter and then check every cell. Otherwise check
        ; a quarter of the screen per picture (all of it for NMI drawing).
        ldx flipseq
        lda flipdir
        sta charid
        txa
        sec
        sbc lastseq
        stx lastseq
        tay
        lda scrhi
        cmp lastscrhi
        beq same_screen
        sta lastscrhi
        cpy #1
        bne full_scan
        lda charid
        jsr shift_picture
        jmp full_scan
same_screen
        lda render_full
        bne full_scan
        lda scanrot
        sta scanblk
        clc
        adc #1
        sta scanend
        and #3
        sta scanrot
        jmp scan_chosen
full_scan
        lda #0
        sta scanblk
        lda #4
        sta scanend
scan_chosen
        ; Colour RAM rarely changes: compare it on three rows per picture.
        ; (Characters are covered by the scan below.)
        lda colbase
        sta rowno
        lda #3
        sta colleft
colour_rows
        jsr setup_row
        lda get_color+1
        sta cq_color+1
        sta cq_rawc+1
        lda get_color+2
        sta cq_color+2
        lda cache_char+2
        clc
        adc #12
        sta cq_rawc+2
        ldx #39
cq_loop
cq_color
        lda $d800,x
cq_rawc
        cmp $ac00,x
        bne cq_dirty
        dex
        bpl cq_loop
        bmi cq_next
cq_dirty
        jsr process_row
cq_next
        ldx rowno
        inx
        cpx #25
        bcc cq_row_ok
        ldx #0
cq_row_ok
        stx rowno
        dec colleft
        bne colour_rows
        stx colbase
        ; Characters: an unrolled linear pass over 250-byte blocks of the
        ; 1000 cells; a mismatch redraws the whole row it belongs to.
scan_block
        ldy scanblk
        lda blk_lo,y
        sta scanbase
        clc
        adc #<$a800
        sta scancache
        lda blk_hi,y
        adc #>$a800
        sta scancache+1
        lda blk_hi,y
        clc
        adc scrhi
        sta scanbase+1
        lda scanbase
        clc
        adc #0
        sta sl0+1
        lda scanbase+1
        adc #0
        sta sl0+2
        lda scancache
        clc
        adc #0
        sta sc0+1
        lda scancache+1
        adc #0
        sta sc0+2
        lda scanbase
        clc
        adc #1
        sta sl1+1
        lda scanbase+1
        adc #0
        sta sl1+2
        lda scancache
        clc
        adc #1
        sta sc1+1
        lda scancache+1
        adc #0
        sta sc1+2
        lda scanbase
        clc
        adc #2
        sta sl2+1
        lda scanbase+1
        adc #0
        sta sl2+2
        lda scancache
        clc
        adc #2
        sta sc2+1
        lda scancache+1
        adc #0
        sta sc2+2
        lda scanbase
        clc
        adc #3
        sta sl3+1
        lda scanbase+1
        adc #0
        sta sl3+2
        lda scancache
        clc
        adc #3
        sta sc3+1
        lda scancache+1
        adc #0
        sta sc3+2
        lda scanbase
        clc
        adc #4
        sta sl4+1
        lda scanbase+1
        adc #0
        sta sl4+2
        lda scancache
        clc
        adc #4
        sta sc4+1
        lda scancache+1
        adc #0
        sta sc4+2
        ldx #245
scan_loop
sl4
        lda $ffff,x
sc4
        cmp $ffff,x
        bne sm4
sl3
        lda $ffff,x
sc3
        cmp $ffff,x
        bne sm3
sl2
        lda $ffff,x
sc2
        cmp $ffff,x
        bne sm2
sl1
        lda $ffff,x
sc1
        cmp $ffff,x
        bne sm1
sl0
        lda $ffff,x
sc0
        cmp $ffff,x
        bne sm0
        txa
        sec
        sbc #5
        tax
        bcs scan_loop
        inc scanblk
        lda scanblk
        cmp scanend
        jne scan_block
        jmp scan_done
sm4
        lda #4
        bpl scan_hit
sm3
        lda #3
        bpl scan_hit
sm2
        lda #2
        bpl scan_hit
sm1
        lda #1
        bpl scan_hit
sm0
        lda #0
        bpl scan_hit
scan_hit
        ; Row = (block*250 + x + k) / 40.
        stx scanx
        clc
        adc scanx
        ldy scanblk
        clc
        adc blk_lo,y
        sta idx
        lda blk_hi,y
        adc #0
        sta idxhi
        ldx #0
row_div
        lda idx
        sec
        sbc #40
        tay
        lda idxhi
        sbc #0
        bcc row_found
        sta idxhi
        sty idx
        inx
        bne row_div
row_found
        stx rowno
        jsr setup_row
        jsr process_row
        ldx scanx
        jmp scan_loop
scan_done
        jsr compose_background
        jsr players
        jsr ball
        jsr start_list
        lda ptrsave
        sta ptr
        lda ptrsave+1
        sta ptr+1
        lda back
        clc
        adc #1
        sta pending
        lda #0
vbrel_11
        sta $d65d
vbrel_12
        sta $d65f
        rts

process_row
        ; Save every raw source byte. The mapped cache remains independent
        ; because advertising uses generated glyphs instead of source glyphs.
        lda get_char+1
        sta raw_fetch_char+1
        lda get_char+2
        sta raw_fetch_char+2
        lda get_color+1
        sta raw_fetch_color+1
        lda get_color+2
        sta raw_fetch_color+2
        lda cache_char+1
        sta raw_save_char+1
        sta raw_save_color+1
        lda cache_char+2
        clc
        adc #8
        sta raw_save_char+2
        adc #4
        sta raw_save_color+2
        ldx #39
raw_copy
raw_fetch_char
        lda $c000,x
raw_save_char
        sta $a800,x
raw_fetch_color
        lda $d800,x
raw_save_color
        sta $ac00,x
        dex
        bpl raw_copy
        lda #0
        sta bannerrow
        ; Recognize ARLA in the original advertising text at any scroll column.
        ; Menu uses a white background and retains its original title/credits.
        lda $de21
        cmp #1
        beq banner_checked
        lda get_char+1
        sta banner_probe+1
        lda get_char+2
        sta banner_probe+2
        ldy #0
        ldx #0
banner_probe
        lda $ffff,y
        cmp banner_signature,x
        bne banner_restart
        inx
        cpx #4
        beq banner_found
        bne banner_step
banner_restart
        ldx #0
        cmp #217
        bne banner_step
        inx
banner_step
        iny
        cpy #40
        bne banner_probe
        beq banner_checked
banner_found
        inc bannerrow
banner_checked
        ldx rowno
        lda bannerrow
        sta rowbanner,x
        ldx #0
char_loop
get_char
        lda $c000,x
        tay
get_color
        lda $d800,x
        and #15
        sta colorid
        lda bannerrow
        beq normal_cache
        txa
        tay
        lda #16
        sta colorid
normal_cache
        lda colorid
cache_color
        cmp $a400,x
        bne tile_dirty
        tya
cache_char
        cmp $a000,x
        bne tile_dirty
        inx
        cpx #40
        bne char_loop
        rts
tile_dirty
        ; A picture move may still be running: the shared BCB is in use.
        jsr wait_blit
        sty charid

char_changed
        stx colno
        ; Calculate destination only for changed cells.
        txa
        asl
        asl
        asl
        sta $7106
        lda #0
        adc destrow+1
        sta $7107
        clc
        lda $7106
        adc destrow
        sta $7106
        bcc dest_ready
        inc $7107
dest_ready
        lda charid
save_char
        sta $a000,x
        lda colorid
save_color
        sta $a400,x
        jsr wait_blit
        lda bannerrow
        beq normal_tile
        lda colno
        and #3
        asl
        asl
        asl
        asl
        asl
        asl
        sta $7100
        lda colno
        lsr
        lsr
        ora #$80
        sta $7101
        lda #7
        sta $7102
        jsr blit
        jmp char_advance
normal_tile
        ; 4096-entry planar address lookup mapped beside the BCB.
        lda colorid
        ora #$40
        sta lookup_lo+2
        lda colorid
        ora #$50
        sta lookup_hi+2
        lda colorid
        ora #$60
        sta lookup_bank+2
        ldx charid
lookup_lo
        lda $4000,x
        sta $7100
lookup_hi
        lda $5000,x
        sta $7101
lookup_bank
        lda $6000,x
        sta $7102
        ldx colno
        jsr blit
char_advance
        inx
        cpx #40
        jne char_loop
        rts

; Move character rows 1-24 of the char layer and of the four cell caches
; by one cell in C64 copy direction A (0-7). Uses the per-direction BCB
; lists the build stores at $6F500 + 128*direction: four cache moves,
; then the char layer move (left running).
shift_picture
        cmp #8
        bcc shift_found
        rts
shift_found
        tax
        stx sprno
        txa
        lsr
        tay
        lda #0
        ror
vbrel_13
        sta $d650
        tya
        clc
        adc #$f5
vbrel_14
        sta $d651
        lda #6
vbrel_15
        sta $d652
        lda #1
vbrel_16
        sta $d653
        jsr wait_blit
        lda sprno
        lsr
        lda #0
        ror
        clc
        adc #84
vbrel_17
        sta $d650
        lda #1
vbrel_18
        sta $d653
        ; Advertising glyphs follow screen columns: horizontal moves must
        ; redraw those rows (and their neighbours, which a vertical part
        ; of the move may have shifted them to).
        ldx sprno
        lda dir_dx,x
        beq shift_done
        ldy #24
shift_banner
        lda rowbanner,y
        beq shift_next
        lda #0
        sta rowbanner,y
        dey
        jsr invalidate_row
        iny
        jsr invalidate_row
        iny
        jsr invalidate_row
        dey
shift_next
        dey
        bne shift_banner
shift_done
        rts

; Make the raw cache of row Y (1-24, others ignored) differ from its source.
invalidate_row
        cpy #1
        bcc inv_skip
        cpy #25
        bcs inv_skip
        lda row40_lo,y
        sta inv_load+1
        sta inv_store+1
        lda row40_hi,y
        clc
        adc #$a8
        sta inv_load+2
        sta inv_store+2
inv_load
        lda $a800
        eor #$ff
inv_store
        sta $a800
inv_skip
        rts

; Point the row routines at character row rowno.
setup_row
        ldy rowno
        lda row40_lo,y
        sta get_char+1
        sta get_color+1
        sta cache_char+1
        sta save_char+1
        sta cache_color+1
        sta save_color+1
        lda row40_hi,y
        clc
        adc scrhi
        sta get_char+2
        lda row40_hi,y
        clc
        adc #$d8
        sta get_color+2
        lda row40_hi,y
        clc
        adc #$a0
        sta cache_char+2
        sta save_char+2
        adc #4
        sta cache_color+2
        sta save_color+2
        lda #0
        sta destrow
        lda row_dest,y
        sta destrow+1
        rts

compose_background
        ; Borders and the bottom strip are never drawn, so each framebuffer
        ; needs a single clear after boot.
        lda clears
        beq compose_list
        dec clears
        lda #0
        sta $7114
        sta $7106
        sta $7107
        sta $7103
        sta $7104
        sta $7100
        sta $7101
        sta $7102
        sta $710f
        sta $7110
        lda back
        sta $7108
        lda #$3f
        sta $710c
        lda #1
        sta $710d
        lda #199
        sta $710e
        jsr blit
        lda #0
        sta $710d
        lda #$ff
        sta $710f
compose_list
        ; List entry 0: pitch. C64 origin is x=24+fineX, y=51+fineY-3. Crop
        ; eight pixels around the viewport, so no uninitialised scroll edge
        ; is exposed. Entry 1: the unscrolled top character row.
        lda #11
        sec
        sbc scrolly
        tay
        lda #8
        sec
        sbc scrollx
        clc
        adc pixel_y_lo,y
        sta LIST
        lda pixel_y_hi,y
        adc #0
        sta LIST+1
        lda back
        sta LIST+8
        sta LIST+21+8
        lda #<(LIST+42)
        sta ptr
        lda #>(LIST+42)
        sta ptr+1
        rts

; Append a sprite BCB: source lo/mid in srcskip/idx (bank 6), width-1
; in clipx, height-1 in clipy, source row step in sstep, destination in
; destrow (in the back buffer).
add_sprite
        ldy #0
        lda srcskip
        sta (ptr),y
        iny
        lda idx
        sta (ptr),y
        ldy #3
        lda sstep
        sta (ptr),y
        ldy #6
        lda destrow
        sta (ptr),y
        iny
        lda destrow+1
        sta (ptr),y
        iny
        lda back
        sta (ptr),y
        ldy #12
        lda clipx
        sta (ptr),y
        ldy #14
        lda clipy
        sta (ptr),y
        iny
        lda #$ff
        sta (ptr),y
        ldy #20
        lda #9
        sta (ptr),y
        clc
        lda ptr
        adc #21
        sta ptr
        bcc add_done
        inc ptr+1
add_done
        rts

; Terminate the list with a blit whose AND mask makes every pixel
; transparent, then start it. The CPU does not wait for it.
start_list
        jsr wait_blit
        lda #0
        ldy #12
        sta (ptr),y
        ldy #14
        sta (ptr),y
        iny
        sta (ptr),y
        ldy #20
        lda #1
        sta (ptr),y
        lda #0
vbrel_19
        sta $d650
        lda #$f2
vbrel_20
        sta $d651
        lda #6
vbrel_21
        sta $d652
        lda #1
vbrel_22
        sta $d653
        rts



wait_blit
vbrel_23
        lda $d653
        bne wait_blit
        rts
blit
        jsr wait_blit
        lda #0
vbrel_24
        sta $d650
        lda #$f1
vbrel_25
        sta $d651
        lda #6
vbrel_26
        sta $d652
        lda #1
vbrel_27
        sta $d653
        ; Wait before the next operation edits this shared BCB.
        jmp wait_blit

; Last boot step, outside $F800-$FFFF: put back the C64 game code the
; boot-only part occupied (staged at VRAM $5F000), then start the game.
finish_boot
        lda #$80|$17
vbrel_28
        sta $d65d
        ldx #0
fb_copy
        lda $7000,x
        sta $f800,x
        lda $7100,x
        sta $f900,x
        lda $7200,x
        sta $fa00,x
        lda $7300,x
        sta $fb00,x
        lda $7400,x
        sta $fc00,x
        lda $7500,x
        sta $fd00,x
        lda $7600,x
        sta $fe00,x
        lda $7700,x
        sta $ff00,x
        inx
        bne fb_copy
        lda #0
vbrel_29
        sta $d65d
        lda #<nmi
        sta $fffa
        lda #>nmi
        sta $fffb
        lda #<irq_exit
        sta $fffe
        lda #>irq_exit
        sta $ffff
        lda #$40
        sta $d40e
        jmp $975b
        ert * > $f800


; Sprite list building and its tables live in unused C64 sprite-pattern RAM.
        org $cc40
players
        lda #16
        sta sstep
        lda #0
        sta sprno
player_loop
        ldx sprno
        lda $cd,x
        cmp #32
        jcc player_next
        cmp #64
        jcs player_next
        ; Clip the real 16x16 rectangle against the visible field.
        lda #15
        sta clipx
        sta clipy
        lda #0
        sta srcskip
        lda $e4,x
        cmp #42
        jcc player_next
        cmp #241
        jcs player_next
        cmp #57
        bcs player_yinside
        sta yy
        lda #57
        sec
        sbc yy
        sta idx
        lda #15
        sec
        sbc idx
        sta clipy
        lda idx
        asl
        asl
        asl
        asl
        sta srcskip
        lda #8
        bne player_ystore
player_yinside
        sec
        sbc #49
        cmp #177
        bcc player_ystore
        sta yy
        lda #191
        sec
        sbc yy
        sta clipy
        lda yy
player_ystore
        sta yy
        lda $9f,x
        sta xx
        lda $b6,x
        and #$80
        beq player_low
        lda #1
player_low
        sta xx+1
        sec
        lda xx
        sbc #20
        sta xx
        lda xx+1
        sbc #0
        sta xx+1
        bmi player_clipleft
        bne player_clipright
        lda xx
        cmp #8
        bcs player_xok
player_clipleft
        lda #8
        sec
        sbc xx
        cmp #16
        jcs player_next
        sta idx
        clc
        adc srcskip
        sta srcskip
        lda #15
        sec
        sbc idx
        sta clipx
        lda #8
        sta xx
        lda #0
        sta xx+1
        beq player_xok
player_clipright
        lda xx
        cmp #56
        jcs player_next
        cmp #41
        bcc player_xok
        lda #55
        sec
        sbc xx
        sta clipx
player_xok
        lda $cd,x
        sec
        sbc #32
        and #31
        sta idx
        ; C64 colour chooses team tint; light-blue uses second bank.
        lda $b6,x
        and #15
        cmp #7
        bne player_team
        lda idx
        ora #$20
        sta idx
player_team
        ; dest = yy*320 + xx
        ldy yy
        clc
        lda pixel_y_lo,y
        adc xx
        sta destrow
        lda pixel_y_hi,y
        adc xx+1
        sta destrow+1
        jsr add_sprite

player_next
        inc sprno
        lda sprno
        cmp #23
        jne player_loop
        rts
ball
        lda $de15
        and #$80
        jeq ball_end
        lda $de0f
        cmp #51
        jcc ball_end
        cmp #244
        jcs ball_end
        sec
        sbc #51
        sta yy
        lda $de0e
        sec
        sbc #24
        sta xx
        lda $de10
        and #$80
        beq ball_low
        lda #1
ball_low
        sbc #0
        bmi ball_end
        sta xx+1
        beq ball_xok
        lda xx
        cmp #56
        bcs ball_end
ball_xok
        lda #0
        sta srcskip
        lda #$ff
        sta idx
        lda #8
        sta sstep
        lda #7
        sta clipx
        sta clipy
        ldy yy
        clc
        lda pixel_y_lo,y
        adc xx
        sta destrow
        lda pixel_y_hi,y
        adc xx+1
        sta destrow+1
        jsr add_sprite

ball_end
        rts

pixel_y_lo ins '../gen/y-lo.bin',0,208
pixel_y_hi ins '../gen/y-hi.bin',0,208
c64_r   ins '../gen/c64-r.bin'
c64_g   ins '../gen/c64-g.bin'
c64_b   ins '../gen/c64-b.bin'
        ert * > $d000

; Boot-only code and data. finish_boot overwrites it with game code.
        org $f800
rt_boot
        sei
        cld
        sta vbpage
        cmp #$d6
        beq reloc_done
        ldx #0
reloc_loop
        lda reloc_lo,x
        sta ptr
        lda reloc_hi,x
        sta ptr+1
        ldy #0
        lda #$d7
        sta (ptr),y
        inx
        cpx #RELOC_COUNT
        bne reloc_loop
reloc_done
        ldx #0
restore_page
        txa
        and #$3f
        ora #$40
        sta restore_src+2
        stx restore_dst+2
        txa
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        ora #$9c
vbrel_30
        sta $d65d
        ldy #0
restore_src
        lda $4000,y
        sta $dd00,y
        iny
        bne restore_src
        lda #0
vbrel_31
        sta $d65d
restore_copy
        lda $dd00,y
restore_dst
        sta $0000,y
        iny
        bne restore_copy
        inx
        cpx #$d0
        bne restore_not_io
        ldx #$d8
restore_not_io
        cpx #$dc
        bne restore_not_vars
        ldx #$e0
restore_not_vars
        cpx #$f0
        bne restore_page
        ldx #$ff
        txs
        lda #0
        sta busy
        sta frames
        sta render_phase
        sta front
        sta pending
        sta lastwait
        sta skipped
        sta scanrot
        sta flipseq
        sta lastseq
        sta lastscrhi
        sta colbase
        sta $d400
        sta $d01a
        sta $d01b
        sta $d20e
        ldx #8
silence_pokey
        sta $d200,x
        dex
        bpl silence_pokey
        lda #3
        sta $d20f
        lda #2
        sta clears
        ; OS ROM must stay disabled: this code executes underneath it at $F000.
        lda #$fe
        sta $d301
        lda #<nmi
        sta $fffa
        lda #>nmi
        sta $fffb
        lda #<irq_exit
        sta $fffe
        lda #>irq_exit
        sta $ffff
        lda #$f8 ; map 4K window $F000? renderer needs own code so use C800? use B window
        ; Keep MEMAC-A disabled.
        lda #0
vbrel_32
        sta $d65e
        lda #$a8
vbrel_33
        sta $d65e
        lda #$f4
vbrel_34
        sta $d65f
        ldx #0
        lda #$ff
clear_cache
        sta $a000,x
        sta $a100,x
        sta $a200,x
        sta $a300,x
        sta $a400,x
        sta $a500,x
        sta $a600,x
        sta $a700,x
        sta $a800,x
        sta $a900,x
        sta $aa00,x
        sta $ab00,x
        sta $ac00,x
        sta $ad00,x
        sta $ae00,x
        sta $af00,x
        inx
        bne clear_cache
        lda #0
vbrel_35
        sta $d65f
        lda #$9b
vbrel_36
        sta $d65d
        ldx #xdl_end-xdl_data-1
setup_xdl
        lda xdl_data,x
        sta $7000,x
        sta $7020,x
        dex
        bpl setup_xdl
        lda #1
        sta $702f
        ldx #20
setup_bcb
        lda bcb_data,x
        sta $7100,x
        dex
        bpl setup_bcb
        lda #0
vbrel_37
        sta $d650
        lda #$f1
vbrel_38
        sta $d651
        lda #6
vbrel_39
        sta $d652
        ; Copy banner tiles from temporary FB1 storage to $78000.
        lda #0
        sta $7100
        sta $7101
        lda #1
        sta $7102
        lda #0
        sta $7106
        lda #$80
        sta $7107
        lda #7
        sta $7108
        lda #$ff
        sta $710c
        lda #0
        sta $710d
        lda #9
        sta $710e
        lda #0
        sta $7103
        sta $7109
        lda #1
        sta $7104
        sta $710a
        jsr blit
        jsr wait_blit
        ldx #20
reset_bcb
        lda bcb_data,x
        sta $7100,x
        dex
        bpl reset_bcb
        lda #1
vbrel_40
        sta $d645
        lda #0
vbrel_41
        sta $d644
        ldx #0
pal_loop
        lda palette,x
vbrel_42
        sta $d646
        inx
        lda palette,x
vbrel_43
        sta $d647
        inx
        lda palette,x
vbrel_44
        sta $d648
        inx
        cpx #192
        bne pal_loop
        lda #0
vbrel_45
        sta $d641
        lda #$f0
vbrel_46
        sta $d642
        lda #6
vbrel_47
        sta $d643
        lda #3
vbrel_48
        sta $d640
        lda #0
vbrel_49
        sta $d65d
        ; C64 reset-state register shadows.
        ldx #63
        lda #0
clear_vic
        sta $de00,x
        dex
        bpl clear_vic
        lda #$1b
        sta $de11
        lda #$c8
        sta $de16
        lda #$14
        sta $de18
        lda #$3f
        sta $dd00
        ldx #SMALL_LEN-1
copy_small
        lda small_src,x
        sta SMALL,x
        dex
        bpl copy_small
        jmp finish_boot

small_src
        dta 217,234,228,217
        dta 0,40,80,120,160,200,240,24,64,104,144,184,224,8,48,88,128,168,208,248,32,72,112,152,192
        dta 0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3
        dta 0,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220,230,240
        dta 0,250,244,238
        dta 0,0,1,2
        dta 0,1,1,1,0,1,1,1
xdl_data
        dta $74,$08,7,0,0,0,$40,1,$11,$ff
        dta $62,$88,199,0,0,0,$40,1,$11,$ff
xdl_end
bcb_data
        dta 0,0,2,8,0,1,0,0,0,$40,1,1,7,0,7,$ff,0,0,0,0,0
palette
        ins '../gen/palette.bin'
        icl '../gen/relocs.asm'
        ert * > $fff0
