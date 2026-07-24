pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--player
atkanglex = 0
atkangley = 0
atkdp =0
moveanglex = 0
moveangley = 0
movedp =0
playeranime = 0
firstget =false
max_life = 5
bestfloor = 0
mugen =false

function firstset()
music(0)
now_playing =0
spflr_num = 0
playerx = 1
playery = 1
playersprite = 003

sp_flr_1 =18+flr(rnd(5))+1
sp_flr_2 =28+flr(rnd(5))+1
sp_flr_3 =38+flr(rnd(5))+1
sp_flr_4 =48+flr(rnd(5))+1
--info

floor = 0
floormove =true
player_life = max_life
player_atk =1
juel =5
pattack =false

--turn
playerturn = true
_upd = update_game
_drw= draw_game
flower =false
end

--for math
x = 0
y = 0
button =true

function eight(a,b,spr_no)
 x = a*8
 y = b*8
 spr(spr_no,x,y)
end


--wall
wallx =flr(rnd(13))+1
wally =flr(rnd(13))+1

function wallmake()
end


function move()
 --former position
 xnow =playerx
 ynow =playery
 button =true
 
 for i = 0,4 do
  if btnp(i) and button then
  playerturn = false
   if i==0 then
    playerx -= 1
    playersprite = 002
    button =false
   elseif i==1 then
    playerx += 1
    playersprite = 001
    button =false
   elseif i==2 then
    playery -= 1
    playersprite = 000
    button =false
   elseif i==3 then
    playery += 1
    playersprite = 003
    button =false
   elseif i==4 then
    if juel >0 and player_life < max_life then
     player_life += 1
     juel -=1
     sfx(06)
     button =false
    else
    sfx(08)
    button =false
    end
   end
   
  end
 end
 
 if roomcheck
  (playerx,playery) ==0 then
  playerx = xnow
  playery = ynow
 end
 
 for item in all(items) do
 if collision(playerx,playery,item.x,item.y) then
  del(items,item)
  juel += 1
  sfx(00)
  if firstget == false and player_life < max_life then
   message =true
   _upd = update_message
   firstget =true
  end
 end
 end
 
  for enemy in all(enemys) do
 if collision(playerx,playery,enemy.x,enemy.y) then
  enemy.hp -= player_atk
  sfx(03)
  playerx = xnow
  playery = ynow
  atkdp =0
  atkanglex = enemy.x - playerx
  atkangley = enemy.y - playery
 end
 end
 
 if collision(playerx,playery,stairx,stairy) then
  if finalfloor() then
  _upd = update_gameover
  _drw= draw_gameover
  sfx(01)
  return
  end
  
  if floormove ==false then
   floormove =true
   sfx(01)
   playerturn =true
  end
 end
 
 if specialfloor() then
  if collision(playerx,playery,bukiyax,bukiyay)
  or collision(playerx,playery,bukiyax+1,bukiyay)
  or collision(playerx,playery,bukiyax,bukiyay+1)
  or collision(playerx,playery,bukiyax+1,bukiyay+1)
  or collision(playerx,playery,bukiyax-1,bukiyay+1)
  then
   playerx = xnow
   playery = ynow
   message =true
   _upd = update_message
  end
 end
 
 
 if finalfloor() then
  if playerx <= 2
  or playerx >=13
  or playery <= 3
  or playery >=14
  then   
   playerx = xnow
   playery = ynow
  end
  
  if collision(playerx,playery,7,7)
  or collision(playerx,playery,7+1,7)
  or collision(playerx,playery,7,7+1)
  or collision(playerx,playery,7+1,7+1)
  then
    playerx = xnow
   playery = ynow
   flower=true
    
  end
  if flower then
   if collision(playerx,playery,8,9) then
    playerx = xnow
    playery = ynow
   end
  end
 end
 
 moveanglex = playerx -xnow
 moveangley = playery -ynow
 
 
 if player_life <= 0 then
  _upd = update_gameover
  _drw= draw_gameover
  sfx(04)
 end
 
end

function music_play(x)
 if now_playing ~= x then
  music(x)
  now_playing =x
 end
end

function roomcheck(x1,y1)
  
  if x1 <1 or x1 >14 then
  	return 0
  end	 
  if y1 <1 or y1 >14 then
  	return 0
  end  
 
  if x1 == wallx1 then
   if y1 == holeya1 then
    return 11
   elseif y1 == holeya2 then
    return 12
   elseif y1 == holeya3 then
    return 13
   else
    return 0
   end
  end
  
  if x1 == wallx2 then
   if y1 == holeyb1 then
    return 14
   elseif y1 == holeyb2 then
    return 15
   elseif y1 == holeyb3 then
    return 16
   else
    return 0
   end
  end
  
  if y1 == wally1 then
   if x1 == holexa1 then
    return 21
   elseif x1 == holexa2 then
    return 22
   elseif x1 == holexa3 then
    return 23
   else
    return 0
   end
  end
  
  if y1 == wally2 then
   if x1 == holexb1 then
    return 24
   elseif x1 == holexb2 then
    return 25
   elseif x1 == holexb3 then
    return 26
   else
    return 0
   end
  end
  
   if x1 <wallx1 then
    if y1< wally1 then
     return 1
    elseif y1 > wally1 then
     if y1 < wally2 then 
      return 4
     elseif y1 > wally2 then
      return 7   
     end
    end
   elseif x1 >wallx1 then
    if x1 < wallx2 then
     if y1< wally1 then
      return 2
     elseif y1 > wally1 then
      if y1 < wally2 then 
       return 5
      elseif y1 > wally2 then
       return 8   
      end
     end
    elseif x1 > wallx2 then
     if y1< wally1 then
      return 3
     elseif y1 > wally1 then
      if y1 < wally2 then 
       return 6
      elseif y1 > wally2 then
       return 9   
      end
     end
    end 
   end
  return 0
  
