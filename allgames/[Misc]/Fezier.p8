pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- an arena shooter
-- by @elastiskalinjen

--player
p1x=64 p1y=64 p1w=8 p1h=8
p1dificulty=2 p1hp=3 p1score=0 olddificulty=p1dificulty

p1dist=0 p1anglemp=0
p1shieldsize=10 p1shield=false p1stop=false p1stopbonus=0

p1delay=false p1autofire = false p1canteleport=false 
p1dcounter=0 p1dust=false
p1icounter=0 p1invurnable=false

p1teleportcounter=0 p1delaycounter=0 p1circcounter=0 p1trot=0

p1a_fr=2 p1a_st=0 p1fl=false
	------------------------------------------------------------------------------

function playerupdate()
	p1anglemp = calcangle(mx,my,p1x,p1y)
	p1dist = calcdist(p1x,p1y,mx,my)
	if p1trot< 100 then p1trot+=0.006 else p1trot=0 end

	if p1shield == false and p1stop == false then
		flipanimation()
	end

	if btn(4) then--stop the character
		p1stop = true 
		if(p1stopbonus < 18 and set == true)p1stopbonus+=0.09
		
		if p1stopbonus >= 4.9 and p1stopbonus < 5.1 then 
			initcircle(p1x+4,p1y+4,0,10,0.25,7)
			sfx(21)
		end
		if p1stopbonus >= 9.9 and p1stopbonus < 10.1 then
			initcircle(p1x+4,p1y+4,0,12,0.35,8)
			sfx(22)
		end
		if p1stopbonus >= 13.9 and p1stopbonus < 14.1 then
			initcircle(p1x+4,p1y+4,0,14,0.45,9)
			sfx(23)
		end
		if p1stopbonus >= 17.8 and p1stopbonus < 17.9 then
			for i=0,2 do
				sfx(24)
				initcircle(p1x+4,p1y+4,0,16+i,(i*0.1)+0.35,10) 
			end
		end
	else
		p1stop=false 
		p1stopbonus = 0
	end

	if btnp(5) and p1canteleport == false then--teleport
		p1canteleport = true
		sfx(10)
		for i=0,2 do initparticle(p1x,p1y,rnd(2)-1,rnd(2)-1,rnd(2)+1,11) end
		initlaser(p1x+cos(p1anglemp)*7,p1y+sin(p1anglemp)*7,(mx+4)+rnd(4)-rnd(4),(my+4)+rnd(4)-rnd(4),11,15)
		p1x = mx+4
		p1y = my+4
		shake+=0.1
		p1stopbonus=0
		for i=0,10 do initparticle(p1x+4,p1y+4,rnd(2)-1,rnd(2)-1,rnd(2)+3,11) end
	end

	if p1canteleport == true then
		p1teleportcounter+=1
		if p1teleportcounter >= 70 + (p1dificulty*20) then
			p1canteleport=false
			p1teleportcounter = 0
		end
	end

	if (pnt() or p1autofire == true) and p1shield == false and p1delay == false and p1invurnable == false then --laser	
		if p1delay == false then
			mouse.hit = true
			p1delay = true
			sfx(8)
			shake += 0.075
			initparticle(p1x+4,p1y+4,rnd(2)-1,rnd(2)-1,rnd(2)+3,8+rnd(3))
			for i=0,3 do initparticle(mx+4,my+4,rnd(2)-1,rnd(2)-1,rnd(2)+3,8+rnd(3)) end
			for i=0,3 do initlaser(p1x+4,p1y+4,(mx+4)+rnd(4)-rnd(4),(my+4)+rnd(4)-rnd(4),8,10) end

			if nenum == 1 then
				local dsprite = 39
				if level >= 10 and level < 19 then 
					dsprite = 40
				elseif level >= 19 then
					dsprite = 41
				end
				mset((mx+4)/8, (my+4)/8, dsprite)
			end
		end			
	end
	if p1delay == true then --delay
		p1delaycounter+=1
		if(p1delaycounter >=2)mouse.hit=false
	end
	if p1delaycounter >= 20 + (p1dificulty * 10) - p1stopbonus / 1.4 then
		p1delay=false
		p1delaycounter=0
	end

	if dist < 10 or pntr() then --shield
		if p1shieldsize > 5 and p1invurnable == false then
				p1shield = true
				p1circcounter+=1
				if(p1dificulty ~=1)p1shieldsize-=0.015
				if(p1circcounter>=20)then
				initcircle(p1x+4,p1y+4,0,p1shieldsize,0.25,7)
				for i=0,2 do initparticle(p1x+4,p1y+4,rnd(2)-1,rnd(2)-1,rnd(2)+3,12+rnd(2)) end
				p1circcounter = 0
				end
		else
			p1shield = false
		end
	else
		if p1stop == false then
			p1x,p1y = movetowards(mx,my,p1x,p1y,0.75 - (p1dificulty*0.1))
			if p1dust == false then
				if p1invurnable == false then 
					initparticle(p1x+4,p1y+4,rnd(1),rnd(1),rnd(1)+1,6+rnd(2)) 
				else
					for i=0,4 do initparticle(p1x+4,p1y+4,rnd(1),rnd(1),rnd(1)+1,10) end
				end 
				p1dust = true
			end
		end
		p1shield = false
		if(p1shieldsize < 10)p1shieldsize+=0.02
	end

	if p1dust == true then --dust delay
		p1dcounter+=1
		if p1dcounter>=50 then
			p1dust=false
			p1dcounter=0
		end
	end

	if p1invurnable == true then --invurnable
		p1icounter+=1
		if(p1icounter == 1)for i=0,3 do initparticle(p1x+4,p1y+4,rnd(2)-1,rnd(2)-1,rnd(2)+3,8+rnd(2)) end
		if p1icounter>=90 then
			p1invurnable = false
			p1icounter = 0
		end
	end
end

--start frame,num frames,speed,flip
function animplayer(sf, nf, sp, fl)
	if(not p1a_ct) p1a_ct=0
	if(not p1a_st) p1a_st=0

	p1a_ct+=1

	if(p1a_ct%(30/sp)==0) then
	 p1a_st+=1
	 if(p1a_st==nf) p1a_st=0
	end

	p1a_fr=sf+p1a_st
	p1fl=fl
end

function flipanimation()
	if p1shield == false and p1stop == false then
		if p1anglemp > 0.1 and p1anglemp < 0.4 then--up
			animplayer(9,2,5,false)
		elseif p1anglemp > 0.4 and p1anglemp < 0.6 then--left
			animplayer(11,2,5,true)
		elseif p1anglemp > 0.6 and p1anglemp < 0.8 then--down
			animplayer(7,2,5,false)
		elseif (p1anglemp > 0.8 and p1anglemp < 1) or (p1anglemp > 0 and p1anglemp < 0.1) then--right
			animplayer(11,2,5,false)
		end
	end
end

mx=0
my=0
mouse=
{	
	x=0,y=0, 
	b=0,ob=0,
 	rad=4,hit=0, 
	init=function()
		poke(0x5f2d,1)
		mouse.x=mid(0,stat(32),127)
		mouse.y=mid(0,stat(33),127)
		mouse.b=stat(34)		
	end,	
	update=function()
		mouse.ob=mouse.b
		mouse.x=mid(0,stat(32),127)
		mouse.y=mid(0,stat(33),127)
		mouse.b=stat(34)
	end,
}
-- mouse newly pressed
function pntp() return (mouse.b==1 and mouse.ob==0) end
-- mouse pressed
function pnt() return (mouse.b==1) end
-- mouse right pressed
function pntr() return (mouse.b==2) end
-- mouse coordinates: x,y=pntc()
function pntc() return mouse.x,mouse.y end

