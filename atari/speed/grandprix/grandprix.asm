; SPEEDMAZA GRAND PRIX - a 3 car, 3 lap race in the style of SpeedMaza on
; the curvy PICO-8 track (see ../race for the one car time trial).
;
; 1 PLAYER: you against two computer cars. 2 PLAYERS: joysticks 1 and 2
; against one computer car. Joystick left/right steers, up/down makes the
; car a little faster/slower. The speed of everybody grows with time.
; Points: +10 per checkpoint, -25 for hitting a wall (the car bounces back
; and is slowed down), -100 for falling behind the screen (the car comes
; back next to the leader), +1000 for the winner, +500 for second place.
;
; Build: ./build.sh   (MADS; tools/make_data.py makes data/ and gen/)

; ---- OS and hardware
RTCLOK	= $14		; jiffy counter (low byte)
ATRACT	= $4D
VDSLST	= $0200
SRTIMR	= $022B
SDMCTL	= $022F
SDLSTL	= $0230
GPRIOR	= $026F
STICK0	= $0278		; STICK1 = $0279
STRIG0	= $0284		; STRIG1 = $0285
PCOLR0	= $02C0
COLOR0	= $02C4
CH	= $02FC
HPOSP0	= $D000
HPOSM0	= $D004
P0PF	= $D004		; read: player / playfield collisions (P1PF, P2PF follow)
P0PL	= $D00C		; read: player / player collisions (P1PL, P2PL follow)
SIZEM	= $D00C
PAL	= $D014
COLPF0	= $D016
COLPF1	= $D017
COLPF2	= $D018
COLBK	= $D01A
GRACTL	= $D01D
HITCLR	= $D01E
CONSOL	= $D01F
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
MUSIC_GAME	= $5700	; game from line 0, win line $25

; ---- memory map
TITLE	= $2000		; title picture (4K, must not cross a 4K page)
FONT	= TITLE+$0F28	; 16x8 digits inside the title picture
PMB	= $5C00		; PM graphics base, double-line resolution
DLA	= $5C00		; two game display lists (double buffered)
DLB	= $5C80
DLBUF	= $5D00		; display list of the title / results screen
MIS	= PMB+$180
PL0	= PMB+$200	; players 0-2 = cars 0-2, $80 bytes apart
RING	= $6000		; 32 unpacked map rows, one 256 byte page each ($6000-$7FFF)
RING_ROWS = 32
TRACK_LINES = 23	; mode 8 lines on screen ...
TRACK_H	= TRACK_LINES*8-7	; ... 177 scan lines (VSCROL shortens the ends)
PM_LAST	= (38+TRACK_H)/2	; first PM line below the track window

; ---- test build: AUTOPILOT=1 starts by itself and lets the computer drive
; car 0 too
	.ifndef AUTOPILOT
AUTOPILOT = 0
	.endif

; ---- game rules and tuning
NCARS		= 3
	.ifndef LAPS
LAPS		= 3
	.endif
TURN		= 2	; heading units per frame (256 = full turn), as PICO-8
SPEED_START	= $0180	; 1.5 colour clocks per frame
SPEED_ACC	= $30	; base speed grows by 3/4096 cc/frame every frame ...
SPEED_MAX	= $0340	; ... up to 3.25
THR_MAX		= 64	; joystick up/down: speed +-25% (64/256)
THR_STEP	= 4
GRIP_MAX	= 64	; how fast the velocity follows the heading (/256)
GRIP_MIN	= 20	; ... at high speed the car slides more (PICO-8 drift)
STUN_WALL	= 30	; frames at half speed after hitting a wall
STUN_BUMP	= 10	; ... after two cars bump
INV_BUMP	= 12	; frames without car collisions after a bump
INV_RESPAWN	= 60	; ... after coming back next to the leader
FLASH		= 8	; frames a hit car shows white
AI_THR		= 0	; throttle of the computer cars (car 2 a bit slower)
AI2_THR		= -4
; points (BCD)
PT_CP		= $0010
PT_WALL		= $0025
PT_RESPAWN	= $0100
PT_FIRST	= $1000
PT_SECOND	= $0500
; colours
C_CAR0	= $38		; orange (PICO-8 colour 9)
C_CAR1	= $88		; blue
C_CAR2	= $C8		; green
C_HIT	= $0E
FX1 = $0300		; SpeedMaza's colour effects (frames)
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
prod	= $89		; 3 bytes
sign	= $8C
posX	= $8D		; current car: position, fraction + 16 bit (cc)
posY	= $90		; ... scan lines
velX	= $93		; 8.8 signed, per frame
velY	= $95
tgtX	= $97
tgtY	= $99
speed	= $9B		; 3 bytes: fraction, 8.8 speed
heading	= $9E
grip	= $9F
camX	= $A0
camY	= $A2
boff	= $A4
dlp	= $A5
nextH	= $A7
nextV	= $A8
tmp	= $A9		; 2 bytes
apDX	= $AB
apDY	= $AD
apZ	= $AF		; 3 bytes
row	= $B2
src	= $B4
dstp	= $B6
ysave	= $B9
spans	= $BA
span	= $BB		; 4 bytes
car	= $BF		; index of the current car
tmp2	= $C0		; 2 bytes

	opt h+

; ======================================================================
; INIT while loading: BASIC off, so $A000-$BFFF is RAM
	org $0600
LoadInit
	lda PORTB
	ora #2
	sta PORTB
	rts
	ini LoadInit

	org TITLE
	ins 'data/title_pic.bin'

; ======================================================================
	org $8000

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
	ldx #TextEnd-TextStart-1	; text lines = spaces
	lda #0
@	sta TextStart,x
	dex
	bpl @-
	lda #$0C
	sta dliCycle
	lda #1
	sta players
	ldx #6			; tenths of a second: 6 frames NTSC, 5 PAL
	lda PAL
	and #$0E
	bne @+
	ldx #5
@	stx tenthFrames
MainLoop
	jsr TitleScreen
	jsr RaceGame
	bcs MainLoop		; ESC
	jsr ResultScreen
	jmp MainLoop

