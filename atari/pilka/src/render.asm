; Arlasoft Soccer VBXE renderer. Lives in VRAM $7D000 and is mapped at
; $C000-$CFFF (MEMAC-A) only while a picture is being built, in place of
; the game's own $C000-$CFFF. It never touches VBXE registers itself: the
; resident bridge provides MEMB, BLIT_AT and BLIT_WAIT.
;
; Character layer: a 40x25-cell ring at VRAM $20000. Screen cell i is ring
; cell (i + oy*40 + ox) mod 1000, so a C64 coarse scroll only moves the
; origin. PREV/COLR hold, per ring cell, the character and colour-RAM byte
; drawn there (2000 bytes each: the blitter keeps a second copy behind the
; first, so any 1000 consecutive cells can be read in one piece).
; The blitter compares the C64 screen (VRAM $7C000/$7C400) with PREV and
; reduces the result to row and 8-column flags; the CPU visits only the
; cells that changed.
        icl 'vars.asm'
        icl '../gen/rt-labels.asm'

BANK_T  = $9b           ; MEMAC-B: VRAM $6C000 (tile map, caches, tile slots)
BANK_L  = $9c           ; MEMAC-B: VRAM $70000 (compose and sprite lists)
TLO     = $4000         ; + colour*256: tile address bits 8-15
THI     = $5000         ; + colour*256: (bank << 2) | address bits 6-7
PREV    = $6000
COLR    = $6800
ROWF    = $7040         ; 25 row flags
SEG     = $7060         ; 5 x 25 flags: 8-column bands
CMPL    = $7120         ; compare list
DIFF    = $7240         ; screen XOR PREV, 40x25
TILETOP = $8000         ; tile slots end here (and the lists of BANK_L follow)
NT      = 120
LCOMP   = $4000         ; 4 slots: character layer -> framebuffer
LBEH    = $4054         ; 4 slots: sprites behind the foreground
LOVL    = $40a8         ; 16 slots: foreground over those sprites
LFRONT  = $41f8         ; 26 slots: other sprites, list end

dp      = $20           ; zero page $20-$2d is saved and restored
colp    = $22
pr      = $24
cr      = $26
tptr    = $28
lptr    = $2a
sp      = $2c

        org $dc40
zsave   .ds 14
scrmid  .ds 1
sxf     .ds 1
syf     .ds 1
offlo   .ds 1
offhi   .ds 1
ox8lo   .ds 1
ox8hi   .ds 1
force   .ds 1
chr     .ds 1
col     .ds 1
lastcol .ds 1
ccol    .ds 1
wrapcol .ds 1
splitc  .ds 1
dstlo   .ds 1
dsthi   .ds 1
dstblo  .ds 1
dstbhi  .ds 1
tcount  .ds 1
rowno   .ds 1
segno   .ds 1
cnt     .ds 1
cnt2    .ds 1
colrot  .ds 1
mapxm   .ds 1
mapy    .ds 1
stripe  .ds 1
ecolno  .ds 1
ecols   .ds 1
ecnt    .ds 1
nb      .ds 1
prevnb  .ds 1
nfront  .ds 1
sprno   .ds 1
j0lo    .ds 1
j0hi    .ds 1
t16lo     .ds 1
t16hi     .ds 1
skip    .ds 1
xx      .ds 2
yy      .ds 1
sframe  .ds 1
scol    .ds 1
sbehind .ds 1
szoom   .ds 1
sw      .ds 1
sh      .ds 1
ssrclo  .ds 1
ssrcmid .ds 1
sdx     .ds 2
sdy     .ds 1
sdstlo  .ds 1
sdstmid .ds 1
bxlo    .ds 4
bxhi    .ds 4
by      .ds 4
bw      .ds 4
bh      .ds 4
palkey  .ds 5
palchg  .ds 1
pno     .ds 1
rx0lo   .ds 1
rx0hi   .ds 1
rx1lo   .ds 1
rx1hi   .ds 1
ry0     .ds 1
ry1     .ds 1
pand    .ds 1
pctrl   .ds 1
x0lo    .ds 1
x0hi    .ds 1
x1lo    .ds 1
x1hi    .ds 1
wlo     .ds 1
whi     .ds 1
y0      .ds 1
hm1     .ds 1
px0lo   .ds 4
px0hi   .ds 4
px1lo   .ds 4
px1hi   .ds 4
pxdlo   .ds 4
pxdhi   .ds 4
py0     .ds 4
py1     .ds 4
pyd     .ds 4
        ert * > $dd00

        org $c000