scrubs={}
function spawnscrub(x,y,col,dcol,dist,speed,size,state,hp,cd)
local s ={}
	s.x=x
	s.y=y
	s.speed=speed
	s.startspeed=speed
	s.hitshield=false
	s.hp=hp
	s.state = state
	s.dist=dist
	s.angle=0
	s.size=size
	s.col=col
	s.startcol=col
	s.dcol=dcol
	s.counter=0
	s.cd=cd
	s.canmove=0
	s.ability = false
	s.p1x=0
	s.p1y=0
	s.ac = 0

	add(scrubs, s)
end

function updatescrub(s)
	if(s.canmove < 12 and s.state ~= 6 and s.state ~= 9)s.canmove+=1 else s.canmove=12 -- a mini-delay,for reaction
	if s.canmove >= 11 then 
		if s.state == 1 or s.state == 5 or s.state == 8 then--normal and co
			if(calcdist(s.x,s.y,p1x+(p1w/2),p1y+(p1h/2)) < s.dist) then
				s.x,s.y = movetowards(p1x+(p1w/2),p1y+(p1h/2),s.x,s.y,s.speed)
			end
		end

		if s.state == 2 then--shooter
			if calcdist(s.x,s.y,p1x+(p1w/2),p1y+(p1h/2)) < s.dist then
				if s.ability == false then
					sfx(14)
					spawnbullet(s.x,s.y,2,calcangle(p1x+4,p1y+4,s.x,s.y),1,60,13)
					for i=0,2 do initparticle(s.x,s.y,rnd(2)-1,rnd(2)-1,1+rnd(2),13) end
					s.ability = true
				end
			else
				s.x,s.y = movetowards(p1x+(p1w/2),p1y+(p1h/2),s.x,s.y,s.speed)
			end
		end

		if s.state == 3 then--bomber
			if calcdist(s.x,s.y,p1x+(p1w/2),p1y+(p1h/2)) < s.dist then
				if p1shield == false then
					s.x,s.y = movetowards(p1x+(p1w/2),p1y+(p1h/2),s.x,s.y,s.speed)
				else
					if(calcdist(s.x,s.y,p1x+(p1w/2),p1y+(p1h/2)) < 80)s.x,s.y = movetowards(p1x+(p1w/2),p1y+(p1h/2),s.x,s.y,-s.speed/3)
				end
			end
		end

		if s.state == 4 or s.state == 9 then--charger	
			if(s.ac == 0 or s.ability == true)s.x,s.y = movetowards(p1x+(p1w/2),p1y+(p1h/2),s.x,s.y,s.speed)

			if calcdist(s.x,s.y,p1x+(p1w/2),p1y+(p1h/2)) < 50 and s.ac == 0 and s.ability == false then
				s.ac=1
				sfx(17)
				for i=0,7 do initparticle(s.x,s.y,rnd(2)-1,rnd(2)-1,1+rnd(2),7) end
				s.p1x=p1x+(p1w/2)
				s.p1y=p1y+(p1h/2)
			end

			if(s.ac >= 1 and s.ability == false)then
				if(s.ac < 60 and calcdist(s.x,s.y,s.p1x,s.p1y) > 5)then
					s.ac+=1
					s.x,s.y = movetowards(s.p1x,s.p1y,s.x,s.y,s.speed*4) 
				else
					s.ability = true
				end	
			end
		end

		if(s.state == 5)s.ability = true --at start

		if s.state == 6 then--mini-boss,waver
			if calcdist(s.x,s.y,64,64) < s.dist then
				if s.ability == false then
					for i=0,20 do 
					spawnbullet(s.x,s.y,3,0.05*i,1.5,80,8)
					end 
					for i=0,3 do initparticle(s.x,s.y,rnd(2)-1,rnd(2)-1,1+rnd(2),13) end
					initcircle(s.x,s.y,s.size,100,1.2,7)
					sfx(19)
					s.ability = true
				end
			else
				s.x,s.y = movetowards(64,64,s.x,s.y,s.speed)
			end
		end

		if s.state == 7 then--sniper
			if calcdist(s.x,s.y,p1x+(p1w/2),p1y+(p1h/2)) < s.dist then
				if s.ability == false then
					initlaser(s.x,s.y,p1x,p1y,8,10)
					sfx(14)
					spawnbullet(s.x,s.y,1,calcangle(p1x+4,p1y+4,s.x,s.y),2.5,60,7)
					for i=0,4 do initparticle(s.x,s.y,rnd(2)-1,rnd(2)-1,2+rnd(2),7+rnd(2)) end
					s.ability = true
				end
			else
				s.x,s.y = movetowards(p1x+(p1w/2),p1y+(p1h/2),s.x,s.y,s.speed)
			end
		end

		if s.state == 8 then--spawner
			if s.ability == false and treshold < 1 then
				spawnscrub(s.x+rnd(10)-rnd(10),s.y+rnd(10)-rnd(10),7,6,400,0.42,4,1,1,400)
				for i=0,4 do initparticle(s.x,s.y,rnd(2)-1,rnd(2)-1,2+rnd(2),7) end
				s.ability = true
				sfx(18)
			end
		end
		scrubstandard(s)
	end
end

function scrubstandard(s)--simple method for inh
	if circcoll(s.x,s.y,mouse.x+4,my+4,s.size,mouse.rad) == true then
		if mouse.hit == true then
			s.col = 7
			for i=0,2 do initparticle(s.x+rnd(10)-rnd(10),s.y+rnd(10)-rnd(10),rnd(2)-1,rnd(2)-1,s.size-1,s.dcol) end
			
			if s.state~=5 then 
				s.hp-=1
			else
				if(s.counter >= s.cd)s.hp-=1
			end
			
			if s.size > 4 then
				s.size-=1
				s.startspeed = s.startspeed * 1.1
				s.speed = s.speed * 1.1
			end
		else
			s.col = s.startcol
		end
	end
	if circcoll(s.x,s.y,p1x+4,p1y+4,s.size,p1shieldsize)==true and p1shield == true then
		s.speed=0
		if s.hitshield==false then
			initparticle(s.x,s.y,rnd(2)-1,rnd(2)-1,3,12)
			p1shieldsize-=0.1
			sfx(13)
			s.hitshield=true
		end
	else
		s.speed=s.startspeed
		s.hitshield=false
	end

	if circcoll(s.x,s.y,p1x+4,p1y+4,s.size,(p1w/2))==true and p1shield == false and p1invurnable == false then
		for i=0,3 do initparticle(s.x,s.y,rnd(2)-1,rnd(2)-1,3,s.col) end
		for i=0,3 do initparticle(p1x,p1y,rnd(2)-1,rnd(2)-1,3,8) end
		if(showwin == false and showlose == false and p1invurnable == false)then
			p1hp-=1
			shake+=0.75
			sfx(7)
			p1invurnable = true
			s.hp-=1
		end
	end

	if s.hp <=0 then--is dead
		for i=0,4 do initparticle(s.x+rnd(10)-rnd(10),s.y+rnd(10)-rnd(10),rnd(2)-1,rnd(2)-1,s.size-1,s.dcol) end
		if s.state == 3 then--splasher
			for i=0, 12 do spawnbullet(s.x,s.y,11,s.angle-rnd(60)+rnd(60),0.09,120,9) end 
		end	
		if s.state == 5 then--splitter
			if s.size > 4 then 
				for i=0,2 do spawnscrub(s.x+rnd(20)-rnd(20),s.y+rnd(20)-rnd(20),14,2,400,0.42,4,5,1,15)end
			end
		end
		if s.state == 9 then--last boss
			for i=0, 15 do spawnbullet(s.x, s.y, 3, 0.05*i, 1.5, 80, 5) end 
			initcircle(s.x,s.y,s.size,100,1.2,7) 
			shake += 0.4
			for i=0, 12 do 
				local type = 1 
				if i > 10 then 
					type = 2
				end
				spawnscrub(s.x+rnd(40)-rnd(40),s.y+rnd(40)-rnd(40),5, 0, 200, 0.42, 4, type,1, 80)
			end
		end 
		if(senum == 2)p1score+=s.state
		sfx(9)
		del(scrubs, s)
	end

	if(s.ability == true)s.counter+=1
	if s.counter >= s.cd and s.ability == true then
		if s.state ~= 5 then
			s.ability = false
			s.counter = 0
			s.ac=0
		end
	end
	s.angle=calcangle(p1x+4,p1y+4,s.x,s.y)
