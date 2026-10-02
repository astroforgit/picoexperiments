require "lua_modules.globals"

function init(self)
 msg.post("/reward", "disable")
end

function final(self)
 msg.post(".", "release_input_focus")
end

function update(self, dt)
                        
                                                  
                                      
end

function on_message(self, message_id, message, sender)
 if message_id == hash("start") then
  msg.post(".", "acquire_input_focus")

  sound.stop("controller:/sfx#music_battle")
  sound.stop("controller:/sfx#music_final_fight")

  self.result = message.result
  if self.result == "victory" then
   label.set_text("/reward#amount", BATTLES[BATTLE_I].reward)
   sound.play("controller:/sfx#music_victory")
  else
   sound.play("controller:/sfx#music_defeat")
  end
  
  msg.post("#result", "play_animation", {id = hash(self.result)})
  go.animate(".", "position.y", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INQUART, 0.5, 0, 
  function()
   if message.result == "victory" then
    msg.post("/reward", "enable")
   end
  end)
 end
end

function on_input(self, action_id, action)
 if action_id == hash("touch") and action.released then
                                    
                                                        
  if self.result == "victory" and BATTLES[BATTLE_I].final then
   msg.post("controller:/controller", "win_game")
  else
                                  
                                                                                                  
   msg.post("controller:/controller", "end_battle")
  end
 end
end

function on_reload(self)
                                 
                                                      
                                      
end
