; Celeste (Matt Thorson + Noel Berry, PICO-8) - Atari XL/XE + VBXE port
; MADS 2.x.  See README.md for the design.
;
; Coordinates: every object position is a byte holding PICO-8 x/y + 64
; ("biased"), so the -64..191 range of a room fits in one byte and maps
; 1:1 onto columns/rows of the 256x256 VBXE framebuffers.

; ------------------------------------------------------------ hardware
RTCLOK  = $12
VVBLKD  = $0224
SDMCTL  = $022f
COLOR4  = $02c8
STICK0  = $0278
STRIG0  = $0284
PADDL0  = $0270
CH      = $02fc
CONSOL  = $d01f
PAL     = $d014
AUDF1   = $d200
AUDC1   = $d201
AUDCTL  = $d208
RANDOM  = $d20a
KBCODE  = $d209
SKSTAT  = $d20f
PORTB   = $d301
DMACTL  = $d400
NMIEN   = $d40e
SETVBV  = $e45c
XITVBV  = $e462
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
; $00000 / $10000  framebuffers (256x256, pico screen at +64,+64)
; $20000 sprite sheet 128x128   $24000 hair variants (3 x 128x8)
; $25000 font   $25800 circles  $26000 / $26400 XDLs
; $28000 tile map 128x64        $30000 bg layer   $34000 terrain layer
; $7f000 blitter list

SOUND   = 1          ; POKEY sound effects
PLAY_MUSIC = 0          ; 1 = also play the cart's music
BIAS    = 64
MAXOBJ  = 48

; blitter command kinds (see bcb_add)
K_NONE  = 0
K_FILL  = 1
K_SPR   = 2
K_GLYPH = 3
K_CIRC  = 4
K_LAYER = 5
K_BAKE  = 6

; object types
T_PLAYER    = 1
T_SPAWN     = 2
T_SPRING    = 3
T_BALLOON   = 4
T_FALLFLOOR = 5
T_SMOKE     = 6
T_FRUIT     = 7
T_FLYFRUIT  = 8
T_LIFEUP    = 9
T_FAKEWALL  = 10
T_KEY       = 11
T_CHEST     = 12
T_PLATFORM  = 13
T_MESSAGE   = 14
T_BIGCHEST  = 15
T_ORB       = 16
T_FLAG      = 17
T_ROOMTITLE = 18
NTYPES      = 19

; ------------------------------------------------------------ zero page
vb      = $80       ; VBXE register base pointer
ptr     = $82
ptr2    = $84
bcbp    = $86       ; next BCB in the MEMAC window
self    = $88       ; current object index
z16     = $8a       ; 16-bit work register (8.8, cosmetic effects)
tmp     = $90       ; tmp..tmp+7 scratch
col_ox  = $98       ; collide/is_solid offsets (signed)
col_oy  = $99
col_ty  = $9a
c_l     = $9b
c_r     = $9c
c_t     = $9d
c_b     = $9e
sa_x    = $9f       ; tile_flag_at / spikes_at arguments
sa_y    = $a0
sa_w    = $a1
sa_h    = $a2
sa_f    = $a3
sa_i0   = $a4
sa_i1   = $a5
sa_j0   = $a6
sa_j1   = $a7
sa_j    = $a8
io_x    = $a9       ; init_object position
io_y    = $aa
dr_x    = $ab       ; drawing arguments (biased)
dr_y    = $ac
dr_c    = $ad
dr_x1   = $ae
dr_y1   = $af
dr_fx   = $b0
dr_fy   = $b1
dr_var  = $b2
txtp    = $b3       ; 2 bytes
rng     = $b5       ; 2 bytes
mul_a   = $b7
mul_b   = $b8
mul_r   = $b9       ; 2 bytes
snd_t   = $e0       ; sound scratch (VBI only) 8 bytes
snd_p   = $e8       ; 2 bytes (VBI only)
amount  = $c1
step    = $c2
cnt     = $c3
cam_x   = $c4
cam_y   = $c5
loop_i  = $c6
end_ptr = $d0       ; control byte of the last command of the running list
za      = $c7       ; 24-bit work registers: PICO-8 16.16 values stored
zt      = $ca       ; as fraction lo, fraction hi, integer (signed)
zm      = $cd

