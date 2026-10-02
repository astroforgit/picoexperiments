require "lua_modules.globals"

function init(self)
 self.warmup_time = 4
 self.current_str = 1
 
 msg.post("win:/credits#label", "disable")
 go.set("win:/bg#bg", "tint", vmath.vector4(0.3,0.2,0.3,1))
 go.animate("win:/bg#bg", "tint", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1), go.EASING_OUTSINE, self.warmup_time)
 go.set("win:/scene#scene", "tint", vmath.vector4(0.3,0.2,0.3,1))
 go.animate("win:/scene#scene", "tint", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1), go.EASING_OUTSINE, self.warmup_time)
 go.set("win:/scene#town", "tint", vmath.vector4(0.3,0.2,0.3,1))
 go.animate("win:/scene#town", "tint", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1), go.EASING_OUTSINE, self.warmup_time)
 go.animate(".", "position.y", go.PLAYBACK_ONCE_FORWARD, 52, go.EASING_OUTSINE, self.warmup_time, 0, function()
  label.set_text("win:/credits#label", CREDITS[self.current_str])
  msg.post("win:/credits#label", "enable")
  timer.delay(CREDIT_DELAY, true, function()
   self.current_str = self.current_str + 1
   if self.current_str > #CREDITS then return end
   label.set_text("win:/credits#label", CREDITS[self.current_str])
  end)
 end)
 
 self.godzillas = {
  "minibeast", "beast", "demon", "ogre"
 }
 self.i = 1

 timer.delay(GODZILLA_DELAY, true, function()
  msg.post("win:/godzi#sprite", "play_animation", {id = hash(self.godzillas[self.i].."_idle")})
  self.i = (self.i % #self.godzillas) + 1
  go.set_position(vmath.vector3(-10, 13, -0.1), "win:/godzi")
  go.animate("win:/godzi", "position.x", go.PLAYBACK_ONCE_FORWARD, 80, go.EASING_LINEAR, 6)
  go.animate("win:/godzi", "position.y", go.PLAYBACK_LOOP_PINGPONG, 18, go.EASING_OUTQUAD, 0.85)
 end)

 sound.play("controller:/sfx#music_title", {}, function() sound.play("controller:/sfx#music_final_fight") end)
                                                   
end

function final(self)
                              
                                                  
                                      
end

function update(self, dt)
                        
                                                  
                                      
end

function on_message(self, message_id, message, sender)
                                  
                                                           
                                      
end

function on_input(self, action_id, action)
                                                                            
                                   
   
                                           
   
                                                                          
                                                              
                                                 
                                      
end

function on_reload(self)
                                 
                                                      
                                      
end
