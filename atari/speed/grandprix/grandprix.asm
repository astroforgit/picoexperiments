; SPEEDMAZA GRAND PRIX - a championship for up to 3 cars in the style of
; SpeedMaza on the four PICO-8 tracks (see ../race for the time trial).
;
; Options screen: players (1: you + 2 computer cars, 2: joysticks 1 and 2 +
; 1 computer car), first track, number of races, laps, difficulty, speed,
; oil patches. Joystick left/right steers, up/down makes the car a little
; faster/slower; everybody's speed grows with time. Points: +10 per
; checkpoint, -25 for hitting a wall (the car bounces back and is slowed),
; -100 for falling behind the screen (the car comes back next to the
; leader), +1000 for the winner of a race, +500 for second place.
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
COLPF3	= $D019
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
AUDF4	= $D206		; sound effects use channel 4 over the music
AUDC4	= $D207

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
DLBUF	= $5D00		; display list of the options / results screen
UNBUF	= $6000		; a track is unpacked here first (the ring is free then)
MIS	= PMB+$180
PL0	= PMB+$200	; players 0-2 = cars 0-2, $80 bytes apart
RING	= $6000		; 32 unpacked map rows, one 256 byte page each ($6000-$7FFF)
RING_ROWS = 32
TRACK_LINES = 23	; mode 8 lines on screen ...
TRACK_H	= TRACK_LINES*8-7	; ... 177 scan lines (VSCROL shortens the ends)
PM_LAST	= (38+TRACK_H)/2	; first PM line below the track window

; ---- test build: AUTOPILOT=1 starts by itself and lets the computer drive
; car 0 too; AUTOPILOT=2 lets car 0 drive straight on (wall test)
	.ifndef AUTOPILOT
AUTOPILOT = 0
	.endif

; ---- game rules and tuning (the options screen picks laps, speed etc.)
NCARS		= 3
TURN		= 2	; heading units per frame (256 = full turn), as PICO-8
THR_MAX		= 64	; joystick up/down: speed +-25% (64/256)
THR_STEP	= 4
GRIP_MAX	= 64	; how fast the velocity follows the heading (/256)
GRIP_MIN	= 20	; ... at high speed the car slides more (PICO-8 drift)
GRIP_OIL	= 6	; ... and much more on oil
OIL_TIME	= 40	; frames a car slides after touching oil
STUN_WALL	= 30	; frames at half speed after hitting a wall
STUN_BUMP	= 10	; ... after two cars bump
INV_BUMP	= 12	; frames without car collisions after a bump
INV_RESPAWN	= 60	; ... after coming back next to the leader
FLASH		= 8	; frames a hit car shows white
COUNT_STEP	= 50	; frames per step of the 3-2-1-GO countdown
SPIN_TIME	= 32	; oil: frames of spinning (8 heading units a frame = 1 turn)
BOOST_MAX	= 9	; booster: charge 1..9 ...
BOOST_FILL	= 90	; ... one step more every 90 frames ...
BOOST_USE	= 20	; ... one step less every 20 frames of boosting (9 = 3 s)
CATCH_ON	= 90	; a computer car catching up keeps boosting this long on screen
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
C_OIL	= $08
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
	lda #$0C
	sta dliCycle
	ldx #OPTS-1		; default options
@	lda optDefault,x
	sta optVal,x
	dex
	bpl @-
	lda #1
	sta optRaces
	ldx #6			; tenths of a second: 6 frames NTSC, 5 PAL
	lda PAL
	and #$0E
	bne @+
	ldx #5
@	stx tenthFrames
	jsr MoveLow		; packed tracks to $0700 (DOS is not needed any more)
MainLoop
	jsr OptionsScreen
	ldx #NCARS*3-1		; championship: totals = 0
	lda #0
@	sta cTotL,x
	dex
	bpl @-
	sta raceNo
ml_race	lda optTrack		; tracks in turn from the chosen one
	clc
	adc raceNo
	sec
	sbc #1
	and #TRACKS-1
	sta track
	jsr LoadTrack
	jsr CountScreens
	jsr RaceGame
	bcs MainLoop		; ESC
	jsr AddTotals
	jsr ResultScreen
	inc raceNo
	lda raceNo
	cmp optRaces
	bcc ml_race
	jmp MainLoop

; copy the packed tracks loaded at LOW_TEMP down to LOW_AREA
MoveLow	lda #<LOW_TEMP
	sta src
	lda #>LOW_TEMP
	sta src+1
	lda #<LOW_AREA
	sta dstp
	lda #>LOW_AREA
	sta dstp+1
	ldx #>(LOW_SIZE+255)	; whole pages
	ldy #0
@	lda (src),y
	sta (dstp),y
	iny
	bne @-
	inc src+1
	inc dstp+1
	dex
	bne @-
	rts

; race points -> championship totals (BCD, 3 bytes)
AddTotals
	ldx #NCARS-1
@	sed
	clc
	lda cTotL,x
	adc cScLo,x
	sta cTotL,x
	lda cTotM,x
	adc cScHi,x
	sta cTotM,x
	lda cTotH,x
	adc #0
	sta cTotH,x
	cld
	dex
	bpl @-
	rts

; ----------------------------------------------------------------------
; Interrupts (SpeedMaza DliTitle, DliGame, DliWin + one for the text lines)

DliTitle
	pha
	tya
	pha
	lda #<DliMenu		; the next DLI (inside this one) colours the menu
	sta VDSLST
	lda #>DliMenu
	sta VDSLST+1
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
@	lda P0PF		; collisions of the frame just shown (the
	sta hitPF		; registers are cleared below the minimap)
	lda P0PF+1
	sta hitPF+1
	lda P0PF+2
	sta hitPF+2
	lda P0PL
	sta hitPL
	lda P0PL+1
	sta hitPL+1
	lda P0PL+2
	sta hitPL+2
	lda #1
	sta hitNew
	lda miniHpos		; players: dots on the minimap first
	sta HPOSP0
	lda miniHpos+1
	sta HPOSP0+1
	lda miniHpos+2
	sta HPOSP0+2
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
	lda carHpos		; ... then the cars on the track
	sta HPOSP0
	lda carHpos+1
	sta HPOSP0+1
	lda carHpos+2
	sta HPOSP0+2
	sta HITCLR		; the dots must not count as collisions (DliGame
				; saved the registers at its start)
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
	lda #$0E
	sta COLPF3
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
; Options screen: SpeedMaza's logo and colour bands, a menu in big letters,
; the HI SCORE. Joystick up/down picks a line, left/right changes it, fire
; (or SPACE / START) starts the championship.

OPTS	= 9			; settings
optPlayers = optVal
optTrack = optVal+1
optLaps	= optVal+2
optDiff	= optVal+3
optSpeed = optVal+4
optOil	= optVal+5
optFx	= optVal+6		; flashing: none, soft, normal, hard
optMap	= optVal+7		; minimap in the status bar
optBoost = optVal+8		; booster
MENU_LINES = 7			; lines on the options screen
IT_MORE	= $80			; menu lines that are not settings
IT_START = $81
IT_BACK	= $82

OptionsScreen
	lda #<DliTitle
	sta VDSLST
	lda #>DliTitle
	sta VDSLST+1
	lda #$C0
	sta NMIEN
	jsr HidePM
	ldx #OPT_DL_LEN-1
@	lda optDL,x
	sta DLBUF,x
	dex
	bpl @-
	lda #<DLBUF
	sta SDLSTL
	lda #>DLBUF
	sta SDLSTL+1
	lda #$60		; logo colours as on SpeedMaza's title
	sta COLOR0
	lda #$62
	sta COLOR0+1
	sta COLOR0+2
	lda #0
	sta COLOR0+4
	ldx #19			; HI SCORE line
@	lda txtHi,x
	sta textHi,x
	dex
	bpl @-
	ldx #4
@	lda digs+BEST,x
	ora #$10		; '0'..'9'
	ora #$40		; colour 1
	sta textHi+13,x
	dex
	bpl @-
	lda #0			; main menu, first line
	sta optSel
	sta optPage
	jsr DrawMenu
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
os_lp	lda STICK0		; act when the joystick moves
	cmp tsStick
	jeq os_in
	sta tsStick
	cmp #14			; up
	bne @+
	dec optSel
	bpl os_draw
	ldx optPage
	ldy menuLen,x
	dey
	sty optSel
	jmp os_draw
@	cmp #13			; down
	bne @+
	inc optSel
	ldx optPage
	lda optSel
	cmp menuLen,x
	bcc os_draw
	lda #0
	sta optSel
	jmp os_draw
@	pha
	jsr SelItem		; X = setting of the chosen line (N: not a setting)
	pla
	cpx #0
	bmi os_spec
	cmp #11			; left
	bne @+
	lda optVal,x
	cmp optMin,x
	beq os_max
	dec optVal,x
	jmp os_draw
os_max	lda optMax,x
	sta optVal,x
	jmp os_draw
@	cmp #7			; right
	bne os_in
	lda optVal,x
	cmp optMax,x
	beq os_min
	inc optVal,x
	jmp os_draw
os_min	lda optMin,x
	sta optVal,x
	jmp os_draw
os_spec	cmp #7			; right on MORE OPTIONS / BACK: go there
	bne os_in
	jsr MenuEnter
	bcs os_go
os_draw	lda #SFX_BUMP
	jsr SfxStart
	jsr DrawMenu
os_in	jsr GetInput
	cmp #$1C
	beq @+
	cmp #$FF
	beq @+
	jsr SelItem		; fire: MORE / BACK switch pages, START starts;
	bmi os_ent		; on a setting line: main page starts, the
	ldx optPage		; other page goes back
	beq os_go
	ldx #IT_BACK
