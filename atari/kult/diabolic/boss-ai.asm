; Shared boss actions. Timings are game updates, not display frames.
 opt h-
 org $DAC0
 jmp Dispatch
Phase=$2DC0
Timer=$2DC1
Rng=$2DC2
NextHazard=$2DC3
Art=$2DC4
Cooldown=$2DC5
BombStock=$2DC6
Direction=$2DC7
Frame=$2DC8
Dispatch
 jsr Tick
 lda $2D20
 cmp #4
 bne DispatchDone
 lda $2D22
 beq DispatchDone
 lda $F398
 bne DispatchDone
 jsr $0312
DispatchDone
 rts
Tick
 lda $FD04
 bne MainHealth
 lda $2D20
 cmp #4
 beq SubHealth
 rts
MainHealth
 lda $FD0A
 jmp Alive
SubHealth
 lda $2D22
Alive
 bne Live
 jsr $0303
 rts
Live
 lda $F398
 beq PilotAlive
 lda #0
 sta Phase
 jsr $0303
 rts
PilotAlive
 lda Phase
 bne Running
 lda #8
 sta Phase
 lda #128
 sta $2D23
 lda #48
 sta $2D24
 lda #0
 sta Timer
 sta Cooldown
 sta Frame
 lda $D20A
 eor #$5D
 bne SeedReady
 lda #$5D
SeedReady
 sta Rng
 lda #1
 sta Art
 lda $2D70
 sta BombStock
 jsr $0303
Running
 lda $2D70
 cmp BombStock
 beq BombReady
 sta BombStock
 lda Art
 cmp #2
 beq BombReady
 jsr $0303
BombReady
 lda Phase
 cmp #1
 beq Shooting
 cmp #2
 beq Shooting
 cmp #3
 beq Retreat
 cmp #4
 bne NotCurtains
 jmp Curtains
NotCurtains
 cmp #5
 bne NotMeteors
 jmp Meteors
NotMeteors
 cmp #7
 bne NotDrain
 jmp Drain
NotDrain
 jmp Arrive
Shooting
 ; Original guardian animation and muzzle-height sequence, one step/update.
 lda Timer
 and #15
 tay
 lda $FCDA,y
 sta Frame
 lda $FCCA,y
 clc
 adc #16
 sta $2D24
 jsr NewOrb
 ; Original guardian moves a newly spawned projectile immediately.
 jsr Orbs

ShotDone
 inc Timer
 lda Timer
 cmp #96
 bcc Done
 lda $FD04
 bne LeaveScreen
 lda NextHazard
 beq LeaveScreen
 ; A sub-boss gets one retreat per encounter, even after pilot respawn.
 jmp Entered
LeaveScreen
 lda #3
 sta Phase
 jsr $0300
 and #1
 clc
 adc #4
 sta NextHazard
Done
 rts
Retreat
 jsr Orbs
 lda $2D23
 cmp #128
 bcs Offscreen
 clc
 adc #2
 sta $2D23
 rts
Offscreen
 jsr $0306
 bne Done
 lda NextHazard
 sta Phase
 lda #0
 sta Timer
 sta Cooldown
 lda #9
 sta $2D7C
 lda $2D70
 sta $1BBF
 lda #29
 sta $2D76
 lda Phase
 cmp #5
 beq StartMeteors
 lda #0
 sta Art
 lda #88
 sta $2D23
 lda #48
 sta $2D24
 rts
StartMeteors
 lda #2
 sta Art
 jsr $0300
 and #3
 tay
 lda Directions,y
 sta Direction
 ldx #7
SetWait
 txa
 asl
 asl
 asl
 asl
 beq WaitReady
 clc
 adc #24
WaitReady
 sta $2DE0,x
 dex
 bpl SetWait
 rts
Curtains
 ; Advance hazards every second game update; the pilot always moves normally.
 lda Cooldown
 eor #1
 sta Cooldown
 beq CurtainDone
 lda $2D7C
 beq CurtainActive
 jsr $6550
 rts
CurtainActive
 lda $2D00
 bne FireCurtain
 lda #255
 sta $2D79
 jsr $1806
 jmp CurtainTime
FireCurtain
 jsr $6550
CurtainTime
 inc Timer
 lda Timer
 cmp #120
 bcs StartDrain
CurtainDone
 ; Stationary bullets still collide on updates between movement steps.
 ldx #7
CurtainHits
 lda $1BE0,x
 beq NextCurtainHit
 jsr $1809
NextCurtainHit
 dex
 bpl CurtainHits
 rts
StartDrain
 lda #7
 sta Phase
 rts

Meteors
 jsr Rocks
 inc Timer
 lda Timer
 cmp #192
 bcs StartDrain
 rts
Drain
 lda Art
 cmp #2
 beq DrainRocks
 lda Cooldown
 eor #1
 sta Cooldown
 beq CurtainDone
 lda #255
 sta $2D79
 jsr $1806
 jmp CheckDrain
