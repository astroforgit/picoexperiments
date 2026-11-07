; ------------------------------------------------------------------
; XEX loader: VBXE detection, 4K uploads into VRAM while the file loads,
; then (RUN) the runtime is copied from VRAM into place with the OS off.
; Payload segments load at STAGE-3: a 3-byte VRAM address, then 4096 bytes.
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
message dta c'GHOSTS''N GOBLINS NEEDS VBXE FX 1.2X',0

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

; RUN: OS off; the runtime code $C300-$CFFF comes from VRAM V_RTIMG+$0300
; (the code banks stay in VRAM); then RT_BOOT
starter sei
        lda #0
        sta NMIEN
        sta DMACTL
        lda #$FE
        sta PORTB
        lda #MEMB_ON|(V_RTIMG>>14)
st_mb   sta $D65D
        ldx #>$C300
        ldy #>(WIN+(V_RTIMG&$3FFF)+$0300)
        lda #>$D000
        jsr copy_pages
        lda #0
st_mb0  sta $D65D
        lda vb_hi
        jmp RT_BOOT

; copy whole pages: destination page X, source page Y, until X = A
copy_pages
        sta cp_end
        stx cp_d+2
        sty cp_s+2
cp_pg   ldy #0
cp_s    lda $FF00,y
cp_d    sta $FF00,y
        iny
        bne cp_s
        inc cp_s+2
        inc cp_d+2
        lda cp_d+2
        cmp cp_end
        bne cp_pg
        rts
cp_end  dta 0
