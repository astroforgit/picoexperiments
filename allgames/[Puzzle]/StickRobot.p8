pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--update
pal(4,0)
l_col =0
function _init()
now_playing =-1
message =false
move_title()
--move_game()
stage=1
move_angle = "no"
music_on =true
music_play(10)
stage_time = 0
game_clear =false
end

function move_game()
update_now =update_game
draw_now =draw_game
end

function _update()
update_now()
end

function update_game()

music_play(0)

 if stage_change then
  stage_set()
 end
--item_move()
if not goal_check() then
 if message == false then

 p_move()
 item_check_add()
 
 item_del()
 item_move()
 else
  show_message()
 end
end

 if goal_check() then
  goal_result()
 end

--[[
 if btnp() then
  --stage +=1
  goal_result()
 end
]]
--[[
if stage > 5 then
stage=1
end
]]
camera(map_x,map_y)

if stage >=22 then
game_clear =true
move_title()
end

end

function music_play(no)
 if music_on then
 if now_playing ~= no then
  music(no)
  now_playing =no
 end
 end
end
-->8
--draw
function _draw()
draw_now()
--print(stat(8),100,1,15)
end

function draw_game()

--rectfill(0,0,128,128,2)
map(map_x/8,map_y/8,map_x,map_y,16,16)
--map(0,0,0,0,128,128)

goal_draw()
item_draw()
p_draw()
stage_draw()

if message then
local xx =((stage-1)%8)*16*8
local yy =16*(flr((stage-1)/8))*8
rect(16+((stage-1)%8)*16*8,
32+16*(flr((stage-1)/8))*8,
112+((stage-1)%8)*16*8,
112+16*(flr((stage-1)/8))*8,4)
rect(17+((stage-1)%8)*16*8,
33+16*(flr((stage-1)/8))*8,
111+((stage-1)%8)*16*8,
111+16*(flr((stage-1)/8))*8,1)
rect(18+((stage-1)%8)*16*8,
34+16*(flr((stage-1)/8))*8,
110+((stage-1)%8)*16*8,
110+16*(flr((stage-1)/8))*8,4)
rectfill(19+((stage-1)%8)*16*8,
35+16*(flr((stage-1)/8))*8,
109+((stage-1)%8)*16*8,
109+16*(flr((stage-1)/8))*8,6)

printc("button  then",25+xx,40+yy,6,1)
printc("let go the boxes",25+xx,50+yy,6,1)
spr(10,65+xx,70+yy,2,2)
 if message_time %80 <= 30 then
  spr(39,49+xx,70+yy,2,2)
 else spr(37,49+xx,70+yy,2,2)
 end
else
end
--check
--[[
print("p.x:"..p.x,flr(p.x/128)*128,20,8)
print("p.y:"..p.y,flr(p.x/128)*128,26,8)
print("x_b:"..p.x_before,flr(p.x/128)*128,17+15,8)
print("y_b:"..p.y_before,flr(p.x/128)*128,25+13,8)
print(move_angle,flr(p.x/128)*128,33+12,8)
print(p.right,flr(p.x/128)*128,42+12,11)
print(p.left,flr(p.x/128)*128,50+12,11)
print(p.up,flr(p.x/128)*128,58+12,11)
print(p.down,flr(p.x/128)*128,64+12,11)
print(item_no,a+flr(p.x/128)*128,80+12,8)
for item in all(items) do
 print(item.catch,item.x,item.y,9)
  print(item.no,item.x,item.y+9,9)
ebd
]]end

function show_message()
 message_time +=1
 if message_time >= 80 then
 message_time =0 end
 if btn(‹) or btn(‘)
 or btn(ƒ) or btn(”)
 or btn(—) or btn() then
  message =false
 end
 
end

-->8
--player
p={}
p.x = 40
p.y = 40
p.x_before =1
p.y_before =1
p.w = 16
p.h = 16
p.catch ="not"
p.right =false
p.left =false
p.up =false
p.down =false
p.spd =4
tyousei = 0
--move_angle = "no"
move_stop = false
first =true
item_stop =false
p.spr = 0
tesuu = 0
snd_time=0

