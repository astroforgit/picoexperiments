pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
-- tankzilla
-- by mischa_u

-->8
-- hex utils (363)

function qr2xy(q,r)
	-- https://www.redblobgames.com/grids/hexagons/#hex-to-pixel
	return 1+8*q,6+10*(r-topr-1-0.5*(q&1))
end

function qr2pos(q,r)
	return r*16+q
end

function pos2qr(pos)
	return pos%16,pos\16
end

function pos2xy(pos)
	return qr2xy(pos2qr(pos))
end

function pos2str(pos)
	local q,r=pos2qr(pos)
	return sub("0"..r+1,-2)..sub("0"..q+1,-2)
end

function str2pos(s)
	return qr2pos(sub(s,3,4)-1,sub(s,1,2)-1)
end

function qr2cube(q,r)
	local x,z=q,r-(q+(q&1))/2
	local y=-x-z
	return {x=x,y=y,z=z}
end

function cube_distance(a,b)
	return (abs(a.x-b.x)+abs(a.y-b.y)+abs(a.z-b.z))/2
end

function pos_distance(a,b)
	return cube_distance(qr2cube(pos2qr(a)),qr2cube(pos2qr(b)))
end

evenq_directions={
	{{0,-1},{1,0},{1,1},
	 {0,1},{-1,1},{-1,0}},
	{{0,-1},{1,-1},{1,0},
	 {0,1},{-1,0},{-1,-1}}
}

function qr_neighbor(hex,direction)
	local parity=hex.q&1
	local dir=evenq_directions[parity+1][direction]
	return {q=hex.q+dir[1],r=hex.r+dir[2]}
end

function can_reach(hex_pos,neighbor_pos,flags)
	local neighbor_tile=board[neighbor_pos]
	local ridge_id=hex_pos..":"..neighbor_pos
	return neighbor_tile>-3
		and (flags.allow_exits or neighbor_tile!=-2)
		and (flags.ignore_craters or neighbor_tile!=-1)
		and (flags.ignore_ridges or blocked[ridge_id]==nil)
end

function hex_reachable(start,range,flags)
	local start_pos=qr2pos(start.q,start.r)
	local visited_set={[start_pos]=0}
	local fringes={{start}}

	for k=2,range+1 do
		add(fringes,{})
		for hex in all(fringes[k-1]) do
			local hex_pos=qr2pos(hex.q,hex.r)
			for dir=1,6 do
				local neighbor=qr_neighbor(hex,dir)
				local neighbor_pos=qr2pos(neighbor.q,neighbor.r)
				if visited_set[neighbor_pos]==nil and can_reach(hex_pos,neighbor_pos,flags) then
					visited_set[neighbor_pos]=k-1
					add(fringes[k],neighbor)
				end
			end
		end
	end
	return visited_set
end

-- pathfinding
-- https://www.redblobgames.com/pathfinding/a-star/introduction.html

function hex_astar(start_pos,goal_pos,flags)
	local frontier={}
	frontier[start_pos]=0
	local came_from={}
	local cost_so_far={}
	came_from[start_pos]=nil
	cost_so_far[start_pos]=0

	local current,priority
	while true do
		current,priority=popmin(frontier)
		if (current==nil or current==goal_pos) break

		local q,r=pos2qr(current)
		for dir=1,6 do
			local next=qr_neighbor({q=q,r=r},dir)
			local next_pos=qr2pos(next.q,next.r)
			if can_reach(current,next_pos,flags) then
				local new_cost=cost_so_far[current]+1
				if cost_so_far[next_pos]==nil or new_cost<cost_so_far[next_pos] then
					cost_so_far[next_pos]=new_cost
					local priority=new_cost+pos_distance(goal_pos,next_pos) -- heuristic
					frontier[next_pos]=priority
					came_from[next_pos]=current
				end
			end
		end
	end

	-- no path found?
	if (current==nil) return {}

	-- reverse path
	local current,path=goal_pos,{}
	while current!=start_pos do
		add(path,current,1)
		current=came_from[current]
	end
	return path
end

-->8
-- utils (238)

function deepcopy(t,init)
	local r=init or {}
	for k,v in pairs(t) do
		if type(v)=="table" then
			r[k]=deepcopy(v)
		else
			r[k]=v
		end
	end
	return r
end

function popmin(list)
	local minv,mink=32767
	for k,v in pairs(list) do
		if v<minv then
			mink,minv=k,v
		end
	end
	list[mink]=nil
	return mink,minv
end

function sort_by_fn(a,fn)
	-- insertion sort
	for i=1,#a do
		local j=i
		while j>1 and fn(a[j-1],a[j]) do
			a[j],a[j-1]=a[j-1],a[j]
			j-=1
		end
	end
end

function sprint(t,x,y,fg)
	print(t,x,y-1,0)
	print(t,x,y+1,0)
	print(t,x-1,y,0)
	print(t,x+1,y,0)
	print(t,x,y,fg)
end

function glen(s)
	local n=0
	for i=1,#s do
		n+=ord(sub(s,i,i))>=128 and 2 or 1
	end
	return n
end

function table_print(t,indent)
	indent=indent or ""
	for k,v in pairs(t) do
		if type(v)=="table" then
			printh(indent..k..":{")
			table_print(v,indent.." ")
			printh(indent.."}")
		else
			printh(indent..k..":"..tostr(v))
		end
	end
end

-->8
-- game state (2179)

