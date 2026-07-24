pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--apodynia
--ver 1.18.10.19.01

function _init()
 cls()
 state=1
 act={} pbul={}
 sparkles={} explo={}
 fric=0.9
 score=0
 frameclock=0 mapclock=0 deadbossclock=0
 make_player() lives=3 invuln=false
 stage=1 boss=false
 chatera=0 firsttalk={false,false,false,false}
 deadboss={false,false,false}
 bees={} spipos=0 webhp=0
 music(26)
end

function make_player()
 p=make_act(64,110,1,0,0)
 p.kind=1
 p.dy=-3
 p.hp=3
 invuln=true
 powerup=0
end

function make_act(x,y,s,dx,dy)
 local n={}
 n.x=x n.y=y n.s=s
 n.kind=2
 n.dx=dx n.dy=dy
 n.ddx=0.25 n.ddy=0.25
 n.tx=4 n.ty=4
 n.hp=1 n.pow=1
 n.movetype=1
 n.shoottype=0
 n.size=1 n.score=1
 n.shape=""
 n.flipx=false n.flipy=false
 n.inpos=0
 
 if n.s==3 then
  n.hp=2
 elseif n.s==5 then
  n.shoottype=1
  n.hp=5 n.score=3
 elseif n.s==1005 then
  n.s=5
  n.shoottype=1
  n.hp=7 n.score=3
  n.movetype=4
  n.movemode=0
 elseif n.s==1999 then
  n.shoottype=999
  n.hp=55
  n.movetype=4
  n.movemode=1
 elseif n.s==19 then
  n.shoottype=2
  n.movetype=3
  n.size=2
  n.hp=20
  n.score=10
 elseif n.s==51 then
  n.movetype=2
  n.hp=3 n.score=2
 elseif n.s==25 then
  n.shape="long"
  n.hp=5
  n.score=2
 elseif n.s==136 then
  n.shape="wide"
  n.hp=4
 elseif n.s==11 then
  n.size=2
  n.hp=26
  n.score=20
  n.shoottype=3
 elseif n.s==43 then
  n.size=2
  n.hp=8
 elseif n.s==140 then
  n.movetype=7 n.cx=x n.cy=y
  n.shoottype=4
  n.hp=10
  n.size=2 n.score=10
 elseif n.s==134 then
  n.hp=10 n.score=5
 elseif n.s==224 then
  n.shoottype=8
  n.movetype=6 n.movemode=0
  n.size=2
  n.hp=22
  n.score=10
 elseif n.s==192 then
  n.size=2 n.hp=5
 elseif n.s==236 then
  n.size=2 n.hp=8
  n.movetype=2 n.score=5
    
 elseif n.s==90 then
  n.size=3
  n.hp=300
  n.movetype="w" n.turnrad=1.375
  n.sspd=1.33
  boss=true n.score=100
  check_chat()
 elseif n.s==144 then
  n.size=3
  n.hp=300
  n.movetype=5
  boss=true n.score=200
  check_chat()
 elseif n.s==150 then
  n.size=3 n.shape="huge"
  n.hp=500
  n.movetype=6.1
  boss=true n.score=300
  n.shoottype=8.1
  check_chat()
  n.movemode=0
  
 elseif n.s==228 or n.s==244 or n.s==245 then
  n.hp=999
  webhp=90
  n.kind=10
  if n.dx!=0 then
   n.dx=0
   n.flipx=true
  end
  
 elseif n.s==18 or n.s==7 or n.s==33 then
  n.kind=3
 elseif n.s==172 or n.s==45 then
  n.kind=3 n.size=2
 elseif n.s==15 then
  n.kind=3 n.movetype=8

 elseif n.s==53 or n.s==55 
 or n.s==56 or n.s==47 then
  n.kind=4
 
 elseif n.s==999 then
  n.kind=999
  n.hp=999
  n.movetype=3
  n.size=2
  boss=true
   
 end
 
 add(act,n)
 return n
end

function main_monster_checker()
 if firsttalk[stage]==true and frameclock>0 then
  if stage==1 then
   if (frameclock%120==0 and frameclock>750) make_monsters(0)
   if (frameclock%90==0 and frameclock>250) make_monsters(1)
   if (frameclock%50==0) make_monsters(5)
   if (frameclock%100==0 and frameclock>500) make_monsters(13)
   if (frameclock==5400) make_monsters(6)  
  elseif stage==2 then
   if (frameclock%185==0 and frameclock>900) make_monsters(2)
   if (frameclock%90==0 and frameclock>300) make_monsters(11)
   if (frameclock%50==0) make_monsters(3)
   if (frameclock%115==0 and frameclock>600) make_monsters(14)
   if (frameclock==6600) make_monsters(7)  
  elseif stage==3 then
   if (frameclock%310==0 and frameclock>333) make_monsters(4)
   if (frameclock%180==0) make_monsters(10)
   if (frameclock%205==0 and frameclock>666) make_monsters(12)
   if (frameclock%100==0 and frameclock>1000) make_monsters(11)
   if (frameclock==6900) make_monsters(8)  
  elseif stage==4 then 

   if (frameclock==99) make_monsters(9)  
  end
 end
end

function make_monsters(set)
  if set<1 then
   local r=flr(rnd(2))
   if r==0 then
    make_act(-24,112,5,0.35,-0.35)
    make_act(-16,104,5,0.35,-0.35)
    make_act(-8,96,5,0.35,-0.35)
   elseif r==1 then
    make_act(152,112,5,-0.35,-0.35)
    make_act(144,104,5,-0.35,-0.35)
    make_act(136,96,5,-0.35,-0.35)
   end
  elseif set<2 then
   if rnd(100)<50 then
    qqq=152
    qa=rnd(0.5)-0.75
   else
    qqq=-24
    qa=rnd(0.5)+0.25
   end
   ttt=rnd(128)
   qb=rnd(1.5)-0.75
   make_act(qqq,ttt,51,qa,qb)
  elseif set<3 then
   make_act(flr(rnd(112))+8,-16,19,0,0.5)
  elseif set<4 then
   make_act(flr(rnd(112))+8,-16,25,0,rnd(0.312)+0.468)
  elseif set<5 then
   make_act(flr(rnd(112))+8,-16,11,0,0.3)
  elseif set<6 then
   local ax=flr(rnd(112))+8
   make_act(ax,-16,3,0,rnd(0.5)+0.5)
  elseif set<7 then
   music(-1,16000)
   boss1=make_act(64,-24,90,0.4966,0.6)
   for a=1,6 do
    bees[a]=make_act(0,-64,1005,0,0)
    bees[a].beenum=a
   end
  elseif set<8 then
   music(-1,18000)
   boss2=make_act(flr(rnd(112))+8,-24,144,0,0.5)
  elseif set<9 then
   music(-1,24000)
   boss3=make_act(flr(rnd(112))+8,-24,150,0,0.5)
  elseif set<10 then
   boss4=make_act(64,-24,999,0,0.5)
   for a=1,20 do
    bees[a]=make_act(0,-64,1999,0,0)
    bees[a].beenum=a
   end
  elseif set<11 then
   if rnd(100)<50 then
    qqq=152
    qa=rnd(0.5)-0.75
   else
    qqq=-24
    qa=rnd(0.5)+0.25
   end
   ttt=rnd(64)+32
   qb=rnd(1.5)-0.75
   make_act(qqq,ttt,140,qa,qb)
  elseif set<12 then
   make_act(flr(rnd(112))+8,-16,134,0,rnd(0.25)+0.25)
  elseif set<13 then
   make_act(flr(rnd(112))+8,-16,224,0,0.5)
  elseif set<14 then
   if rnd(100)<50 then
    qqq=152
    qa=-0.5
   else
    qqq=-24
    qa=0.5
   end
   ttt=rnd(96)+16
   make_act(qqq,ttt,136,qa,0)
  elseif set<15 then
   if rnd(100)<50 then
    qqq=152
    qa=(rnd(0.5)-0.75)*2
   else
    qqq=-24
    qa=(rnd(0.5)+0.25)*2
   end
   ttt=rnd(128)
   qb=(rnd(1.5)-0.75)*2
   make_act(qqq,ttt,236,qa,qb)
  end
end

function make_pbul(s,po,sf)
 local n={}
 n.x=p.x n.y=p.y n.s=s
 n.dx=0
 n.dy=-3
 n.pow=po
 add(pbul,n)
 sfx(sf)
end

function make_sparkles(i,way)
 if way==1 then
  local n={}
  n.x=i.x+rnd(8)-4
  n.y=i.y+rnd(8)-4
  n.s=33
  n.dx=0 n.dy=1
  n.age=0
  n.wide=1
  add(sparkles,n)
 elseif way==2 then
  local n={}
  n.x=i.x
  n.y=i.y+4
  n.s=219
  n.dx=rnd(0.5)-0.25 n.dy=0.5
  n.age=20
  n.wide=1
  add(sparkles,n)
 elseif way==3 then
  local n={}
  n.x=i.x
  n.y=i.y-4
  n.s=49
  n.dx=rnd(0.5)-0.25 n.dy=rnd(0.5)-.25
  n.age=15
  n.wide=1
  add(sparkles,n)
 end
end

function explosion(x,y)
 for i=1,9 do
  local n={}
  n.x=x+rnd(12)-6
  n.y=y+rnd(12)-6
  n.s=49
  n.dx=rnd(2)-1 n.dy=rnd(2)-1
  n.age=0
  n.wide=1
  add(sparkles,n)
 end
end

