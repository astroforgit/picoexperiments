pico-8 cartridge // http://www.pico-8.com
version 11
__lua__
-- rey's scavenger run
-- a game by tassilo
-- graphics, code and sound
-- by tassilo
-- music by chris d. (@gruber_music)

-- this is a non-commercial
-- fan-project and not to be
-- sold or rented
-- rey is probably a tm of disney
	highscores={}
	highscorenames={}
	--cartdata("reys_scavanger_run")
	if not cartdata("reys_scavanger_run") then
		highscores={200,180,160,140,120,100,80,60,40,20}
		highscorenames[1]={20,1,19}
		highscorenames[2]={2,9,12}
		highscorenames[3]={14,15,1}
		highscorenames[4]={19,1,18}
		highscorenames[5]={3,18,4}
		highscorenames[6]={2,21,13}
		highscorenames[7]={2,12,5}
		highscorenames[8]={2,5,5}
		highscorenames[9]={18,5,25}
		highscorenames[10]={11,25,12}
	end

function _init()
 characters={"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9","0","_","-"}
	highscore=dget(0)
	highscoretimer=0
	resethighscores()
	for i=1,10 do
		highscores[i]=dget(i)
		highscorenames[i]={}
		for j=1,3 do
			highscorenames[i][j]=dget(7+(i*3)+j)
		end
	end
	music(0)
	version="1.21"
	-- player
	playerx=10
	playery=80
	flamesprite1=000
	flamesprite2=016
	playername={1,1,1}	
	score=0
	scorefound=0
	lives=3
	map1x=0
	map2x=0
	map3x=0
	map4x=0
	map5x=0
	map0x=0
	bounce=0
	bounceupdate=0
	-- mode 0=game, 1=titlescreen
	-- 2=scoring, 3=instructions
	-- 4=game over, 5=highscores
	-- 6=enter highscores
	mode=1
	spritestotal=0
	upboundary=60
	downboundary=95
	leftboundary=0
	rightboundary=104
	speed=1.5
	speedback=3
	objects={}
	enemies={}
	gain={}
	enemychance=1
	vaporizer=300
	level=1
	timer=1
	junk=0
	explosiontime=0
	smoke = {}
	cursorx = 50
	cursory = 50
	musicplaying=0
	sfxplayed=0
	blinktimer=0
	loadtitle()
	logoposy=1
	logoposition={-30,-28,-26,-24,-22,-20,-18,-16,-14,-12,-10,-8,-6,-5,-4,-3,-4,-5,-5,-6,-6,-6,-5,-5,-4,-4,-3,-3,-3,-4,-4,-5}
end

function resethighscores()
	if dget(0)==0 then
		highscores={200,180,160,140,120,100,80,60,40,20}
		highscorenames[1]={18,5,25}
		highscorenames[2]={20,1,19}
		highscorenames[3]={3,18,4}
		highscorenames[4]={14,15,1}
		highscorenames[5]={19,1,18}
		highscorenames[6]={2,9,12}
		highscorenames[7]={2,21,13}
		highscorenames[8]={2,12,5}
		highscorenames[9]={2,5,5}
		highscorenames[10]={11,25,12}
		for i=1,10 do
			dset(i,highscores[i])
			for j=1,3 do
				dset(7+(i*3)+j,highscorenames[i][j])
			end
		end
	end
	dset(0,1)
end

