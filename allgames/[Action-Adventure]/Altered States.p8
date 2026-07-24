pico-8 cartridge // http://www.pico-8.com
version 8
__lua__

lt = {"awakenings","another door", "evil lurks", "locked in", "altered reality", "falling free","set a trap","butterfly","bouncy castle","jump and switch","can't jump this","freeze punk","final door"}
global_door = {}
global_door.x = -1
global_door.y = -1
target_dim = -1
show_dim_select = 0
dim_select_ticks = 0
clear_map = false

lines = {}
lines.l1 = ""
lines.l2 = ""
lines.l3 = ""
lines.col = 7
lines.ticks = 0
lines.state = 0
lines.next_state = 0

a_ticks = 0

portal = {}
portal.x = 0
portal.y = 0
portal.vis = false
portal.scale = 0
portal.f = 0
portal.sp = 96

glob_hit_down = false
ct = 5
ttf = 0
tdf = 0.2
no_save = false
special_ticks = 0
player = {}
player.x = 104
player.y = 24
player.dx = 0
player.ddx = 0.4
player.decx = 0.8
player.flipx = false
player.max_x = 2
player.dy = 0
player.ddy = 0.5
player.max_y = 4
player.jumpy = 3
player.glide = false
player.glide_count = 0
player.boost_count = 1
player.boost_ticks = 0
player.onground = true
player.jumpticks = 0
player.glide_pos = false
player.bf = 1
player.f = 0
player.zup = true
player.xup = true
player.fall_dist = 0
player.deadticks = 0
player.bonus_collect = 0
player.numdeaths = 0
sel_menu = 0

bonus_xx = 0
bonus_yy = 0


level_collect = 0

startx = 0
starty = 0
shake_timer = 0
flash_timer = 1
dxoff = 0
dyoff = 0

dispticks = 0
time_min = 0
time_sec = 0
time_ticks = 0


game_state = 0

world = {}
world.map_changes = {}
world.gravity = 1
world.collect_count = 0
world.exit_open = false

gravity = 0.5
max_x = 2
glide_max_x = 1
fall_max_y = 4
glide_max_y = 0.8
level = 1

map_objects,lava,lavaf = {},{},{},{}
land_particles = {},{}


function save_game()
	
	dset(0, time_min)
	dset(1, time_sec) 
	dset(2, level)
	
	local nd1 = player.numdeaths
	local nd2 = 0
	if (nd1 > 255) then
	  nd2 = flr(nd1/255)
	  nd1 = nd1 - nd2*255
	end
	 
	dset(3, nd1)
	dset(4, nd2)
	dset(10,1)
end

function set_player_params()
  if (player.dim < 2) then
			player.ddx = 0.4
			player.decx = 0.8
			player.max_x = 2
			player.ddy = 0.5
			player.max_y = 4
			player.jumpy = 3  
			max_x = 2
			world.enemy_x = 0.5
  elseif (player.dim == 2) then
			player.ddx = 0.25
			player.decx = 0.25
			player.max_x = 1.5
			max_x = 1.5
			player.ddy = 0.1
			player.max_y = 2
			player.jumpy = 2.25
			world.enemy_x = 0.25   
  else
			player.ddx = 0.4
			player.decx = 0.8
			player.max_x = 2
			max_x = 2
			player.ddy = 1
			player.max_y = 5
			player.jumpy = 2.5
			world.enemy_x = 0.75  
  end
end

function load_game()
  ct = 5
  level = dget(2)

  time_min = dget(0)
  time_sec = dget(1)
  time_ticks = 0
  local nd1 = dget(3)
	 local nd2 = dget(4)
	
	 player.numdeaths = nd2*255+nd1
  if (level > 13) level = 13
  load_level(level)
end

function dead()
  shake(12)
  player.deadticks = 18
  player.movable = false
  sfx(0)
  player.numdeaths += 1
  save_game()
end

function unlock(xx,yy,nn)

 
 for y = 0, 8 do
   v = mget(xx,y+yy)
   if (fget(v,6)) then
     mset(xx,y+yy,0)
   else
     if (y == 0) return
     break
   end
 end
 
 for y = 1, 8 do
   v = mget(xx,yy-y)
   if (fget(v,6)) then
     mset(xx,yy-y,0)
   else
     break
   end
 end

 for x = 1, 15 do
   v = mget(xx+x,yy)
   if (fget(v,6)) then
     mset(xx+x,yy,0)
   else
     break
   end
 end
 
 for x = 1, 15 do
   v = mget(xx-x,yy)
   if (fget(v,6)) then
     mset(xx-x,yy,0)
   else
     break
   end
 end
 
 if (not nn) then
 	obj = {}
 	obj.x = xx
 	obj.y = yy
 	obj.cf = 55
 	add(world.map_changes,obj)
 end
end

function add_lava(tp)
  l = {}
  l.x = rnd(127)
  l.y = - 60 - rnd(100)
  l.f = 0
  
  l.c = 5
  
  if (tp) then
    l.dy = rnd(4) + 1
    l.l = flr(rnd(80) + 24)
    l.w = flr(rnd(9) + 2)
    add(lava,l)
  else
    l.dy = rnd(2) + 4
    l.l = flr(rnd(3) + 1)
    l.w = flr(rnd(2) + 1)
    add(lavaf,l)
  end
end

function move_lava()
  for l in all(lava) do
    l.y += l.dy
    if (l.y > 130) then
      l.x = rnd(127)
      l.y = - 60 - rnd(100)  
    end
  end
  for l in all(lavaf) do
    l.y += l.dy
    if (l.y > 130) then
      l.x = rnd(127)
      l.y = - 60 - rnd(100)  
    end
  end
end

function draw_lava()
  for l in all(lava) do
    if (level < 31) then
      rectfill(l.x,l.y,l.x+l.w,l.y+l.l,l.c)
    else
      l.f += 0.33
      if (l.f > 1.8) l.f = 0
      spr(46+l.f,l.x,l.y)
    end
  end
end

function draw_lavaf()
  for l in all(lavaf) do
    rectfill(l.x,l.y,l.x+l.w,l.y+l.l,l.c)
  end
end

function _init()
  cartdata("proto_gc99")
  
  no_save = false
  if (dget(10) == 0) then
    no_save = true
  end
  
  game_state = 0
end

function new_game()
  ct = 5
  level = 1
  load_level(level)
  player.bonus_collect = 0
  player.numdeaths = 0
  time_min = 0
  time_sec = 0
  time_ticks = 0
  level_collect = 0
  game_state = 40
end

function add_level_object(v,x,y)
  if (v == 35) then    
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 35
    obj.fe = 37
    obj.fc = 3
    obj.wc = 20
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    if (is_in_map_changes(obj)) return false
    add(map_objects,obj)
  elseif (v == 32) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 32
    obj.fe = 32
    obj.fc = 500
    obj.wc = 20
    obj.cf = v
    obj.fd = 0
    obj.ticks = obj.fc
    add(map_objects,obj)
  elseif (v == 72) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 72
    obj.fe = 73
    obj.fc = 2
    obj.wc = 20
    obj.cf = v
    obj.fd = 1
    obj.rev = false
    obj.ticks = obj.fc
    if (is_in_map_changes(obj)) return false
    add(map_objects,obj)  
  elseif ((v >= 38) and (v <= 43)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 38
    obj.fe = 43
    obj.fc = 4
    obj.wc = 20
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 22) and (v <= 27)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 22
    obj.fe = 27
    obj.fc = 5
    obj.wc = 60
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  end
    
  --[[
    if ((v >= 48) and (v <= 51)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 48
    obj.fe = 51
    obj.fc = 5
    obj.wc = 30
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 22) and (v <= 27)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 22
    obj.fe = 27
    if (level > 20) then
      obj.fc = 5
      obj.wc = 35
    else
    	 obj.fc = 5
    	 obj.wc = 35
    end

    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 28) and (v <= 31)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 28
    obj.fe = 31
    if (level > 20) then
      obj.fc = 4
      obj.wc = 25
    else
    		obj.fc = 4
    		obj.wc = 25
    end

    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 38) and (v <= 43)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 38
    obj.fe = 43
    obj.fc = 4
    obj.wc = 20
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 53) and (v <= 54)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 53
    obj.fe = 54
    obj.fc = 8
    obj.wc = 8
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 32) and (v <= 34)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 32
    obj.fe = 34
    obj.fc = 3
    obj.wc = 10
    obj.cf = v
    obj.fd = 1
    obj.ticks = obj.fc
    obj.rev = true
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 48) and (v <= 51)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 48
    obj.fe = 51
    obj.fc = 10
    obj.wc = 10
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 35) and (v <= 37)) then
    --collectible
    if (level_collect == level) then
      return false
    end
    
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 35
    obj.fe = 37
    obj.fc = 3
    obj.wc = 20
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 76) and (v <= 77)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 76
    obj.fe = 77
    obj.fc = 20
    obj.wc = 5
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
  elseif ((v >= 56) and (v <= 59)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 56
    obj.fe = 59
    obj.fc = 3
    obj.wc = 16
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
   elseif ((v >= 60) and (v <= 63)) then
    obj = {}
    obj.x = x
    obj.y = y
    obj.fs = 60
    obj.fe = 63
    obj.fc = 3
    obj.wc = 16
    obj.cf = v
    obj.fd = 1
    obj.rev = true
    obj.ticks = obj.fc
    if ((v == obj.fs) or (v == obj.fe)) obj.ticks = obj.wc
    if (v == obj.fe) obj.fd = -1
    add(map_objects,obj)
   end
   ]]
  return true
