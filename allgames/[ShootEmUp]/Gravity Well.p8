pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- gravity well
--	by randomph
introc=0
introt=0
gemcharge=0
regenspeed=0.2
gamemode=0
speedmult=1
speedupc=0
p={}
pshadow={}
m={}
hpshadow=0
regenshadow=0
t=0
ammo=0
maxammo=0
level=0
kills=0
score=0
prevcredits=0
creditc=0
regen=0
absorbc=0
scrshkc=0
gameoverc=0
credits=0
weapontype=0
xxxx=0
enemies={}
bullets={}
lasers={}
explode={}
obstacles={}
gravwells={}
gems={}
entershop=false

mangle=0
tangle=0
weapondamage=1
stars={}

shopitem={}
shopitem[1]={name="1x‡",cost=20,sp=63}
shopitem[2]={name="3x‡",cost=50,sp=63}
shopitem[3]={name="tri",cost=60,sp=48}
shopitem[4]={name="ammo+1",cost=80,sp=54}
shopitem[5]={name="wave",cost=150,sp=50}
shopitem[6]={name="quad",cost=200,sp=52}
shopitem[7]={name="5-shot",cost=250,sp=49}
shopitem[8]={name="laser",cost=300,sp=51}
shopitem[9]={name="maxhp+3",cost=500,sp=55}
shopitem[10]={name="dmgx2",cost=1000,sp=53}

mirr={}
mirr[1]={x=0,y=5}--0
mirr[2]={x=1,y=5}
mirr[3]={x=2,y=5}
mirr[4]={x=3,y=4}
mirr[5]={x=4,y=3}
mirr[6]={x=5,y=2}
mirr[7]={x=5,y=1}
mirr[8]={x=5,y=0}--90


shopcount=10
shopselect={}
msgc=0
msgmax=0
msgtxt=""
gemc=0
gemhigh = false

function sstep(a,b,i)
	local v=i*i*(3-2*i)
	return a+(b-a)*v
end
function lerp(a,b,i)
	return a+(b-a)*i
end
function msg(str)
	msgtxt=str
	msgc=180
	msgmax=180
end

function clamp(x,a,b)
	return min(max(x,a),b)
end
function damage(dmg,e)
 e.hp-=dmg
	if e.hp>0 then
		spawn_explode(e.x,e.y,5)
		return false
	else
		spawn_explode(e.x,e.y,10)
		return true
	end						
end

function _init()
	intro_init()
end

function intro_init()
	introc=0
	introt=0
	gamemode=0
	stars={}
	for i=1,60 do
		add(stars,{x=rnd(128),y=rnd(256)-256,dy=rnd(2)+0.1})
	end
end
function intro_update()

	foreach(stars,function(s)
		s.y+=s.dy*speedmult
		if s.y>256 then 
			s.y-=256 
			s.x=rnd(128)
		end
	end)
	if gamemode==0 then
		if	introc>0 then
			introc-=1
			introt=sstep(0,128,introc/30)
		end
		if btnp(4,0) then 
			gamemode=3 
			speedmult=8
		end
		if btnp(5,0) then game_init() end
	elseif gamemode==3 then
		if introc<30 then
			introc+=1
			introt=sstep(0,128,introc/30)
		end
		if btnp(4,0) then	
			gamemode=0
			speedmult=1 
		end
		if btnp(5,0) then	game_init() end
	end
end
function intro_draw()
	cls()
	foreach(stars,function(s)
		line(s.x,s.y,s.x,s.y-s.dy*speedmult,5)
	end)

	pal(7,8)
	map(0,0,30+rnd()*2,48+rnd()*2+introt,8,2)
	pal()
	map(0,0,30,48+introt,8,2)
	
	print("press x to start",24,80+introt,7)
	print("press z for help",24,88+introt,7)
	print("a game by randomph",24,96+introt,7)
	print("for the gmtk game jam",24,104+introt,7)

	print("use arrow keys ”ƒ‹‘ to move",0,-128+20+introt,7)
	print("mirror field ”ƒ deflects shots",0,-128+28+introt,7)
	print("press z to shoot - uses ammo",0,-128+36+introt,7)
	print("absorb bullet to restock ammo",0,-128+44+introt,7)
	print("your health regens over time",0,-128+52+introt,7)
	print("destroy enemies for credits",0,-128+60+introt,7)
	print("travel gravity well for upgrades",0,-128+68+introt,7)

	print("press x to start",0,-128+92+introt,7)
	print("press z to go back to main menu",0,-128+100+introt,7)

end

function _update60()
	if gamemode==0 or gamemode==3 then
		intro_update()
	elseif gamemode==1 or gamemode==2 then
		game_update()
	end
end

function _draw()
	if gamemode==0 or gamemode==3 then
		intro_draw()
	elseif gamemode==1 or gamemode==2 then
		game_draw()
	end
end

