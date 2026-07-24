pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--† game loop †--

function _init()
	cartdata("xerrf_telco_1")
	psuedo_init()
end

function _update60()
	global_update()
	_upd()
end

function _draw()
	_drw()
end

function psuedo_init()
	game_paused=false
	game_over=false
	make_timers()
	make_code_menu()
	make_menu()
	make_wind()
	make_narrative()
	make_interactables()
	make_tile_flags()
	make_lvl_table()
	make_lvls()
	make_avatars_table()
	_upd=update_lvl
	_drw=draw_game
end
-->8
--“ updates (game state) “--
function make_timers()
	t=0 --time
	trap_time=60 --trap toggle time
	trap_timer=0 --trap timer
	pause_t=0 --pause timeout
	first_launch=true
end

function restart_game()
	--destroy everything first
	foreach(avatars,destroy_avatar)
	destroy_ghosts()
	reset_interactables()
	--reset narrative stuff
	end_wind()
	dialog=false
	n_delivered=false
	fset(16,3,true) --npc dialog trigger
	--reload original map
	reload(0x2000,0x2000,0x1000)
	psuedo_init()
end

--[[
input code menu handler
]]--
function update_code_menu()
	for i=0,3 do
		if(btnp(i))then
			move_cursor(dirx[i+1],diry[i+1])
		end
	end
	if(btnp(—))then
		add_to_code()
	end
		--code color
	code_t=min(code_t+0.1,1)
	if(code_t==1)then
		code_c=7
	end
end

--[[
pause game state
]]--
function update_pause_menu()
	pause_t=min(pause_t+0.05,1)
	if(pause_t==1)then
		if(btnp(Ž))then
		game_paused=false
			_upd=update_game
			_drw=draw_game
		elseif(btnp(—))then
			dset(0,tot_attempts)
			restart_game()
		end
	end
end

--[[
updates timing tiles and things
that are seperate from gameplay
and movement state switches.
]]--
function global_update()
	if(not game_paused)then
		if(btnp(Ž))then
			pause_t=0
			if(cur_lvl==1)then
				_upd=update_code_menu
				_drw=draw_code_menu
			else
				game_paused=true
				_upd=update_pause_menu
				_drw=draw_pause_menu
			end
		end	
		t+=1
		--trap cycle timer 
		--here bc movement interupts update_game()
		if(allow_toggle)then
			if(trap_timer<=0)then
				foreach(toggles,toggle_tiles)
				trap_timer=trap_time
			end	
			trap_timer-=1
		end
	end
end

--[[
main game state
]]--
function update_game()
	if(interactables_made==false)then
		for t in all(tv) do
			del(tv,t)
		end
		make_interactables_for_lvl()
	end
	destroy_ghosts()
	allow_toggle=true --trap toggle
	
	--gameplay updates
	if(wind_open==false)then --allow mvmt
	 update_avatars()
	 foreach(avatars,check_a_on_trap)
		check_lvl_trap()
	else
		update_narrative()
 end
 if(n_delivered==false)then
		check_narrative()
	end
end

--[[
determines which avatars'
smooth	move anim to play
]]--
function update_a_walk()
	local s=0.2 --anim speed
	a_t=min(a_t+s,1) --update animation timer 
		
 --update pos for smooth mvmt
	for i=1, #avatars do
		if(avatars[i].move==true)then
			a_walk_to_space(avatars[i])
		else
		 a_walk_to_wall(avatars[i])
		end
	end
		
 --return state to game
	if(a_t==1)then
		check_lvl_exit()
		if(lvl_success==false)then
			_upd=update_game
		end
	end
end

--[[
sets up the level, map offset, 
called on death,lvl success.
]]--
function update_lvl()
	allow_toggle=false
	if(l_t==0)then
		foreach(avatars,destroy_avatar)
	end
	reset_interactables()
 if(n_delivered==false)then
		check_narrative()
	end
	line_count=1
	l_t=min(l_t+0.05,1) --level timer
	
	--sets offset x,y for map
	if(l_t==1)then
		--update solid tile offset
		local tempox
		local b=cur_lvl
		tempox=b%8
		if(tempox==0)then
			tempox=8
		end
		lvl_ox=16*tempox-16  --set x offset for collision
		if(b>=0 and b<9)then	--set y ^^
			lvl_oy=0
		elseif(b>=9 and b<17)then
			lvl_oy=16
		elseif(b>=17 and b<25)then
			lvl_oy=32
		elseif(b>=25 and b<33)then
			lvl_oy=48
		end
		trap_timer=0
		update_music()
		spawn_a_in_l(cur_lvl) --in avatars
		_upd=update_game
		_drw=draw_game
	end
end

--[[
handles input when dialog box
is up.
]]--
function update_narrative()
	local n_speed=0.05
	line_t=min(line_t+n_speed,1)
	if(line_t>=1)then
		if(btnp(—))then
			line_count+=1
			line_t=0
		end
	end
end

--[[
updates music based on level
]]--
function update_music()
	if(cur_lvl>=6 and cur_lvl<8)then
		music(0)
	elseif(cur_lvl>=8 and cur_lvl<9)then
		music(2)
	--split to 2
	elseif(cur_lvl>=9 and cur_lvl<12)then
		music(4)
	--offest
 elseif(cur_lvl>=12 and cur_lvl<22)then
		music(6)
	-- split to 4
	elseif(cur_lvl>=22 and cur_lvl<25)then
		music(10)
	--split to 8
	elseif(cur_lvl>=25 and cur_lvl<28)then
		music(14)
	--split to 2, rev
	elseif(cur_lvl>=28 and cur_lvl<32)then
		music(18)
	elseif(cur_lvl==32)then
		music(22)
	else
		music(-1)
	end
end
-->8
--… draws (global) …--
function make_menu()
	blink_frame=0 --tracks frame to blink
	blink_speed=20
	blink_seq_i=1
end

--[[
draws the code input menu
]]--
function draw_code_menu()
	cls(7)
	print("telco ch-33 se",36,20,5)
	print("— to select",40,100,5)
	--code shown
	rectfill2(40,32,48,11,6)
	rectfill2(41,33,46,9,0)
	local spacing=0
	for i=1, #code do
		print(code[i],48+spacing,35,code_c)
		spacing+=10
	end	
	--cursor
	print("c"..c.gridx..","..c.gridy,2,2,7)
	spr(20,c.px-13,c.py)
	spr(20,c.px+8,c.py,1,1,true,false)
	--visual menu grid
	for k in all(keypad)do
		print(k.str,k.x,k.y,5)
	end
end

--[[
draws the pause menu
]]--
function draw_pause_menu()
	cls(7)
	print("telco ch-33 se code",26,32,5)
	print(get_pause_code(),55,40,0)
	blink_text("z to resume",40,98)
	blink_text("x to quit",44,106)
end

--[[
main game view
]]--
function draw_game()
	cls(7)
	pal()
 --draw the current level
	draw_lvl()
	if(game_over)then
		draw_game_over_ui()
	else
		draw_game_ui()
	end
	
	foreach(avatars,draw_avatar)
	if(cur_lvl==1)then
		blink_text("z to input code",34,80)
		blink_text("‹ move ‘",44,88)
	end
	if(cur_lvl==2)then
		draw_npcs()
	end
	if(wind_open)then
		draw_wind()
	end
end

--[[
shifts map to current level
]]--
function draw_lvl()
	map(lvl_ox,lvl_oy)
	foreach(avatars,draw_spawn)
end

--[[€€ draw avatars €€]]--

function draw_avatar(a)
	spr(get_frame(a.anim),a.x*8+a.ox,a.y*8+a.oy,1,1,a.flip)
end

function draw_spawn(a)
	spr(2,a.spawnx*8,a.spawny*8)
end

--[[€€€€€ ui €€€€€]]--

--[[
draws the ingame ui
]]--
function draw_game_ui()
	local lvl_name
	lvl_name=cur_lvl-1
	if(cur_lvl>2)then
		rectfill(0,0,127,14,7)
		print("s-36 metrics",2,2,14)
		print("test-"..lvl_name,2,8,5)
		--print total attempts
		print("resilience:",55,2,5)
		print(tot_attempts,110,2,5)
		--print lvl attempts
		print("frustration:",55,8,5)
		print(lvl_attempts,110,8,5)
	end
