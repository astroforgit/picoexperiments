pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- blasphemy!
-- by felixmcfelix

-- game vars

die_strs={
	"r.i.p.",
	"too slow",
	"awful!",
	"ouch",
	"are you even trying?",
	":'(",
	"we're doomed!"
}

lvl_strs={
	"sweet!",
	"finally...",
	"this one's a doozy",
	"phew!",
	"yahaha!",
	":')",
	"good job?"
}

framerate = 30
map_n=0
ent_dat={
	{
		{t=3,x=88,y=64},
		{t=2,x=56,y=56},
		{t=1,x=32,y=48}
	}, -- map 0
	{
		{t=3,x=72,y=32},
		{t=2,x=44,y=60},
		{t=2,x=32,y=32},
		{t=2,x=80,y=80},
		{t=1,x=32,y=92}
	}, -- map 1
	{
		{t=6,x=32,y=40,signal=0},
		{t=9,x=48,y=24,signal=0,params={active=true}},
		{t=9,x=48,y=32,signal=0,params={active=true}},
		{t=9,x=48,y=40,signal=0,params={active=true}},
		{t=8,x=48,y=24,params={topside=true}},
		{t=8,x=48,y=40},
		{t=7,x=32,y=32,anim="tr"},
		{t=7,x=48,y=16,anim="tr"},
		{t=3,x=80,y=40},
		{t=2,x=64,y=80},
		{t=2,x=104,y=72},
		{t=2,x=88,y=56},
		{t=2,x=104,y=40},
		{t=1,x=16,y=32}
	}, -- map2
	{
		{t=6,x=52,y=36,signal=0},
		{t=6,x=100,y=100,signal=0},
		--
		{t=10,x=80,y=48,anim="cap",signal=0,params={reverse=true}},
		{t=10,x=88,y=48,signal=0,params={reverse=true}},
		{t=10,x=96,y=48,anim="cap",params={flip=true,reverse=true},signal=0},
		--
		{t=10,x=96,y=72,anim="cap",signal=0,params={reverse=true}},
		{t=10,x=104,y=72,anim="cap",params={flip=true,reverse=true},signal=0},
		--
		{t=10,x=80,y=96,anim="cap",signal=0,params={reverse=true}},
		{t=10,x=88,y=96,anim="cap",params={flip=true,reverse=true},signal=0},
		--
		{t=9,x=32,y=24,signal=0},
		{t=9,x=32,y=32,signal=0},
		{t=9,x=32,y=40,signal=0},
		{t=8,x=32,y=24,params={topside=true}},
		{t=8,x=32,y=40},
		--
		{t=9,x=72,y=24,signal=0,params={active=true}},
		{t=9,x=72,y=32,signal=0,params={active=true}},
		{t=9,x=72,y=40,signal=0,params={active=true}},
		{t=8,x=72,y=24,params={topside=true}},
		{t=8,x=72,y=40},
		--
		{t=9,x=72,y=56,signal=0},
		{t=9,x=72,y=64,signal=0},
		{t=9,x=72,y=72,signal=0},
		{t=9,x=72,y=80,signal=0},
		{t=9,x=72,y=88,signal=0},
		{t=8,x=72,y=56,params={topside=true}},
		{t=8,x=72,y=88},
		--
		{t=3,x=20,y=40},
		{t=2,x=48,y=84},
		{t=1,x=16,y=32}
	}, -- map3
	{
		{t=10,x=16,y=96,anim="cap",params={}},
		{t=10,x=24,y=96,params={}},
		{t=10,x=32,y=96,params={}},
		{t=10,x=40,y=96,params={}},
		{t=10,x=48,y=96,anim="cap",params={flip=true}},
		--
		{t=6,x=72,y=80,signal=0},
		{t=7,x=72,y=64,anim="circ"},
		{t=7,x=56,y=64,anim="circ"},
		--
		{t=9,x=56,y=72,signal=0,params={active=true}},
		{t=9,x=56,y=80,signal=0,params={active=true}},
		{t=9,x=56,y=88,signal=0,params={active=true}},
		{t=9,x=56,y=96,signal=0,params={active=true}},
		{t=9,x=56,y=104,signal=0,params={active=true}},
		{t=9,x=56,y=112,signal=0,params={active=true}},
		{t=9,x=56,y=120,signal=0,params={active=true}},
		{t=8,x=56,y=72,params={topside=true}},
		{t=8,x=56,y=120},
		--
		{t=9,x=56,y=0,params={active=true}},
		{t=9,x=56,y=8,params={active=true}},
		{t=9,x=56,y=16,params={active=true}},
		{t=9,x=56,y=24,params={active=true}},
		{t=9,x=56,y=32,params={active=true}},
		{t=9,x=56,y=40,params={active=true}},
		{t=9,x=56,y=48,params={active=true}},
		{t=9,x=56,y=56,params={active=true}},
		{t=8,x=56,y=0,params={topside=true}},
		{t=8,x=56,y=56},
		--
		{t=9,x=4,y=0,params={active=true}},
		{t=9,x=4,y=8,params={active=true}},
		{t=9,x=4,y=16,params={active=true}},
		{t=9,x=4,y=24,params={active=true}},
		{t=9,x=4,y=32,params={active=true}},
		{t=9,x=4,y=40,params={active=true}},
		{t=9,x=4,y=48,params={active=true}},
		{t=9,x=4,y=56,params={active=true}},
		{t=9,x=4,y=64,params={active=true}},
		{t=9,x=4,y=72,params={active=true}},
		{t=9,x=4,y=80,params={active=true}},
		{t=9,x=4,y=88,params={active=true}},
		{t=9,x=4,y=96,params={active=true}},
		{t=9,x=4,y=104,params={active=true}},
		{t=9,x=4,y=112,params={active=true}},
		{t=9,x=4,y=120,params={active=true}},
		{t=8,x=4,y=0,params={topside=true}},
		{t=8,x=4,y=120},
		--
		{t=3,x=40,y=16},
		{t=2,x=104,y=32},
		{t=2,x=80,y=48},
		{t=2,x=104,y=88},
		{t=2,x=32,y=88},
		{t=1,x=72,y=8}
	} -- map4
}
timelimit={5,10,5,16,15}