end

----menu variables, refractored to save space---------------------------
	senum=0--enum
	menum=0--marked enum
	nenum=0--next menu
	level=0 levelc=0 lockedlevel=28
	w=52 h=20
	ax=8 ay=21 ac=7--arcade
	ex=8 ey=43 ec=7--endless
	tx=8 ty=65 tc=7--option
	abx=8 aby=87 abc=7 --about
	
	autoffx=5 autoffy=32 autoffc=7 --auto off 
	autonx=40 autony=32 autonc=7 --auto on 
	
	d1x=5 d1y=62 d1c=7 --easy on 
	d2x=40 d2y=62 d2c=7 --medium on 
	d3x=75 d3y=62 d3c=7 --hard on 
	oh = 15 ow=30  -- option width
	showcontrols=false
	enx=10 eny=40 enw=95 enh=50 enc=7 score=0 --endlessbutton

	logoy=32 logocolor=7 
	dust=false dustc=0 pos=0 
	ac1=7 ac2=7 ac3=7 
--------------------------------------------------------------------------
	
function startscreenupdate()
	dustreset()
	animatebackground()
	--choose start menu 1 -----------------------------------------------------------
	if nenum <=0 then
		if menumouse(mx+4,my+4,ax,ay,w,h) == true then--arcade
			menum = 1
			ax = lerp(ax,28,0.2)
			resetcolor(8,7,7,7)
			logoy-=0.5
		elseif menumouse(mx+4,my+4,ex,ey,w,h) == true then--endless
			menum = 2
			ex = lerp(ex,28,0.2)
			resetcolor(7,9,7,7)
			logoy-=0.25
		elseif menumouse(mx+4,my+4,tx,ty,w,h) == true then--option
			menum = 3
			tx = lerp(tx,28,0.2)
			resetcolor(7,7,10,7)
			logoy+=0.5
		elseif menumouse(mx+4,my+4,abx,aby,w,h) == true then--about
			menum = 4
			abx = lerp(abx,28,0.2)
			resetcolor(7,7,7,15)
			logoy+=0.75
		else
			menum = 0
			resetcolor(7,7,7,7)
		end

		--move it back if not selected
		if(menum ~= 1)ax = lerp(ax,8,0.2)
		if(menum ~= 2)ex = lerp(ex,8,0.2)
		if(menum ~= 3)tx = lerp(tx,8,0.2)
		if(menum ~= 4)abx = lerp(abx,8,0.2)

		if logoy >-100 then--move logo 
			logoy-=0.2 
		else 
			logoy=135 
		end
		if(logoy > 135)logoy=-100
		if pntp() then--go to next menu
			for i=0,4 do initparticle(mx+4,my+4,rnd(2)-1,rnd(2)-1,rnd(2)+2,6+rnd(2)) end
			initcircle(mx+4,my+4,0,10,0.55,7)
			nenum = menum
			menum = 0
			pos = 120

			if(nenum > 0)then
				sfx(1)
			else 
				if(my < 64)then logoy+=10 else logoy-=10 end 
				sfx(0)
			end
		end
	else
	--other menu------------------------------------------------------------------------------	
		moveicons()
		if pntp() then--go back to main menu
			initcircle(mx+4,my+4,0,10,0.55,7)
			if mx > 115 then
				for i=0,4 do initparticle(mx+4,my+4,rnd(2)-1,rnd(2)-1,rnd(2)+2,6+rnd(2)) end
				pos = 8
				sfx(3)
				nenum = 0
			end
		end
		if nenum == 1 then--arcade
			selectlevel()
		elseif nenum == 2 then--endless
			endlessmenu()
		elseif nenum == 3 then--option
			optionmenu()
		end
	end
end

loopx = 60
even = 0
function animatebackground()
	if loopx < 60 then 
		loopx += 1
	else 
		loopx = 0
		for x=0, 16 do 
			local sprite = 0
			if even == 0 then 
				sprite = 42
				even = 1
			else
				even = 0
				sprite = 43
			end
			for y = 0, 16 do
				mset(x, y, sprite)
			end 
		end
	end
end

function menumouse(mx, my, x, y, w, h)--looks if hovering over a button
	if(my >= y and mx <=(x+w) and my <=(y+h)) then return true else return false end
end

function resetcolor(c1, c2, c3, c4)
	ac=c1 ec=c2 tc=c3 abc=c4
	ac1=c1 ac2=c2 ac3=c3
	d1c=c1 d2c=c2 d3c=c3
end

function moveicons()--move icons to the side
	ax = lerp(ax,pos,0.08)
	ex = lerp(ex,pos,0.10)
	tx = lerp(tx,pos,0.12)
	abx = lerp(abx,pos,0.14)
	if(logoy > 20)then logoy = lerp(logoy,200,0.11) else logoy = lerp(logoy,-100,0.11) end
end

function dustreset()
	if menum > 0 or (nenum > 0 and mx > 115) then
		if dust == false then
			initparticle(mx+4,my+4,rnd(2)-1,rnd(2)-1,rnd(2)+2,6+rnd(2))
			dust = true
		end
		if(dust == true)dustc+=1
		if dustc >=15 then
			dust = false
			dustc = 0
		end
	end
end

selx=0 sely=0
function selectlevel()
	if my > 20 and my < 48 and mx < 110 then
		resetcolor(8,7,7,7)
		sely = 22
	elseif my > 50 and my < 78 and mx < 110 then
		resetcolor(7,9,7,7)
		sely = 52
	elseif my > 80 and my < 108 and mx < 110 then
		resetcolor(7,7,10,7)
		sely = 82
	else
		resetcolor(7,7,7,7)
		sely = -100
	end

	selx = (checkwhatlevel()-1) * 12 + 4

	if ac2 > 7 then 
		levelc = 9
	elseif ac3 > 7then 
		levelc = 18
	else 
		levelc = 0 
	end

	if pntp() and checkwhatlevel() > 0 and checkwhatlevel() + levelc <= lockedlevel then
		sfx(4)
		sfx(5)
		senum = 1
		level = checkwhatlevel() + levelc
	end
end

function endlessmenu()
	if my >=40 and mx <= (enx+enw) and my <=(40+enh) and mx >=enx then
		enc = 3
		eny = lerp(eny,50,0.2)
		if pntp() and enc == 3 then
			sfx(4)
			sfx(5)
			senum=2
			olddificulty = p1dificulty
			p1dificulty=2 -- always plays endless on medium! same for all is important
		end
	else
		enc=7
		eny=lerp(eny,40,0.2)
	end
end

