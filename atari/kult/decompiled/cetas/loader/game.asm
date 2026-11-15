; CETAS resident disk loader and setup
; Automatically traced 6502 source; unidentified bytes remain DTA.
; Packed/relocated runtime code is NOT recovered by this static pass.
; Labels identify file segments and CPU addresses, not inferred game roles.
; Original segment headers and all bytes are retained for exact rebuilding.
    opt h-
    org $0000

; marker at file offset $000000
    org $0000
    dta $FF,$FF

; Segment 1: $1400-$15EF; file offset $000002
    org $0000
    dta a($1400),a($15EF)
    org $1400
    dta $58,$41,$55,$54,$4F,$52,$55,$4E,$20,$20,$20,$08,$07,$E2,$02,$E0 ; $1400 unidentified data/code
    dta $02,$03,$FF,$40,$C0,$99,$00,$14,$C8,$D0,$FA,$E6,$C2,$CA,$10,$F5 ; $1410 unidentified data/code
    dta $4C,$30,$10,$3F,$40,$FF,$07,$01,$00,$01,$00,$53,$40,$FC,$07,$07 ; $1420 unidentified data/code
    dta $00,$04,$00,$51,$4D,$45,$47 ; $1430 unidentified data/code
S001_1437: ldy #$07                 ; A0 07
S001_1439: lda $142B,y              ; B9 2B 14
S001_143C: sta $0302,y              ; 99 02 03
S001_143F: dey                      ; 88
S001_1440: bpl *-7                  ; 10 F7
S001_1442: jsr $E459                ; 20 59 E4
S001_1445: cpy #$01                 ; C0 01
S001_1447: rts                      ; 60
    dta $9B,$EF,$CD,$E0,$10,$13,$00,$15 ; $1448 unidentified data/code
S001_1450: ldy #$01                 ; A0 01
S001_1452: sty $09                  ; 84 09
S001_1454: ldy #$0D                 ; A0 0D
S001_1456: lda $1415,y              ; B9 15 14
S001_1459: sta.w $00C0,y            ; 99 C0 00
S001_145C: dey                      ; 88
S001_145D: bpl *-7                  ; 10 F7
S001_145F: lda $1411                ; AD 11 14
S001_1462: bmi *+44                 ; 30 2A
S001_1464: ldx $0301                ; AE 01 03
S001_1467: cpx #$01                 ; E0 01
S001_1469: bne *+22                 ; D0 14
S001_146B: ldy #$03                 ; A0 03
S001_146D: lda $C001,y              ; B9 01 C0
S001_1470: cmp $1433,y              ; D9 33 14
S001_1473: bne *+12                 ; D0 0A
S001_1475: dey                      ; 88
S001_1476: bpl *-9                  ; 10 F5
S001_1478: lda $03EF                ; AD EF 03
S001_147B: and #$07                 ; 29 07
S001_147D: sec                      ; 38
    dta $2C,$18,$8A ; $147E unidentified data/code