; ------------------------------------------------------------ variables
; Everything from $a000 is uninitialised RAM that is cleared at start.
; ($a000-$bfff is used as a staging area while the XEX loads.)
VARS    = $a000
o_type  = VARS
o_x     = o_type+MAXOBJ
o_y     = o_x+MAXOBJ
o_spr   = o_y+MAXOBJ
o_sprf  = o_spr+MAXOBJ
o_flx   = o_sprf+MAXOBJ
o_fly   = o_flx+MAXOBJ
o_sxl   = o_fly+MAXOBJ
o_sxh   = o_sxl+MAXOBJ
o_syl   = o_sxh+MAXOBJ
o_syh   = o_syl+MAXOBJ
o_rxl   = o_syh+MAXOBJ
o_rxh   = o_rxl+MAXOBJ
o_ryl   = o_rxh+MAXOBJ
o_ryh   = o_ryl+MAXOBJ
o_hbx   = o_ryh+MAXOBJ
o_hby   = o_hbx+MAXOBJ
o_hbw   = o_hby+MAXOBJ
o_hbh   = o_hbw+MAXOBJ
o_coll  = o_hbh+MAXOBJ
o_sol   = o_coll+MAXOBJ
o_v0    = o_sol+MAXOBJ
o_v1    = o_v0+MAXOBJ
o_v2    = o_v1+MAXOBJ
o_v3    = o_v2+MAXOBJ
o_v4    = o_v3+MAXOBJ
o_sxf   = o_v4+MAXOBJ   ; low fraction bytes of spd/rem (16.16)
o_syf   = o_sxf+MAXOBJ
o_rxf   = o_syf+MAXOBJ
o_ryf   = o_rxf+MAXOBJ
NFIELDS = 30
o_end   = o_type+NFIELDS*MAXOBJ

room_tiles = $a600      ; 16x16 tiles of the current room
        .if o_end > room_tiles
        .error "object arrays too large"
        .endif
; clouds (17)
cl_xl   = $a700
cl_xh   = cl_xl+17
cl_y    = cl_xh+17
cl_sl   = cl_y+17
cl_sh   = cl_sl+17
cl_w    = cl_sh+17
cl_h    = cl_w+17
; particles (25)
pa_xl   = $a780
pa_xh   = pa_xl+25
pa_yl   = pa_xh+25
pa_yh   = pa_yl+25
pa_s    = pa_yh+25
pa_sl   = pa_s+25
pa_sh   = pa_sl+25
pa_ol   = pa_sh+25
pa_oh   = pa_ol+25
pa_dl   = pa_oh+25      ; min(0.05, spd/32) as a 16-bit turn step
pa_dh   = pa_dl+25
pa_c    = pa_dh+25
; dead particles (8)
dp_xl   = $a8c0
dp_xh   = dp_xl+8
dp_yl   = dp_xh+8
dp_yh   = dp_yl+8
dp_sxl  = dp_yh+8
dp_sxh  = dp_sxl+8
dp_syl  = dp_sxh+8
dp_syh  = dp_syl+8
dp_t    = dp_syh+8      ; 0 = unused
; hair (5 segments, 8.8)
hr_xl   = $a910
hr_xh   = hr_xl+5
hr_yl   = hr_xh+5
hr_yh   = hr_yl+5
; big chest beams (50)
bc_x    = $a940
bc_yl   = bc_x+50
bc_yh   = bc_yl+50
bc_h    = bc_yh+50
bc_s    = bc_h+50
bc_n    = bc_s+50
got_fruit = $aa40       ; 32 bytes
txtbuf  = $aa60         ; 32 bytes
; globals
G       = $aa80
room_x  = G+0
room_y  = G+1
lvl     = G+2
freeze  = G+3
shake   = G+4
will_restart = G+5
delay_restart = G+6
has_dashed = G+7
sfx_timer = G+8
has_key = G+9
pause_player = G+10
flash_bg = G+11
new_bg  = G+12
music_timer = G+13
frames  = G+14
seconds = G+15
minutes = G+16      ; 2 bytes
deaths  = G+18      ; 2 bytes
max_djump = G+20
start_game = G+21
start_game_flash = G+22
obj_count = G+23
need_compact = G+24
room_changed = G+25
; player (only one player or player_spawn exists at a time)
p_jump  = G+26
p_dash  = G+27
p_grace = G+28
p_jbuf  = G+29
p_djump = G+30
p_dtime = G+31      ; dash_time (signed)
p_detime = G+32     ; dash_effect_time
p_sproff = G+41     ; spr_off in quarters
p_wasg  = G+42
p_input = G+43      ; -1/0/1
p_onground = G+44
p_onice = G+45
p_dash_now = G+46
p_jump_now = G+47
; input
btn_l   = G+48
btn_r   = G+49
btn_u   = G+50
btn_d   = G+51
btn_j   = G+52
btn_x   = G+53
; frame / VBI
back_bank = G+54    ; framebuffer being drawn (0/1)
present_req = G+55  ; $80|bank when a finished frame waits for VBL
ticks   = G+56
tick_acc = G+57
hz      = G+58
bcb_n   = G+59
bcb_last = G+60
snd_add = G+61
bg_col  = G+62
palflash = G+63     ; current title flash colour (10 = none)
bank_tmp = G+64
compact_w = G+65
draw_phase = G+66
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
ch_lead = G+136     ; channel that times the music pattern
mus_on  = G+137
mus_pat = G+138
mus_loop = G+139
mus_len = G+140
mus_cnt = G+141
snd_frame = G+142
mus_req = G+143     ; $ff none, $fe stop, else pattern
sfx_req = G+144     ; $ff none
p_dtx   = G+160     ; dash_target.x/y, dash_accel.x/y (16.16, 3 bytes)
p_dty   = G+163
p_dax   = G+166
p_day   = G+169
p_acc   = G+172
pl_idx  = G+175     ; index of the player object, $fe = none
list_n  = G+176     ; entries in each of the 4 type lists (4 bytes)
tpl_kind = G+180    ; primitive kind whose constants the template holds
VARS_END = G+181
slot_kind = $abc0   ; kind of the command stored in each list slot (190)
type_lists = $ab40  ; 4 x 32 indices: springs, fall floors, fake walls, platforms

        opt h+
        org $2000

