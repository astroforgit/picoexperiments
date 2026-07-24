pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--tria insomnia
--by sprvrn & nyeti

-- buckets
-- 0,1,2 :    character level
-- 3,4,5 :    character xp
-- 6,7 :      posx,posy
-- 8 :        keys
-- 31 to 46 : collected items

function _init()
	cartdata("dc_test")
	palette={[0]=
	0,129,136,3,132,5,6,7,8,9,10,139,140,134,14,15
	}
	pal(palette,1)
	
	poke(0x5f2e,0)
	
	menuitem(1,"erase save data",function()
		for i=0,63 do
			dset(i,nil)
		end
		reset()
		--pal(palette,1)
		--loadgame()
	end)

	viewsize = 121
	viewx,viewy = 3,3
	posx,posy = 89,54
	ofx,ofy = 0,0
	dirx,diry = -1,0
	planex,planey = 0,0.66
	zbuffer = {}
	flr_clr=0
	ceil_clr=0
	
	keys=0
	
	stepct=0
	
	shakedur=0
	
	collected={}
	
	orientation={"s","w","n","e"}
	cur_or=4
	
	entities={}
	objects={}
	mapobj={}
	
	mvspd,rspd=.8,.010
	
	upd=upd_title
	drw=drw_title

	local objid=0
	for x=0,127 do
		zbuffer[x]=0
		for y=0,63 do
			local t=mget(x,y)
			local item=obj_db[t]
			if item then
				local nobj={
					id=objid,x=x,y=y,sprite=t,
					activation=item[2],
					upd=item[3],
					udiv=item[4] or 1,
					vdiv=item[5] or 1,
					vmove=item[6] or 0}
				add(objects,nobj)
				item[1](nobj)
				objid+=1
			end
			if t==33 or t==16 then
				mapobj[x*y]=objid
				if iscollected(objid) then
					mset(x,y,0)
				end
				objid+=1
			end
		end
	end
	
	for i=1,#rooms do
		local r=rooms[i]
		rooms[i]={
		x=r[1],
		y=r[2],
		w=r[3],
		h=r[4],
		floor=r[5],
		ceiling=r[6],
		bgm=r[7],
		battles=r[8] or {}
		}
	end
	
	skills={}
	--name,str,target,ele,cost
	mkskill("attack",1,1,1,0)
	mkskill("allout",1,2,1,2)
	mkskill("nuklear",1.3,1,2,3,"nucklear atk. single target")
	mkskill("nuklear+",1.3,2,2,15,"nuklear atk. target all")
	mkskill("cyber",1.3,1,4,3,"cyber atk. single target")
	mkskill("cyber+",1.3,2,4,25,"nucklear atk. target all")
	mkskill("bio",1.3,1,3,3,"bio atk. single target")
	mkskill("bio+",1.3,2,3,15,"nucklear atk. target all")
	mkskill("dew",-2.5,-1,5,5,"heal some life. single target")
	mkskill("dew+",-2.5,-2,5,5,"heal some life. target all")
	mkskill("needles",1,1,1,6,"multi normal hits")
	mkskill("needles+",1.5,1,1,12,"multi normal hits")
	skills.needles.hits=3
	skills.needles.delay=1.5
	skills["needles+"].hits=5
	skills["needles+"].delay=1.7
	
	elements={}
	mkelement("normal",7,p_dmg_dust,0,1)
	mkelement("nuklear",9,p_nuclear,4,2)
	mkelement("bio",3,p_bio,2,34)
	mkelement("cyber",2,p_cyber,3,33)
	mkelement("dew",12,p_dew,0,32)
	
	monsters={}
	mkmonster("ghost",64,1,2,  1,   2,1,3,3,   2,
	{"attack"})
	mkmonster("ghost2",65,8,2,  4,   1,1,1,3,   1,
	{"attack"})
	mkmonster("ghost3",64,1,2,  10,   20,1,1,3,   2,
	{"allout","bio","bio","bio"})
	monsters[3].particle=p_monster2
	
	mkmonster("virus",80,10,12,  4,   3,1,2,5,   3,
	{"nuklear"})
	
	mkmonster("virus2",81,2,3,  8,   30,1,2,5,   2,
	{"attack","allout","cyber"})
	mkmonster("virus3",82,1,2,  7,   10,1,2,6,   3,
	{"dew","attack","attack","attack"})
	monsters[5].particle=p_monster2
	monsters[6].particle=p_monster2
	
	mkmonster("glitch",83,2,14,  4,   3,1,2,5,   4,
	{"cyber"})
	mkmonster("glitch2",83,1,12,  5,   2,1,2,5,   3,
	{"dew"})
	
	mkmonster("glitch3",84,1,12,  13,   45,1,5,6,   4,
	{"allout","cyber","allout"})
	monsters[9].particle=p_monster2
	
	
	xptable={
		5,20,30,40,50,
		70,90,120,150
	}
	maxlevel=#xptable
	
	
end

function cd_get_bit(bit_id)
 local bucket_index,bucket_subindex=bit_id\32,bit_id%32
 local bucket=dget(bucket_index)
 local mask=0x0.0001<<bucket_subindex
 return (bucket&mask)~=0
end

function cd_set_bit(bit_id,val)
 local bucket_index,bucket_subindex=bit_id\32,bit_id%32
 local bucket=dget(bucket_index)
 local mask=0x0.0001<<bucket_subindex
 if val then
  bucket=bucket|mask
 else 
  bucket=bucket&(~mask)
 end
 dset(bucket_index,bucket)
end

function savegame()
	local i=0
	for c in all(characters)do
		dset(i,c.level)
		dset(i+3,c.exp)
		i+=1
	end
	dset(6,posx)
	dset(7,posy)
	dset(8,keys)
	for cltd in all(collected) do
		collectobj(cltd)
	end
	collected={}
end

function loadgame()
	characters={}
	mkchar(0,"char1",96,4,107,        10,1,5,3)
	mkchar(1,"char2",98,4+41,107,     1,20,2,2)
	mkchar(2,"char3",100,4+(41*2),107,15,5,3,10)
	
	characters[1].skills={
		[0]="attack",
		[1]="nuklear",
		[3]="dew",
		[4]="bio",
		[5]="nuklear+"
	}
	characters[2].skills={
		[0]="attack",
		[2]="dew",
		[3]="cyber",
		[4]="dew+",
		[5]="cyber+"
	}
	characters[3].skills={
		[0]="attack",
		[2]="needles",
		[3]="bio",
		[4]="bio+",
		[5]="needles+"
	}
	
	posx,posy=
	(dget(6)>0) and dget(6) or posx,
	(dget(7)>0) and dget(7) or posy
	keys=(dget(8)>0) and dget(8) or keys
	change_room()
	stepct=0
end

function shtcrd(s)
	return (s%16)*8,flr(s/16)*8
end

function lerp(st,ed,t)
	return st+t*(ed-st)
end

function sort(a,cmp)
 for i=1,#a do
  local j=i
  while j>1 and cmp(a[j-1],a[j]) do
   a[j],a[j-1]=a[j-1],a[j]
   j=j-1
  end
 end
end

function round(num)
 return flr(num+.5)
end

function after(d,cmd)
	add(entities,{z=0,d=d+time(),call=cmd,
	upd=function(c)
		if time()>=c.d then
			c.call()
			del(entities,c)
		end
	end})
end

function shadow()
	--[[pal({[0]=
	0,
	128+1,
	128+2,
	0,
	128+4,
	0,
	5,
	6,
	128+2,
	128+2,
	128+4,
	3,
	5,
	5,
	128+4,
	128+4},1)]]
end

