; Aimed shots gated by muzzle distance, at any point in an enemy wave.
 opt h-
 org $E300
 jmp Gate
 jmp Aim
Age=$2DFC
Count=$2DFD
Den=$2DFE
Sign=$2DFF
Gate
 pha
 sec
 sbc $E957
 bcc Reject
 cmp #52
 bcc Reject
 pla
 clc
 rts
Reject
 pla
 sec
 rts
Aim
 lda #0
 sta Den
 sta Count
 sta Sign
 lda $2D02
 sta Speed+1
 lda $2D20
 cmp #7
 bne HaveSpeed
 lda #6
 sta Speed+1
HaveSpeed
 lda $2D14,x
 sec
 sbc $E957
Travel
 inc Den
 sec
Speed
 sbc #6
 beq TravelReady
 bcs Travel
TravelReady
 lda $E958
 clc
 adc #8
 sec
 sbc $2D18,x
 bcs Positive
 eor #255
 clc
 adc #1
 inc Sign
Positive
 pha
 lda Den
 lsr
 sta Count
 pla
 clc
 adc Count
 ldy #0
Divide
 cmp Den
 bcc Divided
 sec
 sbc Den
 iny
 bne Divide
Divided
 tya
 ldy Sign
 beq AimDone
 eor #255
 clc
 adc #1
AimDone
 rts
 ert * > $E460