os_ent	jsr MenuEnter
	bcs os_go
	jmp os_draw
@	lda CONSOL		; START
	and #1
	beq os_go
	.if AUTOPILOT
	jmp os_go
	.endif
	jsr RMT_PLAY
	jsr SfxTick
	lda #1
	jsr Wait
	jsr RMT_PLAY
	ldx #$4B
@	sta WSYNC
	dex
	bpl @-
	jmp os_lp
os_go	jmp StopAll

; X = item of the chosen line (a setting number, or IT_...), flags of X
SelItem	ldx optPage
	lda menuStart,x
	clc
	adc optSel
	tax
	lda menuItems,x
	tax
	rts

; MORE OPTIONS / BACK / START RACE (item X): C = 1 to start the race
MenuEnter
	cpx #IT_START
	beq me_go
	cpx #IT_MORE
	bne @+
	lda #1			; to the second page
	sta optPage
	lda #0
	sta optSel
	clc
	rts
@	cpx #IT_BACK
	bne me_no
	lda #0			; back: main page, on MORE OPTIONS
	sta optPage
	lda #MORE_LINE
	sta optSel
me_no	clc
	rts
me_go	sec
	rts

; the menu lines of the page: label, value; the chosen line in colour 3
DrawMenu
	ldx #MENU_LINES*20-1	; empty lines
	lda #0
@	sta menuText,x
	dex
	cpx #$FF
	bne @-
	ldx optPage		; help line of the page
	ldy helpOfs,x
	ldx #0
@	lda txtHelp,y
	sta textHi+20,x
	iny
	inx
	cpx #20
	bne @-
	lda #0
	sta dmLine
dm_line	ldx optPage
	lda dmLine
	cmp menuLen,x
	bcc @+
	rts
@	asl @			; start of the line: dmLine * 20
	asl @
	sta tmp
	asl @
	asl @
	adc tmp
	sta tmp+1
	lda #0			; colours: chosen line all colour 3
	sta colL
	lda #$40
	sta colV
	lda dmLine
	cmp optSel
	bne @+
	lda #$C0
	sta colL
	sta colV
@	lda dmLine
	clc
	adc menuStart,x
	tax
	lda menuItems,x
	sta dmItem
	and #$7F		; label: 18 characters, settings first then IT_...
	bit dmItem
	bpl @+
	clc
	adc #OPTS
@	sta tmp			; x 18
	asl @
	asl @
	asl @
	adc tmp
	asl @
	tax
	lda #18
	sta pnCount
	ldy tmp+1
@	lda optLabel,x
	ora colL
	sta menuText,y
	inx
	iny
	dec pnCount
	bne @-
	ldx dmItem		; value of a setting over the last 6 characters
	bmi dm_next
	lda optVal,x
	clc
	adc optStr,x
	sta tmp			; string number * 6
	asl @
	adc tmp
	asl @
	tax
	lda tmp+1
	clc
	adc #12
	tay
	lda #6
	sta pnCount
@	lda valStr,x
	ora colV
	sta menuText,y
	inx
	iny
	dec pnCount
	bne @-
dm_next	inc dmLine
	jmp dm_line

; the second DLI of the options screen: colours of the menu
DliMenu	pha
	lda #$0C		; labels
	sta COLPF0
	lda #$1E		; values
	sta COLPF1
	lda #$3A		; chosen line
	sta COLPF3
	lda #<DliTitle
	sta VDSLST
	lda #>DliTitle
	sta VDSLST+1
	pla
	rti

;		slow   normal fast
spdStartLo dta <$0140, <$0180, <$01C0	; start speed (8.8 colour clocks)
spdStartHi dta >$0140, >$0180, >$01C0
spdAcc	dta $20,    $30,    $40	; growth per frame (1/65536)
spdMaxLo dta <$02C0, <$0340, <$03C0
spdMaxHi dta >$02C0, >$0340, >$03C0

; settings: players, track, laps, difficulty, speed, oil, flash, map, booster
	.ifdef TESTOPT
optDefault dta 1,1,1,1,1,1,2,1,1	; test: 1 lap
	.else
optDefault dta 1,1,3,1,1,1,2,1,1
	.endif
optMin	dta 1,1,1,0,0,0,0,0,0
optMax	dta 2,TRACKS,5,2,2,1,3,1,1
optStr	dta $FF,$FF,$FF,5,8,11,14,11,11	; + value = number of the value string
; the two pages: items of their lines
menuItems
menuMain dta 0,1,2,3,4,IT_MORE,IT_START
menuMore dta 5,6,7,8,IT_BACK
menuStart dta 0,menuMore-menuItems
menuLen	dta menuMore-menuMain,menuStart-menuMore
MORE_LINE = 5			; line of MORE OPTIONS on the main page
helpOfs	dta 0,20
; labels (18 characters): the settings, then MORE OPTIONS, START RACE, BACK
optLabel dta d' PLAYERS          '
	dta d' TRACK            '
	dta d' LAPS             '
	dta d' DIFFICULTY       '
	dta d' SPEED            '
	dta d' OIL              '
	dta d' FLASH            '
	dta d' MAP              '
	dta d' BOOSTER          '
	dta d' MORE OPTIONS     '
	dta d' START RACE       '
	dta d' BACK             '
valStr	dta d'1     2     3     4     5     '
	dta d'EASY  NORMALHARD  '
	dta d'SLOW  NORMALFAST  '
	dta d'OFF   ON    '
	dta d'      '		; 13: not used
	dta d'NONE  SOFT  NORMALHARD  '
txtHi	dta d'    HI SCORE        '
txtHelp	dta d'JOY:MOVE  FIRE:START'
	dta d'JOY:MOVE  FIRE:BACK '

optDL	dta $70,$70,$70,$CE,a(TITLE)
	:28 dta $0E
	dta $F0,$47,a(menuText)
	:MENU_LINES-1 dta $07
	dta $70,$46,a(textHi),$06,$41,a(DLBUF)
OPT_DL_LEN = *-optDL

; ----------------------------------------------------------------------
; Results after each race: "MAZA PASSED!", a header and the cars by
; championship points: place, name, points of this race, total. After the
; last race the best human total becomes the HI SCORE.

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

rsTail	dta $F0,$46,a(textRes),$06,$06,$06,$41,a(DLBUF)

ResultText
	ldx #79			; 4 lines of spaces
	lda #0
@	sta textRes,x
	dex
	bpl @-
	ldx #19			; header
	lda optRaces
	cmp #1
	beq rt_one
	lda raceNo
	clc
	adc #1
	cmp optRaces
	beq rt_final
@	lda txtRace,x		; header in colour 3 (white)
	ora #$C0
	sta textRes,x
	dex
	bpl @-
	lda raceNo
	clc
	adc #$11		; '1'..
	ora #$C0
	sta textRes+9
	lda optRaces
	clc
	adc #$10
	ora #$C0
	sta textRes+14
	jmp rt_sort
rt_one	lda txtResult,x
	ora #$C0
	sta textRes,x
	dex
	bpl rt_one
	jmp rt_sort
rt_final
	lda txtFinal,x
	ora #$C0
	sta textRes,x
	dex
	bpl rt_final
rt_sort	ldx #NCARS-1		; order = 0,1,2, then sort by total
@	txa
	sta order,x
	dex
	bpl @-
	ldy #2
rt_pass	ldx #0
rt_cmp	lda order,x
	sta tmp
	lda order+1,x
	sta tmp+1
	stx tmp2
	ldx tmp			; a < b ? (3 byte BCD)
	lda cTotH,x
	ldx tmp+1
	cmp cTotH,x
	bcc rt_swap
	bne rt_next
	ldx tmp
	lda cTotM,x
	ldx tmp+1
	cmp cTotM,x
	bcc rt_swap
	bne rt_next
	ldx tmp
	lda cTotL,x
	ldx tmp+1
	cmp cTotL,x
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
	lda #0			; lines 2-4: " 1 P1  1530  04530"
	sta tmp2
rt_line	lda tmp2
	clc
	adc #1
	asl @
	asl @
	sta tmp
	asl @
	asl @
	adc tmp			; (place + 1) * 20
	tay
	ldx tmp2
	lda order,x
	tax
	lda tmp2
	clc
	adc #$11		; '1'..
	ora carColBits,x
	sta textRes+1,y
	jsr CarName		; at textRes+3,Y
	lda cScHi,x		; race points at +6
	jsr ResBCD
	lda cScLo,x
	jsr ResBCD
	iny			; total at +12
	iny
	lda cTotH,x
	and #$0F
	clc
	adc #$10
	ora carColBits,x
	sta textRes+6,y
	iny
	lda cTotM,x
	jsr ResBCD
	lda cTotL,x
	jsr ResBCD
	inc tmp2
	lda tmp2
	cmp #NCARS
	bne rt_line
	lda raceNo		; last race: best human total -> HI SCORE
	clc
	adc #1
	cmp optRaces
	bne rt_x
	ldy #0
@	ldx order,y
	lda carHuman,x
	bne rt_best
	iny
	cpy #NCARS
	bne @-
rt_x	rts
rt_best	lda cTotH,x		; 5 digits
	and #$0F
	sta newBest
	lda cTotM,x
	lsr @
	lsr @
	lsr @
	lsr @
	sta newBest+1
	lda cTotM,x
	and #$0F
	sta newBest+2
	lda cTotL,x
	lsr @
	lsr @
	lsr @
	lsr @
	sta newBest+3
	lda cTotL,x
	and #$0F
	sta newBest+4
	ldx #0			; bigger than the best so far?
@	lda newBest,x
	cmp digs+BEST,x
	bcc rt_x
	bne @+
	inx
	cpx #5
	bne @-
	rts