end
-->8
--enemy
enemys={}
enemyspr = 5
message = false

function enemyset()
 if enemynum >0 then
 local i =1
  for i = 1,enemynum do
   repeat
    enemyx =flr(rnd(13))+1
    enemyy =flr(rnd(13))+1
   until roomcheck(enemyx,
    enemyy) >0 and not 
    collision(playerx,playery,enemyx,enemyy)
   enemys[i] = {x=enemyx,
   y=enemyy,hp=enemyhp,
   anglex=0,angley=0,d=0,
   atk =false,x_now = enemyx,
   y_now= enemyy,anime =0,
   mokutekiti =false,
   mezasux=0,mezasuy=0,mezasuroom=0,
   teisiturn =0}
  end
 else
 end
end

function enemymove()
 for enemy in all(enemys) do
 if enemy.hp <= 0 then
 del(enemys,enemy)
 else
  enemy.x_now =enemy.x
  enemy.y_now =enemy.y
  eroom = roomcheck(enemy.x,enemy.y)
  if abs(enemy.x-playerx)< 2 and
     abs(enemy.y-playery)< 2then
   if enemy.y == playery or
      enemy.x == playerx then
     player_life -= enemyattack
     sfx(02)
     enemy.d = 0
					enemy.anglex = playerx -enemy.x
					enemy.angley = playery -enemy.y
					enemy.atk = true
   else
   repeat
    local rand = flr(rnd(2))
      enemy.x =enemy.x_now
      enemy.y =enemy.y_now
     if rand ==0 then
      enemy.y = playery
     else
      enemy.x = playerx
     end
    until roomcheck(enemy.x,enemy.y) >0 
   end
  else
   if eroom 
   ==roomcheck(playerx,playery) then
    enemy.mezasux= playerx
    enemy.mezasuy= playery
    enemy.mokutekiti =true
   end

			if enemy.x ==enemy.mezasux and enemy.y == enemy.mezasuy then
			 enemy.mokutekiti =false
			end
   
   if enemy.mokutekiti == false then
   enemy.mokutekiti =true
   enemy.mezasuroom = 0
   local rand = flr(rnd(2))
   if floor < changefloor then 
    if eroom ==1 then
     if rand == 0 then 
      enemy.mezasuroom= 11
	    else 
      enemy.mezasuroom= 21
     end
	 		elseif eroom ==2 then
     if rand == 0 then 
      enemy.mezasuroom= 11
	    else 
      enemy.mezasuroom= 22
     end
	 		elseif eroom ==4 then
     if rand == 0 then 
      enemy.mezasuroom= 21
	    else
      enemy.mezasuroom= 12
     end
		 	elseif eroom ==5 then
     if rand == 0 then 
      enemy.mezasuroom= 12
	    else 
      enemy.mezasuroom= 22
     end
    end
   else
    local r = flr(rnd(12))
    if eroom ==1 then
     if r/6 < 1  then 
      enemy.mezasuroom= 11
	    else
      enemy.mezasuroom= 21
     end
	 		elseif eroom ==2 then
     if r/4 < 1 then 
      enemy.mezasuroom= 11
	    elseif r/4 >= 2 then
      enemy.mezasuroom= 22
     else
      enemy.mezasuroom= 14
     end
    elseif eroom ==3 then
     if r/6 < 1  then 
      enemy.mezasuroom= 14
	    else
      enemy.mezasuroom= 23
     end
	 		elseif eroom ==4 then
     if r/4 < 1 then 
      enemy.mezasuroom= 21
	    elseif r/4 >= 2 then
      enemy.mezasuroom= 12
     else
      enemy.mezasuroom= 24
     end
		 	elseif eroom ==5 then
     if r/3 < 1 then 
      enemy.mezasuroom= 12
	    elseif r/3 >= 3 then
      enemy.mezasuroom= 22
     elseif r/3 <= 2 then
      enemy.mezasuroom= 25
     else
      enemy.mezasuroom= 15
     end
    elseif eroom ==6 then
     if r/4 < 1 then 
      enemy.mezasuroom= 23
	    elseif r/4 >= 2 then
      enemy.mezasuroom= 15
     else
      enemy.mezasuroom= 26
     end
    elseif eroom ==7 then
     if r/6 < 1  then 
      enemy.mezasuroom= 24
	    else
      enemy.mezasuroom= 13
     end
    elseif eroom ==8 then
     if r/4 < 1 then 
      enemy.mezasuroom= 13
	    elseif r/4 >= 2 then
      enemy.mezasuroom= 25
     else
      enemy.mezasuroom= 16
     end
    elseif eroom ==9 then
     if r/6 < 1 then 
      enemy.mezasuroom= 16
	    else
      enemy.mezasuroom= 26
     end
    end
   end
    if eroom >= 10 and eroom < 20 then
     enemy.x =enemy.x+1-rand*2
     enemy.mokutekiti = false
    elseif eroom >= 20 then
     enemy.y =enemy.y+1-rand*2
     enemy.mokutekiti = false
    end
    
    if enemy.mezasuroom == 11 then
     enemy.mezasux= wallx1
     enemy.mezasuy= holeya1
    elseif enemy.mezasuroom == 12 then
     enemy.mezasux= wallx1
     enemy.mezasuy= holeya2
    elseif enemy.mezasuroom == 13 then
     enemy.mezasux= wallx1
     enemy.mezasuy= holeya3
    elseif enemy.mezasuroom == 14 then
     enemy.mezasux= wallx2
     enemy.mezasuy= holeyb1
    elseif enemy.mezasuroom == 15 then
     enemy.mezasux= wallx2
     enemy.mezasuy= holeyb2
    elseif enemy.mezasuroom == 16 then
     enemy.mezasux= wallx2
     enemy.mezasuy= holeyb3
    elseif enemy.mezasuroom == 21 then
     enemy.mezasux= holexa1
     enemy.mezasuy= wally1
    elseif enemy.mezasuroom == 22 then
     enemy.mezasux= holexa2
     enemy.mezasuy= wally1
    elseif enemy.mezasuroom == 23 then
     enemy.mezasux= holexa3
     enemy.mezasuy= wally1
    elseif enemy.mezasuroom == 24 then
     enemy.mezasux= holexb1
     enemy.mezasuy= wally2
    elseif enemy.mezasuroom == 25 then
     enemy.mezasux= holexb2
     enemy.mezasuy= wally2
    elseif enemy.mezasuroom == 26 then
     enemy.mezasux= holexb3
     enemy.mezasuy= wally2
    end
    
    
   end
   
   if enemy.mokutekiti ==true then
    enemy.x,enemy.y= chase(enemy.x,enemy.y,enemy.mezasux,enemy.mezasuy)
   end
   
  end
    
   if collide_enemy(enemy,enemy.x,enemy.y) then
    enemy.x = enemy.x_now
    enemy.y = enemy.y_now
   end
 
  if roomcheck(enemy.x,enemy.y) ==0 then
   enemy.x = enemy.x_now
   enemy.y = enemy.y_now
  end
  
   if eroom 
   ~=roomcheck(playerx,playery)
   and enemy.mokutekiti == true then
   enemy.teisiturn +=1
   else
   enemy.teisiturn = 0
   end
 if eroom 
  ==roomcheck(playerx,playery)
 then
 enemy.teisiturn = 0
 end
   if floor < changefloor then 
    if enemy.teisiturn >=15 then
     enemy.mokutekiti =false
     enemy.teisiturn = 0
    end
   else
    if enemy.teisiturn >=6 then
     enemy.mokutekiti =false
     enemy.teisiturn = 0
    end
   end
   
  if enemy.atk == false then
   enemy.d = 0
		 enemy.anglex = enemy.x -enemy.x_now
		 enemy.angley = enemy.y -enemy.y_now
  end
 end
 end
   
   playerturn =true   
