require "lua_modules.globals"

       
function Grid()
 local s = {}

 s.rows = 5
 s.cols = 5

 s.links = {}
 s.units = {}
 s.unit_queue = {}
 s.trees = {}
 s.moves = {}
 s.attacks = {}
 s.events = {}
 s.act_unit_i = -1

 math.randomseed(os.clock() * 100.0)
 local battle = BATTLES[BATTLE_I]
 
 for i = 1, battle.trees do
  local x = math.random(1,s.cols-2)
  local y = math.random(s.rows)-1
  s.trees[y*s.cols + x] = true
 end
 
 for row = 0, s.rows-1 do
  for col = 0, s.cols-1 do
   local i = col + row*s.cols
   s.links[i] = {}
   if col > 0 then s.links[i][i-1] = true end
   if col < s.cols-1 then s.links[i][i+1] = true end
   if row > 0 then 
    s.links[i][i-s.cols] = true
    if row%2==0 and col>0 then s.links[i][i-s.cols-1] = true end
    if row%2==1 and col<s.cols-1 then s.links[i][i-s.cols+1] = true end
   end
   if row < s.rows-1 then
    s.links[i][i+s.cols] = true
    if row%2==0 and col>0 then s.links[i][i+s.cols-1] = true end
    if row%2==1 and col<s.cols-1 then s.links[i][i+s.cols+1] = true end
   end
  end
 end

 print("PLAYER STRENGTH: "..party_strength(SNAPSHOT.units))
 local i = 0
 for _, name in pairs(SNAPSHOT.units) do
  s.units[i] = {
   kind = KINDS[name],
   ap = KINDS[name].ap,
   hp = KINDS[name].hp,
   foe = false,
   unic_name = "unit_"..KINDS[name].gfx_name.."_"..i
  }
  i = i + s.cols
 end
 print("ENEMY STRENGTH: "..party_strength(battle.units))
 local i = COLS*ROWS - 1
 for _, name in pairs(battle.units) do
  s.units[i] = {
   kind = KINDS[name],
   ap = KINDS[name].ap,
   hp = KINDS[name].hp,
   foe = true,
   unic_name = "unit_"..KINDS[name].gfx_name.."_"..i
  }
  i = i - s.cols
 end

                
 for i, unit in pairs(s.units) do
  table.insert(s.unit_queue, unit)
 end
 table.sort(s.unit_queue, function(a,b) return a.ap > b.ap end)

 function s.ProcessClickOn(click_i)
  local unit = s.units[s.act_unit_i]
  if s.moves[click_i] and s.moves[click_i].cost <= unit.ap then
   s.Move(s.act_unit_i, click_i)
  elseif s.attacks[click_i] then
   s.Attack(s.act_unit_i, click_i)
  end
 end

 
 function s.SkipCurrentUnit()
  if s.act_unit_i < 0 then return end
                                                   
  s.NextUnit()
 end

 
 function s.NextUnit()
  local win, lose = true, true
  for i, unit in pairs(s.units) do
   if unit.foe then win = false else lose = false end
  end
  if win then
   table.insert(s.events, {name = "end", result = "victory"})
   print("victory detected")
   s.act_unit_i = -1
   return
  end
  if lose then
   table.insert(s.events, {name = "end", result = "defeat"})
   print("defeat detected")
   s.act_unit_i = -1
   return
  end

  if s.act_unit_i >= 0 then
                                   
   local done_unit = table.remove(s.unit_queue, 1)
   done_unit.ap = done_unit.kind.ap
   table.insert(s.unit_queue, done_unit)
  end
  for i, unit in pairs(s.units) do
   if unit == s.unit_queue[1] then
    s.act_unit_i = i
                                        
    break
   end
  end
  s.FindMoves()
  s.FindAttacks()
  if not s.units[s.act_unit_i].foe then
   table.insert(s.events, {name = "moves_updated", ap = s.units[s.act_unit_i].ap}) 
  end
 end


 function s.FoeAct()
  local i_a, node_a = next(s.attacks)
  if node_a then
   local attacks_i = {}
   for i in pairs(s.attacks) do
    table.insert(attacks_i, i)
   end
   s.Attack(s.act_unit_i, attacks_i[math.random(#attacks_i)])
  elseif next(s.moves) then
   local min_cost = 9999
   local target_i = -1
   for i, node in pairs(s.moves) do
    for i2, _ in pairs(s.links[i]) do
     if s.units[i2] and not s.units[i2].foe then
      if node.cost < min_cost then
       min_cost = node.cost
       target_i = i
       break
      end
     end
    end
   end
   if target_i < 0 then
    target_i = next(s.moves)
   end
   s.Move(s.act_unit_i, target_i)
  else
   s.NextUnit()
  end
 end


 function s.FindMoves()
  s.moves = {}
  local edge = {}
  edge[s.act_unit_i] = {cost = 0, parent = nil}
  
  local add_to_edge = function(i, cost, parent)
   if edge[i] ~= nil and edge[i].cost > cost then
    edge[i] = {cost = cost, parent = parent}
   elseif not s.units[i] and not edge[i] and not s.moves[i] and not s.trees[i] then
    edge[i] = {cost = cost, parent = parent}
   end
  end

  repeat
   for i, node in pairs(edge) do
    for next_i, _ in pairs(s.links[i]) do
     add_to_edge(next_i, node.cost+1, i)
    end
    s.moves[i] = node
    edge[i] = nil
   end
  until next(edge) == nil

  s.moves[s.act_unit_i] = nil
 end


 function s.FindAttacks()
  s.attacks = {}
  local edge = {}
  edge[s.act_unit_i] = {cost = 0, parent = nil}

  local add_to_edge = function(i, cost, parent)
   if cost > s.units[s.act_unit_i].kind.dist then return end
   if edge[i] ~= nil and edge[i].cost > cost then
    edge[i] = {cost = cost, parent = parent}
   elseif not edge[i] and not s.attacks[i] then
    edge[i] = {cost = cost, parent = parent}
   end
  end

  repeat
   for i, node in pairs(edge) do
    for next_i, _ in pairs(s.links[i]) do
     add_to_edge(next_i, node.cost+1, i)
    end
    s.attacks[i] = node
    edge[i] = nil
   end
  until next(edge) == nil

  for i, node in pairs(s.attacks) do
   if s.units[s.act_unit_i].kind.summon then
    if s.units[i] or s.trees[i] then s.attacks[i] = nil end
   elseif not s.units[i] then s.attacks[i] = nil 
   elseif s.units[i].foe == s.units[s.act_unit_i].foe then s.attacks[i] = nil end
  end
 end


 function s.Move(from_i, to_i)
  if not s.moves[to_i] then
   print("ALARM ALARM: destination unreachable!!!")
   return
  end
  local unit = s.units[from_i]
  if not unit then
   print("ALARM ALARM: no unit to move!!!")
   return
  end
  local i = to_i
  local path = {}
  while i ~= from_i do
   table.insert(path, 1, i)
   i = s.moves[i].parent
  end

  i = from_i
  for _, next_i in pairs(path) do
   local event = {name = "unit_moved", from_i = i, to_i = next_i}
   table.insert(s.events, event)
   s.units[i] = nil
   s.units[next_i] = unit
   i = next_i
   unit.ap = unit.ap - 1
   if unit.ap == 0 then break end
  end

  s.act_unit_i = i

  if unit.ap > 0 then
   s.FindMoves()
   s.FindAttacks()
   if not unit.foe then table.insert(s.events, {name = "moves_updated", ap = unit.ap}) end
  else
   s.NextUnit()
  end
 end


 function s.Attack(from_i, to_i)
  if not s.units[from_i] then 
   print("NO ATTACKER FOR ATTACK!")
   return  
  end
  local attacker = s.units[from_i]
  if attacker.kind.summon then
   local kind = KINDS[attacker.kind.summon]
   s.units[to_i] = {
    kind = kind,
    ap = kind.ap,
    hp = kind.hp,
    foe = attacker.foe
   }
   table.insert(s.unit_queue, 2, s.units[to_i])
   table.insert(s.events, {
    name = "summon",
    from_i = from_i,
    to_i = to_i,
    kind = attacker.kind.summon,
    foe = attacker.foe
   })
  else
   if not s.units[to_i] then
    print("NO TARGET FOR ATTACK!")
    return
   end
   s.units[to_i].hp = s.units[to_i].hp - attacker.kind.dmg
   local lethal = (s.units[to_i].hp < 1)
   table.insert(s.events, {
    name = "attack",
    from_i = from_i,
    to_i = to_i,
    ranged = (attacker.kind.dist > 1),
    lethal = lethal
   })
   if lethal then 
    if s.units[to_i].kind.gfx_name == "warlock" then
     print("MISSION COMPLETE! YOU WIN!")
     table.insert(s.events, {name = "end", result = "victory"})
     print("victory detected")
     s.act_unit_i = -1
     return
    end
    for i, body in ipairs(s.unit_queue) do
     if body == s.units[to_i] then
      table.remove(s.unit_queue, i)
      break
     end
    end
    s.units[to_i] = nil
   end
  end
                   
  s.NextUnit()
 end


 function s.IsFoeTurn()
  local act_unit = s.units[s.act_unit_i]
  if act_unit and act_unit.foe then
   return true
  else
   return false
  end
 end


 s.NextUnit()

 return s
end
