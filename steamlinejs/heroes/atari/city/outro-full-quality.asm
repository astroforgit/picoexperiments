; Stream one gallery picture at a time from D1 into the existing screen buffers.
        icl 'generated/outro-full-quality-symbols.inc'
        org $2000
        ins 'generated/outro-full-quality-core.bin'
        org $B800
.proc viewer_prepare
        mva #61 upload_index
        rts
.endp
.local full_outro
.proc start
        cld
        lda hardware_ok
        bne ready
        jmp main
ready   jsr setup_antic
        jsr setup_xdl
        jsr blit_init
        jsr load_city_palette
        mva #0 front_bank
        sta page
        sta render_bank
        mva #1 back_bank
        jsr draw
        jsr enable_display
next    jsr wait_action
        lda load_ok
        beq retry
        inc page
        lda page
        cmp #GALLERY_COUNT
        bcc retry
        mva #0 page
retry   mva back_bank render_bank
        jsr draw
        jsr present_back_buffer
        jmp next
.endp
.proc draw
        mva #0 load_ok
        lda page
        clc
        adc #4
        jsr story_load
        bcc failed
        mva #1 load_ok
        mwa #s_next text_src
        mwa #NEXT_X text_x
        lda page
        cmp #[GALLERY_COUNT-1]
        bne footer
        mwa #s_replay text_src
        mwa #REPLAY_X text_x
        jmp footer
failed  mwa #s_retry text_src
        mwa #RETRY_X text_x
footer  mva #190 text_y
        jsr draw_text
        jmp wait_blit
.endp
.proc wait_action
        ldx #2
release jsr wait_frame
        jsr pressed
        bne wait_action
        dex
        bne release
press   jsr wait_frame
        jsr pressed
        beq press
        ldx #2
finish  jsr wait_frame
        jsr pressed
        bne held
        dex
        bne finish
        mva #$FF ch
        rts
held    ldx #2
        bne finish
.endp
.proc pressed
        lda strig0
        and #1
        beq yes
        lda skstat
        and #4
        bne no
        lda kbcode
        and #$3f
        cmp #12
        beq yes
        cmp #33
        beq yes
no      lda #0
        rts
yes     lda #1
        rts
.endp
page dta 0
load_ok dta 0
s_next dta c'FIRE / ENTER / SPACE: NEXT PAGE',0
s_replay dta c'FIRE / ENTER / SPACE: REPLAY',0
s_retry dta c'FIRE: RETRY STORY DISK',0
.endl
        ert *> $C000
        ini loader_init
        ini viewer_prepare
        icl 'generated/outro-full-quality-uploads.inc'
        org $6000
        ins 'generated/outro-full-quality-runtime.bin'
        org $A000
        ins 'generated/outro-full-quality-ui.bin'
        run full_outro.start