end

--[[
draws final game results
]]--
function draw_game_over_ui()
	rectfill(0,0,127,14,7)
	print("result: reality entanglement",2,2,14)
	--print total attempts
	print("resilience(deaths):",2,8,5)
	print(tot_attempts,80,8,5)
	print("thank you for playning",20,73,0)
end

--[[€€€ helpers €€€]]--

function blink_text(str,x,y)
	local blink_seq={0,5,6,6,5}
	blink_frame+=1
	if(blink_frame>blink_speed)then
		blink_frame=0
		blink_seq_i+=1
		if(blink_seq_i>#blink_seq)then
			blink_seq_i=1
		end
	end
	print(str,x,y,blink_seq[blink_seq_i])
end

--[[
same as rectfill except that
its parameters are x,y,width,
height and color)
]]--
function rectfill2(_x,_y,_w,_h,_c)
	rectfill(_x,_y,_x+_w-1,_y+_h-1,_c)
end

--[[
takes in table of anim frames
and returns the one to draw	
]]--
function get_frame(anim)
	local s=7 --speed
	return anim[flr(t/s)%#anim+1]
end

--[[
swap between adjecent tiles 
for two-tile animation
]]--
function swap_tile(x,y)
	local tile=mget(x,y)
	mset(x,y,tile+1)
end

function unswap_tile(x,y)
	local	tile=mget(x,y)
	mset(x,y,tile-1)
end

--[[€€€€ juice €€€€]]--
function draw_npcs()
	pal(6,4)
	draw_npc(5,8,{56,57,58,59},false)
	draw_npc(13,5,{57,58,59,56},true)
	pal(6,15)
	draw_npc(11,5,{58,59,56,57},true)
	draw_npc(11,7,{56,57,58,59},false)
	pal(6,4)
	draw_npc(12,7,{57,58,59,56},true)
	pal()
end

function draw_npc(x,y,g,flipped)
	spr(get_frame(g),x*8,y*8,1,1,flipped)
end
	
function ghosts_a(at)
	for i=1, #at do
		add(ghost_avatars,at[i])
	end
--	av=at
	d_t=0
end

--function ghosts_t()
-- local x=lvl_ox
-- local y=lvl_oy
--	for i=x, x+15 do
--		for j=y, y+15 do
--			local temptile=mget(i,j)
--			if(fget(temptile,tele))then
--				local t={}
--				t.x=i%16
--				t.y=j%16
--				add(tv,t)
--			end
--		end
--	end
--end

--[[

]]--
function draw_ui_effect(txt,bck)
	pal(5,txt)
	pal(14,0)
	pal(6,txt)
	pal(7,bck)
	draw_game_ui()	
end

--[[
on-screen death effects
]]--
function draw_death()
	draw_ui_effect(9,8)
	pal(5,0)
	for a in all(ghost_avatars) do
		spr(32,a.x*8,a.y*8,1,1,a.flip,false)
	end
end

--[[
on-screen success screen/effects
]]--
function draw_success()

	if(lvl_success)then
		lvl_success=false
		cls(7)
		pal(6,11)
		map(lvl_ox,lvl_oy)
		pal()
	end
	draw_ui_effect(3,12)
	pal()
	--show avatar on tele
	foreach(ghost_avatars,draw_avatar)
	foreach(ghost_avatars,draw_spawn)
end

--[[€€ dialog window €€]]--

function make_wind()
	wind={}
	wind_open=false
end

function destroy_wind()
	for w in all(wind) do
		del(wind,w)
	end
end

--[[
draws one window
]]--
function add_wind(_x,_y,_w,_h,_txt)
	local w={x=_x,y=_y,
										w=_w,h=_h,
										txt=_txt}
	add(wind,w)
	return w	
end

--[[
draws all winds
]]--
function draw_wind()
	for w in all(wind) do
		local wx,wy,ww,wh=w.x,w.y,w.w,w.h --save tokens
		rectfill2(wx,wy,ww,wh+1,5) --drop shadow
		rectfill2(wx,wy,ww,wh,7) --white
		rectfill2(wx+1,wy+1,ww-2,wh-2,12) --
		rectfill2(wx+2,wy+2,ww-4,wh-4,7) --white
		local lt,rt,lb,rb
		--draw the 2x2 speaker icon
		if(cur_lvl==2)then
			lt={25,27}
			rt={26,28}
			lb={41,43}
			rb={42,44}
		else
			lt={21,23}
			rt={22,24}
			lb={37,39}
			rb={38,40}
		end
		spr(get_frame(lt),wx+3,wy+3)
		spr(get_frame(rt),wx+3+8,wy+3)
		spr(get_frame(lb),wx+3,wy+3+8)
		spr(get_frame(rb),wx+3+8,wy+3+8)
		wx+=4
		wy+=4
		clip(wx,wy,ww-8,wh-8)
		for i=1, #w.txt do
			local txt=w.txt[i]
			print(txt,wx+18,wy+1,0)
			wy+=6
		end
	end
end
-->8
--‰ avatars ‰--

function make_avatars_table()
	avatars={}
	ghost_avatars={}
	a_t=0
	tot_attempts=0
	lvl_attempts=0
	dirx={-1,1,0,0} 
	diry={0,0,-1,1} 
end

function destroy_avatar(a)
	del(avatars,a)
end

function destroy_ghosts()
	for a in all(ghost_avatars) do
		del(ghost_avatars,a)
	end
end

function make_avatar(x,y)
	local a={}
	a.spawnx=x --spawn coord
	a.spawny=y --^^
	a.x=a.spawnx --init pos is spawn
	a.y=a.spawny --^^
	a.ox=0	--offset for smooth walk
	a.oy=0	--^^
	a.sox=0	--starting offset pos for smooth walk
	a.soy=0	--^^
	a.flip=false	--flips spr horizontally
	a.anim={48,49,50,51,52,53,54,55} --anim sprites sequence
	a.move=nil	--dtermines which mvmt anim to play
	a.on_exit=false
	a.on_trap=false
	a.on_breakable=false
	a.prev_tile_x=0
	a.prev_tile_y=0
	add(avatars,a) --add to master table
end

--[[
delegates mvmt updates based on
input. broke out mvmt check and
mvmt update for proper door 
behavior. 
]]--
function update_avatars()
	for i=0,3 do
		if(btnp(i))then
			local a_count=1
			for a in all(avatars) do
				if(levels[cur_lvl].mirror and a_count%2==0)then
					check_a_mvmt(-1*dirx[i+1],diry[i+1],a)
				else
					check_a_mvmt(dirx[i+1],diry[i+1],a)
				end
					a_count+=1
			end
			a_count=1
			for a in all(avatars) do
				if(levels[cur_lvl].mirror and a_count%2==0)then
					update_a_mvmt(-1*dirx[i+1],diry[i+1],a)
				else
					update_a_mvmt(dirx[i+1],diry[i+1],a)
				end
					a_count+=1
			end
		end
	end
end

--[[
checks the destination tile and
updates interactables such as
switches, doors, breakable traps,
and sets a.on_trap and a.on_exit.
*does not move player, sets up
tiles to move.
]]--
function check_a_mvmt(dx,dy,a)
	--add lvl ox/oy to account for solid tiles new levels
	local destx=a.x+dx+lvl_ox	--x coord for where player will move
	local desty=a.y+dy+lvl_oy	--y ^^
	local dest_tile=mget(destx,desty) -- get the tile 
	
	--trigger dialog
	if(fget(dest_tile,wall)and fget(dest_tile,3))then
		dialog=true
		check_narrative()
		fset(16,3,false)
		
	elseif(fget(dest_tile,wall))then
	--check switch, open door
		if(fget(dest_tile,switch))then
			sfx(2)
	 	if(not switch_on)then
				switch_on=true --var to control door tile swap
			else
				switch_on=false										--^^
			end
			foreach(switches,toggle_ds)
			foreach(doors,toggle_ds)
		end
	
	else
		--change breakable
		if(a.breakable==true and fget(dest_tile,wall)==false)then
			local prev_tile=mget(a.prev_tile_x,a.prev_tile_y)
			prime_trap(prev_tile,a.prev_tile_x,a.prev_tile_y)
			a.breakable=false
		end
	
		--check breakable
		if(fget(dest_tile,breakable))then
			a.breakable=true
		end
		
		--check trap
		if(fget(dest_tile,trap))then
			a.on_trap=true
		else
			a.on_trap=false
		end
	
		--check exit
		if(fget(dest_tile,tele))then
			a.on_exit=true
		else
			a.on_exit=false
		end
	end
end

--[[
moves avatar if next tile is not
a wall. sets up smooth animation.
]]--
function update_a_mvmt(dx,dy,a)
	local destx=a.x+dx+lvl_ox	--x coord for where player will move
	local desty=a.y+dy+lvl_oy	--y ^^
	local dest_tile=mget(destx,desty) -- get the tile 
	
	if(fget(dest_tile,wall))then
		
		a.move=false
		a.sox=dx*8	--reset offset of where spr will go
		a.soy=dy*8	--^^
		a.ox=0		--set actual offest to 0 b/c we aren't moving avatar offset
		a.oy=0		--^^
		a_t=0	--reset mvmt timer
	else
		
		a.move=true
		a.x+=dx
		a.y+=dy
		a.prev_tile_x=destx
		a.prev_tile_y=desty
		
		--set up smooth animation
		a.sox=-dx*8	--reset starting offset
		a.soy=-dy*8	--^^
		a.ox=a.sox		--set actual offest to starting offset
		a.oy=a.soy		--^^
		a_t=0	--reset mvmt timer
	end
	flip_a_x(dx,a)
	_upd=update_a_walk
end

--[[€€€ helpers €€€]]--

--[[
checks if avatar is on an
interactable tile.
]]--
function check_a_interaction(a)
	local curr_tile=mget(a.x,a.y)
 a.on_trap=check_a_on_trap(curr_tile)
end

--[[
checks if avatar is on a trap,
used for timed trap toggle.
]]--
function check_a_on_trap(a)
	local curr_tile=mget(a.x+lvl_ox,a.y+lvl_oy)
	if(fget(curr_tile,trap))then
		a.on_trap=true
	else 
		return false
	end
end

--[[
checks if avatar is on a switch,
used to open/close doors.
]]--
function check_a_on_wall()
	local curr_tile=mget(a.x+lvl_ox,a.y+lvl_oy)
	if(fget(curr_tile,wall))then
		return true
	else
		return false
	end
end

--[[
smooth moves to next tile
]]--
function a_walk_to_space(a)
	--reduces ox,oy to zero, allowing sprite to match actual pos
	a.ox=a.sox*(1-a_t)
	a.oy=a.soy*(1-a_t)
end

--[[
smooth bump
]]--
function a_walk_to_wall(a)
	sfx(3)
	--first half of anim
	if(a_t<0.5)then
		--increases ox,oy, allowing sprite to move away from actual pos
		a.ox=a.sox*(a_t)
		a.oy=a.soy*(a_t)
	else
		--reduces ox,oy to zero, allowing sprite to match actual pos
		a.ox=a.sox*(1-a_t)
		a.oy=a.soy*(1-a_t)
	end
end

--[[
flips avatar direction depending
on input (left or right)
]]--
function flip_a_x(_dx,_a)
	if(_dx<0)then
		_a.flip=true
	elseif(_dx>0)then
		_a.flip=false
	end
end
-->8
--’ interactables ’ --
--traps, doors, switches

function make_tile_flags()
	wall=0
	tele=1
	trap=2
	breakable=3
	switch=4
	door=5	
	tog_on=6
	tog_off=7
end

function make_interactables()
	switch_on=false
	interactables_made=false
	toggle_tiles_in_lvl=false
	allow_toggle=true
	doors={}
	switches={}
	breakables={}
	toggles={}
end

--[[
searches map for door flag,
and creates table instance
for all doors in the level.
]]--
function make_interactables_for_lvl()
	local x=lvl_ox
	local y=lvl_oy
	--check map
	for i=x, x+15 do
		for j=y, y+15 do
			local temptile=mget(i,j)
		
			--make doors
			if(fget(temptile,door))then
				local d={}
				d.x=i
				d.y=j
				d.init_spr=mget(i,j)
				d.curr_spr=mget(i,j)
				if(curr_spr==7)then
					d.open=false
				else
					d.open=true
				end
				add(doors,d)
			
				--make switches
			elseif(fget(temptile,switch))then
				local s={}
				s.x=i
				s.y=j
				s.init_spr=mget(i,j)
				s.curr_spr=mget(i,j)
				add(switches,s)
				
			--make breakables
			elseif(fget(temptile,breakable))then
				local b={}
				b.x=i
				b.y=j
				b.init_spr=mget(i,j)
				b.curr_spr=mget(i,j)
				add(breakables,b)		
			
			--toggle traps
			elseif(fget(temptile,tog_on) or fget(temptile,tog_off))then
				local t={}
				t.x=i
				t.y=j
				t.init_spr=mget(i,j)
				t.curr_spr=mget(i,j)
				add(toggles,t)
			
			--teleporter
			elseif(fget(temptile,tele))then
				local l={}
				l.x=i
				l.y=j
				l.init_spr=mget(i,j)
				l.curr_spr=mget(i,j)
				add(teles,l)
			end
		end
	end
--	ghosts_t()
	interactables_made=true
end

--[[
resets all breakable traps
to the original state
]]--
function reset_interactables()
	foreach(doors,reset_i)
	foreach(switches,reset_i)
	foreach(breakables,reset_i)
	foreach(toggles,reset_i)
end

--[[
clears the interactable tables
so it can repopulate with the
new level's interactables.
]]--
function	destroy_interactables()
	destroy_i(doors)
	destroy_i(switches)
	destroy_i(breakables)
	destroy_i(toggles)
	destroy_i(teles)
	interactables_made=false
end

function destroy_i(q)
	for i in all(q) do
		del(q,i)
	end
end

--[[
resets the door/switch to
initial its tile.
]]--
function reset_i(q)
	mset(q.x,q.y,q.init_spr)
	q.curr_spr=q.init_spr
end

--[[
primes breakable tiles to its 
next stage/tile
]]--
function prime_trap(tile,x,y)
	mset(x,y,tile-1)
end

--[[
toggles door/switch tile
between open and closed.
called on switch hit.
]]--
function toggle_ds(ds)
	local tile=mget(ds.x,ds.y)
	if(tile==ds.init_spr)then
		if(tile%2==0)then
			mset(ds.x,ds.y,ds.init_spr-1)
	 else
	 	mset(ds.x,ds.y,ds.init_spr+1)
	 end
	else
			mset(ds.x,ds.y,ds.init_spr)
	end
end

--[[
toggles between two sprites, 
used for the timing trap tiles.
has its own timing, so is not
included in othr map-search
functions.
]]--
function toggle_tiles(t)
	if(fget(t.curr_spr,tog_on))then
		t.curr_spr+=1
	elseif(fget(t.curr_spr,tog_off))then
		t.curr_spr-=1
	end
	sfx(0)
	mset(t.x,t.y,t.curr_spr)	
end

--[[€€€ helper €€€]]--

--[[
checks if a tile matches a flag
]]--
function is_tile(tile_type,x,y)
	local tile=mget(x,y)
	local	has_flag=fget(tile,tile_type)
	return has_flag
end

-->8
--‚ level handler ‚--

function make_lvl_table()
	levels={}
	cur_lvl=1 --set to 1
	lvl_ox=0 --tracks the starting pos for map lvl changes
	lvl_oy=0	--tracks the ^^
	l_t=0 --timeout for level change
	lvl_success=false --success effect
end

function destroy_lvl(l)
	del(levels,l)
end

--[[
takes metadata and creates a 
level with and id, number of 
avatars, a table for avatar x,
a table for avatar y.
]]--
function make_l(id,_anum,ax,ay,mirror)--_btnum,btx,bty)
	local l={}
	l.id=id
	l.anum=_anum
	l.spawnx={}
	l.spawny={}
	l.mirror=mirror
	for i=1, l.anum do --get each x,y pair and add to table
		add(l.spawnx,ax[i])
		add(l.spawny,ay[i])
	end
	add(levels,l)
