; SPEEDMAZA RACE - SpeedMaza (2014, Jakub Husak) rebuilt as a one-lap race
; on the rounded track of the PICO-8 "1k racing" game (../picospeed.txt).
;
; From SpeedMaza (ported from ../decompiled/speedmaza.asm): title screen,
; DLI colour bars, status line, speed/distance bars, colour pulsing with the
; music, crash and "MAZA PASSED!" screens, pictures, font, RMT music.
; From the PICO-8 game: track 1 and the car (outline, drift steering).
; Rules as in SpeedMaza: the car drives by itself and keeps getting faster,
; touching the walls (colour 3, as in SpeedMaza) is a crash.
;
; Build: ./build.sh   (MADS; tools/make_data.py makes data/ and gen/)

; ---- OS and hardware
POKMSK	= $10
RTCLOK	= $14		; jiffy counter (low byte)
ATRACT	= $4D
VDSLST	= $0200
SRTIMR	= $022B
SDMCTL	= $022F
SDLSTL	= $0230
GPRIOR	= $026F
STICK0	= $0278
STRIG0	= $0284
PCOLR0	= $02C0
COLOR0	= $02C4
CH	= $02FC
HPOSP0	= $D000
HPOSM0	= $D004
P0PF	= $D004		; read: player 0 / playfield collisions
P3PF	= $D007
SIZEM	= $D00C
PAL	= $D014
COLPF0	= $D016
COLPF1	= $D017
COLPF2	= $D018
COLBK	= $D01A
GRACTL	= $D01D
HITCLR	= $D01E
RANDOM	= $D20A
PORTB	= $D301
DLISTL	= $D402
HSCROL	= $D404
VSCROL	= $D405
PMBASE	= $D407
WSYNC	= $D40A
VCOUNT	= $D40B
NMIEN	= $D40E

; ---- SpeedMaza parts at their original addresses
RMT_INIT	= $4C00	; A = song line, X/Y = module address
RMT_PLAY	= $4C03
RMT_SILENCE	= $4C09
RMT_VOL		= $494A	; player variable SpeedMaza pulses the walls with
MUSIC_TITLE	= $5000
MUSIC_GAME	= $5700	; game from line 0, win line $25, crash line $28

; ---- memory map
TITLE	= $2000		; title picture (4K, must not cross a 4K page)
FONT	= TITLE+$0F28	; 16x8 digits inside the title picture
CRASH	= $3000		; crash picture
PMB	= $5C00		; PM graphics base, double-line resolution
DLA	= $5C00		; two game display lists (double buffered)
DLB	= $5C80
DLBUF	= $5D00		; display list of the title / win / crash screen
MIS	= PMB+$180
PL0	= PMB+$200
PL1	= PMB+$280
PL2	= PMB+$300
PL3	= PMB+$380
RING	= $6000		; 32 unpacked map rows, one 256 byte page each ($6000-$7FFF)
RING_ROWS = 32

; ---- test builds: AUTOPILOT=1 drives itself, AUTOPILOT=2 never steers
	.ifndef AUTOPILOT
AUTOPILOT = 0
	.endif

; ---- game tuning
CAR_Y0		= $3A	; top PM line of the car (centre at scan line 128)
CAR_HPOS	= $78	; player 0; player 3 is 8 colour clocks right
CAR_COLOR	= $38	; orange (PICO-8 colour 9), apart from the gold walls
TURN		= 2	; heading units per frame (256 = full turn), as PICO-8
SPEED_START	= $0180	; 1.5 colour clocks per frame
SPEED_ACC	= $30	; +3/4096 cc/frame every frame
GRIP_MAX	= 64	; how fast the velocity follows the heading (/256)
GRIP_MIN	= 20	; ... at high speed the car slides more (PICO-8 drift)
; colour effects start at SpeedMaza's times (frames)
FX1 = $0300
FX2 = $0480
FX3 = $0600
FX4 = $0C00
FX5 = $1800

; ---- zero page ($6B-$7C belong to the RMT player)
ptr	= $80
ptr2	= $82
dst	= $84
mcand	= $86
mplier	= $88
prod	= $89
sign	= $8C
posX	= $8D
posY	= $90
velX	= $93
velY	= $95
tgtX	= $97
tgtY	= $99
speed	= $9B
heading	= $9E
grip	= $9F
camX	= $A0
camY	= $A2
boff	= $A4
dlp	= $A5
nextH	= $A7
nextV	= $A8
tmp	= $A9
apDX	= $AB
apDY	= $AD
apZ	= $AF
row	= $B2		; map row being worked on (16 bit)
src	= $B4
dstp	= $B6
doff	= $B8
ysave	= $B9
spans	= $BA		; road spans left in the row being unpacked
span	= $BB		; first byte, mask, last byte, mask

	opt h+

; ======================================================================
; INIT while loading: BASIC off, so $A000-$BFFF is RAM (tables reach it)
	org $0600
LoadInit
	lda PORTB
	ora #2
	sta PORTB
	rts
	ini LoadInit

; ======================================================================
	org TITLE
	ins 'data/title_pic.bin'
	org CRASH
	ins 'data/crash_pic.bin'

; ======================================================================
	org $3840

Start
	ldx #$FF
	stx CH
	inx
	stx SDMCTL
	lda RTCLOK
