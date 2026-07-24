pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- mausoleum quest
-- by sprvrn

-- twitter @vrnspr
-- https://sprvrn.itch.io
txtblk,scrndur,debug,faded,fading,nfade,fadeblack,t
=true,0,"",0,false,0.1,false,0

ending=0
colfadeend=1

function _init()
 upd,drw=upd_title,drw_title
 
 for x=0,3 do
 	for y=0,7 do
 		make_map(y*16,x*16)
 	end
 end
 
 local leftarea={7,8,15,16,23,24,31,32}
 for m in all(leftarea)do
 	maps[m].colors=
  	{{1,8},
  	{14,6},
  	{8,2},
   {2,1},
   {13,14},
   {12,7}}
 end
 
 make_event("29,65,54,65,54")
 make_switch("28,115,60,57,48,56,48,57")
 
 make_switch("26,115,25,63,23,52,24,53")
 make_switch("26,115,19,49,16,50,22,50")
 
 make_event("25,1,48,2,48")
 make_switch("25,115,14,62,3,59,10,60")
 
 make_event("17,7,32,8,32")
 
 make_switch("19,115,13,21,13,24,14,24")
 
 make_event("1,9,2,10,3")
 
 make_event("3,47,6,47,7")
 
 make_event("4,63,6,63,6")
 
 make_event("6,88,15,88,15")
 
 make_switch("9,115,13,22,13,24,15,24")
 
 make_switch("18,115,28,37,19,37,26,42")
 make_event("18,23,47,24,49")
 
 make_event("10,30,31,30,31")
 make_switch("10,115,22,25,23,15,24,16")
 make_switch("10,115,21,19,22,19,22,20")
 
 make_switch("13,115,66,23,72,24,78,27")
 make_switch("13,115,78,30,67,21,68,22")
 make_switch("13,115,73,16,65,24,69,30")
 
 make_event("12,48,16,62,21")
 
 make_switch("19,115,46,46,44,36,44,44")
 make_switch("19,115,40,41,38,44,38,44")
 
 make_switch("21,115,65,45,67,36,74,46")
 make_switch("21,116,67,36,65,37,74,46")
 make_event("21,79,45,79,46")
 
 make_event("30,79,59,82,60")
 
 make_event("31,107,48,110,48")
 
 make_switch("15,115,97,27,100,22,101,23")
 make_switch("15,115,97,19,100,19,101,20")
 make_switch("15,115,103,19,98,17,100,17")
 make_switch("15,115,98,16,103,17,105,17")
 make_switch("15,115,106,19,106,30,108,30")
 
 make_switch("16,115,115,30,120,16,121,31")
 make_switch("16,115,113,17,122,16,123,31")
 make_switch("16,115,116,17,124,16,125,31")
 make_event("16,118,17,119,20")
 
 make_switch("7,115,100,3,103,3,103,14")
	make_switch("7,115,106,12,107,3,107,14")
	make_event("7,111,4,111,12") 
	
	make_switch("32,115,113,58,113,54,114,55")
	make_event("32,111,60,112,61")
	
 player=make_ent(1,7,56,40,1,2)
 player.boxy,player.spawnmap,player.animspeed
 =1,maps[20],10
 
 --1 walking drone
 make_monster(9,2,1,1,2,0.07,0.05,true,follow)
 --2 shooting drone
 make_monster(25,1,1,1,2,0.07,0.05,false,follow_shoot)
 --3 laser drone
 make_monster(7,1,1,1,2,0.07,0.05,false,follow_laser)
 --4 guard drone
 make_monster(40,3,1,2,2,0.07,0.05,false,follow_attack,0,1,1,1)

 --5 laser boss
 make_monster(42,15,2,2,1,0,0,false,follow_laser,0,0,2,2)
 monsters[5].massive=true
 
 --6 core boss
 make_monster(44,2,2,2,1,0,0,false,multiple_shoot,0,0,2,2)
 monsters[6].massive=true
 
 --7 dopple boss
 make_monster(1,60,1,2,4,0.10,0.10,false,follow_attack,0,1,1,1)
 
 spawn(player)
end

function _update()
	t+=1
 upd()
end

function _draw()
 cls()
 drw()
end

function upd_title()
	if btn(0) or btn(1) or btn(2) or btn(3) then
		upd,drw=upd_game,drw_game
		fade_scr(1)
		spawn(player)
	end
end

function drw_title()
 print_shadow("\x8b\x91\x94\x83",50,90,7,5)
end

function upd_game()
 player_controls()
 foreach(entities,update_entity)
 foreach(cmap.items,item_a)
 foreach(wpnspr,update_wpnspr)
 foreach(entities,collide_weap)
 foreach(particles,update_particle)
 
 c_ending()
end

function drw_game()
	draw_map_screen()
end

function upd_ending()

end

function drw_ending()
	print("a game by",40,110,7)
	print("sprvrn",78,111,2)
	print("sprvrn",79,110,8)
end

function c_ending()
	if ending>0 then
 	if ending==1200 then
 		act_tile(33,52)
 		act_tile(47,56)
 		act_tile(47,57)
 		shake(200)
 	end
 
 	ending-=1
 	
 	if ending>=1000 and ending%10==0 then
 		sfx(8)
 		smoke(rnd(127),rnd(127),{7,0,5,6})
 	end
 	
 	if(ending==1000)sfx(4)
 	
 	if ending>=50 and ending<1000 and ending%50==0 then
 		blood(rnd(127),rnd(127),{12,1})
 		shake()
 		add(cmap.colors,{colfadeend,0})
 		colfadeend+=1
 	end
 	
 	if(ending>100)player.speed=lerp(0,0.15,ending/1000)
 
 	if ending==100 then
 		player.speed=0
 		player.sprite=6
 		playerui=false
 		fade_i()
 	end
 	
 	if ending==0 then
 		upd,drw=upd_ending,drw_ending
 	end
 end
end

function eq(var,t)
	local d=strspl(t,",")
	for i in all(d)do
		if(var==i)return true
	end
	return false
end

function print_shadow(txt,x,y,c1,c2)
 if t%20==0 then
 	txtblk=not txtblk
 end
 if txtblk then
 	print(txt,x+1,y+1,c1)
 else
  print(txt,x+1,y+1,c2)
  print(txt,x,y,c1)
 end
end

function sheetcoord(s)
 return {x=(s%16)*8,y=flr(s/16)*8}
end

function loading()
	return not ((scrx==0 and scry==0)and not fading)
end

function round(num, numdecimalplaces)
 local mult = 10^(numdecimalplaces or 0)
 return flr(num * mult + 0.5) / mult
end

--string split(string, seperator)
function strspl(s,sep)
 ret,bffr = {},""
 for i=1, #s do
  if (sub(s,i,i)==sep)then
   add(ret,bffr)
   bffr=""
  else
   bffr = bffr..sub(s,i,i)
  end
 end
 if (bffr!="") add(ret,bffr)
 return ret
end

function splitint(str)
	local d=strspl(str,",")
 for k,v in pairs(d)do
 	d[k]=tonum(v)
 end
 return d
end

function anim(e,start,frames,speed)
	if (not e.ctframe)e.ctframe=0
	if (not e.curframe)e.curframe=0
	e.ctframe+=1
	if(e.ctframe%(30/speed)==0) then
	 e.curframe+=1
  if(e.curframe==frames)e.curframe=0
	end
	
	return start+e.curframe*e.width
end

function distance(x,y)
	return sqrt(x*x+y*y)
end

function normalize(x,y)
	local d=distance(x,y)
	return x/d,y/d
end

function lerp(st,ed,t)
 return st+t*(ed-st)
end

function linepoint(ax,ay,bx,by)
	local n=max(abs((bx)-(ax)),abs((by)-(ay)))
	local pts={}
	for step=0,n do
		local t=nil
		if n==0 then
		 t=0.0
		else
			t=step/n
		end
		local tx,ty=round(lerp(ax,bx,t)),round(lerp(ay,by,t))
	 add(pts,{tx,ty})
	end
	return pts
end

function fade_o()
	faded,fading,nfade=0,true,0.05
end

function fade_i()
	faded,fading,nfade=1,true,-0.05
end

function update_fade()
	if fading then
		faded+=nfade
		fade_scr(faded)
		if nfade<0 and faded<0 then
		 fadeblack,fading=false,false
		elseif nfade>0 and faded>1 then
			fadeblack,fading=true,false
		end
	end
end

function fade_scr(fa)
	fa=max(min(1,fa),0)
	local fn,pn,fades_data,fades=8,15,{
		"1,1,1,1,0,0,0,0",
		"2,2,2,1,1,0,0,0",
		"3,3,4,5,2,1,1,0",
		"4,4,2,2,1,1,1,0",
		"5,5,2,2,1,1,1,0",
		"6,6,13,5,2,1,1,0",
		"7,7,6,13,5,2,1,0",
		"8,8,9,4,5,2,1,0",
		"9,9,4,5,2,1,1,0",
		"10,15,9,4,5,2,1,0",
		"11,11,3,4,5,2,1,0",
		"12,12,13,5,5,2,1,0",
		"13,13,5,5,2,1,1,0",
		"14,9,9,4,5,2,1,0",
		"15,14,9,4,5,2,1,0}"
	},{}
	
	for f in all(fades_data)do
		add(fades,splitint(f,","))
	end
	
	local fc=1/fn
	local fi=flr(fa/fc)+1
	
	for n=1,pn do
		pal(n,fades[n][fi],0)
	end
end

function shake(sd)
	scrndur=sd or 5
end

function update_shake()
	camera()
	if scrndur>0 then
		scrndur-=1
	 camera(cos(scrndur/3),cos(scrndur/3))
	end
end
-->8
--entities

entities={}