; ============================================================ main
main
        sei
        lda #0
        sta NMIEN
        sta SDMCTL
        sta DMACTL
        sta COLOR4
        lda #$40
        sta NMIEN
        cli
        lda #1
        sta NOCLIK          ; silent keyboard (XL OS)
        jsr detect_vbxe
        bcs vbxe_ok
        jmp no_vbxe
vbxe_ok
        ; clear variables
        mwa #VARS ptr
        ldx #$20
        lda #0
        tay
clr_vars sta (ptr),y
        iny
        bne clr_vars
        inc ptr+1
        dex
        bne clr_vars
        lda #$ff
        sta mus_req
        sta sfx_req
        lda #10
        sta palflash
        lda RANDOM
        sta rng
        lda RANDOM
        ora #1
        sta rng+1
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
        jsr init_effects
        ; install the deferred VBI
        lda #7
        ldx #>vbi
        ldy #<vbi
        jsr SETVBV
        jsr install_kb
        jsr title_screen

main_loop
        lda ticks
        beq main_loop
        dec ticks
        jsr read_input
        jsr game_update
        lda freeze
        bne main_loop
        ; wait until the previously presented frame is on screen, so the
        ; buffer we are about to draw is no longer displayed
wait_present
        lda present_req
        bne wait_present
        jsr game_draw
        jsr bcb_kick            ; the blitter draws while the next tick runs
        lda back_bank
        ora #$80
        sta present_req
        lda back_bank
        eor #1
        sta back_bank
        jmp main_loop

; ------------------------------------------------------------ VBI
vbi
        lda present_req
        beq vbi_nopresent
        ldy #VB_BLIT            ; show the frame once the blitter is done
        lda (vb),y
        bne vbi_nopresent
        lda present_req
        and #1
        tax
        ldy #VB_XDL0
        lda #0
        sta (vb),y
        iny
        lda xdl_mid,x
        sta (vb),y
        iny
        lda #2
        sta (vb),y
        lda #0
        sta present_req
vbi_nopresent
        ; title flash palette (applied during blank)
        jsr apply_flash
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
        jmp XITVBV
xdl_mid dta $60,$64

; ------------------------------------------------------------ input
; Joystick 0 moves; fire = jump.  Dash: SHIFT, SPACE, C, joystick 2's
; fire, or buttons 2/3 of a 2-button joystick (Joy2B+: pin 5 / pin 9,
; read as POT 0 / POT 1).
; Keyboard alternative: W/A/S/D move, O or X jump, P dash.
; Each source counts only after it was seen released once (Altirra holds
; OPTION while booting; an unused POT line may read as pressed).
IN_U    = 1
IN_D    = 2
IN_L    = 4
IN_R    = 8
IN_J    = $10
IN_X    = $20
NOCLIK  = $02db

read_input
        lda #0
        sta in_mask
        ; joystick 0 directions
        lda STICK0
        eor #15
        and #15
        ldx #0
        jsr in_src
        ; fire
        lda STRIG0
        jsr in_low_j
        ldx #1
        jsr in_src
        ; keyboard: every real key press arrives through the keyboard IRQ.
        ; Jump/dash keys give a one-tick press; W/A/S/D stay held until
        ; the keyboard is idle or the opposite direction is pressed.
ri_kev  ldy kb_tail
        cpy kb_head
        beq ri_kend
        lda kb_ring,y
        iny
        tya
        and #7
        sta kb_tail
        lda kb_ring-1,y
        and #$3f
        ldy #key_bits-key_codes-1