@	cmp RTCLOK
	beq @-
	ldx #VarsEnd-VarsStart-1	; variables = 0
	lda #0
@	sta VarsStart,x
	dex
	bpl @-
	lda #$0C
	sta dliCycle
	ldx #6			; tenths of a second: 6 frames NTSC, 5 PAL
	lda PAL
	and #$0E
	bne @+
	ldx #5
@	stx tenthFrames
MainLoop
	jsr TitleScreen
	jsr RaceGame
	cmp #1
	bne @+
	jsr WinScreen
@	cmp #2
	bne MainLoop
	jsr CrashScreen
	jmp MainLoop

; ----------------------------------------------------------------------
; Interrupts (SpeedMaza DliTitle, DliGame, DliWin)

DliTitle
	pha
	tya
	pha
	lda VCOUNT
	cmp #$1C
	bcs dt_x
	lda #$10
	sta dliLine
	ldy #0
	sty ATRACT
	lda dliCycle
	sta dliCol
	clc
	adc #$10
	sta dliCycle
dt_lp	lda dliLine
	bmi dt_end		; dliLine < $80
	inc dliCol
	lda dliCol
	and #$F0
	ora #$0C
	sta COLPF2
	lda dliLine
	cmp #$1E
	bcs dt_2
	lda #$10
	sta COLBK
	sty WSYNC
	jmp dt_n
dt_2	cmp #$2F
	bcs dt_3
	sty WSYNC
	sty COLBK
	jmp dt_n
dt_3	cmp #$70
	bcs dt_4
	sty WSYNC
	lda #$80
	sta COLBK
	jmp dt_n
dt_4	sty WSYNC
	lda #$B0
	sta COLBK
dt_n	inc dliLine
	jmp dt_lp
dt_end	sty COLBK
dt_x	pla
	tay
	pla
	rti

DliGame
	pha
	tya
	pha
	lda VCOUNT
	cmp #$10
	bcc @+
	jmp dg_x
@
	ldy #0
	sty dliLine
	sty ATRACT
	lda #$64
	sta dliCol
	lda dliCycle
	clc
	adc #$10
	sta dliCycle
dg_1	lda dliLine
	cmp #5
	bcs dg_1e
	lda dliCol
	clc
	adc #2
	sta dliCol
	sty WSYNC
	sty WSYNC
	sta COLPF2
	inc dliLine
	jmp dg_1
dg_1e	inc dliLine
	sty WSYNC
	sty WSYNC
	sty WSYNC
	sty WSYNC
	sty WSYNC
dg_2	lda dliLine
	beq dg_2e
	lda dliCol
	sec
	sbc #2
	sta dliCol
	sty WSYNC
	sty WSYNC
	sta COLPF2
	dec dliLine
	jmp dg_2
dg_2e	sty WSYNC
	lda dliColPF1
	sta COLPF1
	lda dliColPF2
	sta COLPF2
	lda dliColPF0
	sta COLPF0
	sty WSYNC
	lda dliColBK
	sta COLBK
dg_x	pla
	tay
	pla
	rti

DliWin
	pha
	tya
	pha
	ldy #0
	sty dliLine
	sty ATRACT
	lda dliCycle
	sta dliCol
	clc
	adc #$10
	sta dliCycle
dw_lp	lda dliLine
	cmp #$0C
	bcs dw_x
	inc dliCol
	lda dliCol
	and #$F0
	ora #$0C
	sta COLPF2
	sty WSYNC
	inc dliLine
	jmp dw_lp
dw_x	pla
	tay
	pla
	rti

; ----------------------------------------------------------------------
; Small helpers (SpeedMaza Wait, GetInput, AnyKey, StopAll, HidePM)

; wait A frames
Wait	clc
	adc RTCLOK
@	cmp RTCLOK
	bne @-
	rts

; A = $21 when fire is pressed (debounced), a key code, or $FF
GetInput
	lda giDelay
	beq @+
	dec giDelay
@	lda giDelay
	and #$0F
	sta giDelay
	lda STRIG0
	bne gi_up
	lda giTrig
	cmp #1
	bne gi_key
	lda giDelay
	bne gi_key
	lda #0
	sta giTrig
	lda #$10
	sta giDelay
	lda #$21
	rts
gi_up	lda giTrig
	bne gi_key
	lda #1
	sta giTrig
gi_key	lda CH
	cmp #$FF
	beq gi_x
	ldx #$FF
	stx CH
	ldx #$FA
	stx SRTIMR
gi_x	rts

; Z clear if a key or fire was pressed
AnyKey	jsr GetInput
	cmp #$FF
	rts

StopAll	lda #$40
	sta NMIEN
	lda #0
	sta SDMCTL
	jsr RMT_SILENCE
	lda #1
	jmp Wait

HidePM	lda #0
	ldx #7
@	sta HPOSP0,x
	dex
	bpl @-
	sta GRACTL
	lda #$22
	sta SDMCTL
	rts

; copy A bytes from (ptr) to DLBUF
CopyDL	tay
@	dey
	lda (ptr),y
	sta DLBUF,y
	cpy #0
	bne @-
	rts

; ----------------------------------------------------------------------
; Numbers: 5 decimal digits drawn with the font of the title picture

