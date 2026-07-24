pico-8 cartridge // http://www.pico-8.com
version 14
__lua__
--api
local level=0
local levelh=0
local layers = {}
local gravity = 0x0.04
local _delay = 0
local _light = 0
local _shakedir, _shake = 0,0

--game stuff
local player
local players,pickups,bullets,enemies,texts
local bags,triggers
local truck={}
local home={}

deaths=0

local splash=true

local tutorial=0

local number_of_bags=0

local camx=0
local camy=0
local camtx=0
local camty=0

local truckx=1
local trucky=0

local current_level
local level_number
local last_level

local goal_bags=17

local level_data={
	{
		index=2,
		height=1,
		first_bag=1
	},
	{
		index=3,
		height=2,
		first_bag=2
	},
	{
		index=5,
		height=3,
		first_bag=6
	},
	{
		index=10,
		height=4,
		first_bag=11
	},
	{
		index=3,
		height=2,
		first_bag=6
	},
	{
		index=3,
		height=2,
		first_bag=6
	}
}

local function t_home_update(home)
	home_update(home)
end

local function t_home_enter(home)
	home_enter(home)
end

local function t_home_exit(home)
	home_exit(home)
end

level_data.home={
	index=0,
	height=1,
	first_bag=0,
	update=t_home_update,
	enter=t_home_enter,
	exit=t_home_exit
}

function t_world_enter(world)
	world_enter(world)
end

level_data.world={
	index=1,
	height=1,
	first_bag=0,
	enter=t_world_enter
}

--positional sfx
local function psfx(id,x,y)
	local sx=x*8
	local sy=y*8
	if sx>=camx
			and sx<=camx+128
			and sy>=camy
			and sy<=camy+96 then
		sfx(id)
	end
end

--make and return a new layer
local function new_layer()
  local layer = {}
  add(layers,layer)
  return layer
end

--add an object to a layer
local function create(obj,layer)
  obj.layer = layer
  add(layer,obj)
end

--remove an object from its layer
local function destroy(obj)
	del(obj.layer,obj)
end

--add x frames of delay
local function delay(x)
	--if(x>_delay) _delay = x
	_delay += x
end

--flash ligh to x
local function light(x)
	if(x>_light) _light = x
end

--screen shake intensity to x
local function shake(x)
	if(x>_shake) _shake = x
end

--hex debugging
hexlut = {"1","2","3","4",
		"5","6","7","8","9","a","b",
		"c","d","e","f",[0]="0"}
local function hex(num)
	return hexlut[band(shr(num,12),0xf)]..hexlut[band(shr(num,8),0xf)]..hexlut[band(shr(num,4),0xf)]..hexlut[band(num,0xf)].."."..hexlut[band(shl(num,4),0xf)]..hexlut[band(shl(num,8),0xf)]..hexlut[band(shl(num,12),0xf)]..hexlut[band(shl(num,16),0xf)]
end

--director api
local _active_scenes={}

local function scene_update()
  for scene in all(_active_scenes) do
  	assert(coresume(scene))
  end
end

--begin the scene and start it this frame
local function begin_scene(script)
  local scene
  scene=cocreate(function()
    script()
    del(_active_scenes,scene)
  end)
  add(_active_scenes,scene)
  assert(coresume(scene))
end

--run scripts simultaneously
local function multitask(scripts)
 local tasks={}
 for script in all(scripts) do
   add(tasks,cocreate(script))
 end
 repeat
		local complete = true
		for task in all(tasks) do
			if coresume(task) then
			 complete = false
			end
		end
  if complete then
    return
  else
    yield()
  end
	until false
end

--collision
local r_mget=mget
function mget(x,y)
	if(x<0) return 1
	if(y<0) return 1
	local r=flr(y/12)
	local ly=((level+r)%5)*12
	local lx=flr((level+r)/5)*16
	return r_mget(x+lx,(y%12)+ly)
end

--helper function for switching axis
local function mgety(x,y)
	return mget(y,x)
end

local function collide(
		x,y,l,r,u,d,v,m)
	local tu = flr(y+u)
	local td = y+d
	local hit=0

	if v < 0 then --left
		local tl = flr(x+l)
		while tu < td do
		 --spr(3,tl*8,i*8)
			local spriten=m(tl, tu)
			hit=bor(fget(spriten),hit)
			tu += 1
		end
		if band(hit,0x1)!=0 then
			x = tl + 1 - l
		end
	elseif v > 0 then --right
  local tr = x+r
  local trf = flr(tr)
  if trf ~= tr then
   tr = trf
  else
   tr = trf - 1
  end
		while tu < td do
			--spr(3,tr*8,i*8)
			local spriten=m(tr, tu)
			hit=bor(fget(spriten),hit)
   tu += 1
		end
		if band(hit,0x1)!=0 then
			x = tr - r -- 0x0.2
		end
	end

	return hit,x
end

local function movex(o,v)
  v=v or o.vel.x
  o.x+=v
  local c=o.coll
  return collide(
			o.x,o.y,c.l,c.r,c.u,c.d,
			v,mget)
end

local function movey(o,v)
  v=v or o.vel.y
  o.y+=v
  local c=o.coll
  return collide(
			o.y,o.x,c.u,c.d,c.l,c.r,
			v,mgety)
end

local function physics(o)
  local v=o.vel
  v.ox=x
  if o.gravity then
    v.y+=gravity
    --x axis friction
  end
  if o.grounded then
  	if o.frict then
   	v.x*=o.frict
   	if(abs(v.x)<0x0.04) v.x=0
   end
  elseif o.airfrict then
  	v.x*=o.airfrict
  	if(abs(v.x)<0x0.04) v.x=0
  end
  if o.coll then
    if (v.x<-0x0.8) v.y=-0x0.8
    if (v.x>0x0.8) v.y=0x0.8
    if (v.y<-0x0.8) v.y=-0x0.8
    if (v.y>0x0.8) v.y=0x0.8
    local hitx,hity
    
    --when holding, have to
    --check old body for
    --hurt independently
    if o.hurt and o.holding then
    	local temp=o.coll
    	local ox=o.x
    	o.coll=o.old_coll
    	hitx=movex(o)
    	o.x=ox
    	o.coll=temp
    	if band(hitx,0x4)!=0 then
    		o:hurt()
    	end
    end
   	
    hitx,o.x=movex(o)
    o.walled=(band(hitx,0x1)!=0)
    if o.walled then
     v.x=0
    end
    if (not o.holding) then
     if o.kill and band(hitx,0x10)!=0 then
    		o:kill()
    	elseif o.hurt and band(hitx,0x4)!=0 then
    		o:hurt()
    	end
    end
   	if band(hitx,0x8)!=0 then
    	v.x*=0x0.8
    end
    hity,o.y=movey(o)
    local ovy = v.y
    if band(hity,0x1)!=0 then
    	--bounce?
    	if v.y>0 and band(hity,0x2)==0x2 then
    		v.y=-0x0.5d
    		hity=nil
    		psfx(9,o.x,o.y)
    	else
     	if o.dropsfx
     			and not o.grounded
     			and v.y>0x0.2 then
     		psfx(o.dropsfx,o.x,o.y)
     		if(o.heavy) shake(flr(v.y*4))
     	end
     	v.y=0
     end
    end
				if (not o.holding) or ovy>0 then
   		if o.kill and band(hity,0x10)!=0 then
    		o:kill()
    	elseif o.hurt and band(hity,0x4)!=0 then
    		o:hurt()
    	end
   	end
    o.grounded=(band(hity,0x1)!=0)
    if band(hity,0x8)!=0 then
    	v.y*=0x0.8
    	o.grounded=true
    end
    o.standing=nil
  else
   o.x+=v.x
   o.y+=v.y
  end
