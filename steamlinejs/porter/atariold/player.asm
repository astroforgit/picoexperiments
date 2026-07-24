JOY_UP = %00000001
JOY_DOWN = %00000010
JOY_LEFT = %00000100
JOY_RIGHT = %00001000
JOY_JUMP = %00010000
SPR_PLAYER_IDLE = 1
SPR_PLAYER_RUN_START = 3
SPR_PLAYER_JUMP = 7
SPR_PLAYER_FALL = 8

init_player
			lda level_idx
			asl
			asl
			asl
			tay
			lda level_meta+0,y
			sta plr_x
			lda level_meta+1,y
			sta plr_y
			mva #0 plr_dx
			mva #0 plr_dxh
			mva #0 plr_dy
			mva #0 plr_dyh
			mva #0 plr_flip
			mva #0 plr_onground
			mva #0 plr_canTele
			mva #SPR_PLAYER_IDLE plr_sprite
			rts

update_player
			lda joy_pressed
			and #JOY_JUMP
			beq up_no_jump
			lda plr_onground
			beq up_no_jump
			lda #$fc
			sta plr_dyh
			mva #0 plr_onground
up_no_jump
			lda joy_state
			and #$0c
			bne up_input
			lda plr_dxh
			beq up_gravity
			bmi up_friction_neg
			dec plr_dxh
			jmp up_gravity
up_friction_neg
			inc plr_dxh
			jmp up_gravity
up_input
			lda joy_state
			and #JOY_LEFT
			beq up_right
			lda plr_dxh
			cmp #$fe
			beq up_set_left
			dec plr_dxh
up_set_left	mva #1 plr_flip
up_right	lda joy_state
			and #JOY_RIGHT
			beq up_gravity
			lda plr_dxh
			cmp #2
			beq up_set_right
			inc plr_dxh
up_set_right	mva #0 plr_flip
up_gravity	lda plr_dyh
			cmp #3
			bcs up_move
			inc plr_dyh
up_move		jsr move_player_h
			jsr move_player_v
			jsr select_player_sprite
			jsr player_deadly_check
			bcc up_coin
			jsr reload_current_level
			rts
up_coin		jsr check_coin
			rts

move_player_h
			lda plr_dxh
			beq mph_done
			bmi mph_left
			tax
mph_right_loop	jsr player_collide_right
			bcs mph_stop
			inc plr_x
			dex
			bne mph_right_loop
mph_done	rts
mph_left	eor #$ff
			clc
			adc #1
			tax
mph_left_loop	jsr player_collide_left
			bcs mph_stop
			dec plr_x
			dex
			bne mph_left_loop
			rts
mph_stop	mva #0 plr_dxh
			rts

move_player_v
			lda plr_dyh
			beq mpv_stand
			bmi mpv_up
			tax
			mva #0 plr_onground
mpv_down_loop	jsr player_collide_down
			bcs mpv_land
			inc plr_y
			dex
			bne mpv_down_loop
			rts
mpv_land	mva #0 plr_dyh
			mva #1 plr_onground
			mva #1 plr_canTele
			rts
mpv_up		mva #0 plr_onground
			eor #$ff
			clc
			adc #1
			tax
mpv_up_loop	jsr player_collide_up
			bcs mpv_ceiling
			dec plr_y
			dex
			bne mpv_up_loop
			rts
mpv_ceiling	mva #0 plr_dyh
			rts
mpv_stand	jsr player_collide_down
			bcc mpv_air
			mva #1 plr_onground
			rts
mpv_air		mva #0 plr_onground
			rts

select_player_sprite
			lda plr_dyh
			bmi sps_jump
			beq sps_ground
			mva #SPR_PLAYER_FALL plr_sprite
			rts
sps_ground	lda plr_onground
			beq sps_fall
			lda plr_dxh
			beq sps_idle
			lda ramka
			lsr
			lsr
			and #3
			clc
			adc #SPR_PLAYER_RUN_START
			sta plr_sprite
			rts
sps_idle	mva #SPR_PLAYER_IDLE plr_sprite
			rts
sps_jump	mva #SPR_PLAYER_JUMP plr_sprite
			rts
sps_fall	mva #SPR_PLAYER_FALL plr_sprite
			rts

reload_current_level
			jsr load_level
			jmp init_player

check_coin
			lda coin_active
			beq coin_done
			lda plr_x
			clc
			adc #4
			cmp coin_x
			bcc coin_done
			sec
			sbc coin_x
			cmp #8
			bcs coin_done
			lda plr_y
			clc
			adc #4
			cmp coin_y
			bcc coin_done
			sec
			sbc coin_y
			cmp #8
			bcs coin_done
			mva #0 coin_active
			lda level_next
			cmp #$ff
			beq coin_done
			sta level_idx
			jsr load_level
			jsr init_player
coin_done
			rts

player_deadly_check
			jsr player_hazard_inside
			bcs pdc_dead
			jsr player_block_inside
			bcs pdc_dead
			lda plr_x
			cmp #ROOM_PX
			bcs pdc_dead
			lda plr_y
			cmp #ROOM_PX
			bcs pdc_dead
			clc
			rts
pdc_dead	sec
			rts

draw_coin
			lda coin_active
			beq draw_coin_done
			mwa #[ROOM_OY*256+ROOM_OX] pom1
			clc
			lda pom1
			adc coin_x
			sta pom1
			lda pom1+1
			adc coin_y
			sta pom1+1
			lda #SPR_COIN
			jsr blit_sprite_tile
draw_coin_done
			rts

draw_player
			mwa #[ROOM_OY*256+ROOM_OX] pom1
			clc
			lda pom1
			adc plr_x
			sta pom1
			lda pom1+1
			adc plr_y
			sta pom1+1
			lda plr_sprite
			jmp blit_sprite_tile

blit_sprite_tile
			sta pom0
			ldy #$5d
			mva #$80+[bcb_spr_vbxe>>14] (fx_ptr),y
			lda pom0
			and #3
			asl
			asl
			asl
			asl
			asl
			asl
			sta $4000+[bcb_spr_vbxe&$3fff]+0
			lda pom0
			lsr
			lsr
			sta $4000+[bcb_spr_vbxe&$3fff]+1
			lda pom1
			sta $4000+[bcb_spr_vbxe&$3fff]+6
			lda pom1+1
			sta $4000+[bcb_spr_vbxe&$3fff]+7
			ldy #$50
			mva #bcb_spr_vbxe&$ff (fx_ptr),y+
			mva #[bcb_spr_vbxe>>8]&$ff (fx_ptr),y+
			mva #bcb_spr_vbxe>>16 (fx_ptr),y+
			mva #1 (fx_ptr),y
blit_sprite_wait
			ldy #$53
			lda (fx_ptr),y
			bne blit_sprite_wait
			ldy #$5d
			mva #0 (fx_ptr),y
			rts