render
        ldx #13
save_zp lda $20,x
        sta zsave,x
        dex
        bpl save_zp
        jsr BLIT_WAIT
        lda #BANK_T
        jsr MEMB
        lda front
        eor #1
        sta back
        ; The state the C64 would show next: the values its raster
        ; interrupt is about to latch, with the freshly sorted sprites.
        lda $11d9
        and #$10
        lsr
        lsr
        ora #$c0
        sta scrmid
        lda $11d7
        and #7
        sta sxf
        lda $11d8
        and #7
        sta syf
        ldy oy
        lda ox
        clc
        adc row40lo,y
        sta offlo
        lda row40hi,y
        adc #0
        sta offhi
        lda ox
        asl
        asl
        asl
        sta ox8lo
        lda #0
        rol
        sta ox8hi
        lda #0
        sta palchg
        lda first
        beq map_check
        ; First picture: nothing is known about the layer. Draw every cell.
        ldx #<$f0e0
        ldy #>$f0e0
        lda #6
        jsr BLIT_AT             ; PREV := 0, so DIFF becomes the characters
        jsr BLIT_WAIT
        lda #1
        sta force
        sta palchg
        bne compare
        ; A cut to another part of the pitch: cells whose character stays
        ; the same may still change (stripes and advertising follow the
        ; map position), so draw them all.
map_check
        lda menu_mode
        bne compare
        lda $e80e
        cmp expmx
        bne map_jump
        lda $e80f
        cmp expmy
        beq compare
map_jump
        lda $e80e
        sta expmx
        lda $e80f
        sta expmy
        lda #1
        sta force
compare
        clc
        lda offlo
        sta CMPL+2*21
        lda offhi
        adc #$e0
        sta CMPL+2*21+1
        lda scrmid
        sta CMPL+3*21+1
        ldx #<$f120
        ldy #>$f120
        lda #6
        jsr BLIT_AT
        ; ---- while the blitter compares: palette and sprites
        ldx #4
pal_keys
        ldy palreg,x
        lda $de00,y
        and #15
        cmp palkey,x
        beq pal_same
        sta palkey,x
        inc palchg
pal_same
        dex
        bpl pal_keys
        lda palchg
        beq pal_done
        ldx palkey+1            ; $D022; the C64 yellow of the stands is shown grey
        ldy #0
        jsr putrgb
        cpx #7
        bne pal_bg0
        ldx #2
pal_stand
        lda standrgb,x
        sta palbuf,x
        dex
        bpl pal_stand
pal_bg0
        ldx palkey              ; $D021: grass when it is the pitch green
        cpx #5
        bne pal_plain
        ldx #17
pal_grass
        lda grassrgb,x
        sta palbuf+3,x
        dex
        bpl pal_grass
        bmi pal_bg2
pal_plain
        ldy #3
        jsr putrgb
        ldy #6
        jsr putrgb
        ldy #9
        jsr putrgb
        ldy #12
        jsr putrgb
        ldy #15
        jsr putrgb
        ldy #18
        jsr putrgb
pal_bg2 ldx palkey+2            ; $D023
        ldy #21
        jsr putrgb
        ldx palkey+4            ; $D026
        ldy #24
        jsr putrgb
        ldx palkey+3            ; $D025
        ldy #27
        jsr putrgb
        lda #1
        sta palflag
pal_done
        lda #BANK_L
        jsr MEMB
        lda #0
        sta nb
        sta nfront
        lda #<LFRONT
        sta lptr
        lda #>LFRONT
        sta lptr+1
        ldx #0
