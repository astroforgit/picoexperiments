; Harmless shot burst, using the existing eight software sprites.
; Reclaim retired HUD routines while preserving their RTS entry points.
 opt h-
 org $F39E
Tick
 lda $2DC0
 cmp #10
 beq Done
 cmp #9
 beq Advance
 jmp Init
Advance
 inc $2DC1
 lda $2DC1
 cmp #24
 bcc MoveJump
 lda #10
 sta $2DC0
 jmp $0303
MoveJump
 jmp Move
Done
 rts
 :($F3E5-*) dta 0
 rts ; retired fuel HUD entry
Init
 lda #9
 sta $2DC0
 lda #0
 sta $2DC1
 lda #1
 sta $2DC4
 ldx #7
Seed
 lda $2D23
 clc
 adc #12
 sta $1BD0,x
 lda $2D24
 clc
 adc #8
 sta $1BD8,x
 lda #1
 sta $1BE0,x
 dex
 bpl Seed
 ldx #3
 ldy #3
 lda #52
 jmp $F533
 :($F420-*) dta 0
 rts ; retired bomb HUD entry
Move
 ldx #7
Next
 lda $1BE0,x
 beq Skip
 lda $1BD0,x
 clc
 adc DX,x
 cmp #128
 bcs Remove
 sta $1BD0,x
 lda $1BD8,x
 clc
 adc DY,x
 cmp #128
 bcs Remove
 sta $1BD8,x
 bcc Skip
Remove
 lda #0
 sta $1BE0,x
Skip
 dex
 bpl Next
 rts
DX dta 253,254,0,2,3,2,0,254
DY dta 0,252,250,252,0,4,6,4
 ert * > $F465
