pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--updates

--[[ 
to do:

flags:
0 - wall
1 - barrier
2 - spikes
3 - jump
4 - coins
5 - signs
6 - side dash
7 - gravity flip

cartdata:
0:room
1:time
2:check digit
3:deaths
4:coins
5:coin1
6:coin2
7:coin3
8:coin4 
etc..

track names:
1: bermeja theme
2: cascading caverns
3: worth its weight in gold
]]--

function _update()
	_upd()
end

function _draw()
	_drw()
	colour()
	inittimer()
end

function _init()
	_startgame()
	music(0,0,1)
end


-->8
--game loop

function _startgame()
	
	_upd=menu
	_drw=menu
	
	cartdata("bermejafinal")
	
	menuitem(3,"show timer",turntimer)
	
	--player
	p={
		x=64,
		y=88,
		dx=0,
		dy=0,
		onground=false,
		sprite=64,
		flipped=false,
		flippedy=false,
		sliding=false,
		moving=false,
		wallsliding=false,
		jumpboost=3.4,
		dash=false,
		doublejump=false
	}
	
	--physics
	grav=0.3
	maxspeedx=1.7
	maxspeedy=-3
	maxspeedyu=3
	friction=0.8
	dashcount=0
	canflip=false
	
	--locations
	spawns={
		{72,88},
		{136,88},
		{264,72},
		{392,72},
		{520,72},
		{648,72},
		{776,88},
		{8,216},
		{128,176},
		{264,200},
		{392,200},
		{520,184},
		{648,184},
		{776,200},
		{904,216},
		{968,296},
		{880,312},
		{752,352},
		{632,360}
	}
	
	room=0
	roomchange=false
	
	gotcoins={
		false,
		false,
		false,
		false
	}
	
	saws={
		{224,167},
		{344,208},
		{440,200},
		{440,192},
		{440,184},
		{440,176},
		{440,168},
		{440,160},
		{488,200},
		{488,174},
		{488,166},
		{560,144},
		{568,144},
		{576,144},
		{584,144},
		{592,144},
		{592,152},
		{592,160},
		{592,168},
		{592,176},
		{592,184},
		{568,168},
		{568,176},
		{568,184},
		{568,192},
		{576,208},
		{584,208},
		{592,208},
		{600,208},
		{608,208}
	}
	
	--particles
	smoke={}
	wind={}
	clouds={}
	jump={}
	deadanim={}
	drip={}
	
	--other
	palt(14,true)
	palt(0,false)
	t=0
	mapx=0
	mapy=0
	roughness=0
	count=0
	planespd=55
	planex=40
	jolt=false
	deaths=0
	canwallslidel=true
	canwallslider=true
	timer=false
	timestart=0
	menucursor=98
	loadedtime=0
	coins=0
	sawspr=0
	cutscene2done=false
	cutscene3done=false
	changemapy=false
	dashy=0
end

function updategame()
	player()
	playmusic()
	dset(1,round(((time()-timestart)+loadedtime)))
end

function drawgame()
	basics()
	drawsaws()
	drawplayer()
	drawmap()
end

function playmusic()
	if mapy==128
	and changemapy then
		music(11,100,2)
	elseif mapy==256
	and changemapy then
		music(22,100,3)
	end
end

function loadgame()
	_upd=updategame
	_drw=drawgame
	loadedtime=dget(1)
	room=dget(0)
	--room=16
	deaths=dget(3)
	coins=dget(4)
	timestart=time()
	p.x=spawns[room+1][1]
	p.y=spawns[room+1][2]
	mapx=flr(p.x/128)*128
 mapy=flr(p.y/128)*128
 if mapy==128 then
 	music(11,100,2)
 elseif mapy==256 then
 	music(22,100,3)
 	p.flipped=true
 end
	if dget(5)==1 then
		mset(56,13,46)
	end
	if dget(6)==1 then
		mset(75,0,46)
	end
	if dget(7)==1 then
		mset(14,26,46)
	end
	if dget(8)==1 then
		mset(63,26,46)
	end
	if dget(9)==1 then
		mset(109,20,46)
	end
	roughness=0
	fade()
end

function newgame()
	dset(0,0) --room
	dset(1,0) --time
	dset(2,1) --check digit
	dset(3,0) --deaths
	dset(4,0) --coins
	for i=1,5 do
		dset(i+4,0)
	end
	_upd=cutscene
	_drw=cutscene
	roughness=0
	fade()
end

function menu()
	cls(12)
	map(112,-0.01)
	particles(nil,nil,"wind",nil,nil,1,"right")
	spr(235,42,20,5,2)
	spr(74,38,menucursor)
	print("load game",46,100,9)
	print("new game",48,110,9)
	if roughness%0.1>0.05	then
		pal(10,13)
		pal(15,12)
	else
		pal(15,13)
		pal(10,12)
	end
	spr(69,40,56+sin(time())*2.3,5,3)
	pal()
	palt(14,true)
	palt(0,false)
	if btnp(ƒ)
	and menucursor==98 then
		menucursor+=10
	elseif btnp(”)
	and menucursor==108 then
		menucursor-=10
	end
	if btn(—) then	
		if menucursor==98
		and dget(2)==1 then
			sfx(18)
			loadgame()
		else
			sfx(18)
			newgame()
		end
	end
	roughness+=0.01
	changemapy=true
end
-->8
--player

function player()
	moveplayer()
	playersprite()
end

function died()
	playerdead=true
	tempx2=p.x
	tempy2=p.y+7
 p.x=spawns[room+1][1]
 p.y=spawns[room+1][2]
 jolt=true
 p.dash=false
 deaths+=1
 grav=0.3
 p.dy=0
 p.dx=0
 p.flippedy=false
 if mapy==256 then
 	p.flipped=true
 end
 dset(3,deaths)
 sfx(15)
end

function drawplayer()
	--draw sprite
	spr(p.sprite,p.x,p.y,1,1,p.flipped,p.flippedy)
	if p.onground
	and grav>=0 then
		tempx=p.x+3
		tempy=p.y+8
	end
	if playerjump
	and grav>=0 then
		particles(tempx,tempy,"jump")
	end
	if playerdead then
		particles(tempx2,tempy2,"dead")
	end
end

function moveplayer()
	--controls
	if btn(‹)
	and (getflag(p.x-1,p.y+2,0)
	or getflag(p.x-1,p.y+6,0))
	and not collision("left",1)
	and not p.onground
	and p.flipped
	and canwallslidel then
		p.wallsliding=true
		p.dy=0
	elseif btn(‹) then
		p.dx-=1
		p.moving=true
		p.flipped=true
		p.wallsliding=false
	elseif not btn(‘) then
		p.wallsliding=false
	end
	if btn(‘)
	and (getflag(p.x+8,p.y+2,0)
	or getflag(p.x+8,p.y+6,0))
	and not p.onground
	and not p.flipped
	and not collision("right",1)
	and canwallslider then	
		p.wallsliding=true
		p.dy=0
	elseif btn(‘) then   
		p.dx+=1
		p.moving=true
		p.flipped=false
		p.wallsliding=false
	elseif not btn(‹) then
		p.wallsliding=false
	end
	if btn(Ž)
	and (p.onground
	or p.doublejump) then
		if p.doublejump then
			p.dy=0
		end
		p.dy+=p.jumpboost*sgn(grav)
		p.onground=false
		if not p.doublejump then
			playerjump=true
		end
		sfx(16)
	elseif btnp(Ž) 
	and p.wallsliding then
		p.dy+=3.6*sgn(grav)
		if p.flipped then
			p.dx+=6
		else
			p.dx-=6
		end
		sfx(16)
	end
	
	checkplayer()
	
	-- dx --
	--------
	
	pdx()
	
	-- dy --
	--------

	pdy()

end