live_ent={}
alive=false
player_g=0
buttons=0
buttons_p=0
timer=0
targ_time=0

-- state functions

function menu_init()
	update = menu_update
	draw = menu_draw
end

function menu_update()
	--nothing yet

	-- just go straight to game
	if btn(4) or btn(5) then
		update=function()
			pal()
			force_flick=true
			flicker()
			pause_time+=1
			if (pause_time > pause_duration*framerate/2) blackout()
			if (pause_time > pause_duration*framerate) game_init()
		end
	end
end

function menu_draw()
	--nothing yet
	cls()
	cthicc("blasphemy!", 32, 12)
	cprint("the end of the world draws near",48)
	cprint("maneuver the hidden olympus",56)
	cprint("complex and anger zeus",64)

	cprint("his fury is our only hope...",80)

	cthicc("press z or x", 96, 2)
	local inst="move:\x8b\x91\x94\x83 jump:\x8e use:\x97"
	thicc(inst, ((128-4*#inst)/2)-12, 104, 2)
end

oneup=false
musicon=false

function game_init()
	load_map()
	if(not musicon) music(0) musicon=true
	oneup=false
	update=game_update
	draw=game_draw
end

function game_update()
	if (timer > targ_time) kill_player("time")
	timer += 1
	for ent in all(live_ent) do
		ent_update(ent)
		ent_fns[ent.t][2](ent)
		ent_predraw(ent)
	end
	oneup=true
end

function game_draw()
	cls()
	if(not oneup) return

	pal()
	map((map_n%8)*16,flr(map_n/8)*16, 0, 0)
	for ent in all(live_ent) do
		pal()
		for entry in all(ent.pal) do
			pal(entry[1],entry[2])
		end
		local fid = ent_anims[ent.t][ent.anim][flr(ent.frame/ent.framedur)+1]
		if(not fid) fid = ent_anims[ent.t][ent.anim][1]
		-- if(not fid) plog("bad frame:".." "..ent.t.." "..ent.anim.." "..#ent.anim.." "..ent.frame.." "..ent.framedur)
		spr(fid,ent.x,ent.y,1,1,ent.flipx,ent.flipy)
	end
	-- log("map "..map_n)
	flicker()
	unlog()
	draw_tooltips()
	draw_ui()
end

pause_duration=2
pause_time=0

function die_init()
	pause_time=0
	local msc = die_strs[flr(rnd(#die_strs))+1]
	update=function()
		pause_time+=1
		if (pause_time>pause_duration*framerate) game_init()
	end
	draw=function()
		cls()
		pal()
		thicc(msc, (128-4*#msc)/2, 60, 1)
	end
end

last_flick=0
flick_left=0
force_flick=false

function flicker()
	if rnd(1) < 4/5 and targ_time-timer < 5*framerate and timer-last_flick>0.8*framerate then
		flick_left=flr(rnd(5))
		last_flick=timer
	end

	if flick_left>0 or force_flick then
		pal(0, 0, 1)
		pal(1, 0, 1)
		pal(2, 0, 1)
		pal(3, 1, 1)
		pal(4, 2, 1)
		pal(5, 0, 1)
		pal(6, 5, 1)
		pal(7, 5, 1)
		pal(8, 2, 1)
		pal(9, 4, 1)
		pal(10, 4, 1)
		pal(11, 3, 1)
		pal(12, 1, 1)
		pal(13, 1, 1)
		pal(14, 2, 1)
		pal(15, 4, 1)
		flick_left -=1
	end
end

function blackout()
	pal(0, 0, 1)
	pal(1, 0, 1)
	pal(2, 0, 1)
	pal(3, 0, 1)
	pal(4, 0, 1)
	pal(5, 0, 1)
	pal(6, 0, 1)
	pal(7, 0, 1)
	pal(8, 0, 1)
	pal(9, 0, 1)
	pal(10, 0, 1)
	pal(11, 0, 1)
	pal(12, 0, 1)
	pal(13, 0, 1)
	pal(14, 0, 1)
	pal(15, 0, 1)
end

function chlevel_init()
	pause_time=0
	local msc = lvl_strs[flr(rnd(#lvl_strs))+1]
	sfx(5)

	if (map_n+1>=#ent_dat) msc="" pause_duration=3

	update=function()
		pause_time+=1
		if (pause_time>pause_duration*framerate) then
			map_n+=1
			if map_n < #ent_dat then
				game_init()
			else
				music(-1, 1)
				end_init()
			end
		end
	end
	draw=function()
		cls()
		pal()
		thicc(msc, (128-4*#msc)/2, 60, 1)
	end
end

function end_init()
	draw=end_draw
	update=end_update
end

function end_draw()
	cls()
	-- local msg="you win! yadda yadda"
	local coord=(128-4*8)/2

	color(7)
	spr(67, coord,coord-5*8,4,4)
	rect(coord-2,coord-5*8-2, coord+4*8+2, coord+2-8)

	-- thicc(msg, (128-(4*#msg))/2,(128-8)/2, 1)
	local start = coord+2
	cprint("and so the hero",start)
	cprint("ascended the mountain",start+8)
	cprint("with a \"screw you, zeus!\"",start+16)

	cprint("the god, nonplussed,",start+24)
	cprint("struck him down",start+32)
	cprint("yet his bolts of fury restored",start+40)
	cprint("the world's power...",start+48)

	cthicc("you're a true hero!", start+60, 1)
	cthicc("(but kinda dead...)", start+68, 1)
end
function end_update()

end

function _init() menu_init() end
function _update() update() end
function _draw() draw() end

-- entity stuff

function ent_predraw(ent)
	local lf=ent.frame
	if not ent.stop then
		ent.frame+=1
	end
	ent.frame%=((#ent_anims[ent.t][ent.anim])*ent.framedur)

	if (ent.frame<lf and ent.nextanim~="") ent.anim=ent.nextanim ent.nextanim=""
end

function ent_update(ent)
	local lx = ent.x
	local ly = ent.y

	ent.dx+=(ent.ddx/framerate)
	ent.dy+=(ent.ddy/framerate)
	ent.conveyed=false

	if (not ent.movable) return

	local startpts = bbpts(lx, ly, ent.col_x, ent.col_y, ent.w, ent.h)

	local vx = ent.dx/framerate
	local vy = ent.dy/framerate

	ent.hit_world=false

	if not ent.collide_world then
		ent.x += vx
		ent.y += vy
		return
	end

	local xdir = sgn(vx)
	local ydir = sgn(vy)
	local hit_x = false
	local hit_y = false

	local chosenx=0
	if ent.dx<0 then
		chosenx=startpts.l_x
	else
		chosenx=startpts.r_x
	end

	local closest_x=-1
	for i=flr(chosenx/8),flr((chosenx+vx)/8),xdir do
		for j=flr(startpts.t_y/8),flr(startpts.b_y/8) do
			if (solid_tile(i, j)) closest_x=i-min(0,xdir) goto fnd_x
		end
	end
	::fnd_x::

	local x_move=vx
	if closest_x>=0 then
		local target=(closest_x*8)-max(xdir,0)
		local mv = target-chosenx
		x_move = xdir*min(mv*xdir,vx*xdir)
		if (x_move~=vx) hit_x=true
	end
	--ent-sweep x
	-- log(ent.t)
	local ent_obs_x=select_ent_obstacle(chosenx, xdir, "x",
		{l_x=min(chosenx+x_move,chosenx), r_x=max(chosenx+x_move,chosenx),
		b_y=startpts.b_y, t_y=startpts.t_y}, ent
	)
	if ent_obs_x[1] then
		x_move = xdir*min(ent_obs_x[2]*xdir,x_move*xdir)
		if (x_move~=vx) hit_x=true
	end
	ent.x += x_move

	local choseny=0
	if ent.dy<0 then
		choseny = startpts.t_y
	else
		choseny = startpts.b_y
	end

	local closest_y=-1
	for i=flr(choseny/8),flr((choseny+vy)/8),ydir do
		for j=flr((startpts.l_x+x_move)/8),flr((startpts.r_x+x_move)/8) do
			if (solid_tile(j, i)) closest_y=i-min(0,ydir) goto fnd_y
		end
	end
	::fnd_y::

	local y_move=vy
	if closest_y>=0 then
		local target=(closest_y*8)-max(ydir,0)
		local mv = target-choseny
		y_move = ydir*min(mv*ydir,vy*ydir)
		if (y_move~=vy) hit_y=true
	end
	--ent-sweep y
	local ent_obs_y=select_ent_obstacle(choseny, ydir, "y",
		{l_x=startpts.l_x+x_move, r_x=startpts.r_x+x_move,
		b_y=max(choseny+y_move,choseny), t_y=min(choseny+y_move,choseny)}, ent
	)
	if ent_obs_y[1] then
		-- if(ent.t==1)plog("w? "..y_move.." "..ent_obs_y[2].." "..choseny)
		y_move = ydir*min(ent_obs_y[2]*ydir,y_move*ydir)
		if (y_move~=vy) hit_y=true
	end
	ent.y += y_move

	if hit_x then
		-- don't cancel x-velocity -- this feels way better
		-- ent.dx = 0
		ent.x = round(ent.x)
	end
	if hit_y then
		ent.dy = 0
		ent.y = round(ent.y)
	end

	ent.hit_world=hit_x or hit_y
end

function select_ent_obstacle(chosen, dir, axis, sweepbb, inent)
	local any=false
	local needed_move=0

	-- on other objects, select the boundary opposing the one we want to move
	local key=""
	local kl={x={"l","r"},y={"t","b"}}
	if dir<0 then
		key=kl[axis][2]
	else
		key=kl[axis][1]
	end
	key=key.."_"..axis

	for ent in all(live_ent) do
		local entbb = bbpts_ent(ent)
		-- log("can i? t:"..inent.t..","..bstr(not (ent.t==1)).." "..bstr(inent.playermovable))
		if ent.collide_world and ent~=inent and ((not (ent.t==1)) or inent.playermovable) and bbcollide(entbb,sweepbb) then
			local p=entbb[key]-dir
			local mv=p-chosen
			if (not any) needed_move=mv any=true
			needed_move = dir*min(dir*mv, dir*needed_move)
		end
	end

	return {any, needed_move}
end

function kill_player(cause, pl)
	if (pl==nil) pl=player_g
	if (player_g==nil) log("failed kill") return

	if pl.alive then
		pl.alive=false
		pl.cause=cause
		pl.remdeathframes=1*framerate
	end
end

function player_init(player)
	player.jump=false
	player.readywalljump=false
	player.walljmp=0
	player.collide_world=true
	player.ddy=128
	player_g=player
	player.col_x=2
	player.col_y=1
	player.w=4
	player.h=7
	player.alive=true
	player.cause=""
	player.remdeathframes=0
	player.movable=true
	player.framedur=5
	player.airlast=false
end

function player_update(player)
	--compute wall touches etc
	world_touches(player)

	-- now, movement (left + right)
	local ms=40
	-- local ms=32
	local jmph=-72
	-- player.dy*=0.5
	
	-- jumps

	player.walljmp=max(player.walljmp-1,0)
	
	local lms=ms
	if player.touched_below then
		if (not player.jump) and btn(4) then
			player.jump=true
			player.dy=jmph
			player.readywalljump=false
			sfx(1)
		elseif player.jump then
			player.jump=false
		end

		if (player.airlast) sfx(0)
		player.airlast=false
		--ground friction
		player.dx*=0.5
	else
		player.airlast=true
		player.dx*=0.75
		-- player.dx*=0.5
		lms*=0.67
	end

	if (player.y > 128 or player.x < -(player.col_x+player.w) or player.x>128) kill_player("time")

	local b0=btn(0)
	local b1=btn(1)
	if player.alive then
		if(b0)player.dx-=lms
		if(b1)player.dx+=lms
		-- if(btn(2))player.dy-=lms
		-- if(btn(3))player.dy+=lms
		if not player.airlast then
			player.anim="def"
			if ((b0 or b1) and player.dx~=0) player.anim="run"
		else
			player.anim="jmp"
		end

		player.flipx=player.dx<0

		if (not player.readywalljump) player.readywalljump=(player.airlast and not btn(4))

		if (player.touched_left or player.touched_right) and player.airlast then
			if player.dy>0 then
				player.dy*=0.9
				local hdir=0
				if ((player.touched_left and b0) or (player.touched_right and b1)) player.dy*=0.75
			end
			player.anim="jmpwall"
			player.flipx=player.touched_right
			if player.walljmp<=0 and btn(4) and player.readywalljump then
				player.walljmp=0
				player.dy=jmph
				player.dx=bint(player.touched_right)*(-3)*ms
				player.readywalljump=false
				sfx(1)
			end
		end
	elseif player.cause=="lightning" then
		player.cause=""
		player.dx=0
		player.dy=0
		player.ddy=0
		player.anim="shock"
		player.nextanim="gone"
		player.framedur=3
	elseif player.cause=="time" then
		force_flick=true
	end

	if (not player.alive) and player.remdeathframes<=0 then die_init() end
	player.remdeathframes-=1
end

function button_init(button)
	button.trig=false
	buttons+=1
end

function button_update(button)
	if (not button.trig) and entcollide(button, player_g) then
		buttons_p+=1
		button.trig=true
		sfx(3)
	end
	if button.trig then
		if button.frame>=3 then button.pal={{8,11}}
		else button.pal={{8,3}} end
	else
		if button.frame>=3 then button.pal={}
		else button.pal={{8,2}} end
	end
end

function doorbase_init(door)
	door.partopen=2
	door.isparent=true
	door.child=new_ent({t=4,x=door.x,y=door.y-8})

	door.child.col_y=5
	door.child.child=nil
	door.child.partopen=1
	door.child.parent=door
	door.child.isparent=false
end

function doorbase_update(door)
	local semion = false
	if (not door.on) and buttons==buttons_p then
		door.on=true
		if door.isparent then
			-- make an arrow!
			local arr=new_ent({t=5,x=door.x,y=door.y-16})
			arr.base_y=arr.y
		end
	elseif buttons_p>1 and buttons_p>=flr(buttons/2) then
		semion=true
	end

	if door.on then
		door.pal = {}
		if door.partopen > 0 then
			door.partopen-=1
		else
			concat_tab(door.pal,{{1,0},{5,0},{2,0}})
		end

		if door.frame>=3 then add(door.pal,{8,11})
		else add(door.pal,{8,3}) end
	elseif semion then
		if door.frame>=3 then door.pal={{8,9}}
		else door.pal={{8,10}} end
	else
		if door.frame>=3 then door.pal={}
		else door.pal={{8,2}} end
	end

	if (not door.isparent) return
	if entcollide(door,player_g) or entcollide(door.child,player_g) then
		if door.on then
			chlevel_init()
		elseif not door.tooltip then
			door.tooltip=tooltip_f(
				(buttons-buttons_p).." remaining!",
				door.x+4, door.y-8, 1000,
				7,2,-1,-1
			)
		end
	elseif door.tooltip then
		door.tooltip.die=true
		door.tooltip=nil
	end
end

function doorarrow_init(door)
	door.lframe=0
end

function doorarrow_update(arrow)
	local pals = {
		{},
		{{10,9},{9,8},{8,10}},
		{{10,8},{9,10},{8,9}}
	}
	local len=15
	arrow.lframe+=1
	arrow.lframe%=len
	arrow.pal=pals[flr(arrow.lframe/(len/#pals))+1]
	arrow.y = arrow.base_y + round(sin(time()))
end

function lever_init(lever)
	lever.active=false
	lever.w=12
	lever.h=12
	lever.col_x=-2
	lever.col_y=-2
end

function lever_update(lever)
	if entcollide(lever,player_g) then
		if btnp(5) then
			lever.active=not lever.active
			signal(lever.signal, "lever_toggle")
			sfx(2)
		end

		if not lever.tooltip then
			lever.tooltip=tooltip_f(
				"\x97!",
				lever.x+4, lever.y-4, 1000,
				7,2,-1,-1
			)
		end
	elseif lever.tooltip then
		lever.tooltip.die=true
		lever.tooltip=nil
	end

	lever.anim="def"
	if (lever.active) lever.anim="active"
end

function lever_msg(lever, msg)
end

function thundersrc_init(src)
	src.flipy=src.params.topside
end

function thunder_init(thunder)
	thunder.active=thunder.params.active==true
	thunder.lframe=0
	thunder.nextflip=-1
end

function thunder_update(thunder)
	if thunder.nextflip<0 then
		thunder.nextflip=flr(rnd(7)+1)
	elseif thunder.lframe>=thunder.nextflip then
		thunder.flipx = not thunder.flipx
		thunder.nextflip=-1
		thunder.lframe=-1
	end

	thunder.lframe += 1

	if thunder.active then
		thunder.anim="def"
		if (entcollide(thunder,player_g)) kill_player("lightning", player_g)
	else
		thunder.anim="ded"
	end
end

function thunder_msg(thunder, msg)
	if (msg=="lever_toggle") thunder.active = not thunder.active
end

function conveyor_init(conveyor)
	conveyor.flipx=conveyor.params.flip==true
	conveyor.framedur=6
	conveyor.stops=conveyor.params.stops==true
	conveyor.reverse=true--conveyor.params.reverse==true
	conveyor.collide_world=true
end

function conveyor_update(conveyor)
	conveyor.stop = conveyor.stops and conveyor.reverse

	local pal={{4,0}}
	if conveyor.frame>=conveyor.framedur/2 then
		add(pal, {6,0})
	else
		concat_tab(pal,{{5,0},{6,5}})
	end

	local lead={5,13,6}
	local base={13,9,2}
	if (xor(conveyor.flipx, conveyor.reverse)) base=rev(base)

	for i=1,3 do
		add(pal,{base[((flr(conveyor.frame/2)+i)%3)+1],lead[i]})
	end

	conveyor.pal=pal

	local ms=30
	local dummy={x=conveyor.x,y=conveyor.y-1,w=8,h=1,col_x=0,col_y=0}
	local dir=bint(conveyor.reverse)
	if(conveyor.stop) dir=0
	for ent in all(live_ent) do
		if (ent.movable and entcollide(dummy, ent) and (not ent.conveyed)) ent.dx+=dir*ms ent.conveyed=true
	end
end

function conveyor_msg(conveyor, msg)
	if (msg=="lever_toggle") conveyor.reverse = not conveyor.reverse
end

ent_fns={
	{player_init,player_update,function()end},
	{button_init,button_update,function()end},
	{doorbase_init,doorbase_update,function()end},
	{function()end,doorbase_update,function()end},
	{doorarrow_init,doorarrow_update,function()end},
	{lever_init,lever_update,lever_msg},
	{function()end,function()end,function()end},
	{thundersrc_init,function()end,function()end},
	{thunder_init,thunder_update,thunder_msg},
	{conveyor_init,conveyor_update,conveyor_msg}
}

ent_anims={
	{def={11,27}, run={11,12}, jmp={13,14}, jmpwall={15}, shock={28,29,28,29,28,29,30,31,43},gone={255}},
	{def={4,4,4,4,4,4}},
	{def={32,32,32,32,32,32}},
	{def={16,16,16,16,16,16}},
	{def={5}},
	{def={33},active={34}},
	{def={17},tr={18},circ={19}},
	{def={36}},
	{def={20},ded={255}},
	{def={66},cap={65}}
}

function signal(sig_id, msg)
	if (sig_id==nil) return
	for ent in all(live_ent) do
		if (ent.signal==sig_id) ent_fns[ent.t][3](ent, msg)
	end
end

-- restarty stuff

function init_ent(ent)
	local anime="def"
	local parame={}
	if (ent.anim) anime=ent.anim
	if (ent.params) parame=ent.params
	local new_ent = {t=ent.t,
		x=ent.x,y=ent.y,dx=0,dy=0,ddx=0,ddy=0,movable=false,playermovable=false,
		anim=anime,nextanim="",frame=1,framedur=1,stop=false,palv={},flipx=false,flipy=false,
		solid=true,w=8,h=8,col_x=0,col_y=0,collide_world=false,
		signal=ent.signal,params=parame,conveyed=false
	}
	ent_fns[ent.t][1](new_ent)
	return new_ent
end

function load_map()
	live_ent={}
	alive=true
	player_g={}
	buttons=0
	buttons_p=0
	timer=0
	msgs={}
	tooltips={}
	targ_time=timelimit[map_n+1]*framerate
	last_flick=0
	flick_left=0
	force_flick=false
	last_sec=-1

	for ent in all(ent_dat[map_n+1]) do
		--initialise each entity from the given data
		new_ent(ent)
	end
end

function new_ent(ent)
	local e = init_ent(ent)
	add(live_ent, e)
	return e
end

-- collision code?
function solid(x, y)
	return solid_tile(flr(x/8),flr(y/8))
end

function solid_tile(x, y)
	return fget(mget((map_n%8)*16+x,flr(map_n/8)*16+y), 0)
end

function bbpts_ent(ent)
	return bbpts(ent.x, ent.y, ent.col_x, ent.col_y, ent.w, ent.h)
end

function bbpts(x, y, col_x, col_y, w, h)
	local lx = x + col_x
	local ty = y + col_y
	local rx = lx + w - 1
	local by = ty + h - 1
	return {
		l_x=lx,r_x=rx,t_y=ty,b_y=by
	}
end

-- check if world collision exists around an ent
function world_touches(ent)
	local bbx = bbpts_ent(ent)
	ent.touched_above = solid(bbx.l_x, bbx.t_y-1) or solid(bbx.r_x, bbx.t_y-1)
	ent.touched_below = solid(bbx.l_x, bbx.b_y+1) or solid(bbx.r_x, bbx.b_y+1)
	ent.touched_left = solid(bbx.l_x-1, bbx.t_y) or solid(bbx.l_x-1, bbx.b_y)
	ent.touched_right = solid(bbx.r_x+1, bbx.t_y) or solid(bbx.r_x+1, bbx.b_y)

	local a_bb={l_x=bbx.l_x, r_x=bbx.r_x, t_y=bbx.t_y-1, b_y=bbx.t_y-1}
	local b_bb={l_x=bbx.l_x, r_x=bbx.r_x, t_y=bbx.b_y+1, b_y=bbx.b_y+1}
	local l_bb={l_x=bbx.l_x-1, r_x=bbx.l_x-1, t_y=bbx.t_y, b_y=bbx.b_y}
	local r_bb={l_x=bbx.r_x+1, r_x=bbx.r_x+1, t_y=bbx.t_y, b_y=bbx.b_y}
	for oent in all(live_ent) do
		if oent.collide_world and oent~=ent then
			local b=bbpts_ent(oent)
			ent.touched_above = ent.touched_above or bbcollide(a_bb,b)
			ent.touched_below = ent.touched_below or bbcollide(b_bb,b)
			ent.touched_left = ent.touched_left or bbcollide(l_bb,b)
			ent.touched_right = ent.touched_right or bbcollide(r_bb,b)
		end
	end
end

function entcollide(e1,e2)
	local bb1=bbpts_ent(e1)
	local bb2=bbpts_ent(e2)
	return bbcollide(bb1,bb2)
end

function bbcollide(bb1,bb2)
	return bb2.l_x<=bb1.r_x and bb2.b_y>=bb1.t_y and bb1.l_x<=bb2.r_x and bb1.b_y>=bb2.t_y
end

-- utility
function bstr(boolin)
	if boolin then return "true" else return "false" end
end
function bint(boolin)
	if boolin then return 1 else return -1 end
end

msgs = {}
pmsgs={}
function log(st)
	add(msgs,st)
end
function plog(st)
	add(pmsgs,st)
end
function unlog()
	for msg in all(pmsgs) do
		print(msg)
	end
	for msg in all(msgs) do
		print(msg)
	end
	msgs = {}
end

function round(x, dec)
	if (dec) return flr((x*(10^dec) + 0.5))/(10^dec)
	return flr(x+0.5)
end

function num_fmt(x, dec)
	local val=round(x,dec)
	local lhs=flr(x)
	local rem=flr(abs(val-lhs)*(10^dec))..""
	while #rem<dec do rem=rem.."0" end
	return lhs.."."..rem
end

function ceil(x)
	return flr(x)+1
end

function concat_tab(tab, tabtab)
	for part in all(tabtab) do
		add(tab, part)
	end
end

function rev(tab)
	local out={}
	for i,v in pairs(tab) do
		out[#tab+1-i]=v
	end
	return out
end

function xor(a,b) return(not(a and b) and (a or b)) end

-- ui stuff
tooltips={}
function draw_tooltips()
	local to_die={}

	for t in all(tooltips) do
		if t.die then
			add(to_die, t)
		else
			w=4*#t.s
			h=5
			s_x=t.x-(w/2)
			s_y=t.y-h+1
			if (t.b2>=0) rectfill(s_x-1,s_y-1,s_x-1+w,s_y+1+h,t.b2)
			if (t.b>=0)	rectfill(s_x-1,s_y-2,s_x-1+w,s_y+h,t.b)
			if (t.sh>=0) print(t.s, s_x, s_y-1, t.sh)
			thicc(t.s, s_x, s_y, 2)
		end
	end

	for rip in all(to_die) do
		del(tooltips, rip)
	end
end

function tooltip(str, x_ctr, y_ctr, max_w)
	return tooltip_f(str, x_ctr, y_ctr, max_w, 7, 2, -1, -1)
end

function tooltip_f(str, x_ctr, y_ctr, max_w, col, shadow, box, box2)
	local ent = {s=str,x=x_ctr,y=y_ctr,m_w=max_w,die=false,c=col,sh=shadow,b=box,b2=box2}
	add(tooltips,ent)
	return ent
end

function thicc(str,x,y,bg)
	x=max(x,1)
	y=max(y,1)
	for i=-1,1 do
		for j=-1,1 do
			print(str,x+i,y+j,bg)
		end
	end
	print(str,x,y,7)
end

function cthicc(str,y,bg)
	thicc(str,(128-4*#str)/2,y,bg)
end

function cprint(str,y,bg)
	if(bg==nil) bg=7
	print(str,(128-4*#str)/2,y,bg)
end

last_sec=-1

function draw_ui()
	--timer
	local t=max(0,(targ_time-timer)/framerate)
	print(num_fmt(t,2), 0, 8)

	local tp=flr(t)
	if(tp<last_sec and last_sec<6) sfx(4)
	last_sec=tp
end
__gfx__
00000000444444441111111100000000000000000022220055555555000000000000000000000000000000000000000000000000000000000000000000000000
0000000044444444111111110088880006667770008aa800555555550222002222000022200000000000000200cc0c0000cc0c0000cc0c0000cc0c0000cc0c00
0070070044444444111111110088880001d5d56000988900555555550242224442202224222220002220222200c7c70000c7c70000c7c70000c7c70000c7c700
000770004444444411111111008888000158856022a99a22555555550220444444222424442422002422242401cccc0001cccc0010cccc0001cccc0000cccc00
0007700044444444111111110088880001588560a98aa89a55555555000022444444244442444200444444440011110000111100011111000111110001111100
00700700444444441111111100888800015d5d600a9889a055555555022224244442424444444200444444440122220001222200002222000022220011222200
000000004444444411111111008888000111111000a99a0055555555022442455555555554442220555555550020200000202000002020000020200000202000
0000000044444444111111110088880000000000000aa000555555550024444ddddaadddd4444200dddddddd0020200002000200020200000202000002220000
0000000000000000000000000000000017101c100244444d642442000024444d111111116444442066766766000000007111111001111110000c000000000007
000000000777774007777740077777401771cc100002444d644220020244244d11111111644224206d6d6d6d00000000c17717107177171c01110070070000c0
0000000007cccc7007666670076bb67001711c102220244d644242222444244d11155111644442006ddddddd00cc0c000171711c01717110017111000c011100
0066660007cccc700768867007bbbb700177cc102422244d642444240022424d115995116424220065d5d5dd00c7c7001c7777101c7777101177711000117110
6dd8866607cccc700788887007bbbb701ccc77104444444d644444440002444d115aa511644220006444444d01cccc0001cccc1071cccc1071cccc10111ccc10
d1dddd1607cccc7007666670076bb6701c1777714444444d644444440222444d15555551642422006442444d001111001c7777101c777710117777101c777710
d11111160474774004747740047477400177cc715555555d655555550244244d11111111624444206444244d0122220001717117717171107171711c71717110
d152251600000000000000000000000017711c10dddddddd6ddddddd0244444d11111111644442206424024d002020007171710c1c111717117171101c111710
d15115160000000000000000667667660000000066766766667667660024444d66766766644442006424224d0000000066766766667667666444444d55555555
d155551600666600006666006d6d6d6d000000006d6d6d6d6d6d6d6d0000244d6d6d6d6d542242006242244d000000006d6d6d6d6d6d6d6d6442244d55555555
d1111116001a760000155600dddddddd00000000dddddddd6ddddddd0000244dddddddddd44422006444024d000007006ddddddddddddddd6444424d55555555
d15555160019a600001bb600d5d5d5d500000000d5d5d5dd65d5d5d500224425d5d5d5d5d42442226442444d0000c00065d5d5d5d5d5d5dd6424224555555555
d155551600188600001a760024444444000000002444444d644444440024424444444444444424426420244d01000000644444442444444d6442244455555555
d1111116001556000019a60042424444007777004242244d642442440022222422242444444222226444024d1c100000642442444242244d6424244455555555
d1555516001116000011160042224445576666754220024d644220020000022202022222222220006424242d11710000644220055220024d6244442555555555
d152251600000000000000002000244d16dddd612000024d642200000000000000000200000000006442444d1c1100006422000dd000024d6444422d55555555
0024444d6444444d00000000644422000224445d000000206442024d6676676666766766667667666424024d000000006424420d6244444d6676676600000000
4244244d6442444d00000000644442000022444d000002226444244d6d6d6d6d6d6d6d6d6d6d6d6d6444244d000000006442200d6002444d6d6d6d6d00000000
2444244d6444224d00000000d42422000024444d22202242d442444d6ddddddddddddddddddddddd6442444d000000006442422dd220244ddddddddd00000000
4022424d6444204500000000d24420000022442524422444d444244565d5d5d5d5d5d5d5d5d5d5dd6444244d0000000064244425d422244dd5d5d5d500000000
4402444d64242204000000004424220000024424444424444242224264242420420240224424244d6442444d00000000644444444444444d2444444400000000
4422444d64424442000000004244420000224242444442442222022262444442442442422444424d6424244d00000000644444444444444d4242444400000000
5444244d64424424000000005444220000244445542424452000000065555555555555555555555d6555555d00000000655555555555555d5442444500000000
d444444d6444420000000000d44442200022444dd442424d00000000dddddddddddddddddddddddd6ddddddd000000006dddddddddddddddd400244d00000000
555555559d29d29d9d29d29daaaaaaaaaaaaaaaaaaaa1111110700cc000000000000000000000000000000000000000000000000000000000000000000000000
55d55d5525656544465656546d6644444666666666466611100000c0000000000000000000000000000000000000000000000000000000000000000000000000
5d6666d5d6111644451111646d6444445476d66774446611000000c0000000000000000000000000000000000000000000000000000000000000000000000000
555655659517154446147154dd6177775546d66744776661000700c0000000000000000000000000000000000000000000000000000000000000000000000000
d666666d2614164445144164d6615555755666644555666100000cc0000000000000000000000000000000000000000000000000000000000000000000000000
55655655d51115444611115466655888555666745588666100000c00000000000000000000000000000000000000000000000000000000000000000000000000
5d6666d5965656444565656466658828577666758828166100000cc0000000000000000000000000000000000000000000000000000000000000000000000000
555d55d52d92d92d2d92d92dd66778887ff7f77778871661000000c0000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d6177777ff44f77777771661000000c0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006617777ff444f77777101111111100c0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006617fff7f4f4f7777117777777111000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000661ffff77ff5f5711777000007111100000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000661ffff77ff777177700000007771111000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000661444f7f75551770000000000007711000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000066114477555001700000000000000711000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000066615545500411700000000000000771000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000061614540044441700000000000000071000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000061145444445541700000000000000071000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000061445456444541700000000000000711000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000011144456445441770000000000007711000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001111144454441170000000000007110000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000011144454444117000000000007110000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000445644411700000000007110000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c0000000044644441770000000007110000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ccc00000004444441177000000000711000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000ccc00cc00044451117000000000771000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000cccccc0074455011700000000071000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000700c00cc004645011700000000071000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000007770700040cc00645000170000000077000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007000466004455000170000000007000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000770046664440000017000000007000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000440000000017000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000000000001010101000000000000000000000101010001010000000000000000010001010101010100010101000101000101010101010101000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
ffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a080a0a0a080a0a0a080a0a0a080a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00070a0a080a0a350a080a0a080a090000070a080a080a080a35080a0a0a090000070a080a080a080a0a0a0a080a090000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff001706064006062a06400606400619000017064006400640062a40060606190000170640064006400606060640061900000000002c3839ff373e383900002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff001706060606062a06060606060619000017060606060606062a06060606190000170606060606060606060606061900000000002a000000002a000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff070a0a080a0a0a0a080a0a09ffff002725060606063128250637383833000017060606060606062a06060606190000170606060606060606060606061900000000002a000000002a000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff170606400606060640060619ffff000027282506061608300606060619000027282828282506063c2d060606190000272828282828282339060606061900000000002a000000002a000000003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff170606060606060606060619ffff0000000017060606402e383839061900000000000000170606062a06060619000000000000ffffff1706060606061900000000002a000000002a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff170606060606060606060619ffff0000000017060606062a060606061900000000000000170606063a06060619000000000000ffffff1706060606061900000000002a000037383d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffff272828282828282828282829ffff000000071506061a062a0637383833000000000000001706060606060606190000000000070a080a1506060606061900000000003a0000000000000000001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff000708150606062a062a060606061900000000000000170606060606060619000000000017064006060606060606190000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff001740060606062a063c383839061900000000000000170606060606060619000000000017060606060606060606190000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff001706060606062a0606060606061900000000000000272828282828282829000000000027282828282506060606190000000000000000000000000000002a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff002728282828283628282828282829000000000000000000000000000000000000000000000000ffff2728250606190000000000000000000000000000003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffff272828290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000013030106300f0300c62009020066200701005610050100461004010026100301003610030100361004010066000660005600056000460004600044000360003600026000260002600026000140001400
00010000316302e730316302f7202c620297202961027010286102841025610244102371022710236102371016610066000660005600056000460004600046000360003600026000260002600026000160001600
000100000837007360053600535004340033300431007310083200833010650106500e61000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000100001f7401e7401f7403574035740347400e7400d7400d7400c7400c740007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000100000000000000343703437034370343703437034370000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001d6602166021650216402463025630276302862029620296102a6102c6002e600306102d6102c61023610216101962016620126200e6100d6100b6100a62008620076200b65006620046200463004650
010c00000315003154051000310003100031000315003150051000510000100081000515005150001000010006150061500010000100001000010006150061500610000100081000010008150081500010000100
010c00000a1500a154051000310003100031000a1500a150051000510000100081000d1500d150001000010008150081500010000100001000010008150081500610007100061000510008150061500515006150
010c00100c0530c053000000c05324753246030c05300000000000c0030c053000002463530005246350000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002535127350273522735227302000002e3522e3022c352000002a3522a3022935229300273502535022350203502235022352223521e3001b3021b30018351193521b3521e3021e3521e3001b35200000
010c0000185061a5061c5061d506195771e57720577255062250019506005002a5022c5772a577225772550625570275702557025570255701e5001b5021b50028571295722a5721e50231572335002a57200500
010c0000193701b37031302193701b3702e302193701b3702a300293002730020300193001930219302253712a3702a3722a3721b300273702637029370223702a3702c3002c370003002e3700d302253701e300
010c0000225200f520225300f540225500f560225700f570225200f520225300f540225500f560225700f57025520225202553022540255502256025570225702552022520255302254025550225602557022570
010c00001b350163501235012352003001b3001b350003001635000300123501d3001d3500030016350003001e3541e3501e352003001d3541d3501d352003001b3541b3501b3520030019354193501935200300
010c00000f1501b150031500f1501b150031500f1501b150031500f1501b150031501d150111501e150121501a150021500e1501a150021500e1501a150021500e1501a150021500e15012150111500f15011150
010c000017150231500b15017150231500b15017150231500b15017150231500b150191500d1501b1500f150161500a1501e150161500a15022150161500a1501e150161500a1502215012150111500f1500e150
010c00003a255242000c0530c0533a255246030c0530c0533a2550c0030c0530c0533a255300050c0530c0533a255180033a2550c003180031800318053180033a2550c0033a2551a6053a2053a205180533a205
010c00003a255242000c0530c0533a255246030c0530c0533a2550c0030c0530c0533a255300050c0530c0530c05318053326550c05318053326550c05318053326550c053180531a6553a255180533a25518053
010c00001b3541b3501b3521b3521b3521b3521b3551d3040000000000000000000000000000001a3541b3501d3541d3501d3521d3521d3521d3521d3551d3041d3541d3521d3521d3551d3541d3521d3521d355
010c00001e1741e17020172201722217222172221751d10400100001000010000100001000010022174201701a1741b1701a1721a1721717217172161751d1042217422172221722217523174231722317223175
010c000017374173721737217375173741737217372173751737417372173721737519374193721b3721b3751e3741e3711d3711d3721d3721d3751e3741e3711d3711d3721d3721d3752237422372223721e370
010c0000171741717217172171751b1741b1721b1721b17522174221722217222175251742517222172221752217420171201712017220172201752217422170201712017220172201751d1741d1721d1721a170
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 06 08 09 0a
00 07 08 0b 0c
00 06 08 09 0a
00 06 08 0d 0c
00 0e 10 43 44
00 0f 10 43 44
00 0e 10 12 44
00 0f 11 14 44
00 0e 10 12 13
00 0f 11 14 15
00 41 10 43 44
00 41 10 11 44
00 06 10 43 44
02 07 10 11 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
