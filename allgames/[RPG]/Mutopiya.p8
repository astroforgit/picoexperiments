pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
-- mutopiya
-- by greay
--------
-- KEYS
--------
do
	local held,hold_reset = {},nil

	function btnh(n)
		if held[n] > 24 and not hold_reset then
			hold_reset = n
			return true
		end
	end

	function btnr(n)
		if held[n] > 0 and held[n] <= 24 and not btn(n) then
			held[n] = 0
			return true
		end
	end

	function btn_init()
		for i=0,5 do held[i] = 0 end
	end

	function btn_update()
		for i=0,5 do
			if(btn(i)) held[i] += 1
		end
	end

	function btn_lateupdate()
		for i=0,5 do
			if not btn(i) then
				if (hold_reset == i) hold_reset = nil
				held[i] = 0
			end
		end
	end
end
-------
-- DATA
-------
D_pstats={
	-- all stats are out of 16
	hp=16,mhp=16,
	imm=16,h=0,t=0,e=0,inf=0,inf_t=0
}
D_flags={
	wall=0,
	sight="sight"
}

D_enemies={
	{ 	s=160, d=161, name="goblin",
		stats = {hp=4,mhp=4, sight=7}
	},
	{ 	s=144, d=145, name="orc",
		stats = {hp=4,mhp=4, sight=5}
	},
	{ 	s=176, d=177, name="skeleton",
		stats = {hp=4,mhp=4, sight=4}
	},
	{ 	s=132, d=133, name="infected",
		stats = {hp=4,mhp=4, sight=3, inf=5}
	},
	{ 	s=148, d=149, name="slime",
		stats = {hp=4,mhp=4, sight=2, inf=5}
	}
}

D_npcs={130,131, 146,147, 162,163, 178,179}

D_loot={
	{s=209, h=-2, t=-2}, -- apple
	{s=210, h=-5, t=2}, -- bread
	{s=211, h=-3}, -- canned food
	{s=212, h=2, e=-5, hp=-2}, -- coffee
	{s=213, h=-3, t=2}, -- egg
	{s=214, h=-3, t=2}, -- fish
	{s=215, h=-5, t=3, hp=1}, -- meat
	{s=216, h=-2, t=3}, -- plum
	{s=217, e=-2}, -- lemon
	{s=218, t=-4, inf=1}, -- dirty water
	{s=219, h=-2, t=-3, hp=1}, -- milk
	{s=220, h=-2, t=2}, -- jerky
	{s=221, h=-3, inf=3}, -- rotten food
	{s=222, h=-2, t=5}, -- toast
	{s=223, t=-5}, -- water
	{s=240, hp=4}, -- bandage
	{s=241, hp=-2, imm=5}, -- antibiotics
	{s=242, imm=3}, -- vitamin
	{s=243, e=5}, -- sleeping pill
	{s=244, hp=-3, imm=-1, inf=-5} -- panacea
}
D_counts = {0, 0, 0, 1, 1, 2, 2, 3}

D_snore={t=0,f=1,s=4,sp={203,203,204,204}}
D_trade_dialogue={
	{"hello, let's trade"},
	{"I don't have much, but..."}
}
D_dialogue={
	{"I don't have anything..."},
	{"you'll never reach the bottom"},
	{"antibiotics will leave you\nweak, but they'll help with\ninfection"},
	{"don't drink dirty water"},
	{"panacea is the only way to\ncure infection, but it\ntakes a toll on your body"}
}


player={
	name="player",
	x=3,y=4,
	s=128
}
inv={
	x=0,y=0,p=0,o=98,
	items={}
}
cam={x=0,y=0}
looting=false
dam=0
-------
-- UTIL
-------
function incl(a, b)
	for x in all(a) do
		if(x == b) return true
	end
	return false
end

function akeys(a)
	local keys,i = {},1
	for k,v in pairs(a) do
		keys[i] = k
		i=i+1
	end
	return keys
end