function playersprite()
	--moving
	if p.moving==true
	and p.dx!=0 then
	t+=0.25
	if t==4 then
		t=1
	end
	if t==1 then
		p.sprite=64
	elseif t==2 then
		p.sprite=80
	elseif t==3 then
		p.sprite=96
	end
	--sliding
	elseif p.moving==false
	and p.dx!=0
	and p.onground then
		p.sprite=65
	--not moving
	elseif p.moving==false then
		p.sprite=64
	end
	
	--jumping 
	if not p.onground
	and p.dy>0 then
		p.sprite=66
	--falling
	elseif not p.onground
	and p.dy<0
	and not p.wallsliding then
		p.sprite=67
	--wall sliding
	end
	if p.wallsliding then
		p.sprite=68
	end
end

function checkplayer()
	if not btn(‹) 
	and not btn(‘) then
		p.moving=false
	end
	
	if p.onground==false then
 	maxspeedx=1.4
	else
		maxspeedx=1.7
	end
	
	if p.onground then
		p.wallsliding=false
	end

	if not getflag(p.x+3,p.y+8,0)
	or not getflag(p.x+3,p.y-1,0) then
		p.onground=false
	end
	
	if getflag(p.x+3,p.y+3,4) then
		coins+=1
		sfx(19)
		dset(4,coins)
		if room==3 then
			dset(5,1)
		elseif room==4 then
			dset(6,1)
		elseif room==7 then
			dset(7,1)
		elseif room==10 then
			dset(8,1)
		elseif room==13 then
			dset(9,1)
		end	
		mset((p.x+3)/8,(p.y+3)/8,46)
	end
	
	if getflag(p.x+3,p.y+3,6)
	and btn(Ž) then
		p.dash=true
		dashy=p.y
		sfx(17)
	end
	
	if getflag(p.x+3,p.y+3,7)
	and btn(Ž) then
		if canflip then
			grav*=-1
			p.dy+=1
			p.flippedy=not p.flippedy
			canflip=false
			sfx(33)
		end
	else
		canflip=true
	end
	
	if p.dash then
		p.dx=0
		p.dy=0
		p.y=dashy
		if couldcollide(p.x,p.y,0,4,-1)
		or couldcollide(p.x,p.y,0,4,1) then
			p.dash=false
			p.dx=0
		end
		if p.flipped
		and not couldcollide(p.x,p.y,0,4,-1) then
			p.x-=4.4
		elseif not couldcollide(p.x,p.y,0,4,1) then
			p.x+=4.4
		end
		dashcount+=1
		if dashcount>=5 then
			dashcount=0
			p.dash=false
		end
	end
	
	if getflag(p.x+3,p.y+3,3) then
		p.doublejump=true
	else
		p.doublejump=false
	end
	
		--saws
	for i=1,#saws do
		if (p.x+3>saws[i][1]
		and p.x+3<saws[i][1]+7)
		and (p.y+3>saws[i][2]
		and p.y+3<saws[i][2]+7) then
			died()
		end
	end
end

function pdx()
	--stopping
	if p.dx>0 then
		if p.dx<0.4 then
			p.dx=0
		end 
		if collision("right",0) then
			p.dx=0
			snaptotilex()
		end
	elseif p.dx<0 then
		if p.dx>-0.4 then
			p.dx=0
		end
		if collision("left",0) then
			p.dx=0
			snaptotilex()
		end
	end
	
	--max speed
	if p.flipped then
		if p.dx<-maxspeedx then
			p.dx=-maxspeedx
		end
	else
		if p.dx>maxspeedx then
			p.dx=maxspeedx
		end
	end
	
	p.dx*=friction

	p.x+=p.dx
	
	if room==4 
	and not p.flipped
	and p.x<512 then
		p.x=512
	end
	
	if room==5
	and not p.flipped
	and p.x<640 then
		p.x=640
	end
end

function pdy()
	if p.wallsliding then
		p.dy-=grav/1.01
	end
 if not p.onground then
		p.dy-=grav
	end
	
	if grav>=0 then
		p.dy=max(p.dy,maxspeedy)
	else
		p.dy=min(p.dy,maxspeedyu)
	end
	
	p.y-=p.dy
	
	if p.y<=0 then
		p.y=0
		p.dy=0
	end
	if p.dy<=0 then
		if getflag(p.x+2,p.y+10)
		or getflag(p.x+5,p.y+10) then
			p.dy=-0.7
		end
		if collision("down",0)
		and not p.flippedy then
			p.dy=0
			snaptotiley()
			if not p.flippedy then
				p.onground=true
			end
		end
		if collision("down",2) then
			if p.dy<0
			or p.wallsliding then
				died()
			end
		end
	elseif p.dy>0 then
		if collision("up",0) then
			p.dy=0
			snaptotileyu()
			if p.flippedy then
				p.onground=true
			end
		end
		if collision("up",2)
		and p.dy>0 then
			died()
		end
	end
end
-->8
--tools

function getflag(x,y,flag)
	if fget(mget(x/8,y/8),flag) then
	 return true
	else
	 return false
	end
end	

function snaptotiley()
	p.y=flr((p.y+4)/8)*8
end

function snaptotileyu()
	p.y=flr((p.y-4)/8)*8+8
end

function snaptotilex()
	p.x=(flr(((p.x+4)/8))*8)
end


function screenshake(dur)
	if (dur*30>count) then
		mapx+=rnd(2)-1
		mapy+=rnd(2)-1
		count+=1
		camera(mapx,mapy)
	else
		if mapx>0 then
			mapx-=1
		elseif mapx<0 then
			mapx+=1
		end
		if mapy>0 then
			mapy-=1
		elseif mapy<0 then
			mapy+=1
		end
		if abs(mapx)<1 then
			mapx=0
		end
		if abs(mapy)<1 then
			mapy=0
		end
	end
end

function screenjolt()
	mapy+=1
	camera(mapx,mapy)
	mapy-=1
end

function timedprint(text,x,y,colour)
	print(sub(text,0,flr(count)),x,y,colour)
	count+=0.5
end

function round(number)
	number*=100
	return(flr(number-number%0.01)/100)
end

function turntimer()
	timer=not	timer
end

