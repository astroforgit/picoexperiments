pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- Chalice of the Gods
-- @geeitsomelaldy
-- for toyboxjam 2019
function str_to_tbl(str,join)
join = join or ','
local cn = ""
local t = {}
for d=1,#str do
local n = sub(str,d,d)
if(n ~= join) then
cn = cn .. n
else
add(t, cn)
cn = ""
end
end
add(t, cn)
return t
end
function string_to_number_table(str)
local t = str_to_tbl(str)
for k,v in pairs(t) do
t[k] = tonum(v)
end
return t
end
function string_to_string_table(str)
return str_to_tbl(str,'+')
end
local mus_current = 1
local sfx_summon_start, sfx_summon_journey, sfx_summon_complete, sfx_summon_repeat = 31,63,48,15
local sfx_interact, sfx_menu_select, sfx_menu_change, sfx_item_use,sfx_error = 10,1,0,2,3
local sfx_teleport_start,sfx_teleport_end = 9,12
local sfx_player_weapon = 11

local spr_player_projectile_h, spr_player_projectile_v ,spr_interact= 77,78,154

local player_dir, player_money,player_max_money,player_projectile_x,player_projectile_y,player_projectile_dir,player_attack_cooldown,player_attack_timer = 0,0,255,0,0,nil,30,0
local player_swish_duration,player_swish_timer,player_hp,player_hp_max,player_speed,anim_index,player_walk,step = 10,0, 4,4,1,0,{25,24},0

local player_x,player_y = 0,32
local player_invulnerable = 0
local show_map = false
local biome_names, biome_map_colours = string_to_string_table"grass+forest+wetlands+desert+mountain+volcano+lake+city+desert mesa+oasis+lakeside",string_to_number_table("11,3,15,9,6,8,12,7,4,7,15")

local known_locations,inventory,bullets = {},{},{}

local enemy_templates = {
{anim={98,99},hp=2},
{anim={100,101},hp=4,shoots=95,every=60,drop_chance=0.8,speed=.3},
{anim={102,103},hp=2,shoots=87,every=120,drop_chance=0.8,speed=.4},
{anim={104,105},hp=5,drop_chance=0.5,speed=.3},
{anim={182,183,184},hp=4,shoots=185,every=90,drop_chance=0.75,speed=.3},
}

local drop_table = {
{sprite=64,onpickup=function() player_hp = min(player_hp + 1, player_hp_max) end},
{sprite=66,onpickup=function() player_money = min(player_money + 1, player_max_money) end},
{sprite=114,onpickup=function() player_money = min(player_money + 5, player_max_money) end}
}

local biomes = {
string_to_number_table("11,11,11,11,11,11,11,11,11,11,3,5")
,string_to_number_table("11,11,11,11,11,3,3,3,3,3,3,3,4,4,4")
,string_to_number_table("12,12,12,12,15,15,11,11,11,11,11,3")
,string_to_number_table("15,15,15,15,15,15,15,15,15,15,15,15,9,9,9,4,4,4")
,string_to_number_table("4,4,4,4,5,5,5,5,6,6,6,6,6,6,6,7,7,7")
,string_to_number_table("6,6,6,6,4,4,4,4,2,2,2,9,9,9,8,8,8,8")
,string_to_number_table("12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,15,11")
,string_to_number_table("5")
,string_to_number_table("4,4,4,4,5,5,5,15,15")
,string_to_number_table("6")
,string_to_number_table("12,15,15,15,15,15,15,9,9,9,9,9,3")
}

local biome_depth = {
string_to_number_table("7,3,1,1,1,1,1,8"),
string_to_number_table("7,3,1,1,1,1,1,1,1,1,2,2,2,5,8,6"),
string_to_number_table("7,11,3,3,3,3,3,1,1,1,1,1,1,1,1,2,2"),
string_to_number_table("7,2,1,4,4,4,4,9,9"),
string_to_number_table("7,3,3,10,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,9,6"),
string_to_number_table("4,4,4,4,4,4,4,4,4,4,9,9,6"),
string_to_number_table("2,2,2,4,4,4,9,9,9"),
string_to_number_table("7,1,4,4,4,4")
}
local biome_music = string_to_number_table("0,0,6,29,21,21,6,25,21,25,6")
local biome_enemies = {
{3}
,{3,4}
,{3,1}
,{3}
,{3,4,5}
,{5,2}
,{1}
,nil
,{3,4,5}
,nil
,nil
}
local town_chance = string_to_number_table("0.01,0.003,0.003,0,0,0,0,1,0,1,0.3")
local town_buildings
local temples = {
{name="water temple",map=15, colour=7,drop="firewand",circle={69,8,5,5}, biomes={7},chance=0.4,boss_id=3,minion_id=1},
{name="wind temple",map=25, colour=7,drop="waterwand",circle={63,8,5,5}, biomes={9,5},boss_id=2,minion_id=5},
{name="life temple",map=35, colour=11,drop="goldwand",circle={58,8,5,5}, biomes={2},boss_id=1,minion_id=3},
{name="fire temple",map=45, colour=9,drop="chalice",circle={75,8,5,5}, biomes={6}, chance=0.8,boss_id=4,minion_id=2}
}
function use_summon_temple(temple,canfunc)
return function(scene0)
if(canfunc(scene0,temple) == false) return
summon_temple(scene0,temple)
end
end
function  can_summon_temple(chunk,temple)
if(chunk.istown == true) return false
local biomefound = false
for b in all(temple.biomes) do
if(b == chunk.biome) biomefound = true
end
if(biomefound == false) return false

srand(chunk.seed + 1000 * chunk.biome)
return rnd() < (temple.chance or 0.2)
end
local item_database = {}
item_database.boat = {name="bOAT"}
item_database.chalice = {name="cHALICE OF gODS"}
item_database.wsword = {name="wDN sWORD"}
item_database.waterwand = {name="wATER wAND",
use=use_summon_temple(temples[1],
function(scene0,temple)
return known_locations[temple.name] == nil and can_summon_temple(scene0.chunk,temple)
end)}
item_database.firewand = {name="fIRE wAND",
use=use_summon_temple(temples[4],
function(scene0,temple)
return known_locations[temple.name] == nil and can_summon_temple(scene0.chunk,temple)
end)}
item_database.goldwand = {name="aIR wAND",
use=use_summon_temple(temples[2],
function(scene0,temple)
return known_locations[temple.name] == nil and can_summon_temple(scene0.chunk,temple)
end)}
item_database.naturewand = {name="eARTH wAND",
use=use_summon_temple(temples[3],
function(scene0,temple)
return known_locations[temple.name] == nil and can_summon_temple(scene0.chunk,temple)
end)}

local current_scene
function _init()
music(06)
current_scene = map_scene(45,15, function(_scene)
show_confirmation(string_to_string_table"one day, while wandering,+you found a magic wand in the+dirt...+you think it could fetch a nice+price in town, or, perhaps,+you might discover the wand's+purpose, if you ask the right+person!",function()
scene_transition(_scene,start_game())
end)
end)
end
local lastx,lasty
function _update60()
step += 1
step %= 120
current_scene:update()
end

function _draw()
current_scene:draw()
end


function start_game()
local start_x,start_y = find_nearest_town(flr(rnd() * 9000 - 4500)*2,flr(rnd() * 9000 - 4500)*2)
known_locations[1] = {x=start_x,y=start_y,name="home",enabled=true}
add_item_to_inventory"wsword"
add_item_to_inventory"naturewand"
return overworld_scene(start_x,start_y)
end
function add_item_to_inventory(id,count)
count = count or nil
local item = {item=item_database[id],id=id,count = count}
add(inventory,item)
return item
end
function get_inventory_item(id)
for item in all(inventory) do
if(item.id == id) then
return item
end
end
return nil
end
function summon_temple(scene0,temple)
show_map = false
scene0:draw()
local t = 0

known_locations[temple.name] = {x=scene0._x,y=scene0._y,px=0, py=16,name=temple.name}

local co_summon = cocreate(function()
mus_current = -1
music(-1)
sfx(sfx_summon_start)
while(t < 9) do
yield()
end
sfx(sfx_summon_journey)

for i=1,4 do
sfx(sfx_summon_repeat)
t = 0
while(t < 0.7) do
scene0:draw()
camera(rnd() * 2, 0)
pal(4,temple.colour)
if(i > 3 ) then
map(temple.map,7,24,40,10,4)
else
map(15,3,24,48,10,4)
end
pal()
yield()
end

yield()
end
local ns = overworld_scene(scene0._x,scene0._y)
ns:draw()
sfx(sfx_summon_complete)
t = 0
while(t < 4) do
yield()
end
current_scene=ns
current_scene:start()
end)
current_scene = {
update = function() end,
draw = function()
t += 1/30
assert(coresume(co_summon))
end
}
end
function player_death()
mus_current = -1
player_invulnerable = 0
local scene = current_scene
show_map = false
local co_summon = cocreate(function()
music(23)
for i = 1, 60 do
yield()
end
player_hp = flr(player_hp_max / 3) + 1
player_x = known_locations[1].px or 0
player_y = known_locations[1].py or 0
scene_transition(scene,overworld_scene(known_locations[1].x,known_locations[1].y))
end)
current_scene = {
update = function(self)
end,
draw = function(self)
assert(coresume(co_summon))
end
}
end
function teleport_to(scene,known_location)