; ----------------------------------------------------------------------
; Interrupts (SpeedMaza DliTitle, DliGame, DliWin + one for the text lines)

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
	bmi dt_end
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
@	ldy #0
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
	lda #<DliText		; next: the text lines
	sta VDSLST
	lda #>DliText
	sta VDSLST+1
dg_x	pla
	tay
	pla
	rti

; colours of the text lines under the track: one per car
DliText
	pha
	lda #C_CAR0
	sta WSYNC
	sta COLPF0
	lda #C_CAR1
	sta COLPF1
	lda #C_CAR2
	sta COLPF2
	lda #0
	sta COLBK
	lda dliBack		; back to the DLI at the top of the screen
	sta VDSLST
	lda dliBack+1
	sta VDSLST+1
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
dw_x	lda #<DliText
	sta VDSLST
	lda #>DliText
	sta VDSLST+1
	pla
	tay
	pla
	rti

; ----------------------------------------------------------------------
; Helpers (SpeedMaza Wait, GetInput, StopAll, HidePM)

Wait	clc
	adc RTCLOK
@	cmp RTCLOK
	bne @-
	rts

; A = $21 when a fire button is pressed (debounced), a key code, or $FF
GetInput
	lda giDelay
	beq @+
	dec giDelay
@	lda giDelay
	and #$0F
	sta giDelay
	lda STRIG0
	and STRIG0+1
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

; draw digits digs[X..X+4] at (dst) with the font of the title picture
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
; Title: SpeedMaza's, plus a line to choose 1 or 2 players

TitleScreen
	lda #<DliTitle
	sta VDSLST
	lda #>DliTitle
	sta VDSLST+1
	lda #$C0
	sta NMIEN
	jsr HidePM
	lda #<dlTitleSrc
	sta ptr
	lda #>dlTitleSrc
	sta ptr+1
	lda #$6A		; all but the JVB ...
	jsr CopyDL
	ldx #6			; ... then a text line and the JVB
@	lda tsTail,x
	sta DLBUF+$6A,x
	dex
	bpl @-
	lda #<TITLE
	sta DLBUF+5
	lda #>TITLE
	sta DLBUF+6
	lda #<DLBUF
	sta SDLSTL
	lda #>DLBUF
	sta SDLSTL+1
	lda #<(TITLE+$099F)	; best score, in the HI SCORE line
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
	lda #$1E		; the players line
	sta COLOR0+3
	jsr ShowPlayers
	lda #0
	ldx #<MUSIC_TITLE
	ldy #>MUSIC_TITLE
	jsr RMT_INIT
	lda #30			; ignore keys and fire for half a second
	jsr Wait
	lda #$FF
	sta CH
	lda STICK0
	sta tsStick
ts_lp	lda STICK0		; joystick moved or SELECT: 1 <-> 2 players
	cmp tsStick
	beq ts_sel
	sta tsStick
	cmp #15
	beq ts_sel
	jsr TogglePlayers
ts_sel	lda CONSOL
	and #2
	bne @+
	lda tsSel
	bne ts_in
	lda #1
	sta tsSel
	jsr TogglePlayers
	jmp ts_in
@	lda #0
	sta tsSel
ts_in
	.if AUTOPILOT
	jmp StopAll
	.endif
	jsr GetInput
	cmp #$1C
	beq @+
	cmp #$FF
	beq @+
	jmp StopAll		; fire / any key: race
@	lda CONSOL		; START also starts
	and #1
	bne @+
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

tsTail	dta $70,$46,a(textTitle),$41,a(DLBUF)

TogglePlayers
	lda players
	eor #3			; 1 <-> 2
	sta players
ShowPlayers
	ldx #19
@	lda txtOne,x
	ldy players
	cpy #2
	bne *+5
	lda txtTwo,x
	ora #$C0		; colour 3 (bright, set in TitleScreen)
	sta textTitle,x
	dex
	bpl @-
	rts

txtOne	dta d'  1 PLAYER  VS 2 AI '
txtTwo	dta d'  2 PLAYERS  JOY 1+2'

; ----------------------------------------------------------------------
; Results: "MAZA PASSED!" and the cars, best score first

ResultScreen
	lda #<DliWin
	sta VDSLST
	sta dliBack
	lda #>DliWin
	sta VDSLST+1
	sta dliBack+1
	lda #$C0
	sta NMIEN
	jsr HidePM
	lda #<dlWinSrc
	sta ptr
	lda #>dlWinSrc
	sta ptr+1
	lda #$1A
	jsr CopyDL
	ldx #9
@	lda rsTail,x
	sta DLBUF+$1A,x
	dex
	bpl @-
	lda #<(TITLE+$0D48)	; "MAZA PASSED!" part of the title picture
	sta DLBUF+$0D
	lda #>(TITLE+$0D48)
	sta DLBUF+$0E
	lda #<DLBUF
	sta SDLSTL
	lda #>DLBUF
	sta SDLSTL+1
	lda #6
	sta COLOR0
	lda #$0A
	sta COLOR0+1
	lda #$0E
	sta COLOR0+2
	lda #0
	sta COLOR0+4
	jsr ResultText
	lda #$25
	ldx #<MUSIC_GAME
	ldy #>MUSIC_GAME
	jsr RMT_INIT
	jsr RMT_PLAY
	lda #60			; show it for at least a second
	.if AUTOPILOT
	lda #250
	.endif
	sta tmp2
rs_lp	jsr RMT_PLAY
	lda #1
	jsr Wait
	lda tmp2
	beq @+
	dec tmp2
	lda #$FF
	sta CH
	bne rs_lp
@
	.if AUTOPILOT
	jmp StopAll
	.endif
	jsr GetInput
	cmp #$FF
	beq rs_lp
	jmp StopAll

rsTail	dta $F0,$70,$46,a(textRes),$06,$06,$41,a(DLBUF)

; three lines "1 P1 01530" in the car colours, best score first; the best
; score of a human player becomes the HI SCORE of the title screen
ResultText
	ldx #59
	lda #0
@	sta textRes,x
	dex
	bpl @-
	ldx #NCARS-1		; order = 0,1,2, then sort by score