function make_ent(s,colt,xx,yy,w,h)
	local e={
	life=1,maxlife=1,invuln=0,
	sprite=s,transparent=colt,
	x=xx,y=yy,
	spawnx=xx,spawny=yy,
	spawnmap=nil,
	animnframe=4,animespeed=5,
	width=w,height=h,
	dx=0,dy=0,
	accel=0.1,speed=0.15,
	lastdir="down",
	lookdown=true,lookleft=true,
	boxx=0,boxy=0,boxw=1,boxh=1,
	cddash=0,ctrespawn=0,
	t=0,
	display=true,
	atkflipy=false
	}
	add(entities,e)
	return e
end

function screen_pos(e)
	return 
	(e.x-cmap.x)*8+scrx,
	(e.y-cmap.y)*8+scry
end

function draw_entity(e)
 local epx,epy=screen_pos(e)
 if e.display then
  
  local ent_spr,st_anim=e.sprite,e.sprite
  if(e==player)st_anim+=1
  if(e.dx~=0 or e.dy~=0)ent_spr=anim(e,st_anim,e.animnframe,e.animespeed)
  if(e==player and playerwpn~=nil)ent_spr=2
  if(not e.lookdown and e.sprite==1)ent_spr+=16*e.height
  if(e==player and e.life==0)ent_spr=6
  
	 shadow(epx,epy+2+8*(e.height-1))
	 
  if(e.lookdown and e.sprite==1 and playerwpn==nil)draw_pole(e,epx,epy)
  
  if e==player and e.redscarf then
  	pal(1,8)
  end
  
  if e~=player and e.sprite==1 then
  	pal(12,0)
  	pal(5,0)
  	pal(1,5)
  	pal(6,0)
  	pal(15,7)
  end
  
  if e.atk then
   pal(13,8)
  end
  
  if e.invuln>0 then
  	for c=0,15 do
  		pal(c,7)
  	end
  end
  
  palt(0,false)
  palt(e.transparent,true)
  
 	spr(ent_spr,epx,epy,e.width,e.height,e.lookleft)
	 
	 if (e~=player and e.sprite==1)
	  or (e==player and e.redscarf) then
  	pal()
  end
	 
 	if (e.sprite==1 and e~=player and not e.atk)
 	 or (e==player and playerwpn==nil) then
    palt(7,true)
   local wpx=6
   if(e.lookleft)wpx=-wpx
   
   if(e.redscarf)pal(6,8)
   
   spr(15,epx+wpx,epy+12,1,1,e.lookleft)
   if(e.redscarf)pal()
   if(not e.lookdown)draw_pole(e,epx,epy)
  end
  
  palt(e.transparent,false)
 	palt(0,true)
 	
 	if(e.invuln>0)pal()
  
  if e.behav then
   if e.behav==follow_laser
    and e.lct and e.lasertargetx and e.lasertargety then
 			local pxx,pyy=screen_pos(player)
    
    local lasercolor=10
    if(e.lct>=50)lasercolor=8
    
    local lx,ly=get_laser_end(e)
    
    line(epx+4,epy,(lx-cmap.x)*8+4,(ly-cmap.y)*8,lasercolor)

 		 end
 		end
 		
   if(e.atk)pal()
 	end
end

function shadow(sx,sy)
	sp=sheetcoord(48)
	for x=sp.x,sp.x+7 do
		for y=sp.y,sp.y+7 do
		 if sget(x,y)~=0 then
		 	local pixx,pixy=sx+x-sp.x,sy+y-sp.y
		 	local c=pget(pixx,pixy)
		  local nc=0
		  if c<=5 or c==8 then
		   nc=0
		  elseif c==11 then
		   nc=3
		  elseif c==13 then
		  	nc=1
		  else
		  	nc=2
		  end
		  pset(pixx,pixy,nc)
		 end
		end
	end
end

function draw_pole(e,epx,epy)
	if (e==player and playerwpn==nil)
	or (e~=player and not e.atk)
	then	
 	local wv=6
 	if e.lookleft then
   line(epx-wv+7,
   epy+wv+6,
   epx+wv+7,
   epy-wv+6,0)
  else
   line(epx-wv,
   epy-wv+6,
   epx+wv,
   epy+wv+6,0)
  end
 end
end

function update_entity(e)
 if(e~=player)move_monster(e)

	if(e.invuln>0)e.invuln-=1
	
	if e.life<=0 then
	 e.dx,e.dy=0,0
	else
	 local spx,spy=screen_pos(e)
 
 	if playerwpn==nil and not e.dash then
  	if(e.dx>e.speed)e.dx=e.speed
  	if(e.dx<-e.speed)e.dx=-e.speed
  	if(e.dy>e.speed)e.dy=e.speed
  	if(e.dy<-e.speed)e.dy=-e.speed
  end
  if not solid_a(e,e.dx,0)then
   e.x+=e.dx
  end
  if not solid_a(e,0,e.dy)then
   e.y+=e.dy
  end
  
  if(e.dx>0)then
   e.lookleft=false
   e.lstdir="right"
  end
  if(e.dx<0)then
   e.lookleft=true
   e.lstdir="left"
  end
  if e.dy<0 then
   e.lookdown=false
   e.lstdir="up"
  end
  if e.dy>0 then
   e.lookdown=true
   e.lstdir="down"
  end
  if playerwpn~=nil then
  	e.dx,e.dy=0,0
  end

  if e.dash then
  	e.ctdash+=1
  	if e.t%2==0 and scrx==0 and scry==0 then
    smoke(spx,spy+4)
   end
  	if e.ctdash>=4 then
  	 e.dash,e.cddash=false,15
  	end
  end

  if(e.cddash>0)e.cddash-=1
  if pit_a(e) and not e.dash then
  	sfx(4)
  	e.life,e.display=0,false
  	splash(spx,spy+16)
  	if(e~=player)monster_dies(e)
  end
  e.t+=1
 end
end

function solid(x,y,f)
 f=f or 0
 return fget(mget(x,y),f)
end

function collider(e)
	local box,boy,bow,boh=0,0,1,1
	if e.boxx and e.boxy and e.boxw and e.boxh then
		box,boy,bow,boh=e.boxx,e.boxy,e.boxw,e.boxh
	else
		bow,boh=e.width,e.height
	end
	local x,y=
	(e.x+box),
 (e.y+boy)
	return 
	x,y,x+(bow),y+(boh)
end

function actorcollide(a1,a2)
	local ax1,ay1,ax2,ay2=collider(a1)
	local bx1,by1,bx2,by2=collider(a2)
	return 
	 ax1<bx2 and ax2>bx1 and
	 ay1<by2 and ay2>by1
end

function solid_area(x,y,w,h)
 return 
  solid(x-w,y-h) or
  solid(x+w,y-h) or
  solid(x-w,y+h) or
  solid(x+w,y+h)
end

function pit_area(x,y,w,h)
	return 
	 solid(x-w,y-h,1) and
  solid(x+w,y-h,1) and
  solid(x-w,y+h,1) and
  solid(x+w,y+h,1)
end

function solid_a(a,dx,dy)
 return solid_area(
    a.boxx+a.x+dx+0.5,
    a.boxy+a.y+dy+0.5,
    a.boxw/2-0.1,
    a.boxh/2-0.1) 
end

--check if all a's box is in a pit area (flag 1)
function pit_a(a)
 return pit_area(
    a.boxx+a.x+0.5,
    a.boxy+a.y+0.5,
    a.boxw/2-0.1,
    a.boxh/2-0.1) 
end

--check if the middle pixel of e1's box is inside e2
function middledot(e1,e2)
	local mex,mey=collider(e1)
	local x1,y1,x2,y2=collider(e2)
 mex,mey=mex+0.5,mey+0.5
 return
  (mex>=x1 and mex<=x2) and
  (mey>=y1 and mey<=y2)
end


-->8
--player

playerui,cdrespawn,gem_n=true,25,0

function player_controls()
 if player.life>0 then
  local px,py=screen_pos(player)
 	if not actorcollide(player,cmap)
 	and playerwpn==nil
 	then
 	 local nm=getmapfrom(player)
 	 pmap=cmap
 	 setmap(nm)
 	 if(pmap.x<cmap.x)pmap.mx,pmap.my=-128,0
   if(pmap.x>cmap.x)pmap.mx,pmap.my=128,0
   if(pmap.y<cmap.y)pmap.mx,pmap.my=0,-128
   if(pmap.y>cmap.y)pmap.mx,pmap.my=0,128
   scrx,scry=-pmap.mx,-pmap.my
 	end
 	
 	if not loading()
 	   and playerwpn==nil
 	   and not player.dash then
  	if btn(0)or btn(1)or btn(2)or btn(3) then
    if btn(4) 
    			and ending==0
       and not player.dash
       and player.cddash==0 then
   		player.dash,player.ctdash=true,0
   		sfx(1)
   		if(btn(0))player.dx-=0.8
   		if(btn(1))player.dx+=0.8
   		if(btn(2))player.dy-=0.8
   		if(btn(3))player.dy+=0.8
   		
   		if player.dx~=0 and player.dy~=0 then
   			player.dx/=1.3
   			player.dy/=1.3
   		end
    else
    	if btn(0) then
    		player.dx-=player.accel
    	elseif btn(1) then
    		player.dx+=player.accel
    	else
    	 player.dx=0
    	end
    	if btn(2) then
    		player.dy-=player.accel
    	elseif btn(3) then
    		player.dy+=player.accel
    	else
    		player.dy=0
    	end
    end
  	else
  		player.dx,player.dy=0,0
  	end
  	
  	if abs(player.dx)+abs(player.dy)>0.1 and not player.dash
      and player.t%10==0 then
    sfx(0)
    dust(px+4,py+16)
   end
  	
  	if btnp(5) and 
  	   playerwpn==nil then
  	 atk_spear(player,true)
  	end
  end
 else
 	--player is dead
 	if(player.ctrespawn<cdrespawn)player.ctrespawn+=1
 	if player.ctrespawn==cdrespawn then
 	 if not fading then
 	 	if not fadeblack then
 	 	 sfx(5)
 	 	 fade_o()
 	  else
 	 	 spawn(player)
 	  end
 	 end
 	end
 end
end

function spawn(e)
 fade_i()
	setmap(e.spawnmap)
	e.x,e.y,e.life,e.display,e.ctrespawn=
	e.spawnx,e.spawny-1,e.maxlife,true,0
