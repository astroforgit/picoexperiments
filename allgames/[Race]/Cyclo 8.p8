pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--cyclo 8
--by nusan

camoffx = 0 camoffy = -64
goalcamx = 0 goalcamy = -64
camadvanx = 0

bikeframe = 0

flaganim = 0
score = 0
retries = 0
timer = 0

totalscore = 0
totalretries = 0
totaltimer = 0
totalleveldone = 0

bikefaceright = true
isdead = false
isfinish = false
restartafterfinish = false
isstarted = false

charx = 0
chary = 0
charx2 = 0
chary2 = 0
chardown = false

-- position of the last checkpoint
last_check_x = 0
last_check_y = 0
has_check = false

dbg_lastcheckidx = 0

-- physics settings :

-- nb of physics substeps
stepnb = 10
-- strengh of rebound
str_reflect = 1.1
str_gravity = 0.06
str_air = 0.99
str_wheel = 0.25
str_wheel_size = 1.0
str_link = 0.5
-- rotation of the bike 
-- according to arrow keys
str_bodyrot = 0.04

-- acceleration factor
base_speedlerp = 0.5
-- max speed front
base_speedfront = 0.18
-- max speed back
base_speedback = 0.03
base_frameadvfront = 0.3
base_frameadvback = 0.15

limit_col = 2.0
limit_wheel = 1.5

bodyrot = 0.0

playeridx = 1

currentlevel = 1
levelnb = 7

timernextlevel = 0
timernextlevel_dur = 30*7

timerlasteleport = 1000

zone = {}

cloudsx = {}
cloudsy = {}
cloudss = {}

-- map zone structure.
-- level is made of several zones
function zone.new (in_startx,in_starty,in_sizex,in_sizey)
	local set = {}
	set.startx = in_startx
	set.starty = in_starty
	set.sizex = in_sizex
	set.sizey = in_sizey
  return set
end

level = {}
    
-- level structure
function level.new (in_name,in_zkill,in_backy,in_camminx,in_cammaxx,in_camminy,in_cammaxy)
	local set = {}
	set.name = in_name
	set.zones = {}
	set.zonenb = 0
	set.zkill = in_zkill
	set.backy = in_backy
	set.camminx = in_camminx
	set.cammaxx = in_cammaxx
	set.camminy = in_camminy
	set.cammaxy = in_cammaxy
	set.startright = true
	return set
end

levels = {}

entity = {}
    
-- entity = the 2 wheels
function entity.new (in_x,in_y)
	local set = {}
	set.x = in_x
	set.y = in_y
	set.vx = 0.0
	set.vy = 0.0
	set.rot = 0.0
	set.vrot = 0.0
	set.isflying = true
	--set.lastcolx = set.x
	--set.lastcoly = set.y
	--set.lastcolnx = 0
	--set.lastcolny = 0
	set.link = nil
	set.linkside = 1
  return set
end

entities = {}

item = {}
itemnb = 0

item_apple = 1
item_checkpoint = 2
item_start = 3
item_finish = 4
item_teleport = 5
    
function item.new (in_x,in_y,in_type)
	local set = {}
	set.x = in_x
	set.y = in_y
	set.type = in_type
	set.active = true
	set.size = 8
  return set
end

items = {}

link = {}

-- a physic link between wheels
function link.new (ent1,ent2)
	local set = {}
	set.ent1 = ent1
	set.ent2 = ent2
	set.baselen = 8.0
	set.length = set.baselen
	set.dirx = 0.0
	set.diry = 0.0
  return set
end

link1 = link.new(1,2)

-- array to link sprite to colision
sdflink = {}
sdflink[1] = 1
sdflink[2] = 2
sdflink[3] = 3
sdflink[12] = 3
sdflink[6] = 4
sdflink[13] = 4
sdflink[8] = 5
sdflink[9] = 6
sdflink[10] = 7
sdflink[11+16] = 8
sdflink[0+16*3] = 9
sdflink[1+16*3] = 10
sdflink[2+16*3] = 11
sdflink[3+16*3] = 12
sdflink[4+16*3] = 13
sdflink[10+16*3] = 14
sdflink[11+16*3] = 15

function lerp(a,b,alpha)
	return a*(1.0-alpha)+b*alpha
end

function saturate(a)
	return max(0, min(1, a))
end

function blur_pass(insdf,outsdf)
	for i=1,14 do
		for j=1,14 do
			local idx = i+j*16
			local sum = 0
			local wei = 0
			for sx=-1,1 do	
				for sy=-1,1 do	
					local lwei = sqrt(sx*sx + sy*sy + 0.01)
					sum += insdf[idx + sx + sy*16] * lwei
					wei += lwei
				end
			end
			outsdf[idx] = sum / wei
		end
	end
end

-- this function is not used at runtime
-- it create a distance field in a 16x16 sprite
-- based on a 8x8 sprite colision
function gen_sdf(ix,iy,num)
	local rx = 8*ix
	local ry = 8*iy

	local wx = 2*8*(num%8)
	local wy = 2*8*flr(num/8) + 8*12

	-- init to 0
	-- we will ping-pong
	-- beetween sdf and sdf2
	local sdf = {}
	local sdf2 = {}
	for i=0,15 do
		for j=0,15 do
			sdf[i+j*16] = 0.0
		end
	end

	-- fill the sdf sprite with the base sprite colision
	for i=0,7 do
		for j=0,7 do
			local sc = sget(rx+i, ry+j, 8)
			local idx = i+4+(j+4)*16
			-- 3 is the transparent color
			if(sc!=3) then
				sdf[idx] = 15.0
			else
				sdf[idx] = 0.0
			end
			--sset(wx+i + 4, wy+j + 4, sc)
		end
	end

	-- first propagation of distance field
	-- along x axis
	for i=0,15 do
		for j=0,15 do
			local idx = i+j*16
			-- we search the nearest colision along x
			local mindist = 15.0
			for s=0,15 do	
				-- if we find a colision on the same row
				if(sdf[s+j*16] >= 8.0) then
					-- set the distance
					local curdist = abs(s-i)
					mindist = min(mindist, curdist)
				end
			end
			sdf2[idx] = mindist
		end
	end

	-- second propagation of distance field
	-- along y axis
	for i=0,15 do
		for j=0,15 do
			local idx = i+j*16
			-- we search the nearest colision along x,y
			local mindist = 15.0
			for s=0,15 do	
				-- we compute the final distance
				-- with pythagore
				local disty = abs(s-j)
				local distx = sdf2[i+s*16]
				local curdist = sqrt(distx*distx+disty*disty + 0.001)
				mindist = min(mindist, curdist)
			end
			sdf[idx] = mindist
		end
	end

	--blur_pass(sdf,sdf2)
	--blur_pass(sdf2,sdf)

	-- we encode the final sdf
	-- in sprites
	-- we want a maximum range of 4
	-- because the wheel is of radius 4
	for i=0,15 do
		for j=0,15 do
			local idx = i+j*16
			sset(wx+i, wy+j, max(0,min(flr(15.0-(sdf[idx]-1)*4.0),15)))
			--sset(wx+i, wy+j, max(0,min(flr(sdf[idx]),15)))
		end
	end

	-- we save everything in the cartridge
	cstore()
end

function gen_all_sdf()
	-- here is the list of all sprites
	-- that will generate a sdf
	gen_sdf(0,1,0)
	gen_sdf(1,0,1)
	gen_sdf(2,0,2)
	gen_sdf(3,0,3)
	gen_sdf(6,0,4)
	gen_sdf(8,0,5)
	gen_sdf(9,0,6)
	gen_sdf(10,0,7)
	gen_sdf(11,1,8)
	gen_sdf(0,3,9)
	gen_sdf(1,3,10)
	gen_sdf(2,3,11)
	gen_sdf(3,3,12)
	gen_sdf(4,3,13)
	gen_sdf(10,3,14)
	gen_sdf(11,3,15)
end

function create_levels()

	local l=1
	levels[l] = level.new("long road", 256, 144, 512,896,-1000,128)
	levels[l].zones[1] = zone.new(64,16,64,16)
	levels[l].zonenb = 1

	l=2
	levels[l] = level.new("easy wheely", 125, 16, 0,400,-1000,58)
	levels[l].zones[1] = zone.new(0,0,64,16)
	levels[l].zones[2] = zone.new(32,16,32,4)
	levels[l].zonenb = 2

	l=3
	levels[l] = level.new("central pit", 256, 144, 0,128,-1000,128)
	levels[l].zones[1] = zone.new(0,16,32,16)
	levels[l].zonenb = 1

	l=4
	levels[l] = level.new("spiral", 125, 16, 834,896,2,2)
	levels[l].zones[1] = zone.new(104,0,24,16)
	levels[l].zonenb = 1

	l=5
	levels[l] = level.new("sky fall", 125, 16, 512,700,-1000,0)
	levels[l].zones[1] = zone.new(64,0,40,16)
	levels[l].zonenb = 1

	l=6
	levels[l] = level.new("here and there",386, 272, 384,896,-1000,256)
	levels[l].zones[1] = zone.new(48,32,64,16)
	levels[l].zones[2] = zone.new(112,32,16,8)
	levels[l].zonenb = 2
	levels[l].startright = false

	l=7
	levels[l] = level.new("ninja rise",386, 256, 0,385,-1000,256)
	levels[l].zones[1] = zone.new(0,32,48,16)
	levels[l].zones[2] = zone.new(32,20,32,12)
	levels[l].zonenb = 2

