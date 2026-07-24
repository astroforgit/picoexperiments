pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- a puzzle rougelike game
-- for my awesome brother

-- still not how i really want, but now it has some levels of polish at least!

p1x,p1y=64,88
lastpx=p1x
lastpy=p1y
itemposx=p1x
itemposy=p1y

p1spr,hp,swordspr,cursorpos=224,2,21,97

coins,bombupg,piercing,attack,nrbombs,nrarrows,cursorloc,direction =1,1,1,1,1,1,1,1
attackreduction,enemieswalked,room,steps,switchtrap,moveenemies,keys,p1tile=0,0,0,0,0,0,0,0
attacking,hasbeenhit,checkmove,createdust,canmove=false,false,false,false,false,true

pre_made_levels={
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,1,1,0,0,1,1,1,0,0,0,0,0,1,1,0,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,1,1,1,0,0,0,0,1,1,1,1,1,1,1,0,0,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,1,0,0,0,0,0,1,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,1,0,0,0,0,0,0,0,1,1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,1,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,1,1,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,1,0,0,1,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,1,0,0,0,0,1,0,0,1,0,0,0,0,1,0,0,0,1,1,1,1,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1,0,0,1,1,0,1,1,0,0,0,0,1,0,0,0,1,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,1,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0,1,1,0,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,1,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1,1,1,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,1,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,1,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,0,0,1,1,0,1,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1,1,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,1,0,1,0,0,0,1,1,1,1,0,0,0,0,0,1,1,0,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,0,1,1,1,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,1,0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,1,1,0,0,0,0,0,1,0,0,0,0,1,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,0,1,0,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,1,0,1,0,0,1,1,1,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0",
	"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
}

function shuffle(tbl)
	for i=#tbl,2,-1 do
		local j = 1+flr(rnd(i))
		tbl[i],tbl[j] = tbl[j],tbl[i]
	end
	return tbl
end

function playerupdate()
	if hp >= 0 and room < boss+1 then
		lastpx = p1x
		lastpy = p1y
		playermovement()
		playercollidewithitems()
		interactplayer()
	end
end

function playermovement()
if canmove then
	if btnp(0) then--walk
		if p1spr == 228 then
			if fget(mget(p1x/8 -1,p1y/8))~=2 then
				p1x-=8--left
				createdust = true
			end
		else
			p1spr=228
			attacking = false
		end
	elseif btnp(1) then
		if p1spr == 230 then
			if fget(mget(p1x/8 +1,p1y/8))~=2 then
				p1x+=8--right
				createdust = true
			end
		else
			p1spr=230
			attacking = false
		end
	elseif btnp(2) then
		if p1spr == 224 then
			if fget(mget(p1x/8,p1y/8 -1))~=2 then
				p1y-=8--up
				createdust = true
			end
		else
			p1spr=224
			attacking = false
		end
	elseif btnp(3) then
		if p1spr == 226 then
			if fget(mget(p1x/8,p1y/8 +1))~=2 then
				p1y+=8--down
				createdust = true
			end
		else 
			p1spr=226
			attacking = false
		end
	end
	if createdust then
		infostep()
		sfx(8)
		createdust = false
		initparticle(p1x+4,p1y+4,0,0,2,7,12)
	end
end
	checkstep()
	getitemdir()
end

function checkstep()
	if steps >= 1 then	
		steps = 0
		for e in all(enemies) do
			e.move = true 
			e.steps = e.stepc
		end

		for b in all(bombs) do
			b.sp = b.sp == 36 and 37 or 36
			b.dur-=1
		end

		for t in all(towers) do 
			if t.rotate then
				if t.dir == 1 then
					t.dir = 3
				elseif t.dir == 2 then
					t.dir = 4
				elseif t.dir == 3 then
					t.dir = 2
				elseif t.dir == 4 then
					t.dir = 1
				end 
				t.sp = 111 + t.dir + t.noenemies
			end
			t.shoot = true
		end 

		for x in all(explosions) do x.dur-=1 end

		switchtrap+=1
		if switchtrap == 2 then
			switchtrap=0
			for i=2,14 do
				for j=2,14 do
					if fget(mget(i,j)) == 32 then
						mset(i,j,7)
					elseif fget(mget(i,j)) == 128 then
						mset(i,j,8)
					end
				end
			end
		end
	end

	if #enemies > 0 then --only move if all enemies has moved
		for e in all(enemies) do
			checkmove = e.move == false and true or false
		end
		if checkmove then
			checkmove = false
			canmove = true
		end
	else
		canmove = true
	end
end

function infostep()
	steps+=1
	attacking=false
	canmove=false
	hasbeenhit=false
end

function movebackplayer()
	p1x = lastpx
	p1y = lastpy
end

function resetroom()
	shop=false
	room+=1
	
	vgnt.mode="close"
	movebackplayer()
end

function nextlevel()
	clearmap()
	initfloattext("advanced to room "..room.."!",28,50,1,0.1,9,10,100)
	sfx(2)
	initenemypos()
	makeroom()
	keys=0
	getrightdirdoor()
	for i=0,50 do initparticle(rnd(128),rnd(128),0,rnd(2),1,7,12) end
	shake=0.1
end

