; Curse of the Lich King (Johan Peitz / Gruber, PICO-8) - Atari XL/XE + VBXE port
; MADS 2.x.  See README.md for the design.
;
; The OS ROM is switched off once the program has loaded: the game runs
; its own NMI (vertical blank) handler and uses the RAM under the ROM.
; World coordinates are pixels (tile * 8), 16 bit; the screen is the
; 128x128 PICO-8 screen drawn into VBXE framebuffers by the blitter.

; ------------------------------------------------------------ hardware
TRIG0   = $d010
COLPF2  = $d018
COLBK   = $d01a
PRIOR   = $d01b
GRACTL  = $d01d
CONSOL  = $d01f
PAL     = $d014
AUDF1   = $d200
AUDC1   = $d201
POT0    = $d200
AUDCTL  = $d208
KBCODE  = $d209
RANDOM  = $d20a
POTGO   = $d20b
IRQEN   = $d20e
SKSTAT  = $d20f
SKCTL   = $d20f
PORTA   = $d300
PORTB   = $d301
DMACTL  = $d400
NMIEN   = $d40e
NMIST   = $d40f
NMIRES  = $d40f
SDMCTL  = $022f             ; OS shadows (only while the OS is on)
NOCLIK  = $02db
MEMW    = $9000             ; MEMAC window (4K)

; VBXE register offsets from the detected base ($d600 or $d700)
VB_VCTL = $40
VB_XDL0 = $41
VB_CSEL = $44
VB_PSEL = $45
VB_CR   = $46
VB_BLAD = $50
VB_BLIT = $53
VB_MEMC = $5e
VB_BANK = $5f

; ------------------------------------------------------------ VRAM map
; $00000 / $04000 / $30000  framebuffers 128x128 (stride 128)
; $08000 title background 128x128
; $0c000 font masks (glyph g at +g*4, stride 512)   $0d000/$0d400/$0d800 XDLs
; $0f000 blitter list
; $10000 sprite sheet, $14000 lit (14->1), $18000 dark (dpal), $1c000 flash (lpal)
; $20000 text cache, 32 slots of 256x8
; $40000 level map baked with fog, 1024x256
VR_TITLE = $08000
VR_FONT  = $0c000
VR_SHEET = $10000
VR_TEXT  = $20000
VR_MAP   = $40000

SOUND   = 1
USE_POT = 0         ; 1 = second joystick button on POT 0
MAXENT  = 224
MAXPART = 48
MAXFLT  = 12
MAXWIN  = 8
NSLOT   = 32            ; text cache slots
SLOTLEN = 48            ; glyphs stored per slot (incl. terminator)

; ------------------------------------------------------------ zero page
vb      = $80       ; VBXE register base pointer
ptr     = $82
ptr2    = $84
bcbp    = $86       ; next BCB in the MEMAC window
tmp     = $88       ; tmp..tmp+7 scratch (leaf routines)
bx      = $90       ; blit: x,y (signed 16), w,h (16), source, steps, masks
by      = $92
bw      = $94
bh      = $96
bsrc    = $98       ; 3 bytes
bssx    = $9b       ; source step x (1, $ff, 0)
bssy    = $9c       ; source step y as a shift: 0 none, 7, 8, 10
band    = $9d
bxor    = $9e
bmode   = $9f
cx0     = $a0       ; clip rectangle (x1/y1 exclusive)
cy0     = $a1
cx1     = $a2
cy1     = $a3
camx    = $a4       ; camera (world pixels, signed 16)
camy    = $a6
rng     = $a8       ; 4 bytes
self    = $ac       ; current entity
other   = $ad
m_a     = $ae
m_b     = $af
m_r     = $b0       ; 2 bytes
sp      = $b2       ; string pointer
sp2     = $b4
a0      = $b8       ; arguments a0..a7
a1      = $b9
a2      = $ba
a3      = $bb
a4      = $bc
a5      = $bd
a6      = $be
a7      = $bf
t0      = $c0       ; temporaries t0..t7 (non-leaf routines)
t1      = $c1
t2      = $c2
t3      = $c3
t4      = $c4
t5      = $c5
t6      = $c6
t7      = $c7
u0      = $c8       ; u0..u7: more temporaries (level generator, logic)
u1      = $c9
u2      = $ca
u3      = $cb
u4      = $cc
u5      = $cd
u6      = $ce
u7      = $cf
end_ptr = $d0       ; control byte of the last command of the running list
w_i     = $d2       ; current window
p_i     = $d3       ; current particle
i_i     = $d4       ; current item
lp      = $d5       ; loop index (outer loops)
lp2     = $d6
snd_t   = $e0       ; sound scratch (VBI only) 8 bytes
snd_p   = $e8       ; 2 bytes (VBI only)
nmi_a   = $ea