sprites ; The game's sorted list ends at the first Y of $FF; what follows
        ; is stale. Bit 7 of the colour is X bit 8.
        lda $e4,x
        cmp #$ff
        beq sprites_done
        sta yy
        lda $9f,x
        sta xx
        lda $cd,x
        sta sframe
        lda $b6,x
        sta scol
        ; Behind the foreground: only where the game has patched this
        ; sprite's multiplexer slot (mask $8E8D, slot = index mod 7); it
        ; does that for a limited number of flagged sprites per frame.
        and #$40
        beq spr_prio
        lda $8e8d
        and slotbit,x
spr_prio
        sta sbehind
        lda #0
        sta szoom
        bit scol
        bpl spr_low
        lda #1
spr_low sta xx+1
        lda menu_mode
        beq spr_draw
        cpx #8
        bcs spr_draw
        lda $de1d               ; the menu shows expanded sprites
        and bitmask,x
        beq spr_draw
        lda #$11
        sta szoom
spr_draw
        stx sprno
        jsr draw_sprite
        ldx sprno
        inx
        cpx #23
        bne sprites
sprites_done
        ; VIC sprite 7 is the ball.
        lda $de15
        bpl ball_done
        lda $24d8
        sta xx
        lda #0
        sta szoom
        bit $de10
        bpl ball_low
        lda #1
ball_low
        sta xx+1
        lda $24e0
        sta yy
        lda $de2e
        sta scol
        lda $24e2
        and #$80
        sta sbehind
        lda ballframe
        sta sframe
        jsr draw_sprite
ball_done
        ; The last sprite ends the list.
        lda nfront
        bne end_last
        lda #<LFRONT
        sta sp
        lda #>LFRONT
        sta sp+1
        lda #1
        jsr noop
        jmp cells
end_last
        sec
        lda lptr
        sbc #1
        sta sp
        lda lptr+1
        sbc #0
        sta sp+1
        ldy #0
        lda #1
        sta (sp),y

        ; ---- changed cells
cells   jsr BLIT_WAIT
        lda #BANK_T
        jsr MEMB
        lda #<TILETOP
        sta tptr
        lda #>TILETOP
        sta tptr+1
        lda #NT
        sta tcount
        lda #$ff
        sta lastcol
        lda $e80e               ; map column of the screen's left edge
map_mod cmp #40
        bcc map_ok
        sbc #40
        bcs map_mod
map_ok  sta mapxm
        lda $e80f
        sta mapy
        ; Coarse scrolls brought in rows and/or columns of cells. Their
        ; layer slots held other cells, which may have had the same
        ; character but another stripe or advertising tile.
        ldx #0                  ; rows: first, count
        lda flipdy
        beq edge_rows_set
        bmi edge_rows_top
        sta ecnt
        lda #25
        sec
        sbc ecnt
        tax
        lda ecnt
        bne edge_rows_set
edge_rows_top
        eor #$ff
        clc
        adc #1
edge_rows_set
        sta ecnt
        stx rowno
        ldx #0                  ; columns: first, count
        lda flipdx
        beq edge_cols_set
        bmi edge_cols_left
        sta ecols
        lda #40
        sec
        sbc ecols
        tax
        lda ecols
        bne edge_cols_set
edge_cols_left
        eor #$ff
        clc
        adc #1
edge_cols_set
        sta ecols
        stx ecolno
        lda #0
        sta flipdx
        sta flipdy
        lda ecnt
        ora ecols
        beq edges_done
        lda ecnt
        cmp #4
        bcs edge_all
        lda ecols
        cmp #4
        bcc edge_rows
edge_all
        lda #1                  ; a long way: draw everything
        sta force
edge_rows
        lda force
        bne edges_done
        lda ecnt
        beq edge_cols
edge_row
        jsr setup_row
        ldy #0
edge_row_cell
        jsr edge_cell
        iny
        cpy #40
        bne edge_row_cell
        inc rowno
        dec ecnt
        bne edge_row
edge_cols
        lda ecols
        beq edges_done
        lda #0
        sta rowno
edge_col_row
        jsr setup_row
        ldy ecolno
        lda ecols
        sta cnt
edge_col_cell
        jsr edge_cell
        iny
        dec cnt
        bne edge_col_cell
        inc rowno
        lda rowno
        cmp #25
        bne edge_col_row
edges_done
        lda #0
        sta rowno
