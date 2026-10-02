function init(self)
 msg.post(".", "acquire_input_focus")
 gui.set_text(gui.get_node("gold_number"), SNAPSHOT.gold)
 for name, exist in pairs(SNAPSHOT.buildings) do
  if exist then
   gui.set_color(gui.get_node("button_"..name), vmath.vector3(0.7, 0.7, 0.8))
   gui.set_enabled(gui.get_node("cost_"..name), false)
  else
   if SNAPSHOT.gold < PRICE[name] then
    gui.set_color(gui.get_node("cost_"..name), vmath.vector3(1, 0.7, 0.75))
   end
   gui.set_text(gui.get_node("cost_"..name), PRICE[name])
  end
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
 if action_id == hash("cancel") then
  msg.post("controller:/controller", "close_builder")
 end
 if action_id == hash("touch") and action.pressed then
  if gui.pick_node(gui.get_node("button_back"), action.x, action.y) then
   msg.post("controller:/controller", "close_builder")
  end
  for name, exist in pairs(SNAPSHOT.buildings) do
   if not exist and gui.pick_node(gui.get_node("button_"..name), action.x, action.y) then
    if SNAPSHOT.gold>=PRICE[name] then
     SNAPSHOT.gold = SNAPSHOT.gold - PRICE[name]
     SNAPSHOT.buildings[name] = true
     JUST_BUILT[name] = true
     sound.play("controller:/sfx#build")
     msg.post("controller:/controller", "close_builder")
    else
     sound.play("controller:/sfx#no_gold")
    end
   end
  end
 end
end

function on_reload(self)
                                 
                                                      
                                      
end