; draw digits digs[X..X+4] at (dst)
PrintNum
	lda #5
	sta pnCount
pn_lp	lda digs,x
	jsr DrawDigit
	clc
	lda dst
	adc #3
	sta dst
	bcc @+
	inc dst+1
@	inx
	dec pnCount
	bne pn_lp
	rts

; digit A at (dst): 8 lines of [0, glyph, glyph], 40 bytes apart
DrawDigit
	asl @
	asl @
	asl @
	asl @
	clc
	adc #<FONT
	sta ptr
	lda #>FONT
	adc #0
	sta ptr+1
	lda dst
	sta ptr2
	lda dst+1
	sta ptr2+1
	lda #8
	sta tmp
dd_lp	ldy #0
	tya
	sta (ptr2),y
	lda (ptr),y
	iny
	sta (ptr2),y
	lda (ptr),y
	iny
	sta (ptr2),y
	clc
	lda ptr
	adc #2
	sta ptr
	bcc @+
	inc ptr+1
@	clc
	lda ptr2
	adc #40
	sta ptr2
	bcc @+
	inc ptr2+1
@	dec tmp
	bne dd_lp
	rts

; ----------------------------------------------------------------------
; Speed bar (player 1, left) and distance bar (player 2, right), grown
; upwards from line $7F; the sideways labels are cut out of the bar.
; A = speed height, X = distance height, Y = 1 to clear and draw labels

DrawBars
	sta dbA
	stx dbB
	lda #$30
	sta HPOSP0+1
	lda #$C8
	sta HPOSP0+2
	lda #$AA
	sta PCOLR0+1
	lda #$5A
	sta PCOLR0+2
	tya
	beq db_draw
	lda #0
	tax
@	sta PL1,x
	sta PL2,x
	inx
	bpl @-
	ldx #$1C
@	lda barTxt1,x
	lsr @
	sta PL1+$40,x
	dex
	bpl @-
	ldx #$2A
@	lda barTxt2,x
	lsr @
	sta PL2+$30,x
	dex
	bpl @-
	lda #$7F
	sta topA
	sta topB
db_draw	sec			; speed bar: fill up to line $7F-a
	lda #$7F
	sbc dbA
	sta tmp
db_a	lda topA
	cmp tmp
	bcc db_b
	beq db_b
	dec topA
	ldx topA
	lda #$FE
	cpx #$40
	bcc @+
	cpx #$5D
	bcs @+
	lda barTxt1-$40,x
	lsr @
	eor #$FE
@	sta PL1,x
	jmp db_a
db_b	sec			; distance bar
	lda #$7F
	sbc dbB
	sta tmp
db_b1	lda topB
	cmp tmp
	bcc db_x
	beq db_x
	dec topB
	ldx topB
	lda #$FE
	cpx #$30
	bcc @+
	cpx #$5B
	bcs @+
	lda barTxt2-$30,x
	lsr @
	eor #$FE
@	sta PL2,x
	jmp db_b1
db_x	rts

; ----------------------------------------------------------------------
; Screens (SpeedMaza TitleScreen, WinScreen, CrashScreen)

TitleScreen
	lda #<(DliTitle)
	sta VDSLST
	lda #>(DliTitle)
	sta VDSLST+1
	lda #$C0
	sta NMIEN
	jsr HidePM
	lda #<(dlTitle)
	sta SDLSTL
	lda #>(dlTitle)
	sta SDLSTL+1
	lda #<(TITLE+$099F)	; best time, in the HI SCORE line
	sta dst
	lda #>(TITLE+$099F)
	sta dst+1
	ldx #BEST
	jsr PrintNum
	lda #$60
	sta COLOR0
	lda #$62
	sta COLOR0+1
	sta COLOR0+2
	lda #0
	sta COLOR0+4
	ldx #<(MUSIC_TITLE)
	ldy #>(MUSIC_TITLE)
	jsr RMT_INIT
	lda #30			; ignore keys and fire for half a second
	jsr Wait
	lda #$FF
	sta CH
ts_lp
	.if AUTOPILOT
	lda #$21
	.else
	jsr GetInput
	.endif
	cmp #$1C
	beq @+
	cmp #$FF
	beq @+
	jmp StopAll
@	jsr RMT_PLAY
	lda #1
	jsr Wait
	jsr RMT_PLAY
	ldx #$4B
@	sta WSYNC
	dex
	bpl @-
	jmp ts_lp

WinScreen
	lda #<(DliWin)
	sta VDSLST
	lda #>(DliWin)
	sta VDSLST+1
	lda #$C0
	sta NMIEN
	jsr HidePM
	lda #<(dlWinSrc)
	sta ptr
	lda #>(dlWinSrc)
	sta ptr+1
	lda #$1D
	jsr CopyDL
	lda #<(TITLE+$0D48)	; "MAZA PASSED!" part of the title picture
	sta DLBUF+$0D
	lda #>(TITLE+$0D48)
	sta DLBUF+$0E
	lda #<(DLBUF)
	sta DLBUF+$1B
	sta SDLSTL
	lda #>(DLBUF)
	sta DLBUF+$1C
	sta SDLSTL+1
	lda #6
	sta COLOR0
	lda #$0A
	sta COLOR0+1
	lda #$0E
	sta COLOR0+2
	lda #0
	sta COLOR0+4
	lda #$25
	ldx #<(MUSIC_GAME)
	ldy #>(MUSIC_GAME)
	jsr RMT_INIT
	jsr RMT_PLAY
