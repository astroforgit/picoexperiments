; ------------------------------------------------------------------
; Object types.  Each routine is entered with X = self and must
; return with X = self.  Comments quote the original Lua where the
; translation is not obvious.
; ------------------------------------------------------------------

;                  -  pl sp sg bl ff sm fr ff lu fw ky ch pf ms bc ob fl rt
type_tile    dta 0, 0, 1,18,22,23, 0,26,28, 0,64, 8,20, 0,86,96, 0,118,0
type_nofruit dta 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0
; which type list (1..4) holds objects of each type, 0 = none
type_listed  dta 0, 0, 0, 1, 0, 2, 0, 0, 0, 0, 3, 0, 0, 4, 0, 0, 0, 0, 0
list_base    dta 0,0,32,64,96
init_tab
        dta a(no_op,player_init,spawn_init,spring_init,balloon_init)
        dta a(ffloor_init,smoke_init,fruit_init,flyfruit_init,lifeup_init)
        dta a(no_op,no_op,chest_init,platform_init,no_op)
        dta a(bigchest_init,orb_init,flag_init,rtitle_init)
update_tab
        dta a(no_op,player_update,spawn_update,spring_update,balloon_update)
        dta a(ffloor_update,smoke_update,fruit_update,flyfruit_update,lifeup_update)
        dta a(fakewall_update,key_update,chest_update,platform_update,no_op)
        dta a(no_op,no_op,no_op,no_op)
draw_tab
        dta a(no_op,player_draw,spawn_draw,default_draw,balloon_draw)
        dta a(ffloor_draw,default_draw,default_draw,flyfruit_draw,lifeup_draw)
        dta a(fakewall_draw,default_draw,default_draw,platform_draw,message_draw)
        dta a(bigchest_draw,orb_draw,flag_draw,rtitle_draw)
no_op   rts

; spawn an object of type :1 at self + (:2,:3)
.macro spawn_rel
        lda o_x,x
        clc
        adc #<(:2)
        sta io_x
        lda o_y,x
        clc
        adc #<(:3)
        sta io_y
        lda #:1
        jsr init_object
.endm

; store a 16.16 constant into an object field triple (f, l, h)
.macro ost24
        lda #<(:4)
        sta :1,x
        lda #>(:4)
        sta :2,x
        lda #^(:4)
        sta :3,x
.endm

; store a 16.16 constant into 3 bytes
.macro set24
        lda #<(:2)
        sta :1
        lda #>(:2)
        sta :1+1
        lda #^(:2)
        sta :1+2
.endm

sfx     sta sfx_req
        rts
psfx    ldy sfx_timer
        bne psfx_no
        sta sfx_req
psfx_no rts

; =========================================================== player
player_init
        lda #0
        ldy #p_wasg-p_jump
pi_clr  sta p_jump,y
        dey
        bpl pi_clr
        lda max_djump
        sta p_djump
        lda #1
        sta o_hbx,x
        lda #3
        sta o_hby,x
        lda #6
        sta o_hbw,x
        lda #5
        sta o_hbh,x
; create_hair(obj)
create_hair
        ldy #4
ch_loop lda o_x,x
        sta hr_xh,y
        lda o_y,x
        sta hr_yh,y
        lda #0
        sta hr_xl,y
        sta hr_yl,y
        dey
        bpl ch_loop
        rts

; PICO-8 16.16 constants of the player physics (rounded like its parser)
ACC_GROUND = $999a      ; 0.6
ACC_AIR    = $6666      ; 0.4
ACC_ICE    = $0ccd      ; 0.05
DECCEL     = $2666      ; 0.15
GRAVITY    = $35c3      ; 0.21
GRAV_HALF  = $1ae1      ; 0.21*0.5
MAXFALL    = $20000
SLIDEFALL  = $6666      ; 0.4
JUMP_SPD   = -$20000
D_FULL     = $50000
D_HALF     = $38919     ; 5*0.70710678118
DASH_ACC   = $18000     ; 1.5
DASH_ACC_D = $10f87     ; 1.5*0.70710678118

player_update
        lda pause_player
        beq pu_go
        rts
pu_go   lda #0
        ldy btn_r
        beq pu_in1
        lda #1
        bne pu_in2
pu_in1  ldy btn_l
        beq pu_in2
        lda #$ff
pu_in2  sta p_input
        ; spikes collide
        lda o_x,x
        clc
        adc o_hbx,x
        sta sa_x
        lda o_y,x
        clc
        adc o_hby,x
        sta sa_y
        lda o_hbw,x
        sta sa_w
        lda o_hbh,x
        sta sa_h
        jsr get_sx
        jsr sign24
        sta sp_xs
        jsr get_sy
        jsr sign24
        sta sp_ys
        ; (like the original, the update carries on after a death)
        jsr spikes_at
        bcc pu_nospk
        jsr kill_player
pu_nospk
        ; bottom death: y>128
        lda o_y,x
        cmp #BIAS+129
        bcc pu_alive
        jsr kill_player
pu_alive
        lda #0
        sta col_ox
        lda #1
        sta col_oy
        jsr is_solid
        lda #0
        rol
        sta p_onground
        jsr is_ice
        lda #0
        rol
        sta p_onice
        ; smoke particles on landing
        lda p_onground
        beq pu_nl
        lda p_wasg
        bne pu_nl
        spawn_rel T_SMOKE,0,4
pu_nl
        ; jump = btn(k_jump) and not p_jump
        lda #0
        ldy btn_j
        beq pu_j1
        ldy p_jump
        bne pu_j1
        lda #1
pu_j1   sta p_jump_now
        lda btn_j
        sta p_jump
        lda p_jump_now
        beq pu_j2
        lda #4
        sta p_jbuf
        bne pu_j3
pu_j2   lda p_jbuf
        beq pu_j3
        dec p_jbuf
pu_j3
        ; dash = btn(k_dash) and not p_dash
        lda #0
        ldy btn_x
        beq pu_d1
        ldy p_dash
        bne pu_d1
        lda #1
pu_d1   sta p_dash_now
        lda btn_x
        sta p_dash
        ; grace / djump refill
        lda p_onground
        beq pu_g1
        lda #6
        sta p_grace
        lda p_djump
        cmp max_djump
        bcs pu_g2
        lda #54
        jsr psfx
        lda max_djump
        sta p_djump
        jmp pu_g2
pu_g1   lda p_grace
        beq pu_g2
        dec p_grace
pu_g2
        ; dash_effect_time -= 1
        lda p_detime
        beq pu_de
        dec p_detime