end

--[[
make all the levels with their
unique meta data.
]]--
function make_lvls()
	--lvl id,a num,{ax},{ay}
	make_l(1,1,{6},{14},false) --1,1
	make_l(2,1,{1},{14},false) --1,2
	make_l(3,1,{3},{14},false) --1,3
	make_l(4,1,{3},{14},false) --1,4
	make_l(5,1,{3},{14},false) --1,5
	make_l(6,1,{3},{14},false) --1,6
	make_l(7,1,{3},{14},false) --1,7
	make_l(8,1,{5},{14},false) --1,8
	--2 avatar, normal clone
	make_l(9,2,{4,13},{14,14},false) --2,1
	make_l(10,2,{1,9},{14,14},false) --2,2
	make_l(11,2,{1,9},{14,14},false) --2,3 (first offset)
	--introduce offset movement
	make_l(12,2,{4,12},{14,14},false) --2,4
	make_l(13,2,{2,12},{14,14},false) --2,5
	make_l(14,2,{1,10},{12,13},false) --2,6
	make_l(15,2,{4,12},{14,14},false) --2,7
	make_l(16,2,{2,13},{14,14},false) --2,8
	make_l(17,2,{6,14},{14,14},false) --3,1
	make_l(18,2,{3,12},{14,14},false) --3,2
	make_l(19,2,{1,9},{14,14},false) --3,3
	make_l(20,2,{3,7},{8,14},false) --3,4
	make_l(21,2,{6,11},{14,13},false) --3,5
	--split to 4
	make_l(22,4,{4,1,9,9},{4,12,3,13},false) --3,6
	make_l(23,4,{1,1,9,9},{7,13,7,14},false) --3,7
	make_l(24,4,{1,4,12,9},{4,12,4,11},false) --3,8
	--8
	make_l(25,8,{6,6,6,6,10,12,9,9},{5,8,11,14,4,7,11,13},false) --4,1
	make_l(26,8,{1,2,3,4,12,11,10,9},{5,8,11,14,5,8,11,14},false) --4,2
	make_l(27,8,{1,4,6,1,9,12,14,9},{5,4,7,14,5,4,7,14},false)
	--2, flipped mvmnt
	make_l(28,2,{2,13},{14,14},true)
	make_l(29,2,{3,13},{14,14},true)
	make_l(30,2,{3,12},{9,9},true)
	make_l(31,2,{6,9},{14,14},true)
	--end
	make_l(32,17,{2,4,6,8,10,12,
														 3,5,9,11,13,
														 2,4,6,8,10,12},
														{11,11,11,11,11,11,
															12,12,12,12,12,
															13,13,13,13,13,13},false)
