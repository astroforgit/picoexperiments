; Four staggered, curving projectiles emitted from the skull's front/mouth.
; $2D80..83 = per-projectile age; $2D7B = captured vertical aim (-1,0,1).
 opt h-
 org $6550
BossTick
 inc $2D76
 lda $2D76
 cmp #192
 bcc ClockReady
 lda #0
 sta $2D76
ClockReady
 sta $2D79
 cmp #1
 bne PatternReady
 lda $E958
 clc
 adc #8
 sta $2D7F
 lda $2D24
 clc
 adc #16
 cmp $2D7F
 beq AimLevel
 bcc AimDown
 lda #255
 bne AimStore
AimDown
 lda #1
 bne AimStore
AimLevel
 lda #0
AimStore
 sta $2D7B
 lda $2D74
 bne StorePattern
 inc $2D78
 lda $2D78
 cmp #4
 bcc StorePattern
 lda #1
 sta $2D78
StorePattern
 sta $2D77
 ldx #3
 lda #0
ClearOld
 sta $2D10,x
 dex
 bpl ClearOld
PatternReady
 lda $2D75
 clc
 adc #2
 sta $2D7C
 ldx #3
Velocity
 lda $2D10,x
 cmp #1
 bne NextVelocity
 inc $2D80,x
 lda $2D80,x
 ldy $2D77
 cpy #3
 bne PhaseReady
 lsr
PhaseReady
 sta $2D7D
 txa
 asl
 asl
 clc
 adc $2D7D
 and #15
 tay
 lda Curve,y
 clc
 adc $2D7B
 sta $2D1C,x
 lda $2D77
 cmp #1
 bne NextVelocity
 lda $2D1C,x
 clc
 adc Fan,x
 sta $2D1C,x
NextVelocity
 dex
 bpl Velocity
 lda $2D79
 cmp #24
 bcc Warning
 cmp #56
 bcc FirstTrain
 cmp #80
 bcc Done
 cmp #112
 bcs Done
 sec
 sbc #80
 jmp TrainSlot
FirstTrain
 sec
 sbc #24
TrainSlot
 pha
 and #7
 beq Emit
 pla
 rts
Emit
 pla
 lsr
 lsr
 lsr
 tax
 lda $2D10,x
 cmp #1
 beq Done
 lda #1
 bne Spawn
Warning
 ldx #0
 lda #2
Spawn
 sta $2D10,x
 lda $2D23
 sta $2D14,x
 lda $2D24
 clc
 adc #16
 sta $2D18,x
 lda #0
 sta $2D50,x
 sta $2D80,x
 sta $2D1C,x
Done
 rts
Curve dta 2,2,1,1,0,255,254,254,254,254,255,255,0,1,2,2
Fan dta 0,255,1,0
 ert * > $6684
