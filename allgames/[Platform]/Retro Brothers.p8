pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--	retro bros, v1.0
-- by @aplundell

game_name="retrobros"
highscore=0
highscore_coop=0

options={}
options.sound=true
options.monochrome_gag=false
options.coop=false

start_game_at_level=1

weather=true

lives_per_player=3

dazetimer=300

platform_duration=100


update_funcs={}
draw_funcs={}
init_funcs={}



fps=60

make_label=false



--utils
function fade(i)
	if(i>=8)i=7
	memcpy(0x5f10,64*(i),16)
end
function ezsfx(x)
	if(options.sound) sfx(x,x%4)
end
function reset_pal()
	pal()
	palt(0,false)
end
function cel(x)
	return -flr(-x)
end
function printctr(str,x,y,col)
	local wid=4 * #str
	local lft=x-wid/2
	lft=max(0,min(lft,128-wid))
	print(str,lft,y,col)
end
function fontprintctr(str,x,y,col)
	local wid=8 * #str
	local lft=x-wid/2
	lft=max(0,min(lft,128-wid))
	fontprint(str,lft,y,col)
end


--state
state_fade=0
app_state=0
next_state=-1
function _update60()
	update_funcs[app_state]()
	--fade
 if(next_state>=0) then
 	state_fade+=1
 	if(state_fade>8) set_app_state(next_state)
 	return
	elseif(state_fade>=0) then
		state_fade-=1
		return
	end
end

function _draw()
	reset_pal()
	draw_funcs[app_state]()
	if(state_fade>=0)fade(state_fade)

	if(make_label)then
		printctr("aNDY lUNDELL PRESENTS", 64,8,6)
		fontprintctr("retro bros",64,32,7)
		pal()
		--printctr("FOR UP TO FOUR PLAYERS!",64,42,6)
		printctr("FOR UP TO FOUR PLAYERS!",64,42,6)
	end

	if(options.monochrome_gag)then
		local greena={
			{1,0},{2,0},
			{4,3},{5,0},{6,11},{7,11},
			{8,11},{9,11},{10,11},
			{12,11},{13,3},{14,11},{15,11}}
		local greenb={
			{1,3},{2,3},
			{4,3},{5,3},{6,11},
			{8,3},{9,3},{10,11},
			{12,11},{13,3},{14,11},{15,11}}

		if(asdf_green==true)then
			setpal(greena,1)
			asdf_green=false
		else
			setpal(greenb,1)
			asdf_green=true
		end

	end
end


function change_state(s)
	next_state=s
end
function set_app_state(s)
	local f=init_funcs[s]
	if(f~=nil) f()
	app_state=s
	next_state=-1
end

function _init()
	cartdata(game_name.."_aplundell_v001")

	--increment counter
	local play_count=dget(0) + 1
	dset(0,play_count)

	highscore=dget(1)
	highscore_coop=dget(2)

	sndfunc= function()
		local s="sound: off"
		if(options.sound)s="sound: on"
		menuitem(1,s, function() options.sound= not options.sound;sndfunc() end )
	end
	sndfunc()

	monofunc=function()
		local s="monochrome: off"
		if(options.monochrome_gag)s="monochrome: on"
		menuitem(3,s,function() options.monochrome_gag= not options.monochrome_gag;monofunc() end)
	end
	monofunc()

	init_funcs[0]()
end


