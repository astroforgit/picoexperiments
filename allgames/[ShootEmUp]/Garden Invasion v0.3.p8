pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--garden defender
--by hankdetank05

--tab 0: main

debug=true
game_over=false

function _init()
	//seed the rng
	srand(time())
	make_player()
	init_fslist()
	init_bglist()
	init_bulletlist()
	init_zombielist()
	init_pickuplist()
	init_particles()
	wave_display=true
	current_time=time()
	printh("\n--------\nnew game\n--------\n")
	spawn_zombies()
end

function _update60()
	
	if(not(wave_display))then
		spawn_zombies()
	end
	
	if(not(game_over))then
		update_player()
	end
	
	update_bulletlist()
	update_zombielist()
	update_fslist()
	update_pickuplist()
	check_collisions()
	update_bglist()
	update_particles()
	update_hud()
	update_wave()
end

function _draw()
	cls()
	map(0,0,0,0,16,16)
	if(wave_display)then
		wave_n()
	end
	draw_fslist()
	draw_particles_btm()
	draw_player()
	draw_bullets()
	draw_zombies()
	draw_pickups()
	draw_particles_top()
	draw_hud()
	draw_bglist()
	
	if(game_over)then
		show_game_over()
	end
	
	--[[
	if(current_time-prev_time>0.0167)then
		print(current_time-prev_time,0,0,8)
	else
		print(current_time-prev_time,0,0,7)
	end
	--]]
	
end

function draw_dirt_ui_box(x,y,w,h)
	local dirt_tl=149
	local dirt_tr=154
	local dirt_bl=165
	local dirt_br=170
	
	//top left
	spr(dirt_tl, x,     y    )
	//top right
	spr(dirt_tr, x+w-8, y    )
	//bottom left
	spr(dirt_bl, x,     y+h-8)
	//bottom right
	spr(dirt_br, x+w-8, y+h-8)
	
	//left edge
	for yl=y+8,y+h-16,8 do
		if(yl%2==0) then
			spr(148,x,yl)
		else
			spr(164,x,yl)
		end
	end
	//right edge
	for yr=y+8,y+h-16,8 do
		if(yr%2==0) then
			spr(155,x+w-8,yr)
		else
			spr(171,x+w-8,yr)
		end
	end
	//top edge
	local top_edge_range={150,153}
	local top_edge_spr=150
	for xt=x+8,x+w-16,8 do
		spr(top_edge_spr,xt,y)
		top_edge_spr+=1
		if(top_edge_spr>=top_edge_range[2])then
			top_edge_spr=top_edge_range[1]
		end
	end
	//bottom edge
	local btm_edge_range={166,169}
	local btm_edge_spr=166
	for xb=x+8,x+w-16,8 do
		spr(btm_edge_spr,xb,y+h-8)
		btm_edge_spr+=1
		if(btm_edge_spr>=btm_edge_range[2])then
			btm_edge_spr=btm_edge_range[1]
		end
	end
	//infill
	local infill_range={182,185}
	local infill_spr=182
	for xi=x+8,x+w-16,8 do
		for yi=y+8,y+h-16,8 do
			spr(infill_spr,xi,yi)
			infill_spr+=1
			if(infill_spr==infill_range[2])then
				infill_spr=infill_range[1]
			end
		end
	end
end

function show_game_over()	
	draw_dirt_ui_box(40,40,6*8,4*8)
	//text
	sspr(0,10*8,4*8,2*8,48,48)
end

//diagonal functions
function atan(x1, y1, x2, y2)
	--finds the angle between x & y
	local x = x2-x1
	local y = y2-y1
	return atan2(x,y)
end

function distance(x1, y1, x2, y2)
	return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function taxicab_distance(x1,y1,x2,y2)
	return (max(x1,x2)-min(x1,x2)) + (max(y1,y2)-min(y2,y1))
end

function lookat(x1, y1, x2, y2)
	--steps x toward y
	local x = cos(atan(x1,y1,x2,y2))
	local y = sin(atan(x1,y1,x2,y2))
	return x,y
end

function normalize(x,y)
	local rad=atan2(x,y)
	return cos(rad),sin(rad)
end

