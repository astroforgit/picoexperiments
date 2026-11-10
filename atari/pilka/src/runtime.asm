; Arlasoft Soccer native 6502 bridge. Original logic stays at original
; addresses. This file is the resident part: the interrupt, the game-loop
; hooks and the data the C64 kept in RAM under its I/O area. The renderer
; itself (render.asm) lives in VRAM and is mapped at $C000 only while it runs.
        icl 'vars.asm'

GBANK   = $80|$7c       ; MEMAC-A bank: the game's own $C000-$CFFF (VRAM $7C000)
RBANK   = $80|$7d       ; MEMAC-A bank: renderer code (VRAM $7D000)

; ------------------------------------------------------------------
; Always visible: former VIC-only character set RAM.
; ------------------------------------------------------------------
        org $f000
; VBXE access for the renderer bank (it holds no hardware addresses, so
; only this file needs relocating for a VBXE at $D700).
memb
vbrel_0
        sta $d65d
        rts
blit_at                         ; X/Y/A = blitter list address low/mid/high
vbrel_1
        stx $d650
vbrel_2
        sty $d651
vbrel_3
        sta $d652
        lda #1
vbrel_4
        sta $d653
        rts
blit_wait
vbrel_5
        lda $d653
        bne blit_wait
        rts

; Draw one picture. The renderer replaces the game's $C000-$CFFF while it
; runs; the blitter reads the C64 screens straight from that VRAM bank.
render_tramp
        ldx $c3ff
        lda $11d9
        and #$10
        beq rt_screen0
        ldx $c7ff
rt_screen0
        stx ballframe
        lda #RBANK
vbrel_6
        sta $d65f
        jsr $c000
        lda #GBANK
vbrel_7
        sta $d65f
        rts

nmi
        pha
        txa
        pha
        tya
        pha
        ; The game may be interrupted inside SED code; RTI restores its D flag.
        cld
        lda #0
        sta $d40f
        inc frames
        ; Show a finished picture, and only during vertical blank. Both XDLs
        ; are immutable, so a frame cannot mix the old/new screen addresses.
        lda pending
        beq no_publish
vbrel_8
        lda $d653
        bne no_publish
        ldx pending
        dex
        stx front
        txa
        asl
        asl
        asl
        asl
        asl
vbrel_9
        sta $d641
        lda #0
        sta pending
        ; The colours that follow VIC registers change with the picture.
        lda palflag
        beq no_publish
        lda #0
        sta palflag
        tax
        tay
publish_palette
        lda palidx,x
vbrel_10
        sta $d644
        lda palbuf,y
vbrel_11
        sta $d646
        lda palbuf+1,y
vbrel_12
        sta $d647
        lda palbuf+2,y
vbrel_13
        sta $d648
        iny
        iny
        iny
        inx
        cpx #10
        bne publish_palette
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
        ; The C64 raster interrupt: only when the game has enabled it and
        ; is outside its SEI critical sections.
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

palidx  dta 1,2,3,4,5,6,7,8,$20,$40

