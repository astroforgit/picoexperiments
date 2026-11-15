; Native wrapper for the selected ASMA Type B originals. Constants supplied by builder.
        org $2000
start   sei
        cld
        lda #0
        sta $d40e
        sta $d20e
        sta $d400
        sta $d01d
        sta $d000
        sta $d001
        sta $d002
        sta $d003
        lda #$e0
        sta $d409
        lda #2
        sta $d401
        lda #<dlist
        sta $d402
        lda #>dlist
        sta $d403
        lda #$0e
        sta $d017
        lda #$82
        sta $d018
        lda #0
        sta $d01a
        lda #$22
        sta $d400
        lda #3
        sta $d21f
        jsr restart
leave   lda $d40b
        cmp #124
        beq leave
frame   lda $d40b
        cmp #124
        bne frame
        lda paused
        bne keys
        jsr SOURCE_PLAYER
        sei
keys    lda $d20f
        and #4
        beq held
        lda #$ff
        sta last_key
        jmp leave
held    lda $d209
        and #$3f
        cmp last_key
        beq leave
        sta last_key
        cmp #$23
        beq next
        cmp #$0a
        beq previous
        cmp #$21
        bne leave
        lda paused
        eor #1
        sta paused
        beq resume
        ; Save/restore POKEY state is the source routine's responsibility.
        ; It restores its voices on the next tick after resume.
        lda #0
        sta $d201
        sta $d203
        sta $d205
        sta $d207
resume  jmp leave
next    inc song
        lda song
        cmp #SOURCE_SONGS
        bcc picked
        lda #0
        sta song
        beq picked
previous
        lda song
        bne decrement
        lda #SOURCE_SONGS
        sta song
decrement
        dec song
picked  jsr restart
        jmp leave
restart lda #0
        sta paused
        ; Some SAP routines (including Commando) never write AUDCTL. Do not
        ; inherit the disk/OS clock and channel-join settings on real hardware.
        ldx #8
reset_pokey
        sta $d200,x
        dex
        bpl reset_pokey
        lda song
        ldx #0
        ldy #0
        jsr SOURCE_INIT
        sei
        rts
song    dta 0
paused  dta 0
last_key dta $ff
dlist   dta $70,$70,$70,$42,a(screen)
        :23 dta 2
        dta $41,a(dlist)
screen  ins 'screen.bin'
        ert * >= $2f00