end 

function collide_enemy(c,x,y)
 for other in all(enemys) do
  if c ~= other and collision(x,y,other.x,other.y) then
   return true
  end
 end
 return false
end

function chase(x1,y1,x2,y2)
local xx =x1
local yy =y1
repeat
local r =flr(rnd(2))
 x1 =xx
 y1 =yy
 if x2>x1 then
  if y2 >y1 then
  	if r ==0 then
  	 x1 +=1
  	else
  	 y1 +=1
  	end
  elseif y2 == y1 then
   x1 += 1
  elseif y2 < y1 then
   if r ==0 then
  	 x1 += 1
  	else
  	 y1 -=1
  	end
  end
 elseif x2 ==x1 then
  if y2 >y1 then
  	 y1 +=1
  elseif y2 < y1 then
  	 y1 -=1
  else
   x1=x1 y1 =y1
  end  
 elseif x2<x1 then
  if y2 >y1 then
  	if r ==0 then
  	 x1 -= 1
  	else
  	 y1 +=1
  	end
  elseif y2 == y1 then
   x1 -= 1
  elseif y2 < y1 then
   if r ==0 then
  	 x1 -= 1
  	else
  	 y1 -=1
  	end
  end
 end 
 until roomcheck(x1,y1) >0
 return x1,y1
end

-->8
--update
d=0
 start_time =0
function _init()
_upd = update_start
_drw= draw_start
start_wait =false
end

function set()
bestfloor = max(floor,bestfloor)
 for item in all(items) do
  del(items,item)
 end
 for enemy in all(enemys) do
  del(enemys,enemy)
 end
--enemy
 enemyattack = 1
 enemyhp=flr((floor-6)/10)+2
 enemynum = (floor-1)%5+1+flr((floor-1)/10)
 if floor <=5 then
itemnum = (floor-1)%5+1
else itemnum = floor%5+2 end
wallset()
stairset()
  if specialfloor() or finalfloor()  then
   wallx1 =-1
   wally1 =-1
   wallx2 =-1
   wally2 =-1
   itemnum =0
   enemynum =0
   stairx =7
   stairy =2
   playerx =7
   playery =13
   if finalfloor() then
    stairx =7
    stairy =5
   end
  end
enemyset()
itemset()
 if specialfloor() then
  music_play(1)
 else
  music_play(0)
 end
end

function _update()
_upd()
end

function update_message()
movedp =0
if specialfloor() then
weaponman()
else

 if btnp(Ž) then
  _upd = update_game
  message =false
 end
end
end

function update_game()
 if floormove==true then
  floor += 1
  set()
  floormove =false
 end

 if playerturn ==true then
  move()
 else
  enemymove()
 end
end