function p_move()
--p.x_before =p.x
--p.y_before =p.y
item_stop =false

 if move_angle =="no" then
  p.spr =0
  
  --[[if(snd_time >=30)then
  sfx(-1)
  snd_time = 0
  end]]
  
  snd_once1 =true
  snd_once2 =true
  
  p.x_before =p.x
  p.y_before =p.y
  for item in all(items) do
   if item.get ==true then
    item.catch =true
    if item.aim =="right" then
     p.right = true
     p.catch = "right"
    elseif item.aim =="left" then
     p.left = true
     p.catch = "left"
    elseif item.aim =="up" then
     p.up =true
     p.catch = "up"
    elseif item.aim =="down" then
     p.down =true
     p.catch = "down"
    end 
   end
  end
  
  if btnp(‘) then
   move_angle ="right"
   tesuu +=1
  elseif btnp(‹) then
   move_angle ="left"
   tesuu +=1
  elseif btnp(”) then
   move_angle ="up"
   tesuu +=1
  elseif btnp(ƒ) then
   move_angle ="down"
   tesuu +=1
  elseif btnp(—) then
   stage_change =true
  elseif btnp() and p.catch != "not" then
   item_leave()
   p.catch ="not"
   p.right =false
   p.left =false
   p.up =false
   p.down =false 
   --tesuu +=1
   sfx(15)
  end
  
  if collision_item(p.x,p.y,p.w,p.h,0,move_angle)
  or (p_go_no_catch() and
  (p.up and
   (collision_item(p.x_before,p.y_before-16,p.w,p.h,0,move_angle)
   or collision_item(p.x_before,p.y_before-16,p.w,p.h,1,move_angle)) )
  or (p.down and
   (collision_item(p.x_before,p.y_before+16,p.w,p.h,0,move_angle)
   or collision_item(p.x_before,p.y_before+16,p.w,p.h,1,move_angle)))
  or(p.right and
   (collision_item(p.x_before+16,p.y_before,p.w,p.h,0,move_angle)
   or collision_item(p.x_before+16,p.y_before,p.w,p.h,1,move_angle)))
  or(p.left and
   (collision_item(p.x_before-16,p.y_before,p.w,p.h,0,move_angle)
   or collision_item(p.x_before-16,p.y_before,p.w,p.h,1,move_angle)))
  )
  then
   move_angle = "no"
   tesuu -=1
  
  end
  
 else
 --move actually
 if snd_once1 then
 sfx(11)
 snd_once1 =false
 end
 
  if move_angle == "right" then
   p.x+=p.spd
   p.spr =2
  elseif move_angle =="left" then
   p.x-=p.spd
   p.spr =4
  elseif move_angle =="up" then
   p.y-=p.spd
   p.spr =6
  elseif move_angle =="down" then
   p.y+=p.spd
   p.spr =8
  end
 
 
 --item collision
  if p.catch != "not" and (
  (p.up and
   (collision_item(p.x_before,p.y_before-16,p.w,p.h,0,move_angle)
   or collision_item(p.x_before,p.y_before-16,p.w,p.h,1,move_angle)))
  or (p.down and
   (collision_item(p.x_before,p.y_before+16,p.w,p.h,0,move_angle)
   or collision_item(p.x_before,p.y_before+16,p.w,p.h,1,move_angle)))
  or(p.right and
   (collision_item(p.x_before+16,p.y_before,p.w,p.h,0,move_angle)
   or collision_item(p.x_before+16,p.y_before,p.w,p.h,1,move_angle)))
  or(p.left and
   (collision_item(p.x_before-16,p.y_before,p.w,p.h,0,move_angle)
   or collision_item(p.x_before-16,p.y_before,p.w,p.h,1,move_angle)))
  )
  then  
  item_stop =true
   
    if move_angle == "right" then
    if (p.x_before+8)%16 != 0 then
    p.x_before = flr((p.x_before - 8-tyousei)/16)*16 +8
    end
    p.x -= p.spd+p.spd*1.5
     if p.x_before > p.x then
      p.x = p.x_before     
     end
    end
    if move_angle == "left" then
    if (p.x_before+8)%16 != 0 then
    p.x_before = flr((p.x_before + 8+tyousei)/16)*16 +8
    end
    p.x += p.spd+p.spd*1.5
     if p.x_before < p.x then
      p.x = p.x_before
     end
    end
    if move_angle == "up" then
     if (p.y_before+8)%16 != 0 then
     p.y_before = flr((p.y_before + 8+tyousei)/16)*16 +8
     end
     p.y += p.spd+p.spd*1.5
     if p.y_before < p.y then
      p.y = p.y_before
     end
    end
    if move_angle == "down" then
    if (p.y_before+8)%16 != 0 then
     p.y_before = flr((p.y_before - 8-tyousei)/16)*16 +8
    end
     p.y -= p.spd+p.spd*1.5
     if p.y_before > p.y then
      p.y = p.y_before
     end
    end
   
  else
  --player collision
  if collision(p,0,move_angle)
  or item_check() 
  or (item_each_col() and p_go_no_catch())
  then
   --move stop
  if snd_once2 then
   sfx(-1)
   sfx(12)
   snd_once2 =false
  else
   snd_time+=1 
  end
   if move_angle == "right" then
    p.x = flr((p.x - 8)/16)*16 +8
    p.x_before += p.spd+2
    
     if p.x_before > p.x then
      p.x_before = p.x
     end
   elseif move_angle =="left" then
    p.x = flr((p.x + 8)/16)*16 +8
    p.x_before -= p.spd+2
    
     if p.x_before < p.x then
      p.x_before = p.x
     end
   elseif move_angle =="up" then
    p.y = flr((p.y + 8)/16)*16 +8
    p.y_before -= p.spd+2
    
     if p.y_before < p.y then
      p.y_before = p.y
     end
   elseif move_angle =="down" then
    p.y = flr((p.y - 8)/16)*16 +8
    p.y_before += p.spd+2
   
     if p.y_before > p.y then
      p.y_before = p.y
     end
   end
   
   
   end  

  end
  if p.x == p.x_before and
   p.y == p.y_before then
   
    move_angle ="no"
   end
--  if flr((p.x - 8)/16)
 end



end

function p_draw()
spr(p.spr,p.x_before,p.y_before,2,2)

--print(a,flr(p.x/128)*128,100+12,9)
--print(collision2(p.x_before,p.y_before-16,p.w,p.h,move_angle),100,50,12)

--[[print("r:"..(collision(p,0,"right") and "true" or "false"),100,16,8)
print("l:"..(collision(p,0,"left") and "true" or "false"),100,25,8)
print("u:"..(collision(p,0,"up") and "true" or "false"),100,34,8)
print("d:"..(collision(p,0,"down") and "true" or "false"),100,43,8)
]]
--p.x and p.x_beforecheck]]

--line(p.x_before,p.y_before,p.x,p.y,9)

if move_angle =="left" then
 line(p.x,p.y+2,p.x,p.y+p.h-3,l_col)
 line(p.x+1,p.y+4,p.x+1,p.y+p.h-5,l_col)
 rectfill(p.x,p.y+7,p.x_before+2,p.y_before+8,l_col)
else
 line(p.x_before,p.y_before+2,p.x_before,p.y_before+p.h-3,l_col)
 line(p.x_before+1,p.y_before+4,p.x_before+1,p.y_before+p.h-5,l_col)
 rectfill(p.x_before,p.y_before+7,p.x_before+2,p.y_before+8,l_col)
end

if move_angle =="right" then
 line(p.x+p.w-1,p.y+2,p.x+p.w-1,p.y+p.h-3,l_col)
 line(p.x+p.w-2,p.y+4,p.x+p.w-2,p.y+p.h-5,l_col)
 rectfill(p.x+p.w-1,p.y+7,p.x_before+p.w-3,p.y_before+8,l_col)
else
 line(p.x_before+p.w-1,p.y_before+2,p.x_before+p.w-1,p.y_before+p.h-3,l_col)
 line(p.x_before+p.w-2,p.y_before+4,p.x_before+p.w-2,p.y_before+p.h-5,l_col)
 rectfill(p.x_before+p.w-1,p.y_before+7,p.x_before+p.w-3,p.y_before+8,l_col)
end

if move_angle =="up" then
 line(p.x+2,p.y,p.x+p.w-3,p.y,l_col)
 line(p.x+4,p.y+1,p.x+p.w-5,p.y+1,l_col)
 rectfill(p.x+7,p.y,p.x_before+8,p.y_before+2,l_col)
else
 line(p.x_before+2,p.y_before,p.x_before+p.w-3,p.y_before,l_col)
 line(p.x_before+4,p.y_before+1,p.x_before+p.w-5,p.y_before+1,l_col)
 rectfill(p.x_before+7,p.y_before,p.x_before+8,p.y_before+2,l_col)
end

if move_angle =="down" then
 line(p.x+2,p.y+p.h-1,p.x+p.w-3,p.y+p.h-1,l_col)
 line(p.x+4,p.y+p.h-2,p.x+p.w-5,p.y+p.h-2,l_col)
 rectfill(p.x+7,p.y+p.h-1,p.x_before+8,p.y_before+p.h-3,l_col)
else
 line(p.x_before+2,p.y_before+p.h-1,p.x_before+p.w-3,p.y_before+p.h-1,l_col)
 line(p.x_before+4,p.y_before+p.h-2,p.x_before+p.w-5,p.y_before+p.h-2,l_col)
 rectfill(p.x_before+7,p.y_before+p.h-1,p.x_before+8,p.y_before+p.h-3,l_col)
end

end


-->8
--collision
function get_map_flag(x,y,z)
 local celx = flr(x/8)
 local cely = flr(y/8)
 local celc = mget(celx,cely)
 return fget(celc,z)
end

function collision(obj,tag,angle)
 --obj = hairetu
local x =obj.x local y =obj.y
local w =obj.w local h =obj.h