end

local function aabb_intersect(o1,o2)
	if o1.coll and o2.coll then
		local c1,c2=o1.coll,o2.coll
		return not(o1.x+c1.l>o2.x+c2.r
				or o1.x+c1.r<o2.x+c2.l
				or o1.y+c1.u>o2.y+c2.d
				or o1.y+c1.d<o2.y+c2.u)
	end
end

local function for_collisions(l1,l2,f)
	for o1 in all(l1) do
		for o2 in all(l2) do
			if aabb_intersect(o1,o2) then
				f(o1,o2)
			end
		end
	end
end

--level
--this spawnlist gets populated
--later
spawnlist = {}
local function spawn(c,x,y)
	--look into the spawnlist
 local f=spawnlist[c]
 --if we found something
 --then it's our spawn function
	if f then
		local o=f() --call it!
		if o then
			o.x,o.y = x,y --set the pos
			o.respawn={
				x=x,
				y=y
			}
		end
		return o --return it
	end
end

--temp, should decode
--[[
local function loadlevel(n)
	local lx=((n%8)*16)
	local ly=flr(n/8)*16
	for x=0,16 do
		for y=0,14 do
			local c=mget(lx+x,ly+y)
			if spawn(c,x,y) then
				mset(x,y,0)
			else
				mset(x,y,c)
			end
		end
	end
end
]]

local function contains(list,item)
	for oth in all(list) do
		if oth.uid==item.uid and
				oth.level_owner==item.level_owner then
			return true
		end
	end
end

local level_gold=0
local wx=0
local wy=0

local dbg=false

local function loadlevel(l)
	--before loading the next level
	--allow the current level
	--to do exit logic
	if current_level then
		if current_level.exit then
			dbg=true
			current_level:exit()
		end
	end

	layers={}
	texts=new_layer()
 enemies=new_layer()
	pickups=new_layer()
	triggers=new_layer()
	bags=new_layer()
 players=new_layer()
	bullets=new_layer()
 
 

	current_level=l
	level=l.index
	levelh=l.height
	level_gold=l.first_bag
	spawn_id=0
	--for every "room"
	for r=0,levelh-1 do
		local ly=((level+r)%5)*12
 	local lx=flr((level+r)/5)*16
		
		--every cell in that room
		for y=0,11 do
			for x=0,15 do
				--get the sprite number
				--of the cell
				local c=r_mget(x+lx,y+ly)
				--spawn that sprite!
				local obj=spawn(c,x,y+(r*12))
				if obj then
					obj.uid=spawn_id
					obj.level_owner=current_level
					spawn_id+=1
					
					if contains(truck,obj) or
							contains(home,obj) then
						destroy(obj)
					end
				end
				--optionally delete the cell
				--(i just mask it right now)
			end
		end
	end
	
	if current_level.enter then
		current_level:enter()
	elseif tutorial!=0 then
		level_enter()
	end
end

local function update(layer)
	for o in all(layer) do
		if(o.update) o:update()
	end
end

local function draw(layer)
	for o in all(layer) do
		if(o.draw) o:draw()
	end
end

local function sprite_draw(obj)
	local s = obj.sprite
 if not s.hide then
 	spr(s.n,
 			(obj.x*8)+0x0.8,
 			(obj.y*8)+0x0.8,
 			s.w or 1,s.h or 1,s.fx,s.fy)
 end
 if	obj.gold_id then
 	color(9)
  print(obj.gold_id,
  (obj.x*8)+0x3.8,
  (obj.y*8)+0x2.8)
	end
end
--api end


-->8
--player
local function player_throw(obj)
	local item=obj.holding
	obj.holding=nil
	create(item,item.layer)
	item.vel.x=obj.vel.x
	if obj.sprite.fx then
		item.vel.x-=0x0.1
	else
		item.vel.x+=0x0.1
	end
	item.vel.y=-0x0.44
	obj.held5=true
	obj.coll=obj.old_coll
	item.notthrown=nil
end

local function player_hold(obj,bag)
	obj.holding=bag
	destroy(bag) --don't process
	obj.old_coll=obj.coll
	obj.coll={
		u=obj.old_coll.u+bag.coll.u-bag.coll.d,
		d=obj.old_coll.d,
		l=obj.old_coll.l,
		r=obj.old_coll.r
	}
	--it only changes the u
	--but in a future ver, it
	--could change more
	obj.held5=true
	
	if bag.gold_id==1 and tutorial==0 then
		tutorial=1
		create_exit_trigger()
		destroy(tutorial_text)
		tutorial_text=text_box("take gold home",30,8)
	end
end

local function player_input(obj)
	local vel = obj.vel
	if btn(o) then
		vel.x -= 0x0.08--0x0.0c
		obj.sprite.fx = true
	elseif btn(1) then
		vel.x += 0x0.08--0x0.0c
		obj.sprite.fx = false
	end
	
	--jump
	if btn(2) or btn(4) then
		if (not obj.jump)
				and obj.grounded then
			vel.y = -0x0.44
			obj.jump = true
      sfx(3)
		end
	else
		if obj.jump and vel.y > -0x0.34 then
 		obj.jump = false
 		if(vel.y<0) vel.y = 0
 	end
	end
	
	if btn(3) and vel.y<-0x0.30 then
		obj.jump = false
		vel.y = -0x0.30
	end
	
	--run ani
 if obj.grounded then
   obj.sprite.n+=abs(obj.oldx-flr(obj.x*8))/4
   if(obj.sprite.n>=69) obj.sprite.n-=4
 end
 obj.oldx=flr(obj.x*8)
	
	--pickup bags
	--look for nearest bag
	--remove it from bags list and
	--hold it in the player
	if btn(5) then
		if not obj.held5 then
			if not obj.holding then
				local grabbox={
					x=obj.x,
					y=obj.y,
   		coll={
   			u=0x0.2,
   			d=0x1.6,
   			l=0x0.2,
   			r=0x0.e
   		}
   	}
   	local hity=obj.y+obj.coll.u
   	local hitx=obj.x+((obj.coll.l+obj.coll.r)/2)
   	local hitxl=obj.x+obj.coll.l
   	local hitxr=obj.x+obj.coll.r
  		local fail=false
  		for bag in all(bags) do
  			if aabb_intersect(grabbox,bag) then
  				local topy=hity+bag.coll.u-bag.coll.d
  				if not fget(mget(hitx,topy),0) then
   				player_hold(obj,bag)
   				fail=false
   				break
   			else
   				local boty=flr(topy+1)-bag.coll.u+bag.coll.d-obj.coll.u+obj.coll.d
   				--number_of_bags=hitxr--debug
   				if not fget(mget(hitxl,boty),0) and not fget(mget(hitxr,boty),0) then
   					obj.y=boty-obj.coll.d
   					player_hold(obj,bag)
   					fail=false
   					break
   				else
   					fail=true
   				end
   			end
  			end
  		end
  		--if(fail) sfx(11)
  	else
  		--throw
  		player_throw(obj)
  	end
  end
 else
 	obj.held5=nil
 end
	
	if obj.holding then
		obj.holding.x=obj.x
		obj.holding.y=obj.y+obj.old_coll.u-obj.holding.coll.d
	end
end


local function player_draw(obj)
	if obj.holding then
		sprite_draw(obj.holding)
	end
	sprite_draw(obj)
