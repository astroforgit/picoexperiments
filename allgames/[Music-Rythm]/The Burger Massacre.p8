pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- main functions
-- prototyping
-- 10.12 - 20.12.2018
-- nils huebner, clemens rieck & sebastian schaffrath
-- radical burger massacre

--[[  states

 0 = idle-screen
 1 = menu
 2 = optionen
 3 = game
 4 = game over
 5 = game vs ai
 6 = steuerung
 7 = beschreibung
 8 = credits

]]

--[[ sprachen

 0 = englisch
 1 = deutsch
 
 
]]

function _init()

 ticker = 0
 intro_ticker = 0
 teststring = "test"
 debug_counter = 0
 state = 0
 order = {}
 order_pos = 0
 order_delay = 20
 way  = 0
 way2 = 0
 winner = ""
 menu_pos = 0
 options_pos = 0
 gameover_sound = false
 is_music = false
 
 window_x = {}
 window_y = {}
 credits_strings= {}
 
 title_y_init = 15
 logo_x = 42
 logo_y = -30
 massacre_x = 42
 massacre_y = -30
 logo_burger_left_x  = 28
 logo_burger_left_y  = -30
 logo_burger_right_x = 90
 logo_burger_right_y = -30
 is_logo_fall = false
 is_logo_burger_fall = false
 logo_fallen = false
 logo_burger_left_fallen = false
 logo_burger_right_fallen = false
 
 controls_color = 7
 
 lang_id = 0
 lang_short = "eng"
 
 vegan_check = "off"
 vegan = false
 
 freeze = false
 
 gravity = 0.3
 elasticity = 0.1
  
 streak_limit = 5
 failstreak_limit = 3
 streak_time = 120
 failstreak_time = 120
  
 burger = {
 
  count = 20,
  frames = {
   { 1,3,5,7,9},				-- burger 1
   {32,34,36,38,9},
   {40,11,42,13,9},
   {44,46,64,9},
   {128,160,130,9},
--   {66,68,70,72,74,76,78,9}    -- burger 6
           },
  varieties = 5,
  order  = {},
  rain_spr = {193,194,193,32,128},
  rain_x = {-20,-20,-20,-20,-20},
  rain_y = {-10,-10,-10,-10,-10},
  rain_w = {1,1,1,2,2},
  rain_h = {1,1,1,2,2},
  rain_v = {1,1.3,1.5,2,2.5}
 }
 
 
 player1 = {
 state = 0,
 x = 23,
 y = 60,
 c = 8,
 symbol_x = 52,
 symbol_y = 44,
 fail = false,
 success = false,
 symbol_flip = false,
 action_timer = 0,
 active_anim = 0,
 streak = 0,
 streak_timer = 0,
 streak_x = 10,
 streak_y = 30,
 failstreak_timer = 0,
 streak_display = false,
 failstreak_display = false,
 failstreak = 0,
 streak_pos = ceil(rnd(5)),
 failstreak_pos = ceil(rnd(6)),
 success_sound = 8,
 fail_sound = 6,
 empty_sound = 12,
 crunch = {},
 burger = {
  x = 23,
  y = 0,
  w = 2,
  h = 2,
  gap = 9,
  plate_x = 23,
  plate_y = 60,
  fall = false,
  fall_speed = 0,
  state = 0,
  eaten = false,
  order_pos = 1,
  remaining = burger.count,
  anim_index = 1,
  crumble_extra = 0
          }
 
 }
 
 player2 = {
 state = 0,
 x = 93,
 y = 60,
 c = 1,
 symbol_x = 68,
 symbol_y = 44,
 fail = false,
 success = false,
 symbol_flip = true,
 action_timer = 0,
 active_anim = 0,
 streak = 0,
 streak_timer = 0,
 streak_x = 90,
 streak_y = 30,
 failstreak_timer = 0,
 streak_display = false,
 failstreak_display = false,
 failstreak = 0,
 streak_pos = ceil(rnd(5)),
 failstreak_pos = ceil(rnd(6)),
 success_sound = 9,
 fail_sound = 7,
 empty_sound = 11,
 crunch = {},
 burger = {
  x = 93,
  y = 0,
  w = 2,
  h = 2,
  gap = 9,
  plate_x = 93,
  plate_y = 60,
  fall = false,
  fall_speed = 0,
  state = 0,
  eaten = false,
  order_pos = 1,
  remaining = burger.count,
  anim_index = 1,
  crumble_extra = 0
          }
 }
 
 ai = {
 state = 0,
 x = 93,
 y = 60,
 c = 1,
 symbol_x = 68,
 symbol_y = 44,
 fail = false,
 success = false,
 symbol_flip = true,
 action_timer = 0,
 active_anim = 0,
 streak = 0,
 streak_timer = 0,
 streak_x = 90,
 streak_y = 30,
 failstreak_timer = 0,
 streak_display = false,
 failstreak_display = false,
 failstreak = 0,
 streak_pos = ceil(rnd(5)),
 failstreak_pos = ceil(rnd(6)),
 success_sound = 9,
 fail_sound = 7,
 empty_sound = 11,
 crunch = {},
 burger = {
  x = 93,
  y = 0,
  w = 2,
  h = 2,
  h = 2,
  gap = 9,
  plate_x = 93,
  plate_y = 60,
  fall = false,
  fall_speed = 0,
  state = 0,
  eaten = false,
  order_pos = 1,
  remaining = burger.count,
  anim_index = 1,
  crumble_extra = 0
  },
  
  difficulty = 2,
  eat_delay = -1,
  delay_timer = 0,
  serve_delay = -1,
  failchance = -1
  
 }
  
 update_options()

end


function _update() 

 ticker+=1
 intro_ticker+=1
 start_functions()
 
-- debug()

end


function _draw()

 cls()
 
 draw_states()

-- draw_debug()

end
-->8
-- update function()

function game_functions()

   direction_order_position()
   interval()
   
   player_functions()
      
   get_winner()
   check_game_over()
   
   play_music()

end

function player_functions()
 
		 physics(player1)
   update_player(player1,0)   
   player_serve(player1,0)
   player_action(player1,0)   
   plate_collision(player1,0)   
   update_crumbles(player1)
   cheats(player1,0)   
   streak_display(player1) 
   failstreak_display(player1)   
   fail_action(player1,0)   
   symbol_timer(player1)

   if state == 3 then

     physics(player2)
     update_player(player2,1)     
     player_serve(player2,1)  
     player_action(player2,1)     
     plate_collision(player2,1)     
     update_crumbles(player2)  
     cheats(player2,1)     
     streak_display(player2)
     failstreak_display(player2)     
     fail_action(player2,1)     
     symbol_timer(player2)
     
   elseif state == 5 then

     physics(ai)     
     ai_serve(ai)  
     ai_action(ai)     
     plate_collision(ai)     
     update_crumbles(ai)  
     cheats(ai)     
     streak_display(ai)
     failstreak_display(ai)     
     fail_action(ai)     
     symbol_timer(ai)
   end

end

function update_player(p,n)
 
 p.burger.y += p.burger.fall_speed
 p.active_anim = #burger.frames[burger.order[player1.burger.order_pos]]
  
 update_streak(p)
 update_failstreak(p)
  
 fall_crumble(p)
 
 if   p.burger.anim_index == p.active_anim-1 then
      p.burger.crumble_extra = 5*p.active_anim
 else p.burger.crumble_extra = 0
 end
 
    if p.active_anim != p.burger.anim_index then
     if p.active_anim == 8 then
      p.burger.h = 4
      p.burger.gap = 25
     end
    else
     p.burger.h = 2
     p.burger.gap = 9
    end

end

function interval()

 if ticker%order_delay == 0 then
  order_pos+=1
  freeze = false
  
 end
end

