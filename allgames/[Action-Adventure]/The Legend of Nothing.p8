pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


function p8u(s,y,x)local w=0local u=0local v=0local z=0local function f(i)u-=i w=lshr(w,i)end local t={9,579}for i=1,58 do t[sub(",i])v+=e%1*c579}f#k<lmax>0q/42368ghjnprwyz!{:;.~_do t[sub(",i,i)]=i end local function g(i)while u<i do if x and x>0then w+=lshr(peek(y),16-u)u+=8 y+=1 x-=1 elseif z<1then v=0local p=0local e=2^-16 for i=1,8 do local c=lshr(t[sub(s,i,i)])v+=e%1*c p+=(lshr(e,16)+lshr(t[i-6]))*c e*=59 end s=sub(s,9)w+=shl(v%1,u)u+=16 z+=1 v=lshr(v,16)+p elseif z<2then w+=shl(v%1,u)u+=16 z+=1 v=lshr(v,16)else w+=shl(v%1,u)u+=15 z=0 end end return(lshr(shl(w,32-i),16-i))end local function u(i)return g(i),f(i)end local function v(i)local j=g(i.j)f(i[j]%1*16)return(flr(i[j]))end local function g(i)local t={j=1}for j=1,288 do t.j=max(t.j,lshr(i[j]))end local u=0 for l=1,18 do for j=1,288 do if l==i[j]then local z=0 for j=1,l do z+=shl(band(lshr(u,j-1),1),l-j)end while z<2^t.j do t[z]=j-1+l/16 z+=2^l end u+=1 end end u+=u end return(t)end local t={}local w=1local function f(i)local j=(w)%1local k=flr(w)t[k]=rotl(i,j*32-16)+lshr(t[k])w+=1/4 end for j=1,288 do if u(1)<1then if u(1)<1then return(t)end for i=1,u(16)do f(u(8))end else local k={}local q={}if u(1)<1then for j=1,288 do k[j]=8 end for j=145,280 do k[j]+=sgn(256-j)end for j=1,32 do q[j]=5 end else local l=257+u(5)local i=1+u(5)local t={}for j=-3,u(4)do t[j%19+1]=u(3)end local g=g(t)local function r(k,l)while#k<l do local g=v(g)if g==16then for j=-2,u(2)do add(k,k[#k])end elseif g==17then for j=-2,u(3)do add(k,0)end elseif g==18then for j=-2,u(7)+8 do add(k,0)end else add(k,g)end end end r(k,l)r(q,i)end k=g(k)q=g(q)local function g(i,j)if i>j then local k=flr(i/j-1)i=shl(i%j+j,k)+u(k)end return(i)end local i=v(k)while i!=256 do if i<256then f(i)else local l=i<285 and g(i-257,4)or 255local q=1+g(v(q),2)for j=-2,l do local j=(w-q/4)%1local k=flr(w-q/4)f(band(rotr(t[k],j*32-16),255))end end i=v(k)end end end end


do
local ub = _update_buttons
local oldstate, state = 0, btn()
function _update_buttons(n)
ub(n)
oldstate, state = state, btn()
end
function cbtnp(i)
local bitfield = band(btnp(), bnot(oldstate))
return not i and bitfield or band(bitfield, 2^i) != 0
end
end

function smoothrect(x0, y0, x1, y1, r, col)
r=min(r,min(x1-x0,y1-y0)/2)
line(x0, y0 + r, x0, y1 - r, col)
line(x1, y0 + r, x1, y1 - r, col)
line(x0 + r, y0, x1 - r, y0, col)
line(x0 + r, y1, x1 - r, y1, col)
clip(x0, y0, r, r)
circ(x0 + r, y0 + r, r, col)
clip(x0, y1 - r, r, r + 1)
circ(x0 + r, y1 - r, r, col)
clip(x1 - r, y0, r + 1, r)
circ(x1 - r, y0 + r, r, col)
clip(x1 - r, y1 - r, r + 1, r + 1)
circ(x1 - r, y1 - r, r, col)
clip()
end

function smoothrectfill(x0, y0, x1, y1, r, col1, col2)
r=min(r,min(x1-x0,y1-y0)/2)
circfill(x0 + r, y0 + r, r, col1)
circfill(x0 + r, y1 - r, r, col1)
circfill(x1 - r, y0 + r, r, col1)
circfill(x1 - r, y1 - r, r, col1)
rectfill(x0 + r, y0, x1 - r, y1, col1)
rectfill(x0, y0 + r, x1, y1 -r, col1)
smoothrect(x0, y0, x1, y1, r, col2)
end


function crnd(a, b)
return min(a, b) + rnd(abs(b - a))
end

