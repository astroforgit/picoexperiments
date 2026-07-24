pico-8 cartridge // http://www.pico-8.com
version 1
__lua__
-------------------------
--- rabu rabu monster ---
-------------------------
--by the pedroest--------
--pedro of'em all--------
------------------------- 
------gosh, i hope this--
------will turn out fun--
-------------------------

-- global stuff --
------------------
game=false
title=true

difficulty="easy"
canisetdifficulty=true

start=false
camerax=0
--cameray=0
gravity=0.4
--speed=1
--loops=1
maxspeed=5

time=0
gametime=0
maxmins=2

killcount=0

-- player stuff --
------------------
phealth=82
px = 0
py = 88
pspeedx = 0
pspeedy = 0

pframe = 1
pfacing = 1
pstate = "normal"
panimspeed = 24

pjumppower=5

pholdtime=0

function healthcheck()
	if(phealth<0)phealth=0 gameover=true
	if(py>130)gameover=true
	if(phealth>82)phealth=82
end

function gameoveryet()
	if night
	then
		colours={0,1,1,1,13,1,6,7,2,10,10,3,1,2,14,6}
		for x=1,16 do if x~=8 then pal(x-1,colours[x]) end end
	end

	if twilight
	then
		colours={0,1,2,2,4,8,6,7,8,10,10,9,8,2,14,15}
		for x=1,16 do if x~=8 then pal(x-1,colours[x]) end end
	end
	
	if gameover
	then
		colours={0,2,2,2,2,8,14,7,8,8,14,14,8,2,14,14}
		for x=1,16 do if x~=8 then pal(x-1,colours[x]) end end
	end
end

function pmove()
	if pspeedx>0
	then
		if not pcolr then px+=pspeedx end
	end
	if pspeedx<0
	then
		if not pcoll then px+=pspeedx end
	end

	--correct x coordinate--
	dontcorrectme=false
	iwannabeherey=round(px/8)*8
	if(solid(pmapx2+2,pmapy))px=iwannabeherey pstate="jumping" dontcorrectme=true
	if(solid(pmapx4,pmapy))px=iwannabeherey pstate="jumping" dontcorrectme=true

		
	if pspeedy<0	
	then
	 if not solid(pmapx4,pmapy-2) and not solid(pmapx2+2,pmapy-2) then py+=pspeedy else if not dontcorrectme then pspeedy=max(pspeedy,0) end end
	end
	if pspeedy>0
	then
		if not pcold then py+=pspeedy end
	end
	
	if pcold and pstate=="jumping" and pspeedy>=0
	then
		pclock=0
		pframe=1
		panimcount=0
		panimation="standing"
		pstate="normal"
		pspeedy=0
	end

	
	pspeedy+=gravity
	if (pspeedy>maxspeed)pspeedy=maxspeed
	if pcold and pspeedy>=0 and not dontcorrectme then pspeedy=0 end
	if pspeedy~=0 then pstate="jumping" end

	--correct y coordinate--
	iwannabeherey=flr(py/8)*8
	if(not dontcorrectme and pcold and pspeedy==0 and py>iwannabeherey)py=iwannabeherey

 ----iwannabeherey=flr(py/8+1)*8
	--if(not pcold and pcoldd and pspeedy>3)py=iwannabeherey

	--if(solid(pmapx4,pmapxy))px=iwannabeherey+8

	--if(pinn)px=iwannabeherey
	--if solid(pmapx,pmapy)
	--then
		--if px%8<5 then px=pmapx*8+7
		--else px=0 end
	--end

	--player facing--
	if pspeedx>0 then pfacing=1 end
	if pspeedx<0 then pfacing=0 end


	--a good boy eats slowly--
	if pstate=="omnomnom"
	then
		peattimer+=1
		if(peattimer>20)pstate="normal" create_skull(px,py) phealth+=human_deliciousness speechbubble=1 sfx(35,3)
	end
	
	if(not done and px>1000)px=1000
	if(px<0)px=0
	if(title and px<9)px=9
	if(title and px>142)px=0 py=88 title=false startinggame=true for ball in all(fireballs)do del(fireballs,ball) end
	if(title and py>64)px=98 py=-8
	
end

function panimate()
	pclock+=1
	if(pclock>30)pclock=0

	if pstate~="capture"
	then
		if(pclock>=30-panimspeed)
		then
			pclock=0
			pframe+=1
			if pframe>4 then pframe=1 panimcount+=1 if panimcount>4 then panimcount=0 end end
		end
	
		if(pfiring)pfiring+=1
		if(pfiring and pfiring>3)pfiring=nil
	end
	
	if pstate=="capture"
	then
		if(pclock>15) pholding=true pstate="normal"
	end
end

function playerdraw()
	rectfill(px,py,px+15,py+31,10)
	rectfill(px,py,px+7,py+31,14)
end

function pdraw()
	--flash when firing--
	if(pfiring)pal(2,10)pal(8,9)
	
	gameoveryet()
	
	--offset if facing left--
	if(pfacing==0)px+=8
	--bobbing movement--
	if panimation=="walking"
	then
		bobx=(pframe+1)%2
		boby=-(pframe%2)

		px+=bobx
		py+=boby
	end

	--facing multiplier--
	local f=pfacing*2-1
	if f==1 then fp=false
	else fp=true end

	if panimation=="standing" and pstate~="jumping"
	then
		--lower body--
		spr(32,px-4+4*f,py+16,3,2,fp)
	end
	
	if panimation=="walking" and pstate=="normal"
	then
		if(pframe==1)legsprite=4
		if(pframe==2 or pframe==4)legsprite=32
		if(pframe==3)legsprite=36	
	
		--lower body--
		spr(legsprite,px-4+4*f,py+16,3,2,fp)
	end
	
	--left hand sprite--
	lhspr=3
	if(pholding)lhspr=2

	if pstate=="normal" or pstate=="capture"
	then
		--torso--
		if(pframe==1 or pframe==4)spr(0,px,py,2,2,fp)
		if(pframe==2 or pframe==3)spr(0,px,py+1,2,2,fp)
		--stiff upper lip--
		if(pframe==1 or pframe==4)pset(px+16+((f-1)/2*17),py+10,3)
		if(pframe==2 or pframe==3)pset(px+16+((f-1)/2*17),py+11,3)
		--amazing left hand--
		if pstate~="capture"
		then
			if(pframe==1 or pframe==2)spr(lhspr,px+4+12*f,py+12,1,1,fp)
			if(pframe==3 or pframe==4)spr(lhspr,px+4+12*f,py+13,1,1,fp)
			--to die for right hand--
			if(pframe==1 or pframe==2)spr(3,px+6+((f-1)/2*4),py+14,1,1,fp)
			if(pframe==3 or pframe==4)spr(3,px+6+((f-1)/2*4),py+15,1,1,fp)
		end
		--sexy lower lip--
		if(pframe==1 or pframe==4)pset(px+16+((f-1)/2*17),py+15,11)
		if(pframe==2 or pframe==3)pset(px+16+((f-1)/2*17),py+16,11)line(px+12+((f-1)/2*10),py+17,px+13+((f-1)/2*10),py+17,3)
		--drool--
		droolx=px+9+((f-1)/2*3)
		drooloffsety=min(1,(pframe-1)%3)
		--if((((panimcount-1)/5)%1==0) or (((panimcount+1)/5)%1==0))
		--then
				--pset(droolx,py+15+drooloffsety,12)
		--end
		--if((panimcount/5)%1==0)
		--then
			if(panimcount~=2 and panimcount~=3)line(droolx,py+15+drooloffsety,droolx,py+15+0^panimcount+drooloffsety,12)
		--end			

		--captured human sweat--
		if pholding
		then
			pholdtime+=1
			if(pholdtime>100)pholdtime=0
			
			if ((pholdtime>10 and pholdtime<20) or (pholdtime>30 and pholdtime<40))
			then
				if pfacing==1
				then
					pset(px+18,py+14,7)
					pset(px+20,py+15,7)
				else
					pset(px-4,py+14,7)
					pset(px-6,py+15,7)					
				end
			end
		end
				
	end

	if pstate=="jumping"
	then			
		--unbelievable legs--
		spr(7,px,py+16,2,2,fp)
		--torso--
		spr(0,px,py,2,2,fp)
		--stiff upper lip--
		pset(px+16+((f-1)/2*17),py+10,3)
		--amazing left hand--
		spr(lhspr,px+4+12*f,py+12,1,1,fp)
		--to die for right hand--
		spr(3,px+4+2*f,py+14,1,1,fp)
		--sexy lower lip--
		pset(px+16+((f-1)/2*17),py+15,11)
	end		
	
	
	if pstate=="omnomnom"
	then

		if peattimer<10
		then
			spr(0,px,py,2,2,fp)
			spr(41,px+8*f,py+8,2,1,fp)

			--stiff upper lip--
			pset(px+16+((f-1)/2*17),py+10,3)
		else
			spr(80,px,py,2,2,fp)
		end
		
		--amazing left hand--
		spr(lhspr,px+4+12*f,py+12,1,1,fp)
		--to die for right hand--
		spr(3,px+4+2*f,py+14,1,1,fp)
		--sexy lower lip--
		pset(px+16+((f-1)/2*17),py+15,11)

	end
	
	--bobbing movement correction--
	if panimation=="walking"
	then
		px-=bobx
		py-=boby
	end
	
	--offset correction--
	if(pfacing==0)px-=8
	pal()
