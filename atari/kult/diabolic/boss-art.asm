; Shared, right-edge-clipped 64x64 tile renderer for both boss types.
 opt h-
 org $0480
 jmp DrawBoss
 jmp CopyTile
DrawBoss
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
 sta $2DCC
 ldx #16
CopyRow
 ldy #0
CopyByte
 lda ($82),y
 sta ($84),y
 iny
 cpy $2DCC
 bcc CopyByte
 clc
 lda $82
 adc #2
 sta $82
 bcc SourceReady
 inc $83
SourceReady
 clc
 lda $84
 adc #64
 sta $84
 bcc TargetReady
 inc $85
TargetReady
 dex
 bne CopyRow
CopyDone
 rts
 ert * > $0680
