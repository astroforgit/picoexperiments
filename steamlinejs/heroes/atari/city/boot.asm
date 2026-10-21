; Boot sectors 1-2 of the single-disk release. Streams the unchanged game XEX
; stored after the story pictures, using the same OS SIO reads as story.load.
        opt h-
        icl 'generated/boot-layout.inc'
PORTB=$D301
SDMCTL=$022F
SOUNDR=$41
BASICF=$03F8
RUNAD=$02E0
INITAD=$02E2
DCB=$0300
SIOV=$E459
buffer=$0800

        org $0700
        dta 0,2,a($0700),a(done)
        ; The OS calls here after loading both boot sectors; it never returns.
        lda PORTB
        ora #2
        sta PORTB
        lda #1
        sta BASICF
        lda #0
        sta SDMCTL
        sta SOUNDR
segment lda #<done
        sta INITAD
        lda #>done
        sta INITAD+1
header  jsr get
        sta store+1
        jsr get
        sta store+2
        and store+1
        cmp #$FF
        beq header
        ; A zero start address marks the end of the stored XEX.
        lda store+1
        ora store+2
        beq run
        jsr get
        sta last
        jsr get
        sta last+1
copy    jsr get
store   sta $FFFF
        lda store+1
        cmp last
        lda store+2
        sbc last+1
        inc store+1
        bne advanced
        inc store+2
advanced
        bcc copy
        jsr init
        jmp segment
init    jmp (INITAD)
run     jmp (RUNAD)

get     ldx pos
        bne have
read    ldy #11
command lda sio,y
        sta DCB,y
        dey
        bpl command
        jsr SIOV
        tya
        bmi read
        inc sio+10
        bne loaded
        inc sio+11
loaded  ldx #0
have    lda buffer,x
        inx
        stx pos
done    rts

pos     dta 0
last    dta a(0)
sio     dta $31,1,$52,$40,a(buffer),7,0,a(256),a(XEX_SECTOR)
boot_end
        ert boot_end>buffer
