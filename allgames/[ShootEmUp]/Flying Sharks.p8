pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--flying sharks
--by flyingsmog
cls()
cartdata("smog_sharks")

--things to do:


function _init()

	debug=false
	
	st="menu"
	game_score=0
	music(0)
	a=1
	
--pointer
	pointer={}
	pointer.y=1
	
--entering
	enter={}
	enter.timer=25
	enter.v=0
	enter.a=0.1
	
--player	
	player={}
	player.x=-16
	player.y=64
	player.h=8
	player.w=16
	player.vh=1
	player.vv=2
	player.skin=0
	player.uff=true
	player.isalive=true
	player.maxhealth=10
	player.health=10
	player.lives=3
	player.shk=0
	player.bshk=0
	player.tshk=0
	player.hhd=0
	player.gshk=0
	player.all=0
	player.ouch=false
	player.immortal=false
	player.timer=0
	
--bullets
	bullets={} --objects
	bul={} --entity
	bul.canshoot=true
	bul.canshoottimermax=0.4
	bul.canshoottimer=bul.canshoottimermax
	bul.damage=15

--rockets
	rockets={}
	roc={}
	roc.unlocked=false
	roc.ammo=0
	roc.ammomax=16
	roc.canshoot=true
	roc.canshoottimermax=4
	roc.canshoottimer=roc.canshoottimermax
	roc.damage=75

	
--sharks
	sharks={}
	shk={}
	shk.createtimermax=30
	shk.createtimer=shk.createtimermax
	shk.tspr=0
	shk.nspr=37
	shk.count=0
--sub-sharks
	bshk={} 
	bshk.unlocked=false
	bshk.count=0
	bshk.tspr=0
	bshk.nspr=39
	
	tshk={}
	tshk.unlocked=false
	tshk.count=0
	tshk.tspr=0
	tshk.nspr=27
	
	gshk={}
	gshk.unlocked=false
	gshk.count=0
	gshk.tspr=0
	gshk.nspr=45
	
--hammerheads
	hammerheads={}
	hhd={}
	hhd.unlocked=false
	hhd.createtimermax=360
	hhd.createtimer=hhd.createtimermax
	hhd.tspr=0
	hhd.nspr=false
	hhd.mspr=false
	hhd.count=0
	
--randomizers
	random={}
	random.x=20
	random.y=flr(rnd(90)+18)
	random.shark=flr(rnd(9)+1)
	random.hhead=rnd()
	random.bg=flr(rnd(10)+70)
	random.drop=1
	
--buildings
	f1={x=0,y=112,w=128}
 f2={x=128,y=112,w=128}
 b1={x=0,y=107,w=128}
 b2={x=128,y=107,w=128}
	
--drops
	drops={}
	dps={}
	dps.unlocked=false
	dps.createtimermax=600
	dps.createtimer=dps.createtimermax
	dps.count=0

--unlockables
	drawtmax=90
	drawt=0
	
--animations
	circles={}
	playertrails={}
	playerexplosions={}
	sharkexplosions={}
	smokes={}
	fins={}
	sharktrails={}
	
	createcircletimermax=14
	createcircletimer=1
	
	createfintimermax=75
	createfintimer=1
	
	createtrailtimermax=3
	createtrailtimer=1
	
	overhclr=1
	highhclr1=7
	highhclr2=7
	