@	ldx #4
@	lda newBest,x
	sta digs+BEST,x
	dex
	bpl @-
	rts

txtRace	dta d'    RACE 1 OF 4     '
txtResult dta d'       RESULT       '
txtFinal dta d'  CHAMPIONSHIP END  '

; "P1" / "P2" / "AI" for car X at textRes+3,Y (colour of the car)
CarName	lda carHuman,x
	beq cn_ai
	lda #$30		; 'P'
	ora carColBits,x
	sta textRes+3,y
	txa
	clc
	adc #$11		; '1' / '2'
	ora carColBits,x
	sta textRes+4,y
	rts
cn_ai	lda #$21		; 'A'
	ora carColBits,x
	sta textRes+3,y
	lda #$29		; 'I'
	ora carColBits,x
	sta textRes+4,y
	rts

; two BCD digits of A at textRes+6+Y, Y += 2 (colour of car X)
ResBCD	pha
	lsr @
	lsr @
	lsr @
	lsr @
	clc
	adc #$10
	ora carColBits,x
	sta textRes+6,y
	pla
	and #$0F
	clc
	adc #$10
	ora carColBits,x
	sta textRes+7,y
	iny
	iny
	rts

carColBits dta $00,$40,$80	; text colour bits: PF0, PF1, PF2

; ----------------------------------------------------------------------
; The race. Returns C = 1 when ESC was pressed.

RaceGame
	lda #C_OIL		; colour 1 of the track: oil
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
	jsr MiniDraw
	jsr BoostLabels
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
	sta sfxT
	ldx optSpeed		; speed setting
	lda spdStartLo,x
	sta speedStart
	sta baseSpd+1
	lda spdStartHi,x
	sta speedStart+1
	sta baseSpd+2
	lda spdAcc,x
	sta speedAcc
	lda spdMaxLo,x
	sta speedMax
	lda spdMaxHi,x
	sta speedMax+1
	lda #40			; the race starts at once (the 3-2-1-START
	sta cdShow		; screens came before); GO! stays a moment
	lda #$FF
	sta cdStep
	lda #1
	sta started
	lda tenthFrames
	sta tdiv
	lda track		; grid of this track: index track*3+car
	asl @
	adc track
	sta tmp3
	ldx #NCARS-1		; cars on the grid, facing east
@	txa
	clc
	adc tmp3
	tay
	lda gridXLo,y
	sta cPosXL,x
	lda gridXHi,y
	sta cPosXH,x
	lda gridYLo,y
	sta cPosYL,x
	lda gridYHi,y
	sta cPosYH,x
	jsr SetPlaces
	lda #$FF
	sta cRow,x
	jsr FillHistory
	dex
	bpl @-
	lda #1			; booster charge at the start
	sta cBoost
	sta cBoost+1
	sta cBoost+2
	lda #1			; who drives what
	sta carHuman
	lda #0
	sta carHuman+2
	lda optPlayers
	cmp #2
	beq @+
	lda #0
@	sta carHuman+1
	jsr CountText
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
	jsr MiniDots
	jsr RMT_PLAY
	jsr SfxTick
	jsr Collisions
	jsr GetInput
	cmp #$1C		; ESC
	bne @+
	jsr StopAll
	sec
	rts
@	inc frame
	inc tick
	bne @+
	inc tick+1
@	jsr Countdown
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
	jsr BoostTick
	ldx car
	jsr SaveCar
	jsr DriveOff
	jsr History
rg_next	ldx car
	inx
	cpx #NCARS
	bne rg_car
	jsr ChooseTarget
	jsr Respawns
	jsr MiniAhead
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
rg_show	jsr BoostShow
	lda cdShow		; countdown text, or points and laps
	beq @+
	jsr CountText
	jmp rg_fx
@	jsr TextLines
rg_fx
	jsr ColourFx
	jmp rg_loop

; 3-2-1-GO: a beep a step, then the race starts and GO! stays a moment
Countdown
	lda cdStep
	bmi cd_go
	dec cdTimer
	bne cd_x
	lda #COUNT_STEP
	sta cdTimer
	dec cdStep
	bne cd_beep
	lda #1			; GO
	sta started
	lda #40
	sta cdShow
	lda #$FF
	sta cdStep
	lda #1
	jmp SfxStart
cd_beep	lda #0
	jsr SfxStart
cd_x	lda #1
	sta cdShow
	rts
cd_go	lda cdShow
	beq @+
	dec cdShow
	bne @+
	ldx #39			; countdown text gone: clear the lines once
	lda #0
cd_clr	sta textLine,x
	dex
	bpl cd_clr
@	rts

; text lines during the countdown: "GET READY 3" / "GO!", track and race
CountText
	ldx #19
@	lda txtReady,x
	ldy cdStep
	bpl *+5
	lda txtGo,x
	ora #$C0
	sta textLine,x
	lda txtTrack,x
	ora #$C0
	sta textLine+20,x
	dex
	bpl @-
	lda cdStep
	bmi @+
	clc
	adc #$10
	ora #$C0
	sta textLine+15
@	lda track
	clc
	adc #$11
	ora #$C0
	sta textLine+20+7
	lda optLaps
	clc
	adc #$10
	ora #$C0
	sta textLine+20+17
	rts

txtReady dta d'    GET READY  3    '
txtGo	dta d'        GO!         '
txtTrack dta d' TRACK 1    LAPS 3  '

; ----------------------------------------------------------------------
; 3, 2, 1, START: four screens like SpeedMaza's crash screen (shaking,
; flashing colours; FLASH NONE keeps them still), big blocky letters drawn
; into UNBUF (free until the race starts), 48 bytes x 44 lines, mode E

CS_FRAMES = 45			; frames per screen

CountScreens
	jsr HidePM
	lda #<dlCrashSrc
	sta ptr
	lda #>dlCrashSrc
	sta ptr+1
	lda #$3B
	jsr CopyDL
	lda #<UNBUF
	sta DLBUF+$0B
	lda #>UNBUF
	sta DLBUF+$0C
	lda #<DLBUF
	sta DLBUF+$39
	sta SDLSTL
	lda #>DLBUF
	sta DLBUF+$3A
	sta SDLSTL+1
	lda #0
	sta csStep
	sta csN
cs_step	jsr DrawBig
	lda #$22		; picture on
	sta SDMCTL
	ldx #SFX_BEEP
	lda csStep
	cmp #3
	bcc @+
	ldx #SFX_GO
@	txa
	jsr SfxStart
	lda #CS_FRAMES
	sta csT
cs_fr	inc csN
	jsr SfxTick
	lda #1
	jsr Wait
	lda optFx		; FLASH NONE: still picture, steady colours
	bne @+
	sta VSCROL
	sta HSCROL
	lda #4
	sta COLOR0
	lda #8
	sta COLOR0+1
	lda #$0C
	sta COLOR0+2
	lda #0
	sta COLOR0+4
	jmp cs_nx
@	lda RANDOM		; shake
	and #7
	sta VSCROL
	lda RANDOM
	and #7
	sta HSCROL
	lda csN			; colours as the crash screen
	asl @
	asl @
	asl @
	asl @
	and #$E0
	sta tmp
	lda csN
	and #2
	beq cs_b
	lda #4
	ora tmp
	sta COLOR0
	lda #8
	ora tmp
	sta COLOR0+1
	lda #$0E
	ora tmp
	sta COLOR0+2
	lda #0
	sta COLOR0+4
	jmp cs_nx
cs_b	lda #8
	ora tmp
	sta COLOR0
	lda #4
	ora tmp
	sta COLOR0+1
	lda #0
	sta COLOR0+2
	lda #$0E
	ora tmp
	sta COLOR0+4
cs_nx	dec csT
	jne cs_fr
	inc csStep
	lda csStep
	cmp #4
	jne cs_step
	lda #0
	sta COLOR0+4
	sta HSCROL
	sta VSCROL
	jmp StopAll

; the picture of step csStep: "3", "2", "1" (wide letters) or "START"
DrawBig	lda #<UNBUF		; clear 48 x 44 bytes (9 pages)
	sta ptr
	lda #>UNBUF
	sta ptr+1
	ldx #9
	lda #0
	tay
@	sta (ptr),y
	iny
	bne @-
	inc ptr+1
	dex
	bne @-
	ldx csStep
	lda bigText,x		; first glyph in bigSeq, glyph count, byte
	sta dbGlyph		; width of a font pixel, first byte (centred)
	lda bigCount,x
	sta dbCount
	lda bigWide,x
	sta dbWide
	lda bigLeft,x
	sta dbX
db_char	lda #0			; font rows 0..6, 6 lines each
	sta dbRow
db_row	ldx dbGlyph		; row bits (5 columns, bit 4 = left) to the top
	lda bigSeq,x
	sta tmp
	asl @
	asl @
	asl @
	sec
	sbc tmp			; glyph x 7
	clc
	adc dbRow
	tax
	lda bigFont,x
	asl @
	asl @
	asl @
	sta dbBits
	ldx dbRow		; colour of the row: shaded top to bottom
	lda bigShade,x
	sta dbCol
	lda dbX
	sta dbPos
	lda #5
	sta dbColN
db_col	asl dbBits		; C = pixel of this column
	bcc @+
	jsr BigBlock		; fill dbWide bytes x 6 lines
@	lda dbPos
	clc
	adc dbWide
	sta dbPos
	dec dbColN
	bne db_col
	inc dbRow
	lda dbRow
	cmp #7
	bne db_row
	lda dbX			; next letter: 6 columns further
	ldx #6
@	clc
	adc dbWide
	dex
	bne @-
	sta dbX
	inc dbGlyph
	dec dbCount
	bne db_char
	rts