end

function _init()
	-- uncomment the next line
	-- to regenerate sdf sprite
	--gen_all_sdf()

	pal={5,13,15,11,9,6,7,7,14,10,7,7,7,6,15,7}

	create_entities()
	create_levels()
	create_clouds()
end

function create_clouds()
	local i = 1
	while(i <= 60) do
		cloudsx[i] = rnd(10)
		cloudsy[i] = rnd(5)
		cloudss[i] = rnd(10)
		i+=1
	end
end

function start_level(levelidx)
	currentlevel = levelidx

	items = {}
	itemnb = 0
	has_check = false
	bikefaceright = levels[currentlevel].startright
	
	find_replace_items()
	reset_camera()
	reset_player()
	score = 0
	retries = 0
	timer = 0
	restartafterfinish = false

	sfx(7,2)
end

function find_replace_items_zone(startx, starty, sizex, sizey)
	for i=startx,startx+sizex-1 do
		for j=starty,starty+sizey-1 do

			local col = mget(i,j)
			local flags = fget(col)

			local itemtype = 0
			if(band(flags, 4)>0) then
				itemtype = item_teleport
				if(col == 56) then
					itemtype = item_apple
				end	
			end
			if(band(flags, 8)>0) then
				itemtype = item_checkpoint
				if(col == 67) then
					itemtype = item_start
					last_check_x = 8*i+4
					last_check_y = 8*j+4
				end
				if(col == 68) then
					itemtype = item_finish
				end
			end

			-- if we found an item
			if(itemtype != 0) then
				itemnb += 1
				items[itemnb] = item.new(i*8+3.5,j*8+3.5, itemtype)

				-- remove from the map
				mset(i,j,0)
			end

		end
	end
end

-- find all items
-- insert in the array
-- remove them from the map
function find_replace_items()

	-- here is the list of zones
	-- that make the level
	for i=1,levels[currentlevel].zonenb do

		local curzone = levels[currentlevel].zones[i]
		find_replace_items_zone(curzone.startx,curzone.starty,curzone.sizex,curzone.sizey)

	end
	
	--find_replace_items_zone(0,0,128,16)
	--find_replace_items_zone(32,16,64,8)

end

-- display the level
function draw_map(flags)

	-- here is the list of zones
	-- that make the level

	for i=1,levels[currentlevel].zonenb do

		local curzone = levels[currentlevel].zones[i]
		map(curzone.startx,curzone.starty,curzone.startx*8,curzone.starty*8,curzone.sizex,curzone.sizey, flags)

	end

	--map(0,0,0,0,128,16,flags)
	--map(32,16,32*8,16*8,64,8,flags)
end

-- reset player state
-- after a retry
function reset_player()
	entities[playeridx].x = last_check_x
	entities[playeridx].y = last_check_y
	entities[playeridx].vx = 0
	entities[playeridx].vy = 0
	entities[playeridx].vrot = 0

	entities[playeridx+1].x = last_check_x+8
	entities[playeridx+1].y = last_check_y
	entities[playeridx+1].vx = 0
	entities[playeridx+1].vy = 0
	entities[playeridx+1].vrot = 0

	--camoffx = 0 camoffy = -64
	--goalcamx = 0 goalcamy = -64

	--bikefaceright = true
	isdead = false

	if(isfinish) then
		restartafterfinish = true
	end
	if(not isfinish) then
		retries += 1
	end
end

function reset_camera()

	camoffx = last_check_x-16 -- -64
	camoffy = last_check_y-64 -- -96
	goalcamx = camoffx
	goalcamy = camoffy
end

-- create the 2 wheels
-- and init some variables
function create_entities()
	entities[1] = entity.new(0,0)
	entities[2] = entity.new(0+8,0)
	entities[1].link = link1
	entities[1].linkside = 1
	entities[2].link = link1
	entities[2].linkside = -1
end

-- get the value of sdf
-- at location lx,ly
-- according to a sprite
-- chosen at an offset ox,oy
function get_sdf(lx,ly,ox,oy)
	local sx = flr((lx+ox)/8)
	local sy = flr((ly+oy)/8)

	-- get the sprite at the offset
	local col = mget((lx+ox)/8, (ly+oy)/8)
	local flags = fget(col)
	local isc = band(flags, 1)

	-- check if its a colision
	if(isc==0) then
		return 0
	end

	-- check if its in the level zone
	local inlevelzone = false
	for i=1,levels[currentlevel].zonenb do

		local curzone = levels[currentlevel].zones[i]
		if((sx>=curzone.startx) and (sx<(curzone.startx+curzone.sizex))) then
			if((sy>=curzone.starty) and (sy<(curzone.starty+curzone.sizey))) then
				inlevelzone = true
				break
			end
		end
	end
	if(not inlevelzone) then
		return 0
	end

	-- get the colision profile
	local sdfval = sdflink[col];
	-- if none is found, use the full square
	if(sdfval == nil) then sdfval = 0 end

	-- proper coordinates in sdf
	local wx = 2*8*(sdfval%8) + lx-sx*8 + 4
	local wy = 2*8*flr(sdfval/8) + 8*12 + ly-sy*8 + 4

	-- get distance
	local dist = sget(wx, wy)

	return dist
end

-- get the combined sdf
-- of the 4 closest cells
function is_pointcol(lx,ly)

	local v0 = get_sdf(lx,ly,-3,-3)
	local v1 = get_sdf(lx,ly, 4,-3)
	local v2 = get_sdf(lx,ly, 4, 4)
	local v3 = get_sdf(lx,ly,-3, 4)

	return max(max(v0,v1),max(v2,v3))
end

-- get the colision distance
-- and surface normal
function is_coliding(lx,ly)

	-- we take the 4 points
	-- at the center of the wheel
	local v0 = is_pointcol(lx-0.5,ly-0.5)
	local v1 = is_pointcol(lx+0.5,ly-0.5)
	local v2 = is_pointcol(lx+0.5,ly+0.5)
	local v3 = is_pointcol(lx-0.5,ly+0.5)

	-- we iterpolate the distance
	-- with bilinear
	local llx = lx-0.5-flr(lx-0.5)
	local lly = ly-0.5-flr(ly-0.5)
	local lerp1 = (1.0-llx)*v0 + llx*v1
	local lerp2 = (1.0-llx)*v3 + llx*v2
	local final = (1.0-lly)*lerp1 + lly*lerp2

	-- the normal is a gradient
	local norx = (v0-v1 + v3-v2)*0.5
	local nory = (v0-v3 + v1-v2)*0.5

	-- we ensure normal is normalized
	local len = sqrt(norx*norx+nory*nory + 0.001)
	norx /= len
	nory /= len
	
	--local final = is_pointcol(lx,ly)

	return final, norx, nory
end

-- this take a velocity vector
-- and reflect it by a normal
-- a damping is applyed of the reflection
function reflect(vx, vy, nx, ny)

	local dot = vx*nx + vy*ny
	local bx = dot*nx
	local by = dot*ny

	local rx = vx-str_reflect*bx
	local ry = vy-str_reflect*by

	-- we play some colision sounds
	-- when both vector are opposite
	if(dot<-0.8) then
		sfx(0,3)
	else
		if(dot<-0.2) then
			sfx(6,3)
		end
	end

	return rx, ry
end

-- this update the state of a link
-- between 2 wheels
function up_link(link)

	local dirx = entities[link.ent2].x - entities[link.ent1].x
	local diry = entities[link.ent2].y - entities[link.ent1].y

	link.length = sqrt( dirx*dirx + diry*diry + 0.01)
	link.dirx = dirx/link.length
	link.diry = diry/link.length
end

-- pre physic update of a wheel
function up_start_entity(ent)

	-- apply gravity
	ent.vy += str_gravity
	ent.isflying = true

end

