pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--imi's dungeon
--biolardi "vsio neithr" yoshogi
--twitter.com/vsios

// config
_config={
 start_level=1,
 is_debug_level=false,
 state_after_boot="title",
 is_sfx_muted=false,
 is_bgm_muted=false,
 version="v1.0",
 cartname="neithr_imisdungeon_1",
 is_reset_data=false
}

//
_service_locator=nil
_state_manager=nil
_level_manager=nil
_entity_manager=nil
_value_storer=nil
_data_storer=nil
_player_settings={}

function init_value_storer()
 local value_storer=_service_locator:get_service(value_storer)
 _value_storer=value_storer
 local data_storer=_data_storer
 
 value_storer:set_value("start_level",_config.start_level)
 value_storer:set_value("version",_config.version)
 value_storer:set_value("highest_level",data_storer:load("highest_level"))
 value_storer:set_value("is_game_finished",data_storer:load("is_game_finished")==1)
end

function init_data_storer()
 local data_storer=_service_locator:get_service(data_storer)
 _data_storer=data_storer
 data_storer:set_cartname(_config.cartname)
 
 data_storer:register(0,"highest_level")
 data_storer:register(1,"is_game_finished")
 
 if(data_storer:load("highest_level")==0)then
  data_storer:save("highest_level",1)
 end 
end

function init_reset_data()
 local data_storer=_service_locator:get_service(data_storer)
 
 data_storer:save("highest_level",1)
 data_storer:save("is_game_finished",0)
end


function init_service_locator()
 _service_locator=sl:new()
end

function init_sounds()
 local sound_mgr=_service_locator:get_service(sound_manager)
 local sound_regist=function(a,b)sound_mgr:register(a,b)end
 sound_mgr:set_mute(_config.is_sfx_muted)
 
 sound_regist("stair",0) 
 sound_regist("hole",1)
 sound_regist("walk",2)
 sound_regist("unlock",3)
 sound_regist("arrow",4)
 sound_regist("ui",6)
end

function init_musics()
 local music_mgr=_service_locator:get_service(music_manager)
 local music_regist=function(a,b)music_mgr:register(a,b)end 
 music_mgr:set_mute(_config.is_bgm_muted)
  
 music_regist("intro",4) 
 music_regist("flor1",5) 
end

function init_levels()
 _level_manager=_service_locator:get_service(level_manager)
 local add_level=function(a,b,c,d,e,f)_level_manager:add_level(a,b,c,d,e,f)end
 
 if (_config.is_debug_level)then
  add_level(1,1,13,11,8,16)
 else
  //_config.start_level=1
  
  //01
  add_level(15,1,25,7,20,24)
  add_level(27,1,37,8,20,30)
  add_level(39,1,48,10,24,24)
  add_level(50,1,60,10,20,20)
  add_level(62,1,72,11,20,20)
  
  //05
  add_level(74,1,84,7,20,32)  
  add_level(86,1,95,10,24,24)
  add_level(97,1,107,11,16,24)
  add_level(109,1,119,11,16,24)
  add_level(121,1,127,11,36,24)
  
  //10
  add_level(1,13,8,23,28,24)
  add_level(10,13,20,19,20,32)
  add_level(22,13,30,23,24,20)
  add_level(15,8,29,11,4,48)
  add_level(32,11,44,20,12,24)
  
  //15
  add_level(46,12,56,20,18,24)
  add_level(58,12,69,18,18,32)  
  add_level(71,12,81,22,18,20)  
  add_level(83,12,91,22,28,20)
  add_level(93,12,103,22,20,20)
  
  //20
  add_level(105,13,114,19,24,28) 
  add_level(116,13,126,20,24,28)    
  add_level(0,25,15,34,0,24)    
  add_level(17,25,25,36,28,16)  
  add_level(27,25,36,37,24,14)
  
  //25
  add_level(38,22,44,28,40,32)
  add_level(38,30,45,37,32,32)
  add_level(46,22,58,28,12,32)
  add_level(60,20,70,30,20,20)
  add_level(72,24,85,36,8,16)
  
  //30
  add_level(87,24,95,34,24,20)
  add_level(97,24,105,34,28,20)
  add_level(107,21,119,32,12,16)
  add_level(120,22,127,31,24,20)
  add_level(1,36,15,47,4,16)
  
  //35
  add_level(17,38,29,46,12,30)  
  add_level(31,38,45,45,4,24)
  add_level(47,30,58,40,16,20)
  add_level(60,32,70,42,20,20)  
  add_level(72,37,86,46,4,24)
  
  //40
  add_level(88,36,100,43,12,32)
  add_level(102,36,112,46,20,20)  
  add_level(114,34,127,41,8,30)  
  add_level(1,48,7,60,36,14)  
  add_level(9,49,21,59,12,20)
  
  //45
  add_level(23,48,32,59,24,18)
  add_level(34,47,46,58,12,16)
  add_level(48,42,58,53,18,16)
  add_level(60,44,70,55,18,16)
  add_level(72,48,84,59,12,16)
 end
end

function init_players()
 local player_1_sprites={}
 player_1_sprites["up"]={49,50,49,51}
 player_1_sprites["down"]={1,2,1,3}
 player_1_sprites["left"]={17,18,17,19}
 player_1_sprites["right"]={33,34,33,35}
 
 local player_2_sprites={}
 player_2_sprites["up"]={52,53,52,54}
 player_2_sprites["down"]={4,5,4,6}
 player_2_sprites["left"]={20,21,20,22}
 player_2_sprites["right"]={36,37,36,38}
  
 add(_player_settings,{sprites=player_1_sprites,cur_spr_name="down"})
 add(_player_settings,{sprites=player_2_sprites,cur_spr_name="down"})
end

function init_entities()
 _entity_manager=_service_locator:get_service(entity_manager)
 local reg_e=function(a,b,c)_entity_manager:register(a,b,c) end
 
 init_players()
 
 reg_e(1,player_te,_player_settings[1])
 reg_e(4,player_te,_player_settings[2])
 reg_e(11,goal_te)
 reg_e(12,hole_te)
 reg_e(26,hole_te,{cur_spr_name="cracked"})
 
 reg_e(13,arrow_te,{cur_spr_name="up"})
 reg_e(29,arrow_te,{cur_spr_name="down"})
 reg_e(45,arrow_te,{cur_spr_name="left"})
 reg_e(61,arrow_te,{cur_spr_name="right"})
 
 reg_e(42,key_te,{cur_spr_name="copper"})
 reg_e(58,key_te,{cur_spr_name="silver"})
end

function init_states()
 local sl=_service_locator
 _state_manager = sl:get_service(state_manager)
 _state_manager:set_service_locator(sl)
 
 _state_manager:add_state("title",title_state)
 _state_manager:add_state("gameplay",gameplay_state)
 _state_manager:add_state("gallery",gallery_state) 
 _state_manager:add_state("end",end_state)
 _state_manager:add_state("credit",credit_state)
 
 //_state_manager:change_state_to("end",false)
 
 _state_manager:change_state_to("title",false)
end

--

function init_extra_menu_items()
 local sound_mgr=_service_locator:get_service(sound_manager)
 local music_mgr=_service_locator:get_service(music_manager)

 menuitem(1,"un/mute sfx",function()
  _config.is_sfx_muted=not _config.is_sfx_muted
  sound_mgr:set_mute(_config.is_sfx_muted)
 end)
 
 menuitem(2,"un/mute music",function()
  _config.is_bgm_muted=not _config.is_bgm_muted
  music_mgr:set_mute(_config.is_bgm_muted) 
 end)
 
 menuitem(3,"delete progress",function()
  init_reset_data()
  run()
 end)  
end

function _init()
 init_service_locator() 
 init_sounds()
 init_musics()
 init_levels()
 init_entities()
 init_data_storer()
 
 if(_config.is_reset_data)then
  init_reset_data()
 end
 
 init_value_storer()
 
 init_extra_menu_items()
 
 init_states()  
end

function _update()
 if (_state_manager != nil) then
  _state_manager:update()
 end
end

function _draw()
 cls()
 rect(0,0,127,127,2)
 
 if (_state_manager != nil) then
  _state_manager:draw()
 end
end

-->8
-- states

-- state prototype

state={}

function state:new(o)
 self.__index = self
 o=o or {}
 m=setmetatable(o, self)
 o.is_active=false
 
 o:init()
  
 return m
end

function state:init()
 self.sl=nil or self.sl
 self.input_cooldown=10
 
 self:init_services()
end

function state:init_services()
 if (self.sl==nil)return false

 self.value_storer=self.sl:get_service(value_storer)
 self.sound_manager=self.sl:get_service(sound_manager)
 self.music_manager=self.sl:get_service(music_manager)
 self.state_manager=self.sl:get_service(state_manager)
 
 return true
end

function state:change_state_to(name,is_transition)
 self.state_manager:change_state_to(name,is_transition)
end

function state:play_sfx(name)
 self.sound_manager:play(name)
end

function state:play_music(name)
 self.music_manager:play(name)
end

function state:cooldown_input(timer)
 self.input_cooldown=timer or 5
end

function state:update()
 
end

function state:update_input()
 if (self.input_cooldown>0) self.input_cooldown-=1  
 if (self.input_cooldown>0) return true

 return false
end

function state:draw()

end

function state:destroy()
 
end

-- state manager

state_manager={
 name="state_manager"
}

function state_manager:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self) 
 o:init()
 
 return m
end

function state_manager:init()
 self.current_state=nil
 self.states={}
 self.sl=nil
 self.transition=nil
end

function state_manager:set_service_locator(sl)
 self.sl=sl
end

function state_manager:add_state(name, new_state)
 self.states[name]=new_state
