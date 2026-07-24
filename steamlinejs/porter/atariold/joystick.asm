read_joystick
			lda joy_state
			sta joy_prev
			mva #0 joy_state
			mva #0 joy_pressed

			lda porta
			and #$0f
			sta pom0
			lda pom0
			and #1
			bne joy_check_down
			lda joy_state
			ora #JOY_UP
			sta joy_state
joy_check_down
			lda pom0
			and #2
			bne joy_check_left
			lda joy_state
			ora #JOY_DOWN
			sta joy_state
joy_check_left
			lda pom0
			and #4
			bne joy_check_right
			lda joy_state
			ora #JOY_LEFT
			sta joy_state
joy_check_right
			lda pom0
			and #8
			bne joy_check_fire
			lda joy_state
			ora #JOY_RIGHT
			sta joy_state
joy_check_fire
			lda trig0
			bne joy_done
			lda joy_state
			ora #JOY_JUMP
			sta joy_state
			lda joy_prev
			and #JOY_JUMP
			bne joy_done
			lda joy_pressed
			ora #JOY_JUMP
			sta joy_pressed
joy_done
			rts