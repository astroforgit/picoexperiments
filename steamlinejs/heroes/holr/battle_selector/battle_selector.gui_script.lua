require "lua_modules.globals"

function init(self)
 msg.post(".", "acquire_input_focus")

 self.selected = -1

 local max_battles = 3

 print("Player strength: "..party_strength(SNAPSHOT.units))

 local sign_i = 0
 self.battles = {}
 for i, battle in ipairs(BATTLES) do
  if SNAPSHOT.battles_done[battle.name] and battle.once then
   print("skipping mission "..battle.name)
  elseif (not battle.req) or SNAPSHOT.battles_done[battle.req] then
   if party_strength(battle.units) - party_strength(SNAPSHOT.units) <= 10 then
    sign_i = sign_i + 1
    self.battles[i] = gui.get_node("battle"..sign_i)
    gui.set_color(self.battles[i], vmath.vector3(1, 0.86, 0.86))
    gui.set_text(gui.get_node("text"..sign_i), battle.name)
    print("Sign N"..sign_i..": battle N"..i..", strength: "..party_strength(battle.units))
    if battle.final then
     gui.set_color(gui.get_node("text"..sign_i), vmath.vector3(0.4, 0, 0))
    end
    if sign_i == max_battles then break end
   end
  end
 end

      
     
                                                          
                         
                                                      
                                                                  
                                                             
                          
                                                                            
         
                                             
        
       

 for i = sign_i+1, max_battles do
  gui.set_enabled(gui.get_node("battle"..i), false)
  gui.set_enabled(gui.get_node("text"..i), false)
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
  local selected = -1
  for battle_i, box in pairs(self.battles) do
   if gui.pick_node(box, action.x, action.y) and gui.is_enabled(box) then
    selected = battle_i
   end
  end
  if selected ~= self.selected then
   if self.selected > 0 then
    gui.set_color(self.battles[self.selected], vmath.vector3(1, 0.86, 0.86))
   end
   if selected > 0 then
    gui.set_color(self.battles[selected], vmath.vector3(1, 1, 1))    
   end
   self.selected = selected
  end
 elseif action_id == hash("touch") and action.pressed then
  if self.selected > 0 then
   BATTLE_I = self.selected
   msg.post("controller:/controller", "start_battle")
  elseif gui.pick_node(gui.get_node("button_back"), action.x, action.y) then
   msg.post("controller:/controller", "battle_rejected")
  end
 elseif action_id == hash("cancel") then
  msg.post("controller:/controller", "battle_rejected")
 end
end

function on_reload(self)
                                 
                                                      
                                      
end