pu_de
        ; if dash_time > 0
        lda p_dtime
        beq pu_move
        bmi pu_move
        spawn_rel T_SMOKE,0,0
        dec p_dtime
        jsr get_sx
        ldy #2
pu_dc1  lda p_dtx,y
        sta zt,y
        lda p_dax,y
        sta zm,y
        dey
        bpl pu_dc1
        jsr appr24
        jsr put_sx
        jsr get_sy
        ldy #2
pu_dc2  lda p_dty,y
        sta zt,y
        lda p_day,y
        sta zm,y
        dey
        bpl pu_dc2
        jsr appr24
        jsr put_sy
        jmp pu_anim

pu_move
        ; accel: 0.6 ground, 0.4 air, 0.05 ice
        set24 p_acc,ACC_GROUND
        lda p_onground
        bne pu_a1
        set24 p_acc,ACC_AIR
        jmp pu_a2
pu_a1   lda p_onice
        beq pu_a2
        set24 p_acc,ACC_ICE
pu_a2   ; if abs(spd.x) > maxrun
        jsr get_sx
        lda za+2
        bpl pu_ab
        jsr neg24
pu_ab   lda za+2            ; abs > 1.0 ?
        cmp #1
        bcc pu_run
        bne pu_over
        lda za
        ora za+1
        beq pu_run
pu_over ; spd.x = appr(spd.x, sign(spd.x)*maxrun, deccel)
        jsr get_sx
        set24 zt,$10000
        lda za+2
        bpl pu_ov1
        set24 zt,-$10000
pu_ov1  set24 zm,DECCEL
        jmp pu_apx
pu_run  ; spd.x = appr(spd.x, input*maxrun, accel)
        jsr get_sx
        lda #0
        sta zt
        sta zt+1
        lda p_input
        sta zt+2
        ldy #2
pu_rn1  lda p_acc,y
        sta zm,y
        dey
        bpl pu_rn1
pu_apx  jsr appr24
        jsr put_sx
        ; facing
        jsr sign24
        beq pu_face
        lda za+2
        rol
        lda #0
        rol
        sta o_flx,x
pu_face
        ; gravity: zt = maxfall, zm = gravity
        set24 zt,MAXFALL
        set24 zm,GRAVITY
        jsr get_sy
        lda za+2
        bpl pu_gv1
        jsr neg24
pu_gv1  lda za+2            ; abs(spd.y) <= 0.15 ?
        bne pu_gv2
        lda za+1
        cmp #>DECCEL
        bcc pu_gvh
        bne pu_gv2
        lda za
        cmp #<DECCEL+1
        bcs pu_gv2
pu_gvh  set24 zm,GRAV_HALF
pu_gv2  ; wall slide
        lda p_input
        beq pu_ws
        sta col_ox
        lda #0
        sta col_oy
        jsr is_solid
        bcc pu_ws
        jsr is_ice
        bcs pu_ws
        set24 zt,SLIDEFALL
        lda #10
        jsr rnd_n
        cmp #2
        bcs pu_ws
        ldy #5              ; keep zt/zm across the smoke spawn
pu_ws1  lda zt,y
        pha
        dey
        bpl pu_ws1
        lda p_input
        asl
        clc
        adc p_input
        asl                 ; input*6
        clc
        adc o_x,x
        sta io_x
        lda o_y,x
        sta io_y
        lda #T_SMOKE
        jsr init_object
        ldy #0
pu_ws2  pla
        sta zt,y
        iny
        cpy #6
        bne pu_ws2
pu_ws   lda p_onground
        bne pu_jb
        jsr get_sy
        jsr appr24
        jsr put_sy
pu_jb   ; jump
        lda p_jbuf
        jeq pu_dash
        lda p_grace
        beq pu_wj
        ; normal jump
        lda #1
        jsr psfx
        lda #0
        sta p_jbuf
        sta p_grace
        ost24 o_syf,o_syl,o_syh,JUMP_SPD
        spawn_rel T_SMOKE,0,4
        jmp pu_dash
pu_wj   ; wall jump
        lda #$fd
        sta col_ox
        lda #0
        sta col_oy
        jsr is_solid
        lda #$ff
        bcs pu_wj1
        lda #3
        sta col_ox
        jsr is_solid
        lda #1
        bcs pu_wj1
        jmp pu_dash
pu_wj1  sta tmp+4           ; wall_dir
        lda #2
        jsr psfx
        lda #0
        sta p_jbuf
        ost24 o_syf,o_syl,o_syh,JUMP_SPD
        lda #0
        sta o_sxf,x
        sta o_sxl,x
        lda tmp+4           ; spd.x = -wall_dir*(maxrun+1)
        bmi pu_wj2
        lda #$fe
        bne pu_wj3
pu_wj2  lda #2
pu_wj3  sta o_sxh,x
        lda tmp+4
        asl
        clc
        adc tmp+4
        sta col_ox          ; wall_dir*3
        lda #0
        sta col_oy
        jsr is_ice
        bcs pu_dash
        lda tmp+4
        asl
        clc
        adc tmp+4
        asl
        clc
        adc o_x,x
        sta io_x
        lda o_y,x
        sta io_y
        lda #T_SMOKE
        jsr init_object

pu_dash lda p_dash_now
        bne pu_dsh1
        jmp pu_anim
pu_dsh1 lda p_djump
        bne pu_dsh2
        ; dash without a charge
        lda #9
        jsr psfx
        spawn_rel T_SMOKE,0,0
        jmp pu_anim
pu_dsh2 spawn_rel T_SMOKE,0,0
        dec p_djump
        lda #4
        sta p_dtime
        lda #1
        sta has_dashed
        lda #10
        sta p_detime
        ; v_input
        lda #0
        ldy btn_u
        beq pu_v1
        lda #$ff
        bne pu_v2
pu_v1   ldy btn_d
        beq pu_v2
        lda #1
pu_v2   sta tmp+4
        lda #0
        sta o_sxf,x
        sta o_sxl,x
        sta o_sxh,x
        sta o_syf,x
        sta o_syl,x
        sta o_syh,x
        lda p_input
        beq pu_dv
        lda tmp+4
        beq pu_dh
        ; diagonal: d_half
        lda p_input
        jsr dash_half
        jsr put_sx
        lda tmp+4
        jsr dash_half
        jsr put_sy
        jmp pu_dset
pu_dh   ; horizontal: d_full
        lda p_input
        jsr times5
        sta o_sxh,x
        jmp pu_dset
