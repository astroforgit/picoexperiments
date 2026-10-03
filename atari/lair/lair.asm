; The Lair (Jakub Wasilewski @krajzeg / Gruber, PICO-8) - Atari XL/XE + VBXE port
; MADS 2.x.  See README.md for the design.
;
; The OS ROM is switched off once the program has loaded: the game runs its
; own NMI handler and uses the RAM under the ROM.  The game logic runs at
; the cart's 60 updates per second (_update60); the screen is the 128x128
; PICO-8 screen, drawn by the VBXE blitter into three framebuffers.

; ------------------------------------------------------------ hardware
TRIG0   = $d010
TRIG1   = $d011
COLPF2  = $d018
COLBK   = $d01a
PRIOR   = $d01b
GRACTL  = $d01d
CONSOL  = $d01f
PAL     = $d014
AUDF1   = $d200
AUDC1   = $d201
POT0    = $d200     ; (POT 1 = $d201)
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
SDMCTL  = $022f
NOCLIK  = $02db
MEMW    = $9000             ; MEMAC window (4K)

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
; $00000/$04000/$08000  framebuffers 128x128 (stride 128)
; $0c000 font masks (glyph g at +g*4, stride 512)
; $0d000/$0d400/$0d800 XDLs        $0e000/$0f000 blitter lists
; $10000 sprite sheet, $14000 captain colours, $18000 fire-spitter colours
;        (pixels are $f0|colour, PICO-8 colour 0 stored as 3, 3 = transparent)
; $1c000 reflection rows, moon images
; $20000 text cache: 32 slots of 256x16 (body rows 0-7, outline rows 8-15)
; $40000 moons, $43800 shadows, $44800 outlined font (glyph g at g*8,
;        stride 512), $46000 floor strips (3 stages, stride 256),
;        $4c000 the map (128x32)
; $50000 map layer strips of the current stage (stride 1024)
VR_FONT  = $0c000
VR_OFONT = $44800
VR_SHEET = $10000
VR_REFL  = $1c000
VR_MOON  = $1e000
VR_TEXT  = $20000
VR_STAGE = $40000