end

function round(x)
	if x-flr(x)>=0.5 then return flr(x)+1
	else	return flr(x) end
end

function pupdatecollision()
	pmapx=flr(px/8)
	pmapx2=flr((px-1)/8)
	pmapx3=flr((px+7)/8)
	pmapx4=flr((px+8)/8)
	pmapy=flr(py/8)+3
	pmapy2=flr((py-1)/8)+3

	if(floor(pmapx4,pmapy) or floor(pmapx+1,pmapy) or floor(pmapx2+2,pmapy) or solid(pmapx4,pmapy+1) or solid(pmapx+1,pmapy+1) or solid(pmapx2+2,pmapy+1))pcold=true else pcold=false
	if(solid(pmapx+2,pmapy) or solid(pmapx+2,pmapy2+1))pcolr=true else pcolr=false
	if(solid(pmapx3,pmapy) or solid(pmapx3,pmapy2+1))pcoll=true else pcoll=false


end


--function pdrawcollisionbox()
	--rectfill(pcolx,pcoly-8,pcolx+7,pcoly-1,10)
	--rectfill(pmapx*8,(pmapy-16)*8,pmapx*8+7,(pmapy-16)*8+7,13)
--end


--	map stuff --
---------------
function solid(x,y)
	return fget(mget(x,y),0)
end

function floor(x,y)
	return fget(mget(x,y),3)
end

function flag(x,y,f)
	return fget(mget(x,y),f)
end

-- fireball stuff --
--------------------
fireballs = {}
max_fireballs = 3

--molten = {}
--molten[148]=true
--molten[167]=true
--molten[168]=true
--molten[175]=true

--molten[138]=true
--molten[139]=true
--molten[140]=true
--molten[141]=true

----molten[154]=true
----molten[155]=true
----molten[156]=true
----molten[157]=true

--molten[128]=148
--molten[129]=167
--molten[130]=168
--molten[131]=175

--molten[144]=148
--molten[145]=167
--molten[146]=168
--molten[147]=175

--molten[160]=138
--molten[65]=139
--molten[66]=140
--molten[161]=167
--molten[162]=168
--molten[163]=141
--molten[164]=175

function create_fireball(x,y,speedx,speedy)
	fireball={}
	fireball.x=x
	fireball.y=y
	fireball.speedx=speedx
	fireball.speedy=speedy
	--fireball.mapx=0
	--fireball.mapy=0
	fireball.trail={}
	fireball.timeout=0
	
	if(count(fireballs)<max_fireballs)add(fireballs,fireball)
end

flames={}
function create_flame(x,y)
	local flame={}
	flame.x=flr(x)
	flame.y=flr(y)
	flame.timer=0
	flame.trail={}
	
	local stop=false
	for fire in all(flames) do
		if (fire.x==flame.x and fire.y==flame.y)stop=true
	end
	
	if(not stop)add(flames,flame) 
end

function burn_flames()
	for flame in all(flames) do
		
		if flame.timer>9
		then
			tile=155
			fx=flame.x
			fy=flame.y

			if(flag(fx-1,fy,6) or flag(fx+1,fy,6))tile=155
			if(not flag(fx-1,fy,5) and not flag(fx-1,fy,6))tile=154
			if(not flag(fx+2,fy,5) and not flag(fx+2,fy,6))tile=156
			if(not flag(fx+1,fy,5) and not flag(fx+1,fy,6))tile=157
			
			if(flag(fx,fy+1,4))tile-=16
			if(flag(fx,fy,1))tile=255
			if(flag(fx,fy,2))tile=233
			mset(flame.x,flame.y,tile) killcount+=1
		end
		
	end
	
	for flame in all(flames) do
		if flame.timer>9 then
			if(flag(flame.x,flame.y+1,6))mset(flame.x,flame.y,255)
			if(flag(flame.x,flame.y-1,6)) mset(flame.x,flame.y-1,255)
			del(flames,flame)
		end
		flame.timer+=1
	end	
end

function draw_flame(flame)	
	if(night or twilight)pal()
	if(flame.timer==1 or flame.timer==2 or flame.timer==7 or flame.timer==8)pal(7,8)pal(8,9)pal(9,10)pal(10,7)
	if(flame.timer==3 or flame.timer==4 or flame.timer==9 or flame.timer==10)pal(7,9)pal(8,10)pal(9,7)pal(10,8)
	if(flame.timer==5 or flame.timer==6 or flame.timer==11 or flame.timer==12)pal(7,10)pal(8,7)pal(9,8)pal(10,9)
	
	if(gameover)gameoveryet()
	spr(39,flr(flame.x)*8,(flr(flame.y))*8)
	pal()
end

function burn(mapx,mapy)
	local offset=0
	negoffset=0
	while flag(mapx+offset,mapy,5) or flag(mapx+negoffset,mapy,5)
	do
		raiseoff=false
		raisenego=false
		if flag(mapx+offset,mapy,5)
		then
			create_flame(mapx+offset,mapy)
			raiseoff=true
			sfx(30,3)
			--mset(mapx+offset,mapy,molten[mget(mapx+offset,mapy)])
		end
		if flag(mapx+negoffset,mapy,5)
		then
			create_flame(mapx+negoffset,mapy)
			raisenego=true
			--mset(mapx+offset,mapy,molten[mget(mapx+offset,mapy)])
		end
		
		local offsety=1
		while flag(mapx+offset,mapy-offsety,5)
		do
			create_flame(mapx+offset,mapy-offsety)
			--mset(mapx+offset,mapy-offsety,192)
			
			offsety+=1
		end

		offsety=1
		while flag(mapx+negoffset,mapy-offsety,5)
		do
			create_flame(mapx+negoffset,mapy-offsety)
			--mset(mapx+offset,mapy-offsety,192)
			
			offsety+=1
		end

	if(raiseoff)offset+=1
	if(raisenego)negoffset-=1
	
	end
	
end

function move_fireballs()
	for fireball in all(fireballs)
	do
		if fireball.timeout==0
		then
			--move--
			fireball.x+=fireball.speedx
			fireball.y+=fireball.speedy
		
			fireball.speedy+=gravity/2
			if(fireball.speedy>maxspeed)fireball.speedy=maxspeed

			--leave trail--
			spark={}
			spark.x=fireball.x+flr(rnd(7))
			spark.y=fireball.y+flr(rnd(7))
			spark.timer=1
			spark.loops=0
			add(fireball.trail,spark)

			--collide--
			--if(fireball.x>298+camerax or fireball.x<-178)fireball.timeout=1
			if(fireball.x<-18 or fireball.y>130)fireball.timeout=1

			if((fireball.x/8)-(flr(fireball.x/8)))>0.5
			then
				fireball.mapx=flr(fireball.x/8)+1
			else
				fireball.mapx=flr(fireball.x/8)
			end
			fireball.mapy=fireball.y/8
			--if(fireball.mapy<6)fireball.mapy=256

			imherelol=mget(fireball.mapx,fireball.mapy)

			if game and (fget(imherelol,3) or solid(fireball.mapx,fireball.mapy))	then burn(fireball.mapx,fireball.mapy) fireball.timeout=1 end

		else
			 fireball.timeout+=1
			 if(fireball.timeout>10)del(fireballs,fireball)
		end
	
	end
end

function draw_fireballs()
	if(night or twilight)pal()
	for fireball in all(fireballs)
	do		
		if(fireball.timeout==0)spr(39,fireball.x,fireball.y)	

		--rectfill(fireball.mapx*8,(fireball.mapy-16)*8,fireball.mapx*8+7,(fireball.mapy-16)*8+7,12)
		for spark in all(fireball.trail) do
			local x=spark.loops
			increment=spark.loops
			while x<5 do
				firecolor=7-spark.loops
				if(firecolor<4)firecolor=8
				if(firecolor<7)firecolor+=4
				pset(spark.x+rnd(7)-3,spark.y+rnd(7)-3,firecolor)
				increment+=1
				x+=increment
			end
			
			spark.timer+=1

			if(spark.timer>3)spark.timer=0 spark.loops+=1
			if(spark.loops>5)del(fireball.trail,spark)
		end
		
	end
end


-- enemy stuff --
-----------------
max_humans=10
max_helicopters=2
max_tinies=30

damage_human=0.5
damage_helicopter=1
human_deliciousness=20


-- human stuff --
-----------------
humans={}

function create_human(x,y)
	human={}
	human.x=x
	human.y=y
	human.speedx=speedx
	human.speedy=speedy
	--human.mapx=0
	--human.mapy=0
	--human.close=false
	human.timer=-1
	--human.caught=false
	
	if count(humans)<max_humans
	then add(humans,human) end	
end

function move_humans()
	for human in all(humans) do
		if(px-human.x+camerax/2>150)del(humans,human)
		
		if human.close
		then
			human.timer+=1
			if(human.timer>60)human.timer=-1
			
			--cause damage--
			if(start and human.timer%5==0 and human.timer<26)phealth-=damage_human sfx(32,3)
		end
	end
end

function ai_human(human)
	local offset=camerax/2
	
	if not human.caught
	then
		if abs(human.x-offset-px-8)<40 and abs(human.y-py)<70 then human.close=true else human.close=false end
	else
		human.close=false
		
		if(pstate=="capture" and pclock>14)del(humans,human)
	end
end

