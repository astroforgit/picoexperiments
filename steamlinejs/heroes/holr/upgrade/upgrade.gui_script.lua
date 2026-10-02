require "lua_modules.globals"

function init(self)
 msg.post(".", "acquire_input_focus")
 gui.set_text(gui.get_node("gold_number"), SNAPSHOT.gold)
 local unit = SNAPSHOT.units[UPGRADE_UNIT_I] 
 for name, req in pairs(UPGRADE_REQ) do
  if unit == req.unit and SNAPSHOT.buildings[req.building] then
   gui.set_text(gui.get_node("text_"..name), name)
   gui.set_text(gui.get_node("cost_"..name), req.cost)
   if SNAPSHOT.gold < req.cost then
    gui.set_color(gui.get_node("cost_"..name), vmath.vector3(1, 0.7, 0.75))
   end
  else
   gui.set_position(gui.get_node("button_"..name), vmath.vector3(128, 128, 0))
  end
 end

 if unit == "spearman" then
  gui.set_position(gui.get_node("button_demote"), vmath.vector3(128, 128, 0))
 end

 gui.set_text(gui.get_node("name"), string.upper(unit))
 local s = KINDS[unit].dmg.."\n"..KINDS[unit].hp.."\n"..KINDS[unit].ap.."\n"..KINDS[unit].dist
 gui.set_text(gui.get_node("stats_numbers"), s)
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
  UPGRADE_UNIT_I = -1
  msg.post("controller:/controller", "close_upgrade")  
 end
 if action_id == hash("touch") and action.pressed then
  if gui.pick_node(gui.get_node("button_back"), action.x, action.y) then
   UPGRADE_UNIT_I = -1
   msg.post("controller:/controller", "close_upgrade")
  elseif gui.pick_node(gui.get_node("button_demote"), action.x, action.y) then
   SNAPSHOT.units[UPGRADE_UNIT_I] = "spearman"
   msg.post("controller:/controller", "close_upgrade")
  end
  local kind = SNAPSHOT.units[UPGRADE_UNIT_I]
  for name, req in pairs(UPGRADE_REQ) do
   if gui.pick_node(gui.get_node("button_"..name), action.x, action.y) then
    if SNAPSHOT.gold>=req.cost then
     SNAPSHOT.gold = SNAPSHOT.gold - req.cost
     SNAPSHOT.units[UPGRADE_UNIT_I] = name
     msg.post("controller:/controller", "close_upgrade")
    else
     sound.play("controller:/sfx#no_gold")
    end   
   end
  end
 end
end

function on_reload(self)
                                 
                                                      
                                      
end