pu_dv   lda tmp+4
        beq pu_dn
        jsr times5
        sta o_syh,x
        jmp pu_dset
pu_dn   ; no direction: face
        lda #1
        ldy o_flx,x
        beq pu_dn1
        lda #$ff
pu_dn1  sta o_sxh,x
pu_dset lda #3
        jsr psfx
        lda #2
        sta freeze
        lda #6
        sta shake
        ; dash_target = 2*sign(spd)
        jsr get_sx
        jsr sign24
        sta tmp+2
        asl
        sta p_dtx+2
        jsr get_sy
        jsr sign24
        sta tmp+3
        asl
        sta p_dty+2
        lda #0
        sta p_dtx
        sta p_dtx+1
        sta p_dty
        sta p_dty+1
        set24 p_dax,DASH_ACC
        set24 p_day,DASH_ACC
        lda tmp+3
        bpl pu_t1
        set24 p_dty,-$18000 ; dash_target.y *= .75
pu_t1   lda tmp+3
        beq pu_t2
        set24 p_dax,DASH_ACC_D
pu_t2   lda tmp+2
        beq pu_anim
        set24 p_day,DASH_ACC_D

pu_anim ; animation
        inc p_sproff
        lda p_onground
        bne pu_an1
        lda p_input
        sta col_ox
        lda #0
        sta col_oy
        jsr is_solid
        lda #3
        bcc pu_an9
        lda #5
        bne pu_an9
pu_an1  lda #6
        ldy btn_d
        bne pu_an9
        lda #7
        ldy btn_u
        bne pu_an9
        lda o_sxf,x
        ora o_sxl,x
        ora o_sxh,x
        beq pu_an2
        lda btn_l
        ora btn_r
        beq pu_an2
        lda p_sproff
        lsr
        lsr
        and #3
        clc
        adc #1
        bne pu_an9
pu_an2  lda #1
pu_an9  sta o_spr,x
        ; next level
        lda o_y,x
        cmp #BIAS-4
        bcs pu_nx
        lda lvl
        cmp #30
        bcs pu_nx
        jsr next_room
        ldx self
pu_nx   lda p_onground
        sta p_wasg
        rts

; A = -1/1 -> za = A*d_half
dash_half
        bmi dhf_neg
        set24 za,D_HALF
        rts
dhf_neg set24 za,-D_HALF
        rts
; A = -1/1 -> A*5 (integer byte)
times5  bmi t5_neg
        lda #5
        rts
t5_neg  lda #$fb
        rts

player_draw
        ; clamp in screen
        lda o_x,x
        cmp #BIAS-1
        bcc pd_cl
        cmp #BIAS+122
        bcc pd_ok
        lda #BIAS+121
        bne pd_cl2
pd_cl   lda #BIAS-1
pd_cl2  sta o_x,x
        lda #0
        sta o_sxf,x
        sta o_sxl,x
        sta o_sxh,x
pd_ok   lda p_djump
        jsr hair_colour
        lda o_flx,x
        beq pd_f1
        lda #$ff
        bne pd_f2
pd_f1   lda #1
pd_f2   jsr draw_hair
        jmp draw_self_hair

; set_hair_color(djump): dr_c = colour, dr_var = sprite variant
hair_colour
        cmp #1
        beq hc_8
        cmp #2
        beq hc_2
        lda #12
        ldy #3
        bne hc_set
hc_8    lda #8
        ldy #0
        beq hc_set
hc_2    lda frames
hc_mod  cmp #6
        bcc hc_m
        sbc #6
        bcs hc_mod
hc_m    cmp #3
        lda #7
        ldy #1
        bcc hc_set
        lda #11
        ldy #2
hc_set  sta hair_col
        sty hair_var
        rts
hair_col dta 8
hair_var dta 0

; draw_hair(obj, facing=A)
draw_hair
        sta tmp+4
        ; last = (x+4-facing*2, y+(btn(down) and 4 or 3))
        asl
        sta tmp
        lda o_x,x
        clc
        adc #4
        sec
        sbc tmp
        sta dh_lxh
        lda #0
        sta dh_lxl
        sta dh_lyl
        lda #3
        ldy btn_d
        beq dh_1
        lda #4
dh_1    clc
        adc o_y,x
        sta dh_lyh
        ldy #0
dh_loop sty dh_i
        ; h.x += (last.x - h.x)/1.5
        sec
        lda dh_lxl
        sbc hr_xl,y
        sta z16
        lda dh_lxh
        sbc hr_xh,y
        sta z16+1
        jsr twothirds
        ldy dh_i
        clc
        lda hr_xl,y
        adc z16
        sta hr_xl,y
        sta dh_lxl
        lda hr_xh,y
        adc z16+1
        sta hr_xh,y
        sta dh_lxh
        ; h.y += (last.y+0.5-h.y)/1.5
        sec
        lda dh_lyl
        sbc hr_yl,y
        sta z16
        lda dh_lyh
        sbc hr_yh,y
        sta z16+1
        lda z16
        clc
        adc #$80
        sta z16
        bcc dh_2
        inc z16+1
dh_2    lda #171
        jsr mulfrac16
        ldy dh_i
        clc
        lda hr_yl,y
        adc z16
        sta hr_yl,y
        sta dh_lyl
        lda hr_yh,y
        adc z16+1
        sta hr_yh,y
        sta dh_lyh
        ; circfill(h.x,h.y,size,8)
        lda hr_xh,y
        sta dr_x
        lda hr_yh,y
        sta dr_y
        lda hair_col
        sta dr_c
        lda dh_size,y
        jsr circ_draw
        ldx self
        ldy dh_i
        iny
        cpy #5
        jne dh_loop
        rts
; z16 = z16*0.664 (x/2+x/8+x/32+x/128), signed
twothirds
        lda z16+1
        cmp #$80
        ror
        sta tmp+1
        lda z16
        ror
        sta tmp             ; t = x/2
        sta tmp+2
        lda tmp+1
        sta tmp+3           ; acc = x/2
        ldy #3
tt_loop lda tmp+1           ; t /= 4
        cmp #$80
        ror
        sta tmp+1
        ror tmp
        lda tmp+1
        cmp #$80
        ror
        sta tmp+1
        ror tmp
        lda tmp+2
        clc
        adc tmp
        sta tmp+2
        lda tmp+3
        adc tmp+1
        sta tmp+3
        dey
        bne tt_loop
        lda tmp+2
        sta z16
        lda tmp+3
        sta z16+1
        rts