if angle =="right" then
 if get_map_flag(x+w-1,y,tag) or
    get_map_flag(x+w-1,y+h-1,tag)
 then return true
 else return false
 end
elseif angle =="left" then
 if get_map_flag(x,y,tag) or
    get_map_flag(x,y+h-1,tag)
 then return true
 else return false
 end
elseif angle =="up" then
 if get_map_flag(x,y,tag) or
    get_map_flag(x+w-1,y,tag)
 then return true
 else return false
 end
elseif angle =="down" then
 if get_map_flag(x,y+h-1,tag) or
    get_map_flag(x+w-1,y+h-1,tag)
 then return true
 else return false
 end
end

end

function collision_item(x,y,w,h,tag,angle)

if angle =="right" then
 if get_map_flag(x+w,y,tag) or
    get_map_flag(x+w,y+h-1,tag)
 then return true
 else return false
 end
elseif angle =="left" then
 if get_map_flag(x-1,y,tag) or
    get_map_flag(x-1,y+h-1,tag)
 then return true
 else return false
 end
elseif angle =="up" then
 if get_map_flag(x,y-1,tag) or
    get_map_flag(x+w-1,y-1,tag)
 then return true
 else return false
 end
elseif angle =="down" then
 if get_map_flag(x,y+h,tag) or
    get_map_flag(x+w-1,y+h,tag)
 then return true
 else return false
 end
end

end

function p_go_no_catch() 
  if move_angle == "right" then
   if p.right then
    return true
   end
  elseif move_angle =="left" then
   if p.left then
    return true
   end
  elseif move_angle =="up" then
   if p.up then
    return true
   end
  elseif move_angle =="down" then
   if p.down then
    return true
   end
  end
  return false
end
-->8
--goal
goal={}
--goal.stage = 1
--goal.goal = false
goal_x =0
goal_y =0
goal_time =0

function goal_check()

 if move_angle =="no" and
    goal_x == p.x and
    goal_y == p.y then
  
  return true
  
 else
  return false
 end
 
end

function goal_result()
 if goal_time ==5 then
 sfx(13)
 end
 
 if goal_time %12 <6 then
 p.spr =12
 else
 p.spr =14
 end
  
 if goal_time>36
 then
 stage_change =true
 stage += 1
 goal_time =0
 end
 goal_time +=1
end



function goal_draw()
--if flr(stage_time/30) = 0 then
-- spr(72+2*flr(stage_time/20),goal_x,goal_y,2,2)
spr(34,goal_x,goal_y,2,2)
end
-->8
--stage
map_x =0
map_y =0
stage_change =true

function stage_set()
p.catch ="not"
p.right =false
p.left =false
p.up =false
p.down =false


tesuu = 0
map_x =((stage-1)%8)*16*8
map_y =16*(flr((stage-1)/8))*8

item_no =0
for item in all(items) do
 mset(flr(item.x/8),flr(item.y/8),32)
   mset(flr(item.x/8)+1,flr(item.y/8),33)
   mset(flr(item.x/8),flr(item.y/8)+1,48)
   mset(flr(item.x/8)+1,flr(item.y/8)+1,49)

 del(items,item)
end

--stage =3
if stage ==1 then
p.x = 4
p.y = 3

goal_x = 1
goal_y = 1
elseif stage ==2 then
p.x = 4
p.y = 3

goal_x = 4
goal_y = 4
elseif stage ==3 then
p.x = 4
p.y = 3

goal_x = 2
goal_y = 2

make_item(1,4,6)
elseif stage ==4 then
p.x = 4
p.y = 3

goal_x = 4
goal_y = 4

make_item(1,1,5)
elseif stage ==5 then
p.x = 4
p.y = 3

goal_x = 6
goal_y = 3

make_item(1,7,2)
elseif stage ==6 then
p.x = 4
p.y = 3

goal_x = 4
goal_y = 2

make_item(1,4,5)
elseif stage ==7 then
p.x = 4
p.y = 3

goal_x = 5
goal_y = 3

make_item(1,6,1)
make_item(2,3,2)
elseif stage ==8 then
p.x = 4
p.y = 3

goal_x = 2
goal_y = 4

make_item(1,4,2)
make_item(2,4,4)
make_item(3,3,3)
make_item(4,5,3)
elseif stage ==9 then
p.x = 4
p.y = 3

goal_x = 2
goal_y = 3

make_item(1,1,5)
message = true
message_time =0
elseif stage ==10 then
p.x = 4
p.y = 3

goal_x = 5
goal_y = 2

make_item(1,6,1)
elseif stage ==11 then
p.x = 4
p.y = 3

goal_x = 4
goal_y = 4


make_item(1,7,3)
elseif stage ==12 then
p.x = 4
p.y = 3

goal_x = 1
goal_y = 1

make_item(1,1,6)
elseif stage ==13 then
p.x = 4
p.y = 3

goal_x = 4
goal_y = 4

make_item(1,1,4)
make_item(2,7,5)
elseif stage ==14 then
p.x = 4
p.y = 3

goal_x = 2
goal_y = 6

make_item(1,1,1)
make_item(2,6,6)

elseif stage ==15 then
p.x = 4
p.y = 3

goal_x = 5
goal_y = 3

make_item(1,1,4)
make_item(2,7,5)
make_item(3,3,1)
elseif stage ==16 then
p.x = 4
p.y = 3

goal_x = 5
goal_y = 6

make_item(1,4,1)
make_item(2,3,6)
make_item(3,7,5)
elseif stage ==17 then
p.x = 4
p.y = 3

goal_x = 2
goal_y = 3

make_item(1,1,1)
make_item(2,3,3)
make_item(3,7,6)

elseif stage ==18 then
p.x = 4
p.y = 3

goal_x = 5
goal_y = 5

make_item(1,3,3)
make_item(2,4,2)
make_item(3,4,4)
make_item(3,5,3)


elseif stage ==19 then
p.x = 4
p.y = 3

goal_x = 4
goal_y = 4

make_item(1,1,1)
make_item(2,7,6)
make_item(3,7,1)
make_item(4,1,6)
elseif stage ==20 then
p.x = 4
p.y = 3

goal_x = 4
goal_y = 2

make_item(1,1,5)
make_item(2,7,5)
elseif stage ==21 then
p.x = 4
p.y = 3

goal_x = 7
goal_y = 4

make_item(1,1,4)
elseif stage >=22 then
game_clear =true
move_title()

end

p.x =p.x*16-8+((stage-1)%8)*16*8
p.y =p.y*16+8+16*(flr((stage-1)/8))*8
goal_x =goal_x*16-8+((stage-1)%8)*16*8
goal_y =goal_y*16-8+16*(flr((stage-1)/8))*8+16


--item_set(stage)
 
stage_change =false

end

