all: bin/hans-kloss.xex

side_a/HK_NAME_MOD.FNT side_a/HK_TITLE_NAME.DTA side_a/HK_TITLE_CREDIT.DTA: side_a/HK_NAME.FNT util/title-name-to-data.js
	node util/title-name-to-data.js side_a/HK_NAME.FNT side_a/HK_NAME_MOD.FNT side_a/HK_TITLE_NAME.DTA side_a/HK_TITLE_CREDIT.DTA

side_a/HK_TITL_MOD.FNT side_a/HK_TITLE_IMAGE.DTA: util/hans-rzygol-title-image\ (1).json side_a/HK_TITL.FNT util/title-json-to-data.js
	node util/title-json-to-data.js "util/hans-rzygol-title-image (1).json" side_a/HK_TITL.FNT side_a/HK_TITL_MOD.FNT side_a/HK_TITLE_IMAGE.DTA

side_a/HK_MAIN_MOD.FNT: side_a/HK_MAIN.FNT util/heart-font.js
	node util/heart-font.js side_a/HK_MAIN.FNT side_a/HK_MAIN_MOD.FNT

side_a/HK_PISS.DTA: util/hans-kloss-piss-sprite.json util/piss-json-to-data.js
	node util/piss-json-to-data.js util/hans-kloss-piss-sprite.json side_a/HK_PISS.DTA

side_a/HK_MAIN.OBJ: side_a/HK_MAIN.ASM side_a/HK_PROC.ASM side_a/HK_PLAY.ASM side_a/HK_PISS.DTA side_a/HK_TITLE_NAME.DTA side_a/HK_TITLE_CREDIT.DTA side_a/HK_TITLE_IMAGE.DTA
	mads side_a/HK_MAIN.ASM -o:side_a/HK_MAIN.OBJ

side_b/HK_MAIN.XEX: side_a/HK_MAIN.OBJ util/protect.js
	node util/protect.js < side_a/HK_MAIN.OBJ > side_b/HK_MAIN.XEX

side_a/HK_LOAD.OBJ: side_a/HK_LOAD.ASM
	mads side_a/HK_LOAD.ASM -o:side_a/HK_LOAD.OBJ
	
bin/hans-kloss.xex: main.asm side_a/HK_INIT.ASM side_a/HK_LOAD.FNT side_a/HK_LOAD.OBJ side_a/HK_MAIN_MOD.FNT side_a/HK_TITL_MOD.FNT side_a/HK_FINI.FNT side_a/HK_GOTH.FNT side_a/HK_PLAN.FNT side_a/HK_NAME_MOD.FNT side_a/HK_WALK.PLR side_a/HK_JUMP.PLR side_a/HK_STAT.STA side_a/HK_PLAY.AMC side_a/HK_CAVE.DTA side_b/HK_MAIN.XEX
	mads main.asm -o:bin/hans-kloss.xex

side_b/HK_GAME.XEX: bin/hans-kloss.xex
	cp bin/hans-kloss.xex side_b/HK_GAME.XEX

side_b/HK_INIT.OBJ: side_a/HK_INIT.ASM
	mads side_a/HK_INIT.ASM -o:side_b/HK_INIT.OBJ

side_b/HK_LOAD.OBJ: side_a/HK_LOAD.ASM
	mads side_a/HK_LOAD.ASM -o:side_b/HK_LOAD.OBJ

clean:
	rm side_a/*.OBJ side_a/HK_PISS.DTA side_a/HK_NAME_MOD.FNT side_a/HK_TITLE_NAME.DTA side_a/HK_TITLE_CREDIT.DTA side_a/HK_TITL_MOD.FNT side_a/HK_TITLE_IMAGE.DTA side_a/HK_MAIN_MOD.FNT side_b/*.OBJ side_b/*.XEX bin/*.xex

test: side_b/HK_GAME.XEX side_b/HK_INIT.OBJ side_b/HK_LOAD.OBJ side_b/HK_MAIN.XEX checksum.md5
	md5sum --check checksum.md5