dh_size dta 2,2,1,1,1
dh_i    dta 0
dh_lxl  dta 0
dh_lxh  dta 0
dh_lyl  dta 0
dh_lyh  dta 0

; spr(spr,x,y,1,1,flip.x,flip.y) with the hair palette
draw_self_hair
        lda hair_var
        ldy o_spr,x
        cpy #16
        bcc dsh_1
        lda #0
dsh_1   sta dr_var
        jsr draw_sprite_self
        lda #0
        sta dr_var
        rts

kill_player
        lda #12
        sta sfx_timer
        lda #0
        jsr sfx
        inc deaths
        bne kp_1
        inc deaths+1
kp_1    lda #10
        sta shake
        jsr destroy_object
        lda o_x,x
        clc
        adc #4
        sta tmp
        lda o_y,x
        clc
        adc #4
        sta tmp+1
        ldy #7
kp_loop lda tmp
        sta dp_xh,y
        lda tmp+1
        sta dp_yh,y
        lda #0
        sta dp_xl,y
        sta dp_yl,y
        lda #10
        sta dp_t,y
        lda dead_sx_lo,y
        sta dp_sxl,y
        lda dead_sx_hi,y
        sta dp_sxh,y
        lda dead_sy_lo,y
        sta dp_syl,y
        lda dead_sy_hi,y
        sta dp_syh,y
        dey
        bpl kp_loop
; restart_room()
restart_room
        lda #1
        sta will_restart
        lda #15
        sta delay_restart
        rts

; =========================================================== player_spawn
; v0 state, v1 delay, v2 target.y
spawn_init
        lda #4
        jsr sfx
        lda #3
        sta o_spr,x
        lda o_y,x
        sta o_v2,x
        lda #BIAS+128
        sta o_y,x
        ost24 o_syf,o_syl,o_syh,-$40000
        lda #0
        sta o_sol,x
        jmp create_hair

spawn_update
        lda o_v0,x
        bne su_s1
        ; jumping up
        lda o_v2,x
        clc
        adc #16
        sta tmp
        lda o_y,x
        cmp tmp
        bcs su_done
        lda #1
        sta o_v0,x
        lda #3
        sta o_v1,x
su_done rts
su_s1   cmp #1
        bne su_s2
        ; falling
        lda o_syl,x
        clc
        adc #128
        sta o_syl,x
        bcc su_f1
        inc o_syh,x
su_f1   jsr su_pos
        beq su_f2
        lda o_v1,x
        beq su_f2
        lda #0
        sta o_syf,x
        sta o_syl,x
        sta o_syh,x
        dec o_v1,x
su_f2   jsr su_pos
        beq su_done
        lda o_v2,x
        cmp o_y,x
        bcs su_done
        sta o_y,x
        lda #0
        sta o_sxf,x
        sta o_sxl,x
        sta o_sxh,x
        sta o_syf,x
        sta o_syl,x
        sta o_syh,x
        lda #2
        sta o_v0,x
        lda #5
        sta o_v1,x
        lda #5
        sta shake
        spawn_rel T_SMOKE,0,4
        lda #5
        jmp sfx
su_s2   ; landing
        dec o_v1,x
        lda #6
        sta o_spr,x
        lda o_v1,x
        jpl su_done
        jsr destroy_object
        lda o_x,x
        sta io_x
        lda o_y,x
        sta io_y
        lda #T_PLAYER
        jmp init_object
; Z=0 when spd.y > 0
su_pos  lda o_syh,x
        bmi su_p0
        ora o_syl,x
        ora o_syf,x
        rts
su_p0   lda #0
        rts

spawn_draw
        lda max_djump
        jsr hair_colour
        lda #1
        jsr draw_hair
        jmp draw_self_hair

; =========================================================== spring
; v0 hide_in, v1 hide_for, v2 delay
spring_init
        rts
spring_update
        lda o_v1,x
        beq sg_u1
        dec o_v1,x
        jne sg_hide
        lda #18
        sta o_spr,x
        lda #0
        sta o_v2,x
        jmp sg_hide
sg_u1   lda o_spr,x
        cmp #18
        jne sg_u3
        lda #0
        tay
        jsr check_player
        jcc sg_hide
        lda o_syh,y         ; hit.spd.y >= 0
        jmi sg_hide
        lda #19
        sta o_spr,x
        lda o_y,x
        sec
        sbc #4
        sta o_y,y
        ; hit.spd.x *= 0.2
        sty tmp+5
        stx tmp+6
        tya
        tax
        jsr get_sx
        set24 zm,$3333
        jsr mul24
        jsr put_sx
        ost24 o_syf,o_syl,o_syh,-$30000
        ldx tmp+6
        ldy tmp+5
        lda max_djump
        sta p_djump
        lda #10
        sta o_v2,x
        spawn_rel T_SMOKE,0,0
        ; breakable below us
        lda #0
        sta col_ox
        lda #1
        sta col_oy
        lda #T_FALLFLOOR
        jsr collide
        bcc sg_nb
        tya
        jsr break_fall_floor
sg_nb   lda #8
        jsr psfx
        jmp sg_hide
sg_u3   lda o_v2,x
        beq sg_hide
        dec o_v2,x
        bne sg_hide
        lda #18
        sta o_spr,x
sg_hide ; begin hiding
        lda o_v0,x
        beq sg_done
        dec o_v0,x
        bne sg_done
        lda #60
        sta o_v1,x
        lda #0
        sta o_spr,x
sg_done rts

; =========================================================== balloon
; v0/v1 offset (turns, 16-bit fraction), v2 start, v3 timer, v4 turns%3
balloon_init
        jsr rnd8
        sta o_v1,x
        jsr rnd8
        sta o_v0,x
        lda o_y,x
        sta o_v2,x
        lda #$ff
        sta o_hbx,x
        sta o_hby,x
        lda #10
        sta o_hbw,x
        sta o_hbh,x
        rts
balloon_update
        lda o_spr,x
        cmp #22
        bne bu_hidden
        ; offset += 0.01
        lda o_v0,x
        clc
        adc #<655
        sta o_v0,x
        lda o_v1,x
        adc #>655
        sta o_v1,x
        bcc bu_1
        inc o_v4,x
        lda o_v4,x
        cmp #3
        bcc bu_1
        lda #0
        sta o_v4,x
bu_1    ldy o_v1,x
        lda balloon_off,y
        clc
        adc o_v2,x
        sta o_y,x
        lda #0
        tay
        jsr check_player
        bcc bu_done
        lda p_djump
        cmp max_djump
        bcs bu_done
        lda #6
        jsr psfx
        spawn_rel T_SMOKE,0,0
        lda max_djump
        sta p_djump
        lda #0
        sta o_spr,x
        lda #60
        sta o_v3,x
