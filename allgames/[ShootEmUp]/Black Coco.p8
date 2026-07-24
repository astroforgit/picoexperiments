pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- general
dbg_mode = false
dt = 0
last_time = 0

-- scene ids
scn_id_splash = 1
scn_id_ingame = 2

-- etype
et_base		= 0
et_flint	= 1
et_silver	= 2
et_billy	= 3
et_coco	= 4
et_ptree = 5
et_shellfish = 6
et_hcrab = 7
et_fx = 8

-- orient
orient_up		= "up"
orient_down		= "down"
orient_left		= "left"
orient_right	= "right"

-- layers
layer_bg_1      = 1
layer_bg_2      = 2
layer_entity_1 	= 3
layer_entity_2 	= 4
layer_entity_3  = 5
layer_fx 	      = 6
nb_layers 	     = 6

-- map offsets
map_off_x      = 11
map_off_y      = 5

-- maths
function num_format(n, d)
 local s = n
 local ten_power = 10
 for i=1,d-1 do
  if(n < ten_power) s = "0"..s
  ten_power *= 10
 end

 return s
end

-- strings
function str_split(s,sep)
 ret = {}
 bffr=""
 for i=1, #s do
  if sub(s,i,i) == sep then
   add(ret,bffr)
   bffr=""
  else
   bffr = bffr..sub(s,i,i)
  end
 end
 if (bffr != "") add(ret,bffr)
 return ret
end

function str_trim(s)
 local ss = 1
 local se = #s 
 while str_isspace(s, ss) do ss += 1 end
 while str_isspace(s, se) do se -= 1 end 
 return sub(s, ss, se)
end

function str_isspace(s,i)
 local c = sub(s,i,i)
 return c  == " " or c == "	"
end

-- random
function rnd_range(min, max)
 return min + rnd(max-min)
end

function rnd_range_i(min, max)
 return min + flr(rnd((max+1)-min))
end

function rnd_bool()
 return (rnd_range_i(0,1) == 1)
end

-- print outline
function print_outline(s, x, y, c1, c2)
 print(s, x-1, y, c2)
 print(s, x, y-1, c2)
 print(s, x+1, y, c2)
 print(s, x, y+1, c2) 
 print(s, x, y, c1)
end

-- burn effect
function be_create()
 return {
  active = false,
  t = 0,
  tmax = 0,
  colors = {9,0},
  c_tmin = 1,
  c_tmax = 2,
  c_grid = {},
  p_range_min = 2,
  p_range_max = 4,
  p_tmin = 1,
  p_tmax = 8,
  p_color_end = -1,
  p_grid = {},
  p_visited = {},
  p_bounds = {32,32,96,96},
  bg_grid = {}
 }  
end

function be_reset(be)
 be.active = false
 be.t  = 0
 be.tmax = 0
 be.c_grid = {}
 be.p_grid = {}
 be.p_visited = {}
 be.bg_grid = {}
end

function be_bg_capture(be)
 for x=0,127 do
  be.bg_grid[x] = {}
  for y=0,127 do
   be.bg_grid[x][y] = pget(x,y)
  end
 end
end

function be_ppoint_add(be,x,y)
 if(be_ppoint_visited(be,x,y)) return false
 be_ppoint_visit(be,x,y)

 if(x < be.p_bounds[1] or y < be.p_bounds[2] or x > be.p_bounds[3] or y > be.p_bounds[4]) return false

 if(be.p_color_end >= 0 and pget(x,y) == be.p_color_end) then
  be_cpoint_add(be,x,y,1)
  return false
 end

 local t = be.t + rnd_range_i(be.p_tmin, be.p_tmax)
 if(nil == be.p_grid[t]) be.p_grid[t] = {}
 if(nil == be.p_grid[t][x]) be.p_grid[t][x] = {}
 add(be.p_grid[t][x],y)

 if(t > be.tmax) be.tmax = t
 be_cpoint_add(be,x,y,1)
 be.active = true

 return true
end

function be_ppoint_visit(be,x,y)
 if(nil == be.p_visited[x]) be.p_visited[x] = {}
 be.p_visited[x][y] = 1
end

function be_ppoint_visited(be,x,y)
 if(nil == be.p_visited[x]) return false
 return 1 == be.p_visited[x][y]
end

function be_cpoint_add(be,x,y,ci)
 local t = be.t + rnd_range_i(be.c_tmin, be.c_tmax)
 if(nil == be.c_grid[t]) be.c_grid[t] = {}
 if(nil == be.c_grid[t][x]) be.c_grid[t][x] = {}
 be.c_grid[t][x][y] = ci
 if(t > be.tmax) be.tmax = t
 be.active = true
end