function stage_draw()
--rectfill(0,0,120+((stage-1)%8)*16*8,16+16*(flr((stage-1)/8))*8,1)
print("turn:"..tesuu,55+((stage-1)%8)*16*8,5+16*(flr((stage-1)/8))*8,6+16*(flr((stage-1)/8))*8)
print("stage "..stage,7+((stage-1)%8)*16*8,5+16*(flr((stage-1)/8))*8,6+16*(flr((stage-1)/8))*8)

rect(88+((stage-1)%8)*16*8,0+16*(flr((stage-1)/8))*8,128+((stage-1)%8)*16*8,16+16*(flr((stage-1)/8))*8,4)
rect(89+((stage-1)%8)*16*8,1+16*(flr((stage-1)/8))*8,127+((stage-1)%8)*16*8,15+16*(flr((stage-1)/8))*8,1)
rectfill(90+((stage-1)%8)*16*8,2+16*(flr((stage-1)/8))*8,126+((stage-1)%8)*16*8,14+16*(flr((stage-1)/8))*8,13)

printc("restart",94+((stage-1)%8)*16*8,3+16*(flr((stage-1)/8))*8,6,4)
printc("— or x",94+((stage-1)%8)*16*8,9+16*(flr((stage-1)/8))*8,6,4)

end
-->8
--item
items ={}
a=0
function item_leave()

for item in all(items) do

 if item.catch == true then
 mset(flr(item.x/8),flr(item.y/8),37)
 mset(flr(item.x/8)+1,flr(item.y/8),38)
 mset(flr(item.x/8),flr(item.y/8)+1,53)
 mset(flr(item.x/8)+1,flr(item.y/8)+1,54)
  item.get =false
  item.catch = false
  item.change = false
  item.aim ="no"
  item.sprite=37
 --[[
 local numy= item.no
 local xx =item.x--2*16-8+((stage-1)%8)*16*8 
 local yy =item.y--2*16+8+16*(flr((stage-1)/8))*8
 
 if item.no == numy then
  del(items,item)
 end
 ]]
 
 --make_item(numy,xx,yy)
 
 else
 -- rectfill(item.x,item.y,item.x+4,item.y+4,8)
 --item.x =item.no*16-8+((stage-1)%8)*16*8 
 --item.y =6*16+8+16*(flr((stage-1)/8))*8
 end
 
end

 
end

function make_item(num,xx,yy)
if tesuu ==0 then
xx =xx*16-8+((stage-1)%8)*16*8  
yy =yy*16+8+16*(flr((stage-1)/8))*8
end

item_no =item_no+1

items[item_no]={
  no =item_no,
  x =xx,
  y =yy,
  w=16,
  h=16,
  get =false,
  catch = false,
  change = false,
  aim ="no",
  sprite=37,
  }
  
  mset(flr(xx/8),flr(yy/8),37)
  mset(flr(xx/8)+1,flr(yy/8),38)
  mset(flr(xx/8),flr(yy/8)+1,53)
  mset(flr(xx/8)+1,flr(yy/8)+1,54)
  
end

function item_check()
 for item in all(items) do
 if item.catch==false 
 then
  if(abs(p.y -item.y) <16 
  and abs(p.x -item.x) <16) then
   item.get =true
  --[[ mset(flr(item.x/8),flr(item.y/8),32)
   mset(flr(item.x/8)+1,flr(item.y/8),33)
   mset(flr(item.x/8),flr(item.y/8)+1,48)
   mset(flr(item.x/8)+1,flr(item.y/8)+1,49)]]
    if item.y ==p.y_before then
     if item.x >= p.x_before then
      item.aim ="right"
     else
      item.aim ="left"
     end
    elseif item.x == p.x_before then 
     if item.y >= p.y_before then
       item.aim ="down"
     else
      item.aim ="up"
     end
    end
    
    
   return true
  end 
 elseif item.catch==true then
  if collision_item(item.x,item.y,item.w,item.h,0,move_angle) then
   return true
  end
 end
 end
 return false
end

function item_move()
 for item in all(items) do
 
  if item.get then
   if item.aim == "right" then
    item.x =p.x+16  
    item.y =p.y
   elseif item.aim == "left" then
    item.x =p.x-16 
    item.y =p.y
   elseif item.aim == "up" then
    item.x = p.x
    item.y =p.y-16
   elseif item.aim == "down" then
    item.x =p.x 
    item.y = p.y+16
   end
  end 
 
  if item.catch then
   if item.aim == "right" then
    item.x =p.x_before+16  
    item.y =p.y_before
   elseif item.aim == "left" then
    item.x =p.x_before-16 
    item.y =p.y_before
   elseif item.aim == "up" then
    item.x = p.x_before
    item.y =p.y_before-16
   elseif item.aim == "down" then
    item.x =p.x_before 
    item.y = p.y_before+16
   end
  if item.aim == move_angle then
   if item.aim == "right" then
    item.x =p.x+16  
    item.y =p.y
   elseif item.aim == "left" then
    item.x =p.x-16 
    item.y =p.y
   elseif item.aim == "up" then
    item.x = p.x
    item.y =p.y-16
   elseif item.aim == "down" then
   item.x = p.x
    item.y =p.y+16
   end
  end
   
  end
 end
end
 
function item_check_add()
 for item in all(items)do
 if item.get ==false
 then
  if item.x == p.x_before then
   if p.y_before-item.y ==-16 and
      (move_angle == "down" 
      or( move_angle == "no" and
      btnp(ƒ))) 
      then 
    if move_angle == "no"
    then tesuu +=1 end
    item.get =true
    item.aim ="down"
   
   elseif p.y_before-item.y ==16 and
      (move_angle == "up" 
      or (move_angle == "no" and
      btnp(”))) 
      then 
    if move_angle == "no"
    then tesuu +=1 end    
    item.get =true
    item.aim ="up"
   end
  elseif item.y == p.y_before then
   if p.x_before-item.x ==16 and
      (move_angle == "left" 
      or (move_angle == "no" and
      btnp(‹))) 
      then 
    if move_angle == "no"
    then tesuu +=1 end     
    item.get =true
    item.aim ="left"
   elseif p.x_before-item.x ==-16 and
      (move_angle == "right" 
      or (move_angle == "no" and
      btnp(‘))) 
      then 
    if move_angle == "no"
    then tesuu +=1 end
         
    item.get =true
    item.aim ="right"
   end
   
  end 
 end
 end
end

function item_each_col()
local no local x
local y  local w local h
for item in all(items) do
  no = item.no
  x =item.x
  y =item.y
  w =item.w
  h =item.h
 if item.catch
    and (collision_item(item.x,item.y,item.w,item.h,1,move_angle)
    )
  then
 
  return true
  
 end
end
return false
end

function item_del()
 for item in all(items) do
 
 if item.get and item.change ==false then
   item.change =true
   sfx(14)
   mset(flr(item.x/8),flr(item.y/8),32)
   mset(flr(item.x/8)+1,flr(item.y/8),33)
   mset(flr(item.x/8),flr(item.y/8)+1,48)
   mset(flr(item.x/8)+1,flr(item.y/8)+1,49)
 end
 end
end