SOUND   = 1
PLAY_MUSIC = 0
MAXE    = 40                ; entities
MAXD    = 40                ; drawables
MAXPS   = 24                ; particle systems
MAXP    = 160               ; particles
MAXHU   = 24                ; queued attacks
NSLOT   = 32                ; text cache slots
SLOTLEN = 40

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
bssy    = $9c       ; source step y as a shift code (0 none, 7, 8, 10) or $80 = -128
band    = $9d
bxor    = $9e
bmode   = $9f
cx0     = $a0       ; clip rectangle (x1/y1 exclusive), screen coordinates
cy0     = $a1
cx1     = $a2
cy1     = $a3
camx    = $a4       ; camera (signed 16)
camy    = $a6
rng     = $a8       ; 2 bytes
dbank   = $aa       ; draw palette bank 0..15 (the cart's pal() state)
dsheet  = $ab       ; sprite sheet variant 0..2
self    = $ac       ; current entity
other   = $ad
m_s     = $ae
m_t     = $af
m_lo    = $b0
m_hi    = $b1
m_f     = $b2
m_r     = $b3       ; 3 bytes
m_v     = $b6       ; 2 bytes
m_w     = $b8       ; 2 bytes
m_u     = $ba       ; 2 bytes
m_n     = $bc       ; 2 bytes
m_d     = $be       ; 2 bytes
m_q     = $c0       ; 2 bytes
m_rm    = $c2       ; 2 bytes
a0      = $c4       ; arguments a0..a7
a1      = $c5
a2      = $c6
a3      = $c7
a4      = $c8
a5      = $c9
a6      = $ca
a7      = $cb
t0      = $cc       ; temporaries t0..t7 (non-leaf routines)
t1      = $cd
t2      = $ce
t3      = $cf
t4      = $d0
t5      = $d1
t6      = $d2
t7      = $d3
u0      = $d4       ; u0..u7 more temporaries (state handlers)
u1      = $d5
u2      = $d6
u3      = $d7
u4      = $d8
u5      = $d9
u6      = $da
u7      = $db
end_ptr = $dc
sp      = $de       ; string pointer (2)
snd_t   = $e0       ; sound scratch (VBI only) 8 bytes
snd_p   = $e8
nmi_a   = $ea
nv_dx   = $eb       ; 3 bytes (vnorm)
nv_dy   = $ee       ; 3 bytes
nv_ux   = $f1       ; 2
nv_uy   = $f3       ; 2
nv_d    = $f5       ; 2
nv_sx   = $f7
nv_sy   = $f8
nv_sh   = $f9
pp      = $fa       ; current particle
ps      = $fb       ; current particle system
dd      = $fc       ; current drawable
lp      = $fd
lp2     = $fe
rx0     = $00       ; rectangle / span corners (signed 16)
rx1     = $02
ry0     = $04
ry1     = $06
bk_ptr  = $70       ; BCB kind memo of the current list
str_p   = $72       ; text: string pointer
gl_x    = $74       ; text: pen x (16 bit)
v0      = $76       ; v0..v7 temporaries (renderers)
v1      = $77
v2      = $78
v3      = $79
v4      = $7a
v5      = $7b
v6      = $7c
v7      = $7d

; ------------------------------------------------------------ RAM map
; $0200-$03ff  attack queue, drawables
; $0400-$1fff  entities, particle systems, particles, text cache keys
; $a000-$bfff  tables (loaded) / XEX staging area while loading
; $c000-$cfff  globals, sound state
; $d800-$ffff  quarter squares, sine, sfx data (RAM under the OS ROM)

; attack queue
hu_e    = $0200
hu_box  = hu_e+MAXHU
hu_grp  = hu_box+MAXHU
hu_cb   = hu_grp+MAXHU
hu_end  = hu_cb+MAXHU
; drawables
d_kind  = hu_end
d_ent   = d_kind+MAXD
d_layer = d_ent+MAXD          ; $ff: the entity's y
d_t     = d_layer+MAXD        ; 16 bit
d_th    = d_t+MAXD
d_a     = d_th+MAXD           ; renderer data
d_b     = d_a+MAXD
d_c     = d_b+MAXD
d_next  = d_c+MAXD            ; bucket list while drawing
d_end   = d_next+MAXD
        .if d_end > $0400
        .error "attack queue/drawables overflow"
        .endif

; entities (struct of arrays)
E0      = $0400
e_cls   = E0+MAXE*0           ; class (0 = free)
e_st    = E0+MAXE*1           ; state
e_tl    = E0+MAXE*2           ; frames in the state (16 bit): the cart's t*2
e_th    = E0+MAXE*3
e_il    = E0+MAXE*4           ; hit-stop frames
e_xf    = E0+MAXE*5
e_xl    = E0+MAXE*6
e_xh    = E0+MAXE*7
e_yf    = E0+MAXE*8
e_yl    = E0+MAXE*9
e_zf    = E0+MAXE*10
e_zl    = E0+MAXE*11
e_zh    = E0+MAXE*12
e_vxf   = E0+MAXE*13
e_vxl   = E0+MAXE*14
e_vyf   = E0+MAXE*15
e_vyl   = E0+MAXE*16
e_vzf   = E0+MAXE*17
e_vzl   = E0+MAXE*18
e_qn    = E0+MAXE*19          ; facing: 1 or $ff
e_paf   = E0+MAXE*20          ; damage taken 8.8
e_pal   = E0+MAXE*21
e_bl    = E0+MAXE*22          ; last hit time (frames)
e_bh    = E0+MAXE*23
e_pul   = E0+MAXE*24          ; parry/dash flash time
e_puh   = E0+MAXE*25
e_rjl   = E0+MAXE*26          ; invulnerable until
e_rjh   = E0+MAXE*27
e_gjl   = E0+MAXE*28          ; walking since (e_gjon = 0: not walking)
e_gjh   = E0+MAXE*29
e_gjon  = E0+MAXE*30
e_dn0   = E0+MAXE*31          ; entities hit by the current attack (bit mask)
e_dn1   = E0+MAXE*32
e_dn2   = E0+MAXE*33
e_dn3   = E0+MAXE*34
e_dnn   = E0+MAXE*35          ; their number
e_gbt   = E0+MAXE*36          ; palette effect: bank (0 = none)
e_ku    = E0+MAXE*37          ; attached particle system ($ff none) and its gen
e_kug   = E0+MAXE*38
e_ih    = E0+MAXE*39
e_ihg   = E0+MAXE*40
e_nb    = E0+MAXE*41          ; dead
e_dg    = E0+MAXE*42          ; drawn while dead
e_dx    = E0+MAXE*43          ; sign of the last move dx (0, 1, $ff)
e_chg   = E0+MAXE*44          ; charge * 2
e_jm    = E0+MAXE*45          ; combo
e_fkl   = E0+MAXE*46
e_fkh   = E0+MAXE*47
e_gk    = E0+MAXE*48
e_s_    = E0+MAXE*49          ; strength
e_njxf  = E0+MAXE*50          ; target position
e_njxl  = E0+MAXE*51
e_njxh  = E0+MAXE*52
e_njyf  = E0+MAXE*53
e_njyl  = E0+MAXE*54
e_njon  = E0+MAXE*55
e_od    = E0+MAXE*56
e_mxf   = E0+MAXE*57          ; felm smoothed move, lunge velocity (ax, ay)
e_mxl   = E0+MAXE*58
e_myf   = E0+MAXE*59
e_myl   = E0+MAXE*60
e_axf   = E0+MAXE*61
e_axl   = E0+MAXE*62
e_ayf   = E0+MAXE*63
e_ayl   = E0+MAXE*64
e_df    = E0+MAXE*65          ; eldr: frames close to the hero
e_rgxf  = E0+MAXE*66          ; blch shot target / eldr anchor
e_rgxl  = E0+MAXE*67
e_rgxh  = E0+MAXE*68
e_rgyf  = E0+MAXE*69
e_rgyl  = E0+MAXE*70
e_rs    = E0+MAXE*71          ; teleport target: 0 random, 1 by the hero
e_es    = E0+MAXE*72          ; projectile life
e_var   = E0+MAXE*73          ; bh colours, pickup kind
e_rf    = E0+MAXE*74          ; em: radius 8.8
e_ri    = E0+MAXE*75
e_kwf   = E0+MAXE*76          ; em: ring speed 8.8
e_kwi   = E0+MAXE*77
e_wf    = E0+MAXE*78          ; em: width 8.8
e_wi    = E0+MAXE*79
e_om    = E0+MAXE*80          ; em: debris count
e_oe    = E0+MAXE*81          ; colour
e_ihf   = E0+MAXE*82          ; level end / misc flag
e_mf    = E0+MAXE*83          ; misc
e_dn4   = E0+MAXE*84
e_jw    = E0+MAXE*85          ; gravity of a projectile /256
e_end   = E0+MAXE*86
; particle systems
ps_on   = e_end               ; 0 free
ps_gen  = ps_on+MAXPS
ps_em   = ps_gen+MAXPS        ; emitting (the cart's ja ~= nil)
ps_ja   = ps_em+MAXPS         ; emission chance /256 (255 = always)
ps_cs   = ps_ja+MAXPS         ; life lost per frame /256
ps_ml   = ps_cs+MAXPS         ; friction (0 = 1.0)
ps_jw   = ps_ml+MAXPS         ; gravity /256
ps_ir   = ps_jw+MAXPS         ; bounce (0 none)
ps_bp   = ps_ir+MAXPS         ; 1: not kept inside the floor
ps_y    = ps_bp+MAXPS         ; drawing layer
ps_head = ps_y+MAXPS          ; first particle ($ff none)
ps_kind = ps_head+MAXPS       ; emitter
ps_own  = ps_kind+MAXPS       ; emitter owner entity
ps_a    = ps_own+MAXPS        ; emitter parameters
ps_b    = ps_a+MAXPS
ps_c    = ps_b+MAXPS
ps_d    = ps_c+MAXPS
ps_e    = ps_d+MAXPS
ps_f    = ps_e+MAXPS
ps_csh  = ps_f+MAXPS          ; cs high byte
ps_next = ps_csh+MAXPS        ; bucket list while drawing
ps_end  = ps_next+MAXPS
; particles
p_xf    = ps_end
p_xl    = p_xf+MAXP
p_xh    = p_xl+MAXP
p_yf    = p_xh+MAXP
p_yl    = p_yf+MAXP
p_zf    = p_yl+MAXP
p_zl    = p_zf+MAXP
p_zh    = p_zl+MAXP
p_vxf   = p_zh+MAXP
p_vxl   = p_vxf+MAXP
p_vyf   = p_vxl+MAXP
p_vyl   = p_vyf+MAXP
p_vzf   = p_vyl+MAXP
p_vzl   = p_vzf+MAXP
p_esf   = p_vzl+MAXP          ; life 8.8
p_esl   = p_esf+MAXP
p_oe    = p_esl+MAXP          ; colour
p_ko    = p_oe+MAXP           ; glyph+1 (0 = not a letter)
p_je    = p_ko+MAXP           ; ellipse radius (0 = a pixel)
p_next  = p_je+MAXP
p_end   = p_next+MAXP
        .if p_end > $2000
        .error "RAM below the code overflows"
        .endif

G       = $c000               ; globals ($c000-$cfff, RAM under the OS)
frames  = G+0       ; 2 bytes: the cart's t * 2
ticks   = G+2
tick_acc = G+3
hz      = G+4
back_bank = G+5
prev_bank = G+6
present_req = G+7
bcb_n   = G+8
rtclok  = G+9
pal_req = G+10      ; palette must be rewritten
spal_t  = G+11      ; screen palette effect bank (0 none)
in_held = G+12      ; buttons held (ct)
in_prev = G+13      ; held last tick (kf)
in_new  = G+14      ; pressed this tick (gq)
in_dbl  = G+15      ; double-tapped this tick (pl)
in_ne   = G+16      ; last pressed button
in_hal  = G+17      ; and when (2 bytes)
in_hah  = G+18
qw      = G+19      ; scheduled scene change (0 none, 1 title, 2 new game, 3 next stage)
o_      = G+20      ; game over screen
gr      = G+21      ; screen shake * 2
kh      = G+22      ; difficulty 1..5
jn      = G+23      ; stage
eg      = G+24      ; hero entity
fr      = G+25      ; level entity
boss    = G+26      ; boss entity ($ff none)
ei      = G+27      ; the monster in front of the hero
nt_tab  = G+28      ; screen palette effect: table (0 none, 1 hf, 2 lg)
nt_lvl  = G+29
hu_n    = G+30      ; queued attacks
alloc_e = G+31
title_dy = G+32     ; 2 bytes (8.8 signed)
pl_ckl  = G+34      ; hero: frames fighting (fights took = frames/60)
pl_ckh  = G+35
pl_ohf  = G+36      ; damage taken 8.8
pl_ohl  = G+37
pl_hjf  = G+38      ; drop meter 8.8
pl_hjl  = G+39
pl_mol  = G+40      ; frames waiting at the scroll edge
pl_moh  = G+41
pl_sc0  = G+42      ; score (3 bytes)
pl_sc1  = G+43
pl_sc2  = G+44
lv_xf   = G+45      ; level scroll x (24 bit, <= 0)
lv_xl   = G+46
lv_xh   = G+47
lv_hl   = G+48      ; no monsters: the scroll moves (fr.hl)
lv_mr   = G+49      ; next wave
lv_nw   = G+50      ; number of waves
lv_ta   = G+51      ; par time
lv_qy   = G+52      ; final stage
lv_rk   = G+53      ; scroll factor /256 (0 = 1.0)
lv_ex   = G+54      ; end x (2 bytes, negative)
lv_exh  = G+55
boss_ktl = G+56     ; boss vulnerable since (b.kt), boss_kton = 0: nil
boss_kth = G+57
boss_kton = G+58
boss_qr = G+59      ; boss death particle system
cdata   = G+60      ; cartdata: 0..5 best ranks per difficulty, 6 tutorial seen
kd_n    = G+68      ; results: lines
rank    = G+69
pm_seed = G+70
snd_add = G+71
mus_req = G+72
sfx_q   = G+73      ; 2 queued sfx (number, channel), $ff none
sfx_qc  = G+75
sfx_qo  = G+77      ; start offsets
fx_dirty = G+79
tc_clock = G+80
last_slot = G+81
lv_bgk  = G+82      ; palette bank of the level background
go_cv   = G+83
draw_ok = G+84
upd_n   = G+85
stage_ld = G+86     ; stage graphics in VRAM (0 none)
lv_fl   = G+87
lv_cl   = G+88
ld_gen  = G+89
v_hp    = G+90      ; 2 hp bars shown (lerped), 8.8: hero, last hit
v_hpl   = G+92
results_t = G+94
; waves: x (16 bit), class string, banner, colour, flags
MAXW    = 8
w_xl    = G+96
w_xh    = w_xl+MAXW
w_str   = w_xh+MAXW         ; pointer lo/hi to the spawn string
w_strh  = w_str+MAXW
w_kq    = w_strh+MAXW       ; banner: 0 none, 1 fight!, 2 final fight!
w_end   = w_kq+MAXW
; results table (4 lines)
kd_bx0  = w_end             ; 3 bytes each line score
kd_bx1  = kd_bx0+4
kd_bx2  = kd_bx1+4
kd_sv0  = kd_bx2+4          ; shown values: time in tenths (2 bytes),
kd_sv1  = kd_sv0+2          ; damage taken (2), best combo (1)
kd_sv2  = kd_sv1+2
; sound state
SG      = $c100
ch_on   = SG+0
ch_note = SG+4
ch_accl = SG+8
ch_acch = SG+12
ch_spd  = SG+16
ch_ls   = SG+20
ch_le   = SG+24
ch_pl   = SG+28
ch_ph   = SG+32
ch_prev = SG+36
ch_pitch = SG+40
ch_vol  = SG+44
ch_fx   = SG+48
ch_noise = SG+52
ch_sfx  = SG+56     ; sfx number playing as an effect, $ff = music or none
ch_lead = SG+60
mus_on  = SG+61
mus_pat = SG+62
mus_loop = SG+63
mus_len = SG+64
mus_cnt = SG+65
snd_frame = SG+66
pat_done = SG+67
snd_addl = SG+68
snd_addh = SG+69
mus_mask = SG+70    ; channels kept for music (the cart's channel mask)
ch_mus  = SG+72     ; 4: the channel belongs to the music
VARS_END = SG+80
pl_s_   = G+160     ; the hero between stages: strength, facing, walk speed
pl_qn   = G+161
pl_bv   = G+162
shown_bank = G+163
; renderer arguments
nu_x1   = G+164     ; nu(): 2 bytes each
nu_x2   = G+166
nu_y1   = G+168
nu_y2   = G+170
nu_qc   = G+172
nu_n    = G+174
nu_fg   = G+175
nu_bg   = G+176
nu_rm   = G+177
el_x    = G+178     ; is(): 3 bytes
el_y    = G+181
el_rx   = G+183
el_ry   = G+185
el_w    = G+187
el_c    = G+189
el_dy   = G+190
el_dx   = G+191
el_k    = G+193
el_s0   = G+195
tx_c    = G+197     ; text
tx_ol   = G+198
tx_slot = G+199
tx_n    = G+200
tx_x    = G+201
tx_y    = G+203
tx_sb1  = G+205
tx_sb2  = G+206
tx_h    = G+207
tx_s    = G+208
tx_age  = G+209
tx_i    = G+210
tx_g    = G+211
lr_dx   = G+212     ; lr() arguments
lr_dy   = G+213
lr_dz   = G+214
lr_r    = G+215
lr_oe   = G+216
ent_top = G+217     ; entity slots in use: 0..ent_top-1
ang120  = G+218     ; frames/120 turns (8.8 byte angle), frames/20 turns
ang20   = G+220
fm12    = G+222     ; frames mod 12, frames mod 3
fm3     = G+223
mon_cnt = G+224     ; monsters at the start of the update
rtclok_h = G+225
        .if rtclok_h >= SG
        .error "globals overflow"
        .endif
strbuf  = $c200     ; 64 bytes string builder
numbuf  = $c240     ; 16 bytes
sg_buf  = $c250     ; 128 bytes: a map row
bucket  = sg_buf    ; 130 bytes: first drawable per layer (shares the map row buffer)
eq_iu   = $c300     ; text emitters (per particle system)
eq_sx   = eq_iu+MAXPS
eq_en   = eq_sx+MAXPS
eq_esl  = eq_en+MAXPS
eq_esh  = eq_esl+MAXPS
eq_dhl  = eq_esh+MAXPS
eq_dhh  = eq_dhl+MAXPS
jl_ph_lo = eq_dhh+MAXPS     ; reflection phases
jl_ph_hi = jl_ph_lo+17
sq_ty   = jl_ph_hi+17       ; sound request queue
sq_n    = sq_ty+8
sq_ch   = sq_n+8
sq_of   = sq_ch+8
        .if sq_of+8 > $c400
        .error "$c300 area overflow"
        .endif
bcb_kind = $c400    ; 2 * 195 bytes
tc_str  = $c600     ; text cache keys: NSLOT * SLOTLEN
tc_hash = tc_str+NSLOT*SLOTLEN
tc_len  = tc_hash+NSLOT
tc_age  = tc_len+NSLOT
tc_end  = tc_age+NSLOT
fl_buf  = tc_end      ; floor offsets of the stage: 30 rows * 32 (+64)
rf_idx  = $cf60     ; reflection: row image per row (17)
rf_al   = rf_idx+17 ; amp * fq per row (8.8)
rf_ah   = rf_al+17
hud_sig = rf_ah+17  ; what the cached HUD shows (16)
rf_fq   = hud_sig+16
hud_done = rf_fq+1
fl_key  = hud_done+1  ; the floor cache: stage, ovq, camera x
rf_gen  = fl_key+3    ; reflection widths version, and the cached one
rf_key  = rf_gen+1
        .if fl_buf+30*32 > $d000
        .error "text cache keys / floor offsets overflow"
        .endif
sq4_lo  = $d800     ; quarter squares 512+512
sq4_hi  = $da00
; $dc00-: gen/hi.asm (sfx, music, palettes, sine...) copied under the ROM

        icl 'gen/params.asm'
HI_ADDR = $dc00

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
        sei
        ldx #$ff            ; the whole stack: the loader left it part used
        txs
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
        sta mus_req
        sta sfx_q
        sta sfx_q+1
        sta boss
        sta in_ne
        lda RANDOM
        sta rng
        lda RANDOM
        ora #1
        sta rng+1
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
        jsr make_squares
        jsr vbxe_setup
        lda #1
        sta prev_bank
        lda #0
        sta back_bank
        lda #$40
        sta NMIEN
        cli
        lda #2
        sta kh
        jsr game_init

main_loop
        lda ticks
        beq main_loop
        lda #0
        sta upd_n
ml_tick dec ticks
        jsr game_tick
        inc upd_n
        lda ticks
        beq ml_draw
        lda upd_n
        cmp #4
        bcc ml_tick
        lda #0              ; too far behind: drop the backlog
        sta ticks
ml_draw jsr bcb_begin
        jsr game_draw
        jsr bcb_kick
        ; three framebuffers: wait until the previous frame is on screen,
        ; then queue this one; the next is drawn into the third buffer
wait_present
        lda present_req
        bne wait_present
        lda back_bank
        ora #$80
        sta present_req
        lda o_              ; game over: the melting frame stays in place
        beq ml_rot
        lda back_bank
        sta prev_bank
        jmp main_loop
ml_rot  lda #3
        sec
        sbc prev_bank
        sec
        sbc back_bank
        ldx back_bank
        stx prev_bank
        sta back_bank
        jmp main_loop

clear_ram
        lda #0
        tay
        ldx #$02
cr_lo   stx cr_p+2
cr_p    sta $0200,y
        iny
        bne cr_p
        inx
        cpx #$20
        bne cr_lo
        ldx #$c0
cr_hi   stx cr_h+2
cr_h    sta $c000,y
        iny
        bne cr_h
        inx
        cpx #$d0
        bne cr_hi
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
        bne nmi_r
        inc rtclok_h
nmi_r   lda present_req
        beq vbi_nopresent
        ldy #VB_BLIT            ; show the frame once the blitter is done
        lda (vb),y
        bne vbi_nopresent
        lda present_req
        and #3
        tax
        stx shown_bank
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
        lda pal_req
        beq vbi_nopresent
        jsr apply_palette
vbi_nopresent
        ; 60 Hz game ticks
        lda tick_acc
        clc
        adc #60
vbi_tk  cmp hz
        bcc vbi_noTick
        sbc hz
        ldx ticks           ; at most four ticks of backlog
        cpx #4
        bcs vbi_tk
        inc ticks
        jmp vbi_tk
vbi_noTick
        sta tick_acc
        .if SOUND
        jsr sound_tick
        .endif
        sta POTGO           ; the next paddle scan (POT 0 / POT 1 buttons)
        pla
        tay
        pla
        tax
        pla
irq     rti
xdl_mid dta $d0,$d4,$d8

; ------------------------------------------------------------ input
; PICO-8 buttons: 0 left, 1 right, 2 up, 3 down, 4 O (stab), 5 X (shield).
; As in the Celeste port: joystick 0 moves, its fire is O; the second fire
; is X: SHIFT, joystick 1's fire, or button 2/3 of a 2-button joystick
; (Joy2B+: pin 5 / pin 9, read as POT 0 / POT 1).  Keyboard: W/A/S/D or the
; arrow keys, Z/C/N/O = O, X/V/M/SPACE/RETURN = X.
; Each source counts only after it was seen released once (Altirra holds
; OPTION while booting; an unused POT line may read as pressed).  A POT
; button is any change from the level the line had at startup, since the
; wiring differs (Altirra reads high when pressed, Joy2B+ low).
read_buttons
        lda #0
        sta in_held
        ; joystick 0 directions
        lda PORTA
        eor #15
        and #15
        tax
        lda stick_bits,x
        ldx #0
        jsr in_src
        ; fire
        lda TRIG0
        jsr in_low_o
        ldx #1
        jsr in_src
        ; keyboard
        lda #0
        sta tmp
        lda SKSTAT
        and #4
        bne rb_nk
        lda KBCODE
        and #$3f
        tax
        lda key_bits,x
        sta tmp
rb_nk   lda tmp
        ldx #2
        jsr in_src
        ; SHIFT
        lda SKSTAT
        and #8
        jsr in_low_x
        ldx #3
        jsr in_src
        ; joystick 1 fire
        lda TRIG1
        jsr in_low_x
        ldx #4
        jsr in_src
        ; buttons 2/3 of a 2-button joystick
        ldx #0
        jsr pot_button
        ldx #5
        jsr in_src
        ldx #1
        jsr pot_button
        ldx #6
        jsr in_src
        ; newly pressed
        lda in_prev
        eor #$ff
        and in_held
        sta in_new
        lda #0
        sta in_dbl
        ldx #0
rb_loop lda in_new
        and bit_tab,x
        beq rb_next
        cpx in_ne
        bne rb_set
        ; t - ha < 9  (18 frames)
        lda frames
        sec
        sbc in_hal
        sta tmp+1
        lda frames+1
        sbc in_hah
        bne rb_set
        lda tmp+1
        cmp #18
        bcs rb_set
        lda in_dbl
        ora bit_tab,x
        sta in_dbl
        jmp rb_next
rb_set  stx in_ne
        lda frames
        sta in_hal
        lda frames+1
        sta in_hah
rb_next inx
        cpx #6
        bne rb_loop
        lda in_held
        sta in_prev
        rts
; A = BTN_X when POT line X differs from its resting level (sampled once
; the first scans have finished)
pot_button
        lda rtclok_h
        bne pb_go
        lda rtclok
        cmp #30
        bcc pb_none
pb_go   lda POT0,x
        cmp #128
        lda #0
        rol                 ; 1 = high
        ldy pot_rest,x
        bpl pb_known
        sta pot_rest,x      ; first read: the resting level
pb_none lda #0
        rts
pb_known
        cmp pot_rest,x
        beq pb_none
        lda #$20
        rts
pot_rest dta $ff,$ff
in_low_o
        bne pb_none
        lda #$10
        rts
in_low_x
        bne pb_none
        lda #$20
        rts
; merge source X's buttons (A) unless it has not been released yet
in_src  cmp #0
        bne in_s1
        lda #1
        sta in_armed,x
        rts
in_s1   ldy in_armed,x
        beq in_s2
        ora in_held
        sta in_held
in_s2   rts
in_armed dta 0,0,1,0,0,1,1
bit_tab dta 1,2,4,8,16,32
; PORTA nibble (inverted: 1 = pressed): up 1, down 2, left 4, right 8
stick_bits
        dta 0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15
; keyboard code -> buttons: A D W S, + * - = (arrows), Z C N O = O,
; X V M SPACE RETURN = X
key_bits
        dta $00,$00,$00,$00,$00,$00,$01,$02,$10,$00,$00,$00,$20,$00,$04,$08
        dta $20,$00,$10,$00,$00,$00,$20,$10,$00,$00,$00,$00,$00,$00,$00,$00
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
nv_text dta $7d,c'THE LAIR requires VBXE (FX core) at $D600 or $D700',$9b
nv_len  = *-nv_text

        icl 'src/vbxe.asm'
        icl 'src/math.asm'
        icl 'src/draw.asm'
        icl 'src/text.asm'
        icl 'src/ent.asm'
        icl 'src/part.asm'
        icl 'src/states.asm'
        icl 'src/monsters.asm'
        icl 'src/boss.asm'
        icl 'src/render.asm'
        icl 'src/level.asm'
        icl 'src/game.asm'
code_end
        .if code_end > $9000
        .error "main segment overlaps the MEMAC window"
        .endif
        ini basic_off

; ============================================================ loading
; The staging area $a000-$bfff is filled while the XEX loads; each INI
; routine copies it where it belongs.
        org $a000
        ins 'data/gfx.bin'
        ini stage_gfx
        icl 'gen/load.asm'
        org HI_ADDR,$a000
        icl 'gen/hi.asm'
HI_LEN  = HI_END-HI_START
        .if HI_END > $fffa
        .error "tables under the ROM overflow"
        .endif
        ini stage_hi
        org $a000
        icl 'gen/tables.asm'
        icl 'src/sound.asm'
tables_end
        .if tables_end > $c000
        .error "tables overflow"
        .endif
        run main