end

function player_dies()
	player.life=0
	local px,py=screen_pos(player)
 blood(px,py,{13,12})
 shake(20)
end

function draw_player_ui()
	--tuto
 if cmap.x==48 and cmap.y==48 then
  print_shadow("\x8b + \x8e (z/c)",19,55,7,12)
 end
 if cmap.x==64 and cmap.y==48 then
  print_shadow("— (x)",30,70,14,8)
 end
 
 if ui_speak then
 	--local px,py=screen_pos(player)
 	local px,py=ui_speakx-5,ui_speakx-8
 	rectfill(px-1,py-1,px+24,py+11,7)
 	rect(px,py,px+23,py+10,0)
 	
 	spr(16,px+2,py+1)
 	print_shadow(ui_gem_asked,px+12,py+2,0,9)
 end

 --gems
 if playerui then
  spr(16,108,117)
  print(gem_n,119,119,9)
  print(gem_n,118,118,7)
 	if gem_ui_a then
 		gemuict+=1
 		if gemuict==25 then
 			gem_n+=1
 			gem_ui_a=false
 			sparkle(110,119,{10})
 			sfx(11)
 		end
 	end
	end
end
-->8
--map

maps,pmap,cmap,scrx,scry,waves=
 {},nil,nil,0,0,false

bg={}
 
function make_map(mx,my)
	local m={
	x=mx,y=my,width=16,height=16,
	items={},trees={},
	onmonsterkilled={},
	colors={},
	background=false,
	wave=true
	}
	for xm=mx,16+mx do
		for ym=my,16+my do
		 local tid=mget(xm,ym)
		 local tm=make_item(tid,xm,ym)
 	 if fget(tid,7)then
 	  mset(xm,ym,82)
 	  --monster
 	  tm.monster=true
 	  add(m.items,tm)
		 elseif tid==112 then
		  --tree
		 	add(m.trees,{xm-m.x,ym-m.y})
		 elseif tid==16 then
 	  --gem
 	  tm.gem,tm.mvy,tm.onact=true,1,gem_a
		  add(m.items,tm)
 	  mset(xm,ym,82)
 	 elseif tid==32 then
 	 	tm.sanctu,tm.onact=true,sanctu_a
 	 	add(m.items,tm)
 	 	mset(xm,ym,82)
 	 elseif tid==39 then
 	 	--skel npc
 	 	tm.perk,tm.onact,tm.height=1,skel_a,2
 	 	add(m.items,tm)
 	 	mset(xm,ym,121)
 	 end
 	end
 end
	add(maps,m)
	return m
end

function make_item(s,xx,yy)
	return {
	sprite=s,x=xx,y=yy,
	width=1,height=1,
	t=0,
	onact=nil
	}
end

function make_switch(str)
 local d=splitint(str)
 local sw=make_item(d[2],d[3],d[4])
 sw.activates,sw.onact={},switch_a
 for x=d[5],d[7] do
 	for y=d[6],d[8] do
 		add(sw.activates,{x,y})
 	end
 end
 add(maps[d[1]].items,sw)
end

function make_event(str)
 local d=splitint(str)
 maps[d[1]].onmonsterkilled=
  {d[2],d[3],d[4],d[5]}
end

function getitem(x,y)
	for i in all(cmap.items) do
		if i.x==x and i.y==y then
			return i
		end
	end
end

function getmapfrom(e)
	for mm in all(maps) do
		if actorcollide(e,mm) then
			return mm
		end
	end
end

function setmap(m)
	--set current map to m, clear every previous map data
	player.t,cmap,t,entities,wpnspr,particles,player.dx,player.dy,scrspeed=
	 0,m,0,{},{},{},0,0,10
	
	--create monster entities
	for item in all(m.items) do
		local mstr=getmonster(item.sprite)
	 local ix,iy=item.x,item.y
	 if mstr~=nil and not item.killed then
	 	make_monster_ent(mstr,ix,iy)
	 end
	end
	
	--add player entity back in the list
	add(entities,player)
end

function draw_sanctu_beam(s)
	if s.sanctu then
		if sanctu_activated(s) then
		 local ix,iy=
	   (s.x-cmap.x)*8+scrx,(s.y-cmap.y)*8+scry
	
		 rectfill(ix+5+cos(t/5),iy+5,ix+2+cos(t/5),iy-127,7)
		 rectfill(ix+5,iy+5,ix+2,iy-127,12)
		 if(s.t%5==0)sparkle((scrx+s.x-cmap.x)*8+4,(scrx+s.y-cmap.y)*8+4,{7})
	 end
	end
end

function draw_map_item(mi)
	local ix,iy=screen_pos(mi)
	
	mi.t+=1
	
	if mi.activates then
		--switch
		spr(mi.sprite,ix,iy)
	elseif mi.gem then
  --gem
		if (mi.t%20==0) then
		 mi.mvy=-mi.mvy
		 sparkle(ix,iy,{9},{9,10})
		end
		spr(48,ix,iy+2)
		spr(mi.sprite,ix,iy+mi.mvy)
	elseif mi.sanctu then
	 --sanctuary
	 spr(mi.sprite,ix,iy)
	elseif mi.onact==skel_a then
	 pal(6,5)
	 spr(39,ix+1,iy-1,1,2)
	 pal()
	 spr(39,ix,iy,1,2)
	 if t%20==0 then
	  luciole(ix+4,iy+8)
	 end
	end
end

function draw_map_screen()
	update_shake()
	
	--screen transition
	if scrx<0 then
	 scrx+=scrspeed
	 if(scrx>0)scrx=0
 end
	if scrx>0 then
		scrx-=scrspeed
	 if(scrx<0)scrx=0
	end
	if scry<0 then
	 scry+=scrspeed
	 if(scrx>0)scry=0
 end
	if scry>0 then
		scry-=scrspeed
	 if(scry<0)scry=0
	end
	
	switch_color_map(cmap,true)
	
	if pmap~=nil then
	 scrspeed-=0.4
 	map(pmap.x,pmap.y,
 	 scrx+pmap.mx,
 	 scry+pmap.my,
 		pmap.width,pmap.height)
	end
	if scrx==0 and scry==0 then
		pmap=nil
	end
	
	
	map(cmap.x,cmap.y,
	scrx,scry,cmap.width,cmap.height)
	
	switch_color_map(cmap,false)
	
	draw_wave()
	
	foreach(cmap.items,draw_map_item)
	foreach(particles,draw_particle)
	foreach(entities,draw_entity)
 foreach(cmap.items,draw_sanctu_beam)
	foreach(wpnspr,draw_wpnspr)
	foreach(cmap.trees,draw_tree)
	
	draw_player_ui()
	
	update_fade()
end