-- do one step of physic on a wheel
function up_step_entity(ent)

	-- apply link force
	if(ent.link != nil) then

		-- force according to base length
		local flink = (ent.link.length - ent.link.baselen) * str_link

		-- add the force
		ent.vx += ent.link.dirx * ent.linkside * flink
		ent.vy += ent.link.diry * ent.linkside * flink

		-- apply the rotation
		-- due to the body
		-- if not on the ground ?
		--if(ent.isflying) then
		if(true) then
			-- force perpendicular
			-- to the link axis
			local perpx = ent.link.diry
			local perpy = -ent.link.dirx

			ent.vx += perpx * bodyrot/stepnb * ent.linkside
			ent.vy += perpy * bodyrot/stepnb * ent.linkside
		end
	end

	-- we test if the new location
	-- is coliding
	local x2 = ent.x + ent.vx/stepnb
	local y2 = ent.y + ent.vy/stepnb

	iscol,norx,nory = is_coliding(x2,y2)

	-- if coliding
	if iscol > limit_col then

		-- debug data
		--ent.lastcolx = ent.x
		--ent.lastcoly = ent.y
		--ent.lastcolnx = norx
		--ent.lastcolny = nory

		-- reflect the velocity by
		-- the surface normal
		ent.vx, ent.vy = reflect(ent.vx,ent.vy,norx,nory)

		-- ensure we are not inside the colision
		ent.x = ent.x + norx * (iscol-limit_col)
		ent.y = ent.y + nory * (iscol-limit_col)
	end

	-- apply the motion
	ent.x = ent.x + ent.vx/stepnb
	ent.y = ent.y + ent.vy/stepnb

	-- if wheel is near the ground
	-- we apply the wheel force
	if iscol > limit_wheel then

		-- force direction
		-- perpendicular to the
		-- surface normal
		local perpx = nory
		local perpy = -norx

		local angfac = 3.1415 * 8 * str_wheel_size
		-- transform wheel speed to force
		local angrot = ent.vrot * angfac
		local wantx = angrot * perpx
		local wanty = angrot * perpy

		local distfactor = 1.0--saturate((iscol - limit_wheel)*1.0)

		-- interpolate between
		-- wheel motion
		-- and entity motion
		local lerpx = lerp(ent.vx, wantx, str_wheel * distfactor)
		local lerpy = lerp(ent.vy, wanty, str_wheel * distfactor)
		
		ent.vx = lerpx
		ent.vy = lerpy

		-- get the wheel speed along the surface
		local dotperp = (ent.vx*perpx + ent.vy*perpy)

		-- the new wheel rotation is
		-- the speed along the surface
		ent.vrot = dotperp / angfac

		-- the wheel touch the ground
		ent.isflying = false
	end
end

-- post physic update of a wheel
function up_end_entity(ent)
	-- apply air friction
	if(not ent.isflying) then
		ent.vx *= str_air
		ent.vy *= str_air
	end

	-- make the wheel turn
	ent.rot += ent.vrot
	-- we could apply a wheel friction
	--ent.vrot *= 0.94
end

-- check if an item
-- is near the player
function check_item(it)

	-- need to be carefull
	-- with squaring because of overflow
	-- so we first divide by the item size
	-- before squaring
	local madx = (it.x - charx) / it.size
	local mady = (it.y - chary) / it.size
	local sqrlen = (madx*madx + mady*mady)

	-- if colision with an item
	if((not isdead) and (sqrlen < 1))  then
		-- apples
		if((it.type == item_apple) and it.active) then
			if(not restartafterfinish) then
				it.active = false
				score += 1
				if(isfinish) then totalscore += 1 end -- special case
				sfx(3,3)
			end
		end
		-- teleports
		if((it.type == item_teleport) and it.active) then
			if((not isfinish) and (not isdead)) then
				sfx(7,2)
				retries -= 1 -- free retry
				timerlasteleport = 0
				reset_player()
			end
		end
		-- checkpoints
		if((it.type == item_checkpoint) or (it.type == item_finish)) then
			if(it.active) then
				it.active = false
				last_check_x = it.x
				last_check_y = it.y
				has_check = true

				if(it.type == item_finish) then
					isfinish = true
					-- cumul total values
					totalscore += score
					totaltimer += timer
					totalretries += retries
					totalleveldone += 1
					sfx(5,2)
				else
					sfx(7,2)
				end
			end
		end
	end
end

-- debug function
-- find the next checkpoint in the list of item

function find_next_checkpoint()
	dbg_curcheckcount = 1
	dbg_checkfound = false
	foreach(items, loop_next_checkpoint)
	if(dbg_checkfound) then
		dbg_lastcheckidx += 1
		retries -= 1
		reset_player()
	else
		dbg_lastcheckidx = 0
	end
end

function loop_next_checkpoint(it)

	local checkfound = false
	if(it.type == item_checkpoint) then
		if(dbg_curcheckcount == dbg_lastcheckidx+1) then
			it.active = true
			last_check_x = it.x
			last_check_y = it.y
			has_check = true
			dbg_checkfound = true
		end
		dbg_curcheckcount += 1
	end
end


-- main update function
function _update()

	-- start menu
	if(not isstarted) then

		-- start the game
		if(btnp(4)) then
			isstarted = true
			start_level(currentlevel)
		end

		-- change current level
		if(btnp(0) or btnp(3)) then
			currentlevel -= 1
			if(currentlevel<=0) then
				currentlevel = levelnb
			end
			sfx(0,3)
		end
		if(btnp(1) or btnp(2)) then
			currentlevel += 1
			if(currentlevel>levelnb) then
				currentlevel = 1
			end
			sfx(0,3)
		end

		-- debug
		--isstarted = true

		return
	end

	-- handle going to the next level
	if(isfinish) then
		
		if(timernextlevel > timernextlevel_dur) then

			if(currentlevel != levelnb) then
				isfinish = false
				start_level(currentlevel +1)
				timernextlevel = 0
			end
		end

		timernextlevel += 1

	end
	
	bodyrot = 0.0

	-- player control
	if((not isdead) and (not isfinish)) then

		-- flip button (c)
		if(btnp(4)) then
			bikefaceright = not bikefaceright
			sfx(8,3)
		end

		local speedlerp = base_speedlerp
		local speedfront = base_speedfront
		local speedback = base_speedback
		local frameadvfront = base_frameadvfront
		local frameadvback = base_frameadvback
		local controlwheel = playeridx
		local otherwheel = playeridx + 1
		local wheelside = 1.0
		-- invert all values if bike face left
		if(not bikefaceright) then
			local tmp = speedback
			speedback = speedfront
			speedfront = tmp

			local tmp = frameadvfront
			frameadvfront = frameadvback
			frameadvback = tmp

			local tmp = otherwheel
			otherwheel = controlwheel
			controlwheel = tmp

			wheelside = -1.0
		end

		-- button left
		if(btn(0)) then
			-- make the body rotate
			bodyrot -= str_bodyrot			
		end
		-- button right
		if(btn(1)) then
			-- make the body rotate
			bodyrot += str_bodyrot			
		end
		-- button up
		if(btn(2)) then
			-- only the back wheel is set in motion
			entities[playeridx].vrot = lerp(entities[controlwheel].vrot, -base_speedfront * wheelside, speedlerp)
			--entities[playeridx].vrot = lerp(entities[otherwheel].vrot, -base_speedfront * wheelside, speedlerp)
			bikeframe -= base_frameadvfront
		end
		-- button down
		if(btn(3)) then			
			-- both wheels are slowed
			entities[playeridx].vrot = lerp(entities[controlwheel].vrot, base_speedback * wheelside, speedlerp)
			entities[playeridx].vrot = lerp(entities[otherwheel].vrot, base_speedback * wheelside, speedlerp)
			bikeframe += base_frameadvback
		end
		
	end

	-- update the physics
	-- using several substep
	-- to improve colision
	foreach(entities, up_start_entity)
	for step=0,stepnb-1 do
		-- update links
		up_link(link1)
		-- update wheels
		foreach(entities, up_step_entity)
	end
	foreach(entities, up_end_entity)

	local isdown = false

	-- compute the body location
	-- according to the 2 wheels
	-- this is the upper body
	charx, chary, chardown = get_bike_rot(entities[1],entities[2], 4.0)
	-- this is the lower body
	charx2, chary2, isdown = get_bike_rot(entities[1],entities[2], 1.0)

	-- make upper body a bit closer
	-- to the lower body
	charx += (charx2-charx)*0.5

	-- check the upper body colision
	local coldist,colnx,colny = is_coliding(charx, chary)
	if(coldist > 1.8) then
		-- if there is a colision
		-- the player is dead
		if(not isdead) then
			isdead = true
			if(not isfinish) then
				sfx(4,2)
			end
		end
	end

	-- check items colision
	foreach(items, check_item)

	local needkillplayer = false
	-- check the killing floor
	if(entities[playeridx].y>levels[currentlevel].zkill) then
		needkillplayer = true
	end

	-- check the killing camera limit
	if(entities[playeridx].x>levels[currentlevel].cammaxx+128) then
		needkillplayer = true
	end
	if(entities[playeridx].x<levels[currentlevel].camminx) then
		needkillplayer = true
	end
	if(entities[playeridx].y>levels[currentlevel].cammaxy+128) then
		needkillplayer = true
	end
	if(entities[playeridx].y<levels[currentlevel].camminy) then
		needkillplayer = true
	end
	
	if(needkillplayer) then
		if((not isfinish) and (not isdead)) then
			sfx(4,2)
		end
		reset_player()
	end

	-- check the retry button (v)
	if(btnp(5) and (not isfinish)) then
		sfx(7,2)
		reset_player()
	end

	-- debug cheating :
	if(false) then
		if(btnp(5,1)) then
			find_next_checkpoint()
		end
	end

	-- update the camera :

	-- make the camer look back
	--if(entities[playeridx].vx<-0.8) then
	if(not bikefaceright) then
		camadvanx = -32
	end
	-- make the camer look front
	--if(entities[playeridx].vx>0.8) then
	if(bikefaceright) then
		camadvanx = 32
	end

	-- update the camera goal
	goalcamx = goalcamx*0.9 + (entities[playeridx].x-64+camadvanx)*0.1
	
	-- in y there is a safe zone
	if(camoffy > entities[playeridx].y-64+32) then
		goalcamy = entities[playeridx].y-64+32
	end
	if(camoffy < entities[playeridx].y-64-32) then
	 goalcamy = entities[playeridx].y-64-32
	end
	-- or else the camera is only updated
	-- when the wheel touch ground
	if not entities[playeridx].isflying then
	 goalcamy = entities[playeridx].y-64
	end

	-- clamp the camera goal to the level limit
	goalcamx = max(goalcamx, levels[currentlevel].camminx)
	goalcamx = min(goalcamx, levels[currentlevel].cammaxx)

	goalcamy = max(goalcamy, levels[currentlevel].camminy)
	goalcamy = min(goalcamy, levels[currentlevel].cammaxy)

	-- the camera location is lerped
	--camoffx = camoffx*0.8 + goalcamx*0.2
	--camoffy = camoffy*0.7 + goalcamy*0.3
	camoffx = lerp(camoffx, goalcamx, 0.2)
	camoffy = lerp(camoffy, goalcamy, 0.3)

	-- increment the timer
	if(not isfinish) then
		timer += 1
	end
		
