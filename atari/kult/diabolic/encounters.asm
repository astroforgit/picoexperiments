; Native encounter hooks. Uses the existing eight enemy blitters.
 opt h-
 org $3B00
 jmp LoadEncounter
 jmp MoveEncounter
 jmp EncounterFrame
 jmp HitEncounter
 jmp BombEncounter
 jmp BossMeter
 jmp ShieldTick
 jmp ShieldDraw
 jmp ShieldBlink
 jmp DrawRingFrame
 jmp EraseRingFrame
 jmp ClipEnemyDraw
 jmp ClipEnemyRestore
MeteorY = $2D40
MeteorWait = $2D48
ShieldTime = $2D61
ShieldHeld = $2D60
RingMask = $2D62
Mode = $2D20
Age = $2D21
Health = $2D22
HeadX = $2D23
HeadY = $2D24
SavedDesign = $2D25
MaxHealth = $2D2A
MeterHealth = $2D2B
MeterMax = $2D2C
Remainder = $2D2D
Filled = $2D2E
MeterVisible = $2D2F
Finished = $2D29
Tile = $2D26
SourceLo = $2D27
SourceHi = $2D28
LoadEncounter
 sta SavedDesign
 lda Mode
 cmp #4
 bne ReadKind
 ldx #0
RestoreExplosions
 lda $3000,x
 sta $7D00,x
 lda $3100,x
 sta $7E00,x
 lda $3200,x
 sta $7F00,x
 inx
 bne RestoreExplosions
ReadKind
 lda $FB8A
 asl
 asl
 tay
 iny
 lda ($80),y
 lsr
 lsr
 lsr
 lsr
 lsr
 sta Mode
 lda #0
 sta Age
 sta Finished
 lda #128
 sta HeadX
 lda $FC09
 asl
 asl
 asl
 sta Health
 sta MaxHealth
 lda Mode
 bne SpecialLoad
 lda SavedDesign
 jmp $F16B
SpecialLoad
 cmp #4
 beq HeadLoad
 lda #14
 jsr $F16B
 lda #$2F
 sta SourceHi
 lda #4
 bne TileCount
HeadLoad
 ldx #0
SaveExplosions
 lda $7D00,x
 sta $3000,x
 lda $7E00,x
 sta $3100,x
 lda $7F00,x
 sta $3200,x
 inx
 bne SaveExplosions
 lda #19
 jsr $F16B
 lda #$2E
 sta SourceHi
 lda #8
TileCount
 sta TileLimit
 lda #0
 sta SourceLo
 sta Tile
LoadTile
 lda Tile
 ldx SourceLo
 ldy SourceHi
 jsr $F0C4
 clc
 lda SourceLo
 adc #32
 sta SourceLo
 bcc SourceReady
 inc SourceHi
SourceReady
 inc Tile
 lda Tile
 cmp TileLimit
 bcc LoadTile
 ldx #7
 lda #0
NoDrops
 sta $7482,x
 lda #128
 sta MeteorY,x
 sta $7462,x
 txa
 asl
 asl
 asl
 asl
 beq FirstMeteorDelay
 clc
 adc #24
FirstMeteorDelay
 sta MeteorWait,x
 lda #0
 sta $746A,x
 dex
 bpl NoDrops
 rts
TileLimit dta 0
MoveEncounter
 lda Mode
 bne SpecialMove
 jmp $E7A4
SpecialMove
 ; Original player-death effect reuses the sprite buffers, then clears actors.
 ; Let the wave loader rebuild them instead of resurrecting stale graphics.
 ldx #7
 lda #0
CheckActors
 ora $74E0,x
 dex
 bpl CheckActors
 cmp #0
 bne ActorsRemain
 rts
ActorsRemain
 lda Finished
 beq Moving
 rts
Moving
 lda #0
 sta $7444
 lda Mode
 cmp #4
 bne MoveMeteors
 jmp MoveHead
MoveMeteors
 lda Age
 cmp #192
 bcs MeteorDrain
 inc Age
MeteorDrain
 ldx #7
MeteorLoop
 lda MeteorY,x
 cmp #128
 bcs MeteorWaiting
 clc
 adc MeteorSpeed,x
 cmp #128
 bcc PlaceMeteor
 lda #128
 sta MeteorY,x
 lda #32
 sta MeteorWait,x
 jmp HideMeteor
