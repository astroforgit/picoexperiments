; ------------------------------------------------------------------
; XEX loader: VBXE detection, 4K uploads into VRAM while the file loads,
; then (RUN) code A is copied from VRAM into place with the OS off.
; Payload segments load at STAGE-3: a 3-byte VRAM address, then 4096 bytes.
; (From the Ghosts'n Goblins port.)
; ------------------------------------------------------------------
        icl 'defs.asm'
        icl '../gen/boot-defs.asm'      ; RT_BOOT, V_RTIMG
SAVMSC  = $58
STAGE   = $8000

        org $9000
vb_hi   dta 0

; INIT: find an FX 1.2x core at $D600 or $D700
detect  lda #$D6
        jsr probe
        bcs found
        lda #$D7
        jsr probe
        bcs found
        ldy #0                  ; no VBXE: message on the OS screen, stop
msg_l   lda message,y
        beq msg_h
        sec
        sbc #32
        sta (SAVMSC),y
        iny
        bne msg_l
msg_h   jmp msg_h
found   sta vb_hi
        sta rl_mb+2
        sta rl_mb0+2
        sta up_mb+2
        sta up_mb0+2
        sta st_mb+2
        sta st_mb0+2
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
message dta c'CAULDRON NEEDS A VBXE WITH THE FX 1.2X CORE',0

; INIT after each payload: copy STAGE..+4095 to VRAM at (STAGE-3), 4K aligned
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
        ora #MEMB_ON
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

; RUN: OS off; code A ($0200-$0EFF) from VRAM V_RTIMG+$0200, then RT_BOOT
starter sei
        lda #0
        sta NMIEN
        sta DMACTL
        sta IRQEN
        lda #$FE
        sta PORTB
        lda #MEMB_ON|(V_RTIMG>>14)
st_mb   sta $D65D
        ldx #2
cp_pg   txa
        clc
        adc #>(WIN+(V_RTIMG&$3FFF))
        sta cp_s+2
        stx cp_d+2
        ldy #0
cp_s    lda $FF00,y
cp_d    sta $FF00,y
        iny
        bne cp_s
        inx
        cpx #$0F
        bne cp_pg
        lda #0
st_mb0  sta $D65D
        lda vb_hi
        cmp #$D6
        beq st_go
        jsr relocate
st_go   lda vb_hi
        jmp RT_BOOT

; VBXE at $D700: the high byte of every VBXE register operand of the
; runtime becomes $D7. Entries: 0, address (RAM, code A) or MEMAC-B value,
; window address (VRAM, the code banks); a 0,0,0 entry ends the table.
relocate
        lda #<reloc
        sta rl_p+1
        lda #>reloc
        sta rl_p+2
rl_l    jsr rl_get
        tax                     ; MEMAC-B value or 0
        jsr rl_get
        sta rl_d+1
        jsr rl_get
        sta rl_d+2
        ora rl_d+1
        beq rl_x
        txa
rl_mb   sta $D65D
        lda #$D7
rl_d    sta $FFFF
        lda #0
rl_mb0  sta $D65D
        jmp rl_l
rl_x    rts
rl_get
rl_p    lda $FFFF
        inc rl_p+1
        bne rl_g1
        inc rl_p+2
rl_g1   rts
        icl '../gen/reloc.asm'
