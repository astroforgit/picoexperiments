 opt h-
 org $2F88
 jsr $F48C
 jsr $F475
 lda $4E78
 sec
 sbc #1
 sta $2D96
 lda $2D70
 sta $2D97
 lda $4E77
 sta $2D98
 lda $2D91
 sta $2D99
 ldx #3
Counter
 stx $2D95
 lda CounterLow,x
 sta $80
 lda #$67
 sta $81
 lda $2D96,x
 and #15
 asl
 asl
 asl
 tax
 jsr $EA34
 ldx $2D95
 dex
 bpl Counter
 jsr $638D
 jmp $3B0F
CounterLow dta $36,$3A,$3E,$42
 :($2FD8-*) dta 0
 ; Pause boss movement, but keep collision checks alive for stationary bullets.
 lda $2D94
 beq BossMoves
 lda $FD04
 bne Collide
 lda $2D20
 cmp #4
 bne Done
Collide
 ldx #7
Loop
 lda $1BE0,x
 beq Next
 jsr $1809
Next
 dex
 bpl Loop
Done
 rts
BossMoves
 jmp $DAC0
 ert * > $3000