function textbox(text,colour,colour2)
	rectfill(mapx+(64-(2*#text)),95+mapy,mapx+(2*#text)+66,120+mapy,colour)
	rect(mapx+(64-(2*#text)),95+mapy,mapx+(2*#text)+66,120+mapy,colour2)
	print(text,mapx+(64-(2*#text)+2),100+mapy,7)
end

function signs(requestroom)
	if (getflag(p.x,p.y+3,5)
	or	getflag(p.x+7,p.y+3,5))
	and room==requestroom
	and btn(—) then
		return true
	end
end

function fade()
	dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
	for i=0,40 do
  for j=1,15 do
   col=j
    for k=1,((i+(j%5))/4) do
     col=dpal[col]
    end
   pal(j,col,1)
  end
  flip()
 end
 pal()
 palt(0,false)
 palt(14,true)
end

function inittimer()
	local colour
	if mapy==0 then
		colour=0
	elseif mapy==128 then
		colour=7
	end
	if timer
	and _upd==updategame then
		mseconds=flr(round((time()-timestart)+loadedtime)*100)%100
		seconds=flr(round((time()-timestart)+loadedtime))%60
		minutes=flr((round((time()-timestart)+loadedtime))/60)
		if mseconds<10 then
			mseconds="0"..mseconds
		end
		if seconds<10 then
			seconds="0"..seconds
		end
		if minutes<10 then
			minutes="0"..minutes
		end
		print(minutes..":"..seconds..":"..mseconds,mapx+1,9+mapy,colour)
	end
end	

function colour()
	for i=0,15 do
		if i!=10 then
			pal(i,i+128,1)
		end
	end
end

function couldcollide(x,y,flag,j,direction)
	local k=sgn(direction)
	for i=1,j do
		if getflag(x+i*k,y,flag) then
			p.dx=0
			return true
		end
	end
end

-->8
--collision
--courtesy of nerdyteachers

function collision(direction,flag)

	local x1=0
	local y1=0
	local x2=0
	local y2=0

	if direction=="up" then
		x1=p.x
		y1=p.y-1
		x2=p.x+7
		y2=p.y-1
	elseif direction=="down" then
		x1=p.x+1
		y1=p.y+8
		x2=p.x+6
		y2=p.y+8
	elseif direction=="left" then
		x1=p.x-1
		y1=p.y
		x2=p.x-1
		y2=p.y+7
	elseif direction=="right" then
		x1=p.x+8
		y1=p.y
		x2=p.x+8
		y2=p.y+7
	end
	
	if getflag(x1,y1,flag)
	or getflag(x2,y2,flag) then
		return true
	else
		return false
	end
end

-->8
--map

function basics()
	local storeroom=room
	local mapychange=mapy
	setupmap()
		mapx=flr(p.x/128)*128
 	mapy=flr(p.y/128)*128
 	camera(mapx,mapy)
 	if p.x>=896
 	and mapy==0 then
 		camera(0,128)
 		p.x=11
 		p.y=128
 	end
 if jolt then
 	screenjolt()
 end
 map(0,0,0,0,128,64)
 if jolt then
 	line(mapx,mapy+128,mapx+128,mapy+128,0)
 	jolt=false
 end
	room=flr(p.x/128)
	if mapy==256 then
		room=22-flr(p.x/128)
	end
	if mapy==128 then
		room+=7
	end
 if room!=storeroom then
 	roomchange=true
 	dset(0,room)
 else
		roomchange=false 	
 end
 if mapy!=mapychange then
 	changemapy=true
 else
 	changemapy=false
 end
end

function setupmap()
	if mapy<127 then
		cls(12)
	else
		cls(5)
	end
	if room==14 then
		cls(12)
	end
	if mapy==256 then
		cls(6)
	end
	if mapy==0
	or mapy==1
	or room==14 then
		map(112,0,mapx,mapy)
	elseif mapy==256 then
		map(0,32,mapx,mapy)
	end
end

function drawmap()
	canwallslider=true
	if p.y<128
	or room==14 then
		drawclouds()
	end
	
	if mapy==256 then
		local timed=0
		if time()%0.1>0.03 then
			timed=1
		end
		if timed==1 then
			sawspr=1
		else
			sawspr=0
		end
		for i=1,128,8 do
			mset((mapx+i)/8,(mapy+120)/8,109+sawspr)
			if mapx==896 then
				if i<72
				or i>80 then
					mset((mapx+i)/8,mapy/8,221+sawspr)
				end
			else	
				mset((mapx+i)/8,mapy/8,221+sawspr)
			end
		end
	end
	
	ui()
	
	events()
	
	--signs
	checksigns()
end	

function drawsaws()
	local timed=0
	if time()%0.1>0.03 then
		timed=1
	end
	if timed==1 then
		sawspr+=1
	end
	if sawspr==3 then
		sawspr=0
	end
	for i=1,#saws do
		spr(sawspr+204,saws[i][1],saws[i][2])
	end
end

function checksigns()
	if signs(1) then
		textbox("press Ž to jump ",4,2)
	end
	if signs(2) then
		textbox("use Ž to walljump ",4,2)
	end
	if signs(3) then
		textbox("collect coins!",4,2)
	end
	if signs(4) then
		textbox("careful of wind!",4,2)
	end
	if signs(5) then
		textbox("Ž + tokens to use abilities ",4,2)
	end
	if signs(6)
	and _upd!=cutscene2 then
		textbox("bermeja mine",4,2)
	end
	if signs(8) then
		textbox("saws hurt...",4,2)
	end	
	if signs(14)
	and _upd!=cutscene3 then
		textbox("entrance to oil rig",4,2)
	end
	if signs(15)
	and _upd!=cutscene3 then
		textbox("laser beams, do not touch",4,2)
	end 
end

function events()
	if room==0 then
		particles(60,96,"smoke",60,6,1)
		particles(92,96,"smoke",60,6,1)
	elseif room==3 then
		particles(460,104,"smoke",115,0.1,1)
	elseif room==4 then
		particles(nil,nil,"wind",nil,nil,1.2)
		if not getflag(p.x-1,p.y,0) then
			p.x-=0.6
		end
		canwallslider=false
	elseif room==5 then
		particles(nil,nil,"wind",nil,nil,5)
		if not getflag(p.x-1,p.y,0) then
			p.x-=0.8
		end
		canwallslider=false
	elseif room==6 then
		wind={}
		if p.x>816
		and p.x<825
		and not cutscene2done then
			_upd=cutscene2
			if count>210 then
					_upd=updategame
					count=0
					cutscene2done=true
			elseif count>130 then
				textbox("a mine means humans!",3,7)
			elseif count>60 then
				textbox("so this island is bermeja!",3,7)
			else
				textbox("bermeja mine",4,2)
			end
		end
	elseif room==7 then
		particles(36,200,"smoke",200,3,1)
		particles(64,152,"drip",224)
	elseif room==8 then
		particles(214,144,"drip",224)
	elseif room==9 then
		particles(372,192,"smoke",200,3,1)
		particles(283,173,"drip",224)
	elseif room==13 then
		particles(836,180,"drip",224)
	elseif room==14 then
		if p.x>919
		and p.x<927 
		and not cutscene3done then
			_upd=cutscene3
			if count>210 then
					_upd=updategame
					count=0
					cutscene3done=true
			elseif count>130 then
				textbox("they are hiding bermeja!",3,7)
			elseif count>60 then
				textbox("bermeja must have oil!",3,7)
			else
				textbox("an american oil rig???",3,7)
			end
		end
	end
end

function ui()
	local colour
	if mapy==0 then
		colour=0
	elseif mapy==128
	or mapy==256 then
		colour=7
	end
	print("="..coins,7+mapx,1+mapy,colour)
	spr(114,mapx,mapy)
	print("="..deaths,25+mapx,1+mapy,colour)
	spr(115,mapx+18,mapy)
end
-->8
--cutscenes

function cutscene()
	cls(12)
	camera(mapx,mapy)
	spr(1,16,16,2,2)
	particles(nil,nil,"wind",nil,nil,1.5)
	if roughness%0.1>0.05	then
		pal(10,13)
		pal(15,12)
	else
		pal(15,13)
		pal(10,12)
	end
	if roughness<2 then
		timedprint("you are looking for bermeja",11,110,9)
	elseif roughness<2.02 then
		count=0
	elseif roughness<4 then
		timedprint("the island appeared in old\nmaps, yet can no longer be \nfound",12,100,9)
	elseif roughness<4.02 then
		count=0
	elseif roughness<7 then
		timedprint("you have searched for weeks,\nyou decide to head home",11,110,9)
	end
	if roughness>8 then
		planespd+=1+cos(time())
		planex+=1
		screenshake(15)
	else
		planespd=55+sin(time())*roughness
		planex=40
	end
	if roughness>9.5 then
		_upd=updategame
		_drw=drawgame
		count=0
		timestart=time()
	end
	spr(69,planex,planespd,5,3)
	if roughness>7.5 then
		particles(planex+40,planespd+9,"smoke",10,120,4)
		sfx(20)
	end
	pal()
	palt(14,true)
	palt(0,false)
	roughness+=0.01
end

function cutscene2()
	p.sprite=64
	p.dx=0
	p.dy=0
	if p.y<88 then
		p.y-=maxspeedy
	else
		snaptotiley()
	end
	count+=1
end

function cutscene3()
	p.sprite=64
	p.dx=0
	p.dy=0
	if p.y<216 then
		p.y-=maxspeedy
	else
		snaptotiley()
	end
	count+=1
end




-->8
--particles

function drawclouds()
	local x1=rnd(120)+mapx local y1=rnd(55)+mapy
	local x2=x1+rnd(40)+20	local y2=y1+rnd(10)+3
	add(clouds,{x1,y1,x2,y2,rnd(3)/10})
	if #clouds>3 then
		del(clouds,clouds[#clouds])
	end
	if roomchange then
		for i=1,#clouds do
			del(clouds,clouds[i])
		end
		for i=1,#drip do
			del(drip,drip[i])
		end	
	end
	for i=1,#clouds do
		if clouds[i][1]%128<=5
		and clouds[i][3]>(room+1)%8*128+128 then
			del(clouds,clouds[i])
			add(clouds,{x1-150,y1,x2-150,y2,rnd(3)/10})
		end
		clouds[i][1]+=clouds[i][5]
		clouds[i][3]+=clouds[i][5]
		rectfill(clouds[i][1],clouds[i][2],clouds[i][3],clouds[i][4],7)
		rectfill(clouds[i][3]-(clouds[i][3]-clouds[i][1])/10,clouds[i][2],clouds[i][3],clouds[i][4],6)
		rectfill(clouds[i][1],clouds[i][2]+(clouds[i][4]-clouds[i][2])*1.3,clouds[i][3],clouds[i][4],6)
	end
end

function particles(x,y,particle,height,width,speed,direction)
	if particle=="smoke" then
		add(smoke,{x,y,(rnd(2)+1)/2,flr(rnd(2))*5})
		if #smoke>75 then
			del(smoke,smoke[#smoke])
		end
		for i=1,#smoke do
			smoke[i][2]-=smoke[i][3]
			smoke[i][1]+=rnd(2)-1*speed
			if smoke[i][2]<height 
			or abs(smoke[i][1]-x)>width then
				if flr(rnd(100))>=95 then
					del(smoke,smoke[i])
					add(smoke,{x,y,rnd(2)/3,flr(rnd(2))*5})
				end
			end
			pset(smoke[i][1],smoke[i][2],smoke[i][4])
		end
	elseif particle=="wind" then
		add(wind,{mapx+128+rnd(100),rnd(128)+mapy,rnd(3)+1})
		if #wind>75 then
			del(wind,wind[#wind])
		end
		for i=1,#wind do
			wind[i][1]-=wind[i][3]*speed
			wind[i][2]+=sin(time())
			if wind[i][1]<mapx then
				del(wind,wind[i])
				add(wind,{mapx+128+rnd(100),rnd(128)+mapy,rnd(3)+1})
			end
			pset(wind[i][1],wind[i][2],6)
		end
	elseif particle=="jump" then
		add(jump,{x+rnd(2)-1,y,(rnd(2)-1)/3,0.6,pget(p.x+3,tempy)})
		if #jump>7 then
			del(jump,jump[#jump])
		end
		for i=1,#jump do
			jump[i][1]+=jump[i][3]
			jump[i][2]-=jump[i][4]
			jump[i][4]-=0.08
			if jump[i][2]>=tempy then
				playerjump=false
				jump={}
				break
			else
				pset(jump[i][1],jump[i][2],jump[i][5])
			end
		end
	elseif particle=="dead" then
		for i=1,5 do
			add(deadanim,{x,y,rnd(3)-1.5,rnd(3)-1.5})
		end
		if #deadanim>10 then
			del(deadanim,deadanim[#deadanim])
		end
		for i=1,#deadanim do
			deadanim[i][1]+=deadanim[i][3]
			deadanim[i][2]+=deadanim[i][4]
			if abs(deadanim[i][1]-x)>=6
			or abs(deadanim[i][2]-y)>=6 then
				playerdead=false
				deadanim={}
				break
			else
				pset(deadanim[i][1],deadanim[i][2],8)
			end
		end
	elseif particle=="drip" then
		add(drip,{x+rnd(2)-1,y+rnd(height-y),(rnd(2)-1)/20,rnd(2)+1,12})
		if #drip>3 then
			del(drip,drip[#drip])
		end
		for i=1,#drip do
			drip[i][1]+=drip[i][3]
			drip[i][2]+=drip[i][4]
			if drip[i][2]>=height then
				add(drip,{x+rnd(2)-1,y,(rnd(2)-1)/20,rnd(2)+1,12})
				del(drip,drip[i])
			else
				pset(drip[i][1],drip[i][2],drip[i][5])
			end
		end
	end
end
__gfx__
00000000eeeeeaaaaaaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee9999999999993333333333333eeeee33333333333333eeeeeee000000e0000000
00000000eeeaaaaaaaaaaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee99aaaaaaaaaaaaa3bbbbbbbbbbbeee33bbbbbbbbbbbbbb3eeeeeee00000ee00000e
00700700eeaaaaaaaaaaaaeeeeeeeeee11111111111111111111111111999a9aaaaa9aaaaaaa933bbbbb333bee3bbb3bb3bbbb3bbbbb3eeeee000000e00000ee
00077000eaaaaaaaaaaaaaaeeeeeeeee11111111111111111199999999aaaaaaa999a9aaa999a9a333b3a9a3ee3bbbbbbbbbbbbbbbbb3eeee0000000e00000ee
00077000eaaaaaaaaaaaaaaeeeeeeeee111111111111199999aaaaaaaaaa99aaaaaaaaaaaaaaaaaaaa3aaaaaee3bbbbbbbbbbbbbbbbbb3eee0000000ee00000e
00700700aaaaaaaaaaaaaaaaeeeeeeee1111111111119aaaaaaaa99aa999aa9aaaaaaaa9aaaaaaa9aaaaaaa9e3bb3bbbbbbbb3bb3bbbbb3eee000000eee0000e
000000009aaaaaaaaaaaaaaaeeeeeeee111111111111999aa999aaaaaaaaaaaaa9a99aaaa9a99aaaa9a99aaa33bbbbb3bb3bbbbbbbbbbbb3ee000000ee0000ee
000000009aaaaaaaaaaaaaaaeeeeeeee111111111119aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa333bbbbbbbbbbbbbbbbb3bb3e0000000e000000e
44243bb39aaaaaaaaaaaaaaa11111111111111111119aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa33333333333bbbbbbbbbbbbbbbbbbbb30000000eeeeeeeee
4444333e99aaaaaaaaaaaaaa11111311111111111119aaaaa9aaaaaaa99aaaaaaaaaa6aaaaaaa99abbbbbbbb33bbbbbbb3bbb3bbbb3bbbb3000000eeeeeeeeee
44dddeee99aaaaaaaaaaaaaa11111131111111111119a99aaaaa999aaaa999aaa9aaa66aa9a67aaabbbb333b333bbbbbbbbbbbbbbbbbbbb300000eeeeeeeeeee
4d666ddee99aaaaaaaaaaaae11111311111111111119aaaaaaaaaaaaaaaaaaaaaaaa6aaaaaa56aaa33b34443333b3bbbbbbbbbbbbbbbb3b3000000eeeeeeeeee
5d66666de999aaaaaaaaaaae1111311111111111119aaaaaa99999aaa9aaaa99aaa6aa9aaaaaaaaaaa344244b33bbbbbbb3bbbbbbbbbbbb30000000eeeeeeeee
4d666d7eee999aaaaaaaaaee11b1b111111111111199999aaaaaaaaaaaa9aaaaa66aaaaaa999aaaaaaaa4444333bbb3bbbbbbbbbbbb3bbb3000000eee00eeeee
44dddeeeeee9999aaaaaaeee1b111b1111111111119aaaaaaaaaa9aaa99a9aaaaa6a9aaaaaaaa99aa9aaa5423b33bbbbb3bbb3bbb3bbbbb3000000ee000066ee
4d666ddeeeeee99999aeeeee1b111b1111111111119aaa9aaaa99a9aaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444333bbbbbbbbbbbbbbbbbbbb30000000e0006666e
4d66666deeeeedeeeeeeeeeeeeeeeeee11111111119aaaaa444443b33b344444e333333333333333aaaa42443333b3bbbbbbbbbbb3bbbbb30000000000555500
4d666d7eeeeedeeeeeeeeeeeeee2eeee1c111111119aa9aa545443bbbb3445453bbbbbbbbbbbbbbbaaa44444e33333b33bbbbbbbbbbb3bb30000000005d66d50
24dddeeeeeeedeeeeeeeeeeeeee2eede11111111119aaaaa44444433334444443bbb333bbbbb333baa945442e33333333bbbbbbbbbbbbbb3000000005d2222d5
4d666ddeeeed997eeeeeeeeee7ee2edec111111111999aaa44442444444244443bb3444333b34443aaaa4444ee33b33b333bb3bbb3bbbbb30000000056777765
4d66666d9e6e977eeeeeeeeeee7559ee11919111119aaaaa44244445544442443b34424444344244aaaa4244ee3333333b333bbbbbbbb33e0000000056777765
4d666d7ee9e9ee7eee5e666ee2e9959e19991111119a99aa44444444444444443b34444444444444aaa44444ee333333333343bbbbbb3eee000000005d2222d5
44dddeeee25957ee7e9652e9ee27725911919111119aaaaa44545424424545443bb3454442444544a9aa4442eee3333334424433bbb3eeee0000000005d66d50
4d666dde22e2725ee767e29e22e722e5111111111199aa9a44444444444444443b34444444444444aaa94544eeee333324444442333eeeee0000000000555500
4d66666d3eeedeeedeeedeeedeeedeee2222222244443bb33333333e3bb344444444444444444444444444445666666524444242ee8788ee05dddd5033666666
4d666d7eb3ed67ed67ed67ed67ed67e327747742444443b3bbbbbbb33b3444444474442444454424424444245dd66dd524444242ee8788ee5d6aa6d5b3655555
44dddeeeb3ed6ded6ded6ded6ded6de324444442454243b3b333bbb33b342454466444444244444444454444566dd66524244242ee8788eed6a98a6d3465dddd
4d666dde33d666d666d666d666d666d324774742444443b334443bb33b3444444447445444444544444444445dd66dd524244442ee8788eed6a89a6d44465d66
5d66666d44d666d666d666d666d666d42444444244443bb3442443b33bb344444444744444444444444445445666666524424442ee8788ee5d6446d5444465d6
4d666d7e24d666d666d666d666d666d4222222224443bbb3444443b33bbb34444244467446744444444244445dd66dd524424442ee8788ee05d44d504442465d
44dddeee444ddd4ddd4ddd4ddd4ddd42eee22eee42443bb344543bb33bb34424444546444564424445444454566dd66524244242ee8788ee0054250045444465
4244333e444454444424444444445444eee22eee44443bb3444443b33bb344444444444444444444444444445dd66dd524244442ee8788ee0002200044444446
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee676eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee3333333eeeeeeeeeeeeee00eeeeeeee
ee4444eeeeeeeeeeee4444eeee4444eeeee4444e67776eeeeeeeeeeeeeeeeee5555555eeeeeeeeeeeeeeeeeeeeeeeeee3bbbbbbbeeeeeeeeeeee0055eeeeeee0
ee4fffeeee4444eeee4fffeeee4fffeeeeefff4e67777eeeeeeeeeeeeeeee5550300055eeeeeefeeeee4eeeeeeeeeeee3bbb333b2222222222205556eeeee005
ee4fffeeee4fffeeee4fffeeee4fffeeeeefff4e677667eeeeeeeeeeeeeee6755555557eeeeeeaeeeee44eeeeeeeeeee3bb344432424442444405666eee00555
ee3333eeee4fffeeef3333feee3333eeeee3333fe767567eeeeeeeeeeee6671771511177eeeeeaeeeee444eeeee77eee3b3442442444444244405656ee055666
eef333feee3333feee3333eeef3333feeef3333ee762567eeeeeeeeeee67711771d111177eeeeaeeeee44eeeee7777ee3b3444442224422222205666e0556656
ee3333eeeef333eeee3333eeee3333eeeee3333eee766776eeeeeee6667711177161111777777aeeeee4eeeee777777e3bb34544ee2422eeee05666605666666
ee1ee1eeee31331eee1ee1eeee1ee1eeeeee1ee1ee7777776666666777777777776777777777700eeeeeeeee777777773b344444ee2442eeee05566605656666
eeeeeeee05665565650eeeeeeeeeee00eeeeeeeeee6777777777777777777777776777777777700eeeeeeee7777777777eeeeeeeee2442eeee056666ee056666
ee4444ee005500505000eeeeeeee0005eeeeeeeeeee6777777777777777777777777777777777feeeeeeee777777777777eeeeeeee2422eeee055666ee055666
ee4fffeee000e000000eeeeeee000056eeeee0eeeeeee44444499999999999999999999999994feeeeeee77777777777777eeeeeee2442eeee055656ee056666
ee4fffeee000ee0e50eeeeeeeeee0056eeeee0eeeeeeeeeeeee4444999999999999999999944efeeeeee7557575577577557eeeeee2422eeee056666eee05665
ee3333eeee0eeeee6500eeeeeeeeee05e0ee000eeeeeeeeeeeeeeee4444444444444444444eeefeeeee555555555555555555eeeee2242eeee056666eee05666
ee3f33eeee0eeeee650000eeeeeee000000e000eeeeeeeeeeeeeeeeeee00eeeeeeeeeee00eeeeaeeee55555555555555555555eeee2442eeee055666eeee0556
ee3333eeeeeeeeee5000eeeeeeee000550005500eeeeeeeeeeeeeeeeee00eeeeeeeeeee00eeeeeeee5555555555555555555555eee2442eeee055666eeeee055
eee11eeeeeeeeeee00eeeeeeeeeee05665056650eeeeeeeeeeeee6666666666666666666666666ee555555555555555555555555ee2422eeee056665eeeeee00
eeeeeeeeeeeeeeee555555555555555555555555eeeeeeeeeeeed6666666666666666666666666deeeeeeee5555555555eeeeeeeee5d5eeeeee55deeeeeeee11
ee4444eeeeeeeeee5d6d6d6d6d6d6d6d6d6d6d65eeeeeeeeeeeedd66666666666666666666666ddeeeeeee555555555555eeeeeee5d5555ee555d55eeeeee115
ee4fffeeeeec7eee5d6d6d6d6d6d6d6d6d6d6d65eeeeeeeeeeeeddd666666666666666666666dddeeeeee55555555555555eeeeee5d55dd5e555d55588888115
ee4fffeeeeccc7ee56d666d666d666d666d666d5eeeeeeeeeeeeedddddddddddddddddddddddddeeeeee5555555555555555eeee5550055d5dd00dd577777115
ee3333eeeedcccee56d666d666d666d666d666d5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee555555555555555555eee000000000000000088888115
ee33f3eeeeedceee5d6d6d6d6d6d6d6d6d6d6d65eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee55555555555555555555eedddddddddddddddd88888115
ee3333eeeeeeeeee5d6d6d6d6d6d6d6d6d6d6d65eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555555555555555555555e6d6d6d6d6d6d6d6deeeee115
ee1ee1eeeeeeeeee555555555555555555555555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5555555555555555555555556666666666666666eeeeee11
eeeeeeee00000000eeeeeeeeeeeeeeee5dd66dd55555555555555555000000003eeedeeeeeeeeeeeeeeeeee7777777777eeeeeeeeeeeeeee11eeeeeeeeeeeeee
eeeeeeee00000000eeaa7eeeee777eee566dd665566dd6655d6666d500000e00b3ed67e3eeeeeeeeeeeeee777777777777eeeeeeeeeeeeee511eeeeeeeeeeeee
eeeb7eee000a7000eaaaa7eee70707ee5dd66dd55dd66dd556d66d650000eee0b3ed6de3eeeeeeeeeeeee77777777777777eeeeeeee87eee5118888888888888
eebbb7ee00aaa700eaaaaaeee70707ee5666666556666665566dd66500eeeeee33d666d4eeeeeeeeeeee7777777777777777eeeeee8887ee5117777777777777
ee3bbbee009aaa00e9aaaaeeee777eee5dd66dd55dd66dd5566dd665eeeeeeee44d666d4eeeeeeeeeee777777777777777777eeeee2888ee5118888888888888
eee3beee0009a000ee9aaeeeee707eee566dd665566dd66556d66d65eeeeeeee24d666d4eeeeeeeeee77777777777777777777eeeee28eee5118888888888888
eeeeeeee00000000eeeeeeeeeeeeeeee5dd66dd55dd66dd55d6666d5eeeeeeee444ddd44eeeeeeeee7777777777777777777777eeeeeeeee511eeeeeeeeeeeee
eeeeeeee00000000eeeeeeeeeeeeeeee555555555666666555555555eeeeeeee44445444eeeeeeee777777777777777777777777eeeeeeee11eeeeeeeeeeeeee
00007e00000000000000008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000000030
00007e00000000000000008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
00009f8d9e0000000000008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000e7f7f7f6000000000000000000000000000000000000000000000000000000000000001600001600001600000000000000000000000000fc0030
000000008e0000007d8d8dae8d8d8d8d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000057000000000000000000000000000000000000000000000000000000000000000000fc0000000000000000d30030
000000008e0000007e00008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000b300000700e7f7f6000000000000673636364600000000e7f7f7f600000000000000d30000000000000000d30030
7d8d8d8daf0000007e00008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000d70000160000000000000000b300000000000000000000000000b300000000000000000000000000000700000000d30000004300000000d30030
7e000000000000007e00008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000b300000000001600000000000000b300000000000000000000000000000000000000d30000263636364600d30030
7e000000000000007e00008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000d7000000000000004700000000000000000000000000b300000000000000000000000000000000000000fd0000000000000000d30030
7e000000000000009f8d8dae8d8d8d8d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007000000000000000000000000000000000000000000000000000000b300000000d7000000000000d700263636460000000000000000000000d30030
7e000000000000000000008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000005700000000000000000000000000000000000000b300000000000000000000000000000000000000000000000000000000fd0030
7e000000000000000000008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000b30000000000d7000000000000000000000000004700000000000000000000000000000000000000000000000000000000000030
9f8d8d8d8d9e00000000008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000b300000000000000000000000000d700000000000000000000000000000000000000000000000000d70000000000000000000030
00000000008e00000000008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000b3000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000030
8d8d8d8d8dae8d8d8d8d8daf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e7f7f7f7f7f7f6004700000000000000000000000000000026363646000000000000000000000000000000000000e7f7f7f7f6000000000000000030
00000000008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000002636363646000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030
00000000008e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000066666666000000000000000005666666666666506666666605666666666665500eee0eee0eee0eee0eee0eeeee6d6eeeee66d6eeeee66dee15555551
50555505606666060055550550555500005666566566650065666656005666566566550050e0d7e0d7e0d7e0d7e0d7e0e6d6666ee66d666ee666d66e11111111
55565556666566660556555665556550055566666666555066665666055566666666655050e0d0e0d0e0d0e0d0e0d0e0e6d66dd6666d6666d666d66ee111111e
656665666666666605666566665666500556666556666550666666660556666666566650660ddd0ddd0ddd0ddd0ddd006660066dd6600dd66dd00666ee8788ee
666666666666656605566666666665500566656666566650665666560566656666666550560ddd0ddd0ddd0ddd0ddd06d66006666dd0066d66600dd6ee8788ee
666566666660666600556666666655000556555665556550655565550556666666665550660ddd0ddd0ddd0ddd0ddd066dd66d6e6666d666e66d666dee8788ee
656666566566665600566656656665000055500550055500505555050055665665666500666000600060006000600065e6666d6ee666d66ee66d666eee8788ee
666666666666666605665666666566500000000000000000000000000556666666666650656666566656666666665666eee6d6eeee6d66eeeed66eeeee8788ee
6666666666666666055550eeee05555006666660eeeeeeeeeeeee0eeeeeee6666666666665666656665666666666566665eeeeee6666666666666666ee8788ee
656666066566665605650eeeeee05650e056650eeeeeee0eeeee0eeeeee666555555555566600060006000600060006555171777d6d6d6d6d6d6d6d6ee8788ee
666666666666066606660eeeeee06660ee06660eeeeeee0eee0ee0eeee6655dddddddddd660ddd0ddd0ddd0ddd0ddd06e5717888ddddddddddddddddee8788ee
66066566665666660660eeeeeeee0660ee0660eeeeeeee0eeee0eeeee665dd6666666666560ddd0ddd0ddd0ddd0ddd06e51717770000000000000000ee8788ee
66666666666666660660eeeeeeee0660ee0650eeeeeee0e0ee66eeeee65d666666666666660ddd0ddd0ddd0ddd0ddd00e5888888d55005555dd00dd5ee8788ee
66656666666656660650eeeeeeee0560ee0660eeeeeee060ee66eeee665d66666666666650e0d0e0d0e0d0e0d0e0d0e0e57777775dd55d5e555d555ee111111e
65666655556666060660eeeeeeee0660ee0660eeeeeee0e0ee66eeee65d6666ddddddddd50e0d0e0d0e0d0e0d0e0d0e0e5888888e5555d5ee55d555e11111111
66666650056666660660eeeeeeee0660ee0660eeeeeee060e0000eee65d666d5555555550eee0eee0eee0eee0eee0eeee5eeeeeeeee5d5eeeed55eee15555551
66666650056666660660eeeeeeee0660ee0660eeeee77777777777ee65d666d55d666d56666eeeee5d666d56eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
60666655556666560660eeeeeeee0660ee0560ee99ee707070707eee65d666d55d666d5655666eee5d666d55e444eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
66656666666656660560eeeeeeee0650ee0660eeee9e777777777eee65d666d55d666d56dd5566eedd666ddd4444244444444444444444444444444444444eee
66666666666666660660eeeeeeee0660ee0660eeeee9707070707aae65d666d55d666d5666dd566e66666666444429994444444444444444444444444444422e
66666566665660660660eeeeeeee0660ee0660eeee777777777777ee65d666d55d666d566666d56e66666666e444294494444444444444444444444444444222
66606666666666660650eeeeeeee0560ee1660eeee000000000000ee65d666d55d666d566666d56666666666e444294494499949944994944999499949944222
65666656606666560560eeeeeeee0650ee0660eeeee666dee666deee65d666d55d666d56d6666d56dd666ddde44429449449494949494949494944944949422e
66666666666666660660eeeeeeee0660ee1561eeeeee6deeee6deeee65d666d55d666d565d666d565d666d55e44429994449444949494949494444944949422e
66666550055666660660eeeeeeee0660eec661eeeeee6deeee6deeee6666666665d66d5665d666d55d666d56e44429449449994999494949499944944949422e
65665500005566560650eeeeeeee0560ee166ceeeeee6deeee6deeee55555556465d6d5565d6666dd6666d56e44429444949444994494949494444944999422e
6666655005566666e000eeeeeeee000eeec65cee1111111111111111dddddd564465d6dd665d66666666d566e44429444949494949494949494944944949422e
6656665005666566e00eeeeeeeeee00eeeecceee111111111111111166666d5644465d66e65d66666666d56e444429444949994949494949499944944949422e
6666655005566666e00eeeeeeeeee00eeeecceee111111111111111166666d56444465d6e665dd6666dd566e444429449444444444444449444444944444422e
6666555005556666eeeeeeeeeeeeeeeeeeeeeeee111111111111111166666d564442465dee6655dddd5566eee444299944444444444444999444494444444222
6566650000566656eeeeeeeeeeeeeeeeeeeeeeee1111111111111111d6666d5645444465eee6665555666eeeeee2244444444444444444444444444444444222
6666665005666666eeeeeeeeeeeeeeeeeeeeeeee11111111111111115d666d5644444446eeeee666666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee222e
__gff__
0000000300000000010101000000000004000000000000000000010000000000040000000000010101010100000000000404040420010101000000010004000100000000000000000000000003000303000000000000000000000000000003030040010101000000000000000004040408100000010101000404000000800404
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001030101010103010104040400000004000001010300000101040404000404040000010103000001010101000000000003030101030000030001010000000000
__map__
00000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e711e000e2e1e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e2e1e000e2e1e0000000000000000000000000000000000000000000000000000000000000000010200000000000000000000000000
0000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000282936002829360000000000000000000000000000000000000000000000000000000000000000111200000000000000000000000000
00000000000300000000000000000000000000000000000000000b0c0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000373a350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000300000000000000000000000000000000000000001b1c1d00000000000000000000000000000000000000000b0c0d0000000000000000000000000000000000283600000000000000373a3500000000000000000000000000000000000000000000000000000000000000000000000000000000000000004b0000
00000000000300000000000000000000000000000000000000001b1c1d000000000000000000000b0c0d000000000000001b1c1d0000000000000000000000000b0c0d00003735000000000000003738350000000000000000000000000000000000000000000000000000000000000000000000004b0000000000007a7b7c00
00000000000300000000000000000000000000000000000000002b2c2d000000000000000000001b1c1d000000000000002b2c2d0000000000000000000000001b1c1d0000373500000000000000373a3500000000000000000000610000000000000b0c0d0000000000000000000000000000007a7b7c000000005a5b5b5b5c
0000000000030000000000000b0c0d0000000000000000000000003c00000000000000000000002b2c2d00000000000000003c000000000000000000000000002b2c2d00003735000028293600000e2e1e00700000000000000000000000000000001b1c1d00000b0c0d00000000004f0000005a5b5b5b5c00006a6b6b6b6b6b
0000000000030000000000001b1c1d0000000000000000000000003c0000000000000000000000003c0000000000000000003c00000000000000000000000000003c0000000e1e0000373a3500000e2e1e00000000000000002836000000000000002b2c2d00001b1c1d0000004d4ec100006a6b6b6b6b6b6c6a6b6b6b6b6b6b
0000000000030000000000002b2c2d0000000000000000000000003c0000000000003400000000003c0000000000000000003c34000000000000000000000000003c0000340e1e0000373a3500000e2e1e00003400000000000e3500000000000000003c0000002b2c2d0000005d5ec1006a6b6b6b6b6b6b6b6b6b6b6b6b6b6b
000000000003000000000000003c0000000000000000004c2929292929292929292936000000004c293600002829292929292936000000283133360000002829292929292929292978273a26313329292929292936007000000e3500000000000000003c000000003c000000005d5fc66a6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b
000000000003232123222122003c21000000220034004c273a383a393a3a3a3a3a3a3500000028273a35000037383a3a383a3a100000000e2e2e1e00000037393a3a3a3a393a3a3a393a3a3a3a3a383a3a383a3a35000000000e1e00000000000000003c000034003c001f001f5d1f0e6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b
0404040506070808080808090a0a0a0a0a0a0a1a2929273a3a3a3a3a3a3a3a3a3a3a35000000373a3a263133273a3a3a3a3a3a200000000e2e2e1e000000373a3a3a3a3a3a3a3a3a3a3a3a393a3a3a3a3a3a3a3a262931332929292931332929292929292929292929292929292929296b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b
142414151916161719171716181716171717162a3a3a3a3a3a3a393a3a383a3a3a3a35000000373a3a3a3a393a3a3a3a3a3a3a200000000e713e1e000000373a3a393a383a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a393a3a3a3a3a383a3a3a3a393a3a383a3a3a393a3a3a6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b
141414251616161816171916171916171619172a3a393a383a3a3a3a3a3a3a3a3a3a35000000373a383a3a3a3a3a393a3a3a39300000000e2e2e1e000000373a3a3a3a3a3a3a393a3a3a3a3a3a393a3a3a3a393a3a3a3a383a3a3a3a3a3a393a3a393a3a3a3a3a3a3a3a3a3a3a3a383a6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b
131413251719171616161617171717191716172a3a3a3a3a3a3a3a3a3a393a3a3a3926313233273a3a3a3a3a3a3a3a3a3a3a3a263132332929292931323327383a3a3a3a3a3a3a3a3a3a383a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a393a3a3a3a3a3a6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b6b
f00000f1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1d0c6c6c6c6c6c6c6c6c6c6c6c6c6c6c6d1c1c1c1c1c1c1d0c6c6c6c6c6c6c6c6c6c6c6d1c1c1c1c1c1c1d0c6c6c6c6c6c6c6c6c6c6c6c6d1c1c1c1c1c100000000000000000000000000000000
f00000f1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1d0c6c6c6c6c6c6c6c6d1c1c1c1c1c1c1c1c1c1d0c6c6c6c6c6c6c6c6c6c6c50000000e1e0000000000000e2e1e00c4c6c6c6c6c6c6c5000000000e2e1e00000000c4c6c6c6c6c6c6c5000e2e1e0000d2000000d400c4c6d1c1c1c100000000000000000000000300000000
f00000f1c1c1d0c6c6d1c1c1c1d0c6c6c6c6c6c6c6c50e1e000000000000c4c6c6c6c6c6c6c6c6c6c500d400000e2e2e2e2e1e000000000e1e0000000000000e2e1e000000000000000000000000000e2e1e000000000000000000000000000e2e1e0000e2000000e4000000c4c6c6d100000000000000000000000300000000
f00000f1c1c1c80000c4d9dadbc52e2e1e00d40000000e1e0000000000000e2e1e0000d40000d400d200e400000e2e2e2e2e1e00007000c2c30000000000000e2e1e000000000000000000000000000e2e1e000000000000000000000000000e2e1e0000f2000000e40000000e2e2ec703000000030000000000000300000000
f00000c4c6c6c50000000000000e2e2e1e00f40000000e1e0000000000000e2e1e0000e40000f400e200f400000e2e2e2e2e1e0000610051510000000000000e2e1e000000006100000000000000000e2e1e000000545454545454545400000e2e1e000000000000e40000000e712ec703000000030000000000000300000000
f000000e2e1ed30000006100000e2e2e1e00000000000e1e0061000000000e2e1e0000f400000000e2000000000e2e2e2e2e1e0000000079000000610000000e2e1e000000000000000000000000000e2e1e000053d9dadadadadadadb52000e2e1e000000000000e40000000e2e2ec703000000030000000000000300000000
f000000e2e1ee300001f0000000e2e2e1e0000001f340e1e0000000000000e2e1e00000000000000e2000000000e2e2e2e2e1e0000700079000000610000000e2e1e000000007000610000000000000e2e1e000000000000000000000000000e2e1e000000000000f40000c2c0c0c0e103000000030000dc0000000300000000
f000000e2e1ef30000c2c9cacbc0c0c0c3000000c2c0c0c30000000000000e2e1e00000000000000e2000000000e2e2e2e2e1e00006100790000006100001f0e2e1e1f00000000000000000000001f0e2e1e1f6100706100706100706100000e2e1e00000000610000700051515151c7c300000000d7d8d8d8d8e90300000000
f000000e2e1e000000d25151510e2e1e51000000515151510000000000000e2e1e00000000700000f2000000000e3e2e2e2e1e00000000790000006100c2c0c0c0c0c0c300007000610000000000c2c0c0c0c0c300000000000000000000000e2e1e00007000000000000000004d4ee1f000000000e72e2e2e2ee80300000000
f000000e3e1e000000e20000000e2e1e70000000000000000000000000000e2e1e001f000000000000000000000e2e2e2e2e1e00007000790000006100510e2e515151510000000000000070000051515151515153c9cacacacacacacb52000e2e1e00000000000000000000005d5ec1f0000000000e2e2e2e2ee80300000000
f000000e2e1e000000f20000000e711e0000000000000000000000000000c2c0c0c0c300000000610000700000c2c0c0c0c0c300000000000000000000000e7100610000700000000000000000000000000000000051515151515151510000c2c0c300000000000000000000005d5fc6c5000000000e2f2e2e2ee80300d5d600
f000000e2e1e000000000000000e2e1e000000000000000000000000000051515151510000000000000000000051515151515100000000000000006100000e2e0000000000000000000000000000000000000000000000000000000000000000c1c800001f00000000001f00005d1f0e1e001f34000e2e2e2e2ee80300e5e600
e0c0c0c0c0c0c9cacacacacbc0c0c0c0c0c9cacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacacbc0c0c0c9cacacacacacacacacacacacacacacacacacacacacacacacacacacacacacac1e0c0c0c0c0c0c0c0c0c0c0c0c0c0c0292929293ff72e2e2f2ee80404f5f604
c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c13a383a3a3af8f72e2e2ee81414141424
c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c13a3a3a3a3a3af8f72e2ee81414141414
c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c13a3a3a3a393a3af8f72ee81414131413
__sfx__
01100000171600010011161121600c7001070010160001000f160001000f161101600010000100121600010017160001001116112160000000010010160001000f16000100001001010000100001001210000100
0110000018073001030c00300103001030000318073000032463500003001030c0030010300103180030010318073001030c00300103001030000318073000032463500103001030c00300103001031800312103
0110000015160001001116112160001000010010160001000f160001000c1610d16000100001000b160001000d160001000e1610f1600010000100101600010012160001000f1611016000100001001216000100
0110000018073001030c00300103180730000318073000032462500003001030c0030010300103180730010318073001030c00300103180730000318073000032462500103001030c00318073001031807312103
011000000b772007020c7020070200702007020b772007020b77200702007020c702007020070218702007020b772007020c7020070200702007020b772007020b77200702007020c70200702007020b77212702
0110000017160001001116112160001000010010160001000f160001000f161101600010000100141600010017160001001316114160001000010010160001000f16000100001001010000100001001210000100
0110000004772007020c70200702007020070204772007020477200702007020c7020070200702187020070204772007020c70200702007020070204772007020477200702007020c70200702007020477212702
0110000015160001001116112160001000010010160001000f160001000c1610d16000100001000b10000100091600b1600d1600f1601016012160141601516017160191601b1601c1601e160201602116023160
011000000977200702007020070200702007020977200702097720070200702007020070200702007020070209772007020070200702007020070209772007020977200702007020070200702007020977206702
01100000231500c1001d1511e15018100181001c150181001b1500c1001b1511c15018100181001e15018100231500c1001d1511e15018100181001c150181001b15018100181001c10018100181001e10018100
011000000b140000000f14000000121400000017140000001b140000001e14000000231400000027140000002a14000000271400000023140000001e140000001b14000000171400000012140000000f14000000
0110000021150001001d1511e15000100001001c150001001b1500010018151191500010000100171500010019150001001a1511b15000100001001c150001001e150001001b1511c15000100001001e15000100
011000001014000000141400000017140000001c140000002014000000231400000028140000002c140000002f140000002c140000002814000000231400000020140000001c1400000017140000001414000000
01100000231500c1001d1511e15018100181001c150181001b1500c1001b1511c15018100181002015018100231500c1001d1512015018100181001c150181001b15018100181001c10018100181001e10018100
0110000009150000000d150000001015000000151500000019150000001c15000000211500000025150000002815000000251500000021150000001c150000001915000000151500000010150000000d15000000
000100003462034620346203462034620006000060000600216202162021620216202162000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100001332013320133201432016320183301b3301e33020330243402c340003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100001502015020150201602016020170201702017020190201a0201c0201e02022020280202a0203002037020000000000000000000000000000000000000000000000000000000000000000000000000000
000100002743027440274402744027440274402744000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000200003676036760367603676036750367403673036720367200070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00080000196201a6201d630236302563023630206202361023610226201e6201e6201c6201962014610186101c6201e6201c6301f6302263023620256202562020610216101d6201b620186201a6201862012610
01120000110600000018060000001a0600000018060180001800010061110600000018060000001a06000000110600000018060000001a060000001806018000000001106113060000001a060000001d06000000
0112000016060000001a060000001f060000001d060180000000014061160600c0001a060000001d0600000016060000001a060000001f060000001d0601800000000180611a060000001f060000002206000000
011200002406424062240522405224042240422403224032240222402524002240000000000000000000000000000000000000000000000000000000000000002406424055260622605529062290552b0622b055
0112000029054290522904229042290322903229022290222901229015000000000000000000000000000000000000000000000000000000000000000000000029054290452b0522b0452e0522e0453005230045
01120000110600000018060000001a0600000018060180001800010061110600000018060000001a06000000110600000018060000001a0600000018060180000000010061110600000018060000001d06000000
011200000a0740e0741107413074160741a0741d0741f0742207426074290742b0742e0743207435074370743507432074300742b0742907426074240741f0741d0741a0741807413074110740e0740c07407074
011200000a0700a0700a0600a0600a0500a0500a0400a04016000160001600016000160000000000000180000a0700a0700a0600a0600a0500a0500a0400a0400000000000000000000000000000000000000000
0112000005070050700506005060050500505005040050400a0000a0000a0000a0000a00000000000000000005070050700506005060050500505005040050400000000000000000000000000000000000000000
011200000c073001030c003001030c000000030c073000032463500003001030c00300103001030c073001030c073001030c003001030c073000030c073000032463500103001030c0030c000001030c07312103
011200000707007070070600706007050070500704007040070000700007000070000700007000070000700007070070700706007060070500705007040070400000000000000000000000000000000000000000
011900000e250132000e250112000c2550c25010200092501520009250012001b200072550725508255082550e250132000e2500b2510c2500c2541020009250002000925000200002000725507255092550a255
01190000180730c0000c0000c000246001807318000180732464500003001030c0031800000103180730010318073001030c0030c000246001807318000180732464500103001030c00318000001031807312103
0003000008310083100831008310093100b3200d3301033014340193401f340253402f35038350003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
01190000022501320002250112000025500250102000925015200092001b2001b2001b2001b2001b2001b20002250132000225011200002550025010200022501b2001b2001b2001b2001b2001b2001b2001b200
011900001a240132001a24011200182451824010200152401520015240002001b200132451324514245142451a240132001a24017241182401824410200152400020015240002000020013245132451524516245
011900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 00 01 43 44
00 05 01 43 44
00 02 01 43 44
00 00 03 04 04
00 05 03 06 06
00 07 03 08 08
00 09 03 0a 04
00 0d 03 0c 06
00 0b 03 0e 08
00 00 03 0a 04
02 07 03 0e 08
00 19 42 43 44
01 15 42 43 44
00 16 42 43 44
00 19 17 43 44
00 16 18 43 44
00 19 17 43 44
00 16 18 43 44
00 41 1a 15 44
00 1c 15 17 1d
00 1b 15 18 1d
02 1e 17 16 1d
01 1f 20 22 44
02 23 20 22 1f
01 1f 20 22 24
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