ws_lp	jsr RMT_PLAY
	lda #1
	jsr Wait
	jsr AnyKey
	beq ws_lp
	jmp StopAll

CrashScreen
	jsr HidePM
	lda #$28
	ldx #<(MUSIC_GAME)
	ldy #>(MUSIC_GAME)
	jsr RMT_INIT
	lda #0
	sta csN
	lda #$22
	sta SDMCTL
	lda #<(dlCrashSrc)
	sta ptr
	lda #>(dlCrashSrc)
	sta ptr+1
	lda #$3B
	jsr CopyDL
	lda #<(CRASH)
	sta DLBUF+$0B
	lda #>(CRASH)
	sta DLBUF+$0C
	lda #<(DLBUF)
	sta DLBUF+$39
	sta SDLSTL
	lda #>(DLBUF)
	sta DLBUF+$3A
	sta SDLSTL+1
	lda #4
	sta COLOR0
	lda #8
	sta COLOR0+1
	lda #$0C
	sta COLOR0+2
cs_lp	inc csN
	jsr RMT_PLAY
	lda #1
	jsr Wait
	jsr RMT_PLAY
	lda #1
	jsr Wait
	jsr RMT_PLAY
	lda #1
	jsr Wait
	lda RANDOM		; shake
	and #7
	sta VSCROL
	lda RANDOM
	and #7
	sta HSCROL
	lda csN
	asl @
	asl @
	asl @
	asl @
	and #$E0
	sta csC
	lda csN
	and #2
	beq cs_b
	lda #4
	ora csC
	sta COLOR0
	lda #8
	ora csC
	sta COLOR0+1
	lda #$0E
	ora csC
	sta COLOR0+2
	lda #0
	sta COLOR0+4
	jmp cs_t
cs_b	lda #8
	ora csC
	sta COLOR0
	lda #4
	ora csC
	sta COLOR0+1
	lda #0
	sta COLOR0+2
	lda #$0E
	ora csC
	sta COLOR0+4
cs_t	lda csN
	cmp #$1D
	bcs @+
	jmp cs_lp
@
	jsr StopAll
	lda #0
	sta COLOR0+4
	lda #$32
	jmp Wait

; ----------------------------------------------------------------------
; The race. Returns A = 1 finished, 2 crashed, $1C ESC.

RaceGame
	lda #4
	sta dliColPF0
	lda #8
	sta dliColPF1
	lda #$14
	sta dliColPF2
	lda #0
	sta dliColBK
	jsr BuildDLs
	lda #$FF		; no map row unpacked yet
	ldx #RING_ROWS*2-1
@	sta slotRow,x
	dex
	bpl @-
	ldx #velY+1-velX	; velocity, heading, fractions = 0
	lda #0
@	sta velX,x
	dex
	bpl @-
	sta heading
	sta posX
	sta posY
	sta speed
	sta started
	sta idx
	sta tick
	sta tick+1
	sta frame
	ldx #4
@	sta digs+TIME,x
	dex
	bpl @-
	lda #<(START_X)
	sta posX+1
	lda #>(START_X)
	sta posX+2
	lda #<(START_Y)
	sta posY+1
	lda #>(START_Y)
	sta posY+2
	lda #<(SPEED_START)
	sta speed+1
	lda #>(SPEED_START)
	sta speed+2
	lda tenthFrames
	sta tdiv
	lda #<(DLA)
	sta dlp
	lda #>(DLA)
	sta dlp+1
	jsr UpdateCamera
	jsr Flip
	jsr InitPM
	jsr DrawCar
	lda #0
	tax
	ldy #1
	jsr DrawBars
	lda #<(DliGame)
	sta VDSLST
	lda #>(DliGame)
	sta VDSLST+1
	lda #1
	jsr Wait
	lda #$C0
	sta NMIEN
	lda #0
	ldx #<(MUSIC_GAME)
	ldy #>(MUSIC_GAME)
	jsr RMT_INIT
	sta HITCLR

rg_loop	jsr UpdateCamera	; next frame into the back display list
	lda RTCLOK
@	cmp RTCLOK
	beq @-
	jsr Flip		; vertical blank: show it
	jsr DrawCar
	jsr RMT_PLAY
	lda started
	beq rg_hit
	lda P0PF		; car touches a wall (colour 3) = crash
	ora P3PF
	and #4
	beq rg_hit
	jsr StopAll
	lda #2
	rts
rg_hit	sta HITCLR
	jsr GetInput
	cmp #$1C		; ESC
	bne @+
	jsr StopAll
	lda #$1C
	rts
@	cmp #$21		; fire / SPACE starts the race
	bne @+
	lda #1
	sta started
@	inc frame
	inc tick
	bne @+
	inc tick+1
@
	.if AUTOPILOT
	lda frame		; start after one second
	cmp #60
	bne @+
	sta started