function be_update(be)
 if(not be.active) return
 be.t += 1
 --process propagation grid
 local p_grid_coord = be.p_grid[be.t]
 if nil != p_grid_coord then
  for x,row in pairs(p_grid_coord) do
   for y in all(p_grid_coord[x]) do
    be_propagate(be,x,y)
   end
  end
  be.p_grid[be.t] = {}
 end
 --process color grid
 local c_grid_coord = be.c_grid[be.t]
 if nil != c_grid_coord then 
  for x,row in pairs(c_grid_coord) do
   for y,ci in pairs(c_grid_coord[x]) do
    if(ci <= #be.colors) then
     pset(x,y,be.colors[ci])
     be_cpoint_add(be,x,y,ci+1)
    else
     pset(x,y,be.bg_grid[x][y])
    end
   end
  end
  be.c_grid[be.t] = {}
 end
 if(be.t >= be.tmax) be_reset(be)
end

function be_propagate(be,x,y)
 local range = rnd_range_i(be.p_range_min, be.p_range_max)
 --left
 for i=1,range do
  if(not be_ppoint_add(be,x-i,y)) break
 end
 --right
 for i=1,range do
  if(not be_ppoint_add(be,x+i,y)) break
 end
 --top
 for i=1,range do
  if(not be_ppoint_add(be,x,y-i)) break
 end
 --bottom
 for i=1,range do
  if(not be_ppoint_add(be,x,y+i)) break
 end
end

-- pendulum effect
function pendulum_create()
 return {
  active = false,
  x = 0,
  y = 0,
  rx = 24,
  ry = 12,
  angle = -0.5,
  v = 0,
  acc = 0.00025,
  dir = 1
 }
end

function pendulum_update(p)
 if(not p.active) return
 p.v += p.dir*p.acc
 p.angle += p.v
  
 if p.angle < -0.25 then
  p.dir = 1
 elseif p.angle > -0.25 then
  p.dir = -1
 end
 p.x = p.rx * cos(p.angle)
 p.y = p.ry * sin(p.angle) 
end

pendulum = pendulum_create()

-- entities
entities = {}

function ents_sort(a)
 for i=1,#a do
  local j = i
  while j > 1 and a[j-1].y > a[j].y do
   a[j],a[j-1] = a[j-1],a[j]
   j = j - 1
  end
 end
end

function ents_draw()
 --draw entities (filtered by layers)
 for i=1,nb_layers do
  for e in all(entities) do
   if (e.layer == i) ent_draw(e) end  
  end
end

function ents_pause()
 for e in all(entities) do
  e.paused = true
 end
end

function ents_unpause()
 for e in all(entities) do
  e.paused = false
 end
end

function ent_create(x, y, spr_val, config)
 local e = {
  type = et_base,
  x = x,
  y = y,
  dx = 0,
  dy = 0,
  timeframe = 0,
  time = 0,
  paused = false,
  --orient
  orient = orient_down,
  --velocity
  v = 0.1,
  -- height
  h = 0,
  hv = 0,
  hg = 0.08,
  --layer
  layer = layer_entity_1,
  --sprite
  spr_val = spr_val,
  spr_flipx = false,
  spr_flipy = false,
  spr_w = 1,
  spr_h = 1,
  spr_visible = true,
  --collision
  col_enabled = true,
  col_screen = false,
  col_w = 0.4,
  col_h = 0.4,
  col_x = 0,
  col_y = 0,
  --anim
  anim_name = "",
  anim_list = {},
  anim_index = 1,
  --snap
  snap_entity = nil,
  snap_x = 0,
  snap_y = 0,
  --colors
  swap_colors = {},
  --state
  state = "",
  state_timer = 0,
  --callbacks
  cb_update = nil,
  cb_draw = nil
 }

 for k,v in pairs(config) do
  e[k] = v
 end
	
 add(entities, e)
 return e
end

function ent_addanims(e, anims_str) 
 local anims = str_split(anims_str, "\n")
 for a in all(anims) do
  ent_addanim(e, str_trim(a))
 end
end

function ent_addanim(e, anim_param_str)
 local anim_param_arr = str_split(anim_param_str, "|")
 if(#anim_param_arr != 5) return
 e.anim_list[anim_param_arr[1]] = {
  speed = anim_param_arr[2],
  frames = str_split(anim_param_arr[3], ","),
  flipx = str_split(anim_param_arr[4], ","),
  flipy = str_split(anim_param_arr[5], ","),
 }
end

function ent_update(e)	
 if (e.paused) return
 --time
 e.timeframe += 1
 e.time += dt
 --state timer
 e.state_timer += dt
 --cb update
 if (nil != e.cb_update) e.cb_update(e)
 --anim
 if e.anim_name != "" and e.anim_list[e.anim_name] then			
  local anim = e.anim_list[e.anim_name]
  local nbframes = #anim.frames
  if nbframes > 0 then
   local anim_index = (flr(e.timeframe / anim.speed) % nbframes) + 1
   e.anim_index = anim_index
   e.spr_val = anim.frames[anim_index]			
   e.spr_flipx = (anim.flipx[anim_index] == "1")
   e.spr_flipy = (anim.flipy[anim_index] == "1")
  end
 end
	--move
 local vx = e.dx * e.v
	if (not solid_e(e, vx, 0)) e.x += vx
	local vy = e.dy * e.v
	if (not solid_e(e, 0, vy)) e.y += vy
 --height
 e.hv += e.hg
 e.h += e.hv
 if e.h >= 0 then
  e.h = 0
  e.hv = 0
 end

end

function ent_update_snap(e)
 local se = e.snap_entity
 if se != nil then
  e.x = se.x + e.snap_x
  e.y = se.y + se.h + e.snap_y
 end
end

function ent_draw(e)
 if e.spr_visible then
  for c1,c2 in pairs(e.swap_colors) do
   pal(c1, c2)
  end

  local x = (e.x - e.spr_w/2)*8
  local y = (e.y + e.h - e.spr_h/2)*8
  --hack: entities position according to map
  x += 56
  y += 24    
  
  spr(e.spr_val, x, y, e.spr_w, e.spr_h, e.spr_flipx, e.spr_flipy)
  for c1,c2 in pairs(e.swap_colors) do
   pal(c1, c1)
  end
 end

	if(nil != e.cb_draw) e.cb_draw(e)

	--draw box collider
 if dbg_mode and e.col_enabled then
  local ex, ey = e.x +  e.col_x, e.y +  e.col_y
  local cx = 56 + (ex - e.col_w)*8
  local cy = 24 + (ey - e.col_h)*8
  local cw = 56 + (ex + e.col_w)*8
  local ch = 24 + (ey + e.col_h)*8
  rect(cx, cy, cw, ch, 11)
	end
end

function ent_setstate(e, state)
 e.state = state
 e.state_timer = 0
end

-- camera
cam_x = 0
cam_y = 0
cam_shk_off_x = 0
cam_shk_off_y = 0
cam_shk_dx = 0
cam_shk_dy = 0
cam_shk_power = 0.05
cam_shk_countdown = 0
cam_shk_duration = 0.1
cam_shk_period = 0.05
cam_shk_damping = 0.4
cam_frame = 0

function cam_shake(duration)
 cam_shk_dx = rnd_bool() and 1 or -1
 cam_shk_dy = rnd_bool() and 1 or -1 
 cam_shk_duration = duration
 cam_shk_countdown = duration
end

function cam_update()
 cam_frame += 1
 if (cam_shk_countdown <= 0) return
 
 cam_shk_countdown -= dt
 if cam_shk_countdown <= 0 then
  cam_x = 0
  cam_y = 0
  return
 end

 cam_x -= cam_shk_off_x
 cam_y -= cam_shk_off_y

 local period_pos = (cam_shk_duration - cam_shk_countdown)/ cam_shk_period
 local period_count = flr(period_pos)
 local newoffsetdist = ((period_pos - flr(period_pos)) * 2.0 - 1.0) * cam_shk_power
 for i=0,period_count do
  newoffsetdist *= cam_shk_damping
 end
 cam_shk_off_x = cam_shk_dx * newoffsetdist
 cam_shk_off_y = cam_shk_dy * newoffsetdist

 cam_x += cam_shk_off_x
 cam_y += cam_shk_off_y
end

-- screen
function out_screen(x,y)
	if (x < 0)   return true
	if (x > 16)  return true
	if (y < 0)   return true
	if (y > 15)  return true
	return false
end

-- solid
function solid(x,y)
 return fget(mget(map_off_x + x, map_off_y + y), 0)
end

function solid_area(x,y,w,h)
 return	solid(x-w, y-h) or solid(x+w, y-h) or solid(x-w, y+h) or solid(x+w, y+h)
end

function solid_screen(x,y,w,h)
 return	out_screen(x-w, y-h) or out_screen(x+w, y-h) or out_screen(x-w, y+h) or out_screen(x+w, y+h)
end

function solid_et(e, vx, vy)
 for e2 in all(entities) do
  if e2 != e and e2.col_enabled then
   local x=(e.x+e.col_x + vx) - (e2.x + e2.col_x)
   local y=(e.y+e.col_y + vy) - (e2.y + e2.col_y)
   if abs(x) < (e.col_w + e2.col_w) and abs(y) < (e.col_h + e2.col_h) then 
    return col_rules_ets(e, e2)
   end
  end
 end
 return false
end

function solid_e(e, vx, vy)
 if(not e.col_enabled) return false
 if e.col_screen and 
    solid_screen(e.x + e.col_x + vx, e.y + e.col_y + vy, e.col_w, e.col_h) and
    col_rules_screen(e) then
    return true
 end
	
 if solid_area(e.x + e.col_x + vx, e.y + e.col_y + vy, e.col_w, e.col_h) and
    col_rules_wall(e) then
    return true
  end

 return solid_et(e, vx, vy)
end

-- flint
function flint_create(x, y)
 local f = ent_create(x, y, 64, {
  type = et_flint,
  v = 0.1,
  spr_w = 2,
  spr_h = 2,
  col_y = 0.3,
  col_w = 0.4,
  col_h = 0.4,
  col_screen = true,
  --life
  life = 1,
  --controls 
  controls_move_enabled = true,
  controls_throw_enabled = true,
  controls_catch_enabled = true,
  controls_shake_enabled = true,
  --coconut
  coco = nil,
  throw_force = 0.5,
  --callback
  cb_update = flint_update
 })

 --anims
 ent_addanims(f, [[
 stand_up|1|68|0|0
 stand_down|1|64|0|0
 stand_left|1|72|0|0
 stand_right|1|72|1|0
 stand_c_up|1|100|0|0
 stand_c_down|1|96|0|0
 stand_c_left|1|104|0|0
 stand_c_right|1|104|1|0
 move_up|5|70,70|0,1|0,0
 move_down|5|66,66|0,1|0,0
 move_left|5|72,74|0,0|0,0
 move_right|5|72,74|1,1|0,0
 run_left|2|72,74|0,0|0,0
 move_c_up|5|102,102|0,1|0,0
 move_c_down|5|98,98|0,1|0,0
 move_c_left|5|104,106|0,0|0,0
 move_c_right|5|104,106|1,1|0,0
 shake|1|76|0|0
 reject|1|76|1|0
 jump|1|108|0|0
 gameover|1|78|0|0]])

 return f
end

function flint_update(f) 
 local state_timer = f.state_timer
 local state = f.state

 if state == "state_normal" then
  flint_update_normal(f)
 elseif state == "state_throw" then
  if state_timer >= 0.25 then
   flint_normal(f, true, true, true, true)
  end
 elseif state == "state_shake_ptree" then
  if state_timer >= 0.25 then
   flint_normal(f, true, true, true, true)
  end
 elseif state == "state_reject_silver" then
  if state_timer >= 0.5 then
   flint_call_billy(f)
  end
 elseif state == "state_call_billy" then
  if state_timer >= 1.0 then
   billy_reach_silver(billy)
   flint_normal(f, false, false, false, false)
  end
 elseif state == "flint_state_intro_flee" then
  if f.x <= 4.2 then
   flint_intro_jump(f)
  end
 elseif state == "flint_state_intro_jump" then
  if f.h == 0 then
   flint_intro_catch_coco(f)
  end  
 elseif state == "flint_state_intro_catch_coco" then
  if state_timer >= 0.1 then
   flint_throw(f)
   ent_setstate(f, "flint_state_intro_throw")
  end
 elseif state == "flint_state_intro_throw" then
  if state_timer >= 1.75 then
   flint_shake_ptree(f)
   ent_setstate(f, "flint_state_intro_shake_ptree")
  end
 elseif state == "flint_state_intro_shake_ptree" then
  if state_timer >= 0.25 then
   f.anim_name = "stand_left"
  end
  if state_timer >= 1.75 then
   igm_run()
  end
 end
end

function flint_update_normal(f)
 f.dx,f.dy = 0,0
 if f.controls_move_enabled then
  if btn(0) then 
   f.dx = -1
   f.orient = orient_left
  elseif btn(1) then 
   f.dx = 1
   f.orient = orient_right
  elseif btn(2) then 
   f.dy = -1
   f.orient = orient_up
  elseif btn(3) then 
   f.dy = 1
   f.orient = orient_down
  end
 end

 --anim
 local anim_prefix = "stand_"
 if f.dx != 0 or f.dy != 0 then
  anim_prefix = "move_"
 end
 if f.coco != nil then
  anim_prefix = anim_prefix .."c_"
 end
 f.anim_name = anim_prefix ..f.orient

 local btnp_action = btnp(4) or btnp(5)
 if f.coco != nil then
  if f.controls_throw_enabled and btnp_action then
   flint_throw(f)
  end
 else
  --analyse cocos nearby
  local coco = coco_find(f.x, f.y, 1.7)
  if nil != coco then
   if f.controls_catch_enabled and btnp_action then
    flint_catch(f, coco)
   end
  else
   if f.controls_shake_enabled then 
    --palmtree range
    p_dirx = ptree_trunk.x - f.x
    p_diry = ptree_trunk.y - f.y
    p_dist = (p_dirx * p_dirx) + (p_diry * p_diry)
    local ptree_shake_area = 1.7
    if p_dist <= (ptree_shake_area * ptree_shake_area) then
     if (btnp_action) flint_shake_ptree(f)
    end
   end
  end
 end
end

function flint_intro_flee(f)
 f.dx = -1
 f.anim_name = "run_left"
 f.v = 0.15
 sfx(5,3)
 ent_setstate(f, "flint_state_intro_flee")
end

function flint_intro_jump(f)
 f.anim_name = "jump"
 f.hv = -0.45
 sfx(4,3)
 ent_setstate(f, "flint_state_intro_jump")
end

function flint_intro_catch_coco(f)
 f.dx = 0
 flint_catch(f, cocos[1])
 f.anim_name = "stand_c_left"
 ent_setstate(f, "flint_state_intro_catch_coco")
end

function flint_catch(f, coco)
	f.coco = coco
 coco_caught(coco)
 if coco.ct == ct_heavy then
  f.v *= 0.5
 end
end

function flint_throw(f)
 local coco = f.coco
	coco.snap_entity = nil
	coco.x = f.x + -0.3
	coco.y = f.y
 coco_throw(coco, 1, 0, f.throw_force)
 if coco.ct == ct_heavy then
  f.v /= 0.5
 end
	f.coco = nil
 f.dx = 0
 f.dy = 0
 f.anim_name = "stand_right"  
 ent_setstate(f, "state_throw") 
end

function flint_shake_ptree(f)
 f.dx = 0
 f.dy = 0
 ptree_shake()
 cam_shake(0.25)
 f.anim_name = "shake" 
 ent_setstate(f, "state_shake_ptree")
end

function flint_call_billy(f)
 f.dx = 0
 f.dy = 0
 f.anim_name = "stand_right"
 fx_speech_bubble.spr_visible = true
 sfx(7,3)
 ent_setstate(f, "state_call_billy")
end

function flint_reject_silver(f)
 f.dx = 0
 f.dy = 0
 f.anim_name = "reject"
 ent_setstate(f, "state_reject_silver")
end

function flint_gameover(f)
 f.dx = 0
 f.dy = 0
 f.anim_name = "gameover"
 fx_angry.spr_visible = true
 fx_love.snap_entity = f
 fx_love.snap_x = 0.5
 sfx(6,3)
 ent_setstate(f, "state_gameover")
end

function flint_normal(f, move, catch, throw, shake)
 flint_controls(f, move, catch, throw, shake)
 fx_speech_bubble.spr_visible = false
 ent_setstate(f, "state_normal")
end

function flint_controls(f, move, catch, throw, shake)
	f.controls_move_enabled = move
	f.controls_catch_enabled = catch
	f.controls_throw_enabled = throw
 f.controls_shake_enabled = shake
end

-- silver
function silver_create(x, y)
	local s = ent_create(x, y, 136, {
  type = et_silver,
  state = "start",
  v = 0.02,
  spr_w = 2,
  spr_h = 2,
  col_y = 0.3,
  col_w = 0.4,
  col_h = 0.4,
  col_screen = true,
   --speed
  v_move = 0.02,
  v_knockback = 0.3,
   --in love
  in_love = false,
  v_love_factor = 3.0,
  --flint
  flint_follow_range_y = 0.2,
  --catch
  can_catch = false,
  --nb jumps
  nbjumps = 0,
  -- move
  move_countdown = 0,
  move_time_min = 1.0,
  move_time_max = 5.0,
  -- hit
  hit_time_default = 0.2,
  hit_time = 0,
  -- dragged
  dragged_offset_x = -1.0,
  --callback
  cb_update = silver_update
 })
	
	--anims
 ent_addanims(s, [[
 stand_up|1|164|0|0
 stand_down|1|160|0|0
 stand_left|1|136|0|0
 stand_right|1|136|1|0
 move_up|10|164,166|0,0|0,0
 move_down|10|160,162|0,0|0,0
 move_left|10|136,140|0,0|0,0
 move_right|10|136,140|1,1|0,0
 catch_prepare|1|136|0|0
 catch_rush|1|138|0|0
 catch|1|138|0|0
 stun|1|142|0|0
 rejected|1|142|0|0
 dragged|1|142|0|0]])

	silver_start(s)

	return s
end

function silver_update(s)
 local state = s.state

 fx_love.spr_visible = s.in_love or s.state == "catch"

	if s.x < 15  and  not s.col_screen then
		s.col_screen = true
	end

 --jumps
 if s.nbjumps > 0 then
  if s.h == 0 then
   s.hv = -0.35
   sfx(4,3)
   s.nbjumps -= 1
  end
 end

	local is_flint_in_follow_range_y = abs(flint.y - s.y) <= s.flint_follow_range_y

	if state == "moveleft" then
  s.move_countdown -= dt
  if s.move_countdown <= 0  then
		 if not is_flint_in_follow_range_y then
			 silver_movevertical(s)		
		 else
			 silver_moveleft(s)
		 end	
	 end	
	elseif state == "moveup" or state == "movedown" then
		if s.can_catch then
			if is_flint_in_follow_range_y then
				silver_catch_prepare(s)
			end
		else
			if is_flint_in_follow_range_y then
				silver_moveleft(s)
			else
				s.move_countdown -= dt
				if s.move_countdown <=0 then
					silver_moveleft(s)
				end
			end
		end
  elseif state == "hit" then
		 if s.state_timer >= s.hit_time then
			 silver_stun(s)
		end
	 elseif state == "stun" then
   if igm_state == "igm_state_run" then
 		 if s.state_timer >= 2 then
 			 silver_moveleft(s)
 		 end
  end
	 elseif state == "catchprepare" then
  if s.h == 0 and s.nbjumps == 0 and s.state_timer >= 1 then
			 silver_catch_rush(s)
		 end
	elseif state == "rejected" then
  if s.x >= 5 then
			silver_waitdragged(s)
		end
	elseif state == "inlove_start" then
  if s.h == 0 and s.nbjumps == 0 then
   s.in_love = true
   silver_moveleft(s)
  end
 elseif state == "dragged" then
  if abs(billy.x - s.x) >= abs(s.dragged_offset_x) then
   s.x = billy.x + s.dragged_offset_x
  end
 end
end

function silver_start(s)
 s.dx = 0
 s.dy = 0
 s.anim_name = "stand_left"
 ent_setstate(s, "start")
end

function silver_movevertical(s)
	local diry = flint.y - s.y;
	if(diry < 0) then
		silver_moveup(s)
	else 
		silver_movedown(s)
	end
end

function silver_moveup(s)
	s.v = s.v_move	
 if(s.in_love) s.v *= s.v_love_factor  
	s.dx = 0
	s.dy = -1
	s.anim_name = "move_up"
	s.move_countdown = rnd_range(s.move_time_min, s.move_time_max)
	s.state = "moveup"
end

function silver_movedown(s)
	s.v = s.v_move	
 if(s.in_love) s.v *= s.v_love_factor 
	s.dx = 0
	s.dy = 1
	s.anim_name = "move_down"
	s.move_countdown = rnd_range(s.move_time_min, s.move_time_max)
	s.state = "movedown"
end

function silver_moveleft(s)
	s.v = s.v_move
 if(s.in_love) s.v *= s.v_love_factor
	s.dx = -1
	s.dy = 0
	s.anim_name = "move_left"
	s.move_countdown = rnd_range(s.move_time_min, s.move_time_max)
	s.state = "moveleft"
end

function silver_stun(s)
 igm_resume()

	--unlock flint controls
	flint_controls(flint, true, true, true, true)

	s.v = 0	
	s.dx = 0
	s.dy = 0
	s.anim_name = "stun" 
 fx_warn.spr_visible = false
	s.state = "stun"	
end

function silver_catch(s)
 silver.spr_visible = false
	s.v = 0
	s.dx = 0
	s.dy = 0
	s.anim_name = "catch"
	s.state = "catch"
end

function silver_catch_prepare(s)
 ingame_manager_pause()

	flint_normal(flint, false, false, true, false)
	flint.orient = orient_right

 s.in_love = false
	s.v = 0
	s.dx = 0
	s.dy = 0
 s.nbjumps = 2
	s.anim_name = "stand_left"
 fx_warn.spr_visible = true
	ent_setstate(s, "catchprepare")
end

function silver_catch_rush(s)
	s.v = 0.5
	s.dx = -1
	s.dy = 0
	s.anim_name = "catch_rush"
 fx_warn.spr_visible = false
	ent_setstate(s, "catchrush")
end

function silver_inlove_start(s)
 s.dx = 0
 s.dy = 0
 s.nbjumps = 2
 s.anim_name = "stand_left"
	ent_setstate(s, "inlove_start")
end

function silver_rejected(s)
	s.can_catch = false
	s.v = 0.2
	s.dx = 1
	s.dy = 0
	s.anim_name = "rejected"
 sfx(2, 3)
	ent_setstate(s, "rejected")
end

function silver_waitdragged(s)
	s.v = 0
	s.dx = 0
	s.dy = 0
	s.anim_name = "rejected"
	ent_setstate(s, "waitdragged")		
end

function silver_dragged_start(s)
 s.dx = 0
 s.dy = 0
	s.anim_name = "dragged"
	ent_setstate(s, "dragged")		
end

function silver_dragged_stop(s)
end

function silver_hit(s, coco)
 score_add = 5
 if coco.ct == ct_love then
  score_add = 15
  silver_inlove_start(s)
 else
 	flint_controls(flint, true, true, true)
 	s.can_catch = false
  s.nbjumps = 0
  s.in_love = false
 	s.v = s.v_knockback
  s.hit_time = s.hit_time_default
 	s.dx = 1
 	s.dy = 0
 	s.orient = orient_left
 	s.anim_name = "stun"
  if coco.ct == ct_heavy then
   score_add = 10
   s.v *= 1.1
   s.hit_time *= 1.1
  elseif coco.ct == ct_light then
   score_add = 3
   s.v *= 0.5
   s.hit_time *= 0.5
  end
  igm_score += score_add
 	ent_setstate(s, "hit")		
 end	
end

function silver_collide_wall(s)
	if s.state == "moveleft" then
		s.can_catch = true
		if abs(flint.y - s.y) <= s.flint_follow_range_y then
			silver_catch_prepare(s)
		else
			silver_movevertical(s)
		end
		return true
	end

	if s.state == "movedown" then
		silver_moveup(s)
		return true
	end

	if s.state == "moveup" then
		silver_movedown(s)
		return true
	end

	return false
end

-- billy
function billy_create(x, y)
 b = ent_create(x, y, 200, {
  type = et_billy,
  v = 0.2,
  spr_w = 2,
  spr_h = 2,
  col_enabled = false,
  col_y = 0.3,
  col_w = 0.4,
  col_h = 0.4,
  --callback
  cb_update = billy_update
 })

 --anims
 ent_addanims(b, [[
 stand_left|5|200|0,0|0,0
 move_left|2|200,204|0,0|0,0
 move_right|5|202,206|1,1|0,0
 stun|1|234|1|0
 fall|1|232|1|0]]) 

 return b
end

function billy_update(b)

 if b.state == "state_reach_silver" then
  local dot = (b.dx * (silver.x - b.x))
  local dist_x = abs(silver.x - b.x)
  if dist_x < 0.1 or dot < 0 then
   hcrab_reach_billy(hcrab)
   billy_drag_silver(b)
  end
 elseif b.state == "state_fall" then
  if b.state_timer >= 0.5 then
   billy_stun(b)
   hcrab.col_screen = true
   hcrab.col_enabled = true
   hcrab_startmove(hcrab)
   flint_controls(flint, true, true, true, true)
   silver_dragged_stop(silver)
   silver_moveleft(silver)
   igm_resume()
  end 
 elseif b.state == "state_drag_silver" then
  if abs(hcrab.x - b.x) <= 1.0 then
   hcrab_stopmove(hcrab)
   billy_fall(b)
  end
 end
end

function billy_fall(b)
 b.dx = 0
 b.anim_name = "fall" 
 sfx(9,3)
 ent_setstate(b, "state_fall") 
end

function billy_stun(b)
 b.x += 1
 b.dx = 0
 b.anim_name = "stun" 
 sfx(10,3)
 fx_stun.spr_visible = true 
 ent_setstate(b, "state_stun") 
end

function billy_reach_silver(b)
 b.v = 0.2
 b.y = silver.y
 b.dx = -1
 b.anim_name = "move_left"
 ent_setstate(b, "state_reach_silver") 
end

function billy_drag_silver(b)
 b.v = 0.1
 b.dx = 1
 b.anim_name = "move_right" 
 ent_setstate(b, "state_drag_silver")
 silver_dragged_start(silver)
end

-- cocos
cocos = {}

-- coconut types
ct_classic = 1
ct_light = 2
ct_heavy = 3
ct_love = 4

function coco_create(x, y, ct)
	local c = ent_create(x, y, 128, {
  type = et_coco,
  ct = ct,
  spr_w = 2,
  spr_h = 2,
  v = 0.5,
  col_w = 0.3,
  col_h = 0.3,
  anim_name = "stand",
  state = "stand",
  -- drop
  drop_x = 0,
  drop_y = 0,
  --callback
  cb_update = coco_update
 })

	--anims
 ent_addanims(c, [[
 stand|1|128|0|0
 caught|1|132|0|0
 move|2|128,130,132,134|0,0,0,0|0,0,0,0]]) 

 --apply specific params for coco type
 if c.ct == ct_heavy then
  c.swap_colors[4] = 5
 elseif c.ct == ct_light then
  c.swap_colors[4] = 11
  c.swap_colors[0] = 3
 elseif c.ct == ct_love then
  c.swap_colors[4] = 14
  c.swap_colors[0] = 2
 end

 coco_stand(c)

	add(cocos, c)
	return c
end

function coco_update(c)
 if c.state == "state_throw" then
	 if(out_screen(c.x, c.y)) del(entities, c)
 elseif c.state == "state_drop" then
  local dir_x = c.drop_x - c.x
  local dir_y = c.drop_y - c.y
  local dot = (c.dx*dir_x) + (c.dy*dir_y)
  if dot < 0 then
   c.x = c.drop_x
   c.y = c.drop_y
   coco_stand(c)
  end
 end
end

function coco_update_snap(c)
	if c.snap_entity != nil then
		local flint_orient = flint.orient
		local snap_y = -1
		if flint_orient == orient_left or flint_orient  == orient_right  then
			if(flint.anim_index  == 2) snap_y += 0.125
		elseif flint.dy!= 0  then
			snap_y += 0.125
		end
		c.snap_y =  snap_y
	end
end

function coco_stand(c)
 c.dx = 0
 c.dy = 0
 c.v = 0
 c.col_enabled = true
 c.layer = layer_entity_1
 c.anim_name = "stand"
 c.state = "state_stand"
end

function coco_drop(c, x, y)
 c.drop_x = x
 c.drop_y = y
 local angle = atan2(x-c.x, y-c.y)
 c.dx = cos(angle)
 c.dy = sin(angle)
 c.v = 0.1
 c.layer = layer_entity_3
 c.anim_name = "move" 
 c.col_enabled = false
 c.state = "state_drop"
 sfx(3,3)
end

function coco_throw(c, dx, dy, v)
 c.dx = dx
 c.dy = dy
 c.v = v
 if c.ct == ct_heavy then
  c.v *= 0.5
 elseif c.ct == ct_light then
  c.v *= 1.5
 end
 c.anim_name = "move"
 c.layer = layer_entity_1
 c.col_enabled = true 
 c.state = "state_throw"
end

function coco_caught(c)
 c.snap_entity = flint
 c.anim_name = "caught"
 c.layer = layer_entity_2
 c.col_enabled = false
 c.state = "state_caught"
end

function coco_find(x,y,area)
	local result = nil
	local bestdist = area * area
	for e in all(entities) do
		if e.type == et_coco and e.state == "state_stand" then
			local dist = ((x - e.x) * (x - e.x)) + ((y - e.y) * (y - e.y))
			if dist <= bestdist then
				result = e
    bestdist = dist
			end
		end
	end
	return result
end

-- palmtree
function ptree_shadow_create(x, y)
 return ent_create(x, y, 192, {
  type = et_ptree,
  spr_w = 4,
  spr_h = 2,
  col_h = 0,
  col_w = 0,
  col_enabled = false,
  layer = layer_bg_1
 })
end

function ptree_foilage_create(x, y)
	return ent_create(x, y, 212, {
  type = et_ptree,
  spr_w = 4,
  spr_h = 3,
  col_h = 0,
  col_w = 0,
  col_enabled = false,
  layer = layer_entity_3
 })
end

function ptree_trunk_create(x, y)
	return ent_create(x, y, 224, {
  type = et_ptree,
  spr_w = 4,
  spr_h = 2,
  col_y = 0.2,
  col_w = 0.8,
  col_h = 0.7,
  max_cocos = 1
 })
end

function ptree_create(x,y)
 ptree_trunk_create(x,y)
 ptree_foilage_create(x,y-2)
 ptree_shadow_create(x,y+0.5)
end

function ptree_shake()
 local max_cocos = ptree_trunk.max_cocos
 local nb_cocos = 0
 for e in all(entities) do
  if(e.type == et_coco and e.state != "state_throw") nb_cocos+=1
 end
 sfx(0,3)
 --do nothing if there are enough cocos on scene
 if (nb_cocos >= max_cocos) return
 
 local cx = rnd_range(0.7, 2.0)
 local cy = 0
 if rnd_bool() then
  --top
  cy = rnd_range(2, 6)
 else 
  --bottom
  cy = rnd_range(10.6, 14)
 end

 local level = igm_lvl
 local random_percent = rnd_range_i(0, 100)
 local ct = ct_classic
 if level >= 2 and random_percent >= 80 then 
 	ct = ct_light
 elseif level >= 3 and random_percent >= 60 then 
 	ct = ct_heavy
 elseif level >= 4 and random_percent >= 40 then 
 	ct = ct_love
 end

 c = coco_create(ptree_foilage.x, ptree_foilage.y, ct)
 coco_drop(c, cx, cy)
end

-- shellfish
function shellfish_create(x, y, skin)
 s = ent_create(x, y, 173, {
  type = et_shellfish,
  spr_w = 1,
  spr_h = 1,
  col_h = 0,
  col_w = 0,
  col_enabled = false,
  layer = layer_bg_1
 })

 --random skin
 if skin == 1 then
  s.swap_colors[15] = 7
  s.swap_colors[14] = 6
  s.swap_colors[2] = 13  
 elseif skin == 2 then
  s.swap_colors[15] = 6  
  s.swap_colors[14] = 12  
  s.swap_colors[2] = 1  
 elseif skin == 3 then
  s.swap_colors[15] = 7 
  s.swap_colors[14] = 11  
  s.swap_colors[2] = 3    
 end

 return s
end

-- hermit crab
function hcrab_create(x, y)
 h = ent_create(x, y, 188, {
  type = et_hcrab,
  spr_w = 1,
  spr_h = 1,
  layer = layer_bg_2,
  col_enabled = false,
  v = 0.02,
  orient = orient_left,
  anim_name = "stand_left",
  cb_update = hcrab_update
 })

	--anims
 ent_addanims(h, [[
 stand_left|1|188|1|0
 stand_right|1|188|0
 move_left|10|188,189|1,1|0,0
 move_right|10|188,189|0,0|0,0]])

 ent_setstate(h, "pause")
 return h
end

function hcrab_update(h)
 if h.state == "stand" then
  if h.state_timer >= h.stand_time then
   hcrab_startmove(h)
  end
 elseif h.state == "move" then
  if h.state_timer >= h.move_time then
   hcrab_stopmove(h)
  end
 end
end

function hcrab_startmove(h)
 hcrab_changedir(h)
 h.anim_name = "move_" .. h.orient
 h.move_time = rnd_range(1.0, 3.0)
 ent_setstate(h, "move")
end

function hcrab_stopmove(h)
 h.dx = 0
 h.dy = 0
 h.anim_name = "stand_" .. h.orient
 h.stand_time = rnd_range(0.5, 2.0)
 ent_setstate(h, "stand")
end

function hcrab_changedir(h)
 local rnd_movedir = rnd_range_i(0,4)
 if rnd_movedir == 0 then
  h.dx = 1
  h.dy = 0
  h.orient = orient_right
 elseif rnd_movedir == 1 then
  h.dx = -1
  h.dy = 0
  h.orient = orient_left
 elseif rnd_movedir == 2 then
  h.dx = 0
  h.dy = 1
 else
  h.dx = 0
  h.dy = -1
 end
end

function hcrab_reach_billy(h)
 h.y = billy.y + 0.5
 h.dx = -1
 h.anim_name = "move_left"
 ent_setstate(h, "reach_billy")
end

-- fx
function fx_create(x, y, sprval)
	local fx = ent_create(x, y, sprval, {
  type = et_fx,
  spr_w = 1,
  spr_h = 1,
  spr_visible = false,
  col_enabled = false,
  layer = layer_fx
 })
	return fx
end

function fx_speech_bubble_create(snap_entity)
 local fx = fx_create(0, 0, 168)
 fx.spr_w = 3
 fx.spr_h = 2
 fx.snap_entity = snap_entity
 fx.snap_y = -2
 return fx
end

function fx_love_create(snap_entity)
 local fx = fx_create(0, 0, 196)
 fx.anim_name = "default"
 ent_addanim(fx, "default|5|196,197|0,0|0,0")
 fx.snap_entity = snap_entity
 fx.cb_update = fx_love_update
 return fx
end

function fx_love_update(fx)
 local sign = cos(flr(fx.timeframe / 8) / 2)
 fx.snap_y = -1.5 + sign * 0.1
end

function fx_stun_create(snap_entity)
 local fx = fx_create(0, 0, 198)
 fx.snap_entity = snap_entity
 fx.snap_y = -1
 fx.anim_name = "default"
 ent_addanim(fx, "default|5|198,199|0,0|0,0")
 return fx
end

function fx_warn_create(snap_entity)
 local fx = fx_create(0, 0, 171)
 fx.snap_entity = snap_entity
 fx.snap_y = -1.7
 return fx
end

function fx_angry_create(snap_entity)
 local fx = fx_create(0, 0, 187)
 fx.snap_entity = snap_entity
 fx.cb_update = fx_angry_update
 return fx
end

function fx_angry_update(fx)
 local sign = cos(flr(fx.timeframe / 8) / 2)
 fx.snap_x = -1 + sign * 0.15
 fx.snap_y = -1.2 + sign * -0.15
end

-- popup base
popups = {}

popup_base_x = 64
popup_base_y = 56

popup_spr_corner  = 236
popup_spr_top     = 252
popup_spr_left    = 237
popup_spr_middle  = 253
popup_open_duration = 0.4

function popup_create(w, h)
 local p = {
  w = w,
  h = h,
  x = popup_base_x - w*4,
  y = popup_base_y - h*4,
  active = false,
  visible = false,

  cb_open = nil,
  cb_close = nil ,
  cb_update = nil,
  cb_draw = nil,

  transition_state = "",
  open_timer = 0,

  burn_effect = nil
 }

 add(popups, p)
 return p
end

function popup_update(p)

 if p.transition_state == "popup_opening" then
  p.open_timer += dt
  if p.open_timer > popup_open_duration then
   p.active = true
   p.transition_state = ""
   if(p.cb_open != nil) p.cb_open(p)
  end
 end

 if p.transition_state == "popup_closing" then
  if not burn_effect.active then
   p.visible = false
   p.transition_state = ""
   if(p.cb_close != nil) p.cb_close(p)   
  end
 end

 if(p.active and nil != p.cb_update) p.cb_update(p)
end

function popup_draw(p)
 if(not p.visible) return

 local w = p.w
 local h = p.h
 local x = p.x
 local y = p.y

 if p.transition_state == "popup_opening" then
  local ratio = p.open_timer / popup_open_duration
  w = max(flr(ratio * p.w), 1)
  x = popup_base_x - w*4
  y = popup_base_y - h*4
 end

 for i=0,w do
  for j=0,h do
   local spr_x = x + i*8
   local spr_y = y + j*8
   local spr_val = popup_spr_middle
   local flip_x = false
   local flip_y = false

   if i == 0 then
    spr_val = popup_spr_top
    if(j == 0) spr_val = popup_spr_corner
    if(j == h) flip_y,spr_val=true,popup_spr_corner
   elseif i == w then
    flip_x = true   
    spr_val = popup_spr_top  
    if(j == 0) spr_val = popup_spr_corner
    if(j == h) flip_y,spr_val=true,popup_spr_corner
   elseif j == 0 then
    spr_val = popup_spr_left
   elseif j == h then
    flip_y = true
    spr_val = popup_spr_left     
   end

   spr(spr_val, spr_x, spr_y, 1, 1, flip_x, flip_y)

  end
 end

 if(p.cb_draw != nil) p.cb_draw(p)

end

function popup_open(p, with_transition)
 p.visible = true
 if with_transition then
  p.transition_state = "popup_opening"
  p.open_timer = 0
 else
  p.active = true
  if(p.cb_open != nil) p.cb_open(p)
 end

end

function popup_close(p, with_transition)
 p.active = false
 if with_transition then 
  p.transition_state = "popup_closing"
  p.open_timer = 0  
  local xmin = p.x
  local xmax = p.x -2 + p.w*9
  local ymin = p.y
  local ymax = p.y +2 + p.h*9
  burn_effect.p_bounds = {xmin, ymin, xmax, ymax}
  --be_ppoint_add(burn_effect, xmin + flr((xmax - xmin)/2), ymin + flr((ymax - ymin)/2))
  be_ppoint_add(burn_effect, xmin + flr((xmax - xmin)/2), ymin)
  be_ppoint_add(burn_effect, xmin + flr((xmax - xmin)/2), ymax)
  be_ppoint_add(burn_effect, xmin, ymin + flr((ymax - ymin) / 2))
  be_ppoint_add(burn_effect, xmax, ymin + flr((ymax - ymin) / 2))
  be_ppoint_add(burn_effect, xmin, ymin)
  be_ppoint_add(burn_effect, xmax, ymin)
  be_ppoint_add(burn_effect, xmin, ymax)
  be_ppoint_add(burn_effect, xmax, ymax)  
 else
  p.visible = false
  if(p.cb_close != nil) p.cb_close(p)  
 end
end

-- popup gameover
function popup_gameover_create()
 local p = popup_create(9, 6)

 --callbacks
 p.cb_update = popup_gameover_update
 p.cb_draw = popup_gameover_draw

 return p
end

function popup_gameover_update(p)
 if btnp(4) or btnp(5) then
  popup_close(p, false)
  scn_change(scn_id_ingame)
 end
end

function popup_gameover_draw(p)
 if(not p.active) return

 local px, py = p.x + p.w*4, p.y
 color(4)
 print("game over" , px - 13.5, py + 5)
 local text_score = "\x92 " .. igm_score
 print(text_score , px - #text_score*1.5, py + 21)
 print("press \151 or \142", px - 24, py + 37)
 print("to restart" , px - 15, py + 45)
end


-- popup lvlup
function popup_lvlup_create()
 local p = popup_create(9, 7)

 p.pup_selected = -1

 --callbacks
 p.cb_open = popup_lvlup_onopen 
 p.cb_close = popup_lvlup_onclose 
 p.cb_update = popup_lvlup_update
 p.cb_draw = popup_lvlup_draw

 return p
end

function popup_lvlup_onopen(p)
 p.pup_selected = -1
end

function popup_lvlup_onclose(p)
 igm_changelvl(igm_lvl+1)
 ents_unpause()
 igm_resume()
end

function popup_lvlup_update(p)
 if btnp(0) then 
  p.pup_selected -= 1
  if(p.pup_selected < 0) p.pup_selected = 2
 end

 if btnp(1) then
  p.pup_selected += 1
  if(p.pup_selected > 2) p.pup_selected = 0
 end


 if (btnp(4) or btnp(5)) and p.pup_selected >= 0 then
  powerup_apply(p.pup_selected)
  popup_close(p, true)
 end

end

function popup_lvlup_draw(p)
 if(not p.active) return

 local px, py, pup_selected = p.x, p.y, p.pup_selected

 --lvlup label
 print("level up" , px + p.w*4 - 12, py + 5, 4)

 --powerups
 spr(254, px+10, py+30)
 spr(238, px+35, py+30)
 spr(239, px+60, py+30) 

 --cursor
 local spr_arrow = 255
 if(pup_selected == pup_type_strength) spr(spr_arrow, px+11, py+20)   
 if(pup_selected == pup_type_speed)    spr(spr_arrow, px+36, py+20)   
 if(pup_selected == pup_type_maxcoco)  spr(spr_arrow, px+61, py+20)   

 --lvlup label
 local lbl_powerup_text = ""
 if(pup_selected == pup_type_strength) lbl_powerup_text = "strength up"
 if(pup_selected == pup_type_speed)    lbl_powerup_text = "speed up"
 if(pup_selected == pup_type_maxcoco)  lbl_powerup_text = "coco up"   
 print(lbl_powerup_text, px + p.w*4 - #lbl_powerup_text*1.5, py + 50, 4)

end


-- power ups
pup_type_strength = 0
pup_type_speed    = 1
pup_type_maxcoco  = 2

function powerup_apply(pup_type)
 if pup_type == pup_type_strength then
  flint.throw_force += 0.05
  silver.v_knockback += 0.02
  silver.hit_time_default += 0.04
 end

 if pup_type == pup_type_speed then
  flint.v += 0.05
 end

 if pup_type == pup_type_maxcoco then
  ptree_trunk.max_cocos += 1 
 end
end


-- wave effect
waves = {}
waves_anims = str_split([[1,5
3,7
32,36,
34,38 ]], "\n")

function waves_create()
 wave_create(-4,  0, 1)
 wave_create(-2,  0, 1)
 wave_create(0,  0, 1)
 wave_create(2,  0, 2)

 wave_create(4,  0, 3)
 wave_create(6,  0, 4)
 wave_create(8,  0, 3)
 wave_create(10, 0, 4)
 wave_create(12, 0, 3)
 wave_create(14, 0, 4) 
 wave_create(16, 0, 3) 
 wave_create(18, 0, 4) 
end

function wave_create(x, y, index)
 w = {
  x = x,
  y = y,
  anim = str_split(waves_anims[index], ","),
  frame = 0
 }
 add(waves, w)
 return w
end

function wave_update(w)
 w.frame += 1
 local anim_frame = flr(w.frame / 12) % 2

 local x = map_off_x + w.x
 local y = map_off_y + w.y
 spr_base = w.anim[anim_frame+1]
 mset(x, y, spr_base)
 mset(x + 1, y, spr_base+1) 
 mset(x, y + 1, spr_base+16)  
 mset(x + 1, y + 1, spr_base+17)
end

-- collisions rules
function col_rules_wall(e)
	if (e.type == et_flint) return true
 if (e.type == et_silver) return silver_collide_wall(e)

 if e.type == et_hcrab then
  hcrab_startmove(hcrab)
  return true
 end

	return false
end

function col_rules_screen(e)
 if (e.type == et_hcrab) hcrab_startmove(hcrab)

 return true
end

function col_rules_ets(e1, e2)
	--flint->coconut
	if e1.type == et_flint and e2.type == et_coco then
		return true
	end

	--flint->palmtree
	if e1.type == et_flint and e2.type == et_ptree then
		return true
	end

	--silver->coconut
	if e1.type == et_silver and e2.type == et_coco then
		return col_silver_coco(e1, e2)
	end

	--silver->flint
	if e1.type == et_silver and e2.type == et_flint then
		return col_silver_flint(e1, e2)
	end

	return false
end

function col_silver_coco(s,c)
	del(entities, c)
	silver_hit(s, c)
	sfx(2,3)
	return false
end

function col_silver_flint(s,f)
	if flint.life > 0 then
		flint.life -= 1
  flint_reject_silver(f)
		silver_rejected(s)
	else
  igm_gameover()
	end

	return true	
end

-- scene manager
scn_dict = {}
scn_id = nil

function scn_register(id, s)
 scn_dict[id] = s
end

function scn_update()
 if nil != scn_id then
  local s = scn_dict[scn_id]
  if nil != s and nil != s.cb_update then
   s.cb_update(s)
  end
 end
end

function scn_draw()
 if nil != scn_id then
  local s = scn_dict[scn_id]
  if nil != s and nil != s.cb_draw then
   s.cb_draw(s)
  end
 end
end

function scn_change(id)
 -- unload previous scene
 if nil != scn_id then
  local s = scn_dict[scn_id]
  if nil != s then
   if nil != s.cb_unload then
    s.cb_unload(s)
   end
  end
 end

 --load new scene
 scn_id = id
 if nil != scn_id then
  local s = scn_dict[scn_id]
  if nil != s then
   if nil != s.cb_load then
    s.cb_load(s)
   end
  end
 end

end

-- ingame manager
igm_timer = 0
igm_state = nil
igm_lvl = 0
igm_lvl_duration = 0
igm_state_timer = 0
igm_score = 0
igm_gameover_countdown = -1

function igm_update()
 igm_state_timer += dt

 if igm_gameover_countdown > 0 then
  igm_gameover_countdown -= dt
  if igm_gameover_countdown <= 0 then
   music(20)
   popup_open(popup_gameover, true)
  end
 end

 if igm_state == "igm_state_run" then
  igm_timer += dt
  if igm_timer >= igm_lvl_duration then
   be_bg_capture(burn_effect)
   popup_open(popup_lvlup, true)
   ents_pause()
   ingame_manager_pause()
  end
 end
end

function igm_intro()
 flint.col_enabled = false
 silver.col_screen = false
 flint_intro_flee(flint)
 silver_moveleft(silver)
 igm_timer = 0
 igm_setstate("igm_state_intro")
end

function igm_run()
 igm_score = 0
 flint.col_enabled = true
 flint.v = 0.1
 flint_normal(flint, true, true, true, true)
 silver.col_enabled = true
 silver_moveleft(silver)
 igm_setstate("igm_state_run")
 music(5,0,14)
end

function ingame_manager_pause()
 igm_setstate("igm_state_pause")
 --music(-1)
end

function igm_resume()
 if igm_state == "igm_state_pause" then
  igm_setstate("igm_state_run")
   --music(5)
 end
end

function igm_gameover()
 silver_catch(silver)
 flint_gameover(flint)
 music(-1)
 igm_gameover_countdown = 2
 igm_setstate("igm_state_gameover")
end

function igm_changelvl(lvl)
 igm_lvl = lvl
 if(igm_lvl == 1) then
  igm_lvl_duration = 30
 elseif(igm_lvl == 2) then
  igm_lvl_duration += 30
  silver.v_move += 0.005
 else
  igm_lvl_duration += 45
  silver.v_move += 0.01
 end
end

function igm_setstate(state)
 igm_state = state
 igm_state_timer = 0
end

-- scene menu splash
function scn_splash_create()
 return {
  cb_load = scn_splash_load,
  cb_unload = scn_splash_unload,
  cb_update = scn_splash_update,
  cb_draw = scn_splash_draw
 }
end

function scn_splash_load(s)
	-- palmtrees
	ptree_create(0.7, 9.5)
	ptree_create(-2.7, 7.5)
	ptree_create(-2.7, 11.5) 
	ptree_create(-2.7, 14.5)  
	--shellfishes
	shellfish_create(15, 4, 2)
	shellfish_create(10, 14, 1) 	
	--coconut
 coco_create(2, 10, ct_classic)
	--press text blink
	s.presstext_time = 0.5

 scn_splash_setstate(s, "splash_wait_for_input")
	music(0)
 pendulum.active = true
end

function scn_splash_unload(s)
 pendulum.active = false
 entities = {}
 cocos = {}
end

function scn_splash_update(s)
 --state update
 s.state_timer += dt
 if s.state == "splash_wait_for_input"  then
  if btn(4) or btn(5)  then
   s.presstext_time = 0.1
   scn_splash_setstate(s, "splash_title_blink_fast")
   music(-1, 5000)
   sfx(8,3)
   pendulum.active = false
  end
 elseif s.state == "splash_title_blink_fast" then
  if(s.state_timer >= 1.5) then
   scn_splash_setstate(s, "splash_movecam")
   end
 elseif s.state == "splash_movecam" then
 	local px = pendulum.x
 	local py = pendulum.y

  if(px != 0) px += -sgn(px) * 0.7
  if(py != 0) py += -sgn(py) * 0.7

 	if(abs(px) <= 0.5) px = 0
 	if(abs(py) <= 0.5) py = 0

 	if px == 0 and py == 0 then
   scn_splash_setstate(s, "splash_wait_launch")
 	end

 	pendulum.x = px
 	pendulum.y = py

 elseif s.state == "splash_wait_launch" then
  if s.state_timer >= 1 then
  	scn_change(scn_id_ingame)
  	return
  end
 end

 --update pendulum
 pendulum_update(pendulum)

 --update entites
 foreach(entities, ent_update)
end

function scn_splash_setstate(s, state)
 s.state = state
 s.state_timer = 0
end

function scn_splash_draw(s)
 --draw map
 camera(56 + pendulum.x, 24+ pendulum.y)
 map(4, 2, 0, 0, 26, 22)
 ents_draw()
 camera()
 --draw title
 if s.state == "splash_wait_for_input" or  s.state == "splash_title_blink_fast" then
	 map(40, 0, 32, 42, 9, 2)
	 map(40, 2, 35, 62, 8, 2)
  local text_visible = cos(flr(s.state_timer / s.presstext_time) / 4) != 0
	 if(text_visible) print_outline("press \151 or \142 to start", 20, 90, 0, 10)
 end

end


-- scene ingame
function scn_ig_create()
 return {
  cb_load = scn_ig_load,
  cb_unload = scn_ig_unload,
  cb_update = scn_ig_update,
  cb_draw = scn_ig_draw
 }
end

function scn_ig_load(s)
	--characters
 flint = flint_create(17, 9.5)
	silver = silver_create(17, 9.5)
	billy = billy_create(17, 0)
	hcrab = hcrab_create(17, 0)
 --fx elements
 fx_speech_bubble = fx_speech_bubble_create(flint)
 fx_angry = fx_angry_create(flint)
 fx_love = fx_love_create(silver)
 fx_warn = fx_warn_create(silver)
 fx_stun = fx_stun_create(billy)
 --main palmtree
	ptree_shadow = ptree_shadow_create(0.7, 10) 
 ptree_foilage = ptree_foilage_create(0.7, 7.5)
 ptree_trunk = ptree_trunk_create(0.7, 9.5)
 --coconut
 coco_create(2, 10, ct_classic)
	--shellfishes
	shellfish_create(15, 4, 2)
	shellfish_create(10, 14, 1)
 --level
 igm_changelvl(1)
 igm_intro()
end

function scn_ig_unload(s)
	entities = {}
	cocos = {}
end

function scn_ig_update(s)
 -- update ingame manager
 igm_update()
 --update camera
 cam_update()
 --update entities
 foreach(entities, ent_update)
 foreach(cocos, coco_update_snap)
 foreach(entities, ent_update_snap)
 ents_sort(entities)
 --update popups
 foreach(popups, popup_update)
end

function scn_ig_draw(s)
	camera(56+cam_x, 24+cam_y)
	map(4, 2, 0, 0, 26, 22)
	ents_draw()
	--reset camera params
	camera()
	--draw hud
	if igm_state == "igm_state_run" then
		map(40, 7, 0, 120, 32, 1)
		--level
		print_outline("lvl ".. igm_lvl, 1, 122, 6, 0)
		--timer
		local display_time = igm_lvl_duration - igm_timer
		local seconds = ceil(display_time % 60)
		local minutes = flr(display_time / 60)
		local str_seconds = ""..seconds
		if(seconds < 10) str_seconds = "0"..seconds
		local str_minutes = ""..minutes
		if(minutes < 10) str_minutes = "0"..minutes
		print_outline("\x91 "..str_minutes..":"..str_seconds, 25, 122, 7, 0) 
  --igm_score
  print_outline("\x92 "..num_format(igm_score, 4), 100, 122, 11, 0)
	end
	--draw popups
	foreach(popups, popup_draw)

	if dbg_mode then
		print("entities = " .. #entities, 0, 0, 3)
		print("dt = " ..dt, 0, 8, 3)  
	end
end

-- pico8 functions
function _init()
	last_time = time()
	palt(0, false)
	palt(8, true)
	--waves
	waves_create()
	--burn effect
	burn_effect = be_create()
	--popups
	popup_lvlup = popup_lvlup_create()
	popup_gameover = popup_gameover_create()
	--scenes
	scn_register(scn_id_ingame, scn_ig_create())
	scn_register(scn_id_splash, scn_splash_create())
	scn_change(scn_id_splash)
end

function _update()
	--delta time
	local cur_time = time()
	dt = cur_time - last_time
	last_time = cur_time
	--burn effect
	be_update(burn_effect)
	--update scene manager
	scn_update()
	 --update waves
	foreach(waves, wave_update)
end

function _draw()
 if not burn_effect.active then
  scn_draw()
 end
end
__gfx__
000000001111111111111111111111111111111111111111111111111111111111111111a9999a99777777778800000088888880888888888888888000000888
0000000011111111111111111111111111111111111111111111111111111111111111119a9a999a777777998044444408888804088888888888880444444088
00000000111111111111111111111111111111111111111111111111111111111111111199999a99779999990440000440888804408888888888804400004408
0000000011111111111111111111111111111111ccc111111111cccccccc1111111ccccca99a9a99999a99a90408888040888804408888888888804088880408
0000000011111111111111111111111111111111ccccccccccccccccccccc11111cccccc9999a9a9a999999a0408880440888804408888888888804088880408
0000000011111111111111111111111111111111cccccccccccccccccccccccccccccccc9a9a9a999a99a9990408804408888804408888888888804088880408
00000000cccc1111111ccccccccccc11111ccccc77777cccc777777777cccccccccc7777a99999a999a9aa9a0400044088888804408888888888804088880408
00000000cccccccccccccccccccccccccccccccc77777777777777777777ccccccc7777799a99a9aa999a9990444440888888804408888888888804400004408
11111111cccccccccccccccccccccccccccccccc99977777777999999977777777779999aa99a9a99a9a9a9a0444440888888804408888888888880444444088
111111117cccccccccccccc77777ccccccc777779999999999999999999977777779999999999999999999990400044088888804408888888888804444444408
1111111177777ccccccc777777777777777777779999999999999999999999999999949999a999a9a9a9a9a90408804408888804408888888888804400004408
111111119977777777777799999777777779444999999999999999999999999999994449a99a9999999a99990408880440888804408888888888804088880408
111111119a9977777777a9999a999a99a999444a9a999a999a99a9999a999a99a994444a9a999a999a99a9a90408888040888804408888888888804088880408
111111119999a99a9999999a9999a99a9a9444499999a99a9999999a9999a99a9a9444499999a99a9999999a0440000440888804440000008888804088880408
111111119a9a9a99999a9a999a9a9a99994444999a9a9a99999a9a999a9a9a99994444999a9a9a99999a9a998044444408888880444444440888044088880440
11111111a999a9999a999a99a999a999a9444999a999a9999a999a99a999a999a9444999a999a9999a999a998800000088888888000000008888000888888000
1111111111111111111111111111111111111111111111111111111111111111aa9444499aaaaaaaaaa999998888000000008888880088888000888800000000
11111111111111111111111111111111111111111111111111111111111111119a9944499aaaaaaaaaaaa9998880444444440888804408880444088800000000
1111111111111111111111111111111111111111111111111111111111111111aa94449999aaaaaaaaaaaa998804440000444088804408804404408800000000
11111111111111111111111111111111cccccc11111111cccccccc1111111ccc9944449a999aaaaaaaaaaaa98804408888000888804408044080088800000000
11111111111111111111111111111111cccccccccccccccccccccccccccccccca994449a999aaaaaaaaaaaaa8804088888888888880440440888888800000000
11111111111111111111111111111111cccccccccccccccccccccccccccccccc9a944449999aaaaaaaaaaaaa8804088888888888880444408888888800000000
cccc1111111ccccccccccc111111cccc7777ccccccccccc77777777cccccc77799444499a999aaaaaaaaaaaa8804088888888888880444088888888800000000
ccccc1111ccccccccccccccccccccccc77777777777777777777777777777777a9444999a999aaaaaaaaaaaa8804088888888888880440888888888800000000
cccccccccccccccccccccccccccccccc999977777777777779999977777779999a944499a9999aaaaaaaaaaa8804088888888888880440888888888800000000
777ccccccccc77777777cccccccc7777999999999999999999999999999999999a994449aa9999aaaaaaaaaa8804088888888888880444088888888800000000
77777cccccc777777777777777777777999999999999999999999999999999999a944449aa99999aaaaaaaaa8804088888888888880444408888888800000000
997777777777779999999777777aa99999999999999999999999999999aaa999a9444499aaa99999aaaaaaaa8804088888888888880440440888888800000000
aaaa7777777aaa999999999999aaaaaaaaaa999999aaaa999999999999aaaaaa99944499aaaa999999aaaaaa8804408888000888804408044080088800000000
aaaaaa9999999aaaaaaaaa9999999aaaaaaaaa9999999aaaaaaaaa9999999aaaaa944449aaaaaa9999999aaa8804440000444088804408804404408800000000
aaaaaaaa9999999aaaaaaaaa9999999aaaaaaaaa9999999aaaaaaaaa9999999a99944449aaaaaaaa9999999a8880444444440888804408880444088800000000
aaaaaaaaaa999999aaaaaaaaaa999999aaaaaaaaaa999999aaaaaaaaaa999999a9444499aaaaaaaaaa9999998888000000008888880088888000888800000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888000000888888888888888888888888880000008888888888888888888888888800000888888888888888888888888888000008888888880000000088888
88880ffffff08888888880000008888888880ffffff08888888880000008888888880fffff088888888880000088888888880fffff088888880fffff00008888
8880ffffffff088888880ffffff088888880ffffffff088888880ffffff088888880fffffff0888888880fffff0888888880fffffff0888880fffffff0000888
8880ff3ff3ff08888880ffffffff08888880ffffffff08888880ffffffff08888880f3ff00f088888880fffffff088888880f3ff00f0888880f00f00f0000088
880ffffffffff0888880ff3ff3ff0888880ffffffffff0888880ffffffff08888880fffff0f088888880f3ff00f088888880fffff0f0888880f0fffff0000008
8880ff9999ff0888880ffffffffff0888880ffffffff0888880ffffffffff088888099ff0ff088888880fffff0f08888888099ff0ff0888880ff0ff990ff0008
88880f9ff9f088888880ff9999ff088888880ffffff088888880ffffffff08888880f9ffff008888888099ff0ff088888880f9ffff00888880000ff9f0f00000
888000099000088888880f9ff9f00088888000000000088888880ffffff00888888090fff00888888880f9ffff008888888000fff0088888880ff00090000000
880ff000000ff088880000099000f088880ff000000ff088888000000000f0888888080000088888888090fff0088888880ff00000888888880ffff005500008
880ff000000ff088880ff000000008888800f000000f0088880ff0000000088888888800ff0888888888000000888888880ffff0008888888880000555508888
8880000000000888880ff000000088888880000000000888880ff0000000888888888800ff08888888800000ff00888888800000008888888880ff0055500888
8888040000408888888004000440888888880400004088888880040004408888888880440008888888044000ff04088888888044000888888880004400044088
88880440044088888888008804408888888804400440888888888000044088888888804444088888888044000044088888888044440888888880444406004088
88888008800888888888888880088888888880088008888888888888800888888888880000888888888800888800888888888800008888888888000080600888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888008888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888000000888888888888888888888888880000008888888888888888888888888800000888888888888888888888888888000008888888888888888888888
88000ffffff00088888880000008888888000ffffff00088888880000008888888800fffff088888888880000088888888880fffff0888888888888888888888
80ff0ffffff0ff0888000ffffff0008880f0ffffffff0f0888000ffffff00088880ff0fffff0888888800fffff0888888880fffffff088888888888888888888
80ff0f3ff3f0ff0880ff0ffffff0ff088000ffffffff000880f0ffffffff0f08880ff0ff00f08888880ff0fffff088888880f3ff00f088888888888888888888
88000ffffff0008880ff0f3ff3f0ff08880ffffffffff0888000ffffffff0008888000fff0f08888880ff0ff00f088888880fffff0f088888888888888888888
88800f9999f0088888000ffffff000888880ffffffff0888880ffffffffff0888880000f0ff08888888000fff0f08888888099ff0ff088888888888888888888
8880009ff900088888800f9999f0088888880ffffff088888880ffffffff088888800000ff0088888880000f0ff088888880f9ffff0088888888888888888888
88880009900088888880009ff9000888888800000000888888880ffffff00888888090000008888888800000ff008888888090fff00888888888888888888888
88888000000888888888000990008888888880000008888888880000000088888888080000088888888090000008888888800000008888888888888888888888
888880000008888888888000000888888888800000088888888800000008888888888800000888888888000000888888880ff000008888888888888888888888
888800000000888888888000000088888888000000008888888800000000888888888800000888888880000000008888880ff000000088888888888888888888
88880400004088888888804004408888888804000040888888880400044088888888804400088888880440000004088888800000044088888888888888888888
88880440044088888888800804408888888804400440888888888000044088888888804444088888888044000044088888888804404088888888888888888888
88888008800888888888888880088888888880088008888888888888800888888888880000888888888800888800888888888880400888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888088888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888800000888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888000000088888888880000088888888888000008888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888880000000008888888800000008888888880000000888888888800000888888
888888800888888888888000008888888888888888888888888888800000888888000fff00000888888000000000888888800000000088888888000000088888
8888880440888888888804444408888888888800008888888888880444f408888800fffff000008888000fff0000088888000fff000008888880000000008888
8888804444088888888804444f40888888888044f408888888888044444f08888880ffcffff000888800fffff00000888800fffff000008888000fff00000888
88880444f44088888888044444f40888888804444f408888888804444444088888800fffff0000088880ffcffff000888880ffcffff000888800fffff0000088
888804444f4088888888044444440888888044444444088888880444444408888880f0fff000000888800fffff00000888800fffff0000088880ff00fff00088
888804444440888888880444444408888880444444440888888804444444088888800055550000888880f0fff00000088880f0fff000000888800fffff000008
8888044444408888888880444444088888880444444088888888044444408888880fff0555088888888000555500008888800055550000888880f0fff0000008
8888804444088888888888044444088888888044440888888888044444088888880f005555088888880fff0555088888880fff05550888888880005055000088
88888804408888888888888000008888888888000088888888888000008888888880800000088888880f000555008888880f0055550888888888000f05088888
8888888008888888888888888888888888888888888888888888888888888888888880006088888888808800004408888880800000088888888880ff05088888
88888888888888888888888888888888888888888888888888888888888888888888804060888888888888806004088888888000608888888888800000088888
88888888888888888888888888888888888888888888888888888888888888888888880008888888888888806080888888880440608888888888066600888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888880888888888888008088888888888800008888888
88888800008888888888888888888888888888000088888888888888888888888888880000000000088888888880088888888888888888888888888008888888
88880000000088888888880000888888888800000000888888888800008888888888007777777777700888888880088888222288882228888888880440888888
888000ffff0008888888000000008888888000000000088888880000000088888880777777777777777008888880088882feff2882fef2888888804444088888
88000ffffff00088888000ffff000888880000000000008888800000000008888807777777777777777770888880088882efff2882eff2888888044444408888
8800ffcffcff008888000ffffff00088880000000000008888000000000000888807007707077070707077088880088882fffe28882f288888804444f4440888
800ffffffffff0088800ffcffcff00888000000000000008880000000000008888070707070770707070770888888888882fe28888828888888044444f440888
0000fff00fff0000800ffffffffff008000000000000000080000000000000088807007707077070007077088880088888822888888888888804444444f44088
00000f0ff0f000000000fff00fff00000000000000000000000000000000000088070707070770770777770888800888888888888888888888044444444f4088
800000f00f00000800000f0ff0f000008000000000000008000000000000000088070077070070070770770888888888880008888800088888044444444f4088
8880f050050f0888800000f00f000008888050555505088880000000000000088807777777777777777770888888888880fff08880fff0888804444444444088
88880055550088888880f050050f088888880055550088888880505555050888888077777777777777000888888080880ff00f080ff00f088880444444440888
8888800550088888888800055000888888888005500888888888000550008888888800007777770000888888880080080f0ff0f00f0ff0f08880444444440888
8888040006088888888880400608888888888060004088888888806000408888888888880777708888888888888888880ff0f0000ff0f0008888044444408888
88880440060888888888880006088888888880600440888888888060000888888888888880770888888888888800800880fff0e080fff0e08888804444088888
88888008808888888888888880888888888888088008888888888808888888888888888880708888888888888880808888000ee0880000088888880440888888
88888888888888888888888888888888888888888888888888888888888888888888888888088888888888888888888888880008888888888888888008888888
88888844448888888888888888888888888888888888888888888888888888888880000008888888888000000888888888888888888888888888888888888888
8888844444488888888888888888888880080088880808888080888008880808880aaaaaa0888888880aaaaaa088888888800000088888888880000008888888
888888844444448888888444488888880ee0ee0880e0e088088808088080888088000000aa08888888000000aa088888880aaaaaa0888888880aaaaaa0888888
888888444444444444444444888888880eeeee0880eee0888080888008880808880fffff0a088888880fffff0a08888888000000aa08888888000000aa088888
8888844444444444444444488888888880eee088880e08880888080880808880880ff00f00a08888880ff00f00a08888880fffff0a088888880fffff0a088888
88884444444444444444444488888888880e0888888088888080888008880808880f0cfff0a08888880f0cfff0a08888880ff00f00a08888880ff00f00a08888
8884444444444444444444444888888888808888888888888888888888888888880ffffff0a08888880ffffff0a08888880f0cfff0a08888880f0cfff0a08888
8884888444444444444444444488888888888888888888888888888888888888880fffff0a088888880fffff0a088888880ffffff0a08888880ffffff0a08888
88888844444444444444444448888888888888888888888888888888888888888880fff0a08888888880fff0a0888888880fffff0a088888880fffff0a088888
8888844444444444444444488888888888888888888888888888888888888888888800000088888888880000000088888880fff0a08888888880fff0a0888888
8888444444444444444444448888888888888888888888888888888888888888888880000088888888888000ffff088888880000008888888880000000000888
88884888444444444444444448888888888888888888888888888888888888888888800ff088888888888000000f088888880000ff088888880f00000ffff088
88888888444444444444444448888888888333333888888888888883333338888888800ff0888888888880000080888888000000ff008888880000000000f088
888888844444444444488884888888888883bbbbb33888833888833bbbbb38888888055000888888888805500088888880550550000508888055055000050888
888888844488444444888888888888888883bbbbbb33883bb38833bbbbbb38888888055550888888888805555088888888055000005508888805500000550888
8888888448888844888888888888888888833bbbbbb383bbbb383bbbbbb338888888800008888888888880000888888888800088880088888880008888008888
88888888888803bbbb3088888888888888883bbbbbbb3bbbbbb3bbbbbbb388888888888888888888888888888888888888008880088888088088000080888088
888888888888043bb3408888888888888888833bbbbb33bbbb33bbbbb338888888800000088888888888888888888888880f080ff00080f00008044000080408
8888888888880943349088888888888888833b33bbbbb33bb33bbbbb33b33888880aaaaaa0888888888888888888888880fff0ffffff0fff80880440808044f0
88888888888809999990888888888888883bbbb33bbbbb3333bbbbb33bbbb38888000000aa08888888888888888888880fffffffffffffff8880444088804440
8888888888880499994088888888888883bbbbbb333bbb3333bbb333bbbbbb38880fffff0a08888888880008888888880fffffffffffffff0000444088804440
888888888888094444908888888888883bbbbb33bbb33bb33bb33bbb33bbbbb3880ff00f00a088888800aaa08888888880ffffffffffffff0444444088804440
888888888888099999908888888888883b3333bbbbb3bbbbbbbb3bbbbb3333b3880f0ffff0a0888880aa000a0888888880ffffffffffffff0444004088880408
888888888888099999908888888888883383bbbbbb33bbbbbbbb3bbbbbbb3833880ff0fff0a088880aa00ff0a0888888880fffffffffffff0000800088888088
88888888888094499449088888888888883bbbbbb3b3bbbbbbbb33bbbbbbb388880fffff0a0888880a0fffff00000888880fffffffffffff8088880088000088
8888888888099994499990888888888883bbbbb33bbb3bbbbbb3bb33bbbbbb388880fff0a08888880a0f0ffff000000880ffffffffffffff0008807088000088
888888888099999999999908888888883bbbbb3bbbbb3bbbbbb3bbbb333bbbb388880000000008880a0f0f0ff000005080ffffffffffffff8088070888000088
888888888099449999449908888888883bb333bbbbb33bbbbbb33bbbbbb33bb3888800000ffff0880a0ff0fff00000500fffffffffffffff8880708888000088
888888888800999999990088888888883b383bbb333803bbbb303333bbb383b3880000000000f0880a0fffff0ff0055080ffffffffffffff0807088800000000
888888888880999009990888888888883383bb338888043bb340888833bb38338055055000050888800000000ff005500fffffffffffffff0070888880000008
888888888880990880990888888888888883b3888888094334908888883b38888805500000550888888888888008800880ffffffffffffff8008888888000088
888888888888008888008888888888888883388888880999999088888883388888800088880088888888888888888888880fffffffffffff0800888888800888
__gff__
0001010101010101010001000000000001000000010000000100000000010000010101010101010101000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000002f2f0000000000000000000000000b0c0d0e0f2b2c2d2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000002f2f0000000000000000000000001b1c1d1e1f3b3c3d3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001010101010101010101010101010101010101010101010101010100000000000000000002b2caeaf2b2caeaf2f00000080810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001010101010101010101010101010101010101010101010101010100000000000000000003b3cbebf3b3cbebf0000000090910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005060708050607010203042021222320212223202122232021222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000012130a1112130a111213143031323330313233303132333031323300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090909191a090909190928292a292a292a292a292a292a292a292a00000000000000000010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000909091a19191a191a1a38393a393a393a393a393a393a393a393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009091a191a190909090928292a292a292a292a292a292a292a292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a09190909091a191a1a38393a393a393a393a393a393a393a393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000191a1a1a1a090909190928292a292a292a292a292a292a292a292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000090909091a091a191a1a38393a393a393a393a393a393a393a393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009190909091a09091a1928292a292a292a292a292a292a292a292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a1a1a1a1a0909191a1a38393a393a393a393a393a393a393a393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a1a09091a091a091a0928292a292a292a292a292a292a292a292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a1a091a0919191a1a1a38393a393a393a393a393a393a393a393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a1a191a1a090909091928292a292a292a292a292a292a292a292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009090909090909191a1a38393a393a393a393a393a393a393a393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001919191a1a1a0909190928292a292a292a292a292a292a292a292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009191a1a1a190919191928393a393a393a393a393a393a393a393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a1a19191a091a09090938292a292a292a292a292a292a292a292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000191a1a1a191a1919190928393a393a393a393a393a393a393a393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001a1a1a09191a1a09190938292a292a292a292a292a292a292a292a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000393a393a393a393a393a393a393a393a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0102000000643050300202100611021000060000000000000400002000020000000000000000000b0000b100014001300014500165000c5000b5000b5000b5000050000500005000050000500005000050000500
01030006006130c6110c611002000c20018200002000c20018200002000c2001820024200002000c5002450000000007000070000700000000000000000000000000000000000000000000000000000000000000
0118000018113275002750022500225001d5001d50018500185001350000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
01500000297131f5001b5001b500165001650016500165001d5001d50016500165001d5001d5001d5001d5001b5001b5001b5001b500225002250022500225001f5001f5001f5001f5001f5001f5001f5001f500
0101000027011290112b0112e011300113301135011370113a0001300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010700080061500600006001860000615006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
017800002911300700007000070000700007050c7000c7000c7000c7000c7000c7000c7000c7000c7050c7050c70000700007000070000700007050c7050c7050f7000f7000f7000f7000f7001b7000070500705
010a0000241102d1112800028000240003300035000370003a0001300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0104000018325183102432524310303253031030310303103031030315003030c3002c3002830033300303002c300283000c30000300003000030000300003000030000300003000030000300003000030000300
010600003c6153c515305013f1051f10029100301003f100181002410018100241001810024100181002410018100181001810018100181000010000100001000010000100001000010000100001000010000100
010a0000006552411324103071040a1000a1040a104071000a1000a1040c1000c10407102071040710405100071000510503100031040710005105031000310405100051040a1000a10407100071040710207105
01180000051050710007102071040a1000a1040a104071000a1000a1040c1000c1040710207104071040510007100051050310003104071000510503100031040510005104071000710400100001040010200100
01300010006450060000605006000064500200002000c70400645006000060500605006450c305006450c305006050060500605002000020000200002000c7000060300600006050c60000603006000c60500305
011800000056000560005600053000500005000000000000005600056000560005300050000500000000000000560005600056000530005000050000000000000056000560005600053024760247342472424710
010c00101872624714187062472618714247061872624714187262471418706247261871424706187262471418700187001870018700187000070000700007000070000700007000070000700007000070000700
010c00101871624714187062471618714247061871624714187162471418706247161871424706187162471418700187001870018700187000070000700007000070000700007000070000700007000070000700
011800201d1301f1221f1121f7142212222122227141f132221222211424122247141f1221f1121f7141d1101f1321d1221b1101b7141f1221d1221b1121b7141d1321d11422122221141f1221f1141f1121f115
011800201d1301f1221f1121f7142212222122227141f132221222211424122247141f1221f1121f7141d1101f1321d1221b1101b7141f1221d1221b1121b7141d1321d7141f1221f71418112181141811024100
000c00001870024700187002470018700247001870024700187002470018700247001870024700187002470018700187001870018700187000070000700007000070000700007000070000700007000070000700
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01120020135301f71416530227141a5301a53026714135301f71416530227141a530267141a5301853016530135301f71416530227141a5301653018530135301653022714125301353013530135301f71400505
01120000135301f71016530227101a5301a53026710135301f71016530227101a530267101a5301853016530135301f71016530227101a5301a53026710185302471016530227101353013530135301f71000500
011200001a530267101f5302b7101e5301e5302a7101a530267101d530297101c5301c5301c53028710265001a530267101f5302b7101e5301a5301d5301c53018530247101a5301653016530165302271022500
011200001a530267101f5302b7101e5301e5302a7101a530267101d530297101c530287101353015530165301a53026710185302471016530185301a53018530165302271015530135301f710003000030013130
0112002013114161351a1351a1351a1301a1141a1301a114161301611418130181141a1301a1301a1141313013114161351a1351a1351a1301a1141a1301a1141613515135131301313013130131141310513130
0112002013114161351a1351a1351a1301a1141a1301a114161301611418130181141a1301a1301a1301a1142b1051a1351a1301a1141a1301a1141a1301a1301a1301a115161301611413130131141313013114
0112002013130131142b7141f10016130161142e7141a1301a1241a122327241a1121a11232714261002610026100261001a1301a1141a1301a1141a1301a1141a1301a114181301613016130161142210522105
0112002013130131142b7141f10516130161142e7141a1301a1241a122181311811418112307142b1002b10026100261001a1301a1141a1301a1141a1301a1141a1301a1141d1301d1141f1301f1301f1142b105
0112002013100161001a1001a1001a1001a1001a1001a100161001610018100181001a1001a1001a1001310013100161001a1001a1001a1001a1001a1001a1001610015100131001310013100131001310013100
01120010077200772507700077000a7200a7250a7000a7000c7200c7250a700027000e7200e725007000a7000770007705167000c7000a7000a7050c700137000c7000c7050a700027000e7000e7051670000700
01120020077200772507700077000a7200a7250a7000e7200e7250c7000a700027000e7000e700007000a700077450774507700077050774507745077050770507745077450a7000270007745077451670000700
01120020077200772507700077000a7200a7250a7000e7200e7250c7000a700027000e7000e700007000a7000774507745167000c70007745077450c700137000272002725057200572507720077251670000700
011200201f5001f5001f5001f50022500225002e50026500265002650026500265001a5001a5001f5001f5001a5001a500265002650026500265002650026500265002e500245002250022500135001350013500
010900200c043016050c615006050c61500605216002360018610186130c6150c6050c6150c60500600006000c043016050c615006050c61500600006000060024615186050c6150c6050c615006000060019600
010900200c043016050c615006050c61500605216002360024615186050c6150c6050c6150c60500600006000c043016050c615006050c61500600006000060018610186130c6150c6050c615006000060019600
011200200c0430c6050c60500605246150c6050c605236000c0430c6050c6050c60524615186030c6050c6050c0430c6050c60500605246150c6050c605006000064500600006450060500645186000c60019600
01120010077000770007700077000a7000a7000a7000a7000c7000c7000a700027000e7000e700007000a7000770007700167000c7000a7000a7000c700137000c7000c7000a700027000e7000e7001670000700
01120020077000770007700077000a7000a7000a7000e7000e7000c7000a700027000e7000e700007000a700077000770007700077000770007700077000770007700077000a7000270007700077001670000700
01120020077000770007700077000a7000a7000a7000e7000e7000c7000a700027000e7000e700007000a7000770007700167000c70007700077000c700137000270002700057000570007700077001670000700
010900200c000016000c600006000c60000600216002360018600186000c6000c6000c6000c60000600006000c000016000c600006000c60000600006000060024600186000c6000c6000c600006000060019600
010900200c000016000c600006000c60000600216002360024600186000c6000c6000c6000c60000600006000c000016000c600006000c60000600006000060018600186000c6000c6000c600006000060019600
011200200c0000c6000c60000600246000c6000c600236000c0000c6000c6000c60024600186000c6000c6000c0000c6000c60000600246000c6000c600006000060000600006000060000600186000c60019600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0112002026500265001a5351a5041a5351a5041a5351a5041a5551a5041d5351d5041f5351f5141f5042b50526500265001a5001a5041a5001a5041a5001a5041a5001a5041d5001d5041f5001f5001f5042b505
011200200774507745167000c70007745077450a7000e700027200272505720057250772007725007000a7000770507705167000c70007705077050c700137000270002705057000570507700077051670000700
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 42 43 0e
01 0c 0d 43 0e
00 0c 0d 10 0f
02 0c 0d 11 0f
02 41 42 43 44
01 14 1d 21 44
00 14 1d 21 44
00 15 1d 21 44
00 16 1d 21 44
00 17 1d 21 44
00 18 1d 21 44
00 19 1d 21 44
00 1a 1e 22 44
00 1a 1e 22 44
00 1a 1e 22 44
02 1b 1f 23 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
05 2d 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 07 22 25 28
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