end

function update_map_object(obj)
  
  if (level > 20) then
    if (rnd(1000) > 990) flash(rnd(2) + 2 )
  elseif (rnd(10000) > 9990) then
    flash(rnd(4) + 3)
  end
  
  if (obj.fd == 0) return
  
  obj.ticks -= 1
  if (obj.ticks < 1) then
    obj.cf += obj.fd
    if (obj.fd == 2) then
      obj.cf = obj.fs
      obj.fd = 1
    end
    obj.ticks = obj.fc
    if (obj.cf >= obj.fe) then
      obj.ticks = obj.wc
      if (obj.rev) then
        obj.fd = -1
      else
        obj.fd = 2
      end
    elseif (obj.cf <= obj.fs) then
      obj.ticks = obj.wc
      obj.fd = 1
      obj.cf = obj.fs
    end
    mset(obj.x,obj.y,obj.cf)
  end
end

function zpad(t,z)
  if (t > 9) return t
  return z..t
end

function is_in_map_changes(obj)
  for c in all(world.map_changes) do
    if ((c.x == obj.x) and (c.y == obj.y)) then
      return true
    end
  end
  return false
end

function setup_map(l,dm,nn)
		lava = {}
		lavaf = {}
		
		if (dm == 3) then
			for i = 0,15 do
			  add_lava(true)
			  if ((i % 3) == 0) add_lava(false)
			end
		end
		
  map_objects = {}
  land_particles = {}
  if (l < 5) then
    lr = flr(l/8)
    lc = l - (lr*8)
  elseif (l < 8) then
    lr1 = 5 + flr((l-5)*2)
    lr1 += player.dim
    lr = flr(lr1/8)
    lc = lr1 - (lr*8)
  elseif (l < 11) then
    lr1 = 11 + flr((l-8)*3)
    lr1 += player.dim
    lr = flr(lr1/8)
    lc = lr1 - (lr*8)  
  else
    lr1 = 20 + flr((l-11)*4)
    lr1 += player.dim
    lr = flr(lr1/8)
    lc = lr1 - (lr*8) 
  end
  
  xoff = 16*lc
  yoff = 16*lr
  
  for x = 0,15 do
    for y = 0, 15 do
      v = mget(x+xoff,y+yoff)
      if (fget(v,0)) then
        mset(x,y,0)
        startx = x * 8
        starty = y * 8
        if (nn) then
	        if (startx > 64) then
	          player.flipx = false
	        else
	          player.flipx = true
	        end
        end
      elseif (fget(v,3)) then
        mset(x,y,0)
        if(add_level_object(v,x,y)) mset(x,y,v)
      elseif (fget(v,4)) then
        mset(x,y,0)
        if (nn) then
          e = {}
          e.on_ground = true
		        e.spawnticks = 0
		        e.x = x*8
		        e.y = y*8
		        e.mx = x
		        e.my = y
		        e.sx = e.x
		        e.sy = e.y
		        e.f = 0
		        if (v == 75) then
		          e.cf = 75
		          e.dx = -1
		          e.dy = 0
		          e.tp = 0
		          e.alive = true
		        		e.vis = true
		        elseif (v == 77) then
		          e.cf = 77
		          e.dx = -1
		          e.dy = 0
		          e.tp = 5
		          e.alive = false
		          e.vis = false
		          mset(x,y,77)
		        end
		        e.ticks = 0
		        add(world.enemies,e)
		      end
      else
        mset(x,y,v)
      end
    end
  end
  open_exit()
  for mc in all(world.map_changes) do
    if (mc.cf == 55) then
      unlock(mc.x,mc.y,true)
    end
  end
  if (not nn) then
			for e in all(world.enemies) do
	    if (e.tp == 5) then
	      if (player.dim == 0) then
		      e.x = flr((e.x+4)/8)*8
		      e.y = flr((e.y +4)/8)*8
		      mset(e.x/8,e.y/8,77)
	       e.vis = false
	       e.alive = false
	      else
	        e.vis = true
	        e.alive = true
	      end
	    end
	  end  
  end
end

function load_level(l)
  special_ticks = 0
  dispticks = 40
  game_state = 5
  flash_timer = 0
	 shake_timer = 0
  player.glide = false
  player.glide_count = 0
  player.boost_count = 1
  player.boost_ticks = 0
  player.onground = true
  player.jumpticks = 0
  player.glide_pos = false
  player.bf = 1
  player.f = 0
  player.zup = true
  player.xup = true
  player.fall_dist = 0
  player.dx = 0
  player.dy = 0
  player.movable = false
  stop_glide()
  player.deadticks = 0
  player.has_key = false
  player.key_obj = nil
  
  world.map_changes = {}
  world.gravity = 1
  world.collect_count = 0
  world.exit_open = false
  world.max_dim = 0
  world.enemies = {}
  
  if (l > 4) world.max_dim = 1
  if (l > 7) world.max_dim = 2
  if (l > 10) world.max_dim = 3

  player.dim = 0
  
  setup_map(level, player.dim, true)
  set_player_params()
  player.x,player.y = startx,-9

end

function open_exit()
  if (world.exit_open == true) then
    for obj in all(map_objects) do
      if (obj.cf == 32) then
        obj.fs = 33
        obj.fe = 33
        obj.cf = 33
        mset(obj.x,obj.y,33)
        return
      end
    end   
  end
end

function intersect(r1l,r1r,r1t,r1b,r2l,r2r,r2t,r2b)
  local col = not ((r2l > r1r)
        or (r2r < r1l)
        or (r2t > r1b)
        or (r2b < r1t))
        
  glob_hit_down = false
   
  if (col) then
    if (r1b <= (r2t + 5)) then
      glob_hit_down = true
    end
  end
  
  return col
end

function enemy_collision()
  local r1l = player.x + 1
  local r1r = player.x + 6
  local r1t = player.y
  local r1b = player.y + 7
  
  for e in all(world.enemies) do
    if (e.alive) then
      if (intersect(r1l,r1r,r1t,r1b,e.x,e.x+7,e.y,e.y+7)) then
        if ((e.tp < 5) and (player.dy > 0) and (glob_hit_down) and ((player.dim == 0) or (player.dim == 2))) then
          e.alive = false
          add_land_particles(1)
          e.ticks = 20
          e.spawnticks = 0
          player.dy = -player.jumpy
          player.jumpticks = 11
          player.y -= 2
          sfx(4)
          return
        else
          dead()
        end
      elseif (e.y > 131) then
        e.alive = false
        e.ticks = 20
      end
    end 
  end  
end

function check_unlock()
  if (player.has_key) then
    if (global_door.x >= 0) then
      unlock(global_door.x, global_door.y, false)
      player.has_key = false
      player.key_obj = nil
      sfx(3)
    end 
  end
end

function solid (x, y)
 global_door.x = -1
 global_door.y = -1
 
 yy = flr(y)/8
 if (yy < 0) return false
 if (yy > 15.5) return false
 
 yy = flr(yy)
 xx = flr(flr(x)/8)
	val = mget(xx,yy)
	if (fget(val,6)) then
	  --can be unlocked
	  global_door.x = xx
	  global_door.y = yy
	  
	end 
	
	return fget(val, 1)
end

function death(x,y)
 
 yy = flr(y)/8
 if (yy < 0) then
   return false
 elseif (yy > 15.5) then
   return false
 end
 
	val = mget(flr(x)/8,yy)
	return fget(val, 2)
end

function boost(x,y)
 
 yy = flr(y)/8
 if (yy < 0) then
   return false
 elseif (yy > 15.5) then
   return false
 end
 
	val = mget(flr(x)/8,yy)
	return fget(val, 4)
end

function key(x,y)
 
 if (player.has_key) return false
 
 yy = flr(y)/8
 if (yy < 0) then
   return false
 elseif (yy > 15.5) then
   return false
 end
 
 yy = flr(yy)
	val = mget(flr(x)/8,yy)
	if (fget(val,3)) then
	  if ((val == 72) or (val == 73)) then
	    player.has_key = true
	    mset(flr(x)/8,yy,0)
	    player.key_obj = remove_level_obj(flr(flr(x)/8),yy)
	    return true
	  end
	end
	
	return false
end

