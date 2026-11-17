; Project lane progress into disjoint vertical columns or horizontal rows.
; Called with X = actor and A = progress (0..127). One actor owns each lane.
 opt h-
 org $2360
 sta $746A,x
 lda $2D20
 cmp #3
 beq FromRight
 cmp #2
 beq FromBelow
 cmp #6
 bne Vertical
 txa
 and #1
 beq Vertical
FromBelow
 lda #127
 sec
 sbc $2D40,x
 sta $746A,x
Vertical
 lda Columns,x
 jmp StoreX
FromRight
 lda Rows,x
 sta $746A,x
 lda #127
 sec
 sbc $2D40,x
StoreX
 sec
 sbc $7446
 sta $7462,x
 rts
Columns dta 8,68,108,38,88,18,58,118
Rows dta 0,64,112,32,96,16,80,48
 ert * > $2400