ri_kfind
        cmp key_codes,y
        beq ri_kfound
        dey
        bpl ri_kfind
        bmi ri_kev
ri_kfound
        lda key_bits,y
        cmp #IN_J
        bcs ri_kact
        lda kdir
        and key_clear,y
        ora key_bits,y
        sta kdir
        jmp ri_kev
ri_kact ora kpulse
        sta kpulse
        jmp ri_kev
ri_kend lda SKSTAT
        and #4
        beq ri_kheld
        lda #0
        sta kdir
ri_kheld
        lda kdir
        ora kpulse
        ldx #0
        stx kpulse
        ldx #2
        jsr in_src
        ; SHIFT
        lda SKSTAT
        and #8
        jsr in_low_x
        ldx #3
        jsr in_src
        ; joystick 2 fire
        lda $0285
        jsr in_low_x
        ldx #4
        jsr in_src
        ; buttons 2/3 of a 2-button joystick (POT 0 / POT 1).  Wiring
        ; differs (Altirra reads high when pressed, Joy2B+ low), so a press
        ; is any change from the level the line had at startup.
        ldx #0
        jsr pot_button
        ldx #5
        jsr in_src
        ldx #1
        jsr pot_button
        ldx #6
        jsr in_src
        ; unpack
        ldy #5
ri_unp  ldx #0
        lda in_mask
        and in_bit,y
        beq ri_u0
        inx
ri_u0   txa
        sta btn_l,y
        dey
        bpl ri_unp
        rts
; A=0 when pressed -> A=IN_J / IN_X, else 0
; A = IN_X when POT line X differs from its resting level
pot_button
        lda PADDL0,x
        cmp #128
        lda #0
        rol                 ; 1 = high
        ldy pot_rest,x
        bpl pb_known
        sta pot_rest,x      ; first read: this is the resting level
        lda #0
        rts
pb_known
        cmp pot_rest,x
        beq in_none
        lda #IN_X
        rts
pot_rest dta $ff,$ff
in_low_j
        bne in_none
        lda #IN_J
        rts
in_low_x
        bne in_none
        lda #IN_X
        rts
in_none lda #0
        rts
; merge source X's bits (A) unless it has not been released yet
in_src  cmp #0
        bne in_s1
        lda #1
        sta in_armed,x
        rts
in_s1   ldy in_armed,x
        beq in_s2
        ora in_mask
        sta in_mask
in_s2   rts
in_mask  dta 0
kdir     dta 0
kpulse   dta 0
in_armed dta 0,0,1,0,0,1,1
; keyboard IRQ: queue every real key press, then continue in the OS
VKEYBD  = $0208
kb_irq  txa
        pha
        ldx kb_head
        lda KBCODE
        sta kb_ring,x
        inx
        txa
        and #7
        cmp kb_tail
        beq kb_full
        sta kb_head
kb_full pla
        tax
        jmp (kb_os)
kb_os    dta a(0)
kb_head  dta 0
kb_tail  dta 0
kb_ring  :8 dta 0
install_kb
        sei
        lda VKEYBD
        sta kb_os
        lda VKEYBD+1
        sta kb_os+1
        lda #<kb_irq
        sta VKEYBD
        lda #>kb_irq
        sta VKEYBD+1
        cli
        rts
; btn_l, btn_r, btn_u, btn_d, btn_j, btn_x are consecutive
in_bit   dta IN_L,IN_R,IN_U,IN_D,IN_J,IN_X
key_codes dta $2e,$3e,$3f,$3a,$08,$16,$0a,$21,$12
key_bits  dta IN_U,IN_D,IN_L,IN_R,IN_J,IN_J,IN_X,IN_X,IN_X
key_clear dta $ff^IN_D,$ff^IN_U,$ff^IN_R,$ff^IN_L

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
nv_text dta $7d,c'CELESTE requires VBXE (FX core) at $D600 or $D700',$9b
nv_len  = *-nv_text

        icl 'src/vbxe.asm'
        icl 'src/objects.asm'
        icl 'src/types.asm'
        icl 'src/game.asm'
        icl 'src/draw.asm'
        icl 'src/sound.asm'
        icl 'gen/tables.asm'
sfx_data
        ins 'data/sfx.bin'
code_end
        .if code_end > $9000
        .error "main segment overlaps the MEMAC window"
        .endif
        ini basic_off

; ============================================================ loading
; The staging area $a000-$bfff is filled three times while the XEX loads;
; each INI routine copies it into VBXE memory.
        org $a000
        ins 'data/gfx.bin'
        ini stage_gfx
        org $a000
        ins 'data/map.bin'
        ini stage_map
        org $a000
        ins 'data/stage.bin'
        ini stage_misc
        run main