function game_init()
	gemc=0
	gemhigh = false
	
	weapondamage=1
	weapon_type=1
	mangle=0
	tangle=90
	stars={}
	enemies={}
	bullets={}
	lasers={}
	explode={}
	obstacles={}
	gravwells={}
	gems={}
	pshadow={}

	score=0
	credits=0
	kills=0
	level=1
	msg("level "..level)

	t=0
	palt(1,true)
	palt(0,false)
	absorbc=0
	scrshkc=0
	gameoverc=0
	p={x=64,y=96,dx=0,dy=0,
			hit={x=-2,y=-2,w=4,h=4},
			alive=true,hp=4,maxhp=4}
	for i=1,8 do
		add(pshadow,{x=64,y=64,c=0})
	end
	for i=1,60 do
		add(stars,{x=rnd(128),y=rnd(256)-256,dy=rnd(2)+0.1})
	end
	
	m={x=0,y=-1} --direction
	ammo=5
	maxammo=5
	
	gamemode=1
	speedmult=20
end

function shop()
	shopselect={}
	for i=0,2 do
		obj={x=i*32+32,y=-20,
			hit={x=-4,y=-4,w=8,h=8},
			id=flr(rnd(shopcount)+1),
			selected=false
			}
		add(shopselect,obj)
	end
	if level%10==0 then
		shopselect[flr(rnd(3))+1].id=1
	else
		shopselect[flr(rnd(3))+1].id=level
	end	
end
function nextlevel()
	gemc=0
	gemhigh = false

	speedupc-=250
	level+=1
	msg("level "..level)
end