end

local function pdeath_update(obj)
  physics(obj)
  delay(2)
  if obj.y>14 then
    run()
  end
end

local function iframes(obj)
  if obj.iframes > 0 then
    obj.iframes-=1
    obj.sprite.hide=(obj.iframes%4)>1
  else
    obj.sprite.hide=nil
  end
end

local function player_update(obj)
	if obj.stun>0 then
		obj.stun-=1
	elseif obj.input then
		obj:input()--remove input for dummy char
	end
	physics(obj)
 iframes(obj)
end

local function new_player()
	local player={
  gravity=true,
  frict=0x0.c,
  airfrict=0x0.c,
		x=5,y=4,
		vel={
			x=0,y=0
		},
		coll={
			l=0x0.4,
			r=0x0.c,
			u=0x0.4,
			d=0x1.0
		},
		sprite={
			n=64,
			fx=false,
			fy=false,
		},
		gun={
      wait=0,
      speed=16
    },
  health=3,
  iframes=0,
  stun=0,
  dropsfx=8,
		update=player_update,
		input=player_input,
		draw=player_draw,
		hurt=player_hit,
		kill=player_kill
	}
	create(player,players)
	return player
end

local new_bag

local function make_into_bag(obj)
	destroy(obj)
 --local bag=new_bag()
 local temp=1-obj.coll.d
 obj.coll.d=1-obj.coll.u
 obj.coll.u=temp
 obj.sprite.n+=32
 obj.sprite.hide=nil
 obj.dropsfx=8
 obj.frict=0x0.e
 obj.airfrict=nil
 obj.update=physics
 obj.draw=sprite_draw
 obj.hurt=nil
 obj.kill=kill_corpse
 obj.notthrown=true
 create(obj,bags)
end

function player_die(obj)
 --obj.update=pdeath_update
 --obj.update=nil
 --obj.coll=nil
 obj.sprite.fy=true
 --music(-1,50)
 sfx(4)
 shake(6)
 light(1)
 delay(5)
 deaths+=1
 
 make_into_bag(obj)
 
 --begin_scene(death_box)
 begin_scene(delay_spawn_player)
 --player=new_player()
 
 
end

function player_hit(player,enemy,amount,kill)
 if (player.iframes>0) return
 if enemy then
  player.vel.x=(player.x-enemy.x)*(rnd(0x0.2)+0x0.3)
 end
 player.vel.y=-rnd(0x0.2)-0x0.1
 player.jump=true
 player.stun=15

	if kill then
		player.health=0
	else
		--hack fix
 	player.health-=1
 end
 
 if player.holding then
 	player_throw(player)
 end
 
 if player.health<=0 then
  player_die(player)
 else
  player.iframes=60
  sfx(5)
 end
end

function player_kill()
	player_hit(player,nil,nil,true)
	delay_destroy(player,60)
end

function truck_drive(p)
	p.vel.x=0
	p.vel.y=0
	if btn(0) then
		p.sprite.fx=false
		p.vel.x-=0x0.1
	end
	if btn(1) then
		p.sprite.fx=true
		p.vel.x+=0x0.1
	end
	if(btn(2)) p.vel.y-=0x0.1
	if(btn(3)) p.vel.y+=0x0.1
	physics(p)
end
-->8
--other
--enemies
local function edeath_update(obj)
  physics(obj)
  if obj.y>14 then
    destroy(obj)
  end
end

local function enemy_die(obj,vel)
 if vel then
 	obj.vel.x=vel.x*(rnd(0x0.2)+0x0.3)
 end
 obj.vel.y=-rnd(0x0.2)-0x0.1
 --obj.update=edeath_update
 --obj.coll=nil
 obj.sprite.fy=true
 delay(3)
 psfx(2,obj.x,obj.y)
 
 make_into_bag(obj)
end

local function enemy_update(obj)
 if obj.sprite.fx then
  obj.vel.x-=obj.speed
 else
  obj.vel.x+=obj.speed
 end
	physics(obj)
 if obj.walled then
   obj.sprite.fx = not obj.sprite.fx
	end
end

function enemy_kill(enemy)
	enemy_die(enemy)
	delay_destroy(enemy,60)
end

local function new_enemy()
	local enemy={
  gravity=true,
  speed=0x0.08,
  frict=0x0.c,
  airfrict=0x0.c,
  --speed=0x0.10,
		vel={
			x=0,
			y=0
		},
		coll={
			l=0x0.2,
			r=0x0.e,
			u=0x0.4,
			d=0x1.0
		},
		sprite={
			n=69
		},
		update=enemy_update,
		draw=sprite_draw,
		hurt=enemy_die,
		kill=enemy_kill
	}
	create(enemy,enemies)
	return enemy
end

spawnlist[69] = new_enemy

--bullet
local function bimpact_update(obj)
	if obj.flash > 0 then
		obj.flash -= 1
	else
		destroy(obj)
	end
end

--[[
local function bullet_impact(obj)
  sfx(0)
  --delay(1)
  --light(0)
  shake(1)
  obj.update = bimpact_update
  obj.flash = 2
  obj.sprite.n = 81
end
]]

local function bullet_update(obj)
	physics(obj)
	if obj.walled then
    bullet_impact(obj)
  end
end

local function bflash_update(obj)
	if obj.flash > 0 then
		obj.flash -= 1
	else
		obj.sprite.n = 80
		obj.update = bullet_update
	end
end

function new_bullet()
  local bullet = {
    coll = {
    	l = 0x0.6,--0x0.2
    	r = 0x0.a,--0x0.e
    	u = 0x0.6,--0x0.6
    	d = 0x0.a --0x0.a
    },
    sprite = {
    	n = 81,
    	w = 1,
    	h = 1
    },
    flash = 2,
    draw = sprite_draw,
    update = bflash_update
  }
  create(bullet,bullets)
  return bullet
end

--crate
local function pickup_text(obj,text)
  begin_scene(rising_box(text,(obj.x*8)+4,(obj.y*8)-2))
end

local function crate_picked_up(crate,player)
	if(player.gun.speed>0) player.gun.speed-=2
  pickup_text(crate,"+1 gun")
end

local function health_picked_up(crate,player)
	player.health+=1
  pickup_text(crate,"+1 h")
end

local function new_pickup(sprite_n,picked_up)
	local crate={
		coll={
			l=0x0.2,
			r=0x0.e,
			u=0x0.4,
			d=0x1.0
		},
		sprite={
			n=sprite_n
		},
		draw=sprite_draw,
		picked_up=picked_up
	}
	create(crate,pickups)
	return crate
end

local function new_gun_crate()
  return new_pickup(70,crate_picked_up)
end
spawnlist[70] = new_gun_crate

local function new_health_crate()
  return new_pickup(70,health_picked_up)
end
spawnlist[71] = new_health_crate

function kill_bag(bag)
	if not bag.respawning then
		psfx(10,bag.x,bag.y)
		delay_respawn(bag,32)
	end
end

function kill_corpse(bag)
	delay_destroy(bag,20)
end

function kill_box(bag)
	delay_respawn(bag,20)
end

function new_bag()
	local bag = {
			vel={
				x=0,
				y=0
			},
   coll={
 			l=0x0.2,
 			r=0x0.e,
 			u=0x0.0,
 			d=0x1.0
 		},
   sprite = {
   	n = 72,
   	w = 1,
   	h = 1
   },
   heavy=true,
   gravity=true,
   frict=0x0.e,
   dropsfx=6,
   draw = sprite_draw,
   update = physics,
   kill = kill_bag,
   gold_id=level_gold
 }
 create(bag,bags)
 level_gold+=1
 return bag