//misc functions
function contains(table,value)
	includes=false
	--[[
	for v in all(table) do
		if(v==value)then
			includes=true
			break
		end
	end
	--]]

	//binary search
	
	local runs=0
	
	l=1
	r=#table
	m=flr((left+right)/2)
	
	while(l<=r)do
		m=flr(l+(r-l)/2)
		assert(l>=1,"left bound too small")
		assert(r<=#table,"right bound to large")
		assert(m<=#table and m>=1,"middle index out of bounds")
		assert(l<=m,"mid index smaller than left bound")
		assert(m<=r,"mid index larger than right bound")
		
		assert(table[m]!=nil,"table[m]==nil, m="..m)
		assert(value!=nil,"value==nil")
		
		//check if value is present at mid
		if(table[m]==value)then
			includes=true
			break
		end
		
		//if value is greater, ignore left half
		if(table[m]<value)then
			l=m+1
		//if value is smaller, ignore right half
		else
			r=m-1
		end
		runs+=1
		assert(runs<100,"100 loop runs in binary search")
	end
	
	return includes
end

function insert_sorted_ltoh(table,value)
	//printh("value="..value)
	if #table>0 then
		i=#table
		local runs=0
		//printh("\n\ninserting into sorted order")
		//printh_table(table)
		while i>=1 and table[i]>value do
			table[i+1]=table[i]
			i-=1
			runs+=1
			//printh_table(table)
			assert(runs<100,"100 runs of insertion while loop")
		end
		table[i+1]=value
		//printh_table(table)
		//printh("done inserting into sorted order\n")
	else
		table[1]=value
		//printh_table(table)
	end
end

function printh_table(table)
	for val in all(table) do
		printh(val)
	end
	printh("\n")
end


//debug functions
function debug_pickup_generation()
	for p in all(pickuplist)do
		print("type: "..p.type,0)
	end
end

function debug_entity_collisions()

	if(leftcol)then
		print("leftcol",12)
	else
		print("leftcol",8)
	end
		
	if(rightcol)then
		print("rightcol",12)
	else
		print("rightcol",8)
	end
		
	if(hcol)then
		print("hcol",12)
	else
		print("hcol",8)
	end
		
	if(game_over)then
		print("game over",12)
	else
		print("game over",8)
	end
		
		
	if(vcol)then
		print("vcol",12)
	else
		print("vcol",8)
	end
		
	if(upcol)then
		print("upcol",12)
	else
		print("upcol",8)
	end
		
	if(downcol)then
		print("downcol",12)
	else
		print("downcol",8)
	end
end

function debug_wall_collision()
	pset(player.leftx,player.lefty,10)
	pset(player.rightx,player.righty,10)
	pset(player.upx,player.upy,10)
	pset(player.downx,player.downy,10)

	if(wleft)then
		print("wleft "..left,12)
		rect(player.lcellx*8,player.lcelly*8,player.lcellx*8+7,player.lcelly*8+7,12)
	else
		print("wleft "..left,8)
		rect(player.lcellx*8,player.lcelly*8,player.lcellx*8+7,player.lcelly*8+7,8)
	end
	
	if(wright)then
		print("wright "..right,12)
		rect(player.rcellx*8,player.rcelly*8,player.rcellx*8+7,player.rcelly*8+7,12)
	else
		print("wright "..right,8)
		rect(player.rcellx*8,player.rcelly*8,player.rcellx*8+7,player.rcelly*8+7,8)
	end
	
	if(wup)then
		print("wup "..up,12)
		rect(player.ucellx*8,player.ucelly*8,player.ucellx*8+7,player.ucelly*8+7,12)
	else
		print("wup "..up,8)
		rect(player.ucellx*8,player.ucelly*8,player.ucellx*8+7,player.ucelly*8+7,8)
	end
	
	if(wdown)then
		print("wdown "..down,12)
		rect(player.dcellx*8,player.dcelly*8,player.dcellx*8+7,player.dcelly*8+7,12)
	else
		print("wdown "..down,8)
		rect(player.dcellx*8,player.dcelly*8,player.dcellx*8+7,player.dcelly*8+7,8)
	end
end

function debug_bullet_collision()
	for b in all(bulletlist) do
		pset(b.leftx,b.lefty,8)
		pset(b.rightx,b.righty,8)
		pset(b.upx,b.upy,8)
		pset(b.downx,b.downy,8)
	end
end

function debug_max_zombies_this_wave()
	if(debug)then
		print(max_zombies_this_wave,0,0,7)
	end
end

function debug_wave_display()
	if(wave_display)then
		print("true",0,0,11)
	else
		print("false",0,0,8)
	end
end

function debug_spawn_countdown()
	print(spawn_countdown,0,0,7)
end
-->8
--tab 1: player

shots_fired=0

function make_player()
	player={}
	
	--movement speed
	player.speed=0.5
	local diag_rad = atan2(player.speed,player.speed)
	player.diag_speed_x=cos(diag_rad)
	player.diag_speed_y=sin(diag_rad)
	
	--player pos. and dir.
	player.x=64
	player.y=64
	player.dir=5 --numpad notation
	player.dirx=0
	player.diry=1
	player.fdirx=0
	player.fdiry=1
	player.deltax=0
	player.deltay=0
	player.cellx=flr(player.x/8)
	player.celly=flr(player.y/8)
	
	player.leftx=player.x
	player.lefty=player.y+4
	
	player.rightx=player.x+7
	player.righty=player.y+4
	
	player.upx=player.x+4
	player.upy=player.y
	
	player.downx=player.x+4
	player.downy=player.y+7
	
	player.centerx=player.x+4
	player.centery=player.y+4
	
	--health
	player.healthcap=3
	player.health=3
	
	player.knockback=16
	player.kbx=0
	player.kby=0
	player.kb_pos=0
	player.kb_speed=2
	
	player.hurthelp_window=60
	player.hurthelp=0
	
	--ammo
	player.ammocap=2
	player.ammo=2
	player.reloading=false
	player.reloadstatus=0
	player.reloadspeed=0.17
	
	player.max_spread=0.25	
	player.shot_spread=0.015625
	player.shot_incr_step=0.015625
	
	player.max_pellets=10
	player.num_pellets=2
	
	player.max_penetration=10
	player.pellet_penetration=0
	
	player.num_particles=25
	
	player.score=0
	
end

function update_player()
	
	--update hurthelp
	if(player.hurthelp>0)then
		player.hurthelp-=1
	end
	
	--update player sprite edges
	player.leftx=player.x
	player.lefty=player.y+4
	
	player.rightx=player.x+7
	player.righty=player.y+4
	
	player.upx=player.x+4
	player.upy=player.y
	
	player.downx=player.x+4
	player.downy=player.y+7
	
	player.centerx=player.x+4
	player.centery=player.y+4

	--update cellx and celly
	player.cellx=flr((player.x)/8)
	player.celly=flr((player.y)/8)
	
	player.lcellx=flr(player.leftx/8)
	player.lcelly=flr(player.lefty/8)
	
	player.rcellx=flr(player.rightx/8)
	player.rcelly=flr(player.righty/8)
	
	player.ucellx=flr(player.upx/8)
	player.ucelly=flr(player.upy/8)
	
	player.dcellx=flr(player.downx/8)
	player.dcelly=flr(player.downy/8)
	
	left=mget(player.lcellx,player.lcelly)
	right=mget(player.rcellx,player.rcelly)
	up=mget(player.ucellx,player.ucelly)
	down=mget(player.dcellx,player.dcelly)
	
	wleft=fget(left,5)
	wright=fget(right,5)
	wup=fget(up,5)
	wdown=fget(down,5)

	--knockback
	if(player.kb_pos<player.knockback)then
		if((player.kbx<0 and not(wleft)) or (player.kbx>0 and not(wright)))then
			player.x+=player.kbx*2
		end
		if((player.kby<0 and not(wup)) or (player.kby>0 and not(wdown)))then
			player.y+=player.kby*2
		end
		player.kb_pos+=player.kb_speed
	else
	
		//player.dirx=0
		//player.diry=0
	
		if btn(‹) then
			//left
			player.dirx=-1
			if not(wleft) then
				player.deltax=-1
			else
				player.deltax=0
			end
		elseif btn(‘) then
			//right
			player.dirx=1
			if not(wright) then
				player.deltax=1
			else
				player.deltax=0
			end
		else
			player.dirx=0
			player.deltax=0
		end
		
		if btn(”) then
			//up
			player.diry=-1
			if not(wup) then
				player.deltay=-1
			else
				player.deltay=0
			end
		elseif btn(ƒ) then
			//down
			player.diry=1
			if not(wdown) then
				player.deltay=1
			else
				player.deltay=0
			end
		else
			player.diry=0
			player.deltay=0
		end
		
		local nx,ny
		
		if not(player.deltax==0 and player.deltay==0) then
			nx,ny=normalize(player.deltax,player.deltay)
		else
			nx=0
			ny=0
		end
		
		player.x+=nx*player.speed
		player.y+=ny*player.speed
		
	end
	
	--[[
	local target={player.x+player.dirx,player.y+player.diry}
	
	delta_x,delta_y = lookat(player.x,player.y,target[1],target[2])
	
	if(btn(‹) or btn(‘) or btn(”) or btn(ƒ)) then
		if(abs(distance(player.x, player.y, target[1], target[2])) >= 0.5)then
			player.x+=delta_x
			player.y+=delta_y
		end
	end
	--]]

	-----------------------------
	--rotate player if not firing
	-----------------------------
	--fire
	if(btnp(—) and not(btn(Ž)))then
		fire()
	
	--reload
	elseif(btnp(Ž) and player.ammo!=player.ammocap)then
		reload_ammo()
	
	--rotate player
	elseif(player.dirx==-1)then
		if(player.diry==-1)then
			--left,up
			player.dir=7
			player.fdirx=-1
			player.fdiry=-1
		elseif(player.diry==0)then
			--left
			player.dir=4
			player.fdirx=-1
			player.fdiry=0
		else
			--left,down
			player.dir=1
			player.fdirx=-1
			player.fdiry=1
		end
		
	elseif(player.dirx==0)then
		if(player.diry==-1)then
			--up
			player.dir=8
			player.fdirx=0
			player.fdiry=-1
		elseif(player.diry==0)then
			--idle, change nothing
		else
			--down
			player.dir=2
			player.fdirx=0
			player.fdiry=1
		end
		
	else
		if(player.diry==-1)then
			--right,up
			player.dir=9
			player.fdirx=1
			player.fdiry=-1
		elseif(player.diry==0)then
			--right
			player.dir=6
			player.fdirx=1
			player.fdiry=0
		else
			--right,down
			player.dir=3
			player.fdirx=1
			player.fdiry=1
		end
		
	end
end

function draw_player()
	if(player.hurthelp>0)then
		--draw hurthelp sprite
		if(player.hurthelp%2==0)then
			spr(player.dir+16,player.x,player.y)
		else
			spr(player.dir+32,player.x,player.y)
		end
	else
		--draw regular sprite
		spr(player.dir,player.x,player.y)
	end
end

function fire()
	shots_fired+=1
	if(not(player.reloading) and player.ammo>0)then
		sfx(0)
		player.ammo-=1
		
		local half_spread=player.shot_spread/2
		local spread_slice=player.shot_spread/(player.num_pellets-1)

		create_bulletgroup(shots_fired)
		
		for i=0,player.num_pellets-1 do
			local rad=atan2(player.fdirx,player.fdiry)+half_spread-(i*spread_slice)
			local bltdx=cos(rad)
			local bltdy=sin(rad)
			//printh("bltdx="..bltdx)
			//printh("bltdy="..bltdy)
			//printh("player.x="..player.x)
			create_bullet(shots_fired,player.pellet_penetration,player.x,player.y,bltdx,bltdy)
			//printh("bltgrp["..i.."]="..bltgrp[i+1].x)
		end
		
		//add(bulletlist,bltgrp)
		//printh("#bulletlist="..#bulletlist)
		
		fire_particles()
		
		--[[
		left_rad=atan2(player.dirx,player.diry)+player.half_spread		
		leftdx=cos(left_rad)
		leftdy=sin(left_rad)
		
		--create left bullet
		create_bullet("l",player.x,player.y,leftdx,leftdy)

		--create middle bullet
		create_bullet("m",player.x,player.y,player.dirx,player.diry)
		
		right_rad=left_rad-player.shot_spread
		rightdx=cos(right_rad)
		rightdy=sin(right_rad)

		--create right bullet
		create_bullet("r",player.x,player.y,rightdx,rightdy)
]]
	elseif(not(player.reloading) and player.ammo==0)then
		sfx(2)
	end
end

function reload_ammo()
	if(player.reloading)then
		return
	else
		player.reloading=true
		player.reloadstatus=player.ammo*4
		player.ammo=2
	end
end

function damage_player(dmgdir)
	--player gets pushed away from
	--damage source unless there
	--is a wall in the way
	
	if(player.hurthelp==0 and player.health>0)then
		player.health-=1
		if(player.health==0)then
			game_over=true
		else
			player.hurthelp=player.hurthelp_window
			player.kb_pos=0
			if(dmgdir==1)then
				--dmg from dl, push ur
				player.kbx=1
				player.kby=-1
				
			elseif(dmgdir==2)then
				--dmg from down, push up
				player.kbx=0
				player.kby=-1
			
			elseif(dmgdir==3)then
				--dmg from dr, push ul
				player.kbx=-1
				player.kby=-1
			
			elseif(dmgdir==4)then
				--dmg from left, push right
				player.kbx=1
				player.kby=0
			
			elseif(dmgdir==5)then
				--invalid collision
			
			elseif(dmgdir==6)then
				--dmg from right, push left
				player.kbx=-1
				player.kby=0
			
			elseif(dmgdir==7)then
				--dmg from ul, push dr
				player.kbx=1
				player.kby=1
			
			elseif(dmgdir==8)then
				--dmg from up, push down
				player.kbx=0
				player.kby=1
				
			elseif(dmgdir==9)then
				--dmg from ur, push dl
				player.kbx=-1
				player.kby=1
				
			end
		end
	end
end

function get_pickup(ptype)
	
	if(ptype=="health")then
		if(player.health<player.healthcap)then
			player.health+=1
		end
		
	elseif(ptype=="spread")then
		//increase shot spread width by 0.015625 radians if not maxed out
		if(player.shot_spread<player.max_spread)then
			player.shot_spread+=player.shot_incr_step
		end
		//add a mid-field spawn
		add_field_spawn()
	
	elseif(ptype=="pellet")then
		//increase pellets per shot by 1 if not maxed out
		if(player.num_pellets<player.max_pellets)then
			player.num_pellets+=1
		end
	
	elseif(ptype=="penetration")then
		//increase pellet penetration by 1 if not maxed out
		if(player.pellet_penetration<player.max_penetration)then
			player.pellet_penetration+=1
		end
		//increase zombie spawn frequency
		spawn_frequency=base_spawn_freq-(player.pellet_penetration*2.9)

	end

end

function fire_particles()
	if(player.dir==7 or player.dir==8 or player.dir==9 or player.dir==4 or player.dir==6)then
		layer="bottom"
	else
		layer="top"
	end
	
	for i=1,player.num_particles do
		xdev=rnd(0.5)-0.25
		ydev=rnd(0.5)-0.25
		
		add_p_vel(player.x+4,player.y+4,player.dirx+xdev,player.diry+ydev,"fire",layer)
	end
end
-->8
--tab 2: bullet

bullet_id=0
bullet_speed=2.5
bullet_wall_particles=5
bullet_zombie_particles=50

function init_bulletlist()
	bulletlist={}
end

function create_bullet(bg_id,pent,px,py,dirx,diry)

	bullet={}
	
	bullet.bg_id=bg_id
	
	bullet.penetration=pent
	bullet.z_ids={}
	
	bullet.x=px
	bullet.y=py
	
	bullet.dx=dirx
	bullet.dy=diry
	
	bullet.leftx=bullet.x+2
	bullet.lefty=bullet.y+4
	
	bullet.rightx=bullet.x+5
	bullet.righty=bullet.y+4
	
	bullet.upx=bullet.x+4
	bullet.upy=bullet.y+2
	
	bullet.downx=bullet.x+4
	bullet.downy=bullet.y+5
	
	bullet.centerx=bullet.x+4
	bullet.centery=bullet.y+4
	
	bullet.sprx=bullet.x+2
	bullet.spry=bullet.y+2
	
	bullet.plr_dir=player.dir
	
	add(bulletlist,bullet)
end

function update_bulletlist()
	for bg in all(bg_list) do
		bg.live_count=0
	end

	for b in all(bulletlist)do

		b.x+=b.dx*bullet_speed
		b.y+=b.dy*bullet_speed
	
		b.leftx=b.x+2
		b.lefty=b.y+4
	
		b.rightx=b.x+5
		b.righty=b.y+4
	
		b.upx=b.x+4
		b.upy=b.y+2
	
		b.downx=b.x+4
		b.downy=b.y+5
		
		bullet.centerx=bullet.x+4
		bullet.centery=bullet.y+4
		
		bullet.sprx=bullet.x+2
		bullet.spry=bullet.y+2
	
		for bg in all(bg_list) do
			if bg.id==b.bg_id then
				for z_id in all(b.z_ids) do
					if not(contains(bg.z_ids,z_id)) then
						printh("bullet group #"..bg.id.." does not contain zombie id #"..z_id)
						insert_sorted_ltoh(bg.z_ids,z_id)
					end
				end
				if bg.live_count==0 and #bg.z_ids>0 and bg.x==128 and bg.y==128 then
					set_bg_pos(b.x,b.y)
				end
				bg.live_count+=1
			end
		end

	end
end

function draw_bullets()
	for b in all(bulletlist)do
		spr(16,b.x,b.y)
	end
end

function delete_bullet(b)
	printh("deleting bullet")
	printh_table(b.z_ids)
	
	for bg in all(bg_list) do
		if bg.id == b.bg_id then
			if #bg.z_ids>0 and bg.x==128 and bg.y==128 then
				set_bg_pos(b.x,b.y)
			end
			for z_id in all(b.z_ids) do
				if not(contains(bg.z_ids,z_id)) then
					printh("bullet group #"..bg.id.." does not contain zombie id #"..z_id)
					insert_sorted_ltoh(bg.z_ids,z_id)
				end
			end
		end
	end
	
	del(bulletlist,b)
end

function bullet_fence_particles(b)
	layer="bottom"
	
	for i=1,bullet_wall_particles do
		local vel=rnd(0.5)
		local altvel=rnd(1)
		if(b.x<8)then
			//vertical particles (left)
			if(i%2==0)then
				//particle up
				add_p_vel(b.leftx,b.upy,altvel,-vel,"wall",layer)
			else
				//particle down
				add_p_vel(b.leftx,b.upy,altvel,vel,"wall",layer)
			end
		
		elseif(b.x>110)then
			//vertical particles (right)
			if(i%2==0)then
				//particle up
				add_p_vel(b.rightx,b.upy,-altvel,-vel,"wall",layer)
			else
				//particle down
				add_p_vel(b.rightx,b.upy,-altvel,vel,"wall",layer)
			end
			
		elseif(b.y<8)then
			//horizontal particles (up)
			if(i%2==0)then
				//left particles
				add_p_vel(b.leftx,b.upy,-vel,altvel,"wall",layer)
			else
				//right particles
				add_p_vel(b.leftx,b.upy,vel,altvel,"wall",layer)
			end		
			
		elseif(b.y>97)then
			//horizontal particles (down)
			if(i%2==0)then
				//left particles
				add_p_vel(b.leftx,b.downy,-vel,-altvel,"wall",layer)
			else
				//right particles
				add_p_vel(b.leftx,b.downy,vel,-altvel,"wall",layer)
			end
		end
	end
end

-->8
--tab 3: hud

fheart=32
eheart=48

ammo_anim_start=49
ammo_0=49
ammo_1=53
ammo_2=57
ammo_anim_end=57

penet_spr_index={}

pellet_spr_index={}

spread_line_mid_x=69
spread_line_y=124
upgrade_stage=0
line_len=0
max_line_len=5*8

function create_hud()
end

function update_hud()
	update_health_box()
	update_ammo_box()
	update_score_box()
	update_upgrades_box()
end

function draw_hud()
	--128x16
	line(0,110,127,110,15)
	rect(0,111,127,127,4)
	
	--health
	draw_health_box()
	
	line(32,112,32,126,4)
	
	--ammo
	draw_ammo_box()
	
	line(46,112,46,126,4)
	
	--score
	draw_score_box()
	
	line(104,112,104,126,4)
	
	--upgrades
	draw_upgrades_box()
end

function draw_hud_box(x1,y1,x2,y2)
	--top edge (dark)
	line(x1,y1,x2,y1,5)
	
	--left edge (dark)
	line(x1,y1,x1,y2,5)
	
	--right edge (light)
	line(x2,y1+1,x2,y2,15)
	
	--bottom edge (light)
	line(x1,y2,x2,y2,15)
	
	--infill (neutral)
	rectfill(x1+1,y1+1,x2-1,y2-1,4)
end

function update_health_box()
end

function draw_health_box()
	--draw box border
	draw_hud_box(1,112,31,126)
	
	--draw filled hearts
	for i=0,player.health-1 do
		spr(fheart,5+8*i,115)
	end
	
	--draw empty hearts
	for i=player.health,player.healthcap-1 do
		spr(eheart,5+8*i,115)
	end
end

function update_ammo_box()
	--set the ammo sprite
	if(player.reloading)then
		if(player.reloadstatus>=8)then
			player.reloading=false
		else
			player.reloadstatus+=player.reloadspeed
			if((player.reloadstatus>=4 and player.reloadstatus<4+player.reloadspeed) or (player.reloadstatus>=8 and player.reloadstatus<8+player.reloadspeed))then
				sfx(1)
			end
			ammosprite=flr(player.reloadstatus+49)
		end
		
	elseif(player.ammo==2)then
		ammosprite=ammo_2
	
	elseif(player.ammo==1)then
		ammosprite=ammo_1
	
	else
		ammosprite=ammo_0
	end

end

function draw_ammo_box()
	--draw box border
	draw_hud_box(33,112,45,126)
	
	spr(ammosprite,35,115)
end

function update_score_box()
end

function draw_score_box()
	draw_hud_box(105,112,126,126)
	//print(zombies_killed,108,117,5)
	//print(zombies_killed,109,117,6)
	print(player.score,108,117,5)
	print(player.score,109,117,6)
end

function update_upgrades_box()
	update_penet_upgrade()
	update_pellet_upgrade()
	update_spread_upgrade()
end

function draw_upgrades_box()
	draw_hud_box(47,112,103,126)
	
	//penetration
	draw_penet_upgrade()
	
	//pellets
	draw_pellet_upgrade()
	
	//spread
	draw_spread_upgrade()
	
end

function update_penet_upgrade()
	for i=1,5 do
		//update sprites
		if(player.pellet_penetration<1+(i*2-2))then
			penet_spr_index[i]=193
		elseif(player.pellet_penetration==1+(i*2-2))then
			penet_spr_index[i]=194
		elseif(player.pellet_penetration==2+(i*2-2))then
			penet_spr_index[i]=195
		elseif(player.pellet_penetration>2+(i*2-2))then
			penet_spr_index[i]=196
		end
	end
end

function draw_penet_upgrade()
	for i=1,5 do
		//draw sprites
		spr(penet_spr_index[i],49+(i*8-8),110)
	end
end

function update_pellet_upgrade()
	for i=1,5 do
		//update sprites
		if(player.num_pellets<1+(i*2-2))then
			pellet_spr_index[i]=209
		elseif(player.num_pellets==1+(i*2-2))then
			pellet_spr_index[i]=210
		elseif(player.num_pellets>1+(i*2-2))then
			pellet_spr_index[i]=211
		end
	end
end

function draw_pellet_upgrade()
	for i=1,5 do
		//draw sprites
		spr(pellet_spr_index[i],49+(i*8-8),114)
	end
end

function update_spread_upgrade()
	line_len=(player.shot_spread/player.max_spread)*max_line_len
end

function draw_spread_upgrade()
	line(spread_line_mid_x-(max_line_len/2),spread_line_y,spread_line_mid_x+(max_line_len/2),spread_line_y,13)

	//adjusted line length
	local adj_len=flr(line_len/2)
	local left_x=spread_line_mid_x-adj_len
	local right_x=spread_line_mid_x+adj_len
	
	//left edge line
	line(left_x,spread_line_y-1,left_x,spread_line_y+1,7)
	//width line
	line(spread_line_mid_x-adj_len,spread_line_y,spread_line_mid_x+adj_len,spread_line_y,7)
	//right edge line
	line(right_x,spread_line_y-1,right_x,spread_line_y+1,7)
end

-->8
--tab 4: zombie

base_spawn_freq=30
spawn_frequency=base_spawn_freq //num frames
spawn_countdown=spawn_frequency
zombies_spawned=0
zombies_killed=0

max_zombies_this_wave=0
zombies_this_wave=0

ai_refresh_rate=30
level_up_rate=3
pickup_rarity=30
horde_threshold=300

blood_particles=10

blood_vel=1.2
blood_half_vel=blood_vel/2

spawn_val_range=4

rotation_threshold=5

function init_zombielist()
	zombielist={}
end

function create_zombie()

	zombie={}

	if #field_spawns>0 then
		spawn_val_range=5
	end

	edge=flr(rnd(spawn_val_range))
	coord=flr(rnd(128))
	
	zombie.played_dead_sound=false
	
	zombie.dir=5
	
	if edge==4 then
		//mid-field spawn
		--local tmpx,tmpy		
		local s_index=flr(rnd(#field_spawns)+1)
		local spwnr=field_spawns[s_index]
		//printh("field spawns="..#field_spawns)
		//printh("s_index="..s_index)
		if not(all_spawns_busy()) then
			while #field_spawns>1 and spwnr.incoming do
				printh("spawner is busy, finding a new one")
				s_index=flr(rnd(#field_spawns)+1)
				spwnr=field_spawns[s_index]
			end
			spwnr.incoming=true
			zombie.x=spwnr.x
			zombie.y=spwnr.y
		else
			edge=flr(rnd(spawn_val_range-1))
			coord=flr(rnd(128))				
		end
	end
	
	if edge==0 then
		//left
		zombie.x=-8
		zombie.y=coord
	elseif edge==1 then
		//right
		zombie.x=128
		zombie.y=coord
	elseif edge==2 then
		//up
		zombie.x=coord
		zombie.y=-8
	elseif edge==3 then
		//down
		zombie.x=coord
		zombie.y=110
	end
	
	zombie.id=zombies_spawned
	zombie.dead=false
	zombie.dead_anim_count=0
	zombie.dead_anim_speed=0.1
	zombie.speed=0.25
	zombie.refresh=ai_refresh_rate

	--set zombie sprite edges
	zombie.leftx=zombie.x
	zombie.lefty=zombie.y+4
	
	zombie.rightx=zombie.x+7
	zombie.righty=zombie.y+4
	
	zombie.upx=zombie.x+4
	zombie.upy=zombie.y
	
	zombie.downx=zombie.x+4
 zombie.downy=zombie.y+7
 
 zombie.centerx=zombie.x+4
 zombie.centery=zombie.y+4
 
 zombie.dirx=0
 zombie.diry=0
 zombie.dir=0 --numpad notation
	
	
	if edge<4 then	
		add(zombielist,zombie)
		printh("created zombie with id "..zombie.id)
	else
		add(z_waiting_room,zombie)
	end
	zombies_spawned+=1
			zombies_this_wave+=1
			spawn_countdown=spawn_frequency
	
end

function update_zombielist()
	//max_zombies_this_wave=wave
	
	for z in all(zombielist) do

		if(z.dead)then
			--code goes here
			if(z.dead_anim_count<2)then
				if(not(z.played_dead_sound))then
					sfx(4)
					z.played_dead_sound=true
				end
				z.dead_anim_count+=z.dead_anim_speed				
			else
				del(zombielist,z)
				drop_random_pickup(z.x,z.y)
				zombies_killed+=1
				wave_kills+=1
				//if(zombies_killed%level_up_rate==0)then
					//level_up_rate+=1
					//spawn_frequency-=1
				//end
			end
		else
			--update zombie sprite edges
			z.leftx=z.x
			z.lefty=z.y+4
			
			z.rightx=z.x+7
			z.righty=z.y+4
			
			z.upx=z.x+4
			z.upy=z.y
			
			z.downx=z.x+4
		 z.downy=z.y+7
		 
		 z.centerx=z.x+4
		 z.centery=z.y+4
		 
		 z.dirx=0
		 z.diry=0
		 z.dir=0 --numpad notation
			
			if(z.refresh>0)then
				z.refresh-=1
			else				
				if(player.x < z.x-rotation_threshold) then
					z.dirx=-1
				elseif(player.x > z.x+rotation_threshold) then
					z.dirx=1
				else
					z.dirx=0
				end
				
				if(player.y < z.y-rotation_threshold) then
					z.diry=1
				elseif(player.y > z.y+rotation_threshold) then
					z.diry=-1
				else
					z.diry=0
				end
				
				local target = {player.x,player.y}
				delta_x,delta_y = lookat(z.x,z.y,player.x,player.y)
				z.x += delta_x*z.speed
				z.y += delta_y*z.speed
				
				if(z.dirx==-1 and z.diry==-1)then
					z.dir=1
				elseif(z.dirx==0 and z.diry==-1)then
					z.dir=2
				elseif(z.dirx==1 and z.diry==-1)then
					z.dir=3
				elseif(z.dirx==-1 and z.diry==0)then
					z.dir=4
				elseif(z.dirx==0 and z.diry==0)then
					z.dir=5
				elseif(z.dirx==1 and z.diry==0)then
					z.dir=6
				elseif(z.dirx==-1 and z.diry==1)then
					z.dir=7
				elseif(z.dirx==0 and z.diry==1)then
					z.dir=8
				elseif(z.dirx==1 and z.diry==1)then
					z.dir=9
				end
			end
		end
	end
end

function draw_zombies()
	for z in all(zombielist) do
		if(z.dead)then
			--code goes here
			spr(z.dir+64+(16*flr(z.dead_anim_count)),z.x,z.y)
		else
			spr(z.dir+64,z.x,z.y)
		end
		//print(z.id,z.x,z.y,7)
	end
end

function spawn_zombies()
	if(zombies_this_wave<max_zombies_this_wave)then
		if(spawn_countdown>0)then
			spawn_countdown-=1
		else
			create_zombie()
		end
	end
end

function drop_random_pickup(x,y)
	
	if(zombies_killed%15==0 and zombies_killed>=20 and pickup_rarity<99)then
		pickup_rarity+=5
	end
	
	random=flr(rnd(pickup_rarity))
	if(random==0)then
		create_health_pickup(x,y)
	elseif(random==1)then
		create_penet_pickup(x,y)
	elseif(random==2)then
		create_pellet_pickup(x,y)
	elseif(random==3)then
		if(player.num_pellets>2)then
			create_spread_pickup(x,y)
		else
			create_pellet_pickup(x,y)
		end
	end
end

function blood_particles_hit(b,z)
	if(z.dir==7 or z.dir==8 or z.dir==9)then
		layer="bottom"
	else
		layer="top"
	end
	for i=1,blood_particles do
		local xdev=rnd(blood_vel)-blood_half_vel
		local ydev=rnd(blood_vel)-blood_half_vel
		add_p_vel(z.x+4,z.y+4,xdev,ydev,"blood",layer)
	end
end

function blood_particles_penet(b,z)
	if(z.dir==1 or z.dir==2 or z.dir==3)then
		layer="bottom"
	else
		layer="top"
	end
	for i=1,blood_particles do
		local xdev=rnd(blood_vel)-blood_half_vel
		local ydev=rnd(blood_vel)-blood_half_vel
		
		if(b.plr_dir==1)then
			ydev*=2.5
			xdev=-ydev
		elseif(b.plr_dir==2)then
			xdev*=0.5
			ydev*=2.5
		elseif(b.plr_dir==3)then
			ydev*=2.5
			xdev=ydev
		elseif(b.plr_dir==4)then
			xdev*=2.5
			ydev*=0.5
		elseif(b.plr_dir==6)then
			xdev*=2.5
			ydev*=0.5
		elseif(b.plr_dir==7)then
			ydev*=2.5
			xdev=ydev
		elseif(b.plr_dir==8)then
			xdev*=0.5
			ydev*=2.5
		elseif(b.plr_dir==9)then
			ydev*=2.5
			xdev=-ydev
		end
		
		add_p_vel(z.x+4,z.y+4,b.dx+xdev,b.dy+ydev,"blood",layer)
	end
end
-->8
--tab 5: collision detection

function check_collisions()
	check_bullet_collisions()
	check_player_collisions()
end

function check_bullet_collisions()
	--check zombie collisions
	
	for b in all(bulletlist) do
		//check for pellet wall collisions		
		if fget(mget(flr(b.leftx/8),flr(b.downy/8)),5) then
			//play sound for pellet hitting wall
			//sfx(???)
			bullet_fence_particles(b)
			//del(bulletlist,b)
			delete_bullet(b)
		end
		
		for z in all(zombielist) do
			--code goes here
			if taxicab_distance(b.x,b.y,z.x,z.y) <= 12 and not(contains(b.z_ids,z.id)) then
				bleftcol=(z.leftx<=b.leftx and b.leftx<=z.rightx)
				brightcol=(z.leftx<=b.rightx and b.rightx<=z.rightx)
				
				bupcol=(z.upy<=b.upy and b.upy<=z.downy)
				bdowncol=(z.upy<=b.downy and b.downy<=z.downy)
				
				if((bleftcol or brightcol) and (bupcol or bdowncol)) then
					assert(z.id!=nil,"nil zombie id")
					//add(b.z_ids,z.id)
					insert_sorted_ltoh(b.z_ids,z.id)
					b.penetration-=1
					if(b.penetration<0)then
						//del(bulletlist,b)
						delete_bullet(b)
						blood_particles_hit(b,z)
					else
						blood_particles_penet(b,z)
					end
					z.dead=true
				end
			end
		end
	end
end

function check_player_collisions()
	--code goes here
	--check pickup collision
	for p in all(pickuplist) do
		pleftcol=(p.leftx<=player.leftx and player.leftx<=p.rightx)
		prightcol=(p.leftx<=player.rightx and player.rightx<=p.rightx)
		
		pupcol=(p.upy<=player.upy and player.upy<=p.downy)
		pdowncol=(p.upy<=player.downy and player.downy<=p.downy)
		
		if(check_rect_collision(player.x,player.y,8,8,p.x,p.y,8,8))then
			get_pickup(p.type)
			sfx(p.sound)
			del(pickuplist,p)
		end
	end
	--check zombie collision
	for z in all(zombielist) do
		if(not(z.dead))then
			assert(z.leftx!=nil,"z.leftx==nil")
			assert(z.rightx!=nil,"z.rightx==nil")
			zleftcol=(z.leftx<=player.leftx and player.leftx<=z.rightx)
			zrightcol=(z.leftx<=player.rightx and player.rightx<=z.rightx)		
			zhcol=zleftcol or zrightcol
		
			zupcol=(z.upy<=player.upy and player.upy<=z.downy)
			zdowncol=(z.upy<=player.downy and player.downy<=z.downy)
			zvcol=zupcol or zdowncol
			
			if(zhcol and zvcol) then
				--determine direction of collision
				
				--uses numpad notation
				dmgdir=5
				
				xdelta=z.centerx-player.centerx
				ydelta=z.centery-player.centery
				
				if(abs(xdelta)>abs(ydelta))then
					--horiz. collision
					if(xdelta>0)then
						--right
						dmgdir=6
					elseif(xdelta<0)then
						--left
						dmgdir=4
					end
					
				elseif(abs(xdelta)<abs(ydelta))then
					--vert. collision
					if(ydelta>0)then
						--down
						dmgdir=2
					elseif(ydelta<0)then
						--up
						dmgdir=8
					end
					
				else
					--diag. collision
					if(xdelta>0 and ydelta>0)then
						--dr
						dmgdir=3
					elseif(xdelta>0 and ydelta<0)then
						--ur
						dmgdir=9
					elseif(xdelta<0 and ydelta>0)then
						--dl
						dmgdir=1
					elseif(xdelta<0 and ydelta<0)then
						--ul
						dmgdir=7
					end
				end
				
				damage_player(dmgdir)
			end
		end
	end
end

function check_rect_collision(r1x,r1y,r1w,r1h,r2x,r2y,r2w,r2h)
	if((r1x < r2x + r2w) and (r1x + r1w > r2x) and (r1y < r2y + r2h) and (r1y + r1h > r2y)) then
		return true
	else
		return false
	end
end

function check_map_collision(r1x,r1y,r1w,r1h,flag)
	check=false
	for i=0,15,1 do
		for j=0,15,1 do
			if check_rect_collision(r1x,r1y,r1w,r1h,i*8,j*8,8,8) and fget(mget(i,j),flag) then
				check=true
			end
		end
	end
	return check
end
-->8
--tab 6: pickups

function init_pickuplist()
	pickuplist={}
end

function update_pickuplist()
	for p in all(pickuplist)do
		p.current_spr+=0.1
		if(p.current_spr>=p.spr1+4)then
			p.current_spr=p.spr1
		end
	end
end

function draw_pickups()
	for p in all(pickuplist)do
		spr(flr(p.current_spr),p.x,p.y)
	end
end

function create_generic_pickup(px,py)
	
end

function create_health_pickup(px,py)
	pu={}
	
	--position
	pu.x=px
	pu.y=py
	
	--edges
	pu.leftx=pu.x
	pu.lefty=pu.y+4
	
	pu.rightx=pu.x+7
	pu.righty=pu.y+4
	
	pu.upx=pu.x+4
	pu.upy=pu.y
	
	pu.downx=pu.x+4
	pu.downy=pu.y+7
	
	--attributes
	pu.type="health"
	pu.spr1=74
	pu.current_spr=pu.spr1
	pu.sound=3
	
	add(pickuplist,pu)
end

function create_penet_pickup(px,py)
	pu={}
	
	--position
	pu.x=px
	pu.y=py
	
	--edges
	pu.leftx=pu.x
	pu.lefty=pu.y+4
	
	pu.rightx=pu.x+7
	pu.righty=pu.y+4
	
	pu.upx=pu.x+4
	pu.upy=pu.y
	
	pu.downx=pu.x+4
	pu.downy=pu.y+7
	
	--attributes
	pu.type="penetration"
	pu.spr1=90
	pu.current_spr=pu.spr1
	pu.sound=3
	
	add(pickuplist,pu)
end

function create_pellet_pickup(px,py)
	pu={}
	
	--position
	pu.x=px
	pu.y=py
	
	--edges
	pu.leftx=pu.x
	pu.lefty=pu.y+4
	
	pu.rightx=pu.x+7
	pu.righty=pu.y+4
	
	pu.upx=pu.x+4
	pu.upy=pu.y
	
	pu.downx=pu.x+4
	pu.downy=pu.y+7
	
	--attributes
	pu.type="pellet"
	pu.spr1=106
	pu.current_spr=pu.spr1
	pu.sound=3
	
	add(pickuplist,pu)
end

function create_spread_pickup(px,py)
	pu={}
	
	--position
	pu.x=px
	pu.y=py
	
	--edges
	pu.leftx=pu.x
	pu.lefty=pu.y+4
	
	pu.rightx=pu.x+7
	pu.righty=pu.y+4
	
	pu.upx=pu.x+4
	pu.upy=pu.y
	
	pu.downx=pu.x+4
	pu.downy=pu.y+7
	
	--attributes
	pu.type="spread"
	pu.spr1=122
	pu.current_spr=pu.spr1
	pu.sound=3
	
	add(pickuplist,pu)
end
-->8
--tab 7: waves

wave=0
wave_kills=0
wave_screentime=120
wave_screentimer=wave_screentime
wave_display=false
max_zombies_this_wave=0

function update_wave()
	if wave_kills==max_zombies_this_wave then
		wave_kills=0
		wave+=1
		wave_display=true
		zombies_this_wave=0
		//max zombies this wave = the larger of the two: [the wave number] or (round up)[wave number * num pellets * 0.25]
		max_zombies_this_wave=max(wave,ceil(wave*(player.num_pellets*0.25)))
		if wave>ceil(wave*(player.num_pellets*0.1)) then
			printh("wave greater")
		else
			printh("scalar greater")
		end
	end
end

function wave_n()
	local num_spr=132

	//draw wave n		
	//draw_dirt_ui_box(40,36,6*8,5*8)
	draw_dirt_ui_box(40,36,48,40)
	
	//draw wave text
	//"w"            "a"            "v"            "e"
	spr(128,48,44) spr(129,56,44) spr(130,64,44) spr(131,72,44)
	
	//draw wave timer bar
	sspr(0,9*8,4*8,8,48,52)
	rectfill(50,54,(wave_screentimer/wave_screentime)*28+50,57,12)
	
	//draw wave number
	if(wave<10)then
		//draw single-digit wave number
		spr(wave+num_spr,60,60)
	elseif(wave<100)then
		//draw double-digit wave numebr
		//draw 10s place
		spr(flr(wave/10)+num_spr,56,60)
		//draw 1s place
		spr((wave%10)+num_spr,64,60)
	else
		//draw triple-digit wave number
		//draw 100s place
	 spr(flr(wave/100)+num_spr,52,60)
		//draw 10s place
		spr(flr((wave-100)/10)+num_spr,60,60)
		//draw 1s place
		spr((wave%10)+num_spr,68,60)
	end
	wave_screentimer-=1
	if(wave_screentimer<=0)then
		wave_display=false
		wave_screentimer=wave_screentime
	end
end
-->8
--tab 8: particles

ps_btm={} //particles (bottom)
ps_top={} //particles (top)

g=0.0 //particle gravity
max_vel=2 
min_time=2 //min/max time btwn particles
max_time=5
min_life=90 //particle lifetime
max_life=120
t=0 //ticker
cols={1,1,1,13,13,12,12,7}	//colors


shot_min_life=1
shot_max_life=10
shot_colors={8,9,9,9,9,10}

wall_min_life=1
wall_max_life=10
wall_colors={5,4,4,4,4,15}

blood_min_life=1
blood_max_life=15
blood_colors={136,136,8,8,8,8,8}

burst=50

function init_particles()
	next_p=randrange(min_time,max_time)
end

function update_particles()
	t+=1
	if(t==next_p)then
		//add_p(64,64)
		next_p=randrange(min_time,max_time)
		t=0
	end
	//burst
	--[[
	if(btn(Ž))then
		for i=1,burst do
			add_p(64,64)
		end
	end
	--]]
	foreach(ps_btm,update_p)
	foreach(ps_top,update_p)
end

function draw_particles_btm()
	foreach(ps_btm,draw_p)
end

function draw_particles_top()
	foreach(ps_top,draw_p)
end

function randrange(low,high)
	return flr(randrangefloat(low,high))
end

function randrangefloat(low,high)
	return (rnd(high-low+1)+low)
end

function add_p(x,y)
	//add particle with rnd velocity
	local p={}
	
	p.x=x
	p.y=y
	
	p.dx=rnd(max_vel)-max_vel/2
	p.dy=rnd(max_vel)*-1
	
	p.life_start=randrange(min_life,max_life)
	p.life=p.life_start
	
	p.tag="none"
	
	add(ps_btm,p)
end

function add_p_vel(x,y,vx,vy,tag,layer)
	//add particle with given velocity
	local p={}
	
	p.x=x
	p.y=y
	
	p.dx=vx
	p.dy=vy
	
	p.tag=tag
	p.layer=layer
	
	local minl=0
	local maxl=0
	
	if(tag=="fire")then
		minl=shot_min_life
		maxl=shot_max_life
	elseif(tag=="wall")then
		minl=wall_min_life
		maxl=wall_max_life
	elseif(tag=="blood")then
		minl=blood_min_life
		maxl=blood_max_life
	else
		minl=min_life
		maxl=max_life
	end
	
	p.life_start=randrange(minl,maxl)
	p.life=p.life_start

	if(layer=="top")then
		add(ps_top,p)
	elseif(layer=="btm" or layer=="bottom")then
		add(ps_btm,p)
	end
end

function update_p(p)
	if(p.life<=0)then
		if(p.layer=="top")then
			del(ps_top,p) //kill old particles
		elseif(p.layer=="btm" or p.layer=="bottom")then
			del(ps_btm,p)
		end
	else
		
		--[[
		p.dy+=g //add gravity
		if((p.y+p.dy)>127)then
			p.dy*=-0.8
		end
		--]]
		
		p.x+=p.dx //update position
		p.y+=p.dy
		
		p.life-=1 //die a little
	end
end

function draw_p(p)
	if(p.tag=="fire")then
		local pcol=flr(p.life/p.life_start*#shot_colors+1)
		pset(p.x,p.y,shot_colors[pcol])
		
	elseif(p.tag=="wall")then
		local pcol=flr(p.life/p.life_start*#wall_colors+1)
		pset(p.x,p.y,wall_colors[pcol])
		
	elseif(p.tag=="blood")then
		local pcol=flr(p.life/p.life_start*#blood_colors+1)
		pset(p.x,p.y,blood_colors[pcol])
		
	elseif(p.tag=="none")then
		local pcol=flr(p.life/p.life_start*#cols+1)
		pset(p.x,p.y,cols[pcol])
	end
end
-->8
--tab 9: field spawns

xmin=2
xmax=14
ymin=2
ymax=12

function init_fslist()
	field_spawns={}
	z_waiting_room={}
end

function update_fslist()
	for s in all(field_spawns) do
		if s.anim<3 or (s.incoming and s.anim<8) then
			s.anim+=0.125
		elseif s.anim>=8 then
			printh("spawning zombie...")
			printh("z_waiting_room size = "..#z_waiting_room)
			local z=deli(z_waiting_room,1)
			printh("z_waiting_room size = "..#z_waiting_room)
			printh("z.x="..z.x.." z.y="..z.y)
			add(zombielist,z)
			printh("created midfield zombie with id "..z.id)
			if not(#field_spawns==1 and #z_waiting_room>=1) then
				s.incoming=false
			end
			s.anim=3
		end
	end
end

function draw_fslist()
	for s in all(field_spawns) do
		spr(113+flr(s.anim),s.x,s.y)
	end
end

function add_field_spawn()
	local spawn={}
	
	spawn.x=(flr(rnd(xmax-xmin))+xmin)*8
	spawn.y=(flr(rnd(ymax-ymin))+ymin)*8
	
	spawn.anim=0
	
	spawn.incoming=false
	
	add(field_spawns,spawn)
end

function spawn_zombie_at_fs()
end

function all_spawns_busy()
	local num_busy=0
	for s in all(field_spawns) do
		if s.incoming==true then
			num_busy+=1
		end
	end
	local all_busy= num_busy==#field_spawns
	if all_busy then
		printh("all spawns busy")
	end
	return all_busy
end
-->8
--tab 10: bulletgroup

function init_bglist()
	bg_list={}
end

function update_bglist()
	for bg in all(bg_list) do
		if not(bg.moving) then
			bg.kills=#bg.z_ids
			
			if bg.kills<5 then
				bg.multiplier=1
			elseif bg.kills<10 then
				bg.multiplier=2
			elseif bg.kills<15 then
				bg.multiplier=4
			elseif bg.kills<20 then
				bg.multiplier=8
			elseif bg.kills<25 then
				bg.multiplier=16
			elseif bg.kills<30 then
				bg.multiplier=32
			elseif bg.kills<35 then
				bg.multiplier=64
			elseif bg.kills<40 then
				bg.multiplier=128
			else
				bg.multiplier=256
			end
			
			bg.final_score=bg.kills*bg.multiplier
			bg.score=bg.kills
			
			if bg.live_count==0 then
				
				printh("bg.z_ids")
				for z_id in all(bg.z_ids) do
					printh("\t"..z_id)
				end
				bg.moving=true
				//del(bg_list,bg)
			end
		else
			//bg is moving
			if bg.score==bg.final_score then
				bg.x+=bg.dx*bg.speed
				bg.y+=bg.dy*bg.speed
				
				if bg.x>107 and bg.y>116 then
					player.score+=bg.score
					del(bg_list,bg)
				end
			else
				bg.score+=1
			end
		end
	end
	//printh("bg count = "..#bg_list)
end

function draw_bglist()
	for bg in all(bg_list) do
		if not(bg.moving) then
			print(bg.kills.."x"..bg.multiplier,bg.x,bg.y,5)
			print(bg.kills.."x"..bg.multiplier,bg.x+1,bg.y,6)
		else
			print(flr(bg.score),bg.x,bg.y,5)
			print(flr(bg.score),bg.x+1,bg.y,6)
		end
	end
end

function set_bg_pos(x,y)
	bg.x=x
	bg.y=y
	bg.dx,bg.dy=lookat(bg.x,bg.y,108,117)
end

function create_bulletgroup(bg_id)
	bg={}
	bg.x=128
	bg.y=128
	bg.dx=0
	bg.dy=0
	bg.speed=2
	bg.moving=false
	bg.id=bg_id
	bg.z_ids={}
	bg.live_count=0
	bg.kills=0
	bg.multiplier=1
	bg.score=0
	bg.final_score=0
	add(bg_list,bg)
end
__gfx__
00000000005555000055550000555500005555000055550000555500005555000055550000555500333333333333333300000000000000000000000000000000
000000000ffff55005ffff50055ffff00ff5555005ffff5005555ff00f55555005555550055555f033333b333b33333300000000000000000000000000000000
007007000cffcf500fcffcf005fcffc00fcf55500fcffcf00555fcf00cf555500f5555f005555fc0333333333333333300000000000000000000000005555550
000770000ffffff00ffffff00ffffff00ffffff00ffffff00ffffff00ffffff00ffffff00ffffff0b33333b333333b3300000000055555500555555053333335
0007700000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff003333333333b3333300000000533333355333333553333535
0070070055111100055111000015550055111100055111000011455505111100001111500011114533333333333333b355555500533333505333353553333535
000000000411110004411100004411000011110004411100001441000011110000111140001114403333b3333333333353333350533333505333335053333350
00000000002122000021120000221200002210000021120000012200002212000021120000212200333333333333333305333335053333350533333505333335
00000000005555000055550000555500005555000055550000555500005555000055550000555500333b33333333333344333333333443333333334400000000
000000000ffff55005ffff50055ffff00ff5555005ffff5005555ff00f55555005555550055555f0333333333b33333344454444445445444444544400000000
0055550008ff8f500f8ff8f005f8ff800f8f55500f8ff8f00555f8f008f555500f5555f005555f8033b333b3333c333335543333333443333333455300000000
005775000ffffff00ffffff00ffffff00ffffff00ffffff00ffffff00ffffff00ffffff00ffffff03333333333cac33334544333333443333334454300000000
0057750000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0033333333333c353334344454445445444544434300000000
005555005588880005588800008555005588880005588800008845550588880000888850008888453b3333b3333b53b33433554b33344333b455334300000000
000000000488880004488800004488000088880004488800008448000088880000888840008884403333b333333333333433454b33b44b33b454334300000000
00000000002822000028820000228200002280000028820000082200002282000028820000282200333333333333333335334bbb333bb333bbb4335300000000
00000000005555000055550000555500005555000055550000555500005555000055550000555500333333333333333344334333333333333334334400000000
077077000ffff55005ffff50055ffff00ff5555005ffff5005555ff00f55555005555550055555f033e333b333b3338344434333333333333334344400000000
7887887009ff9f500f9ff9f005f9ff900f9f55500f9ff9f00555f9f009f555500f5555f005555f903eae3333333338a835545333333333333335455300000000
788888700ffffff00ffffff00ffffff00ffffff00ffffff00ffffff00ffffff00ffffff00ffffff033eb353b33333b8334544333333333333334454300000000
7888887000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff00333b533333333b5534344433333333333344434300000000
07888700559999000559990000955500559999000559990000994555059999000099995000999945333333333b3333333433554b33333333b455334300000000
007870000499990004499900004499000099990004499900009449000099990000999940009994403b3333333333333b3433454b33333333b454334300000000
000700000029220000299200002292000022900000299200000922000022920000299200002922003333b3333333333335334bbb33333333bbb4335300000000
00000000077707770777077707770777077707770288077702880777028807770288077702880288000000000000000044335333333443333335334400000000
07707700070707070707070707070707070707070288070702880707028807070288070702880288000000000000000045444444445445444444445400000000
70070070000000000000000000000000028800000288000002880000028800000288028802880288000000000000000034555333333443333334554300000000
70000070070707070707070707070707028807070288070702880707028807070288028802880288000000000000000033444333333443333334443300000000
70060070070707070707070702880707028807070288070702880707028802880288028802880288000000000000000033345444445445444445433300000000
0700070000000000000000000288000002880000028800000288000002880288028802880288028800000000000000003333455b33344333b554333300000000
007070000707070702880707028807070288070709aa070709aa028809aa028809aa028809aa09aa00000000000000003333344b33b44b33b443333300000000
00070000077707770288077702880777028807770499077704990288049902880499028804990499000000000000000033333bbb333bb333bbb3333300000000
00666600006666000066660000666600006666000066660000666600006666000066660000666600000880000008500000088000000580000000000000566500
06655660055556600655556006655550055666600655556006666550056666600666666006666650000880000008500000055000000580000000000005566550
05555850085585600585585006585580058566600585585006665850085666600566665006666580088888800088850000088000005888000000000055566555
05555550055555500555555005555550055555500555555005555550055555500555555005555550088888800088850000088000005888000000000005566550
00555500005555000055550000555500005555000055550000555500005555000055550000555500000880000008500000055000000580000000000005566550
00222200002222000022220000222200002222000022220000222200002222000022220000222200000880000008500000088000000580000000000000566500
00252200002222000022220000222200002222000022220000222200002222000022220000222200000000000000000000000000000000000000000000566500
00425400004244000042240000442400004420000042240000024400004424000042240000424400005555000005500000055000000550000000000000066000
00000000000056600066660006650000000006600000000006600000000066600000000006660000000000000000000000000000000000000000000000666600
05555660000585660685586066585000000055660000000066550000000856660066660066658000000000000000000000000000000000006666655505666650
05555560002555660555555066555200000258560000000065852000002556660666666066655200000065550000655500066555060065550066656555666655
00555580022558560522225065855220002255560000000065552200022556660666666066655220006665650666656560666565006665650000655505666650
00555550422255500022220005552224022225500000000005522220422255500566665005552224000065550000655500006555000065550000000005566550
00522500022222000022220000222220422222000000000000222224042222000055550000222240000000000000000000000000000000000000000000566500
00252200004220000042240000022400042220000000000000022240002220000022220000022200000000000000000000000000000000000000000000566500
00455500000400000042240000004000000200000000000000002000000400000042240000004000005055550550555550055555055055550000000000066000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000055550055550055550000005555000000000000666600
00055500000000000000000000000000000000000000000000000000000000000000000000000000000056650056650056650000005665000000555506666660
00055600000000000000000000000000000000000000000000000000000000000000000000000000555556650056650056655555005555000000566556666665
00555500000085500055550005580000000055500000000005550000000085500055550005580000566555550055550055555665005665005555566505666650
00555800022225860622226068522220422558560000000065855224042556660666666066655220566500000056650000005665005665005665555505666650
00555000022225660622226066522220422555660000000066555224042566660666666066665220555500000055550000005555005555005665000000666600
00252000042425660542245066524240222556660000000066655222022566660666666066665240000000000000000000000000000000005555000000566500
00555000042425560042240065524240022556660000000066655220022566660066660066665240055555500005500005555550000550000000000000066000
00000000000000000000000000000000000004400000044000000440000004400000044000000440007777000077770000777700007777000000000000666600
00000000000000000000000000004000004444400044444000444440004444400044444000444440007667000766667007666670076666700000000006666660
00000000000000000000440000044400004555400042224000422240004888400048884000488840007667000766667076666667076666700000000066666666
00000000000440000004440004455440045555540425552404222224048222840488888404888884007667000076670007666670007667000000000006666660
00000000004540000045540004555440445555544425552444225224448222844488288444888884000770000076670007666670007667000000000006666660
00055500004440000445540044555400445555544425552444222224448222844488888444888884000770000076670000766700007667000000000000666600
00555800000000000044440004444000444555404442224044422240444888404448884044488840000770000007700000766700000770000000000000666600
00550000000000000000000004400000044444000444440004444400044444000444440004444400000770000007700000077000000770000000000000066000
bb300bb300bbb300bb300bb3bbbbbbb30bbbbbb0bbbb30000bbbbbb00bbbbbb0bb300bb3bbbbbbb30bbbbb30bbbbbbb30bbbbbb00bbbbbb00000000000000000
b4300b4300b44300b4300b43b4444443bb4444b3b4443000bb4444b3bb4444b3b4300b43b4444443bb444430b4444443bb4444b3bb4444b30000000000000000
b4bb3b430bb44330b433bb43b4bb3333b43bb44333b43000b4333b43b43bbb43b4300b43b4bbbb33b43333303333bb43b4bbbb43b4333b430000000000000000
b4b4bb430b4bb430bb43b433b4443000b4bb4b4300b43000333bbb43333b4433b4bbbb433b444433b4bbbb300000b433bb444433b4bbbb430000000000000000
bb44b433bb4444330b4bb430b4333000b4b43b4300b430000bbb4433bb3334b3b444444333333b43b4444433000bb430b4333b43bb4444430000000000000000
0b444430b4333b430bb44330b4bbbbb3b44bbb43bbb4bbb3bb443333b4bbbb4333333b43b4bbbb43b4bbbb43000b4330b4bbbb430bbbbb430000000000000000
0b43b430b4300b4300b44300b4444443bb444433b4444443b44444433344443300000b4333444433bb444433000b4300334444330b4444330000000000000000
03333330333003330033330033333333033333303333333333333333033333300000033303333330033333300003330003333330033333300000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0044444400000000444544440000000000000000000000000000000044444400000000000bbbbbb00000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3004544440000440444444444000000000400000000000004000044004454444000000000bb4444b30000000000000000
bb555555555555555555555555555533004444440004444444444444004444444544444400444444400444004444444000000000b43bb4430000000000000000
bb555555555555555555555555555533004444540444444444444454444544444444444444454444444444004444440000000000b4bb4b430000000000000000
bb555555555555555555555555555533004444440544454444444444444444444444444444444444444444004444440000000000b4b43b430000000000000000
bb555555555555555555555555555533000044440444444454444444444444544444454444444544444544404454400000000000b44bbb430000000000000000
bb333333333333333333333333333333000044540444444444444444454444444444444444444444444444404444440000000000bb4444330000000000000000
b3333333333333333333333333333333004444440044444444444444444444445444444444444444444444404444444000000000033333300000000000000000
0bbbbb3000bbb3000bb3bb30bbbbbbb3004444440044444444444444444444444445444444444444444544004444440000000000000000000000000000000000
bb44443000b443000b4bb430b4444443044444440444444444444444444544444444444444444444444444404444440000000000000000000000000000000000
b43333300bb443300b444430b4bb3333045444440444544444544454444444444444444445444544444444404544440000000000000000000000000000000000
b43bbbb30b4bb430bb44b433b4443000044444440044444444444444444444544445444444444444444444404444400000000000000000000000000000000000
b43b4443bb444433b4b4bb43b4333000044445440004444444454444444444444444444444444444454444404444400000000000000000000000000000000000
b4bbbb43b4333b43b4333b43b4bbbbb3004444440004445444444444444400040004444544445444444400004445400000000000000000000000000000000000
bb444433b4300b43b4300b43b4444443000444440004444400444440044000000000444404440000444000004444440000000000000000000000000000000000
03333330333003333330033333333333004445440000000000000000000000000000000000000000000000004444440000000000000000000000000000000000
0bbbbbb0bb300bb3bbbbbbb3bbbbbbb3000000000000000044444444444444444444444444444444000000000000000000000000000000000000000000000000
bb4444b3b4300b43b4444443b4444443000000000000000044444444444444544444444445444444000000000000000000000000000000000000000000000000
b4333b43b433bb43b4bb3333b4bbbb43000000000000000044444444445444444444445444444454000000000000000000000000000000000000000000000000
b4300b43bb43b433b4443000b4444443000000000000000044454444444444444444444444444444000000000000000000000000000000000000000000000000
b4300b430b4bb430b4333000b44bb333000000000000000044444444444444444445444444444444000000000000000000000000000000000000000000000000
b4bbbb430bb44330b4bbbbb3b4344bb3000000000000000044444444444445444444444444544444000000000000000000000000000000000000000000000000
bb44443300b44300b4444443b4333443000000000000000044444444445444444444444444444444000000000000000000000000000000000000000000000000
03333330003333003333333333303333000000000000000044444444444444444444444444444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006555066606660666066606660666066606660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000085808580555085805550555055505550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055505550555055505550555055505550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000022202226682022266226682662266220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000022202220222022202220222022202220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56655555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
566500000ddd0ddd05550ddd05550555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555500000ddd0ddd05650ddd05650565000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ddd0ddd05550ddd05550555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00566500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05566550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55566555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05566550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05566550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00566500000006000060000000000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00566500000006660066666666666600666000006666666600000000000000000000000000000000000000000000000000000000000000000000000000000000
00066000000006000060000000000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000008080000000000000000000000000000080820202000000000000000000000000808200820000000000000000000000000002020200001010101010101010101808080800080000000000000000000008080808080800000000000000000000080808080808000080808080808080808808080800080
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000800000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000
__map__
1c1d1d1d1d1d1d1d1d1d1d1d1d1d1d1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2d2d2d0a2d2d2d2d2b0a2d2d2d2e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2d2b2d2d2d2d0a2d2d2d2d2d2d2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2d0b2d2d0b2d1b2d2d2d2d2d0a2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2d2d2d2d0a2d2d0b2d2d0a2d2d2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c1b2a2d2d2d2d2d2d2d2d2d2a2d2d2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2d2d1b2d2d2d0a2d2d2d2d2d2d2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2d2d2d1b2d2d2a2d2d2d2d2d1b2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2d2d2d2d2d0b2d2d2d0b2d2d2d2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2b2d2d2d2d2d2d2d2d2d2b2d0a2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2d2d2d0b2d2d2d2d2d0a2d2d2d2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d0b2d1b2d2d2b1a2d2d2d1b2d2d2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2c2d2d2d2d2d2d0b0a0a2d2d0b2d2d2e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3c1d1d1d1d1d1d1d1d1d1d1d1d1d1d3e2e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003c1d1d1d1d1d1d1d1d1d1d1d1d1d1d3e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001e6501e6501e6501e6301e6201e6201e6201e6101e6101e6101e610053000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000100000d61018610206102d6103a6103e6103b61000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00010000006400064000640006703f6003f6000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00010000000400204004040070400a0400d04013040180401c0402004023040260402704027040270402704027040270402704027030270302703027020270202702027020270102701027010270102700027000
00010000203501d3501b35019350183501535013350103500d3500a350063500135028300323003f30016300163001430012300113000e3000c3000a300093000730005300023000130000300003000030000300
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