function game_update()
	if mangle<tangle then mangle+=1 end
	if tangle<90 then tangle+=0 end
	
	if gamemode==2 then
		speedupc-=1
		if speedupc>=460 then
			speedmult+=1
		elseif speedupc==459 then
			if entershop then
				shop()
			else
				nextlevel()
			end
		elseif speedupc==0 then
			speedmult=1
			gamemode=1
		elseif speedupc<20 then
			speedmult-=1
		end
			
		for s in all(shopselect) do
			if s.y>48 and s.y<80 then
				s.y=s.y+0.1
			else
				s.y=s.y+1
			end
			if collision(s,p) and not s.selected then
				if credits<shopitem[s.id].cost then
					msg("insufficient credits")
					sfx(8)
					s.selected=true
				else
					credits-=shopitem[s.id].cost
					--apply shop effect
					
					--				weapontype 1=tri,2=wave,3=quad,4=shot,5laser
					local sptxt=""
					if s.id==1 then
						if p.hp==p.maxhp then
							p.maxhp+=1
							p.hp+=1				
							sptxt=" maxhp+1 bonus"		
						else
							p.hp=min(p.hp+1,p.maxhp)
							if p.hp==p.maxhp then regen=0 end
						end
					elseif s.id==2 then
						if p.hp==p.maxhp then
							p.maxhp+=1
							p.hp+=1						
							sptxt=" maxhp+1 bonus"		
						else
							p.hp=min(p.hp+3,p.maxhp)
							if p.hp==p.maxhp then regen=0 end
						end
					elseif s.id==3 then
						weapontype=1
					elseif s.id==4 then
						maxammo+=1					
					elseif s.id==5 then
						weapontype=2
					elseif s.id==6 then
						weapontype=3
					elseif s.id==7 then
						weapontype=4
					elseif s.id==8 then
						weapontype=5
					elseif s.id==9 then
						p.maxhp+=3
					elseif s.id==10 then
						weapondamage*=2
					end
					if p.hp>=p.maxhp then regen=0 end
					sfx(2)
					msg("acquired "..shopitem[s.id].name..sptxt)
					del(shopselect,s)
				end		
			end
		end
	end
	if t%4==0 then
		hpshadow=p.hp
		regenshadow=regen
	end
	
	
	
	--game spawner
	if t<2200 and p.alive then
	
		
	
	if t%360==0 and speedmult==1 then
		if level==1 then
			spawn_enemy(flr(rnd(120))+4,-20,0)
		elseif level==2 then
			spawn_enemy(flr(rnd(120))+4,-20,flr(rnd(2)))		
		elseif level==3 then
			local loc = flr(rnd(100))+4
			local rand=flr(rnd(2))
			spawn_enemy(loc,-20,rand)		
			spawn_enemy(loc+20,-20,rand)		
		elseif level==4 then
			local xt=(t/360)%2
			if xt==1 then
				spawn_enemy(flr(rnd(120))+4,-20,2)				
			else
				local loc = flr(rnd(100))+4
				local rand=flr(rnd(2))
				spawn_enemy(loc,-20,rand)		
				spawn_enemy(loc+20,-20,rand)		
			end		
		elseif level==5 then
			local xt=(t/360)%2
			if xt==1 then
				spawn_enemy(flr(rnd(120))+4,-20,3)				
			else
				spawn_enemy(flr(rnd(120))+4,-20,1)				
			end				
		elseif level==6 then	
			local xt=(t/360)%2
			if xt==1 then
				spawn_enemy(flr(rnd(120))+4,-20,4)				
			else
				spawn_enemy(flr(rnd(120))+4,-20,1)				
			end				
		elseif level==7 then
			local loc = flr(rnd(100))+4
			local rand=flr(rnd(4))
			spawn_enemy(loc,-20,rand)		
			spawn_enemy(loc+20,-20,rand)						
		elseif level==8 then
			local loc = flr(rnd(100))+4
			local rand=flr(rnd(5))
			spawn_enemy(loc,-20,rand)		
			spawn_enemy(loc+20,-20,rand)				
		else
			local numl= 2+flr(level/10)
			local loc = flr(rnd(120-16*numl))+4
			local rand=flr(rnd(5))
			for i=1,numl do
				if level%2 == 0 then rand=flr(rnd(5)) end
				spawn_enemy(loc+(i-1)*16,-20,rand)
			end
		end		
	end
	if t%480==20 and speedmult==1 then
		local arr={}
		
		maxj=flr(t/800)+1+flr(level)
		for j=1,maxj do
			arr[j]={}
			for i=1,16 do
				if rnd()<0.4+(level/100) then
					arr[j][i]=true
				else
					arr[j][i]=false					
				end
			end
		end
		local spawnlone=false
		for j=1,maxj do
			for i=1,16 do
				if arr[j][i] then
					if j<maxj and i<15 then
						if arr[j+1][i] and arr[j+1][i+1] and arr[j][i+1] then
							spawn_obstacle(i*8-4,-24-j*8,1)
							arr[j][i]=false
							arr[j+1][i]=false
							arr[j][i+1]=false
							arr[j+1][i+1]=false
						else
							spawnlone=true
						end
					else
						spawnlone=true
					end
				end
				if spawnlone then
					spawn_obstacle(i*8-4,-16-j*8,0)
					arr[j][i]=false
				end
				spawnlone=false
			end
		end
		
	end
	if t%1200==1199 and speedmult==1 then
		spawn_gravwell(2+124*flr(rnd(2)),-20)
	end
	end
	
	if t>=3000 and gamemode==1 and p.alive then
						gamemode=2
						speedupc=480
						sfx(7)
						entershop=false	
						t=0
	end
	
	p.dx*=0
	p.dy*=0
 if btn(0,0) then p.dx-=1 end
 if btn(1,0) then p.dx+=1 end
 if btn(2,0) then p.dy-=1 end
 if btn(3,0) then p.dy+=1 end
 if btnp(5,0) then weapontype=(weapontype+1)%6 end
 p.x+=p.dx
 p.y+=p.dy
 p.x=clamp(p.x,4,124)
 p.y=clamp(p.y,4,124)
 
 
 --if btn(0,0) then m={x=-1,y=0} end
 --if btn(1,0) then m={x=1,y=0} end
 if btn(2,0) then m={x=0,y=-1} end
 if btn(3,0) then m={x=0,y=1} end

	if btnp(4,0) and p.alive then 
		if ammo>0 then
			ammo-=1
			local ax = p.x+m.x*6
			local ay = p.y+m.y*6
			sfx(1)
			mangle=0
			


			if weapontype==0 then
				spawn_bullet(ax,ay,0,-2,0,1) 
			elseif weapontype==1 then --tri
				spawn_bullet(ax,ay,0,-2,0,1) 
				spawn_bullet(ax,ay,0.6,-1.6,0,1) 
				spawn_bullet(ax,ay,-0.6,-1.6,0,1) 
			elseif weapontype==2 then --wave
				spawn_bullet(ax,ay,0,-2,1,1)
			elseif weapontype==3 then --quad
				spawn_bullet(p.x,p.y-6,0,-2,0,1) 
				spawn_bullet(p.x,p.y+6,0,2,0,1) 
				spawn_bullet(p.x-6,p.y,-2,0,0,1) 
				spawn_bullet(p.x+6,p.y,2,0,0,1) 
			elseif weapontype==4 then --5shot
				spawn_bullet(ax,ay,0,-2,0,1) 
				spawn_bullet(ax,ay,1.4,-1.4,0,1) 
				spawn_bullet(ax,ay,0.6,-1.6,0,1) 
				spawn_bullet(ax,ay,-1.4,-1.4,0,1) 				
				spawn_bullet(ax,ay,-0.6,-1.6,0,1) 				
			elseif weapontype==5 then --laser
				spawn_laser(ax,ay,ax,ay-128,1)			
			end
		else
			sfx(13)
		end
	elseif btnp(4,0) and gameoverc==1 then
		--reset game
		intro_init()
	end
	for l in all(lasers) do
		l.c-=1
		if gamemode==1 and l.side==1 and l.c==1 then
			for e in all(enemies) do
				if collision(l,e) then
					local ehp=e.hp
					local sound=0
					if damage(l.hp,e) then
						del(enemies,e)
						spawn_gems(e.x,e.y,8)	
						kills+=1
						sound=1				
					end	
					if sound==1 then sfx(3) else sfx(6) end
				end
			end
			for o in all(obstacles) do
				if collision(l,o) then
					local ohp=o.hp
					local sound=0
					if damage(l.hp,o) then
						spawn_gems(o.x,o.y,1)	
						del(obstacles,o)
						sound=1
					end
					if sound==1 then sfx(6) else sfx(9) end
				end
			end
		
		end
		if l.c==0 then del(lasers,l) end
	end	
	
	
	for g in all(gems) do
		g.x+=g.dx
		g.y+=g.dy+(speedmult-1)+0.25
		g.dx*=0.98
		g.dy*=0.98
		g.c-=1
		if g.c==0 then del(gems,g)	end
		if gamemode==1 then
			if collision(g,p) then
				sfx(4)
				credits+=g.hp
				gemc+=g.hp
				del(gems,g)
			end		
		elseif gamemode==2 then
		end
		if g.y<-10 or g.y>138 then
			del(gems,g)
		elseif g.x<0 or g.x>128 then
			g.dx=-g.dx
		end
	end

	for e in all(enemies) do
		e.x+=e.dx
		e.y+=e.dy+(speedmult-1)
		if e.x>128 or e.x<0 then e.dx=-e.dx end	
		if gamemode==1 then
			e.c+=1
	 	if e.c==e.maxc then
 		--local dist=(p.x-e.x)*(p.x-e.x)+
 		--				(p.y-e.y)*(p.y*e.y)
 		--spawn_bullet(e.x,e.y+6,(p.x-e.x)/sqrt(dist),(p.y-e.y)/sqrt(dist))
 			if e.t==0 or e.t==1 then spawn_bullet(e.x+6*e.ax,e.y+6*e.ay,e.ax,e.ay,0,0)
				elseif e.t==2 or e.t==3 then
					local distc=sqrt((p.x-e.x)*(p.x-e.x)+(p.y-e.y)*(p.y-e.y))
					local tx=(p.x-e.x)/distc
					local ty=(p.y-e.y)/distc
					spawn_bullet(e.x,e.y,tx,ty,0,0)
				elseif e.t==4 then
					e.angle=(e.angle+1)%16
					spawn_bullet(e.x,e.y,cos(e.angle/16),sin(e.angle/16),0,0)
				end
				
 			if e.t==1 then e.dx=-e.dx end
 			e.c=0
 		end
 		if collision(e,p) and p.alive then
	 		scrshkc=16
 			if damage(e.hp,p)	then				
					p.alive = false
					scrshkc=32
				end
				if scrshkc==32 then sfx(5) else sfx(3) end
				del(enemies,e)
				spawn_gems(e.x,e.y,4)
				kills+=1
				regen=0
 		end
 		if e.y>128 and e.dy>0 then
 			e.dy=-0.3
 			if e.t==0 or e.t==1 then e.ay=-1 end
 		elseif e.y<0 and e.dy<0 then
				e.dy=0.3
				if e.t==0 or e.t==1 then e.ay=1 end
 		end
 	elseif gamemode==2 then
 		if e.y>138 then
 			del(enemies,e)
 		end
 	end
 end
 for o in all(obstacles) do
 	o.x+=o.dx
 	o.y+=o.dy+(speedmult-1)
 	if o.x<0 or o.x>128 or o.y>128 then
 		del(obstacles,o)
 	end
 	if gamemode==1 then
	 	if collision(p,o) and p.alive then
 			scrshkc=8
 			if damage(o.hp,p) then
 				p.alive = false		
	 			scrshkc=32
 			end
 			if scrshkc==32 then sfx(5) else sfx(6) end
 			del(obstacles,o)
				regen=0
 		end
		elseif gamemode==2 then
	 end
	end

	for b in all(bullets) do
		local deleted=false
		b.x+=b.dx
		b.y+=b.dy+(speedmult-1)
		if b.x<0 or b.x>128 or b.y<0 or b.y>128 then
			del(bullets,b)
		end
		if gamemode==1 then 
			if b.side==1 then
			for e in all(enemies) do
				if collision(b,e) then
					local ehp=e.hp
					local sound=0
					if damage(b.hp,e) then
						del(enemies,e)
						spawn_gems(e.x,e.y,8)	
						kills+=1
						sound=1				
					end	
					if sound==1 then sfx(3) else sfx(6) end
					b.hp-=ehp
					if b.hp<=0 then
						del(bullets,b)
						deleted=true
					end
				end
			end
			for o in all(obstacles) do
				if collision(b,o) then
					local ohp=o.hp
					local sound=0
					if damage(b.hp,o) then
						spawn_gems(o.x,o.y,1)	
						del(obstacles,o)
						sound=1
					end
					if sound==1 then sfx(6) else sfx(9) end
					b.hp-=ohp
					if b.hp<=0 and not deleted then
						del(bullets,b)
						deleted=true
					end
				end
			end
			end
			
			if p.alive and b.side==0 then
				for g in all(gravwells) do
					if collision(p,g) then
						gamemode=2
						speedupc=480
						sfx(7)
						entershop=true
					end
				end
		
				local distsq=(b.x-p.x)*(b.x-p.x)+
						(b.y-p.y)*(b.y-p.y)
				local distsqnx=(b.x+b.dx-p.x)*(b.x+b.dx-p.x)+
						(b.y+b.dy-p.y)*(b.y+b.dy-p.y)
				if distsq<=8*8 and distsqnx<distsq then
			--entry angle
					local reflect=false
					local zgle=atan2(b.y-p.y,b.x-p.x)*360
					
					if zgle>180-mangle and zgle<180+mangle and m.y==-1 then 
						reflect=true
					end
					if (zgle<mangle or zgle>360-mangle) and m.y==1 then
						reflect=true
					end
					
					if reflect then
				--
						mangle=max(0,mangle-30)
						b.side=1
						sfx(11)
						local n={x=(b.x-p.x)/sqrt(distsq),
														y=(b.y-p.y)/sqrt(distsq)}
						local dot = b.dx*n.x
															+b.dy*n.y
						b.dx-=(2*dot*n.x)
						b.dy-=(2*dot*n.y)
						while distsq<=8*8 do
							b.x+=b.dx
							b.y+=b.dy
							distsq=(b.x-p.x)*(b.x-p.x)+
								(b.y-p.y)*(b.y-p.y)
						end
					end
					if distsq<=4*4 then
						--player damage
						local sound=0
						if damage(b.hp,p) then
							p.alive=false
							sound=1
							scrshkc=32
						end
						if sound==1 then sfx(5) else sfx(12) end
						regen=0
						ammo=maxammo
						absorbc=32
						if not deleted then del(bullets,b) end
					end
				end
			end
		end
	end
	
	for e in all(explode) do
		if e.c >e.maxc then
			del(explode,e)
		else
			e.c+=0.5
		end
	end
	foreach(stars,function(s)
		s.y+=s.dy+(speedmult-1)
		if s.y>256 then 
			s.y-=256 
			s.x=rnd(128)
		end
	end)
	foreach(gravwells,function(g)
		g.y+=g.dy+(speedmult-1)
		if	g.y>138 then
			del(gravwells,g)
		end
	end)

	if p.hp<p.maxhp and p.alive and gamemode==1 then 
		regen+=regenspeed
	end
	if regen==127 and p.alive then 
		if p.hp<p.maxhp then
		p.hp+=1
		regen=0
		end
	end
	if creditc>0 then creditc-=1 end
	if credits!=prevcredits then
		creditc=8
		prevcredits=credits
	end
	
	if gameoverc>1 then	gameoverc-=1 end
	if not p.alive and gameoverc==0 then 
		gameoverc=200 
		score=credits+p.maxhp*20+maxammo*10+level*100+kills*5
		
	end
	if msgc>0 then msgc-=1 end
	
	for i=1,7 do
		pshadow[i].x=pshadow[i+1].x
		pshadow[i].y=pshadow[i+1].y+speedmult-1
		pshadow[i].c=pshadow[i+1].c
	end
 pshadow[8].x=p.x
 pshadow[8].y=p.y+speedmult-1
 pshadow[8].c=(t+speedupc)%2
	
	if gamemode==1 then 
		if speedmult>1 then
 		speedmult-=1
		else
 		t=(t+1)%16384 
		end
	end
	if gemc >= 100 then
		gemhigh = true
	end