rows    ldx rowno
        lda ROWF,x
        ora force
        beq next_row
        jsr setup_row
        lda #0
        sta segno
segs    ldx segno
        lda seg25,x
        clc
        adc rowno
        tax
        lda SEG,x
        ora force
        beq next_seg
        ldx segno
        ldy seg8,x
        lda #8
        sta cnt
seg_cells
        lda (dp),y
        ora force
        beq seg_next
        jsr emit_cell
seg_next
        iny
        dec cnt
        bne seg_cells
next_seg
        inc segno
        lda segno
        cmp #5
        bne segs
next_row
        inc rowno
        lda rowno
        cmp #25
        bne rows
        ; ---- colour RAM: it is not in VRAM, so the CPU compares it. The
        ; menu changes colours alone (all rows every picture); in a match
        ; colours change together with characters, and one row per picture
        ; is checked as a safety net.
        lda force
        bne colours_done
        ldx #1
        lda menu_mode
        beq colour_count
        ldx #25
colour_count
        stx cnt2
colour_row
        lda colrot
        sta rowno
        jsr setup_row
        ldy #0
colour_cell
        lda (colp),y
        eor (cr),y
        and #15
        beq colour_same
        jsr emit_cell
colour_same
        iny
        cpy #40
        bne colour_cell
        ldx colrot
        inx
        cpx #25
        bcc colour_next
        ldx #0
colour_next
        stx colrot
        dec cnt2
        bne colour_row
colours_done

        ; ---- layer -> framebuffer, foreground over "behind" sprites
        lda #BANK_L
        jsr MEMB
        jsr setup_pieces
        ; C64 38-column, 24-row window: display x 7-310, y 4-195. Display
        ; (x, y) shows layer pixel (x - fineX, y + 3 - fineY).
        lda #7
        sec
        sbc sxf
        sta rx0lo
        lda #0
        sta rx0hi
        lda #$37
        sec
        sbc sxf
        sta rx1lo
        lda #1
        sta rx1hi
        lda #7
        sec
        sbc syf
        sta ry0
        lda #199
        sec
        sbc syf
        sta ry1
        lda #<LCOMP
        sta lptr
        lda #>LCOMP
        sta lptr+1
        lda #$ff
        sta pand
        lda #8
        sta pctrl
        jsr emit_pieces
        lda #$f8
        sta pand
        lda #9
        sta pctrl
        ldx #0
overlays
        cpx nb
        bcs overlays_done
        stx sprno
        lda ovllo,x
        sta lptr
        lda ovlhi,x
        sta lptr+1
        sec
        lda bxlo,x
        sbc sxf
        sta rx0lo
        lda bxhi,x
        sbc #0
        sta rx0hi
        sec                     ; + width-1 + 1
        lda rx0lo
        adc bw,x
        sta rx1lo
        lda rx0hi
        adc #0
        sta rx1hi
        lda by,x
        clc
        adc #3
        sec
        sbc syf
        sta ry0
        sec
        adc bh,x
        sta ry1
        jsr emit_pieces
        ldx sprno
        inx
        bne overlays
overlays_done
        ; Slots used by the previous picture but not by this one.
unused  cpx prevnb
        bcs unused_done
        stx sprno
        lda behlo,x
        sta sp
        lda #>LBEH
        sta sp+1
        lda #9
        jsr noop
        ldx sprno
        lda ovllo,x
        sta sp
        lda ovlhi,x
        sta sp+1
        lda #4
        sta cnt
unused_ovl
        lda #9
        jsr noop
        clc
        lda sp
        adc #21
        sta sp
        bcc unused_ovl2
        inc sp+1
unused_ovl2
        dec cnt
        bne unused_ovl
        ldx sprno
        inx
        bne unused
unused_done
        lda nb
        sta prevnb
        ; ---- run: tiles, compose, sprites. The CPU does not wait; the
        ; interrupt shows the picture once the blitter has finished.
        lda tcount
        cmp #NT
        bne start_tiles
        ldx #0
        ldy #0
        lda #7
        bne start
start_tiles
        ldx tptr
        lda tptr+1
        ora #$80
        tay
        lda #6
