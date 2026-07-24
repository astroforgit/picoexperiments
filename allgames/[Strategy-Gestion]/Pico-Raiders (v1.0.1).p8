pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
-- pico raiders v1.0.1
-- by kieron scott

-- select game to load
--  viking raiders https://www.youtube.com/watch?v=e23sh8gjbwg
--  maziacs https://www.youtube.com/watch?v=7dwg9-xcqh4
--  space invaders
--  r-type 

-- to do
--  instructions of how to play

-- critical bugs
-- 
-- minor bugs
--  sometimes boats which want to move up won't move?
--  can't seem to pathfind through enemy unit
--   double check collision, if hostile then attack?

function _init()
	init_funcs={init_mainmenu}
	update_funcs={update_mainmenu}
	draw_funcs={draw_mainmenu}
	update_state(1)
end
function _update()
	update_funcs[state]()
end
function _draw()
	draw_funcs[state]()
end

-- core funcs
function update_state(n,s)
	state,substate,index=n,1,1
	init_funcs[state]()
	if (s) sfx(s)
end
function update_substate(n,s)
	substate,index=n,1
	if (s) sfx(s)
end
-->8
-- cross game funcs

-- distance
function getdist(x1,y1,x2,y2)

	local x,y=x1-x2,y1-y2
	return sqrt(x^2+y^2)
	
end

-- timers
function systime()
	-- s:mm, issues ticking over to new hour
	return stat(95)+stat(94)*60
end

-- delay
function delayrnd(t)
	-- yields if 0-0.999<t per update
	repeat
		if (rnd_chance(t)) t=yield()
	until false
end
function delaysec(t)
	-- t=0 or 1 (use: systime()%2+1)
	-- returns when second changes
	repeat
		if (systime()%2==t) t=yield()
	until false
end
function delaymillisec(t)
	
	-- define variables
	local ms,cs=0,0
	
	-- approximately 1 second to increase cs
	-- track milliseconds and count seconds passed
	while true do
		ms+=0.0001
		if (ms>100) cs+=1 ms=0
		if (cs+ms/100>t) cs=0 ms=0 t=yield()
	end
	
end

