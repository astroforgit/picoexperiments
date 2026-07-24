pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
map_tiles_size = 32
tile_size = 8
dood_x_offset = 32
dood_regrow_x_offset = 64
ENTS = nil
EGGS = nil
CATEGORIES = {}
cat_counter = 0
spawn_x_offset = 64
screen_tiles = 16
tile_half = 4
map_pixels_size = map_tiles_size*tile_size
screen_pixels_size = screen_tiles*tile_size
screen_size = screen_tiles*tile_size
LOWEST = -32768

DEB ={}
log_list = {}
function LOG(cnt)
	add(log_list, cnt)
	deli(log_list, 10)
end

function add_category(cat)
	if not CATEGORIES[cat] then
		CATEGORIES[cat] = cat_counter
		cat_counter +=1
	end
end
NOSTEP = {
	category = "nostep"
}
add_category("nostep")
FX = {
	bite = {
		sprite = 49,
		length = 4,
	},
	spit = {
		sprite = 53,
		length = 4,
	},
	forage = {
		sprite = 57,
		length = 5,
		duration = 2,
	},
	impact = {
		sprite = 112,
		length = 4,
		duration = 0.5,
	},
	tranq = {
		sprite = 117,
		length = 3,
	},
	pool = {
		sprite = 120,
		length = 4,
		duration = 20,
	},
	splat = {
		sprite = 104,
		length = 4,
		duration = 2,
	}
}
for i,def in pairs(FX) do
	def.duration = def.duration or 1
end
RAY = {
	spit = {
		colors = {11,10,3,2},
		duration = 1,
	},
	bullet = {
		colors = {7,13,12},
		duration = 0.25,
	},
	tranq = {
		colors = {15,14,2,1},
		duration = 0.25,
	},
	sense = {
		colors = {15,14,2,1},
		duration = 2,
	}
}
for i,def in pairs(RAY) do
	def.num_colors = #def.colors
end
DOODADS = {
	foilage_sparse = {		
		sprites = {134},
		energy = 40,
		category = "plants",
	},
	foilage_dense = {
		sprites = {133,160,142,143,158,159,174,175,182},
		energy = 90,
		category = "plants",
	},
	vegetation_plain = {
		sprites = {128,129,144},
		energy = 120,
		category = "plants",
	},
	vegetation_huge = {
		sprites = {130,131,146,147,162,163,178,179},
		energy = 350,
		category = "plants",
	},
	vegetation_fruity = {
		sprites = {145,161,177,176},
		energy = 180,
		category = "plants",
	}
}
local tmp = {}
for i,def in pairs(DOODADS) do
	def.name = i
	for _,id in pairs(def.sprites) do
		tmp[id] = def
	end
	add_category(def.category)
end
for spri,def in pairs(tmp) do
	DOODADS[spri] = def
end


function plot_heal(x,y,c)
	pset(x,y,((c%2)==0) and 11 or 13)
end
function plot_hurt(x,y,c)
	pset(x,y,((c%2)==0) and 8 or 9)
end
function plot_drain(x,y,c)
	pset(x,y,((c%2)==0) and 10 or 11)
end
function plot_sprite(x,y,c)
	pset(x,y,c)
end
function plot_dark(x,y,c)
	pset(x,y,((c%2)==0) and 2 or 3)
end
function plot_shadow(x,y,c)
	pset(x+1,y+1,0)
end
function rspr(sprite_id,x,y,a,w,plot_method)
	local sx = (sprite_id % 16) * tile_size
	local sy = flr(sprite_id / 16) * tile_size
	local ca,sa=cos(a),sin(a)
	local srcx,srcy
	local ddx0,ddy0=ca,sa
	local mask=shl(0xfff8,(w-1))
	w*=4
	ca*=w-0.5
	sa*=w-0.5
	local dx0,dy0=sa-ca+w,-ca-sa+w
	w=2*w-1
	for ix=0,w do
		srcx,srcy=dx0,dy0
		for iy=0,w do
			if band(bor(srcx,srcy),mask)==0 then
				local c=sget(sx+srcx,sy+srcy)
				if c ~= 0 then
					plot_method(x+ix,y+iy,c)
				end
			end
			srcx-=ddy0
			srcy+=ddx0
		end
		dx0+=ddx0
		dy0+=ddy0
	end
end

poke(0x5f2e,1)
for i,c in pairs({0,128,130,133,5,134,6,7,136,8,139,11,10,135,140,12}) do
 pal(i-1, c, 1)
end

function tile_on_screen(tx,ty)
	return not (tx < ctx-1 or tx > ctx + screen_tiles or ty < cty-1 or ty > cty + screen_tiles)
end
channel = 0
function sfx_on_screen(x,y,s)
	if FAST then return end
	if tile_on_screen(x,y) then
		sfx(s,channel)
		channel=(channel+1)%4		
	end
end

LOS_BLOCK_FLAG = 4
function _in_bounds(x,y)
	if x < 0 or y < 0 or x > map_tiles_size-1 or y > map_tiles_size-1 then
		return false
	end
	return true
end
function _los_blocked(x,y)
	if x <= 0 or y <= 0 or x >= map_tiles_size-1 or y >= map_tiles_size-1 then
		return true
	end
	return fget(mget(x+dood_x_offset,y),LOS_BLOCK_FLAG)
end
function _get_ent_forwards(ent,offset)
	local offset = offset or 1
	local dx,dy = angle_delta(ent.angle[1])
	local ix,iy = offset*dx+ent.x[1],offset*dy+ent.y[1]
	if _in_bounds(ix,iy) then
		return ent_lookup[ix][iy],ix,iy
	else
		return nil,ix,iy
	end
end
function _get_first_ent_forwards_range(ent,range)
	local dx,dy = angle_delta(ent.angle[1])
	local x,y = ent.x[1],ent.y[1]
	local sx,sy =x+dx, y+dy
	for i=1,range do
		local ix,iy = x+dx*i, y+dy*i
		local target = ent_lookup[ix][iy]
		if target then
			return target,ix,iy,sx,sy
		end
		if _los_blocked(ix,iy) then
			return nil,ix,iy,sx,sy
		end
	end
	return nil,x+dx*range, y+dy*range,sx,sy
end
function _get_doodad(x,y)
	return mget(x+dood_x_offset,y)	
end

function ent_generation(ent,gen)
	ent.generation = gen
	ent.gen_text = "gen"..gen
end
DOOD_REGROW_TICKS = 1000
function _doodad_passes(dood,mask)
	return (fget(dood) & mask) ~= 0
end
function _can_consume_doodad(x,y,mask)
	local dood = _get_doodad(x,y)
	local dood_def = DOODADS[dood]
	return dood_def and _doodad_passes(dood, mask)
end

function _consume_doodad(x,y, mask)
	local dood = _get_doodad(x,y)
	local dood_def = DOODADS[dood]
	if dood_def and _doodad_passes(dood, mask) then
		dood_regrow[x][y] = frame+DOOD_REGROW_TICKS
		mset(x+dood_regrow_x_offset,y,dood)
		mset(x+dood_x_offset,y,0)
		return dood,dood_def
	end
	return nil
end
function _regrow_doodad(x,y)
	mset(x+dood_x_offset,y,mget(x+dood_regrow_x_offset,y))
	dood_regrow[x][y] = nil
end

function rnd_offset(x,y,size)
	return mid(x+flr(rnd(size*2+1))-size,0,map_tiles_size-1),mid(y+flr(rnd(size*2+1))-size,0,map_tiles_size-1)
end

function bloody_segment(ent,x,y,i)
	for s=1,9 do
		local ox,oy = rnd_offset(x,y,flr(s/3)+1)
		add_fx(FX.splat,ox,oy,s/3+i-1.33)
	end		
	local ox,oy = rnd_offset(x,y,1)
	add_fx(FX.pool,ox,oy,i)
	add_fx(FX.pool,x,y)
end
EXTINCT_RESPAWN_DELAY = 3000
function remove_ent(ent)
	del(ents, ent)
	del(animated_ents, ent)
	del(ai_tick_ents, ent)
	del(post_tick_ents, ent)
	ent_counts[ent.def] -= 1
	del(ents_by_def[ent.def], ent)
	if ent_counts[ent.def] <= 0 and ent.def.spawn_points then
		ent_extinct_frame[ent.def] = frame + EXTINCT_RESPAWN_DELAY
	end
	for i=1,ent.def.segs do
		local x,y = ent.x[i],ent.y[i]
		ent_lookup[x][y] = nil
		add_corpse(ent.def.corpse[i],x,y,ent.angle[i])

		local rem = ent.def.on_removed_segment
		if rem then
			rem(ent,x,y,i)
		end		
	end	