end

spawnlist[72] = new_bag

function new_box()
	local box = {
			vel={
				x=0,
				y=0
			},
   coll={
 			l=0x0.2,
 			r=0x0.e,
 			u=0x0.0,
 			d=0x1.0
 		},
   sprite = {
   	n = 75,
   	w = 1,
   	h = 1
   },
   heavy=true,
   gravity=true,
   frict=0x0.e,
   dropsfx=7,
   draw = sprite_draw,
   update = physics,
   kill = kill_box
 }
 create(box,bags)
 return box
end

spawnlist[75] = new_box

function new_bouncy_box()
	local obj=new_box()
	obj.bounce=0x0.5d
	obj.sprite.n=76
	obj.kill=kill_bag
	return obj
end

function spawn_bouncy_box()
	if band(peek(0x5e00),0x1)==0 then
		return new_bouncy_box()
	end
end

spawnlist[76] = spawn_bouncy_box

--loo brb
--todo, replace this hack with
--goto level select?
function exit_on_b(obj,player)
	if btn(3) and not player.holding then
		if tutorial==1 then
			save_truck()
		
			local found=false
			for bag in all(truck) do
				if bag.gold_id==1 then
					found=true
				end
			end
			
			load_truck()
			
			if not found then
				destroy(tutorial_text)
				tutorial_text=text_box("no gold laoded",8,8)
				
				--create_exit_trigger()
				return
			end
		end
		
		destroy(obj)
		exit_level()
	end
end

function create_exit_trigger()
	local box = {
			x=truckx,
			y=trucky+2,
   coll={
 			l=0x0.0,
 			r=0x1.0,
 			u=0x0.0,
 			d=0x1.0
 		},
 		sprite={
 			n=89,
 			w=1,
 			h=1
 		},
 		trigger=exit_on_b,
 		draw=sprite_draw
 }
 create(box,triggers)
 return box
end

--spawnlist[89]=create_exit_trigger

local function enter_trigger(trg)
	if btn(4) or btn(5) then
		loadlevel(trg.level)
	end
end

function create_enter_trigger(level)
	return function()
		local box = {
   coll={
 			l=0x0.0,
 			r=0x1.0,
 			u=0x0.0,
 			d=0x1.0
 		},
 		level=level,
 		trigger=enter_trigger,
  }
  create(box,triggers)
  return box
	end
end

spawnlist[51]=create_enter_trigger(level_data.home)

spawnlist[53]=create_enter_trigger(level_data[1])
spawnlist[54]=create_enter_trigger(level_data[2])
spawnlist[55]=create_enter_trigger(level_data[3])
spawnlist[56]=create_enter_trigger(level_data[4])
spawnlist[57]=create_enter_trigger(level_data[5])
spawnlist[58]=create_enter_trigger(level_data[6])

-->8
--collision handlers
local function shot_enemy(bullet,enemy)
  if bullet.update==bullet_update then
  	bullet_impact(bullet)
  	enemy_die(enemy,bullet.vel)
  end
end

local function player_pickup(player,pickup)
	pickup.picked_up(pickup,player)
	destroy(pickup)
end

local function bag_bag(bag1,bag2)
	--hack so player can jump off of items
	--if(bag1.layer==players) bag1.grounded=true
	
	if bag1!=bag2 then
		local dx=bag1.x-bag2.x
		local dy=bag1.y-bag2.y
		if abs(dy)>abs(dx) then
			if dy<0 and bag1.vel.y>0 then
				local temp=bag1.y
				local ty=(bag2.y
						+bag2.coll.u
						-bag1.coll.d)-bag1.y
				if band(movey(bag1,ty),0x1)!=0 then
					bag1.y=temp
				end
				
				--bag1.y=bag2.y
				--		+bag2.coll.u
				--		-bag1.coll.d
				if bag2.bounce then
					bag1.vel.y=-bag2.bounce
					bag1.grounded=false
					psfx(9,bag1.x,bag1.y)
				else
 				if bag1.dropsfx and bag1.vel.y>0x0.2 then
 					psfx(bag1.dropsfx,bag1.x,bag1.y)
 				end
					bag1.vel.y=0
					bag1.grounded=true
				end
			end
		else
 		if dx<0 then
  		if bag1.layer==enemies then
 				bag1.sprite.fx=true
 				if(bag1.vel.x>0) bag1.vel.x=0
 			elseif bag1.vel.x>bag2.vel.x then
 				bag2.vel.x+=0x0.1
 				--local temp=bag1.vel.x
 				--bag1.vel.x=bag2.vel.x
 				--bag2.vel.x=temp
 			end
 		else
 			if bag1.layer==enemies then
 				bag1.sprite.fx=false
 				if(bag1.vel.x<0) bag1.vel.x=0
 			elseif bag1.vel.x<bag2.vel.x then
 				bag2.vel.x-=0x0.1
 				--local temp=bag1.vel.x
 				--bag1.vel.x=bag2.vel.x
 				--bag2.vel.x=temp
 			end
 		end
 	end
	end
end

local function bag_enemy(bag,enemy)
	local dy=bag.y-enemy.y
	if not bag.notthrown and dy<0 and bag.vel.y>0 then
		enemy_die(enemy,bag.vel)
	end
end

local function bag_player(bag,player)
	local dy=bag.y-player.y
	if not player.holding and dy<0 and player.grounded and bag.vel.y>0x0.24 and bag.vel.y-bag.coll.d+player.coll.u>dy then
		if bag.heavy then
			player_die(player,bag.vel)
		else
			player_hit(player,bag)
		end
	else
		bag_bag(bag,player)
	end
end

--wrong place lol
function text_draw(obj)
	if obj.bg then
 	color(obj.bg)
 	rectfill(obj.x-1,obj.y-1,obj.x+(obj.w*4)-1,obj.y+5)
 end
 color(obj.fg)
 cursor(obj.x,obj.y)
 print(obj.text)
end

function trigger_player(trigger,player)
	if trigger.trigger then
		trigger:trigger(player)
	end
end

-->8
--scripts
function wait(t)
  for i=1,t do
    yield()
  end
end

function text_box(text,x,y)
  local obj={
    x=x,y=y,w=#text,
    bg=0,fg=7,
    text=text,
    draw=text_draw
  }
  create(obj,texts)
  return obj
end

function type_text(obj,text,speed)
  for p=1,#text do
  		obj.text=sub(text,1,p)
    wait(speed)
  end
end

function death_box()
		wait(20)
  local t=text_box("game over",46,54)
  type_text(t,"game over",5)
  --destroy(t)
end