function _update()
 frameclock+=1
 if (frameclock==16000) frameclock=0
 if state==1 then
  title_update()
 elseif state==2 then
  game_update()
 elseif state==3 then
  dead_update()
 elseif state==4 then
  update_kill()
 elseif state==5 then
  update_chat()
 elseif state==6 then
  dead_boss_update()
 end
end

function dead_update()
 move_player_bullets()
 move_monsters()
 move_sparkles()
 if (btnp(4)) run()
end

function dead_boss_update()
 move_player_bullets()
 move_monsters()
 move_sparkles()
 deadbossclock+=1
 
 if deadbossclock==64*1.5 then
  stage+=1
  if stage==1 then
   music(0)
  elseif stage==2 then
   music(15)
  elseif stage==3 then
   music(5)
  elseif stage==4 then
   music(25)
  end
  p.x=999 p.y=999
  p.dx=0 p.dy=0
  for b in all(act) do
   if (b.kind!=1) del(act,b)
  end
 end
 if deadbossclock==64*3 then
  boss=false
  frameclock=0
  p.x=64 p.y=110
  p.dx=0 p.dy=-3
  state=2
 end
end

function dead_boss_draw()
 if stage>0 then
  cls()
  cycle_sprites()
  draw_background()
  draw_player()
  draw_player_bullets()
  draw_monsters()
  draw_sparkles()
  screen_draw()
 else
  print("pain is never ending",24,120,1)
  rectfill(0,frameclock/16000*128,128,128,1)
  rectfill(0,frameclock/7200*128,128,128,2)
  rectfill(0,frameclock/3200*128,128,128,8)
  rectfill(0,frameclock/1400*128,128,128,9)
  rectfill(0,frameclock/600*128,128,128,10)
  rectfill(0,frameclock/250*128,128,128,12)
  rectfill(0,frameclock/100*128,128,128,3)
  spr(64,24,48,10,4)
  print("press Ž to start",30,93,7)
  print("— shoot",28,106,6)
  print("”",76,103,6)
  print("‹ƒ‘",68,109,6)
  print("move",97,106,6)
 end
 draw_curtains()
end

function title_update()
 if btnp(4) then
  music(-1,2000)
  start_game()
 end
 if (frameclock==16000) start_game()
end

function start_game()
 stage=0
 state=6
end

function game_update()
 if frameclock==50 and firsttalk[stage]==false then
  firsttalk[stage]=true
  check_chat()
 end
 move_player()
 move_player_bullets()
 if boss==false then
  main_monster_checker()
 else
  boss_checker()
 end
 move_monsters()
 check_col_player_hit_mon()
 check_col_enemy_hit_player()
 if (invuln==true) dmgboost()
 move_sparkles()
 if (frameclock%10==0) make_sparkles(p,1)
end

function check_col_player_hit_mon()
 for e in all(act) do
  if (e.kind==2 or e.kind==10 or e.kind==999) and e.y>0 then
   for b in all(pbul) do
    local px=(e.x-b.x)^2
    local py=(e.y-b.y)^2
    if abs(px+py)-(4+e.size*4)^2<0 then
     if e.hp>0 then
      if (e.kind==2) e.hp-=b.pow
      if (e.kind==10) webhp-=b.pow
      sfx(9)
      make_sparkles(b,3)
      del(pbul,b)
      if e.hp<=0 then
       explosion(e.x,e.y)
       score+=e.score
       float_score(e)
       if (boss==true) check_kill_boss(e)
       maybe_powerup(e.x,e.y)
       del(act,e)
       sfx(10)
      end
      if webhp<=0 and e.kind==10 then
       killweb(e)
      end
     end
    end
   end
  end
 end
end

function check_kill_boss(e)
 if e.s==90 or e.s==93
 or e.s==144 or e.s==147 
 or e.s==150 or e.s==153 then
  deadboss[stage]=true
  check_chat()
  deadbossclock=0
 end
end

function float_score(e)
 local n={}
 n.x=e.x+rnd(12)-6
 n.y=e.y+rnd(12)-6
 n.wide=1
 if e.score==1 then
  n.s=23
 elseif e.score==2 then
  n.s=39
 elseif e.score==10 then
  n.s=40
 elseif e.score==20 then
  n.s=24
 elseif e.score==30 then
  n.s=57
 elseif e.score==50 then
  n.s=58
 elseif e.score==3 then
  n.s=197
 elseif e.score==5 then
  n.s=229
 elseif e.score==100 then
  n.s=74 n.wide=2
 elseif e.score==200 then
  n.s=230 n.wide=2
 elseif e.score==300 then
  n.s=246 n.wide=2
 end
 n.dx=0.1 n.dy=-0.75
 n.age=0
 add(sparkles,n)
end

function maybe_powerup(x,y)
 if rnd(100)<5 then
  local choice=rnd(2)
  if choice<1 then
   make_act(x,y,47,0,0.5)
  else
   make_act(x,y,56,0,0.5)
  end
 end
end

function grant_power(s)
 if s==47 then
  powerup=8
  sfx(39)
 elseif s==56 then
  sfx(14)
  if (p.hp<3) p.hp+=1
 end
end

function check_col_enemy_hit_player()
 for b in all(act) do
  if b.kind!=1 then 
   local px=(p.x-b.x)^2
   local py=(p.y-b.y)^2
  if b.kind==4 then 
   if abs(px+py)<64 then
    grant_power(b.s)
    del(act,b)
   end
  elseif invuln==false then
   colcode=5-b.kind 
   if (b.kind==999) colcode=3
   if (b.kind==10) colcode=3
   if abs(px+py)-(colcode+b.size*4)^2<0 then
    if b.kind==10 or b.s==192 then
     fric=0.45
     cspiders()
    elseif b.s==15 then
     make_act(b.x,b.y,192,0,0.2)
     del(act,b)
    else
     p.hp-=b.pow
     sfx(11)
     invuln=true
     invulncount=0
     if (b.kind==3 and b.s!=45) del(act,b)
     if p.hp<=0 then
      explosion(p.x,p.y)
      del(act,p)
      sfx(12)
      if lives>0 then
       make_player()
       lives-=1
      else
       music(28)
       state=3
      end
     end
    end
   end
  end
  end
 end
end

function dmgboost()
 invulncount+=1
 if (invulncount==45) invuln=false
end

function _draw()
 if state==1 then
  title_draw()
 elseif state==2 then
  game_draw()
 elseif state==3 then
  dead_draw()
 elseif state==4 then
  draw_kill()
 elseif state==5 then
  draw_chat()
 elseif state==6 then
  dead_boss_draw()
 end
end

function dead_draw()
 cls()
 cycle_sprites()
 draw_background()
 draw_player_bullets()
 draw_monsters()
 draw_sparkles()
 screen_draw()
 print("g a m e   o v e r",29,60,7)
 print("press Ž to restart",26,68,7)
end

function title_draw()
 cls()
 print("pain is never ending",24,120,1)
 rectfill(0,frameclock/16000*128,128,128,1)
 rectfill(0,frameclock/7200*128,128,128,2)
 rectfill(0,frameclock/3200*128,128,128,8)
 rectfill(0,frameclock/1400*128,128,128,9)
 rectfill(0,frameclock/600*128,128,128,10)
 rectfill(0,frameclock/250*128,128,128,12)
 rectfill(0,frameclock/100*128,128,128,3)
 spr(64,24,48,10,4)
 print("press Ž to start",30,93,7)
 print("— shoot",28,106,6)
 print("”",76,103,6)
 print("‹ƒ‘",68,109,6)
 print("move",97,106,6)
 
 p.x=64+40*sin(frameclock/160)
 p.y=64+24*cos(frameclock/160)

 draw_player()
 if (frameclock%10==0) make_sparkles(p,1)
 draw_sparkles()
 move_sparkles()
 cycle_sprites()

end

function game_draw()
 cls()
 cycle_sprites()
 draw_background()
 draw_monsters()
 draw_player()
 draw_sparkles()
 draw_player_bullets()
 screen_draw()
end

function draw_background()
 if stage==1 then
  rectfill(0,0,127,119,3)
  map(0,0,0,mapclock,16,16)
  map(0,0,0,mapclock-128,16,16)
 elseif stage==2 then
  rectfill(0,0,127,119,13)
  map(16,0,0,mapclock,16,16)
  map(16,0,0,mapclock-128,16,16)
 elseif stage==3 then
  rectfill(0,0,127,119,5)
  map(32,0,0,mapclock,16,16)
  map(32,0,0,mapclock-128,16,16)
 elseif stage==4 then
  rectfill(0,0,127,119,0)
  map(64,0,0,mapclock,16,16)
  map(64,0,0,mapclock-128,16,16)
 end
 mapclock+=0.2
 if (mapclock>=128) mapclock=0
end

function draw_curtains()
 if deadbossclock<64 then
  map(48,0,deadbossclock-64,0,8,16)
  map(56,0,128-deadbossclock,0,8,16)
 elseif deadbossclock<128 then
  map(48,0,0,0,8,16)
  map(56,0,64,0,8,16)
 elseif deadbossclock>=128 then
  map(48,0,128-deadbossclock,0,8,16)
  map(56,0,deadbossclock-64,0,8,16)
  p.hp=3
 end
end