@	txa
	sta order,x
	dex
	bpl @-
	ldy #2			; bubble sort, 3 passes are plenty
rt_pass	ldx #0
rt_cmp	lda order,x
	sta tmp
	lda order+1,x
	sta tmp+1
	stx tmp2
	ldx tmp
	lda cScHi,x
	ldx tmp+1
	cmp cScHi,x
	bcc rt_swap
	bne rt_next
	ldx tmp
	lda cScLo,x
	ldx tmp+1
	cmp cScLo,x
	bcs rt_next
rt_swap	ldx tmp2
	lda tmp
	sta order+1,x
	lda tmp+1
	sta order,x
rt_next	ldx tmp2
	inx
	cpx #NCARS-1
	bne rt_cmp
	dey
	bne rt_pass
	ldx #0			; write the lines
	stx tmp2
rt_line	lda tmp2
	asl @
	asl @
	sta tmp
	asl @
	asl @
	adc tmp			; x20
	tay
	ldx tmp2
	lda order,x
	tax
	lda carColBits,x
	sta tmp
	lda #0
	sta textRes,y
	sta textRes+1,y
	lda tmp2
	clc
	adc #$11		; '1'.. in internal code
	ora tmp
	sta textRes+2,y
	lda #0
	sta textRes+3,y
	sta textRes+4,y
	jsr CarName		; 2 letters for car X at textRes+5,y
	lda #0
	sta textRes+7,y
	sta textRes+8,y
	sta textRes+9,y
	lda cScHi,x
	jsr PutBCD
	lda cScLo,x
	jsr PutBCD
	ldx tmp2
	inx
	stx tmp2
	cpx #NCARS
	bne rt_line
	ldy #0			; best human score -> HI SCORE
@	ldx order,y
	lda carHuman,x
	bne @+
	iny
	cpy #NCARS
	bne @-
	rts
@	lda cScHi,x		; digits 0 and 1 stay 0 (scores < 10000)
	pha
	lsr @
	lsr @
	lsr @
	lsr @
	sta tmp
	pla
	and #$0F
	sta tmp+1
	lda cScLo,x
	pha
	lsr @
	lsr @
	lsr @
	lsr @
	tay
	pla
	and #$0F
	; compare with the best so far (digits BEST+1..BEST+4)
	sta tmp2+1
	sty tmp2
	lda tmp
	cmp digs+BEST+1
	bcc rt_x
	bne rt_new
	lda tmp+1
	cmp digs+BEST+2
	bcc rt_x
	bne rt_new
	lda tmp2
	cmp digs+BEST+3
	bcc rt_x
	bne rt_new
	lda tmp2+1
	cmp digs+BEST+4
	bcc rt_x
rt_new	lda tmp
	sta digs+BEST+1
	lda tmp+1
	sta digs+BEST+2
	lda tmp2
	sta digs+BEST+3
	lda tmp2+1
	sta digs+BEST+4
rt_x	rts

; "P1" / "P2" / "AI" for car X, at textRes+5,Y (colour of the car)
CarName	lda carHuman,x
	beq cn_ai
	lda #$30		; 'P'
	ora carColBits,x
	sta textRes+5,y
	txa
	clc
	adc #$11		; '1' / '2'
	ora carColBits,x
	sta textRes+6,y
	rts
cn_ai	lda #$21		; 'A'
	ora carColBits,x
	sta textRes+5,y
	lda #$29		; 'I'
	ora carColBits,x
	sta textRes+6,y
	rts

; two BCD digits of A at textRes+Y.., Y += 2 (colour of car X)
PutBCD	pha
	lsr @
	lsr @
	lsr @
	lsr @
	clc
	adc #$10		; '0'
	ora carColBits,x
	sta textRes+10,y
	pla
	and #$0F
	clc
	adc #$10
	ora carColBits,x
	sta textRes+11,y
	iny
	iny
	rts

carColBits dta $00,$40,$80	; text colour bits: PF0, PF1, PF2

; ----------------------------------------------------------------------
; The race. Returns C = 1 when ESC was pressed.

RaceGame
	lda #4
	sta dliColPF0
	lda #8
	sta dliColPF1
	lda #$14
	sta dliColPF2
	lda #0
	sta dliColBK
	lda #<DliGame
	sta dliBack
	lda #>DliGame
	sta dliBack+1
	jsr BuildDLs
	lda #$FF		; no map row unpacked yet
	ldx #RING_ROWS*2-1
@	sta slotRow,x
	dex
	bpl @-
	lda #0
	ldx #CarVarsEnd-CarVars-1
@	sta CarVars,x
	dex
	bpl @-
	ldx #4
@	sta digs+TIME,x
	dex
	bpl @-
	sta started
	sta tick
	sta tick+1
	sta frame
	sta places
	sta endWait
	sta target
	sta baseSpd
	lda #<SPEED_START
	sta baseSpd+1
	lda #>SPEED_START
	sta baseSpd+2
	lda tenthFrames
	sta tdiv
	ldx #NCARS-1		; cars on the grid, facing east
@	lda gridXLo,x
	sta cPosXL,x
	lda gridXHi,x
	sta cPosXH,x
	lda gridYLo,x
	sta cPosYL,x
	lda gridYHi,x
	sta cPosYH,x
	jsr SetPlaces
	lda #$FF
	sta cRow,x
	jsr FillHistory
	dex
	bpl @-
	lda #1			; who drives what
	sta carHuman
	lda #0
	sta carHuman+2
	lda players
	cmp #2
	beq @+
	lda #0
@	sta carHuman+1
	lda #AI_THR
	sta cThr+1
	lda #<AI2_THR
	sta cThr+2
	jsr TextLines
	lda #<DLA
	sta dlp
	lda #>DLA
	sta dlp+1
	jsr UpdateCamera
	jsr Flip
	jsr InitPM
	jsr DrawCars
	lda #<DliGame
	sta VDSLST
	lda #>DliGame
	sta VDSLST+1
	lda #1
	jsr Wait
	lda #$C0
	sta NMIEN
	lda #0
	ldx #<MUSIC_GAME
	ldy #>MUSIC_GAME
	jsr RMT_INIT
	sta HITCLR

