require "lua_modules.globals"

                                                    
function init(self)
 self.old_pos = go.get_position()
end

function final(self)
                              
                                                  
                                      
end

function update(self, dt)
                        
                                                  
                                      
end

function on_message(self, message_id, message, sender)
 if message_id == hash("set_kind") then
  self.name = message.name
  self.foe = message.foe
  msg.post("#sprite", "play_animation", {id = hash(self.name.."_idle")})
  sprite.set_hflip("#sprite", self.foe)
 elseif message_id == hash("summon") then
  self.idle = false
  self.name = message.name
  self.foe = message.foe
  sprite.play_flipbook("#sprite", self.name.."_summon", function()
   msg.post("#sprite", "play_animation", {id = hash(self.name.."_idle")})
   self.idle = true
  end)
  sprite.set_hflip("#sprite", self.foe)
  sound.play("controller:/sfx#summon")
 elseif message_id == hash("move") then
  go.cancel_animations(".", "position")
  go.set_position(self.old_pos)
  sprite.set_hflip("#sprite", self.old_pos.x > message.to.x)
  go.animate(".", "position.x", go.PLAYBACK_ONCE_FORWARD, message.to.x, go.EASING_LINEAR, UNIT_MOVE_TIME, 0, 
  function() 
   self.idle = true
   self.old_pos = go.get_position()
   sound.play("controller:/sfx#step", { gain = 0.7+math.random()*0.3, speed = 0.7+math.random()*0.3 })
  end)
  go.animate(".", "position.y", go.PLAYBACK_ONCE_FORWARD, 
   self.old_pos.y+(message.to.y-self.old_pos.y)/2+6, go.EASING_OUTQUAD, UNIT_MOVE_TIME/2, 0, 
  function() 
   go.animate(".", "position.y", go.PLAYBACK_ONCE_FORWARD, message.to.y, go.EASING_INQUAD, UNIT_MOVE_TIME/2)
  end)
  go.animate(".", "position.z", go.PLAYBACK_ONCE_FORWARD, message.to.z, go.EASING_LINEAR, UNIT_MOVE_TIME)
  self.idle = false
 elseif message_id == hash("attack") then
  self.idle = false
  sprite.set_hflip("#sprite", self.old_pos.x > message.target.x)
  go.cancel_animations(".", "position")
  go.set_position(self.old_pos)
  msg.post("#sprite", "play_animation", {id = hash(self.name.."_atk1")})
  timer.delay(UNIT_MOVE_TIME/2, false,
  function() 
   msg.post("#sprite", "play_animation", {id = hash(self.name.."_atk2")})
   timer.delay(UNIT_MOVE_TIME, false,
   function()
    msg.post("#sprite", "play_animation", {id = hash(self.name.."_idle")})
    self.idle = true
   end)
                                       
  end)
  if not message.ranged then
   local pos = self.old_pos + (message.target - self.old_pos) / 2
   go.animate(".", "position", go.PLAYBACK_ONCE_FORWARD, pos, go.EASING_INQUART, UNIT_MOVE_TIME/2, 0,
   function()
    sound.play("controller:/sfx#hit", { gain = 0.6+math.random()*0.4, speed = 0.6+math.random()*0.4 })
    go.animate(".", "position", go.PLAYBACK_ONCE_FORWARD, self.old_pos, go.EASING_INQUART, UNIT_MOVE_TIME)
   end)  
  end
 elseif message_id == hash("suffer") then
  self.idle = false
  sprite.set_hflip("#sprite", self.old_pos.x > message.source.x)
  timer.delay(UNIT_MOVE_TIME/2, false, function()
   msg.post("#sprite", "play_animation", {id = hash(self.name.."_hit")})
   if message.die then
    if self.name == "warlock" then
     sound.stop("controller:/sfx#music_final_fight")
     sound.play("controller:/sfx#warlock_end", {}, function()
      sprite.play_flipbook("#sprite", "warlocks_end", function() self.idle=true end)
      sound.play("controller:/sfx#hit", { delay = 1.5 })
     end)
    else
     go.animate("#sprite", "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_INCIRC, 1, 0,
     function() self.idle = true end)
     local die_pos = self.old_pos + vmath.normalize(self.old_pos - message.source) * 3
     go.animate(".", "position", go.PLAYBACK_ONCE_FORWARD, die_pos, go.EASING_OUTCIRC, 1)
     sound.play("controller:/sfx#death")
    end
    
   else
    timer.delay(UNIT_MOVE_TIME/2, false, function()
     msg.post("#sprite", "play_animation", {id = hash(self.name.."_idle")})
     self.idle = true
    end)
   end
  end)
 elseif message_id == hash("select") then
  go.set_position(self.old_pos)
  local jump_pos = self.old_pos + vmath.vector3(0, 2, 0)
  go.animate(".", "position", go.PLAYBACK_LOOP_PINGPONG, jump_pos, go.EASING_OUTQUAD, 0.333)
 elseif message_id == hash("deselect") then
  go.cancel_animations(".", "position")
  go.set_position(self.old_pos)
 end
end

function on_input(self, action_id, action)
                                                                            
                                   
   
                                           
   
                                                                          
                                                              
                                                 
                                      
end

function on_reload(self)
                                 
                                                      
                                      
end

                                                                                                         
                                                                                                         