function bonus(x,y)
 
 bonus_yy = flr(flr(y)/8)
 if (bonus_yy < 0) then
   return false
 elseif (bonus_yy > 15.5) then
   return false
 end
 
 bonus_xx = flr(flr(x)/8)
 
	val = mget(bonus_xx,bonus_yy)
	
	--if ((val == 92) or (val == 93)) then
	  -- on computer
	--  special_ticks = 20
	--end
	
	return fget(val, 5)
end

function pass_level(x,y)
 
 yy = flr(flr(y)/8)
 if (yy < 0) then
   return false
 elseif (yy > 15.5) then
   return false
 end
 
 xx = flr(flr(x)/8)
 
	val = mget(xx,yy)
	
	--if ((val == 92) or (val == 93)) then
	  -- on computer
	--  special_ticks = 20
	--end
	
	return fget(val, 7)
end

function win(x,y)
 
 yy = flr(y)/8
 if (yy < 0) then
   return false
 elseif (yy > 15.5) then
   return false
 end
 
	val = mget(flr(x)/8,yy)
	return fget(val, 7)
end

function stop_glide()
  player.glide = false
  player.max_y = fall_max_y
  player.max_x = max_x
  player.glide_pos = true
end

function move_player_x(ddx)
  player.dx += (ddx * player.ddx)
  if (ddx > 0) then
    player.flipx = true
  else
    player.flipx = false
  end
  
  if (abs(player.dx) > player.max_x) then
    if (player.dx > 0) then
      player.dx = player.max_x
    else
      player.dx = -player.max_x
    end
  end
end

function drag_player_x()
  if (player.dx == 0) return
  if (player.dx > 0) then
    player.dx -= player.decx
    if (player.dx < 0) player.dx = 0
  else
    player.dx += player.decx
    if (player.dx > 0) player.dx = 0
  end
end

function fall_player()
  player.dy += player.ddy
  if (player.dy > player.max_y) then
    player.dy = player.max_y
  end
end

function remove_level_obj(x,y)
  for obj in all(map_objects) do
    if ((obj.x == x) and (obj.y == y)) then
      add(world.map_changes,obj)
      del(map_objects,obj)
      return obj
    end
  end
  return nil
end


function add_land_particles(d)

  for i = 1,5 do
	  p = {}
	  p.x = rnd(6) + player.x + 1
	  p.y = player.y - 1
	  p.dy = 0.75 + rnd(1)
	  p.ddy = 0.05
	  if (d > 0) then
	    p.y += 9
	    p.dy = p.dy * -1
	    p.ddy = 0.35
	  else
	    p.dy = p.dy/2
	  end
	  
	  p.dx = -0.75 + rnd(1.5)
	  p.ticks = 8
	  add(land_particles,p)
  end
end

function draw_land_particles()
  for p in all(land_particles) do
    p.y += p.dy
    p.x += p.dx
    p.ticks -= 1
    p.dy += p.ddy
    if (p.ticks < 1) then
      del(land_particles,p)
    else
      pset(p.x,p.y,6)
    end
  end
end

function collect(x,y)
 yy = flr(y)/8
 xx = flr(x)/8
 if (yy < 0) then
   return false
 elseif (yy > 15.5) then
   return false
 end
 
 mset(xx,yy,0)
 
 remove_level_obj(flr(xx),flr(yy))
end

function setup_win()

end

function set_dimension()
  setup_map(level,player.dim,false)
  set_player_params()
end

function handle_enemy_death(e)
  e.ticks -= 1
  e.x += -1 + rnd(2)
  if (e.ticks < 1) e.vis = false
end

function update_enemy(e)
  if ((e.spawnticks > 0) and (e.tp < 5)) then
    e.spawnticks -= 1
    e.x += -0.3 + rnd(0.6)
    if (e.spawnticks == 0) then
      e.alive = true
    end
    return
  end
  
  if (e.alive == false) then
    if ((e.vis) and (e.ticks > 0)) then
      handle_enemy_death(e)
    else
      if ((e.vis == false) and (e.tp < 5)) then
        e.ticks += 1
        if (e.ticks > 240) then
          e.ticks = 0
          e.vis = true
          e.alive = false
          e.spawnticks = 20
          sfx(8)
          e.x = e.sx
          e.y = e.sy
        end
      end
    end
    return
  end
  
  if (e.tp == 0) then
    if (not(solid(e.x+4, e.y+8))) then
      --should fall
      e.dy += player.ddy
      if (e.dy > player.max_y) e.dy = player.max_y
      e.y += e.dy
      e.on_ground = true
      if (solid(e.x+4,e.y)) then
        e.y = flr(flr(e.y)/8)*8
        e.dy = 0 
        e.on_ground = false
      end
    else
	  		--move side to side
	    e.x += e.dx*world.enemy_x
	    if (solid(e.x+4,e.y)) then
        e.y = flr(flr(e.y)/8)*8
        e.dy = 0 
        e.on_ground = true
     end
	    
	    if (e.dx < 0) then
	      if (solid(e.x-1, e.y)) then
	        e.dx = -e.dx
	      elseif (solid(e.x,e.y + 8) == false) then
	        e.dx = -e.dx
	      end
	    else
	      if (solid(e.x + 9,e.y)) then
	        e.dx = -e.dx
	      elseif (solid(e.x+8,e.y + 8) == false) then
	        e.dx = -e.dx
	      end
	    end
	  end
  elseif (e.tp == 5) then
    if (not(solid(e.x+4, e.y+8))) then
      --should fall
      e.dy += player.ddy
      if (e.dy > player.max_y) e.dy = player.max_y
      e.y += e.dy
      e.on_ground = true
      if (solid(e.x+4,e.y)) then
        e.y = flr(flr(e.y)/8)*8
        e.dy = 0 
        e.on_ground = false
      end
    else
	  		--move side to side
	    e.x += e.dx*2
	    if (solid(e.x+4,e.y)) then
        e.y = flr(flr(e.y)/8)*8
        e.dy = 0 
        e.on_ground = true
     end
	    
	    if (e.dx < 0) then
	      if (solid(e.x-1, e.y)) then
	        e.dx = -e.dx
	      elseif (solid(e.x,e.y + 8) == false) then
	        e.dx = -e.dx
	      end
	    else
	      if (solid(e.x + 9,e.y)) then
	        e.dx = -e.dx
	      elseif (solid(e.x+8,e.y + 8) == false) then
	        e.dx = -e.dx
	      end
	    end
	  end  
  end
end