end
function hurt_health(ent,damage)
	assert(damage >= 0)
	local shealth = ent.health
	ent.health = max(ent.health-damage,0)
	ent.hurt_frame = frame
	if ent.health <= 0 then
		remove_ent(ent)
		if ent == locked then
			locked = ents[flr(rnd(#ents))+1]
			selected = locked
		end
		sfx_on_screen(ent.x[1], ent.y[1], 3)
	end
	return ent.health-shealth
end
function gain_health(ent,healing)
	assert(healing >= 0)
	if ent.health < ent.def.health then
		ent.health = min(ent.health+healing,ent.def.health)
		ent.heal_frame = frame
		return true
	end
end
function hurt_energy(ent,drain)
	assert(drain >= 0)
	local drained = min(ent.energy,drain)
	ent.energy -= drained
	ent.drain_frame = frame
	return -drained
end
function modify_energy(ent,amt)
	if amt > 0 then gain_energy(ent, amt) else hurt_energy(ent, -amt) end
end

ENERGY_PER_REGENERATION = 100
function gain_energy(ent,gained)	
	assert(gained >= 0)
	ent.energy = ent.energy+gained
	local above_max = max(0,ent.energy-ent.def.energy)
	if above_max > 0 then
		ent.energy -= above_max
		gain_health(ent, above_max/ENERGY_PER_REGENERATION)
	end
end
function consume_energy(ent,consumed)
	assert(consumed >= 0)
	if ent.energy >= consumed then
		ent.energy = max(ent.energy-consumed,0)
		return true
	end
end
function add_fx(def,x,y,frame_offset)
	if not ULTRAFAST then
		fx_lookup[x][y] = {
			def = def,
			frame = frame + (frame_offset or 0),
		}
	end
end
function add_ray(def, x,y,x2,y2)
	if not ULTRAFAST then
		add(rays, {
			x=x,
			y=y,
			x2=x2,
			y2=y2,
			def = def,
			frame = frame,
		})
	end
end
function add_corpse(sprite, x,y,angle)	
	corpse_lookup[x][y] = {
		angle = angle,
		sprite = sprite,
		frame = frame,
	}	
end

function _can_step(ent,x,y)
	local walkable = ent.def.walkable
	if ent_lookup[x][y] then
		return false
	end
	local dood = mget(x+dood_x_offset,y)
	if fget(dood, 5) then
		return (walkable & fget(dood)) ~= 0			
	end
	return (walkable & fget(mget(x,y))) ~= 0
end

function _can_step_forward_in_angle(ent, deltaa)
	local dx,dy = angle_delta(ent.angle[1]+deltaa)
	local x,y = ent.x[1]+dx,ent.y[1]+dy
	return _can_step(ent,x,y)
end

function _get_backward_in_angle(ent,deltaa)
	local segs = ent.def.segs
	local dx,dy = angle_delta(ent.angle[segs]+deltaa)
	return ent.x[segs]+dx,ent.y[segs]+dy
end

function _can_step_backward_in_angle(ent, deltaa)	
	local x,y = _get_backward_in_angle(ent, deltaa)
	return _can_step(ent,x,y)
end

function _move_ent_head(ent,dx,dy)
	local xs,ys = ent.x,ent.y
	local x,y = xs[1]+dx,ys[1]+dy
	if _can_step(ent, x,y) then
		local segs = ent.def.segs

		ent_lookup[xs[segs]][ys[segs]] = nil

		for s=segs+1,2,-1 do
			xs[s] = xs[s-1]
			ys[s] = ys[s-1]
		end

		xs[1] = x
		ys[1] = y
		ent_lookup[x][y] = ent

		ent.move_frame = frame
		ent.move_forwards = true
		return true
	end
end

function _move_ent_rear(ent,dx,dy)
	local xs,ys = ent.x,ent.y
	local segs = ent.def.segs
	local x,y = xs[segs]+dx,ys[segs]+dy
	if _can_step(ent, x,y) then
		ent_lookup[xs[1]][ys[1]] = nil

		for s=0,segs-1 do
			xs[s] = xs[s+1]
			ys[s] = ys[s+1]
		end
		xs[segs] = x
		ys[segs] = y
		ent_lookup[x][y] = ent

		ent.move_frame = frame
		ent.move_forwards = false
		return true
	end
end

function angle_delta(a)
	return flr(cos(a)),-flr(sin(a))
end

function _rotate_ent_head(ent,deltaa)
	local angles = ent.angle
	local a = angles[1]+deltaa

	for s=ent.def.segs+1,2,-1 do
		angles[s] = angles[s-1]
	end
	angles[1] = a

	ent.rotate_frame = frame
	ent.rotate_forwards = true
end

function _rotate_ent_rear(ent,deltaa)
	local angles = ent.angle
	local segs = ent.def.segs
	local a = angles[segs]+deltaa
	for s=0,segs-1 do
		angles[s] = angles[s+1]
	end
	angles[segs] = a

	ent.rotate_frame = frame
	ent.rotate_forwards = false
end

function _step_forwards(ent)
	return _move_ent_head(ent, angle_delta(ent.angle[1]))
end

function _step_backwards(ent)
	return _move_ent_rear(ent, angle_delta(ent.angle[ent.def.segs]+0.5))
end

function get_cost_segs(ent)
	return ent.def.segs
end

function get_inheritance_fraction(ent)
	return 1.0 - 0.5/ent.generation
end

function copy_network_weights_to(froment, toent, fraction)
	assert(froment)
	assert(toent)
	assert(froment.network)
	assert(toent.network)
	assert(froment.network.def == toent.network.def)
	local ifraction = 1-fraction
	for i,layer in ipairs(froment.network.layers) do
		local to_layer = toent.network.layers[i]
		assert(to_layer)
		for n,neuron in pairs(layer.neurons) do
			local to_neuron = to_layer.neurons[n]
			assert(to_neuron)
			to_neuron.bias = to_neuron.bias*ifraction + neuron.bias*fraction
			for u,w in pairs(neuron.weights) do
				assert(u)
				assert(w)
				assert(fraction)
				to_neuron.weights[u] = to_neuron.weights[u]*ifraction + w*fraction
			end
		end
	end
end

move_forwards = {
	weight_bias = 1,
	cost = get_cost_segs,
	valid = function(ent)
		return _can_step_forward_in_angle(ent,0)
	end,
	execute = function(ent)
		_step_forwards(ent)
		_rotate_ent_head(ent, 0)
	end,
}

move_backwards = {
	weight_bias = -0.5,
	cost = get_cost_segs,
	valid = function(ent)
		return _can_step_backward_in_angle(ent,0.5)
	end,
	execute = function(ent)
		_step_backwards(ent)
		_rotate_ent_rear(ent, 0)
	end
}

function get_cost_low(ent)
	return 0.25
end

rotate_left = {
	cost = get_cost_low,
	execute = function(ent)
		_rotate_ent_head(ent, -0.25)
	end
}

rotate_right = {
	cost = get_cost_low,
	execute = function(ent)
		_rotate_ent_head(ent, 0.25)
	end
}

rotate_move_left = {
	cost = get_cost_low,
	valid = function(ent)
		return _can_step_forward_in_angle(ent,-0.25)
	end,
	execute = function(ent)
		rotate_left.execute(ent)
		_step_forwards(ent)	
	end
}

rotate_move_right = {
	cost = get_cost_low,
	valid = function(ent)
		return _can_step_forward_in_angle(ent,0.25)
	end,
	execute = function(ent)
		rotate_right.execute(ent)
		_step_forwards(ent)	
	end
}

function get_cost_default(ent)
	return 1
end

MEAT_ENERGY_VALUE_PER_HEALTH = 3
bite_forwards = {
	weight_bias = 1,
	cost = get_cost_default,
	valid = _get_ent_forwards,
	sound = 2,
	execute = function(ent)
		local target,x,y = _get_ent_forwards(ent)
		add_fx(FX.bite, x,y)
		if target then
			gain_energy(ent, -hurt_health(target, ent.def.damage)*MEAT_ENERGY_VALUE_PER_HEALTH)			
		end
		ent.ability_frame = frame
	end
}
SPIT_GAIN_FRACTION = 0.75
spit_forwards = {
	cost = get_cost_default,
	valid = function(ent)
		return _get_ent_forwards(ent, 3)
	end,
	sound = 12,
	execute = function(ent)
		local target,x,y,sx,sy = _get_first_ent_forwards_range(ent,3)
		add_ray(RAY.spit, sx,sy,x,y)
		add_fx(FX.spit, x,y)
		if target then
			local drain = ent.def.drain
			gain_energy(target, -hurt_energy(target, drain)*SPIT_GAIN_FRACTION)
		end		
		ent.ability_frame = frame
	end
}


forage_under = {
	cost = get_cost_default,
	weight_bias = 1,
	valid = function(ent)
		return _can_consume_doodad(ent.x[1], ent.y[1],ent.def.reachable)
	end,
	sound = 1,
	execute = function(ent)
		local x,y = ent.x[1], ent.y[1]
		local consumed_doodad,doodad_def = _consume_doodad(x,y,ent.def.reachable)
		if consumed_doodad then			
			gain_energy(ent, doodad_def.energy)
			add_fx(FX.forage,x,y)			
		end
		ent.ability_frame = frame
	end
}

SHOT_ENERGY = {	
	herbi = 1.5,
	carni = 2.5,	
}
shoot_forwards = {
	cost = get_cost_default,
	weight_bias = 1,
	valid = function(ent)
		local target = _get_first_ent_forwards_range(ent,6)
		if target and SHOT_ENERGY[target.def.category] then
			return true
		end
	end,
	sound = 5,
	execute = function(ent)	
		local target,x,y,sx,sy = _get_first_ent_forwards_range(ent,6)
		add_fx(FX.impact,x,y)
		add_ray(RAY.bullet,sx,sy,x,y)
		if target then
			local amount = hurt_health(target, ent.def.damage)			
			modify_energy(ent, (SHOT_ENERGY[target.def.category] or 0) * -amount)
		end		
		ent.ability_frame = frame
	end
}

EGG_ENERGY_FRACTION_COST = 0.75
egg_backwards = {	
	cost = function(ent)
		return ent.def.energy*EGG_ENERGY_FRACTION_COST
	end,
	valid = function(ent)
		return _can_step_backward_in_angle(ent,0.5)
	end,
	sound = 4,
	execute = function(ent)
		local x,y = _get_backward_in_angle(ent,0.5)
		local added = add_ent(ent.def.eggdef,x,y)
		ent_generation(added, ent.generation+1)		
		added.parent_ent = ent
		ent.ability_frame = frame		
	end
}


DUPLICATE_LOCK_DURATION = 150
duplicate = {	
	cost = function(ent)
		return ent.def.energy*EGG_ENERGY_FRACTION_COST
	end,
	valid = function(ent)
		return _can_step(ent,ent.spawn_x,ent.spawn_y)
	end,
	sound = 11,
	execute = function(ent)
		local added = add_ent(ent.def,ent.spawn_x,ent.spawn_y)

		copy_network_weights_to(ent, added, get_inheritance_fraction(ent))
		ent_generation(added, ent.generation+1)	
		added.locked_until_frame = frame + DUPLICATE_LOCK_DURATION		
	end
}

kick_forwards = {
	weight_bias = 0.5,
	cost = get_cost_default,
	valid = function(ent)
		local target = _get_ent_forwards(ent)
		if target and target.def.category == "carni" then
			return true
		end
	end,
	sound = 10,
	execute = function(ent)
		ent.ability_frame = frame
		local target = _get_ent_forwards(ent)
		if target then
			hurt_health(target, ent.def.damage)
			modify_energy(ent, 100)			
		end
	end
}



FILM_CAT_ENERGY = {
	friendly = 10,
	hostile = 50,
	carni = 200,
	herbi = 100,
	egg = 50,
}
film_forwards = {
	weight_bias = 0.5,
	cost = get_cost_default,
	valid = function(ent)
		local target = _get_first_ent_forwards_range(ent,4)
		if target and (not ent.filmed or not ent.filmed[target.def]) then
			return true
		end
	end,
	sound = 9,
	execute = function(ent)
		ent.ability_frame = frame
		ent.filmed = ent.filmed or {}
		local target,x,y,sx,sy = _get_first_ent_forwards_range(ent,4)
		if target then
			ent.filmed[target.def] = true
			gain_energy(ent, FILM_CAT_ENERGY[target.def.category] or 10)			
		end
		add_ray(RAY.sense,sx,sy,x,y)
	end
}

OBSERVE_ENERGY = {
	egg = 4,
	herbi = 8,
	carni = 20,
}
OBSERVE_GAIN_FRACTION = 2
OBSERVE_COOLDOWN = 200
observe_forwards = {
	weight_bias = 0.5,
	cost = get_cost_default,
	valid = function(ent)
		local target = _get_first_ent_forwards_range(ent,6)
		if target and OBSERVE_ENERGY[target.def.category] and (not target.observed_frame or (target.observed_frame < frame -OBSERVE_COOLDOWN)) then
			return true
		end
	end,
	sound = 8,
	execute = function(ent)
		ent.ability_frame = frame
		local target,x,y,sx,sy = _get_first_ent_forwards_range(ent,6)
		if target then
			target.observed_frame = frame
			local observe = OBSERVE_ENERGY[target.def.category]*ent.def.observe_power
			gain_energy(ent, -hurt_energy(ent, observe)*OBSERVE_GAIN_FRACTION)			
		end
		add_ray(RAY.sense,sx,sy,x,y)
	end
}

treat_forwards = {
	weight_bias = 0.5,
	cost = get_cost_default,
	valid = function(ent)
		local target = _get_ent_forwards(ent)
		if target and target.def ~= ent.def and target.health < target.def.health then
			return true
		end
	end,
	sound = 7,
	execute = function(ent)
		ent.ability_frame = frame
		local target,x,y = _get_ent_forwards(ent)
		if target then
			if gain_health(target, 10) then
				gain_energy(target, 10)
				gain_energy(ent, 50)			
			end
		end
	end
}

DRAIN_GAIN_FRACTION = 0.5
tranq_forwards = {
	weight_bias = 0.5,
	cost = get_cost_default,
	valid = function(ent)
		local target = _get_first_ent_forwards_range(ent,5)
		if target and target.def.category == "carni" then
			return true
		end
	end,
	sound = 6,
	execute = function(ent)
		local target,x,y,sx,sy = _get_first_ent_forwards_range(ent,5)
		add_ray(RAY.tranq, sx,sy,x,y)
		add_fx(FX.tranq, x,y)
		if target then
			local drain = ent.def.drain			
			gain_energy(ent, -hurt_energy(target, drain)*DRAIN_GAIN_FRACTION)
		end		
		ent.ability_frame = frame
	end
}

local E = 2.7182
function sigmoid(val)
	return 1.0 / (1.0 + E^-val)
end
function sum_neuron(neuron, src)
	local sum = 0
	for i,w in pairs(neuron.weights) do
		sum += src[i]*w
	end
	return sigmoid(sum + neuron.bias)
end
function tick_network(network)
	for i=1,network.def.num_inputs do
		network.inputs[i] = network.def.inputs[i](network, network.inputs[i] or 0)
	end	
	for i,layer in ipairs(network.layers) do
		for ni, neuron in ipairs(layer.neurons) do
			layer[ni] = sum_neuron(neuron, layer.source)
		end
	end
end

work_table = {}
function weighted_executable_action(ent)
	local outputs = ent.network.outputs		
	local total_score = 0
	for i,action in pairs(ent.def.actions) do
		local score = outputs[i] or 0
		if not action.valid or action.valid(ent) then
			if action.cost(ent) <= ent.energy then
				work_table[i] = score
				total_score += score
			end
		end
	end

	local roll = rnd()*total_score
	local selected = nil
	for action, score in pairs(work_table) do
		roll -= score
		if not selected and roll <= 0 then
			selected = action
		end
		work_table[action] = nil
	end
	return selected
end

function tick_ai(ent)
	tick_network(ent.network)
	ent.action = weighted_executable_action(ent)
end

function ent_sense_offsets(ent,sense)
	local angle = ent.angle[1] + sense.angle
	local ox,oy = cos(angle),-sin(angle)
	local x,y = ent.x[1], ent.y[1]
	if sense.slide then
		local slide_angle = angle+0.25
		x+=cos(slide_angle)*sense.slide
		y-=sin(slide_angle)*sense.slide
	end
	assert(flr(x) == x)
	assert(flr(y) == y)
	return x,y,ox,oy
end

function tick_senses(ent)
	for i,sense in pairs(ent.def.senses) do
		local sense_data = ent.senses[i]
		local x,y,ox,oy = ent_sense_offsets(ent,sense)
		local blocked = false
		for dist=sense.start,sense.target do
			local detection = nil
			if not blocked then
				local sx,sy = x+ox*dist,y+oy*dist
				local found_ent = ent_lookup[sx][sy]
				local is_other = found_ent ~= ent
				if found_ent and is_other then
					detection = found_ent.def
				else
					local dood = _get_doodad(sx,sy)
					if dood and (not ent.def.reachable or _doodad_passes(dood, ent.def.reachable)) then
						detection = DOODADS[dood]					
					end
				end
				if not detection and is_other and not _can_step(ent,sx,sy) then
					detection = NOSTEP
				end
				if found_ent ~= ent and _los_blocked(sx,sy) then
					blocked = true
				end			

			end


			sense_data[dist] = detection
			--if offi == sense.target then
			--	add_ray(RAY.sense,x,y,sx,sy)
			--end
		end
	end
end

function get_sense_predicate_proximity(ent, sense_index, predicate)
	local sense_def = ent.def.senses[sense_index]
	local sense_data = ent.senses[sense_index]
	local target = sense_def.target
	for dist=sense_def.start, target do
		local sensed = sense_data[dist]
		if sensed and predicate(sensed) then
			return target+1-dist
		end
	end
	return 0
end

function default_ent_post_tick(ent)
	tick_senses(ent)
end


HEALTH_ENERGY_MULTIPLIER = 2
function default_ent_tick(ent)
	if ent.locked_until_frame then
		if ent.locked_until_frame == frame then
			ent.locked_until_frame = nil
		end
		return 
	end
	if not consume_energy(ent, IDLE_ENERGY_COST) then
		hurt_health(ent, 1)	
	end
	local action = ent.def.actions[ent.action]
	if action then
		local valid,a,b = not action.valid or action.valid(ent)
		if valid then
			if consume_energy(ent, action.cost(ent)) then
				action.execute(ent,a,b)
				if action.sound then sfx_on_screen(ent.x[1], ent.y[1], action.sound) end
			end
		end	
	end
	if ent.energy <= ent.def.critical_energy and ent.health > 0 then
		gain_energy(ent,-hurt_health(ent, 1)*HEALTH_ENERGY_MULTIPLIER)		
	end
end

function egg_ent_tick(ent)
	gain_energy(ent,1)
	if ent.energy >= ent.def.energy then	
		sfx_on_screen(ent.x[1], ent.y[1], 0)
		remove_ent(ent)
		local added = add_ent(ENTS[ent.def.ent], ent.x[1], ent.y[1])
		added.health = added.def.health * (ent.health / ent.def.health)
		copy_network_weights_to(ent.parent_ent, added, get_inheritance_fraction(ent.parent_ent))
		ent_generation(added, ent.generation)		
		if locked == ent then
			locked = added
			selected = locked
		end
	end
end


senses_herbi = {
	{target = 2, angle = 0.25},
	{target = 2, angle = -0.25},
	{start = 0, target = 1, angle = 0},
}

senses_carni = {
	{target = 3, angle = 0},
	{target = 1, angle = 0, slide = 1},
	{target = 1, angle = 0, slide = -1},
}

senses_human = {
	{target = 5, angle = 0},
	{target = 1, angle = 0.25},
	{target = 1, angle = -0.25},	
}

EGGS = {
	carni1_egg = {
		name = "raptor egg",
		health = 100,
		sprite = 12,
		ent = "carni1",
		tick = egg_ent_tick,
		energy = 500,
		corpse = {62},
	},
	carni2_egg = {
		name = "t-rex egg",
		health = 200,
		sprite = 28,
		ent = "carni2",
		tick = egg_ent_tick,
		energy = 1000,
		corpse = {63},
	},
	carni3_egg = {
		name = "dilophosaurus egg",
		health = 50,
		sprite = 44,
		ent = "carni3",
		tick = egg_ent_tick,
		energy = 250,
		corpse = {62},
	},
	herbi1_egg = {
		name = "stegosaurus egg",
		health = 100,
		sprite = 13,
		ent = "herbi1",
		tick = egg_ent_tick,
		energy = 400,
		corpse = {63},
	},
	herbi2_egg = {
		name = "moschops egg",
		health = 50,
		sprite = 29,
		ent = "herbi2",
		tick = egg_ent_tick,
		energy = 100,
		corpse = {62},
	},
	herbi3_egg = {
		name = "diplodocus egg",
		health = 200,
		sprite = 45,
		ent = "herbi3",
		tick = egg_ent_tick,
		energy = 600,
		corpse = {63},
	},
}
for id,def in pairs(EGGS) do	
	def.segs = 1	
	def.start_energy = 1
	def.category = "egg"
	add_category(def.category)
end


ENTS = {
	carni1 = {
		name = "raptor",
		health = 300,
		damage = 75,
		anim_speed = 4,
		walk = {2,18},
		ability = 34,
		actions = {
			move_forwards, rotate_left, rotate_right, bite_forwards, egg_backwards,
		},
		corpse = {31},
		eggdef = EGGS.carni1_egg,
		senses = senses_carni,
		category = "carni",
	},
	carni2 = {
		name = "t-rex",
		health = 1000,
		damage = 300,
		anim_speed = 2,
		walk = {3,19},
		ability = 35,
		segs = 2,
		actions = {
			move_forwards, move_backwards, rotate_move_left, rotate_move_right, bite_forwards, egg_backwards
		},
		corpse = {47,14},
		eggdef = EGGS.carni2_egg,
		senses = senses_carni,
		category = "carni",
	},
	carni3 = {
		name = "dilophosaurus",
		health = 125,
		damage = 50,
		drain = 400,
		anim_speed = 4,
		walk = {5,21},
		ability = 37,
		actions = {
			move_forwards, rotate_left, rotate_right, bite_forwards, spit_forwards, egg_backwards
		},
		corpse = {46},
		eggdef = EGGS.carni3_egg,
		senses = senses_carni,
		category = "carni",
	},
	herbi1 = {
		name = "stegosaurus",
		health = 500,
		anim_speed = 2,
		walk = {6,22},
		ability = 38,
		segs = 2,
		reachable = 0b00000011,
		actions = {
			move_forwards, move_backwards, rotate_move_left, rotate_move_right, forage_under, egg_backwards
		},
		corpse = {15,14},
		eggdef = EGGS.herbi1_egg,
		senses = senses_herbi,
		category = "herbi",
	},
	herbi2 = {
		name = "moschops",
		health = 200,
		anim_speed = 4,
		walk = {8,24},
		ability = 40,
		reachable = 0b00000001,
		actions = {
			move_forwards, rotate_left, rotate_right, forage_under, egg_backwards
		},
		corpse = {31},
		eggdef = EGGS.herbi2_egg,
		senses = senses_herbi,
		category = "herbi",
	},
	herbi3 = {
		name = "diplodocus",
		health = 2000,
		anim_speed = 2,
		walk = {9,25},
		ability = 41,
		segs = 3,
		reachable = 0b00000110,
		actions = {
			move_forwards, move_backwards, rotate_move_left, rotate_move_right, forage_under, egg_backwards
		},
		corpse = {15,30,14},
		eggdef = EGGS.herbi3_egg,
		senses = senses_herbi,
		category = "herbi",
	},
	hunter = {
		name = "hunter",
		health = 100,
		damage = 40,
		anim_speed = 4,
		walk = {64,80},
		ability = 96,
		actions = {
			move_forwards, move_backwards, rotate_left, rotate_right, shoot_forwards, duplicate
		},
		corpse = {102},
		senses = senses_human,
		category = "hostile",
	},
	girl = {
		name = "girl",
		health = 100,
		damage = 5,
		anim_speed = 4,
		walk = {65,81},
		ability = 97,
		actions = {
			move_forwards, rotate_left, rotate_right, kick_forwards, duplicate
		},
		corpse = {102},
		senses = senses_human,
		category = "friendly",
	},
	cameraman = {
		name = "cameraman",
		health = 100,
		anim_speed = 4,
		walk = {66,82},
		ability = 98,
		actions = {
			move_forwards, rotate_left, rotate_right, film_forwards, duplicate
		},
		corpse = {102},
		senses = senses_human,
		category = "friendly",
	},
	paleontologist = {
		name = "paleontologist",
		health = 100,
		anim_speed = 4,
		walk = {67,83},
		ability = 99,
		observe_power = 10,
		actions = {
			move_forwards, rotate_left, rotate_right, observe_forwards, duplicate
		},
		corpse = {102},
		senses = senses_human,
		category = "friendly",
	},
	biologist = {
		name = "biologist",
		health = 100,
		damage = 5,
		anim_speed = 4,
		walk = {68,84},
		ability = 100,
		actions = {
			move_forwards, rotate_left, rotate_right, treat_forwards, duplicate
		},
		corpse = {102},
		senses = senses_human,
		category = "friendly",
	},
	tranqman = {
		name = "tranquilizer",
		health = 100,
		drain = 250,		
		anim_speed = 4,
		walk = {69,85},
		ability = 101,
		actions = {
			move_forwards, rotate_left, rotate_right, tranq_forwards, duplicate
		},
		corpse = {102},
		senses = senses_human,
		category = "hostile",
	},
	jeep = {
		name = "park jeep",
		health = 500,
		walk = {70},
		ability = 70,
		segs = 2,
		rigid = true,
		observe_power = 20,
		actions = {
			move_forwards, move_backwards, rotate_move_left, rotate_move_right, observe_forwards, duplicate
		},
		walkable = 0b01000000,
		corpse = {103,103},
		senses = senses_human,
		category = "friendly",
	},
	wrangler = {
		name = "hunter wrangler",
		health = 500,
		walk = {86},
		ability = 86,
		segs = 2,
		rigid = true,
		damage = 40,
		actions = {
			move_forwards, move_backwards, rotate_move_left, rotate_move_right, shoot_forwards, duplicate
		},
		walkable = 0b01000000,
		corpse = {103,103},
		senses = senses_human,
		category = "hostile",
	},
}
IDLE_ENERGY_COST = 0.5
SPAWN = {}
for id,def in pairs(ENTS) do
	local segs = def.segs or 1
	SPAWN[def.sprite or (def.walk[1]+segs-1)] = def	
	def.on_removed_segment = bloody_segment
	def.tick = default_ent_tick
	def.post_tick = default_ent_post_tick
	def.segs = segs
	def.num_actions = def.actions and #def.actions
	def.num_walk = def.walk and #def.walk
	def.walkable = def.walkable or 0b11000000
	def.anim_speed = def.anim_speed or 1
	def.damage = def.damage or 1
	def.energy = def.energy or def.health * 5
	def.start_energy = def.energy*0.5
	def.critical_energy = segs + IDLE_ENERGY_COST
	for i,v in pairs(def.senses) do
		v.start = v.start or 1
	end
	add_category(def.category)

	def.spawn_points = {}
	for x=0,map_tiles_size-1 do		
		for y=0,map_tiles_size-1 do
			local tile = mget(x+spawn_x_offset,y)
			local spawn_def = SPAWN[tile]
			if spawn_def == def then
				add(def.spawn_points, {x,y})				
			end
		end
	end
end


NETDEF_BUILDERS = {
	add_action_memory = function(self, action, decay)		
		add(self.inputs, function(net, last)
			if net.ent.action == action then
				return 1
			else
				return last * decay
			end
		end)
		add(self.debug, "a")
		return self
	end,
	add_fraction_layer = function(self, key)		
		add(self.inputs, function(net, last)
			local ent = net.ent
			return ent[key] / ent.def[key]
		end)
		add(self.debug, "f")
		return self
	end,
	add_sense_index_category_proximity = function(self, sense_index, category, decay)
		local function compare(def)
			return def.category == category			
		end
		add(self.inputs, function(net, last)
			return max(get_sense_predicate_proximity(net.ent, sense_index, compare), last*decay)
		end)
		add(self.debug, sub(category,1,2))
		return self
	end,
	add_sense_index_def_proximity = function(self, sense_index, validdef, decay)
		local function compare(def)
			return (def == validdef) or (validdef.eggdef == def)
		end
		add(self.inputs, function(net, last)
			return max(get_sense_predicate_proximity(net.ent, sense_index, compare), last*decay)
		end)
		add(self.debug, "*")
		return self
	end,	
	add_hidden_layer = function(self, layer_size)
		add(self.layers, layer_size)
		return self
	end,
	add_output_layer = function(self, layer_size, rnd_bias)
		add(self.layers, layer_size)
		self.layers_rnd[#self.layers] = rnd_bias
		return self
	end,
}
NETDEF_META = {__index = NETDEF_BUILDERS}

function net_def()
	return setmetatable({inputs = {}, layers = {}, debug = {}, layers_rnd = {}}, NETDEF_META)
end


NETS = {}
for id, entdef in pairs(ENTS) do
	local net = net_def()
	for action_id=1, entdef.num_actions do
		net:add_action_memory(action_id, 0.9)
	end
	net:add_fraction_layer("health")
	net:add_fraction_layer("energy")
	for category, _ in pairs(CATEGORIES) do
		for sense_index,_ in ipairs(entdef.senses) do
			net:add_sense_index_category_proximity(sense_index, category, 0.6)
		end
	end
	for sense_index,_ in ipairs(entdef.senses) do
		net:add_sense_index_def_proximity(sense_index, entdef, 0.6)
	end
	net.num_inputs = #net.inputs
	net:add_hidden_layer(8)
	net:add_hidden_layer(8)
	local weights = {}
	for i,action in ipairs(entdef.actions) do
		weights[i] = action.weight_bias or 0
	end
	net:add_output_layer(entdef.num_actions, weights)
	entdef.netdef = net
end


function new_neuron(num_weights, bias)	
	local neuron = {weights = {}, bias = -rnd()*0.1 + rnd()*0.1 + bias*num_weights}
	for i=1,num_weights do
		add(neuron.weights, -rnd()*num_weights + rnd()*num_weights)
	end
	return neuron
end
function new_network(def, ent)
	local net = {
		def = def,
		ent = ent,
		inputs = {},
		layers = {},
	}
	local last_layer = net.inputs
	local last_num = def.num_inputs
	for i=1, #def.layers do
		local layer = {neurons = {}, source = last_layer}
		add(net.layers, layer)
		local num_neurons = def.layers[i]
		local layer_bias = def.layers_rnd[i]
		for n=1, num_neurons do
			add(layer.neurons, new_neuron(last_num, layer_bias and layer_bias[n] or 0))
		end
		last_layer = layer
		last_num = num_neurons
	end
	net.outputs = last_layer
	return net
end


dt = 1/30
tick_time = 1/4
center = 64
held_fraction = 0
cam_speed = 50
cam_speed_min = 50
cam_speed_max = 150
cam_buffer = 7*tile_size
cam_controls = {
	{-1,0},{1,0},{0,-1},{0,1}
}


function segs_list(v, segs)
	local tab = {}
	for i=0,segs+1 do
		tab[i] = v
	end
	return tab
end

START_ENERGY_FRACTION = 0.5
function add_ent(def, x,y)	
	local ang = rnd()
	local ent = {
		def = def,
		spawn_x = x,
		spawn_y = y,
		x = segs_list(x,def.segs),
		y = segs_list(y,def.segs),		
		angle = segs_list(flr(rnd()*4)*4, def.segs),		
		sprite = def.sprite or def.walk[1],
		rotate_frame = frame,
		rotate_forwards = true,
		move_frame = frame,
		move_forwards = true,
		health = def.health,
		energy = def.start_energy,
		hurt_frame = LOWEST,
		drain_frame = LOWEST,
		heal_frame = LOWEST,
		ability_frame = LOWEST,
		score = 0,
		action = 0,
		frame = frame,		
	}
	ent_generation(ent, 1)
	ent_lookup[x][y] = ent
	add(ents, ent)
	if def.post_tick then
		add(post_tick_ents, ent)
	end
	if def.walk then
		add(animated_ents,ent)
	end
	if def.netdef then	
		add(ai_tick_ents, ent)	
		ent.network = new_network(def.netdef, ent)
	end
	if def.senses then
		ent.senses = {}
		for i,v in pairs(def.senses) do
			ent.senses[i] = {}
		end
	end	
	ent_counts[def] += 1
	add(ents_by_def[def], ent)
	return ent
end




function _init()
	frame = -LOWEST-1000
	ticker_step = 0
	last_fraction_index = 1
	frame_alpha = 0
	ent_lookup = {}
	fx_lookup = {}
	corpse_lookup = {}
	rays = {}
	dood_regrow = {}
	ents = {}
	ent_counts = {}
	ent_extinct_frame = {}
	ents_by_def = {}
	for i,def in pairs(EGGS) do
		ents_by_def[def] = {}
		ent_counts[def] = 0
	end
	post_tick_ents = {}
	ai_tick_ents = {}
	animated_ents = {}
	cx,cy = 0,0
	ctx,cty = 0,0
	for x=0,map_tiles_size-1 do
		ent_lookup[x] = {}
		dood_regrow[x] = {}
		fx_lookup[x] = {}
		corpse_lookup[x] = {}		
	end
	for i,def in pairs(ENTS) do
		ent_counts[def] = 0
		ents_by_def[def] = {}
		for j,spawnpoint in pairs(def.spawn_points) do
			add_ent(def, spawnpoint[1], spawnpoint[2])
		end
	end
end

CORPSE_DURATION = 1000
function tick()
	frame+=1
	if not ULTRAFAST then
		for i,ray in pairs(rays) do
			if ray.frame < frame - ray.def.duration then
				rays[i] = nil
			end
		end
		for x,row in pairs(fx_lookup) do
			for y,fx in pairs(row) do
				if fx.frame < frame - fx.def.duration then
					row[y] = nil
				end
			end
		end
	end
	for x,row in pairs(corpse_lookup) do
		for y,corpse in pairs(row) do
			if corpse.frame < frame - CORPSE_DURATION then
				row[y] = nil
			end
		end
	end
	for i,ent in pairs(ents) do
		ent.def.tick(ent)
	end
	for i,ent in pairs(post_tick_ents) do
		ent.def.post_tick(ent)
	end
	for x,row in pairs(dood_regrow) do
		for y,at_frame in pairs(row) do
			if at_frame == frame then
				_regrow_doodad(x,y)
			end
		end
	end
	last_fraction_index = 1
	fraction_index_traget = #ai_tick_ents

	for def,spawn_frame in pairs(ent_extinct_frame) do
		if frame == spawn_frame then
			for j,spawnpoint in pairs(def.spawn_points) do
				local x,y = spawnpoint[1], spawnpoint[2]
				if not ent_lookup[x][y] then
					add_ent(def, x, y)
				end
			end			
			ent_extinct_frame[def] = nil
		end
	end
end

function prepare_tick_fraction(fraction)	
	local target_index = flr(fraction_index_traget*fraction)
	for i=last_fraction_index, target_index do
		tick_ai(ai_tick_ents[i])
	end
	last_fraction_index = target_index+1
end

function lerp(from,to,a)
	return from + (to-from)*a
end
function ent_palpha(ent)
	return min(1,frame-ent.move_frame+frame_alpha)
end

function ent_seg_on_screen(ent,seg)
	return tile_on_screen(ent.x[seg], ent.y[seg])
end

function ent_seg_draw_pos(ent, seg)
	local xs,ys = ent.x,ent.y
	local tx,ty = xs[seg],ys[seg]
	local palpha = ent_palpha(ent)
	local poffset = ent.move_forwards and 1 or -1
	local x = lerp(xs[seg+poffset], tx,palpha) * tile_size
	local y = lerp(ys[seg+poffset], ty,palpha) * tile_size
	return x,y
end

_ticker_steps = {tick}
local target_steps = max(1,flr(tick_time/dt))
for i=1,target_steps do
	add(_ticker_steps, function() prepare_tick_fraction(i/target_steps) end)
end
_num_ticker_steps = #_ticker_steps
FAST = false

function find_ent_around(cx,cy,size)
	local x,y,dx,dy = 0,0,0,-1
	for i=1,size^2 do
		local lx,ly = cx+x, cy+y
		if _in_bounds(lx,ly) then
			local ent = ent_lookup[cx+x][cy+y]
			if ent then
				return ent
			end
		end
		if x == y or (x < 0 and x == -y) or (x > 0 and x == 1-y) then
            dx, dy = -dy, dx
        end
        x, y = x+dx, y+dy	
	end
end

function _update()
	local cosumed4 = false	
	if ULTRAFAST then
		if btnp(5) then
			FAST = false
			ULTRAFAST = false			
		end
		if btnp(4) then			
			ULTRAFAST = false
			cosumed4 = true
		end
	else
		if btn(5) then			
			FAST = true
			if btnp(4) then
				ULTRAFAST = true
				cosumed4 = true
			end
		else
			FAST = false
		end
	end

	local frames = ULTRAFAST and 50 or (FAST and 20 or 1)
 	for i=1,frames do
 		if ticker_step >= _num_ticker_steps then
 			ticker_step = 0
 		end
 		ticker_step += 1
 		_ticker_steps[ticker_step]() 		
 	end
	
	frame_alpha = (ticker_step-1)/_num_ticker_steps

	cam_speed = lerp(cam_speed_min, cam_speed_max, held_fraction)
	cam_dt = cam_speed*dt
	local held = false
	for i, delta in pairs(cam_controls) do
		if btn(i-1) then
			cx = mid(cx + delta[1]*cam_dt, -cam_buffer, map_pixels_size - screen_pixels_size + cam_buffer)
			cy = mid(cy + delta[2]*cam_dt, -cam_buffer, map_pixels_size - screen_pixels_size + cam_buffer)
			held = true
			locked = nil
			TUT_CAM = true
		end
	end
	if locked then		
		cx,cy = ent_seg_draw_pos(locked, 1)
		cx-=64
		cy-=64
		if btnp(4) and not cosumed4 then
			show_ai = not show_ai
		end
	else
		selected = find_ent_around(ctx+8,cty+8,5)
		if selected and btn(4) and not cosumed4 then
			locked = selected
		end
	end
	ctx, cty = cx\8,cy\8
	held_fraction = mid(held_fraction + dt*(held and 5 or -10), 0, 1)	
end


function lerp_angle(from,to,a)
	local delta = (to-from)
	if delta > 0.5 then
		delta -= 1
	end
	if delta < -0.5 then
		delta += 1
	end
	return from + delta*a
end

function predraw_ents()
	for i,ent in pairs(animated_ents) do		
		local def = ent.def
		if ent.ability_frame >= frame then
			ent.sprite = def.ability
		else
			ent.sprite = def.walk[flr((ent_palpha(ent)*def.anim_speed)%def.num_walk)+1]
		end
	end
end
function get_prg(ent)
	return (frame-ent.frame+frame_alpha)/ent.def.duration
end
function draw_rays()
	for _,ray in pairs(rays) do
		local prg = get_prg(ray)
		if prg < 1 then
			if tile_on_screen(ray.x,ray.y) or tile_on_screen(ray.x2,ray.y2) then
				line(ray.x*tile_size+tile_half, ray.y*tile_size+tile_half, ray.x2*tile_size+tile_half, ray.y2*tile_size+tile_half, ray.def.colors[1+flr(prg*ray.def.num_colors)])
			end
		end
	end
end
function draw_corpses()
	for x,row in pairs(corpse_lookup) do
		for y,corpse in pairs(row) do
			if tile_on_screen(x,y) then				
				rspr(corpse.sprite, x*tile_size, y*tile_size, corpse.angle, 1, plot_sprite)
			end
		end
	end
end
function draw_fx()
	for x,row in pairs(fx_lookup) do
		for y,fx in pairs(row) do
			if tile_on_screen(x,y) then
				local prg = get_prg(fx)
				if prg >= 0 and prg < 1 then
					spr(fx.def.sprite + flr(prg*fx.def.length), x*tile_size, y*tile_size)
				end
			end
		end
	end
end
function draw_ents(method, check_status)
	for i,ent in pairs(ents) do
		local def = ent.def
		local segs = def.segs
		local emethod = method
		if check_status then
			if ent.locked_until_frame then
				emethod = plot_dark
			elseif ent.hurt_frame >= frame and frame_alpha < 0.5 then
				emethod = plot_hurt
			elseif ent.drain_frame >= frame then
				emethod = plot_drain
			elseif ent.heal_frame >= frame then
				emethod = plot_heal
			end
		end
		for si = 1,segs do			
			if ent_seg_on_screen(ent,si) then
				local x,y = ent_seg_draw_pos(ent,si)
				local asi = def.rigid and 1 or si
				local aoffset = ent.rotate_forwards and 1 or -1
				local aalpha = min(1,frame-ent.rotate_frame+frame_alpha)
				local angles = ent.angle
				local angle = lerp_angle(angles[asi+aoffset], angles[asi],aalpha)
				rspr(ent.sprite+segs-si, x, y, angle, 1, emethod)
			end
		end
	end	
end

function draw_tile_rect(x,y,c)
	rect(x*tile_size,y*tile_size,x*tile_size+tile_size,y*tile_size+tile_size,c)
end

function draw_ents_debug()
	for x,row in pairs(ent_lookup) do
		for y,ent in pairs(row) do
			draw_tile_rect(x,y,9)			
		end
	end
end

function draw_node(value,x,y)
	rectfill(x,y,x+4,y+4,0)	
	rectfill(x+1,y+1,x+3,y+3,1+flr(value*7))
	--if text then print(text, x+6, y, 7) end
end

function npos(li,ni)
	return 1+li*40,7+ni*6
end

DARK_WCOLORS = {1,2,3,4,5}
LIT_WCOLORS = {9,8,6,10,11}
function draw_network(network)
	for i=1,network.def.num_inputs do
		local value = network.inputs[i] or -1
		draw_node(value, npos(0,i))--, network.def.debug[i].." "..tostring(value))
	end
	for j,layer in ipairs(network.layers) do
		for i,value in ipairs(layer) do	
			local x,y = npos(j,i)			
			for u,w in pairs(layer.neurons[i].weights) do								
				local sx,sy = npos(j-1,u)
				local COLMAP = (abs(layer.source[u]) > 0.5) and LIT_WCOLORS or DARK_WCOLORS
				line(sx+2,sy+2,x+2,y+2,COLMAP[mid(1,5,flr(3.5 + w*3))])				
			end
			draw_node(value, x,y)
		end
	end
end
function draw_senses(senses)
	for i,sensed in pairs(senses) do
		for y,data in pairs(sensed) do
			draw_node(25+10*i,7+y*7, 1, data.name)
		end
	end
end

function draw_ent_senses(ent)
	for i,sense in pairs(ent.def.senses) do
		local x,y,ox,oy = ent_sense_offsets(ent,sense)
		for dist, detection in pairs(ent.senses[i]) do
			local sx = x+ox*dist
			local sy = y+oy*dist
			draw_tile_rect(sx,sy,5+CATEGORIES[detection.category])
			print(sub(detection.category,1,2), sx*tile_size+1, sy*tile_size+2, 7)
		end
	end
end

function print_shadowed(t,x,y,c)
	print(t,x+1,y+1,0)
	print(t,x,y,c)
end

function print_shadowed_aligned(t,x,y,c,ax,ay)
	print_shadowed(t,x-#t*ax*4,y-6*ay,c,ax)
end

function tile_camera()
	camera(cx%8,cy%8)
	palt(0,true)
end
function ent_camera()
	camera(cx,cy)
end

function draw_name(gen_text, generation, name, x,y)
	local w = #gen_text*4
	rectfill(x,y-1,x+w+1,y+5,0)
	print(generation,x+14,y,2)
	print(gen_text,x+1,y,6)
	print(generation,x+13,y,9)
	print_shadowed(name,x+3+w,y,6)
end
function draw_hud(ent)
	draw_name(ent.gen_text, ent.generation, ent.def.name, 1,6)
	local hfract = ent.health/ent.def.health
	rectfill(1,1,1+125,2,0)
	rectfill(1,1,1+125*hfract,2,11)
	local efract = ent.energy/ent.def.energy
	rectfill(1,3,1+125,4,0)
	rectfill(1,3,1+125*efract,4,15)

	--draw_senses(ent.senses)
	if locked and show_ai then
		if ent.network then
			draw_network(ent.network)
		end
		ent_camera()
		draw_ent_senses(locked)
	end
end

function draw_cursor(x,y,c)
	rect(x-4,y-4,x+4,y+4, c)
end

function _draw()
	if not ULTRAFAST then
		cls(14)
		tile_camera()
		local tx,ty = cx\8,cy\8
		local w,h = min(17, map_tiles_size-tx),min(17, map_tiles_size-ty)
		map(tx,ty,0,0,w,h)
		tx = tx + map_tiles_size
		map(tx,ty,0,0,w,h, 0x1)
		ent_camera()
		predraw_ents()
		draw_corpses()
		palt(0,false)
		draw_ents(plot_shadow)
		palt(0,true)
		draw_ents(plot_sprite, true)
		--draw_ents_debug()
		tile_camera()
		map(tx,ty,0,0,w,h, 0x2)
		
		ent_camera()
		draw_rays()
		draw_fx()

		tile_camera()		
		map(tx,ty,0,0,w,h, 0x4)	

		camera(0,0)
		palt(0,false)
		if selected then
			if not locked then
				local x,y = ent_seg_draw_pos(selected,1)
				draw_cursor(x-cx+tile_half,y-cy+tile_half,7)
			end
			draw_hud(selected)		
		else 
			draw_cursor(center,center,0)
		end	
	else
		cls(1)
	end
	camera(0,0)
	cpuload = stat(1)
	line(0,127,cpuload*127,127,9)
	memusage = stat(0)/2048
	line(0,127,memusage*127,127,10)

	for i,v in pairs(log_list) do		
		print_shadowed(v,50,7*i,7)
	end
	if ULTRAFAST or FAST then
		if ULTRAFAST then
			local y = 1
			for def,count in pairs(ent_counts) do
				local respawn_frame = ent_extinct_frame[def]
				local zero = count == 0
				if zero and respawn_frame then
					rect(1,y,29,y+4,2)
					rectfill(2,y+1,2+27*((respawn_frame-frame)/EXTINCT_RESPAWN_DELAY),y+3,8)
				else
					print(count,1,y, zero and 4 or 12)
				end
				local highest = 0
				local highest_ent = nil
				for i,ent in pairs(ents_by_def[def]) do
					if ent.generation > highest then
						highest = ent.generation
						highest_ent = ent
					end					
				end
				if highest_ent then
					draw_name(highest_ent.gen_text, highest_ent.generation, highest_ent.def.name, 12,y)					
				else
					print(def.name, 31,y,3)
				end
				y+=6
			end
		end
		print(frame, 128-#tostring(frame)*4,121,9)
		if ULTRAFAST then
			print_shadowed_aligned("\142\151 normal speed",1,121,7, 0,0)
		else
			print_shadowed_aligned("\142 lock super speed",1,121,7, 0,0)
		end
	else
		if not TUT_CAM then
			print_shadowed_aligned("\139\145\148\139 move camera",center-8,center,7, 0.5,0.5)
		else
			if locked then
				if show_ai then
					print_shadowed_aligned("\142 hide ai",1,114,7, 0,0)
				else
					print_shadowed_aligned("\142 show ai",1,114,7, 0,0)
				end
			else
				if selected then
					print_shadowed_aligned("\142 track",1,114,7, 0,0)
				end
			end
			print_shadowed_aligned("\151 speed up",1,121,7, 0,0)
		end
	end
end
__gfx__
00111111111111000000000000000116000000000000000000034600000000000000000000000644332222000046000000000000000000000500000600600000
01111111111111106100316040000223301600000600700000013220003460006004600000000643323443222340000000000000000000000040405005005600
1118889ddabbb1110334800033400013333228000301008000022333331300a0344430a00340000334455443331305a000787000003ab0000000044305000000
1188899ddaabbb113345540001314111322445402134450003434454545455540455455423343434555555544455555408676700056776003030340044330670
1188999ccaaabb1133455400003111113224454002234500343434354545455404554554200343454555555444455554005580000ab566000000004340403667
118999911aaaab110334800000000013333228000301008030022333331300a0344430a00000000324455443331305a0000000000045a0000600444035000000
1199991111aaaa116100316000000223301600000600700000013220003460006004600000000643322442222340000000000000000000000050005005005600
11ffe110011899110000000000000116000000000000000000034600000000000000000000000644332222000046000000000000000000000000000600600000
11ffe110011899110060160000001600000000000000000000360000034600000600460000006443322222000004600000000000000000000006006000000000
11dccc1111ffff110313000000002233160000006000070000132200133000000400400000006433223443222334000000000000000000003050000460000500
11ddccc11ffffe110334800000000133333228003100108030022333331000a0044430a0000000033445544333105a0000579800000570004043403405034000
11dddccaafffee113345540000014113322445400134450033434454545455540455455420043434555555544455554008977760007a7a003300330000406700
11ddddcbbffeee113345540000411113322445402223450004343435454545540455455423434345455555544445554005768970005777004043404005437000
111ddddbbfeee1110334800003310033333228003100108000022333331000a0044430a0033000032445544333105a00005665000005a0005040404000404450
01111111111111100313000004002233160000006000070000132220133000000400400000006433322442222334000000000000000000000650040655000300
00111111111111000060160000001600000000000000000000360000034600000600460000006443322222000004600000000000000000000006000000000000
00000000000000000060160000000610060000000000000000034600000000006000000000006443322220000004600000000000000000000000030000005600
00000000000000000010390000000123330000900607da0000013220003460003304600000006433223443220034000000000000000000000000400000600000
00000000000000000033447000000111333325700310a9000002233333130b0004440b00000000033445444323102a00000c70000037b6000650300005000660
00000000000000003334554000001141132245502144c0000343444545453430055134300334343455555544343334200057860005ab77600304060044336676
00000000000000000334554000014111132245500234a000343443445454534045541340234343454555554443434320000850000a667b703050377040466000
00000000000000000033447000331011333325700310c9003002233333130b0004440b00200000032445444323102a0000000000045aa6500060300035006670
000000000000000000103900004001233300009006072a000001322000346000330460000000643332244222003400000000000000a454003000400000600000
00000000000000000060160000000610060000000000000000034600000000006000000000006443322220000004600000000000000000000300030000005700
0000000000000000000000000000000000000000000000000000010000000000003300000000bb0000000b000000000003000004000000000000000000000000
00000000000550000000000000000000000000000a100a0001101a100112201001000030000a0000a000000000000a0000000000010000010000000004500760
000000000507705000055000000000000000000000a0b00000aab1100010012000000000ba00000000a000004000000000003000000010000050340045003076
0000000007000070000770000070070000000000abb7bb101ba22a1012100020300000030babbaa00000000a0004000000040030001000100400006000000000
00000000000000000500005005055050004004000017b1001aa22a00121001203000000300aba0b0000a00000000004000000000000000000003300000033030
000000000070070000700700000770000000000000b00a0000aaaa000011111030000013b0a00000000000000040000000000000000000000300004033000000
00000000005005000000000000000000000000000a0000a00110001001222010010000300b00aba0000000000000000000000300000000100064030005000054
0000000000000000000000000000000000000000a000000000100000001000000013300000000000b00000b00a000a0000300000010000000000000000030540
00000000000000000000000000000000000000000000000000000000000000000000555555550000000000000000000003434340000000007700007700000770
0000000000000000000000000000000000005000000000000000110aa1140000000566666666500003433343433343400454545000000000445353445353544f
004400000008810000ee0000003400000033000000ee00000009bebeebac400000566c6666c66500034343434343434004747470003535005343545353435350
014553000283300002e55000023150000489500002e453000004fbbbbfaa400005666c6776c66650035353535353535004545450004747005454545443545350
004551100083300000e55400003150000849500000e45dd00004fbbbbfaa400056666c6666c66665045454545454545003535350003535003354535353545330
004433000008100000e66700003400000033000000ee33000009bebeebac400056cccc6776cccc65047474747474747003434340002e22004453534453535440
0000000000000000000040000000000000005000000000000000110aa11400005666666776666665057575757575757002ee2820002282007714147714141770
000000000000000000000000000000000000000000000000000000000000000056676777777676650474747474747470000000000000000066f00f66f000f66f
00000000000000000000000000000000000000000000000000000000000000005667677777767665045454545454545000000000000000007455344700000000
00000000000000000000000000000000000005000000000000001106611400005666666776666665044444545444544004575440000057507434344700000000
0044300000081000000ee000003400000083300000ee300000094eee5f5c400056cccc6776cccc65034343434343434003444550000044406545555600000000
004551100083300000e55000003150000849500000e45dd0000433555f55400056666c6666c6666503434343434343400457533004343430f334434f00000000
014553000283300002e55000023150000449500002e45300000433555f55400005666c6776c66650033333333333333003444220047474700555555000000000
004430000008810000667000003400000033000000ee300000094eee5f5c400000566c6666c6650002ee2ee2882eee2004575000035353500344334000000000
00000000000000000004000000000000000500000000000000001106611400000005666666665000022222228822222002222000034343407455545700000000
0000000000000000000000000000000000000000000000000000000000000000000055555555000000000000000000000000000002e22e207434344700000000
00000000000000000000000000000000000000000000000000000000000011000000000008900000028000200120002000000000000000006554555600000000
0000000000100000000000000004000000000000000000000500004000e01100000000000080008000000008000000020000000000000000f333334f00000000
004400000080000000ee0000004200000003350000ee0000000705000ee040000008800000000000000000000000000000000000000000000545551000000000
015530c00033822002e5540003150000089500000245306060405000040603000089990089008009200020020000000000000000000000000334434000000000
005511dc0033800000e5504000153400089500000045dd7600040600000604400089900000000000000000000000000000000000000000007555555700000000
004330c00080000000ee6670003300000003350000e3306005000060000000ef0008800008000080000000000000000000000000000000007433344700000000
00000000001000000000040000004000000000000000000006000000000110f00000000009800990800000022000000100000000000000006111111600000000
0000000000000000000000000000000000000000000000000000000000000000000000000000080002000080010000200000000000000000f000000f00000000
000c0000000000000000000000000000000000000000000000004000030033000088880000222800000022000000210000000000000000000000000000000000
000c00000000000000041000000110000e000e000e000f000400e400330033308899998828222822222022221200002100000000000000000000000000000000
000dd000000cc000006641000111110000f0f000000000004e0e0000033300008899999822888222222222200001020000000000000000000000000000000000
0cd77dcc00cddc000166664001444110000d00000f0ff0e044ee44e0033003038889889822882222022220000120100000000000000000000000000000000000
00d77d0000cdddc004466640014444100007d000000ff0000004e0e0000033338999888828888222002222000002010000000000000000000000000000000000
000dd000000cdc00006644100011411000f00e0000e00e0004e0e400033033008988898828828222002222220000002000000000000000000000000000000000
000c00000000000000040100000101000e0000e0000000e004400040033003338889998828228882022022220120002100000000000000000000000000000000
000c0000000000000000000000000000e00000000000000000000000003000300088980000228800000022000000120000000000000000000000000000000000
bb0a00bb00bbb00000000000000000000013aa0000a0b00a00a00000341134411313331111111111eeeeeeeeeeee555ee55e555e555eeeeeaa0000bbba0ab0a0
0bbaab4b00abb0000000ba0abb0000000a477b70b0000000000000a0444344133313331311111111eeeeeeeeee55555555555555555555ee0000000ab000a0a0
004ab4b000004bba000bbb0bbba00000346777610a00a0a000000000343414131113111311111111eeeeeeeee5554445445544454444555ea0000000000a0000
aabbbba003343ba0000bbb04bba0abb046667677000a00000000a000411441443331333111111111eeeeeeeee5543334334433344333455ebb000a0a00000000
0abbba0000045000000aaa45aa04bbb0366a6577a00000a0a0000000134113413331333111111111eeeeeeeee54311333133113333113455000000ab00000000
004bb4b00bb350ab0005a4111440abb014ab56a4000a000000000000441443411111111311111111eeeeeeee554311111111111111113455a00000000000000a
0bba4bb0bba04abb0a0411abbba4aa000ab566a00b000b0000a00000341434433313331311111111eeeeeeee554331111111111111133455aa0000aaa00b00a0
0b0a00b0aa0004a00bba01abbbb1a40000a11000000b000a00000a00414411441313331111111111eeeeeeee55443111111111111113455e00a00000a0ab0aa0
000000000000bbb00bbba5abbba1400000133a0000a33311113ab10013113131111111111111111111111111e5543111111111111113455eaa0aa0aa0aa0ba0a
00004000aa0aaabb0bbb0033aa1aaa00017757a00ab776ab576bbb31313113131111111111111111111111115543311111111111111334550000b0a000a0b00a
00aaa040ada4dca00aa40aa4a14bbbb03777574135bb776bb7a6774111131311111331333313331333133111554311111111111111113455a000000000000000
00bbba00acd300000000abbb00abbba047b56673465a775b7757774a31133113113331333133313331333311554311111111111111113455bb0000000000000a
04abba000aa4c300000abbbba0abbb00aaa6657a3765b75a666677ba13311311113331333133313331333311e5543111111111111113455e00000000000000ba
000aa000004adc000000bbbba50a000014a656ba1455776665756b6a11131331111113133133331331331311555431111111111111134555aa00000000000000
000004000aabbb000000000aa000000035656771356656555776555313133113113331111111311111113111554311111111111111113455a0000000000000aa
000000000bbbb0000000000000000000a65677433776b6b77a76777331331131113333111111111111333311e5433111111111111113345e0000000aa000000a
0000b000003bb0030000000b00000000ab767741abbb756bb7757b4311113131113333110000000011333311e55431111111111111134455a000000aa0000000
000ab00000abb8300ba0000ba0000b00aab65641aab775abb76566a411311111113331110000000011311311554331111111111111133455aa0000000000000a
0a0000a03a8aaaba00aa00bba000ba0003677b6103675756665677ba1113131111111111000000001113311155431111111111111111345500000000000000aa
bb0a0ab00bbbbbb900baa0bba00baa00166775aa1665b65677577a7a3111111311133311000000001333331155431133331133133311345eab00000000000000
0000000009ba8aaa000baabaa0bba0003465b6a3345b7775b7b5777311311311113333110000000011333311e5543334433344334333455ea0000000000000bb
0ba00a000aaabb80000bbabaabbaa000145a66431ab77775b7bb663311131111113333310000000011313311e5554444544455445444555e000000000000000a
0b000ba00038bb000000baaaabba00000aa6643101a677ab666ab31011111113111111110000000011131111ee55555555555555555555eea00b0a000a0b0000
0000000003000300000aaa41aba0000000a331000033313a334aa30031311131113333110000000011333311eeeee555e555e55ee555eeeea0ab0aa0aa0aa0aa
baeba40e003aa000baaaaa1a1bbbbbb00013aba41aaa31000aa000001111311111333311111111111133331111e1eeeeefef7eeeeeefeefeeeee1eeeeeeefeee
af5bae50db0ad0300bbbbaa14aaaaaaa0a657ab457b75631a98a00001311111111311111113111111111331113eee31efeefffffefeeeeeee11eeeeefefeeefe
04040040bb0100ad0000aaaaaaab0000aba657a765775b73a89a000011111111111333133133313331331111eee1e11eee77ffeeeffeefffe1eeeee1eeeeeeee
e303303f031ad1aa000aabbabbabb0004a776577677577ba0aa00aa0111111131133331331333133331333111e1eeeeeefff7eff7ff7ff7feeeeeeeeefeeeeee
0f3ae03b000aa000000ab00abbaab00036766b775665777a00000a8a11131111111331333313331331333311eeee3e1efee7feeeff7f7ff7eee1ee1eeeeeeefe
ba3aa3e0aa31010000ab000ab00ab0001466b6756776a74100aa0aaa11111111111131333313313331333111e11eeeeefeffffeeee7fefffeeeee11efeeefeee
be404ba0da003aa000b0000ab000ab0001aba665666ba431009a000011111131111111111111111111311111e13e1e31eeff7feffeefeeee1eeeeeeeeefeeeef
0005eab000000da000000000a0000000001aa11114aaa1000000000011311111111111111111111111111111eeeeee11fef7ffeeefeeffefeeeeee1eeeeeeeee
00111000011111000111110001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
018881001aaaaa101ccccc101eeeee10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
181118101a111100011c11001e111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
188888101a100000001c10001e1eee10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
181118101a111100001c10001e111e10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
181018101aaaaa10001c10001eeeee10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000100011111000001000001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660666066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62226262622262620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62006662666066620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
62006262026202620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606262666266620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02220202022202220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010100000000000000000000010132323232e1e10000000000000000010132323232e1010000000000000000000000000000e10000000000000000000000000000000000
a2b2b4b4310101c0c0c000c0c0c0010101b2b4b4313131c0c0c0c0c0c0c0010101b2b4b4313131c0c000c0c0c0c00101b2a2b4b4313101c0c0c0c0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a8a8a8a8a8b8c8c8c8dbfbfbf8b8c8c8c8c8c8c8c8c8c8c8d8a8a8a8a8a8a8a8a8a8a8a8a85b0814d86bfbfbf81818185b0818590b08181858a8a8a8a8a8a8a8a8a8a8a8a85b0814d86bfbfbf81818185b0818590b08181088a8a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a8a8a8b8c898998889dbdbd8bb7b7b78989898989898989898c8d8a8a8a8a8a8a8a8a8586865c000085bfbf81a18185a1859090858185a18585868a8a8a8a8a8a8a8a8586865c440085bfbf81a18185a1059090858185a18508868a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a8b8c89989999aa899dbbbb9bb7b7b789b789898989898989899d8a8a8a8a8a8a85b085860000005db086bbb0858590858185a1908585908181b08a8a8a8a8a8a85b085000047005db086bbb0858590858105a1908585908181b08a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a9b8989a8b7b7a8899dbbbb9b9797a7b7b7b7b7898989b78989898d8a8a8a8a8a8181858e85810086868686868186a19085a18585814c8581a185818a8a8a8a8a8181850085810086868686868186a19085a18585814c8581a185818a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8b8998b9bab7b7b8999a8dbb9b87878797a7b7b7898988b7b7b789898d8a8a8a81859e8fafa18500000086bb81858690858585868190005d85859081868a8a8a8185000000a18500000086bb81858690858585868190005d85859081868a0000000000000000000000000000000000000000000000000000000000000000
8a8a9b89a8b789b7a7b789899dbdabacacacaca7b7b7b789a8b7b7b78989ad8a8a8ab0868686868586868148498a81858586b08690828385008283868686b08a8a8ab0860086868586868142438a81858586b08690828385008283868686b08a0000000000000000000000000000000000000000000000000000000000000000
8a8a9b89a8b7b7b7a7b7b7979dbfbfbcbbbbbf9bb7b7b7b7aab78989899d8a8a8a8a85868e86868685858558598a8abb86868ab0859293850092938581868a8a8a8a85860086868685858545418a8abb86868ab0859293850092938581868a8a0000000000000000000000000000000000000000000000000000000000000000
8a8b98b9ba8989b7a797a797878c8c8c8c8dbf9bb798b99988b99a89899d8a8a8a859e8faf868685b18481b4b5b0848681858a85859e8f860000008582838a8a8a85000000008685b18481b4b5b0848681858a85850000000000008582838a8a0000000000000000000000000000000000000000000000000000000000000000
8a9ba88989898989b7a7979787878797b79dbd9ba7a897a78989aab7b79d8a8a8ab08e8283908686858185848185818194b08aa2a38681858690008592938a8a8ab0008283908686858185848185818194b08aa2a30081858690408592938a8a0000000000000000000000000000000000000000000000000000000000000000
8a9ba88989898989b7b7a79797878797a79dbb9ba7aa97a7a79988a7b79d8a8a8a868692938686868184858186b4b581a48586b2b38e84818500000086868a8a8a860092938686868184858186b4b581a48586b2b30084810057008386868a8a0000000000000000000000000000000000000000000000000000000000000000
8a9ba8b7b7b789b7b7b7a797a79797a7a79dbb9b97a88797979988a7b79d8a8a8a860086868685828385858485818485a2a3bb86858eb1858500000085868a8a8a8600860b8685828385858485818485a2a3bb868500b1850057409300868a8a0000000000000000000000000000000000000000000000000000000000000000
8a9baab7b7b789b7b7b7a797979797a7a7adbd9b98ba879797a788b789ad8a8a8a85868283868592938184b185818586b2b38a859eaf94b1864c004d85b08a8a8a85008283868592938184b185818586b2b38a85000094b1864c004d85b08a8a0000000000000000000000000000000000000000000000000000000000000000
8a9baab7b7b7b7b7a7a79797878797979d8a8b98ba87879797ac88acad8a8a8a8ab08e9293908585858585858194b181858ab09eaf85a485a000005d868a8a8a8ab0009293908585850785858194b181858ab0000085a485004c404d008a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a9bb89a8989b7a7a797978787878787978c97aa87879797adbe8a8a8a8a8a8a8a8586868686858585b1b4b585a485848184858e94b185a080b65eb68a8a8a8a8a850000860b858507b1b4b585a485848184850094b185a080b6008a8a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a9b89aa89b7b7a79787879899b999b9b9b999ba8797979dbbbe8a8a8a8a8a8a8a86a086858585b18586b19e8f8f8f8f8f8f8fafa4a086a2a3b66e8a8a8a8a8a8a86a000858585b18586b1000000000000000000a4a086a2a3b6008a8a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a9bb7aab7a79797878797aa9797ac97878787878797acadbbbe8a8a8a8a8a8a8ab0858e85b1b4b58581858eb4b5b094b19596b1818580b2b3b68a8a8a8a8a8a8ab0850085b1b4b585818500b4b5b094b19596b1818580b2b3b68a8a8a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a9b89a8b7b7b797979797a897ad8a9b87878787979dbbbbbbbe8a8a8a8a8a8a8a86908e8585b1858184858e85808aa485a5a68186b086b6b68a8a8a8a8a8a8a8a8690008585b1858184850085808aa485a5a68186b086b6b68a8a8a8a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a9b89a8b789b7b7a797a7aa9d8a8b9787878787979dbbbbbbbbbe8a8a8a8a8a8ab08686858685858283858e808a808681b1858585a08686b6b6bbb68a8a8a8a8ab086008586858582838500808a808681b1858585a08686b6b6bbb68a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a9b89b89a89b7b7b797a7a89dbd9b9787878787979dbbbb8b8c8c8c8d8a8a8a8a8685ae9f8283859293858ea2a3b0859481b4b5a080868680a0a0a2a38a8a8a8a8685000082838592938500a2a3b0859481b4b5a080868680a0a0a2a38a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a9b8989aa8989b7b7a7b7aa9dbb9b978787878797978c8cb7b789b79d8a8a8a8ab090858e9293854a4b8586b2b386b1a481b18185a080a0868086b2b38a8a8a8ab09085009293854a4b8500b2b386b1a481b18185a080a0868008b2b38a8a8a0000000000000000000000000000000000000000000000000000000000000000
8aab8989aab7b7a8b7a7b7aa9dbbab9797878787879797a7a7b7b7b79dbe8a8a8a86858586905c005a5b850086868086858581b4b585a0858581a086808a8a8a8a86858500905c455a5b850086868086850281b4b585a0858581a008808a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a9b89b8b9b9888888b9ba9dbdbdacac97979787878797a7b7b7899dbbbb8a8a8a86860000000000000000b08a8a80a2a385b18185848185858585b08a8a8a8a8a86860000444342000000b08a8a80a2a302b18185848185858585b08a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a9b8989b7b7b88989b789898dbfbfbfaba7a79797a797a7898989898dbb8a8a8ab08690854d005d86858680808a8ab2b3b0818581b1858283819085a2a38a8a8ab08690854d415d00478680808a8ab2b3b0818581b1858283819085a2a38a0000000000000000000000000000000000000000000000000000000000000000
8a8aab898989898989b7b7b789898dbf8a8aaba7a797b7b7b7b7b789899dbb8a8a8a8686868586858685858686a2a38a8a8aa2a3868283859293858181b2b38a8a8a8686868586858685858686a2a38a8a8aa2a3868283859293858181b2b38a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a9b8989898989b7b7b78989ad8a8a8abbabb7a7b7b78989b7b789adbe8a8a8a8ab0868686868582838586b2b38a8a8ab2b3869293819085828385b08a8a8a8a8ab0868686868582838586b2b38a8a8ab2b3869293819085828385b08a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8aab898989898989b7b789adbbbb8b8dbbbbabb7b7b789b7b7b79dbbbe8a8a8a8a86868691869092938686b086bbb09186868085828385819293a2a38a8a8a8a8a86868691869092938686b086bbb09186868085828385819293a2a38a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a8aabac8989898989899dbbbb8b89898dbbbb9bb7b7898989899dbb8a8a8a8a8a8a86b08686868691868086868082839186bb85929385918585b2b38a8a8a8a8a8a86b08686868691868086868082839186bb85929385910485b2b38a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a8a8abeab89898989899dbb8b898989898dbbab8989898989acadbe8a8a8a8a8a8a8a8a86869186868686bb8685929385a2a3b0918185858191b08a8a8a8a8a8a8a8a8a86869186860786bb8685929385a2a3b0918104858191b08a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a8a8a8abeabacacacacadbdabacacacacadbdbdabacacacadbbbe8a8a8a8a8a8a8a8a8a8ab086869186b08ab0859185b0b2b3a2a385b091a2a38a8a8a8a8a8a8a8a8a8a8ab086079186b08ab0859185b0b2b3a2a385b091a2a38a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a8a8a8a8abebebbbbbbbebfbebbbbbbbbbebfbfbebbbbbebbbb8a8a8a8a8a8a8a8a8a8a8a8a8686b6b6868a86b6b6b686868ab2b3b6868ab2b38a8a8a8a8a8a8a8a8a8a8a8a8686b6b6868a86b6b6b686868ab2b3b6868ab2b38a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
8a8a8a8a8a8a8a8a8abebebe8a8a8abebebebe8a8a8a8abebe8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8686868a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8a8686868a8a8a8a8a8a8a8a8a8a8a8a8a8a0000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000046700d66013660156501f650136400f640176400a6300b6301062016620196200a61007620086200c6201062008620096200c6100d61008620076200761006610026200061000610007000060000600
00020000097200d7300c7401173012720137201673005720047200472000710027100371002710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000141701817018140101301d1300d130141301c12009120091200d120070200702004120041200312003130021300213001130011200112001130011200000000000000000000000000000000000000000
000200000a1601016003160041600a150151500c150081500a1400d1401314008140081400a1400d1400513005130071300713005130051300513005130041200112003120011200212002110000100001000010
00020000055100551008530235300f7500d7500c7400c7300d7300e7300e7300f7301072012720127101471016710187101e710207102171025710287102b71030710387103b7102d7102f710000000000000000
0001000010670076600e64006630106200662011620086200f620096200c6200b6100a61009610096100861007610066100561004610036100261001610016100161000610000000000000000000000000000000
000200001d71021520105500e56007560065600453003530035300252002520015100151001510015100051000510005100051000510005100051001510015100151000510005000050000500005000070000700
00010000045501c550045501e5500a5500e73012730167301a7301e7302172024720277202a7202c7202d7202e710307103071031710327103371033710327103271000700007000070000700007000000000000
000100001575016750167601677016770167600b7300b7300b7300a7200a7200a7200a7100a7100a7100a7100a710000000000000000000000000000000000000000000000000000000000000000000000000000
0001000007750077500775000000000000c7500c7500c750000000000015750157501575000000000001475014750147500000000000000000000000000000000000000000000000000000000000000000000000
00010000046500865015640176300f630156200a62003620036100362004610086100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000075200852007520195301a5301a5301a5300b5300a530205302155022550245502555011550115502c5502d5302e52030520315103251033510345100000000000000000000000000000000000000000
0001000005770067600376005750145300b530135300d530165200d52009720077200674005740057100471002710017100171001710017100070000700007000070000700000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
