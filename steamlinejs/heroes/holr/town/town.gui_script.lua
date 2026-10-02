require "lua_modules.globals"

function init(self)
 msg.post(".", "acquire_input_focus")
 
 gui.set_text(gui.get_node("gold_number"), SNAPSHOT.gold)
 for name, exist in pairs(SNAPSHOT.buildings) do
  if not exist or JUST_BUILT[name] then
   gui.set_color(gui.get_node(name), vmath.vector4(1, 1, 1, 0))
  end
  if JUST_BUILT[name] then
   gui.animate(gui.get_node(name), gui.PROP_COLOR, vmath.vector4(1, 1, 1, 1), gui.EASING_INOUTSINE, 2)
   JUST_BUILT = {}
  end
 end
 self.units = {}
 self.hover_unit_i = -1
 for i = 1, 5 do
  self.units[i] = gui.get_node("unit"..i)
  local unit_cost = gui.get_node("cost"..i)
  if SNAPSHOT.units[i] then
   gui.play_flipbook(self.units[i], SNAPSHOT.units[i].."_idle")
   gui.set_enabled(unit_cost, false)
   if i == UPGRADE_UNIT_I then
    local pos = gui.get_position(self.units[i])
    gui.set_position(self.units[i], pos + vmath.vector3(0, 6, 0))
    gui.animate(self.units[i], "position", pos, gui.EASING_INQUART, 0.5)
    UPGRADE_UNIT_I = -1
    sound.play("controller:/sfx#upgrade")
   end
  else
   if i < 4 or SNAPSHOT.buildings.tower then
    gui.set_text(unit_cost, PRICE.spearman)
   else
    gui.set_enabled(self.units[i], false)
   end
  end
 end

 gui.set_color(gui.get_node("restored"), vmath.vector4(1,1,1,0))
 if DEFEATED then
  gui.animate(gui.get_node("restored"), "color", vmath.vector4(1,1,1,1), gui.EASING_OUTQUART, 3, 0, nil, gui.PLAYBACK_ONCE_PINGPONG)
  DEFEATED = false
 end
end

function final(self)
 msg.post(".", "release_input_focus")
end

function update(self, dt)
                        
                                                  
                                      
end

function on_message(self, message_id, message, sender)
 
                                  
                                                           
                                      
end

function on_input(self, action_id, action)
 if not action_id then                 
  local hover_unit_i = -1
  for i, box in pairs(self.units) do
   if gui.pick_node(box, action.x, action.y) and gui.is_enabled(box) then
    hover_unit_i = i
   end
  end
  if hover_unit_i ~= self.hover_unit_i then
   local x = 2 + 12 * (hover_unit_i - 1)
   gui.set_position(gui.get_node("unit_select"), vmath.vector3(x, -2, 0))
   self.hover_unit_i = hover_unit_i
  end
 elseif action.pressed then
  if action_id == hash("add_money") then
   SNAPSHOT.gold = SNAPSHOT.gold + 10
   gui.set_text(gui.get_node("gold_number"), SNAPSHOT.gold)
  elseif action_id == hash("rem_money") then
   SNAPSHOT.gold = math.max(SNAPSHOT.gold - 10, 1)
   gui.set_text(gui.get_node("gold_number"), SNAPSHOT.gold)
  elseif self.hover_unit_i > 0 then
   if SNAPSHOT.units[self.hover_unit_i] then
    UPGRADE_UNIT_I = self.hover_unit_i
    msg.post("controller:/controller", "open_upgrade")
   elseif SNAPSHOT.gold >= PRICE.spearman then
    SNAPSHOT.units[self.hover_unit_i] = "spearman"
    SNAPSHOT.gold = SNAPSHOT.gold - PRICE.spearman
    local unit = self.units[self.hover_unit_i]
    gui.set_text(gui.get_node("gold_number"), SNAPSHOT.gold)
    gui.play_flipbook(unit, SNAPSHOT.units[self.hover_unit_i].."_idle")
    gui.set_enabled(gui.get_node("cost"..self.hover_unit_i), false)
    local pos = gui.get_position(unit)
    gui.set_position(unit, pos + vmath.vector3(0, 6, 0))
    gui.animate(unit, "position", pos, gui.EASING_INQUART, 0.5)
    sound.play("controller:/sfx#upgrade")
   else
    sound.play("controller:/sfx#no_gold")
   end
  elseif gui.pick_node(gui.get_node("button_build"), action.x, action.y) then
   msg.post("controller:/controller", "open_builder")
  elseif gui.pick_node(gui.get_node("button_battle"), action.x, action.y) then
   msg.post("controller:/controller", "select_battle")
  end
  
                                       
                                                                            
                                
                          
                                                          
                                                  
                                      
                                                      
                                                                
                                                                    
                                                       
                                                   
                                                                     
                                                                            
          
         
 end
 
end

function on_reload(self)
                                 
                                                      
                                      
end