bu_done rts
bu_hidden
        lda o_v3,x
        beq bu_back
        dec o_v3,x
        rts
bu_back lda #7
        jsr psfx
        spawn_rel T_SMOKE,0,0
        lda #22
        sta o_spr,x
        rts
balloon_draw
        lda o_spr,x
        cmp #22
        bne bd_done
        ; spr(13+(offset*8)%3, x, y+6)
        lda o_v1,x
        lsr
        lsr
        lsr
        lsr
        lsr
        clc
        adc o_v4,x
        adc o_v4,x
bd_mod  cmp #3
        bcc bd_m
        sbc #3
        bcs bd_mod
bd_m    clc
        adc #13
        sta tmp
        lda o_x,x
        sta dr_x
        lda o_y,x
        clc
        adc #6
        sta dr_y
        lda #0
        sta dr_fx
        sta dr_fy
        lda tmp
        jsr spr_draw
        ldx self
        lda #22
        jmp draw_spr_at_self
bd_done rts

; =========================================================== fall_floor
; v0 state, v1 delay
ffloor_init
        rts
ffloor_update
        lda o_v0,x
        bne ff_s1
        lda #0
        ldy #$ff
        jsr check_player
        bcs ff_brk
        lda #$ff
        ldy #0
        jsr check_player
        bcs ff_brk
        lda #1
        ldy #0
        jsr check_player
        bcc ff_done
ff_brk  txa
        jmp break_fall_floor
ff_s1   cmp #1
        bne ff_s2
        dec o_v1,x
        beq ff_1
        bpl ff_done
ff_1    lda #2
        sta o_v0,x
        lda #60
        sta o_v1,x
        lda #0
        sta o_coll,x
ff_done rts
ff_s2   dec o_v1,x
        beq ff_2
        bpl ff_done
ff_2    lda #0
        tay
        jsr check_player
        bcc ff_3
        lda #0              ; stay at 0: retry next frame
        sta o_v1,x
        rts
ff_3    lda #7
        jsr psfx
        lda #0
        sta o_v0,x
        lda #1
        sta o_coll,x
        spawn_rel T_SMOKE,0,0
        rts

; break_fall_floor(obj A)
break_fall_floor
        tay
        lda o_v0,y
        bne bff_done
        lda self
        pha
        sty self
        ldx self
        lda #15
        jsr psfx
        lda #1
        sta o_v0,x
        lda #15
        sta o_v1,x
        spawn_rel T_SMOKE,0,0
        lda #0
        sta col_ox
        lda #$ff
        sta col_oy
        lda #T_SPRING
        jsr collide
        bcc bff_ns
        lda #15             ; break_spring: hide_in=15
        sta o_v0,y
bff_ns  pla
        sta self
        tax
        rts
bff_done ldx self
        rts

ffloor_draw
        lda o_v0,x
        cmp #2
        beq ffd_done
        cmp #1
        beq ffd_shake
        lda #23
        jmp draw_spr_at_self
ffd_shake
        ; spr(23+(15-delay)/5)
        lda #15
        sec
        sbc o_v1,x
        ldy #0
ffd_div cmp #5
        bcc ffd_d
        sbc #5
        iny
        bne ffd_div
ffd_d   tya
        clc
        adc #23
        jmp draw_spr_at_self
ffd_done rts

; =========================================================== smoke
smoke_init
        lda #29
        sta o_spr,x
        ost24 o_syf,o_syl,o_syh,-$199a  ; -0.1
        jsr rnd8                    ; 0.3+rnd(0.2)
        sta mul_a
        lda #51
        sta mul_b
        jsr mul8
        lda mul_r
        clc
        adc #<$4ccd
        sta o_sxf,x
        lda mul_r+1
        adc #>$4ccd
        sta o_sxl,x
        lda #0
        sta o_sxh,x
        jsr rnd8                    ; x += -1+rnd(2)
        asl
        lda o_x,x
        sbc #0
        sta o_x,x
        jsr rnd8
        asl
        lda o_y,x
        sbc #0
        sta o_y,x
        jsr maybe
        sta o_flx,x
        jsr maybe
        sta o_fly,x
        lda #0
        sta o_sol,x
        rts
smoke_update
        lda o_sprf,x
        clc
        adc #51
        sta o_sprf,x
        bcc smu_1
        inc o_spr,x
smu_1   lda o_spr,x
        cmp #32
        bcc smu_2
        jmp destroy_object
smu_2   rts

; =========================================================== fruit
; v0 start, v1 off
fruit_init
        lda o_y,x
        sta o_v0,x
        rts
fruit_update
        jsr collect_fruit
        bcs fu_done
        ldy o_v1,x
        iny
        cpy #40
        bcc fu_1
        ldy #0
fu_1    tya
        sta o_v1,x
        lda fruit_off,y
        clc
        adc o_v0,x
        sta o_y,x
fu_done rts

; hit=collide(player): collect.  C=1 when collected (and destroyed)
collect_fruit
        lda #0
        tay
        jsr check_player
        bcc cf_no
        lda max_djump
        sta p_djump
        lda #20
        sta sfx_timer
        lda #13
        jsr sfx
        ldy lvl
        lda #1
        sta got_fruit,y
        spawn_rel T_LIFEUP,0,0
        jsr destroy_object
        sec
cf_no   rts

; =========================================================== fly_fruit
; v0 start, v1 fly, v2 step index, v3 sfx_delay
flyfruit_init
        lda o_y,x
        sta o_v0,x
        lda #0
        sta o_sol,x
        lda #8
        sta o_v3,x
        rts
flyfruit_update
        lda o_v1,x
        beq fyu_wait
        ; fly away
        lda o_v3,x
        beq fyu_1
        dec o_v3,x
        bne fyu_1
        lda #20
        sta sfx_timer
        lda #14
        jsr sfx
fyu_1   jsr get_sy
        set24 zt,-$38000
        set24 zm,$4000
        jsr appr24
        jsr put_sy
        lda o_y,x
        cmp #BIAS-16
        bcs fyu_col
        jmp destroy_object
fyu_wait
        lda has_dashed
        beq fyu_2
        lda #1
        sta o_v1,x
fyu_2   ldy o_v2,x
        iny
        cpy #20
        bcc fyu_3
        ldy #0
