; Shared original guardian tile renderer, now also used by 64x64 sub-bosses.
; $0480..$17FF used to hold packed terrain maps; their decoder is retired.
 opt h-
 org $0480
DrawBoss
 lda $FD04
 bne OriginalGuardian
 lda $2D20
 cmp #4
 beq SubBoss
OriginalGuardian
 jmp $FDD5
SubBoss
 lda $2D22
 beq Done
 ; Preserve the original guardian's coordinates, tile source and map pointer.
 ldx #9
SaveState
 lda $FCFA,x
 pha
 dex
 bpl SaveState
 lda #88
 sta $FCFA
 lda #32
 sta $FCFB
 lda #0
 sta $FCFE
 lda #8
 sta $FCFF
 lda $2D21
 lsr
 lsr
 and #3
 asl
 asl
 asl
 asl
 sta $FD00
 lda #$10
 sta $FD01
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
 ert * > $0800
