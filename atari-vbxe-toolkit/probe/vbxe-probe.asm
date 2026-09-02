; Minimal Atari XL/XE VBXE presence probe for MADS.

SDMCTL = $022F
SDLSTL = $0230
COLOR1 = $02C5
COLOR2 = $02C6
COLOR4 = $02C8
CHBAS  = $02F4
DMACTL = $D400

src = $CB
dst = $CD

        org $2000

.proc main
        lda #0
        sta SDMCTL
        sta DMACTL
        ldx #0
?clear  sta text_screen,x
        sta text_screen+$100,x
        sta text_screen+$200,x
        sta text_screen+$300,x
        inx
        bne ?clear

        lda #<display_list
        sta SDLSTL
        lda #>display_list
        sta SDLSTL+1
        lda #$E0
        sta CHBAS
        lda #$0E
        sta COLOR1
        lda #$82
        sta COLOR2
        lda #0
        sta COLOR4
        lda #$22
        sta SDMCTL
        sta DMACTL

        mwa #title src
        mwa #text_screen+5*40+11 dst
        jsr copy_text

        lda $D640
        cmp #$10
        beq ?d600
        lda $D740
        cmp #$10
        beq ?d700

        mwa #not_found src
        mwa #text_screen+10*40+9 dst
        jsr copy_text
        jmp *

?d600  mwa #found src
        mwa #text_screen+9*40+10 dst
        jsr copy_text
        mwa #at_d600 src
        jmp ?address

?d700  mwa #found src
        mwa #text_screen+9*40+10 dst
        jsr copy_text
        mwa #at_d700 src

?address
        mwa #text_screen+11*40+10 dst
        jsr copy_text
        jmp *
.endp

.proc copy_text
        ldy #0
        lda (src),y
        tax
        beq ?done
?loop   iny
        lda (src),y
        dey
        sta (dst),y
        iny
        dex
        bne ?loop
?done   rts
.endp

title     dta 16,d'ATARI VBXE PROBE'
found     dta 16,d'VBXE FX DETECTED'
at_d600   dta 16,d'REGISTERS AT D600'
at_d700   dta 16,d'REGISTERS AT D700'
not_found dta 17,d'VBXE NOT DETECTED'

display_list
        dta $42,a(text_screen)
        :24 dta $02
        dta $41,a(display_list)

        org $3000
text_screen
        :1024 dta 0

        run main