S001_1481: adc $0300                ; 6D 00 03
S001_1484: adc #$FF                 ; 69 FF
S001_1486: sta $13FC                ; 8D FC 13
S001_1489: lda #$01                 ; A9 01
S001_148B: sta $0301                ; 8D 01 03
S001_148E: lda #$2B                 ; A9 2B
S001_1490: sta $143A                ; 8D 3A 14
S001_1493: jsr $1437                ; 20 37 14
S001_1496: bne *+11                 ; D0 09
S001_1498: lda $07FC                ; AD FC 07
S001_149B: and #$20                 ; 29 20
S001_149D: beq *+4                  ; F0 02
S001_149F: asl                      ; 0A
S001_14A0: asl                      ; 0A
S001_14A1: eor #$80                 ; 49 80
S001_14A3: jsr $12CC                ; 20 CC 12
S001_14A6: lda $13F0                ; AD F0 13
S001_14A9: sta $0305                ; 8D 05 03
S001_14AC: lda $13FC                ; AD FC 13
S001_14AF: sta $0300                ; 8D 00 03
S001_14B2: ldx #$00                 ; A2 00
S001_14B4: lda $13F1                ; AD F1 13
S001_14B7: bne *+3                  ; D0 01
S001_14B9: inx                      ; E8
S001_14BA: sta $0304                ; 8D 04 03
S001_14BD: stx $0309                ; 8E 09 03
S001_14C0: eor #$FF                 ; 49 FF
S001_14C2: clc                      ; 18
S001_14C3: adc #$01                 ; 69 01
S001_14C5: sta $0308                ; 8D 08 03
S001_14C8: lda $D01F                ; AD 1F D0
S001_14CB: and #$04                 ; 29 04
S001_14CD: beq *+16                 ; F0 0E
S001_14CF: ldy #$00                 ; A0 00
S001_14D1: sty $022F                ; 8C 2F 02
S001_14D4: ldy #$00                 ; A0 00
S001_14D6: ldx #$14                 ; A2 14
S001_14D8: jsr $1009                ; 20 09 10
S001_14DB: bcc *+5                  ; 90 03
S001_14DD: jmp $1600                ; 4C 00 16
S001_14E0: lda $13FF                ; AD FF 13
S001_14E3: sta $13EB                ; 8D EB 13
S001_14E6: lda $13FE                ; AD FE 13
S001_14E9: sta $13EA                ; 8D EA 13
S001_14EC: lda $13E5                ; AD E5 13
S001_14EF: sta $112E                ; 8D 2E 11
S001_14F2: lda #$08                 ; A9 08
S001_14F4: sta $13E5                ; 8D E5 13
S001_14F7: lda $116D                ; AD 6D 11
S001_14FA: sta $13ED                ; 8D ED 13
S001_14FD: lda $116B                ; AD 6B 11
S001_1500: sta $13EC                ; 8D EC 13
S001_1503: lda $1414                ; AD 14 14
S001_1506: sta $13E8                ; 8D E8 13
S001_1509: sta $D20E                ; 8D 0E D2
S001_150C: lda $1413                ; AD 13 14
S001_150F: sta $D40E                ; 8D 0E D4
S001_1512: lda $03F8                ; AD F8 03
S001_1515: sta $0244                ; 8D 44 02
S001_1518: lda $D301                ; AD 01 D3
S001_151B: eor $1412                ; 4D 12 14
S001_151E: and #$02                 ; 29 02
S001_1520: eor $1412                ; 4D 12 14
S001_1523: sta $D301                ; 8D 01 D3
S001_1526: ldx $140C                ; AE 0C 14
S001_1529: jsr $1039                ; 20 39 10
S001_152C: ldy #$00                 ; A0 00
S001_152E: sty $89                  ; 84 89
S001_1530: sty $87                  ; 84 87
S001_1532: lda #$10                 ; A9 10
S001_1534: sta $8A                  ; 85 8A
S001_1536: lda $140B                ; AD 0B 14
S001_1539: sta $88                  ; 85 88
S001_153B: sec                      ; 38
S001_153C: sbc $8A                  ; E5 8A
S001_153E: sta $86                  ; 85 86
S001_1540: lda #$04                 ; A9 04
S001_1542: sta $8C                  ; 85 8C
S001_1544: ldx $1410                ; AE 10 14
S001_1547: ldy $140F                ; AC 0F 14
S001_154A: jsr $1027                ; 20 27 10
S001_154D: ldx $140E                ; AE 0E 14
S001_1550: ldy $140D                ; AC 0D 14
S001_1553: jsr $1021                ; 20 21 10
S001_1556: ldy #$00                 ; A0 00
S001_1558: ldx #$04                 ; A2 04
S001_155A: lda $1448,x              ; BD 48 14
S001_155D: sta $8D                  ; 85 8D
S001_155F: lda $144C,x              ; BD 4C 14
S001_1562: sta $8E                  ; 85 8E
S001_1564: lda ($8D),y              ; B1 8D
S001_1566: jsr $15BB                ; 20 BB 15
S001_1569: sta ($8D),y              ; 91 8D
S001_156B: dex                      ; CA
S001_156C: bpl *-18                 ; 10 EC
S001_156E: lda ($89),y              ; B1 89
S001_1570: sta $8B                  ; 85 8B
S001_1572: ldx #$C0                 ; A2 C0
S001_1574: stx $85                  ; 86 85
S001_1576: cmp #$20                 ; C9 20
S001_1578: beq *+38                 ; F0 24
S001_157A: cmp #$40                 ; C9 40
S001_157C: beq *+57                 ; F0 37
S001_157E: cmp #$60                 ; C9 60
S001_1580: beq *+53                 ; F0 33
S001_1582: cmp #$2C                 ; C9 2C
S001_1584: beq *+49                 ; F0 2F
S001_1586: ldx #$80                 ; A2 80
S001_1588: stx $85                  ; 86 85
S001_158A: and #$1F                 ; 29 1F
S001_158C: cmp #$09                 ; C9 09
S001_158E: beq *+16                 ; F0 0E
S001_1590: asl $85                  ; 06 85
S001_1592: and #$0D                 ; 29 0D
S001_1594: cmp #$08                 ; C9 08
S001_1596: beq *+8                  ; F0 06
S001_1598: stx $85                  ; 86 85
S001_159A: bcc *+4                  ; 90 02
S001_159C: ror $85                  ; 66 85
S001_159E: lda $8B                  ; A5 8B
S001_15A0: jsr $15C6                ; 20 C6 15
S001_15A3: asl $85                  ; 06 85
S001_15A5: bcc *-55                 ; 90 C7
S001_15A7: lda ($89),y              ; B1 89
S001_15A9: jsr $15C6                ; 20 C6 15
S001_15AC: asl $85                  ; 06 85
S001_15AE: bcc *-64                 ; 90 BE
S001_15B0: lda ($89),y              ; B1 89
S001_15B2: jsr $15BB                ; 20 BB 15
S001_15B5: jsr $15C6                ; 20 C6 15
S001_15B8: jmp $156E                ; 4C 6E 15
S001_15BB: cmp #$10                 ; C9 10
S001_15BD: bcc *+8                  ; 90 06
S001_15BF: cmp #$14                 ; C9 14
S001_15C1: bcs *+4                  ; B0 02
S001_15C3: adc $86                  ; 65 86
S001_15C5: rts                      ; 60
S001_15C6: sta ($87),y              ; 91 87
S001_15C8: lda #$00                 ; A9 00
S001_15CA: sta ($89),y              ; 91 89
S001_15CC: iny                      ; C8
S001_15CD: bne *+13                 ; D0 0B
S001_15CF: inc $8A                  ; E6 8A
S001_15D1: inc $88                  ; E6 88
S001_15D3: dec $8C                  ; C6 8C
S001_15D5: bne *+5                  ; D0 03
S001_15D7: pla                      ; 68
S001_15D8: pla                      ; 68
    dta $24,$60 ; $15D9 unidentified data/code
