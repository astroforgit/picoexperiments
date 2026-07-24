pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--picosnood

--constants
c_gs_start_screen=1
c_gs_how_to_play_screen=2
c_gs_playing=3
c_gs_win_screen=4
c_gs_game_over_screen=5

c_short_sfx=0
c_long_sfx=1

c_max_level=3
c_fault_line_y=104
c_level_cell_w=12
c_level_cell_h=16
c_level_w=c_level_cell_w*8
c_snood_velocity_multiplier=3
c_level_start_y=0

c_brick_sprite=59
c_level_names={'snood lightning', 'hava cuppa', 'x marks the spot','my house'}
c_animations={
 [0]={next=0, base=0},
 [98]={next=99, base=98},
 [99]={next=98, base=98},
 [100]={next=101, base=100},
 [101]={next=100, base=100},
 [107]={next=222, base=107},
 [222]={next=107, base=107},
 [227]={next=228, base=227},
 [228]={next=229, base=227},
 [229]={next=227, base=227},
 [236]={next=237, base=236},
 [237]={next=236, base=236},
 [238]={next=239, base=238},
 [239]={next=238, base=238},
 [c_brick_sprite]={next=c_brick_sprite, base=c_brick_sprite}
}

-->8
--core engine functions
function _init()
 cartdata('danb91_picosnood')
 setup_asciitables()
 
 input_new={}
 input_old={}

 falling_snoods={}
 snood_types=nil
 current_level=nil
 launched_snood=nil
 level_start_x=nil
 update_current_gamestate=nil
 draw_current_gamestate=nil
 num_snoods_left=nil
 num_snoods_used=nil

 launcher={sprite=207, 
  offx=48,offy=108,angle=.25}
 snood_start_x = launcher.offx
 snood_start_y = launcher.offy
 launcher.x, launcher.y = calc_launcher_coords()
 danger_meter={x=108, y=16, w=8, h=86, filled_pct=0}
 
 change_gamestate(c_gs_start_screen)
end
function change_gamestate(gamestate)
 if gamestate == c_gs_start_screen then
  context=init_start_screen()
  update_current_gamestate=update_start_screen_gamestate
  draw_current_gamestate=draw_start_screen_gamestate
 elseif gamestate == c_gs_how_to_play_screen then
  context=init_how_to_play_screen()
  update_current_gamestate=update_how_to_play_screen_gamestate
  draw_current_gamestate=draw_how_to_play_screen_gamestate
 elseif gamestate == c_gs_playing then
  update_current_gamestate=update_playing_gamestate
  draw_current_gamestate=draw_playing_gamestate
 elseif gamestate == c_gs_game_over_screen then
  context=init_game_over_screen()
  update_current_gamestate=update_game_over_screen_gamestate
  draw_current_gamestate=draw_game_over_screen_gamestate
 elseif gamestate == c_gs_win_screen then
  context=init_win_screen()
  update_current_gamestate=update_win_screen_gamestate
  draw_current_gamestate=draw_win_screen_gamestate
 else
  assert(false)
 end
end

function _update60()
 update_input()
 update_current_gamestate(context)

 local tmp=input_new
 input_new=input_old
 input_old=tmp
end


function _draw()
 cls()

 draw_current_gamestate(context)
end


function update_input()
 input_new[î]=btn(î)
 input_new[É]=btn(É)
 input_new[ã]=btn(ã)
 input_new[ë]=btn(ë)
 input_new[é]=btn(é)
 input_new[ó]=btn(ó)
end
function is_pressed(b)
 return input_new[b] and not input_old[b]
end
function is_held(b)
 return input_new[b]
end
function is_let_go(b)
 return not input_new[b] and input_old[b]
end

