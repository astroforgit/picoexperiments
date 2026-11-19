; Two staggered diagonal streams. Reuse the retired original guardian attack.
 opt h-
 org $FE83
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
Place
 cmp Starts,x
 beq Visible
 bcc Visible
 lda #255
 sta $2D40,x
 lda #128
 sta $74E0,x
 bne Skip
Visible
 sta $2D40,x
 sta $746A,x
 txa
 and #1
 beq Down
 lda #127
 sec
 sbc $2D40,x
 sta $746A,x
Down
 lda Starts,x
 sec
 sbc $2D40,x
 sec
 sbc $7446
 sta $7462,x
Skip
 dex
 bpl Next
 rts
Delays dta 12,55,65,53,49,58,42,35
Speeds dta 2,5,5,5,4,5,3,3
Starts dta 127,127,107,107,87,87,67,67
 ert * > $FF12