end

--[[
checks if avatar is on a trap. 
if it is, then restart the lvl.
]]--
function check_lvl_trap()
	local on_trap_count=0
	for i=1, #avatars do
		if(avatars[i].on_trap)then
			on_trap_count+=1
		end
	end
	--check if one has touched trap
	if(on_trap_count>0)then
		--restart level
		sfx(5)
		tot_attempts+=1
		lvl_attempts+=1
		load_lvl()
	end
end

--[[
checks if all avatars are on
the exti tiles. if yes, then 
loads the next level.
]]--
function check_lvl_exit()
--	l_t=0
	local on_exit_count=0
	for i=1, #avatars do
		if(avatars[i].on_exit)then
			on_exit_count+=1
		end
	end
	--check the match and return
	if(on_exit_count==#avatars)then
		-- load next level
		lvl_success=true
		sfx(1)
		cur_lvl+=1
		if(cur_lvl==32)then
			game_over=true
		elseif(cur_lvl>=33)then
			cur_lvl=1
			game_over=false
		end
		load_lvl()
	end
end

--[[
prepares level for reset
]]--
function load_lvl()
	if(lvl_success)then
		reset_lvl()
		_drw=draw_success
	else
		_drw=draw_death
	end
	l_t=0
	ghosts_a(avatars)
	_upd=update_lvl
end

--[[
resets lvl stuff so lvl can be 
loaded and interactables still
work
having trouble reset timers?
]]--
function reset_lvl()
	destroy_interactables()
	destroy_wind()
	n_delivered=false
	lvl_attempts=0
	l_t=0
end

--[[
spawns avatar in given level
]]--
function spawn_a_in_l(b)
	for i=1, levels[b].anum do
		make_avatar(levels[b].spawnx[i],levels[b].spawny[i])
	end
end


-->8
--‡ narrative ‡--

function make_narrative()
--	narrative={}
	line_count=1
	line_t=0
	dialog=false
	n_delivered=false
end

--[[
updates line count var
]]--
function update_line_count()
	line_count+=1
end

--[[
clears and creates a new "line"
for a wind dialog box.
]]--
function add_line(txt1,txt2)
	destroy_wind()
	add_wind(0,16,128,21,{txt1,txt2})
end

--[[
clears wind dialog from screen.
]]--
function end_wind()
	destroy_wind()
	wind_open=false
	line_count=1
end

--[[
checks level and line count vars
to display correct dialog.
]]--
function check_narrative()
	local x,y,w,h=3,3,122,22
	if(cur_lvl==2 and dialog)then
		wind_open=true	
		if(line_count==1)then
			add_line(																--
			"ah, test-subject 36!",
			"(— to advance)")
		elseif(line_count==2)then
			add_line(																--
			"congratulations to you",
			"on behalf of the..")
		elseif(line_count==3)then
			add_line(																--
			"..telco coorporation of",
			"teleportation tech,")
		elseif(line_count==4)then
			add_line(																--
			"it is your test day!", 
			"you will be testing the")
		elseif(line_count==5)then
			add_line(																--
			"telco-t83, our newest",
			"prototy-i mean model.")
		elseif(line_count==6)then
			add_line(																--
			"totally safe for you, so",
			"no need to don't worry.")
		elseif(line_count==7)then
			add_line(																--
			"i will talk to you over",
			"the telecom to check in.")
		elseif(line_count==8)then
			add_line(																--
			"open the door with the",
			"switch and step on to..")
		elseif(line_count==9)then
			add_line(																--
			"the teleporter to begin",
			"your test. good luck!")
		else
			n_delivered=true
			end_wind()
			dialog=false
		end
	-----------------------------
	elseif(cur_lvl==3)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"*telcom* see, it's safe,",
			"telco guaranteed!")
		else
			n_delivered=true
			end_wind()
		end
	-----------------------------
	elseif(cur_lvl==7)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"you're doing great! just",
			"a few more tests.")
		else
			n_delivered=true
			end_wind()
		end
 -----------------------------
	elseif(cur_lvl==9)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"uuh, two of you?! there",
			"must be a bug. don't..")
		elseif(line_count==2)then
			add_line(																--
			"..worry. i will fix it",
			"soon, just stay in sync!")
		else
			n_delivered=true
			end_wind()
		end
 -----------------------------
	elseif(cur_lvl==12)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"you're out of sync! be ",
			"careful, reality is a.. ")
		elseif(line_count==2)then
			add_line(																--
			"delicate thing! ",
			"")
		else
			n_delivered=true
			end_wind()
		end
 -----------------------------
	elseif(cur_lvl==18)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"not much progress, but ",
			"your test results are ")
		elseif(line_count==2)then
			add_line(																--
			"looking great! i hope i",
			"don't get fired for this")
		else
			n_delivered=true
			end_wind()
		end
 -----------------------------
	elseif(cur_lvl==21)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"i think i've fixed it!",
			"get to the teleporter!")
		else
			n_delivered=true
			end_wind()
		end
 -----------------------------
	elseif(cur_lvl==22)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"ŒŒŒŒ................",
			"i'll call my supervisor.")
		else
			n_delivered=true
			end_wind()
		end
 -----------------------------
	elseif(cur_lvl==24)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"alright, my supervisor",
			"said to try to get back")
		elseif(line_count==2)then
			add_line(																--
			"in sync with the clones.",
			"")
		else
			n_delivered=true
			end_wind()
		end
	-----------------------------
	elseif(cur_lvl==25)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"eight! oh no............",
			"i'm just an intern!")
		else
			n_delivered=true
			end_wind()
		end
	-----------------------------
	elseif(cur_lvl==27)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"supervisor here! try to",
			"get back in sync!.. hey")
		elseif(line_count==2)then
			add_line(																--
			"intern, what did you do",
			"to mess this up?!")
		else
			n_delivered=true
			end_wind()
		end
	-----------------------------
	elseif(cur_lvl==28)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"back to two. progress..",
			"wait! the calibration..")
		elseif(line_count==2)then
			add_line(																--
			"is off! these numbers are",
			"all backwards!")
		else
			n_delivered=true
			end_wind()
		end
 -----------------------------
	elseif(cur_lvl==32)then
		wind_open=true
		if(line_count==1)then
			add_line(																--
			"yikes. surry buddy, but",
			"your bodies are too..")
		elseif(line_count==2)then
			add_line(																--
			"entangled in time, there",
			"is nothing we can do..")
		elseif(line_count==3)then
			add_line(																--
			"on behalf of telco, we",
			"thank you for your..")
		elseif(line_count==4)then
			add_line(																--
			"service to science and",
			"the futre. over and out.")
		else
			n_delivered=true
			game_over=true
			end_wind()
		end
	end