MeteorWaiting
 lda Age
 cmp #192
 bcs HideMeteor
 lda MeteorWait,x
 beq SpawnMeteor
 dec MeteorWait,x
 ; Reserve an invisible off-right actor while this lane waits to spawn.
 lda #128
 sec
 sbc $7446
 sta $7462,x
 lda #$10
 sta $74E0,x
 jmp NextMeteor
SpawnMeteor
 lda #0
PlaceMeteor
 sta MeteorY,x
 sta $746A,x
 lda Columns,x
 sec
 sbc $7446
 sta $7462,x
 lda #$10
 sta $74E0,x
 jmp NextMeteor
HideMeteor
 lda $74E0,x
 beq NextMeteor
 lda #$80
 sta $74E0,x
NextMeteor
 dex
 bpl MeteorLoop
 rts

FinishEncounter
 lda #1
 sta Finished
 ldx #7
 lda #$80
FinishLoop
 sta $74E0,x
 dex
 bpl FinishLoop
 rts
MoveHead
 lda Health
 beq FinishEncounter
 inc Age
 lda HeadX
 cmp #88
 bcc HeadEntered
 beq HeadEntered
 dec HeadX
 dec HeadX
HeadEntered
 lda Age
 and #63
 cmp #32
 bcc HeadBob
 eor #63
HeadBob
 lsr
 clc
 adc #40
 sta HeadY
 ldx #7
HeadTiles
 txa
 and #3
 asl
 asl
 asl
 clc
 adc HeadX
 sec
 sbc $7446
 sta $7462,x
 txa
 and #4
 asl
 asl
 clc
 adc HeadY
 sta $746A,x
 lda #$10
 sta $74E0,x
 dex
 bpl HeadTiles
 rts
EncounterFrame
 lda $FD04
 bne OrdinaryFrame
 lda Mode
 cmp #4
 bne OrdinaryFrame
 tya
 rts
OrdinaryFrame
 lda $743C,x
 rts
HitEncounter
 lda Mode
 beq OrdinaryHit
 cmp #4
 bne IgnoreHit
 lda Health
 beq IgnoreHit
 dec Health
 bne IgnoreHit
 txa
 pha
 jsr DefeatBoss
 pla
 tax
IgnoreHit
 lda #1
 rts
OrdinaryHit
 dec $7586,x
 rts
BombEncounter
 rts

DefeatBoss
 jsr FinishEncounter
 ; Three guaranteed, separated rewards: two weapon upgrades and a bomb.
 ldx #2
BossRewards
 lda #0
 sta $74E0,x
 lda RewardKinds,x
 sta $7482,x
 lda RewardX,x
 sta $7472,x
 lda RewardY,x
 sta $747A,x
 dex
 bpl BossRewards
 rts
RewardKinds dta $11,$12,$14
RewardX dta 80,96,112
RewardY dta 32,60,88
; The former fuel area displays boss HP only, never fuel.
BossMeter
 lda #0
 sta MeterVisible
 sta Filled
 lda $FD04
 beq SkullMeter
 lda #100
 sta MeterMax
 lda $FD0A
 jmp HaveHealth
SkullMeter
 lda Mode
 cmp #4
 bne DrawMeter
 lda MaxHealth
 beq DrawMeter
 sta MeterMax
 lda Health
HaveHealth
 sta MeterHealth
 inc MeterVisible
 lda #0
 sta Remainder
 ldx #14
ScaleHealth
 lda Remainder
 clc
 adc MeterHealth
 cmp MeterMax
 bcc KeepRemainder
 sbc MeterMax
 inc Filled
KeepRemainder
 sta Remainder
 dex
 bne ScaleHealth
 lda MeterHealth
 beq DrawMeter
 lda Filled
 bne DrawMeter
 inc Filled
DrawMeter
 lda #$79
 sta $80
 lda #$67
 sta $81
 ldx #15
MeterRow
 ldy #0
 lda #0
 sta ($80),y
 iny
 sta ($80),y
 iny
 lda ($80),y
 and #7
 sta ($80),y
 lda MeterVisible
 beq NextMeterRow
 cpx #15
 beq MeterBorder
 cpx #0
 beq MeterBorder
 ldy #0
 lda #2
 sta ($80),y
 ldy #2
 lda ($80),y
 ora #8
 sta ($80),y
 cpx Filled
 bcc MeterFill
 beq MeterFill
 bne NextMeterRow
MeterBorder
 ldy #0
 lda #3
 sta ($80),y
 ldy #2
 lda ($80),y
 ora #$F8
 sta ($80),y
