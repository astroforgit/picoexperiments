; ------------------------------------------------------------------
; Input: Atari joystick 1 -> C64 joystick port 2; Atari keyboard -> one
; key of the C64 matrix (plus SHIFT). The game reads them through the
; $DC00/$DC01 stubs (stubs-rt.asm).
; ------------------------------------------------------------------
input_init
        lda #$FF
        sta joy2
        sta key_pb
        sta last_key
        lda #0
        sta key_pa
        sta shift_on
        sta kq
        lda #3
        sta SKCTL               ; keyboard scan on
        rts

read_input
        lda TRIG0
        and #1
        asl
        asl
        asl
        asl
        sta ri_t
        lda PORTA
        and #$0F
        ora ri_t
        ora #$E0
        sta joy2
        ; SHIFT
        lda SKSTAT
        and #$08
        eor #$08
        sta shift_on            ; non-zero: held
        ; START = RETURN, held key from the keyboard
        lda CONSOL
        lsr
        bcs ri_kb
        lda #$01                ; RETURN: PA0 / PB1
        ldx #$0C
        jmp ri_set
ri_kb   lda SKSTAT
        and #$04
        bne ri_none
        lda KBCODE
        and #$3F
        tax
        lda kmap,x
        cmp #$FF
        beq ri_none
ri_set  stx ri_code
        pha
        lsr
        lsr
        lsr
        tay
        lda bit8,y
        sta key_pa
        pla
        and #7
        tay
        lda bit8,y
        eor #$FF
        sta key_pb
        lda ri_code
        cmp last_key
        beq ri_out
        sta last_key
        tax
        lda kpet,x              ; for GETIN
        sta kq
ri_out  rts
ri_none lda #0
        sta key_pa
        lda #$FF
        sta key_pb
        sta last_key
        rts
ri_t    dta 0
ri_code dta 0
bit8    dta 1,2,4,8,16,32,64,128

; Atari KBCODE (0-63) -> C64 matrix position PA*8+PB, $FF = none
;   letters and digits as labelled, ESC = RUN/STOP, TAB = the C64 left
;   arrow, BACKSPACE = INST/DEL, RETURN, SPACE, < > = F1 F3
kmap
        dta $2A,$22,$32,$FF,$FF,$25,$28,$31   ; L J ; - - K + *
        dta $26,$FF,$29,$1E,$01,$21,$2B,$35   ; O - P U RET I - =
        dta $1F,$FF,$14,$FF,$FF,$1C,$17,$0C   ; V - C - - B X Z
        dta $0B,$FF,$08,$13,$3F,$10,$3B,$38   ; 4 - 3 6 ESC 5 2 1
        dta $2F,$3C,$2C,$27,$FF,$24,$37,$FF   ; , SPACE . N - M / -
        dta $11,$FF,$0E,$19,$39,$16,$09,$3E   ; R - E Y TAB T W Q
        dta $20,$FF,$23,$18,$00,$1B,$04,$05   ; 9 - 0 7 BKSP 8 < >
        dta $15,$1D,$12,$FF,$FF,$1A,$0D,$0A   ; F H D - - G S A
; ... -> PETSCII for GETIN (0 = none)
kpet    dta $4C,$4A,$3B,0,0,$4B,$2B,$2A
        dta $4F,0,$50,$55,$0D,$49,$2D,$3D
        dta $56,0,$43,0,0,$42,$58,$5A
        dta $34,0,$33,$36,$03,$35,$32,$31
        dta $2C,$20,$2E,$4E,0,$4D,$2F,0
        dta $52,0,$45,$59,$5F,$54,$57,$51
        dta $39,0,$30,$37,$14,$38,$85,$86
        dta $46,$48,$44,0,0,$47,$53,$41