function direction_order_position()
 
 if order[order_pos] == 1 then
    way  = "‹"
    way2 = "s"
    way_s = 209
 elseif order[order_pos] == 2 then
    way  = "‘"
    way2 = "f"
    way_s = 210
 elseif order[order_pos] == 3 then
    way  = "”"
    way2 = "e"
    way_s = 225
 elseif order[order_pos] == 4 then
    way  = "ƒ"
    way2 = "d"
    way_s = 226
 end
end

function player_action(p,n)
 if  not freeze 
 and not p.burger.fall
 then 
  for b = 0, 3 do
    if p.burger.anim_index < player1.active_anim then
      if  order[order_pos] == b+1
  		  and btnp(b,n) then

         p.burger.anim_index+=1
         crunch(p)
         p.streak+=1
         p.failstreak=0
         freeze = true
         p.success  = true
         p.fail  = false
         p.action_timer = 0
         sfx(5)         
         
      elseif  order[order_pos] != b+1
   	  and btnp(b,n) then
  					  
       p.streak = 0
       p.failstreak  += 1
       p.fail  = true
       p.success  = false
       p.action_timer = 0
       sfx(p.fail_sound)
         
      end
    elseif p.burger.anim_index == player1.active_anim then
     if btnp(b,n) and p.action_timer == 0
     then
       plate_shake(player1,0)
       plate_shake(player2,1)
     end
    end
  end
 end
end

function player_serve(p,n)
 
 if btnp(4,n) and p.burger.anim_index == #burger.frames[burger.order[p.burger.order_pos]] or
    btnp(5,n) and p.burger.anim_index == #burger.frames[burger.order[p.burger.order_pos]] then
   p.burger.order_pos+=1
    if p.burger.order_pos > #burger.order then
         p.burger.order_pos = #burger.order
    end  
   
   p.burger.remaining -=1
   p.burger.anim_index = 1
   p.burger.y = -5
   p.burger.state = 0
   p.burger.fall = true
   p.eaten = false
   p.crunch = {}
 
 end 

end


function get_winner()

 if state == 3 then
   if player1.burger.remaining < player2.burger.remaining then
     winner = string.player1
   elseif player2.burger.remaining < player1.burger.remaining then
     winner = string.player2
   else
     winner = string.tie
   end
     
 elseif state == 5 then
     
   if player1.burger.remaining < ai.burger.remaining then
     winner = string.player1
   elseif ai.burger.remaining < player1.burger.remaining then
     winner = string.ai
   else
     winner = string.tie
   end
 end
end


function check_game_over()

 if player1.burger.remaining < 1 or
    player2.burger.remaining < 1 or
    ai.burger.remaining < 1 then
    
    state = 4
    
 end
end

function game_over()

 clear_orders()
 burger_rain_big(burger)
 burger_rain_small(burger)
 
 if not gameover_sound then
        sfx(10)
        gameover_sound = true
 end

 if btnp(—) then
   state = 1
 end

end

function update_options()

   clear_orders()

   direction_order_generator() 
   
   if #burger.order < burger.count then
   burger_order_generator()
   end
   
   reset_player(player1)
   reset_player(player2)
   reset_player(ai)
   
   reset_burger(player1.burger)
   reset_burger(player2.burger)
   reset_burger(ai.burger)
   
   ticker = 0
   order_pos = 0
   
   is_music = false

end


function menu()
 menu_update_position()
 menu_choose_action()
 move_title()
 burger_rain_big(burger)
 burger_rain_small(burger)
 
end

function menu_update_position()
  if     btnp(3) then
   menu_pos += 1
  elseif btnp(2) then
   menu_pos -= 1
  end
    
  if state == 1 then
 
    if     menu_pos >= 4 then
           menu_pos =  0
    elseif menu_pos <  0 then
           menu_pos =  3               
    end
  end  
end

function menu_choose_action()

  if     menu_pos == 0 and btnp(5) then
         start_newgame()
  elseif menu_pos == 1 and btnp(5) then
         start_newgame_ai()
  elseif menu_pos == 2 and btnp(5) then
         state = 2
  elseif menu_pos == 3 and btnp(5) then
         state = 7
  end
--[[  
  if btnp(4) then
   state = 0
   ticker = 0
   reset_intro()
  end
]]
end

function options()

 burger_rain_small(burger)
 options_update_position()
 options_choose_action()

end

function options_update_position()
  if     btnp(3) then
   options_pos += 1
  elseif btnp(2) then
   options_pos -= 1
  elseif btnp(4) then
   state = 1
  end
    
  if state == 2 then
 
    if     options_pos >= 7 then
           options_pos =  0
    elseif options_pos <  0 then
           options_pos =  6               
    end
  end
  
end

function options_choose_action()

  
  if     options_pos == 0 then
    change_burger_count()
  elseif options_pos == 1 then
    change_interval()
  elseif options_pos == 2 then
    change_difficulty()
  elseif options_pos == 3 then
    change_language()
  elseif options_pos == 4 and btnp(5) then
    change_vegan()
  elseif options_pos == 5 and btnp(5) then
    state = 8
  elseif options_pos == 6 and btnp(5) then
  update_options()
         state = 1
  
  end

end

function change_vegan()
  if vegan then
      pal()
      vegan = false
      vegan_check = string.off
  elseif not vegan then
      pal(5,15)
      vegan = true
      vegan_check = string.on
  end
end

function change_language_id()
        
  if     lang_id == 0 then
     lang_short = "< english >"
  elseif lang_id == 1 then
     lang_short = " < deutsch >"
  end

end

function change_language()

  if btnp(‹) then
     lang_id -= 1         
  elseif btnp(‘) then
     lang_id += 1
  end   
       
  if     lang_id  > 1 then
         lang_id  = 0
  elseif lang_id  < 0 then
         lang_id  = 1
  end
end

function start_newgame(p)
   update_options()
      
   state = 3
end

function start_newgame_ai(p)
   update_options()
      
   state = 5
end


function direction_order_generator()
 for i=1, burger.count*ceil(100/order_delay)*10+50 do
   local d = ceil(rnd(4))
  add(order, d)   
  add(ai.direction, d)   
 end
end