rg_loop	jsr UpdateCamera	; next frame into the back display list
	lda RTCLOK
@	cmp RTCLOK
	beq @-
	jsr Flip		; vertical blank: show it
	jsr DrawCars
	jsr RMT_PLAY
	jsr Collisions
	jsr GetInput
	cmp #$1C		; ESC
	bne @+
	jsr StopAll
	sec
	rts
@	cmp #$21		; fire starts the race
	bne @+
	sta started
@	inc frame
	inc tick
	bne @+
	inc tick+1
@
	.if AUTOPILOT
	lda frame
	cmp #60
	bne @+
	sta started
@
	.endif
	lda started
	beq rg_show
	jsr BaseSpeed
	ldx #0
rg_car	stx car
	lda cFin,x
	bne rg_next
	jsr LoadCar
	jsr Control
	jsr Physics
	jsr Checkpoint
	ldx car
	jsr SaveCar
	jsr History
rg_next	ldx car
	inx
	cpx #NCARS
	bne rg_car
	jsr ChooseTarget
	jsr Respawns
	jsr Timer
	lda places		; race over when two cars are home
	cmp #2
	bcc rg_show
	inc endWait
	lda endWait
	cmp #90
	bcc rg_show
	jsr StopAll
	clc
	rts
rg_show	lda #<(TITLE+$0360)	; time in the status line
	sta dst
	lda #>(TITLE+$0360)
	sta dst+1
	ldx #TIME
	jsr PrintNum
	jsr TextLines
	jsr ColourFx
	jmp rg_loop

; ----------------------------------------------------------------------
; Display: two display lists with the SpeedMaza status line, 23 lines of
; mode 8 with LMS (+HSCROL+VSCROL) into the map ring, 2 text lines

BuildDLs
	lda #<DLA
	sta ptr
	lda #>DLA
	sta ptr+1
	jsr bd_one
	lda #<DLB
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
	lda #<TITLE
	sta (ptr),y
	iny
	lda #>TITLE
	sta (ptr),y
	ldy #32
	ldx #TRACK_LINES-1
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
	lda #$80		; 1 blank line with the DLI for the text colours
	sta (ptr),y
	iny
	lda #$46
	sta (ptr),y
	iny
	lda #<textLine
	sta (ptr),y
	iny
	lda #>textLine
	sta (ptr),y
	iny
	lda #$06
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

; camera on the target car; LMS of the back display list, next scroll
UpdateCamera
	ldx target
	sec
	lda cPosXL,x
	sbc #<VIEW_X
	sta camX
	lda cPosXH,x
	sbc #>VIEW_X
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
	lda #<CAM_X_MAX
	sta camX
	lda #>CAM_X_MAX
	sta camX+1
@	sec
	lda cPosYL,x
	sbc #<VIEW_Y
	sta camY
	lda cPosYH,x
	sbc #>VIEW_Y
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
	lda #<CAM_Y_MAX
	sta camY
	lda #>CAM_Y_MAX
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
	ldy #33
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
@	cpy #33+TRACK_LINES*3
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
	inc src
	bne @+
	inc src+1
@	ldy #3
@	lda (src),y
	sta span,y
	dey
	bpl @-
	ldy span
	lda (dstp),y
	and span+1
	sta (dstp),y
	iny
	lda #0
@	cpy span+2
	bcs @+
	sta (dstp),y
	iny
	bne @-
@	ldy span+2
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
	eor #$80
	sta dlp
	rts

InitPM
	lda #0
	tax
@	sta MIS,x
	sta PL0,x
	sta PL0+$80,x
	sta PL0+$100,x
	sta PL0+$180,x
	inx
	bpl @-
	lda #$FF
	sta SIZEM
	lda #>PMB
	sta PMBASE
	lda #0
	sta COLOR0+3
	lda #3
	sta GRACTL
	lda #$11
	sta GPRIOR
	lda #$FF		; missiles: borders beside the track
	ldx #19
@	sta MIS,x
	inx
	cpx #PM_LAST
	bne @-
	lda #1
	jsr Wait
	lda #$2E
	sta SDMCTL
	lda #3
	jsr Wait
	lda #$30
	sta HPOSM0
	lda #$38
	sta HPOSM0+1
	lda #$C0
	sta HPOSM0+2
	lda #$C8
	sta HPOSM0+3
	rts

; cars on screen: players 0-2 at the car positions, rows clipped to the
; track window (PM lines 19..PM_LAST-1), hidden when finished or off screen
DrawCars
	ldx #NCARS-1
dc_car	stx car
	lda cRow,x		; clear the old picture
	cmp #$FF
	beq dc_new
	jsr PlayerPtr
	ldy #9
	lda #0
@	sta (ptr),y
	dey
	bpl @-
dc_new	ldx car
	jsr ShownPos
	lda #$FF
	sta cRow,x
	lda #0
	sta HPOSP0,x
	lda cFin,x
	bne dc_next
	jsr ScreenPos		; tmp = x - camX, tmp2 = y - camY (16 bit)
	bcs dc_next		; off screen
	lda tmp			; hpos = x - camX + $2F - 4
	clc
	adc #$2B
	sta HPOSP0,x
	lda tmp2		; top PM line = (y - camY + 38) / 2 - 5
	clc
	adc #38
	lsr @
	sec
	sbc #5
	sta cRow,x
	lda cFlash,x		; colour: white for a while after a hit
	beq @+
	dec cFlash,x
	lda #C_HIT
	bne dc_col
@	lda carColour,x
dc_col	sta PCOLR0,x
	lda cHead,x		; frame = (heading + 4) / 8, 10 bytes each
	clc
	adc #4
	lsr @
	lsr @
	lsr @
	sta tmp
	asl @
	asl @
	adc tmp
	asl @			; x10 (< 320, carry to high byte)
	sta ptr2
	lda #0
	rol @
	sta ptr2+1
	clc
	lda ptr2
	adc #<carShape
	sta ptr2
	lda ptr2+1
	adc #>carShape
	sta ptr2+1
	jsr PlayerPtr
	ldy #9
