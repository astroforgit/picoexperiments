pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--init

function _init()
	debug={}
	acc=0
	t=0
	hud_shake=0
	cls()
	
	-- fade colors
 dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
 
	dirx={-1,1,0,0,1,1,-1,-1}
	diry={0,0,-1,1,-1,1,1,-1}
	
	mob_idle={112,64,80,83,110}
	mob_idle_f={2,4,2,2,2}

	mob_atk={1,0,1,1,1}
	mob_hp={3,1,1,1,1}
	
	mob_tasks={nil,ai_hatch,ai_attack,ai_attack,ai_attack}
	mob_wait={0,8,1,0,0}
	
	mat_idle={
		{118,118,118,118,118,118,118,119,120,121,122,123},
		{093,094},
	}
	
	mat_speed={4,40}
	
	def_idle={
		{096,097},
		{114,115},
		{125,126}
	}
	
	def_disable={
		{100},
		{115},
		{127}
	}
	
	def_fire={
		{098,099},
		{116,117},
		{125,126},
	}
	
	def_cost={1,1,1}
	def_r={10,3,0}
	def_wait={0,4,0}
	
	tips={
		"reds reproduce...fast",
		"upgrade your turrets",
		"step on a turret",
		"‡life is precious‡",
		"’you are the weapon’",
		"don't let them spread",
		"ˆ try to sleep ˆ",
		"maybe there is a cure",
		"virush die attacking you",
		"“ take it slow “",
		"you move, they move",
		"do it for them ‡",
		"tu tu tu",
		"don't forget the bombs",
		"drop a bomb and run",
		"eggs can't hurt you",
		"attack while they lay",
		"a quarantine has 40 nights",
		"you can heal in hospitals",
		"dangerous is the night",
		"think your next move",
	}

	mats_wait=get_mats_wait()
	
	day_label={1,2,3,4,5,6,7,8,9,10,15,20,23,31,38,40}
	
	start_game()
end

function _update60()
	t+=1
	_upd()
	doparts()
	dofloats()
end

function _draw()
	_drw()
	d_hud()
	
	for part in all(parts) do
		d_part(part)
	end
	
	checkfade()
end 

function start_game(fast)
	cls()
	day=0
	max_day=15
	setmapcoords()

	exit=nil
	show_hud=false
	p_def=1
	xi=0
	yi=0

	floats={}
	marks={}
	parts={}
	p=nil
	p_cure=0
	m_kill=0
	turrets=0
	bombs=0
	life_lost=0
	
	vcntr=61

	--deadmobs
	dmob={}
	fadeperc=1
	tips=shuffle(tips)

	if fast then
		_upd=u_day
		_drw=d_day
	else
		_upd=u_title
		_drw=d_title
	end
	
	
	music(1)
end

function spawnthings()
	acc+=1
	a_t=0
	buttbuff=-1
	mob={}
	def={}
	mats={}
	decals={}
	med_blocks={}
	
	local x = mapx
	local y = mapy

	for x=x,mapx+15 do
		for y=y,mapy+15 do
			spawn(x,y,xi,yi)
		end
	end
	
	if not p then
		p = addmob(1,6,6)
		p.mat=0
		p.hp=3
	end
end

function spawn(x,y)
	--add(debug,"["..x.."-"..y.."]")
	--player
	
	local sx=x-mapx
	local sy=y-mapy
	local tl=mget(x,y)
	
	if tl == 95 then
		local oldhp= p and p.hp or mob_hp[1]
		local oldmat= p and min(2,p.mat) or 0
		p = addmob(1,sx,sy)
		p.mat=oldmat
		p.hp=oldhp
	elseif tl == 64 then
		-- egg
		addmob(2,sx,sy)
	elseif tl == 80 then
		-- spider
		addmob(3,sx,sy)
	elseif tl == 83 then
		-- green
		addmob(4,sx,sy)
	elseif tl == 110 then
		-- red
		addmob(5,sx,sy)
	elseif tl == 96 then
		-- turret
		adddef(1,sx,sy)
	elseif tl == 114 then
		-- bomb
		adddef(2,sx,sy)
	elseif tl == 125 then
		-- hospital
		adddef(3,sx,sy)
	elseif tl == 118 then
		-- material
		addmat(1,sx,sy)
	elseif tl == 093 then
		-- cure
		addmat(2,sx,sy)
	elseif tl == 56 then
		addmed(sx,sy)
	else
		return
	end
	
	mset(x,y,0)
end

function setmapcoords()
	mapx=day%8
	mapx*=16
	mapy=day\8
	mapy*=16
end
-->8
--update

function u_title()
	if btnp(—) then
		--menu button
		sfx(46)
		fadeout(0.02)
		a_t=0
		i_story(get_intro_txt())
		_upd=u_story
		_drw=d_story
	end
	
	if btnp(Ž) then
		sfx(46)
		fadeout(0.02)
		a_t=0
		start_game(true)
	end
end

function u_day()
	if(a_t == 0) then
		cls()
		parts={}
	end
	
	a_t=min(a_t+0.0125,1)
	
	if a_t == 1 then
		exit=nil
		show_hud=true
		spawnthings()
		fadeout(0.02)
		_upd=u_game
		_drw=d_game
	end
end

function u_win()
	if btnp(—) then
		--menu button
		sfx(46)
		fadeout()
		start_game(true)
	end
	
	if btnp(Ž) then
		--menu button
		sfx(46)
		fadeout()
		start_game()
	end
end

function u_game()
	dobuttbuff()
	dobutt(buttbuff)
	buttbuff=-1
	dodeftarget()
end

function u_gover()
	if btnp(—) then
		--menu button
		sfx(46)
		fadeout()
		start_game(true)
	end
	
	if btnp(Ž) then
		--menu button
		sfx(46)
		fadeout()
		start_game()
	end
end

function u_pturn()
	dobuttbuff()
	a_t=min(a_t+0.125,1)
	
	p:mov(p)

	if a_t == 1 then
		domats()
		
		if p.ani_call then
			p.ani_call()
			p.ani_call=nil
		end

		if isalive() then
			_upd = u_game
			dodef()
		end
	end
end

function u_dturn()
	dobuttbuff()
	a_t=min(a_t+0.125,1)

	for d in all(def) do
		if d.mov then
				d:mov()
		end
		
		if d.ani_call and a_t == 1 then
			d.ani_call()
			d.ani_call=nil
		end
	end
	
	if a_t == 1 then
		a_t=0
		doai()
	end
end


function u_aiturn()
	dobuttbuff()
	a_t=min(a_t+0.125,1)

	for m in all(mob) do
		if m!=p and m.mov then
				m:mov()
		end
		if 
			m!=p and 
			m.ani_call and
			a_t == 1
		then
			m.ani_call()
			m.ani_call=nil
		end
	end
	
	if a_t == 1 then
		if isalive() then
			_upd = u_game
			a_t=0
		end
	end
end

function dobuttbuff()
	if buttbuff == -1 then
		buttbuff=getbutt()
	end
end

function getbutt()
	for i=0,5 do
		if btnp(i) then
			return i
		end
	end
	return -1
end

function dobutt(b)
	if b<0 then return end
	
	if b<4 then
		p_mov(dirx[b+1],diry[b+1])
		return
	end
	
	if b == 5 then
		local up = up_def(p.x,p.y)
		local bld = build_def(p.x,p.y)
		if not  up and not bld then
			hud_shake+=1
			sfx(56)
		end
	end
	
	if b == 4 then
		--swap item
		sfx(49)
		p_def=next_def(p_def)
		spawn_parts(p.x,p.y,{7,14,8})
	end
	
	-- menu button
end

function up_def(x,y)
	local d = getdef(x,y)
	if(not d)return false
	local cost = def_cost[p_def]
	if(cost > p.mat)return false
	if(d.typ == 2)return false
	if(d.disable)return false

	if d.typ == 1 then
		--upgrade turret
		sfx(61)
		d.r += 5
	elseif d.typ==2 then
		--d.r += 1
	elseif d.typ==3 then
		--regain health
		sfx(54)
		spawn_parts(p.x,p.y,{11,3})
		p.hp = min(p.hp+1,3)
		d.task=d_disable
		d.disable=true
	end
	
	p.mat -= cost
	spawn_parts(x,y,{6,13})
	return true
end

function build_def(x,y)
	local d = getdef(x,y)
	if(d)return false
	local cost = def_cost[p_def]
	if(cost > p.mat)return false
	p.mat -= cost
	adddef(p_def,x,y)
	spawn_parts(x,y,{6,13})
	
	if p_def == 1 then
		sfx(48) --build turret
		turrets+=1
	elseif p_def == 2 then
		sfx(47) --place bomb
		bombs+=1
	end

	return true
end
-->8
--draw

