; Laser razors. Retired title-music data; gameplay uses the separate SFX driver.
 opt h-
 org $DF00
 jmp Load
 jmp Move
 jmp DisplayFrame
 jmp Update
 jmp Draw
 jmp Scroll
 jmp Erase
 jmp WaveGate
 jmp WaveKind
Phase=$2DE8 ; 1 warning, 2 live, 3 finished
Timer=$2DE9 ; PAL display frames, not game updates
Pattern=$2DEA
Rendered=$2DEB
Dirty=$2DEC ; one byte per framebuffer
Row=$2DEE
Bits=$2DEF
Fill=$2DF1
ActivePattern=$2DF2
Column=$2DF3
BeamY=$2DF4
Slope=$2DF5
Paint=$2DF6 ; 0 erase, 1 warning, 2 live
LastColumn=$2DF7
Offset=$2DF8
SavedBaseLo=$2DF9 ; absolute row-zero origin per framebuffer
SavedBaseHi=$2DDE
Core=$2DFB
NextRoute=$2DFC
End=$2DDD
Load
 and #31
 jsr $3B00
 lda $FB8B
 bpl Done
 lda #8
 sta $2D20
 lda NextRoute
 sta Pattern
 clc
 adc #15
 sta End
 cmp #45
 bcc StoreNextRoute
 lda #0
StoreNextRoute
 sta NextRoute
 lda #0
 sta Rendered
 sta $7444
 ldx #7
ClearActors
 sta $74E0,x
 sta $7482,x
 dex
 bpl ClearActors
 lda #1
 sta Phase
 lda #WarningFrames
 sta Timer
Done
 rts
Move
 lda $2D20
 cmp #8
 jeq Done
 jmp $3B03
DisplayFrame
 lda $2D20
 cmp #8
 jne Done
 lda $F398
 jne Done
 lda Rendered
 jeq Done
 lda Timer
 jeq Done
 dec Timer
 rts
Scroll
 lda $F398
 bne NormalScroll
 lda $2D20
 cmp #8
 beq Hold
NormalScroll
 jmp $DE80
Hold
 jmp $EAD8
WaveGate
 lda $2DC0
 cmp #255
 beq NormalGate
 lda $2D20
 cmp #8
 bne NormalGate
 lda Phase
 cmp #3
 beq NormalGate
 clc
 rts
NormalGate
 jmp $030F
WaveKind
 ; Extended encounter: high bit of the sprite slot, native kind zero.
 dey
 lda ($80),y
 bmi LaserKind
 iny
 lda ($80),y
 and #$E0
 rts
LaserKind
 iny
 lda #$10
 rts
Update
 lda $2D20
 cmp #8
 beq LaserUpdate
 jmp $F940
LaserUpdate
 lda $F398
 beq PilotAlive
 lda #1
 sta Phase
 lda #WarningFrames
 sta Timer
 lda #0
 sta Rendered
 rts
PilotAlive
 lda Phase
 cmp #3
 jeq Done
 lda Timer
 bne Collision
 lda Rendered
 beq Collision
 lda #0
 sta Rendered
 lda Phase
 cmp #1
 beq Energize
 inc Pattern
 lda Pattern
 cmp End
 bcc Warn
 lda #3
 sta Phase
 rts
Warn
 lda #1
 sta Phase
 lda #WarningFrames
 sta Timer
 jmp Collision
Energize
 lda #2
 sta Phase
 lda #LiveFrames
 sta Timer
 ; A short laser chirp marks activation, independent of firing settings.
 ldx #2
 ldy #4
 lda #24
 jsr $F533
Collision
 lda $F0BF
 beq CheckShield
 dec $F0BF
 rts
CheckShield
 lda $2D61
 jne Done
 lda Phase
 cmp #2
 jne Done
 lda Rendered
 cmp #2
 jcc Done
 lda Pattern
 sta ActivePattern
 ldx Pattern
 lda Sequence,x
 tax
 lda Masks,x
 sta Bits
 lda #0
 sta Row
HitRow
 lsr Bits
 bcc NextHitRow
 jsr SetSlope
 lda $E957
 lsr
 lsr
 sta Column
 lda $E957
 clc
 adc #19
 lsr
 lsr
 sta LastColumn
HitColumn
 jsr Coordinate
 cmp #125
 bcs NextHitColumn
 sec
 sbc $E958
 clc
 adc #3
 cmp #19
 bcs NextHitColumn
 lda #3
 sta $F398
 rts