S001_15DB: jsr $15EF                ; 20 EF 15
S001_15DE: jsr $103F                ; 20 3F 10
S001_15E1: lda #$22                 ; A9 22
S001_15E3: sta $022F                ; 8D 2F 02
S001_15E6: ldx #$0A                 ; A2 0A
S001_15E8: lda #$00                 ; A9 00
S001_15EA: tay                      ; A8
S001_15EB: clc                      ; 18
S001_15EC: jmp.w $00C0              ; 4C C0 00
S001_15EF: rts                      ; 60

; Segment 2: $1000-$13FF; file offset $0001F6
    org $0000
    dta a($1000),a($13FF)
    org $1000
    dta $78,$42,$43,$4C,$C6,$10,$4C,$51,$10 ; $1000 unidentified data/code
S002_1009: jmp $10CC                ; 4C CC 10
    dta $4C,$B1,$10,$4C,$05,$12 ; $100C unidentified data/code
S002_1012: jmp $1137                ; 4C 37 11
    dta $4C,$CA,$11,$4C,$DF,$11,$4C,$23,$12,$4C,$33,$12 ; $1015 unidentified data/code
S002_1021: jmp $1241                ; 4C 41 12
    dta $4C,$8F,$11 ; $1024 unidentified data/code
S002_1027: jmp $123A                ; 4C 3A 12
    dta $4C,$8A,$12 ; $102A unidentified data/code
S002_102D: jmp $10C9                ; 4C C9 10
    dta $4C,$5C,$10 ; $1030 unidentified data/code
S002_1033: jmp $111E                ; 4C 1E 11
    dta $4C,$8E,$12 ; $1036 unidentified data/code
S002_1039: jmp $1248                ; 4C 48 12
S002_103C: jmp $1141                ; 4C 41 11
S002_103F: jmp $12C0                ; 4C C0 12
    dta $4C,$7F,$11,$4C,$C3,$10,$4C,$CC,$12,$4C,$0A,$13,$6C,$E0,$02,$20 ; $1042 unidentified data/code
    dta $CC,$10,$90,$06,$60,$A2,$6C,$20,$9C,$10,$20,$CA,$11,$B0,$ED,$8D ; $1052 unidentified data/code
    dta $A4,$12,$20,$C4,$11,$8D,$A5,$12,$2D,$A4,$12,$C9,$FF,$F0,$EB,$20 ; $1062 unidentified data/code
    dta $C4,$11,$8D,$F3,$13,$20,$C4,$11,$AA,$0D,$F3,$13,$F0,$CB,$AD,$F3 ; $1072 unidentified data/code
    dta $13,$38,$ED,$A4,$12,$A8,$C8,$D0,$01,$E8,$8A,$ED,$A5,$12,$8D,$F4 ; $1082 unidentified data/code
    dta $13,$8C,$F3,$13,$A2,$99,$A0,$01,$A9,$10,$8E,$9F,$10,$99,$E2,$02 ; $1092 unidentified data/code
    dta $A9,$C2,$88,$10,$F8,$20,$C4,$11,$20,$A3,$12,$D0,$F8,$F0,$A6,$20 ; $10A2 unidentified data/code
    dta $7F,$12,$8E,$A5,$12,$8C,$A4,$12,$20,$C4,$11,$20,$A3,$12,$D0,$F8 ; $10B2 unidentified data/code
S002_10C2: rts                      ; 60
    dta $A9,$A8,$2C,$A9,$AA,$2C ; $10C3 unidentified data/code
S002_10C9: lda #$26                 ; A9 26
    dta $2C,$A9,$75 ; $10CB unidentified data/code
