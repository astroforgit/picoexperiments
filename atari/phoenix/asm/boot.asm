; ------------------------------------------------------------------
; Loader: VBXE detection, 4K uploads into VRAM while the XEX loads, then
; (RUN) the RAM image staged at VRAM $50000 + address is copied into place
; with the OS off. Payload segments load at $7FFD: a 3-byte VRAM address,
; then 4096 bytes.
; ------------------------------------------------------------------
SAVMSC  = $58
PORTB   = $D301
NMIEN   = $D40E
DMACTL  = $D400
STAGE   = $8000
WIN     = $5000

        icl '../gen/boot-defs.asm'

        org $9000
vb_hi   dta 0

; INIT: find an FX 1.2x core
detect  lda #$D6
        jsr probe
        bcs found
        lda #$D7
        jsr probe
        bcs found
        ldy #0
msg_l   lda message,y
        beq msg_h
        sec
        sbc #32                 ; ATASCII -> screen code
        sta (SAVMSC),y
        iny
        bne msg_l
msg_h   jmp msg_h
found   sta vb_hi
        sta up_mb+2
        sta up_mb0+2
        rts
probe   sta pr_c+2
        sta pr_m+2
pr_c    lda $D640
        cmp #$10
        bne pr_no
pr_m    lda $D641
        and #$70
        cmp #$20
        bne pr_no
        lda pr_c+2
        sec
        rts
pr_no   lda pr_c+2
        clc
        rts
message dta c'PHOENIX NEEDS VBXE FX 1.2X AT D600/D700',0

; INIT after each payload: copy STAGE..+4095 to VRAM at (STAGE-3)
upload  lda STAGE-2
        and #$3F
        ora #$40
        sta up_dst+2
        lda STAGE-2
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr
        sta up_b
        lda STAGE-1
        asl
        asl
        ora up_b
        ora #$80                ; MEMAC-B bank, CPU access
up_mb   sta $D65D
        lda #>STAGE
        sta up_src+2
        ldx #16
up_pg   ldy #0
up_src  lda STAGE,y
up_dst  sta $4000,y
        iny
        bne up_src
        inc up_src+2
        inc up_dst+2
        dex
        bne up_pg
        lda #0
up_mb0  sta $D65D
        rts
up_b    dta 0

; RUN: OS off, copy the RAM image from VRAM, start
        org $4000
starter sei
        lda #0
        sta NMIEN
        sta DMACTL
        lda #$FE
        sta PORTB
        lda vb_hi
        sta s_vb
        sta st_c+2
        sta st_s+2
        sta st_s2+2
        sta st_c2+2
        lda #$58                ; MEMAC-A: 4K at $5000, CPU access
st_c    sta $D65E
        ldx #$04
        ldy #$40
        jsr copy_range
        ldx #$60
        ldy #$D0
        jsr copy_range
        ldx #$D8
        ldy #$00
        jsr copy_range
        lda #0
st_s2   sta $D65F
st_c2   sta $D65E
        lda s_vb
        jmp RT_START

; copy pages X..Y-1 from VRAM $50000 + address
copy_range
        sty s_end
cr_pg   txa
        lsr
        lsr
        lsr
        lsr
        ora #$80|$50
st_s    sta $D65F
        txa
        and #$0F
        ora #>WIN
        sta cr_src+2
        stx cr_dst+2
        ldy #0
cr_src  lda $FF00,y
cr_dst  sta $FF00,y
        iny
        bne cr_src
        inx
        cpx s_end
        bne cr_pg
        rts
s_end   dta 0
s_vb    dta 0