@
	.endif
	lda started
	beq rg_show
	.if AUTOPILOT = 1
	jsr AutoSteer
	.elseif AUTOPILOT = 2	; crash test: no steering
	.else
	jsr Steer
	.endif
	jsr Physics
	jsr Timer
	jsr Checkpoint
	bcc rg_show
	jsr StopAll		; finished the lap
	jsr SaveBest
	lda #1
	rts
rg_show	lda #<(TITLE+$0360)	; time in the status line
	sta dst
	lda #>(TITLE+$0360)
	sta dst+1
	ldx #TIME
	jsr PrintNum
	sec			; speed bar: (speed - start) / 16
	lda speed+1
	sbc #<(SPEED_START)
	sta tmp
	lda speed+2
	sbc #>(SPEED_START)
	lsr @
	ror tmp
	lsr @
	ror tmp
	lsr @
	ror tmp
	lsr @
	ror tmp
	lda tmp
	cmp #$60
	bcc @+
	lda #$60
@	sta tmp
	ldx idx
	lda cpBar,x
	tax
	lda tmp
	ldy #0
	jsr DrawBars
	jsr ColourFx
	jmp rg_loop

; display lists A and B: status line from the title DL, then 27 lines of
; ANTIC mode 8 with LMS (+HSCROL+VSCROL) and a JVB back to the start
BuildDLs
	lda #<(DLA)
	sta ptr
	lda #>(DLA)
	sta ptr+1
	jsr bd_one
	lda #<(DLB)
	sta ptr
bd_one	ldy #0
@	lda dlTitleSrc+4,y
	sta (ptr),y
	iny
	cpy #31
	bne @-
	lda #0
	sta (ptr),y
	ldy #1
	lda #<(TITLE)
	sta (ptr),y
	iny
	lda #>(TITLE)
	sta (ptr),y
	ldy #32
	ldx #26
@	lda #$78
	sta (ptr),y
	iny
	iny
	iny
	dex
	bne @-
	lda #$58
	sta (ptr),y
	iny
	iny
	iny
	lda #$70
	sta (ptr),y
	iny
	lda #$41
	sta (ptr),y
	iny
	lda ptr
	sta (ptr),y
	iny
	lda ptr+1
	sta (ptr),y
	rts

; camera from car position; LMS of the back display list, next scroll
UpdateCamera
	sec
	lda posX+1
	sbc #<(VIEW_X)
	sta camX
	lda posX+2
	sbc #>(VIEW_X)
	sta camX+1
	bpl @+
	lda #0
	sta camX
	sta camX+1
@	lda #<CAM_X_MAX
	cmp camX
	lda #>CAM_X_MAX
	sbc camX+1
	bcs @+
	lda #<(CAM_X_MAX)
	sta camX
	lda #>(CAM_X_MAX)
	sta camX+1
@	sec
	lda posY+1
	sbc #<(VIEW_Y)
	sta camY
	lda posY+2
	sbc #>(VIEW_Y)
	sta camY+1
	bpl @+
	lda #0
	sta camY
	sta camY+1
@	lda #<CAM_Y_MAX
	cmp camY
	lda #>CAM_Y_MAX
	sbc camY+1
	bcs @+
	lda #<(CAM_Y_MAX)
	sta camY
	lda #>(CAM_Y_MAX)
	sta camY+1
@	lda camX		; HSCROL = 15 - (camX & 15), as SpeedMaza
	and #$0F
	eor #$0F
	sta nextH
	lda camY
	and #7
	sta nextV
	lda camX+1		; first byte of every line = camX / 16
	sta tmp
	lda camX
	lsr tmp
	ror @
	lsr tmp
	ror @
	lsr tmp
	ror @
	lsr tmp
	ror @
	sta boff
	lda camY+1		; first row = camY / 8 (16 bit)
	sta row+1
	lda camY
	lsr row+1
	ror @
	lsr row+1
	ror @
	lsr row+1
	ror @
	sta row
	ldy #33			; LMS of the 27 mode 8 lines
uc_lp	sty ysave
	jsr EnsureRow
	ldy ysave
	lda boff
	sta (dlp),y
	iny
	lda row
	and #RING_ROWS-1
	ora #>RING
	sta (dlp),y
	iny
	iny
	inc row
	bne @+
	inc row+1
@	cpy #33+27*3
	bne uc_lp
	rts

; make sure map row 'row' is unpacked in its ring slot (row & 31)
EnsureRow
	lda row
	and #RING_ROWS-1
	asl @
	tax
	lda slotRow,x
	cmp row
	bne er_unpack
	lda slotRow+1,x
	cmp row+1
	bne er_unpack
	rts
er_unpack
	lda row
	sta slotRow,x
	lda row+1
	sta slotRow+1,x
	lda row			; src = rowPtr[row]
	asl @
	sta src
	lda row+1
	rol @
	sta src+1
	clc
	lda src
	adc #<rowPtr
	sta src
	lda src+1
	adc #>rowPtr
	sta src+1
	ldy #0
	lda (src),y
	tax
	iny
	lda (src),y
	sta src+1
	stx src
	lda row			; destination: one 256 byte page per slot
	and #RING_ROWS-1
	ora #>RING
	sta dstp+1
	lda #0
	sta dstp
	lda #$FF		; the whole row is wall ...
	ldy #MAP_BYTES
@	dey
	sta (dstp),y
	bne @-
	lda (src),y		; ... except the road spans (Y = 0: span count)
	sta spans