end

function spawn_gems(xx,yy,size)
	local zz=size
	while zz>0 do
		local angle=rnd() 
		local sx=xx+cos(angle)*8
		local sy=yy+sin(angle)*8
		local rr=flr(rnd(3))+1
		spawn_gem(sx,sy,cos(angle)*(rnd(1)+0.1),sin(angle)*(rnd(1)+0.1),rr)	
		zz-=rr
	end
end

function spawn_gem(xx,yy,dxx,dyy,sze)
	local hpp=1
	if sze==2 then hpp=5 end
	if sze==3 then hpp=20 end
	obj={x=xx,y=yy,dx=dxx,dy=dyy,
	hit={x=-sze,y=-sze,w=sze*2,h=sze*2},
	hp=hpp,size=sze,c=180}
	add(gems,obj)
end

function spawn_obstacle(xx,yy,tt)
	local obj={}
	if tt==0 then
		obj={x=xx,y=yy,dx=0,dy=0.25,
		hit={x=-3,y=-3,w=7,h=7},
		hp=1,t=tt}
	elseif tt==1 then
		obj={x=xx,y=yy,dx=0,dy=0.25,
		hit={x=-6,y=-6,w=14,h=14},
		hp=4,t=tt}
	end
	add(obstacles,obj)
end
function spawn_gravwell(xx,yy)
	add(gravwells,{x=xx,y=yy,dx=0,dy=0.25,
		hit={x=-10,y=-10,w=21,h=21}
	})