S002_10CE: sta $111C                ; 8D 1C 11
S002_10D1: stx $1297                ; 8E 97 12
S002_10D4: sty $1296                ; 8C 96 12
S002_10D7: jsr $1228                ; 20 28 12
S002_10DA: ldx #$24                 ; A2 24
S002_10DC: stx $10FB                ; 8E FB 10
S002_10DF: jsr $1164                ; 20 64 11
S002_10E2: jsr $117F                ; 20 7F 11
S002_10E5: bcs *-35                 ; B0 DB
S002_10E7: ldx #$85                 ; A2 85
S002_10E9: lda $06FB,x              ; BD FB 06
S002_10EC: bne *+8                  ; D0 06
S002_10EE: cpx #$80                 ; E0 80
S002_10F0: bcs *+98                 ; B0 60
S002_10F2: sec                      ; 38
S002_10F3: rts                      ; 60
S002_10F4: and #$56                 ; 29 56
S002_10F6: beq *+85                 ; F0 53
S002_10F8: stx $110E                ; 8E 0E 11
S002_10FB: clc                      ; 18
S002_10FC: rts                      ; 60
    dta $A0,$29,$C9,$42,$F0,$02,$A0,$24,$8C,$76,$11,$A0,$0A,$20,$95,$12 ; $10FD unidentified data/code
    dta $D9,$00,$07,$D0,$39,$88,$10,$F5,$BD,$FF,$06,$BC,$FE,$06,$4C,$75 ; $110D unidentified data/code
    dta $11 ; $111D unidentified data/code
S002_111E: clc                      ; 18
S002_111F: lda $13ED                ; AD ED 13
S002_1122: ldy $13EC                ; AC EC 13
S002_1125: bit $38                  ; 24 38
S002_1127: sty $116B                ; 8C 6B 11
S002_112A: sta $116D                ; 8D 6D 11
S002_112D: lda #$08                 ; A9 08
S002_112F: bcc *+5                  ; 90 03
S002_1131: lda $06FC,x              ; BD FC 06
S002_1134: sta $13E5                ; 8D E5 13
S002_1137: jsr $1164                ; 20 64 11
S002_113A: ldx #$00                 ; A2 00
S002_113C: stx $110E                ; 8E 0E 11
S002_113F: beq *+64                 ; F0 3E
S002_1141: ldx #$18                 ; A2 18
S002_1143: stx $10FB                ; 8E FB 10
S002_1146: ldx $110E                ; AE 0E 11
S002_1149: beq *-98                 ; F0 9C
S002_114B: txa                      ; 8A
S002_114C: clc                      ; 18
S002_114D: adc #$10                 ; 69 10
S002_114F: tax                      ; AA
S002_1150: bcc *-103                ; 90 97
S002_1152: lda $13FF                ; AD FF 13
S002_1155: ldy $13FE                ; AC FE 13
S002_1158: iny                      ; C8
S002_1159: bne *+4                  ; D0 02
S002_115B: adc #$00                 ; 69 00
S002_115D: dec $1255                ; CE 55 12
S002_1160: bne *-126                ; D0 80
S002_1162: sec                      ; 38
S002_1163: rts                      ; 60
S002_1164: ldx $13E5                ; AE E5 13
S002_1167: stx $1255                ; 8E 55 12
S002_116A: ldy #$69                 ; A0 69
S002_116C: lda #$01                 ; A9 01
S002_116E: rts                      ; 60
    dta $AD,$FD,$07,$AC,$FE,$07,$08,$29,$03,$28,$D0,$04,$C9,$00,$F0,$E3 ; $116F unidentified data/code
S002_117F: sta $13FF                ; 8D FF 13
S002_1182: sty $13FE                ; 8C FE 13
S002_1185: ldx #$52                 ; A2 52
S002_1187: ldy #$00                 ; A0 00
S002_1189: sty $13F2                ; 8C F2 13
S002_118C: jmp ($13EE)              ; 6C EE 13
    dta $8C,$F8,$13,$8E,$F9,$13,$8D,$FA,$13,$20,$C4,$11,$A0,$02,$B9,$F5 ; $118F unidentified data/code
    dta $13,$D9,$F8,$13,$90,$F3,$88,$10,$F5,$18,$60,$8E,$F2,$13,$A0,$0B ; $119F unidentified data/code
    dta $8C,$F5,$13,$20,$95,$12,$AC,$F2,$13,$20,$E7,$11,$AC,$F5,$13,$C0 ; $11AF unidentified data/code
    dta $16,$D0,$F0,$F0,$5F,$20,$CA,$11,$B0,$39,$60,$20,$ED,$11,$B9,$00 ; $11BF unidentified data/code
    dta $07,$C8,$8C,$F2,$13,$A2,$FD,$FE,$F8,$12,$D0,$03,$E8,$D0,$F8,$60 ; $11CF unidentified data/code
    dta $8D,$E6,$11,$20,$F3,$11,$A9,$FF,$99,$00,$07,$4C,$D0,$11,$20,$99 ; $11DF unidentified data/code
    dta $12,$B0,$0B,$60,$20,$99,$12,$90,$FA,$20,$23,$12,$B0,$F5,$20,$6F ; $11EF unidentified data/code
    dta $11,$90,$EB,$68,$68,$60,$8E,$10,$12,$8C,$0F,$12,$20,$7F,$12,$AD ; $11FF unidentified data/code
    dta $FF,$FF,$EE,$0F,$12,$D0,$03,$EE,$10,$12,$20,$DF,$11,$B0,$C0,$20 ; $120F unidentified data/code
    dta $AE,$12,$D0,$EB,$A2,$50,$6C,$EE,$13 ; $121F unidentified data/code