end

-- draw a wheel entity
function draw_entity(ent)

	local base = 80
	-- the wheel sprite
	-- depend on the wheel rotation
	local	rfr = flr(-ent.rot*4*5)%5
	if(rfr<0) rfr+=5
	local cspr = base+rfr

	--if(abs(ent.vrot) > 0.14) then
	if(false) then
		rfr = flr(-ent.rot*3)%3
		if(rfr<0) rfr+=3
		cspr = base+5+rfr
	end	

	-- to avoid the wheel appearing
	-- to rotate backward
	-- if the speed is too strong
	-- we rotate slower but skip
	-- a frame each time
	if(abs(ent.vrot) > 0.14) then
		rfr = flr(-ent.rot*3)%5
		if(rfr<0) rfr+=5
		rfr *= 2
		if(rfr>5) rfr-=5
		cspr = base+rfr
	end

	spr(cspr,ent.x-3.5,ent.y-3.5,1,1)

	--line(ent.lastcolx,ent.lastcoly,ent.lastcolx+ent.lastcolnx*15,ent.lastcoly+ent.lastcolny*15,8)
	--line(ent.x,ent.y,ent.x+ent.vx*15,ent.y+ent.vy*15,11)

	--circ(ent.lastcolx,ent.lastcoly,3,8)
end

-- debug function to draw
-- the sdf colision
-- around the player
function draw_col()
	local x = entities[playeridx].x
	local y = entities[playeridx].y
	for i=flr(x)-15,flr(x)+15 do
		for j=flr(y)-15,flr(y)+15 do
			local mi = (i%2) == 0
			local mj = (j%2) == 0
			if(mi or mj or true) then
				local mycol = is_pointcol(i,j)
				if(mycol>2.0) then
					pset(i,j, mycol)
				end
				--pset(i,j, mycol)
			end
		end
	end
end

-- take 2 wheel and give
-- a point between
-- with an perpendicular offset
function get_bike_rot(ent1, ent2, offset)

	local dirx = ent2.x - ent1.x
	local diry = ent2.y - ent1.y

	-- average to get the center
	local centx = ent1.x + dirx * 0.5
	local centy = ent1.y + diry * 0.5

	-- normalize the direction
	local length = sqrt( dirx*dirx + diry*diry + 0.01)
	dirx = dirx/length
	diry = diry/length

	-- get the perpendicular
	local perpx = diry
	local perpy = -dirx

	-- offset the point
	-- along the perpendicular
	centx += perpx * offset
	centy += perpy * offset

	-- we want to know
	-- is the point is below the bike
	local isdown = false
	if(perpy > 0.5) then isdown = true end

	return centx, centy, isdown
end

function centertext(posx,posy,text,col)

	local sposx = posx - #text * 2
	local sposy = posy
	print(text, sposx+1,sposy,0)
	print(text, sposx-1,sposy,0)
	print(text, sposx,sposy+1,0)
	print(text, sposx,sposy-1,0)
	print(text, sposx,sposy,col)
end

-- draw an item icon (apple, checkpoint)
function draw_item(it)

	-- only apples can be picked
	local hide = false
	if((it.type == item_apple) and (not it.active)) then
		hide = true
	end

	if(it.type == item_start) then
		hide = true
	end

	if(not hide) then
		local sprite = 56

		if(it.type == item_teleport) then
			sprite = 103 + (flaganim%3)
		end

		if((it.type == item_checkpoint) or (it.type == item_finish)) then
			sprite = 64 + (flaganim%3)

			-- change the flag pole color
			local flagcolor = 12
			if(it.active) then
				if(it.type == item_finish) then
					flagcolor = 11
				else
					flagcolor = 8
				end
			end

			line(it.x -1, it.y-3, it.x -1, it.y + 12, flagcolor)			
		end

		spr(sprite,it.x-3.5,it.y-3.5,1,1)

		--line(it.x, it.y, charx, chary, 12)
	end
end

-- draw the introduction and victory big flag
function draw_big_flag(text, finishx, finishy, col)

	--line(finishx-1,finishy,finishx-1,finishy+15,8)
	--line(finishx+64,finishy,finishx+64,finishy+15,8)
	--line(finishx-1,finishy-1,finishx+64,finishy-1,8)
	--line(finishx-1,finishy+16,finishx+64,finishy+16,8)
	rectfill(finishx,finishy,finishx+63,finishy+15,0)
	for i=0,31 do
		local tmpx = finishx+(i%16)*4
		local tmpy = finishy + (1-i%2) * 4 + flr(i/16)*8
		rectfill(tmpx,tmpy,tmpx+3,tmpy+3,6)
	end

	centertext(finishx+32,finishy+6,text,col)

	--pal(7,10)

	local sprite = (64 + (flr(flaganim*0.7)%3))
	--spr(sprite,finishx-6,finishy,1,1,true)
	--spr(sprite,finishx-2+64,finishy,1,1,false)
	sspr((sprite-64)*8,4*8,8,8,finishx-20,finishy-4,32,32,true)
	sspr((sprite-64)*8,4*8,8,8,finishx-16+64,finishy-4,32,32,false)		

	--pal()
end

function gettimestr(val)
	-- transform timer to min:sec:dec
	local t_cent = flr(val*10/30)%10
	local t_sec = flr(val/30)%60
	local t_min = flr(val/(30*60))

	local fill_sec = ""
	if(t_sec<10) then fill_sec = "0" end

	return t_min..":"..fill_sec..t_sec..":"..t_cent
end

function clampy(v)
	return v--return max(0,min(128,v))
end

function swap(x1,x2)
	return x2,x1
end

function rectlight(x,y,sx,sy,c)
	local mx = min(x,sx)
	local ex = max(x,sx)
	for i=mx,ex do
		pset(i,y,pal[pget(i,y)+1])
	end
end

function otri(x1,y1,x2,y2,x3,y3,c)

	if y2<y1 then
		if y3<y2 then
			y1,y3=swap(y1,y3)
			x1,x3=swap(x1,x3)
		else
			y1,y2=swap(y1,y2)
			x1,x2=swap(x1,x2)
		end
	else
		if y3<y1 then
			y1,y3=swap(y1,y3)
			x1,x3=swap(x1,x3)
		end
	end

	y1 += 0.001

	local miny = min(y2,y3)
	local maxy = max(y2,y3)

	local fx = x2
	if y2<y3 then
		fx = x3
	end

	local cl_y1 = (clampy(y1))
	local cl_miny = (clampy(miny))
	local cl_maxy = (clampy(maxy))

	local steps = (x3-x1)/(y3-y1)
	local stepe = (x2-x1)/(y2-y1)

	local sx = steps*(cl_y1-y1)+x1
	local ex = stepe*(cl_y1-y1)+x1
		
	for y=cl_y1,cl_miny do
		rectlight(sx,y,ex,y,c)
		sx += steps
		ex += stepe
	end

	sx = steps*(miny-y1)+x1
	ex = stepe*(miny-y1)+x1

	local df = 1/(maxy-miny)

	local step2s = (fx-sx) * df
	local step2e = (fx-ex) * df

	local sx2 = sx + step2s*(cl_miny-miny)
	local ex2 = ex + step2e*(cl_miny-miny)

	for y=cl_miny,cl_maxy do
		rectlight(sx2,y,ex2,y,c)
		sx2 += step2s
		ex2 += step2e
	end