end

function spawn_enemy(xx,yy,tt)
	local obj ={}
	if tt==0 then
		obj={x=xx,y=yy,dx=0,dy=0.3,
			ax=0,ay=1,
			hit={x=-2,y=-2,w=4,h=4},
			hp=3,c=0,maxc=32,			
			t=tt}
	elseif tt==1 then
		obj={x=xx,y=yy,dx=0.6,dy=0.3,
			ax=0,ay=1,
			hit={x=-2,y=-2,w=4,h=4},
			hp=3,c=0,maxc=32,			
			t=tt}
	elseif tt==2 then
		obj={x=xx,y=yy,dx=0,dy=0.3,
			ax=0,ay=0,
			hit={x=-2,y=-2,w=4,h=4},
			hp=3,c=0,maxc=32,			
			t=tt}	
	elseif tt==3 then
		obj={x=xx,y=yy,dx=-0.6,dy=0.3,
			ax=0,ay=0,
			hit={x=-2,y=-2,w=4,h=4},
			hp=3,c=0,maxc=32,			
			t=tt}	
	elseif tt==4 then
		obj={x=xx,y=yy,dx=0.2,dy=0.3,
			ax=0,ay=0,
			hit={x=-2,y=-2,w=4,h=4},
			hp=3,c=0,maxc=8,angle=0,		
			t=tt}	
	end
	add(enemies,obj)