function rnda(a)
	local keys = akeys(a)
	local k = keys[flr(rnd(#keys)) + 1]
	return a[k]
end

function dist(a,b)
	local dx,dy=a.x-b.x,a.y-b.y
	return sqrt(dx*dx+dy*dy)
end

function rnd_dir()
	local d,r={x=0,y=0},rnd()
	if (r<0.25) then 
		d.x=1
	elseif (r<0.5) then
		d.x=-1
	elseif (r<0.75) then
		d.y=1
	else
		d.y=-1
	end
	return d
end
------
-- MAP
------
function los(a,b,retest)
	if dist(a,b)==1 then return true end
	local x1,y1, x2,y2 = a.x,a.y, b.x,b.y
	local dx,dy,sx,sy=abs(x2-x1),abs(y2-y1),sgn(x2-x1),sgn(y2-y1) 
	local err,e2,frst=dx-dy,true
	while not(x1==x2 and y1==y2) do
		if not frst and is_tile(D_flags.sight, x1,y1)==false then
			if retest then
				return false
			end
			return los(b,a,true)
		end
		e2,frst=err+err,false
		if e2>-dy then
			err-=dy
			x1+=sx
		end
		if e2<dx then 
			err+=dx
			y1+=sy
		end
	end
	return true 
end

function is_tile(mode, x,y)
	local tile=mget(x,y)
	if mode == D_flags.sight then
		return not fget(tile, D_flags.wall)
	else
		return fget(tile, mode)
	end
end

function sight(a,pos)
	return dist(a,pos)<=a.sight and los(a,pos)
end

function next_to(a, b)
	local dx,dy = abs(a.x - b.x),abs(a.y - b.y)
	return  (dx == 1 and dy == 0) or (dx == 0 and dy == 1)
end

function setpos(a, b)
	a.x = b.x
	a.y = b.y
end
-------
-- GAME
-------
function init_game()
	for k,v in pairs(D_pstats) do
		player[k] = v
	end
	inv.items={}
end
-----------
-- movement
-----------
function move(o, l, r, u, d)
	local newx,newy,moved = o.x,o.y,false
	
	if(l) moved=true;newx -=1
	if(r) moved=true;newx +=1
	if(u) moved=true;newy -=1
	if(d) moved=true;newy +=1

	if (newx != o.x) and (newy != o.y) then
		if flr(rnd(2)) == 0 then
			newx = o.x
		else
			newy = o.y
		end
	end
	return newx, newy, moved
end

function move_player()
	local newx,newy,moved = move(player, btnp(0), btnp(1), btnp(2), btnp(3))
	if(not moved) return
	
	local a = other_at(player, newx,newy)
	if a then
		if a.friendly then
			talk(a)
		else
			sfx(1)
			attack(player, a)
			if(player.t > 0) player.t = player.t - 1
		end
	elseif curfloor:can_move(newx,newy, true) then
		player.x = mid(0,newx,127)
		player.y = mid(0,newy,63)
	else
		sfx(0)
		moved=false
	end

	local dx,dy = player.x-cam.x, player.y-cam.y
	if dx > 1 then
		inv.o = 0
	elseif dx < -1 then
		inv.o = 98
	end
	if dx > 4 then
		cam.x += 1
	elseif dx < -4 then
		cam.x -= 1
	end
	if dy > 4 then
		cam.y += 1
	elseif dy < -4 then
		cam.y -= 1
	end
	return moved
end

function move_actors()
	for a in all(curfloor.objects) do
		if (a.npc) a.ai(a)
	end
end

function move_items(a, items, w, h)
	local other, newx,newy,moved = a.other, move(a, btnp(0), btnp(1), btnp(2), btnp(3))
	if(not moved) return
	
	if newy<0 and a.p>0 then
		if(not other) a.p -= 1
		newy = h - 1
		sfx(3)
	elseif newy>h-1 and (a.p+1)*w*h<#items then
		if(not other) a.p += 1
		newy = 0
		sfx(2)
	end
	if other ~= nil then
		if newx > w-1 and not other then
			newx = 0
			a.other = true
			sfx(3)
		elseif newx < 0 and other then
			newx = w-1
			a.other = false
			sfx(2)
		end
	end
	if newx>=0 and newx<w and newy>=0 and newy<h then
		a.x = newx
		a.y = newy
		return true
	else
		sfx(0)
	end
end

function move_inv()
	return move_items(inv, inv.items, 4,4)
end

function move_trade(items)
	return move_items(trading, items, 3,4)
end

-----------
-- interaction
-----------
function interact()
	local items,obj=curfloor:items_at(player.x,player.y),curfloor:obj_at(player.x, player.y)
	if items then
		inv.p = 0 -- when looting, always start on the 1st page
		looting=items
		change_state("inv")
	elseif obj then
		if obj.s == 13 then
			change_floor(-1)
		elseif obj.s == 14 then
			change_floor(1)
		elseif obj.s == 70 or obj.s == 71 then
			sleeping = true
		elseif obj.s > 208 then
			add(inv.items, obj)
			del(curfloor.objects, obj)
			tick()
		end
	end
end

function other_at(a, x, y)
	local b = curfloor:actor_at(x,y)
	if a == player then
		if(b != player) return b
	else
		if(b == player) return b
	end
	return false
end

function attack(a, b)
	if b==player then
		hurt(1)
		if(a.inf) player.inf_t += a.inf
	else
		b.hp = b.hp - 1
	end
	if(b.ai == snooze) b.ai = seek_state
	if(b.hp <= 0) kill_actor(b, a.name)
end

function talk(a)
	tb_init(5, a.dialogue)
	if a.items then
		trading = {x=0, y=0, p=0, npc=a, other=false}
	end
	change_state("diag")
end

function kill_actor(a, reason)
	if a == player then
		player.death = reason
		change_state("dead")
	else
		local corpse,n = {s=a.d, items={}}, rnda(D_counts)
		for i=0,n do
			add(corpse.items, random_item())
		end
		del(curfloor.objects, a)
		curfloor:place_obj(corpse, a)
	end
end


function selected_item(a, items, w, h)
	local offset = 0
	if (not a.other) offset = a.p*w*h
	local i = offset + a.y * w + a.x + 1
	if(i<=#items) return items[i]
end

function cull_inv()
	local d={}
	for i in all(inv.items) do
		if(i.used) add(d,i)
	end
	for i in all(d) do
		del(inv.items, i)
	end
end

function hurt(n)
	player.hp -= n
	dam=4
	if(sleeping) sleeping = false
end

-----------
-- drawing
-----------
function draw_map(l)
	camera(cam.x*8-64, cam.y*8-64)

	if l then
		map(0,0, 0,0, 128,64, l)
	else
		map(0,0, 0,0, 128,64)
	end
end

function draw_object(o)
	spr(o.s, o.x*8, o.y*8)
end

function draw_actor_hp(a)
	draw_bar(a.x*8,a.y*8 - 4, 8,4, a.hp,a.mhp, 0, 8)
end

function draw_snore(a)
	spr(D_snore.sp[D_snore.f], a.x*8+4, (a.y-1)*8)
end

function animate(o)
	o.t=(o.t+1)%o.s --tick fwd
	if (o.t==0) o.f=o.f%#o.sp+1
end

function draw_path(path)
	if (path and #path > 1) then
		for pt in all(path) do
			local x,y = pt.x * 8, pt.y * 8
			rect(x, y, x + 8, y + 8, 10)
		end
	end
end


-----------
-- state
-----------
function game_draw()
	cls""
	draw_map()
	for a in all(curfloor.objects) do
		draw_object(a)
	end
	for a in all(curfloor.objects) do
		if a.npc then
			if a.mhp ~= nil and a.hp < a.mhp then
				draw_actor_hp(a)
			end
			if (a.ai == snooze) draw_snore(a)
		end
	end
	draw_object(player) -- (re)draw over everything else
	if(sleeping) draw_snore(player)
	draw_ui()
	drawclock()
end

function game_update()
	trading = nil
	if sleeping then
		tick(true)
	else
		if(move_player()) tick()

		if(btnr(4)) interact()
		if(btnr(5)) change_state("inv")
	end
end

-----------------------------

function inv_draw()
	game_draw()
	if trading then
		tb_draw()
		draw_trade()
	else
		draw_inventory()
	end
end

function inv_update()
	local items = inv.items
	if trading then
		if trading.other then
			items = trading.npc.items
		end
		if(move_trade(items)) tick()
	else
		if(move_inv()) tick()
	end

	if btnr(5) then
		change_state("game")
		cull_inv()
		looting=false
		trading = nil
	end

	if btnh(4) then
		if not trading then
			local o = selected_item(inv, inv.items, 4,4)
			if o then
				del(inv.items, o)
				curfloor:place_obj(o, player)
				sfx(8)
				return
			end
		end
		sfx(0)
	elseif btnr(4) then
		if trading then
			local o = selected_item(trading, items, 3,4)
			if o then
				if trading.other then
					if trading.npc.credit > 0 then
						del(items, o)
						add(inv.items, o)
						trading.npc.credit -= 1
						sfx(7)
						return
					end
				else
					if incl(trading.npc.wants, o.id) then
						del(items, o)
						add(trading.npc.items, o)
						trading.npc.credit += 1
						sfx(6)
						return
					end
				end
			end
			sfx(0)
		elseif looting then
			local i = looting[inv.y * 4 + inv.x + 1]
			curfloor:pickup_loot(i)
			tick()
		else
			local o = selected_item(inv, inv.items, 4,4)
			if o and not o.used then
				local i = D_loot[o.id]
				if(i.hp) player.hp = player.hp + i.hp
				if(i.imm) player.imm = player.imm + i.imm
				if(i.h) player.h = player.h + i.h
				if(i.t) player.t = player.t + i.t
				if(i.e) player.e = player.e + i.e
				if(i.inf) player.inf = player.inf + i.inf
				-- del(inv.items, o)
				i.used=true
				o.used=true
				tick()
			else
				sfx(0)
			end
		end
	end
end
-------
-- TIME
-------
function update_stats()
	if (not curfloor) return

	-- only tick stats every other turn
	if sleeping then
		player.e -= 0.1
		if player.inf > 0 then
			player.imm -= 0.01 -- immunity decreases
			if player.imm > 0 then
				-- infection goes down
				player.inf -= 0.01 
			else
				-- infection gets worse
				player.inf += 0.01
			end
		else
			if player.t < 16 and player.h < 16 then
				player.imm += 0.025
				if player.imm > 12 then
					-- if your immune system is doing well, sleep is good for the body
					player.hp += 0.01
				end
			end
		end
		player.t += 0.05  -- you get thirsty at night
		player.h += 0.025 -- hunger

		-- time to wake up?
		if(player.e <= 0 or player.h>=16 or player.t>=16) sleeping = false
	else
		if curfloor.t % 3 == 0 then
			if player.imm > 0 then -- immunity
				player.imm -= 0.05
				if(player.inf > 0) player.imm -= player.inf / 16 -- immunity decreases faster if infected
			end
			if(player.inf_t > 0) then
				printh("inf:"..player.inf.." t:"..player.inf_t, "log.txt")
				player.inf += (16-player.imm) / 4 --infection
				player.inf_t -= 1
			else
				if (player.inf>0) player.inf -= 0.1
			end
		end
		if curfloor.t % 2 == 0 then
			player.h += 0.1 -- hunger
			if(player.h >= 16) hurt(0.05)
			-- thirst
			if(player.t >= 16) hurt(0.05)
			if(player.e >= 16) then -- exhaustion
				if(player.hp >= 0) hurt(0.1)
			else
				player.e += 0.1
			end
		end
	end

	-- health
	if(player.hp > player.mhp) player.hp = player.mhp
	if(player.hp <= 0) then
		local reason = "fate"
		if player.e >= 16 then
			reason = "exhaustion"
		elseif player.h >= 16 then
			reason = "starvation"
		elseif player.t >= 16 then
			reason = "thirst"
		end
		kill_actor(player, reason)
	end
	
	for k in all({"imm","h","t","e","inf"}) do
		if(player[k] < 0) player[k] = 0
		if(player[k] > 16) player[k] = 16
	end
end

function update_turns()
	for f in all(floors) do
		f.t = f.t+1
	end
end

function tick()
	if sleeping or not curfloor.safe then
		update_stats()
		update_turns()
	end
	move_actors()
	update_clock()
end
---------
-- DUNGEN
---------
do
	local tiles = {
		[0]   = 16,
		[2]   = 17, 
		[8]   = 17, 
		[10]  = 49, 
		[11]  = 49, 
		[16]  = 17, 
		[18]  = 48,
		[22]  = 48, 
		[24]  = 17, 
		[26]  = 17, 
		[27]  = 17, 
		[30]  = 17, 
		[31]  = 17, 
		[64]  = 22, 
		[66]  = 38, 
		[72]  = 20, 
		[74]  = 33, 
		[75]  = 38, 
		[80]  = 22, 
		[82]  = 38, 
		[86]  = 38, 
		[88]  = 20, 
		[90]  = 38, 
		[91]  = 38, 
		[94]  = 38, 
		[95]  = 38, 
		[104] = 33, 
		[106] = 38, 
		[107] = 34, 
		[120] = 33, 
		[122] = 33, 
		[123] = 34, 
		[126] = 18, 
		[127] = 18, 
		[208] = 32, 
		[210] = 35, 
		[214] = 35, 
		[216] = 32, 
		[218] = 32, 
		[219] = 32, 
		[222] = 35, 
		[223] = 19, 
		[248] = 17, 
		[250] = 38, 
		[251] = 50, 
		[254] = 51, 
		[255] = 0
	}
	local patterns= {
		Q = "xxxxooxoo",
		W = "xxxoooooo",
		E = "xxxooxoox",
		A = "xooxooxoo",
		S = "ooooooooo",
		D = "ooxooxoox",
		Z = "xooxooxxx",
		X = "ooooooxxx",
		C = "ooxooxxxx",
		_ = "_________",
		B = "BBBBBBBBB",
		O = "ooooooooo"
	}
	local SCALE=3
	local start_tile = nil
	local bt=0
	floor_n = 0
	floors={}
	
	-----------
	-- objects
	-----------
	
	function random_enemy()
		local e = rnda(D_enemies)
		local a = { s=e.s, d=e.d, name=e.name, npc=true }
		for k,v in pairs(e.stats) do
			a[k] = v
		end
		a.ai = snooze
		
		return a
	end

	function random_npc()
		local n = rnda(D_npcs)
		local a = { s=n, wants={}, credit=0, npc=true, friendly=true }
		if rnd() < 0.5 then
			a.dialogue = rnda(D_trade_dialogue)
			a.items = {}
			for i = 0,1+rnda(D_counts) do
				add(a.wants, random_item_id())
			end
			for i=0,rnda(D_counts) do
				add(a.items, random_item())
			end
		else
			a.dialogue = rnda(D_dialogue)
		end
		a.ai = nothing
		
		return a
	end
	
	function random_item_id()
		return flr(rnd(#D_loot))+1
	end

	function random_item()
		local id = random_item_id()
		return {s=D_loot[id].s, id=id}
	end
	
	function empty_space(room, lev)
		local t,pt = 0, { x=flr(room.x + room.w / 2), y=flr(room.y + room.h / 2)}
		while t < 10 do
			pt.x += flr(rnd(4)) - 2
			pt.y += flr(rnd(4)) - 2
			if(not isw(tile(pt.x,pt.y,lev)) and not lev:any_at(pt.x, pt.y)) return pt
			t+=1
		end
		return nil
	end

	function place_obj(a, room, lev)
		if(not room) return

		local pt = empty_space(room, lev)
		if(not pt) return nil
		lev:place_obj(a, pt)
		return a
	end
	
	function fillroom(lev, room)
		if(rnd()<0.1) return

		local n = 1
		if(room.w/3 > n) n = room.w/3
		if(room.h/3 > n) n = room.h/3
		for i=1,n do
			local r = rnd()
			if r < 0.5 then
				-- scenery
				local obj = { s=64+flr(rnd(14)), items={} }
				if incl({64, 65, 66}, obj.s) then
					local n = D_counts[flr(rnd(8)) + 1]
					for i=0,n do
						add(obj.items, random_item())
					end
				end
				place_obj(obj, room, lev)
			elseif r < 0.8 then
				-- NPC
				if lev.safe or rnd()<0.1 then
					place_obj(random_npc(), room, lev)
				else
					place_obj(random_enemy(), room, lev)
				end
			else
				-- item
				place_obj(random_item(), room, lev)
			end
		end
	end
	
	-----------
	-- dungeon
	-----------
	function init_dungeon()
		for y=0,31 do
			for x=0,127 do
				mset(x,y,0)
			end
		end
		floors={}
		floor_n = 1
		change_state("build")
	end

	function change_floor(n)
		floor_n += n
		if (n>0) start_tile = 13
		if (n<0) start_tile = 14

		local lev = floors[floor_n]
		if lev then
			restore_dungeon(lev)
		else
			change_state("build")
		end
	end
	
	-- function log_map(lev)
	-- 	for y=0,lev.grid.h-1 do
	-- 		local s = ""
	-- 		for x=0,lev.grid.w-1 do
	-- 			local t,obj = lev.grid[x][y], lev:obj_at(x,y)
	-- 			if obj then
	-- 				if (obj.s == 13) t = "<"
	-- 				if (obj.s == 14) t = ">"
	-- 			end
	-- 			s = s..t
	-- 		end
	-- 		printh(s, "log.txt")
	-- 	end
	-- end

	function restore_dungeon(lev)
		build_map(lev)

		for o in all(lev.objects) do
			if o.s == start_tile then
				setpos(player, o)
			end
		end

		setpos(cam, player)

		curfloor = lev
	end
	
	function grid(width,height)
		local g = {w=width,h=height}
		for x = 0,width-1 do
			g[x] = {}
			for y = 0,height-1 do
				g[x][y] = "_"
			end
		end
		return g
	end

	function gset(g,x,y,p)
		for yi = 0,SCALE-1 do
			for xi = 0,SCALE-1 do
				local index = 1 + xi + yi*SCALE
				g[x*SCALE+xi][y*SCALE+yi] = sub(p,index,index)
			end
		end
	end

	function explode_grid(g, n)
		local ng = grid(g.w*n,g.h*n)
		for x = 0,g.w-1 do
			for y = 0,g.h-1 do
				gset(ng,x,y, patterns[g[x][y]])
			end
		end
		return ng
	end

	function explode_features(lev, n)
		local nr,nd = {},{}
		for r in all(lev.rooms) do
			add(nr, {x=r.x*n, y=r.y*n, w=r.w*n, h=r.h*n})
		end
		for d in all(lev.doors) do
			add(nd, {x=d.x*n+1, y=d.y*n+1, d=d.d, w=d.w})
		end
		return nr,nd
	end

	function place_doors(lev)
		local grid = lev.grid
		for door in all(lev.doors) do
			local d,x,y = door.d,door.x,door.y
			if not door.wide then
				if (d==1) grid[x][y-1] = "o"; grid[x][y-2] = "o"
				if (d==3) grid[x][y+1] = "o"; grid[x][y+2] = "o"
				if (d==4) grid[x-1][y] = "o"; grid[x-2][y] = "o"
				if (d==2) grid[x+1][y] = "o"; grid[x+2][y] = "o"
			end
		end
	end
	
	function build_map(r)
		for y=0,r.height-1 do
			for x=0,r.width-1 do
				sprite = tile_sprite(x,y,r)
				if (r.safe and sprite ~= 7 and sprite ~= 0) sprite += 8
				mset(x,y,sprite)
			end
		end
	end

	function isw(t)
		return t== "x" or t == "_" or t == "B"
	end

	function tile_sprite(x, y, r)
		local this= tile(x,y,r)
		if(this=="o") return 7
		if(this=="_") return 0
		if(this=="B") return 2
		if(this=="D") return 1
		local n,t=0,{
			ul=isw(tile(x-1,y-1,r)),
			u =isw(tile(x,y-1,r)),
			ur=isw(tile(x+1,y-1,r)),
			l =isw(tile(x-1,y,r)),
			r =isw(tile(x+1,y,r)),
			dl=isw(tile(x-1,y+1,r)),
			d =isw(tile(x,y+1,r)),
			dr=isw(tile(x+1,y+1,r))
		}
		if (t.u and t.l and t.ul) n += 0x01
		if (t.u)  n += 0x02
		if (t.u and t.r and t.ur) n += 0x04
		if (t.l)  n += 0x08
		if (t.r)  n += 0x10
		if (t.d and t.l and t.dl) n += 0x20
		if (t.d)  n += 0x40
		if (t.d and t.r and t.dr) n += 0x80
		
		t = tiles[n]
		if(t) return t

		return 8
	end
	
	function tile(x, y, r)
		if x<0 or y<0 or x>=r.width or y>=r.height then return "x" end
		return r.grid[x][y]
	end

	function contains(area, p)
		for pt in all(area) do
			if(p.x == pt.x and p.y == pt.y) return true
		end
		return false
	end

	function seal_grid(g)
		for x = 0,g.w-1 do
			for y = 0,g.h-1 do
				if x == 0 or x == g.w-1 or y == 0 or y == g.h-1 then
					g[x][y] = "x"
				end
				local t = g[x][y]
				if t == "_" or t == "B" then
					for xi=-1,1 do
						for yi=-1,1 do
							t = g[x+xi][y+yi]
							if((y~=0 or x~=0) and (t == "o")) g[x][y]="x"
						end
					end
				end
			end
		end
	end

	function finish_level(m)
		local lev = level:new {
			f=m.f, 
			width=m.width*SCALE, 
			height=m.height*SCALE, 
			t=0, 
			wake_t=25, 
			objects={},
			safe=(m.f % 5 == 0),
			-- safe=true,
			grid=explode_grid(m.grid, SCALE),
		}
		lev.rooms,lev.doors = explode_features(m, SCALE)
		place_doors(lev)
		seal_grid(lev.grid)
		
		local upstairs,downstairs = nil,nil
		downstairs = place_obj({s=14}, rnda(lev.rooms), lev)
		if #floors > 0 then
			upstairs = place_obj({s=13}, rnda(lev.rooms), lev)
		end
	
		place_obj(player, rnda(lev.rooms), lev)

		for room in all(lev.rooms) do
			fillroom(lev, room)
		end

		restore_dungeon(lev)
		local start = player
		if (#floors > 0) start = upstairs
		local path = find_path(lev, start, downstairs, manhattan_distance, map_neighbors)
		if not path or #path < 5 then
			lev,m = nil,nil
			return false
		else
			floors[lev.f]=lev

			-- log_map(lev)
			return true
		end
	end

	function build_update()
		if (not CURRENT_LEVEL) then
			bt=0
			CURRENT_LEVEL = new_level(random_params(), floor_n)
		end

		bt+=1
		for i=1,5 do
			push_rooms(CURRENT_LEVEL)
		end
		if (bt>200 or #CURRENT_LEVEL.new_rooms <= 0) then
			local new_level = CURRENT_LEVEL
			CURRENT_LEVEL = nil
			if finish_level(new_level) then
				change_state("game")
			else
				bt = 0
			end
		end
	end
	
	function build_draw()
		if (bt==1) cls(0)
		if (not CURRENT_LEVEL) return
		-- draw new rooms
		for r in all (CURRENT_LEVEL.new_rooms) do
			rect(8+r.x*8,24+r.y*8, 8+(r.x+r.w)*8-1,24+(r.y+r.h)*8-1, 2)
		end
	end

end
------------------
-- DUNGEON BUILDER
------------------
function random_params()
	return {
		wide_doors=rnd(),
		connectedness=rnd(),
		big_rooms=rnd(),
		block_amnt=rnd(0.5),
		block_size=rnd(0.5)
	}
end

function new_level(p, f)
	local lev = level:new { f=f, width=12, height=6,new_rooms={},rooms={},doors={} }
	lev.params={
		wide_doors=p.wide_doors,
		connectedness=p.connectedness,
		big_rooms=p.big_rooms,
		block_amnt=p.block_amnt,
		block_size=p.block_size
	}
	init_level(lev)
	generate(lev,8+rnd(16))

	return lev
end

function init_level(lev)
	lev.grid = grid(lev.width,lev.height)

	-- add blocking tiles
	for i=1,32 do
		if (rnd()<lev.params.block_amnt) then
			local x,y=flr(2+rnd(lev.width-4)), flr(2+rnd(lev.height-4))
			lev.grid[x][y] = "B"
			if (rnd()<lev.params.block_size) then
				lev.grid[x+1][y] = "B"
				lev.grid[x-1][y] = "B"
			end
			if (rnd()<lev.params.block_size) then
				lev.grid[x][y-1] = "B"
				lev.grid[x][y+1] = "B"
			end 
		end
	end
	-- initial room
	add_room(lev,6,3,1,1)
end

function generate(lev,amnt)
	-- add the rooms
	for i=1,amnt do
		spawn_room(lev)
	end 
end

-- spawns a room in the middle
function spawn_room(lev)
	if (rnd()<lev.params.big_rooms) then
		add_room(lev,6,3,2+flr(rnd(2)),2+flr(rnd(2)))
	else
		add_room(lev,6,3,1,1)
	end
end

function add_room(lev,x,y,w,h)
	local r={x=x, y=y, w=w, h=h}
	add(lev.new_rooms,r)
end

-- returns the room at position or nil
function get_room_at(lev, x,y)
	for r in all(lev.rooms) do
		if (x>=r.x and y>=r.y and x<r.x+r.w and y<r.y+r.h) return r
	end
	
	return nil
end

-- removes a room from the map
function remove_room(lev,r)
	for x=r.x,r.x+r.w-1 do
		for y=r.y,r.y+r.h-1 do
			lev.grid[x][y] = "_"
		end
	end
end

-- tries to place room r on the map returns true if successful
function place_room(lev,r)
	-- 1x1 room
	if (r.w==1 and r.h==1) then
		if lev.grid[r.x][r.y] == "_" then
			lev.grid[r.x][r.y] = "O"
			add(lev.rooms,r)
			del(lev.new_rooms,r)
			return true
		end
	else
		-- bigger room
		local fits=true
		for x=0,r.w-1 do
			for y=0,r.h-1 do
				local rx,ry = r.x+x,r.y+y
				if (rx>=lev.width or ry>=lev.height or lev.grid[rx][ry] ~="_") fits=false
			end
		end
		
		local pairs={}
		if (fits) then
			local rx,ry = r.x,r.y
			for x=rx,rx+r.w-1 do
				for y=ry,ry+r.h-1 do
					lev.grid[x][y] = "S"
					add(pairs,{x=x,y=y})
				end
			end
			for x=rx,rx+r.w-1 do
				lev.grid[x][ry] = "W"
			end
			for x=rx,rx+r.w-1 do
				lev.grid[x][ry+r.h-1] = "X"
			end
			for y=ry,ry+r.h-1 do
				lev.grid[rx][y] = "A"
			end
			for y=ry,ry+r.h-1 do
				lev.grid[rx+r.w-1][y] = "D"
			end
			
			lev.grid[rx][ry] = "Q"
			lev.grid[rx+r.w-1][ry] = "E"
			lev.grid[rx][ry+r.h-1] = "Z"
			lev.grid[rx+r.w-1][ry+r.h-1] = "C"
			
			add(lev.rooms,r)
			del(lev.new_rooms,r)
			return true
		end
	end
	
	return false
end

-- push all non set rooms in random directions to see if they can be placed
function push_rooms(lev)
	if (not lev) return
	for r in all(lev.new_rooms) do
		local rx,ry = r.x,r.y
		if (place_room(lev,r)) then
			-- add doors
			-- get candidates
			local nds={}
			for x=rx,rx+r.w-1 do
				-- top
				if (get_room_at(lev,x,ry-1)~=nil) add(nds,make_door(lev,x,ry,1))
				-- btm
				if (get_room_at(lev,x,ry+r.h)~=nil) add(nds,make_door(lev,x,ry+r.h-1,3))
			end
			for y=ry,ry+r.h-1 do
				-- left
				if (get_room_at(lev,rx-1,y)~=nil) add(nds,make_door(lev,rx,y,4))
				-- right
				if (get_room_at(lev,rx+r.w,y)~=nil) add(nds,make_door(lev,rx+r.w-1,y,2))
			end
			
			if (#nds>0) then    
				-- add one door
				local id=flr(rnd(#nds))+1
				add(lev.doors,nds[id])
				del(nds,nds[id])
				
				-- add some doors
				for d in all(nds) do
					if (rnd()<lev.params.connectedness) add(lev.doors,d)  
				end  
			else
				if (r.h>1 and r.w>1) then
					-- no doors, kill room
					remove_room(lev,r)
					del(lev.rooms,r)
				end
			end 
		else
			-- move room
			r.d=rnd_dir()
			local nx,ny = rx+r.d.x,ry+r.d.y
			if (nx>=0 and nx<lev.width and ny>=0 and ny<lev.height) and lev.grid[nx][ny] ~="B" then
				r.x=nx
				r.y=ny
			end
		end
	end
end

-- creates a door with a direction
function make_door(lev,x,y,d)
	return {x=x,y=y,d=d,wide=(rnd()<lev.params.wide_doors)}
end
-----
-- A*
-----

function find_path(lev, start, goal, estimate_fn, neighbor_fn)
	if (start == nil or goal == nil) return
	local shortest = {
		last = start,
		cost_from_start = 0,
		cost_to_goal = estimate_fn(start, goal)
	}
	local best_table = {}
	
	best_table[node_to_id(start)] = shortest
	local frontier = { shortest }
	local frontier_len = 1
	local goal_id = node_to_id(goal)
	local max_number = 32767.99
	
	while frontier_len > 0 do
		local cost, index_of_min = max_number
		for i = 1, frontier_len do
			local temp = frontier[i].cost_from_start + frontier[i].cost_to_goal
			if (temp <= cost) index_of_min, cost = i, temp
		end
		
		shortest = frontier[index_of_min]
		frontier[index_of_min] = frontier[frontier_len]
		shortest.dead = true
		frontier_len -= 1
		
		local p = shortest.last
		
		if node_to_id(p) == goal_id then
			p = { goal }
			while shortest.prev do
				shortest = best_table[node_to_id(shortest.prev)]
				add(p, shortest.last)
			end
			return p
		end
		
		for n in all(neighbor_fn(lev, p)) do
			local id = node_to_id(n)
			local old_best = best_table[id]
			local new_cost_from_start = shortest.cost_from_start + 1
			
			if not old_best then
				old_best = {
					last = n,
					cost_from_start = max_number,
					cost_to_goal = estimate_fn(n, goal)
				}
				frontier_len += 1
				frontier[frontier_len] = old_best
				best_table[id] = old_best
			end
			
			if not old_best.dead and old_best.cost_from_start > new_cost_from_start then
				old_best.cost_from_start = new_cost_from_start
				old_best.prev = p
			end
		end
	end
end

function get_neighbors(node, blocked)
	local neighbors = {}
	if (not blocked.up) add(neighbors, { x = node.x, y = node.y - 1})
	if (not blocked.down) add(neighbors, { x = node.x, y = node.y + 1})
	if (not blocked.left) add(neighbors, { x = node.x - 1, y = node.y})
	if (not blocked.right) add(neighbors, { x = node.x + 1, y = node.y})
	if (not blocked.up_left) add(neighbors, { x = node.x - 1, y = node.y - 1})
	if (not blocked.up_right) add(neighbors, { x = node.x + 1, y = node.y - 1})
	if (not blocked.down_left) add(neighbors, { x = node.x - 1, y = node.y + 1})
	if (not blocked.down_right) add(neighbors, { x = node.x + 1, y = node.y + 1})
	return neighbors
end
  
function map_neighbors(lev, node)
	local blocked = {
		up = not lev:can_move(node.x, node.y - 1),
		down = not lev:can_move(node.x, node.y + 1),
		left = not lev:can_move(node.x - 1, node.y),
		right = not lev:can_move(node.x + 1, node.y)
	}
	if ((blocked.up and blocked.left) or not lev:can_move(node.x - 1, node.y - 1)) blocked.up_left = true
	if ((blocked.up and blocked.right) or not lev:can_move(node.x + 1, node.y - 1)) blocked.up_right = true
	if ((blocked.down and blocked.left) or not lev:can_move(node.x - 1, node.y + 1)) blocked.down_left = true
	if ((blocked.down and blocked.right) or not lev:can_move(node.x + 1, node.y + 1)) blocked.down_right = true
	
	return get_neighbors(node, blocked)
end

function manhattan_distance(a, b)
	return abs(a.x - b.x) + abs(a.y - b.y)
end

function node_to_id(node)
	return shl(node.y, 8) + node.x
end
  
-----
-- UI
-----

function draw_bar(x,y, w,h, amt,m, delta, c)
	local uic=7
	if(dam==4)uic=8
	if(dam==3)uic=9
	if(dam==2)uic=7
	
	rectfill(x, y, x+w, y+h, 0)
	rect    (x, y, x+w, y+h, uic)
	x+=1 y+=1 w-=2 h-=2
	local f,d = flr(w * amt/m),-flr(-w * delta/m)
	local x0,x1,x2 = x, min(x+f, x+f+d), max(x+f,x+f+d)
	x1 = mid(x, x1, x+w)
	x2 = mid(x, x2, x+w)
	if(x1>x0) rectfill(x0, y, x1, y+h, c)
	if(x2>x1) then
		if delta>0 then
			rectfill(x1, y, x2, y+h, 10)
		else
			rectfill(x1, y, x2, y+h, 2)
		end
	end
		
end

function checkerfill()
	fillp(0b0101101001011010.1)
end

function stat_bar(s, x,y, w,h, amt, delta, menace)
	spr(s, x, y)
	local c = 6
	if menace then
		if (amt<4) c=12
		if (amt>10) c=8
	else
		if (amt<4) c=8
		if (amt>10) c=12
	end
	draw_bar(x+8,y, w,h, amt,16, delta, c)
end

function draw_ui()
	local x,y,w = inv.o,24, 24
	camera(0, 0)
	checkerfill()
	rectfill(x+3, 6, x+w+5, y+58, 1)
	fillp()
	rectfill(x-1, 2, x+w+1, y+54, 1)
	
	local d = {hp=0, imm=0, h=0, t=0, e=0, inf=0}
	if gamestate=="inv" and not looting then
		local o = selected_item(inv, inv.items, 4,4)
		if o and not o.used then
			local i = D_loot[o.id]
			for k in all({"hp","imm","h","t","e","inf"}) do
				if(i[k]) d[k] = i[k]
			end
		end
	end

	stat_bar(196, x,y+ 3, 16,6, player.hp, d.hp, false) -- health
	stat_bar(197, x,y+11, 16,6, player.imm, d.imm, false) -- immunity
	stat_bar(198, x,y+23, 16,6, player.h, d.h, true) -- hunger
	stat_bar(199, x,y+31, 16,6, player.t, d.t, true) -- thirst
	stat_bar(200, x,y+39, 16,6, player.e, d.e, true) -- exhaustion
	stat_bar(201, x,y+47, 16,6, player.inf, d.inf, true) -- infection
end

function mask_item(o, items)
	if trading then
		if items == inv.items then
			return not incl(trading.npc.wants, o.id)
		else
			return trading.npc.credit <= 0
		end
	end
	return false
end

function draw_items(items, offset, xpos, ypos, w, h)
	-- draw background
	checkerfill()
	rectfill(xpos+2, ypos+2, xpos+12*w, ypos+12*h, 1)
	fillp()
	rectfill(xpos-2, ypos-2, xpos-2+12*w, ypos-2+12*h, 1)

	local x,y = 0,0
	for i = 1,w*h do
		if offset+i < #items+1 then
			if x > w-1 then
				x = 0
				y = y+1
			end
			local o=items[offset+i]
			if not o.used then
				spr(o.s, xpos+x*12, ypos+y*12)
				if(mask_item(o, items)) spr(3, xpos+x*12, ypos+y*12)
			end
			x = x+1
		end
	end
end

function draw_inventory()
	local items = inv.items
	if (looting) items=looting
	draw_items(items, inv.p*16, 40,40, 4,4)
	spr(202, 40+inv.x*12, 40+inv.y*12) -- highlight
end

function draw_trade()
	-- player
	draw_items(inv.items, trading.p*12, 4,12, 3,4)
	-- merchant
	draw_items(trading.npc.items, 0, 44,20, 3,4)
	-- highlight
	if trading.other then
		spr(202, 44+trading.x*12, 20+trading.y*12)
	else
		spr(202, 4+trading.x*12, 12+trading.y*12)
	end
end
--------
-- TITLE
--------
function title_draw()
	cls""
	-- mouthwatering appetizing tasty savory yummy
	-- catacomb sepulcher labyrinth tomb
	rectfill(0,20,128,40,1)
	print("\^w\^tMtopiya", 32,26, 7,5)
	print("(—) begin", 46,104, 12,5)
	-- dead_draw()
end
function title_update()
	if btnp(5) then
		init_game()
		init_dungeon()
	end
end

function dead_update()
	if btnp(5) or btnp(6) then
		change_state("title")
	end
end

function dead_draw()
	cls""
	local skull = "    222       11111     1111111   111111111 1111111111111  111  111   111   111111 111111111   1111 111111111   1111111    1 131 1  "

	for y=1,12 do
		for x=0,10 do
			local index = 1 + x + y*11
			local n = tonum(sub(skull, index,index))
			if (n) spr(9 + n, 16+x*8, y*8)
		end
	end
	print("killed by "..player.death, 24, 112, 7)
	print("made it to floor "..floor_n, 24, 120, 7)
end

-----
-- TB
-----
function tb_init(voice,string)
	reading=true
	tb={
		str=string,
		voice=voice,
		i=1,
		cur=0,
		char=0,
		x=0,
		y=106,
		w=127,
		h=21,
		col1=0,
		col2=7,
		col3=7,
	}
end

function tb_update()
	if tb.char<#tb.str[tb.i] then
		tb.cur+=0.5
		if tb.cur>0.9 then
			tb.char+=1
			tb.cur=0
			if (ord(tb.str[tb.i],tb.char)!=32) sfx(tb.voice)
		end
		if (btnr(4) or btnr(5)) tb.char=#tb.str[tb.i]
	elseif trading and btnr(4) then
		change_state("inv")
	elseif btnr(5) then
		if #tb.str>tb.i then
			tb.i+=1
			tb.cur=0
			tb.char=0
		else
			reading=false
		end
	end
end

function tb_draw()
	if reading then
		rectfill(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col1)
		rect(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col2)
		print(sub(tb.str[tb.i],1,tb.char),tb.x+2,tb.y+2,tb.col3)
	end
end

--------

function diag_draw()
	game_draw()
	tb_draw()
end

function diag_update()
	tb_update()
	if not reading then
		change_state("game")
	end
end
-------
-- MAIN
-------

do
	local update_functions={
		["title"]=title_update,
		["game"]=game_update,
		["inv"]=inv_update,
		["dead"]=dead_update,
		["diag"]=diag_update,
		["build"]=build_update
	}
	local draw_functions={
		["title"]=title_draw,
		["game"]=game_draw,
		["inv"]=inv_draw,
		["dead"]=dead_draw,
		["diag"]=diag_draw,
		["build"]=build_draw
	}
	function change_state( state )
		gamestate=state
		innerupdate=update_functions[gamestate]
		_draw=draw_functions[gamestate]
	end
	function _init()
		btn_init()
		poke(0x5600,unpack(split"5,8,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,15,15,15,15,0,0,0,0,0,15,15,15,0,0,0,0,0,15,9,15,0,0,0,0,0,9,6,9,0,0,0,0,0,9,0,9,0,0,0,0,0,9,9,9,0,0,0,0,8,14,15,14,8,0,0,0,1,7,15,7,1,0,0,14,6,6,6,0,0,0,0,0,0,12,12,12,14,0,0,10,4,14,4,14,4,0,0,0,0,0,12,0,0,0,0,0,0,0,0,6,3,0,0,0,0,0,6,6,0,0,0,0,10,10,0,0,0,0,0,0,4,10,4,0,0,0,0,0,0,0,0,0,0,0,0,4,4,4,4,0,4,0,0,0,10,10,0,0,0,0,0,10,15,10,15,10,0,0,0,15,5,15,12,15,0,0,0,9,4,6,2,9,0,0,0,6,6,3,5,14,0,0,0,12,12,0,0,0,0,0,0,6,3,3,3,6,0,0,0,6,12,12,12,6,0,0,0,9,6,6,9,0,0,0,0,0,2,7,2,0,0,0,0,0,0,0,0,6,3,0,0,0,0,0,14,0,0,0,0,0,0,0,6,6,0,0,0,8,4,6,2,1,0,0,0,15,11,11,11,15,0,0,0,7,6,6,6,6,0,0,0,15,12,15,3,15,0,0,0,15,12,15,12,15,0,0,0,13,13,15,12,12,0,0,0,15,3,15,12,15,0,0,0,15,3,15,11,15,0,0,0,15,12,12,12,12,0,0,0,15,11,15,11,15,0,0,0,15,13,15,12,15,0,0,0,6,6,0,6,6,0,0,0,6,6,0,6,6,3,0,0,8,12,6,12,8,0,0,0,0,0,14,0,14,0,0,0,1,3,6,3,1,0,0,0,15,8,14,0,2,0,0,0,15,13,13,1,15,0,0,0,0,0,6,5,6,0,0,0,1,1,7,5,7,0,0,0,0,0,7,1,7,0,0,0,4,4,7,5,7,0,0,0,0,0,3,3,7,0,0,0,6,2,7,2,2,0,0,0,0,0,7,5,7,4,7,0,1,1,7,5,5,0,0,0,2,0,3,2,2,0,0,0,2,0,2,2,2,3,0,0,1,1,5,3,5,0,0,0,1,1,1,1,3,0,0,0,9,9,15,11,1,0,0,0,0,0,3,5,5,0,0,0,0,0,7,5,7,0,0,0,0,0,7,5,7,1,1,0,0,0,7,5,7,4,4,0,0,0,7,1,1,0,0,0,0,0,6,2,3,0,0,0,1,1,3,1,7,0,0,0,0,0,5,5,6,0,0,0,0,0,5,5,2,0,0,0,0,0,9,11,7,0,0,0,0,0,5,2,5,0,0,0,0,0,5,5,7,4,7,0,0,0,3,2,6,0,0,0,7,1,1,1,7,0,0,0,1,2,2,2,4,0,0,0,7,4,4,4,7,0,0,0,2,5,0,0,0,0,0,0,0,0,0,0,15,0,0,0,6,12,0,0,0,0,0,0,15,9,15,9,9,0,0,0,7,9,7,9,7,0,0,0,15,1,1,1,15,0,0,0,7,9,9,9,7,0,0,0,15,1,7,1,15,0,0,0,15,1,7,1,1,0,0,0,15,1,13,9,15,0,0,0,9,9,15,9,9,0,0,0,7,2,2,2,7,0,0,0,8,8,8,9,15,0,0,0,9,5,3,5,9,0,0,0,1,1,1,1,15,0,0,0,15,15,9,9,9,0,0,0,9,11,15,13,9,0,0,0,15,9,9,9,15,0,0,0,15,9,15,1,1,0,0,0,6,9,9,13,14,0,0,0,7,9,7,9,9,0,0,0,15,1,15,8,15,0,0,0,7,2,2,2,2,0,0,0,9,9,9,9,15,0,0,0,5,5,5,2,2,0,0,0,9,9,9,15,15,0,0,0,9,6,6,9,9,0,0,0,9,9,15,2,2,0,0,0,15,12,6,3,15,0,0,0,12,2,3,2,12,0,0,0,2,2,0,2,2,0,0,0,3,4,12,4,3,0,0,0,0,10,15,5,0,0,0,0,0,0,0,0,0,0,0,0,127,127,127,127,127,127,127,0,85,42,85,42,85,42,85,0,65,99,127,93,93,119,62,0,62,99,99,119,62,65,62,0,17,68,17,68,17,68,17,0,4,12,124,62,31,24,16,0,28,38,95,95,127,62,28,0,34,119,127,127,62,28,8,0,42,28,54,119,54,28,42,0,28,28,62,93,28,20,20,0,8,28,62,127,62,42,58,0,62,103,99,103,62,65,62,0,62,127,93,93,127,99,62,0,24,120,8,8,8,15,7,0,62,99,107,99,62,65,62,0,8,20,42,93,42,20,8,0,0,0,0,85,0,0,0,0,62,115,99,115,62,65,62,0,8,28,127,28,54,34,0,0,127,34,20,8,20,34,127,0,62,119,99,99,62,65,62,0,0,10,4,0,80,32,0,0,17,42,68,0,17,42,68,0,62,107,119,107,62,65,62,0,127,0,127,0,127,0,127,0,85,85,85,85,85,85,85,0"))
		change_state("title")
	end
	function _update()
		btn_update()
		if(innerupdate) innerupdate()

		animate(D_snore)
		if (dam==4) sfx(4)
		if (dam>0) dam-=1

		btn_lateupdate()
	end
end
-----
-- AI
-----
function bmove(a, d)
	if next_to(a, player) then
		attack(a, player)
		return
	end
	local newx,newy,moved = move(a, d==0, d==1, d==2, d==3)
	if(not moved) return
	
	if curfloor:can_move(newx,newy, true) then
		a.x = mid(0,newx,127)
		a.y = mid(0,newy,63)
	end
end

function step_path(start, goal)
	local path = find_path(curfloor, start, goal, manhattan_distance, map_neighbors)
	if(not path or #path < 2) return
	return path[#path - 1]
end

function snooze(a)
	if curfloor.t > curfloor.wake_t then
		a.ai = move_state
	end
end

function nothing(a)
	-- do nothing
end

function move_state(a)
	d = flr(rnd(4))
	bmove(a, d)
	if sight(a, player) then
		a.ai = seek_state
	end
end

function seek_state(a)
	if next_to(a, player) then
		attack(a, player)
		return
	end
	
	local step = step_path(a, player)
	if(not step) return
	
	local newx,newy,moved = move(a, step.x<a.x, step.x>a.x, step.y<a.y, step.y>a.y)
	if(not moved) return
	
	if curfloor:can_move(newx,newy, true) then
		a.x = mid(0,newx,127)
		a.y = mid(0,newy,63)
	end
end
  
--------
-- CLOCK
--------
do
	local s,m,cy,rad = 0,0,12,12

	function update_clock()
		s = curfloor.t
		m = curfloor.wake_t
		s = s % 60
	end

	function drawclock()
		for i=0,59 do
			drawpx(rad-1,i/60,7,1)
		end 
		for i=0,11 do
			drawpx(rad-2,i/12,7,1)
			drawpx(rad-3,i/12,7,1)
		end
		for i=-2,rad-1 do
			drawpx(i,m/60,6,1)
		end
		for i=-2,rad-1 do
			drawpx(i,s/60,8,1)
		end
	end

	function drawpx(r,angle,c,b)
		local x,y=inv.o+rad+r*cos(1.25-angle), cy+r*sin(1.25-angle)
		pset(x,y,c)
		if b==2 then
			pset(x-1,y-1,c)
			pset(x,y-1,c)
			pset(x+1,y-1,c)
			pset(x-1,y,c)
			pset(x+1,y,c)
			pset(x-1,y+1,c)
			pset(x,y+1,c)
			pset(x+1,y+1,c)
		end
	end
end
--------
-- LEVEL
--------
level = {}
level.__index = level
function level:new(props)
	local lev = {}
	for k,v in pairs(props) do
		lev[k] = v
	end
	setmetatable(lev, level)
	return lev
end

function level:all_at(x,y)
	local objs = {}
	for obj in all(self.objects) do
		if(obj.x == x and obj.y == y) add(objs, obj)
	end
	return objs
end

function level:actor_at(x,y)
	if(player.x == x and player.y == y) return player
	for a in all(self:all_at(x,y)) do
		if(a.npc == true) return a
	end
end

function level:obj_at(x, y)
	for a in all(self:all_at(x,y)) do
		if(a ~= player and not a.npc) return a
	end
end

function level:any_at(x,y)
	local a = self:all_at(x,y)
	if(#a > 0) return a[1]
end

function level:can_move(x,y, include_actors)
	if (x < 0 or y < 0 or x > self.width or y > self.height) return false
	if(is_tile(D_flags.wall, x,y)) return false
	local a = self:actor_at(x,y)
	if (not a) return true
	if include_actors then
		return false
	else
		return not a.friendly
	end
end

function level:items_at(x,y)
	local items={}
	for obj in all(self:all_at(x,y)) do
		if obj.items then
			for i in all(obj.items) do
				add(items, i)
			end
		end
	end
	if(#items>0) return items
end

function level:place_obj(obj, pt)
	setpos(obj, pt)
	add(self.objects, obj)
end

function level:pickup_loot(i)
	for obj in all(self:all_at(player.x,player.y)) do
		if obj.items and incl(obj.items, i) then
			del(obj.items, i)
			del(looting, i)
			add(inv.items, i)
			return
		end
	end
end
__gfx__
00000000000ff0001100000001001001dddd555d55555555555111151111555522222222111111110000005500000000000000550000006d6666666600000000
000000000ff44ff00000000110010010dddddddd5111511151111115111155552eeeeee21111111150000000000000005000000000006d6d6dddddd600000000
00700700f444444f00001100001001005d555d555111111111111115111155552eeeeee211111111005000000000000000500000006d6d6d6555555600000000
000770004444444400110000010010015d555d555111111111111115555511112eeeeee2111111110005050000000000000505056d6d6d6d611116d600000000
00077000664444441100000010010010dddddddd5511111111111155555511112eeeeee2111111110000005500005055000000006d6d6d556116d6d611101110
00700700444444640000001100100100555ddddd5111111111111115555511112eeeeee2111111115500000055000000000000006d6d555566d6d6d666656665
00000000664444440000010001001001555d555d5111111111111115555511112eeeeee2111111110005000000050000000000006d55555566d6d6d666656665
00000000444444440011000010010010555d555d5111111111111115111155552222222211111111000055000000550000000000555555556666666666656665
04444440444444440000444444440000444411000011144444444444000000000666666066666666000066666666000066661100001116666666666611111111
4ffffff44ffffff400004ff54ff400004ff122100121fff44ffffff4000000006ffffff66ffffff600006ff56ff600006ff1dd1001d1fff66ffffff665666566
4ffffff4244444420000455445540000244415510155144245444454000000006ffffff6d666666d0000655665560000d66615510155166d6566665665666566
244444420222222000004ff44ff4000002221111111122204f4224f400000000d666666d0dddddd000006ff66ff600000ddd11111111ddd06f6dd6f665666566
022222202555555200004ff44ff4000025555512221555524f4554f4000000000dddddd0d555555d00006ff66ff60000d555551ddd15555d6f6556f611111111
255555520211120000004ff44ff4000002111111111112004f4114f400000000d555555d0d111d0000006ff66ff600000d11111111111d006f6116f666656665
02111200255155520000455445540000255155511551555245415454000000000d111d00d551555d0000655665560000d55155511551555d6561565666656665
055155501111111100004ff44ff4000011111111111111114f4114f400000000055155501111111100006ff66ff6000011111111111111116f6116f666656665
444444444444444400004ff44ff4000000000000000000004f4004f400000000666666666666666600006ff66ff6000000000000000000006f6006f655515551
4ffffff44ffffff400004ff44ff4000000000005100100004f4004f4000000006ffffff66ffffff600006ff66ff6000000000005100100006f6006f611111111
44444442244444440000455445540000000050541511000045400454000000006666666dd6666666000065566556000000005056151100006560065651555155
4ff4222002224ff400004ff44ff40000000044f441f400004f4004f4000000006ff6ddd00ddd6ff600006ff66ff60000000066f661f600006f6006f611111111
4ff4555225554ff400004ff44ff4000000004ff44ff400004f4004f4000000006ff6555dd5556ff600006ff66ff6000000006ff66ff600006f6006f655515551
4ff4120002114ff400004ff44ff4000000004ff44ff400004f4004f4000000006ff61d000d116ff600006ff66ff6000000006ff66ff600006f6006f611111111
45545552255145540000455445540000000045544554000045400454000000006556555dd5516556000065566556000000006556655600006560065651555155
4ff4111111114ff400004ff44ff4000000004ff44ff400004f4004f4000000006ff6111111116ff600006ff66ff6000000006ff66ff600006f6006f611111111
4ff5444444445ff4000044444444000000004ff44ff4000044444444000000006ff5666666665ff6000066666666000000006ff66ff600006666666644454444
4ff5fff44fff5ff400004ff44ff4000000004ff44ff400004ffffff4000000006ff5fff66fff5ff600006ff66ff6000000006ff66ff600006ffffff655555555
2444444224444442000044422444000000004514455400002444444200000000d666666dd666666d0000666dd66600000000651665560000d666666d44444445
02222220022222200000122002210000000041114152000002222220000000000dddddd00dddddd000001dd00dd1000000006111615d00000dddddd055555555
2555555225555552000055522555000000001122122100002555555200000000d555555dd555555d0000555dd5550000000011dd1dd10000d555555d44454444
02111200021112000000120002110000000052111124000002111200000000000d111d000d111d0000001d000d11000000005d1111d600000d111d0055555555
2551555225515552000055522551000000001122221100002551555200000000d551555dd551555d0000555dd5510000000011dddd110000d551555d44444445
1111111111111111000011111111000000002255552200001111111100000000111111111111111100001111111100000000dd5555dd00001111111155555555
000000000fffff000000000000000900009000000094490090000000000000099444444904444440006006000000000000000000000000000000000000000000
00000000f44444f00000000000000400004000000055550046688888888886644444444405555550446446440000000000000000000000000000000000000000
0aaaaa90feeee4f0f66666ff00944900009449000055550046688888888886644444444405324d50444444440000060000077000000000000000000000000000
aee4e4494fffff40fee4e44f00444500005444000044440096688888888886694444444405324d50466446644466464400777700000770000000000000000000
9e44444944444440fe44444f00944500005449000094490056688888888886659444444905555550444444444444444400717100007777000000000000000000
aaaaa99954444450fffff44400555500005555000055550052222222222222255555555505d42350555555550555555000071700001716000000000000000000
ae42144945555540fe42144400500500005005000050050055555555555555555000000505d42350500000050500005000000000006170000000000000000000
9e444449044444004e44444400500500005005000050050050000005500000055000000505555550500000050500005000000000000000000000000000000000
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
00665000006650000066500000444000006650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05665506056655600566550004444400056655060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05f1f10605f1f16005f1f100054141000538b8060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02ffff0602ffff60077fff00055555000133bb060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5566655f056665f05577775f115555145566655b0000665000000000000000000000000000000000000000000000000000000000000000000000000000000000
f24462000f446200f244770042255500314461000005665500000000000000000000000000000000000000000000000000000000000000000000000000000000
0555550005555500055555000111110005555500665538b800000000000000000000000000000000000000000000000000000000000000000000000000000000
0200020000222000020002001111111001000100556133bb00000000000000000000000000000000000000000000000000000000000000000000000000000000
060006000000000000fff00000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06bbbb000000000007ffff0605555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb1b100000000000ff1f10605414100000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbb0000000000077fff0655444400003b13000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbb0000600065577775f11d4d11403b161300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b24464b00006bbbbf244770040ddd00003b31330000bb30000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbb00bb3bb1b105555500011111003b3333330bbb333000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b000b0033bbbbbb0200020012111200333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000000
40bbb0400000000033bb300000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4bbbbb400000000003bbb30009999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbaba0000000000aaa1a10009f1f100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb0000000000009aaaa0099ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03bbb300040bbb0433bbb33a556f655f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
302440b004bbbbb4a2446200f2666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb00033bbaba00333330005555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03000300bb33bb000400040004000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00677000000000000066600000555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
067777000000000006ffff0005ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
067171000000000006f1f10005f1f100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00071700000067700fffff000fffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06777760000677775777775f9979979f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6057750600067171f5556500f9777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00677000066007170999990009777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000600655677770400040004000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000001100000000000000000000000000000000000cc0000cc0000000000000000000000000000000077007700
00010000000100000001000000010000000000000018e10009990000065557600066660000000000c000000c0000000000666600000000000000000077007700
00181000001b1000001a1000001510000188188001888e004999900f06ccc7600600006001bb13b0000000000000000006111160000000000000000077007700
01188100011bb100011aa10001155100188888880188880049999fff06cccc60066606601b3b33bb000000000066000006661660000000000000000077007700
0188881001bbbb1001aaaa1001555510188888880166770044999fff06cccc60066066601bbb3bb3000000000666600006616660000000000000000077770000
0188881001bbbb1001aaaa100155551001888880016677004444400f06cccc600600006001b33b30000000000666600006111160000000000000000077770000
00188100001bb100001aa10000155100001888000016710004440000006666000666660000133b00c000000c0666000006666600000000000000000077000000
00011000000110000001100000011000000180000001100000000000000000006000000000013000cc0000cc6000000060000000000000000000000077000000
0000000000004000049449000666770000000000006ff00000000000000000000000000000aaaa00000000000000000048e84000000000000444440000000000
000660000004000004944900655555600000040006ffff00000cc0000444ff00000000000aaaa990004440000044400048e840000444660049f99f4000444000
006666000484880049449490666666600000454006ff7f0060cccc00424fe8f002e12200aaaaaa90064476000644760004828400414623604f49994006447600
0666666024888e8049449490666566700000454066fffff06cccc6c0444f87f027e21820aaaaaa9006dd76000677760004828400444637600494940006cc7600
066666602488e78047777740267777800440040066fffff06c6c6cc0442f88f02e221820aa9aaa9006ddd6000677760048284000441633600499440006ccc600
0066660024888880777777702286888045540000666ffff0656c6660244f88f022228220aaa9a99006ddd6000677760048284000244633600449940006ccc600
0006600022444440777777702288688004400000666fff6060566500222f8ef022222220bba9990006ddd60006777600048e84002226326004f4f40006ccc600
000000000222220007777700028888000000000006666600000550000222ff0002222200bba990000066600000666000048e8400022266000444440000666000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06447600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06557600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06555600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f555f00000110000001100000000000066777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f54ffff0001281000013b100000000000dd666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f5ff55f00122280001333b0007777700d5dddd600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f54ff5f0012222000133330077666770d5dd7d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7f555f70016677000166770077776770d99979600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f77777f0016677000166770077777770d99979600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9fffff90001671000016710067777760d99999600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
099999000001100000011000066666000dd666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000201010101010101000101010101010101010101010101010001010101010101010101010101010100010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000b0b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000a0a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000a0a0a0a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0a0a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a00000a0a0a00000a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0000000a0a0a0000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0000000a0a0a0000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a000a0a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0000000a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0a0a0a0a0a0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000117300e7400d7400d74000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001465011650116500c65000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000c5510c555000000000027551275550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002d5512d55500000000000e5510e5550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001a75018750157501275000000000000000000000137000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001932016320183200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002435030350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002f35028350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000027750247502575021750227501f7500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