S002_1228: ldx #$FD                 ; A2 FD
S002_122A: lda #$00                 ; A9 00
S002_122C: sta $12F8,x              ; 9D F8 12
S002_122F: inx                      ; E8
S002_1230: bne *-4                  ; D0 FA
S002_1232: tay                      ; A8
S002_1233: sty $1280                ; 8C 80 12
S002_1236: stx $1285                ; 8E 85 12
S002_1239: rts                      ; 60
S002_123A: stx $1050                ; 8E 50 10
S002_123D: sty $104F                ; 8C 4F 10
S002_1240: rts                      ; 60
S002_1241: stx $10A1                ; 8E A1 10
S002_1244: sty $10A0                ; 8C A0 10
S002_1247: rts                      ; 60
S002_1248: bcc *+17                 ; 90 0F
S002_124A: stx $1255                ; 8E 55 12
S002_124D: ldy $13F1                ; AC F1 13
S002_1250: lda $0700,y              ; B9 00 07
S002_1253: sta $FF00,y              ; 99 00 FF
S002_1256: iny                      ; C8
S002_1257: bne *-7                  ; D0 F7
S002_1259: stx $1252                ; 8E 52 12
S002_125C: stx $13F0                ; 8E F0 13
S002_125F: stx $110F                ; 8E 0F 11
S002_1262: stx $1171                ; 8E 71 11
S002_1265: stx $1174                ; 8E 74 11
S002_1268: stx $129E                ; 8E 9E 12
S002_126B: stx $11CF                ; 8E CF 11
S002_126E: stx $11E9                ; 8E E9 11
S002_1271: dex                      ; CA
S002_1272: stx $1133                ; 8E 33 11
S002_1275: stx $111A                ; 8E 1A 11
S002_1278: stx $1117                ; 8E 17 11
S002_127B: stx $10EB                ; 8E EB 10
S002_127E: rts                      ; 60
    dta $A9,$00,$8D,$F3,$13,$A9,$00,$8D,$F4,$13,$60,$A0,$E4,$A2,$12,$8C ; $127F unidentified data/code
    dta $EE,$13,$8E,$EF,$13,$60,$B9,$FF,$FF,$60,$AC,$F2,$13,$CC,$FF,$07 ; $128F unidentified data/code
    dta $60,$B9,$FF,$FF,$8D,$FF,$FF,$EE,$A4,$12,$D0,$03,$EE,$A5,$12,$AD ; $129F unidentified data/code
    dta $F3,$13,$D0,$03,$CE,$F4,$13,$CE,$F3,$13,$AD,$F3,$13,$0D,$F4,$13 ; $12AF unidentified data/code
    dta $60 ; $12BF unidentified data/code