function optionmenu()
	if p1autofire == false then
		autoffc=11
		autonc=7
	else
		autoffc=7
		autonc=11
	end


	if p1dificulty == 1 then
		resetcolor(8, 7, 7, 0)
	elseif p1dificulty == 2 then
		resetcolor(7, 8, 7, 0)
	elseif p1dificulty == 3 then
		resetcolor(7, 7, 8, 0)
	end

	if menumouse(mx+4,my+4,autoffx,32,ow,oh) == true then
		autoffy = lerp(autoffy,37,0.07)
		autony = lerp(autony,32,0.07)
		if pntp() then
			p1autofire = false
			dset(3, -1)
			sfx(2)
		end
	elseif menumouse(mx+4,my+4,autonx,32,ow,oh) == true then
		autony = lerp(autony,37,0.07)
		autoffy = lerp(autoffy,32,0.07)
		if pntp() then
			p1autofire = true
			dset(3, 1)
			sfx(2)
		end
	else
		autoffy = lerp(autoffy,32,0.07)
		autony = lerp(autony,32,0.07)
	end

	if menumouse(mx+4,my+4,d1x,62,ow,oh) == true then
		lerpoption(67, 62, 62)
		if pntp() then
			p1dificulty = 1
			sfx(2)
		end
	elseif menumouse(mx+4,my+4,d2x,62,ow,oh) == true then
		lerpoption(62,67,62)
		if pntp() then
			p1dificulty = 2
			sfx(2)
		end
	elseif menumouse(mx+4,my+4,d3x,62,ow,oh) == true then
		lerpoption(62,62,67)
		if pntp() then
			p1dificulty = 3
			sfx(2)
		end
	else
		lerpoption(62,62,62)
	end
	olddificulty=p1dificulty
	dset(2, p1dificulty)
	if(my > 80 and mx < 103)showcontrols = true else showcontrols = false
end

function lerpoption(value1, value2, value3)
	d1y = lerp(d1y, value1, 0.07)
	d2y = lerp(d2y, value2, 0.07)
	d3y = lerp(d3y, value3, 0.07)
end

function checkwhatlevel()
	if ac1 > 7 or ac2 > 7 or ac3 > 7 then
		if mx < 12 then
			return 1
		elseif mx < 24 then
			return 2
		elseif mx < 36 then
			return 3
		elseif mx < 48 then
			return 4
		elseif mx < 60 then
			return 5
		elseif mx < 72 then
			return 6
		elseif mx < 84 then
			return 7
		elseif mx < 96 then
			return 8
		elseif mx < 108 then
			return 9
		else
			return 0
		end
	else
		return 0
	end
end

---particles-------------------------------------------------------------------------
lasers={}
function initlaser(x, y, x2, y2, col, du)
	local l={}
	l.x=x
	l.x2=x2
	l.y=y
	l.y2=y2
	l.col = col
	l.du = du

	add(lasers,l)
end

function updatelaser(l)
	l.du-=1
	if(l.du <= 0)del(lasers,l)
end

function drawlaser(l)
	line(l.x,l.y,l.x2,l.y2,l.col)
end

circles={}
function initcircle(x, y, rad, maxrad, speed, col)
	local c={}
	c.x=x
	c.y=y
	c.rad=rad
	c.maxrad=maxrad
	c.speed = speed
	c.col = col
	add(circles,c)
end

function updatecircle(c)
	c.rad+=c.speed
	if(c.rad >= c.maxrad)del(circles,c)
end

function drawcircle(c)
	circ(c.x,c.y,c.rad,c.col)
end

particles={}
function initparticle(x, y, dx, dy, size, col)
	local p={}
	p.x=x
	p.y=y
	p.dx=dx
	p.dy=dy
	p.size=size
	p.col=col
	add(particles, p)
end

function updateparticle(p)
	p.dx*=0.9
	p.dy*=0.9
 	p.x+=p.dx
 	p.y+=p.dy
 	if(p.size > 10)then p.size -= 0.5 else p.size -= 0.09 end
	if(p.size <=0)del(particles, p) 
end

function drawcircpart(p)
	circfill(p.x, p.y, p.size, p.col)
end

function drawscrub(s)
	circfill(s.x,s.y,s.size,s.col)
	if s.size <=4 then 
		spr(2,s.x-s.size+cos(s.angle)*2,s.y-s.size+sin(s.angle)*2)
	else
		circfill(s.x+cos(s.angle)*(s.size/2),s.y+sin(s.angle)*(s.size/2),2,7)
		circfill(s.x+cos(s.angle)*(s.size/2),s.y+sin(s.angle)*(s.size/2),1,5)
	end
end

bullets={}
--x,y,size,angle,speed,timer,colour
function spawnbullet(x, y, s, a, sp, t, c)
	local b ={}
	b.x = x
	b.y = y
	b.size = s
	b.speed = sp
	b.angle = a
	b.ltimer = t
	b.timer = 0
	b.col = c
	b.pc = 12

	add(bullets,b)
end
function updatebullet(b)
	b.x+=b.speed*cos(b.angle)
	b.y+=b.speed*sin(b.angle)
	b.timer+=1

	if circcoll(p1x+(p1w/2),p1y+(p1h/2),b.x,b.y,4,b.size) == true then
		if p1shield == false and p1invurnable == false then
			if(showwin == false and showlose == false)p1hp-=1
			p1invurnable = true
			b.pc = b.col
			shake+=0.5
			sfx(16)
		else
			b.pc = 12
		end	
		initparticle(b.x+rnd(5)-rnd(5),p1y+rnd(5)-rnd(5),rnd(2)-1,rnd(2)-1,3,b.pc)
		del(bullets,b)
	end

	if(circcoll(b.x,b.y,p1x+4,p1y+4,b.size,p1shieldsize)==true and p1shield == true)then
		initparticle(b.x+rnd(5)-rnd(5),p1y+rnd(5)-rnd(5),rnd(2)-1,rnd(2)-1,3,12)
		p1shieldsize-=0.1
		shake+=0.1
		sfx(15)
		del(bullets,b)
	end
	
	if b.timer >=b.ltimer then
	 	del(bullets,b)
	 	initparticle(b.x,b.y,rnd(2)-1,rnd(2)-1,1+rnd(2),b.col) 
	end	
end

function scenemanager()
	if senum == 0 then
		startscreenupdate()
	end

	if senum == 1 or senum  == 2 then
		fightmanager()
		if p1hp > 0 and showwin == false and showlose == false then
			playerupdate()
			if senum == 1 then 
				a_spawner() 
			else 
				e_spawner()
			end
		end
	end
end

--init-------------------------------------------------------------------------
function _init()
	cartdata("elstiskalinjen_fezier")
	lockedlevel = dget(0)
	if(lockedlevel == 0)lockedlevel=1
	mouse.init()
	score = dget(1)
	p1dificulty = dget(2)
	if dget(3) == 1 then p1autofire = true else p1autofire = false end
	if(p1dificulty == 0)p1dificulty=2
end

---update----------------------------------------------------------------------
function _update60()
	mouse.update()
	mx,my=pntc()
	foreach(particles,updateparticle)
	foreach(lasers,updatelaser)
	foreach(circles,updatecircle)
	foreach(bullets,updatebullet)
	foreach(scrubs,updatescrub)	 

	scenemanager()
end

--draw-------------------------------------------------------------------------
function _draw()
	cls()
	treshold = stat(1)
	if(senum>=0)map(0, 0, 0, 0, 128, 128)
	if(senum>0 and tcounter <= 3)tutorial()
	foreach(circles, drawcircle)
	foreach(particles, drawcircpart)
	foreach(lasers, drawlaser)
	foreach(bullets, drawcircpart)
	foreach(scrubs, drawscrub)
	drawstartscreen()
	drawbattle()