function _update()

		a_ticks += 1
  if (game_state < 2) then
    ct -= 1
    if (ct < 1) then
      if (btnp(4) or btnp(5)) then
        if (game_state == 0) then 
          if (sel_menu == 1) then
            new_game()
          else
            load_game()
          end
          music(20)
          return
        else
          game_state = 0
          ct = 30
          music(-1)
          return
        end
      elseif (btnp(2) or btnp(3)) then
        sel_menu += 1
        if (sel_menu > 1) sel_menu = 0
      end
    end
    return
  end
  
  if (game_state == 20) then
  
    -- picking dimension
    if (btnp(5)) then
      show_dim_select = 0
      game_state = 10
    elseif (btnp(0)) then
      -- left
      if (player.dim == 2) then
        show_dim_select = 0
        game_state = 10
        return
      end
      
      if (world.max_dim >= 2) then
        game_state = 21
				    target_dim = 2       
      end
    elseif (btnp(1)) then
      if (player.dim == 3) then
        show_dim_select = 0
        game_state = 10
        return
      end
      if (world.max_dim >= 3) then
        game_state = 21
				    target_dim = 3      
      end    
    elseif (btnp(2)) then
      if (player.dim == 0) then
        show_dim_select = 0
        game_state = 10
        return
      end
      if (world.max_dim >= 0) then
        game_state = 21
				    target_dim = 0       
      end    
    elseif (btnp(3)) then
      if (player.dim == 1) then
        show_dim_select = 0
        game_state = 10
        return
      end
      if (world.max_dim >= 1) then
        game_state = 21
				    target_dim = 1       
      end      
    end
    dim_select_ticks = 10
    return
  elseif (game_state == 21) then
    if (show_dim_select == 2) then
      show_dim_select = 1
      sfx(5)
    end
    dim_select_ticks -= 1
    if (dim_select_ticks < 1) then
      sfx(6)
      game_state = 22
      dim_select_ticks = 12
		    show_dim_select = 0
		    portal.x = player.x - 4
		    portal.y = player.y - 3
		    portal.vis = true
		    shake(1)
		  end
    return
  elseif (game_state == 22) then
    dim_select_ticks -= 1
    if (dim_select_ticks < 1) then
      portal.scale = 1
      game_state = 23
      dim_select_ticks = 12
      clear_map = true
    end
    return
  elseif (game_state == 23) then
    dim_select_ticks -= 1
    if (dim_select_ticks < 1) then
      game_state = 24
      dim_select_ticks = 8
      clear_map = false
		  		player.dim = target_dim
						set_dimension()
						shake(1)
    end
    return
  elseif (game_state == 24) then
    dim_select_ticks -= 1
    if (dim_select_ticks < 1) then
      game_state = 30
      portal.vis = false
    end  
    return
  elseif (game_state == 30) then
				game_state = 10
		  if (solid(player.x+4,player.y+4)) then
      dead()
    end
				return   
  elseif (game_state == 40) then
    -- setup text
    lines.col = 0
    lines.ticks = 0
    game_state = 50
    if (level == 1) then
      if (lines.state == 0) then
	      lines.l1 = "death came as a mercy."
	      lines.l2 = "the horror of the crash"
	      lines.l3 = "fading from my mind."
	      lines.next_state = 1
      elseif (lines.state == 1) then
       lines.l1 = "neurons fire their last"
	      lines.l2 = "random signals."
	      lines.l3 = "blackness."
	      lines.next_state = 2      
      elseif (lines.state == 2) then
       lines.l1 = ""
	      lines.l2 = ""
	      lines.l3 = ""
	      lines.next_state = 3 
	      lines.ticks = 100     
      elseif (lines.state == 3) then
       lines.l1 = "my eyes open again."
	      lines.l2 = "why?"
	      lines.l3 = ""
	      lines.next_state = 0      
      end
    elseif (level == 2) then
					 if (lines.state == 0) then
	      lines.l1 = "what is this place?"
	      lines.l2 = "i feel unhinged from reality."
	      lines.l3 = ""
	      lines.next_state = 1
      else
       lines.l1 = "another ghostly door appears."
	      lines.l2 = "but how to open?"
	      lines.l3 = "and where does it lead?"
	      lines.next_state = 0   
      end
    elseif (level == 3) then
					 if (lines.state == 0) then
	      lines.l1 = "this place is not safe."
	      lines.l2 = "evil lurks here i know it."
	      lines.l3 = "dare i open more doors?"
	      lines.next_state = 0
      end
    elseif (level == 5) then
					 if (lines.state == 0) then
	      lines.l1 = "what is reality anymore?"
	      lines.l2 = "i feel the fabric fold."
	      lines.l3 = "press — to transcend."
	      lines.next_state = 0  
      end
    elseif (level == 6) then
					 if (lines.state == 0) then
	      lines.l1 = "what new power do i posess?"
	      lines.l2 = "will it help me escape?"
	      lines.l3 = "i don't know what's real..."
	      lines.next_state = 0  
      end    
    elseif (level == 8) then
					 if (lines.state == 0) then
	      lines.l1 = "more realities unfold."
	      lines.l2 = "each different then the other."
	      lines.l3 = "is there any escape?"
	      lines.next_state = 0
      end
    elseif (level == 12) then
					 if (lines.state == 0) then
	      lines.l1 = "a strange being is near."
	      lines.l2 = "it's energy barely contained"
	      lines.l3 = "in this reality."
	      lines.next_state = 0
      end
    elseif (level == 11) then
					 if (lines.state == 0) then
	      lines.l1 = "more realities unfold."
	      lines.l2 = "a heavy weight bears down"
	      lines.l3 = "on me."
	      lines.next_state = 0
      end
    elseif (level == 13) then
					 if (lines.state == 0) then
	      lines.l1 = "i feel release is near."
	      lines.l2 = "one more door..."
	      lines.l3 = "and then hopefully peace."
	      lines.next_state = 0
      end
    elseif (level == 14) then
					 if (lines.state == 0) then
	      lines.l1 = "reality folds back to one."
	      lines.l2 = "i am released from this"
	      lines.l3 = "strange prison."
	      lines.next_state = 1
      elseif (lines.state == 1) then
	      lines.l1 = "my eyes close for the"
	      lines.l2 = "last time."
	      lines.l3 = ""
	      lines.next_state = 2      
      else
	      lines.l1 = ""
	      lines.l2 = "the end"
	      lines.l3 = ""
	      lines.next_state = 0      
      end
    else
      lines.ticks = 200
      lines.next_state = 0
      lines.state = 0
    end
    return
  elseif (game_state == 50) then
    -- showing text and fading out

    lines.ticks += 1
    lines.col = 0
    if (lines.ticks < 10) then
      lines.col = 0
    elseif (lines.ticks < 20) then
      lines.col = 5
    elseif (lines.ticks < 30) then
      lines.col = 6
    elseif (lines.ticks < 120) then
      lines.col = 7
    elseif (lines.ticks < 130) then
      lines.col = 6
    elseif (lines.ticks < 140) then
      lines.col = 5
    elseif (lines.ticks < 160) then
      lines.col = 0
    else
      lines.state = lines.next_state
      game_state = 40
      if (lines.state == 0) then
        if (level < 14) then
          save_game()
    				  load_level(level)
    				else
    				  game_state = 1
    				  ct = 10
    				end
      end
    end
    return
  end

  if (player.movable) then
    
    if (player.y > 136) then
      dead()
      return
    end
  
    time_ticks += 1
    if (time_ticks >= 30) then
      time_ticks = 0
      time_sec += 1
      if (time_sec >= 60) then
        time_min += 1
        time_sec = 0
      end
    end
    
    if (btn(0)) then
      move_player_x(-1)
    elseif (btn(1)) then
      move_player_x(1)
    else
      drag_player_x()
    end

    if (player.boost_ticks > 0) then
      player.boost_ticks -= 1
    end
    
    if (player.boost_ticks == 0) then
      if (player.bf == 8) player.bf = 6  
    end
    
    if (player.bf == 12) then
      player.f += 0.25
      if (player.f > 0.5) then
        player.bf = 4
        player.f = 0
      end
				elseif (player.bf == 4) then
				  player.f += 0.2
				  if (player.f > 1) then
        player.f = 0
      end
				end
				
				if (btnp(5)) then
				  --switch dimensions
				  if (world.max_dim > 0) then
				    game_state = 20
				    show_dim_select = 2
				    target_dim = player.dim
				    sfx(5)
				  end
				end

    if (btn(2)) then
      if (player.glide) then
        if (player.boost_ticks < 1) then
          if ((player.boost_count > 0) and (player.xup)) then
            player.boost_count -= 1
            player.boost_ticks = 18
            player.xup = false
            player.bf = 8
            player.f = 0
      				end
    				else
      			--in boost and still holding
      			player.dy -= 0.4
      			player.dy -= (player.boost_ticks/40) 
    			 end
  			 end
			 else
  		  player.boost_ticks = 0
  		 player.xup = true
			 end

  		if (player.jumpticks > 0) then
    		player.jumpticks -= 1
  		end

  		if ((btn(4)) or (btn(2))) then
    		if (player.onground) then
      		if (player.zup) then
        		player.jumpticks = 10
        		player.dy = -player.jumpy
        		stop_glide()
        		player.glide_pos = false
        		player.zup = false
        		player.f = -0
        		player.bf = 12
        		add_land_particles(1)
      		end
    		elseif (player.jumpticks > 0) then
        player.dy -= player.ddy*0.6
    		else
      --toggle glide / fall
      -- uncomment below to 
      --re enable glide
      		--[[
      		if ((player.glide == false) and (player.glide_pos)) then
        		player.glide = true
        		player.max_y = glide_max_y
        		player.max_x = glide_max_x
        		player.zup = false
      		end
      		]]
    		end
  		else
    		player.jumpticks = 0
    		player.zup = true
    		if (player.glide_pos == false) player.glide_pos = true
    		if (player.glide) then
      		stop_glide()
    		end
  		end
		end
  
  if (player.deadticks == 0) then
    fall_player()
    player.y += player.dy
  end
  
  if (player.movable) then
    for obj in all(world.enemies) do
      update_enemy(obj)
    end
    enemy_collision()
	  -- check if hit ground
	  if (player.dy > 0) then
	    if ((solid(player.x+2,player.y+7)) or (solid(player.x+4,player.y+7))) then
	      check_unlock()
	      player.y = flr(flr(player.y)/8)*8
	      player.onground = true
	      player.glide_pos = true
	      player.boost_count = 1
	      if (player.glide) then
	        stop_glide()
	        player.boost_ticks = 0
	      else
	        if ((player.dy > 3) and (player.fall_dist > 15)) then
	          shake(2)
	          sfx(1)
	          player.bf = 13
	          player.f = 0
	          add_land_particles(1)
	        end
	      end
	      player.dy = 0
	      
	      player.fall_dist = 0
	      
	    elseif (player.dy > 0.5) then
	      player.onground = false
	    end
	  elseif (player.dy < 0) then
	    player.onground = false
	    if ((solid(player.x+2,player.y)) or (solid(player.x+4,player.y))) then
	      player.jumpticks = 0
	      player.y = flr(flr(player.y)/8)*8+8 
	      if (player.dy < -3) then
	        shake(2)
	        add_land_particles(-1)
	        sfx(1)
	      elseif (player.dy < -2) then
	        shake(1)
	        add_land_particles(-1)
	        sfx(1)   
	      end
	      player.dy = 0
	      player.fall_dist = 0
	      check_unlock()
	    end
	  end
  
    player.x += player.dx
  
  end
  
  if (game_state == 5) then
    if (player.y >= starty) then
      player.y = starty
      game_state = 10
      shake(6)
      player.movable = true
      add_land_particles(1)
    end
  end
    
  if (player.onground) then
    if (player.bf == 13) then
      player.f += 0.2
      if (player.f > 1.0) then
        player.bf = 1
      end
    else   
      player.bf = 1
      if (abs(player.dx) > 0.05) then
        player.bf = 2
        player.f += 0.35
        if (player.f > 1.95) then
          player.f = 0
        end
      else 
        player.f = 0
      end
    end
  elseif (player.glide) then
    player.bf = 6
    player.f += 0.2
    if (player.boost_ticks > 0) then
      player.f += 0.55
      if (player.f > 3.95) then
        player.f = 0
      end
    else
      if (player.f > 1.95) then
        player.f = 0
      end
    end
  elseif (player.dy > 0.75) then
    player.bf = 4
  end
  
  --check hit sides
  if (player.dx > 0) then
    if (solid(player.x+6,player.y+4)) then
      player.dx = 0
      player.x -= 1
      if (player.glide == false) player.f = 0
      check_unlock()
      --player.y = flr(flr(player.x)/8)*8-8 
    elseif (player.x > 120) then
      player.x = 120
      if (player.glide == false) player.f = 0
    end
  elseif (player.dx < 0) then
    if (solid(player.x+1,player.y+4))  then
      player.dx = 0
      player.x += 1
      player.f = 0
      if (player.glide == false) player.f = 0
      check_unlock()
    elseif (player.x < 0) then
      player.x = 0
      if (player.glide == false) player.f = 0
    end
  end 
  
  for obj in all(map_objects) do
    update_map_object(obj)
  end
  
  player.fall_dist += player.dy
  
  move_lava()
  
  if (player.movable) then
  
	  if (death(player.x+3,player.y+4)) then
	    dead()
	    return
	  elseif (boost(player.x+3,player.y+4)) then
	    player.boost_count = 1
	    collect(player.x+3, player.y+4)
	    sfx(3)
	    return
	  elseif (bonus(player.x+3,player.y+4)) then
	    world.collect_count += 1
	    collect(player.x+3, player.y+4)
	    sfx(2)
	    if (world.collect_count >= 3) then
	      world.exit_open = true
	      open_exit()
	    end
	  elseif (pass_level(player.x+3,player.y+4)) then
	   level += 1
	   game_state = 40
	   --music(20)
	   sfx(7)
	   return
	  elseif (win(player.x+3,player.y+4)) then
	    game_state = 1
	    ct = 60
	    --music(-1)
	    sfx(4)
	    setup_win()
	    return
	  elseif (key(player.x+3,player.y+4)) then
	    sfx(3)
	    return
	  end
  
  else
    if (player.deadticks > 0) then
      player.deadticks -= 1
      if (player.deadticks == 0) then
        load_level(level)
      end
    end
  end
  