S002_12C0: jsr $1228                ; 20 28 12
S002_12C3: lda $13EB                ; AD EB 13
S002_12C6: ldy $13EA                ; AC EA 13
S002_12C9: jmp $117F                ; 4C 7F 11
S002_12CC: sta $13F1                ; 8D F1 13
S002_12CF: sta $11CE                ; 8D CE 11
S002_12D2: sta $11E8                ; 8D E8 11
S002_12D5: ldx #$90                 ; A2 90
S002_12D7: ora #$05                 ; 09 05
S002_12D9: bmi *+4                  ; 30 02
S002_12DB: ldx #$B0                 ; A2 B0
S002_12DD: stx $10F0                ; 8E F0 10
S002_12E0: sta $10E8                ; 8D E8 10
S002_12E3: rts                      ; 60
    dta $58,$8E,$02,$03,$A9,$80,$E0,$50,$F0,$01,$4A,$8D,$03,$03,$AD,$FF ; $12E4 unidentified data/code
    dta $13,$8D,$0B,$03,$AD,$FE,$13,$8D,$0A,$03,$AD,$F0,$13,$8D,$05,$03 ; $12F4 unidentified data/code
    dta $20,$59,$E4,$98,$0A,$60,$8D,$2C,$13,$8D,$38,$13,$20,$CA,$11,$C9 ; $1304 unidentified data/code
    dta $02,$D0,$FE,$A9,$FF,$8D,$48,$13,$8D,$50,$13,$A9,$80,$20,$BC,$13 ; $1314 unidentified data/code
    dta $48,$20,$CA,$11,$20,$A3,$12,$A9,$00,$D0,$03,$CE,$38,$13,$CE,$2C ; $1324 unidentified data/code
    dta $13,$D0,$EE,$A9,$00,$D0,$EA,$68,$0A,$B0,$3E,$20,$BC,$13,$48,$AD ; $1334 unidentified data/code
    dta $A4,$12,$18,$69,$00,$8D,$A1,$12,$AD,$A5,$12,$69,$00,$8D,$A2,$12 ; $1344 unidentified data/code
    dta $A0,$00,$AE,$38,$13,$F0,$0C,$20,$A0,$12,$C8,$D0,$FA,$EE,$A2,$12 ; $1354 unidentified data/code
    dta $CA,$D0,$F4,$AE,$2C,$13,$F0,$07,$20,$A0,$12,$C8,$CA,$D0,$F9,$8E ; $1364 unidentified data/code
    dta $38,$13,$8E,$2C,$13,$68,$0A,$90,$A4,$A2,$FE,$8E,$2C,$13,$20,$BF ; $1374 unidentified data/code
    dta $13,$48,$08,$AE,$2C,$13,$E8,$8E,$50,$13,$D0,$05,$28,$68,$4C,$5C ; $1384 unidentified data/code
    dta $10,$20,$CA,$11,$28,$8D,$48,$13,$6E,$50,$13,$6E,$48,$13,$A2,$00 ; $1394 unidentified data/code
    dta $8E,$38,$13,$E8,$8E,$2C,$13,$68,$B0,$03,$20,$CA,$13,$EE,$2C,$13 ; $13A4 unidentified data/code
    dta $D0,$03,$EE,$38,$13,$4C,$42,$13,$EE,$2C,$13,$0A,$D0,$05,$20,$CA ; $13B4 unidentified data/code
    dta $11,$38,$2A,$90,$01,$60,$0A,$2E,$2C,$13,$2E,$38,$13,$4C,$BF,$13 ; $13C4 unidentified data/code
    dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $13D4 unidentified data/code
    dta $00,$08,$28,$FF,$00,$28,$00,$00,$69,$01,$E4,$12,$07,$80,$00,$00 ; $13E4 unidentified data/code
    dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; $13F4 unidentified data/code

; Segment 3: $02E0-$02E1; file offset $0005FA
    org $0000
    dta a($02E0),a($02E1)
    org $02E0
    dta $50,$14 ; $02E0 unidentified data/code

; Segment 4: $1600-$1845; file offset $000600
    org $0000
    dta a($1600),a($1845)
    org $1600
