; Reclaimed invisible-target source page. Targets now use the blank terrain tile.
 opt h-
 org $2E00
 jmp Poll
 jmp Move
 jmp Boss
 jmp Offset
 jmp DisplayFrame
 jmp Init
 jmp Collect
 jmp Scroll
 jmp PlayerShots
Time=$2D90
Stock=$2D91
Held=$2D92
Phase=$2D93
Skip=$2D94
Poll
 lda #0
 sta Skip
 lda $F398
 beq Keys
 sta Held
 lda #0
 sta Time
 beq Done
Keys
 lda $D20F
 and #4
 bne Released
 lda $D209
 and #$3F
 cmp #$17 ; Z
 beq Pressed
 cmp #$16 ; X
 beq Pressed
 cmp #$12 ; C
 bne Released
Pressed
 lda Held
 bne Pace
 inc Held
 lda Time
 bne Pace
 lda Stock
 beq Pace
 dec Stock
 lda #150 ; 150 PAL display frames = three seconds, independent of game speed.
 sta Time
 lda #0
 sta Phase
 beq Pace
Released
 lda #0
 sta Held
Pace
 lda Time
 beq Done
 inc Phase
 lda Phase
 cmp #3
 bcc HoldPhase
 lda #0
 sta Phase
HoldPhase
 sta Skip
Done
 lda $F398 ; Preserve the original game-loop death branch.
 rts
Move
 lda Skip
 bne Return
 jmp $DF03
Boss
 jmp $2FD8
Return
 rts

Offset
 lda Skip
 bne Return
 dec $7444
 rts
DisplayFrame
 pha
 lda $7460 ; Do not spend the effect while the game is paused.
 bne FrameDone
 jsr $DF06
 lda Time
 beq FrameDone
 dec Time
FrameDone
 pla
 rts
Init
 lda #3
 sta Stock
 lda #0
 sta Time
 sta Held
 sta Phase
 sta Skip
 rts
Collect
 cmp #5
 bne BombGift
 lda Stock
 cmp #3
 bcs Collected
 inc Stock
 bne Collected
BombGift
 lda $2D70
 cmp #3
 bcs Collected
 inc $2D70
Collected
 jmp $F9CC
Scroll
 lda Skip
 beq NormalScroll
 jmp $EAD8
NormalScroll
 jmp $DF0F
PlayerShots
 ; Player firing and projectiles always advance at normal speed.
 jmp $F22F
 ert * > $2F00