end

function shake(sc)
  shake_timer = sc
end

function flash(sc)
  flash_timer = sc
end

function box_text(txt,y,tc,bc)
  w = (#txt * 4) + 8
  x = (128 - w) / 2
	  
	 rectfill(x,y,x+w,y+8,bc)
	 print(txt,x+4,y+2,tc)
	 
end

function draw_enemies()
  for obj in all(world.enemies) do
    if (obj.vis) then
      pal()
      if (obj.spawnticks > 0) then
        pal(5,6)
        pal(6,7)
        pal(3,7)
        pal(11,6)
      elseif (obj.alive == false) then
        pal(3,2)
        pal(11,8)
      end
      obj.f += 0.167 
      if (obj.f > 1.9) obj.f = 0
      spr(obj.cf+player.dim*16+obj.f,obj.x,obj.y)
    end
  end
end

function _draw()

 if (game_state == 0) then
   cls(0)
   
   print ("altered states",35,48,5)
   
   if (no_save) then
     print ("new game",48,90,10)
     sel_menu = 1
   else
	   if (sel_menu == 0) then
		   print ("resume",52,98,10)
		   print ("new game",48,106,6)
		  else
		   print ("resume",52,98,6)
		   print ("new game",48,106,10)	  
		  end
		 end
   return
 elseif (game_state == 40) then
   return
 elseif (game_state == 50) then
   cls(0)
   box_text(lines.l1,48,lines.col,0)
   box_text(lines.l2,56,lines.col,0)
   box_text(lines.l3,64,lines.col,0)
   return
 elseif (game_state == 1)  then
   cls(0)
	  h = 38
	  xx = 36
	  yy = 12
	  rectfill(xx,yy,xx+64,yy+h,1)
	  yy += 4
	  print("    victory!",xx,yy+2,7)
	  yy += 12
	  print("   time: " .. time_min .. ":" .. zpad(time_sec,"0"),xx+2,yy+2,7)
	  print(" deaths: " .. player.numdeaths ,xx+2,yy+10,7)
	  return
	end

 if (player.dim == 2) then
   cls(12)
 else
   cls(0)
 end
 
 draw_lava()
 if (shake_timer > 0) then
   shake_timer -= 1
   dxoff = rnd(2.75) - 1.5
   dyoff = rnd(2.75) - 1.5
 else
   dxoff = 0
   dyoff = 0
 end

 if (player.dim == 0) then
   pal(4,1)
   pal(15,6)
 elseif (player.dim == 1) then
   pal(4,0)
   pal(7,6)
   pal(11,6)
   pal(12,5)
   pal(13,5)
   pal(15,5) 
 elseif (player.dim == 2) then
   -- air
   pal(4,7)
   pal(12,1)
   pal(15,5)
 else
   pal(4,5)
   pal(15,7) 
 end
 
 if (flash_timer > 0) then
   flash_timer -= 1
   if (rnd(4) > 1) then
     pal(13,10)
     if (level > 20) then
       pal(8,10)
     end
   end
 end
 
 map(0,0,dxoff,dyoff)
 pal()
 draw_enemies()
 if (clear_map) cls(0)
 
 --draw portal
 if (portal.vis) then
   if ((a_ticks % 4) == 0) then
     portal.f += 2
     if (portal.f > 2) portal.f = 0
   end
   spr(portal.sp+portal.f,portal.x,portal.y,2,2)
 end
 
 if (clear_map) return
 
 if (player.dim == 1) then
   pal(1,5)
   pal(15,7) 
 end
 
 if (player.deadticks > 0) then
   if (rnd(5) > 3) then
     pal(15,10)
   end
   spr(15,player.x+dxoff,player.y+dyoff,1,1,player.flipx,false)
 else
   if ((player.glide) and (player.boost_count == 0) and (player.boost_ticks < 2)) then
     pal(12,6)
   end
   spr(player.bf+player.f,player.x+dxoff,player.y+dyoff,1,1,player.flipx,false)
	  if (player.has_key) then
	    spr(73,player.x+dxoff,player.y+dyoff-5,1,1,player.flipx,false)
	  end 
	end
	
	pal()
	
	if (clear_map == false) then
	  draw_land_particles()
	  draw_lavaf()
	end
	
	if (show_dim_select > 0) then
	  cx = 60
	  cy = 64
	  box_text("alter reality",cy-44,7,1)
	  spr(80,cx,cy)
	  pal(14,6)
	  if (target_dim == 0) pal(14,9)
	  rectfill(cx-5,cy-29,cx-4+20,cy-28+20,0)
	  sspr(0,32,8,8,cx-4,cy-28,16,16)
	  if (world.max_dim > 0) then
	    pal(14,6)
	    if (target_dim == 1) pal(14,9)
     rectfill(cx-5,cy+19,cx+16,cy+19+20,0)
	    sspr(8,32,8,8,cx-4,cy+20,16,16)
	  end
	  if (world.max_dim > 1) then
		  pal(14,6)
		  if (target_dim == 2) pal(14,9)
		  rectfill(cx-29,cy-5,cx-29+20,cy-5+20,0)
		  sspr(16,32,8,8,cx-28,cy-4,16,16)
		 end
		 if (world.max_dim > 2) then
		  pal(14,6)
	   if (target_dim == 3) pal(14,9)
	   rectfill(cx+19,cy-5,cx+39,cy+15,0)
	   sspr(24,32,8,8,cx+20,cy-4,16,16) 
	  end
	  pal()  
	end
	
	if (dispticks > 0) then

	  dispticks -= 1
	  rectfill(2,110,47,127,1)
	  print(zpad(time_min," ") .. ":" .. zpad(time_sec,"0"),8,112,7)
	  print("deaths:" .. player.numdeaths,4,121,7)
	  
	  box_text(lt[level],48,7,1)
	end
	
end
__gfx__
00000000005500000055000000550000005500000055000005550000055500000550000005550000055500000555000000000000000000000000000000055000
0000000000ff500000ff500000ff500000ff500000ff50000ff500000ff500000ff500000ff500000ff550000ff50000005500000055000000000000005ff500
0070070000fff00000fff00000fff00000fff00000fff0000fff00f00fff00000fff00000fff00000fff00f00fff000000ff500000ff5000000880000f0ff0f0
0007700000ff100000ff100000ff1000f1ff1100f1ff11f00ff111cc0ff11f000ff110000ff11f000ff111cc0ff11f0000fff00000fff0000008b000001ff100
00077000001111000001110000011000001110f000111000f1111cc000111c000011f10000111c00f1111cc000111c0000ff100000ff10000000800000111100
00700700001111000f1110f00001f00000111000001110000cc111100fc1111000f111100fc111100cc110000fc1111000011100001111000000000000011000
0000000000f11f000001100000011000001001000010100000011000000110000000101000011000000101000001100000011f0000f11f000000000001111110
00000000000110000010110000011000000100100010010000000000000000000000000000000000000010000000000000101100001001000000000000000000
c000000c5555555000a00a0000000aaa9899889a9aaa0000ffffffffffffff0f00ffff0f00ffff0f00ff0f0f00000000ffffffffffffffffffffffffaaaaaaaa
000000005555555500a00a00000aaa99a889889a888aaa00fffffffffff0fffffff0f0ffff0000f00f0000f000000000ffffffffffffffffffffffffaaaaaaaa
00000000666666650aa0aa00aaa88888a88988aa98888aaaf000000ff000000ff0000000f00000000000000000000000f000000ff000000fa000000aa000000a
00000000333333650a8aa8a000aaa888aa8aa8a0999aa000f000000ff000000f0000000f0000000f0000000f00000000f000000ff000000fa000000aa000000a
0000000033333365aa8aa8a0000aa9990a8aa8a0888aaa00f000000ff000000ff000000ff0000000f000000000000000f000000ff000000fa000000aa000000a
0000000033333365a88988aaaaa888890aa0aa0088888aaaff0000ff0f0000f00f0000000f0000000000000000000000ff0000fffa0000afaa0000aaaa0000aa
0000000033333365a889889a00aaa88800a00a0099aaa000fffffffffffff0fffff0f00f0f00000f0f00000f00000000ffffffffaaaaaaaaaaaaaaaaaaaaaaaa
c000000c333333659899889a0000aaa900a00a00aaa000000ffffff00f0ffff0000000f0000000f000000000000000000ffffff00aaaaaa00aaaaaa00aaaaaa0
00077000000770000077700000000000000cc00000000000000000000000000000000000000a0000000a0000a00a000a00000000000000000000000000050000
077cc77007700770007c7000000cc00000cbbc00000cc00000000000000000000009900000099000000aa0000a0990a000000000000000000555550000555000
77cccc7777000077007c700000cbbc000cbbbbc000cbbc00000760000007a000000770000007900000a77a0000a7aa0000000000000000000505050005505500
7cccccc770000007777c77700cbbbbc00cbbbbc00cbbbbc0007767000077a7000aaa77a0aa7797aa0999779a0a77a7a000000000000000000555550055050550
7cccccc7700000077c7c7c700cbbbbc000cbbc000cbbbbc000757700007977000a7799a00a7a77a0a977aa90aa7977aa00000000000000000505050005505500
7cccc7c77000000707ccc70000cbbc00000cc00000cbbc00000570000009700000077000000a700000a77a0000a97a0000000000000000000555550000555000
7cccccc770000007007c7000000cc00000000000000cc00000000000000000000009900000099000000aa0000a0990a000000000000000000000000000050000
7cccccc770000007000700000000000000000000000000000000000000000000000000000000a000000a0000a000a00a00000000000000000000000000000000
0a0a0a0aa0a00a0a0a0000a0000000000000000000000000000550000ffffff000aa8a0000aa0a0000a00a000000000000000000000000000000000000000000
aaaaaaaaaaa00aaaaa0000aa000000000000000000055000005cc500f444444f00a8aa000008a000000800000000800000000000000000000000000000000000
88aaaa8888a00a8888000088a000000a00000000005cc50000500500f499944f00aa8a00000a80000000000000000000aaaaaaaaa0a0a00aa0a0000a00000000
8aa88aa88a8008a88800008880000008000000000050050055600655f444944f00a8aa0000a00a0000000a00000000008a8a8a8a8a8a0a8a008a008000800080
8aa88aa88a8008a8880000888000000800000000556006556cc77cc6f449944f00aa8a00000a8000000a000000000000a8a8a8a8a80808a0a800000000000000
88aaaa8888a00a8888000088a000000a000000006cc77cc60cc77cc0f444944f00a8aa0000a80a0000a8000000080000aaaaaaaa00a0a00a0000a00a00000000
aaaaaaaaaaa00aaaaa0000aa00000000000000000cc77cc000600600f444444f00aa8a00000a8000000080000000000000000000000000000000000000000000
a0a0a0a0a0a00a0a0a0000a0000000000000000000600600000000000ffffff000a8aa0000a8a00000a0a0000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0ffffffffffffffffffffff00ffffff000000000009990000006600000bbbb0000bbbb00ffffffffffffffff00000055
e007cc7ee007667eecc7117ee007cc7effffffffffffffffffffffffffffffff0099900000009000006660000bbbbbb00bbbbbb0f444444ff444444f00005555
e007cc7ee007667eecc7117ee007cc7ef4ffff4f4444fff44f44ff4fff44ff4f000090000009900006666000bbbbbbbbbbbbbbbbf4f44f4ff4f44f4f05655565
e0dddddee055555eec55555ee077777ef44ff44444444f444444f44ff444f44f000990000000900000066000baa33aabbaa33aabf444444ff444444f55655555
e0d1d1dee050505eec57575ee075757ef4444444444444444444444ff444444f000090000009990000066000bbb33bbbbbb33bbbf4ffff4ff4ffff4f00605565
edd1111ee550000ee557777ee775555ef4444444444444444444444ff444444f00099900000909000006600000b88b0000b88b00f444444ff444444f06660555
e111111ee000000ee777777ee555555ef4444444444444444444444ff444444f00090900000999000006600000b88b000b8008b0f444444ff444444f66666065
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeef4444444444444444444444ff444444f0009990000000000006666000bb00bb0bb0000bbffffffffffffffff66666655
00076000ddddddddddddddddddddddddf4444444444444444444444ff444444f8a8a8a8aa8a8a8a8066666008a8a8a8aa8a8a8a888a88a88a88a88a800000055
00076000d0ddd0ddd0ddd0dddd00000dff44444444444444444444fff44444ffa44444488444444a000006008a8a8a8aa8a8a8a8855555588555555a00005555
00076000dddddd00dddddd00d00000ddf444444444444f444444444ff444444f84f4444aa4f44448000006005555555555555555a5a55a5a8585585805655565
77777777dddddd00dddddd00d00000ddf44444444444444444444fffff44444fa44444488444444a06666600577557755775577585555558a555555855655555
66676666ddddd000ddddd000dd00000df444444444444444444444fff444444f84444f4aa4444f48060000005555555555555555855665588566665a00605565
00076000dddd0000dddd0000ddd0d00dfff44444444444444444444ff444444fa44f4448844f444a066000000058850000588500a565565a8555555806660555
00076000dddd0000dddd0000dd0dddddff44444444f444444444444ff44444ff8444444aa444444806666600005885000588885085555558a555555866666065
00076000d0000000d0000000ddddddddf4444444444444444444444ff44444ffa8a8a8a88a8a8a8a06666600555555555500005588a88a888a88a88a66666655
0000000999000000a000009999000a00f4444444444444444444444ff444444f00000000000000000666666000bbbb0000bbbb0088a88a88a88a88a800000055
000000988890a0000000099888900000f4f44444444444444f44444ff444444f0666666006666660000000600bbbbbb00bbbbbb08bbbbbb88bbbbbba00005555
0a000998888900000009988888900000f4444444444444444444444ff444444f666666666666666600000060bbbbbbbbbbbbbbbbab8bb8ba8babbab805655565
00099888888990a00009888888900000f4444444444444444444444ff444444f655555566555555600666660baa33aabbaa33aab8bbbbbb8abbbbbb855655555
0009888888889000009988888899000af4f4444444444444444444fff444f44f655555566555555600000060bbb33bbbbbb33bbb8bb55bb88b5555ba00605565
00098888888899000098888888899000ff4f44f4444444f444444fffff44ff4f66666666666666660000006000b88b0000b88b00ab5bb5ba8bbbbbb806660555
009988888888890000988888888899000ffff4ff4ff44fff4f4fffffffffffff06666660066666600000006000b88b000b8008b08bbbbbb8abbbbbb866666065
0098888888888900009888888888990000fffffffffff55ffffff0000ffffff00000000000000000066666600bb00bb0bb0000bb88a88a888a88a88a66666655
009888888888990000988888888899000ffffffffffffffffffffff00ffffff00000000000000000060000008a8a8a8aa8a8a8a888a88a88a88a88a800000055
00998888888990000099998888899000fffffffffffffffffffffffff44fff4f0000000000000000060006008a8a8a8aa8a8a8a8855555588333333a00005555
00099888888900000000099888890000f4ff4f44444ff4f4f4ffff4ff4444f4f0000000000000000060006005555555555555555a5a55a5a8383383805655565
0000998888900a00000000988889000af444444444444444f444f44fff44444f000000000000000006666666566556655665566585555558a333333855655555
00a00988899000000000009888890000f4444444444444444444444ff444444f0000000000000000000006005555555555555555855665588366663a00605565
00000998990000000000009888990000fff444444444444444f4444ff4f4444f0000000000000000000006000068860000688600a565565a8333333806660555
000000999000a0000000009989900000ffff44f44ff4444fff4444fff44f4f4f000000000000000000000600006886000688886085555558a333333866666065
00000009900000000a000009990000a00ffffffffffffffffffffff00ffffff0000000000000000000000600666666666600006688a88a888a88a88a66666655
00000000000000000000000000000000777777777751000000000000000000847777777777770000000000000000000077777777777700000000000000000000
b4007700000000414141777777777777000077000000004141417777777777770000770000000032004177777777777700007700000000000041777777777777
77777777777777777777777777777777000000015767000000000000000000000000000057670000000000000000000000000000576700000000000000000000
77777700000000414141770000000077777777000000004141417700000000777777770000000000004177414141417700007700000000000000000000000277
00000000000000000000000000005100212121770000000000475757575757672121217700000000004757575757576700000077000000000047575757575767
00007700000000414141777777777777000077000000004141417777777777778400770000000000004177777777777700007700000000777777777777777777
00000000000000000000000000005184212121770000000000414141414141412121217700000000002121214141414100002177000000000021212121212121
00007700000000000000000000000000000077000000000000000000000000000000770000000000000000000000000000007700000000000000000000000000
00000000000000000000000000005177212121776161613200000000000000002121217700000000002121210000000000210077000000000021212121212121
00007700000000000000000000000000000000000000000000000000840000000000770000000000000000000000000000007700000000000000000000000000
00000000000000000000000000002121212121770000000000000000000000002121217700000000002121210000000000000077000000000021212121212121
00007777000000000000000000000000737377770000000000000000000000000000777700000000000000000000000000007700000000000000000000000000
00000000000000000000000000000000212121770000445464000000000000002121217700000000002121210000000000000077000000000021212121212121
010077b400b400b40000000000000000000077000000000000000000000000000000772121212121212121212121212100007300000000000000000000000000
00000000000000000000000000000000212121770000455565616161445454542121217700000000002121210000000021000077000000000021212121212121
47575757575757575757575757575767735757575757575757575757575757674757575757575757575757575757576747575757575757575757575757575773
00000032000000320000003200000000212121770000455565212121455555552121217700000000002121210000000000210077414100320021212100000000
84773200000000000000000000000077007741414141414141414141414141410000004141410000000000000000327700774141414141414141414141414100
77000000000000000000000000000000212121770000455565212121455555552121217700000000002121214454546400000077414100000021212100000000
77777777777777777777777777777777777741414141414141414141414141417700004141410000000000000077777777774141414141414141414141414100
00000000000000000000000000000000212121770000455565212121455555552121217700000032002121214555556500000077414144546421212100000000
00770000000000000000000000000000007741414141414141414141414141410000000000000000000000007700000000770000000000000000000000000000
00000000000000000000000000000000212121770000455565212121455555552121217700000000002121214555556500002177414145556521212100000000
00770000000000000000000000000000007700000000000000000000000000000000000000000000000000000000000000770000000000000000000000000000
00000000000000000000000000000000000000000000455565212121455555550000000000004454642121214555556500000000000045556521212173737373
00770000000000000000000000000000007700000000000000000000000000000077510000000000000000000000000000770000000000000000000000000000
21212121212121212121212121212121000000000000455565212121455555550000000000004555652121214555556500000000000045556521212100000002
0077000000000000000000000000000000770000000000000000000000000000847700000000000000000000000000000077000000000000b2b2b2b2b2b20000
44545454545454545454545454545464545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
00770000000000000000000000000000445400000000000000000000000000004454545454640000000000000000000000545454545454545454545454545464
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00770000000000000000000000000000455500000000000000000000000000005555555555650000000000000000000000555555555555555555555555555555
57575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757
00000000000000000000000041414132000000000000000000000000414141418441000000000000000000004141414100000000000000000000000041414141
32000000000000000000000000000000000000000041000000414100000000004141414141410000004141000000000000000000000000840000000000000000
00000000000000000000000041410000000000000000000000000000414141410041000000000000000000004141414100000000000000000000000041414141
00000000000047576700000000000000000000000041475767410000000000004141414141414757674100000000000000000000000047576700000000000000
00000000000000000000000087000000000000000000000000000000414141410041000000000000000000004141414100000000000000000000000041414141
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d4000000000000000000000000000000414141410041000000000000000000004141414100000000000000000000000041414141
010000000000000000000000000000d4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000000000000000000000047575767770000000000000000000000475757677700000000000000000000004757576700000000000000000000000047575767
57575757575757575757575757576777575757575757575757575757575767735757575757575757575757575757677757575757575757575757575757576777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b4b4b4b4004141000000000000000000000000000041410000000000008400000000000032414100000000000000000000000000004141000000000000000000
010000000000d4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67676767777777777777777767676767777777777777777777777777777777737377777777737373737373737777777777777777777777777777777777777777
47575767734757575757575757575767575757677747575757575757575757674757576777475757575757575757576747575767775757575757575757575767
00000000000000000000000000007731000000000000000000000000000077000000000000000000000000000000773100000000000000000000000000007731
0000d400000000000000000000d40000000000000000008400000000003200000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007731000000000000000000000000000077000000000000000000000000000000773100000000000000000000000000007731
57575757575757575767734757575757575757575757575757677747575757575757575757575757576773475757575757575757575757575767774757575757
44640000000000000000000000007731446400000000000000000000000077004464000000000000000000000000773144640000000000000000000000007731
41414173000000000000000000000032414141730000000000000000000084004141417300000000000000000021212100000073000000000000000000000000
55650000000000000000000000007731556500000000000000000000000077005565000000000000000000000000773155650000000000000032000000007731
41414173000000000047670000777777414141730000000000476700007777774141417300000000000000000077777700000073000000000047670000777777
55650000000000000000000000007731556500000000000000000000000077005565000000000000000000000000773155650000000000000000000000007731
41414173000000000000000000777777414141730000000000000000007777774141417300000000000000000077777700000073000000000000000000777777
55650000000000000000000000007700556500008400000000000000000077025565000000000000000000000000773155650000000000006284b20000007300
414141730000d4000000000000777777414141730000000000000000007777774141417300000000000000000077777702000073000000000000000000777777
55650000770000000000000000777777556500007700000000000000007777775565000077000000000000000077770055650000777777777777777777777777
54545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
55650000000000000000000000000000556500000000000000000000000000005565000000000000000000000000000055650000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
__gff__
000000000000000000000000000000000100040404040a0a0a0a08080a0a0a0c088008282828080808080c0c000002020c0c0c08001818420c0c08080c0c08080000000002020202080800100012121000000000020202020c0c0010001010100000000002020202000000100010101000000000020202020202001000101010
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080808080000000000000000000000000808080800000000000000000000000008080808000000000000000000000000080808080
__map__
5500000000000000000000000000000055555555555555555555555555555555000000000000000000000000000000005700000000000000230000000000000065656557000000004800000000000000656565656565656565656565777777776565656565656565656565657777777700000000000000000000000000000000
0000000000000000000000000000000055555555555555555555555555555555000000000000000000000000000000135700000000000000000000000000000000002357000000000000000000000000000000000000372377000000770000000000000000007700000000007714141400000000000000000000000000000000
0000000000000000000000000000000055555555555555555555555555555555100000000000000000000000000000135700000029292929262626260000002000000057000000007700000000000000000000000000370077000000770000000000000000007700000000207714141400000000000000747677000000000000
0000000000000000000000000000000055656565656565656565656565656555454545461212444545454545462344455700007475757575757575760074757600007757000077000000000000000023000000000074757575757575750000000000000000747575757575757714140000000000000000000077002300000000
000000000000000000000000000000005600000000000000000000000000005465656565757565656565656566006465570000000000000000000000000000000000005700000000000000000000000010000000004b00004b000000000000000000000000000000000000000000140000007700000000000077000000000000
0000000000000000000000000000000056000000000000000000000000000054000000000000000000000000000000135777000000000000000000000000000077000057161600000000000000000000757575757575757575757575757600777575757575757575757575757576001623001400000000000000747575757575
00000000000000000000000000000000560000000000000000000000000000540000000000000000000000000000001367234b0000000000000000000000000000000057000000000000000000004b0000000000000000000000000077772b774800000000000000000000237700000075760000000000000000000000000000
00000000000000000000000000000000560000000000000000000000002100540000000000000000000044757575754574757575757575757575760000002300000077571a1a1a00000074757575757500000000000000000000000077772b770000000000000000002b2b2b770000770000000000000000000000004b000000
000000000000000000000000000000005600000000000000000044454545455500001200000012000000671400002357000000000000000000000000000000000000006700000000000000000000000077777700000000000077777777772b777777770000000000007777777700000023000000007475757575757575761212
00000000000000000000000000000000560000000000000000005455555555552374757575757575757576000000005700000000000000000000000000747575770000370000001600160000000000000000000000004b000000000077772b770000000000000000000000007777000075757600007777777777777777777777
000000000000000000000000000000005600000000004445454555555555555500000000141414140000470000007757000000000000262626260000000000007700003700000000100000000000000000007777777777777777770077772b770000777777777777777777007700000000000000001414141414141414141414
000000000000000000000000000000005610000000005455555555555555555500000000000000000000570000000057000000000074757575757576000000107575757576000074757600000000002300000000000000000000000077772b770000000000000000000000007700007710000000000000000000004b0000004b
000000000000000000000000000000005545454545455555555555555555555500007700000000000000677777000057454546000000000000000000000000770000000000000000000000000000262677777777770000000000000077772b777777777777000000000000007777000075760000007475757575757575757576
000000000000000000000000000000005555555555555555555555555555555500007712000000000000000000002057555556000000000000000000000000002000000000000000000016000000262600000023774b000000000000000000770000000000000000000000000000000000000000000037000012000000000020
00000000000000000000000000000000555555555555555555555555555555554545454545454545454545454545455655555600004b0000004b00000000000075761616161616000000000074757576777777777744454545454545454545467777777777444545454545454545454600000000774445454545454545454546
0000000000000000000000000000000055555555555555555555555555555555555555555555555555555555555555555555554545454545454545454545454500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000131415230000000000141414141400004800000014141414140000000000000000000000000000000000000000770000000000000000000023000000000000000000000000000000004b4b4b4b4b4b4b4b4b4b4b4b4b4b4b4b00000000000000000000000000000000
4800000000000000000000000000000000000000000000131415000000000000141414141400000000000014141414140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007475757575757575757575757575757637373737373737373737373737373737
1b1b1b0000000074767700747576290000000000000000131415161616000000141414141400007700000014141414140000000000000000000000000000000000000000000000000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000160000007700000000770000230000000000001400000000000000141414141400000000000014141414140023000000000000000000000000000000000000000000000000000000000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000771600000000007712121200000000000000000000000000000000161616000000000000001616160000141414140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007700000000000000000000000000000077
1212140000000000000075757575757575757575760000000000000000000000000000000000000000000000000000000000000000480000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121216000000000000000000000000000000000000000000161616000000000000000000000077000000000000000000000000000000770000000000000000000000000000007700000000000000000000000000000077000000000000000000000000000000000000000077000000000000000000000000000000000000
12121212000000000000000000000000000000004b000000004b000000004b00000000000000000000000000000000000000000000770000000000000000007700000000000000000000000000000077000000000000000000000000000000770000000000000000000000000000000000000000000000000000000000000000
1212121212747575757575757576000077777777777777777777777777777777777777777777777777777777373737770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000770000000000000000000000000000000000000000
00000000000000000000000000000000004b0000000000000000000000001000230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007700000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000001a0077777777777777777777777777777777777777777777777700007777777777770077000000000000000000000000000000770000000000000000000000000000007700000000000000000000000000000000000000000000007700000000000000000000000000000000000000000000
1000000000000000000000000000000000000000000000000000000000000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
75760000004475757575757575757576480000000000000074757575757575750000000000000000747575757575757500000000000000000000002c0000000000000000000000000000002c0000773700000000000000000000002c000000000000000000000077000000000000000000000000000000000000000000000000
0000000000007700000000000000000000000000262600000037002626000000000000001200000000770000120000201000000000000000000000000000000000000000000000000000000000007720000000000000000000000000230000001000000000000000000000000000000010000000000000000000000000000000
0000000077444545454545454545454645454545454545454545454545454545454545454545454545454545454545454545460000000000000000000000444545454600004445454545454600004445454546000000000000000000770000004445454545454545454545454545454644454545454545454545454545454546
0000000000000000000000000000000055555555555555555555555555555555555555555555555555555555555555555555560000000000000000000000545555555600005455555555555600005455555556000000000000000000000000005555555555555555555555555555555555555555555555555555555555555555
__sfx__
000200002f0502a0502705024050210501e0501b050190501605013050110500e0500b05008050050500305002050010500105001050010500105001050010500105001050010400104001030010300102000000
01020000026500162001610016000d6000d6000d6000d6000d6000d6000d6000d6000d6000d6000d6000d6000d600036000160002600000000000000000000000000000000000000000000000000000000000000
000200001200014020170301c0501f050230502c050330502e000350003d0003f0002c000340003e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008000020300243502a3502e35000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000167521675216752187521a7521e75221752247521f752117520475202752214022a702205022b7020e3022b7022b7022a702287022070217702104020040200402004000040000400004000040000400
0002000035620000000000000000000002d6000000000000000002d60000000000002d600000002d600000002d6002d6002d6002d6002d6002d6002d6002d6002d6002d6002d6002d6002d6002d6002d6002d600
00040000333103a3203e3203f3303b330333402e34031340393403d340363402e34021340273402a3502f350353503a3503f3503d3503d3503b3502f3402d34033340373303b3303d33038320303202431032310
010100000761507615076150761007625076200762507620026250262202625026220262502620026250262507625076250762007622076250762007625076200760507602076050760507605076000760507605
00050000076150f5050762500505076250f50509625005050b625005050c615005050e6050050510505005050e5050f5051050510505105051050510505005051050500505105051050510505005051050500505
00100000000000000010472114021140200002114721140200000000001047210472000000000000000000000000000000000000000000000000000e4720e4020e47210402104721047200000000000000000000
0010000000402004020e472004021047200402114720040210472004020e4720e47200402004020e4720e4020e4720040210472104720000200402004020040200402004020e4020e4020e402004020e40210402
0010000000003000030c0730000300003000030e0730000300003000030c0730000300003000030000300003000030000300003000030000300003110730000311073000030c0730000300003000030000300003
001000000000300003110730000310073000030e073000031007300003110730e07300003000030e0730000300003000031007300003000030000300003000030000300003000030000300003000030000300003
0010000000000000000c000000000c6750c6050000000000000000000000000000000c67500000000000c6050c67500000000000000000000000000c6750000000000000000c6750000000000000000000000000
001000001057511575105750050511505005050e575005050e575005051057500505005050e5050e5751057511575105750e5750e5050e5050e5050e575005050e57500505105750050500505005050050500505
0010000011402004020040200402004020040211472004021147200402104721047200402004020e472004020e47200402104721047200402004020e472004021147200402104721047200402004020040200402
00100000004020040200402004020040200402114720040210472004021047210472004020040211472114021147200402104721047200402004020e4720e4020e47200402104721047200402004020040200402
00100000115750050511575005051057500505005050050500505005050e505005050e57500505115750050510575005050e505005050e505000050e005000050e50500505105750050511575005051057500505
001000000040200402114720040210472004020e4720e4720e4020040200402004020e472004021047210472114020040200402004020e4721047211472104720e4720e4720e402104020e4720e4021047210472
00100000004020040211472004021047200402104721047200402004020e472004020e4720040210472104720040200402004020040211472004021147200402104721047210402004020e472004021047210472
012c003f0062513600376253760000605006253762500000006251360037625376000060500625376250000000625136003762537600006050062537625000000062513600376253760000605006253762500000
012c000030521325212b5312b531376002b530000000000030521325212b5312b531376002b530000000000030521325212b5312b531376002b530000000000030521325212b5312b531376002b5300000000000
012c00001a5211a5011a5211a5011a5311a50113521000001a5211a5011a5211a5011a5311a50113521000001a5211a5011a5211a5011a5311a50113521000001a5211a501185211a50113531135311350100000
012c000024524245012452424505215311f5011a5212450124524245012452424505215311f5011a5212450124524245012452124505215311f5011a5212450124534245012453124501135311f5011f5011f505
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
03 15 42 43 44
00 08 42 43 44
01 08 09 0b 0d
02 08 0a 0c 0d
00 0e 42 43 44
01 0e 0f 0b 0d
02 0e 10 0b 0d
00 11 42 43 44
01 11 12 0b 0d
02 11 13 0b 0d
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 14 42 43 44
00 14 15 43 44
00 14 16 43 44
02 14 17 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