start   jsr BLIT_AT
        ldx back
        inx
        stx pending
        lda #0
        sta force
        sta first
        jsr MEMB
        ldx #13
rest_zp lda zsave,x
        sta $20,x
        dex
        bpl rest_zp
        rts

; palbuf[Y..Y+2] := RGB of C64 colour X. Keeps X.
putrgb
        lda c64r,x
        sta palbuf,y
        lda c64g,x
        sta palbuf+1,y
        lda c64b,x
        sta palbuf+2,y
        rts

; Make the BCB at (sp) draw nothing; A = its control byte.
noop
        ldy #20
        sta (sp),y
        lda #0
        ldy #12
        sta (sp),y
        iny
        sta (sp),y
        iny
        sta (sp),y
        iny
        sta (sp),y
        rts

; Point the cell routines at screen row rowno.
setup_row
        ldx rowno
        clc
        lda row40lo,x
        adc #<DIFF
        sta dp
        lda row40hi,x
        adc #>DIFF
        sta dp+1
        lda row40lo,x
        sta colp
        lda row40hi,x
        ora #$d8
        sta colp+1
        ; ring index of the row's first cell
        clc
        lda row40lo,x
        adc offlo
        sta j0lo
        lda row40hi,x
        adc offhi
        sta j0hi
        lda j0lo
        cmp #$e8
        lda j0hi
        sbc #3
        bcc sr_inring
        lda j0lo
        sbc #$e8
        sta j0lo
        lda j0hi
        sbc #3
        sta j0hi
sr_inring
        ; Column at which the row passes ring cell 999 (or none).
        lda #$ff
        sta wrapcol
        lda j0hi
        cmp #3
        bcc sr_nowrap
        lda j0lo
        cmp #$c1
        bcc sr_nowrap
        lda #$e8
        sec
        sbc j0lo
        sta wrapcol
sr_nowrap
        lda j0lo
        sta pr
        sta cr
        lda j0hi
        clc
        adc #>PREV
        sta pr+1
        adc #8
        sta cr+1
        ; Layer address of the row: ring row R0 from column ox, then ring
        ; row R0+1 from column 0.
        lda rowno
        clc
        adc oy
        cmp #25
        bcc sr_r0
        sbc #25
sr_r0   tax
        lda ox8lo
        sta dstlo
        lda row10,x
        clc
        adc ox8hi
        sta dsthi
        inx
        cpx #25
        bne sr_r1
        ldx #0
sr_r1   sec
        lda ox8lo
        sbc #$40
        sta dstblo
        lda ox8hi
        sbc #1
        clc
        adc row10,x
        sta dstbhi
        lda #40
        sec
        sbc ox
        sta splitc
        lda mapy                ; mowing stripes follow the map row
        clc
        adc rowno
        and #4
        sta stripe
        rts

; Redraw screen cell (rowno, Y) from the C64 screen and colour RAM. Within
; a row, cells must come in ascending column order. Keeps Y.
emit_cell
        sty ccol
        jsr ec_switch
        lda (dp),y
        eor (pr),y
        sta chr
        sta (pr),y
        lda #0
        sta (dp),y
        lda (colp),y
        and #15
        sta col
        sta (cr),y              ; bit 4 is added for a light-stripe tile
        jmp ec_count

; Redraw an incoming cell (rowno, Y) unless its slot already shows the
; right tile. Keeps Y.
edge_cell
        jsr ec_switch
        lda (dp),y
        bne ee_emit
        lda menu_mode
        bne ee_done
        lda (colp),y
        and #15
        cmp #9
        bne ee_plain
        lda (pr),y
        cmp #$d9
        bcs ee_emit
        cmp #203
        bcs ee_plain
        cmp #8
        bcs ee_stripe
        cmp #0
        bne ee_plain
ee_stripe
        lda stripe
        beq ee_plain
        lda #$10
        bne ee_cmp
ee_plain
        lda #0
ee_cmp  eor (cr),y
        and #$10
        beq ee_done
ee_emit jmp emit_cell
ee_done rts

; Step the row's layer and ring pointers past column Y where needed.
ec_switch
        cpy splitc
        bcc ec_dst
        lda dstblo
        sta dstlo
        lda dstbhi
        sta dsthi
        lda #$ff
        sta splitc