MeterFill
 ldy #1
 lda #$FF
 sta ($80),y
NextMeterRow
 clc
 lda $80
 adc #32
 sta $80
 bcc MeterPointer
 inc $81
MeterPointer
 dex
 bpl MeterRow
 rts
ShieldBlink
 lda ShieldTime
 beq NormalBlink
 lda #0
 rts
NormalBlink
 lda $F0BF
 rts
ShieldTick
 lda ShieldTime
 beq ReadShieldKey
 dec ShieldTime
ReadShieldKey
 lda $D20F
 and #4
 bne ReleaseShield
 lda $D209
 and #$3F
 cmp #$21
 bne ReleaseShield
 lda ShieldHeld
 bne ProtectShip
 inc ShieldHeld
 lda ShieldTime
 bne ProtectShip
 lda $F398
 bne ProtectShip
 lda $4E77
 beq ProtectShip
 dec $4E77
 lda #17
 sta ShieldTime
 bne ProtectShip
ReleaseShield
 lda #0
 sta ShieldHeld
ProtectShip
 lda ShieldTime
 beq ShieldTickDone
 ; Keep collision immunity alive without shortening spawn immunity.
 lda $F0BF
 cmp #2
 bcs ShieldTickDone
 lda #2
 sta $F0BF
ShieldTickDone
 jmp $F51A
ShieldDraw
 rts
; A one-hires-pixel ellipse, saved independently for each framebuffer.
; Draw after sprites, erase before their old backgrounds are restored.
DrawRingFrame
 jsr $EC05
 lda ShieldTime
 bne RingActive
 rts
RingActive
 lda $7439
 beq FirstRingBuffer
 lda #128
FirstRingBuffer
 sta $2D65
 lda #0
 sta $2D66
 lda $E957
 clc
 adc $7446
 asl
 sta $2D69
 lda $E958
 sta $2D6A
RingPoint
 ldx $2D66
 lda $2D69
 clc
 adc $2B00,x
 sec
 sbc #2
 bcc SkipPoint
 sta $2D67
 lda $2D6A
 clc
 adc $2B80,x
 sec
 sbc #2
 bcc SkipPoint
 cmp #128
 bcs SkipPoint
 tay
 lda $2D67
 lsr
 tax
 jsr $EF43
 lda $2D67
 and #7
 tax
 lda RingBits,x
 sta $2D62
 ldx $2D65
 lda $F8
 sta $2500,x
 lda $F9
 sta $2600,x
 ldy #0
 lda ($F8),y
 eor #$FF
 and $2D62
 sta $2700,x
 lda ($F8),y
 ora $2D62
 sta ($F8),y
 inc $2D65
SkipPoint
 inc $2D66
 lda $2D66
 cmp $2D68
 bcc RingPoint
 ldx $7439
 lda $2D65
 and #127
 sta $2D63,x
RingDone
 rts
EraseRingFrame
 ldy $7439
 lda $2D63,y
 sta $2D66
 lda #0
 sta $2D63,y
 lda $2D66
 beq RingErased
 tya
 beq FirstEraseBuffer
 lda #128
FirstEraseBuffer
 tax
ErasePoint
 lda $2500,x
 sta $F8
 lda $2600,x
 sta $F9
 lda $2700,x
 eor #$FF
 sta $2D62
 ldy #0
 lda ($F8),y
 and $2D62
 sta ($F8),y
 inx
 dec $2D66
 bne ErasePoint
RingErased
 jmp $ECA7
RingBits dta $80,$40,$20,$10,8,4,2,1

; Limit native 16-row blits to the current 128-row framebuffer.
; Both drawing and restoring must stop before the next memory bank.
ClipEnemyDraw
 lda $F8
 ldx $F9
 jsr ClipRows
 rts
ClipEnemyRestore
 lda $FC
 ldx $FD
 jsr ClipRows
 tax
 rts
ClipRows
 lsr
 lsr
 lsr
 lsr
 lsr
 lsr
 sta $2D6B
 txa
 and #31
 asl
 asl
 ora $2D6B
 sta $2D6B
 lda #128
 sec
 sbc $2D6B
 cmp $EDBE
 bcc ClippedRows
 lda $EDBE
ClippedRows
 rts

MeteorSpeed dta 2,4,6,3,5,4,7,5
Columns dta 20,68,105,40,88,12,58,115
 ert * > $4000
