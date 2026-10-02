require "lua_modules.globals"
require "lua_modules.tactic"

function init(self)
 self.nodes = {}
 self.hexes = {}
 self.units = {}
 self.win = false
 self.lose = false
 self.hover_i = -1
 self.old_hover_i = -2
 self.idle = true

 msg.post("#bg", "play_animation", {id = hash("battle_bg_"..BATTLES[BATTLE_I].env)})

 self.grid = Grid()

 for row = 0, self.grid.rows-1 do
  for col = 0, self.grid.cols-1 do
   local i = col + row*self.grid.cols
   local x = GRID_X+col*NODE_W+row%2*(NODE_W/2)+NODE_W/2
   local y = GRID_Y+row*NODE_H+NODE_H/2
   self.hexes[i] = factory.create("#hex_factory", vmath.vector3(x, y, 0))
   self.nodes[i] = vmath.vector3(x, y, 0.9 - y/128.0)
  end
 end

 for i, _ in pairs(self.grid.trees) do
  local tree = factory.create("#tree_factory", self.nodes[i])
 end

 for i, unit in pairs(self.grid.units) do
  local unit_go = factory.create("#unit_factory", self.nodes[i])
  msg.post(unit_go, "set_kind", {name=unit.kind.gfx_name, foe=unit.foe})
  self.units[i] = unit_go
 end

 update_unit_info(self)

 if BATTLES[BATTLE_I].final then
  sound.play("controller:/sfx#music_final_fight", { delay = 2, gain = 0.7 })
 else
  sound.play("controller:/sfx#music_battle", { delay = 2 })
 end
 msg.post(".", "acquire_input_focus")
end

function final(self)
 msg.post(".", "release_input_focus")
end

function update(self, dt)
 self.idle = true
 for i, unit in pairs(self.units) do
  local unit_url = msg.url("battle", unit, "unit")
  self.idle = self.idle and go.get(unit_url, "idle")
  if not self.idle then return end
 end

 local e = self.grid.events[1]
 if e then
  if e.name == "end" then
   finish_battle(self, e.result)
  elseif e.name == "moves_updated" then
   for i, unit in pairs(self.units) do
    if i == self.grid.act_unit_i then
     msg.post(unit, "select")
    else
     msg.post(unit, "deselect")
    end
   end
   remove_marks(self)
   for i, node in pairs(self.grid.moves) do
    if e.ap>=node.cost then msg.post(self.hexes[i], "mark_walk") end
   end
   for i in pairs(self.grid.attacks) do
    msg.post(self.hexes[i], "mark_attack")
   end
  elseif e.name == "unit_moved" then
   local unit = self.units[e.from_i]
   self.units[e.from_i] = nil
   self.units[e.to_i] = unit
   msg.post(unit, "move", {to = self.nodes[e.to_i]})
   remove_marks(self)
  elseif e.name == "attack" then
   msg.post(self.units[e.from_i], "attack", {target = self.nodes[e.to_i], ranged = e.ranged})
   if e.ranged then
    local dist = vmath.length(self.nodes[e.to_i] - self.nodes[e.from_i])
                                                             
    go.set_position(self.nodes[e.from_i], "arrow")
    go.animate("arrow", "position", go.PLAYBACK_ONCE_FORWARD, self.nodes[e.to_i],
    go.EASING_LINEAR, dist * (UNIT_MOVE_TIME/2) / 64, UNIT_MOVE_TIME/2, 
    function()
     go.set_position(vmath.vector3(-16, 0, 0), "arrow")
    end)
    sound.play("controller:/sfx#bow")
   end
   msg.post(self.units[e.to_i], "suffer", {source = self.nodes[e.from_i], die = e.lethal})
                                                      
   remove_marks(self)
  elseif e.name == "summon" then
   msg.post(self.units[e.from_i], "attack", {target = self.nodes[e.to_i], ranged = true})
   local unit_go = factory.create("#unit_factory", self.nodes[e.to_i])
   msg.post(unit_go, "summon", {name=e.kind, foe=e.foe})
   self.units[e.to_i] = unit_go
   remove_marks(self)
  else
   print("unknown event: ", e.name)
  end
  table.remove(self.grid.events, 1)
 elseif self.grid.IsFoeTurn() then
  self.grid.FoeAct()
 end
end

function on_message(self, message_id, message, sender)
 if not self.idle then return end
 if message_id == hash("skip") then
  msg.post(self.units[self.grid.act_unit_i], "deselect")
  self.grid.SkipCurrentUnit()
 elseif message_id == hash("flee") then
  finish_battle(self, "defeat")
 end
end

function on_input(self, action_id, action)
 if not action_id then                 
          
  self.old_hover_i = self.hover_i
  self.hover_i = -1
  local mouse_pos = vmath.vector3(action.x, action.y, 0)
  for i, node_pos in pairs(self.nodes) do
   local dist = mouse_pos - node_pos
   if vmath.length_sqr(dist) < NODE_W*NODE_W/4 then
    go.set_position(node_pos-vmath.vector3(0, 0, 0.1), "/hover_hex")
    self.hover_i = i
    break
   end
  end
  if self.hover_i == -1 then
   go.set_position(vmath.vector3(-64, -64, 0), "/hover_hex")
  end
  update_unit_info(self)
 elseif action_id == hash("touch") and action.released and self.idle then
  self.grid.ProcessClickOn(self.hover_i)
  self.old_hover_i = -1
  update_unit_info(self)
 end
end

function on_reload(self)
                                 
                                                      
                                      
end

                                                                                                                          
                                                                                                                          

function remove_marks(self)
 for i, hex in pairs(self.hexes) do
  msg.post(hex, "clear_marks")
 end
end

function update_unit_info(self)
 if self.old_hover_i == self.hover_i then return end
 msg.post("/ui#battle_gui", "update_info", {unit = self.grid.units[self.hover_i]})
end

function finish_battle(self, result)
 if result == "victory" then
  SNAPSHOT.units = {}
  for i, unit in pairs(self.grid.units) do
   if not unit.foe then
    table.insert(SNAPSHOT.units, unit.kind.gfx_name)
   end
  end
  local b = BATTLES[BATTLE_I]
  SNAPSHOT.gold = SNAPSHOT.gold + b.reward
  SNAPSHOT.battles_done[b.name] = true
  DEFEATED = false
 else
  DEFEATED = true
 end

 go.set_position(vmath.vector3(-64, -64, 0), "/hover_hex")
 for i, unit in pairs(self.units) do
  msg.post(unit, "deselect")
 end
 remove_marks(self)
 msg.post("/ui#battle_gui", "disable")
 msg.post("/final#final", "start", {result = result})
 msg.post(".", "release_input_focus")
end