; ------------------------------------------------------------ RAM map
; $0400-$07ff particles, floaters
; $0800-$17ff tile map 128x32
; $1800-$1fff text cache keys
; $a000-$bfff entities (also the XEX staging area while loading)
; $c000-$cfff windows, inventory, rooms, globals
; $d800-$e7ff fog 128x32, $e800-$f7ff occupancy (first entity per tile)
TMAP    = $0800
FOG     = $d800
OCC     = $e800

; particles
pa_xf   = $0400
pa_xl   = pa_xf+MAXPART
pa_xh   = pa_xl+MAXPART
pa_yf   = pa_xh+MAXPART
pa_yl   = pa_yf+MAXPART
pa_dxl  = pa_yl+MAXPART
pa_dxh  = pa_dxl+MAXPART
pa_dyl  = pa_dxh+MAXPART
pa_dyh  = pa_dyl+MAXPART
pa_life = pa_dyh+MAXPART
pa_c    = pa_life+MAXPART     ; colour list (index into pcol_*)
pa_uf   = pa_c+MAXPART        ; 0 none, 1 gravity, 2 rise
pa_end  = pa_uf+MAXPART
; floaters
fl_e    = pa_end
fl_dyl  = fl_e+MAXFLT
fl_dyh  = fl_dyl+MAXFLT
fl_oyl  = fl_dyh+MAXFLT
fl_oyh  = fl_oyl+MAXFLT
fl_c    = fl_oyh+MAXFLT
fl_life = fl_c+MAXFLT
fl_dly  = fl_life+MAXFLT
fl_on   = fl_dly+MAXFLT
fl_str  = fl_on+MAXFLT        ; 16 bytes each
fl_end  = fl_str+16*MAXFLT
        .if fl_end > $0800
        .error "particles/floaters overflow"
        .endif

; text cache keys
tc_str  = $1800               ; NSLOT * SLOTLEN
tc_hash = tc_str+NSLOT*SLOTLEN
tc_c    = tc_hash+NSLOT       ; c1 | c2<<5 packed? no: two arrays
tc_c2   = tc_c+NSLOT
tc_w    = tc_c2+NSLOT         ; pixel width
tc_age  = tc_w+NSLOT
tc_gen  = tc_age+NSLOT        ; bumped when a slot is re-rendered
tc_end  = tc_gen+NSLOT
mm_lo   = $f800               ; pointer memo for static strings (64)
mm_hi   = mm_lo+64
mm_c1   = mm_hi+64
mm_c2   = mm_c1+64
mm_slot = mm_c2+64
mm_gen  = mm_slot+64
        .if tc_end > $2000
        .error "text cache keys overflow"
        .endif

