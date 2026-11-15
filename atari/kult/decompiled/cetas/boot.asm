; CETAS boot sectors (header included)
; Recovered bytes; semantic annotation is partial. Unknown bytes remain DTA.
    opt h-
RUNAD = $02E0
INITAD = $02E2

; $07C4-$0943
    org $07C4
    dta $78,$03,$C4,$07,$62,$08 ; $07C4
BootEntry:
    lda #$07                       ; $07CA: A9 07
L07CC:
    sta $1A                        ; $07CC: 85 1A
L07CE:
    lda #$3C                       ; $07CE: A9 3C
L07D0:
    sta $24                        ; $07D0: 85 24
L07D2:
    lda #$09                       ; $07D2: A9 09
L07D4:
    sta $02E8                      ; $07D4: 8D E8 02
L07D7:
    sta $25                        ; $07D7: 85 25
L07D9:
    ldx #$44                       ; $07D9: A2 44
L07DB:
    ldy #$14                       ; $07DB: A0 14
L07DD:
    jsr $E486                      ; $07DD: 20 86 E4
L07E0:
    lda #$80                       ; $07E0: A9 80
L07E2:
    sta $02E7                      ; $07E2: 8D E7 02
L07E5:
    lda $02EA                      ; $07E5: AD EA 02
L07E8:
    and #$20                       ; $07E8: 29 20
L07EA:
    beq L07F1                      ; $07EA: F0 05
L07EC:
    inc $02D6                      ; $07EC: EE D6 02
L07EF:
    asl                            ; $07EF: 0A
L07F0:
    asl                            ; $07F0: 0A
L07F1:
    eor #$80                       ; $07F1: 49 80
L07F3:
    sta $19                        ; $07F3: 85 19
L07F5:
    sta $02D5                      ; $07F5: 8D D5 02
L07F8:
    ora #$05                       ; $07F8: 09 05
L07FA:
    sta $18                        ; $07FA: 85 18
L07FC:
    eor #$F8                       ; $07FC: 49 F8
L07FE:
    sta $44                        ; $07FE: 85 44
L0800:
    jsr L0864                      ; $0800: 20 64 08
L0803:
    bmi BootInit                   ; $0803: 30 5D
L0805:
    jsr L092A                      ; $0805: 20 2A 09
L0808:
    bmi L0847                      ; $0808: 30 3D
L080A:
    sta $45                        ; $080A: 85 45
L080C:
    jsr L092A                      ; $080C: 20 2A 09
L080F:
    sta $46                        ; $080F: 85 46
L0811:
    cmp #$FF                       ; $0811: C9 FF
L0813:
    beq L0805                      ; $0813: F0 F0
L0815:
    jsr L092A                      ; $0815: 20 2A 09
L0818:
    sta $47                        ; $0818: 85 47
L081A:
    jsr L092A                      ; $081A: 20 2A 09
L081D:
    sta $48                        ; $081D: 85 48
L081F:
    lda #$62                       ; $081F: A9 62
L0821:
    sta INITAD                     ; $0821: 8D E2 02
L0824:
    lda #$08                       ; $0824: A9 08
L0826:
    sta $02E3                      ; $0826: 8D E3 02
L0829:
    jsr L092A                      ; $0829: 20 2A 09
L082C:
    dey                            ; $082C: 88
L082D:
    sta ($45),y                    ; $082D: 91 45
L082F:
    ldy $45                        ; $082F: A4 45
L0831:
    lda $46                        ; $0831: A5 46
L0833:
    inc $45                        ; $0833: E6 45
L0835:
    bne L0839                      ; $0835: D0 02
L0837:
    inc $46                        ; $0837: E6 46
L0839:
    cpy $47                        ; $0839: C4 47
L083B:
    sbc $48                        ; $083B: E5 48
L083D:
    bcc L0829                      ; $083D: 90 EA
L083F:
    lda #$08                       ; $083F: A9 08
L0841:
    pha                            ; $0841: 48
L0842:
    lsr                            ; $0842: 4A
L0843:
    pha                            ; $0843: 48
L0844:
    jmp (INITAD)                   ; $0844: 6C E2 02
L0847:
    jmp (RUNAD)                    ; $0847: 6C E0 02
    dta $A5,$22,$C9,$28,$F0,$B0,$60 ; $084A
L0851:
    lda $48                        ; $0851: A5 48
L0853:
    clc                            ; $0853: 18
L0854:
    adc #$10                       ; $0854: 69 10
L0856:
    bcc L087F                      ; $0856: 90 27
L0858:
    ldy $030A                      ; $0858: AC 0A 03
L085B:
    iny                            ; $085B: C8
L085C:
    lsr $45                        ; $085C: 46 45
L085E:
    bne L0876                      ; $085E: D0 16
L0860:
    ldy #$AA                       ; $0860: A0 AA
BootInit:
    clc                            ; $0862: 18
L0863:
    rts                            ; $0863: 60
L0864:
    sec                            ; $0864: 38
L0865:
    ror $45                        ; $0865: 66 45
L0867:
    ldy #$91                       ; $0867: A0 91
L0869:
    lda $2A                        ; $0869: A5 2A
L086B:
    cmp #$08                       ; $086B: C9 08
L086D:
    beq L0871                      ; $086D: F0 02
L086F:
    ldy #$B1                       ; $086F: A0 B1
L0871:
    sty L0931                      ; $0871: 8C 31 09
L0874:
    ldy #$69                       ; $0874: A0 69
L0876:
    lda #$01                       ; $0876: A9 01
L0878:
    jsr L08ED                      ; $0878: 20 ED 08
L087B:
    bmi BootInit                   ; $087B: 30 E5
L087D:
    lda $18                        ; $087D: A5 18