fyu_3   tya
        sta o_v2,x
        lda fly_spd_f,y
        sta o_syf,x
        lda fly_spd_lo,y
        sta o_syl,x
        lda fly_spd_hi,y
        sta o_syh,x
fyu_col jsr collect_fruit
        rts
flyfruit_draw
        lda #0
        sta tmp+4
        lda o_v1,x
        bne fyd_1
        ldy o_v2,x
        lda fly_spd_hi,y
        bpl fyd_1
        ; off = 1+max(0,sign(y-start))
        lda #1
        sta tmp+4
        lda o_y,x
        cmp o_v0,x
        beq fyd_1
        bcc fyd_1
        inc tmp+4
fyd_1   lda o_x,x
        sec
        sbc #6
        sta dr_x
        lda o_y,x
        sec
        sbc #2
        sta dr_y
        lda #1
        sta dr_fx
        lda #0
        sta dr_fy
        lda #45
        clc
        adc tmp+4
        jsr spr_draw
        ldx self
        lda #28
        jsr draw_spr_at_self
        lda o_x,x
        clc
        adc #6
        sta dr_x
        lda o_y,x
        sec
        sbc #2
        sta dr_y
        lda #0
        sta dr_fx
        sta dr_fy
        lda #45
        clc
        adc tmp+4
        jsr spr_draw
        ldx self
        rts

; =========================================================== lifeup
; v0 duration, v1 flash (half steps)
lifeup_init
        ost24 o_syf,o_syl,o_syh,-$4000
        lda #30
        sta o_v0,x
        lda o_x,x
        sec
        sbc #2
        sta o_x,x
        lda o_y,x
        sec
        sbc #4
        sta o_y,x
        lda #0
        sta o_sol,x
        rts
lifeup_update
        dec o_v0,x
        beq luu_1
        bpl luu_2
luu_1   jmp destroy_object
luu_2   rts
lifeup_draw
        inc o_v1,x
        lda o_v1,x
        lsr
        and #1
        clc
        adc #7
        sta dr_c
        lda o_x,x
        sec
        sbc #2
        sta dr_x
        lda o_y,x
        sta dr_y
        mwa #str_1000 txtp
        jsr print
        ldx self
        rts

; =========================================================== fake_wall
fakewall_update
        lda #$ff
        sta o_hbx,x
        sta o_hby,x
        lda #18
        sta o_hbw,x
        sta o_hbh,x
        lda #0
        tay
        jsr check_player
        jcc fw_no
        lda p_detime
        jeq fw_no
        ; hit.spd.x = -sign(hit.spd.x)*1.5
        lda o_sxh,y
        bmi fw_pos
        ora o_sxl,y
        ora o_sxf,y
        beq fw_z
        lda #<(-384)
        sta o_sxl,y
        lda #>(-384)
        sta o_sxh,y
        jmp fw_z
fw_pos  lda #<384
        sta o_sxl,y
        lda #>384
        sta o_sxh,y
fw_z    lda #0
        sta o_sxf,y
        sta o_syf,y
        lda #<(-384)
        sta o_syl,y
        lda #>(-384)
        sta o_syh,y
        lda #$ff
        sta p_dtime
        lda #20
        sta sfx_timer
        lda #16
        jsr sfx
        jsr destroy_object
        spawn_rel T_SMOKE,0,0
        spawn_rel T_SMOKE,8,0
        spawn_rel T_SMOKE,0,8
        spawn_rel T_SMOKE,8,8
        spawn_rel T_FRUIT,4,4
fw_no   lda #0
        sta o_hbx,x
        sta o_hby,x
        lda #16
        sta o_hbw,x
        sta o_hbh,x
        rts
fakewall_draw
        lda #64
        jsr draw_spr_at_self
        lda o_x,x
        clc
        adc #8
        sta dr_x
        lda #65
        jsr spr_draw
        ldx self
        lda o_y,x
        clc
        adc #8
        sta dr_y
        lda #81
        jsr spr_draw
        ldx self
        lda o_x,x
        sta dr_x
        lda #80
        jsr spr_draw
        ldx self
        rts

; =========================================================== key
key_update
        lda o_spr,x
        sta tmp
        ldy frames
        lda key_spr,y
        sta o_spr,x
        cmp #10
        bne ku_1
        cmp tmp
        beq ku_1
        lda o_flx,x
        eor #1
        sta o_flx,x
ku_1    lda #0
        tay
        jsr check_player
        bcc ku_done
        lda #23
        jsr sfx
        lda #10
        sta sfx_timer
        jsr destroy_object
        lda #1
        sta has_key
ku_done rts

; =========================================================== chest
; v0 start, v1 timer
chest_init
        lda o_x,x
        sec
        sbc #4
        sta o_x,x
        sta o_v0,x
        lda #20
        sta o_v1,x
        rts
chest_update
        lda has_key
        beq chu_done
        dec o_v1,x
        lda #3
        jsr rnd_n
        clc
        adc o_v0,x
        sec
        sbc #1
        sta o_x,x
        lda o_v1,x
        beq chu_open
        bpl chu_done
chu_open
        lda #20
        sta sfx_timer
        lda #16
        jsr sfx
        spawn_rel T_FRUIT,0,-4
        jmp destroy_object
chu_done rts

; =========================================================== platform
; v0 dir, v1 last
platform_init
        lda o_x,x
        sec
        sbc #4
        sta o_x,x
        sta o_v1,x
        lda #0
        sta o_sol,x
        lda #16
        sta o_hbw,x
        rts
platform_update
        ; spd.x = dir*0.65
        lda o_v0,x
        bmi plu_l
        ost24 o_sxf,o_sxl,o_sxh,$a666
        jmp plu_1
plu_l   ost24 o_sxf,o_sxl,o_sxh,-$a666
plu_1   lda o_x,x
        cmp #BIAS-16
        bcs plu_2
        lda #BIAS+128
        sta o_x,x
        bne plu_3
plu_2   cmp #BIAS+129
        bcc plu_3
        lda #BIAS-16
        sta o_x,x
plu_3   lda #0
        tay
        jsr check_player
        bcs plu_last
        lda #0
        ldy #$ff
        jsr check_player
        bcc plu_last
        ; hit.move_x(x-last,1)
        lda o_x,x
        sec
        sbc o_v1,x
        sta amount
        clc
        adc #8              ; ignore the wrap-around jump
        cmp #17
        bcs plu_last
        tya
        tax
        lda #1
        jsr move_x
        ldx self
plu_last
        lda o_x,x
        sta o_v1,x
        rts
