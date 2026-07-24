pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
combos_displayed = 4

p_song = {1, "song"}
p_wood = {2, "wood"}
p_game = {3, "game"}
p_fruit = {4, "fruit",{"+1 food"}}
p_rock = {5, "rock"}
p_clay = {6, "clay"}
p_storm = {7, "storm",{"-1 happiness"}}
p_cold = {8, "cold",{"+1 frost","(-3 happiness)"}}
p_mushroom = {9, "mushroom"}
p_spear = {10, "spear",{"beats 1 enemy","on the sides"}}
p_fire = {11, "fire", {"-1 frost"}}
p_speech = {12, "speech"}
p_fence = {13, "fence", {"stuns enemies","on the sides"}}
p_forest = {14, "forest"}
p_mountain = {15, "mountain"}
p_hammerstone = {25, "hammerstone",{"stuns and beats","enemy at its right"}}
p_flint = {26, "flint", {"beats 1 adjacent enemy"}}
p_coal = {27, "coal"}
p_gem = {28, "gem"}
p_gold = {29, "gold"}
p_oil = {30, "oil"}
p_uranium = {31, "uranium"}
p_sheep = {32, "sheep", {"+3 food"}}
p_horse = {33, "horse"}
p_manure = {34, "manure", {"-1 happiness"}}
p_fur = {35, "fur", {"-1 frost"}}
p_jar = {36, "jar", {"+1 max food","for the year"}}
p_dwelling = {37, "dwelling"}
p_effigy = {38, "effigy",{"+1 max happy","for the year","+1 happiness"}}
p_altar = {39, "altar"}
p_persuasion = {40, "persuasion"}
p_drought = {41, "drought",{"-1 food"}}

p_wolf = {42, "wolf",
{"-2 food",
"if no food,",
"-1 population"},
{"the remnants of the",
"hungry wolf pack flee !",
"with them gone,",
"there should be",
"more game for you !",
"(+1 game for the year)"},
2, {3,4}, {2,3}}

p_outcast = {43, "outcast",
{"-3 food"},
{"the outcasts scatter",
"before your might.",
"awed by your power,",
"some of them",
"beg to join you.",
"(+1 population)"},
3, nil, {1,2}}

p_bear = {44, "bear",
{"-5 food",
"if no food,",
"-1 population"},
{"you have defeated",
"the bears !"},
4, {4,5}, {3,4}}

p_raider = {45, "raider",
{"cannot be locked",
"-1 leisure pop.",
"-2 food"},
{"the ravaging raiders",
"have been repelled !"},
5, nil, {5,6}}

p_wheat = {52, "wheat"}
p_masonry = {53, "masonry"}
p_arrow = {54, "arrow", {"beats 2 enemies","on the sides"}}

sp_oven = "sp_oven"
sp_shrine = "sp_shrine"
sp_torchlight = "sp_torchlight"

lands = {p_forest, p_mountain}
mountains = {p_rock, p_clay, p_gem, p_stone, p_coal, p_gold, p_rock, p_oil, p_rock, p_rock, p_uranium}
all_explore = {"ex. forest","ex. mountain","ex. cave"}

seasons = {{"spring", 5, {}},
{"summer", 6, {p_storm}},
{"fall", 5, {p_storm}},
{"winter", 4, {p_cold}}}

weathers = {p_storm, p_cold, p_drought}
enemy_types = {
 [1] = {p_wolf, p_outcast},
 [2] = {p_bear, p_raider}
}

function remove(list, rank)
 for i = rank, #list do
  list[i] = list[i+1]
 end
end

function nb_in(item, list)
 nb = 0
 for i in all(list) do
  if (i == item) nb+=1
 end
 return nb
end

function deepcopy(list)
 res = {}
 for i in all(list) do
  add(res, i)
 end
 return res
end

function show_sign(val)
 if (val>0) return "+"..val
 return val
end


---------- combos

function combo(name, text, requires,
tech, effect)
 c = {}
 c.name = name
 c.text = text
 c.order = requires[1]
 c.quantity = {}
 c.only = {}
 c.none = {}
 for i = 1, #requires[2], 2 do
  if requires[2][i+1] == "only" then
   add(c.only, requires[2][i])
  elseif requires[2][i+1] == "none" then
   add(c.none, requires[2][i])
  elseif requires[2][i+1] == "left" then
   c.left = requires[2][i]
  elseif requires[2][i+1] == "right" then
   c.right = requires[2][i]
  else
   add(c.quantity, requires[2][i])
   add(c.quantity, requires[2][i+1])
  end
 end
 c.tech = tech
 c.effect = effect
 return c
end

function message(x0, y0, x1, y1, text, next_msg)
 m = {}
 m.x0 = x0
 m.y0 = y0
 m.x1 = x1
 m.y1 = y1
 m.text = text
 m.next_msg = next_msg
 return m
end

function max_food()
 mf = 10
 for i in all(techs) do
  if (i[1] == "granary") mf+=1
 end
 return mf+yearly_mf
end

function max_happiness()
 mh = 10
 for i in all(techs) do
  if (i[1] == "ritual") mh+=1
  if (i[1] == "tradition") mh+=2
  if (i[1] == "law") mh+=3
  if (i[1] == "justice") mh+=4
 end
 return mh+yearly_mh
end