L087F:
    tax                            ; $087F: AA
L0880:
    stx $48                        ; $0880: 86 48
L0882:
    lda $06FB,x                    ; $0882: BD FB 06
L0885:
    and #$46                       ; $0885: 29 46
L0887:
    beq L0851                      ; $0887: F0 C8
L0889:
    ldy #$03                       ; $0889: A0 03
L088B:
    cmp #$42                       ; $088B: C9 42
L088D:
    beq L0891                      ; $088D: F0 02
L088F:
    ldy #$FF                       ; $088F: A0 FF
L0891:
    sty $49                        ; $0891: 84 49
L0893:
    ldy #$01                       ; $0893: A0 01
L0895:
    iny                            ; $0895: C8
L0896:
    lda ($24),y                    ; $0896: B1 24
L0898:
    cmp #$3A                       ; $0898: C9 3A
L089A:
    beq L0895                      ; $089A: F0 F9
L089C:
    cmp #$9B                       ; $089C: C9 9B
L089E:
    beq L08AB                      ; $089E: F0 0B
L08A0:
    cmp #$2E                       ; $08A0: C9 2E
L08A2:
    bne L08AE                      ; $08A2: D0 0A
L08A4:
    txa                            ; $08A4: 8A
L08A5:
    and #$0F                       ; $08A5: 29 0F
L08A7:
    cmp #$0D                       ; $08A7: C9 0D
L08A9:
    beq L0895                      ; $08A9: F0 EA
L08AB:
    dey                            ; $08AB: 88
L08AC:
    lda #$20                       ; $08AC: A9 20
L08AE:
    cmp $0700,x                    ; $08AE: DD 00 07
L08B1:
    bne L0851                      ; $08B1: D0 9E
L08B3:
    inx                            ; $08B3: E8
L08B4:
    txa                            ; $08B4: 8A
L08B5:
    and #$0F                       ; $08B5: 29 0F
L08B7:
    bne L0895                      ; $08B7: D0 DC
L08B9:
    ldx $48                        ; $08B9: A6 48
L08BB:
    ldy $06FE,x                    ; $08BB: BC FE 06
L08BE:
    lda $06FF,x                    ; $08BE: BD FF 06
L08C1:
    bcs L08D8                      ; $08C1: B0 15
L08C3:
    lda $44                        ; $08C3: A5 44
L08C5:
    cmp $07FF                      ; $08C5: CD FF 07
L08C8:
    bne L0939                      ; $08C8: D0 6F
L08CA:
    lda $07FD                      ; $08CA: AD FD 07
L08CD:
    and $49                        ; $08CD: 25 49
L08CF:
    ldy L07FE                      ; $08CF: AC FE 07
L08D2:
    bne L08D8                      ; $08D2: D0 04
L08D4:
    cmp #$00                       ; $08D4: C9 00
L08D6:
    beq L0939                      ; $08D6: F0 61
L08D8:
    jsr L08ED                      ; $08D8: 20 ED 08
L08DB:
    php                            ; $08DB: 08
L08DC:
    ldx #$00                       ; $08DC: A2 00
L08DE:
    stx $43                        ; $08DE: 86 43
L08E0:
    ldx $2A                        ; $08E0: A6 2A
L08E2:
    cpx #$08                       ; $08E2: E0 08
L08E4:
    bne L08EB                      ; $08E4: D0 05
L08E6:
    lda $44                        ; $08E6: A5 44
L08E8:
    sta $07FF                      ; $08E8: 8D FF 07
L08EB:
    plp                            ; $08EB: 28
L08EC:
    rts                            ; $08EC: 60
L08ED:
    ldx #$52                       ; $08ED: A2 52
L08EF:
    sta $030B                      ; $08EF: 8D 0B 03
L08F2:
    sty $030A                      ; $08F2: 8C 0A 03
L08F5:
    stx $0302                      ; $08F5: 8E 02 03
L08F8:
    lda $19                        ; $08F8: A5 19
L08FA:
    sta $0304                      ; $08FA: 8D 04 03
L08FD:
    lda $1A                        ; $08FD: A5 1A
L08FF:
    sta $0305                      ; $08FF: 8D 05 03
L0902:
    jmp $E453                      ; $0902: 4C 53 E4
L0905:
    lda $2A                        ; $0905: A5 2A
L0907:
    cmp #$08                       ; $0907: C9 08
L0909:
    bne L0935                      ; $0909: D0 2A
L090B:
    ldx #$57                       ; $090B: A2 57
L090D:
    lda $43                        ; $090D: A5 43
L090F:
    sta $07FF                      ; $090F: 8D FF 07
L0912:
    bcs L08F5                      ; $0912: B0 E1
    dta $63,$08,$04,$09,$29,$09,$29,$09,$36,$09,$49,$08 ; $0914
L0920:
    pha                            ; $0920: 48
L0921:
    jsr L0905                      ; $0921: 20 05 09
L0924:
    jsr L08C3                      ; $0924: 20 C3 08
L0927:
    bmi L0938                      ; $0927: 30 0F
L0929:
    pla                            ; $0929: 68
L092A:
    ldy $43                        ; $092A: A4 43
L092C:
    cpy $07FF                      ; $092C: CC FF 07
L092F:
    bcs L0920                      ; $092F: B0 EF
L0931:
    lda ($19),y                    ; $0931: B1 19
L0933:
    inc $43                        ; $0933: E6 43
L0935:
    ldy #$01                       ; $0935: A0 01
L0937:
    rts                            ; $0937: 60
L0938:
    pla                            ; $0938: 68
L0939:
    ldy #$88                       ; $0939: A0 88
L093B:
    rts                            ; $093B: 60
    dta $44,$3A,$41,$55,$54,$4F,$9B,$00 ; $093C