end
function spawn_laser(xx1,yy1,xx2,yy2,sside)
	obj = {x=xx1,y=yy1,x2=xx2,y2=yy2,
			hit={x=0,y=(yy2-yy1),w=1,h=(yy1-yy2)},hp=1,side=sside,c=8}
	add(lasers,obj)
end--				spawn_laser(ax,ay,ax,ay-128,1)			


function spawn_bullet(xx,yy,dxx,dyy,tt,sside)
	--t=type, 0 normal
	--1,2,3,4 -> left right up down
	local hitt={}
	local hpp=1
	if sside==1 then hpp=weapondamage end
	if sside==1 and gemhigh then hpp*=2 end
	if tt==0 then
		hitt={x=0,y=0,w=1,h=1}
	elseif tt==1 then --wave
		hitt={x=-4,y=-1,w=9,h=2}
	elseif tt==2 then --laser
		hitt={x=0,y=-128,w=1,h=128}
	end 
	obj = {x=xx,y=yy,dx=dxx,dy=dyy,t=tt,
			hit=hitt,hp=hpp,side=sside}
	add(bullets,obj)
end


function spawn_explode(xx,yy,cc)
		obj = {x=xx,y=yy,c=0,maxc=cc}
	add(explode,obj)
end


function game_draw()
	cls()
	if scrshkc>0 then
		local dev=scrshkc/2
		camera(rnd(dev)-dev/2,rnd(dev)-dev/2)
		scrshkc-=1
	end
		--mirror	
	foreach(stars,function(s)
		line(s.x,s.y,s.x,s.y-s.dy*speedmult,5)
	end)
		
	foreach(obstacles,function(o)
		if o.t == 0 then
			spr(29,o.x-4,o.y-4)
		elseif o.t == 1 then
			spr(30,o.x-4,o.y-4)
			spr(31,o.x+4,o.y-4)
			spr(46,o.x-4,o.y+4)
			spr(47,o.x+4,o.y+4)
		end
	end)
	
	foreach(gems,function(g)
		if g.c>64 or flr(g.c/4)%2==0 then
			spr(12+g.size,g.x-4,g.y-4)
		end
	end)
	
	foreach(enemies,function(e)
		if e.t==0 or e.t==1 then
			spr(16,e.x-4,e.y-4)
		elseif e.t==2 or e.t==3 or e.t==4 then
			local py=e.y-p.y
			local px=p.x-e.x
			local offset=0
			local flipx=false
			local flipy=false
			if e.t==4 then
				local dangle=flr(e.angle/2)
				px=0
				if dangle==0 or dangle==1 or dangle==7 then px=1
				elseif dangle==3 or dangle==4 or dangle==5 then px=-1
				end
				py=0
				if dangle==1 or dangle==2 or dangle==3 then py=1
				elseif dangle==5 or dangle==6 or dangle==7 then py=-1
				end				
			end
			if py>2*px then
				if py>-0.5*px then
					if py>-2*px then
						offset=2
						flipy=true
					else
						flipx=true
						flipy=true
					end
				else
					if py>0.5*px then
						offset=1
						flipx=true
					else
						flipx=true
					end
				end
			else
				if py>-0.5*px then
					if py>0.5*px then
						flipy=true
					else
						offset=1
					end
				else
					if py>-2*px then
					else
						offset=2
					end
				end
			end
			
			spr(17+offset,e.x-4,e.y-4,1,1,flipx,flipy)		
		end
	end) 
	
	foreach(explode,function(e)
		circfill(e.x+rnd(4)-2,e.y+rnd(4)-2,e.c,8)
		if e.maxc-e.c>1 then
			circfill(e.x+rnd(2)-1,e.y+rnd(2)-1,e.c,7)
		end
	end)
	
	foreach(bullets,function(b)
		if b.t==0 then
			circfill(b.x-b.dx,b.y-b.dy,0,8-b.side)
			circfill(b.x,b.y,1,8-b.side)

		elseif b.t==1 then
			line(b.x-2,b.y-1,b.x+2,b.y-1,7)
			line(b.x-2,b.y-1,b.x-4,b.y+1,7)
			line(b.x+2,b.y-1,b.x+4,b.y+1,7)
			line(b.x-2,b.y,b.x+2,b.y,8)
			line(b.x-2,b.y,b.x-4,b.y+2,8)
			line(b.x+2,b.y,b.x+4,b.y+2,8)

		end		
	end)
	foreach(lasers,function(l)
		line(l.x-1,l.y,l.x2-1,l.y2,8)
		line(l.x,l.y,l.x2,l.y2,7)
		line(l.x+1,l.y,l.x2+1,l.y2,8)
	end)
	
	foreach(shopselect,function(s)
		spr(shopitem[s.id].sp,s.x,s.y)
		print(shopitem[s.id].cost,s.x,s.y-10,7)
		print(shopitem[s.id].name,s.x,s.y+10,7)
		
	end)
	
	
	if p.alive then
		if absorbc>0 then absorbc-=1 end
		for i=1,8 do
		local pspr=pshadow[i].c+1
		if i==2 or i==3 then pspr=2 end
