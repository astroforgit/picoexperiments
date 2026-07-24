pico-8 cartridge // http://www.pico-8.com
version 22
__lua__
-- mini ex machina v1.0
-- targem homework 2019-2020

function _init()
	mus_f=true	
	menuitem(1,"restart game",restart)

	parse([[
dirx=-1,1,0,0
diry=0,0,-1,1
dpal=0,1,1,2,1,13,6,4,4,9,3,13,1,13,14
rot_spr=97,98,98,99,99,98,98,97,97

item_
name,        type,  stat, buy, sale
potatos,     goods, 0,     0,   0
scrap,       goods, 0,     1,   0
wood,        goods, 0,     2,   0
books,       goods, 0,     3,   0
rusty gun,   gun,   0,     4,  24
shotgun,     gun,   0,     5,  24
bumper,      bump,  1,     6,  47
supa gun,    gun,   1,     7,  81
small trunk, body,  1,     4,  4
medium trunk,body,  2,     5,  23
big trunk,   body,  3,     6,  62
huge trunk,  body,  4,     7,  81
wood cover,  armor, 2,     4,  4
tin cover,   armor, 3,     5,  33
iron cover,  armor, 4,     6,  62
steel cover, armor, 6,     7,  81

mobs_
spr, wep, dmg, hp, name
64,  1,   1,   1,  0
66,  2,   1,   1,  0
68,  1,   1,   3,  0
74,  2,   1,   3,  0
70,  2,   2,   4,  mech spider
72,  2,   4,   6,  super tank

roadtl=0,0,16,0,18,4,17,0,3,48,32,50,34,49,33
fillerstl=1,9,2,24,25
gameobjtl=13,35,63
hometl=6,7,8
city_names=kamensk,ekabu,kyshtim,chelly,kurgan,petropavl,kokshetau,burabai,nursultan
gatetl=44,51,43,55,40,   46,51,45,28,39
gate2tl=44,51,44,42,41,  46,51,46,27,38
bordertl=10,51,10,55,10, 10,51,10,28,10
musa=0,14
road_decor1=1,1,1,2,1,1,10,10,1,6,51,2,8,1,2,1,1
road_decor2=4,4,4,4,4,4, 4, 4,4,4, 4,4,4,4,4,4,4
filler_decor1=1,9,2,24,25,6,5,51,13,63,10,55,10
filler_decor2=4,4,4, 4, 4,4,4, 4, 4, 4, 4,42,44
]])

	qs_txt=
	{
		{"talk to the %s mayor","what brings you here?"},
		{"destroy the %s",""},
		{"bring $20 to %s","got $20 to fix the road?"},
		{"bring %s wood to %s","got any wood for bridge?"},
		{"bring %s scrap to %s","got any scrap for us?"},
		{"destroy bandits' lair",""},
		{"return to the %s","do you have good news?"}
	}	

	cartdata("mem")
	st_hiscore=dget(0)
	showsplash()
	fadeperc=1
end

function _update()
	t+=1/10
	sindx=sin(time())
	_upd()
	if _upd!=updsp then
		dust_update()
		animate_tl()
		animate_camera()
		dofloats()
		dohpwnd()
	end
end

function _draw()
	_drw()
	if _drw!=drwsp then
		if fadeperc>0 then
			fadeperc=max(fadeperc-0.04,0)
			dofade()
		end
		drawnd()
	end
end

function startgame()
	t=0
	cam_x,cam_y=0,0
	ox,oy=0,0
	pdir = 2
	cf=false
	r_mode=0
	incity=false
	relod=false

	gold=10
	hp=5
	hp_max=8
	hp_up=0
	dmg_up=0
	dmg_up2=0
	inv_cur=0
	inv_max=5
	inv_up=0
	inv={}
	amo={}
	eqp={}

	st_kills=0
	st_moves=0
	st_gold=0
	st_score=0

	wnd={}
	float={}

	dust={}
	expl={}
	bulls={}

	city_itms_init()
	gen_zones_n_quests()
	gen_map()

	px,py=getfreecellfromzone2(zones[1],get_xy(zones[1].cityid))

	mobs_init()
	lair_init()

	qs_init()
	sideq_init()

	city_init()

	fog_init()
	fog_update()
	
	_upd=update_game
	_drw=draw_game

	hpwnd=addwnd(5,5,80,13,{})

	local txt1={"the cyclone had set","the car down very","gently-for cyclone","in the midst of","a country of","marvelous beauty."}
	local txt2={"i can't get out of here","on this piece of junk,","so i need to get to","the nearest city and","ask for help!"}
	local dialog={{txt=txt1,img=76,size=4},{txt=txt2,img=88,size=2}}
	showdialog(dialog)
end

