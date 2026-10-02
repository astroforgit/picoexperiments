function init(self)
 msg.post(".", "acquire_input_focus")
 
 self.current_str = 1
 
 label.set_text("intro:/intro#label", INTRO[self.current_str])
end

function final(self)
 msg.post(".", "release_input_focus")
end

function update(self, dt)
                        
                                                  
                                      
end

function on_message(self, message_id, message, sender)
                                  
                                                           
                                      
end

function on_input(self, action_id, action)
 if action.pressed then
  sound.play("controller:/sfx#step", { gain = 0.7+math.random()*0.3, speed = 0.7+math.random()*0.3 })
  self.current_str = self.current_str + 1
  if self.current_str > #INTRO then
   msg.post("controller:/controller", "start_prelude")
   return
  end
  label.set_text("intro:/intro#label", INTRO[self.current_str])
 end
end

function on_reload(self)
                                 
                                                      
                                      
end