end

-------------------------------------------------------------------------------
tm=20
tcounter=0
function tutorial()
	if level == 1 and lockedlevel == 1 then
		print("-----controls------\nmove with mouse\nleft click to shoot\n-------------------",25,90,7)
		if(pntp()==true)tcounter+=1
		spr(33,90,81)
		showplayer()
		spr(14,tm,81)
	end
	
	if level == 2 and lockedlevel == 2 then
		if(btn(4))tcounter+=0.1
		print("--------------------\nhold z/Ž to stop\n--------------------",25,90,7)
		spr(14,97,95)
	end
	
	if level == 3 and lockedlevel == 3 then
		print("--------------------\nright click mouse\nor hover over player\nto shield\n--------------------",20,90,7)
		spr(14,90,81)
		if(p1shield == true)tcounter+=0.1
		showplayer()
		if(tm > 80)spr(107,86,77,2,2)
		spr(33,tm,81)
	end

	if level == 4 and lockedlevel == 4 then
		if(btnp(5))tcounter+=3
		print("----------------------\npress x/Ž to teleport\nto mouse position\n----------------------",20,90,7)
		spr(33,90,81)
		showplayer()
		spr(15,tm,81)
	end
end

function showplayer()
	if tm < 88 then
	 	tm=lerp(tm,90,0.015)
	 else
	 	if(tcounter <= 3)tm=20
	 end
end

function drawstartscreen()
	if senum==0 then
		--all rect on start
		rect(ax,ay,(ax+w),(ay+h),7)
		rect(ex,ey,(ex+w),(ey+h),7)
		rect(tx,ty,(tx+w),(ty+h),7)
		rect(abx,aby,(abx+w),(aby+h),7)

		spr(96,110,logoy,2,2)--logo
		spr(98,108,logoy+15,2,2)
		spr(100,108,logoy+30,2,2)
		spr(102,110,logoy+45,1,2)
		spr(98,108,logoy+60,2,2)
		spr(103,109,logoy+75,2,2)
		spr(132,109,logoy-15,2,2)

		if nenum == 0 then--start
			print("arcade",ax+8,ay+8,ac)
			print("endless",ex+8,ey+8,ec)
			print("options",tx+8,ty+8,tc)
			print("about",abx+8,aby+8,abc)
			spr(33,mx,my)
		end

		if nenum > 0 and ax > 115 then
			print("b\n\n\n\na\n\n\n\nc\n\n\n\nk",123,25,7)
		end

		if ax > 115 then
			if nenum == 1 then--arcade
				spr(82, 4, 4, 2, 1)
				print("arcade", 20, 6, 7)
				print("01 02 03 04 05 06 07 08 09",5,30,ac1)
				for i=1,9 do 
					if((lockedlevel) >= i+1)then
						spr(24,-8+i*12,38) 
					else
						if(i>lockedlevel)spr(27,-8+i*12,38)
					end
				end

				print("10 11 12 13 14 15 16 17 18",5,60,ac2)
				for i=1,9 do
					if((lockedlevel-10) >= i)then
						spr(23,-8+i*12,68)
					else
						if(i>lockedlevel-9)spr(26,-8+i*12,68)
					end
				end
				print("19 20 21 22 23 24 25 26 27",5,90,ac3)
				for i=1,9 do 
					if((lockedlevel-19) >= i)then
						spr(22,-8+i*12,98) 
					else
						if(i>lockedlevel-18)spr(25,-8+i*12,98) 
					end
				end

				rect(73,5,105,18,7)
				if(lockedlevel > 9)spr(18,76,8)
				if(lockedlevel > 18)spr(19,85,8)
				if(lockedlevel > 27)spr(20,95,8)
				if mx < 108 then 
					spr(28, selx, sely)
				end
		elseif nenum == 2 then--endless
			spr(80, 4, 4, 2, 1)
			print("endless", 22, 6, 7)
			print("your highscore:"..score, eny - 30, eny - 6, 7)

			rect(enx,eny,enx+enw,eny+enh,7)
			if enc == 7 then 
				print("      go?",enx+enw/5,eny+enh/2.5,enc) 
			else 
				print("gooooooooooooo!",enx+enw/5,eny+enh/2.5,enc) 
			end

			if enc == 3 then
				if(lockedlevel < 28) then 
					print("i recommend you to play\nthe whole arcade to\nprepare for this!",12,105,7) 
				else 
					print("you are ready for this,\n      good luck!",12,58 + eny, 7)
				end
			end

			rect(73,5,104,18,7)
			if(score >= 100)spr(36,75,8)
			if(score >= 200)spr(37,85,8)
			if(score >= 300)spr(38,95,8)
		elseif nenum == 3 then--option
			spr(84, 4, 4, 2, 1)
			print("options", 22, 6, 7)
			print("\n\n\nauto fire:\n\n\n\n\ndifficulty:",5,5,7)
			
			if showcontrols == true then
				rect(5,87,105,123,7)
				print("move with mouse\nleft click to shoot\nz/Ž to stop\nx/— to teleport\nright click to shield",11,91,7)
			else
				rect(5,87,105,99,7)
				print("     show controls!",8,91,7)
			end

			rect(autonx,autony,autonx+ow,autony+oh,autonc)--auto on 
			print("on",autonx+10,autony+5,autonc) 
				
			rect(autoffx,autoffy,autoffx+ow,autoffy+oh,autoffc)--auto off
			print("off",autoffx+9,autoffy+5,autoffc) 

			rect(d1x,d1y,d1x+ow,d1y+oh,d1c)
			print("easy",d1x+8,d1y+5,d1c) 
				
			rect(d2x,d2y,d2x+ow,d2y+oh,d2c)
			print("medium",d2x+4,d2y+5,d2c) 

			rect(d3x,d3y,d3x+ow,d3y+oh,d3c)
			print("hard",d3x+8,d3y+5,d3c) 

		elseif nenum == 4 then--about
			spr(86, 4, 4, 2, 1)
			print("about", 22, 6, 7)
			print("\n\n\n\n\nfezier was made by \n\nsebastian lind\n\ntwitter:@elastiskalinjen\n\n\n\nthank you for playing!",5,5,7)
			line(5,92,90,92,7)
			if(lockedlevel >27)print("|you have won the arcade|\n|   you are awesome!    |",5,112,9)
			spr(128,75,25,4,4,true)
		end		
		end

		if(nenum ~= 0)spr(34,mx,my)		
	end
end

tim = 0
function initword(word, x, y, height, speedLimiter, color)
	tim += 0.5
	for i=0, #word, 1 do
		print(sub(word, i, i), x + (i * 4), y + sin((tim + i) / speedLimiter) * height, color)
	end
end