end

function state_manager:change_state_to(name,is_transition)
 if(self.current_state!=nil)then
  self.current_state:destroy()
 end
 
 if(is_transition==nil)is_transition=true
 if(is_transition)then
  if(self.transition==nil)then
   self.transition=transition:new()
  end
  
  self.transition:start(function()
   self.current_state=self.states[name]:new({sl=self.sl})
   
   self.transition:start(nil,true)
   
  end,false)
  
 else
  self.current_state=self.states[name]:new({sl=self.sl})
 end 
end

function state_manager:draw()
 if (self.current_state!=nil)self.current_state:draw()
  
 if (self.transition!=nil)self.transition:draw() 
end

function state_manager:update()
 if (self.transition!=nil)then 
  self.transition:update()
  if (not self.transition.is_paused) return
 end
 
 if (self.current_state!=nil)self.current_state:update() 
end

-- title state

title_state=state:new()

function title_state:init()
 self.menu=nil
 self.menu_texts=nil
 
 state.init(self)

 self.focus=0
 
 self:init_menu()
end

function title_state:init_menu()
 local tmenu=menu:new()
 local ybase=80
 local ydelta=8
  
 tmenu:add("new game",64-8*2,ybase)
 tmenu:add("level select",64-12*2,ybase+ydelta)
 tmenu:add("gallery",64-7*2,ybase+ydelta*2)
  
 self.menu=tmenu
 self.menu_texts=tmenu:get_elements()
end

function title_state:init_services()
 if (not state.init_services(self)) return false

 self.version=self.value_storer:get_value("version")
 self.highest_level=self.value_storer:get_value("highest_level")
 //self.highest_level=50
 
 self.select_level_number=1
 self:play_music("intro")
  
 return true 
end

function title_state:update()
 state.update(self)

 self:update_input()
end

function title_state:update_input()
 if (state.update_input(self)) return true

 if (btn(0)) then
  if (self.focus==1)then
   self:change_level_number(true)
   self:play_sfx("ui")
   self:cooldown_input(5)
  end
 elseif (btn(1)) then
  if (self.focus==1)then
   self:change_level_number(false)
   self:play_sfx("ui")
   self:cooldown_input(5)
  end
 elseif (btn(2)) then
  if (self.focus==0)then
   self.menu:decrease()
   self:play_sfx("ui")
   self:cooldown_input(5)
  end
 elseif (btn(3)) then
  if (self.focus==0)then
   self.menu:increase()
   self:play_sfx("ui")
   self:cooldown_input(5)
  end
 elseif (btn(4)) then
  local index=self.menu:get_index()
  self:play_sfx("ui")
  
  if(index==1)then
   self:new_game()
   self:cooldown_input(5)
   self:change_state_to("gameplay")
  elseif(index==2)then
   if(self.focus==0)then
    self.focus=1
    self:cooldown_input(5)
   elseif(self.focus==1)then
    self:load_level()    
   end   
  elseif(index==3)then
   self:change_state_to("gallery")
  end
 elseif (btn(5)) then
  if(self.focus==1)then
   self.focus=0
   self:cooldown_input(5)
  end
 end
 
 return false
end

function title_state:new_game()
 //local value_storer=_service_locator:get_service(value_storer)

 //value_storer:set_value("start_level", 1)
end

function title_state:load_level()
 local value_storer=_service_locator:get_service(value_storer)

 value_storer:set_value("start_level",self.select_level_number)
 self:change_state_to("gameplay")
end

function title_state:change_level_number(is_left)
 local level_number=self.select_level_number
 
 if(is_left==nil)is_left=true
 
 if(is_left)then
  level_number-=1
  if(level_number==0)then
   level_number=self.highest_level
  end
 else
  level_number+=1
  if(level_number==self.highest_level+1)then
   level_number=1
  end  
 end
 
 self.select_level_number = level_number
end

