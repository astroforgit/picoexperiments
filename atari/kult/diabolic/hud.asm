; Bottom-only HUD. Reuses the hidden top panel's 768 bytes.
 opt h-
 org $6384
 jmp HudUpdate
 jmp HudInit
 jmp BombKey
 jmp WeaponPreview
 jmp BossBar
HudInit
 sta $4E77
 sta $2D70
 jsr $2E0F
 lda #0
 sta $2D71
 rts
HudUpdate
 jmp $2F88

WeaponPreview
 ; Four 16x16 dotted firing patterns, selected by the native weapon index.
 lda $F24D
 and #3
 asl
 asl
 asl
 asl
 asl
 tax
 lda #<($6684+8*32+5)
 sta $80
 lda #>($6684+8*32+5)
 sta $81
 lda #16
 sta $2D73
WeaponRow
 ldy #0
 lda Patterns,x
 sta ($80),y
 inx
 iny
 lda Patterns,x
 sta ($80),y
 inx
 clc
 lda $80
 adc #32
 sta $80
 bcc WeaponNext
 inc $81
WeaponNext
 dec $2D73
 bne WeaponRow
 lda $43FF
 and #2
 beq FlameShort
 lda #$D0
 bne DrawFlame
FlameShort
 lda #$50
DrawFlame
 sta $6684+12*32+1
 sta $6684+20*32+1
 rts
BossBar
 ; Eight segments at bottom-right; zero the whole meter when no boss exists.
 ldx #7
BossSegment
 lda #0
 ldy $2D2F
 beq StoreSegment
 lda #$7E
StoreSegment
 sta $6684+22*32+23,x
 sta $6684+27*32+23,x
 lda #0
 ldy $2D2F
 beq FillSegment
 lda #$42
 cpx $2D2E
 bcs FillSegment
 lda #$7E
FillSegment
 sta $6684+23*32+23,x
 sta $6684+24*32+23,x
 sta $6684+25*32+23,x
 sta $6684+26*32+23,x
 dex
 bpl BossSegment
 rts
BombKey
 lda $D20F
 and #8
 beq BombPressed
 lda #0
 sta $2D71
 rts
BombPressed
 lda $2D71
 bne BombDone
 inc $2D71
 lda $2D70
 beq BombDone
 dec $2D70
 lda #0
 ldx #3
ClearHostile
 sta $2D10,x
 dex
 bpl ClearHostile
 jsr $0309
 bcc BombSound
 lda $FD04
 beq BombFormation
 lda $FD0A
 sec
 sbc #16
 bcs GuardianHealth
 lda #0
GuardianHealth
 sta $FD0A
 jmp BombSound
BombFormation
 jsr $2429
 beq BombOrdinary
 cmp #4
 bne BombSound
 lda #16
 sta $2D72
BombSkull
 ldx #0
 jsr $3B09
 dec $2D72
 bne BombSkull
 jmp BombSound
BombOrdinary
 ldy #7
BombEnemy
 lda $74E0,y
 cmp #$10
 bne BombNext
 lda #4
 sta $74E0,y
BombNext
 dey
 bpl BombEnemy
BombSound
 jmp $F38E
BombDone
 rts
Patterns
 ins 'hud-patterns.bin'
 ert * > $6684