function ccrnd(tab)
n = flr(crnd(1, #tab+1))
return tab[n]
end




g_btn_confirm = 4
g_btn_back = 5
g_btn_jump = 4
g_btn_call = 5
g_sfx_menu_move = 0
g_sfx_menu_select = 1
g_sfx_shoot = 3
g_sfx_walk = 29
g_sfx_type = 30
g_sfx_drown = 28
g_sfx_select = 34
g_sfx_key = 36
g_sfx_crumble = 31
g_sfx_burn = 37
g_sfx_pet = 35
g_sfx_jump = 33
g_sfx_push = 32
g_sfx_loot1 = 26
g_sfx_loot2 = 27
g_sfx_plant = 3
g_style_center = 1
g_style_bottom = 2
g_style_question = 3
g_spr_ball = 64
g_spr_boots = 6
g_spr_gloves = 7
g_spr_can = 8
g_spr_suit = 9
g_spr_sign = 16
g_spr_chest = 32
g_spr_chest_open = 48
g_spr_key = 40
g_spr_collapse = 52
g_spr_boulder = 56
g_spr_fire = 24
g_spr_plant = 37
g_id_person = -1
g_id_cat = -2
g_id_raccoon = -3
g_id_trigger = -4
g_spr_ground = 34
g_spr_water = 39
g_spr_waterfall = 55
msg_queue = {}

function open_message(text,style,header,fn)
local m = { text=text, header=header, style=style, fn=fn, h=0, cursor="", opening=true }
m.wanted_h = 6 + 8
for i=1,#text do if sub(text,i,i)=="\n" then m.wanted_h += 8 end end
if style==g_style_question then m.wanted_h += 8 end
m.text_width = font_width(text)
add(msg_queue, m)
end
function has_message()
return #msg_queue > 0
end
function message_cam_y()
local m = msg_queue[1]

return 0
end
function update_message()
local m = msg_queue[1]
if not m then return end
if m.close then
m.close += 1/20
if m.close > 1 then
del(msg_queue, m)
if m.fn then m.fn(m.answer) end
return
end
m.h = m.wanted_h * max(0, 1 - m.close)
elseif m.wait then
if cbtnp(0) then m.answer = (m.answer + 1) % 3 + 1 end
if cbtnp(1) then m.answer = m.answer % 3 + 1 end
m.wait += 1/30
m.cursor = m.style == g_style_bottom and m.wait % 1 > .4 and "ƒ" or ""
if cbtnp(4) then
sfx(g_sfx_select)
m.close = 0
end
elseif m.display then
local tmp = m.display
m.display += (btn(4) and 1.5 or .3)
if flr(tmp)!=flr(m.display) then sfx(g_sfx_type) end
if m.display >= #m.text then m.wait = 0 m.answer = 1 end
m.cursor = m.display % 6 < 4 and "€" or ""
m.h = m.wanted_h
elseif m.opening then
m.h += 1
if m.h >= m.wanted_h then m.display = 0 end
end
end
function draw_message()
local m = msg_queue[1]
if not m then return end
local c1 = { 0xbf, 0xba, 0xba }
local c2 = { 14, 8, 8 }
local w,h = ({m.text_width+8, 128 - 4, 128 - 4})[m.style], m.h
local x,y = ({60-m.text_width/2, 2, 2})[m.style], ({80 - h / 2, 127 - h - 2, 127 - h - 2})[m.style]
if h then
fillp(0x6699)
smoothrectfill(x, y, x + w - 1, y + h, 5, c1[m.style])
fillp()
smoothrect(x, y, x + w - 1, y + h, 5, 1)
if h >= 4 then
smoothrect(x + 1, y + 1, x + w - 2, y + h - 1, 3, c2[m.style])
end
end
clip(x + 4, y + 4, w - 6, h - 6)
if m.display then
local i = m.display
print(sub(m.text,1,i)..m.cursor, x + 4, y + 4)
end
if m.style==g_style_question and m.answer then
local ch={"‡", "@", "|"}
for i=1,3 do
local dot=i==m.answer and "‘" or ""
print(dot, x + 24 + i * 20, y + h - 10)
print(ch[i], x + 30 + i * 20, y + h - 10)
end
end
clip()
end
function new_quest()
return {
start = { x=5, y=28 },


chests = {
{ x=52, y=10, item="ball",
text="You found a ball\n for the cats" },
{ x=18, y=09, item="boots",
text="You found a pair of boots!\nYou can now jump with —." },
{ x=9, y=34, item="suit",
text="You found a bathing suit!\nYou can now swim." },
{ x=66.5, y=8, item="gloves",
text="You found a pair of\ngloves! You can now\npush boulders with Ž." },
},
boulders = {
10,13,  11,13,  12,15,  13,13,  11,31,  14,30,  12,32,  13,30,  12,30,  11,33,  13,33,  15,32,  15,33,
12,34,  14,31,  6,32,  14,32,  1,37,
0,38,  2,38,  6,44,  7,43,
23,38,  23,37,  24,37,  20,40,  21,40,  22,40,  23,40,  24,40,  21,41,  23,41,  20,42,  23,42,  24,42,  23,43,  22,44,
13,39,  14,39,  15,39,  12,41,  14,40,  15,40,  17,40,  11,42,  12,43,
23,7,
57,23,
30,29,
48,25,
},
keys = {
{ x=18, y=21 },
{ x=22, y=38 },
{ x=40, y=16 },
{ x=78, y=26 }, 
},
triggers = {
{ x=2, y=28, f=function()
open_message("Wow.\nWhy am I waking up here?",g_style_center)
end },
{ x=1, y=22, f=function()
open_message("There must have been one\nof those storms again.",g_style_center)
end },
{ x=2, y=15, f=function()
open_message("I hope nobody's\nhurt. Better check\nif everyone's ok.",g_style_center)
end },
{ x=10, y=8, f=function()
open_message("Storms have destroyed\nthe landscape.\nEverything is fragile now.",g_style_center)
end },
{ x=113, y=40, f=function()
open_message("Finally home\non my island!",g_style_center)
open_message("While I was busy\ncatching up with\neveryone,",g_style_center)
open_message("All my friends\nwere reconstructing\nmy house!",g_style_center)
open_message("What a kind\nthing to do!",g_style_center)
end },
},
signs = {
{ x=2,  y=18, text={"Did you know that signs\nsaved your progress? ‡\nNow you do!"} },
{ x=13, y=6, text={"Today I made my fisrt sign!\nHope someone will read it.\nI am so exited!"} },
{ x=17, y=3, text={"Oh no, there's a spelling\nmistake in my first sign..."} },
{ x=59, y=17, text={"What kind of shorts do\nclouds wear?","...","Thunderwear."} },
{ x=59, y=27, text={"If you like my funny puns,\ndon't forget to engrave a\nthumb up."} },
{ x=27, y=31, text={"Would you like to hear\na construction joke?","...","Still working on it."} },
{ x=8, y=36, text={"To support my work,\nyou can also tip me."} },
{ x=48, y=41, text={"Can a kangaroo jump higher\nthan a cliff?","...","Of course, cliffs can't jump!"} },
{ x=116, y=35, text={"To the person who invented\nzero: thanks for nothing."} },
{ x=21, y=15, text={"I find potatoes jokes\nvery...","appeeling."} },
{ x=19, y=7, text={"The ravine of the death.\nReserved to people who\ncan jump."} },
{ x=33, y=1, text={"Be careful on your way to\nthe other side of the lake!"} },
{ x=19, y=20, text={"You should know that\neverytime you read a sign\nyour progress is saved."} },
{ x=9, y=41, text={"What do you call a man with\na rubber toe?","...","Roberto."} },
},
living = {
{ x=1, y=2, id=g_id_cat, dir=1, name="Botox" },
{ x=91, y=2, id=g_id_cat, dir=1, name="Juno" },
{ x=24, y=35, id=g_id_cat, dir=0, name="Grocha" },
{ x=116, y=41, id=g_id_cat, dir=0, name="Yoyo" },
{ x=52, y=23,  id=g_id_raccoon, dir=0, name="Lulu" },
{ x=67, y=5,  id=g_id_raccoon, dir=0, name="Damdam" },
{ x=84, y=38,  id=g_id_raccoon, dir=0, name="Sammy" },
{ x=15, y=25,  id=g_id_person, name="Frdy",
text = { "Good morning!",
"Did the storm do any damage\nto your lovely home?",
"I just can't believe my\nbeloved plants are still\nintact!",
"I heard the storm destroyed\na house by the lake.","I am going there to help\nrebuilding it!",
"Can you water my plants\nwhile I am gone?", 
{ "Thank you my dear friend!\nMy plants mean so much\nto me.","Taking care of them\nand watching them grow is\nmy biggest joy in the world." }, 
{ "Don't worry,\nI am sure you will find it\nvery easy and relaxing!\nYou will do great." },              
{ "Aww, I didn't know you\nloved gardening too!","We should get together\nsometimes when I come back,\nI would love to hear about\nyour plants." },     
function()
sfx(g_sfx_loot1)
sfx(g_sfx_loot2)
open_message("You received a\nwatering can!",g_style_center)
game.inventory.can = true
end,
},
text2 = { "My plants are so beautiful\nbecause of you!\nI hope you enjoyed\ntaking care of them."},
},
{ x=25, y=22,  id=g_id_person, name="Clemon",
text = { "Well be with you, gentleman!",
"Let me narrate a riddle\nfor thee:",
"Is this a raccoon\nthat I see before me,\nthe muzzle toward\nmy hand?","Come, let me clutch thee.",
"I have thee not,\nand yet I see thee thrice.",
},
text2 = { "O, brave!","Intelligent party\nto the advantages\nof the very all of all.\nThis told, I joy."}
},
{ x=26, y=4,  id=g_id_person, name="Marjolaine",
text = { "Hey there!","What a storm huh?",
"My two grand-daughters\nare so light and tiny\nthey were lifted\nby the wind!",
"If by any chance you find\nthem on your way,\nwould you be kind enough\nto send them back to me?","I have been worrying\nlike hell.",  
{ "You are right, I should\ntake care of myself and\ntry not to worry too much.","Thank you,\nit helps to know\nthat I am not alone." }, 
{ "Yes it was a\nvery strong wind!\nThey love storms so much,\nthey couldn't resist\ngoing out." },              
{ "They are ressourceful\nlittle girls!","I would not be surprised\nif they found their\nway home by themselves!" },     
},
text2 = { "Thank you for sending\nback my girls."}
},
{ x=90, y=26,  id=g_id_person, name="Charlene",
text = { "Well,\nthat was a fun adventure!\nFor a minute,\nI was a bird!",
"My grandma says storms\nare a lot more common now\nthan in the past.",
"...",
"Sometimes it makes me\nso sad and scared\nto see the world\nfalling appart.",  
{ "You are so sweet.\nI could really use\nsomeone to talk to,\nthank you so much.","I promise I will not stay alone\nand come to you whenever I feel anxious." }, 
{ "My friends and I\nhave so much ideas\non how to improve things!",
"We are already taking part\nin some peaceful actions\nto change things,\nyou should come by sometimes." },              
{ "That's inspiring!\nI agree, collective action\ncan feel very empowering." },     
}
},
{ x=54, y=39,  id=g_id_person, name="Alix",
text = { "You, here?\nWhat a nice surprise!\nCome sit next to me.","I promise not to bore you\nwith science facts.",
"...",
"...",
"So, I have been reading.","Did you know that\nthe temperature of\nlightning is around\n20000Â°C?",  
{ "No, you are amazing!","After all,\nit is you who gave me\nmy very first science book\na while ago." }, 
{ "I learned it in\na book my grandma found.\nOh! That's the one!\nWhere did you find it?" },              
{ "Amazing, right?\nScience facts are\nso fascinating.","Did you know that\none day on Venus\nis longer than a year\non Earth?" },     
}
},
{ x=112, y=33, id=g_id_person, name="Claire",
text = { "Hi, I'm Claire. I made this\ngame with Sam here.\nThanks for trying our game,\nwe love you!"
},
},
{ x=113, y=33, id=g_id_person, name="Sam",
text = { "Hi, I'm Sam. I made this game\nwith Claire here.\nCongratulations on reaching\nthe final island!"
},
},

{ x=6,  y=36, id=g_spr_fire, dir=3, },
{ x=20, y=39, id=g_spr_fire, dir=1, },
{ x=15, y=43, id=g_spr_fire, dir=1, },
{ x=15, y=42, id=g_spr_fire, dir=1, },
{ x=15, y=41, id=g_spr_fire, dir=1, },
{ x=11, y=38, id=g_spr_fire, dir=3, },
{ x=12, y=38, id=g_spr_fire, dir=3, },
{ x=0,  y=41, id=g_spr_fire, dir=1, },

{ x=5,  y=43, id=g_spr_fire, dir=1, },
{ x=8,  y=38, id=g_spr_fire, dir=3, },
{ x=19, y=34, id=g_spr_fire, dir=1, },
},
}
end
function init_quest(q)
game.inventory = {
nkeys = 0
}
foreach(q.chests, function(o)
add(game.specials, { x=o.x+.5, y=o.y+.5, r=.5, id=g_spr_chest, data=o, xoff=-4, yoff=-4 })
end)
foreach(q.keys, function(o)
add(game.specials, { x=o.x+.5, y=o.y+.5, r=.5, id=g_spr_key, data=o, xoff=-4, yoff=-4, noblock=true })
end)
foreach(q.triggers, function(o)
add(game.specials, { x=o.x+.5, y=o.y+.5, r=1, id=g_id_trigger, data=o, noblock=true })
end)
for i=1,#q.boulders,2 do
local o = {x=q.boulders[i], y=q.boulders[i+1]}
add(game.specials, { x=o.x+.5, y=o.y+.5, r=1, id=g_spr_boulder, data=o, xoff=-4, yoff=-6 })
end
foreach(q.signs, function(o)
add(game.specials, { x=o.x+.5, y=o.y+.5, r=.5, id=g_spr_sign, data=o, xoff=-4, yoff=-6 })
end)
foreach(q.living, function(o)
add(game.specials, new_living(o.x+.5, o.y+.5, o.dir or 3, o.id, o))
end)
end
function update_quest(q)
end
function quest_touch(q,o)
if o.id==g_spr_key then
sfx(g_sfx_key)
game.inventory.nkeys += 1
del(game.specials,o)
elseif o.id==g_id_trigger then
o.data.f()
del(game.specials,o)
elseif o.id==g_spr_fire then
sfx(g_sfx_drown)
game.player.dead = 0
end
end

function quest_activate(q,o)
if o.id==g_spr_sign then
sfx(g_sfx_select)
if game.player.dir==3 then
open_message("The text is on the other\nside of the sign!",g_style_center)
else
foreach(o.data.text, function(t) open_message(t,g_style_bottom) end)
q.save = { x=game.player.x, y=game.player.y }
end
elseif o.id==g_spr_chest then
if game.inventory.nkeys>0 then
sfx(g_sfx_loot1)
sfx(g_sfx_loot2)
open_message(o.data.text,g_style_center)
game.inventory.nkeys -= 1
game.inventory[o.data.item] = true
o.id=g_spr_chest_open
else
open_message("The chest is locked.",g_style_center)
end
elseif o.id==g_spr_plant and not o.grown and game.inventory.can then
sfx(g_sfx_plant)
o.grown=flr(rnd(2))
elseif o.id==g_id_person then
q.current=0
local function next_msg()
q.current += 1
local i=q.current
if i<=#o.data.text then
if type(o.data.text[i+1])==type({}) then
open_message(o.data.text[i], g_style_question, o.data.name,
function(answer)
foreach(o.data.text[i+answer], function(t) open_message(t,g_style_bottom,o.data.name) end)
q.current += 3 
next_msg()
end)
elseif type(o.data.text[i])==type(function()end) then
o.data.text[i](next_msg)
else
open_message(o.data.text[i],g_style_bottom,o.data.name,next_msg)
end
end
end
next_msg()
elseif o.id==g_id_cat then
sfx(g_sfx_pet)
open_message("You pet "..o.data.name.." the\ncat. How adorable! ‡",g_style_center)
elseif o.id==g_id_raccoon then
sfx(g_sfx_pet)
open_message("You pet "..o.data.name.." the\nraccoon. How cute! ‡",g_style_center)
end
end

g_map = {}
for i=0,0x400 do g_map[i+1] = peek4(0x2000+i*4) end
function load_map()

for i=0,0x400 do poke4(0x2000+i*4,g_map[i+1]) end
local map = {
collapses={},
plants={},
junk={},
}

for ty = 0,63 do for tx = 0,127 do
local id = mget(tx,ty)
local function special(list, src, dst)
if id == src then
add(list, {x=tx+.5,y=ty+.5})
mset(tx,ty,dst)
end
end
special(map.collapses, g_spr_collapse, g_spr_water)
special(map.plants, g_spr_plant, g_spr_ground)
end end
return map
end
function reset_map(m)
foreach(m.junk, function(o)
add(m.collapses, {x=o.x, y=o.y})
end)
m.junk={}
end
function create_maze(x,y,w,h)

local p=0x2000+128*y+x
for j=0,h-1 do
memset(p+128*j,0,w)
end

local c={x=band(rnd(w),254)+1,y=band(rnd(h),254)+1}
local s={}
local n
local function test(x2,y2)
if x2>0 and y2>0 and x2<w-1 and y2<h-1 and mget(x+x2,y+y2)==0 then
add(n,{x=x2,y=y2})
end
end
repeat
mset(x+c.x,y+c.y,1)
n={}
test(c.x+2,c.y) test(c.x-2,c.y)
test(c.x,c.y+2) test(c.x,c.y-2)
if #n>0 then
add(s,c)
local p=n[1+flr(rnd(#n))]
mset(x+c.x/2+p.x/2, y+c.y/2+p.y/2, 1)
c=p
else
c=s[#s]
s[#s]=nil
end
until #s==0

mset(x+1,y+h-1,1)

local function doeach(f) for j=y,y+h-1 do for i=x,x+w-1 do f(i,j) end end end

doeach(function(i,j) if mget(i,j)==1 and mget(i,j+1)==0 then mset(i,j+1,62) end end)

doeach(function(i,j) if mget(i,j)==0 then mset(i,j,39) end end)

local bad = {[62]=true, [39]=true}
local lut = {3,1,2,36,51,49,50,4,19,17,18,20,35,33,34}
doeach(function(i,j) if mget(i,j)==1 then
local m=0
if not bad[mget(i-1,j)] then m+=1 end
if not bad[mget(i+1,j)] then m+=2 end
if not bad[mget(i,j-1)] then m+=4 end
if not bad[mget(i,j+1)] then m+=8 end
mset(i,j,lut[m])
end end)
end
function has_flag(x,y,flag)
local bg = mget(x, y)
return fget(bg, flag)
end
function block_object(list,x,y)



for i=1,#list do
local o = list[i]
local d
if o.noblock then 
elseif o.id<0 or fget(o.id,7) then d=.5
elseif fget(o.id,0) then d=0.8 end
if d and max(abs(x-o.x),abs(y-o.y)) <= d then return true end
end
return false
end
function on_object(list,x,y)
for i=1,#list do
local o = list[i]
if max(abs(x-o.x),abs(y-o.y)) <= 0.5 then return true end
end
return false
end
function block_walk(x,y,w,h)
if x<0 or y<0 or x>=128 or y>=64 then return true end
local x1,x2,y1,y2 = flr(x-w/2),flr(x+w/2),flr(y-h/2),flr(y+h/2)
if x1!=x2 then
if has_flag(x1,y1,1) or has_flag(x2,y1,0) or
has_flag(x1,y2,1) or has_flag(x2,y2,0) then
return true
end
end
if y1!=y2 then
if has_flag(x1,y1,3) or has_flag(x1,y2,2) or
has_flag(x2,y1,3) or has_flag(x2,y2,2) then
return true
end
end
if block_object(game.specials,x,y) then return true end



return false
end
function block_fly(x,y,w,h)
if w or h then
return block_fly(x-w/2,y-h/2) or block_fly(x+w/2,y-h/2)
or block_fly(x-w/2,y+h/2) or block_fly(x+w/2,y+h/2)
end
return false
end
function in_water(x,y,w,h)
if on_object(game.world.map.collapses,x,y) then return false end
if has_flag(x,y,4) then return true end
return false
end
function palette(n)
local p = {
{ 7,7,7,7,7,15,15,15,15,15,134,134,134,5,5,128,0 }, 
{ 7,6,6,134,5,5,133,128,0,0,0,0,0,0,0,0,0 }, 
{ 7,6,6,6,134,5,5,133,128,128,128,0,0,0,0,0,0 }, 
{ 7,7,6,6,134,134,5,133,133,133,133,128,128,0,0,0,0 }, 
{ 7,7,6,6,6,134,134,5,5,5,5,133,128,128,0,0,0 }, 
{ 7,7,7,6,6,6,134,134,134,134,5,5,5,133,128,128,0 }, 
{ 7,7,7,7,6,6,6,6,6,6,134,5,5,5,133,128,0 }, 
{ 7,7,7,7,7,7,7,7,7,7,6,134,134,5,5,128,0 }, 
{ 7,7,15,14,14,14,8,8,8,8,136,136,132,132,132,128,0 }, 
{ 7,7,15,15,143,143,143,137,137,137,4,4,4,132,132,128,0 }, 
{ 7,7,15,15,15,9,9,9,9,9,9,4,4,4,132,128,0 }, 
{ 7,7,7,135,135,135,10,10,10,10,10,10,134,134,5,128,0 }, 
{ 7,6,6,6,12,12,12,140,140,140,140,1,1,1,129,129,0 }, 
{ 7,6,6,6,12,12,12,12,12,12,12,140,1,1,129,129,0 }, 
{ 7,7,7,6,6,139,139,139,139,139,3,3,3,3,131,0,0 }, 
{ 7,7,7,135,135,135,138,138,138,138,138,139,3,3,5,128,0 }, 
}

for i=1,#p do pal(i-1,p[i][n+9],1) end
end
function msave(p,n)
local m={}
for i=1,n/4 do m[i]=peek4(p+(i-1)*4) end
m.restore = function(p2)
p2 = p2 or p
for i=1,#m do poke4(p+(i-1)*4,m[i]) end
end
return m
end
do
local data =
" † @‡ Ž—‘ ƒ | "..
"ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
"abcdefghijklmnopqrstuvwxyz"..
"0123456789.,:;?!\"-'()=€"
local widths = {
2,4,2,8,7,73,9,9,6,8,8,2,4,34,
4,4,4,4,4,4,4,4,1,3,4,4,5,5,5,4,5,4,4,5,4,5,7,5,5,4,
4,4,3,4,4,2,4,4,1,2,4,1,5,4,4,4,4,3,3,2,4,5,5,4,4,4,
4,2,4,4,4,4,4,4,4,4,1,2,1,2,4,1,3,4,1,2,2,3,4,
}
local x0,y0 = 0,32
local params = {}
local outline = nil
for i=1,#data do
local w = widths[i]
if x0 + w > 128 then
y0 += 8
x0 = 0
end
params[sub(data,i,i)] = { x=x0, y=y0, w=w }
x0 += w
end
pico8_print = print
function print(str, x0, y, c, scx, scy)
scx = scx or 1
scy = scy or scx
local function do_work(x0, y, blit)
local x = x0
for i=1,#str do
local ch = sub(str,i,i)
local param = params[ch]
if ch==" " then
x += 3 * scx
elseif ch=="\n" then
x = x0
y += 8 * scx
elseif param then
blit(param.x, param.y, param.w, 8, x, y, param.w * scx, 8 * scy)
x += (param.w + 1) * scx
end
end
end
local old = msave(0x5f00,0x20)
if outline then
for i=2,15 do palt(i,true) end
pal(1,outline)
local function sspr2(sx, sy, sw, sh, x, y, dw, dh)
sspr(sx, sy, sw, sh, x-1, y, dw, dh)
sspr(sx, sy, sw, sh, x+1, y, dw, dh)
sspr(sx, sy, sw, sh, x, y-1, dw, dh)
sspr(sx, sy, sw, sh, x, y+1, dw, dh)
end
do_work(x0, y, sspr2)
palt()
end
pal(1,c or 1)
do_work(x0, y, sspr)
old.restore()
end
function font_width(str)
local x,xmax = 0,0
for i=1,#str do
local ch = sub(str,i,i)
local param = params[ch]
if ch==" " then
x += 3
elseif ch=="\n" then
xmax,x = max(x,xmax),0
elseif param then
x += param.w + 1
end
end
return max(x,xmax)-1
end
function font_outline(s) outline=s end
end
mode = {}
mode.menu = {}
function mode.menu.start()
create_maze(60,4,20,20)
palette(0)
music(10, 300)
end
function mode.menu.update()
if btnp(4) then
state = "play"
end
end
function mode.menu.draw()
cls(13)
map(62,6,0,0,16,16)
for i=1,50 do x=rnd(200) y=rnd(128) line(x,y-32,x-20,y+52,ccrnd({13,7})) end
font_outline(1)
print("The Legend\n of Nothing", 14, 28, 8, 2)
print("by Niarkou and Sam", 34, 64, 15)
if time()%1<0.5 then
print("Press Ž to start", 30, 100, 11)
end
font_outline()
end
mode.play = {}
function new_world()
return {
map = load_map(),
}
end
function new_entity(x, y, dir)
return {
x = x, y = y,
dir = dir,
cooldown = 0,
anim = rnd(128),
walk = rnd(128),
shot = 0,

skin = 1+flr(rnd(4)),
eyes = 1+flr(rnd(2)),
clothes = 1+flr(rnd(5)),
hair = 1+flr(rnd(6))
}
end
function new_living(x, y, dir, id, data)
local e = new_entity(x, y, dir)
e.r = 0.5 
e.id = id
e.data = data
return e
end
function new_player(x, y)
local e = new_entity(x, y, 1)
e.movements = {}
e.weapon = 1
e.lives = 6
e.maxlives = 6
e.trail = { off=0 }
return e
end
function init_game()
game = {}
game.world = new_world()
game.quest = new_quest()
game.player = new_player(game.quest.start.x, game.quest.start.y)
game.specials = {}
foreach(game.world.map.plants, function(o)
add(game.specials, { x=o.x+.5, y=o.y+.5, r=.5, id=g_spr_plant, data=o, xoff=-4, yoff=-4 })
end)
game.junk = {}
game.spawn = 0
game.music = 0
game.tick = 0 

game.balls = {}
game.score = 0
game.cats = 0
game.explosions = {}




for j=0,15 do for i=0,15 do mset(127-i,63-j,46) end end
end
function draw_bg()
for n=0,9 do
map(112, 48, -128, -128 + 128*n, 16, 16) 
map(112, 48, -128 + 128*n, -128, 16, 16) 
map(112, 48, 128*8, -128 + 128*n, 16, 16) 
map(112, 48, -128 + 128*n, 8*46, 16, 16) 
end
map(0, 0, 0, 0, 128, 46)
draw_ground_tiles()
draw_other_tiles(false)
end
function draw_fg()
draw_other_tiles(true) 
end
function draw_ground_tiles()
foreach(game.world.map.collapses, function(c)
local x, y = c.x*8, c.y*8
if c.t2 then
x += rnd(c.t2)-rnd(c.t2)
y += rnd(c.t2)-rnd(c.t2)
else
y -= max(0, sin(game.tick/80 + (c.x+c.y)/4))
end
spr(g_spr_collapse, x-4, y-4)
if c.t1 then
for n=1,8*c.t1 do
pset(x+rnd(n)-rnd(n),y+rnd(n)-rnd(n),crnd(4,7))
end
end
end)
end
function draw_other_tiles(top)
local function xor(b1,b2) return (not b1)!=(not b2) end
foreach(game.specials, function(s)
if s.d < 16 and xor(top,s.y<=game.player.y) then
if s.id == g_id_person then
draw_person(s)
elseif s.id == g_id_cat then
draw_cat(s)
elseif s.id == g_id_raccoon then
draw_raccoon(s)
elseif s.id == g_spr_fire then
draw_fire(s)
elseif s.id >= 0 then
spr(s.id, s.x*8+s.xoff, s.y*8+s.yoff)
if s.grown then 
spr(53+s.grown, s.x*8+s.xoff, s.y*8+s.yoff-4)
end
end
end
end)
end
local cl1 = { 5, 6, 0, 0 }
local cl2 = { 12, 14, 8, 10, 4 }
local cl3 = { 2, 3, 4, 5, 6, 10 }
local cl4 = { 13, 14 }
function draw_person(p)
local x,y = p.x*8, p.y*8




if p.dead then
clip(0,33,128,32) 
y+=p.dead*8
elseif p.in_water then
clip(0,33,128,32)
y+=4
elseif p.jump then
local k=sin(p.jump/4)
y-=8*k*k
end
local oldpal = msave(0x5f00,0x20)
pal(7,cl1[p.skin])
pal(12,cl2[p.clothes])
pal(13,cl2[p.clothes]+1)
spr(82 + (p.dir < 2 and 0 or 2) + flr(p.walk*4%2), x - 4, y - 6)
pal(14,cl3[p.hair])
pal(15,cl3[p.hair]+1)
pal(8,cl4[p.eyes])
spr(66 + max(1, p.dir), x - 4, y - 11 + flr(p.anim*2.6%2), 1, 1, p.dir == 0)
clip()
oldpal.restore()
end
function draw_fire(o)
for dx=0,7 do
local x=o.x*8-4+dx
local y=o.y*8+2-3*sin(dx/14)
for c=8,11 do
local dy=rnd(4-cos(dx/7))
rectfill(x,y,x,y-dy,c)
y-=dy
end
end
spr(g_spr_fire, o.x*8-4, o.y*8-4)
end
function draw_cat(o)
spr(70 + flr(t() * 3 % 2), o.x * 8 - 4, o.y * 8 - 6, 1, 1, o.dir == 0)
spr(72, o.x * 8 - (o.dir == 0 and 6 or 2), o.y * 8 - 7 - flr(t() * 2.5 % 2), 1, 1, o.dir == 0)
end
function draw_raccoon(o)
spr(73 + flr(t() * 3 % 2), o.x * 8 - 4, o.y * 8 - 6, 1, 1, o.dir == 0)
spr(75, o.x * 8 - (o.dir == 0 and 6 or 2), o.y * 8 - 7 - flr(t() * 2.5 % 2), 1, 1, o.dir == 0)
end
function draw_player(p)

for i = 1,game.cats do
local item = p.trail[(p.trail.off - 2 - i * 10) % #p.trail + 1]
if item then
spr(102 + flr((t() * 3 + i / 7) % 2), item.x * 8 - 4, item.y * 8 - 6, 1, 1, item.dir == 0)
spr(104, item.x * 8 - (item.dir == 0 and 6 or 2), item.y * 8 - 7 - flr((t() * 2.5 + i / 5) % 2), 1, 1, item.dir == 0)
end
end

draw_person(p)
end
function draw_balls()
foreach(game.balls, function(b)
spr(b.spr, b.x * 8 - 4, b.y * 8 - 4)
end)
end
function draw_ui()

local x = 128 - 15
local function disp(id)
smoothrectfill(x,2,x+11,13,2,7,1)
spr(id,x+2,4)
x -= 14
end
if game.inventory.boots then disp(g_spr_boots) end
if game.inventory.gloves then disp(g_spr_gloves) end
if game.inventory.can then disp(g_spr_can) end
if game.inventory.suit then disp(g_spr_suit) end
if game.inventory.ball then disp(g_spr_ball) end
for i=1,game.inventory.nkeys do disp(g_spr_key) end
end
function mode.play.start()
init_game()
init_quest(game.quest)
end
function respawn()
game.spawn = 0
local s = game.quest.save or game.quest.start
game.player.x = s.x
game.player.y = s.y
game.player.dead = nil
reset_map(game.world.map)

foreach(game.specials, function(o)
if o.id==g_spr_boulder or o.id==g_spr_fire then
o.x = o.data.x+.5
o.y = o.data.y+.5
end
end)
end
function mode.play.update()
if game.dead then
if cbtnp(4) then
game.dead = false
respawn()
end
return
end

update_anims()
update_music()
update_quest(game.quest)
update_message()

if not has_message() then

update_balls()
update_world(game.world)
update_player(game.player)
end
end

function atan3(dx,dy)
return ({1,2,0,3,1})[flr(4*atan2(dx,dy)+1.5)]
end
function update_player(p)

if p.dead then
palette(min(8,flr(p.dead*4)))
p.dead += 1/60
p.dir = ({0,2,1,3})[1+flr(p.dead*6)%4]
if p.dead > 2 then
game.dead = true
end
return
end
p.in_water = not p.jump and in_water(p.x, p.y, 0.6, 0.4)
if p.in_water and not game.inventory.suit then
sfx(g_sfx_drown)
p.dead = 0
end

local dx = (btn(0) and -1 or (btn(1) and 1 or 0)) / 12
local dy = (btn(2) and -1 or (btn(3) and 1 or 0)) / 12

if cbtnp(4) and not p.push then

local s
foreach(game.specials, function(o)

if o.d<1 and p.dir==atan3(-o.dx,-o.dy) then s=o end
end)
if not s then
if game.inventory.ball then
shoot(p)
end
elseif s.id==g_spr_boulder and game.inventory.gloves then
p.push=0
p.boulder=s
else
quest_activate(game.quest,s)
end
end

if p.jump then
p.jump -= 1/12
if p.jump > 0 then
dx = p.jdx
dy = p.jdy
else
p.jump = nil
end
elseif cbtnp(5) then
if game.inventory.boots then
sfx(g_sfx_jump)
p.jump = 2

local cx = flr(p.x + ({-2,2,0,0})[p.dir+1])+0.5
local cy = flr(p.y + ({0,0,-2,2})[p.dir+1])+0.5
p.jdx = (cx - p.x) / 24
p.jdy = (cy - p.y) / 24
elseif not p.warned then
open_message("I cannot jump without\nmy boots...\nI really have nothing!",g_style_center)
p.warned = true
end
end

if p.push then
if p.push == 0 then
sfx(g_sfx_push)
p.pdx = ({-1,1,0,0})[p.dir+1]
p.pdy = ({0,0,-1,1})[p.dir+1]
end
p.push += 1/32
p.boulder.id = 0
if p.push >= 1 or block_walk(p.boulder.x + p.pdx*0.5, p.boulder.y + p.pdy*0.5, 0.5, 0.5) then
p.boulder.x = flr(p.boulder.x) + 0.5
p.boulder.y = flr(p.boulder.y) + 0.5
p.push = nil
else

dx = p.pdx / 32
dy = p.pdy / 32
p.boulder.x += dx
p.boulder.y += dy
end
p.boulder.id = g_spr_boulder
end

if not block_walk(p.x + dx, p.y, 0.6, 0.4) then
p.x += dx
end
if not block_walk(p.x, p.y + dy, 0.6, 0.4) then
p.y += dy
end

for i = 0,3 do
if cbtnp(i) then
add(p.movements, i)
elseif not btn(i) then
del(p.movements, i)
end
end
if #p.movements > 0 then
p.walk += 1/60
p.dir = p.movements[1]
if (rnd() > 0.6) sfx(g_sfx_walk)
end

if band(btn(), 0xf) != 0 then
local t = {x=p.x, y=p.y, dir=p.dir}
local len = max(#p.trail, 10 * game.cats + 10)
while #p.trail < len do
add(p.trail, t)
end
p.trail[p.trail.off] = t
p.trail.off = p.trail.off % len + 1
end
end
function shoot(p)
local bx = p.x
local by = p.y - 0.25
local vx = ((p.dir == 0) and -1 or ((p.dir == 1) and 1 or 0)) / 4
local vy = ((p.dir == 2) and -1 or ((p.dir == 3) and 1 or 0)) / 4
local dx, dy = vy, -vx
sfx(g_sfx_shoot)
add(game.balls, {spr = g_spr_ball, x = bx, y = by, vx = vx, vy = vy})
end
function update_world(w)
local p = game.player

do end

local tx, ty = flr(p.x)+.5, flr(p.y)+.5
foreach(game.world.map.collapses, function(c)
if p.jump then

elseif c.t2 then
c.t2 += 1/32
if c.t2 >= 1 then
add(game.world.map.junk, c)
del(game.world.map.collapses, c)
end
elseif c.t1 then
c.t1 += 1/64
if c.t1 >= 1 then
sfx(g_sfx_crumble)
c.t2 = 0
end
elseif c.x==tx and c.y==ty then
c.t1 = 0
end
end)

foreach(game.specials, function(o)

o.dx = p.x-o.x
o.dy = p.y-o.y
o.d = max(abs(o.dx),abs(o.dy))

if o.d < o.r and not p.dead then
quest_touch(game.quest,o)
end

if o.anim then
o.anim += 1/60
end

if o.d < 20 and o.id==g_spr_fire then
local dx = ({-0.1,0.1,0,0})[o.dir+1]
local dy = ({0,0,-0.1,0.1})[o.dir+1]
if not block_walk(o.x + dx, o.y + dy, 0.6, 0.6) then
o.x += dx
o.y += dy
else
o.dir = bxor(o.dir, 1)
end
end
end)
end
function update_balls()
foreach(game.balls, function(b)
b.x += b.vx
b.y += b.vy
if block_fly(b.x, b.y) then
del(game.balls, b)
else
local dx = abs(b.x - game.player.x)
local dy = abs(b.y - game.player.y)
if max(dx, dy) > 9 then
del(game.balls, b)
else
if b.spr == g_energy and (max(dx, dy) < 0.5) then
if game.player.shot < 0 then
game.player.lives = max(0, game.player.lives - 1)
game.player.shot = 1
end
del(game.balls, b)
end
end
end
end)
end
function update_music()
game.music -= 2
if game.music < 0 then
music(game.music % 2 * 4, 300)
game.music += flr(60 * (75 + rnd(30)))
end
end
function update_anims()
game.spawn += 1/60
game.tick += 1
game.player.anim += 1/60

if game.tick % 40 == 0 then
local p=16*64+56/2
for y=0,7 do
poke4(p+y*64,rotr(peek4(p+y*64),4))
end
end

if game.tick % 3 == 0 then
local p=24*64+56/2
local saved = peek4(p+7*64)
for q=p+6*64,p,-64 do poke4(q+64,peek4(q)) end
poke4(p,saved)
end
end
function mode.play.draw()
if game.dead then
palette(0)
cls(1)
print("YOU DIED", 26, 50, 8, 2, 3)
else
if game.spawn < 2 then palette(max(0, flr(8 - game.spawn*4))) end
cls(7) 
local cam_x = game.player.x * 8 - 64
local cam_y = game.player.y * 8 - 64 - message_cam_y()
camera(cam_x, cam_y)
draw_bg()
draw_player(game.player)
draw_balls()
draw_fg()
camera()
draw_ui()
draw_message()
end
end
function _init()
poke(0x5f2e, 1) 
poke(0x5f34, 1)
cartdata("nothing")
state = "menu"
end
function _update60()
if state != prev_state then
mode[state].start()
prev_state = state
end
mode[state].update()
end
function _draw()
mode[prev_state].draw()
end
__gfx__
000000005432211112113211111223456421124600322300000330000002300000000000000011106dcd3dcd3d3dcdcdcdcd3dc6124221332432232323221231
000000004324767777767777777752344356653402ffff2000377300003673000100000001337991d46767b7b767b767b7b6b64c132132212211112221332522
00000000326777777777777777767723336777333eeebef3003cd220035562001100011018999981c67b7b7b7b7b7b7b7b7b7b6d132121523111111342213423
00000000227777677777777777777732227777232e8eeef203cc2772015561300e40200119798971d7b7777777777777767777b3132211414111111421323421
00000000237777777777777676777722237777222eeee8f23ccd2cd20145526300e4ff42198319923b7777677777777777777b7d122412323111111321313221
000000003267677777677777777776231277772102eeef200212ccd202455552004eeef419931982d6b7b7b7b7b7b7b7b7b7b76c212214243111111322321212
000000004325777777767777776742341277672100234200002ccdd203445520004eeef427925892cd6b6b7b767b6b7b7b76764d121323232212212323232121
000000005432211112112113111223451277772100000000000222200021120000042240422003156cd3dcdcd3dcdcd5dcd3dcd6126221111223322311121621
344444435432211112113211113223451277674377777444444777771443333100000000137777216dcdcdcdcdcd5dcd3dcdcdc6137777778111111877777731
45777764432477777767776777765234127777217777444444447777177777610000000012777723d467b6b7b767b767b7b6b64c127777771811118177777721
47371574326777777777777777777723237777217774444444444777154433310000000012767733367b7b7b7b7b7b7b7b7b7b6d117776771181181177677711
46777754227777577777777775777732347777327745555555555477167777710000000022777731d7b7777777777777757777b4237777771118811177757732
34444443347667777777677777777721126777217454645555464547154443310200002032777722c57767777777677777757b7d327767671118811176777723
00044000127776777767777777677721127776214754645555464574167777610010010033777633d7b77677776777777767776c436777771181181177777634
000440001277777777777777777777322377773277555544555555771443333109000090435665343b7577777777777777777b7d132577771811118177765231
00044000237777777777777777777721127777217755554455555577177777610008800012421221d7b7777777777777777777bc153221118111111833322351
00000000127777777777777777777621127777210000000077777777dddddd6d0000000014322521cb7777777777777777777b7d314322321221225212212211
00000000126777777777777777777732127677210000000077777777ddd6dddd0410000014221422d7b7777777777777777777bc424221322232214222322122
03211230237776777777776777777721127777210000e00077777777dd6d7ddd41a1111023132231567777777777776777777b7d512132422221322322213221
21aa991212777777777777777777772122777732000ef00077777777dddddddd2a4aaa9112131231d7b76777777777777776776c212131232521312325213121
1bbbaa91127767777777777777767721327777220e0fe0ef77777777dddd6ddd42b2a2a1122322214b7777777777777777777b7d112232132521322225213231
1bb12ba1237777777777777777677721337776330fe0eef077777777ddd6ddd6042412a112524232d6b77677777777777767776c122524232422242332132522
1bbbbba13477777777677777777777324356653400feef00737373736ddddd7d0000012022423221cb7777777767777777777b7d212423121231232224232421
21111112126777777777777777777722642112460000f00077377737dddddddd0000000015323521d7b7777777777777777777bc315323221231235223121231
333333331277777777777777777677210000000009a90000088088006dddd6dd0012230012353241cb7777777777777777777b7d124221332222322223221231
25aaaa5223777777777777777777772100eee0009aba900089a8a9807dcd6dcd0145673013434322d7b777777777777777777764132142213324252321332522
015995101277767777677777776777320ef77e00ab7ba0008ababa807d6d7d6d1324147313232323c67776777767777777677b7d132121324224242342213423
21344312327777777777677777777722efffffe49aba9fe008a7a8007d7dcd7d1334456213233531d7b7677777776777777577b3132221312254235321323421
1bbba991237777777777777776777722effeffe309a9fbfe8ababa80767d6d7c11334652322523214b7777677777777776777b7d322522321253232321313221
1bb12ba1326767777777777777777623eeffee30000fb7bf89a8a980d6767d761221324141242214d6b7b7b7b7b7b7b7b7b7b7bc412225242241232222321214
1bbbbba143257777767767777767423403eee200000efbfe08808800d6d6767d0122231063132136c46b6b7b767b6b7b7b76664d631323232323232323232136
21111112543221111211211311122345000300000000efe000000000d6dd76dd00111100664214666cd4dcdcd4d3d3d5dcd4dcd6664221111211211311121466
00000000001111000000000000222200002222000022220000000000000000000020020000000000000000000020020000223340000223340031000000000000
0000000001ffbb100110110002ffff2002ffff2002ffff20000000000000000002a02a2000000000000000000260262002ffbb73002dd6673017200000000000
000120001ee11fb1189197102ffeeee22efffff22eeeeef200000000000000002a9999202000000000000000265555202fff2fb732dd2d26731d720000000000
001d72000111ff10138888102fee33302eeffff22e3333e22200000000000000299797205200000022000000252727202ef2f2fb32cdd2dd631cd72000000000
001cd100001ef100013881002e33717223eeee32231771329922220022222200029797202522220052222200026121622eef2fff22cc2d2dd21ccd1000000000
0001100000011000001310000277787227333372278778720299a92099a9a9200299992005262520262625200255652002eeeef2002ccccd201cc20000000000
00000000001ef1000001000000277720027777200277772002a9920009999200002222000265520005555200002222000022222000022222001c200000000000
00000000000110000000000000022200002222000022220009292090029292000000000005252050025252000000000000000000000000000031000000000000
00000000000110000001100000011000000110000001100001101110011111101111111101111001100110011000100011000101110111001110111001110000
00000000001bb100001cd100001cd100001cd100001cd10010011001100010011000100010001001100110101000110111100110001100110001100110000000
00000000001ab100021cd100001cd100001cd120021cd10010011110100010011110111010111111100111001000101011010110001100110001100101100000
31111113001aa100272cd1200012d100021cd272272cd12011111001100010011000100010011001100111001000100011010110001111010001111000010000
1ccccd710019a10002cd127200272100272cd120021cd27210011001100010011000100010011001100110101000100011001110001100010101100100010000
02ccd72000011000015c712001727510025c17100171c52010011110011111101111100001101001111010011111100011000101110100011110100111100000
002d72000019a1000017510001511100001135100153110000000000000000000000000000000000000000000000000000000000000000000001000000000000
00012000000110000001100000100000000011000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111100110001100000110001100011111000010000000001000001000010001011000100000000000000000000000000010000000000000000000000000000
00100100110001100000101010100010001000010000000001000010000010000001001100000000000000000000000000010000000000000000000000000000
00100100110001010001000100010100010011111100110111011011011011101011010111110111001101110011110101111100110001100011001100111110
00100100101010010101000100001000100100110011001001100110100110011011100110101100110011001100111011010100101010101010110100100100
00100100101010010101001010001001000100110011001001110010100110011011010110101100110011001100110000110100101010010101001100101000
00100011000100001010010001001001111011111100110111011110011110011011001110101100101101110011110011001011100100010101001011111110
00000000000000000000000000000000000000000000000000000000000100000010000000000000000001000000100000000000000000000000000000100000
00000000000000000000000000000000000000000000000000000000011000000100000000000000000001000000100000000000000000000000000011000000
01100111101110000111100110111101100110000000111011010000101100008888000000000000000000000000000000000000000000000000000000000000
10011100010001001110001000000110011001000000000111010000110010008888000000000000000000000000000000000000000000000000000000000000
10010101100110010111101110001001101001000000001010000000010010008888000000000000000000000000000000000000000000000000000000000000
10010110000001100100011001001010010111000101010010001111010011118888000000000000000000000000000000000000000000000000000000000000
10010110000001111100011001010010010001000000000000000000010010008888000000000000000000000000000000000000000000000000000000000000
01100111111110000111100110010001100110101101010010000000010011118888000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000010010000000000000001100008888000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
72129213202122222222402222222232e273e2122222222222f22222222222222222222222c27272727272727272727272727272727272727272727272727272
727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272a1b1b1b1b2b2b2b1b1c1727272727272727272
7212d3e3f21332e2e3e3912222222232e273e2122222222222f22222222222222222222222c27272727272727272727272727272727272727272727272727272
72727272727272727272727272727272727272727272727272727272727272727272727272727272727272a1b1b2b2b2b2b2b2b2b2b2b2c17272727272727272
72122322d3f2419222b2922323232233727272122222222222f22222222222222222222222c2727272727272727272a1b1b1b1b1b1b1b1b1b1b1b1b1b1c17272
72727272727272727272727272727272727272727272727272727272727272727272727272727272727272a2b2b2b2b2b2b2b2b2b2b2b2c27272727272727272
e371f2b2b2d34192b2b2d3f2f2f271f2727272122222222222f22222222222222222222222c27272727272727272a122222222222222222222b2b2b22222c172
72727272727272727272727272a1b1b1b1b1b1b1b1b1c17272727272727272727272727272727272727272a2b2b2b2b2b2b2b2b2b2b2b2b2c172727272727272
2222d3f2132333922222222222222222212121222222222222f2b2b2b2b2b2b2b2b2b2b2b2c272727272727272a1b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c1
72727272727272727272727272a2b2b2b2b2b2b2b2b2b2c172727272727272727272727272727272727272a2b2b2b2b2b2b2b2b2b2b2b2b2c272727272727272
222222d3e3e2e2e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3b2b2f322b2b2b2b2b2b2b2b2b2b2c272727272727272a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c2
72727272727272727272727272a2b2b2b2b2b2b2b2b2b2b2c1727272727272727272727272727272727272a2b2b2b21030711030b2b2b2b2c272727272727272
b2b222222222229222e222222222b222222222e22222222223e22222b2b2b2b2b2b2b2b2b2c272727272727272a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c2
72727272727272727272727272a3b2b2b2b2b2b2b2b2b2b2b2c17272727272727272727272727272727272a2b2b3b3e2e271e2e2b3b3b3b3c372727272727272
e3e3e3e371f3b29222e2222222222222222222e22222b2b2d3e222b2b2b2b2b2b2b2b2b2b2c272727272727272a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c2
7272727272727272727272727272a2b2b2b2b2b2b2b2b2b2b3c37272727272727272727272727272727272a3c37272d3f371d3f3727272727272727272727272
72a2b2b2b2b2b2922293b2b2b2b223b2b2b2b2e2b2b2b2b2b2e2b2b2b2b2b2b2b2b2b2b2b2c272727272727272a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c2
7272727272727272727272727272a3b2b2b2b2b2b2b2b3c372727272727272727272727272727272727272727272112121222121212121317272727272727272
21b2b2b2d3e3e3f3b222b2b2b2b240b2b2b2b2e2b2b2b2b2b2e2b2b2b2b2b2b2b2b2b2b2b2c272727272727272a2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c2
727272727272727272727272727272a3b3b3b3b3b3c3727272727272727272727272727272727272727272721021b2b2b2b2b2b2b2b2b2337272727272727272
2323b2b2b2b2e2b222b2b2b2b2b2e2b2b2b2b293b2b2b2b2b2e2b2b2b2b2b2b2b2b2b2b2b2c272727272727272a3b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c3
72727272727272727272727272727272727272727272727272727272727272727272727272727272727272727213232323232323232333727272727272727272
e2e212b2b2b293b22240b2b2b2b2e2b2b2b2b2b2b2b2b2b2b2e2b2b2b2b2b2b2b2b2b2b2b2c27272727272727272a3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3c372
72727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272
e292132323232323239223232323e2b2b2b2b2b2b2b2b2b2b2e2b2b2b2b2b2b2b2b2b2b2b2c27272727272727272727272727272727272727272727272727272
72727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272727272
e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3f3e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2
e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2e2
e200000000000000000000000000000000000000000000000022000000000000000000000000000000b2b2b2b20000b2b2b2b2b2000000000000000000000000
00b2b2b2000000000000000000b2b2b2b2b2b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c6c6c6c6c6c6c6c6c6c6c0000000000000000000000000000000000000000000000000000000000000000000000000000b2b200000000000000000000000000
0000b200b2b2b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000707070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000dddd000000000000000000000000000000000000000000000000000000000000000000000000000
00000000707070e3707070707070e30000000000000000000d00dd00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000d00000dd000000000000000000000000000000000000000000000000000000000000000000000000
000000007070707070707070707070000000000000000000d00000dd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dd0000d0000000000000000000000000000000000000000000000000000000000000000000000000
00000000707070707070e3707070700000000000000000000dddddd0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000101030e37070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007070207070e3707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e3702070707070707070e37000f0000000000000000000000000f100f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000070702070707070e37070707000000000000000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000707020707070e3707070707000000000e20000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007070207070e370707070707000000000000000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000070702070707070707070707000000000000000f100000000e2000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000070702070707070e37070e370f100000000000000000000000000f000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000070702070e370707070707070000000f0000000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000010105070707070707070e37080900000000000a0a18180a090a19181f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000070e37070e3e37070e370707000000000f00000000000000000000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000707070707070707070707070000000000000000000000000f2000000f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
000d0c0e070f000000000000000f070f8005040603000003000b00000009000a800100020b800010000f0000000f0f0f8009080a20000010010f0000000f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
32323232321f3e3e3e2d2e1d321f2e2e2f3e3e3e3e3e3e3e3e2e2e2e2e2e2e2f3e3e3e3e3e2d2e2e2e2e2e2f3e3e2d2e2f3e3e1d330e311f2e2e2e2f3e3e3e3e2b1d32323232323232323232323232323232323232323232323232321f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
3e3e3e3e3e3f2222223d3e2d2e2f3e3e3f22222222050505223d3e3e3e3e3e3f22222222223d3e3e3e3e3e3f22223d3e3f22222d2e372e2f3e3e3e3f222222222b2d3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e2e3e3e3e3e3e2f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22222222222222222222223d3e3f222222222222220505052222222222222222222222222232323232323222222222222222223d3e373e3f22222222222222222b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b292b2b2b2b2b2f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
323232323232323232322222222222222222222222050505222222222232323b3b3b3b3b332727272727272122222222222222223337313232322222222222222b292b2b042b2b010202020202020202032b220102032917010202032f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
2e2e2e2e3e3e3e3e2d2f212222222222222222222b111212132222222327272734272727272727272727272122222222222222232727272727272122222222222b292b2b292b2b2d2e3e3e3e3e3e3e3e2f2b2b3d3e3e2e173d3e3e3e3f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
12121212121212132d2f212222222222222222222b1d32321f2222222327272727272734273434342727273132323232323232332727272727272122222222222b292b22292b2b2d2f2b2b2b2b2b2b2b292b2b2b2b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22222222220522233d3f21222222222222222222323d3e0e3f2222222327272734270a0c273434342727272727272727272727272727272727272122222522222b290103292b2b2d2f17010202020317290102032b2b292b2b010202032b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
222522252222222327212b22222222222222222c27272a3b2b2b22222327271a1c272727272727272727272727272727272727272727272727272122222222222b2d3e3e2f2b2b3d3f172d2e2e2e2f172e3e3e2f2b2b392b2b3d3e3e2f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
222222222222323c342a222222222232322b2b2c270a3c272a2222222327273a3c27272727271a1b1c273434272727272727271a1b1c272727272122222222222b292b2b292b2b2b2b2b2d3e3e3e3f17292b2b292b2b2b2b2b2b2b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
222222222223272727212b2b2b2b23272721222c2727271102020213232727273434273434273a3b3c273434343434270a0c272a222c272727272122222222222b292b2b292b2b010203292b2b323232292b2b290102032b2b323232292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
222225222223270411132122222223270132223c271112142727271423272727272727272727272727272727273427272727272a2b2c272727272122222522222b292b2b392b2b2d3e3e2f2b2b2d3e3e3f2b2b3d3e3e2f2b2b2d3e3e2f2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22222222222327141d1f212222221f273d3e170f3721221d0337011f232727271a1b0c342727272727272727272727272727272a2b2c272727272122222222222b292b2b2b2b2b292b2b292b2b292b2b2b2b2b2b2b2b292b2b292b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22052222222327142d2f212222233f27343a3b3c2721222d2f372d2f232727273a3c34272727272727272727273427272727273a3b3c272727272122222222222b2901020202032f2b2b292b2b292b2b010202032b2b293232292b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22222222222327142d2f212222232727342734272721223d3f373d3f23272727272727272727272727272727270a1c34342734342727272727272122222222222b2d3e3e2e3e3e2f2b2b392b2b392b2b2e3e3e3f2b2b3d3e3e3f2b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
32322232323327192d2f212222232734343434271122222327272721232727272734342727271a1b1b1c273434273a3c273434342727272727272122222522222b292b2b292b2b292b2b2b2b2b2b2b2b292b2b2b2b2b2b2b2b2b2b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
3d2e172e3d2937292d2f212222232734273427272122222327271122232727272727273434272a22222c272727272727272727272727272727272122222222222b292b2b292b2b2901020202020202032f2b2b010202032b2b010203292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
12122212121327042d2f21222223270a0b0b0c272122222212122222232727270a1c273434272a25222c272727272727273434272727272727272122222222222b292b2b392b2b3d3e3e2e3e3e3e3e3e2f2b2b3d3e3e2f2b2b2d3e3e2e2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
25222222222327142d2f212222232727342734271d3222222222222223272727273a0c3434272a22222c27271a121c27271a1b1c2727272727272a22222222222b292b2b2b2b2b2b2b2b292b2b2b2b2b292b2b2b2b2b292b2b292b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22222222222327142d2f212222232727343434273d3e212222222222221327272727272727273a3b3b3c34273a252c27342a222c2734343434272a22222522222b292b2b010202032b2b292b2b042b2b292b2b323232290103292b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22222222222327142d2f21222223272727343427272721222222222222232727272727272727272727272727273a3c27273a3b3c2727272727272a22222222222b292b2b3d3e2e2f2b2b392b2b292b2b392b2b3d3e3e3e3e3e2f2b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22222222222327142d2f2122222327270a1b1b1c27272122222222222223272727272727272727272727272727272727272727272727272727272122222222222b292b2b2b222d2f2b2b2b2b2b292b2b2b2b2b2b2b2b2b2b2b292b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22223232223327142d2f212222232727273a323c27272122222222222222121327272727272727272727272727272727272727272727272727272122222222222b29010203222d2f2b2b010203292b2b042b2b010202020317292b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
05232727172727142d2f2122222327272727272727272122222222222222222212121212121212121212121212121212121212121212121212392122222522222b3d3e3e3f222d2f2b2b2d3e3e2f2b2b292b2b2d3e3e3e3f17392b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22232711221212232d2f21222222121212121212132e212b2b2b22222222222222222222222222222222222222222222222222222222222222222222222222222b2b2b2b2b222d2f2b2b292b2b292b2b292b2b292b2b2b2b2b2b2b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
222327212b0525232d2f21222222222222222b2b232e2122222b2b2222222222222222222222222222222222222222222222222222222222222e0102020202020202020203172d2e0103292b2b2901032e2b2b290102020202032b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22232731323232232d2f21222b2b2222222b2b22232e21222b2b2b22222b2b2222222e2e2e2e2e2e2e2e2e2e2e2e2e2e222e2e2e2e2e2e2e2e3d2e2e2e2e2e2e2e2d3e3e3f173d3e3e3e3f2b2b2d3e3e3f2b2b3d3e3e3e3e3e2e2b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
2b232727272727142d2f2122252b22252b2b2522232e21222b2b2b2b2b2b2b2b2b2b2e2b2b2b22222222222222222222222222222222222222222222222522222b292b2b2b222b2b2b2b2b2b2b292b2b2b2b2b2b2b2b2b2b2b292b2b292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22221205121327142d2f2122222222222b2b2222232f21222b222b2b2b22222222222e222222222222222222222222222b2222222222222222222222222222222b2901020202020202020202032f0102020202020202020203290103292b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b
22222b222b2327142d2f31323232323232323232332f2122222222222222222222222e22222222222222222222222222222b2b222222222222222222222222222b3d3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3f2b2b2b2b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b
3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e3e2e2e2e2e2e2e2e2e2e2b2e2e2e3f2222222222222222222222222222222b2b2222222222222222222222222b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c27272727272727272727272727272727272727272727272727272727272727
271129110202120202133f22222222223232323232322232323222222222222222222b2b222222222222222222222222222222222b2b2222222222222222222b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2c27272727272727272727272727272727272727272727272727272727272727
272129212e2e142e3f222222222222232f272d3e3e3f173d3e2f2222222222222222222222223b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3c272727272727272727272727272727271a1b1c272727272727272727272727
__sfx__
010500001805224052300521805200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0105000018750185501875018550293002f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500001877418771187711877500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000346202f6202a62025620206201c620196201762015620146201262011620106200f6200e6200e6200d6200c6200b6200b6200b6200a62000000000010000100001000010000100001000010000100001
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000f0000f0001800018000180000e0000e00018000180000d0000d0000b0000b0000e0000e0000e00000000130001300018000180001200012000100001000013000130001300012000120001200012000
011600001f7301f7302b7302b7302873028730247302673028730287302473024730217302173023730237301f7301f7302b7302b7302873029730267302873029730297302d7302d7302b7302b7302b7302b730
011600002b7302d7302f7302b7302d7302f7302f7302b7302b730297302b73028730297302b7302b7302873028730267302473026730267302d7302d7302b7302b7302b7302b7302b7302b7202b7202b7102b710
0116000023730237302473024730267302673029730297302873028730267302473026730267301f7301f7302d7302d7302b730297302b7302b73023730237302173021730237302373024730247302473024730
0116000023730237302473024730267302673029730297302873028730267302473026730267301f7301f7302d7302d7302b730297302b7302b7302f7302f7303073030730307303073030730307303073030730
011600001553000000155301a5301c5301d5301a5301c0001553000000155301a5301c5301d5301a5301c000135300000013530185301a5301c530185301c000135300000013530185301a5301c5301853000000
011600001753000000175301c5301d5301f5301c530000001753000000175301c5301d5301f5301c530155001853018500185301d5301f530215301d530235302353024530245302452024520245202451024510
011600001a7501a7501a7501a7501a7501a7501a7501a750157501575015750157501575015750157501575013750137501375013750137501375013750137501875018750187501875018750187501875018750
011600001375013750137501375013750137501375013750157501575015750157501575015750157501575011750117501175011750117501175011750117501575015750157501575015750157501575015750
011600000e033100030e615000000e0330e033000000e6150e033100030e615000000e0330e033000000e6150e033100030e615000000e0330e033000000e6150e033100030e615000000e0330e033000000e615
011600001353011530105300c50011530135301553018500175301553013530185001553017530185301d0001a53018530175301a000185301a5301c5301a0001a5301c5301d530150001c5301c5301c53018000
0114000015710157101572015720187301873018730187301c7301c7301c7301c73015730187301c7301573013730137301373013730177301773017730177301a7301a7301a7301a73013730177301a73013730
011400001173011730117301173015730157301573015730137301373013730137301173015730137301173010730107301073010730107201072010720107201071010710107101071010710107101071010710
0114000015700157001570015700187001870018700187001c7001c7001c7001c70015700187001c7001570015510155101551015510185201852018520185201c5201c5201c5201c52015520185201c52015520
0114000013520135201352013520175201752017520175201a5201a5201a5201a52013520175201a5201352011520115201152011520155201552015520155201352013520135201352011520155201352011520
011400001052010520105201052010520105201052010520105101051010510105101051010510105101051030700307003070030700247002e7002e7002e7002e7002e7002e700000002d7002d7002d70000000
010f00000c7540c7500c7500c7501375013750137501875018750187501875018755187001870018700187001d0001c0001a0001800000000160001a000160001800016000150000000015000150001800018000
010f0000185501a5601c560185601a5601c5601f56024560245602457024570245702450024500245002450011000100000e0000c000000000a0000e0000a0000c0000a000090000900009000090000c00000000
010f000028750237601f7601c76017760137601076010760107601075018700187002970000000247002470024700247002470024700247002270022700227002270022700227000000021700217002170000000
01040000157131771309203171031810318103220002c0002b000290002b0002c00031000000002c000300002c0002b0002900027000000002500029000250002700025000240000000024000240002700018000
0106000017613156131d0001f000200002400022000200001f0001d0001f0002000025000000002000024000200001f0001d0001b00000000190001d000190001b00019000180000000018000180001b00018000
010a00001761317613176131761309202072020720235700357003570035700357003570000000307003070030700307003070030700247002e7002e7002e7002e7002e7002e700000002d7002d7002d70000000
010f00001d6121d6221d6121d62200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01030000184141a4121c4121d4121c4121a4121841500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000c5400c5400c5400c54000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200003232234322353220000000000000000000000000323223432235322000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001c5301d5301f5302153021530215302153021530215302153000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000028420234201f4201c42017420134201042010420104201042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 0b 42 43 44
00 0c 42 43 44
00 0d 42 43 44
02 0e 42 43 44
00 0f 11 43 44
00 10 12 43 44
01 0f 11 13 44
00 14 12 13 44
00 0f 11 13 44
02 10 12 13 44
00 15 42 43 44
01 16 17 43 44
00 41 18 43 44
02 15 19 43 44
00 1a 1b 43 44
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