--			if i==1 then pspr=2 end
			spr(pspr,pshadow[i].x-4,pshadow[i].y-4)
		end
		
--		spr(1,p.x-p.dx-4,p.y-p.dy-4)	
		spr(flr(absorbc/4)%2,p.x-4,p.y-4)

		for i=1,8 do
			if mangle>=(i-1)*90/7 then
				circ(p.x+mirr[i].x,p.y+mirr[i].y*m.y,0,7)
				circ(p.x-mirr[i].x,p.y+mirr[i].y*m.y,0,7)
			end
		end

	end

 foreach(gravwells,function(g)
		circ(g.x,g.y,5-((t/16)%4),7)
		circ(g.x,g.y,9-((t/16)%4),7)
		circ(g.x,g.y,10,7)
	end)
	
	--rectfill(p.x,p.y,p.x+5,p.y+5,5)
 
 local bar=(120/p.maxhp)
 line(2,2,126,2,0)
 line(6,6,130,6,0)
 line(3,3,hpshadow*bar+regenshadow/128*bar+2,3,7)
 line(5,5,hpshadow*bar+regenshadow/128*bar+4,5,7)

 line(3,3,p.hp*bar+regen/128*bar+2,3,8)
 line(4,4,p.hp*bar+regen/128*bar+3,4,8)
 line(5,5,p.hp*bar+regen/128*bar+4,5,8)

 for i=1,p.maxhp do
 	line(3+(i)*bar,3,4+(i)*bar,4,0)
 end
	
	rectfill(7,6,128,8,0)
 local abar=(120/maxammo)
 for i=1,ammo do
 	line(7+(i-1)*abar,7,5+i*abar,7,7)
 	line(8+(i-1)*abar,8,6+i*abar,8,7)

 end

	line(10,10,10+gemc,10,8)
 
 if gameoverc>0 then
		if gameoverc<200 then 
			print("game over",64-22+rnd()*4-2,20+rnd()*4-2,8)		
			print("game over",64-22,20,7)
		end
		if gameoverc<170 then
			print("level",31,51,0)
			print(level,81,51,0)
			print("level",30,50,7)
			print(level,80,50,7)
		end
		if gameoverc<140 then
			print("credits",31,61,0)
			print(credits,81,61,0)
			print("credits",30,60,7)
			print(credits,80,60,7)
		end
		if gameoverc<110 then
			print("score",31,71,0)
			print(flr((90-max(gameoverc-20,0))/90*score),81,71,0)			
			print("score",30,70,7)
			print(flr((90-max(gameoverc-20,0))/90*score),80,70,7)			
		end
		if gameoverc==1 then
			print("press z to restart",30+rnd(2)-1,80+rnd(2)-1,8)
			print("press z to restart",30,80,7)
		end		
	end
	if msgc>0 then
		msgx=(msgmax-msgc)/msgmax*4*#msgtxt
		print(sub(msgtxt,1,msgx),64-(#msgtxt/2)*4-2+rnd()*2-1,20+rnd()*2-1,8)	
		print(sub(msgtxt,1,msgx),64-(#msgtxt/2)*4-2,20,7)
	end

	if t>=2700 then
			local timleft = flr((3000-t)/60+0.5)
			print("warping in "..timleft,64-24+rnd()*2-1,20+rnd()*2-1,8)
			print("warping in "..timleft,64-24,20,7)
	end

	local wx=0
	if creditc>0 then wx=rnd(2)-1 end
	
	print(credits,1+wx,12+wx,8)
	print(credits,2,13,7)

	if gemhigh then 
		print("x2 dmg",2+16*4-rnd(2)+1,120-rnd(2)+1,8)
		print("hyper credits - x2 dmg",2,120,7)
	end
--	print(t,64,24,8)
-- rectfill(1,0,1+regen,0,8)
end


function collide(ax,ay,ahitbox, bx,by,bhitbox)
    if
        bx+bhitbox.x+bhitbox.w > ax+ahitbox.x and
        by+bhitbox.y+bhitbox.h > ay+ahitbox.y and
        bx+bhitbox.x < ax+ahitbox.x+ahitbox.w and
        by+bhitbox.y < ay+ahitbox.y+ahitbox.h
    then
        return true
    end
end

function collision(a,b)
	return collide(a.x,a.y,a.hit,b.x,b.y,b.hit)
end
if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
11111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111117111
11117111111181111111011100000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111711111177711
11117111111181111111011100000000000000000000000000000000000000000000000000000000000000000000000011111111111171111117771111777871
11177711111888111110001100000000000000000000000000000000000000000000000000000000000000000000000011111111111787111178887117788887
11777771118888811100000100000000000000000000000000000000000000000000000000000000000000000000000011111111111171111117871111788871
11777771118888811100000100000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111711111178711
11711171118111811101110100000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111117111
11111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111
11101011111001111111111111100011000000000000000000000000000000000000000000000000000000000000000000000000110000111111111111111111
11080801110880111100001111088801000000000000000000000000000000000000000000000000000000000000000000000000108778011111110000111111
10888880108808011088880110888880000000000000000000000000000000000000000000000000000000000000000000000000087777801111008888001111
10888880088888800880808010808080000000000000000000000000000000000000000000000000000000000000000000000000077777801110887770080111
10808080080880800888800110888880000000000000000000000000000000000000000000000000000000000000000000000000078780801108777777008011
11018101108801010880808010800080000000000000000000000000000000000000000000000000000000000000000000000000087000801108777778008011
11118111110880111088880111080801000000000000000000000000000000000000000000000000000000000000000000000000108888011087787777000801
11110111111001111100001111101011000000000000000000000000000000000000000000000000000000000000000000000000110000111087777780080801
11000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001080700708008801
10877801000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001080000000000801
08777780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001108008080008011
07777780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001108000000808011
07878080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001110880008880111
08700080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111008888001111
10888801000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111110000111111
11000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111111
11111111117111711111111111111111111111111111111111111111118111811111111100000000000000000000000000000000000000000000000011111111
11111111118111811111111111187811111171111111711111178111181818181111111100000000000000000000000000000000000000000000000011181811
11117111111171111117711111187811111181111171817111178111818888811111111100000000000000000000000000000000000000000000000011888881
17118117171181171178871111187811111111111118181117778881818887811111111100000000000000000000000000000000000000000000000011888781
18111118181111181781187111187811178111871781118718888881181878181111111100000000000000000000000000000000000000000000000011187811
11111111111111111811118111187811111111111118181111178111118181811111111100000000000000000000000000000000000000000000000011118111
11111111111111111111111111187811111181111171817111178111111818111111111100000000000000000000000000000000000000000000000011111111
11111111111111111111111111111111111171111111711111111111111181111111111100000000000000000000000000000000000000000000000011111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777077770777707007070777707007000070070070777707000070000000000000000000000000000000000000000000000000000000000000000000000000
07000070070700707007070070007007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07000070070700707007070070007007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07000070070700707007070070007007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07000070070700707007070070007007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07000070070700707007070070007007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07000070070700707007070070007007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07007077770777700707070070007777000070070070777707000070000000000000000000000000000000000000000000000000000000000000000000000000
07007077000700700707070070000007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07007070700700700707070070000007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07007070700700700707070070000007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07007070070700700077070070000007000070070070700007000070000000000000000000000000000000000000000000000000000000000000000000000000
07777070070700700077070070007777000077777770777707777077770000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777070070700700077070070007777000077777770777707777077770000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4041424344454647000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051525354555657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001a7501975017750157501375011750107500e7500b7500b75007750077500473001720017100670005700000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b750277502475022750217501f7501e7501d7501b7501a74019730187201771000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000010550165501254018540145301a530155201c520165101d51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001d6400a64016630086300f620056200961003610036100001000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002a75031750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000346501c6502f650186502964012640246400e6401f6300b630196300963011620056200b6200261005610016100000000000000000000000000000000000000000000000000000000000000000000000
00070000126500f6400c6300962005610036000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000015500155001550025500355005550075500a5500c5500f5501155014550175501b5501e5502255025500225402e600225402e600225302f600225302f60022520306002252000000225100000022510
000b000018550145400e5200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000562003610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000e66004640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000855008510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001e5501e5101e5201e51000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000f050000000f0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