-->8
--Start screen game state
function init_start_screen()
 local max_level_name_len=0
 for level_name in all(c_level_names) do
  max_level_name_len=max(max_level_name_len, #level_name)
 end
 return {max_level_name_len=max_level_name_len, blink_tick=0, blink_state=false}
end
function update_start_screen_gamestate(context)
 if is_pressed(ó) then
  sfx(57, c_short_sfx)
  change_gamestate(c_gs_how_to_play_screen)
 end
end

function draw_start_screen_gamestate(context)
 local y=10
 do 
  local str_x=(64-#'picosnood'*4)
  spr(context.blink_state and 99 or 98 , str_x-10, y)
  spr(context.blink_state and 101 or 100, str_x+#'picosnood'*8+2, y)
  sprint('picosnood', str_x/8, y/8,12,2,2)
 end
 y+=24

 sprint('best snoods used', (64-#'best snoods used'*4)/8, y/8, 11, 0, 0)
 y+=8
 line(0, y, 128, y, 7)
 y+=4
 local lines={}
 local max_line_len=0
 for i, level_name in pairs(c_level_names) do
  local level=level_name..':'
  for _=context.max_level_name_len,#level_name,-1 do
   level..=' '
  end
  level..=' '
  local least_snoods_used=dget(i-1)
  if least_snoods_used>0 then
   add(lines, {level, tostr(least_snoods_used)})
   max_line_len=max(max_line_len, #(level..tostr(least_snoods_used)))
  else
   add(lines, {level, 'not completed'})
   max_line_len=max(max_line_len, #(level..'not completed'))
  end
 end
 for l in all(lines) do
  local level, value=unpack(l)
  print_with_border(level, 64-max_line_len*2, y, 7, 2)
  if value!='not completed' then
   print_with_border(value, (64-max_line_len*2)+#level*4, y, 7, 3)
  else
   print_with_border(value, (64-max_line_len*2)+#level*4, y, 7, 8)
  end
  y+=8
 end
 y+=24
 local start_str='press ó to start'
 print_with_border(start_str, 64-#start_str*2, y, context.blink_state and 3 or 7, context.blink_state and 7 or 3)
 y+=16

 print('#toyboxjam2', 0, 120, 7)
 print('daniel bokser', 128-#'daniel bokser'*4, 120, 7)

 context.blink_tick-=1
 if context.blink_tick<=0 then
  context.blink_tick=15
  context.blink_state=not context.blink_state
 end
end
-->8
--How-to-play screen game state
function init_how_to_play_screen()
 return {blink_tick=0, blink_state=false}
end
function update_how_to_play_screen_gamestate(context)
 if is_pressed(ó) then
  load_level(0)
  sfx(57, c_short_sfx)
 end
end

function draw_how_to_play_screen_gamestate(context)
 local y=10
 local str='how to play'
 sprint(str, (64-#str*4)/8, y/8,12,2,2)
 y+=16

 str='è'
 print(str, x, y, 12)
 str='use ã and ë'
 local x=0
 print(str, x+8, y, 7)
 y+=8
 str='to move the launcher'
 print(str, x+8, y, 7) 
 y+=12

 str='è'
 print(str, x, y, 12)
 str='press ó to launch a snood'
 print(str, x+8, y, 7)
 y+=12

 str='è'
 print(str, x, y, 12)
 str='hold é and use ã and ë '
 print(str, x+8, y, 7)
 y+=8
 str='to aim more precise shots'
 print(str, x+8, y, 7) 
 y+=12
 
 str='è'
 print(str, x, y, 2)
 str='match 3 or more snoods '
 print(str, x+8, y, 7)
 y+=8
 print('to clear them', x+8, y, 7)
 y+=12

 str='è'
 print(str, x, y, 2)
 str='keep your danger meter low'
 print(str, x+8, y, 7)
 y+=8
 print('by making snoods fall!', x+8, y, 7)
 y+=8

 str='press ó to continue'
 print_with_border(str, 64-#str*2, y, context.blink_state and 3 or 7, context.blink_state and 7 or 3)

 context.blink_tick-=1
 if context.blink_tick<=0 then
  context.blink_tick=15
  context.blink_state=not context.blink_state
 end
end


-->8
--Playing game state

--context isn't used, but probably should be used instead of a bunch of globals
function update_playing_gamestate(context)
 precision_mode=is_held(é)
 if is_pressed(é) then
  sfx(62, c_short_sfx)
 elseif is_let_go(é) then
  sfx(63, c_short_sfx)
 end

 if is_held(ã) then
  launcher.angle+=precision_mode and .001 or .01
 end
 if is_held(ë) then
  launcher.angle-=precision_mode and .001 or .01
 end
 if is_pressed(ó) and not launched_snood and #falling_snoods==0 then
  --launch snood
  sfx(47, c_short_sfx)
  num_snoods_used+=1
  local snood=launcher.current_snood
  if launcher.angle <= .25 then
   snood.vx = 1-(launcher.angle/.25)
   snood.vy = -(launcher.angle/.25)
  else
   snood.vx = (1-(launcher.angle/.25))
   snood.vy = -2+(launcher.angle/.25)
  end
  snood.vx*=c_snood_velocity_multiplier
  snood.vy*=c_snood_velocity_multiplier
  launched_snood=snood
  --launcher.current_snood=next_snood()
 end
 launcher.angle=clamp(launcher.angle, .0625, 0.4375)
 launcher.x, launcher.y=calc_launcher_coords()
 for snood in all(falling_snoods) do
  snood.y+=snood.vy
  if snood.y>=128 then
   del(falling_snoods, snood)
   num_snoods_left-=1
  end
 end

 if num_snoods_left==0 then
  --you won!!
  change_gamestate(c_gs_win_screen)
  sfx(0, c_long_sfx)
  return
 end

 if launched_snood!=nil then
  local will_collide_x, will_collide_y = will_collide(launched_snood)

  local collide=will_collide_x or will_collide_y
  --move snood
  if not will_collide_x then
   launched_snood.x+=launched_snood.vx
  end
  if not will_collide_y then
   launched_snood.y+=launched_snood.vy
  end


  if not collide then
   --bounds checks
   if launched_snood.x<0 then
    launched_snood.x=0
    launched_snood.vx=-launched_snood.vx
    sfx(43, c_short_sfx)
   elseif launched_snood.x+launched_snood.w>=c_level_w then
    launched_snood.x=c_level_w-launched_snood.w
    launched_snood.vx=-launched_snood.vx
    sfx(43, c_short_sfx)
   end
  else

   --[[
   ************************************************************
     now calculate where the launched snood goes in the tile map
   ************************************************************
   ]]
   --calc x
   
   local px_x
   local should_round_up_x
   if will_collide_x then
    px_x=launched_snood.x+launched_snood.vx
    --should_round_up_x=false
    should_round_up_x=launched_snood.vx<0
   else
    px_x=launched_snood.x
    should_round_up_x=launched_snood.x%8>=4
   end

   --calc y
   --y velocity is always negative
   local px_y
   local should_round_up_y
   if will_collide_y then
    px_y=launched_snood.y+launched_snood.vy
    should_round_up_y=true
   else
    px_y=launched_snood.y
    should_round_up_y=launched_snood.y%8>4
   end

   local tile_x, tile_y=pixel_to_tile_coords(px_x, px_y, should_round_up_x, should_round_up_y)
   assert(tile_x>=level_start_x)
   assert(tile_y>=c_level_start_y)
   assert(mget(tile_x, tile_y) == 0)
   mset(tile_x, tile_y, launched_snood.sprite)
   num_snoods_left+=1

   --[[
   ************************************************************
    run match algorithm and clear matching snoods if there are 3 or more 
   ************************************************************
   ]]
   --look at adjacent snoods and see if we have 3 or more
   local num_matched_snoods, matching_snoods=gather_matching_snoods(tile_x, tile_y, launched_snood.sprite, {[cck(tile_x, tile_y)]={tile_x=tile_x,tile_y=tile_y}}, 1)
   if num_matched_snoods>=3 then
    for _,snood in pairs(matching_snoods) do 
     mset(snood.tile_x, snood.tile_y, 0)
     num_snoods_left-=1
    end
    --[[
    ************************************************************
    calculate and start fall of disconnected snoods
    ************************************************************
    ]]
    local disconnected_snoods=find_disconnected_snoods()

    if #disconnected_snoods>0 then
     sfx(35, c_long_sfx)
     update_danger_meter(-.2*#disconnected_snoods)
    else
     update_danger_meter(.2)
    end
    for snood in all(disconnected_snoods) do
     mset(snood.tile_x, snood.tile_y, 0)
     add(falling_snoods,{x=(snood.tile_x-level_start_x)*8, y=snood.tile_y*8,sprite=snood.sprite,vy=c_snood_velocity_multiplier})
    end
    refresh_snood_types()
    sfx(1, c_short_sfx)
   else
     update_danger_meter(.2)
     sfx(61, c_short_sfx)
   end
   launched_snood=nil

   launcher.current_snood=next_snood()
   for x=level_start_x,level_start_x+c_level_cell_w-1 do
    if mget(x, c_fault_line_y/8)!=0 then
     --game over!!
     sfx(39, c_long_sfx)
     change_gamestate(c_gs_game_over_screen)
     return
    end
   end 

  end --end if not collided else
 end -- end if launched_snood!=nil

 animation_ticks+=1
 if animation_ticks==60 then
  animation_ticks=0
  for y=c_level_start_y,c_level_cell_h do
   for x=level_start_x,level_start_x+c_level_cell_w do
    local tile=mget(x, y)
    if tile!=0 and tile!=c_brick_sprite  then
     mset(x, y, c_animations[tile].next)
    end
   end
  end
 end
end

--context isn't used, but probably should be used instead of a bunch of globals
function draw_playing_gamestate(context)
 --draw background behind launcher
 for y=c_fault_line_y,128,8 do
  for x=0,128,8 do
   spr(1,x,y)
  end
 end
 rectfill(0,120, 128, 128, 3)
 print(c_level_names[current_level+1], 64-((#c_level_names[current_level+1])*3), 121, 7) 



 line(0, c_fault_line_y, 128, c_fault_line_y, 7)
 map(current_level*c_level_cell_w, 0, 0, 0, c_level_cell_w, c_level_cell_h)
 if launched_snood then
  spr(launched_snood.sprite, launched_snood.x, launched_snood.y)
 end
 for snood in all(falling_snoods) do
  spr(snood.sprite, snood.x, snood.y)
 end


 --draw hud rectangle
 rectfill(c_level_w, 0, 128, 128, 1)
 print('danger', 100, 4, 7)
 rectfill(danger_meter.x, danger_meter.y, 
 danger_meter.x+danger_meter.w, danger_meter.y+danger_meter.h, 6) 

 do
  local hud_middle=c_level_w+((128-c_level_w)/2)
  local current_record=dget(current_level)
  print('snoods', hud_middle-(#'snoods'*2), danger_meter.y+danger_meter.h+4, 7)
  print('used:', hud_middle-(#'used:'*2), danger_meter.y+danger_meter.h+12, 7)
  if current_record>0 then
   local num_snoods_used_str=tostr(num_snoods_used)..'/'..tostr(current_record)
   if num_snoods_used<=current_record then
    --print with green border
    print_with_border(num_snoods_used_str, hud_middle-(#num_snoods_used_str*2), danger_meter.y+danger_meter.h+18, 7, 3)
   else 
    --print with orange border
    print_with_border(num_snoods_used_str, hud_middle-(#num_snoods_used_str*2), danger_meter.y+danger_meter.h+18, 7, 8)
   end
  
  else
   local num_snoods_used_str=tostr(num_snoods_used)
   print(num_snoods_used_str, hud_middle-(#num_snoods_used_str*2), danger_meter.y+danger_meter.h+20, 7)
  end
 end

 if danger_meter.filled_pct>0 then
  rectfill(danger_meter.x, danger_meter.y+danger_meter.h, 
  danger_meter.x+danger_meter.w, danger_meter.y+danger_meter.h-(danger_meter.h*danger_meter.filled_pct), 10) 
 end

 line(launcher.x+4, launcher.y+4, launcher.offx+4, launcher.offy+4, precision_mode and 9 or 7)
 line(launcher.x+3, launcher.y+4, launcher.offx+3, launcher.offy+4, precision_mode and 9 or 7)
 line(launcher.x+5, launcher.y+4, launcher.offx+5, launcher.offy+4, precision_mode and 9 or 7)
 spr(launcher.sprite, launcher.x, launcher.y)
 circfill(launcher.offx+4, launcher.offy+4, 6, precision_mode and 9 or 7)
 circfill(launcher.offx+4, launcher.offy+4, 5, 0)
 if launcher.current_snood then
  spr(launcher.current_snood.sprite, launcher.current_snood.x, launcher.current_snood.y)
 end

 --debug hud
 --local cpu_utilization=tostr(stat(1))
 --print(cpu_utilization, 128-(#cpu_utilization*4), 120, 7)
end

function update_danger_meter(delta)
 danger_meter.filled_pct+=delta
 if delta>0 then
  if danger_meter.filled_pct>=1 then
   danger_meter.filled_pct-=1
   for y=c_fault_line_y/8,c_level_start_y,-1 do
    for x=level_start_x,level_start_x+c_level_cell_w-1 do
     mset(x, y, mget(x, y-1))
    end
   end
   for x=level_start_x,level_start_x+c_level_cell_w-1 do
    mset(x, c_level_start_y, c_brick_sprite)
   end
  end
 else
  danger_meter.filled_pct=max(0, danger_meter.filled_pct)
 end
end
function clamp(v, l, u)
 return v < l and l or (v > u and u or v)
end
function hash(h)
 h ^^= h >> 16
 h *= 0x85eb.ca6b
 h ^^= h >> 13
 h *= 0xc2b2.ae35
 h ^^= h >> 16
 return h
end

function load_level(level)
 reload()
 sfx(-1)
 srand(hash(level+1))
 --globals
 num_snoods_used=0
 current_level=level
 level_start_x=level*c_level_cell_w
 num_snoods_left=0
 danger_meter.filled_pct=0

 refresh_snood_types()
 animation_ticks=0
 for y=c_level_start_y,c_fault_line_y/8 do
  for x=level_start_x,level_start_x+c_level_cell_w-1 do
   if mget(x,y)!=0 then
    num_snoods_left+=1
   end
  end
 end
 launcher.current_snood=next_snood()
 change_gamestate(c_gs_playing)
 menuitem(1, "restart level", function() load_level(current_level) end)
 
 local did_complete_all_levels=true
 for i=0,c_max_level do
  if dget(i)==0 then
   did_complete_all_levels=false
   break
  end
 end
 if did_complete_all_levels then
  menuitem(2, "next level", function() load_level((current_level+1) % (c_max_level+1)) end)
 end
end
function refresh_snood_types()
 snood_types={}
 for y=c_level_start_y,c_fault_line_y/8 do
  for x=level_start_x,level_start_x+c_level_cell_w-1 do
   local snood=c_animations[mget(x,y)].base
   if snood!=0 and snood!=c_brick_sprite and not contains(snood,snood_types) then
    add(snood_types,snood)
   end
  end
 end
end
function find_disconnected_snoods()
 --gather connected snoods
 local connected_snoods={}
 for x=level_start_x,level_start_x+c_level_cell_w-1 do
  if mget(x, y)!=0 then
   local key=cck(x, c_level_start_y)
   connected_snoods[key]=true
   gather_connected_snoods(x, c_level_start_y, connected_snoods)
  end
 end
 --loop though level and see which snoods are not in connected snoods list
 local disconnected_snoods={}
 for y=c_level_start_y,c_fault_line_y/8 do
  for x=level_start_x,level_start_x+c_level_cell_w-1 do
   local key=cck(x, y)
   local sprite=c_animations[mget(x, y)].base
   if sprite!=0 and not connected_snoods[key] then
    add(disconnected_snoods, {tile_x=x, tile_y=y,sprite=sprite})
   end
  end
 end
 return disconnected_snoods
end

function next_snood()
 if #snood_types>0 then
  return {sprite=snood_types[flr(rnd(#snood_types))+1], x=snood_start_x, y=snood_start_y,w=8,h=8} 
 end
 return nil
end

function does_collide(snood, vx, vy)
 local x1,y1=pixel_to_tile_coords(snood.x+vx, snood.y+vy)
 local x2,y2=pixel_to_tile_coords(snood.x+vx+snood.w-1, snood.y+vy+snood.h-1)
 
 --check all 4 points
 return y1<c_level_start_y or mget(x1,y1)!=0 or mget(x1,y2)!=0 or
  mget(x2,y1)!=0 or mget(x2,y2)!=0
end

function will_collide(snood)
 if does_collide(snood, snood.vx, 0) then
  return true, false
 elseif does_collide(snood, 0, snood.vy) then
  return false, true
 elseif does_collide(snood, snood.vx, snood.vy) then
  return true, true
 else
  return false, false
 end
end
function gather_connected_snoods(snood_tile_x, snood_tile_y, out_connected_snoods)
 for y=snood_tile_y-1,snood_tile_y+1 do
  for x=clamp(snood_tile_x-1,level_start_x,level_start_x+c_level_cell_w-1),clamp(snood_tile_x+1,level_start_x,level_start_x+c_level_cell_w-1) do
   local key=cck(x, y)
   if mget(x, y)!=0 and not out_connected_snoods[key] then
    out_connected_snoods[key]=true
    gather_connected_snoods(x, y, out_connected_snoods)
   end
  end
 end
end

--stands for "create coordinate key"
function cck(x,y)
 return tostr(x)..';'..tostr(y)
end
function gather_matching_snoods(snood_tile_x, snood_tile_y, snood_type, snoods_matched, num_matched_snoods)
 for y=snood_tile_y-1,snood_tile_y+1 do
  for x=clamp(snood_tile_x-1,level_start_x,level_start_x+c_level_cell_w-1),clamp(snood_tile_x+1,level_start_x,level_start_x+c_level_cell_w-1) do
   local key=cck(x, y)
   if snoods_matched[key]==nil and c_animations[mget(x,y)].base==snood_type then
    snoods_matched[key]={tile_x=x,tile_y=y}
    num_matched_snoods,_=gather_matching_snoods(x, y, snood_type, snoods_matched, num_matched_snoods+1)
   end
  end
 end
 return num_matched_snoods, snoods_matched
end

function pixel_to_tile_coords(px_x, px_y, round_up_x, round_up_y)
 local fx=round_up_x and ceil or flr
 local fy=round_up_y and ceil or flr
 --NOTE: we do c_level_start_y-1 as lower bound because the check x code is different from the check y code
 --For check x code, we don't go into the collision function if the snood is about to go out of bounds
 --but for y, we do because if we are about to go out of bounds for x, we keep moving and just bounce.
 --for y, we want the snood to stop
 return clamp(fx(level_start_x+px_x/8),level_start_x,level_start_x+c_level_cell_w-1), 
  clamp(fy(px_y/8),c_level_start_y-1,c_level_start_y+c_level_cell_h-1)
end
function px_to_tile_lower_x(p) 
 return flr(p/8)+level_start_x
end
function px_to_tile_lower_y(p) 
 return flr(p/8)+c_level_start_y
end
function px_to_tile_higher_x(p) 
 return ceil(p/8)+level_start_x
end
function px_to_tile_higher_y(p) 
 return ceil(p/8)+c_level_start_y
end

function calc_launcher_coords() 
 return cos(launcher.angle)*20 + launcher.offx, sin(launcher.angle)*20 + launcher.offy
end

-->8
--utility functions
function deep_tostr(v)
	if type(v) == 'table' then
		local ret='{'
		for k,v in pairs(v) do
			ret=ret..deep_tostr(k)..': '..
			deep_tostr(v)..',\n'
		end
		ret=ret..'}\n'
		return ret
	else
		return tostr(v)
	end
end
function print_with_border(string, x, y, foreground, border)
 print(string, x, y, border)
 print(string, x+1, y, border)
 print(string, x+2, y, border)
 print(string, x, y+1, border)
 print(string, x, y+2, border)
 print(string, x+1, y+2, border)
 print(string, x+2, y+1, border)
 print(string, x+2, y+2, border)
 print(string, x+1, y+1, foreground)
end

----------------------------
-- sets up ascii tables
-- by yellow afterlife
-- https://www.lexaloffle.com/bbs/?tid=2420
-- btw after ` not sure if 
-- accurate
function setup_asciitables()
 chars=" !\"#$%&'()*+,-./0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[\\]^_`|ÄÄÅÇÉÑÖÜáàâäãéåçéèêëíìîïñóòô~"
 -- '
 s2c={}
 c2s={}
 for i=1,#chars do
  c=i+31
  s=sub(chars,i,i)
  c2s[c]=s
  s2c[s]=c
 end
end
---------------------------
function asc(_chr)
 return s2c[_chr]
end
---------------------------
function chr(_ascii)
 return c2s[_ascii]
end
-- sprite print centered on x
function sprintc(_str,_y,_c,_c2,_c3)
 local i, num
 _x=63-(flr(#_str*8)/2)
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+160
  spr(num,_x+(i-1)*8,_y*8)
 end
 pal()
end
-------------------------------
-- sprite print
-- _c = letter color
-- _c2 = line color
-- _c3 = background color of font
-- collapse all these sprite
-- printing routines into one
-- function if you want!
function sprint(_str,_x,_y,_c,_c2,_c3)
 local i, num
 palt(0,false) -- make sure black is solid
 if (_c != nil) pal(7,_c) -- instead of white, draw this
 if (_c2 != nil) pal(6,_c2) -- instead of light gray, draw this
 if (_c3 != nil) pal(5,_c3) -- instead of dark gray, draw this
 -- make color 5 and 6 transparent for font plus shadow on screen
  
 for i=1,#_str do
  num=asc(sub(_str,i,i))+96
  spr(num,(_x+i-1)*8,_y*8)
 end
 pal()
end

function contains(v, t)
 assert(type(t) == 'table')
 for element in all(t) do
  if element == v then
   return true
  end
 end
 return false
end

--[[
********************************
Win screen game state
******************************
]]

function init_win_screen()
 local best_num_snoods_used=dget(current_level)
 local new_record=false
 if best_num_snoods_used==0 or num_snoods_used<best_num_snoods_used then
  dset(current_level, num_snoods_used)
  new_record=true
 end
 local gameend_msgs
 
 if current_level<c_max_level then
  gameend_msgs={'you won!', 'snoods used: '..tostr(num_snoods_used)}
  if new_record then
   add(gameend_msgs, 'new record!')
  end
 else
  gameend_msgs={'congrats!','you beat the game!', 'snoods used: '..tostr(num_snoods_used)}
  if new_record then
   add(gameend_msgs, 'new record!')
  end
 end
 add(gameend_msgs, 'press ó to continue')

 local max_len=0
 for msg in all(gameend_msgs) do
  max_len=max(#msg,max_len)
 end
 local bx=64-(max_len*6)/2
 local by=64-((6*#gameend_msgs)/2)
 return {gameend_msgs=gameend_msgs,
  max_len=max_len, bx=bx, by=by}
end
function update_win_screen_gamestate(context)
 if is_pressed(ó) then
  if current_level<c_max_level then
   load_level(current_level+1)
  else
   change_gamestate(c_gs_start_screen)
  end
 end
end

function draw_win_screen_gamestate(context)
 draw_playing_gamestate(context)

 rectfill(context.bx,context.by,context.bx+context.max_len*6,
  context.by+6*#context.gameend_msgs+2,0)
 rect(context.bx,context.by,context.bx+context.max_len*6,
  context.by+6*#context.gameend_msgs+2,7)

 local y=64-(6*#context.gameend_msgs)/2 + 2
 for msg in all(context.gameend_msgs) do
  local x=64-(#msg*4)/2
  print(msg,x,y,7)
  y+=6
 end
end
--[[
********************************
Game Over screen game state
******************************
]]

function init_game_over_screen()
 local gameend_msgs={'game over!', 'press ó to restart the level'}

 local max_len=0
 for msg in all(gameend_msgs) do
  max_len=max(#msg,max_len)
 end
 local bx=64-(max_len*6)/2
 local by=64-((6*#gameend_msgs)/2)
 return {gameend_msgs=gameend_msgs,
  max_len=max_len, bx=bx, by=by}
end
function update_game_over_screen_gamestate(context)
 if is_pressed(ó) then
  load_level(current_level)
 end
end

function draw_game_over_screen_gamestate(context)
 draw_playing_gamestate(context)

 rectfill(context.bx,context.by,context.bx+context.max_len*6,
  context.by+6*#context.gameend_msgs+2,0)
 rect(context.bx,context.by,context.bx+context.max_len*6,
  context.by+6*#context.gameend_msgs+2,7)

 local y=64-(6*#context.gameend_msgs)/2 + 2
 for msg in all(context.gameend_msgs) do
  local x=64-(#msg*4)/2
  print(msg,x,y,7)
  y+=6
 end
end
__gfx__
00012000606660666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0666066606660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652206660666066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70660666066606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc07656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900090040405565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90090004005767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000712826007282160
a979979400e88000d71cc17dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500612825006282150
a71991740e111800d77cc77dd71cc17d271881722718817203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666666665000dd0009a9009a9776650006ddddd000006600070000007
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
b3b00b3b0bbbbbb00000000000000900aaaaaaaaaaaaaaaa994499444444444499999999555555555555555566666666666d6666dd5555ddcccccccc00088000
b039930bbbb33bbb0000000000009a90aaa999aaaaaa99aa944494444444444499444499555d55ddd55dd55d6d6666d66dd666d6d566665dcccccccc00800800
00999200b33bb33b0000000000000900aaaaaa9aaaaaaa9a444444444444444444444444dddddddddddddddd6666666666dd6d6656666665cccccccc08099080
00944200b393323b0000090000e00b00aa9aaa9a99aaaaaa1414141499449944991111995d55d555dd555d55666666666d66666656666665cccccccc80900908
009992000099920000909a900eae0300a9aaa9aaaa9aaaaa414141419444944494111149dddddddddddddddd6666666666666dd656666665cccccccc80900908
099999200444992009a9090000e00300a9aaaaaaaaaaa9aa11111111444444449911119955dd5d55d555d55d666666666666d6665d6666d5cccccccc08099080
044499200999992000900b0000b00300aa99aaaaaa999aaa000000004444444444111144dddddddddddddddd6d6666d66dd666ddd5dddd5d1cc11cc100800800
029992200299922000b0030000300300aaaaaaaaaaaaaaaa000000004444444499111199555555555555555566666666d666666ddd5555dd1111111100088000
00000000002222200777000000044000000aa000007000000777700000bbbbbbbbbbbbbbbbbbbb002222222222222222000000000000000000000bbb00990000
2222222202944442067770000049940000a7aa0000700000070070000b333b333b333b3333b333b042244224422442240000000000000000000b3b3b00049000
44444444029999420677770000444200007aa90000700000070070000b34333433343334433343b04444444444444444000000000000000000bbb3bb09094090
44444444022222220677777000494200007aa9007770000077077000b3444444444444444444443b44444444444444220b00000000000000003b3b3094994949
222222220294949206777700004992000a7aaa907770000077077000b3344444444444444444433b4444444444444422b0b0bb00000000000bb3bbb099494490
222222220294949206777000004942000aaa99900000000000000000bb34444444444444444443bb444444444222444400b0b0b0000000000b3b3b0009949900
2442442402949492066600000049920000666d000000000000000000b3344224422442244224433b4224422442224224000b0000077707703bbb000000949000
22422424002222200000000000042200000000000000000000000000b3222222222222222222223b2222222222222222000b0000777777773300000000040000
00aaa900000ee0000000000000800000008000000000000000000000008008000000000000808000000000000fffff000fffff000fffff00002ee20000000000
00666d000eeaaee0000ee0000877000008770000008000000007000000088000000000000008800000000800f44444f0f44444f0f44444f002222220002ee200
067176d00eeaaee00eeaaee0a7170007a7170f0708770007000770700088e800080880800088e80008088000f4fff4f0f4fff4f0f4fff4f0047ff74002222220
6771766db0beeb0b0eeaaee0087777770877ff77a71777770004007708888e800088e80008888e800088e800f4f4f4f0f4f4f4f0f4f4f4f0471ff17404ffff40
6771116db3bbbb3b0bbeebb0077fff77077fff77087fff77009994400818818008888e800818888008888e80f4f444f0f4f444f0f4f444f00ffffff0471ff174
6777766d3bb1b1bb33bb1b1b077ff7700777f770077ff7700949994002888e8001888e100288888001888e80f4ff22f0f4ff1e10f4fff1e1002222000ffffff0
067766d03bbbbbbb33bbbbbb0077770000a7770000777a00099494400288888002888880022288800222888044422220444feee0444feeee00eeee0000eeee00
00666d000333333003333330000a0a0000000a00000a000009944400002228000022280000222200002222000422220004eeeee004eeeeee0040040000400400
0002ee20002ee200002ee2000000000000000000002ee2000022ee00000000000022ee000022ee000022ee00022ee00000000000002222000000000002222000
002222220222222002222220002ee2000000000002222220022222200022ee00022222200222222002222220222222000022ee00022222200022220022222200
0447ff74047ff760014ff4100222222000000000071ff170044447f002222220044447f0044447f0044447604441ff0002222220044444400222222044444440
0471ff17471ff1644f1ff1f401ffff1000000000477ff774044f71f004444ff0044f71f0044f71f0044f716044ff1d0004441ff04f4444f404444440f4444f40
00ffffff0ffffd6d0fffffd04f1ff1f4002ee2000ffffff000fffff0044f71f000fffff000fffff000fffd6d0ff4d666044ff1f00ffffff04f4444f4ffffff00
00222200002222d000222d6d0ffffff002222220002222000022220000fffff00022220000222200002222d002222d0000fffff0002222000ffffff000222200
00eee40000eeee4000eeee6000eeee00011ff11000eeee0000eeee0000eeee0000eee400004eee0000eeee400eeee00000eeee0000eeee0000eeee0004eeee00
004000000040040000400460004004004ffffff40040040000400400004004000040000000000400004004000400400000400400004004000040040000000400
__gff__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000040400000000000000000000000000000000000000000000000000000000000c0c00000000000000000001000000000000000001000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
ee0000620000640000e300006b6b6b626b6b6b626b6b6b646200000000ec6200000000ec00000000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ee0000620000640000e300626b64646b6464626b626b62006400006b00006400006b000000006400ec0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0000620000640000e30000626b62626b6b6b646b626b62000062ee0000000062ee0000000062006400e300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ee0000620000640000e300626b64646b6464626b6b6b640000ec6400000000ec640000006b00000000006b6264eeec0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeecec62ecec646b6be36b6b626b62626b6b6b626b626b62006400006b00006400006b00ee0000626be30000e36400e30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006462646264626462646264626200000000ec6200000000ec6400006400ec00006b62006b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000620000ee00ee0000000000620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000006be364ec6264626be3ecee640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
000100002b52329543265532555323551215511f5511c5511955118551165511455113541105410d5310b52108521075210551103511025110151102400023000130003400024000140001400024000240001400
010f00000004400011000001c7141c7151c51510001237040704007011000001c7141c715000001c515237040504405011000001c7141c7152351510001240150204002011000001c7141c715000001c51523714
010f00000c04300000000001871418715185151c0001c700246150000000000187141871500000185151f7040c04300000000001f7141f7151f715100001f015246150000000000187141871500000245151f714
010f00000304403011000001b7141b7151b51510001237040704007011000001b7141b715000001b5152370405044050110000020714207152451510001240150a0400a011000001a51526515225151d51522714
010f00000c043287102b7101871418715185152471024702246152f7102b71018714187152b710185152b7100c0432d710307101f7141f7151f715247101f01524615347102b715187141871500000245151f714
010f00000c04324510275101871418715185151b51033700246152c5102b510187141871527510185151f7040c04327510245101f7141f7151f715245101f015246152451022510187141871522510245151f714
010f00000804408011000001b7141b7151b51510001237040804008011000001b7141b715000001b5152370407044070110000022714227152751513001270150704007011000001a51526515225151d51522714
010f00000c04330700337001871430710307152e7102e715246152e7102e71518714187152e700185151f7040c04333700307001b5142c5102c5152b5102b515246152751027515337051a71526715227151d715
010e0000184251d3252032524425356152c325184251d32520325184251d3252c325356151d32520325184251d32520325184251d32535615244251d32520325184251d3252c3252442535615203251842529325
010e00000c0430544505435054450543505445054350544501435014450143501445014350144501435014450c0430344503435034450343503445034350344500435004450043500445004350c0430043500445
010e00002042524325293252c4251d3252032524425293252c3251d4252032524325294252c3251d3252042524325293252c4251d3252032524412293252c3251d4252032524325294252c3251d3252042524325
010e00000c043014350144501435014450143520415014350c04320415014350143501435014451d415204150c043014350144501435014450143501445014350c04300445004350044500435004350043500445
010e0000182151d3251d3251d325356151d325304201d3252e4202e4201d3251d325356151d325292202c2202c2201d3251d3251d325356151d3252e4201d325294201b3251b32527420356151b3251b3251b325
010e00000c043014450143501425034450343503425034150c04305445054350542508445084350842508415356150a4450a4350a425356150c4350c4250c4150c04300445004450044500445004450043500435
010e000029420294112941229415356152b4202b4112b4122d4202d4112d4122d4123561530420304123041232411324103241032412354113541235412294163541635416294162941635416354162941629416
01100000070402671524815247150b0402671524815075010c04024715248150d040237250e0402481500000070402571524815267150b04023715248151d7150c04023715248150d0401d7150e0402481507501
011000000c50022735230252873522025237352672522035237252803523725280352672528005260050c5000c5002e7352f0252e7352f0252b7352802526735220251f735210251c7351f0250c5000c5000c500
01100000070402b715248151f7150b04030715248152d7150c04023715248150d040237150e0402481523715130400000030715000002f71500000070430000029715280152971528015297151c0052e7110a700
0110000035725340253571534025357153402532715300252e7252b0352d725280352b7252d0352f7253203537725000053772500005377250000524815000052b0152b7152b0152b7152b0151f7052f7110a700
0110000009040020003271502000317150200009043020002b7152a0152b7152a0152b7151e005307110c700000401c015297152d7002871500000040401f01529715257002871500700050401f715070400c501
0110000037725000053772500005377250000524815000052b0152b7152b0152b7152b0151f7052f7110a70024815180152b7252d7002b7253600524815220153072524815307252a0052481528715248153c715
0110000037725000053772500005377250000524815000052b0152b7152b0152b7152b0151f7052f7110a700248152d7352e0252d7352e0252d735248153402532725248152e7252f025248152b0352481528735
010e00000c0433f2153f215243032461018615243033f2150c043243033f2153f215246101203403041000410c043001053f2153f21524610186153f215003040c0433f215000053f21524610000140c02118031
010e00000c0450015500140000350c043001400003500324001550014000035001400c043186153f215003240c0450015500140000350c043001400003500324001550014000035001400c043186153f21500324
010e00000c0430010500100000050c0430010000005003040c0430010000005001000c0431202403031000310c0430010500100000050c0430010000005003040c0430010000005001000c043000140c01118021
010e00000c0450015500140000350015500140000350032400155001400003500140000351861430600003240c045001550014000035001550014000035003240015500140000350014000035186143060000324
010e00000c0433f2153f215000052461018615000053f2150c043001003f2153f215246101200403000000000c043001053f2153f21524610186153f215003040c0433f215000053f21524610000040c00018000
010e00000c0450015500150000050c043001500000500304001550015000005001500c043186153f215003040c0450015500150000050c043001500000500304001550015000005001500c043186153f21500304
011400002743018726217161871627430187162171627430295150040026435264352443526435247162043000400000001d430004002772618716217161871627700187162d5151870024615187162d51518700
011400000c04305320295150c320306150332005320295050c043053201d22505320306151d225000000c04305330000001b42005320306150000003320053300c04300320335150c043033200f3300432010330
011400002e4302a72627716247162051524716304302c430000000b2100c2100d2200f2101e420204101e420314302d7262a716277162351527716334302f4302f7262b51528716257162b5152b5152b5152b515
011400000c043083202051506330306150c04306320083300c0430b32000310013200331006320083100b9500c043099400b9400c043306150b330235150c0430994019515079400c04330615129400794013940
0114000027400187002171618716270001800021716187162740018700217161801627000184152171618716274001870021016187161831518415217161801627400187002151624506275162d3152171118016
010c00001075513755187451c7451f735247252b71512755157551a7451e74521735267252d71514755177551c7452074523735287252f7153472500000000000000000000000000000000000000000000000000
010c0000000001072513725187251c7251f725247252b70512725157251a7251e72521725267252d70514725177251c7252072523725287252f72534705000001ca051ca051ca051ca051ca051ca051ca051ca05
012000001474014731147211471516740167311672116715197401973119721197151b7401b7311b7211b7111b7101b7121b7121b7121b7151970019700197001970019700197001b7001b7001b7001b7001b700
012000001272012720127251270510720107201072510705117201172011725117051572015720157201572015722157221572215725057000570005700007000070006705087050970009700097000970009700
012000000102001020010200102506020060200602006025080200802008020080250402004020040200402004020040200402204022040250400500000000000000000000000000000000000000000000000000
012000000102001020010200102506020060200602006025080200802008020080250402004020040200402004020040200402204022040250400500000000000000000000000000000000000000000000000000
000100002c2502b6202a2502962028250276202625025620242502362022250216202025000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002a3502a5102a515245653005030510305152a565361503651036515365053450029500295002f5003f500335003450029500295002f5003f500335003450029500295002f5003f500005000050000500
000200001021304611102230462110223046311023304631102430464110253046511026304661102630465110253046511024304641102430463110233046211022304621102130461110213046111021304611
000100000c1500e0511105114051170511705014051120510f0510c15100100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200003f6142646525361242512345122341212413f6041f3050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b3501b2501c1511d1411f141211312313127121371213b1101b3301b2301c1311d1311f131211312312127121371113b1101b3101b2101c1111d1111f111211112311127111371113b1100000000000
000100000905009040090400903009031090310902109021090210a0210b0210b0210c0210d0200e0210f02111011120111c0011a0011700116001140011200111001100010d0010d00100001000010000100001
000300000c7500f041130311312500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000296632866528604276532765426605256432564524604236432264421603206351e6351c6031b6341762314604106230c625086030661503613026040c0040740400604083040c004172041160400404
0002000000373016732b3730167300473233731c26301663053631a26301663016530d253024531e3530164300343054431c2430163325333016330033325423016230162309323016231d313016131021300413
000100000f12500000000000710500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000c34300300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0005000011574160741357418074155641a064165641b054185541d0541a7541f5441b044217441d544220441f744245342103426734220242772424014297140070400704007040070400704007040070400704
000600000b07012741127350c07013741137350d07014741147350f0701674116735182001840018300185021800512200122050a2000a4000a3000a0050a70500000000000d0001400014005000000000000000
000300000c343236450933520621063311b6210432116611023210f611013110a6110361104600036000260001600016000460003600026000160001600016000160004600036000260001600016000160001600
00020000187551a5551c7551554517745195451273514535167350f52511725135250c7150e515107150060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000600001c36311000103331031310303107031070513005306041070310705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001c1431c1331c1231c1131b1031a1030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00002d27321363164530c3430733303323013130d50309503075031550300003000030000300003000031d303123031b0030000300003000030000300003153030b3031a7031f5031b003217031d50322003
00010000352103751534100371003f10039100331001f1001f1001f1001f100231002a10034100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c0150c0050c005110350c0050c0050c00516055000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
00020000071540f163163730b22332643216331c6231861315613136130e6130a61304600000000000000000000000b1010710105101031010110100000000000000000000000000000000000000000000000000
000100000f12500000000000710500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000c15515003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 02 03 43 44
00 02 03 43 44
00 04 03 43 44
00 04 03 43 44
00 02 05 43 44
00 02 05 43 44
00 04 06 43 44
00 04 06 43 44
00 07 08 43 44
02 04 08 43 44
01 0b 0a 43 44
00 0b 0a 43 44
00 09 0a 43 44
00 09 0a 43 44
00 0c 0d 43 44
00 0c 0d 43 44
00 0c 0d 43 44
00 0a 0d 43 44
02 0e 0f 43 44
01 10 11 43 44
00 12 13 43 44
00 10 11 43 44
00 12 13 43 44
00 14 16 43 44
00 14 15 43 44
00 14 16 43 44
02 14 15 43 44
01 19 1a 43 44
00 19 1a 43 44
00 17 18 43 44
00 17 18 43 44
00 1b 1c 43 44
02 1b 1c 43 44
01 21 1e 43 44
00 21 1e 43 44
00 1d 1e 43 44
00 1d 1e 43 44
00 1f 20 43 44
02 1f 20 43 44
04 22 23 43 44
04 24 25 26 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