show_map = false
local co_summon = cocreate(function()
local next_scene = overworld_scene(known_location.x,known_location.y)
mus_current = -1
music(-1)
camera()
sfx(sfx_teleport_start)
cls(7)
yield()
for p = 1,5 do
for t = 0,3 do
scene:draw()
yield()
end
for t = 0,3 do
cls(0)
yield()
end
sfx(sfx_teleport_start)
yield()
end
cls(7)
for v=1,10 do
yield()
end
sfx(sfx_teleport_end)
player_x = known_location.px or 0
player_y = known_location.py or 0
current_scene=next_scene
next_scene:start()
end)
current_scene = {
update = function(self)
end,
draw = function(self)
assert(coresume(co_summon))
end
}
end
function scene_transition(scene0,scene1)
local transition_duration = 0.3
local t = 0
local co_transition = cocreate(function()
yield()
while(t < 1) do
camera()
scene0:draw()
camera()
rectfill(0,0,128,128 * t,0)
yield()
end
t = 0
scene1:start()
rectfill(0,0,128,128,0)
yield()
yield()
yield()
t = 0
while(t < 1) do
camera()
camera()
rectfill(0,0,128,128 * (1-t),0)
yield()
end
current_scene = scene1

end)
current_scene = {
update = function(self)
t += 1/30 / transition_duration
end,
draw = function(self)
assert(coresume(co_transition))
end
}
end
local player_is_over_water,player_is_over_lava,player_recoil = false,false,0
local player_last_x,player_last_y = 0,0
function update_player(chunk0)

player_last_x,player_last_y = player_x,player_y
if(player_recoil <=  0 and btn(0)) then
player_x -= player_speed
if(test_player_collision(player_x,player_y,chunk0)) then
player_x = player_last_x
end
player_dir = 0
anim_index += 0.1
end
if(player_recoil <=  0 and btn(1))then
player_x += player_speed
if(test_player_collision(player_x,player_y,chunk0)) then
player_x = player_last_x
end
player_dir = 2
anim_index += 0.1
end
if(player_recoil <=  0 and btn(2))then
player_y -= player_speed
if(test_player_collision(player_x,player_y,chunk0)) then
player_y = player_last_y
end
player_dir = 1
anim_index += 0.1
end
if(player_recoil <=  0 and btn(3)) then
player_y += player_speed
if(test_player_collision(player_x,player_y,chunk0)) then
player_y = player_last_y
end
player_dir = 3
anim_index += 0.1
end
if(player_recoil > 0) then
if(player_dir == 0) then
player_x += 2
elseif(player_dir == 1) then
player_y += 2
elseif(player_dir == 2) then
player_x -= 2
elseif(player_dir == 3) then
player_y -= 2
end
end

local floor = {0,0,0,1,1,0,-1,0,0,-1}
local water = 0
local lava = 0
for f = 1,#floor,2 do
local pc = get_chunk_colour(chunk0,floor[f]+player_x+64,floor[f+1]+player_y+64)
if(pc == 12) water += 1
if(pc == 8) lava += 1
end
player_is_over_water = water >= 5
player_is_over_lava = lava >= 5
if(player_is_over_water and (is_over_entrance_border(player_x,player_y,chunk0) == false) and get_inventory_item'boat' == nil) then
player_x = player_last_x
player_y = player_last_y
player_is_over_water = (is_over_entrance_border(player_x,player_y,chunk0))
end

if(player_attack_timer > 0) player_attack_timer -= 1
if(player_swish_timer > 0) player_swish_timer -= 1
if(btnp(4) and player_attack_timer <= 0) then
if(player_hp == player_hp_max and player_projectile_dir == nil) then
sfx(sfx_player_weapon)
player_projectile_x = player_x
player_projectile_y = player_y
player_projectile_dir = player_dir
player_attack_timer = player_attack_cooldown
end
if(player_hp < player_hp_max) then
sfx(sfx_player_weapon)
player_swish_timer = player_swish_duration
player_attack_timer = player_attack_cooldown
end
end
if(test_player_collision(player_x,player_y,chunk0)) then
player_x = player_last_x
player_y = player_last_y
end
if(player_projectile_dir == 0) then
player_projectile_x -= 3
elseif(player_projectile_dir == 1) then
player_projectile_y -= 3
elseif(player_projectile_dir == 2) then
player_projectile_x += 3
elseif(player_projectile_dir == 3) then
player_projectile_y += 3
end
if(player_projectile_y < -64 or player_projectile_y > 64 or player_projectile_x < -64 or player_projectile_x > 64) then
player_projectile_dir = nil
end
if(player_projectile_dir ~= nil and chunk0 ~= nil) then
for enemy in all(chunk0.enemies) do
if(player_projectile_dir ~= nil and rect_intersect(player_projectile_x-4,player_projectile_y-4,player_projectile_x+4,player_projectile_y+4, enemy.x,enemy.y,enemy.x+8,enemy.y+8)) then
enemy:take_damage(player_projectile_dir)
player_projectile_dir = nil
end
end
end
if(player_swish_timer > 0) then
local x0,y0,x1,y1
if(player_dir == 0) x0,x1,y0,y1 = -8,-10,-10,10
if(player_dir == 1) x0,x1,y0,y1 = 10,-10,-8,-10
if(player_dir == 2) x0,x1,y0,y1 = 8,10,10,-10
if(player_dir == 3) x0,x1,y0,y1 = -10,10,8,10
if(chunk0 ~= nil) then
for enemy in all(chunk0.enemies) do
if(player_swish_timer > 0 and rect_intersect(player_x+x0,player_y+y0, player_x+x1,player_y+y1,enemy.x,enemy.y,enemy.x+8,enemy.y+8)) then
enemy:take_damage(player_dir)
end
end
end
end
player_invulnerable = max(0,player_invulnerable - 1)
player_recoil = max(0,player_recoil - 1)
if(chunk0 ~= nil) then
for enemy in all(chunk0.enemies) do
if(player_invulnerable <= 0 and rect_intersect(
player_x-2,player_y-2,
player_x+2,player_y+2,
enemy.x,enemy.y,
enemy.x+8,enemy.y+8
)) then
player_invulnerable = 60
player_recoil = 15
player_hp -= 1
sfx(11)
end
end
end
for bullet in all(bullets) do
if(player_invulnerable <= 0 and rect_intersect(player_x-2,player_y-2,player_x+2,player_y+2, bullet.x,bullet.y,bullet.x + 2, bullet.y + 2)) then
del(bullets,bullet)
player_invulnerable = 60
player_recoil = 15
player_dir = bullet.dir
player_hp -= 1
sfx(11)
end
end
for pickup in all(current_scene.pickups) do
pickup.lifetime -=1
if(pickup.lifetime <= 0) del(current_scene.pickups,pickup)
if(rect_intersect(player_x-2,player_y-2,player_x+2,player_y+2, pickup.x,pickup.y,pickup.x+8,pickup.y+8)) then
pickup.onpickup()
del(current_scene.pickups,pickup)
sfx(1)
end
end
if(player_hp <= 0) then
player_death()
end

end
function draw_player_and_weapons(chunk0)
camera(-64,-64)