-- print
function bprint(s,x,y,c)
	-- background print
	rectfill(x,y,x+#s*4-2,y+4,c[1])
	print(s,x,y,c[2])
end
function rprint(s,x,y,c,spc)
	-- default: 4px between chars
	local spc,i=spc or 4
	-- rainbow colors
	for i=1,#s do
		print(sub(s,i,i),x+i*spc-spc,y,c[i%#c+1])
	end
end
function cprint(s,y,c)
	-- centred
	print(s,64-#s*2,y,c)
end
function cfprint(s,y,c,t)
	-- centred and 2 tone flashing
	fprint(s,64-#s*2,y,c,t)
end
function crprint(s,y,c,spc)
	-- centred rainbow
	rprint(s,64-#s*(2+(spc-4)\2),y,c,spc)
end
function fprint(s,x,y,c,t)
	-- 2 tone flashing
	local t=t or flr(time()*3)
	rectfill(x,y,x+#s*4-2,y+4,c[t%#c+1])
	print(s,x,y,c[(t+1)%#c+1])
end
function contprint(dx,dy,c,x,y)
	-- default: bottom right
	local x,y=x or 113,y or 114
	-- controller
	rectfill(x-8,y-10,x+14,y+13,c)
	print("",x+dx*8,y+dy*8,7)
end

-- flashing sprites
function fsspr(s,w,x,y,c,t)
	local t=t or flr(time()*3)
	rectfill(x,y,x+w*8-1,y+7,c[t%#c+1])
	pal(1,c[(t+1)%#c+1])
	sspr(s%16*8,s\16*8,w*8,8,x,y)
	pal(1,1)
end
function fspr(s,x,y,c,t)
	local t=t or flr(time()*3)
	rectfill(x,y,x+7,y+7,c[t%#c+1])
	pal(1,c[(t+1)%#c+1])
	spr(s,x,y)
	pal(1,1)
end

-- random numbers
function rnd_ceil(n,m)
	-- 1 > x > n
	return ceil(rnd(n))+(m or 0)
end
function rnd_flr(n,m)
	-- 0 > x > n-1
	return flr(rnd(n))+(m or 0)
end
function rnd_chance(n)
	-- 0 > x > 1 < n
	return rnd()<n
end
-->8
-- main menu
function init_mainmenu()
	menuitem(1,"game menu",load_gamemenu)
	menuitem(2,"main menu",_init)
	gameid=1
	games={
		{init=init_norse,name="pico raiders"},
		{init=init_norse,name="pico invaders"},
		{init=init_norse,name="p-type"}		
	}
	load_game()
end
function update_mainmenu()
	if (btnp(”)) gameid=(gameid-2)%#games+1
	if (btnp(ƒ)) gameid=gameid%#games+1
	if (btnp(—)) load_game()
end

function draw_mainmenu()
	cls() local i for i=1,#games do
		print(games[i].name,16,i*8,7)
	end print("—",2,gameid*8,7)
end

-- menu func
function load_game()
	games[gameid].init()
	init_funcs[state]()
end
function load_mainmenu()
	_init()
end
function load_gamemenu()
	update_state(1)
end
-->8
-- norse raiders

function init_norse()
	
	-- load graphics
	-- 0x6300 to sprites
	-- 0x???? to map
	
	init_funcs={init_loading_norse,init_menu_norse,init_game_norse,init_instructions_norse}
	draw_funcs={draw_loading_norse,draw_menu_norse,draw_game_norse,draw_instructions_norse}
	update_funcs={update_loading_norse,update_menu_norse,update_game_norse,update_instructions_norse}
	
end

-- game init
function init_loading_norse()
	
	sfx(9)
	
	pal(1,140,1) 	-- dark blue to medium blue
	pal(11,139,1)	-- green to dark green
	
	cols,fcols,names={8,11,14,9},{8,10},{"brunhilda","odin","wotan","egbert"}
	
end
function init_menu_norse()
	
	numplayers,numcpu,players=1,0,{}
	dx,dy=0,0
	
end
function init_instructions_norse()
	
end
function init_game_norse()

	-- declare variables
	local x,y,w,h,i,j,n,c,success
	local dirs={
		{x=-1,y=-1},{x=0,y=-1},{x=1,y=-1},
		{x=-1,y= 0},{x=0,y= 0},{x=1,y= 0},
		{x=-1,y= 1},{x=0,y= 1},{x=1,y= 1}
	}
	
	repeat
		
		-- init variables
		success,player,turn,frost=true,1,0,0
		units,gmap={},{}
		
		-- clear variables
		for i=1,#players do
			players[i].castle=nil
		end
		
		-- init map
		for y=1,13 do
			gmap[y]={}
			for x=1,16 do
				gmap[y][x]=nil
			end
		end
		
		-- create rivers
		x,y=rnd_ceil(16),rnd_ceil(11,1)
		for i=1,7 do
		
			-- create wiggly river
			-- across
			-- 	pick ty +- 2
			-- 	if reached step, then move 1 y and continue
			-- vertical
			--  pick tx +- 2 
			--  if reached step, then move 1 x and continue
			
			-- random chance of picking new coords
			if (rnd_chance(0.25)) x,y=rnd_ceil(14,1),rnd_ceil(11,1)
			
			-- define variables
			local tx,ty,tw=rnd_ceil(14-abs(x-8),2),rnd_ceil(10-abs(y-6),1),rnd_ceil(2,2)-1
			local sx,sy=1,1
			
			-- river goes left/right
			if i%2==0 then
				
				if (x>8) sx*=-1
				
				for n=0,tx do
					gmap[y][x]={x=x,y=y,s=61,c=0}
					if (n<tx) x=mid(1,x+sx,16)
				end
				
			-- river goes up/down
			else
			
				if (y>6) sy*=-1
				
				for n=0,ty do
					for j=0,tw do
						if x>8 then 
							gmap[y][x-j]={x=x-j,y=y,s=61,c=0}
						else
							gmap[y][x+j]={x=x-j,y=y,s=61,c=0}
						end
					end
					if (n<ty) y=mid(2,y+sy,12)
				end
				
			end
		
		end
		
		-- create castles
		for i=1,#players do
			
			local p,count=players[i],176
			local coords=16
			
			-- repeat placement until first valid coord
			-- found or all coords checked
			repeat
				
				-- define variables
				local dist=999
				n,c=0,0
				
				-- check points sequentially
				x,y=coords%16+1,coords\16+1
				coords+=1
				
				-- get min dist to other players
				for j=1,i-1 do
					
					-- define variables
					local cx,cy=players[j].castle.x,players[j].castle.y
					local d=getdist(x,y,cx,cy)
					
					-- store shortest distance
					if (d<dist) dist=d
					if (y==cy or x==cx) dist=0
					
				end
				
				-- validation check
				if dist>5 then
					
					-- check river access
					if (not all_collisions_norse(x-1,y-1,3,61)) n+=1
					if (not all_collisions_norse(x-1,y+1,3,61)) n+=1
					
					-- check blank spaces
					for j=1,9 do
						if (not all_collisions_norse(x+dirs[j].x,y+dirs[j].y,1)) c+=1
					end
					
					-- valid placement break loop
					if (n==1 and c==6) break
					
				end
				
				-- decrement counter
				count-=1
				
				-- exit if loop failed
				if (count<0) success=fail break
				
			until false
			
			-- if placement of current player
			-- did not fail then add player
			if success then
				
				-- place castle
				gmap[y][x]={x=x,y=y,s=44,c=cols[i]}
				
				-- define player variables
				p.castle={x=x,y=y,c=cols[i]}
				p.gold=50
				p.unit=nil
				
				-- buy units
				buy_unit_norse(3,p,true)
				buy_unit_norse(1,p,true)
				buy_unit_norse(1,p,true)
				buy_unit_norse(1,p,true)
				buy_unit_norse(2,p,true)
				
			-- else placement failed then
			-- skip and retry with new map
			else
			
				break
				
			end
			
		end
		
		-- create drinking horns
		for i=1,7 do
			repeat
				x,y=rnd_ceil(16),rnd_ceil(13)		
			until not all_collisions_norse(x,y)
			gmap[y][x]={x=x,y=y,s=46,c=0}
		end
		
		-- create chests
		for i=1,2 do
			repeat
				x,y=rnd_ceil(16),rnd_ceil(13)		
			until not all_collisions_norse(x,y)
			gmap[y][x]={x=x,y=y,s=45,c=0}
		end
		
		-- show process
		draw_game_norse()
		local col={8,10} if (systime()%2==0) col={10,8}
		cfprint(" generating map ",51,col)
		flip()
		
	until success

end

-- game update
function update_loading_norse()	
	if (btnp()&0x3f!=0) update_state(2,8)
end
function update_instructions_norse()
	if (btnp()&0x3f!=0) update_state(2,8)
end
function update_menu_norse()
	
	-- define variables
	local len1,totalplayers=#players+1,numplayers+numcpu
	
	-- guide to instructions
	if substate==1 then
		
		if (btnp(—)) update_state(4,8)
		if (btnp(Ž)) update_substate(2,8)
		
	-- select players
	elseif substate==2 then
		
		if (btnp(‹)) numplayers=(numplayers-1)%5
		if (btnp(‘)) numplayers=(numplayers+1)%5
		if btnp(—) then
			
			numcpu=4-numplayers
			local i=3 if (numplayers==4) i=4
			update_substate(i,8)
			
		end
		
	-- select cpus
	elseif substate==3 then
		
		if (btnp(‹)) numcpu=(numcpu-1)%(5-numplayers)
		if (btnp(‘)) numcpu=(numcpu+1)%(5-numplayers)
		if btnp(—) then
			
			local i=2 if (totalplayers>1) i=4
			update_substate(i,8)
			
		end
	
	-- select images
	elseif substate==4 then
		
		if (btnp(”)) index=(index-2)%4+1
		if (btnp(ƒ)) index=index%4+1
		if btnp(—) then
			
			-- skip if already chosen
			for i=1,#players do
				if (players[i].s==index) return
			end
			
			-- create player
			players[len1]={
				name=names[index],
				s=index,
				c=cols[len1],
				gold=50,
				unit=nil,
				castle=nil,
				cpu=len1>numplayers
			}
			
			-- start game or select next
			if len1==totalplayers then update_substate(5,8)
			else index=index%4+1 sfx(8) end
			
		end
	
	-- start game
	elseif substate==5 then
		
		if (btnp(—)) update_state(3,8)
		
	end
	
end
function update_game_norse()
	
	-- define variables
	local p=players[player]
	local w=check_end_game_norse()
	
	-- if player is dead then skip
	if (p.dead) end_round_norse() return
	if (w!=0) end_game_norse(w) return
	
	-- if cpu and not in map approve
	if substate!=1 and p.cpu then
		
		-- delay for quarter a second
		local wait=cocreate(delaymillisec)
		
		-- if all units moved
		if #p.units==0 then
			
			// buy unit - delay for quarter a second
			if buy_unit_norse(3,p,true) then
				sfx(8)
				draw_game_norse()
				flip()
				coresume(wait,0.25)
			end
			
			// buy unit - delay for quarter a second
			if buy_unit_norse(1,p,true) then
				sfx(8)
				draw_game_norse()
				flip()
				coresume(wait,0.25)
			end
			
			// buy unit - delay for quarter a second
			if buy_unit_norse(1,p,true) then 
				sfx(8)
				draw_game_norse()
				flip()
				coresume(wait,0.25)
			end
			
			// buy unit - delay for quarter a second
			if buy_unit_norse(1,p,true) then 
				sfx(8)
				draw_game_norse()
				flip()
				coresume(wait,0.25)
			end
			
			// buy unit - delay for quarter a second
			if buy_unit_norse(2,p,true) then 
				sfx(8)
				draw_game_norse()
				flip()
				coresume(wait,0.25)
			end
			
			// end turn
			end_round_norse()
			
			return
			
		end
		
		-- carry out CPU commands
		ai_control_norse()
		
		-- delay for quarter a second
		draw_game_norse()
		flip()
		coresume(wait,0.25)
		
	-- if player or in map approve
	else
		
		-- init map
		if substate==1 then
			
			-- accept or redo map
			if (btnp(—)) update_substate(2,8) start_round_norse()
			if (btnp(Ž)) update_state(3,8) -- redo map
			
		-- select unit
		elseif substate==2 then
			
			-- no units left to move
			if (#p.units==0) p.unit=nil update_substate(8,8) return
			
			-- select unit or end move
			if (btnp(—) and p.unit) update_substate(3,8) return
			if (btnp(Ž)) p.unit=nil update_substate(8,8) return
			
			-- cycle through units
			local len,i=#p.units,get_punit_index_norse(p.unit,p.units) or 1
			if (btnp(‹)) p.unit=units[p.units[(i-2)%len+1]]
			if (btnp(‘)) p.unit=units[p.units[i%len+1]]
			
		-- direction to move
		elseif substate==3 then
			
			-- accept direction or cancel move
			if (btnp(—)) update_substate(4,8) return
			if (btnp(Ž)) update_substate(2,8) return
			
			-- get y-axis
			if btn(”) then dy=-1
			elseif btn(ƒ) then dy=1
			else dy=0 end 
			
			-- get x-axis
			if btn(‹) then dx=-1 
			elseif btn(‘) then dx=1
			else dx=0 end
			
		-- distance to move
		elseif substate==4 then
			
			-- skip unit
			if dx==0 and dy==0 then
				
				p.unit.moved=true
				end_move_norse(p,p.unit)
				
				return
				
			end
			
			-- accept distance or cancel move
			if (btnp(—)) move_unit_norse(p,p.unit,dx,dy,index) return
			if (btnp(Ž)) update_substate(3,8) return
			
			-- get distance
			if (btnp(”)) index=min(9,index+1)
			if (btnp(ƒ)) index=max(1,index-1)
			
		-- direction to fire (catapults only)
		elseif substate==6 then
			
			-- accept direction or cancel fire
			if (btnp(—)) update_substate(7,8) return
			if btnp(Ž) then 
				
				p.unit.fired=true
				end_move_norse(p,p.unit)
				
				return
				
			end
			
			-- get y-axis
			if btn(”) then dy=-1
			elseif btn(ƒ) then dy=1
			else dy=0 end 
			
			-- get x-axis
			if btn(‹) then dx=-1 
			elseif btn(‘) then dx=1
			else dx=0 end
			
		-- range to fire (catapults only)
		elseif substate==7 then
			
			-- skip fire
			if (dx==0 and dy==0) end_move_norse(p,p.unit) return
			
			-- accept distance or cancel fire
			if (btnp(—)) shoot_catapult_norse(p,p.unit,dx,dy,index) return
			if (btnp(Ž)) update_substate(6,8) return
			
			-- get distance
			if (btnp(”)) index=min(9,index+1)
			if (btnp(ƒ)) index=max(1,index-1)
			
		-- buy units
		elseif substate==8 then
			
			-- no money left to buy
			if (p.gold<1) update_substate(9,8) return
			
			-- buy unit or end turn
			if (btnp(—)) buy_unit_norse(index,p) sfx(8) return
			if (btnp(Ž)) update_substate(9,8) return
			
			-- cycle units
			if (btnp(”)) index=(index-2)%3+1
			if (btnp(ƒ)) index=index%3+1
			
		-- end turn
		elseif substate==9 then
			
			-- wait for keypress
			if (btnp()&0x3f!=0) end_round_norse(8)
			
		end
		
	end
	
end

-- game draw
function draw_loading_norse()
	
	-- clear screen
	cls(7)
	
	-- draw bg
	rectfill(0,72,127,79,11)
	rectfill(0,80,127,127,12)
	rectfill(0,115,127,127,1)
	
	-- draw characters
	local i
	for i=0,3 do
		pal(1,cols[i+1])
		sspr(i*24,8,24,32,i*30+8,38)
		pal(1,1)
	end
	
	-- draw troops
	palt(2,true)
	local t=time()
	sspr(48,0,8,8,(t+2)*3%136-8,68)
	sspr(8,0,8,8,(t+12)*4%136-8,69)
	sspr(56,0,16,8,128-(t+4)*5%144,70)
	sspr(104,8,24,8,(t+4)*6%152-24,94+cos(t/3))
	sspr(104,8,24,8,128-(t+6)*7%152,86+sin(t/3),24,8,true)
	pal(2,false)
	
	-- draw text
	cprint("c kieron scott 21 v1.0.1",8,12)
	crprint("pico raiders",22,cols,6)
	cprint("nog                    nog",108,7)
	cprint("based on viking raiders",116,7)
	cprint("by mark lucas",122,7)
	
	-- draw flashing text
	local s="  tape loaded  "
	if (t%4<2) s=" press any key "
	fprint(s,34,108,fcols)
	
end
function draw_instructions_norse()
	
	-- clear screen
	cls(7)
	
	-- draw title
	crprint("pico raiders",6,cols,6)
	-- draw headers
	bprint(" fighters ",6,16,{0,7})
	bprint(" hazards ",86,16,{0,7})
	
	-- water
	rectfill(0,70,127,85,12)
	rectfill(52,24,78,85,12)
	print("water",100,72,7)
	
	-- fighters
	pal(1,9)
	-- catapult
	sspr(56,0,16,8,0,28)
	print("catapult",16,29,8)
	-- army
	spr(1,0,38)
	print("army",8,39,8)
	-- army+loot
	pal(2,9)
	palt(2,false)
	spr(1,0,48)
	palt(2,true)
	pal(2,2)
	print("army+loot",8,49,8)
	-- army/drunk
	spr(6,0,58)
	print("army/drunk",8,59,8)
	-- boat
	sspr(104,0,24,8,0,71)
	print("boat",25,72)
	-- end fighers
	pal(1,1)
	
	-- hazards
	pal(1,cols[3])
	-- castle
	spr(44,120,28)
	print("castle",96,30,cols[1])
	-- treasure chest
	spr(45,120,38)
	print("chest",100,40,cols[1])
	-- drinking horn
	spr(46,120,48)
	print("horn",104,50,cols[1])
	-- end hazards
	pal(1,1)
	
	-- draw players
	for i=1,5 do
		pal(1,cols[i%4+1])
		sspr((i%4+1)*24-24,8,24,32,i*24-20,92)
		pal(1,1)
	end
	
	cfprint("press any key",120,fcols)
	
end
function draw_menu_norse()
	
	-- declare variables
	local i,j
	
	-- white background
	cls(7)
	
	-- draw title
	crprint("pico raiders",6,cols,6)
	
	-- draw players
	for i=1,4 do
		color(1)
		for j=1,#players do
			local p=players[j]
			if (p.s==i) color(p.c) pal(1,p.c)
		end
		if (substate==4) print(i.."=",2,i*26)
		sspr(i*24-24,8,24,32,12,i*26-8)
		print(names[i],40,i*26)
		pal(1,1)
	end
	
	-- draw text
	color(2)
	-- demonstration game
	-- guide to graphics
	if substate==1 then
	
		print("guide to graphics? yes — no Ž",2,122)
	
	elseif substate==2 then
		
		print("how many humans?",2,122)
		print("‹ "..numplayers.." ‘—",90,122)
		
	elseif substate==3 then
		
		print("how many cpu? (min:"..max(0,2-numplayers)..")",2,122)
		print("‹ "..numcpu.." ‘—",90,122)
		
	elseif substate==4 then
		
		local s="cpu "..(#players-numplayers+1)
		if (#players<numplayers) s="player "..(#players+1)
		print(s..", which face?",2,122)
		print("” "..index.." ƒ—",90,122)
		
	elseif substate==5 then
		
		fprint(" press any key ",34,122,fcols)
		
	end
	
end
function draw_game_norse()

	-- declare variables
	local p=players[player]
	local c,x,y,i,j,s=p.c

	-- draw ground
	cls(6)
	
	-- draw frost
	rectfill(0,-1,127,frost*8-1,7)
	
	-- draw map
	for y=1,13 do
		for x=1,16 do
			local s=gmap[y][x]
			-- if something at target coords
			if s then
				-- if castle is in a fight
				if s.fight then
					fspr(s.s,x*8-8,y*8-8,{s.c,7})
				-- not castle or fighting
				else
					pal(1,s.c)
					spr(s.s,x*8-8,y*8-8)
				end
			end
		end
	end
	
	-- draw units
	for i=1,#units do
		
		-- define variables
		local u=units[i]
		local s,w,x,y,c=u.s,u.w,u.x*8-8,u.y*8-8,u.c
		
		-- palette change
		if u.gold then pal(2,c)
		else palt(2,true) end
		
		-- sprite change
		if (u.drunk) s=6
		
		-- draw units which aren't cargo
		if not u.carried then
			pal(1,c)
			sspr(s%16*8,s\16*8,w*8,8,x,y)
			if u.cargo then
				if u.cargo[1] then 
					spr(29,x,y)
				end
				if u.cargo[2] then
					spr(30,x+8,y)
				end
				if u.cargo[3] then
					spr(31,x+16,y)
				end
			end
			pal(1,1)
		end
		
		-- clean up
		pal(2,2)
		palt()
		
	end
	
	-- draw flashing castle if no selected unit
	if not p.unit then
		
		if not p.dead and p.castle then
			s,x,y=44,p.castle.x*8-8,p.castle.y*8-8
			fspr(s,x,y,{c,7})
		end
		
	-- draw unit selected
	elseif #p.units>0 then
		
		-- define variables
		local u=p.unit
		
		if u then
			local s,w,x,y,c=u.s,u.w,u.x*8-8,u.y*8-8,u.c
			
			-- palette change
			if u.gold then pal(2,c)
			else palt(2,true) end
			
			-- draw flashing unit
			if u.fight then
				fsspr(s+rnd_ceil(4),w,x,y,{c,7})
			elseif u.cargo then
				fsspr(s,w,x,y,{c,7})
				if u.cargo[1] then
					fspr(29,x,y,{c,7})
				end
				if u.cargo[2] then
					fspr(30,x+8,y,{c,7})
				end
				if u.cargo[3] then
					fspr(31,x+16,y,{c,7})
				end
			elseif not u.carried then
				fsspr(s,w,x,y,{c,7})
			elseif u.carried then
				fspr(28+u.carried[1],x,y,{c,7})
			end
			
			-- clean up
			pal(2,2)
			palt()
		end
		
	end
	
	-- draw ui
	pal(1,c) rectfill(0,104,127,127,7)
	
	-- draw ui face
	sspr(p.s*24-24,8,24,32,0,104)
	
	-- draw accept map
	if substate==1 then
		
		print("— to accept map\nŽ to redraw map",24,111,c)
	
	-- draw select unit
	elseif substate==2 then
		
		print("‹‘ to cycle units\n— to select unit\nŽ to end turn",24,108,c)
	
	-- draw direction of move
	elseif substate==3 then
		
		print("‹‘”ƒ direction\n— to move\nŽ to cancel",24,108,c)
		contprint(dx,dy,c)
		
	-- draw distance of move
	elseif substate==4 then
		
		print("”ƒ distance:"..index.."\n— to move\nŽ to cancel",24,108,c)
		contprint(dx,dy,c)
	
	-- draw direction of fire
	elseif substate==6 then
		
		print("‹‘”ƒ direction\n— to fire\nŽ to skip",24,108,c)
		contprint(dx,dy,c)
		
	-- draw distance of fire
	elseif substate==7 then
		
		print("”ƒ distance:"..index.."\n— to fire\nŽ to cancel",24,108,c)
		contprint(dx,dy,c)
	
	-- draw buy units
	elseif substate==8 then
		
		rectfill(104,104,127,127,c)
		print("gold\nhoard\n"..p.gold,106,108,7)
		print("” ƒ\n— buy\nŽ skip",24,108,c)
		
		if index==1 then fprint("army     @ 1",54,108,fcols)
		else print("army     @ 1",54,108,c) end
		if index==2 then fprint("boat     @ 8",54,114,fcols)
		else print("boat     @ 8",54,114,c) end
		if index==3 then fprint("catapult @ 4",54,120,fcols)
		else print("catapult @ 4",54,120,c) end
	
	-- draw end turn
	elseif substate==9 then
		
		cfprint(" press any key ",114,fcols)
		
	end
	
	-- end draw
	pal(1,1)
	
end

-- funcs norse

-- move unit
function move_unit_norse(p,m,dx,dy,index)
	
	-- define variables
	local halt=false
	local ignore={47,62}
	
	-- boats don't ignore things
	if (m.s==13) ignore=nil
	
	-- carry on moving while actions
	while index>0 do
		
		-- define variables
		local tx,ty,w=m.x+dx,m.y+dy,m.w
		local obj,j={x=tx,y=ty,w=w,r=m.r,i=ignore}
		
		-- if out of bound
		if outbounds_norse(tx,ty,w) then
			
			-- halt
			halt=true
			
		-- only process non-dead units
		elseif not m.dead then
			
			-- decrease steps left
			index-=1
			
			-- define variables
			local t=map_collision_norse(obj)
			
			-- collided with map item
			if t then
				
				-- army & castle
				if m.s==1 and t.s==44 then
				
					-- enemy castle
					if t.c!=m.c then
						
						-- halt
						halt=fight_castle_norse(m,t)
						
					-- friendly castle
					else
					
						-- hand over gold
						if m.gold then
							p.gold+=m.gold
							m.gold=nil
						end
						
						-- halt
						halt=true
						
					end
					
				-- army & chest
				elseif m.s==1 and t.s==45 then
					
					-- give gold to army
					if (m.s==1) m.gold=5
					
					-- halt
					halt=true
					
				-- army & horn
				elseif m.s==1 and t.s==46 then
					
					-- clear horn
					gmap[ty][tx]=nil
					
					-- set as drunk
					m.drunk=true
					
					-- create new horn
					local x,y repeat
						x,y=rnd_ceil(16),rnd_ceil(13)
					until not all_collisions_norse(x,y)
					gmap[y][x]={s=46,c=0}
					
					-- halt
					halt=true
					
				-- catch all halt
				else
					
					halt=true
				
				end
				
			end
			
			-- if unit did not collide with map
			if not t or (t and m.s!=13) then
				
				-- check units
				for j in all(units) do
					
					if unit_collision_norse(j,obj) then
						
						-- not checking against self
						if j!=m then
							
							-- attacker is catapult
							if m.s==7 then
							
								-- so halt
								halt=true
								
							-- attacker is boat
							elseif m.s==13 then
							
								-- if target is boat
								if j.s==13 then 
								
									-- sink enemy
									if j.c!=m.c then
										
										-- if has cargo
										if j.cargo then
										
											-- sink anim
											sink_boat_norse(m,j)
											
											-- remove boat
											del(units,j)
											
										else
											
											-- sfx
											sfx(15)
											
											-- recruit unit
											j.c,j.moved=m.c,true
											
											-- stop move
											halt=true
										
										end
										
									-- else halt
									else
									
										halt=true
										
									end
									
								end
								
							-- attacker is army and target is enemy
							elseif j.c!=m.c then
								
								-- fight army
								if j.s==1 then
									
									-- if army unit is not on boat
									if not j.carried then
										
										-- recruit drunk units
										if j.drunk then
											
											-- sfx
											sfx(15)
											
											-- recruit unit
											j.c,j.drunk,j.moved=m.c,false,true
											
											-- stop move
											halt=true
											
										-- fight unit
										else
											
											halt=fight_army_norse(m,j)
											
										end
										
									end
								
								-- fight catapult
								elseif j.s==7 then
									
									-- sfx
									sfx(15)
									
									-- remove catapult
									del(units,j)
									
									-- draw scene
									draw_game_norse()
									flip()
									
									-- give player a moment to notice
									local delay=cocreate(delaymillisec)
									coresume(delay,0.25)
								
								-- fight boat
								else
									
									-- if has cargo
									if j.cargo then
									
										-- sink anim
										sink_boat_norse(m,j)
										
										-- remove boat
										del(units,j)
										
									else
										
										-- sfx
										sfx(15)
										
										-- recruit unit
										j.c,j.moved=m.c,true
										
										-- stop move
										halt=true
									
									end
									
								end
								
							-- attacker is army and target is friendly
							else
								
								-- if target is drunk (army only)
								if j.drunk and not m.drunk then
								
									-- sober up target
									j.drunk=false
									
									-- stop movement
									halt=true
									
								-- else allow boarding allied boat
								else
								
									-- sober units only trying to board ship
									if not m.drunk then
										
										-- if boat
										if j.s==13 then 
											
											-- if cargo pos filled
											if j.cargo and j.cargo[tx-j.x+1]!=nil then
												halt=true
											else
												halt=false
											end
											
										-- else blocked
										else
											halt=true
										end
										
									-- else halt progress
									else
										
										halt=true
										
									end
									
								end
								
							end
							
						end
						
					end
					
				end
				
			end
			
		end
		
		-- if halted/dead, stop move
		if (halt or m.dead) index,dx,dy,i=0,0,0,3
		
		-- if being carried
		if m.carried then
			
			-- define variables
			local i,b=m.carried[1],m.carried[2]
			
			-- remove unit from cargo
			b.cargo[i]=nil
			
			-- if no cargo left then remove cargo completely
			if (not b.cargo[1] and not b.cargo[2] and not b.cargo[3]) b.cargo=nil
			
		-- if carrying cargo then move units
		elseif m.cargo then
			
			if m.cargo[1] then m.cargo[1].x+=dx m.cargo[1].y+=dy end
			if m.cargo[2] then m.cargo[2].x+=dx m.cargo[2].y+=dy end
			if m.cargo[3] then m.cargo[3].x+=dx m.cargo[3].y+=dy end
		
		end
		
		-- update unit
		m.x+=dx
		m.y+=dy
		m.moved=true
		m.carried=false
		
		-- render game while in loop
		draw_game_norse()
		flip()
		
	end
	
	-- delete dead units
	if m.dead then
		
		del(units,m)
		
	-- check if army boarded ship
	elseif m.s==1 then
		
		-- get boat
		local t=get_unit_at(m.x,m.y,m)
		
		-- if boat add to cargo
		if t and t.s==13 then
			
			-- get pos to add to cargo
			local cx=m.x-t.x+1
			
			-- create cargo if missing
			if (not t.cargo) t.cargo={}
			
			-- add unit to cargo
			t.cargo[cx]=m
			
			-- mark 
			m.carried={cx,t}
			
		end
	
	end
	
	-- back to unit selection
	end_move_norse(p,m)
	
end
function end_move_norse(p,unit)
	
	-- living catapults can fire
	if unit.s==7 and not unit.dead and not unit.fired then
		
		-- select dir to fire
		if p.cpu then update_substate(6)
		else update_substate(6,8) end
	
	-- else find next unit
	else
		
		-- update moveable units
		-- as units may have been killed
		-- update array to prevent issues
		p.units=player_units_norse()
		
		-- get next valid unit
		if #p.units<2 then p.unit=nil
		else
			local u=get_punit_index_norse(p.unit,p.units) or 1
			p.unit=units[p.units[u%#p.units+1]]
		end
		
		-- update moveable units
		p.units=player_units_norse()
		
		-- back to unit select
		if p.cpu then update_substate(2)
		else update_substate(2,8) end
		
	end
	
end

-- sink boat
function sink_boat_norse(unit,boat)
	
	-- define variables
	local s,w,x,y,c=unit.s,unit.w,unit.x*8-8,unit.y*8-8,unit.c
	local tx,ty,w=unit.x+dx,unit.y+dy,unit.w
	local bs,bc,bx,by,bw=boat.s,boat.c,boat.x*8-8,boat.y*8-8,boat.w*8
	local delay,f,t,r,i,dy=cocreate(delaymillisec),0
	
	-- sinking sfx
	sfx(13)
	
	-- sinking anim
	t,r,dy=0,29,1
	repeat
		
		draw_game_norse()
		
		-- draw unit/boat and cargo
		if unit.gold then pal(2,c) else palt(2,true) end
		if unit.cargo then
			fsspr(s,w,x,y,{c,7},flr(f*3))
			if unit.cargo[1] then fspr(29,x,y,{c,7},flr(f*3)) end
			if unit.cargo[2] then fspr(30,x+8,y,{c,7},flr(f*3)) end
			if unit.cargo[3] then fspr(31,x+16,y,{c,7},flr(f*3)) end
		elseif not unit.carried then
			fsspr(s,w,x,y,{c,7},flr(f*3))
		elseif unit.carried then
			fspr(28+unit.carried[1],x,y,{c,7},flr(f*3))
		end
		pal(2,2) palt(2,false)
		
		-- sinking ship
		clip(bx,by,bw,8)
		pal(1,bc)
		rectfill(bx,by,bx+bw,by+8,12)
		palt(2,true)
		sspr(bs%16*8,bs\16*8,bw,8,bx,by+dy)
		if boat.cargo then
			if boat.cargo[1] then spr(29,bx,by+dy) end
			if boat.cargo[2] then spr(30,bx+8,by+dy) end
			if boat.cargo[3] then spr(31,bx+16,by+dy) end
		end
		palt(2,false)
		pal(1,1)
		clip()
		
		flip()
		
		coresume(delay,0.25)
		
		f+=0.25
		dy+=0.25
		t=t+1
		
	until t>r
	
	-- bubbles sfx
	sfx(14)
	
	-- bubbles anim
	t,r,dy=0,17,0
	repeat
		
		draw_game_norse()
		
		-- draw unit/boat and cargo
		if unit.gold then pal(2,c) else palt(2,true) end
		if unit.cargo then
			fsspr(s,w,x,y,{c,7},flr(f*3))
			if unit.cargo[1] then fspr(29,x,y,{c,7},flr(f*3)) end
			if unit.cargo[2] then fspr(30,x+8,y,{c,7},flr(f*3)) end
			if unit.cargo[3] then fspr(31,x+16,y,{c,7},flr(f*3)) end
		elseif not unit.carried then
			fsspr(s,w,x,y,{c,7},flr(f*3))
		elseif unit.carried then
			fspr(28+unit.carried[1],x,y,{c,7},flr(f*3))
		end
		pal(2,2)
		palt(2,false)
		
		-- draw bubbles
		clip(bx,by,bw,8)
		pal(1,7)
		rectfill(bx,by,bx+bw,by+8,12)
		spr(28,bx+16,by+8-dy)
		spr(28,bx+8,by+16-dy)
		spr(28,bx,by+24-dy)
		pal(1,1)
		clip()
		
		flip()
		
		coresume(delay,0.1)
		
		f+=0.1
		dy+=2
		t=t+1
		
	until t>r
	
	-- stop sfx
	sfx(-1)
	
	-- delete units on boat
	if boat.cargo then
		for i=1,3 do
			if boat.cargo[i] then
				boat.cargo[i].dead=true
				del(units,boat.cargo[i])
			end
		end
	end
		
end

-- shoot catapult
function shoot_catapult_norse(p,unit,dx,dy,index,ox,oy)
	
	-- use override target, else random in direction
	local tx,ty=ox or unit.x+dx*index,oy or unit.y+dy*index
	local a={x=tx,y=ty,w=1}
	local s,w,x,y,c=unit.s,unit.w,unit.x*8-8,unit.y*8-8,unit.c
	local delay,t,r,f,by=cocreate(delaymillisec)
	
	-- start fight sfx
	sfx(12)
	
	-- update fire
	t,r,f=1,2,0
	repeat
		
		draw_game_norse()
		fsspr(s+t*w,w,x,y,{c,7},flr(f*3))
		flip()
		
		coresume(delay,0.25)
		
		f+=0.25
		t=t+1
		
	until t>r
	
	-- wait for rock to fall
	t,r=0,4
	repeat
		
		draw_game_norse()
		fsspr(s+2*w,w,x,y,{c,7},flr(f*3))
		flip()
		
		coresume(delay,0.25)
		
		f+=0.25
		t=t+1
		
	until t>r
	
	-- rock hits
	t,r=0,6
	repeat
		
		draw_game_norse()
		fsspr(s+2*w,w,x,y,{c,7},flr(f*3))
		if (not outbounds_norse(tx,ty)) fsspr(60,1,tx*8-8,ty*8-8,{7,c},flr(f*3))
		flip()
		
		coresume(delay,0.25)
		
		f+=0.25
		t=t+1
		
	until t>r
	
	-- end fight sfx
	sfx(-1)
	
	-- destroy units
	for u in all(units) do
		
		if unit_collision_norse(a,u) then
			
			-- mark as dead
			u.dead=true
			
			-- if boat, anim boat death
			if (u.s==13) sink_boat_norse(unit,u)
			
			-- remove unit from lists
			del(units,u)
			
		end
	end
	
	-- replace with ball
	if not outbounds_norse(tx,ty) then
	
		t=map_collision_norse(a)
	
		if t then
		
			-- horn
			if t.s==46 then
				
				-- create new horn
				local x,y repeat
					x,y=rnd_ceil(16),rnd_ceil(13)
				until not all_collisions_norse(x,y)
				
				-- add ball
				gmap[ty][tx]={s=47,c=0}
				
			-- not water, ice, chest or castle
			elseif t.s!=61 and t.s!=62 and t.s!=45 and t.s!=44 then
				
				-- add ball
				gmap[ty][tx]={s=47,c=0}
				
			end
			
		elseif not outbounds_norse(tx,ty) then
			
			-- add ball
			gmap[ty][tx]={s=47,c=0}
			
		end
		
	end
	
	-- mark as fired
	unit.fired=true
	
	-- get next unit
	end_move_norse(p,p.unit)
	
end

-- fight code
function fight_army_norse(a,b)

	-- set units as fighting
	a.fight=true
	b.fight=true
	
	-- define variables
	local delay=cocreate(delaymillisec)
	local c,r,f=0,rnd_ceil(10,5),0
	
	-- start fight sfx
	sfx(10)
	
	-- update fight
	repeat
		
		draw_game_norse()
		if a.gold then pal(2,a.c) else palt(2,true) end
		fsspr(a.s+rnd_ceil(4),a.w,a.x*8-8,a.y*8-8,{a.c,7},flr(f*3))
		if b.gold then pal(2,b.c) else palt(2,true) end
		fsspr(b.s+rnd_ceil(4),b.w,b.x*8-8,b.y*8-8,{7,b.c},flr(f*3))
		pal(2,2) palt(2,false)
		flip()
		
		coresume(delay,0.25)
		
		f+=0.25
		c+=1
		
	until c>r
	
	-- end fight sfx
	sfx(-1)
	
	-- attackers have advantage
	if rnd_chance(0.6) then
		
		a.fight=false
		del(units,b)
		
		draw_game_norse()
		flip()
		
		coresume(delay,0.2)
		
	else
		
		a.dead=true
		b.fight=false
		
		return true
	
	end
	
	return false
	
end
function fight_castle_norse(a,b)

	-- set units as fighting
	a.fight=true
	b.fight=true
	
	-- define variables
	local delay=cocreate(delaymillisec)
	local c,r,f=0,rnd_ceil(10,5),0
	
	-- start fight sfx
	sfx(10)
	
	-- update fight
	repeat
		
		draw_game_norse()
		if a.gold then pal(2,a.c) else palt(2,true) end
		fsspr(a.s+rnd_ceil(4),a.w,a.x*8-8,a.y*8-8,{a.c,7},flr(f*3))
		pal(2,2) palt(2,false)
		fspr(b.s,b.x*8-8,b.y*8-8,{7,b.c},flr(f*3))
		flip()
		
		coresume(delay,0.25)
		
		f+=0.25
		c+=1
		
	until c>r
	
	-- end fight sfx
	sfx(-1)
	
	-- attackers have disadvantage
	if rnd_chance(0.33) then
		
		-- play victory music
		sfx(11)
		
		local p1,p2=getplayerbycolor(a.c),getplayerbycolor(b.c)
		
		-- loop winning animation
		c,r,f=0,29,0
		repeat
			
			-- buffer game graphics
			draw_game_norse()
			
			-- overwrite with face/name
			rectfill(0,104,127,127,7)
			pal(1,a.c)
			sspr(p1.s*24-24,8,24,32,0,104)
			cprint(p1.name,108,a.c)
			
			-- overwrite defeat text
			cfprint(" defeats ",114,{8,10},flr(f*3))
			
			-- overwrite with face/name
			pal(1,b.c)
			cprint(p2.name,120,b.c)
			sspr(p2.s*24-24,8,24,32,103,104)
			pal(1,1)
			
			-- display on screen
			flip()
		
			-- delay
			coresume(delay,0.25)
			
			f+=0.25
			c+=1
			
		until c>r
		
		-- stop fight
		a.fight=false
		b.fight=false
		
		-- convert all units to player
		local i for i in all(units) do
		
			if i.c==b.c then
			
				-- sfx
				sfx(15)
				
				-- change unit ownership
				i.c,i.moved=a.c,true
				
				-- draw update
				draw_game_norse()
			
				-- overwrite with face/name
				rectfill(0,104,127,127,7)
				pal(1,a.c)
				sspr(p1.s*24-24,8,24,32,0,104)
				cprint(p1.name,108,a.c)
				
				-- overwrite defeat text
				cfprint(" defeats ",114,{8,10},flr(f*3))
				
				-- overwrite with face/name
				pal(1,b.c)
				cprint(p2.name,120,b.c)
				sspr(p2.s*24-24,8,24,32,103,104)
				pal(1,1)
				
				-- render to screen
				flip()
				
				-- wait for a moment
				coresume(delay,0.25)
				
				f+=0.25
				
			end
			
		end
		
		-- delete player castle
		gmap[b.y][b.x]=nil
		
		-- mark player as dead
		p2.dead=true
		p2.castle=nil
		
	else
		
		a.dead=true
		b.fight=false
		
		return true
	
	end
	
	return false
	
end

-- player info
function getplayerbycolor(c)
	local i for i in all(players) do
		if (i.c==c) return i
	end
	return nil
end

-- buy units
function buy_unit_norse(i,p,free)
	
	-- define variables
	local tx,ty=p.castle.x,p.castle.y
	local vars={{1,1,1},{13,3,8,61},{7,2,4}}
	local s,w,g,r=unpack(vars[i])
	local ignore={47,62}
	local bought=false
	
	-- correct variables
	if (free) g=0
	
	-- check has gold
	if p.gold>=g then
		
		-- check around castle
		for y=ty-1,ty+1 do
			for x=tx-1,tx-w+2 do
				
				-- define variables
				local clear=true
				
				-- check for any collision
				if (all_collisions_norse(x,y,w,r,ignore)) clear=false
				
				-- if clear then buy
				if clear and not bought then
					
					bought=true
					p.gold-=g
					unit={
						moved=false,  -- moved this round
						fired=false,  -- fired this round
						drunk=false,  -- under cpu control
						dead=false,   -- prevent further updates
						cargo=nil,    -- boat only (array of units in pos if boarded)
						carried=nil,  -- army only (cargo where unit is being carried)
						s=s,w=w,      -- sprite,width
						c=p.c,r=r,    -- color,restricted move to sprite
						x=x,y=y       -- coords
					}
					
					-- add army unit to boat
					if i==2 then
					
						local army={
							moved=false,      -- moved this round
							drunk=false,      -- under cpu control
							dead=false,       -- prevent further updates
							cargo=nil,        -- boat only (array of units in pos if boarded)
							carried={3,unit}, -- army only (cargo where unit is being carried)
							s=1,w=1,          -- sprite,width
							c=p.c,r=nil,      -- color,restricted move to sprite
							x=x+2,y=y         -- coords
						}
						
						unit.cargo={nil,nil,army}
						add(units,army)
						
					end
					
					-- add unit ot main array
					add(units,unit)
					
					-- update player units
					p.units=player_units_norse()
					
					-- exit loop
					break
					
				end
				
			end
			
		end
		
	end
	
	return bought
	
end

-- collision detection
function get_unit_at(x,y,unit)
	
	local a,i={x=x,y=y,w=1}
	
	for i in all(units) do
		if (unit_collision_norse(a,i) and i!=unit or nil) return i
	end
	
	-- return empty list
	return nil
	
end
function all_collisions_norse(x,y,w,r,i,u)
	
	-- variable correction
	w=w or 1
	i=i or {}
	
	-- return map if collision
	local t=map_collision_norse({x=x,y=y,w=w,r=r,i=i})
	if (t) return t
	
	-- create temporary object
	local a={x=x,y=y,w=w}
	
	-- return unit if collision
	for t in all(units) do
		if (unit_collision_norse(a,t,u)) return t
	end
	
	-- return nothing
	return nil

end
function map_collision_norse(a)
	
	local ret={}
	
	local i for i=0,a.w-1 do
		
		local tx,ty=a.x+i,a.y
		
		-- if out of bounds
		if outbounds_norse(tx,ty) then
			
			-- return collision
			return add(ret,{x=tx,y=ty})
			
		-- within bounds
		else
			
			-- get map reference
			local t=gmap[ty][tx]
			
			-- if restricted to specific tiles
			if a.r then
				
				-- restricted tile not found
				if (not t) return {x=tx,y=ty}
				
				-- tile not restricted type
				if (a.r!=t.s) add(ret,t)
				
			-- not restricted to specific tiles
			elseif t then
				
				-- assume fail
				local pass,j=false
				
				-- check ignore list
				for j in all (a.i) do
					if (j==t.s) pass=true
				end
				
				-- if in ignore list
				if (not pass) add(ret,t)
				
			end
			
		end
		
	end
	
	-- return first object collided with
	if #ret>0 then return ret[1]
	-- else no collision
	else return nil end
	
end
function unit_collision_norse(a,b)
	return a.x<b.x+b.w and a.x+a.w>b.x and a.y==b.y
end
function outbounds_norse(x,y,w)
	return x<1 or x>16 or x+(w or 1)-1>16 or y<1 or y>13
end

-- player units
function player_dunits_norse()
	-- return drunk units which haven't moved
	local p,t,i=players[player],{}
	for i=1,#units do
		local unit=units[i]
		if unit.drunk and not unit.moved and unit.c==p.c then
			add(t,i)
		end
	end
	return t
end
function player_units_norse()
	-- return units which haven't moved
	local p,t,i=players[player],{}
	for i=1,#units do
		local unit=units[i]
		if (not unit.drunk and not unit.moved and unit.c==p.c) or p.unit==unit then
			if (unit.s==13 and unit.cargo) or unit.s!=13 then
				add(t,i)
			end
		end
	end
	return t
end
function get_punit_index_norse(unit,arr)
	-- return index of unit in active player units
	local i
	for i=1,#arr do
		if (units[arr[i]]==unit) return i
	end
	return nil
end

-- ai
function ai_control_norse()

	-- define variables
	local p=players[player]
	
	-- update variables
	p.units=player_units_norse()
	
	-- while active units left
	if #p.units>0 then
		
		-- active unit
		if (not p.unit) p.unit=units[p.units[1]]
		
		-- if in move state
		if substate==2 then 
			
			-- display movement
			update_substate(3)
			
			-- random choice 1-10
			local r,arr=rnd_ceil(12),{}
			local options={}
			
			-- reduce skip by one step
			if (p.unit.skip) p.unit.skip-=1
			
			-- if no skip present or skip period has passed
			if not p.unit.skip or p.unit.skip<1 then
				
				-- boats only
				if p.unit.s==13 then
					
					-- skip first attempt at boat
					-- to give units a chance to board
					if not p.unit.skip then
					
						p.unit.skip=1
						
					-- head towards castle
					else
						
						arr=get_nearest_castle_norse(p,p.unit)
						
					end
					
				-- catapults only
				elseif p.unit.s==7 then
					
					-- catapults move away from enemies
					arr=get_nearest_enemy_norse(p,p.unit)
				
				-- army only
				else
				
					-- return if carrying gold
					if p.unit.gold then
						
						set_closest_norse(p.castle,p.unit,arr)
					
					-- if carried
					elseif p.unit.carried then
						
						-- always skip first three moves
						-- to give boat chance to move
						if not p.unit.skip then
							
							p.unit.skip=3
							
						-- wait until out of skips
						-- then attempt to attack enemy castle
						else
							
							arr=get_nearest_castle_norse(p,p.unit)
							
						end
						
					-- head to friendly boat (1-2)
					elseif r<3 then
						
						arr=get_nearest_boat_norse(p,p.unit)
						
					-- head to nearest enemy (3-4)
					elseif r<5 then
						
						arr=get_nearest_enemy_norse(p,p.unit)
						
					-- head to nearest gold (5)
					elseif r==5 then
					
						arr=get_nearest_obj_norse(p,p.unit,45)
						
					-- head to nearest drink (6)
					elseif r==6 then
					
						arr=get_nearest_obj_norse(p,p.unit,46)
						
					-- head to nearest castle (7-12)
					else
						
						arr=get_nearest_castle_norse(p,p.unit)
						
					end
					
				end
				
				-- process args to generate options
				while #arr>0 do
					
					-- define variables
					local target=arr[1]
					local ignore={47,62}
					
					-- army only, if right next to target then carry out option
					if p.unit.s==1 and p.unit.x+target.dx==target.x and p.unit.y+target.dy==target.y then
						
						-- next to target
						add(options,target)
					
					-- if nothing is blocking immediate path then continue
					elseif not all_collisions_norse(p.unit.x+target.dx,p.unit.y+target.dy,p.unit.w,p.unit.r,ignore) then
						
						-- quick check passed
						add(options,target)
						
					-- else find next shortest path
					else
						
						-- define variables
						local dirs,i={
							{x=-1,y=-1},{x=0,y=-1},{x=1,y=-1},
							{x=-1,y= 0},{x=0,y= 0},{x=1,y= 0},
							{x=-1,y= 1},{x=0,y= 1},{x=1,y= 1}
						}
						
						-- create array of options
						for i=1,#dirs do
							
							-- define variables
							local tx,ty,blocked=dirs[i].x,dirs[i].y
							
							-- boats only check water
							if p.unit.s==13 then 
								
								blocked=map_collision_norse({x=p.unit.x+tx,y=p.unit.y+ty,w=p.unit.w,r=p.unit.r})
								
							-- catapults and army check for all units
							else
								
								blocked=all_collisions_norse(p.unit.x+target.dx,p.unit.y+target.dy,p.unit.w,p.unit.r,ignore,p.unit)
								
								-- if collision is boat, override block
								-- always try to board or attack
								if p.unit.s==1 then
									local obj=get_unit_at(p.unit.x+target.dx,p.unit.y+target.dy,p.unit)
									if obj and obj.s==13 and r<5 then
										blocked=false
									end
								end
								
							end
							
							-- if target is not blocked by anything
							if not blocked then
							
								-- declare variables
								local j,k
								
								-- get local distance
								local d=getdist(target.x,target.y,p.unit.x+tx,p.unit.y+ty)
								
								-- catapults: choose furthest distance
								if p.unit.s==7 then
								
									for j=1,#options do if (d>options[j].d) k=j end
									
								-- other units: choose closest distance
								else
								
									for j=1,#options do if (d<options[j].d) k=j end
									
								end
								
								-- add to table at right index
								add(options,{d=d,dx=tx,dy=ty,x=tx,y=ty},k or #options+1)
								
							end
							
						end
						
					end
					
					-- if valid option found
					if #options>0 then
					
						-- get top option
						local option=options[1]
						
						-- further the distance, greater the move
						index=mid(1,option.d,9)
						
						-- head towards target
						dx,dy=option.dx,option.dy
						
						-- exit loop
						break
						
					-- try next option
					else
					
						deli(arr,1)
						
					end
				
				end
				
			end
			
			-- if valid move found
			if #options>0 then
				
				move_unit_norse(p,p.unit,dx,dy,index)
				
			-- else no action, try one last time
			else
				
				-- prevent from moving again
				-- choose random value 2-3
				if not p.unit.skip then
					
					p.unit.skip=rnd_ceil(2,1)
					
				-- if run out of skips
				-- mark as moved
				elseif p.unit.skip<0 then
				
					p.unit.moved=true
					
				end
				
				-- select next unit
				end_move_norse(p,p.unit)
				
			end
			
		-- if in shoot state
		elseif substate==6 then
		
			-- declare variables
			local ox,oy
			
			-- display shooting
			update_substate(7)
			
			-- random shot
			dx,dy,index=rnd_flr(3,-1),rnd_flr(3,-1),rnd_ceil(9)
			
			-- chance of random position on board
			if (rnd_chance(0.5)) ox,oy=rnd_ceil(16),rnd_ceil(13)
			
			-- fire catapult
			shoot_catapult_norse(p,p.unit,dx,dy,index,ox,oy)
			
		end
		
	end
	
end
function get_nearest_obj_norse(p,unit,s)
	
	-- define variables
	local t,x,y={}
	
	-- get min dist to other players
	for x=1,16 do
		for y=1,13 do
			
			-- define variables
			local target=gmap[y][x]
			
			if target and target.s==s then
				set_closest_norse({x=x,y=y},unit,t)
			end
			
		end
		
	end
	
	-- return table
	return t
	
end
function get_nearest_boat_norse(p,unit)
	
	-- define variables
	local t,i={}
	
	-- get min dist to other units
	for i=1,#units do
		
		-- define variables
		local target=units[i]
		
		-- if unit belongs to player and is boat and not self
		if target.c==p.c and target.s==13 and target!=unit then
			set_closest_norse(target,unit,t)
		end
		
	end
	
	-- return table
	return t
	
end
function get_nearest_enemy_norse(p,unit)
	
	-- define variables
	local t,i={}
	
	-- get min dist to other players
	for i=1,#units do
		
		-- define variables
		local target=units[i]
		
		-- if unit is enemy
		if target.c!=p.c then 
			set_closest_norse(target,unit,t)
		end
		
	end
	
	-- return table
	return t
	
end
function get_nearest_castle_norse(p,unit)
	
	-- define variables
	local t,i={}
	
	-- get min dist to other players
	for i=1,#players do
		
		-- define variables
		local target=players[i].castle
		
		-- target has castle and is not players
		if target and target.c!=p.c then
			set_closest_norse(target,unit,t)
		end
		
	end
	
	-- return table
	return t
	
end
function set_closest_norse(target,unit,t)
	
	-- declare variables
	local j,k
	
	-- define variables
	local x,y=target.x,target.y
	local sx,sy=x-unit.x,y-unit.y
	local d=getdist(unit.x,unit.y,x,y)
	
	-- correction
	if sx==0 then sx=0 else sx=sgn(sx) end
	if sy==0 then sy=0 else sy=sgn(sy) end
	
	-- determine index
	for j=1,#t do if (d<t[j].d) k=j end
	
	-- add to table at right index
	add(t,{d=d,dx=sx,dy=sy,x=x,y=y},k or #t+1)

end

-- turn/round func
function start_round_norse()
	
	-- define variables
	local p=players[player]
	local dunits=player_dunits_norse()
	
	-- move drunk unit
	while #dunits>0 do
		
		-- define variables
		local dunit,r=dunits[1],rnd_ceil(8)
		dx,dy,index=rnd_flr(3,-1),rnd_flr(3,-1),rnd_ceil(9)
		
		-- move unit
		move_unit_norse(p,units[dunit],dx,dy,index)
		
		-- remove drunk unit from units to move
		del(dunits,dunit)
		
	end
	
	-- update active units
	p.units=player_units_norse()
	
	-- start move units if not cpu
	if p.cpu then update_substate(2)
	else update_substate(2,8) end
	
end
function end_round_norse(s)
	
	if (s) sfx(s)
	
	players[player].unit=nil
	player+=1
	
	if player>#players then	end_turn_norse()
	else start_round_norse() end
	
end
function check_end_game_norse()
	
	local c,w,i=0,0
	
	-- check for dead players
	for i=1,#players do
		if players[i].dead then c+=1
		else w=i end
	end
	
	if (c!=#players-1) w=0
	
	return w
	
end
function end_game_norse(w)

	-- play victory music
	sfx(11)
	
	-- get winner
	local winner=players[w]
	local c,r,f=0,29,0
	local delay=cocreate(delaymillisec)
	
	-- loop winning animation
	repeat
		
		-- buffer game graphics
		draw_game_norse()
		
		-- overwrite with face/name
		rectfill(0,104,127,127,7)
		pal(1,winner.c)
		sspr(winner.s*24-24,8,24,32,0,104)
		cprint(winner.name,108,winner.c)
		
		-- overwrite defeat text
		cfprint(" the winner ",114,{8,10},flr(f*3))
		pal(1,1)
		
		-- display on screen
		flip()
		
		-- delay
		coresume(delay,0.25)
		
		f+=0.25
		c+=1
		
	until c>r		
	
	-- back to main screen
	update_state(2,8)
	
end
function end_turn_norse()
	
	local x,y,i
	
	-- define variables
	player,frost,turn=1,flr(sin(turn/25+0.33)*16),turn+1
	
	-- update frostline
	for y=1,13 do
		for x=1,16 do
			local t=gmap[y][x]
			if t and (t.s==61 or t.s==62) then
				if frost<y then t.s=61
				else t.s=62 end
			end
		end
	end
	
	-- update units
	for i in all(units) do
	
		-- allow actions for unit
		i.moved=false
		i.fired=false
		i.skip=nil
		
		-- if not on a boat and on water then kill
		if i.s!=13 and not i.carried and gmap[i.y][i.x] and gmap[i.y][i.x].s==61 then
			i.dead=true
			del(units,i)
		end
		
	end
	
	-- start next round
	start_round_norse()
	
end
__gfx__
00000000001110000000000100000000000001000000000000010000000000000011000000000000000000000000100000000000000000001000000000000000
00000000001110100111001000011100011101000001110011101000000000000111000000000000000000000000010000000000000000001000000000000000
00700700000100100111010000011100011101000001110011101000000000001000000000000000000000000000001000000000000000001000000000000010
00077000111111100010100000001110001010000000100001111000000000010000000000111111111100000000000100000000000000001000000000000111
00077000121100000111000000011210011100001111111001111000000000110000000000000001001100000000000110000000100000001000000000000100
00700700111100000121010000101110012100000000121010111110111001010000111011100001000011101110000101001110111011111110111110111100
00000000001010000111100001001011111111000001111100010000101111111111101010111111111110101011111111111010011111111111111111111000
00000000010001001000000010001000100000000001000000100000111000000000111011100000000011101110000000111110000000000000000000000000
00000100001110000100000001110000000000000001110000001000000000000010000000000011000000011000000000100000000000001000000000000000
00000110110001101100000000011000000000000011000000001000000000000010000000000101000000010100000000000100001110001011100011101000
00000111000000011100000000111100000000000111100000010000000000000001000000001001000000010010000000100000001110101011101011101010
00000111000000011100000000001110000100001110000000110000000100000001100000001010000100001010000000000100000100101001001001001111
00001000000000000010000000011111001110011111000000110000000100000001100000001010001110001010000000100000101111101011111011111100
00001111111111111110000000000001111011110000000000111000011111000011100000001010011111001010000000000100111211111112111112111100
00001100110001100110000000000000110001100000000000011100111111100111000000001001111111110010000000100000011111111111111111111000
00001111111111111110000000000001111011110000000000001111111111111110000000001001110001110010000000000100000000000000000000000000
00001001010001010010000000000011111111111000000000000111011011011100000000000111110101111100000011100000000000000000000000000000
00001001000000010010000000000111111111111100000000000011111111111000000000000111110001111100000011100000001000000000000000000000
00001001000000010010000000001111111111111110000000000011111111111000000000001111111111111110000010000000011000000000010000000000
00001001000100010010000000000100010001000100000000000011010001011000000000011111111111111111000010000000011000000000111000000000
00010001010001010001000000000100000000000100000000000110000000001100000000011111111111111111000010101010001000000000111000000000
00010001001110010001000000011000000100000011000000000100000000000100000000011111111111111111000011111110000111101000111000011000
00010001100000110001000001100100000000000100110000001111000100011110000000011110001110001111000011111110000111100111111000011000
00010001010001010001000000000000010001000000000000000111111111111100000000011100001110000111000011111110000111100011110000000000
00100001001110010000100000000000001110000000000000011111101110111111000000000100000100000100000000000000ccccccccdddddddd00000000
00100001000000010000100000010010000000001001000000000111110001111100000000001100010001000110000000000000ccccccccdddddddd00000000
00100001000000010000100000000100100000100100000000011011111111111011000000000010001110001000000000010100ccccccccdddddddd00000000
01000010000000001000010000000001000100010000000000000111111111111100000000000101000000010100000000001000ccccccccdddddddd00000000
01000010000000001000010000000000000100000000000000001001111111110010000000000000100000100000000000111110ccccccccdddddddd00000000
10000100000000000100001000000100000000001000000000010010101110101001000000000001011111010000000000001000ccccccccdddddddd00000000
01000100000000000100010000000000010001000000000000000100101110100100000000000000010101000000000000010100ccccccccdddddddd00000000
00111000000000000011100000000000001010000000000000000000000100000000000000000000000000000000000000000000ccccccccdddddddd00000000
00888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000350502c0501b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001e05020050220502405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00012405500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01200000180501a0501c0501d0501f05021050230502405023050210501f0501d0501c0501a050180501a0501c0501d0501f05021050230502405000000000000000000000000000000000000000000000000000
0108000018050180551c0501c05520050200550000000000000000000523055210551f0551d0551c0551a0551805517055150551305511055100550e0550c055000050000000000000050c0500c0500005000050
011e0000000001805018050000000000017050170500000000000150501505000000000001305013050000000000011050110500000000000100501005000000000000e0500e05000000000000c0500c05000000
010800022405030050000000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