function switch_color_map(m,b)
	if (#cmap.colors>0) then
	 if b then
 	 for c in all(cmap.colors) do
 	 	pal(c[1],c[2])
 	 end
	 else
	  pal()
	 end
	end
end

function draw_wave()
	if cmap.wave then
 	if t%30==0 then
 		waves=not waves
  	if waves then
   	for x=cmap.x,cmap.x+cmap.width do
   		for y=cmap.y,cmap.y+cmap.height do
   			if mget(x,y)==80 then
   			 mset(x,y,79)
   		 elseif mget(x,y)==79 then
   		  mset(x,y,80)
   		 end
   	 	if mget(x,y)==96 then
   	 	 mset(x,y,95)
   		 elseif mget(x,y)==95 then
   		  mset(x,y,96)
   		 end
   		end
   	end
  	end
	 end
	end
end

function nearestwalkable(e)
	local x,y=
	 round(e.x)+e.boxx,
	 round(e.y)+e.boxy
	if walkable(x,y) then
	 return x,y
	else
		if(walkable(x+1,y))return x+1,y
		if(walkable(x-1,y))return x-1,y
		if(walkable(x,y+1))return x,y+1
		if(walkable(x,y-1))return x,y-1
	end
	return x,y
end

function draw_tree(t)
	local tx,ty=t[1]*8+3+scrx,
	t[2]*8-15+scry
	circfill(tx+1,ty+1,15,5)
	circfill(tx,ty,15,13)
end

function item_a(i)
 ui_speak=false
 
 if i.onact~=nil then
 	for e in all(entities)do
 	 if i.onact==skel_a then
 	  if actorcollide(i,player) then
 	  	i.onact(i)
 	  end
   else
 	  
  	 if middledot(e,i) then
  	 	if (e~=player and i.onact==switch_a)
  	 	 or (e==player)
  	 	 then
  	 		i.onact(i)
  	 	end
  	 end
 	 end
 	end
	end
end

--check if sanctu s is activated
function sanctu_activated(s)
 return
 player.spawnx==s.x+1
 and player.spawny==s.y+1
end

function sanctu_a(s)
 if not sanctu_activated(s) then
	 player.spawnx,
	 player.spawny,
	 player.spawnmap=
	  s.x+1,s.y+1,cmap
	 sfx(3)
  shake(5)
	end
end

function skel_a(s)
	ui_speak=true
	
	ui_speakx,ui_speak_y=screen_pos(s)
	
	check_gem(s,10,15,perk3)
	check_gem(s,5,10,perk2)
	check_gem(s,1,5,perk1)
end

function check_gem(s,amount,next_perk,perk_function)
	if s.perk==amount then
	 ui_gem_asked=amount
		if (gem_n>=amount) then
			perk_function(s)
			s.perk=next_perk
		end
	end
end

function perk1(s)
	act_tile(33,52)
	shake(10)
	sfx(10)
end

function perk2(s)
	shake(10)
	sfx(10)
	player.redscarf=true
end

function perk3(s)
	shake(10)
	--sfx(10)
	cmap.colors={{8,7},{14,0},{3,13},{2,5},{4,0},{11,13},{9,7}}
	
	make_monster_ent(monsters[7],39,52)
 local tm=make_item(1,39,52)
 tm.monster=true
 add(cmap.items,tm)
 
 del(cmap.items,s)
end

function gem_a(s)
 local ix,iy=screen_pos(s)
	sfx(12)
	gem(ix,iy)
	gem_ui_a,gemuict=true,0
	del(cmap.items,s)
end

function switch_a(s)
	if s.sprite==115 then
		s.sprite=116
 	activation(s)
 end
end

function activation(s)
	sfx(4)
 local ix,iy=screen_pos(s)
 sparkle(ix,iy,{12})
 shake()
 for a in all(s.activates)do
  act_tile(a[1],a[2])
 end
end

function act_tile(ax,ay)
 local v=mget(ax,ay)
 if v==113 then
  	mset(ax,ay,114)
  	dust_spike(
  	 (ax-cmap.x)*8,(ay-cmap.y)*8)
	end
	if(v==114)mset(ax,ay,113)

 if v==108 or v==109 or v==124 or v==125 then
  
  splash((ax-cmap.x)*8+4,(ay-cmap.y)*8+8,3)
  
  if(v==108)mset(ax,ay,65)
  if(v==109)mset(ax,ay,67)
  if(v==124)mset(ax,ay,97)
  if(v==125)mset(ax,ay,99)
  
  if((v==125 or v==124)and mget(ax,ay+1)==64)mset(ax,ay+1,80)
 end
 
 if v==65 or v==67 or v==97 or v==99 then
 	splash((ax-cmap.x)*8+4,(ay-cmap.y)*8+8,3)
  
 	if(v==65)mset(ax,ay,108)
  if(v==67)mset(ax,ay,109)
  if(v==97)mset(ax,ay,124)
  if(v==99)mset(ax,ay,125)
 end
    	
 local ti=getitem(ax,ay)
 if (ti) then
 	sparkle(ti.x*8,ti.y*8+8,{10})
 	if(ti.sprite==115)ti.sprite=116
 	if(ti.sprite==116)ti.sprite=115
 end
end
-->8
--weapons

wpnspr={}
playerwpn=nil

function make_wpnspr(s,xx,yy,w,h,f,nf,exp)
	nf=nf or 2
	exp=exp or 10
	local w={
	sprite=s,
	x=xx,y=yy,
	dx=0,dy=0,
	nframe=nf,
	width=w,height=h,
	flipx=f,flipy=false,
	ctframe=0,
	expire=exp,
	colswi={}
	}
	add(wpnspr,w)
	return w
end

function draw_wpnspr(ws)
	local wpns,ww,wh=ws.sprite,ws.width,ws.height
	local wx,wy=screen_pos(ws)
	
	--spear
	if ws.sprite==31 then
		local s,fx,fy,mwx,mwy=31,false,false,0,0
		if ws.dx~=0 then
			line(wx,wy+4,wx+16,wy+4,0)
			s=47
			if ws.dx>0 then
				fx,mwx=true,8
			end
		end
		if ws.dy~=0 then
			line(wx+4,wy,wx+4,wy+16,0)
			s=31
			if ws.dy>0 then
				fy,mwy=true,8
			end
		end
		if(player.redscarf and ws.player)pal(6,8)
		spr(s,wx+mwx,wy+mwy,1,1,fx,fy)
	 if(player.redscarf and ws.player)pal()
		
	else
	
		--other
 	if(ww<1)ww=1
 	if(wh<1)wh=1
 	if(ws.nframe>1 and ws.ctframe>=3)wpns+=ws.width
 	
 	for c in all(ws.colswi)do
 		pal(c[1],c[2])
 	end
 	
 	spr(wpns,wx,wy,ww,wh,not ws.flipx,ws.flipy)
  pal()
  
  if ws.dx!=0 and ws.dy!=0 then
  	if(t%5==0)sparkle(wx,wy,{7})
  end
 end
end

function update_wpnspr(ws)
	ws.x+=ws.dx
	ws.y+=ws.dy
	ws.ctframe+=1
	if ws.ctframe>=ws.expire then
	 if(ws==playerwpn)playerwpn=nil
		del(wpnspr,ws)
 end
end

function collide_weap(e)
 local px,py=screen_pos(e)
	for w in all(wpnspr)do
		if (e.invuln==0
		   and (w.player and e~=player)
		   and actorcollide(e,w)
		   and sees_player(e))
		   and e.life>0
		   or
		   ((not w.player and e==player)
		   and actorcollide(e,w)
		   and e.life>0
		   )
		   then
			if w.player and player.redscarf then
			 e.life-=2
			else
			 e.life-=1
			end
			e.invuln=10
			shake()
			sfx(6)
			if (e~=player)dmg_splash(px,py,player.lookleft)
			if e~=player and not e.massive then
				if(player.lookleft)e.dx=-0.5
		 	if(not player.lookleft)e.dx=0.5
		 end
			if e.life<=0 then
		 	if e==player then
		 		player_dies()
		 	else
		 		monster_dies(e)
	 	 end
		 end
		end
	end
end

function atk_spear(e,pl)
	local wvx,wvy,w,h,wdx,wdy=1,2,2,1,0.1,0
 
 e.dx,e.dy=0,0
 
 if e.lookleft then
  wvx,wvy=-2,2
  wdx=-wdx
  e.dx-=0.2
 else
  e.dx+=0.2
 end
 if e.lstdir=="down" then
  wvx,wvy,w,h,wdx,wdy,e.dx=0,3,1,2,0,0.1,0
  e.dy+=0.2
 end
 if e.lstdir=="up" then
  wvx,wvy,w,h,wdx,wdy,e.dx=0,0,1,2,0,-0.1,0
  e.dy-=0.2
 end
 
 local weap=make_wpnspr(31,
  e.x+wvx,
  e.y-1+wvy,
  w,h,e.lookleft)
 if pl then
  playerwpn=weap
  playerwpn.player=true
 end
 
 weap.dx,weap.dy,e.expire=wdx,wdy,2
 sfx(2)
end

function atk_slash(e,pl,c,w,h)
	c,w,h=c or {},w or 2, h or 2
	
 local wvx,wvy=1.2,1
 
 e.dx,e.dy=0,0
 
 if e.lookleft then
  wvx,wvy=-2.2,1
  e.dx-=0.2
 else
  e.dx+=0.2
 end
 if e.lstdir=="down" then
  wvx,wvy,e.dx=0,3,0
  e.dy+=0.2
 end
 if e.lstdir=="up" then
  wvx,wvy,e.dx=0,-0.3,0
  e.dy-=0.2
 end
  	 
 local weap=make_wpnspr(11,
  e.x+wvx,
  e.y-1+wvy,
  w,h,e.lookleft)
 if pl then
  playerwpn=weap
  playerwpn.player=true
 end
 
 e.expire,weap.colswi=3,c
 sfx(2)
end
-->8
--particles

particles={}

function make_particle(xx,yy,vvx,vvy,aax,aay,exp,c,ps,psp,txt,sm)
 psp,txt,sm=
  psp or 0,txt or nil,sm or 2
 add(particles,
 {
 x=xx,y=yy,
 vx=vvx,vy=vvy,
 ax=aax,ay=aay,
 cols=c,
 expire=exp,
 size=ps,
 sprite=psp,
 text=txt,
 ctframe=0,
 sizemode=sm
 })
end

function update_particle(p)
	if(p.ctframe==p.expire)then
		del(particles,p)
	else
		p.vx+=p.ax*0.5
		p.vy+=p.ay*0.5
		p.x+=p.vx*0.5
		p.y+=p.vy*0.5
	end
	p.ctframe+=1
end

function draw_particle(p)
 local pax,pay=p.x+scrx,p.y+scry
 rndcol=p.cols[flr(rnd(#p.cols)+1)]
 if p.text~=nil then
 	--print_outline(p.text,pax,pay,rndcol,7)
 elseif p.sprite~=0 then
 	if(rndcol~=7)pal(7,rndcol)
 	spr(p.sprite,pax,pay)
 	pal()
 else
  local psize=flr(rnd(p.size))
 	if(p.sizemode==1)psize=p.ctframe/4
 	if(p.sizemode==2)psize=p.size
 	circfill(pax,pay,psize,rndcol)
 end
end

function splash(x,y,si)
 si=si or 1
	for i=1,20 do 
 	make_particle(
 	 x+rnd(2)-1,y,
 	 rnd(4)-2,-rnd(2.5)-0.5,
 	 0,0.3,
 	 flr(rnd(20))+5,{12},si
 	)
	end
end

function dmg_splash(x,y,d)
	for i=1,10 do
		local dvx,dvy=rnd(2)+2,rnd(3)-1.5
	 if d then
	 	dvx=-dvx
	 end
 	make_particle(
 	 x,y,
 	 dvx,dvy,
 	 -(dvx/10),0,
 	 flr(rnd(18))+10,{7},1
 	)
	end
end

function gem(x,y)
 local vx,vy=(115-x)/10,(120-y)/10
	make_particle(
	 x,y,
	 vx,vy,
	 -0.1,-0.1,
	 25,{9},1,16
	)
end

function dust(x,y)
 make_particle(
 	x,y,
 	0,-1,
 	0,0,
 	12,{6},3,0,nil,1
 )
end

function luciole(x,y)
	for i=1,3 do
	 make_particle(
 	 x+rnd(2)-1,y,
 	 rnd(4)-2,-rnd(2.5)-0.5,
 	 0,0,
 	 flr(rnd(20))+5,{9,10},1
 	)
 end
end

function sparkle(x,y,c)
	c=c or {7}
	for i=1,5 do
		make_particle(
 	 x,y,
 	 rnd(5)-2,
 	 rnd(5)-2,
 	 0,0,
 	 flr(rnd(20))+5,c,1
 	)
	end
end

function dust_spike(x,y,c)
	c=c or {6}
	for i=1,10 do
		make_particle(
 	 x,y,
 	 rnd(4)-2,
 	 rnd(4)-2,
 	 0,0,
 	 flr(rnd(25))+5,c,4,0,nil,1
 	)
	end
end

function blood(x,y,c)
	c=c or {7,8}
	for i=1,10 do
		make_particle(
 	 x,y,
 	 rnd(3)-1,rnd(3)-1,
 	 0,0,
 	 flr(rnd(80))+10,{c[flr(rnd(#c))+1]},5,0,nil,1
 	)
	end
end

function smoke(x,y,c)
	c={6,5}
	for i=1,10 do
		make_particle(x,y,
 	 rnd(4)-2,
 	 rnd(4)-2,
 	 0,0,
 	 flr(rnd(20))+5,{c[flr(rnd(#c))+1]},5,0,nil,1
 	)
	end
end
-->8
--monsters

monsters={}

function make_monster(s,l,w,h,af,ac,spe,ht,beh,bx,by,bw,bh)
 bx,by,bw,bh=bx or 0,by or 0,bw or 1,bh or 1
 
 add(monsters,{
		sprite=s,
		life=l,
		width=w,height=h,
		nframe=af,
		speed=spe,accel=ac,
		hurtontouch=ht,
		behav=beh,
		boxx=bx,boxy=by,boxw=bw,boxh=bh
	})
end

function make_monster_ent(mo,x,y)
	
	local tm=make_ent(mo.sprite,7,x,y,mo.width,mo.height)
 tm.life,
 tm.animnframe,
 tm.path,
 tm.behav,
 tm.accel,
 tm.boxx,
 tm.boxy,
 tm.boxw,
 tm.boxh,
 tm.massive,
 tm.lct,
 tm.speed,
 tm.hurtontouch,
 tm.lstknownpos
 =
 mo.life,
 mo.nframe,
 {},
 mo.behav,
 mo.accel,
 mo.boxx,
 mo.boxy,
 mo.boxw,
 mo.boxh,
 mo.massive,
 0,
 mo.speed,
 mo.hurtontouch,
 {x,y}
 
 tm.targetx,tm.targety=tm.x,tm.y
end

function getmonster(msp)
	for mstr in all(monsters) do
		if msp==mstr.sprite then
			return mstr
		end
	end
end

function player_in_range(e,d,od)
	local x1,y1=collider(e)
	local x2,y2=collider(player)
	local di=distance(x2-x1,y2-y1)
	if di<=d then
		return true
	end
	return false
end

function sees_player(e)
	if (player.life<=0)return false
	for p in all(linepoint(e.x,e.y,player.x,player.y+1)) do
		if(solid(p[1],p[2]))return false
	end
	return true
end

function setmove(e,tax,tay)
	e.moving,e.startx,e.starty,e.targetx,e.targety
	 =true,e.x,e.y,tax,tay
 e.distance=distance(e.targetx-e.startx,e.targety-e.starty)
 e.dirx,e.diry=
  (e.targetx-e.startx)/e.distance,
  (e.targety-e.starty)/e.distance
end

function pathtoplayer(e)
	if e.t%15==0 then
 	e.path=findpath(
 	{nearestwalkable(e)},
 	{e.lstknownpos[1],e.lstknownpos[2]})
	end
end

function follow(e)
	e.aggro=sees_player(e)
 if e.aggro then
	 e.lstknownpos={nearestwalkable(player)}
 end
 if e.lstknownpos~=nil then
  pathtoplayer(e)
 end
end

function follow_shoot(e)
	if sees_player(e) and player.life>0 then
	 e.lstknownpos={nearestwalkable(player)}
 end
 local nlstx,nlsty=nearestwalkable(player)
 if e.lstknownpos[1]==nlstx
 and e.lstknownpos[2]==nlsty then
  e.lct+=1
  e.lookdown=true
  if e.lct==50 then
   e.lct=0
   shoot(e)
  end
 else
 	pathtoplayer(e)
 end
end

function multiple_shoot(e)
	e.lookdown=true
	
	if sees_player(e) and player.life>0 then
	 e.lstknownpos={nearestwalkable(player)}
 end
 
 local nlstx,nlsty=nearestwalkable(player)
 if e.lstknownpos[1]==nlstx
 and e.lstknownpos[2]==nlsty then
 	e.lct+=1
  if e.lct>=60 and e.lct%10==0 then
   shoot(e)
   e.atk=true
  end
  
  if e.lct==110 then
  	e.lct=0
  	e.atk=false
  end
 end
end

function shoot(e)
	sfx(7)
 local plcx,plcy=collider(player)
 local w=make_wpnspr(54,e.x,e.y,0.5,0.5,false,1,50)
 local angle=atan2(plcy-e.y,plcx-e.x)
 w.dx,w.dy=sin(angle)*0.3,cos(angle)*0.3
end

function get_laser_end(a)
	local vectorabx,vectoraby=a.lasertargetx-a.x,a.lasertargety-a.y
 local nx,ny=normalize(vectorabx,vectoraby)
 return a.x+nx*16,a.y+ny*16
end

function follow_laser(e)
	if sees_player(e) then
	 if(not e.lct)e.lct=0
	 if(e.lct)e.lct+=1
	 e.lstknownpos={nearestwalkable(player)}
  
  if e.lct%20==0 then
   sfx(9)
  end
  
  if e.lct<=50 then
  	e.lasertargetx,e.lasertargety
  	 =player.x,player.y+1
  end
  
  if e.lct%70==0 then
  	sfx(7)
  	shake()
  	e.lct=0
  	
  	local lx,ly=get_laser_end(e)
  	  	
  	for p in all(linepoint(e.x,e.y,lx,ly))do
  	 make_wpnspr(0,p[1],p[2],1,1,false,0,2)
    sparkle((p[1]-cmap.x)*8,(p[2]-cmap.y)*8,{7,9})
   end
  end
	else
		e.lct=0
		e.lasertargetx=nil
	end
	
	local nlstx,nlsty=nearestwalkable(player)
 if e.lstknownpos[1]==nlstx
 and e.lstknownpos[2]==nlsty then
 else
  pathtoplayer(e)
 	e.lct=0
 end
end

function follow_attack(e)
	if sees_player(e) then
		if(e.lct==0)e.lstknownpos={nearestwalkable(player)}
 end
 if sees_player(e) 
	and player_in_range(e,4,10)
	 then
	 e.atk=true
	elseif not e.atk then
		pathtoplayer(e)
	end
	
	if e.atk then
		if(not e.lct)e.lct=0
	 if(e.lct)e.lct+=1
	end
	
	if e.lct==20 then
	 if e.sprite==1 then
	 	atk_spear(e,false)
	 else
	 	atk_slash(e,false,{{6,12},{5,1}})
	 end
	end
 if e.lct==25 then
	 e.atk,e.lct=false,0
	end
end

function move_monster(e)
	if not loading() then 
 	if player.life>0 and e.life>0 and e.hurtontouch and actorcollide(e,player)then
 		player_dies()
 	end
 	
 	if(e.life>0)e.behav(e)
 	
 	if e.sprite==1 then
 		--boss special
 		if e.lct==0 then
  		if e.life<=60 and e.life>=45 then
  			e.behav=follow_attack
  			e.lct=0
  		elseif e.life<45 and e.life >=30 then
  			e.behav=follow_laser
  			e.lct=0
  		elseif e.life<30 and e.life >=24 then
  			e.behav=follow_shoot
  			e.lct=0
  		else
  			e.behav=follow_attack
  			e.lct=0
  		end
 		end
 	end
 	
  path=e.path
  if not e.atk and e.invuln==0 and #e.path>0 and not e.dash and not e.moving then
 	 
 	 if (e.behav==follow_attack
 	     and rnd(10)<=7)
 	     and not e.dash
 	   then
 	  if rnd(100)<=10 then
			  local rnddir=flr(rnd(4))
			  if(rnddir==1)e.dx-=0.8
			  if(rnddir==2)e.dx=0.8
			  if(rnddir==3)e.dy-=0.8
			  if(rnddir==4)e.dy=0.8
			  e.dash,e.ctdash=true,0
			  sfx(1)
		  end
 	 else
 	  setmove(e,e.path[1][1]+e.boxx,e.path[1][2]-e.boxy)
   end
  end	
  	
 	if e.moving then
  	e.dx,e.dy=e.dirx*e.speed,e.diry*e.speed
  	if sqrt((e.x-e.startx)^2+(e.y-e.starty)^2)>=e.distance then
  		e.x,e.y,e.dx,e.dy,e.moving
  		 =e.targetx,e.targety,0,0,false
  	end
  end
 end
end

function monster_dies(e)
	local px,py=screen_pos(e)
	sfx(8)
 e.display=false
 
 if e.sprite~=1 then
		dust_spike(px,py)
	else
		blood(px,py,{8,14})
	end
	
	local allkilled=true
	
	for e in all(entities)do
		if e.sprite~=1 and e.life>0 then
			allkilled=false
		end
	end
	
	if allkilled then
 	for m in all(cmap.items)do
 		if (m.monster)m.killed=true
 	end
 	
 	if cmap.x==32 and cmap.y==48 then
 		ending=1200
 	end
	end
	
	if #cmap.onmonsterkilled>0 
	   and allkilled then
	 sfx(10)
		for x=cmap.onmonsterkilled[1],cmap.onmonsterkilled[3] do
			for y=cmap.onmonsterkilled[2],cmap.onmonsterkilled[4] do
			 act_tile(x,y)
			end
		end
	end
end
-->8
--pathfinding
--by:richard adem, @richy486
--from picozine 4

function findpath(start,goal)
 explored,frontier,came_from,cost_so_far
 =0,{},{},{}
 insert(frontier, start, 0)
 came_from[vectoindex(start)] = nil
 cost_so_far[vectoindex(start)] = 0
 while #frontier > 0 do
  current = popend(frontier)
  if vectoindex(current) == vectoindex(goal) then
		 break
  end
  local neighbours = getneighbours(current)
  for next in all(neighbours) do
		 local nextindex = vectoindex(next)
   local new_cost = cost_so_far[vectoindex(current)]
 
   if (cost_so_far[nextindex] == nil) or (new_cost <
   cost_so_far[nextindex]) then
		  cost_so_far[nextindex] = new_cost
		  local priority = new_cost + heuristic(goal, next)
		  insert(frontier, next, priority)
		  came_from[nextindex] = current
			end
		end
 end
 
 current=came_from[vectoindex(goal)]
 local path={}
 if current~=nil and current~="none" then
  local cindex=vectoindex(current)
  local sindex=vectoindex(start)
  while cindex!=sindex do
   add(path,current)
   current=came_from[cindex]
   cindex=vectoindex(current)
  end
  reverse(path)
 end
 
 if(#path>0)add(path,goal)
 return path
end

function walkable(x,y)
	return 
	not solid(x,y) and
	not solid(x,y,1)
end

-- find all existing neighbours of a position that are not walls
function getneighbours(pos)
local neighbours,x,y={},pos[1],pos[2]
if x > cmap.x and walkable(x-1,y) then
		 add(neighbours,{x-1,y})
end
if x < cmap.x+15 and walkable(x+1,y) then
		 add(neighbours,{x+1,y})
end
if y > cmap.y and walkable(x,y-1) then
		 add(neighbours,{x,y-1})
end
if y < cmap.y+15 and walkable(x,y+1) then
		 add(neighbours,{x,y+1})
end
if (x+y) % 2 == 0 then
		 reverse(neighbours)
end
return neighbours
end

-- insert into start of table
--function insert(t, val)
--for i=(#t+1),2,-1 do
--		 t[i] = t[i-1]
--end
--t[1] = val
--end

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

function heuristic(a, b)
return abs(a[1] - b[1]) + abs(a[2] - b[2])
end

-- translate a 2d x,y coordinate to a 1d index and back again
function vectoindex(vec)
 return maptoindex(vec[1],vec[2])
end
function maptoindex(x, y)
 return ((x+1) * 16) + y
end
--function indextomap(index)
--		 local x = (index-1)/16
--		 local y = index - (x*w)
--return {x,y}
--end
__gfx__
00000000070000777700000777000007770000077700000777777777777987799778977777dddd7dd7dddd770000000000006666000000000000666676667777
000000000600000770600000706000007060000070600000777777779778877997788779d7dddd7dd7dddd7d0000000666666655000000066666665556677777
000000000600000770600000706000007060000070600000777777779595595995955959d5dddd5dd5dddd5d0000666666666500000066666666550055667777
00000000000df0070700df000700df000700df000700df00777777779795597977955979d755557dd755557d0066666655550000006666665555000057566777
00000000071fff070771fff00771fff00771fff00771fff07700000777999977779999777758b5777758c57d0666666500000000066666650000000077756677
0000000007111177077111170771111707711117077111177060000077555597795555777758c5d77d58b5776666665000000000666666500000000077775667
0000000071111117771111117711111177111111771111117060000079777797797777977d7777d77d7777d76666650000000000666665000000000077777557
000000007cc11cc777ccc11c77ccc11c77ccc11c77ccc11c7000000079777777777777977d777777777777d76666500000000000666665000000000077777777
000aa0007ccc6cc77cccc6c77cccc6c77cccc6c77cccc6c77070fff0000000000000000077aaaa7aa7aaaa776665000000000000666665000000000000065000
00a999007ccc6cc77cccc6c77cccc6c77cccc6c77cccc6c7701111110000000000000000a7aaaa7aa7aaaa7a0000000000000000666665000000000000065000
0a9999907ccc6cc77cccc6c77cccc6c77cccc6c77cccc6c777ccc11c0000000000000000a9aaaa9aa9aaaa9a0000000000000000666666500000000000065000
a9999999cccc5ccc5cccc5cc5cccc5cc5cccc5cc5cccc5cc7cccc6c70000000000000000a799997aa799997a0000000000000000066666650000000000065000
a999999955cc5c5555ccc55555ccc55555ccc55555ccc5557cccc6c70000000000000000779339777793b97a0000000000000000006666665555000000065000
09999990755c5557755cc557755cc557755cc557755cc5577cccc6c700000000000000007793b9a77a9339770000000000000000000066666666550006065050
0099990077077077770777077770707777700777777070775cccc5cc00000000000000007a7777a77a7777a70000000000000000000000066666665506666650
00099000775775777577777577577577777557777757757755cccc5500000000000000007a777777777777a70000000000000000000000000000666600666500
550000550700007777000007770000077700000777000007000000000000000077ddd77777ddd7777aa7779988777aa777777dddddd777770000000000000000
558888550600000770600000706000007060000070600000000000000000000077ddd77777ddd77775577799887775577dbddddddddbddd70000000000000660
2277772206000007706000007060000070600000706000000000000000666000775887d7d758977775579988889975577bdbdddddddbddd70000000000000066
0877778000000007070000000700000007000000070000000000000006666600d7555757575557d775599988889995577ddbd555555bddd70000000066666666
08777780070000070771000007710000077100000771000000000000066066005d757d575d757d57aa799955559997aa7ddbd5d55d5bddd70000000055555566
557777550710017707711117077111170771111707711117000000000666600055d5d55755d5d55755799955559997557dbdd555555dbdd70000000000000065
5588885571111117771111117711111177111111771111110000000000666600575557575755575755799955559997557ddbdddddddddbd70000000000000550
220000227c111cc777c11ccc77c11ccc77c11ccc77c11ccc0000000000066000575557575755575757799955559997757555b55555555b570000000000000000
000000007c11ccc77cc11cc77cc11cc77cc11cc77cc11cc7000008800606060057555777575557577aa9995555999aa775ddbbd5dddbbb570000000000000000
000000007c11ccc77c11ccc77c11ccc77c11ccc77c11ccc700008a980666666057577d7777577d57755999999999955775d555b5d5bd55570000000000000000
000000007c11ccc77c11ccc77c11ccc77c11ccc77c11ccc700008998060600607757757777577577755599999999555775d555b55b5555570000000000000000
00022000cc11cccc5c11cccc5c11cccc5c11cccc5c11cccc00000880666666067757d5777d577577755555555555555775d555b5dbdddd570000000000000000
02222220551ccc55551ccc55551ccc55551ccc55551ccc5500000000600600067d7757777577d777aa775555555577aa75d555b5d5b55d570000000000000000
22222222755cc557755ccc57755ccc57755ccc57755ccc5700000000666666067577577775775777557777777777775575dddbb5dddbbd570000000000000000
0222222077077077770777077770707777700777777070770000000060060000757755777557577755777777777777557555b55555555b570000000000000000
0002200077577577757777757757757777755777775775770000000006666666755777777777557757777777777777757555b55555555b570000000000000000
11111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee42232224000000000000000000000000000000000000000000000000000000000800008088888888
11111111e8888888888888888888888eeeeeeeeeeeeeeeee42322224088888888888888888888880000000000000000008888888888888800800008088888888
11111111e8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee42322224080000000000000000000080000000000000000008000000000000800800008088888888
11111111e8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee42232224080000000000000000000080000000000000000008000000000000800800008088888888
11111111e8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee42223224080000000000000000000080000000000000000008000000000000800800008088888888
11111111e8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee42223224080000000000000000000080000000000000000008000000000000800800008088888888
11111111e8eeeeeeeeeeeeeeeeeeee8eeeeeee8888eeeeee422322240800000000000000000000800000008888000000088888888888888008000080cccccccc
11111111e8eeeeeeeeeeeeeeeeeeee8eeeeeee8ee8eeeeee42223224080000000000000000000080000000800800000000000000000000000800008011111111
88888888e8eeeeeeeeeeeeeeeeeeee8eeeeeee8ee8eeeeee4222222408000000eeeeeeee00000080000000800800000008000080000000000000000033333333
88888888e8eeeeeeeeeeeeeeeeeeee8eeeeeee8888eeeeee4222222408000000eeeeeeee00000080000000888800000008000080088888808888888833333333
88888888e8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee42222224080000002222222200000080000000000000000008000080080000800000000033333333
88888888e8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee42222224080000002222222200000080000000000000000008000080080000800000000083333388
88888888e8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee4222222408000000eeeeeeee00000080000000000000000008000080080000800000000088888888
88888888e8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee4222222408000000eeeeeeee00000080000000000000000008000080080000800000000088888888
88888888e8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee422222240800000022222222000000800000000000000000088888800800008088888888cccccccc
cccccccce8eeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee42222224080000002222222200000080000000000000000000000000080000800000000011111111
33333333e8eeeeeeeeeeeeeeeeeeee8e422222222222222222222224080000000000000000000080eeeeeeebbeeeeeee11111111111111110000000000000000
33333333e8eeeeeeeeeeeeeeeeeeee8e422222222222222222222224080000000000000000000080eeeeeebbbbeeeeee1cccccccccccccc10000000000000000
33333333e8eeeeeeeeeeeeeeeeeeee8e422222222222222222222224080000000000000000000080eeeeebbbbbbeeeee1c111111111111c10000000000000000
83333388e8eeeeeeeeeeeeeeeeeeee8e422222222222222222222224080000000000000000000080eeeebbbbbbbbeeee1c111111111111c10000000000000000
88888888e8eeeeeeeeeeeeeeeeeeee8e422222222222222222222224080000000000000000000080eeebbbbbbbbbbeee1c111111111111c10000000000000000
88888888e8eeeeeeeeeeeeeeeeeeee8e422222222222222222222224080000000000000000000080eebbbbbbbbbbbbee1c111111111111c10000000000000000
88888888e8888888888888888888888e422222222222222222222224088888888888888888888880ebbbbbbbbbbbbbbe1c111111111111c10000000000000000
cccccccceeeeeeeeeeeeeeeeeeeeeeee422222222222222222222224000000000000000000000000bbbbbbbbbbbbbbbb1c111111111111c10000000000000000
b444444beeddddeedddddddd0cccccc00000000022223222bbbb88bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1c111111111111c10000000000000000
b444444bedccccdedccccccdcccccccc0000000022223222bbbb88bbbbccbbbbbbbbbbbbbbbbbbbbebbbbbbbbbbbbbbe1c111111111111c10000000000000000
4444444bddccccdddccccccdcccccccc0cccccc022232222bb3b3bbbbbccbbbbbb3333bbbbbbbbbbeebbbbbbbbbbbbee1c111111111111c10000000000000000
44444444ddccccdddccccccdcccccccccccccccc22223222bbb3bbbbbbb3b3bbbb3bb3bbbbbbbbbbeeebbbbbbbbbbeee1c111111111111c10000000000000000
44444444ddccccdddccccccdcccccccccccccccc22232222bb3bbbbbbbbb3bbbbb3b33bbbbbbbbbbeeeebbbbbbbbeeee1c111111111111c10000000000000000
44444444dd1111dddccccccd1cccccc1cccccccc22232222bb3bbbbbbbbb3bbbbb3bbbbbbbbbbbbbeeeeebbbbbbeeeee1c111111111111c10000000000000000
44444444d111111ddccccccd11111111cccccccc22223222bbb3bbbbbbb3bbbbbb3bbbbbbbbbbbbbeeeeeebbbbeeeeee1cccccccccccccc10000000000000000
b4b44b4b11111111dddddddd011111100cccccc022232222bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbeeeeeeebbeeeeeee11111111111111110000000000000000
04040404040404171704040404040404e425e44656565756565766758696257686e5e5e5e5e5e5e5e59497040404047500a4868686868686868686868686b400
00a486868686868686868686868686869697979797b6252525a69797979787e40404040415350404e4041525253504040404040404c4e5e5e5e5e5e5e5e5e5d4
04142424242424554524a7979797b604e4a6e470a6259125257025e446662546565657565656565766e4b70404040475a49656565656575656565756575676b4
a4965656565656575656565656565656669797979797972525979797979797e40404040415350404e40415252535040404040404044656565656565656565666
0415a674e5e5e5e5e5e5e5e594a78704e497e42577d525a6d5b625e446662546565657565656575666e405040404047595645657565657565656565656576575
9565565656565656565656565656565766976797979797b6a667979797b635e40404040415350404e40415252545242424243404044656565656565656565666
04b67496575656565656565676949704e4a7e40506e40506e40605e42525252525a697978725252525e404040404047595640505051424242424340505056575
956597b7242424a79797979797979797b7a797079797979797979797079736e40414340415350404e40415252525252525253504040505050505050505050505
0497e465565656565657575664e49704e425e40404e40404e40404e42525a6979797b7a797b6258225e414342704b77595050404041525b62525350404040575
95a797262626262626269797879797972626979797b72697977797b6263674950415910415350404e40415252525252525253504040404040404040404040404
0477e465142424242424973464e4a704e425e4c6d6e4c6d6e4c6d6e425257797b7252525a797b625a6e4163627047075950404040415257787b6350404040475
95050614341434143414340606c4e58484e5e5e5e5e5e5e5e5e5e5e5e5e5b5950415350415350404c50416262626262626263604042424240424042404040404
04a7e41482a69797979797b634e43504e425e4c7d7c5c7d7c5c7d776e584e5e5e5e5e5942597b725a7e405052704a675950404040415a6876797350404040475
95040416361636163616360404466675965656575656565656575656565776950415350415350404650405050505050505050504040525250425040504253504
0415e415a69767979797779735e4a604e467e404046404046404044666e44657565666e42525252525e414342704b7759514242424a697979777452424243475
9504041525a697b625823504044666e4655656565756565656565656565665e40491350415350404650404040404040404040404040405250405040404253504
0415e415979797979797979735e49704e497e404046504046504044666e44656575666e4b625258225e416362704707595978797779777679797978797b63575
95b60415a6b7a79787b63504046791e4650505050505050505050505050565e40416360415350404050404040404040404040425250404250404250404253504
0415e41625a79797979797b736e49704e497e4c6d605c6d605c6d60505e42525252525e497b6252525e405052704977595970797976787979777779777073575
95970414341434143414340404b725e4050404040404040404040404040405e40405050415350404040404040404040404040405050425250404252504253504
0415769416262654a777263674969704e4b7c5c7d704c7d704c7d70404c5857484948576e5d425c4e59614342704a775958797b6a7979777978797b626263675
95670416361636163616360404b625c50404b625a604a797040425a697040476e5e5940415350404040404040404040404040425252505252504252504050504
04156476e5e5d41535c4e5e596658704e4256504040404040404040404658575009585465766254656661636270470759506060605a7879797b7350605050575
959704b6822525252525a604040605650404b7050604050604040506b70404465666e40415350404040404040404040404040425250504250504252504040404
04b66557565666153546565656649704e425640404040404040404040465857500958546576617465666050527a69775950404040415a797b725350404040475
95b704b7252525a69797970404040465040425040404040404040404250404465666e40415350404040404040404040404040425250404250404250504250404
0497b757565666153546565657a69704c5252525a69797979797977797b725750095142424242524a79797b72597677595040404041525972525350404040475
9525041434143414341434259797b717242455a797979702a78797b7452424243485e40416262626262626542525350404040405050404250404050404050404
04b744262667b62626269797779797046597978797b7a79797979797b72525750095b6262626a677b6262626a6979775a594040404162697b6263604040474b5
0094041636163616361636a69797251726262626a77797262697b726262626263685e40405050505050505152525350404040404040454250404040404253504
0415350505050505050506060606060465c4e5e5e5e5d41717748484848484b50095060505050606060505050506067500a58484848494a7977484848484b500
00008484848484848484848484848484848494050506060505060505050574849485e40404040404040404162626360404040404040415253504040404050504
04171704040404040404040404040404044656575657661717768686868686b400a4868686868686868686868686b40000a4868686869615357686868686b400
00a4868686868686868686868686b4000000a58484849424247484848484b5009585e40404040404040404171717170404040404040415253504040404040404
0415350404040404040404040404040404012424242434171746565657565676869646565756565656565657566676b4a49656575656661535465657565676b4
a49656575656565657565656565776b40000a48686869525257686868686b4009585e40414242404242424242424340404042424242455254524242424243404
0415350404040404040404040404040417171717171717050546575656565646566646565756565656565757566664759565565657566615a646565756566575
9564565656575656575656565656657500a49656565776d425465657565676b49585e40415252504252525050505350404042525902525252525252525253504
0415350404040404040404040404040405050505050505040405050505050546566614242424242424242424243464759565050505050515a797679724346475
95651424242424242424242424346475009565565657466625465656575665759585e40415252504259025252504350404042525252525252525252590253504
0415452424a697979797b6242424242424a797b7340404c6d60404142497b724241755252525252525a6b62525453475950504040404040505979797b6453475
95145590252525252525252590453475009565142424466624242424243465759585e40405050525252525252504350404040505050505050505050505253504
041544a697979797779797b6262626a6b6262626360404c7d7040416a677b67484e5e5942525a667979797b674e5e58696049707770404040415a7979726a675
9515262626a697b6442626262626367500951497b6252525252597b6a24534759585e40415252525252505052504350404040404040404040404040404253504
0415350606060606060606060505050606050505050404040404040506061575954666e49797979797978797e4565756660406060604040404153574e5e5e586
96177484848494b735748484848484b5009515a7079797b62525a777b62535759585e40415902525252525042504350404c6d604040404040404040404253504
0415350404040404040404040404040404040404040404040404040404041575954666e49797979797979797e45756566604040404040404041535e456565656
663576868686961535768686868686b40095152597876797972525259797b6759585e40415250525252525042591350404c7d704040404040404040404253504
0415350404040404040404040404040404040404040404040404040404041575950125e49787977297979797e4142427179797b7243404041455a6e456575656
6635465756565615354656575656667686961525259797b725252525252597759585e40415250425252525042525350404040404040404040404040404050504
0415350404070404040404040404040404040404040404040404040404041575952525e49797979797779797e4162627178797262636040416a697e4262626a6
b63646565756561535465656575666465666152525a7972525252525252597759585e40415250425250525250505050404040404040404040404040404253504
0415350404060404040404040404040404040404040404040404040404041575958585e46797979797979797e485857494979705050504040506067584848484
849414242424245545242424a77797465666152525259725a2252525252597759585c50415250425250425252525350404157004040404040404040404253504
041535c6d6c6d6c6d6c6d691a6d5040404040404040404040404040404041575958585c5979777979797b725c585857595979704040404040404047686868686
86961525252525252525902525a79717a7b717252525252525252525252535759585650405050425250425252590350404152504040404040404040404253504
041535c7d7c7d7c7d7c7d71667e404040404142434047494041424a7040415759585856597979797979725256485857595b73504040404040404044656575656
566615a697b62525a6b625252525a71725011754252525a625a69725254436759585650415252525250405050525251717252504040404040404040404253504
04b635c4e5e5e5e5e5e5e5e5e596040404041501a604769604b602350404157595858565a79797979797b6256485857595153504040404040404044656575656
5766159797979797976797b6254436748484941626a697b726977797973674b59514242455252525252525252525251717250125252504259025252525253504
04b7a7465656575656565756566624a76797b625870446660497b645a79777759516262626a797979797b72626263675a5944524242424242424242424242424
24a787979797979797979797b63674b50000a58484848484848484848484b5009516262626260526260526262626050505162626262626262626052626260504
04162626a69797779797b62626262626a697972636044666049767b625a7b775a58484848484848484848484848484b500a58484848484848484848484848484
8484848484848484848484848484b500000000000000000000000000000000009505050505050405050405050505040404050505050505050505040505050404
__gff__
0180000000000080808000000000000000000000000000000080000000000000000000000000000080008000800000000000000000000000000000000000000002000000000001010101010101010102020000000000010100010101010101020200000001010101010100000202000001010000000100000000000002020000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4040404040404040404040406a79796b6a424242104040404040404142774242427a4040406a79797842797b40767b57594040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040475e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e4d40404040404040404040
40404040404040404040404079797679796b626263404040404040616a796b626262796b40617679796b5260407b195759407979404142424242424340797940404042434040796b43404041420940404040797b4340404040404041424340404e64656565656565656565656565656565656565656640404040404040404040
40196a4040404340406c6d406060606060605050504040404040404748484848484849534050606060605040405153575940707b4051525252522853407670404040206a4040767053404051526a4040404051095340404040404051076a40404e646565656565656565656565656565656565656566404040406a7979104340
406a7b40406b6340407c7d4040404040404040404040404040404057000000000000597979797b7a79787b43406b63676940605040516a6b526a6b534060604040406a7640407979504040616a794040404061526340404040404079797940404e505050414242714242427142424350505050505050404040407a7970525340
406050404060504040404040404040404040404040404040404040676868686868686951525252527a7b52534060506466406b7a796b797979787954427a7740404052604040607a40404050606040404040506a5040404040404060526040404e40404051525271525252715252547142424242424242424042555279796b40
404040787b5554424340404040404040404040404040404040404064656575656565665152525252525252534040406466407b527a79797b52797b5252527940404052404040405240404040404040404040407940404040404040406b4040404e40404051195271525207715252447162626262626262626250456a7b525340
4040405144626a6b5340404040404040404040404040404040404064656575656575666b5252525252525254424242716a6b6262624579525252524462627a71527a79796b5240796b526a797879797b52525279797840796b52527a774040404e40404051525271525252715219535050505050505050505040506062626340
404142555350607b547a404279796b4242424242424242426a7942097a7b424242427a7b5252526a796b5252525244717a6050505051766b52522853505050505050526060504052605060607a6060505050507b6060406079505050604040404e40404051525271525252715252534040404040404040404040404050505040
406b6279794040514462406a7979796b626262626262096a79786262626262626262626262456a7679796b522852534749407b434051797b5252526a4041404040405240404040524040404052404040404040524040404060404040404040404e4040405152527152525271525253404040475e4d40404c5e5e4d4040404040
406050797742425553504060475e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e49797979797979796b5253575940616340617a796b626a7940614040407a79794040417a774040415243404040407952434040404040406a796b40404e40404051525271525252715207534040404e64654040656565664052524040
40404079797b4462634040404e64756565656575656565656575656565756565656565664e79797978797976796b63575940505040505060605060604050404040517079404051097a404051706b40404040795252095240526a7b79767940404e40404051525271525219715252534040404e64654040656565664052524040
4040406060515350504040404e6465656565657575656565756565656565656565657566675e5e5e5e5e5e5e5e5e5e68685e5e5e5e5e5e5e5e5e5e5e5e5e5e5e4961627a40406150634040616a6040404040786b635050406a605061627940404e40404051525271525252715252534040404e41424040424242424052504040
4070794040515340407977404e41424242427a7979797978797b424242424242427a7b43646565656565756565656565656565656565756565656565657565664e505050404050405040405060404040404060605040404079404050506040404e40405261626271626262716262637152524e51444040626262624062404040
4077794040515340406b19404e514462626262797979797979796b626262626262626b6a646565756565656565656565657565656565756565656565656565664e404040404040404040404040404040404040404040404052404040404040404e40414243525071505050715050505050524e5153475e5e5e5e5e5e5e5e5e5e
4050604040515340406050404e5153505050506060607979797660505050505050506079796262626279766b62626262626262627a7979796b626262626a50504e404040404040404040404040404040404040404040404052404040404040404e40515253504071404040714040404040524e51534e64656565656565656566
4040404040515340404040404e516a404040404040406071716040404040404040404060605050505060606050505050505050505060606060505050507a4040675e5e5e5e5e5e5e5e5e5e5e5e5e4d40404040404040405d715d404040404040674d515253404050404040504040404040524e51534e64656565656565656566
4040404040515340404040404e5179404c5e5e5e5e5e4d71714c5e5e5e5e5e48485e5e5e5e5e5e5e5e5e5e5e5e5e4d40404040404040404040404040407140404040407a79404040417a404040404047485e5e5e5e5e5e6952675e5e5e5e5e496466616263404040404040404040404040524e51534e40406c6d6c6d6c6d4040
4079797979515379797979404e6a7940646565756565666a6b646575656566575964656565656565756565656565664040404040404040404040404040524040404040107a404040616a4040404040575964656565656566526465656565664e64667171714040717171405d4040404040524e61634e71717c7d7c7d7c7d0952
4079707879515379792079404e7979406465657565656679786465656575665759646565656565656575656565656640404040797b424242424242427a794040404040505040404050604040404040575964657565656566526465657565664e50505050504040505d41434e404040404050675e5e6910716c6d6c6d6c6d5050
4079797979515378797979404e7779407779797b5252717a79420742426b4357595050505050505050505050505050404040407b1952525252525252197a40404040404040404040404040404040405759414242424242424242426a79796b4e40414340717140524e61634e4040404040406465656652717c7d7c7d7c7d0952
4060606060515360606060404e797940527a7b52105271626262626a777963575941794340404040404040407a79764040404051525252526a7979766b5340404040404040404040404040404040406769516a796b525252525252797979794e4061634071714050575e5e694040404040406465656671716c6d6c6d6c6d5050
4040404040515340404040404e527a4047485e5e5e5e4d50505050606060505759797b527a787b525252797b52527a527142796b52526a797b527a79795340404040406c6d404040404040404040406466517976796b526a796b52797979794e40505040505040404e6465662052404040405050505050507c7d7c7d7c7d5209
4079797979515379797979404e52534057696565756566404040404040404057596152635060505050506050615263505050607b5252797b2a5252797b5340404040407c7d404040404040404040406466517a7979797979777979787979764e40404040717140405c6465665252404040404052405240406c6d6c6d6c6d2c52
4076707979515379797079404e5253404e4665657565664079767b42424243575950525040404040404040405052504040404051526a795252526a796b53404040407a797978796b52526a7979526a79525244627979797b527979796245794e4040404071714040565050525252525252525252525240407c7d7c7d7c7d5252
4079797979515379787979404e7171404e465050505050407909526a5209535759406a40404040404040404040524040404040515279766b526a7779795340404040506c6d6060606c6d6060606c6d474961635d517a79525252527a5d617a4e4040404050504040564040525050505050505250525040406c6d6c6d6c6d5209
4060606060515360606060404e6a79404e604040404052407b5252796b5253575940794079797979797979794052404040404051527a7979797979797b5340474940407c7d4040407c7d4040407c7d575a4848595858585858585858574848594040404052524040504040524040404040405040504040407c7d7c7d7c7d5050
4040404040515340404040405c7979404e4040707976704051526a79796b535759405240797079787979707940524040404040515252527a7979797b526a40676940406c6d4040406c6d4040406c6d57000000595858585858585858570000594040404052525252525252524040404040404040404040406c6d6c6d6c6d4040
404040404051534040404040467879404e6b2060606060405152797b7a77795759405240606060606060606040524040404040511952525252525252797940646640407c7d4040407c7d4040407c7d574a6868695858585858585858676868594041434041435050474d5052404c5e5e5e5e5e4d404040407c7d7c7d7c7d0952
4041426a425554424242424346797b404e776b4242424340515279797b7a795759416a79404040404040404041796b404040406b626262626a6b626a79797864667171717171404009524040400952575964756658585858585858586465664e40616340515340404e5640504064656565656566404040406c6d6c6d6c6d5050
40616a79776b6245446a7979626263404e79766b6a787940616a786b626a6b57596a797b52526a79776b52527a795340404040605050505060605060607a79797b522007527140406b524040400952575964756658585858585858586465664e40505040515340404e5640404064656565656566404040407c7d7c7d7c7d0952
405060606060505153606060505050404e7a475e5e5e5e5e5e5e5e4848497b575961767950506060606052506178634040404040404040404040404040525247496a79766b71404060504040406b52575941424242424242424242424242434e40404040515340404e5071717144626262626263404040406c6d6c6d6c6d5050
404040404040405153404040404040404e524e64657565656575665700597157595060604040404040407940506050474848484848484848484848484848485b5a48484848484848484848484848485b59515252525252525252525252526a4e40404040515340404e4051525253505050505050404040407c7d7c7d7c7d4040
__sfx__
00010000096001862009600096000960032600380003e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000000002650036500365003650036500360002600026000260002600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000462006620086200b6200e620116201462018620276200460002700027000360004100026000560005600046000460004600046000360003600046000460005600066000660006600066000000000000
010100000d150131501b150211502c150351702815014150081500c150111501c150221502a15032170241500f1500b150121501715020150241502b15031150361503a170371501b15009150011500c00000000
000400003c61033620276302064012650066500165002600026000260002600026000260003600036000360003600036000360003600036000360003600036000460004600046000360003600036000260002600
010700000e05000000000001905000000000000d05000000000000405000000000000305005100000000105001000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003d65033650256501a65010640066300162000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000371503215029150201501b15017150111500e1500c1400b1400a140081400714006140051400413003120031100000000000000000000000000000000000000000000000000000000000000000000000
000100002b650256501f6501d650186501665014650136501265011650106501f65016650106500b6500865007650066500465003650026500265001650016500165001650026500265002650026500265003650
000300001433014330143301433014320143100000000000000002410000000000002410000000241002410000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000011350113401133011320113101d3501d3401d3301d3201d3102a3502a3402a3302a3202a3101e3501e3401e3301e3201e310353503534035330353203531035310000000000000000000000000000000
000100003a7303a7403a7503a7603a7703a770367303674036750367603677034730347403475034760347703f7303f7403f7503f7603f7700000000000000000000000000000000000000000000000000000000
0102000038760387503874038730387203c7603c7503c7403c7303c72000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000187103a710000001b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c0430000000000000003c615000003c6153c6150c0430000000000000003c615000003c6153c6150c0430000000000000003c615000003c6153c6150c0430000000000000003c6153c6153c6153c615
011000001a730260201a710260351a7201a010267301a0251a710267301a720267151a730267201a710267351a730267201a715267301a720267101a735267201a7101a730267201a7151a730267201a71026735
000f00002470024710247202473024740247502476024770247002471024720247302474024750247602477024700247102472024730247402475024760247702470024710247202473024740247502476024770
011000001805418054180541805418054180541805418054180541805418054180541805418054180541805418054180541805418054180541805418054180541805418054180541805418054180541805418054
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
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