@	lda cRow,x		; clip rows outside the track window
	sty tmp
	clc
	adc tmp
	cmp #19
	bcc dc_skip
	cmp #PM_LAST
	bcs dc_skip
	lda (ptr2),y
	sta (ptr),y
dc_skip	dey
	bpl @-
dc_next	ldx car
	dex
	jpl dc_car
	rts

carColour dta C_CAR0,C_CAR1,C_CAR2

; remember the position shown now, and the one shown before
ShownPos
	lda cShXL,x
	sta cPrXL,x
	lda cShXH,x
	sta cPrXH,x
	lda cShYL,x
	sta cPrYL,x
	lda cShYH,x
	sta cPrYH,x
	lda cPosXL,x
	sta cShXL,x
	lda cPosXH,x
	sta cShXH,x
	lda cPosYL,x
	sta cShYL,x
	lda cPosYH,x
	sta cShYH,x
	rts

; shown, previous and safe position of car X = its position now
SetPlaces
	lda cPosXL,x
	sta cSafeXL,x
	sta cShXL,x
	sta cPrXL,x
	lda cPosXH,x
	sta cSafeXH,x
	sta cShXH,x
	sta cPrXH,x
	lda cPosYL,x
	sta cSafeYL,x
	sta cShYL,x
	sta cPrYL,x
	lda cPosYH,x
	sta cSafeYH,x
	sta cShYH,x
	sta cPrYH,x
	rts

; ptr = player X memory + cRow
PlayerPtr
	txa
	lsr @
	ror @
	and #$80
	clc
	adc cRow,x
	sta ptr
	txa
	lsr @
	clc
	adc #>PL0
	sta ptr+1
	bcc *+4
	inc ptr+1
	rts

; position of car X on screen: tmp = x - camX, tmp2 = y - camY;
; C = 1 when it is off the track window
ScreenPos
	sec
	lda cPosXL,x
	sbc camX
	sta tmp
	lda cPosXH,x
	sbc camX+1
	bne sp_off		; < 0 or >= 256
	lda tmp
	cmp #$A4
	bcs sp_off
	sec
	lda cPosYL,x
	sbc camY
	sta tmp2
	lda cPosYH,x
	sbc camY+1
	bne sp_off
	lda tmp2
	cmp #TRACK_H
	rts
sp_off	sec
	rts

; ----------------------------------------------------------------------
; Cars

CAR_REGS = 14		; bytes of the working set copied in and out
LoadCar	lda cPosXF,x
	sta posX
	lda cPosXL,x
	sta posX+1
	lda cPosXH,x
	sta posX+2
	lda cPosYF,x
	sta posY
	lda cPosYL,x
	sta posY+1
	lda cPosYH,x
	sta posY+2
	lda cVelXL,x
	sta velX
	lda cVelXH,x
	sta velX+1
	lda cVelYL,x
	sta velY
	lda cVelYH,x
	sta velY+1
	lda cHead,x
	sta heading
	rts

SaveCar	lda posX
	sta cPosXF,x
	lda posX+1
	sta cPosXL,x
	lda posX+2
	sta cPosXH,x
	lda posY
	sta cPosYF,x
	lda posY+1
	sta cPosYL,x
	lda posY+2
	sta cPosYH,x
	lda velX
	sta cVelXL,x
	lda velX+1
	sta cVelXH,x
	lda velY
	sta cVelYL,x
	lda velY+1
	sta cVelYH,x
	lda heading
	sta cHead,x
	rts

; base speed grows with time, as in SpeedMaza, up to SPEED_MAX
BaseSpeed
	lda baseSpd+1
	cmp #<SPEED_MAX
	lda baseSpd+2
	sbc #>SPEED_MAX
	bcs @+
	clc
	lda baseSpd
	adc #SPEED_ACC
	sta baseSpd
	bcc @+
	inc baseSpd+1
	bne @+
	inc baseSpd+2
@	rts

; steering and throttle: joystick for people, AutoSteer for the computer
Control	ldx car
	.if AUTOPILOT
	jmp AutoSteer
	.endif
	lda carHuman,x
	beq ct_ai
	cpx #0			; car 0 = joystick 1, car 1 = joystick 2
	beq @+
	lda STICK0+1
	bne ct_stick
@	lda STICK0
ct_stick
	sta tmp
	and #4			; left
	bne @+
	lda heading
	clc
	adc #TURN
	sta heading
@	lda tmp
	and #8			; right
	bne @+
	lda heading
	sec
	sbc #TURN
	sta heading
@	lda tmp			; up = faster, down = slower, else back to 0
	and #3
	cmp #2			; up pressed (bit 0 = 0)
	bne ct_down
	lda cThr,x
	cmp #THR_MAX
	beq ct_x
	clc
	adc #THR_STEP
	sta cThr,x
	rts
ct_down	cmp #1			; down pressed (bit 1 = 0)
	bne ct_zero
	lda cThr,x
	cmp #<(-THR_MAX)
	beq ct_x
	sec
	sbc #THR_STEP
	sta cThr,x
	rts
ct_zero	lda cThr,x
	beq ct_x
	bmi @+
	sec
	sbc #THR_STEP
	sta cThr,x
	rts
@	clc
	adc #THR_STEP
	sta cThr,x
ct_x	rts
ct_ai	jmp AutoSteer

; speed = base * (1 + throttle/256), halved while stunned; then the car
; follows its heading with some grip (PICO-8: u=(u-r*cos)*k+r*cos) and moves
Physics
	lda baseSpd+1
	sta mcand
	lda baseSpd+2
	sta mcand+1
	ldx car
	lda cThr,x
	sta sign
	bpl @+
	eor #$FF
	clc
	adc #1
@	sta mplier
	jsr Mul16x8		; prod+1..2 = base * |thr| / 256
	lda sign
	bpl @+
	sec
	lda baseSpd+1
	sbc prod+1
	sta speed+1
	lda baseSpd+2
	sbc prod+2
	sta speed+2
	jmp ph_stun