function burger_order_generator()
 for i=1, burger.count*ceil(100/order_delay)*10+50 do
  add(burger.order, ceil(rnd(#burger.frames)))   
 end   
end

function clear_orders()

 burger.order = {}
 order = {}
 
end

function idle()
   if intro_ticker >= 200 and btnp(—) then
     state = 1
   end
   
   burger_rain_big(burger)
   burger_rain_small(burger)
   move_title()
   logo_fall_trigger()
   logo_fall()
   logo_burger_fall()
   bite_shake()

end


function physics(p)
  
  if p.burger.fall then
			  p.burger.fall_speed+=gravity/8
  end

end

function crunch(p)

    local cr = {
      x = p.x,
      y = p.y,
      crumbles = { }
  	  }
  
  for i=1, #burger.frames[4]+p.burger.crumble_extra do
    local k = {
    
     x  = p.x+4,
     y  = p.y+4,
     vx = rnd(8) - 4,
     vy = rnd(8) - 4,
     c  = 4
    }
    
    add(cr.crumbles, k)
    
  end
  
  add(p.crunch, cr)
  
end


function update_crumbles(p)
 
 for cr in all(p.crunch) do
  for k in all(cr.crumbles) do
  
   crumble_speed(k)   
   crumble_fall(k)   
   crumble_delete(k,cr)
  
  end
 end
end

function crumble_speed(_k)

   _k.x += _k.vx
   _k.y += _k.vy   
end

function crumble_fall(_k)
   _k.vy += gravity
end

function crumble_delete(_k,_cr)

  if _k.x < 0 or _k.x > 128
  or _k.y < 0 or _k.y > 128 then
   del(_cr.crumbles, _k)
  end
end

function plate_collision(p)

 if p.burger.y >= p.y-p.burger.gap then
    p.burger.y = p.y-p.burger.gap
    p.burger.fall = false
    p.burger.fall_speed = 0
    p.burger.state += 1
 end

end

function cheats(p,n)

  if  btnp(4,n) and
      btnp(5,n) then
  
     p.burger.remaining -= flr(burger.count/10)
  end

end

function instructions()

 burger_rain_small(burger)

  if btnp(4) then
   state = 1
  elseif btnp(5) then
   state = 6
  end
end

function controls()

 burger_rain_small(burger)

  if btnp(4) then
   state = 7
  elseif btnp(5) then
   state = 1
  end
end


function change_burger_count()

    if btnp(‹) then
       burger.count -= 5         
    elseif btnp(‘) then
       burger.count += 5
    end   
           
    if     burger.count <= 5 then
           burger.count = 5
    elseif burger.count > 100 then
           burger.count = 100
    end
    
end

function change_interval()

    if btnp(‹) then
       order_delay -= 5         
    elseif btnp(‘) then
       order_delay += 5
    end   
           
    if     order_delay <= 10 then
           order_delay = 10
    elseif order_delay > 60 then
           order_delay = 60
    end
end


function change_difficulty()

    if btnp(‹) then
       ai.difficulty -= 1         
    elseif btnp(‘) then
       ai.difficulty += 1
    end   
           
    if     ai.difficulty <= 0 then
           ai.difficulty = 0
    elseif ai.difficulty > 4 then
           ai.difficulty = 4
    end
        
end

function name_difficulty()

    if     ai.difficulty == 0 then
     string.difficulty = string.very_easy
    elseif ai.difficulty == 1 then
     string.difficulty = string.easy
    elseif ai.difficulty == 2 then
     string.difficulty = string.medium
    elseif ai.difficulty == 3 then
     string.difficulty = string.hard
    elseif ai.difficulty == 4 then
     string.difficulty = string.very_hard
    end
end


function reset_game(p,n)

  if  
      btn(0,n) 
  and btn(1,n) 
--  and btn(2,n) 
--  and btn(3,n) 
  and btn(4,n) 
  and btn(5,n) 
  then
      
      state = 1
  end
end

function reset_player(p)

 p.fail = false
 p.active_anim = 0
 p.streak = 0
 p.streak_timer = 0
 p.failstreak_timer = 0
 p.streak_display = false
 p.failstreak_display = false
 p.failstreak = 0
 p.streak_pos = ceil(rnd(5))
 p.failstreak_pos = ceil(rnd(5))

end

function reset_burger(pb)

   pb.remaining = burger.count
   pb.y = 0
   pb.fall = true
   pb.fall_speed = 0
   pb.anim_index = 1

end

function update_intro()
   
  if not intro.init then 
    for n = 1, 100 do
     add(intro.x,flr(rnd(100))+10)
    end
    intro.init = true
  end
  
  intro.t+=1
    
  if intro.t%50 == 0 then
     intro.d=intro.d*intro.d
  end
end

function update_streak(p)

 if p.streak == streak_limit then
    streak_bonus(p)
    if p.burger.remaining > 1 then
     p.burger.remaining -=1
    end
    p.streak = 0   
 end
end

function update_failstreak(p)

 if p.failstreak == failstreak_limit then
    failstreak_bonus(p)
    p.burger.remaining +=1
    p.failstreak = 0   
 end
end

function streak_bonus(p)

 p.streak_pos = ceil(rnd(5))
 p.streak_timer = 1
 p.streak_display  = true
 sfx(p.success_sound)
  
end

function failstreak_bonus(p)

 p.failstreak_pos = ceil(rnd(5))
 p.failstreak_timer = 1
 p.failstreak_display  = true
 sfx(p.fail_sound)
 
end

function streak_display(p)

   if p.streak_timer >0 then
      p.streak_timer+=1
      if p.streak_timer == 60 then
         p.streak_timer = 0
         p.streak_display = false       
      end
   end
end

function failstreak_display(p)

   if p.failstreak_timer >0 then
      p.failstreak_timer+=1
      if p.failstreak_timer == 60 then
         p.failstreak_timer = 0
         p.failstreak_display = false
      end
   end
end

function plate_shake(p,n)

  for b = 0, 3 do
      if  btnp(b,n) then
          p.eaten = true
          sfx(p.empty_sound)
      end
  end
end

function fail_action(p,n)

 if freeze or p.burger.fall then 
  for b = 0, 3 do
    if  btnp(b,n) then
      p.fail = true
    else
      p.fail = false
    end
  end
 end
end

function symbol_timer(p)

 if p.fail then
  p.action_timer +=1
   if p.action_timer > 30 then
     p.fail = false
     p.action_timer = 0
   end
 elseif p.success then
  p.action_timer +=1
   if p.action_timer > 30 then
     p.success = false
     p.action_timer = 0
   end
 end
end

function fall_crumble(p)

 if p.burger.state == 1 then
  crunch(p)
  sfx(13)
   if p.burger.state > 1 then
     p.burger.state = 2
   end
 end
end

function move_title()

  if logo_fallen and intro_ticker > 370 then
   local y = (0.32*sin(time()/2))
   logo_y = title_y_init-2 * y*3
   massacre_y = logo_y+16
  end

end

function burger_rain_small(b)
 local sprites = {193,194,195}
 local _x = {60,7,105,35,80}
  for i = 1,3 do
    if intro_ticker%(60*i) == 0 then
      b.rain_x[i] = _x[i]
    end
    if b.rain_x[i] != -20 then  
     b.rain_y[i] += b.rain_v[i]
     if b.rain_y[i] > 140 then
        b.rain_y[i] = -20
        b.rain_spr[i] = sprites[ceil(rnd(2))]
     end
    end
  end
end

function burger_rain_big(b)
 local sprites = {1,32,40,44,128}
 local _x = {7,60,105,35,80}
  for i = 4,#burger.rain_x do
    if intro_ticker%(60*i) == 0 then
      b.rain_x[i] = _x[i]
    end
    if b.rain_x[i] != -20 then  
     b.rain_y[i] += b.rain_v[i]
     if b.rain_y[i] > 140 then
        b.rain_y[i] = -20
        b.rain_spr[i] = sprites[ceil(rnd(2))]
     end
    end
  end
end

function logo_fall_trigger()

 if intro_ticker == 190 then
    is_logo_fall = true
 end
 
 if intro_ticker == 260 then
    is_logo_burger_fall = true
 end  

end

function logo_fall()

 if is_logo_fall and not logo_fallen then
   logo_y += gravity*2
   massacre_y += gravity*2
   if logo_y >= 15 then
    logo_y = 15
   end
   if massacre_y >= 31 then
    massacre_y = 31
    logo_fallen = true
   end
 end
 
 if intro_ticker == 290
 or intro_ticker == 336
 then
  sfx(14)
 end
 
 
end


function logo_burger_fall()

 if is_logo_burger_fall and not burger_fallen then
    logo_burger_left_y  += gravity*2
    logo_burger_right_y += gravity*2
   if logo_burger_left_y >= 15 then
    logo_burger_left_y = 15
    logo_burger_left_fallen = true
   end
   if logo_burger_right_y >= 15 then
    logo_burger_right_y = 15
    logo_burger_right_fallen = true
   end
 end
end

function bite_shake()

 if intro_ticker == 370 then
   sfx(5)
   for i = 1,10 do
     camera((rnd(4)-2),rnd(4)-2)
   end
 else
     camera(0,0)
 end

end

function states()


 if     state == 0 then
   idle()
--   intro_ticker += 1
   
 elseif state == 1 then
   menu()
   
 elseif state == 2 then
   options()
 
 elseif state == 3 then
 
   game_functions()
   
 elseif state == 4 then
 
   game_over()
 
 elseif state == 5 then
 
   game_functions()
   ai_functions(ai)
   update_ai(ai)
   
   
 elseif state == 6 then

   controls()
   
 elseif state == 7 then

   instructions()
   
 elseif state == 8 then
   credits()
 end

end

function start_functions()

 language()
 change_language_id()  
 name_difficulty()
 reset_game(player1,0)
 states()
 stop_music()
 
end

function reset_intro()

 burger = {
 
  count = 20,
  frames = {
   { 1,3,5,7,9},				-- burger 1
   {32,34,36,38,9},
   {40,11,42,13,9},
   {44,46,64,9},
   {128,160,130,9},
--   {66,68,70,72,74,76,78,9}    -- burger 6
           },
  varieties = 5,
  order  = {},
  rain_spr = {193,194,193,32,128},
  rain_x = {-20,-20,-20,-20,-20},
  rain_y = {-10,-10,-10,-10,-10},
  rain_w = {1,1,1,2,2},
  rain_h = {1,1,1,2,2},
  rain_v = {1,1.3,1.5,2,2.5}
 }
 
end

function play_music()

 if not is_music then
    music(0)
    is_music = true
 end
end

function stop_music()

 if  state != 3 
 and state != 5
 then
    music(-1)
    is_music = true
    teststring = "stop"
 end

end
-->8
-- draw functions

function draw_field()

	map(0,0,0,0,16,16)
 draw_window()

end

function draw_direction_order(p)

 if  not freeze 
 and order[order_pos] != nil
 then
   if ticker%order_delay != 0 then
     spr(way_s,60, 44)
   end
 end

end

function draw_player_stats(p, x, y, c)
 
 circfill(x+3, y+7, 4,1)
 circfill(x+5, y+7, 4,1)
 circfill(x+7, y+7, 4,1)
 
 local r = p.burger.remaining
   if r < 10 then
     print("0"..r, x+2, y+5, 7)
   else 
				 print(p.burger.remaining, x+2, y+5, 7)
			end
 
end

function draw_active_burger(p)

 spr(
 burger.frames
  [burger.order
   [p.burger.order_pos]]
    [p.burger.anim_index],
 p.burger.x,
 p.burger.y,
 p.burger.w,
 p.burger.h
 )

end

function draw_pipe_lower(p)
 spr(
  164, p.x-4, p.y-53,3,1  
 )
end

function draw_pipe_upper(p)
 spr(
  132, p.x-4, p.y-61,3,2  
 )
end

function draw_cutlery(p)
 
 spr(
  135,
  p.burger.plate_x-4,
  p.burger.plate_y+1,
  3,
  2
 )
 
 spr(
  167,
  p.burger.plate_x-12,
  p.burger.plate_y+1,
  1,
  2,
  true
 )
 
 spr(
  168,
  p.burger.plate_x+20,
  p.burger.plate_y+1,
  1,
  2,
  true
 )
 

end

function draw_game_over()

 map(32,0,0,0,16,16)

 draw_burger_rain_small(burger)
 draw_burger_rain_big(burger)

 print(winner..string.wins, 42, 60, 10)
 print(string.continue, 30, 105, 10)

end

function draw_idle()

 map(32,0,0,0,16,16)

 draw_burger_rain_small(burger)
 draw_logo()
 draw_burger_rain_big(burger)
 
 if ticker >= 380 then
  if ticker %30 < 15 then
  print(string.idle, 30, 100, 7)
  end
 end  

end


function draw_menu()

 map(32,0,0,0,16,16)

 draw_burger_rain_small(burger)
 draw_logo()
 draw_burger_rain_big(burger)
 
 print(string.vs_player, 48,60,7)
 
 print(string.vs_ai, 48,75,7)
 
 print(string.settings, 48,90,7)
 
 print(string.controls, 48,105,7)

end

function draw_menu_position()

 spr(193,37,58+menu_pos*15)
 
end

function draw_options()

 map(32,0,0,0,16,16)
 draw_burger_rain_small(burger)
 
 print(string.settings, 48,20,11)
 
 print(string.burger_count..burger.count.." >", 18,50,7)
 
 print(string.interval..order_delay.." > frames", 18,60,7)
 
 print(string.ai_difficulty.." < "..string.difficulty.." >", 18,70,7)
 
 print(string.language..lang_short, 18,80,7)
 
 print(string.vegan_mode..vegan_check, 18,90,7)
 
 print(string.credits, 18,100,7)
 
 print(string.back, 18,110,7)
 
end

function draw_options_position()

 spr(193,8,48+options_pos*10)
  
end

function draw_credits()

 map(32,0,0,0,16,16)

 draw_burger_rain_small(burger)
 
 print(credits_strings.title, 48,20,11)
 
 print(credits_strings.l1, 28,65,7)
 
 print(credits_strings.l2, 28,85,7)
 
 print(credits_strings.l3, 28,105,7)

end


function draw_crunch(p)

    for k in all(p.crunch) do
     for cr in all(k.crumbles) do
      pset(cr.x, cr.y, cr.c)
     end
    end

end

function draw_controls()


 map(32,0,0,0,16,16)
 draw_burger_rain_small(burger)
 
 print(string.controls, 48,20,11)
 
 for i=25,31 do
   circfill(i,54,12,4) 
 end
 
 for i=96,102 do
   circfill(i,54,12,4) 
 end
 
 rectfill(10,93,44,101,4)
 rectfill(82,93,116,101,4)
 
 print(string.player1, 13,35,controls_color)
 print(string.p1_up, 25,46,11)
 print(string.p1_sides, 17,52,11)
 print(string.p1_down, 25,58,11)
 
 print(string.p1_reload, 12,95,9)
 
 print(string.player2, 86,35,controls_color)
 print(string.p2_up, 98,46,11)
 print(string.p2_sides, 90,52,11)
 print(string.p2_down, 98,58,11)
 
 print(string.p2_reload, 86,95,9)
 
 print(string.eat_descr1, 13,72,controls_color)
 print(string.eat_descr2, 13,78,controls_color)
 
 print(string.reload_descr1, 13,107,controls_color)
 print(string.reload_descr2, 13,113,controls_color)

end

function draw_intro()
 
end


function draw_streak(p)

   print(string.streak[p.streak_pos], p.streak_x, p.streak_y,10)

end

function draw_failstreak(p)

   print(string.failstreak[p.failstreak_pos], p.streak_x, p.streak_y,8)

end

function draw_fail(p)

-- circfill(p.symbol_x+9,p.symbol_y+8,8,12)
-- rectfill(p.symbol_x+5,p.symbol_y+3,p.symbol_x+14,p.symbol_y+12,0)

 spr(
 208,
 p.symbol_x,
 p.symbol_y,
 1,
 1,
 false
 )

end

function draw_success(p)

 spr(
 224,
 p.symbol_x,
 p.symbol_y,
 1,
 1,
 false
 )

end

function draw_eaten(p)

 spr(
 240,
 p.symbol_x,
 p.symbol_y,
 1,
 1,
 p.symbol_flip
 )

end

function draw_logo()

 spr(
 234,massacre_x,massacre_y,6,2
 )
 spr(
 202,logo_x,logo_y,6,2
 )
 
 local brs = 66
 
  if ticker >= 370 then
    brs = 68
  else
    brs = 66
  end

 spr(
 66,logo_burger_left_x-1,logo_burger_left_y-6,2,4)
 spr(
 brs,logo_burger_right_x,logo_burger_right_y-6,2,4)

end

function draw_instructions()

 map(32,0,0,0,16,16)
 draw_burger_rain_small(burger)

print(string.instructions, 48,20,11)

print(string.inst_1, 15,46,7)

end

function draw_window()

 spr(180,48,48,1,1,false,false)
 spr(180,72,48,1,1,true,false)
 
 spr(181,48,40,1,1,true)
 spr(181,72,40,1,1,false)
 
 spr(174,56,40,1,1,true) 
 spr(174,64,40,1,1,false)
   
 for i=0,4 do
   spr(182,(8)*8,i*8,1,1,false)
   spr(182,(7)*8,i*8,1,1,true)
 end
 
 spr(175,56,48,1,1,false)
 spr(175,64,48,1,1,false)
 

end

function draw_burger_rain_small(b)

 for i = 1,3 do

  spr(b.rain_spr[i],b.rain_x[i],b.rain_y[i],b.rain_w[i],b.rain_h[i])
  
 end

end

function draw_burger_rain_big(b)

 for i = 4,#b.rain_x do

  spr(b.rain_spr[i],b.rain_x[i],b.rain_y[i],b.rain_w[i],b.rain_h[i])
  
 end

end

function draw_states()

 
 if     state == 0 then 
  draw_idle()
  
 elseif state == 1 then
  draw_menu()
  draw_menu_position()
  
 elseif state == 2 then
  draw_options()
  draw_options_position()
 
 elseif state == 3 then
  draw_field()
  
  draw_direction_order(player1)
--  draw_direction_order(player2)
  
  draw_cutlery(player1)
  draw_cutlery(player2)
  
  draw_pipe_lower(player1)
  draw_pipe_lower(player2)

  draw_active_burger(player1)
  draw_active_burger(player2)
  
  draw_pipe_upper(player1)
  draw_pipe_upper(player2)
  
  draw_player_stats(player1, 25, 90, 4)
  draw_player_stats(player2, 95, 90, 1)
  
  draw_crunch(player1)
  draw_crunch(player2)
  
  if     player1.streak_display == true then
     draw_streak(player1)
  elseif player2.streak_display == true then
     draw_streak(player2)
  elseif player1.failstreak_display == true then
     draw_failstreak(player1)
  elseif player2.failstreak_display == true then
     draw_failstreak(player2)
  end
  
 if player1.fail then
   draw_fail(player1)
 elseif player2.fail then
   draw_fail(player2)
 elseif player1.success then
   draw_success(player1)
 elseif player2.success then
   draw_success(player2)
 end
  
 if     player1.eaten then
   draw_eaten(player1)
 elseif player2.eaten then
   draw_eaten(player2)   
 end
  
 elseif state == 4 then
 draw_game_over()
 
 elseif state == 5 then
  draw_field()
  
  draw_direction_order(player1)
  draw_direction_order(ai)
  
  draw_cutlery(player1)
  draw_cutlery(ai)
  
  draw_pipe_lower(player1)
  draw_pipe_lower(ai)
  
  draw_active_burger(player1)
  draw_active_burger(ai)
  
  draw_pipe_upper(player1)
  draw_pipe_upper(ai)
  
  draw_player_stats(player1, 25, 90, 4)
  draw_player_stats(ai, 95, 90, 1)
  
  draw_crunch(player1)
  draw_crunch(ai)
  
  if     player1.streak_display == true then
     draw_streak(player1)
  elseif ai.streak_display == true then
     draw_streak(ai)
  elseif player1.failstreak_display == true then
     draw_failstreak(player1)
  elseif ai.failstreak_display == true then
     draw_failstreak(ai)
  end
  
 if player1.fail then
   draw_fail(player1)
 elseif ai.fail then
   draw_fail(ai)
 elseif player1.success then
   draw_success(player1)
 elseif ai.success then
   draw_success(ai)
 end
  
 if     player1.eaten then
   draw_eaten(player1)
 elseif ai.eaten then
   draw_eaten(ai)   
 end
  
 elseif state == 6 then
  draw_controls()
  
 elseif state == 7 then
  draw_instructions()
  
 elseif state == 8 then
  draw_credits()
  
 end
end
-->8
-- helper functions
function debug()

 if btnp (4) and btn(5) then
--   state = 1
 end

end

function draw_debug()

-- print(intro_ticker, 0, 0, 7)
-- print(is_music, 0, 8, 7)
-- print(teststring, 0, 16, 7)
-- print(ai.difficulty, 0, 24, 7)
-- print(order_pos, 0, 24, 7)
-- print(1/intro.d, 0, 32, 7)

-- if btnp(4) then
--  player1.burger.anim_index += 1
--     
--     if player1.burger.anim_index > #burger.frames[burger.order[1]] then
--      player1.burger.anim_index = 1
--     end
-- end


end
-->8
--textbloecke

function language()

 if lang_id == 0 then		 		-- englisch
 
    string = {
   
    idle = "press x to start",
    vs_player = "duel",
    vs_ai = "vs ai",
    
    settings = "settings",
    burger_count = "burger count: < ",
    interval = "interval: < ",
    vegan_mode = "vegan mode: ",
    off = "off ",
    on = "on ",
    ai_difficulty = "ai-crux:",
    difficulty = "difficulty",
    very_easy = "very easy",
    easy = "easy",
    medium = "medium",
    hard = "hard",
    very_hard = "very hard",
    language = "language: ",
    credits = "credits",
    back = "back",
    player1 = "player 1",
    player2 = "player 2",
    ai = "cpu",
    tie = "jesus",
    default = "god",
    wins = " wins",
    loses = " loses",
    continue = "press — to continue",
    
    instructions = "instructions",
    inst_1 = "press the shown direction\n to eat your burger.\n\norder the next one \n when the plate is empty.\n\n\ngetting a streak without any\n errors will decrease\n the stocked burgers\n additionally.",
    
    controls = "controls",
    p1_up = "”",
    p1_sides = "‹  ‘",
    p1_down = "ƒ",
    p1_reload = " x or 8",
    
    p2_up = "e",
    p2_sides = "s   f",
    p2_down = "d",
    p2_reload = "l shift",
    eat_descr1 = "press displayed direction",
    eat_descr2 = "to eat",
    
    reload_descr1 = "press if plate is empty",
    reload_descr2 = "to request new burger",
        
    streak = {
    "yay!",
    "killing\n spree",
    "om nom nom",
    "junk\nfood\nfirst!",
    "jackpot!",
    "noice!"
    									},
    failstreak = {
    "loser",
    "zero points!",
    "n00b",
    "come on!",
    "you suck!",
    "saturated?", 
    									} 
    									
    }
    
 elseif lang_id == 1 then -- deutsch
   
    string = {
    
    idle = "druecke x zum starten",
    vs_player = "duell",
    vs_ai = "gegen ki",
    
    settings = "optionen",
    burger_count = "anzahl burger: < ",
    interval = "intervall: < ",
    vegan_mode = "veganer-modus: ",
    off = "aus",
    on = "an",
    ai_difficulty = "ki-hunger:",
    difficulty = "schwierigkeit",
    very_easy = "topmodel",
    easy = "kleinkind",
    medium = "normalo",
    hard = "'murica!",
    very_hard = "aethiopier",
    language = "sprache: ",
    credits = "credits",
    back = "zurueck",
    player1 = "spieler 1",
    player2 = "spieler 2",
    ai = "cpu",
    tie = "jesus",
    default = "gott",
    wins = " gewinnt",
    loses = " verliert",
    continue = "druecke —,\n um fortzufahren",
    
    instructions = "spielziel",
    inst_1 = "druecke die angezeigte richtung,\n um zu essen.\n\nbestelle nach,\n wenn der teller leer ist.\n\n\nstreaks ohne fehler\n senken den vorrat\n zusaetzlich.",
    
    controls = "steuerung",
    p1_up = "”",
    p1_sides = "‹  ‘",
    p1_down = "ƒ",
    p1_reload = "x oder 8",
    
    p2_up = "e",
    p2_sides = "s   f",
    p2_down = "d",
    p2_reload = "l shift",
    
    eat_descr1 = "druecke angezeigte richtung,",
    eat_descr2 = "um zu essen",
    
    reload_descr1 = "bei leerem teller druecken,",
    reload_descr2 = "um neuen burger anzufordern",
        
    streak = {
    "yay!",
    "monsterkill",
    "om nom nom",
    "gegen\ngesunde\nernaehrung",
    "jackpot!",
    "mahlzeit!"
    									},
    failstreak = {
    "loser",
    "null punkte",
    "lappen!",
    "gib dir muehe!",
    "versager!",
    "schon satt?"   
    									}    									
    }
 end
 
end
-->8
-- ai functions

function ai_functions(ai)

 update_ai(ai)
 ai_difficulty(ai)
 
end

function ai_difficulty(a)

 if     a.difficulty == 0 then
   a.eat_delay = order_delay*0.5
   a.failchance = 4
   a.cooldown = order_delay*0.5
 elseif a.difficulty == 1 then
   a.eat_delay = order_delay*0.4
   a.failchance = 3
   a.cooldown = order_delay*0.4
 elseif a.difficulty == 2 then
   a.eat_delay = order_delay*0.2
   a.failchance = 3
   a.cooldown = order_delay*0.25
 elseif a.difficulty == 3 then
   a.eat_delay = order_delay*0.2
   a.failchance = 2
   a.cooldown = order_delay*0.2
 elseif a.difficulty == 4 then
   a.eat_delay = order_delay*0.2
   a.failchance = 1
   a.cooldown = order_delay*0.1
 end

end

function ai_action(p)
 if  not freeze 
 and not p.burger.fall then
    if p.burger.anim_index < player1.active_anim then
     if ai_score(p.failchance) then
      if flr(ticker%ai.eat_delay) == 0
  		  then
  		    ai_eat(p)
      end   
     elseif not ai_score(p.failchance) then
   	  if ticker%ai.eat_delay == 0
   	  then
        ai_eat_fail(p)
      end
     end
    elseif p.burger.anim_index == player1.active_anim then
     if ticker%ai.eat_delay == 0 and p.action_timer == 0
     then
       plate_shake(player1,0)
       plate_shake(player2,1)
       sfx(p.empty_sound)
     end
    end
 end
end



function update_ai(a)
 
 a.burger.y += a.burger.fall_speed/2
 ai.active_anim = #burger.frames[burger.order[player1.burger.order_pos]]
  
 update_streak(a)
 update_failstreak(a)

 fall_crumble(a)
 
 if   a.burger.anim_index == a.active_anim-1 then
      a.burger.crumble_extra = 5*a.active_anim
 else a.burger.crumble_extra = 0
 end
 
    if a.active_anim != a.burger.anim_index then
     if a.active_anim == 8 then
      a.burger.h = 4
      a.burger.gap = 25
     end
    else
     a.burger.h = 2
     a.burger.gap = 9
    end

end


function ai_serve(p)
 
 if ticker%order_delay == 0 and p.burger.anim_index == #burger.frames[burger.order[p.burger.order_pos]] or
    ticker%order_delay == 0 and p.burger.anim_index == #burger.frames[burger.order[p.burger.order_pos]] then
   p.burger.order_pos+=1
    if p.burger.order_pos > #burger.order then
         p.burger.order_pos = #burger.order
    end  
   
   p.burger.remaining -=1
   p.burger.anim_index = 1
   p.burger.y = -5
   p.burger.state = 0
   p.burger.fall = true
   p.eaten = false
   p.crunch = {}
 
 end 

end

function ai_score(a)

 local quote = ceil(rnd(9)) 
  if quote <= a then
   return false
  else
   return true
  end

end

function ai_eat(p)

            -- test: warum werden aus d und dt dezimalzahlen, auch nach dem runden?!
 local d = p.cooldown
-- local dt = 0
   p.delay_timer += 1
--    if ceil(d) == ceil(dt) then
    if p.delay_timer >= d
    then--         dt = 0
         teststring = p.delay_timer

         p.burger.anim_index+=1
         crunch(p)
         p.streak+=1
         p.failstreak=0
         freeze = true
         p.success  = true
         p.fail  = false
         p.action_timer = 0
         sfx(0)
         p.delay_timer = 0
    end
end

function ai_eat_fail(p)
  					  
       p.streak = 0
       p.failstreak  += 1
       p.fail  = true
       p.success  = false
       p.action_timer = 0
       sfx(p.fail_sound)
end
-->8
-- credits


function credits()

 burger_rain_small(burger)
 if btnp(4) or btnp(5) then
  state = 2
 end  

 if lang_id == 0 then		 		-- englisch
   
    credits_strings = {
    
    title = "credits",
    l1 = "graphic design:\n clemens rieck",
    l2 = "marketing:\n nils huebner",
    l3 = "programming:\n sebastian schaffrath"  									
    }
    
 elseif lang_id == 1 then -- deutsch
   
    credits_strings = {
    
    title = "credits",
    l1 = "grafikdesign:\n clemens rieck",
    l2 = "vermarktung:\n nils huebner",
    l3 = "programmierung:\n sebastian schaffrath"  									 									
    }
 end
 
end
__gfx__
00000000002444444244420000244442000000000000000000000000000000000000000000000000000000001022442000000000000000000000000000000000
00000000024499944444422002449992000000000000000000000000000000000000000000000000000000008124992000000000000000000000000000000000
00700700244999994444242224499992200000000000000000000000000000000000000000000000000000008829992000000000000000000000000000000000
00077000242499944944442224249992200000000000000000000000000000000000000000000000000000002882992000000000000000000000000000000000
00077000244444444444442224444442220000000000000000200000000000000000000000000000000000001221444200000000000000000000000000000000
00700700224444444444422222444444222000000000000002200000000000000000000000000000000000001112444200000000000000000000000000004200
00000000b222222222222223b2222222222200000000000222320000000000000000000000000000000000002222222220000000000000000000000000002200
0000000033bb33353b33bb3333bb33353b222200000022223b22222000000200000000000000000000000000288ee8e828800000000000000000000000000002
0000000032333555335533323233355533322222222222222252222222222220000000000000000000000000228822b322880000000000000000000000000000
00000000225555555555552822555555555225282222255555552222222222200000000000000000000000003bb33b322382000022333b300000000000000000
0000000082255555555552288225555555552228822555555552222882555552000000000000000000000000233223222283200023b353530000000000000000
00000000882222828222228288222282822222828822228282222228882222820000000000000000000000002222555522822220222555500000000000000000
00000000288ee88228e88822288ee88228e88822288ee88228e82282288ee8822000000000000000000000002422222222824422222222220000000040000000
00000000224999944444442222499994422242222249999444888822224999922200000000004200000000002244994442824222222499422000000000000000
00000000022444444444422002244444442222200224444444222220022444424220000000002200002000000224444442882220022244442288200009a99200
0000000000024444444420000002444442222000000244444222200000024422242220000000000020000000000222222288800000022222288880009a999920
00244444444422000024444200000000000000000000000000000000000000001022444444422201000000000000000000000000000000000000000000000000
02449994444442200244999200000000000000000000000000000000000000008124999444442218000000000000000000000000000000000000000000000000
24499999444444222449999200000000000000000000000000000000000000008829999944444288000000000000000000000000000000000000000000000000
24449994494444222444999200000000000000000000000000000000000000002882999449442882000000000000000000000000000000000000000000000000
24444444444444222444444400000000000000000000000000000000000000001221444444441221000000000000000000000000000000000000000000000000
22444444444442222244444420000000000000000000000000000000000000001112444444222111000000000000000000000000000000000000000000000000
92222222222222299222222220000000000000000000000000000000000000002222222222888222000000022000000000002444444200000000244200000000
99aaaa999999999999aaaa999220000000000000222000000000000000000000288ee8e888ee8820000000e82880000000024999424420000002499420000000
9939aaaaa99a93999939aaaaa992200000000029a99220000000000000000000228822bb22882232000022bb2288000000244999444442000024499420000000
23bbb399993a932223bbb39999999200000029999999920000002992000000003bb33bb3338bbb3222333b33b382000000244444442442000024444220000000
22333332233a322222333332299a222222223332299a22222222333200000000233223223283332023b353555283200000224444444422000022444222000000
22222222299a222222222222229a22222333b222229a22222233b222200000002222555522822222222555555282222003b3222222223b0003b3225552200000
299aaaa999a99922299aaaa999a99922223b2aa999a99922233b2aa92000000024222222228244222222222222822222003b325555282330003b322555220000
2249992444a944222249992444a942222222992444a9422222229924420000002244994442824222222499444282442200228825888222000022882222222200
0224444444a442200224444444a442200224444444a992200224444449a992000224444442882220022244444288222000244999444442000024499944224200
00024444449420000002444449a9200000024444999a9900000244449a9999200002222222888000000222222288800000022222222220000002222222222000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000004424444442000000442442000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000244999442444220024499942000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002449aa99444424222449aa994000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002424999449444422242499944200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002444444444444422244444444420000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002444444444444222244444444442000000000000244200000000000000000000000000000000000000000000000000000000000000000000
00000000000000003244444444422223324444444442230000000002444223000000000000000000000000000000000000000000000000000000000000000000
0000000033200000b332222222222bb3b332222222222bb30000002222222bb30000000000000000000000000000000000000000000000000000000000000000
00000002888222003bb332233bbbb3333bb332233bbbb333023332233bbbb3330000000000000000000000000000000000000000000000000000000000000000
00000249442242002332222223bbbb322332222223bbbb302332222223bbbb300000000000000000000000000000000000000000000000000000000000000000
00002222222220002225555522233322222555552223332022255555222333200000000000000000000000000000000000000000000000000000000000000000
00000000000000002255555552222222225555555222222222555555522222220000000000000000000000000000000000000000000000000000000000000000
00000000000000000222222222222222022222222222222202222222222222220022222222000000000000000000000000000000000000000000000000000000
00000000000000000829999aaaaaa9200829999aaaaaa9200829999aaaaaa920082299aaa9200000000000000000000000000000000000000000000000000000
0000000000000000822229999aaaa982822229999aaaa982822229999aaaa98282222299aa920000000000022222200000000000000000000000000000000000
00000000000000008822222999aa92828822222999aa92828822222999aa9282882222299a992000000000299a99920000000000000000000000000000000000
00000000000000002228888299992220222888829999222022288882999922202228888299992200000000829999920000000000000000000000000000000000
00000000000000000222228828882522022222882888252202222288288825220222228828882522000002882899252200000000000000000000000000000000
00000000000000000255555522882522025555552288252202555555228825220255555522882522000025552288252200002222000000000000000000000000
00000000000000000225555552282223022555555228222302255555522822230225555552282223000255522228222300225555220000000000000000000000
00000000000000003b222222222822b33b222222222822b33b222222222822b33b222222222822b323322222222822b322222255222220000000000002222000
000000000000000033bb332233b88bb333bb332233b88bb333bb332233b88bb333bb332233b88bb333bb332233b88bb333bb332233b88bb20000000023b88bb2
000000000000000023334444433383322333444443338332233344444333833223334444433383322333444443338332bb334444433883bb00000002233883bb
00000000000000002449a999444844222449a999444844222449a999444844222449a999444844222449a999444844223349a999444843330000002944484333
00000000000000002244999444484422224499944448442222449994444844222244999444484422224499944448442222449994444844220000229444484422
00000000000000000224444494884220022444449488422002244444948842200224444494884220022444449488422002244444948842200024944442884220
00000000000000000002444444842000000244444484200000024444448420000002444444842000000244444484200000024444448820000022444428888200
0000000000000000000000000000000001dd66d6766d6ddddddddd10444441111111111111144444111111111111111144444444124444440000000000000000
0000000000000000000000000000000001d116d676d6dddddddd6110444116666666666666611444112222222222222244444444124444440110000000000110
00000000000000000000000000000000011666d611111111dddddd10441666777777777777666144124444444444444444444444124444440000000000000000
0000000000000000000000000000000001dd6111dddddddd111ddd10416667666666666666766614124444444444444444444444124444440001110001111000
0000000000000000000000000000000001d11ddd766d6dddddd11d10416676666666666666676614124444444444444444444444124444440000000000000000
00000000000000000000000000000000011dd6d676d6ddddddddd110c1667666666666666667661c124444444444444444444444124444441110001111111000
0022444444442200000000000000000001dd66d6766d6ddddddddd10c1766766666666666676671c124444444444444444444444124444441111011111111101
0249999444444220000000000000000001d666d676d6dddddd611d107d17766666666666666771d7124444444444444444444444124444441111011111111101
24499994444444220000000000000000011d66d6766d6dddddddd1107cd117777777777777711dc7124444444444444444444421444444441111011111111101
2444444444444422000000000000000001dd66667666666666dddd10c77dd11111111111111dd77c124444444444444444444421444444441110000000000000
2244444444444222000000000000000001d666111111111111666d10277cc66dd66dd66dd66cc772129994444444499944444421999999991111111111100011
28bbb333b3bbb382000000000000000001611100000000000011161042277cc77cc77cc77cc77224199999999999999944444421999999991111111111110111
3bb8828889aaa933000000028200000001100000000000000000011044422cc77cc77cc77cc22444199999999999999944444421999999990011110000110000
22222222229a922200000222220000000100000000000000000000104444422cc77cc77cc2244444199999999999999944444421999999991111111111111111
2449a994444a44420002a9944420000000000000000000000000000044444442277cc77224444444114444444444444444444421444444441111111111111111
02222222222922200022222222220000000000000000000000000000444444444227722444444444111222222222222244444421222222221111111111111111
00000000000000004415124441515151000000000000000000000000412121214412124444444444111222222222222222222111444444440000000600000000
0000000000000000441d514441d1d1d100000011111111111100000041d1d1d1441d214444444444111222222222222222222111442244440000000000000000
0000000000000000441dd14441d1d1d100011111111111111111100041d1d1d1441dd14444444444111222222222222222222111428824440000000000000000
0000000000000000441dd14441ddddd100111111111111111111110041ddddd1441dd14444444444111222222222222222222111422222440000000000000000
0000000000000000441dd1444211d112001dd11111111111111dd1004211d112441dd14444444444111222222222222222222111444444440000000000000000
0000000000000000441d514444215124000166dddddddddddddd100044212124441d214444999444111222222222222222222111444444440000000000000000
0022444200000000441331477413314400001166766ddddddd110000741221444412214749444944111222222222222222222111444444440000000077777777
0249999200000000441b31777713b144000000111111111111000000771281444418217744999444111222222222222222222111444444440000000011111111
2449999200000000441bb177771bb144170000001111111100000071771881444418817744444444111224444444444444444444444444214442211111111111
2444444420000000441bb127721bb144170000007777611100000071721881444418812742244444111244444444444444444444444444214444211122222211
2244444420000000441bb142241bb144170000000000061100000071241881444418814244444224111244444444444444444444444999214444211144444421
28bbb333b0000000441b31444413b144170000000000006100000071441281444418214444444444111244994222222499999999999999919944211144444421
3bb8828882000000441331444413314416000000000000710000007144122144441221444444444411124999249aa94299999999999999919994211144444421
22222222220000004411124444211144116000000000007100000071442111444411124444444444111249992449944299999999999999919994211144444421
2449a994442000004422244444422244111677770000007100000071444222444422244444444444111224992244442299999999444444119942211144444421
02222222222220004444444444444444111111110000007100000071444444444444444444444444111222222222222222222222222221112222211144444421
00000000000000000000000000000000002222222220000000222222222000000022222222200000277777722777222772777777222277777277777e77777722
000000000249442002494420000000000233333333322100023333333332200002333333333220002777ee77277722277e777ee7722777777e777777777ee772
00700700249a9442249a9442002422002333333bbbb331002333333bbbb332002333333bbbb33200277722e7e77722277777722e7e777eee77777eee77722e7e
000770003bbb33582dd6d55202499420233333bbbbab1c10233333bbbbbbb320233333bbbbbbb320277722277777222777777222777772227777722277722277
000770002333588225dd6d520258b320223333bbbbb176c1223333bbbbbbab20223333bbbbbbab20277722277777222777777222777772227777722277722277
007007002499944224992442024944200222333bbbb16cc10222333bbbbbbb200222333bbbbbbb2027772277e777222777777227777772227777777777722777
00000000024444200244d42000242200002fffffffff1c10002effffffffb320002effffffffb3202777777e2777222777777777e277722222777777777777e2
00000000000000000000000000000000002eefffeeef37f200233fff333f37f200211fff333f37f2277777722777222777777777227772222277777777777722
1100001100011000000110000000000000211fff333f7ef200211fff111f7ef200271fff771f7ef22777ee772777222777777e77e27772e777777eee777e77e2
1210012100161000000161000000000002ec1eff7c1ffef202feeffffffffef202ec1eff7c1ffef2277722e7e777222777777277727772e77777722277727772
0121121001661111111166100000000002ffe27fffffff2002ffe27fffffff2002ffe27fffffff20277722277777222777777277727772227777722277727772
0018810016666666666666610000000002fffffffffff20002ff222222fff20002fffffffffff200277722277e77e2e77e7772e77e777222777777777772e77e
0018810027777777777777720000000002ff2efee2fff20002ff2e7762fff20002ff2efee2fff20027772277e2e77777e277722777e777777777777777722777
01211210027722222222772000000000002fff77ffff2000002ff2ee2fff2000002fff77ffff20002777777e212e777e22777227772e77777e77777e77722777
1210012100272000000272000000000000022fffff22000000022f77ff22000000022fffff2200002eeeeee21112eee212eee22eee12eeeee2eeeee2eee22eee
11000011000220000002200000000000000002222200000000000222220000000000022222000000222222211111222111222112221122222222222222211222
00000011000120000017720022222222222222222222222222222222011111000022222222200000082228028882028888028888028882028880888821888820
0000013100177200001772002222222222222222222222222222222214aaa4100233333333322000088288088888088888088888088888088820881881888820
100013310177762000177200222222222222221111122221222222221aaaaa102333333bbbb33200088888088188088210088210088188088220881880882100
3101331017776662111772222222221111111111122221112222222219aaa910233333bbbbbbb320088888088888088888088888088888088120882880888820
3b1b310011176222177776621111111112222211111111112222222219999910223333bbbbbbab20088288088288088888088888088288088100888810888820
1bab1000001762000177662011122221111222211111122122222222199999100222333bbbbbbb20088188088188001288001288088188088000882800882100
01b100000017620000176200112222111111111111111111222222221499941000211fff333fb320082182082182088888088888088082088880821820888820
0010000000176200000120001111111111111111111111112222222201999100002c1fff7c1f37f2022022022022082882088882082022028880221220228220
001441002222222211111111111111111111111112112222222211210199910000271fff771f7ef2022021021022022222022122022021022120221210222210
001aa1002222222211111111111111111122111111222222222222110144410002ec1eff7c1ffef2012010021012012212012012012011011110121110122110
001aa1002222222211111111111111111111111111111111111111110011100002fee27ffeeeff20011010011011011201011011001001011010010100112010
001991002222222211111111111221111111111111112222222211110011100002fffffffffff200001000010001001100001001001000001000010000011000
00199100222211221111111111111111111111111111112222111111019a910002fff22ffffff200001000000000001100000000000000001000000000010000
001111002121221211111111111111111111111111111222222111110199910002effee2fffff200000000000000000100000000000000000000000000000000
0019910022212212111111111111111111111111111111111111111101444100002eff22ffff2000000000000000000000000000000000000000000000000000
001441002222112211111111111111111111111111111122221111110011100000022f77ff220000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000
__map__
e6e6f1e6e6e6e6d3d3e6e6e6f1e6e6e600000000000000000000000000000000d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6f6f2f2f2f5f1d3d3f1f6f2f2f2f5e600000000000000000000000000000000d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d300000000000000000000d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6f6f2f2f4f5e6d3d3e6f6f2f2f2f5e600000000000000000000000000000000d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e6f6f2f2f2f5e6d3d3e6f6f2f2f4f5f100000000000000000000000000000000d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e4f2f2f2f2f2e5d3d3e5f2f2f2f2f2e300000000000000000000000000000000d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f39ef2f2f2f2d3d3d3d3f2f2f2f29ff400000000000000000000000000000000d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9f9ef2f2f29ed3d3d3d39f9ef2f2f29e000000000000000000000000000000008f8e8f8e8e8f8e8f8f8e8f8e8e8f8f8e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8a8b8b8b8b8b8b8b8b8b8b8b8b8b8bbf000000000000000000000000000000009e9e9f9f9e9e9e9e9f9f9e9e9e9f9e9e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8d8c8c8c8c8c8c8c8c8c8c8c8c8cad9c00000000000000000000000000000000f29e9e9ef2f2f2f29e9ef2f2f29e9ef20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8d8c8c8c8c8c8ca98c8c8c8c8c8c8c9c00000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8d8c8c8c8c8c8c8c8cad8c8c8c8c8c9c00000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8da98cb9ad8ca98c8c8ca98cb9a98c9c00000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9a9dbcbc9d9b9d9d9b9d9b9d9d9dbcbd00000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f2f2aaabf1abf1ababf1ababf1acf2f200000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f2f2babbbcbcbcbcbcbcbcbcbbbef29e00000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9ff2f2e4e3e5e4e3e5e4e3e4e5f29f9f00000000000000000000000000000000f2f2f2f2f2f2f2f2f2f2f2f2f2f2f2f20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000200c033000000c03300000246250000024625000000c033000000000000000246250000024600000000c033000000c03300000246250000024625000000c03300000000000000024625000002460000000
011000202313025100271322713223132251002713025100281302710027130271002713026100251302310023130251002713227132231322510027130251002813027100271302710027132271322713023100
011000000412004110041200411004120041100412004110051200511005120051100512005110051200511004120041100412004110041200411004120041100512005110051200511005120051100512005110
001000202313027100271302713023132251002713025100281302713027130271002713026100251302610027130291002a1302b1002a100291002a100291002710018100191001810018100001000010000100
001000002313021100231322113223132251002713027130281302710027130251302713026100251302513027130221002313023100231300000000000000000000000000000000000000000000000000000000
000100001b6501d6502065023650246502665027650276502765024650206501c650176501565013650106500d6500a6500865005650026500165001650016500165001650016500165001650016500165001650
000100001a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a0501a050
000100001225012250122501225012250122501225012250122501225012250122501225012250122501225012250122501225012250122501225012250122501225012250122501225012250122501225012250
000800000b3500b3500b35010350163501b3501b3501b3501b3501b350293002b3002e300303003330036300003003c3003f3003f300003000030000300003000030000300003000030000300003000030000300
000800000b1500b1500b15010150161501b1501b1501b1501b1501b150291002b1002e100301003310036100001003c1003f1003f100001000010000100001000010000100001000010000100001000010000100
000800002225022250222002225022250222502225022250222502225022250222502f2002d2002a2002720024200222002120000200002000020000200002000020000200002000020000200002000020000200
0002000000100001000a1500e150111501415018150191501a1501b1501b150181501715013150131501015008150011500010000100001000010000100001000010000100001000010000100001000010000100
0002000000000000000a0500e050110501405018050190501a0501b0501b050180501705013050130501005008050010500000000000000000000000000000000000000000000000000000000000000000000000
00080000146500d65007650026500165016600136000f6000c6000960007600056000360001600016000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000200001f6501b6501765014650116500e6500965006650036500165005600016000160003600140000e00004000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 00 01 02 44
00 00 02 03 44
00 00 02 03 44
02 00 02 04 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
