; ------------------------------------------------------------------
; Loader: VBXE detection, 4K uploads into VRAM while the XEX loads,
; then (RUN) the RAM images are copied into place with the OS off.
; Payload segments load at $7FFD: a 3-byte VRAM address, then 4096 bytes.
; ------------------------------------------------------------------
SAVMSC  = $58
PORTB   = $D301
NMIEN   = $D40E
DMACTL  = $D400
STAGE   = $8000

        org $9000
vb_hi   dta 0                   ; $D6/$D7, 0 = not found
up_ptr  dta a(0)

; INIT: find an FX 1.2x core
detect  lda #$D6
        jsr probe
        bcs found
        lda #$D7
        jsr probe
        bcs found
        ; no VBXE: message on the OS screen and stop
        ldy #0
msg_l   lda message,y
        beq msg_h
        sec
        sbc #32                 ; ATASCII -> screen code (upper case/digits)
        sta (SAVMSC),y
        iny
        bne msg_l
msg_h   jmp msg_h
found   sta vb_hi
        sta up_mb+2
        sta up_mb0+2
        sta st_mb+2
        sta st_mb2+2
        sta st_mb3+2
        sta st_mc+2
        sta st_ms+2
        sta st_ms2+2
        sta st_mc2+2
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
message dta c'VBXE FX 1.2X NOT FOUND AT D600 OR D700',0

; INIT after each payload: copy STAGE..+4095 to VRAM at (STAGE-3), 4K aligned
upload  lda STAGE-2               ; read the descriptor before the window hides it
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
        sta up_b                ; address bits 14-15
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
up_d    dta 0,0,0
up_b    dta 0

; RUN: OS off, copy the runtime image and bank 7 from VRAM, start
starter sei
        lda #0
        sta NMIEN
        sta DMACTL
        lda #$FE
        sta PORTB
        ; runtime: VRAM $40000.. -> $0A00..$3FFF (MEMAC-B bank 16)
        lda #$80|16
st_mb   sta $D65D
        ldx #>$0A00
        ldy #>($4000+$0A00)
        lda #>$4000
        jsr copy_pages          ; $0A00-$3FFF
        ; bank 7: VRAM $44000.. -> $C000..$FFFF without $D000-$D7FF
        lda #$80|17
st_mb2  sta $D65D
        ldx #>$C000
        ldy #>$4000
        lda #>$D000
        jsr copy_pages
        ldx #>$D800
        ldy #>$5800
        lda #>$0000
        jsr copy_pages
        lda #0
st_mb3  sta $D65D
        ; services: VRAM $48000.. -> $4000..$4FFF through a 4K MEMAC-A window
        ; at $A000 (this code runs at $9xxx)
        lda #$A8
st_mc   sta $D65E
        lda #$80|($48000>>12)
st_ms   sta $D65F
        ldx #>$4000
        ldy #>$A000
        lda #>$5000
        jsr copy_pages
        lda #0
st_ms2  sta $D65F
st_mc2  sta $D65E
        lda vb_hi
        jmp RT_START

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