function gen_zones_n_quests()
	qs_chain={}
	zones={}
	
	add(qs_chain,{type=1,city=1})
	add(zones,{lvl=1,gate=1})
	local lq=-1
	local nospdr=true

	for i=2,#city_names-1 do
		add(qs_chain,{type=1,city=i})

		local zl=min(flr((i+1)/2),4)

	::m1::
		local nq=rand(5)+1
		if(nq==lq)goto m1
		
		if(i==2 and nq==2)nq=3
		if(i==#city_names-1 and nospdr)nq=2

		gq=nq
		if(gq>5)gq=5
		
		add(zones,{lvl=zl,gate=gq})
		local q={type=nq,city=i,par2=min(rand(8),i*2),zone=#zones}

		if nq==2 then
			q.par2=5
			q.zone=#zones+1
			q.city=nil
			add(zones,{lvl=zl,gate=5,nocity=1})
			add(qs_chain,q)
			q={type=7,city=i,zone=#zones}
			nospdr=false
		elseif nq==4 then
			city_itms[i][3]=0
			city_itms[i-1][3]=1
		elseif nq==5 then
			city_itms[i][2]=0
			city_itms[i-1][2]=1
		elseif nq==6 then
			q.city=nil
			add(qs_chain,q)
			q={type=7,city=i,zone=#zones}
		end
		add(qs_chain,q)
		if(rand(3)==1)add(zones,{lvl=zl,gate=1,nocity=1})
		lq=nq
	end

	add(zones,{lvl=4,gate=2})
	add(zones,{lvl=4,nocity=1})
	add(qs_chain,{type=1,city=#city_names})
	add(qs_chain,{type=2,par2=6,zone=#zones})
	add(qs_chain,{type=7,city=#city_names})
	add(qs_chain,{type=5,city=1,par2=24})
	add(qs_chain,{type=99})
	city_itms[#city_names][2]=1
end

function city_itms_init()
	city_itms={}
	for c=1,#city_names do
		add(city_itms,explode("0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"))
		for i=1,min(c,4) do
			for j=0,3 do
				city_itms[c][j*4+i]=rand(2)-1
			end
		end
	end
end

function city_init()
	cityinfo={}
	for zone in all(zones) do
		if zone.cityid>0 then
			_x,_y=get_xy(zone.cityid)
			l1,l2={},{}
			for i=1,#item_name do
				_t=item_buy[i]+rand(4)
				_t2=_t+item_sale[i]+rand(4)
				if( city_itms[#cityinfo+1][i]==0 ) _t2=-1
				add(l1,_t)
				add(l2,_t2)
			end
			local city={x=_x,y=_y,la=l1,lb=l2}
			add(cityinfo,city)
			city.name=city_names[#cityinfo]
			city.zone=zone
			city.sidequest = sidequest_random(#cityinfo)
			city.visited=false
		end
	end	
end

function lair_init()
	lairs={}
	for x=0,mapw do
		for y=0,maph do
			if (mget(x,y)==13) add(lairs,{x=x,y=y,zone=zones_get(x,y),c=10})
		end
	end
end

function mobs_init()
	loot={}
	mobs={}
	for zone in all(zones) do
		zone.mobs=rand(zone.h*zone.w/10)
		for _i=1,zone.mobs do
			local x,y=getfreecellfromzone(zone)
			mobs_add(x,y,rand(zone.lvl))
		end
		zone.loot=rand(zone.h*zone.w/20)
		for _i=1,zone.loot do
			local _x,_y=getfreecellfromzone(zone)
			if(_x)add(loot,{x=_x,y=_y,typ=rand(zone.lvl)})
		end
	end
end

function getfreecellfromzone(zone)
	for _i=1,99 do
		local x,y=rand(zone.w+1)+zone.x-1,rand(zone.h+1)+zone.y-1
		if can_go(x,y) and dist(px,py,x,y)>1 then
			return x,y
		end
	end
end

function getfreecellfromzone2(zone,x,y)
	for _i=1,99 do
		local d=rand(4)
		if can_go(x+dirx[d],y+diry[d]) then
			x+=dirx[d]
			y+=diry[d]
		end
	end
	return x,y
end

function zones_intersect(zone, x, y)
	return x >= zone.x and x <= zone.x2 and y >= zone.y and y <= zone.y2
end

function zones_get(x, y)
	for zone in all(zones) do
		if (zones_intersect(zone, x, y)) return zone
	end
end

function zones_respawn_mobs(zone,max_mobs)
	local count = zone.mobs
	for mob in all(mobs) do
		if (zones_intersect(zone, mob.x, mob.y)) count -= 1
	end
	if(count==0)return
	for i = 1, min(count,max_mobs or 999) do
		local x,y=getfreecellfromzone(zone)
		mobs_add(x,y,rand(zone.lvl))
	end
	return true
end

-- random map generator
mapw = 128
maph = 32
mapsize = maph * mapw

function get_xy(id)
	local x = flr(id / maph)
	return x, id - x * maph
end

function get_id(x, y)
	return y + x * maph
end

function mset_id(id, num)
	local x, y = get_xy(id)
	mset(x, y, num)
end

function mget_id(id)
	return mget(get_xy(id))
end

function zone_has_id(k, id)
	for zid in all(zones[k].ids) do
		if(zid == id)return true
	end
end

function rand_zone_side()
	return rand(7) + 3
end

function gen_map()
	local moveDown = true
	local moveRight
	local lastZone
	local x, y = 1, -1
	local w, h = rand_zone_side(), 0

	function place_zone(zone)
		zone.x = x
		zone.y = y
		zone.w = w
		zone.h = h

		zone.ids = {}
		zone.border = {}

		for dx = 0, w do
			for dy = 0, h do
				add(zone.ids, get_id(x + dx, y + dy))
			end
			if moveDown then
				add(zone.border, get_id(x + dx, y + h + 1))
			else
				add(zone.border, get_id(x + dx, y - 1))
			end
		end
	end

	local cities = {}
	local gates = {}
	for zone in all(zones) do
		local needH = rand_zone_side()
		if moveDown then
			local dy = y + h + 2
			if needH >= maph - dy - 1 then
				moveRight = true
			else
				h = needH
				y = dy
			end
		else
			local dy = y - 2
			if needH >= dy then
				moveRight = true
			else
				h = needH
				y = dy - h
			end
		end
		if(lastZone)lastZone.brot=moveRight and 0 or 1
		if moveRight then
			moveDown = not moveDown

			lastZone.border = {}
			for dy = 0, h do
				add(lastZone.border, get_id(x + w + 1, y + dy))
			end

			x += w + 2
			w = rand_zone_side()
			h = lastZone.h+rand(2)
			if not moveDown then
				y=lastZone.y+lastZone.h-h
			end
		end
		--
		place_zone(zone)
		--
		add(cities,zone.nocity and 0 or rnd(zone.ids))
		zone.cityid=cities[#cities]

		if lastZone then
			add(gates, rnd(lastZone.border))
			lastZone.gateid=gates[#gates]
			local _x,_y=get_xy(lastZone.gateid)
			if moveRight then 
				_x+=1
			elseif moveDown then
				_y+=1
			else
				_y-=1
			end
			zone.enterid=get_id(_x,_y)
		end
		--
		moveRight = false
		lastZone = zone
		zone.x2=x+w+1
		zone.y2=y+h+1
	end

	lastZone.border = {}

	for id = 0, mapsize - 1 do
		mset_id(id, 10)
	end

	-- draw zones
	for zone in all(zones) do
		for id in all(zone.ids) do
			mset_id(id, rnd(fillerstl))
		end

		for id in all(gameobjtl) do
			mset_id(rnd(zone.ids),id)
		end

		for id in all(zone.border) do
			mset_id(id, bordertl[zone.brot*5+zone.gate])
		end

	end

	local road = {}
	function place_road(k, id1, id2)
		local x1, y1 = get_xy(id1)
		local x2, y2 = get_xy(id2)

		road[id1] = true
		road[id2] = true
		for _ = 1,99 do
			if x1 ~= x2 then
				local dirX = mid(-1, x2 - x1, 1)
				local nextId = get_id(x1 + dirX, y1)
				if zone_has_id(k, nextId) then
					x1 += dirX
					road[nextId] = true
					goto cont
				end
			end
			if y1 ~= y2 then
				local dirY = mid(-1, y2 - y1, 1)
				local nextId = get_id(x1, y1 + dirY)
				if zone_has_id(k, nextId) then
					y1 += dirY
					road[nextId] = true
				end
			else
				break
			end
			::cont::
		end
	end

	local prev_gate
	for k, id in pairs(cities) do
		local next_gate = gates[k]
		if id > 0 then
			if prev_gate then
				place_road(k, prev_gate, id)
			end
			if next_gate then
				if k>1 then
					local x, y = get_xy(id)
					for i=1,4 do
						if road[get_id(x + dirx[i], y + diry[i])] then
							id=get_id(x + dirx[i], y + diry[i])
						end
					end
				end
				place_road(k, id, next_gate)
			end
		else
			if prev_gate and next_gate then
				place_road(k, prev_gate, next_gate)
			end
		end
		prev_gate = next_gate
	end

	-- draw roads
	for id in pairs(road) do
		local x, y = get_xy(id)
		local up = road[get_id(x, y - 1)] and 8 or 0
		local left = road[get_id(x - 1, y)] and 4 or 0
		local right = road[get_id(x + 1, y)] and 2 or 0
		local down = road[get_id(x, y + 1)] and 1 or 0
		local tileType = bor(bor(bor(up, left), right), down)
		mset_id(id, roadtl[tileType])
	end

	-- draw other
	for id in all(cities) do
		if id>0 then
			local x, y = get_xy(id)
			local c=59
			for j=1,4 do
				if road[get_id(x + dirx[j], y+diry[j])] then 
					c=58+j
				else
					mset(x + dirx[j], y+ diry[j], rnd(hometl)) 
				end
			end
			mset_id(id, c)
		end
	end

	for i=1,#zones-1 do
		local gate = zones[i].gate
		mset_id(zones[i].gateid, gatetl[zones[i].brot*5+gate])
	end

	for id = 0, mapsize - 1 do
		if mget_id(id)==10 then
			local x,y=get_xy(id)
			if(mget(x,y-1)==10 or mget(x,y-1)==26)mset(x,y,26)
		end
	end
end

-->8
-- draws

function draw_game()
	cls()
	camera(cam_x,cam_y)
	map()

	draw_loot()
	draw_dust()

	if(hp>0) draw_player()
	mobs_draw()
	draw_expl()

	for f in all(float) do
		print(f.txt,f.x,f.y,f.c)
	end

	fog_draw()

	if(_upd==upd_aim)spr(84,xf*8,yf*8)
	draw_bulls()

	camera()

	if incity and _upd==update_game then
		print("é",90,4+hpwnd.y,4)
		print("é",90,4+hpwnd.y+sindx,7)
		print("town",98,4+hpwnd.y,7)
	end
end

function draw_bulls()
	for b in all(bulls) do
		spr(83,b.x,b.y)
	end
end

function draw_loot()
	local remap=explode("7,11,12,10,8")
	for l in all(loot) do
		pal(7,remap[l.typ])
		spr(80+t%3,l.x*8,l.y*8)
		pal(7,7)
	end
end

function draw_player()
	if r_mode==0 then
		spr(96+t%2,px*8+ox,py*8+oy,1,1,cf)
	elseif r_mode==2 then
		spr(rot_spr[abs(ox)+1],px*8,py*8,1,1,cf)
	else
		spr(rot_spr[abs(ox)+1],px*8+ox,py*8,1,1,cf)
	end
end

function mobs_draw()
	for m in all(mobs) do
		spr(mobs_spr[m.lvl]+t%2,m.x*8+m.ox,m.y*8+m.oy,1,1,m.cf)
		if m.fire then
			spr(83,px*8+m.xb,py*8+m.yb)
		end
	end
end

function draw_dust()
	for d in all(dust) do
		spr(103-d.c,d.x,d.y)
	end
end

function draw_expl()
	if expl.x then
		spr(111+expl.iter,expl.x*8,expl.y*8)
	end
end

function print_cs(s,y,c)
	print(s,64-#s*2,y*7,c or 7)
end

function draw_mainmenu()
	cls"9"
	for i=0,16 do
		spr(road_decor1[i+1],i*8-od,37)
		spr(road_decor2[i+1],i*8-od,45)
		if(od==7)road_decor1[i],road_decor2[i]=road_decor1[i+1],road_decor2[i+1]
		--spr(4,i*8-od,45)
	end
	od+=1
	if od==8 then 
		od=0
		fd=rand(#filler_decor1)
		road_decor1[17]=filler_decor1[fd]
		road_decor2[17]=filler_decor2[fd]
	end
	spr(97+sindx,60,42)
	spr(192,25,4+sindx,10,4)
	rect(3,3,125,125,7)

	if goreason then
		print_cs(goreason,8)
	else
		print_cs("gently demake v1.0",8,7)
	end

	if goreason then
		local score=st_score+st_gold-st_moves
		if score>st_hiscore then
			st_hiscore=score
			dset(0, score)
		end
		print_cs("your score: "..score,10)
		print_cs("killed: "..st_kills.." enemies",11)
		print_cs("traveled: "..st_moves.." km",12)
		print_cs("earned: "..st_gold.." gold",13)
	else
		print_cs("use é - menu or pickup",11)
		print_cs("and ó - back or fire",12)
	end
	print_cs("high score: "..st_hiscore,9)
	print_cs("press é to start",14,rand(15))
	print_cs(" ó toggle music",15)
	print_cs("(c) targem homework 2020",17)
end

-->8
-- updates

function update_game()
	player_move()
	fog_update()
end


function expl_init(x,y,l)
	sfx"57"
	expl.x,expl.y,expl.typ,expl.iter=x,y,l,0
	_upd=upd_expl
end


function player_move()
	local nx,ny=px,py
	skipai=false
	incity=findcity()

	if hp<=0 then
		expl_init(px,py)
		return
	end

	r_mode=0

	for i=1,4 do
		if(btnp(i-1))then
			pdir=i
			nx=px+dirx[i]
			ny=py+diry[i]
			ox=-dirx[i]*8
			oy=-diry[i]*8
			if(i==1 and not cf)r_mode=1
			if(i==2 and cf)r_mode=1
		end
	end

	if(ox!=0 or oy!=0)_upd=update_pturn

	tle=mget(nx,ny)

	if( ny!=py or nx!=px ) then
		if attack_mobs(nx,ny,1+dmg_up) then
			nx,ny=px,py
			ox=-ox/2
			oy=-oy/2
			relod=false
		else
			if not fget(tle,0) then
				st_moves+=1
				add(dust,{x=px*8,y=py*8,c=3})
				px,py=nx,ny
				sfx"50"
				relod=false
				for l in all(lairs) do
					if st_moves%10==0 and l.c>0 then
						if(zones_respawn_mobs(l.zone,1))l.c-=1
					end
				end
				incity=false
			else
				if r_mode>0 then
					r_mode=2
				else
					ox=-ox/2
					oy=-oy/2
				end
				sfx"55"
				if fget(tle,5) then
					if tle==13 then
						for l in all(lairs) do
							if l.x==nx and l.y==ny then
								del(lairs,l)
								if qtyp==6 then
									qs_doprogress()
									showmsg(qs_getquestlogtext())
								end
							end
						end
					end
					mset(nx,ny,tle+1)
				else
					skipai=true
				end
			end
		end
	end

	if btnp"4" then
		local fl=checkloot()
		if not fl and (tle==35 or tle==36) then
			fl=true
			docamp()
			mset(px,py,37)
		end
		if not fl and tle==63 then
			fl=true
			showwaymark()                     	
		end
		if(not fl)showmenu()
	end
	if(btnp"5")fire()
end

function showwaymark()
	local nearest,name,city=1000
	for city in all(cityinfo) do
		local d=dist(px,py,city.x,city.y)
		if d<nearest then
			nearest=d
			name=city.name
		end
	end
	showtalk({name.." - "..nearest.." km"})
end

function attack_mobs(_x,_y,dmg)
	for m in all(mobs) do
		if m.x==_x and m.y==_y then
			m.hp-=dmg
			addfloat("-"..dmg,m.x*8,m.y*8,8)
			if(m.hp<=0)then
				st_kills+=1
				if m.lvl>=5 then
					qs_doprogress()
					showmsg(qs_getquestlogtext())
					m.lvl=5
				end
				sidequest_mob_killed(m.x, m.y)

				expl_init(m.x,m.y,m.lvl)
				del(mobs,m)
			end
			return true
		end
	end
end

function fire()
	if relod then
		showmsg("gun is reloading")
		return
	end
	local itm=eqp[1]
	if itm and item_type[itm]=="gun" then
		if item_name[itm]=="shotgun" then
			sfx"58"
			for i=-1,1 do
				add(bulls,{x=px*8,y=py*8,sx=dirx[pdir]+diry[pdir]*i,sy=diry[pdir]+dirx[pdir]*i,c=1})
			end
			_upd=upd_bullet
			relod=true
		else
			_upd=upd_aim
			xf,yf=px,py
		end
	else
		showmsg("you have no gun to fire")
	end
end

function upd_aim()
	for i=1,4 do
		if(btnp(i-1))then
			if((i<3 and yf!=py)or(i>2 and xf!=px))then
				xf,yf=px,py
			end
			if dist(px,py,xf+dirx[i],yf+diry[i])<4 then
				xf+=dirx[i]
				yf+=diry[i]
			end
		end
	end
	if(btnp"5")_upd=update_game
	if(btnp"4")then
		sfx"56"
		add(bulls,{x=px*8,y=py*8,sx=xf-px,sy=yf-py,c=1})
		_upd=upd_bullet
		relod=true
	end
end

function upd_bullet()
	for b in all(bulls) do
		b.x+=b.sx
		b.y+=b.sy
		b.c+=1
		if not iswalkable(b.x/8,b.y/8) then
			del(bulls,b)
		elseif b.c==9 then
			del(bulls,b)
			attack_mobs(b.x/8,b.y/8,1+dmg_up2)
		end
	end
	if #bulls==0 then
		if _upd==upd_bullet then
			_upd=update_game
			if(not skipai)mobs_move()
		end
	end
end

function upd_expl()
	expl.iter +=0.5
	ox-=sign(ox)
	oy-=sign(oy)
	if expl.iter==4 and expl.typ then
		add(loot,{x=expl.x,y=expl.y,typ=expl.typ})
	end
	if expl.iter>=7 then
		if expl.typ then
			expl = {}
			_upd=update_game
			if(not skipai)mobs_move()
		else
			showmainmenu("you died")
		end
	end
end

function update_pturn()
	ox-=sign(ox)
	oy-=sign(oy)
	if r_mode>0 and abs(ox)==4 then
		cf = not cf
	end
	if ox==0 and oy==0 then
		_upd=update_game
		if(not skipai)mobs_move()
	end
end

function showsplash()
	t=0
	_upd=updsp
	_drw=drwsp
	cls()
	spr(130,36,32,7,4)
end

function updsp()
end

function drwsp()
	if t>5 then
		cls()
		spr(192,24,32,10,4)
		spr(76,48,72,4,4)
	end
	if t>10 then
		adjustmusic()
		startgame()
		showmainmenu()
	end
end

function showmainmenu(_reason)
	wnd,_upd,_drw={},update_mainmenu,draw_mainmenu
	od=0
	goreason=_reason
	fadeout(0.02)
	_upd=update_mainmenu
	adjustmusic()	
end

function update_mainmenu()
	if(btnp"4")restart()
	if(btnp"5")trigmusic()
end

function mobs_add(_x,_y,_lvl)
	if(not can_go(_x,_y)) return
	add(mobs,{x=_x,y=_y,ox=0,oy=0,lvl=_lvl,hp=mobs_hp[_lvl],cf=false,fire=false,t=0})
end

function mobs_move()
	for m in all(mobs) do
		if m.lvl==6 then
			m.t+=1
			if(m.t%2==0) goto skipmove
		end
		local _d=dist(px,py,m.x,m.y)
		local dx,dy=0,0
		if _d<5 then
			if(m.x!=px)m.cf=m.x>px
			dx=sign(px-m.x)
			dy=sign(py-m.y)
		end

		if _d<4 and _d>1 and
		mobs_wep[m.lvl]==2 and
		(px==m.x or py==m.y) then
			m.xb=(-px+m.x)*8
			m.yb=(-py+m.y)*8
			m.fire=true
			dox=sign(m.xb)
			doy=sign(m.yb)
			local mox,moy = m.x,m.y
			repeat
				mox -= dox
				moy -= doy
				if (not iswalkable(mox,moy))m.fire = false
			until (mox==px and moy==py)

			if m.fire == true then
				sfx"56"
				_upd=mobs_update
				dx,dy=0,0
			end
		end

		if _d==1 then --mob attack
			sfx"56"
			player_attack(mobs_dmg[m.lvl])
			m.ox=4*dx
			m.oy=4*dy
			_upd=mobs_update
			dx,dy=0,0
		end

		if(not can_go(m.x,m.y+dy)) dy=0
		if(dy!=0 or not can_go(m.x+dx,m.y)) dx=0
		if dx!=dy then
			m.x+=dx
			m.y+=dy
			m.ox=-8*dx
			m.oy=-8*dy
			_upd=mobs_update
		end
		::skipmove::
	end
end

function player_attack(dmg)
	hp-=dmg
	addfloat("-"..dmg,px*8,py*8,8)
end

function mobs_update()
	local _mf=true
	for m in all(mobs) do
		if m.fire then
			_mf=false
			m.xb-=-px+m.x
			m.yb-=-py+m.y

			if m.xb==0 and m.yb==0 then
				m.fire=false
				player_attack(mobs_dmg[m.lvl])
			end

		elseif m.ox!=0 or m.oy!=0 then
			m.ox-=sign(m.ox)
			m.oy-=sign(m.oy)
			_mf=false
		end
	end
	if(_mf) _upd=update_game
end
-->8
-- more updates

function fog_init()
	fog={}
	for _x=0,mapw do
		fog[_x]={}
		for _y=0,maph do
			fog[_x][_y]=2
		end
	end
end

function fog_draw()
	for _x=0,mapw do
		for _y=0,maph do
			if (fog[_x][_y]>0) spr(10+fog[_x][_y],_x*8,_y*8)
		end
	end
end

function fog_update()
	for _x=-3,3 do
		for _y=-3,3 do
			local _dist=sqrt(_x*_x+_y*_y)
			local _mx,_my=_x+px,_y+py
			if _mx>=0 and _mx<=mapw and _my>=0 and _my<=maph then
				if _dist<=2.5 then fog[_mx][_my]=0
				elseif _dist<=3.2 and fog[_mx][_my]==2 then fog[_mx][_my]=1
				end
			end
		end
	end
end

function animate_tl()
 if (t-flr(t)>0.1) return
 local _x,_y,spr
 for _x=0,mapw do
  for _y=0,maph do
   spr=mget(_x,_y)
   if (spr==24 and rnd(100)<=2) mset(_x,_y,19)
   if fget(spr,3) then
    if fget(spr,4) then
     repeat
      spr-=1
     until fget(spr,4) or not fget(spr,3)
    end
    spr+=1
    mset(_x,_y,spr)
   end
  end
 end
end

function animate_camera_delta(p,cam)
	local _dist=p*8-cam
	if(_dist<16) return -1
	if (120-_dist<16) return 1
	return 0
end

function animate_camera()
	cam_x+=animate_camera_delta(px,cam_x)
	cam_y+=animate_camera_delta(py,cam_y)
end

function dust_update()
	for d in all(dust) do
		d.c-=0.05
		if (d.c<=0) del(dust,d)
	end
end

function checkloot()
	for p in all(loot) do
		if p.x==px and p.y==py then
			local itm = rand(4) + p.typ - 1
			if add2inv(itm) then
				del(loot,p)
				showmsg("found "..item_name[itm])
				sfx"51"
			else
				showmsg("cargo bay is full")
				sfx"52"
			end
			return true
		end
	end
end

function docamp()
	local z=zones_get(px,py)
	if rnd(3)<2 then
		sfx"53"
		local fg=rand(z.lvl*2)
		gold+=fg
		st_gold+=fg
		showmsg("found "..fg.." gold")
	else
		showmsg("it is a trap!!!")
		sfx"52"
		mobs_add(px-2,py,rand(z.lvl))
		mobs_add(px+2,py,rand(z.lvl))
		skipai=true
	end
end
-->8
--ui

function addwnd(_x,_y,_w,_h,_txt,_cur)
	local w={x=_x, y=_y, w=_w, h=_h, txt=_txt, cur=_cur}
	add(wnd,w)
	if _cur then
		w.parent=curwnd
		curwnd=w
		_upd=update_menu
	end
	if(not(_w and _h)) wnd_adjustwh(w)
	return w
end

function addmenu(_txt,_head,_cur)
	local w={txt=_txt,head=_head,cur=_cur or 1}
	add(wnd,w)

	if curwnd then
		w.x=curwnd.x+6
		w.y=curwnd.y+curwnd.cur*6 + (curwnd.head and 5 or 0)
	else
		w.x,w.y=6,20
	end

	w.parent=curwnd
	curwnd=w
	_upd=update_menu
	wnd_adjustwh(w)
	return w
end

function drawnd()
	for w in all(wnd) do
		local wx,wy,ww,wh=w.x,w.y,w.w,w.h
		rectfill(wx,wy,wx+max(ww-1,0),wy+max(wh-1,0),9)
		rect(wx+1,wy+1,wx+ww-2,wy+wh-2,7)
		wx+=3
		wy+=4
		clip(wx,wy-2,ww-2,wh-6)
		if (w.cur) wx+=6

		if w.head then
			print(w.head,wx+2,wy,4)
			wy+=6

			line(wx-5,wy+1,wx+ww-14,wy+1,4)
			wy+=5
		end

		if w.img then
			spr(w.img,wx,wy,w.isize,w.isize)
		end

		for i=1,#w.txt do
			local dx=0
			if(w.img)dx=8*w.isize
			print(w.txt[i],wx+2+dx,wy,w.col and w.col[i] or 7)
			if i==w.cur then
				local d = w!=curwnd and 0 or sindx
				print("\x8e",wx-6,wy,4)
				print("\x8e",wx-6,wy+d,7)
			end
			wy+=6
		end

		if (w.cur) print("\x97"..(w.parent and "back" or "exit"),wx-6,wy,4)

		clip()

		if w.dur then
			w.dur-=1
			if w.dur<=0 then
				local dif=w.h/4
				w.y+=dif/2
				w.h-=dif
				if (w.h<3) del(wnd,w)
			end
		else
			if w.butt then
				print("\x97",wx+ww-15,wy-2,4)
				print("\x97",wx+ww-15,wy-2+sindx,7)
			end
		end
	end
end

function showmsg(txt,dur)
	local wid=(#txt+2)*4+7
	local w=addwnd(63-wid/2,50,wid,13,{" "..txt})
	w.dur=dur or 45
end

function showtalk(txt)
	talkwnd=addwnd(4,50,nil,nil,txt)
	talkwnd.butt=true
	talkwnd.prev_upd=_upd
	talkwnd.w+=12
	_upd=updtalk
end

function dialog_fill(d)
	talkwnd.txt=d.txt	
	talkwnd.img=d.img
	talkwnd.isize=d.size
	wnd_adjustwh(talkwnd)
end

function showdialog(dlg)
	showtalk({" "})
	talkwnd.d=dlg
	talkwnd.dc=1
	dialog_fill(dlg[1])
end

function updtalk()
	if btnp"4" or btnp"5" then
		if talkwnd.d and talkwnd.dc<#talkwnd.d then
			talkwnd.dc+=1
			dialog_fill(talkwnd.d[talkwnd.dc])
		else
			talkwnd.dur=0
			_upd=talkwnd.prev_upd
		end
	end
end

function addfloat(_txt,_x,_y,_c)
	add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
	for f in all(float) do
		f.y+=(f.ty-f.y)/10
		f.t+=1
		if (f.t>70) del(float,f)
	end
end

function dohpwnd()
	hpwnd.txt[1]="$"..gold.." á"..hp.."/"..hp_max+hp_up.." è"..inv_cur.."/"..inv_max+inv_up
	local hpy=5
	if (py-cam_y/8<8) hpy=110
	hpwnd.y+=(hpy-hpwnd.y)/5
end

--
-- ui - menu system
--
function wnd_adjustwh(wnd)
	local w,h,t=4
	for t in all(wnd.txt) do
		w=max(#t,w)
	end
	h=7+#wnd.txt*6
	if wnd.head then
		w=max(w,#wnd.head)
		h+=11
	end
	if wnd.img then
		w+=2*wnd.isize
	end
	w*=4
	if wnd.cur then
		w+=6
		h+=6
	end
	wnd.w=w+8
	wnd.h=h
end

function closecurwnd()
	curwnd.dur=0
	curwnd=curwnd.parent
	if(not curwnd) _upd=update_game
end

function update_menu()
	if btnp"2" then
		sfx"59"
		curwnd.cur-=1
	elseif btnp"3" then
		sfx"59"
		curwnd.cur+=1
	end
	curwnd.cur=(curwnd.cur-1)%#curwnd.txt+1
	wnd_adjustwh(curwnd)

	local act=curwnd.action
	if btnp"4" then
		if(type(act)=="table") act=act[curwnd.cur]
		if(act) act()
	elseif btnp"5" then
		closecurwnd()
	end
end

--
-- ui - menu tree
--
function showmenu()
	if incity then
		showtown()
	else
		show_um()
	end
end

function show_um()
	umwnd=addmenu(explode("truck,quest log"))
	umwnd.action={showinv,showquestlog}
end

function trigmusic()
	mus_f=not mus_f
	adjustmusic()
end

function restart()
	sfx"51"
	fadeout()
	startgame()
	adjustmusic()
end

function adjustmusic()
	local mus=mus_f and (_upd==update_mainmenu and rnd(musa) or 22) or -1
	menuitem(2,"turn music "..(mus_f and "off" or "on"),trigmusic)
	music(mus,300)
end

function showtown()
	townwnd=addmenu(explode("mayor's office,repair shop,item shop,truck"))
	townwnd.action={showmayoroffice,showrepairshop,showshop,showinv}
	townwnd.head="city: "..cityinfo[findcity()].name
end

function showmayoroffice()
	wndmayor=addmenu({},"hi traveler!")
	cn = findcity()

	wndmayor.action={takemq}
	wndmayor.txt={qs_getcitytext()}

	if(wndmayor.txt[1]) return
	
	for k, v in pairs(sidequest_actived) do
		if v.target_city == cn then
			v.show_wndow(true)
			return
		end
	end

	local quest = sidequest_actived[cn]
	if quest then
		quest.show_wndow()
		return
	end

	local txts, actions = {}, {}
	for k, v in pairs(cityinfo[cn].sidequest) do
		add(txts, v.txt)
		add(actions, v.action)
	end

	if #txts == 0 then
		add(txts,"i have no tasks for you")
	end

	wndmayor.head="i require assistance"
	wndmayor.txt = txts
	wndmayor.action = actions
end

function takemq()
	if qs_doprogress() then

		if not cityinfo[cn].visited then
			local txt1={"hello, i need","a new car to get across","the mountain pass"}
			local txt2={"you look like a good guy.","so i will help, if you"}
			add(txt2,qs_getquestlogtext())
			local dialog={{txt=txt1,img=88,size=2},{txt=txt2,img=90,size=2}}
			showdialog(dialog)
			cityinfo[cn].visited =  true
		else
			showmsg(qs_getquestlogtext())
		end

	end
	sfx"61"
	closecurwnd()
end

function showrepairshop()
	if hp==hp_max+hp_up then
		showmsg("nothing to repair")
		return
	end

	if gold==0 then
		showmsg("you're out of money")
		return
	end

	local m=min(hp_max+hp_up-hp, gold)
	local txt={"repair 1 hp for $1","repair "..m.." hp for $"..m}
	wndrepair=addmenu(txt,"i will repair your car")
	wndrepair.action={function() repair(1) end, function() repair(99) end}
end

function repair(rep)
	rep=min(min(rep,hp_max+hp_up-hp),gold)
	if rep>0 then
		showmsg("car have repaired")
		gold-=rep
		hp+=rep                   	
		sfx"53"
	end
	closecurwnd()
end

function showquestlog(refresh)
	local txts, actions = {}, {}
	add(txts, qs_getquestlogtext())
	add(actions, function() end)

	for k, v in pairs(sidequest_actived) do
		add(txts, cityinfo[k].name .. ": " .. v.show_qlwnd())
		add(actions, function()
			local wnd = addmenu({"cancel"})
			wnd.head = v.show_qlwnd()
			wnd.action = proc_cancel_quest(k,v.qn,true)
		end)
	end

	if #txts == 0 then
		add(txt,"[no active quests]")
		add(col,13)
	end
	if refresh then
		qlwnd.h=7+#txts*6
		qlwnd.txt=txts
	else
		qlwnd=addmenu(txts)
	end
	qlwnd.action=actions
end

function showinv(refresh)
	local txt,col,price,action,none={},{},{},{},explode("no weapon,no armor,no trunk")

	add(txt,"-equipment-")
	add(col,4)
	for i=1,3 do
		if eqp[i] then
			add(txt,item_name[eqp[i]])
			add(col,7)
			action[#txt]=showuse
		else
			add(txt,none[i])
			add(col,13)
		end
	end
	add(txt,"-cargo-")
	add(col,4)

	if #inv==0 then
		add(txt,"empty")
		add(col,13)
	end
	for itm in all(inv) do
		local desc=item_name[itm].." "..amo[itm]
		if incity then
			local _p=cityinfo[findcity()].la[itm]
			desc=dot_in(desc,"$".._p,17)
			add(price,_p)
		end
		add(col,7)
		add(txt,desc)
		action[#txt]=showuse
	end

	if (refresh) then
		invwnd.txt=txt
	else
		invwnd=addmenu(txt)
	end
	invwnd.col=col
	invwnd.price=price
	invwnd.action=action
end

function showshop()
	local txt,prices,items_idx={},{},{}

	for i=1,#item_name do
		local _p=cityinfo[findcity()].lb[i]
			if _p>0 then
				add(txt, dot_in(item_name[i], "$".._p, 17))
				add(prices, _p)
				add(items_idx, i)
			end
	end
	if #txt==0 then
		showmsg("the shop is closed")
		return
	end
	shopwnd=addmenu(txt)
	shopwnd.prices=prices
	shopwnd.items_idx=items_idx
	shopwnd.action=showbuy
end

function showuse()
	local txt={}
	
	if invwnd.cur < 5 then
		add(txt,eqp[invwnd.cur-1] and "remove")
	else
		itm=inv[invwnd.cur-5]
		local typ=item_type[itm]
		if (typ=="body" or typ=="gun" or typ=="bump" or typ=="armor") add(txt,"equip")
		add(txt, incity and "sell" or "drop")
	end
	usewnd=addmenu(txt)
	usewnd.action=triguse
end

function showbuy()
	shopwnd.itemidx=shopwnd.items_idx[shopwnd.cur];
	buywnd=addmenu({"buy"},"buy "..item_name[shopwnd.itemidx].." for $"..shopwnd.prices[shopwnd.cur])
	buywnd.action=trigbuy
end

function triguse()
	local verb, i = usewnd.txt[usewnd.cur], invwnd.cur-5

	local oi=nil

	if verb=="equip" then
		itm=inv[i]
		typ=item_type[itm]
		if typ=="gun" then
			oi=eqp[1]
			eqp[1]=itm
			dmg_up2=item_stat[itm]
			dmg_up=0
		end
		if typ=="bump" then
			oi=eqp[1]
			eqp[1]=itm
			dmg_up=item_stat[itm]
			dmg_up2=0
		end
		if typ=="armor" then
			oi=eqp[2]
			eqp[2]=itm
			hp_up=item_stat[itm]
		end
		if typ=="body" then
			oi=eqp[3]
			eqp[3]=itm
			inv_up=item_stat[itm]
		end
	end

	if verb=="drop" or verb=="sell" or verb=="equip" then
		del2inv(i,1)
		if verb=="sell" then
			gold+=invwnd.price[i]
			st_gold+=invwnd.price[i]
			sfx"53"
		elseif verb=="drop" then
			sfx"54"
		elseif verb=="equip" then
			sfx"51"
			if(oi)add2inv(oi)
		end
	end

	if verb=="remove" then
		local e=invwnd.cur-1
		if inv_cur<inv_max+(e==3 and 0 or inv_up) then
			add2inv(eqp[e])
			sfx"51"			
			eqp[e]=nil
			if(e==1)dmg_up,dmg_up2=0,0
			if(e==2)hp_up,hp=0,min(hp,hp_max)
			if(e==3)inv_up=0
		else
			sfx"52"			
		end
	end

	closecurwnd()

	showinv(true)
	invwnd.cur=i+5
end

function trigbuy()
	local price=shopwnd.prices[shopwnd.cur]
	if gold>=price and price>0 then
		if add2inv(shopwnd.itemidx) then
			gold-=price
			sfx"53"
		else
			sfx"54"
		end
	end
	closecurwnd()
end

-->8
--tools

function rand(x)
	return flr(rnd(x)) + 1
end

function explode(str)
local rv={},v
	while str!="" do
		v,str=cutby(',',str)
		add(rv,tonumsafe(v))
	end
	return rv
end

function tonumsafe(str)
	return tonum(skipspaces(str)) or skipspaces(str)
end

function cutby(symbol,str)
	for i=1,#str do
		if(sub(str,i,i)==symbol) return sub(str,1,i-1),sub(str,i+1)
	end
	return str,""
end

function skipspaces(str)
	for i=1,#str do
		if(sub(str,i,i)>" ") return sub(str,i)
	end
	return("")
end

function parse(text)
	local objname,line
	function cutline()
		line,text=cutby("\n",text)
	end
	while text!="" do
		cutline()
		objname,line=cutby("=",line)
		if objname!="" then
			if line!="" then
				_ENV[objname]=explode(line)
			else
				cutline()
				local arrays,arr,suffix={}
				while line!="" do
					suffix,line=cutby(",",line)
					arr={}
					_ENV[objname..skipspaces(suffix)]=arr
					add(arrays,arr)
				end
				local idx=1
				while true do
					cutline()
					if (line=="") break
					local a=1
					while line!="" do
						val,line=cutby(",",line)
						arrays[a][idx]=tonumsafe(val)
						a+=1
					end
					idx+=1
				end
			end
		end
	end
end

function sign(val)
	return val==0 and 0 or sgn(val)
end

function dot_in(l,r,limit)
	return l..sub("................................",1,limit-#l-#r)..r
end

function dist(x1,y1,x2,y2)
	return abs(x2-x1)+abs(y2-y1)
end

function isfree(x,y)
	for m in all(mobs) do
		if(m.x==x and m.y==y)return
	end
	return true
end

function iswalkable(x,y)
	return not fget(mget(x,y),0)
end

function can_go(x,y)
	if(not x) return
	if(not iswalkable(x,y)) return
	return isfree(x,y)
end

function add2inv(i)
	if (inv_cur>=inv_max+inv_up) return
	inv_cur+=1

	for _i in all(inv) do
 		if _i==i then
 			amo[i]+=1
 			return true
 		end
	end
	add(inv,i)
	amo[i]=1
	return true
end

function del2inv(i,n)
	local itm=inv[i]
	if amo[itm]>n then
 		amo[itm]-=n
 	else
 		del(inv,itm)
	end
	inv_cur-=n
end

function findcity()
	for _i=1,#cityinfo do
		if(cityinfo[_i].x==px and cityinfo[_i].y==py)return _i
	end
end

function dofade()
 p=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+j*1.46)/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

function fadeout(spd)
 spd=spd or 0.04
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
end

-->8
--quest system

function format(str, arg1, arg2)
	for i = 1, #str do
		if sub(str, i, i + 1) == "%s" then
			local result = sub(str, 1, i - 1) .. arg1 .. sub(str, i + 2)
			return arg2 and format(result, arg2) or result
		end
	end
end


function sidequest_mob_killed(x, y)
	local zone = zones_get(x, y)
	if zone then
		for k, v in pairs(sidequest_actived) do
			if v.mob_count and v.zone == zone then
				v.count += 1
			end
		end
	end
end

function proc_take_quest(cn, quest)
	return function()
		sidequest_actived[cn] = quest
		showmsg("quest taken")
		sfx"53"
		closecurwnd()
	end
end

function proc_reward_quest(cn, reward, quest_num)
	return function()
		sidequest_actived[cn] = nil
		cityinfo[cn].sidequest[quest_num] = nil
		gold += reward
		st_gold += reward
		st_score += 20
		showmsg("quest complete")
		sfx"53"
		closecurwnd()
	end
end

function proc_cancel_quest(cn,qn,ql)
	return function()
		sidequest_actived[cn] = nil
		cityinfo[cn].sidequest[qn] = nil
		showmsg("quest canceled")
		closecurwnd()
		if(ql)showquestlog(true)
	end
end

function sideq_init()

	sidequest_actived = {}
	sidequest_generators = {}

	-- kill bandits
	add(sidequest_generators, function(cn, quest_num)
		local zone = cityinfo[cn].zone
		local need_count = rand(zone.mobs)

		local quest = {
			mob_count = true,
			zone = zone,
			count = 0
		}
		local function qt() return format("kill %s bandits", need_count-quest.count) end 
		quest.txt = qt() 
		quest.action = function()
			proc_take_quest(cn, quest)()
			zones_respawn_mobs(zone)
		end
		quest.show_wndow = function()
			if quest.count >= need_count then
				wndmayor.head = "job done, thanks!"
				wndmayor.txt = {"take reward"}
				wndmayor.action = proc_reward_quest(cn, 2*need_count+cn, quest_num)
				return
			end

			wndmayor.head = qt()
			wndmayor.txt = {"cancel"}
			wndmayor.action = proc_cancel_quest(cn,quest_num)
		end
		quest.show_qlwnd = function()
			if (quest.count >= need_count) return "return for reward"
			return qt()
		end
		return quest
	end)

	-- give resource
	add(sidequest_generators, function(cn, quest_num)
		local city = cityinfo[cn]
		local need_count = rand(cn)

		local not_buy_items = {}
		for i = 1, 4 do
			if (city.lb[i] < 1) add(not_buy_items, i)
		end

		local item_num = rnd(not_buy_items)
		if (not item_num) return
		local item_name = item_name[item_num]
		local reward = (city.la[item_num]+4) * need_count

		local function qt() return format("bring us %s %s", need_count, item_name) end 

		local quest = {}
		quest.txt = qt()
		quest.action = function()
			for i, num in pairs(inv) do
				if num == item_num then
					del2inv(i, min(need_count,amo[num]))
					need_count-=amo[num]
					if need_count<=0 then
						proc_reward_quest(cn, reward , quest_num)()
						return
					end
				end
			end
			quest.txt = qt()
			showmsg(qt())
			sfx"53"
			closecurwnd()
		end
		return quest
	end)

	-- send message
	add(sidequest_generators, function(cn, quest_num)
		if(cn==1)return  
		local target_city = rand(cn - 1)
		local target_name = cityinfo[target_city].name
		local qt = format("pack to %s", target_name)

		local quest = {
			target_city = target_city
		}
		quest.txt = "take the "..qt
		quest.action = proc_take_quest(cn, quest)
		quest.show_wndow = function(completed)
			if completed then
				wndmayor.head = "do you have pack for me?"
				wndmayor.txt = {"deliver package"}
				wndmayor.action = proc_reward_quest(cn, cn + 3, quest_num)
				return
			end

			wndmayor.head = qt
			wndmayor.txt = {"cancel"}
			wndmayor.action = proc_cancel_quest(cn,quest_num)
		end
		quest.show_qlwnd = function()
			return qt
		end
		return quest
	end)
end

function sidequest_random(cn)
	local quests, nums = {}, {}
	nums[rand(3)] = true
	nums[rand(3)] = true
	for k in pairs(nums) do
		local quest = sidequest_generators[k](cn, #quests + 1)
		if quest then
			quest.qn=#quests + 1
			add(quests, quest)
		end
	end
	return quests
end

-- main quest sequence

function qs_init()
	main_quest=1
	qs_update()
end

function qs_update()
	qtyp=qs_chain[main_quest].type
	qpar=qs_chain[main_quest].city
	qpar2=qs_chain[main_quest].par2
	qpar3=qs_chain[main_quest].zone
end

function qs_opengate()
	if(qpar3)mset_id(zones[qpar3].gateid,gate2tl[zones[qpar3].brot*5+zones[qpar3].gate])
end

function qs_getquestlogtext()
	if qtyp==2 then
		return format(qs_txt[qtyp][1],mobs_name[qpar2])
	elseif qtyp==4 or qtyp==5 then
		return format(qs_txt[qtyp][1],qpar2,cityinfo[qpar].name)
	elseif qtyp==6 then
		return qs_txt[qtyp][1]
	else
		return format(qs_txt[qtyp][1],cityinfo[qpar].name)
	end
end

function qs_getcitytext()
	if (cn==qpar) return qs_txt[qtyp][2]
end

function qs_doprogress()
	_flag=false
	if qtyp==7 or qtyp==1 then
		if incity and cn==qpar then
			_flag=true
			qs_opengate()
		end
	end
	if qtyp==2 or qtyp==6 then
		_flag=true
	end
	if qtyp==3 then
		if incity and cn==qpar then
			if gold>=20 then
				gold-=20
				qs_opengate()
				_flag=true
			else
				showmsg("you have no $20 yet")
			end
		end
	end
	if qtyp==4 or qtyp==5 then
		if incity and cn==qpar then
			del2invq(qtyp==4 and 3 or 2)
			if _flag then qs_opengate() else showmsg(qs_getquestlogtext()) end 
		end
	end
	if _flag then
		main_quest+=1
		st_score+=100
		qs_update()
		if qtyp==2 then
			local z=zones[qpar3]
			local x,y=getfreecellfromzone2(z,get_xy(z.enterid))
			if(not can_go(x,y)) x,y=getfreecellfromzone(z)
			mobs_add(x,y,qpar2)
		end
		if qtyp==6 then
			local z=zones[qpar3]
			local _x,_y=getfreecellfromzone2(z,get_xy(z.cityid))
			mset(_x,_y,13)
			add(lairs,{x=_x,y=_y,zone=z,c=5})
		end
		if qtyp==99 then
			st_score+=200
			showmainmenu("you win")
			_flag=false
		end
	end
	return _flag
end

function del2invq(itm)
	for i=1,#inv do
		if inv[i]==itm then
			local need=min(amo[inv[i]],qpar2)
			qpar2-=need
			if(qpar2<=0)_flag=true
			del2inv(i,need)
			return
		end
	end
end
__gfx__
0000000099a9a99aaaabbaaaaa5665aaa9994aaaaaa88aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa96060606066666666aaaaaaaaaaaaaaaaaaaaaaaa
00000000aaaaaaaaaab33baaaa5665aaaaaaaaaaaa8778aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99aa4aaa0606060666666666aaa55aaaaaaaaaaaaaaaaaaa
00700700a99a94aaab3333baaa5665aa55555555aa7777aaaaa44aaaaaa44aaaaaa44aaaaaaaaaaaaaa494aa6060606066666666aa5dd5aaaaaaaaaaaaaaaaaa
00077000aaaaaaaab333333baa5665aa66666666aa7777aaaa4774aaaa4774aaaa4774aaaaaaaaaaaa4944aa0606060666666666a5dddd5aaa55d5aaaaaaaaaa
000770009a9994aab333333baa5665aa66666666aa7ee7aaa477774aa477774aa477774aaaaa9a9aa494444a6060606066666666ad5555daa55d55daaaa55aaa
00700700aaaaaaaabb3333bbaa5665aa55555555aa7777aaaa7bb7aaaa7667aaaa7cc7aaaaaaaaaa494aa4440606060666666666a556655aa5556555a55d655a
00000000aa9a994aabb44bbaaa5665aaaa9a994aaa777799aa7777aaaa7777aaaa7777aaaaaaaaaa94a44a446060606066666666ad5555daad5555da5d5555d5
00000000aaaaaaaaaaa44aaaaa5665aaaaaaaaaaaaaaaaaaaaaaa999aaaaa999aaaaa999aaaaaaaa4a4994a40606060666666666aaaaa999aaaaa999aaaaa999
aaaaaaaaaaaaaaaaaaaaaaaab3ababbab3ababbab3ababbab3ababbab3aaaaaab3ababbac3acaccaa494444aa456654aaa6666aaaa6666aaaa6666aaaa6666aa
999aaaaaaaaaaaaaaaaa999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaac7c7caaaaaaaaaaaaaaaa4944444a6656656666cccc6666cccc6666cccc6666cccc66
aaaaaad55555555555daaaaaabbab3aaabbab3aaabbab3aaaaacacaaabaacccaabbab3aaaccac3aa444494aacc5665cccc6cccccccc66cccccccc6cccccccccc
aaaa5d66666666666665aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa7ccc7aaaaaaaaaaaaaaaaaaaaaaaaaa44949aacc5665ccc6ccc6cccccccccccccccc6c6ccc6cc6
aaa566666666666666665aaaba3bb3aabaaaa3aabac7c7cabacaaacaba3bb3aaba3bb3aaca3cc3aaaa94449acc5665cccccccc6c6cccccc6c66cccccccc6cccc
aad666d5556666555d66daaaaaaaaaaaaacacaaaaaacccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa94aa449cc5665cccccc66cccccc66cccccc66cccccc66cc
aa566daaaa5665aaaad66daaac7c7caaa7ccc73aaaaaaaaaaababb3aaababb3aaababb3aaacacc3a94a44a44665665666666aa666666aa666666aa666666aa66
aa5665aaaa5665aaaa5665aaaacccaaaacaaacaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4994aaa456654a9aaa9aaa9aaa9aaa9aaa9aaa9aaa9aaa
aa5665aaaa5665aaaa5665aaaaa77aaaaa47aaaaaaaaaaaaaa5665aaaa5665aaaa5555aaa5d55d5aa6cccc6aa494444aa494444aaa5665a9aa5665a9aaaaaa9a
aa5665aaaa5665aaaa5665aaaaaa7aaaaaaa7aaaaaaaaaaa5a5665a5a555555aa5d55d5aa555555a44c44c444944444a4944444a995665aa995665aaaa666aaa
aa56665555666655556665aaa4a9aaaaaaa77aaaaaaaaaaa5a5665a555d55d5555d55d5555555555555555555444545555555555aa5495aaaa5665aaa6c7c6aa
aa56666666666666666665aaaaeaaaaaaa799aaaaaaaaaaa5a5665a55dd55dd56555555666666666666666666449496666666666a449454aa456654a8677768a
aa56666666666666666665aaaa99aaaaaaae9aaaaaaaaaaa5a5665a555d5d5d56555555666666666666666666694449666666666a454444aa456654aa67c76aa
aa56665555666655556665aaaa4f4aaaaa494aaaaa4a4aaa5a5665a55dd55dd555d55d5555555555555555555945544555555555494aa44449566544aa666aaa
aa5665aaaa5665aaaa5665aaa454a4aaa454a4aaa454a4aa5a5665a555555555a5d55d5aaaaaaaaa464cc46494a44a4494a44a4494a44a4494566544988a88a9
aa5665aaaa5665aaaa5665aaaaaaaaaaaaaaaaaaaaaaaaaaaa5665aaaa5665aaa555555aa555555aa64cc46aaa4994aaaa4994aa4a5995a44a5665a4aaaaaaaa
aa5665aaaa5665aaaa5665aaaaaaa999aaaaa999aaaaa999aaaaa99996cccc6a96c6cc6a96cccc6a96cc6c6aaaaaaaaaaaaaaaaaaa5665aaaaaaaaaacccccccc
aad66daaaa5665aaaad665aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa6cc6c6aa6cccc6aa6c6cc6aa6cccc6aaa5555a9aa5555a9aa5665a9aa5555a9c7676c7c
aaad66d5556666555d666daaa4a4a4a4aaaaaaaaaaaaaaaaaaaaaaaaa6ccc6c6a6ccccc6a6c6ccc6a6ccccc65566665aa5666655a566665aa566665acccccccc
aaa566666666666666665aaa49494949aa4a4a4aaaaaaaaaaaaaaaaaa6ccccc6a6ccc6c6a6ccccc6a6c6ccc666665d5aa5d56666a5d5665aa5d5665ac766c77c
aaaa56666666666666d5aaaa5454545454444444aa4a4a4aaaaaaaaa9a6cccc69a6cc6c69a6cccc69a6c6cc666d5665aa5665d66a5665d5aa5665d5acccccccc
aaaaad55555555555daaaaaaa4a4a4a4a4a4a4a454545454aaaaaaa4aa6c6cc6aa6cccc6aa6cc6c6aa6cccc65566665aa5666655a566665aa566665aaa5aa5aa
999aaaaaaaaaaaaaaaaaa9995454545454545454545454545aaaaaa4a6c6cc6aa6cccc6aa6cc6c6aa6cccc6aaa5555aaaa5555aaaa5555aaaa5665aaaa5aa5aa
aaaaaaaaaaaaaaaaaaaaaaaaa4a494944a4a49494a4a494945aa4949a6cccc6aa6c6cc6aa6cccc6aa6cc6c6aaaaaaa99aaaaaa99aaaaaa99aa566599aa5aa5aa
000000000000000000000000000000000000000000000000004444000000000000333300000000000000500000000000000000000000000000000b0000000000
0000000000000000005000000000000000044440000000000554450000444400003883330033330004445550000050000000000000000000000bbbbbb0000000
000444000000000005555000005000000004cc44000444400044440000544550003333000038833304cc45000444555000000000000000000bbbaabbbbbb0000
0004cc40000444004444000005555000999444440004cc44040000400044440003333330003333009444444404cc4500000000000000000bbaabbbbaabbbbbb0
444444440004cc404cc444c0444400004444444c99944444404004040400004035555553033333304444444c944444440000000000040baabbbbaabbbbaab330
45444454454444544144414041c441c0454444544544445c40400404404004045151515531515153414444144144441c000000000499999bbaabbbbaabb35330
565005655654456516101610161416105650056556544565404004044040040455151515551515151610016116144161000000049999999999bbaabbb5335330
050000500500005001000100010001000500005005000050444004444440044405555550055555500100001001000010000000999999999999a44bb335335330
0000000000000000000000000000000000000000000000000000000000000000000000115f00000000000011fff000000000012229999999a445415335335334
0000000000000000000000000000000000088000000000000000000000000000000001115ff000000000012145f0000000000555522299a44556415335335444
000000000000000000000000000000000008800000000000000000000000000000001115555f000000001114555f0000000015d5d55522255676415335344444
0000000000000000000000000009a000088008800000000000000000000000000000111555550000000011155555000000005d5d5dd555576776415334444444
065565500565565005565560000aa00008800880000000000000000000000000000011ddd611000000001ddddd55f000220155d5d5ddddd76776415444444444
0547746005477450064774500000000000088000000000000000000000000000000115755157f000000dddddddd55f0022255d5d5dd5dd766776454444444444
05444450064444600544445000000000000880000000000000000000000000000011155d71555f0000005176116555000024d5d5d5dddd767766454449441544
06555550055555500555556000000000000000000000000000000000000000000011111d7111550000005576666655000049499ddddddd767764454444115554
00044400000000000000000000000000006000000000000000006006000000000001ddddd666500000005576667655000494999999ddd7667444454494551550
3334ff00000444000044400004444400060600000060660000000000000000000000dddd6665000000000555666600004949999999949762944545444151d550
3334ff003334ff00334ff00034fff4300060660000000006060000060000000000000ddddd6500000000056666600000559999999949a42294544544415dd650
333444443334ff00334ff00034fff43000060060006000000000000000000000000015d665510000000006676660000066555999949a49422444454441556550
4444444f33344444334444403444443006060060000000060000000000000000000115dddd11d000000011666d5ff000d651555549a494444444454441555500
454444544544445f5444f4f004f4f40060606600060000060600000000000000000111555555d00000111ddddd55fff0dd515155555944944154454001155000
5650056556544565654565400444440060600000060066000000000000000000011111111111ddd001111ddddd555fff5551515d665544411555400000000000
050000500500005050505050050005000600000000000000000060060000000011111ddd1ddddddd1111ddddd555555f6551515dd65449455155400000000000
00000000000000000000808805505550000000050000500000000000000000000000000000000000000000000000000006655155dd5544151d55000000000000
000000008008800885850a855050008005005000000000000000000000000000000000000000000000000000000000000006665555544415dd65000000000000
00000000008aa8008880088085500000000000000500000000000000000000000000000000000000000000000000000000000066655564155655000000000000
000a000008a77a800505505005055055050505000005050000000000000000000000000000000000000000000000000000000000066661155550000000000000
0aa7a00008a77a8005a5505805055050000550000000000000000000000000000000000000000000000000000000000000000000000000115500000000000000
00777a00008a880008800a0050055005005000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa000800880088055008050850085000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000080005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000005700000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000677d0000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000005777770000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000067777776000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000077777777500000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000006077777777700000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007077777777600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000060000505577777777500000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000d77500670d77777777000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000001777760775677777776000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000007777770777777777775000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000777777d677777777770776500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005777777777777777750777777500000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000777777777777777755777776000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000067777777777777777d777760000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000057777777777777777777770d600000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000770777777777777777777770d7710000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000d7607777777777776777770d77700000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000d7d07777d7777771777700777000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000050577d5777776077700d7d0000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000d750d77775077000d000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000005000d77700650000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000777607760776000776077607600760077600776076007607760776000000000000000000000000000000000000000000000000000000000
00000000000000000076067760767607600076007767760760006776077677607600760000000000000000000000000000000000000000000000000000000000
00000000000000000076076760776007600077607777760760007676076767607760776000000000000000000000000000000000000000000000000000000000
00000000000000000076077760777607676076007676760767607776076007607600076000000000000000000000000000000000000000000000000000000000
00000000000000000076076760767600776077607600760077607676076007607760776000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000766666666000000000000000000000000000000000000000000000000000000000dddd0000000000000000000000000000000000000000000000000
0000007776666666666dd00000000000000000000000000000000000000000000000000000dddddd000000000000000000000000000000000000000000000000
00000776666ddddd66666d00ddddddddddddddddddddddddddddddddddddddddddddddddddd55dddd00000000000000000000000000000000000000000000000
00007766ddd00000000666ddddddddddddddddddddddddddddddddddddddddddddddddddddd500ddd00000000000000000000000000000000000000000000000
00077666d00000000000666d7777777777777777777777777777777777777777777777777ddd006dd00000000000000000000000000000000000000000000000
00776666d00000000000066666666666666666666666666666666666666666666666666666ddd6dd500000000000000000000000000000000000000000000000
0776d066d00000000000066666666666666666666666666666666666666666666666666666ddddd5000000000000000000000000000000000000000000000000
0766d0777777777000007776666d006d00666d006666d00066d066d06d06d006d0066d00666ddd50000000000000000000000000000000000000000000000000
0666d0777777777d000777d6666d006d0066d000666d00000d006d00d006d006d006d0006666dd00000000000000000000000000000000000000000000000000
066d0077ddddd77700777dd6666d006d0066d000666d00700d006d00d006d006d066d0006666dd00000000000000000000000000000000000000000000000000
666d0077d0000077d777dd0666d000d00066d00066d0077d0d006d00d006d006d066d0006666dd00000000000000000000000000000000000000000000000000
666d00777777d007777dd00666d000d0006d000066d0076d0d006d00d00d0006d066d0006666dd00000000000000000000000000000000000000000000000000
666d00777777d00777dd000666d000d0006d007066d006666d006d00d00d0006d06d00706666dd00000000000000000000000000000000000000000000000000
666d0077ddddd00777d0000666d00000006d00600d0066666d000000d00d0000d06d00600666dd00000000000000000000000000000000000000000000000000
066d0077d0000077777d000666d00000006d07600d0066666d000000d00d0700006d07600666dd00000000000000000000000000000000000000000000000000
066d0077d0000777d777d00666d07007006d00000d0066d06d07d000d00d070000d000000666dd00000000000000000000000000000000000000000000000000
066777777777777dd0777d066d00600600d000000d0066d0d006d006d00d076d00d000000666dd00000000000000000000000000000000000000000000000000
06666677777777dd000777d66d00600600d000000d000d00d006d00d006d066d00d000000666dd00000000000000000000000000000000000000000000000000
0066d0ddddddddd0000077766d00600600d006d006d00000d006d00d00d0066d00d066d00666dd00000000000000000000000000000000000000000000000000
00666d0000000000000007766d00606600d006d006d00006d006d00d00d0066d00d066d00666dd00000000000000000000000000000000000000000000000000
000666d000000000000007666666666666666666666666666666666666666666666666666666dd00000000000000000000000000000000000000000000000000
0000666d00000000000077666666666666666666666666666666666666666666666666666666dd00000000000000000000000000000000000000000000000000
00000666d0000000077776ddddddddddddddddddd7ddd7dd777dd7dd7dd777dddddddddddddddd00000000000000000000000000000000000000000000000000
00000066666007777766660dddddddddddddddddd77d77ddd7ddd7dd7ddd7dddddddddddddddd000000000000000000000000000000000000000000000000000
0000000666666666666ddd00000000000000000007d7d7d007d0077d7d007d000000000000000000000000000000000000000000000000000000000000000000
00000000066666ddddd00000000000000000000007d007d007d007d77d007d000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000007d007d007d007d07d007d000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000007d007d0777d07d07d0777d00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000010000010101010001000021080000000008080808080000010009090919000000281800000101000001000100000000002108080009090919000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010e00001023510231102301123511231112301023510231102301123511231112311623017200162301720010235102311023011235112311123010235102311023011235112311123116230172001723017200
010e00001863018635006030060300603006030060300603186030060300603186030060300603006031860318630186350060300603006030060300603186031860300603186031860300603186031863018635
010e0000040320403204032040320403204032040320403204032040320403204032050320503204032040320403204032040320403204032040320403204032040320403204032040320a0320a0320b0320b032
010e00001863018635186000060000600006000060000600006000060000600006000060000600006000060018630186350060000600186001860018600186001860000600186431860018630186351863518645
010e00000c0630c0630c0000c063246350c0000c0630c0630c0000c0630c0630c000246350c000246250c0000c0630c0630c0000c063246350c0000c0630c0630c0000c0630c0630c000246350c0632462524635
010e0000044350443504435044350443504435044350443504435044350443504435054350543504430044350443504435044350443504435044350443504435044350443504435044350a4350a4350b4300b435
010e00000c0630c0630c0000c063246350c0000c0630c0630c0000c0630c0630c000246350c000246350c0000c0630c0630c0000c063246350c0000c0630c0630c0000c0630c0630c00024635246352463524635
010e00000c0630c0630c0000c063246350c0000c0630c0630c0000c0630c0630c000246350c063246250c0000c0630c0630c0000c063246350c0000c0630c0630c0000c0630c0630c000246350c0632462524635
010e00000443504435044350443504435044350443504435044350443504435044350543505435044300443504435044350443504435044350443504435044350443504435044350443502435024350443004435
010e00002341123412234122341223412234122341223412234122341221411214122141221412214122141223411234122341223412234122341223412234122341223412244112441224412244122441224412
010e0000234122341223412234122341223412234122341223412234122141121412214122141221412214121c4111c4121c4121c4121c4121c4121c4121c4121c4121c4121c4121c4121c4121c4121c4121c412
010e00001023510231102301123511231112301023510231102301123511231112311623017200162301720010235102311023011235112311123010235102311023011235102311023210232102321023210235
01100000152551524518255182451c2551c245152551524518255182451c2551c245152551524518255182451c2551c245152551524518255182451c2551c245152551524518255182451c2551c2451525515245
01100000132551324517255172451a2551a245132551324517255172451a2551a245132551324517255172451a2551a245132551324517255172451a2551a245132551324517255172451a2551a2451325513245
011000001125511245152551524518255182451125511245152551524518255182451125511245152551524518255182451125511245152551524518255182451125511245152551524518255182451a2551a245
01100000132551324517255172451a2551a245132551324517255172451a2551a245132551324517255172451c2551c245132551324517255172451a2551a2451325513245172551724518255182451725517245
011000001d6001d60000000130001d600000001d6001d6000000000000000000000000000000001d6001d6001d6331d63300003130531d63300003130531d633130531d63313000130531d653130001d6531d653
01100000072550724507255072450725507245072550724507255072450725507245072550724507255072450c2550c2450c2550c2450c2550c2450c2550c2450e2550e2450e2550e2450e2550e2450e2550e245
011000000c05300003000030c0531d65300003130000000313000130000c0000c0531d6531d6000c053000030c05300003000030c0531d65300003130000000313000130000c0530c0531d6531d6000c05313000
011000000925509245092550924509255092450925509245092550924509255092450925509245092550924509255092450925509245092550924509255092450925509245092550924509255092450925509245
011000000725507245072550724507255072450725507245072550724507255072450725507245072550724507255072450725507245072550724507255072450725507245072550724507255072450725507245
011000000525505245052550524505255052450525505245052550524505255052450525505245052550524505255052450525505245052550524505255052450525505245052550524505255052450525505245
011000000c05300003000030c0531d65300003130000000313000130000c0530c0531d6531d6000c053000030c0530c053000030c0531d6530c0530c0530c0000c0530c0530c0000c0531d6530c0531d6531d653
010700001c00000000000001a000000001f0001a0001a0001c00000000000001f000000001f0001a0001c000150001c0000000000000150000000015000150001500000000150001500013050130501305013050
010700000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050013550135501355013550
010e00001c0501c050210151a000211451f0001a0501a0501a050000001f0501f050211451f0001c0501c050210151c000210151a000211450000021015150002101500000210151a000211451a0001505015050
010e00000915009150091500915009150091500914009140091400914009140091400913009130091300913009130091300913009120091200912009120091200912009120091100911009110091100715007150
010e00000c1500c1500c1500c1500c1400c1400c1400c1400c1300c1300c1300c1300c1200c1200c1200c1200c1200c1200c1200c1200c1200c1100c1100c1100c1100c1100c1100c1100c1100c1100c1500c150
010e00000b1500b1500b1500b1500b1500b1500b1500b1500b1400b1400b1400b1400b1400b1400b1400b1400b1300b1300b1300b1300b1300b1300b1300b1300b1200b1200b1200b1200c1500c1500b1500b150
010e00001c2301c2201c2201c2101c2101c2101a2301a2201a2201a2101f2301f2201f2201f2101c2301c2301c2301c2201c2201c2201c2101c2101c2101c2101c2101c2101c2101c2101c2101c2101523015230
010e0000180631c0031800300003180031800300003000031865318003186230000318613000030000300003180631c0031c003000030000318003180631a0031865318003186231800318063186001a0631a063
010e0000180630000010000000000000010000100001000018653000001862300000186131000010000000001f063000001c0630000018600100001f063000001865300000186230000018063100001806300000
010e00000c1500c1500c1500c1400c1400c1400c1400c1300c1300c1300c1200c1200c1200c1100c1500c1500b1500b1500b1500b1500b1500b1400b1400b1400b1300b1300b1200b1200c1500c1500b1500b150
010e00001f2301f2201f2201f2101f2101f2101d2301d2301d2201d2201c2301c2301c2201c2201a2301a2301a2301a2201a2201a2201a2101a2101a2101a2101a2101a2101a2101a21018230182301723017230
010e000018063000000000000000000000000000000000001865300000186230000018613000001f063000001a06300000100000000000000000000000000000186530000018623000001f063100001a06300000
011c0000091500915009150091400914009140091300913009130091200912009120091100911009110091100c1000c1000010000100001000010000100001000010000100001000010000100001000010000100
011c0000152301523015230152201522015220152101521015210152101521015210152101521015210152100c0000c0000000000000000000000000000000000000000000000000000000000000000000000000
010e00001806300003000030000300003000030000300003186530000318623000031861300003000030000318063000031806300003000030000318063000031865300003116330000318063180631806300003
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
000100001314013110130001300013000130001a10011000121001210012100121001210012100106000260000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001455017550115501355015550145501155000000000000000000000000000000000000000000700014000000000000000000000000000000000000000000000000000000000000000000000000000000
000f000019340113400c0001d0001d0001d0001d0001c0001c0001c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000305502a5502f5501640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001e1501915015150121500f1500c1500d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003b6202f620216201c62017620116200b62006620036200162000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000366202f620216201c620176201162034620276201c62016620116200d620356202e620276201f6201c620166202f6201f6201a6201562011620116201060000000000000000000000000000000000000
000300003d6303d6303963036630306302a630236301a6301763013630106300d6300a63008630066300563004630036200362002620026100161001610016100160001600000000000000000000000000000000
000200003963035630306302863024630216301f6301d6301b6301963015630116300e6300b6303a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000145201a520015000150001500015000150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600001e750227502475025750257502575023750207501d7501875012750097500c75011740197401e7302373024730287202b7202e72031710317102f7102b7001a700167001d50021300203000000000000
000f00000d250122500d250142500f200162000f20017200317001210017100241002410029100291002a1002a1002a1000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00 01 43 02
00 00 03 43 02
01 00 04 05 02
00 00 06 05 02
00 00 04 05 02
00 00 06 05 02
01 02 07 08 09
00 02 07 08 0a
00 02 07 08 09
00 02 06 08 0a
00 00 04 05 02
00 0b 04 05 02
00 00 04 05 02
02 00 06 05 02
01 0c 42 43 44
00 0d 42 43 44
00 0e 42 43 44
00 0f 10 11 44
01 0c 12 13 44
00 0d 12 14 44
00 0e 12 15 44
02 0f 16 14 44
00 17 18 43 44
00 19 1a 43 44
00 19 1a 43 44
00 19 1b 43 44
00 19 1c 43 44
00 19 1a 43 44
01 19 1a 1d 1e
00 19 1a 1d 1f
00 19 20 21 22
02 19 23 24 25
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
