pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- init functions
function _init()
	carrying=0
	key=7
	trspr={t1=119,t2=120,t3=121}

	treasure={}

	player={}
	player.x=30
	player.y=30
	player.spr=4
	player.spd=0.5
	lock=15
	locks={{7,7},
			{4,13},
			{11,13},
			{8,14},
			{4,21},
			{20,13},
			{27,12},
			{23,23},
			{27,25},
			{36,13},
			{39,14},
			{36,24},
			{43,25},
			{52,13},
			{52,24}
	}
	bad_key_spots={{9,2},
					{13,2},
					{9,11},
					{13,11},
					{11,12},
					{8,7},
					{25,26},
					{29,26},
					{25,29},
					{29,29},
					{27,30},
					{36,25},
					{34,26},
					{38,26},
					{34,29},
					{38,29},
					{36,30},
					{41,26},
					{45,26},
					{41,29},
					{45,29},
					{43,30},
					{52,25},
					{50,26},
					{54,26},
					{50,29},
					{54,29},
					{52,30}
	}
	init_locks()
	init_key()
	clear_treasure()
	init_treasure()
	init_fiends()
	spider_flipper=1
	spider_flipper_states={{false,false},
							{true,false},
							{true,true},
							{false,true}
	}
	camx=0
	camy=0
	flickercols={9,9,9,9,9,10,10,10,7,7}
	safecols={9}
	matchcols=flickercols
	matchrad=10
	cmc=0
	fourframe=1
	maxdelay=16
	framedelay=maxdelay-1
	pathupdatectr=60
	fiendpaths={bat={},ghost={},spider={}}
	killer=nil
	wallflag=2
	lives=9
	matches=100
	matchlit=false
	matchlitframes=600
	if flicker == nil then
		flicker=true
		ftxt="on"
	end
	
	skspr={106,108,106,110,108,106,108,110,106,108,110}
	skspridx=0
	sksprctr=10
	skx=camx-20
	deathanim=false
 	deathframecounter=180
	
	gametime=0
	gameframes=0
	dispgametime=""
	gameend=""
	gameendcol=8
	gameendshadowcol=1

	floor=1
	floorframedelay=30
	maxfloorframedelay=30
	
	stepsfxctr=30

	introtxt={"ah, another visitor!",
				"stay awhile,",
				"stay forever!",
				" ",
				" ",
				"sorry, wrong script!",
				"let's start again.",
				" ",
				"find the 3 pieces",
				"of my treasure and",
				"you may leave my house",
				"through the first",
				"floor door",
				"(if you survive!)"
	}
	wintxt={"find the 3 piec--",
				"oh, you've done that?",
				" ",
				"well, do you want to",
				"maybe hang out awhile?",
				"i've got snacks!",
				" ",
				"no?",
				" ",
				"*sigh*",
				"no one ever wants",
				"to hang out with me."
	}
	losetxt={"you look as if",
				"you've seen a ghost!",
				" ",
				"or a bat? a spider?",
				" ",
				"in any case, i'm",
				"glad you decided",
				"to stay!",
				" ",
				"i will enjoy our",
				"eternity together!",
				" ",
				"muahahhaahahahahaha!"
	}
	itx=10
	ity=45
	ito=8
	otx=10
	oty=45
	oto=8
	fadeperc=0
	
	startoffsets={{-2,0},{0,-2},{2,0},{0,2}}
	startoffsetsidx=1
	startoffsetc=15
	_draw=draw_start
	_update60=update_start
	music(40)
end

function init_locks()
	for l in all(locks) do
		mset(l[1],l[2],lock)
	end
end

function init_fiends()
	bat={}
	bat.name="bat"
	bat.spd=1
	bat.spr=-1
	bat.vis=false
	isopen=1
	while isopen > 0 do
		kx=flr(rnd(61))+2
		ky=flr(rnd(29))+2
		isopen=fget(mget(kx,ky))
 	end
 	bat.x=kx*8
 	bat.y=ky*8

	ghost={}
	ghost.name="ghost"
	ghost.spd=1
	ghost.spr=5
	ghost.vis=false
	isopen=1
	while isopen > 0 and (abs(kx-bat.x\8) <= 8 or abs(ky-bat.y\8) <= 8) do
		kx=flr(rnd(61))+2
		ky=flr(rnd(29))+2
		isopen=fget(mget(kx,ky))
 	end
 	ghost.x=kx*8
 	ghost.y=ky*8
 	
 	spider={}
 	spider.name="spider"
 	spider.spd=1
 	spider.spr=8
 	spider.vis=false
 	isopen=1
	while isopen > 0 and ((abs(kx-bat.x\8) <= 8 or abs(ky-bat.y\8) <= 8) or (abs(kx-ghost.x\8) <= 8 or abs(ky-ghost.y\8) <= 8)) do
		kx=flr(rnd(61))+2
		ky=flr(rnd(29))+2
		isopen=fget(mget(kx,ky))
 	end
 	spider.x=kx*8
 	spider.y=ky*8
	spider.vflip=false
	spider.hflip=false
end

function clear_treasure()
	cleared=0
	for x=0,63 do
		for y=0,31 do
			tile=mget(x,y)
			if mid(118,tile,122)==tile then
				mset(x,y,0)
				cleared += 1
				if(cleared == 3) return
			end
		end
	end
end

function init_treasure(t)
	if t == nil then
		for name,spr in pairs(trspr) do
			isopen=1
			while isopen > 0 do
				kx=flr(rnd(61))+2
				ky=flr(rnd(29))+2
				isopen=fget(mget(kx,ky))
			end
			mset(kx,ky,spr)
		end
	else
		isopen=1
		while isopen > 0 do
			kx=flr(rnd(61))+2
			ky=flr(rnd(29))+2
			isopen=fget(mget(kx,ky))
		end
		mset(kx,ky,t)
	end
end

function init_key()
	if(prevkeyx != nil) mset(prevkeyx,prevkeyy,0)

	isopen=1
	while isopen > 0 do
		kx=flr(rnd(61))+2
		ky=flr(rnd(29))+2
		isopen=fget(mget(kx,ky))
		if isopen == 0 then
			for badspot in all(bad_key_spots) do
				if kx == badspot[1] and ky == badspot[2] then
					isopen = 1
					break
				end
			end
		end
 	end
 	mset(kx,ky,key)
 	prevkeyx=kx
 	prevkeyy=ky
end

-->8
-- update functions
function update_start()
	startoffsetc -= 1
	if startoffsetc == 0 then
		startoffsetsidx += 1
		if startoffsetsidx == 5 then
			startoffsetsidx = 1
		end
		startoffsetc=15
	end
	if btnp(0) or btnp(1) then
		flicker = not flicker
		if flicker then
			ftxt="on"
		else
			ftxt="off"
		end
	end
	if btnp(5) or btnp(4) then
		music(-1,500)
		_update60=update_intro_fade_in
	end
end

