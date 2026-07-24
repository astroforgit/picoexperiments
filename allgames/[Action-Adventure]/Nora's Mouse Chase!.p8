pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
--nora's mouse chase!
--by jte   p8jam2 2016-05

north=0
south=1
west=2
east=3

--pico-8's wacky nonstandard
--table manipulation chip
--leaves much to be desired.
function ins(t, v, i)
 for n = #t,i,-1 do
  t[n+1] = t[n]
 end
 t[i] = v
 return t
end

function isin(t, v)
 for x in all(t) do
  if x == v then
   return true
  end
 end
 return false
end

function ceil(x)
 return -flr(-x)
end

--begin my actual game stuff?

-- title screen
(function()
 poke(0x5f2c,3)
 rectfill(0,0,63,63,1)
 for i=1,10 do flip() end
 spr(192,2,2,5,1)
 for i=1,10 do flip() end
 spr(197,13,13,5,1)
 for i=1,10 do flip() end
 spr(202,25,25,5,1)
 for i=1,20 do flip() end
 print("press \151\nto start",29,42,7)
 music(0)
 clip(0,27,25,63)
 local i=0
 while not btnp(5) do
  if i%6==0 then
   local f=flr(i/6)%2
   -- clear canvas
   camera()
   pal()
   rectfill(0,0,63,63,1)
   -- draw nora
   camera(-13,-28+f)
   pal(1,0)
   -- nora's back hair
   spr(241+f,-12,11)
   spr(241+f,2,11,1,1,true)
   -- nora's head
   circfill(0,12,7,15)
   circ(0,12,7,0)
   -- nora's face
   spr(207,-2,9)
   -- nora's front hair
   spr(208+f*3,-9,0,3,2)
   spr(240+f*3,-9,16)
   -- nora's tail
   if f==0 then
    spr(247,-12,26)
   else
    spr(247,-12,21,1,1,true,true)
   end
   -- nora's torso
   spr(214+f*2,-8,18,2,2)
   -- nora's feets
   if f==0 then
    spr(244,-4,32)
    spr(244,1,32)
   else
    line(-9,21,-9,22,0)
    line(8,21,8,22,0)
    spr(245,-9,30)
    spr(246,4,29)
   end
  end
  flip()
  i+=1
 end
 music(-1)
 poke(0x5f2c,0)
 clip()
end)()

blackscreen=false
hud_objects={}
tutorial=nil

entity={x=0,y=0,t=0}
function entity:new(o)
 o = o or {}
 o._super=self
 return setmetatable(o,{__index=self})
end

--draw a menu cursor
function arrow(x,y)
 color(7)
 line(x,y,x,y+4)
 line(x+1,y+1,x+1,y+3)
 pset(x+2,y+2)
end

function drawmenu(selected)
 rectfill(0,0,64,20,1)
 rect(0,0,64,20,0)
 color(7)
 print("attack",6,4)
 print("items",6,12)
 print("skills",38,4)
 print("run",38,12)
 arrow(selected%2==1 and 34 or 2, flr(selected/2)==1 and 12 or 4)
end

function drawskills(selected)
 local skills={
 "shuffle next   2mp",
 "full random    8mp",
 "convert fire  16mp",
 "convert elec. 16mp",
 "convert water 16mp",
 "convert earth 16mp"}
 local y=#skills*8+4
 rectfill(0,0,80,y,1)
 rect(0,0,80,y,0)
 color(7)
 y=4
 for s in all(skills) do
  print(s,6,y)
  y+=8
 end
 arrow(2,4+8*selected)
end

function runtutorial()
 local cards={{3,2},{1,3},{2,2},{0,1},{2,0}}
 local badcards={{3,2},{3,1},{3,1},{3,2},{0,0}}
 local goodcards={{3,3},{3,0},{3,3},{3,1},{0,3}}

 circout()
 tutorial=entity:new({cutin=0})
 function tutorial:update()
  self.t += 1
  if self.dialog.script == "" then
   music(-1)
   tutorial=nil
   circout()
   crossin(false)
  end
 end

 function tutorial:draw()
  pal()
  rectfill(0,0,127,127,1)
  pal(1,7)
  for y=flr(self.t/4)%32-32,127,32 do
   for x=flr(self.t/4)%32-32,127,32 do
    sspr(80,0,16,16,x,y,32,32)
   end
  end
  pal()
  if self.cutin==1 then
   -- menu
   camera(-32,-32)
   drawmenu(0)

   -- arrow
   camera(0,-55)
   color(8)
   line(64,0,64,16)
   line(63,15,64-4,8)
   line(64,16,64+4,8)

   -- cards
   local x=16
   for i=1,5 do
    camera(-x,-79)
    drawcard(cards[i])
    x+=20
   end
  elseif self.cutin==2 then
   camera(-56,-32)
   drawcard(cards[1])
   print("element",-32,0,8)
   line(-12,6,0,8,8)
   print("next link",32,-6,8)
   line(30,-4,17,-1)
  elseif self.cutin==3 then
   local x=16
   for i=1,5 do
    camera(-x,-32)
    drawcard(badcards[i])
    x+=20
   end

   -- arrow
   camera(0,-55)
   color(8)
   line(64,0,64,16)
   line(63,15,64-4,8)
   line(64,16,64+4,8)

   -- menu
   camera(-32,-75)
   drawmenu(1)
  elseif self.cutin == 4 then
   local x=16
   for i=1,5 do
    camera(-x,-32)
    drawcard(goodcards[i])
    x+=20
   end
  elseif self.cutin == 5 then
   -- nina stat sheet
   camera(-24,-32)
   rectfill(0,0,80,26,1)
   rect(0,0,80,26,0)
   pal(1,7)
   spr(10,2,2,2,2)
   print("subject: nina\nresists:\nweakness:\nweight: 15.8 g",18,2,7)

   camera(-81,-42)
   circfill(0,0,3,5)
   spr(132,-3,-3)
   camera(-85,-48)
   sspr(114,7,12,9,-2,-2,7,5)

   -- nora stat sheet
   pal()
   camera(-24,-60)
   rectfill(0,0,80,26,1)
   rect(0,0,80,26,0)
   pal(1,15)
   spr(0,2,2,2,2)
   print("subject: nora\nresists:\nweakness:",18,2,7)
   print("name meaning: stray",2,20,7)

   camera(-81,-70)
   circfill(0,0,3,2)
   spr(128,-3,-3)
   camera(-85,-76)
   circfill(0,0,3,12)
   spr(130,-3,-3)
  end
 end

 crossin(false)
 music(0)
 tutorial.dialog = dialog:spawn({script=sub([["
welcome to nora's mouse
chase!<nod
<clrin this brief adventure rpg,
you are a cat who summons
and mixes magical elements.<nod
<clr<cin0001when you choose attack from
the command menu, you will
be shown a series of links.<nod
<clr<cin0002these links consist of two
parts: an element, and a next
link.<nod
<clrthe element adds to your
attack chain directly.<nod
<clrmatching elements will
combine, giving the attack a
massive boost in power.<nod
<clrthe next link shows which
element you would select
next to continue the chain.<nod
<clr<cin0003if you can't make a good
combo using what you have,
try one of your skills.<nod
<clr<cin0004you may be able to improve
your situation dramatically!<nod
<clr<cin0005enemies you encounter may
have elemental weaknesses.<nod
<clrfigure out what the weakness
is, and you can use a skill
or item to exploit it!<nod
<clr<cin0000that's everything you need
to know to play nora's
mouse chase! good luck, nora!<nod<end]],3)})--"
end

world=entity:new({objects={},room=-1,room_npcs={}})
function world:update()
 foreach(self.objects,function(o)
  o:think()
 end)
end