; entities
e_id    = $a000
e_tx    = e_id+MAXENT
e_ty    = e_tx+MAXENT
e_oxl   = e_ty+MAXENT
e_oxh   = e_oxl+MAXENT
e_oyl   = e_oxh+MAXENT
e_oyh   = e_oyl+MAXENT
e_hp    = e_oyh+MAXENT
e_hpmax = e_hp+MAXENT
e_atk   = e_hpmax+MAXENT
e_fl    = e_atk+MAXENT
e_pois  = e_fl+MAXENT
e_conf  = e_pois+MAXENT
e_para  = e_conf+MAXENT
e_t     = e_para+MAXENT
e_mt    = e_t+MAXENT          ; move timer in eighths (0..9)
e_dx    = e_mt+MAXENT
e_dy    = e_dx+MAXENT
e_odist = e_dy+MAXENT
e_dir   = e_odist+MAXENT
e_hitc  = e_dir+MAXENT
e_fc    = e_hitc+MAXENT
e_fs    = e_fc+MAXENT
e_frame = e_fs+MAXENT
e_fbase = e_frame+MAXENT
e_fmode = e_fbase+MAXENT      ; 0 normal, 1 dying hero, 2 defeated lich
e_logic = e_fmode+MAXENT
e_gx    = e_logic+MAXENT
e_gy    = e_gx+MAXENT
e_next  = e_gy+MAXENT         ; next entity on the same tile ($ff = none)
e_nfr   = e_next+MAXENT       ; number of animation frames
ent_list = e_nfr+MAXENT       ; draw/update order
e_end   = ent_list+MAXENT
        .if e_end > $c000
        .error "entity arrays overflow"
        .endif
; entity flags
F_MOB   = $01
F_PROP  = $02
F_TRAP  = $04
F_WALK  = $08
F_BLOS  = $10
F_USED  = $20
F_ITEM  = $40   ; hasitem
F_ATKD  = $80   ; attacked this turn
; logic routines
L_NONE  = 0
L_PLAYER = 1
L_WAIT  = 2
L_CHASE = 3
L_FLEE  = 4
L_CONF  = 5
L_PARA  = 6
L_TRAP  = 7

; windows
WL      = 12                  ; max lines
wn_on   = $c000
wn_x    = wn_on+MAXWIN        ; signed
wn_yl   = wn_x+MAXWIN         ; y, 8.8
wn_yh   = wn_yl+MAXWIN
wn_w    = wn_yh+MAXWIN
wn_hl   = wn_w+MAXWIN         ; h, 8.8
wn_hh   = wn_hl+MAXWIN
wn_dly  = wn_hh+MAXWIN
wn_life = wn_dly+MAXWIN       ; signed
wn_haslife = wn_life+MAXWIN
wn_btn  = wn_haslife+MAXWIN
wn_close = wn_btn+MAXWIN      ; on_close: 0 none, 1 to title (death), 2 to title (win)
wn_cur  = wn_close+MAXWIN     ; 0 = no cursor, 255 = cursor gone
wn_sel  = wn_cur+MAXWIN       ; on_select: 0 none, 1 inventory, 2 item menu
wn_head = wn_sel+MAXWIN       ; header window or $ff
wn_hud  = wn_head+MAXWIN
wn_hdr  = wn_hud+MAXWIN
wn_n    = wn_hdr+MAXWIN       ; number of lines
wn_inv  = wn_n+MAXWIN         ; lines come from the inventory
wn_lo   = wn_inv+MAXWIN       ; line pointers WL*MAXWIN
wn_hi   = wn_lo+WL*MAXWIN
wn_buf  = wn_hi+WL*MAXWIN     ; 2 line buffers of 48 bytes per window
wn_end  = wn_buf+96*MAXWIN
win_list = wn_end             ; windows in drawing order
modal_stack = win_list+MAXWIN
; inventory (8 slots, it_on = 0 empty; slot 8 holds a new item)
it_on   = modal_stack+MAXWIN
it_id   = it_on+9
it_type = it_id+9
it_spr  = it_type+9
it_atk  = it_spr+9
it_heal = it_atk+9
it_hpmax = it_heal+9
it_trait = it_hpmax+9
it_stat = it_trait+9
it_idf  = it_stat+9
it_eq   = it_idf+9
it_end  = it_eq+9
; rooms
MAXROOM = 32
rm_x    = it_end
rm_y    = rm_x+MAXROOM
rm_w    = rm_y+MAXROOM
rm_h    = rm_w+MAXROOM
rm_oob  = rm_h+MAXROOM
rm_typ  = rm_oob+MAXROOM
rm_flr  = rm_typ+MAXROOM
rm_pool = rm_flr+MAXROOM      ; room_pool (types)
room_bg = rm_pool+MAXROOM     ; saved tiles under a room being placed (128)
strbuf  = room_bg+128         ; string builder (64)
inv_text = strbuf+64          ; 8 inventory lines of 48
G       = inv_text+8*48       ; globals
        .if G+256 > $d000
        .error "globals overflow"
        .endif