DrainRocks
 jsr Rocks
CheckDrain
 jsr $0306
 beq ReturnNow
 rts
ReturnNow
 lda #6
 sta Phase
 lda #128
 sta $2D23
Arrive
 lda $2D23
 sec
 sbc #2
 sta $2D23
 cmp #88
 beq Entered
 rts
Entered
 lda #0
 sta Timer
 sta Cooldown
 lda #1
 sta Art
 jsr $0300
 and #1
 clc
 adc #1
 sta Phase
 rts
NewOrb
 lda $2D00
 beq NoOrb
 lda #6
 sta $2DC9
 lda Phase
 cmp #2
 bne OrbLimitReady
 lda #3
 sta $2DC9
OrbLimitReady
 ldx #0
FindOrb
 lda $1BE0,x
 beq TryOrb
 inx
 cpx $2DC9
 bcc FindOrb
NoOrb
 rts
TryOrb
 jsr $0300
 ldy Phase
 cpy #2
 beq SparseChance
 and #3
 bne NoOrb
 beq Born
SparseChance
 and #7
 bne NoOrb
Born
 lda #1
 sta $1BE0,x
 lda $2D23
 sta $1BD0,x
 lda Timer
 and #15
 tay
 lda $FCEA,y
 sta $1BD8,x
 sta $1BF0,x
 lda Phase
 sta $1BC0,x
 lda #0
 sta $1BE8,x
 rts

Orbs
 ldx #7
OrbLoop
 lda $1BE0,x
 beq NextOrb
 ldy $1BC0,x
 lda $1BD0,x
 sec
 sbc #4
 bcc EndOrb
 sta $1BD0,x
 inc $1BE8,x
 cpy #2
 bne OrbHit
 lda $1BE8,x
 asl
 asl
 asl
 tay
 lda $7164,y
 lsr
 clc
 adc $1BF0,x
 sec
 sbc #14
 bcc OrbZeroY
 cmp #113
 bcc OrbY
 lda #112
 bne OrbY
OrbZeroY
 lda #0
OrbY
 sta $1BD8,x
OrbHit
 jsr $1809
 jmp NextOrb
EndOrb
 lda #0
 sta $1BE0,x
NextOrb
 dex
 bpl OrbLoop
 rts
Rocks
 ldx #7
RockLoop
 lda $1BE0,x
 beq RockWait
 lda $1BE8,x
 clc
 adc Speeds,x
 cmp #128
 bcc RockPlace
 lda #0
 sta $1BE0,x
 lda #32
 sta $2DE0,x
 bne NextRock
RockWait
 lda $2D00
 beq NextRock
 lda Phase
 cmp #5
 bne NextRock
 lda $2DE0,x
 beq RockBorn
 dec $2DE0,x
 jmp NextRock
RockBorn
 lda #1
 sta $1BE0,x
 lda #0
RockPlace
 sta $1BE8,x
 sta $1BD8,x
 lda Direction
 cmp #3
 beq RockRight
 cmp #2
 beq RockUp
 cmp #6
 bne RockColumn
 txa
 and #1
 beq RockColumn
RockUp
 lda #127
 sec
 sbc $1BE8,x
 sta $1BD8,x
RockColumn
 lda Columns,x
 jmp RockX
RockRight
 lda Rows,x
 sta $1BD8,x
 lda #127
 sec
 sbc $1BE8,x
RockX
 sta $1BD0,x
 jsr $1809
NextRock
 dex
 bpl RockLoop
 rts
Directions dta 1,2,3,6
Speeds dta 2,4,6,3,5,4,7,5
Columns dta 8,68,108,38,88,18,58,118
Rows dta 0,64,112,32,96,16,80,48
 ; The original guardian bypasses terrain drawing, but the sub-boss used to
 ; scroll/copy the retired building buffers throughout the fight. Hold that
 ; scroll state for either boss; PM parallax stars keep moving independently.
 ert * > $DE80
 :($DE80-*) dta 0
BossScroll
 ; Respawn waits for scroll phase 2 at $FB18. Never freeze that clock
 ; while the pilot is dying, even when the boss itself is still alive.
 lda $F398
 bne ScrollTerrain
 lda $FD04
 bne HoldTerrain
 lda $2D20
 cmp #4
 bne ScrollTerrain
 lda $2D22
 bne HoldTerrain
ScrollTerrain
 dec $758E
 jmp $EAB0
HoldTerrain
 jmp $EAD8
 ert * > $DEA0
 :($DEA0-*) dta 0
BossTerrain
 lda $2D20
 cmp #4
 bne DrawTerrain
 lda $2D22
 beq DrawTerrain
 rts
DrawTerrain
 jmp $E7F9
 ert * > $DF00
