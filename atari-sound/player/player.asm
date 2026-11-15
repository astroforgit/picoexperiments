; PICO music / one POKEY. MADS source. See ../FORMAT.md.
; SAP API: A=subsong -> init; call tick once per PAL video frame.
ptr = $f0
music = $4000
count = music+5
ids = music+$40
nexts = music+$80
los = music+$c0
his = music+$100

        org $2000
init    cld
        tax
        lda #3
        sta $d21f
        lda #0
        sta paused
        sta stopped
        sta delay
        cpx count
        bcc init_ok
        ldx #0
init_ok stx selected
        jmp select

select  stx current
        lda los,x
        sta ptr
        lda his,x
        sta ptr+1
        lda #0
        sta delay
        sta stopped
        ldx #8
clear   sta regs,x
        sta $d200,x
        dex
        bpl clear
        rts

tick    lda paused
        ora stopped
        bne tick_end
        lda delay
        beq record
        dec delay
        jmp write
record  jsr getbyte
        bne event
        ldx current
        lda nexts,x
        cmp #$ff
        beq stop
        tax
        jsr select
        jmp record
event   sec
        sbc #1
        sta delay
        jsr getbyte
        sta mask
        jsr getbyte
        sta mask+1
        ldx #0
decode  lsr mask+1
        ror mask
        bcc unchanged
        jsr getbyte
        sta regs,x
unchanged
        inx
        cpx #9
        bne decode
write   ldx #8
write_loop
        lda regs,x
        sta $d200,x
        dex
        bpl write_loop
tick_end
        rts
stop    lda #1
        sta stopped
silence lda #0
        sta $d201
        sta $d203
        sta $d205
        sta $d207
        rts
getbyte ldy #0
        lda (ptr),y
        inc ptr
        bne gotbyte
        inc ptr+1
gotbyte ora #0                       ; return flags for the byte, not pointer INC
        rts

paused  dta 0
stopped dta 0
delay   dta 0
mask    dta 0,0
regs    :9 dta 0
current dta 0
selected dta 0
last_console dta 7
last_key dta $ff
ntsc_phase dta 0

; Self-contained application. OS ROM stays visible for the font; no VBXE.
start   sei
        cld
        lda #0
        sta $d40e
        sta $d400
        sta $d20e
        sta $d01d
        sta $d003
        sta $d002
        sta $d001
        sta $d000
        lda #$e0
        sta $d409
        lda #2
        sta $d401
        lda #<dlist
        sta $d402
        lda #>dlist
        sta $d403
        lda #$0e
        sta $d018
        lda #$82
        sta $d017
        lda #0
        sta $d01a
        ldx #39
title_loop
        lda music+8,x
        sta screen+120,x
        dex
        bpl title_loop
        lda #$22
        sta $d400
        lda #0
        jsr init
wait_leave
        lda $d40b
        cmp #124
        beq wait_leave
wait_frame
        lda $d40b
        cmp #124
        bne wait_frame
        ; NTSC: omit one tick in six. PAL files remain PAL-tuned.
        lda $d014
        and #14
        bne do_tick
        inc ntsc_phase
        lda ntsc_phase
        cmp #6
        bne do_tick
        lda #0
        sta ntsc_phase
        jmp controls
do_tick jsr tick
controls
        ; OS IRQs are disabled: poll POKEY's physical key state and scan code.
        lda $d20f
        and #4                      ; SKSTAT bit 2: zero while a key is held
        beq key_down
        lda #$ff
        sta last_key
        jmp console_keys
key_down
        lda $d209
        and #$3f                    ; accept lowercase and Shift+N/P equally
        cmp last_key
        beq console_keys
        sta last_key
        cmp #$23                    ; N
        beq forward
        cmp #$0a                    ; P
        beq backward
        cmp #$21                    ; Space
        beq toggle
console_keys
        lda $d01f
        and #7
        cmp last_console
        bne console_changed
        jmp draw
console_changed
        sta last_console
        cmp #6
        beq toggle
        cmp #5
        beq forward
        cmp #3
        beq backward
        jmp draw
toggle  lda paused
        eor #1
        sta paused
        beq resume
        jsr silence
        jmp draw
resume  lda stopped
        beq draw
        ldx selected
        jsr select
        jmp draw
forward ldx selected
        inx
        cpx count
        bcc choose
        ldx #0
        beq choose
backward
        ldx selected
        bne prev
        ldx count
prev    dex
choose  stx selected
        jsr select
        lda #0
        sta paused
draw    ldx current
        lda ids,x
        lsr
        lsr
        lsr
        lsr
        tax
        lda hex,x
        sta screen+295
        ldx current
        lda ids,x
        and #15
        tax
        lda hex,x
        sta screen+296
        lda paused
        ora stopped
        tax
        lda status,x
        sta screen+316
        ldx #0
meter_loop
        lda regs+1,x
        and #15
        tay
        lda hex,y
        sta screen+377,x
        inx
        inx
        cpx #8
        bne meter_loop
        jmp wait_leave
hex     dta d'0123456789ABCDEF'
status  dta d'>-'
dlist   dta $70,$70,$70,$42,a(screen)
        :23 dta 2
        dta $41,a(dlist)
screen
        dta d'                                        '
        dta d'          PICO / POKEY MUSIC            '
        dta d'                                        '
        dta d'                                        '
        dta d'                                        '
        dta d'       FOUR VOICES - ATARI 8-BIT        '
        dta d'                                        '
        dta d'       PATTERN 00                    >  '
        dta d'                                        '
        dta d'       VOLUME    0 0 0 0                '
        dta d'                                        '
        dta d'       SPACE : PAUSE / RESUME           '
        dta d'       N     : NEXT PATTERN             '
        dta d'       P     : PREVIOUS PATTERN         '
        dta d'                                        '
        dta d'       LOAD ANOTHER GAME XEX TO CHANGE  '
        dta d'       MUSIC. RESET TO LEAVE PLAYER.    '
        dta d'                                        '
        dta d'       PAL TUNING / NTSC TEMPO ADAPTED  '
        :200 dta 0
        ert * > $3000