function update_gameover()
 music(-1)
 if btnp(Ž) then
  _upd = update_start
   _drw= draw_start
   return
 end
 --[[
 if finalfloor() then
  if btnp(Ž) then
   _upd = update_start
   _drw= draw_start
  end
 end]]
end

function update_start()
  
  if bestfloor >= lastfloor and
      btnp(—) then
    start_wait =true
  start_time =0
  sfx(7)
  mugen =true
  end
  
 if btnp(Ž) and start_wait==false then
  start_wait =true
  start_time =0
  sfx(7)
  mugen =false
 end
 
 if start_wait ==true then
 start_time += 1
 end
 
 if start_time>=30 then
  firstset()
  start_wait =false
  start_time =0
 end

end

bure =0
function draw_start()
rectfill(0,0,128,128,1)
map(0,16,0,0,16,16)
circfill(31,35+bure,18,7)
circfill(39,33,16,1)
--rectfill(33,20,94,50,1)
rectfill(64,20,94,50,1)
spr(64, 6*8, 3*8, 4, 2)
spr(96, 5*8-4, 5*8, 7, 1)

 if start_wait ==true then
  tenmetu +=2
 else
  tenmetu +=1
  
  if bestfloor >= lastfloor then
   print("button — or x endless",18,110,8)
  end
  
 end
 if tenmetu >=10 then
  print("button Ž or z start",22,100,7)
  playersprite=3
  if start_wait then playersprite=1 end
 else playersprite=19
  if start_wait then playersprite=17 end
 end
if tenmetu >=20 then
 tenmetu =0
 bure = flr(rnd(2))
end

rectfill(68,89,75,74,1)
line(8,88,120,88,7)
eight(4+start_time/10,10,playersprite)
if start_time>=25 then
rectfill(0,0,128,128,1)
end

if bestfloor >0 then
print("best floor:"..bestfloor,11,70)
end

end

function _draw()
_drw()
end

function draw_game()
--clear the screen
rectfill(0,0,128,128,1)
draw_wall()
--playeranime
 playeranime +=1
 if playeranime % 13 == 6 then
  if playersprite >= 16 then
  playersprite -= 16
  else
  playersprite += 16
  end
 end
--player attacknoidou
if abs(atkdp) < abs(atkanglex/2) then
 eight(playerx+atkdp,playery,playersprite)
 atkdp += atkanglex/4
elseif abs(atkdp) < abs(atkangley/2) then
 eight(playerx,playery+atkdp,playersprite)
 atkdp += atkangley/4
else
 if abs(movedp) < abs(moveanglex) then
  eight(xnow+movedp,playery,playersprite)
  movedp += moveanglex/3
 elseif abs(movedp) < abs(moveangley) then
  eight(playerx,ynow+movedp,playersprite)
  movedp += moveangley/3
 else
eight(playerx,playery,playersprite)
movedp =0
 end
end

for item in all(items) do
 eight(item.x,item.y,4)
end
if finalfloor() then
eight(stairx,stairy,6)
else
eight(stairx,stairy,22)
end
--enemy attack move
for enemy in all(enemys) do
 if enemy.hp <= player_atk then
  enemyspr =5
 else
 enemyspr = 37
 end
 enemy.anime +=1
 if enemy.anime % 10 >= 6 then
  enemyspr += 16
 end
 if enemy.atk ==true then
 if abs(enemy.d) < abs(enemy.anglex/1.5) then
  eight(enemy.x+enemy.d,enemy.y,enemyspr)
  enemy.d += enemy.anglex/4
 elseif abs(enemy.d) < abs(enemy.angley/1.5) then
  eight(enemy.x,enemy.y+enemy.d,enemyspr)
  enemy.d += enemy.angley/4
 else
  enemy.anglex=0
  enemy.angley=0
  enemy.d = 0
  enemy.atk=false
  eight(enemy.x,enemy.y,enemyspr)
 end
 else
  if abs(enemy.d) < abs(enemy.anglex) then
   eight(enemy.x_now+enemy.d,enemy.y,enemyspr)
   enemy.d += enemy.anglex/4
  elseif abs(enemy.d) < abs(enemy.angley) then
   eight(enemy.x,enemy.y_now+enemy.d,enemyspr)
   enemy.d += enemy.angley/4
  else
  eight(enemy.x,enemy.y,enemyspr)
  end
 end 
 --[[
 print(enemy.mezasuroom,enemy.x*8,enemy.y*8,10)
 print(enemy.mezasux,enemy.x*8+9,enemy.y*8,9)
 print(enemy.mezasuy,enemy.x*8,enemy.y*8+9,9)
 print(enemy.mokutekiti,enemy.x*8+9,enemy.y*8+9,9)
 print(enemy.teisiturn,enemy.x*8+9,enemy.y*8+9+9,9)
 ]]
end



if finalfloor() then
 draw_final()
 else
  map(0,0,0,0,16,16)
end
--ui
rectfill(0,0,128,7,0)
print(floor,1,1,7)
print("f",1+8,1)
print("‡",1+16,1)
rect(26,0,48,6)
if player_life >=1 then
 spr(20,28,0)

 if player_life >=2 then spr(20,32,0)
  if player_life >=3 then spr(20,36,0)
   if player_life >=4 then spr(20,40,0)
    if player_life >=5 then spr(20,44,0)
    if player_life >=6 then print("+",50,0)
    end
    end
   end
  end
 end
end
--print(player_life,1+28,1)
print("†:",1+48+12,1)
print(juel,1+60+12,1)
print("atk:",1+72+12+6,1)
print(player_atk,1+92+12+6,1)