er_span	lda spans
	beq er_x
	dec spans
	inc src			; next span: first byte, mask, last byte, mask
	bne @+
	inc src+1
@	ldy #3
@	lda (src),y
	sta span,y
	dey
	bpl @-
	ldy span		; first byte: clear its road pixels
	lda (dstp),y
	and span+1
	sta (dstp),y
	iny
	lda #0			; bytes in between: all road
@	cpy span+2
	bcs @+
	sta (dstp),y
	iny
	bne @-
@	ldy span+2		; last byte
	lda (dstp),y
	and span+3
	sta (dstp),y
	clc
	lda src
	adc #3
	sta src
	bcc er_span
	inc src+1
	jmp er_span
er_x	rts

; during vertical blank: switch to the display list just built
Flip	lda dlp
	sta SDLSTL
	sta DLISTL
	lda dlp+1
	sta SDLSTL+1
	sta DLISTL+1
	lda nextH
	sta HSCROL
	lda nextV
	sta VSCROL
	lda dlp
	eor #$80		; DLA <-> DLB
	sta dlp
	rts

InitPM
	lda #0
	tax
@	sta MIS,x
	sta PL0,x
	sta PL0+$80,x
	sta PL2,x
	sta PL2+$80,x
	inx
	bpl @-
	lda #$FF
	sta SIZEM
	lda #>(PMB)
	sta PMBASE
	lda #0
	sta COLOR0+3
	lda #3
	sta GRACTL
	lda #$11
	sta GPRIOR
	lda #$FF		; missiles: borders beside the track
	ldx #$13
@	sta MIS,x
	inx
	bpl @-
	lda #1
	jsr Wait
	lda #$2E
	sta SDMCTL
	lda #3
	jsr Wait
	lda #CAR_HPOS
	sta HPOSP0
	lda #CAR_HPOS+8
	sta HPOSP0+3
	lda #$30
	sta HPOSM0
	lda #$38
	sta HPOSM0+1
	lda #$C0
	sta HPOSM0+2
	lda #$C8
	sta HPOSM0+3
	lda #CAR_COLOR
	sta PCOLR0
	sta PCOLR0+3
	lda #$0E
	sta PCOLR0+1
	sta PCOLR0+2
	rts

; car frame for the heading into players 0 and 3
DrawCar	lda heading
	clc
	adc #4
	lsr @
	lsr @
	lsr @
	sta tmp			; frame 0..31, x12 bytes
	lda #0
	sta tmp+1
	lda tmp
	asl @
	adc tmp			; x3 (no carry: < 96)
	asl @
	rol tmp+1
	asl @
	rol tmp+1		; x12
	clc
	adc #<(car0)
	sta ptr
	lda tmp+1
	adc #>(car0)
	sta ptr+1
	lda ptr
	clc
	adc #<(car3-car0)
	sta ptr2
	lda ptr+1
	adc #>(car3-car0)
	sta ptr2+1
	ldy #11
@	lda (ptr),y
	sta PL0+CAR_Y0,y
	lda (ptr2),y
	sta PL3+CAR_Y0,y
	dey
	bpl @-
	rts

; joystick left/right turns the car (PICO-8: 1/128 turn per frame)
Steer	lda STICK0
	and #4
	bne @+
	lda heading
	clc
	adc #TURN
	sta heading
@	lda STICK0
	and #8
	bne @+
	lda heading
	sec
	sbc #TURN
	sta heading
@	rts

	.if AUTOPILOT
; steer towards the current checkpoint: turn left when
; z = 2*sinY*dx - cos*dy > 0 (cross product of heading and target)
AutoSteer
	ldx idx
	sec
	lda cpXLo,x
	sbc posX+1
	sta apDX
	lda cpXHi,x
	sbc posX+2
	sta apDX+1
	sec
	lda cpYLo,x
	sbc posY+1
	sta apDY
	lda cpYHi,x
	sbc posY+2
	sta apDY+1
	ldx heading
	lda sinYTab,x
	ldy #apDX
	jsr SMul
	asl prod		; x2
	rol prod+1
	rol prod+2
	ldx #2
@	lda prod,x
	sta apZ,x
	dex
	bpl @-
	ldx heading
	lda cosTab,x
	ldy #apDY
	jsr SMul
	sec			; z = 2a - b
	lda apZ
	sbc prod
	sta apZ
	lda apZ+1
	sbc prod+1
	sta apZ+1
	lda apZ+2
	sbc prod+2
	bmi as_r
	ora apZ+1
	ora apZ
	beq as_x
	lda heading
	clc
	adc #TURN
	sta heading
as_x	rts
as_r	lda heading
	sec
	sbc #TURN
	sta heading
	rts

; prod (24 bit signed) = A (signed 8) * zero page word at Y (signed 16)
SMul	sta mplier
	eor $01,y
	sta sign
	lda $00,y
	sta mcand
	lda $01,y
	sta mcand+1
	bpl @+
	lda #0
	sec
	sbc mcand
	sta mcand
	lda #0
	sbc mcand+1
	sta mcand+1
@	lda mplier
	bpl @+
	eor #$FF
	clc
	adc #1
	sta mplier
