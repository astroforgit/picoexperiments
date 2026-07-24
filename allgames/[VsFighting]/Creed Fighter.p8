pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function set_vars()
roundtextshowing = true
punch_stun_time = 6
special_stun_time = 15
floor_top = 85
round_tick = 0
round = 1
anim_tick = 0
walkspd = 1
bible=185 --2,4
handup=187 --2,5
particles = {}
p1canmakemorepcls = true
p2canmakemorepcls = true
winner = ""
p1wins = 0
p2wins = 0
pcls2 = {}
cors = {}
smokes = {}
intro = {
"nicaea, 325 ce:",
"bishops gather from everywhere",
"to debate and codify the",
"doctrines of the church.",
"legend says that st. nicholas",
"(of santa claus fame)", 
"was there, as well as",
"arius, notable heretic. arius",
"argued for his beliefs, but",
"they were so offensive that",
"after days of listening to ",
"heresy upon heresy, nicholas",
"finally lost his temper and ",
"slapped the other bishop!",
"thus orthodoxy prevailed."
}
end

function _init()
 set_vars()
 lines_drawn = 1
 make_players()
 initsplash()
 mode = "splash"
 music(0)
end

function _update()
 anim_tick += 1
 if mode == "game" then
  gameupdate()
 elseif mode == "title" then
  titleupdate()
 elseif mode == "splash" then
  splashupdate()
 elseif mode == "round" then
  roundupdate()
 elseif mode == "gameover" then
  gameoverupdate()
 end

end

function titleupdate()
end

function splashupdate()
 if btnp(Ž) then
  mode = "title"
 elseif btnp(—) then
  music(-1)
 add(cors,cocreate(startnewround))
  mode = "game"
 end
end 

function gameupdate()
 update_particles() 
 update_players(p1)
 update_players(p2)
 do_hit_stuff()
 check_round_over()
end

function _draw()
 cls(13)
 
 
 draw_background()
 
 if mode == "game" or mode=="round" then
  draw_game()
  if mode == "round" then
    showwintext()
  end
 elseif mode == "title" then
  draw_title()
 elseif mode == "splash" then
  draw_splash()
 elseif mode == "gameover" then
  draw_gameover()
 end
end

function draw_all_p()
 draw_players(p1)
 pal(8,11)
 pal(2,3)
 pal(14,12)
 draw_players(p2)

end

function draw_game()
 draw_all_p()
 
 for c in all(cors) do
  if costatus(c) != 'dead' then
   coresume(c)
  else 
   del(cors, c)
  end
 end
 draw_particles()
 
 local b = gethitbox(p1)
 local c = gethitbox(p2)
 pal()
  
 draw_health()
end

function draw_background()
 --floor
 fillp(0b1110101101011011)
 rectfill(0,floor_top,128,128,118)
 fillp()
 
 line(0,floor_top+10,128,floor_top+10,7)
 line(0,floor_top+23,128,floor_top+23,7)
 line(0,floor_top+37,128,floor_top+37,7)
 line(15,floor_top,-15,128,7)
 line(29,floor_top,10,128,7)
 
 line(43,floor_top,31,128,7)
 line(57,floor_top,51,128,7)
 
 line(71,floor_top,77,128,7)
 line(85,floor_top,97,128,7)
 
 line(99,floor_top,118,128,7)
 line(114,floor_top,144,128,7)
 
 --altar
 fillp(0xd2)
 rectfill(40,floor_top-15,86,floor_top-1,130)
 fillp()
 line(40,floor_top-15,86,floor_top-15,8)
 
 rectfill(60,floor_top-18,68,floor_top-16,9)
 rectfill(63,floor_top-34,65,floor_top-19,10)
 rectfill(60,floor_top-30,68,floor_top-28,10)
  
end

function draw_health()
 local n1 = 1
 local length = 45
 local a1 = 81
 local y1 = 1
 local y2 = 6
 rect(n1,y1,n1+length,y2,7)
 local x2 = length*(p1.health/100)+n1-1

 if x2 > n1+1 then
  rectfill(n1+1,y1+1,x2,y2-1,8)
 end
 print("st.nick",n1+1,y2+2,7)
 
 rect(a1,y1,a1+length,y2,7)
 x2 = (length*(p2.health/100))+a1-1
 if x2 > a1+1 then
  rectfill(a1+1,y1+1,x2,y2-1,11)
 end
 
 print("arius",106,y2+2,7)
end

function check_pcls_hit()
 if #particles == 0 or 
  #pcls2 == 0 then return end
  
 if abs(particles[1][1] - 
  pcls2[1][1]) < 14 then
   add(smokes,{x=particles[1][1],y=particles[1][2]-10})	
   add(smokes,{x=particles[1][1]+3,y=particles[1][2]-5})	
   particles = {}
   pcls2 = {}
   p1canmakemorepcls= false
   p2canmakemorepcls= false
 end 

end

function do_pcl_hit(target,pcl,chain)
 assert(pcl[6] != nil)
 if pcl[6] == true then return end
 pcl[6] = true
 sfx(30)
 target.stun_timer = special_stun_time
 target.state = "stun"
 target.health -= 3 + chain*.5
end

function pcl_hits(target,pcl)
 if target.state == "crouch" or target.state == "walkrouch" then 
  return false
 end

 local hb = gethitbox(target)
 
 return pcl[1] >= target.x and pcl[1] <= hb.x2
end