function place_unit(id,ut,pos,maxr)
	local q,r
	if not pos then
		while true do
			q,r=flr(rnd(maxq-1))+1,flr(rnd(maxr))
			pos=qr2pos(q,r)
			if (board[pos]>=0 and #gs_b_units[pos]==0) break
		end
	end
	gs_units[id]=make_unit(id,pos,ut)
	add(gs_b_units[pos],id)
	gs_reachable[id]={}
	return q,r
end

function load_scenario(name)
	gs_scenario=scenarios[name]
	-- assert(gs_scenario)
	local id,forward_as=1,0
	for u in all(gs_scenario.units) do
		local pos=u.pos
		if pos then
			if (type(pos)=="string") pos=str2pos(pos)
			place_unit(id,u.type,pos)
			id+=1
		else
			for i=1,u.n do
				local attack=unit_types[u.type].attack
				local q,r=place_unit(id,u.type,nil,attack+forward_as<=gs_scenario.max_center_strength and 16 or 7)
				if (r>7) forward_as+=attack
				id+=1
			end
		end
	end
end

function init_board()
	board,ridges,blocked={},{},{}
	-- board, with margin for easier neighbor checks
	for r=-1,maxr+1 do
		for q=-1,maxq do
			local i=qr2pos(q,r)
			if q==-1 or r==-1 or r==maxr+1 or (r==maxr and q%2==0) then
				-- edge of board
				board[i]=-3
			elseif (r==maxr-1 and q%2==0) or (r==maxr and q%2==1) then
				-- bottom row of board
				board[i]=-2
			else
				board[i]=0
			end
		end
	end
	-- craters
	for i in all(craters) do
		board[i]=-1
		add(ridges,{i,63})
	end
	-- ridges
	for n=1,#encoded_ridges,2 do
		local i,t=encoded_ridges[n],encoded_ridges[n+1]
		local q,r=pos2qr(i)
		add(ridges,{i,t})
		for dir=0,5 do
			if t&2^dir>0 then
				local n=qr_neighbor({q=q,r=r},dir+1)
				local n_pos=qr2pos(n.q,n.r)
				blocked[i..":"..n_pos]=true
				blocked[n_pos..":"..i]=true
			end
		end
	end
end

function new_state()
	gs_turn=1
	gs_p_active=1	-- 1=red, 2=blue
	gs_victory=0
	gs_phase="move"	-- move/combat/move2
	gs_unit_actions=0
	gs_units={}
	gs_b_units={}
	gs_reachable={}
	for i,v in pairs(board) do
		if (v>0) board[i]=0	-- clear debris
		if (v>-3) gs_b_units[i]={}
	end
	-- units
	load_scenario(config_scenario)
	gs_tz_unit=gs_units[1]
	gs_outpost_unit=gs_units[2]
	reset_unit_actions()
end

function make_unit(id,pos,ut)
	local u=deepcopy(unit_types[ut])
	u.type=ut
	u.id=id
	u.pos=pos
	u.acted=false	-- TODO change to active?
	u.moves_left=0
	u.ap_attacked=false
	u.ram_count=0
	u.disabled=0
	if ut=="mk3" or ut=="mk5" then
		u.active_weapons=deepcopy(u.weapons)
		u.active_treads=u.treads
		u.player=1
	else
		u.player=2
	end
	return u
end

function unit_flags(unit)
	local flags={
		allow_exits=gs_phase!="combat" and unit.allow_exits,
		ignore_ridges=unit.ignore_ridges or gs_phase=="combat",
		ignore_craters=gs_phase=="combat"}
	return flags
end

function player_unit_at_pos(player,pos)
	-- returns my unit at pos, or nil
	if #gs_b_units[pos]>0 then
		for uid in all(gs_b_units[pos]) do
			local unit=gs_units[uid]
			if unit.player==player then
				return unit
			end
		end
	end
	return nil
end

function next_active_unit()
	for u in all(gs_units) do
		if (u.player==gs_p_active and not u.acted and not u.destroyed) return u
	end
	return nil
end

phase_action_attr={["move"]="move",["combat"]="range",["move2"]="move2"}

function unit_action_attr(unit)
	local action_attr=phase_action_attr[gs_phase]
	return unit[action_attr] or 0
end

function can_act(unit)
	if unit.player==gs_p_active and gs_phase=="combat" and unit.weapons then
		-- tankzilla combat
		-- XXX not ideal to put this here
		for w in all(subsystems) do
			if (unit.active_weapons[w]>0) return true
		end
		return false
	end
	local unit_actions=unit_action_attr(unit)
	return unit.player==gs_p_active and not unit.acted and not unit.destroyed and unit.disabled==0 and unit_actions>0
end

function has_weapons(u,activate)
	local has_weapons=false
	for w in all(subsystems) do
		if (activate) u.active_weapons[w]=u.weapons[w]
		if (u.weapons[w]>0) has_weapons=true
	end
	return has_weapons
end

function max_tz_weapon_range(u)
	local result=0
	for w in all(subsystems) do
		local range=tz_weapons[w].range
		if (u.weapons[w]>0 and range>result) result=range
	end
	return result
end

function reset_unit_actions(recovery)
	gs_unit_actions=0
	local tz_range=max_tz_weapon_range(gs_tz_unit)
	for u in all(gs_units) do
		if u.player==gs_p_active and not u.destroyed then
			-- recovery
			if (recovery and u.disabled>0) u.disabled-=1
			u.acted=false
			u.ap_attacked=false
			u.ram_count=0

			if gs_phase=="combat" and u.weapons then
				-- tankzilla
				if has_weapons(u,true) then
					gs_unit_actions+=1
				else
					u.acted=true
				end
			elseif can_act(u) then
				if gs_phase!="combat" then
					u.moves_left=unit_action_attr(u)
				end
				local count=update_reachable(u)
				if count>0 then
					gs_unit_actions+=1
				else
					u.acted=true
				end
			else
				-- can't act this phase
				u.acted=true
			end
		elseif not u.destroyed then
			u.acted=true
			-- show visibility for TZ units depending on max range
			if gs_phase=="combat" then
				local target_distance=pos_distance(gs_tz_unit.pos,u.pos)
				if target_distance<=tz_range then
					u.acted=false
				end
			end
		end
	end
end

function check_victory()
	-- victory= 1-3 if attacker wins, 4-6 if defender wins, 0 otherwise
	local def_outpost,tz_escape,tz_count,def_count,def_pnt=false,false,0,0,0
	for u in all(gs_units) do
		if not u.destroyed then
			if u.player==1 then
				if u.move>0 then
					tz_count+=1
					if (board[u.pos]==-2) tz_escape=true
				end
			else
				def_count+=1
				if (u.attack!=nil) def_pnt+=u.attack
				if (u.type=="outpost") def_outpost=true
			end
		end
	end
	local result=0
	if def_count==0 then
		-- major attacker victory: all defending units destroyed
		result=1
	elseif not def_outpost and tz_escape then
		-- attacker victory: outpost destroyed and tankzilla escapes from bottom
		result=2
	elseif not def_outpost and tz_count==0 then
		-- minor attacker victory: outpost destroyed and tankzilla destroyed
		result=3
	elseif def_outpost and tz_escape then
		-- minor defender victory: outpost survives, tankzilla escapes
		result=4
	elseif def_outpost and tz_count==0 then
		-- defender victory: outpost survives, tankzilla destroyed
		result=5
	elseif def_outpost and tz_count==0 and def_pnt>=gs_complete_victory_strength then
		-- major defender victory: outpost survives, tankzilla destroyed,
		-- >=30 attack points survive (50 for mk5)
		result=6
	end
	if result>0 then
		gs_victory=result
	end
end

function next_phase()
	deselect()
	if gs_phase=="move" then
		gs_phase="combat"
		reset_unit_actions()
		if (gs_unit_actions>0) return
	end
	if gs_phase=="combat" then
		gs_phase="move2"
		reset_unit_actions()
		if (gs_unit_actions>0) return
	end
	if gs_unit_actions==0 or gs_phase=="move2" then
		gs_p_active=3-gs_p_active
		if (gs_p_active==1) gs_turn+=1
		gs_phase,ai_plan="move"
		-- swap cursors
		cq,cr,other_cq,other_cr=other_cq,other_cr,cq,cr
		center_view(cr)
		reset_unit_actions(true)
	end
end

function can_move_to(unit,pos)
	return (board[pos]>=0 or (unit.allow_exits and board[pos]==-2)) and gs_reachable[unit.id][pos]!=nil
		and player_unit_at_pos(unit.player,pos)==nil and (player_unit_at_pos(3-unit.player,pos)==nil or not is_infantry(unit))
end

function update_reachable(unit)
	-- TODO only use for movement
	-- TODO tankzilla
	local range=gs_phase!="combat" and unit.moves_left or unit_action_attr(unit)
	local q,r=pos2qr(unit.pos)
	local flags=unit_flags(unit)
	gs_reachable[unit.id]=hex_reachable({q=q,r=r},range,flags)
	local result=0
	for pos,_ in pairs(gs_reachable[unit.id]) do
		if (gs_phase=="combat" and player_unit_at_pos(3-gs_p_active,pos))
				or (gs_phase!="combat" and can_move_to(unit,pos)) then
			result+=1
		else
			gs_reachable[unit.id][pos]=false
		end
	end
	return result
end

function move_unit(unit,to_pos)
	assert(pos_distance(unit.pos,to_pos)<=1)
	del(gs_b_units[unit.pos],unit.id)
	add(gs_b_units[to_pos],unit.id,1)
	unit.pos=to_pos
	unit.moves_left-=1
	update_reachable(unit)
	if unit.moves_left==0 then
		printh"no moves left"
		unit.acted=true
		gs_unit_actions-=1
	end
end

function ram_unit(unit,target,to_pos)
	if is_infantry(target) then
		-- infantry overrun
		if unit.weapons["anti-personnel"]>0 then
			reduce_infantry(target)
		end
	else
		-- TZ can only ram twice per turn
		if unit.ram_count>=2 then
			return
		end
		if target.type=="outpost" then
			-- TZ takes no damage
			destroy_unit(target)
		else
			if target.move==0 or target.disabled>0 then
				destroy_unit(target)
			else
				local dice=roll_dice()
				if dice>3 then
					destroy_unit(target)
				else
					target.disabled=2
				end
			end
			-- TZ loses treads
			if target.type=="hvy" then
				lose_treads(unit,2)
			else
				lose_treads(unit,1)
			end
		end
		unit.ram_count+=1
	end
	if (unit.pos!=to_pos) move_unit(unit,to_pos)
end

function ram_tz(unit,target,to_pos)
	lose_treads(target,1)
	destroy_unit(unit)
	if not unit.acted then
		unit.acted=true
		gs_unit_actions-=1
	end
end

function skip_unit(unit)
	unit.acted=true
	gs_unit_actions-=1
end

crt={
	["<1:2"]="ne",
	["1:2"]=split"ne,ne,ne,ne,d,x",
	["1:1"]=split"ne,ne,d,d,x,x",
	["2:1"]=split"ne,d,d,x,x,x",
	["3:1"]=split"d,d,x,x,x,x",
	["4:1"]=split"d,x,x,x,x,x",
	[">4:1"]="x"}

function combat_ratio(attack,defense)
	if attack>=1 and defense==0 then
		return ">4:1"
	else
		-- assert(defense>0)
		local ratio=attack/defense
		if ratio<0.5 then
			return "<1:2"
		elseif ratio<1 then
			return "1:2"
		elseif ratio>4 then
			return ">4:1"
		else
			return flr(ratio)..":1"
		end
	end
end

function roll_dice()
	return flr(rnd(6))+1
end

function combat_result(ratio)
	if type(crt[ratio])=="string" then
		return crt[ratio]
	else
		local dice=roll_dice()
		return crt[ratio][dice]
	end
end

function has_selected_weapons()
	for w,n in pairs(selected_weapons) do
		if (n>0) return true
	end
	return false
end

function attack_unit_stats(units,target)
	local attack,defense=0,0
	if selected_weapons then
		for w,n in pairs(selected_weapons) do
			attack+=tz_weapons[w].attack*n
		end
	else
		for u in all(units) do
			attack+=u.attack
		end
	end
	if selected_subsystem then
		if selected_subsystem=="treads" then
			defense=attack	-- 1:1 odds
		else
			defense=tz_weapons[selected_subsystem].defense
		end
	else
		defense=target.defense
	end
	local ratio=combat_ratio(attack,defense)
	return attack,defense,ratio
end

function attack_unit(units,target)
	local attack,defense,ratio=attack_unit_stats(units,target)
	local result=combat_result(ratio)
	combat={units=units,target=target,attack=attack,defense=defense,
			subsystem=selected_subsystem,weapons=selected_weapons,
			ratio=ratio,result=result,
			result_str="attacking "..target.type.." on "..pos2str(target.pos)}
end

function destroy_unit(target)
	del(gs_b_units[target.pos],target.id)
	target.destroyed=true
	if is_infantry(target) and board[target.pos]<2 then
		board[target.pos]=1 -- skeleton
	else
		board[target.pos]=2 -- hulk
	end
end

function is_infantry(unit)
	return sub(unit.type,1,3)=="inf"
end

function reduce_infantry(target,sim)
	local n=tonum(sub(target.type,4,4))
	if n<2 and not sim then
		destroy_unit(target)
	else
		local new="inf"..n-1
		target.type=new
		target.attack=unit_types[new].attack
		target.defense=unit_types[new].defense
		target.sid=unit_types[new].sid
	end
end

function lose_treads(target,amount)
	target.active_treads=max(target.active_treads-amount,0)
	-- adjust movement speed
	target.move=ceil(target.active_treads/(target.treads\3))
end

function resolve_combat(combat)
	local target=combat.target
	if combat.weapons then
		for w,n in pairs(combat.weapons) do
			if w=="missile" then
				gs_tz_unit.weapons[w]-=n
			elseif w=="anti-personnel" and n>0 and is_infantry(target) then
				target.ap_attacked=true
			end
			gs_tz_unit.active_weapons[w]-=n
		end
	else
		for u in all(combat.units) do
			u.acted=true
			gs_unit_actions-=1
		end
	end
	if target.weapons then
		-- tankzilla
		if combat.subsystem=="treads" then
			-- attack treads per unit
			local treads_destroyed=0
			for u in all(combat.units) do
				if combat_result"1:1"=="x" then
					treads_destroyed+=u.attack
				end
			end
			lose_treads(target,treads_destroyed)
			combat.result_str=treads_destroyed.." treads destroyed"
		elseif combat.result=="x" then
			target.weapons[combat.subsystem]=max(target.weapons[combat.subsystem]-1,0)
			combat.result_str=combat.subsystem.." destroyed"
		else
			combat.result_str="attack has no effect"
		end
		if not has_weapons(target) and target.move==0 then
			target.destroyed=true
			combat.result_str=target.type.." destroyed"
		end
	else
		if combat.result=="x" then
			destroy_unit(target)
			combat.result_str=target.type.." destroyed"
		elseif combat.result=="d" then
			if is_infantry(target) then
				reduce_infantry(target)
				if target.destroyed then
					combat.result_str=target.type.." destroyed"
				else
					combat.result_str="infantry reduced"
				end
			elseif target.disabled>0 then
				destroy_unit(target)
				combat.result_str=target.type.." destroyed"
			else
				target.disabled=2
				combat.result_str=target.type.." disabled"
			end
		else
			combat.result_str="attack has no effect"
		end
	end
end

-->8
-- draw (1643)

function draw_hex(x,y,t)
	sspr(t%10*12,t\10*12,12,12,x-1,y-1)
end

function draw_tile(q,r,t)
	local x,y=qr2xy(q,r)
	draw_hex(x,y,t)
end

function draw_tile_ridge(q,r,t,shade)
	local x,y=qr2xy(q,r)
	if shade then
		pal(0,13)
		draw_hex(x,y-1,t)
		pal(0,2)
		draw_hex(x,y+1,t)
	else
		draw_hex(x,y,t)
	end
end

function draw_ridges(shade)
	for h in all(ridges) do
		local i,t=h[1],h[2]
		local q,r=pos2qr(i)
		if r>=topr and r<=bottomr then
			if t==63 then
				draw_tile_ridge(q,r,0,shade)
			else
				for n=0,5 do
					if t&2^n>0 then
						draw_tile_ridge(q,r,4+n,shade)
					end
				end
			end
		end
	end
end

p_colors={{fg=8,bg=2},{fg=12,bg=1}}

function draw_units()
	for r=topr,bottomr do
		for q=0,maxq do
			local i=qr2pos(q,r)
			local uids=gs_b_units[i]
			if uids!=nil and #uids>0 then
				-- alternative which unit to draw if there are multiple
				local id=uids[ani_t\18%#uids+1]
				local u=gs_units[id]
				-- assert(not u.destroyed)
				local u_color,x,y=p_colors[u.player],qr2xy(q,r)
				if u.disabled>0 then
					pal({[7]=7,[12]=6,[3]=5,[1]=1})
				elseif u.disabled>0 or (u.player==2 and u.acted and not u.type=="outpost") then
				-- 	only show blue as acted
					pal({[7]=6,[12]=3,[3]=1,[1]=0})
				end
				draw_hex(x,y,u.sid)
				if u.acted or u.disabled>0 then
					-- restore
					pal({[7]=7,[12]=12,[3]=3,[1]=1})
				end
			end
		end
	end
end

function draw_target()
	if gs_phase=="combat" and selected_target then
		local q,r=pos2qr(selected_target.pos)
		pal(0,p_colors[gs_p_active].fg)
		draw_tile(q,r,3)
	end
end

function draw_cursor()
	for u in all(selected_units) do
		local q,r=pos2qr(u.pos)
		pal(0,p_colors[gs_p_active].fg)
		draw_tile(q,r,1)
	end
	if ani_t%20>10 then
		pal(0,10)
		draw_tile(cq,cr,1)
	end
end

function draw_scrollbar()
	local sy,sh=128*(topr+1)/maxr,128*(viewh-2)/maxr
	line(125,0,125,127,0)
	line(126,sy-1,127,sy-1,0)
	rectfill(126,sy,127,sy+sh,6)
	line(126,sy+sh+1,127,sy+sh+1,0)
end

function draw_statusbar()
	local pos=qr2pos(cq,cr)
	local unit=player_unit_at_pos(gs_p_active,pos)
	local target=player_unit_at_pos(3-gs_p_active,pos)
	sprint("p"..gs_p_active.." "..gs_phase,2,2,p_colors[gs_p_active].fg)
	sprint(pos2str(pos),108,2,6)
	if cs.status then
		local s,c
		if type(cs.status)=="function" then
			s,c=cs.status(pos,unit,target)
		else
			s=cs.status
		end
		s=s or ""
		c=c or 7
		sprint(s,2,121,c,0)
	end
	if cs.hint and not ai_plan then
		local s=type(cs.hint)=="function" and cs.hint(pos,unit,target) or cs.hint
		if (#s>0) sprint(s,124-glen(s)*4,121,7)
	end
end

function unit_status_tostr(unit)
	-- "inf3 a3/1 d3 m3"
	local s,c=unit.type.." "
	if unit.disabled>0 then
		s..="disabled "
	end
	if unit.attack!=nil and unit.disabled==0 then
		s..="a"..unit.attack.."/"..unit.range.." "
	end
	if unit.defense!=nil then
		s..="d"..unit.defense.." "
	end
	if unit.move!=nil and unit.disabled==0 then
		s..="m"..unit.move
		if unit.move2!=nil then
			s..="-"..unit.move2
		end
		s..=" "
	end
	return s,p_colors[unit.player].fg
end

function draw_modal(w,h,b,bg)
	local x,y=(124-w)/2,(128-h)/2
	rectfill(x,y,x+w,y+h,bg)
	rect(x+1,y+1,x+w-1,y+h-1,b)
	return x,y
end

function draw_dmg_dots(x,y,n,a,sx,rx)
	sx=sx or 5
	rx=rx or 20
	local c=8
	for i=0,n-1 do
		local bx=x+(i%rx*4)+(i%rx\sx*2)
		local by=y+(i\rx*6)
		rectfill(bx,by,bx+1,by+1,i<n-a and 8 or 7)
	end
end

subsystems={"primary","secondary","missile","anti-personnel"}

function draw_subsystem_cursor(s,x,y,w,h,fg,bg)
	rectfill(x,y,x+w,y+h,bg or 5)
	print(s,x,y+1,fg or 7)
end

function weapon_tostr(weapon)
	return "a"..weapon.attack.."/"..weapon.range.." d"..weapon.defense
end

function draw_scorecard(unit,select)
	local w,h,mx,my=118,82,8,8
	local x,y=draw_modal(w,h,7,2)
	print("tankzilla "..unit.type,x+mx,y+my,7)
	for n,w_name in pairs(subsystems) do
		if select and c_subsystem==n then
			local c,bg=">",5
			draw_subsystem_cursor(c,x+mx-4,y+my+5+6*n,w-mx-2,6,7,bg)
		end
		local available_weapons=unit.weapons[w_name]
		local unit_type_weapon=unit_types[unit.type].weapons[w_name]
		local weapon=tz_weapons[w_name]
		local s=available_weapons.." "..w_name.."\*"..(15-#w_name)..(unit_type_weapon>9 and "" or " ").."  "..weapon_tostr(weapon)
		print(s,x+mx,y+my+6+6*n,6)
		if n<4 then
			draw_dmg_dots(x+mx+(18-unit_type_weapon)*4+2,y+my+8+6*n,unit_type_weapon,available_weapons,6)
		else
			draw_dmg_dots(x+mx,y+my+38,unit_type_weapon,available_weapons,4)
		end
	end
	if select and c_subsystem==5 then
		draw_subsystem_cursor(">",x+mx-4,y+my+43,w-mx-2,6)
	end
	s=sub("0"..unit.active_treads,-2).." treads\*e  m3\n\*n   2\n\*n   1\n\*n   0"
	print(s,x+mx,y+my+44,6)
	draw_dmg_dots(x+mx,y+my+52,unit.treads,unit.active_treads,5,unit.treads\3)
end

victory_text={"major attacker victory","attacker victory","minor attacker victory",
			  "minor defender victory","defender victory","major defender victory"}

function draw_victory()
	local w,h,mx,my=104,50,8,8
	local winner=gs_victory<4 and 1 or 2
	local x,y=draw_modal(w,h,7,p_colors[winner].bg)
	print("\^w\^tgame over",x+w/2-9*4,y+my,7)
	local s=victory_text[gs_victory]
	print(s,x+w/2-#s*2,y+my+14,7)
	print("total turns: "..gs_turn,x+mx,y+my+22,7)
	print("— new game",x+w-40-mx,y+h-my-2,6)
end

function doshake()
	local shakex,shakey=16-rnd(32),16-rnd(32)
	shakex*=shake
	shakey*=shake
	camera(shakex,shakey)
	shake=shake*0.95
	if (shake<0.05) shake=0
end

function draw_explosion(pos)
	local frame=ani_t\(ani_length/5)
	if frame<5 then
		local q,r=pos2qr(pos)
		draw_tile(q,r,22+frame)
	end
end

function _draw()
	cls(5)
	doshake()
	palt(0,false)
	palt(11,true)
	-- board background tiles
	local highlight_tiles=not animate and gs_phase!="combat" and #selected_units==1 and gs_p_active==2
	for r=topr,bottomr do
		for q=0,maxq do
			local i,t=qr2pos(q,r),12 -- empty tile
			if board[i]!=nil and board[i]>=-2 then
				if board[i]==-1 then
					t=11 -- crater
				elseif board[i]>=0 then
					t=12+board[i] -- regular tiles
				end
				draw_tile(q,r,t)
				if highlight_tiles then
					local reachable=gs_reachable[selected_units[1].id][i]
					if reachable and reachable>0 then
						pal(0,p_colors[gs_p_active].fg)
						draw_tile(q,r,2) -- checkered
						pal(0,0)
					end
				end
				if board[i]==-2 then
					draw_tile(q,r,10) -- bottom row icons on top
				end
			end
		end
	end
	-- shades
	palt(5,true)
	draw_ridges(true)
	-- hills
	pal(0,0)
	draw_ridges(false)
	pal(3,12+128,1)
	pal(2,4+128,1)
	draw_units()
	draw_target()
	if animate then
		if combat then
			draw_explosion(combat.target.pos)
		elseif movement and movement.ramming then
			draw_explosion(movement.target.pos)
		end
	elseif not ai_plan then
		draw_cursor()
	end

	-- pal()
	pal(0,0)
	palt()
	camera()

	draw_scrollbar()
	if gs_victory>0 then
		draw_victory(gs_victory)
	else
		if scorecard then
			draw_scorecard(scorecard.unit,scorecard.select)
		end
		draw_statusbar()
	end
end

-->8
-- update (207)

function scroll_view(r)
	topr=mid(-1,r,maxr-viewh+1)
	bottomr=topr+viewh
end

function center_view(r)
	scroll_view(cr-ceil(viewh/2))
end

function cursor_x(dx)
	-- TODO improve move direction depending on last up/down direction
	cq=mid(0,cq+dx,maxq)
	-- correct bottom row movement
	if (cr==maxr and cq%2==0) cr-=1
end

function cursor_y(dy)
	cr=mid(0,cr+dy,maxr)
	if (cr==maxr and cq%2==0) cr-=1
	if cr<topr+viewedge then
		scroll_view(cr-viewedge)
	elseif cr>bottomr-viewedge then
		scroll_view(cr-viewh+viewedge)
	end
end

function cursor_pos(pos)
	cq,cr=pos2qr(pos)
	center_view(cr)
end

function select_unit(unit)
	if gs_phase!="combat" then
		selected_units={unit}
		update_reachable(unit)
	elseif not selected_uids[unit.id] then
		add(selected_units,unit)
		selected_uids[unit.id]=true
	else
		del(selected_units,unit)
		selected_uids[unit.id]=false
	end
end

function select_target(target)
	selected_target=target
	selected_units,selected_uids={},{}
end

function deselect()
	selected_units,selected_uids,selected_target,selected_subsystem,selected_weapons={},{},nil,nil,nil
	scorecard,force_end_phase=nil,false
end

-->8
-- control states (1238)

function start_animation(length)
	animate,ani_t,ani_length=true,0,length
end

function start_movement(unit,to_pos,target)
	local flags=unit_flags(unit)
	local path=hex_astar(unit.pos,to_pos,flags)
	movement={unit=unit,to_pos=to_pos,path=path,target=target}
	start_animation(8)
end

control_states={
	move_select={
		enter=function()
			assert(gs_phase!="combat")
			assert(#selected_units==0)
			if gs_unit_actions==0 then
				change_state"no_actions"
			elseif gs_p_active==1 then
				-- move cursor to TZ
				cursor_pos(gs_tz_unit.pos)
				select_unit(gs_tz_unit)
				change_state"move_to"
			end
		end,
		input_o=function()
			force_end_phase=not force_end_phase
			change_state"force_end_phase"
		end,
		input_x=function(pos,unit,target)
			if unit and can_act(unit) then
				select_unit(unit)
				sfx(0) -- confirm selection
				change_state"move_to"
			elseif target and target.weapons then
				scorecard={unit=target}
				change_state"show_scorecard"
			else
				local unit=next_active_unit()
				if (unit) cursor_pos(unit.pos)
			end
		end,
		hint=function(pos,unit,target)
			if unit and can_act(unit) then
				return "—select"
			elseif target and target.weapons then
				return "—info"
			else
				return "—gotoŽend?"
			end
		end,
		status=function(pos,unit,target)
			if unit then
				return unit_status_tostr(unit)
			elseif target then
				return unit_status_tostr(target)
			else
				local s=gs_unit_actions.." active unit"
				if gs_unit_actions!=1 then
					s..="s"
				end
				return s
			end
		end
	},
	move_to={
		enter=function()
			assert(gs_phase!="combat")
			assert(#selected_units==1)
			animate=false
			movement=nil

		end,
		tick=function()
			if ai_plan and not movement then
				-- pick next pos from the path
				local pos=deli(ai_plan.path,1)
				if pos!=nil then
					-- printh("AI moving to tile "..pos2str(pos))
					cursor_pos(pos)
					local target=player_unit_at_pos(3-gs_p_active,pos)
					start_movement(gs_tz_unit,pos,target)
				else
					change_state"no_actions"
				end
			elseif animate and movement and ani_t==ani_length then
				if movement.ramming then
					shake+=0.15
					sfx(3) -- explosion
					if movement.unit.weapons then
						-- printh"ram_unit"
						ram_unit(movement.unit,movement.target,movement.to_pos)
					elseif movement.target.weapons then
						-- printh"ram_tz"
						ram_tz(movement.unit,movement.target,movement.to_pos)
					end
					if (movement.target.weapons) or movement.unit.moves_left==0 then
						-- printh"end of move"
						deselect()
						change_state"move_select"
					end
					animate,movement=false,nil
				elseif movement.unit.pos==movement.to_pos then
					-- printh"destination reached"
					if movement.target then
						-- printh"ramming..."
						sfx(2) -- bump / ram noise
						movement.ramming=true
						start_animation(15)
					else
						if movement.unit.moves_left==0 then
							-- printh"end of move"
							deselect()
							change_state"move_select"
						end
						animate,movement=false,nil
						check_victory()
					end
				else
					-- printh"move_unit"
					assert(#movement.path>0)
					local next_pos=deli(movement.path,1)
					-- printh("moving "..movement.unit.id.." from "..pos2str(movement.unit.pos).." to "..pos2str(next_pos))
					move_unit(movement.unit,next_pos)
					ani_t=0
				end
			end
		end,
		input_o=function()
			if not animate then
				deselect()
				change_state"move_select"
			end
		end,
		input_x=function(pos,unit,target)
			local this_unit=selected_units[1]
			if animate then
				return
			elseif unit then
				-- TODO check infantry merge
				if pos==this_unit.pos then
					skip_unit(this_unit)
					deselect()
					change_state"move_select"
				elseif can_act(unit) then
					select_unit(unit)
					sfx(0) -- confirm selection sound
					change_state"move_to"
				end
			elseif can_move_to(this_unit,pos) then
				if target then
					if target.weapons and not is_infantry(this_unit) then
						sfx(1) -- rodger
						start_movement(this_unit,pos,target)
					else
						sfx(2) -- invalid
					end
				else
					sfx(1) -- rodger
					start_movement(this_unit,pos)
				end
			else
				sfx(2) -- invalid
			end
		end,
		hint=function(pos,unit,target)
			local this_unit=selected_units[1]
			if animate then
				return ""
			elseif pos==this_unit.pos then
				return "—skip"
			elseif board[pos]==-2 then
				return "—escape"
			elseif target and this_unit.weapons then
				if is_infantry(target) then
					return "—overrun"
				elseif this_unit.ram_count<2 then
					return "—ram"
				end
			elseif target and target.weapons and not is_infantry(this_unit) then
				return "—ram"
			else
				return "—move"
			end
		end,
		status=function()
			if movement and movement.target then
				if is_infantry(movement.target) then
					return "overrunning "..movement.target.type.."..."
				else
					return "ramming "..movement.target.type.."..."
				end
			elseif movement then
				return "moving..."
			else
				return unit_status_tostr(selected_units[1])
			end
		end
	},
	combat_target={
		enter=function()
			assert(gs_phase=="combat")
			assert(not selected_target)
			if gs_unit_actions==0 then
				-- printh"no more actions, auto move!"
				change_state"no_actions"
			elseif gs_p_active==1 and ai_plan then
				target=deli(ai_plan.targets,1)
				if target!=nil then
					-- printh("next target: "..target.id)
					-- table_print(target.selected_weapons)
					select_target(gs_units[target.id])
					if not selected_uids[gs_tz_unit.id] then
						select_unit(gs_tz_unit)
					end
					selected_weapons=target.selected_weapons
					if has_selected_weapons() then
						scorecard=nil
						attack_unit(selected_units,selected_target)
						change_state"show_combat"
					else
						assert(false, "no selected weapons")
					end
				else
					change_state"no_actions"
				end
			elseif gs_p_active==2 then
				-- move cursor to TZ
				cursor_pos(gs_tz_unit.pos)
			end
		end,
		input_o=function()
			force_end_phase=not force_end_phase
			change_state"force_end_phase"
		end,
		input_x=function(pos,unit,target)
			if target then
				select_target(target)
				sfx(0) -- confirm selection sound
				scorecard={unit=target,select=true}
				change_state"select_target_subsystem"
			end
		end,
		hint=function(pos,unit,target)
			if target then
				return "—target"
			else
				return "Žend?"
			end
		end,
		status=function(pos,unit,target)
			if unit then
				return unit_status_tostr(unit)
			elseif target then
				return unit_status_tostr(target)
			end
			return ""
		end
	},
	combat_attackers={
		enter=function()
			assert(gs_phase=="combat")
			assert(selected_target)
			if gs_p_active==2 then
				assert(selected_subsystem)
				-- auto-select all units within range
				for u in all(gs_units) do
					local target_distance=pos_distance(u.pos,selected_target.pos)
					if can_act(u) and u.range>=target_distance and not selected_uids[u.id] then
						select_unit(u)
					end
				end
			end
		end,
		input_o=function()
			if #selected_units>0 then
				attack_unit(selected_units,selected_target)
				change_state"show_combat"
			end
		end,
		input_x=function(pos,unit,target)
			if unit and can_act(unit) then
				select_unit(unit)
				sfx(0) -- confirm selection sound
			elseif target==selected_target then
				scorecard={unit=target,select=true}
				change_state"select_target_subsystem"
			elseif target then
				select_target(target)
				sfx(0) -- confirm selection sound
			elseif not unit and not target then
				deselect()
				change_state"combat_target"
			end
		end,
		hint=function(pos,unit,target)
			local s=""
			if unit then
				s="—select"
			elseif #selected_units>0 then
				s="Žattack"
			elseif target then
				s="—target"
			end
			return s
		end,
		status=function(pos,unit,target)
			if selected_subsystem then
				attack,defense,ratio=attack_unit_stats(selected_units,selected_target)
				return sub(selected_subsystem,1,9).." "..ratio.." "..ceil(100*hit_pct[ratio][3]).."%hit"
			elseif unit then
				return unit_status_tostr(unit)
			elseif target then
				return unit_status_tostr(target)
			else
			end
			return ""
		end
	},
	no_actions={
		enter=function()
			-- assert(gs_unit_actions==0)
			if ai_plan then
				start_animation(30)
			end
		end,
		tick=function()
			if ani_t==ani_length then
				animate=false
				next_phase()
				change_state_phase()
			end
		end,
		input_x=function()
			next_phase()
			change_state_phase()
		end,
		hint="—next",
		status=function()
			if (not ai_plan) return "no actions left..."
		end
	},
	force_end_phase={
		enter=function()
			assert(force_end_phase)
		end,
		input_o=function()
			force_end_phase=not force_end_phase
			change_state_phase()
		end,
		input_x=function()
			next_phase()
			change_state_phase()
		end,
		hint="—next",
		status=function()
			return "end "..gs_phase.." phase?"
		end
	},
	select_target_subsystem={
		enter=function()
			assert(gs_p_active==2)
			assert(selected_target)
			max_subsystem=5
		end,
		input_cursor=function(b_l,b_r,b_u,b_d)
			if (b_u) c_subsystem=max(c_subsystem-1,1)
			if (b_d) c_subsystem=min(c_subsystem+1,max_subsystem)
		end,
		input_o=function()
			deselect()
			change_state"combat_target"
		end,
		input_x=function()
			if c_subsystem<5 and selected_target.weapons[subsystems[c_subsystem]]>0 then
				selected_subsystem=subsystems[c_subsystem]
				scorecard=nil
				change_state"combat_attackers"
			elseif c_subsystem==5 and selected_target.active_treads>0 then
				selected_subsystem="treads"
				scorecard=nil
				change_state"combat_attackers"
			else
				sfx(2) -- invalid
			end
		end,
		hint="—select",
		status="select subsystem"
	},
	show_scorecard={
		enter=function()
			assert(scorecard)
		end,
		input_cursor=function()
		end,
		input_x=function()
			scorecard=nil
			change_state"move_select"
		end,
		hint="—dismiss"
	},
	show_combat={
		enter=function()
			assert(combat)
			ani_wait=30
			start_animation(30)
		end,
		tick=function()
			if ani_t==ani_length\5 then
				sfx(3) -- explosion
				shake+=0.15
			-- elseif ani_t==ani_length\2 then
			elseif ani_t==ani_length then
				resolve_combat(combat)
				animate=false
				deselect()
			elseif ani_t==ani_length+ani_wait then
				check_victory()
				combat=nil
				change_state"combat_target"
			end
		end,
		status=function()
			if combat then
				return combat.result_str
			end
		end
	}
}

function change_state(to)
	-- printh("changing control state to: "..to)
	csn,cs=to,control_states[to]
	if (cs.enter) cs.enter()
end

function change_state_phase()
	if gs_phase!="combat" then
		change_state"move_select"
	else
		change_state"combat_target"
	end
end

-->8
-- AI logic

function find_exit_pos()
	local tzq,tzr=pos2qr(gs_tz_unit.pos)
	return qr2pos(tzq,maxr-1+1*(tzq&1))
end

function find_nearby_units(pos)
	local units={}
	for u in all(gs_units) do
		if u.player==2 and not u.destroyed and pos_distance(pos,u.pos)<=8 then
			local unit=deepcopy(u)
			unit.hits=0
			unit.selected_weapons={}
			add(units,unit)
		end
	end
	return units
end

function dump_hexes(hexes)
	for n,h in pairs(hexes) do
		printh(pos2str(h.id)..": moves="..h.moves.." goal="..h.goal_distance.." attack="..h.attack_val.." damage="..h.damage_val.." target="..h.target_val.." hex="..h.hex_val)
		if h.ramming then
			printh(" ramming "..h.ramming.type)
		end
		for target in all(h.targets) do
			local s=" "..target.type.." on "..pos2str(target.pos)
			for w,n in pairs(target.selected_weapons) do
				s..=" "..n.."x "..w
			end
			printh(s)
		end
	end
end

function assign_ap(unit,target_ratio,ap_weapons)
	if (unit.ap_deployed/unit.defense>=target_ratio) return 0
	for i=1,ap_weapons do
		unit.ap_deployed+=1
		if (unit.ap_deployed/unit.defense>=target_ratio) return i
	end
	return ap_weapons
end

function deploy_ap(units,ap_weapons,ap_ratios,skip_1s)
	if (ap_weapons==0) return 0
	for ratio in all(ap_ratios) do
		-- printh("deploy_ap ratio="..ratio.." skip_1s="..tostr(skip_1s))
		for i=1,#units do
			if not skip_1s or units[i].type!="inf1" then
				ap_weapons-=assign_ap(units[i],ratio,ap_weapons)
			end
			if (ap_weapons==0) return 0
		end
	end
	return ap_weapons
end

function add_target(targets,unit,weapon,count)
	local target
	for t in all(targets) do
		if t.id==unit.id then
			target=t
			break
		end
	end
	if target==nil then
		target=unit
		add(targets,unit)
	end
	if (target.selected_weapons[weapon]==nil) target.selected_weapons[weapon]=0
	target.selected_weapons[weapon]+=count
end

damage_c,tread_damage_c,target_c=10,10,100
-- hit ratio for enabled / disabled units
hit_pct={
	["<1:2"]=split"0,0,0",
	["1:2"]=split"0.33,0.25,0.17",
	["1:1"]=split"0.67,0.5,0.33",
	["2:1"]=split"0.83,0.67,0.5",
	["3:1"]=split"1,0.83,0.67",
	["4:1"]=split"1,0.92,0.83",
	[">4:1"]=split"1,1,1"}

function co_ai_plan()
	local start_t=time()
	printh("---")
	-- printh("\nAI start: "..start_t)
	ai_thinking,ai_plan=true

	-- strategic long-range target
	local goal_pos=gs_outpost_unit.pos
	if gs_outpost_unit.destroyed then
		-- escape
		-- printh("outpost destroyed, escaping")
		goal_pos=find_exit_pos()
	end
	printh("AI GOAL POS "..pos2str(goal_pos))
	-- tactical short-range intelligence
	local hexes={}
	for p,v in pairs(gs_reachable[gs_tz_unit.id]) do
		if v and v>0 then
			-- printh(pos2str(p))
			-- TODO consider ram path
			local goal_distance=pos_distance(p,goal_pos)
			local hex={id=p,path={p},ramming=nil,targets={},moves=v,goal_distance=goal_distance,attack_val=0,damage_val=0,target_val=0}
			local units=find_nearby_units(p)

			-- ramming
			for u in all(units) do
				if u.pos==p then
					hex.ramming=u
					-- printh("ramming "..u.type.." on "..pos2str(u.pos))
					if u.disabled>0 or u.move==0 or u.type=="inf1" then
						u.hits=1
						u.destroyed=true
					elseif is_infantry(u) then
						reduce_infantry(u,true)
						hex.attack_val+=20 -- attack_val of inf1
					else
						u.hits=0.75
						u.disabled=2
						hex.damage_val+=u.type=="hvy" and 2*tread_damage_c or tread_damage_c
					end
				end
			end

			-- attack value
			-- AI anti-personnel
			local ap_weapons=gs_tz_unit.weapons["anti-personnel"]
			if ap_weapons>0 then
				local infantry_units={}
				for u in all(units) do
					if not u.destroyed and is_infantry(u) and pos_distance(p,u.pos)<=1 then
						u.ap_deployed=0
						add(infantry_units,u)
					end
				end
				if #infantry_units>0 then
					-- sort in ascending order of defense
					sort_by_fn(infantry_units,function(a,b) return a.defense>b.defense end)
					-- go 1-2 starting at the bottom of the list, going up
					ap_weapons=deploy_ap(infantry_units,ap_weapons,split"0.5")
					-- sort in descending order of defense
					sort_by_fn(infantry_units,function(a,b) return a.defense<b.defense end)
					-- go 1-1 starting at the top and going down, etc
					ap_weapons=deploy_ap(infantry_units,ap_weapons,split"1")
					-- go 2-1 starting at the top and going down, etc, skipping 1s
					-- go 3-1 starting at the top and going down, etc, skipping 1s
					-- go 4-1 starting at the top and going down, etc, skipping 1s
					ap_weapons=deploy_ap(infantry_units,ap_weapons,split"2,3,4",true)
					-- go 2-1 starting at the top and going down, etc, including 1s
					-- go 3-1 starting at the top and going down, etc, including 1s
					-- go 4-1 starting at the top and going down, etc, including 1s
					ap_weapons=deploy_ap(infantry_units,ap_weapons,split"2,3,4")
					-- put remaining on lowest inf
					if ap_weapons>0 then
						-- printh("putting remaining on lowest inf "..ap_weapons)
						infantry_units[#infantry_units].ap_deployed+=ap_weapons
					end
					for u in all(infantry_units) do
						local ratio=combat_ratio(u.ap_deployed,u.defense)
						u.hits+=hit_pct[ratio][2]
						-- printh("simulating anti-personnel target="..u.type.." on "..pos2str(u.pos).." "..u.ap_deployed.."x hits="..u.hits)
						add_target(hex.targets,u,"anti-personnel",u.ap_deployed)
					end
				end
			end

			local weapon_order=split"secondary,primary,missile"
			-- change order if there are no defenders at 3 hexes away
			local units_at_3=false
			for u in all(units) do
				if (pos_distance(p,u.pos)==3) units_at_3=true
			end
			if not units_at_3 then
				weapon_order=split"primary,secondary,missile"
			end
			for w in all(weapon_order) do
				local weapon=tz_weapons[w]
				for n=1,gs_tz_unit.weapons[w] do
					sort_by_fn(units,
						function(a,b)
							-- most attack_val
							if a.attack_val!=b.attack_val then
								return a.attack_val<b.attack_val
							end
							-- lowest hits
							if a.hits!=b.hits then
								return a.hits>b.hits
							end
							-- closest to target
							return pos_distance(a.pos,goal_pos)>pos_distance(b.pos,goal_pos)
						end)
					for u in all(units) do
						if not u.destroyed and pos_distance(p,u.pos)<=weapon.range and u.hits<1 and (w!="missile" or (u.type=="outpost" or u.type=="arty" or gs_outpost_unit.destroyed)) then
							local ratio=combat_ratio(weapon.attack,u.defense)
							if u.disabled>0 or u.type=="inf1" then
								u.hits+=hit_pct[ratio][1]
							else
								u.hits+=hit_pct[ratio][2]
							end
							-- new target value
							u.attack_val*=min(u.hits,1)
							-- printh("simulating weapon "..w.." target="..u.type.." on "..pos2str(u.pos).." hits="..u.hits)
							add_target(hex.targets,u,w,1)
							break
						end
					end
				end
			end
			for u in all(units) do
				hex.attack_val+=min(u.hits,1)*u.attack_val
			end

			-- damage value
			local defender_aps,arty_count=0,0
			for u in all(units) do
				if not u.destroyed and u.disabled<2 and u.attack and pos_distance(u.pos,p)<=u.range then
					if (u.type=="arty" and u.hits<1) arty_count+=1
					defender_aps+=u.attack*(1-min(u.hits,1))
				end
			end
			hex.damage_val+=defender_aps*damage_c

			-- target value
			local current_goal_distance=pos_distance(gs_tz_unit.pos,goal_pos)
			local distance_delta=current_goal_distance-goal_distance
			-- XXX speed up when under arty umbrella
			if (distance_delta>0 and arty_count>0) distance_delta*=3
			-- penalty for no change in distance or withdrawal
			if (distance_delta<=0) distance_delta-=1
			hex.target_val=target_c/max(gs_tz_unit.move,1)*distance_delta

			-- total hex value
			hex.hex_val=hex.attack_val-hex.damage_val+hex.target_val+rnd()
			add(hexes,hex)
		end
		if (stat(1)>0.87) then
			-- printh("yielding...")
			yield()
		end
	end
	sort_by_fn(hexes,function(a,b) return a.hex_val>b.hex_val end)
	dump_hexes(hexes)
	ai_plan=hexes[#hexes]
	printh("Best: "..pos2str(ai_plan.id).. " value="..ai_plan.hex_val)
	-- printh("AI end: "..time())
	printh("AI duration: "..time()-start_t)
	printh()
	ai_thinking=false
end

-->8
-- updates

function update_player()
	if gs_p_active==2 then
		local b_l,b_r,b_u,b_d,b_o,b_x=btnp(0),btnp(1),btnp(2),btnp(3),btnp(4),btnp(5)
		if b_l or b_r or b_u or b_d then
			if cs.input_cursor then
				cs.input_cursor(b_l,b_r,b_u,b_d)
			else
				-- default
				if (b_l) cursor_x(-1)
				if (b_r) cursor_x(1)
				if (b_u) cursor_y(-1)
				if (b_d) cursor_y(1)
			end
		end
		if b_o or b_x then
			local pos=qr2pos(cq,cr)
			local unit=player_unit_at_pos(gs_p_active,pos)
			local target=player_unit_at_pos(3-gs_p_active,pos)
			-- printh(csn.."] pos "..pos.." input "..tostr(b_o).." "..tostr(b_x))
			if (b_o and cs.input_o) then
				cs.input_o(pos,unit,target)
			elseif (b_x and cs.input_x) then
				cs.input_x(pos,unit,target)
			end
		end
	end
	if cs.tick then
		cs.tick()
	end
end

function _update()
	if ai_thinking then
		local cstatus,err=coresume(ai_thread)
		if err then
			-- cls()
			local t=trace(ai_thread,err)
			printh(t)
			stop(t)
		end
	end
	if gs_victory==0 then
		if gs_p_active==1 and gs_phase=="move" then
			-- trigger plan generation with "A" key
			if not ai_thinking and (not ai_plan or btnp(5,1)) then
				-- co_ai_plan()
				ai_thread=cocreate(co_ai_plan)
				coresume(ai_thread)
			end
		end
		update_player()
	else
		if (btnp(5)) new_game()
	end
	ani_t+=1
end

-->8
-- game data (449)

craters=split"36,44,45,57,68,93,96,104,110,117,129,140,165,166,178,200,205"
-- 1=N, 2=NE, 4=SE, 8=S, 16=SW, 32=NW, 63=ALL
encoded_ridges=split"7,4,21,24,22,16,33,48,40,10,50,4,51,12,56,12,75,3,88,4,98,33,101,6,102,8,106,30,107,33,114,4,115,4,119,4,125,8,130,4,145,4,152,2,162,51,170,28,183,6,185,12,198,6,213,49,226,12,232,24,233,4,236,12,237,8,247,33"

scenarios={
	-- ["4arty"]={
	-- 	max_center_strength=20,
	-- 	complete_victory_strength=30,
	-- 	units={
	-- 		{type="mk3",pos="2106"},
	-- 		{type="outpost",pos="0110"},
	-- 		-- 20 points of attack strength of infantry
	-- 		{type="inf3",n=6},
	-- 		{type="inf2",n=1},
	-- 		-- 12 armor units, arty counts twice
	-- 		{type="arty",pos="0906"},
	-- 		{type="arty",pos="0907"},
	-- 		{type="arty",pos="0908"},
	-- 		{type="arty",pos="0909"},
	-- 		{type="arty",pos="0910"},
	-- 		{type="arty",pos="1008"}
	-- 	}
	-- },
	["mk3"]={
		max_center_strength=20,
		complete_victory_strength=30,
		units={
			{type="mk3",pos="2106"},
			{type="outpost",pos="0110"},
			-- 20 points of attack strength of infantry
			{type="inf3",n=6},
			{type="inf2",n=1},
			-- 12 armor units, arty counts twice
			{type="hovr",n=3},
			{type="hvy",n=3},
			{type="msl",n=2},
			{type="arty",n=2}
		}
	},
	["mk5"]={
		max_center_strength=40,
		complete_victory_strength=50,
		units={
			{type="mk5",pos="2106"},
			{type="outpost",pos="0110"},
			-- 30 points of attack strength of infantry
			{type="inf3",n=10},
			-- 20 armor units, arty counts twice
			{type="hovr",n=5},
			{type="hvy",n=5},
			{type="msl",n=4},
			{type="arty",n=3}
		}
	}
}

unit_types={
	["mk3"]={weapons={missile=2,primary=1,secondary=4,["anti-personnel"]=8},treads=45,move=3,allow_exits=true,ignore_ridges=true,pts=17,sid=21},
	["mk5"]={weapons={missile=6,primary=2,secondary=6,["anti-personnel"]=12},treads=60,move=3,allow_exits=true,ignore_ridges=true,pts=25,sid=21},
	["hovr"]={attack=2,range=2,defense=2,move=4,move2=3,pts=1,attack_val=100,sid=30},
	["hvy"]={attack=4,range=2,defense=3,move=3,pts=1,attack_val=100,sid=31},
	["msl"]={attack=3,range=4,defense=2,move=2,pts=1,attack_val=100,sid=32},
	["arty"]={attack=6,range=8,defense=1,move=0,pts=2,attack_val=200,sid=33},
	["inf1"]={attack=1,range=1,defense=1,move=2,ignore_ridges=true,attack_val=20,sid=34},
	["inf2"]={attack=2,range=1,defense=2,move=2,ignore_ridges=true,attack_val=40,sid=35},
	["inf3"]={attack=3,range=1,defense=3,move=2,ignore_ridges=true,attack_val=60,sid=36},
	["outpost"]={defense=0,move=0,pts=0,attack_val=255,sid=37}
}

tz_weapons={
	["primary"]={attack=4,range=3,defense=4},
	["secondary"]={attack=3,range=2,defense=3},
	["missile"]={attack=6,range=5,defense=3},
	["anti-personnel"]={attack=1,range=1,defense=1}
}

-->8
-- main hooks (74)

function new_game()
	cs,csn,c_subsystem,force_end_phase=nil,"",1,false
	cq,cr,other_cq,other_cr=5,20,7,6
	center_view(cr)
	new_state()
	selected_units,selected_uids,selected_target,selected_subsystem,movement,combat,scorecard={},{},nil,nil,nil,nil,nil
	change_state"move_select"
end

function _init()
	poke(0x5f2e,1) -- keep extended palette
	poke(0x5f5c,8) -- btnp initial delay
	poke(0x5f5d,2) -- btnp repeat delay
	-- srand(33)
	animate,ani_t,shake,maxq,maxr,viewh,viewedge=false,0,0,14,21,13,2
	config_scenario="mk3"
	init_board()
	new_game()
end
__gfx__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb0000000bbbbb7777777bbbbb5555555bbbbb7770777bbbbb0000000bbbbb5555550bbbbb5555555bbbbb5555555bbbbb5555555bbbbb0555555bbbbbbbbbb
bbb0bbbbb0bbbbb7bbbbb7bbbbb50b0b05bbbbb7bb0bb7bbbbb5bbbbb5bbbbb5bbbbb0bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb0bbbbb5bbbbbbbbbb
bb0bbbbbbb0bbb7bbbbbbb7bbb50b0b0b05bbb7bbbbbbb7bbb5bbbbbbb5bbb5bbbbbbb0bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb0bbbbbbb5bbbbbbbbb
bb0bbbbbbb0bbb7bbbbbbb7bbb5b0b0b0b5bbb7bbbbbbb7bbb5bbbbbbb5bbb5bbbbbbb0bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb0bbbbbbb5bbbbbbbbb
b0bbbbbbbbb0b7bbbbbbbbb7b5b0b0b0b0b5b7bbbb0bbbb7b5bbbbbbbbb5b5bbbbbbbbb0b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b0bbbbbbbbb5bbbbbbbb
b0bbbbbbbbb0b7bbbbbbbbb7b50b0b0b0b05b00bb0b0bb00b5bbbbbbbbb5b5bbbbbbbbb0b5bbbbbbbbb0b5bbbbbbbbb5b0bbbbbbbbb5b0bbbbbbbbb5bbbbbbbb
b0bbbbbbbbb0b7bbbbbbbbb7b5b0b0b0b0b5b7bbbb0bbbb7b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb0b5bbbbbbbbb5b0bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
bb0bbbbbbb0bbb7bbbbbbb7bbb5b0b0b0b5bbb7bbbbbbb7bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb0bbb5bbbbbbb5bbb0bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bb0bbbbbbb0bbb7bbbbbbb7bbb50b0b0b05bbb7bbbbbbb7bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb0bbb5bbbbbbb5bbb0bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bbb0bbbbb0bbbbb7bbbbb7bbbbb50b0b05bbbbb7bb0bb7bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb0bbbbb5bbbbb5bbbbb0bbbbb5bbbbb5bbbbb5bbbbbbbbbb
bbb0000000bbbbb7777777bbbbb5555555bbbbb7770777bbbbb5555555bbbbb5555555bbbbb5555550bbbbb0000000bbbbb0555555bbbbb5555555bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbbbbbbb
bbb5bbbbb5bbbbb5009a95bbbbb5442445bbbbb5442445bbbbb5442445bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbbbbbbb
bb5bb999bb5bbb500800095bbb544422245bbb544422245bbb5444d2265bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bb5bb909bb5bbb589900005bbb544244425bbb544247775bbb54415d625bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
b5b9990999b5b58009800005b52442444425b52442171715b524d5564425b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
b5b9090909b5b50000a98005b52224444425b52224777725b5276565d425b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
b5bb90009bb5b500000a9985b52442444425b52442717125b56615555125b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
bb5bb909bb5bbb580009005bbb544424422bbb544411125bbb51d155515bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bb5bbb9bbb5bbb589098005bbb524442245bbb524442245bbb521111145bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bbb5bbbbb5bbbbb5898005bbbbb5222245bbbbb5222445bbbbb5222445bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbbbbbbb
bbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb55dd655bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbbbbbbb
bbb5bbbbb5bbbb122221b5bbbbb5bbbbb5bbbbb5bb8bb5bbbb998666b5bbbbb5b5ddb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbbbbbbb
bb5bbbbbbb5bbb188887727bbb5bbbbbbb5bbb58966bb95bbb5add5db99bbb5bbb51bb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bb522222bb5bbb181288818bbb5b9bbb9b5bbb5aa669ab5bbb5665666a5bbb5d6bbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
b5b288888775b51888822125b5bbb99bbbb5b58baa9abbb5b5b66d6666b5b5b15bbbd6b5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
b5b181282885b5122221bbb5b5bb99a99bb5b5b667796685b58dd5666d95b5bbbbbb5db5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
b5b128882bb5b51111111115b5bbb99bbbb5b5bd6a66d6d5b585665ddbb5b5bbbdd6bbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
bb511212115bb12222222221bb5bbbb9bb5bbb5bda66dd5bbb5d6566ab5bbb5bb55dbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bb512222215bb12181818181bb5b9bbbbb5bbb589bddbb5bbb5bdd66985bbb5bbb15bb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bbb5111115bbbb122222221bbbb5bbbbb5bbbbb5bbbb85bbbbb5abbbb8bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbbbbbbb
bbb5555555bbbbb1111111bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5335555bbbbb1155555bbbbb5558855bbbbb5555555bbbbb5555555bbbbbbbbbb
bbb5bbbbb5bbbbb5bbbbb5bbbbb5bb3bb5bbbbb5bbbbb5bbbbb5bbbbb5bbbbb3cc3bb5bbbb1331bb33bbbbb5bb88b5bbbbb5bbbbb5bbbbb5bbbbb5bbbbbbbbbb
bb11bbbbbb5bbb5bbbbbbb5bbb5bb173bb5bbb5bbbbbbb5bbb5bbccbbb5bbb3cccc3bb5bb1333313cc3bbb133b1b133bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
b13c1317775bbb5111131b5bbb5b17c73b5bbb5bbbbbb77cbb5bc77cbb5bbb53cc3ccb5bbb13313cccc3bb3cc133cc3bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
b13cc1cc7771b5b1c33c1775b5b1cc71bbb5b5bbbbb77cc1b5bc7777cbb5b53c33c77cb5b1311cc3cc35b53ccccccc35b5bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
b1333333ccc1b5b1cccc1cc5b51c331bbbb5b5bbb77cc335b5bbc77cbbb5b5b3bc7777c5b51bc77c33c3b53ccccccc35b5bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
b51111111111b51333333115b5313113c7b5b5b33cc33bb5b5bc7cc7cbb5b5bbbbc77cb5b5bc7777cb35b51111111115b5bbbbbbbbb5b5bbbbbbbbb5bbbbbbbb
bb5bbbbbbb5bbb131c1c1c1bbb1113133c7bbb3cc33cc35bbb5bcbbcbb5bbb5bbc7cc7cbbb5bc77cbb5bbb513313315bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bb5bbbbbbb5bbb5133cc315bbb311131113bbb13ccccc35bbb5bbbbbbb5bbb5bbbcbbc5bbb5c7cc7cb5bbb51cc1cc15bbb5bbbbbbb5bbb5bbbbbbb5bbbbbbbbb
bbb5bbbbb5bbbbb5111115bbbbb111b111bbbbb1111111bbbbb5bbbbb5bbbbb5bbbbb5bbbbb5cbbcb5bbbbb1111111bbbbb5bbbbb5bbbbb5bbbbb5bbbbbbbbbb
bbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbb5555555bbbbbbbbbb
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
000100002501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080200002103021010290200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000d05007050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000306602b66024650206501c6501964016640116400e6400b64009630066200462002620016100061000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