; fill dbWide bytes at byte dbPos, lines dbRow*6+1 .. +6, with dbCol
BigBlock
	lda dbRow		; line = row * 6 + 1
	asl @
	adc dbRow
	asl @
	adc #1
	sta dbLine
	lda #6
	sta dbN
bb_line	lda dbLine		; ptr = UNBUF + line * 48
	sta ptr
	lda #0
	sta ptr+1
	asl ptr
	rol ptr+1
	asl ptr
	rol ptr+1
	asl ptr
	rol ptr+1
	asl ptr
	rol ptr+1		; x 16
	lda ptr
	ldx ptr+1
	asl ptr
	rol ptr+1		; x 32
	clc
	adc ptr
	sta ptr
	txa
	adc ptr+1
	sta ptr+1		; x 48
	clc
	lda ptr
	adc #<UNBUF
	sta ptr
	lda ptr+1
	adc #>UNBUF
	sta ptr+1
	ldy dbPos
	ldx dbWide
	lda dbCol
@	sta (ptr),y
	iny
	dex
	bne @-
	inc dbLine
	dec dbN
	bne bb_line
	rts

; glyphs 5 x 7: 3, 2, 1, S, T, A, R
bigFont	dta %11110,%00001,%00001,%01110,%00001,%00001,%11110	; 3
	dta %01110,%10001,%00001,%00010,%00100,%01000,%11111	; 2
	dta %00100,%01100,%00100,%00100,%00100,%00100,%01110	; 1
	dta %01111,%10000,%10000,%01110,%00001,%00001,%11110	; S
	dta %11111,%00100,%00100,%00100,%00100,%00100,%00100	; T
	dta %01110,%10001,%10001,%11111,%10001,%10001,%10001	; A
	dta %11110,%10001,%10001,%11110,%10100,%10010,%10001	; R
bigShade dta $55,$55,$AA,$AA,$FF,$FF,$FF	; colours 1, 2, 3 down the letters
bigSeq	dta 0, 1, 2, 3,4,5,6,4		; "3" "2" "1" "START"
;		3  2  1  START
bigText	dta 0, 1, 2, 3		; first entry in bigSeq
bigCount dta 1, 1, 1, 5
bigWide	dta 3, 3, 3, 1		; bytes per font pixel
bigLeft	dta 16,16,16,9		; first byte: (48 - width) / 2

; ----------------------------------------------------------------------
; Sound effects on channel 4, written after the music player each frame

SFX_BEEP = 0
SFX_GO	= 1
SFX_WALL = 2
SFX_BUMP = 3
SFX_BACK = 4
SFX_OIL	= 5
SFX_BOOST = 6

; start effect A (a new one replaces the old one)
SfxStart
	tax
	lda sfxF0,x
	sta sfxF
	lda sfxDF0,x
	sta sfxDF
	lda sfxDist0,x
	sta sfxDist
	lda sfxVol0,x
	sta sfxVol
	lda sfxLen0,x
	sta sfxT
	rts

SfxTick	lda sfxT
	beq @+
	dec sfxT
	lda sfxF
	sta AUDF4
	clc
	adc sfxDF
	sta sfxF
	lda sfxDist
	ora sfxVol
	sta AUDC4
	lda sfxT		; fade: volume - 1 every 2 frames
	and #1
	bne @+
	lda sfxVol
	beq @+
	dec sfxVol
@	rts

;		beep  GO    wall  bump  back  oil   boost
sfxF0	dta $50,  $28,  $30,  $A0,  $90,  $04,  $40
sfxDF0	dta 0,    0,    4,    6,    <-5,  0,    <-2
sfxDist0 dta $A0, $A0,  $80,  $A0,  $A0,  $80,  $80
sfxVol0	dta 10,   12,   15,   10,   10,   7,    10
sfxLen0	dta 10,   30,   20,   10,   24,   16,   20

; ----------------------------------------------------------------------
; Tracks: unpack track 'track' to UNBUF, copy its checkpoint tables to
; WORK and rebuild its rows as spans at W_SPANS (with the row pointers)

cpXLo	= WORK
cpXHi	= WORK+MAX_CP
cpYLo	= WORK+2*MAX_CP
cpYHi	= WORK+3*MAX_CP
cpCurve	= WORK+4*MAX_CP		; how sharp the road bends after a checkpoint

LoadTrack
	ldx track
	lda tdSrcLo,x
	sta src
	lda tdSrcHi,x
	sta src+1
	lda #<UNBUF
	sta dstp
	lda #>UNBUF
	sta dstp+1
	clc
	lda #<UNBUF
	adc tdLenLo,x
	sta upEnd
	lda #>UNBUF
	adc tdLenHi,x
	sta upEnd+1
	lda tdBytes,x
	sta mapBytes
	lda tdRowsLo,x
	sta mapRows
	lda tdRowsHi,x
	sta mapRows+1
	lda tdCamXLo,x
	sta camXMax
	lda tdCamXHi,x
	sta camXMax+1
	lda tdCamYLo,x
	sta camYMax
	lda tdCamYHi,x
	sta camYMax+1
	lda tdCp,x
	sta cpCount
	txa			; oil patches of this track
	asl @
	sta tmp
	asl @
	adc tmp			; x6 (OIL_N)
	tay
	ldx #0
@	lda oilRowLo,y
	sta oilRL,x
	lda oilRowHi,y
	sta oilRH,x
	lda oilByte,y
	sta oilB,x
	iny
	inx
	cpx #OIL_N
	bne @-
	jsr Unpack
	ldx #0			; checkpoint tables (5 * MAX_CP bytes) to WORK
@	lda UNBUF,x
	sta WORK,x
	lda UNBUF+$100,x
	sta WORK+$100,x
	lda UNBUF+$200,x
	sta WORK+$200,x
	inx
	bne @-
	; fall through

; rows: count (bit 7: as changes from the row above), then per span the
; first and last pixel, or their changes -> count, first byte, mask, last
; byte, mask (see EnsureRow)
BuildSpans
	lda #<(UNBUF+CP_TABLES)
	sta src
	lda #>(UNBUF+CP_TABLES)
	sta src+1
	lda #<W_SPANS
	sta dstp
	lda #>W_SPANS
	sta dstp+1
	lda #<W_ROWPTR
	sta ptr2
	lda #>W_ROWPTR
	sta ptr2+1
	lda mapRows
	sta row
	lda mapRows+1
	sta row+1
bs_row	ldy #0			; row pointer
	lda dstp
	sta (ptr2),y
	iny
	lda dstp+1
	sta (ptr2),y
	lda #2
	jsr AddPtr2
	jsr GetSrc		; count
	sta tmp2+1
	and #$7F
	sta spans
	jsr PutDst
	ldx #0
bs_span	cpx spans
	jeq bs_next
	lda tmp2+1
	bpl bs_abs
	jsr GetSrc		; x0 += change
	jsr SignExt
	clc
	adc bsX0L,x
	sta bsX0L,x
	lda tmp
	adc bsX0H,x
	sta bsX0H,x
	jsr GetSrc		; x1 += change
	jsr SignExt
	clc
	adc bsX1L,x
	sta bsX1L,x
	lda tmp
	adc bsX1H,x
	sta bsX1H,x
	jmp bs_put
bs_abs	jsr GetSrc
	sta bsX0L,x
	jsr GetSrc
	sta bsX0H,x
	jsr GetSrc
	sta bsX1L,x
	jsr GetSrc
	sta bsX1H,x
bs_put	lda bsX0L,x		; first byte = x0 / 4, mask of x0 & 3
	and #3
	tay
	lda maskL,y
	sta span+1
	lda bsX1L,x
	and #3
	tay
	lda maskR,y
	sta span+3
	lda bsX0H,x
	sta tmp
	lda bsX0L,x
	lsr tmp
	ror @
	lsr tmp
	ror @
	sta span
	lda bsX1H,x
	sta tmp
	lda bsX1L,x
	lsr tmp
	ror @
	lsr tmp
	ror @
	sta span+2
	cmp span		; one byte: both masks together
	bne @+
	lda span+1
	ora span+3
	sta span+1
	sta span+3
@	lda span
	jsr PutDst
	lda span+1
	jsr PutDst
	lda span+2
	jsr PutDst
	lda span+3
	jsr PutDst
	inx
	jmp bs_span
bs_next	lda row
	bne @+
	dec row+1
@	dec row
	lda row
	ora row+1
	jne bs_row
	rts

maskL	dta $00,$C0,$F0,$FC	; clear pixels p..3
maskR	dta $3F,$0F,$03,$00	; clear pixels 0..p

; A = next byte of (src)
GetSrc	ldy #0
	lda (src),y
	inc src
	bne @+
	inc src+1
@	cmp #0			; flags of the byte
	rts
; (dstp) = A, next
PutDst	ldy #0
	sta (dstp),y
	inc dstp
	bne @+
	inc dstp+1
@	rts
AddPtr2	clc
	adc ptr2
	sta ptr2
	bcc @+
	inc ptr2+1
@	rts
; tmp = sign extension of A (A kept)
SignExt	pha
	and #$80
	beq @+
	lda #$FF
@	sta tmp
	pla
	rts

; LZ77 unpack (src) -> (dstp) until upEnd: token < $80: token+1 literal
; bytes follow; token >= $80: copy (token & $7F) + 3 bytes from 2-byte
; offset back
Unpack	lda dstp
	cmp upEnd
	bne @+
	lda dstp+1
	cmp upEnd+1
	bne @+
	rts
@	jsr GetSrc
	bmi up_match
	tax
	inx
@	jsr GetSrc
	jsr PutDst
	dex
	bne @-
	jmp Unpack