function item_draw()
 for item in all(items) do
  if item.get then
   item.sprite =39
  else item.sprite =37
  end
  
   
  spr(item.sprite,item.x,item.y,2,2)
   --[[
  print(item.x,item.x,item.y,9)
  print(item.x,item.x+9,item.y,9)
  --print(p.y -item.y ,item.x,item.y+9,9)
  print(item.get,item.x,item.y+9,9)
  print(item.catch,item.x,item.y+18,9)
  --print(collision(item,0,move_angle),1,item.y+9,9)
]]
 end
end
-->8
--title
title_time = 0
block = false
title_tenmetu = 0
go_game =false

function move_title()

title_tenmetu = 0
move_angle = "no"
music_on =true
music_play(10)
stage_time = 0
go_game =false
map(0,0,0,0,0,0)
camera(0,0)


update_now =update_title
draw_now =draw_title
end

function update_title()
title_time += 0.8

if btnp(—) then
go_game=true
elseif btnp(‹) and stage > 1 then
stage-=1
sfx(16)
elseif btnp(‘) and stage <20 then
sfx(16)
stage+=1
elseif btnp()then
 if music_on then
  music_on =false
  music(-1)
 else music_on =true
  music(10)
 end
end

if stage < 1 then
stage =1
elseif stage >20 then
stage =20
end

if go_game then
title_tenmetu +=1
 if title_tenmetu >30 then
  move_game()
  title_tenmetu = 0
 end
end

end

function draw_title()
rectfill(0,0,128,128,6)
local a
local rand
local rand2
rand=(rnd(2))

for a=-1,9 do
 for b =-1,9 do
 
 spr(32,a*16+title_time%16,b*16-title_time%16,2,2)

end
end

if title_time ==1 and 
(rand >= 1 or block ==true) then

  spr(45,-16+title_time,160-title_time,2,2)
  spr(45,-16+title_time,176-title_time,2,2)
  spr(45,-32+title_time,176-title_time,2,2)

block = true
end

 if title_time >=160
 then title_time =0
 block = false
 end

--title logo
line(29,19,29,20+8*4+1,4)
line(30,19,30+8*8+1,19,4)
rectfill(30,20,30+8*8+1,20+8*4+1,1)
line(30+8*8+1,19,30+8*8+1,20+8*4+1,4)
line(30,20+8*4+1,30+8*8+1,20+8*4+1,4)
spr(64,30,20,8,4)
--print(title_time,1,1,8)
--print(rand,1,9,8)
if title_time%16 >=8 then
printc("‹ stage "..stage,38,77,13,4)
printc("‘",86,77,13,4 )
else
printc("‹ stage "..stage,38,77,6,1)
printc("‘",86,77,6,1 )
end
if title_tenmetu %4 ==0 then
printc("- press — or x to start -",11,90,13,1)
end

printc("    2020 hiko_game",23,119,13,1)
if music_on then 
print(" or z to stop music",23,110,1)
end

if game_clear then
rectfill(17,63,111,71,13)
printc("thank you for playing!!",19,65,4,6)
end

end

function printc(moji,x,y,col1,col2)
local a =0

for a =0,1 do
print(moji,x+1-a*2,y,col2)
print(moji,x,y+1-a*2,col2)
end

