pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--iii demake by carson kompon

function _init()
	music(0)
	init_menu()
end

function _update60()
	if(gamestate==0) update_menu()
	if(gamestate==1) update_game()
end

function _draw()
	cls()
	palt(0,false)
	palt(10,true)
	if(gamestate==0) draw_menu()
	if(gamestate==1) draw_game()
end
-->8
--player controller
function init_player()
	spawnx=34*8+4
	spawny=27*8
	ply={
	x=spawnx,y=spawny,hs=0,vs=0,
	fric=0.25,spd=1,jump=-3.25,ldir=0,
	wallgrab=false,jumped=false,swapped=false,flp=false,
	lanim=0,
	box={0,0,7,7}
	}
	dead=false
	gravity=0.25
	dimension=0
	lastdim=1
	eyes=1
	walljump=false
	doublejump=false
	jumps=1
	cancheck=false
	cantalk=false
	itemget=0
	itemgot=0
	itemtxt=""
	shinew=0
	itemjewel=0
	itemflower=0
	itempresent=0
	init_dialog()
end

function update_player()
	--player movement
		if btn(‘) and not dead then
			if(ply.hs < ply.spd) ply.hs += ply.fric
		elseif btn(‹) and not dead then
			if(ply.hs > -ply.spd) ply.hs -= ply.fric
		else
			if(ply.hs != 0) ply.hs -= ply.fric*sgn(ply.hs)
		end
	
	ply.flp = get_flip()
	
	if ply.wallgrab and ply.vs > 0 then
		if ply.vs < 1 then
			ply.vs += gravity/4
		else
			ply.vs -= ply.fric
		end
	else
		ply.vs += gravity
	end
	
	--jumping
	if not dead and btnp(Ž) and not ply.jumped then
		if on_ground(ply) then
			jumps=1
			if(doublejump)jumps=2
			player_jump(false)
		elseif ply.wallgrab then
			if doublejump then jumps=2
			else jumps=1 end
			player_jump(false)
			ply.hs = ply.spd*-ply.ldir
		elseif jumps > 0 then
			player_jump(true)
		end
	end
	
	if ply.jumped and not btn(Ž) and ply.vs < 0 and ply.vs >= ply.jump then
		ply.vs *= ply.fric
	end
	
	ply.jumped = btn(Ž)
	
	ply.wallgrab=false
	
	--dimension swapping
	if btnp(ƒ) and not ply.swapped then
		if eyes>1 then
			btnprompt=0
			ply.vs-=gravity*sign(ply.vs)
			ply.hs-=ply.fric*sign(ply.hs)
			sfx(8,2)
			screenshake(3,0.1)
			for p in all(plats) do
				p.check=true
			end
			if dimension==0 then
				if eyes>1 then
					lastdim = dimension
					dimension = 1
				elseif eyes==3 then
					lastdim = dimension
					dimension = 2
				end
			elseif dimension==1 then
				if lastdim==0 then
					if eyes==3 then
						lastdim = dimension
						dimension=2
					else
						lastdim = dimension
						dimension=0
					end
				else
					lastdim=dimension
					dimension=0
				end
			elseif dimension==2 then
				if eyes>1 then
					lastdim=dimension
					dimension=1
				else
					lastdim=dimension
					dimension=0
				end
			end
		end
	end
	ply.swapped = btn(ƒ)
	
	--player collision
	player_col()
	
	local wasgrounded = on_ground(ply)
	
	--update position
	ply.x+=ply.hs
	ply.y+=ply.vs
	
	if not wasgrounded and on_ground(ply) then
		sfx(10,3)
		jumps=1
		if(doublejump)jumps=2
	end
end

--map collision
function player_col()
	--horizontal collision check
	while cmap(ply,ply.x+ply.hs,ply.y) do
		if(walljump) ply.wallgrab=true
		ply.ldir=sgn(ply.hs)
		ply.hs-=ply.fric*sgn(ply.hs)
	end
	--vertical collision check
	while cmap(ply,ply.x,ply.y+ply.vs) do
		ply.vs-=gravity*sgn(ply.vs)
	end
	--angled collision check
	if cmap(ply,ply.x+ply.hs,ply.y+ply.vs) then
		ply.hs = 0
		ply.vs = 0
	end
end

function player_jump(dbl)
	ply.vs = ply.jump
	if dbl then
		jumps=0
		ply.vs/=1.25
	else
		jumps-=1
	end
	sfx(9,3)
end

function on_ground(o)
	local mapcol = cmap(o,o.x,o.y+1)
	if(mapcol) return true
	for p in all(plats) do
		if(plat_coll(o,o.x,o.y+1,p)) return true
	end
	return false
end

function draw_player(x,y)
	if dead then
		pal(2,5)
		draw_ply_spr(26,x,y,ply.flp)
		pal(2,2)
	elseif not on_ground(ply) then
		local sp = 10
		if ply.vs > 0 then
			sp = 11
			if(ply.wallgrab) sp=12
		end
		ply.lanim = sp
		draw_ply_spr(sp,x,y,ply.flp)
	elseif abs(ply.hs) > 0 then
		ply_anim(ply,6,4,5,ply.flp,x,y)
	else
		ply_anim(ply,1,5,3,ply.flp,x,y)
	end
end

function kill_player()
	if not dead then
		sfx(27,3)
		sfx(17,2)
		dead=true
	end
end

function draw_ply_spr(sp,x,y,flp)
	pal(0,5)
	pal(13,5)
	pal(6,5)
	for i=-1,1 do
		for j=-1,1 do
			if not(i==0 and j==0) then
				spr(sp,x+i,y+j,1,1,flp)
			end
		end
	end
	pal(0,0)
	pal(6,6)
	if eyes < 2 then pal(13,0)
	else pal(13,13) end
	if eyes < 3 then pal(2,0)
	else pal(2,2) end
	spr(sp,x,y,1,1,flp)
	pal()
	palt(0,false)
	palt(10,true)
end

--object, start frame,
--num frames, speed, flip
function ply_anim(o,sf,nf,sp,fl,x,y)
	if o.lanim ~= sf then
		o.a_ct=0
		o.a_st=0
		o.lanim=sf
	end
	
	o.a_ct+=1
	
	if(o.a_ct%(30/sp)==0) then
		o.a_st+=1
		if(o.a_st==nf) o.a_st=0
	end
	
	o.a_fr=sf+o.a_st
	draw_ply_spr(o.a_fr,x,y,fl)
end

function get_flip()
	if ply.hs > 0 then
		return false
	elseif ply.hs < 0 then
		return true
	else
		return ply.flp
	end
end
-->8
--useful functions

--collision box
function abs_box(s)
	local box = {}
	box[1] = s.box[1] + s.x
	box[2] = s.box[2] + s.y
	box[3] = s.box[3] + s.x
	box[4] = s.box[4] + s.y
	return box
end

--collision box
function abs_box_xy(s,x,y)
	local box = {}
	box[1] = s.box[1] + x
	box[2] = s.box[2] + y
	box[3] = s.box[3] + x
	box[4] = s.box[4] + y
	return box
end

--object collision
function coll(a,b)
	local box_a = abs_box(a)
	local box_b = abs_box(b)
	
	if box_a[1] > box_b[3] or
	   box_a[2] > box_b[4] or
	   box_b[1] > box_a[3] or
	   box_b[2] > box_a[4] then
	   return false
	end
	
	return true
end

