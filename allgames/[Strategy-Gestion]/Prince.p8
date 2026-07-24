pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- prince
-- by john adam ziolkowski

-- util

table = "table"
number = "number"
string = "string"
boolean = "boolean"

‹ = 0
‘ = 1
” = 2
ƒ = 3
— = 4
Ž = 5

black = 0
navy = 1
purple = 2
forest = 3
brown = 4
dark = 5
light = 6
white = 7
red = 8
orange = 9
yellow = 10
neon = 11
sky = 12
pale = 13
pink = 14
sand = 15

function rnd_int(min_in, max_in)
 assert(type(min_in)==number)
 assert(flr(min_in)==min_in)
 assert(min_in>0)
 assert(type(max_in)==number)
 assert(flr(max_in)==max_in)
 assert(min_in<=max_in)
 if min_in == max_in then
  return min_in
 end
 int = flr(rnd(1) * (max_in-min_in+1))+min_in
 assert(int <= max_in, int.." "..max_in)
 assert(int >= min_in, int.." "..min_in)
 return int
end

function cap_int(value_in, min_in, max_in)
 assert(type(value_in)==number)
 assert(flr(value_in)==value_in)
 assert(type(min_in)==number)
 assert(flr(min_in)==min_in)
 assert(type(max_in)==number)
 assert(flr(max_in)==max_in)
 
 local value_out = value_in
 if value_out < min_in then
  value_out = min_in
 elseif value_out > max_in then
  value_out = max_in
 end
 assert(value_out >= min_in, value_out)
 assert(value_out <= max_in, value_out)
 return value_out
end

