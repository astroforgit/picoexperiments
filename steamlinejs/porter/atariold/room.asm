FLAG_SOLID_MASK = $01
SPR_COIN = 48

load_level
			mwa #levels_data pom
			lda level_idx
			clc
			adc pom+1
			sta pom+1
			ldy #0
@copy		lda (pom),y
			sta room_buf,y
			iny
			bne @copy

			lda level_idx
			asl
			asl
			asl
			tay
			lda level_meta+2,y
			sta coin_x
			lda level_meta+3,y
			sta coin_y
			lda level_meta+6,y
			sta level_end
			lda level_meta+7,y
			sta level_next
			lda coin_x
			cmp #$ff
			bne @coin_ok
			mva #0 coin_active
			rts
@coin_ok	mva #1 coin_active
			rts

; draws the 16x16 room tiles into the centered 128x128 playfield area
; pom1 = current destination pointer inside VBXE screen (16-bit low word)
draw_room
			ldy #$5d
			mva #$80+[bcb_tile_vbxe>>14] (fx_ptr),y
			ldy #$50
			mva #bcb_tile_vbxe&$ff (fx_ptr),y+
			mva #[bcb_tile_vbxe>>8]&$ff (fx_ptr),y+
			mva #bcb_tile_vbxe>>16 (fx_ptr),y

			mwa #[ROOM_OY*256+ROOM_OX] pom1
			mva #0 pom0a
@row		lda pom0a
			asl
			asl
			asl
			asl
			tay
			ldx #ROOM_TILES
@col		lda room_buf,y
			jsr blit_room_tile
			iny
			clc
			lda pom1
			adc #8
			sta pom1
			bcc @+
			inc pom1+1
@			dex
			bne @col
			clc
			lda pom1
			adc #$80
			sta pom1
			lda pom1+1
			adc #$07
			sta pom1+1
			inc pom0a
			lda pom0a
			cmp #ROOM_TILES
			bne @row
			ldy #$5d
			mva #0 (fx_ptr),y
			rts

; A = tile id, pom1 = destination low word within scr_vbxe bank
blit_room_tile
			sta pom0
			tya
			pha
			lda pom0
			and #3
			asl
			asl
			asl
			asl
			asl
			asl
			sta $4000+[bcb_tile_vbxe&$3fff]+0
			lda pom0
			lsr
			lsr
			sta $4000+[bcb_tile_vbxe&$3fff]+1
			lda pom1
			sta $4000+[bcb_tile_vbxe&$3fff]+6
			lda pom1+1
			sta $4000+[bcb_tile_vbxe&$3fff]+7
			ldy #$53
			mva #1 (fx_ptr),y
@busy		lda (fx_ptr),y
			bne @busy
			pla
			tay
			rts