function screen_draw()
 rectfill(0,120,127,127,0)
 rect(0,0,127,119,7)
 spr(216,1,120,3,1)
 print(score,24,121,12)

 if (powerup>0) rectfill(56,121,55+powerup*2,126,11)
 if (powerup>2) rectfill(60,121,55+powerup*2,126,10)
 if (powerup>4) rectfill(64,121,55+powerup*2,126,9)
 if (powerup>6) rectfill(68,121,55+powerup*2,126,8)
 if (powerup>0) spr(194,55,120,3,1)
 
 if (score>0) print("00",24+(#tostr(score))*4,121,12)
 for i=1,p.hp do
  spr(10,67+8*i,120)
 end
 for i=1,lives do
  spr(1,92+i*9,121,1,0.625)
 end

end

function cycle_sprites()
 if frameclock%4==0 then
  if p.s==1 then
   p.s=2
  elseif p.s==2 then
   p.s=1
  end
 end
 
 for i in all(sparkles) do
  if i.age%3==0 then
   if i.s==33 then
    i.s=34
   elseif i.s==34 then
    i.s=33
   elseif i.s==49 then
    i.s=50
   elseif i.s==50 then
    i.s=49
   end
  end
 end
 
 for i in all(act) do
  if i.kind==2 then
   if frameclock%4==0 then
    if i.s==3 then
     i.s=4
    elseif i.s==4 then
     i.s=3
    elseif i.s==5 then
     i.s=6
    elseif i.s==6 then
     i.s=5
    elseif i.s==51 then
     i.s=52
    elseif i.s==52 then
     i.s=51
     if i.flipx==false then
      i.flipx=true
      i.flipy=true
     elseif i.flipx==true then
      i.flipx=false
      i.flipy=false
     end
    elseif i.s==25 then
     i.s=26
    elseif i.s==26 then
     i.s=25
    elseif i.s==11 then
     i.s=13
    elseif i.s==13 then
     i.s=11
    elseif i.s==134 then
     i.s=135
    elseif i.s==135 then
     i.s=134
    elseif i.s==224 then
     i.s=226
    elseif i.s==226 then
     i.s=224
    elseif i.s==43 then
     if i.flipx==false and i.flipy==false then
      i.flipy=true
     elseif i.flipx==false and i.flipy==true then
      i.flipx=true
     elseif i.flipx==true and i.flipy==true then
      i.flipy=false
     elseif i.flipx==true and i.flipy==false then
      i.flipx=false
     end
    elseif i.s==136 then
     if i.flipx==true then
      i.flipx=false
     else
      i.flipx=true
     end
    elseif i.s==140 then
     i.s=142
    elseif i.s==142 then
     i.s=140
    end
    
   elseif frameclock%2==0 then
    if i.s==19 then
     i.s=21
    elseif i.s==21 then
     i.s=19
    elseif i.s==90 then
     i.s=93
    elseif i.s==93 then
     i.s=90
    elseif i.s==144 then
     i.s=147
    elseif i.s==147 then
     i.s=144
    elseif i.s==150 then
     i.s=153
    elseif i.s==153 then
     i.s=150
    elseif i.s==172 then
     i.s=174
    elseif i.s==174 then
     i.s=172
    elseif i.s==236 then
     i.s=238
    elseif i.s==238 then
     i.s=236
    end
   end
  end
 end
end

--[[function toggle(v)
 if v==true then
  return false
 elseif v==false then
  return true
 end
end]]

function move_player()
 if btnp(4) then
  if p.hp>1 then
   p.hp-=1
   if (powerup<7) powerup+=2
  end
  --"undocumented feature"
 end

 if btn(5) and firsttalk[stage]==true then
  shoot()
 end

 if btn(0) then
  p.dx-=p.ddx
  if (p.dx<(p.tx*-1)) p.dx=(p.tx*-1)
 end
 if btn(1) then
  p.dx+=p.ddx
  if (p.dx>p.ty) p.dx=p.tx
 end
 if btn(2) then
  p.dy-=p.ddy
  if (p.dy<(p.ty*-1)) p.dy=(p.ty*-1)
 end
 if btn(3) then
  p.dy+=p.ddy
  if (p.dy>p.ty) p.dy=p.ty
 end
 
 p.dx*=fric p.dy*=fric
 if (fric!=0.9) fric=0.9
 p.x+=p.dx p.y+=p.dy
 
 if p.x<5 then
  p.x=5
  p.dx=0
 end
 if p.x>123 then
  p.x=123
  p.dx=0
 end
 if p.y<5 then
  p.y=5
  p.dy=0
 end
 if p.y>115 then
  p.y=115
  p.dy=0
 end
end

function move_monsters()
 for i in all(act) do
  if i.y>192 or i.y<-64 
  or i.x>192 or i.x<-64 then
   if (i.s!=1999) del(act,i)
  elseif i.kind==2 then
  
   if i.movetype==1 then
    i.y+=i.dy
    i.x+=i.dx
    
   elseif i.movetype==2 then
    if i.x<5 and i.dx<0 then
     i.x=5
     i.dx*=-1
    end
    if i.x>123 and i.dx>0 then
     i.x=123
     i.dx*=-1
    end
    if i.y<5 and i.dy<0 then
     i.y=5
     i.dy*=-1
    end
    if i.y>115 and i.dy>0 then
     i.y=115
     i.dy*=-1
    end
    i.y+=i.dy
    i.x+=i.dx

   elseif i.movetype==3 then
    if i.x<4*i.size+1 and i.dx<0 then
     i.x=4*i.size+1
     i.dx*=-1
    end
    if i.x>127-4*i.size and i.dx>0 then
     i.x=127-4*i.size
     i.dx*=-1
    end
    if i.y>16 and i.dy>0 then
     i.y=16
     i.dy=0
     i.dx=1
    end
    i.y+=i.dy
    i.x+=i.dx
    
   elseif i.movetype==4 then
    if i.movemode==0 then
     i.x=boss1.x+i.inpos*(cos(frameclock/160+(i.beenum/6)))
     i.y=boss1.y-i.inpos*(sin(frameclock/160+(i.beenum/6)))
     if (i.inpos<16) i.inpos+=0.5
    elseif i.movemode==1 then
     if i.beenum<=2 then
      i.rad=12 i.pos=i.beenum
     elseif i.beenum<=5 then
      i.rad=24 i.pos=i.beenum-2
     elseif i.beenum<=9 then
      i.rad=36 i.pos=i.beenum-5
     elseif i.beenum<=14 then
      i.rad=48 i.pos=i.beenum-9
     else
      i.rad=60 i.pos=i.beenum-14
     end
     i.x=boss4.x+i.inpos*(cos(frameclock/(i.rad*10)+(i.pos/(i.rad/12+1))))
     i.y=boss4.y-i.inpos*(sin(frameclock/(i.rad*10)+(i.pos/(i.rad/12+1))))
     if (i.inpos<i.rad) i.inpos+=0.5
    end    
   
   elseif i.movetype==5 then
    if i.inpos<=-45 then
     i.ang=atan2(p.x-i.x,p.y-i.y)
     i.inpos=sqrt((p.x-i.x)^2+(p.y-i.y)^2)    
    elseif i.inpos<=0 then
     i.inpos-=2
    else
     i.y+=2*sin(i.ang)
     i.x+=2*cos(i.ang)
     i.inpos-=2
    end

   elseif i.movetype==6 then
    spidercatch(i)
    if i.movemode==0 then
     i.inpos=0
     if i.x<4*i.size+1 and i.dx<0 then
      i.x=4*i.size+1
      i.dx*=-1
     end
     if i.x>127-4*i.size and i.dx>0 then
      i.x=127-4*i.size
      i.dx*=-1
     end
     if i.y>16 and i.dy>0 then
      i.y=16
      i.dy=0
      i.dx=1
     end
     if rnd(190)<1 then
      i.movemode=1
     end
     
    elseif i.movemode==1 then
     if i.inpos<=0 then
      i.ang=atan2(p.x-i.x,(p.y+4)-i.y)
      i.inpos=sqrt((p.x-i.x)^2+((p.y+4)-i.y)^2)    
     elseif i.inpos<=2 then
      i.movemode=2
     else
      i.dy=2*sin(i.ang)
      i.dx=2*cos(i.ang)
      i.inpos-=2
     end
     if (i.y>104) i.movemode=2
    elseif i.movemode==2 then
     i.dx=0
     i.dy=-2
     if (i.y<17) then
      i.movemode=0
      i.y=16
      i.dy=0
      i.dx=1
     end
    end

    i.y+=i.dy
    i.x+=i.dx


   elseif i.movetype==6.1 then
    spidercatch(i)
    if i.movemode==0 then
     i.inpos=0
     if i.x<12 and i.dx<0 then
      i.x=12
      i.dx*=-1
     end
     if i.x>115 and i.dx>0 then
      i.x=115
      i.dx*=-1
     end
     if i.y>16 and i.dy>0 then
      i.y=16
      i.dy=0
      i.dx=1
     end
     if rnd(205)<1 then
      i.movemode=1
     elseif rnd(185)<1 and webhp<=0 then
      i.movemode=3
     end
     
    elseif i.movemode==1 then
     if i.inpos<=0 then
      i.ang=atan2(p.x-i.x,p.y-i.y)
      i.inpos=sqrt((p.x-i.x)^2+(p.y-i.y)^2)    
     elseif i.inpos<=2 then
      i.movemode=2
     else
      i.dy=2*sin(i.ang)
      i.dx=2*cos(i.ang)
      i.inpos-=2
     end
     if (i.y>100) i.movemode=2
     if (i.x<13) i.movemode=2
     if (i.x>114) i.movemode=2
    elseif i.movemode==2 then
     i.dx=0
     i.dy=-2
     if (i.y<17) then
      i.movemode=0
      i.y=16
      i.dy=0
      i.dx=1
     end
    elseif i.movemode==3 then
     if i.inpos<=0 then
      i.target=flr(rnd(2))+1
      if i.target==1 then
       i.targx=12 i.targy=16
      else
       i.targx=115 i.targy=16
      end
      i.ang=atan2(i.targx-i.x,i.targy-i.y)
      i.inpos=sqrt((i.targx-i.x)^2+(i.targy-i.y)^2)    
     elseif i.inpos<=2 then
      if (i.targx==12) spipos=1
      if (i.targx==115) spipos=2
      i.movemode=2
     else
      i.dy=2*sin(i.ang)
      i.dx=2*cos(i.ang)
      i.inpos-=2
     end
     if (i.y>100) i.movemode=2
     if (i.x<13) i.movemode=2
     if (i.x>114) i.movemode=2
    end

    i.y+=i.dy
    i.x+=i.dx

   elseif i.movetype==7 then
    if i.cx<5 and i.dx<0 then
     i.cx=5
     i.dx*=-1
    end
    if i.cx>123 and i.dx>0 then
     i.cx=123
     i.dx*=-1
    end
    if i.cy<5 and i.dy<0 then
     i.cy=5
     i.dy*=-1
    end
    if i.cy>115 and i.dy>0 then
     i.cy=115
     i.dy*=-1
    end

    cosang=cos(frameclock/160)
    sinang=sin(frameclock/160)
    
    if i.cx-i.x>0 then
     if i.dx>0 then
      i.flipx=true
     else
      i.flipx=false
     end
    else
     if i.dx>0 then
      i.flipx=true
     else
      i.flipx=false
     end
    end
    if i.cy-i.y>0 then
     if i.dy>0 then
      i.flipy=true
     else
      i.flipy=false
     end
    else
     if i.dy>0 then
      i.flipy=true
     else
      i.flipy=false
     end
    end

    i.cy+=i.dy
    i.cx+=i.dx

    i.x=i.cx+8*cosang
    i.y=i.cy-8*sinang

   elseif i.movetype=="w" then
    if i.inpos==0 then
     if i.y<104 then
      i.dy=0.6
      if i.dx<=0 and i.x<40 then
       i.dx=i.sspd
      elseif i.dx>0 and i.x>88 then
       i.dx=-i.sspd
      end
     else
      i.inpos=1 i.wag=0.25
      i.y=104 i.x=64
      i.dx=0
      i.dy=0
     end
    elseif i.inpos==1 then
     if i.wag<0.75 then
      i.wag+=0.005
      i.dx=i.turnrad*sin(i.wag)
      i.dy=i.turnrad*cos(i.wag)
     else
      i.inpos=2
      i.y=16 i.x=64
      i.dx=i.sspd
      i.dy=0
     end
    elseif i.inpos==2 then
     if i.y<104 then
      i.dy=0.6
      if i.dx<=0 and i.x<40 then
       i.dx=i.sspd
      elseif i.dx>0 and i.x>88 then
       i.dx=-i.sspd
      end
     else
      i.inpos=3 i.wag=0.25
      i.y=104 i.x=64
      i.dx=0
      i.dy=0
     end    
    elseif i.inpos==3 then
     if i.wag>-0.25 then
      i.wag-=0.005
      i.dx=i.turnrad*-sin(i.wag)
      i.dy=i.turnrad*-cos(i.wag)
     else
      i.inpos=0
      i.y=16 i.x=64
      i.dx=-i.sspd
      i.dy=0
     end
    end
    
    i.x+=i.dx
    i.y+=i.dy
        
   end
  
   if i.x<128 and i.x>0 and i.y<128 and i.y>0 then
    monster_shoot(i)
   end
  
  elseif i.kind==3 then
   if i.movetype==8 then
    if i.inpos<=0 then
     i.ang=atan2(p.x-i.x,p.y-i.y)
     i.inpos=10+sqrt((p.x-i.x)^2+(p.y-i.y)^2)
     i.dy=2*sin(i.ang)
     i.dx=2*cos(i.ang)
     i.inpos-=2
    elseif i.inpos<12 then
     make_act(i.x,i.y,192,0,0.2)
     del(act,i)
    else
     i.dy=2*sin(i.ang)
     i.dx=2*cos(i.ang)
     i.inpos-=2
    end
   end
   i.x+=i.dx
   i.y+=i.dy
   
  elseif i.kind==4 then
   i.x+=i.dx
   i.y+=i.dy
   
  elseif i.kind==999 then
    if i.x<4*i.size+1 and i.dx<0 then
     i.x=4*i.size+1
     i.dx*=-1
    end
    if i.x>127-4*i.size and i.dx>0 then
     i.x=127-4*i.size
     i.dx*=-1
    end
    if i.y>16 and i.dy>0 then
     i.y=16
     i.dy=0
     i.dx=1
    end
    i.y+=i.dy
    i.x+=i.dx
   
  
  end
 end
end

function monster_shoot(e)
 if e.shoottpe==0 then
  return
 elseif e.shoottype==1 and
 frameclock%45==0 then
  make_act(e.x,e.y+e.size*4,18,0,1)
  sfx(13)
 elseif e.shoottype==2 and
 frameclock%30==0 then
  local ang=atan2(p.x-e.x,p.y-e.y)
  make_act(e.x,e.y+e.size*4,7,cos(ang),sin(ang))
  sfx(13)
 elseif e.shoottype==3 and
 frameclock%120==0 then
  local ang=atan2(p.x-e.x,p.y-e.y)
  make_act(e.x,e.y+e.size*4,43,cos(ang)/2,sin(ang)/2)
  sfx(13)
 elseif e.shoottype==4 and flr(rnd(85))==0 then
  make_act(e.x,e.y+e.size*4,172,0,0.75)
  sfx(13)
 elseif e.shoottype==8 and
 frameclock%80==0 then
  make_act(e.x,e.y+e.size*4,15,0,0)
  sfx(13)
 elseif e.shoottype==8.1 and
 frameclock%50==0 then
  make_act(e.x,e.y+e.size*4,15,0,0)
  sfx(13)
 elseif e.shoottype==999 and
 frameclock%20==0 then
  local ang=rnd(1)
  make_act(e.x,e.y,33,cos(ang),sin(ang))
  sfx(13)
 end
end

function shoot()

 if powerup<3 then
  hab=4
 elseif powerup<5 then
  hab=3
 elseif powerup<7 then
  hab=3
 elseif powerup>=7 then
  hab=2
 end
  
 if frameclock%hab==0 then
  p.pow=2+powerup

  if powerup>0 then
   p.shoottype=133
  else
   p.shoottype=17
  end

  p.ssfx=5

  make_pbul(p.shoottype,p.pow,p.ssfx)
 end
end

function draw_player()
 if invuln==false then
  spr(p.s,p.x-4,p.y-4)
 else
  if frameclock%2==0 then
   spr(p.s,p.x-4,p.y-4)
  end
 end 
end

function draw_monsters()
 for i in all(act) do
  if i.kind!=1 then
   if i.s==45 then
    local offset=4*i.size
    spr(i.s,i.x-offset,i.y-offset,i.size,i.size,i.flipx,i.flipy)
   elseif i.kind!=1 and i.kind!=999 and i.s!=45 then
    if i.shape=="long" then
     spr(i.s,i.x-4,i.y-8,1,2)
    elseif i.shape=="wide" then
     spr(i.s,i.x-8,i.y-4,2,1,i.flipx,i.flipy)
    elseif i.shape=="huge" then
     line(i.x,i.y,i.x,0,7)
     spr(i.s,i.x-12,i.y-16,3,4)
    elseif i.s==224 or i.s==226 then
     line(i.x,i.y,i.x,0,7)
     local offset=4*i.size
     spr(i.s,i.x-offset,i.y-offset,i.size,i.size,i.flipx,i.flipy)
    elseif i.s==1999 then
     circfill(i.x,i.y,4,2)
    else
     local offset=4*i.size
     spr(i.s,i.x-offset,i.y-offset,i.size,i.size,i.flipx,i.flipy)
    end
   elseif i.kind==999 then
    draw_heart(i)
   end
  end
 end
end

function move_player_bullets()
 for i in all(pbul) do
  if rnd(20)<(powerup+1) then
   make_sparkles(i,2)
  end
  if i.y<-4 then
   del(pbul,i)
  else
   i.x+=i.dx
   i.y+=i.dy
  end
 end

 if powerup>0 then
  powerup-=0.02
 else
  powerup=0
 end

end

function move_sparkles()
 for i in all(sparkles) do
  if i.age>30 then
   del(sparkles,i)
  else
   i.x+=i.dx
   i.y+=i.dy
   i.age+=1
  end
 end
end

function draw_player_bullets()
 for i in all(pbul) do
  if i.y>-10 then
   spr(i.s,i.x-4,i.y-4)
  end
 end
end

function draw_sparkles()
 for i in all(sparkles) do
  spr(i.s,i.x-4,i.y-4,i.wide,1)
 end
end

function draw_kill()
 cls()
end

function update_kill()
 music(-1)
end

function draw_chat()
 wide=#lin1
 if (#lin2>wide) wide=#lin2
 if (#lin3>wide) wide=#lin3
 if (#lin4>wide) wide=#lin4
 wide*=2
 rectfill(56-wide,48,72+wide,80,1)
 rect(57-wide,49,71+wide,79,12)
 spr(speaker,60-wide,52,1,speakhigh)
 print(lin1,70-wide,53,speacol)
 print(lin2,70-wide,59,speacol)
 print(lin3,70-wide,65,speacol)
 print(lin4,70-wide,71,speacol)
end

function update_chat()
 chattime+=1
 speaker=1 speacol=15
 keeptalk=false
 lin1=""
 lin2=""
 lin3=""
 lin4=""
 speakhigh=1
 
 if chatera==1 then
  lin1="when a wish is made,  "
  lin2="a fairy is born"
  lin3="to grant it."
  keeptalk=true
 elseif chatera==2 then
  lin1="i am dynia, and i will"
  lin2="see the wish i carry"
  lin3="come true!"
 elseif chatera==3 then
  speaker=90 speacol=2
  lin1="ugh! miscreant pixie! "
  lin2="you are not welcome!"
  lin3="begone at once!"
  keeptalk=true
 elseif chatera==4 then
  lin1="i have been sent,     "
  lin2="bearing a sacred wish!"
  lin3="i will not be stopped!"
 elseif chatera==5 then
  speaker=90 speacol=2
  lin1="ugh! what do you want?"
  lin2="just go away!"
  keeptalk=true
 elseif chatera==6 then
  lin1="i will complete       "
  lin2="my duty, no"
  lin3="matter what!"
 elseif chatera==7 then
  lin1="no matter my foe,     "
  lin2="i must persevere."
  lin3="i bear the wish"
  lin4="of a god."
 elseif chatera==8 then
  speaker=177 speacol=2
  lin1="you speak of a god?   "
  lin2="the god you serve is  "
  lin3="a fool and a wretch!"
  keeptalk=true
 elseif chatera==9 then
  speaker=177 speacol=2
  lin1="and the wish you      "
  lin2="bear is fiendish!"
 elseif chatera==10 then
  speaker=177 speacol=2
  lin1="what right do you     "
  lin2="have to force this"
  lin3="upon us!?"
  keeptalk=true
 elseif chatera==11 then
  lin1="i am bound to complete"
  lin2="my duty..."
  lin3="it is not my place"
  lin4="to question a wish..."
 elseif chatera==12 then
  lin1="wishes must come true,"
  lin2="or else hearts will"
  lin3="break..."
 elseif chatera==13 then
  speaker=186 speacol=2 
  lin1="some wishes should    "
  lin2="never be granted."
  lin3="some dreams should"
  lin4="never come true."
  keeptalk=true
 elseif chatera==14 then
  speaker=186 speacol=2 
  lin1="and some hearts       "
  lin2="deserve to be broken."
  keeptalk=true
 elseif chatera==15 then
  lin1="i must go on...       "
  lin2="this is what i was"
  lin3="born to do..."
  keeptalk=true
 elseif chatera==16 then
  lin1="this is my fate...    "
 elseif chatera==17 then
  lin1="no matter what...     "
  lin2="i am bound to my duty."
 elseif chatera==18 then
  speacol=10 speaker=248
  lin1="you are not wanted    "
  lin2="anymore."
  keeptalk=true
 elseif chatera==19 then
  speacol=10 speaker=248
  lin1="this was pointless    "
  lin2="from the beginning."
  keeptalk=true
 elseif chatera==20 then
  speacol=10 speaker=248
  lin1="pain...               "
  keeptalk=true
 elseif chatera==21 then
  speacol=10 speaker=248
  lin1="... is never ending.  "
 end
 
 if (speaker==90 or speaker==186) speakhigh=1.5
  
 if chattime>(#lin1+#lin2+#lin3+#lin4)*4 then
  if keeptalk==false then
   if (boss==true and deadboss[stage]==false) music(31)
   if deadboss[stage]==true then
    music(-1,3000)
    state=6
   else
    state=2
   end
  else
   chatera+=1
  end
  chattime=0
 end
 
 frameclock-=1
end

function check_chat()
 lin1="" lin2="" lin3="" lin4=""
 state=5
 chattime=0
 chatera+=1
end

function draw_heart(e)
 e.hp=999
 e.size=2-2*(sin(frameclock/160))
 circfill(e.x,e.y,e.size*4,1)
end

function boss_checker()
 if stage==1 then
  if (frameclock%180==0) make_monsters(0)
  if frameclock%350==0 then
   for b=1,6 do
    if bees[b].hp<=0 then
     bees[b]=make_act(boss1.x,boss1.y,1005,0,0)
     bees[b].beenum=b
    end
   end
  end
 elseif stage==2 then
  if (frameclock%200==0) make_monsters(2)
 elseif stage==3 then
  if (frameclock%360==0) make_monsters(12)
  if spipos!=0 and webhp<=0 then
   if spipos==1 then
    origx=0 origy=0
    termh=63 termf=127
    for s=0,16 do
     make_act(origx+8*s,origy+8*s,228,0,0)
     make_act(origx+8*s,origy+4*s,244,0,0)
     make_act(origx+4*s,origy+8*s,245,0,0)
    end
    spipos=0
   elseif spipos==2 then
    origx=127 origy=0
    termh=63 termf=0
    for s=0,16 do
     make_act(origx+8*-s,origy+8*s,228,1,0)
     make_act(origx+8*-s,origy+4*s,244,1,0)
     make_act(origx+4*-s,origy+8*s,245,1,0)
    end
    spipos=0
   end
  end
 elseif stage==4 then
  if frameclock%1600==0 then
   for b=1,20 do
    if bees[b].hp<=0 then
     tempb=make_act(boss4.x,boss4.y,1999,0,0)
     tempb.beenum=b
     if b<=2 then
      tempb.rad=16 tempb.pos=tempb.beenum
     elseif b<=5 then
      tempb.rad=32 tempb.pos=tempb.beenum-2
     elseif b<=9 then
      tempb.rad=48 tempb.pos=tempb.beenum-5
     elseif b<=14 then
      tempb.rad=64 tempb.pos=tempb.beenum-9
     else
      tempb.rad=80 tempb.pos=tempb.beenum-14
     end
     bees[b]=tempb
    end
   end
  end
 end
end

function killweb(e)
 float_score(e)
 for l in all(act) do
  if l.kind==10 then
   explosion(l.x,l.y)
   del(act,l)
  end
 end
 sfx(10)
end

function cspiders()
 for w in all(act) do
  if w.s==150 or w.s==224 or
  w.s==153 or w.s==226 then
   if w.movemode==0 then
    w.movemode=1
    w.inpos=0
   end
  end
 end
end

function spidercatch(i)
 if i.x>127 then
  i.x=127
  i.dx=abs(i.dx)*-1
 elseif i.x<0 then
  i.x=0
  i.dx=abs(i.dx)
 end
 if i.y>120 then
  i.y=120
  i.dy=0
 end
end
__gfx__
00000000ccaaaacc00aaaa0010012001000120000221006602210000000000007788887700888800000000000000001122000000000000112200000000070000
00000000ccaffaccccaffacc01111210001112000011a6660011a66000011000778ff877778ff8770ee0ee002000011122200001000001112220000006777760
007007000caffac0ccaffacc0011120001111210000a1660000a1666001dd100078ff870778ff877888888e02200111122220011022011112222011006070067
000770000aa77a000aa77a0010012001100120010001aa000001aa6601dddd10088ee800088ee800288888e00221111122222110220111112222201170670607
000770000aa77a000aa77a00010120100001200000aa110000aa110001d1d110088ee800088ee800028888000001111122222000200111112222200177777777
007007000c7770c000777c0000111200011112100011a0000011a000001d110007eee07000eee700002880002001111122222001000111112222200070677007
00000000c0f0f00c0cf0f0c0001112001011120100aa000000aa00000001100070f0f00707f0f070000200002201111122222011022111112222211006070660
0000000000f0f000c0f0f00c000120000001200001000000010000000000000000f0f00070f0f007000000000221111122222110220111112222201100777700
3b33333300777700000000000000000bb00000000000000bb0000000000000000000000000254950025495000001111122222000200111112222200133333333
b333333307000070099a9aa000000003b000000000000003b00000000000000007777777001b1a1001b1a10000011111222220000001111122222000b3333333
b3333b33700070070999aaa00076000bb00067000000000bb00000007707777772222222002bba5002bba500022111112222211022211111222221113b33b333
333333b370000707009aaa0000707003b007070000000003b0000000667ddddd8872727201b4a100001b4a10220011111111001100001111111100003b3b3333
33b333b3700000070099aa000006060bb06060000000000bb0000000767d7d7d7822222202b1a500002b1a5020011111222220010001111122222000333b3333
3b33333370000007000aa00000007073b707000000000003b0000000767ddddd8777777701bba100001bba100001111122222000000111112222200033333b33
3b333333070000700009a0000000060670600000006767676767670066677777887000002b4a50000002b4a5000018112282000000001811228200003333b333
3333333300777700000000000000006767000000007666677666670077700000770000001b1a10000001b1a1000000011000000000000001100000003333b333
5bb5a53300000000000000000000067677600000076767676767677000077777000000002bba50000002bba500000ffffff00000000001111110000007700000
3b5a5a53000000000000000000006067670700007000007677000007777ddddd0777777701b4a100001b4a10000555555f5ff0000000155551111100d6670000
5ba5ab53000000000000c00000070706706060007076770770776707cc7d7d7d7333333302b1a500002b1a50005555f5f5f5ff000000155555555111d6667000
3a5ab5a50000c000000c7c0000606073b707070070000073b70000077c7dddddbb73737301bba100001bba1005555555555f5ff000111115555555110d668e00
5bab5ab5000c7c0000c777c00707070bb06060600676770bb0676770c77777777b333333002b4a5002b4a5000555555555f5f5f0001555115555551000d888e0
3ab5ab530000c000000c7c0060606003b007070700000003b0000000cc7000007b777777001b1a1001b1a100155555555f555f5f00155551555555110002888e
5bbab533000000000000c0007007002222006007000000222200000077000000bbb70000002bba5002bba500151555555555f5ff01155555555111510000288e
3bab5a5300000000000000006760005252000767000000525200000000000000777000000041014004101400155555555555555f151555555555511100000220
35ba5bb300000000000000000099f900009f990007700000008888000770000000000000077777770aaaaaaa151555555555f5ff151155555555551022222221
335ba5b5000000000000000009f99f900f99f990d667000008999980eff70000006647707aaaaaaaa7777777115551555555555f155555555555551112222211
35a5bab30000000000008000999f9f9951f9f9f9d6667000899aa998efff700000074700997a7a7aeea7a7a7151515555555555f155555555555555121222121
35ba5bb500008000000828009ff4599f11954f990d66ba0089aaaa980effdc000076077079aaaaaae77777770151555555555550115115551115551122111221
5a5ba5b30008280000822280f9954ff90054599f00dbbba089aaaa9800edddc00600070799777777eeaaaaaa0115151515555550011155555511111022222221
5ba5bab5000080000008280099f959990f9f9ff90003bbba899aa9980001dddc06eeee7779700000aea000000011515555555500000155555555100012222211
35ba5bb300000000000080000f110f90099f999000003bba0898898000001ddc06eeeee799700000eea000000001151515555000000115511551100021222121
335babb50000000000000000005100000099f9000000033000800800000001100666767777000000aa0000000000011111100000000011101111000022111221
00000000000000000000000000000000000000000000000000000000000000000000000000000000007077707777777055555555414414155141441455555335
0000000000000100000000000000000000000000000000000000000000000000000000000000000007878887eeeeeee755555555441414155144141455553443
0000000000001710000000000000000000000000000000000000000000800000000000000000000078878787e7e7e7e753355555414414155514141453355555
000000000ddd3100000000000000000000000000000000000000000008a80000000dddd00000000007878787e7e7e7e734435555414144155514141434435555
00000000dbb3bd0000000000000009000000000000000000000000000380000000dbbbbd0000000007878787eeeeeee755555335414141555514141455555555
00000000dbbb3d000ddd000000009a900ddd000000000000000000003dddd00000dbbbbd00000000788888877777777055553443414141555144141455555555
0000000003b3d00ddbbbdd0000003900dbbbd00000000ddd00000000d3bbbd00000dbbd000000000077777700000000055335555414141555141441455533555
000000003d3bd0dbbbbbbbdd00030000dbbbbd000000dbbbdd000000db3bbd00000dbbd000000000000000000000000053443555414144155141414455344355
00000000dbbbbdbbbbddbbbbdddd3ddddddbbb10000dbbbbbbd000000db3d00000dbbbbd00000000000000000000000001111110000000000000000111110000
00000000dbbbbdbbdd80ddbbddb3bbbbdd0db17130dbbbddbbd000000dbb300000dbbbbd00000000000000000000001111515551000000000000011151551000
00000000dbbbbdbbd8a80dbbddbb3bbbbbdddb1bd3bbbd00dd0000800dbbd31000dbbbbd000000000aaa00000000015515151155000000000000055515155000
0000000dbbddbbdbbd80ddbbd0d3bdddbbbbddbbbb3bdddd000008a80dbb31710dbbddbbd00000009a09aa0000001515515155150aaa00000000115151515000
0000000dbbddbbdbb3ddbbbbd03dbbd0ddbbbddbbbb3dbbbd00003800db3d0100dbbddbbd000000090099aa000001151551151559a09aa000000151511155000
0000000dbbddbbdb3dbbbbddd00dcbd300dbbd0dbb39dbbbd00030000d3bd0000dbbddbbd0000000000911a0444155115515151590099aa04441511515515200
000000dbbd00dbbdb3bbddbbbddc7c3d000dbbddb39a9dbbbd00030000d3bd00dbbd00dbbd000000000911a44491151515515000000911a44491115551222120
000000dbbd00dbbdbb3ddbbbbbbdc3bd000dbbdd3bd90dbbbbd030ddd03bbd00dbbd00dbbd000000000911a44941155155122110000911a44941151512211220
000000dbbd00dbbdb3d1bbbddbbb3bbd000dbbd3bbd00dbbbbbd03bbbd3bbd00dbbd02dbbd000000000911a44494922212222222000911a44494922221122210
00000dbbd0000dbbdb171bd003b3dbbd000dbbdd3bd00dbbdbbb3dbbd0d3bd0dbbd02e2dbbd0000000aa99041949999001112211000911a4194999a212211120
00800dbbd0000dbbd3b1bbd03d9bdbbd000dbbddb3d00dbbddb3ddbbd0d93d0dbbd0320dbbd0000000000001449499aa0000000000aa99014494911512222210
08a8dbbddddddddbbd3bbbbdd9a9dbbd000dbbddb83000dbbd31bdbbdd9a93dbbdd3dddddbbd00000000001019419115150000000000001019411151aa111100
0083dbbbbbbbbbbbb3bbdbbbbb9ddbbd000dbbdd8a8300dbb3171dbbddb93bdbbbbb3bbbbbbd00000000010100141151aaa00000000001001014999a9aa00000
000d3bbbbbbbbbbb3bdd0dbbbdddbbd000dbbd0db83000dbbd31bbbbd0ddd3bbbbbbb3bbb3bbd000000001100100999a9aa0000000001001001099a9a9aa0000
000db3ddddddddddb3d000ddd00dbbd0ddbbbd0db3d000dbb30dbbbbbd003dbbdddddd3d3d3bd00000000010010099a9a9aa0000000000010100111515550000
00db3d0000000000db3d000000dbbdddbbbbd00d3bd000db3d00dbbbbd03dbbd0000008300d3bd00000000000010111515550000000000000100115151550000
0ddb3d0000000000db38dd000dbbbbbbbbdd00dbb3bd00d3bd000dbbbd0d3bb1000008a800db3dd0000000000010115151550000000000000010999a9aaa0000
dbb3d000000000000d8a8bd00dbbbbbbdd000dbb3bbbd0db3d0000dbbddbb31710000080000db3bd000000000010999a9aaa000000000000001099a9a9aa0000
db3bbd0000000000db38bbd000dddddd000000d3dddd0db3bd0000dbbddbbb310000000000dbbb3d00000000000099a9a9aa0000000000000000111515500000
0dd3bd0000000000d3bddd00000000000000000030000d3bbd0000dbbbddd3bd0000000000dbb3d0000000000000111515500000000000000001115151000000
003dd000000000000d3000000000000000000000000003ddd00000dbbbd03dd000000000000dd030000000000001115151000000000000000009a00000000000
0000000000000000000000000000000000000000000000000000000ddd0000000000000000000000000000000009a0000000000000000000009a000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a0000000000000000000009a0000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a0000000000000000000000000000000000000
52521ddddd112525ddddd5dddddddddd000000000089ab000001d0000001d000000000000000000033332833333122330005500000009a9a00000000009a9944
5521ddddd1d15255dd1dd5ddddd5dddd00777700080000c050115d0500115d0000004440000000003333283333121223000550000009a4440005500005a49454
52521dddd1dd1125dddddd5dddd5dddd070000708000c00d011155d0511155d504449ff4440004403328a7283321712300005500005a4449000555005a449445
5511ddd1ddd15215dddddd5ddd5dddd10700707090000d02511155d5011155d04fff9fff9f444ff433289a28332212135500550005a4449405505500a5494544
51521d1ddd151515dddddd5ddd5ddddd07000070a0000008011155d0511155d54fff444f9fff9ff4333a2833333221335555a5a05a5449450555a4a054594454
512151ddd1555215ddddd151dd5dd1dd07000070b000000e511155d5011155d00444000444ff944033b3283333333b330055599a454449440055499aa5954440
5251551ddd152525dddddd1dd151dddd007777000c0000e00011110050111105000000000044400033a33333333333a30000a99aa45494540000a99aa4945525
552551ddd1515255d1dddddddd1ddddd0000000000d28e000085580000855800000000000000000033b33333333333b300000a499555954000000a4995555525
000000000001200000000000000000000001200000000000000010000000000000010000000010000000000000010000000054a999555250005a5aa99a555525
00000000000ba0000000000000000000000ba000000000000000100000000000000100000000100000000000000100000005a5454955552505a54545a4005225
00000000000ba0000000000000000000000ba00000000000000100000000000000001000000010000000000000010000005a5455550522259a44599550000555
00000000000250000000000000000000000250000000000000010000000000000000100000010000000000000000100009a4444555505550a449954550000000
00000000000ba0000000000000000000000ba000000000000010000000000000000001000001000000000000000010009a444499552500009994445555000000
00000000000ba0000000000000000000000ba00000000000101000000222222000000101001000000000000000000100a4449945252500009445445552500000
00000000000250000000000000000000000250000000000010100000211111120000010101100000000000000000011094494454522500004544542222500000
00000000000ba0000000000000000000000ba00000000000100100021122881120001001010100000222222000001010a4945440055000004454405555500000
00000000000ba0000000000000099900000ba0000099900001010002112828112000101010010000211111120000100100060000000000600006000000000060
00000000000250000000000000909090000250000909090001001002111281112001001010001002112288112001000100070006000000700007000006000070
00000000000ba0000000000009090009000ba0009000909000100102112828112010010001001002112828112001001000000007000600000000000007000000
00000000000ba0000000000090909090900ba0090909090900011012112288112101100000100102111281112010010000000000000700000600000000000000
00000000000250000000000090090900090250900090900900000111211111121110000000010102112828112010100006000000000000000700000000000006
00009999000ba0009999000090090900990ba0990090900900000001121111211000000000001012112288112101000007000600000060000000006000060007
00990900990ba0990090990009900909009ba9009090099000000001121111211000000000000111211111121110000000000700000070006000007000070000
09900090009259000900099000099009009259009009900000000110121111210110000000011001121111211001100000000000000000007000000000000000
90099009009ba9009009900900000990909ba9090990000000011001002112001001100000100111121111211110010000000000000000000000600000000000
9900090999bbab99909000990000000999bbab999000000000100010021111200100010001000000121111210000001060000006000000060000700000600000
90909999009259009999090900000990909259090990000001000100021111200010001001000001002112001000001070000007000600070000000000700600
09999000909ba9090009999000099090099ba9900909900001000100021111200010001010000010021111200100000100060000000700000000000000000706
9090090999bbab99909009090990900999bbab999009099010001000008282000001000110000100021111200010000100070000000000000060000000000007
90099990145251450999900990909099145251459909090910001000002828000001000100000100021111200010000000000000000000000070060000000000
09990000154ba1540000999090099900154ba1540099900900010000010000100000100000001000008282000001000000000600000060000000070000060000
00000000115ba1150000000009990000115ba1150000999000010000001001000000100000001000002828000001000000000700000070000000000000070000
00000000000000000000000000000000000000000000000000010000000000000000100000010000010000100000100000000000000000000000000000000000
0000000060000000cccccccccccc7c7c770000008808888800010000000000000000100000010000001001000000100000000000000000000000000000000000
0060006676600060d00000000000000007000000aa89999900001000000000000001000000001000000000000001000000000000000000000000000000000000
0007d6006006d700d000000000000000070000008a89898900001000000000000001000000001000000000000001000000000000000000000000000000000000
000d706676607d00d00000000000000007000000aa89999900000100000000000010000000000100000000000010000000000000000000000000000000000000
0006070070070600d000000000000000070000008a88888800000100000000000010000000000010000000000100000000000000000000000000000000000000
0060606070606060d00000000000000007000000aa80000000000010000000000100000000000001100000011000000000000000000000000000000000000000
0060600d7d006060ddddcdcdccccccccc70000008800000000000010000000000100000000000000000000000000000000000000000000000000000000000000
067677776777767643435dddddddd4dddddddddddd55343400000000000000000000000000000000000000000000000000888800000000000000000000000000
0060600d7d0060604435dddddd5dd4ddddd4ddddd5d5434400000000000000000000bb00000bb000b00000000000000008000080000000000000000000000000
006060607060606043435ddddddddd4dddd4ddddd5dd553400000000000000000bbbccbbbbbccb0bcb0000000000000080008008000000000000000000000000
00060700700706004455ddd5dddddd4ddd4dddd5ddd543540000700000000000bccbcbbcccbcbcbcb00000000000c00080000808000000000000000000000000
000d706676607d0045435d5ddddddd4ddd4ddddddd5454540000000000000000bcbbcbbcbcbccbbccb000000000c8a0080000008000000000000000000000000
0007d6006006d700453545ddddddd545dd4dd5ddd544435400000000007000000bcbccbcbcbcbcbcb00000000000a00080000008000000000000000000000000
00600066766000604345445ddddddd5dd545dddddd5434340000000000000000bccbbbbcccbb0bbccb0000000000000008000080000000000000000000000000
0000000060000000443445ddd5dddddddd5dddddd545434400000000000000000bb0000bbb00000bb00000000000000000888800000000000000000000000000
0001000000001000001000000000010070000000000fffff01110111011111113333333300000000000000111111111140400004000040400040000400004000
0001000000001000000100000000100006000000fff222221ccc1ccc1ddddddd3333333311111111111111111111111140040055500400404040005550004040
1001000000001001010100000000101000700000eef2f2f2011c1c1c1d1d1d1d3333333300000000000000000000000004004044404004004004004440040040
1000100220010001010010000001001000060000eff222220ccc1c1c1d1d1d1d33333b3300001100000000000000000000400455540040004000405550400040
0110012222100110001010022001010000007000feffffff1c111c1c1ddddddd3333b33300110000100111001001000007767744477677600440074447004400
0001122dd2211000001001222210010000000600eef000001ccc1ccc111111113333b33300111111001101101111010066766765676676660004676567640000
0000022dd22000000001122dd221100000000070ff00000001110111000000003333333300100000011000101100010066676654566766660006665456660000
00011222222110000000022dd2200000000000060000000000000000000000003333333300011000010001101100010000000054500000000077605450677000
011001222210011000011222222110007600000070000000000000000aaaaaaa0aa0000033333333011111001010010000000054500000000777005450077700
1000100220010001001001222210010000760000600000000aaaaaaaa44444443bbaa00033333333000100001000010000004454544000006660445454406660
100100222200100100101002200101000000760007000000a999a999a4a4a4a43b3bba0033333333000000000100001000040111110400006604011111040666
0001002222001000010010222201001000000076060000000aa9a9a9a4a4a4a403b3bba033b33333000000000100000100040114110400000004011411040066
0010008228000100010010222201001000000000007000000a99a9a9a444444403bb3ba0333b3333000000000100000000040004000400000000400400400000
0010000000000100010100822800101000000000006000000aa9a9a9aaaaaaaa003bb3ba333b3333000000110111000000400004000040000000400400400000
000100000000100000010000000010000000000000070000a999a999a000000000033bba33333333000000011110000004000004000004000004000400040000
0001000000001000000011100111000000000000000600000aaaaaaa000000000000033033333333000000001100000040000004000000400040000400004000
__gff__
0001010404040408010100040404040800020804040404000004040404040400000000040404040000040408080808100000000404100210100000080808080000000000000000000000000000000000000000000000000000000404040404040000000000000000000004040404040400000000000000000000040404040404
0000000000000404040400000404040404040404040404040404040404040404040404040404040404040404080808080404040404040404040404040808080808080000000004040404040400000000080800000000000000000000000000000404040404000000000000000000000004040404040400000000000000000000
__map__
2010101010108a101010101010101030d2d3d4d3d4d300d3d4d3d400d4d3d4d54d4c4f4c4f4c4f4c4f4c4f4c4f4c4f4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0000d7000000d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2010001010101f1010101010e8101030d2d400d4d3d4d3d4d3d4d3d4d3d4d3d54d4f4c4f4c4f4c4f4c4f4c4c4f004f4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00d60000000000d600000000d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2010108b10101f1000108b1f10e81030d2d3d4d3d4d3d4d3d4d3d4d3d4d3d4d54d4c4f004f4c4f4c4f4c4f4f4c4f4c4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00d700d60000000000000000000000d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
201010101010101f101010e810101030d2d4d300d3d4d3d4d3d4d3d3d400d4d54d4f4c4f4c4f4c4f004f4c4c4f4c4f4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000d6000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20101f10001f10101010101010108b30d2d4d4d4d4d3d4d3d3d4d4d4d3d4d3d54d4c4f4c4f4c4f4c4f4c4f4f00004c4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000d7d60000000000000000d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
201010101000101010001f1010101030d2d4d4d3d4d300d4d3d4d3d4d3d4d4d54d4f4c4f4c4f4c4f4c4f4c004c4f4c4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0000000000000000000000000000d7d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
201010f910f910e81010108b10101030d2d3d4d3d4d4d3d3d4d3d4d3d4d3d3d54d4c4f4c4f4c4f4c4c4f4c4c4f4c4f4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000d6d700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20108b10101010108a10101000101030d2d4d3d4d3d3d4d3d400d4d4d3d4d4d54d4f4c4f4c4f4c00004c4f4f4c4f4c4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
201010101010e81f1f10100010101030d2d300d3d3d4d300d3d4d3d3d4d3d4d54d4c4f4c004c4c4f4c4f4c4c004c4f4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0000000000d70000000000d6d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2010f9108b10101f10001f10108a1030d200d3d4d400d4d3d4d3d400d3d400d54d4f00004f4c4f4c4c4c4f4f4c4f4c4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0000d60000000000d700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20101010101f00101ff91010101f1030d2d300d4d3d4d3d400d4d3d3d4d3d4d54d4c4f4f4c4f4c4f004f4c4c004c4f4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000d7000000000000d7000000d700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
201010101010108a1010f910101f1030d2d3d4d3d3d4d3d4d4d4d3d4d3d4d3d54d4f4c4c4f4c4f4c4c4c4f4f4c4f4c4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000d600000000d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20108a10001f101f1010101f10001030d2d3d300d4d3d4d3d3d4d3d4d3d4d4d54d4c4f4c004c4f4c4c4f4c4c4f4c4f4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000000000d6d70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20101f0010101f1010108b1010101030d2d4d4d3d3d4d3d4d4d3d400d4d3d3d54d4f4c4f4c4f004f4f4c4f4f4c4f4c4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0000d70000d6000000d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
201010101f10001ff91010108a101030d2d3d4d3d4d3d400d3d4d3d4d3d4d3d54d4c4f4c4f4c4f4c4c004c4f4f4c4f4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f000000000000000000d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20e8001010101010101010101f101f30d2d400d4d3d3d4d3d4d3d4d3d4d3d3d54d4f4c4f4c4f4c4f4f4c4f4c4c4f4c4e3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00d60000000000000000000000d700d7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011200200c552005020e552105520c5520e552005020c5520c5520e552005020c5520c55210552005020c5520e5520e552005020c552005020e552105520c5520e552005020e5520c5520e552005020c55200502
011200201055500505115551355510555115550050511555105551355500505105551055513555005051055511555115550050510555005051155513555105551155500505115551055511555005051055500505
011200201555500505155551755515555155550050515555155551755500505155551355517555005051555515555155550050515555005051555517555155551555500505155551555515555005051355500505
0110002028525285052854528505285552850528535285052652526505265452650526555265052653526505285252850528525245052452528505245452850529555295052b5552b50526555295052953529505
000100000e7500f740100401203015030170301a0201c0201f02022710267102c7102a5002d500325003650037500005000050000500005000050000500005000050000500005000050000500005000050000500
011200200c552005020c5520c5520e552005020e5520c5520e552005020e5520c5520e552005020e5520c5520e5520e552105520e552005020c552005020e552105520c5520e552005020c5520c5520e55200502
011200201055500505115551055511555005051155510555135550050511555105551355500505115551055513555135551355511555005051055500505115551355510555115550050511555105551355500505
011200201555500505155551555515555005051755515555175550050517555155551755500505175551555517555175551755515555005051555500505155551755515555155550050515555155551755500505
00010000207501b740197301672014710117000f70000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000200002f1203013031140321502b1302a1402915028160350003500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000203501b4401533013430123301342018320204501f4301e4201d410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002025022250261502816028150232301d23013740117601c1601f14021130211301d23018240112500f76012250161301812019130130500e0500c0500774007720057100471004710047100471000000
000100001a750207601a0501874000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000013711137111471115711167111671117711197111c7211e7211e7211e7211e7311e7311f7311f7311f7312074122741247412675129751297612a7612a7612b7712d7712f7713277136771397713d771
010100000855604756034560155601666013560a5560955608756075560675605456044560355602456017560b7060b4060a40608406084060130601706017060170602706047060570600406004060040600406
0002000033170306402d0502a62028230250102d1602a6402804026620252302302022030220102816026630250402562023540222201f040251702363022640202201d0401d0201f1601c6301b6501904018020
000200000b6100b6100c6100d6100e6200f6201062010620116201262014620156201662017630186301a6301c6301d6401f64020640226402465026650296502a6502d660306603366035660376603a6703c670
011200200c5520c552105520e552000000c552000000e552105520c5520e552000000c5520c5520e552000000e5520c5520e552000000c55200000105520e5520e552000000c55200000105520e5520e55200000
011200201055510555135551155500000105550000011555135551055511555000001155510555135550000011555105551155500000105550000013555135551355500000105550000013555135551355500000
011200201555513555175551555500000155550000015555175551555515555000001555515555175550000015555155551555500000155550000017555175551755500000155550000017555175551755500000
000200003005033050350503605030050290502f0503205033050310501b050200502205023050230501d0501e05020050220502405024050210501c0501e05023050240501e0501c0501e0501f0501d05019050
011000201275210752127521075212752007021075210752107520070200702127521075212752007021275210752127520070212752107521075212752007021275210752127521075200702107521275212752
0110002015752157521575213752157520c7021575215752157520c7020c7021775215752157520c7021575213752157520c702157521375213752157520c702157521575215752137520c702137521575215752
0110002018052180521b052170521b0520c0021805218052180520c0020c0021b052180521b0521800218052170521b052180021805217052170521b0520c00218052180521b052170520c002170521805218052
011000201075200700127521075210752007000070010752107521075200700107520070012752107521075212752007001275210752107520070000700107521075210752007000070013752107521275212752
011000201575200000157521575213752000000000015752157521575200000157520000015752137521575215752000001575215752137520000000000157521575215752000000000017752157521575215752
01100020180521800018052180521705200000000001805218052180521800018052180001b05217052180521b05218000180521805217052000000000018052180521805218000180001b052180521805218052
011000201275210752107521275200000127521075210752127520000012752107521075200000127521075210752127520000000000127521075212752000001075210752107520000000000137521075213752
011000201575213752137521575200000157521375215752157520000015752157521375200000157521375213752157520000000000157521375215752000001575215752157520000000000177521575217752
011000201805217052170521b052000001b05217052180521b05200000180521805217052000001805217052170521b052000000000018052170521b0520000018052180521805218000180001b052180521b052
011000200e7520a7520c7520e752000000e7520a7520c7520e752000000e7520a7520c7520e7520a7520e752000000c752000000c7520c7520a752000000c7520c7520a752000000c7520c7520e7520a75200700
0110002011755117551175511755117551175511755117550f7550f7550f7550f7550f7550f7550f7550f75511755117551175511755117551175511755117550f7550f7550f7550f7550f7550f7550f7550f755
01100020150521304215032150250c005150521304215032150250c0051505213042150321502213022150250c005150550c0051505215042130350c0051505215042130350c005150521504215032130250c005
011000200c752007020c7520c7520a752007020c7520c7520e75200702007020c7520c7520a752007020a752007020c752007020e7520a7520c7520c752007020c7520c7520a752007020c7520a7520a7520e752
011000200e7550e7550e7550e7550e7550e7550e7550e7550f7550f7550f7550f7550f7550f7550f7550f7550e7550e7550e7550e7550e7550e7550e7550e7550f7550f7550f7550f7550f7550f7550f7550f755
01100020150550c0001505215042110350c0001505215042150350c0000c0001505213042130350c000130550c000150550c000150521304215032150250c0001505215042130350c00015052130421303215025
011000200e7520e7520c752007020a7520e7520c752007020e7520a7520c7520e752000000a752007020a7520e7520c752007020e7520c752007020e7520c7520c752000000e7520a7520c7520c7520a75200000
011000201505215042130350c0001505215042130350c000150521304213032150250c000150550c0001505215042130350c00015052130450c0001505213042130350c00015052130421503215022150250c000
0002000008052070520705208052090520b05210052150521405213052130521305214052170521b0521a0521905218052190521b0521d05221052200521f0521f0522005221052250522b0522a0522b0522f052
01100000116010060100601006011164100601006010060110601006010060100601116310060100601006010e601006010060100601116210060100601006010c60100601006010060111611006010060100601
012000000c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c7530c753
01180000185551a555185551c5551855515555185551a5551a5521a5551c5521c55515552155551a5521a5551855515555185551d5551855515555185551c5551d5521d55515552155551a5521a5551c5521c555
011800001c7521c7421c7321c7221c7121770217702177021d7521d7421d7321d7221d7121570215702157021c7521c7421c7321c7221c7121f7021f7021f70215752157421573215722157121a7021a7021a702
01180020185551a555185551c5551855515555185551d5551d5521d5551c5521c5551c5521c5551a5521a555185551a555185551c555185551c555185551a55515552155551d5521d55521552215551c5521c555
011800201c7521c7421c7321c7221c71200000000000000015752157421573215722157120000000000000001c7521c7421c7321c7221c7120000000000000001875218742187321872218712000000000000000
011000200c5530050300503005030c5530050300655000000c5530c55300503005030c5530050300655000000c5530050300503005030c5530050300655000000c5530c55300503005030c553005030165500655
012000201311113521131321354115151155421513115521131121352113131135421115111541111321152113111135221313113541171521754117131175221311113521131321354110151105421013110521
012000201125611356134560030113256153561545600301132561335613456003011325613356114560030115256153561145600301132561335615456003011125611356154560030113256113561145600301
01100020130550000500005000051305500005000050000513055000050000500005130550000500005000050c0550000500005000050d0550000500005000050c0550000500005000050d055000050000500005
011000200c055000000c05500000240550000018055000000e055000000e0550000026055000001a055000001005500000100550000028055180001c055180001105500000110550000029055000001d05500000
011000200c055000000c0550c055240550c055180550c0550e055000000e0550e05526055000001a0550e0551005500000100551005528055100551c055100551105500000110551105529055000001d05511055
011000200c7530c75500705007050d7530d75500705007050c7530c75500705007050d7530d75500705007050c7530c75500705007050d7530d75500705007050c7530c75500705007050d7530d7550070500705
01100020012550f25500205032550f2550125500205012550f25500205012550f2550020501255122550020501255122550625500205012550f25500205012550f255012550f25500205012550d255032550f255
01100020017520175201752017520175203752037520375203752037520375206752067520675206752067520675206752087520875208752087520875208752087520a7520a7520a7520a7520a7520a7520a752
011000200375203752037520375203752067520675206752067520675206752087520875208752087520875208752087520a7520a7520a7520a7520a7520a7520a7520d7520d7520d7520d7520d7520d7520d752
01100020012550f25520355032550f2550125520355012550f25522355012550f2552235501255122552335501255122550625500205012550f25500205012550f255012550f25500205012550d255032550f255
01100020012550f25520355032550f2550125520355012550f25522355012550f2552235501255122552335501255122550625522355012550f25520355012550f255012550f2551e355012550d255032550f255
011000200a7520e7520e7520c752000000e7520c7520a7520e7520e7520c752000000e752000000e752000000e7520a7520c7520e752000000e7520c7520e7520c752000000e7520a7520c7520e7520c75200000
01100020150521505215052130550c0001505213052150550c00015052150550c000150550c000130550c0000c0001505213052150550c0001505213052150550c0000c000150521505213052150521305518000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 01 42 43 44
00 01 02 43 44
00 01 02 03 44
00 06 07 08 44
02 12 13 14 44
01 16 42 43 44
00 19 17 43 44
00 1c 1a 18 44
00 19 1d 1b 44
00 1c 1a 1e 44
00 16 1d 1b 44
00 19 1a 1e 44
00 16 17 18 44
00 19 1a 1b 44
02 1c 1d 1e 44
01 41 20 43 44
00 1f 20 43 44
00 1f 20 21 44
00 22 23 24 44
00 22 23 43 44
00 41 23 43 44
00 41 20 43 44
00 25 20 43 44
00 3a 20 3b 44
02 25 23 26 44
03 28 29 43 44
01 2a 2b 43 44
02 2c 2d 43 44
01 31 42 43 44
00 32 42 43 44
02 33 42 43 44
01 36 42 43 44
00 37 42 43 44
00 2e 36 43 44
00 2e 37 43 44
01 2e 36 35 44
00 2e 37 35 44
00 2e 36 38 44
00 2e 37 38 44
00 2e 36 39 44
02 2e 37 38 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