function lget(list, index)
 assert(type(list)==table)
 assert(type(index)==number)
 assert(flr(index)==index)
 assert(index!=0)
 assert(index<=#list, index.." "..#list)
 value = list[index]
 assert(value!=nil, "value is nil "..index)
 return value
end

function lset(list, index, value)
 assert(type(list)==table)
 assert(type(index)==number)
 assert(flr(index)==index)
 assert(index!=0)
 assert(value!=nil, "value is nil")
 list[index] = value
end

function lclr(list)
 assert(type(list)==table)
 assert(#list>0)
 local length = #list
 for i=length,1,-1 do
  local item = list[i]
  del(list,item)
 end
end

function linc(list,item)
 assert(type(list)==table)
 assert(#list>0)
 assert(type(item)!=nil)
 for i=1,#list do
  if list[i] == item then
   return true
  end
 end
 return false
end

function lfnd(list,attribute,value)
 assert(type(list)==table)
 assert(#list>0)
 assert(type(attribute)==string)
 assert(#attribute>0)
 assert(value!=nil)
 
 for i=1,#list do
  local item = lget(list,i)
  if item[attribute] == value then
   return {index=i,item=item}
  end
 end
 assert(false)
end

function lsrt(list,attribute)
 assert(type(list)==table)
 assert(#list>0)
 assert(type(attribute)==string)
	assert(#attribute>0)
	local length = #list
	if length == 1 then
	 return
	end
	local unsorted = {}
	for i=1,#list do
	 local item = lget(list,i)
	 add(unsorted,item)
	end
	assert(#unsorted==length)
	for i=1,#unsorted do
	 local item = lget(list,1)
	 del(list,item)
	end
	assert(#list==0)
	for s=1,length do
 	local lowest_v
 	local lowest_item
  for u=1,#unsorted do
   local item = lget(unsorted,u)
   local value = item[attribute]
   assert(value)
   if not lowest_v or value < lowest_v then
    lowest_v = value
    lowest_item = item
   end
  end
  add(list,lowest_item)
  del(unsorted,lowest_item)
 end
end

function split(str,sep,cast)
 assert(type(str)==string)
 assert(#str>0)
 assert(type(sep)==string)
 assert(#sep>0)
 local list = {}
 local start = 0
 for c=1,#str+1 do
  local char = sub(str,c,c)
  if char == sep or c==#str+1 then
   local item = sub(str,start,c-1)
   assert(#item>0)
   if cast == number then
    item = strtoint(item)
   elseif cast == boolean then
    item = str_to_boolean(item)
   end
   add(list,item)
   start = c+1
  end
 end
 assert(#list>0)
 return list
end

function inttobin(b)
 local t={}
 local a=0
 for i = 0,4 do
  a=2^i
  t[i+1]=band(a,b)/a
 end
 return t
end

function get_chars(sheet)
	assert(type(sheet)==table)
 sheet.s2c={}
 sheet.c2s={}
 for i=1,#sheet.chars do
  local c=i-2
  local s=sub(sheet.chars,i,i)
  sheet.c2s[c]=s
  sheet.s2c[s]=c
 end
end

function ord(sheet, s, i)
 assert(type(sheet)==table)
 assert(type(s)==string)
 assert(type(i)==number)
 local ci = sheet.s2c[sub(s,i or 1,i or 1)]
 assert(ci, s..".."..i)
 return ci
end

function str_to_boolean(str)
 assert(type(str)==string)
 assert(#str>0)
 if str=="true" then
  return true
 elseif str=="false" then
  return false
 end
 assert(false)
end

function strtoint(str)
 assert(type(str)==string)
 assert(#str>0)
 local sheet = {
  chars="0123456789"
 }
 get_chars(sheet)
 
 local value = 0
 local multiplier = 1
 for ci=#str,1,-1 do
  local cv = ord(sheet,str,ci)+1
  assert(type(cv)==number)
  value += cv * multiplier
  multiplier *= 10
 end
 return value
end

function get_state()
 assert(#states_stack>0)
 return lget(states_stack, #states_stack)
end

function set_state(state)
 assert(type(state)==table)
 local index = 1
 if #states_stack > index then
  index = #states_stack
 end
 lset(states_stack, index, state)
 if state.init then
  state.init()
 end
 message = nil
 set_stale()
end

function push_state(state)
 assert(type(state)==table)
 add(states_stack, state)
 if state.init then
  state.init()
 end
 message = nil
 set_stale()
end

function pop_state()
 local prev_state = get_state()
 if prev_state.finish then
  prev_state.finish()
 end
 message = nil
 del(states_stack, prev_state)
 set_stale()
end

-->8
-- init

version="v1.1"
date="18.08.12"

function _init()
 clear = dark
 cls(clear)
 palt(black, false)
 palt(pale, true)

 set_up_settings()
 set_up_elements()
 set_up_arena()
 set_up_party()
 init_states()
 set_state(states.arena)
 push_state(states.intro)
 push_state(states.title)
end

function init_states()
states = {

 title={name="^title",
        update=update_title,
        draw=draw_title},
        
 credits={name="^credits",
        update=update_credits,
        draw=draw_credits},
        
 tips={name="^tips",
        update=update_tips,
        draw=draw_tips},

 intro={name="^intro",
        init=init_intro,
        update=update_intro,
        draw=draw_arena_state},

 arena={name="^arena",
        init=init_arena,
        update=update_arena,
        draw=draw_arena_state},
        
 settings={name="^settings",
        init=init_settings,
        update=update_settings,
        draw=draw_settings},
        
 camp={name="^camp",
        init=init_camp,
        update=update_camp,
        draw=draw_camp},
        
 element_chart={name="^element ^chart",
        init=init_element_chart,
        update=update_element_chart,
        draw=draw_element_chart},
        
 attacking={name="^attacking",
        init=init_attack,
        update=update_attack,
        draw=draw_arena_state},
        
 battle_over={name="^battle ^over",
        init=init_battle_over,
        update=update_battle_over,
        draw=draw_arena_state},
        
 game_over={name="^game ^over",
        init=init_game_over,
        update=update_game_over,
        draw=draw_arena_state},
}
states_stack={}
end

settings_string = "^auto ^turn|^off,^on|boolean|false,true|1/^text ^delay|^1,^5,^1^0,^1^5|number|1,5,10,15|3/^draw stats|^off,^on|boolean|false,true|1"
settings_split = split(settings_string,"/")
settings = {}
for ss=1,#settings_split do
 local setting_string = lget(settings_split,ss)
 local setting_split = split(setting_string,"|")
 local types = lget(setting_split,3)
 local values = split(lget(setting_split,4),",",types)
 local setting = {
  n=lget(setting_split,1),
  o=split(lget(setting_split,2),","),
  v=values,
  s=strtoint(lget(setting_split,5))
 }
 add(settings, setting)
end

function set_up_settings()
 auto = set_up_setting(1)
 delay = set_up_setting(2)
 penalty = 1
 stats = set_up_setting(3)
end
function set_up_setting(index)
 local setting = lget(settings,index)
 local options = setting.v
 local selected = lget(options,setting.s)
 return selected
end

function set_up_elements()
 for i=2,12 do
  local element = lget(elements,i)
  element.count = 0
  element.party = 0
 end
 
 unlocked_elements = {}
 for i=1,1 do
  local element = lget(elements,i)
  add(unlocked_elements,element)
  if element.i != 1 then
   element.count = 1
  end
 end
end

step = 4

prince = 22
fighter = 25
caster = 28

function is_in_line(enemy_id, base_id)
 if enemy_id == base_id
  or enemy_id == base_id + 1
   or enemy_id == base_id + 2 then
  return true  
 end
end

function is_fighter(enemy_id)
 return is_in_line(enemy_id, fighter)
end

function is_caster(enemy_id)
 return is_in_line(enemy_id, caster)
end

function is_prince(enemy_id)
 return is_in_line(enemy_id, prince)
end

function get_element(eni)
 local en_el_c=lget(enemy.stats,eni).e
 for element in all(elements) do
  if sub(element.n, 1, 1) == en_el_c then
   return element
  end
 end
 assert(false, "unknown element:"..eni)
end

function element_by_n(n)
 assert(type(n)==string)
 for element in all(elements) do
	 if n == sub(element.n, 1, 1) then
	  return element
	 end
	end
	assert(false, "unknown element: "..n)
end

elements = {                 //nfawreipbldh
 {i=1, n="none", c=dark,    o="444444444332"},

 {i=2, n="fire", c=orange,  o="424843663342"},
 {i=3, n="air", c=sand,     o="442483366342"},
 {i=4, n="water", c=navy,   o="484246336432"},
 {i=5, n="rock", c=brown,   o="448426633432"},

 {i=6, n="elec", c=yellow,  o="433662484342"},
 {i=7, n="ice", c=sky,      o="463364248342"},
 {i=8, n="plant", c=forest, o="466338424432"},
 {i=9, n="blood", c=red,    o="436634842432"},

 {i=10, n="light", c=light, o="644664466283"},
 {i=11, n="dark", c=purple, o="666446644823"},

 {i=12, n="holy", c=pink,   o="888888888664"},

 {i=13, n="variable", c=neon}
}

wide = {
 chars = " abcdefghijklmnopqrstuvwxyz0123456789.,!?:'+-*/(){}[]>",
 x = 0,
 y = 0,
 tw = 5,
 th = 5,
 layers = 4
}
get_chars(wide)

slim = {
 chars = " abcdefghijklmnopqrstuvwxyz0123456789.,!?:'+-*/()",
	x = 0,
	y = 5,
 tw = 3,
 th = 5,
 layers = 4
}
get_chars(slim)

enemy = {
 x = 0,
	y = 10,
 tw = 16,
 th = 12,
 layers = 2,
 str = '^bunny,n,1|^rabbit,n,3|^bunny ^girl,n,5|^horse,n,2|^unicorn,n,4|^centaur,n,6|^ghost,n,1|^poltergeist,n,4|^zombie,n,2|^ghoul,n,5|^skeleton,n,3|^skull ^army,n,6|^floating^eye,n,1|^eye ^beast,n,4|^willowisp,n,2|^giant ^skull,n,5|^sadness,n,3|^madness,n,7|^man,n,0|^woman,n,0|^child,n,0|^prince,v,6|^king,v,8|^emperor,v,10|^fighter,v,7|^general,v,9|^giant,v,11|^caster,v,8|^sorceror,v,10|^merlin,v,12|^lizard,f,2|^dragon,f,4|^drako,f,6|^snake,e,3|^cobra,e,5|^lamia,e,7|^bird,a,2|^crow,a,4|^harpy,a,6|^sap,p,3|^slime,p,5|^jelly ^girl,p,7|^fish,w,2|^shark,w,4|^mermaid,w,6|^mouse,i,3|^rat,i,5|^mouse^prince,i,7|^turtle,r,2|^tortise,r,4|^kapa,r,6|^bat,b,3|^vampire ^bat,b,5|^vampire,b,7|^cat,l,4|^lion,l,6|^cat ^girl,l,8|^dog,d,4|^wolf,d,6|^werewolf,d,8|^slug,h,5|^snail,h,7|^hermit,h,9|^mist,n,7|^blarg,n,8|^rude ^demon,n,9|^living^sword,n,11|^mimic,n,10|^embers,f,8|^phoenix,f,10|^bolt ^rider,e,9|^android,e,11|^wind ^rider,a,8|^marionette,a,10|^evil ^weed,p,9|^evil ^tree,p,11|^rain ^rider,w,8|^hydra,w,10|^snow ^rider,i,9|^polar ^bear,i,11|^mushroom,r,8|^golem,r,10|^death,b,9|^haunted^tree,b,11|^cactus,l,10|^mummy,l,12|^dark ^hand,d,10|^dark ^mouth,d,12|^priest,h,11|^angel,h,13|^elder^dragon,f,12|^blade^master,e,13|^puppeteer,a,12|^venus ^trap,p,13|^kraken,w,12|^frozen^mimic,i,13|^raging ^dino,r,12|^vampiress,b,13|^sphinx,l,14|^hatman,d,14|^bishop,h,15|^final^bishop,h,16'
}
enemy.stats = split(enemy.str,"|")
for e=1,#enemy.stats do
 local e_str = lget(enemy.stats,e)
 local e_split = split(e_str,",")
 local e_stats = {
  i=e,
  n=lget(e_split,1),
  e=lget(e_split,2),
  l=strtoint(lget(e_split,3))
 }
 lset(enemy.stats,e,e_stats)
end

boss_sets_string = "16,90,90,102,90,90/14,55,86,99,57,56/12,31,32,91,33,32/14,87,88,100,88,87/12,74,74,93,74,74/12,82,82,97,82,82/13,68,48,96,47,68/13,52,54,98,83,53/15,89,89,101,89,89/13,35,72,92,36,34/13,76,75,94,75,76/12,44,78,95,45,43"

boss_sets = {}
boss_sets_split = split(boss_sets_string, "/")

for bs=1,#boss_sets_split do
 local boss_set_string = lget(boss_sets_split, bs)
 local boss_set_split = split(boss_set_string,",",number)
 local boss_set_level = lget(boss_set_split,1)
 del(boss_set_split, boss_set_level)
 local boss_set = {
  l=boss_set_level,
  i=boss_set_split
 }
 add(boss_sets, boss_set)
end

levels = {}
level = 0
for i=1,16 do
 if i < 3 then
  level += i*2
 elseif i < 5 then
  level += i*3
 elseif i < 8 then
  level += i*4
 else
  level += i*5
 end
 add(levels,level)
end
level = nil

member_join_levels = {2,4,6,8}

enemies_by_level = {}
for l=1,#levels do
 lset(enemies_by_level,l,{})
end
for e in all(enemy.stats) do
 local l = e.l
 if l != 0 then
  //skip man, woman, child
  if e.i < 91 then
   //skip bosses
  	add(lget(enemies_by_level,l),e)
  end
 end
end

function set_up_enemy(s, id)
 e = lget(enemy.stats,id).e
 if e == "v" then
  //humans get random element
  local enemy_l = lget(enemy.stats,id).l
  local element_i
  if id == prince
   or id == fighter
    or id == caster then
   element_i = rnd_int(2,5)
  elseif id == prince+1
   or id == fighter+1
    or id == caster+1 then
   element_i = rnd_int(6,9)
  elseif id == prince+2
   or id == fighter+2
    or id == caster+2 then
   element_i = rnd_int(10,11)
  end
  assert(element_i)
  local element_n = sub(lget(elements,element_i).n,1,1)
  e = element_n
 end
 local n = lget(enemy.stats,id).n
 local l = lget(enemy.stats,id).l
	local enemy = {
	 s = s,
		i = id,
		x = 16 + ((s-1) % 2) * 12,
		sx = 0,
		y = (s-1) * 14 + 13,
		e = e,
		n = n,
		l = l
	}
	add(enemies, enemy)
end

function set_up_enemies()
 enemies.dead = {}
 local l = 1
 if level then
  l = level
 end

 local boss_set
 local bosses_at_level = {}
 for s=1,#boss_sets do
  local set = lget(boss_sets,s)
  local set_boss_level = set.l
 
  if l == set_boss_level then
   add(bosses_at_level,set)
  end
 end
 
 if #bosses_at_level > 0 then
  local b = rnd_int(1,#bosses_at_level)
  boss_set = lget(bosses_at_level,b)
 end
  
 if boss_set then
  set_up_boss(boss_set)
 	return
 end

 for s=1,5 do
  if rnd(1) < 0.05*#party+level/32 then
   local id
   local e
   if l > #enemies_by_level then l = #enemies_by_level end
   local enemies_at_level = lget(enemies_by_level,l)
   local e_l = rnd_int(1,#enemies_at_level)
   local enemy = lget(enemies_at_level,e_l)
   id = enemy.i
   set_up_enemy(s, id)
  end
 end
 if #enemies == 0 then
  set_up_enemies()
 end
end

function set_up_boss(boss_set)
 assert(boss_set)

	//populate enemies
 for s=1,5 do
  local id = lget(boss_set.i,s)
  set_up_enemy(s,id)
	end
end

function set_up_member(available)
 local id
 local s
 if #party == 0 then
  id = prince
  s = 3
 else
  if #available==0 then return end
  
  local a = rnd_int(1,#available)
	 s = lget(available,a)
	 id = rnd_int(1,2)
  if id == 1 then
   id = fighter
  else
   id = caster
  end
	end
	if id != nil then
 	local member = {
 	 s = s,
 		i = id,
 		x = 96 - ((s-1) % 2) * 12,
 		sx = 0,
 		y = (s-1) * 14 + 13,
 		e = "n",
 	 n = lget(enemy.stats,id).n
 	}
 	add(party, member)
 	lsrt(party,"s")
	end
end

function set_up_party()
 set_up_member(3, {})
 
 score = 0
 battles = 0
 level = 1
 luck = 0
 setbacks = 0
 party.dead = {}
 
 turn = party
 cur = {l=party, i=1, s=nil}
end

function set_up_arena()
 party = {}
 enemies = {}
end

function init_intro()
 intro_ticks = 0
end

function init_auto_turn()
 auto_ticks = 0
end

function init_battle_over()
 over_ticks = 0
end

function init_game_over()
 game_over_ticks = 0
end

function init_element_chart()
 e_cur = {e=1}
end

function init_settings()
 s_cur = {s=#settings+1, o=1}
 for s=1,#settings do
  setting = lget(settings,s)
  setting.c = setting.s
 end
end

function init_camp()
 turn = party
 cur.l = party
 revive()
 find_new_member()
 cur.i = lfnd(party,"i",prince).index
end

function find_new_member()
 local appears
 for l=1,#member_join_levels do
  local mjl = lget(member_join_levels,l)
  if mjl==level and #party<l+1 then
   appears = true
  end
 end
 if not appears then return end
 
 local available = {}
 for s=1,5 do
  local found
  for p=1,#party do
   local member = lget(party,p)
   if member.s == s then
    found = true
   end
  end
  if not found then
   add(available,s)
  end
 end
 set_up_member(available)
end

function init_attack()
 attack_ticks = 0
 
 attacker = lget(turn,cur.s.i)
 attacker_n = attacker.n
 assert(attacker)
 targets = {}
 main_target = {t=lget(opposition(turn),cur.i)}
 main_target_n = main_target.t.n
 add(targets, main_target)
 
 if is_caster(attacker.i) then
  for p_target in all(opposition(turn)) do
   if p_target.s == main_target.t.s +1 or
    p_target.s == main_target.t.s -1 then
    add(targets, {t=p_target})
   end
  end
 end
 
 for target in all(targets) do
 	assert(target)
	
  local hit
  local chance = get_hit_chance(attacker, target)
  hit = rnd(1) < chance
  
  if is_prince(attacker.i) then
   if hit and turn==party then
    local old_element = element_by_n(attacker.e)
    local new_element = element_by_n(target.t.e)     
    take_element(old_element, new_element)
   end
  end
  
  if turn == party then
   if chance > 0.5 and not hit then
    luck -= chance-0.5
   elseif chance < 0.5 and hit then
    luck += 0.5-chance
   end
  else
   if chance < 0.5 and hit then
    luck -= 0.5-chance
   elseif chance > 0.5 and not hit then
    luck += chance-0.5
   end
  end
  target.h = hit
 end
end
-->8
-- update

function _update()
 local state = get_state()
 if state.update then
  state.update()
 end
end

function move_element_chart(d)
 e_cur.e += d
 e_cur.e = cap_int(e_cur.e,1,#elements-1)
 set_stale()
end

function show_element_chance(mode)
 if e_cur.o != mode then
  e_cur.o = mode
 else
  e_cur.o = nil
 end
 set_stale()
end

function update_title()
 if btnp(Ž) then
  pop_state()
 elseif btnp(‘) then
  push_state(states.credits)
 elseif btnp(‹) then
  push_state(states.tips)
 end
end

function update_credits()
 if btnp(—) or btnp(Ž) then
  pop_state()
 end
end

function update_tips()
 if btnp(—) or btnp(Ž) then
  pop_state()
 end
end

function update_element_chart()
 if btnp(Ž) or btnp(—) then
  pop_state()
 
 elseif btnp(”) then
  move_element_chart(-1)
  
 elseif btnp(ƒ) then
  move_element_chart(1)
  
 elseif btn(‹) then
  show_element_chance("attacking")
 elseif btn(‘) then
  show_element_chance("dodging")
 end
end

function update_arena()

 if turn == party then
  if not auto then
   if btnp(‹) then
    push_state(states.element_chart)
   elseif btnp(‘) then
    push_state(states.settings)
   elseif btnp(”) then
    move_cursor(-1)
   elseif btnp(ƒ) then
    move_cursor(1)
   elseif btnp(Ž) then
    select()
   elseif btnp(—) then
    deselect()
  	end
  else
   if btnp(—) then
    finish_auto_turn()
   else
    update_auto_turn()
   end
  end
 elseif turn == enemies then
  update_auto_turn()
 end
end

function update_settings()
 if btnp(—) then
  pop_state()
 elseif btnp(Ž) then
  save_settings()
 elseif btnp(‹) then
  change_options(-1)
 elseif btnp(‘) then
  change_options(1)
 elseif btnp(”) then
  change_settings(-1)
 elseif  btnp(ƒ) then
  change_settings(1)
 end
end

function update_camp()
 if game_complete then return end
 
 if not auto then
  if btnp(Ž) then
   pop_state()
  elseif btnp(—) then
   push_state(states.element_chart)
  elseif btnp(‹) then
   change_element(lget(party,cur.i))
  elseif btnp(‘) then
   change_class(lget(party,cur.i))
  elseif btnp(”) then
   move_cursor(-1)
  elseif btnp(ƒ) then
   move_cursor(1)
  end
 else
  auto_camp()
  pop_state()
 end
end

function update_attack()
 
 attack_ticks += 1
 
 if attack_ticks == 1 then
  
  if turn == party then
   attacker.sx = -step
  else
   attacker.sx = step
  end
  
  for t=1,#targets do
   local target = lget(targets,t)
   
   if is_fighter(attacker.i) then
    add_anim(fighter_anim,attacker.e,target.t.x,target.t.y, turn)
   elseif is_caster(attacker.i) then
    add_anim(caster_anim,attacker.e,target.t.x,target.t.y, turn)
   else
    add_anim(attack_anim,attacker.e,target.t.x,target.t.y, turn)
   end
   
   if target.h and is_prince(attacker.i) then
    //prince changes element
    attacker.e = target.t.e
   end  
   
   if not target.h then
    if turn == party then
     target.t.sx = -step
    else
     target.t.sx = step
    end
   end
  end
  
  local name = main_target_n
  if #targets > 1 then
   name = #targets.." targets"
  end
  message = attacker_n.." attacks "..name
  set_stale()
 elseif attack_ticks == 3*delay then
  
  cur.s = nil
  
  local text = "^but it missed!"
  if #targets==1 then
   if lget(targets,1).h then
    text = "^hit! "..main_target_n.." is gone"
    eliminate(opposition(turn), main_target.t)
   end
  else
   local miss_count=0
   local hit_count=0
   local all_count=0
   for target in all(targets) do
    all_count +=1
    if target.h then
     hit_count += 1
     eliminate(opposition(turn), target.t)
    else
     miss_count += 1
    end
   end
   if miss_count == all_count then
    text = "^magic missed all "..all_count.." targets"
   elseif hit_count == all_count then
    text = "^magic hit all "..all_count.." targets"
   else
    text = "^magic hit "..hit_count.." of "..all_count.." targets"
   end
  end
 
  message = text
  set_stale()

 elseif attack_ticks == 6*delay then
  cur.s = nil
  attack_ticks = nil
  
  attacker.sx = 0
  
  attacker = nil
  attacker_n = nil
  
  chance = nil
  main_target = nil
  main_target_n = nil
  
  for t=1,#targets do
   local target = lget(targets,t)
   if target then
    target.t.sx = 0
   end
  end
  
  targets = nil
  
  toggle_turn()
  pop_state()
  check_over()
 end
end

function draw_auto_message()
 if turn == party then
  message = "^press (^b) to end auto"
  set_stale()
 end
end

function update_auto_turn()
 if auto_ticks == nil then
  auto_ticks = 0
 end
 auto_ticks += 1
 if auto_ticks == 1 then
  draw_auto_message()
 elseif auto_ticks == 2*delay then
  random_cursor()
  draw_auto_message()
 elseif auto_ticks == 4*delay then
  select()
  draw_auto_message()
 elseif auto_ticks == 6*delay then
  random_cursor()
  draw_auto_message()
 elseif auto_ticks == 8*delay then
  select()
  auto_ticks = nil
 end
end

function update_battle_over()
 over_ticks += 1
 
 if over_ticks == 2*delay then
  set_stale()
  message = "^no more enemies remain!"
 elseif over_ticks == 5*delay then
  set_stale()
  battles += 1
  local s = ""
  if battles > 1 then s = "s" end
  message = "^finished "..battles.." battle"..s
 elseif over_ticks == 10*delay then
  set_stale()
  message = "^total exp: "..score
 elseif over_ticks == 15*delay then
  local next_level = lget(levels,level)
 	if score >= next_level and
 	 level < #levels then
 	 level += 1
 	 if level > #levels then
 	  level = #levels
 	 end
   did_level = true
   revive()
   text = "^level up!! ^now at "..level 
  else
   text = "^currnent level: "..level 
  end
  set_stale()
  message = text
 
 elseif over_ticks == 20*delay then
  if did_level or game_complete then
   push_state(states.camp)
   did_level = false
  end
 elseif over_ticks == 21*delay then
  set_up_enemies()
  turn = party
  cur.l = party
  cap_cursor()
  text = "^new enemies"
  if #enemies == 1 then
   text = "^single "..lget(enemies,1).n
  end
  message = text.." appeared!"
  set_stale()
 elseif over_ticks == 23*delay then
  over_ticks = nil
  pop_state()
 end
end

function update_game_over()
 game_over_ticks += 1
 
 if game_over_ticks == 2*delay then
  message = "^your entire party is down!"
  set_stale()
 elseif game_over_ticks == 5*delay then
  local s = "s"
  if battles == 1 then s = "" end
  message = "^finished "..battles.." battle"..s
 	set_stale()
 elseif game_over_ticks == 10*delay then
  
  message = "^final level: "..level
 elseif game_over_ticks == 15*delay then
  lclr(enemies)
  if #enemies.dead>0 then 
   lclr(enemies.dead)
  end
  revive()
 	
  turn = party
  cur = {l=party, i=1, s=nil}
 	cap_cursor()
 	old_level = level
 	level = 1
 	score = 0
 	setbacks += 1
 	if old_level > penalty then
 	 level = old_level-penalty
 	 score = lget(levels,level)
 	end
 	message = "^the party is set back to "..level.."..."
 	set_stale()
 elseif game_over_ticks == 18*delay then
  push_state(states.camp)
 
 elseif game_over_ticks == 21*delay then
  message = "^new enemies appear!"
  set_up_enemies()
  set_stale()
 
 elseif game_over_ticks == 24*delay then
  game_over_ticks = nil
  pop_state()
 end
end

function update_intro()
 intro_ticks += 1
 
 if intro_ticks == 2*delay then
  set_stale()
  message = "^a new journey begins"
 
 elseif intro_ticks == 5*delay then
  set_stale()
  push_state(states.camp)
 
 elseif intro_ticks == 8*delay then
  set_up_enemies()
  text = "^new enemies"
  if #enemies == 1 then
   text = "^single "..lget(enemies,1).n
  end
  message = text.." appeared!"
  set_stale()
  
 elseif intro_ticks == 13*delay then
  intro_ticks = nil
  pop_state()
 end
end
-->8
-- draw

function _draw()
 if stale then
  cls(clear)
  local state = get_state()
  if state.draw then
   state.draw()
   stale = false
  end
  if stats then
   draw_stats()
  end
 end
 draw_animations()
end

function draw_arena()

 if message then
  note(message)
 end
 
 //draw stones
 for x = 0,15 do
  spr(192, x*8, 0)
 end
 draw_enemies()
 draw_party()
 line(0,90,128,90,black)
 draw_options()
end

function draw_element_chart()
 
 local cur_element = lget(elements,e_cur.e)
 
 local chart = 
 {{x=-3, y=-1},//none
 
  {x= 0, y=-2},//fire
  {x= 2, y= 0},//air
  {x= 0, y= 2},//water
  {x=-2, y= 0},//earth
  
  {x= 1, y=-1},//elec
  {x= 1, y= 1},//ice
  {x=-1, y= 1},//plant
  {x=-1, y=-1},//blood
  
  {x= 3, y=-1},//light
  {x= 3, y= 1},//dark
  {x=-3, y= 1}}//holy
 
 local chart_x = 80
 local chart_y = 32

 local line_x = chart_x+2
 local line_y = chart_y+2
 
 line(line_x, line_y-15, line_x, line_y+15, purple)
 line(line_x-15, line_y, line_x+15, line_y, purple)
 
 line(line_x-6, line_y-6, line_x+6, line_y+6, purple)
 line(line_x-6, line_y+6, line_x+6, line_y-6, purple)
 
 line(line_x+30, line_y+6, line_x+30, line_y-6, purple)

 line(line_x, line_y-15, line_x, line_y, light)
 line(line_x, line_y, line_x+15, line_y, light)
 
 line(line_x, line_y, line_x+6, line_y+6, light)
 line(line_x, line_y, line_x+6, line_y-6, light)
 
 line(line_x+30, line_y, line_x+30, line_y-6, light)

 print("^elements",2,2,black)
 print("^opposition ^chart",49,2,black)
 for e=1,#elements-1 do
  local col_1 = black
  local col_2 = nil
  if e_cur.e == e then
   col_1 = white
   col_2 = black
  end
  local element = lget(elements,e)
  local e_n_c = sub(element.n,1,1)
  print("^@"..e_n_c.."^"..element.n, 4, 2+e*7, col_1, col_2)
  
  //draw chart
  local offset = lget(chart,e)

  print("^@"..e_n_c, chart_x+offset.x*10, chart_y+offset.y*10, col_1, col_2)
  
  if e_cur.o == "dodging" then
  	local t_e_i = cur_element.i
			local multiplier_char = sub(element.o, t_e_i, t_e_i)
   print(multiplier_char, chart_x+offset.x*10+7, chart_y+offset.y*10, white, black)
  
  elseif e_cur.o == "attacking" then
	  local t_e_i = element.i
			local multiplier_char = sub(cur_element.o, t_e_i, t_e_i)
   print(multiplier_char, chart_x+offset.x*10-5, chart_y+offset.y*10, white, black)
  end
 end

 print("^inspect ^hit ^chances:",42,66,black)
 print("^u/^d:select element",48,73,black)
 print("^l:^:  ^r:^-",64,80,black)
 
 print("^opposing elements hurt enemies",2,94,black)
 print("more often. ^same elements will",2,100,black)
 print("rarely hit. ^choose target well!",2,106,black)
 print("^none has no bonus or weakness.",2,114,black)
 print("^holy is good against all!",2,120,black)
end

function draw_settings()
 
 print("^settings",2,2,black)
 local bc=nil
 local fc=black
 if s_cur.s == #settings+1 and
  s_cur.o == 1 then
  bc=black
  fc=white
 end
 print("^cancel",50,120,fc,bc)
 bc=nil
 fc=black
 if s_cur.s == #settings+1 and
  s_cur.o == 2 then
  bc=black
  fc=white
 end
 print("^accept",86,120,fc,bc)
 
 for s=1,#settings do
  local setting = lget(settings,s)
  bc=nil
  fc=black
  if s_cur.s == s then
   bc=black
   fc=white
  end
  print(setting.n..":",2,s*7+2,fc,bc)
  
  for o=1,#setting.o do
   local option = lget(setting.o,o)
   bc=nil
   fc=black
   if setting.c == o then
    bc=black
    fc=white
   end
   print(option,20*(o-1)+54,s*7+2,fc,bc)
  end
 end
end

function draw_camp()
 draw_party()
 draw_options()
 spr(210, 72, 44)
 spr(194, 72, 36)
 
 print("^learned ^elements",2,2)
 for e=1,#unlocked_elements do
  local element = lget(unlocked_elements,e)
  local e_n_c = sub(element.n,1,1)
  local y = 4+e*6
  print("^@"..e_n_c.."^"..element.n, 4, y) 
  if element.i != 1 then
   print("x"..element.count, 40, y)
   print("p"..element.party, 54, y)
  end
 end
 
 print("^party ^l:"..level,83,2)

	if game_complete then
  note("^the journey is complete.")
		print("^congratulations!",2,93)
		print("   ^battles: "..battles,2,100)
		print("^experience: "..score,2,107)
  print("  ^setbacks: "..setbacks,2,114)
		print("^total luck: "..luck,2,121)
	
	else
	 note("^get the party ready to go")

  if #unlocked_elements > 1 then
   print("^l:^change element",2,95)
  end
  if not is_prince(lget(party, cur.i).i) then
   print("^r:^change class",2,103)
  end
  print("^b:^element chart",2,111)
  print("^a:^finish",2,119, white, black)
	end
end

function draw_arena_state()
 draw_arena()
 draw_options()
 if message then
  note(message)
 end
end

function draw_title()
 draw_logo(20,16)

 print("-^mini ^arena ^r^p^g-",29,40)
 print("by ^john ^adam ^ziolkowski",18,52)
 print("with ^pico-8",42,60)

 print("^l:^view ^game ^tips",30,80)
 print("^r:^view ^game ^info",30,90)
 print("^a:^start ^new ^game",30,100,white,black) 

end

function draw_logo(x,y)
 render(enemy,prince-1,x+24,y+1,clear,black,clear,white,true)
 render(enemy,fighter-1,x+36,y+1,clear,black,clear,white,true)
 render(enemy,caster-1,x+49,y+1,clear,black,clear,white,true)
 
 print("^p^r^i^n^c^e",x+28,y+14,white,black)
end

function draw_credits()
 draw_logo(0,1)
 print(version,90,6)
 print(date,90,14)
 
 lines = {
  "^by ^john ^adam ^ziolkowski",
  "^git^hub: ^john^adam^ziolkowski",
  "",
  "^special thanks to:",
  " ^,^sami ^gray",
  " ^{^rowan ^sheppard",
  " ^*^laura ^cole",
  "",
  "^made for ^pico-8 with one cart.",
  "^open source on repo '^prince'.",
  "^take my util functions, and use",
  "them for your game! ^very handy!",
  "",
  "^pico-8 info: www.lexaloffle.com",
 }

 for l=1,#lines do
  print(lget(lines,l),2,18+7*l)
 end 
end

function draw_tips()
 draw_logo(20,0)
 
 print("^tips:",8,12)
 
 lines = {
  "-^arena battles, win to cont.",
  "-^no ^h^p, all go down in one hit",
  " (try to take the best chances)",
  "-^more team members join later",
  "-^:^fighter hits 2x more often",
  "-^*^caster can target 3 enemies",
  "-^.^prince steals ^{elements",
  "-^l:^view elements in battle",
  "-^r:^change settings in battle",
  "-^can change party at campfire",
  "  (on level up or set back)",
  "-^don't give up! ^set back gives",
  " you a chance to take ^{elements",
  "-^final fight is at level 16.",
  "-^you can do this! ^good luck!!!",
 }

 for l=1,#lines do
  print(lget(lines,l),2,15+7*l)
 end 
end
-->8
-- logic

function check_over()
 if #enemies == 0 then
  push_state(states.battle_over)
 elseif #party == 0 then
  game_complete = false
  push_state(states.game_over)
 end
end

function opposition(list)
 //returns the opposing list
 if list == enemies then
  return party
 else
  return enemies
 end
end

function toggle_turn()
 if turn == party then
  turn = enemies
  init_auto_turn()
 else
  turn = party
  if auto then
   init_auto_turn()
  end
 end
 cap_cursor()
end

function select()
  
 if cur.l == turn then
  // select attacker
  cur.s = {l=cur.l, i=cur.i}
  toggle_cursor()
  set_stale()
 
 else
  // attack target
  push_state(states.attacking)
 end
end

function deselect()
 if cur.s then
  cur.i = cur.s.i
  cur.s = nil
  toggle_cursor()
  set_stale()
 end
end

function toggle_cursor()
 cur.l = opposition(cur.l)
 cap_cursor()
end

function move_cursor(d) 
 cur.i += d
 cap_cursor()
 set_stale()
end

function random_cursor()
 cur.i = rnd_int(1, #cur.l)
 set_stale()
end

function cap_cursor()
 if #cur.l > 0 then
  cur.i = cap_int(cur.i, 1, #cur.l)
 end
end

function get_hit_chance(attacker, target)
 if not attacker then return end
 if not target then return end
 if not target.t then return end

	local attack_element = element_by_n(attacker.e)
	local target_element = element_by_n(target.t.e)
	local t_e_i = target_element.i
	local multiplier_char = sub(attack_element.o, t_e_i, t_e_i)
	local chance
	
	if multiplier_char == "2" then
	 chance = 0.25
	elseif multiplier_char == "3" then
	 chance = 0.375  
	elseif multiplier_char == "4" then
	 chance = 0.5
	elseif multiplier_char == "6" then
	 chance = 0.625
	elseif multiplier_char == "8" then
	 chance = 0.75
	else
	 assert(false, chance)
	end
 
 if is_fighter(attacker.i) then
  chance = 1-((1-chance) * (1-chance))
 end
 
 return chance
end

function eliminate(list, target)
 if list == enemies then
  score += target.l
 end
 add(list.dead, target)
 del(list, target)
 if target.i == 102 then
  game_complete = true
 end
end

function take_element(old_element, new_element)
 assert(linc(elements, old_element))
 assert(linc(elements, new_element))
 
 if not linc(unlocked_elements, new_element) then
  //unlocks new element for later
  add(unlocked_elements, new_element)
  lsrt(unlocked_elements, "i")
 end
 
 //store old element
 if old_element.i != 1 then
  old_element.count += 1
		old_element.party -= 1
  if old_element.count + old_element.party > 9 then
   old_element.count = 9 - old_element.party
  end
 end
 
 //update party count
 if new_element.i != 1 then
  new_element.party += 1
  if new_element.count + new_element.party > 9 then
   new_element.count = 9 - new_element.party
  end
 end
end

function revive()
 for member in all(party.dead) do
  add(party, member)
  del(party.dead, member)
 end
 lsrt(party,"s")
end

function change_element(member)
 local member_element_index_in_unlocked
 local member_element
 for u=1,#unlocked_elements do
  local element = lget(unlocked_elements,u)
  local element_n = sub(element.n,1,1)
  if element_n == member.e then
   member_element = element
   member_element_index_in_unlocked = u
  end
 end
 assert(member_element_index_in_unlocked)
 if member_element.i != 1 then
  member_element.count += 1
  member_element.party -= 1
 end
 
 local found = false
 local new_element
 for u=1,#unlocked_elements do
  if not found then
   member_element_index_in_unlocked += 1
   if member_element_index_in_unlocked > # unlocked_elements then
    member_element_index_in_unlocked = 1
   end
   new_element = lget(unlocked_elements,member_element_index_in_unlocked)
   if new_element.i == 1
   or new_element.count > 0 then
    found = true
   end
  end
 end
  
 if new_element.i != 1 then
  new_element.count -= 1
  new_element.party += 1
 end
 
 member.e = sub(new_element.n,1,1)
 set_stale()
end

function change_class(member)
 if is_fighter(member.i) then
  member.i = caster
 elseif is_caster(member.i) then
  member.i = fighter
 end
 member.n = lget(enemy.stats,member.i).n
 set_stale()
end

function change_settings(d)
 s_cur.s += d
 s_cur.s = cap_int(s_cur.s, 1, #settings+1)
 if s_cur.s > #settings then
  s_cur.o = 1
 else
  s_cur.o = lget(settings,s_cur.s).s
 end
	set_stale()
end

function change_options(d)
 s_cur.o += d
 if s_cur.s > #settings then
 s_cur.o = cap_int(s_cur.o, 1, 2)
 else
  setting = lget(settings, s_cur.s)
  options = setting.o
  s_cur.o = cap_int(s_cur.o, 1, #options)
		setting.c = s_cur.o
	end
	set_stale()
end

function auto_camp()
 for p=1,#party do
  cur.i = p
  if rnd(1) > 0.5 then
   change_class(lget(party,cur.i))
  end
  for u=1,#unlocked_elements do
   if lget(party,cur.i).e != "n" then
   	change_element(lget(party,cur.i))
   end
  end
 end
 for p=1,#party do
  cur.i = p
  local available = {}
		for u=1,#unlocked_elements do
		 local element = lget(unlocked_elements,u)
		 if element.i == 1 or element.count > 0 then
		  add(available, element)
		 end
		end
  local e = rnd_int(1,#available)
  local element = lget(available,e)
  for u=1,#available do
   local member = lget(party,cur.i)
   if member.e != sub(element.n,1,1) then
    change_element(member)
  	end
  end
 end
end
-->8
-- finish

function finish_auto_turn()
	auto_ticks = nil
 lget(settings,1).s = 1
 set_up_settings()
 message = nil
 set_stale()
end

function save_settings()
 if s_cur.s == #settings + 1 then
  if s_cur.o == 2 then
   for s=1,#settings do
    setting = lget(settings,s)
    setting.s = setting.c
   end
   set_up_settings()
  end
  s_cur = nil
  pop_state()
 end
end
-->8
-- graphihcs

function set_stale()
 stale = true
end

note_pos = {x=2, y=83}

function note(string, col1)
 col2 = black
 
 if not col1 then
  col1 = white
  col2 = black
 end
 print(string, note_pos.x, note_pos.y, col1, col2, false)
end

function print(s, x, y, pc, bg_col, caps)
 assert(type(s)==string,type(s))
 assert(type(x)==number)
 assert(type(y)==number)
 if pc == nil then
  pc = black
 end
 assert(type(pc)==number)
 
 local offset = 0
 local shift = false
 local elem = false
 for char=1,#s do
  if sub(s,char,char) == "^" then
   shift = true
  elseif sub(s,char,char) == "@" then
   elem = true
  else
   if shift or caps then
    sheet = wide
   else
    sheet = slim
   end
   local ci = ord(sheet, s, char)
   if bg_col != nil then
    rectfill(x+offset-1, y-1, x+offset+sheet.tw, y+sheet.th, bg_col)
   end
   if elem then
    ci = -1 //space
    local element = element_by_n(sub(s,char,char))
    draw_element(x + offset+2, y+2, element, pc, shift or caps)
   end
   render(sheet, ci, x + offset, y, pc, bg_col)
  	offset += sheet.tw + 1
  	shift = false
  	elem = false
  end
 end
end

function render(sheet, ci, dx, dy, pc1, pc2, pc3, pc4, flipx)
 local tw = sheet.tw
 local th = sheet.th
 local off_x = sheet.x
 local off_y = sheet.y
 local layers = sheet.layers
 local rw = flr(128 * layers / sheet.tw) //tiles per row
 
 local c = flr(ci / layers) % (rw / layers)
 local l = ci % layers
 local r = flr(ci / rw)
 local sx = off_x + c * tw
 local sy = off_y + r * th

 for y = 0,th-1 do
  for x = 0,tw-1 do
   local dpixel
   local spixel = sget(sx + x, sy + y)
   if spixel != black then
    local b = inttobin(spixel)
    if layers == 4 then
     if b[l+1] == 1 then
      dpixel = pc1
     end
    elseif layers == 2 then
     local ll = l * 2
     if b[ll+1] == 1 and b[ll+2] == 1 then
      dpixel = pc4
     elseif b[ll+1] == 1 then
      dpixel = pc2
     elseif b[ll+2] == 1 then
      dpixel = pc3
     end
    end
    if dpixel != nil then
     local final_x = dx + x
     if flipx then
      final_x = dx - x + tw
     end
     pset(final_x, dy + y, dpixel)
    end
   end
  end
 end
end

function draw_enemy(i, x, y, flipx)
 local sheet = enemy
 local c = get_element(i).c
 render(sheet, i-1, x, y, nil, black, nil, white, flipx)
end

function draw_enemies()
 for e in all(enemies) do
  draw_enemy(e.i, e.x+e.sx, e.y)
  end
 for e in all(enemies.dead) do
  spr(195, e.x+4, e.y+4)
 end
end

function draw_party()
 for e in all(party) do
  draw_enemy(e.i, e.x+e.sx, e.y, true)
 end
 for e in all(party.dead) do
  spr(193, e.x+7, e.y+2)
 end
end

function draw_options()
 local lists = {{l=enemies, x=2},
                {l=party, x=82}}

 for l = 1,#lists do
  local list = lget(lists,l)
  for e = 1,#list.l do 
   local en = lget(list.l,e)
   local element = lget(list.l,e).e
   local c = black
   local bg = nil
   local icon = "^ "
   local gem = "@"..element
   local subtarget = false
   local attacker = nil
   if cur.s and cur.s.l and lget(cur.s.l,cur.s.i) then
    attacker = lget(cur.s.l,cur.s.i)
    
    if attacker.i == caster or
     attacker.i == caster +1 or
      attacker.i == caster +2 then
     if
     lget(list.l,e).s == lget(cur.l,cur.i).s +1 or
     lget(list.l,e).s == lget(cur.l,cur.i).s -1 then
      subtarget = true
     end
    end
   end
   if (cur.s and cur.s.l == list.l and cur.s.i == e) or
    (cur.s and cur.s.l != list.l and (cur.i == e or subtarget) and attack_ticks and attack_ticks<20) then
    c = white
    bg = black
     if turn == enemies or
      settings.auto then 
      icon = "^>" //hollow
     else
      icon = "^[" //arrow
     end
    gem = "^"..gem
   elseif cur.l == list.l
    and cur.i != e
     and turn == party
      and not attack_ticks
       and not game_over_ticks 
        and (not settings.auto
         and subtarget) then
    if subtarget then
     icon = "^>"
     gem = "^"..gem
    else
     icon = "^]" //notch
    end
   elseif cur.l == list.l
    and (cur.i == e or subtarget)
     and not attack_ticks then
     if turn == enemies or
      settings.auto then
      icon = "^>" //hollow
     else
      icon = "^[" //arrow
     end
    gem = "^"..gem
   end
   local name = lget(enemy.stats,en.i).n
   print(icon..gem..name, list.x, 7*e + 86, c, bg, false)
  end
 end
end

function draw_element(x, y, element, ring, wide)
	
	assert(element, x.." "..y.." "..ring)
	local fill = element.c
	
 if wide then
  circfill(x, y, 2, fill)
  circfill(x, y, 1.5, fill)
  if ring != white then
   pset(x, y-1, white)
   pset(x-1, y, white)
  end
  line(x-2, y, x, y-2, ring)
  line(x, y-2, x+2, y, ring)
  line(x+2, y, x, y+2, ring)
  line(x, y+2, x-2, y, ring)
 else
  circ(x-1, y, 1, ring)
  pset(x-1, y, fill)
  
  pset(x-2, y-1, fill)
  pset(x-2, y+1, fill)
  pset(x, y-1, fill)
  pset(x, y+1, fill)
 end
end


function draw_stats()
 local message = ""
 message = message.." l"..level
 message = message.." x"..score
 message = message.." b"..battles
 message = message.." s"..setbacks
 message = message.." e"..#unlocked_elements
 message = message.." r"..luck

 if cur and cur.l and cur.l == opposition(turn) and cur.s and cur.s.i then
  local attacker = lget(turn,cur.s.i)
  local main_target = {t=lget(opposition(turn),cur.i)}

  local hit_chance = get_hit_chance(attacker, main_target)
  hit_chance = sub(""..hit_chance*100,1,2)
  if hit_chance then
   message = message.." h"..hit_chance
  end
 end
 print(message, 0, 0, white, black)

 local state_text = ""
 if states and states.stack then
  for s=1,#states.stack do
   local state = lget(states.stack,s)
   local arrow = " "
   if s == #states.stack then
    arrow = "^["
   end
   print(arrow..state.name, 0, s*7+86, dark, black)
  end
 end
end
-->8
-- animations

attack_anim = {
 frames = {196,197,198,199},
 delay = 4
}

fighter_anim = {
 frames = {212,213,214,215,216,217},
 delay = 4
}

caster_anim = {
 frames = {228,229,230,231,232,233,234,235},
 delay = 4
}

active_anims = {}

function add_anim(anim, element_n, x, y, team)
 local element=element_by_n(element_n)
 
 local swap = team==enemies
 local dx = 12
 if swap then
  dx = 0
 end
 
 local d = anim.delay
 if d > delay then
  d = delay
 end
 
 local new = {
  a=anim.frames,
  c=element.c,
  x=x+dx,
  y=y,
  d=d,
  dt=0,
  f=1,
  s=swap
 }
 add(active_anims, new)
end

function draw_animations()
 if #active_anims==0 then
  anim_ticks = nil
  return
 end
 
 if not anim_ticks then
  anim_ticks = 0
 end
 
 for a=#active_anims,1,-1 do
  local anim = lget(active_anims,a)
  draw_animation(anim)
 end
 
 anim_ticks += 1
end

function draw_animation(active_anim)
 local frames = active_anim.a
 local frame = lget(frames,active_anim.f)
 
 if flr(anim_ticks/4) % 2 == 1 then
  pal(black,active_anim.c)
 end
 spr(frame,active_anim.x,active_anim.y,1,1,active_anim.s)
 pal(black,black)
  
 active_anim.dt += 1
 if active_anim.dt > active_anim.d then
  active_anim.dt = 0
  active_anim.f += 1
 end
 if active_anim.f > #frames then
  del(active_anims,active_anim)
  set_stale()
 end
end
__gfx__
affd0b777fdbb37bccc3afffcf000f36e638bff82fff20cac1ceafd2ecf302702001000000000000000000000000000000000000000000000000000000000000
5a02dc3008481427b01fd280b7808769874b4043f000e2c6d2e0d0fe031f65f50110100000000000000000000000000000000000000000000000000000000000
5b339cbbcc4c50278b8716e615282540f04c89f01ddf8f696eb7e7ac6b747fcf7100010000000000000000000000000000000000000000000000000000000000
5a00fc300c6814a78027128165a4a5469066544e5020de120ee1f0e6fce645f52110100000000000000000000000000000000000000000000000000000000000
beee1b775ddbbbdbcc436ffc385358afffa9bbf10fdd07efe63ede27484620720001000000000000000000000000000000000000000000000000000000000000
218872c920008440007e7fbffffcc033080600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24df05484be1cb3707d87c07d0e4c83701c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6b9bf55d2f1fb41f0f4b5dffdffee0ecc0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
f0bf0c496f87a1d7e568510e52d3301503c100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2fda59fbdb436c1e1dffebbfdfdfd0110a0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004444400000000000111000000000000000000444010000000000000000000000000000000000000000055000004000000000000000000011c10c00c00000
0004ccccc4000000000113110044400000000000444450000000005550000000000000455100000000000055550004c000000004040000000010ccddccc00000
004cc4cc4c4000000013311314cc44000000000044dd5000000005557500000000400455571040000000005f5f0004c0000000044444000000c1c44454c0c000
004444ccccc400000015513314c44440000000004dfd71000000055f7d0000000000045d7f1000000044005555004c000004405555cc400000cc5ccccd4cc000
0000445dc5400000004cd5315d44444000011000457533100000057775000000000004577710000004cc555fff504c00004445557fd4c40000c4dcccccc5c000
0000004dddc4000004cd577757544000001751115fd77110000005555555500000000045555510004c4d405555054000045055577dd4c40000c5ccc55d44d000
0001104c5d5c400004c5575555544000017d77775dffd400000055ff5f5f50000004045d7d7710004cc5005000050400040115557fd4c40000c45cddddd4d000
0001555d5554400004c457555544440005f577777777500000005fff555500000000045d7551000004400555000000000040005555cc4000000c5455f5f4c100
0004dd5ddd400000004453571440440004d577555775550000005ff5554000000000045751000000000005005000000000000004444400000000c45d5d54c000
0004dddc5dc400000004415514404440004575554575550000005f555040000000004457710000000000500050000000000000040000440000001cc5dcd4c100
000045ddc5dc40000004415514440000000573551573555000055551404000000044455555100000000055005500000000000040400040000000010c444c1000
000000444444400000001110110000000005514405510000000000000000000000000000000000000000000000000000000000000000000000000001cdc10000
00000400000400000000000000000000000000000000000000000505050000000000000000000000000044510000000000000000000000000000000000000000
00001540444400000000005550000000000004040400000000040555550000000000445110000000000005775000000004555500000000000000000000100000
000005555d444000000005555500000000000444440000000000457ff504000000044dd511044400000015775500000045555550440040000044444011100000
000001575fd4c4000000155df50000000000045544000000000445d55504c0000044cdd7314cc4000001375df71000004055ff50550400000444550511310000
000055775774c400000045fff50000000000055fd40000000000455ff505c0000004cdf7354d4000001337fff7310000005fff50510514040401551544111440
00154555dd5455000000555550000000000015ffd4000000000405fff50540000004455154d5000000113577717500000455550550004c5000055055d40544c4
0001155f75dd5400000045f755000000000005554154000000000555505510000004d7775d500000011355d57575000045575555001434140045404555444444
000015777555c440000005f5540000000000055557d4000000005fd555f500000004df77d500000001137dfd555100004557fd55441000040444444455540400
0000555d55444440000005f5500000000000057d5540000000017d575555000000044df550100000001357f77351100051555500440011404444444445104044
00015554ccc4000000000155500000000000055d404000000004d557500500000004455d54000000000157555373310000555500000000004444544455544440
00155440444000000000055555000000000005555040000000044551550500000004455511000000000055545511110005555550000000000044415551000000
00040000000000000000000000000000000000000000000000000000000000000000000000000000000011110110000000000000000000000444440444400000
00000010100000000000000444000000000400004400000011111011000000000000044400000000000000000000000000000000000000000000000000000000
00000011110000000000004445510000000444044000000001111101110000000000444c400000000000000000f0000000001100000000000000005101000000
000000111110000000000044dd73100000044445504044400011110113100000000044cc40000000000000040000000000011310000000000000444511111400
000000113130000000400044dd5110000000455414c440400001111133101100000444c401100000000000044003f00000113310110000000000044d73314000
000110133354000000040040573141000044555545500000000001111111310000044cdc5331100000000004440330000011111131000100000014dff1140000
0011111115454000004400045d55c4000004445555550400000001377511100000044d7df5333100000004455444400001333111101011000000145537500000
0011011315111000004400444577540000000441510444000011045dfd51000000005d77733131000001055555447400015131110011110000015cddd7510000
00100013155000000454015d44511000000005111500000000015ccdff50000000017f7f7333310000015555355400000401375404015000000575d753110000
001000553144000005c4133755d7100000004044105400000015444555500000001315dd551331000445451111044000041555555c5500000004175533310000
0040155555440000054d7555ff7710000000400404004000000004455510000001155ddddd511000000440011000000000515555555100000000055551111000
000440115550000004d5d4cc55d5000000000000004000000000000110110000044dd55555d50000000040000000000000011511511000000000444154011000
00000000000000000044444444400000000000000000000000000001101100000044444444400000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000404000000000000000000000000000000000000000
00000000000000000000000111000000000000044400000000000000444000000000001010000000000000444411000000000040000000000000004044405000
00000000000000000000041115100000045040445440000000000004ccc400000000001110000000000000545d51100000000444000000000000151544451500
0000000000000000000045517571000000555045dc4040400014004cc44c4000004400113100000000011455fd51000000004444400000000001737354555110
000004440000000000045315515400000015115ddc5105000050005c44c4c40004400113314000000011005ddd500000000004c400000000001735555c4d7500
000444c444000000004131557710400000110554544511000050155dd454440004450111105144000015404555154000000044c4005010000013553575457100
004c4c4c4c4000000001311551011000001100445c40100000505555dd55500004554455557540000055004d5555400000044455500515000013355554d55110
0044c555d44044400000111111111000000110454c400000004555555ddd400000455455755c44000055145dd555000000044555550551000001715754441400
0044575575455400000111111110000000000004450100000045554554551000000055555404444000455555dd51000000044555514550000004151555551100
04455155551555400001101111000000000000044410000000441044144000000004015154004400000555155550000000005555555510000051515151511000
00045500554000000000001111000000000000444440000000445504514400000004515514400000000011554155000000155554555100000115111515001000
00000000000000000000011101100000000000000000000000000000000000000000000000000000000011111111100000000000000000000000004000000000
00000004000000000000000003333300000000000000000000000000000000000000444000000000000044444440000000000000000000000000000000000000
000044444000000000000000331113000044440404470000000000155d00000000000c15554440000004ccccccd5500000000455110044400000001111000000
000004444400000000000003753313000304c4447c43300000c00117571000c000004557571c0000004ccccccdffd5000000c513131c40400004455757144000
0004155c4c04000000000077df73130003034c44f4031300004d131151310c4000011f1d1d750000004ccc44c5fdcc400001575511750000004ddfdddd7d4000
0044554444555000000377fdfdf5300003330074330030000017f3377f71c40000133f377f3d000004cc4cc44ddccc50001337733375400004dffffffffdc400
00045455dcd500000035df5f5d573000031134373334000000055355f514440000011d155d14000004ccc444557dd5100001115515504400044ddddddddc4c40
000055555c5c400000375d7d55f700000311743751570000000047117400400000000c4444400000004ccc4455df7100000010454540000004cccc44cc4ccc40
000115757d5c40000007f555d7f40000003740317570000000000031d700000000001514410000000004cc4d5c4510000044000544400000044cf447cc444400
0011355555d4000000375d5dff44000000044031111300000000000f57000000000104054010000000005455440000000004410045000000004cc404cc440000
00133555515000000035557d5700000000004447531300000000003530400000000000041500000000011155541100000004454545000000044fcc744fc44000
00115551551000000031177713000000000004443330000000000077004400000000000404000000001005545550100000004445400000000444444044444000
00000000000000000003330330000000000000000000000000000000000000000000000000000000000044040444000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000444400000044000000000444000400100000044400000000111100044440000
00000111000000000000045115400000000000444000000000000000011000004cccc404404c5000000014dc0000440100011154c400000001333555cccc4000
00001357551000000040115504104000000004ccc4000000000000010100000004cccc4cc4cc5000114015d111004c500011357dc400000001777fffddccc400
000055ddf7310000000571544440440000000445540000000000000015554000004c4c4cc4d511100d5017d113104c500011155440454100055fd5fffdddc400
00005fffdd5310000041554444440000000104ddd500000000000005554444000004ccc55cc410001d55137517500c41011355444444100005d5df7fd7ff5410
000175d5f551000000101444d500000000015c5757550000000004554451400000004c57f540100011d5515115d144500117737d54110110045df75dd777d411
0005dddffd54000000001045d550000000005ddd5d4d50000004455c40400000000044d7f5d57100111d515557575400011111555403070004d57d5d777d5401
004cd5d7754400000000115575750000000004557544100000444555400000000000455ddd557100110153155551140001155544dc435f50044df555ff55f501
004c405771444000000011555d100000000004d5f50000000444445555040400000015dd5c401000111055034cc70110015ddd4ccc55dd4004455d5f75dd5511
004cc5331354400000001055550000000000045555000000044455555555540000005d7515c410001115451755555011015dddc4c4ccdc4004445555dd551110
00444411111000000000145555500000000045555550000000444455555444400001557315541000131311555555411301155dd4c4c5c5000015455555111100
00000000000000000000440404440000000000000000000000004444444400000000001100000000000000000000000000000440404140000001155511011111
000000000000000000044510011000000000ccc0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000040045111000004453111110000000c300d11ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000044045c51500015445733333100000c00455111c000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000044445cc50440131457331131310000f04455713c000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000400454405040131457333333310003f344d5d110c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005dc400001355577577131100003c5577513ddcc000000000000000000000000000000000000000000000000000000000000000000000000000000000
04404004554440001777577751313100c0345d57f77554cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
0044415515504000577775513333110000444dddf7554cc000000000000000000000000000000000000000000000000000000000000000000000000000000000
001411111550000053777773111133500c44c4dd575cc30000000000000000000000000000000000000000000000000000000000000000000000000000000000
001111115550000013775773355577540c44c4555110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001115555451000177775777755577100cc4555551100c000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001011001010000111111111111111000444404440000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d00dd00ddddd000dddd0dd0dddddddddddddddd0ddddddd0ddddddd5ddddddd50000000000000000000000000000000000000000000000000000000000000000
00dd00ddd00d000ddd00d0dddddddddddddddd0ddddddd0ddddddd5ddddddd5d0000000000000000000000000000000000000000000000000000000000000000
00000000d00070ddd00d0dddddddddddddddd00dddddd05dddddd05dddddd55d0000000000000000000000000000000000000000000000000000000000000000
ddd0ddd0ddd00000dd00ddddddddddddddddddddddd000ddddd505ddddd555dd0000000000000000000000000000000000000000000000000000000000000000
ddd0dd00dd000d00dd0d0ddddd000dddddddddddddd00ddddd000ddddd555ddd0000000000000000000000000000000000000000000000000000000000000000
000d000ddd000dddddd0ddddd00707dddddddddddd0dddddd000dddddd05dddd0000000000000000000000000000000000000000000000000000000000000000
d0ddd0ddd000ddddddd0ddddd00000ddddddddddddddddddd00dddddd00ddddd0000000000000000000000000000000000000000000000000000000000000000
d0ddd0ddd000ddddddddddddddd0d0dddddddddddddddddd0ddddddd0ddddddd0000000000000000000000000000000000000000000000000000000000000000
0000000000000000ddd7dddd00000000dddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
0000000000000000dd77d7dd00000000dddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
0000000000000000d77d77dd00000000dddddd00dddddd55dddddd55dddddd55000ddd55005ddd55000000000000000000000000000000000000000000000000
000000000000000007dd7d7000000000dddd00ddddd000ddddd555ddddd555ddd00005ddd00555dd000000000000000000000000000000000000000000000000
00000000000000000077d77000000000ddddddddd0000dddd0055dddd55500ddd55000ddd55555dd000000000000000000000000000000000000000000000000
0000000000000000d007770d00000000dddddddd000ddddd005ddddd555ddd00555ddd55555ddd55000000000000000000000000000000000000000000000000
00000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
000000000000000000dddd0000000000dddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
00000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000
00000000000000000000000000000000dddddddddddddddddd0ddddd0d5000dd500005dd505505dd555555dd555555dd00000000000000000000000000000000
00000000000000000000000000000000dddddddddd0dddddd05d0ddd05005ddd055550dd050050dd550055dd555555dd00000000000000000000000000000000
00000000000000000000000000000000dd00dddddd000ddddd0050dd005505dd050050dd505505dd505505dd550055dd00000000000000000000000000000000
00000000000000000000000000000000dd00ddddd000dddd0500dddd505500dd050050dd505505dd505505dd550055dd00000000000000000000000000000000
00000000000000000000000000000000ddddddddddd0ddddd0d50dddd50050dd055550dd050050dd550055dd555555dd00000000000000000000000000000000
00000000000000000000000000000000ddddddddddddddddddd0dddd0005d0dd500005dd505505dd555555dd555555dd00000000000000000000000000000000
00000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