ec_dst  cpy wrapcol
        bcc ec_ring
        sec
        lda pr
        sbc #$e8
        sta pr
        sta cr
        lda pr+1
        sbc #3
        sta pr+1
        clc
        adc #8
        sta cr+1
        lda #$ff
        sta wrapcol
ec_ring rts
ec_count
        lda tcount
        bne ec_slot
        jsr flush
ec_slot dec tcount
        sec
        lda tptr
        sbc #21
        sta tptr
        bcs ec_addr
        dec tptr+1
ec_addr lda ccol
        asl
        asl
        asl
        tax
        lda #0
        rol
        sta t16hi
        txa
        clc
        adc dstlo
        ldy #6
        sta (tptr),y
        lda t16hi
        adc dsthi
        iny
        sta (tptr),y
        ; Pitch advertising: text characters in the pitch colour become
        ; the generated strip, placed by map column so it scrolls along.
        lda menu_mode
        bne ec_tile
        lda col
        cmp #9
        bne ec_tile
        lda chr
        cmp #$d9
        bcc ec_pitch
        lda ccol
        clc
        adc mapxm
        cmp #40
        bcc ec_ban
        sbc #40
ec_ban  tax
        ldy #0
        lda ban_lo,x
        sta (tptr),y
        iny
        lda ban_mid,x
        sta (tptr),y
        iny
        lda #7
        sta (tptr),y
        ldy ccol
        rts
        ; Pitch characters on a light stripe: the second tile set, VRAM
        ; $74000 + character*64.
ec_pitch
        cmp #203
        bcs ec_tile
        cmp #8                  ; 1-7 are stand characters: no stripes
        bcs ec_stripe
        cmp #0
        bne ec_tile
ec_stripe
        lda stripe
        beq ec_tile
        ldy ccol
        lda col
        ora #$10
        sta (cr),y
        lda chr
        and #3
        tax
        lda b0lut,x
        ldy #0
        sta (tptr),y
        lda chr
        lsr
        lsr
        ora #$40
        iny
        sta (tptr),y
        lda #7
        iny
        sta (tptr),y
        ldy ccol
        rts
ec_tile lda col
        cmp lastcol
        beq ec_look
        sta lastcol
        ora #>TLO
        sta ec_lo+2
        eor #$10
        sta ec_hi+2
ec_look ldx chr
ec_lo   lda TLO,x
        ldy #1
        sta (tptr),y
ec_hi   lda THI,x
        tax
        lda b0lut,x
        dey
        sta (tptr),y
        lda b2lut,x
        ldy #2
        sta (tptr),y
        ldy ccol
        rts

; All tile slots are in use: draw them now and start over.
flush
        lda #0
        sta TILETOP-1           ; the last slot ends the list
        ldx tptr
        lda tptr+1
        ora #$80
        tay
        lda #6
        jsr BLIT_AT
        jsr BLIT_WAIT
        lda #8
        sta TILETOP-1
        lda #<TILETOP
        sta tptr
        lda #>TILETOP
        sta tptr+1
        lda #NT
        sta tcount
        rts

; The four pieces the ring cuts the screen into: columns before/after the
; ring's column wrap, each split where its ring row wraps. For each: the
; screen-pixel bounds and what to add to reach ring pixels.
setup_pieces
        sec                     ; XA = 320 - ox*8
        lda #$40
        sbc ox8lo
        sta px1lo
        sta px1lo+1
        sta px0lo+2
        sta px0lo+3
        lda #1
        sbc ox8hi
        sta px1hi
        sta px1hi+1
        sta px0hi+2
        sta px0hi+3
        lda #0
        sta px0lo
        sta px0lo+1
        sta px0hi
        sta px0hi+1
        sta py0
        sta py0+2
        lda #$40
        sta px1lo+2
        sta px1lo+3
        lda #1
        sta px1hi+2
        sta px1hi+3
        lda ox8lo
        sta pxdlo
        sta pxdlo+1
        lda ox8hi
        sta pxdhi
        sta pxdhi+1
        sec                     ; ox*8 - 320
        lda ox8lo
        sbc #$40
        sta pxdlo+2
        sta pxdlo+3
        lda ox8hi
        sbc #1
        sta pxdhi+2
        sta pxdhi+3
        lda oy
        asl
        asl
        asl
        sta pyd                 ; oy*8
        clc
        adc #8
        sta pyd+2
        lda #200
        sta py1+1
        sta py1+3
        sec
        sbc pyd
        sta py1                 ; YA = 200 - oy*8
        sta py0+1
        sec
        sbc #8
        sta py1+2               ; YB = 192 - oy*8
        sta py0+3
        lda pyd
        sec
        sbc #200
        sta pyd+1
        lda pyd
        sec
        sbc #192
        sta pyd+3
        rts