@	clc
	lda baseSpd+1
	adc prod+1
	sta speed+1
	lda baseSpd+2
	adc prod+2
	sta speed+2
ph_stun	ldx car
	lda cStun,x
	beq @+
	dec cStun,x
	lsr speed+2
	ror speed+1
@	ldx heading		; target x = speed * cos / 128
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
	sbc #<SPEED_START
	sta tmp
	lda speed+2
	sbc #>SPEED_START
	bcc ph_max		; slower than the start speed
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
ph_max	lda #GRIP_MAX
	bne ph_g
ph_min	lda #GRIP_MIN
ph_g	sta grip
	ldx #0
	jsr Follow
	ldx #2
	jsr Follow
	ldx #0
	jsr Move
	ldx #3

; pos[x] (24 bit) += vel (sign extended); X = 0 for x, 3 for y
Move	txa
	lsr @
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

; computer driver: turn towards the next checkpoint (cross product sign)
AutoSteer
	jsr TurnSign
	bmi as_r
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

; A = sign of z = 2*sinY*dx - cos*dy towards checkpoint cIdx of the current
; car: > 0 turn left, < 0 turn right (N/Z flags set from A)
TurnSign
	ldy car
	ldx cIdx,y
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
	asl prod
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
	sec
	lda apZ
	sbc prod
	sta apZ
	lda apZ+1
	sbc prod+1
	sta apZ+1
	lda apZ+2
	sbc prod+2
	bmi ts_neg
	ora apZ+1
	ora apZ
	beq ts_zero
	lda #1
	rts
ts_neg	lda #$FF
	rts
ts_zero	lda #0
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

; next checkpoint reached: +10 points; after the last one a new lap, and
; after the last lap the car is home (1st and 2nd get a bonus)
Checkpoint
	ldx car
	ldy cIdx,x
	sec
	lda posX+1
	sbc cpXLo,y
	sta tmp
	lda posX+2
	sbc cpXHi,y
	jsr InBoxX
	bcc cp_no
	sec
	lda posY+1
	sbc cpYLo,y
	sta tmp
	lda posY+2
	sbc cpYHi,y
	jsr InBoxY
	bcc cp_no
	lda #<PT_CP
	ldy #>PT_CP
	jsr AddPoints
	inc cIdx,x
	lda cIdx,x
	cmp #CP_COUNT
	bcc cp_no
	lda #0
	sta cIdx,x
	inc cLap,x
	lda cLap,x
	cmp #LAPS
	bcc cp_no
	inc places		; home
	lda places
	sta cFin,x
	cmp #1
	bne @+
	lda #<PT_FIRST
	ldy #>PT_FIRST
	jmp AddPoints
@	cmp #2
	bne cp_no
	lda #<PT_SECOND
	ldy #>PT_SECOND
	jmp AddPoints
cp_no	rts

; C = 1 when the 16-bit difference A:tmp lies inside +-CP_RX / +-CP_RY
InBoxX	cmp #0
	beq @+
	cmp #$FF
	bne ib_no
	lda tmp
	cmp #256-CP_RX
	rts
@	lda tmp
	cmp #CP_RX
	jmp ib_inv
InBoxY	cmp #0
	beq @+
	cmp #$FF
	bne ib_no
	lda tmp
	cmp #256-CP_RY
	rts
@	lda tmp
	cmp #CP_RY
ib_inv	bcc ib_yes
ib_no	clc
	rts
ib_yes	sec
	rts

; score of car X += A:Y (BCD, low:high)
AddPoints
	sed
	clc
	adc cScLo,x
	sta cScLo,x
	tya
	adc cScHi,x
	sta cScHi,x
	cld
	bcc @+
	lda #$99		; 9999 at most
	sta cScLo,x
	sta cScHi,x
@	rts

; score of car X -= A:Y (BCD), not below 0
SubPoints
	sta tmp
	sty tmp+1
	sed
	sec
	lda cScLo,x
	sbc tmp
	sta cScLo,x
	lda cScHi,x
	sbc tmp+1
	sta cScHi,x
	cld
	bcs @+
	lda #0
	sta cScLo,x
	sta cScHi,x
@	rts

; every 4 frames: remember where the car was (for cars coming back)
History	lda frame
	and #3
	bne hi_x
	ldx car
	lda cHist,x
	clc
	adc #1
	and #7
	sta cHist,x
	jsr HistIndex
	lda cPosXL,x
	sta hX,y
	lda cPosXH,x
	sta hX+1,y
	lda cPosYL,x
	sta hY,y
	lda cPosYH,x
	sta hY+1,y
	lda cHead,x
	sta hHead,y
hi_x	rts

; Y = history slot A of car X (8 slots, 2 bytes each)
HistIndex
	and #7
	sta tmp
	txa
	asl @
	asl @
	asl @
	ora tmp
	asl @
	tay
	rts

; all history slots of car X = its position now
FillHistory
	lda #7
	sta tmp2
@	lda tmp2
	jsr HistIndex
	lda cPosXL,x
	sta hX,y
	lda cPosXH,x
	sta hX+1,y
	lda cPosYL,x
	sta hY,y
	lda cPosYH,x
	sta hY+1,y
	lda #0
	sta hHead,y
	dec tmp2
	bpl @-
	rts

; the camera follows the leader: most laps, then most checkpoints
ChooseTarget
	ldx target
	lda cFin,x
	beq @+
	ldx #0			; target is home: take the first car still racing
ct_find	lda cFin,x
	beq ct_set
	inx
	cpx #NCARS
	bne ct_find
	rts
ct_set	stx target
@	ldx #0
ct_cmp	cpx target
	beq ct_nx
	lda cFin,x
	bne ct_nx
	ldy target
	lda cLap,x
	cmp cLap,y
	bcc ct_nx
	bne ct_new
	lda cIdx,x
	cmp cIdx,y
	bcc ct_nx
	beq ct_nx
ct_new	stx target
ct_nx	inx
	cpx #NCARS
	bne ct_cmp
	rts

; a car that fell off the screen comes back just behind the leader, in the
; leader's direction and on the leader's lap: -100 points
Respawns
	ldx #NCARS-1