end

-->8
--Š save state Š--

function make_code_menu()
	code={}
	code_c=7
	code_t=0 --code timer
	pause_code=""
	keypad={}
	px={35,63,92}
	py={50,58,66,74}
	make_keypad("‹",33,py[1])
	make_keypad("del",59,py[1])
	make_keypad("‘",90,py[1])
	make_keypad("1",px[1],py[2])
	make_keypad("2",px[2],py[2])
	make_keypad("3",px[3],py[2])
	make_keypad("4",px[1],py[3])
	make_keypad("5",px[2],py[3])
	make_keypad("6",px[3],py[3])
	make_keypad("7",px[1],py[4])
	make_keypad("8",px[2],py[4])
	make_keypad("9",px[3],py[4])
	c={} --cursor
	c.gridx=1 --1,2,3
	c.gridy=1 --1,2,3,4
	c.px=px[1]
	c.py=py[1]
end

function make_keypad(_str,_x,_y)
	local k={}
	k.str=_str
	k.x=_x
	k.y=_y
	add(keypad,k)
end

--[[
moves cursor in in grid pos
]]--
function move_cursor(dx,dy)
	if(dx==1 and c.gridx~=3)then
		c.gridx+=1
	elseif(dx==-1 and c.gridx~=1)then
		c.gridx-=1
	end
	if(dy==1 and c.gridy~=4)then
		c.gridy+=1
	elseif(dy==-1 and c.gridy~=1)then
			c.gridy-=1
	end
	c.px=px[c.gridx]
	c.py=py[c.gridy]
end