platform_draw
        lda o_x,x
        sta dr_x
        lda o_y,x
        sec
        sbc #1
        sta dr_y
        lda #0
        sta dr_fx
        sta dr_fy
        lda #11
        jsr spr_draw
        ldx self
        lda o_x,x
        clc
        adc #8
        sta dr_x
        lda #12
        jsr spr_draw
        ldx self
        rts

; =========================================================== message
; v0 index (half characters), v1 last
MSG_LEN = 68
message_draw
        lda #4
        ldy #0
        jsr check_player
        bcs md_show
        lda #0
        sta o_v0,x
        sta o_v1,x
        rts
md_show lda o_v0,x
        cmp #MSG_LEN*2
        bcs md_text
        inc o_v0,x
        ; if index>=last+1 then last+=1 sfx(35)
        lda o_v0,x
        lsr
        cmp o_v1,x
        beq md_text
        bcc md_text
        inc o_v1,x
        lda #35
        jsr sfx
md_text lda o_v0,x
        lsr
        sta md_n
        beq md_done
        lda #BIAS+8
        sta md_x
        lda #BIAS+96
        sta md_y
        ldy #0
md_loop sty md_i
        lda message_text,y
        cmp #'#'
        beq md_nl
        sta md_ch
        lda md_x
        sec
        sbc #2
        sta dr_x
        clc
        adc #9
        sta dr_x1
        lda md_y
        sec
        sbc #2
        sta dr_y
        clc
        adc #8
        sta dr_y1
        lda #7
        sta dr_c
        jsr fill_rect
        lda md_ch
        sta md_str
        lda md_x
        sta dr_x
        lda md_y
        sta dr_y
        lda #0
        sta dr_c
        mwa #md_str txtp
        jsr print
        lda md_x
        clc
        adc #5
        sta md_x
        jmp md_next
md_nl   lda #BIAS+8
        sta md_x
        lda md_y
        clc
        adc #7
        sta md_y
md_next ldy md_i
        iny
        cpy md_n
        bcc md_loop
md_done ldx self
        rts
md_n    dta 0
md_i    dta 0
md_x    dta 0
md_y    dta 0
md_ch   dta 0
md_str  dta 0,0
message_text
        dta c'-- celeste mountain --#this memorial to those# perished on the climb'
        .if *-message_text <> MSG_LEN
        .error "message length"
        .endif

; =========================================================== big_chest
; v0 state, v1 timer
bigchest_init
        lda #16
        sta o_hbw,x
        rts
bigchest_draw
        lda o_v0,x
        beq bcd_s0
        cmp #1
        jne bcd_bottom
        jmp bcd_s1
bcd_s0  lda #0
        ldy #8
        jsr check_player
        bcc bcd_closed
        ; hit.is_solid(0,1)
        sty tmp+4
        tya
        tax
        lda #0
        sta col_ox
        lda #1
        sta col_oy
        jsr is_solid
        ldx self
        bcc bcd_closed
        lda #$fe
        sta mus_req
        lda #37
        jsr sfx
        lda #1
        sta pause_player
        ldy tmp+4
        lda #0
        sta o_sxf,y
        sta o_sxl,y
        sta o_sxh,y
        sta o_syf,y
        sta o_syl,y
        sta o_syh,y
        lda #1
        sta o_v0,x
        spawn_rel T_SMOKE,0,0
        spawn_rel T_SMOKE,8,0
        lda #60
        sta o_v1,x
        lda #0
        sta bc_n
bcd_closed
        lda #96
        jsr draw_spr_at_self
        lda o_x,x
        clc
        adc #8
        sta dr_x
        lda #97
        jsr spr_draw
        ldx self
bcd_bottom
        lda o_x,x
        sta dr_x
        lda o_y,x
        clc
        adc #8
        sta dr_y
        lda #0
        sta dr_fx
        sta dr_fy
        lda #112
        jsr spr_draw
        ldx self
        lda o_x,x
        clc
        adc #8
        sta dr_x
        lda #113
        jsr spr_draw
        ldx self
        rts
bcd_s1  dec o_v1,x
        lda #5
        sta shake
        lda #1
        sta flash_bg
        lda o_v1,x
        bmi bcd_add0
        cmp #46
        bcs bcd_add0
        lda bc_n
        cmp #50
        bcs bcd_add0
        tay
        inc bc_n
        lda #14
        jsr rnd_n
        clc
        adc #1
        ldy bc_n
        sta bc_x-1,y
        lda #0
        sta bc_yl-1,y
        sta bc_yh-1,y
        lda #32
        jsr rnd_n
        clc
        adc #32
        ldy bc_n
        sta bc_h-1,y
        lda #8
        jsr rnd_n
        clc
        adc #8
        ldy bc_n
        sta bc_s-1,y
bcd_add0
        lda o_v1,x
        bpl bcd_beams
        ; timer < 0: open
        lda #2
        sta o_v0,x
        lda #0
        sta bc_n
        sta flash_bg
        lda #1
        sta new_bg
        spawn_rel T_ORB,4,4
        lda #0
        sta pause_player
bcd_beams
        ldy #0
bcd_bl  cpy bc_n
        bcs bcd_bdone
        sty tmp+5
        ; p.y += p.spd
        lda bc_yl,y
        clc
        adc bc_s,y
        sta bc_yl,y
        bcc bcd_b1
        lda bc_yh,y
        adc #0
        sta bc_yh,y
bcd_b1  ; top = y+8-p.y (16-bit biased)
        lda o_y,x
        clc
        adc #8
        sta tmp+2           ; bottom limit y+8
        sec
        sbc bc_yl,y
        sta tmp
        lda #0
        sbc bc_yh,y
        sta tmp+1
        ; bottom = min(top+h, y+8)
        lda tmp
        clc
        adc bc_h,y
        sta tmp+3
        lda tmp+1
        adc #0
        bmi bcd_bskip       ; entirely above the screen
        bne bcd_b2
        lda tmp+3
        cmp tmp+2
        bcc bcd_b3
bcd_b2  lda tmp+2
        sta tmp+3
bcd_b3  lda tmp+1
        beq bcd_b4
        lda #0
        sta tmp
bcd_b4  lda tmp
        cmp #BIAS-8
        bcs bcd_b5
        lda #BIAS-8
bcd_b5  sta dr_y
        lda tmp+3
        cmp dr_y
        bcc bcd_bskip
        sta dr_y1
        lda o_x,x
        clc
        adc bc_x,y
        sta dr_x
        sta dr_x1
        lda #7
        sta dr_c
        jsr fill_rect
        ldx self