function score2string(scr)
		local a = flr(scr)
		local b = cel((scr-a)*1000)
		if(b>=1000)then
			a+=1
			b-=1000
		end
		if(a>0) then
			local bstr = ""..b
			while(#bstr < 3) do
				bstr="0"..bstr
			end
			return ""..a..","..bstr
		end
		return ""..b
end
function ishighscore(s)
	if(options.coop)return(s>=highscore_coop)
	return(s>=highscore)
end

function update_highscore(s)
	if(s>highscore_coop and options.coop) then
		highscore_coop=s
		dset(2,highscore_coop)
	elseif(s>highscore and not options.coop) then
		highscore=s
		dset(1,highscore)
	end
end

--font text
function fontprint(str,x,y,col)
	if(str==nil or #str==0) return
	if(x==nil) x=0
	if(y==nil) y=0
	if(col==nil) col=8
	pal(7,col)
	palt(0,true)
	printhelper(str,x,y)
end
function printhelper(s,x,y)
	if(s==nil or #s==0) return
	local ch = sub(s,1,1)
	local idx = chr_lookup[ch];

	spr(idx+192,x,y)

	printhelper(sub(s,2),x+8,y)
end

chr_lookup = nil
chrstr=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz{|}~_"
function build_lookup()
	chr_lookup={}
	for i=1,#chrstr do
  local c=sub(chrstr,i,i)
  chr_lookup[c]=i-1
 end
end
build_lookup()

function setpal(pallet,scr)
	for p in all(pallet) do
		pal(p[1],p[2],scr)
	end
end

function pushback(list,item)
	local c=#list
	for n = c,1,-1 do
		list[n+1]=list[n]
	end
	list[1]=item
end

function ezsfx(x)
	if(options.sound) sfx(x,-1)
end
-->8
-- main menu

player_choice={0,0,0,0}
player_selection={1,0,0,0}
controller_color={8,11,10,12}

init_funcs[0]=function()
	coopfunc=function()
		local s="co-op: off"
		if(options.coop)s="co-op: on"
		menuitem(2,s,function() options.coop=not options.coop;coopfunc() end)
	end
	coopfunc()
end


update_funcs[0]=function ()

	for ii=1,4 do

		if(player_choice[ii]<=0) then
			if(btnp(0,ii-1)) then
				player_selection[ii]-=1
				if(player_selection[ii]<0) player_selection[ii]=4
			end
			if(btnp(1,ii-1)) then
				player_selection[ii]+=1
				if(player_selection[ii]>4) player_selection[ii]=0
			end
		end

		if(btnp(4,ii-1))then
			if( player_choice[ii] > 0 ) then
				change_state(1)
			elseif(is_player_chosen(player_selection[ii])==false) then
				player_choice[ii]=player_selection[ii]
			end
		end

		if(btnp(5,ii-1)) then
			player_choice[ii]=0
		end

	end

end



icon_x={16,48,80,112}
draw_funcs[0]=function ()
	cls(0)

	printctr("aNDY lUNDELL PRESENTS", 64,8,6)
	fontprintctr("retro bros",64,24,7)
	pal()
	--printctr("for up to four players!",64,48,6)
	printctr("FOR UP TO FOUR PLAYERS!",64,42,6)

	spr(48,8,24)
	spr(32,109,24,1,1,true)


	if(has_any_player_chosen()) then
		printctr("press Ž to start ",64,96,8)
	else
		printctr("select your character ",64,96,8)
	end

	local yy=78

	for i = 1,4 do
		draw_player(icon_x[i],yy,i)

		if(player_choice[i]>0) then
			local c = controller_color[i]
			rect(icon_x[player_choice[i]]-5,yy-5,icon_x[player_choice[i]]+4,yy+5,c)
		end

	end

	if(player_selection[1]>0 and player_choice[1]==0)then
		spr(172,icon_x[player_selection[1]]-12,yy-12)
	end
	if(player_selection[2]>0 and player_choice[2]==0)then
		spr(189,icon_x[player_selection[2]]+4,yy+4)
	end
	if(player_selection[3]>0 and player_choice[3]==0)then
		spr(188,icon_x[player_selection[3]]-12,yy+4)
	end
	if(player_selection[4]>0 and player_choice[4]==0)then
		spr(173,icon_x[player_selection[4]]+4,yy-12)
	end

	if(options.coop)then
		printctr("co-op highscore:"..score2string(highscore_coop),64,120,7)
	else
		if(highscore>0)printctr("highscore:"..score2string(highscore),64,120,7)
	end
end

function has_any_player_chosen()
	for i=1,4 do
		if(is_player_chosen(i)) return true
	end
	return false
end
function is_player_chosen(x)
	for c in all(player_choice) do
		if(c==x) return true
	end
	return false
end
function draw_player(x,y,i)
	x-=4
	y-=4
	s=player_bw[i]
	if(is_player_chosen(i)) then
		s=player_sp[i]
	end
	palt(0,true)
	spr(s,x,y)
end

-->8
--game

bonus_level_time=10

players={{}}

bumps={}


monsters={}

score_blips={}

pow_graphical_offset=0


--particles
parts={}
-- add_particle(x,y,dx,dy,col,lifespan)

timer=0

--level
level={}
--level.number=1
--level.map=-1
--level.monster_delay=60*5
--level.monsters={}
level.platforms={0,0,0,0}
--level.pow=3
--seconds until hazards
--level.icicles=10
--level.fireballs=11
--level.snowmen=10
--level.bonus_level=false
level.end_timer=1.0


bonus_coins={
													{32,8},
													{9,42},{24,42},
													{32,70},
													{9,102}
												}

maps={
	{17,0}, --1 standard yellow
	{34,0},	--2 with grass
	{50,0}, --3 cyber!
	{68,0}, --4 frozen
	{85,0}, --5 roy g. biv
	{104,0},--6 bricks
	{17,16},--7 blocks
	{34,16},--8 vanishing
	{0,16}, --9 little ice
	}

--pipes
--pipe_time_2_monster=60
--pipe_queue={}
--pipe_left=false
--pipe_frame={0,0,0,0}

function init_pipe()
	--queue
	pipe_time_2_monster=60
	pipe_queue={}
	foreach(level.monsters,function(t)
		add(pipe_queue, make_monster(t,0,0,0,0))
	end)


	--gfx
	pipe_frame={0,0,0,0}

	--misc
	pipe_left=(rnd(100)<50)

end

function init_map(i)
	for xx=0,15 do
		for yy=0,15 do
			local t = mget(xx+maps[i][1], yy+maps[i][2])
			mset(xx,yy,t)
		end
	end
end


function update_pipe()
	update_sewer()

	if(#pipe_queue==0) then
		pipe_time_2_monster=level.monster_delay
		return
	end

	if(#monsters==0) then
		pipe_time_2_monster=min(50,pipe_time_2_monster)
	end

	pipe_time_2_monster-=1

	--visual
	pipe_frame[1]=0
	pipe_frame[2]=0
	p=2;
	if(pipe_left)p=1
	pipe_frame[p] = max(0,6 - flr(pipe_time_2_monster * 0.25))
	if(pipe_frame[p]==6)pipe_frame[p]=0

	if(pipe_time_2_monster==0) then
		local x = 116
		if(pipe_left) x = 8

		--move monster to monster list
		local m = pipe_queue[1]
		del(pipe_queue,m)
		add(monsters,m)

		--position
		if(m.piped) then
			m.x=x; m.y=8
			m.dx=-8; if(pipe_left)m.dx=8
			m.fliped=(m.dx<0)
			m.walking=-1; if(pipe_left)m.walking=1
		end

		--next!
		if(m.piped) pipe_left= not pipe_left
		pipe_time_2_monster=level.monster_delay
	end

end



function update_sewer()

	pipe_frame[3]=max(0,pipe_frame[3]-0.25)
	pipe_frame[4]=max(0,pipe_frame[4]-0.25)


	local f = function(m,p,x,y)
			if(m.piped==false) return
			local dx=abs(m.x-x)
			local dy=abs(m.y-y)

			if(max(dx,dy)<8) then
				--move monster to pipe
				del(monsters,m)
				--if not a coin, re-queue
				if(m.type~=7) add(pipe_queue,m)
				--restart animation
				pipe_frame[p]=5.9
			end
		end

	foreach(monsters,function(m)
			if(m.dazed<=0) f(m,3,0,116)
		end)

	foreach(monsters,function(m)
			if(m.dazed<=0) f(m,4,120,116)
		end)

end



runspeed=1
gravity=0.2
air_friction=0.01
ground_friction=0.06
ice_friction=0.33*ground_friction

function absminus(a,b)
	s=a/abs(a)
	x=abs(a)-abs(b)
	if(x<=0)return 0
	return x*s
end

update_funcs[1]=function ()

	timer += 1.0/fps

	update_platforms()

	if(gameover()) then
		for i=0,3 do
			if(btnp(5,i)) change_state(0)
		end
	end

	for p in all(players) do
		p:update()
	end

	foreach(monsters,function(m) m:update() end)


	update_pipe()

	check_collisions()

	update_pow()

	update_particles()

	update_hazards()

	update_level_status()
end

function update_level_status()
	if(level.bonus_level) then

		-- destroy the coins when
		-- timer runs out
		if(timer>bonus_level_time) then
			monsters={}
		end


		-- count the coins and stuff
		local coins=0
		for m in all(monsters) do
			if(m.type==8) coins+=1
		end

		if(coins <= 0 )then
			level.end_timer-=1/fps

			if(level.end_timer<=0)then
				start_level(level.number+1)
			end

			level.pow=3

		end

	else
		local pests=0
		for m in all(monsters) do
			if(m.pest) pests+=1
		end
		for m in all(pipe_queue) do
			if(m.pest) pests+=1
		end

		if( pests==0 )then
			level.end_timer-=1/fps

			if(level.end_timer<=0)then
				start_level(level.number+1)
			end

		end
	end

end


function update_hazards()

	--icicles
	if(timer>level.icicles and level.icicles >= 0) then
		add(monsters,make_monster(4,0,0,0,0))
		level.icicles+=3+rnd(3)
	end

	--fireballs
	if(timer>level.fireballs and level.fireballs>=0) then

		local count=0
		foreach(monsters,function(m)
			if(m.type==9) then
				count+=1
			end
		end)
		if(count == 0) then
			local x = 4
			local y = 16
			if(rnd(100)<50) x=120-x
			add(monsters,make_monster(9,x,y,0,0))
		end

		level.fireballs= timer+rnd(4)+1.5

	end

	--snowmen
	if(timer>level.snowmen and level.snowmen >= 0) then
		local snowman_exists=false
		for ii = 1,#pipe_queue do
			if(pipe_queue[ii].type==6) snowman_exists=true
		end
		if(snowman_exists==false)then
			add(pipe_queue,make_monster(6,0,0,0,0))
		end
		level.snowmen+=11+rnd(3)
	end
end



draw_funcs[1]=function ()
	cls(0)
	if(weather)	drawweather()

	draw_particles()

	--draw map
 --todo: figure out map
 local y= 0 + pow_graphical_offset
 palt(0,true)
 if(level.map==8 and timer>2)then
 	pal(2,0)
 	pal(8,2)
 	if(timer>4)pal(8,0)
 end
 map(0,0,0,y,16,16) --platforms
	pal()
	draw_blips()

 foreach(bumps, function(b) b:draw() end)


	foreach(monsters, function(m) m:draw() end)

 local pipe=160
 palt(0,false) palt(15,true)

	--setpal({{10,11},{9,3},{4,1}})
 spr(pipe+flr(pipe_frame[1])*2,0,-2,2,2,true,false)
 spr(pipe+flr(pipe_frame[2])*2,112,-2,2,2,false,false)
 spr(pipe+flr(pipe_frame[3])*2,0,112,2,2,true,true)
 spr(pipe+flr(pipe_frame[4])*2,112,112,2,2,false,true)

 pal()
 palt(0)

	for p in all(players) do
		p:draw()
		draw_lives(p)
	end


	--print(stat(1),0,120) --cpu

	-- bonus timer
	if(level.bonus_level) then
		if(#monsters==0) then
			fontprintctr(bonus_str,64,8)			
		elseif(timer>=bonus_level_time)then
			fontprintctr("0.00",64,8)
		else
			bonus_str = ""..(bonus_level_time-timer)
			bonus_str=sub(bonus_str,1,4)
			fontprintctr(bonus_str,64,8)
		end
	end



	-- level start text
	if(timer < 2.0 or gameover()) then
			pal()
			if(gameover()) then
				fontprintctr("game over",64,35,7)
			elseif level.bonus_level then
				fontprintctr("bonus",64,35,7)
				fontprintctr("stage",64,45,7)
			else
				fontprintctr("level " .. level.number,64,35,7)
			end
			pal()
			local draw=function(p,x,y)
				spr(p.tiny,x,y)
				c=p.color
				if(ishighscore(score[p.player]) and flr(timer*2)%2==0) c=7
				print(p:scorestring(),x+8,y,c)
			end

			if level.number > 1 or gameover() then
				if(options.coop)then
					c=7
					if(ishighscore(coop_score) and flr(timer*2)%2==0) c=9
					fontprintctr(players[1]:scorestring(),64,72,c)
					printctr("score:",64,64,6)
				else
					if(players[2]~=nil)then
						if(players[1]~=nil)draw(players[1],16,66)
						if(players[2]~=nil)draw(players[2],78,66)
					else
						if(players[1]~=nil)draw(players[1],50,66)
					end

					if(players[4]~=nil)then
						if(players[3]~=nil)draw(players[3],16,80)
						if(players[4]~=nil)draw(players[4],78,80)
					else
						if(players[3]~=nil)draw(players[3],50,80)
					end
				end
			end --if show scores

	end

end

function start_level(n)
	timer=0

	players={}
	for ii=1,4 do
		if( player_choice[ii] > 0 ) then
			local p = make_player(ii,player_choice[ii])
			add(players,p)
		end
	end

	monsters={}
	pipe_queue={}
	bumps={}
	initweather()

	level.number=n

	while(n>#levels)do
		n -= lvl_backtrack
	end

	local lvl=levels[n]

	level.map=lvl[1]
	level.bonus_level=lvl[2]
	level.monsters=lvl[3]
	level.icicles=lvl[4]
	level.fireballs=lvl[5]
	level.snowmen=lvl[6]

	level.end_timer=2.25

	level.monster_delay=60*5-(6*n)

	if(level.map<0) then --random map?
		level.map=1+flr(rnd(7))
	end
	init_map(level.map)

	if( level.bonus_level ) then
		for c in all(bonus_coins) do
			add(monsters,make_monster(8,c[1],c[2],0,0))
			add(monsters,make_monster(8,128-c[1],c[2],0,0))
		end
	else
		init_pipe()
	end

	ezsfx(17)

end

init_funcs[1]=function()

	menuitem(2)

	start_level(start_game_at_level)

	level.pow=3
	parts={}
	score_blips={}

	for i=1,4 do
		score[i]=0
		lives[i]=lives_per_player
	end
	coop_lives=#players*lives_per_player
	coop_score=0
end



weather_dots={}
function initweather(t)
	for i = 1,50 do
		local d = {}
		d.x = rnd(127)
		d.y = rnd(127)

		d.dx=rnd(0.5)
		d.dy=1+rnd(4)
		d.c = 1
		if(i%4==0) d.c=12

		weather_dots[i]=d
	end
end
function drawweather()
	foreach(weather_dots,function(d)
		pset(d.x,d.y,d.c)
		d.x += d.dx
		d.y += d.dy
		if(d.x>128)d.x-=128+rnd(16)
		if(d.y>128)d.y-=128+rnd(16)
	end	)
end


function add_bump(x,y,player)
	local b={}
	b.x=x
	b.y=y
	b.frame=0
	b.draw=draw_bump

	--find overlapping bumps
	foreach(bumps, function(them)
		if(
			abs(y-them.y)<8 and
			abs(x-them.x)<8) then
				if(b.frame<bump_frames) b.frame=them.frame
				del(bumps,them)
		end
	end)

	add(bumps,b)

	--bump nearby thingies
	local bump_func =function(m)
			if(m==player)return
			if(
				m.landed and
				abs(m.y-b.y)<8 and
				abs(m.x-b.x)<8 ) then

				m:bump(b.x,b.y,player)
			end
		end


	foreach(monsters,bump_func)
	foreach(players,bump_func)

end

bump_frames=10
function draw_bump(b)

	local offset=0
	if(b.frame<bump_frames) then
		offset=b.frame
		b.frame+=2
	else
		offset=(bump_frames*2)-b.frame
		b.frame+=1
	end

	--remove dead bumps
	if(b.frame>bump_frames*2) then
		del(bumps,b)
	end

	function bumpline(x,y,dy)
		if(x<0 or x > 127) return
		dy=dy/4
		y-=7
		for ii=0,16 do
			local c = pget(x,y+ii+dy)
			pset(x,y+ii,c)
		end
	end

	for dx=0,10 do
		if(offset-dx>0) then
			bumpline(b.x+dx+1,b.y,2*(offset-dx/2))
			bumpline(b.x-dx,b.y,2*(offset-dx/2))
		end
	end
end

function check_collisions()
	for m in all(monsters) do
		for p in all(players) do
			local dx = m.x-p.x
			if(abs(dx)<=8) then
				local dy = m.y-p.y
				if(abs(dy)<=8) then
					--todo do pixel collision
					--checks
					if( true ) then
						m:touch(p)
					end
				end
			end
		end
	end
end

function remove_monster(m)
	del(monsters,m)
end

function activate_platform(i)
	level.platforms[i]=platform_duration
	return(8*plat_x[i]+8)
end

plat_x={2,5,9,12}
function update_platforms()
	for i = 1,4 do
		local v = level.platforms[i]
		local tile=0
		if(v>0) tile=87
		if(v>platform_duration*0.50) tile=71

		mset(plat_x[i]+0,1,tile)
		if(tile>0)tile+=1
		mset(plat_x[i]+1,1,tile)

		if(v>0)level.platforms[i]-=1
	end
end

pow_tiles={83,85,69}
pow_immunity=0
function update_pow()
	--update tiles
	if(level.pow<=0)then
		mset(7,11,0)
		mset(8,11,0)
	else
		mset(7,11,pow_tiles[level.pow]+0)
		mset(8,11,pow_tiles[level.pow]+1)
	end
	pow_immunity-=1
	if(pow_graphical_offset<0)then
		pow_graphical_offset+=0.5
	end
end

function pow(player)
	if(level.pow<=0) return
	if(player.dy>0) return
	if(pow_immunity>0) return
	level.pow-=1;
	pow_immunity=30

	for m in all(monsters) do
		if(m.landed) then
			local x = m.x+4
			local y = m.y+8
			m:bump(x,y,player)
		end
	end
	pow_graphical_offset=-5

	ezsfx(19)
end

function add_coin()
	pushback(pipe_queue,make_monster(7,0,0,0,0))
end

function add_particle(
		x,y,
		dx,dy,
		col,lifespan,gravity)

		local p={}
		p.x=x
		p.y=y
		p.dx=dx
		p.dy=dy
		p.col=col
		p.lifespan=lifespan
		p.age=0

		if(gravity~=nil) then
			p.g=gravity/10
		end

		add(parts,p)
end
function update_particles()
	for p in all(parts) do
		p.x+=p.dx
		p.dy+=p.g
		p.y+=p.dy
		p.age+=1
		if(p.age>p.lifespan) then
			del(parts,p)
		end
		--if fire or something
		--adjust colors
	end
end
function draw_particles()
	for p in all(parts) do
		pset(p.x,p.y,p.col)
	end
end
function spr2part(x,y,s,f,life,g)
	s=flr(s)
	local ssx=(s%16)*8
	local ssy=flr(s/16)*8

	for xx = 0,7 do
		for yy = 0,7 do
			local c=sget(ssx+xx,ssy+(yy))

			if(c!=0) then
				local fx= 0.0 + (xx-4)
				local fy=-0.1 + (yy-4)

				add_particle(x+xx,y+yy,fx*f,fy*f,c,life,g)
			end
		end
	end

end

--score blips
blip_lifespan=15
function make_blip(x,y,value,c,c2)
	local s1=min(127+flr(value/100),136)
	local s2=151
	if(value<100)then
		s1=127+flr(value/10)
		s2=152
	end
	local tmp=c+c2
	local b={x,y,s1,s2,blip_lifespan,0.2,c,c2}
	add(score_blips,b)
end
function draw_blips()
	palt(0,true)
	if(#score_blips==0)return
	for ii=1,#score_blips do
		local b=score_blips[ii]
		if(b~=nil)then
			if(b[5]<blip_lifespan*0.33) pal(12,b[8])
			pal(12,b[7])
			pal(1,b[8])
			spr(b[3],b[1],b[2])
			spr(b[4],b[1]+8,b[2])
			b[6]+=0.1
			b[2]-=b[6]
			b[5]-=1

			if(b[5]<=0)del(score_blips,b)
		end
	end
end

function draw_lives(p)
	if(options.coop)then
		rectfill(52,122,76,128,0)
		printctr("‡X"..coop_lives,62,123,7)		
	else
		x=16+24*(p.player-1)
		rectfill(x,122,x+16,128,0)
		print(" X"..p:lives(), x+2,123,7)
		spr(player_tiny[p.g],x,123)
	end
end

function gameover()
	for i=1,#players do
		if(players[i]:lives()>=1 or players[i].dead==false) return false
	end
	return true
end
-->8
--players

score={}
lives={}
coop_lives=6
coop_score=654.321

--player_name={"jelpi","jocko",
--													"jenny","sue"}

player_sp={48,32,100,116}
player_bw={37,53,38,54}
player_dazed={190,174,175,191}
player_tiny={8,24,40,56}
player_pos={25,45,75,95}
--player graphics
--red		:48			green	:32
--pink	:100		blue 	:116

player_color={8,11,14,12}
player_color_dark={2,3,2,1}


function make_player(i,g)
	p=make_obj(
			player_pos[i]	,100,
			player_sp[g],
			0,0)
	p.player=i
	p.ctrl=i-1
	p.g=g
	p.draw=player_draw
	p.dz=player_dazed[g]
	p.tiny=player_tiny[g]
	p.combo_timer=0
	p.combo=0
	setupplayerfunctions(p)
	p.combo_mult=function(this)
		this.combo_timer=1.5
		this.combo+=1
		return this.combo
	end

	p.color=player_color[g]
	p.color_dark=player_color_dark[g]
	p.scorestring = function(p)
		local scr = score[p.player]
		if(options.coop)scr=coop_score
		return score2string(scr)
	end
	p.addscore=function(p,s)
		local oldscore
		local newscore
		if(options.coop)then
			oldscore=coop_score
			coop_score+=(s/1000)
			update_highscore(coop_score)
			newscore=coop_score
		else
			oldscore=score[p.player]
			score[p.player]+=(s/1000)
			update_highscore(score[p.player])
			newscore=score[p.player]
		end
		-- one up!
		if((0.001+oldscore)%10 > (0.001+newscore)%10 or
		   newscore>=4.999 and oldscore < 4.999 )then
			lives[p.player]+=1
			coop_lives+=1
			ezsfx(18)
		end

	end
	p.lives=function(p)
		if(options.coop) return coop_lives
		return lives[p.player]
	end

	return p
end

function setupplayerfunctions(this)
		this.update=update_player
		this.bump=object_bump
		this.wake=object_wake
		this.touch=function(o)end
		this.kill=player_kill
		this.immune=60
		this.dead=false
		this.dazed=0
end

function update_player(p)
	local c = p.ctrl
	local friction=air_friction
	--if(btnp(5,c))change_state(0)

	p.combo_timer-=0.0166
	if(p.combo_timer<0)p.combo=0

 --tiles
 local t=mget((4+p.x)/8,1+p.y/8)
 f=fget(t)
 p.landed=(f~=0)

	--determine friction
	if(p.landed) then
		if(fget(t,7)) then
			friction=ice_friction
		else
		 friction=ground_friction
		end
	end


	t=mget((p.x+4)/8,(1+p.y)/8)
	f=fget(t)
	local bump=(f~=0)
	if(bump) then
		if( band(f,0x8)==0x8 ) then
			pow(p)
		else
			add_bump(p.x+4,p.y-6,p)
		end

	end



	if(p.dazed<=0) then

		--jump
		if((btnp(4,c) or btnp(5,c)) and p.landed) then
			p.dy=-4
			ezsfx(13)
		end
		--walk
 	if(btn(0,c)) then
 		p.dx -= 1.0 * friction
 		p.walking = -1
 	elseif(btn(1,c)) then
 	 p.dx += 1.0 * friction
 	 p.walking = 1
 	else
 		p.dx=absminus(p.dx,friction)
 		if(abs(p.dx)>0.5 and p.landed and p.squeek==nil)then
 			ezsfx(11)
 			p.squeek=1
 		end
 		p.walking = 0
 	end
 else
 	--dazed
 	if(p.landed) then
 		p.dx=absminus(p.dx,friction*2)
 	end
 end

	local g = gravity
	if(not btn(4,c)) g+=gravity
	p.dy += gravity
	if(p.landed and p.dy>0)p.dy=0
	if(p.landed) then
	 p.y-=p.y%8
	end

	--
	if(bump and p.dy<0)p.dy+=abs(0.5*p.dy)

	--
	if(p.dx>runspeed)p.dx=runspeed
	if(p.dx<-runspeed)p.dx=-runspeed
	p.x+=p.dx
	p.y+=p.dy

	if(abs(p.dx)<0.01 and p.walking==0 ) then
		p.frame = 0;
	elseif( abs(p.walking)>0 or p.frame !=0 ) then
		p.frame+=0.5
		if(p.frame>=5) p.frame-=5
		if(p.frame%4==0 and p.landed)then
			ezsfx(10)--tap tap
			p.squeek=nil
		end

	end

	if(p.x-4<0)p.x+=128
	if(p.x>=124)p.x-=128
	if(p.walking>0)p.flipped=false
	if(p.walking<0)p.flipped=true
	if(p.dx==0 and p.landed)p.frame=0

	p.sprt=p.gfx+p.frame

	if(p.immune > 0)p.immune-=1

end

function player_draw(p)
	if(p.dazed>0)then
		local dz=p.dz
		pal()
		palt(p.bg,true)
		spr(dz,p.x,p.y,1,1,p.flipped)
		local s={55,39,23,-55,-39,-23}
		local f=1+(flr(p.dazed/6))%6
		spr(abs(s[f]),p.x,p.y-7,1,1,s[f]>0)
		p.dazed-=1
	else
		object_draw(p)
	end

end

function player_kill(this,other)
	if(this.immune > 0 ) return
	if(make_label)return
	this.dx=1
	this.dy=-4
	this.dead=true
	ezsfx(16)
	if(this.x<other.x)this.dx *= -1

	this.update=player_corpse_update
	this.bump=function(o)end
	this.wake=function(o)end
	this.touch=function(o)end
	this.kill=function(o)end
	this.dazed=0

	if(options.coop)then
		coop_lives=max(0,coop_lives-1)
	else
		lives[this.player]-=1
	end

end

function player_corpse_update(this)
	--rise from your grave!
	if(this.y > 500+8) then
		if(this:lives() <= 0 ) return
		this.x = activate_platform(this.player)
		this.x -= 4 --half player width

		this.y=-16
		this.dx=0
		this.dy=0

		setupplayerfunctions(this)

	end

	this.dy += gravity
	this.x += this.dx*0.5
	this.y += this.dy*0.5
end
-->8
-- generic objects

angry_pal={
	{2,1},{8,12},{15,12},
	{9,11},{4,3},{7,12},
	{10,11},
	}
anger_factor=1.5

function make_obj(
		x,y,
		gfx,
		dx,dy)
	local o={}
	o.x=x
	o.y=y
	o.gfx=gfx;o.frame=0;o.bg=0
	o.fps=0.5
	o.dx=0;o.dy=0
	o.piped=true
	if(dx~=nil)o.dx=dx
	if(dy~=nil)o.dy=dy
	o.landed=false
	o.fliped=(dx<0)
	o.vfliped=false
	o.walking=0 -- -1=left +1=right
	o.jumping=0
	o.runspeed=0.25
	o.dazed=0
	o.angry=false
	o.angry_pal=angry_pal
	o.height=8
	o.immune=0
	o.dead=false
	o.pest=false
	o.draw=object_draw
	o.bump=object_bump
	o.wake=object_wake
	o.kill=function(o)end
	o.touch=function(o)end
	return o
end

function object_draw(o)
	pal()
	palt(o.bg,true)

	if(o.angry) setpal(o.angry_pal)

	local y=o.y
	local vflip=(o.dazed>0 or o.dead or o.vfliped)
	if(vflip) y+=(8-o.height)
	spr(o.sprt,o.x,y,1,1,o.flipped,vflip)
	spr(o.sprt,o.x+128,y,1,1,o.flipped,vflip)
	spr(o.sprt,o.x-128,y,1,1,o.flipped,vflip)
	pal()
end

--generic physics function
function walker_update(e, skip_animation)
	local friction=air_friction


 --tiles
 local t=mget((4+e.x)/8,1+e.y/8)
 f=fget(t)
 e.landed=(f~=0)

	--physics
	if(e.landed) friction=ground_friction

	if(e.dazed>0)then
		e.dazed-=1
		e.dx=absminus(e.dx,friction/2)

		--get up
		if(e.dazed<1) then
			e:wake()
			--wake up naturaly? anger!
			e.angry=true
		end
	else
		--not dazed

		--walking
		if(e.walking==-1) then
			e.dx -= (1.0 * friction)
		elseif(e.walking==1) then
		 e.dx += (1.0 * friction)
		else
			e.dx=absminus(e.dx,friction)
		end
	end

	local g = gravity
	if(not jumping) g+=gravity
	e.dy += gravity
	if(e.landed and e.dy>0)e.dy=0
	if(e.landed) then
	 e.y-=e.y%8
	end

	--physics
	local runspd = e.runspeed
	local fps = e.fps
	if(e.angry) then
		runspd *= anger_factor
		fps *= anger_factor
	end

	if(e.dazed==0) then
		if(e.dx>runspd)e.dx=runspd
		if(e.dx<-runspd)e.dx=-runspd
	end
	e.x+=e.dx
	e.y+=e.dy



	if(skip_animation==nil) then
		local maxframes=7
		if(abs(e.dx)<0.01 and e.walking==0 ) then
			e.frame = 0;
		elseif( abs(e.walking)>0 or e.frame !=0 ) then
			e.frame+=fps
			if(e.frame>=maxframes) e.frame-=maxframes
		end
				if(e.dx==0 and e.landed)e.frame=0
		e.sprt=e.gfx+e.frame
	end

	if(e.x-4<0)e.x+=128
	if(e.x>=124)e.x-=128
	if(e.walking>0)e.flipped=false
	if(e.walking<0)e.flipped=true


	if(e.immune > 0)e.immune-=1
end

function hopper_update(e)
	e.walking=0

	local runspd = e.runspeed
	local fps = e.fps
	if(e.angry) then
		runspd *= anger_factor
		fps *= anger_factor
	end

	if(e.dazed == 0) then
 	--animation
 	if(e.landed) then
 		e.frame+=e.fps
 		if(e.frame>=1) e.frame=1
 	else
 		if(e.frame<3) e.frame=3
 		if(e.dy>0) e.frame+=fps
 		if(e.frame>=7) e.frame=4
 	end

 	--hop
 	if(e.landed) then
 		e.hop_timer -= 1
 		if(e.hop_timer<=0 ) then
 			e.landed = false
 			e.dx+=runspd
 			e.dy-=1.00
 			if(e.flipped) e.dx = -e.dx
 			e.hop_timer = e.hop_interval
 			e.frame=2
 		else
 			--not hopping?
 			if(e.dazed==0) dx=0
 		end
 	else -- not landed?
 		--antigravity
 			e.dy-=gravity*0.90

 			--is flipped?
 			if(e.dx<0)e.flipped=true
 			if(e.dx>0)e.flipped=false
 	end
	else
		--dazed?
		frame=3
	end

	e.sprt=e.gfx+e.frame
	walker_update(e,true) --skip_animation=true
end


function object_bump(o,x,y,player)
	if(o.immune>0)return
	o.dx=o.dx
	o.dx+=((o.x+4)-x)/4
	if(o.dx<-o.runspeed*4)o.dx=-o.runspeed*4
	if(o.dx> o.runspeed*4)o.dx= o.runspeed*4
	o.dy-=1
	o.landed=false

	if(o.dazed>0 and o.dazed<(dazetimer-10)) then
	 --already dazed?
		o.y-=2
	 o:wake() --bumped awake? no anger
	 o.immune=10
	 return
	end

	o.dazed=dazetimer
end
function object_double_tap(o,x,y,player)
	if(o.immune>0)return
	o.gfx+=16
	o.bump=object_bump
	o.runspeed *= 1.25
	o.immune=10
	o.dy-=2
	o.dx+=((o.x+4)-x)/4
	o.landed=false
end


function object_wake(o,do_not_anger)
	o.dazed=0
	o.walking=1
	if(rnd(2)>1)o.walking=-1
end

function object_animate(self)
			self.frame+=self.fps
			self.frame%=7
			self.sprt=flr(self.gfx+self.frame)
end

-->8
--monsters


--if i had been smart, i would
--have organized these. instead,
--they're just in the order that
--i thought of them.
mtypes={}
-- { spr, speed, fps,height }
-- 1 = shroomhead
mtypes[1]={9,0.20,0.5,7}
-- 2 = crabface
mtypes[2]={89, 0.25, 0.25,7}
-- 3 = hopper
mtypes[3]={73, 0.55, 0.25,7}
-- 4 = icicle
mtypes[4]={137, 0, 0.0,8}
-- 5 = snake
mtypes[5]={121,0.75,0.4,3}
-- 6 = snowman
mtypes[6]={41,0.19,0.15,6}
-- 7 = rolling coin
mtypes[7]={16,0.2,.33,8}
-- 8 = floating bonus coin
mtypes[8]={16,0,0.33,8}
-- 9 = fireball
mtypes[9]={153,0.4,0.25,5}

mvalues={100,200,400,50,500,50,100,100,50}

deadly_ice_age=400

function make_monster(t,x,y,dx,dy)

	if(t==4) return make_icicle()
	if(t==9) return make_fireball(x,y)

	local o = make_obj(x,y,105,0,0)

	o.value=mvalues[t]

	o.type=t
	o.walking=-1
	o.update=walker_update

	o.gfx=mtypes[t][1]
	o.runspeed=mtypes[t][2]
	o.fps=mtypes[t][3]
	o.height=mtypes[t][4]

	o.bg=0

	--crabface is a double-tap
	if(t==2)then
		o.bump=object_double_tap
		o.angry_pal={ {8,12},{2,13} }
	end
	--hopper has to do hops
	if(t==3) then
		o.update=hopper_update
		o.hop_interval=30
		o.hop_timer=15
	end

	o.touch=monster_touch
	o.kill=monster_kill

	if(t==5)then --snake
		o.angry_pal={{11,14},{3,2},{5,8}}
	end

	if(t==6)then --snowman
		o.bump=snowman_bump
		o.update=snowman_update
		o.melting=0
	end

	if(t==7 or t==8)then --coin
		o.bg=15
		o.bump=coin_bump
		o.touch=coin_touch
		o.kill=coin_touch
	end

	if(t==8) then --floating coin
		o.x-=4
		o.y-=4
		o.update = object_animate
	end

	if(t==1 or t==2 or t==3 or t==5) then
		o.pest=true
	end

	return o
end
function make_icicle()
	local y=30
	local x=5+rnd(42)
	if(rnd(100)<50) x=128-x

	local t = 4
	local o = make_obj(x,y,0,0,0)
	o.value=mvalues[t]
	o.type=4
	o.gfx=mtypes[t][1]
	o.runspeed=0
	o.fps=0
	o.frame=0
	o.piped=false


	o.iceage=0

	o.update=icicle_update
	o.touch=icicle_touch
	o.kill=monster_kill

	return o
end

function icicle_update(this)

	if( this.iceage < deadly_ice_age ) then
		this.iceage+=1
		local ia=this.iceage
		local f = 6*flr(this.iceage/deadly_ice_age)

		if(ia<6*(deadly_ice_age/6))f=5
		if(ia<5*(deadly_ice_age/6))f=4
		if(ia<4*(deadly_ice_age/6))f=3
		if(ia<3*(deadly_ice_age/6))f=2
		if(ia<2*(deadly_ice_age/6))f=1
		if(ia<1*(deadly_ice_age/6))f=0

		this.frame=f
	else
		this.frame=6
		this.dy += gravity*0.25
		this.y += this.dy
		if(this.y > 200) this.update=corpse_update
	end
	this.sprt=this.gfx+this.frame
end

function icicle_touch(this,player)
	if(this.frame>=6) player:kill(this)

	if(this.frame<6 ) then
		spr2part(
			this.x,
			this.y,
			this.sprt,
			0.04,--force
			15,--life
			0.14) --g
		remove_monster(this)
	end
end

function make_fireball(x,y)

	local o = make_obj(x,y,0,0,0)
	o.gfx=mtypes[9][1]
	o.runspeed=0
	o.fps=0.05
	o.frame=0
	o.piped=false
	o.type=9

	o.value=mvalues[9]

	o.fireage=-180

	o.dx=-mtypes[9][2]
	if(x < 64) o.dx=mtypes[9][2]
	o.dy=-mtypes[9][2]

	o.dy*= (25+rnd(50))/100


	o.update=fireball_update
	o.touch=fireball_touch
	o.kill=monster_kill
	o.bump=function (this,x,y,player)
		ezsfx(25)
		monster_kill(this,player)
		remove_monster(this)
		spr2part(this.x,this.y,158,.05,15,0)
	end
	return o
end
function fireball_update(o)
		o.fireage+=1
		if(o.fireage>30000) then
			o:bump(nil)
			return
		end
		if o.fireage < 0  then
			o.frame+=o.fps
			if o.frame >= 2 then
				o.frame=0
			end
		else
			o.fps = 0.25
			o.x+=o.dx
			o.y+=o.dy

			o.vfliped=(o.dy<0)
			o.flipped=(o.dx<0)

			o.frame+=o.fps
			if(o.frame>=5 or o.frame < 2) then
				o.frame=2
			end


			local px=o.x
			local px=o.x+(o.height/2)
			px += (rnd(4)-2)
			px -= o.dx * 5

			local py=o.y
			local py=o.y+(o.height/2)
			py += (rnd(4)-2)
			py -= o.dy * 5


			local c=8+flr(rnd(3))
			add_particle(px,py,0,0,c,rnd(60),-0.01)

			--bounce off edges
			if(o.y<0)o.dy = abs(o.dy)
			if(o.y>112)o.dy =-abs(o.dy)
			if(o.x<0)o.dx = abs(o.dx)
			if(o.x>120)o.dx =-abs(o.dx)

			--bounce off walls
			px=o.x+(o.height/2)
			py=o.y+(o.height/2)
			local t
			t=mget((px+4*o.dx)/8,py/8)
			if(fget(t)>0) o.dx *= -1

			t=mget(px/8,(py+4*o.dy)/8)
			if(fget(t)>0) o.dy *= -1

			--check for "landed"
			o.landed=false
			t=mget(px/8,(py+7)/8)
			if(fget(t)>0)o.landed=true

		end

		o.sprt=o.gfx+o.frame
end
function fireball_touch(this, player)
	if(this.fireage>0) player:kill(this)
end

function monster_touch(this, player)
	if(	this.dazed !=0 ) then
		this:kill(player)
	else
		-- not-dazed
		player:kill(this)
	end
end

function monster_kill(this,player)
	this.dx=1
	this.dy=-2
	this.dead=true
	if player ~= nil then
		ezsfx(20+player.combo%4)
		if(this.x<player.x)this.dx *= -1
		tmp=this.value+42
		v=this.value*(player:combo_mult())
		player:addscore(v)
		make_blip(this.x,this.y,v,player.color,player.color_dark)
	end

	this.update=corpse_update
	f=function() end
	this.bump=f
	this.wake=f
	this.touch=f
	this.kill=f



	if(this.pest) add_coin()
end
function corpse_update(this)
	this.dy += gravity
	this.x += this.dx
	this.y += this.dy

	if(this.y > 128+8) then
		remove_monster(this)
	end
end

function snowman_update(o)
	if(o.melting==0)then
		walker_update(o)

		local ty=flr(o.y/8)

		--are we on ice? then we're done
		local t=mget((4+o.x)/8,1+ty)
		if(fget(t,7)) return

		if(not o.landed) return
		if(rnd(100) < 90) return

		if( flr(o.x)==60 and ty==6) then
			o.melt_platform=1
		elseif( flr(o.x)==15 and ty==10) then
			o.melt_platform=2
		elseif( flr(o.x)==103 and ty==10) then
			o.melt_platform=3
		elseif( flr(o.x)==23 and ty==2) then
			o.melt_platform=4
		elseif( flr(o.x)==102 and ty==2) then
			o.melt_platform=5
		end
		if(o.melt_platform~=nil)then
			o.melting=1
			o.frame=-65
		end

	else
		o.frame+=(1 * o.fps)
		if(o.frame<1)then
		 o.sprt=o.gfx
		else
			o.sprt=56+flr(o.frame)
		end

		local freeze=function(tx,ty)
			local t=mget(tx,ty)
			local newt=81
			if(fget(t,0))newt=80
			if(fget(t,2))newt=82
			mset(tx,ty,newt)

			for i=0,20 do
				local c = 12
				if(rnd(100)>50) c=7
				local dx= -0.2 + rnd(0.4)
				add_particle(tx*8+rnd(8),ty*8+rnd(8),
				 dx,-0.2,c,30,0)
			end
		end

		if(o.frame>=8) then
			remove_monster(o)
			if(o.melt_platform==1) then
				for i=4,11 do
					freeze(i,7)
				end
			end
			if(o.melt_platform==2) then
				for i=0,4 do
					freeze(i,11)
				end
			end
			if(o.melt_platform==3) then
				for i=11,15 do
					freeze(i,11)
				end
			end
			if(o.melt_platform==4) then
				for i=0,6 do
					freeze(i,3)
				end
			end
			if(o.melt_platform==5) then
				for i=9,15 do
					freeze(i,3)
				end
			end

		end

	end
end

function snowman_bump(this,x,y,player)
	spr2part(
		this.x,
		this.y-2,
		this.sprt,
		0.04,--force
		45,--life
		0.06) --g
		remove_monster(this)
end

function coin_bump(this,x,y,player)
	coin_touch(this,player)
end
function coin_touch(this, player)
	local cx=this.x+4
	local cy=this.y+4

	local c=9

	--normal coin
	if(this.type==7) then
		spr2part(cx,cy,7,0.2,20,0)
	else
		spr2part(cx,cy,6,0.1,20,0)
	end

	if player ~= nil then
		player:addscore(this.value)
		if(this.type==7)make_blip(this.x,this.y,this.value,player.color,player.color_dark)
		ezsfx(12)
	end

	remove_monster(this)
end




-->8
--levels

--map,is bonus,monsters,
--time-to-icicle, time-to-fireball, time-to-snowman
no=-1
levels=
{
--{8,false,{1,2,3,4,5,6,7},5,6,7}, --test level
{1,false,{1,1,1},no,no,no},
{2,false,{1,1,1,1},no,no,no},
{2,false,{1,1,1,1,1,1},no,no,no},
{1,true,{},no,no,no},
{1,false,{2,2,2,2},10,no,15},
{2,false,{1,1,2,2,2,2},10,no,5},
{2,false,{3,3,3,3},10,no,5},
{9,false,{2,2,3,3,3,3},10,no,5},
{4,true,{},no,no,no},
{5,false,{1,1,1,1,2},10,13,15},
{5,false,{1,2,2,2,2,3},10,13,15},
{5,false,{2,2,3,3,3,5},6,7,18},
{4,false,{2,2,2,5,5},6,7,8},
{4,false,{2,2,2,2,5},6,7,8},
{8,true,{},no,no,no},
{7,false,{1,2,2,3,3,5},6,7,18},
{7,false,{2,2,3,3,5,5},6,7,18},
{7,false,{5,3,3,3,5},6,7,18},
{6,false,{1,2,2,3,3,5},3,4,5},
{6,false,{1,5,1,5,1,1},3,4,5},
{8,true,{},no,no,no},
{no,false,{1,1,1,1,2},4,5,6},
{no,false,{1,2,2,2,2,3},4,5,6},
{no,false,{2,2,3,3,5,5},4,5,6},
{no,false,{2,2,3,3,5,5},1,2,4},
{no,false,{5,2,3,3,1,5,2},1,2,3},
}
lvl_backtrack=6
__gfx__
00102030405060608090a0b0c0d0e0f00000000001ccccc00000a000000000000f0f000000000000000000000022220000222200002222000000000000000000
001020304050d060809090b0c050e060c0001cc01ccc777c00aa9a90000000000ffff00000222200002222000222222002222220022222200022220000000000
001020302010d0d020404030305040d0cc10cccccdc7c7c70a009000000aa0000f1f100002222220022222202227272222272722222727220222222000222200
00101010201050d020404030305020501cccccc0ccc7c7c700a9a9a000a009000efff00022272722222727222222222222222222222222222227272202222220
000010101010505020405030101020500ccccc10cc1cccc00000900900a0090000000000222222222222222200ffff0000ffff0000ffff002222222222272722
0000000000005050205050001010205000cccc00cc00000000a9a9a0000990000000000000ffff0000ffff0006ffff6006ffff6006ffff6000ffff0022222222
00000000000010100000000010101010ccccc1001c10c00000009000000000000000000006ffff6006ffff6006000600006006000060060006ffff6006ffff60
0000000000000000000000000000000001c100000ccc000000000000000000000000000000600060006006000000000000000000000000000060060000600060
fff00ffffff00ffffff00fffffff0ffffff0fffffff00ffffff00fff00000000040400000000000000000d000000dd0000000d00000000000000000000000000
ff0aa0ffff0aa0ffff0aa0fffff0a0ffff0a0fffff0aa0ffff0aa0ff000000000444400009990d00099900d009990bb0099900d0099900d0009990d0000999d0
f0a9990ff0a9990fff0a90fffff0a0ffff0a0fffff0a90fff0a9990f0000000004141000944990d0944990bb94499b60944990bb9449900d0944990d0094499d
0a999990f0a9990fff0990fffff090ffff090fffff0990fff0a9990f000000000244400049949bb0499490b649949bb0499490b6499490bb049949bb0049949b
0a999940f0a9990fff0990fffff090ffff090fffff0990fff0a9990f000000000000000094949b60949490bb9494bbb0949490bb949490b60b4949b600949496
f099940ff099940fff0940fffff040ffff040fffff0940fff099940f000000000000000009990bb009999bbb099bbb0009999bbb099900bbbbb990bb000999bb
ff0440ffff0440ffff0440fffff040ffff040fffff0440ffff0440ff0000000000000000bbbbbbb0bbbbbbb0bbbb0000bbbbbbb0bbbbbbbbbbbbbbbbbbbbbbbb
fff00ffffff00ffffff00fffffff0ffffff0fffffff00ffffff00fff00000b00000000000bbbbb000bb000000bb000000bb000000bbbbb000bbbbb000bbbbbb0
00000000000000000400040004000400000000000000000000000000000000000999900000000000007777000000000000777700007777000077770000000000
040004000400040004444440044444400400040007000700066666000000000099fff00000000000076565d000777700076565d0076565d0076565d000777700
04444440044444400414441004144410044444400777777066777770000000009fdfd00000777700076595d0076565d000dd9d0000dd9d0000dd9d00076565d0
04144410041444100244442002444420041444100757775067577750000000009efff000076565d000dd9d0000dd9d0007779700077797700777977000dd9d00
02444420024444200033300000333000024444200677776067777770000000000000000000dd9d000777777007779770766666d07666666d7666666d07779770
003330000033300000bbb40004bbb00000333000005550000055500000000b0000000000077797707666666d7666666d0dd666d00dddddd07666ddd07666666d
00bbb00000bbb400040000000000040004bbb000006660000666660000000000000000007666666d7666666d0ddd666d000ddd00000000000ddd00007666666d
0040400000400000000000000000000000004000007070000070700000000000000000000dddddd00dddddd00000ddd00000000000000000000000000dddddd0
00000000000000000f000f000f000f00000000000000000000000000000000000444400000000000000000000000000000000000000000000000000000000000
0f000f000f000f000ffffff00ffffff00f000f0006000600055555000000030044fff00000000000000000000000000000000000000000000000000000000000
0ffffff00ffffff00f1fff100f1fff100ffffff00666666055777770000030304f3f300000777700007770000000000000000000000000000000000000000000
0f1fff100f1fff100effffe00effffe00f1fff100656665057577750000003004efff00000656500006577000007700000000000000000000000000000000000
0effffe00effffe000222000002220000effffe00766667056777760000000004000000007dd9dd000dd65000075770000007000000000000000000000000000
002220000022200000888f000f88800000222000005550005055500000000000000000000777977007779dd000dd650000777700000000000000000000000000
0088800000888f000f00000000000f000f8880000077700006666600000000000000000006666660776669d007669dd007d565d0077777700000000000000000
00f0f00000f0000000000000000000000000f000006060000070700000000000000000007ddddddd7ddddddd7dddd9dd77666ddd77d565dd77dddd777d0000d7
00004444444444444444000055555555000000000777777777777770000cccccccccc00000000000000000000077770000777700076767670076667000076700
0004090909090909090940006655666600000000770007707700770700c7070707070c000077770000777700077787700777e770000050000000500000005000
0040909090909090909094006666566600000000777707070707070700c0707070707c00077787700777b7700777777007777770007777000077770000777700
00490909090909090909040066665666000000007770770007007707000cccccccccc00007777770077777700717771007177710077787700777877007778770
00049090909090909090400066665666000000007707770707077777000000000000000007177710071777100777777007777770071777100717771007177710
0000444444444444444400006666566600000000770007070707770700000000000000000777777007777770a999999009a99990077777700777777007777770
0000000000000000000000006666566600000000077777777777777000000000000000000999999a0999999000000a000000000a099999900999999009999990
00000000000000000000000066665666000000000000000000000000000000000000000000a000000a0000a0000000000000000000a00a0000a000a00a0000a0
0000cccccccccccccccc000001111111111111100dddddddddddddd0000111111111100000000000000000000000000000000000000000000000000000000000
000c7cccccccccccccccc0001100011011001101dd000dd0dd00dd0d001505050505010008000080080000800800008008000080080000800800008008000080
00c7cc6060ccc060606ccd001111010101010101dddd0d0d0d0d0d0d001050505050510000888800008888000088880000888800008888000088880000888800
00ccc606060606060606dd001110110001001101ddd0dd000d00dd0d000111111111100088088088880880888808808888088088880880888808808888088088
00cc606060606060606050001101110101011111dd0ddd0d0d0ddddd000000000000000008088080080880800808808008088080080880800808808008088080
00cc555555555555555500001100010101011101dd000d0d0d0ddd0d000000000000000002282280022822800228228002282280022822800228228002282280
00cc0000000000000000000001111111111111100dddddddddddddd0000000000000000080000080800000800800000880000080800000808000008008000008
00c00000000000000000000000000000000000000000000000000000000000000000000008000008800000808000008080000080080000088000008080000080
0000b3b3b3b3b3b3b3b300005335b555000000000000000009999900099999000000000000000000000000000000000000000000000000000000000000000000
00033b333b333b333b333000665b6666099999000999990099fffff099fffff00999990008800880088008800880088008800880088008800880088008800880
003090909090909090909300666b666699fffff099fffff09fdfffd09fdfffd099fffff000888800008888000088880000888800008888000088880000888800
0049090909090909090904006666b6669fdfffd09fdfffd09effffe09effffe09fdfffd088988888889888888898888888988888889888888898888888988888
000490909090909090904000666656669effffe09effffe000222000002220009effffe008988980089889800898898008988980089889800898898008988980
0000444444444444444400006666566600222000002220000eeeef000feeee000022200002282280022822800228228002282280022822800228228002282280
000000000000000000000000666656660eeeee000eeeef000f00000000000f000feeee0080000080800000800800000880000080800000808000008008000008
0000000000000000000000006666566600f0f00000f0000000000000000000000000f00008000008800000808000008080000080080000088000008080000080
00008888888888888888000011111111000000000000000004444400044444000000000000000000000000000000000000000000000000000000000000000000
000822222222222222228000c1cccccc044444000444440044fffff044fffff00444440000000000000000000000000000000000000000000000000000000000
008200000000000000002800c1cccccc44fffff044fffff04f3fff304f3fff3044fffff0000000000000000000000000000000bb000000000000000000000000
008200000000000000002800cc1ccccc4f3fff304f3fff304effffe04effffe04f3fff30000000bb000000bb000000bb000000b5000000bb00000000000000bb
000822222222222222228000cc1ccccc4effffe04effffe044ddd00044ddd0004effffe0000000b5000000b5000000b5000000bb000000b5000000bb000000b5
000088888888888888880000ccc1cccc44ddd00044ddd0000ccccf000fcccc0044ddd0000bbb00b3bbb000b3bb0000b300000bb30000bbb3000bbbb500bbb0b3
000000000000000000000000ccc1cccc0ccccc000ccccf000f00000000000f000fcccc00bb3bbbb0b3bbbbb03bbbbbb0bbbbbb30bbbbb3b0bbbb3bb3bbb3bbb0
000000000000000000000000cccc1ccc00f0f00000f0000000000000000000000000f00033033330303333300333333033333300333330303333033033303330
00cc000c00ccc00c00ccc00c00c0c00c00ccc00c00ccc00c00ccc00c00c1c00c00cc100c000cc00000cccc0000cccc0000cccc0000cccc000077770000070700
000c00c00001c0c0000cc0c000ccc0c000c100c000c000c00000c0c0000c00c000c1c0c000000000000cc00000cccc00000cc000000cc000077c777007c77760
000c00c000c100c00000c0c00000c0c00001c0c000c1c0c0000c00c000c0c0c00000c0c00000000000000000000cc00000c7cc0000c7cc0007c7776007c77760
00ccc00c00ccc00c00ccc00c0000c00c00ccc00c00ccc00c000c000c000c000c000cc00c00000000000000000000000000cccc000c7cccc00077770000777600
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc00000cccc000077760000776600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc0000007600000076000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007600000066000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000060000
00008888888888888888000044444444000044444444444444400000000c00000000000000000000000000000000000000000000000000000000000000000000
00099999999999999999900088868886000688868886888688860000c0c0c000c000000000000000000000000000000000000000000000000808008000000000
00aaaaaaaaaaaaaaaaaaaa0082268226000682268226822682260000c0c0c000c000000000000000000090000008890000088800000988000888808000080000
00bbbbbbbbbbbbbbbbbbbb0066666666066666666666666666666600000c0000000000000000900000000000008a999000898990008999800080888000800800
000cccccccccccccccccc0008688868806888688868886888688860000000000000000000009090000900090009aaa700089a9a00089a9a00828080000000000
00002222222222222222000026822682068226822682268226822600000000000000000000009000000000000099aa7000999aa0009999a00008002000080800
000000000000000000000000666666660666666666666666666660000000000000000000000000000000900000077700000aaa000008aa000020200000008000
00000000000000000000000088868886000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffff0affffffffffff0aaafffffffffff0aaaaffffffffffffff0affffffffffffff0affffffffffffff0a8808800000cc0c0c0000000000000000
fffffffffffff0aafffffffffff0aaaaffffffffff0aaaaafffffffff00000aafffffffffffff0aafffffffffffff0aa8080800000c0dccc0000000000000000
ffffffffffff0aaafffffffffff0aaa9ffffffffff0aaa99ffffffff0aaaaaaaffffffffffff0aaaffffffffffff0aaa8800800000cc000c0400040009999900
fffffffffff0aaa9fffffffffff0aaa9fffffffff0aaa999ffffffff07aaaaa9ffffffff0000aaa9fffffffffff0aaa980088808c0c0000c0444444099fffff0
ffffffffff0aaa99ffffffffff0aaa99fffffffff0aaa999fffffff07aa99999ffffffff0aaaaa99fffffff0000aaa9900000088cc000000044141409ffdfdf0
fffffffff0aaa99afffffffff0aaa99afffffffff0aa999afffffff0aa9999aafffffff0aaa9999afffffff0aaaaa99a00000888ccc00000024444209effffe0
ffffff0f0aaa99a9ffffff0f0aaa99aaffffff0f0aaa99aaffffff00aa999aaaffffff00aa9999a9ffffff00aa9999a900008888cccc00000033300000222000
fffff0a0aaa99a99fffff0a0aaa99a9afffff0a0aaa99aaafffff0a0a999aaaafffff0a0a999aaa9fffff0a0a9999a9900088888ccccc000004b40000efefe00
ffff0aaa0a99a994ffff0aaa0a99a994ffff0aaa0a99aa99ffff0aaa099aaaa9ffff0aaa099aaaa9ffff0aaa0999a994000aaaaabbbbb0000000000000000000
fffff0aaa09a9990fffff0aaa09a9990fffff0aaa09a9999fffff0aaa09aaa99fffff0aaa09aaaa9fffff0aaa09aa9900000aaaabbbb00000000000000000000
ffffff0aa909940fffffff0aa909940fffffff0aa9099400ffffff0aa9099999ffffff0aa90aaa99ffffff0aa90aa99000000aaabbb000000f000f0004444400
fffffff09a9090fffffffff09a9090fffffffff09a9090fffffffff09a909494fffffff09a909999fffffff09a909940000000aabb0000000ffffff044fffff0
ffffffff09990fffffffffff09990fffffffffff09990fffffffffff09990000ffffffff09990000ffffffff09990000aa0aaa0ab0bb0bbb0ff1f1f04ff3f3f0
fffffffff09940fffffffffff09940fffffffffff09940fffffffffff09940fffffffffff09940fffffffffff09940ffa0a0aa0000b0b03b0effffe04effffe0
ffffffffff040fffffffffffff040fffffffffffff040fffffffffffff040fffffffffffff040fffffffffffff040fffaa000a0000bb0b300022200044ddd000
fffffffffff0fffffffffffffff0fffffffffffffff0fffffffffffffff0fffffffffffffff0fffffffffffffff0ffffa00aaa0000b00bbb00f8f0000cfcfc00
00000000000077000770770000077077707770777077000000666600000770000077000000770000707000000000000000000000000000000000000000007000
00000000000777000770770000777077707770777077700006000060000770000770000000077000070000000007700000000000000000000000000000077000
00000000000777000070070000777077707770777077700060066006000000000700000000007000777000000007700000000000000000000000000000070000
00000000000770000700700000777077707770777077700060600006000000000700000000007000070000000777777000770000007777000000000000770000
00000000000000000000000000777077707770777077700060600006000000000700000000007000707000000777777000770000007777000000000000700000
00000000077000000000000000077077707770777077000060066006000000000770000000077000000000000007700000070000000000000077000007700000
00000000077000000000000000000000000000000000000006000060000000000077000000770000000000000007700000700000000000000077000007000000
00000000000000000000000000000000000000000000000000666600000000000000000000000000000000000000000000000000000000000000000000000000
00777000000770000777770007777770000777007777770000777700777777700777770007777700000000000077000000007000000000000007000000777700
07007700007770007700077000007700007777007700000007700000770007707700077077000770000770000077000000070000000000000000700007700770
77000770000770000000777000077000077077007777770077000000000077007700077077000770000770000000000000777770077777700777770000000770
77000770000770000077770000777700770077000000077077777700000770000777770007777770000000000077000007777770000000000777777000007700
77000770000770000777700000000770777777700000077077000770007700007700077000000770000770000077000000777770000000000777770000077000
07700700000770007770000077000770000077007700077077000770007700007700077000007700000770000007000000070000077777700000700000000000
00777000077777707777777007777700000077000777770007777700007700000777770007777000000000000070000000007000000000000007000000770000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700007770007777770000777700777770007777777077777770007777707700077007777770000777707700077007700000770007707700077007777700
07000070077077007700077007700770770077007700000077000000077000007700077000077000000007707700770007700000777077707770077077000770
70077707770007707700077077000000770007707700000077000000770000007700077000077000000007707707700007700000777777707777077077000770
70700707770007707777770077000000770007707777770077777700770077707777777000077000000007707777000007700000777777707777777077000770
70707707777777707700077077000000770007707700000077000000770007707700077000077000770007707777700007700000770707707707777077000770
70070707770007707700077007700770770077007700000077000000077007707700077000077000770007707707770007700000770007707700777077000770
07000077770007707777770000777700777770007777777077000000007777707700077007777770077777007700777007777770770007707700077007777700
00777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777700077777007777770007777000077777707700077077000770770007707700077007700770777777700077700000000000007770000000000000000000
77000770770007707700077077007700000770007700077077000770770007707770777007700770000077700777770000777000077777000007000000000000
77000770770007707700077077000000000770007700077077000770770707700777770007700770000777007700077000777000770707700077700000000000
77000770770007707700777007777700000770007700077077707770777777700077700000777700007770007707077070777070777077700777770000000000
77777700770777707777700000000770000770007700077007777700777777700777770000077000077700007700077007777700770707707077707000000000
77000000770077007707770077000770000770007700077000777000777077707770777000077000777000000777770000777000077777000077700000000000
77000000077770707700777007777700000770000777770000070000770007707700077000077000777777700077700000070000007770000077700000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777770
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020402000808010408000000000000818284080808080104000000000000000102040200000000000000000000000001020402000000000000000000000000
0000000000000000000000000000000001020402010204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001020400000000000000000003000000000000000000200000000100000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444400444444444444444444444444444444444444000000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444400444444444444444444444444444444444444000000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444400444444444444444444444444444444444444000000000000
0000000000000000000000000000000000414141414141424444404141414141410041414141414142444440414141414141717171717171724444707171717171717100515151515151524444505151515151510091919191919192444490919191919191444400959595959595964444949595959595959999990000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444400444444444444444444444444444444444444000000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444400444444444444444444444444444444444444000000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444400444444444444444444444444444444444444000000000000
0000000000000000000000000000000000444444444041414141414142444444440044444444606161616161616244444444444444447071717171717172444444444400444444445051515151515152444444440044444444909191919191919244444444444400444444449495959595959596444444444444000000000000
0000000000000000000000000000000000414244444444444444444444444440410061624444444444444444444444446061717244444444444444444444444470717100515244444444444444444444444450510091924444444444444444444444449091444400959644444444444444444444444494959999000000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444400444444444444444444444444444444444444000000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444444444444440000000000
0000000000000000000000000000000000414141414244444546444440414141410061616161624444454644446061616161717171717244444546444470717171717100515151515244444546444450515151510091919191924444454644449091919191444444959595959644444546444494959595959999440000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444444444444440000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444444444444440000000000
0000000000000000000000000000000000444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444444444444444444444444444444444444444444444440000000000
0000000000000000000000000000000000434343634343434343634343436343430043634343436343434363436343634363737373737373737373737373737373737300436343434343434343436343434343430043434343436343434343434343634343444444939393939393939393939393939393939999440000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414244444041414141414100c4c4c4c4c4c4c54444c3c4c4c4c4c4c40071717171717172444470717171717171710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444444445051515151515152444444440044444444c3c4c4c4c4c4c4c5444444440044444444707171717171717244444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4142444444444444444444444444404100c4c5444444444444444444444444c3c40071724444444444444444444444447071710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414142444445464444404141414100c4c4c4c4c5444445464444c3c4c4c4c40071717171724444454644447071717171710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444444444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444444444444444444444444400444400444444444444444444444444440044444444444444444444444444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4343436343434343436343436343434344c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c40043434363434343434343436343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000f05011050000001405019050000001d05000000220502405000000270500000028050290502905029050290502905029050260502605000000000000000000000000000000000000
000100000d05013050000001905000000000002005000000000002705000000000002e050000000000034050000000000039050000003f0500000000000000000000000000000000000000000000000000000000
0001000038050380501a0501a0501b0501d0501e0502005022050250502a0502b0502e0502e0502e0502d0502c0502705026050220501f0501a05014050120501105011050110501105012050130401403017010
000600002e05037050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003e77700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c63000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003d0303e0303e0203f0203f0103f0103f0103f010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070000397503e070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000010740127401675018750157501475014760147601776023760277602c7702e77031770347700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002575023750227501e7501b750187501575000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002575023750227501e7501b750187501e750257502a7500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002f35034330313502e3302c350283302535022330203501d3301b350193301635014330113500e3300b350093300534002310003100030004300003003a0003d0003f0000d0000e000100001400016000
01100000185601c5701f57024570245701f5702457024570245700000000000000000000019500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000280002b00034000280502b060340603006032070370700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003c67036670306702b670236701e670176701667002650026500265002650026503c600366003060004650026500065000650146500860007600066000460002600066000c60010600156001a60000000
000300001707015070130701107010070100000000000000110000e0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000023070210701f0701d0701c070130000000000000170001500013000110001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002f0702d0702b0702907028070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300003b07039070370703507034070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003e0503905038050350502d050310502d0502b0501f05028050240501205011050200501b0503a05018050150501405012050100500f0500c0500b0500905007050050500060000600006000060000600
001d00002e64300004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 01 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