--print(enemynum,100,1)

--wall info
--[[
print("wallx1:"..wallx1,1,1,3)
print("wally1;"..wally1,1,7,3)
print("wallx2:"..wallx2,1,13,8)
print("wally2:"..wally2,1,19,8)
print("holexa1:"..holexa1,1,25,9)
print("holexa2:"..holexa2,1,31,9)
print("holexa3:"..holexa3,1,37,9)
print("holexb1:"..holexb1,1,43,10)
print("holexb2:"..holexb2,1,49,10)
print("holexb3:"..holexb3,1,57,10)
print("holeya1:"..holeya1,1,69,9)
print("holeya2:"..holeya2,1,75,9)
print("holeya3:"..holeya3,1,81,9)
print("holeyb1:"..holeyb1,1,87,10)
print("holeyb2:"..holeyb2,1,93,10)
print("holeyb3:"..holeyb3,1,99,10)
]]
if message then
 draw_message()
else
 lineno = 1
end


if specialfloor() then
 draw_special()
end


end

function draw_gameover()
 rectfill(0,0,128,128,1)
 if finalfloor() then
 spr(38, 64-8, 64-8-24, 2, 2)
 spr(71, 64-32, 64, 9, 1)
 spr(84, 64-8-32, 64+12, 11, 1)
 else
 spr(32, 64-8, 64-8-24, 2, 2)
 print("you died in "..floor.. " f",30,56,7)
 print("button Ž restart",30,64,7)
 end
--print("1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 ",0,0,15)
end
-->8
--wallmake
changefloor = 5

wallx1 =0
wallx2 =0
wally1=0
wally2=0
holexa1 =0
holexa2 =0
holexa3 =0
holexb1 =0
holexb2 =0
holexb3 =0
holeya1 =0
holeya2 =0
holeya3 =0
holeyb1 =0
holeyb2 =0
holeyb3 =0

function wallset()

if floor<changefloor then
 repeat 
  wallx1 =flr(rnd(10))+3
  wally1 =flr(rnd(10))+3
 until wallx1 ~= playerx and wally1 ~= playery
 wallx2 =15
 wally2 =15
else
 repeat 
  wallx1 =flr(rnd(7))+3
  wally1 =flr(rnd(7))+3
  wallx2 =flr(rnd(10-wallx1))+wallx1+3
  wally2 =flr(rnd(10-wally1))+wally1+3
 until wallx1 ~= playerx and wally1 ~= playery and
 wallx2 ~= playerx and wally2 ~= playery
end

holexa1 =flr(rnd(wallx1-1))+1
holexa2 =flr(rnd(wallx2-wallx1-1))+wallx1+1
holexa3 =flr(rnd(15-wallx2-1))+wallx2+1

holexb1 =flr(rnd(wallx1-1))+1
holexb2 =flr(rnd(wallx2-wallx1-1))+wallx1+1
holexb3 =flr(rnd(15-wallx2-1))+wallx2+1

holeya1 =flr(rnd(wally1-1))+1
holeya2 =flr(rnd(wally2-wally1-1))+wally1+1
holeya3 =flr(rnd(15-wally2-1))+wally2+1

holeyb1 =flr(rnd(wally1-1))+1
holeyb2 =flr(rnd(wally2-wally1-1))+wally1+1
holeyb3 =flr(rnd(15-wally2-1))+wally2+1
if floor<changefloor then
holexa3=15
holeya3=15
end

end

function draw_wall()
local xx =0
local yy =0
 for xx=1,14 do
  eight(xx,wally1,7)
  eight(xx,wally2,7)
  eight(wallx1,xx,7)
  eight(wallx2,xx,7)
 end
 
 eight(holexa1,wally1,15)
 eight(holexa1-1,wally1,23)
 
 eight(holexa2,wally1,15)
 eight(holexa3,wally1,15)
 eight(holexb1,wally2,15)
 eight(holexb2,wally2,15)
 eight(holexb2+1,wally2,23)
 eight(holexb3,wally2,15)
 eight(wallx1,holeya1,15)
 eight(wallx1,holeya2,15)
 eight(wallx1,holeya2+1,23)
 eight(wallx1,holeya3,15)
 eight(wallx2,holeyb1,15)
 eight(wallx2,holeyb1-1,23)
 
 eight(wallx2,holeyb2,15)
 eight(wallx2,holeyb3,15)
--[[
 for xx = 1,holexa1-1 do
  eight(xx,wally1,7)
 end
 for xx = holexa1+1,holexa2-1 do
  eight(xx,wally1,7)
 end
 for xx = holexa2+1,holexa3-1 do
  eight(xx,wally1,7)
 end
  for xx = holexa3+1,14 do
   eight(xx,wally1,7)
  end
 
 for xx = 1,holexb1-1 do
  eight(xx,wally2,7)
 end
 for xx = holexb1+1,holexb2-1 do
  eight(xx,wally2,7)
 end
 for xx = holexb2+1,holexb3-1 do
  eight(xx,wally2,7)
 end
 for xx = holexb3+1,14 do
  eight(xx,wally2,7)
 end
 
 for xx = 1,holeya1-1 do
  eight(wallx1,xx,7)
 end
 for xx = holeya1+1,holeya2-1 do
  eight(wallx1,xx,7)
 end
 for xx = holeya2+1,holeya3-1 do
  eight(wallx1,xx,7)
 end
 for xx = holeya3+1,14 do
  eight(wallx1,xx,7)
 end
 
  for xx = 1,holeyb1-1 do
  eight(wallx2,xx,7)
 end
 for xx = holeyb1+1,holeyb2-1 do
  eight(wallx2,xx,7)
 end
 for xx = holeyb2+1,holeyb3-1 do
  eight(wallx2,xx,7)
 end
 for xx = holeyb3+1,14 do
  eight(wallx2,xx,7)
 end
 ]]