bcd_bskip
        ldy tmp+5
        iny
        bne bcd_bl
bcd_bdone
        jmp bcd_bottom

; =========================================================== orb
orb_init
        ost24 o_syf,o_syl,o_syh,-$40000
        lda #0
        sta o_sol,x
        rts
orb_draw
        jsr get_sy
        set24 zt,0
        set24 zm,$8000
        jsr appr24
        jsr put_sy
        jsr sign24
        bne od_draw
        lda #0
        tay
        jsr check_player
        bcc od_draw
        lda #45
        sta music_timer
        lda #51
        jsr sfx
        lda #10
        sta freeze
        sta shake
        jsr destroy_object
        lda #2
        sta max_djump
        sta p_djump
od_draw lda #102
        jsr draw_spr_at_self
        ; 8 circles around: frames/30 turns + i/8
        lda frames
        sta mul_a
        lda #137            ; 256/30*16 = 136.5 -> (frames*137)>>4
        sta mul_b
        jsr mul8
        lda mul_r
        lsr mul_r+1
        ror
        lsr mul_r+1
        ror
        lsr mul_r+1
        ror
        lsr mul_r+1
        ror
        sta tmp+4
        lda #0
        sta tmp+5
od_loop lda tmp+4
        clc
        adc tmp+5
        tay
        lda o_x,x
        clc
        adc #4
        clc
        adc ring_cos,y
        sta dr_x
        lda o_y,x
        clc
        adc #4
        clc
        adc ring_sin,y
        sta dr_y
        lda #7
        sta dr_c
        lda #1
        jsr circ_draw
        ldx self
        lda tmp+5
        clc
        adc #32
        sta tmp+5
        bne od_loop
        rts

; =========================================================== flag
; v0 score, v1 show
flag_init
        lda o_x,x
        clc
        adc #5
        sta o_x,x
        ldy #0
        lda #0
fi_loop clc
        adc got_fruit,y
        iny
        cpy #30
        bne fi_loop
        sta o_v0,x
        rts
flag_draw
        lda frames
        ldy #0
fd_div  cmp #5
        bcc fd_d
        sbc #5
        iny
        bne fd_div
fd_d    tya
fd_mod  cmp #3
        bcc fd_m
        sbc #3
        bcs fd_mod
fd_m    clc
        adc #118
        sta o_spr,x
        jsr draw_spr_at_self
        lda o_v1,x
        bne fd_show
        lda #0
        tay
        jsr check_player
        bcc fd_done
        lda #55
        jsr sfx
        lda #30
        sta sfx_timer
        lda #1
        sta o_v1,x
fd_done rts
fd_show lda #BIAS+32
        sta dr_x
        lda #BIAS+2
        sta dr_y
        lda #BIAS+96
        sta dr_x1
        lda #BIAS+31
        sta dr_y1
        lda #0
        sta dr_c
        jsr fill_rect
        lda #BIAS+55
        sta dr_x
        lda #BIAS+6
        sta dr_y
        lda #0
        sta dr_fx
        sta dr_fy
        lda #26
        jsr spr_draw
        ldx self
        ; "x"..score
        lda #'x'
        sta txtbuf
        lda o_v0,x
        ldy #0
        jsr fmt_u16_at1
        lda #BIAS+64
        sta dr_x
        lda #BIAS+9
        sta dr_y
        lda #7
        sta dr_c
        mwa #txtbuf txtp
        jsr print
        lda #BIAS+49
        ldy #BIAS+16
        jsr draw_time
        ; "deaths:"..deaths
        ldy #6
fd_cp   lda str_deaths,y
        sta txtbuf,y
        dey
        bpl fd_cp
        lda deaths
        ldy deaths+1
        ldx #7
        jsr fmt_u16_x
        lda #BIAS+48
        sta dr_x
        lda #BIAS+24
        sta dr_y
        lda #7
        sta dr_c
        mwa #txtbuf txtp
        jsr print
        ldx self
        rts
str_deaths dta c'deaths:'

; =========================================================== room_title
; v0 delay
rtitle_init
        lda #5
        sta o_v0,x
        rts
rtitle_draw
        dec o_v0,x
        lda o_v0,x
        jpl rt_done
        cmp #$e2            ; delay < -30
        bcs rt_show
        jmp destroy_object
rt_show lda #BIAS+24
        sta dr_x
        lda #BIAS+58
        sta dr_y
        lda #BIAS+104
        sta dr_x1
        lda #BIAS+70
        sta dr_y1
        lda #0
        sta dr_c
        jsr fill_rect
        lda #7
        sta dr_c
        lda #BIAS+62
        sta dr_y
        lda room_x
        cmp #3
        bne rt_1
        lda room_y
        cmp #1
        bne rt_1
        lda #BIAS+48
        sta dr_x
        mwa #str_oldsite txtp
        jmp rt_print
rt_1    lda lvl
        cmp #30
        bne rt_2
        lda #BIAS+52
        sta dr_x
        mwa #str_summit txtp
        jmp rt_print
rt_2    ; level = (1+lvl)*100
        ldy lvl
        iny
        tya
        sta mul_a
        lda #100
        sta mul_b
        jsr mul8
        lda mul_r
        ldy mul_r+1
        ldx #0
        jsr fmt_u16_x
        ldx tmp             ; digit count from fmt
        lda #' '
        sta txtbuf,x
        lda #'m'
        sta txtbuf+1,x
        lda #0
        sta txtbuf+2,x
        lda #BIAS+52
        ldy mul_r+1
        cpy #>1000
        bcc rt_small
        bne rt_x
        ldy mul_r
        cpy #<1000
        bcs rt_x
rt_small
        lda #BIAS+54
rt_x    sta dr_x
        mwa #txtbuf txtp
rt_print
        jsr print
        lda #BIAS+4
        ldy #BIAS+4
        jsr draw_time
rt_done ldx self
        rts
str_oldsite dta c'old site',0
str_summit  dta c'summit',0
str_1000    dta c'1000',0

; =========================================================== shared draws
default_draw
        lda o_spr,x
        beq dd_none
draw_sprite_self
        lda o_spr,x
; spr(A, x, y, 1, 1, flip.x, flip.y)
draw_spr_at_self
        pha
        lda o_x,x
        sta dr_x
        lda o_y,x
        sta dr_y
        lda o_flx,x
        sta dr_fx
        lda o_fly,x
        sta dr_fy
        pla
        jsr spr_draw
        ldx self
dd_none rts