ent_n   = G+0       ; entities in ent_list
pl      = G+1       ; player entity index
pl_depth = G+2
pl_win  = G+3
pl_lvl  = G+4
pl_xp   = G+5       ; 2 bytes
pl_wpn  = G+7       ; inventory slot of the weapon, $ff = none
inv_n   = G+8       ; inventory.items
sleep   = G+9
phase   = G+10
floater_delay = G+11
camtx   = G+12
camty   = G+13
move_cam = G+14
next_btn = G+15     ; $ff = none
state   = G+16      ; 0 title, 1 level
next_state = G+17
change_state = G+18
fade_p  = G+19      ; fade_progress * 200 (signed)
fade_k  = G+20      ; palette fade steps shown
modal_top = G+21    ; $ff = none
nmodal  = G+22
nwin    = G+23
tried_anvil = G+24
tried_well = G+25
tried_altar = G+26
title_t = G+27      ; 2 bytes
s_time  = G+29      ; 2 bytes (turns, 16 bit)
hit_name = G+31     ; 2 bytes: name of what last hurt the hero
num_rooms = G+33
n_rooms = G+34      ; rooms in the list
n_pool  = G+35
mobs_placed = G+36
mobs_to_place = G+37
mobs_per_room = G+38
dropped = G+39
removed = G+40
rcx     = G+41
rcy     = G+42
dc      = G+43
back_bank = G+44
present_req = G+45
ticks   = G+46
tick_acc = G+47
hz      = G+48
bcb_n   = G+49
frame30 = G+50      ; 0..29
last_slot = G+51
tc_clock = G+52
in_held = G+53
in_cnt  = G+54      ; 6 bytes
in_armed = G+60
pal_k_shown = G+61
snd_add = G+62
mus_req = G+63
sfx_q   = G+64      ; 2 bytes
sfx_qn  = G+66
alloc_e = G+67      ; next entity slot to try
pot_rest = G+68     ; 2 bytes
wpn_slot_tmp = G+70
pl_hitc_seen = G+71
prev_bank = G+72
; sound state (4 channels)
ch_on   = G+80
ch_note = G+84
ch_accl = G+88
ch_acch = G+92
ch_spd  = G+96
ch_ls   = G+100
ch_le   = G+104
ch_pl   = G+108
ch_ph   = G+112
ch_prev = G+116
ch_pitch = G+120
ch_vol  = G+124
ch_fx   = G+128
ch_noise = G+132
ch_lead = G+136
mus_on  = G+137
mus_pat = G+138
mus_loop = G+139
mus_len = G+140
mus_cnt = G+141
snd_frame = G+142
ch_sfx  = G+144     ; 4 bytes: channel plays a sound effect
snd_addl = G+148
snd_addh = G+149
pat_done = G+150
rtclok  = G+151
fx_dirty = G+152
VARS_END = G+160

        opt h+
        org $2000

; ============================================================ main
main
        sei
        lda #0
        sta NMIEN
        sta DMACTL
        sta SDMCTL
        cli
        lda #1
        sta NOCLIK
        jsr detect_vbxe
        bcs vbxe_ok
        jmp no_vbxe