--map collision
function cmap(o,x,y)
	local ct=false
	
	-- if colliding with map tiles
	local x1=(x+o.box[1])/8
	local y1=(y+o.box[2])/8
	local x2=(x+o.box[3])/8
	local y2=(y+o.box[4])/8
	local a=fget(mget(x1,y1),0)
	local b=fget(mget(x1,y2),0)
	local c=fget(mget(x2,y2),0)
	local d=fget(mget(x2,y1),0)
	ct=a or b or c or d
	
	if(not ct)return cplatbox(x1,y1,x2,y2,x,y)
	
	return ct
end

function cplat(o,x,y,ignore,pid)
	local ig = ignore or false
	local ct=false
	
	-- if colliding with platform
	local x1=(x+o.box[1])/8
	local y1=(y+o.box[2])/8
	local x2=(x+o.box[3])/8
	local y2=(y+o.box[4])/8
	
	local a = plat_get(x1,y1,ig)
	local b = plat_get(x1,y2,ig)
	local c = plat_get(x2,y2,ig)
	local d = plat_get(x2,y1,ig)
	
	if pid then
		a = plat_get(x1,y1,ig,pid)
		b = plat_get(x1,y2,ig,pid)
		c = plat_get(x2,y2,ig,pid)
		d = plat_get(x2,y1,ig,pid)
	end
	
	ct=a or b or c or d
	
	return ct
end

function cplatbox(x1,y1,x2,y2,x,y)
	local ct=false
	
	-- if colliding with platform
	local a = plat_get_box(x1,y1)
	local b = plat_get_box(x1,y2)
	local c = plat_get_box(x2,y2)
	local d = plat_get_box(x2,y1)
	
	ct=a or b or c or d
	
	return ct
end

function round(x)
	local n = x - flr(x)
	if(n >= 0.5) return ceil(x)
	return flr(x)
end

--screenshake
function screenshake(am,dc)
	shake=am
	shakedec=dc
end

--linear interpolation
function lerp(pos,tar,perc)
 return pos+((tar-pos)*perc)
end

--outlined text
function outline_print(s,x,y,c1,c2)
	for i=-1,1 do
	 for j=-1,1 do
	  if not(i==0 and j==0) then
	   print(s,x+i,y+j,c1)
	  end
	 end
	end
	print(s,x,y,c2)
end

--object, start frame,
--num frames, speed, flip
function anim(o,sf,nf,sp,fl,x,y)
	if o.lanim ~= sf then
		o.a_ct=0
		o.a_st=0
		o.lanim=sf
	end
	
	o.a_ct+=1
	
	if(o.a_ct%(30/sp)==0) then
		o.a_st+=1
		if(o.a_st==nf) o.a_st=0
	end
	
	o.a_fr=sf+o.a_st
	spr(o.a_fr,x,y,1,1,fl)
end

--real sgn
function sign(x)
	if(x == 0) return 0
	return sgn(x)
end

--inverse circle fill
function invcircfill(xx,yy,r,c)
    local r2=r*r
    color(c)
    for j=cy-4,cy+127+4 do
        local y=yy-j
        local x=sqrt(max(r2-y*y))
        rectfill(xx-128,j,xx-x,j)
        rectfill(xx+x,j,xx+128,j)
    end
end

function point_distance(x1,y1,x2,y2)
 return flr(sqrt((x2-x1)^2+(y2-y1)^2))
end

--particles
function explos_init()
	sparks={}
	for i=1,150 do
		add(sparks,{
		x=0,y=0,velx=0,vely=0,
		r=0,alive=false,col=6,spd=0.1
		})
	end
end

function explode(x,y,r,particles,spd,col)
	spd = spd or 1
	col = col or 6
	local selected = 0
	for i=1,#sparks do
		if not sparks[i].alive then
			sparks[i].x = x
			sparks[i].y = y
			sparks[i].vely = -1 + rnd(2)
			sparks[i].velx = -1 + rnd(2)
			sparks[i].mass = 0.5 + rnd(2)
			sparks[i].r = 0.5 + rnd(r)
			sparks[i].alive = true
			sparks[i].col = col
			sparks[i].spd = spd/10
			
			selected += 1
			if selected == particles then
			break end
		end
	end
end

--draw explosion fx
function draw_parts()
	for i=1,#sparks do
		if sparks[i].alive then
			circfill(sparks[i].x,sparks[i].y,
			sparks[i].r,sparks[i].col)
		end
	end
end
-->8
--game functions
function init_game()
	gamestate=1
	explos_init()
	init_plats()
	init_catposts()
	init_npcs()
	init_enemies()
	init_pickups()
	init_player()
	init_camera()
	win=false
	spotsize=0
	btnprompt=0
	--music(0)
end

function init_camera()
	camx=ply.x-60
	camy=ply.y-60
	cx=camx
	cy=camy
	caml=0.125
	shake=0
	shakedec=0
end

function update_game()
	update_plats()
	update_catposts()
	update_enemies()
	if(itemget==0 and not dialog and not win) update_player()
	update_npcs()
	update_dialog()
	update_pickups()
	
	if not win and ply.y < -7 then
		win=true
	end
	
	if win or dead then
		spotsize = lerp(spotsize,0,0.0325)
		if win and flr(spotsize)==0 then
			init_menu()
		elseif dead and flr(spotsize)==0 then
			ply.x=spawnx
			ply.y=spawny
			cx=ply.x-60
			cy=ply.y-60
			init_enemies()
			dead=false
		end
	else
		spotsize = lerp(spotsize,52,0.0325)
	end
	
	--screenshake
	if(shake > 0) shake -= shakedec
	if(shake < 0) shake = 0
	
	--itemget effect
	if itemget > 0 then
		if itemget < 60 then
			shinew+=1
			ply.y = lerp(ply.y,plyy-8,0.0325)
		elseif itemget == 60 then
			sfx(20,3)
			screenshake(3,0.1)
		elseif itemget == 240 then
			itemget=0
		elseif itemget > 180 then
			shinew-=1
			ply.y = lerp(ply.y,plyy,0.0325)
		end
		if(itemget>0)itemget+=1
	end
	
	if btnprompt>0 then
		btnprompt+=1
	end
	
	--explosion fx
		for i=1,#sparks do
			if sparks[i].alive then
				sparks[i].x += sparks[i].velx / sparks[i].mass
				sparks[i].y += sparks[i].vely / sparks[i].mass
				sparks[i].r -= sparks[i].spd
				if sparks[i].r < sparks[i].spd then
					sparks[i].alive = false
				end
			end
		end
end

