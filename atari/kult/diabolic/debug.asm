; TEMPORARY DEBUG: 1 skull, 2 top, 3 bottom, 4 right, 5 top/bottom, 6 Insect Queen.
; POKEY key codes verified against Altirra uikeyboard.cpp.
 opt h-
 org $3F50
DebugWave
 lda $D20F
 and #4
 bne Released
 lda $D209
 and #$3F
 ldx #5
FindKey
 cmp Keys,x
 beq Pressed
 dex
 bpl FindKey
Released
 lda #0
 sta $2D7E
 jmp $FB8C
Pressed
 cmp $2D7E
 bne JumpWave
 jmp $FB8C
JumpWave
 sta $2D7E
 lda Kinds,x
 sta CompareKind+1
 jsr $FB5F
 ldy #1
 lda CompareKind+1
 beq FoundBoss
FindBoss
 lda ($80),y
 and #$E0
CompareKind
 cmp #$80
 beq FoundBoss
 iny
 iny
 iny
 iny
 cpy #193
 bcc FindBoss
 jmp $FB8C
FoundBoss
 tya
 lsr
 lsr
 sta $FB8A
 lda #0
 sta $FD04
 sta $4E79
 sta $F398
 sta $2D61
 ldx #7
ClearActors
 sta $74E0,x
 sta $7482,x
 dex
 bpl ClearActors
 ldx #5
ClearPlayerShots
 sta $74E8,x
 dex
 bpl ClearPlayerShots
 ldx #3
ClearEnemyShots
 sta $2D10,x
 dex
 bpl ClearEnemyShots
 lda #12
 sta $E957
 lda #56
 sta $E958
 lda #40
 sta $F0BF
 lda $2D7E
 cmp #$1B
 bne LoadWave
 lda #33
 sta $4E79
LoadWave
 ; The normal loader enters the original guardian at progress 33.
 jmp $FB8C
Keys dta $1F,$1E,$1A,$18,$1D,$1B
Kinds dta $80,$20,$40,$60,$C0,0
 ert * > $4000