function update_particles()
 if roundtextshowing then return end
 check_pcls_hit()
 
 local f = p1.pfrm
 local g = p2.pfrm

 
 if p1.state == "special" and f%6==0 and f < 15 and p1canmakemorepcls then
  local d = p1.flp and -1 or 1
  local flpo = p1.flp and -10 or 44
  --particle: {x,y,radius,direction, nothing, hasHit}
  add(particles,{p1.x+flpo,p1.y+5,2,d,null, false})
 end

 if p2.state == "special" and
  g%5==0 and g < 15 and p2canmakemorepcls then
  --pcls2: x, y, scale?, flip, something I don't know what is using this slot, hasHit
  add(pcls2,{p2.x+12, p2.y+6, 2, p2.flp and -1 or 1, null, false})
 end

 for a in all(particles) do
  a[1] += f * a[4]
  a[3] = flr(f/2)
  if a[1] > 138 or a[1] < -10 then
   if a[6] == false then
    p1.chain = 0
    p1.punchchain = 0
   end
   del(particles, a)
  end
  if pcl_hits(p2,a) then
   if a[6] == false then
    p2.chain = 0
    p2.punchchain = 0
    p1.chain += 1
    p1.punchchain = 0
    do_pcl_hit(p2,a, p1.chain)
  end
  end 
 end
 
 for a in all(pcls2) do
  a[1] += g * a[4]
  a[3] = flr(g/2)
  a[5] = flr(g*1.05)
  if a[1] > 138 or a[1] < -10 then
   if a[6] == false then
    p2.chain = 0
    p2.punchchain = 0
   end
   del(pcls2, a)
  end
  if pcl_hits(p1,a) then
   if a[6] == false then
    p2.chain += 1
    p1.chain = 0
    p1.punchchain = 0
    p2.punchchain = 0
    do_pcl_hit(p1,a, p2.chain)
   end
  end
 end

 
 
 for s in all(smokes) do
  s.y -= 1
  if s.y < -5 then
   del(smokes,s)
  end
 end


end

function draw_splash()
  -- camera(dx,0)
  cls(1)
  draw_background()
  put_sintext(txt0,25,3,'big')
  put_sintext(txt1,10,28,'big')

  put_sintext(txt0,25,3,'pixl')
  put_sintext(txt1,10,28,'pixl')

  oprint("a nextlevelbanana game",20,118,10)
 
  if anim_tick %30 > 10 then
   oprint("press — to start",30,92,8)
   oprint("or Ž for lore",36,100,11)
  end
end

function initsplash()
 titleangle = 0
 txt0=scan_text("creed")
 txt1=scan_text("fighter")  
end

function check_round_over()
 if p1.health <= 0 then
  p2wins += 1
  newround(p2)
 elseif p2.health <= 0 then
  p1wins += 1
  newround(p1)
 -- should there also be a timer?
 end
end

function newround(p)
 music(-1)
 mode = "round"
 winner = p.name
 if round == 3 or p1wins == 2 or p2wins == 2 then
  mode = "gameover"
  music(0)
  if p2wins > p1wins then
   winner = p2.name
   p2.state = "special"
   p1.state = "stun"
  else
   winner = p1.name
   p1.state = "special"
   p2.state = "stun"
  end
  add(cors,cocreate(dogameover))
 end
end

function resetroundstuff()
 round += 1
 particles = {}
 pcls2 = {}
 p1.health = 100
 p2.health = 100
 p1.stun_timer = 0
 p2.stun_timer = 0
 p1.chain = 0
 p1.punchchain = 0
 p2.punchchain = 0
 p2.chain = 0
 p1.x = -10
 p2.x = 100
 p1canmakemorepcls = true
 p2canmakemorepcls = true
end

function roundupdate()
 round_tick += 1
 if round_tick == 60 then
  resetroundstuff()
 end
 if round_tick > 60 then
	  add(cors,cocreate(startnewround))
   mode = "game"
   round_tick = 0
 end
end

function showwintext(col)
 if not col then col = 10 end
 wtxt=scan_text(winner)
 wtxt2=scan_text("wins")
 cls(13)
 draw_background()
 draw_all_p()
 
 put_sintext(wtxt,10,2,'big',col)
 put_sintext(wtxt2,10,28, 'big',col)
end

function startnewround()
 music(4)
 roundtextshowing = true
 for i=1,30 do
 p1.state = "special"
 p2.state = "special"
 wtxt=scan_text("round "..round)
 cls(13)
 draw_background()
 draw_all_p()
 
 put_sintext(wtxt,10,15,'big')
 put_sintext(wtxt,10,15,'pixl')
 yield()
 end
 roundtextshowing = false
 p1.state = "idle"
 p2.state = "idle"
 p1.pfrm = 0
 p2.pfrm = 0
 p1canmakemorepcls = true
 p2canmakemorepcls = true 
end

function draw_gameover()
 showwintext(p1wins > p2wins and 8 or 11)
 
 if p1wins > p2wins then
  draw_all_p() 
  draw_heaven_lines(p1.x + sprw(p1.lspr)*4)
  draw_hell_lines(p2.x + sprw(p2.lspr)*4)
 else
  draw_all_p() 
  draw_heaven_lines(p2.x + sprw(p1.lspr)*4)
  draw_hell_lines(p1.x + sprw(p2.lspr)*4)
 end

 oprint("press — or Ž to play again",8,88,7)
 
end

function draw_heaven_lines(midx)

  for i=midx-16,midx+16 do
  -- if rnd() > 0.5 then
    local col = rnd() > 0.3 and 10 or 7  
    line(i,-4,i,25+(rnd()*30),col)
 --  end
  end
end

function draw_hell_lines(midx)
 for i=midx-16,midx+16 do
  -- if rnd() > 0.5 then
    local col = rnd() > 0.3 and 8 or 9  
    line(i,130,i,108+(rnd()*30),col)
  -- end
  end
end

function gameoverupdate()
 if p1wins < p2wins then 
  p1.y += 1.5
  p2.y -= 1.8
 else
  p1.y -= 1.8
  p2.y += 1.5
 end
 if p1.y < 0 or p1.y > 128 then
  if btnp(—) or btnp(Ž) or btnp(—,1) or btnp(Ž,1) then
    _init()
  end
 end
end

function dogameover()
 
end
-->8
--players

function draw_players(p)
  animate(p)

