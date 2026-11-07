; ------------------------------------------------------------------
; Ghosts'n Goblins Arcade for Atari XL/XE + VBXE: runtime that runs the
; original C64 program. Assembled as images of $C300-$CFFF, $E000-$EFFF
; (code) and $DC10-$DFFF (variables, no data); the build merges them into
; the RAM image of the C64 program at its entry point.
; ------------------------------------------------------------------
        icl 'defs.asm'
        icl 'render-defs.asm'
        icl '../gen/entry.asm'          ; ENTRY_A/X/Y/SP/P/PC

; code banks (4K each, VRAM, mapped at $E000 by MEMAC-A)
BK_INIT = $80|$7A
BK_IDLE = $80|$7B
BK_SPLIT = $80|$7C
BK_COMP = $80|$7D
BK_SPR  = $80|$7F

; ---- variables --------------------------------------------------
        org $DC10
vb_page   .ds 1         ; $D6 or $D7
memb_sh   .ds 1         ; MEMAC-B value the running code expects
nmi_busy  .ds 1
nmi_p     .ds 1         ; P of the context the NMI interrupted
vframe    .ds 2
ntsc      .ds 1         ; 1 = NTSC machine
tick_ph   .ds 1         ; NTSC: 5 game ticks in 6 frames
in_chain  .ds 1         ; running the game's IRQ chain
cur_lo    .ds 1         ; raster line of the IRQ being run
cur_hi    .ds 1
prev_lo   .ds 1
prev_hi   .ds 1
nsplit    .ds 1
rv        .ds 1         ; value computed by a read stub
joy2      .ds 1         ; C64 joystick port 2 (active low, bit 4 = fire)
key_pa    .ds 1         ; held key: column bit (DC00 line), 0 = none
key_pb    .ds 1         ; row mask (DC01 bits cleared)
shift_on  .ds 1
last_key  .ds 1
kq        .ds 1         ; GETIN queue (one key)
col_dirty .ds 1         ; colour RAM written
col_run   .ds 1         ; a colour pass is running
cs_dirty  .ds 1         ; a charset was rewritten by the game
anim_dirty .ds 1        ; bits 0/1: chars $FA/$FB, $FC/$FD swapped
gs_x      .ds 1         ; stub scratch
gs_a      .ds 1
iw_v      .ds 1
iw_x      .ds 1
iw_y      .ds 1
map_lo    .ds 1         ; playfield map pointer of the last draw ($3855)
map_hi    .ds 1
drops     .ds 1
ticks     .ds 1
mema_sh   .ds 1         ; MEMAC-A bank the running code expects
idle_ran  .ds 1         ; the game's frame wait did renderer work
in_idle   .ds 1         ; the main context is inside idle_step
ex_left   .ds 1         ; tile expansions left for this idle step
c64_nmi   .ds 2         ; where the game's stores to its NMI vector go
spr_ptag  .ds 8         ; pointer held by sprite cache slots 192-199
sc_flush  .ds 1         ; the sprite blit cache is stale
co_state  .ds 1         ; 1: the renderer is suspended (its NMI frame at co_sp)
co_sp     .ds 1
co_gsp    .ds 1         ; the game's stack pointer in co_run
co_pre    .ds 1         ; the renderer may be suspended (the game's frame wait)
        icl 'vars-rows.asm'
        .print 'vars DC: ', *
        ert * > $DD00

        org $DD10
        icl 'vars-render.asm'
        icl 'vars-rec.asm'
row_dmd   .ds 25        ; (renderer row state, with row_dcs in code A)
        .print 'vars DD: ', *
        ert * > $DE00

        org $DE40
        icl 'vars-sound.asm'
        icl 'vars-loader.asm'
ready     .ds 1         ; list composed and waiting for the NMI ($FF none)
shown     .ds 1         ; framebuffer on screen
rdy_lo    .ds 1         ; its start address
rdy_mid   .ds 1
rdy_hi    .ds 1
log_w     .ds 1         ; IRQ chain log the NMI writes
log_n     .ds 1
log_on    .ds 1         ; $FF: this frame is not recorded
log_cnt   .ds 2         ; records per log
log_ri    .ds 1         ; newest complete log
log_new   .ds 1
log_busy  .ds 1         ; log the main context reads ($FF none)
zp_save   .ds 26
row_anim  .ds 25
row_edge  .ds 25        ; 1: columns 38-39 came in from the right, 2: 0-1 from the left
sq_on     .ds 1         ; a scroll of the game waits for the renderer's step
sq_x      .ds 1         ; (its map pointer)
sq_y      .ds 1
        .print 'vars DE: ', *
        ert * > $DF00

        org $DF20
        icl 'vars-split.asm'
row_force .ds 25
row_prio  .ds 25
        .print 'vars DF: ', *
        ert * > $E000

; ---- code A -----------------------------------------------------
        org $C300
; RT_BOOT: entered from the XEX starter with the OS off, A = VBXE page.
; Copies the C64 RAM image from VRAM staging, sets up VBXE and POKEY, then
; enters the game at its entry point with the C64 CPU state.
rt_boot
        sei
        cld
        ldx #$FF
        txs
        pha                     ; VBXE page
        cmp #$D6
        beq rb_rel_done
        jsr vbx_relocate
rb_rel_done
        ; RAM image pages 2..$FF (not the runtime, not I/O), VRAM V_STAGE.
        ; Pages $DC-$DF hold the initial variables and chip shadows.
        lda #2
        sta rb_pg
rb_pg_l lda rb_pg
        cmp #$C3
        bcc rb_copy
        cmp #$D0
        bcc rb_next             ; runtime code A
        cmp #$D8
        bcc rb_next             ; Atari I/O
        cmp #$E0
        bcc rb_copy             ; colour RAM, CIA RAM, variables
        cmp #$F0
        bcc rb_next             ; MEMAC-A window
rb_copy lda rb_pg
        tax
        jsr stage_page
rb_next inc rb_pg
        bne rb_pg_l
        pla
        sta vb_page
        ; pages 0 and 1 wait in $0400-$05FF (the stack is in use)
        lda #0
        ldx #>$0400
        jsr stage_page
        lda #1
        ldx #>$0500
        jsr stage_page
        jsr pal_detect
        lda #$E8                ; MEMAC-A: 4K at $E000, CPU access
vm_c1   sta VBX+VB_MEMC
        jsr t_gfx_init
        jsr t_pal_fixed
        jsr t_snd_init
        jsr t_render_init
        jsr t_input_init
        ; pages 0 and 1 into place (no stack use from here)
        ldx #0
rb_zp   lda $0400,x
        sta $0000,x
        lda $0500,x
        sta $0100,x
        inx
        bne rb_zp
        lda #<nmi
        sta $FFFA
        lda #>nmi
        sta $FFFB
        lda #$40
        sta NMIEN
        ldx #ENTRY_SP
        txs
        lda #ENTRY_P
        pha
        lda #ENTRY_A
        ldx #ENTRY_X
        ldy #ENTRY_Y
        plp
        jmp ENTRY_PC
rb_pg   dta 0

; copy RAM image page A (VRAM V_STAGE + A*256) to page X, through the
; bounce buffer $1A00 (the destination may be under the window)
stage_page
        pha
        lsr
        lsr
        lsr
        lsr
        lsr
        lsr                     ; 16K bank of the page
        ora #MEMB_ON|(V_STAGE>>14)
        sta sp_mb+1
        pla
        and #$3F
        ora #>WIN
        sta sp_src+2
        stx sp_dst+2
sp_mb   lda #0
vm_2    sta VBX+VB_MEMB
        ldy #0
sp_src  lda WIN,y
        sta $1A00,y
        iny
        bne sp_src
        lda #0
vm_3    sta VBX+VB_MEMB
sp_cp   lda $1A00,y
sp_dst  sta $0000,y
        iny
        bne sp_cp
        rts

; MEMAC-B: A = value (also kept in memb_sh)
vbx_memb_a
        sta memb_sh
vbx_memb
        lda memb_sh
vm_1    sta VBX+VB_MEMB
        rts

; patch the high byte of every VBXE register operand to $D7. Entries are
; (address, MEMAC-A bank or 0); the MEMAC-A operands used here go first.
vbx_relocate
        lda #$D7
        sta vr_mc+2
        sta vr_ms+2
        lda #$E8
vr_mc   sta $D65E               ; MEMAC-A: 4K at $E000
        lda #<vbx_reloc
        sta ZP
        lda #>vbx_reloc
        sta ZP+1
vr_l    ldy #2
        lda (ZP),y
vr_ms   sta $D65F               ; the operand's bank (0: RAM)
        dey
        lda (ZP),y
        beq vr_done
        sta ZP+3
        dey
        lda (ZP),y
        sta ZP+2
        lda #$D7
        sta (ZP+2),y
        lda ZP
        clc
        adc #3
        sta ZP
        bcc vr_l
        inc ZP+1
        bne vr_l
vr_done rts

pal_detect
        lda PAL
        and #$0E
        cmp #$0E                ; GTIA: 1 = PAL, 15 = NTSC
        bne pd_pal
        lda #1
        sta ntsc
        rts
pd_pal  lda #0
        sta ntsc
        rts

; ------------------------------------------------------------------
; NMI: vertical blank. Input, one C64 frame (IRQ chain, sound) and the
; composition of the next picture.
; ------------------------------------------------------------------
nmi     pha
        txa
        pha
        tya
        pha
        bit NMIST
        sta NMIRES
        cld
        lda nmi_busy
        bne nmi_out
        inc nmi_busy
        tsx
        lda $0104,x
        sta nmi_p
        lda memb_sh
        pha
        lda mema_sh
        pha
        lda rv                  ; the game's IRQ handlers use the read stubs too
        pha
        lda #0
        jsr vbx_memb_a
        jsr vbi_work
        jsr raster_sync
        dec nmi_busy
        jsr co_check            ; (does not return when it suspends)
nmi_tail
        pla
        sta rv
        pla
        jsr mema_set
        pla
        jsr vbx_memb_a
nmi_out pla
        tay
        pla
        tax
        pla
        rti

vbi_work
        ; first, while the beam is in the vertical blank: show the finished
        ; picture and start the next list. The XDL address takes effect at the
        ; next frame and the list draws into the framebuffer this frame showed:
        ; done later, the rest of this frame would show it being drawn
        jsr nmi_display
        lda #0                  ; (the XDL went through the MEMAC-B window:
        jsr vbx_memb_a          ; the game's handlers run under it)
        inc vframe
        bne vw_0
        inc vframe+1
vw_0    lda vframe              ; a colour pass every 32 frames (writes the
        and #31                 ; stubs do not see)
        bne vw_1
        dec col_dirty
vw_1    jsr t_read_input
        lda ntsc
        beq vw_tick
        ldx tick_ph
        inx
        cpx #6
        bcc vw_2
        ldx #0
vw_2    stx tick_ph
        cpx #5
        beq vw_notick           ; NTSC: skip one tick in six
vw_tick lda nmi_p
        and #$04
        bne vw_sei              ; the game is in a SEI section: no IRQ now
        inc ticks
        jsr run_chain
vw_sei
vw_notick
        jsr t_snd_frame         ; sound effects (the music comes later)
        ; no frame wait of the game did renderer work: do some here
        lda idle_ran
        beq vw_idle
        lda #0
        sta idle_ran
        rts
vw_idle lda in_idle
        ora co_state            ; (not while the renderer is suspended)
        bne vw_ix
        ldx #15
vw_s    lda ZP,x
        sta zp_save,x
        dex
        bpl vw_s
        ldx #9
vw_s2   lda ZPX,x
        sta zp_save+16,x
        dex
        bpl vw_s2
        lda #4
        sta ex_left
        jsr t_idle_step
        ldx #15
vw_r    cpx #4                  ; (not upd_ptr: renderer state, $44/$45)
        beq vw_r1
        cpx #5
        beq vw_r1
        lda zp_save,x
        sta ZP,x
vw_r1   dex
        bpl vw_r
        ldx #9
vw_r2   lda zp_save+16,x
        sta ZPX,x
        dex
        bpl vw_r2
vw_ix   rts

; ------------------------------------------------------------------
; The game's raster IRQ chain, run in raster order. After each handler
; the renderer records the VIC state for the lines from there on.
; ------------------------------------------------------------------
run_chain
        jsr t_split_begin
        lda VIC+$1A
        and #1
        beq rc_done
        lda #0
        sta nsplit
        lda #$FF
        sta prev_lo
        sta prev_hi
rc_loop lda VIC+$11
        asl
        lda #0
        rol
        sta cur_hi
        lda VIC+$12
        sta cur_lo
        ; stop at line 312 or later, or at or above the previous line
        lda cur_hi
        beq rc_1
        lda cur_lo
        cmp #<312
        bcs rc_done
rc_1    lda prev_hi
        bmi rc_go               ; first handler
        lda cur_hi
        cmp prev_hi
        bcc rc_done
        bne rc_go
        lda cur_lo
        cmp prev_lo
        bcc rc_done
        beq rc_done
rc_go   lda #1
        sta in_chain
        jsr call_irq
        lda #0
        sta in_chain
        jsr t_split_take
        lda cur_lo
        sta prev_lo
        lda cur_hi
        sta prev_hi
        inc nsplit
        lda nsplit
        cmp #20
        bcc rc_loop
rc_done jmp t_split_end

; call the game's IRQ handler as an interrupt; it returns here with RTI
call_irq
        lda #>ci_ret
        pha
        lda #<ci_ret
        pha
        lda #$24
        pha
        lda $01
        and #$02
        beq ci_hw
        pha                     ; KERNAL entry: A, X, Y on the stack
        pha
        pha
        jmp ($0314)
ci_hw   jmp ($FFFE)
ci_ret  rts

; KERNAL IRQ exits ($EA31, $EA81, $FEBC): restore Y, X, A and return
k_exit  pla
        tay
        pla
        tax
        pla
        rti

; ------------------------------------------------------------------
; Wait for the next frame ($3AB4), doing renderer work meanwhile
; ------------------------------------------------------------------
idle_wait
        php
        stx iw_x
        sty iw_y
        lda $0700
        sta iw_v
iw_l    lda #1
        sta co_pre
        jsr co_run
        lda #0
        sta co_pre
        lda $0700
        cmp iw_v
        beq iw_l
        ldx iw_x
        ldy iw_y
        plp
        lda iw_v
        cmp $0700
        rts

; The renderer runs as a coroutine on its own stack (CO_TOP down), so that
; the game gets the CPU as soon as its frame begins: when the game's frame
; counter changes while a renderer step runs from the frame wait, the NMI
; leaves its own stack frame on the renderer's stack (co_check) and returns
; to the game; the next co_run resumes it with the NMI's exit code.
CO_TOP  = $A8
co_run  tsx
        stx co_gsp
        lda co_state
        bne cr_res
        ldx #CO_TOP
        txs
        lda #6                  ; (tile expansions per step: a row with
        sta ex_left             ; more new tiles goes on in the next one)
        lda #1
        sta idle_ran
        sta in_idle
        jsr t_idle_step
        lda #0
        sta in_idle
        lda sq_on               ; a scroll during the step
        beq cr_x
        lda #0
        sta sq_on
        lda #BK_SPLIT
        jsr mema_set
        ldx sq_x
        ldy sq_y
        jsr scroll_notify
cr_x    ldx co_gsp
        txs
        rts
cr_res  lda #0
        sta co_state
        lda #1
        sta in_idle
        sta idle_ran
        ldx co_sp
        txs
        jmp nmi_tail

; NMI end: suspend the renderer when the game's frame has begun
co_check
        lda co_pre
        and in_idle
        beq cc_x
        lda $0700
        cmp iw_v
        beq cc_x
        pla                     ; (co_check's return address)
        pla
        tsx
        stx co_sp
        lda #1
        sta co_state
        lsr
        sta in_idle
        jsr vbx_memb_a          ; MEMAC-B off for the game
        ldx co_gsp
        txs
        rts                     ; from co_run
cc_x    rts


; playfield draw ($3855 jumps here instead of $00D0)
hook_scroll
        lda $D3
        pha
        lda $D4
        pha
        jsr $00D0
        pla
        tay
        pla
        tax                     ; X/Y = map pointer of this draw
        lda co_state            ; the renderer is suspended (maybe composing a
        beq hs_now              ; picture): its step ends with the scroll
        stx sq_x                ; state it began with (co_run applies it)
        sty sq_y
        sta sq_on
        rts
hs_now  lda #BK_SPLIT
        jsr mema_set
        jmp scroll_notify

; memory block swap ($5BCA), used for charsets: mark them dirty first
hook_swap
        jsr cs_mark
        ldy #0
        ldx $5BC9
        jmp $5BCF

; row fill ($3341: LDA $xxxx,X / STA ($FB),Y; the game sets the LDA operand
; at $3328/$332E): its stores to colour RAM mark it
hook_colfill
hc_op   lda $FD78,x
        sta ($FB),y
        pha
        lda $FC
        and #$FC
        cmp #$D8
        bne hc_1
        sta col_dirty
hc_1    pla
        jmp $3346

; KERNAL calls of the menu (bank SPLIT; A, X, Y, P pass through)
k_chrout
        jsr t_co_abort
        pha
        lda #BK_SPLIT
        jsr mema_set
        pla
        jmp kb_chrout
k_plot  jsr t_co_abort
        pha
        php
        lda #BK_SPLIT
        jsr mema_set
        plp
        pla
        jmp kb_plot
k_getin lda #BK_SPLIT
        jsr mema_set
        jmp kb_getin
k_scnkey
        rts
        icl 'stubs-rt.asm'
        icl '../gen/stubs.asm'
        icl 'loader.asm'
        icl 'render-ram.asm'

; ---- MEMAC-A bank switch and the entry points of the banks
mema_set
        sta mema_sh
vm_a1   sta VBX+VB_MEMS
        rts
t_gfx_init
        lda #BK_INIT
        jsr mema_set
        jmp gfx_init
t_pal_fixed
        lda #BK_COMP
        jsr mema_set
        jmp pal_fixed
t_snd_init
        lda #BK_SPLIT
        jsr mema_set
        jmp snd_init
t_render_init
        lda #BK_IDLE
        jsr mema_set
        jmp render_init
t_idle_step
        lda #BK_IDLE
        jsr mema_set
        jmp idle_step
t_co_abort                      ; (A, X, Y, P kept)
        php
        pha
        lda #BK_SPLIT
        jsr mema_set
        pla
        jsr co_abort
        plp
        rts
t_render_loaded
        lda #BK_IDLE
        jsr mema_set
        jmp render_loaded
t_split_begin
        lda #BK_SPLIT
        jsr mema_set
        jmp split_begin
t_split_take
        lda #BK_SPLIT
        jsr mema_set
        jmp split_take
t_split_end
        lda #BK_SPLIT
        jsr mema_set
        jmp split_end
t_snd_frame
        lda #BK_SPLIT
        jsr mema_set
        jmp snd_frame
t_xdl   lda #BK_SPLIT
        jsr mema_set
        jmp xdl_write
t_read_input
        lda #BK_SPLIT
        jsr mema_set
        jmp read_input
t_input_init
        lda #BK_SPLIT
        jsr mema_set
        jmp input_init
; main context, from bank IDLE: rows_state in bank SPLIT
far_rows
        lda #BK_SPLIT
        jsr mema_set
        jsr rows_state
        lda #BK_IDLE
        jmp mema_set

; main context, from bank IDLE: sprite blits in bank COMP
far_sbegin
        lda #BK_COMP
        jsr mema_set
        jsr spr_begin
        lda #BK_IDLE
        jmp mema_set
far_emit
        lda #BK_SPR
        jsr mema_set
        jsr spr_emit
        lda #BK_IDLE
        jmp mema_set

; main context, from bank IDLE: compose_list in bank COMP
far_compose
        lda #BK_COMP
        jsr mema_set
        jsr compose_list
        lda #BK_IDLE
        jmp mema_set

; NMI: show the picture the blitter finished, start the next ready list
nmi_display
        lda pending
        beq nd_1
nd_b1   lda VBX+VB_BLIT
        bne nd_x                ; still drawing
        lda run
        sta shown
        jsr show_fb
        lda #0
        sta pending
nd_1    lda ready               ; (nothing draws now. Its framebuffer can be
        bmi nd_x                ; the one on screen only after a race with
                                ; list_get: then it draws there, once)
nd_b2   lda VBX+VB_BLIT
        bne nd_x
        sta run                 ; (A = 0 here: overwritten below)
        lda ready
        sta run
        lda rdy_lo
        ldx rdy_mid
        ldy rdy_hi
        jsr blit_start
        lda #$FF
        sta ready
        lda #1
        sta pending
nd_x    ldx shown               ; the picture on screen, its playfield moved
        jmp t_xdl               ; by the scroll since it was composed

; per char row, renderer state shared by the banks (RAM)
row_dcs   .ds 25                ; what the char layer row was drawn with

vbx_reloc                       ; the build appends the operand table here:
                                ; (address, MEMAC-A bank or 0) per operand
        .print 'code A end: ', *
        ert * > $D000

; ---- code banks ---------------------------------------------------
        org $E000
bank_init
        icl 'bank-init.asm'
        .print 'bank INIT end: ', *
        ert * > $F000
        org $E000
bank_idle
        icl 'bank-idle.asm'
        .print 'bank IDLE end: ', *
        ert * > $F000
        org $E000
bank_split
        icl 'bank-split.asm'
        icl 'sound.asm'
        icl 'input.asm'
        icl 'kernal.asm'
        .print 'bank SPLIT end: ', *
        ert * > $F000
        org $E000
bank_comp
        icl 'bank-comp.asm'
        .print 'bank COMP end: ', *
        ert * > $F000
        org $E000
bank_spr
        icl 'bank-spr.asm'
        .print 'bank SPR end: ', *
        ert * > $F000