@	jsr Mul16x8
	lda sign
	bpl @+
	ldx #0
	sec
	txa
	sbc prod
	sta prod
	txa
	sbc prod+1
	sta prod+1
	txa
	sbc prod+2
	sta prod+2
@	rts
	.endif

; speed grows every frame; velocity follows the heading with some grip
; (PICO-8: u=(u-r*cos)*k+r*cos), then the car moves
Physics
	clc
	lda speed
	adc #SPEED_ACC
	sta speed
	lda speed+1
	adc #0
	sta speed+1
	lda speed+2
	adc #0
	sta speed+2
	ldx heading		; target x = speed * cos / 128
	lda cosTab,x
	jsr MulSpeed
	lda prod
	asl @
	lda prod+1
	rol @
	sta tgtX
	lda prod+2
	rol @
	sta tgtX+1
	ldx #0
	jsr FixSign
	ldx heading		; target y = speed * sinY / 64
	lda sinYTab,x
	jsr MulSpeed
	asl prod
	rol prod+1
	rol prod+2
	asl prod
	rol prod+1
	rol prod+2
	lda prod+1
	sta tgtY
	lda prod+2
	sta tgtY+1
	ldx #tgtY-tgtX
	jsr FixSign
	sec			; grip = GRIP_MAX - (speed - start) / 8
	lda speed+1
	sbc #<(SPEED_START)
	sta tmp
	lda speed+2
	sbc #>(SPEED_START)
	lsr @
	ror tmp
	lsr @
	ror tmp
	lsr @
	ror tmp
	bne ph_min
	lda tmp
	cmp #GRIP_MAX-GRIP_MIN
	bcs ph_min
	lda #GRIP_MAX
	sec
	sbc tmp
	jmp ph_g
ph_min	lda #GRIP_MIN
ph_g	sta grip
	ldx #0			; x, then y
	jsr Follow
	ldx #2
	jsr Follow
	ldx #0
	jsr Move
	ldx #3
	; fall through

; pos[x] (24 bit) += vel (sign extended); X = 0 for x, 3 for y
Move	txa
	lsr @			; 0 -> 0, 3 -> 1 ... velocity index 0 / 2
	asl @
	tay
	clc
	lda posX,x
	adc velX,y
	sta posX,x
	lda posX+1,x
	adc velX+1,y
	sta posX+1,x
	lda velX+1,y
	and #$80
	beq @+
	lda #$FF
@	adc posX+2,x
	sta posX+2,x
	rts

; vel[x] += (tgt[x] - vel[x]) * grip / 256
Follow	sec
	lda tgtX,x
	sbc velX,x
	sta mcand
	lda tgtX+1,x
	sbc velX+1,x
	sta mcand+1
	sta sign
	bpl @+
	lda #0
	sec
	sbc mcand
	sta mcand
	lda #0
	sbc mcand+1
	sta mcand+1
@	lda grip
	sta mplier
	jsr Mul16x8
	lda sign
	bpl @+
	lda #0
	sec
	sbc prod+1
	sta prod+1
	lda #0
	sbc prod+2
	sta prod+2
@	clc
	lda velX,x
	adc prod+1
	sta velX,x
	lda velX+1,x
	adc prod+2
	sta velX+1,x
	rts

; prod = speed * |A| (A signed), sign = A
MulSpeed
	sta sign
	bpl @+
	eor #$FF
	clc
	adc #1
@	sta mplier
	lda speed+1
	sta mcand
	lda speed+2
	sta mcand+1
	; fall through

; prod (24 bit) = mcand (16 bit) * mplier (8 bit), unsigned
Mul16x8	lda #0
	sta prod+1
	sta prod+2
	ldy #8
ml_lp	lsr mplier
	bcc @+
	clc
	lda prod+1
	adc mcand
	sta prod+1
	lda prod+2
	adc mcand+1
	sta prod+2
@	ror prod+2
	ror prod+1
	ror prod
	dey
	bne ml_lp
	rts

; negate tgtX+x (16 bit) when sign is negative
FixSign	lda sign
	bpl @+
	lda #0
	sec
	sbc tgtX,x
	sta tgtX,x
	lda #0
	sbc tgtX+1,x
	sta tgtX+1,x
@	rts

; time in tenths of a second, 5 decimal digits
Timer	dec tdiv
	bne tm_x
	lda tenthFrames
	sta tdiv
	ldx #TIME+4
@	inc digs,x
	lda digs,x
	cmp #10
	bcc tm_x
	lda #0
	sta digs,x
	dex
	bpl @-			; TIME = 0: stop after the first digit
tm_x	rts

; next checkpoint reached? C = 1 when the last one (finish line) is passed
Checkpoint
	ldx idx
	sec
	lda posX+1
	sbc cpXLo,x
	tay
	lda posX+2
	sbc cpXHi,x
	jsr InBoxX
	bcc cp_no
	sec
	lda posY+1
	sbc cpYLo,x
	tay
	lda posY+2
	sbc cpYHi,x
	jsr InBoxY
	bcc cp_no
	inc idx
	lda idx
	cmp #CP_COUNT
	rts			; C = 1 when idx = CP_COUNT
cp_no	clc
	rts