; Formation tables the C64 game reads with its I/O area banked out (the
; build copies them here and points the game's reader at them):
rec0    .ds 1155                ; C64 RAM $DA7D-$DEFF, 33 records of 35 bytes
rec1    .ds 280                 ; $C980,$CA80..$CF80 and $D080, 35 bytes each
        ert * > $f800

; ------------------------------------------------------------------
; Game context only: unused C64 sprite-pattern RAM (in the game's bank).
; $C900-$CBFF holds the menu table relocated from under the C64 I/O.
; ------------------------------------------------------------------
        org $cc00
; Replacement for the game's raster-dependent frame wait: consume exactly
; one vertical blank. If the loop has fallen behind, the following waits
; return at once (and pictures are skipped) until it has caught up.
frame_wait
        php
        cld
        lda lastwait
fw_idle cmp frames
        beq fw_idle
        inc lastwait
        lda frames
        sec
        sbc lastwait
        cmp #4
        bcc fw_debt
        lda frames
        sta lastwait
        lda #0
fw_debt sta debt
        lda #0
        sta $91ff
        plp
        rts

; Called where the game loop runs its logic, right after it has sorted the
; sprite list: scroll, screen, sprites and ball are one consistent state.
game_hook
        lda #0
        sta menu_mode
        lda pending
        bne gh_skip
        lda debt
        beq gh_draw
        inc skipn
        lda skipn
        cmp #3
        bcc gh_skip
gh_draw lda #0
        sta skipn
        jsr render_tramp
gh_skip jmp $85e4

; Menu input/update is called from its own loop, once per frame.
menu_frame
        lda #1
        sta menu_mode
        lda pending
        bne mf_skip
        jsr render_tramp
mf_skip jmp $9524

; The game arms a screen flip: the new screen is the old one moved by one
; character in direction $11DB (0-7). Move the ring origin the same way.
flip_hook
        ldx $11db
        cpx #8
        bcs fh_done
        lda flipdx
        clc
        adc dir_dx,x
        sta flipdx
        lda flipdy
        clc
        adc dir_dy,x
        sta flipdy
        lda ox
        clc
        adc dir_dx,x
        bpl fh_x1
        clc
        adc #40
        dec oy
        jmp fh_x2
fh_x1   cmp #40
        bcc fh_x2
        sbc #40
        inc oy
fh_x2   sta ox
        lda expmx
        clc
        adc dir_dx,x
        sta expmx
        lda expmy
        clc
        adc dir_dy,x
        sta expmy
        lda oy
        clc
        adc dir_dy,x
        bpl fh_y1
        clc
        adc #25
fh_y1   cmp #25
        bcc fh_y2
        sbc #25
fh_y2   sta oy
fh_done lda $11e5
        rts
; C64 screen-copy offsets $1471: -40,-39,+1,+41,+40,+39,-1,-41
dir_dx  dta 0,1,1,1,0,$ff,$ff,$ff
dir_dy  dta $ff,$ff,0,1,1,1,0,$ff

; C64 raster line (9 bits: X low, A bit 7 high) for the game's time-sliced
; screen copy. The VBI is scanline 248; the C64 interrupt is line $FA.
raster9
        lda $d40b
        clc
        adc #1
        asl
        tax
        lda #0
        ror
        rts

; Formation record address for index Y = $21-$28.
rec1ptr
        lda rec1_hi-$21,y
        sta $17
        lda rec1_lo-$21,y
        rts
rec1_lo dta <rec1,<(rec1+35),<(rec1+70),<(rec1+105),<(rec1+140),<(rec1+175),<(rec1+210),<(rec1+245)
rec1_hi dta >rec1,>(rec1+35),>(rec1+70),>(rec1+105),>(rec1+140),>(rec1+175),>(rec1+210),>(rec1+245)

; Last boot step, outside $F800-$FFFF: put back the C64 game code the
; boot-only part occupied (staged at VRAM $5F000), then start the game.
finish_boot
        lda #$80|$17
vbrel_14
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
vbrel_15
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
        ert * > $d000

; ------------------------------------------------------------------
; Boot-only code and data. finish_boot overwrites it with game code.
; ------------------------------------------------------------------
        org $f800
rt_boot
        sei
        cld
        sta vbpage
        jsr relocate
        ; OS ROM must stay disabled: this code executes underneath it.
        lda #$fe
        sta $d301
        ; MEMAC-A: 4K at $C000 = VRAM $7C000, where the loader staged the
        ; game's $C000-$CFFF. It stays mapped for good.
        lda #$c8
vbrel_16
        sta $d65e
        lda #GBANK
vbrel_17
        sta $d65f
        ; Again, now for the bridge code inside that bank.
        jsr relocate
        ; Copy the staged C64 RAM image (VRAM $70000) into place.
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
vbrel_18
        sta $d65d
        ldy #0
restore_src
        lda $4000,y
        sta $dd00,y
        iny
        bne restore_src
        lda #0
vbrel_19
        sta $d65d
restore_copy
        lda $dd00,y
restore_dst
        sta $0000,y
        iny
        bne restore_copy
        inx
        cpx #$c0
        bne restore_not_bank
        ldx #$e0                ; $C0-$CF is VRAM already; $D0-$DF is not game RAM
restore_not_bank
        cpx #$f0
        bne restore_page
        ldx #$ff
        txs
        ; Runtime variables and colour RAM start clean.
        lda #0
        tax
clear_vars
        sta $dc00,x
        sta $dd00,x
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x
        inx
        bne clear_vars
        inc first
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
        lda #<nmi
        sta $fffa
        lda #>nmi
        sta $fffb
        lda #<irq_exit
        sta $fffe
        lda #>irq_exit
        sta $ffff
        ; One-off blits through the scratch BCB at VRAM $6F100.
        lda #$9b
vbrel_20
        sta $d65d
        ldy #0
boot_blits
        ldx #0
boot_bcb
        lda boot_list,y
        sta $7100,x
        iny
        inx
        cpx #21
        bne boot_bcb
        sty $fc
        ldx #0
        ldy #$f1
        lda #6
        jsr blit_at
        jsr blit_wait
        ldy $fc
        cpy #5*21
        bne boot_blits
        lda #0
vbrel_21
        sta $d65d
        ; Fixed palette entries (palette 1): character and sprite colours.
        lda #1
vbrel_22
        sta $d645
        ldx #0
pal_loop
        lda palette,x
        beq pal_done
vbrel_23
        sta $d644
        lda palette+1,x
vbrel_24
        sta $d646
        lda palette+2,x
vbrel_25
        sta $d647
        lda palette+3,x
vbrel_26
        sta $d648
        inx
        inx
        inx
        inx
        bne pal_loop
pal_done
        lda #0
vbrel_27
        sta $d641
        lda #$f0
vbrel_28
        sta $d642
        lda #6
vbrel_29
        sta $d643
        lda #3
vbrel_30
        sta $d640
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
        jmp finish_boot

; A VBXE at $D700: patch the high byte of every VBXE register operand.
relocate
        lda vbpage
        cmp #$d6
        beq reloc_done
        ldx #0
reloc_loop
        lda reloc_lo,x
        sta $fc
        lda reloc_hi,x
        sta $fd
        ldy #0
        lda #$d7
        sta ($fc),y
        inx
        cpx #RELOC_COUNT
        bne reloc_loop
reloc_done
        rts

; Advertising tiles, list templates and light pitch tiles wait in framebuffer 1 while the
; RAM image occupies their place; then both framebuffers are cleared.
boot_list
        dta $00,$00,$01, $00,$01,1, $00,$80,$07, $00,$01,1, $ff,$00,9, $ff,0,0,0,0,0
        dta $00,$0a,$01, $00,$01,1, $00,$00,$07, $00,$01,1, $ff,$00,4, $ff,0,0,0,0,0
        dta $00,$10,$01, $00,$01,1, $00,$40,$07, $00,$01,1, $ff,$00,63, $ff,0,0,0,0,0
        dta $00,$00,$00, $40,$01,1, $00,$00,$00, $40,$01,1, $3f,$01,199, 0,0,0,0,0,0
        dta $00,$00,$00, $40,$01,1, $00,$00,$01, $40,$01,1, $3f,$01,199, 0,0,0,0,0,0
palette
        ins '../gen/palette.bin'
        icl '../gen/relocs.asm'
        ert * > $fff0