vbxe_ok
        ; OS off: own NMI/IRQ vectors, RAM under the ROM
        sei
        lda #0
        sta NMIEN
        sta IRQEN
        lda PORTB
        and #$fe
        ora #$82
        sta PORTB
        jsr clear_ram
        lda #<nmi
        sta $fffa
        lda #>nmi
        sta $fffb
        lda #<irq
        sta $fffe
        lda #>irq
        sta $ffff
        lda #0
        sta COLBK
        sta PRIOR
        sta GRACTL
        lda #$ff
        sta next_btn
        sta modal_top
        sta pl_wpn
        sta mus_req
        lda #$3f
        sta in_armed            ; inputs count after a release
        lda #$ff
        sta pot_rest
        sta pot_rest+1
        lda RANDOM
        sta rng
        lda RANDOM
        sta rng+1
        lda RANDOM
        sta rng+2
        lda RANDOM
        ora #1
        sta rng+3
        ; PAL or NTSC pacing
        lda PAL
        and #$0e
        bne is_ntsc
        lda #50
        sta hz
        lda #<617
        sta snd_add
        jmp hz_done
is_ntsc lda #60
        sta hz
        lda #<514
        sta snd_add
hz_done
        jsr sound_init
        jsr vbxe_setup
        lda #1
        sta prev_bank           ; framebuffer 1 is shown, 0 is drawn next
        lda #$40
        sta NMIEN
        cli
        jsr bake_title
        lda #200
        sta fade_p
        lda #0
        sta state
        jsr swap_title

main_loop
        lda ticks
        beq main_loop
        dec ticks
        jsr bcb_begin           ; level updates may queue map bakes
        jsr game_update
        jsr game_draw
        jsr bcb_kick            ; the blitter draws while the next tick runs
        ; three framebuffers: wait until the previous frame is on screen,
        ; then queue this one; the next is drawn into the third buffer
wait_present
        lda present_req
        bne wait_present
        lda back_bank
        ora #$80
        sta present_req
        lda #3
        sec
        sbc prev_bank
        sec
        sbc back_bank
        ldx back_bank
        stx prev_bank
        sta back_bank
        jmp main_loop

; wait for the next 30 Hz tick without drawing (PICO-8 flip())
flip    lda ticks
        beq flip
        dec ticks
        rts

clear_ram
        lda #0
        tay
        ldx #$04
cr_lo   stx cr_p+2
cr_p    sta $0400,y
        iny
        bne cr_p
        inx
        cpx #$20
        bne cr_lo
        ldx #$a0
cr_hi   stx cr_h+2
cr_h    sta $a000,y
        iny
        bne cr_h
        inx
        cpx #$d0
        bne cr_hi
        ldx #$d8
cr_os   stx cr_o+2
cr_o    sta $d800,y
        iny
        bne cr_o
        inx
        cpx #$ff
        bne cr_os
        rts

; ------------------------------------------------------------ NMI
nmi     bit NMIST
        bvs nmi_vbi
        rti
nmi_vbi sta NMIRES
        pha
        txa
        pha
        tya
        pha
        inc rtclok
        lda present_req
        beq vbi_nopresent
        ldy #VB_BLIT            ; show the frame once the blitter is done
        lda (vb),y
        bne vbi_nopresent
        lda present_req
        and #3
        tax
        ldy #VB_XDL0
        lda #0
        sta (vb),y
        iny
        lda xdl_mid,x
        sta (vb),y
        iny
        lda #0
        sta (vb),y
        sta present_req
vbi_nopresent
        jsr apply_fade
        ; 30 Hz game ticks
        lda tick_acc
        clc
        adc #30
        cmp hz
        bcc vbi_noTick
        sbc hz
        ldx ticks           ; at most two ticks of backlog
        cpx #2
        bcs vbi_noTick
        inc ticks
vbi_noTick
        sta tick_acc
        .if SOUND
        jsr sound_tick
        .endif
        sta POTGO
        pla
        tay
        pla
        tax
        pla
irq     rti
xdl_mid dta $d0,$d4,$d8