; Four BCBs at lptr: layer rectangle rx0..rx1 x ry0..ry1 (exclusive ends,
; screen pixels before fine scroll) to the back buffer, AND mask pand,
; control pctrl. Pieces the rectangle misses become no-ops.
emit_pieces
        ldx #0
ep_loop stx pno
        lda rx0lo
        cmp px0lo,x
        lda rx0hi
        sbc px0hi,x
        bcs ep_x0r
        lda px0lo,x
        sta x0lo
        lda px0hi,x
        sta x0hi
        jmp ep_x1
ep_x0r  lda rx0lo
        sta x0lo
        lda rx0hi
        sta x0hi
ep_x1   lda rx1lo
        cmp px1lo,x
        lda rx1hi
        sbc px1hi,x
        bcc ep_x1r
        lda px1lo,x
        sta x1lo
        lda px1hi,x
        sta x1hi
        jmp ep_w
ep_x1r  lda rx1lo
        sta x1lo
        lda rx1hi
        sta x1hi
ep_w    clc
        lda x1lo
        sbc x0lo
        sta wlo
        lda x1hi
        sbc x0hi
        sta whi
        jcc ep_empty
        lda ry0
        cmp py0,x
        bcs ep_y0
        lda py0,x
ep_y0   sta y0
        lda ry1
        cmp py1,x
        bcc ep_y1
        lda py1,x
ep_y1   clc
        sbc y0
        jcc ep_empty
        sta hm1
        lda y0
        clc
        adc pyd,x
        tay
        clc
        lda x0lo
        adc pxdlo,x
        sta t16lo
        lda x0hi
        adc pxdhi,x
        sta t16hi
        clc
        lda t16lo
        adc ylo,y
        sta t16lo
        lda t16hi
        adc yhi,y
        ldy #1
        sta (lptr),y
        dey
        lda t16lo
        sta (lptr),y
        lda y0
        clc
        adc syf
        sec
        sbc #3
        tax
        clc
        lda x0lo
        adc sxf
        sta t16lo
        lda x0hi
        adc #0
        sta t16hi
        clc
        lda t16lo
        adc ylo,x
        ldy #6
        sta (lptr),y
        lda t16hi
        adc yhi,x
        iny
        sta (lptr),y
        lda back
        iny
        sta (lptr),y
        ldy #12
        lda wlo
        sta (lptr),y
        iny
        lda whi
        sta (lptr),y
        iny
        lda hm1
        sta (lptr),y
        iny
        lda pand
        sta (lptr),y
        ldy #20
        lda pctrl
        sta (lptr),y
        jmp ep_next
ep_empty
        lda #0
        ldy #12
        sta (lptr),y
        iny
        sta (lptr),y
        iny
        sta (lptr),y
        iny
        sta (lptr),y
        ldy #20
        lda #9
        sta (lptr),y
ep_next clc
        lda lptr
        adc #21
        sta lptr
        bcc ep_cont
        inc lptr+1
ep_cont ldx pno
        inx
        cpx #4
        jne ep_loop
        rts

; Queue C64 sprite frame sframe (32-127, 24x21 bytes per 512 at VRAM
; $60000) at C64 position xx (9 bits), yy in colour scol, clipped to the
; C64 window (x 7-310, y 4-195). The first sprite line is Y+1, so the
; display position is (X-24, Y-50). Sprite-colour pixels are stored as $FF
; and become $60+colour through the AND mask; the multicolours are palette
; entries $40 and $20.
draw_sprite
        lda sframe
        sec
        sbc #32
        cmp #96
        bcs ds_out
        asl
        sta ssrcmid
        lda #0
        sta ssrclo
        lda #20
        sta sh
        lda #23
        sta sw
        lda yy
        sec
        sbc #50
        sta sdy
        bcc ds_top
        cmp #4
        bcs ds_yin
