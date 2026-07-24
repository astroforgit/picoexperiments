FLAG_HAZARD_MASK = $04
FLAG_BLOCK_MASK = $08

sample_room_tile
			cpx #ROOM_TILES
			bcs @empty
			cpy #ROOM_TILES
			bcs @empty
			tya
			asl
			asl
			asl
			asl
			clc
			adc #<room_buf
			sta pom2
			lda #>room_buf
			adc #0
			sta pom2+1
			txa
			tay
			lda (pom2),y
			rts
@empty		lda #0
			rts

; pom0  = flag mask
; pom0a = x1, pom0b = y1, pom0c = x2, pom0d = y2
; returns C=1 if any of the 4 points hits a tile with that mask
collide_points_mask
			lda pom0a
			lsr
			lsr
			lsr
			tax
			lda pom0b
			lsr
			lsr
			lsr
			tay
			jsr sample_room_tile
			tay
			lda tile_flags,y
			and pom0
			bne @hit

			lda pom0a
			lsr
			lsr
			lsr
			tax
			lda pom0d
			lsr
			lsr
			lsr
			tay
			jsr sample_room_tile
			tay
			lda tile_flags,y
			and pom0
			bne @hit

			lda pom0c
			lsr
			lsr
			lsr
			tax
			lda pom0b
			lsr
			lsr
			lsr
			tay
			jsr sample_room_tile
			tay
			lda tile_flags,y
			and pom0
			bne @hit

			lda pom0c
			lsr
			lsr
			lsr
			tax
			lda pom0d
			lsr
			lsr
			lsr
			tay
			jsr sample_room_tile
			tay
			lda tile_flags,y
			and pom0
			bne @hit
			clc
			rts
@hit		sec
			rts

player_collide_left
			mva #FLAG_SOLID_MASK pom0
			mva plr_x pom0a
			lda plr_y
			clc
			adc #3
			sta pom0b
			lda plr_x
			clc
			adc #2
			sta pom0c
			lda plr_y
			clc
			adc #7
			sta pom0d
			jmp collide_points_mask

player_collide_right
			mva #FLAG_SOLID_MASK pom0
			lda plr_x
			clc
			adc #5
			sta pom0a
			lda plr_y
			clc
			adc #3
			sta pom0b
			lda plr_x
			clc
			adc #7
			sta pom0c
			lda plr_y
			clc
			adc #7
			sta pom0d
			jmp collide_points_mask

player_collide_up
			mva #FLAG_SOLID_MASK pom0
			lda plr_x
			clc
			adc #2
			sta pom0a
			lda plr_y
			clc
			adc #1
			sta pom0b
			lda plr_x
			clc
			adc #6
			sta pom0c
			lda plr_y
			clc
			adc #2
			sta pom0d
			jmp collide_points_mask

player_collide_down
			mva #FLAG_SOLID_MASK pom0
			lda plr_x
			clc
			adc #2
			sta pom0a
			lda plr_y
			clc
			adc #8
			sta pom0b
			lda plr_x
			clc
			adc #6
			sta pom0c
			lda pom0b
			sta pom0d
			jmp collide_points_mask

player_hazard_inside
			mva #FLAG_HAZARD_MASK pom0
			lda plr_x
			clc
			adc #4
			sta pom0a
			lda plr_y
			clc
			adc #3
			sta pom0b
			mva pom0a pom0c
			mva pom0b pom0d
			jmp collide_points_mask

player_block_inside
			mva #FLAG_BLOCK_MASK pom0
			lda plr_x
			clc
			adc #3
			sta pom0a
			lda plr_y
			clc
			adc #4
			sta pom0b
			lda plr_x
			clc
			adc #5
			sta pom0c
			mva pom0b pom0d
			jmp collide_points_mask