print(moji,x,y,col1)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000004444444444440000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000044444444000000000000000000000000000000000000
00000004400000000000000440000000000000044000000000000004400000000000000440000000000000044000000400000004400000000000000440000000
00004444444400000000444444440000000044444444000000004444444400000000444444440000400044444444000400004444444400000000444444440000
0004ddd66ddd40000004dddd66dd40000004dd666ddd40000004d666666d40000004dddddddd40004004ddd66ddd40440004dd6666dd40000004dd6666dd4000
0004d666666d40000004dd66666640000004666666dd40000004d646646d40000004ddd66ddd40004404d666666d40440004d666666d40000004d666666d4000
0004d646646d40000004dd64664640000004646646dd400000046646646640000004d666666d40004404d646646d404400046466664640000004646666464000
00446646646644000044d6646646440000446466466d440000446666666644000044664664664400444466466466444400444646646444000044464664644400
00446666666644000044d6666666440000446666666d440000446664466644000044664664664400444466666666444400446666666644000044666666664400
0004d644446d40000004dd66446640000004664466dd40000004d646646d400000046666666640004444d644446d404400046646646640000004664444664000
0004d666666d40000004dd64664640000004646646dd40000004ddd66ddd40000004d664466d40004404d666666d40440004d664466d40000004d644446d4000
0004ddd66ddd40000004dddd66dd40000004dd666ddd40000004dddddddd40000004d646646d40004404ddd66ddd40440004dd6666dd40000004dd6666dd4000
00004444444400000000444444440000000044444444000000004444444400000000444444440000400044444444000400004444444400000000444444440000
00000004400000000000000440000000000000044000000000000004400000000000000440000000400000044000000400000004400000000000000440000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000004444444000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000444444444440000000000000000000000000000000000
ddddddddddddddddddddd444444ddddd000000004444444444444444444444444444444444444444444444444444444446ddd144444444444444444400000000
d66666666666666dd66441111114466d0000000046dddddddddddd64461111111111116446666666666666644444444446ddd1444dddddddddddddd400000000
d66666666666666dd64116666661146d000000004d666666666666d4416666666666661446dddddddddddd641111111146ddd1444dd1111111111dd400000000
d66666666666666dd41166666666114d000000004d666644446666d4416666444466661446dddddddddddd64dddddddd46ddd1444d1d11111111d1d400000000
d66666666666666dd41611661111614d000000004d6644dddd4466d4416644111144661446dddddddddddd64dddddddd46ddd1444d11d111111d11d400000000
d66666666666666d4161666616616614000000004d664dd6ddd466d4416641161114661446ddd111111ddd64dddddddd46ddd1444d111d1111d111d400000000
d66666666666666d4161661616616614000000004d64dd6ddddd46d4416411611111461446ddd144441ddd646666666646ddd1444d1111d11d1111d400000000
d66666666666666d4166111611116614000000004d64d6dddddd46d4416416111111461446ddd144441ddd644444444446ddd1444d11111dd11111d400000000
d66666666666666d4166666661666614000000004d64dddddddd46d4416411111111461446ddd144441ddd6444444444441ddd644d11111dd11111d400000000
d66666666666666d4166111161666614000000004d64dddddddd46d4416411111111461446ddd144441ddd6466666666441ddd644d1111d11d1111d400000000
d66666666666666d4166166161666614000000004d664dddddd466d4416641111114661446ddd111111ddd64dddddddd441ddd644d111d1111d111d400000000
d66666666666666dd41611116111614d000000004d6644dddd4466d4416644111144661446dddddddddddd64dddddddd441ddd644d11d111111d11d400000000
d66666666666666dd41116616666114d000000004d666644446666d4416666444466661446dddddddddddd64dddddddd441ddd644d1d11111111d1d400000000
d66666666666666dd64116666661146d000000004d666666666666d4416666666666661446dddddddddddd6411111111441ddd644dd1111111111dd400000000
d66666666666666dd66441111114466d0000000046dddddddddddd644611111111111164466666666666666444444444441ddd644dddddddddddddd400000000
ddddddddddddddddddddd444444ddddd0000000044444444444444444444444444444444444444444444444444444444441ddd64444444444444444400000000
666666dddddddd6666dddddddddddd6666666666dddddd66666ddd6666666666ddddd444444dddddddddd444444dddddddddd444444dddddddddd444444ddddd
6666dddddddddddd66dddddddddddd16666666dddddddddd6666dd1666666666d66441111114466dd66441111114466dd66441111114466dd66441111114466d
666dddd111111dddd66111144111111ddd666dddddddddddd666dd1666666666d64116666661146dd64116666661146dd64116666661146dd64116666661146d
666dd1166666611dd16666644166666ddd166ddddd11ddddd166dd1666666666d41166666666114dd41166666666114dd41166666666114dd41166666666114d
666dd1166666666dd16666644166666ddd16dddd111111ddd166dd1666dd6666d41666111166d14dd41d66111166d14dd41d6661166dd14dd41d61116666d14d
666dd1666666666111666664416666661116dddd116661111166dd166ddd166641d66111111ddd1441ddd1111116d614416dd611116dd614416d6111666dd614
666dddd666666666666666644166666ddd66ddd1166666666666dd16ddd1166641d66116666dd61441666116611dd614416dd116611dd614416dd111666dd614
6666ddddddddddd6666666644166666ddd16ddd1166666666666dd1ddd11666641d66116666dd61441666116611ddd14416dd116611dd61441ddd111666dd614
66666ddddddddddd666666644166666ddd16ddd1166666666666ddddd116666641d66116111dd61441ddd116611ddd14416dd111111dd61441ddd111666dd614
6666661111111dddd66666644166666ddd16dddd166666ddd666dddd1166666641d66116611dd614416dd116611dd614416dd111111dd614416dd111666dd614
666666666666611dd16666644166666ddd16dddd116666ddd166dddd1666666641ddd111111ddd1441ddd111111dd614416dd116611ddd14416dd111111dd614
666dd6666666666dd16044444444066ddd166ddddd16ddddd166ddddd6666666d41dd6111166d14dd41d6611116dd14dd41d6116611dd14dd41dd1111116d14d
666dddd666666dddd164ddd66ddd466ddd166dddddddddddd166dd1ddd666666d41166666666114dd41166666666114dd41166666666114dd41166666666114d
4661dddddddddddd1164d666666d466ddd1666dddddddddd1166dd11ddd16664d64116666661146dd64116666661146dd64116666661146dd64116666661146d
466611dddddddd111664d646646d466ddd166666dddddd111666dd166dd16664d66441111114466dd66441111114466dd66441111114466dd66441111114466d
4444444444444444444466466466444444444444444444444444444444444444ddddd444444dddddddddd444444dddddddddd444444dddddddddd444444ddddd
444444444444444444446666666644444444444444444444444444444444444444444444004441dd444444444444444441dddd1441dddd144444444446ddd144
4ddddddddd66666dddd4d644446d4dddd66666666dddddd6666dddddddddddd41111111104441ddd411111111111111441dddd1111dddd144111111446ddd111
4ddd111dddd166ddddd4d666666d4ddddd66666dddddddddd6661111dd111114dddddddd4441ddd141dddddddddddd1441dddddddddddd1441dddd1446dddddd
6ddd1111ddd166dd1114ddd66ddd411ddd1666dddddddddddd666666dd166666dddddddd441ddd1441dddddddddddd1441dddddddddddd1441dddd1446dddddd
6ddd1666ddd16ddd166044444444061ddd1666ddddd11ddddd666666dd166666dddddddd41ddd14441dddddddddddd1441dddddddddddd1441dddd1446dddddd
6ddd166dddd16dd1166ddd144166666ddd166dddd111111dddd66666dd166666dddddddd1ddd144441dddddddddddd1441dddddddddddd1441dddd1446dddddd
6ddddddddd116dd16666dd14416666ddd1166dddd111666dddd16666dd16666611111111ddd1444041dddd1111dddd1441dddd1111dddd1441dddd1446ddd111
6dddddddd1166dd16666dd144ddddddd11166ddd11166666ddd16666dd16666644444444dd14440041dddd1441dddd1441dddd1441dddd1441dddd1446ddd144
6ddd166ddd666dd16666dd144dddddd111666ddd11166666ddd16666dd16666641dddd14dd14440041dddd1441dddd144444444441dddd1441dddd14441ddd64
6ddd166ddd666dd16666dd144dddddddd6666ddd11166666ddd16666dd16666641dddd14ddd1444041dddd1111dddd141111111111dddd1141dddd14111ddd64
6ddd166dddd66dd16666dd14411111dddd666dddd116666dddd16666dd16666641dddd141ddd144441dddddddddddd14dddddddddddddddd41dddd14dddddd64
6ddd1666ddd16dd1166ddd144166611ddd166dddd111666dddd16666dd16666641dddd1441ddd14441dddddddddddd14dddddddddddddddd41dddd14dddddd64
6ddd1666dddd66dd166ddd144166661ddd1666ddddd11ddddd116666dd16666641dddd14441ddd1441dddddddddddd14dddddddddddddddd41dddd14dddddd64
6ddd16666ddd16dd116dd114416666dddd1666dddddddddddd116666dd16666641dddd144441ddd141dddddddddddd14dddddddddddddddd41dddd14dddddd64
6ddd16666ddd16ddddddd1644dddddddd116666dddddddddd1166666dd16666641dddd1404441ddd411111111111111411dddd1111dddd1141111114111ddd64
6ddd666666dd166ddddd1444444ddddd116666666dddddd111666666dd16666641dddd14004441dd444444444444444441dddd1441dddd1444444444441ddd64
92b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a20000000000
92b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a20000000000
93b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a30000000000
93b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a30000000000
92b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a2
92b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a2
c2526202120212021202120212d2e2c3c2d2e202120212021202120212d2e2c3c25262021202120212021202125262c3c20212021202120212021202120212c3
c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c2536303130313031303130313d3e3c3c2d3e303130313031303130313d3e3c3c25363031303130313031303135363c3c20313031303130313031303130313c3
f686c786b603a68686b61303e60313c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c2d2e2d2e2d2e2021202120212d2e2c3c202120212d2e25262d2e202120212c3c20212021202120212021202120212c3c20212021202122232021202120212c3
c20287028702870212c6b60287a686f7c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c2d3e3d3e3d3e3031303130313d3e3c3c203130313d3e35363d3e303130313c3c20313031303130313031303130313c3c20313031303132333031303130313c3
c2038703c686d78686d6a7b6c6b713c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c2d2e2223252620212021202120212c3c20212021252620212526202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c202870287028702128712a7d786b6c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c2d3e3233353630313031303130313c3c20313031353630313536303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c203e703e703e70313e71303e703a7f7c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c2d2e2d2e2d2e2021202120212d2e2c3c202120212d2e25262d2e202120212c3c20212021202122232021202120212c3c20212021202120212021202120212c3
c25262021202120212021202122232c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c2d3e3d3e3d3e3031303130313d3e3c3c203130313d3e35363d3e303130313c3c20313031303132333031303130313c3c20313031303130313031303130313c3
c25363031303130313031303132333c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c2d2e2d2e2d2e2021202120212d2e2c3c20212021202120212223202120212c3c20212021202120212021202120212c3c25262021202120212021202125262c3
f6b61202a686c78686c7b602a68686f7c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c2d3e3d3e3d3e3031303130313d3e3c3c20313031303130313233303130313c3c20313031303130313031303130313c3c25363031303130313031303135363c3
c2a786c7b703870313878703870313c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c2d2e2d2e2d2e20212021202125262c3c20212021202120212021202120212c3c25262021202120212021202125262c3c20212021202120212021202120212c3
c2021287120287021287870287d2e2c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c2d3e3d3e3d3e30313031303135363c3c20313031303130313031303130313c3c25363031303130313031303135363c3c20313031303130313031303130313c3
c20313e71303a78686b7a786b7d3e3c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
93b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a3
93b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a3
92b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a20000000000
92b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a2000000000092b3b3b3b3a292b3b3b3a20000000000
93b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a30000000000
93b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a3000000000093b2b2b2b2a393b2b2b2a30000000000
92b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a2
92b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a292b3b3b3b3b3b3b3b3b3b3b3b3b3b3a2
c20212021202120212021202120212c3c2d2e202120212021202120212d2e2c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20313031303130313031303130313c3c2d3e303130313031303130313d3e3c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20212021202120212021202120212c3c202120212d2e25262d2e202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20313031303130313031303130313c3c203130313d3e35363d3e303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20212021202120212021202120212c3c20212021252620212526202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20313031303130313031303130313c3c20313031353630313536303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20212021202120212021202120212c3c202120212d2e25262d2e202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20313031303130313031303130313c3c203130313d3e35363d3e303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20212021202120212021202120212c3c20212021202120212223202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20313031303130313031303130313c3c20313031303130313233303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3c20212021202120212021202120212c3
c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3c20313031303130313031303130313c3
93b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a3
93b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a393b2b2b2b2b2b2b2b2b2b2b2b2b2b2a3
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000102020202010101010101000000000001020202020101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101010100000000000000000101010101010101
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000
392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000
293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a
2c2021202120212d2e202120212d2e3c2c2021202120212d2e2021202120213c2c202120212d2e2d2e202120212d2e3c2c2d2e2d2e2d2e20212d2e2d2e2d2e3c2c202120212d2e2d2e2d2e20212d2e3c2c202120212d2e20212021202120213c2c2021202120212021202125262d2e3c2c202120212d2e2d2e2d2e2d2e20213c
2c3031303130313d3e303130313d3e3c2c3031303130313d3e3031303130313c2c303130313d3e3d3e303130313d3e3c2c3d3e3d3e3d3e30313d3e3d3e3d3e3c2c303130313d3e3d3e3d3e30313d3e3c2c303130313d3e30313031303130313c2c3031303130313031303135363d3e3c2c303130313d3e3d3e3d3e3d3e30313c
2c20212021202120212021202120213c2c20212021202120212021202120213c2c20212223202120212021202120213c2c2d2e202120212021202120212d2e3c2c20212021202120212021202125263c2c202120212d2e22232021202120213c2c2021202125262d2e202120212d2e3c2c202120212d2e252620212d2e20213c
2c30313031303130313031303130313c2c30313031303130313031303130313c2c30313233303130313031303130313c2c3d3e303130313031303130313d3e3c2c30313031303130313031303135363c2c303130313d3e32333031303130313c2c3031303135363d3e303130313d3e3c2c303130313d3e353630313d3e30313c
2c20212021202120212021202120213c2c2d2e20212d2e2021202120212d2e3c2c2d2e2021202120212021202120213c2c2d2e20212d2e20212d2e202120213c2c20212021202120212021222320213c2c20212021202120212021202120213c2c20212021202120212223202120213c2c20212021252620212526202120213c
2c30313031303130313031303130313c2c3d3e30313d3e3031303130313d3e3c2c3d3e3031303130313031303130313c2c3d3e30313d3e30313d3e303130313c2c30313031303130313031323330313c2c30313031303130313031303130313c2c30313031303130313233303130313c2c30313031353630313536303130313c
2c2d2e2021202120212021202120213c2c202120212d2e20212021202120213c2c2d2e2021202120212021202120213c2c2d2e2021202122232021202120213c2c2d2e20212d2e20212021202120213c2c20212021202120212021202120213c2c20212d2e202120212021202120213c2c20212223202125262021202120213c
2c3d3e3031303130313031303130313c2c303130313d3e30313031303130313c2c3d3e3031303130313031303130313c2c3d3e3031303132333031303130313c2c3d3e30313d3e30313031303130313c2c30313031303130313031303130313c2c30313d3e303130313031303130313c2c30313233303135363031303130313c
2c20212021202120212021202120213c2c20212021202120212021202120213c2c20212021202120212021202120213c2c2526202120212021202120212d2e3c2c20212021202120212021202120213c2c20212021202125262021202120213c2c202120212021202120212d2e2d2e3c2c20212021202120212021202120213c
2c30313031303130313031303130313c2c30313031303130313031303130313c2c30313031303130313031303130313c2c3536303130313031303130313d3e3c2c30313031303130313031303130313c2c30313031303135363031303130313c2c303130313031303130313d3e3d3e3c2c30313031303130313031303130313c
2c2d2e2021202120212021202120213c2c2021202120212d2e2021202120213c2c2d2e2021202125262021202120213c2c2d2e2021202120212d2e2d2e2d2e3c2c2d2e202120212d2e2021202120213c2c2d2e2021202120212d2e2d2e2d2e3c2c202120212021202120212d2e2d2e3c2c20212021202120212021202120213c
2c3d3e3031303130313031303130313c2c3031303130313d3e3031303130313c2c3d3e3031303135363031303130313c2c3d3e3031303130313d3e3d3e3d3e3c2c3d3e303130313d3e3031303130313c2c3d3e3031303130313d3e3d3e3d3e3c2c303130313031303130313d3e3d3e3c2c30313031303130313031303130313c
392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a
293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000293b3b3b3b2a293b3b3b2a0000000000
392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000392b2b2b2b3a392b2b2b3a0000000000
293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a293b3b3b3b3b3b3b3b3b3b3b3b3b3b2a
2c2d2e2d2e2d2e20212d2e2d2e2d2e3c2c2d2e2021202120212d2e25262d2e3c2c2d2e202120212021202120212d2e3c2c22232d2e202120212021202120213c2c202120212021202120212d2e2d2e3c2c25262021202120212021202120213c2c20212d2e25262d2e20212d2e2d2e3c2c20212021202125262021202120213c
2c3d3e3d3e3d3e30313d3e3d3e3d3e3c2c3d3e3031303130313d3e35363d3e3c2c3d3e303130313031303130313d3e3c2c32333d3e303130313031303130313c2c303130313031303130313d3e3d3e3c2c35363031303130313031303130313c2c30313d3e35363d3e30313d3e3d3e3c2c30313031303135363031303130313c
2c2d2e202120212021202120212d2e3c2c2d2e2021202120212223202120213c2c2d2e2d2e20212021202120212d2e3c2c20212d2e202120212021202120213c2c202120212021202120212d2e2d2e3c2c2d2e2d2e2d2e2d2e2021202120213c2c20212d2e20212d2e202120212d2e3c2c20212021202120212021202120213c
2c3d3e303130313031303130313d3e3c2c3d3e3031303130313233303130313c2c3d3e3d3e30313031303130313d3e3c2c30313d3e303130313031303130313c2c303130313031303130313d3e3d3e3c2c3d3e3d3e3d3e3d3e3031303130313c2c30313d3e30313d3e303130313d3e3c2c30313031303130313031303130313c
2c2d2e22232d2e20212d2e202120213c2c20212021202120212021202120213c2c20212021202120212021202125263c2c20212d2e2d2e20212021202120213c2c2d2e2021202120212021202120213c2c2021202120212021202120212d2e3c2c2d2e2d2e202120212223202120213c2c2021202120212021202120212d2e3c
2c3d3e32333d3e30313d3e303130313c2c30313031303130313031303130313c2c30313031303130313031303135363c2c30313d3e3d3e30313031303130313c2c3d3e3031303130313031303130313c2c3031303130313031303130313d3e3c2c3d3e3d3e303130313233303130313c2c3031303130313031303130313d3e3c
2c2d2e2021202120212021202120213c2c2021202120212021202120212d2e3c2c20212021202122232021202120213c2c2021202120212021202120212d2e3c2c25262021202122232021202120213c2c2021202120212d2e202120212d2e3c2c25262021202120212d2e2d2e2d2e3c2c20212d2e2d2e2d2e2021202120213c
2c3d3e3031303130313031303130313c2c3031303130313031303130313d3e3c2c30313031303132333031303130313c2c3031303130313031303130313d3e3c2c35363031303132333031303130313c2c3031303130313d3e303130313d3e3c2c35363031303130313d3e3d3e3d3e3c2c30313d3e3d3e3d3e3031303130313c
2c2526202120212021202120212d2e3c2c2021202120212021202120212d2e3c2c202120212d2e20212021202120213c2c2d2e2d2e2d2e2021202120212d2e3c2c2d2e2d2e202120212021202125263c2c2d2e20212d2e2021202120212d2e3c2c2d2e2d2e202120212021202125263c2c2021202120212d2e2d2e2d2e25263c
2c3536303130313031303130313d3e3c2c3031303130313031303130313d3e3c2c303130313d3e30313031303130313c2c3d3e3d3e3d3e3031303130313d3e3c2c3d3e3d3e303130313031303135363c2c3d3e30313d3e3031303130313d3e3c2c3d3e3d3e303130313031303135363c2c3031303130313d3e3d3e3d3e35363c
2c2d2e2021202120212d2e2d2e2d2e3c2c2d2e2d2e2021202120212d2e2d2e3c2c20212021202120212d2e2d2e2d2e3c2c2526202120212021202120212d2e3c2c2d2e2d2e2021202120212d2e2d2e3c2c2d2e22232d2e2021202125262d2e3c2c2d2e2d2e202120212d2e2d2e2d2e3c2c2d2e2021252620212223202120213c
2c3d3e3031303130313d3e3d3e3d3e3c2c3d3e3d3e3031303130313d3e3d3e3c2c30313031303130313d3e3d3e3d3e3c2c3536303130313031303130313d3e3c2c3d3e3d3e3031303130313d3e3d3e3c2c3d3e32333d3e3031303135363d3e3c2c3d3e3d3e303130313d3e3d3e3d3e3c2c3d3e3031353630313233303130313c
392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a392b2b2b2b2b2b2b2b2b2b2b2b2b2b3a
__sfx__
011000200c1201b10007120001000c1200010023100261000c120251001f1001c1000c12018100061000010010120171001712017100101201c10019100161001012016100171001d10010120151000010000100
011000201c0201c0201c02000000000000000023000260001c0201c0201c0201c000000001800006000000001f0201f0201f02017000000001c00019000160001f0201f0201f0201d00015000000000000000000
011000002301023010004002301023010000002301000000260102601000000260102601000000260100000028010280100000028010280100000028010000002401024010000002401024010000002401000000
010e0020000000e0200e02000000000000e0200e02000000000000e0200e02000000000000e0200e0200000000000110201102000000000001102011020000000000011020110200000000000110201102000000
010e00000000026020290202d02000000290202d0202602000000290202d020280200000029020290202d0200000026020290202d02000000290202d0202602000000290202d020280200000029020290202d020
010e00200000021020240201d02000000240202402021020000001d020210202402000000210201d0201d0200000024020240202102000700240202102021020347001d0202102024020000001d0202402024020
010e00200000032020320203202032020307003070000000397003502035020350203502000000357003570000000390203902039020390200000000000390200000035020350203202032020320203202000000
011000000c0200c02000000000000c0200c020000000000010020100200000000000100201002000000000000c0200c02000000000000c0200c02000000000001002010020000000000010020100200000000000
01100000181201c1201c1201c1201f1201812018120181201f1201c1201c1201c1201f120181201812018120181201c1201c1201c1201f1201812018120181201f1201c1201c1201c120181201f1201f1201f120
0110000000100241102411024110001002b1102b1102b110001002411024110241100010028110281102811000100241102411024110001002b1102b1102b1100010024110241102411000100281102811028110
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000030510605107051090510b05111051160511e0510b0010e0011000113001170011b0011c0011b0011b0011b0011b0011b0011b0011b0011c0011b0011b0011b0011b0011b0011c0011c0011c0011c001
000300001b0511b0511a0511805115051100510c05109051060510505105051050010600108001090010b0010b0010d0010e0010e0010d0010c0010b001090010800106001060010400102001010010000102001
000400002915129151291512913124000240002913129131291312913124000291312913129131291312813128131281312813126131261312613126131241312413124131241312413124131241350000000000
00010000303302a3301f3302733031330003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00010000293001f3501d3501c3501c3501b3500e35004350293002930024300293002930029300293002830028300283002830026300263002630026300243002430024300243002430024300243000030000300
00020000000003b0503b0503b0503b050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000100001d0001e000200000400004000030003b0003c000270002d000320001d000170001400012000100000f0000e0000e0000d0001000000000000000000000000000000000000000000000000000000
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
01 00 42 43 44
01 00 01 43 44
01 00 01 43 44
03 00 01 02 44
01 41 42 43 44
01 41 05 43 44
01 41 04 05 44
02 41 04 05 06
02 41 04 05 06
01 07 42 43 44
01 07 08 43 44
02 07 08 09 44
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