end

function wtri(x1,y1,x2,y2,x3,y3,c)
	line(x1,y1,x2,y2,c)
	line(x3,y3,x2,y2,c)
	line(x1,y1,x3,y3,c)
end

function lamp(lampx,lampy,lampdirx,lampdiry,lampperpx,lampperpy,sidefac,lamplen,lampwid)

	local lampp1x = lampx + lampdirx * lamplen*sidefac + lampperpx * lampwid
	local lampp1y = lampy + lampdiry * lamplen*sidefac + lampperpy * lampwid
	local lampp2x = lampx + lampdirx * lamplen*sidefac - lampperpx * lampwid
	local lampp2y = lampy + lampdiry * lamplen*sidefac - lampperpy * lampwid
	otri(flr(lampx),flr(lampy), flr(lampp1x), flr(lampp1y), flr(lampp2x), flr(lampp2y), 10)

end

-- main draw function
function _draw()

	cls()
		
	camera(0, 0)

	-- black will not be translucent
	-- dark green will be
	palt(0,false)
	palt(3,true)
	palt(4,false)

	-- start menu
	if(not isstarted) then

		rectfill(0,0,127,127,1)

		local c = 16

		centertext(64,c,"nusan present",5)
		draw_big_flag("cyclo 8",32,c+12,10)

		c = 58
		centertext(32,c,"up = gas",7)
		centertext(32,c+8,"down = brake",7)
		centertext(64,c+16,"left-right = rotate the bike",7)
		centertext(96,c,"c = flip bike",7)
		centertext(96,c+8,"v = retry",7)

		local flipcol = 6+flr(flaganim*0.5)%2

		c = 94
		centertext(64,c,"starting level :",7)
		centertext(64,c+8,"< "..currentlevel.." - "..levels[currentlevel].name.." >",8)
		centertext(64,c+18,"press c to start",flipcol)

		flaganim += 0.2

		return
	end

	-- background color
	rectfill(0,0,127,127,4)
	
	camera(camoffx, camoffy)

	local treeoff = levels[currentlevel].backy

	-- draw the cloud in background :

	local paral2x = (camoffx)*0.75
	local paral2y = (camoffy-treeoff)*0.75 + treeoff

	i = 1
	while(i <= 30) do
		circfill(paral2x + i * 20 + cloudsx[i], paral2y + 45 + cloudsy[i], 10+cloudss[i], 5)
		i += 1
	end

	i = 1
	while(i <= 30) do
		local b = i-30
		circfill(paral2x + i * 20 + cloudsx[i], paral2y + 62 + cloudsy[i], 10+cloudss[i], 4)
		i += 1
	end

	-- draw the trees :

	local paralx = (camoffx)*0.5
	local paraly = (camoffy-treeoff)*0.5+treeoff
	palt(3,false)
	palt(4,true)
	-- draw the bottom of the trees
	rectfill(camoffx,paraly+64+8,camoffx+128,camoffy+128,2)	

	paralx = paralx%128+flr(paralx/128)*256
	-- draw 2 series of trees
	-- warping infinitly
	map(112,40,paralx,paraly+16,16,8)
	map(112,40,paralx+128,paraly+16,16,8)
	palt(3,true)
	palt(4,false)
	
	-- draw the bottom line
	-- in black to mask bottom
	-- of the level
	rectfill(camoffx,108+treeoff,camoffx+128,110+treeoff,12)
	rectfill(camoffx,109+treeoff,camoffx+128,camoffy+treeoff+128,0)
	
	--draw_col()

	-- draw the all level
	draw_map(0)

	foreach(items, draw_item)

	--draw_entity(entities[1])
	--draw_entity(entities[2])
	foreach(entities, draw_entity)

	-- draw the player :

	local cspr = flr(-bikeframe)%4
	if(cspr<0) cspr+=4
	if(isdead) cspr = 4

	local bodyadv = 0
	if(bodyrot>0) then bodyadv = 1 end
	if(bodyrot<0) then bodyadv = -1 end

	local cspr2 = cspr+16

	if(chardown) then
		cspr = 5
		if(isdead) cspr = 6
	end

	-- player lower body
	spr(96+cspr2,charx2-3.5,chary2-4.5,1,1,not bikefaceright)
	-- player upper body
	spr(96+cspr,charx-3.5 + bodyadv * 2,chary-6,1,1,not bikefaceright)

	local wheelidx = 1
	local sidefac = -1
	if(bikefaceright) then
		wheelidx = 2
		sidefac = 1
	end
	
	local lampdirx = entities[playeridx].link.dirx
	local lampdiry = entities[playeridx].link.diry
	local lampperpx = lampdiry
	local lampperpy = -lampdirx
	local lampx = entities[wheelidx].x + lampperpx*4 + lampdirx * sidefac * 2
	local lampy = entities[wheelidx].y + lampperpy*4 + lampdiry * sidefac * 2

	lamp(lampx,lampy,lampdirx,lampdiry,lampperpx,lampperpy,sidefac,20,10)
	--lamp(lampx,lampy,lampdirx,lampdiry,lampperpx,lampperpy,sidefac,10,5)
	--lamp(lampx,lampy,lampdirx,lampdiry,lampperpx,lampperpy,sidefac,5,2)
	circ(flr(lampx),flr(lampy),1,1)
	pset(flr(lampx),flr(lampy),7)
	
	-- draw the foreground part of the level
	draw_map(bnot(0x2))

	--otri(flr(lampx),flr(lampy), flr(lampp1x), flr(lampp1y), flr(lampp2x), flr(lampp2y), 10)

	--circfill(charx,chary,1, 11)

	--draw_col()
	
	camera(0, 0)

	-- display hud
	if(true) then

		if(timerlasteleport < 30) then
			if((timerlasteleport % 4)<2) then
				centertext(64,64,"teleport",12)
			end
			timerlasteleport += 1
		end

		-- handle going to the next level
		if(isfinish) then
			
			local progress = saturate((timernextlevel/timernextlevel_dur - 0.3)/0.5)
			rectfill(-1,0,128*progress-1,128,1)

			if(progress > 0.9) then
				if(currentlevel>=levelnb) then
					local c = 36

					centertext(64,c,"nusan present",5)
					draw_big_flag("cyclo 8",32,c+12,10)

					centertext(66,72,"thanks for playing",7)
				else
					centertext(64,64,"next level :",7)
					centertext(64,74,(currentlevel+1).." - "..levels[currentlevel+1].name,7)	
				end	
			end

			centertext(64,14,"total over "..totalleveldone.. " levels",12)
			centertext(22,22,"retries:"..totalretries,12)
			centertext(64,24,"score:"..totalscore,12)
			centertext(112,22,gettimestr(totaltimer),12)

		end

		centertext(22,4,"retries:"..retries,8)
		centertext(64,2,"score:"..score,8)
		centertext(112,4,gettimestr(timer),8)

		if(isdead and (not isfinish)) then
			centertext(64,20,"you are dead",8)
			centertext(64,28,"press v to retry",8)
		end

		if(isfinish) then
			draw_big_flag("victory",32,90,8)
		end
	end


	-- debug draw values
	if(false) then
		--[[print(flr(entities[playeridx].x),0,112,4)
		print(flr(entities[playeridx].y),0,120,4)

		print(entities[playeridx].vrot,24,112,4)
		print(entities[playeridx].vx,24,120,4)

		print(flr(camoffx),64,112,4)
		print(flr(camoffy),64,120,4)]]--
		print("cpu "..stat(1),96,112,7)
	end

	flaganim += 0.2