up_match
	and #$7F
	clc
	adc #3
	tax
	jsr GetSrc
	sta tmp
	jsr GetSrc
	sta tmp+1
	sec
	lda dstp
	sbc tmp
	sta ptr
	lda dstp+1
	sbc tmp+1
	sta ptr+1
	ldy #0
@	lda (ptr),y
	jsr PutDst
	inc ptr
	bne *+4
	inc ptr+1
	dex
	bne @-
	jmp Unpack

; ----------------------------------------------------------------------
; Minimap in the status bar (instead of the SpeedMaza logo): the track in
; grey, the stretch ahead of the followed car in yellow, the cars as dots
; of their players (moved there by DliGame). Pixel = x / 96 + tdMiniX,
; line = y / 96 + tdMiniY (x in colour clocks, y in scan lines: one scale
; keeps the shape, as a mode E pixel is about as wide as 1.6 lines).

STATUS_LINES = 29
BAR_LINE = 19			; booster bars: lines 19-25
AHEAD	= 10			; checkpoints drawn yellow ahead of the car

; clear the bar, draw the whole track in colour 1
MiniDraw
	lda #<statusBuf
	sta ptr
	lda #>statusBuf
	sta ptr+1
	ldx #>(STATUS_LINES*40+255)
	lda #0
	tay
@	sta (ptr),y
	iny
	bne @-
	inc ptr+1
	dex
	bne @-
	lda #$06		; colours of the bar: grey track, yellow stretch
	sta COLOR0
	lda #$1C
	sta COLOR0+1
	lda #$0E
	sta COLOR0+2
	ldx track
	lda tdMiniX,x
	sta miniX
	lda tdMiniY,x
	sta miniY
	lda #$FF
	sta hiIdx
	lda optMap		; MAP off: no map
	bne @+
	rts
@	lda #$55			; colour 1
	sta miniCol
	lda #0
	sta miniK
@	lda miniK
	jsr MiniCp
	inc miniK
	lda miniK
	cmp cpCount
	bne @-
	rts

; the stretch ahead of the followed car: when its checkpoint changes, the
; old stretch goes back to grey and the new one is drawn yellow
MiniAhead
	lda optMap
	beq ma_x
	ldx target
	lda cIdx,x
	cmp hiIdx
	beq ma_x
	pha
	lda hiIdx
	bmi @+
	ldx #$55
	jsr MiniRange
@	pla
	sta hiIdx
	ldx #$AA		; colour 2
	jmp MiniRange
ma_x	rts

; AHEAD checkpoints from A in colour pattern X
MiniRange
	stx miniCol
	sta miniK
	lda #AHEAD
	sta miniN
@	lda miniK
	jsr MiniCp
	inc miniK
	lda miniK
	cmp cpCount
	bcc *+7
	lda #0
	sta miniK
	dec miniN
	bne @-
	rts

; plot checkpoint A and the point halfway to the next one
MiniCp	tax
	lda cpXLo,x
	sta tmp
	lda cpXHi,x
	sta tmp+1
	lda cpYLo,x
	sta ptr2
	lda cpYHi,x
	sta ptr2+1
	txa
	pha
	jsr MiniXY		; A = pixel, Y = line
	jsr Plot
	pla
	tax
	inx
	cpx cpCount
	bcc *+4
	ldx #0
	clc			; halfway: (a + b) / 2, i.e. the sum / 128 and / 256
	lda cpXLo,x
	adc tmp
	sta tmp
	lda cpXHi,x
	adc tmp+1
	sta tmp+1
	clc			; (y sum / 2) / 96 = (y sum / 64) / 3
	lda cpYLo,x
	adc ptr2
	sta ptr2
	lda cpYHi,x
	adc ptr2+1
	sta ptr2+1
	jsr Div192
	clc
	adc miniY
	tay
	lda tmp			; (x sum / 64) / 3
	sta ptr2
	lda tmp+1
	sta ptr2+1
	jsr Div192
	clc
	adc miniX
	jmp Plot

; A = (ptr2 / 64) / 3  (ptr2 < 16384)
Div192	lda ptr2+1
	sta tmp3
	lda ptr2
	asl @
	rol tmp3
	asl @
	rol tmp3
	ldx tmp3
	lda div3,x
	rts

; tmp = x, ptr2 = y (16 bit) -> A = x / 96 + miniX, Y = y / 96 + miniY
; (tmp kept)
MiniXY	jsr Div96
	clc
	adc miniY
	tay
	lda tmp
	sta tmp3
	lda tmp+1
	sta tmp3+1
	lda ptr2		; keep y, divide x the same way
	pha
	lda ptr2+1
	pha
	lda tmp3
	sta ptr2
	lda tmp3+1
	sta ptr2+1
	jsr Div96
	sta tmp3
	pla
	sta ptr2+1
	pla
	sta ptr2
	lda tmp3
	clc
	adc miniX
	rts

; A = (ptr2 / 32) / 3  (ptr2 < 8192)
Div96	lda ptr2+1
	sta tmp3
	lda ptr2
	asl @
	rol tmp3
	asl @
	rol tmp3
	asl @
	rol tmp3
	ldx tmp3
	lda div3,x
	rts

div3	:128 dta #/3		; (x / 32 and y / 32 stay below 128)

; pixel A of line Y in the status bar = miniCol (mode E)
Plot	cpy #STATUS_LINES
	bcs pl_x
	sta tmp2
	lda #0			; ptr = statusBuf + Y * 40
	sta ptr+1
	tya
	asl @
	asl @
	asl @			; Y * 8 (< 256)
	sta ptr
	asl @
	rol ptr+1
	asl @
	rol ptr+1		; Y * 32
	clc
	adc ptr
	sta ptr
	lda ptr+1
	adc #0
	sta ptr+1
	clc
	lda ptr
	adc #<statusBuf
	sta ptr
	lda ptr+1
	adc #>statusBuf
	sta ptr+1
	lda tmp2
	and #3
	tax
	lda tmp2
	lsr @
	lsr @
	tay
	lda pixMask,x
	eor #$FF
	and (ptr),y
	sta tmp2
	lda pixMask,x
	and miniCol
	ora tmp2
	sta (ptr),y
pl_x	rts

; booster of the human players in the status bar: "P1 BOOST" top left,
; "P2 BOOST" top right, under it a bar of 9 segments (full ones in colour
; 3, which the DLI shades, empty ones grey) and the charge as a number

BoostLabels
	lda #$FF		; bars: draw at the first BoostShow
	sta bdLast
	sta bdLast+1
	lda optBoost
	beq bl_x
	ldx #0
	jsr BoostLabel
	lda carHuman+1
	beq bl_x
	ldx #1
BoostLabel
	lda #$AA		; colour 2 (yellow)
	sta miniCol
	lda boostPx,x
	sta dcPx
	txa			; text: 8 glyphs from boostText + player * 8
	asl @
	asl @
	asl @
	sta dcK
	lda #8
	sta dcN
@	ldx dcK
	lda boostText,x
	ldy #3			; lines 3-16 (each font row twice)
	ldx #2
	jsr DrawChar
	lda dcPx
	clc
	adc #6
	sta dcPx
	inc dcK
	dec dcN
	bne @-
bl_x	rts

BoostShow
	lda optBoost
	beq bs_x
	ldx #0
	jsr BoostOne
	lda carHuman+1
	beq bs_x
	ldx #1
	jmp BoostOne
bs_x	rts

; bar and number of player X, when the charge has changed
BoostOne
	lda cBoost,x
	cmp bdLast,x
	bne @+
	rts
@	sta bdLast,x
	sta bdVal
	stx bdP
	lda #<(statusBuf+BAR_LINE*40)
	sta ptr2
	lda #>(statusBuf+BAR_LINE*40)
	sta ptr2+1
	lda #7			; 7 lines
	sta dcN
bo_line	ldx bdP
	ldy boostByte,x		; 9 segments
	lda #0
	sta dcK
@	lda #$54		; empty: 3 grey pixels
	ldx dcK
	cpx bdVal
	bcs *+4
	lda #$FC		; full: 3 pixels in colour 3
	sta (ptr2),y
	iny
	inc dcK
	lda dcK
	cmp #BOOST_MAX
	bne @-
	lda #0			; clear where the number goes
	iny
	sta (ptr2),y
	iny
	sta (ptr2),y
	clc
	lda ptr2
	adc #40
	sta ptr2
	bcc *+4
	inc ptr2+1
	dec dcN
	bne bo_line
	lda #$AA		; the number
	sta miniCol
	ldx bdP
	lda boostDigit,x
	sta dcPx
	lda bdVal
	ldy #BAR_LINE
	ldx #1
	jmp DrawChar

; glyph A of tinyFont at pixel dcPx, line Y; X = lines per font row (1, 2)
DrawChar
	sta dcG
	sty dcLine
	stx dcScale
	lda #0
	sta dcRow
tc_row	lda dcG			; row bits (bit 4 = left) to the top
	asl @
	asl @
	asl @
	sec
	sbc dcG			; x 7
	clc
	adc dcRow
	tax
	lda tinyFont,x
	asl @
	asl @
	asl @
	sta dcBits
	lda #0
	sta dcCol
tc_col	asl dcBits
	bcc tc_nx
	lda dcScale		; 1 or 2 lines
	sta dcRep
	ldy dcLine
@	lda dcPx
	clc
	adc dcCol
	sty dcY
	jsr Plot
	ldy dcY
	iny
	dec dcRep
	bne @-
tc_nx	inc dcCol
	lda dcCol
	cmp #5
	bne tc_col
	lda dcLine
	clc
	adc dcScale
	sta dcLine
	inc dcRow
	lda dcRow
	cmp #7
	bne tc_row
	rts