function printf(string,x,y,width,alignment)
	if alignment == "center" then
		print(string,x+(width*#string)/2,y)
	elseif alignment == "right" then
		print(string,x+width-4*#string,y)
	else
		printh("invalid argument")
	end
end

function spawnobject()
	local object={}
	object.id=flr(rnd(6))+58
	object.x=128
	object.y=flr(rnd(37))+66
	add(objects,object)
end

function spawngain()
	local gainsprite={}
	gainsprite.id=030
	gainsprite.x=playerx+10
	gainsprite.y=playery-4
	gainsprite.init=playery-4
	add(gain,gainsprite)
end

function spawnenemy()
	local enemy={}
	i=flr(rnd(3))
	if i==0 then
		enemy.id=077
	elseif i==1 then
		enemy.id=93
	elseif i==2 then
		enemy.id=54
	end
	enemy.x=128
	enemy.y=flr(rnd(37))+66
	add(enemies,enemy)
end

function make_smoke(x,y,init_size,col)
	local s = {}
	s.x=x
	s.y=y
	s.col=col
	s.width = init_size
	s.width_final = init_size + rnd(3)+1
	s.t=0
	s.max_t = 30+rnd(10)
	s.dx = -(rnd(3)*.4)
	s.dy = rnd(.05)
	s.ddy = -.01
	add(smoke,s)
	return s
end

function move_smoke(sp)
	if (sp.t > sp.max_t) then
		del(smoke,sp)
	end
	if (sp.t > sp.max_t) then
		sp.width +=1
		sp.width = min(sp.width,sp.width_final)
	end
	sp.x = sp.x + sp.dx
	sp.y = sp.y + sp.dy
	sp.dy= sp.dy+ sp.ddy
	sp.t = sp.t + 1
end

function draw_smoke(s)
	circfill(s.x, s.y,s.width, s.col)
end

function drawobjects(object)
	spr(object.id,object.x,object.y)
end

function drawgain(gainsprite)	
	spr(gainsprite.id,gainsprite.x,gainsprite.y)
end

function drawenemies(enemy)
	spr(enemy.id,enemy.x,enemy.y)
	spr(enemy.id+1,enemy.x+8,enemy.y)
	spr(enemy.id+2,enemy.x+16,enemy.y)
	-- draw the enemies shadow
	if enemy.id!=54 then
		for i=0,2 do
			spr(64+i,-2+enemy.x+i*8,enemy.y+5)
		end
	end
end

function moveobjects(object)
	if object.x<-4 then
		del(objects,object)
	else
		if object.y>90 then
			object.x-=2.5
		elseif object.y>80 then
			object.x-=2
		else
			object.x-=1.5
		end
	end
end

function movegain(gainsprite)
	if gainsprite.y<gainsprite.init-8 then
		del(gain,gainsprite)
	else
		gainsprite.y-=1
	end
end


function moveenemies(enemy)
	if enemy.id!=54 then
		if enemy.x<=-22 then
			del(enemies,enemy)
		else
			if enemy.y>90 then
				enemy.x-=3
			elseif enemy.y>80 then
				enemy.x-=2.5
			else
				enemy.x-=2
			end
		end
	else
			if enemy.x<=-22 then
			del(enemies,enemy)
		else
			if enemy.y>90 then
				enemy.x-=2.5
			elseif enemy.y>80 then
				enemy.x-=2
			else
				enemy.x-=1.5
			end
		end
	end
end


function junkcollect()
 for a2 in all(objects) do
   local x=playerx - a2.x
   local y=playery - a2.y
   if ((abs(x) < 28) and
      (abs(y+4) < 8))
   then 
   		del(objects,a2)
   		sfx(1)
   		junk+=1
   		spawngain()
     return true 
   end
 end
 return false
end

function collision()
 for a2 in all(enemies) do
   local x=playerx - a2.x
   local y=playery - a2.y
   if ((abs(x) < 28) and
      (abs(y+4) < 8))
   then 
   		del(enemies,a2)
   		lives-=1
   		sfx(0)
   		if lives<0 then
   			mode=4
   		end
   		explosiontime=1
     return true 
   end
 end
 return false
end

function explosion()
	if explosiontime>66 then
		spr(108,playerx+12,playery+4)
	elseif explosiontime>33 then
		spr(67,playerx+8,playery)
		spr(68,playerx+16,playery)
		spr(80,playerx+8,playery+8)
		spr(81,playerx+16,playery+8)
	else
		spr(76,playerx+8,playery)
		spr(92,playerx+16,playery)
		spr(72,playerx+8,playery+8)
		spr(125,playerx+16,playery+8)
	
	end
	explosiontime+=5
	if explosiontime>100 then
		explosiontime=0
	end
end

function moveplayer()
	-- links
	if btn(0) and playerx>leftboundary then
	-- links und hoch
		if btn(2) and playery>upboundary then
			playerx-=speedback
			playery-=speed
	-- links und runter
		elseif btn(3) and playery<downboundary then
			playery+=speed
			playerx-=speedback
		else
			playerx-=speedback
		end
	-- rechts
	elseif btn(1) and playerx<rightboundary then
	-- rechts und hoch
		if btn(2) and playery>upboundary then
			playery-=speed
			playerx+=speed
	-- rechts und runter
		elseif btn(3) and playery<downboundary then
			playery+=speed
			playerx+=speed
		else
			playerx+=speed
		end
	-- hoch
	elseif btn(2) and playery>upboundary then
		playery-=speed
 -- runter
	elseif btn(3) and playery<downboundary then
		playery+=speed
	end
end

function drawintro()
	reload(0x0000,0x0000,0x1fff)
	if musicplaying==0 then
		music(15)
		musicplaying=1
	end
	sfx(3, 3)
	rectfill(0,8,128,128,12)
	rectfill(0,0,128,8,1)
	--	for y=7,15 do
	--		for x=0,15 do
	--			spr(112,x*8,y*8)
	--		end
	--	end
	sspr(96,0,24,8,0,56)
	sspr(96,0,24,8,104,56)
	sspr(48,0,48,16,0,64)
	sspr(48,8,48,16,0,72)
	sspr(56,8,48,16,0,80)
	sspr(64,8,48,16,0,88)
	sspr(48,8,48,16,0,96)
	sspr(56,8,48,16,0,104)
	sspr(64,8,48,16,0,112)
	sspr(48,8,48,16,0,120)
	sspr(48,0,48,16,80,64)
	sspr(48,8,48,16,80,72)
	sspr(56,8,48,16,80,80)
	sspr(64,8,48,16,80,88)
	sspr(48,8,48,16,80,96)
	sspr(56,8,48,16,80,104)
	sspr(64,8,48,16,80,112)
	sspr(48,8,48,16,80,120)
	sspr(56,8,48,16,40,80)
	sspr(64,8,48,16,40,88)
	sspr(48,8,48,16,40,96)
	sspr(56,8,48,16,40,104)
	sspr(64,8,48,16,40,112)
	sspr(48,8,48,16,40,120)
	sspr(48,16,32,8,0,8)
	sspr(48,16,32,8,32,8)
	sspr(48,16,32,8,64,8)
	sspr(48,16,32,8,96,8)
drawvaporizer(94,20)
	rectfill(70,80,128,128,4)
	for y=1,5 do
		spr(21,66,82+y*8)
		pset(86,90+y*8,2)
		pset(90+y*8,86,2)
--		spr(112,82,82+y*8)
	end
	rect(65,78,128,128,0)
	line(70,79,128,79,15)
	line(90,88,128,88,2)
	line(88,90,88,128,2)
	rectfill(90,90,128,128,0)
	rectfill(17,9,109,91,5)
	rectfill(18,10,108,90,7)
	for i=1,6 do
		line(90+i,91,100,100,7)
	end
		pset(17,9,12)
		pset(109,9,12)
		pset(17,91,9)
		pset(109,91,0)
		line(91,91,100,100,6)
		line(97,91,100,100,6)
		map(0,18,96,98,4,4)
		rectfill(124,110,128,118,0)
		print("'so you are looking",20,13,0)
		print("for cash? get me some",20,19,0)
		print("junk from the desert!",20,25,0)
		print("collect these:",20,36,0)
		for i=0,5 do
			spr(i+58,20+((i*8+i*7)),43)
		end
		print("avoid these:",20,59,0)
		for i=0,2 do
			spr(i+077,20+((i*8)),66)
			spr(i+093,53+((i*8)),66)
			spr(i+054,86+((i*8)),66)
		end
		print("press x to continue!",22,82,0)
--		print("to continue!",24,86,0)
		--print("highscore: "..highscore,38,110,10)
end

function drawcredits()
	cls(0)
	palt(0,true)
	palt(12,false)
	sspr(0,0,128,128,0,0)

	displaylogo(0,logoposition[logoposy])
	if logoposy<#logoposition then logoposy+=1 end
	if logoposy>15 then
		print("a game by @tassilorau",22,101,0)
		print("a game by @tassilorau",23,101,0)
		print("a game by @tassilorau",24,101,0)
		print("a game by @tassilorau",23,99,0)
		print("a game by @tassilorau",24,99,0)
		print("a game by @tassilorau",24,100,0)
		print("a game by @tassilorau",23,100,7)
	end
	if logoposy>24 then
		print("music by @grubermusic",22,110,0)
		print("music by @grubermusic",23,110,0)
		print("music by @grubermusic",24,110,0)
		print("music by @grubermusic",23,108,0)
		print("music by @grubermusic",24,108,0)
		print("music by @grubermusic",24,109,0)
		print("music by @grubermusic",23,109,7)	
	end

--		sfx(3, 3)
--		rectfill(0,0,128,128,0)
--		map(82,0,0,0,16,16)
--		print("graphics,code",65,48,6)
--		print("and sound",73,55,6)
--		spr(57,53,61)
--		spr(21,76,57)
--		print("2016",62,62)
--		print("@tassilorau",81,62,7)
--		print("music by",75,73,6)
--		spr(57,49,79)
--		print("2016",58,80)
--		print("@gruber_music",76,80,7)
--		print("non-commercial",66,98,5)
--		print("fan-project",71,105,5)
--		print(version,84,35,5)
		blinktimer+=.5
		if blinktimer>20 then
			print("press Ž to play",37,121,0)
			print("press Ž to play",39,121,0)
			print("press Ž to play",38,120,10)				
			if blinktimer>40 then
				blinktimer=0
			end
		end
end

function displaylogo(x,y)
	rectfill(x,y+13,x+129,y+27,0)
	rectfill(x,y+13,x+128,y+25,7)
	rectfill(x,y+14,x+127,y+24,4)
	rectfill(x,y+17,x+10,y+19,2)
	rectfill(x+10,y+17,x+16,y+18,2)
	rectfill(x+116,y+20,x+127,y+21,2)
	rectfill(x+111,y+21,x+127,y+21,2)
	rectfill(x+108,y+23,x+128,y+23,2)
	pset(x+105,y+18,2)
	pset(x+120,y+16,2)
	pset(x+15,y+23,2)


	print("rey's scavenger run",x+25,y+18,2)
	print("rey's scavenger run",x+26,y+18,2)
	print("rey's scavenger run",x+27,y+18,2)
	print("rey's scavenger run",x+25,y+16,2)
	print("rey's scavenger run",x+26,y+16,2)
	print("rey's scavenger run",x+27,y+16,2)
	print("rey's scavenger run",x+26,y+17,7)	
end

function drawhighscore()
	cls()
	--map(89,1,30,5,9,3)
	displaylogo(0,-5)
	rectfill(0,26,128,32,7)
	print("h i g h s c o r e s",28,27,0)
	for i=1,10 do
		print(highscores[i],100,35+i*8,5+i)
		for j=1,3 do
			print(characters[highscorenames[i][j]],10+(j*4),35+i*8,5+i)
		end
	end
end

function enterhighscore()
	cls()
	if scorefound==0 then
		buttontimer=0
		char=1
		compare=10
		--find the first higher slot
		while score>highscores[compare] and compare>1 and scorefound==0 do
		 compare-=1
		end
		--if not the last slot, move others down
		if compare+1<10 and score<=highscores[1] then	
			for i=10,compare+2,-1 do
				highscores[i]=highscores[i-1]
				for j=1,3 do
					highscorenames[i][j]=highscorenames[i-1][j]
				end
			end
		end
		if compare+1<10 and score>highscores[1] then	
			for i=10,compare+1,-1 do
				highscores[i]=highscores[i-1]
				for j=1,3 do
					highscorenames[i][j]=highscorenames[i-1][j]
				end
			end
			compare-=1
		end
		--enter the new highscore
			highscores[compare+1]=score
			highscorenames[compare+1]=playername
	scorefound=1
	end
--	map(89,1,30,5,9,3)
		displaylogo(0,-5)
	print("-- n e w   h i g h s c o r e --",5,32,10)
	for i=1,10 do
		print(highscores[i],100,35+i*8,5+i)
		for j=1,3 do
			print(characters[highscorenames[i][j]],10+(j*4),35+i*8,5+i)
		end
	end
	--while char<4 do

		if buttontimer<20 then buttontimer+=1 end
		namecursor(compare+1,char)
		for i=1,10 do
			print(highscores[i],100,35+i*8,5+i)
			for j=1,3 do
				print(characters[highscorenames[i][j]],10+(j*4),35+i*8,5+i)
			end
		end
		if btn(0) and buttontimer>6 and char>1 then
			sfx(60)
			char-=1
			buttontimer=0
		end
		if btn(1) and buttontimer>6 and char<3 then
			sfx(60)
			char+=1
			buttontimer=0
		end
		if btn(3) and buttontimer>6 and highscorenames[compare+1][char]>1 then
			sfx(60)
			highscorenames[compare+1][char]-=1
			buttontimer=0
		end
		if btn(2) and buttontimer>6 and highscorenames[compare+1][char]<#characters then
			sfx(60)
			highscorenames[compare+1][char]+=1
			buttontimer=0
		end
if btn(4) or btn(5) and buttontimer>6 then
		for i=1,10 do
			dset(i,highscores[i])
			for j=1,3 do
				dset(7+(i*3)+j,highscorenames[i][j])
			end
		end
		sfx(44)
	mode=1
	musicplaying=0
	_init()
end
	--end

end

function namecursor(row,letter)
	blinktimer+=1
	if blinktimer>15 then
		rectfill(9+(letter*4),34+((row)*8),13+(letter*4),40+((row)*8),2)		
	end
	if blinktimer>30 then blinktimer=0 end
end

function drawclouds()
end

function drawvaporizer(x,y)
	sspr(8,58,16,6,x+12,y)
	sspr(0,56,8,8,x+16,y+6,8,24)
	sspr(0,64,8,24,x+16,y+30)
	sspr(16,64,16,16,x+12,y+38)
	sspr(16,72,16,8,x+12,y+54)
	sspr(8,64,8,24,x+4,y+38,8,24,true,false)
	sspr(8,64,8,24,x+28,y+38)
	spr(129,x+12+(x/16),y+38)
	sspr(8,80,8,8,x+12+(x/16),y+46,8,16)
end

function gameover()
	sfx(3, 3)
			if score==0 and junk>0 then
				score=junk
			end
			--rectfill(0,0,128,128,0)
			rectfill(19,29,109,101,6)
			rectfill(20,30,108,100,0)
			map(0,18,76,68,4,4)
			print("you blew it!",24,34,7)
			print("game over",24,41,8)
			print("your score:",24,55,7)
			print(score,24,62,9)
			if score>highscores[10] then
--				dset(0,score)
				print("new highscore!",24,72,8)
				print("press 'x'",30,82,7)
				print("to enter!",30,89,7)
			else
				print("press 'x'",30,82,7)
				print("to restart!",24,89,7)
			end
			for i=1,100000 do
			end
			if btnp(5) then
				if score>highscores[10] then
					mode=6
					sfx(44)
				else
					mode=1
					musicplaying=0
					sfx(44)
					_init()
				end
			end
end

function _update60()
	if mode==0 then
		moveplayer()
		foreach(smoke, move_smoke)
		make_smoke(playerx+4,playery+8,rnd(3),6)
		map0x-=2.5
		map1x-=2
		map2x-=1.5
		map3x-=1
		map4x-=0.5
		map5x-=0.2
		vaporizer-=3
		if vaporizer<-100 then vaporizer=300+rnd(200) end
		if map0x<-192 then
			map0x=0
		end
		if map1x<-192 then
			map1x=0
		end
		if map2x<-192 then
			map2x=0
			timer+=1
			if timer>16 then
				mode=2
			end
		end
		if map3x<-192 then
			map3x=0
		end
		if map4x<-512 then
			map4x=0
		end
		if map5x<-512 then
			map5x=0
		end
	end
end

function drawgame()
	sfx(2, 3)
	-- clear the screen
	rectfill(0,0,128,128,0)
	print(explosiontime,0,0)
	palt(12,true)
	rectfill(0,16,128,70,12)
	--drawclouds()
	map(0,22,map5x/2,16,128,8)
	-- layer5
	map(0,0,map5x,16,128,2)
	-- layer4
	map(0,2,map4x,32,128,6)
	-- layer3
	map(0,6,map3x,64,64,1)
	-- layer2
	map(0,7,map2x,72,64,2)
	-- layer1
	map(0,10,map1x,88,64,2)
	-- layer0
	map(0,10,flr(map0x),96,64,2)
	palt(12,false)
	
	-- draw the players shadow
	for i=0,2 do
		spr(64+i,playerx+i*8,playery+8)
	end

	-- draw the objects
	foreach(objects,moveobjects)
	foreach(objects,drawobjects)
		
	-- draw the enemies
	foreach(enemies,moveenemies)
	foreach(enemies,drawenemies)

	foreach(smoke, draw_smoke)
		
	-- draw the player
	if bounceupdate<=4 then
		bounceupdate+=1
	elseif bounceupdate>=4 then
		bounceupdate=0
		if bounce==0 then
			bounce=1
		elseif bounce==1 then
			bounce=0
		end
	end
	if flamesprite1==000 then
		flamesprite1=003
	elseif flamesprite1==003 then
		flamesprite1=004
	elseif flamesprite1==004 then
		flamesprite1=000
	end
	spr(flamesprite1,playerx,playery+4-bounce)
	spr(001,playerx+8,playery-bounce)
	spr(002,playerx+16,playery-bounce)
	--spr(flamesprite2,playerx,playery+8-bounce)
	spr(017,playerx+8,playery+8-bounce)
	spr(018,playerx+16,playery+8-bounce)
	-- draw the gain
	foreach(gain,movegain)
	foreach(gain,drawgain)

	-- draw vaporizer
	drawvaporizer(vaporizer,50)

	-- draw the ui
	for y=0,1 do
		for x=0,5 do
			sspr(80,16,32,8,(x*32)-y*8,y*8)
		end
	end
	
	for y=0,1 do
		for x=0,5 do
			sspr(80,16,32,8,(x*32)-y*8,(y*8)+110)
		end
	end
	line(0,110,128,110,9)
	line(0,109,128,109,0)
	
	-- distance
	rect(-2,114,130,124,9)
	rect(-2,113,130,123,2)
	rectfill(0,114,128,123,0)
	
	line(0,15,128,15,2)
	line(0,16,128,16,0)
	-- lives
	rect(5,3,30,12,9)
	rect(6,2,31,11,2)
	rectfill(6,3,30,11,0)
	-- score
	rect(35,3,80,12,9)
	rect(36,2,81,11,2)
	rectfill(36,3,80,11,0)
	-- junk
	rect(85,3,122,12,9)
	rect(86,2,123,11,2)
	rectfill(86,3,122,11,0)
	
		-- distance
	map(timer,16,0+(timer*8),115,16-timer,1)
	map(0,17,0,115,timer,1)
			
	-- draw the junk
	print("junk: ",89,5,15)
	print(junk,113,5,15)

	-- draw the score
	print("score: ",39,5,15)
	print(score,67,5,15)
	
	-- draw the lives
	--for i=1,lives do
	spr(005,8,3)
	print("x",19,5,15)
	print(lives,25,5,15)
	--end
		

	-- spawn an object
	i=flr(rnd(100))
	if i>=95 then
		spawnobject()
	end

	--spawn an enemy
	i=flr(rnd(100))
	if i>=(100-enemychance) then
		spawnenemy()
	end

	junkcollect()
	collision()
	if explosiontime>0 then
		explosion()
	end
end


function _draw()
highscoretimer+=1
if highscoretimer>400 then
highscoretimer=0
end
	if mode==0 then
		drawgame()
	elseif mode==1 then
	if highscoretimer>200 then
		drawhighscore()
	else
		drawcredits()
	end
		if btnp(5) then
			mode=3
			sfx(44)
		end
-- auswertung
	elseif mode==2 then
		sfx(3, 3)
		if sfxplayed==0 then
			sfx(50)
			sfxplayed=1
		end
		rectfill(19,29,109,101,6)
		rectfill(20,30,108,100,0)
		map(0,18,76,68,4,4)
		if junk>30 then
			print("'well done!",24,34,7)
			print(junk .." pieces! take",24,41,7)
			print("these spare parts",24,48,7)
			print("for your speeder!'",24,55,7)
			print("press 'x'",30,69,7)
			print("to continue!",24,76,7)
		elseif junk>20 then
			print("'hmph, "..junk .." pieces.",24,34,7)
			print("not your best day.",24,41,7)
			print("keep going, here's",24,48,7)
			print("your ration.'",24,55,7)
			print("press 'x'",30,69,7)
			print("to continue!",24,76,7)
		else
			print("'you worthless scum!",24,34,7)
			print("only "..junk .." pieces?",24,41,7)
			print("i will take your",24,48,7)
			print("speeder instead!'",24,55,7)
			print("press 'x'",30,69,7)
			print("to continue!",24,76,7)
		end
		--for i=1,100000 do
		--end
		if btnp(5) then
			if junk<21 then
				lives-=1
			elseif junk>30 then
				lives+=1
			end
			sfxplayed=0
			mode=0
			sfx(44)
			if lives<0 then
				-- game over
				mode=4
			end
			score+=junk
			junk=0
			timer=0
			level+=1
			enemychance+=1
		end
		-- instructions
	elseif mode==3 then
		drawintro()
		if btnp(5) then
			mode=0
			sfx(44)
		end
		-- game over
	elseif mode==4 then
			gameover()
			if musicplaying==1 then
			music(28)
			musicplaying=0
			end
	elseif mode==5 then
		drawhighscore()
	elseif mode==6 then
		enterhighscore()		
	end
end

function loadtitle()
	titleline={}
	titleline[1]="ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000020000005005000000000000000000000000755555556566"
	titleline[2]="dddddddddddddddddddddddddddddddddddcdcddddddddddddddddddddddddddddddddddddd00000200000005000050000000000000000000000755505555656"
	titleline[3]="dddddddddddddddddddddddddddddcdddddcccdddddddddddddddddddddddccccddddddddd200000200000000000000000000000000000000000755505555566"
	titleline[4]="ddddddccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2000002000000000050000000000000000000000000755505555656"
titleline[5]="cdddddddddddddddddddcccccdddddddddddddddddddddddddddddccccddddddddddccddc2000002000000000000005000000000000000000000755505556566"
titleline[6]="cccdddddddddddddddccdddccccccccccccdddddddccccddddddddddddddccddddddddddd2000020000000000000000000000000000000000000755505555656"
titleline[7]="ccccccccddddccccccddddddddddcccccccccdccccdddddddddddddddddddddddddcccccd0200020000000000000000000002000000022200000755505555566"
titleline[8]="dddddccccccddddddddddddddddddcccccccccccccccccccccccccddddddddcccccccccdd0020020000000200000005000000220000224422222755505555656"
titleline[9]="dddccccccccccccccccccccccccccdddddcdccccccccccccccddddcccccccccccccccdddd0000200000000220000004220020022222442222222755505556566"
titleline[10]="cccccccccccccccccccccccccdddddddddccccdddddccddccccdddddddccddddddddcccc20000000000000020002222222222224442224222442755505555656"
titleline[11]="cccddddcccddccccccccddddddddcccccccccccccccccccdddcccccccccddccccccddddc20000000000000002444444499994444492222444422755505555566"
titleline[12]="cddcccccccccccccccccccccccccccccdddcccccccddcccccccccccdddcccccccccccdddd2200000000000000249999994444949994444442299755505555656"
titleline[13]="cccccccccccccccddcddddcccccccccccccccccccccccccddccccccccccccccdddccccccc0000000000000000244999999999999994999444449755505556566"
titleline[14]="ccccccccddddddcccccccccccccccccccccddcccccccccccccccccccccccccccccccccccd0000000000000004424449999999999999999999994755505555656"
titleline[15]="ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2000000000002049992244999999999999999999999755505555566"
titleline[16]="ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2000000000002049999924444499999999999999999755505555656"
titleline[17]="ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccdc200000000002099999999999999999999999999999755555556566"
titleline[18]="dcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000002499999999999999999999999999999955555555656"
titleline[19]="666666dddcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000002499999999999999f9f9f9f9f9f9f9f9f5755555566"
titleline[20]="ccccccdcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddd00000200002499999999999f9f9f9f9f9f9f9f9f9f95755555656"
titleline[21]="cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2000200009499999999f9f9f9f9f9f9f9f9f9f9ff57555556566"
titleline[22]="cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccddcc20020000949999999f9f9f9f9fffffffffffffff75555555656"
titleline[23]="ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc2002000094449999f9f9f9fffffffffffffffffd55555555566"
titleline[24]="ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc200444409924999f9f9f9ffffffffffffffffff544555555656"
titleline[25]="ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00002004499249f9f9fffffffffffffffffffff544555556566"
titleline[26]="cccccccccccccccccccd6dcccccccccccccccccccccccccccccccccccccccccccccccccccccc2000022009492244f9ffffffffffffffffffffff144555555656"
titleline[27]="cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc20000002099449244fffffffffffffffffffffff000000000000"
titleline[28]="cccccccccccccccccccccccccccddd66666666666666666ddccc6dcccccccccccccccdd6dccc02000000449944fffffffffffffffffffffffff0000000000000"
titleline[29]="cccccccccccccccccccccccccccccccccccccddd666666ddddddd6ddddccccccccccddd6ddc000000000944994fffffffffffffffffffffff777755555555555"
titleline[30]="ccccccccccccccccccccccccccccccccccccccdddddddd66666666ddccccccccccccccccccc20000000999249ffffffffffffffffffffffff555000555556665"
titleline[31]="cccccccc66dccccccccccccccccccccccccd6ccccccccccccccccccccccddccccccdddddcccc20000009949944ffffffffffffffffffffffff55500075556666"
titleline[32]="ccccccccccccccddd6666666666666ddcccc6dccccccccccccccccccccccccccccccccccccccc200000999499444ffffffffffffffffffffff55000075555666"
titleline[33]="ccccccccccccccccccccccdd6666dcccccccccccccccccccccccccccccccccccccccccccccccc0000009994ffff4444ffffffffffffffffffff5000755555566"
titleline[34]="cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc555ccccccccccccccc000099999499ffffff4ffffffffff9ffffffff577555555566"
titleline[35]="ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc56665ccccccccc4440000009999994fffff44ff99fffffffffffffff1000000000000"
titleline[36]="ccccccccccccccccccccccccccccccccdddd66dddcccccccccccccccccc56665ccccccc64fff40000099999994f9f4fffff99ffffff9f9fff056566655666666"
titleline[37]="ccccccccdcccccccccccccccccccccccccccdd66666666dddccccd6655c56665cccccc64f49f90000099999999444fffffff9fffffff9ffff055555555555665"
titleline[38]="ccccccccccccccccccccccccccccccccccccccccccccccdccccccc556655555cccccccd4f449900009999444444444499fff99fffff999fff050055555555666"
titleline[39]="ccccccccccccccccccccccccccccccccccccccccccccccccccccc566556655ccd50666c4f44440000999994422222244499999ffffff99fffffff55555555656"
titleline[40]="cccccccccccccccccccccccccccccccccccccccccccccccccccc5655665566555650cccc4944000099999999444444222444999fffff9fffffff666666666666"
titleline[41]="cccccccccccccccccccccccccccccccccccccccccccccccccccc06565566556655650ccc4f44000099999999999994442222444999fffffffff0550005555000"
titleline[42]="cccccccccccccccccccccccccccc55ccccccccccccccccccccccc06666556655665650cc4f940000999999999999999994442224499ffffff005500565550056"
titleline[43]="cccccccccccccccccccccccccc55665555ccccccccccccccccccc06666665566556565cc4f9400409999994999442222449944444949fffff005500565550056"
titleline[44]="ccccccccd666dccccccccccc55666666665555cccccccccccccccc0666666655665056ccc4f4402244999942442200000002499999499ffff005500565550056"
titleline[45]="cccccccccdd6666ddccccc5566666666666666555ccccccccccccc0666666666556055ccc4f40000022499942200f2700220249999499fffff00550056550056"
titleline[46]="cccccccccccccccccccc5566666666666666666665555cccccccccc0666666666656055cccf0002220024999200f722447270024994999ffff00550056550056"
titleline[47]="cccccccccccccccccc556666665556666665666666666555cccccc006666666666560505cc404047f2202499994444422244440299949fffff00550056550056"
titleline[48]="cccccccccccccccc556666666666556666666666666666665555c0650666666665656050cc0f9447f44202499999999999999999999499ffff00550056550056"
titleline[49]="cccccccccccccc55666655566666666666666666666666666665065506666666566560505c0f4447f4492024999ffffffffff9f9f9949fffff00550056550056"
titleline[50]="cccccccc5ccc556666666665566666655666666666666665555550555066666566665605004f9447f449920249ffffffffffff9f999499ffff00550056550056"
titleline[51]="cccccccccc5566666666666666666666666666667666665555555555506666666666560500c4f447f44999204ffffffffffffff9999999fffff0055005655055"
titleline[52]="cccccccc55666666655666666666666666666566667775555566555555066666666665605cc4f947f449994024ffffffffffff99999999fffff0055005655005"
titleline[53]="cccccc5566666655666666666556666666666666666666665566665505006666666665605cc4f947f449999204fffffffffff9f9994999fffff0055005655005"
titleline[54]="cccc5566666655666666666555555556666666666666666655555556505500666666665655c4f947ff49999204ffffffffff9f99994999fffff0055005655005"
titleline[55]="cc55666666666655666655555555555555666666666666666556555655055500666666560504f9447f44999404fffffffff9f999999999fffff0055005655005"
titleline[56]="55666666665666666777775666655555555566666666666656565555555000000066666655cc49447f44999402ffffffffff999fff9999fffff0005005655005"
titleline[57]="66666666666666666666655666666665555555666666666565555555555500000c00666660cc49947f44999920fffffffff999fff9999fffffff005500565005"
titleline[58]="6666d66666666666666556666666666666555555666666565555555556555000cccc00660cccc4947ff44999209fffffffff99ff999999ffffff005500565005"
titleline[59]="666666666666666665555556666666666666555556666565655565555055550ccccccc00cccccc447ff44999209fffffffffffff94999fffffff005500565005"
titleline[60]="d6dd66d666666667777555555666666666666655555656565555556555055550ccccccccccddccc57ff44499404ffffffffffff9449999ffffffff4444444444"
titleline[61]="6dd666665666665566677555555dd66565656555555565655555555555505550ccccccddddcccccc17fff4999029ffffffffff9449999fffffff677656666666"
titleline[62]="6dd6d666d6666665556666655d555dd6ddd65dd65555565055055550555005550ddddddddddcccdc57ffff9992049fffffffff94f99999fffff6775555555555"
titleline[63]="dd6dd6dd66666d666d55ddd66d5d5d55dd6d6565ddd5555055505555050505550ccccccccdddcccd57fffff99902499ff9444ffffff99ffffff6655555555555"
titleline[64]="6ddddddddd56d6ddddd5d5dddd5ddd55d7d65dddd65505d5550505555055505500cdddddcccccccd57fffff99990244422ff9449ffffff77f777765566777675"
titleline[65]="ddddddddd555dddddd6dd5dddddddd7dd7ddddddddd5555505dd555550dd505500ddddddddddddccc57ffff9999942224ffff94449ffff7776f7555555556666"
titleline[66]="dddddddddd55d56d6d5ddddddddddd7d7dddddddddd55dd5555dd555dd05d550000dddddddddddddd5fffff9999fffffffffff99f444fffff6f7555555556666"
titleline[67]="ddddddddd6dddd5dddddddddddddd7dd7ddddddddddd555d555d5d555d05d50dddddddddddddddddd5fffff999ffffffffffff94f4224ffff6f7555555556666"
titleline[68]="dddddddddddddddddddddddddddd4747ddddddddddddddddddd5ddd555dddd0dd0dddddddddddddddd2ffff99ffffffffffffff944249f99f666666666666666"
titleline[69]="444ddddddddddddddddddd4444dddddd44444ddddddddddddddddddddddddddddddddddddddddddddd2ffff99fffffffffffffff99949ffff555555555555555"
titleline[70]="99944444ddddddddddd4449944776666dd9994444dddddddddddddddddddd4444444444ddddddddddd24ffff9ffffffffffffffff9949f7ff656555556565557"
titleline[71]="99999999444444444449999d6799677767d999999444444444ddddddddd449999999999444ddddddddd24fff9ffffffffffffffffff4ff7ff665655565655557"
titleline[72]="f9f9f999999999999999999677767000767d99f999999999994444444449999999999999994ddddddddd24ff99ffffffffffffffff49fffff666565556665557"
titleline[73]="9f9f9f9f9f9f999999999d6777670076076949999ff999f999999999999f9f9f9f9f9f9f999444dddddd244ff9fffff99ffffffff9fff99ff666655565655557"
titleline[74]="fffffff9f99999999999d677776707000767d9999fff9f9f9f9999999999f9f9f9f999999999994444444244999ffff99f77fffffff99999f566565556665557"
titleline[75]="fff999fffffff9999444d477776700000767d999999999999999999999999999999999944449999999999424999ffff9f77ffff9999999999566655565665557"
titleline[76]="fffffff444444449999d49997676700076776d9f9f99999999999999999999999999999999999999999994224999ffff77f4f999444499999566655556665557"
titleline[77]="44ff444444444444999d679976776777dd776d9999999999999999999999999999999999999999999999992424499fff7ff42444444444444566655566665557"
titleline[78]="ffffff99999999999ffdd6776666766d00d76d9999999999999999999999999999999999999999999f9f9f22244499fffffff4eeeeeeeeeee576665556665557"
titleline[79]="ffffffffffffffffffffd6d66777667d00d96dfffffff999999f9f9f9f99999999999999999999f9f9f9f9f244444499ffffff44e7e77777e576665566665557"
titleline[80]="ffffffffffffffffffdd6d66dd677766dd994dfffffffffffffff9f9f9f9f99999999999999f9f9ffffffff224444449ffffffff4eeeeeeee576665556665557"
titleline[81]="ff9f9f9f9f9f9fffdd7776dd666dd67767764d999999f9f9f9f9ffffff9f9f9f9999999f9fffffffffffffff24444499ffffffffffe777777677665566665557"
titleline[82]="f9f99999f999fffd79977699ddd666dd6766d999999f9f9f9ffffffffffffff9f99999999999f9f9fff9ff7f44444499ffffffff99fff9999667665556665557"
titleline[83]="99999999999999d799979996666ddd666ddd9999f9f9ffffffffffffffffffff9f9f99999999999f9f9f9f7f44244499ffffffffff9999999566665566765557"
titleline[84]="9999999999999d4999999996777666ddd4d9999f9f9ffffffffffffffffffffff9f9f9f999999999f9f9f77f4f2244499ffffffffffffffff577665556665557"
titleline[85]="ffffff999999d4999999996777777766999d99f9ffffffffffffffff9f9fffffffff9f9f999f9999999997f44ff2244499fffffffffffffff566665566665557"
titleline[86]="fffffffffffd666999996677777677699999d99ffffffffffffffff9f9ffff66fffff9f9f9f9f9f9f9997744ffff2244499ffffffffffffff666665566665557"
titleline[87]="99999f9f9f9d67766666777777777769999ddfffffffffffffffffffff9ff6666fffffff9f9f9f9f99997f4ffffff2244499fffffffffffff666665566655557"
titleline[88]="9999f9f9f9d6767776777777777777699999ddf9fffffffffffffffffffff9999ffffffffffffff9f9f7ff4ffffff92244499ffffffff7777677665566655557"
titleline[89]="9f9f9fffffd66776767767777777776999999d9ff9fff9f9f9ffffffffffffffffffffffffff9fffff77ff4ffffff992244499fffffff7777666665566655557"
titleline[90]="f9f9fffffd667777767777777777776999999dd9ff9f9f9f9f9f9f9ffffffffffffffffffffffffff77fff4ffffff9922244499ffffffffff566665577655556"
titleline[91]="fffffffffd676779999977777777776999dd6dd9f9f9f9f9f9f9f9f9fff9f9f9f9f9f9f9f9f9999977ffff44fffff9992222449999f999999566665566665556"
titleline[92]="fffffffffd667999999999777776776999d6d6d99999999f9f9f9f9f9f9f9f9f9f9f999f99999f977ffffff4ffffff9929929944499999449566665566655557"
titleline[93]="fffffffff56799999999999777777769999d6dd99999999999f9f9f9f9f999f999999f9999f99977fffffff4fffff99929922994444444444566665566665557"
titleline[94]="fffffffff5d9999666999999777776699996dd5999999999999999999f99f99999ffffff9999777ffffffff44fffff9922992999944444444566665566665557"
titleline[95]="ffffffff95649967799999996776666d99996d59fffffffff9999999999999999ffffff9ff7777fffff9f9f944fff99992999299999999999566655566665557"
titleline[96]="fffff9f9f5d996777999999996676666d9999459999fffffffffffff99fffffffffff9559777ffffff9f9f9f944fff9992999299999999999676665566665556"
titleline[97]="9f9f9f9f95649677779976999767666d6d9944599999999999999fffff99999999996555977ffffff9f9f9f9ff44f99992299299999999999666665566665556"
titleline[98]="f9f9999999544677777776999676666666ddd56999999999999999999999996666066555977fffffff9f999999ff4f9999299299999999999666665566665556"
titleline[99]="99999999995496997777769997666666d6d6d56f9999999999999999996655666656655597fffffff9f999999f9ff99999229299999ffffff666665566665556"
titleline[100]="f99999999994494997777699966666666d6d599f9999999999999996556656665656655597ffffff9f99999999ffff9999992999999ffffff667655567665556"
titleline[101]="999999999995449497776999966d6666d6dd59ff9999999999999566656656665656655597fff9f9f99999999f9ff9f99999922999fffffff666665566665556"
titleline[102]="99999999999954496666999966666d6d6dd59f9f999999999656656665565666565665559fff9f9f9999999999ffff999999992299fffffff566665566665556"
titleline[103]="999999999944454494949996d6d6d6d6dd5499f9999ff56666566566655656665656655559f9f9f9999999999f9ff9f99999999922fffffff566665566665556"
titleline[104]="99999999444444544949446d6d6d6dddd544449fffff6566666565566656566656566555599f9f999999999999ffff99999999999ffffffff666665566665556"
titleline[105]="999999444444444544445dd6d6dddddd54444449f666665666656656665655665655665555499ff9999999999f9ff9f999999999f9fffffff566665566665556"
titleline[106]="99999444444444445555d5dddddddd55444446665666665666655656665655666565665555499fffff99999999ffff9f999999999fff99999566665566665556"
titleline[107]="999944444444444444555d5d5d5d5544446666666666665666655556665655666665666555499999fffff999ff9ffff9f9999999f9f999999566665566665556"
titleline[108]="99994444444444444444444444444444456666666566665666655656665655666665566555544999999fffffffffffff9f99999f9ff999999956765566665556"
titleline[109]="99999444444444444444444444444446656666666566665566655655665655566666566655544449999999999ffffffff9f99999fff999999956665566665556"
titleline[110]="99999999444444444444444444444656665666666566666566655655665665566666555655554444444999999999ffffff9f9f9f9fff99999995665566665556"
titleline[111]="9999999999994444444444444446665666566666665666656666656566566556666665556555444444444444499f9ffffff9f9f9ffff99999995665444445556"
titleline[112]="99999999999999999999999966666656665566666556666556666565665665566565666555555494444444949999fffffffffffffffff999999f5444444499f6"
titleline[113]="999999999999999999999996666666656665666665566665566665665656665666665566555554494944444949999ffffffffffffffff9999994442244449f77"
titleline[114]="99999999999999999999999666666665666556666656666556665656566566566665555666555544949494949999f9ffffffffffffffff99994222224449fff7"
titleline[115]="999999999999999999999966666566656666566666556665566556565665665666565555666555544949499999999f9fffffffffffffff9992222222449fffff"
titleline[116]="9999999999999999999996666665666556665566665566565665565656656656666565655566555544999999999999f9fffffffffffffff924444422299fffff"
titleline[117]="f9999999999999999999666666655665566655666655665665665665656566566666665665566555549999999999999f9ffffffffffffff924444444499fffff"
titleline[118]="fffffff99999999999966666666656665666655666556656656656655566566556650665665566555544999999999999f9ffffffffffffff244444449999ffff"
titleline[119]="fffffffff9f9f9f9f96666666566656655666555666566566566556656555665566656655665566555554499999999999fffffffffffffff2244444499999fff"
titleline[120]="ffffffff9f9ffffff6666666665665566566665566655656665665665555566555666555556655665555554499999999f9f9fffffffffffff2224444444999ff"
titleline[121]="fffffffffff666ff55666666665566566556666566655655665665565555566655666655555665566555555549999999999f9f9fffffffffff22220000444999"
titleline[122]="ffffffffff9666ff455566666665566666556665566555656655655665565566655665055555565566555555544449999999f9f9fffffffffff0000000004449"
titleline[123]="ffffffffff9999f7944556666666556666556565556655655665655565566556655666565556556556655555555554444449999f9f9f9f222222222222000444"
titleline[124]="fffffffffffffff7994455666666655666655556655655555665565566556655655566666556655655665555555555555554449999f9f22222499999ff000004"
titleline[125]="ffffffffffffff77f999445566666655666556556655555656665655565566556655565650556655656665555555555555555544999922222449999fffffffff"
titleline[126]="ffffffffffffff7ffff994555666666556665566555555556566555556655665566556666505066555566655666655555555555544422222449999999fffffff"
titleline[127]="ffffffff9999997fffff994455566666555665556555555555565555566556665566556656505066565566655666666655555555555222244999999999999fff"
titleline[128]="ffffffff9999977ffffff99445555666655556556655555555566555556555565566655666650506556556665566666666655555555222244999999999999999"
	for y=1,128 do
		for x=1,128 do
			colvalue=sub(titleline[y],x,x)
			if colvalue=="a" then colvalue=10 end
			if colvalue=="b" then colvalue=11 end
			if colvalue=="c" then colvalue=12 end
			if colvalue=="d" then colvalue=13 end
			if colvalue=="e" then colvalue=14 end
			if colvalue=="f" then colvalue=15 end
			sset(x-1,y-1,colvalue)
		end
	end
	titleline=nil
end
__gfx__
000000110000220000000000000000110000001100000000dddd4444444dddddddddddddddddddddddddddddddddddddccccccccccccddcccccccccc00000000
000aa16400029920000000000899a164008a916400000000dd4499999994444dddddd4444444dddddddd444444444444cccccccccccdcccccccccddd00000000
0089a1d40029952000000000009aa1d40089a1d45555555044999fffff99999444444999999944444444999999999999cdddccccddddcdddcccccccc00000000
000000000299ff1000000000000000000000000056464445999ffff9f9ff99f9999ffff9f9f999999999999999999999cdccccddcdddccdddddccccc00555550
000000142299111111515000000000140000001405464445ffff9f9f9f99f999ffff9f9f9f99f9999999ffffff999999cccccccccccccccccddddddd00555550
899aa16492294444444445000089a164089a916456464445f9f9f99999999999f9f9f999999999999ffff9999999fff9ccdddccdccdddddcccdddddc00000000
0889a1d229924422222442500899a1d20899a1d25555555099999999999999999999999999999999999999999ffff999ddddccdddddddccccccccccc00000000
0000001142ff44449992425000000011000000110000000099999999999999999999999999999999999999fffff99999cccddddcddddddddcddddccc00000000
dcddddcd4ff2444444924210ccddddcccccdcccc222424449999999999999999999999fffff9999999fffffff999999999999999999999990000000000000000
dcddddcd552d444444424210dccddccdccddcccc22424444999999999fffff9f999fffff99999999999999999999999999999999999999990000000055000550
dccddccd2d11444444444210dcddddcdcccddccc24244244999999fffffff9f999ff9999999999999999999999999999999999999999999900000b3005505500
dcddddcd1100222222222100ddddddddcccdcccc2242444499999f9f9f9f9f999999999999999999999999999999999999ff9999999999990b30bb3000555000
dcddddcd0000111151551000dcddddcdcccdcccc2224244499f9f9f9f9999999999999999999999999999999999999999999999999999999bbb30b3000555000
dddddddd0000000000000000ddddddddcccdcccc22424444999999999999999999999999999ffff9ffff99999999999999999999999999990b300b3005505500
dcddddcd0000000000000000dcddddcdcccdcccc242442449999999999999999999999fffffffff9fffffffffffffff999999999999999990000bbb355000550
dcddddcd0000000000000000dccddccdccdddccc224244449999999999999999999999999999999999999fffff99999999999999999999990000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccc11cc111c1111111ccc11111111111111444444444444444444444444444444440000000000000000
ccccccccccccccccccccccccccc66ccccccccccccccc666c1cccc11111111111ccccc111111cc11c444444444444444444444444444444440000000000488400
cccccccccccccccccccccccccc677767cccccccccc676776cc11c1111ccccc11c111111cc1111111222442444444444444444444444444220000000004888840
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1111111ccccccc11244444444444444444444444444444440000000008888880
ccccccccc67776ccccccccccccccccccccccccccccccccccc1cc11ccccc11ccccccccccccccccccc444444444444444442444444444444440000000008888880
cccc6666cccccccccccccccc6776ccccccccccccccccccccccc1ccc1ccccc1cccc11ccccc1ccc1c1444444444444444444444442444444440000000004888840
6777777776cc67776ccccccccccccccccccccccccccccccccccccccc1c1cccc1cccccccccccccccc444442422444444444444444442444440000000000488400
ccc6777777777766ccccccccccccccccccccccccccccccccc1cccccccccccccccccccc1ccc11cccc444444444444444444444444444444440000000000000000
cccccccc667776cccccccccccccccccccccccccccccccccc0000442222440000000000000000000000656600001ccc5001d6cc60001150000000000000000000
cccccccccccccccccccccccccc666ccccccccccccccccccc004422222222440000000000000000000533d76001877765011111c0019765000115500000144000
cccccccccccccccccccccccc677776cccccccc666ccccccc0424888228884240000000000000000053bb3d750166666501666660016661001c777600049a9400
ccccccccccccccccc6776cccc6777776ccccc677777676cc4222248228422224000000000000000053bb3d75018767610111111001777100c6667750197aa940
cccccccccccccccccccccccccccccccccc6777776ccccccc012222222222221000000000000000005d336665018676650111111017997650445c6750174a4a40
cc6776cccccccccccccccccccccccccccccccccccccccccc0000112222100000000000000000000005dddd500176866100011000179976500044561419aaa910
ccccccccccccccccccccccccccccc676cccccccccccccccc00000002200000000000000000000000005555000016761000011000177766100000444044444440
cccccccccccccccccccccccccccccccccccccccccccccccc00004442244400000000000000000000044444400167776000566600016661000000000004444400
00000000000000000000000000d0000000000000cccccccccccccccccccccccc00d777775565656600000000cccccccc0000000d000000000004400000499444
0000000000000000000000000d6d0000000dd000cccccccccccccccccccccccc0d6777765556565600000000cccccccc00ddddd600000000000f400000244422
000000000000000000000000d677d00000d76d00ccccccccccccccccccccccccd6777777c555556500000000cccccccc0d676d670000000177ccd10001222111
000000000000000000000000d677d0ddd0d66d00cccccc55ccccccccccccccccd6776777cc55565600888880ccccccccd6777677011111c7cccccd1114441000
0000000000000000000000000ddddd676d0dd000cccc55775555ccccccccccccd6766777cc55555500888880ccccccccd6777777144444444449944222221100
000000000000000000000000000d677776d00000cc55776677775555ccccccccd666d677cc56555600000000c5550cccd6777767d666cc7c76122224449942c1
000004444444444444444440000d677776d000005577666666666666555ccccc0ddddd66c566555500000000c55500cc0d677777d66cc7c766144224444442c1
000000444444444444444000000d677776d0000077666666666566666665555c000000ddc565555500000000055000cc00d66777144444444444444222111100
0000d6776d0dd000cccccccccccccccccccc557766666666666666666666666555cccccc5565555556555555005000ccd0000000000000000000011111000000
00ddddddddd66d00cccccccccccccccccc557766666556666666666665666666665555cc555555505555555555000ccc6dd0dd00000000000000016776100000
6d6776d0d67776d0cccccccccccccccc5577666666666556666556666666655555555555555555550555055555cccccc766d66d0000000000000017767610000
d67777d0d67776d0cccccccccccccc5577666655566666666666656666655555555555555550555000555055555ccccc7767776d00000000000011116761142c
d67776ddd6666d00cccccccccccc5577666666666666666666666666667755555555555555555550000555055555cccc7767776d01400000000224167444442c
0d666dd76dddd000cccccccccc5577666666666666666666666666666666777555555555550555550000555555555ccc7777766d144111111124442761122221
00ddd0d66d000000cccccccc5577666665666566655556666666666666666666665555555555550550000555050555cc777766d0442000022222111177124441
0000000dd0000000cccccc5577666666666666777775555556666666666666666655555555555555550000555055550c77776d00111111111111011117111221
cccccccccccccccccccc55776666666666666666666777555555666665566666666555555555055555000005555550cc00000000cccccccccccccccc00000000
cccccccccddddccccc5577666666d6666666666666666666555555556566666666565555555550555000cc0055550ccc000dd000cccccccccccccccc08800088
cdddcccccccccccc5577666666666666666666665555566666665555566666666565555555555500000dccc00550cccc0dd77d00cccccccccccccccc00880880
cdccccdddccdcc55776666666655656665666667775755556666565555566666565555555555555000ccccdd000cccddd77776d0cccc5ccccccccccc00088800
ccccccc4dddd5577666d66d6dd66666d666666666565656555d56565d55566dd6565d555555555500cccccccc0ccccccd77766d0ccc575ccc5555ccc00088800
ccddd449dd557766dd66d66d66666666666666dd6d6d565d5555ddd555dd55665655555d5555550000dddccdccdddccd0d666d00cc57675cc55550cc00880880
ddd44999dddddddd66dd66ddd6dd656d6666dddd66ddd565dd55555dddddddd555d5dd555dd000d000ddccddddddccdd00ddd000c5765675555500cc08800088
cc499999dddddddddddddddddd66dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddccccddddc0000000057666667505000cc00000000
00067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000767776d050000ccc00550000
00067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000677776d0650ccccc05555000
000670007777770000677777000000000000000000000000000000000000000000000000000000000000000000000000000000007777776d665ccccc50555550
000670007666670000666667000000000000000000000000000000000000000000000000000000000000000000000000000000007777766d5665cccc05550055
000670007d6d6d66766d6d6700000000000000000000000000000000000000000000000000000000000000000000000000000000767766d065665ccc05000567
000670006ddd6d06706d6dd60000000000000000000000000000000000000000000000000000000000000000000000000000000076666d00565655cc50005555
00067000000ddd0670ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000066ddd0005565555c55544999
00067000000000067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd0000005556565555499fff
000770000000000000011111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049fffff
00077000000070000007777777777000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000549f9ffff
00766700000d67000007d6d66666700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000549ff99fff
00766700000d67000007ddddddd6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000549ff94fff
00766700000d67000001111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050499f94fff
07d66670000d67007777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000054999994fff
07dd6670000d6700766777776766666700000000000000000000000000000000000000000000000000000000000000000000000000000000000005494449497f
07ddd670000d67007dddddddddddddd700000000000000000000000000000000000000000000000000000000000000000000000000000000000050494200297f
01111110000d670011111111111111110000000000000000000000000000000000000000000000000000000000000000000000004550000000005049442029ff
07777770000d670076677776667777670000000000000000000000000000000000000000000000000000000000000000000000004550000000050049999449ff
76776667000d670076111116611111670000000000000000000000000000000000000000000000000000000000000000000000004d50000000050049fff49999
76776d676666670076677776667777670000000000000000000000000000000000000000000000000000000000000000000000004550000000050049fff94999
76776d6766666700761111166111116700000000000000000000000000000000000000000000000000000000000000000000000045540000000505499f994222
7d776667dddd67007667777666777767000000000000000000000000000000000000000000000000000000000000000000000000445940000005504999992000
7dd7d667000d67007611111661111167000000000000000000000000000000000000000000000000000000000000000000000000945f440000500449ff942000
0dddddd0000d67007dddddddddddddd70000000000000000000000000000000000000000000000000000000000000000000000004f5f4940005004949f949222
01111110000d670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004f549f940500494949f99999
76776667000d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff59fff90444494f949f9fff
76d77667000d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000945ff499599949f4f949ff7f
7d166767000d670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004f5449556599949f4f949999
7d166767000d6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000094455566d659494499f94444
76d11d67000d67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555666ddd659499944999999
767dd667000d670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006dd9aaa9a4ddd666dddd666d
0dddddd0000d6700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066d4499494dd666666dd66dd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055500000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077655000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055566500
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009445dd50
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099945dd5
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff945d6
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffff9456
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009ffff945
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009ffff945
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049ff9994
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049999994
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000049944449
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044400249
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000440024f9
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444ff9
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000094ffff99
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004ffff999
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024999999
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002999999
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002499994
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002949f949
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999f949f
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099f949f4
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff949f4f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009949ff99
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044999944
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099944499
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd6d6666
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666d6ddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d5000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005d500000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000046500000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000046500000
__gff__
0101010101000000000000000000000001010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
28292627282926272728292829262728292627272829262728292627282926272728292829262728292829262728292627272829282926272829262727282926282926272829262727282928292627282829808182837c85867c0000000000000000000000000000000000000000000000000000000000000000000000000000
24242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424909192939495967c7c2a2b2c2d2e0000000000000000000000000000000000000000000000000000000000000000
222222242422222222222222222222222424242222222222222224242424222222222222222222222222242424242222222424242424246d6e22242422222222222424242422222222222222222222222222a0a1a2a3a4a5a6707172737475767778000000000000000000000000000000000000000000000000000000000000
22222424242222222214242224242224242424222222222422222424242424222224242224242424242424242424242424245245464724497e4b242222222224222224242424222222142424242422222224b0b1b2b3b4b5b67c7c7c797a7b7c7c7c000000000000000000000000000000000000000000000000000000000000
22222222222422222213242424242222222224242422222422222222222424222224242424242422222222222222242452535455565758595a5b222224242424222222222224222222132424242422222222c0c1c2c3c4c5c67c7c007c7c7c000000000000000000000000000000000000000000000000000000000000000000
0d0c0d0e0d0c0e0d0c100d0e0c0d0d0c0d0e0d0c0e0d0c0c0d0c0d0e0d0c0e0d0c0c0d0e0c0d0d0c0d0d0c0d0e0d0d6162636465666768696a6b0e0d0c0e0d0c0d0c0d0e0d0c0e0d0c100d0e0c0d0d0c0c0dd0d1d2d3d4d5d67c7c00000000000000000000000000000000000000000000000000000000000000000000000000
08060708090b0b0a09060708090a0b0b0b08060708090b0b08060708090b0b0a09060708090a0b0b0b08060708090b0a0b090607090a0909090908060708090b08060708090b0b0a09060708090a0b0b0b0be0e1e2e3e4e5e67c7c00000000000000000000000000000000000000000000000000000000000000000000000000
18161718191a1b18191618191d1d1d1a1a18161718191a1b18161718191a1b18191618191d1d1d1a1a18161718191a1b18191617191a19191a1a18161718191a18161718191a1b18191618191d1d1d1a1a1af0f1f2f3f4f5f67c7c00000000000000000000000000000000000000000000000000000000000000000000000000
1a1617181d1d1d1618191a1b1d1d1d1b171a1617181d1d1d1a1617181d1d1d1618191a1b1d1d1d1b171a1617181d1d1d1618191a1b1d1d1d1b171a1617181d1d1a1617181d1d1d1618191a1b1d1d1d1b1b178788898a8b8c7c7c7c00000000000000000000000000000000000000000000000000000000000000000000000000
1d1d1d1b161d1d191a1b1d1d1d1d1a1a1b1d1d1d1b161d1d1d1d1d1b161d1d191a1b1d1d1d1d1a1a1b1d1d1d1b161d1d191a1b1d1d1d1d1a1a1b1d1d1d1b161d1d1d1d1d1b161d1d191a1b1d1d1d1d1a1a1b9798999a9b9c7c7c7c00000000000000000000000000000000000000000000000000000000000000000000000000
1d1d1d18191a1b161819161718191a1a1b1d1d1d18191a1b1d1d1d18191a1b161819161718191a1a1b1d1d1d18191a1b161819161718191a1a1b1d1d1d18191a1b1d1d1d18191a1b161819161718191a1a1ba7a8a9aaabac7c7c0000000000000000000000000000000000000000000000000000000000000000000000000000
1b191d1d1d1d18191a1b1a171b161717181b191d1d1d1d181b191d1d1d1d18191a1b1a171b161717181b191d1d1d1d18191a1b1a171b161717181b191d1d1d1d181b191d1d1d1d18191a1b1a171b16171718b7b8b9babbbcbdbe0000000000000000000000000000000000000000000000000000000000000000000000000000
1a161718191a1b16181916171d1d1d1a1b1a161718191a1b1a161718191a1b16181916171d1d1d1a1b1a161718191a1b16181916171d1d1d1a1b1a161718191a1b1a161718191a1b16181916171d1d1d1a1bc7c8c9cacbcccdce8d00000000000000000000000000000000000000000000000000000000000000000000000000
1b191a1b161718191a1b191a1b1d1d17181b191a1b1617181b191a1b161718191a1b191a1b1d1d17181b191a1b161718191a1b191a1b1d1d17181b191a1b1617181b191a1b161718191a1b191a1b1d1d1718d7d8d9dadbdcddde848d000000000000000000000000000000000000000000000000000000000000000000000000
1a16171d1d1d1d161819161718191a1a1b1a16171d1d1d1d1a16171d1d1d1d161819161718191a1a1b1a16171d1d1d1d161819161718191a1a1b1a16171d1d1d1d1a16171d1d1d1d161819161718191a1a1be7e8e9eaebecedee848d000000000000000000000000000000000000000000000000000000000000000000000000
1b191a1d1d1d1d191a1b191a1b161717181b191a1d1d1d1d1b191a1d1d1d1d191a1b191a1b161717181b191a1d1d1d1d191a1b191a1b161717181b191a1d1d1d1d1b191a1d1d1d1d191a1b191a1b16171718f7f8f9fafbfcfdfe848d000000000000000000000000000000000000000000000000000000000000000000000000
2f0f0f0f0f0f0f0f0f0f0f0f0f0f0f1f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2f4a4a4a4a4a4a4a4a4a4a4a4a4a4a6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007fbf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8e8fcfff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9e9fdf9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aeafefad7c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424242424242424242424242424242424242424242424242432332424242424242424242424243324242424242424242424312424242424242424242424242424242424242424242424242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2430242424242424232424242424242420212424242524242424242432242424242424242424242423322424242424242424243435242424243022242425242420212424242424243324242423242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424202124302424242424242424242424242424242424242424242424242424242424242533242424242424242424242424242424242424242425242424242424242424242424242424242424242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424242434352424242424242424242424343525242424243224242424242424242424242424242424202132332424242424242424242424242424242424242530232424242424242420212400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424243324242424242424242424333224242424242424242424242424242420212424242424243435242424242424242424242325242424242433343524242424242424242424242424242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0102000002640096400d640186401f6402764029640256401e6401a6401964016640196401a6401c6401d6401964016640146401364013640146401564016640156401463012630106200e6200d6100961006615
0101000010050120201303014050170501d05023050280502d0502f05032050370303a0203a010015000150001500015000150001500015000150001500015000150001500000000000000000000000000000000
011000200161002610046100561005610056100461002610016100161002610016100261003610066100761007610076100661004610036100361003610036100461005610066100561004610046100461005610
011000003570534705327053c7050c70000700107000c700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
011b00142b7702b73028770287302b7702b7301c0001d0002777027730297702973026770267302b7702b7302b0041c50300000000001a503000001a503000001c50300000000000000000000000000000000000
000b00000160012610126101262012620126301263012640126401265012650126601266012670126701267012670126701267012660126601265012650126401264012630126301262012620126101261000000
011100002d7402d725307452d7352d7402d7202d7152d7052d7402d725307452d74528740287252b745287452d7402d725307452d7352d7402d7202d715007002d7402d725307452d74528740287252b74528745
0111000000000000000000000000000000000000000000000000000000000000000000000000001c1401c03021140210302102021010151401503015020150100010000000000000000000000000001014010030
011100011572415705157041570515704157051570415705157041570515704157051570415705157041570515704157051570415705157041570515704157051570415705157041570515704157051570415705
011100002d7402d7302d7252d7051c7401c7201f7401c7102174021730217252d70528740287202b740287102d7402d7302d7252d705347403472037740347103974039730397252d70504140040200714004140
011100001514015030150250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011100000914409144091440914409144091440914409144091440914409144091440914409144091440914409144091440914409144091440914409144091440914409144091440914410140100201314010140
01110000285471c537285271c517265471a537265271a517285471c547285371c5371c705245072454024530265471a537265271a51723547175372352717517285471c547285371c537285271c527285171c517
011100040c043000150c6053f50515704157051570415705157041570515704157051570415705157041570515704157051570415705157041570515704157051570415705157041570515704157051570415705
011100002403024720247102471023030237202371023710240302472024710247102471524700210302172023030237202371023710210302172021710217102403024730247202472024020247102471024715
011100000e1400e1300e1200e1100c1400c1300c1200c1100b1400b1300b1200b1100914009130091200911007140071300712007110051400513005120051100414004130041200411002140021300212002110
01110000210402102524045210352104021020210152d005210402102526045210352104021020210152100521040210252804521035210402102021015000002104021025290452103521040210202101528005
0111000021736287362d7262872621516287162d5162871621736287362d7262872621516287162d5162871621736287362d7262872621516287162d5162871621716287162d7162871621516287162d51628716
01110000155601555015540155321856018550185401853210560105601055010550105421054215560155501a5601a5501a5401a5321c5601c5601c5601c5501c5501c5501c5421c5321c5251c5001c5001c500
01110000215602156021550215502154021540215322152221515155001f5601f53018560185301d5601d5301a5601a5601a5501a5501a5401a5321a5201a5121a5601a5601a5501a5501a5401a5301a5221a512
011100000914009130091200911509140091300912009115091400913009120091150914009130091200911509140091300912009115091400913009120091150914009130091200911509140091300912009115
01110000150201571018020187101a0201a7101c0201c71015020157101c0201c71024020247101c0201c71015020157101c0201c7102402024710307452d7352d7402d725307452d7352d7402d7251c0201c710
011100001556015550155401553215532155321a56018560175601755017540175321856018550185421853215560155601556015550155501555015540155401554015530155321553215535157001c5001c500
0111000015020157101c0201c71024020247101c0201c71015020157101c0201c71018020187101c0201c7101e0301e0201e0101e0102d7402d725307452d7352d7402d725327452d7352d7402d725307452d735
011100000914009130091200911509140091300912009115091400913009120091150914009130091200911502140021300212002115021400213002120021150214002130021200211502140021300212002115
0111000015560155501554015532185601855018540185321556015560155501555215540155401c5601c5501e5601e5501e5401e5321a5601a5601a5601a5501a5501a5501a5421a5321a525157001c5001c500
011100002d7402d7251c0201c71024020247101c0201c71015020157101c0201c71018020187101c0201c7100e0200e71015020157101e0201e7102102021710240202471021020217101e0201e7101502015710
01110000091400913009120091150914009130091200911509140091300912009115091400913009120091150a1400a1300a1200a1150a1400a1300a1200a1150a1400a1300a1200a1150a1400a1300a1200a115
01110000157001670515020157101c0201c710210202171024020240202402024020240102471024010247100e0000e70016020167101d0201d7102202022710260202671022020227101d0201d7101602016710
011100000514005130051200511505140051300512005115051400513005120051150514005130051200511504140041300412004115041400413004120041150214002130021200211502140021300212002115
011100000014000130001200011500140001300012000115051400513005120051150514005130051200511505140051300512005115051400513005120051150714007130071200711507140071300712007115
011100001d5601d5601d5501d5501d5401d5401d5321d5221d515155001c5601c53010560105301a5601a53017560175601755017550175401753017522175121756017560175501755017540175321752017512
011100001856018560185501855018540185401853218522185151770017560175300e5600e530175601753015560155601555015550155401553015522155121356013560135501355013540135321352213512
011100001570016705110201171018020187101d0201d71021020210202102021020210102171021010217100e0000e7002002020710230202371020020207101a0201a7101e0201e71023020237101e0201e710
0111000015700167051c0201c7101f0201f7101c0201c71021020217101f0201f7101d0201d7101f0201f7101d7101d710180201871021020217101d0201d71023020237101a0201a7101f0201f7102302023710
011100001556015560155601555015550155501554015540155401553015530155301552015520155201552015520155201552015520155201552015520155201552015520155101551015512155121551215510
011100000914009130091200911009110091100911009110091100911009110091151510015100151001510015100151001510015100151001510015100151001510015100151001510015100151001510015100
011100002151021510215102151021510215102151021510215102151021510215102151021510215102151021510215102151021510215102151021510215102151021512215122151221515155001550015500
010e000009140091250c145091350914009120091152d10509140091250c145091450414004125071450414509140091250c145091350914009120091152d10509140091250c1450914504140041250714504145
010e00000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c0430000000000000000c043000000000000000
010e00000c043000001b3231b3230c04300000000001b3230c0431b32300000000000c043000001b3231b3230c043000001b3231b3230c04300000000001b3230c0431b32300000000000c043000001b3231b323
010e00000c0433f2151b3231b3230c0433f2153f2151b3230c0431b3233f2153f2150c0433f2151b3231b3230c0433f2151b3231b3230c0433f2153f2151b3230c0431b3233f2153f2150c0433f2151b3233f215
010e00000e1400e1301a135021450c1400c13018125001450b1400b1300b1350b14509140150351c03015115071400e0351f0450e025051400c0351d0450c0250414004130100450e0450c0450b1450714508145
010e0000051400512510145051350514005120051152d1050514005125101450514504140041250714504145051400512510145051350514005120051152d1050514005125101450514504140041250714504145
010600003572534725327253c7150c70000700107000c700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
01050000101300f1310e1310e1310d1310d1310c1310c1310b1310b1310a1310a1310913109131081310813107131071310613106131051310513104131041310313103131021310213101131011310013100131
010500001235311353103530f3530e3530e3530d3530d3430c3430c3430b3430b3430a3430a343093330933308333083330733307333063330632305323053230432304323033230332302313023130131301313
0105000010404104440f4440e4440e4440d4440d4440c4440c4440b4440b4440a4440a44409444094440844408444074440744406444064440544405444044440444403444034440244402444014440144400444
011200000614006130061200611506140061300612006115061400613006120061150214002130021200914006140061300612006115021400213002120091400614006130061200611006110061100611006115
011200003c61024611186110c61100610006100061500605125401253012522125150e5400e5300e52015540125401253012522125150e5400e5300e522155401254012530125201251012510125121251212515
01070000285252d52534535395303952039510395152b505305053450034500345003450034500345051b5051b5051d5051f505225052250524505275052750527505295052b5052e5052e505305053050531505
010e00000e1400e1301a135021450c1400c13018125001450b1400b1300b1350b14509140150351c0301511511140180351d0451113510140170351f045101350e140150351d0450e1350c14013045180450c135
010e00000b1400e1351a1350b14509140101301812509145071400e130131350714505140150351c03505145041400b0451004504145001400004002045031450414004040100450e1450c0450b1450714508145
010e00000e1400e1301a135021450c1400c13018125001450b1400b1300b1350b14509140150351c03015115071400e0351f0450e025051400c0351d0450c0250414004130100450e0450c0450b1450714508145
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600003732000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 06 42 08 44
00 06 07 08 44
00 09 0a 08 44
00 0c 0e 0d 0b
00 0c 0e 0d 0b
00 06 08 0d 0b
00 10 11 0d 0f
00 12 15 0d 14
00 16 17 0d 18
00 19 1a 0d 18
00 13 1c 0d 1b
00 1f 21 0d 1d
00 20 22 0d 1e
00 23 0c 0e 24
02 25 0c 0e 44
00 26 27 43 44
00 26 28 43 44
01 26 29 43 44
00 26 29 43 44
00 2b 29 43 44
00 26 29 43 44
00 2a 29 43 44
00 26 29 43 44
00 26 29 43 44
00 2b 29 43 44
00 26 29 43 44
00 33 29 43 44
02 34 29 43 44
00 2d 2e 2f 44
04 30 31 43 44
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