function world:draw()
 -- draw overworld tiles
 pal()
 palt(0,false)
 camera(8,8)
 for y=0,8 do
  for x=0,8 do
   local t=mget(x+self.room*9,9+y)
   if t~=0 then
    sspr((t%16)*8,flr(t/16)*8,8,8,x*16,y*16,16,16)
   else
    rectfill(x*16,y*16,x*16+16,y*16+16,0)
   end
  end
 end

 -- sort objs by y position
 local objlist = {}
 foreach(self.objects,function(o)
  for i=1,#objlist do
   if o.y < objlist[i].y then
    ins(objlist,o,i)
    return
   end
  end
  add(objlist,o)
 end)

 foreach(objlist,function(o)
  pal()
  camera(-o.x,-o.y)
  o:draw()
 end)
end

function world:moveroom(nroom)
 --store objects in the current room
 local roomnpcs = {}
 foreach(self.objects,function(o)
  if o==player then return end
  add(roomnpcs,o)
 end)
 self.room_npcs[self.room] = roomnpcs

 --remove current room objects from world
 foreach(self.room_npcs[self.room],function(o)
  del(self.objects,o)
 end)

 --retrieve objects from next room
 self.room=nroom
 if self.room_npcs[self.room] then
  foreach(self.room_npcs[self.room],function(o)
   add(self.objects,o)
  end)
  self.room_npcs[self.room]=nil
 elseif self.room==0 then
  key:spawn({x=36,y=52,activate=function(self,plr)
   face_eachother(self,plr)
   sfx(17)
   dialog:spawn({script="<spdnora found bedroom key.\nthe bedroom is now open.<nod<end"})
   mset(14,14,80)
   mset(14,13,81)
   del(world.objects,self)
  end})
  mouse:spawn({x=88,y=40,anim=2,activate=function(self,plr)
   face_eachother(self,plr)
   if player.quest==3 then
    dialog:spawn({script=sub([["
is that cheese i smell?
oh delicious cheese!~
quickly, let me have it!<nod
<clrthanks, nora! where did you
even find this much cheese?<nod
<clrwhaat? numo really did have
cheese?!<nod
<clrbut i was just sending you on
a wild mouse chase! to be
honest, i already ate mine.<nod
<hid<see0003<wai0060
<clr<shoi hope you didn't hurt her
too badly...<nod<hid<fao<the<end]],3)})--"
   elseif not self.dialog then
    player.quest=1
    for o in all(world.room_npcs[1]) do
     if o._super == noise then
      del(world.room_npcs[1], o)
      break
     end
    end
    self.dialog = dialog:spawn({script=sub([["
hi nora. you heard me
squeaking, didn't you?
she has my cheese again...<nod
<clrwho? that dog, of course!
she just won't leave this
poor little mousie alone.<nod
<clrwon't you help me
get the cheese?<nod
<clrwith your hunting prowess,
i'm sure it'll be a piece
of cake! tasty cheesecake!<nod
<clrwhat's wrong, nora?
don't you remember how?
<tut<clrgood luck, nora!<nod<end]],3)})--"
   elseif self.dialog.script ~= "" then
    self.dialog:show()
   else
    dialog:spawn({script="good luck, nora!<nod<end"})
   end
  end})
 elseif self.room==1 then
  table:spawn({x=16,y=56,item=cheese})
  dog:spawn({x=24,y=60,anim=2})
  noise:spawn({x=96,y=120})
 elseif self.room==2 then
  bed:spawn({x=96,y=64})
 elseif self.room==3 then
  local c=cheese:new({activate=function(self,plr)
   face_eachother(self.table,plr)
   if player.quest<2 then
    dialog:spawn({script="numo growls at nora...<nod<end"})
   else
    player.quest+=1
    sfx(17)
    dialog:spawn({script="<spdnora takes the cheese.<nod<end"})
    self.table.item=nil
    for o in all(world.room_npcs[1]) do
     if o._super == table then
      o.item=nil
      break
     end
    end
   end
  end})
  c.table=table:spawn({x=32,y=64,item=c})
  foodbowl:spawn({x=32,y=82,activate=function(self,plr)
   face_eachother(self,plr)
   dialog:spawn({script="numo's food bowl is nearly\nempty...<nod<clrshe must have quite\nan appetite!<nod<end"})
  end})
  waterbowl:spawn({x=30,y=76})
  grapebowl:spawn({x=96,y=84,activate=function(self,plr)
   face_eachother(self,plr)
   dialog:spawn({script="grape vines are great\nfor gnawing on!<nod<clrbut they're covered in these\nweird squishy purple balls.<nod<end"})
  end})
  fridge:spawn({x=48,y=32,activate=function(self,plr)
   face_eachother(self,plr)
   dialog:spawn({script="the cold box isn't making\nany noise right now.\nit's probably sleeping.<nod<end"})
  end})
  dog:spawn({x=48,y=72,anim=2,activate=function(self,plr)
   if player.quest<1 then
    face_eachother(self,plr)
    dialog:spawn({script="what do you want, cat?\ngo play with your mouse\nor something. i'm busy.<nod<end"})
   elseif player.quest==1 then
    face_eachother(self,plr)
    if not self.dialog then
     self.dialog=dialog:spawn({script=sub([["
huh? cheese?
no, i don't have any cheese
for nina today. sorry.<nod
<clryou want what's on the
master's table?? you know
you can't have that, nora!<nod
<clr*growl* scram, you nosey cat.<nod
<endyou're still here?<nod
i'm warning you...<nod
<endalright, that's it, cat.
i've had enough of your
whining.<nod<btl0002<end]],3)})--"
    elseif self.dialog.script~="" then
     self.dialog:show()
    else
     dialog:spawn({script="back for more?\nyou don't know when to\ngive up, do you nora?<nod<btl0002<end"})
    end
   end
  end})
 end
end

world_obj=entity:new({dir=south,anim=0,ticks=0,radius=5,height=6})
function world_obj:spawn(o)
 o = self:new(o)
 add(world.objects, o)
 return o
end

function world_obj:trytiles(x,y)
 for y=flr((y+2)/16),flr((y+7)/16) do
  for x=flr((x+4)/16),flr((x+3+8)/16) do
   local t = mget(x+world.room*9,y+9)
   local f = fget(t,0)
   if f then
    return false
   end
  end
 end
 return true
end

function world_obj:trymove(x,y)
 --test new position
 --for tile collisions
 if not self:trytiles(x,y) then
  if self:trytiles(self.x,y) then
   x = self.x
  elseif self:trytiles(x,self.y) then
   y = self.y
  else
   return false
  end
 end

 -- test new position for object collisions
 for o in all(world.objects) do
  if o ~= self and o.solid ~= false then
   if abs(o.x - x) < o.radius+self.radius and
      (o.y > y-self.height and y > o.y-o.height) then
    if x ~= self.x and abs(o.x - self.x) >= o.radius+self.radius then
     x = self.x
    elseif y ~= self.y then
     y = self.y
    else
     return false
    end
   end
  end
 end

 --prevent character from
 --leaving the screen
 x,y =
     x<4 and 4
  or x>124 and 124
  or x,
     y<8 and 8
  or y>128 and 128
  or y

 local r = self.x~=x or self.y~=y
 self.x,self.y=x,y
 if r then
  if world.room == 0 and self.y >= 104 then
   r,player.x,player.y,player.dir=false,96,120,west
   world:moveroom(1)
   crossin()
  elseif world.room == 1 and self.x >= 108 then
   r,player.x,player.y,player.dir=false,64,96,north
   world:moveroom(0)
   crossin()
  elseif world.room == 1 and self.y < 80 and self.x > 64 then
   r,player.x,player.y,player.dir=false,64,96,north
   world:moveroom(2)
   crossin()
  elseif world.room == 1 and self.y < 80 and self.x < 64 then
   r,player.x,player.y,player.dir=false,64,96,north
   world:moveroom(3)
   crossin()
  elseif world.room == 2 and self.y > 104 then
   r,player.x,player.y,player.dir=false,80,104,south
   world:moveroom(1)
   crossin()
  elseif world.room == 3 and self.y > 104 then
   r,player.x,player.y,player.dir=false,32,104,south
   world:moveroom(1)
   crossin()
  end
 end
 return r