--[[
handles code menu input on the 
mock keypad
]]--
function add_to_code()
	local input
	if(c.gridy==1)then
		if(c.gridx==1)then
			game_paused=false
			_upd=update_game
			_drw=draw_game
		elseif(c.gridx==2)then
			del(code,code[#code])
		elseif(c.gridx==3)then
			local config=configure_code()
			if(config)then
				tot_attempts=dget(0)
				code_c=13
				reset_lvl()
				_upd=update_lvl
			else
				code_c=8
				code_t=0
			end
		end
	else
		if(c.gridx==1 and c.gridy==2)then
			input=4
		elseif(c.gridx==2 and c.gridy==2)then
			input=5
		elseif(c.gridx==3 and c.gridy==2)then
			input=6
		elseif(c.gridx==1 and c.gridy==3)then
			input=7
		elseif(c.gridx==2 and c.gridy==3)then
			input=8
		elseif(c.gridx==3 and c.gridy==3)then
			input=9
		elseif(c.gridx==1 and c.gridy==4)then
			input=10
		elseif(c.gridx==2 and c.gridy==4)then
			input=11
		elseif(c.gridx==3 and c.gridy==4)then	
			input=12
		end
		if(#code<4)then
			add(code,keypad[input].str)
		end
	end
end

--[[
configures level to load based
on code return false if code
is invalid
]]--
function configure_code()
	local attempt=true
	local passcode=""
	for i=1, #code do
		passcode=passcode..code[i]
	end
	--super check the code
	if(passcode=="9393")then
		cur_lvl=2
	elseif(passcode=="7413")then
		cur_lvl=3
	elseif(passcode=="1124")then
		cur_lvl=4
	elseif(passcode=="2567")then
		cur_lvl=5
	elseif(passcode=="3939")then
		cur_lvl=6
	elseif(passcode=="4511")then
		cur_lvl=7
	elseif(passcode=="6771")then
		cur_lvl=8
	elseif(passcode=="9185")then
		cur_lvl=9
	elseif(passcode=="4771")then
		cur_lvl=10
	elseif(passcode=="7433")then
		cur_lvl=11
	elseif(passcode=="3439")then
		cur_lvl=12
	elseif(passcode=="5218")then
		cur_lvl=13
	elseif(passcode=="1486")then
		cur_lvl=14
	elseif(passcode=="5482")then
		cur_lvl=15
	elseif(passcode=="4481")then
		cur_lvl=16
	elseif(passcode=="7177")then
		cur_lvl=17
	elseif(passcode=="4822")then
		cur_lvl=18
	elseif(passcode=="7282")then
		cur_lvl=19
	elseif(passcode=="1164")then
		cur_lvl=20
	elseif(passcode=="6624")then
		cur_lvl=21
	elseif(passcode=="7432")then
		cur_lvl=22
	elseif(passcode=="3416")then
		cur_lvl=23
	elseif(passcode=="5981")then
		cur_lvl=24
	elseif(passcode=="3155")then
		cur_lvl=25
	elseif(passcode=="7811")then
		cur_lvl=26
	elseif(passcode=="6116")then
		cur_lvl=27
	elseif(passcode=="2279")then
		cur_lvl=28
	elseif(passcode=="1941")then
		cur_lvl=29
	elseif(passcode=="7354")then
		cur_lvl=30
	elseif(passcode=="8814")then
		cur_lvl=31
	elseif(passcode=="3197")then
		cur_lvl=32
	else
		attempt=false
	end
	return attempt
end

--[[
returns pause code depending
on the level. supa-if check
]]--
function	get_pause_code()
	local _code=-1
	if(cur_lvl==2)then
		_code="9393"
	elseif(cur_lvl==3)then
		_code="7413"
	elseif(cur_lvl==4)then
  _code="1124"
	elseif(cur_lvl==5)then
		_code="2567"
	elseif(cur_lvl==6)then
		_code="3939"
	elseif(cur_lvl==7)then
		_code="4511"
	elseif(cur_lvl==8)then
		_code="6771"
	elseif(cur_lvl==9)then
		_code="9185"
	elseif(cur_lvl==10)then
		_code="4771"
	elseif(cur_lvl==11)then
		_code="7433"
	elseif(cur_lvl==12)then
		_code="3439"
	elseif(cur_lvl==13)then
		_code="5218"
	elseif(cur_lvl==14)then
		_code="1486"
	elseif(cur_lvl==15)then
		_code="5482"
	elseif(cur_lvl==16)then
		_code="4481"
	elseif(cur_lvl==17)then
		_code="7177"
	elseif(cur_lvl==18)then
		_code="4822"
	elseif(cur_lvl==19)then
		_code="7282"
	elseif(cur_lvl==20)then
		_code="1164"
	elseif(cur_lvl==21)then
		_code="6624"
	elseif(cur_lvl==22)then
		_code="7432"
	elseif(cur_lvl==23)then
		_code="3416"
	elseif(cur_lvl==24)then
		_code="5981"
	elseif(cur_lvl==25)then
		_code="3155"
	elseif(cur_lvl==26)then
		_code="7811"
	elseif(cur_lvl==27)then
		_code="6116"
	elseif(cur_lvl==28)then
		_code="2279"
	elseif(cur_lvl==29)then
		_code="1941"
	elseif(cur_lvl==30)then
		_code="7354"
	elseif(cur_lvl==31)then
		_code="8814"
	elseif(cur_lvl==32)then
		_code="3197"
	end
	return _code
end
__gfx__
0000000000066000000000001111111100000000ffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000077777777
0000000006677660006666001666666100000000fcccc7cff777777ff111111f0000000000000000000000000000000000000000000000000000000077777557
00700700688ff886067777601660606100000000ffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000077777777
0007700067f88f7667eeee7616060661000ff000f666666ff666666fcccccc7c000ff00000000000000000000000000000000000000000000000000066666666
00077000688ff8866ee77ee61660606100000000f666666ff111111fcccccc7cfff77fff000000000000000000000000000000000000000000000000656b5686
007007005667766567eeee761606066100000000f166661ff166661fcccccc7cf777777f00000000000000000000000000000000000000000000000066666666
0000000005566550067777601666666100000000f111111ff666666fcccccc7cf777777f00000000000000000000000000000000000000000000000066666666
0000000000055000006666001111111100000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000066666666
00000000000660000006600000066000000b00005555555555555555555555555555555555555555555555555555555555555555000000000000000066666666
00000000066776600667766006677660000bb0005777777777777775577777777777777550011111111111055001111111111105000000000000000067777776
0000000068877886699779966ff77ff6000bbbb05ffffff55ffffff55ffffff55ffffff550111144444411155011114444441115000000000000000067bbbb76
000660006778877667799776677ff776000bb000577777161677777557777761617777755111144444444115511114444444411500000000000000006bb77bb6
0008800068877886699779966ff77ff6000b00005ffff555555ffff55ffff555555ffff551114444444441155111444444444115000000000000000067bbbb76
00000000566776655667766556677665000000005777716161677775577776161617777551114444444444155111444444444415000000000000000056777765
00000000055665500556655005566550000000005fff55555555fff55fff55555555fff551144479447944155114447944794415000000000000000005666650
00000000000550000005500000055000000000005777761616177775577771616167777551144444444444155114444444444415000000000000000000555500
00555550000660000006600000000000000000005fffff5555fffff55fffff5555fffff551144444444444155114444444444415000000000000000000000000
05555555066776600667766000000000000000005777777777777775577777777777777551144445554444155114444455444415000000000000000000000000
05556660688778866997799600000000000000005666666666666665566666666666666551114444444441155111444455444115000000000000000000000000
5556666667788776677997760000000000000000566d66d6d6d6c765566d66d6d6d6c76551111444444111155111144444411115000000000000000000000000
557666606887788669977996000000000000000056ddd6666666cc6556ddd6666666cc6551777444444777155177744444477715000000000000000000000000
57677776566776655667766500000000000000005666666666666665566666666666666557777774477777755777777447777775000000000000000000000000
05777750055665500556655000000000000000005555555555555555555555555555555555555555555555555555555555555555000000000000000000000000
00600600000550000005500011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ddddd0000dddd0000000000000000000dddddd0000ddd000000000000000000001111000000000000111100011111000000000000000000000000000000000
0ddddddd00dddddd00ddddd000ddddd00dddddd000dddddd00ddddd000ddddd00011661100011110001166110116666100000000000000000000000000000000
0dddeee00dddeee00ddddddd0dddddddddddeee00dddeee00ddddddd0ddddddd0116666600116611011666660116565600000000000000000000000000000000
ddde1e1e0dde1e1e0ddddddd0dde1e1dddde1e1e0dde1e1e0ddddddd0dde1e1d0166565601166666016656560166666100000000000000000000000000000000
ddfeeee0ddfeeee0ddde1e1eddfeeeedddfeeee0ddfeeee0dddeeeeeddfeeee00116666101665656055666610555555000000000000000000000000000000000
dfeffffedfeffffeddfeeeeddfeffffddfeffffedfeffff0ddfeeeeddefffff00565555005566661065555500565556000000000000000000000000000000000
0dffffd0ddffffd0dfeffffeddfffffeddffffd0ddffffdedefffffeddffffde0555555006555550055555600555555000000000000000000000000000000000
00e00e000dedded0ddeffeddddedded000e00e000dedded00deffed00dedded00060060000600600006006000060060000000000000000000000000000000000
00000007666666666666666666666666ffffffff1111111111111111111111116666666666666666111111111111111111111111111111111111111111111111
00000007676776767777777767777777f111111f1666666666666666666666616666666666666666166666661666666116666666666666616666666666666666
00000007666666666766676667666677ffffffff1666666666666666666666616666666666666666166666661666666116666666666666616666666666666666
00000006676776766767676767677677666666661666666666666666666666616666666116666666111111111666666116666661166666616666666666666666
00000006676776766767676767677677666666661666666666666666666666616666666116666666155555551666666116666661166666616666666666666666
00000006666666666667666767666677666666661666666666666666666666616666666116666666157777771666666116666661166666616666666666666666
00000006676776767777777767777777666666661666666666666666666666616666666116666666155555551666666116666661166666616666666666666666
00000005666666666666666667777776666666661666666666666666666666616666666116666666111111111666666116666661166666616666666116666666
00000005777775000000000000000000000000001666666666666666666666616666666116666666111111111666666116666661166666611666666666666661
00000005777775000000000000000000000000001666666666666666666666616666666666666666666666661666666116666666666666616666666666666666
00000006777775000000000000000000000000001666666666666666666666616666666666666666666666661666666116666666666666616666666666666666
00000006777775000000000000000000000000001666666666666666666666616666666116666666111111111666666111111111111111116666666666666666
00000006777775000000000000000000000000001666666666666666666666616666666116666666555555551666666115555555555555516666666666666666
00000005777775000000000000000000000000001666666666666666666666616666666116666666777777771666666115777777777777516666666666666666
00000000777775000000000000000000000000001666666666666666666666616666666116666666555555551666666115555555555555516666666666666666
00000000777775000000000000000000000000001666666666666666666666616666666116666666111111111666666111111111111111111666666666666661
00000000666666660000000066666666666666661666666666666666666666611666666666666661111111111666666111111111111111111666666116666661
00000000676776760000000066666666666666661666666666666666666666611666666666666661666666611666666166666666666666661666666666666661
00000000666666660000000066666666666666661666666666666666666666611666666666666661666666611666666166666666666666661666666666666661
00000000676776760000000066666666666666661111111111111111111111111666666116666661111111111111111166666661166666661666666666666661
00000000676776760000000066666666666666661555555555555555555555511666666116666661555555511555555166666661166666661666666666666661
00000000666666660000000066666666666666661577777777777777777777511666666116666661777777511777777166666661166666661666666666666661
00000000676776760000000066666666666666661555555555555555555555511666666116666661555555511555555166666661166666661666666666666661
00000000666666660000000066666661166666661111111111111111111111111666666116666661111111111111111166666661166666661666666666666661
00000000666666611666666666666661166666666666666616666661111111111666666116666661166666661111111166666666111111111666666100000000
00000000666666666666666666666666666666666666666666666666666666661666666666666661166666661666666166666666666666666666666600000000
00000000666666666666666666666666666666666666666666666666666666661666666666666661166666661666666166666666666666666666666600000000
00000000111111111111111166666666666666666666666666666666666666661666666116666661116666661111111116666661166666611666666100000000
00000000555555555555555566666666666666666666666666666666666666661666666116666661156666661555555116666661166666611666666100000000
00000000777777777777777766666666666666666666666666666666666666661666666116666661176666661577775116666661166666611666666100000000
00000000555555555555555566666666666666666666666666666666666666661666666116666661166666661555555116666661166666611666666100000000
00000000111111111111111166666666666666661111111166666666111111111666666116666661166666661111111116666661166666611666666100000000
65656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565
65656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565
65656565656565653657466565656565656565656565466565656565656565656565656536574665656565656565656565656565656565656565656536574665
65656536574665656565653657466565656565656536574665656565653657466565656565365746656565656536574665656565656565656565656565656565
846666666666669475f0566666666694656565656565656565656565656565658466666676f05694846666666666669465656565656584666666666676f05694
65658476f056946565846676f0569465846666666676f05584666666c776f055846666666676f055846666666676f05584666666666666948466666666666694
754022222210f05575f1222222104055846666666666946565656565656565657540404080f14055754022222222225565656565656575404040407040f14055
65657550f150569465754040f1405694754040405040f15575204040b640f155754040401000f155754040104040f15575404040404040557540404040404055
754040104040f15575404010404040557610101010105694846666666694656575404040a4a5a595754040104050405565653657466585a68030547440404055
65847640404040556537744040404055754040402040315575401040404040557540104040124055757040b74040405575201040404040557540104020104055
75401222124040557540b412224040551031313131311055754040404055656575404040404040557540104012f04055658476f05694754040405617d6646447
847610b710704055656585a5a670a495754040404040405575404040404040557540404040124055754080404040405575104040104040557540404010404055
75313131313110557540b6313131405510313140313110557540b440a427669475404031401040557570401222f14055657540f1405575404040704055656565
751040404040105565847610404040557540401040404055754010104040405575404010b7002255754040404040225575224040404040557540404040404055
75401040404040557540404040104055103140b7403110557540b540404040557540404010404055751040401010105565754040405575504040b44056669465
75404040b7104055847640104040a495754040104040405575404040402240557540404040404055754010504022405575404040404010557540404040101055
7540401040404055754040404010405510313140313110557540b640547440557540404040104055751040b74040405565754040405585a5a5a5974080405694
75807040404040557540104040101055376464646464644737646464e477f4473764646464e477e53764646464e477e585a5a670a4a5a59585a5a5a670b4f055
754040b74010105575404010104040551031314031311055754040a495754055754080501040405575104040404040558417a631a42796804070c5d440b44055
75402110101010557550b71080b7105584666666666666948466666676f05694846666666676f055846666666676f05575401040b74010557510401040b6f155
754040404040405575104040404040557410104010101055377440405676405575104040404040557540104010404055751040404010b540b74040b540b64055
85a68040104010557540313140314055754040104010f0557540404040f18055757040404012f155754040401040f1557522408040404055754040b780404055
75104040404040557540b7401040a4953774104010f01056c77640b44040405575104040121210557540401040104055764040314040b64040b440b540404055
7510404010401055754031b421104055754040b74040f1557540404040404055754040404012105575401040b7404055752240404040a4957520404022404055
754040404040405575312131313131556575104010f14010b51040b540405447751070b72222405575404010504080b510313150314010b440b540c5a6705447
75401040b44010557531a4d5405031557520404040104055754040401040405575401040104040557540404022801055754012402040f0557510404040104055
754010101010105585a61010222240558476103150104010b5f070b5404055657540404040404055753140403140a495744040314040c4d570b6408040405565
75401040b640a49575404020703140557510403140404055752040314040405575403140502240557521404040401055754040404040f1557540404050404055
754040404040205575313131313120557510104040404010b5f140b54010556575404040404040557540104080401055751040404010b5404040546464644765
75401040704020557510b43030304055752240404040105575404022401040557540408040401055754040404010105537744040404010557540404040404055
37646464646464473764646464646447376464646464646467646464646464473764646464646447376464646464644737646410646467646464476565656565
37646464646464473764676464646447376464646464644737646464646464473764646464646447376464646464644765376464646464473764646464646447
65656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565
65656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656556666666666666666666666666666676
65656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565
65656565656565656565656565656565656565656565656565656565656565656565656565365746656464646464646422122212221222122212121222122212
65656565656565656565656565656565656565656565656536574665656565656565656565656565656565656565656565656565656565656565656565656565
6565656565656565656565656565656565656565656565656565656565656565846666666676f055846666666666669412a4d7a5a5a5a5a5a5a5a5a5a5a5a622
84666666666694658466666666666694846666666666669475f05666666666948466666666666694846666666666669465656565656565656565656565656565
6565656565656565656565656565656536574665656565656565656536574665754022408070f155754010407040f05522c4d5c4a5a5a6b4c4a5a6c4a5a5d412
7640404022f056c7761040404040f055754040404040f05575f17040504040557540403040404055751240304040405565656565656565656565656565656565
8466666666666694846666666666669475f05666666666948466666676f05694757010401040505585a5a680b740f15512b50087a5a600b5c5a5a6b50000b522
1040404040f140b5108040404040f155754040214080f15575404040404040557540407040404055754040704040405565656536574665656565365746656565
754040224040f055754010404040405575f13140404040557512221222f110557540b740b7404055754040401012125522b5b4e6646474e6646474e66464f612
c6a5a5a5a5a5a5e7a5a5a5a65040a49585a5a5a5a5a5f09585a5a5a5a5a5a5957580a4a5a5a5a5957580a4a5a5a5a59565846676f0566694846676f056666694
754040222110f1557540104040401055751012101040405575404040403140557540402140104055754040404022225512567656666676566666765666667622
7540404040f040b5108040404040f055754040404080f15575f04010404040557540404040404055754040401240405584764040f1104055754040f112401055
75104022214040557510404010404055754040404040105575104040404040557510104040104055751040404040405522122212221222122212221222122212
7540404031f140e6741040404080f155754040402240405575f1704040b431557540404012402155754040404040405575402222404040557540401240402255
7540104040b7105575f0401040404055754040104012405575401040b740105575224040214050557540b71040504055c4a5a5a5a5a5a5a5a5a5a5a5a5a5a5d4
85a5a5a5a5a5d64785a5a5d7a5a5a55585a5a5a5a5a5a59585a5a5a5a5d5f05585a5a5a5a5a6705585a5a5a5a5a6705575401040222222557540404040404055
754040404040405575f140404010405575407020b7221255754040102040805575124040404010557540404040314055b53232323232323232323232323232b5
7540104040f05694754040b64040f05575f0224040404055755040404080f155754040402150405575f040404040405575404040404040557540104022222255
85a64040124040557540404010404055752140b74040a495755040404010125575101070a4a5a5957510b780a4a5d647b54040404040404040404040404040b5
7550404040f14055754040404040f15575f17040404040557540402240224055754010404040405575f110404012305585a6121040402255754022124010a495
751240402210405575104010b71240557540402140104055751040404040125575224040404040557540403140405565b5402040204020f020402040204040b5
85a640a4a5a5a59585a5a622a4a5a59585a5a5a5a5a5a59585a5a5a5a5a5a5957540404010404055754040401040405575402240104040557540404040224055
75101010404040557540404022224055754010404040405575104040224040557540104040b740557540214022405694b5404020402040f140204020402040b5
7540404040f04086764040404040f05575f0404040404055754040404012f0557540104040f04055753050304030405575401040404040557540404040404055
754040404010405575401040404010557540404010504055754040104010405575404040401040557540402210221055b54020402040204020402040204040b5
7540224040f140b5108040404040f15575f1702140404055754040404080f1557540104080f1705575404040401240557540404040b440557540404010404055
751040204040405575404040402040557510404040404055754040404040544775504040404020557520402222405055b54040404040404040404040404040b5
37646464646464676464646464646447376464646464644737646464646464473764646464646447376464646464644737646464646764473764646464646447
376464646464644737646464646464473764646464646447376464646464476537646464646464473764646464646447c5a5a5a5a5a5a5a5a5a5a5a5a5a5a5d5
__gff__
00040001001111212000000000000001090c0808004080408040804080000002004480010040804080408040800000000000000000000000000000000000000000000000010101010101010101010101000100000001010101010101010101010000000101010101010101010101010100010101010101010101010101010100
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4546464646464646464646464646464756565656565656565656565704555656000000000000000000000000000000005656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565603030303030303030356
6566666666666666666666666666666756565656565656565656565704555656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656
2221222122212221222121212221222156565656566375645656565704555656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656
214a7d5a5a5a5a5a5a5a5a5a5a5a6a225656565648670f654956486704654956565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656
224c5d4c5a5a6a4b4c5a6a4c5a5a4d215656565657041f045556570404055556565656565656565656565656565656565656565656565656565656565656565656566375645656565656565656565656486666666666666666664956565656565656565656565656565656565656565648666666494866666666664956565656
215b00785a6a005b5c5a6a5b00005b225656565657040404555657040404555656565656565656565656565656565656565656565656565656565656565656564866670f656649565656565656565656570422220422220104016566666649565656637564565656565656565656565657131313555722220421215556565656
225b4b6e4646476e4646476e46466f2156565648716a074a724957040404555656565656565656565656565656565656565656565656565656565656565656565704041f04045556565656565656565657044b04044b220401040422042255565656570f656649565656565656565656571305136867224a5a6a215556565656
216567656666676566666765666667225656565704040404055557040404555656565656565656565656565656565656565663756456565656565656565656565701047b01225556565656565656565657045b04046b22010401044a6a0455564866671f040455565656565656565656571313135b041322040f045556565656
2221222122212221222122212221222156565657041004040455570404045556565663756456565656565656565656564866670f6566495656565656565656565704010422225556565656565656565657045c5a6a0122040413040f04215556572222220404555656565656565656565722456c5d044a4d211f045556565656
46464646464646464646464646464646565656570404040404557346464674564866670f6566495656565656565656565704041f0404555656565656565656565722220401015556565656565656565657041313131345464722011f0445745657222222222255565656565656565656571365670107015b0422045556565656
56565656565656565656565656565656486666716a0404044a726666666666495704011f0104555656565656565656565721040404215556565656565656565657227b01040455565656565656565656734713010113555657222222045556565704212121215556565656565656565657222222040445764646467456565656
5656565656565656565656565656565657040404040404040404040404040455570404040404555656565656565656565704212121045556565656565656565657040121210455565656565656565656565713131313555673464646467456565722222200225556565656565656565657040422010455565656565656565656
5656565656565656637564565656565657084a6d4446464446464446464446745701040104015556565656565656565657040404040455565656565656565656572121044b225556565656565656565648716a134a5a59565656565656565656585a6a05074a5956565656565656565657040121040455565656565656565656
5656565656486666670f555656565656570404555656565656565656565656565704040404045556565656565656565657042222220455565656565656565656570404016b0455565656565656565656570104040401555656565656565656565704040404045556565656565656565657222104040455565656565656565656
5656565656570204041f55565656565657040455565656565656565656565656570404040404555656565656565656565722040404225556565656565656565657040104042155565656565656565656570404040404555656565656565656565704040404045556565656565656565657010404040455565656565656565656
5656565656734646464674565656565673464674565656565656565656565656734646464646745656565656565656567346464646467456565656565656565673464646464674565656565656565656734646464646745656565656565656567346464646467456565656565656565673464646464674565656565656565656
4646464646464646464646464646464656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656
5656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656
5656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656
5656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656637564565656565656565656565656
5656565656565656565656565656565648666666666666494866666666666649565656565663756456565656566375645656565656565656565656565656565656565656565656565656565656565656565656565656565656565656565656564866666666666649486666666666664948670f65666666494866666666666649
565656565656565656565656565656565701040f040404555704040f040404554866666666670f554866666666670f555656565656565656565656565656565656565656565656565656565656565656566375645656565656565656565656565701010404042255570404040404225557011f040404045557040f0404010455
565656565656565656565656565656565704041f040404555704041f010404555704042222041f555722220404221f55565656565656565656565656565656565656565656637564565656565663756448670f6566664956486666666666495657010404010401555704040104040455570413040104045557041f0421040155
565656565656565656565656565656565704047b010104555704047b0404045557042221040401555704042104220455565656565656565656565656565656565656565656570f555656565656570f5557041f01070465495704040f040865495701040101042255570404010404225557040401040422555704040401220155
486666666666495656486666666666495704040404120755570401040412075557040401010104555704040101010455565663756456565656565656637564564866666666671f554866666666671f5557040404040401555704041f010404555701040404040455570104040104015557040104010122555704010104040155
570f04040404555656570f0422040155570704047b040455570704047b040455570422222222045557040404040404554866670f6566495656486666670f65495722040404042255570404222222045557040407130401555704010401044a59570404040104045557040401040404555721040404040455572204047b040155
571f04210404555656571f22040404555704047b210404555704047b04042155570401040401045557220421040404555704041f0404555656570404041f0455572204017b012255570401044b010455570404010408045557040404040401555701040401040f555704010404040f5557220404040401555721040404040455
5704210404045556565704040401045557040401217b215557010404217b215557210404010404555704042204210455570404040404555656570404040404555704130401040455570404046b040455570401040404015557040404010407555701042204041f555704040401041f5557210401040104555722040401040155
5704040401045556565704040404045557040401040421555701040421040455572104220404225557040104010404555704047b0404555656570404041104555701040404040455570404041304015557040104010401555704010404040455570113040401045557042204040404555704047b220404555701047b04220455
5704010404045556565704040401045557041304012201555704130401220155572101040104045557040422040421555704040404045556565704040404045557017b0404010455570401040404015557040404040401555701040404014a59586a040404040455570404210404015557040404040104555704040404010455
5704040104045556565704040404045557040108040445745704010804040555570404040422045557040104220404555704040404045556565704040404045557010404040404555704040104040155570101010405045557010404080404555704040104040455570404040404045557010204040401555704040401020455
7346464646467456567346464646467473464646464674567346464646464674734646464646467473464646464646747346464646467456567346464646467473464646464646747346464646464674734646464646467473464646464646747346464646464674734646464646467473464646464646747346464646464674
__sfx__
000200001d0101c0101c0101c01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001da201fa2027a302ea402ea3011a0011a0011a0011a0011a0011a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a00
0002000037a201fa4013a3018a2001a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a0000a00
000300000f01007010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000402001020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000020d201dd401bd201bd1000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d0000d00
010f00000372003720037250372503725037250372503723037200372003725037250372503725037250372303720037200372503725037250372503725037230f7250f7250f7250f7250c7250a7250a7250a723
010f00000372003720037250372503725037250372503723037200372003725037250372503725037250372303720037200372503725037250372503725037230372003720037250372503723037230372303723
010f00001f70000000007000070005730007000070000700007000070000700007000573000700007000070000700007000070000700057300070000700007000070000700007000070005730007000070000000
010f00001f00200002000020000205022050250000200002000020000200002000020502205023000020000200002000020000200002050220502400002000020000200002000020000205022050210702104003
010f00000372003720037250372503725037250372503723037200352005525075250552503525037250372303720037200372503725037250372503725037230372004720057230572305723057230572305023
010f00000350500505035050350505515035050551703505035050350503505055050951505505035050951503505035050350503505055150350505517035050350503505035050350509515005050a50500505
010f00001f00200002000020502205023051250502200002000020000200002050220502205123050220000200002000020000205022050230512505022000020000200002000020000005022050230702207003
010f00000350500505065250350505515035050551703505035050651503505055050952505505035050951503505035050652503505055150350505517035050350506525035030350509525000000651500000
010f00000372303723037230372303723037230372003720037230372503725037250372503725037200372003723037250372503725037250372503720037200372303725037250372503725037250372003720
010f00000372303725037250372503725037250372003720035230372503725055250752505525037200352003723037250372503725037250372503720037200572305723057230572305723057230472003720
010f00000372303725037250372503725037250372003720037230372503725037250372503725037200372003723037250372503725037250372503720037200a7240a7230a7250c7250f7250f7250f7250f725
010f00001f00200002000020702207023000020000200002000020000200002050220502300002000020000200002000020000206022060230000200002000020000200002000020502205021070210400300000
010f000006d020000006d021cd120000007d021dd1207d0205d020000007d021dd1207d0207d021fd1207d02000000ad020cd021fd120000000d0221d120ad0200000000000cd0221d121fd121dd121cd1200000
010f00000371003710037150371503715037150371503713037100371003715037150371503715037150371303710037100371503715037150371503715037130371003710037150371503713037130371303713
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 13 42 43 44
02 13 42 43 44
01 07 08 43 44
02 06 08 43 44
01 07 09 43 44
02 06 09 43 44
01 07 09 0b 44
00 0a 09 0b 44
00 07 09 0b 44
02 06 09 0b 44
01 07 0c 0b 44
00 0a 0c 0b 44
00 07 0c 0b 44
02 06 0c 0b 44
01 07 0c 0d 44
00 0a 0c 0d 44
00 07 0c 0d 44
02 06 0c 0d 44
01 0e 11 0d 44
00 0f 11 0d 44
00 0e 11 0d 44
02 10 11 0d 44
01 0e 11 0d 44
00 0f 11 0d 12
00 0e 11 0d 44
02 10 11 0d 12
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