;		player 1  player 2
boostPx	dta 4,       112	; label: first pixel
boostByte dta 1,     28		; bar: first byte (pixels 4 / 112)
boostDigit dta 41,   153	; number: first pixel (bytes 10-11 after the bar)
boostText dta 10,1,15,11,12,12,13,14	; "P1 BOOST"
	dta 10,2,15,11,12,12,13,14	; "P2 BOOST"
; 5 x 7 font: 0-9, P, B, O, S, T, space (bit 4 = left column)
tinyFont dta %01110,%10001,%10011,%10101,%11001,%10001,%01110	; 0
	dta %00100,%01100,%00100,%00100,%00100,%00100,%01110	; 1
	dta %01110,%10001,%00001,%00010,%00100,%01000,%11111	; 2
	dta %11110,%00001,%00001,%01110,%00001,%00001,%11110	; 3
	dta %00010,%00110,%01010,%10010,%11111,%00010,%00010	; 4
	dta %11111,%10000,%11110,%00001,%00001,%10001,%01110	; 5
	dta %00110,%01000,%10000,%11110,%10001,%10001,%01110	; 6
	dta %11111,%00001,%00010,%00100,%01000,%01000,%01000	; 7
	dta %01110,%10001,%10001,%01110,%10001,%10001,%01110	; 8
	dta %01110,%10001,%10001,%01111,%00001,%00010,%01100	; 9
	dta %11110,%10001,%10001,%11110,%10000,%10000,%10000	; P
	dta %11110,%10001,%10001,%11110,%10001,%10001,%11110	; B
	dta %01110,%10001,%10001,%10001,%10001,%10001,%01110	; O
	dta %01111,%10000,%10000,%01110,%00001,%00001,%11110	; S
	dta %11111,%00100,%00100,%00100,%00100,%00100,%00100	; T
	dta 0,0,0,0,0,0,0					; space

; each car's dot: one player byte at line y / 128 (PM line (8 + line) / 2)
MiniDots
	lda optMap		; MAP off: no dots
	bne md_on
	sta miniHpos
	sta miniHpos+1
	sta miniHpos+2
	rts
md_on	ldx #NCARS-1
md_car	stx car
	lda cDot,x		; clear the old dot
	beq @+
	jsr DotPtr
	lda #0
	tay
	sta (ptr),y
	ldx car
@	lda #0
	sta cDot,x
	sta mdHpos		; stored once at md_next, as in DrawCars
	lda cFin,x
	bne md_next
	lda cPosXL,x
	sta tmp
	lda cPosXH,x
	sta tmp+1
	lda cPosYL,x
	sta ptr2
	lda cPosYH,x
	sta ptr2+1
	jsr MiniXY
	ldx car
	clc
	adc #$30		; one colour clock per pixel
	sta mdHpos
	tya
	clc
	adc #8
	lsr @
	sta cDot,x
	jsr DotPtr
	lda #$C0
	ldy #0
	sta (ptr),y
md_next	ldx car
	lda mdHpos
	sta miniHpos,x
	dex
	bpl md_car
	rts

; ptr = player X memory at line cDot
DotPtr	lda cDot,x
	sta tmp
	txa
	lsr @
	ror @
	and #$80
	ora tmp
	sta ptr
	txa
	lsr @
	clc
	adc #>PL0
	sta ptr+1
	rts

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
	lda #<statusBuf
	sta (ptr),y
	iny
	lda #>statusBuf
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
@	lda camXMax
	cmp camX
	lda camXMax+1
	sbc camX+1
	bcs @+
	lda camXMax
	sta camX
	lda camXMax+1
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
@	lda camYMax
	cmp camY
	lda camYMax+1
	sbc camY+1
	bcs @+
	lda camYMax
	sta camY
	lda camYMax+1
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
	adc #<W_ROWPTR
	sta src
	lda src+1
	adc #>W_ROWPTR
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
	ldy mapBytes
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
er_x	lda optOil		; oil patches: 2 bytes x 3 rows, road -> colour 1
	beq er_done
	ldx #OIL_N-1
er_oil	sec
	lda row
	sbc oilRL,x
	sta tmp
	lda row+1
	sbc oilRH,x
	bne er_no
	lda tmp
	cmp #3
	bcs er_no
	ldy oilB,x
	lda (dstp),y
	ora #$55
	sta (dstp),y
	iny
	lda (dstp),y
	ora #$55
	sta (dstp),y
er_no	dex
	bpl er_oil
er_done	rts

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
	lda cVis,x		; drawn in the frame before / in this one
	sta cVisPrev,x
	lda #0
	sta cVis,x
	jsr ShownPos
	lda #$FF
	sta cRow,x
	lda #0			; horizontal position: stored once at dc_next
	sta dcHpos		; (DliGame copies carHpos at any moment)
	lda cFin,x
	bne dc_next
	jsr ScreenPos		; tmp = x - camX, tmp2 = y - camY (16 bit)
	bcs dc_next		; off screen
	lda #1
	sta cVis,x
	lda tmp			; hpos = x - camX + $2F - 4
	clc
	adc #$2B
	sta dcHpos
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
	lda dcHpos
	sta carHpos,x
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

; base speed grows with time, as in SpeedMaza, up to speedMax
BaseSpeed
	lda baseSpd+1
	cmp speedMax
	lda baseSpd+2
	sbc speedMax+1
	bcs @+
	clc
	lda baseSpd
	adc speedAcc
	sta baseSpd
	bcc @+
	inc baseSpd+1
	bne @+
	inc baseSpd+2
@	rts

; steering and throttle: joystick for people, AutoSteer for the computer
Control	ldx car
	lda cSpin,x		; spinning on oil: no control
	beq ct_drive
	lda #0
	sta cBoostOn,x
	lda heading
	clc
	adc cSpinD,x
	sta heading
	dec cSpin,x
	bne @+
	lda RANDOM		; out of the spin: a little off the old direction
	and #31
	sec
	sbc #16
	clc
	adc heading
	sta heading
@	rts
ct_drive
	lda carHuman,x
	beq ct_ai
	.if AUTOPILOT = 2	; test: the human car never steers (hits walls)
	rts
	.elseif AUTOPILOT	; test: the human car drives itself
	jmp AutoSteer
	.endif
	jsr HumanBoost
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
ct_ai	jsr AiThrottle
	jsr AiBoost
	jmp AutoSteer

; booster of a human car: on while fire is held and there is charge
HumanBoost
	lda #0
	ldy optBoost
	beq hb_set
	ldy cBoost,x
	beq hb_set
	lda STRIG0,x		; car 0: trigger 1, car 1: trigger 2
	eor #1			; pressed = 1
hb_set	cmp cBoostOn,x
	beq @+
	sta cBoostOn,x
	cmp #1
	bne @+
	lda #SFX_BOOST		; starting to boost
	jsr SfxStart
	ldx car
@	rts

; booster of a computer car: switched on once there is enough charge and
; the road ahead is straight enough (the harder, the sooner and the more
; bent), off again at a sharper bend. Behind a human and off the screen it
; boosts to catch up: with its charge, or free when there is none
; (cBoostOn = 2)
AiBoost	ldx car
	lda optBoost
	beq ab_off
	jsr ScreenPos		; behind a human and off the screen: catch up,
	bcs @+			; and keep going CATCH_ON frames after it is
	lda cCatch,x		; back on the screen
	beq ab_norm
	dec cCatch,x
	jmp ab_cmp
@	lda #CATCH_ON
	sta cCatch,x
ab_cmp	jsr BestHuman		; tmp = best human progress (C = 0: none)
	bcc ab_norm1
	ldx car
	jsr Progress		; ptr2 = this car's progress
	lda ptr2
	cmp tmp
	lda ptr2+1
	sbc tmp+1
	bcs ab_ahead		; not behind
	ldx car
	lda #1			; own charge first ...
	ldy cBoost,x
	bne @+
	lda #2			; ... else a free boost (does not drain)
@	sta cBoostOn,x
	rts
ab_ahead
	ldx car
	lda #0
	sta cCatch,x
	beq ab_norm
ab_norm1
	ldx car
ab_norm	lda cBoostOn,x		; a free boost ends here
	cmp #2
	bne @+
	lda #0
	sta cBoostOn,x
@	ldy cIdx,x		; too sharp a bend ahead (how sharp is too
	lda cpCurve,y		; sharp depends on the difficulty)
	ldy optDiff
	cmp aiBoostBend,y
	bcs ab_off
	lda cBoostOn,x
	bne ab_x		; keep going while charge lasts
	ldy optDiff
	lda cBoost,x
	cmp aiBoostMin,y
	bcc ab_x
	lda #1
	sta cBoostOn,x
ab_x	rts
ab_off	lda #0
	sta cBoostOn,x
	rts

aiBoostMin dta 9,6,2	; easy, normal, hard: charge before a computer car boosts
aiBoostBend dta 20,28,34	; ... and bends it still boosts through (S-bends: ~24-32)

; charge / use the booster of the current car, once a frame
BoostTick
	ldx car
	lda optBoost
	beq bt_x
	inc cBoostT,x
	lda cBoostOn,x
	cmp #1			; only a normal boost uses the charge
	bne bt_fill
	lda cBoostT,x
	cmp #BOOST_USE
	bcc bt_x
	lda #0
	sta cBoostT,x
	dec cBoost,x
	bne bt_x
	sta cBoostOn,x		; empty
bt_x	rts
bt_fill	lda cBoostT,x
	cmp #BOOST_FILL
	bcc bt_x
	lda #0
	sta cBoostT,x
	lda cBoost,x
	cmp #BOOST_MAX
	bcs bt_x
	inc cBoost,x
	rts

