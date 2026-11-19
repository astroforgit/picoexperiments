; Extra sprite layer. Retired terrain-map storage is reserved by the builder.
; Two 512-byte background stores; restore in reverse order to handle overlap.
 opt h-
 org $1800
 jmp Erase
 jmp Draw
 jmp Update
 jmp HitSprite
Slot = $1BB0
Record = $1BB1
Rows = $1BB2
PhysicalX = $1BB3
Width = $1BBB
Update
 ldx #7
Actors
 stx Slot
 lda $1BE0,x
 bne Active
SpawnCheck
 lda #0
 cpx #6
 bcc SpawnPhase
 lda $2D7D
SpawnPhase
 cmp $2D79
 beq SpawnNow
 jmp NextActor
SpawnNow
 lda #0
 sta $1BE8,x
 lda #1
 sta $1BE0,x
 lda $2D23
 sta $1BD0,x
 sta $1BC8,x
 lda $2D77
 sta $1BC0,x
 lda $2D24
 clc
 adc #16
 sta $1BD8,x
 ; Keep each bullet's lane: older guards survive the next wave's gap change.
 txa
 cpx #6
 bcc MainCurtain
 lda $2D7A
 cpx #6
 bne LowerGuard
 sec
 sbc #1
 jmp RowReady
LowerGuard
 clc
 adc #2
 jmp RowReady
MainCurtain
 cmp $2D7A
 bcc RowReady
 clc
 adc #2
RowReady
 asl
 asl
 asl
 asl
 sta $1BF0,x
 jmp Collision
Active
 inc $1BE8,x
 lda $1BE8,x
 cmp #3
 bcs StartSpread
 jmp Collision
StartSpread
 cmp #19
 bcs Rush
 lda $1BD0,x
 clc
 adc #2
 sta $1BD0,x
 sta $1BC8,x
 lda $1BF0,x
 sta $1BB6
 lda #4
 sta $1BB7
 lda $1BD8,x
 jsr $6553
 sta $1BD8,x
 jmp Collision
Rush
 lda $1BC8,x
 sec
 sbc #12
 bcs ContinueShot
 lda #0
 sta $1BE0,x
 jmp SpawnCheck
ContinueShot
 sta $1BC8,x
 ; Original Kult sine table: S curtain, cosine arc, double-frequency ribbon.
 lda $1BE8,x
 sec
 sbc #19
 asl
 asl
 asl
 sta $1BB8
 ldy $1BC0,x
 lda $2300,y
 beq NormalFrequency
 asl $1BB8
NormalFrequency
 lda $2310,y
 clc
 adc $1BB8
 sta $1BB8
 lda $1BF0,x
 sta $1BBA
 ldy $1BC0,x
 lda $2320,y
 tay
 lda $1BBA
 cpy #0
 beq RowPhase
RowFrequency
 asl
 dey
 bne RowFrequency
RowPhase
 clc
 adc $1BB8
 sta $1BB9
 ldy $1BC0,x
 lda $2350,y
 clc
 adc $1BB9
 tay
 lda $7164,y
 lsr
 lsr
 lsr
 clc
 adc $1BC8,x
 sec
 sbc #3
 bcs PositiveX
 lda #0
PositiveX
 sta $1BD0,x
 ldy $1BB8
 lda $7164,y
 lsr
 lsr
 lsr
 clc
 adc $1BF0,x
 sec
 sbc #3
 bcs PositiveY
 lda #0
PositiveY
 cmp #113
 bcc TargetY
 lda #112
TargetY
 sta $1BB6
 lda #2
 sta $1BB7
 lda $1BD8,x
 jsr $6553
 sta $1BD8,x

Collision
 jsr HitSprite
NextActor
 dex
 bmi UpdateDone
 jmp Actors
UpdateDone
 rts

HitSprite
 lda $2DC0
 cmp #9
 bcs HitDone
 lda $F0BF
 ora $F398
 ora $2D61
 bne HitDone
 ; Orb art uses a forgiving central hitbox; curtains and rocks retain theirs.
 ldy $2DC4
 lda $1BD0,x
 sec
 sbc $E957
 clc
 adc HitXBias,y
 cmp HitWidth,y
 bcs HitDone
 lda $1BD8,x
 sec
 sbc $E958
 clc
 adc HitYBias,y
 cmp HitHeight,y
 bcs HitDone
HitPlayer
 lda #3
 sta $F398
HitDone
 rts

; Ship core [6,16) x [4,12), orb core [2,6) x [4,12).
HitXBias dta 8,255,8
HitWidth dta 28,13,28
HitYBias dta 16,7,16
HitHeight dta 32,15,32