function max_tech()
 return 10*(#wheel)
end

function quantity(prod, item)
 cut = 0
 if prod == p_fire then
  for i in all(sp_tech) do
   if (i==sp_oven) cut+=1
  end
 end
 if type(item) == "number" then
  q = item
 else
  q = 1
  for j in all(techs) do
   if (j[1]==item) q+=1
   if (j[1]=="altar" and nb_in(item,{"ritual","tradition"})>0) q-=1
  end
 end
 return max(cut+q,0)
end

function c_level(lvl)
 if (#wheel<lvl) current_msg=lvl_msg[lvl]
 for i = #wheel+1, lvl do
  add(wheel, false)
  add(slides, 0)
 end
-- if (#wheel>=3) slide_action=true
end


---------- combo effects

function c_attack(range, nb_targets, prod)
 nt = nb_targets
-- nb_targets = target[2]
-- if target[1] == "visible" then
 for i in all(range) do
  if (nt<=0) break
  if i > 0
  and i <= #wheel
  and nb_in(roster[wheel[i]], enemies) > 0
  and nb_in(wheel[i], killed) <= 0 then
   add(killed, wheel[i])
   if prod != nil then
    add(passive_anims, {prod, "beats "..roster[wheel[i]][2]})
   end
   nt -= 1
  end
 end
end

function c_attack_wheel(nb_targets)
 ran = {}
 for i = 1, #wheel do
  add(ran, i)
 end
 c_attack(ran, nb_targets)
end

function c_bird_hunt()
 nb_game = 0
 for i in all(roster) do
  if (i==p_game) nb_game+=1
 end
 c_mod_food(nb_game*4)
end

function c_harvest()
 harvested = 0
 for i in all(wheel) do
  if (roster[i]==p_wheat) harvested+=harvest_bonus
 end
 c_mod_food(harvested)
end

function c_newpop(tmp)
-- happiness -= pop_total()
 leisure += 1
end

function c_mod_happiness(val,prod)
 happiness = min(max_happiness(),happiness+val)
 if prod != nil then
  add(passive_anims, {prod,show_sign(val).." happiness"})
 end
end

function c_mod_happiness_low(val, prod)
 if happiness < 0 then
  c_mod_happiness(val*3, prod)
 else
  c_mod_happiness(val, prod)
 end
end

function c_mod_food(val, prod)
 food = max(0,food+val)
 if prod != nil then
  add(passive_anims, {prod,show_sign(val).." food"})
 end
end

function game_over()
 current_msg = message(0, 0, 127, 127,
 {"on their "..year.."th year,",
 "",
 "the brave tribe met their end.",
 "",
 "",
 "***** game over *****"},
 "restart")
end

function exile_pop()
 if pop_total() <= 1 then
  game_over()
  return
 end
 exile = flr(rnd(pop_total()))+1
 if exile <= leisure then
  exile_anim = {"leisure", 100}
  leisure -= 1
 else
  exile -= leisure
  for activ in all(techs) do
   if activ[2] == "activity" then
    exile -= 1
    if exile == 0 then
     exile_anim = {activ[1], 100}
     del(techs, activ)
     sel_tech = 0
     break
    end
   end
  end
 end
end

function c_devour(val)
 if food > 0 then
  c_mod_food(-val)
 else
  add(passive_anims, {p, "-1 pop. !"})
  exile_pop()
 end
end

function c_mod_happiness_leisure(tmp, prod)
 c_mod_happiness(leisure, prod)
end

function c_vision(tmp, prod)
 c_mod_happiness(-1, prod)
 locked = {}
 nb_actions += 1
end

function c_add(tmp, prod)
 add(additional, tmp)
 if prod != nil then
  add(passive_anims, {prod,"produces "..tmp[2]})
 end
end

function c_mod_mh(val,prod)
 yearly_mh+=val
 if (val!=0) add(passive_anims,{prod,show_sign(val).."max happy."})
end

function c_mod_mf(val,prod)
 yearly_mf+=val
 if (val!=0) add(passive_anims,{prod,show_sign(val).."max food"})
end

function paved_count()
 pc = 0
 for i in all(techs) do
  if (i[1]=="paved road") pc+=1
  if (nb_in(i[1], all_explore)>0) pc-=1
 end
 return pc
end


---------- messages

msg_intro10 = message(10, 50, 115, 105,
{" you start with 1 reel.",
"      to spin it,",
"push the big button",
"     with the c key.",
{21,90,20}})

msg_intro9 = message(0, 50, 110, 100,
{"     all these symbols",
"       will show up",
"       on the reel."},
msg_intro10)

msg_intro8 = message(0, 10, 117, 85,
{"    you can also see",
"    a weather symbol.",
"  it changes every year.",
"drought     : -1 food",
"storm     : -1 happiness",
"cold     : +1 frost",
"(1 frost = -3 happiness)",
{41,40,28},
{7,32,36},
{8,28,44}},
msg_intro9)

msg_intro7 = message(0, 10, 117, 75,
{"   you can also see",
" a mountain",
" and a forest.",
" these are always available",
" to explore.",
{15,50,12},
{14,60,20}},
msg_intro8)

msg_intro6 = message(0, 10, 117, 65,
{"here is your production. ->",
"your can see the 5 songs",
"produced by your population."},
msg_intro7)

msg_intro5 = message(40, 52, 112, 95,
{"leisure produces",
"  1 song",
{1,40,12}},
msg_intro6)

msg_intro4 = message(40, 52, 112, 100,
{"<- by default,",
"  people are",
"enjoying leisure."},
msg_intro5)

msg_intro3 = message(28, 27, 110, 85,
{"<- here are your",
"   innovations.",
"  you can build",
"up to 10 for now."},
msg_intro4)

msg_intro2 = message(15, 20, 127, 50,
{"<- here is your population."},
msg_intro3)

msg_intro1 = message(0, 50, 115, 120,
{"",
"",
"welcome to spinvilization,",
"  the game that lets you",
"  build your civilization",
"    by spinning reels !"},
msg_intro2)

msg_sliders = message(0, 50, 110, 127,
{"your tribe is nomadic,",
"they can travel to improve",
"the outcome of the wheel!",
"",
"when on a reel,",
"press up/down",
"to move a step.",
"use it to your advantage!"})

msg_spinned = message(-4, 50, 58, 125,
{"   good !",
"let's see",
"if you can",
"match a combo.",
"push right to",
"go to the list",
"of combos."})

msg_sel_combo2 = message(-5, 0, 58, 120,
{"move up/down",
"to check combos.",
"matched combos",
"are in yellow.",
"",
"new population",
"is special. it",
"only requires",
"that your",
"value reaches",
"your current",
"population",
"number.",
{17,42,68}})

msg_sel_combo = message(0, 0, 120, 120,
{"how to match a combo :",
"",
"",
"        : sequence",
"",
"    :    on the left reel",
"    :    on the right reel",
"",
"2   1    : amount needed",
"",
"     : only those symbols",
"on the remaining reels",
"     : none of those symbols",
{10,6,28},
{3,14,28},
{13,22,28},
{5,6,44},
{49,6,44},
{5,27,44},
{11,6,52},
{50,6,52},
{11,27,52},
{3,11,68},
{10,27,68},
{35,6,84},
{36,14,84},
{23,6,84},
{23,14,84},
{1,6,100},
{12,14,100},
{59,6,100},
{59,14,100}},
msg_sel_combo2)

msg_year4 = message(27, 5, 127, 60,
{"after eating, any food",
"over the",
"storage capacity",
"is wasted."})

msg_year3 = message(27, 11, 127, 95,
{"<-   this is your",
"civilization's",
"happiness/max happiness",
"",
"if happiness falls",
"below 0,",
"you lose 1 population."},
msg_year4)

msg_year2 = message(27, 3, 127, 75,
{"<-   here is your",
" food/storage capacity",
"",
"if there is not",
" enough food, they",
"lose happiness instead."},
msg_year3)

msg_year1 = message(0, 50, 115, 115,
{"one last action before",
"the end of the year !",
"",
"every year, your population",
"       needs to eat."},
msg_year2)

msg_lvl2_2 = message(0, 45, 110, 100,
{"as you entered a new age,",
"you gained a new reel !",
"you can now lock a reel",
"by pressing c when on it."})

msg_lvl2 = message(0, 0, 110, 95,
{"      age 2",
"    age of tools",
"",
"tools allow a species",
"to overcome their physical",
"limitations, accomplishing",
"complex tasks.",
"many animals use tools."},
msg_lvl2_2)

msg_lvl3_2 = message(0, 45, 110, 127,
{"your civilization",
"has settled !",
"",
"now you can slide a reel",
"multiple times, but",
"each time costs an action.",
"use it wisely : sliding",
"at the right time",
"is key to success."})

msg_lvl3 = message(0, 0, 110, 125,
{"      age 3",
" age of sedentism",
"",
"settling on a fertile land",
"allows for a great",
"increase in population,",
"at the cost of",
"being vulnerable",
"to low harvest.",
"drought, animal plague,",
"frost cause starvation.",
"in response, people look",
"to the stars for answers."},
msg_lvl3_2)

msg_lvl4_2 = message(0, 20, 127, 127,
{"that's the end of",
"the journey for now !",
"(spinvilization will be back)",
"thanks for playing !",
"i hope you enjoyed it.",
"",
"",
"",
"you can keep playing any try",
"to last as long as possible."})

msg_lvl4 = message(0, 0, 110, 127,
{"         age 4",
"   age of the state",
"",
"following sedentism, the",
"successful tribes have",
"expanded their numbers to",
"the thousands, making it",
"impossible to know all",
"one's peers. interactions",
"with strangers become more",
"common. trade and other",
"impersonal relations",
"flourish, and a need for",
"a common framework arises.",
},
msg_lvl4_2)


lvl_msg = {nil,msg_lvl2,msg_lvl3,msg_lvl4}

current_msg = msg_intro1

already_spinned = false
already_sel_combo = false
already_sel_tech = false
already_sliders = false
already_year = false

---------- combos

function init_combos()
 return {
 {
  -- new population
  combo("new pop.",
  {"+1 population"},
  {{}, {}, {}, {}},
  "instant",
  {c_newpop}),
  -- combos level 1
  -- effigy
  combo("effigy",
  {"activity :","uses clay,","produces","effigy"},
  {{}, {p_clay,1}},
  {"activity", {p_clay}, {p_effigy}},
  {}),
  -- explore forest
  combo("ex. forest",
  {"activity :","produces","wood,","game,","mushroom","and fruit"},
  {{}, {p_forest,1}},
  {"activity", {}, {p_wood,p_game,p_fruit,p_mushroom}},
  {}),
  -- explore mountain
  combo("ex. mountain",
  {"activity :","produces","rock","and clay"},
  {{}, {p_mountain,1}},
  {"activity", {}, {p_rock,p_clay}},
  {}),
  -- hammerstone
  combo("hammerstone",
  {"activity :","uses","rock,","produces","hammerstone,","unlocks","age 2"},
  {{}, {p_rock,1}},
  {"activity", {p_rock}, {p_hammerstone}},
  {}),
  -- harmony
  combo("harmony",
  {"instant :","+5 happiness"},
  {{}, {p_song,"only"}},
  "instant",
  {c_mod_happiness,5}),
  -- humming
  combo("humming",
  {"instant :","+1 happiness"},
  {{}, {p_song,1}},
  "instant",
  {c_mod_happiness,1}),
  -- rabbit hunt
  combo("rabbit hunt",
  {"instant :","+2 food"},
  {{}, {p_game,1,p_song,"none",p_speech,"none"}},
  "instant",
  {c_mod_food,2}),
  -- spear
  combo("spear",
  {"activity :","uses","wood,","produces","spear,","unlocks","age 2"},
  {{}, {p_wood,1}},
  {"activity", {p_wood}, {p_spear}},
  {}),
  -- vision
  combo("vision",
  {"instant :","-1 happiness,","unlock all","slots, and","roll","for free"},
  {{}, {p_mushroom,1}},
  "instant",
  {c_vision})
 },
 {
  -- combos level 2
  -- altar
  combo("altar",
  {"activity :","uses rock","and effigy","produces","altar,","and ritual","and tradition","cost 1 less"},
  {{}, {p_rock,1,p_effigy,1}},
  {"activity", {p_rock,p_effigy}, {p_altar}},
  {}),
  -- arrow
  combo("arrow",
  {"activity :","uses spear","and flint,","produces","arrow"},
  {{p_spear,p_flint}, {}},
  {"activity", {p_spear,p_flint}, {p_arrow}},
  {}),
  -- bird hunt
  combo("bird hunt",
  {"instant :","+4 food","for each","game","produced"},
  {{}, {p_arrow,1,p_forest,1,p_song,"none",p_speech,"none"}},
  "instant",
  {c_bird_hunt}),
  -- boar hunt
  combo("boar hunt",
  {"instant :","+5 food"},
  {{}, {p_game,1,p_spear,1,p_song,"none",p_speech,"none"}},
  "instant",
  {c_mod_food,5}),
  -- bonfire
  combo("bonfire",
  {"instant :","+8 happiness"},
  {{}, {p_song,1,p_fire,"only"}},
  "instant",
  {c_mod_happiness,8}),
  -- charcoal
  combo("charcoal",
  {"activity :","uses wood,","produces","fire and","coal"},
  {{}, {p_wood,1,p_fire,1}},
  {"activity", {p_wood}, {p_fire,p_coal}},
  {}),
  -- deer hunt
  combo("deer hunt",
  {"instant :","+7 food"},
  {{}, {p_game,1,p_arrow,1,p_song,"none",p_speech,"none"}},
  "instant",
  {c_mod_food,7}),
  -- ember guardian
  combo("embers",
  {"activity :","uses wood,","produces","fire"},
  {{p_storm,p_wood}, {}},
  {"activity", {p_wood}, {p_fire}},
  {}),
  -- explore cave
  combo("ex. cave",
  {"activity :","produces","dwelling,","manure,","and clay,","unlocks age3"},
  {{p_fire,p_mountain}, {}},
  {"activity", {}, {p_dwelling,p_manure,p_clay}},
  {}),
  -- flint
  combo("flint",
  {"activity :","uses rock,","produces","flint"},
  {{p_hammerstone,p_rock}, {}},
  {"activity", {p_rock}, {p_flint}},
  {}),
  -- folksong
  combo("folksong",
  {"instant :","+1 happiness","for each","population","in leisure"},
  {{}, {p_song,1,p_speech,1}},
  "instant",
  {c_mod_happiness_leisure}),
  -- fur
  combo("fur",
  {"activity :","uses game,","produces","fur"},
  {{}, {p_game,"left",p_game,"right"}},
  {"activity", {p_game}, {p_fur}},
  {}),
  -- igloo
  combo("igloo",
  {"activity :","uses cold,","produces","dwelling,","-1 food","per year,","unlocks age3"},
  {{p_cold,p_cold}, {}},
  {"activity", {p_cold}, {p_dwelling}},
  {}),
  -- menhir
  combo("menhir",
  {"innovation :","before","eating,","if","happiness<0,","+1 happiness"},
  {{p_rock,p_rock}, {}},
  {"dev"},
  {}),
  -- mourning
  combo("mourning",
  {"instant :","+2 happiness,","tripled if","happiness<0"},
  {{p_song,p_song}, {}},
  "instant",
  {c_mod_happiness_low,2}),
  -- fireside story
  combo("fire story",
  {"instant :","+3 happiness"},
  {{}, {p_fire,1,p_speech,1}},
  "instant",
  {c_mod_happiness,3}),
  -- ritual
  combo("ritual",
  {"innovation :","+1 max","happiness,","rituals cost","+1 song"},
  {{}, {p_song,"ritual"}},
  {"dev"},
  {}),
  -- shaman
  combo("shaman",
  {"activity :","uses song,","produces","speech"},
  {{}, {p_mushroom,1,p_song,1}},
  {"activity", {p_song}, {p_speech}},
  {}),
  -- sparks
  combo("sparks",
  {"instant :","produces","fire","for the year"},
  {{p_flint,p_flint}, {}},
  "instant",
  {c_add,p_fire}),
  -- stone throw
  combo("stone throw",
  {"instant :","beats","1 enemy"},
  {{}, {p_rock,"left"}},
  "instant",
  {c_attack_wheel,1}),
  -- tent
  combo("tent",
  {"activity :","uses fur,","produces","dwelling,","unlocks","age 3"},
  {{}, {p_fur,"left",p_fur,"right"}},
  {"activity", {p_fur}, {p_dwelling}},
  {}),
  -- totem
  combo("totem",
  {"innovation :","animals","give +1 max","happiness","for the year"},
  {{}, {p_effigy,1,p_wood,1}},
  {"dev"},
  {})
 },
 {
  -- combos level 3
  -- bricks
  combo("bricks",
  {"activity :","uses clay,","produces","masonry"},
  {{}, {p_fire,2,p_clay,2}},
  {"activity", {p_clay}, {p_masonry}},
  {}),
  -- buffalo hunt
  combo("buffalo hunt",
  {"instant :","+15 food"},
  {{}, {p_game,2,p_spear,1,p_song,"none",p_speech,"none"}},
  "instant",
  {c_mod_food,15}),
  -- burial mound
  combo("burial mound",
  {"instant :","+3 happiness,","tripled if","happiness<0"},
  {{}, {p_spear,"only",p_flint,"only",p_fur,"only",p_effigy,"only",p_jar,"only"}},
  "instant",
  {c_mod_happiness_low,3}),
  -- burn coal
  combo("burn coal",
  {"activity :","uses coal","and fire,","produces","fire and fire"},
  {{}, {p_coal,1,p_fire,2}},
  {"activity", {p_coal,p_fire}, {p_fire,p_fire}},
  {}),
  -- cobblestone
  combo("cobblestone",
  {"activity :","uses rock,","produces","masonry"},
  {{}, {p_hammerstone,1,p_rock,1,p_clay,1}},
  {"activity", {p_rock}, {p_masonry}},
  {}),
  -- farm
  combo("farm",
  {"activity :","produces","wheat,","farms cost","+1 fence"},
  {{}, {p_dwelling,1,p_fence,"farm"}},
  {"activity", {}, {p_wheat}},
  {}),
  -- fence
  combo("fence",
  {"activity :","uses wood,","produces","fence"},
  {{p_wood,p_wood}, {}},
  {"activity", {p_wood}, {p_fence}},
  {}),
  -- granary
  combo("granary",
  {"innovation :","+1 max food,","+1 jar bonus"},
  {{}, {p_dwelling,1,p_game,"none",p_sheep,"none",p_horse,"none",p_bear,"none"}},
  {"dev"},
  {}),
  -- grove
  combo("grove",
  {"innovation :","+1 fruit","bonus"},
  {{}, {p_fence,"left",p_fence,"right",p_fruit,"only"}},
  {"dev"},
  {}),
  -- harvest
  combo("harvest",
  {"instant :","+1 food","for each","wheat"},
  {{}, {p_wheat,1,p_storm,"none",p_drought,"none",p_cold,"none"}},
  "instant",
  {c_harvest}),
  -- horse taming
  combo("ride horse",
  {"activity :","uses sheep,","produces","horse"},
  {{}, {p_sheep,1,p_speech,"only"}},
  {"activity", {p_sheep}, {p_horse}},
  {}),
  -- oracle
  combo("oracle",
  {"activity :","uses altar,","produces","speech"},
  {{}, {p_mountain,1,p_storm,1,p_song,"only",p_altar,"only"}},
  {"dev", {p_altar}, {p_speech}},
  {}),
  -- oven
  combo("oven",
  {"activity :","uses rock","and fire,","combos","require","-1 fire"},
  {{p_rock,p_fire,p_rock}, {}},
  {"activity", {p_rock,p_fire}, {sp_oven}},
  {}),
  -- pottery
  combo("pottery",
  {"activity :","uses clay,","produces","jar"},
  {{}, {p_clay,"left",p_clay,"right"}},
  {"activity", {p_clay}, {p_jar}},
  {}),
  -- shrine
  combo("shrine",
  {"innovation :","uses altar,","after eating,","1 excess food","is converted","to happiness"},
  {{p_fence,p_altar,p_fence}, {}},
  {"dev", {p_altar}, {sp_shrine}},
  {}),
 -- oven
-- combo("oven",
-- {{p_rock,p_coal,p_rock}, {}, {}, {}},
-- {"activity", {p_rock,p_coal}, {p_oven}},
-- {}),
  -- sheep taming
  combo("tame sheep",
  {"activity :","produces","sheep and","manure"},
  {{p_spear,p_game,p_fence}, {}},
  {"activity", {}, {p_sheep, p_manure}},
  {}),
  -- torch light
  combo("torch light",
  {"innovation :","uses fire,","+1 action","per year"},
  {{}, {p_fire,"right"}},
  {"dev", {p_fire}, {sp_torchlight}},
  {}),
  -- tradition
  combo("tradition",
  {"innovation :","+2 max","happiness,","traditions","cost","+1 speech"},
  {{}, {p_speech,"tradition"}},
  {"dev"},
  {}),
  -- village council
  combo("v. council",
  {"activity :","uses spear","and speech,","produces","persuasion,","unlocks age4"},
  {{}, {p_spear,1,p_speech,"only"}},
  {"activity", {p_spear,p_speech}, {p_persuasion}},
  {})
-- },
-- {
  -- combos level 4
  -- paved road
--  combo("paved road",
--  {{}, {p_masonry,"paved road"}},
--  "dev",
--  {})
 }
}
end

---------- end of combos


function actions_year()
 ay = 6
 for i in all(sp_tech) do
  if (i==sp_torchlight) ay+=1
 end
 return ay
end

function pop_total()
 t =  leisure
 for i in all(techs) do
  if (i[2] == "activity") t+=1
 end
 return t
end

function actual_prod(w, r)
 a = {}
 for i in all(w) do
 add(a, r[i])
 end
 return a
end

function new_pop_threshold()
 return pop_total()-recruit_bonus
end

function c_dist(c, w)
 if c.name == "new pop." then
  if happiness >= new_pop_threshold() then
   return {0, {}}
  else
   return {1, {}}
  end
 end
 dist = 0
 actual = actual_prod(w, roster)
 part = {}
 for i,j in pairs({[#actual]=c.right,[1]=c.left}) do
  if j != nil then
   if (nb_in(j,roster)<=0) return nil
   if j == actual[i] then
    add(part, i)
--    remove(actual, i)
   else
    dist += 1
   end
  end
 end
 for i in all(c.order) do
  if (nb_in(i,roster)<=0) return nil
 end
-- for i = 1, #c.quantity, 2 do
--  if (nb_in(c.quantity[i],roster)<=0) return -1
-- end
 if #c.order > 0 then
  best_order = {#c.order, 0}
  for i = 0, #actual-#c.order do
   tmp = 0
   for j = 1, #c.order do
    if (nb_in(i+j,part)>0 or c.order[j]!=actual[i+j]) tmp+=1
   end
   if (tmp<best_order[1]) best_order={tmp,i}
  end
  dist += best_order[1]
 end
 for i = 1, #c.order do
  add(part, i+best_order[2])
--  del(actual, i)
 end
 if #c.quantity > 0 then
  for i = 1, #c.quantity, 2 do
   q = quantity(c.quantity[i], c.quantity[i+1])
   if (q>0 and nb_in(c.quantity[i],roster)<=0) return nil
--   n = nb_in(c.quantity[i], actual)
   for j = 1, #actual do
    if (q<=0) break
    if nb_in(j,part) <= 0 and actual[j] == c.quantity[i] then
     q -= 1
     add(part, j)
    end
   end
--   for j = 1, min(n,q) do
--    del(actual, c.quantity[i])
--   end
--   if (n<q) dist+=q-n
   dist += q
  end
 end
 if #c.only > 0 then
  only_possible = true
  for i = 1, #actual do
   if nb_in(i, part) <= 0 then
    if nb_in(actual[i], c.only) <= 0 then
     dist+=1
     only_possible = false
    else
     add(part, i)
    end
   end
  end
  for i in all(c.only) do
   if (nb_in(i,roster)>0) only_possible=true
  end
  if (not only_possible) return nil
 end
 for i = 1, #actual do
  if (nb_in(i,part)<=0 and nb_in(actual[i],c.none)>0) dist+=1
-- for i in all(c.none) do
--  dist += nb_in(i,actual)
-- end
 end
 return {dist,part}
end

function w_shift(r, pos, shift)
 return ((pos+shift-1)%#r) + 1
end

function instant_prod()
 if (roster==nil) return
 frost = 0
 granary_bonus = 0
 grove_bonus = 0
 totem_bonus = 0
 neutralized = {}
 for i in all(techs) do
  if (i[1]=="granary") granary_bonus+=1
  if (i[1]=="grove") grove_bonus+=1
  if (i[1]=="totem") totem_bonus+=1
 end
 actual = actual_prod(wheel,roster)
 for i = 1, #actual do
  if anim[i] != -1 then
   p = actual[i]
   if (p==p_fruit) c_mod_food(1+grove_bonus,p)
   if (p==p_wheat) harvest_bonus+=1 add(passive_anims,{p,"+1 harvest bonus"})
   if (p==p_game) c_mod_mh(totem_bonus,p)
   if p == p_sheep then
    c_mod_mh(totem_bonus,p)
    c_mod_food(3,p)
   end
   if (p==p_horse) c_mod_mh(totem_bonus,p)
   if (p==p_wolf) c_mod_mh(totem_bonus,p)
   if (p==p_bear) c_mod_mh(totem_bonus,p)
   if p == p_effigy then
    c_mod_mh(1,p)
    c_mod_happiness(1,p)
   end
   if (p==p_storm) c_mod_happiness(-1,p)
   if (p==p_drought) c_mod_food(-1,p)
   if (p==p_manure) c_mod_happiness(-1,p)
   if (p==p_jar) c_mod_mf(1+granary_bonus,p)
   if (p==p_cold) frost += 1
   if (p==p_fire) frost -= 1
   if (p==p_fur) frost -= 1
   if (p==p_gem) c_mod_happiness(2,p)
   if (p==p_dwelling) recruit_bonus+=1
   if (p==p_hammerstone) c_attack({i+1},1,p)
   if (p==p_hammerstone) add(neutralized, i+1)
   if (p==p_spear) c_attack({1,#wheel},1,p)
   if (p==p_fence) add(neutralized, 1)
   if (p==p_fence) add(neutralized, #wheel)
   if (p==p_flint) c_attack({i-1,i+1},1,p)
   if (p==p_arrow) c_attack({1,#wheel},2,p)
  end
 end
 if (frost>0) c_mod_happiness(-(frost*3),p_cold)
 for i = 1, #actual do
  p = actual[i]
  if nb_in(i, neutralized) > 0 then
   if (p==challenger) add(passive_anims, {p, "is stunned !"})
  else
   if anim[i] != -1 then
    if (p==p_wolf) c_devour(2,p)
    if (p==p_outcast) c_mod_food(-3,p)
    if (p==p_bear) c_devour(5,p)
    if p == p_raider then
     c_mod_food(-2,p)
     if leisure > 0 then
      leisure -= 1
      if pop_total() <= 0 then
       game_over()
       return
      end
     end
    end
   end
  end
 end
 vanquish()
end

function vanquish()
-- if #killed > 0 then
--  print()
--  happiness = #killed
--  print(erazze[5])
-- end
 for i in all(killed) do
  del(enemies, roster[i])
 end
 killed = {}
 if #enemies <= 0
 and challenger != nil then
  partial_msg = deepcopy(challenger[4])
  if challenger[6] != nil then
   food_b = challenger[6][1]+flr(rnd(challenger[6][2]))
   c_mod_food(food_b)
   add(partial_msg, "+"..food_b.." food")
  end
  if challenger[7] != nil then
   happy_b = challenger[7][1]+flr(rnd(challenger[7][2]))
   c_mod_happiness(happy_b)
   add(partial_msg, "+"..happy_b.." happiness")
  end
  if (challenger==p_wolf) c_add(p_game)
  if (challenger==p_outcast) leisure+=1
--  if (challenger==p_outcast) leisure+=1
--  display(reward)
  current_msg = message(10, 50, 110, 127, partial_msg, nil)
  challenger = nil
 end
end

function add_enemies()
 if (rnd(1)>0.25) return
 new_enemies = flr(rnd(year))+1
 current_val = 0
 for i in all(enemies) do
  current_val += i[5]
 end
 if (new_enemies<=current_val) return
 possible = {}
 for i = #wheel-1, #wheel do
  if enemy_types[i] != nil then
   for j in all(enemy_types[i]) do
    add(possible, j)
   end
  end
 end
 if (#possible<=0) return
 challenger = possible[flr(rnd(#possible))+1]
 enemies = {}
 for i = 1, new_enemies, challenger[5] do
  add(enemies, challenger)
 end
end

function update_combos(lvl)
 dists = {}
 for i = 0, 20 do
  dists[i] = {}
 end
 for i = 1, lvl do
  for j in all(combos[i]) do
   d = c_dist(j, wheel)
   if d != nil then
    add(dists[d[1]], {j,d[2]})
   end
  end
 end
 flat_dists = {}
 for i = 0, 20 do
  for j in all(dists[i]) do
   add(flat_dists, {i,j[1],j[2]})
  end
 end
 sel_combo = 1
 sel_prod = 1
 return flat_dists
end

function update_roster()
-- instant_prod()
 roster = {}
 sp_tech = {}
 our_lands = 2
-- for i in all(techs) do
--  if (nb_in(i[1], {"ex. forest", "ex. mountain", "ex. cave"})>0) our_lands+=1
-- end
 for i = 1, our_lands do
  add(roster, landscape[i])
 end
 for i = 1, leisure do
  add(roster, p_song)
 end
 add(roster, yearly_w)
 for i in all(enemies) do
  add(roster, i)
 end
 for i in all(additional) do
  add(roster, i)
 end
 changed = true
 tmp_tec = deepcopy(techs)
 while changed do
  changed = false
  for i in all(tmp_tec) do
   tmp_ros = deepcopy(roster)
   paid = true
   for j in all(i[3]) do
    if nb_in(j, roster) > 0 then
     del(roster, j)
    else
     paid = false
    end
   end
   if paid then
    changed = true
    for j in all(i[4]) do
     if nb_in(j,{sp_oven,sp_shrine,sp_torchlight}) > 0 then
      add(sp_tech, j)
     else
      add(roster, j)
     end
    end
    del(tmp_tec, i)
   else
    roster = tmp_ros
   end
  end
 end
 tmp_ros = deepcopy(roster)
 roster = {}
 while #tmp_ros > 0 do
  add(roster, tmp_ros[flr(rnd(#tmp_ros))+1])
  del(tmp_ros, roster[#roster])
 end
-- locked = {}
 if (#wheel>=3) slide_action=true
 roll()
end

function change_year()
-- vanquish()
-- instant_prod()
 year += 1
 consume = pop_total()
 for i in all(techs) do
  if (i[1]=="igloo") consume+=1
  if (i[1]=="menhir" and happiness<0) c_mod_happiness(1)
 end
 food -= consume
 if food < 0 then
  happiness += food
  food = 0
 elseif food > max_food() then
  for i in all(sp_tech) do
   if (i==sp_shrine) then
    c_mod_happiness(1)
    food -= 1
    if (food<=max_food()) break
   end
  end
  if (food>max_food()) add(waste_anims, {food-max_food(), 30, 8, 100})
  food = max_food()
 end
 if happiness<0 and happiness<new_pop_threshold() then
  exile_pop()
 end
 harvest_bonus = 1
 recruit_bonus = 0
 nb_actions = actions_year()
 add_enemies()
 additional = {}
 yearly_mf = 0
 yearly_mh = 0
 if (happiness>max_happiness()) add(waste_anims, {happiness-max_happiness(), 30, 16, 100})
 happiness = min(max_happiness(),happiness)
 yearly_w = weathers[flr(rnd(#weathers))+1]
 update_roster()
end

function reset_slides()
 slides = {}
 for i = 1, #wheel do
  add (slides, 0)
 end
end

function slide_cost()
 if (not slide_action) return 0
 cost = 0
 for i = 1, #wheel do
  cost += abs(slides[i])
 end
 return cost
end

function year_ended()
 return nb_actions-slide_cost() <= 0
end

function spend_action(ic)
 sel_wheel = #wheel + 1
 rolling = true
 must_update = ic!=nil or year_ended()
 if not must_update then
  for i = 1, #wheel do
   if nb_in(i,locked) <= 0 then
    anim[i] = -1
    slides[i] = 0
   end
  end
 else
  locked = {}
  nb_actions -= slide_cost()
  for i = 1, #wheel do
   slides[i] = 0
   if ic != nil and nb_in(i,ic)>0 then
    anim[i] = -1
   end
  end
  instant_prod()
 end
end

function finish_action()
 if year_ended() then
  change_year()
 else
  nb_actions -= 1
  if must_update then
--   instant_prod()
--   nb_actions -= slide_cost()
   update_roster()
  else
   roll()
  end
 end
 must_update = nil
end

function roll()
 anim = {}
 for i = 1, #wheel do
  if nb_in(i, locked) == 0 then
   wheel[i] = flr(rnd(#roster))+1
--   slides[i] = 0
   add(anim, flr(rnd(18)) + 8)
  else
   add(anim, 0)
  end
 rolling = false
 end
-- reset_slides()
-- sel_wheel = #wheel+1
 visible_combos = update_combos(#wheel)
end

--function anim_combo(c)
-- for i in all(c) do
--  anim[i] = -1
-- end
--end

function show_roster()
 for i = 1, #roster do
 if (wheel[sel_wheel]==i or (sel_wheel==#wheel+3 and sel_prod==i)) pal(7,9)
  spr(roster[i][1], 120-(8*flr((i-1)/16)), ((i-1)%16)*8)
  pal()
 end
end

function show_wheel(x0, y0)
 if sel_wheel == #wheel+2 
 and visible_combos[sel_combo][1] == 0 then
  parts = visible_combos[sel_combo][3]
 else
  parts = {}
 end
 for i = 1, #wheel do
  px = x0+((i-(#wheel+1))*8)
  for j = -1, 1, 2 do
   if nb_in(i, locked) > 0 then
    pal(11,10)
   elseif slide_action then
    if slides[i]*j >= 0 then
     if slide_cost() >= nb_actions then
      pal(11,8)
     else
      pal(11,12)
     end
    end
   elseif slides[i] == j then
    pal(11,8)
   end
   spr(16, px, y0+8+(j*15), 1, 1, false, j==-1)
   pal()
   if slide_action and slides[i]*j<0 then
--    spr(51, px, y0+8+(j*15), 1, 1, false, j==-1)
    ypos = y0+9+(j*18)
    if (j==1) ypos += 1
    print(abs(slides[i]), px+2, ypos, 10)
   end
  end
  pal(7,6)
  pal(6,7)
  if anim[i] != 0 then
   spr(57, px, y0)
   spr(57, px, y0+16)
   spr(57, px, y0+8)
  else
   spr(roster[w_shift(roster,wheel[i],-1)][1], px, y0)
   spr(roster[w_shift(roster,wheel[i],1)][1], px, y0+16)
   if i==sel_wheel then
    pal(7,9)
   elseif nb_in(i, locked) > 0 then
    pal(7,10)
   else
    pal()
   end
   spr(roster[wheel[i]][1], px, y0+8)
   if (nb_in(i,parts)>0) spr(56, px, y0+8)
  end
 end
 pal()
 color(8)
 rect(x0, y0, x0-(1+(#wheel*8)), y0+23)
 rect(x0+1, y0+1, x0-(2+(#wheel*8)), y0+22)
end

function show_spin(xpos, ypos)
 spr(22, xpos+3, ypos-1)
 color(10)
 actions_left = nb_actions
 if (slide_action) actions_left-=slide_cost()
 print("*"..max(actions_left,0), xpos+7, ypos+1)
 color(7)
 if sel_wheel == #wheel+1 then
  button_anim = (button_anim+1)%100
  if button_anim >= 50 then
   tmp = 21
  else
   tmp = 58
  end
 else
  tmp = 20
 end
 spr(tmp, xpos+5, ypos+8)
end

function show_requirements(v_prod, xpos, ypos)
 xshift = 0
 gap = 0
 for j,k in pairs({[49]=v_prod.left,[50]=v_prod.right}) do
  if k != nil then
   spr(k[1], xpos+xshift, ypos+6)
   spr(j, xpos+xshift, ypos+6)
   xshift += 8
   gap = 3
  end
 end
 xshift += gap
 gap = 0
 for j = 1, #v_prod.order do
  spr(v_prod.order[j][1], xpos+xshift, ypos+6)
  xshift += 8
  gap = 3
 end
 xshift += gap
 gap = 0
 for j = 1, #v_prod.quantity, 2 do
  spr(v_prod.quantity[j][1], xpos+xshift+4, ypos+6)
  print(quantity(v_prod.quantity[j], v_prod.quantity[j+1]), xpos+xshift, ypos+8)
  xshift += 13
  gap = 3
 end
 xshift += gap
 gap = 0
 color(6)
 for j = 1, #v_prod.only do
  spr(v_prod.only[j][1], xpos+xshift, ypos+6)
  spr(23, xpos+xshift, ypos+6)
  xshift += 8
  gap = 3
 end
 xshift += gap
 gap = 0
 for j = 1, #v_prod.none do
  spr(v_prod.none[j][1], xpos+xshift, ypos+6)
  pal(11, 8)
  spr(23, xpos+xshift, ypos+6)
  pal()
  xshift += 8
 end
end

function show_passive()
 ypos = 60
 for i in all(passive_anims) do
  spr(i[1][1], 62, ypos)
  print(i[2], 72, ypos+2)
  ypos += 10
 end
end

function show_combos(xpos, ypos)
 if sel_combo > combos_displayed then
  start_show = sel_combo - combos_displayed
 else
  start_show = 0
 end
 for i = 1, min(combos_displayed,#visible_combos) do
  if visible_combos[start_show+i][1]==0 then
   color(10)
   if (sel_wheel==#wheel+2 and sel_combo==start_show+i) color(9)
  else
   color(6)
   if (sel_wheel==#wheel+2 and sel_combo==start_show+i) color(7)
  end
  v_prod = visible_combos[start_show+i][2]
  print(v_prod.name, xpos, ypos+(i*16))
  if v_prod.name == "new pop." then
   spr(17, xpos, ypos+6+(i*16))
   print(new_pop_threshold(), xpos+9, ypos+8+(i*16))
  else
   show_requirements(v_prod, xpos, ypos+(i*16))
  end
 end
 color(7)
end

function show_tech(xpos, ypos)
 if sel_tech+1 > combos_displayed then
  start_show = sel_tech+1-combos_displayed
 else
  start_show = 0
 end
 for i = 1, min(combos_displayed,#techs+1) do
  color(12)
  if (sel_wheel==0 and sel_tech==start_show+i-1) color(11)
  if start_show+i-1 == 0 then
   t = {"leisure "..leisure, "activity", {}, {p_song}}
  else
   t = techs[start_show+i-1]
  end
  print(t[1], xpos, ypos+(i*16))
  if t[2] == "activity" then
   spr(18, xpos, ypos+(i*16)+7)
   print(":", xpos+6, ypos+(i*16)+8)
   for j = 1, #t[3] do
    spr(t[3][j][1], xpos+(j*8)+1, ypos+(i*16)+7)
   end
   print("->", xpos+10+(#t[3]*8), ypos+(i*16)+8)
   for j = 1, #t[4] do
    spr(t[4][j][1], xpos+((j+#t[3])*8)+10, ypos+(i*16)+7)
   end
  end
 end
 color(7)
end

function global_msg(msg, no_button_msg)
-- if (msg.text==nil) return
 rectfill(msg.x0, msg.y0, msg.x1, msg.y1, 0)
 rect(msg.x0, msg.y0, msg.x1, msg.y1, 9)
 color(7)
 for i = 1, #msg.text do
  text = msg.text[i]
  if type(text) == "string" then
   print(text, msg.x0+5, msg.y0+(i*8)-3)
  else
   spr(text[1], text[2]+msg.x0, text[3]+msg.y0)
  end
 end
 if (no_button_msg!=nil) return
 color(6)
 if msg.next_msg == nil then
  print("c button : ok",msg.x1-56, msg.y1-10)
 else
  print("c button : next",msg.x1-62, msg.y1-10)
 end
 color(7)
end

function msg_combo(c)
 rect(0, 45, 58, 120, 4)
 print(c.name, 5, 50, 9)
 color(7)
 for i = 1, #c.text do
  print(c.text[i], 5, 58+(i*7))
 end
end

function msg_tech(name, text)
 rect(62, 45, 118, 120, 4)
 print(name, 65, 50, 11)
 color(7)
 for i = 1, #text do
  print(text[i], 65, 58+(i*7))
 end
end

function msg_waste(val, x, y)
 print(val.." wasted!", x, y, 8)
 color(7)
end

function msg_lost(name)
 print("lost 1 pop. in", 0, 40, 8)
 print(name.."!", 0, 48, 8)
 color(7)
end

function msg_score(name, timer)
 print(name, 36, 0, 9+((timer/10)%2))
 color(7)
end

function _init()
-- current_msg = msg_intro1
 slide_action = false
 must_update = nil
 animating = false
 rolling = false
 button_anim = 0
 waiter = 0
 passive_anims = {}
 waste_anims = {}
 exile_anim = nil
 score_anim = nil
 landscape = {p_forest, p_mountain}
 for i = 1, 1000 do
  add(landscape, lands[flr(rnd(2))+1])
 end
-- all_enemies = {}
-- for i,j in pairs(enemy_types) do
--  add(all_enemies, j)
-- end
 enemies = {}
 killed = {}
-- our_lands = 2
 year = 1
 food = 5
-- max_food = 10
 happiness = 5
 yearly_mf = 0
 yearly_mh = 0
-- max_happiness = 10
-- max_tech = 10
 techs = {}
 sp_tech = {}
 sel_tech = 0
 leisure = 5
 harvest_bonus = 1
 recruit_bonus = 0
 wheel = {false}
-- anim = {}
-- wheel = {false,false,false}
 combos = init_combos()
 additional = {}
 yearly_w = weathers[flr(rnd(#weathers))+1]
 reset_slides()
 locked = {}
 update_roster()
 nb_actions = actions_year()
 sel_wheel = #wheel+1
 move_pop = nil
end

function _update()
 first_zero = nil
 animating = false
 for i = 1, #anim do
  if nb_in(i, locked) <= 0 then
   if anim[i] == 0 then
    if (first_zero==nil) first_zero=i
   else
    animating = true
    if (anim[i]>0) anim[i]-=1
   end
  end
 end
 if must_update != nil then
  if first_zero == nil then
   finish_action()
  elseif waiter <= 0 then
   anim[first_zero] = -1
   slides[first_zero] = 0
   waiter = 15
  end
 end
 if waiter > 0 then
  waiter -= 1
  return
 end
 if (animating) return
 if current_msg != nil then
  if (waiter == 0 and btn(4)) current_msg=current_msg.next_msg waiter=20
  if (current_msg=="restart") current_msg=nil _init() return
  return
 end
 if (nb_actions<=3 and not already_sliders) current_msg=msg_sliders already_sliders=true
 if (nb_actions<=0 and not already_year) current_msg=msg_year1 already_year=true
 passive_anims = {}
 if (btn(0)) and sel_wheel>0 then
  sel_wheel -= 1
  waiter = 5
 end
 if (btn(1))
 and sel_wheel<=#wheel+2 and move_pop==nil then
  sel_wheel += 1
  if not already_sel_combo and sel_wheel==#wheel+2 then
   already_sel_combo = true
   current_msg = msg_sel_combo
  end
  waiter = 5
 end
 shift = 0
 if (btn(2)) shift=-1
 if (btn(3)) shift=1
 if shift != 0 then
  if sel_wheel == #wheel+3 then
   sel_prod = ((sel_prod+shift-1) % #roster) + 1
  elseif sel_wheel == #wheel+2 then
   sel_combo = min(#visible_combos, max(1, sel_combo+shift))
  elseif sel_wheel == 0 then
   sel_tech = min(#techs, max(0, sel_tech+shift))
  elseif sel_wheel <= #wheel then
   if nb_in(sel_wheel, locked) == 0 then
    slide_ok = false
    if slide_action then
     if slide_cost() < nb_actions or shift*slides[sel_wheel] < 0 then
      slide_ok = true
     end
    elseif shift!=slides[sel_wheel] then
     slide_ok = true
    end
    if slide_ok then
     wheel[sel_wheel] = w_shift(roster, wheel[sel_wheel], shift)
     slides[sel_wheel] += shift
     visible_combos = update_combos(#wheel)
    end
   end
  end
  waiter = 10
 end
 if (btn(4)) then
  if sel_wheel == #wheel+1 then
   if (not already_spinned) current_msg=msg_spinned already_spinned=true
   spend_action()
   waiter = 20
  elseif sel_wheel == #wheel+2 then
   if visible_combos[sel_combo][1] == 0 then
    vc = visible_combos[sel_combo][2]
    in_combo = visible_combos[sel_combo][3]
    if (#vc.effect>0) vc.effect[1](vc.effect[2])
    if vc.tech == "instant" then
     score_anim = {"       "..vc.name, 100}
     if (nb_in(vc.name,{"igloo"})>0) c_level(3)
     if (vc.name=="vision") in_combo=nil
     spend_action(in_combo)
    elseif #techs < max_tech() then
     new_tech = {vc.name, vc.tech[1], vc.tech[2], vc.tech[3], vc.text}
     if vc.tech[1] == "dev"
     or (nb_in(vc.name, all_explore)>0 and paved_count()>0) then
      score_anim = {"       "..vc.name, 100}
      add(techs, new_tech)
      spend_action(in_combo)
     else
      move_pop = {new_tech, in_combo}
      sel_wheel = 0
     end
    end
    waiter = 20
   end
  elseif sel_wheel == 0 then
--   if move_pop != nil then
   _removed = nil
   if sel_tech == 0 then
    if leisure > 0 then
     leisure -= 1
     _removed = "activity"
     score_anim = {"       leisure", 100}
    end
   elseif techs[sel_tech][2]=="activity"
   or move_pop == nil then
    _removed = techs[sel_tech][2]
    score_anim = {"cancel "..techs[sel_tech][1], 100}
    del(techs, techs[sel_tech])
   end
   if _removed != nil then
    in_combo = {}
    if move_pop!=nil then
     score_anim = {"       "..move_pop[1][1], 100}
     add(techs, move_pop[1])
     in_combo = move_pop[2]
     if (nb_in(move_pop[1][1],{"spear","hammerstone"})>0) c_level(2)
     if (nb_in(move_pop[1][1],{"ex. cave","igloo","tent"})>0) c_level(3)
     if (nb_in(move_pop[1][1],{"v. council"})>0) c_level(4)
     move_pop = nil
    elseif _removed=="activity" then
      leisure += 1
    end
    waiter = 20
    sel_tech = 0
    spend_action(in_combo)
   end
--  end
  else
   if nb_in(sel_wheel, locked) > 0 then
    del(locked, sel_wheel)
    waiter = 5
   elseif #locked < #wheel-1
   and roster[wheel[sel_wheel]] != p_raider then
    add(locked, sel_wheel)
    waiter = 5
   end
  end
 end
end

function _draw()
 cls()
 show_wheel(82, 15)
 color(7)
 show_spin(82, 15)
 show_roster()
 if sel_wheel == #wheel+2 then
  msg_combo(visible_combos[sel_combo][2],9)
 else
  show_tech(0, 40)
 end
 if sel_wheel == 0 then
  if move_pop != nil then
   print("choose 1 pop.", 0, 40, 8)
   print("for", 0, 48, 8)
   print("new", 14, 48, 8)
   print("activity", 28, 48, 8)
  end
  if sel_tech == 0 then
   msg_tech("leisure",{"people here","produce","1 song each"})
  else
   msg_tech(techs[sel_tech][1], techs[sel_tech][5])
  end
 elseif rolling or animating then
  show_passive()
 else
  show_combos(60, 40)
 end
 print("year "..year, 0, 0)
 if food < pop_total() then
  color(8)
 elseif food < pop_total()*3 then
  color(9)
 else
  color(11)
 end
 spr(19, 0, 7)
 print(food.."/"..max_food(), 10, 8)
 color(8)
 if happiness < 0 then
  spr(24, 0, 15)
 elseif happiness > 0 then
  if (happiness>=pop_total()) color(11)
  spr(17, 0, 15)
 else
  spr(55, 0, 15)
 end
 print(happiness.."/"..max_happiness(), 10, 16)
 color(7)
 spr(18, 0, 23)
 print(pop_total(), 10, 24)
 spr(48, 0, 31)
 print(#techs.."/"..max_tech(), 10, 32)
 if sel_wheel == #wheel + 3 then
  partial_msg = {roster[sel_prod][2]}
  if roster[sel_prod][3] != nil then
   for i in all(roster[sel_prod][3]) do
    add(partial_msg, i)
   end
  end
  global_msg(message(45, 50, 115, 100,
  partial_msg), true)
 end
 for i in all(waste_anims) do
  if i[4] > 0 then
   i[4] -= 1
   msg_waste(i[1], i[2], i[3])
  else
   del(waste_anims, i)
  end
 end
 if exile_anim != nil then
  if exile_anim[2] > 0 then
   exile_anim[2] -= 1
   msg_lost(exile_anim[1])
  else
   exile_anim = nil
  end
 end
 if score_anim != nil then
  if score_anim[2] > 0 then
   score_anim[2] -= 1
   msg_score(score_anim[1], score_anim[2])
  else
   score_anim = nil
  end
 end
 if (current_msg != nil) global_msg(current_msg)
end


__gfx__
00000000777777777777777777777777777777777777777777777777755555577777777777777777777777777777777777777777777777777777777777777777
000000007777cc7777b744477777575777777bb77777777777777777555555557777c77777755577744774477778777777000077747474777337333777767777
007007007777c7c77774444774777477777997777775577777777777555a555577c7c7c777555577774774777789877770777707444444473333333377766777
000770007777c777774444b7774447777799997777555577777dd777555a5555777ccc777555577777744777789a98777079b707747474773b333b3377dd6d77
0007700077ccc777749944b777444477779999777755555777dddd77777aa7777ccccccc7555977777744777789a9877707997077474747733b3333b77dddd77
007007007cccc7777499477775477577777997777555555777dddd777777a777777ccc77777799777747747789aaa9877077770744444447344343437d4dddd7
0000000077cc777774447777777777777777777775555557777dd7777777a77777c7c7c77777797774777747789a9877770700777474747764464646ddd44ddd
00000000777777777777777777777777777777777777777777777777777777777777c777777777777777777777777777777077777777777766666666ddddd4dd
0000000000aaa00008080000000bb000000cc00000c77c0000000000bbbbbbbb00ccc00077676767777777777777777777777777777777777777777777777777
000000000aaaaa000088800009900000008888000c8888c00a000000b000000b0c0c0c007767676777757777770077777c777777777777777775777776777767
00000000aa0a0aa00008080099990505088ee880c889988ca9a00000b000000bccccccc0777777777755577770000777cbc77777777557777775777777677677
000bb000aaaaaaa00008000099990050c8e88e8c789aa987a9a00000b000000bcc0c0cc07775557775d5d577770080077c77797777a5a5777755577766b8c666
00bbbb00a00000a00088800009955500c8e88e8c789aa987a9a00000b000000bc0c0c0c077755577755d55777008000077779a97775a555777555777777c8777
0bbbbbb00a000a000080800000055550088ee880c889988ca9a00000b000000b0ccccc0077755577775557770000700777877977755a5aa77755577777677b77
0000000000aaa0000080800000550050008888000c8888c00a000000b000000b00ccc00077755577777777777007777778f8777775a5a557777577777b777767
00000000000000000000000000000000000cc00000c77c0000000000bbbbbbbb0000000077777777777777777777777777877777777777777777777777777777
777777777779447777767767777777777777777777777777777777777777777770007777777aa777777777777777777777774877777777777777777777777777
777755777779477777677677777447777474474777777777777757777776d7770777077777aaaa777775777777747444777744777778777777775777777775d7
67777667774444777776776777455477474dd474777dd77777dddd7777666d770777707877aaaa775857777777478757777447777755594777d77d7777777577
766666674444475777677677777447777474474777d6dd77777dd777776dd67770000788777aa77775555555747555777744457777757947777dd7777ddddd77
766667777444757777777777777557777744447777dddd77777ddd7777dd6d77777777787777777755755557777757777744577744455977777ddd7777ddddd7
756567777547777777444477777447777744447744dd6d44775d757777666677787787787777777777755557777575777744477774445777775d7577775d5757
775757777757777774444447774774777744447744dd6d4477777777466666647887887777999779777757577775757777445777754547777777777777757777
77777777777777777777777777777777777447774444444477777777444444448878877799959995777777777777777777577777775757777777777777777777
00a00a00bbbb00000000bbbb00000000777777777777aa777777777700bbb000bb0000bb76767676007cc7008888888877777777777777777777777757777777
a000000ab00000000000000b0000000077977797777aad77755777550bbbbb00b000000b76777677078888708000000877777777777777777777577775775777
000aa000b00000000000000b000000007779797777aad97775477745b00b00b000000000767776777889988780000008777777777777777777dddd7777555577
00aaaa00b00000000000000b0000000077979797799d9d7777747477bbbbbbb00000000077777777c89aa98c800000087777777777777777777dd77777775755
a0aaaa0ab00000000000000b00000000777999777dd9d77777774777b00000b00000000077777777c89aa98c800000087777777777777777777ddd7777775755
000aa000b00000000000000b000aa00077979797799d7777779474970bbbbb00000000007776777678899887800000087777777777777777775d757777757577
00055000b00000000000000b00a99a00777999777dd777777949794900bbb000b000000b77767776078888708000000877777777777777777777777777757577
00000000bbbb00000000bbbb000aa00077779777777777777797779700000000bb0000bb76767676007cc7008888888877777777777777777777777777777777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
