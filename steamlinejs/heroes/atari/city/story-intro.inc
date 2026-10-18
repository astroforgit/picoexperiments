; Two preloaded 320x200 pictures occupy the front/back buffers only at boot.
; Gameplay replaces them after the story; no permanent graphics allocation.
.proc story_intro
        mva #0 front_bank
        mva #1 back_bank
        jsr enable_display
        jsr wait_action
        jsr present_back_buffer
        jsr wait_action
        ; Reuse the relocated startup display reset before painting both buffers.
        jsr loader_init
        mva #$FF CH
        rts

.proc wait_action
        ; Require two released frames before accepting a fresh press. Holding
        ; Fire/Enter/Space cannot skip either page or open a city popup.
        ldx #2
release
        jsr wait_frame
        jsr pressed
        bne wait_action
        dex
        bne release
press
        jsr wait_frame
        jsr pressed
        beq press
        ldx #2
finish
        jsr wait_frame
        jsr pressed
        bne held
        dex
        bne finish
        rts
held    ldx #2
        bne finish
.endp

.proc pressed
        lda STRIG0
        and #1
        beq yes
        lda SKSTAT
        and #4
        bne no
        lda KBCODE
        and #$3F
        cmp #12
        beq yes
        cmp #33
        beq yes
no      lda #0
        rts
yes     lda #1
        rts
.endp
.endp
