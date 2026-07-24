// Porter Patch -- Atari VBXE conversion
// Reuses VBXE init/blitter pattern from gacek/.

			icl 'atari.hea'

//----- VBXE memory layout ---------------------------------------------------
shape_vbxe	= $00000		; 256 shapes * 64 bytes = $4000 bytes
scr_vbxe	= $10000		; bitmap framebuffer (256 wide * 224 high)
xdl_vbxe	= $70800
bcb_tile_vbxe	= $70880	; BCB for drawing tiles (8x8 copy)
bcb_spr_vbxe	= $70900	; BCB for drawing sprites (8x8 with transparency)
bcb_cls_vbxe	= $70980	; BCB for clearing screen

ROOM_TILES	= 16
TILE_PX		= 8
ROOM_PX		= ROOM_TILES*TILE_PX	; 128
SCR_W		= 256
SCR_H		= 208
ROOM_OX		= 64			; room x offset on screen
ROOM_OY		= 32			; room y offset on screen

//----- zero page ------------------------------------------------------------
			opt h-
			org $80

regA		org *+1
regX		org *+1
licznik		org *+1
zegar		equ $14

pom			org *+2
pom0		org *+1
pom0a		org *+1
pom0b		org *+1
pom0c		org *+1
pom0d		org *+1
pom1		org *+2
pom2		org *+2
pom4		org *+2

fx_ptr		org *+2			; VBXE base ($d600 or $d700)

// player / game state
plr_x		org *+1			; player x in room pixels (0..127)
plr_y		org *+1
plr_dx		org *+1			; 8.8 fixed, low byte
plr_dxh		org *+1			; high byte (signed)
plr_dy		org *+1
plr_dyh		org *+1
plr_flip	org *+1			; 0=right, 1=left
plr_onground org *+1
plr_canTele	org *+1
plr_sprite	org *+1			; current shape id
level_idx	org *+1
level_next	org *+1
level_end	org *+1
coin_x		org *+1
coin_y		org *+1
coin_active	org *+1
ramka		org *+1			; frame counter
joy_state	org *+1
joy_prev	org *+1
joy_pressed	org *+1

			opt h+

//----- main RAM data blocks -------------------------------------------------
			org $0500
room_buf	:256 dta 0		; 16x16 current room tile ids

			org $0600
carrier_dlist
			dta $70,$70				; 16 blank scanlines at top (PAL layout)
			dta $42,a(carrier_scr)		; first text row with LMS
			:25 dta $02				; total 26 ANTIC text rows = 208 scanlines
			dta $41,a(carrier_dlist)

carrier_scr	:26*40 dta $00

			org $2000
			icl 'init_vbxe.asm'

			org $3000
//============================================================================
// entry / init
//============================================================================
nmi			bit nmist
			bpl *+5
			jmp (dliv)
			jmp (vbiv)

vbi			pha
			txa
			pha
			tya
			pha
			inc zegar
			mwa #dli_dummy dliv
			pla
			tay
			pla
			tax
			pla
			rti

dli_dummy	rti
irq_dummy	rti

start
			lda 20
@			cmp 20
			beq @-

			sei
			mva #0 nmien
			sta dmactl
			sta 559
			mva #3 skctl
			mva #$fe portb
			mwa #vbi vbiv
			mwa #dli_dummy dliv
			mwa #nmi nmivec
			mwa #irq_dummy irqvec
			mva #64 nmien
			cli

			jsr vbxe_init			; detect+upload shapes+palette+XDL+BCBs
			mwa #carrier_dlist dlptr
			mva #scr40 dmactl
			sta 559
			jsr cls_screen			; fill VBXE bitmap with background colour

			mva #0 level_idx
			jsr load_level			; copy level into room_buf
			jsr draw_room			; blit all 16x16 tiles to VBXE screen

			jsr init_player

main_loop
			jsr wait_vbl
			jsr read_joystick
			jsr update_player
			jsr draw_room
			jsr draw_coin
			jsr draw_player
			inc ramka
			jmp main_loop

wait_vbl
			lda zegar
@			cmp zegar
			beq @-
			rts

cls_screen
			ldy #$5d
			mva #$80+[bcb_cls_vbxe>>14] (fx_ptr),y
			ldy #$50
			mva #bcb_cls_vbxe&$ff (fx_ptr),y+
			mva #[bcb_cls_vbxe>>8]&$ff (fx_ptr),y+
			mva #bcb_cls_vbxe>>16 (fx_ptr),y+
			mva #1 (fx_ptr),y
@			ldy #$53
			lda (fx_ptr),y
			bne @-
			ldy #$5d
			mva #0 (fx_ptr),y
			rts

			icl 'room.asm'
			icl 'collision.asm'
			icl 'player.asm'
			icl 'joystick.asm'
			icl 'data.asm'

			run start