; computer throttle = level + car - braking before bends + catching up
; (rubber band: faster when behind the best human, slower when ahead),
; kept within +-THR_MAX
AiThrottle
	ldy optDiff
	lda aiLevel,y
	clc
	adc aiCar,x
	sta tmp2
	ldy cIdx,x		; braking: bend sharpness * aiBrake / 4
	lda cpCurve,y
	sta tmp
	lda #0
	ldy optDiff
	ldx aiBrake,y
@	clc
	adc tmp
	dex
	bne @-
	lsr @
	lsr @
	sta tmp
	sec
	lda tmp2
	sbc tmp
	sta tmp2
	jsr BestHuman		; tmp = best human progress, C = 0: nobody racing
	bcc ai_clamp
	ldx car
	jsr Progress		; ptr2 = progress of this car
	sec
	lda tmp
	sbc ptr2
	sta tmp
	lda tmp+1
	sbc ptr2+1
	bmi ai_ahead
	bne ai_max		; far behind
	lda tmp			; behind by tmp checkpoints: + 2 each
	asl @
	bcs ai_max
	ldy optDiff
	cmp aiBand,y
	bcc ai_add
ai_max	ldy optDiff
	lda aiBand,y
ai_add	clc
	adc tmp2
	sta tmp2
	jmp ai_clamp
ai_ahead
	cmp #$FF		; ahead: - 2 each
	bne ai_min
	lda tmp
	eor #$FF
	clc
	adc #1
	asl @
	bcs ai_min
	ldy optDiff
	cmp aiBand,y
	bcc ai_sub
ai_min	ldy optDiff
	lda aiBand,y
ai_sub	sta tmp
	sec
	lda tmp2
	sbc tmp
	sta tmp2
ai_clamp
	ldx car
	lda tmp2
	bmi @+
	cmp #THR_MAX
	bcc ai_set
	lda #THR_MAX
	bne ai_set
@	cmp #<(-THR_MAX)
	bcs ai_set
	lda #<(-THR_MAX)
ai_set	sta cThr,x
	rts

;		easy  normal hard
aiLevel	dta <-20, 0,    16
aiBrake	dta 4,    3,     2	; x/4 of the bend sharpness
aiBand	dta 32,   20,    12	; most the rubber band adds or takes
aiCar	dta 0,    0,    <-6	; car 2 a little slower than car 1

; ptr2 = laps * checkpoints + checkpoint of car X
Progress
	lda cIdx,x
	sta ptr2
	lda #0
	sta ptr2+1
	ldy cLap,x
	beq pr_x
@	clc
	lda ptr2
	adc cpCount
	sta ptr2
	bcc *+4
	inc ptr2+1
	dey
	bne @-
pr_x	rts

; tmp = best progress of a human car still racing; C = 0 if there is none
BestHuman
	lda #0
	sta tmp
	sta tmp+1
	sta tmp3
	ldx #NCARS-1
bh_car	lda carHuman,x
	beq bh_next
	lda cFin,x
	bne bh_next
	jsr Progress
	lda #1
	sta tmp3
	lda ptr2
	cmp tmp
	lda ptr2+1
	sbc tmp+1
	bcc bh_next
	lda ptr2
	sta tmp
	lda ptr2+1
	sta tmp+1
bh_next	dex
	bpl bh_car
	lda tmp3
	lsr @			; C = 1 when a human is racing
	rts

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
@	lda cBoostOn,x		; booster: speed + 50 % (catching up: + 75 %)
	beq ph_nb
	lda speed+2		; tmp = speed / 2
	lsr @
	sta tmp+1
	lda speed+1
	ror @
	sta tmp
	lda cBoostOn,x
	cmp #2
	bne @+
	lda tmp+1		; + speed / 4
	lsr @
	sta tmp2+1
	lda tmp
	ror @
	clc
	adc tmp
	sta tmp
	lda tmp2+1
	adc tmp+1
	sta tmp+1
@	clc
	lda tmp
	adc speed+1
	sta speed+1
	lda tmp+1
	adc speed+2
	sta speed+2
ph_nb	ldx heading		; target x = speed * cos / 128
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
	sbc speedStart
	sta tmp
	lda speed+2
	sbc speedStart+1
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
	ldx car			; on oil: hardly any grip, and a wobble
	lda cOil,x
	beq ph_f
	dec cOil,x
	lda #GRIP_OIL
	sta grip
	lda RANDOM
	and #7
	bne ph_f
	lda RANDOM
	and #2
	sec
	sbc #1
	clc
	adc heading
	sta heading
ph_f	ldx #0
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
	cmp cpCount
	bcc cp_no
	lda #0
	sta cIdx,x
	inc cLap,x
	lda cLap,x
	cmp optLaps
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

; the camera follows the leading human car still racing (most laps, then
; most checkpoints); when no human is racing any more, the leading car
ChooseTarget
	lda #1
	sta ctHuman
ch_pass	ldx target
	jsr CtValid
	bcs ch_have
	ldx #0			; target not valid: take the first car that is
@	jsr CtValid
	bcs ch_have
	inx
	cpx #NCARS
	bne @-
	lda ctHuman		; no human racing: any car
	beq ch_x
	lda #0
	sta ctHuman
	jmp ch_pass
ch_have	stx target
	ldx #0
ch_cmp	cpx target
	beq ch_nx
	jsr CtValid
	bcc ch_nx
	ldy target
	lda cLap,x
	cmp cLap,y
	bcc ch_nx
	bne ch_new
	lda cIdx,x
	cmp cIdx,y
	bcc ch_nx
	beq ch_nx
ch_new	stx target
ch_nx	inx
	cpx #NCARS
	bne ch_cmp
ch_x	rts

; C = 1 when car X may be followed: racing, and human if ctHuman is set
CtValid	lda cFin,x
	bne @+
	lda ctHuman
	beq cv_yes
	lda carHuman,x
	bne cv_yes
@	clc
	rts
cv_yes	sec
	rts

; a car that fell off the screen comes back just behind the leader, in the
; leader's direction and on the leader's lap: -100 points
Respawns
	ldx #NCARS-1
rp_car	stx car
	cpx target
	jeq rp_next
	lda carHuman,x		; computer cars drive on off the screen
	jeq rp_next
	lda cFin,x
	ora cInv,x		; just came back: give it time
	jne rp_next
	jsr ScreenPos
	jcc rp_next
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
	lda #SFX_BACK
	jsr SfxStart
	ldx car
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
@	lda hitNew		; wait for DliGame to save this frame's registers
	beq @-
	lda #0
	sta hitNew
	lda started
	bne @+
	rts
@	ldx #NCARS-1
co_wall	lda cFin,x
	jne co_next
	lda cInv,x
	beq @+
	dec cInv,x
@	lda hitPF,x		; oil (colour 1): slide for a while
	and #1
	beq co_wl
	lda cOil,x
	bne @+
	lda #SFX_OIL		; new oil: spin round once
	stx car
	jsr SfxStart
	ldx car
	lda #SPIN_TIME
	sta cSpin,x
	sta cStun,x		; half speed while spinning
	lda RANDOM
	and #16
	eor #8			; +8 or -8 ($F8) a frame
	bne *+4
	lda #<-8
	sta cSpinD,x
@	lda #OIL_TIME
	sta cOil,x
co_wl	lda cVisPrev,x		; not on screen then: DriveOff checks walls
	beq co_next
	lda hitPF,x
	and #4
	beq co_safe
	lda cStun,x		; hit a moment ago: already handled
	cmp #STUN_WALL-2
	bcs co_next
	lda #SFX_WALL
	stx car
	jsr SfxStart
	ldx car
	jsr WallHit
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
	jmp Bump

; car X hit a wall: back to its last safe place, bounce, slow down,
; -25 points, turn a little towards the road (X kept)
WallHit	stx car
	lda cSafeXL,x
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
	jsr StepIn		; and a step towards the road
	lda #STUN_WALL
	sta cStun,x
	lda #FLASH
	sta cFlash,x
	lda #<PT_WALL
	ldy #>PT_WALL
	jsr SubPoints
	jsr LoadCar
	jsr TurnSign
	pha
	ldx car
	pla
	beq wh_x
	bmi @+
	lda cHead,x
	clc
	adc #12
	sta cHead,x
	rts
@	lda cHead,x
	sec
	sbc #12
	sta cHead,x
wh_x	rts

; car X: 3 colour clocks and 4 lines towards its next checkpoint (on the
; road), and that becomes its safe place, so a car pressed against a wall
; is walked back onto the track instead of hitting it again and again
StepIn	ldy cIdx,x
	sec
	lda cpXLo,y
	sbc cPosXL,x
	lda cpXHi,y
	sbc cPosXH,x
	bmi @+
	lda #3
	bne si_x
@	lda #<-3
si_x	jsr AddX
	sec
	lda cpYLo,y
	sbc cPosYL,x
	lda cpYHi,y
	sbc cPosYH,x
	bmi @+
	lda #4
	bne si_y
@	lda #<-4
si_y	jsr AddY
	lda cPosXL,x
	sta cSafeXL,x
	lda cPosXH,x
	sta cSafeXH,x
	lda cPosYL,x
	sta cSafeYL,x
	lda cPosYH,x
	sta cSafeYH,x
	rts
; car X position += A (signed)
AddX	sta tmp
	jsr ExtA
	clc
	lda cPosXL,x
	adc tmp
	sta cPosXL,x
	lda cPosXH,x
	adc tmp+1
	sta cPosXH,x
	rts
AddY	sta tmp
	jsr ExtA
	clc
	lda cPosYL,x
	adc tmp
	sta cPosYL,x
	lda cPosYH,x
	adc tmp+1
	sta cPosYH,x
	rts