; Return the per-buffer record index and backup pointer in FC/FD.
BackupPointer
 lda $7439
 asl
 asl
 asl
 ora Slot
 sta Record
 lda Slot
 and #3
 asl
 asl
 asl
 asl
 asl
 asl
 sta $FC
 lda Slot
 lsr
 lsr
 clc
 adc #$1C
 sta $FD
 lda $7439
 asl
 clc
 adc $FD
 sta $FD
 rts

Erase
 lda #7
 sta Slot
EraseActor
 jsr BackupPointer
 ldx Record
 lda $1BA0,x
 jeq EraseNext
 pha
 and #$60
 lsr
 lsr
 lsr
 lsr
 lsr
 sta Width
 pla
 and #31
 sta Rows
 asl
 clc
 adc Rows
 sta Rows
 lda #0
 sta $1BA0,x
 lda $1B80,x
 sta $F8
 lda $1B90,x
 sta $F9
 lda Width
 cmp #3
 bne EraseClipped
 ldy #0
EraseFastRow
 lda ($FC),y
 sta ($F8),y
 iny
 lda ($FC),y
 sta ($F8),y
 iny
 lda ($FC),y
 sta ($F8),y
 iny
 jsr NextRow
 cpy Rows
 bne EraseFastRow
 jmp EraseNext
EraseClipped
 ldy #0
EraseRow
 lda ($FC),y
 sta ($F8),y
 iny
 lda Width
 cmp #2
 bcc ErasePadding
 lda ($FC),y
 sta ($F8),y
ErasePadding
 iny
 iny
 jsr NextRow
 cpy Rows
 bne EraseRow
EraseNext
 dec Slot
 jpl EraseActor
 jmp $3B1E

Draw
 jsr $3B1B
 lda $FD04
 bne DrawGuardian
 lda $2D20
 cmp #4
 beq DrawBoss
 rts
DrawGuardian
 lda $FD0A
 jmp DrawHealth
DrawBoss
 lda $2D22
DrawHealth
 bne DrawReady
 lda $2DC0
 cmp #9
 bne EarlyDone
 jmp DrawReady
EarlyDone
 rts
DrawReady
 lda #0
 sta Slot
DrawActor
 ldx Slot
 lda $1BE0,x
 jeq DrawNext
 lda $1BD0,x
 cmp #128
 jcs DrawNext
 clc
 adc $7446
 sta PhysicalX
 ; Clip off-right bytes before saving or drawing. They otherwise spill into
 ; the next scanline/buffer when the scroll origin is at the end of a row.
 and #3
 clc
 adc #131
 sec
 sbc $1BD0,x
 lsr
 lsr
 cmp #3
 bcc HaveWidth
 lda #3
HaveWidth
 sta Width
 lda $1BD8,x
 cmp #128
 jcs DrawNext
 tay
 lda #128
 sec
 sbc $1BD8,x
 cmp #16
 bcc RowCount
 lda #16
RowCount
 sta Rows
 ldx PhysicalX
 jsr $EF43
 jsr BackupPointer
 ldx Record
 lda Width
 asl
 asl
 asl
 asl
 asl
 ora Rows
 sta $1BA0,x
 lda $F8
 sta $1B80,x
 lda $F9
 sta $1B90,x
 jsr $0315
 lda Rows
 asl
 clc
 adc Rows
 sta Rows
 lda Width
 cmp #3
 bne DrawClipped
 ldy #0
DrawFastRow
 lda ($F8),y
 sta ($FC),y
 ora ($FA),y
 sta ($F8),y
 iny
 lda ($F8),y
 sta ($FC),y
 ora ($FA),y
 sta ($F8),y
 iny
 lda ($F8),y
 sta ($FC),y
 ora ($FA),y
 sta ($F8),y
 iny
 jsr NextRow
 cpy Rows
 bne DrawFastRow
 jmp DrawNext
DrawClipped
 ldy #0
DrawRow
 lda ($F8),y
 sta ($FC),y
 ora ($FA),y
 sta ($F8),y
 iny
 lda Width
 cmp #2
 bcc DrawPadding
 lda ($F8),y
 sta ($FC),y
 ora ($FA),y
 sta ($F8),y
DrawPadding
 iny
 iny
 jsr NextRow
 cpy Rows
 bne DrawRow
DrawNext
 inc Slot
 lda Slot
 cmp #8
 beq DrawDone
 jmp DrawActor
DrawDone
 rts
NextRow
 ; Y walks the 48-byte sprite and backup linearly (three bytes per row).
 ; Move the screen pointer by 64-3 so pointer+Y still advances one scanline.
 clc
 lda $F8
 adc #61
 sta $F8
 bcc FrameReady
 inc $F9
FrameReady
 rts
 ert * > $1B80