end

--player control
function world_obj:control()
 local x,y = self.x,self.y
 if btn(0) then x -= 1 end
 if btn(1) then x += 1 end
 if btn(2) then y -= 1 end
 if btn(3) then y += 1 end

 --for the count of tokens...
 --devil's pact here:
 self.dir
  = y > self.y and south
 or y < self.y and north
 or x < self.x and west
 or x > self.x and east
 or self.dir
 --do trymove on a separate
 --line because it does warps
 self.anim=self:trymove(x,y) and 1 or 0

 if self.anim==1 and self.ticks%12 == 0 then
  sfx(21+(self.ticks/12)%2)
  if player.encounter_steps > 0 then
   player.encounter_steps -= 1
  end
 end

 --search for nearby
 --objects to activate
 if btnp(5) then
  for o in all(world.objects) do
   if o ~= self and o.activate and abs(o.x-self.x)+abs(o.y-self.y) < 16 then
    o:activate(self)
    break
   end
  end
 end
end

function world_obj:think() end
function world_obj:draw() end

cat=world_obj:new({name="nora",hp=100,max_hp=100,mp=40,max_mp=40,weakness={0.5,1,1.5,1}})
function cat:think()
 if self.anim ~= 0 then
  self.ticks += 1
 else
  self.ticks = 0
 end
end

function cat:draw()
 local f=self.anim==1 and (flr(self.ticks/6)+1)%4 or self.anim==2 and (flr(self.ticks/20)+1)%4 or 0
 if self.dir == south then
  pal(1,15)
  spr(2*(f%2),f>1 and -9 or -8,-16,2,2,f>1)
 elseif self.dir == north then
  pal(1,8)
  spr(2*(f%2),f<2 and -9 or -8,-16,2,2,f<2)
 else
  local d=self.dir == west
  spr(4+2*(f%2)+2*flr(f/3),d and -9 or -8,-16,2,2,d)
 end
end

dog=world_obj:new({name="numo",weakness={1,2,0,1}})
dog.think = cat.think

function dog:draw()
 local f=self.anim==1 and (flr(self.ticks/6)+1)%4 or self.anim==2 and (flr(self.ticks/20)+1)%4 or 0
 if self.dir == south then
  pal(1,13)
  spr(38+2*(f%2),-8,-16,2,2,f>1)
 elseif self.dir == north then
  pal(1,5)
  spr(38+2*(f%2),-8,-16,2,2,f<2)
 else
  local d=self.dir == west
  spr(42+2*(f%2)+2*flr(f/3),d and -9 or -8,-16,2,2,d)
 end
end

mouse=world_obj:new({name="nina"})
mouse.think = cat.think

function mouse:draw()
 local f=self.anim==1 and (flr(self.ticks/6)+1)%4 or self.anim==2 and (flr(self.ticks/20)+1)%4 or 0
 if self.dir == south then
  pal(1,7)
  spr(10+2*(f%2),-8,-16,2,2,f>1)
 elseif self.dir == north then
  pal(1,6)
  spr(10+2*(f%2),-8,-16,2,2,f<2)
 else
  local d=self.dir == west
  spr(32+2*(f%2)+2*flr(f/3),d and -9 or -8,-16,2,2,d)
 end
end

cheese=world_obj:new()
function cheese:draw()
 spr(14,-8,-16,2,2)
end

table=world_obj:new({item=nil})
function table:draw()
 --pal(1,0)
 palt(1,true)
 spr(68,-8,-8)
 spr(68,0,-8,1,1,true)

 if self.item then
  palt()
  camera(-self.x,-(self.y-8))
  self.item:draw()
 end
end

function table:activate(plr)
 if self.item then
  self.item.activate(self.item, plr)
 end
end

foodbowl=world_obj:new({radius=1,height=4})
function foodbowl:draw()
 pal(5,2)
 pal(3,8)
 palt(10,true)
 spr(115,-4,-8)
end

waterbowl=foodbowl:new()
function waterbowl:draw()
 pal(8,6)
 pal(2,5)
 pal(4,5)
 pal(3,6)
 palt(10,true)
 spr(115,-4,-8)
end

grapebowl=foodbowl:new()
function grapebowl:draw()
 pal(8,7)
 pal(4,7)
 pal(5,7)
 pal(3,4)
 pal(10,4)
 spr(115,-1,-12)
end

fridge=world_obj:new({radius=11,height=16})
function fridge:draw()
 sspr(32,48,8,8,-16,-32,32,32)
end

sleepingdog=world_obj:new()
function sleepingdog:draw()
 spr(78,-8,-16,2,2)
end

spinstars=world_obj:new({solid=false})
function spinstars:think()
 self.t+=1
end

function spinstars:draw()
 local f=flr(self.t/4)%4
 if f==3 then
  spr(76,-5,-18,1,1,true)
 else
  spr(75+f,-4,-18)
 end
end

bed=world_obj:new({radius=22,height=20,defeated=false})
function bed:think()
 if player.busy or player.encounter_steps > 0 then return end
 if abs(player.x-self.x) < 32 and abs(player.y-(self.y-(self.height/2-player.height/2))) < 16 then
  player.encounter_steps=30
  sfx(15)
  dialog:spawn({script="<spdfuzzy slippers appeared!<wai0060<btl0003<end"})
 end
end
function bed:draw()
 pal(1,0)
 sspr(0,48,24,16,-24,-32,48,32)
 rect(-22,0,24,1,0)
end

slippers=entity:new({name="slippers",hp=80,max_hp=80,weakness={2,0,1,1}})
function slippers:think()
 --slippers don't think,
 -- you silly cat.
 if self.anim==1 then
  self.t+=1
 else
  self.t=0
 end
end

function slippers:draw()
 local f=flr(self.t/6)%4
 if self.anim==1 and f==0 then
  spr(111,-7,-10)
  spr(111,-1,-8)
 elseif self.anim==1 and f==2 then
  spr(111,-7,-8)
  spr(111,-1,-10)
 else
  spr(111,-7,-8)
  spr(111,-1,-8)
 end
end

noise=world_obj:new({solid=false})
function noise:think()
 self.t += 1
end

function noise:draw()
 if flr(self.t/4)%2 == 0 or flr(self.t/30)%2 == 0 then
  return
 end
 color(7)
 line(1,-8,8,-8)
 line(3,-14,8,-12)
 line(3,-2,8,-4)
end

key=world_obj:new({solid=false})
function key:draw()
 if self.color then
  pal(5,self.color)
 end
 spr(82,-4,-8)
end

dialog=entity:new({text="",time=0,script=""})
function dialog:spawn(o)
 o = self:new(o)
 o:show()
 return o
end

function dialog:show()
 player.busy=true
 player.anim=0
 add(hud_objects, self)
end

function dialog:get_param()
 local n=sub(self.script,1,4)*1
 self.script=sub(self.script,5)
 return n
end