S004_1600: lda $140B                ; AD 0B 14
S004_1603: sec                      ; 38
S004_1604: sbc #$20                 ; E9 20
S004_1606: sta $86                  ; 85 86
S004_1608: ldy #$22                 ; A0 22
S004_160A: lda $140B                ; AD 0B 14
S004_160D: jsr $179C                ; 20 9C 17
S004_1610: ldy #$29                 ; A0 29
S004_1612: lda $140C                ; AD 0C 14
S004_1615: jsr $179C                ; 20 9C 17
S004_1618: lda $0304                ; AD 04 03
S004_161B: jsr $179C                ; 20 9C 17
S004_161E: ldy #$2F                 ; A0 2F
S004_1620: lda $140E                ; AD 0E 14
S004_1623: jsr $179C                ; 20 9C 17
S004_1626: lda $140D                ; AD 0D 14
S004_1629: jsr $179C                ; 20 9C 17
S004_162C: ldy #$35                 ; A0 35
S004_162E: lda $1410                ; AD 10 14
S004_1631: jsr $179C                ; 20 9C 17
S004_1634: lda $140F                ; AD 0F 14
S004_1637: jsr $179C                ; 20 9C 17
S004_163A: ldy #$3B                 ; A0 3B
S004_163C: lda $13EF                ; AD EF 13
S004_163F: jsr $15BB                ; 20 BB 15
S004_1642: jsr $179C                ; 20 9C 17
S004_1645: lda $13EE                ; AD EE 13
S004_1648: jsr $179C                ; 20 9C 17
S004_164B: ldy #$5D                 ; A0 5D
S004_164D: lda $13E7                ; AD E7 13
S004_1650: bmi *+5                  ; 30 03
S004_1652: jsr $179C                ; 20 9C 17
S004_1655: ldy #$4A                 ; A0 4A
S004_1657: lda $13FC                ; AD FC 13
S004_165A: and #$0F                 ; 29 0F
S004_165C: jsr $179C                ; 20 9C 17
S004_165F: lda $14                  ; A5 14
S004_1661: cmp $14                  ; C5 14
S004_1663: beq *-2                  ; F0 FC
S004_1665: lda $0230                ; AD 30 02
S004_1668: sta $1764                ; 8D 64 17
S004_166B: lda $0231                ; AD 31 02
S004_166E: sta $1769                ; 8D 69 17
S004_1671: lda #$C1                 ; A9 C1
S004_1673: sta $0230                ; 8D 30 02
S004_1676: lda #$17                 ; A9 17
S004_1678: sta $0231                ; 8D 31 02
S004_167B: lda #$21                 ; A9 21
S004_167D: sta $022F                ; 8D 2F 02
S004_1680: jsr $1033                ; 20 33 10
S004_1683: jsr $1012                ; 20 12 10
S004_1686: lda #$8B                 ; A9 8B
S004_1688: sta $1719                ; 8D 19 17
S004_168B: lda #$11                 ; A9 11
S004_168D: sta $80                  ; 85 80
S004_168F: jsr $17B4                ; 20 B4 17
S004_1692: lda #$08                 ; A9 08
S004_1694: sta $81                  ; 85 81
S004_1696: sta $83                  ; 85 83
S004_1698: lda #$19                 ; A9 19
S004_169A: sta $82                  ; 85 82
S004_169C: lda #$1A                 ; A9 1A
S004_169E: sta $84                  ; 85 84
S004_16A0: jsr $103C                ; 20 3C 10
S004_16A3: bcs *+58                 ; B0 38
S004_16A5: pha                      ; 48
S004_16A6: ldy #$00                 ; A0 00
S004_16A8: lda $80                  ; A5 80
S004_16AA: sta ($81),y              ; 91 81
S004_16AC: lda #$0E                 ; A9 0E
S004_16AE: iny                      ; C8
S004_16AF: sta ($81),y              ; 91 81
S004_16B1: iny                      ; C8
S004_16B2: pla                      ; 68
S004_16B3: and #$10                 ; 29 10
S004_16B5: beq *+4                  ; F0 02
S004_16B7: lda #$0B                 ; A9 0B
S004_16B9: sta ($81),y              ; 91 81
S004_16BB: sta ($83),y              ; 91 83
S004_16BD: iny                      ; C8
S004_16BE: lda $0700,x              ; BD 00 07
S004_16C1: sta ($83),y              ; 91 83
S004_16C3: sec                      ; 38
S004_16C4: sbc #$20                 ; E9 20
S004_16C6: sta ($81),y              ; 91 81
S004_16C8: inx                      ; E8
S004_16C9: iny                      ; C8
S004_16CA: cpy #$0E                 ; C0 0E
S004_16CC: bne *-14                 ; D0 F0
S004_16CE: inc $80                  ; E6 80
S004_16D0: lda $81                  ; A5 81
S004_16D2: clc                      ; 18
S004_16D3: adc #$20                 ; 69 20
S004_16D5: sta $81                  ; 85 81
S004_16D7: sta $83                  ; 85 83
S004_16D9: bcc *-57                 ; 90 C5
S004_16DB: bcs *+7                  ; B0 05
S004_16DD: lda #$83                 ; A9 83
S004_16DF: sta $1719                ; 8D 19 17
S004_16E2: lda $D20F                ; AD 0F D2
S004_16E5: and #$04                 ; 29 04
S004_16E7: bne *-5                  ; D0 F9
S004_16E9: lda $D209                ; AD 09 D2
S004_16EC: ldy #$0E                 ; A0 0E
S004_16EE: cmp $176E,y              ; D9 6E 17
S004_16F1: beq *+32                 ; F0 1E
S004_16F3: cmp $1785,y              ; D9 85 17
S004_16F6: beq *+11                 ; F0 09
S004_16F8: dey                      ; 88
S004_16F9: bpl *-11                 ; 10 F3
S004_16FB: jsr $1794                ; 20 94 17
S004_16FE: jmp $16E2                ; 4C E2 16
S004_1701: tya                      ; 98
S004_1702: clc                      ; 18
S004_1703: adc #$31                 ; 69 31
S004_1705: sta $13FC                ; 8D FC 13
S004_1708: sta $0300                ; 8D 00 03
S004_170B: jsr $1763                ; 20 63 17
S004_170E: jmp $148E                ; 4C 8E 14
S004_1711: cmp #$21                 ; C9 21
S004_1713: bne *+8                  ; D0 06
S004_1715: jsr $1794                ; 20 94 17
S004_1718: jmp $168B                ; 4C 8B 16
S004_171B: cmp #$1C                 ; C9 1C
S004_171D: bne *+8                  ; D0 06
S004_171F: jsr $1794                ; 20 94 17
S004_1722: jmp $1680                ; 4C 80 16
S004_1725: lda $177D,y              ; B9 7D 17
S004_1728: pha                      ; 48
S004_1729: tay                      ; A8
S004_172A: ldx #$1F                 ; A2 1F
S004_172C: lda $1900,y              ; B9 00 19
S004_172F: eor #$80                 ; 49 80
S004_1731: sta $1900,y              ; 99 00 19
S004_1734: iny                      ; C8
S004_1735: dex                      ; CA
S004_1736: bpl *-10                 ; 10 F4
S004_1738: jsr $1794                ; 20 94 17
S004_173B: pla                      ; 68
S004_173C: tax                      ; AA
S004_173D: ldy #$00                 ; A0 00
S004_173F: clc                      ; 18
S004_1740: lda $1A0B,x              ; BD 0B 1A
S004_1743: sta $1400,y              ; 99 00 14
S004_1746: iny                      ; C8
S004_1747: inx                      ; E8
S004_1748: cpy #$0B                 ; C0 0B
S004_174A: bne *-10                 ; D0 F4
S004_174C: lda $19FF,x              ; BD FF 19
S004_174F: cmp #$0B                 ; C9 0B
S004_1751: beq *+8                  ; F0 06
S004_1753: jsr $1763                ; 20 63 17
S004_1756: jmp $14CF                ; 4C CF 14
S004_1759: ldy #$00                 ; A0 00
S004_175B: ldx #$14                 ; A2 14
S004_175D: jsr $102D                ; 20 2D 10
S004_1760: jmp $1683                ; 4C 83 16
S004_1763: lda #$FF                 ; A9 FF
S004_1765: sta $0230                ; 8D 30 02
S004_1768: lda #$FF                 ; A9 FF
S004_176A: sta $0231                ; 8D 31 02
S004_176D: rts                      ; 60
    dta $1F,$1E,$1A,$18,$1D,$1B,$33,$35,$21,$1C,$C0,$C0,$C0,$C0,$C0,$00 ; $176E unidentified data/code
    dta $20,$40,$60,$80,$A0,$C0,$E0,$5F,$5E,$5A,$58,$5D,$5B,$73,$75,$70 ; $177E unidentified data/code
    dta $7F,$55,$52,$7A,$6A,$78 ; $178E unidentified data/code