--I don't know why I need this but I don't want to debug it any further
 if roundtextshowing then 
  p.state = "special" 
 end
 
 palt(10,true)
 local xoffset = 0
 local yoffset = 0
 local specialflp = true
 if p.state == "special" 
 and p.bspr == 187 then
  xoffset = -20
  yoffset = -1
  specialflp = false
 end
 spr(p.bspr, 
 getxpos(p.x+xoffset, p.bspr,
  p.state,p.flp,p.cosx,p.pfrm),
   getypos(p.y+yoffset, p.bspr,
    p.state,p.sinx), 
    sprw(p.bspr),sprh(p.bspr),
    p.flp and specialflp, p.state == "stun" or p.state == "knockback")
 spr(p.tspr, getxpos(p.x, p.tspr, p.state,p.flp,p.cosx,p.pfrm), getypos(p.y,p.tspr,p.state,p.sinx), sprw(p.tspr),sprh(p.tspr), p.flp)
 spr(p.lspr, getxpos(p.x, p.lspr, p.state,p.flp,p.cosx,p.pfrm), getypos(p.y, p.lspr, p.state,p.sinx), sprw(p.lspr),sprh(p.lspr, p.state),p.flp)

 spr(p.hspr, getxpos(p.x, p.hspr, p.state,p.flp,p.cosx,p.pfrm),getypos(p.y,p.hspr,p.state,p.sinx),2,p.hsprh, p.flp)
 if p.aspr == 187 and p.state == "special" and not p.flp then
  xoffset=-34
 else
  xoffset = 0
 end
 spr(p.aspr, getxpos(p.x+xoffset, p.aspr, p.state,p.flp,p.cosx,p.pfrm),getypos(p.y,p.aspr,p.state,p.sinx),sprw(p.aspr),sprh(p.aspr),p.flp, p.state == "stun" or p.state == "knockback")
 if p.state == "special" then
  drawspecialarms(p)
 end
pal()
end

function getxpos(x,sp,st,flp,cosx,pfrm)
 
if flp == nil then flp = false end

if st == "idle" or st == "special" then
  if sp == 0 or sp == 199 then --head
   if flp then return x+6 end
   return x + 13
  elseif sp == 2 then --arm
   if flp then return x + 10 + cosx end
   return x + 2 + cosx
  elseif sp == 9 then --sparm
   if flp then return x-9 end
   return x+7
  elseif sp ==187 then --sp2arm
   if flp==false then return x+34 end
   return x+22
  elseif sp == 38 or sp == 48 or sp == 51 then --torso
   if flp then return x+7 end
    return x+5 
  elseif sp == 40 then -- back arm
   if flp then return x + cosx end
    return x + 16 + cosx
  elseif sp == 96 then --legs
    return x - 2
  end

elseif st == "stun" or st == "knockback" then
 if sp == 0 or sp == 199 then --head
  if flp then return x+9 end
  return x + 11
 elseif sp == 187 then --arm
  if flp then return x + 22 end
  return x -2
 elseif sp == 48 then --torso
  if flp then return x+8 end
  return x+4 
 elseif sp == 96 then --legs
  return x - 2
 end

elseif st == "walk" then
  if sp == 0 or sp == 199 then --head
   if flp then return x+7 end
   return x + 13
  elseif sp == 2 then --arm
   if flp then return x +10 end
    return x + 2 + cosx
  elseif sp == 48 then --torso
   if flp then return x+8 end
    return x+5 
  elseif sp == 40 then -- back arm
    if flp then return x + cosx end
    return x + 16 + cosx
  elseif sp == 96 then --legs
   if flp==true then return x-1 end
    return x - 2
  elseif sp == 101 then
    if flp==true then return x-7 end
    return x - 4
  end
  
elseif st == "crouch" or st == "walkrouch" then
  if sp == 0 or sp == 199 then --head
   if flp then return x+10 end
   return x + 20
  elseif sp == 5 then --arm
   if flp then return x+3 end
   return x + 12
  elseif sp == 123 then -- torso
   if flp == true then return x+11 end    return x + 4
  elseif sp == 40 then -- back arm
   if flp then return x + 17 end
   return x + 6
  elseif sp == 176 or sp == 117 then --legs
   return x
  end

elseif st == "punch" then
  local sq = {2,3,3,4,4,3}
  local sq2 = {2,8,8,13,13,8}
    local sq3 = {2,13,13,21,21,13}
  local sq4 = {2,-2,-2,-3,-3,-2}
  local m = flp and -1 or 1
  if sp == 0 or sp == 199 then --head
   if flp then return x end
    return x+15 + sq[pfrm]*m
  elseif sp == 2 or sp == 5 or sp == 9then -- arm
    local xoff = flp and -4 or 0 
    return x + sq3[pfrm]*m + xoff
  elseif sp == 96 or sp == 176 or sp == 43 or sp == 101 then --legs
   if flp then return x-2-sq[pfrm] end
   return x - 2 + sq2[pfrm]
  elseif sp == 48 or sp == 51 
  or sp == 38 then --torso 
   if flp then return x+7-sq[pfrm] end
   return x+5 + sq2[pfrm]
  elseif sp == 40 then -- back arm
   if flp then return x +sq4[pfrm] end
    return x + 16 + sq4[pfrm]
  end
 end
end

function getypos(y,sp,st,sinx)
  if st == "idle" or st == "special"  then
  if sp == 0 or sp == 199 then --head
   return y + sinx
  elseif sp == 2 then  -- arm
    return y+13+sinx
  elseif sp == 48 or sp == 51 then --torso
    return y + 10 + sinx
  elseif sp == 40 then -- back arm
     return y+8+sinx
  elseif sp == 96 or sp == 101 then -- legs
    return y + 32
  elseif sp == 9 then-- special arm
   return y+13
  elseif sp == 187 then --special2
   return y-12
  end
  
 elseif st == "stun" or st == "knockback" then
 if sp == 0 or sp == 199 then --head
  return y
 elseif sp == 187 then --arm
  return y+13
 elseif sp == 48 then --torso
  return y+11
 elseif sp == 96 then --legs
  return y+32
 end
 
 elseif st == "walk" then
  if sp == 0 or sp == 199 then --head
   return y + sinx
  elseif sp == 2 then  -- arm
    return y + 13 + sinx
  elseif sp == 48 then --torso
    return y+10+sinx
  elseif sp == 40 then -- back arm
    return y+5+sinx
  elseif sp == 96 or sp == 101 then -- legs
  return y + 32
  end
 elseif st == "crouch" or st == "walkrouch" then
  if sp == 0 or sp == 199 then --head
   return y + 18 + sinx
  elseif sp == 5 then  --arm
   if flp==true then return y+25 + sinx end
    return y + 27 + sinx
  elseif sp == 123 then --torso
    return y + 23 + sinx
  elseif sp == 40 then -- back arm
    return y+ 29 + sinx
  elseif sp == 176 or sp == 117 then --legs
    return y + 44 + sinx
  end
  elseif st == "special" then
   return y+15
 elseif st == "punch" then
  if sp == 0 or sp == 199 then --head
    return y+2
  elseif sp == 2 or sp == 5 or sp == 9 then -- arm
    return y + 13
  elseif sp == 96 or sp == 43 or sp == 101 then --legs
   return y + 32
  elseif sp == 48 or sp == 51 
  or sp == 38 then --torso
   return y + 12
  elseif sp == 40 then -- back arm
    return y+13
  elseif sp == 176 then
    return y + 40
  end
 end