local player_spr = player_walk[flr(anim_index % #player_walk) + 1]
local outline_colour = (player_invulnerable > 0 and step%12 < 6 and 7) or 0
if(player_is_over_water) then
if(get_inventory_item'boat' == nil) then
spro(outline_colour,player_spr,player_x-4,player_y-4)
spr(player_spr,player_x-4,player_y-4)
rectfill(player_x - 4,player_y,player_x+4,player_y + 4,12)
else
spro(outline_colour,54,player_x-4,player_y-4)
spr(54,player_x-4,player_y-4)
end
else
spro(outline_colour,player_spr,player_x-4,player_y-4)
spr(player_spr,player_x-4,player_y-4)
end
if(test_player_trigger(player_x,player_y,chunk0)) then
spro(0,spr_interact,player_x-4,player_y - 12)
spr(spr_interact,player_x-4,player_y - 12)
end
if(player_projectile_dir == 0 or player_projectile_dir == 2) then
spro(7,spr_player_projectile_h,player_projectile_x-4,player_projectile_y-4)
spr(spr_player_projectile_h,player_projectile_x-4,player_projectile_y-4)
elseif(player_projectile_dir == 1 or player_projectile_dir == 3) then
spro(7,spr_player_projectile_v,player_projectile_x-4,player_projectile_y-4)
spr(spr_player_projectile_v,player_projectile_x-4,player_projectile_y-4)
end
if(player_swish_timer > 0) then
local pt = player_swish_timer/player_swish_duration
local x0,x1,y0,y1
if(player_dir == 0) x0,x1,y0,y1 = -6,-6,-8,8
if(player_dir == 1) x0,x1,y0,y1 = 8,-8,-6,-6
if(player_dir == 2) x0,x1,y0,y1 = 6,6,8,-8
if(player_dir == 3) x0,x1,y0,y1 = -8,8,6,6
local xt0,xt1 = (x1-x0) * pt + x0 + player_x,(x1-x0) * (pt+0.1) + x0 + player_x
local yt0,yt1 = (y1-y0) * pt + y0 + player_y,(y1-y0) * (pt+0.1) + y0 + player_y
line(xt0,yt0,xt1,yt1,7)
end
end
function map_scene(x,y,onnext)
return {
start=function() end,
update=function(self)
if(onnext ~= nil and btnp(4)) onnext(self)
end,
draw=function()
cls(0)
map(x,y,0,0,16,16)
if(onnext ~= nil) print("press \x8e to start",32,108,0)
end
}
end
function boss_scene(temple)
player_projectile_dir = nil
player_invulnerable = 120
local boss_max,reward = temple.boss_id * 5,temple.boss_id * 10
bullets = {}
boss = create_boss()
enemies = {boss}
for ei = 1,temple.boss_id * 2 do
add(enemies,create_enemy(enemy_templates[temple.minion_id]))
end
boss.hp = boss_max

return {
chunk={
enemies=enemies
},
start = function(self)
player_x, player_y = 0,32
play_music(18)
end,
update = function(self)
if(#enemies == 0) then
local dropped = string_to_string_table("you got $"..reward.."!+you got a heart!")
player_money = min(player_money + reward, player_max_money)
player_hp_max = min(player_hp_max + 1, 10)
if(get_inventory_item(temple.drop) == nil) add(dropped,"you got the "..add_item_to_inventory(temple.drop).item.name .."!")

play_music(24)
show_confirmation(dropped,function()
if(get_inventory_item"chalice" ~= nil) then
scene_transition(self,map_scene(61,15))
else
teleport_to(self,known_locations[1]) end
end)
end

update_scene(self)
player_x = mid(-44,player_x,44)
player_y = mid(-44,player_y,44)
end,
draw = function(self)
cls (0)
map(13,15,0,0,16,16)
draw_scene(self)
rectfill(8,0,120,8,0)
rectfill(9,1,119,7,1)

if(#enemies > 0) rectfill(9,1,9+110*(boss.hp/boss_max),7,2)
print("boss",10,2,7)
end
}
end
function draw_scene(scene)
camera(0,0)

if(scene.chunk ~= nil) then
draw_chunk(scene.chunk)
draw_chunk_borders(scene.chunk)
end
camera(-64,-64)
if(scene.chunk ~= nil and scene.chunk.enemies ~= nil) then
for enemy in all(scene.chunk.enemies) do
enemy:draw()
end
end
for bullet in all(bullets) do
spr(bullet.sprite,bullet.x-4,bullet.y-4)
end
if(scene.pickups ~= nil) then
for pickup in all(scene.pickups) do
if(pickup.lifetime > 80 or pickup.lifetime % 8 < 4) spr(pickup.sprite,pickup.x,pickup.y)
end
end
draw_player_and_weapons(scene.chunk)

camera(0,0)
rectfill(108,117,127,127,1)
print("$"..player_money,111,120,7)
for i = 0, player_hp_max-1 do
spro(0,64,i*8+2,118)
if(i < player_hp) spr(64,i*8+2,118)
end
end
function update_scene(scene)
update_player(scene.chunk)
update_bullets()
if(scene.chunk ~= nil) then
for enemy in all(scene.chunk.enemies) do
enemy:update()
end
end
end
function overworld_scene(chunk_x,chunk_y)
local chunk0,collision_map = generate_chunk(chunk_x,chunk_y)
lastx,lasty,bullets ,player_projectile_dir = chunk_x,chunk_y,{},nil
local draw_player = true
local inventory_menu = create_menu(
map_table(inventory, function(k,v) if(v.count ~= nil) then return v.item.name.."X"..v.count else return v.item.name end end),
map_table(inventory, function(k,v) return k end)
)
local locations_menu = create_menu(
map_table(known_locations, function(k,v) return (v.enabled and v.name) or nil end),
map_table(known_locations, function(k,v) return (v.enabled and k) or nil end),4
)
locations_menu.active = false

return {
chunk = chunk0,
_x = chunk_x,
_y = chunk_y,
use_item = function(self,item_index)
local inv = inventory[item_index]
local item = inv.item
if(item == nil) return
if(item.use == nil) return
if(inv.count == nil or(inv.count ~= nil and inv.count > 0)) then
sfx(sfx_item_use)
item.use(self)
if(inv.count ~= nil) inv.count -= 1
end
end,
start = function(self)
player_x, player_y = find_safest_spot(player_x,player_y,chunk0)
player_recoil = 0

if(chunk0.istown) then
play_music(25)
else
play_music(biome_music[chunk0.biome])
end
end,
update = function(self)
if(show_map == false) then

local trigger = test_player_trigger(player_x,player_y,chunk0)
if(trigger) then
if(btnp(4)) then
sfx(sfx_interact)
player_projectile_dir = nil
trigger.building.dialog(self)
return
end
end
if(btnp(5)) then
show_map = true
return
end
update_scene(self)

if(player_x > 64) then
chunk_x += 2
player_x = -64
end
if(player_x < -64) then
chunk_x -= 2
player_x = 64
end
if(player_y > 64) then
chunk_y += 2
player_y = -64
end
if(player_y < -64) then
chunk_y -= 2
player_y = 64
end
chunk_x = mid(-9000,chunk_x,9000)
chunk_y = mid(-9000,chunk_y,9000)
if(chunk_x ~= lastx or chunk_y ~= lasty) then
draw_player = false
scene_transition(self,overworld_scene(chunk_x,chunk_y))
end


else
if(btnp(0) or btnp(1)) then
if(locations_menu.active) then
locations_menu.active = false
inventory_menu.active = true
else
locations_menu.active = true
inventory_menu.active = false
end
sfx(sfx_menu_change)
end
if(btnp(3)) then
locations_menu:next()
inventory_menu:next()
sfx(sfx_menu_select)
end
if(btnp(2)) then
locations_menu:back()
inventory_menu:back()
sfx(sfx_menu_select)
end
if(btnp(4) and locations_menu.active and locations_menu:selected_item() ~= nil) then
teleport_to(self,known_locations[locations_menu:selected_item()])
end
if(btnp(4) and inventory_menu.active and inventory_menu.selected_item() ~= nil) then
self:use_item(inventory_menu.selected_item())
end
if(btnp(5)) then
show_map = false
end
end
end,
draw = function(self)
cls (0)
draw_scene(self)

if(show_map) then
pal()
cls(0)
local title = biome_names[chunk0.biome]
if(chunk0.istown and town_chance[chunk0.biome] < 1) then
title = biome_names[chunk0.biome] .. " town"
end
camera(-94,-45)
draw_map(chunk_x,chunk_y)

print(title,-30,-40,7)
print(chunk_x..","..chunk_y,-30,34,7)
if(locations_menu.active) then
local selected = known_locations[locations_menu.selected_item()]
local dx,dy = selected.x-chunk_x,selected.y-chunk_y
dx = mid(-31,dx,30)
dy = mid(-31,dy,30)
rect(dx-1,dy-1,dx+2,dy+2,(step < 6 and 11) or 7)
end
rectfill(0,0,1,1,(step%12 < 6 and 10) or 8)
camera(-64,-88)
print("known locations",0,0,10)
locations_menu:draw()
camera(-4,-4)
print("inventory",0,0,10)
inventory_menu:draw()
end
end
}
end




function create_bullet(x,y,dir,sprite)
add(bullets, {
x=x+4,
y=y+4,
dir=dir,
sprite=sprite
})
end
function update_bullets()
for bullet in all(bullets) do
if(bullet.dir == 0) bullet.x += 0.6
if(bullet.dir == 1) bullet.y += 0.6
if(bullet.dir == 2) bullet.x -= 0.6
if(bullet.dir == 3) bullet.y -= 0.6
if(bullet.x < -64 or bullet.x > 64 or bullet.y < -64 or bullet.y > 64) del(bullets,bullet)
end
end
function create_pickup(_x,_y, template)
current_scene.pickups = current_scene.pickups or {}
local pickup = {x=_x,y=_y,lifetime = 300}
for k,p in pairs(template) do
pickup[k] = p
end
add(current_scene.pickups,pickup)
return pickup
end
function create_boss()
local s,dir,diry,x,y,invulnerable = 0.5,-1,-1,0,-40,0
return {
hp = 20,
invulnerable = 0,
x=0,
y=0,
take_damage=function(self)
if(invulnerable > 0) return
self.hp -= 1
invulnerable = 30
if(self.hp <= 0) del(current_scene.chunk.enemies,self)
end,
update=function(self)
x += s*dir
y += (1-s)*diry
self.x = x
self.y = y
if(x >= 32) dir = -1
if(x <= -40) dir = 1
if(y >= 40) diry = -1
if(y <= -40) diry = 1
if(step == 0) s = rnd() * 0.2 + 0.4
invulnerable = max(0,invulnerable -1)

end,
draw=function(self)
if(invulnerable % 6 < 3) then
spr(117,x,y)
end
spr(118,x-8,y,1,1,true)
spr(118,x+8,y)
end
}

end
function create_enemy(template)
local enemy = {}
for k,v in pairs(template) do
enemy[k] = v
end
local bullet_countdown = (rnd() * (enemy.every or 0) / 2) + ((enemy.every or 0)  / 2)
enemy.x,enemy.y,enemy.dir,enemy.dir_time,enemy.speed,enemy.frame,enemy.invulnerable,
enemy.take_damage,enemy.update,enemy.draw =  (flr(rnd() * 10) - 5)*10,(flr(rnd() * 10) - 5)*10, flr(rnd() * 4),rnd() * 30 + 120, enemy.speed or .2,0,0,
function(self)
if(self.invulnerable > 0) then return end
self.hp -= 1
self.invulnerable = 10
if(self.hp <= 0) then
srand(self.x * self.x + self.y * self.y)
if(rnd() < (self.drop_chance or 0.33)) then
sfx(5)
create_pickup(self.x,self.y,  drop_table[flr(rnd()*#drop_table) + 1])
end
del(current_scene.chunk.enemies,self)
end
end,
function(self)
local dir = self.dir
local s = self.speed * (((self.invulnerable > 0) and 0.5) or 1)

if(dir == 0) self.x += s
if(dir == 1) self.y += s
if(dir == 2) self.x -= s
if(dir == 3) self.y -= s
if(self.invulnerable > 0) self.invulnerable -= 1
self.dir_time -= 1
if(self.dir_time <= 0 or self.x < -44 or self.y < -44 or self.x > 44 or self.y > 44) then
enemy.dir = flr(rnd() * 4)
enemy.dir_time = rnd() * 30 + 120
end
self.frame += 0.1
self.frame %= #self.anim
self.x = mid(-44,self.x,44)
self.y = mid(-44,self.y,44)
if(self.every ~= nil) then
bullet_countdown -= 1
if(bullet_countdown <= 0) then
bullet_countdown = self.every
create_bullet(self.x,self.y,dir,self.shoots or 48)
end
end
end,
function(self)
spro((self.invulnerable > 0 and 7) or 8,self.anim[flr(self.frame) + 1],self.x,self.y)
spr(self.anim[flr(self.frame) + 1],self.x,self.y)
end
return enemy
end
function make_inn_dialogue(title,lines,onselect)
return function(scene)
local dialog = {
x=12,y=10,w=100,h=32,
menu = create_menu(string_to_string_table"yes+no",{true,false},2),
title=title,
lines=lines,
select=onselect
}
show_dialogue(scene,dialog)
end
end
function make_hint_dialogue()
local offset = rnd() * 100
return function(scene)
srand(scene.chunk.seed + offset)
local hints = {}
if(get_inventory_item"firewand" ~= nil and known_locations["fire temple"] == nil) add(hints,string_to_string_table"i heard there used to be monks+who worshiped the fire god!+they had a temple+in a volcano!")
if(get_inventory_item"waterwand" ~= nil and known_locations["water temple"] == nil) add(hints,string_to_string_table"i remember making my way to+the temple in the lake+but one day it just vanished+under the waves!")
if(get_inventory_item"boat" == nil ) add(hints,string_to_string_table"you can buy a boat+from any shop!+it's like the only thing+they sell!")
if(get_inventory_item"naturewand" ~= nil and known_locations["life temple"] == nil) add(hints,string_to_string_table"the god of life made his home+in the forest!+druids used to worship him+around a stone circle!")
if(get_inventory_item"goldwand" ~= nil and known_locations["wind temple"] == nil) add(hints,string_to_string_table"is that a wand of the air+godess? her temple was in+the mountains+you should try and find it!")
add(hints, string_to_string_table"tales tell of four wands+each wand allowed someone+to summon a temple of the+gods! (in the right place+of course)")

show_confirmation(hints[ceil(rnd() * #hints)])
end
end
function show_confirmation(lines,onclose)
local scene = current_scene
if(type(lines) == 'string') lines = {lines}
current_scene = {
update = function(self)
if(btnp(5) and onclose ~= nil) then
onclose()
elseif(btnp(5)) then
current_scene = scene
end
end,
draw = function(self)
local h = #lines * 8
camera(-2,(h-128)/2)
rectfill(-1,-1,124,h,5)
for l = 1, #lines do
print(lines[l],1,(l-1) * 8 + 1,7)
end
end
}
end

function show_dialogue(scene,dialog)

local x,y,w,h = dialog.x or 10,dialog.y or 10, dialog.w or 108,dialog.w or 108
if(dialog.menu) dialog.menu:reset()
current_scene = {
_x=scene._x,
_y=scene._y,
update=function(self)
if(self.close == true) then
current_scene = scene
return
end
if(btnp(5)) current_scene = scene
if(btnp(2) and dialog.menu) dialog.menu:next()
if(btnp(3) and dialog.menu) dialog.menu:back()
if(btnp(4) and dialog.menu) then
if(dialog:select(dialog.menu.selected_item())) then
current_scene = scene
end
end
end,
draw = function(self)
camera()
rectfill(x,y,x+w,y+12,5)
rect(x,y,x+w,y+12,0)
print(dialog.title or "dialog",x + 2,y+2)
rectfill(x,y+12,x+w,y+h,5)
rect(x,y+12,x+w,y+h,0)
local ty = y + 16
if(dialog.lines) then
for line in all(dialog.lines) do
print(line, x + 2, ty,7)
ty += 8
end
end
camera(-x-2,-ty - 2)
if(dialog.menu) dialog.menu:draw()
end
}

end
function map_table(t,m)
if(t == nil) return {}
local mapped = {}
for k,v in pairs(t) do
local n = m(k,v)
if(n ~= nil) add(mapped,n)
end
return mapped
end
function create_menu(labels,items,max)
max = max or 10
local selected = 0
local starti = 1
return {
active = true,
chevron_l = "\142 ",
chevron_r = "",
reset=function(self)
selected = 0
starti = 1
end,
selected_index=function()
return selected + 1
end,
selected_item=function(self)
return items[selected + 1]
end,
draw=function(self)
if(selected+1 < starti) then
starti = selected+1
elseif(selected+1 >= starti + max) then
starti = selected+1
end
local y = 1
if(starti > 1) then
print("^",0,y * 8,7)
y += 1
end
for i = starti,min(#items,starti + max - 1) do
if(self.active and i == selected + 1) then
print(self.chevron_l .. labels[i] .. self.chevron_r,0,y * 8,7)
else
print(labels[i],0,y * 8,7)
end
y += 1
end
if(starti + max - 1 < #items) then
print("v",0,y * 8,7)
y += 1
end
end,
next=function(self)
if(self.active == false) return
selected += 1
if(selected >= #labels) selected = 0
end,
back=function(self)
if(self.active == false) return
selected -= 1
if(selected < 0) selected = #labels - 1
end
}
end
function play_music(m)
if(mus_current == m) return
music(m)
mus_current = m
end
function spro(oc,n,x,y,w,h,fx,fy)
for c = 0,15 do
pal(c,oc)
end
spr(n,x-1,y)
spr(n,x+1,y)
spr(n,x,y-1)
spr(n,x,y+1)
pal()
palt()
end


function draw_map(cx,cy)
for ix=-32,31, 2 do
for iy =-32,31, 2 do
local c_chunk_x, c_chunk_y = (cx + ix), (cy + iy)
local biome,istown = get_biome(c_chunk_x,c_chunk_y)
if(istown) then
rectfill(ix,iy,ix+1,iy+1,7)
else
rectfill(ix,iy,ix+1,iy+1,biome_map_colours[biome])
end
end
end
end
function draw_chunk_borders(chunk)
if(chunk == nil or chunk.borders == nil) return
local right = chunk.borders[1]
local bottom = chunk.borders[2]
local left = chunk.borders[3]
local top = chunk.borders[4]
if(right[2] ~= chunk.istown) then
map(0,0,120,0,1,16)
end
if(left[2] ~= chunk.istown) then
map(0,0,0,0,1,16)
end
if(top[2] ~= chunk.istown) then
map(0,0,0,0,16,1)
end
if(bottom[2] ~= chunk.istown) then
map(0,0,0,120,16,1)
end
if(chunk.biome == 7) then
if(top[1] ~= 7) then
map(29,15,0,0,16,1)
end
if(right[1] ~= 7) then
map(29,15,120,0,1,16)
end
if(bottom[1] ~= 7) then
map(29,15,0,120,16,1)
end
if(left[1] ~= 7) then
map(29,15,0,0,1,16)
end
end
end
function draw_building_at(x,y,building)
map(building.map[1],building.map[2],x,y,building.map[3],building.map[4])
end
function is_over_entrance_border(x,y,chunk)
if(chunk.istown) return true
if((x < -56 and y < -56)
or (x < -56 and y > 56)
or (x > 56 and y > 56)
or (x > 56 and y < -56))  then return true end
local has_water_right = (chunk.borders[1][1] == 7) and (chunk.biome == 7)
local has_water_bottom = (chunk.borders[4][1] == 7) and (chunk.biome == 7)
local has_water_left = (chunk.borders[3][1] == 7) and (chunk.biome == 7)
local has_water_top = (chunk.borders[2][1] == 7)  and (chunk.biome == 7)
if(x < -56 and has_water_left == false) return true
if(x > 56 and has_water_right == false) return true
if(y < -56 and has_water_bottom == false) return true
if(y > 56 and has_water_top == false) return true
return false
end
function get_chunk_colour(chunk,x,y,scale)
if(chunk == nil or chunk.heights == nil or chunk.istown) return 0
scale = scale or 128
local chunk_w = scale / 64
local c_v = biomes[chunk.biome]
local height = chunk.heights[mid(1,flr(x/chunk_w)+1,#chunk.heights)][mid(1,flr(y/chunk_w)+1,#chunk.heights)]
if(height == nil) then
return 0
end
return c_v[ceil((height+1) * 0.5 * #c_v)]
end
function draw_chunk(chunk)
if(chunk == nil or chunk.borders == nil or chunk.heights == nil) return

if(chunk.buildings ~= nil) then
cls(5)

draw_building_at(8,8,chunk.buildings[1])
draw_building_at(8,88,chunk.buildings[2])
draw_building_at(88,8,chunk.buildings[3])
draw_building_at(88,88,chunk.buildings[4])
draw_building_at(48,48,chunk.buildings[5])
return
end
local colours = biomes[chunk.biome]

for ix=0,#chunk.heights-1 do
for iy=0,#chunk.heights[ix+1]-1 do
local c_v = colours
local c =  c_v[ceil((chunk.heights[ix+1][iy+1]+1) * 0.5 * #c_v)]
rectfill(ix*2,iy*2,ix*2 + 2,iy*2 + 2,c)
end
end
for special in all(chunk.special) do
if(type(special.map) == 'table') then map(special.map[1],special.map[2],special.x,special.y,special.map[3],special.map[4])
else map(special.map,7,special.x,special.y,10,4) end
end
end
function get_buildings(chunk)
if(chunk.istown == false) return nil
local buildings = {}
for i = 1,#town_buildings do
add(buildings,town_buildings[i])
end
srand(chunk.seed)
return shuffle(buildings)
end
function test_player_collision(x,y,chunk)
if(chunk == nil) return false
for collision_check in all(chunk.collision) do
if(collision_check[1](x+64,y+64)) return true
end

return false
end
function test_player_trigger(x,y,chunk)
if(chunk == nil) return nil
for collision_check in all(chunk.triggers) do
if(collision_check[1](x+64,y+64)) return collision_check
end
return nil
end

function find_safest_spot(x,y,chunk)
if(test_player_collision(x,y,chunk) == false) return x,y
for d = 5, 200,5 do
local xpd = mid(0,x + d,128)
local xmd = mid(0,x - d,128)
local ypd = mid(0,y + d,128)
local ymd = mid(0,y - d,128)
if(false == test_player_collision(xpd,y,chunk))  then return xpd,y end
if(false == test_player_collision(x,ypd,chunk))  then return x,ypd end
if(false == test_player_collision(xmd,y,chunk))  then return xmd,y end
if(false == test_player_collision(x,ymd,chunk)) then  return x,ymd end
end
return x,y
end
function rect_intersect(
ax1,ay1,
ax2,ay2,
bx1,by1,
bx2,by2)
ax1,ay1, ax2,ay2, bx1,by1, bx2,by2 = min(ax1,ax2),min(ay1,ay2),   max(ax1,ax2),max(ay1,ay2),  min(bx1,bx2),min(by1,by2),  max(bx1,bx2),max(by1,by2)
if(ax2 < bx1 or ax1 > bx2 or ay2 < by1 or ay1 > by2) return false
return true
end
function get_chunk_collisions(chunk)

local collisions = {}
local triggers = {}
local add_rect = function(ox,oy,ow,oh)
return {
function(_x,_y)
return rect_intersect(_x-2,_y-2,_x+2,_y+2,ox,oy,ox+ow,oy+oh)
end
}
end
if(chunk.buildings ~= nil) then
local building_collision = function(ox,oy,building,box)
box = box or "collision"
if(building == nil or building[box] == nil) return {function() return false end, function() end}
local dx,dy, width,height= ox+building[box][1]*8,oy+building[box][2]*8, building[box][3]*8,building[box][4]*8
local bounds = add_rect(dx,dy,width,height)
bounds.building = building
return bounds
end
add(collisions,building_collision(8,8,chunk.buildings[1]))
add(collisions,building_collision(8,88,chunk.buildings[2]))
add(collisions,building_collision(88,8,chunk.buildings[3]))
add(collisions,building_collision(88,88,chunk.buildings[4]))
add(collisions,building_collision(48,48,chunk.buildings[5]))

add(triggers,building_collision(8,8,chunk.buildings[1],"trigger"))
add(triggers,building_collision(8,88,chunk.buildings[2],"trigger"))
add(triggers,building_collision(88,8,chunk.buildings[3],"trigger"))
add(triggers,building_collision(88,88,chunk.buildings[4],"trigger"))
add(triggers,building_collision(48,48,chunk.buildings[5],"trigger"))
end

if(chunk.borders[1][2] ~= chunk.istown) then
add(collisions,add_rect(120,0,8,48))
add(collisions,add_rect(120,80,8,48))
end
if(chunk.borders[2][2] ~= chunk.istown) then
add(collisions,add_rect(0,120,48,8))
add(collisions,add_rect(80,120,48,8))
end
if(chunk.borders[3][2] ~= chunk.istown) then
add(collisions,add_rect(0,0,8,48))
add(collisions,add_rect(0,80,8,48))
end
if(chunk.borders[4][2] ~= chunk.istown) then
add(collisions,add_rect(0,0,48,8))
add(collisions,add_rect(80,0,48,8))
end
for special in all(chunk.special) do
if(special.collision ~= nil) add(collisions,add_rect(special.x+special.collision[1]*8,special.y+special.collision[2]*8,special.collision[3]*8,special.collision[4]*8))

if(special.trigger ~= nil) then
local bounds = add_rect(special.x+special.trigger[1]*8,special.y+special.trigger[2]*8,special.trigger[3]*8,special.trigger[4]*8)
bounds.building = special
add(triggers,bounds)
end
end
return collisions,triggers
end
function shuffle(tbl)
for i = #tbl, 2, -1 do
local j = ceil(rnd(i))
tbl[i], tbl[j] = tbl[j], tbl[i]
end
return tbl
end

function find_nearest_town(x,y)
local ix,iy,dx,dy,cx,cy,t,istown= 0,0,0,-1,0,0,nil,false

while istown == false do
if (ix == iy or (ix < 0 and ix == -iy) or (ix > 0 and ix == 1-iy)) dx, dy = -dy, dx
ix, iy = ix+dx, iy+dy
cx,cy = ix*2,iy*2
t,istown = get_biome(cx+x,cy+y)

end
return cx+x,cy+y
end
function get_biome(x,y)
if(x < -9000 or x > 9000 or y < -9000 or y > 9000) return 0
srand(x * x + y * y)
local b = (Simplex2D(x*0.005,y*0.005) + 1) / 2
local bd = biome_depth[ceil(b * #biome_depth)]
local bc = (Simplex2D(x*0.06,y*0.06) + 1) / 2
local biome_id = bd[ceil(bc * #bd)]
return biome_id,  rnd() <= (town_chance[biome_id] or 0)
end
function generate_chunk(x,y)
if(x < -9000 or x > 9000 or y < -9000 or y > 9000) return nil
local chunk = {}
local freq = 0.03125
chunk.seed = x * x + y * y
chunk.biome, chunk.istown = get_biome(x,y)
chunk.buildings = get_buildings(chunk)
chunk.x,chunk.y = x,y,{},{}
chunk.heights, chunk.borders, chunk.enemies = {},{},get_chunk_enemies(chunk)

add(chunk.borders,{get_biome(x + 2,y)})
add(chunk.borders,{get_biome(x,y + 2)})
add(chunk.borders,{get_biome(x - 2,y)})
add(chunk.borders,{get_biome(x,y - 2)})
chunk.special = {}
for t in all(temples) do
local loc = known_locations[t.name]
if(loc ~= nil and loc.x == x and loc.y ==y) then
add(chunk.special,{name=t.name,colour=t.colour,map=t.map,x=24,y=40,collision={0,0,10,4}, trigger={4,4,2,1}, dialog=function()

known_locations[t.name].enabled = true
scene_transition(current_scene,boss_scene(t))
end})
elseif(can_summon_temple(chunk,t)) then
add(chunk.special,{name=t.name.."circle",colour=t.colour,map=t.circle,x=44,y=44})
end
end
for ix = 0,63 do
local row = {}
add(chunk.heights ,row)
for iy = 0,63 do
add(row,Simplex2D(ix*freq+x,iy*freq+y))
end
end
chunk.collision,chunk.triggers = get_chunk_collisions(chunk)
return chunk
end
function get_chunk_enemies(chunk)
if(chunk.istown) return {}
for k,v in pairs(known_locations) do
if(v.x == chunk.x and v.y == chunk.y) return {}
end
srand(chunk.seed + 10000)
local count = flr(rnd()*5)
local enemy_types = biome_enemies[chunk.biome]
if(enemy_types == nil) return {}
local enemies = {}
for i = 1,count do
local enemy = create_enemy(enemy_templates[enemy_types[flr(rnd() * #enemy_types) + 1 ]])
add(enemies,enemy)
end
return enemies
end



local perm_string = "151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180,180"
local Perms = {}


local cn = ""
local ci = 0
for d=1,#perm_string do
local n = sub(perm_string,d,d)
if(n ~= ",") then
cn = cn .. n
else
Perms[ci] , Perms[ci + 256]= cn,cn

ci += 1
cn = ""
end
end
Perms[ci] , Perms[ci + 256] = cn,cn


local Grads3 = {
string_to_number_table"1, 1, 0", string_to_number_table"-1, 1, 0", string_to_number_table"1, -1, 0", string_to_number_table"-1, -1, 0 ",
string_to_number_table"1, 0, 1", string_to_number_table"-1, 0, 1", string_to_number_table"1, 0, -1", string_to_number_table"-1, 0, -1 ",
string_to_number_table"0, 1, 1", string_to_number_table"0, -1, 1", string_to_number_table"0, 1, -1", string_to_number_table" 0, -1, -1"
}

for row in all(Grads3) do
for i=0,2 do
row[i]=row[i+1]
end

end

for i=0,11 do
Grads3[i]=Grads3[i+1]
end


function GetN2d (bx, by, x, y)
local t = .5 - x * x - y * y
local index = Perms[bx + Perms[by] ] % 12
return max(0, (t * t) * (t * t)) * (Grads3[index][0] * x + Grads3[index][1] * y)
end





function Simplex2D (x, y)
local s = (x + y) * 0.366025403
local ix, iy = flr(x + s), flr(y + s)
local t = (ix + iy) * 0.211324865
local x0 = x + t - ix
local y0 = y + t - iy
ix, iy = band(ix, 255), band(iy, 255)
local n0 = GetN2d(ix, iy, x0, y0)
local n2 = GetN2d(ix + 1, iy + 1, x0 - 0.577350270, y0 - 0.577350270)
local xi = 0
if x0 >= y0 then xi = 1 end
local n1 = GetN2d(ix + xi, iy + (1 - xi), x0 + 0.211324865 - xi, y0 - 0.788675135 + xi)
return 70 * (n0 + n1 + n2)
end




town_buildings = {
{name="shop",map={1,1,4,3},collision={0,0,4,3},trigger={2,3,1,1},dialog=make_inn_dialogue(
"shop",string_to_string_table"buy a boat for $100?",function(dlg,confirm)
if(confirm == true) then
local scene = current_scene
if(player_money < 100) then
show_confirmation(string_to_string_table"you don't have enough money!",function()
scene.close = true
current_scene = scene
end )
return false
end
add_item_to_inventory"boat"
player_money -= 100
show_confirmation(string_to_string_table"you bought a boat!",function()
scene.close = true
current_scene = scene
end  )
return false
end
return true
end
)},
{name="inn",map={9,1,4,3},collision={0,0,4,3},trigger={1,3,2,1},dialog=make_inn_dialogue(
"inn",string_to_string_table"make this inn your home?",function(dlg,confirm)
if(confirm == true) then
local scene = current_scene
known_locations[1]= {x=current_scene._x,y=current_scene._y,px=player_x, py=player_y,name="inn",enabled=true}
show_confirmation(string_to_string_table"this inn is now your home",function()
scene.close = true
current_scene = scene
end  )
return false
end
return true
end
)},
{name="house",map={1,4,4,3},collision={0,0,4,3},trigger={2,3,1,1},dialog=make_hint_dialogue()},
{name="chapel",map={1,7,4,3},collision={0,0,4,3},trigger={2,3,1,1},dialog=make_inn_dialogue(
"chapel",string_to_string_table"heal your wounds for $5?",function(dlg,confirm)
if(confirm == true) then
local scene = current_scene
if(player_hp == player_hp_max) then
show_confirmation(string_to_string_table"you look perfectly healthy!",function()
scene.close = true
current_scene = scene
end )
return false
end
if(player_money < 5) then
show_confirmation(string_to_string_table"you don't have enough money!",function()
scene.close = true
current_scene = scene
end  )
return false
end
player_hp = player_hp_max
player_money -= 5
show_confirmation(string_to_string_table"you are fully healed!",function()
scene.close = true
current_scene = scene
end  )
return false
end
return true
end
)},
{name="pond",map={5,7,4,3},collision={1,1,2,1}},
{name="graves",map={9,7,4,3},collision={0,0,4,3}},
{name="grove",map={1,10,4,4}},
{name="well",map={5,10,4,4},collision={1,1,2,2}},
{name="house2",map={9,10,4,4},collision={1,0,2,3},trigger={2,3,1,1},dialog=make_hint_dialogue()},
{name="tree",map={1,14,3,3},collision={1,1,1,1}}
}

__gfx__
00012000606660666066606660666066606660666066606616666661feeeeee87bbbbbb30000004000000030000300000b0dd030777777674f9f4fff7999a999
07d1257000000000000000000000000000000000007777006d6666d6e8888882b3333331040000000300000003000030d3000b0d76777777fffff9f49999979a
057d57d0666066606660566060333306608888066676d75062444426e8811882b33773310000040000000300000003b0000b030077777677ff4fffff99a99999
22566d11000000000000000000333300008888000077770064222246e8866882b3366531000400000003000000b00bb0b0030000777677779fff9ff999997997
11d6652206660666066605666033330660888806067d675664442446e8877282b3355131400000003000000030b30b003000dd0b677777774fffff9fa9999979
0d75d750000000000000000000331300008818000077770064222a96e8822182b33113310000000400000003003b00030b00000377777776ff4fffff999a9999
07521d70660666066606660660331306608818066605550664424446e8888882b33333310400000003000000030b00000300b00076777777ff9ff9ff99999799
0002100000000000000000000033330000888800000000006422224682222222311111110000400000003000000030000dd030b077776777f9ffff4f979999a9
111c111c7ccc7cc70000000005500550005070500500700000dddd00656565650d0aa000000aa000760000000766660006566650777777500007a90000000070
11c111c177ccc7cc000000000765676005076005000760050dddddd0666666650df99f000df99f0006500000766550000666666576666650000a0000000006d6
1c111c11c77ccc7c00000000076007605076660050766700dddddddd662226650de11e000de11e0700650000664500000659405676565650000aa90000006d60
c111c111cc77ccc7076007600765676050766605007676000555555066666665d55660070d66660200065006650450000009400076666650000a00000006d000
111c111c7cc77ccc07656760076007600766767007667670066666606655566509066602d5d6609200006560650045000009400076565650000a0000076d0000
11c111c1c7cc77cc0760076000000000576676655761166506dd6c6066111665000cc092090cc00200000650600004500009400076565650007aa9007dd6d000
1c111c11cc7cc77c1765676100000000766767667610016606dd6c606611166500c11c0200c11c000000604500000045000940000766650000a00a006d06d000
c111c1117cc7cc771d211d2100000000565655656610016606dd6660cc444ccc044004400440044000060004000000040009400000555000009aa900076d0000
0bb3b3b030bbb0030150051001500510940000499999999994000049000099997667060000065000d777777dd55550000076dc0000999900000000000007d000
bb3b3b350bbb3300157556511575515194544449444444444444444400094444641605000065d650566666657665d650075555d0094444900000000000766d00
b3b33333bb3bbb305757651557576515945555490550055004555550009440006666666065616560566666657661656001c6dc109444444900000000076666d0
b3333335b3b3b33505766650057656509400004904500450045004500944000011111156006176d011111155766176d007cc6d50999aa9990000000000044000
0b4334503bbb3b3505666650056565509400004904500450045004509945400076d176d57661110076d176d57661110007cc6d50955aa5590007d00000094000
0009450033b3b355575665155516551594544449045004500454445094405400656165606161d650656165607661d65007cc6d509544444900766d0000094000
0009450003335550156551511155515194555549444444444455554494000544d650d65064616560d650d6507661656007cc6d5095444449076666d000094000
095454540033350301500510015005109400004999999999940000499400004900000000766176d000000000d55176d00066d500999999990004400000094000
000990000777770000077000007dd500007665000554455000007000067666500007000099999999750705607776777677777776777777767777777677777776
049aa94075666660007667000007500007666650554444550000770000565100007a900090040405565656507665766576666665766666657766665576666665
49a99a940065d56000077000077665507666666545444454000076700067650007aaa90094444445057775007665766576555565766776657676656576666665
9a9aa9a900666660076666707766665576565565455a9554000077770067650007aaa90090004005767766606555655576566765767665657667566576666665
9a9aa9a900655d60765555677666666576666665411a911407007000006765000a99990094444445057665007677767776566765767665657667566576666665
49a99a94006666606500005676666665765565654445544476666667006765007556559095555555565656506576657676577765766556657676656576666665
049aa940006777775650056577666655766666654444444407666670006765000aaaa90000055000750605606576657676666665766666657766665576666665
00499400005555500567765007766550655555555444444500777700067666500000000005064005000000005565556565555555655555556555555565555555
00000000000005d9007a4200000000000000000900009999900a000000000000000000000049400000040000a7a9999900076000000000000001000000000000
0e82e82000555d5507a9942000000000000909aa009999aa09000a900009000009009090049a94000049400004a994400007610000111000001c10000eeeee20
e788888205d6d5550a999940000000000000aaaa09a9aaaa00009000008aa800008aa80049a7a940049a9400097999400007610001ccc10001c7c1007262626c
e88888825d7ddd500a99994000000009090a9a9a099a9909a000000000a77a9009a77a009a777a9449a7a94009a99990707765071c777c1001c7c10015252520
0888882056dddd500a9999400000a09a00a9a9a999a997900090000009a77a0000a77a9049a7a940049a9400099a99407667665601ccc10001c7c10002e50000
0088820055ddd5500ae999400000099a09aa9a7799a970000a000000008aa800008aa800049a940000494000009994007676656500111000001c10005e200000
000820000555550007fe9420000099a70aa9a7779aa090000900000000009000090900900049400000040000000a900007655651000000000001000025200000
0000000000555000007942000009aa779aaa97779aa90000000000000000000000000000000400000000000007a9994000766510000000000000000000000000
000550000005500005677650000550000567765000ddd0000000000000033000060aa05065656565757575751111111111111111111111112888888212888821
00566500005666000567765000566500567777650d666d0003333330033bb33006aa00505dddddd66060606015555555555555555555555188eeee88288ee882
0567765066677760567777650567765067766776d67666d033bbbb3333b77b3306a00a506d5555d5575757571565505050505050505556518ea77ae888eaae88
5677776577777776567777655675576577655677d66666d03b7777b33b7777b30600aa505d5cc6d6060606061555550505050505050555518e7777e88ea77ae8
6777777677777777677557765675576556500565dd666d503b7777b33b7777b3060aa0506d5cc6d5757575751555505050505050505555518e7777e88ea77ae8
77777777666775577777777705677650050000500dddd50033bbbb3333b77b3306aa00505d5666d6606060601555550505050505050555518ea77ae888eaae88
56666665005677505666666500566500000000000055500003333330033bb33006a00a506dddddd55757575715655050505050505055565188eeee88288ee882
05555550000566000555555000055000000000000000000000000000000330000600aa5055555555060606061555555555555555555555512888888212888821
00aaaa000007000000dddd0000dddd000022220050222205bb0bb0bb0b0bb0b00000bbb000000000000990003bb1000000666000000770000076660000766600
0a999940000e00000d7cc7d00d7cc7d0552882550528825003abba30b3abba3b000b1b1ba000bbb000007900b3b3b10006000600007755000702826007282060
a979979400e88000d70cc07dd77cc77d22588522225885220bbbbbb00bbbbbb00a0bbbbbb00b1b1b009a9990bb3bbb1060700060077665500602825006282050
a71991740e111800d77cc77dd70cc07d271881722708807203baab3003baab30b00b3707b00bbbbb0979a99913b3b3b160000060775555550066550000665500
a9999994e8191880dccccccddccccccd2888888228888882b003300b00033000b00bbb00b00b370799a999790bbb3bb160000060775e275507d75d6007d75d60
a992299408111820dcc11ccddcc11ccd28881882288188820b3bb3b00b3bb3b0bb0bbbb0bb0bb3309997aa9901b3b3b106000600775227557d7dd5d67d7dd5d6
b30880d5008882000dccccd00dceecd0028888299288882000bbbb00b0bbbb0b0bb0bbbbbbb0bbbb0999a990001bbb3000666000777776557d7dd5d57d7dd5d5
ff0ee0660008200000dddd0000dddd0099222290092222990bb33bb000b33b0000bbbbb00bbbbbb0009a99000001110b00000000055555500665565006655650
08000080a00700b00056650000077000004aa4000077770000777700000000076776d7765000000000d7cd0009aaaa900000567700a7777d0007700000077000
0000000007a00bba056766500076650044a77a4407666670000666700000007676675665650000000d77ccd09a1aa1a9000567760a6666dd0076670000700700
00880800077bba7b5676666500766500aa7777aa71166117a0776657000007667667566566500000d777cccd9a5aa5a905677775a7777d5d0766667007000070
8008e808b0b7aab067666666007665004aa77aa4712662177a6666660000766676675665666500007777cccc9aaaaaa95677775076666d5d7666666770000007
008ee80000ba7ab0666666660076650004a77a40066116606d666666000766667667566566665000dcccdddd09affa900567777676666d5d0005500000077000
000888000b7b77ab56666665007665004a7aa7a405666650d05661150076666676675665666665000dccddd09a9aa9a95677766576666d5d0006600000700700
000000800ab0b7aa05666650076666504aa44aa4006116000006665007666666766756656666665000dcdd00a900009a6777655076666dd00006600007000070
08008000ab0000a00056650006555550aa4004aa0056650000665000766666666552155666000000000000000000000000000000000000000000000000000000
2002821000028210202000000006822d02822222020220d000000000000000000000000000000000007665000076650005555555555555555555555055677655
0211111122111111022282100026cdcd1111110002200d0000000000000000000000000000000000075006500750065055666666666666666666665556555565
11ddcdcd01ddcdcd001111110216ddddddcdcddd21ddd00002000000000000000000000000000000065006500650000056676767676767676767766556677665
006ddddd106ddddd66ddcdcd0016dddd66666d0081cddd0022ddd000000000000000000000000000766666657666666556777777777777777777776556677665
006d5ddd006d5ddd600ddddd0015ddd066dddd001ddddd008dddd000002282000202820002222200766166657663666556777676767676767676776555677655
0065111d0065111d0005ddd00052111056d111111c66d1111dddd1000221166600211110002282dd766166657663666556766676666666666767766556555565
00520010005200100552211100520010052200000d6661001d66611100666c10011dddd000111110766666657666666556776756666666667577666556677665
0502001005020010500200100502001000502000000552221d666222666dddc066666666666dddd0655555556555555556766665555555555667766556677665
0028210020000000002821002200000002228200005000000000000000000000c0c6cc0000777700056650000000000056677665555575555566765555555555
02111110222821000211111002282100221116660205002002022210202221000cccccc0071111605600650007a00a7056776665565755665555555556677665
d21ddcd60111111021ddcdcd0111111000666c10022560220022822102282210cdd7d7d071111115607006000a9009a056677665565757676565565655555555
d1dd66660ddddcd0666ddddd0dddcdc0066dddcd101d5682011111111111111006ddddd071100115600006000000000056776665575757777576755757777775
00d66d00066dddd06066dd00066dddd05555dd0011ddd62206ddcdcd0ddcdcd00d665ddd71100115560065000000000056677665575756766557675675555557
202211000066dd00001221000066dd00021dd00000dd661260d5dddd6d5dddd000c5ccc071111115056694500a90000056776665565756666565565655677655
02000010002212000110020000221100200100000dd6dc116552ddd16522dd11005c00c0061111500000094507a0000056677665565755665555555556776665
0000000100012000000000200002100000100000d000c1105220011152220001050c00c000555500000000940000000056776665555575555567665556677665
0028226000000000628210000022000022000000222200001112000006822d0026822d0077777777002820000077770056776675555755555677666556776665
002222600028220026111100081d0000820d0000228110001112800026cdcd0016cdcd0000000000028e8200076566d056676756665575656577666556677665
061221600022222006dcdc00621d0000612d000011dcd00011dc600016dddd0006dddd000600600608e7e8007665666d56777667676575657667766555776655
06d11dd0061221160ddddd00611c0200611c0200d66665d5dddd656506dddd0006dddd000000000008eee8007665556d56677777777575757777766575555557
0dd1d1d00dd11ddd05dddd006cdd52016cdd5201dddd0d00ddd6060005ddd00005ddd00000500500028e82007666666d56667676767575756767666557777775
005111000dd1d1dd522dd0d0d66d5211d6665211211100001112000005221110052211100000000000282000076666d056666666666575656666666555555555
0015000000551110220100000d6652100dd6521020001000100020005002000150020001010100100028200000dddd0055666666665575656666665556677665
00105000001051000110000000dd510000dd51002000010010000200500000005000000000000000002820000000000005555555555755555555555055555555
062281100000000000400000202821000028210000282100000000000000000000000000000000007777777711111100566666660015d0005666666500000000
6d6dcdc00000122240900040111111102111111021111110030100000606330000003300000000007555555717777610655115510015d0006666666600000000
506dddd0000dd18090a040900ddbdbd00ddbdbd01ddbdbd003013300663138300031383000077000756556571777610065155551001d50006000000601111110
506dddd0000ddd11a00090a40666dddd1666dddd0666dddd00313830633313300633133000766700755555571776610051155551000d15006000000605555550
5006ddd000ddddd10405a00900d5dd0000d5dd0000d5dd00003313303331301363313013005665007555555717667610655115110001d5006000000605555550
00021111002d6dd00905004a005111000052110000521100033130131110000011100000000550007565565716116761655551510001d0006000000605155150
000200010222166d0a5000900520001005002000052201001110000010000000100000000000000075555557010016716555515100105d006000000605111150
0002000020011006dd1110a05020000050010000500001001000000000000000000000000000000077777777000001105111111500150d000000000005111150
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555775555775775557757755555775555775577557777555555775555557755555577555775557755557755555555555555555555555555555555775
55555555555770555770770577777775557777755770770057777055555770555577005555557755577577005557705555555555555555555555555555557700
55555555555770555500500557707700577770005507700555770775555500555577055555557705777777755777777555555555577777755555555555577005
55555555555500555555555577777775550777755577077557707700555555555577055555557705577077005557700055775555550000005555555555770055
55555555555775555555555557707700577777005770077057707705555555555557755555577005770057755557705555770555555555555577555557700555
55555555555500555555555555005005550770055500550055775775555555555555005555550055500555005555005557700555555555555577055555005555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755555775555777775557777755555777755777777555777755577777755577775555777755555775555557755555557755555555555577555557777755
57700775557770555500077555000775557707705770000057700005550007705770077557700775555770555557705555577005557777555557755555000775
57705770555770555577770055577700577007705777775557777755555577005577770055777770555500555555005555770055555000055555775555577700
57705770555770555770000555550775577777705500077557700775555770055770077555500770555775555557755555577555557777555557700555550005
55777700557777555777777557777700550007705777770055777700555770555577770055777700555770555557705555557755555000055577005555577555
55500005555000055500000055000005555555005500000555500005555500555550000555500005555500555577005555555005555555555550055555550055
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777755577777555577777555777775557777555775577555777755555577755775577557755555575555755775577555777755
57700775577007755770077557700775577007755770000057700000577000055770577055577005555557705770770057705555577557705777577057700775
57707770577777705777770057705500577057705777775557777755577077755777777055577055555557705777700557705555577777705777777057705770
57705000577007705770077557705775577057705770000557700005577057705770077055577055577557705770775557705555577777705770777057705770
55777775577057705777770055777700577777005577777557705555557777005770577055777755557777005770577555777775577007705770577055777700
55500000550055005500000555500005550000055550000055005555555000055500550055500005555000055500550055500000550055005500550055500005
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55777755557777555777775555777775577777755775577557755775577557755775577557755775577777755777775557755555577777555557755555555555
57700775577007755770077557700000555770005770577057705770577777705577770055777700550077005770000555775555550077055577775555555555
57777700577057705777770055777755555770555770577057705770577777705557700555577005555770055770555555577555555577055770077555555555
57700005577077005770077555500775555770555770077055777700577007705577775555577055557700555770555555557755555577055500550055555555
57705555557707755770577057777700555770555577770055577005570055705770077555577055577777755777775555555775577777055555555557777775
55005555555005005500550055000005555500555550000555550055550555505500550055550055550000005500000555555500550000055555555555000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
__gff__
000101010181010001000000000000000000000001010000000000000000020001010101000000000000000000000000000000000000000000000000000000000000000000000c0000040400000000000000000000000000000000000000000000000000000000000c0c00000000000000000001000000000000000001000000
0000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3b3b3b3b3b3b090909093b3b3b3b3b3b00000c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b5a5a5a5a5a5a5a5a5a5a5a5a00000000000c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3bf3e8eff0e6efefe4e9eeeec000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b0102be010102be0101bebe0100000909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b5a5a5a5a5a5a5a5a5a5a5a5a00000909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b01010101e1f2edf2f7e5f0f300000909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09010405010102be010102be0100000909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09140a3b3b000a0a00340a0a340000113737373737373737111414143d3d3d3d1414140a21212121212121210a8f0f8f0fbaba0f8f0f8f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
093b3b3b3b0a10100a0a34340a000037000000000000000037140d14373d3d37140d14210b0b3c25253c0b0b219cba9cbabababa9cba9c0000000022222200090000000000000011000000000f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
093b3b173b000a0a00340a0a3400003700003f7a7a3f00003714140d3d49493d0d1414210b0b245757240b0b219cba9cba5f5fba9cba9c000000230b0b0b23000d0d0900000000000000000f22b2220f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b0a0a0a0a0a0a0a0a0a77790a000011377837bebe3778371114143d3dbebe3d3d141421212124bebe24212121acadacadbebe9dae9dae0000000b0b0b0b0b000d0d0d0d001100120011000fb2bab20f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b0a0a0a0a0a12120a0a3b3b0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000220b0b0b2300090d0900000000a90000000f22b2220f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b0a0a0a0a0a3b3b0a0a3b040a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000023222300090000000000000011000000000f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b0a0a0a0a0a0a0a0a0a13130a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b0a0a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b0a200a0000000000000000008c8d8d8d8d8d8d8d8d8d8d8d8d8d8d8e0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a000000000000000000000000000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000
000a0a0a0000000000000000009c3f3f3f3f3f3f3f3f3f3f3f3f3f3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a007474747474747474747474747474000e0ef9eff5c0e7eff4c0c0f4e8e50e0e010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00c0c0e3e8e1ece9e3e5c0efe6c0c0000ec0c0e3e8e1ece9e3e5c0efe6c0c00e010100000000007576000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a007474c0f4e8e5c0e7efe4f3c07474000e0ec0f4e8e5c0e7efe4f3c0c1c00e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a000000747474747474747474740000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000000000000000000000000000000c0e3efeee7f2e1f4f5ecf4e9efeef3c0010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000000000e0e0e0e0e0e00000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0000000e0e0e0e0e0e0e0e0e0e0000000e0e0e0e0e0e3f3f3f3f0e0e0e0e0e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a000e0e0e0e3f0e0e0e3f0e0e0e0e0e000e0e0e0e0e3f3f495e3f3f0e0e0e0e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a000e0e0e3f3f3f0e0e3f0e3f0e0e0e000e0e0e0e3f3f3f577a3f3f3f0e0e0e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0e0e0e3f3f3f3fbebe3f3f3f3f0e0e0e0e0e0e3f3f3f3fbebe3f3f3f3f0e0e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e4b0e0e0e0e0e0e0e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a000e0e0e0e0e0e180e0e0e0e0e0e0e000e0e0e0e0e0e0e180e0e0e0e0e0e0e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f5b5c5c5c5c5c5c5c5c5c5c5d3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a00000e0e0e0e0e0e0e0e0e0e0e0e00000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010100000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000009c3f3f3f3f3f3f3f3f3f3f3f3f3f3f9c0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0000000e0e0e0e0e0e0e0e0e0e0000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000ac8d8d8d8d8d8d8d8d8d8d8d8d8d8dae0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a000000000000000000000000000000000e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002e1502e1502f1502f1502f150351503715000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200002e5502e5503555035550166003a5503a55037500345003350034500385000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001c620385503455031550305502e5502d5501d6201d6201d6001d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000006500065000650006551305014050140501405014050140501405013050110500e0500b0500905008050070500605005050050500505006050070500105001030010230000000000000000000000000
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002a750267502a7500070032750377003970039700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0004000036630236701f6711c6511b6511b6511a6511a6511a630176310e631066310463102631016310063100631006110061100611006110061100611006110061101600006000060000300003000030000300
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000700180062307623000000762300623000000000000623076230000007623006230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000307342b751237511d75117751127510d75108751037310271501713007050c7000a700077000670004700027000170000700007000070000700007000070000700017000070000700007000070000700
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000312502b250252502025019250122500e2500e6300e6300e6351520010200072000420000200002000d20009200082000820000200002000120026100121001e100061000d10019100251000c10024100
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
000900000b6500b6500b6531c6001c6501c650156300e630096300763005610036100161001615000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001c6301c630232541c35120353173501b3501935422230246002460025600266002660027600156000f6000b6000760006600056000460004600046000020000200002000020000200002000020000200
0003000028630286301e6501a650186501664014640106400f6400c630096300663005630026100161001610016102750020500235002c5002e50022500295002e500325001f5002a5002d500265002a5001c500
000300000863111631206003365032651306512a651226511a651136410d641086410463101631006110061500000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000017630106300e6500e6301063213652186521e6522a6523663236632306323062221622126220661200612006120161200612006150060000600006000060000600006000060000600006000060000600
010c00201125411255052550000000000112541125505255000000000011254112550525500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100000705005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000205004050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000005002050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f000005135051050c00005135091351c0150c1351d0150a1351501516015021350713500000051350000003135031350013500000021351b015031351a0150513504135000000713505135037153c7001b725
010f00000c03300000300152401524615200150c013210150c003190151a01500000246153c70029515295150c0332e5052e5150c60524615225150000022515297172b71529014297152461535015295151d015
010f000007135061350000009135071351f711000000510505135041350000007135051351c0151d0150313503135021350000005135031350a1050a135000000113502135031350413505135000000a13500000
010f00000c033225152e5153a515246152b7070a145350150c003290153200529005246152501526015220150c0331e0251f0252700524615225051a0152250522015225152201522515246150a7110a0001d005
011400000c0330253502525020450e6150252502045025250c0330253502525020450e6150252502045025250c0330252502045025350e6150204502535025250c0330253502525020450e615025250204502525
011400001051512515150151a5151051512515150151a5151051512515150151a5151051512515150151a5151051512515170151c5151051512515170151c5151051512515160151c5151051512515160151c515
011400001c5151e5151a515150151c5151e5151a015155151c5151e5151a515150151c5151e5151a015155151c5151e51517015230151c5151e51517015230151c5151e515165151c0151c5151e515160151c515
011400000c0330653506525060450e6150652506045065250c0330653506525060450e6150652506045065250c0330952509045095350e6150904509535095250c0330953509525090450e615095250904509525
0114000020515215151c5151901520515215151c0151951520515215151c5151901520515215151c0151951520515215151c0151901520515215151c01525515285152651525515210151c5151a5151901515515
01180000021100211002110021120e1140e1100e1100e1120d1140d1100d1100d1120d1120940509110091120c1100c1100c1100c1120b1110b1100b1100b1120a1100a1100a1100a11209111091100911009112
01180000117201172011722117221d7201d7201d7221d7221c7211c7201c7201c7201c7221c72218720187221b7211b7201b7201b7201b7221b7221d7221d7221a7201a7201a7201a7201a7221a7221672016722
011800001972019720197221972218720187201872018720147201472015720157201f7211f7201d7201d7201c7201c7201c7221c7221a7201a7201a7221a7251a7201a7201a7221a72219721197201972219722
011800001a7201a7201a7221a7221c7201c7201c7221c7221e7201e7202172021720247212472023720237202272022720227202272022722227221f7201f7202272122720227202272221721217202172221722
0118000002114021100211002112091140911009110091120e1140e1100c1100c1120911209110081100811207110071100711007112061110611006110061120111101110011100111202111021100211002112
0118000020720207202072220722217202172021722217222b7212b72029720297202872128720267202672526720267202672026720267222672228721287202672026720267202672225721257202572225722
010e00000c0231951517516195150c0231751519516175150c0231951517516195150c0231751519516175150c023135151f0111f5110c0231751519516175150c0231e7111e7102a7100c023175151951617515
010e000000130070200c51000130070200a51000130070200c51000130070200a5200a5200a5120a5120a51200130070200c51000130070200a51000130070200c510001300b5200a5200a5200a5120a5120a512
010e00000c0231e5151c5161e5150c0231c5151e5161c5150c0231e5151c5161e5150c0231c5151e5161c5150c0230c51518011185110c0231c5151e5161c5150c0231e7111e7102a7100c023175151951617515
010e0000051300c02011010051300c0200f010051300c02011010051300c0200f0200f0200f0120f0120f012061300d02012010071300e02013010081300f0201503012020140101201015030120201401012010
018800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
01640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
018800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0164002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
010a000024045270352d02523045260352c02522045250352b02522035250352b02522035250252b01522725257252b71522715257152b71522715257152b7151700017000170001700017000130000c00000000
010a000021705247052a7052072523715297151f72522715287151f71522715287151f71522715287151f71522715287151f71522715287151f70522705287051770017700177001770017700137000c70000700
010c00000f51014510185101b510205102451011510165101a5101d510225102651013510185101c5101f5102451028510285102851028510285102851028515240042450225504255052650426502265050e500
010c000014730187301b730207302473027730167301a7301d730227302673029730187301c7301f73024730287302b730307403073030730307303072030715247042470225704257052670426702267050e700
011200000843508435122150043530615014351221502435034351221508435084353061512215054250341508435084350043501435306150243512215034351221512215084350843530615122151221524615
011200000c033242352323524235202351d2352a5111b1350c0331b1351d1351b135201351d135171350c0330c0332423523235202351d2351b235202352a5110c03326125271162c11523135201351d13512215
0112000001435014352a5110543530615064352a5110743508435115152a5110d43530615014352a511084150d4350d4352a5110543530615064352a5110743508435014352a5110143530615115152a52124615
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033115151c1351d1351c1351d135115151d1350c03323135115152213523116221352013522135
0112000001435014352a5110543530615064352a5110743508435115152a5110d435306150143502435034350443513135141350743516135171350a435191351a1350d4351c1351d1351c1351d1352a5011e131
011200000c033115152823529235282352923511515292350c0332823529216282252923511515115150c0330c033192351a235246151c2351d2350c0331f235202350c033222352323522235232352a50130011
011600000042500415094250a4250042500415094250a42500425094253f2050a42508425094250a425074250c4250a42503425004150c4250a42503425004150c42500415186150042502425024250342504425
011600000c0330c4130f54510545186150c0330f545105450c0330f5450c41310545115450f545105450c0230c0330c4131554516545186150c03315545165450c0330c5450f4130f4130e5450e5450f54510545
0116000005425054150e4250f42505425054150e4250f425054250e4253f2050f4250d4250e4250f4250c4250a4250a42513425144150a4250a42513425144150a42509415086150741007410074120441101411
011600000c0330c4131454515545186150c03314545155450c033145450c413155451654514545155450c0230c0330c413195451a545186150c033195451a5451a520195201852017522175220c033186150c033
010b00200c03324510245102451024512245122751127510186151841516215184150c0031841516215134150c033114151321516415182151b4151d215224151861524415222151e4151d2151c4151b21518415
010200002067021670316602f65031650336503365033650386503f6503f650326502f6502f650006002f6502e6502d650006002b650296502760024650216001e65019600116500a60000630066000161000010
010200000e6510c6530a6520b653056530000000000000000e6510c6530a652000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000013535000002b5070000037535000001f507000002b5350000000000000001f53500000000000000013505000002b5070000037535000001f507000002b5350000000000000001f535000000000000000
011000000062200622006220062202622026220262202622006220062200622006220262202622026220262200622006220062200622026220262202622026220062200622006220062202622026220262202622
__music__
00 16 17 43 44
00 16 17 43 44
01 16 17 43 44
00 16 17 43 44
00 18 19 43 44
02 18 19 43 44
00 1a 42 43 44
01 1a 1b 43 44
00 1a 1b 43 44
00 1a 1c 43 44
00 1a 1c 43 44
02 1d 1e 43 44
01 1f 20 43 44
00 1f 21 43 44
00 1f 20 43 44
00 1f 21 43 44
00 22 23 43 44
02 1f 24 43 44
01 25 26 43 44
00 25 26 43 44
02 27 28 43 44
00 29 2a 43 44
03 2b 2c 43 44
04 2d 2e 43 44
04 2f 30 43 44
01 31 32 43 44
00 31 32 43 44
00 33 34 43 44
02 35 36 43 44
01 37 38 43 44
00 39 3a 43 44
00 37 3b 43 44
02 39 3b 43 44
03 3e 42 43 44
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