--highscore
	--hs_char={"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
	
end

function ccol(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1<x2+w2 and
		x2<x1+w1 and
		y1<y2+h2 and
		y2<y1+h1
end

function outline(s,x,y,c1,c2)
	for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x+1,y+1,c2)
end

function _game_state()

if st=="menu" then
	_pointer()
	if a<5 then
		a+=0.02
	else
		a=1
	end
elseif st=="skin" then


	if btnp(1)
	and player.skin<3 then
		player.skin+=1
		sfx(17)
	elseif btnp(0)
	and player.skin>0 then
		player.skin-=1
		sfx(17)
	end
	
	if btnp(4) then
		st="game"
		music(-1)
		music(9)
		sfx(18)
	elseif btnp(5) then
		st="menu"
		sfx(18)
	end
elseif st=="ctrl" then

	if btnp(5) then
		sfx(18)
		st="menu"
	end
	
elseif st=="game" then
	_player()
	_bullets()
	_rockets()
	_smoke()
	_sharks()
	_explode()
	_trail()
	_hammerheads()
	_drops()
	_collision()
	
elseif st=="dead" then

	player.x=20
	player.y=64
	player.h=8
	player.w=16
	player.isalive=true
	player.health=player.maxhealth
	st="game"
	

elseif st=="over" then

	if btnp(5) then
		sfx(18)
		_init()
	elseif btnp(2) then
		sfx(18)
		st="high"
	end
	
	if game_score>=dget(0) then
		dset(0,game_score)
	end
	
	if player.all>=dget(1) then
		dset(1,player.all)
	end
	
elseif st=="cred" then
	
	if btnp(5) then
		sfx(18)
		st="menu"
	end	

elseif st=="high" then

	if btnp(5)
	and player.lives>0 then
		sfx(18)
		st="menu"
	elseif btnp(3)
	and player.lives<=0 then
		sfx(18)
		st="over"
	end

end

end

function _pointer()
	
	if btnp(2)
	and pointer.y>1 then
		pointer.y-=1
		sfx(17)
	elseif btnp(3)
	and pointer.y<4 then
		pointer.y+=1
		sfx(17)
	end

	if btnp(4) then
		if pointer.y==1 then
			sfx(18)
			st="skin"
		elseif pointer.y==2 then
			sfx(18)
			st="ctrl"
		elseif pointer.y==3 then
			sfx(18)
			st="cred"
		elseif pointer.y==4 then
			sfx(18)
			st="high"
		end
	end
	
end

function _player()

	if enter.timer>0 then
		enter.timer-=1
		enter.v+=enter.a
		player.x+=enter.v
	end
	
		if player.skin==0 then
		--health
		player.maxhealth=10
		--speed
		player.vh=1
		player.vv=2
		--damage
		bul.damage=15
		roc.damage=75
		--bullet speed
		bul.canshoottimermax=0.4
		roc.canshoottimermax=4
	elseif player.skin==1 then
			--health
		player.maxhealth=14
		--speed
		player.vh=0.5
		player.vv=1
		--damage
		bul.damage=45
		roc.damage=150
		--bullet speed
		bul.canshoottimermax=1.5
		roc.canshoottimermax=15
	elseif player.skin==2 then
			--health
		player.maxhealth=12
		--speed
		player.vh=0.5
		player.vv=0.5
		--damage
		bul.damage=5
		roc.damage=25
		--bullet speed
		bul.canshoottimermax=0.1
		roc.canshoottimermax=1
	elseif player.skin==3 then
			--health
		player.maxhealth=2
		--speed
		player.vh=2
		player.vv=4
		--damage
		bul.damage=10
		roc.damage=50
		--bullet speed
		bul.canshoottimermax=0.2
		roc.canshoottimermax=2
	end
	
	if player.uff then
		player.health=player.maxhealth
		player.uff=false
	end



if enter.timer==0 then



	if btn(0) and player.x>0 then
		player.x-=player.vh
	elseif btn(1) and player.x + player.w<128 then
		player.x+=player.vh
	end
	
	if btn(2) and player.y>20 then
		player.y-=player.vv
	elseif btn(3) and player.y + player.h<128 then
		player.y+=player.vv
	end
	
	if player.health<=0
	and player.lives==0 then
		player.isalive=false
		music(8)
		st="over"
	elseif player.health<=0
	and player.lives>0 then
		player.health=player.maxhealth
		player.lives-=1
		player.ouch=true
		game_score-=100
		sfx(14)
			for n=1,20 do
				newpexplosion={x=player.x+8,y=player.y+4,vx=rnd(4)*cos(rnd(1)),vy=rnd(4)*sin(rnd(1)),r=8,c=1,cv=rnd(0.7)+0.1}
 			add(playerexplosions,newpexplosion)
 		end
		
		st="dead"		
	end
	
	if player.ouch then
		player.timer+=1
	end
	
	if player.timer>60 then
		player.timer=0
		player.ouch=false
	end
			
	player.all=player.shk+player.bshk+player.tshk+player.hhd+player.gshk
	
	if game_score<0 then
		game_score=0
	end

end

end

function _bullets()

if enter.timer==0 then
	
	bul.canshoottimer-=0.1
	
	if bul.canshoottimer<0 then
		bul.canshoot=true
	else
		bul.canshoot=false
	end
	
	if btn(4) and bul.canshoot then 
		newbullet={x=player.x+player.w,y=player.y+3,w=4,h=1,sp=3}
		add(bullets,newbullet)
		bul.canshoottimer=bul.canshoottimermax
	end 
	
	for i, bullet in pairs(bullets) do
		bullet.x=bullet.x + 4
		
		if bullet.x>128 then
			del(bullets,bullets[i])
		end
		
	end
	
end

end

function _rockets()

if enter.timer==0 then

	if roc.ammo>0
	and roc.unlocked==false then
		roc.unlocked=true
	end

if roc.unlocked then

	roc.canshoottimer-=0.5
	
	if roc.canshoottimer<0 then
		roc.canshoot=true
	else
		roc.canshoot=false
	end

	if btn(5)
 and roc.canshoot
 and roc.ammo>0 then
		newrocket={x=player.x+4,y=player.y+2,w=8,h=4,sp=4,vh=0,vv=2}
		add(rockets,newrocket)
		roc.canshoottimer=roc.canshoottimermax
		roc.ammo-=1
	end
	
	for i, rocket in pairs(rockets) do
		rocket.vh+=0.25
		rocket.x+=rocket.vh
		
		if rocket.vv>0 then
			rocket.vv-=0.2
		end
		
		rocket.y+=rocket.vv
		
		if rocket.x>128 then
			del(rockets,rockets[i])
		end
		
	end

end

end

end

function _smoke()

	for i,rocket in pairs(rockets) do
		if rocket.vh>1 then
			newsmoke={x=rocket.x-3,y=rocket.y+1,r=2,vh=0,vv=(rnd(1.5)-0.5),clr=flr(rnd(4.9))}
			add(smokes,newsmoke)
		end
	end
	
	for j, smoke in pairs(smokes) do
		smoke.vh+=0.5
		smoke.y+=smoke.vv
		smoke.x-=smoke.vh
	
		if smoke.vh>2 then
			smoke.r-=0.5
		end
		
		if smoke.r<=0 then
			del(smokes,smokes[j])
		end

	end
		
end

function _sharks()

if st=="game" then
	
	shk.createtimer-=1
	
	if shk.createtimer<0 then
		
		shk.createtimer=shk.createtimermax
		
		random.y=flr(rnd(90)+20)
		
		if gshk.unlocked
		and shk.count%100==0 then
			newgshark={x=132,y=random.y,w=24,h=12,sp=13,health=500,damage=10,v=0.5,group="golden",score=1000}
			add(sharks,newgshark)
			gshk.count+=1
			shk.count+=1
		elseif bshk.unlocked 
		and shk.count%random.shark==0 then
			newbshark={x=132,y=random.y,w=24,h=12,sp=7,health=75,damage=4,v=1,group="boosted",score=20}
			add(sharks,newbshark)
			bshk.count+=1
			shk.count+=1
			random.shark=flr(rnd(9)+1)
		elseif tshk.unlocked
		and shk.count%random.shark>2 then
			newtshark={x=132,y=player.y,w=16,h=8,sp=11,health=30,damage=1,v=4,group="tiny",score=5}
			add(sharks,newtshark)
			tshk.count+=1
			shk.count+=1
			random.shark=flr(rnd(9)+1)
		else
			newshark={x=132,y=random.y,w=24,h=12,sp=5,health=45,damage=2,v=1,group="normal",score=10}
			add(sharks,newshark)
			shk.count+=1
		end
		
	end
	
	for i, shark in pairs(sharks) do
		shark.x-=shark.v
		
		if shark.x<-20 then
			del(sharks,sharks[i])
			if (game_score>0) game_score-=shark.score/5
		end
		
		if shark.health<=0 then
			del(sharks,sharks[i])
			sfx(11)
			if shark.group=="normal" then
				player.shk+=1
			elseif shark.group=="boosted" then
				player.bshk+=1
			elseif shark.group=="tiny" then
				player.tshk+=1
			elseif shark.group=="golden" then
				player.gshk+=1
			end
			game_score+=shark.score
			local clr={2,4,5,8,9,10,12,13}
			for n=1,30 do
				newsexplosion={x=shark.x+8,y=shark.y+4,vx=rnd(3)*cos(rnd(1)),vy=rnd(4)*sin(rnd(1)),r=3,c=clr[flr(rnd(7.9)+1)]}
 			add(sharkexplosions,newsexplosion)
 		end
		end
		
	end
	
end	
	
end

function _explode()

	

	for j,ex in pairs(sharkexplosions) do
	
		ex.x+=ex.vx
		ex.y+=ex.vy
		ex.r-=0.5
		
		if ex.r<0 then
			del(sharkexplosions,sharkexplosions[j])
		end
		
	
	end
	
	for k,ex in pairs(playerexplosions) do
	
		ex.x+=ex.vx
		ex.y+=ex.vy
		ex.r-=0.6
		ex.c+=ex.cv
		
		if ex.r<0 then
			del(playerexplosions,playerexplosions[j])
		end
		
	
	end
	

end

function _trail()

	local sclr={2,7,8,12,13,14}
	local gclr={2,7,10,10,10,12,12}
	local pclr={5,6,8,9}
	
	if createtrailtimer<0 then
		createtrailtimer=createtrailtimermax
	else
		createtrailtimer-=1
	end

	for i,shark in pairs(sharks) do
		if shark.health>0
		and createtrailtimer<0 then
			if shark.group!="golden" then
				newstrail={x=shark.x+8,y=shark.y+6+rnd(3),vx=0.5,vy=rnd(1)-0.5,c=sclr[flr(rnd(5.9)+1)],t=1}
			else
				newstrail={x=shark.x+8,y=shark.y+6+rnd(3),vx=0.5,vy=rnd(1)-0.5,c=gclr[flr(rnd(6.9)+1)],t=1}
			end
			add(sharktrails,newstrail)
		end
	end
	
	if createtrailtimer<1 then
		newptrail={x=player.x+3,y=player.y+5,vx=0.8,vy=rnd(0.4)-0.2,c=7,t=1}
		add(playertrails,newptrail)
	end
	
		for j,ptrail in pairs(playertrails) do
			ptrail.x-=ptrail.vx
			ptrail.y+=ptrail.vy
			ptrail.t-=0.05
			
			if player.skin!=3 then
				
				if player.health<4 then
					ptrail.c=pclr[flr(rnd(3.9)+1)]
				elseif player.health<6 then
					ptrail.c=5
				elseif player.health<7 then
					ptrail.c=6
				else
					ptrail.c=7
				end
				
			end
						
			if ptrail.t<0 then
				del(playertrails,playertrails[j])
			end	
			
	end
	
	for k,strail in pairs(sharktrails) do
		strail.x+=strail.vx
		strail.y+=strail.vy
		strail.t-=0.05
						
		if strail.t<0 then
			del(sharktrails,sharktrails[k])
		end	
			
	end

end

function _hammerheads()

if st=="game" and hhd.unlocked then

	hhd.createtimer-=1
	
	if hhd.createtimer<0 then
		
		hhd.createtimer=hhd.createtimermax
		newhamhead={x=player.x,y=138,w=16,h=32,sp=9,health=150,damage=6,v=2,score=500}
		if hhd.count==0 then
			newhamhead.y=138
			hhd.mspr=false
		elseif random.hhead>0.5 then
			newhamhead.y=138
			hhd.mspr=false
		else
			newhamhead.y=-10
			newhamhead.v=-2
			hhd.mspr=true
		end
		add(hammerheads,newhamhead)
		hhd.count+=1
		random.hhead=rnd()
	end
	
	for i,hammerhead in pairs(hammerheads) do
		hammerhead.y-=hammerhead.v
		
		if hammerhead.y+hammerhead.h<0 then
			del(hammerheads,hammerheads[i])
		end
		
		if hammerhead.health<=0 then
			del(hammerheads,hammerheads[i])
			sfx(11)
			player.hhd+=1
			game_score+=hammerhead.score
		end
		
	end


end
end

function _drops()

if st=="game"
and player.isalive
and dps.unlocked then

	dps.createtimer-=1
	
	if dps.createtimer<0 then
		
		dps.createtimer=dps.createtimermax
		
		newdrop={x=random.x,y=-10,w=7,h=6,v=0.5,tp=random.drop}
		
		add(drops,newdrop)
		dps.count+=1

		random.x=flr(rnd(100)+10)
		random.drop=flr(rnd(2.9))
	
	end
	
	for i, drop in pairs(drops) do
			drop.y+=drop.v
			
			if drop.y>150 then
				dps.count-=1
				del(drops,drops[i])
			end
			
	end

end	

end

function _collision()

	for i, shark in pairs(sharks) do
		
		for j, bullet in pairs(bullets) do
			
			if ccol(shark.x,shark.y,shark.w,shark.h,bullet.x,bullet.y,bullet.w,bullet.h)
			and	player.isalive then
				del(bullets,bullets[j])
				shark.health-=bul.damage
			end
		
		end
		
		for k, rocket in pairs(rockets) do
		
			if ccol(shark.x,shark.y,shark.w,shark.h,rocket.x,rocket.y,rocket.w,rocket.h)
			and player.isalive then
				del(rockets,rockets[k])
				shark.health-=roc.damage								
			end
		
		end
		
		if ccol(shark.x,shark.y,shark.w,shark.h,
			player.x,player.y,player.w,player.h)
		and player.isalive
		and not player.ouch then
			del(sharks,sharks[i])
			player.health-=shark.damage
			sfx(12)
			if (game_score>0) game_score-=shark.score
		end
		
	end
	
	for i,hammerhead in pairs(hammerheads) do
	
		for j, bullet in pairs(bullets) do
			
			if ccol(hammerhead.x,hammerhead.y,hammerhead.w,hammerhead.h,
			bullet.x,bullet.y,bullet.w,bullet.h)
			and player.isalive
			and not player.ouch then
				del(bullets,bullets[j])
				hammerhead.health-=bul.damage
			end
			
		end
		
		for k, rocket in pairs(rockets) do
		
			if ccol(hammerhead.x,hammerhead.y,hammerhead.w,hammerhead.h,
			rocket.x,rocket.y,rocket.w,rocket.h)
			and player.isalive then
				del(rockets,rockets[k])
				hammerhead.health-=roc.damage
			end
		
		end
		
		if ccol(hammerhead.x,hammerhead.y,hammerhead.w,hammerhead.h,
		player.x,player.y,player.w,player.h)
		and player.isalive
		and not player.ouch then
			del(hammerheads,hammerheads[i]) --fix
			sfx(12)
			player.health-=hammerhead.damage
			if (game_score-(hammerhead.score/2)>0) game_score-=hammerhead.score/2
		end
	
	end
	
	for i,drop in pairs(drops) do
	
		if ccol(drop.x,drop.y,drop.w,drop.h,
		player.x,player.y,player.w,player.h) then
			sfx(13)
			del(drops,drops[i])
			dps.count-=1
			if drop.tp==0 and
			player.health<player.maxhealth then
				if player.health<=player.maxhealth-6 then
					player.health+=6
				else
					player.health=player.maxhealth
				end
			elseif drop.tp==1 and
			roc.ammo<roc.ammomax then
				if roc.ammo<=roc.ammomax-10 then
					roc.ammo+=10
				else
					roc.ammo=roc.ammomax
				end
			elseif drop.tp==2 then
				if player.lives<3 then
					player.lives+=1
				else
					player.health=player.maxhealth
				end
			end
			
		end
	
	end

end

function _unlockables()
	
	if player.shk==20 and player.bshk==0 then
		drawt=drawtmax
		dps.unlocked=true
		bshk.unlocked=true
	elseif player.bshk==10 and player.tshk==0 then
		drawt=drawtmax
		shk.createtimermax=20
		tshk.unlocked=true
	elseif player.tshk==10 and player.hhd==0 then
		drawt=drawtmax
		shk.createtimermax=10
		hhd.unlocked=true
	end
	
	if player.all>=80 then
		gshk.unlocked=true
	end

end

function _update()
	_game_state()
	_unlockables()
end

function game_state_draw()

if st=="menu" then
	cls()
	menu_draw()
elseif st=="skin" then
	cls()
	skin_draw()
elseif st=="ctrl" then
	cls()
	ctrl_draw()
elseif st=="game" then
	cls()
	background_draw()
	
	trail_draw()
	smoke_draw()
	explode_draw()
	player_draw()
	bullets_draw()
	rockets_draw()
	sharks_draw()
	hammerheads_draw()
	drops_draw()
	unlockables_draw()
	
	gui()

elseif st=="dead" then
	--cls()
elseif st=="over" then
	cls()
	over_draw()
elseif st=="cred" then
	cls()
	cred_draw()
elseif st=="high" then
	cls()
	high_draw()
end


end

function _title()


	sspr(32,48,11,15,30,30+4*sin(a))
	sspr(44,48,11,15,42,30+4*(sin(a-0.1)))
	sspr(55,48,14,15,50,30+4*(sin(a-0.2)))
	sspr(70,48,4,15,66,30+4*(sin(a-0.3)))
	sspr(75,48,14,15,71,30+4*(sin(a-0.4)))
	sspr(89,48,11,15,85,30+4*(sin(a-0.5)))
	
	sspr(101,48,11,15,28,52+4*(sin(a-0.1)))
	sspr(112,48,11,15,39,52+4*(sin(a-0.2)))
	sspr(0,64,13,15,51,52+4*(sin(a-0.3)))
	sspr(14,64,11,15,63,52+4*(sin(a-0.4)))
	sspr(27,64,11,15,75,52+4*(sin(a-0.5)))
	sspr(101,48,11,15,87,52+4*(sin(a-0.6)))

end

function menu_draw()

	rectfill(0,0,128,128,1)
	
	local pclr=0
	local cclr=0
	local dclr=0
	local hclr=0
	
	if pointer.y==1 then
		pclr=7
		cclr=5
		dclr=5
		hclr=5
	elseif pointer.y==2 then
		pclr=5
		cclr=7
		dclr=5
		hclr=5
	elseif pointer.y==3 then
		pclr=5
		cclr=5
		dclr=7
		hclr=5
	elseif pointer.y==4 then
		pclr=5
		cclr=5
		dclr=5
		hclr=7
	end
		 
	 createcircletimer-=1
	 
	 if createcircletimer<0 then
	 	createcircletimer=createcircletimermax
	 	newcircle={x=64,y=64,r=0,v=2,c=flr(rnd(15.9))}
	 	add(circles,newcircle)
	 end
	 
	 for m,cc in pairs(circles) do
	 	cc.r+=cc.v

	 	
	 	circfill(cc.x,cc.y,cc.r,cc.c)
	 	
	 	if cc.r>150 then
	 		del(circles,circles[m])
	 	end
	 	
	 end
	 
	 _title()
	 	rectfill(36,76,91,117,0)
	
	sspr(0,40,32,24,32,72,64,50)
	
	outline("play",44,80,1,pclr)
	outline("controls",44,89,1,cclr)
	outline("credits",44,98,1,dclr)
	outline("highscores",44,107,1,hclr)

	outline("@flyingsmog's",35,18,6,1)
	--outline("add. art by @gimbernau",20,2,5,1)
	 
		 randomx=flr(rnd())		
	
		createfintimer-=1
		
		if createfintimer<0 then
			 randomx=flr(rnd(1.9))
			if randomx==0 then
				finx=-10
				finv=0.5
			elseif randomx==1 then
				finx=130
				finv=-0.5		
			end
			newfin={x=finx,y=124,v=finv,f=false}
			add(fins,newfin)
			createfintimer=createfintimermax
		end
		
		for i, fin in pairs(fins) do
			
			fin.x+=fin.v
			
			if fin.v<0 then
				fin.f=true
			else
				fin.f=false
			end
			
			spr(5,fin.x,fin.y,1,1,fin.f)
			
			if fin.x<-20
			or fin.x>140
			or st!="menu" then
				del(fins,fins[i])
			end
			
		end
	

end

function skin_draw()
	rectfill(0,0,127,127,1)
	outline("choose your plane:",30,12,13,7)
	spr(1+16*player.skin,56,40,2,1)
	
	if player.skin>0 then
		spr(36,41,41,1,1,true)
	end
	
	if player.skin<3 then
		spr(36,80,41)
	end
	
	local l=0
	local s=0
	local d=0
	local bs=0
	local name="o"
	
	if player.skin==0 then
		l=3
		s=3
		d=3
		bs=3
		name="eagle"
	elseif player.skin==1 then
		l=5
		s=2
		d=4
		bs=1
		name="baron"
	elseif player.skin==2 then
		l=4
		s=1
		d=1
		bs=5
		name="mount"
	elseif player.skin==3 then
		l=1
		s=5
		d=2
		bs=4
		name="flash"
	end
	outline(name,55,28,5,10)
	outline("health",24,59,8,7)
	outline("speed",28,69,9,7)
	outline("damage",24,79,11,7)
	outline("shot speed",8,89,12,7)
	outline("press — to go to menu",19,110,6,1)
	
	for i=1, 5 do
		for j=1, 4 do
			spr(48,i*5+50,60+j*10-10)
		end
	end
	
	for j=1, l do
		rectfill(51+j*5,61,54+j*5,63,11)
	end
		
	for k=1, s do
		rectfill(51+k*5,71,54+k*5,73,11)
	end
	
	for m=1, d do
		rectfill(51+m*5,81,54+m*5,83,11)
	end
	
	for n=1, bs do
		rectfill(51+n*5,91,54+n*5,93,11)
	end
		
end

function ctrl_draw()

	rectfill(0,0,127,127,1)
	outline("controls",48,12,13,7)
	
	outline("arrows to move your plane",16,33,5,7)
	
	outline(" to shoot bullets",24,57,5,7)
	outline("— to shoot rockets",24,83,5,7)
	
	outline("press — to go to menu",19,110,10,1)
end

function over_draw()
	rectfill(0,0,127,127,1)
	outline("game over",46,12,13,10)
	print("you killed:",16,25,5)
	print("you killed:",16,24,7)
	print(player.shk .. " sharks",20,33,5)
	print(player.shk .. " sharks",20,32,7)
	print(player.bshk .. " robo sharks",20,41,5)
	print(player.bshk .. " robo sharks",20,40,7)
	print(player.tshk .. " tiny sharks",20,49,5)
	print(player.tshk .. " tiny sharks",20,48,7)
	print(player.hhd .. " hammerheads",20,57,5)
	print(player.hhd .. " hammerheads",20,56,7)
	if gshk.unlocked
	and gshk.count>0 then
		outline(player.gshk .. " golden sharks",21,65,5,6)
		outline(player.gshk .. " golden sharks",20,64,10,12)
	end
	
	print("killing a total of     sharks!",4,79,5)
	print("killing a total of     sharks!",4,78,7)
	outline(player.all,80,77,12,7)
	print("score:     points",32,93,5)
	print("score:     points",32,92,7)
	outline(game_score,58,91,12,7)
	
	

	if game_score==dget(0)
	or player.all==dget(1) then
	
		if overhclr<15 then
			overhclr+=0.5
		else
			overhclr=1
		end
	
		outline("new highscore!",38,100,0,overhclr)
	
	end
	
	outline("press — to go to menu",19,109,13,10)
	outline("press ” to see the highscores",4,118,13,10)
end

function cred_draw()
	rectfill(0,0,128,128,1)
	outline("credits",48,12,13,7)
	
	outline("code,art and music:",24,24,5,6)
	outline("@flyingsmog",39,36,12,7)
	outline("additional art:",33,48,5,6)
	outline("@gimbernau",41,60,12,7)
	outline("some art based on:",26,72,5,6)
	outline("@morningtoast's 'bustin''",14,84,12,7)
	outline("@benjamin soul ?'s 'hug arena'",4,94,12,7)
	outline("press — to go to menu",19,110,10,1)
end

function high_draw()

	rectfill(0,0,128,128,1)
	outline("highscores",44,12,13,7)
	
	if player.lives>0 then
		outline("press — to go to menu",19,110,10,1)
		highhclr1=7
		highhclr2=7
	elseif player.lives<=0 then
		outline("press ƒ to go back",24,110,10,1)
	
		if game_score==dget(0) then
	
			if highhclr1<15 then
				highhclr1+=0.5
			else
				highhclr1=1
			end
			
		elseif player.all==dget(1) then
	
			if highhclr2<15 then
				highhclr2+=0.5
			else
				highhclr2=1
			end
		end
	
	end
	
	outline("most points:",40,34,5,7)
	outline(dget(0),54,46,12,highhclr1)
	outline("most sharks:",40,64,5,7)
	outline(dget(1),56,76,12,highhclr2)

	
end

function gui()

	line(0,17,127,17,6)
	rectfill(0,0,127,15,1)
	
--lives
		spr(2+16*player.skin,0,1)
		outline(player.lives,11,1,13,7)

--health
	for i=1, player.maxhealth do
		spr(16,i*4-3,10)
	end
	
	for i=1, player.health do
		local hclr=0
		local wrec=2
		if i<=2 then	hclr=8
		elseif i<=4 then	hclr=9
		elseif i<=6 then	hclr=10
		elseif i<=player.maxhealth then	hclr=11
		end
		
		if i==player.maxhealth then
			wrec=2
		else
			wrec=3
		end
		
		rectfill(2+i*4-4,11,3+i*4-wrec,13,hclr)
	end

--score
	outline("score:"..game_score,47,2,13,7)

--ammo
	if roc.unlocked then
		spr(32,28,1)
		outline(roc.ammo,34,1,13,7)
	end
	
--shark count
	
	spr(6,89,-2)
	
	if player.shk<100 then
		outline(player.shk,99,1,13,7)
	else
		outline("!",99,1,13,7)
	end
	
	if tshk.unlocked then
		spr(11,89,7)
		
		if player.tshk<100 then
			outline(player.tshk,99,9,13,7)
		else
			outline("!",99,9,13,7)
		end
		
	end
	
	if bshk.unlocked then
		spr(8,109,-2)
		
		if player.bshk<100 then
			outline(player.bshk,119,1,13,7)
		else
			outline("!",119,1,13,7)
		end
		
	end
	
	if hhd.unlocked then
		spr(9,109,7)
		
		if player.hhd<100 then
			outline(player.hhd,119,9,13,7)
		else
			outline("!",119,9,13,7)
		end
		
	end


end

function background_draw()

	rectfill(0,0,127,127,1)
	sspr(40,64,35,32,0,18)
	
	
	if st=="game" then
		f1.x-=0.4
		f2.x-=0.4
		b1.x-=0.2
		b2.x-=0.2
	end
	
	if f1.x+f1.w<0 then
		f1.x=f2.x+f2.w
	elseif f2.x+f2.w<0 then
		f2.x=f1.x+f1.w
	elseif b1.x+b1.w<0 then
		b1.x=b2.x+b2.w
	elseif b2.x+b2.w<0 then
		b2.x=b1.x+b1.w
	end
	
	spr(192,b1.x,b1.y,16,2)
	spr(192,b2.x,b2.y,16,2)
	
	spr(224,f1.x,f1.y,16,2)
	spr(224,f2.x,f2.y,16,2)
	
end

function player_draw()

	if	player.isalive
	and player.timer%6==0 then
		spr(1+16*player.skin,player.x,player.y,2,1)
		--sfx(0)
	end	
	
end

function bullets_draw()

	for i, bullet in pairs(bullets) do
		spr(bullet.sp,bullet.x,bullet.y)
	end
	
	if btn(4)
 and bul.canshoot
 and enter.timer==0 then
		sfx(9)
	end

end

function rockets_draw()

	
	for i, rocket in pairs(rockets) do
		spr(rocket.sp,rocket.x,rocket.y)		
	end
	
	if btn(5)
 and roc.canshoot
 and roc.ammo>0 then
		sfx(10)
	end
	
end

function smoke_draw()
	
	for i,smoke in pairs(smokes) do
		circfill(smoke.x,smoke.y,smoke.r,6+smoke.clr)
	end
	
	
end

function sharks_draw()

	shk.tspr+=1
	if shk.tspr==7 then
		shk.nspr=38
	elseif shk.tspr==14 then
		shk.tspr=0
		shk.tspr+=1
		shk.nspr=37
	end
	
	if bshk.unlocked then
			bshk.tspr+=1
		if bshk.tspr==5 then
			bshk.nspr=40
		elseif bshk.tspr==10 then
			bshk.tspr=0
			bshk.tspr+=1
			bshk.nspr=39
	 end
	end
	
	if tshk.unlocked then
		tshk.tspr+=1
		if	tshk.tspr==3 then
			tshk.nspr=28
		elseif tshk.tspr==6 then
			tshk.tspr=0
			tshk.tspr+=1
			tshk.nspr=27
		end
			
	end
	
	if gshk.unlocked then
		gshk.tspr+=1
		if gshk.tspr==4 then
			gshk.nspr=46
		elseif gshk.tspr==8 then
			gshk.tspr=0
			gshk.tspr+=1
			gshk.nspr=45
		end
	end
	
	for i,shark in pairs(sharks) do
		
		
		if tshk.unlocked
		and shark.group=="tiny" then
			spr(shark.sp,shark.x,shark.y,2,1,true)
		else
			spr(shark.sp,shark.x,shark.y,2,2,true)
		end
		
		if bshk.unlocked
		and shark.group=="boosted" then
			spr(bshk.nspr,shark.x+16,shark.y+4,1,1,true)
		elseif tshk.unlocked
		and shark.group=="tiny" then
			spr(tshk.nspr,shark.x+16,shark.y,1,1,true)
		elseif gshk.unlocked
		and shark.group=="golden" then
			spr(gshk.nspr,shark.x+16,shark.y+4,1,1,true)
		else
			spr(shk.nspr,shark.x+16,shark.y+4,1,1,true)
		end

		
	end
	
end

function explode_draw()

	for i,ex in pairs(sharkexplosions) do
		circfill(ex.x,ex.y,ex.r,ex.c)
	end
	
	local clr={7,7,10,9,8,6,5}
	
	for j,ex in pairs(playerexplosions) do
		circfill(ex.x,ex.y,ex.r,clr[flr(ex.c)])
	end

end

function trail_draw()
	
	for i,ptrail in pairs(playertrails) do
		circ(ptrail.x,ptrail.y,0,ptrail.c)
	end
	
	for j,strail in pairs(sharktrails) do
		circ(strail.x,strail.y,0,strail.c)
	end
	
end

function hammerheads_draw()

	hhd.tspr+=1
	local t=true
	local y=0
	
	
	if hhd.createtimer<=45 then	
		if hhd.createtimer>30 then
			t=true
		elseif hhd.createtimer>15 then
			t=false
		else
			t=true
		end
		
		if random.hhead>0.5 or hhd.count==0 then
			y=110
		elseif random.hhead<0.5 and hhd.count!=0 then
			y=18
		end
		
		if t==true then
			spr(43,player.x,y,2,2)
		end	
	end
	
	if hhd.tspr==7 then
		hhd.nspr=true
	elseif hhd.tspr==14 then
		hhd.nspr=false
		hhd.tspr=0
		hhd.tspr+=1
	end
	
	for i, hammerhead in pairs(hammerheads) do
		spr(hammerhead.sp,hammerhead.x,hammerhead.y,2,4,hhd.nspr,hhd.mspr)
	end

end

function drops_draw()

	for i,drop in pairs(drops) do
		
		spr(20,drop.x,drop.y-12)
		line(drop.x,drop.y-7,drop.x+3,drop.y,5)
		line(drop.x+3,drop.y-7,drop.x+3,drop.y,5)
		line(drop.x+drop.w-1,drop.y-7,drop.x+3,drop.y,5)
		spr(19+16*drop.tp,drop.x,drop.y)
	
	end
	
end

function unlockables_draw()

if drawt>0 then
	drawt-=1
	if hhd.unlocked==true then
	 outline("hammerheads are coming!",20,24,8,7)
	elseif tshk.unlocked==true then
		outline("tiny sharks are coming!",20,24,12,7)
	elseif bshk.unlocked==true then
		outline("robo sharks are coming!",20,24,9,7)
	end
end

end

function _draw()

	game_state_draw()
	
	--print("new highscore!",38,100,7)
	--print(dget(1),0,0,7)
	--print(gshk.tspr,64,50,7)
	--print(shk.count,64,40,7)
	if debug==true then
		print(drawt,80,0,7)
		print(bshk.unlocked,80,10,7)		
	end
	
end
__gfx__
000000000880000566000000499a00005078888006600000000000000660000000000000066666677666666060000000000000000aa000000000000000000000
0000000002880055cc7000050000000057788888006600000000000000660000000000005566667777666655660000000000000000aa00000000000000000000
0070070002888867777877750000000057788882006660000000000000666000000000002856677777766582666556660000000000aaa0000000000000000000
0007700000288888888886780000000050622220006666000000000000666600000000007766677557766677666285600000000000aaaa000000000000000000
00077000000228888288266500000000000000006666666666666666666666655555555566667755557766666666660000000000aaaaaaaaaaaaaaaa00000000
00700700000002282882660500000000000000006666666655666660666666656655555006677755557776606777700000000000aaaaaaaa55aaaaa000000000
00000000000000028820000000000000000000006666666628566700666666652865570000000757757000000660000000000000aaaaaaaa285aa70000000000
00000000000000022200000000000000000000006666666666667000666666665555700000000777777000006600000000000000aaaaaaaaaaaa700000000000
055550000cc0000566000000055555000555550076667777766700007666777777770000000000777700000060000006000000069aaa99999aa7000000000000
5dddd5000dcc0055cc700005538383505ff5ff506667777777700000666777777770000000000077770000006600000060000000aaa999999970000000000000
5dddd5000dcccc67777c7775588888505f5f5f506606600777770000660660077776000000000077770000000660666666000666aa0aa0099997000000000000
5dddd50000dcccccccccc67c5388835055fff5506066000007777000606600000777600000000777777000000666666606606666a0aa00000999700000000000
05555000000ddccccdccd66553383350555555500000000000000000000000000000000000000677776000000777766607777666000000000000000000000000
0000000000000ddcdccd660555555550500500500000000000000000000000000000000000006777777600007700776607700766000000000000000000000000
000000000000000dccd0000000000000000000000000000000000000000000000000000000067777777760007000006677000066000000000000000000000000
000000000000000ddd00000000000000000000000000000000000000000000000000000000677777777776000000066070000660000000000000000000000000
088000000bb000056600000005555500c000000000000006600000060000000680000006067776777767776000000005500000000000000ac000000a00000000
8882000003bb0055cc70000553333350cc0000006000066666006666800005662200556667777677776777760000000550000000c0000aaaaa00aaaa00000000
8882000003bbbb67777b777553788350ccc000006606666666666666220555665555556666666677777666660000005aa5000000aa0aaaaaaaaaaaaa00000000
88820000003bbbbbbbbbb67b53788350cc0000006666666606666666555556660555566600006667770000000000005aa5000000aaaaaaaa0aaaaaaa00000000
8882000000033bbbb3bb366553333350c0000000067777776770077705777777577007770006666777000000000005aaaa5000000a999999a990099900000000
077000000000033b3bb366055555555000000000677000777700007757700077770000770066666777000000000005a99a500000a99000999900009900000000
5555000000000003bb300000000000000000000077000006700000067700000670000006006000677700000000005aa99aa500009900000a9000000a00000000
000000000000000333000000000000000000000070000066000000667000006600000066000000677700000000005aa99aa50000900000aa000000aa00000000
055550000aa000056600000005555500077700000777770000000000000000000000000060000067770000000005aaa99aaa5000000000000000000000000000
5dddd50009aa0055cc70000553333350777770007770777000000000000000000000000060000067770000000005aaa99aaa5000000000000000000000000000
5dddd50009aaaa67777a7775583c335070077000770007700000000000000000000000006600006770000000005aaaa99aaaa500000000000000000000000000
5dddd500009aaaaaaaaaa67a5888875070007000770007700000000000000000000000006660066770000000005aaaaaaaaaa500000000000000000000000000
0555500000099aaaa9aa9665533833507007700007777700000000000000000000000000066666770000000005aaaaa99aaaaa50000000000000000000000000
000000000000099a9aa96605555555507777700000000000000000000000000000000000077777700000000005aaaaa99aaaaa50000000000000000000000000
0000000000000009aa90000000000000077700000000000000000000000000000000000077000000000000005aaaaaaaaaaaaaa5000000000000000000000000
00000000000000099900000000000000000000000000000000000000000000000000000070000000000000005555555555555555000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000dddddddd00000000000000000ddd00000000dddd0000000000000000
000000000000000000000000000000000000000000000000dddddddd0000000000000000dddddddd0000000000000000ddddd0000000d9d90000000000000000
000000000000000000000000000000000000000000000000d9dddddd0000000000000000d9dddd9d0000000000000000d9d9ddddddddd4d40000000000000000
000000000000000000000000000000000000000000000000d4dddddd0000000000000000d4dddd4ddddddddd000dd000d4d4d9d99d9ddddd0000000000000000
000000000000000000000000000000000000000000000000ddddd9d9dddddddd00000000ddddddddd9d9dddd00dddd00ddddd4d44d4dd9d90000000000000000
000000000000000000000000000000000000000000000000ddddd4d4d9dddd9d00000000d9dddd9dd4d4dddd0dddddd0d9d9ddddddddd4d40000000000000000
000000000000000000000000000000000000000000000000ddddddddd4dddd4dddddddddd4dddd4dddddddddddddddddd4d4dddddddddddd0000000000000000
000888888888888888888888888880000000000000000000dddddddddddddddddddddddddddddddddddddddddd9dd9dddddddddddddddddd0000000000000000
008777777777777777777777777778000000000000000000ddddddddd9ddddddd9dddddddddddddddddddddddd4dd4dddddddddddddddddd0000000000000000
087700000000000000000000000077800000000000000000ddddddddd4ddddddd4dd9d9ddddddddddddddddddddddddddddddddddddddddddddddddd000dd000
877000000000000000000000000007780000000000000000dddddddddddddddddddd4d4dddddddddddddddddddddd9ddddddddddddddddddd9dddd9d00dddd00
870000000000000000000000000000780000000000000000ddddddddddddddddddddddddddddddddddddddddddddd4ddddddddddddddddddd4dddd4d0dddddd0
870000000000000000000000000000780000000000000000ddddddddddddddddd9d9dddddddddddddddddddddddddddddddddddddddddddddddddddddd9dd9dd
870000000000000000000000000000780000000000000000ddddddddddddddddd4d4ddddddddddddddddddddddddddddddddddddddddddddddd9d9dddd4dd4dd
870000000000000000000000000000780000000000000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd4d4dddddddddd
870000000000000000000000000000780d7777777600d7000000000777000000077700076000d70000000660000dd77777000000dd7700000dd0000066000000
87000000000000000000000000000078d77777776620d770000000077770000077762077620d77700000776200d77777776000777777760077d2000776200000
87000000000000000000000000000078d77777776220d77200000000d7770007776220d6220d7777000077720d77722266620777222766207772000777200000
87000000000000000000000000000078d777222222007772000000000d77707776220002200d7777700077720d77220002220777200022207772000777200000
8700000000000000000000000000007877722200000077720000000000d7777762200007700d7777770077720d72200000000077200000007772000777200000
870000000000000000000000000000787772200000007772000000000007777622000077720d772777d0d7720772000000000077770000007777777777200000
870000000000000000000000000000787777777760007772000000000000777220000077720d7722777dd7720772000000000007777700007777777777200000
870000000000000000000000000000787777777662007772000000000000777200000077720777202777777207720d7777000000077770007777777777200000
870000000000000000000000000000787777776622007772000000000000777200000077d207772002777762077200d77770000000077700777222277d200000
870000000000000000000000000000787776222220007772000000000000777200000077d207772000277762077200022762000000007d207772000776200000
870000000000000000000000000000787762200000007772000000000000d76200000077620776200002776207720000276207d000007d207772000776200000
87000000000000000000000000000078d762000000007777000000000000d762000000776207762000007762077700007762077d0007762077620007d6200000
87700000000000000000000000000778d762000000007777777760000000d6620000007662076620000076620077777776620077777762207662000d66200000
08770000000000000000000000007780662200000000d7777776620000006622000000d622076220000066220007777776220002777622007622000662200000
008777777777777777777777777778000220000000000dd777662200000002200000000220002200000002200000222222200000222220000220000022000000
00088888888888888888888888888000000000000000002222222000000000000000000000000000000000000000000000000000000000000000000000000000
0ddd7777770000077777772000007700007662007dd7777777dddd777777722d2222202000000000000000000000000000000000000000000000000000000000
77777777776000777777777d2007772007762200dd77777777dddd7777777022d2dd222d00000000000000000000000000000000000000000000000000000000
77777777776200777222277d2007772077622000777777777777d7777777d722d22dd20d00000000000000000000000000000000000000000000000000000000
777722227762007722000076200777277622000077777dd7777777777777dd222222d22000000000000000000000000000000000000000000000000000000000
777220007762007720000076200777776220000077ddddd777777777dd7dd772220dd22202000000000000000000000000000000000000000000000000000000
777200006772007720000076200777772200000077dddd777777777dddd77772220dd2220d000000000000000000000000000000000000000000000000000000
777777667772007770000776200777722000000077ddd7777777777dddd7777222d222200d000000000000000000000000000000000000000000000000000000
777777777772007777777762000d777700000000dddd777777777dddd77777722d22222000000000000000000000000000000000000000000000000000000000
777777777772007777777722000d777770000000ddddd777777ddddddd777772dd22220000000000000000000000000000000000000000000000000000000000
777222227772007772077720000d772777000000ddddd77ddddddddddd77772dd222220000000000000000000000000000000000000000000000000000000000
77720000777200d772007772200d772077700000dddddddddd7777dddd77222d2222200002000000000000000000000000000000000000000000000000000000
7d620000777720d772000777620d77207776000022dddddddd777dddd22222222222d00002000000000000000000000000000000000000000000000000000000
d6220000777620d762000776620d76202d776000722222ddd777dddd72222022222d200020000000000000000000000000000000000000000000000000000000
02200000666620d622000066220d622002d662002777dd22227722222222dd2222dd000000000000000000000000000000000000000000000000000000000000
00000000022220022000000200002200000222002222222227772222222222222220000d00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007222222227222dd222222222220000d200000000000000000000000000000000000000000000000000000000
00cccccccccccc0000000000000000000000000077772222222dddd220dd22222200dd2000000000000000000000000000000000000000000000000000000000
0c000000000000c000000000000000000000000027777dddd22222222dd222222000d22000000000000000000000000000000000000000000000000000000000
c00000000000000c00000000000000000000000020d72222222222222222222000dd200000000000000000000000000000000000000000000000000000000000
c00000000000000c0000000000000000000000002d0022222220002222200000ddd2000000000000000000000000000000000000000000000000000000000000
c00000000000000c0000000000000000000000002dd00222002222222000ddddd220000000000000000000000000000000000000000000000000000000000000
c00000000000000c00000000000000000000000022dddddd2d22220000dddd222200000000000000000000000000000000000000000000000000000000000000
c00000000000000c00000000000000000000000022222dd22222dd07ddd222222200000000000000000000000000000000000000000000000000000000000000
c00000000000000c00000000000000000000000022222222222222ddd22222200000000000000000000000000000000000000000000000000000000000000000
c00000000000000c0000000000000000000000002222200000002222222220000000000000000000000000000000000000000000000000000000000000000000
c00000000000000c000000000000000000000000200220ddddd22222222200000000000000000000000000000000000000000000000000000000000000000000
c00000000000000c00000000000000000000000000000dd222222222000000000000000000000000000000000000000000000000000000000000000000000000
0c000000000000c000000000000000000000000000dddd2222000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000050000000000000000000000000000000
00000000000000000000000055555555000000000000000005550000000055550000000000000000000000050000000055000000000000000000000000000000
55555555000000000000000055555555000000000000000055555000000059590000000000000000000000550000000055500000000000000000000000000000
59555555000000000000000059555595000000000000000059595555555554540000000000000000000005550000000555900000000050000000000050000000
54555555000000000000000054555545555555550005500054545959959555550000000000000000000055550000005555400000000555000000000055000000
55555959555555550000000055555555595955550055550055555454454559590000000000000000000555550000055555505500005555500000000055500000
55555454595555950000000059555595545455550555555059595555555554540000000000000000005555555555555955555550055555550000000055550000
55555555545555455555555554555545555555555555555554545555555555555555555500055000055955955559555455555555555955950000000059555000
55555555555555555555555555555555555555555595595555555555555555555955559500555500555455455554555555955995555455450000000054555500
55555555595555555955555555555555555555555545545555555555555555555455554505555550595555555555555555455445555555550050005055555550
55555555545555555455959555555555555555555555555555555555555555555555555555955955545595555555555555555555555555950555055559555555
55555555555555555555454555555555555555555555595555555555555555555559595555455455555545555555555555555555555555455555555554555955
55555555555555555555555555555555555555555555545555555555555555555554545555555555555555955599555555559955555555555995555555555455
55555555555555555959555555555555555555555555555555555555555555555555555555555555555555455544555555554455555555555445555955555555
55555555555555555454555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555455555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000
00000000000000000000000d00000000dd000000000000000000000000000000000000000000000000000000dddddddd00000000000000000ddd00000000dddd
0000000000000000000000dd00000000ddd00000000000000000000000000000dddddddd0000000000000000dddddddd0000000000000000ddddd0000000d9d9
000000000000000000000ddd0000000ddd9000000000d00000000000d0000000d9dddddd0000000000000000d9dddd9d0000000000000000d9d9ddddddddd4d4
00000000000000000000dddd000000dddd400000000ddd0000000000dd000000d4dddddd0000000000000000d4dddd4ddddddddd000dd000d4d4d9d99d9ddddd
0000000000000000000ddddd00000dddddd0dd0000ddddd000000000ddd00000ddddd9d9dddddddd00000000ddddddddd9d9dddd00dddd00ddddd4d44d4dd9d9
000000000000000000ddddddddddddd9ddddddd00ddddddd00000000dddd0000ddddd4d4d9dddd9d00000000d9dddd9dd4d4dddd0dddddd0d9d9ddddddddd4d4
dddddddd000dd0000dd9dd9dddd9ddd4ddddddddddd9dd9d00000000d9ddd000ddddddddd4dddd4dddddddddd4dddd4dddddddddddddddddd4d4dddddddddddd
d9dddd9d00dddd00ddd4dd4dddd4dddddd9dd99dddd4dd4d00000000d4dddd00dddddddddddddddddddddddddddddddddddddddddd9dd9dddddddddddddddddd
d4dddd4d0dddddd0d9dddddddddddddddd4dd44ddddddddd00d000d0ddddddd0ddddddddd9ddddddd9dddddddddddddddddddddddd4dd4dddddddddddddddddd
dddddddddd9dd9ddd4dd9ddddddddddddddddddddddddd9d0ddd0dddd9ddddddddddddddd4ddddddd4dd9d9ddddddddddddddddddddddddddddddddddddddddd
ddd9d9dddd4dd4dddddd4ddddddddddddddddddddddddd4dddddddddd4ddd9dddddddddddddddddddddd4d4dddddddddddddddddddddd9dddddddddddddddddd
ddd4d4dddddddddddddddd9ddd99dddddddd99ddddddddddd99dddddddddd4ddddddddddddddddddddddddddddddddddddddddddddddd4dddddddddddddddddd
dddddddddddddddddddddd4ddd44dddddddd44ddddddddddd44dddd9ddddddddddddddddddddddddd9d9dddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddd4ddddddddddddddddddddddddd4d4dddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
808182838485868788898a8b8c8d8e8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
909192939495969798999a9b9c9d9e9f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7a8a9aaabacadaeaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b8b9babbbcbdbebf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0c1c2c3c4c5c6c7c8c9cacbcccdcecf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0d1d2d3d4d5d6d7d8d9dadbdcdddedf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0e1e2e3e4e5e6e7e8e9eaebecedeeef00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010800021561515615006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
010e00040b4420b445174421744500402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402004020040200402
010e000000200002000020000200002000020000200002000020000200002000020000200002001f2001f2002b2412b2452c2412c2452c2412c2452b2412b2452c2412c2452b2412b2452c2412c2412c2002c200
010e00003b2413b2413b2413b241232412324123241232413b2413b2413b2413b2412324123241232412324123200232002320023200232002320023200232002320000000000000000000000000000000000000
010e00081764523605246050060517645006052460500605236050060500605006052360500605006050060523605006050060500605006050060500605006050060500605006050060500605006050060500605
010e00081764524645246452464517645246452464524645000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e00003b2413b2413b2413b2413b2413b2413b2413b2413b2413b2413b2413b2413b2413b2412f2412f240236003b2003b2003b2003b2002f2002f2002f2002f2002f2002f2002f2002f2002f2002f2002f200
010e00000b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2410b2400b2000b2000b2000b200
012a00002364123641176411764117645176051760017600176001760017600176001760017600176001760000600006000060000600006000060000600006000060000600006000060000600006000060000600
010a00002f1232c103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103
012000000963409633006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604
011e00001a16300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
011400000933330307003070030700307003070030700307003070030700307003070030700307003070030700307003070030700307003070030700307003070030700307003070030700307003070030700307
010600001c7451f745247450070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
013400000b65300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
010e00040b4120b415174121741500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010e000000200002000020000200002000020000200002000020000200002000020000200002001f2001f2002b2112b2152c2112c2152c2112c2152b2112b2152c2112c2152b2112b2152c2112c2112c2002c200
010c00001805224002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
010c00001c05224002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
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
00 01 02 43 44
00 01 02 04 44
00 01 02 05 44
00 01 02 05 44
00 01 02 03 05
00 01 02 03 05
00 01 02 03 05
00 01 02 03 05
04 06 07 08 44
03 0f 10 43 44
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