end
__gfx__
333333337733333333333333333333331110d100001d011133333333333333333333337773333333333333377777777733333333333333331000000000110001
33333333667733333333333333333333d61010d11d01016d33333333333333333333776667333333333333766666666633333333333333331100000111111011
33333333d66677333333333333333333dd11016dd61011dd33333333333333333377666dd67333333333376ddddddddd33333333333333333111111111111111
33333333ddd666773333333333333333dd6d01111110d6dd333333333333333377666ddddd673333333376dddddddddd33333333333333333311111111131113
33333333ddddd66677777777773333336dd1000110001dd63333337733333333666dddddddd6733333376ddddddddddd77333333333333773311111311311313
33333333ddddddd66666666666773333dddd1d1001d1dddd33337766333333336ddddddddddd67333376dddddddddddd66773333333377663313113311313311
3333333311111ddddddddddddd667733dd11d6d11d6d11dd337766dd33333333ddd11111ddddd673376ddddd11111111d66677333377666d3313313331113311
3333333300011111111111111111117711011d1001d110117711111133333333111110001ddddd6776ddddd100000000ddd6667777666ddd3313313331331313
01110100011110000111110000101000733333333333333773333337000000000101010101ddddd66ddddd107333333733333333333333333313133331333113
1dd61d101d76d1011ddd610001d161001733333333333371173333710000000010101010001dddddddddd1006733337633333333333333333313113331131313
01dd110001ddd11d111dd1000011dd1017333333333333711733337100000000010101010001dddddddd1000d673376d33333333333333333313131331111313
00110100001d10010001d10111101100063333333333336006333360000000001010101000001dddddd10000dd6776dd33333333333333333311131333113313
00001dd1d11101000110111ddd6100006333333333333336633333360000000001010101100001dddd100001ddd66ddd33333337733333333311131331111313
61001d6d1001dd1016dd10011dd100163333333333333333333333330000000010101010d101001dd100101ddddddddd33333336633333333331113331311113
7d11d11001dd6dd11dd10000011d11d73333333333333333333333330000000001010101161d10011001d16111dddd1133333336633333333311313331133113
1dd0100000110110011000000001001d333333333333333333333333000000001010101000010000000010000111111033333333333333333313131331313313
10001101100000000011000110110001133333333333333113333331000001000000000001110000001010007777777777777777777777773313131331313313
111111111100000111111011111110131333333333333331133333310111010010110011001d000001ddd10066666dddddddddddddd666663311331331311313
3111311311111111111111111111111313333333333333311333333101dd000111d1101d0011100000011000ddddddd1111111111ddddddd3313111331313113
3313333313111111111311133111113313333333333333311333333100110000011110110000000100001000ddddd11111111111111ddddd3311311311133113
3333333333313311113311333331133313333333333333311333333100000110000000001110011100000000ddd111111111111111111ddd3311311111131313
3333333333333331133331333333333313333333333333311333333110001dd1000111000dd10001d1000010d1111110101010100111111d3311111131111113
3333333333333333333333333333333313333333333333311333333110011d10001dd10101d10000011001d11101010101010101101010113113311311111113
33333333333333333333333333333333133333333333333113333331d00000000000000000100000000000110000000000000000000000001111111111111111
3333337777777777666ddd1111ddd66677333333000000011000000010001010333333331110d116000001100000000033131113331331133333333333333333
33337766666666666ddd11333311ddd66677333310ddd01dd10ddd010001610133388333d610011d011101333311001133111313331113133333333333333333
3377666ddddddddddd113333333311ddd66677330166dd0110dd66100166d10033899833dd11116d01dd33333333101d33131313313311333333333333333333
77666ddd111111111133333333333311ddd666771d661d1001d166d1061dddd03249a983dd6d1ddd001333333333301133131313331313333313313313133333
666ddd1133333333333333333333333311ddd6661d06dd1001dd60d10d6d1d1032499983ddd11dd6003333333333330033133133333111333313113313113333
6ddd11333333333333333333333333333311ddd601d6611001166d1001d1d1d0332448336dd1dddd103333333333330031113333333313333311113111111313
dd113333333333333333333333333333333311dd01161d0110d1611001100d6d33322333ddd111dd133333333333333133133333333333333111111111111113
11333333333333333333333333333333333333111d01d100001d10d1000001d13333333311001011133333333333333033333333333333331111111111111111
3333333333333333333333333333333333333333333c333344444444244444442200222222022022000000000000000000000000000000000000000000000000
333603363336063333363603333330b33333308333cc333344444442224444442220022222222222000000000000000000000000000000000000000000000000
333067503330605733305067333b0b03333808033ccccccc44444422222444442222220022222202000000000000000000000000000000000000000000000000
3336057633360675333676053330b0b333308083cccccccc44444222222244442222222222222220000000000000000000000000000000000000000000000000
333067503330605733305067333b0b0333380803cccccccc44442222222222442000222222202222000000000000000000000000000000000000000000000000
3333357333333375333373353330b333333083333ccccccc44022222222200040022222222222222000000000000000000000000000000000000000000000000
333333333333333333333333333333333333333333cc333344000222000000442202222222222222000000000000000000000000000000000000000000000000
3333333333333333333333333333333333333333333c333344420002222224442222222222222222000000000000000000000000000000000000000000000000
331dd1333311dd3333111d3333d1113333dd11330000000044222202222222242222222222222222000000000000000000000000000000000000000000000000
31d66d1331dd66133d6dd6d33d6dd6d33166dd130000000044022222222220042222220222222220000000000000000000000000000000000000000000000000
1dd66dd1d66d66d1d66dd661166dd66d1d66d66d0000000044400200000200442222200222222022000000000000000000000000000000000000000000000000
d667766dd6677dd11dd77dd11dd77dd11dd7766d0000000044440002220020440022222222222222000000000000000000000000000000000000000000000000
d667766d1dd7766d1dd77dd11dd77dd1d6677dd10000000044422200222200442002222222022222000000000000000000000000000000000000000000000000
1dd66dd11d66d66d166dd66dd66dd661d66d66d10000000044022222200002242200222222022222000000000000000000000000000000000000000000000000
31d66d133166dd133d6dd6d33d6dd6d331dd66130000000040002222202222242222222222222222000000000000000000000000000000000000000000000000
331dd13333dd113333d1113333111d333311dd330000000042200022222222202222002222220222000000000000000000000000000000000000000000000000
333333333333333333333333333333333333333333333333333333333333c333333c333333c33333000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333333333333333cc33333ccc33335cc3333000000000000000000000000000000000000000000000000
333aaa33333aaa33333aaa33333aaa33333aaa3333eeff33338e8f33335ccc3335ccc33333cccc33000000000000000000000000000000000000000000000000
333e9033333e9033333e9033333e9033333880333eeefff338e8f8f335cc7c3335c7cc3335cccc33000000000000000000000000000000000000000000000000
33ee993333ee993333ee993333ee9933338e8833eeeefff38e8e8f8335cccc3335cccc3335cc7c33000000000000000000000000000000000000000000000000
3eeeff333eeeff333eefff333eeeff3338e8f8339399fff39388f8f3335cc533335cc533335cc533000000000000000000000000000000000000000000000000
3eeeff933eeff9333eef9f933eeff9333e8e8f833309f39333088393333553333335533333355333000000000000000000000000000000000000000000000000
33eeff3333eeff3333eeff3333eeff3333e8f83333aaa33333aaa333333333333333333333333333000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33eeff3333eeff3333eeff3333eeff33338e8f330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3eeefff33eeefff33eeefff33eeefff338e8f8f30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3eeefff33eeefff33eeeeff33eeefff33e8e8f830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3ee33ff333eeff3333feeef333eeff3338e338f30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3ee11ff33311ff333fffee3333ee11333e811f830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
311111133331ff333111111333ee1333311111130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33311333333311333333333333113333333113330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000060300000000000000000000083000000d0032300000000000000000000000000000000
00000000000000603000000060300000000000000083000000000000000000000000000000000000000000000000000000000000000000000000000000000060
0000000000000000000000000000000000000000000000000000006080407241000000000000000000d080b1b1a1420000000000000000000000000000000000
00000000603060406341005101114183000000006020203000000000000000000000000000000000000000000000000000000000000000000000000000005182
000000000000000000000000830000000000040000000000000051b321a3020000000000000000c180a19282720142000000000000000000000000000000e3f3
0000345101218292503000528250102020300051222202f041000000000000000000000000000000000000000000000083000000000000000000000000000092
3000000000000000000000000000000000d02020c000000000000052314283000000040000c180b29292533101824200300000000000000083000000c180b2d2
1020202040827192a20141528292a27222124100000000f10000a0b0900000000000000000000000e30000000000602020202030000000000000000000440021
31410000000000d020300000000000600323e0f03343300000000052824200006020202020804092720111721131420001410000000000602030000052821131
72922182a3e0e022f032005272a3023200000000000000e2a0b0a1929110c00000000000040000a0b24100000051f0122212e01241000000d080b010c000d040
a24200000000a0a172824100000051e00000f1e10000e04100830052634200512202e022e0f02212922172f082a242001100000000005112f0224100001282a2
2212223200d3e100f100005272428300000400d0d1c180b0a182a3e02212f04100a090e3f3d080a1a30000000400c3008300f1000000d080a192825391b0a192
9242830000a0a1a312320000000000c30000e1f10000f10000000052509000000000f100c3e10000021222d3123200006300000000000000f100000000000232
00000000e300f183c30000523142000000d00323000002121250c0e28300f2d080a191b0b0a1a3028300e3f3e3f3d0031341d300d080a17211a27282a2319292
824200600323020000000000000000000000f1e10000c360c0000000b39110c00000d30083d30000000000000000000050c0000000000000e100000000000000
0000d0031341f20000000052534200c1032300000000000000b391b0b0b0b0a19282722163824276005113131313230000c12080a12212122202321222021222
634251220000040000000000000000000000d3f100005131919000000002b39110203000000083000000000000000000a29110c000000000f100000000000000
60032300c180b010d10000528242000000000000008300000000e0021222f022e002122212f00000000000000000000000000000000000000064740000000000
11420000000000d03000000083000000000000e10000835392919000000000e0f01222410000000000000000000000008272019110c00000d300000000000051
7200000000e0f022000004525010202020202030000000000000e1000000f100d300000000f10000000000000000000000000000006474000065750000006474
501020202003132332410000000000a0900000f10000009282a29190000000d3f1000000000000a09000000000000000310131827291900000000000e3000052
2183000000e1f1000060208040a302e0f0e01222410000000000d3000000e1000000000000c30000000000000083000000647400006575006485750000006575
72f002e0220000000000e30000c180a19110c0f2f3d08040a302b39110c00000c300000000d080a1919000000004000073a302f0e0121241000000a0b2410052
3100000000e1c3005122f022320000e1f1d300000000000000a090000000c3000000000000000000000000602020300000657564746585746584857400648475
31f100d30000000000a0b2410000b372920191b0b0a131a3008300e0b391b2410000006080a12131a29110c000000000014283e1f18300000000a0a192428352
50c0000400d300000000f100000000d3e10000040000c180b0a19110c000000000000000000000d03000511282a2224164847565848484756585847564858575
11c33400000000d080a18242000052a28272211131a3f000000000f100e0f00000005101113172823101a33313131341214200f1c300000000a0a12172420052
729110202030000000e3f2f300000000c300d0202080b2927253a2729110c0000000040000d080a1224100527263420085848584858494848584858484858485
50202020202080a18272714200005271719292317342c3760000e3d300c3d3000000523182319272a282420000000000509000d3040000d080a1828271427652
92a292a22182416080b2c2d2b1b1b19000a0a192723111820121718221729110c0e3f3d080a12192420000528292420084949585849594858494958585849484
8292213101822172a271714200005271717182a2501020202080b01020202020d100527221927171727242000000000092911020202080a17211927171420052
7282717171725172119271a28221a291b1a172118271a271a29271717282829291b0b0a192a29282420000520182420000000094959400959400009595940000
00122222222221000012222100000000000000000000000000000000000000000000000000000000000000001222210000122210000000000000000001222100
02466666666664200246666421000000000000000000000000000000000000000000000000000000000000124666642002466642000000000000000024666420
147aaaaaaaaaa741147aaaa764210000000000000000000000000000000000000000000000000000000012467aaaa741147aaa74200000000000000247aaa741
26adeeeeeeeeda6226adeedaa76421000000000000000000000000000000000000000000000000000012467aadeeda6226adeda742000000000000247adeda62
26aeffffffffea6226aeffeedaa7642000122222222221000012222100000000000000001222210002467aadeeffea6226aefeda7420000000000247adefea62
26aeffffffffea6226aeffffeedaa741024666666666642002466664210000000000001246666420147aadeeffffea6226aeffeda74200000000247adeffea62
26aeffffffffea6226aeffffffeeda62147aaaaaaaaaa741147aaaa764210000000012467aaaa74126adeeffffffea6226aefffeda742000000247adefffea62
26aeffffffffea6226aeffffffffea6226adeeeeeeeeda6226adeedaa76421000012467aadeeda6226aeffffffffea6226aeffffeda7420000247adeffffea62
26aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffeedaa7642002467aadeeffea6226aeffffffffea6226aefffffeda74200247adefffffea62
26aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffffeedaa741147aadeeffffea6226aeffffffffea6226aeffffffeda741147adeffffffea62
26aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffffffeeda6226adeeffffffea6226aeffffffffea6226aefffffffeda6226adefffffffea62
26aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffffffffea62
26adeeeeeeeeda6226adeeeeeeeeda6226adeeeeeeeeda6226adeeeeeeeeda6226adeeeeeeeeda6226adeeeeeeeeda6226adeeeeeeeeda6226adeeeeeeeeda62
147aaaaaaaaaa741147aaaaaaaaaa741147aaaaaaaaaa741147aaaaaaaaaa741147aaaaaaaaaa741147aaaaaaaaaa741147aaaaaaaaaa741147aaaaaaaaaa741
02466666666664200246666666666420024666666666642002466666666664200246666666666420024666666666642002466666666664200246666666666420
00122222222221000012222222222100001222222222210000122222222221000012222222222100001222222222210000122222222221000012222222222100
00122210012221000000000012222100001222222222210000122222222221000012222222222100001222210000000000122222222221000012222222222100
02466642246664200000001246666420024666666666642002466666666664200246666666666420024666642100000002466666666664200246666666666420
147aaa7447aaa741000012467aaaa741147aaaaaaaaaa741147aaaaaaaaaa741147aaaaaaaaaa741147aaaa764210000147aaaaaaaaaa741147aaaaaaaaaa741
26adeda77adeda620012467aadeeda6226adeeeeeeeeda6226adeeeeeeeeda6226adeeeeeeeeda6226adeedaa764210026adeeeeeeeeda6226adeeeeeeeeda62
26aefedaadefea6202467aadeeffea6226aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffeedaa7642026aeffffffffea6226aeffffffffea62
26aeffeddeffea62147aadeeffffea6226aeffffffffea6226aeffffffeeda6226adeeffffffea6226aeffffeedaa74126aeffffffeeda6226adeeffffffea62
26aefffeefffea6226adeeffffffea6226aeffffffffea6226aeffffeedaa741147aadeeffffea6226aeffffffeeda6226aeffffeedaa741147aadeeffffea62
26aeffffffffea6226aeffffffffea6226aeffffffffea6226aeffeedaa7642002467aadeeffea6226aeffffffffea6226aefffedaa7642002467aadefffea62
26aeffffffffea6226aeffffffffea6226adeeeeeeeeda6226adeedaa76421000012467aadeeda6226aeffffffffea6226aeffeda76421000012467adeffea62
26aeffffffffea6226aeffffffeeda62147aaaaaaaaaa741147aaaa764210000000012467aaaa74126adeeffffffea6226aeffea7421000000001247aeffea62
26aeffffffffea6226aeffffeedaa741024666666666642002466664210000000000001246666420147aadeeffffea6226aefeda6200000000000026adefea62
26aeffffffffea6226aeffeedaa7642000122222222221000012222100000000000000001222210002467aadeeffea6226aefea741000000000000147aefea62
26adeeeeeeeeda6226adeedaa76421000000000000000000000000000000000000000000000000000012467aadeeda6226adeda620000000000000026adeda62
147aaaaaaaaaa741147aaaa764210000000000000000000000000000000000000000000000000000000012467aaaa741147aaa74100000000000000147aaa741
02466666666664200246666421000000000000000000000000000000000000000000000000000000000000124666642002466642000000000000000024666420
00122222222221000012222100000000000000000000000000000000000000000000000000000000000000001222210000122210000000000000000001222100
__gff__
0001010101010100010101010101020201010101000000010101010100000202020202020000000101010101010102020101010101010101040101010202020208080808080200000000000000000000000000000000000000000000000000000000000000000004040400000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
030000000000380d1d060c0000003800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000380000001510140000000000000000000000003800000000000000252a292736132827282a292813121110282917
10140000000a0b1a16271901081b1b09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0202030000251224000000000000000000000d082b2c140000430000252811123a2021220e0f202122233b13112717
12240006081a3a23252827282a3512190103000000000000000000000000000000000000000000000000000000000038000000000000000000000000000000000000430000000000000000000000001532383b283e3f25352400000000000000060230320e3b2900060203380025123a0e003800002e2f38004038003b121329
1324002021234300380e0f3b272a272a1129140000000000000000000000000000000000000000000000003800000d02020300000000000000000000000000000006020203000000000000380d0c0000000000122d0b2b050c38000000000000200f00001f00293f27131014002513243c0006080b0b0b010c000000003b1127
05010202020202020c3c3d240e22230e0f230000000d0c00000000000000000000000000000000000006020202081a372827140000000000000000000000000000200e212300000000000d30320e1400000000112829172a19010c0d03000000003c00001e0013292a281324002510240015103a200e233b1901030038251228
101127282a29273619010c241e38003d3c0000380a1a2a14000000000000000000000d081b0900001527282927283a0e220f000000000000000000000000000006033d000000063031313200003c000d0c000d04272a29133a0e333223001c0c004000001f00102a172912240025352438252924443d38000e3b281400252729
1213103510293713272919092e0d0202020306081a292a2400060c00000000000d081a273629140000210e3d0e20001e003d0000000000000000000000000000123a0038001521140000000000000a1a190b1a102837103a003c000000000033340202031e381235172711243825132400250501020c00001f2512240025282a
1011121312131011101112190b1a2a28272a27292a102924152919093840000a1a3a0f0f0e3d000000401f001e00003c00000000000000000000440000000000363800000000000000000040000a1a3a20223b12113a0e00000000000000000000000e221f00112817291024002505090000210f2333341d1e25352438253529
12131011101112132a292927282917171717171717271724252927190102081a3a001e3d3c3e00003e3f2e3e2f3f38000000000000000000000000380000000005090000000000000000000d081a3a000000000e0f001f00000000000000003800003c003d0a042a17291224002527190938001e000000383c0a042400251228
282729281213102817171729271717171717171717171724251717272a29222100003d00152c2c2d0b0b2b2c2c2d093e000000000000380d02082b2c1400000023333402020c000000153132202100000000001f1e003d00000000003800000000060202081a27292a13102400000e2819010c2e3e3f3f0d081a102400251329
171717172a292717171717171717171717171717171717242517171717050c0038000000252711131213102a1229192b1400000000000a1a35272a2a240000000000000e0f33341d38000000000000000000001e3c000d3014000006020c000000200e22230f0e232812050900003d203b29190b0b0b0b1a2a3a2000380a042a
17171717171717171717171717171717171717292a281724252a28171717190102021d00000e2121220f0f351127102924000000000a1a2927112927240000000000001e3d00000000000000000000000000403d0d303200000000200f23000000001e00001f3d002827121909380000000e0f0e220f0e0f230000000a1a1129
17171717171717171717171717171717172a13111013282425131129271711173a000000003c0000003c1f2829111210240000000a1a2728292a1329240000000000001e000000001c02020c0000380000000d3032004400000000001e00000000002e00003c0000172a291319010c00381e3d1f403c1f1e0038000a1a10132a
1717171717171717171717171717171729103a67210f2300000e0f20230e200e000000000006020c38003d0e102822230000000a1a292a1728172928240000000000003c000d301400003b191b1b1b1b1b1b1a2400003e3f000000001f0038000d080b010c380d1d17172728101019010c2e3e2f3e3f2e3d3e0d081a12372929
1717171717171717171717171717172728360000003c0000383c3d00003c002e0000000015292719010c003c0f1f0000380d081a272917171717171724000000003e380d3032000000000020212223202221230000152c2c14001c0c2f3f0d303220223b190b1a241717172929111210190b0b0b0b0b0b0b0b1a111027282717
171717171717171717171717171717172a050c0d02020800000102020202080b01030000252a11123619010c2f2e3f0d081a1210132a171717171717240000000033313200000000000000000000000000000000000021220000003331313200000000002021230017171717272a291310111229271313102a2810292a171717
0300000000000000000000000000000000000000060c003840000000000015102a272400252927132a2927190b0b0b1a27372913171717171717171724000000060300000000000603000000000000000000000000000000000000000000000000000000000000003e3f3e3f06082b2c2d01033e3f3e00000000000000000000
1014000000000000000038000000000d1d0000152919010c000000000000251117292400251717171728131127291112292a2817171717171717171724000000292814000000150e0f1400000000000000000000000000000000000000000000000000000000001535112712133a0e0f3b121128132d01033e3f3e3f3e3e3f3e
102400000000000d082b2c2c2c2c2d1a24000025271029190b0b011d0000251217172400251717171717122a282a101228171717171717171717171724000000111024000000001e1f000000000000000000380000000000000000000000000000380000000000000e0f222123001e3d2513121312132a29272a371012271717
1324430000000a1a35292827293a2023000000252911122a29283a00003825351717240025171717171717171728271717171717171717171717171724000000271124000000001f1e0000000000000000000000003800400000000d0c00000000000038000000003d1e000000003c0025103a20212223202122233b132a2817
0501020202081a121311293a0f0000000000000020212220212200000000251100004400380000000000000000000000000000000000000000000000000000002a1324430000001e1f38000d030000000000000602020c3e000d081a190103000000000000004000001f00000000000025110038000040000038000029112817
101127282a27113a20210f001e00003800003800000000000000004500000a0400060203000000000000000000000000000000000000000000000000000000001310243e3f3e3f2f2e0d081a27140000000015111310190b0b1a3622210e0f140000000000003e3f3e2f0000000000380a390102020c3e0d0300000028132a28
28292a292712120000001f003d0000000000001c0c000000000000000d081a27151028121400000000000000000000000000000000000000000000000000000028112d0b0b2b2c2c2d1a2727122400000000252a1213282a2927050c383d3c000000000d02080b0b0b2b140000000d081a292223233331322014000027291127
2a3a0e210f3b130000003c000000000000000025192b2c2d0b0b0b0b1a29372925292a282400000000000000000000003800000000000000000000000000000627281113271013121137102828273628352937292812111312102919010202020202081a11131211131224001c081a292a3a000000000000000000002a281027
27003d001e0010380000000006082b1400000000203b272829272a29282a28122529271224000000000000000000000006030000001c0c0000000000000015282927123a200e22202122202321220f230e0f222320210e210f0e0f212220222321272829291013272a362400000e220f23000000000000000000000029351328
130000381e00050c00004000210f0f000000000000002122220e0f0e0f220f102513290509000038000000004000001521221400000033340c00000000003813360f2200001e00000000000000001f001e1f000000001e001f1e1f0000380000000f233b272a271329132400001e001f0000000d030000000000000027102a17
110000003c001119010c0000383c3d380000000000000000383d1e1f1e003d11251228101901021d0000000006030000003800000603000033340c0000000027121f0000003c00000000000038001e001f1e000000003c001e1f3d000d020c00001f38000f21233b29050900003d401e00000a1a281400000000000028131129
36000000000d042829190b2b2c2c2d011d0000000000000000003c3d3c00003525102a1137131124000000150f0e140000000015101114000025190900000028131e0000000038000000000000003d001e1f4000380000001f3c0015320033341d1e00003c0000003b2a19010c3e3f2e0d081a3a0e0000000000000d04122917
12380006081a3a0f293612280f0f0e0f0000000000000000000608010c38001325292829292805093e0d03001e1f0000000006080436240000002033341d0013101f000000000000000d0c00000000003c2f3f000000003e2f00003800000000001f0000060c0000003b2812192b2c2d1a2220003c000000000d081a10292a17
100000210f23401f0e0f220f1f1e1f3d00380000003800001521203b192b2d04003b1311123a3b190b1a3a141f1e000000151013292924000000400000000012123d44000000000d081a190102020300152c2d1b1b1b1b2b2c14000067000000003d00152819090000002021220e220f220000004500000d30323b2813282717
05010202020c3e2e3d3c383d3c2e2f0d1d001c0c3e0d08090044000d042a1027000020210f000021222300001e3c0040000a0411270501020202020202020804130c3e0d0202081a29282a122927292425272a2917172829282400000000000000000025282919010c000000003c403d00000000000d303200000027122a1717
29122a2829192b2d01020202082b2d1a240025190b1a28190102081a2912282a000000003c000000000000003d00000d3032202122212220232021222021212328190b1a291029271717172a17171724252a2817171717272a240000000000000000002527122827190102020202020202020202081a24000000002829171717
__sfx__
000100001c62021620276302d6403365036650396503c6503d65038650306502c6402a630286302562023620216201f6201c63019630176401465013650116400e6300c6200a6200862006620056200362002620
001e00081a07010040110301a0201f0401d0301a0501c05000000227001f700167002210021100000002b10021100000001e10000000000000000000000000000000000000000000000000000000000000000000
001e000401640106100a6301361000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000350703f0703f070390703307021400214002140021400224001804018040190401c0401d0401e040210402204025030280302a0302c02030020350200b52009520065100451001500015002030020200
001000002e3202f3402e3502f3502e3602f3502e3402e3302e3202c3702c3502c3302c31000000000000000000000000002c4002e4002c4002e4002c400000000000000000000000000000000000000000000000
001e0000254502643029440274003246032440324203241027730297302b7402c7302d72030740327503474034720307202e7403076031730337403574034720347102c700287002670026700267002670025700
0001000025630336203e6203b6103861034610306102b6502661023610206101e6101b610186101661014610126100f6100f6100e6000c6000b6000a6000a6000a6000a6000a6000a6000a6000a6000a6000a600
000100001d0701f0702007020070000002207000000000000000025070000000000026050000000000028040000002904000000000002903000000000002a03000000000002a02000000000002b0100000000000
000100000002012610126201362013630156401665017650196501b6501c6501e640126301f6502062021650106102265022650000302365023650206501c6401862017620156201463014640136201361013600
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