end


-->8
--item stair
items={}
stairx=0
stairy=0
function itemset()
local i =1
for i = 1,itemnum do
  repeat
   itemx =flr(rnd(13))+1
   itemy =flr(rnd(13))+1
  until roomcheck(itemx,
  itemy) > 0 and not collision(playerx,playery,itemx,itemy)
 items[i] = {x=itemx,y=itemy}
end
end

function stairset()
 repeat
  stairx =flr(rnd(13))+1
  stairy =flr(rnd(13))+1
 until roomcheck(stairx,
 stairy) >0  and not collision(playerx,playery,stairx,stairy)
end

function collision(x1,y1,x2,y2)
 if x1==x2 and y1==y2 then 
  return true
  else
  return false
 end
end

-->8
--specialfloor
   bukiyax =7
   bukiyay =4
lineno=1
tenmetu = 0
choise =false
weaponup = 0
cursorx=1*8+70
spflooronce =false
spanime = 0
spflr_num = 1
messageend =false

function specialfloor()
 if floor%lastfloor  ==11 or
 floor%lastfloor == sp_flr_1 or
 floor%lastfloor == sp_flr_2 or
 floor%lastfloor == sp_flr_3 or
 floor%lastfloor == sp_flr_4
 then
  if spflooronce == true then
   choise =false
   weaponup = 0
   spflooronce =false
   spflr_num +=1
  else 
  end
  return true
 else
  spflooronce =true
  weaponup = 1
  lineno =1
  return false
 end
end

function weaponman()

 if btnp(Ž) then
  if weaponup > 0 and messageend then
  _upd = update_game
  message =false
  messageend =false
   if weaponup == 1 then
    weaponup =0
    lineno =1
   end
  end
 end
 
 if choice then
  if btnp (‹) then
   cursorx =1*8+70
  elseif btnp(‘) then
   cursorx =1*8+95
  end
   if btnp(Ž) or btnp(—) then
   choice =false
    if cursorx == 1*8+70 then
     if juel >=5*spflr_num then
     weaponup = 2
     player_atk =spflr_num+1
     juel -=5*spflr_num
     lineno =1
     sfx(05)
     else
      weaponup = 3
      player_life +=2
      sfx(06)
      messageend =true
     end
    else
     weaponup = 1
     messageend =true
    end   
   end
 else
  if btnp(Ž) then
  lineno +=1
  end
 end



end

function draw_special()
spr(9, 7*8, 4*8, 2, 2)
spr(24, 7*8-8, 4*8+8)
if not message then
spanime += 1
end

spr(11, 7*8+1-spanime/20, (4+1)*8)

 
 if spanime >= 39 then
  spanime =0
 end

end

function draw_message()
tenmetu +=1
rectfill(1*8-1,8*8-1,15*8,15*8,1)
rectfill(1*8-1+1,8*8-1+1,15*8-1,15*8-1,7)
rectfill(1*8-1+2,8*8-1+2,15*8-2,15*8-2,1)
if not specialfloor() then
print("! use juel† to heal",1*8+3,8*8+3+5,14)
print("  button Ž",1*8+3,8*8+25,14)
else

if weaponup == 0 then

 if lineno >=1 then
  if spflr_num==1 then
    print("	you juel† have.",1*8+3,8*8+3+5,14)
  elseif spflr_num ==2 then
   print("	you again !",1*8+3,8*8+3+5,14)
  elseif spflr_num ==3 then
   print("	why you go up ?.",1*8+3,8*8+3+5,14)
  elseif spflr_num ==4 then
   print("	you alive now. happy.",1*8+3,8*8+3+5,14)
  elseif spflr_num >=5 then
   print("	......",1*8+3,8*8+3+5,14)
  end
  if lineno >=2 then
   print(" your juel†"..5*spflr_num.." juel.",1*8+3,8*8+3+20-5,14)
   if lineno >=3 then
    print(" you stronger.",1*8+3,8*8+3+30-5,14)
    if lineno >=4 then
     print(" by me.",1*8+3,8*8+3+40-5,14)
     choice =true
     print("yes",1*8+70,8*8+3+40,14)
     print("no",1*8+95,8*8+3+40,14)
    end
   end
  end
 end  --gyouhenka
 
 if not choice then
  if tenmetu <= 10 then
   print("Ž",100,8*8+3-5+10*min(lineno,3),14)
  end
 end