function drawbattle()
	if senum == 1 or senum == 2 then
		if showlose == false and showwin == false then
			if p1stop == false and p1shield == false then
			 	if p1invurnable == true then spr(16,p1x,p1y) else spr(p1a_fr,p1x,p1y,1,1,p1fl) end
			else
			 	if p1invurnable == false then spr(6,p1x,p1y) else spr(16,p1x,p1y) end
			end

			if p1canteleport == false then spr(5,p1x+cos(p1trot)*6,p1y+sin(p1trot)*7) else spr(21,p1x+cos(p1trot)*6,p1y+sin(p1trot)*7) end
			if p1delay == false then spr(3,p1x+cos(p1anglemp)*7,p1y+sin(p1anglemp)*7) else spr(4,p1x+cos(p1anglemp)*7,p1y+sin(p1anglemp)*7) end
			if(p1shield == true)circ(p1x+4,p1y+4,p1shieldsize,12)
		 end

		doshake()
		if p1invurnable == false then
		 	if p1shield == false then 
			 	spr(1,mx,my) 
			else 
				spr(17,mx,my) 
			end
		else
		 	spr(32,mx,my)
		end

		if (showwin == false and showlose==false) and (p1invurnable == true or set == false) then
		 	for i=1,p1hp do spr(13,p1x+i*8-12,p1y-20) end
		end

		if pause == true and #scrubs == 0 and showlose==false then
		 	print("wave "..wave.." cleared!",34,60,0)
		 	if(pausedelay < 290)rect(0,0,127,127,8)
		 	if(pausedelay > 20 and pausedelay < 280)rect(1,1,126,126,9)
		 	if(pausedelay > 30 and pausedelay < 270)rect(2,2,125,125,10)
		 	print("score:"..p1score,44,118,7)
		 end

		 if showwin == true then
		 	initword("you won!", 44, 60, 8, 28, 10) 
		end

		 if showlose == true then
		 	if senum == 1 then
			 	initword("you lost!", 40, 60, 8, 28, 8) 
		 	else
				initword("your score:" ..p1score, 32, 60, 8, 28, 9) 
		 	end
		 end
	end
end

------functions----------------------------------------------------------------------------
function movetowards(x1, y1, x2, y2, speed)
	local newangle=calcangle(x1,y1,x2,y2)
	x2+=speed*cos(newangle)
	y2+=speed*sin(newangle)

	return x2,y2
end
function calcangle(x1,y1,x2,y2)
	angle = atan2(x1-x2,y1-y2)
	return angle
end
function calcdist(x1,y1,x2,y2)
 	dist=sqrt(((x2-x1)/10)^2+((y2-y1)/10)^2)*10
	return dist
end
function circcoll(x1,y1,x2,y2,rad1,rad2)
	dist = calcdist(x1,y1,x2,y2)
	if(dist < (rad1+rad2)) then return true end
end
function lerp(var,target,pow)
	return(var+pow*(target-var))
end

shake=0
function doshake()
	local shakex=16-rnd(32)
	local shakey=16-rnd(32)
	shakex*=shake
	shakey*=shake

	if(shake >=0.6)then
		if(showwin == true)pal(0,10,1)
		if(showlose == true)pal(0,8,1)
		if(p1invurnable == true)pal(0,9,1)
	else 
		pal(0,0,1)
	end

	camera(shakex,shakey)
	shake=shake*0.95
	if(shake<0.05)shake=0
end

monsterspawned=0
set=false
showwin=false
showlose=false
showcounter=0
stoploop=false
loopc=0
msetx=0
spawnlist={}
background=0
endlesstile=49
function fightmanager()
	if set == false then--set up the level spawn
		if senum == 1 then
			spawnlist = levels[level]
			monsterspawned = #spawnlist-1
			background = 48+level
		else
			monsterspawned = 1 -- just to not triggering the win/lose condition,lack of tokens...
			background=endlesstile+rnd(9)
		end
		p1hp=4-p1dificulty
	end
	
	if stoploop == false and msetx <= 15 then--set up the level background
		stoploop = true
		for i=0,15 do mset(msetx, i, background) end
		if msetx < 15 then msetx+=1 else set = true end
	end
	if(stoploop == true)loopc+=1
	if loopc >= 7 then
		stoploop = false
		loopc=0
	end

	if set == true and p1hp <= 0 and showlose == false and showwin == false then--show lose
		showlose = true
		sfx(11)
		shake+=1
		if(p1score > score and senum == 2)then
			score = p1score
			dset(1,score)
		end
		for i=0,70 do initparticle(p1x-rnd(5)+rnd(5),p1y-rnd(5)+rnd(5),rnd(10)-5,rnd(10)-5,5+rnd(3),8) end
		for s in all(scrubs) do s.hp = 0 end
	end

	if set == true and #scrubs == 0 and monsterspawned == 0 and showwin == false and showlose == false then--show win
		showwin = true
		sfx(12)
		shake+=1
		for i=0,80 do initparticle(p1x-rnd(5)+rnd(5),p1y-rnd(5)+rnd(5),rnd(10)-5,rnd(10)-5,5+rnd(3),10) end
		for i=0,5 do initcircle(p1x-4,p1y-4,0,40+(i+i),0.6+(i/10),7) end
		if(level == lockedlevel)lockedlevel+=1
		dset(0, lockedlevel)
	end

	if(showwin == true or showlose == true)showcounter+=1

	if showcounter >= 110 and set == true then--reset
		if senum == 1 then nenum=1 else nenum=2 end 
		senum=0
		showwin=false 
		showlose=false
		p1score=0
		p1x = 64
		p1y = 64
		p1hp=4-p1dificulty
		p1dificulty = olddificulty
		p1invurnable = false
	 	p1icounter = 0
		set=false
		msetx=0
		tcounter=0
		tm=20
		spawnrate=100
		randscrub=30
		for s in all(scrubs) do del(scrubs,s) end
		for b in all(bullets) do del(bullets,b) end
		pause=false 
		pausedelay=0 
		wave=0 
		wavecounter=0 
		wavethreshold=10
		tim = 0
		if endlesstile == 49 then endlesstile=58 else endlesstile=49 end

		showcounter=0
		for i=0,15 do 
			for j =0,15 do 
				mset(i,j,48)
			end
		end
	end
end