function playercollidewithitems()
	if fget(mget(p1x/8,p1y/8)) == 1 then
		if keys >= 1 then
			resetroom()
		else
			movebackplayer()
		end	
	end

	if p1x <= 0 or p1x >= 120 or p1y <= 0 or p1y >= 120 then
		resetroom()
	end

	if fget(mget(p1x/8,p1y/8)) == 4 then --hp
		if (hp < 5)hp+=1
		sfx(15)
		initfloattext("hp",12,115,1,-0.2,8,7,40)
		for i=0,3 do initparticle(p1x+rnd(4),p1y+rnd(4),rnd(2)-1,rnd(2)-1,2,8,8) end
		mset(p1x/8,p1y/8,floorsprite)
	end

	if fget(mget(p1x/8,p1y/8)) == 8 then --item
		getitem=flr(rnd(3))+1
		for i=0,4 do initparticle(87+i*9,121,0,-rnd(1),2,2,14) end
		for i=0,3 do initparticle(p1x+rnd(4),p1y+rnd(4),rnd(2)-1,rnd(2)-1,2,3,11) end
		sfx(1)
		shake=0.05
		
		if getitem == 1 then
			if(attack < 6)attack+=1
			initfloattext("+trident",97,115,1,-0.2,9,10,40)
			init_pick_up(241,p1x,p1y,98,122)
		elseif getitem ==2 then
			if(nrbombs < 6)nrbombs+=1
			initfloattext("+bomb",97,115,1,-0.2,9,10,40)
			init_pick_up(243,p1x,p1y,108,122)
		else
			if(nrarrows < 6)nrarrows+=1
			initfloattext("+arrow",97,115,1,-0.2,9,10,40)
			init_pick_up(242,p1x,p1y,118,122)
		end
		mset(p1x/8,p1y/8,floorsprite)
	end

	if fget(mget(p1x/8,p1y/8)) == 16 then --coin
		coins+=1
		init_pick_up(41,p1x,p1y,28,0)
		initfloattext("+1",30,8,2,0.2,7,9,50)
		sfx(14)
		mset(p1x/8,p1y/8,floorsprite)
		for i=0,3 do 
			initparticle(p1x+rnd(4),p1y+rnd(4),rnd(2)-1,rnd(2)-1,1,10,7)
			initparticle(100+i*8,4,0,rnd(1),1,10,7)
		end
	end

	if fget(mget(p1x/8,p1y/8)) == 64 then -- key
		for i=0,3 do initparticle(p1x+rnd(4),p1y+rnd(4),0,-rnd(2),2,10,10) end
		initfloattext("key",20,8,2,-0.2,9,4,50)
		sfx(6)
		shake=0.05
		keys+=1
		init_pick_up(57,p1x,p1y,20,0)
		if room == 0 then
			initfloattext(badstory[flr(rnd(#badstory-1)+1)],5,80,1,-0.1,9,10,120)
		end
		mset(p1x/8,p1y/8,floorsprite)
	end
	if fget(mget(p1x/8,p1y/8)) == 32 then -- trap
		if not attacking then
			hp-=1
			sfx(10)
			initfloattext(-1,p1x,p1y,1,-0.3,11,3,40)
			shake=0.15
			for i=0,3 do initparticle(p1x+rnd(4),p1y+rnd(4),rnd(2)-1,rnd(2)-1,2,8,2) end
			mset(p1x/8,p1y/8,7)
		else
			mset(p1x/8,p1y/8,floorsprite)
			shake=0.15
		end
	end
end

function interactplayer()
	if not shop then
		if btnp(4) then
			if cursorloc == 1 and attack > 0 and not attacking then
				if p1spr == 228 then 
					if(fget(mget(p1x/8 -1,p1y/8))==0)p1x-=8--left
				elseif p1spr == 230 then
					if(fget(mget(p1x/8 +1,p1y/8))==0)p1x+=8--right
				elseif p1spr == 224 then
					if(fget(mget(p1x/8,p1y/8 -1))==0)p1y-=8 --up
				elseif p1spr == 226 then
					if(fget(mget(p1x/8,p1y/8 +1))==0)p1y+=8--down
				end
				sfx(13)
				attacking=true
				if(room > 0)attack-=1-attackreduction
				for i=0,1 do initparticle(p1x,p1y,rnd(2)-1,rnd(2)-1,3,7,6) end
				shake=0.075
			elseif cursorloc == 2 and nrbombs > 0 then
				for i=0,1 do initparticle(107+rnd(6),120,0,-rnd(1),1,10,9) end
				attacking=false
				sfx(0)
				if(room > 0)nrbombs-=1
				shake=0.06
				initbombs(itemposx,itemposy,36)
			elseif cursorloc == 3 and nrarrows > 0 then
				for i=0,1 do initparticle(117+rnd(6),120,0,-rnd(1),1,10,9) end
				attacking=false
				sfx(3)
				if(room > 0)nrarrows-=1
				shake=0.08
				initarrow(itemposx,itemposy,direction,true)
				for i=0,2 do initparticle(p1x,p1y,rnd(2)-1,rnd(2)-1,3,10,9) end
			end
		end

		if btnp(5) then
			sfx(7)
			if cursorloc < 3 then
				cursorloc+=1
				cursorpos+=10 
			else 
				cursorloc=1
				cursorpos=97
			end
		end
	end
end

function load_room(room_str)
	local the_room=split(room_str)
	local m_x=0
	local m_y=0
	for i=1,#the_room do
		if the_room[i] == 1  then
			mset(m_x,m_y,walls+16)
		end
		if m_x < 15 then
			m_x+=1
		else
			m_x=0
			m_y+=1
		end
	end
end

function getitemdir()
	if p1spr == 228 then 
		itemposx=p1x-8
		itemposy=p1y
		swordspr=24
		direction=1
	elseif p1spr == 230 then
		itemposx=p1x+8
		itemposy=p1y
		swordspr=23
		direction=2
	elseif p1spr == 224 then
		itemposx=p1x
		itemposy=p1y-8
		swordspr=21
		direction=3
	elseif p1spr == 226 then
		itemposx=p1x
		itemposy=p1y+8
		swordspr=22
		direction=4
	end
 end

 function getrightdirdoor()
 	if p1spr == 228 then 
		p1spr = 230
	elseif p1spr == 230 then
		p1spr = 228
	elseif p1spr == 226 then
		p1spr = 224
	elseif p1spr == 224 then
		p1spr = 226
	end
 end

shop,boss,shopgoal,watereffect = false,21,(3+flr(rnd(5))), false
function makeroom()			
	dooramount=flr(rnd(3))+1
	doorplaced = dooramount
	while doorplaced > 0 do
		wheretoplacedoor=flr(rnd(4))+1
		if wheretoplacedoor == 1 and p1y/8 > 1 then--up
			if fget(mget(8,0)) ~= 1 then
				mset(8,0,3)
				mset(7,0,3)
				doorplaced-=1
			end
		elseif wheretoplacedoor == 2 and p1y/8 <14 then--down
			if fget(mget(8,15)) ~= 1 then
				mset(8,15,3)
				mset(7,15,3)
				doorplaced-=1
			end
		elseif wheretoplacedoor == 3 and p1x/8 <14 then--right
			if fget(mget(15,8)) ~= 1 then
				mset(15,8,3)
				mset(15,7,3)
				doorplaced-=1
			end
		elseif wheretoplacedoor == 4 and p1x/8 > 1 then--left
			if fget(mget(0,8)) ~= 1 then
				mset(0,8,3)
				mset(0,7,3)
				doorplaced-=1
			end
		end
	end

	--place a locked door
	if p1y/8 == 1 then
		mset(8,0,33)
		mset(7,0,33)
	elseif p1y/8 == 14 then
		mset(8,15,33)
		mset(7,15,33)
	elseif p1x/8 == 1 then
		mset(0,8,33)
		mset(0,7,33)
	elseif p1x/8 == 14 then
		mset(15,8,33)
		mset(15,7,33)
	end

	if room == 0 then 
		mset(5,10,203) --key
	elseif room == boss then
		initfloattext("----real boss----",29,16,1,0.05,9,9,240)
		mset(2,2,8) --trap closed
		mset(2,13,8) --trap closed
		mset(13,13,8) --trap closed
		mset(13,2,8) --trap closed

		mset(3+1,3+1,91)
		mset(4,4,91)
		mset(11,4,91)
		mset(11,11,91)
		mset(4,11,91)

		initenemy(72, 32, 120, 3, 3, 4) --initenemy(x,y,sprite,hp,steps,type)
	else 
		watereffect = (flr(rnd(10)) == 1 and not shop) and true or false		
		if room == shopgoal then
			shop=true
			shopgoal=room+(3+flr(rnd(5)))
		end

		if not shop then --make normal rooms
			load_room(pre_made_levels[room])

			key=1
			while key > 0 do
				fieldx=flr(rnd(12))+2
				fieldy=flr(rnd(12))+2 
				if is_tile_empty(fieldx, fieldy) then
					mset(fieldx,fieldy,203)
					key-=1
				end
			end

			heart=flr(rnd(10))
			if heart == 1 then
				heartplaced=heart
				while heartplaced > 0 do
					fieldx=flr(rnd(12))+2
					fieldy=flr(rnd(12))+2 
					if is_tile_empty(fieldx, fieldy) then
						mset(fieldx,fieldy,154)
						heartplaced-=1
					end
				end
			end

			item = 1 + flr((rnd(10)/9))--make so that you can get super lucky with two
			itemplaced=item
			while itemplaced > 0 do
				fieldx=flr(rnd(12))+2
				fieldy=flr(rnd(12))+2 
				if is_tile_empty(fieldx, fieldy) then
					mset(fieldx,fieldy,186)
					itemplaced-=1
				end
			end

			coin=flr(rnd(10))
			if coin == 1 then
				coinplaced=coin
				while coinplaced > 0 do
					fieldx=flr(rnd(12))+2
					fieldy=flr(rnd(12))+2 
					if is_tile_empty(fieldx, fieldy) then
						mset(fieldx,fieldy,219)
						coinplaced-=1
					end
				end
			end

			traps = 2 + flr(rnd(room/8))
			trapsplaced=traps
			while trapsplaced > 0 do
				fieldx=flr(rnd(12))+2
				fieldy=flr(rnd(12))+2 
				if is_tile_empty(fieldx, fieldy) then
					randomtrap = flr(rnd(2))+1
					if randomtrap <= 1 then
						mset(fieldx,fieldy,8) --trap closed
					else
						mset(fieldx,fieldy,7) --trap
					end
					trapsplaced-=1
				end
			end

			enemy=flr(rnd(room/2))+1
			enemyplaced=enemy
			while enemyplaced > 0 do
				fieldx=flr(rnd(12))+2
				fieldy=flr(rnd(12))+2 
				if is_tile_empty(fieldx, fieldy) then
					if enemyplaced == 1 then -- at least one crab on every level
						initenemy(fieldx*8,fieldy*8,116,1,1,0)
					else
						pickrandomenemy()
						if randomenemy == 1 then
							initenemy(fieldx*8,fieldy*8,116,1,1,0)
						elseif randomenemy == 2 then
							dir = flr(rnd(3))+1
							inittower(fieldx*8,fieldy*8,dir,60,false)--normal tower
						elseif randomenemy == 3 then
							initenemy(fieldx*8,fieldy*8,100,1,2,0)
						elseif randomenemy == 4 then
							initenemy(fieldx*8,fieldy*8,118,1,1,1)
						elseif randomenemy == 5 then
							dir = flr(rnd(3))+1
							inittower(fieldx*8,fieldy*8,dir,60,true)
						elseif randomenemy == 6 then
							initenemy(fieldx*8,fieldy*8,102,1,1,2)
						elseif randomenemy == 7 then
							initenemy(fieldx*8,fieldy*8,104,1,1,3)
						end
					end
					enemyplaced-=1
				end
			end
		else --shop! 			
			mset(4,6,47)
			mset(11,6,47)
			for i=0,7 do mset(4+i,4,29) end
			for i=0,7 do mset(4+i,5,29) end
			for i=0,7 do mset(4+i,7,45) end
			for i=0,5 do mset(5+i,6,30) end
			boxes=flr(rnd(4))+2
			while boxes > 0 do
				fieldx=flr(rnd(12))+2
				fieldy=flr(rnd(5))+9
				mset(fieldx,fieldy,31)
				boxes-=1
			end
			mset(8,9,203)
		end
	end
end

function is_tile_empty(x,y)
	return mget(x,y) == floorsprite
end

function pickrandomenemy()
	randomenemy = flr(rnd((room/2)))+1
	if (randomenemy <= 0)pickrandomenemy()
	if (randomenemy > 7)pickrandomenemy()
end

enemypos={}
function initenemypos()
	for i = 1, 16 do
		enemypos[i] = {}
		for j = 1, 14 do
			enemypos[i][j] = false -- occupied
		end
	end
end 

walls,getroomstyle,floorsprite=64,0,0
function clearmap()
	if room < boss then
		getroomstyle=room/2
		floorsprite=128+flr(getroomstyle)
	end

	for i=1,14 do
		for j=1,14 do
			mset(i,j,floorsprite)
		end
	end
	
	walls=64+getroomstyle  
	for i=0,16 do 
		mset(i,0,walls)
		mset(0,i,walls)
		mset(15,i,walls)
		mset(i,15,walls)
	end
	for e in all(enemies) do del(enemies,e) end
	for t in all(towers) do del(towers,t) end
end

highscore= 0
function _init()
	cartdata("elstiskalinjen_posedion")
	highscore = dget(0)
	sfx(18)
	shuffle(pre_made_levels)

	clearmap()
	makeroom()
	initenemypos()

	  -- vignette properties
		-- by prof. patonildo
    vgnt={
    dpos=-20,
    pos=8,
    size=-8,
    mode="open"
    }
end

bubbletimer=0
function makebubbles()
	if bubbletimer < 30 then
		bubbletimer+=1
	else
		bubbletimer=0
		initparticle(rnd(128),rnd(128),rnd(0.5)-rnd(0.5),-rnd(0.5),rnd(1),7,12)
	end
end

function _update60()
	t=time()
	if(not playonce)playerupdate()
	foreach(enemies,updateenemies)
	foreach(bombs,updatebomb)
	foreach(arrows,updatearrow)
	foreach(explosions,updateexplosion)
	foreach(particles, update_particle)
	foreach(floattexts,updatefloattext)
	foreach(towers,updatetower)
	foreach(pick_ups, update_pickup)
	makebubbles()
	doshake()
	shopping()
	animate_items()
end

function _draw()
	cls()
	map(0,0,0,0,128,128)
	foreach(particles, draw_particle)
	foreach(arrows, draw_arrow)
	
	if(watereffect)sine_xshift(time()-launch,2,44,10,1,127,false)
	foreach(towers,drawtower)

	local bounce = flr(t) % 2 == 0 and 1 or 0
	spr(p1spr+bounce,p1x,p1y)
	foreach(enemies,drawspr)
	foreach(bombs,drawspr)

	local swordbounce = p1spr == 226 and -bounce or bounce
	if(attacking)spr(swordspr,itemposx,itemposy+swordbounce)
	foreach(explosions,drawspr)

	foreach(floattexts,drawfloattext)
	rectfill(1,121,30,126,0)
	for i=0,hp-1 do spr(240,1+(5*i),120) end

	rectfill(96,121,125,126,0)
	if(attack>0)spr(241,97,120)
	if(nrarrows>0)spr(242,117,120)
	if(nrbombs>0)spr(243,107,120)

	if(shop == false)spr(14,cursorpos,120)

	for i=0,attack-1 do spr(48,97+i*1,120) end
	for j=0,nrbombs-1 do spr(48,107+j*1,120) end
	for k=0,nrarrows-1 do spr(48,117+k*1,120) end

	rectfill(0,0,46,5,0)
	spr(42,0,0)
	print(":"..room,8,0,9)
	if(keys > 0)spr(57,19,0)
	spr(41,28,0)
	print(":"..coins,32,0,10)
	foreach(pick_ups, drawspr)

	drawshop()
	startsreen()
	endscreen()

	draw_vignette(vgnt.mode)
end

starty=-90
c=0
function startsreen()
	if room == 0 then
		starty = keys == 0 and lerp(starty,16,0.04) or lerp(starty,-90,0.04)
		if keys == 1 then 
			draw_text_shadow("test out your weapons\nbefore your adventure!",16,12,2,7)
			draw_text_shadow("trident",16,32,2,10) 
			spr(192,16,40,2,1)

			draw_text_shadow("bomb",52,32,2,10) 	
			spr(194,52,40,2,1)

			draw_text_shadow("bolt",82,32,2,10) 
			spr(196,82,40,2,1)
		end
		initparticle(rnd(128),rnd(128),rnd(0.5)-rnd(0.5),-rnd(0.5),rnd(1),7,12)
		rectfill(16,starty,112,starty+56,0)
		rect(16,starty,112,starty+56,9)
		spr(144,32,starty+12+sin(t)*1.2,8,1)
		spr(152,17,starty+4-sin(t)*1.1,2,3)
		spr(152,93,starty+4-sin(t)*1.1,2,3)

		draw_text_shadow("move:”ƒ‹‘",36,starty+32,2,10) 
		draw_text_shadow("switch move:—",36,starty+41,2,10)
		draw_text_shadow("use move:Ž",36,starty+49,2,10)
		if keys == 0 then 
			draw_text_shadow("a game for my awesome brother!\n\nmy twitter:@elastiskalinjen",6,100,2,12)
		end
	end
end

function draw_text_shadow(text,x,y,co1,co2) 
	print(text,x,y,co1)
	print(text,x,y-1,co2)
end

blinktimer,skullx,blink,playonce = 0,0,false,false
function endscreen()
	if hp <= 0 or room > boss then
		if room > highscore then
			highscore = room
			dset(0,highscore)
		end
		starty = lerp(starty,16,0.04)
		rectfill(16,starty,112,starty+100,0)
		rect(16,starty,112,starty+100,9)
		
		skullx = lerp(skullx,not blink and 8 or 0,0.03)
		if room <= boss then
			spr(178,50+cos(t)*1.1,starty+41,3,1,flr(t) % 2 == 0)
			if not playonce then
				sfx(11)
				playonce = true
			end
			spr(160,54,starty+25+skullx,2,2)
			draw_text_shadow("- you lost! -",38,starty+51,2,9)
		else 
			spr(178,50,starty+41,3,1)		
			spr(166,54,starty+25+skullx,2,2)
			draw_text_shadow("- you won! -",40,starty+51,2,10)
		end

		draw_text_shadow("highscore: "..highscore,41,starty+81,2,9)
		if (not blink)draw_text_shadow("press z/x to restart",25,starty+91,2,9)

		watereffect=true
		if blinktimer < 40 then
			blinktimer+=1 
		else
			blinktimer = 0
			blink = not blink
		end
		if (btnp(4) or btnp(5))run()
	end
end

shop_list={
	"health: 1+",
	"trident:1+",
	"bolt:1+",
	"bomb:1+",
	"trident:durability+",
	"bomb:explosion+",
	"arrow:piercing+"
}

function drawshop()
	if shop then
		fillp()
		rectfill(32,32,95,40,0)
		fillp()
		rect(32,32,96,64,4)
		spr(233,32,24,4,1)
		spr(233,64,24,4,1)
		spr(shopksp,64,48)
		if shopx < 140 then
			rectfill(0,12,128,23,0)
			for i=0,3 do spr(59+i,shopx+(i*15),14) end 
		end
		if canshop then 
			spr(58,shopcurs,32)
			print(shop_list[shoploc+1],32,24-sin(t)*0.9,9)

			print("buy: Ž, next: —",32,12+sin(t)*0.9,7)
		end
		for i=0,3 do spr(240+i,32+(i*8),32-sin(t+i/10)*0.4) end 

		if(attackreduction == 0)spr(244,65,32-sin(t+4/10)*0.4)
		if(bombupg < 8)spr(245,72,32-sin(t+5/10)*0.4)
		if(piercing < 8)spr(246,80,32-sin(t+6/10)*0.4)
	end
end

shopksp=43
canshop = false
shopcurs=32
shoploc=0
greeted = false
shopx = -55
function shopping()
	if shop then
		if (shopksp <= 44.9) then shopksp+=0.05 else shopksp = 43 end 
		if (shopx < 140)shopx+=0.7
		if calcdist(p1x,p1y,64,47) < 20 then
			canshop = true
		else
			canshop = false
			shopcurs=32
			shoploc=0
			greeted = false
		end
		if canshop then
			if not greeted then
				greeted = true
				initfloattext("hi",64,41,2,0.05,10,9,50)
			end
			if btnp(5) then
				if shoploc < 6 then
					shoploc+=1
					shopcurs+=8 
				else 
					shoploc=0
					shopcurs=32
				end
				sfx(9)
			end

			if btnp(4) then
				if coins > 0 then
					for i=0,4 do initparticle(4+i*8,4,0,rnd(1),2,10,7) end
					initfloattext("thanks",60,41,2,0.05,10,9,50)
					sfx(16)
					if shoploc == 0 then 
						if hp < 5 then
							hp+=1
							init_pick_up(240,p1x,p1y,12,112)
							initfloattext("+hp",12,115,1,-0.2,8,7,40)
							coins-=1
						end
					elseif shoploc == 1 then
						if attack < 6 then
							attack+=1
							initfloattext("+trident",97,115,1,-0.2,9,10,40)
							coins-=1
						end
					elseif shoploc == 2 then
						if nrarrows < 6 then
							nrarrows+=1
							initfloattext("+arrow",97,115,1,-0.2,9,10,40)
							coins-=1
						end
					elseif shoploc == 3 then
						if nrbombs < 6 then
							nrbombs+=1
							initfloattext("+bomb",97,115,1,-0.2,9,10,40)
							coins-=1
						end
					elseif shoploc == 4 then --attackreduction
						if attackreduction == 0 then
							initfloattext("+durability",97,115,1,-0.2,9,10,40)
							attackreduction=0.5
							coins-=1
						end
					elseif shoploc == 5 then --bomb upg
						if bombupg < 8 then
							initfloattext("+bomb-upg",88,115,1,-0.2,9,10,40)
							bombupg+=1
							coins-=1
						end
					elseif shoploc == 6 then -- piercing
						if piercing < 8 then
							initfloattext("+arrow-upg",88,115,1,-0.2,9,10,40)
							piercing+=1
							coins-=1
						end
					end
				else
					initfloattext("no coins!",52,41,2,0.05,10,9,50)
					sfx(17)
				end
			end
		end
	else
		shopx = -55
	end
end

animate_counter=0
function animate_items()
	if animate_counter < 12 then 
		animate_counter+=1
	else
		animate_counter=0
		for x=0,15 do
			for y=0,15 do
				local m=mget(x,y)
				local f_p=fget(m,3)
				local f_h=fget(m,2)
				local f_k=fget(m,6)
				local f_c=fget(m,4)
				local min_value = -1
				
				if f_p then
					min_value = 186 
				elseif f_h then 
					min_value = 154
				elseif f_k then 
					min_value = 203
				elseif f_c then 
					min_value = 219
				end

				if min_value > -1 then
					if m < min_value+3 then 
						mset(x,y,m+1)
					else
						mset(x,y,min_value)
					end
				end
			end
		end
	end
end

enemies={}
function initenemy(x,y,sprite,hp,steps,type)
local e ={
	x=x,
	y=y,
	oldx=x,
	oldy=y,
	sp = sprite,
	sprite = sprite,
	stepc = steps,
	steps = steps,
	delay = 0,
	hp=hp,
	move=false,
	rotvert=false,
	rothor=false,
	type=type
	}
	add(enemies,e)
end

function updateenemies(e)
	--move
	if e.move and e.steps > 0 then
		disttoplayer=calcdist(e.x+4,e.y+4,p1x+4,p1y+4)
		bestmove=0
		enemypos[e.x/8][e.y/8] = false
		
		if e.type == 0 or e.type == 1 or e.type == 4 or e.type == 3 then
			dist=calcdist(e.x-8,e.y,p1x,p1y)
			if disttoplayer > dist then
				if fget(mget((e.x/8)-1,e.y/8))~=2 and not enemypos[(e.x/8)-1][(e.y/8)] then
					bestmove=1
					disttoplayer=dist
				end
			end
			dist=calcdist(e.x+8,e.y,p1x,p1y)
			if disttoplayer > dist then
				if fget(mget((e.x/8)+1,e.y/8))~=2 and not enemypos[(e.x/8)+1][(e.y/8)] then
					bestmove=2
					disttoplayer=dist
				end
			end
			dist=calcdist(e.x,e.y-8,p1x,p1y)
			if disttoplayer > dist then
				if fget(mget((e.x/8),(e.y/8)-1))~=2 and enemypos[(e.x/8)][(e.y/8)-1] == false then
					bestmove=3
					disttoplayer=dist
				end
			end
			dist=calcdist(e.x,e.y+8,p1x,p1y)
			if disttoplayer > dist then
				if fget(mget((e.x/8),(e.y/8)+1))~=2 and enemypos[(e.x/8)][(e.y/8)+1] == false then
					bestmove=4
					disttoplayer=dist
				end
			end

			if bestmove > 0 then
				if e.delay < 12 then
					e.delay+=1
				else
					e.delay=0
					initparticle(e.x+rnd(4),e.y+rnd(4),0,0,rnd(2),7,7)
					
					if bestmove == 1 then--left
						if e.type == 0 or e.type == 4 or e.type == 3 then
							e.x-=8
						else
							while fget(mget((e.x/8)-1,e.y/8))~=2 and e.x-p1x ~= 0 and not enemypos[(e.x/8)-1][(e.y/8)] do
								e.x-=8
								for i=0,3 do initparticle(e.x+rnd(4),e.y+rnd(4),0,0,rnd(2),3,10) end
							end
						end
						e.rothor=false
						e.sp=e.sprite
					elseif bestmove == 2 then--right
						if e.type == 0 or e.type == 4 or e.type == 3 then
							e.x+=8
						else
							while(fget(mget((e.x/8)+1,e.y/8))~=2 and e.x-p1x ~=0 and enemypos[(e.x/8)+1][(e.y/8)] == false)do
								e.x+=8
								for i=0,2 do initparticle(e.x+rnd(4),e.y+rnd(4),0,0,rnd(2),3,10) end
							end
						end
						e.rothor=true
						e.sp=e.sprite
					elseif bestmove == 3 then--up
						if e.type == 0 or e.type == 4 or e.type == 3 then
							e.y-=8
						else
							while fget(mget((e.x/8),(e.y/8)-1))~=2 and e.y-p1y ~=0 and enemypos[(e.x/8)][(e.y/8)-1] == false do
								e.y-=8
								for i=0,2 do initparticle(e.x+rnd(4),e.y+rnd(4),0,0,rnd(2),3,10) end
							end
						end
						e.rotvert=false
						e.sp=e.sprite+1
					elseif bestmove == 4 then--down
						if e.type == 0 or e.type == 4 or e.type == 3 then
							e.y+=8
						else
							while fget(mget((e.x/8),(e.y/8)+1))~=2 and e.y-p1y ~=0 and enemypos[(e.x/8)][(e.y/8)+1] == false do
								e.y+=8
								for i=0,2 do initparticle(e.x+rnd(4),e.y+rnd(4),0,0,rnd(2),3,10) end
							end
						end
						e.rotvert=true
						e.sp=e.sprite+1
					end
						e.steps-=1
						initfloattext(e.steps,e.x+4,e.y+4,1,-0.2,13,2,30)
				end
			else
				e.steps-=1
				initfloattext("!",e.x+4,e.y+4,1,-0.2,13,2,30)
			end
		end

		if e.type == 2 then 
			if e.delay < 12 then
					e.delay+=1
				else
					e.delay=0
					initparticle(e.x+rnd(4),e.y+rnd(4),0,0,rnd(2),7,7)

					if p1spr == 228 then 
						if (fget(mget(e.x/8 +1,e.y/8))~=2)e.x+=8--left
					elseif p1spr == 230 then
						if (fget(mget(e.x/8 -1,e.y/8))~=2)e.x-=8--right
					elseif p1spr == 224 then
						if (fget(mget(e.x/8,e.y/8 +1))~=2)e.y+=8--up
					elseif p1spr == 226 then
						if (fget(mget(e.x/8,e.y/8 -1))~=2)e.y-=8--down
					end
					disttoplayer=calcdist(e.x+4,e.y+4,p1x+4,p1y+4)
					for t=0,6 do initparticle(e.x+4,e.y+4,rnd(3)-1.5,rnd(3)-1.5,rnd(2),14,8) end 

					if disttoplayer < 12 then
						hp-=1
						initfloattext(-1,p1x,p1y,1,-0.3,11,3,40)
						hasbeenhit=true
						shake=0.2
					end
					e.steps-=1
					initfloattext(e.steps,e.x+4,e.y,1,-0.2,13,2,30)
				end
		end

		if e.steps == 0 then
			if e.move and e.type == 4 then 
				mset((8 * flr(rnd(10)) + 16)/8, (8 * flr(rnd(10)) + 16)/8,7)
			end

			if e.type == 4 then
				initarrow(e.x, e.y-10, 3, false)
				initarrow(e.x, e.y+10, 4, false)
			end
			if e.type == 3 then
				initarrow(e.x-10, e.y, 1, false)
				initarrow(e.x+10, e.y, 2, false)
			end

			e.move=false
			if e.x > 0 and e.y > 0 and e.y < 128 and e.x < 128 then
				enemypos[e.x/8][e.y/8] = true
			end
		end
	end

	if (e.x == itemposx and e.y == itemposy and attacking)e.hp-=1
	if (fget(mget(e.x/8,e.y/8)) == 32)e.hp-=1

	if e.x == p1x and e.y == p1y and not hasbeenhit then
		if not attacking then 
			hp-=1
			initfloattext(-1,p1x,p1y,1,-0.3,11,3,40)
			hasbeenhit=true
			for i=0,3 do initparticle(p1x+rnd(4),p1y+rnd(4),rnd(2)-1,rnd(2)-1,2,8,2) end
		end
		if e.type < 4 then
			e.hp=0
		else
			e.hp-=1
			initfloattext(-1,e.x+4,e.y+4,1,-0.2,13,2,30)
			e.x = 72
			e.y = 32
		end
	end

	if e.hp <= 0 then
		initfloattext(-1,e.x+4,e.y,1,-0.5,8,2,30)
		for i=0,3 do initparticle(e.x+rnd(4),e.y+rnd(4),rnd(2)-1,rnd(2)-1,2,8,9) end
		dropcoin=flr(rnd(4))
		sfx(5)
		if dropcoin == 1 then
			if (not checkforkey(e.x,e.y))mset(e.x/8,e.y/8,219)	
		else
			enemypos[flr(e.x/8)][flr(e.y/8)] = false
		end
		if e.type == 4 then
			mset(e.x/8,e.y/8,203)
		end
		del(enemies,e)
		shake=0.1
	end
end

function drawspr(s)
	spr(s.sp,s.x,s.y,1,1,s.rothor,s.rotvert)
end

bombs={}
function initbombs(x,y,sp)
	local b={
		x=x,
		y=y,
		sp=sp,
		dur=3,
		timer = 0,
		upg = bombupg, --how long explosions
		push = true -- can push bombs
	}
	checkvalidspot(x, y, true)
	add(bombs,b)
end

function updatebomb(b)
	if (b.timer <  1)initparticle(b.x+4,b.y+1,rnd(0.3)-rnd(0.3),-rnd(1)-0.1,1,6,7)
	if (b.timer < 7) then b.timer+=1 else b.timer = 0 end
	
		for e in all(enemies) do
			if hitboxcoll(b.x,b.y,8,8,e.x+2,e.y+2,2,2) then
				if b.dur == 3 then
					e.hp-=1
					shake=0.3
					enemypos[flr(b.x/8)][flr(b.y/8)] = false
					del(bombs,b)
				end
			end
		end

		for a in all(arrows) do 
			if hitboxcoll(b.x,b.y,8,8,a.x+2,a.y+2,2,2) and a.hero then
				del(arrows,a)
				shake=0.3
				b.dur = 0
			end
		end
	pushobject(b)
	
	--explode
	if b.dur <= 0 then
		for i=1,b.upg do  
			if not checkforkey(b.x+(8 * i),b.y) then
				mset((b.x+(8 * i))/8,b.y/8,floorsprite)
				initexplosion(b.x+(8 * i),b.y,39)
			end
			if not checkforkey(b.x-(8 * i),b.y) then
				mset((b.x-(8 * i))/8,b.y/8,floorsprite)
				initexplosion(b.x-(8 * i),b.y,39)
			end
			if not checkforkey(b.x,b.y-(8 * i)) then
				mset(b.x/8,(b.y-(8 * i))/8,floorsprite)
				initexplosion(b.x,b.y-(8 * i),39)
			end
			if not checkforkey(b.x,b.y+(8 * i)) then
				mset(b.x/8,(b.y+(8 * i))/8,floorsprite)
				initexplosion(b.x,b.y+(8 * i),39)
			end
		end
		--middle piece
		if not checkforkey(b.x,b.y) then
			mset(b.x/8,b.y/8,floorsprite)
			initexplosion(b.x,b.y,55)
		end

		shake=0.2
		for i=0,5 do initparticle(b.x+rnd(4),b.y+rnd(4),rnd(4)-2,rnd(4)-2,2,9,10) end
		sfx(12)
		del(bombs,b)
		checkvalidspot(b.x, b.y, false)
	end
end

function pushobject(o)
	if hitboxcoll(o.x,o.y,8,8,p1x+2,p1y+2,2,2) then 
		movebackplayer()
		if direction == 1 and checkpos(o.x-8,o.y) then
			enemypos[o.x/8][o.y/8] = false
		 	o.x-=8
		 	enemypos[o.x/8][o.y/8] = true
		elseif direction == 2 and checkpos(o.x+8,o.y) then
			enemypos[o.x/8][o.y/8] = false
		 	o.x+=8
		 	enemypos[o.x/8][o.y/8] = true
		elseif direction == 3 and checkpos(o.x,o.y-8) then
			enemypos[o.x/8][o.y/8] = false 
			o.y-=8
			enemypos[o.x/8][o.y/8] = true
		elseif direction == 4 and checkpos(o.x,o.y+8) then
			enemypos[o.x/8][o.y/8] = false 
			o.y+=8
			enemypos[o.x/8][o.y/8] = true
		end
	end
end

function checkforkey(x,y)
	return fget(mget(x/8,y/8),6)
end

arrows={}
function initarrow(x,y,dir,hero)
	local a={}
	a.x=x
	a.y=y
	a.dir=dir
	if hero then
		if a.dir == 1 then--left
			a.sp = 27
		elseif a.dir==2 then--right
			a.sp = 26
		elseif a.dir==3 then--up
			a.sp = 25
		elseif a.dir==4 then--down
			a.sp = 28
		end
		a.dur = piercing
	else
		a.sp = 52
		a.dur = 1
	end
	a.hero=hero
	a.speed = 0.5
	
	a.pos=fget(mget(a.x/8,a.y/8)) 
	a.timer = 0
	add(arrows,a)
end

function updatearrow(a)
	a.pos=fget(mget((a.x+4)/8,(a.y+4)/8))
	if (a.timer < 1)initparticle(a.x+rnd(4),a.y+rnd(4),0,0,1,7,6)
	if (a.timer < 3) then a.timer+=1 else a.timer = 0 end
	if (a.speed < 2.5)a.speed+=0.25
	if a.dir == 1 then--left
		a.x-=a.speed
	elseif a.dir==2 then--right
		a.x+=a.speed
	elseif a.dir==3 then--up
		a.y-=a.speed
	elseif a.dir==4 then--down
		a.y+=a.speed
	end
	if a.pos > 0 and a.pos < 100 then
		if a.pos == 32 then
			coin=rnd(4)
			if (coin < 1 and not checkforkey(a.x,a.y)) then mset(a.x/8,a.y/8,219) else mset(a.x/8,a.y/8,floorsprite) end 
		end
		a.dur-=1
		if a.hero then 
			shake=0.04
			sfx(4)
		end
	end
	
	for e in all(enemies) do
		if hitboxcoll(a.x+3,a.y+3,2,2,e.x,e.y,8,8) then
			a.dur-=1
			e.hp -= 1 
		end
	end

	if hitboxcoll(a.x,a.y,8,8,p1x+2,p1y+2,1,1) then
		a.dur = 0
		for i=0,2 do initparticle(a.x+rnd(4),a.y+rnd(4),rnd(2)-1,rnd(2)-1,1,8,9) end
		hp-=1
		sfx(10)
		initfloattext(-1,p1x,p1y,1,-0.3,11,3,40)
	end

	if a.dur <= 0 then
		for i=0,2 do initparticle(a.x+rnd(4),a.y+rnd(4),rnd(2)-1,rnd(2)-1,1,4,9) end
		del(arrows,a)
	end
end
function  draw_arrow(s)
	spr(s.sp,s.x,s.y,1,1,s.timer == 0,s.rot2)
end

towers={}
function inittower(x,y,dir,shoottimer,rotate)
	local t={
		x=x,
		y=y,
		dir = dir,
		rotate = rotate,
		sp = not rotate and 95 + dir or 112 + dir,
		shoot = false,
		noenemies = 0,
	}
	enemypos[x/8][y/8] = true
	add(towers,t)
end

function updatetower(t)
	if t.shoot then
		t.shoot = false
		if #enemies > 0 then 
			initarrow(t.x,t.y,t.dir,false) --shoot
		else
			if t.noenemies == 0 then
				t.noenemies +=10
				t.sp += t.noenemies
			end
		end
	end
	pushobject(t)

	if fget(mget(t.x/8,t.y/8)) == 32 then
		del(towers,t)
		for i=0,10 do initparticle(t.x+rnd(4),t.y+rnd(4),rnd(4)-2,rnd(4)-2,1,12,2) end
		sfx(5)
		dropcoin=flr(rnd(6))
		if dropcoin == 1 then
			if (not checkforkey(t.x,t.y))mset(t.x/8,t.y/8,219)	
		end
	end	
end

function drawtower(t)
	spr(t.sp,t.x,t.y)
end

explosions={}
function initexplosion(x,y,sp)
	local b={
		x=x,
		y=y,
		sp=sp,
		dur=1,
	}
	add(explosions,b)
end

function updateexplosion(b)
	for e in all(enemies) do
		if (hitboxcoll(b.x,b.y,8,8,e.x+2,e.y+2,2,2))e.hp-=1
	end
	for t in all(towers) do
		if (hitboxcoll(b.x,b.y,8,8,t.x+2,t.y+2,2,2))del(towers,t)
	end
	if hitboxcoll(b.x,b.y,8,8,p1x+2,p1y+2,2,2) then
	 	hasbeenhit=true
	 	hp-=1 
	 end
	if (b.dur <= 0)del(explosions,b)
end

pick_ups={}
function init_pick_up(sp,x,y,ex,ey)
	local p={
		sp=sp,
		x=x,
		y=y,
		ex=ex,
		ey=ey,
	}
	add(pick_ups,p)
end

function update_pickup(p)
	p.x = lerp(p.x, p.ex,0.1)
	p.y = lerp(p.y, p.ey,0.1)
	if calcdist(p.x,p.y,p.ex,p.ey) < 2 then 
		del(pick_ups, p)
	end
end

------functions

function hitboxcoll(a1x,a1y,a1width,a1height,a2x,a2y,a2width,a2height)
	return not ((a1x > a2x+a2width) or
	(a1x+a1width < a2x) or
	(a1y > a2y+a2height) or 
	(a1y+a1height < a2y))
end

shake=0
function doshake()
 local shakex=16-rnd(32)
 local shakey=16-rnd(32)
 shakex*=shake
 shakey*=shake

 camera(shakex,shakey)
 shake=shake*0.95
 if (shake<0.05)shake=0
end

function calcdist(x1,y1,x2,y2)
	return sqrt(((x2-x1)/10)^2+((y2-y1)/10)^2)*10
end

function checkpos(x,y)
	fieldx = x/8
	fieldy = y/8
	return fget(mget(fieldx,fieldy)) <= 1 or fget(mget(fieldx,fieldy)) == 128
end

function lerp(var,target,pow)
	return var+pow*(target-var)
end

function checkvalidspot(x, y, tag)
	if x >= 8 and x <= 120 and y >= 8 and y <= 120 then 
		enemypos[x/8][y/8] = tag
	end	
end

---effects---

particles={}
function initparticle(x,y,dx,dy,size,col1,col2)
	local randomcolor=flr(rnd(2))+1
	local p={
		x=x,
		y=y,
		dx=dx,
		dy=dy,
		size=size+rnd(2),
		realcol= randomcolor == 1 and col1 or col2
	}
	add(particles,p)
end

function  update_particle(p)
	p.dx*=0.9
	p.dy*=0.9
	p.x+=p.dx
	p.y+=p.dy
 	p.size -= 0.08
	if (p.size <=0)del(particles,p)	
end

function  draw_particle(p)
	circ(p.x,p.y,p.size,p.realcol)
end
 
floattexts={}
function initfloattext(text,x,y,dir,sp,c1,c2,timer)
	local t={
		x = x,
		y = y,
		text = text,
		dir = dir,
		speed = sp,
		c1 = c1,
		c2 = c2,
		timer = timer,
		changecolor = timer/2
	}

	add(floattexts,t)
end
function updatefloattext(t)
	if t.dir == 1 then t.y+=t.speed else t.x+=t.speed end
	if(t.timer <= t.changecolor)t.c1 = t.c2
	if t.timer > 0 then t.timer-=1 else del(floattexts,t) end
end
function drawfloattext(t)
	print(t.text,t.x,t.y,t.c1)
end

badstory={
	"keys must lead to somewhere",
	"i have been here before...",
	"i need to find some answers",
	"just need to find back to home",
	"nothing is going to stop me",
	"why is everyone turning on me",
	"so much death ahead...",
	"all should be under my control",
	"is this hades work?",
	"i miss amphitrite",
}

-- horizontal distortion effect by qbicfeet
-- t: time
-- a: amplitude
-- l: wavelength 
-- s: speed
-- y1: first horizontal line
-- y2: last horizontal line
-- mode: interlaced y/n
launch = time()
function sine_xshift(t,a,l,s,y1,y2,mode)
 for y=y1,y2 do
  local off = a * sin((y + flr(t*s + 0.5) + 0.5) / l)
  if mode and y%2 < 1 then off *= -1 end
  local x = flr(off/2 + 0.5) % 64
  local addr = 0x6000+64*y
  
  memcpy(0x4300,addr,64)
  memcpy(addr+x,0x4300,64-x)
  memcpy(addr,0x4340-x,x)
 end
end

function draw_vignette(_mode)
    -- check modes
    if _mode=="open" then
			if vgnt.pos>-140 then
				vgnt.pos-=2
				vgnt.size+=4
			end
    elseif _mode=="close" then
			if vgnt.pos < 8 then
				vgnt.pos+=4
				vgnt.size-=8
			else
				vgnt.mode = "open"
				nextlevel()
			end
    end
   
    -- draw vignette
    -- change palt to your needs
    -- change sspr to your needs
    -- x==player x   y==player y
		if vgnt.pos >= -128 or vgnt.mode == "close" then
			palt(0,false)
			palt(1,true)
			local factor,x,y=vgnt.pos+20,p1x,p1y
			sspr(8,0,16,16,x+vgnt.pos,y+vgnt.pos,vgnt.size,vgnt.size)
			rectfill(0,0,x-20+factor,512,0)
			rectfill(x-20+factor,0,x+27-factor,y-20+(vgnt.pos+20),0)
			rectfill(x+27-factor,0,1024,512,0)
			rectfill(x-20+factor,y+27-factor,x+27-factor,512,0)
			palt()
		end
end
__gfx__
00000000000001111110000011111111000000000000000011111111112222111188881100000000000000000000000000000000000000009999999900000000
000000000001111111111000145454510000000000000000119aa911121221211888888100000000000000000000000000000000000000009000000900000000
00700700001111111111110095222249000000000000000019a7aa912222222281f1f1f800000000000000000000000000000000000000000000000000000900
0007700001111111111111109400005900000000000000001a7aaaa125656562811111180000000000000000000000000000000000000000000000000aaaaa90
0007700001111111111111109540054900000000000000001aaaaaa1265656528111111800000000000000000000000000000000000000000000000000000900
00700700111111111111111194500459000000000000000019aaaa91222222228f1f1f1800000000000000000000000000000000000000000000000000000000
0000000011111111111111119999999900000000000000001d9aa9d1122222211888888100000000000000000000000000000000000000009000000900000000
00000000111111111111111152222225000000000000000011dddd11112222111188881100000000000000000000000000000000000000009999999900000000
00000000111111111111111100000000000000000900a0a00000d00000000000000000000000a000000000000000000000a00000111111112222222219444491
00000000111111111111111100000000000000000909a0a00000500000000aaaaaa00000000a00000000000000000000000a0000111111112222222294545459
0000000011111111111111110000000000000a000999a9a000004000000009000090000000aa0000000a000000a0000a0000a000515151512222222245454544
0000000001111111111111100000000000000000000aa000000040000000aaaaaaaa0000000aa00000aaa00a0aaa00a00000aa00151515152222222244545454
000000000111111111111110000000000000000000040000000aa000d544a990099a445d0000aa000a00aaa0a00aaa00000aa000111111112222222245454544
0000000000111111111111000000000000000000000400000a9a999000000900009000000000a000a0000a000000a00000aa0000111111112222222294545459
0000000000011111111110000000000000000000000500000a0a90900000099999900000000a00000000000000000000000a0000111111112222222229444492
0000000000000111111000000000000000000000000d00000a0a0090000000000000000000a0000000000000000000000000a000555555552222222212222221
000000001111111100000000111111110000000000000000000000000a9999a015666651000aa00000a99a000077770000000000555555550000000049999994
00000000154545410000000011111111000000000000000000000000a988889a56d66d6500a7aa000a4545a00766667000777700aa7a7a7a00000000999a4999
0000000064545456000000001111111100777d0000aaa90000000000989aa9896d5665d6007aaa000954549076cd116707666670494949940000000099a44499
0000000065454546000000001111111107d7dd20079a99800000000098a99a896666666600aaa900094545907611116776cd1167499494940000000099444299
000000006454545600000000111111110ddddd20099999800000000098a99a8966666666000a9000095454907666666776111167494949940000000099942999
0000000065454546000000001111111102ddd2200899988000000000989aa9896d5665d600000000000000007666666776666667444444440000000049999994
00000000666666660000000011111111022222200888888000000000a988889a56d66d65000000000000000071dddd1771d11d17444444440000000044444444
000000005222222500000000111111110022220000888800000000000a9999a01566665100000000000000007666666706666660444444440000000044444444
000000001111111111a11811000000000000000000cccc00000000000a9999a0000000000007a0000000000000a7aa7a070000700a7aa77000aaa70011111111
0700000011a118111a88888100000000007e88000c1cc1c000cccc00a9aaaa9a0000000000a00a00000000000a9999907a0000a7a900009a0aa00aa011111111
000000001a888881188888810000000007ee88200caaaac00cccccc09a9aa9a900000000000aa000000000000a000000aa0000aaaa0000aa0aa00aa011111111
000000001888888112888821000000000ee88820cc9999cc0c1cc1c09aa99aa900000000000a0000000000000aaaaa00aaaaaaaaaa0000aa0aa00aa011111111
0000000012888821122882210000000008888820cc7777cc0caaaac09aa99aa900000000000a900000000000009999a0aa9999aaaa0000aa0aa00a9011111111
00000000122882211122221100000000088882200cc77cc0cc9999cc9a9aa9a9000000000000000000000000000000a0aa0000aaaa0000aa0aaaa90011111111
000000001d2222d11dddddd100000000002222000cccccc00cc77cc0a9aaaa9a0000000000000000900000090aaaaa909a0000a9a900009a0a90000011111111
0000000011dddd1111dddd1100000000000000000c0000c00cccccc00a9999a00000000000000000a999999a9999990009000090099999900aa0000011111111
100000011d1111d11333335111111111311b1b1311111111188888811114411111111111115522111111111111aa911100000111111000000000000000000000
00dddd00d111111d333bb33511d11111b33b131b111e2111888887881994499111666611156522211aaaaaa111a9991100011111111110000000000000000000
0d0000d0111dd1113335b3bb11d1dd1111b1133111e22211878888881944449116cc7c61165555211a77aaa11999989100111111111111000000000000000000
0d0000d011d11d113bb333b5dddddddd3b313b131e222221888878784424424416c7cc61555552221a7aaaa1a899989901111111111111100000000000000000
0d0000d011d11d113b5333331dddddd11333b3b312222221887888882224422216ccc761555522521aaaaaa19889888801111111111111100000000000000000
0d0000d0111dd111333bb333dddddddd11b33b3112222221d888888d99944999167c7c61655555221aaaaaa18888888811111111111111110000000000000000
00dddd00d111111d533b53352dddddd211133311d222222d1dddddd11944449116666661d662222d199999912888888211111111111111110000000000000000
200000021d1111d11553355112222221111111111dddddd111111111129229211dddddd11dddddd1111111111222222111111111111111110000000000000000
1100001111e11e11113bb5111d11d111111331111111111111188111119449111111111111611611177aaaa11111111111111111111111110000000000000000
10000001e11ee21e133353511d1dd11d11b3331111e1212111878811299449921167661115655651999aa9991111a11111111111111111110000000000000000
100000012eee211e3b3333551d1d11dd11b333111e222221178887811944449117cc7c6111611611a79999aa11a19a1111111111111111110000000000000000
10000001122e11e233b333351ddd1dd11b33b3311e222221888888884444444416ccc7611565565199aaaa991a9989a101111111111111100000000000000000
10000001111eee21b333355511dddddd1b33b3b1e222222218ffff8122444422167c7c6111611611a999999a1988888101111111111111100000000000000000
10000001ee1e21e133335b551ddd6d6111b3331122222222111771111924429116ccc7611161161197a7aaa91888888100111111111111000000000000000000
d000000d12eeee11d333555d266666621b33b331d222222d11177111299449921d6666d1d666666da999999ad222222d00011111111110000000000000000000
1dddddd1111221111dddddd112222221113333111dddddd111dddd111292292111dddd111dddddd1199999911dddddd100000111111000000000000000000000
00cccc0000cccc0000cccc0000cccc000000a0000000c0000000000000977900002220ee0022220000cccc0000cccc0000cccc0000cccc000000000000000000
0fccfcc00ccfccf00c2222c00cccccc0000a900d000dcc00064464009ffffff9027e7e0002ee77200fccfcc00ccfccf00cccccc00cccccc00000000000000000
c2222cccccc2222cc288882cccfccfcc0cccdcdc000c7c00714417400ffeeff027eee20e2e2eee72ccccccccccccccccc222222cccfccfcc0000000000000000
288882cccc288882c288882ccc2222cccc7dddc0000ddca047ee74449fe22e9f27eeeee02ee2eee2222222cccc222222ccddddcccccccccc0000000000000000
288882cccc288882c299992cc288882c0dcdcdcd009cdd9a9e22eff4047ee7402ee2e20e2eeeee72cddddccccccddddcccccccccc222222c0000000000000000
299992cddc299992dd2222ddd288882d0000900c000ddc00ffeefff0071441702e2eeee002e2e2e0cccccccddcccccccddccccdddcddddcd0000000000000000
02222dd00dd222200dddddd00299992000000000000ccd000fffff00ff6446ff02eee20ee0e0e00e0cccccc00cccccc00dddddd00dccccd00000000000000000
00dddd0dd0dddd00d0dddd0dd022220d0000000000cd0cd0007f70000f0000f0002220000e0e00e000ddc0c00c0cdd00d0dddd0dd0dddd0d0000000000000000
00bb00000000bb00000bb000000bb000020000000880088000000000000000000ccccc000c0000c000bb00000000bb00000bb000000bb0000000000000000000
01331b0000b1331001eeee1000b33b00882080802800008200000000000eee0001cc1cc00cccccc001331b0000b1331001bbbb1000b33b000000000000000000
0eeee3b00b3eeee00e8888e0001331008002820002022020000002000027e700aaaaccc00cc77cc00bbbb3b00b3bbbb00bbbbbb0001331000000000000000000
e8888e3003e8888e0e8888e003eeee3000288820002882000e70e0e000e000009999ccc0dc7777cdbbbbbb3003bbbbbb0e8888e003bbbb300000000000000000
e8888e3003e8888e0e2222e00e8888e000288820088888800ee020200002e2000777ccc0cc9999cce8888e3003e8888e0eeeeee00bbbbbb00000000000000000
e2222e3003e2222e03eeee300e8888e080028200002882000e70e0e0000000e00777cdc00caaaac0eeeeee3003eeeeee03bbbb300bbbbbb00000000000000000
0eeee330033eeee0033333300e2222e0882080800802208000e200900a92e2000cccccc00c1cc1c00333333003333330033333300e8888e00000000000000000
003333b00b3333000b3333b00beeeeb00200000000000000000000a9090000000c000c0000cccc00003333b00b3333000b3333b00beeeeb00000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11011111111111111111111111111111111111111111122111111111115115111111d11111111111111111111221112111111111111111111111111111111111
1001101111111111111111d1111161111111111111111121111211111511115111111d1115111151111111111121111111111111111111111111111111111111
111011111111111111d11111111d1d11114141111111211111222111111111111111111111111111111011111111121111111111111111111111111111111111
1111011111111d111d11111111111111111411111112111111151111111111111d11111111111111110001111111221111111111111111111111111111111111
110110011111d1d111111111111111111111111112111111111111111511115111d1111115111151111011111121111111111111111111111111111111111111
1111101111111d111111111111111111111111111221111111111111115115111111111111111111111111111221122111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00aaa7000a7aa77000a7aa7a0aaaaa000700a7aa0000700a7777000a7aa7a00000000000000000001111111111a118111118811111a118110000000000000000
0aa00aa0a900009a0a999990a9999990aa0aa00a700aa0a90009a0a999990000007000070000070011a118111a888881118888111a8888810000000000000000
0aa00aa0aa0000aa0a000000a00000007a0aa000aa07a0aa000aa0a000000000009a0009a000a9001a8888811888888111888811188888810000000000000000
0aa00aa0aa0000aa0aaaaa00aaaaaa00aa0aa000aa0aa0aa000aa0aaaaa0000000970009a000a900188888811288882111888811128888210000000000000000
0aa00a90aa0000aa009999a0a9999990aa0aa000aa0aa0aa000aa009999a00000097000970007900128888211228822111288211122882210000000000000000
0aaaa900aa0000aa000000a0a0000000aa0aa00aa90aa0aa000aa000000a0000009a0009a000a900122882211122221111122111112222110000000000000000
0a900000a900009a0aaaaa90aaaaaa00aa0aaaaa900aa0a90009a0aaaaa90000009aa09aa909a9001d2222d11dddddd11dddddd11dddddd10000000000000000
0aa00000099999909999990099999990990999990009900999990999999000000009aaaa77a9900011dddd1111dddd1111dddd1111dddd110000000000000000
000007777770000000000000000000000000000000000000000999999999900000009a9a9aa90000000000000000000011111111000000000000000000000000
0000777777770000000000000000000000000000000000000092222222222900000000999900000000000000a00a0a0011111111000000000000000000000000
00077777777770000000000000000000000000000000000000a9121212129900000000022000000000000000a00a0a00111111d1000000000000000000000000
00777777777777000000000000000000000000000000000000a799111199a900000000024000000000000000aaaa0a0011d11111000000000000000000000000
07771177771177700000000000000000000000000000000000a7aa9999aaa900000000024000000000000000a00a0a001d111111000000000000000000000000
07711177771117700000000000000000000000000000000000aa7aaaaaaaa900000000024000000000000000a00a0a0011111111000000000000000000000000
07711177771117700000000000000000000000000000000000aa7aaaaaaa9900000000024000000000000000a00a0a0011111111000000000000000000000000
077611777711677000000000000000000000000000000000000aaaaaaaaa90000000000240000000000000000000000011111111000000000000000000000000
0677667777667760000000000000000000000000000000000000aaaaaa9900000000000240000000114545111154541111454511114545110000000000000000
006777777777760000000000000000000000000000000000000000999900000000000002400000001337b33111b7b311133733311337b3310000000000000000
0000771717170000000000000000000000000000000000000000000a9000000000000001d0000000117333111173331111733b11117333110000000000000000
00007717171700000000000000000000000000000000000000000009a000000000000002400000001173b311117b331111733311117b33110000000000000000
0000771717170000000000000000000000000000000000000000007aaa00000000000001d0000000133333311133331113333331133333310000000000000000
000007777770000000cc00ccc000cc000cc00cc00cc00cc00000aaaaaa990000000000024000000013b3333111b333111333b33113b33b310000000000000000
00000666666000000ccc0ccc00ccc00ccc0ccc0ccc0ccc0c000a99999999900000000001d00000001d3333d1113333111d3333d11d3333d10000000000000000
0000000000000000cccccccccccccccccccccccccccccccc0000000000000000000000244400000011dddd1111dddd1111dddd1111dddd110000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001117a111111aa111111aa111117aaa1100000000
0000000000000aaa00000000000000000000000000000000000000000000000000000000000000000000000011711a1111a11a11111aa11111a11a1100000000
000a0000000009000006d00000aaa900000aa000a0000a00000aa000a0000a0000000000000000000000000011a11a1111911911111aa111119aa91100000000
00aa90000000aaaa006dd200079a998000000a000a00aaa000000a000a00aaa0000000000000000000000000119aa911111aa111111a1111111a111100000000
00040000d544a99000dd2200099999800000a00000aaa00a0000a00000aaa00a000000000000000000000000111a1111111a1111111a1111111aa11100000000
0004000000000900000220000899988000000900000a000000000900000a0000000000000000000000000000111aa111111a1111111a1111111a111100000000
0000000000000999000000000888888000000000000000000000000000000000000000000000000000000000111a11111119a111111911111119a11100000000
000000000000000000000000008888000000000000000000000000000000000000000000000000000000000011d9ad1111dddd11111dd11111dddd1100000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111119aa9111117a111119aa91100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000119aa91119a7aa9111aaaa1119a7aa9100000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000019a7aa911a7aaaa111a7aa111a7aaaa100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001a7aaaa11aaaaaa111aaaa111aaaaaa100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001aaaaaa119aaaa91119aa91119aaaa9100000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000019aaaa91119aa91111199111119aa91100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d9aa9d111111111111111111111111100000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011dddd1111dddd11111dd11111dddd1100000000
000f0000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077770000f00000777700000000000007777000000000000777700000000000000000000000000000000000000000000000000000000000000000000000000
0003f3f0000777700f3f300007777000003f3f990077770099f3f300007777000000000000000000000000000000000000000000000000000000000000000000
000777990003f3f0997770000f3f30b000777fa9003f3f999af7770099f3f3000000000000000000000000000000000000000000000000000000000000000000
b00f7fa9000777999af7f00b9977700b9ff7ff9a00777fa9a9ff7ff99af777000000000000000000000000000000000000000000000000000000000000000000
b00fff9a0b0fffa9a9fff00b9af7fbb300ffff999ff7ffba99ffff00abff7ff90000000000040000004000000000040000004000000000000000000000000000
3bbb3b99b03fff9a99b3fbb3a9b3fb30003bb30b00ffff3b30bb3b00b3ffff000000000004044044404444400444440444044040000000000000000000000000
033bb3303b3b3b9903bb9b3099bb93000033bb30003bb3b303b3b3003b3bb3000000000044444444444444444444444444444444000000000000000000000000
0000000000000000000000000000000000000e0000000e0000000e00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000e2200000e2200000e220000000000000000000000000000000000000000000000000000000000000000000000000
000a8000000a0000000aa0000006d000000a0200000a9200000aa200000000000000000000000000000000000000000000000000000000000000000000000000
00a8820000aa900000000a00006dd20000aa900000a9980000000a00000000000000000000000000000000000000000000000000000000000000000000000000
00888200000400000000a00000dd220000040000009988000000a000000000000000000000000000000000000000000000000000000000000000000000000000
00082000000400000000090000022000000400000008800000000900000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000104081080200000000000000004000000400000000000000000020002000200020000000002100000000200020004040000000000001000000000000002020202020202020202020200000000020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000040404040000000000000000000000000000000000000000000000000000000008080808000000000000000000000000004040404000000000000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000100300e0200b0200601001000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001601016020170301a0301f040240502c06032010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000100401204015040170401c0401f0401204016040180401a0401c0401e040200401004012040140401604019040150401a050200502e0501a0001d00012000130000d00011000130001a0001500020000
00020000121301b130201402f15029130211201811011120291100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000d62010120181202b2201a220102200760005600046000c6000c60008600044000b400004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000241501815014140121400f1400e1300c1300a120071200512003120021200111000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000003750037500575007750097500c7500e750107500d70016750177001270022750177001f7001b7002b7502270015700147001470013700167001a7001c7001c7001f7001870022700157002670015700
00020000067100a7100d72001700000000000000000000000c7000000015700087000470002700017000000000000000000670009700000000000000000000000000000000000000000000000000000000000000
000300000901010010000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000471009720007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000019150101400c1400802005010050100210000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001b050140500c0500f050190501e050210501c05018050130500c050060500205000000030500000006050000000a050000000c050000000e05009050060500305009050011500000006000010000e000
000500000655103331017210265101611016000160007600016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000571005710077200c73005700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000400001c12023540285502454023530290402d0500a500085000750006500045000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00080000181401314001030010301a040200500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000b01014020260201a03030030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000705004050020500105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000027100271002710037100372004720057200672006720067200772008720097300a7300a7300b7300b7300b7300c7300c7400d7400e7500f7500f7500f7501075011760127601476016760177601c770
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