; C = 1 when the 16-bit difference A:Y lies inside +-CP_RX / +-CP_RY
InBoxX	cmp #0
	beq @+
	cmp #$FF
	bne ib_no
	cpy #256-CP_RX
	rts
@	cpy #CP_RX
	jmp ib_inv
InBoxY	cmp #0
	beq @+
	cmp #$FF
	bne ib_no
	cpy #256-CP_RY
	rts
@	cpy #CP_RY
ib_inv	bcc ib_yes
ib_no	clc
	rts
ib_yes	sec
	rts

; lower time is better; 00000 means no best time yet
SaveBest
	ldx #0
@	lda digs+BEST,x
	bne sb_cmp
	inx
	cpx #5
	bne @-
	beq sb_copy
sb_cmp	ldx #0
@	lda digs+TIME,x
	cmp digs+BEST,x
	bcc sb_copy
	bne sb_x
	inx
	cpx #5
	bne @-
	rts
sb_copy	ldx #4
@	lda digs+TIME,x
	sta digs+BEST,x
	dex
	bpl @-
sb_x	rts

; SpeedMaza's colour effects: the walls pulse with the music,
; later the road and the borders flash
ColourFx
	lda RMT_VOL
	and #$0F
	sta tmp
	lda #<FX5
	cmp tick
	lda #>FX5
	sbc tick+1
	bcs cf_4
	lda tick
	and #6
	tax
	jmp cf_flash
cf_4	lda #<FX4
	cmp tick
	lda #>FX4
	sbc tick+1
	bcs cf_3
	lda tick
	and #7
	cmp #7
	bne cf_4n
	ldx tmp
	cpx #5
	bcs cf_4y
cf_4n	ldx #0
	jmp cf_flash
cf_4y	ldx #1
cf_flash
	lda #$10
	ora tmp
	sta dliColPF2
	lda #0
	sta dliColBK
	sta COLOR0+3
	txa
	beq cf_x
	lda tmp
	beq cf_x
	lda #$6F
	sta dliColBK
	sta COLOR0+3
cf_x	rts
cf_3	lda #<FX3
	cmp tick
	lda #>FX3
	sbc tick+1
	bcs cf_2
	lda #$10
	ora tmp
	sta dliColPF2
	rts
cf_2	lda #<FX2
	cmp tick
	lda #>FX2
	sbc tick+1
	bcs cf_1
	lda tmp
	lsr @
	clc
	adc #2
	ora #$10
	sta dliColPF2
	rts
cf_1	lda #<FX1
	cmp tick
	lda #>FX1
	sbc tick+1
	bcs cf_0
	lda tmp
	lsr @
	lsr @
	clc
	adc #4
	ora #$10
	sta dliColPF2
	rts
cf_0	lda #$14
	sta dliColPF2
	rts

; ---- variables (cleared at start)
TIME	= 0
BEST	= 5
VarsStart
digs	.ds 10			; time digits, best digits
tenthFrames .ds 1
tdiv	.ds 1
started	.ds 1
idx	.ds 1
tick	.ds 2
frame	.ds 1
pnCount	.ds 1
dbA	.ds 1
dbB	.ds 1
topA	.ds 1
topB	.ds 1
csN	.ds 1
csC	.ds 1
giDelay	.ds 1
giTrig	.ds 1
dliCycle .ds 1
dliLine	.ds 1
dliCol	.ds 1
VarsEnd
slotRow	.ds RING_ROWS*2		; which map row each ring slot holds
dliColPF0 = $03E8		; same shadows as SpeedMaza
dliColPF1 = $03E9
dliColPF2 = $03EA
dliColBK  = $03EB

; ---- title screen: SpeedMaza's layout with smaller gaps and three credit
; lines under the MSX line (TITLE lines 0-28 logo, 29-60 GAME/CODE/GFX/MSX,
; 61-68 HI SCORE, 69-76 PRESS BUTTON, 77-84 HUSAK)
	.align $400
dlTitle
	dta $10,$50,$70,$70
	dta $CE,a(TITLE)
	:28 dta $0E
	dta $70
	dta $4E,a(TITLE+29*40)
	:7 dta $0E
	:3 dta $70,$4E,a(TITLE+(37+#*8)*40),$0E,$0E,$0E,$0E,$0E,$0E,$0E
	dta $70,$4E,a(creditPic)
	:7 dta $0E
	dta $10
	:8 dta $0E
	dta $10
	:8 dta $0E
	dta $70,$4E,a(TITLE+61*40)
	:7 dta $0E
	dta $70
	:8 dta $0E
	dta $70,$10
	:8 dta $0E
	dta $41,a(dlTitle)
creditPic			; "TINY" "MODIFICATIONS:" "ASTROFOR", 3x8 mode E lines
	ins 'data/credit_pic.bin'
CodeEnd
	.if CodeEnd > $48DF
	.error "code overlaps the RMT player"
	.endif

; ======================================================================
	org $48DF
	ins 'data/rmt_player.bin'
	org MUSIC_TITLE
	ins 'data/music.bin'

; ======================================================================
	org $8000
	icl 'gen/tables.asm'
	icl 'gen/speedmaza_data.asm'
trackRle			; map rows as lists of road spans
	ins 'data/track_rle.bin'
TablesEnd
	.if TablesEnd > $BC00
	.error "tables too big"
	.endif

	run Start