spawn=false spawncounter=0
spawnx=0 spawny=0
function a_spawner()--arcade spawner
	if spawn == false then
		spawn = true
		spawnonsides()
		if monsterspawned > 0 and set == true then
			enemyindex(spawnlist[#spawnlist-monsterspawned+1])
			monsterspawned-=1
			spawncheck = false
			sfx(7)
			for i=0,4 do initparticle(spawnx-rnd(5)+rnd(5),spawny-rnd(5)+rnd(5),rnd(2)-1,rnd(2)-1,3+rnd(3),scrubs[#scrubs].col) end
		end
	end
	spawntimer()
end

spawnrate=100 randscrub=30
pause=false pausedelay=0 wave=0 wavecounter=0 wavethreshold=10
function e_spawner()--endless spawner
	if spawn == false and pause == false then
		spawn = true
		spawnonsides()
		if(spawnrate > 50)spawnrate-=0.10

		if set == true then
			enemyindex(scrubpicker())
			if(randscrub < 100)randscrub+=1
			wavecounter+=1
			spawncheck = false
			sfx(7)
			for i=0,4 do initparticle(spawnx-rnd(5)+rnd(5),spawny-rnd(5)+rnd(5),rnd(2)-1,rnd(2)-1,3+rnd(3),scrubs[#scrubs].col) end
		end
	end
	spawntimer()

	if wavecounter == wavethreshold and pause==false then
		pause=true
		wave+=1
	end
	if pause==true and #scrubs == 0 then
		initparticle(30+rnd(65),60,rnd(2)-1,rnd(2)-1,4+rnd(4),8+flr(rnd(3)))
		for b in all(bullets) do del(bullets,b) end
		pausedelay+=1
		if pausedelay <=1 then
			shake+=0.3
			sfx(20)
		end
		if pausedelay >=300 then
			pause = false
			pausedelay=0
			wavecounter=0
		end
	end
end

function scrubpicker()--for endless, all enemies have different chances to be spawned
	dice=rnd(randscrub)

	if dice < 30 then--30
		index = 1
	elseif dice >= 30 and dice < 50 then--20
		index = 2
	elseif dice >= 50 and dice < 70 then--20
		index = 3
	elseif dice >= 70 and dice < 80 then--10
		index = 4
	elseif dice >= 80 and dice < 85 then--5
		index = 5
	elseif dice >= 85 and dice < 90 then--5
		index = 6
	elseif dice >= 90 and dice < 95 then--5
		index = 9
	elseif dice >= 95 and dice < 97 then--2
		index = 7
	elseif dice >= 97 and dice < 99 then--2
		index = 8
	elseif dice >= 99 and dice < 100 then--1
		index = 10
	end

	return index
end

spawncheck=false
function spawnonsides()--gets the position to spawn
	while spawncheck == false do
		local updownleftright = flr(rnd(4))
			if updownleftright == 0 then--right
				spawnx = 126
				spawny = rnd(128)
			elseif updownleftright == 1 then--left
				spawnx = 2
				spawny = rnd(128)
			elseif updownleftright == 2 then--up
				spawnx = rnd(128)
				spawny = 2
			elseif updownleftright == 3 then--down
				spawnx = rnd(128)
				spawny = 126
			end
		if circcoll(p1x+(p1w/2),p1y+(p1h/2),spawnx,spawny,4,8) == true then
			spawncheck = false
		else
			spawncheck = true
		end
	end
end

function spawntimer()--different between maps/modes
	if(spawn == true)spawncounter+=1
	if senum == 1 then--arcade
		if spawncounter >=spawnlist[1] then
			spawncounter=0
			spawn = false
		end
	else--endless
		if spawncounter >= spawnrate then
			spawncounter=0
			spawn = false
		end
	end
end

--x, y, col, dcol, dist, speed, size, state, hp, cd
function enemyindex(index)--spawn scrub according to the index 
	if index == 1 then
		spawnscrub(spawnx,spawny,11,3,400,0.3,4,1,1,0) --normal
	elseif index == 2 then
		spawnscrub(spawnx,spawny,13, 12,60,0.25,4,2,1,90)--shooter
	elseif index == 3 then
		spawnscrub(spawnx,spawny,9,10,400,0.35,5,3,2,0)--bomb splasher
	elseif index == 4 then
		spawnscrub(spawnx,spawny,11,3,400,0.3,9,1,6,0)--big normal
	elseif index == 5 then
		spawnscrub(spawnx,spawny,12,13,400,0.32,5,4,2,160)--charger
	elseif index == 6 then
		spawnscrub(spawnx,spawny,14,2,400,0.4,7,5,2,0) --splitter
	elseif index == 7 then
		spawnscrub(spawnx,spawny,8,9,2,0.6,10,6,5,180) --waver
	elseif index == 8 then
		spawnscrub(spawnx,spawny,15,7,60,0.2,6,7,2,180) --sniper
	elseif index == 9 then
		spawnscrub(spawnx,spawny,7,15,100,0.3,7,8,3,120) --spawner
	elseif index == 10 then
		spawnscrub(spawnx, spawny, 5, 0, 400, 0.15, 17, 9, 15, 240) --last boss
	end
end

--first number is the spawn-delay
lv1={160,1,1,1,1,1}
lv2={80,1,1,1,1,1,1,1,1,1,1}
lv3={70,1,1,1,1,1,2}
lv4={70,2,1,2,1,1,2}
lv5={50,2,2,2,2,2}
lv5={50,3,1,3,1,3,1,1,3}
lv6={40,1,2,3,1,2,1,4}
lv7={15,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4}
lv8={90,1,2,3,1,2,3,1,2,3}
lv9={60,4,3,2,4,2,3,1,4}

lv10={50,5,1,1,1,1,1,1,1,1,5}
lv11={10,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
lv12={70,6,1,3,1,6,1,6}
lv13={80,1,2,3,4,5,6}
lv14={80,1,6,2,6,3,6}
lv15={50,3,3,3,3,3,3,3,3,3}
lv16={60,6,4,3,2,1,1,3,2,1,5}
lv17={60,1,7,1}
lv18={100,2,3,3,4,7,3,3,1}

lv19={50,2,2,2,2,2,2,2,2,2}
lv20={75,8,1,1,1,8,1,1,1,8}
lv21={70,8,1,4,1,1,3,8,3}
lv22={75,9,1,9,1,1,5,1,1,9}
lv23={85,9,1,9,2,1,9,1,2,3,9}
lv24={80,1,2,3,4,1,1,1,5,6,6,8}
lv25={100,7,1,1,1,2,1,2,1,1,6,1,1,2,1,1,2}
lv26={170,9,8,7,6,5,4,3,2,1}
lv27={70,10}

levels={lv1,lv2,lv3,lv4,lv5,lv6,lv7,lv8,lv9,
	   lv10,lv11,lv12,lv13,lv14,lv15,lv16,lv17,lv18,
	   lv19,lv20,lv21,lv22,lv23,lv24,lv25,lv26,lv27}
__gfx__
000000000888888000000000000000000000000000000000000220000002200000022000000220000002200000022000000220000088880000077000000bb000
000000008000000800000000000000000000000000000000000ff000000ff000000ff000000ff000000ff000000ff000000ff0000881a9a000077000000bb000
007007008000000800077000000dd000000880000000000000c11c007cc11cc77cc11cc77cccccc77cccccc7fcccc000fcccc0000288889a00777700bbbbbbbb
00077000800890080075570000d61d00008928000003b0000cc11cc000c11c0000c11c0000cccc0000cccc00000cc000000cc0000e2222290777777000bbbb00
00077000800980080075570000d11d0000822800000b300007c11c7000c11c0000c11c0000cccc0000cccc00000cc000000cc00002e222290777777000bbbb00
007007008000000800077000000dd000000880000000000000dddd0000dddd0000dddd0000dddd0000dddd00000ddd00000dd0000e2222290077770000bbbb00
00000000800000080000000000000000000000000000000000d00d0000d00d0000d00d0000d00d0000d00d0009dd00d0000dd00000e222090070070000b00b00
00000000088888800000000000000000000000000000000000900900000009000090000000000900009000000000009000099000000000900070070000b00b00
000990000c7007c000c77c0000b77b00002772000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000aa000c000000c00c77c0000b77b00002772000000000007a7aaa0079799900a8a88800a0000a0090000900800008000000000000000000000000000000000
00a77a0070000007004444000066660000999900000000000aaaaaa0099999900888888000a99a00009889000089980000000000000000000000000000000000
0aa77aa0000000000445544006655660099889900005600007aaaaa0079999900a8888800097a900008a98000096890000099000000000000000000000000000
07a77a7000000000045765400656d5600987a8900006500009aaaa900899998002888820009aa900008998000098890000882900000000000000000000000000
009999007000000704566540065dd560098aa89000000000009aa900008998000028820000a99a00009889000089980000822290000000000000000000000000
00900900c000000c044554400665566009988990000000000009900000088000000220000a0000a0090000900800008077777777000000000000000000000000
00a00a000c7007c00044440000666600009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077007700770077077777700000640000007600000079000100100010022000005050050111111100111111100000000000000000000000000000000
00700700700000077000000767777000004554000065560000988900000111100002200255000050111111011011111100000000000000000000000000000000
09099090707777077000000767777000065765400756d5600787a890001011002000220250055000111110111101111100000000000000000000000000000000
0090090000700700000000006777770045766654656ddd56987aaa89100000012200200050050505111101111110111100000000000000000000000000000000
009009000070070000000000666677704566665465dddd5698aaaa89101000010220202050550500111011111111011100000000000000000000000000000000
090990907077770770000007600667774566665465dddd5698aaaa89001111000020020200050505110111111111101100000000000000000000000000000000
00700700700000077000000700006677025555200d5555d002888820000110000202200205055055101111111111110100000000000000000000000000000000
000000000770077007700770000006670022220000dddd0000222200100110010200002005000000011111111111111000000000000000000000000000000000
01111111111110011001010111000001000000000000000011111111111111111111111110000001222002220220022002200220222222222220022200222200
10111111111101100011110110000000011111100111111010000001100110011100001100000000200220022000002222000022200000022002200202202222
11011111001100111111010000000001010110100101101010100101101001011011110100100100202002022020020220000002222222222020020220022022
11101111110001010100011110000001011111100111111010000001110110111010010100000000020220200002200000022000202222020200002020202020
11110111110111001111010110000000011111100001001010000001110110111010010100000000020220200002200000022000202222020200002002202200
11111011001111011001110100000001010110100100010010100101101001011011110100100100202002022020020220000002222222222020020202200222
11111101100110011011011010000001011111100111111010000001100110011100001100000000200220022200002222000022200000022002200220002200
11111110100101101100110010010110000000000000000011111111111111111111111110000001222002220220022002200220222222222220022222222022
00000000000000000000000055555555555555550000000055555555055555505000005022222222122112211000000100000000000000000000000000000000
02000020002020200020222050000005550000550555555050500055550000550050000020211202221111220011110000000000000000000000000000000000
00200200000202000200000050050005505555050505505050505555500000050000505021222212212222120101101000000000000000000000000000000000
00000000020020200000022050505055505050050555555055555505500000050500000020200202112002110111111000000000000000000000000000000000
00000000002002000222000055050505505555050500005055000505500000050050500520200202112002110111111000000000000000000000000000000000
00200200020200200000002050005005505555050500005055555555500000055000050021222212212222120101101000000000000000000000000000000000
02000020002020000202220050050005550000550555555050500005550000550050005020211202221111220011110000000000000000000000000000000000
00000000000000000000000055555555555555550000000055555555055555500500500022222222122112211000000100000000000000000000000000000000
0c7cccc00cc7ccc00000000a9900000000760000000000000000008882290000009a9900a0aa00a0000000000000000000000000000000000000000000000000
cc0000ccc70000cc000088822292000007006000000000000000088882209000aa111199a0a0a0a0000000000000000000000000000000000000000000000000
7000000c7000000c0008888222922000660066666666666600000888882090000aa99990a0a00aa0000000000000000000000000000000000000000000000000
7000000cc000000c0008882222992000006600000000000000000fffffe00a0000aa9900a0a000a0000000000000000000000000000000000000000000000000
7000000cc000000c0008888222292000000000000007600000000fffffe00000000a900000000000000000000000000000000000000000000000000000000000
c000000cc000000d00088882222a90000000000000700600000cc111111cc000000a900000000000000000000000000000000000000000000000000000000000
ddd000dddc0000cd00088822222a9000666666666660066600ccc111111ccc0000aa990000000000000000000000000000000000000000000000000000000000
0dddddd00dddddd0000888822222200000000000000660000cccc111111cccc00aa9999000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000006666666600000000000000000000000000000000000000000000
0077777777770000007777777777000000777777777700000077777707777777770000000006d776677d60000000cccccccc0000000000000000000000000000
007000000007000000700000000700000070000000070000007000070700000000700000006d77766777d600000cc000000cc000000000000000000000000000
007000000007000000700000000700000070000000070000007000070700000000070000006777766777760000c0000000000c00000000000000000000000000
00700000000700000070077777770000007777770007000000700007070000000007000000677766667776000cc0000000000cc0000000000000000000000000
00700077777700000070070000000000000000070007000000700007070000000007000000677765567776000c000000000000c0000000000000000000000000
00700070000000000070077777770000000000700070000000700007070000000070000000676665566776000c000000000000c0000000000000000000000000
00700077770000000070000000070000000007000700000000700007070000000700000000666665566666000c000000000000c0000000000000000000000000
00700000070000000070000000070000000070007000000000700007070000007000000000677d6666d776000c000000000000c0000000000000000000000000
007000000700000000700777777700000007000700000000007000070700000007000000006777d66d7776000c000000000000c0000000000000000000000000
00700077770000000070070000000000007700700000000000700007070007700070000000d7777667777d000c000000000000c0000000000000000000000000
00700070000000000070077777770000007000777777000000700007070007070007000000d7777777777d000cc0000000000cc0000000000000000000000000
00700070000000000070000000070000007000000007000000700007070007070000700000d7777777777d0000c0000000000c00000000000000000000000000
007000700000000000700000000700000070000000070000007000070700070070000700006d77777777d600000cc000000cc000000000000000000000000000
0077777000000000007777777777000000777777777700000077777707777700077777000006d777777d60000000cccccccc0000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000006666666600000000000000000000000000000000000000000000
0000000000000000000000000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d61d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d11d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000eefff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000099000000000111000000000000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000092888000000ccc0000000000088882992000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000092888800000ccc0000000000888222292200000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000090288880000ccc00000000000888822292200000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000090effff000ccc000000000000888822292200000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000effff00cccc000000000000888222299200000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ccc11111ccccc0000000000000888822229200000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccc11111cccc00000000000000888822229900000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000ccccc11111cccd00000000000000888222229900000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000ccccc11111ccd000000000000000888822222200000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cccccc11111cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ccdccc11111cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cc0dcc11111cc0b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cc0ccc11111cc03b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000110ccc11111cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ef0ccc11111cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ef6d6ddddddd60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddddddd6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dd500005ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055000000dd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dd0000005d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dd0000005d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aa000000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aa000000aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00050000010101b000130001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000177101c720227300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000010010150100d0402c70007700157000170000000367000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000301005010090100b02000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000502001010050200101005020010100502001010050200101004020010100402001010040200101004020010100402001010040200101004020010100402001010040200101004020010100502001010
0005000023010280202f0301800022000260002c00032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000071100c030070100471002710017000170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f0201202014020180201a0201e0200b0200b0200d010100101201014010160100201001000020000100021000220002400025000250002500027000290002a0002c000150002e000300003100033000
0003000016030120200f0200b0200602001010080000b0000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000036040330402d0402a040250401e030180301603014030110300d0200a0200701005010030100400006000070000700000000070000700000000070000600006000060000000000000000000000000000
0008000024120211201e1201c1101911018110111101411012110111100e110081100a110081100511004110021100111001100181001010001100081000e1000d1000b1000e100091000b100081000810008100
00060000040100401005010050100601008010090100a0100d0100e010100101011014110171101c1102111024110271102e110301002a1102e11032210001000010000100001000010000100001000010000100
000100001453010520005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000f01012020180500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002e02021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002c0501a050120501305000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000085100a5200d5200f52011520145300050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000160400b0400b0000a0000f00014000170001c00012000110001000015000120000d0000b0000c0000e0000e0000f0001000007000070000f000100001000006000090000b000080000e0000f00007000
000100000703000000000000903000000100300000000000000001203000000000001503000000000000f030000000c030000000b030060000603007030070000803009020080200b0200b0100c0100d0100f010
000700000e0200f0201102014030100201102012020130201402016020180201c0300000018030000001b0301f030230302c05000000000000000000000000000000000000000000000000000000000000000000
000800000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00000901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000006010000000fc0011c000fc0011c000dc0011c000dc000fc001fc001fc001fc001fc000dc0012c000dc000fc000000000000000000000000000000000000000000000000000000000000000000000000
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