rp_car	stx car
	cpx target
	jeq rp_next
	lda cFin,x
	ora cInv,x		; just came back: give it time
	bne rp_next
	jsr ScreenPos
	bcc rp_next
	lda #<PT_RESPAWN
	ldy #>PT_RESPAWN
	jsr SubPoints
	ldy target		; where the leader was 2 slots (8 frames) ago
	lda cHist,y
	sec
	sbc #2
	sty tmp2
	pha
	tya
	tax
	pla
	jsr HistIndex
	ldx car
	lda hX,y
	sta cPosXL,x
	lda hX+1,y
	sta cPosXH,x
	lda hY,y
	sta cPosYL,x
	lda hY+1,y
	sta cPosYH,x
	jsr SetPlaces
	lda hHead,y
	sta cHead,x
	lda #0
	sta cPosXF,x
	sta cPosYF,x
	sta cStun,x
	ldy tmp2
	lda cVelXL,y
	sta cVelXL,x
	lda cVelXH,y
	sta cVelXH,x
	lda cVelYL,y
	sta cVelYL,x
	lda cVelYH,y
	sta cVelYH,x
	lda cIdx,y
	sta cIdx,x
	lda cLap,y
	sta cLap,x
	lda #INV_RESPAWN
	sta cInv,x
	lda #FLASH
	sta cFlash,x
	jsr FillHistory
rp_next	ldx car
	dex
	jpl rp_car
	rts

; collisions of the frame just shown. Wall: back to the last safe place,
; bounce, slow down, -25 points. Two cars: they swap speeds and are pushed
; apart.
Collisions
	ldx #NCARS-1
@	lda P0PF,x
	sta hitPF,x
	lda P0PL,x
	sta hitPL,x
	dex
	bpl @-
	sta HITCLR
	lda started
	bne @+
	rts
@	ldx #NCARS-1
co_wall	lda cFin,x
	jne co_next
	lda cInv,x
	beq @+
	dec cInv,x
@	lda hitPF,x
	and #4
	beq co_safe
	lda cStun,x		; hit a moment ago: already handled
	cmp #STUN_WALL-2
	bcc co_hit
	jmp co_next
co_safe
	lda cPrXL,x		; no wall: where it was shown is safe
	sta cSafeXL,x
	lda cPrXH,x
	sta cSafeXH,x
	lda cPrYL,x
	sta cSafeYL,x
	lda cPrYH,x
	sta cSafeYH,x
	jmp co_next
co_hit	stx car
	lda cSafeXL,x		; back to safety
	sta cPosXL,x
	lda cSafeXH,x
	sta cPosXH,x
	lda cSafeYL,x
	sta cPosYL,x
	lda cSafeYH,x
	sta cPosYH,x
	lda #0
	sta cPosXF,x
	sta cPosYF,x
	lda cVelXL,x		; bounce: velocity = -velocity / 2
	sta tmp
	lda cVelXH,x
	jsr NegHalf
	sta cVelXH,x
	lda tmp
	sta cVelXL,x
	lda cVelYL,x
	sta tmp
	lda cVelYH,x
	jsr NegHalf
	sta cVelYH,x
	lda tmp
	sta cVelYL,x
	lda #STUN_WALL
	sta cStun,x
	lda #FLASH
	sta cFlash,x
	lda #<PT_WALL
	ldy #>PT_WALL
	jsr SubPoints
	jsr LoadCar		; turn a little towards the road
	jsr TurnSign
	pha
	ldx car
	pla
	beq co_next
	bmi @+
	lda cHead,x
	clc
	adc #12
	sta cHead,x
	jmp co_next
@	lda cHead,x
	sec
	sbc #12
	sta cHead,x
co_next	dex
	jpl co_wall
	ldx #0			; car pairs (0,1) (0,2) (1,2)
	ldy #1
	jsr Bump
	ldx #0
	ldy #2
	jsr Bump
	ldx #1
	ldy #2
	; fall through

; cars X and Y touched: swap velocities, push apart
Bump	lda hitPL,x
	and bitOf,y
	bne @+
	rts
@	lda cFin,x
	ora cFin,y
	ora cInv,x
	ora cInv,y
	beq @+
	rts
@	lda cVelXL,x
	pha
	lda cVelXL,y
	sta cVelXL,x
	pla
	sta cVelXL,y
	lda cVelXH,x
	pha
	lda cVelXH,y
	sta cVelXH,x
	pla
	sta cVelXH,y
	lda cVelYL,x
	pha
	lda cVelYL,y
	sta cVelYL,x
	pla
	sta cVelYL,y
	lda cVelYH,x
	pha
	lda cVelYH,y
	sta cVelYH,x
	pla
	sta cVelYH,y
	lda #INV_BUMP
	sta cInv,x
	sta cInv,y
	lda #STUN_BUMP
	sta cStun,x
	sta cStun,y
	lda #FLASH
	sta cFlash,x
	sta cFlash,y
	sec			; push apart: 3 cc and 4 lines
	lda cPosXL,x
	sbc cPosXL,y
	lda cPosXH,x
	sbc cPosXH,y
	bmi @+
	lda #3
	jsr PushX
	jmp bu_y
@	lda #-3
	jsr PushX
bu_y	sec
	lda cPosYL,x
	sbc cPosYL,y
	lda cPosYH,x
	sbc cPosYH,y
	bmi @+
	lda #4
	jmp PushY
@	lda #-4
	jmp PushY

bitOf	dta 1,2,4

; car X x += A, car Y x -= A (A signed, small)
PushX	sta tmp
	jsr ExtA
	clc
	lda cPosXL,x
	adc tmp
	sta cPosXL,x
	lda cPosXH,x
	adc tmp+1
	sta cPosXH,x
	sec
	lda cPosXL,y
	sbc tmp
	sta cPosXL,y
	lda cPosXH,y
	sbc tmp+1
	sta cPosXH,y
	rts
PushY	sta tmp
	jsr ExtA
	clc
	lda cPosYL,x
	adc tmp
	sta cPosYL,x
	lda cPosYH,x
	adc tmp+1
	sta cPosYH,x
	sec
	lda cPosYL,y
	sbc tmp
	sta cPosYL,y
	lda cPosYH,y
	sbc tmp+1
	sta cPosYH,y
	rts