elseif weaponup ==2 then 
 if tenmetu <= 10 then
  print("Ž",100,8*8+3-5+10*min(lineno,3),14)
 end
 
 if spflr_num ==1 then 
 print("	you smart.",1*8+3,8*8+3+5,14)
 messageend =true
 elseif spflr_num ==2 then 
  if lineno>=1 then
   print("	red one, 2 attack.",1*8+3,8*8+3+5,14)
   if lineno >=2 then
   print(" white one, 1 attack.",1*8+3,8*8+3+20-5,14)
    if lineno >=3 then
    messageend =true
    print(" care.",1*8+3,8*8+3+30-5,14)
    end
   end
  end
 elseif spflr_num ==3 then
  if lineno>=1 then
   print("	see many go up.",1*8+3,8*8+3+5,14)
   if lineno >=2 then
   print(" few go down.",1*8+3,8*8+3+20-5,14)
    if lineno >=3 then
    messageend =true
    print(" i up and down.",1*8+3,8*8+3+30-5,14)
    end
   end
  end
 elseif spflr_num ==4 then
  if lineno>=1 then
   print("	your juel.",1*8+3,8*8+3+5,14)
   if lineno >=2 then
   print(" thanks. i rich.",1*8+3,8*8+3+20-5,14)
    if lineno >=3 then
    messageend =true
    print(" use ? secret.",1*8+3,8*8+3+30-5,14)
    end
   end
  end
  elseif spflr_num >=5 then
  if lineno>=1 then
   print("	... ...",1*8+3,8*8+3+5,14)
   if lineno >=2 then
   print(" ... go up.",1*8+3,8*8+3+20-5,14)
    messageend =true
   end
  end
 end
elseif weaponup ==1 then
 messageend =true
 print("	you idiot.",1*8+3,8*8+3+5,14)
elseif weaponup ==3 then
 messageend =true
 print("	you poor.",1*8+3,8*8+3+5,14)
 print("	sorry.",1*8+3,8*8+3+5+10,14)
 print("	heal you.",1*8+3,8*8+3+5+20,14)
end


 if tenmetu > 20 then
  tenmetu = 0
 end

 if choice then
  if tenmetu <= 10 then
   rectfill(cursorx,8*8+3+40,cursorx+13,8*8+3+40+6,1)
  end
 end

end

end

-->8
--finalfloor
lastfloor =56
function finalfloor()
if mugen then
return false
end

 if floor >=lastfloor then
 music(-1)
  return true
 else
 return false
 end
end

bure2 =0
function draw_final()
tenmetu +=1
 if tenmetu >= 15 then
  bure =flr(rnd(3))
  bure2 =flr(rnd(3))
  tenmetu =0
 end
--crowds
spr(13, 14*8-8+bure, 13*8-3, 2, 1)
spr(13, 14*8-2+bure, 13*8+4, 2, 1)
spr(13, 14*8-6+bure, 13*8+10, 2, 1)
spr(13, 1*8-6+bure2, 12*8-3, 2, 1,true)
spr(13, 1*8+bure2-2, 12*8+4, 2, 1,true)
spr(13, 1*8-4+bure2, 12*8+10, 2, 1,true)

map(16,0,0,0,16,16)
spr(32, 7*8, 7*8, 2, 2)

  if flower then
  eight(8,9,12)
  end
end