function dialog:update()
 if self.nod then
  self.time += 1
  if btnp(5) then
   self.nod = false
   self.time = 0
  end
  return
 end

 if self.tutorial then
  if self.time > 0 then
   self.time -= 1
   return
  end
  if btnp(2) then
   sfx(19)
   self.tutorial=0
  elseif btnp(3) or btnp(4) then
   sfx(19)
   self.tutorial=1
  elseif btnp(5) then
   sfx(23)
   self.time=20
   if self.tutorial == 1 then
    self.tutorial=nil
   else
    self.tutorial=nil
    self.time=0
    self.text=""
    del(hud_objects,self)
    player.busy=false

    runtutorial()
   end
  end
  return
 end

 if self.wbe then
  if inbattle then
   return
  end
  self.wbe=false
  player.busy=true
  self.hidden=false
 end

 if btnp(4) then
  self.skip_ahead=true
  self.time=0
 end

 if self.time > 0 then
  self.time -= 1
  return
 end

 while self.script ~= "" and self.time == 0 do
  local c = sub(self.script,1,1)
  if c == "<" then
   c = sub(self.script,2,4)
   self.script=sub(self.script,5)
   if c=="nod" then
    self.nod=true
    self.skip_ahead=false
    break
   elseif c=="clr" then
    self.text=""
   elseif c=="end" then
    self.text=""
    del(hud_objects,self)
    player.busy=false
    break
   elseif c=="btl" then
    inbattle=battle:new({id=self:get_param()})
    --del(hud_objects,self)
    --player.busy=false
   elseif c=="wbe" then
    player.busy=false
    self.hidden=true
    self.wbe=true
   elseif c=="hid" then
    self.hidden=true
   elseif c=="sho" then
    self.hidden=false
    del(hud_objects,self)
    add(hud_objects,self)
   elseif c=="wai" then
    self.time=self:get_param()
   elseif c=="fai" then
    crossin(false)
   elseif c=="fao" then
    circout()
   elseif c=="tut" then
    sfx(16)
    self.time=10
    self.skip_ahead=false
    self.tutorial=0
   elseif c=="cin" then
    tutorial.cutin=self:get_param()
   elseif c=="spd" then
    self.skip_ahead=true
    self.time=0
   elseif c=="sfx" then
    sfx(self:get_param())
   elseif c=="see" then
    world:moveroom(self:get_param())
    del(world.objects,player)
    crossin()
   elseif c=="the" then
    music(0)
    the_end=true
   end
  else
   self.text = self.text..c
   self.script = sub(self.script,2)
   self.time = (self.skip_ahead or tutorial) and 0 or (c=="." or c=="!" or c=="?") and 10 or c=="," and 5 or (c==" " or c=="\n" or c=="'") and 1 or 3
   if self.time==3 then
    sfx(8,3)
   end
   if sub(self.script,1,4) == "<nod" then
    self.time = 0
   end
  end
 end
 if self.time > 0 then self.time -= 1 end
end

function dialog:draw()
 if self.hidden then
  return
 end
 --render the dialog box
 --base
 rectfill(5,102,122,122,7)
 --pal(1,0)
 --corners
 spr(127,0,97,1,1,true,true)
 spr(127,120,97,1,1,false,true)
 spr(127,0,120,1,1,true,false)
 spr(127,120,120,1,1,false,false)
 --top
 line(8,97,119,97,2)
 rectfill(8,98,119,99,8)
 rectfill(8,100,119,101,15)
 --left
 line(0,105,0,119,2)
 rectfill(1,105,2,119,8)
 rectfill(3,105,4,119,15)
 --right
 line(127,105,127,119,2)
 rectfill(125,105,126,119,8)
 rectfill(123,105,124,119,15)
 --bottom
 line(8,127,119,127,2)
 rectfill(8,125,119,126,8)
 rectfill(8,123,119,124,15)
 --text
 print(self.text,7,104,0)
 --nod
 if self.nod then
  spr(126,116,117-sin(self.time/10)*2)
 end
 --tut
 if self.tutorial then
  rectfill(32,76,96,96,2)
  rect(32,76,96,96,0)
  color(7)
  print("tutorial?",34,78)
  print("yes",80,84)
  print("no",80,90)
  arrow(76,84+self.tutorial*6)
 end
end

status=entity:new()
function status:new(o)
 local o=self._super.new(self,o)
 o.x = o.target.x
 o.y = 105
 return o
end

function status:update()
 if self.battle.finished then
  del(hud_objects,self)
  return
 end

 --todo fancy health bar
 -- drain animation here
end

