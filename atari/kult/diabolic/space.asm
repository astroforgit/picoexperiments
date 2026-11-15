; Right-to-left grayscale parallax inspired by the supplied canvas example.
    opt h-
    org $4000
    jmp Init
    jmp Step
    jmp Menu
    jmp Tile
    jmp Raster
Init
    jsr $E9D6
    lda #$8F
    sta $601B
    sta $61DD
    lda #$30
    sta $D407
    lda #3
    sta $D01D
    lda #$10
    sta $D01B
    lda #0
    sta Clock
    sta $D008
    sta $D009
    sta $D00A
    sta $D00B
    lda #$55
    sta $D00C                 ; double-width missiles: bright 8x4 laser bolts
    lda #0
    sta $02C8
    lda #$0C
    sta $02C7
    lda #0
    ldx #2
ClearPhase
    sta Phase,x
    dex
    bpl ClearPhase
    lda #$0A
    sta $02C4
    ldx #3
Positions
    lda StarX,x
    sta $D000,x
    dex
    bpl Positions
    jsr InitShots
    jsr Twinkle
    rts
Step
    inc Clock
    ldx #2
Layers
    lda Phase,x
    clc
    adc Velocity,x
    sta Phase,x
Rows
    lda Phase,x
    cmp #4
    bcc NextLayer
    sec
    sbc #4
    sta Phase,x
    lda PositionPage,x
    sta ReadPosition+2
    sta WritePosition+2
    sec
    sbc #4
    sta WriteGlyph+2
    sec
    sbc #12
    sta ReadGlyph+2
    ldy #40
MoveRow
ReadPosition
    lda $3800,y
    beq SkipRow
    sec
    sbc #1
    cmp #58
    bcs StoreRow
    lda #194
StoreRow
WritePosition
    sta $3800,y
    sta ClipMask+1
ReadGlyph
    lda $2800,y
ClipMask
    and $2C00
WriteGlyph
    sta $3400,y
SkipRow
    iny
    cpy #168
    bne MoveRow
    jmp Rows
NextLayer
    dex
    bpl Layers
    jsr Twinkle
    jsr Shots
    jmp $F908
Twinkle
    lda Clock
    lsr
    lsr
    and #15
    tay
    lda NearRamp,y
    sta $02C0
    tya
    clc
    adc #5
    and #15
    tay
    lda MidRamp,y
    sta $02C1
    tya
    clc
    adc #6
    and #15
    tay
    lda FarRamp,y
    sta $02C2
    sta $02C3
    rts
Menu
    lda #0
    sta $D01D
    ldx #7
Hide
    sta $D000,x
    dex
    bpl Hide
    lda $C3F1
    rts
Tile
    ; The old terrain scroll stays intact for enemies, but draws black tiles.
    lda #0
    jmp $E905
Raster
    pha
    lda $D40B
    cmp #80
    bcc StarRaster
    pla
    jmp $EA73
StarRaster
    txa
    pha
    tya
    pha
    ldy #40
Scanline
    ; Prefetch before WSYNC. All three HPOS writes then finish in the left
    ; blanking interval, before even a star at the left edge is drawn.
    lda $3802,y
    sta Position0
    lda $3902,y
    tax
    lda $3A02,y
    sta $D40A
    sta $D002
    stx $D001
    lda Position0
    sta $D000
    iny
    cpy #168
    bne Scanline
    pla
    tay
    pla
    tax
    pla
    rti
InitShots
    lda #0
    sta FireClock
    sta EnemyIndex
    ldx #3
ClearShots
    sta Active,x
    sta $D004,x
    dex
    bpl ClearShots
    rts
Shots
    ; Four independent hardware missiles; no star renderer or blitter buffers.
    lda #0
    ldy #127
ClearMissilePage
    sta $3328,y
    dey
    bpl ClearMissilePage
    lda FireMode
    bne FireEnabled
    jmp InitShots
FireEnabled
    lda $FD04
    bne MoveShots
    inc FireClock
    lda FireClock
    cmp FireInterval
    bcc MoveShots
    lda #0
    sta FireClock
    ldx #3
FindFree
    lda Active,x
    beq ChooseEnemy
    dex
    bpl FindFree
    jmp MoveShots
ChooseEnemy
    inc EnemyIndex
    lda EnemyIndex
    and #7
    sta EnemyIndex
    tay
    lda $74E0,y
    beq MoveShots
    bmi MoveShots
    and #7
    bne MoveShots
    lda $7462,y
    clc
    adc $7446
    adc $7444
    cmp #120
    bcs MoveShots
    cmp #24
    bcc MoveShots
    sta BulletX,x
    lda $746A,y
    clc
    adc #8
    cmp #124
    bcs MoveShots
    sta BulletY,x
    lda #0
    sta BulletDY,x
    lda FireMode
    cmp #2
    bne ActivateShot
    lda $E958
    clc
    adc #8
    cmp BulletY,x
    beq ActivateShot
    lda #1
    bcs AimDown
    lda #$FF
AimDown
    sta BulletDY,x
ActivateShot
    lda #1
    sta Active,x
MoveShots
    ldx #3
MoveOne
    lda #0
    sta $D004,x
    lda Active,x
    beq NextShot
    lda BulletX,x
    sec
    sbc FireSpeed
    bcc RemoveShot
    sta BulletX,x
    lda BulletY,x
    clc
    adc BulletDY,x
    cmp #125
    bcs RemoveShot
    sta BulletY,x
    ; Narrow collision box around the visible player, respecting invulnerability.
    sec
    sbc $E958
    cmp #16
    bcs DrawShot
    lda BulletX,x
    sec
    sbc $E957
    cmp #20
    bcs DrawShot
    lda $F0BF
    bne RemoveShot
    lda $F398
    bne RemoveShot
    lda #3
    sta $F398
RemoveShot
    lda #0
    sta Active,x
    beq NextShot
DrawShot
    lda BulletX,x
    clc
    adc #64
    sta $D004,x
    lda BulletY,x
    clc
    adc #40
    tay
    lda $3300,y
    ora ShotBits,x
    sta $3300,y
    iny
    lda $3300,y
    ora ShotBits,x
    sta $3300,y
    iny
    lda $3300,y
    ora ShotBits,x
    sta $3300,y
    iny
    lda $3300,y
    ora ShotBits,x
    sta $3300,y
NextShot
    dex
    bmi ShotsDone
    jmp MoveOne
ShotsDone
    rts
ShotBits dta 3,12,48,192
FireMode = $2D00
FireInterval = $2D01
FireSpeed = $2D02
FireClock = $2D03
EnemyIndex = $2D04
Active = $2D10
BulletX = $2D14
BulletY = $2D18
BulletDY = $2D1C
Position0 = $90
Clock = $43FF
Phase dta 0,0,0
PositionPage dta $38,$39,$3A
Velocity dta 7,3,1
StarX dta 0,0,0,0
NearRamp dta 10,10,10,12,12,12,14,14,14,12,12,12,10,10,10,10
MidRamp dta 6,6,6,6,6,8,8,8,8,8,6,6,6,6,6,6
FarRamp dta 2,2,2,2,2,4,4,4,4,4,4,2,2,2,2,2
    ert * > $43FF
