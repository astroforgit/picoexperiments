"""Manually established entry points; neutral labels are retained elsewhere."""
KULT_NAMES={0x7fee:'ResetSoundAndEnter',0xc000:'MenuEntry',0xc0ee:'MenuSetup',0xc126:'MenuLoop',0xc309:'InitializeDisplay',0xc362:'FadeToBlack',0xc390:'FadeToPalette',0xc3dd:'WaitTwoFrames',0xc5a0:'PrintDoubleWidth'}
KULT_SEEDS=[0x7fee,0xc000,0xc281,0xc271,0xc2c3]
KULT_COMMENTS={0x7fee:'Clear nine POKEY registers, set SKCTL=3, enter menu at $C000.',0xc003:'ANTIC display-list bytes (not 6502 instructions).',0xc126:'Menu polling loop: TRIG0 is checked at $C140.',0x300:'Additional runtime helper loaded by the first packed stream.',0xc800:'2048-byte character/graphics bank.'}
CETAS_NAMES={0x2000:'NmiHandler',0x201d:'VerticalBlank',0x205e:'ReadJoystick',0x20ab:'MusicTick',0x22ac:'GameEntry',0x235d:'MainLoop',0x237c:'UpdateObjects',0x23a2:'DispatchObject',0x1400:'MusicInit',0x1403:'MusicUpdate',0x1409:'MusicStop',0x140f:'MusicCommand'}
CETAS_SEEDS=[0x22ac,0x2000,0x1400,0x1403,0x1409,0x140f]
CETAS_COMMENTS={0x2000:'NMIST bit 7 distinguishes display-list and vertical-blank interrupts.',0x205e:'PORTA bits 0..3 are inverted and shifted into $9B-$9E.',0x20ab:'Music update called once per vertical blank.',0x1182:'Music frequency/envelope tables precede the player at $1400.'}
INTRO_NAMES={0xcd2:'IntroNmi',0xcde:'IntroVblank',0xd19:'WaitFrame',0xd20:'LoadA',0xd3f:'LoadB',0xd5b:'LoadC',0xd77:'LoadD',0xd93:'StartSlideshow',0xe83:'CopyFontUnderRom',0xecd:'CopyPicture',0x1400:'MusicInit',0x1403:'MusicUpdate',0x1409:'MusicStop'}
INTRO_SEEDS=[0xd20,0xd3f,0xd5b,0xd77,0xd93,0xe83,0xcd2,0x1400,0x1403,0x1409]
INTRO_COMMENTS={0xd20:'Load A/B/C/D through resident disk loader $0806; each continuation replaces RUNAD.',0xe83:'Copy 26 pages from $A010 to $E010 with OS ROM disabled, then load file E.\nResource F supplies 6480 bytes; the copy also reads 176 bytes beyond it.',0xecd:'Copy a 40-byte-wide, 192-line bitmap to $8010, column by column.'}
# Object dispatch at $23AB reads little-endian pointers at $2DF5+2*type.
CETAS_SEEDS += [0x24fb,0x2b23,0x2475,0x23c8,0x2e7d,0x2f79,0x255a,0x29d4,0x280c,0x2948,0x286c,0x27ac,0x26cf,0x2668,0x2580,0x26f2,0x2770]
for index,address in enumerate([0x24fb,0x2b23,0x2475,0x2475,0x23c8,0x2e7d,0x2f79,0x255a,0x29d4,0x280c,0x2948,0x286c,0x27ac,0x26cf,0x2668,0x2580,0x26f2,0x2770],1):
    CETAS_NAMES.setdefault(address,'ObjectType%02d'%index)
CETAS_NAMES[0x2df5]='ObjectHandlerTable'
CETAS_COMMENTS[0x23b7]='Self-modified JSR: operand comes from ObjectHandlerTable[type].'
KULT_NAMES.update({0xc281:'NmiDispatch',0xc271:'IrqHandler',0xc2c3:'MenuVblank',0xc41b:'SelectMenuDisplay'})
KULT_SEEDS += [0xc35f,0xc581,0xea73]
KULT_NAMES.update({0xc35f:'EmptyVblank',0xc581:'MenuDli',0xea73:'GameDli',0xf6e1:'InitializeGame',0xf7c2:'GameLoop',0xe487:'MusicTick'})
KULT_COMMENTS[0xf6e1]='Clear $7600-$BFFF, reset sound/state, install display and enter GameLoop.'
CETAS_NAMES.update({0x24fb:'PlayerUpdate',0x2eb5:'FireProjectile',0xabe1:'UpdateSpawnScript'})
CETAS_COMMENTS[0x24fb]='Player handler: fire from $9A, movement from $9B-$9E; object slot 0.'
CETAS_COMMENTS[0xabe1]='Timed object-spawn bytecode interpreter. $AF/$B0 is the script cursor; $FF/$FE/$FD change delay and loop state, $FA patches a JSR.'
INTRO_NAMES[0xe83]='CopyGraphicsUnderRom'