function title_state:draw()
 
 // title logo
 sspr(0,48,88,16,20,16)
   
 // scene
 sspr(0,32,16,16,48,40,32,32)

 if(self.menu_texts!=nil)then 
  local pos=self.menu_texts[self.menu:get_index()]

  print("->",pos.x-15,pos.y+1,2)  
  print("->",pos.x-15,pos.y,7)
  
  foreach(self.menu_texts,function(el)
  
   if (self.focus==0) then
    print(el.value,el.x,el.y+1,2)
    print(el.value,el.x,el.y,7)   
   elseif (self.focus==1) then
    if(el.value=="level select")then
     local str="‹ level "..self.select_level_number.." ‘"
     local xstr=64-#str*2-4
     
     print(str,xstr,el.y+1,2)
     print(str,xstr,el.y,7)
    else
     print(el.value,el.x,el.y,2)
    end
   end
   
  end)
  
  
 end
 
 print(self.version,105,6,2)
 print(self.version,105,5,7)
 
 local str="(c) 2020 biolardi y./ neithr"
 print(str,64-#str*2,119,2)
 print(str,64-#str*2,118,7)
 
 //print("Ž/z to start",40,96,7)
end

-- gameplay state

gameplay_state=state:new()

function gameplay_state:init()
 self.level_manager=nil
 self.players={}
 self.tile_entities={}
 self.is_player_input=true
 self.active_char=0 // must zero to move again
 self.goal_counter=0
 self.te_evs=nil
 self.focus_turn=0 //0:input player,1:check entity area
 self.main_timer=nil
 self.start_level=1
 
 state.init(self) 
end

function gameplay_state:init_services()
 if (not state.init_services(self)) return false

 self.start_level=self.value_storer:get_value("start_level")
 
 self.data_storer=self.sl:get_service(data_storer)
 
 self.level_manager=self.sl:get_service(level_manager)
 self.entity_manager=self.sl:get_service(entity_manager)
 self:init_te_events()
 self.main_timer=timer_ev:new() 
 self.transition=transition:new()
 
 self:set_level(self.start_level,false)

 return true 
end

function gameplay_state:init_te_events()
 local te_evs=te_ev_manager:new()
 local te_reg=function(a,b)te_evs:register_matched_event(a,b)end

 // matched events

 te_reg({11},function()self:check_goals()end)
 te_reg({12},function(p)
  self:ko_player(p)
  self:play_sfx("hole")
 end)
 
 te_reg({26},function(p,te)
 
  if (te.cur_spr_name=="hole") then
   self:play_sfx("hole")
   self:ko_player(p)   
  end
 end)
  
 local move_p=function(p,x,y)  
  self:move_player(p,x,y)
  self:play_sfx("arrow")
 end
 
 te_reg({13},function(p)move_p(p,nil,-8)end)
 te_reg({29},function(p)move_p(p,nil,8)end)
 te_reg({45},function(p)move_p(p,-8,nil)end)
 te_reg({61},function(p)move_p(p,8,nil)end)
 
 local open_door=function(p,te,door)
  if (not te.is_visible) return
  
  te:set_visible(false)
  self:play_sfx("unlock")
  self:check_level(door,function(cx,cy,spr_index)
   self:open_door(cx,cy,spr_index)
  end)
 end 
 
 te_reg({42},function(p,te)open_door(p,te,41)end)
 te_reg({58},function(p,te)open_door(p,te,57)end)
    
 // end events
    
 local te_end_reg=function(a,b)te_evs:register_end_event(a,b)end
 
 te_end_reg({26},function(p,te)
  if (te.cur_spr_name=="cracked") then
   te:play("hole")
  end
 end)
  
 //
    
 self.te_evs=te_evs
end

function gameplay_state:activate_restart()
 self.active_char=1

 if(self.main_timer:check_is_paused())then
  self.main_timer:activate_timer(function()
   self:set_level()
  end,100)
 end
end

function gameplay_state:check_all_entities()
 local is_matched
 
 foreach(self.players, function(player)
  foreach(self.tile_entities, function(te)
   is_matched = te:check_all_with_entity_pos(player)
  end)
 end)
  
 self:check_end()
end

function gameplay_state:check_end()
 local is_ko=false
 
 if (self.goal_counter>0)self.goal_counter=0
 
 foreach(self.players,function(p)
  if (p.is_ko) then
   is_ko=true
   foreach(self.players,function(p)
    p:set_active(false)
   end)
   return
  end
 end)
 
 if (is_ko) then  
  self:next_turn(2)
 else
  self:next_turn(0)
 end 
end

function gameplay_state:activate_transition(ev,is_transition)
 if(is_transition==nil)is_transition=true

 if(is_transition)then
  self.transition:start(function()
   ev()  
   self.transition:start(nil,true)   
  end,false)
 else
  ev()
 end
end

function gameplay_state:check_level(spr_index,ev)
 local lvl=self.level_manager.cur_level
 
 local ch=lvl.cy+lvl.h
 local cw=lvl.cx+lvl.w
 
 for cy=lvl.cy,ch do
  for cx=lvl.cx,cw do
   if(mget(cx,cy)==spr_index)then
    ev(cx,cy,self.level_manager.replace_spr)
   end
  end
 end  
end

function gameplay_state:open_door(cx,cy,new_spr_index)
 mset(cx,cy,new_spr_index)
end

function gameplay_state:check_goals()
 local target=#self.players

 self.goal_counter+=1
 
 if(self.goal_counter==target)then
  self:next_level()
  self:play_sfx("stair")
 end
end

function gameplay_state:ko_player(p)
 p:kill()
end

function gameplay_state:reset()
 self.entity_manager:reset()
 self.main_timer:stop()
 foreach(self.players,function(p)
  del(self.players,p)
 end)
 
 self.players={}
 self.active_char=0
end

function gameplay_state:next_level()
 if(not self.level_manager:check_end_level())then
  self:activate_transition(function()
   self.level_manager:next_level()
   self:save_level_progress()  
   self:reset() 
   self:init_gameplay()
  end)
 else
  self:change_state_to("end")
  self.value_storer:set_value("is_game_finished",true)
  self.data_storer:save("is_game_finished",1)
 end 
end

function gameplay_state:set_level(number,is_transition)
 if(is_transition==nil)is_transition=true
 local ev=function()
  self:reset()
  self.level_manager:set_level(number or self.level_manager.number)
  self:init_gameplay() 
 end
 
 if(is_transition)then
  self:activate_transition(ev)
 else
  ev()
 end
 
end

function gameplay_state:check_ko()
 
end

function gameplay_state:init_gameplay()
 local data=self.level_manager:scan()

 self:play_music("flor1")
 
 self:create_entities(data)
 self:next_turn(0)
end

function gameplay_state:create_entities(data)
 local entity
 local lv=self.level_manager:get_cur_level()
 local sx=lv.sx
 local sy=lv.sy
 
 //printh(sx..","..sy)

 foreach(data, function(e)
  entity=self.entity_manager:spawn(e.spr_index,(e.cx-1)*8+sx,(e.cy-1)*8+sy)
  
  if (e.spr_index==1 or e.spr_index==4) then
   self:add_player(entity)
   del(self.entity_manager.entities,entity)
  else
   add(self.tile_entities,entity)
   entity:set_matched_event(self.te_evs:get_ev(e.spr_index))
   entity:set_end_event(self.te_evs:get_end_ev(e.spr_index))
  end
  
 end)
 
 //printh("posts")
 //foreach(self.tile_entities,function(e)printh(e.x..","..e.y)end)
 
 //printh(#self.tile_entities)
end

function gameplay_state:save_level_progress()
 if (self.level_manager.number>self.data_storer:load("highest_level"))then
  self.data_storer:save("highest_level",self.level_manager.number)
  self.value_storer:set_value("highest_level",self.level_manager.number)
 end 
end

function gameplay_state:add_player(player)
 add(self.players,player)
 
 player:set_end_move_event(function()
  self.active_char-=1

  player:activate_stepped_te_event()
  
  self:check_player_step_on_te(player)
  
  if (self.active_char==0)then   
   self:next_turn(1)
  end
 end)
 
end

function gameplay_state:next_turn(index)
 self.focus_turn=index
 
 //printh("turn:"..self.focus_turn)

 if (self.focus_turn==0) then // player input
  self.is_player_input=true
 elseif (self.focus_turn==1) then // tile checks
  self:check_all_entities() 
 elseif (self.focus_turn==2) then // game over
  self:activate_restart()
 end
end

function gameplay_state:draw()

 if (self.level_manager!=nil) self.level_manager:draw()
 if (self.entity_manager!=nil) self.entity_manager:draw()
 
 //printh(self.input_cooldown..","..tostr(self.is_player_input)..","..self.active_char)
 
 foreach(self.players,function(p)
  p:draw()
 end)
 
 if (self.transition!=nil)self.transition:draw()
 
 //print(#self.entity_manager.entities,2,24)
 //print(#self.players,4,4)

 //print(self.players[1].sprites["down"],4,4)

 //print(self.players[1].x..","..self.players[1].y,4,4)
end

function gameplay_state:update()
 if (self.transition!=nil)then 
  self.transition:update()
  if (not self.transition.is_paused) return
 end

 state.update(self)
 
 if (self.main_timer!=nil)then
  if (not self.main_timer:check_is_paused())self.main_timer:update()
 end
  
 foreach(self.players, function(p) p:update() end)

 self:update_input()
end

function gameplay_state:update_input()
 if (state.update_input(self)) return true
 
 if (btn(2)) then
  self:move_players(nil,-8)
  self:cooldown_input(5)
 elseif (btn(3)) then
  self:move_players(nil,8)
  self:cooldown_input(5)
 elseif (btn(0)) then
  self:move_players(-8,nil)
  self:cooldown_input(5)
 elseif (btn(1)) then
  self:move_players(8,nil)
  self:cooldown_input(5)
 elseif (btn(5)) then
  self:set_level()
  self:cooldown_input(5)
 end
 
 return false
end

function gameplay_state:move_player(player,x,y)
 x=x or 0
 y=y or 0

 local lv=self.level_manager:get_cur_level()
 local sx=lv.sx
 local sy=lv.sy

 local px=player:get_x()+x
 local py=player:get_y()+y
 local cx=self.level_manager.cur_level.cx
 local cy=self.level_manager.cur_level.cy
  
 local mx=cx+flr((px-sx)/8)
 local my=cy+flr((py-sy)/8)

 if (x!=0) then
  player:set_facing(x>0 and "right" or "left")
 elseif (y!=0) then
  player:set_facing(y>0 and "down" or "up")
 end
 
 if (not fget(mget(mx,my),0)) then
  if (x!=0) then
   player:move_to_x(x)
  elseif (y!=0) then
   player:move_to_y(y)  
  end
     
  self.is_player_input=false     
  self.active_char+=1 
  
  return true
 end
 
 return false
end

function gameplay_state:check_player_step_on_te(player)
 foreach(self.tile_entities,function(te)
  if(te.x==player.x and te.y==player.y) then
   player:set_stepped_te(te)
  end
 end)
end

function gameplay_state:move_players(x_to,y_to)
 if (not self.is_player_input) return
 if (self.active_char>0) return

 local move_count=0

 foreach(self.players,function(player)  
  if (self:move_player(player,x_to,y_to))then
   move_count+=1
  end
 end) 
 
 if (move_count>0)then
  self:play_sfx("walk")
 end
end

-- ending state

end_state=state:new()

function end_state:init()
 state.init(self)
end

function end_state:init_services()
 if (not state.init_services(self)) return false

 self:play_music("intro")
  
 return true 
end

function end_state:update()
 state.update(self)

 self:update_input()
end

function end_state:update_input()
 if (state.update_input(self)) return true

 if (btn(4)) then
  self:change_state_to("credit")
 end
 
 return false
end

function end_state:draw()
 rectfill(0,0,127,12,2)
 rectfill(0,119,127,127,2)
 
 local str="’ congratulation! ’"
 
 print(str,60-#str*2,21,2)
 print(str,60-#str*2,20,7)
 
 local str="„ you completed all levels! „"
 
 print(str,60-#str*2,29,2)
 print(str,60-#str*2,28,7)
   
 local sx,sy=40,40

 sspr(80,32,16,16,sx,sy,48,48)
 rect(sx-1,sy-1,sx+48,sy+48,2) 
 rect(sx-3,sy-3,sx+50,sy+50,2) 
 
 local str="„ you found: „"
 
 print(str,60-#str*2,98,2)
 print(str,60-#str*2,97,7)
 
 local str="’ a ruby of reliability ’"
 
 print(str,60-#str*2,108,2)
 print(str,60-#str*2,107,9)
end

-- credit state

credit_state=state:new()

function credit_state:init()
 state.init(self)
end

function credit_state:update()
 state.update(self)

 self:update_input()
end

function credit_state:update_input()
 if (state.update_input(self)) return true

 if (btn(4)) then
  self:change_state_to("title")
 end
 
 return false
end

function credit_state:draw()
 rectfill(0,0,127,12,2)
 rectfill(0,119,127,127,2)
 
 local ybase=30
 
 local str="(c) 2020 biolardi y./ neithr"
 
 print(str,5,ybase,2)
 print(str,5,ybase,7) 
 
 local str="coder,level designer,artist,"
 
 print(str,5,ybase+17,2)
 print(str,5,ybase+16,10)
 
 local str="sound,music"
 
 print(str,5,ybase+25,2)
 print(str,5,ybase+24,10)
 
 local str="  - biolardi y. / neithr"
  
 print(str,5,ybase+33,2)
 print(str,5,ybase+32,7)
  
 local str="special thanks to"
 
 print(str,5,ybase+49,2)
 print(str,5,ybase+48,10)  

 local list={"pico-8","notepad++","you, the player"}
 local n=#list
 
 for i=1,n do
  print("  - "..list[i],5,ybase+57+(i-1)*8,2)
  print("  - "..list[i],5,ybase+56+(i-1)*8,7)  
 end
    
end

--

-- gallery state

gallery_state=state:new()

function gallery_state:init()
 state.init(self)
  
 self:init_menu()
end

function gallery_state:init_menu()
 local gmenu=menu:new()
 local xbase=40
 local ybase=36
 local highest_level=self.value_storer:get_value("highest_level")
 local is_finished=self.value_storer:get_value("is_game_finished")
 
 local add_pic=function(x,y,text)  
  gmenu:add({x,y,text},xbase,ybase)
 end
 
 local create_locked_pic=function(text)  
  add_pic(112,32,"??? ("..text..")")
 end
 
 gmenu:add({0,32,"found dungeon"},xbase,ybase)
 
 if(highest_level>=11)then
  add_pic(16,32,"intro char 1")
 else
  create_locked_pic("finish level 10")
 end
 
 if(highest_level>=21)then
  add_pic(32,32,"intro char 2")
 else
  create_locked_pic("finish level 20")
 end 
 
 if(highest_level>=31)then
  add_pic(48,32,"splitting")
 else
  create_locked_pic("finish level 30")
 end 
 
 if(highest_level>=41)then
  add_pic(64,32,"doing adventure")
 else
  create_locked_pic("finish level 40")
 end
 
 if(is_finished)then
  add_pic(80,32,"found treasure")
  add_pic(96,32,"dinner time")
 else
  create_locked_pic("finish all levels")
  create_locked_pic("finish all levels")
 end
  
 self.menu=gmenu
 self.menu_graphics=gmenu:get_elements()
end

function gallery_state:update()
 state.update(self)

 self:update_input()
end

function gallery_state:update_input()
 if (state.update_input(self)) return true

 if (btn(0)) then
  self.menu:decrease()
  self:play_sfx("ui")
  self:cooldown_input(5)
 elseif (btn(1)) then
  self.menu:increase()
  self:play_sfx("ui")
  self:cooldown_input(5)
 elseif (btn(4)) then
  self:play_sfx("ui")
  self:change_state_to("title") 
 elseif (btn(5)) then
  self:play_sfx("ui")
  self:change_state_to("title")
 end
 
 return false
end

function gallery_state:draw()
 rectfill(0,0,127,12,2)
 rectfill(0,119,127,127,2)
 
 print("‹‘ prev/mext",8,121,7)
 print("—/x to title",72,121,7)

 if (self.menu!=nil)then
 
  local index=self.menu:get_index()  
  local g=self.menu_graphics[index]
  local values=g.value
  local str=index..". "..values[3]

  print(str,64-#str*2,4,7)
 
  rect(g.x-1,g.y-1,g.x+48,g.y+48,2)
  rect(g.x-3,g.y-3,g.x+50,g.y+50,2)
  
  sspr(values[1],values[2],16,16,g.x,g.y,48,48)
 end
 
 //sspr(0,32,16,16,42,30,48,48)
end
-->8
-- levels

level_manager={
 name="lvl_manager"
}

function level_manager:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self) 
 o:init()

 return m
end

function level_manager:init(o)
 self.number=-1
 self.levels={}
 self.cur_level=nil
 self.replace_spr=10
 self.replace_flag=1
end

function level_manager:add_level(cx1,cy1,cx2,cy2,sx,sy)
 add(self.levels, {cx=cx1,cy=cy1,sx=sx,sy=sy,w=cx2-cx1+1,h=cy2-cy1+1})
end
 
function level_manager:reload_level()
 reload(0x1000, 0x1000, 0x1000)
 reload(0x2000, 0x2000, 0x1000)
end

function level_manager:get_cur_level()
 return self.cur_level
end
 
function level_manager:set_level(number)
 self.reload_level()
 self.number = number
 self.cur_level = self.levels[number]
end

function level_manager:restart_level()
 self:set_level(self.number)
end

function level_manager:next_level()
 if (self.number == #self.levels) then
  return false
 end
 
 self:set_level(self.number+1)
 return true
end

function level_manager:scan()
 local cur_level = self.cur_level
 local data={}

 local ch=cur_level.cy+cur_level.h
 local cw=cur_level.cx+cur_level.w
 
 for cy=cur_level.cy,ch do
  for cx=cur_level.cx,cw do
   self:convert(data,cx,cy,cur_level.cx-1,cur_level.cy-1)
  end
 end
 
 return data
end

function level_manager:convert(data,cx,cy,cx0,cy0)
 local spr_index=mget(cx,cy)
  
 if fget(spr_index,1) then
  add(data,{spr_index=spr_index,cx=cx-cx0,cy=cy-cy0})
  mset(cx,cy,self.replace_spr)
 end
end

function level_manager:check_end_level()
 return self.number==#self.levels
end

function level_manager:draw()
 local cur_level = self.cur_level
 if(cur_level==nil)return
 
 rectfill(0,0,127,12,2)
 rectfill(0,119,127,127,2)
 
 print("level "..self.number,2,4,7)
 print("”ƒ‹‘ move",8,121,7)
 print("—/x restart",76,121,7)
 map(cur_level.cx,cur_level.cy,cur_level.sx,cur_level.sy,cur_level.w,cur_level.h)
end

-- entity manager

entity_manager={
 name="ent_manager"
}

function entity_manager:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self) 
 o:init()
 
 return m
end

function entity_manager:init()
 self.entities={}
 self.r_entities={} // registered entities
end

function entity_manager:register(spr_index,class,args)
 self.r_entities[spr_index]={class=class,args=args}
end

function entity_manager:reset()
 foreach(self.entities,function(e)
  del(self.entities,e)
  e:destroy()
 end)
 
end

function entity_manager:spawn(spr_index,x,y)
 local e=self.r_entities[spr_index]
 if (e==nil)return
 
 local copy=e.args
 if (e.args!=nil) then
  copy={}
 
  for key,val in pairs(e.args) do
   copy[key]=val
  end
 end 

 local inst=e.class:new(copy)
 inst:set_position(x,y)
  
 add(self.entities,inst)

 return inst
end

function entity_manager:draw()
 foreach(self.entities,function(e)
  e:draw()
 end)
end
-->8
-- animation

anim={}

function anim:new(o)
 self.__index=self
 
 o=o or {}
 local m=setmetatable(o,self) 
 o:init()
 
 if(o.cur_spr_name!=nil)o:play(o.cur_spr_name,nil,true)
 
 return m
end

function anim:init()
 self.is_visible=true
 self.index=1
 self.cur_sprite=nil
 self.cur_spr_name=self.cur_spr_name
 self.sprites=self.sprites or {}
 
 self.is_playing=false
 self.is_loop=false
  
 self.frame_rate=10
 self.frame=1
 
 self.end_anim_event=nil
 self.is_active=true
 
 self.x=0
 self.y=0 
end

function anim:add_sprite(name,numbers)
 self.sprites[name]=numbers
end

function anim:play(name,frame_rate,loop) 
 self.is_playing=true
 self.is_loop=is_loop or true
 
 self.cur_sprite=self.sprites[name]
 self.cur_spr_name=name
 self.frame_rate=frame_rate or 15
end

function anim:set_end_anim_event(event)
 self.end_anim_event=event
end

function anim:set_position(x,y)
 if(x!=nil)self.x=x
 if(y!=nil)self.y=y
end

function anim:set_x(x)
 self.x=x
end

function anim:set_y(y)
 self.y=y
end

function anim:get_x()
 return self.x
end

function anim:get_y()
 return self.y
end

function anim:set_active(value)
 self.is_active=value
end

function anim:set_visible(value)
 self.is_visible=value
end

function anim:update()
 if (not self.is_active) return

 if (not self.is_playing or self.cur_sprite==nil) return
 if (#self.cur_sprite==1) return
 
 local frame=self.frame
 local index=self.index
 
 frame+=1
 if (frame%self.frame_rate==0) then
  frame=1
  index+=1
  if (index>#self.cur_sprite and self.is_loop) then
   index=1
  else
   if (self.end_anim_event!=nil) self.end_anim_event()
  end
 end
 
 self.frame=frame
 self.index=index
end

function anim:draw()
 if (self.cur_sprite==nil)return
 if (not self.is_visible)return
  
 spr(self.cur_sprite[self.index] or 0,self.x,self.y)
end

function anim:destroy()
 //self.sprites=nil
end


-->8
---------

-- player

player=anim:new()

function player:init()
 anim.init(self)
 self.facing=0
 self.move_speed=3
 self.to_x=0
 self.to_y=0
 self.end_move_event=nil
 self.is_ko=false 
end

function player:set_facing(name,frame_rate)
 self.facing=name
 self:play(name,frame_rate or 20,true)
end

function player:set_end_move_event(ev)
 self.end_move_event=ev
end

function player:update()
 anim.update(self)
 self:update_moving()
end

function player:move_to_x(x)
 self.to_x=x
end

function player:move_to_y(y)
 self.to_y=y
end

function player:kill()
 self:set_visible(false)
 self.is_ko=true
end

function player:update_moving()
 local move_speed=self.move_speed
 local end_ev=self.end_move_event
 local remainder
 
 if (self.to_x!=0) then
  local to_x=self.to_x
  
  if (to_x>0) then
   if (to_x>move_speed)then
    self.x+=move_speed
    to_x-=move_speed
   else
    self.x+=to_x
    to_x=0
   end
  elseif (to_x<0) then
   if (to_x<-move_speed)then
    self.x-=move_speed
    to_x+=move_speed
   else
    self.x+=to_x
    to_x=0
   end   
  end
  
  self.to_x=to_x
  
  if(to_x==0)then
   if(end_ev!=nil)end_ev()
  end
 end
 
 if (self.to_y!=0) then
  local to_y=self.to_y
 
  if (to_y>0) then
   if (to_y>move_speed)then
    self.y+=move_speed
    to_y-=move_speed
   else
    self.y+=to_y
    to_y=0
   end
  elseif (to_y<0) then
   if (to_y<-move_speed)then
    self.y-=move_speed
    to_y+=move_speed
   else
    self.y+=to_y
    to_y=0
   end   
  end
  
  self.to_y=to_y
  
  if(to_y==0)then
   if(end_ev!=nil)end_ev()
  end  
 end
end

-- te: tile_entities

te_ev_manager={}

function te_ev_manager:new(o)
 self.__index = self
 o=o or {}
 local m=setmetatable(o, self)
 o:init()
 
 return m 
end

function te_ev_manager:init()
 self.te_evs={}
 self.te_end_evs={}
end

function te_ev_manager:register_matched_event(spr_indexes,ev)
 foreach(spr_indexes,function(i)
  self.te_evs[i]=ev
 end)
end

function te_ev_manager:register_end_event(spr_indexes,ev)
 foreach(spr_indexes,function(i)
  self.te_end_evs[i]=ev
 end)
end

function te_ev_manager:get_ev(index)
 return self.te_evs[index]
end

function te_ev_manager:get_end_ev(index)
 return self.te_end_evs[index]
end

-- te: tile_entities

te=anim:new({
 dir_types={
  default=0
 }
})

function te:init()
 anim.init(self)
 self.areas={}
 self.end_event=nil
 self.matched_event=nil
 self.is_stepped=false
end

function te:activate_end_event(e)
 if(self.end_event==nil) return
 
 self.end_event(e,self)
end

function te:check_all_with_entity_pos(entity)
 local ex=entity.x
 local ey=entity.y
 local pos
 local output=false
  
 foreach(self.areas,function(a)
  pos=self:check_area(a.dir_type,a.dx,a.dy)
 
  if (pos.x==ex and pos.y==ey) then
   output=true
   if(self.matched_event!=nil)self.matched_event(entity,self)
 
   return
  end
 end)
 
 return output
end

function te:set_matched_event(ev)
 self.matched_event=ev
end

function te:check_area(dir_type,dx,dy)
 if(dir_type==0)then
  return {x=self.x,y=self.y}
 end 
end

function te:add_check_area(dir_name,dx,dy)
 local a={dir_type=self.dir_types[dir_name] or 0,dx=dx or 0,dy=dy or 0}

 add(self.areas,a)
end

function te:set_end_event(event)
 self.end_event=event
end

function te:destroy()
 anim.destroy(self)
 self.areas=nil
end


-- player te

player_te=player:new()

function player_te:init()
 player.init(self)
 
 self.stepped_te=nil
end

function player_te:set_stepped_te(te)
 self.stepped_te = te
end

function player_te:activate_stepped_te_event()
 if (self.stepped_te==nil)return

 self.stepped_te:activate_end_event(self,self.stepped_te)
 self.stepped_te=nil
end

-- goal te

goal_te=te:new()

function goal_te:init()
 te.init(self)
 
 self:add_sprite("basic",{11})
 self:play("basic")
 
 self:add_check_area()
end

-- hole te

hole_te=te:new()

function hole_te:init()
 te.init(self)
 
 self.cur_spr_name=self.cur_spr_name or "hole"
 
 self:add_sprite("hole",{12})
 self:add_sprite("cracked",{26})
 
 self:play(self.cur_spr_name)
  
 self:add_check_area()
end

-- arrow te

arrow_te=te:new()

function arrow_te:init()
 te.init(self)
 
 local spr_name=self.cur_spr_name
 local spr_i=13
 
 if (spr_name=="up")then
  spr_i=13
 elseif (spr_name=="down")then
  spr_i=29
 elseif (spr_name=="left")then
  spr_i=45
 elseif (spr_name=="right")then
  spr_i=61
 end
 
 self:add_sprite(self.cur_spr_name,{spr_i})
 self:play(self.cur_spr_name)
 
 self:add_check_area()
end

-- copper key

key_te=te:new()

function key_te:init()
 te.init(self)
 
 local spr_name=self.cur_spr_name
 local spr_i=42
 
 if (spr_name=="copper")then
  spr_i=42
 elseif (spr_name=="silver")then
  spr_i=58
 end
 
 self:add_sprite(self.cur_spr_name,{spr_i})
 self:play(self.cur_spr_name)
 
 self:add_check_area()
end

-->8
-- service locator

sl={}

function sl:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self)
 o:init()
 
 return m
end

function sl:init() 
 self.services={} 
end

function sl:add_service(class)
 local name=class.name

 if (self.services[name]==nil) then
  self.services[name]=class:new()
 end
 
 return self.services[name]
end

function sl:get_service(class)
 local name=class.name
 
 if (self.services[name]==nil) then
  return self:add_service(class)
 end
 
 return self.services[name]
end

-->8
-- value storer

value_storer={
 name="value_storer"
}

function value_storer:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self)
 o:init()
 
 return m
end

function value_storer:init() 
 self.values={} 
end

function value_storer:set_value(name,value)
 self.values[name]=value
end

function value_storer:get_value(name)
 return self.values[name]
end

-- data storer

data_storer={
 name="data_storer"
}

function data_storer:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self)
 o:init()
 
 return m
end

function data_storer:init() 
 self.cartname=nil
 self.data={} 
end

function data_storer:set_cartname(name)
 self.cartname=name
 cartdata(name)
end

function data_storer:register(index,name)
 self.data[name]=index
end

function data_storer:save(name,value)
 if(self.data[name]==nil or self.cartname==nil)return
 
 dset(self.data[name],value)
end

function data_storer:load(name)
 if(self.data[name]==nil or self.cartname==nil)return
 
 return dget(self.data[name])
end


-- timer event

timer_ev={}

function timer_ev:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self)
 o:init()
 
 return m
end

function timer_ev:init()
 self.wait_time=0
 self.wait_time_assigned=0
 self.event=nil
 self.is_paused=true
 self.is_loop=false
end

function timer_ev:update(framerate)
 if(self.is_paused)return

 local wait_time=self.wait_time
 framerate=framerate or 15
 
 if (self.wait_time>0)then
  wait_time-=framerate  
  
  if (wait_time <= 0)then
  
   if(self.is_loop)then
    wait_time=self.wait_time_assigned
   else
    wait_time=0
    self.is_paused=true
   end 
    
   if (self.event!=nil)self.event()
  end
  
 end
 
 self.wait_time=wait_time
end

function timer_ev:set_is_paused(value)
 self.is_paused=value
end

function timer_ev:activate_timer(ev,wait_time,is_loop)
 self.is_paused=false
 self.wait_time_assigned=wait_time
 self.wait_time=wait_time or 1000
 self.event=ev
 self.is_loop=is_loop or false
end

function timer_ev:stop()
 self:init()
end

function timer_ev:check_is_paused()
 return self.is_paused
end

-- menu --

menu={}

function menu:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self)
 o:init()
 
 return m
end

function menu:init()
 self.index=1
 self.elements={}
end

function menu:get_index()
 return self.index
end

function menu:get_elements()
 return self.elements
end

function menu:add(value,x,y)
 add(self.elements,{value=value,x=x,y=y})
end

function menu:increase(val,is_reset)
 local size=#self.elements
 local index=self.index
 if(is_reset==nil)is_reset=true
 
 index+=(val or 1)
  
 if(index==size+1)then
  if(is_reset)then
   index=1
  else
   index=size
  end
 end
 
 self.index=index
 
 return self.elements[index]
end

function menu:decrease(val,is_reset)
 local size=#self.elements
 local index=self.index 
 if(is_reset==nil)is_reset=true
 
 index-=(val or 1)
 
 if(index==0)then
  if(is_reset)then
   index=size
  else
   index=1
  end
 end
 
 self.index=index
 
 return self.elements[index]
end

-- transition --

transition={}

function transition:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self)
 o:init()
 
 return m
end

function transition:init()
 self.progress=0
 self.framerate_default=0.01
 self.framerate=self.framerate_default
 self.framemulti=1.15
 
 self.is_paused=true
 self.end_event=nil
 
 self.is_fade_in=false
end

function transition:start(end_event,is_fade_in)
 if(is_fade_in==nil)is_fade_in=true
 
 if(is_fade_in)then
  self.progress=1
 else
  self.progress=0
 end
 
 self.framerate=self.framerate_default
 self.is_fade_in=is_fade_in 
 self.is_paused=false
 self.end_event=end_event
end

function transition:update()
 if(self.is_paused)return

 local prog=self.progress
 local fr=self.framerate

 if(self.is_fade_in)then
  if(prog>0)then
   prog-=self.framerate
   
   if(prog<0)then
    prog=0
    self.is_paused=true
    if(self.end_event!=nil)self.end_event()    
   end
  end  
 else
  if(prog<1)then
   prog+=self.framerate
   
   if(prog>1)then
    prog=1
    self.is_paused=true
    if(self.end_event!=nil)self.end_event()
   end
  end  
 end
  
 fr*=self.framemulti
 
 self.progress=prog
 self.framerate=fr
end

function transition:draw()
 if(self.is_paused)return

 //left
 rectfill(-1,0,64*self.progress-1,128,2)

 //right
 rectfill(128-64*self.progress,0,128,128,2)

 //rectfill(0,0,64,128,1)
 
end
-->8
-- sound manager

sound_manager={
 name="sound_manager"
}

function sound_manager:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self)
 o:init()
 
 return m
end

function sound_manager:init()
 self.is_muted=false
 self.sounds={}
end

function sound_manager:set_mute(value)
 self.is_muted=value
end

function sound_manager:register(name,index)
 self.sounds[name]=index
end

function sound_manager:play(name)
 if(self.is_muted)return

 sfx(self.sounds[name])
end

-- music manager

music_manager={
 name="music_manager"
}

function music_manager:new(o)
 self.__index=self
 o=o or {}
 local m=setmetatable(o,self)
 o:init()
 
 return m
end

function music_manager:init()
 self.musics={}
 self.is_muted=false
 self.cur_music=nil
end

function music_manager:register(name,index)
 self.musics[name]=index
end

function music_manager:set_mute(value)
 self.is_muted=value
 
 if (self.is_muted)then
  //self.cur_music=nil
  music(-1)
 else
  music(self.cur_music)
 end
end

function music_manager:play(name,is_forced)
 local music_idx=self.musics[name]
 
 if(is_forced==nil)then
  is_forced=false
 end

 if (music_idx==nil)return
 if (music_idx==self.cur_music and is_forced==false)return

 self.cur_music=music_idx
 
 if(self.is_muted)return
 music(music_idx)
end

function music_manager:stop()
 self.cur_music=nil
 music(-1)
end
__gfx__
0000000000ddcc000000000000000000010000100000000000000000000000005555555d11111111ddddddd5ddddddd511111111000000000000000000000000
000000000ccddcc000ddcc0000ddcc00001111000100001001000010000000005ddddddd1ee22221d5555555d555511511111111000880000000000000000000
007007000ccccc800ccddcc00ccddcc0011111100011110000111100000000005ddddddd1e222221d5555555d222211511111111008888000000000000000000
000770000cffff800ccccc800ccccc8001ffff100111111001111110000000005ddddddd12222221d5555555d555551511111111088888800000000000000000
000770000cffffc00cffff800cffff8001ffff1001ffff1001ffff10000000005ddddddd12222221d5555555d222221511111111022882200000000000000000
007007000b5555b00cffffc00cffffc00855558001ffff1001ffff10000000005ddddddd12222221d5555555d555555511111111000880000000000000000000
00000000f088880f0e555ff00ff55540f0cccc0f0e555ff00ff555e0000000005ddddddd12222221d5555555d222222511111111008820000000000000000000
0000000000200200002205000050220000400400004405000050440000000000dddddddd11111111555555555555555511111111002200000000000000000000
00000000ddcccc000000000000000000000011100000000000000000000000000000000011111111ddddddd55555555100000000000000000000000000000000
00000000cddcccc0ddcccc00ddcccc0001111100000011100000111000000000000000001ee22121d15555155111221500000000000088000000000000000000
00000000cccc8cc0cddcccc0cddcccc011111100011111000111110000000000000000001e222221d51511555111111500000000000882000000000000000000
000000000fff8cc0cccc8cc0cccc8cc00fff11001111110011111100000000000000000012112221d55155555121221100000000088888800000000000000000
000000000fffccc00fff8cc00fff8cc00fff11000fff11000fff1100000000000000000012122111d55515555112122100000000088888800000000000000000
000000000005bcc00fffccc00fffccc0000580100fff11000fff1100000000000000000012222221d55151555122112100000000028888200000000000000000
00000000000ff00000ffbcc000e5bcc0000ff00000ff8e1000e58f10000000000000000012221221d11551151111111500000000002882000000000000000000
00000000000820000022850000882500000420000022450000442500000000000000000011111111555555551155515500000000000220000000000000000000
0000000000ccccdd0000000000000000011100000000000000000000000000000000000089999998008888000000000000000000000000000000000000000000
000000000ccccddc00ccccdd00ccccdd001111100111000001110000000000000000000092424249009999000000000000000000000800000000000000000000
000000000ccccccc0ccccddc0ccccddc0011111100111110001111100000000000000000929a9249009009000000000000000000008800000000000000000000
000000000cccfff00ccccccc0ccccccc0011fff000111111001111110000000000000000a2924249009889000000000000000000088888000000000000000000
000000000cccfff00cccfff00cccfff00011fff00011fff00011fff00000000000000000a24242a9000990000000000000000000088888800000000000000000
000000000ccb50000cccfff00cccfff0010850000011fff00011fff00000000000000000a24242a9000998000000000000000000028822800000000000000000
00000000000ff0000ccb5e000ccbff00000ff00001f85e0001e8ff00000000000000000092424249000999000000000000000000002800200000000000000000
00000000000280000052880000582200000240000052440000542200000000000000000092424249000000000000000000000000000200000000000000000000
0000000000cccc00000000000000000001011010000000000000000000000000000000002dddddd2002222000000000000000000000000000000000000000000
000000000cccccc000cccc0000cccc000011110001011010010110100000000000000000d242424d00666d000000000000000000000080000000000000000000
000000000cccccc00cccccc00cccccc00111111000111100001111000000000000000000d266d24d00602d000000000000000000080088000000000000000000
000000000cccccc00cccccc00cccccc0011111100111111001111110000000000000000062d2d24d00d2d0000000000000000000088888800000000000000000
000000000cccccc00cccccc00cccccc001111110011111100111111000000000000000006242426d000d6d000000000000000000028888800000000000000000
000000000bccccb00cccccc00cccccc001555510011111100111111000000000000000006242426d000660000000000000000000002288200000000000000000
00000000f088880f05ccccb00bcccc50f0cccc0f0e555580085555e00000000000000000d242424d0006dd000000000000000000000082000000000000000000
0000000000200200008205f00f50280000400400004402f00f2044000000000000000000d242424d000000000000000000000000000020000000000000000000
c6c6555555555c6cdddddddddddddddd444444444444444455555555555555555ccccddd55555555222222222222222222222777772222220000000000000000
ccc25225525252cc444444444444666633333333333333335552225555555522ccccddccd55ddddd2dcc2dddddddddd255557778877555550000000000000000
9695552555525596ddddddddddd6565644444444444444445555525552225555cccfffccc5552225dcd2d2222222212222227778777222220000000000000000
6962555555555269444444ccccd6656533333333333333335555555552555555ccf3ff3855555d25ddccc2dddddd112255577788777755550000015555100000
9692521252125596dddccccccc66d66644444441144411445555555555555555cff3ff3f55225d55cccccc22222111112c7cd777772172210000050000500000
ccdccc115111551144c44cccccc4444433633311111113332222555555552222cfffffff5dd25555ffffcc2ddd111111ccccccc5551111110000050000500000
cccc51c151115112ddddcfffffccdddd44664111111114441111255555521111ccb555bc5d555dd53ff38222221fffffccffffc2211111120000050000500000
ccccc111511111114444c3ff3f8c4444333631fffff113331111155555211111ccb555bc555555553ff3f2777221ff1fcf3ff38c51fff1110000055555500000
cccccddddd111111ddddf3ff3f8cdddd6644441ff1f11444cc111255552221112222222222222222f88ff7aaa7f1ff1fcf3ff3f8221f1f110000555555550000
cccf3cd3d1d111114444ffffffcc444436633f1ff1f11333ccc11155552112221155115555555555b55b7ad8897f88ffcff88ffc5f1f1f110000555115550000
cccf3c33331f1111ddddccbbbbccdddd44644ffffff11444cccc11522512111151111115dd52222555557a8829715588ccbbbbc22ff8fff10000555115550000
cccfff33331ff111ddddcbbbbbbcdddd4444414888844144cccc11525512111111ffff15d552dd55551f792229788555cca3bbf5551388510000555555550000
ccfcff333ffff111dd6ffb666ffcdddd4444696588ff4444cccc1155552111111f1ff1155555d555111ff79997ff85552639a96226aba9f40000555555550000
ccfc33333ffff111466f6966ff444944d5d59a955ffd5dd5ccccb155552121111f1ff1f555555555555fff777fff555546666664466666640000000000000000
cc55bb33333811154666966694459996559855559d555555ccccb155552218ff1ffffff522225555bbbbfffdffff888844666644446666440000000000000000
c5555bb3338511554999999944566664d5598889d555d55dccccf15225118888118558555dd25555bbbb22ddd228888844444444444444440000000000000000
02200220022002200220022002200220022002200220022002200220022002200220022002200220022002200002200002222220022222200220022002222220
0220022002200220022002200220022002200220022002200220022002200220022002200220022002200220002dd0000dddddd00dddddd00dd00dd00dddddd0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddd00000000dd000000dd00dd00dd00dd00000
0dddd00000000000000000d000000000dddddd00000000000000000000000000000000000000000000000000000dd00002222dd000222dd00dd22dd00dd22220
0dddd00000000000000dd0d000000000ddddddd0000000000000000000000000000000000000000000000000000dd0000dddddd000ddddd00dddddd00dddddd0
026d200dddd00ddd000220200dddd000dd222d600dd00dd00dd0dd0000ddd0d000dddd0000dddd000dd0dd00000dd0000dd0000000000dd000000dd000000dd0
006600d6ddddddddd00d6000ddddd0006d00066006d006d00dddddd00dddddd00dddddd00dddddd00dddddd0002dd2000dd2222002222dd000000dd002222dd0
0066002662d6d2d6d0066000666220006600066006600660066d26600662266006622d6006d22660066d266000dddd000dddddd00dddddd000000dd00dddddd0
00660006602660266006600026660000660006d00660066006620660066006600666662006600660066206600222222002222220022222200222222002222220
006d0006d006d00d6006d000006660006d00ddd006d00dd006d006d00d6ddd600662220006dd0dd006d006d00dddddd00dddddd00dddddd00dddddd00dddddd0
0dddd00dd00dd00dd00dd000ddddd000ddddddd00ddddddd0dd00dd002ddddd00dddddd00dddddd00dd00dd00dd000000dddddd00dd00dd00dd00dd00dd00dd0
0dddd00dd00dd00dd00dd000dddd2000dddddd2002dddd2d0dd00dd000222dd002dddd2002dddd200dd00dd00dd2222000000dd00dd22dd00dd22dd00dd00dd0
022220022002200220022000222200002222220000222202022002200d000dd00022220000222200022002200dddddd000000dd00dddddd00dddddd00dd00dd0
000000000000000000000000000000000000000000000000000000000dddddd00000000000000000000000000dd00dd000000dd00dd00dd000000dd00dd00dd0
0220022002200220022002200220022002200220022002200220022002dddd200220022002200220022002200dd22dd000000dd00dd22dd002222dd00dd22dd0
02200220022002200220022002200220022002200220022002200220002222000220022002200220022002200dddddd000000dd00dddddd00dddddd00dddddd0
000090d0d29000009090a0d3d1a0909000909090909090b0a09000909090900000909090900090a0a0900090a0900090a1a1a1a1900090c090a190e790909090
90909090909090000000000000000090d090d090d1900090a0c0d2a0c0d2a0900090c0d2a0a0d2a0c09000909090909090909090909090900000000000000000
00009010d0900000009090a0b09090000090a0d2d2a0d2d0a09000000000000000000000000090d0a0900090a090009090c090a1900090a1a1a190009010c0a1
a1a1a1a1c0b090009090909090909090a0a0a0a0a0900090b0c0d2a0a0a0a0900090c0d2a0c0d2a0909000000000000000000000000000000000000000000000
000090909090000000009090909000000090a0d3d3a0d3d0a09000909090909090909090900090a0a090009092900090c0a1a1a1900090a19090900090a1c0a1
909090a1c0a1900090b0a0a0a0a0a093a2a0a0a0a090009090909090909090900090909090909090900000000000000000e69090909090009090909090909090
00000000000000000000000000000000009010d2d2a0d3d3a0900090a0d2a0a0a0d2a0b0900090a0d0900090d19000909090a1a1900090a190c0900090a1a1a1
a1a1a1a1a1a190009090909090909090909090909090000000000000000000000000000000000000000000000000000000d69010a0a190009040a0b090a3a190
d690909090909090009090909090909000909090909090909090009040a0a0d2a0a0a0d2900090a0a2900090b0900000009090a1900090a1a1a1900090909090
90909090909090e6000000000000000000000000000000e690909090909090000000909090e690909090900090909090900090a0a0a0900090a0a09090a1a190
f690a0a0a0a0a0900090a0a040a0a090d6000000000000000000009090909090909090909000909090900090909000000090a1a19000909090a1900000000000
00000000000000f7909090909090900090909090909000b69010a0a0a0a090000000904090c69040a0a0909090a0a0a0900090a090a2900090a0a0a092a0a190
009010d3d3d1a0900090a0d1a0d1a090b790909090909090900000000000d600000000000000000000000000000000909090a190900090a1a1a1900090909090
900090909090900090a0c0a1a14090009010a0a0a090900090a0a0a0a0a09090900090a0900090a090a0a1a1a1a090a090009093909090009090909090909090
009090d090d1a0900090d0a0d2a0d290009040a190c0a1a1900000000000c79090900090909000909090909090900090b0a1a1c0900090b090c090009040c0a1
909090a1c0b0900090b090a1a1a1900090a0a0a0a0a0900090909090a0a1a1a1900090a0900090a090a0a1a1a1a090a0900090a1a1a190000000000000000000
0090b0d0c0d2a0900090c0d0a0d2c0900090c0a1a1a1a1b0900000000000009010900090b0900090c0a1a1a14090009090909090900090909090900090a1c0a1
a1a1a1a1c0a1900090a0a1a1c0a190009090909090a1900090b0a0a0a09090a190009092900090b0a0a0909090a0a0a2900090a1a1b090000000000000000000
0090a0a0a0a0a0900090d0a0d2c0d09000909090909090909000000000000090a1900090a1900090a1a190909090000000000000000000000000000090a1a1a1
909090a1a1a19000909090909090900090a1a1a1c0a1900090909090a19090a1900090a190009090909090009090909090009090909090000000000000000000
0090909090909090009090d1a0d1909000000000000000000000000000000090a1909090a1900090a1c09000000000e60090909090909000909090e690909090
9000909090909000000000000000000090a1c0a1a1a1900000000090a1a1a1a2900090b090000000000000000000000000000000000000000000000000000000
00000000000000000090d3a0d1c0d19000000000000090909090909090900090a1a1c0a1a1900090a1a19090909000d79090a0a0a0d19000901090e700000000
0000000000000000909090909090909090a1c0a1a1a1900000000090909090909000909090000090909090909090909000000000000000000000000000000000
00000000000000000090a0d3a0d1c0900000000000009010a1a1a1a1a1900090c0a1a1a1c0900090c0a1a1a1b090000090c0a0b0a0c0900090a1900090909090
909090909090900090b0a1c090a1a1a1a1a19090a190900000000000000000000000000000000090a0a0a090a0a0a09000000000000000000000000000000000
00000000000000000090d0c0d1c0d09000000000000090c0c090c0a1b09000909090909090900090909090909090000090d0a040a090900090a1900090a1a1a1
a1a110a093b0900090a1a1a1a1a1c090a1a1a1a1a1900000000000000000000000000000000000901090a192a190b09000000000000000000000000000000000
00000000000000000090a0a0b0a0a0900000000000009090909090909090000000e60000000000000000000000000000909090909090000090a1900090a19090
90a1a0d190a090009090909090909090909090909090000000000000000000000000000000000090909090909090909000000000000000000000000000000000
00000000000000000090909090909090000000000000e600000000000000000000c79090909090909090009090909000000000000000000090a1900090a19000
90a190c0909090f60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e690909090909090e600000000000000000000000000b7909090909090909090000090a1a392a1c0a190009040a09000909090909090909090a1900090a19090
90a19090900000f79090909090900090909090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e690a092a0a1a090f690909090909000909090909090009040a0a0a0d2a0a090900090a1c090a1a1a1900090a0a0900090a0a0c0d2a1a0d290a1900090a2a1a1
a1a19000000000009010a1a1a1900090a1a1a1409000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090a090a1a3a190009010a0a0a090009040a0a1a2900090909090a090c0a0a0900090a1a190c0a190900090a1a1900090b090a0d0a190a090a1900090909090
909090009090900090909090a1900090a19090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090a090a0a140900090a0a1a1a0900090a0a090a1900090c0d290a090c0d2a0900090c0a190a1a190000090a0a0900090a0a0a0d0a190a0a1a1900000000000
0000000090a3900090a2a0a0a0900090a0a0a0a09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090a090909090900090a0a0a0a0900090a0a093b0900090d0a0a0a0d3a0a0b0900090a1a190a0a09000909090a090009090a0d2a1a190c0d290900090909090
909090909092900090d1d1d1a1900090d1d1d1a09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090b0900000000000909090a190900090909090909000909092909090909090900090a1c090b0a0900090a2a0a0900000909090909090909090000090b0a190
a1a140a0a0a0900090c0c0c093900090c0c0c0929000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009090900090909000000090a1900000000000000000000090a090000000000000009010a090909090009090c0a1900000000000000000000000000090d0a1a1
a1d3c090a0a0900090a0a0a0a0900090909090a19000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000090a09000909090a1909000909090909090009090a09000909090909000909090900000000090a0a1a1900000000000000000000000000090909090
909090909090900090a0909090900090a1a1a1a39000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009090909090a0900090a0a0a0a0909090a0a0a0a0900090d1a090009010a0a29000000000000090909090a09090900000000000000000000000000000000000
000000000000000090a0a0a1a1900090a0a0a0a09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090a0a1a093a0900090a0a1a1a0a192a1a0a1a1a0900090c0a0900090d090939000000000000090b0a0a193a1a1900000000000000000000000000000000000
000000000000000090d1a090a1900090a19090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090a1a2a190a0900090a3a0a0a0909090a0a0a0b0900090a3a0900090c0d2b09000000000000090909090909090900000000000000000000000000000000000
000000000000000090a1a190b0900090a1a1a1b09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009010a1a090b0900090909090909000909090909090009090909000909090909000000000000000000000000000000000000000000000000000000000000000
00000000000000009090909090900090909090909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0002000002000000000100020202000000000000000000000001020200020000000000000000000000010200000200000000000000000000000102000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7f090919090909000919190909097f09090909090009090909097f09090909090000000000007f090909090909090909097f09090909000909090909097f09090909090009090909097f09090909090009090909097f090909090909090909097f09090909090909000000007f09090909090000000000006b09090909090909
7f090a0a0a0b0900090a0a0a0b096b090a0a0b0900090a0a0b096c090a0a0a090009090909096d09010a0a0a0a0a0a0b096e09040a0900090a0a0a01096f09010a0b0900090a0a04097b090a0b0a0900090a0b0a097c09010a0a0a0c0a0a0a097d090a090a0c0a09090900007e09010c0b090000000000007f09040a0a0a0a09
00090a0a09090900090909290a0900090a0a0a0900090a0a0a0900090a090a090009010a0a0900090909090909090909090009090a0900090a0909090900090a090a0900090a090a0900090a0c0a0900090a0c0a0900090c0c0a0a0a0a0c0b0900090a0a0a0a0a0c0b09000000090a0c0a0900000000000000090c0c0c0c0a09
00090a0a0a0a1900090a1a1a0c0900090a0a0a090009040a0a0900090b090a09000909090a09000000000000000000000000090a0a0900090a0a0a0b0900090a0a0a0900090a0a0a0900090a0a0a0900090a0a0a09000909090909090909090900090a0c0a090a0a0a09000000090a0a0a0900000000000000090b090a0a0a09
0009090a1a1a090009090a0a0a0900090a0a0a0900090909090900090a09040900090b0a0a09000909090909090909090900090a09090009090909090900090909090900090a09090900090c0a0c0900090c0a0c0900000000000000000000000009040c0a090a090909000000090909090900000000000000090a0a0a0c0c09
00090c0a0d1a0900190a0a0a0a0900090a010a0900000000000000090a0a0a0900090a090a0900090a0a0a0a0a0a0a0a0900090a0a090000000000000000000000000000090a0a0a090009040a0a0900090a0a010900090909090900000000000009090909090909000000000000000000000909090909090009090909090909
00190a0a3d1a0900190c0a090a1900090909090900000000000000090909090900090a0a0a0900090a0909090909090a090009090a090909090909090900090909090909090a090a0900090909090900090909090900090c0c0c09090000000000000000000000000009090900000000000009040a0a0b090000000000000000
00092a0a0a0a1900090a0a0a0a196b000000000909090009090900000000000000090909090900090a0900000000090a0900090a0a0a090a0a0a090a0900090b090a0a0a090a0a0a090000000000000000000000000009040a0a0b0900000000000909090909090909090a09000000000000090a0c0c0a090000090909090900
000909090a0a09001909090a0a096e09090909090b0900090b0909090909000000000000000000090b090000000009040900090a090a0a0a090a0a0b0900090a090a090a0909090a0900000000000000000000000000090c0c0c0909000000000009010c0a0a0a0c0a0a0b09000000000000090a0c0c0a090000090b0a0a0900
0009010a0a0a090009040a0a0a090009040a2a390a0900090a3a290a01090000000000000000000909090000000009090900090909090909090909090900090a0a0a090a0a0a0a0a09000000000000000000000000000909090909000000000000090a0a0a090a0a0a090a09000000000000090a0a0a0a090000090c09010900
0009090919190900091919090909000909090909090900090909090909090000000909090909000000000000000000000000000000000000000000000000090909090909090909090900000000000000000000000000000000000000000000000009090909090909090909090000000000000909090909090000090909090900
000000000000000000000000000000000000000000000000000000000000006b09090a0a0a09000009090909096b09090909090009090909096b0909090000000000000000000000000000090909090909006b0909090909090909096c090909090900000000000000000000000000000000006c000000000000000000000000
6b00090909090909096b09090909090009090909096b0000090909090909096f090a0a090a090009090a090a097b09040c0b090009010a0a097c090c090900000009090909096b0909090009010a0a0a09097e090c090a01090a3a097f090b0a0a090009090909096c090909090909090909096c000909090000000909090000
6b00092a0a0a0a0a096c090a0a010900090a0a0b096d0909090a010a0a0a090009090a090a0900090b2a0a0a0900090a0c0a0900090a0a0a0900090b0a09090000090b0a0a097d09040900090c0c0c392a0900090a090c0a090a0a0900090c0a0c0900090b0a0a096b09013d3d3d3d3d3d0b0900090904090900090901090900
0009090909090a0a0900090a09090900090a09090900090b090a0909090a0900093a0a09010900090909090a0900090a0a0a0900090a0a0a0900092a0a0a09090009090c290900090a0900090c0c0b0a090900090b090c0a0c0c0a0900090c04090900090c0a0c09000909090909090909090900090a0a0a0900090a0a0a0900
00090a0a0a0a0a0a0900092909000000090a0a040900090a0a0a0900092a090009290909090900090a0a0a0a0900090c0a0c0900090929090900090a090a0c090900090a0a0900090a09000909090909090000090a0a290a0a0a0a0900090c290c0900090c0a0c09000000000000000000000000090d0d0a0900090a0d0d0900
00090a0a090909090900090a09090900090a0909090009090909090009090900090a090b0a090009390909090900090a0a0a0900090a0a0a090009010a0a0c0c090009040a0900090a0900000000000000000009090909090909090900090c0a0c0900090c390c09000909090909090909090900090d0a0a0900090a0a0a0900
00090a0a0a010b090000090a0a0b0900090a0a2a090000000000000000000000090a0a0a0a0900090a090a0a090009090a0a09000909090a090009090909090909000909090900090a0900090909090909000000000000000000000000090c0a0c09000909010c090009043d3d3d3d3d3d0b0900090a0a0d0900090d0a0d0900
000909090909090900000909090909000909090909000909090909090909090009090909090900090a0a0a0409000009092a0900090a0b0a090000000000000000000000000000090a0900090a0a0a0a09000009090909090909090900093a0a0a0900090c0a0c0900090909090909090909090009090b09090009090b090900
00000000000000000000000000000000000000000000090b0a0a0a0a0a0a0900000000000000000909090909090000000909090009090909090000000909090909090909090000090a0909090a0c0c0a090000092a0a0c040a0a0a0900090909090900090c0a0c09000000000000000000000000000909090000000909090000
000000090909090900000000000000000000000000000909090909090929090000000000006c000000000000006c000000000000000000000000006c09013d0a3d0a3d0a090000090a0a0a3a290c0b0a090000090a0a390a0a0c0b0900000000000000090a0a2a0900006d090909090909090909090000006d6e000000000000
0000000904290b0900000000000000000000000000000000090a040a0a0a090000000000007b090909090909097d090909090909090009090909097e090b09090909092a09000009090909090909090909000009090909090909090900000000000000090909090900006d09011d090a0a0a0a0a090000000909090909090909
6c0000090909090900000000000000000000000000000000090909090909090000000000000009043d2a3d0b0900092a0a0a0a0a0900090b2d3a090009392d0a2d0a2d0a090000000000000000000000000000000000000000000000000000000000000000000000000000090a1d090a0c2d2d0a0900000009043d0c0a3d0c09
6d0000000000000000000000000000006c0000000000000000006c0000000000000000000000090909090909090009090909090a09000901090a090009090909090909090900006d09090909090900090909090909096d0909090909090909096d09090909090009090900090a1d090a0d090d0a09000000090a3d3d0a3d0c09
000009090909000000000909090900006e0909090909090909096f09090909000009090909000000000000000000090a3d0a0a0a0900090a090a090000000000000000000000007f090b290a04090009010a0a0a0a096b090a0a0a0a0c0c01096c090b0a04090009010900090a0c2d0a0d090d0a09000000090a3d0c0a3d0c09
0009090a0b090900000009041d09000000090a2d2d0a3d3d04090009011d090000093d1d09000009090909090000090a090a3d0a0900090a090a090009090909090909090909090009091d0a0d0900091d090d091d0900090a1d1d0a0d0d0a0900091d0d1d0900091d0900090a0a0a0a0d090d0b09000000090a3d0c0a3d0b09
09090a3d0d0a09090000091d2d09000000090a1d2d0a3d3d0a0900090d1d090909090d1d0900000901290b090000090b390a3d040900090a290a090009293d0a3d0a3d0a3d0a0900091d0a0d0a0900090a3d0a2d0a0900090b0c0c0a0a0a0a0900090c0c0c0900091d0900090909090909090909090000000909090909090909
090a0a0d2d0a0a090000093d1d09000000090a1d3d0a2d2d0a0900090d3d3d3d3d3d0d1d090000090909090900000909090909090900090909090900090b090909090909093a0900090a3d0a2d0900090d091d090d090009090909090909090900090909090900091d0900000000000000000000000000000000000000000000
0909093d0d0909090000091d2d09000000090a0b09090909090900090d1d2d2d2d2d2d1d096c0000000000000000000000000000000000000000000009042d0a2d0a2d0a2d0a0900093d0a1d0a0900090a2d0a2d0a090000000000000000000000000000000009091d0900090909090909090909090909090009090909090900
0000090d2d0900000909093d1d0909090009090909000000000000090d1d090909090d1d097c09090909000909096d09090909090900090909090900090909090909090909090900090a2d3a0d0900091d091d090d0900090909090909090909000909090909090a0a090009040c3d3d3d0a3d3d3d0c0a090009010b3d0c0900
0000093d0d090000090a0a1d2d0a0a090000000000000909090900090b2d090000090d2d090009010b09000904097d0904091a0c090009011a1a096d00000000000000000000000009090909090900090a3d0a3d0a0900090a0a0a0a0c2d040900090b0a0a0c2d0a1d0900093d3d3d0a3d3d3d0a0a0a0b090009090909090900
__sfx__
000c00000e555005050e5550f5050e555005050e555005051e5051d505005050050500505005050050500505255050e5050050500505005050050500505005052550510505005050050500505005050050500505
001000002905124051210511f0411d0411c0411b0411a03100003120001200039000360000f0000e0000e0000a000090001700014000100000e000110000c0000900007000000000000000000000000000000000
001000000085500805008000080003800108000180000800008000080000800008000080000800008000080000800008000080000800008000080000800008000080000800008000080000800008000080000800
001000000d03504005040350a00500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
000800000d3310d3000d3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000005300053000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
001000000892000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900009000090000900
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004000000000015000000001200013000000000000000000000001900000000190001900019000000001900000000180001800017000150001500014000140001500014000080000000008000100001000000000
002000000160203602016020360201602046020660203602016020360201602036020360206602016020460204602046020760206602046020660205602046020260205602066020460204602066020160204602
001000000835508305003000030003355003050030508305083550030500305003050335500305003050030508355003050030500305033550030500305003050835500305003050030503355003000030000300
0010000016554165001454414500165541650014544015001a5541950418554175041655415504135440050413544135441455414554155540050000500165001655401500155001450013544005000050016500
001000000c534165000c534145040f544165040f54401504125540050412554115440f544195040f5440f504125540050412554115440f544005040f544115441455413504145540050412544145041455416500
00200000046031c603046031c6021c6031c603046031c6030460304603046031c60304603046031d6021c6030460304603046031c6030460304603046031c6030460304603046031c60304603206001e6021c603
001000200c055095050705504505010550c0050b005030050c055095050705504505010550000000000000000c055050050705501005010550000000000000000c05505005070550100501055000000000000000
001000200d5500950009500075000f5000b5000b500005000f5500d500065001350014500135000c5000c50012550005001050010500015000f5000f500005000f55000500015000050000500005000050000500
001000200d550095000c500075000c5500b5000d550005000f5500d5000d500135001155013500115000c50012550005001050010500115500f50010550105000f5500050001500005000f550005000050000500
001000200d550095000c500075000c5500b5000d550005000f5500d5000d500135001155013500115000c500115500050010500105000d5500f5000f550105000f55000500015001050010500105000050000500
001000200d5500950009500075000f5000b5000b500005000f5000d500065001350014500135000c5000c50012550005001050010500015000f5000f500005000f50000500015000050000500005000050000500
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
03 18 42 43 44
01 1a 42 43 44
01 1a 1c 43 44
02 1a 1b 43 44
03 1e 1f 43 44
01 1e 1f 19 44
01 1e 20 18 44
02 1e 22 19 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