function update_final()
end
__gfx__
00777700000770000007700000777700000000000777777077777777777771770777077000000000000000000000000000007000000000000000000011111111
0700007000700000000007000700007000077000711111177000700777777177000000070000000000077700000700000007b700777777777777000011111111
07000070070b07700770b07007b00b70007707007181181770777007111111117707770700777770000707770007700000707070777777777777700011111111
070000700700077777700070070770700777707071111117777070077717777700000007077777770007070700000000077707b7777777777777777011111111
00777700007007700770070000700700077777700771177070707007771777770777077077777777707777770000000007777070777777777777777711111111
07777700077777000077777000777770007777000707707070707007771777770000000770777770707777770000000007777700777777777777777711111111
0777770007777000000777700077777000077000070000707070700711111111770777077000b000707000070000000077777000777777777777770011111111
00770770007077000077070007707700000000000770077077777777777771770000000770000000707777770000000000000000777777777777000011111111
00777700000770000007700000777700000000000777777000007777771771770777777070000000707777770000000000000000bbbbbbbb0000000000000000
07000070007000000000070007000070000000007111111700777007777771770777777007000007007777770007000000000000bbbbbbbb0000000000000000
07000070070b07700770b07007b00b70777000007181181777707007111111110077770070000007007000070007700000000000bbbbbbbb0000000000000000
07000070070007777770007007077070777000007111111770707777771777170070070070000007707777770000000000000000bbbbbbbb0000000000000000
00777700007007700770070000700700777000000777777070777007771771770700007007000070707777770000000000000000bbbbbbbb0000000000000000
07777700077777000077777000777770000000007000000777700007771777770700007077777070707777770000000000000000bbbbbbbb0000000000000000
07777700077770000007777000777770000000007770077770000007111111110077770070000770707000070000000000000000bbbbbbbb0000000000000000
07707700070700000000707000770770000000000000000077777777777771770000000077777777707777770000000000000000bbbbbbbb0000000000000000
00000000000000000000000000000000000000000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777777000000000000000000000000000008111111800000777777000000000000000000000000007000000000000000000000000000000000000000000
00007777777700000000000000000000000000008181181800007777777700000777077707770777077707000000000000000000000000000000000000000000
00077777777770000000000000000000000000008111111800077777777770000777077707770777077707000000000000000000000000000000000000000000
00777777777777000000000000000000000000000881188000070000000070000777077707770777077707000000000000000000000000000000000000000000
07777777777777700000000000000000000000000808808000070000000070000777077707770777077707000000000000000000000000000000000000000000
07777777777777700000000000000000000000000800008000777007000777000777077707770777077707000000000000000000000000000000000000000000
07000070700007700000000000000000000000000880088000777777077777000000000000000000000007000000000000000000000000000000000000000000
07077077707707700000000000000000000000000888888000777777077777007777777777777777777777000000000000000000000000000000000000000000
07000070700007700000000000000000000000008111111800777777077777000000000000000000000000000000000000000000000000000000000000000000
07070770707777700000000000000000000000008181181807777777077777700000000000000000000000000000000000000000000000000000000000000000
07077070707770700000000000000000000000008111111807777777777777700000000000000000000000000000000000000000000000000000000000000000
07777777777777700000000000000000000000000888888007777077770777700000000000000000000000000000000000000000000000000000000000000000
07777777777777700000000000000000000000008000000807777700007777700000000000000000000000000000000000000000000000000000000000000000
77777777777777770000000000000000000000008880088807777777777777700000000000000000000000000000000000000000000000000000000000000000
77777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777770770007707777777077000000000000000000000000000000777777707700077077777770770007707700077000000000770007700777770077000770
77777770770007707777777077000000000000000000000000000000777777707700077077777770777007707700777000000000777077707777777077000770
00077000770007707000000077000000000000000000000000000000007770007700077077000770777707707707770000000000077777007700077077000770
00077000770007707777777077000000000000000000000000000000007770007777777077000770777777707777700000000000007770007700077077000770
00077000770007707777777077000000000000000000000000000000007770007777777077777770770777707777700000000000007770007700077077000770
00077000770007707000000077000000000000000000000000000000007770007700077077777770770077707707770000000000007770007700077077000770
77777000777777707777777077777770000000000000000000000000007770007700077077000770770007707700777000000000007770007777777077777770
77777000777777707777777077777770000000000000000000000000007770007700077077000770770007707700077000000000007770000777770077777770
00000000000000000000000000000000777777700777770077777700000000007777770077000000777777707700077077777770770007700777770000000000
00000000000000000000000000000000777777707777777077777770000000007777777077000000777777707770777077777770777007707777777000000000
00000000077770700707770000000000770000007700077077000770000000007700077077000000770007700777770000777000777707707700077000000000
00000000070070770707007000000000777777007700077077000770000000007700077077000000770007700077700000777000777777707700000000000000
00000000077770707707007000000000777777007700077077777770000000007777777077000000777777700077700000777000770777707700777000000000
00000000070070700707770000000000770000007700077077777700000000007777770077000000777777700077700000777000770077707700777000000000
00000000000000000000000000000000770000007777777077007770000000007700000077777770770007700077700077777770770007707777777000000000
00000000000000000000000000000000770000000777770077000770000000007700000077777770770007700077700077777770770007700777770000000000
77777700770007707700077007777700777777700777770077000770000000000000000000000000000000000000000000000000000000000000000000000000
77777770770007707770077077777770777777707777777077700770000000000000000000000000000000000000000000000000000000000000000000000000
77000770770007707777077077000770700000007700077077770770000000000000000000000000000000000000000000000000000000000000000000000000
77000770770007707777777077000000777777707700077077777770000000000000000000000000000000000000000000000000000000000000000000000000
77000770770007707777777077007770777777707700077077777770000000007770770000000000000000000000000000000000000000000000000000000000
77000770770007707707777077007770700000007700077077077770000000007070707000000000000000000000000000000000000000000000000000000000
77777770777777707700777077777770777777707777777077007770000000007070700000000000000000000000000000000000000000000000000000000000
77777700777777707700077007777700777777700777770077000770000000007770700000000000000000000000000000000000000000000000000000000000
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
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000707000707000007070007070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000707070707070707070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000700000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000707070707070707070707070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000708080808080808080808070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070708000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000070707070700000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000141001a1001b05020050260502b0501e05017200182001620017200182001a2001b2001d2001e2001f20020200222002320026200292002d200302000610007100061000410002100021000210000000
000300000666311663106630e6630d61307713067130672312663116630d6530271301713047130471303743106630e6530a643047230471304713057330a6530a6730b6630f6430f64308713077130571304713
000100000f45010450164501c450134501f4501445012450094500c4501f4500b4500b4500000000000133001a300000002430000000303003b30038300243001b30018300000000000000000000000000000000
0001000010330163301d3302833028330123300c3300c33011330183302633003330043300000000000133001a300000002430000000303003b30038300243001b30018300000000000000000000000000000000
000e000013450114500a4500543014450114500e45006430104500c45006430054500443003450024500145001450024500540005400054000640008400034000140000400004000040000400004000040000400
00030000020500205005050080500e050150501d050250502d0503a0503e0501a0001f00026000350001400016000180001a0001c0001e0001f0002600024000290002a0002e0003000033000360003900000000
0002000011050160501f050250502a0503005034050370502005018050091500a1500b1500e15012150191501e150251502c15035150371500500004000060000b000110001c000270003200038000390003a000
0003000000100120501b05020050260502a0502c05026050220501b05016050130501205011050110501105011050140501405014050150501805018050180501805018050180501805018050180501805018050
000200000525004250092500425001250002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00081c0230000300003000031c023000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
011e0010130301103015030000000c0300e03010030000001303011030150300c0001303011030150300000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00101f0421f0421f042210421f0421d0421d0421f04221042210422104223042210421d0421d0421d0422104221042210421f042210421d0421d0421d0420000200002000020000200002000020000200002
01100f1f0000000000000000000000000000000000000000000000000000000000000000000000000000000020550205502055000000225502255022550000002255022550225500000022550225502055000000
011400101c5201a5201d5201a520245201c520235201a5202152018520215201a520215201c520215201a52000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000102055020550205500000022550225502255000000225502255022550000002255022550205500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 0b 0c 43 44
03 0b 42 0d 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