S004_1794: lda $D20F                ; AD 0F D2
S004_1797: and #$04                 ; 29 04
S004_1799: beq *-5                  ; F0 F9
S004_179B: rts                      ; 60
S004_179C: pha                      ; 48
S004_179D: lsr                      ; 4A
S004_179E: lsr                      ; 4A
S004_179F: lsr                      ; 4A
S004_17A0: lsr                      ; 4A
S004_17A1: jsr $17A7                ; 20 A7 17
S004_17A4: pla                      ; 68
S004_17A5: and #$0F                 ; 29 0F
S004_17A7: cmp #$0A                 ; C9 0A
S004_17A9: sed                      ; F8
S004_17AA: adc #$10                 ; 69 10
S004_17AC: cld                      ; D8
S004_17AD: ora #$80                 ; 09 80
S004_17AF: sta $17E6,y              ; 99 E6 17
S004_17B2: iny                      ; C8
S004_17B3: rts                      ; 60
S004_17B4: ldy #$00                 ; A0 00
S004_17B6: tya                      ; 98
S004_17B7: sta $1900,y              ; 99 00 19
S004_17BA: sta $1A00,y              ; 99 00 1A
S004_17BD: iny                      ; C8
S004_17BE: bne *-7                  ; D0 F7
S004_17C0: rts                      ; 60
    dta $70,$70,$70,$70,$70,$70,$70,$70,$42,$E6,$17,$02,$20,$42,$00,$19 ; $17C1 unidentified data/code
    dta $00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$20,$42 ; $17D1 unidentified data/code
    dta $26,$18,$41,$C1,$17,$80,$F8,$A2,$94,$8E,$93,$80,$80,$FC,$A2,$B5 ; $17E1 unidentified data/code
    dta $A6,$80,$80,$FC,$A9,$AE,$A9,$80,$80,$FC,$B2,$B5,$AE,$80,$80,$FC ; $17F1 unidentified data/code
    dta $A9,$8F,$AF,$80,$80,$80,$84,$8D,$8D,$90,$90,$80,$80,$84,$8D,$8D ; $1801 unidentified data/code
    dta $8D,$8D,$80,$84,$8D,$8D,$8D,$8D,$80,$84,$8D,$8D,$8D,$8D,$80,$84 ; $1811 unidentified data/code
    dta $8D,$8D,$8D,$8D,$80,$80,$A4,$E5,$F6,$E9,$E3,$E5,$9A,$80,$84,$80 ; $1821 unidentified data/code
    dta $80,$80,$80,$FC,$80,$B5,$EC,$F4,$F2,$E1,$B3,$F0,$E5,$E5,$E4,$9A ; $1831 unidentified data/code
    dta $80,$84,$8D,$8D,$80 ; $1841 unidentified data/code
