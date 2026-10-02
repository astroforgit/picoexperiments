require "lua_modules.globals"

                                                                
function init(self)
 if not self.end_game then reset_snapshot() end

 msg.post(".", "acquire_input_focus")

 if self.show_final then
  msg.post("#win_proxy", "load")
 else
  msg.post("#title_proxy", "load")
 end

 table.sort(BATTLES, function(a,b) return party_strength(a.units) > party_strength(b.units) end)
 for _, battle in ipairs(BATTLES) do
  print(battle.name..": "..party_strength(battle.units))
 end
 print("5 spearmen : "..party_strength({"spearman", "spearman", "spearman", "spearman", "spearman"}))
 print("5 archers  : "..party_strength({"archer", "archer", "archer", "archer", "archer"}))
 print("5 swordsmen: "..party_strength({"swordsman", "swordsman", "swordsman", "swordsman", "swordsman"}))
end

function final(self)
                              
                                                  
                                      
end

function update(self, dt)
                        
                                                  
                                      
end

function on_message(self, message_id, message, sender)
 if message_id == hash("start_game") then
  msg.post("#town_proxy", "load")
  msg.post("#title_proxy", "unload")
  sound.stop("/sfx#music_title")
  sound.play("/sfx#step")
  sound.play("/sfx#music_town", { delay = 2})
 elseif message_id == hash("start_intro") then
  msg.post("#intro_proxy", "load")
  msg.post("#title_proxy", "unload")
  sound.play("/sfx#step")
 elseif message_id == hash("start_prelude") then
  msg.post("#battle_proxy", "load")
  msg.post("#intro_proxy", "unload")
  sound.stop("/sfx#music_title")
 elseif message_id == hash("open_builder") then
  msg.post("#builder_proxy", "load")
  msg.post("#town_proxy", "unload")
  sound.play("/sfx#step")
 elseif message_id == hash("close_builder") then
  msg.post("#town_proxy", "load")
  msg.post("#builder_proxy", "unload")
  sound.play("/sfx#step")
 elseif message_id == hash("open_upgrade") then
  msg.post("#upgrade_proxy", "load")
  msg.post("#town_proxy", "unload")
  sound.play("/sfx#step")
 elseif message_id == hash("close_upgrade") then
  msg.post("#town_proxy", "load")
  msg.post("#upgrade_proxy", "unload")
  sound.play("/sfx#step")
 elseif message_id == hash("end_battle") then
  msg.post("#town_proxy", "load")
  msg.post("#battle_proxy", "unload")
  sound.stop("controller:/sfx#music_victory")
  sound.stop("controller:/sfx#music_defeat")
  sound.play("/sfx#music_town", { delay = 0.5})
 elseif message_id == hash("win_game") then
  sound.stop()
  msg.post("#win_proxy", "load")
  msg.post("#battle_proxy", "unload")
 elseif message_id == hash("battle_rejected") then
  msg.post("#town_proxy", "load")
  msg.post("#battle_selector_proxy", "unload")
  sound.play("/sfx#step")
 elseif message_id == hash("select_battle") then
  msg.post("#battle_selector_proxy", "load")
  msg.post("#town_proxy", "unload")
  sound.play("/sfx#step")
 elseif message_id == hash("start_battle") then
  msg.post("#battle_proxy", "load")
  msg.post("#battle_selector_proxy", "unload")
  sound.stop("/sfx#music_town")
 elseif message_id == hash("proxy_loaded") then
                                 
  msg.post(sender, "enable")
 elseif message_id == hash("proxy_unloaded") then
                                   
 end
end

function on_input(self, action_id, action)
                                                                            
                                   
   
                                           
   
                                                                          
                                                              
                                                 
                                      
end

function on_reload(self)
                                 
                                                      
                                      
end
