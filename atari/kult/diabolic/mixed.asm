; Mixed wave: two rocks and six shootable enemies, one pass per lane.
; Retired literal terrain page: no extra packed-loader allocation.
 opt h-
 org $2420
 jmp Load
 jmp Move
 jmp Frame
 jmp Bomb
Load
 lda $2D25
 jsr $F16B
 ; Keep enemy animation frames 0/1 and explosion frames 4..7 intact.
 lda #3
 ldx #0
 ldy #$2F
 jmp $F0C4
Move
 lda #0
 sta $7444
 inc $2D21
 ldx #7
Next
 lda $74E0,x
 cmp #16
 bne Skip
 lda $2D40,x
 cmp #128
 bcc Flying
 bne Skip
 lda $2D21
 cmp Delays,x
 bcc Waiting
 lda #0
 beq Place
Waiting
 lda #128
 sec
 sbc $7446
 sta $7462,x
 jmp Skip
Flying
 clc
 adc Speeds,x
 cmp #128
 bcc Place
 lda #255
 sta $2D40,x
 lda #128
 sta $74E0,x
 bne Skip
Place
 sta $2D40,x
 lda #127
 sec
 sbc $2D40,x
 sec
 sbc $7446
 sta $7462,x
 lda Rows,x
 sta $746A,x
Skip
 dex
 bpl Next
 rts
Frame
 lda $FD04
 bne Ordinary
 lda $2D20
 cmp #7
 beq MixedFrame
 cmp #4
 bne Ordinary
 tya
 rts
MixedFrame
 cpy #2
 bcs EnemyFrame
 lda #3
 rts
EnemyFrame
 lda $743C,x
 and #1
 rts
Ordinary
 lda $743C,x
 rts
Bomb
 lda $2D20
 cmp #7
 bne BombDone
 ldy #7
BombEnemy
 lda $74E0,y
 cmp #16
 bne BombNext
 lda #4
 sta $74E0,y
BombNext
 dey
 cpy #2
 bcs BombEnemy
BombDone
 lda $2D20 ; Return the mode AND its zero flag to the original bomb branch.
 rts
Delays dta 1,57,9,21,33,45,69,81
Speeds dta 2,3,5,5,5,5,5,5
Rows dta 16,96,0,32,48,64,80,112
 ert * > $2500
