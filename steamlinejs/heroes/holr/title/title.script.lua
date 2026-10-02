require "lua_modules.globals"

function init(self)
 msg.post("title:/start#label", "disable")

 msg.post(".", "acquire_input_focus")

 self.warmup_time = 4
 self.label_shown = false
 
 go.set("title:/bg#bg", "tint", vmath.vector4(0.3,0.2,0.3,1))
 go.animate("title:/bg#bg", "tint", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1), go.EASING_OUTSINE, self.warmup_time)
 go.set("title:/scene#scene", "tint", vmath.vector4(0.3,0.2,0.3,1))
 go.animate("title:/scene#scene", "tint", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1), go.EASING_OUTSINE, self.warmup_time)
 go.set("title:/scene#town", "tint", vmath.vector4(0.3,0.2,0.3,1))
 go.animate("title:/scene#town", "tint", go.PLAYBACK_ONCE_FORWARD, vmath.vector4(1, 1, 1, 1), go.EASING_OUTSINE, self.warmup_time)
 go.animate(".", "position.y", go.PLAYBACK_ONCE_FORWARD, 52, go.EASING_OUTSINE, self.warmup_time, 0, function()
  timer.delay(self.warmup_time/6, true, function()
   self.label_shown = not self.label_shown
   if self.label_shown then
    msg.post("title:/start#label", "enable")
   else
    msg.post("title:/start#label", "disable")
   end
   
  end)
 end)

 sound.play("controller:/sfx#music_title")
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
  msg.post("controller:/controller", "start_intro")               
 end
end

function on_reload(self)
                                 
                                                      
                                      
end
