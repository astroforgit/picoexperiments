; Six-bullet curtain with one 32-pixel opening and two trailing edge guards.
 opt h-
 org $6550
 jmp BossTick
 jmp Approach
BossTick
 lda $2D7C
 beq AdvanceClock
 dec $2D7C
 lda $2D70
 sta $1BBF
 lda #29
 sta $2D76
 rts
AdvanceClock
 inc $2D76
 lda $2D76
 cmp #30
 bcc HavePhase
 lda #0
HavePhase
 sta $2D76
 sta $2D79
 bne Running
 lda $2D74
 bne Selected
 inc $2D78
 lda $2D78
 cmp #7
 bcc Selected
 lda #1
 sta $2D78

Selected
 sta $2D77
 ; Alternate distant openings: every transition requires a full-height dodge.
 lda $2D7B
 eor #1
 sta $2D7B
 asl
 asl
 clc
 adc #1
 sta $2D7A
 lda $2D77
 sec
 sbc #1
 asl
 ora $2D7B
 tax
 lda $2D74
 bne SoloTiming
 lda $2340,x
 bne GuardTiming
SoloTiming
 lda $2330,x
GuardTiming
 sta $2D7D

Running
 lda $2D70
 cmp $1BBF
 beq NoBomb
 sta $1BBF
 lda #24
 sta $2D7C
 lda #0
 ldx #7
BombClear
 sta $1BE0,x
 dex
 bpl BombClear
 rts
NoBomb
 jsr $1806
Done
 rts
; A=current, target=$1BB6, maximum step=$1BB7.
Approach
 cmp $1BB6
 beq Approached
 bcc Increase
 sec
 sbc $1BB7
 bcc Target
 cmp $1BB6
 bcs Approached
Target
 lda $1BB6
 rts
Increase
 clc
 adc $1BB7
 cmp $1BB6
 bcs Target
Approached
 rts
 ert * > $6684
