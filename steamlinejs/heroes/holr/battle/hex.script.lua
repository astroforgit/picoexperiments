function init(self)
 msg.post("#walk_mark", "disable")
 msg.post("#attack_mark", "disable")
                                                                                          
                                                             
                                      
                                 
                                                                 
end

function final(self)
                              
                                                  
                                      
end

function update(self, dt)
                        
                                                  
                                      
end

function on_message(self, message_id, message, sender)
 if message_id == hash("mark_walk") then
  msg.post("#walk_mark", "enable")
 elseif message_id == hash("mark_attack") then
  msg.post("#attack_mark", "enable")
  go.animate("#attack_mark", "tint.w", go.PLAYBACK_LOOP_PINGPONG, 0, go.EASING_INSINE, 0.8)
 elseif message_id == hash("clear_marks") then
  go.cancel_animations("#walk_mark", "tint.w")
  go.set("#attack_mark", "tint.w", 1.0)
  msg.post("#attack_mark", "disable")
  msg.post("#walk_mark", "disable")
 end
end

function on_input(self, action_id, action)
                                                                            
                                   
   
                                           
   
                                                                          
                                                              
                                                 
                                      
end

function on_reload(self)
                                 
                                                      
                                      
end