end

function update_players(p)
 if roundtextshowing then 
  p.state = "special"
  return 
 end
 assert(roundtextshowing == false)

 if p.state == "stun" then 
  p.stun_timer -= 1
  if p.stun_timer <= 0 then
   p.state = "idle"
  end
  return 
 end

 if p.state == "knockback" then 
  p.x += p.speed
  p.speed *= 0.3
  if abs(p.speed) < 0.1 then
   p.state = "idle"
  -- p.y = 40
  end
  return
 end
 
 if p.state == "punch" 
 or p.state == "special" then
  check_hit(p)
  return 
 end
 
 if btn(1,p.num) then --‘
  if(btn(3,p.num)) then
    p.state="walkrouch"
   else
    p.state = "walk"
  end
  p.dir = "right"
 elseif btn(0,p.num) then --‹
 if(btn(3,p.num)) then
    p.state="walkrouch"
   else
    p.state = "walk"
  end
  p.dir = "left"
 elseif btn(3,p.num) then --ƒ
  p.state = "crouch"
 elseif btnp(4,p.num) then --Ž
  if p.state != "punch" then
   anim_tick = 0
   p.pfrm = 1
   p.state = "punch"
  end
 elseif btnp(5,p.num) then
  if p.num == 0 then
   particles = {}
  else
   pcls2 = {}
  end
  p.state = "special"
  if p == p1 then 
   sfx(31)
  else
   sfx(32)
  end
 else
  if p.state != "punch" and p.state != "special" then
   p.state = "idle"
  end
 end
 
 if p == p1 then
  p.flp = p.x > p2.x
 else
  p.flp = p.x > p1.x
 end
 
 p.sinx = sin(t())+1
 p.cosx = cos(t())

 if p.state == "walk" or p.state == "walkrouch" then
  if p.lspr == 101 or p.lspr == 117 then
   p.sinx = 1
  else
  p.sinx = 0
  end
  if canwalk(p) then
   if p.dir == "right" then
    p.x += walkspd
   else
    p.x -= walkspd
   end
  end
 elseif p.state == "crouch" then
  p.sinx = 0
 end
end

function canwalk(p)
 local mult = p.dir == "right" and 1 or -1
 local goal = p.x + mult*walkspd
 if p.x < -16 or p.x > 110 then return true end -- got punched offscreen
 return goal > -16 and goal < 110
end

function drawspecialarms(p)
 pal()
 if p.num == 0 then
  local flpo = p.flp and -7 or 30
  spr(185,p.x+flpo,p.y-1,2,4,p.flp)
 end
end

function draw_particles()
 for p in all(particles) do
  local c1 = p[4] > 0 and 10 or 7
  local c2 = p[4] > 0 and 7 or 10
   for i=1,p[3] do
   circfill(p[1]-i*p[4],p[2],2,p[4] > 0 and c1 or c2)
   circfill(p[1]+i*p[4],p[2],3,p[4] > 0 and c2 or c1)
   end
  end
  
 for p in all(pcls2) do
  pal(3,5)
  sspr(14*8,0,8,8,p[1]-1,p[2]-1,p[5],p[5])
  sspr(14*8,0,8,8,p[1]+1,p[2]+1,p[5],p[5])
  pal(3,7)
  sspr(14*8,0,8,8,p[1],p[2],p[5],p[5])
 end

 for s in all(smokes) do
  local r = 2
  if s.y < 30 then
   r = 1
  end
  circ(s.x + sin(t()), s.y,r,5)
 end


end
-->8
--animate player
function animate(p)
 local st = p.state
 if st == "knockback" then st = "stun" end

 local f = p.pfrm
  if st == "punch" then
    p.pfrm += 1
   if p.pfrm > 6 then
    reset_state(p)
   end
   
  elseif st == "special" then
   p.pfrm += 1
   if f > 30 then
    reset_state(p, true)
   end
  end
  
  p.lspr = getspr(p.lsprs,st,p.pfrm)
  p.tspr = getspr(p.tsprs,st,p.pfrm)
  p.aspr = getspr(p.asprs,st,p.pfrm)
  p.bspr = getspr(p.bsprs,st,p.pfrm)
end

function getspr(tbl,st,frm)
 if st == "punch" then
  return tbl[st][frm]
 end
 local idx = flr(anim_tick/3)%#tbl[st]+1
 return tbl[st][idx]
end

function reset_state(p, isspecial)
 p.pfrm = 1
 p.state = "idle"
 
 if isspecial then
  if p == p1 then
    p1canmakemorepcls = true
  else
    p2canmakemorepcls = true
  end
 else
  other(p).was_hit = false
 end
end

-->8
-- make player
function make_players()
p1 = {
 speed = 0,
 was_hit = false,
 stun_timer = 0,
 health = 100,
 pfrm = 1,
  cosx = 0,
  sinx=0,
 num = 0,
 hspr = 0,
 hsprh = 2,
 lsprs = {
  idle = {96},
  walk = {96,101},
  crouch = {176},
  walkrouch = {176,117},
  punch={96,43,43,43,43,43},
  special={96},
  stun={96}
 },
 tsprs = {
  idle = {48},
  walk = {48},
  crouch = {123},
  walkrouch = {123},
  punch = {48,38,38,38,38,51},
  special={48},
  stun={48}
 },
 asprs = {
  idle = {2},
  walk = {2},
  crouch = {5},
  walkrouch = {5},
  punch = {2,5,5,9,9,5},
  special = {9},
  stun = {187}
 },
 bsprs = 
 {
  idle = {40},
  walk = {40},
  crouch = {40},
  walkrouch = {40},
  punch = {40,40,40,40,40,40},
  special={9},
  stun = {187}
 },
 
 x = -10,
 y = 40,
 state = "idle",
 flp = false,
 chain = 0,
 punchchain = 0,
 name = "st.nick"
}