; ------------------------------------------------------------ input
; PICO-8 buttons: 0 left, 1 right, 2 up, 3 down, 4 O (close), 5 X (action).
; Joystick 0 + fire (X); keyboard W/A/S/D or the arrow keys, X/SPACE/
; RETURN = X, C/Z/ESC = O; the second button of a 2-button joystick
; (POT 0) = O.  btnp(): a press, then repeats after 15 ticks every 4.
read_buttons
        lda PORTA
        eor #15
        and #15
        tax
        lda stick_bits,x
        sta tmp
        lda TRIG0
        bne rb_nt
        lda tmp
        ora #$20
        sta tmp
rb_nt   lda SKSTAT
        and #4
        bne rb_nk
        lda KBCODE
        and #$3f
        tax
        lda key_bits,x
        ora tmp
        sta tmp
rb_nk   ; second joystick button on POT 0: any change from the rest level
        ; (sampled once the paddle scans have settled)
        .if USE_POT
        lda rtclok
        cmp #30
        bcc rb_np
        lda POT0
        cmp #128
        lda #0
        rol
        ldx pot_rest
        bpl rb_pk
        sta pot_rest
        jmp rb_np
rb_pk   cmp pot_rest
        beq rb_np
        lda tmp
        ora #$10
        sta tmp
        .endif
rb_np   ; tmp = held mask
        ldx #5
rb_loop lda tmp
        and bit_tab,x
        bne rb_held
        lda #0
        sta in_cnt,x
        lda in_armed
        and bit_tab_n,x
        sta in_armed
        jmp rb_next
rb_held lda in_armed
        and bit_tab,x
        bne rb_next             ; not released since start
        lda in_cnt,x
        bne rb_rep
        inc in_cnt,x
        jmp rb_press
rb_rep  inc in_cnt,x
        lda in_cnt,x
        sec
        sbc #16
        bcc rb_next
        and #3
        bne rb_next
rb_press
        lda rb_best             ; buttons are scanned 5..0: the highest wins
        bpl rb_next
        stx rb_best
rb_next dex
        bpl rb_loop
        lda next_btn
        bpl rb_done
        lda rb_best
        sta next_btn
rb_done lda #$ff
        sta rb_best
        rts
rb_best dta $ff
bit_tab   dta 1,2,4,8,16,32
bit_tab_n dta $fe,$fd,$fb,$f7,$ef,$df
; PORTA nibble (inverted: 1 = pressed): up 1, down 2, left 4, right 8
stick_bits
        dta 0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15
; keyboard code -> buttons: A D W S, + * - = (arrows), X V M SPACE RETURN, C Z N ESC
key_bits
        dta $00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$20,$00,$04,$08
        dta $20,$00,$10,$00,$00,$00,$20,$10,$00,$00,$00,$00,$10,$00,$00,$00
        dta $00,$20,$00,$10,$00,$20,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00
        dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$08,$01

; ------------------------------------------------------------ no VBXE
no_vbxe
        lda #$22
        sta SDMCTL
        ldx #0
        lda #9              ; PUT BINARY
        sta $0342,x
        mwa #nv_text $0344,x
        mwa #nv_len $0348,x
        jsr $e456
        jmp *
nv_text dta $7d,c'CURSE OF THE LICH KING requires VBXE (FX core) at $D600 or $D700',$9b
nv_len  = *-nv_text

        icl 'src/vbxe.asm'
        icl 'src/draw.asm'
        icl 'src/text.asm'
        icl 'src/util.asm'
        icl 'src/level.asm'
        icl 'src/entity.asm'
        icl 'src/items.asm'
        icl 'src/windows.asm'
        icl 'src/game.asm'
        icl 'src/sound.asm'
        icl 'gen/tables.asm'
strings_begin
        icl 'gen/strings.asm'
strings_end
sfx_data
        ins 'data/sfx.bin'
code_end
        .if code_end > $9000
        .error "main segment overlaps the MEMAC window"
        .endif
        ini basic_off

; ============================================================ loading
; The staging area $a000-$bfff is filled while the XEX loads; each INI
; routine copies it into VBXE memory.
        org $a000
        ins 'data/gfx.bin'
        ini stage_gfx
        org $a000
        ins 'data/stage.bin'
        ini stage_misc
        run main