; tmp+1 = sign extension of tmp
ExtA	lda tmp
	and #$80
	beq @+
	lda #$FF
@	sta tmp+1
	rts

; A:tmp (high:low, signed) -> -(A:tmp)/2, result high in A, low in tmp
NegHalf	cmp #$80		; arithmetic shift right
	ror @
	ror tmp
	sta tmp+1
	lda #0
	sec
	sbc tmp
	sta tmp
	lda #0
	sbc tmp+1
	rts

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
	bpl @-
tm_x	rts

; text under the track: "1:0000 2:0000 3:0000" and "P1 L1  AI L2  AI 1ST"
TextLines
	ldx #0
tl_car	txa			; column = car * 7
	asl @
	asl @
	asl @
	sta tmp
	txa
	eor #$FF
	sec
	adc tmp			; x7
	tay
	txa
	clc
	adc #$11		; '1'
	ora carColBits,x
	sta textLine,y
	lda #$1A		; ':'
	ora carColBits,x
	sta textLine+1,y
	lda cScHi,x
	jsr PutTL
	lda cScLo,x
	jsr PutTL
	tya			; second line
	sec
	sbc #4
	tay
	lda carHuman,x
	beq tl_ai
	lda #$30		; 'P'
	ora carColBits,x
	sta textLine+20,y
	txa
	clc
	adc #$11
	ora carColBits,x
	sta textLine+21,y
	jmp tl_lap
tl_ai	lda #$21		; 'A'
	ora carColBits,x
	sta textLine+20,y
	lda #$29		; 'I'
	ora carColBits,x
	sta textLine+21,y
tl_lap	lda cFin,x
	bne tl_home
	lda #$2C		; 'L'
	ora carColBits,x
	sta textLine+23,y
	lda cLap,x
	clc
	adc #$11		; lap 1..3
	ora carColBits,x
	sta textLine+24,y
	lda #0
	sta textLine+25,y
	jmp tl_next
tl_home	sec			; 1ST / 2ND / 3RD
	sbc #1
	sta tmp
	asl @
	adc tmp
	sty tmp2
	tay
	lda placeTxt,y
	sta tmp+1
	lda placeTxt+1,y
	pha
	lda placeTxt+2,y
	ldy tmp2
	ora carColBits,x
	sta textLine+25,y
	pla
	ora carColBits,x
	sta textLine+24,y
	lda tmp+1
	ora carColBits,x
	sta textLine+23,y
tl_next	inx
	cpx #NCARS
	beq @+
	jmp tl_car
@	rts

placeTxt dta d'1ST2ND3RD'

; two BCD digits of A at textLine+2+Y.., Y += 2 (colour of car X)
PutTL	pha
	lsr @
	lsr @
	lsr @
	lsr @
	clc
	adc #$10
	ora carColBits,x
	sta textLine+2,y
	pla
	and #$0F
	clc
	adc #$10
	ora carColBits,x
	sta textLine+3,y
	iny
	iny
	rts

; SpeedMaza's colour effects: the walls pulse with the music, later the
; road and the borders flash
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
digs	.ds 10			; race time digits, best score digits
tenthFrames .ds 1
players	.ds 1
tdiv	.ds 1
started	.ds 1
tick	.ds 2
frame	.ds 1
places	.ds 1
endWait	.ds 1
target	.ds 1
baseSpd	.ds 3
pnCount	.ds 1
tsStick	.ds 1
tsSel	.ds 1
giDelay	.ds 1
giTrig	.ds 1
dliCycle .ds 1
dliLine	.ds 1
dliCol	.ds 1
dliBack	.ds 2
order	.ds NCARS
hitPF	.ds NCARS
hitPL	.ds NCARS
carHuman .ds NCARS
VarsEnd
; per car (cleared when a race starts)
CarVars
cPosXF	.ds NCARS
cPosXL	.ds NCARS
cPosXH	.ds NCARS
cPosYF	.ds NCARS
cPosYL	.ds NCARS
cPosYH	.ds NCARS
cVelXL	.ds NCARS
cVelXH	.ds NCARS
cVelYL	.ds NCARS
cVelYH	.ds NCARS
cHead	.ds NCARS
cThr	.ds NCARS
cIdx	.ds NCARS
cLap	.ds NCARS
cFin	.ds NCARS		; 0 racing, else finishing place
cStun	.ds NCARS
cInv	.ds NCARS
cFlash	.ds NCARS
cScLo	.ds NCARS		; points, BCD
cScHi	.ds NCARS
cSafeXL	.ds NCARS		; last place without a wall hit
cSafeXH	.ds NCARS
cSafeYL	.ds NCARS
cSafeYH	.ds NCARS
cRow	.ds NCARS		; PM line of the car picture ($FF = none)
cHist	.ds NCARS
CarVarsEnd
; where each car was shown in this frame and in the one before (the
; collision registers describe the frame before)
cShXL	.ds NCARS
cShXH	.ds NCARS
cShYL	.ds NCARS
cShYH	.ds NCARS
cPrXL	.ds NCARS
cPrXH	.ds NCARS
cPrYL	.ds NCARS
cPrYH	.ds NCARS
hX	.ds NCARS*16
hY	.ds NCARS*16
hHead	.ds NCARS*16
slotRow	.ds RING_ROWS*2
TextStart
textLine .ds 40
textTitle .ds 20
textRes	.ds 60
TextEnd
dliColPF0 = $03E8		; same shadows as SpeedMaza
dliColPF1 = $03E9
dliColPF2 = $03EA
dliColBK  = $03EB

; ======================================================================
	icl 'gen/tables.asm'
	icl 'gen/speedmaza_data.asm'
trackRle
	ins 'data/track_rle.bin'
TablesEnd
	.if TablesEnd > $BC00
	.error "program too big"
	.endif

	org $48DF
	ins 'data/rmt_player.bin'
	org MUSIC_TITLE
	ins 'data/music.bin'

	run Start