function animframe(anim,speed)
	return anim[flr(time()/speed)%#anim+1]
end

function strspl(s,sep)
 local ret,bffr = {},""
 for i=1, #s do
  if (sub(s,i,i-1+#sep)==sep)then
   add(ret,bffr)
   bffr=""
   i+=#sep-1
  else
   bffr=bffr..sub(s,i,i)
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

function clamp(lower,val,upper)
 return max(lower,min(upper,val))
end

function wwrap(s,w)
 local ret,len,wrds,wrd = "",0,strspl(s," "),""
 for k=1, #wrds do
  wrd=strspl(wrds[k],"\n")
  for n=1,#wrd do
   if len+#wrd[n]>w or n>1 then
    ret=ret.."\n"
    len=0
   end
   ret=ret..wrd[n].." "
   len+=#wrd[n]+1
  end
 end
 return ret
end

function print_ol(text,x,y,col1,col2)
 if col2 then
	 for dx=-1,1 do
	  for dy=-1,1 do
	   print(text,x+dx,y+dy,col2)
	  end
	 end
 end
 print(text,x,y,col1)
end

function print_s(text,x,y,col1,col2)
	if(col2)print(text,x,y,col2)
	print(text,x,y-1,col1)
end

function box(x,y,w,h,r)
	local t=time()*3
	rectfill(
		x+r*sin(t),
		y+r*cos(t),
		x+w+r*sin(t),
		y+h+r*cos(t),7
	)
	rectfill(x,y,x+w-1,y+h-1,1)
end

function mk_popup(text)
	local ent={z=2,ox=64,
	drw=function(e)
		print_ol(text,35+e.ox,64,7,1)
	end,
	upd=function(e)
		e.ox=lerp(e.ox,0,0.15)
	end}
	add(entities,ent)
	
	after(2,function()
		del(entities,ent)
	end)
end

function contains(table,element)
  for value in all(table) do
    if value == element then
      return true
    end
  end
  return false
end
-->8
--dungeon, objects, move utils

--new,activationó,upd,udiv,vdiv,vmove
obj_db={
	[49]={
	function(o)
		if iscollected(o.id) then
			del(objects,o)
		end
	end,
	function(o)
		o.hide=not o.hide
		init_battle({3})
		
		collect_at_end=o
	end,
	function(o)
		o.udiv=2+.5*cos(time()/2)
		o.vdiv=2+.5*sin(time()/2)
		o.vmove=10*cos(time()/2)
	end
	},
	[48]={
	function(o)
		if iscollected(o.id) then
			del(objects,o)
		end
	end,
	function(o)
		o.hide=not o.hide
		init_battle({5,6})
		
		collect_at_end=o
	end,
	function(o)
		o.udiv=2+.5*cos(time()/2)
		o.vdiv=2+.5*sin(time()/2)
		o.vmove=10*cos(time()/2)
	end
	},
	[32]={
	function(o)
		if iscollected(o.id) then
			del(objects,o)
		end
	end,
	function(o)
		o.hide=not o.hide
		init_battle({9})
		
		collect_at_end=o
	end,
	function(o)
		o.udiv=2+.5*cos(time()/2)
		o.vdiv=2+.5*sin(time()/2)
		o.vmove=10*cos(time()/2)
	end
	},
	[34]={
	function(o)
		
	end,
	function()
		savegame()
		mk_popup("game saved!")
		sfx(32)
		stepct=0
		for c in all(characters)do
			c.life=get_life(c)
			c.mana=get_mana(c)
			p_dew(c.x+8,c.y+8)
		end
	end,
	function(o)
		o.vmove=20*cos(time()/2)
	end,
	1,1,20
	},
	[50]={function(o)
		if iscollected(o.id) then
			o.sprite=51
		end
		o.animx=0
	end,
	function(o)
		if not iscollected(o.id) and not contains(collected,o.id) then
			--collectobj(o.id)
			--for c in all(chests) do
				--if c[1]==o.x and c[2]==o.y then
					add(collected,o.id)
					o.sprite=51
					o.animx=1
					
					keys+=1
					sfx(38)
					mk_popup("you found a key")
				--end
			--end
		else
			--printh("chest is empty")
		end
	end,
	function(o)
		if o.animx>0 then
			o.udiv=1.5+.5*cos(o.animx)
			o.animx-=0.1
		else
			o.udiv=1.5
		end
	end
	,1.5,1.5,50}
}
--activationó
mapobj_db={
[17]=function()
	fade_out()
	upd=upd_transition
	sfx(35)
	after(0.7,function()
		posx,posy=pos_forward(2)
		change_room()
		fade_in()
		after(0.7,function()
			upd=upd_player_control
			drw=drw_game
		end)
	end)
end,
[33]=function(id,x,y)
	if keys>0 then
		add(collected,id)
		keys-=1
		mset(x,y,0)
		sfx(35)
		mk_popup("door opened with 1 key")
	else
		mk_popup("you need a key")
		sfx(36)
	end
end,
[16]=function(id,x,y)
	if dirx==-1 and diry==0 then
		mk_popup("locked from this side")
		sfx(36)
	else
		mset(x,y,0)
		sfx(35)
		mk_popup("unlocked")
		add(collected,id)
	end
end
}
--x1,y1,x2,y2,flrclr,ceilclr,music
rooms={
--{15,0,28,13,5,1,nil,{{1},{1,1}} },
--{0,0,14,13,5,1,nil,{{1},{1,1}} }
{77,44,92,55,3,1,true,{{1}} },
{94,38,108,48,5,1,true,{{1,1}} },
{82,26,92,40,5,1,true,{{1,1},{2}} },
{66,31,80,39,5,1,nil,{} },
{63,41,76,52,3,1,nil,{} },
{48,53,76,60,5,1,true,{{4,1},{4},{1,4,2}} },
{36,49,46,60,5,1,nil,{} },
{48,47,62,52,5,1,true,{{4,4}} },
{78,57,91,59,5,1,nil,{} },

{93,55,106,61,5,1,true,{{7}} },
{103,49,113,54,5,1,true,{{7,2},{2,7,2}} },
{110,29,115,49,5,1,true,{{2,7,4},{7}} },
{98,22,108,34,5,1,true,{{2,7,8},{4,7},{8,7,2}} },

{64,2,104,19,5,1,nil,{} },
}
walls={
{1}
}
chests={
{16,7,1},
{21,7,2}
}
-- raycasting script is adapated from https://lodev.org/cgtutor/raycasting.html
-- license:
--[[
/*
copyright (c) 2004-2019, lode vandevenne

all rights reserved.

redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

this software is provided by the copyright holders and contributors
"as is" and any express or implied warranties, including, but not
limited to, the implied warranties of merchantability and fitness for
a particular purpose are disclaimed. in no event shall the copyright owner or
contributors be liable for any direct, indirect, incidental, special,
exemplary, or consequential damages (including, but not limited to,
procurement of substitute goods or services; loss of use, data, or
profits; or business interruption) however caused and on any theory of
liability, whether in contract, strict liability, or tort (including
negligence or otherwise) arising in any way out of the use of this
software, even if advised of the possibility of such damage.
*/]]

function draw_cast(scx,scy)
	rectfill(scx,scy,viewsize+scx,viewsize/2+scy,ceil_clr)
	rectfill(scx,viewsize/2+scy,viewsize+scx,viewsize+scy,flr_clr)
	local texsize,sprsize,px,py=8,8,
	posx+ofx+.5-(dirx*.7),
	posy+ofy+.5-(diry*.7)
	for x=0,viewsize do
		local camerax=2*x/viewsize-1
		local raydirx,raydiry,mapx,mapy,sidedistx,sidedisty,hit,stepx,stepy,perpwalldist,side,sprt,wallx,sprx,drawstart,drawend=dirx+planex*camerax,diry+planey*camerax,flr(px),flr(py),0,0,0
		local deltadistx,deltadisty=abs(1/raydirx),abs(1/raydiry)
		if raydirx<0 then
			stepx,sidedistx=-1,(px-mapx)*deltadistx
		else
			stepx,sidedistx=1,(mapx+1-px)*deltadistx
		end
		if raydiry<0 then
			stepy,sidedisty=-1,(py-mapy)*deltadisty
		else
			stepy,sidedisty=1,(mapy+1-py)*deltadisty
		end
		while hit==0 do
			if sidedistx<sidedisty then
				sidedistx+=deltadistx
				mapx+=stepx
				side=0
			else
				sidedisty+=deltadisty
				mapy+=stepy
				side=1
			end
			sprt=mget(mapx,mapy)
			if(sprt>0 and fget(sprt,0))hit=1
		end
		if side==0 then
			perpwalldist=(mapx-px+(1-stepx)/2)/raydirx
		else
			perpwalldist=(mapy-py+(1-stepy)/2)/raydiry
		end
		local lh=flr(viewsize/perpwalldist)
		drawstart=-lh/2+viewsize/2
		if(drawstart<0)drawstart=0
		drawend=lh/2+viewsize/2
		if(drawend>=viewsize)drawend=viewsize-1
		if side==0 then
			wallx=py+perpwalldist*raydiry
		else
			wallx=px+perpwalldist*raydirx
		end
		wallx-=flr(wallx)
		sprx=flr(wallx*texsize)
		if(side==0 and raydirx>0)sprx=texsize-sprx-1
		if(side==1 and raydiry<0)sprx=texsize-sprx-1
		local sx,sy=sprwallcrd(sprt)
		--if(side==1)shadow()
		sspr(sx+sprx,sy,1,texsize,x+scx,drawstart+scy,1,drawend-drawstart+2)
		--pal(palette)
		zbuffer[x]=perpwalldist
	end
	for i=1,#objects do
		local o=objects[i]
		o.distance=(px-o.x)*(px-o.x)+(py-o.y)*(py-o.y)
	end
	sort(objects,function(a,b)return a.distance<b.distance end)
	for i=1,#objects do
		local o=objects[i]
		if not o.hide then
			local spritex,spritey=o.x+.5-px,o.y+.5-py
			local invdev=1.0/(planex*diry-dirx*planey)
			local transformx=invdev*(diry*spritex-dirx*spritey)
			local transformy=invdev*(-planey*spritex+planex*spritey)
			local spritescreenx=flr((viewsize/2)*(1+transformx/transformy))
			local vmovescreen=flr(o.vmove/transformy)
			local spriteheight=abs(flr(viewsize/(transformy)))/o.vdiv
			local drawstarty=-spriteheight/2+viewsize/2+vmovescreen
			if(drawstarty<0)drawstarty=0
			local drawendy=spriteheight/2+viewsize/2+vmovescreen
			if(drawendy>=viewsize)drawendy=viewsize-1
			local spritewidth=abs(flr(viewsize/transformy))/o.udiv
			local drawstartx=-spritewidth/2+spritescreenx
			if(drawstartx<0)drawstartx=0
			local drawendx=spritewidth/2+spritescreenx
			if(drawendx>=viewsize)drawendx=viewsize-1
			for stripe=drawstartx,drawendx do
				local texx=flr((stripe-(-spritewidth/2+spritescreenx))*sprsize/spritewidth)
				if transformy>0 and stripe>0 and stripe<viewsize and transformy<zbuffer[flr(stripe)] then
					local sx,sy=shtcrd(o.sprite)
					sspr(clamp(sx,sx+texx,sx+sprsize-1),sy,1,sprsize,stripe+scx,drawstarty+scy,1,drawendy-drawstarty)
				end
			end
		end
	end
end

function sprwallcrd(s)
	local fr=nil
	for a in all(walls) do
		if a[1]==s then
			fr=a
		end
	end
	if fr then
		return shtcrd(animframe(fr,1))
	else
		return shtcrd(s)
	end
end

function move(d)
	local nx,ny
	if d==2 then
		nx,ny=pos_forward()
	else
		nx,ny=pos_backward()
	end
	if walkable(nx,ny) then
		ofx,ofy,pt,upd=posx,posy,0,upd_movement
		posx,posy=nx,ny
		ofx-=posx
		ofy-=posy
		sfx(5)
	end
end

function walkable(x,y)
	return not fget(mget(x,y),0)
	and not getobject(x,y)
end

function pos_forward(n)
	n=n or 1
	return posx+dirx*n,posy+diry*n
end

function pos_backward()
	return posx-dirx,posy-diry
end

function rotate(r)
	local olddirx,oldplanex=dirx,planex
	dirx,diry=dirx*cos(r)-diry*sin(r),olddirx*sin(r)+diry*cos(r)
	planex,planey=planex*cos(r)-planey*sin(r),oldplanex*sin(r)+planey*cos(r)
end

function change_room()
	for r in all(rooms) do
		if posx>=r.x and posy>=r.y and posx<=r.w and posy<= r.h then
			cur_room=r
			flr_clr=r.floor
			ceil_clr=r.ceiling
			if cur_room.bgm then
				if stat(24)==-1 then
					music(0)
				end
			else
				if stat(24)>-1 then
					music(-1,300)
				end
			end
			return
		end
	end
end

function call_tile(x,y)
	local o=getobject(x,y)
	if(o and o.activation)o.activation(o)
	local o=mapobj_db[mget(x,y)]
	if(o)o(mapobj[x*y],x,y)
end

function getobject(x,y)
	for o in all(objects) do
		if(x==o.x and y==o.y)return o
	end
end

function collectobj(id)
	cd_set_bit(id+1000,true)
end

function iscollected(id)
	return cd_get_bit(id+1000)
end

function resetcollect()
	for i=1000,1500 do
		cd_set_bit(i,false)
	end
end
-->8
--updates

function _update60()
	if stat(24)>-1 then
		if stat(20)==31 then
			if add_music_layer then
				music(stat(24)+8)
				add_music_layer=false
			end
			if remove_music_layer then
				music(stat(24)-8)
				remove_music_layer=false
			end
		end
	end
	
	upd()
	
	-- hard coded: ending
		if not ending and posx==71 and posy==7 then
			ending=true
			upd=function() end
			after(2,function()
				entities={}
				fade_out()
				upd=upd_transition
				after(0.7,function()
					upd=upd_ending
					drw=drw_ending
					music(-1,300)
				end)
			end)
		end
	
	camera()
	if shakedur>0 then
		shakedur-=1
		camera(cos(shakedur/3),0)
	end
	local f=function(e)
		if e.upd then
			e.upd(e)
		end
	end
	foreach(objects,f)
	foreach(entities,f)
	
	sort(entities,function(a,b)return a.z>b.z end)
end

function upd_title()
	if btnp(é) then
		drw=function()end
		upd=function()end
		
		after(2,function()
			loadgame()

			upd=upd_transition
			
			change_room()
			
			fade_in()
			after(0.7,function()
				upd=upd_player_control
				drw=drw_game
			end)
		end)
	end
	if (time()*10)%.5==0 then
		p_title()
	end
end

function upd_ending()
	
end

function upd_player_control()
	for b=2,3 do
		if(btn(b)) then
			move(b)
		end
	end
	if btnp(ã) then
		prot,upd=-.25,upd_movement
		cur_or-=1
		if(cur_or<1)cur_or=4
	elseif btnp(ë) then
		prot,upd=.25,upd_movement
		cur_or+=1
		if(cur_or>4)cur_or=1
	end
	if btnp(é) then
		call_tile(pos_forward())
	end
end

function upd_movement()
	if prot then
		if prot>0 then
			rotate(rspd)
			prot-=rspd
		end
		if prot<0 then
			rotate(-rspd)
			prot+=rspd
		end
		if abs(prot)<0.01 then
			prot,upd,dirx,diry,planex,planey=nil,upd_player_control,round(dirx),round(diry),round(planex / .66) * .66,round(planey / .66) * .66
		end
	elseif abs(ofx)<0.09 and abs(ofy)<0.09 then
		upd,ofx,ofy=upd_player_control,0,0
		change_room()
		
		if cur_room and #cur_room.battles>0 then
			if stepct<=15 then
				stepct+=1
			else
				if rnd(4)<=1 then
					init_battle()
				end
			end
		end
		
		
	else
		ofx,ofy=lerp(0,ofx,mvspd),lerp(0,ofy,mvspd)
	end
end

function upd_transition()
	fade_p-=3
end

function upd_battle_select()
	if cur_selected_char>1 and btnp(ó) then
		
		--local gotochar=cur_selected_char-1
		for i=cur_selected_char-1,1,-1 do
			if characters[i] and characters[i].life>0 then
				del_menu(battle_menu)
				init_battle_menu(i)
				break
			end
		end
		
		--init_battle_menu(gotochar)
	else
		upd_menu(battle_menu)
	end
end

function upd_battle_target()
	if btnp(ó) then
		del_menu(battle_select_target_menu)
		init_battle_menu(cur_selected_char)
	else
		upd_menu(battle_select_target_menu)
	end
end
-->8
--draws

function _draw()
	cls(1)
	drw()
	foreach(entities,function(e)
		if e.drw then
			e.drw(e)
		end
	end)
	--print(stat(1),1,1,2)
end

function drw_title()
	print_s("tria insomnia",40,40,7,2)
	print_s("press é / z",42,80+3*cos(time()/2),7,2)
end

function drw_ending()
	print_s([[the end]],50,50,7,2)
	print_s([[thank you for playing!]],20,60,7,2)
	
	print("a game by ",15,90)
	print_s("sprvrn",55,90+2*cos(time()),7,2)
	print("&",82,90)
	print_s("nyeti",90,90+2*sin(time()),7,2)
end

function fade_out()
	drw=drw_fade
	fade_p=128
end

function fade_in()
	drw=drw_fade
	fade_p=0
end

function drw_game()
	drw_dungeon()
	
	drw_ui_map()
	drw_ui_warning()
	drw_ui_key()
	
	local px,py=pos_forward()
	if getobject(px,py) or mapobj_db[mget(px,py)] then
		print_s("é / z",50,72+1.5*cos(time()),7,2)
	end
end

function drw_battle()
	drw_dungeon()
	
	if battle_menu then
		local skill=skills[battle_menu.entries[battle_menu.cur_ent].label]
		if skill and skill.description then
			rectfill(4,4,124,12,5)
			rectfill(3,3,123,11,1)
			
			print_s(skill.description,5,5,7,5)
		end
	end
end

function drw_dungeon()
	rect(viewx-2,viewy-2,viewx+viewsize+2,viewy+viewsize+2,7)
	draw_cast(viewx,viewy)
end

function drw_ui_map()
	print_ol(orientation[cur_or],64,1,1,7)
	
	local mx,my=90,5
	rectfill(mx-1,my-1,mx+32,my+32,1)
	rectfill(mx,my,mx+31,my+31,13)
	
	for x=0,15 do
		for y=0,15 do
			local cx,cy=x+(posx-7),y+(posy-7)
			local mcx,mcy=mx+(15*2)-(x*2),my+(y*2)
			local col=nil
			if fget(mget(cx,cy),0) then
				col=5
			end
			if fget(mget(cx,cy),1) then
				col=9
			end
			if cx==posx and cy==posy then
				col=8
			end
			local obj=getobject(cx,cy)
			if obj then
				if obj.sprite==34 then
					col=12
				elseif obj.sprite==50 then
					col=10
				end
			end
			if col then
				rectfill(mcx,mcy,mcx+1,mcy+1,col)
			end
		end
	end
	print_ol("n",105,3,7,1)
	print_ol("s",105,35,7,1)
	print_ol("w",88,18,7,1)
	print_ol("e",121,18,7,1)
end

function drw_ui_warning()
	local c={8,10,12,14}
	spr(c[flr(stepct/5)%4+1],1,1,2,2)
end

function drw_ui_key()
	spr(78,5,20)
	print_s(keys,15,22,7,5)
end

function drw_fade()
	drw_game()
	rectfill(fade_p,0,fade_p+127,127,1)
end
-->8
--particles,menus

function mk_particle(typ,x,y,z,dx,dy,ax,ay,cols,exp)
	if(type(cols)=="number")cols={cols}
	if(type(typ)=="number")typ={typ,typ}
	add(entities,{
	x=x,y=y,z=z,
	dx=dx,dy=dy,
	ax=ax,ay=ay,
	cols=cols,
	start=time(),
	t=exp+time(),
	typ=typ,
	circtyp=circfill,
	upd=function(p)
		if time()>=p.t then
			del(entities,p)
			return
		end
		p.dx+=p.ax*.3
		p.dy+=p.ay*.3
		p.x+=p.dx*.3
		p.y+=p.dy*.3
	end,
	drw=function(p)
		if type(p.typ)=="table" then
			p.circtyp(p.x,p.y,lerp(p.typ[1],p.typ[2],time()-p.start/p.t-p.start),p.cols[1])
		else
			print_ol(p.typ,p.x,p.y,p.cols[1],p.cols[2])
		end
	end
	})
end

function p_title()
	for i=0,32 do
		mk_particle({6,0},i*4,128,0,
		rnd(1)-.5,-rnd(2),0,0,
		{7},3)
	end
end

function p_monster(x,y,c1,c2,ol)
 local cols={c1,c2}
 for i=1,2 do
 	local dx,dy=rnd(1)-.5,-rnd(2)
 	for c=1,2 do
 		local col=cols[flr(rnd(#cols))+1]
 		if(c==2)col=ol
 		mk_particle({6+c,1+c},x,y,-c,
	 	dx,dy,0,0,
	 	col,3)
 	end
 end
end

function p_monster2(x,y,c1,c2,ol)
 p_monster(x,y,c1,c2,ol)
 local cols={c1,c2}
 for i=1,1 do
 	local dx,dy=rnd(2)-1,1.75
 	for c=1,2 do
 		local col=cols[flr(rnd(#cols))+1]
 		if(c==2)col=ol
 		mk_particle({6+c,1+c},x,y,-c,
	 	dx,dy,0,-.1,
	 	col,
	 	3)
 	end
 end
end

function p_dmg_dust(x,y,cols)
	for i=0,10 do
		mk_particle({2,0},x,y,2,
		rnd(2)-1,rnd(2)-1,0,0,
		cols[flr(rnd(#cols))+1],1)
	end
end

function p_cyber(x,y)
	local cols={2,14,8}
	for i=0,20 do
		mk_particle("ó",x-20+(i*1.5),y-12,2,
		0,rnd(2),0,.03,
		{7,cols[flr(rnd(#cols))+1]},
		1.1)
		entities[#entities].upd=function(p)
			if time()>=p.t then
				del(entities,p)
				return
			end
			p.dx+=p.ax*.3
			p.dy+=p.ay*.3
			p.x+=p.dx*.3
			p.y+=p.dy*.3
			local g={
			"é",
			"ó",
			"Ü",
			"ä",
			"î",
			"ê",
			"è",
			"â",
			"Ö",
			"á",
			"ç",
			}
			if (time()*10)%1==0 then
				p.typ=g[flr(rnd(#g))+1]
			end
		end
	end
end

function p_dew(x,y)
	local cols={1,12}
	for i=0,20 do
		mk_particle({2,2},x,y,2,
		rnd(3)-1.5,-(rnd(3)),0,0.2,
		cols[flr(rnd(#cols))+1],2.5)
	end
end

function p_bio(x,y)
	local cols={12,11,3}
	for i=0,10 do
		mk_particle({6,1},x,y,2,
		rnd(2)-1,rnd(2)-1,0,0,
		cols[flr(rnd(#cols))+1],1.6)
	end
end

function p_nuclear(x,y)
	local cols={7,10,9}
	for i=0,10 do
		mk_particle({6,1},x,y,2,
		rnd(2)-1,rnd(2)-1,0,0,
		cols[flr(rnd(#cols))+1],1.6)
		entities[#entities].circtyp=circ
	end
end

function p_dmg_notif(x,y,v,cols)
	mk_particle(tostr(v),x,y,3,
	rnd(2)-1,-2,0,0.2,
	cols or {7,1},1)
end

function p_weak(x,y)
	mk_particle("critical",x,y,3,
	0,2,0,-0.1,
	{7,8},1.5)
end

function p_get_exp(txt,x,y)
	mk_particle(txt,x,y,3,
	0,-1,0,0.05,{7,9},2)
end

--menu
function mk_menu(dirmode,...)
	local menu={
		mode=dirmode,
		entries={},
		cur_ent=1,
	}
	for e in all({...}) do
		local m=mk_menu_ent(e)
		add(menu.entries,m)
		add(entities,m)
	end
	menu.entries[1].cur=true
	return menu
end

function mk_menu_ent(params)
	return {label=params[1],
	x=params[2],
	y=params[3],
	z=params[4],
	drw=params[5],
	activ=params[6]}
end

function selectallitem(menu)
	for m in all(menu.entries) do
		m.cur=true
	end
	menu.selectall=true
end

function upd_menu(menu)
	local d={0,1}
	if(menu.mode==2)d={2,3}
	local ets=menu.entries
	local c=ets[menu.cur_ent]
	
	if btnp(é) then
		if not menu.selectall then
			c.activ(c)
		else
			for m in all(menu.entries) do
				m.activ(m)
			end
		end
		sfx(3)
	end
	
	if not menu.selectall then
		if btnp(d[1]) then
			sfx(3)
			c.cur=false
			menu.cur_ent-=1
			if(menu.cur_ent<1)menu.cur_ent=#ets
		end
		if btnp(d[2]) then
			sfx(3)
			c.cur=false
			menu.cur_ent+=1
			if(menu.cur_ent>#ets)menu.cur_ent=1
		end
		ets[menu.cur_ent].cur=true
	end
end

function del_menu(menu)
	foreach(menu.entries,function(e)
		del(entities,e)
	end)
	menu=nil
end
-->8
--characters

function mkchar(id,name,pic,x,y,l,m,a,d,skills)
	local c={
	x=x,y=y,z=1,
	name=name,
	portrait=pic,level=1,exp=0,
	animoy=0,
	
	b_life=l,
	b_mana=m,
	b_atk=a,
	b_def=d,
	
	drw=function(c)
		spr(c.portrait,c.x,c.y+c.animoy,2,2)
		local life_col=7
		if c.life==0 then
			life_col=8
		end
		print_s("á"..c.life.."/"..get_life(c),c.x+10,c.y+4,life_col,1)
		print_s("è"..c.mana.."/"..get_mana(c),c.x+10,c.y+10,7,1)
		print("LV"..c.level,c.x,c.y+11,7)
		if c.level<maxlevel then
			drw_bar(c.x,c.y+16,35,xptable[c.level],c.exp,9)
		end
	end,
	upd=function(c)
		c.animoy=lerp(c.animoy,0,0.3)
	end
	}
	
	local slvl=dget(id)
	if slvl>0 then
		c.level=slvl
		c.exp=dget(id+3)
	end
	
	c.life=get_life(c)
	c.mana=get_mana(c)
	add(entities,c)
	add(characters,c)
end

function get_life(c)
	return flr(9*c.level+4*c.b_life)+10
end

function get_mana(c)
	return flr(3*c.level+4*c.b_mana)+2
end

function get_atk(c)
	return flr(2*c.level+2*c.b_atk)
end

function get_def(c)
	return flr(.5*c.level+2*c.b_def)
end

function dmg(atk,def,skmod)
	return flr(atk*(100/(100+def))*skmod)
end

function add_exp(c,v)
	if c.level>=maxlevel then
		return
	end
	c.exp+=v
	p_get_exp("+"..v.." xp",c.x,c.y)
	sfx(7)
	if c.exp>=xptable[c.level] then
		after(1,function()
			sfx(6)
			printh(c.exp.." "..xptable[c.level])
			c.exp-=xptable[c.level]
			c.level+=1
			p_get_exp("level up!",c.x,c.y)
			c.life=get_life(c)
			c.mana=get_mana(c)
		end)
	end
end

function mkskill(name,str,trgt,ele,cost,de)
	skills[name]={
	name=name,
	str=str,
	targettype=trgt,
	element=ele,
	cost=cost,
	description=de
	}
end

function mkelement(name,col,p_func,weak,sound)
	add(elements,{
	name=name,
	col=col,
	particle=p_func,
	weak=weak,
	sound=sound
	})
end

function drw_bar(x,y,barmaxw,maxv,curv,col)
	local barx1,bary1=x,y
	local barx2,bary2=barx1+barmaxw,bary1
	local percent=(curv*100)/maxv
	local barw=flr(barmaxw*(percent/100))
	rectfill(barx1,bary1,barx2,bary2,4)
	rectfill(barx1,bary1,barx1+barw,bary2,col)
end
-->8
--monsters&battle

function mkmonster(name,s,c1,c2,lvl,l,m,a,d,weak,skills)
	add(monsters,{
	name=name,sprite=s,
	col1=c1,col2=c2,
	b_life=l,
	b_mana=m,
	b_atk=a,
	b_def=d,
	level=lvl,
	weak=weak,
	skills=skills
	})
end

function init_battle(battle)
	upd=function()end
	
	gain_xp=0
	
	mk_popup("enemy appears!")
	sfx(39)
	
	after(2,function()
		drw=drw_battle
		actors={}
		for c in all(characters) do
			add(actors,c)
		end
		
		battle=battle or cur_room.battles[flr(rnd(#cur_room.battles))+1]
		local i=0
		for m in all(battle) do
			mkactor(monsters[m],
			54-((#battle-1)*20)+(i*40),
			54)
			i+=1
		end
		
		selected_moves={}
		
		if stat(24)>-1 then
			add_music_layer=true
		elseif stat(24)==-1 then
			music(8,300)
		end
		
		after(1,function()
			init_battle_menu(1)
		end)
	end)
end

function mkactor(m,x,y)
	local a={
	name=m.name,
	sprite=m.sprite,
	col1=m.col1,col2=m.col2,
	x=x,y=y,z=1,
	animoy=0,
	ox=0,oy=0,
	mana=0,
	level=m.level,
	b_life=m.b_life,
	b_mana=m.b_mana,
	b_atk=m.b_atk,
	b_def=m.b_def,
	weak=m.weak,
	skills=m.skills,
	particle=m.particle,
	monster=true,
	upd=function(e)
		if time()%.25==0 then
			e.ox=rnd(2)-1
			e.oy=rnd(2)-1
			e.animoy=lerp(e.animoy,0,.3)
			local p_func=e.particle or p_monster
			p_func(e.x+8,e.y+8,e.col1,e.col2,elements[e.weak].col or nil)
		end
	end,
	drw=function(e)
		local sx,sy=shtcrd(e.sprite)
		sspr(sx,sy,8,8,e.x+e.ox,e.y+e.oy+e.animoy,16,16)
		drw_bar(e.x-5,e.y+24,25,get_life(e),e.life,8)
		--print(e.life.."/"..get_life(e),e.x,e.y,7)
	end
	}
	a.life=get_life(a)
	add(actors,a)
	add(entities,a)
end

function end_battle(runaway)
	for a in all(actors) do
		if a.monster then
			del(actors,a)
			del(entities,a)
		end
	end
	actors={}
	
	for c in all(characters) do
		c.move=nil
	end
	
	if cur_room and cur_room.bgm then
		remove_music_layer=true
	else
		music(-1,300)
	end
	
	if runaway then
		after(2,function()
			mk_popup("you're running away")
			upd=upd_player_control
			stepct=5
			drw=drw_game
		end)
	else
		after(2,function()
			mk_popup("victory!")
			if collect_at_end then
				add(collected,collect_at_end.id)
				del(objects,collect_at_end)
				collect_at_end=nil
			end
			local alive_char={}
			for c in all(characters) do
				if c.life>0 then
					add(alive_char,c)
				end
			end
			local exp_p_char=ceil(gain_xp/#alive_char)
			for c in all(alive_char) do
				add_exp(c,exp_p_char)
			end
			upd=upd_player_control
			drw=drw_game
			stepct=0
		end)
	end
end

function init_battle_menu(id)
	local c=characters[id]
	if not c then
		upd=function()end
		battle_resolution()
		return
	end
	if c.life<=0 then
		init_battle_menu(id+1)
	else
		cur_selected_char=id
		local m={}
		local i=0
		while i<=c.level do
			if c.skills[i] then
				add(m,c.skills[i])
			end
			i+=1
		end
		add(m,"run")
		local moves={}
		for i=1,#m,1 do
			add(moves,{m[i],
			c.x,c.y-15-6*#m+(i*8),
			2,
			drw_btl_item_menu,
			call_atk_btn})
		end
		sfx(4)
		battle_menu=mk_menu(2,unpack(moves))
		upd=upd_battle_select
		if c.move then
			battle_menu.entries[1].cur=false
			for k,e in pairs(battle_menu.entries)do
				if e.label==c.move then
					e.cur=true
					battle_menu.cur_ent=k
				end
			end
		end
	end
end

function drw_btl_item_menu(e)
	local col1,col2,ox=7,nil,0
	rectfill(e.x-1,e.y-2,e.x+39,e.y+5,1)
	if e.cur then
		col2=2
		ox=9
		spr(79,e.x,e.y)
	end
	local skill=skills[e.label]
	if skill then
		local ele=elements[skill.element]
	
		col1=ele.col
	end
	print_s(e.label,e.x+ox,e.y,col1,col2)
	if skill and skill.cost>0 then
		print_s(skill.cost,e.x+37,e.y,6,2)
	end
end

function call_atk_btn(e)
	targetselected=false
	local sk=skills[e.label]
	if sk and characters[cur_selected_char].mana<sk.cost then
		mk_popup("not enough mana")
		sfx(36)
		return
	end
	del_menu(battle_menu)
	if e.label=="run" then
		if not collect_at_end then
			characters[cur_selected_char].move="run"
			init_battle_menu(cur_selected_char+1)
			return
		else
			mk_popup("can't run away")
			init_battle_menu(cur_selected_char)
			return
		end
	end
	
	local trg={}
	for k,a in pairs(actors) do
		if (sk.targettype>0 and a.monster)
			or(sk.targettype<0 and not a.monster) then
			if a.life>0 then
				add(trg,{a.name..k,a.x,a.y,0,
					function(e)
						if e.cur then
							box(a.x-2,a.y-2,19,19,1)
						end
					end,
					function()
						local curchar=characters[cur_selected_char]
						curchar.move=e.label
						if not battle_select_target_menu.selectall then
							curchar.target=a
							del_menu(battle_select_target_menu)
							init_battle_menu(cur_selected_char+1)
						else
							curchar.target={}
							for t in all(trg) do
								add(curchar.target,t.actor)
							end
							
							if not targetselected then
								targetselected=true
								del_menu(battle_select_target_menu)
								init_battle_menu(cur_selected_char+1)
							end
						end
					end})
					trg[#trg].actor=a
				end
		end
	end
	battle_select_target_menu=mk_menu(1,unpack(trg))
	upd=upd_battle_target
	
	if sk.targettype==2 or sk.targettype==-2 then
		selectallitem(battle_select_target_menu)
	end
end

function battle_resolution()
	cur_actor=0
	delay_after=1
	battle_menu=nil
	actormove()
end

function actormove()
	cur_actor+=1
	
	local a=actors[cur_actor]
	if not a then
		end_battle()
		return
	end
	if a.monster then
		a.move=a.skills[flr(rnd(#a.skills))+1]
	end
	local skill=skills[a.move]
	local element
	if(skill)element=elements[skill.element]
	if a.life>0 then
		if a.move=="run" then
			end_battle(true)
		else
			if a.monster then
				if skill.targettype==2 then
					a.target={}
					for c in all(characters)do 
						add(a.target,c)
					end
				elseif skill.targettype==1 then
					a.target=get_rnd_char()
				elseif skill.targettype==-1 then
					a.target=get_rnd_monster()
				elseif skill.targettype==-2 then
					a.target={}
					for a1 in all(actors)do
						if(a1.monster)add(a.target,a1)
					end
				end
				a.animoy=20
			else
				a.animoy=-20
			end
			if skill.targettype==1 and not contains(actors,a.target) then
				a.target=get_rnd_monster()
			end
			if a.target.level then
				a.target={a.target}
			end
			for t in all(a.target) do
				if t.life>0 then
					for n=1,skill.hits or 1 do
						after((n-1)*.2,function()
							element.particle(t.x+8,t.y+8,{13,6})
							local damage=dmg(get_atk(a),get_def(t),skill.str)
							if(damage>0)shakedur=5
							--printh(a.name.." atk "..t.name.." with "..a.move.." - "..damage)

							sfx(element.sound)
							deal_dmg(t,damage,skill.element)
						end)
					end
				end
			end
					
			a.mana-=skill.cost
			if(a.mana<0)a.mana=0
					
			after(delay_after,function()
				delay_after=skill.delay or 1
				if is_monster() then
					if cur_actor<#actors then
						actormove()
					else
						after(1,function()
							if player_alive() then
								for c in all(characters) do
									c.move=nil
								end
								init_battle_menu(1)
							else
								fade_out()
								upd=upd_transition
								for a in all(actors)do
									del(entities,a)
									del(actors,a)
								end
								music(-1,300)
								sfx(37)
								mk_popup("you were defeated")
								if collect_at_end then
									collect_at_end.hide=false
								end
								after(0.7,function()									
									loadgame()
									fade_in()
									upd=function()end
									after(1.5,function()
										upd=upd_player_control
										drw=drw_game
									end)
								end)
							end
						end)
					end
				else
					end_battle()
				end
			end)
 	end
	else
		actormove()
	end
end

function get_rnd_char()
	local t={}
	for c in all(characters) do
		if c.life>0 then
			add(t,c)
		end
	end
	return t[flr(rnd(#t))+1]
end

function get_rnd_monster()
	local t={}
	for a in all(actors) do
		if a.monster then
			add(t,a)
		end
	end
	return t[flr(rnd(#t))+1]
end

function player_alive()
	for c in all(characters) do
		if(c.life>0)return true
	end
	return false
end

function is_monster()
	for a in all(actors) do
		if(a.monster)return true
	end
end

function deal_dmg(a,v,ele)
	if a.weak and ele==a.weak then
		v*=1.25
		v=flr(v)
		p_weak(a.x,a.y+8)
	end
	a.life-=v
	local cols=nil
	if v<0 then
		cols={7,3}
	end
	p_dmg_notif(a.x+8,a.y+8,abs(v),cols)
	if a.life>get_life(a) then
		a.life=get_life(a)
	end
	if a.life<=0 then
		a.life=0
		if a.monster then
			gain_xp+=a.level*2
			del(actors,a)
			del(entities,a)
			--cur_actor-=1
		end
	end
end
__gfx__
00000000dddd11ddddddddddbb111b11bb111411ddd11ddd66666666d1d111dd0000000cc00000000000000bb00000000000000aa00000000000000880000000
00000000111111111d1111d1bbb1bbb1bbb11411dd11111d6d666666ddd11ddd000000cccc000000000000bbbb000000000000aaaa0000000000008888000000
00700700dd11dddd11d11d111bb1b1111bb14111d11ddd11ddddddd6dd1111dd00000cccccc0000000000bbbbbb0000000000aaaaaa000000000088888800000
000770001111111111d11d11111111bb1114111111ddddd1dddddddd111111110000cccccccc00000000bbbbbbbb00000000aaaaaaaa00000000888888880000
00077000dddd11dd11d11d1111b11bbb114111bb1dddddd1dddddddd11dddd11000c0cccccc0c000000b0bbbbbb0b000000a0aaaaaa0a0000008088888808000
007007001111111111d11d111bbb1bb111411bbb11dddd11dddddd5d1dddddd100cc0cccccc0cc0000bb0bbbbbb0bb0000aa0aaaaaa0aa000088088888808800
00000000dd11dddd1d1111d11bbb111111141bb111111111555d55551d1ddd110ccc00000000ccc00bbb00000000bbb00aaa00000000aaa00888000000008880
0000000011111111dddddddd11b1111111114111dd1111dd5555555511111111cccc00c00c00ccccbbbb00b00b00bbbbaaaa00a00a00aaaa8888008008008888
1999999012222221cccccccc0000000000cccc0c999911999911191199111411cccc00c00c00ccccbbbb00b00b00bbbbaaaa00a00a00aaaa8888008008008888
9191191921121112cccccccc00000000cc0cc0c01111111199919991999114110ccc00000000ccc00bbb00000000bbb00aaa00000000aaa00888000000008880
91911919211211121cc11cc1000000000c0000cc99119999199191111991411100ccc000000ccc0000bbb000000bbb0000aaa000000aaa000088800000088800
999999992112111211111111000000000c000ccc111111111111119911141111000ccc0000ccc000000bbb0000bbb000000aaa0000aaa0000008880000888000
9199191921122112c11cc11c000000000cc000c09999119911911999114111990000cccccccc00000000bbbbbbbb00000000aaaaaaaa00000000888888880000
9191191921122112c11cc11c00000000cc0000c011111111199919911141199900000cccccc0000000000bbbbbb0000000000aaaaaa000000000088888800000
99999999211211121111111100000000cc0000cc991199991999111111141991000000cccc000000000000bbbb000000000000aaaa0000000000008888000000
91911919211211121c111c11000000000cc00cc01111111111911111111141110000000cc00000000000000bb00000000000000aa00000000000000880000000
000000001222222000000000000000000000000000000000cc111c11ee111e110000000000000000000000000000000000000000000000000000000000000000
800000082121121200cccc00000000000000000000000000ccc1ccc1eee1eee10000000000000000000000000000000000000000000000000000000000000000
08000080212112120c77cc300000000000000000000000001cc1c1111ee1e1110000000000000000000000000000000000000000000000000000000000000000
08888880222222220c77cc30000000000000000000000000111111cc111111ee0000000000000000000000000000000000000000000000000000000000000000
08088080212212120ccccc3000000000000000000000000011c11ccc11e11eee0000000000000000000000000000000000000000000000000000000000000000
08088080212112120cccc3300000000000000000000000001ccc1cc11eee1ee10000000000000000000000000000000000000000000000000000000000000000
0888888022222222003333000000000000000000000000001ccc11111eee11110000000000000000000000000000000000000000000000000000000000000000
00888800212112120000000000000000000000000000000011c1111111e111110000000000000000000000000000000000000000000000000000000000000000
08888880800000080444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888800000084999999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88088088888888884999999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888880880884444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80888808880880884994499449944994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88000088088888804999999449999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880088888804999999449999994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800008888004444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000
60000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777000
66666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666000077777770
66066066066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006556666677777220
66066066060660600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006006565677222000
66666666066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666050522000000
06666660006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555000000000000
00666600000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660066666600066660000600600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666660666666006000060600000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66066066660660666600006666666666060000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666066660660066006066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660606666066666666666066066060660600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666600660000666606606666666666060660600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600066666606666666606666660066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006666000666666000666600006666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2211111111112221111bbb1bbbbbb111cc111111111111cc11199999999919990000000000000000000000000000000000000000000000000000000000000000
211111111111121111bbb1b11bbbbb11c11111111c11111c11999991999999990000000000000000000000000000000000000000000000000000000000000000
11111111111111111bbbb1bbb1bbbb111111111ccc11111c19999119199999990000000000000000000000000000000000000000000000000000000000000000
11111211111111111bbbb1bbb1bbbbb111111ccccc11111c99911999919999910000000000000000000000000000000000000000000000000000000000000000
11111222111111111bbb1bbb11bbbbbb111ccccccc11111199199999991999910000000000000000000000000000000000000000000000000000000000000000
11222222221111111bb1bbbbbb1bbbbb111ccccccc11111191999999991919910000000000000000000000000000000000000000000000000000000000000000
11112211121121111b111bb1111bbbbb11111cc111111c1191111991111919910000000000000000000000000000000000000000000000000000000000000000
11122211221121111b11bbbb11b1bbbb1111cccc1cc11c1191919999119119910000000000000000000000000000000000000000000000000000000000000000
1112221122212111bb11bbbb11bb1bbb1111cccc11cc1c1191919999119919110000000000000000000000000000000000000000000000000000000000000000
1122222222211111bb1bbbbbbbbb1bbb111cccccccccc11111999999999919110000000000000000000000000000000000000000000000000000000000000000
1122222222211111bb1bbbbbbbbb1bbb111ccccccccc111111999999999919110000000000000000000000000000000000000000000000000000000000000000
1122222222111111bb1bbbbbbbb1bbbb111cccccccc1111111999999999191110000000000000000000000000000000000000000000000000000000000000000
2122112222111111bb1bb111bbb1bbb1111cc11cccc1111111199119999191110000000000000000000000000000000000000000000000000000000000000000
22122222211112111bb1bbbbbb1bbbb11111cccccc11111111119999991111110000000000000000000000000000000000000000000000000000000000000000
22211111111122111bbb111111bbbb11111111111111111c11111111111111110000000000000000000000000000000000000000000000000000000000000000
222212221112221111bbb1bbb1bbbb11111111ccc111111c11119999991111110000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010
10101010101010101010101000000000001100201010101010101010200010101010710071515171710000617171717100007110101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010
10101010101010101010101000101010101010101010101010101010200010101010510000000000000000711010710000000071101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010
10101000000010101010101000101010101000000000000000000000000010101010717151717171617161711010710000000071101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010
10101020002010101010101000101010101010101010200020101010101010101010101010101010101010101010710000000071101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010
10101020000000000000000000101010101000000000000010101010101010101010101010101010101010101010107100007110101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010
10101020002010101010101010101010101000201010101010101010101010101010101010101010101010101010105000501010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010
10101000000010101010101010101010101000201010101010200020101010101010101010101010101010101010105000501010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010
10101010001010101010101010101010101000000000000000000000001100000000000000000000000000001010105000501010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101030
30301010111010303030101010101010101010101010101010200020101010101010101010102000201010101010105000501010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101030
00000000000000000030101010101010101010101010101010101010101010101010101010101000101010101010106100611010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101030
00004000000040000030101010101010101010101010101010101010101010101000000000000000101010101010617100716110101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101030
00000000000000000030101010101010101010101010101010101010101010101000201010101010101010101061717100717161101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101030
30300000130000303030101010101010101010101010101010101010101010101000001010101010101010101061717100717161101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101010
10104030003040303030303030301010401020101020101010303010101010101000001010101010101010101010617100716110101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101010
10103000000000300000000000204010101010101030101040000000002010101000001010101010101010101010106100611010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101050501010105050505010101050505050505010
10103000000000300000000000010010101010101020101030000000001100000000001010101010101010101061711000611010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101000001000000000000000000000000000000010
10103000230000000000303030200000000000000000000000000000222010101010101010101010101010101010100000611010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101020202021212121212000002040004000200040002000200040002010
40503030303030303030301010100010401010103010301010104010104010101010101010101010106171101010100061611010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101020220000000000000000001100000000000000000000000000000011
00000000000000000000000023500010101010101010101010101010101010101010101010101010000000101071000000101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101020000000000000002000002040004000200020004000200020004010
40000000000000000000000000200040101010101010101010101010101010101010101010101061000000000010107100611010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101021000000000000002100001000000000000000000000000000005050
50505050505050500000000000010040101010101010101010101010101010101010101010101061006110100000000000101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101021002121212121212121211021212110212121212121212121212121
21212121212121211010101010200010103040303030403030303010101010101010101010101071001010101010616110101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101021002121212121101010212121210000002100000000000000002100
00000000000000002121210000120000000000000000000000001010101010101010101010101061001010101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101021002100002100000000001010210020002100202121212121002100
20212121212121002121210000201030304030303040304030303010103010101030101010301010114010101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101021002100002000000000002122000021002100000000000021002100
00000000000021002121212100211010101010101010101010101010100000000000101010100000000000101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101021000000000003000000001100000021002121212121200021002121
21212121200021002121212100211010101010101010101010101010100020002000204010200020002000301010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101021002100002000000000002121212121002121212121200021002000
00220000000021002121212100120000000000000000000000000000110000000000000000000000000022101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101021002100002100000000002110212121000000000000000021000000
00000000200021000000000000211010101010101010101010101010100020002000201010200020002000401010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101021212121212121102110211010212121212121212121212121212021
21212121212121212121212022201010101010101010101010101010100000000000101010400000000000101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010102120211010101010101010101010101010101030104010101010101030103010101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
00000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
__gff__
0001010101010101000000000000000003030101010101010000000000000000000300010003010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101161627160101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101161627030000261601010101010103161616010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101011616260000000000000027161601011626000027160101010101010101010101010101010101010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101011627001700000004000000000316262700000000001602020202020202020202020202020201010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101012600000002000200000000000000000000000000000000000000000000020000000000000201010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101160000000000000000000000000000000000000000000000000000000000000000000000000201010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101271600000002000200000000000000000000000000000000000000000000020000000000000201010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101011627000400000017000000261600000000000000000002020202020202020202020202000201010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101011603000000000027032616161627000000000000001616010101010101010101010102000201010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010116000000000016010101010116030026031627161601010101010101010101010117000201010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010116271616261616010101010101162616011616010101010101010101010101010200000002010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101020002001700020101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101170000200000020101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101020000000000020101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101020022000000020101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101020000000000170101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101011700000002010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010102000201010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101110101010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010102000201010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101150115011515031501151515011503151515031515150300000001010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101040000000000000000000000000000000000000000000000000017010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101150000000115151515011515150115151515150315150300000001010101010101010101010101010101010101010101010000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010000000101010101010101010101010101010101011700000001010101010101010101010101010101010101010101010000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101040000001517011701010101010101010101010101010217001702010101010101010101010101010101010101010101010000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101150000001000000001010101010101010101010101010000000000170101010101010101010101010101010101010101010000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101031503150122000001010101010101010101010101011717171700010101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010100000001010101010101010101010101010000001700170101010101010101010101010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010100020101010101010101010101010101170017001700171716171717171717171701010101010101010101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101010101010101010101010101010101010101010101010100000000000000000000000001010101160017000000162200000011000000001701010101010101010101010101
__sfx__
000c000014750217501a7502975021750327502875032740337403373033710307000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000346303462034620306202c62027620236201e62019620116100a610046100260000600054000540005400054000060000600006000160001600016000160001600016000160000000000000000000000
00010000111500e150131501b15022150291502115019150121500c1500a1500e15013150181501c1502215027150261501d150161500e150141501b1501f15024150231501c150141500e1500d1501115010150
0004000028050000000000000000000002f1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e00001913023710032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000b6300260000600187001d700217000000000000257002b7002f700317000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000091500e15014150191501815012150161501c1502115027150241502115021150261502b150301403414037140331302f1302c1202f120331203712036120321202f1202e1103211035110391103e110
000800001c5502753021550295501f5502c5501e550315502a5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c000009562095451a000150000455204545150001500009562095451a000130000b5620b54515000130000c5620c54515000000000b5620b545150000000009562095451a000000000b5620b5450000000000
010c000009562095451300000000045620454513000000000956209545130000000010562105451a000000000e5620e54513000000000d5620d5451300000000095620954513000000000d5620d5451a00000000
010c000007562075451c0001500009562095451c0001a0000a5620a5451c0001c000095620954515000190000c5620c54515000150000756207545150001a0000656206545150001900009562095450000000000
010c00000e5620e5450000000000095620954500000000000656206545000000000009562095450000000000075620754500000000000a5620a54500000000000956209545000000000007562075450000000000
010c000004562045450000000000075620754500000000000b5620b54500000000000c5620c54500000000000b5620b5450000000000045620454500000000000756207545000000000006562065450000000000
010c000004562045450000000000095620954500000000000c5620c54500000000000e5620e545000000000010562105450000000000095620954500000000000c5620c54500000000000b5620b5450000000000
010c00000963500000096150000009625000000000000000096350000000000000000000000000000000000015143000000000000000000000000000000000000963500000000000000009615000000000000000
010c00001513309625096350000015133000000963509625151330000009635000001513300000096350000015133096250963500000151330962509635000001513300000096350962515133000000963500000
010c00001513309625096350000015133000000963509625151330000009635096251513300000096350000015133096250963500000151330960009635000001513300000096350962515133096250963509625
010c00001514500000171350000015125000001711500000151150000000000000001514500000171450000018145000001711500000151150000000000000001414500000111150000014115000000000000000
010c0000151450000017135000001512500000171150000015115000000000000000151450000017145000001a145000001911500000171150000000000000001514500000171150000019115000000000000000
010c0000151450000017135000001512500000171150000015115000000000000000151450000017145000001a145000001911500000171150000000000000001a145000001c115000001e115000000000000000
010c00001f1450000017100000001e1450000017100000001a145000000000000000191450000017100000001614500000191000000015145000000000000000131450000012135000000e145000001213500000
010c00000e1450000017100000001214500000171000000015145000000000000000191450000017100000001a145000001910000000161450000000000000001314500000161350000015145000001313500000
010c00001014500000000000000012145000000000000000131450000012100000001514500000000000000017145000000000000000101450000000000000001314500000121350000010145000001210000000
010c00001014500000000000000012145000000000000000131450000012135000001014500000000000000010145000001213500000101250000012115000001014500000121350000010125000001211500000
010c00000924500000092350000009245000000923500000092450000009235000000924500000092350000009245000000c235000000b24500000092350000008245000000b2350000009245000000823500000
010c0000092450000009235000000924500000092350000009245000000923500000092450000009235000000e245000000d235000000a2450000009235000000724500000062350000003245000000223500000
010c00000924500000042350000009245000000c23500000102450000009235000000c245000000a2350000009245000000c235000000b24500000092350000008245000000b2350000009245000000823500000
010c000009245000000c2350000010245000000c235000000924500000042350000009245000000c235000000e245000000d235000000a2450000009235000000724500000062350000003245000000223500000
010c000007245000000a235000000e24500000132350000012245000000f235000000e245000000c235000000c235000000a23500000092450000007235000000923500000072350000006245000000323500000
010c00000224500000062350000009245000000a235000000e2420e23500000000000d245000000a23500000072420723500000000000a2420a23500000000000724500000062350000003245000000023500000
010c000004245000000623500000072450000009235000000b245000000c2350000010245000000c235000000b245000000423500000072450000006235000000224500000072350000006245000000223500000
010c00000424500000072450000009245000000b245000000c2450000007245000000e24500000072450000004245000000423500000042450000004235000000724500000072350722507245000000723507200
000100000e350153501c35022350273502c3502f350323500c35013350163501a3501f34022340273402c34030340343400d3401034013340183401c34021330263302c330313203632000300243002c30032300
00010000166501b6501d6501f6501f6501b6501465014650007500074000740007401a6401e640206402264022640206301a63018630007300073000730007301b6301e6302062021620216201d6201862017620
000300000a75012750167501b7501f7502375030750267501e750157500d7500c750167501c75021750357502c7502275019750117500f750097500e75013750187501e71030710287102171016710117100f710
00060000336200000000000000001b620000000000000000096200a600000000c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f5701f5701f5701f5701f570185701857018570185401854011540115401154011540115401154032100321003210032100321003510035100351003510035100000000000000000000000000000000
000300001875018750187501875028750287502875028750287502275022750227502275022750187501875018750187501875018750117501175011750117501175009750097500975009750097500975009750
00080000257502c750327303a7203d720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001f7501f7501f7501f7501f7501f7500000000000000001f7501f7501f7501f7501f7501f7501f7500000000000000001f7501f7501f7501f7501f7501f7501f750000000000000000000000000000000
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
01 08 0e 11 44
00 09 0e 12 44
00 08 0e 11 44
00 09 0e 13 44
00 0a 0e 14 44
00 0b 0e 15 44
00 0c 0e 16 44
02 0d 0e 17 44
01 08 0f 18 44
00 09 0f 19 44
00 08 0f 1a 44
00 09 10 1b 44
00 0a 0f 1c 44
00 0b 0f 1d 44
00 0c 0f 1e 44
02 0d 10 1f 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
