; TEMPORARY DEBUG: press 1 once to load the first skull wave in this sector.
; Key code follows atari800/src/akey.h (AKEY_1=$1F).
 opt h-
 org $3F50
DebugWave
 lda $D20F
 and #4
 bne Released
 lda $D209
 and #$3F
 cmp #$1F
 beq Pressed
Released
 lda #0
 sta $2D7E
 jmp $FB8C
Pressed
 lda $2D7E
 beq JumpBoss
 jmp $FB8C
JumpBoss
 inc $2D7E
 jsr $FB5F
 ldy #1
FindBoss
 lda ($80),y
 and #$E0
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
 ; Let the normal loader rebuild graphics, HP, paths, and the boss clock.
 jmp $FB8C
 ert * > $4000