function d_title()
	--cls(0)
	noise({0,1},100)
	local txt="press — to start"
	local x = hcntr(txt)
	local y = vcntr
	local plt = {4,9,10}
	local c = plt[flr((time()*5)%#plt)+1]
	d_ltrs(1,35,2)
	oprint8(txt,x,y+15,c,0)
	txt="by @afk_mario and @eljovenpaul"
	x = hcntr(txt)
	scroll_txt(txt,y+60,7,2)
end

function d_day()
	cls()
	local txt="night "..digits2(day_label[day+1])
	local x = hcntr(txt)
	local y = vcntr-30
	local plt = {4,9,10}
	local c = plt[flr((time()*5)%#plt)+1]
	print(txt,x,y,10)
	line(x-10,y+10,x+40,y+10,9)

	spr(118,x+8,y+28)
	local ms=p and p.mat or 0
	
	local ams=flr(lerp(ms,min(ms,2),a_t))
	
	print(digits2(ams),x+15,y+30)
	
	if ms > 2 then
		print("you were robbed",x-12,y+37,5)
		print("while you slept",x-12,y+43,5)
	end
	
	d_tip()
	
	if(p_cure < 1)return
	
	txt=p_cure.."/5"
	x = hcntr(txt)+3
	y = vcntr-15
	spr(093,x-10,y-2)
	print(txt,x,y,14)
end

function d_tip()
	local plt = {4,9,10}
	local c = plt[flr((time()*5)%#plt)+1]
	local txt = tips[day+1]
	local x = hcntr(txt)-3
	local y = vcntr+40
	local w=(#txt+2)*4+2
	local x1=x-4
	local y1=y-6
	local x2=x+w
	local y2=y+10
	rect(x1,y1,x2,y2,c)
	oprint8("tip",x,y1-3,9)
	print(txt,x,y,6)
end

function d_game()
	cls(0)
	map(mapx,mapy)

	if(day == 0) then
		local txt="‹”‹ƒ move"
		local tx = hcntr(txt)-12
		local ty = vcntr-60
		local c = 6
		print(txt,tx,ty,c)
		txt="— place defense"
		tx = hcntr(txt)
		ty += 8
		print(txt,tx,ty,c)
		tx = hcntr(txt)
		ty += 8
		txt="Ž swap defense"
		print(txt,tx,ty,c)
	end
	
	for dc in all (decals) do
		d_decal(dc)
	end
	
	if p_def == 2 then
		d_bomb_r(3,p.x,p.y,5)
	end
	
	for m in all(dmob) do
		if sin(time()*100)>0 then
			d_mob(m)
		end
		
		m.dur -= 1
		
		if m.dur <= 0 then
			del(dmob,m)
		end
	end
	
	for d in all(def) do
		d_def(d)
	end
	
	for mat in all(mats) do
		d_mat(mat)
	end
	
	for mb in all(med_blocks) do
		d_medblock(mb)
	end

	-- ’
	for m in all(mob) do
		if m != p then
			d_mob(m)
		end
	end
	
	d_exit()
	d_mob(p)
	
	for f in all(floats) do
		oprint8(f.txt,f.x,f.y,f.c,0)
	end
end

function d_win()
	cls()
	d_face2(48,25,1)
	local plt = {4,9,10}
	local c = plt[flr((time()*5)%#plt)+1]
	local txt="’ you won ’"
	local x = hcntr(txt) - 5
	local y = vcntr+20

	print(txt,x,20,c)
	
	d_results()
	d_menu_back()
end

function d_gover()
	cls()
	d_face(48,25,1)
	
	local txt="game over"
	local x = hcntr(txt)
	local y = vcntr
	print(txt,x,20,9)


	d_results()
	d_menu_back()
end

function d_results()
	local x = 40
	local y = 65
	local x1 = 50-20
	local x2 = 50+50
	local txt=""
	
	line(x1,y-2,x2,y-2,6)
	txt="ˆ night     "..digits2(day)
	x = hcntr(txt)
	print(txt,x,y,6)	

	txt="‚ killed    "..digits2(m_kill)
	y+=6
	print(txt,x,y,6)
	
	txt="˜ turrets   "..digits2(turrets)
	y+=6
	print(txt,x,y,6)
	txt="… bombs     "..digits2(bombs)
	y+=6
	print(txt,x,y,6)
	txt="‡ life lost "..digits2(life_lost)
	y+=6
	print(txt,x,y,6)
	
		
	txt="’ score   "..digits2(get_score())
	y+=12
	line(x1,y-6,x2,y-6,6)
	print(txt,x,y,7)
end

function d_menu_back()
	local x = 20
	local y = 127-11
	local txt="menu"
	local w = 35
	local h = 10
	dbox(x,y,w,h,7,0,"Ž")
	print(txt,x+10,y+3,7)

	
	txt="restart"
	x=60
	dbox(x,y,w,h,7,0,"—")
	print(txt,x+5,y+3,7)
end
-->8
-- tools

function get_frame(ani,speed)
	local speed = speed or 15
	return ani[flr(t/speed)%#ani+1]
end

function d_spr(_spr,_x,_y,_f,_c)
	if _c then
		palt(0,false)
		for i=1,15 do
			pal(i,_c)
		end
	end
	spr(_spr,_x,_y,1,1,_f)
	pal()
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end
 print(_t,_x,_y,_c)
end

function dist(fx,fy,tx,ty)
	local dx,dy=fx-tx,fy-ty
	return sqrt(dx*dx+dy*dy)
end

function dofade()
 local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+j*1.46)/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-0.04,0)
  dofade()
 end
end

function wait(_wait)
 repeat
  _wait-=1
  flip()
 until _wait<0
end

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
 wait(_wait)
end

function arrstr(arr,d)
	if(d==nil)d=","
	local str=""
	for i in all(arr) do
		str=str..i..d
	end
	return str
end

function blankmap(_dflt)
	local ret={} 
	if (_dflt==nil) _dflt=0

	for x=0,15 do
		ret[x]={}
		for y=0,15 do
			ret[x][y]=_dflt
		end
	end
	return ret
end

function shuffle(t)
	for n=1,#t*2 do -- #t*2 times seems enough
		local a,b=flr(1+rnd(#t)),flr(1+rnd(#t))
		t[a],t[b]=t[b],t[a]
	end
	return t
end

function hcntr(s)
  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
end

function noise(plt,spd)
 for i=1,spd do
		x = flr(rnd(127))
		y = flr(rnd(127))
		c = rnd(plt)
		pset(x,y,c)
	end
end

function sin_txt(txt,_y,fg,bg)
--	cls()
	local y
	local c
	local f=time()*80
	local x = 128/2 - (#txt*4)/2
	for c=1,#txt do
		y = sin((x+10+f)/100) * 8
		y += _y
		oprint8(sub(txt,c,c),x,y,fg,bg)
		x = x+4
		end
end

function scroll_txt(txt,y,fg,bg)
--	local _x=time()*10
	local x = time()*40
	for c=1,#txt do
		x = x%128
		oprint8(sub(txt,c,c),x,y,fg,bg)
		x = x+4
	end
end

function lerp(tar,pos,perc)
 return (1-perc)*tar + perc*pos;
end

function digits2(d)
	return d<10 and "0"..d or d
end
-->8
--gameplay

function p_mov(dx,dy)
 
	local destx,desty=p.x+dx,p.y+dy
	local tle=mget(destx,desty)
	local canwalk=iswalkable(destx,desty,"checkmobs")
	
	mobflip(p,dx)
	
	if canwalk then
		--move character
		sfx(63)
		spawn_dust(p.x,p.y,-dx*.2,-dy*.2,{7,6,13,1})
		mob_walk(p,dx,dy)
		a_t=0
		_upd = u_pturn
		local mat=getmat(destx,desty)
		if mat then
			if mat.typ == 1 then
				--get resource
				sfx(53)
				p.mat += 1
				spawn_parts(mat.x,mat.y,{10,9})
				del(mats,mat)
			elseif mat.typ == 2 then
				sfx(53)
				p_cure+=1
				del(mats,mat)
				spawn_parts(mat.x,mat.y,{14,8,2})
			end
		end
		if exit then
			if exit.x == destx and exit.y == desty then 
				advance_day()
			end
		end
	else
		--not walkable
		mob_bump(p,dx,dy)
		a_t=0
		_upd = u_pturn
		local mob=getmob(destx,desty)
		if mob then
			p.ani_call=function()
				sfx(58)
				hit_mob_melee(p,mob)
			end
		end
	end
end

function isalive()
	if p.hp <= 0 then
		show_hud=false
		_upd=u_gover
		_drw=d_gover
			music(-1,100)
		fadeout(0.02)
		reload(0x2000,0x2000,0x1000)
		return false
	end
	return hasvirus()
end

function hasvirus()
	if #mob <= 1 and mob[1].typ==1 then
		-- spawn thing
		if not exit then
			spwn_exit()
			--bed appear
			sfx(43)
		end
	end
	return true
end

function advance_day()
	day+=1
	setmapcoords()
	show_hud=false
	if day > max_day then
		fadeout(0.02)
		a_t=0
		p.mat=0
		if cure == 5 then
			i_story(get_outro_txt_cure())
		else
			i_story(get_outro_txt())
		end
		_upd=u_story
		_drw=d_story
		reload(0x2000,0x2000,0x1000)
	else
		fadeout(0.02)
		a_t=0
		del(mob,p)
		_upd=u_day
		_drw=d_day
	end
end

function los(x1,y1,x2,y2)
 local frst,sx,sy,dx,dy=true
 --’
 if dist(x1,y1,x2,y2)==1 then return true end
 if x1<x2 then
  sx,dx=1,x2-x1
 else
  sx,dx=-1,x1-x2
 end
 if y1<y2 then
  sy,dy=1,y2-y1
 else
  sy,dy=-1,y1-y2
 end
 
 local err,e2=dx-dy
 
 while not(x1==x2 and y1==y2) do
  if not frst and not iswalkable(x1,y1,"sight") then return false end
  frst=false
  e2=err+err
  if e2>-dy then
   err-=dy
   x1=x1+sx
  end
  if e2<dx then
   err+=dx
   y1=y1+sy
  end
 end
 return true 
end

function get_score()
	local score = m_kill\(turrets+bombs)
	score += day
	score = max(10,score-life_lost)
	return score * 100
end
-->8
--ui

function addfloat(txt,x,y,c,t)
	local f = {
	 txt=txt,
	 x=x,
	 y=y,
	 c=c,
	 ty=y-10,
	 t=0
	}
	add(floats,f)
	return f
end

function dofloats()
	for f in all(floats) do
		f.y+=(f.ty-f.y)/10
		f.t+=1
		if f.t > 70 then
			del(floats,f)
		end
	end
end

function addmark(txt,x,y,c)
	local k = {
	 txt=txt,
	 x=x,
	 y=y,
	 c=c
	}
	add(marks,k)
	return k
end

function domarks()
	for k in all(marks) do
--		if k.t > 70 then
			del(marks,k)
--		end
	end
end

function d_hud()
	if(not show_hud)return
	if(not p.hp)return
	if(p.hp <= 0) return
	hud_shake=max(0,hud_shake-.125)
	
	local x=0
	local h=10
	local m=1
	d_hud_p(x,m,h)
	
	x+=37+4
	d_hud_swap(x,m,h)
	x=127-57
	x-=(2-rnd(4)*hud_shake)
	d_hud_up(x,m,h)
end

function d_hud_p(x,m,h)
	local x=x+m
	local y=127-h-m
	local w=37
	local ty=(127-m-2)-h/2
	local tx=x+2
	local mx=tx+(6*3)
	local sy=ty-2

	dbox(x,y,w,h,7,0)
	for i=0,2 do
		local c = 8
		if(p.hp<i+1)c=1
		print("‡",tx+(i*6),ty,c)
	end
	
	local txt=p.mat<10 and "0"..p.mat or p.mat
	print(txt,mx+8,ty,10)
	spr(118,mx,sy)
end

function d_hud_swap(x,m,h)
	local txt="swap"
	local x=x+m
	local y=127-h-m
	local w=25
	local sx=x+3
	local ty=(127-m-2)-h/2
	local sy=ty-2
	local tx=sx+10
	
	dbox(x,y,w,h,7,0,"Ž")
	local swp = next_def(p_def)
	local s = def_idle[swp][1]
	spr(s,tx+1,sy)
	spr(052,sx+2,sy)--swp sprite
--	print(txt,tx,ty,7)
end

function d_hud_up(x,m,h)
	local def=getdef(p.x,p.y)
	--hud3
	local x=x+m
	local y=127-h-m
	local txt=def and "upg" or "bld"
	local w=56
	local ty=(127-m-2)-h/2

	local sx=x+5
	local sy=ty-2
	local tx=sx+10

--return 64-#s*2
	
	if exit then
		dbox(x,y,w,h,7,0)
		d_hud_exit(tx,ty,sx,sy)
		return true
	end
	
--	if p.mat == 0 then
--		dbox(x,y,w,h,7,0,"")
--		d_hud_get_mat(tx,ty,sx,sy)
--		return true
--	end
	
	dbox(x,y,w,h,7,0,"—")
	
	if def and def.typ==3 then
		if not def.disable then
			d_hud_heal(tx,ty,sx,sy,def)
		else
			d_hud_heal_disable(tx,ty,sx,sy,def)
		end
		return true
	end

	--action
	local s = def and 124 or 108
	spr(s,sx,sy)
	sx=tx+(#txt*4)+1
	print(txt,tx,ty,7)--action
	
	s = def_idle[p_def][1]
	local cost = def_cost[p_def]
	if def then
		cost = def_cost[def.typ]
		s=def_idle[def.typ][1]
	end
	
	spr(s,sx,sy)--def sp
	sx=sx+10
	spr(118,sx,sy)
	
	txt=cost < 10 and "0"..cost or cost
	tx=sx+8
	local cc = cost <= p.mat and 10 or 8
	print(txt,tx,ty,cc)

end

function d_hud_exit(tx,ty,sx,sy)
	tx=sx-2
	local txt="go to sleep"
	sx=tx+(#txt*4)
	print(txt,tx,ty,7)
	spr(054,sx,sy+1)
end

function d_hud_get_mat(tx,ty,sx,sy)
	local txt="go get some"
	tx-=10
	print(txt,tx,ty,7)
	sx=tx+(#txt*4)-1
	spr(118,sx,sy)
end

function d_hud_heal(tx,ty,sx,sy,def)
	local tx=tx-10
	local txt="‡"
	print(txt,tx,ty,8)
	txt="+1 for"
	print(txt,tx+8,ty,7)
	sx=tx+(#txt*4)+11
	spr(118,sx,sy)
	txt="01"
	tx=sx+8
	print(txt,tx,ty,10)
end

function d_hud_heal_disable(tx,ty,sx,sy)
	local tx=tx-10
	local txt="out of order"
	print(txt,tx,ty,8)
end

function dbox(x,y,w,h,fg,bg,bt)
	--bg
	rectfill(x+1,y+1,x+w,y+h,bg)
	
	--top border
	line(x+2,y,x+w-2,y,fg)
	--topleft corner
	pset(x+1,y+1,fg)
	--left border
	line(x,y+2,x,y+h-2,fg)
	--bottom left corner
	pset(x+1,y+h-1,fg)
	--topright corner
	pset(x+w-1,y+1,fg)
	--bottomright corner
	pset(x+w-1,y+h-1,fg)
	--right border
	line(x+w,y+2,x+w,y+h-2,fg)
	--bottom-border
	line(x+2,y+h,x+w-2,y+h,fg)
	
	if(not bt)return
	x-=2
	y-=2
	y+=min(0,sin(time()))
	oprint8(bt,x,y,fg,bg)
end
-->8
--mobs

function addmob(typ,x,y)
	local m={
		x=x,
		y=y,
		ox=0,
		oy=0,
		flp=false,
		ani={},
		flash=0,
		hp=mob_hp[typ],
		atk=mob_atk[typ],
		typ=typ,
		wait=mob_wait[typ],
		task=mob_tasks[typ],
		hatch=gethatch(),
	}
	if(typ==5)m.smart=true
	mob_frames_idle(m)
	add(mob,m)
	return m
end

function mobflip(m,dx)
	m.flp=dx==0 and m.flp or dx<0
end

function mob_frames_idle(m)
	m.ani={}
	for i=0,mob_idle_f[m.typ]-1 do
		add(m.ani,mob_idle[m.typ]+i)
	end
end

function mob_walk(m,dx,dy)
 m.x+=dx --?
 m.y+=dy
 mobflip(m,dx)
 m.sox,m.soy=-dx*8,-dy*8
 m.ox,m.oy=m.sox,m.soy
 m.mov=ani_walk
end

function mob_bump(m,dx,dy)
	m.sox = dx*8
	m.soy = dy*8
	m.ox = 0
	m.oy = 0
	m.mov = ani_bump
end

function mob_hatch(m, s)
	m.mov = ani_hatch
	m.ani = {s}
end

function ani_walk(m)
	local tme=1-a_t
	m.ox=m.sox*tme
	m.oy=m.soy*tme
end

function ani_bump(m)
	local tme=a_t
	local tme=a_t>0.5 and 1-a_t or a_t
	m.ox=m.sox*tme*1.5
	m.oy=m.soy*tme*1.5
end

function ani_hatch(m)
	m.ani = {82}
end

function d_mob(m)
	local col=nil
	if m.flash >0 then
		m.flash-=1
		col=7
		if m.typ==1 then
			col=8
		end
	end
	local x1,y1=m.x*8+m.ox,m.y*8+m.oy

	d_spr(
		get_frame(m.ani),
		x1,
		y1,
		m.flp,
		col
	)
end

function getmob(x,y)
	for m in all(mob) do
		if m.x == x and m.y == y then
			return m
		end
	end
	return false
end

function iswalkable(x,y,mode)
	if(not inbounds(x,y))return false
	if(fget(mget(x+mapx,y+mapy),0))return false
	local mb=get_med(x,y)
	if(mb)return false 
	local mode = mode or ""

	if mode=="checkmobs" then
		return not getmob(x,y)
	elseif mode=="checkmats" then
		return not getmat(x,y)
	elseif mode=="checkdefs" then
		return not getdef(x,y)
	elseif mode=="checkall" then
		if(getmat(x,y))return false
		if(getmob(x,y))return false
		if(getdef(x,y))return false
	end

	return true
end


function mob_space_arround(m)
	for i=1,4 do
	 local dx,dy=dirx[i],diry[i]
	 local tx,ty=m.x+dx,m.y+dy
		if iswalkable(tx,ty,"checkall") then
		 	return true
		end
	end
	return false
end

function inbounds(x,y)

	return not (
		x<0 or 
		y<0 or 
		x>15 or 
		y>13
	)
end

function hit_mob_melee(atk,def)
	hit_mob_range(atk,def)
	hit_mob_range(def,atk)
end

function hit_mob_range(atk,def)
	if(def.flash > 0)return
	local dmg=atk.atk
	
	def.hp-=dmg
	
	if(dmg>0)def.flash=10
	if dmg>0 and def.hp > 0 then
		addfloat("-‡",def.x*8,def.y*8,8)
	end
	
	if def.typ == 1 then
		life_lost += 1
	end
	
	if def.hp <= 0 then
		if def.typ != 1 then
			m_kill+=1
		end
		add(dmob,def)
		del(mob,def)
		adddecal(def.x,def.y)
		def.dur=10
	end
end

-->8
--defenses

function adddef(typ,x,y)
	local d={ 
		x=x,
		y=y,
		atk=1,
		hp=5,
		typ=typ,
		ani=def_idle[typ],
		wait=def_wait[typ],
		r=def_r[typ],
		cost=def_cost[typ],
		--r=20,
		task=d_idle,
	}
	add(def,d)
end

function dodeftarget()
	for d in all(def) do
		if d.typ == 1 then
			if d.wait == 0 then
				d_idle(d)
			end
		end
	end
end

function dodef()
	local moving = false
	
	for d in all(def) do
		d.mov  = nil
		d.wait = max(d.wait-1,0)
		moving = d:task() or moving
		
		if d.typ == 1 then
			-- turret
			if d.t then
				d.task=d_fire
			else
				d.task=d_idle
			end
		elseif d.typ == 2 then
			if d.wait == 2 then
				d.task=d_pre_explode
			elseif d.wait == 1 then
				d.task=d_explode
			end
		end
	end

	if moving then
		_upd=u_dturn
		a_t=0
	else
		doai()
	end
end

function in_def_r(d,m)
	local x1,y1=(m.x*8)+1,(m.y*8)+3
	local x2,y2=x1+6,y1+5
	local x,y=d.x*8+4,d.y*8+4
	local r=d.r
	
	local cx=mid(x,x1,x2)
	local cy=mid(y,y1,y2)
	
	local dist=dist(x,y,cx,cy)
	return dist<d.r
end

function d_find_target(d)
	for m in all(mob) do
		local los = los(m.x,m.y,d.x,d.y)
		local iscol= in_def_r(d,m)
	
		if
			d.wait == 0 and
			m.typ != 1 and 
			los and
			iscol
		then
			return m
		end
	end
	return nil
end

function d_hit_all_in_range(d)
	for i=0,d.r-1 do
		local tx=d.x-(d.r\2-i)
		for j=0,d.r-1 do
			local ty=d.y-(d.r\2-j)
				local m = getmob(tx,ty)
				local mb=get_med(tx,ty)
				if m then
					hit_mob_range(d,m)
					spawn_parts(m.x,m.y,{10,9,8,2})
				end
				if mb then
					destroy_medblock(mb)
					spawn_parts(mb.x,mb.y,{10,9,8,2})
				end
		end
	end
	for i=1,4 do
		local tx=d.x+(dirx[i]*2)
		local ty=d.y+(diry[i]*2)
		local mb=get_med(tx,ty)
		local m = getmob(tx,ty)
		if m then
			hit_mob_range(d,m)
			spawn_parts(m.x,m.y,{10,9,8,2})
		end
		if mb then
			destroy_medblock(mb)
			spawn_parts(mb.x,mb.y,{10,9,8,2})
		end
	end
end

--task
function d_idle(d)
	if(d.wait > 0)return
	d.ani=def_idle[d.typ]
	d.fire=false
	d.t = d_find_target(d)
	if d.t then 
		d.ani=def_fire[d.typ]
		d.task=d_fire
		addmark("!!",d.x*8,d.y*8-6,8)
		--addmark("!",d.x*8+2,d.y*8-6,8)
	end
	return false
end

function d_disable(d)
	d.disable=true
	d.ani=def_disable[d.typ]
end

function d_fire(d)
	d.mov=d_ani_fire
	d.fire=true
	return true
end

function d_pre_explode(d)
	d.ani=def_fire[d.typ]
	return false
end

function d_explode(d)
	d.mov=d_ani_explode
	return true
end

function d_ani_fire(d)
	if (a_t==1) and d.t then
		--laser shot
		sfx(60)
		hit_mob_range(d,d.t)
		spawn_parts(d.x,d.y,{8})
		spawn_parts(d.t.x,d.t.y,{8})
		d.t = nil
		d.ani=def_disable[d.typ]
		d.wait=4
		d.fire=false
		--d.wait=0 --…
	end
end

function d_ani_explode(d)
	if (a_t==1) then
		--explosion
		sfx(52)
		d_hit_all_in_range(d)
		spawn_parts(d.x,d.y,{10,9,8,2})
		del(def,d)
		-- todo: flash
	end
end

function getdef(x,y)
	for d in all(def) do
		if d.x == x and d.y == y then
			return d
		end
	end
	return false
end

function d_def(d)
	local col=nil
	local x=d.x*8
	local y=d.y*8
	
	if d.typ == 1 then
		d_turret(d,x,y)
	elseif d.typ == 2 then
		d_bomb(d,x,y)
	end
	
	d_spr(get_frame(d.ani),x,y)
end

function d_turret(d,x,y)
	local circcol=1
	local plt = {2,8}
	local tx=d.t and d.t.x*8 or nil
	local ty=d.t and d.t.y*8 or nil
		
	if d.wait > 0 then
		for i=0,d.wait-1 do
			local wx=x+(i*2)
			local wy=y-2
			rectfill(wx,wy,wx,wy+1,7)
		end
	else
		circcol = plt[flr((time()*5)%#plt)+1]
	end

	circ(x+4,y+4,d.r,circcol)
	
	if(not d.t)return
	
	if not d.fire then
		local ax,ay=x+4,y+4
		local bx,by=tx+4,ty+4
		local plt = {13,14}
		local c = plt[flr((time()*6)%#plt)+1]
		line(ax,ay,bx,by,c)
		oprint8("!",x+2,y-6,8,0)
	else
		local c = 1
		local ax,ay=x+4,y+4
		local bx,by=tx+4,ty+4
		local cx,cy=bx-ax,by-ay
		local rx,ry=ax+(cx*a_t),ay+(cy*a_t)
		line(ax,ay,rx,ry,8)
	end
end

function d_bomb(d,x,y)
	local plt = {2,8}
	local circcol=1

--x+=4
--	y+=4
	local r2 = d.r\2
	local x1 = (x-r2*8)
	local y1 = (y-r2*8)
	local x2 = (x1+d.r*8)
	local y2 = (y1+d.r*8)
	local w = d.r*8
	local h = d.r*8
	
	if d.wait < 2 then
		circcol = plt[flr((time()*5)%#plt)+1]
	end
	
	d_bomb_r(d.r,d.x,d.y,circcol)
	
	if d.wait > 0 then
		for i=0,d.wait-1 do
			local wx=x+(i*2)
			local wy=y-2
			rectfill(wx,wy,wx,wy+1,7)
		end
	end
end

function next_def(d)
	if(d == 1) return 2
	if(d == 2) return 1
end

function d_bomb_r(r,x,y,c)
	local x=x
	local y=y
	local r2 = r\2
	local x1 = ((x*8)-r2*8)
	local y1 = ((y-r2)*8)
	
	for i=0,r-1 do
		local cx=x1+(i*8)+4
		local cr=3+min(0,sin(time()))
		local cy=y1+4
		for j=0,r-1 do
			cy=(y1+4)+j*8
			circ(cx,cy,cr,c)
		end
	end
	
	for i=1,4 do
		local cx=(x+(dirx[i]*2))*8
		local cy=(y+(diry[i]*2))*8
		local cr=3+min(0,sin(time()))
		cx+=4
		cy+=4
		circ(cx,cy,cr,c)
	end
end
-->8
--ai

function doai()
	local moving = false

	for m in all(mob) do
		if m.typ != 1 then
			m.mov=nil
			m.wait= max(m.wait-1,0)
			moving = m:task() or moving
		end

		-- spider
		if m.typ == 3 then
			if m.wait == 0 then
				if m.hatch == 0 then
					m.wait = 4
					m.task=ai_lay_egg
				else
					m.task=ai_attack
					-- todo: check if this is
					-- the best way to swap the
					-- animation
				end
			end
		end
	end
	
	if moving then
		_upd=u_aiturn
		a_t=0
	else
		_upd = u_game
	end
end

function ai_hatch(m)
	if m.wait == 1 then
		m.ani={68,69}
		return false
	end

	if(m.wait > 0) return false

	spawn_parts(m.x,m.y,{7,14,8})
	local nm = addmob(3,m.x,m.y)
	del(mob,m)
end

function ai_attack(m)
	-- set idle frames
	mob_frames_idle(m)
	m.atk=mob_atk[m.typ]
	m.hatch=max(m.hatch-1,0)
	
	if dist(m.x,m.y,p.x,p.y) == 1 then
		--hit
		dx,dy=p.x-m.x,p.y-m.y
		mob_bump(m,dx,dy)
		m.mov=ani_bump
		m.ani_call = function()
			hit_mob_melee(m,p)
			sfx(50)
			--lose health
		end
		return true
	else
		-- move torwards player
		return ai_mob_move(m)
	end
end

function ai_lay_egg(m)
	-- set sprite for hatching
	mob_hatch(m,82)
	m.atk=0
	m.hatch = gethatch()
	
	if 
		m.wait == 0 and
		mob_space_arround(m) 
	then
		sfx(45)
		--egg hatch
		addmob(2,m.x,m.y)
		m.wait=0
		m.task=ai_attack
		ai_mov_rnd(m)
		mob_frames_idle(m)
		return true
	end
	
	return false
end

function ai_mob_move(m)
	if(m.wait > 0) return
	--disable move
	--if(true)return
	
	if m.smart then
		return ai_mob_target(m)
	end
		-- prob to not follow
	if rnd() > 0.3 then
		--prob to move random
		if rnd() > 0.2 then
			-- didnt move
		return false
		end
		return ai_mov_rnd(m)
	else
		return ai_mob_target(m)
	end
end

function ai_mob_target(m)
	if(m.wait > 0) return
	local bdst,bx,by=999,0,0
	for i=1,4 do
		local dx,dy=dirx[i],diry[i]
		local tx,ty=m.x+dx,m.y+dy
		if 
			iswalkable(tx,ty,"checkall")
		then
			local dst=dist(tx,ty,p.x,p.y)
			if dst<bdst then
				bdst,bx,by=dst,dx,dy
			end
		end
	end
	mob_walk(m,bx,by)
	return true
end

function ai_mov_rnd(m)
	if not mob_space_arround(m) then
		return false
	end
	
	local dirs = shuffle({1,2,3,4})
	
	for i in all(dirs) do
	 local dx,dy=dirx[i],diry[i]
	 local tx,ty=m.x+dx,m.y+dy
		if iswalkable(tx,ty,"checkall") then
		 	bdst,bx,by=dst,dx,dy
		end
	end
	mob_walk(m,bx,by)
	return true
end

function gethatch()
	return flr(rnd(17))+3
end
-->8
--materials

function addmat(typ,x,y)
	local mat={ 
		x=x,
		y=y,
		typ=typ,
		ani=mat_idle[typ],
		speed=mat_speed[typ]
	}
	add(mats,mat)
end

function domats()
	if mats_wait > 0 then
		mats_wait -= 1
		if mats_wait == 0 then
			if not exit and p.mat < 10 then
				spwn_mat()
				sfx(44)
				--resource appear
			end
			mats_wait = get_mats_wait()
		end
	end
end

function spwn_mat()
	local can = false
	
	local x = flr(rnd(16))+1
	local y = flr(rnd(16))+1
	
	while not iswalkable(x,y,"checkall") do
		x = flr(rnd(16))+1
		y = flr(rnd(16))+1
	end
	
	addmat(1,x,y)
	spawn_parts(x,y,{10,9})
end

function getmat(x,y)
	for mat in all(mats) do
		if mat.x == x and mat.y == y then
			return mat
		end
	end
	return false
end

function d_mat(mat)
	local col=nil

	d_spr(
		get_frame(mat.ani,mat.speed),
		mat.x*8,
		mat.y*8,
		false,
		col
	)
end

function get_mats_wait()
	local mi = 8
	local ma = 15
	return flr(rnd(ma-mi) + mi)
end
-->8
--juice

function addpart(typ,x,y,mage,carr,dx,dy)
	local dx = dx or 0
	local dy = dy or 0
	local part = {
		typ=typ,
		x=x,
		y=y,
		c=0,
		carr=carr,
		age=0,
		mage=mage,
		dx=dx,
		dy=dy
	}
	if typ == 1 then
		part.r = rnd(2)+1
	end
	add(parts,part)
	return part
end

function doparts()
 for i=#parts,1,-1 do
		local part = parts[i]
		u_part(part)
	end
end

function spawn_parts(_x,_y,carr)
	for i=0,4 do
		local angle = rnd()
		local x = _x*8 + 4
		local y = _y*8 + 4
		x += sin(angle)*4
		y += cos(angle)*4
		addpart(1,x,y,25,carr)
	end
	
	for i=0,flr(rnd(2))+3 do
		local angle = rnd()
		local x = _x*8 + 4
		local y = _y*8 + 4
		x += sin(angle)*4
		y += cos(angle)*4
		addpart(0,x,y,25,carr)
	end
end

function spawn_dust(_x,_y,dx,dy,carr)
	--{6,13,1}
	for i=1,3 do
		local angle = rnd()
		local x = _x*8 + 4
		local y = _y*8 + 4
		x += sin(angle)*2
		y += cos(angle)*2
		addpart(0,x,y,25,carr,dx,dy)
	end
	
	for i=1,2 do
		local angle = rnd()
		local x = _x*8 + 4
		local y = _y*8 + 4
		x += sin(angle)*2
		y += cos(angle)*2
		addpart(1,x,y,25,carr)
	end
end

function u_part(part)
	part.age += 1
	if part.age >= part.mage then
		del(parts,part)
		return
	end
	
	part.x += part.dx
	part.y += part.dy

	-- update colors
	if #part.carr==1 then
			part.c = part.carr[1]
	else
		local ci=part.age/part.mage
		ci=1+flr(ci*#part.carr)
		part.c = part.carr[ci]
	end
	
	-- update radius
	if part.typ == 1 then
		part.r = max(part.r-.125,-1)
	end
	
end

function d_part(part)
	if part.typ == 0 then
		pset(
			part.x,
			part.y,
			part.c
		)
	elseif part.typ == 1 then
		circfill(
			part.x,
			part.y,
			part.r,
			part.c
		)
	end
end

function adddecal(x,y)
	local dc={
		x=x,
		y=y,
		s=rnd({101,102,103,104})
	}
	add(decals,dc)
	return dc
end

function d_decal(dc)
	spr(dc.s,dc.x*8,dc.y*8)
end
-->8
--big sprts

function d_logo(x,y,scale)
	local scale = scale or 1
	d_ltrs(x,y,scale)
	d_face(x+8*8*scale,y-9,scale)
end

function d_ltrs(x,y,scale)
	local scale = scale or 1
	local sx=32
	local sy=0
	local sw=8*8
	local sh=8*2
	local dx=x
	local dy=y
	local dw=8*8*scale
	local dh=16*scale
	sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end

function d_face(x,y,scale)
	local scale = scale or 1
	local sx=96
	local sy=0
	local sw=8*4
	local sh=8*4
	local dx=x
	local dy=y
	local dw=8*4*scale
	local dh=8*4*scale
	sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end

function d_face2(x,y,scale)
	local scale = scale or 1
	local sx=0
	local sy=0
	local sw=8*4
	local sh=8*4
	local dx=x
	local dy=y
	local dw=8*4*scale
	local dh=8*4*scale
	sspr(sx,sy,sw,sh,dx,dy,dw,dh)
end
-->8
-- exit

function spwn_exit()
	local spc = find_space_rnd()
	exit={
		x=spc.x,
		y=spc.y,
		s=054
	}
	spawn_parts(spc.x,spc.y,{7,8,14})
	spawn_parts(spc.x,spc.y,{7,8,14})
end

function d_exit()
	if(not exit)return
	spr(exit.s,exit.x*8,exit.y*8)
end

function find_space_rnd()
	local isvalid=false
	local x = 0
	local y = 0
	
	while not isvalid do
		
		x=flr(rnd(15))
		y=flr(rnd(10))

		local canwalk=iswalkable(x,y,"checkall")
		--fix
		local cansee=los(p.x,p.y,x,y) or true
		local d=dist(x*8,y*8,p.x*8,p.y*8)
		local isfar=d>8*4
		isvalid=canwalk and cansee and isfar
	end
	
	return {x=x,y=y}
end
-->8
-- story

function i_story(txt)
	skip=false
	msg=""
	--music(-1,200)
	--music(8,200)
	
	for l in all(txt)do
		msg=msg..l.."\n"
	end
	current=""
	co_text=cocreate(function()
		text_spool(msg,3)
	end)
end

function u_story()
	--fancy way of only resuming
	--the coroutine if it is
	--currently active
	if btnp(—) then
		--menu button
		sfx(46)
		if skip then
			fadeout(0.02)
			a_t=0
			if day > max_day then
				_upd=u_win
				_drw=d_win
			else
				_upd=u_day
				_drw=d_day
			end
		else
			skip=true
		end
	end

	if (co_text!=nil and costatus(co_text)!="dead") then
		coresume(co_text)
	else
		co_text=nil
	end
end

function d_story()
	cls(0)
	if(not current) return
	print(current,2,2,7)

	local txt="skip"
	
	if skip or not co_text or costatus(co_text)=="dead" then
		txt="start"
	end
	
	local x=127-(#txt*4)-10
	print(txt,x,121,6)

	x+=(#txt*4)
	local by = 121
	by+=min(0,sin(time()))
	print("—",x,by,6)
end

function get_intro_txt()
	return{
	"well my brother, here it is. ",
	"a little piece of history.",
	" ",
	"the story of this black world",
	"and it goes like this.",
	"\n",
	"in the years 2600 ...",
	"\n",
	"when the virush arrived,",
	"in the streets of cartagena,",
	"this story was born.",
	" ",
	"i woke up ˆ",
	"nobody at my side.",
	"virush everywhere,",
	"the only thing i could do ...",
	"survive.",
	}
end

function get_outro_txt()
	return{
		"you wake up,",
		"after days of fever",
		"only destruction by your side",
		" ",
		"there is no sound.",
		"it seems you survived ...",
		" ",
		"but no one else.",
		" ",
		" ",
		"the end.",
		}
end

function get_outro_txt_cure()
	return{
		"you wake up,",
		"after days of fever",
		" ",
		" ",
		"you hear laughter outside",
		"you did it ...",
		" ",
		"you found the cure.",
		" ",
		" ",
		"the end.",
		}
end

function waitfor(t)
	for c=1,t do
		if(not skip) yield()
	end
end

function text_spool(msg,speed)
	local speed=speed or 5
	--loop through the msg one
	--character at a time, from 1
	--to the length of msg (#msg)
	for i=1,#msg do
		--set current_msg to the
		--beginning of msg (1) up to
		--however far we are through
		--the loop (i)
		current=sub(msg,1,i)
		local char = sub(msg,i,i)
		local prevc= i<#msg and sub(msg,i-1,i-1) or false
		
		--play a sound each time we
		--loop, to make the little
		--doot-doot-doot as we type
	
	
		--if they press — while we
		--are playing out the text,
		--stop looping through the
		--text and just jump to where
		--we show all the text
		if (skip) break
	
		waitfor(speed)
	
		if
		char == " " or
		char == "\n"
		then
			--sfx(56)
		else
			sfx(0)
		end
	
		if
		 char == "\n" or 
		 char == ","  or
		 char == "!"
		then
			waitfor(speed*5)
		end
		
		if char == "." then
			waitfor(speed*10)
		end
		
		if 
			char == "0" and
			prevc== "0" or
			char=="ˆ"
		then
			waitfor(speed*22 + 4)
		end
			--wait until the next _update
			--before looping again
		yield()
	end

	--after we are done with the
	--loop (whether it finished
	--naturally or we broke out
	--of it), do one more update
	--to clear out any button
	--presses
	yield()

	--set current_msg to the full
	--text of msg so everything
	--is shown
	current=msg
end
-->8
--medblocks--

function addmed(x,y)
	local mb={ 
		x=x,
		y=y,
		ani={56,57},
	}
	add(med_blocks,mb)
end

function destroy_medblock(mb)
	del(med_blocks,mb)
	addmat(2,mb.x,mb.y)
end

function get_med(x,y)
	for mb in all(med_blocks) do
		if mb.x==x and mb.y==y then
			return mb
		end
	end
	return nil
end

function d_medblock(mb)
	local s =get_frame(mb.ani)
	spr(s,mb.x*8,mb.y*8)
end
__gfx__
00000000000000000000000000000000077770000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000077770000000777700000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000d7777000007777d00000000000000000000000000008888880000000000000000000000000000000000000000000000
00000000000000000000000000000000007777000007777077700777777000077800077700078887888088800088800000000000000000000000000000000000
0000000000000000000000000000000000d77770007777d07770078777770008770007880088882d882088800088800000000000000000000000000000000000
00000000000000777770000000000000000777700077770077700777dd7770087700088800888200220088800088800000000000000000777770000000000000
00000000000777777777770000000000000d777707777d00787007770078800788000887007887000000888000888000000000000077777ffff7770000000000
00000000077777777777777700000000000077770777700077700777007770077700077700d78888000088888888800000000000777777ffffff777000000000
000000077777777777776677700000000000d7777777d000777007770787000887000787000d2788800088888888800000000007777677ffffff4f7770000000
00000077776777777777777777000000000007777777000077800778778000078700078700000d88880088888888800000000077776767effff4f4f777000000
0000077776777777777777777770000000000d77777d000077700777d877000787000787000000288880888222888000000007777776777eff4f4f4f77700000
000077777777777777779999a777000000000077777000007770077707778008777078870887000287808880008880000000777777776777eff4f4fff7700000
00007777799997777779aa9997770000000000d777d00000777007870d7788088887888707878008888088800088800000007777777777777eef4fffff770000
000777779aa999777779aa999777700000000007770000007770077700d7770d7887887d0d88888888208880008880000007777766777777777effffff770000
00077779aa99997777799999977770000000000ddd000000ddd00ddd000ddd00d22d22d00027888882002220002220000007777dd77777777677effff7777000
0077777999999a7777799999977777000000000000000000000000000000000000000000000622222000000000000000007766daa97777777d777eef77777000
007777799999977777779999a777770000000000000000006666666660000000000000060000000000000000000000000077799a9977777799dd777777777700
00777777999a77777777777777777700000000000000000000000000600000000000000600000000000000000000000000774999977777749aa9dd6777777700
00777777777799999999a77777777700000000000000000000000000600000000000000600000000000000000000000000774999477777749a99997777677700
00777777777799999999a77777777700000000000000000000000000600000000000000600000000000000000000000000777444777777779999997776776c00
00c77777777779999997777777777700000000000000000000000000600000000000000600000000000000000000000000c77777799999774999997777767c00
000c7777777777777777777777777c000000000000000000000000006000000000000006000000000000000000000000000c777799444999744447777777c000
000cc77777777777777777777777c0000000000000000000000000006000000000000006000000000000000000000000000cc7779477749977777777777c0000
0000cc77777777777777777777cc200000000000666666660000000060000000000000060000000000000000000000000000cc7777777744777777777ccc2000
00221cc77777777777777777ccc22220000000000000000004777740000000000666666006666660000000000000000000221cc7777777777777777cccc22220
222121ccc7777777777777cccc11222200777660977dd776067777600000000066266266662662660000000000000000222121ccc77777777777cccccc112222
2222111cccccccccccccccccc1121222070000d0977dd677086666e000211200d626266dd686266d00000000000000002222111ccccccccccccccccc11121222
222221111ccccccccccccc111121222000000777977dd777088e8880012ee2105dd88dd15dde8dd10000000000000000222221111cccccccccccc11111212220
0222221211111111111111111212220007000070966dd7760e888e8001988910285e82d12e57e8d1000000000000000002222212111111111111111112122200
002222212121212121212121222200007770000042222666088e8880822882281d58dd211d5edd21000000000000000000222221212121212121212122220000
000022222212121212121222220000000d00007044444444044444402012210255d2d5d155d8d5d1000000000000000000002222221212121212122222000000
00000000222222222222222000000000066777000d00000d02000020000000000525555005255550000000000000000000000000222222222222222000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666600666666006666660
0000000000000000000000000000000000000000000000000555500000550000055500000000550000000000000000000000055066666666666666666d666666
00000000000000000000000000000000000000000000000055555500050050000500500000055550000000000055000000000000d666666dd666d66dd666666d
000770000007700000077000000770000007700000000000055550000055000000000000000000000000000000000000055550005dddddd15dddddd155ddddd1
006666000066660000666600006666000088880008777780000000000000000050000005050000000005500000000000055550005d5555d15d5555d15d1ddd11
00e66e00002e660000e66e000066e2000088880008888880000000500000050000005550000000000055550000000000000000005d5555d11d55ddd15ddddd11
002ee200002eee00002ee20000eee2000028820002888820000005550000505000050000555500500005500000000050000005005dddddd155ddd5d155ddddd1
00022000000220000002200000022000000220000022220000000000000005000000000005000000000000000000000000000000055555500555555005555550
00000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000030003000000000000000000000000
00000000000000000000000000000000000000000000000000000000000300000000003000000030030000000000000000030303000800000008000000000000
00211200000000000077770000000000000000000000000000300000000300000000000000000000000000000000000000000300088888000888880000000000
012ee21000211200072112700033330000000000000000000030300000000000003000000003000000000000000030000000000002878200028e820000000000
01988910012ee210712ee21703baab3003333330000000000030300000000030000000000303000000000000000000000000000000878000008e80000d66ddd0
022882200198891071788717031bb1303bbaaab30000000000000000300003000000000000303000000000000000000030000000008e8000008e8000d555555d
20122102822882288228822803b22b3031b22b130000000000000030030000000000003000000000000000300000000003000300002e200000222000d555555d
2000000220122102271221720033330003333330000000000000000000000000000000000000003000000000000000000000000000020000000000000dd666d0
00000000000000000077770000000000000000000000000000000000000000000000000003000000300000000000000000000000000000000000000000000000
00777700007777000677776000000000007777000020000000000020000022222000000030000200300030300300000006666606002112000000000000000000
06677660066776600668866000777700066776600222000002000000020222000000000200002000300000000000003070677707019889100000000000000000
5d6556d55d6556d5059aa950665555665d6556d500000000002200000022222000000000000000000000030000000030d00ddd0d012882100044440000000000
2d2882d22d2ee2d2029aa920528998252d2dd2d2000000000222200000022000000022000000000000030303000000000000000008222280049aa94004444440
2dd22dd22dd22dd202d99d202d2222d22dd22dd20000000000000000220002200022220000000000003003030a000000000490000212212004199140499aaa94
01dddd1001dddd1001dddd1001dddd1001dddd100000000000000200000222000000000000000000300000000300030000049000002002000291192021911912
00111100001111000011110000111100001111000000000000000000002000020000000000000030000000000000000000044000000000000022220002222220
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000777000007770
000000000000000000000000000000000000000000666600000000000000000000000000000000000000000000000000000700000000dbd00000dbd00000d2d0
00777700000000000d6666d00d6666d00d6666d00788887000aaaa00007aaa000077aa0000a77a0000aa770000aaa70000f7f000007777d0007777d0007777d0
0777777007777770065dd560065335600649946007a77a7000a44a0000744a0000794a0000a99a0000a4970000a4470009999900076666700766667007666670
0779797077777777012cc210012bb210014aa410029aa92000a00400007004000070040000a0040000a0090000a00900000000000d63b3600d63a3600d65d560
07777770c779797c0115511001155110011551100115511000aaaa00007aaa000077aa0000a77a0000aa770000aaa700000700000d3bbb300d3aaa300d5ddd50
0c7997c0c777777c0000000000000000000000000000000000444400009444000099440000499400004494000044490000f7f0000163b3600163a3600165d560
00cccc000cc99cc00000000000000000000000000000000000000000000000000000000000000000000000000000000009999900001111100011111000111110
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
0000000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000000000200010100000000000000000000000000000000000000010101000000000000000000000000000003000303030003000000000000000000000000000000000003030303030300000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2424242424242424242424242424242459585858585858005858585858585b5c5b5b5b5900005a000000006b000000007d5c5c5c5c5c000000475947476b0056585757404d5757005a5a5a56566b585c5c5c5c000000000000000000005c5b5c48596b005a0048474a000058585959405958580058586b57570057570000004c
242424242424242424242424242424246b59570000005a5a580069005757675b5c575b595a004f4e6b00570000575700585c00004e4d4d59596b6b585a53560000586b574d576b5a5a5a5c5a5c536e5c596a00000000005f00000000006a5c59595a595a0000494747000058585859595958584d4e4d004d4e4e4d4e4d4e4f00
252525252525252525252525252525255a0057575653535353586b69585757695c5b575700004f4d6b6b0000570000585858005c00004f59586b6b6b53405300005a57574d6b6b5a5a5a5a565a53536b5c00000000000046000000000000005c5a5a5b005a0048484b00000058585859595c585959594b594b5c004058584f00
000000000000000000000000000000005c5c576a5a4e4f4e4d586b5858575758585b5b595a5a6b406b0057570057575758585c585c005c59005947695b535b58004d4d4d38575a005a6b5a56565a5656575a7600000000460000000000765a5a6b5b5b0000004c48470000005b585859594d5859534d5b5c576e5953584a4d00
00000059594a595359000000575a6b6b6b4800005a5a484c0069586b580057000000005a59484846484857576b5b5b57565c00585858585b59596b47476b6b000057474746575a5a5a6b6b005858580057570000005a5a46005a5a0000005c5a0000004d4e4d464c4b4d4f3800005859594f4e594d575c57485c594e4a580000
000000004a4a5a5959575a00000058586b0000586b5858580058476b4a00000058000059595956004746465647484600005c4d00000000005959596b5b6b6900586b5a5a464646465a5a6b0000696900575b575b595b594659595a5a00595a5c0000004d575b565b57575b4d000000004b38596e5b6b6b485b6b6b4f4f4f4f00
00000000000000005a00005a00465858000000696b005800000000006b6b0000005759595859596b6b6b004059594700005c4e4d4d0000005800595959595958586b6b5a5a5a5a5a4649000000000000005b5759595a5a5946595a5959595c00004846465357577600535b4947480000004e6a4d4d6a465b5b536a005b764f57
000000000000007600000000000048585a57006b6b00000000000057576b58586a574b5859586b6b59586b6b5948470000005c5c5c005c005c00000000005b5b5b005a5a00005a000046000000000000005a4747575a5a5a46595757575c00464848484f0057765f76565b4e464c4c474c4d006a4f4d4e4e4d4f4e6a5b574d57
000000006a00005f005a0000000000000000004b4b00000000004a6b000058006a57494956586b464746566b5948000058004b4b4b00000000006b00000000585b5b00000000000000004646000000005b575b475757575c4646005a575700484849464e535700765c53594d4647494646004d006a006a585f4f006a6a530000
5b5b5a6a6a5800005b5a000000000000000000004b6b6b005c5c5c6b5800000000004b4b56576b6b4b6b6b5859000000584b4b4b4b484b000057575a6b6b00005b5b00000000000000000046590000005c495b5c5c57695a5c49495757575a00000046465656575b5b005646494900000000004d586a6a00004f005800004d56
005c5b49584a57585700000000006e00005c004b4b5f6b005c7d5c6b585c58580000004b494b56586b6b595900000058584b4b484b4b4b4b00575a58576b5800005b00000000000000000046594900005c5b5c56495c4f4e4f4d565c5c5c5c570000004d00694b5b57576b4f000058584d4000474e4f4d48464f004d4d4f4f5a
5a5c5c5b4949575800000000000000000000000000006b6b005a5c5a5c000000005848484b4948764b494b0000005958494b005f4b40404b6b5a587676575a58760000000000000059590000004646465a6a5b6a4953407d00405349495a496b006b004e4e4d47484b4d4f4e5858575c5c584e58584e7600470076000000595a
00005c00005c0057000000000000000000005c0000000000005800005c00580000000000004b4b4b000000004900005848484848494b48005a6b5876766b5800765b7d0000000000005900005f00595959460049495c685c49695c5a5a494957576b575700494b4c4b48005857585c5c576a4f58584e594d484f6b69567d5a59
000000000000000000000000000000000000005c5c0000000000000000005858585f000000004b00000000595959005858004b4b4b4b00000000575758585b5b000000000000004a005959464a59005959465c5c494949490049494949495c5740695c0000004c4c4b006a6a5c5c5748595c4f595958594d464d696b5a586953
00000000000000000000000000000000000000005959595959596b000000000300000000000000000000000000000000000000000000000000000000000000000000000000004a464646595949594659590059000000000000000000000000575c5c5c00004b4c47474b00585c5c6b6b5b5b59595700006b5a6b000000000000
00000000000000000000000000000000000000005c59595c5c5c5c59000000005959000000000000000058585b5b5b6a6a6a000000000000000000005959596a000000575b57005757464659595b5b000059595959595959000000000000006a595900004b4b4b4b484b0058586a5c7d575859575757576b6b6b575749575700
0056006b0056000000566a536b4056560000005959595a4e6e4e5c595900006a6a6a6a6a00000000005b585b5b585b6b6a6e6a595900575746575759594f594000005a5b57575c7d56565c57005a5b00004059385900006a5c696b0000586a7d5959590000000000005c4b5c00006b0040004e00575757575757575749495700
56486a56566a6a6a5a6a5a6a6a565a5300004e596b6b5a5a5a6759595a00595a596e596a6a000000005b5b5b6a6e6a5b6a6a6a4d000057465f465700004f596a005a5a5b575c5c5656575c57574a5b000059404f005c5c004d404d0058587600595c59595c5656005c5c5f5c5c005c574e570057575753575757535a47495700
005959564d4d4d4e004d4d5c5359566a4e4e0000596b595a5a5959595c00005a6a6a596a6a6a000000585b6a6a6a6a6a596a4d4d0000004646460000004e59590000575c005c56405c5c565c00575a5b004e4d4d596a5c5c4e4d4f5a5a6a4d59595900595c5c565c5c5c5c5c5c5c5c5c6b6b00574e6e5757576b576e4d495700
5c5c484e764d764e4c76764d5c48560000004e0058595c6b6b595959000000006a59596b00004e4000404e586a5b5b585959534d000000004a0000004f4e00000057575b4d57560056004f49565c5b00565959590000000000765a5c5a004e405959005c59565648485c5c5c5c480000006b6b6b004d4e5940584d4e00495700
475c0000484c4c4c404e4e4d48594c000000006e005c5c5c405c5c5c00006e006a6a006b0000000040005b585b5b0058000000000000004b7600000000000000005a5a49404f536e534e40495c5b5a56005a5a5c5c5c585a5a00000000004e4d5c5c005c5656564a4a5c5c5c5c48494a4a6b6b6b6b574d6757674d00004e5800
49465c4d4d4e4e4e484d4c4c484c464900004e4e5c5c5c5a00005a5c5c4e4e7d006a000000004e0000004e006a00000000000000000000004a000000000000000000564b4b49575b6a5c49565c5b5a0000595a5a5a5a5a5a4d404d00000000005c585900560059594a4848595959594949004d6b585a464d384d000047494d58
0049464d76484d4d7659464d4849000000005c5c5c0000005a5a0000005c5c5c000000006b4d4d4d4d4d4d4d6b0000000000000000000000764b00000000000000000000564b494b5c575b5b5b5a000000585c5a5a5a00004f4f4d6b005a6a585c5959595956594d595c5c004f594a4949564e4e58586b405f40574749495853
00594c4d4d4c4d5f4d4d4d4d4c000000005c5c00004e00004e00004e0000005c000000000000006b5f5900000000000000000000000000004a0000000000000000000000005757686957005a000000006a6a5c565a6a5c5c5c6b6b6a6a00585800590059565659595300005349494a494956404d56585a4f404f5a49496a6a53
00004c59496a4949475959590000000000000000000000005858464a5800004e00000000004000596b6b004000000000000000000000004b760000004f4e0000000000000057676068000000000000000056565a5c5c006a6a5c5c5c5c5c5a005c005c590056000053004053484949004e5656475658586b6b6b4749466a5358
00000000006a496a490000000000000000000000000000005846464a46584e530000000000000000590000000000000000004e0000005a5a59595a4e4646464f000000000057576957570000004f00004e4e005a5a4f4f4f0000005a5c5a5a00595959595656565900536e00484848760000564646465876760047496a6a6a4e
0000000000006a5c00000000006b00000000000000000000584640484858000057000000000000575700000000000000005a0000005a6b59596b4f4f464e4f4e0000000000004d4d4d000000000000005c0000005c76764d00005c5c5c59005c5c0059590056764e590000004d4e4e6b4d58584d46494900474749466a4d0000
4e5a4e004e6b6b5c004d004d4d4d4d4d0040760000000000584648484a585800575757575700595a5757575a575a0000004f404e5a595959566b594f4646464600000000004e5959594e000000000000405c00005c5a5c5c5c5f00005c5c5c5c5b5b5b59005959595656000059764e585859584e5849494949464646004e4e00
536a6a535b6b536a7d4d0000004d76766a4e00000000000000005846585800575759595957595a5a005a57575759590059594f5659596b567d0056594e4e4e464f00004f76595b5f5b5976000000004f5c0000004e5c5c00005c5c5c5c5c0000595b5b595959000056585800004e00005358594e58004d4f4e4e4e00004d7d00
406a405a5a4e5a5a5a4d534d0076764d5f00000000000000000000000000005757595959575700007d0000575a5a595959590056565959676e67594f4e6e46464f005300595c5c5c5c5959595300004f4e4e00004e005c5c5c5c5c00005900005900595656000058007d00594e0040594053584e4e7676764e7676764d4d4e4e
4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d4d00000000000000000000000000000000575757575757000000000000005957595900000056596a6a6b5959595600000000000000595c5c6b5c5c595900000000000000000000000000005c000059590059595b00565600585959594a4a00000058005800000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000575700000000000000000000000000000000000056595959595600000000000000000000005c5c6b6b0000000000000000000000000000000000000000595959595959000056565656004a0000000000000000000000000000000000000000
__sfx__
000100000e0500e0500e0500f0500d050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001502515025180251c025210251c02518025150251402514025180251c025210251c02518025150251302513025180251c025210251c02518025130251202512025180251c025210251c0251802512025
01100000110251102515025180251c025180251502511025100251002515025180251c0251802515025100250f0250f02515025180251c02518025150250f025100251002515025180251c025180251502510025
0110000007030070300e0300e03007030070300e0300e0300a0300a03011030110300a0300a03011030110300c0300c03013030130300c0300c03013030130300f0300f03016030160300f0300f0301603016030
011000001c7301c7301c7301c7301c7301c7301c7301c7301c7301c7301c7301c730157301573015730157301f7301f7301f7301f7301f7301f73021730217302173021730217302173000700007000070005700
011000002473024730237302373021730217301f7301f7301f7301f7301c7301c7301a7301a7301c7301c7302173021730217302173021730217302173021730237302373023730237303900032000281002f100
011000002d722217222d722217222d722217222d722217222d722217222d722217222d722217222d722217222b7221f7222b7221f7222b7221f7222b7221f722287221d722287221d722287221c722287221c722
01100000297221d722297221d722297221d722297221d722287221c722287221c722287221c722287221c722277221b722277221b722277221b722277221a722287221c722287221c722287221c722287221c722
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011200001b2501500017000172501b2501b00000000000001a000190001900019250190001b0001b250000001c2500000000000192501c2500010000000000000000000000000000000000000000000000000000
011200000b0500000000000060500b0500000000000000000000000000000000905000000150000b050000000d0501500000000080500d0500000000000000000000000000000000000000000000000000000000
01120000154002760332625276033262531300312003110032625326033160032625316001a600326251c6001d600216003262521600326250000000000000003262500000000003262500000000003262500000
011310201b2001500017000172001b2001b00000000000001a000190001900019200190001b0001b200000001c2000000000000192001c2000010000000000002f2002d2002f22015303153232f2202220102605
0112000017255172551b2551e2551e200000001e20000000000001b2201a0001e2201e2001b220172201b20019255192551c255202551f2002020020200202000000000003000000000000000000000000000000
0112000017255172551b2551e2551e200000001e20000000000001b2201a0001e2201e2001b220172201b20019255192551c255202551f2252022020220202200000000003000000000000000000000000000000
011200000b0500b050120001205012050000000b0500b050000001200012050120500b0000b0500b050000000d0550d050000001405514050000000d0500d05000000000001405014050000000d0500d0500f000
01120000311202a1002c12030120311002c1202f1002f1202c1002c1202e1002e1202c1002c120301002c100301202d1002b1202f1202f1002b120311002e120301002b1202f1002e1202c100301203010031100
01120000050531815307053070531815318153180030c625050531815307053070531815318153180030c625050531815307053070531815318153180030c625050531815307053070531815318153000000c625
011200000010000100001000000000100001000010020150251502715028150271502510025150281002a15000100271502a100001000010000100001002a1002a150001002a1002715000100271002515000100
011200000010000100001000010000100001002010020150251502715028150271502510025150281002a1502a15028111281102a15100100001000010025150281502c1002c1503010030150311003115031150
0112000000100001000010000100000000010000100201502515027150281502c15028100281502a1502a15023131231502a100001000010000100001002a1002a150001002a1002715000100271002515000100
011200000010000100000000010000100001000010020150251502715028150271502510025150281002a1502a150281112a1000010000100001000010025150281502c1502c1002815000000241002414025140
01120000000003e6033e6153e6033e6153e6053e6033e6033e6153e6003e603396153e6033e6003e6133e600000003e6033e6153e6033e6153e6053e6033e6033e6153e6003e603396153e6033e6003e6133e600
011200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000805008050000000405004050000000105001050
01120000000000000000000000000000000000000000000000000000000000000000000000000000000000000d1001010100000281002a1010010000100011500415008150301000415031100011500115000000
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
00080000000001c05029000230502a00033050340502a000000000000016000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001f13015640156402b1202b1102b1100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000e2500e1500e25000200274502745000200244501d45022450234501d4500020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
00040000115201053011540136001360015600166001f1001e1001e10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000001001a1501a150001000715006150091500b1500b15005150061500715000100001000010000100001000010000100001000010000100001000010000100001001f1000010000100001000010000100
00030000255500455000000000002b550045500050003550205500355000000285500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000190301e040220402200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000000001f050220502305023050140500d0400c040080300703005030010300003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003735037350373503330033300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00020000027300273002730186400a7401f6500e750236500d750246502465024650077501e65007750186501765016650146401364010640106400c6300c6300872006620057200361003610026100261000610
000200002a1502a1502a1402a1402713027130271302f1202f1202f1102f1302f1302f1302f1002f1002f1002f1002b1002f10000000000000000000000000000000000000000000000000000000000000000000
000200002e05031050320502e05030050310502c0502e050320503705033000360003700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002315024150181501a1501c1501e1501e1503215020150201501e150371501b1501715030150111501a1500b150081500915004150001501a0500415000150021501d1500415007150121500f1500a150
000100001c73025730227401e75019750137600f7601077012760147500e7301662014650145500c5501155000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001505017060260401004016040190402504009030080201302005020110200b01008050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b61006540065401963018630106100e6100c610096100861000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000100301e03028030240201e0302f34013230311201722038340202403c12026210393503214024040200300a7300a72002400034000240003400034000340003400034000340003400034000000000000
000100001d0302104025050290602e76034750397503a74032740187302573013020130201402015720177101a72021720207201d7201b720187201772010020100100f0100e0100e0100e010025000250002500
000100001f0301f03013030140303501035010390102c0102c0102b01026010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002203029030240402303015030120100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c520155301e510145401450000000175201b5201a5100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01 42 43 44
00 02 42 43 44
00 01 42 04 44
00 02 42 05 44
00 01 06 43 44
02 02 07 43 44
00 03 42 43 44
00 41 42 43 44
01 0a 0b 0c 44
00 0a 0b 0c 0d
01 0e 10 0c 44
02 0e 10 0c 44
01 12 13 17 18
00 12 14 17 19
01 12 15 17 18
00 12 16 17 19
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
