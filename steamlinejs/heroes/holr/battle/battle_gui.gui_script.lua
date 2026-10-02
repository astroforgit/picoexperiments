function init(self)
 msg.post(".", "acquire_input_focus")
 self.skip = gui.get_node("skip")
 gui.set_color(self.skip, vmath.vector3(0.7, 0.8, 0.7))
 self.skip_hl = false
 self.flee = gui.get_node("flee")
 gui.set_color(self.flee, vmath.vector3(0.7, 0.8, 0.7))
 self.flee_hl = false
 self.icons = gui.get_node("icons")
 self.ap = gui.get_node("ap")
 self.dmg = gui.get_node("dmg")
 self.hp = gui.get_node("hp")
 gui.set_text(self.ap, "")
 gui.set_text(self.dmg, "")
 gui.set_text(self.hp, "")
 gui.set_enabled(self.icons, false)
end

function final(self)
 msg.post(".", "release_input_focus")
end

function update(self, dt)
                        
                                                  
                                      
end

function on_message(self, message_id, message, sender)
 if message_id == hash("update_info") then
  if message.unit then
   gui.set_text(self.ap, message.unit.ap)
   gui.set_text(self.dmg, message.unit.kind.dmg)
   gui.set_text(self.hp, message.unit.hp)
   gui.set_enabled(self.icons, true)
  else
   gui.set_text(self.ap, "")
   gui.set_text(self.dmg, "")
   gui.set_text(self.hp, "")
   gui.set_enabled(self.icons, false)
  end
 end
end

function on_input(self, action_id, action)
 if not action_id then                 
  if not self.skip_hl and gui.pick_node(self.skip, action.x, action.y) then
   gui.set_color(self.skip, vmath.vector3(0.9, 0.9, 0.8))
   self.skip_hl = true
  elseif self.skip_hl and not gui.pick_node(self.skip, action.x, action.y) then
   gui.set_color(self.skip, vmath.vector3(0.7, 0.8, 0.7))
   self.skip_hl = false
  elseif not self.flee_hl and gui.pick_node(self.flee, action.x, action.y) then
   gui.set_color(self.flee, vmath.vector3(0.9, 0.9, 0.8))
   self.flee_hl = true
  elseif self.flee_hl and not gui.pick_node(self.flee, action.x, action.y) then
   gui.set_color(self.flee, vmath.vector3(0.7, 0.8, 0.7))
   self.flee_hl = false
  end
 elseif action_id == hash("touch") and action.released then
  if self.skip_hl then
   msg.post("/grid#battle", "skip")
  elseif self.flee_hl then
   msg.post("/grid#battle","flee")
  end
 elseif action_id == hash("skip") and action.released then
  msg.post("/grid#battle", "skip")
 end
end

function on_reload(self)
                                 
                                                      
                                      
end