NextHitColumn
 inc Column
 lda Column
 cmp LastColumn
 bcc HitColumn
 beq HitColumn
NextHitRow
 inc Row
 lda Row
 cmp #8
 bcc HitRow
 rts
; Interleave horizontal, parallel diagonal, and crossed patterns.
SetSlope
 lda #0
 sta Slope
 ldx ActivePattern
 lda Sequence,x
 tax
 lda Types,x
 beq SlopeDone
 lda #1
 sta Slope
 lda Types,x
 cmp #2
 bne SlopeDone
 lda Row
 and #1
 beq SlopeDone
 lda #255
 sta Slope
SlopeDone
 rts
Coordinate
 ldx Row
 lda Slope
 beq Horizontal
 bmi Ascending
 lda Column
 sec
 sbc #16
 clc
 adc Rows,x
 rts
Ascending
 lda #16
 sec
 sbc Column
 clc
 adc Rows,x
 rts
Horizontal
 lda Rows,x
 rts
Erase
 jsr $1783
 ldx $7439
 lda Dirty,x
 beq EraseDone
 sec
 sbc #1
 sta ActivePattern
 lda #0
 sta Dirty,x
 sta Paint
 jmp Raster
EraseDone
 rts
Draw
 jsr DrawLines
 jmp $0480
DrawLines
 lda $2D20
 cmp #8
 bne EraseDone
 lda $F398
 bne EraseDone
 lda Phase
 cmp #3
 beq EraseDone
 sta Paint
 ldx $7439
 lda Pattern
 sta ActivePattern
 clc
 adc #1
 sta Dirty,x
 ldx $7446
 ldy #0
 jsr $EF43
 ldx $7439
 lda $F8
 sta SavedBaseLo,x
 lda $F9
 sta SavedBaseHi,x
 lda Rendered
 cmp #2
 bcs Raster
 inc Rendered
Raster
 lda #0
 sta Row
 sta Core
 sta Fill
 lda Paint
 beq BeginRaster
 lda #$FF ; ANTIC F is one bit per pixel: a solid one-scanline warning
 sta Fill
 sta Core
 lda Paint
 cmp #1
 beq BeginRaster
 lda #$FF
 sta Core
 lda Timer
 and #4
 beq PulseBright
 lda #$AA
 bne PulseReady
PulseBright
 lda #$FF
PulseReady
 sta Fill
BeginRaster
 ldx ActivePattern
 lda Sequence,x
 tax
 lda Masks,x
 sta Bits
RasterRow
 lsr Bits
 jcc NextRasterRow
 jsr SetSlope
 lda #0
 sta Column
 jsr Coordinate
 sta BeamY
 ; Screen rows are 64 bytes apart. Start at the beam's central row,
 ; then move sixteen rows back/forward for a diagonal's left endpoint.
 ; Reuse the original physical origin even if death/respawn changed
 ; the live display-list pointers since this buffer was last drawn.
 ldx $7439
 lda SavedBaseLo,x
 sta $F8
 lda SavedBaseHi,x
 sta $F9
 ldx Row
 lda Rows,x
 lsr
 lsr
 clc
 adc $F9
 sta $F9
 lda Slope
 beq RasterColumn
 bmi StartUp
 lda $F9
 sec
 sbc #4
 sta $F9
 jmp RasterColumn
StartUp
 lda $F9
 clc
 adc #4
 sta $F9
RasterColumn
 lda BeamY
 cmp #128
 bcs Advance
 ldy #0
 lda Fill
 sta ($F8),y
 lda Paint
 cmp #1
 beq Advance
 lda BeamY
 cmp #125
 bcs Advance
 ldy #64
 lda Core
 sta ($F8),y
 ldy #128
 sta ($F8),y
 ldy #192
 lda Fill
 sta ($F8),y
Advance
 lda Slope
 beq NextByte
 bmi StepUp
 inc BeamY
 lda $F8
 clc
 adc #64
 sta $F8
 bcc NextByte
 inc $F9
 jmp NextByte
StepUp
 dec BeamY
 lda $F8
 sec
 sbc #64
 sta $F8
 bcs NextByte
 dec $F9
NextByte
 inc $F8
 bne PointerReady
 inc $F9
PointerReady
 inc Column
 lda Column
 cmp #32
 bcc RasterColumn
NextRasterRow
 inc Row
 lda Row
 cmp #8
 jcc RasterRow
 rts
Rows dta 8,24,40,56,72,88,104,120
 icl 'lasers-data.inc'
 ert * > $E300
