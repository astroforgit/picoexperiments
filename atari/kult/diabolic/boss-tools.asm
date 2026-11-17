; Shared boss helpers in retired terrain decoder storage.
 opt h-
 org $0300
 JMP Random
 JMP Clear
 JMP Count
 JMP DamageAllowed
 JMP MainHit
 JMP WaveGate
 JMP HideCore
 JMP SpriteSource
 JMP EraseWidth
Random
 LDA $2dc2
 LSR
 BCC L0323
 EOR #$b8
L0323
 STA $2dc2
 RTS
Clear
 LDA #$00
 LDX #$07
L032B
 STA $1be0,X
 DEX
 BPL L032B
 RTS
Count
 LDA #$00
 LDX #$07
L0336
 ORA $1be0,X
 DEX
 BPL L0336
 CMP #$00
 RTS
DamageAllowed
 LDA $fd04
 BNE L034B
 LDA $2d20
 CMP #$04
 BNE L0352
L034B
 LDA $2dc0
 CMP #$03
 BCS L0354
L0352
 SEC
 RTS
L0354
 CLC
 RTS
MainHit
 LDA $fd04
 BEQ L0395
 JSR DamageAllowed
 BCC L0395
 LDX #$05
L0362
 LDA $74e8,X
 BEQ L0392
 BMI L0392
 LDA $74ee,X
 SEC
 SBC $2d23
 CLC
 ADC #$08
 CMP #$28
 BCS L0392
 LDA $74f4,X
 CLC
 ADC #$08
 SEC
 SBC $2d24
 CMP #$20
 BCS L0392
 LDA #$80
 STA $74e8,X
 LDA $fd0a
 BEQ L0392
 DEC $fd0a
L0392
 DEX
 BPL L0362
L0395
 RTS
WaveGate
 LDA $fd04
 BNE L03AE
 LDA $2d20
 CMP #$04
 BNE L03B1
 LDA $2d22
 BEQ L03B1
 LDA $2dc0
 BEQ L03B1
 CLC
 RTS
L03AE
 JMP $fc48
L03B1
 LDX #$07
 LDA #$00
 JMP $fb90
HideCore
 LDA $fd04
 BNE L0404
 LDA $2dc0
 CMP #$03
 BCS L03D3
 LDA $2d24
 STA $2dca
 LDA $2d23
 STA $2dcb
 JMP L03DD
L03D3
 LDA #$80
 STA $2dcb
 LDA #$30
 STA $2dca
L03DD
 LDX #$07
L03DF
 TXA
 AND #$03
 ASL
 ASL
 ASL
 CLC
 ADC $2dcb
 SEC
 SBC $7446
 STA $7462,X
 TXA
 AND #$04
 ASL
 ASL
 CLC
 ADC $2dca
 STA $746a,X
 LDA #$10
 STA $74e0,X
 DEX
 BPL L03DF
L0404
 RTS
SpriteSource
 LDA $1bb3
 AND #$03
 TAX
 LDA $2dc4
 BEQ L0429
 CMP #$01
 BEQ L041E
 LDA RockLow,X
 STA $fa
 LDA #$07
 STA $fb
 RTS
L041E
 LDA OrbLow,X
 STA $fa
 LDA OrbHigh,X
 STA $fb
 RTS
L0429
 LDA $43ff
 AND #$04
 ORA #$08
 STA $1bb4
 TXA
 ORA $1bb4
 TAX
 LDA $2da0,X
 STA $fa
 LDA $2db0,X
 STA $fb
 RTS
OrbLow dta $80,$B0,$E0,$10
OrbHigh dta 6,6,6,7
RockLow dta $40,$70,$A0,$D0
EraseWidth
 lda $2DCE,y
 sta $FD08
 rts
 ert * > $0480