p2 = {
 speed = 0,
 name="arius",
 chain = 0,
 punchchain = 0,
health = 100,
 pfrm = 0,
  cosx = 0,
  sinx = 0,
num = 1,
 hspr = 199,
 hsprh = 3,
 lsprs = {
  idle = {96},
  walk = {96,101},
  crouch = {176},
  walkrouch = {176,117},
  punch={96,43,43,43,43,43},
  special={96},
  stun={96}
 },
 tsprs = {
  idle = {48},
  walk = {48},
  crouch = {123},
  walkrouch = {123},
  punch = {48,38,38,38,38,51},
  special={48},
  stun={48}
 },
 asprs = {
  idle = {2},
  walk = {2},
  crouch = {5},
  walkrouch = {5},
  punch = {2,5,5,9,9,5},
  special = {187},
  stun = {187}
 },
 bsprs = 
 {
  idle = {40},
  walk = {40},
  crouch = {40},
  walkrouch = {40},
  punch = {40,40,40,40,40,40},
  special={187},
  stun = {187}
 },
 
 x = 100,
 y = 40,
 state = "idle",
 flp = true,
 was_hit = false,
 stun_timer = 0
}
end

-->8
--utils
function sprh(s)
--torso, back arm
 if s == 48 or s == 40 or s == 51 or s == 38 then
  return 3
 elseif s == 176 or s == 117 then
  return 4
 elseif s == 96 or s == 187 or s == 101 or s == 43 then
  return 5
--front arm, back arm
 elseif s == 2 or s == 40 or s == 123 then
  return 3
 elseif s == 5 or s == 9 then -- front arm
  return 2
  
 end
 
end

function sprw(s)
--torso
 if s == 48 or s == 51 or s == 2 or s == 40 then
  return 3
--legs
 elseif s == 96 or s == 9 then
  return 5
 elseif s == 101 or s == 176 or s ==117 then
  return 6
 elseif s == 123 or s == 5 or s == 43 then -- legs, arm
  return 4
 elseif s == 38 or s == 187 then
  return 2
 end
end

function other(p)
 return p == p1 and p2 or p1
end

function gethitbox(p)
 -- x1 is always p.x
 local box = {
 y1 = 0,
 x2 = 0,
 y2 = 0
 }
 if p.state != "crouch" then 
  box.y1 = p.y
  box.y2 = p.y + 32 + 8*sprh(p.lspr, p.state)
 else
  box.y1 = p.y + 18
  box.y2 = p.y + 44 + 8*sprh(176, p.state)
 end
 
 local xoff = p.flp and 0 or 16
 if p.state == "punch" then
  box.x2 = p.x + 4+ 8*sprw(p.aspr) + xoff
 else
  box.x2 = p.x + 8*sprw(p.bspr)+10 + xoff
 end
 
 return box

end

function scan_text(text)
   cls()
   scan={}
   print(text,0,0,1)
   for x=0,(#text)*4 do
     scan[x]={}
     for y=0,6 do
       scan[x][y]=pget(x,y)
     end
   end
   cls()
   return scan
 end

 function put_sintext(text,x,y,effect, col, col2)
  if not col then col = 7 end
  if not col2 then col2 = 0 end
  local a=sin(titleangle)*6
  local i,j
  for i=0,#text do
   for j=0,6 do
    if text[i][j]==1 then
     -- if (effect=='circ') then circfill(i*4+x, j*4+y,3,10) --(i+j)%3+12)
    if (effect=='pixl') pset(i*4+x+2, j*4+y+2,(i+j)%3+8)
    if (effect=='big')  then
     rectfill(i*4+x,j*4+y, i*4+x+5, j*4+y+4,col)
     rect(i*4+x,j*4+y, i*4+x+5, j*4+y+4,col2)
    end
   end
  end
  end
   titleangle+= 0.00243
   if (titleangle>1) titleangle=0

 end
 
function oprint(s,x,y,col)
 for i=0,2 do
	 for j=0,2 do
	  if not(i==1 and j==1) then
	   print(s,x+i,y+j,0)
	  end
	 end
	end
	print(s,x+1,y+1,col)
end
-->8
--title

function titleupdate()
 if btnp(—) or btnp(—,1)then
  music(-1)
  add(cors,cocreate(startnewround))
  mode = "game"
  return
 end
 if anim_tick%35 ==0 then
  lines_drawn+=1
 end
end

function draw_title()
 rect(2,2,125,4+9*lines_drawn,4)
 rectfill(3,3,124,3+9*lines_drawn,15)
 for i=1,lines_drawn do
  local ln = (intro[i] == nil) and " " or intro[i]
   print(ln,4,8*i-3,4)
 end
 if (anim_tick %30 > 15) then
  print("—",105,121,0)
  print("—",105,119,0)
  print("—",105,120,0)

  print("—",103,121,0)
  print("—",103,119,0)
  print("— >>>",103,120,0)

  print("—",104,120,8)
 end
end
-->8
-- hit stuff
function check_pcl_hit(pcl)
 return false
end

function check_hit(p)
 local o = other(p)
 local ohb = gethitbox(o)
 if p.state == "punch" and not o.was_hit then
  --only check for collisions at full extension
  if p.pfrm > 3 and p.pfrm < 6 then
   if o.state != "crouch" and o.state != "walkrouch" then
    local px2 = gethitbox(p).x2
    if mid(p.x,ohb.x2,o.x) == p.x or
     mid(px2,ohb.x2,o.x) == px2 then
      --it's a hit!
      sfx(30)
      other(p).was_hit = true
      other(p).stun_timer = punch_stun_time 
      other(p).state = "stun"
      p.chain += 1
      other(p).chain = 0
      other(p).punchchain = 0
      take_damage(other(p),"punch",p.chain)
      p.punchchain += 1
      knockback(p)
    end 
   end 
  end 

  if p.pfrm == 6 then
  --attack avoided, combo breaker
   p.chain = 0
   p.punchchain = 0
  end
 end --state is punch and not hit
 
end

function do_hit_stuff()
 do_stun(p1)
 do_stun(p2)
end

function knockback(p)
 if p.punchchain > 0 and p.punchchain % 3 == 0 then
  other(p).state = "knockback"
  local d = other(p).flp and 1 or -1
  other(p).speed = 15 * d
 end