function rising_box(text,x,y)
  return function()
		  local t=text_box(text,
		  	x-((#text)*2),
		  	y-3)
		  t.bg=false
		  multitask({function()
		    type_text(t,text,2)
		   end,
		   function()
		    for i=1,5 do
			    wait(2)
			    t.y-=1
			   end
			  end
			 })
			 wait(20)
			 destroy(t)
	 end
end

function delay_destroy(obj,t)
	if not obj.destroying then
		obj.destroying=true
 	begin_scene(function()
 		wait(t)
 		destroy(obj)
 	end)
 end
end

function delay_respawn(bag,t)
	if not bag.respawning then
		bag.respawning=true
 	begin_scene(function()
 		wait(t)
 		if bag.level_owner==current_level and bag.respawn then
  		bag.x=bag.respawn.x
  		bag.y=bag.respawn.y
  	else
  		destroy(bag)
  	end
  	bag.respawning=nil
 	end)
 end
end

function delay_spawn_player()
	wait(60)
	player=new_player()
end

function save_truck()
	truck={}
	local trigger={
		x=truckx,
		y=trucky,
		coll={
			l=0,
			r=4,
			u=0,
			d=5
		}
	}
	for item in all(bags) do
		if aabb_intersect(item,trigger) then
			destroy(item)
			create(item,truck)
			item.x-=truckx
			item.y-=trucky
		end
	end
end

function load_truck()
	for item in all(truck) do
		destroy(item)
		create(item,bags)
		item.x+=truckx
		item.y+=trucky
	end
end

function home_update(home)
	local trigger={
		x=8,
		y=4,
		coll={
			l=0,
			u=0,
			r=6,
			d=6
		}
	}
	number_of_bags=0
	for bag in all(bags) do
		if bag.gold_id and
				aabb_intersect(bag,trigger) then
			number_of_bags+=1
		end
	end
	if tutorial==2 and number_of_bags>0 then
		tutorial=3
		destroy(tutorial_text)
		text_box("find more",12,36)
		text_box("gold!",20,42)
		create_exit_trigger()
	end
	if not gameover and number_of_bags>=goal_bags then
		player.update=nil
		gameover=true
		begin_scene(function()
			for i=0,360 do
				if (i%4)==0 then
					begin_scene(rising_box("",rnd(128),rnd(96)))
				end
				_light=flr((-sin(i/36)*2)+0.5)
				yield()
			end
			player.update=player_update
			text_box("thanks for playing!",16,16)
			text_box("thanks for playing!",16,16)
		end)
	end
end

function truck_exit()
	local oldtruckx=truckx
	for i=0,120 do
		truckx=oldtruckx-i*i*0x0.002
		yield()
	end
end

function truck_enter(x,y)
	trucky=y
	for i=120,0,-1 do
		truckx=x-i*i*0x0.002
		yield()
	end
end

function player_enter_truck()
	destroy(player)
	create(player,truck)
	player.x=0x0.2
	player.y=0x3.4
end

function player_exit_truck()
	destroy(player)
	create(player,players)
	player.x=truckx
	player.y=trucky+2
end

function exit_level()
	menuitem(1)
	begin_scene(function()
		save_truck()--must do before
		
		player_enter_truck()
		truck_exit()
		
		--dont think this is used
		last_level=current_level
		
		if current_level!=level_data.home then
			music(3)
		end
		
		if tutorial==1 then
			tutorial=2
 		loadlevel(level_data.home)
		else
			wx=current_level.x
			wy=current_level.y
			loadlevel(level_data.world)
		end
	end)
end

function level_enter()
	if tutorial>1 and tutorial<10 then
		tutorial+=1
	end
	if tutorial==4 then
		text_box("the truck holds",4,4)
		text_box("more than gold",4,10)
	end
	if tutorial==5 then
		text_box("hold ƒ to",4,4)
		text_box("stay low",4,10)
	end
	if tutorial==5 then
		text_box("boxes will protect",4,4)
		text_box("you from spikes",4,10)
	end
	
	begin_scene(function()
 	truck_enter(1,0)
 	player_exit_truck()
 	load_truck()--must do after
 	menuitem(1,"suicide",player_kill)
 
 	create_exit_trigger()
 end)
 music(0)
end

function home_enter()
	--load the home
	for bag in all(home) do
		destroy(bag)
		create(bag,bags)
	end
	if tutorial==2 then
		destroy(tutorial_text)
		tutorial_text=text_box("store gold",69,36)
	end
	begin_scene(function()
 	truck_enter(1,4)
 	player_exit_truck()
 	load_truck()--must do after
 
 	if tutorial>2 then
 		create_exit_trigger()
 	end
 end)
end

function home_exit()
	--save the home
	for bag in all(bags) do
		destroy(bag)
		create(bag,home)
	end
end

function world_enter()
	local p={
		x=wx,
		y=wy,
		vel={
			x=0,
			y=0
		},
		coll={
			l=0x0.2,
			r=0x0.e,
			u=0x0.4,
			d=0x1.0
		},
		sprite={
			n=10,
			w=1,
			h=1
		},
		update=truck_drive,
		draw=sprite_draw
	}
	create(p,players)
	
end
-->8
--init
function _init()

	--set up world map
	for y=0,11 do
		for x=0,15 do
			--get the sprite number
			--of the cell
			local c=r_mget(x,y+12)-52
			
			if c>=1 and c<=6 then
				level_data[c].x=x
				level_data[c].y=y
			end
			if c==-1 then
				level_data.home.x=x
				level_data.home.y=y
			end
		end
	end
	
	music(0)

	--loadlevel(level_data[1])
	--temp
	--tutorial=2
	
	
	--tutorial=3
	--loadlevel(level_data[4])
	
	loadlevel(level_data[1])

	player=new_player()
	
	tutorial_text=text_box("find gold!",36,8)
	--for i=1,10 do
	--	new_enemy(flr(rnd(1024)),flr(rnd(1024)))
	--end


	camera(0,-0x10)
	--map(0,0,0,0,32,30)
	--memcpy(0x4300, 0x6600, 0x1a00)
end

-->8
--update
function _update60()

	if(btn(5)) splash=false
  --scene
  scene_update()

	if not splash then
	if _delay>0 then
		_delay-=1
	else
    if _light>0 then
     _light-=1
    end
    if _shake>0 then
     _shake-=1
    end
		for layer in all(layers) do
			update(layer)
		end
		
		if #bags>25 then
			for bag in all(bags) do
				if not bag.heavy then
					destroy(bag)
					break
				end
			end
		end

  for_collisions(bullets,enemies,shot_enemy)
		for_collisions(players,enemies,player_hit)
		for_collisions(players,pickups,player_pickup)
		for_collisions(players,bags,bag_bag)
		for_collisions(enemies,bags,bag_bag)
		for_collisions(bags,bags,bag_bag)
		for_collisions(bags,enemies,bag_enemy)
		for_collisions(bags,players,bag_player)
		
		for_collisions(triggers,players,trigger_player)
		
		--if not enemies[1] then
		--	level+=1
		--	loadlevel(level)
		--end
		
		if current_level.update then
			current_level:update()
		end
		
		if player.y<5 and player.health<3 then
			player.health=3
			sfx(12)
		end
		
		local pcamy=(player.y*8)-48
		
		if player.grounded and (camy>pcamy+20) then
			camty=pcamy
		end
		
		if camy>pcamy+48 then
			camty=pcamy
		elseif camy<pcamy then
			camty=pcamy
		end
		
		if camty<0 then
			camty=0
		elseif camty>(levelh-1)*96 then
			camty=(levelh-1)*96
		end
		
		camy+=(camty-camy)*0.1
	end
	end
end

-->8
--draw
function _draw()
 cls()
 --memset(0x6000,0xff,0x2000)

	if not splash then

 --gui
	camera(0,0)
	clip(0,0,128,16)
	cursor(0,0)
	color(8)
	for i=1,player.health do
  print("‡",i*6,0)
 end
 
 if tutorial>2 then
 	color(6)
  print("bags in storage:",1,8)
  color(9)
 	print(number_of_bags,65,8)
 	print("/17",73,8)
 end
 if deaths>0 then
 	color(6)
 	print("deaths:",90,8)
  color(8)
 	print(deaths,118,8)
 end
 
 clip(0,112,128,16)
 
 if tutorial>3 then
  color(10)
 	print("find gold!",0,115)
 	color(6)
 	print("by isogash - ludum dare 40",0,122)
	end
	
	do
		local i=81
 	if(btn(0)) color(7) else color(5)
 	print("‹",i,114)
 	if(btn(3)) color(7) else color(5)
 	print("ƒ",i+8,114)
 	if(btn(2)) color(7) else color(5)
 	print("”",i+16,114)
 	if(btn(1)) color(7) else color(5)
 	print("‘",i+24,114)
 	if(btn(4)) color(7) else color(5)
 	print("Ž",i+32,114)
 	if(btn(5)) color(7) else color(5)
 	print("—",i+40,114)
 end
	

 --level
	clip(0,16,128,96)
	
 --shake
 local acamx=camx
 local acamy=camy-0x10
 
	if _shake > 0 then
		local i = flr(rnd(4))
		if(i==_shakedir) i=(i+2)%4

		local dx,dy = _shake*(i%2),_shake*((i+1)%2)
		if(i>1) dx,dy=-dx,-dy
		acamx+=dx
		acamy+=dy
		_shakedir = i
	end
	
	camera(acamx,acamy)
	
 --light
	if _light > 0 then
		local i = (flr(_light+0.5)-1) * 0x0100
		if(i>0x0100) i = 0x0100
		memcpy(0x5f10,0x0e38+i,4)
		memcpy(0x5f14,0x0e78+i,4)
		memcpy(0x5f18,0x0eb8+i,4)
		memcpy(0x5f1c,0x0ef8+i,4)
	else
		pal()
	end
	
	
  
  --draw layers 
  for i=0,levelh-1 do
  	local ly=(level+i)%5
  	local lx=flr((level+i)/5)
  	map(lx*16,ly*12,0,i*96,16,12,0x80)
  end
 	for layer in all(layers) do
 		draw(layer)
 	end
 	for i=0,levelh-1 do
 		local ly=(level+i)%5
  	local lx=flr((level+i)/5)
  	map(lx*16,ly*12,0,i*96,16,12,0x40)
  end
  
  camera(acamx-(truckx*8),acamy-(trucky*8))
  draw(truck)
  spr(12,0,24,4,2)
  
 else
 	camera()
 	clip()
 	map(112,48,0,0,16,16)
 	print("press —",48,116)
 end
end
__gfx__
00000000066006606665666555555555444444443333333328028028066006600000000000000000000000000000000000111111000000000000000000000000
00000000511651165556555658000005445554443bbbbbb3266262665116511600000000000000000000000000000000007070c1000000000000000000000000
007007005116511655565556508000054444454435555553026666605116511600000000000000000110000000000000007707c1000000000000000000000000
0007700005500550555555555008000545555544055005502866666805500550000000000000000007c0000000000000077070c1000000000000000000000000
0007700006600660666566655000800545445454066006602666666655665566000000000000000007c1111100000000070707c1000000000000000000000000
007007005116511655565556500008054444454451165116026666605566556600000000000000001c5ccc5c00000000707070c1111111111111111111111111
000000005116511655565556500000854445444451165116266262660560056000000000000000001565c56500000000770707ccccccccccccccccccccccccc1
000000000550055055555555555555554444444405500550280280280560056000000000000000000050005000000000111111ccccccccccccccccccccccccc1
00000000aaa000aacccccccc7c7ccc7c06666660666666665111111651111116511111166666666006666666000000005cccccccccccccccccccccccccccccc1
00000000a8aaaa8accccccccc7c77cc7511111161111111151111116511111111111111611111116511111110000000055cc1111cccccccccccccccc1111ccc1
000000008a88a88accccccccc7cccccc51111116111111115111111651111111111111161111111651111111000000005cc115511cccccccccccccc115511cc1
000000008a8aaa8acccccccccccccccc51111116111111115111111651111111111111161111111651111111000000005511566511cccccccccccc11566511c1
000000008a8a88aacccccccccccccccc51111116111111115111111651111111111111161111111651111111000000005c15666651cccccccccccc15666651c1
0000000088888888cccccccccccccccc511111161111111151111116511111111111111611111116511111110000000011156666511111111111111566665111
0000000088888888cccccccccccccccc511111161111111151111116511111111111111611111116511111110000000000005665000000000000000056650000
0000000088888888cccccccccccccccc055555505555555551111116055555555555555051111116511111110000000000000550000000000000000005500000
4444ffffffff44444444444400000000066666666666666051111116066666605111111666666666599999965999999659999996666666600666666600000000
4444ffffffff44444444444400000000511111111111111651111116511111165111111199999999599999965999999999999996999999965999999900000000
4444ffffffff44444444444400000000511111111111111651111116511111165111111199999999599999965999999999999996999999965999999900000000
4444ffffffff44444444444400000000511111111111111651111116511111165111111199999999599999965999999999999996999999965999999900000000
4444ffffffff44444444444400000000511111111111111651111116511111165111111199999999599999965999999999999996999999965999999900000000
4444ffffffff44444444444400000000511111111111111651111116511111165111111199999999599999965999999999999996999999965999999911111111
4444ffffffff444444444444000000005111111111111116511111165111111651111111999999995999999659999999999999969999999659999999ccccccc1
4444ffffffff444444444444000000000555555555555550055555505111111651111115555555555999999605555555555555505999999659999999ccccccc1
cccc77cc3333333333333333444444440000000033363333336363333636363363636363636363636363636306666666666666605999999606666660ccccccc1
ccc717cc33333333333333334444444400000000333333333333333333333333333333333333333333333333599999999999999659999996599999961111ccc1
cc11cccc333333333335533344444444000000003335533333355333333553333335533333355333333553335999999999999996599999965999999615511cc1
7cccccc73333333333577533ffffffff0000000033577533335775333357753333577533335775333357753359999999999999965999999659999996566511c1
1ccccc113333333333577533fffff44f0000000033577533335775333357753333577533335775333357753359999999999999965999999659999996666651c1
cc7ccccc3333333333355333fffff44f000000003335533333355333333553333335533333355333333553335999999999999996599999965999999666665111
c117cccc3333333333333333fffff44f000000003333333333333333333333333333333333333333333333335999999999999996599999965999999656650000
cccccccc3333333333333333fffff44f000000003333333333333333333333333333333363333333636333330555555555555550055555505999999605500000
0000000000000000000000000000000000000000000000000000000000000060000a9a00000aaa00000a90005555555533333333000000000000000000000000
0033300000333000003330000033300000333000000000000060000606600060009444a000a9a9a0009aa900556666553bbbbbb3000000000000000000000000
033fff00033fff00033fff00033fff00033fff0000888700006000600060666004444440044444a00499a9005656666535555553000000000000000000000000
03f8f80003f8f80003f8f80003f8f80003f8f80008788880006600600066606000444440004994400499aa905665666555666655000000000000000000000000
00999900009999f00f999900009999f00f999900088888000066060000600060004444400044940004999a905666566556656565000000000000000000000000
0f5555f00f555500005555f00f555500005555f00800000000666600006000600444444004444440049a99905666656556565665000000000000000000000000
00400400044004000040440004400400004044000888888000606000006000000444444004944440004999005566665555666655000000000000000000000000
00400400000004000040000000000400004000000070007000000000000000000044440000444400000444005555555555555555000000000000000000000000
00000000000770000000000000000000000000000000000000000000000000008000000800000000000000000000000000000000000000000000000000000000
00000000077777700000000000000000000000000000000000000000000000000800008000666660000000000000000000000000000000000000000000000000
000567700777777000000000000000000000000000ddd00000000000000000000080080006655566000000000000000000000000000000000000000000000000
56777777777777770000000000000000000000000ddfff0000000000000000000008800006655566000000000000000000000000000000000000000000000000
56777777777777770000000000000000000000000dfefe0000000000000000000008800006665666000000000000000000000000000000000000000000000000
00056770077777700000000000000000000000000022220000000000000000000080080000666660000000000000000000000000000000000000000000000000
00000000077777700000000000000000000000000f5555f000000000000000000800008000000000000000000000000000000000000000000000000000000000
00000000000770000000000000000000000000000030030000000000000000008000000800000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056
005550000055500000555000005550000055500000000000000000000000000000000000000000000000000000000000000000000000000000000000111111c6
055666000556660005566600055666000556660000555600000000000000000000000000000000000000000000000000000000000000000000000000222222ef
056565000565650005656500056565000565650005655550000000000000000000000000000000000000000000000000000000000000000000000000333333b7
0055550000555560065555000055556006555500055555000000000000000000000000000000000000000000000000000000000000000000000000004444449f
06555560065555000055556006555500005555600500000000000000000000000000000000000000000000000000000000000000000000000000000055555567
00500500055005000050550005500500005055000555555000000000000000000000000000000000000000000000000000000000000000000000000066666677
00500500000005000050000000000500005000000060006000000000000000000000000000000000000000000000000000000000000000000000000077777777
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000058c0e0b0888888ef
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090607070999999f7
0000000000000000000000000000000000000000005550000000000000000000000000000000000000000000000000000000000000000000e0f07060aaaaaa77
000000000000000000000000000000000000000005566600000000000000000000000000000000000000000000000000000000000000000060c0f070bbbbbb67
00000000000000000000000000000000000000000565650000000000000000000000000000000000000000000000000000000000000000006860f070cccccc67
0000000000000000000000000000000000000000005555000000000000000000000000000000000000000000000000000000000000000000f0707070ddddddc6
0000000000000000000000000000000000000000065555600000000000000000000000000000000000000000000000000000000000000000f0707070eeeeeef7
000000000000000000000000000000000000000000500500000000000000000000000000000000000000000000000000000000000000000070607070ffffff77
10000000000000001000000000001010100000000000000000000000000000102011111111111111112000000000001010100000000000101000000000001010
10100000000000101000000000001010101000000000001010000000000010101010000000000010100000000000101010100000000000101000000000001010
1000840000000000101010101010101010840000000000000000100000100010202020202020202020200000000000101010840000000000b400000000101010
1010840000000000b4000000001010101010840000000000b4000000001010101010840000000000b4000000001010101010840000000000b400000000101010
10101000000000101010101010101010101000540054005400001060601050101010101010101010101054005410001010101000540010101010000000001010
10101000540010101010000000001010101010005400101010100000000010101010100054001010101000000000101010101000540010101010000000001010
10101010101010101010101010101010101010105010501010101010101010101010000000000000101010501010001010101010101010101010100000001010
10101010101010101010100000001010101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001010
00000000000000000000000000101010000000000000000000000000001010101000000000000000006060600000001000000000000000000000000000101010
00000000000000000000000000101010000000000000000000000000001010100000000000000000000000000010101000000000000000000000000000101010
000000000000000000000000000010100000000000000000000000000000101010000084000000b4000000000000001000000000000000000000000000001010
00000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010
00000000000000000000000000001010009500000000000000000000000010101000001000000010101010101010501000000000000000000000000000001010
00000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010
00c0d0e0f0000000000000000000001000c0d0e0f000000000000000000000101000000000000060606060600000841000c0d0e0f00000000000000000000010
00c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f00000000000000000000010
00c1d1e1f1000000000000000000001000c1d1e1f100000000000000000000101000000000000060000000600010101000c1d1e1f10000000000000000000010
00c1d1e1f1000000000000000000001000c1d1e1f1000000000000000000001000c1d1e1f1000000000000000000001000c1d1e1f10000000000000000000010
1010101010101010100000b4000000101010101010101010100000b400000010100000000000000000000000000000101010101010101010100000b400000010
1010101010101010100000b4000000101010101010101010100000b4000000101010101010101010100000b4000000101010101010101010100000b400000010
10101010101010101010101000000010101010101010101010101010000000101000000000000000b46000000000001010101010101010101010101000000010
10101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001010101010101010101010101000000010
10101010001010101010100000001010101010100010101010101000000010101000000000000010101010100010001010101010001010101010100000001010
10101010001010101010100000001010101010100010101010101000000010101010101000101010101010000000101010101010001010101010100000001010
10100000000000101000000000001010101000000000001010000000000010101010101010101010000000000000001010100000000000101000000000001010
10100000000000101000000000001010101000000000001010000000000010101010000000000010100000000000101010100000000000101000000000001010
1010840000000000b4000000001010101010840000000000b400000000101010100000000000000000000000000000101010840000000000b400000000101010
1010840000000000b4000000001010101010840000000000b4000000001010101010840000000000b4000000001010101010840000000000b400000000101010
1010100054001010101000000000101010101000540010101010000000001010108400005400b4005400c4000000001010101000540010101010000000001010
10101000540010101010000000001010101010005400101010100000000010101010100054001010101000000000101010101000540010101010000000001010
10101010101010101010100000001010101010101010101010101000000010101010101010101010101010101010501010101010101010101010100000001010
10101010101010101010100000001010101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001010
10101010101010101010101000001010000000000000000000000000001010100000000000000000000000000010101000000000000000000000000000101010
00000000000000000000000000101010000000000000000000000000001010100000000000000000000000000010101000000000000000000000000000000000
10100000101010100000001000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010
00000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000000000
10000000001010000000000000101010009500000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010
00000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000a15152007200a1520000a151520000
1084000010100000000000b40010101000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f00000000000000000000010
00c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000610000006100610072006100007200
1010000010100000000010101010101000c1d1e1f1000000000000000000001000c1d1e1f1000000000000000000001000c1d1e1f10000000000000000000010
00c1d1e1f1000000000000000000001000c1d1e1f1000000000000000000001000c1d1e1f1000000000000000000001000825152006100610061006100006100
101000001010001000001000000000101010101010101010100000b4000000101010101010101010100000b4000000101010101010101010100000b400000010
1010101010101010100000b4000000101010101010101010100000b4000000101010101010101010100000b40000001000610000006100610061006100006200
10100000100000100000000000000010101010101010101010101010000000101010101010101010101010100000001010101010101010101010101000000010
10101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001000620000006200620062007151520000
10100000000000108400000010000010101010100010101010101000000010101010101000101010101010000000101010101010001010101010100000001010
10101010001010101010100000001010101010100010101010101000000010101010101000101010101010000000101000000000000000000000000000000000
10101000000000101000000010000010101000000000001010000000000010101010000000000010100000000000101010100000000000101000000000001010
1010000000000010100000000000101010100000000000101000000000001010101000000000001010000000000010100000b3c300e292d200e300e292c30000
101010000000000000000000100000101010840000000000b4000000001010101010840000000000b4000000001010101010840000000000b400000000101010
1010840000000000b4000000001010101010840000000000b4000000001010101010840000000000b40000000010101000e3000000a200a200a200a20000e300
10101010100000005400101010008410101010005400101010100000000010101010100054001010101000000000101010101000540010101010000000001010
10101000540010101010000000001010101010005400101010100000000010101010100054001010101000000000101000a2000000a200a200a200a20000d300
10101010101010101010101010101010101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001010
10101010101010101010100000001010101010101010101010101000000010101010101010101010101010000000101000a200e300a200a200a200b292c30000
30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a200a200a200a200a2000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b292c200b292c200b2929292c30000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0081410181838581010100000100000000588888810000000000000001010101818181000000000000000000000000408180808000808080808080000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000010101000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000010101000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000000000
0000000000000000222222222222000000000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101
0000000000000022222222222222220000000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101
00000000000000222222222222222200000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001
00000000000000200000000000002100001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001
00000000000000200000000000002100010101010101010101010000000101010101010101010213131313020100000101010101010101010100004b0000000101010101010101010100004b0000000101010101010101010100004b0000000101010101010101010100004b0000000101010101010101010100004b00000001
0059000000000020000000000000210001010000000101010101000000010101010000000101020212120202000000010101010101010101010101010000000101010101010101010101010100000001010101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001
000c0d0e0f000000000000000000210001000000000000010100000000010101010048004501010202020200000001010101010100010101010101000000010101010101000101010101010000000101010101010001010101010100000001010101010100010101010101000000010101010101000101010101010000000101
001c1d1e1f000000000000005500210001000000000000000000000000010101010001010101000101000000000001010101000000000001010000000000010101010000000000010100000000000101010100000000000101000000000001010101000000000001010000000000010101010000000000010100000000000101
01010101010101010101010101010101014800010000000000000005050101010100000101000000000000000001010101014800000000004b0000000001010101014800000000004b0000000001010101014800000000004b0000000001010101014800000000004b0000000001010101014800000000004b00000000010101
010101010101010101010101010101010101000101450000004b000101010101010000000000000000000101010101010101010045000101010100000000010101010100450001010101000000000101010101004500010101010000000001010101010045000101010100000000010101010100450001010101000000000101
0101010101010101010101010101010101010000010101010101010101010101010000000000000000000000000001010101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001010101010101010101010101000000010101010101010101010101010000000101
3030303030303030303030303030303001010000000000000006000000010101010000000000000000000000000000010000000000000000000000000001010100000000000000000000000000010101000000000000000000000000000101010000000000000000000000000001010100000000000000000000000000010101
3030303030303030303030303030303001010000000000000000000000000101010000000000000101050100000000010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101
3030303131313130303030303030303001010500000006000000480000000101010000000000000001010000000048010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101
303030313331313130303030303130300101010101010101010101010000010101010001010000000000000000000101000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001
303031313131313131313031313131300101000000000000000000000001010101010002000000000000000201010101001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001
30303131313136313131313131313130014800000000000000000000000101010100000211111111111111020000000101010101010101010100004b0000000101010101010101010100004b0000000101010101010101010100004b0000000101010101010101010100004b0000000101010101010101010100004b00000001
30313135313131313131313131313030012f000000010000000000010101010101000002020202020202020200004c010101010101010101010101010000000101010101010101010101010100000001010101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001
30313131313131313138313131313030013f0000000100000000000100000101010005010101010101010101000001010101010100010101010101000000010101010101000101010101010000000101010101010001010101010100000001010101010100010101010101000000010101010101000101010101010000000101
3030313131313731313131313131303001010000010100000000000148000101010001010101010101010100000001010101000000000001010000000000010101010000000000010100000000000101010100000000000101000000000001010101000000000001010000000000010101010000000000010100000000000101
30303131313131313031313131313030010100000001004500450001010001010100000000060606060600000001010101014800000000004b0000000001010101014800000000004b0000000001010101014800000000004b0000000001010101014800000000004b0000000001010101014800000000004b00000000010101
3030303031303030303031313130303001010100000105010101050100000101010000000000000048000000000001010101010045000101010100000000010101010100450001010101000000000101010101004500010101010000000001010101010045000101010100000000010101010100450001010101000000000101
3030303030303030303030303030303001010101000001060606010000000101010501021313131313131302000000010101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001010101010101010101010101000000010101010101010101010101010000000101
0000000000000000000000000001010101000000000000000000000000000101010101020212121212120202000000010000000000000000000000000001010100000000000000000000000000010101000000000000000000000000000101010000000000000000000000000001010100000000000000000000000000010101
0000000000000000000000000001010101000000000000000000000000000101010101020202020612060202010000010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101
0000000000000000000000000000010101000100050000050505000001010101010000000000020212020201060000010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101
000c0d0e0f00000000000000000000010100000001010101010101010101010101480000000000020202060606000101000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001000c0d0e0f0000000000000000000001
001c1d1e1f00000000010100000000010100000000060600000006060000000101010000000000000000000000000101001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001001c1d1e1f0000000000000000000001
01010101010101010101010100000001010001000000000000000000000000010100000000000000000000000000010101010101010101010100004b0000000101010101010101010100004b0000000101010101010101010100004b0000000101010101010101010100004b0000000101010101010101010100004b00000001
0101010101010100000000010100000101050101000045000101010101010001010000010000000000000000000001010101010101010101010101010000000101010101010101010101010100000001010101010101010101010101000000010101010101010101010101010000000101010101010101010101010100000001
0101000000000000000000000100010101010101010101010100000000000001020000000000010000020100010501010101010100010101010101000000010101010101000101010101010000000101010101010001010101010100000001010101010100010101010101000000010101010101000101010101010000000101
__sfx__
01030000306732607335700307002b70026700217001c70017700127000d70008700037000170001700017003f70001700037000d700127001870000700007000070000700007000070000700007000070000700
010800003047330605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002e0502a0501e0501a0501a0501a0501e05027050310503305035050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000134501544017430194201b4102040025400294002d4003340036400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000700001b6303a6303763033630306302d6302a6202662023610206101d60018600146000f600286002d60000600006000060000600006000060000600006000060000600006000060000600006000060000600
00010000390502905015050080501d650236501f65007050100001e0500b00015050010002705020000150000d000150000000028000000000000000000000000000000000000000000000000000000000000000
000100002a6202a6403f420106503c410080700105000000000000000000000000000000000000000000000000000000000000000000270000000000000000000000000000000000000000000000000000000000
000100002b5703a420120600907005060030400202001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000110200d010010000300000000000000000000000000000000000000000000150001500000002250000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000134301542017400194001b4002040025400294002d4003340036400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
00040000300502d0502a0502705024040210301e0201b010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001613010130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000024050280502b0503005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000000d0450c6150d04518615090450c6150804524615060450c6151204518615100450c6150804519044090450c6150904518615150450c6151404524615120450c61510045186150f0450c6150b04523214
0120003f19324193221932520324203221e3221e3251c3241c32219322193251b3241b32223321233252132421322213222132520324203221e3221e3251c3241c32219322193251b3241b3221c3211c3221c325
01100020090251002515025190251c02520025090251002515025190251c02520025090251002515025190250b0251202517025190251c0251e0250b0251202517025190251c0251e0250b025120251702519025
011c0000140450f0451b0451d04519045110450d04516045140450f0451b0451d04519045110050d00516005140450f0451b0451d04519045110450d04516045170451b04520045220451204516045190451b045
011c000024615000050e6150000524615000050e6150000524615000050e61500005246153c6153c6153c61524615000050e6150000524615000050e6150000524615000050e6150000524615000050e61500005
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 10 42 43 44
00 10 11 43 44
02 12 11 43 44
01 13 42 43 44
02 13 14 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