function draw_humans()
	gameoveryet()
	local offset=camerax/2
		
	for human in all(humans) do
		if px+8-human.x+offset<0
		then
			if not human.caught
			then
				if not human.close then spr(9,human.x-offset,human.y) else if human.timer%5==0 and human.timer<26 then spr(26,human.x-offset,human.y) else spr(10,human.x-offset,human.y) end end
			else
				spr(25,human.x-offset,human.y)
			end
		else
			if not human.caught
			then
				if not human.close then spr(9,human.x-offset,human.y,1,1,true) else if human.timer%5==0 and human.timer<26 then spr(26,human.x-offset,human.y,1,1,true) else spr(10,human.x-offset,human.y,1,1,true) end end
			else
				spr(25,human.x-offset,human.y)
			end
		end

	end
		
end


-- tiny stuff --
----------------
tinies={}

function create_tiny(x,y)
	tiny={}
	tiny.x=x
	tiny.y=y
	--tiny.mapx=0
	--tiny.mapy=0
	--tiny.dead=false
	tiny.deadtimer=0
	
	if(count(tinies)<max_tinies)add(tinies,tiny)
end

function draw_tinies()
	for tiny in all(tinies) do
		if not tiny.dead then pset(tiny.x,tiny.y,1)
		else pset(tiny.x,tiny.y,8) end
	end
end

function animate_tinies()
	for tiny in all(tinies) do
		if(abs(tiny.x-px)>200)del(tinies,tiny)
	
		if not tiny.dead
		then
			tiny.mapx=flr(tiny.x/8)
			tiny.mapy=flr(tiny.y/8)
		
			if(flr(rnd(5))==0)tiny.x+=rnd(2)-1
			if(tiny.x<tiny.mapx*8)tiny.x=tiny.mapx*8
			if(tiny.x>tiny.mapx*8+7)tiny.x=tiny.mapx*8+7

			if(flr(rnd(5))==0)tiny.y+=rnd(2)-1
			if(tiny.y<(tiny.mapy)*8+1)tiny.y=(tiny.mapy)*8+1
			if(tiny.y>(tiny.mapy)*8+7)tiny.y=(tiny.mapy)*8+7

			--let's collide!--
			if(abs(tiny.x-px-12)<3 and py==(tiny.mapy-3)*8)tiny.dead=true create_skull(tiny.x,tiny.y-8) sfx(38,3)

			for flame in all(flames) do
				if(flame.x==tiny.mapx and flame.y==tiny.mapy)tiny.dead=true create_skull(tiny.x,tiny.y-8)
			end
					
		else
			tiny.deadtimer+=1
			if(tiny.deadtimer>10)del(tinies,tiny)
		end
		
	end
	
end


-- helicopter stuff --
----------------------
helicopters={}

function create_helicopter(x,y)
	helicopter={}
	helicopter.x=x
	helicopter.y=y
	--helicopter.mapx=0
	--helicopter.mapy=0
	helicopter.timer=0
	--helicopter.facing=false
	--helicopter.close=false
	--helicopter.direction=false
	--helicopter.cooldown=false
	--helicopter.dethklok=nil
	
	if(count(helicopters)<max_helicopters) add(helicopters,helicopter)
end