function status:draw()
 camera(-self.x,-self.y)
 rect(-19,2,22,21,0)
 rectfill(-21,0,21,20,1)
 print(self.target.name,-18,3,0)
 print(self.target.name,-19,2,7)

 rect(-11,11,20,12,0)
 line(-12,10,19,10,11)
 line(-12,11,19,11,3)
 print("hp",-20,9,11)
 if self.target.hp < self.target.max_hp then
  rect(-12+ceil(max(self.target.hp,0)/self.target.max_hp*31),10,19,11,0)
 end
 if self.target == self.battle.objects[1] then
  local str=""..self.target.hp
  print(str,5-#str*2,9,7)
 end

 if self.target == self.battle.objects[1] then
  rect(-11,17,20,18,0)
  line(-12,16,19,16,14)
  line(-12,17,19,17,8)
  print("mp",-20,15,8)
  if self.target.mp < self.target.max_mp then
   rect(-12+ceil(max(self.target.mp,0)/self.target.max_mp*31),16,19,17,0)
  end

  local str=""..self.target.mp
  print(str,5-#str*2,15,7)
 end
end

function circout()
 camera()
 pal()
 for i=1,10 do
  circfill(64,64,i*8,0)
  flip()
 end
 blackscreen=true
 cls()
 for i=1,5 do flip() end
end

function circin(f)
 blackscreen=false
 for i=10,1,-1 do
  f()
  camera()
  pal()
  circfill(64,64,i*8,0)
  flip()
 end
end

function crossin(s)
 blackscreen=false
 if s ~= false then
  sfx(20)
 end
 for i=1,10 do
  clip(64-i*8,64-i*8,i*16,i*16)
  if tutorial then
   tutorial:draw()
  elseif inbattle then
   inbattle:draw()
  else
   world:draw()
  end
  flip()
 end
 clip()
end

ele_colors={2,1,12,4,5}

function drawelement(element, size)
 circfill(0,0,size and 6+size*2 or 9,ele_colors[element+1])
 circ(0,0,size and 6+size*2 or 9,0)
 sspr(element*8,64,7,7,-6,-7,14,14)
 if size and size > 1 then
  print("x"..size,4,6,7)
 end
end

function drawcard(card)
 --large element background
 circfill(6,7,9,ele_colors[card[1]+1])
 circ(6,7,9,0)
 --next link
 circfill(14,-1,5,ele_colors[card[2]+1])
 circ(14,-1,5,0)
 spr(128+card[2],11,-4)
 --large element foreground
 circfill(6,7,8,ele_colors[card[1]+1])
 sspr(card[1]*8,64,7,7,0,0,14,14)
end

battle=entity:new({finished=false,turn=1,selection=0,menu=0,time=0,next=-1,bg=0})
function battle:new(o)
 o=self._super.new(self,o)
 o.objects={}
 o.playing={}
 --todo don't reuse overworld
 --sprites/objects for battle
 if o.id == 1 then
--[[
  o.bg = 0
  add(o.objects,cat:new({x=32,y=104,dir=east,anim=2,hand={}}))
  add(o.objects,mouse:new({x=96,y=104,dir=west,hp=40,max_hp=40,hand={}}))
]]
 elseif o.id == 2 then
  o.bg = 1
  add(o.objects,cat:new({x=32,y=104,dir=east,anim=2,hand={}}))
  add(o.objects,dog:new({x=96,y=104,dir=west,hp=140,max_hp=140,hand={}}))
 elseif o.id == 3 then
  o.bg = 2
  add(o.objects,cat:new({x=32,y=104,dir=east,anim=2,hand={}}))
  add(o.objects,slippers:new({x=96,y=104,dir=west,hand={}}))
 end
 foreach(o.objects,function(t)
  add(hud_objects,status:new({target=t,battle=o}))
 end)

 sfx(9)
 circout()
 circin(function()o:draw()end)
 music(0)
 return o
end

function battle:finish(nodelay)
 self.finished=true
 inbattle=nil
 music(-1)
 circout()
 if nodelay then
  crossin(false)
 end
end

function battle:deal()
 return {flr(rnd(4)),flr(rnd(4))}
end

function battle:launch()
 --launch attack
 local hand=self.objects[self.turn].hand
 sfx(17)
 self.play_running=true
 -- turn playing cards
 -- into totals
 local totals={}
 foreach(self.playing,function(i)
  for a in all(totals) do
   if a[1] == hand[i][1] then
    a[2] += 1
    return
   end
  end
  add(totals,{hand[i][1],1})
 end)
 self.totals=totals
 --reset selection
 --for new turn
 self.menu=0
 self.selection=0
 self.used_magic=false
 self.next=-1
 self.playing={}
 --resupply hand
 local attacker=self.objects[self.turn]
 for i=1,5 do
  if hand[i][3] then
   hand[i]=self:deal(attacker)
  end
 end
 --change object animation
 attacker.anim=0
 attacker.step=0
 attacker.countdown=30
end

function battle:damage()
 local target=self.objects[self.turn%2+1]
 sfx(10)
 add(self.objects,damagetext:new({x=target.x,y=target.y,text=self.damage_amount==0 and "immune!" or "-"..self.damage_amount,color=8,battle=self}))
 target.hp -= self.damage_amount
 if target.hp < 0 then target.hp = 0 end
end

function battle:update()
 self.time+=1

 --cheat!
 --if btnp(4,1) then
 -- self.objects[2].hp=0
 --end

 foreach(self.objects,function(o)
  while o.hand and #o.hand < 5 do
   add(o.hand,self:deal())
  end
  o:think()
 end)

 if self.play_running then
  local attacker=self.objects[self.turn]

  if #self.objects > 2 then
   return
  end

  attacker.anim = 0

  if attacker.countdown > 0 then
   attacker.countdown -= 1
   return
  end

  local target = self.objects[self.turn%2+1]

  attacker.step += 1
  attacker.countdown = 30

  if target.hp <= 0 or attacker.step > #self.totals then
   attacker.anim=0
   self.turn=self.turn%2+1
   self.play_running=false
   if self.id==1 or self.objects[self.turn].hp <= 0 then
    if self.objects[1].hp <= 0 then
     world:moveroom(0)
     player.x,player.y,player.dir=64,64,south
     dialog:spawn({script="nora felt like she\nneeded a nap...<nod<fai<end"})
    elseif self.id==2 then
     player.quest+=1
     local x,y=48,64
     for o in all(world.objects) do
      if o._super == dog then
       del(world.objects, o)
       x,y=o.x+24,o.y-12
       break
      end
     end
     for o in all(world.room_npcs[1]) do
      if o._super == dog then
       del(world.room_npcs[1], o)
       break
      end
     end
     sleepingdog:spawn({x=x,y=y,activate=function(self,plr)
      face_eachother(self,plr)
      dialog:spawn({script="......<nod<clrat times like this, it's\nprobably best to let\nsleeping dogs lie.<nod<clrshe looks like she could\nuse the nap, anyway.<nod<end"})
     end})
     spinstars:spawn({x=x,y=y})
    elseif self.id==3 then
     dialog:spawn({script="the slippers stopped\nmoving...<nod<end"})
     if not kitchen_key then
      kitchen_key=key:spawn({x=96,y=74,color=9,activate=function(self,plr)
       face_eachother(self,plr)
       sfx(17)
       dialog:spawn({script="<spdnora found kitchen key.\nthe kitchen is now open.<nod<end"})
       mset(11,14,80)
       mset(11,13,81)
       del(world.objects,self)
       kitchen_key=true
      end})
     end
    end
    self:finish(self.objects[1].hp > 0)
   else
    if self.turn == 1 then
     sfx(18)
    end
    self.objects[self.turn].anim=2
   end
   return
  end

  attacker.anim=1
  local atk = self.totals[attacker.step]
  self.damage_amount=2+2*atk[2]*atk[2]
  if target.weakness then
   self.damage_amount = flr(self.damage_amount * target.weakness[atk[1]+1] + 0.5)
  end
  if atk[1]==0 then
   sfx(14)
   self.damage_amount = flr(self.damage_amount/4+0.5)
   add(self.objects,fire:new({target=target,battle=self}))
  elseif atk[1]==1 then
   sfx(14)
   add(self.objects,lightning:new({target=target,battle=self}))
  elseif atk[1]==2 then
   sfx(9)
   self.damage_amount = flr(self.damage_amount/2+0.5)
   add(self.objects,water:new({target=target,battle=self}))
  elseif atk[1]==3 then
   sfx(16)
   local px,vx=earth.px,earth.vx
   if self.turn == 2 then
    px,vx=-px,-vx
   end
   add(self.objects,earth:new({target=target,battle=self,px=px,vx=vx}))
  else
   self:damage()
  end
 elseif self.turn==1 then
  local hand=self.objects[1].hand
  if self.menu==0 then
   if btnp(0) and self.selection%2==1 then
    sfx(19)
    self.selection-=1
   elseif btnp(1) and self.selection%2==0 then
    sfx(19)
    self.selection+=1
   elseif btnp(2) and flr(self.selection/2)==1 then
    sfx(19)
    self.selection-=2
   elseif btnp(3) and flr(self.selection/2)==0 then
    sfx(19)
    self.selection+=2
   elseif btnp(5) then
    if self.selection==0 then
     -- attack
     sfx(23)
     self.menu,self.selection=1,1
    elseif self.selection==1 then
     --skills
     sfx(23)
     self.menu,self.selection=2,0
    elseif self.selection==2 then
     -- items
     sfx(11)
    elseif self.selection==3 then
     -- run
     sfx(25)
     self:finish(true)
    end
   end
  elseif self.menu==2 then
   if btnp(2) and self.selection>0 then
    sfx(19)
    self.selection-=1
   elseif btnp(3) and self.selection<5 then
    sfx(19)
    self.selection+=1
   elseif btnp(4) then
    sfx(13)
    self.menu,self.selection=0,0
   elseif btnp(5) then
    local s=self.selection
    local mp=s==0 and 2 or s==1 and 8 or 16
    if self.objects[1].mp < mp then
     sfx(11)
    else
     sfx(24)
     self.used_magic=true
     self.menu,self.selection=1,1
     self.objects[1].mp -= mp
     if s==0 then
      -- shuffle next
      foreach(hand,function(c)
       c[2]=flr(rnd(4))
      end)
     elseif s==1 then
      -- full random
      for i=1,5 do
       hand[i]=self:draw()
      end
     elseif s>=2 then
      -- convert
      local count,count2,mcc={0,0,0,0},{0,0,0,0},-1
      -- count cards
      foreach(hand,function(c)
       -- don't count the
       -- element we're replacing!
       if s-2==c[1] then return end
       -- +1
       count[c[1]+1]+=1
       count2[c[2]+1]+=1
       if count[c[1]+1]>=3 then
        -- if there's at least
        -- three of an element
        -- in our hand, it's
        -- obviously the most
        -- common card.
        mcc=c[1]
       end
      end)
      -- we don't have at least
      -- three of any card, so
      -- find the most common
      -- card out of the remainder
      if mcc==-1 then
       -- find highest count
       for i=1,4 do
        if count[i] > 0 or count2[i] > 0 then
         -- select first element
         -- that has a card
         if mcc==-1 then
          mcc=i-1
         -- select highest base
         -- element count
         elseif count[i] > count[mcc+1] then
          mcc=i-1
         -- break ties with the
         -- next link count
         elseif count[i] == count[mcc+1] and count2[i] > count2[mcc+1] then
          mcc=i-1
         end
        end
       end
       -- if every count was 0,
       -- that means the hand
       -- consists entirely of
       -- the element we're
       -- converting to...
       -- and linking to the
       -- element we're
       -- converting to.
       --
       -- a total nop.
       if mcc==-1 then return end
      end
      -- replace all of the
      -- most common element with
      -- the conversion element.
      foreach(hand,function(c)
       if c[1]==mcc then
        c[1]=s-2
       end
       if c[2]==mcc then
        c[2]=s-2
       end
      end)
     end
    end
   end
  elseif self.menu==1 then
   if btnp(3) then
    sfx(19)
    self.selection=6
   elseif btnp(2) and self.selection==6 then
    sfx(19)
    self.selection=3
    while self.selection>1 and hand[self.selection][3] do
     self.selection-=1
    end
    while self.selection<6 and hand[self.selection][3] do
     self.selection+=1
    end
   elseif btnp(0) and self.selection>1 and self.selection<6 then
    sfx(19)
    local was=self.selection
    self.selection-=1
    while self.selection>0 and hand[self.selection][3] do
     self.selection-=1
    end
    if self.selection==0 then
     self.selection=was
    end
   elseif btnp(1) and self.selection<5 then
    sfx(19)
    local was=self.selection
    self.selection+=1
    while self.selection<6 and hand[self.selection][3] do
     self.selection+=1
    end
    if self.selection==6 then
     self.selection=was
    end
   end
   if btnp(4) then
    if #self.playing > 0 then
     sfx(13)
     local c=self.playing[#self.playing]
     self.playing[#self.playing]=nil
     hand[c][3]=false
     if #self.playing==0 then
      self.next=-1
     else
      self.next=hand[self.playing[#self.playing] ][2]
     end

     --reset selection
     self.selection=1
     while self.selection<6 and hand[self.selection][3] do
      self.selection+=1
     end
    elseif self.used_magic then
     sfx(11)
    else
     sfx(13)
     self.menu,self.selection=0,0
    end
   end
   if btnp(5) then
    if self.selection==6 then
     if #self.playing==0 then
      --can't launch 0 cards
      sfx(11)
     else
      self:launch()
     end
     return
    end
    local card=hand[self.selection]
    if card[3] or (self.next~=-1 and card[1]~=self.next) then
     sfx(11)
     return
    end
    sfx(12)
    add(self.playing,self.selection)
    card[3]=true
    self.next=card[2]
    while self.selection < 6 and hand[self.selection][3] do
     self.selection+=1
    end
    if self.selection == 6 then
     self.selection-=1
     while self.selection > 0 and hand[self.selection][3] do
      self.selection-=1
     end
     if self.selection==0 then
      self.selection = 6
     end
    end
   end
  end
 elseif self.turn > 1 and not player.busy then
  local hand=self.objects[self.turn].hand
  --todo real ai here
  local n=6-flr(sqrt(rnd(25)+1))
  for i=1,n do
   add(self.playing,i)
  end
  self:launch()
 end
end

function printo(text,x,y,c,c2)
 for y=y-1,y+1 do
  for x=x-1,x+1 do
   print(text,x,y,c2)
  end
 end
 print(text,x,y,c)
end

function battle:draw()
 cls()
 camera(8,8)
 for y=0,8 do
  for x=0,8 do
   local t=mget(x+self.bg*9,y)
   if t~=0 then
    sspr((t%16)*8,flr(t/16)*8,8,8,x*16,y*16,16,16)
   end
  end
 end

 for o in all(self.objects) do
  camera(-o.x,-o.y)
  pal()
  o:draw()
 end

	camera()
	pal()
	local hand=self.objects[self.turn].hand
 if self.play_running then
  -- render self.totals
  local x,y=64-(#self.totals-1)*14,48
  foreach(self.totals,function(a)
   camera(-x,-y)
   drawelement(a[1],a[2])
   x+=28
  end)
 elseif self.turn==1 then
  if self.menu==0 then
   camera(-32,-64)
   drawmenu(self.selection)
  elseif self.menu==2 then
   camera(-24,-24)
   drawskills(self.selection)
  elseif self.menu==1 then
  local x,y=64,32
  if #self.playing == 0 then
   camera(-x,-y)
   drawelement(4)
  else
   x -= min(#self.playing,4)*10
   foreach(self.playing,function(s)
    camera(-x,-y)
    drawelement(hand[s][1])
    x += 20
   end)
   if #self.playing<5 then
    camera(-x,-y)
    if self.time%12 > 6 then
     drawelement(hand[self.playing[#self.playing] ][2])
    else
     drawelement(4)
    end
   end
  end

  x,y=64-48,57
  local i=1
  foreach(hand, function(c)
   if c[3] then
    i+=1
    x+=20
    return
   end
   if self.selection==i then
    y=48
   else
    y=57
   end
   camera(-x,-y)
   drawcard(c)
   --selection arrow
   if self.selection==i then
    y=39+sin(self.time/10)*2
    camera(-x,-y)
    spr(133,-2,0)
    line(6,0,6,6,8)
    spr(133,7,0,1,1,true)
   end
   x+=20
   i+=1
  end)
  camera()
  local c=self.selection==6 and (#self.playing == 0 and 2 or self.time%10 < 5 and 3) or 1
  rectfill(40,77,87,83+6,c)
  rect(40,77,87,89,0)
  print("launch!",51,81,7)
 end
 end
end

damagetext=entity:new({text=""})
function damagetext:think()
 self.t += 1
 if self.t > 30 then
  del(self.battle.objects, self)
 end
 self.y -= 1
end

function damagetext:draw()
 printo(self.text,-#self.text*2,-12,self.color)
end

fire=entity:new()
function fire:think()
 self.t += 1
 if self.t%7 == 0 then
  self.battle:damage()
 end
 if self.t >= 30 then
  del(self.battle.objects,self)
 end
end

function fire:draw()
 if self.t%2 == 0 then
  return
 end
 for x=self.t%8,self.t%8+16,6 do
  sspr(1,65,5,5,self.target.x-8-6+x,self.target.y-12,8,12)
 end
end

lightning=entity:new({w=64+12,h=0})
function lightning:think()
 self.t += 1
 self.w -= 12
 self.h += 32
 if self.w <= 0 then
  self.battle:damage()
  del(self.battle.objects,self)
 end
end

function lightning:draw()
 if self.w > 32 then
  rectfill(0,0,128,128,6)
 end
 if self.w > 0 and self.t%2 ~= 0 then
  sspr(0,72,8,8,self.target.x-self.w/2,0,self.w,self.h)
 end
end

water=entity:new()
function water:think()
 self.t+=1
 if self.t == 8 or self.t == 30-8 then
  self.battle:damage()
 end
 if self.t >= 30 then
  del(self.battle.objects,self)
 end
end

function water:draw()
 local rectheight=16
 if self.t < 8 then
  rectheight=self.t*2+2
 elseif self.t > 30-8 then
  rectheight=(30-self.t)*2
 end
 if self.t%3 ~= 0 then
  rectfill(self.target.x-8,self.target.y-rectheight,self.target.x+8,self.target.y,12)
  line(self.target.x-7,self.target.y-rectheight,self.target.x-7,self.target.y,7)
  line(self.target.x-4,self.target.y-rectheight,self.target.x-4,self.target.y,7)
 end
 for x=0,16,4 do
  circfill(self.target.x-8+x,self.target.y-rectheight+sin((self.t*4+x)/32)*2,3,7)
 end
end

earth=entity:new({px=64,py=16,vx=-2.45,vy=6,hit=false})
function earth:think()
 if self.t < 10 then
  self.t += 1
  if self.t == 10 then
   sfx(9)
  end
  return
 end
 if self.py > 0 then
  self.vy -= 0.5
  self.px += self.vx
  self.py += self.vy
  if self.py < 0 then
   self.py = 0
  end
 else
  self.t += 1
  if not self.hit then
   self.hit = true
   sfx(15)
   self.battle:damage()
  end
  if self.t >= 30 then
   del(self.battle.objects,self)
  end
 end
end

function earth:draw()
 sspr(25,65,5,5,self.target.x-self.px-10,self.target.y-self.py-20,20,20)
end

function face_eachother(actor1,actor2)
 if abs(actor1.x-actor2.x) < abs(actor1.y-actor2.y) then
  if actor1.y < actor2.y then
   actor1.dir,actor2.dir=south,north
  else
   actor1.dir,actor2.dir=north,south
  end
 else
  if actor1.x < actor2.x then
   actor1.dir,actor2.dir=east,west
  else
   actor1.dir,actor2.dir=west,east
  end
 end
end

function _init()
 player=cat:spawn({x=64,y=120,busy=false,quest=0,encounter_steps=0})
 world:moveroom(1)
end

function _update()
 if tutorial then
  tutorial:update()
 elseif inbattle then
  inbattle:update()
 else
  if not player.busy then
   player:control()
  end
  world:update()
 end
 foreach(hud_objects,function(o)
  o:update()
 end)
end

function _draw()
 if blackscreen then
  cls()
 elseif tutorial then
  tutorial:draw()
 elseif inbattle then
  inbattle:draw()
 else
  world:draw()
 end

 foreach(hud_objects,function(o)
  camera()
  pal()
  o:draw()
 end)
 camera()
 if the_end then
  local t="( the end )"
  print(t,64-#t*2,24,7)
  t="pico-8 jam #2"
  print(t,64-#t*2,40,6)
  t='"chain reaction"'
  print(t,64-#t*2,48,6)
  t="entry by jte, 2016-05"
  print(t,64-#t*2,88,6)
  t="jte@kidradd.org"
  print(t,64-#t*2,96,5)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f8880888f000000000000000000000000f880888f000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f1888881f000000f888808888f0000008ff8888ff0000000f88808888f000000f88808888f000000000000000000000000000000000000000000000000000
008188118881800000111888881110000088f88f888f0000000fff8888fff000000fff8888fff000000000000000000000007600006700000000000000000000
00888111118880000081811188818000008888ffff8800000088f88f888f00000088f88f888f0000000776000067700000071166661170000000000000000000
0088118118108800008881111188800000888ff8f8f88000008888ffff880000008888ffff880000000711666611700000011666666110000000000000000000
0008118118100000008811811810880000888ff8f8f0000000888ff8f8f8800000888ff8f8f88000000016666661000000006666666600000000000000000000
0088811f111800000008118118100000000888fffff0000000888ff8f8f0000000888ff8f8f0000000006666666600000000616116100000000aaa0000000000
00880fffff8800000088811f1118000000888fffff880000000888fffff00000000888fffff000000000616116100000000061611610000000aaaaaaa0000000
000000888000000000880fffff880000008800888088000000888fffff88000000888fffff8800000006616116106000000661111116600000aaaaa9aaa00000
000008888800000000000088800000000000008880000000008800888088000000880088808800000000611111160000000066177106000000a99aaaaaaaa000
000080888080000000008888888000000000088888000000000088888800000000000888880000000006061771606000000000666660000000a99aaaaaaaaa00
000001f1ff000000000000888000000008008fffff000000000000888000000000880088800000000000006666000000000006066000000000aaaaaaa99aa000
00000f1fff00000000000f11ff00000000880fffff00000000088fffff00000008008fffff00000000000606606000000000000776000000000aa9aaa99aaa00
0000008080000000000081ff8800000000000080800000000880088fff80000000000ff88f0000000000000770000000000000060600000000aaaaaaaaaaaa00
0000008080000000000000808800000000000080800000000000088008800000000000888000000000000060060000000000000000000000000aaaa0aaaaa000
000000000000000000000000000000000000000000000000000d50000005d000000000000000000000005d00005d000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000d50555505d00000d5000000005d0000005d55555d00000000d0000005d0000000d0000005d000
00000000000000000000000000000000000000000000000000d1155555511d0000d1505555051d000005ddd555ddd0000005dd55555dd0000005dd55555dd000
0000000000000000000007600067000000000760006700000051555511551500001115555551110000005d555d5d50000005ddd555ddd0000005ddd555ddd000
000077600067700000007776667770000000777666777000005555151115550000515555115515000005555d5dd5500000005d555d5d500000005d555d5d5000
00007776667770000000776666677000000077666667700000055151151150000005551511155000000555d5dd5d50000005555d5dd550000005555d5dd55000
0000676666670000000066766666000000006676666600000005115115115000000551511511500000055dd5dd5d5000000555d5dd5d5000000555d5dd5d5000
0006667666660000000667767670000000066776767000000005111111115000000511511511500000055ddddddd500000055dd5dd5d500000055dd5dd5d5000
000667767670000000066776767000000006677676700000000551dddd1550000055111111115500000055ddddd5500000005ddddddd500000005ddddddd5000
0006667676760000000666777766000000066677776600000005005555005000005051dddd1505000000500555005000000555ddddd55500000555ddddd55500
00006777776000000000667777600000000066777760000000000555555000000000005555000000000000555500000000050005550005000005000555000500
00066677770600000006006666000000000600666600000000005055550500000000555555550000000500555550000000000555555500000000005555500000
000000066000000000000606600000000000000660600000000000d11d0000000000005555000000000555dddd00000000000055550000000000005555000000
000000666600000000000007700000000000000770000000000000d11d00000000000511dd000000000055dddd000000000005dddd000000000555dddd000000
000000077000000000000060066000000000006060000000000000d00d00000000000011ddd000000000000d0d000000000555ddddd00000000055dddd000000
000000606000000000000600000000000000000600000000000000d00d000000000000d00dd000000000000d0d000000000050dd0dd000000000000ddd000000
44444444000000001111111144444444011111111111111111111111000000000000000022222222244444420000000000000000000000000000000000000000
44442444111001001111111144442444154444441111111111111111000000111100000022221222244444420000000000000000000000000000000000000000
22222222111001001111111122000022155555550111111111111110000011111111000011111111244444420999990009990000000000000000000000000000
2222222200100100111111112000000201111122011111111111111000011111111110001111111124444a420000000090000a00090a09000000000000000000
4444444400100100111111114000000400000012001111111111110000111111111111002222222224444442aa000aa00a000000900000900000000000000000
244444440010011111111111200000040000001200111111111111000011111111111100122222222444444200000000aaa00090900a0090000000000000005d
2222222200100111111111112000000200000152000111111111100001111111111111101111111124444442099999000a09990000aaa000000000dd555555dd
22222222000000001111111120000002000015120001111111111000011111111111111011111111244444420000000000000000000a00000000005ddd555ddd
244900020000000000000000222222222222222200001111111100002222222222222222222222222222222222222222222222222222222255500005d55555d5
24440002000000000000000022222222222222220000111111110000222222222222222222222222222222222222222222222222222222220555005555d5d550
244400020000000000000000222222222222222200000111111000002222222222222222222222222222222222222222222222222222222200dd55555ddddd55
24440002000400000000000022222222222222220000011111100000222222222222222222222222222222222222222222222222222222220ddd5555d55dd555
2441111200040000055000002222222222222222000000111100000022222222222222222222222222222222222222222222222222222222dd0dd555ddddddd5
244111120044000050055555222222222222222200000011110000002222222222222222222222222222222222222222222222222222222200ddd55555ddd555
24111112004400005005050522222222222222220000000110000000222222222222222222222222222222222222222222222222222222220dd0000055500055
24111112044400000550000522222222222222220000000110000000222222222222222222222222222222222222222222222222222222220000000005550005
00000000000000000000004444566666006666002222222222222222222222222222222222222222222222222222222222222222222222222222222200000000
0000000000000000000ddd4444566666066666602222222222222222222222222222222222222222222222222222222222222222222222222222222200000000
00dddddddddddd66666ddd4445566666066666602222222222222222222222222222222222222222222222222222222222222222222222222222222200000000
0dddddddddddd666666ddd4454566666066666d02222222222222222222222222222222222222222222222222222222222222222222222222222222200000000
0ddddddddddd6666666ddd4454566666066666d02222222222222222222222222222222222222222222222222222222222222222222222222222222200000000
0ddddddddddd6666666666445456666606666660222222222222222222222222222222222222222222222222222222222222222222222222222222220ddd0000
1dddddddddddd666666ddd44555666660666666022222222222222222222222222222222222222222222222222222222222222222222222222222222dddd0000
1ddddddddddddd66666ddd44445666660555555022222222222222222222222222222222222222222222222222222222222222222222222222222222dddd5555
1dddddddddddddd6666ddd44000000001156666622222222222222222222222222222222222222222222222222222222000007777600007700000000000ff882
1dddddddddddddd6666ddd44000000001456666622222222222222222222222222222222222222222222222222222222000007777766677700000000000ff882
1ddddddddddddddd666ddd2200000000455666662222222222222222222222222222222222222222222222222222222200000777767776760000000000fff882
15dddddddddddddd66666622088888005456666622222222222222222222222222222222222222222222222222222222777777776777776600000000ffff8882
155555555555555555555522825242805456666622222222222222222222222222222222222222222222222222222222077777776767677600000000fff88820
1555555555555555555555228425253a54566666222222222222222222222222222222222222222222222222222222220007777767d7d7661111100088888820
115555555555555555555522888888805556666622222222222222222222222222222222222222222222222222222222000007776c777c760111000088882200
11441111111111111114412208888800445666662222222222222222222222222222222222222222222222222222222200000007067777660010000022220000
00000000000000000000000000000000000000000888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000000a0000006000000565000006660008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
008880000a0a00000007000006666500000060008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000
08898800a00aa0000076600005665500000660000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000
0899980000aa0a000066600006655500000600000000888800000000000000000000000000000000000000000000000000000000000000000000000000000000
009a900000a000000006000000555000000000000000008800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
88000880088880088888000888800880088880008800088008888008800880088880088888800000088880088008800888800088880088888808800001100110
88800880880088088008808800880880880008008880888088008808800880880008088000000000880008088008808800880880008088000008800017700771
88080880880088088008808800880080880000008808088088008808800880880000088000000000880000088008808800880880000088000008800071100117
88008880880088088008808800880800880000008800088088008808800880880000088000000000880000088008808800880880000088000008800071100117
88000880880088088888008888880000088880008800088088008808800880088880088888000000880000088888808888880088880088888008800077700777
88000880880088088008808800880000000088008800088088008808800880000088088000000000880000088008808800880000088088000000000000000000
88000880880088088008808800880000800088008800088088008808800880800088088000000000880008088008808800880800088088000000000008008080
88000880088880088008808800880000088880008800088008888000888800088880088888800000088880088008808800880088880088888808800000880800
00118000000000811000000001180000000000081100000000001111111100000000111111110000000000000000000000000000000000000000000000000000
001ff811181118ff1000000001ff88111811188ff100000000018888888810000011888888881100000000000000000000000000000000000000000000000000
001fff8881888fff1000000001ffff8881888ffff100000000188888888881001188888888888811000000000000000000000000000000000000000000000000
001fff8888188fff1000000001ffff8888188ffff100000000188188888181008888818888818888000000000000000000000000000000000000000000000000
001f88888818888f10000000001f88888818888f1000000000188188888181008881118888811188000000000000000000000000000000000000000000000000
00188888881888888100000000188888881888888100000001881888888181001110188888810011000000000000000000000000000000000000000000000000
01888888818888888100000001888888818888888100000001881888888818100001188888881000000000000000000000000000000000000000000000000000
01888881101888888811100001888881101888888810000001881111111118100017111111111000000000000000000000000000000000000000000000000000
018888100001888888881000018888100001888888810000001177777f77711000117777f7777100000000000000000000000000000000000000000000000000
188881000000118888810000188881000000118888881000001111111111111001ff111111111100000000000000000000000000000000000000000000000000
188881000000001111100000188881000000001188811000001ffffff1ffff1001ffffff1ffff100000000000000000000000000000000000000000000000000
188810000000000000000000188810000000000011100000001ffffff1ffff10001fffff1ffff100000000000000000000000000000000000000000000000000
188810000000000000000000188810000000000000000000001fffff1fffff100001fff11fff1000000000000000000000000000000000000000000000000000
18881000000000000000000018881000000000000000000000011111011111000000111001110000000000000000000000000000000000000000000000000000
18888100000000000000000018888100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01818810000000000000000001818100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01881110000000000011110001818100188100000018100001000000010000000000000000000000000000000000000000000000000000000000000000000000
00181100001111000188810001881100188100000188810018110000181001100000000000000000000000000000000000000000000000000000000000000000
00011100018881000188810000181000188810000188100088881000018118810000000000000000000000000000000000000000000000000000000000000000
00000000188881001888810000011000111110000188100018881000001881100000000000000000000000000000000000000000000000000000000000000000
00000000188881001888810000000000000000000011000001110000000110000000000000000000000000000000000000000000000000000000000000000000
00000000188881001888100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000188810001881000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111100001110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000001010000000000000100000000000000000000000000000101010100000000000000000000000001010100010000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4040404040404040404141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404242424040404141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040424242424240404141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4042424242424242404141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4042424242424242404141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4042424242424242404141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4042424242424242404141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404949494949494949490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040404040404949494949494949490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4949404040404049494141414141414141410000000000000000004141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
49494040404040494941414141414141414100000000000000000041404040404a4040410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000424242424200004949494949494949410047424242424248004140424242424240410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000424242424200004900004900000049410042424242424242004140424242427440410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000454242424600004900004900000049410042424242424242004140424242426340410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005542424256000040404a40404a4040410045424242424246004140424242426340410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404242424040404042424242424240414940404542404040494040404045424040490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404242424040404042424242424243414940405542404040494040404055424040490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424040404a40404040414242420042424242494042424200424242420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010c00000c773007030c603007030c7730070300703007030c7730070300703007030c7730070300703007030c773007030c5730c5730c773007030c573005030c773007030c573005030c773007030c57300503
010c00000c570115000e57013500105700000000000000000b5700000009570000000757000000075700000009572095720957209500075700000007570000000957209572095720000000000000000000000000
010400180c55000000105001050010550000001350000000135501050010500000001055000000105001050013550000001050000000105500000010505000050c50500005115050000515505000051150500005
010400180c55000000115001850011550000001150000000155500000011500000001155000000115000000015550000001750000000115500000013500000001c500000001a5000000018500000001750000000
010400180c55000000000001550013550000000000000000175500000000000000001355000000000000000017550000000000000000135500000000000000000000000000000000000000000000000000000000
010600000030300000000000000000000000000000000000000000000000000000000000000000000000000000303000000000000000000000000000000000000000000000000000000000000000000000000000
010420210c5500000000000000001155000000000000000017550000000000000000185500000000000000001c5500000000000000001f5500000000000000001855218552185521855218552185521855218555
01300002110730c005110030000000000000000000000000000030000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000
000200000b5700f570145701b5701b5701b5001a50015500165001e5001d500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000500002f6102e6102d6202a6202963029660286502763026620256202462024620236102261021610206101e600006000060000600006000060000600006000060000600006000060000600006000060000600
00030000337702e700377003a7703f7713f7313c7313b700387003b70036700397003f70000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000800000c2700c270132000c2700c2700c2700c2700c270002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
00040000175401d5602057024570245700b5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00060000205701d570155700f5700f530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000276102365010670236700a670046300362003610036100560007600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
001000002867028640286202761000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000b7100d731167411c741257712d7512d71137701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701007010070100701
000600001c23024250192002124027260002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
000900001b3301d340153401531111300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00080000193701e370000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000073300b3510d361163611b3411b3210030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301
010800001534013331000000000001300013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000e3400c331000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001c37017300323703737028300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000393403d3603f370000003f3503f340000003f3303f320000003f3203f310000003f3103f3150000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002e6552e6052d645006052b635006052a62500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
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
00 02 07 43 05
00 03 07 43 05
00 02 07 43 05
00 04 07 43 05
00 02 07 43 05
00 03 07 43 05
00 04 07 43 05
02 06 07 43 05
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
