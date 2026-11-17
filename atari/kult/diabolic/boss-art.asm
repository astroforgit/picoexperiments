; Shared, right-edge-clipped 64x64 tile renderer for both boss types.
 opt h-
 org $0480
 jmp DrawBoss
 jmp CopyTile
 jmp VisibleActor
 jmp EraseRows
DrawBoss
 jsr $1780
 jcs Done
 lda $FD04
 bne MainHealth
 lda $2D20
 cmp #4
 jne Done
 lda $2D22
 jmp HaveHealth
MainHealth
 lda $FD0A
HaveHealth
 jeq Done
 lda $2DC0
 cmp #4
 jeq Done
 cmp #5
 jeq Done
 cmp #7
 jeq Done
 lda $2D23
 cmp #128
 jcs Done
 ldx #9
SaveState
 lda $FCFA,x
 pha
 dex
 bpl SaveState
 lda $7439
 asl
 tay
 lda $2D23
 lsr
 lsr
 sta $2DCD
 lda #32
 sec
 sbc $2DCD
 cmp #8
 bcc WidthReady
 lda #8
WidthReady
 sta $2DCE,y
 lda $2D23
 clc
 adc $7446
 sta $FCFA
 lda $2D24
 sec
 sbc #16
 sta $FCFB
 lda $2DC8
 asl
 asl
 asl
 asl
 sta $FD00
 lda $FD04
 bne QueenArt
 lda #0
 sta $FCFE
 lda #8
 sta $FCFF
 lda #$10
 sta $FD01
 bne Paint
QueenArt
 lda #$40
 sta $FCFE
 clc
 adc $FD00
 sta $FD00
 lda #$10
 sta $FCFF
 lda #$17
 sta $FD01
Paint
 jsr $FD0B
 ldx $7439
 lda #1
 sta $2DD2,x
 lda $2D23
 sta $2DD4,x
 lda $2D24
 sta $2DD6,x
 lda $2DC8
 sta $2DD8,x
 lda $FD04
 sta $2DDA,x
 ldx #0
RestoreState
 pla
 sta $FCFA,x
 inx
 cpx #10
 bcc RestoreState
Done
 rts
; $FD84 has resolved the source tile into $82/83 and destination into $84/85.
; Rows are 64 bytes apart; only columns 0..31 belong to the visible sky.
CopyTile
 lda $2D23
 lsr
 lsr
 sta $2DCD
 lda $FD08
 asl
 clc
 adc $2DCD
 cmp #32
 bcs CopyDone
 cmp #31
 beq OneByte
 lda #2
 bne HaveBytes
OneByte
 lda #1
HaveBytes
 cmp #1
 beq CopySingle
 ldy #0
CopyPair
 lda ($82),y
 sta ($84),y
 iny
 lda ($82),y
 sta ($84),y
 iny
 clc
 lda $84
 adc #62
 sta $84
 bcc PairRowReady
 inc $85
PairRowReady
 cpy #32
 bne CopyPair
CopyDone
 rts
CopySingle
 ldy #0
CopySingleRow
 lda ($82),y
 sta ($84),y
 iny
 iny
 clc
 lda $84
 adc #62
 sta $84
 bcc SingleRowReady
 inc $85
SingleRowReady
 cpy #32
 bne CopySingleRow
 rts

; The eight sub-boss actors are collision targets, not visible sprites.
; Do not draw/back up blank tiles on top of the separately rendered boss.
; Keep the ordinary path for its death/rewards and all other encounters.
VisibleActor
 lda $FD04
 bne OrdinaryActor
 lda $2D20
 cmp #4
 bne OrdinaryActor
 lda $2D22
 beq OrdinaryActor
 lda $F398
 bne OrdinaryActor
 lda #$80
 rts
OrdinaryActor
 lda $74E0,y
 rts

; Full-width 64x64 erasure is the common case; partial exits use the
; original width-aware loop. FD09 already holds the number of scanlines.
EraseRows
 ldy $FD08
 cpy #7
 bne PartialErase
EraseFullRow
 lda #0
 sta ($F8),y
 dey
 sta ($F8),y
 dey
 sta ($F8),y
 dey
 sta ($F8),y
 dey
 sta ($F8),y
 dey
 sta ($F8),y
 dey
 sta ($F8),y
 dey
 sta ($F8),y
 clc
 lda $F8
 adc #64
 sta $F8
 bcc EraseAddressReady
 inc $F9
EraseAddressReady
 ldy #7
 dec $FD09
 bne EraseFullRow
 rts
PartialErase
 jmp $FCAE
 ert * > $0680