ds_top  lda #4
        sec
        sbc sdy
        cmp #21
        bcs ds_out
        sta skip
        tax
        lda #20
        sec
        sbc skip
        sta sh
        lda mul24lo,x
        sta ssrclo
        lda mul24hi,x
        clc
        adc ssrcmid
        sta ssrcmid
        lda #4
        sta sdy
        lda #0
        sta szoom
        beq ds_x
ds_out  rts
ds_yin  cmp #196
        bcs ds_out
        cmp #176
        bcc ds_x
        lda #195
        sec
        sbc sdy
        sta sh
        lda #0
        sta szoom
ds_x    sec
        lda xx
        sbc #24
        sta sdx
        lda xx+1
        sbc #0
        sta sdx+1
        bmi ds_left
        bne ds_right
        lda sdx
        cmp #7
        bcs ds_xin
ds_left lda #7
        sec
        sbc sdx
        cmp #24
        bcs ds_out
        sta skip
        clc
        adc ssrclo
        sta ssrclo
        bcc ds_lsrc
        inc ssrcmid
ds_lsrc lda #23
        sec
        sbc skip
        sta sw
        lda #7
        sta sdx
        lda #0
        sta sdx+1
        sta szoom
        beq ds_xin
ds_right
        lda sdx
        cmp #55
        bcs ds_out
        cmp #32
        bcc ds_xin
        lda #54
        sec
        sbc sdx
        sta sw
        lda #0
        sta szoom
ds_xin  lda szoom
        beq ds_dst
        lda sdx+1               ; an expanded sprite must fit completely
        bne ds_nozoom
        lda sdy
        cmp #155
        bcc ds_dst
ds_nozoom
        lda #0
        sta szoom
ds_dst  ldy sdy
        clc
        lda ylo,y
        adc sdx
        sta sdstlo
        lda yhi,y
        adc sdx+1
        sta sdstmid
        lda sbehind
        beq ds_front
        ldx nb
        cpx #4
        bcs ds_front
        lda sdx
        sta bxlo,x
        lda sdx+1
        sta bxhi,x
        lda sdy
        sta by,x
        lda sw
        sta bw,x
        lda sh
        sta bh,x
        lda behlo,x
        sta sp
        lda #>LBEH
        sta sp+1
        inc nb
        bne ds_write
ds_front
        lda lptr
        sta sp
        lda lptr+1
        sta sp+1
        clc
        lda lptr
        adc #21
        sta lptr
        bcc ds_count
        inc lptr+1
ds_count
        inc nfront
ds_write
        ldy #0
        lda ssrclo
        sta (sp),y
        iny
        lda ssrcmid
        sta (sp),y
        ldy #6
        lda sdstlo
        sta (sp),y
        iny
        lda sdstmid
        sta (sp),y
        iny
        lda back
        sta (sp),y
        ldy #12
        lda sw
        sta (sp),y
        ldy #14
        lda sh
        sta (sp),y
        iny
        lda scol
        and #15
        ora #$60
        sta (sp),y
        ldy #18
        lda szoom
        sta (sp),y
        ldy #20
        lda #9
        sta (sp),y
        rts

palreg  dta $21,$22,$23,$25,$26
bitmask dta 1,2,4,8,16,32,64,128
slotbit dta 1,2,4,8,16,32,64,1,2,4,8,16,32,64,1,2,4,8,16,32,64,1,2
seg25   dta 0,25,50,75,100
seg8    dta 0,8,16,24,32
behlo   dta <LBEH,<(LBEH+21),<(LBEH+42),<(LBEH+63)
ovllo   dta <LOVL,<(LOVL+84),<(LOVL+168),<(LOVL+252)
ovlhi   dta >LOVL,>(LOVL+84),>(LOVL+168),>(LOVL+252)
        icl '../gen/render-tables.asm'
        ert * > $d000