function ai_helicopters()
	for helicopter in all(helicopters) do
		if(px-helicopter.x>130)del(helicopters,helicopter)
		
		if not helicopter.dethklok
		then
			helicopter.timer+=1
			if helicopter.timer>16
			then
		
				helicopter.timer=1
				if helicopter.cooldown==false
				then
					helicopter.cooldown=true
				else
					helicopter.cooldown=false
				end
		
			end
			
			--cause some damage yo--
			if(start and helicopter.close and helicopter.timer%2==1 and not helicopter.cooldown)phealth-=damage_helicopter sfx(32,3)

			--where the player at?--		
			if helicopter.x-px-8<0 then helicopter.facing=true
			else helicopter.facing=false end
		
			--oh he close?--
			if abs(helicopter.x-px-8)<40 and py-helicopter.y>-40 then helicopter.close=true
			else helicopter.close=false end
		
		
			--never mind i'll just move around--
			helicopter.mapx=flr(helicopter.x/8)
			helicopter.mapy=flr(helicopter.y/8)
			local mapx=helicopter.mapx+1
			local mapy=helicopter.mapy
			stufftotheleft=false
			stufftotheright=false
		
			--where i headed to?--
			if solid(mapx-1,mapy) or floor(mapx-1,mapy) or solid(mapx-2,mapy) or floor(mapx-2,mapy) or helicopter.x<5
			then
				helicopter.direction=true stufftotheleft=true
			end
		
			if solid(mapx,mapy) or floor(mapx,mapy) or solid(mapx+1,mapy) or floor(mapx+1,mapy)
			then
				helicopter.direction=false stufftotheright=true
			end

			--off i go!--
			if not helicopter.close
			then
		
				if helicopter.direction
				then 
					if not stufftotheright then helicopter.x+=1 end
				else
					helicopter.x-=1
				end
		
			else
			
				if helicopter.facing
				then
	
					if not stufftotheright
					then
						if(px-helicopter.x<18 and not stufftotheleft)helicopter.x-=1
						if(px-helicopter.x>18 and not stufftotheright)helicopter.x+=1
					end
	
				else

					if not stufftotheleft
					then	
						if(helicopter.x-px<32 and not stufftotheright)helicopter.x+=1
						if(helicopter.x-px>32 and not stufftotheleft)helicopter.x-=1
					end

				end

			end
		
		
			--me no like fire--
			for fireball in all(fireballs) do
				if (abs(fireball.x-helicopter.x)<10 and abs(fireball.y-helicopter.y)<7)helicopter.dethklok=1 sfx(36,3)
			end
		
	
		else
			--me dead :(--
			helicopter.dethklok+=1
			if(helicopter.dethklok>9)create_skull(helicopter.x,helicopter.y) del(helicopters,helicopter)
		
		end

	end
end

function draw_helicopters()
	for helicopter in all(helicopters) do
	
		if helicopter.cooldown or not helicopter.close then sprite=11
		else sprite=27 end
		
		if not helicopter.dethklok
		then
		
			if not helicopter.close
			then
				local t=flr(helicopter.timer/2)
				local offsety=-t+5+2*(t-5)*flr(t/6)
				spr(sprite+(helicopter.timer%4),helicopter.x,helicopter.y+offsety,1,1,helicopter.direction)
			else
			spr(sprite+(helicopter.timer%4),helicopter.x,helicopter.y,1,1,helicopter.facing)
			end
		
		else
			sprite=55
			if(helicopter.close)spr(sprite+helicopter.dethklok-1,helicopter.x,helicopter.y,1,1,helicopter.facing)
			if(not helicopter.close)spr(sprite+helicopter.dethklok-1,helicopter.x,helicopter.y,1,1,helicopter.direction)
		end

	end
	
end

-- inputsies --
---------------
function input()
	--change speed :p--
	--if (btn(2,1)) speed+=0.1
	--if (btn(3,1)) speed-=0.1
	--if btn(4,1)
	--then
		--if peek(0x4301)==7
		--then
			--load("english")
		--else
			--load("nihongo")
		--end
		--run()
	--end
	
	if btn(0,0) and pstate~="capture" and pstate~="omnomnom" then if pspeedx>-1 then pspeedx=-1 end if panimation~="walking" then pclock=0 pframe=1 panimcount=0 end panimation="walking"
	elseif btn(1,0) and pstate~="capture" and pstate~="omnomnom" then if pspeedx<1 then pspeedx=1 end if panimation~="walking" then pclock=0 pframe=1 panimcount=0 end panimation="walking"
	else if panimation~="standing" then pclock=0 pframe=1 panimcount=0 end panimation="standing" if pstate=="normal" then pspeedx=0 end end
	
	if pstate~="jumping" and pstate~="capture" and not btn(2,0)
	then
		if(pspeedx>1)pspeedx=1
		if(pspeedx<-1)pspeedx=-1
	end
		
	if btn(2,0) and pstate=="normal" then pclock=0 pframe=1 panimcount=0 pstate="jumping" pspeedy=-pjumppower pspeedx+=pspeedx sfx(37,3) end
	if not btn(2,0) and pstate=="jumping" and pspeedy<0 then pspeedy+=gravity*2 end
	if (pspeedy>maxspeed)pspeedy=maxspeed

	if pspeedx>3 then pspeedx=3 end
	if pspeedx<-3 then pspeedx=-3 end

	--fire fire!--
	if btnp(4,0)
	then
		if pfacing==1 then create_fireball(px+8,py+10,3+pspeedx,-1+pspeedy/2)
		else create_fireball(px+8,py+10,-3+pspeedx,-1+pspeedy/2) end
		sfx(31,3)
		
		pfiring=0
	end

	--c'mere, human!--
	local offset=camerax/2
	
	if btnp(3,0) and py==88 and not pholding and pstate=="normal" and pspeedx==0
	then
		for human in all(humans) do
			if abs(px+8-human.x+offset)<10 and not human.caught then if pstate~="capture" then human.caught=true end pstate="capture" sfx(33,3) end
		end
	end

	if btn(3,0) and pstate=="normal" and pholding
	then
		if pfacing==1
		then
			if(floor(pmapx+2,pmapy) and floor(pmapx+3,pmapy) and not flag(pmapx+2,pmapy,6)) create_tiny(px+24,py+24) pholding=false
		else
			if(floor(pmapx-2,pmapy) and floor(pmapx-3,pmapy) and not flag(pmapx-2,pmapy,6)) create_tiny(px-8,py+24)	pholding=false
		end
	end
	
	
	--human yummy<3--
	if btn(5,0) and pstate=="normal" and pspeedx==0 and pholding
	then
		pstate="omnomnom"
		peattimer=0
		pholding=false
	end
	
end


-- graphical stuff --
---------------------
--function speechbubble(x,y)
	--circfill(x,y,5,7)
	--pset(x-3,y+5,7)
	--pset(x-2,y+6,7)
	--pset(x-3,y+6,7)
	--pset(x-4,y+6,7)
	--spr(64,x-4,y-3)
--end

speechbubble=0
function animate_speechbubble()
	if speechbubble>0
	then
		speechbubble+=1
		if(speechbubble>36)speechbubble=0
	end
end

function draw_speechbubble(x,y)
	if(night or twilight)pal()
	if speechbubble>0
	then
		if(speechbubble<31) speechsprite=87+flr((speechbubble-13)%6/3)
		if(speechbubble<13) speechsprite=83+flr((speechbubble-1)/3)
		if(speechbubble>=31) speechsprite=89+flr((speechbubble-31)/3)
		spr(speechsprite,x,y)
	end
end

skulls={}
function create_skull(x,y)
	skull={}
	skull.x=x
	skull.y=y
	skull.timer=0
	
	add(skulls,skull)
	
	killcount+=1
end

function animate_skulls()
	for skull in all(skulls) do
		skull.timer+=1
		if(skull.timer>16)del(skulls,skull)
	end
end

function draw_skulls()
	if(night or twilight)pal()
	for skull in all(skulls) do
		skullsprite=43+max(0,skull.timer-12)
		local offsetx=abs(5-(skull.timer%5)-3)-1
		
		if(not gameover)skull.x-=offsetx
		
		if(skull.timer==1)skullsprite=47
		if(skull.timer==2)skullsprite=45
		if(skull.timer==3)skullsprite=44

		spr(skullsprite,skull.x,skull.y-skull.timer)
	end
end

phantom_health=phealth

function draw_hud()
	if(night or twilight)pal()
	healthcheck()
	--phantom health bar--
	rectfill(12+camerax,5,12+flr(phantom_health/2)+camerax,10,9)
		
	--health bar--
	spr(82,2+camerax,4)
	rectfill(12+camerax,5,12+flr(phealth/2)+camerax,10,8)
	line(12+camerax,6,12+flr(phealth/2)+camerax,6,2)
	if(phealth>80)line(53+camerax,6,53+camerax,9,2)
	rect(12+camerax,5,54+camerax,10,7)

	if(phantom_health>phealth)phantom_health-=1
	if(phantom_health<1)phantom_health=1

	--killcount--
	spr(43,2+camerax,13)
	print("x " .. killcount,12+camerax,14,7)
	
end

function fixcamera()
	if(px-camerax>82)camerax+=1
	if(px-camerax<30)camerax-=1
	
	if(camerax<0)camerax=0
	if(camerax>896)camerax=896
	
	camera(camerax,0)
end

function rendermountains()
	local offset=camerax/1.5

	for x=0,20 do
		spr(165,x*64+offset,70,2,1)
		spr(181,x*64+offset,78,4,1)		
		spr(135,48+x*64+offset,70,2,1)
		spr(149,32+x*64+offset,78,4,1)
	end
	
	rectfill(0,86,1280+offset,128,1)
	if(night)pal()spr(73,200+offset,83)
end

cloudoffset=-100
cloudspeed=0.1
backcloudoffset=-120
backcloudspeed=0.03
function renderclouds()
	local offset=camerax/1.2

	pal()
	gameoveryet()
	for x=0,20 do
		spr(185,x*56+backcloudoffset+camerax,59,7,1)
	end
	
	rectfill(0,67,1280+backcloudoffset+camerax,128,7)

	if not gameover then pal(7,6)
	else pal(7,14) end
	gameoveryet()

	for x=0,20 do
		spr(185,x*56+cloudoffset+offset,72,7,1)
	end
	
	rectfill(0,80,1280+cloudoffset+offset,128,7)
	pal()
	gameoveryet()

	if(not gameover)cloudoffset-=cloudspeed
	if cloudoffset<=-156 then cloudoffset=-100 end

	if(not gameover)backcloudoffset-=backcloudspeed
	if backcloudoffset<=-176 then backcloudoffset=-120 end
end

function drawbg()
	gameoveryet()
	--sky--
	if(night)rectfill(0+camerax,0,128+camerax,128,5)
	if(not night)rectfill(0+camerax,0,128+camerax,128,12)
	circfill(174+camerax-flr(time)/5,20+((flr(time)-500)/50)^2,20,7)
	if(night)circfill(174+camerax-flr(time)/5-5,20+((flr(time)-500)/50)^2-5,15,5)
	if night
	then
		spr(35,120+camerax,48)
		spr(51,300+camerax/1.5,48)		
		for star in all(stars) do
			pset(star.x+camerax,star.y,7)
		end
	end
	
	renderclouds()
	
	--mountains--
	rendermountains()
	
	spr(31,712,88)
	spr(98,704,96,3,1)

	--background--
	gameoveryet()
	if(night)pal(6,13)
	map(0,0,0,0,128,16)
	--secrets of twilight!--
	if(twilight)	map(0,16,0,64,24,8) map(24,16,192,0,104,8)
	
	--buildings--
	--map(0,0,0,-1,64,16)
	
end

function drawfg()
	--background covering player--
	gameoveryet()
	if(night)pal(6,13)
	palt(11,true)
	for x=0,4 do
		if(flag(pmapx,pmapy-x,7)) map(pmapx,pmapy-x,(pmapx)*8,(pmapy-x)*8,1,1)
		if(flag(pmapx,pmapy-x,7)) map(pmapx,pmapy-x,(pmapx)*8,(pmapy-x)*8,1,1)
	end
	palt()
	
end

function drawfglayer()
	gameoveryet()
	--foreground layer--
	local offset=camerax/2
	if(night)pal(6,13)
	map(0,24,-offset,69,128,8)
end


-- game functions --
--------------------
function update_gameover()
	if(btn(4,0)) run()
end

--update some logic yo!--
function _update()
--	if speed <= 1
--	then
--		if loops>=1
--		then
		if true --game
		then
			if not gameover
			then
				if px>999 and py==88
				then
					done=true
					px+=1
									
					if px>1010	
					then
						--poke(0x4302,7)--ending
						--poke(0x4303,flr(killcount/256))--kills 1
						--poke(0x4304,killcount%256)--kills 2
						--poke(0x4305,flr(gametime/256))--time 1
						--poke(0x4306,gametime%256)--time 2
					
						--if peek(0x4302)==7
						--then
							--if peek(0x4301)==7
							--then 
								--load("english")
							--else
								--load("nihongo")
							--end run()
						--end
					end
			
				else
					--poke(0x4302,0)
				end
				
				time+=1
				gametime+=1
				if time>700 then twilight=true fset(130,3,true) end
				if time>1017 then time=0 twilight=false fset(130,false) if night then night=false fset(233,false) else night=true fset(233,3,true) end end
				generate_helicopters(px+228)
				generate_tinies(px+128)
				generate_humans(px+150+camerax/2)
				move_humans()			
				if(not done)input()
				pupdatecollision()
				healthcheck()
				pmove()
				pupdatecollision()
				for human in all(humans) do
					ai_human(human)
				end
				ai_helicopters()
				move_fireballs()
				burn_flames()
				panimate()
				animate_speechbubble()
				animate_tinies()
				animate_skulls()
				fixcamera()
				fixcamera()
			else
				update_gameover()
			end
		end
--			loops=0
--		end
--		loops+=speed
--	else
--		while (loops<=speed) do
--			input()
--			pupdatecollision()
--			healthcheck()
--			pmove()
--			for human in all(humans) do
--				ai_human(human)
--			end
--			move_humans()
--			ai_helicopters()
--			move_fireballs()
--			burn_flames()
--			panimate()
--			animate_tinies()
--			animate_skulls()
--			fixcamera()
--			fixcamera()

--			loops+=1	
--		end
--		loops=1
		
--	end
	
	if title --title
	then
		if(not done)input()
		pupdatecollision()
		panimate()
		move_fireballs()
		pmove()
		
		if py==40
		then
			if canisetdifficulty
			then
				if difficulty=="easy" then difficulty="medium"
				elseif difficulty=="medium" then difficulty="hard"
				elseif difficulty=="hard" then difficulty="doemu"
				elseif difficulty=="doemu" then difficulty="easy" end
				canisetdifficulty=false
			end
		else
			canisetdifficulty=true
		end
	end
	
	if startinggame --startinggame
	then
		if cameray<0
		then
			cameray+=1
			if(camerax>0)camerax-=2/5
			camera(camerax,cameray)
		else
			startinggame=false
			game=true
		end
		
		if difficulty=="easy"
		then
			max_humans=10
			max_helicopters=1
			max_tinies=15
			maxmins=5

			damage_human=0.5
			damage_helicopter=0.5
			human_deliciousness=100
		end
		if difficulty=="medium"
		then
			max_humans=10
			max_helicopters=2
			max_tinies=20
			maxmins=2

			damage_human=0.5
			damage_helicopter=1
			human_deliciousness=20
		end
		if difficulty=="hard"
		then
			max_humans=10
			max_helicopters=2
			max_tinies=30
			maxmins=1

			damage_human=1
			damage_helicopter=3
			human_deliciousness=20
		end
		if difficulty=="doemu"
		then
			max_humans=10
			max_helicopters=5
			max_tinies=80
			maxmins=0

			damage_human=1
			damage_helicopter=2
			human_deliciousness=-20
		end

		
	end
	
end

-- generators --
----------------
function generate_humans(minx)	
	local giveup=0
	while count(humans)<max_humans and giveup<20
	do

		place=flr(rnd(400))+minx
		local stop=false
		if mget(flr(place/8),29)==129
		then
		
			for human in all(humans) do
				if(abs(human.x-place)<8)stop=true
			end
		
			if(not stop)create_human(place,105)

		end

		giveup+=1
	end
	
end

function generate_tinies(minx)
	local giveup=0
	while count(tinies)<max_tinies-10 and giveup<20
	do
	
		x=flr(rnd(100))+minx
		y=flr(rnd(120))
		if(floor(flr(x/8),flr(y/8)) and floor(flr(x/8)+1,flr(y/8)) and floor(flr(x/8)-1,flr(y/8)))create_tiny(x,y)
	
	giveup+=1
	end
end

function generate_helicopters(minx)
	local giveup=0
	while count(helicopters)<max_helicopters and giveup<20
	do
		
		local stop=false
		x=flr(rnd(100))+minx

		for helicopter in all(helicopters) do
			if(helicopter.stufftotheleft or helicopter.stufftotheright)del(helicopters,helicopter)
			if(abs(x-helicopter.x)<8)stop=true			
		end

		if(not stop)create_helicopter(x,80)
		ai_helicopters()

		giveup+=1
	end
end

stars={}
--initialize da good stuff yo!--
function _init()
	start=true
	music(0)
	
	local x=0
	while count(stars)<30 do
		star={}
		star.x=flr(rnd(128))
		star.y=flr(rnd(86))
		add(stars,star)
		x+=1
		
		for otherstar in all(stars) do
			if(abs(otherstar.x-star.x)<2 and abs(otherstar.y-star.y)<2) del(stars)
		end
	end

		--ram=peek(0x4300)
		--if(ram==0)load("nihongo")run()
		--if(ram==1)difficulty="easy"
		--if(ram==2)difficulty="normal"
		--if(ram==3)difficulty="hard"
		--if(ram==4)difficulty="doemu"

		--if difficulty=="easy"
		--then
			--max_humans=10
			--max_helicopters=1
			--max_tinies=15
			--maxmins=5

			--damage_human=0.5
			--damage_helicopter=0.5
			--human_deliciousness=100
		--end
		--if difficulty=="medium"
		--then
			--max_humans=10
			--max_helicopters=2
			--max_tinies=20
			--maxmins=2

			--damage_human=0.5
			--damage_helicopter=1
			--human_deliciousness=20
		--end
		--if difficulty=="hard"
		--then
			--max_humans=10
			--max_helicopters=2
			--max_tinies=30
			--maxmins=1

			--damage_human=1
			--damage_helicopter=3
			--human_deliciousness=20
		--end
		--if difficulty=="doemu"
		--then
			--max_humans=10
			--max_helicopters=5
			--max_tinies=80
			--maxmins=0

			--damage_human=1
			--damage_helicopter=2
			--human_deliciousness=-20
		--end
	
end

--draw some cuties yo!--
function _draw()	
	if game --game
	then
		drawbg()
		draw_tinies()
		pdraw()
		drawfg()
		for flame in all(flames) do
			draw_flame(flame)
		end
		draw_fireballs()
		drawfglayer()
		draw_humans()
		draw_helicopters()
		draw_skulls()
		draw_speechbubble(px+20-pfacing*4,py-2)
		draw_hud()
	
	--print("time " .. flr(time),0,30)
	--print (pmapx .. "," .. pmapy,camerax,20)
		if(gameover)pal()print("game over!",48+camerax,50,12) print("game over!",47+camerax,49,7)
		
		minutes=maxmins-1-flr((gametime-30)/1800)
		seconds=-flr(gametime/30)%60		
		spr(198,camerax+2,21)		
		if minutes>=0
		then
			if seconds<10 then print(minutes .. ":0" .. seconds,camerax+11,21)
			else print(minutes .. ":" .. seconds,camerax+11,21) end
		else
			minutes=flr((gametime)/1800)-maxmins-1
			seconds=flr(gametime/30)%60
			if seconds<10 then print("-" .. minutes+1 .. ":0" .. seconds,camerax+11,21)
			else print("-" .. minutes+1 .. ":" .. seconds,camerax+11,21) end
			
		end
		
	end
	
	if(title)camerax=16 cameray=-40 camera(camerax,cameray)
	if title or startinggame
	then
		colours={0,0,5,5,6,5,6,7,5,6,7,7,6,6,6,7}
		for x=1,16 do pal(x-1,colours[x]) end
		rectfill(0,-40,143,168,12)
		renderclouds()
		for x=1,16 do pal(x-1,colours[x]) end		
		rendermountains()
		map(0,0,0,0,24,16)
		spr(117,136,8)
		pal()
		print("difficulty",72,64,8)
		print("options",24,40,8)
		print(difficulty,104,16,8)
		
		if(py==16)pal()	map(2,4,16,32,6,3)
		if(py==-8)pal()	map(11,0,88,0,7,4) spr(117,136,8)
		if(py==40)pal()	map(8,6,64,48,8,4)
		
		pal()
		pdraw()
		draw_fireballs()		
		print("rabu rabu monster!",47,-20,8)
		print("rabu rabu monster!",46,-20,7)
	end
end
__gfx__
000000008800000000000000000000000002bbbbbbbb3333330000000002bbbbbbbb333000000000000000000000000000000000000000000000000066656660
000000002880000000000000000000000002bbbbbbbbbbb3333000000002bbbbbbbbb33000011110000111100000000000000000000000000000000066655660
000888888882000000000000000000000022bbbbb33bb333b33000000022bbbbbbbbb333000fff11000fff110000000000000000000000000000000066566660
00002823bbbb3000000000000330000000223bbbbb33333bb330000000223bbbbbbbb3330001f1f10008f8f10070000077777000007000007777700066111660
000002bbbbbbb300000f00000bb3000002223bbbbbb333333300000002223bbbbbbb3333011ffff0011ffff00888000008880000088800000888000066661660
000883b33bb33b300b8000003b3b300002023bbbbbb333333000000002023bbbbbbb333300f8800000f880000778070007787070077877700778070066116660
00882bb363bbb330bb8b00003303300000023bbbbbb3333b3330000000023bbbbbbb333300088800000888000888787008888800088878700888787022222220
00083b2b763333630333000007070000002233bbbbb330333336000000223bbbbbb3333300040400000404000000070000007070000077700000070040000040
0082bb2b776336636656566066666660002033bbbb3330000000000000203bbbbb3333333bb30000000000000000000000000000000000000000000070000000
0082bb2bb33366336565616066551660000003bbb300000000000000000033bbb3003333bbbb3000000011110000000000000000000000000000000070000000
0822bb27bb333333656661606666666000003b3330000000000000000003333330033333b333b3000000fff10000000000000000000000000000000070000000
0002bb226726726761666160665116600000bbbb33711111111100000003333300056330b111133090008f8f0007000077777000000700007777700077007070
0002bb272722720766161660666166600007633773661111110000000003333330056360bfff1130a711ffff0088800008880000008880000888000070707070
0082bbb72227207066616660666166600000111671111100000000000006367360005060b1f1f130980f88009077807007787070907787770778070077000700
0082bbbb62672670222222202222222000000011111000000000000000060700600000006ffff30000008880a788878708888800a78887870888787000007000
0822bbbbbbbbbbbb4000004040000040000000000000000000000000000006000000000006333000000040409800007000007070980007770000070000070000
0002bbbbbbbb333300000000000000000002bbbbbbbbbbb3000000000000a000bbba9bbb77633663000000000066665000555520002222100011110000000000
0002bbbbbbbbbb3300000000700700000002bbbbbbbbbb3300000000009a98a0bbaaa9bbb3336633000000700677776505666652025555210122221000111100
0022bbbbb33bbbb3300000000000000700223bbbb3333bb33000000009aaa9a0bbaa99bbbb333333000000000675756505626252025151210120201000101000
00223bbbbb333b33330000000000000000223bbbbbbb3333330000009a977a98b994299b6726726700000f070566666502555552012222210011111000000000
02223bbbbbb3333b330000000000000002223b3bbbbb333b330000009a777a99bbb42bbb27287887800080000056565000252520001212100001010000000000
02023bbbbbb333bb33000000070007000202333bbbbb333b33000000a9777a98b33333bb22878878880080000675756505626252025151210120201000101000
00023bbbbbb3333330000000000000000002003bbbbb3333300000000a77a980b3333bbb62672670288822800055555000222220001111100000000000000000
002233bbbbb33333000000000000000000220003bbb303330000000000aa9800b333bbbbbbbbbbbb028882000000000000000000000000000000000000000000
002033bbbb3333b333000000070070700020003b333003333300000000000000000000000008000000088808000aa8000097a9900a77aaa00a7aa00000990000
000003bbb30003333360000000000000000000bbbb3370033360000000000000000000000889980089aaa98009a77a800a777799a777777aa799aa7a079889a0
00003b33300011111110000000000000000007633773660111100000000000000079800089aa98809a7777909a7777a0a777777a77797777a98899a70a800890
0000bbbb337111111100000070000000000000000670111111000000777770000899980009a779809a7777909a7777a0a777777a77a88a77a98008aa9a000089
0007633773661110000000000000000700000000000111110000000008890000099799008997a90089a77a800a7777990779777a77a88977a980089a98000089
00001116711111000000000000000000000000001111111000000000079890700899987088999880889aaa8009777a900777777aa7779777a79899a7988088a0
00000011111000000000000000000000000000011111100000000000088988000089070008808800089aa900989779000a7777a0a7777790a7799a9a0aa88a90
00000000000000000000000000070000000000000000000000000000000070700000000000000000000888009009900000a77a900a7777a00a7aa7a000099000
bbbe8bbbbbbbbbbb66611666dddd1111bbbbbbbbffffbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000bbbbbbbbbbbbbbbbbbbb8888888888882888888bbbbbbbbb
bbeee8bbbbbbbbbb661661666666d111bbbbbbffffbbbbbbbbbbbbbbbbbbbbffbbbbbbbb00000000bbbbbbbbb3bbbbbbbbb812888288888888888888bbbbbbbb
bbee88bbbbbbbbbb6166661666666d19bbbbffffbbbbbbbbbbbbbbbbbbbbffffbbbbbbbb00090000bbbbbbbb3b3bbbbbbb81112888288888888888888bbbbbbb
b884288bbbbbbbbb6166661666666d11bbffffbbbbbbbbbbbbbbbbbbbbffffbbbbbbbbbb0aaa9880bb3bbbbbb3bbbbbbb8111118888288888888888888bbbbbb
bbb42bbbffffffff66166166666666d1ffffffffbbbbbbbbbbbbbbbbffffbbbbffffffff000a0000b3b3bbbbbbbbbbbbb1111112888288888888888888bbbbbb
b33333bbffffffff66611666666666d1ffffffffbbbbbbbbbbbbbbffffbbbbbbffffffff0a8a8000bb3bbbbbbbbbbb3bb11111118888288888882888888bbbbb
b3333bbbbbffffbb222222226666666dbbbbbbbbbbbbbbbbbbbbffffbbbbbbbbbbbbbbbb98009800bbbbbbbbbbbbb3b3b11111112222222222222222222bbbbb
b333bbbbbbbbffbb400000006666666dbbbbbbbbbbbbbbbbbbffffbbbbbbbbbbbbbbbbbb80000988bbbbbbbbbbbbbb3bb11111111111111111111111111bbbbb
0000000000000000007707700000000000000000008088200677776006777760028288220020220000000000ffffbbbbb19111114424442444244424442bbbbb
0000000000000000072272270000000000000000088288826222777662828822688888825222222000000000ffbbbbbbb11111114222442444244422242bbbbb
0000000088000000078828270000000000828220088888827882882278888882788888826222222050000000bbbbbbbbb11d1111466d442444244466d42bbbbb
0000000028800000078888270020200002888820088888827888882278888882728888276022220650000005bbbbbbbbb31dd19146dd4424442444ddd42bbbbb
0008888888820000078888270022200002882200028888267288822772888827778882776622206655000055ffffffffb33dd111442444246d244424442bbbbb
00002823bbbb3000007882700022000000222500068882706788227667888276677827765662066505500550ffffffff3333d111442444246d244424422bbbbb
000002bbbbbbb300000727000000000000025000007827600062276007782760077277600660665005505500bbbbbbbb3333311122222222d2222222222bbbbb
000883b33bb33b30000070000000000000000000000200000000000077620000776000006650000055000000bbbbbbbb33333333333333333333333333bbbbbb
00882bb363bbb3300000070007000707077770006666666666666666666000006665666556666666665566600000000000000000000000002420000024200000
00083b3b763333630070707000707700000700006655565556555655566000006665166666665551665666600000000000000000000000002420000024200000
0082bb3b776336630707070000770000007000006656165666566656166000006661666516666616651116600000000009222222222222222422200024222222
0082bb37b33366337000700007000000077777006611665166116655666000006651665661665666666166609aaaaaaaa2211111111111112421120024211111
0882bb37bb3333330000070070000000700000706616161666166656166000006561166661656666661666600000009a22144444444244422424412024224442
0082bbb7633733730000007070000000000000706611161116111616166000006611666616661111661116600000001991222222444244424244441942424442
0082bbbb636736730000000007777700077777002222222222222222222000002222222222222222222222200000001249114242222222222222219222222222
0822bbbbbbbbbbbb0000000000000000000000004000004000004000004000004000000000040000000000400000000112991142444444444441194244444444
66565516666566666666666066666666665666566666666066656666bbbbbbbb000000000000000002000000bbbbbbbb014999111111111111199942bbbe8bbb
65666666666566655165656065556555655565516665666065511166bb288bbb000022222222222224222222bbbccdbb012944999999999999949441bbeee8bb
66165116656111616165616066616661665666166665166066616666b28867bb006677777777777777777776bb76ccdb001194244244424442492420bbee88bb
61166166656166611666566066116611651165165511116065111166b128888b067777777777777777777760bccccd1b000019999999999999942410b884288b
66166166616166616166166066666666611661166661166061616166b111111b067777777777777777777600b111111b000012244244424442421100bbb42bbb
66166166111111616166166066166616161616166661666066616666b133131b067777777777777777776000b131331b000001111111111111110000b33333bb
22222222222222222222222022222222222222222222222022222222b33333bb006777777777777777776000b33333bb000000000100010000000000b3333bbb
40000000000400000000004040000000000400000000004000040000bbbbbbbb000666666666666666666600bbbbbbbb000000007770777000000000b333bbbb
dddddddddddddddd00000000d0000000ddddddddddd66666000011110000110000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000bbbbbbbb
1d66666666666666000000006d000000ddd66666dddddddd00001911000111100000000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000bbbbbbbb
01d66666666666660000000066d00000ddd66666dddddddd0001111100111110000000000000bbbbbbbb8888888888888888888bbbbbbbbbbbbbbb00bbbbbbbb
001d66666666666600000000666d0000ddd66666dddddddd000111150111111100000000000bbbbbbbb188111111111111111188bbbbbbbbbbbbbbb0bbbbbbbb
0011d66666666666000000006666d000ddd66666dddddddd000111110111111100000000000bbbbbbbb1188111111111111111288bbbbbbbbbbbbbb0bbbbbbbb
00011d66666666660000000066666d00ddd66666dddddddd00115111111111111000000000bbbbbbbb111818111111111111112228bbbbbbbbbbbbb0bbbbbbbb
000111d66666666600000000666666d0ddd66666dddddddd0011111111111111100110000bbbbbbbbb111918111111111111112228bbbbbbbbbbbbbbbbbbbbbb
0000111d66666666000000006666666dddd66666dddddddd0111119111111111101110000bbbbbbbb11111118888888888888888888bbbbbbbbbbbbbbbbbbbbb
00001111d66666666666666666666dddbbbbfffb00000000000000011111111111111100bbbbbbbb00000000000000000000000000000000bbbbbbb3bbbbbbbb
000015111ddddddddddddddddddddd00bbbbbffb00000000000000011111111111111100bbbbbbbb00000000000000000000000000000000bbbbbbb1bbbbbbbb
0000111911ddddddddddddddddddd000bbbbbffb00000000000000111111111111111110bbbbbbbb00000888888888888888888000000000bbbbbb30bbbbbbbb
0000111111ddddddddddddddddddd000bbbbbffb000000111111011111111111111111103bbbbbbb00001811181111111118818800000000bbbb3330bbbbbbbb
00001111111ddddddddddddddddd0000bbbbbffb000001111111111111111111111111100333bbbb00008181181111111118912880000000bb331330bbbbbbbb
00001911111ddddddddddddddddd0000bbbbbffb00011111111111111111111111111111003333bb00008181191111111119112228000000bb311130bbbbbbbb
00001119111ddddddddddddddddd0000bbbbbffb011111111111111111111111111111110003133b00008118111111111111112228000000b3310210bbbbbbbb
00001111111ddddddddddddddddd0000bbbbbffb11111111111111111111111111111111000313330000111888888888888888888880000031310100bbbbbbbb
bbbb11111911dddddddddddddddbbbbbddd000000000000000000000000000006665666600001313333bb33333bbbb33333bbb333bb3333312210000bbba9bbb
bbbb19111111dddddddddddddddbbbbbddd0000000000000000000000000000065551116000011113133332123333323323333221333331101210000bbaaa9bb
bbb111111111dddddddddddddddbbbbbddd0000000000000000000000000000066566666000012013213324242433222344332422332321000210000bbaa99bb
bbb111151111dddddddddddddddbbbbbddd0000000000000111000000000000066166666000012001221324242223244424324244324321000200000b994299b
bbb111111911dddddddddddddddbbbbbddd0000000000001111100000000000066166666000001001121224220124224424242422424210000000000bbb42bbb
bb1151111111dddddddddddddddbbbbbddd0000000000011111110000000000066611116000000000112122420122421242210124242100000000000b33333bb
bb1111111111dddddddddddddddbbbbbddd0000000000011111111000000000022222222000000000001122220012220022100001221000000000000b3333bbb
b11111911111dddddddddddddddbbbbbddd0000000000111111111000000000040000000000000000000012200001200000000000000000000000000b333bbbb
11111111111dddddddddddddddddbbbbbbbbbbbb0000011111111110000011100000000000000000000077777700000000000000000000000000000000000000
31111111511dddddddddddddddddbbbbbbbbbbbb0000111111111111000111110000000000000000000777777770000000000000000000000007770000000000
33191111111dddddddddddddddddbbbbbbbbbbbb0000111111111111101111111000000000000000007777777777000000000000000000000777777777000000
33399111111dddddddddddddddddbbbbbbbbbbbb0001111111111111111111111100000000000000077777777777000000000000000000007777777777770000
3333911111dddddddddddddddddddbbbbbbbbbbb0011111111111111111111111110000000077700077777777777700000000000007770007777777777777000
3333311111dddddddddddddddddddbbbbbbbbbbb0111111111111111111111111111000000777770777777777777700000770000077777077777777777777700
333333111dddddddddddddddddddddbbbbbbbbbb1111111111111111111111111111110000777770777777777777700007777700777777777777777777777770
33333331dddddddddddddddddddddddbbbbbbbbb1111111111111111111111111111111107777777777777777777770777777777777777777777777777777770
00001313333bb33333bbbb33333bbb333bb33333bbbbbbb30066660000088888888800000000112200000000000b300000000000000000000000000000000000
0000111131333321233333233233332213333311bbbbbbb10677771000812888288880000000112200000000000b300000000000000000000000000000000000
0000111132133242424332223443324223323210bbbbbb30677777610811128882888800cccc11220000000000bb330000000000000000000000000000000000
0000112212213242422232444243242443243210bbbb3330677555618111118888288880cccc11220000000000bbb30000000000000000000000000000000000
0000012211212242241242244242414224242100bb331330677577611111112888288880ccccc112088888000bbbbb3000000000000000000000000000000000
0000012121121224221224212422142241421110bb311130677777611111111888828888ccccc112812888800bbbb33000000000000000000000000000000000
0000011121111222244122244221142142211210b3312210016666101111111222222222cccc112111128888033b3b300a000b000000e00000000b000000e000
000011122212212212441244442221421221221031312100001111001111111111111111cccc112211122222003333000ae0bb30a0b0eb0e00e0bb30a0b0eb00
0000112222124142422212114424224221111110bbbbbbb33bbbbbbb19111114424442441111111111111111bbb22bbbaae8bbb3a9beeb3e00e8bbb3a9beeb3b
0000112221222144421144222244212222112110bbbbbbb11bbbbbbb11111114424222441010101011112424bbb42bbbaeee8b3aaa9ebbb30eee8b3aaa9ebbb3
0000112212111222412444244244111244211100bbbbbb3223bbbbbb11d1111442499944222222221d112494bbb22bbb4ee8842aa994bb330ee8842aa994bb33
0000112222212441224142224422144224211100bbbb33322333bbbb31dd191442499944442244223d112222bb333bbb88428899429934238842889942993423
0000011224214444144412114411124212211000bb331332233133bb33dd111442444244444244423333333bb3333bbb11421111421114213142111142111421
0000011214412444144411112244412221111100bb311132231113bb333d11144244424411111111333333bbb3333bbb31113331113311133111333111331113
0000112112441242244224422444422442211210b33122122122133b33331112222222221412141233333bbbb333bbbb3333333333333333333333333333333b
00001122122441221221444244442244221122103131212222121313333333333333333311111111333bbbbbbbbbbbbb333333333333333333333333333333bb
bbbb11222212414242221211442422422111111bbbbbb11111111111113bbbbbbbbbbbb3000000003bbbbbbbbbb28bbbbbbbbbbbb004000b0000c0000000c000
bbbb11222122214442114422224421222211211bbbbbb31210101010123bbbbbbbbbbbb1000000001bbbbbbbbb2888bbbbbbbbbbbb0400bb000c0c00000c0c00
bbbb1122121112224124442442441112442111bbbbbb33222222222222231bbbbbbbbb3cccccccccc3bbbbbbb222288bbbbbbbbbbbb40bbbc0c000c000c000c0
bbbb1122222124412241422244221442242111bbbbbb13224422442244211bbbbbbb333cccccccccc333bbbbbb2bb2bbbbbbbbbbbbbbbbbbc000000000000000
bbbbb11224214444144412114411124212211bbbbb3311224442444244131bbbbb33133cccccccccc33133bbbb1111bbbbbbbbbbbbbbbbbbc00ccc00000ccc00
bbbbb112144124441444111122444122211111bbbb31131111111111111313bbbb31113cccccccccc31113bbbb1555bbbbbbbbbbbbbbbbbbc0c0c0c000c0c0c0
bbbb11211244124224422442244442244221121bb3311112141214121413133bb331221cccccccccc122133bb33113bbbabbbbbbbbbbbbbbc0ccc0c000ccc0c0
bbbb11221224412212214442444422442211221b313111111111111111111333313121cccccccccccc121313b3333bbbbaebbb3bbbbbbbbbc000000c00000000
bbb311212212414242221211212222422111111b2111111ccccccccccccc1122c0000000cccccccc66665666656566666666666066666666c00000cc00000000
bb3311212122214442111244144421222211111b2211211ccccccccccccc1122c0c00c00cccccccc656551666565556666566560666666660c00000c00000000
bb3331121211122241221224244211124421113b44211177777777777777112200c00c0c77777777656616666556161665666560665566660c0000cc00000000
b3333112222124412242112242221442242111bb242111cccc7ccc7ccccc1122cc00000ccccccccc656111665566661656666160656616660c00000000000000
b3333312142144441442111144111242122113bb12211ccccc7cccccccccc112c0000000cccccccc6516161666161166616666606666616600c0000000000000
b333331214212442142111112122212221113bbb211111ccccccccccccccc1120c0000c0cccccccc6161166666166666661661606666661600c0000c00000000
3333333112211111221331121111112411133bbb4221121ccccccccccccc112100c000c0cccccccc22222222222222222222222022222222000c00c000000000
3333333311111331113b3311133331111333bbbb2211221ccccccccccccc1122cccccc00cccccccc400000000000400000000040000400000000cccc00000000
__gff__
00000000000000000000000000000020000020200000000000000000000000180000000000000000080000000000000000000000000000000000000000000000080820090808000808000800282828a8000000000000000000000008111111910000c81800202020202020222a2a2a2a20202020202020002222220022222200
202000a0000000000000404040c0000021a1a1a1000000000000404040c00008212121a1a10008002000000000000000111111912a0000000000000000000000010101010108000000010000000000000101010101080800002e0000000000000101010101082a0808000800082a000001010101010100010000202020200000
__map__
000000000000000000000000cccf00ca000000000000cb00000000000000424276750000000000000000000000000000000000000000000000000000000000000000999f4a9f4a9f9f9f9f4a9f9f9f9f9f9f9f4a9f9f9f9f9f9f9f9f4a9f9f9f9f4a9f9f9f9f4a9f9f9f9f9f4a9f9f9f9f4040409f408f284040288f28402828
000000000000000000000089dcdf8fda8e0000000089db8e0000000000898f4baf7f8e00000000000000000000000000000000000000000000000000000000000000a9aaabacadabacababacabacababacacabacacadaaabacadabacabacadabacadabacadabacabacabacadabacadabacabacadabacabacabacadabacadabac
0000000000000000000000999f9f9f9fe5e6e6e6e6e79fe5e6e6e6e6e6e74a9f9f9f9e00000000000000eeef0000000000000000000000000000000000000000898fdcdddcdddcdddcdddcdddcddafdcdddcdddcdddcdddcdddcdddcdddf8e000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000a9aaabacadae00000000a9abae0000000000a9aaabacadae00000000000000fef80000000000cb0000000000000082828282000000999f4848484848484848484848484848484848484848484848484848489f9e000000000000000000000000000000000000000000000000000000000000000000
0000897f8f8f8f8e00000000000000000000000000000000000000000000000000000000cbcbc7c8000000000000cb897fdb8ecacbca00000000000000000000a9aaabacacacababacabacadabacaaabacaaabacadaaabacadabacabacadae000000000000cbcbc7c8000000000000000000000070fc42427600000000cb0000
0000999f9f9f4a9e00000000000000000000000000000000000000121212120000000089dbdbd7d88e0000000089dbafdcdf46dadbda8e0000000000000000000000000000000000000000c7c8000000000000000000000000000000000000000000000089dbdbd7d88e4242767500000089af4c4d4d4d4d4d4d4e4e4fdb8e00
0000a9aaabacadae0000cccdcccf000000000000000000000000008081818183000000994a484848e5e6e6e6e6e7484848445b489f4a9e0000000000000000000000000000747412008977d7d88e00000000000000000000000000000000000000000000999f4a4848e5e6e6e6e6e6e6e6e7485c5d5d5d5d5d5d5e5e5f9f9e00
0000000000000000894bdcdddcdf4b8e00000000000000000000009091929293000000c0c2c3c1c4ae00000000a9aaabacababaac1c4ae00000000000000000000000000897f4b7b8e994a4a7f9e897f4b7f8e0000000000000000000000000000000000a9aaabacadae00000000000000c0c1c2c2abacadacadacadacadae00
0000000000000000999f9f4a9f9f9f9e000000000000000000000090a1a2a2a4000089e0d1d2d3d40000000000000000000000d0d1d41275000000000000000000000000999f9f4a9ea9aaabadae994a8f4a9e00000000000000000000000000cb00000000000000000000000000000089e0e1e3e48e0000fafafacbcccdcf00
0000000000000000a9aaaaababacadae000000000000000000000090a1a2a2a4897f8fe0e1e2e3e48e000000000000000089afe0e1e47f4b8e0000000000000000000000a9aaabadae0000000000a9aaabadae0000000000000000000089afafdbaf8e0000000000000000000000000099f0f1f3f49e00894b8f7fdbdcdddf8f
00000000000000000000000000000000000000000000000000000090a1a2a2a4999f9ff0e1e3e1f4c50000000000000000999ff0f1f44a9fc5000000000000000000000000000000000000000000000000000000000000000000000000999f9f4a9f9e00000000000000000000000000a9aaabacaaae00999f48484848484848
00000000000000000000000000000000008081818300000000000090a1a2a2a4c0c1c2d6f0f2f4c5ae0000000000000000a9aaaac1c1c2c3d4000000000000000000000000000000000000000000000000000000000000000012120000a9aaabacadae0000000000000000000000000000000000000000a9aaabaaabacaaabac
cccdcccdcfcb68696a007374fd0000000090919293cccdcf00cb0090a1a2a2a4d0d1d2d1c2c3c1d40000000000cbca65666712d0d1d1d2d3d4cb7375000000000000000000000000000000000000000000000000000000007071720000000000000000000000000000000000000000cbcbc7c8ca0000000042427675cbcccdcc
dcdddcdddfdb8f7f468f8f8f8f8f8f8f8fa0a1a2a3dcdddf4bdb8fa0a1a2a2a3e0e1e2e3e1e1e3e48e00000089dbda4c4d4e4fe0e1d1d2d3e4db4b8f8e000000000000000000000000000000000000000000000000000089b4edb48e000000000000000000000000000000000000894b77d7d8daeb8f8f4b8f4b7fafdbdcdddc
48484848484848445b41489f9f9f9f9f9fb0b1b2b39f9f4aec9fecb0b1b2b2b3f0f1f2e1e1e3d2f4e5d9d9d9e79f4a5c5d5e5ff0e1e3e2e3e44a4848e5d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9e74a9f4ae5e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9e9ea4a9f9f9f9f9f9f9fec4848484848484848
dddcdcdd8f4b7f8f4a94af8f8f8f8f8f8f8f8f8f8f4b8f8fdcdddcdddcdddcdddcdd7ff0f1f3f4d5f5f6f9f9f7d68f7f4b8fafebf0f1f2f3f48f7fd5f5f9f9f9f9f6f9f9f9f9f9f9f9f9f9f9f6f9f9f9f9f9f9f9f6f9f9f7d67fd5f5f9f9f9f9f9f9f6f9f9f9f9f6f9f9f9f6f9f9f7d64b7f4b8f7f8f4bdcdddcdddcdddcdddc
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000078797a787a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006b6c6f6d6e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000caa800000013c7c8000000000000000000000000000000000000000000000000000000000000000000000000000000007c7d7d7e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000da774c4d4e4fd7d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000005c5d5e5feb0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000007b4c4d4d4e4f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080818300000000000000000000000000000000000000000000008081830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090919300000000000000000000000000000000000000000000009091930000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090a1a4808183000000000000000000000000000000000000000090a1a40000000080818183000000000000000000000000000000000000000000000000808183000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808143a1a4909193000000000000000000000000000000000000000090a1a480818181439192930000000000000000000000000000fafbfc00000000000000909193000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000080818183008081818181830000808181439192a1a490a1a4000000000000000000000000000000000000000090a1844391929292a1a2a400000000000000000000008081818181818300808181818143a1a4000080818181818181818181818181818183
000000000000000000000000000000000000000080818181818183009091929300909192929293000090919292a1a2a18443a1a4808181830000000000000000000000000000808143a18592a1a2a2a2a1a2a400000000000000000000009091929292929300909192929292a1a4000090919292929292929292929292929293
0000000000000000000000000000008081818181439192929292930090a1a2848143a1a2a2a2a4000090a1a2a2a1a2a18592a1a4909192930000000000000000000000000000909192a1a2a2a1a2a2a2a1a2a4000000000000000000000090a1a2a2a2a2848143a1a2a2a2a2a1a4000090a1a2a2a2a2a2a2a2a2a2a2a2a2a2a4
__sfx__
011000002137000000213700000030675213700000020370000002037020370203703067500000203700000000000000000000000000306750000000000000000000000000000000000030675000000000000000
010500002b1002b1002b1002b1002b1002b1002c1002c1002c1002c1002b1002b1002b1002b1002f1002f1002f1002f100301003010030100301003010000200261000020000200002001a10000200002002b100
011000001867000000000000000018670000000000000000186700000000000000001867000000000000000018670000000000000000186700000000000000001867000000000000000018670000000000018600
011000001c1701d1701c1701f1001f170211002017020100211702017021170241702410028100241000000027100281702617000000241702410026170261002817027170281702b17030100000000000000000
011000000c070246033060300000070700000000000000000c070000000000007070070700707009070000000c070000000000000000070701310000000000000c07000000000000707007070070700507005070
011000001837000000183703060030675183700000018370000001837018370183703067500000183700000000000000001f37000000306751f370000001f3702230000000223700000030675000002237000000
01100000050700000000000000000c0700000000000070000507000000000000c0700c0700c0700b0700b070050700000000000000000c070000000000000000070700900000000000000c0700c0700b0700b070
01100000213702230021370000003067521370000002037000000203702037020370306750000020370000001e3001f3001f37000000306751f3701f3001f3002437026370243702b370306752b3702b3702b370
01100000000002b170291700000024170000002817000000291702817029170211700000024170261701f1701f1001d1001f100000000000000000000000000000000000000000000000000001f1001c1001c100
011000001c1701d1701c170000001f1701d100201700000021170201702117024170000002617000000271702717029170271702b1002b1702d1002d170000002e1702d1702e17029100000002e1702d1702d100
011000001a3701a3701a3701f3701f3701f3702137021370213702337023370233700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00001f570265702b5702f570325702b5702f5703257021570265702b5702f570325702b5702f5703257023570265702b5702f570325702b5702f5703257021570265702b5702f570325702b5702f57032570
011000002137000000213700000030675213702130020370203002037020370203703067500000203700000000000000001f37000000306751f37000000000000000000000000000000030675000000000000000
01100000301702f17030170000002b1702f1002f17000000301702e1703017029170291702b170291702817028170281702810028000280702b07030070320703207030070300703507035070340703207030070
011000001c0501d0511c050000001f050000002005000000210502005021050240522405224052240522400200000280502605000000240500000026050000002805027051280502b0522b0722b0722b00200000
01100000000002b050290500000024050000002805000000290502805029050260500000024050230502b0502b0002d000290002a0002a050300000000000000290500000000000000002c050000000000000000
011000002b05029050000002405000000280500000029050280502905026050260002405023050240502400000000000000000000000000000000000000000002403424030240302403024030240302403024030
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d3341d3301d3301d3301d3301d3301d3301d330
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c1342c1302c1302c1302c1302c1302c1302c130
011000002b1202b1202b1202b1202b1202b1202b1202b1202b1202b1202b1202b1202b1202b1202b1202b12029120291202912029120291202912029120291202512025120251202512025120251202512025120
011000001832018320183201832018320183201832018320173201732017320173201732017320173201732016320163201632016320163201632016320163201532015320153201532015320153201532015320
011000002412024120241202412024120241202412024120241202412024120241202412024120241202412024120241202412024120241202412024120241202312023120231202312023120231202312023120
011000001432014320143201432014320143201432014320163201632016320163201632016320163201632013320133201332013320133201332013320133201332013320133201332013320133201332013320
010c00000547005470000000000000470004700540000000054700547000000000000647006470000000540005470054700000000000054700547000000000000540005400000000000000400004000000000000
010c00001d3701d37000000000001d3701d37000000000001d3701d370000001d300213702137021370213701d3701d37000000000001d3701d37000000000001330013300000000000000000000000000000000
011000001832018320183201832030625183201832018320173201732017320173203062517320173201732016320163201632016320306251632016320163201532015320153201532030625153201532015320
011000001132011320113201132030625113201132011320113201132011320113203062511320113201132013320133201332013320306251332013320133201332013320133201332030625133201332013320
011000002422024220242202422024220242202422024220212202122021220212202122021220212202122024220242202422024220242202422024220242202322023220232202322023220232202322023220
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000161004650136701d670176700f670056700a660076500464002630016200561004600046000460005600036000160001600000000000000000000000000000000000000000000000000000000000000
000500000462015640336300e620126100a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500003f6403a600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000240302b060300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000c160131532d1032b1031e1061e1031e1061e1061e1061e1061e1061e1061e1061f1071f1071f1071f1071f1071f1071e1072b1072d10722107231070000000000000000000000000000000000000000
000500001002024031260611f0411c061280513504124031180211800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007001
000600002765017640146301d6200b610106100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000028340303211b3002330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000395703e57119500105000c500095000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 03 04 05 44
00 08 06 07 44
00 09 04 05 44
00 0d 06 0c 44
00 03 04 05 44
00 08 06 00 44
00 09 04 43 44
00 0d 06 43 44
00 0e 42 43 44
00 0f 42 43 44
00 0e 42 43 44
00 10 11 12 44
00 0e 13 14 44
00 0f 15 16 44
00 0e 13 19 44
02 10 1b 1a 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 14 15 17 44
00 18 19 1a 44
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