; a car off the screen has no collision registers: check its centre
; against the track rows and bounce it off walls in the same way
DriveOff
	ldx car
	jsr ScreenPos
	bcc do_x		; on screen: the hardware sees it
	lda cStun,x		; hit a moment ago: already handled
	cmp #STUN_WALL-2
	bcs do_x
	jsr OnRoad
	ldx car
	bcc @+
	lda cPosXL,x		; on the road: safe
	sta cSafeXL,x
	lda cPosXH,x
	sta cSafeXH,x
	lda cPosYL,x
	sta cSafeYL,x
	lda cPosYH,x
	sta cSafeYH,x
do_x	rts
@	jmp WallHit

; C = 1 when the centre of the current car (posX, posY) is on the road,
; looked up in the span rows of the track (W_ROWPTR, W_SPANS)
OnRoad	lda posY+2		; row = y / 8
	sta tmp+1
	lda posY+1
	lsr tmp+1
	ror @
	lsr tmp+1
	ror @
	lsr tmp+1
	ror @
	asl @			; x2: row pointer
	rol tmp+1
	clc
	adc #<W_ROWPTR
	sta src
	lda tmp+1
	adc #>W_ROWPTR
	sta src+1
	ldy #0
	lda (src),y
	tax
	iny
	lda (src),y
	sta src+1
	stx src
	lda posX+2		; byte = x / 16, pixel = x / 4 & 3
	sta tmp+1
	lda posX+1
	lsr tmp+1
	ror @
	lsr tmp+1
	ror @
	tax
	and #3
	tay
	lda pixMask,y
	sta span+1
	txa
	lsr tmp+1
	ror @
	lsr tmp+1
	ror @
	sta span		; byte
	ldy #0
	lda (src),y		; spans in the row
	beq or_no
	sta tmp
	iny
or_span	lda span		; first byte <= byte <= last byte?
	cmp (src),y
	bcc or_next
	iny
	iny
	lda (src),y		; C = last byte >= byte (dey keeps C)
	cmp span
	dey
	dey
	bcc or_next
	lda span		; on the first byte: its pixel must be road
	cmp (src),y
	bne @+
	iny
	lda (src),y
	dey
	and span+1
	bne or_next
@	iny			; on the last byte: likewise
	iny
	lda span
	cmp (src),y
	bne or_yes
	iny
	lda (src),y
	and span+1
	bne or_next3
or_yes	sec
	rts
or_next3
	dey
	dey
	dey
	jmp or_next
or_next	iny			; next span (4 bytes)
	iny
	iny
	iny
	dec tmp
	bne or_span
or_no	clc
	rts

pixMask	dta $C0,$30,$0C,$03

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
	stx tmp2
	sty tmp2+1
	lda #SFX_BUMP
	jsr SfxStart
	ldx tmp2
	ldy tmp2+1
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
	ldx optFx		; FLASH setting
	bne @+
	lda #$14		; none: steady walls, no flashes
	sta dliColPF2
	lda #0
	sta dliColBK
	sta COLOR0+3
	rts
@	lda tick		; the time the effects go by
	sta fxTick
	lda tick+1
	sta fxTick+1
	cpx #1
	bne @+
	lda #<FX3		; soft: at most the pulsing of stage 3
	cmp fxTick
	lda #>FX3
	sbc fxTick+1
	bcs cf_t
	lda #<FX3
	sta fxTick
	lda #>FX3
	sta fxTick+1
	jmp cf_t
@	cpx #3
	bne cf_t
	ldx #2			; hard: four times sooner
@	asl fxTick
	rol fxTick+1
	bcc cf_sh
	lda #$FF
	sta fxTick
	sta fxTick+1
cf_sh	dex
	bne @-
cf_t	lda RMT_VOL
	and #$0F
	sta tmp
	lda #<FX5
	cmp fxTick
	lda #>FX5
	sbc fxTick+1
	bcs cf_4
	lda tick
	and #6
	tax
	jmp cf_flash
cf_4	lda #<FX4
	cmp fxTick
	lda #>FX4
	sbc fxTick+1
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
	cmp fxTick
	lda #>FX3
	sbc fxTick+1
	bcs cf_2
	lda #$10
	ora tmp
	sta dliColPF2
	rts
cf_2	lda #<FX2
	cmp fxTick
	lda #>FX2
	sbc fxTick+1
	bcs cf_1
	lda tmp
	lsr @
	clc
	adc #2
	ora #$10
	sta dliColPF2
	rts
cf_1	lda #<FX1
	cmp fxTick
	lda #>FX1
	sbc fxTick+1
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

; ---- tables (loaded with the program)
	icl 'gen/tables.asm'
	icl 'gen/speedmaza_data.asm'
tracksHigh			; packed tracks that did not fit at LOW_AREA
	ins 'data/tracks_high.bin'
TablesEnd
; status bar picture: 29 x 40 bytes, mode E, one LMS: must not cross 4K
statusBuf .ds 5*256		; (cleared in whole pages)
	.if (statusBuf^(statusBuf+29*40-1))&$F000
	.error "status bar crosses a 4K boundary"
	.endif

; ---- variables (cleared at start)
TIME	= 0
BEST	= 5
VarsStart
digs	.ds 10			; race time digits, best score digits
tenthFrames .ds 1
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
optSel	.ds 1
optPage	.ds 1			; 0 main, 1 more options
dmLine	.ds 1
dmItem	.ds 1
colL	.ds 1
colV	.ds 1
raceNo	.ds 1
track	.ds 1
tmp3	.ds 2
dcHpos	.ds 1			; DrawCars / MiniDots: position being worked out
mdHpos	.ds 1
csStep	.ds 1			; 3-2-1-START screens
csN	.ds 1
csT	.ds 1
dbGlyph	.ds 1			; DrawBig
dbCount	.ds 1
dbWide	.ds 1
dbX	.ds 1
dbRow	.ds 1
dbBits	.ds 1
dbCol	.ds 1
dbPos	.ds 1
dbColN	.ds 1
dbLine	.ds 1
dbN	.ds 1
hitNew	.ds 1			; DliGame saved new collision registers
miniX	.ds 1			; minimap offsets of the track
miniY	.ds 1
miniCol	.ds 1
miniK	.ds 1
miniN	.ds 1
hiIdx	.ds 1			; start of the yellow stretch ($FF = none)
bdLast	.ds 2			; booster charge last drawn, per player
bdP	.ds 1
bdVal	.ds 1			; charge being drawn
dcPx	.ds 1			; DrawChar / labels
dcG	.ds 1
dcLine	.ds 1
dcScale	.ds 1
dcRow	.ds 1
dcBits	.ds 1
dcCol	.ds 1
dcRep	.ds 1
dcY	.ds 1
dcK	.ds 1
dcN	.ds 1
fxTick	.ds 2
ctHuman	.ds 1
cdStep	.ds 1
cdTimer	.ds 1
cdShow	.ds 1
sfxF	.ds 1
sfxDF	.ds 1
sfxDist	.ds 1
sfxVol	.ds 1
sfxT	.ds 1
VarsEnd
optVal	.ds OPTS
optRaces .ds 1			; races per game: always 1
newBest	.ds 5
cTotL	.ds NCARS		; championship points, BCD (must stay together)
cTotM	.ds NCARS
cTotH	.ds NCARS
upEnd	.ds 2
mapBytes .ds 1			; the loaded track
mapRows	.ds 2
camXMax	.ds 2
camYMax	.ds 2
cpCount	.ds 1
oilRL	.ds OIL_N
oilRH	.ds OIL_N
oilB	.ds OIL_N
bsX0L	.ds 16			; BuildSpans: the spans of the row above
bsX0H	.ds 16
bsX1L	.ds 16
bsX1H	.ds 16
speedStart .ds 2		; the speed setting
speedAcc .ds 1
speedMax .ds 2
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
cOil	.ds NCARS		; frames left sliding on oil
cSpin	.ds NCARS		; frames left spinning
cSpinD	.ds NCARS		; ... heading change a frame
cBoost	.ds NCARS		; booster charge 0..9
cBoostT	.ds NCARS		; frames towards the next charge step
cBoostOn .ds NCARS		; boosting (2: free, catching up)
cCatch	.ds NCARS		; frames of catching up left once on the screen
cScLo	.ds NCARS		; points of this race, BCD
cScHi	.ds NCARS
cSafeXL	.ds NCARS		; last place without a wall hit
cSafeXH	.ds NCARS
cSafeYL	.ds NCARS
cSafeYH	.ds NCARS
cRow	.ds NCARS		; PM line of the car picture ($FF = none)
cDot	.ds NCARS		; PM line of the minimap dot (0 = none)
carHpos	.ds NCARS		; horizontal positions: on the track ...
miniHpos .ds NCARS		; ... and on the minimap (set by DliGame)
cVis	.ds NCARS		; drawn in this frame
cVisPrev .ds NCARS		; drawn in the frame before
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
VarsEnd2
dliColPF0 = $03E8		; same shadows as SpeedMaza
dliColPF1 = $03E9
dliColPF2 = $03EA
dliColBK  = $03EB

; ======================================================================
	.if VarsEnd2 > $BC00
	.error "program too big"
	.endif

; ---- buffers in the OS text screen memory ($BC00-$BFFF, unused once the
; game runs; nothing is loaded here)
	org $BC00
TextBufs
textLine .ds 40
menuText .ds MENU_LINES*20
textHi	.ds 40
textRes	.ds 80
TextEnd
hX	.ds NCARS*16
hY	.ds NCARS*16
hHead	.ds NCARS*16
slotRow	.ds RING_ROWS*2
	.if * > $C000
	.error "buffers above $C000"
	.endif

	org $48DF
	ins 'data/rmt_player.bin'
	org MUSIC_TITLE
	ins 'data/music.bin'
	org LOW_TEMP			; moved to LOW_AREA by MoveLow at start
	ins 'data/tracks_low.bin'

	run Start