end
function do_stun(p)
 if p.state != "stun" then return end
 
 p.stun_timer = max(p.stun_timer - 1, 0)
 if p.stun_timer == 0 then
  p.state = "idle"
 end
end

function take_damage(p,kind,chain)
 if kind == "punch" then
  p.health -= 2+(1.5*(chain-1))
 end
end
__gfx__
06666666666000000000002222000000000000000000022220000000000000000000000000222222200000000000000000004444440000000033300000000000
66677777766000000000228888200000000000000000288882000000000000000000000002888888820000000022222224444fffff4000000303030000000000
67777766644400000002288888820000000000000002888888200000000000000000000002888888882222222288888882ffffffff4000000333330000000000
677776ffffff40000002888888820000044444400002888888820000000044444400000002888888888888888888888882fffff44f4000000033300000000000
6777776ffffff400002888888822222244fff4f4002288888882000022244fffff4000002888888888888888888888882ffffff4ff4000000000000000000000
6777776ffffff4000028888822888882fff444f40028888882222222882fffffff4000002888888888888888888888882ffffff4440000000330330000000000
6774466f444444000028888288888882fffffff40028882222888888882ffff44f40000028888888888888888888888824444440000000000003000000000000
674ff467147144000028882288888882fffffff40288822888888888882ffff4ff40000028888888888888888888888820000000000000000330330000000000
6764f6ffff4ff4000288822888888882fffffff40288228888888888882ffff444000000028888888888888888888882aaaaaaaaaaaaaaaa0000000000000000
0664476ffff4f4000288228888888882fffffff428888888888888888824444000000000002888888888888888888882aaaaaaaaaaaaaaaa0000000000000000
0006776fff44f400288228888888888224ffff4028888888888888888820000000000000000288888888888888888882aaaaaaaaaaaaaaaa0000000000000000
00066776f666660028888888888888882044440028888888888888888820000000000000000022222222222222222220aaaaaaaaaaaaaaaa0000000000000000
000066776777660028888888888888882000000028888888888888882200000000000000000000000000000000000000aaaaaaaaaaaaaaaa0000000000000000
000006776766600028888888888888882000000028888888888888220000000000000000000000000000000000000000aaaaaaaaaaaaaaaa0000000000000000
000000677677600028888888888888882000000028888888888822000000000000000000000000000000000000000000aaaaaaaaaaaaaaaa0000000000000000
000000066666000022888888888888882000000002222222222200000000000000000000000000000000000000000000aaaaaaaaaaaaaaaa0000000000000000
aaaaaaaaaaaaaaaa0022888888822222aaaaaaaaaaaaaaaa00002fffffff40000000000000000000aaaaaaaa000000000000000000000000aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa0000222222200000aaaaaaaaaaaaaaaa000552ffffff40000000000000000000aaaaaaaa000000000000000088800000aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa0000000000000000aaaaaaaaaaaaaaaa0556652fffff40000000222000000000aaaaaaaa000000222888888888866500aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa0000000000000000aaaaaaaaaaaaaaaa0267765fffff44000002288200000000aaaaaaaa000000228888888888866500aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa0000000000000000aaaaaaaaaaaaaaaa02867765fffff4000002888820000000aaaaaaaa000000288888888888866500aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa0000000000000000aaaaaaaaaaaaaaaa028867765fffff500028888820000000aaaaaaaa000000288888888888866500aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa0000000000000000aaaaaaaaaaaaaaaa02888676655555500228888882000000aaaaaaaa000002288888888888866500aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa0000000000000000aaaaaaaaaaaaaaaa02888677766666500288888882000000aaaaaaaa000002888888888888866500aaaaaaaaaaaaaaaa
00000000022ffffffff40000000000002fffffff40000000288888677777776502888888820000000000000000002288888828888888665500000000aaaaaaaa
00000055522ffffffff400000000000022ffffff44000000288888867777767502888888820000000000000000002888888882288888676650000000aaaaaaaa
000055666522ffffffff40000000005552fffffff4000000288888867777767502888888882000000000000000002888888888222888676665000000aaaaaaaa
0002566776552ffffffff50000005566652ffffff4000000888888886777677522888888882222220044444000002888888888882288867665000000aaaaaaaa
00022677776522fffffff550000256777652fffff44000008888888886777765288888888222888824fff4f400028888888888888228866766500000aaaaaaaa
002288677776552fffff56550002267777655fffff500000288888888677767528888888228888882ff4f44400028888888888888828888666500000aaaaaaaa
028888677777765255555665000288677776655555555000288888888867765028888888288888882ff444f40002888e888888888888888885000000aaaaaaaa
228888867777777666666765000288867777766666676500288888888886665028888888888888882ff44f440002888ee88888888888888882220000aaaaaaaa
288888866777777777776652000288867777777777665200288888888888860022888888888888882fff44440002888eee8888888888888882222000aaaaaaaa
288888886677777777767520002888866777777776752000288888888888860002888888888888882fff4ff40002888eeeeeee888888888888882200aaaaaaaa
288888888677777777767520002888886677777776752000288888888888860002888888888888882ffff444000288888eeeeee88888888888888200aaaaaaaa
288888888667777777677520002888888677777767752000288888888888860002288888888888882444440000028882888eeeeee888888888888220aaaaaaaa
28888888886777777777652002888888867777777765200002888888888886000028888888888888200000000002888228888eeeee88888888888820aaaaaaaa
288888888866777777767520288888888867777776652000028888888888860000228888888888882000000000002888228888eeeee8888888888820aaaaaaaa
2888888888866777777652202888888888677777765220000288888888888600000222888888888220000000000028882228888eeee8888888888822aaaaaaaa
2888888888886777766752002888888888677776665200000000088800000000000022222222222000000000000228888222888eeeee888888888882aaaaaaaa
288888888888666666775000288888888886666675000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0022888882228888eeee888888888882aaaaaaaa
288888888888888677752000288888888888867715000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0028888882228e88eeeee88888888882aaaaaaaa
288888888888888671752000288888888888866715000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0028888822288e888e8ee88888888882aaaaaaaa
288888888888888671752000288888888888886615000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00288882228888e88e88e88888888882aaaaaaaa
288888888888888671150000288888888888888615000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00288822888888e88888e88888888882aaaaaaaa
288888888888888611750000288888888888888615000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00288888888888888888e88888888882aaaaaaaa
288888888888888671750000288888888888888615000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00288888888888888888888888888882aaaaaaaa
000000000000000000000000288888888888888615000000aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa00022228888888888888888888888882aaaaaaaa
00000000000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000044ff222222888888888888222222000000000
00000028888888888888886717500000aaaaaaaa0000000028888888888888886717500000000000000000000042ffffff40022288888882222ff44000000000
00000028888888888888886717500000aaaaaaaa00000000288888888888888867175000000000000000000000282ffff4000000222222244fffff2220000000
00000028888888888888886717500000aaaaaaaa0000000028888888888888886717500000000000000000000288822222000000000000024ff2228222000000
00000028888888888888886717500000aaaaaaaa0000000288888888888888886717500000000000000000002888888882220000000000282222888822200000
00000288888888888888886717500000aaaaaaaa0000000288888888888888886771500000000000000000002888888888822000000000288888888888220000
00000288888888888888886777500000aaaaaaaa0000000288888888888888888677155000000000000000000222888888888200000000288888888888820000
00002888888888888888886677650000aaaaaaaa0000002888888888888888888886776550000000000000000000222222222000000000022222222222220000
00028888888888888888888677750000000000000000022888888888888888888888666665000000000000000000000000000000000000000000000000000000
00028888888888888888888677765000000000000000028888888888888888888888886666520000000000000000000000000000000000000000000000000000
00028888888888888888888867776500000000000000288888888e88888888888888888888822000000000000000000000000000020000000000000000000000
0002888888888888888888886777765000000000000228888888ee88888888888888888888882200000000000000000000000055552000000000000000000000
0028888888888888888888888667777500000000000288888888e888888888888888888888888220000000000000000000555566665200000000000000000000
00288888888888e8888888888866666220000000002288888888e888888888888888888888888822000000000000000002225667776520000000000000000000
00288888888888ee88888888888888888200000000288888888ee888888888888888888888888882200000000000000028882677777652000000000000000000
002888888888888e8888888882288888882000000288888888ee8888888888888888888888888888220000000000000028888867777765555555550000000000
0288888888888888e88888888222888888220000028888888ee88888888888888888888888888888820000000000000288888886777777666666765000000000
0288888888888888e8888888882288888882000002888888eee88888888888888888888888888888822000000000000288888886777777777776652000000000
0288888888888888e888888888222888888820000288888ee8e88888888888888888882888888888882200000000002288888888667777777767520000000000
0288888888888888e88888888822288888882000028888ee88e88888888888888888888288888888888220000000002888888888866777777767520000000000
00288888888888888e88888888822888888820000288888888e88888888888888888888222888888888820000000002888888888886777777677520000000000
00288888888888888e8888888882228888888200028888888ee88888888888888888888822288888888820000000002888888888886777777776520000000000
02888888888888888e8888888888228888888200028888888e888888888888888888888822228888888820000000002888888888888777777766520000000000
28888888888888888e8888888888222888888820028888888e888888888888888888888882228888888820000000022288888888888677777765220000000000
28888888888888888e88888888882228888888200288888888888888888888888888888882288888888820000000022228888888888677776665200000000000
2888888888888888e888888888882228888888200288888888888888888888888888888822888888888820000000222222888888888666666750000000000000
2888888888888888e888888888822228888888200028888888888888888888888888888888888888888820000002288222888888888888677150000000000000
288888888888888e8888888888822288888888200042288888888888888888888888888888888888888220000002888888888888888888676150000000000000
288888888888888e888888888882228888888820004f222888888888888888888888888888888888882200000028888888888888888888676150000000000000
2888888888888888888888888822888888888820004fff2288888888888888888888888888822222220000000228888888888888888888666665000000000000
0222288888888888888888888828888888888820004ffff22228888888888888888888222222fffff40000000288888882228888888886667766500000000000
04fff22222288888888888888888888222222200004ffffff42222222222222222222220004ffffff40000002288888888222288888866676666500000000000
44ffffff400222888888888888882222ff44000004ffffff40000000aaaaaaaaaaaaaaaa0004fffff40000000000000000000000000000000000000000000000
4fffffff4400002228888888222244fffff2220004fffff400000000aaaaaaaaaaaaaaaa00004fffff4000000000000000000000000000000000000000000000
4f222222f40000000222222200002fff2228882004fffff400000000aaaaaaaaaaaaaaaa00004fffff2200000000000000000000000000000000000000000000
222888822200000000000000000082228888888202222ff220000000aaaaaaaaaaaaaaaa00024fffff2222220000000000000000000000000000000000000000
28888888882000000000000000028888888888822888222220000000aaaaaaaaaaaaaaaa00222222222888820000000000000000000000000000000000000000
28888888882000000000000000028888888888822888888820000000aaaaaaaaaaaaaaaa00288888888888220000000000000000000000000000000000000000
02222222220000000000000000002222222222202222222220000000aaaaaaaaaaaaaaaa00222222222222200000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000aaaaa0000000000000000000000000000000000000000000
0000288888888888888888888886667776220000000000000000000000000000000000000000000af77f4a000000044444400000000000000000000000000000
000228888888888882888888888888666762200000000000000000000000000000000000000000af7ff44a0000004f4f4f440000000000000000000000000000
00028888888888882888888888288888666822000000000000000000000000000000000000000af7f4444a0000004f4f4f4f4000000000000000000000000000
0022888888888888288888888882288888668220000000000000000000000000000000000000aaff44474a0000004fffff4f4000000000000000000000000000
0028888888888888888888888888888888888822000000000000000000000000000000000000aa4474474a0000004fffffff4000000000000000000000000000
0288888888888888888888888888888888888882200000000000000000000000000000000000aaa447744a00000004fffff40000000000000000000000000000
028888888888888e888888888888888888888888220000000000000000000000000000000000aaa444744a000000044ff4400000000000000000000000000000
028888888888888ee88888888888888888888888822000000000000000000333333000000000aa4444744a00000004ffff400000000000000000000000000000
028888888888888ee88888888888882888888888882200000000000000333bbbbb3300000000aa4444774440000004ffff400000000000000000000000000000
028888888888888eee8888888888888288888888888200000000000003bbbbbbb33300000000aaa447474ff40000022222220000000000000000000000000000
028888888888888eee888888888888822288888888822000000000003bbbbbb33ff400000000aaa447444ff40000288888882000000000000000000000000000
02888888888888eeee888888888888882228888888882000000000003bbbb33fffff40000000aa4444444ff40000288888882000000000000000000000000000
0288888888888eeeee888888888888882222888888882000000000003bbb36ffffff40000000aaa444744ff40002888888882000000000000000000000000000
028888888888ee8ee8888888888888888222888888882000000000003b4436f4444440000000aaa447474ff40002888888882000000000000000000000000000
02888888888ee88e888888888888888882228888888820000000000034ff4671471400000044aaa447474ff40002888888882000000000000000000000000000
028888888888888e8888888888888888222888888888200000000000334f5ffff4f40000024faa4f47744f400002888888882000000000000000000000000000
002888888888888e8888888888888888888888888888200000000000034465ffff4f400002ff444f474444000002888888882000000000000000000000000000
00422888888888e88888888888888888888888888882200000000000005665fff44f400002ffffff47444a000002888888882000000000000000000000000000
004f22288888888888888888888888888888888888220000000000000055665f5555550002ffffff47444a000002888888882000000000000000000000000000
004fff22888888888888888888888888888222222200000000000000000556656666650002ffffff47444a000002888888882000000000000000000000000000
004ffff22288888888888888888888222222fffff400000000000000000056666555500002ffffff44444a000002888888882000000000000000000000000000
004ffffff42222222222222222222220004ffffff4000000000000000000566666665000824ffff44444a0000002888888882000000000000000000000000000
04ffffff4000000000000000000000000004fffff40000000000000000005666666650008204444444aa00000002888888882000000000000000000000000000
04fffff400000000000000000000000000004fffff4000000000000000005666666650000000aaaaaa0000000002888888882000000000000000000000000000
02222ff200000000000000000000000000024fffff22222000000000000056666666500000000aaa000000000002888888882000000000000000000000000000
28888228200000000000000000000000002222222288888200000000000056666666500000000000000000000002888888888200000000000000000000000000
28888888200000000000000000000000002888888888888200000000000056666666500000000000000000000002888888888800000000000000000000000000
02222222000000000000000000000000000222222222222000000000000056666666500000000000000000000002888888888800000000000000000000000000
00000000000000000000000000000000000000000000000000000000000005666665000000000000000000000002888888888800000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000566665000000000000000000000002888888888800000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000055550000000000000000000000002888888888800000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288888888800000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028888888800000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002888800000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222200000000000000000000000000000
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
001600002105500000210550000024055000002105500000260550000021055000002805500000260550000024055000002405500000280550000024055000002b05500000240550000028055000002405500200
001600001f055000001f0550000023055000001f0550000024055000001f05500000260550000024055000001d055000001d0550000021055000001d0550000024055000001d0550000024055000002305500000
001600000b6710b6710b6710b6110b6110b6110b61500000000000000000000000000000000000000000000002671026710267102611026110261102615000000000000000000000000000000000000000000000
001200000967109671096710961109611096110961109615097000970009700097000970009700097000970000000000000000000000000000000000000000000000000000000000000000000000000000000000
001200002175500000000002175500000000002175500000000002175500000000001f7550000024755007002175500700007002175500700007002175500700007002175500700007001f755007001c75500000
001200002175500000000002175500000000002175500000000002175500000000001f75500000247550000021755000000000021755000000000021755000002175521755007002175521755000000000000000
001200001c75500000000001c75500500000001c75500000000001c75500000000001c755000001c755000001c75500000000001c75500500000001c755000001c5551c555000001c5551c555000000000000000
0012000021755287550070021755247550070021755227550070021755247550070022755007001f7550070021755287550070021755247550070021755227550070021755247550070022755007001f75500000
0012000021555285550000021555245550000021555225550000021555245550000022555000001f555000002d5550000000000285550000000000265550000000000000002e555000002d555000000000000000
0012000021755287550000021755247550000021755227550000021755247550000022755000001f755000002d7550000000000287550000000000267550000000000000002e755000002d755000000000000000
001200002d55500000000002855500000000002655500000000002e555000002d555000000000000000000002d555000000000028555000000000026555000000000000000000000000000000000000000000000
001200002176500700217650070024765007002176500700267650070021765007002876500700267650070024765007002476500700287650070024765007002b75500700247650070028765007002476500000
001200001f755007001f7550070023755007001f7550070024755007001f75500700267550070024755007001d755247051d7552470521755247051d7550070024755007001d7550070024755007002375500000
001200002155500000000002155500000000002155500000000002155500000000001f5550000024555000002155500000000002155500000000002155500000000002155500000000001f555000001c55500000
001200000955500000000000955500000000000955500000095550000009555000000000009555000000000009555000000000009555000000000009555180000955518000095550000000000095550000000000
001200000955500000000000955500000000000955500000000000755500000000000955500000000000955500000000000955500000000000000009555000000000000000000000000000000000000000000000
00160000000000000000000000000b0410b0310b0210b015000000000010605000000000000000000000000000000000000e0410e0310e0210e0210e0210e0110000000000000000000000000000000000000000
001200001c75500000000001c75500500000001c75500000000001c75500000000001c755005001c755000001c75500000000001c75500500000001c75500000000001c75500000000001c755005001c75500000
001200000055500000000000055500000000000055500000005550000000555000000000000555000000000000555000000000000555000000000000555000000055500000005550000000000005550000000000
001200000055500000000000055500000000000055500000005550000000555000000000000555000000000000555000000000000555000000000000555000000055500000005550000000000005550000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000336502f650286501b65012650046500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000027720277202f7002772027720277202f7002772027720277202c5002e4000050000500005002c5002c5002c5002c5002c4002c4000000000000000000000000000000000000000000000000000000000
000300000b0500b0500605005010050500505005010080500d0500f05012000130001c00016000160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 01 42 43 44
02 02 42 43 44
00 01 11 43 44
02 02 11 43 44
01 05 42 43 44
00 06 42 43 44
00 05 12 43 44
00 06 07 43 44
00 08 0f 43 44
00 0a 0f 43 44
00 08 0f 13 44
00 08 0f 14 44
00 0c 42 43 44
00 0d 42 43 44
00 0c 42 43 44
02 0d 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