function update_end_fade_in()
	if fadeperc < 1 then
		fadeperc += 0.01
		if(fadeperc > 1)fadeperc=1
	else
		camx=0
		camy=0
		if lives==0 or matches==0 then
			music(40)
		else
			music(39)
		end
		_draw=draw_end
		_update60=update_end
	end
end

function update_end()
	if fadeperc > 0 then
		fadeperc -= 0.01
		if(fadeperc<0)fadeperc=0
	else
		mins=tostr(gametime\60)
		secs=tostr(gametime%60)
		if(#secs==1)secs="0"..secs
		dispgametime=mins..":"..secs
		if lives==0 or matches==0 then
			gameend="you died in the house!"
			gameendcol=8
			gameendshadowcol=1
		else
			gameend="you escaped the house!"
			gameendcol=11
			gameendshadowcol=2
		end
	end
	if btnp(5) or btnp(4) then
		music(-1,500)
		_init()
	end
end

function update_win_fade_in()
	if fadeperc < 1 then
		fadeperc += 0.01
		if(fadeperc > 1)fadeperc=1
	else
		camx=0
		camy=0
		music(10)
		_draw=draw_win
		_update60=update_win
	end
end

function update_win()
	sksprctr -= 1
	if sksprctr == 0 then
		sksprctr=10
		skspridx+=1
		if(skspridx > #skspr)skspridx=1
	end
	if fadeperc > 0 then
		fadeperc -= 0.01
		if(fadeperc<0)fadeperc=0
	else
		oty-=0.2
	end
	if oty + #wintxt*oto + 5 < camy then
		music(-1,500)
		_update60=update_end_fade_in
	end
end

function update_lose_fade_in()
	if fadeperc < 1 then
		fadeperc += 0.01
		if(fadeperc > 1)fadeperc=1
	else
		camx=0
		camy=0
		music(10)
		_draw=draw_lose
		_update60=update_lose
	end
end

function update_lose()
	sksprctr -= 1
	if sksprctr == 0 then
		sksprctr=10
		skspridx+=1
		if(skspridx > #skspr)skspridx=1
	end
	if fadeperc > 0 then
		fadeperc -= 0.01
		if(fadeperc<0)fadeperc=0
	else
		oty-=0.2
	end
	if oty + #losetxt*oto + 5 < camy then
		music(-1,500)
		_update60=update_end_fade_in
	end
end

function update_intro_fade_in()
	if fadeperc < 1 then
		fadeperc += 0.01
		if(fadeperc > 1)fadeperc=1
	else
		skspridx=0
		sksprctr=10
		music(10)
		_draw=draw_intro
		_update60=update_intro
	end
end

function update_intro()
	sksprctr -= 1
	if sksprctr == 0 then
		sksprctr=10
		skspridx+=1
		if(skspridx > #skspr)skspridx=1
	end
	if fadeperc > 0 then
		fadeperc -= 0.01
		if(fadeperc<0)fadeperc=0
	else
		ity-=0.2
	end
	if ity + #introtxt*ito + 5 < camy then
		music(-1,500)
		_update60=update_game_fade_in
	end
end

function update_game_fade_in()
	if fadeperc < 1 then
		fadeperc += 0.01
		if(fadeperc > 1)fadeperc=1
	else
		_draw=draw_game
		_update60=update_game
	end
end

function update_death()
	skx += 1
	if skx >= camx+138 then
		deathanim=false
		skx=camx-20
	end
	sksprctr -= 1
	if sksprctr == 0 then
		skspridx += 1
		if(skspridx > #skspr)skspridx=1
		sksprctr = 10
	end
	deathframecounter -= 1
	if deathframecounter == 0 then
		lives -= 1
		if lives == 0 then
			_update60 = update_lose_fade_in
		else
			if #treasure > 0 then
				init_treasure(treasure[#treasure])
				del(treasure,treasure[#treasure])
			end
			if carrying == key then
				init_key()
				carrying=0
			end
			reset_fiend(killer)
			killer=nil
			deathframecounter=180
			matchlit=false
			matchlitframes=600
			_update60 = update_game
		end
	end
end

function update_game()
	if fadeperc > 0 then
		fadeperc -= 0.01
		if(fadeperc<0)fadeperc=0
	else
		gameframes+=1
		if gameframes==60 then
			gametime+=1
			gameframes=0
		end
		if(not matchlit and matches == 0) _update60=update_lose_fade_in
		framedelay-=1
		floorframedelay-=1
		pathupdatectr-=1
		if(floorframedelay < 0)floorframedelay=0
	
		if matchlit then
			matchlitframes -= 1
			if matchlitframes <=0 then
				matchlitframes=600
				matchlit=false
			end
		end
		if framedelay==0 then
			fourframe = (fourframe+1) % 4
			framedelay=maxdelay
			spider_flipper += 1
			if(spider_flipper > 4)spider_flipper = 1
			spider.hflip=spider_flipper_states[spider_flipper][1]
			spider.vflip=spider_flipper_states[spider_flipper][2]
			move_fiend(bat)
			move_fiend(ghost)
			move_fiend(spider)
		end
		if deathcheck() then
			sfx(58)
			killer.x = player.x
			killer.y = player.y
			deathanim=true
			_update60=update_death
		end
		if(pathupdatectr <= 0)pathupdatectr=60
		bvec = vec(bat.x,bat.y,player.x,player.y)
		gvec = vec(ghost.x,ghost.y,player.x,player.y)
		svec = vec(spider.x,spider.y,player.x,player.y)

		if bvec < 30 and bvec > 0 and abs(bat.x - camx) < 128 then
			bat.spr = fourframe
			if not bat.vis then
				bat.vis=true
				sfx(53)
				matchlit=false
			end
		elseif bvec < 60 then
			bat.spr = fourframe
		else
			bat.vis=false
			bat.spr=117
		end
		
		if gvec < 30 and gvec > 0 and abs(ghost.x - camx) < 128 then
			ghost.spr=5
			if not ghost.vis then
				ghost.vis=true
				sfx(53)
				matchlit=false
			end
		elseif gvec < 60 then
			ghost.spr=5
		else
			ghost.vis=false
			ghost.spr=117
		end
	
		if svec < 30 and svec > 0 and abs(spider.x - camx) < 128 then
			spider.spr=8
			if not spider.vis then
				spider.vis=true
				sfx(53)
				matchlit=false
			end
		elseif svec < 60 then
			spider.spr=8
		else
			spider.vis=false
			spider.spr=117
		end
		
		if btn(0) then
			tile=mget((player.x-player.spd)\8,player.y\8)
			flag=fget(tile)
			if flag == 0x20 and floorframedelay <= 0 then
				floorframedelay = maxfloorframedelay
				floor -= 1
				player.x -= 120
				do_step_sound()
			elseif flag == 0x10 and floorframedelay <= 0 then
				floorframedelay = maxfloorframedelay
				floor += 1
				player.x += 136
				do_step_sound()
			elseif flag == 0x8 and matchlit then
				carrying=key
				sfx(41)
				mset((player.x-player.spd)\8,player.y\8,0)
				player.x -= player.spd
			elseif flag == 0x80 and matchlit then
				add(treasure,tile)
				sfx(41)
				mset((player.x-player.spd)\8,player.y\8,0)
				player.x -= player.spd
			elseif flag == 0x4 then
				if carrying == key then
					mset((player.x-player.spd)\8,player.y\8,0)
					player.x -= player.spd
					sfx(39)
				end
			elseif flag != 0x2 and flag != 0x40 then
				player.x -= player.spd
				do_step_sound()
			end
		elseif btn(1) then
			tile=mget((player.x+7+player.spd)\8,player.y\8)
			flag=fget(tile)
			if flag == 0x20 and floorframedelay <= 0 then
				floorframedelay = maxfloorframedelay
				floor -= 1
				player.x -= 136
				do_step_sound()
			elseif flag == 0x10 and floorframedelay <= 0 then
				floorframedelay = maxfloorframedelay
				floor += 1
				player.x += 120
				do_step_sound()
			elseif flag == 0x8 and matchlit then
				carrying=key
				sfx(41)
				mset((player.x+7+player.spd)\8,player.y\8,0)
				player.x += player.spd
			elseif flag == 0x80 and matchlit then
				add(treasure,tile)
				sfx(41)
				mset((player.x+7+player.spd)\8,player.y\8,0)
				player.x += player.spd
			elseif flag == 0x4 then
				if carrying == key then
					mset((player.x+7+player.spd)\8,player.y\8,0)
					player.x += player.spd
					sfx(39)
				end
			elseif flag == 0x40 and #treasure == 3 then
				sfx(52)
				_update60=update_win_fade_in
			elseif flag != 0x2 and flag != 0x40 then
				player.x += player.spd
				do_step_sound()
			end
		end
	
		if btn(2) then
			tile=mget(player.x\8,(player.y-player.spd)\8)
			flag=fget(tile)
			if flag == 0x20 and floorframedelay <= 0 then
				floorframedelay = maxfloorframedelay
				floor -= 1
				player.x -= 128
				player.y += 8
				do_step_sound()
			elseif flag == 0x10 and floorframedelay <= 0 then
				floorframedelay = maxfloorframedelay
				floor += 1
				player.x += 128
				player.y += 8
				do_step_sound()
			elseif flag == 0x8 and matchlit then
				carrying=key
				sfx(41)
				mset(player.x\8,(player.y-player.spd)\8,0)
				player.y -= player.spd
			elseif flag == 0x80 and matchlit then
				add(treasure,tile)
				sfx(41)
				mset(player.x\8,(player.y-player.spd)\8,0)
				player.y -= player.spd
			elseif flag == 0x4 then
				if carrying == key then
					mset(player.x\8,(player.y-player.spd)\8,0)
					player.y -= player.spd
					sfx(39)
				end
			elseif flag != 0x2 and flag != 0x40 then
				player.y -= player.spd
				do_step_sound()
			end
		elseif btn(3) then
			tile=mget(player.x\8,(player.y+7+player.spd)\8)
			flag=fget(tile)
			if flag == 0x20 and floorframedelay <= 0 then
				floorframedelay = maxfloorframedelay
				floor -= 1
				player.x -= 128
				player.y -= 8
				do_step_sound()
			elseif flag == 0x10 and floorframedelay <= 0 then
				floorframedelay = maxfloorframedelay
				floor += 1
				player.x += 128
				player.y -= 8
				do_step_sound()
			elseif flag == 0x8 and matchlit then
				carrying=key
				sfx(41)
				mset(player.x\8,(player.y+7+player.spd)\8,0)
				player.y += player.spd
			elseif flag == 0x80 and matchlit then
				add(treasure,tile)
				sfx(41)
				mset(player.x\8,(player.y+7+player.spd)\8,0)
				player.y += player.spd
			elseif flag == 0x4 then
				if carrying == key then
					mset(player.x\8,(player.y+7+player.spd)\8,0)
					player.y += player.spd
					sfx(39)
				end
			elseif flag != 0x2 and flag != 0x40 then
				player.y += player.spd
				do_step_sound()
			end
		end
		
		if(player.y > 248)player.y=248
		if(player.y < 0)player.y=0
	
		if (btnp(5) or btnp(4)) and not matchlit then
			matches -= 1
			matchlit=true
			sfx(42)
		end

		-- camadjust
		if((player.y > 214 and camy <= 214) or (player.y > 107 and camy <= 107))camy = player.y
		if((mid(107,player.y,214)==player.y and camy > player.y))camy = 108
		if(player.y <= 107)camy=0
		camx=(floor-1)*128
		skx=camx-20
		if(player.x > camx+120)player.x=camx+120

		if flicker then
			matchcols=flickercols
			matchrad=flr(rnd(2))+14
		else
			matchcols=safecols
			matchrad=15
		end
	end
end

-->8
-- draw functions
function draw_start()
	cls()
	map(64,0,0,0,16,16)
	print("apparitional",42+startoffsets[startoffsetsidx][1],76+startoffsets[startoffsetsidx][2],2)
	print("apparitional",41+startoffsets[startoffsetsidx][1],75+startoffsets[startoffsetsidx][2],11)
	print("abode",55+startoffsets[startoffsetsidx][1],86+startoffsets[startoffsetsidx][2],2)
	print("abode",54+startoffsets[startoffsetsidx][1],85+startoffsets[startoffsetsidx][2],11)
	print("match flicker: "..ftxt,33+startoffsets[startoffsetsidx][1],96+startoffsets[startoffsetsidx][2],2)
	print("match flicker: "..ftxt,32+startoffsets[startoffsetsidx][1],95+startoffsets[startoffsetsidx][2],11)
	print("—/ to start",38+startoffsets[startoffsetsidx][1],106+startoffsets[startoffsetsidx][2],2)
	print("—/ to start",37+startoffsets[startoffsetsidx][1],105+startoffsets[startoffsetsidx][2],11)
	if fadeperc != 0 then
		fadepal(fadeperc)
	end
end

function draw_end()
	cls()
	map(64,0,0,0,16,16)
	print("time: "..dispgametime,45,76,2)
	print("time: "..dispgametime,44,75,11)
	print("matches used: "..(100-matches),34,86,2)
	print("matches used: "..(100-matches),33,85,11)
	print("deaths: "..(9-lives),47,96,2)
	print("deaths: "..(9-lives),46,95,11)
	print(gameend,26,106,gameendshadowcol)
	print(gameend,25,105,gameendcol)
	print("—/ to play again!",29,116,2)
	print("—/ to play again!",28,115,11)
	if fadeperc != 0 then
		fadepal(fadeperc)
	end
end

function draw_intro()
	cls()
	for i=1,#introtxt do
		y=ity+(ito*(i-1))
		if y<camy+5 then
			c=5
		elseif y<camy+10 then
			c=6
		else
			c=7
		end
		
		print(introtxt[i],camx+itx,y,c)
	end
	spr(skspr[skspridx],110,110,2,2)
	if fadeperc != 0 then
		fadepal(fadeperc)
	end
end

function draw_win()
	cls()
	camera(camx,camy)
	for i=1,#wintxt do
		y=oty+(oto*(i-1))
		if y<camy+5 then
			c=5
		elseif y<camy+10 then
			c=6
		else
			c=7
		end
		
		print(wintxt[i],camx+otx,y,c)
	end
	spr(skspr[skspridx],110,110,2,2)
	if fadeperc != 0 then
		fadepal(fadeperc)
	end
end

function draw_lose()
	cls()
	camera(camx,camy)
	for i=1,#losetxt do
		y=oty+(oto*(i-1))
		if y<camy+5 then
			c=5
		elseif y<camy+10 then
			c=6
		else
			c=7
		end
		
		print(losetxt[i],camx+otx,y,c)
	end
	spr(skspr[skspridx],110,110,2,2)
	if fadeperc != 0 then
		fadepal(fadeperc)
	end
end

function draw_game()
	cls()
	camera(camx,camy)
	if matchlit then
		circfill(player.x+4,player.y+3,matchrad,matchcols[flr(rnd(#matchcols)+1)])
		circmap(player.x+4,player.y+3,matchrad+5)
	end
	spr(player.spr,player.x,player.y)
	spr(bat.spr,bat.x,bat.y)
	spr(ghost.spr,ghost.x,ghost.y)
	spr(spider.spr,spider.x,spider.y,1,1,spider.hflip,spider.vflip)
	rectfill(camx,camy+108,camx+127,camy+127,1)
	rect(camx,camy+108,camx+127,camy+127,13)
	spr(105,camx+2,camy+110)
	print(":"..matches,camx+11,camy+112)
	spr(player.spr,camx+60,camy+110)
	print(":"..lives,camx+69,camy+112)
	spr(118,camx+60,camy+119)
	print(":",camx+69,camy+121)
	for i=1,#treasure do
		spr(treasure[i],camx+73+((i-1)*8),camy+119)
	end
	spr(11,camx+108,camy+110)
	print(":"..floor,camx+117,camy+112)
	if(carrying==key)spr(key,camx+2,camy+119)
	if(deathanim)spr(skspr[skspridx],skx,player.y,2,2)
	if fadeperc != 0 then
		fadepal(fadeperc)
	end
end

-->8
-- utility functions
function reset_fiend(fiend)
	if fiend != nil then
		isopen=1
		-- make sure the fiend doesn't respawn too close
		-- to the player - that's just rude!
		while isopen > 0 or abs(kx*8-player.x) < 32 or abs(ky*8-player.y) < 32 do
			kx=flr(rnd(61))+2
			ky=flr(rnd(29))+2
			isopen=fget(mget(kx,ky))
		end
		fiend.x=kx*8
		fiend.y=ky*8
 	end
end

function vec(x1,y1,x2,y2)
	-- dividing by 10 to avoid bad overflow math
	d1=(x2-x1)/10
	d2=(y2-y1)/10
	
	-- multiplying by 10 again to bring it on home
	return sqrt((d1^2) + (d2^2)) * 10
end

function nonpath_move(fiend)
	xdir=(player.x - fiend.x)\abs(player.x - fiend.x)
	ydir=(player.y - fiend.y)\abs(player.y - fiend.y)
	xmove = flr(rnd(2)) * xdir * 8
	ymove = flr(rnd(2)) * ydir * 8
	-- check for objects
	flag=fget(mget((fiend.x+xmove)\8,(fiend.y+ymove)\8))
	if flag == 0 then 
		-- empty space
		fiend.x += xmove
		fiend.y += ymove
	elseif flag == 0x10 then
		-- stairwell up, increase x by 128
		fiend.x += 128
		fiend.y += ymove
	elseif flag == 0x20 then
		-- stairwell down, decrease x by 128
		fiend.x -= 128
		fiend.y += ymove
	end
end

function move_fiend(fiend)
	-- pathupdatectr starts at 60, so clear the path every second
	if(pathupdatectr <= 0) fiendpaths[fiend.name]={}
	
	relpos=abs(fiend.x-camx)
	if relpos >= 128 or relpos < 0 then
		-- the fiend is on a different floor, do not chase player, just wander
		nonpath_move(fiend)
	else
		-- the fiend is on the same floor, is it already moving toward player?
		if #fiendpaths[fiend.name] == 0 then
			path=findplayer({fiend.x\8,fiend.y\8},{player.x\8,player.y\8})
			if #path==0 then
				nonpath_move(fiend)
			else
				fiendpaths[fiend.name]=path
			end
		else
			fiendpath=fiendpaths[fiend.name]
			fiend.x=fiendpath[1][1]*8
			fiend.y=fiendpath[1][2]*8
			del(fiendpath,fiendpath[1])		
		end
	end

	-- check for the need to wrap
	if(fiend.y > 280)fiend.y=16
	if(fiend.y < -10)fiend.y=232
	if(fiend.x > 520)fiend.x=16
	if(fiend.x < -10)fiend.x=480
end

function deathcheck()
	-- check bat
	killer=bat
	if((mid(player.x,bat.x,player.x+7) == bat.x or mid(player.x,bat.x+7,player.x+7) == bat.x+7) and (mid(player.y,bat.y,player.y+7) == bat.y or mid(player.y,bat.y+7,player.y+7)==bat.y+7)) return true
	-- check ghost
	killer=ghost
	if((mid(player.x,ghost.x,player.x+7) == ghost.x  or mid(player.x,ghost.x+7,player.x+7) == ghost.x+7) and (mid(player.y,ghost.y,player.y+7) == ghost.y or mid(player.y,ghost.y+7,player.y+7)==ghost.y+7)) return true
	-- check spider
	killer=spider
	if((mid(player.x,spider.x,player.x+7) == spider.x  or mid(player.x,spider.x+7,player.x+7) == spider.x+7) and (mid(player.y,spider.y,player.y+7) == spider.y or mid(player.y,spider.y+7,player.y+7)==spider.y+7)) return true

	killer=nil
	return false
end

function do_step_sound()
	stepsfxctr -= 1
	if stepsfxctr == 0 then 
		stepsfxctr=30
		sfx(0)
	end
end

-->8
-- a* pathfinder
-- lightly adapted from https://www.lexaloffle.com/bbs/?tid=3131
-- by @richy486
-- mostly changed to move code from _init() into findplayer()
function findplayer(_mobpos,_playerpos)
 frontier = {}
 insert(frontier, _mobpos, 0)
 came_from = {}
 came_from[vectoindex(_mobpos)] = nil
 cost_so_far = {}
 cost_so_far[vectoindex(_mobpos)] = 0

 while (#frontier > 0 and #frontier < 1000) do
  current = popend(frontier)

  if vectoindex(current) == vectoindex(_playerpos) then
   break
  end

  local neighbours = getneighbours(current)
  for next in all(neighbours) do
   local nextindex = vectoindex(next)
  
   local new_cost = cost_so_far[vectoindex(current)]  + 1 -- add extra costs here

   if (cost_so_far[nextindex] == nil) or (new_cost < cost_so_far[nextindex]) then
    cost_so_far[nextindex] = new_cost
    local priority = new_cost + heuristic(_playerpos, next)
    insert(frontier, next, priority)
    
    came_from[nextindex] = current
   end 
  end
 end

 current = came_from[vectoindex(_playerpos)]
 path = {}
 if current == nil then
 	return path
 end
 local cindex = vectoindex(current)
 local sindex = vectoindex(_mobpos)

 while cindex != sindex do
  add(path, current)
  current = came_from[cindex]
  if current == nil then
	reverse(path)
  	return path
  end
  cindex = vectoindex(current)
 end

 if(#path == 0) return path
 reverse(path)
 if abs(path[#path][1] - _playerpos[1]) <= 1 and abs(path[#path][2] - _playerpos[2]) <= 1 then
 	add(path,_playerpos)
 end 

 return path
end

-- manhattan distance on a square grid
function heuristic(a, b)
 return abs(a[1] - b[1]) + abs(a[2] - b[2])
end

-- find all existing neighbours of a position that are not walls
function getneighbours(pos)
 local neighbours={}
 local x = pos[1]
 local y = pos[2]
 if x > 0 and (fget(mget(x-1,y)) != wallflag) then
  add(neighbours,{x-1,y})
 end
 if x < 15 and (fget(mget(x+1,y)) != wallflag) then
  add(neighbours,{x+1,y})
 end
 if y > 0 and (fget(mget(x,y-1)) != wallflag) then
  add(neighbours,{x,y-1})
 end
 if y < 15 and (fget(mget(x,y+1)) != wallflag) then
  add(neighbours,{x,y+1})
 end

 -- for making diagonals
 if (x+y) % 2 == 0 then
  reverse(neighbours)
 end
 return neighbours
end

-- insert into start of table
function insert(t, val)
 for i=(#t+1),2,-1 do
  t[i] = t[i-1]
 end
 t[1] = val
end

-- insert into table and sort by priority
function insert(t, val, p)
 if #t >= 1 then
  add(t, {})
  for i=(#t),2,-1 do
   
   local next = t[i-1]
   if p < next[2] then
    t[i] = {val, p}
    return
   else
    t[i] = next
   end
  end
  t[1] = {val, p}
 else
  add(t, {val, p}) 
 end
end

-- pop the last element off a table
function popend(t)
 local top = t[#t]
 del(t,t[#t])
 return top[1]
end

function reverse(t)
 for i=1,(#t/2) do
  local temp = t[i]
  local oppindex = #t-(i-1)
  t[i] = t[oppindex]
  t[oppindex] = temp
 end
end

-- translate a 2d x,y coordinate to a 1d index and back again
function vectoindex(vec)
 return maptoindex(vec[1],vec[2])
end
function maptoindex(x, y)
 return ((x+1) * 16) + y
end
function indextomap(index)
 local x = (index-1)/16
 local y = index - (x*w)
 return {x,y}
end
-->8
--circmap
--by @cubee 
--from https://www.lexaloffle.com/bbs/?tid=38881
function circmap(x,y,r)
 for y2=-r,r do
  x2=sqrt(abs(y2*y2-r*r))
  tline(x-x2,y+y2,x+x2,y+y2,(x-x2)/8,(y+y2)/8)
 end
end
-->8
--fade
--by @krystman
--from https://www.lexaloffle.com/bbs/?tid=31484
function fadepal(_perc)
 -- 0 means normal
 -- 1 is completely black
 
 local p=flr(mid(0,_perc,1)*100)
 
 -- these are helper variables
 local kmax,col,dpal,j,k
 dpal={0,1,1,2,1,13,6,
          4,4,9,3,13,1}
 
 -- now we go trough all colors
 for j=1,13 do
  --grab the current color
  col = j
  
  --now calculate how many
  --times we want to fade the
  --color.
  kmax=(p+(j*1.46))/22  
  for k=1,kmax do
   col=dpal[col]
  end
  
  --finally, we change the
  --palette
  pal(j,col,1)
 end
end
__gfx__
0000000000000000000000000000000000dddd0000777700007777000007a900750705600000000094000049000000076776d776500000005666666500766500
220000220000000000000000000000000d7cc7d00766667000066670000a00005656565001111000945444490000007676675665650000006666666607500650
02200220200202020002020000000000d70cc07d71166117a0776657000aa9000577750011111100945555490000076676675665665000006000000606500650
00220200200828020008280000220200d77cc77d712662177a666666000a00007677666010010110940000490000766676675665666500006000000676666665
00082800022222200022220002282820dccccccd066116606d666666000a00000576650001111110940000490007666676675665666650006000000676616665
00022200002222000220022020022002dcc11ccd05666650d0566115007aa9005656565011111111945444490076666676675665666665006000000676616665
000000000000000022000022200000020dccccd0006116000006665000a00a007506056000000001945555490766666676675665666666506000000676666665
0000000000000000000000000000000000dddd000056650000665000009aa9000000000000000000940000497666666665521556666666650000000065555555
33333333333333333333333333333333333333333333333333333333333333331111111111111111111111111111111111111111111111111111111111111111
33d553333533dd53313335ddddddd55335dddd3dddddd53333555551313331531151555555555511115555555555551111555555555555511555555555555511
13ddd331153dd51115533ddddddddd511ddddd5ddddddd3113dddd55353535511555555dddd5d55115dddddd55ddd551155ddddddddd5d5115dddd5dddddd551
15dddd511d5ddd511dd35ddddddddd511ddddd5ddddddd5115ddddd55d353d511555d55dddd5dd511d5ddddd5ddddd5115d5ddddddd5555115555d5ddddd5d51
1ddddd511dd5d5511d55dddddddddd511ddddd5ddddddd511dddddd5dd3d5d5115d5dd5ddddddd511dd5dd555ddddd5115dd5ddddd5511111111555ddd55dd51
15dddd5115dd5d511555dddddddddd5115555555d51155501ddddd5ddd5ddd5115dddddddddddd511dd5d5dd5ddddd5115ddd55dd51100000000115dd55d5551
155555511555555115555ddddddddd511dd155555d15dd511ddddd55dddddd5115d5dd5ddddddd511ddd5dddd5dddd5115ddd515510000000000001551dddd51
01111110011111101dddd5ddddddd5511dd55ddddd5d5d5115ddd5d5dd5ddd5115dddddd5ddddd511ddd5dddd515551015555551100000000000000115555551
33333333333333331dddddddddd55d511d555555555ddd511d5d55dd5ddddd511ddddd5d5ddddd5115ddd555515ddd5111111111000011110111111011111111
35dddd51355d33531ddddddddd55dd51155d5d555ddddd511dd51155555dd5511d5ddddd5d5d5d511ddd5ddd55dddd5115dddd51000111111000100115dddd51
1dd11d5115dd5351011d5d5dd5dd5d5115d5ddd5d5d5dd51015555d5ddd5555115d5dd5d55dddd5115d5ddddd55555511ddddd5100110111100001011dddd551
1d15515115d5d5511551d5d515ddd551015d5d5d15155551155d5d5d5ddd555115555d55555d5d5115555d5d5d5ddd511ddddd5101100011100000111d5ddd51
1d55555115dddd511555551155d5d5511555d5d15555555115d555d5d5d5555115d5d55555d5555115d5d5d5555dd5511ddddd51011001101100000115dddd51
15d5d55115dd5551151555555d5d5551115555555dd5d551155555555555515115555555155555511555555d5555555115dddd51011111001110000115dddd51
15555551155555511151155555555511111155555555551111515111555551111155551515555511115551555115551115555551111110001011000115555551
01111110011111100111111111111110011111111111111001111111111111100111111111111110011111111111111011111111110000001111111111111111
11111111111111111111111111111111011111111111111070000000000011110101000000100010d115551ddddddddddddddddd0dddddddddddddddddddddd0
11515313313313111000000010111111100000000000000170000000000010010101000000100010d11555111111111111111111d11111111111111111111115
11513313313515111000000001011111100000000000b33170000000011110010010100001000100d11555511111111111111111d11111111111111111111115
11313313313513111000000010111011100000000000333170000000010010010001010010001000d11555515555555155555551d11555515555555155555515
1131331531311131100000000101100b100000000333333170000013110010010000111100010110d11555515555555155555551d11555515555555155555515
11313513513135311000000010111013100000000310333170000030010010010011000111100110d11555515555555155555551d11555515555555155555515
11513315313111311000000001011003100000131301333170033311010010010111000000000010d11555111111111115555511d11555111111111115555515
11313513513313111000000010111111100000300310333170031030010010010100000000000000d11111115555555511111115d11111115555555511111115
113133135133131110000000010110111001111013013331b333011101001001007aaa00000a0000d115551500000000d1155515d115551501dddd10d1155515
11b31313515111311000000010111003100100300310333133331030010011110a999aa000079000d115551500000000d1155515d11555151d555551d1155515
11111313513135311000000011011013111100101301333133330111010011110a9aaa90000a9000d115551500000000d1155515d1155515dd0000d5d1155515
11111315515111311000000000111003100100300310333133331030011111110a9aaaa000099000d115551500000000d1155515d1155515d50000d5d1155515
11313515513515111000000000011111100100101301333133330111011111110a9aaa90000a9000d115551500000000d1155515d1155515d50000d5d1155515
11515513515515111000000000000111100100300310333133331011111111110a9aaa9000099000d115551500000000d1155515d115551515dddd51d1155515
115155155155151110000000000000011001001013013331333101111111111109aaaa9000099000d115551500000000d1155515d115551511555d11d1155515
01111111111111100111111111111110011111111111111033311111111111110099990000009000d111111500000000d1111115d111111510111100d1111115
00011111000000001111111101000010000000dddd000000011110000000000000000111b3000111d1155515ddddddddd1111115d1155515ddddddddd1155515
0001111100000000100000010100001000007b1111dd00001000000000d500000000013155300131111555111111111111155515d11555111111111111155515
00011111111111001111111101000010000b11111111d00001100050005500110003311105533111111555511111111111555515d11555511111111111155515
0001111111111100010000100100001000d1113315111d0000000051155100000005515100555151555555515555555155555515d11555515555555155555515
0000000011111100011111100100001000d1151331531d0000005150055110000035515100055151555555515555555155555515d11555515555555155555515
111110000000000001000010010000100d1d31513315d1d000015050551001500355515100055151555555515555555155555515d11555515555555155555115
111110000000111101000010010000100d15dd1513db115000d050505510055db550015100000151111111111111111111555515d11111111111111111111115
0000000000001111010000100100001001d111dddd11151005005055510555d15500001100000011555555555555555551555515155555555555555555555551
11111111111111110000001111111111011111110000020000020000000002000020000000000000000022222222000000022222222000000000000000000000
15555551100011010001111115555551115551150000220000020000000002000020000009009090002244444444220002244444444220000002222222220000
15dddd51100001110011111015dddd511555555500222120002120000000022000220000008aa800002444444449420002444400149120000224444444442200
15dddd51100000110110011015ddddd1155dd5550022122000212200002002200222200009a77a00022444444444442022444440014142000244444444494200
15ddd5d1110000011100011015ddddd115ddd5d50221122002112120002021200212200000a77a90022444411144412022444444421442002244444444444420
155dddd1101000011110110015ddddd11555555d21112212211122120222212021122000008aa800022444400114012022444444241141002244444444444420
15dddd51100100011111100015dddd5115dddd552111111221111112021211122112122009090090012244440014012012244422444420002244444001444120
1111111101111110111100001111111115ddd5150111111001111110221121111121111200000000012222244441242011222224444420001224444400140120
155555511000000000000001155555510155515d00000000009999000007700000070000a7a9999900112224422122100112111299a090001222224444412420
15dddd155100000000000015515ddd5115dddd5d000000000944449000766700007a900004a99440000111122411200000111011100000000112222422112210
1555d55dd51100000000115dd55ddd5115ddddd500000000944444490007700007aaa90009799940000011124444200000110011000000000011111244442100
15dd55ddd5551111111155ddddd5dd5115ddddd500000000999aa9990766667007aaa90009a999900000111499a0900000110011000000000000101499a09000
15d5ddddd5d5555115555ddddddd5d5115ddddd500000000955aa559765555670a999900099a994000011200110000000122001200000000000010199a999000
155dddddd5dddd5115d5ddddddddd551155ddd550000000095444449650000567556559000999400000114400140000001144012400000000000112244442000
11555555555555511555555555555511115555550000000095444449565005650aaaa900000a9000000002490119000000024901290000000000111122220000
11111111111111111111111111111111111111110000000099999999056776500000000007a99940000000229a9000000000249a900000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000008000000104020000400000000000202020000020202000002000000000002020200000202020101020000000000000000000000000000000000000000000002000000000000020202000002000000020000000000000202020201020202000000000000000000000002000002020000808080000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1a1b1b1b0b1b1b1a1b1b1b1b1b1b1a1b151617170d1717151617170b17171516464646460b4646464646460d464646464d4e4f4f0d4f4f4d4e4f4f4f4f4f4d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b2b2b002b2b2a2b2b2b2b2b2b2a2b25262727002727252627270027272526565656560056565656565600565656565d5e5f5f005f5f5d5e5f5f5f5f5f5d5e0000656667686566676865666768fd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b00000000001a1b00000000001a1b15160000000000151600000000001516464600000000005252000000000046464d4e00000000004d4e00000000004d4e52523333333333333333333333335252520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000002a2b00000000002a2b25260000000000252600000000002526565600000000006262000000000056565d5e00000000005d5e00000000005d5e52523031303130313031303130315252620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b00000000001a1b00000000001a1b15160000000000151600000000001516464600000000005252000000000046464d4e00000000004d4e00000000004d4e5252181918191a1b1a1b181918195252520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000002a2b00000000002a2b25260000000000252600000000002526565600000000006262000000000056565d5e00000000005d5e00000000005d5e5252282928292a2b2a2b282928295252620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b00000000002a2b00000000001a1b15160000000000000000000000001516464600000000000000000000000046464d4e0000000000000000000000004d4e52521a1b1a1b1c1d1e1f1a1b1a1b5252520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000000f0000000000002a2b25260000000000000000000000002526565600000000000000000000000056565d5e0000000000000000000000005d5e52522a2b2a2b2c0c0c2f2a2b2a2b5252620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b00000000001a1b00000000001a1b15160000000000151600000000001516464600000000005252000000000046464d4e00000000004d4e00000000004d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000002a2b00000000002a2b25260000000000252600000000002526565600000000006262000000000056565d5e00000000005d5e00000000005d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b00000000001a1b00000000001a1b15160000000000151600000000001516464600000000005252000000000046464d4e00000000004d4e00000000004d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000002a2b00000000002a2b25260000000000252600000000002526565600000000006262000000000056565d5e00000000005d5e00000000005d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b1a1b001a1b1a1b1a1b001a1b1a1b15161516001516151615160f15161516464646460046465252460000004646464d4e4f4f004f4f4d4e4f0000004f4d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b2a2b0f2a2b2a2b2a2b0f2a2b2a2b252625260f2526252625260025262526565656560f56566262560000005656565d5e5f5f0f5f5f5d5e5f0000005f5d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b000000000000000f00000000000c0c0d00000000000000000000000000000b0b0000000000000f000000000000000d0d000000000000000000000000004d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000002a2b00000000000c0c2a2b0000000000000000000000002526565600000000006262000000000056565d5e0000000000000000000000005d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b00000000001a1b00000000001a1b15160000000000151600000000001516464600000000005252000000000046464d4e00000000004d4e00000000004d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000002a2b00000000002a2b25260000000000252600000000002526565600000000006262000000000056565d5e00000000005d5e00000000005d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b00000000001a1b00000000001a1b15160000000000151600000000001516464600000000005252000000000046464d4e00000000004d4e00000000004d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000002a2b00000000002a2b25260000000000252600000000002526565600000000006262000000000056565d5e00000000005d5e00000000005d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b1a1b001a1b1a1b1b0000001b1a1b15161500000015151615000000151516464646000000465252460000004646464d4e4f0000004f4d4e4f0000004f4d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b2a2b0f2a2b2a2b2b0000002b2a2b25262500000025252625000000252526565656000000566262560000005656565d5e5f0000005f5d5e5f0000005f5d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b0000000000000000000000001a1b15160000000000252600000000001516464600000000000000000000000046464d4e0000000000000000000000004d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b0000000000000000000000002a2b252600000000000f0000000000002526565300000000000000000000000056565d5e0000000000000000000000005d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b1b0000001b1a1b1b0000001b1a1b15161500000015151615160015161516464646460f46465252464600464646464d4e4f4f0f4f4f4d4e4f0000004f4d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b2b0000002b2a2b2b0000002b2a2b25262500000025252625260f2526252656565656005656626256560f565656565d5e5f5f005f5f5d5e5f0000005f5d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b00000000001a1b00000000001a1b15160000000000151600000000001516464600000000005252000000000046464d4e00000000004d4e00000000004d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000002a2b00000000002a2b25260000000000252600000000002526565600000000006262000000000056565d5e00000000005d5e00000000005d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b00000000001a1b00000000001a1b15160000000000151600000000001516464600000000005252000000000046464d4e00000000004d4e00000000004d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b00000000002a2b00000000002a2b25260000000000252600000000002526565600000000006262000000000056565d5e00000000005d5e00000000005d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1b1b1b001b1b1a1b1b1b1b1b1b1a1b15161717001717151617170017171516464646460046464646464600464646464d4e4f4f004f4f4d4e4f4f4f4f4f4d4e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a2b2b2b0b2b2b2a2b2b2b2b2b2b2a2b252627270d2727252627270b27272526565656560b5656565656560d565656565d5e5f5f0d5f5f5d5e5f5f5f5f5f5d5e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010300003c61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a1f200c4520c4510c4410c4310c4210c4110c4110c4100c4100c4100c4100c4100c4120c4120c4120c4120c4120c4210c4310c4410c4510c4610c4710c4020c4020c4020c4020c4020c4020c4020c4020c402
010f00000004400011000001c7141c7151c51510001237040704007011000001c7141c715000001c515237040504405011000001c7141c7152351510001240150204002011000001c7141c715000001c51523714
010f00000c04300000000001871418715185151c0001c700246150000000000187141871500000185151f7040c04300000000001f7141f7151f715100001f015246150000000000187141871500000245151f714
010f00000304403011000001b7141b7151b51510001237040704007011000001b7141b715000001b5152370405044050110000020714207152451510001240150a0400a011000001a51526515225151d51522714
010f00000c043287102b7101871418715185152471024702246152f7102b71018714187152b710185152b7100c0432d710307101f7141f7151f715247101f01524615347102b715187141871500000245151f714
010f00000c04324510275101871418715185151b51033700246152c5102b510187141871527510185151f7040c04327510245101f7141f7151f715245101f015246152451022510187141871522510245151f714
010f00000804408011000001b7141b7151b51510001237040804008011000001b7141b715000001b5152370407044070110000022714227152751513001270150704007011000001a51526515225151d51522714
010f00000c04330700337001871430710307152e7102e715246152e7102e71518714187152e700185151f7040c04333700307001b5142c5102c5152b5102b515246152751027515337051a71526715227151d715
010e0000184251d3252032524425356152c325184251d32520325184251d3252c325356151d32520325184251d32520325184251d32535615244251d32520325184251d3252c3252442535615203251842529325
010e00000c0430544505435054450543505445054350544501435014450143501445014350144501435014450c0430344503435034450343503445034350344500435004450043500445004350c0430043500445
010e00002042524325293252c4251d3252032524425293252c3251d4252032524325294252c3251d3252042524325293252c4251d3252032524412293252c3251d4252032524325294252c3251d3252042524325
010e00000c043014350144501435014450143520415014350c04320415014350143501435014451d415204150c043014350144501435014450143501445014350c04300445004350044500435004350043500445
010e0000182151d3251d3251d325356151d325304201d3252e4202e4201d3251d325356151d325292202c2202c2201d3251d3251d325356151d3252e4201d325294201b3251b32527420356151b3251b3251b325
010e00000c043014450143501425034450343503425034150c04305445054350542508445084350842508415356150a4450a4350a425356150c4350c4250c4150c04300445004450044500445004450043500435
010e000029420294112941229415356152b4202b4112b4122d4202d4112d4122d4123561530420304123041232411324103241032412354113541235412294163541635416294162941635416354162941629416
01100000070402671524815247150b0402671524815075010c04024715248150d040237250e0402481500000070402571524815267150b04023715248151d7150c04023715248150d0401d7150e0402481507501
011000000c50022735230252873522025237352672522035237252803523725280352672528005260050c5000c5002e7352f0252e7352f0252b7352802526735220251f735210251c7351f0250c5000c5000c500
01100000070402b715248151f7150b04030715248152d7150c04023715248150d040237150e0402481523715130400000030715000002f71500000070430000029715280152971528015297151c0052e7110a700
0110000035725340253571534025357153402532715300252e7252b0352d725280352b7252d0352f7253203537725000053772500005377250000524815000052b0152b7152b0152b7152b0151f7052f7110a700
0110000009040020003271502000317150200009043020002b7152a0152b7152a0152b7151e005307110c700000401c015297152d7002871500000040401f01529715257002871500700050401f715070400c501
0110000037725000053772500005377250000524815000052b0152b7152b0152b7152b0151f7052f7110a70024815180152b7252d7002b7253600524815220153072524815307252a0052481528715248153c715
0110000037725000053772500005377250000524815000052b0152b7152b0152b7152b0151f7052f7110a700248152d7352e0252d7352e0252d735248153402532725248152e7252f025248152b0352481528735
010e00000c0433f2153f215243032461018615243033f2150c043243033f2153f215246101203403041000410c043001053f2153f21524610186153f215003040c0433f215000053f21524610000140c02118031
010e00000c0450015500140000350c043001400003500324001550014000035001400c043186153f215003240c0450015500140000350c043001400003500324001550014000035001400c043186153f21500324
010e00000c0430010500100000050c0430010000005003040c0430010000005001000c0431202403031000310c0430010500100000050c0430010000005003040c0430010000005001000c043000140c01118021
010e00000c0450015500140000350015500140000350032400155001400003500140000351861430600003240c045001550014000035001550014000035003240015500140000350014000035186143060000324
010e00000c0433f2153f215000052461018615000053f2150c043001003f2153f215246101200403000000000c043001053f2153f21524610186153f215003040c0433f215000053f21524610000040c00018000
010e00000c0450015500150000050c043001500000500304001550015000005001500c043186153f215003040c0450015500150000050c043001500000500304001550015000005001500c043186153f21500304
011400002743018726217161871627430187162171627430295150040026435264352443526435247162043000400000001d430004002772618716217161871627700187162d5151870024615187162d51518700
011400000c04305320295150c320306150332005320295050c043053201d22505320306151d225000000c04305330000001b42005320306150000003320053300c04300320335150c043033200f3300432010330
011400002e4302a72627716247162051524716304302c430000000b2100c2100d2200f2101e420204101e420314302d7262a716277162351527716334302f4302f7262b51528716257162b5152b5152b5152b515
011400000c043083202051506330306150c04306320083300c0430b32000310013200331006320083100b9500c043099400b9400c043306150b330235150c0430994019515079400c04330615129400794013940
0114000027400187002171618716270001800021716187162740018700217161801627000184152171618716274001870021016187161831518415217161801627400187002151624506275162d3152171118016
010c00001075513755187451c7451f735247252b71512755157551a7451e74521735267252d71514755177551c7452074523735287252f7153472500000000000000000000000000000000000000000000000000
010c0000000001072513725187251c7251f725247252b70512725157251a7251e72521725267252d70514725177251c7252072523725287252f72534705000001ca051ca051ca051ca051ca051ca051ca051ca05
012000001474014731147211471516740167311672116715197401973119721197151b7401b7311b7211b7111b7101b7121b7121b7121b7151970019700197001970019700197001b7001b7001b7001b7001b700
012000001272012720127251270510720107201072510705117201172011725117051572015720157201572015722157221572215725057000570005700007000070006705087050970009700097000970009700
012000000102001020010200102506020060200602006025080200802008020080250402004020040200402004020040200402204022040250400500000000000000000000000000000000000000000000000000
000700000c6241c6252b6002f60024600286002b6002f6003060034600376001360415604176040c6040e60410604116041360400000000000000000000000000000000000000000000000000000000000000000
000100002c2502b6202a2502962028250276202625025620242502362022250216202025000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002a3502a5102a515245653005030510305152a565361503651036515365053450029500295002f5003f500335003450029500295002f5003f500335003450029500295002f5003f500005000050000500
000200001021304611102230462110223046311023304631102430464110253046511026304661102630465110253046511024304641102430463110233046211022304621102130461110213046111021304611
000100000c1500e0511105114051170511705014051120510f0510c15100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200003f6142646525361242512345122341212413f6041f3050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b3501b2501c1511d1411f141211312313127121371213b1101b3301b2301c1311d1311f131211312312127121371113b1101b3101b2101c1111d1111f111211112311127111371113b1100000000000
000100000905009040090400903009031090310902109021090210a0210b0210b0210c0210d0200e0210f02111011120111c0011a0011700116001140011200111001100010d0010d00100001000010000100001
000300000c7500f041130311312500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000296632866528604276532765426605256432564524604236432264421603206351e6351c6031b6341762314604106230c625086030661503613026040c0040740400604083040c004172041160400404
0002000000373016732b3730167300473233731c26301663053631a26301663016530d253024531e3530164300343054431c2430163325333016330033325423016230162309323016231d313016131021300413
000100000f12500000000000710500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000c34300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0005000011574160741357418074155641a064165641b054185541d0541a7541f5441b044217441d544220441f744245342103426734220242772424014297140070400704007040070400704007040070400704
000600000b07012741127350c07013741137350d07014741147350f0701674116735182001840018300185021800512200122050a2000a4000a3000a0050a70500000000000d0001400014005000000000000000
000300000c343236450933520621063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
00020000187551a5551c7551554517745195451273514535167350f52511725135250c7150e515107150060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000600001c36311000103331031310303107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00002d27321363164530c3430733303323013130d50309503075031550300003000030000300003000031d303123031b0030000300003000030000300003153030b3031a7031f5031b003217031d50322003
00010000352103751534100371003f10039100331001f1001f1001f1001f100231002a10034100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c0150c0050c005110350c0050c0050c00516055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
00020000071540f163163730b22332643216331c6231861315613136130e6130a61304600000000000000000000000b1010710105101031010110100000000000000000000000000000000000000000000000000
000100001b5611e06125061010001a0511d0512405100000197411c7412374100700187301b731227310050000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002336311000103330400010705107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 02 03 43 44
00 02 03 43 44
00 04 03 43 44
00 04 03 43 44
00 02 05 43 44
00 02 05 43 44
00 04 06 43 44
00 04 06 43 44
00 07 08 43 44
02 04 08 43 44
01 0b 0a 43 44
00 0b 0a 43 44
00 09 0a 43 44
00 09 0a 43 44
00 0c 0d 43 44
00 0c 0d 43 44
00 0c 0d 43 44
00 0a 0d 43 44
02 0e 0f 43 44
01 10 11 43 44
00 12 13 43 44
00 10 11 43 44
00 12 13 43 44
00 14 16 43 44
00 14 15 43 44
00 14 16 43 44
02 14 15 43 44
01 19 1a 43 44
00 19 1a 43 44
00 17 18 43 44
00 17 18 43 44
00 1b 1c 43 44
02 1b 1c 43 44
01 21 1e 43 44
00 21 1e 43 44
00 1d 1e 43 44
00 1d 1e 43 44
00 1f 20 43 44
02 1f 20 43 44
04 22 23 43 44
03 24 25 26 44
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
