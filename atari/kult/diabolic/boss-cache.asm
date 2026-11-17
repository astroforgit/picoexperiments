; Per-framebuffer body reuse, valid only while terrain scrolling is held.
 opt h-
 org $1780
 jmp Reuse
 jmp Erase
Valid=$2DD2
CacheX=$2DD4
CacheY=$2DD6
CacheFrame=$2DD8
CacheType=$2DDA
Reuse
 lda $F398
 bne Dirty
 ldx $7439
 lda Valid,x
 beq Dirty
 lda $FD04
 beq SubHealth
 lda $FD0A
 beq Dirty
 bne Present
SubHealth
 lda $2D20
 cmp #4
 bne Dirty
 lda $2D22
 beq Dirty
Present
 lda $2DC0
 cmp #4
 beq Dirty
 cmp #5
 beq Dirty
 cmp #7
 beq Dirty
 lda $2D23
 cmp #128
 bcs Dirty
 cmp CacheX,x
 bne Dirty
 lda $2D24
 cmp CacheY,x
 bne Dirty
 lda $2DC8
 cmp CacheFrame,x
 bne Dirty
 lda $FD04
 cmp CacheType,x
 bne Dirty
 sec
 rts
Dirty
 clc
 rts
Erase
 jsr Reuse
 bcs Done
 ldx $7439
 lda #0
 sta Valid,x
 jmp $FC7E
Done
 rts
 ert * > $1800