function draw_game()
	camx = ply.x-60
	camy = ply.y-60
	cx = lerp(cx,camx,caml)
	cy = lerp(cy,camy,caml)
	if(ply.x >= 40*8 and ply.x < 43*8 and cy < 0) cy = 0
	camera(cx+rnd(shake)-shake/2,cy+rnd(shake)-shake/2)
	
	draw_catposts()
	
	--buildings
	if(dimension==0) spr(64,79*8,5*8+1,4,4)
	if(dimension==1) spr(68,18*8,41*8+1,4,4)
	if dimension==2 then
		pal(5,1)
		spr(68,107*8,43*8+1,4,4)
		spr(68,98*8,42*8+1,4,4)
		pal(5,5)
	end
	
	draw_npcs()
	draw_snails()
	draw_parts()
	
	if itemget > 0 then
		local wdth = mid(0,shinew,60)/7
		rectfill(ply.x+4-wdth,ply.y-80,ply.x+4+wdth,ply.y+80,7)
	end
	
	if(not win)draw_player(ply.x,ply.y)
	
	if (cancheck or (cantalk and not dialog)) and itemget==0 then
		local offs = 1
		if(ply.flp) offs=0
		print("”",ply.x+offs,ply.y-7,6)
	end
	
	if itemget==0 and btnprompt>0 and flr(btnprompt/30)%2==0 then
		local offs = 1
		if(ply.flp) offs=0
		print("ƒ",ply.x+offs,ply.y-7,6)
	end
	
	if dimension==0 then
		pal(7,6)
	elseif dimension==1 then
		pal(7,13)
	elseif dimension==2 then
		pal(7,2)
	end
	map(0,0,0,0,128,128)
	if(cx < 0) rectfill(-64,-64,0,64*8,7)
	if(cx > (128-16)*8) rectfill(128*8,-64,128*8+64,64*8,7)
	if(cy < 0) rectfill(0,-64,128*8,0,7)
	if(cy > (64-16)*8) rectfill(0,64*8,128*8,64*8+64,7)
	pal(7,7)
	
	draw_plats()
	draw_pickups()
	
	draw_bats()
	
	if itemget > 60 then
		outline_print(itemtxt,ply.x+4-#itemtxt*2,ply.y+16,0,7)
		spr(itemgot,ply.x,ply.y-16)
	end
	
	palt(0,true)
	invcircfill(ply.x+3,ply.y+3,spotsize+rnd(1),0)
	palt(0,false)
	
	if(dialog)draw_dialog(cx,cy)
	
	if itemget == 0 then
		if(itemjewel==1) spr(60,cx+2,cy+2)
		if(itemflower==1) spr(27,cx+2,cy+2)
		if(itempresent==1) spr(43,cx+2,cy+2)
	end
end

function item_get(sp)
	sfx(19,3)
	itemget=1
	itemgot=sp
	plyy=ply.y
	if(sp==45 or sp==61)itemtxt = "yOU FOUND AN eYE"
	if(sp==28)itemtxt = "yOU GOT dOUBLE jUMP"
	if(sp==44)itemtxt = "yOU GOT wALL jUMP"
	if(sp==60)itemtxt = "yOU GOT A jEWEL"
	if(sp==27)itemtxt = "yOU GOT A fLOWER"
	if(sp==43)itemtxt = "yOU GOT A pRESENT"
end
-->8
--dimension platforms

function init_plats()
	plats={}
	add_plat(60,17,1,true)
	add_plat(61,17,1,true)
	add_plat(61,16,1,true)
	add_plat(61,15,1,true)
	add_plat(62,16,1,true)
	add_plat(62,17,1,true)
	add_plat(63,17,1,true)
	
	for i=0,1 do
		add_plat(70+i,8,1,true)
		add_plat(68+i,6,1,true)
		add_plat(72+i,5,1,true)
		
		add_plat(103+i,18,1,true)
		add_plat(101+i,17,1,false)
		add_plat(99+i,16,1,true)
		add_plat(97+i,15,1,false)
		
		add_plat(47+i,45,1,false)
		add_plat(37,50+i,1,false)
		
		add_plat(17+i,40,1,true)
		add_plat(21+i,41,1,true)
		add_plat(25+i,42,1,true)
	end
	
	for i=3,9 do
		add_plat(97,i,1,true)
	end
	
	for i=98,101 do
		add_plat(i,5,1,false)
	end
	
	for i=0,5 do
		add_plat(65+i,19,1,false)
		
		add_plat(49,40+i,1,false)
		
		if(i<5) add_plat(43,48+i,1,false)
		add_plat(46,47+i,1,true)
	end
	
	for i=0,2 do
		add_plat(74,16+i,2,true)
		
		add_plat(40,49+i,1,true)
		
		add_plat(80+i,40,0,true)
	end
	
	for i=0,7 do
		add_plat(95,37+i,2,true)
		add_plat(119,40+i,2,true)
	end
	
	add_plat(3,34,1,false)
	add_plat(5,32,1,false)
	add_plat(5,26,1,true)
	add_plat(2,21,1,false)
	add_plat(4,19,1,false)
	add_plat(2,17,1,false)
	
	add_plat(82,55,0,false)
	add_plat(85,52,1,false)
	add_plat(84,47,2,false)
	add_plat(81,45,1,false)
end

function add_plat(xx,yy,dimm,allbut)
	add(plats,{
	x=xx*8,y=yy*8,dim=dimm,but=allbut,check=false
	})
end

function plat_get(xx,yy,ignore,pid)
	local ig = ignore or false
	if pid then
		if (ig or plat_is_active(pid)) and pid.x/8 == flr(xx) and pid.y/8 == flr(yy) then
			return true
		end
		return false
	end
	for p in all(plats) do
		if (ig or plat_is_active(p)) and p.x/8 == flr(xx) and p.y/8 == flr(yy) then
			return true
		end
	end
	return false
end

function plat_get_box(xx,yy)
	for p in all(plats) do
		if not (p.x < cx-8 or p.y < cy-8 or p.x > cx+128 or p.y > cy+128) then
			if plat_is_active_box(p) and p.x/8 == flr(xx) and p.y/8 == flr(yy) then
				return true
			end
		end
	end
	return false
end

function update_plats()
	for p in all(plats) do
		if p.check and not (p.x < cx-8 or p.y < cy-8 or p.x > cx+128 or p.y > cy+128) then
			if not cplat(ply,ply.x,ply.y,true,p) then
				p.check=false
			end
		end
	end
end

function draw_plats()
	for p in all(plats) do
		if plat_is_active(p) then
			spr(13+dimension,p.x,p.y)
		elseif plat_is_active(p,true) then
			spr(29+dimension,p.x,p.y)
		end
	end
end

function plat_is_active(p,ignore)
	if(p.x < cx-8 or p.y < cy-8 or p.x > cx+128 or p.y > cy+128) return false
	local ig = ignore or false
	if(not ig and p.check)return false
	if p.but then
		if(p.dim~=dimension)return true
	else
		if(p.dim==dimension)return true
	end
	return false
end

function plat_is_active_box(p)
	if(p.check)return false
	if p.but then
		if(p.dim~=dimension)return true
	else
		if(p.dim==dimension)return true
	end
	return false
end

--plat collision
function plat_coll(o,xx,yy,p,ignore)
	local ig = ignore or false
	if(not ig and not plat_is_active(p)) return false
	
	local box_a = abs_box_xy(o,xx,yy)
	local box_b = {p.x,p.y,p.x+7,p.y+7}
	
	if box_a[1] > box_b[3] or
	   box_a[2] > box_b[4] or
	   box_b[1] > box_a[3] or
	   box_b[2] > box_a[4] then
	   return false
	end
	
	return true
end
-->8
--game objects

function init_catposts()
	catposts={}
	--spawn
	add_catpost(34,26,true)
	--other
	add_catpost(53,18)
	add_catpost(86,7)
	add_catpost(14,38)
	add_catpost(103,45)
end

function add_catpost(xx,yy,ac)
	local a = ac or false
	add(catposts,{
	x=xx*8,y=yy*8,act=a,box={0,0,15,15},hover=false
	})
end

function update_catposts()
	local canc=false
	for p in all(catposts) do
		if(not p.act)p.hover = coll(ply,p)
		if(p.hover)canc=true
		if btnp(”) and p.hover then
			sfx(17,2)
			for q in all(catposts) do
				q.act=false
			end
			spawnx=p.x+4
			spawny=p.y+8
			p.act=true
			p.hover=false
		end
	end
	cancheck=canc
end

function draw_catposts()
	for p in all(catposts) do
		spr(46,p.x,p.y,2,2)
	end
end

--nps
function init_npcs()
	npcs={}
	add_npc(82,8,17,0)
	add_npc(25,43,18,1)
	add_npc(17,44,19,1)
	add_npc(106,46,20,2)
end

function add_npc(xx,yy,spp,dd)
	add(npcs,{x=xx*8,y=yy*8,sp=spp,d=dd,box={0,0,7,7}})
end

function update_npcs()
	local cant = false
	for i=1,#npcs do
		if dimension==npcs[i].d and coll(ply,npcs[i]) then
			cant = true
			if btnp(”) and not dialog then
				if i==1 then --rich guy
					if itemjewel == 1 then
						dialog_box({[[
OH? YOU BROUGHT ME MY jewel?
GOOD KITTY!]],[[
I DON'T HAVE ANY CAT TOYS,
BUT...]],[[
YOU CAN HAVE THESE PAPERS I
HAD LYING AROUND.]]},function() item_get(28) itemjewel=2 doublejump=true end)
					elseif itemjewel==0 then
						dialog_box({[[
SINCE BIRTH I WANTED TO ESCAPE
THE CAVES BY ACQUIRING WEALTH.]],[[
I HAD FOUND A MASSIVE jewel, &
SOLD ITS PIECES FOR A FORTUNE!]],[[
I THINK I FORGOT IT DURING THE
MOVE...]],[[
IT'S PROBABLY BEEN COLLECTING
DUST DOWN THERE SINCE.]]},nil)
					else
						dialog_box({[[
WHILE I THANK YOU FOR HELPING,
CAN YOU GET OFF MY PROPERTY?]]},nil)
					end
				elseif i==2 then --lil girl
					if itemflower == 1 then
						dialog_box({[[
HELLO MR. KITTY! OH! YOU
BROUGHT ME A flower?]],[[
THANK YOU! HERE, YOU CAN HAVE
THIS WEIRD MARBLE I FOUND!]]},function() item_get(61) itemflower=2 eyes=3 end)
					elseif itemflower ==0 then
						dialog_box({[[
I WISH I COULD GIVE MY MOMMY
A flower LIKE MINE!]],[[
ALL THAT GROWS HERE ARE
WEEDS...]]},nil)
					else
						dialog_box({[[
HELLO MR. KITTY!]],[[
GOODBYE MR. KITTY!]]},nil)
					end
				elseif i==3 then --mother girl
					if itempresent == 1 then
						dialog_box({[[
OH? WHAT'S THIS? A present?
FROM WHO?]],[[
WELL THANK YOU! THAT MUST HAVE
BEEN A DIFFICULTY DELIVERY!]],[[
TAKE THIS AS PAYMENT!]]},function() item_get(44) itempresent=2 walljump=true end)
					elseif itempresent==0 then
						dialog_box({[[
MY DAUGHTER AND I MOVED HERE
BECAUSE OUR LAST NEIGHBOURHOOD]],[[
GOT INFESTED WITH DANGEROUS
MONSTERS.]],[[
I DIDN'T WANT HER TO GET HURT,
BUT THIS ISN'T MUCH BETTER...]],[[
IT'S JUST KINDA LONELY OVER
HERE.]]},nil)
					else
						dialog_box({[[
SUZY, BE CAREFUL OVER THERE!]]},nil)
					end
				elseif i==4 then --jeff
					if itempresent == 1 then
						dialog_box({[[
I CAN'T THANK YOU ENOUGH FOR
THIS!]],[[
NO REALLY, I CAN'T. I DON'T
HAVE ANYTHING TO GIVE YOU...]]},nil)
					elseif itempresent==0 then
						dialog_box({[[
I USED TO LIVE NEXT TO ABIGAIL
AND SUZY, BUT THEY MOVED AWAY]],[[
WHEN ALL THE MONSTERS ARRIVED.]],[[
I WANTED TO GIVE ABIGAIL A
present...]],[[
...AND CONFESS MY FEELINGS FOR
HER BUT I DIDN'T HAVE THE GUTS]],[[
YOU'LL BRING IT TO HER? OH
I CAN'T THANK YOU ENOUGH!]]},function() item_get(43) itempresent=1 end)
					else
						dialog_box({[[
OH? YOU GAVE IT TO HER?]],[[
THANK YOU SO MUCH! I REALLY
APPRECIATE THIS!]],[[
I STILL DON'T HAVE ANYTHING TO
THANK YOU WITH...]]},nil)
					end
				end
			end
		end
	end
	cantalk=cant
end

function draw_npcs()
	for n in all(npcs) do
		if dimension == n.d then
			pal(0,5)
			pal(6,5)
			for i=-1,1 do
				for j=-1,1 do
					if not(i==0 and j==0) then
						spr(n.sp,n.x+i,n.y+j)
					end
				end
			end
			pal(0,0)
			pal(6,6)
			spr(n.sp,n.x,n.y)
		end
	end
end

--eye pickups
function init_pickups()
	pickups={}
	add_pickup(91,6,45) --blue eye
	add_pickup(3,33,60) --jewel
	add_pickup(60,51,27) --flower
end

function add_pickup(xx,yy,spp)
	add(pickups,{
	x=xx*8,y=yy*8+4,sp=spp,box={1,1,6,6}
	})
end

function update_pickups()
	for e in all(pickups) do
		if coll(ply,e) then
			if e.sp == 45 then --blue eye
				item_get(45)
				eyes=2
				btnprompt=1
				del(pickups,e)
			elseif e.sp == 60 then --jewel
				item_get(60)
				itemjewel=1
				del(pickups,e)
			elseif e.sp == 27 then --flower
				item_get(27)
				itemflower=1
				del(pickups,e)
			end
		end
	end
end

function draw_pickups()
	for e in all(pickups) do
		spr(e.sp,e.x,round(e.y+sin(t())))
	end
end
-->8
--dialog system
function init_dialog()
	dialog=false
	dialogtxt=""
	dialogtxtto={}
	dtime=0
	dcount=0
	dfunc=nil
end

function dialog_box(txt,func)
	dialog=true
	dialogtxt=""
	dialogtxtto={}
	for i=1,#txt do
		dialogtxtto[i]=txt[i]
	end
	dtime=0
	dcount=0
	dfunc=func
end

function update_dialog()
	if #dialogtxtto < 1 then
		dialog=false
		if dfunc ~= nil then
			dfunc()
			dfunc=nil
		end
		return
	end
	
	local nmod=6
	if(btn(—))nmod=3
	if dcount < #dialogtxtto[1] and dtime%nmod==0 then
		dcount+=1
		sfx(26,3)
	end
	
	if btnp(Ž) then
		if dcount < #dialogtxtto[1] then
			dcount = #dialogtxtto[1]
		elseif dcount == #dialogtxtto[1] then
			dialogtxt=""
			dtime=0
			dcount=0
			deli(dialogtxtto,1)
			return
		end
	end
	
	dialogtxt = sub(dialogtxtto[1],1,dcount)
	
	
	dtime+=1
end

function draw_dialog(x,y)
	rectfill(x+2,y+106,x+125,y+125,0)
	rect(x+2,y+106,x+125,y+125,7)
	print(dialogtxt,x+4,y+108,7)
end
-->8
--enemy code

function init_enemies()
	enemies={}
	etime=0
	--snails
	add_enemy(42,17,1)
	add_enemy(54,11,1)
	add_enemy(49,38,1)
	add_enemy(35,42,1)
	add_enemy(10,39,1)
	add_enemy(104,27,1)
	add_enemy(119,24,1)
	add_enemy(95,33,1)
	add_enemy(111,35,1)
	add_enemy(114,59,1)
	add_enemy(87,57,1)
	add_enemy(94,58,1)
	--bats
	add_enemy(100,19,2)
	add_enemy(120,22,2)
	add_enemy(114,33,2)
	add_enemy(90,38,2)
	add_enemy(115,57,2)
	add_enemy(85,55,2)
	add_enemy(35,49,2)
	add_enemy(7,9,2)
end

function add_enemy(xx,yy,typ)
	local e={
	x=xx*8,y=yy*8,id=typ,hs=0.25,vs=0,box={0,0,7,7}
	}
	if type==2 then
		e.box={0,2,7,6}
		e.dir=0
	end
	add(enemies,e)
end

function update_enemies()
	etime+=1
	for e in all(enemies) do
		if not (e.x < cx-8 or e.y < cy-8 or e.x > cx+128 or e.y > cy+128) then
			if e.id == 1 then
				if cmap(e,e.x+e.hs,e.y) or not cmap(e,e.x+e.hs+(8*sgn(e.hs)),e.y+1) then
					e.hs*=-1
				end
				e.x += e.hs
				--player col
				if coll(ply,e) and not dead then
					if ply.vs > gravity then
						sfx(27,2)
						ply.vs=ply.jump/1.25
						jumps=0
						if(doublejump) jumps=1
						explode(e.x+3,e.y+3,2,10,0.25,5)
						del(enemies,e)
					else
						kill_player()
					end
				end
			else
				if point_distance(e.x,e.y,ply.x,ply.y) <= 52 then
					e.dir=atan2(ply.y-e.y,ply.x-e.x)
					if(dead) e.dir+=0.5
					e.hs=sin(e.dir)*0.3
					e.vs=cos(e.dir)*0.3
					e.x+=e.hs
					e.y+=e.vs
					
					if coll(ply,e) and not dead then
						if ply.vs > gravity then
							sfx(27,2)
							ply.vs=ply.jump/1.25
							jumps=0
							if(doublejump) jumps=1
							explode(e.x+3,e.y+3,2,10,0.25,5)
							del(enemies,e)
						else
							kill_player()
						end
					end
				end
			end
		end
	end
end

function draw_snails()
	for e in all(enemies) do
		if not (e.x < cx-8 or e.y < cy-8 or e.x > cx+128 or e.y > cy+128) then
			if e.id==1 then
				local sp = 21
				if(flr(etime/8)%2==0) sp+=1
				local flp=false
				if(e.hs<0)flp=true
				pal(0,5)
				for i=-1,1 do
				 for j=-1,1 do
						if not(i==0 and j==0) then
							spr(sp,e.x+i,e.y+j,1,1,flp)
						end
					end
				end
				pal(0,0)
				spr(sp,e.x,e.y,1,1,flp)
			end
		end
	end
end

function draw_bats()
	for e in all(enemies) do
		if not (e.x < cx-8 or e.y < cy-8 or e.x > cx+128 or e.y > cy+128) then
			if e.id==2 then
				local sp = 23
				if(flr(etime/12)%2==0) sp+=1
				pal(0,5)
				for i=-1,1 do
				 for j=-1,1 do
						if not(i==0 and j==0) then
							spr(sp,e.x+i,e.y+j)
						end
					end
				end
				pal(0,0)
				spr(sp,e.x,e.y)
			end
		end
	end
end
-->8
--main menu
function init_menu()
	gamestate=0
	spotsize=0
	cx=0
	cy=0
	showmenu=false
	menuy=128
	startgame=1
	starttime=0
end

function update_menu()
	if(btnp(Ž)) startgame=0
	if startgame==0 then
		spotsize = lerp(spotsize,0,0.0325)
		menuy = lerp(menuy,128,0.0325)
		if(flr(spotsize)==0) starttime+=1
		if(starttime==30) init_game()
	else
		spotsize = lerp(spotsize,32,0.0325)
		if not showmenu and ceil(spotsize)==32 then
			showmenu=true
		end
		if showmenu then
			menuy = lerp(menuy,0,0.0325)
		end
	end
end

function draw_menu()
	camera(0,0)
	rectfill(0,0,127,127,6)
	spr(76,47,48-25,4,4)
	invcircfill(63,63-24,spotsize+rnd(sign(startgame)),0)
	--draw options
	local st="pRESS Ž TO sTART"
	print(st,63-#st*2,menuy+96+round(sin(t()/4)*2),6)
	print("bY yUKON w",0,menuy+122,5)
	local st="dEMAKE BY cARSON k"
	print(st,128-#st*4,menuy+122,5)
end
__gfx__
00000000aa0aaa0aaa0aaa0aaa0aaa0aaaaaaaaaaaaaaaaaaa0aaa0aaa0aaa0aaa0aaa0aaa0aaa0aaa0aaa0aaa0aaa0aaa0aaa0a66a66a66ddaddadd22a22a22
00000000aa00000aaa00000aaa00000aaa0aaa0aaa0aaa0aaa00000aaa00000aaa00000aaa00000aaa00000aaa00000aaa00000a6aaaaaa6daaaaaad2aaaaaa2
00700700aa00020aaa00020aaa00020aaa00000aaa00000aaa00020aaa00020aaa00020aaa00020aaa00020aaa00020aaa00020aaa6aa6aaaadaadaaaa2aa2aa
00077000aa0600daaa0600daaa0600daaa00020aaa00020aaa0600daaa0600daaa0600daaa0600daaa0600daaa0600daaa0600da6aa66aa6daaddaad2aa22aa2
00077000aa00000aaa00000aaa00000aaa0600daaa0600daaa00000aaa00000aaa00000aaa00000aaa00000aaa00000aaa00000a6aa66aa6daaddaad2aa22aa2
00700700a0a000aaaaa000aaaaa000aaaaa000aaaaa000aaa0a000aaaaa000aaaaa000aaaaa000aaaaa000aaa0a000aaa0a000aaaa6aa6aaaadaadaaaa2aa2aa
00000000aa0000aaa00000aaaa0000aaaa0000aaa00000aaaa0000aaa00000aaaa0000aaa00000aaaa00000aaa0000aaaa00000a6aaaaaa6daaaaaad2aaaaaa2
00000000aaa0a0aaaaa0a0aaa0a0a0aaa0a0a0aaaaa0a0aaaaa0a0aaaaa00aaaa0a0a0aaaaa00aaaa0a0aaaaaaaa00aaaaaaa0aa66a66a66ddaddadd22a22a22
99999999a66666aaaaaaaaaaaa6666aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000aaaaaaaaaa55aaaaaa666666aaaaaaaaaaaaaaaaaaaaaaaa
99999999a66666aaaa6666aaa666666aa6666aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00000000aaaaaaaaa5665aaaa6000066aaaaaaaaaaaaaaaaaaaaaaaa
999999996666666aa665666aa6000066a00006aaa0000aaaa0000aaa000aa000aa0aa0aa00000000aaaaaaaa56d565aa605556aaaa6aa6aaaadaadaaaa2aa2aa
99999999a50050aaa6500066a605005aa50050aa005500aa005500aaa000000aa000000a00000000aaaaaaaa565d65aa6000006aaaa66aaaaaaddaaaaaa22aaa
99999999a00000aaa605005aa600000aa00000aa000500a0000500aaa050050aa050050a00000000aaaaaaaaa566555aa6055506aaa66aaaaaaddaaaaaa22aaa
9999999966000aaaa660000aa66000aaaa000aaa05050505050505a0a000000aa000000a00000000aaaa0aa0aa55a555aa600006aa6aa6aaaadaadaaaa2aa2aa
999999996a000aaaaa6000aaaa6000aaaa000aaa0050050000500505aaaaaaaa00aaaa00000000000a000020aaaaa5aaa600006aaaaaaaaaaaaaaaaaaaaaaaaa
999999996a0a0aaaaaa0a0aaaaa0a0aaaa0a0aaaa000500aa0005000aaaaaaaaaaaaaaaa00000000a000700daaaa55aa666666aaaaaaaaaaaaaaaaaaaaaaaaaa
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a66aa66aaa666666aa0000aaa5555555555aaaaa
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056655665a6000066a0d11d0aa5000000005aaaaa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005dd66dd5605556aa0d1dd1d0a5000000005aaaaa
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555556000006a0dd00dd0a5555555555aaaaa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005dd66dd5a60555060d0000d0aaaa500505aaaaaa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005dd66dd5aa6000060d1001d0aaaa500555aaaaaa
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005dd66dd5a600006aa0d11d0aaaaa500555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000005dd66dd5666666aaaa0000aaaaaa500550000005
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaaaaaaa0000aaaaaa500550000005
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa6666aaa082280aa555555555500555
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a605506a08288280a50000005a5005aa
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006055570608800880a50055005a5005aa
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000700608000080a505aa505a5005aa
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a650056a08200280a505aa505555555a
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa6006aaa082280aa50055000000005a
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa66aaaaa0000aaa50000000000005a
aaaaaaaaaaaaa555555aaaaaaaaaaaaaaaaaaaaaaaaaa555555aaaaaaaaaaaaaaa77777777a777a7777777aa00000000aaaaaa000aaaaaaaa000aaaaaaaa000a
aaaaaaaaaaaaaa5555aaaaaaaaaaaaaaaaaaaaaaaaaa55555555aaaaaaaaaaaaa7777777777777777777777a00000000aaaaa00000aaaaaa00000aaaaaa00000
aaaaaaaaaaaaa555555aaaaaaaaaaaaaaaaaaaaaaaa5555555555aaaaaaaaaaa77777777777777777777777700000000aaaaa00000aaaaaa00000aaaaaa00000
aaaaaaaaaaaaa555555aaaaaaaaaaaaaaaaaaaaaaa555555555555aaaaaaaaaa77777777777777777777777700000000aaaaa0000aaaaaaa0000aaaaaaa0000a
aaaaaaaaaaaa55555555aaaaaaaaaaaaaaaaaaaaa55555555555555aaaaaaaaa77777777777777777777777700000000aaaaa0000aaaaaaa0000aaaaaaa0000a
aaaaaaaaaaa5555555555aaaaaaaaaaaaaaaaaaa5555555555555555aaaaaaaa77777777777777777777777700000000aaaaaa00aaaaaaaaa00aaaaaaaaa00aa
aaaaaaaaaaaa55555555aaaaaaaaaaaaaaaaaaa555555555555555555aaaaaaa77777777777777777777777700000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaa55555555aaaaaaaaaaaaaaaaaa55555555555555555555aaaaaa77777777777777777777777700000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaa55555555aaaaaaaaaaaaaaaaa5555555555555555555555aaaaa77777777777777777777777777a777a7aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaa5aaaaaaa55555555aaaaaaa5aaaaaaaa555555555555555555555555aaaa77777777777777777777777a77777777aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaa5aaa55aa55555555aa55aaa5aaaaaaa55555555555555555555555555aaaa7777777777777777777777777777777aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa5555555555555555555555555555aaaa5555555555555555555555555555aa77777777777777777777777777777777aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aa5555555555555555555555555555aaa555555555555555555555555555555a77777777777777777777777777777777aaa00aaaaaaaaa00aaaaaaaaa00aaaaa
aa5555555555555555555555555555aa5555555555555555555555555555555577777777777777777777777a77777777aa0000aaaaaaa0000aaaaaaa0000aaaa
a555555555555555555555555555555a55555555555555555555555555555555a7777777777777777777777777777777aa0000aaaaaaa0000aaaaaaa0000aaaa
55555555555555555555555555555555555555555555555555555555555555557777777777777777777777777a777a77aa000aaaaaaaa000aaaaaaaa000aaaaa
a555555555555555555555555555555a5555555555555555555555555555555577777777777777777777777777777777aa000aaaaaaaa000aaaaaaaa000aaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaa7777777777777777777777777777777aaa000aaaaaaaa000aaaaaaaa000aaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaa777777777777777777777777a7777777aa00aaaaaaaaa00aaaaaaaaa00aaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaa77777777777777777777777777777777a000aaaaaaaa000aaaaaaaa000aaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaa77777777777777777777777777777777a000aaaaaaaa000aaaaaaaa000aaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaa7777777777777777777777777777777aa000aaaaaaaa000aaaaaaaa000aaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaaa7777777777777777777777aa7777777a000aaaaaaaa000aaaaaaaa000aaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaaaa7777777a777a77777777aa77777777a000aaaaaaaa000aaaaaaaa000aaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaaaa77777777777777777777aaaa7777aaa00aaaaaaaaa00aaaaaaaaa00aaaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaaa7777777777777777777777aa777777a000aaaaaaaa000aaaaaaaa000aaaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaa77777777777777777777777777777777000aaaaaaaa000aaaaaaaa000aaaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaa77777777777777777777777777777777000aaaaaaaa000aaaaaaaa000aaaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaa77777777777777777777777777777777000aaaaaaaa000aaaaaaaa000aaaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaa777777777777777777777777777777770000aaaaaaa0000aaaaaaa0000aaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaaa7777777a777777a7777777a777777770000aaaaaaa0000aaaaaaa0000aaaaaa
a555555555555555555555555555555aaaa55555555555555555555555555aaaaa777777aa7777aa777777aa77777777a00aaaaaaaaa00aaaaaaaaa00aaaaaaa
9595a5000000869695959595959595959595959595959595959595959595959595959595959595959595959595959595969696a6000000000000000000000000
0000000000008495959595959595959595959595959595a500000000000000000000000000000000000000000000000000000000000000000000000000000085
9595a50000000000869595959595959595959595959595959595959595959595959595959595959595959595959595a600000000000000000000000000000000
0000000000849595959595959595959595959595959595a600000000000000000000000000000000000000000000000000000000000000000000000000000085
9595a500000000000085959595959595959595959595959595959595959595959595959595959595959595959595a50000000000000000000000000000000084
94949494949595959595959595959595959595959595a50000000000008494949494949494a40000000000000000000000000000000000000000000000008495
959595a4000000000086969696959595959595959595959595959595959595959595959595959595959595959595a50000000087b5b5b5949494949494949495
95959595959595959595959595959595959595959595a5000000000000869695959595959595949494949494a400000000000000000000008494949494949595
9595959594a400000000000000869696969696969696969695959595959595959595959595959595959595959595a50000000000000000869696969595959595
95959595959595959595959696969696969595959595a50000000000000000869696969696959595959595959594949494949494949494949595959595959595
9595959595a50000000000000000000000000000000000008696959595959595959595959595959595959595959595a400000000000000000000008595959595
95959595959595959595a60000000000008695959595a50000000000000000000000000000969696969696969696969696959595959595959595959595959595
95959595959594a4000000000000000000000000000000000000869696969696969696969696969696969595959595a500000000000000000000008595959595
959595959595959595a500000000000000008695959595a400000000000000000000000000000000000000000000000000869696969696959595959595959595
959595959595959594a40000000000000000000000000000000000000000000000000000000000000000869696969696b5b5b5b5b5a700000000849595959595
959595959595959595a500000000000000000085959595a500000000000000000000000000000000000000000000000000000000000000869696969595959595
95959595959595959595949494949494a40000000000000000000000000000000000000000000000000000000000000000000000000000000000859595959595
959595959595959595a50000008494a40000008595959595a4000000000000000000000000000000000000000000000000000000000000000000008695959595
95959595959595959595959595959595a50000000000000000000000000000000000000000000000000000000000000000000000000000000000859595959595
959595959595959595a50000849595a50000008695959595a5000000000000000000000000000000000000000000000000000000000000000000000085959595
95959595959595959595959595959595a50000000000000000000000000000000000000000000000000000000000000000000000000000000084959595959595
959595959595959595a50000859595a5000000008695959595a40000000000000000000000000000000000000000000000000000000000000000000085959595
95959595959595959595959595959595a50000000000000000000000849494949494949494949494949494b5a700000000000000000000000085959595959595
959595959595959595a5000085959595a4000000008595959595a400000000000000000000000000000000000000000000000000000000000000000086959595
95959595959595959595959595959595a500000000000084949494949595959595959595959595969696a6000000000000000000000000008495959595959595
959595959595959595a5000085959595a500000000859595959595a4000000000000000000000000000000000000000000000000000000000000000000859595
9595959595959595959595959595959595949494949494959595959595959595959595959596a600000000000000000000000000000000008595959595959595
959595959595959595a5000085959595a5000000008595959595959594949494a400000000000000000000000000000000000000000000000000000000859595
959595959595959595959595959595959595959595959595959595959595959595959596a6000000000000000000000000000000000000008595959595959595
959595959596969696a6000085959595a50000000085959595959595959595959594949494a40000000000000000000000000000000000000000000000869595
95959595959595959595959595959595959595959595959595959595959595959595a60000000000000000000000000000000000000000008595959596969696
96969696a60000000000000085959595a5000000008695959595959595959595959595959595949494949494949494a400000000000000000000000000008595
959595959595959595959595959595959595959595959595959595959595959595a600000000000000000000000000000000000000000084959696a600000000
00000000000000000000000085959595a50000000000859595959595959595959595959595959595959595959595959594949494949494a40000000000008595
9595959595959595959595959595959595959595959595959595959595959595a50000000000000000000000000000000000000000000085a500000000000000
00000000000000000000000085959595a5000000000085959595959595959595959595959595959595959595959595959595959595959595a400000000008595
9595959595959595959595959595959595959595959595959595959595959595a50000000000000000000000000000000000000000000085a500000000000000
00000000000000000000000085959595a5000000000085959595959595959595959595959595959595959595959595959595959595959595a500000000008595
959595959595959595959595959595959595959595959595959595959595959595a400000000000000000000000000000000000000000085a500000000000000
0000000000849494949494949595959595a40000000085959595959595959595959595959595959595959595959595959595959596969696a600000000008595
95959595959595959595959595959595959595959595959595959595959595959595949494949494a4000000000000000000000000000086a600000000000000
0000008494959595959595959595959595a5000000008696969696959595959595959595959595959595959595959595959596a6000000000000000000008595
9595959595959595959595959595959595959595959595959595959595959595959595959595959595949494949494a400000000000000000000008494949494
9494949595959595959595959595959595a500000000000000000086969696959595959595959595959595959595969696a60000000000000000000000008595
959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595a4000000000000000000008595959595
9595959595959595959595959595959595a5000000000000000000000000008696969696969696969696969696a6000000000000000000000000000000849595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595a40000000000000000008595959595
9595959595959595959595959595959595a500000000000000000000000000000000000000000000000000000000000000000000000000000000000000859595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595a50000000000000000008595959595
959595959595959595959595959595959595a4000000000000000000000000000000000000000000000000000000000000000000000000000000000084959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959494a40000008494949595959595
95959595959595959595959595959595959595a40000000000000000000000000000000000000000000000000000000000000000000000000000008495959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959494949595959595959595
959595959595959595959595959595959595959594949494949494a4000000000000000000000000000000000000000000000000000000000084949595959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595
95959595959595959595959595959595959595959595959595959595949494949494a40000000000000000000000000000000000000000849495959595959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595
95959595959595959595959595959595959595959595959595959595959595959595959494949494949494949494949494949494949494959595959595959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595
95959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595
__gff__
0000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010000000000000000000000000001000101000000000000000000000000010101010000000000000000000000000101010100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5959595959595959595959595959595959595959595959595959595959595959595959595959595a00000058595959595959595959595959595959595969696969696959595959595959696969696969696969696959595959595959595959595959595959696969696969696969595959595959595959595959595959595959
5959595959595959595959595959595959595959595959595959595959595959595959595959595a00000058595959595959595959595959595969696a0000000000006869696969696a00000000000000000000006869696969696969696959595959696a000000000000000000585959595959595959595959595959595959
5959595959595959595959595959595959595959595959595959595959595959595959595959595a00000058595959595959696969696969696a000000000000000000000000000000000000000000000000000000000000000000000000006869696a0000000000000000000000685959595959595959595959595959595959
5959595959595959595959595959595959595959595959595959595959595959595959595959595a0000005859595959696a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007b0000000000005859595959595959595959595959595959
5959595959595959595959595959595959595959595959595959595959595959595959595959595a000000585959595a000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000584a00000000005859595959595959595959595959595959
5959595959595959595959595959595959595959595959595959595959595959595959595959595a000000585959596a00000000000000000000000000000000000000000000000000000048594a0000000000000000000000000000000000000000000000000000585a00000000485959595959595959595959595959595959
5959595969696959595959595959595959595959595959595959595959595959595959595959595a0000005859595a00000000004849494949494949494a0000000000000000000000000058595a0000000000000000000000000000000000000000000000000000585a00000000585959595959595959595959595959595959
5959596a00000068595959595959595959595959595959595959595959595959595959595959595a0000005859595a0000000048595959595959595959594a00000000000000000000000058595a0000000000000000000000000000000000000000000000000048595a00000000585959595959595959595959595959595959
59595a0000000000685959595959595959595959595959595959595959595959595959595959595a0000005859595a0000007869696969696969696969695a00000000000000000000004859595a00000000000000000000000048494a0000000000000000000058596a00000000585959595959595959595959595959595959
59595a0000000000006869595959595959595959595959595959595969696969595959595959595a000000585959594a0000000000000000000000000000684a000000000000000000005859595949494949494949494949494959595949494a000000485b5b5b696a0000000000585959595959595959595959595959595959
59595a0000000000000000585959595959595959595959595969696a00000000686969595959595a000000585959595a000000000000000000000000000000684a000000000000000048595969696969595959595959596969696969595959595b5b5b6a00000000000000000000585959595959595959595959595959595959
59596a0000000000000000685959595959595959595959696a00000000000000000000685959595a00000058595959594949494a00000000000000000000000058494a00000048494959595a000000006869696969696a00000000006869696a0000000000000000000000000000585959595959596969696959595959595959
595a00000000000000000000585959595959595959596a000000000000000000000000006869595a000000585959696969696959494949494949497a0000000058595949494969696969696a000000000000000000000000000000000000000000000000000000000000000000485959595959696a0000000068695959595959
595a000000000000000000006869696969696969696a00000000000000000000000000000000685a00000058696a0000000000686969696969696a000000004859595959595a00000000000000000000000000000000000000000000000000000000000000000000000000000058595959596a00000000000000006859595959
595a000000000000000000000000000000000000000000000000000000000000000000000000007900000079000000000000000000000000000000000000485959596969696a00000000000000000000000000000000484949494949494949494a000000000000000000000000585959596a0000000000000000000068595959
595a0000000048494a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006869696a0000000000000000785b5b5b5b5b494949494949595959595959595959595a0000000000000000000048495959596a000000000000000000000000685959
595a000000485959594a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000686969696969696969595959595959595a00000000000000000000585959596a00000000000000000000000000005859
595a00000058595959594a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000686959595959595a000000000000000000005859595a0000000000000000000000000000005859
595a0000005859595959594a0000000048494a00000000000000000000000000000048494949494949494949494a0000000000000000000000004849494949494a00000000000000000000000000000000000000000000000000006869695959594a0000000000000000005859596a0000000000000000000000000000006859
595a000000685959595959594949494959595a00000000000000000000484949494959595959595959595959595949494949494a0000000048495959595959596a0000000000004849494949494a000000000000000000000000000000006869595a00000000000000004859596a000000000000000000000000000000000058
595a000000006859595959595959595959595a00000000000000484949595959595959595959595959595959595959595959595949494949595959595959596a0000000000000058595959595959494949494949494a0000000000000000000068594a0000000000484959595a00000000000000000000000000000000000058
595a000000000068595959595959595959595a000000004849495959595959595959595959595959595959595959595959595959595959595959595959596a0000000000004849595959595959595959595959595959494a00000000000000000068594949494949595959696a00000000000000000000000000000000000058
59594a000000000068595959595959595959594a00000068595959595969696969696969595959595959595959595959595959595959595959595959596a0000000000004859595959595959595959595959595959595959494a000000000000000068696969696969696a000000000000000000000000000000000000000058
5959594a0000000000585959595959595959595a00000000686969696a000000000000006869595959595959595959595959595959595959595959595a00000000004849595959595959595959595959595959595959595959594a00000000000000000000000000000000000000000000000000000000000000000000000058
595959594a0000000058595959595959595959594a0000000000000000000000000000000000585959595959595959595959595959595959595959596a0000000048595959595959595959595959595959595959595959595959594a000000000000000000000000000000000000000000000000000000000000000000000058
595959595a0000000058595959595959595959595a00000000000000000000000000000000005859595959595959595959595959595959595959595a0000000000685959595959595959595959595959595959595959595959595959494a0000000000000000000000000000000000000000000000004849494a000000000058
595959596a000000005859595959595959595959594a000000000000000000000000000000005859595959595959595959595959595959595959595a000000000000686959595959595959595959595959595959595959595959595959594a0000000000000000000000000000000000000000000048595959594a0000000058
5959596a000000000058595959595959595959595959494a00000000000000000000000000485959595959595959595959595959595959595959595a000000000000000068595959595959595959595959595959595959595959595959595949494a0000000000000000000000000000000000484959595959595a0000000058
59595a000000000048595959595959595959595959595959494a000000000000484949494959595959595959595959595959595959595959595959594a000000000000000068595959595959595959595959595959595959595959595959595959594949494949494949494949494949494949595959595959596a0000000058
59595a000000004859595959595959595959595959595959595949494949494959595959595959595959595959595959595959595959595959595959594a00000000000000006859595959595959595959595959595959595959596969696969696959595959595959595959595959595959595959595959596a000000000058
59595a00000048595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595959595b5b5b7a0000000000585959595959595959595959595959595959696a00000000000000686969696969696969696969595959595959595959596a00000000000058
59595a000000585959595959595959595959595959595959595959595959595959595959595959595959595959595959595959596969696969696969696a00000000000000000058595959595959595959595959595959596a0000000000000000000000000000000000000000006869696969696969696a0000000000000058
__sfx__
010100000000002650026500265004650076500c65011650166501c6502065025650286502b6502c6502c6502c6502b65029650246501d650136500c640076300562004610046100461004600046000460005600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002b1112c13133151351613616135161331512d1512b1512a1412a1312a1212a1112a1012a1012a1012a1012a1010010100101001010010100101001010010100101001010010100101001010010100101
000100000000002650026500265004650076500c65011650166501c6502065025650286502b6502c6502c6502c6502b65029650246501d650136500c640076300562004610046100461004600046000460005600
010200000c073076100a6101361021610216100c07300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c073076100a6101361015610156100c07300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001105011050110501105011040110401104011040110301103011030130501305010050100501005011050110501105011050110401104011040110401103011030110301305013050100501005010050
011e00000515405150051500515005140051400514005140051300513005130051300512005120051200512005154051500515005150051400514005140051400513005130051300513005120051200512005120
011e0000110501105011050110501104011040110401104011030110301103011030050500a0500a0400005000050000500005000050000400004000040000400003000030000300003000020000200002000020
011e00000a0500a0500a0500a0500a0400a0400a0400a0400a0300a0300a0300a0300a0200a0200a0250c0500c0500c0500c0500c0500c0400c0400c0400c0400c0300c0300c0300c0300c0200c0200c0200c020
011e00000c0500c0500c0500c0500c0400c0400c0400c0400c0300c0300c0300c0300c0200c0200c0200c0250c0500c0500c0500c0500c0400c0400c0400c0400c0300c0300c0300c0300c0200c0200c0200c025
011e00000a1540a1500a1500a1500a1400a1400a1400a1400a1300a1300a1300a1300a1200a1200a1200015400150001500015000150001400014000140001400013000130001300013000120001200012000125
000400002b1112c13133151351613616135161331512d1512b1512a1412a1312a1212a1112a1012a1012a1012a1012a1010010100101001010010100101001010010100101001010010100101001010010100101
000400001d1111f13133151351613616135161331512d1512b1512a1412a1312a1212a1112a1012a1012a1012a1012a1010010100101001010010100101001010010100101001010010100101001010010100101
001000002071020710207202072020730207302074020740207502075020760207600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002a750277502d7503275033740337403373033730337203372033710337100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e0020180501805018050180501804018040180401804018040180400e5500e5500c5500c5500e5500e5500f5500f5500f5500f5500f5500f5500f5400f5400f5400f5400f5300f5300f5300f5300f5200f520
011e00000f0500f0500f0500f0500f0500f0500f0500f0500f0400f0400f0400f0400f0400f0400f0400f0400f0300f0300f0300f0300f0300f0300f0300f0300f0200f0200f0200f0200f0200f0200f0200f025
011e00000815408150081500815008150081500815008150081400814008140081400814008140081400814008130081300813008130081300813008130081300812008120081200812008120081200812008120
011e002018050180501805018050180401804018040180400e5500e5500c5500c5500e5500e5500f5500f5500f5500f5500f5500f550115401154011540115401353013530135301353013520135201352013520
011e0000110501105011050110501104011040110401104011030110301103011030050500a0500a0400005000050000500005000050000400004000040000400003000030000300003016030160301603016030
000300002205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500002e6502c6501e550135500d550065500555004550045500455004550005000050000500005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 0b 0f 0c 44
00 0d 10 0e 44
00 0b 0f 0c 44
00 0d 10 0e 44
00 0b 0f 0c 44
00 19 10 0e 44
00 15 16 17 44
02 18 16 17 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
