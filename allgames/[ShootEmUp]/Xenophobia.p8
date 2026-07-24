pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--xenophobia v1.0
--bellwether games

t=0
at=0
lt=0
scene="main_menu"
level=0
explosions={}
smoke={}
scroll={}
bosstrigger=10


function explode(x,y)
 add(explosions,{x=x,y=y,t=0})
 make_smoke(x,y)
 make_smoke(x,y)
 make_smoke(x,y)
 make_smoke(x,y)
 make_smoke(x,y)
end

function make_smoke(startx, starty)
 local smoke_particle={
  x=startx,
  y=starty,
  t=0,
  life_time=rndb(10,20),
  size=1,
  max_size=1+rnd(3),
  dy=rnd(0.7)*1,
  dx=rnd(0.7)-0.2,
  ddy=rndb(0.02,0.07),
  col=7,
 }
 add(smoke,smoke_particle)
end

function abs_box(s)
 local box={}
  box.x1 = s.box.x1 + s.x
  box.y1 = s.box.y1 + s.y
  box.x2 = s.box.x2 + s.x
  box.y2 = s.box.y2 + s.y
 return box
end

function coll(a,b)
 local box_a=abs_box(a)
 local box_b=abs_box(b)
 
 if box_a.x1>box_b.x2 or
    box_a.y1>box_b.y2 or
    box_b.x1>box_a.x2 or
    box_b.y1>box_a.y2 then
  return false
 end
 return true
end

function rndb(low,high)
 return flr(rnd(high-low+1)+low)
end

function _init()
 score=0
 t=0
 lt=0
 for i=0,128 do
  add(scroll,{
   x=i*1,
   y1=0,
   y2=0,
   dy=rndb(5,10),
   col=0,
   on=false,
  })
 end
 if scene=="main_menu" then
  music(-1)
  music(14)
  _update = update_menu
  _draw = draw_menu
 end
 if scene=="level" then
  _update=update_game
  _draw=draw_game
 end
end

function update_menu()
 if scene=="main_menu" then
 at+=1
 if at>20 then
  at=0
 end
  if (btnp(5)) then
   scene="level"
   level+=1
   scroll.on=true
  end
 end
 if scroll.on==true then
  lt+=1
  music(-1,1000)
  for l in all(scroll) do
   l.y2+=l.dy
  end
  if lt>80 then
   make_game()
   scroll.on=false
   for l in all(scroll) do
    l.y1=0
    l.y2=0
   end
  end
 end
end

function draw_menu()
 
 if scene=="main_menu" then
  cls()
  --line(64,0,64,128,7)
  rect(2,2,125,125,2)
  rect(1,1,126,126,1)
  rect(4,4,123,123,8)
  rect(7,7,120,120,14)
  print("bellwether games presents",15,24,14)
  spr(199,24,38,5,2)
  spr(231,64,38,5,2)
  spr(192,36,52,7,4)
  if at<5 then
   print("press — to play",33,98,14)
  else
   print("press — to play",33,98,8)
  end
 end
 if scroll.on==true then
  for l in all(scroll) do
   line(l.x,l.y1,l.x,l.y2,l.col)
  end
 end
end

function game_continue()
 music(-1)
 music(20)
 t=0
 player={
  x=-32,
  y=58,
 }
 stars={}
 for i=1,64 do
  add(stars,{
   x=rnd(128),
   y=rndb(30,78),
   spd=rndb(1,3),
  })
 end
 _update=update_continue
 _draw=draw_continue
end

function update_continue()
 t+=1
 at+=1
 player.y+=sin(t/75)
 if at>200 then
  at=0
 end
 if t<15 then
  player.x+=6
 else
  player.x+=0
 end
 if t>15 then
  if at<100 then
   player.x+=.3
  else
   player.x-=.3
  end
 end 

 for s in all(stars) do
   s.x-= s.spd
   if s.x<=0 then
    s.x=128
    s.y=rndb(30,78)
   end
  end
 if (btn(5)) then
  sfx(9)
  t=0
  lt=0
 end
 if player.x>128 then
  scroll.on=true
 end
 if scroll.on==true then
  lt+=1
  music(-1,1000)
  for l in all(scroll) do
   l.y2+=l.dy
  end
  if lt>80 then
  level+=1
   make_game()
   scroll.on=false
   for l in all(scroll) do
    l.y1=0
    l.y2=0
   end
  end
 end
end

function draw_continue()
 cls()
 for s in all(stars) do
  pset(s.x,s.y,7)
 end
 if at<100 then
  spr(204+32,player.x,player.y,4,2) 
 else 
  spr(204,player.x,player.y,4,2)
 end
 line(0,24,36,24,8)
 print("stage clear!",40,22,14)
 line(88,24,128,24,8)
 line(0,84,20,84,1)
 print("press — to continue",24,82,12)
 line(106,84,128,84,1)
 if level==1 then
  if score<600 then
   print("no score bonus",36,92,7)
  end
  if score>=600 then
   print("score bonus!",40,92,7)
   print("powershot full",36,102,6)
  end
  if score>800 then
   print("1st pod ship",40,112,6)
  end
  if score>1000 then
   print("2nd pod ship",40,122,6)
  end
 end
 if level==2 then
  if score<2000 then
   print("no score bonus",36,92,7)
  end
  if score>=2000 then
   print("score bonus!",40,92,7)
   print("powershot full",36,102,6)
  end
  if score>2200 then
   print("1st pod ship",40,112,6)
  end
  if score>2500 then
   print("2nd pod ship",40,122,6)
  end
 end
 if scroll.on==true then
  for l in all(scroll) do
   line(l.x,l.y1,l.x,l.y2,l.col)
  end
 end
end

function game_win()
  music(-1)
  music(24)
 _update=update_win
 _draw=draw_win
end

function update_win()
 scene="main_menu"
 level=0
 if(btnp(5)) then
  lt=0
  scroll.on=true
 end
 if scroll.on==true then
  lt+=1
  music(-1,1000)
  for l in all(scroll) do
   l.y2+=l.dy
  end
  if lt>80 then
   _init()
   scroll.on=false
   for l in all(scroll) do
    l.y1=0
    l.y2=0
   end
  end
 end
end

function draw_win()
 cls()
 --line(64,0,64,128,7)
 spr(70,32,14,8,2)
 spr(10,48,64,4,4)
 print("the xeno force has",28,35,14)
 print("been defeated! rest easy",17,45,14)
 print("hero, a new journey awaits...",7,55,14)
 print("thanks for playing!",27,99,12)
 print("final score: " ..score,31,109,7)
 if scroll.on==true then
  for l in all(scroll) do
   line(l.x,l.y1,l.x,l.y2,l.col)
  end
 end
end

function game_over()
 music(-1)
 _update = update_over
 _draw = draw_over
end

function update_over()
 scene="main_menu"
 level=0
 if(btnp(5)) then
  lt=0
  scroll.on=true
 end
 if scroll.on==true then
  lt+=1
  music(-1,1000)
  for l in all(scroll) do
   l.y2+=l.dy
  end
  if lt>80 then
   _init()
   scroll.on=false
   for l in all(scroll) do
    l.y1=0
    l.y2=0
   end
  end
 end
end

function draw_over()
 cls()
 print("game over",47,64,8)
 if scroll.on==true then
  for l in all(scroll) do
   line(l.x,l.y1,l.x,l.y2,l.col)
  end
 end
end

function make_game()
 t=0
 del(shots,s)
 del(enemies,e)
 del(boss)
 del(explosions)
 del(powerups)
 del(health)
 make_player()
 make_enemies()
 make_boss()
 make_level()
 _update=update_game
 _draw=draw_game
end

function update_game()
 if scene=="level" then
  t+=1
  at+=1
  if at>20 then
   at=0
  end
  update_level()
  control_player()
  control_enemies()
  
  if #enemies<bosstrigger then
   control_boss()
  end
 
  for ex in all(explosions) do
   ex.t+=2
   if ex.t==20 then
    del(explosions, ex)
   end
  end
  
  for p in all(smoke) do
   p.y+=p.dy
   p.x+=p.dx
   p.dy+=p.ddy
   p.t+=1/p.life_time
   p.size=max(p.size,p.max_size*p.t)
   if p.t>0.7 then
    p.col=6
   end
   if p.t>0.9 then
    p.col=5
   end
   if p.t>1 then
    del(smoke,p)
   end
  end 
 end  
end

function draw_game()
 
 if scene=="level" then
  cls()
  draw_level()
  draw_enemies()
	 if #enemies<bosstrigger then
   draw_boss()
  end
  for ex in all(explosions) do
	  circ(ex.x,ex.y,ex.t/2,3+ex.t%10)
	  --circfill(ex.x,ex.y,ex.t/4,11+ex.t%5)
	 end
	 for p in all (smoke) do
	  circfill(p.x,p.y,p.size,p.col)
  end
  draw_player()
 end
end

function make_level()
 tcard={
  x1=0,
  y1=45,
  x2=0,
  y2=58,
 }
 
 if level==1 then
  music(-1)
  music(0)
  stars={}
  debris={}
  planet={
   x=100,
   y=0,
   mapx=70,
   mapy=-30,
   }
  junky=0
  junkspd=3
  for i=1,32 do
   add(debris,{
    x=rnd(128),
    y=rnd(128),
    s=rnd(3)+1.5 
   })
  end
  for i=1,128 do
   add(stars,{
    x=rnd(128),
    y=rnd(128),
   })
  end
 end
 
 if level==2 then
 
  if score>600 then
   player.p=3
  end
  if score>800 then
   helper1.alive=true
  end
  if score>1000 then
   helper2.alive=true
  end
  
  music(-1)
  music(4)
  debris={}
  clouds1y=0
  clouds1spd=.5
  clouds2y=0
  clouds2spd=1
  for i=1,32 do
   add(debris,{
    x=rnd(128),
    y=rnd(128),
    s=rnd(3)+1 
   })
  end
 end
 
 if level==3 then
 
  if score>2000 then
   player.p=3
  end
  if score>2200 then
   helper1.alive=true
  end
  if score>2500 then
   helper2.alive=true
  end
  
  music(-1)
  music(9)
  debris={}
  cityy=0
  cityspd=.5
  cloudsy=0
  cloudsspd=2
  for i=1,32 do
   add(debris,{
    x=rnd(128),
    y=rnd(128),
    s=rnd(3)+1
   })
  end
 end
 
end

function draw_level()
 
 if level==1 then
  
  for st in all(stars) do
   pset(st.x,st.y,6)
  end
  circfill(planet.x,planet.y,32,1)
  circ(planet.x,planet.y,32,6)
  circ(planet.x,planet.y,31,12)
  map(0,0,planet.mapx,planet.mapy,8,8)
  for d in all(debris) do
	  pset(d.x,d.y,6)
	 end
	 map(64,0,0,junky,4,16)
	 map(68,0,96,junky,4,16)
	 map(64,0,0,junky-128,4,16)
	 map(68,0,96,junky-128,4,16)
	 
	 if t<100 then
	  rectfill(tcard.x1,tcard.y1,tcard.x2,tcard.y2,5)
	 end
	  
	 if t>10 and t<80 then
   print("high orbit, perihelion",20,48,7)
   line(32,56,92,56,7)
  end
	end
	
	if level==2 then
  
	 rectfill(0,0,128,128,3)
	 map(8,0,0,clouds1y,32,16)
	 map(8,0,0,clouds1y-128,32,16)
	 map(24,0,0,clouds2y,2,16)
	 map(26,0,112,clouds2y,2,16)
	 map(24,0,0,clouds2y-128,2,16)
	 map(26,0,112,clouds2y-128,2,16)
	 for d in all(debris) do
	  pset(d.x,d.y,7) 
	 end
	 
	 if t<100 then
	  rectfill(tcard.x1,tcard.y1,tcard.x2,tcard.y2,5)
	 end
	 
	 if t>10 and t<80 then
   print("planet 12, upper clouds",20,48,7)
   line(32,56,92,56,7) 
  end
	end
	
	if level==3 then
	 rectfill(0,0,128,128,2)
	 
	 map(32,0,0,cityy,32,32)
	 map(32,0,0,cityy-128,32,32)
	 
	 map(48,0,0,cloudsy,32,32)
	 map(48,0,0,cloudsy-128,32,32)
	 
	 for d in all(debris) do
	  pset(d.x,d.y,7) 
	 end
	 
	 if t<100 then
	  rectfill(tcard.x1,tcard.y1,tcard.x2,tcard.y2,5)
	 end
	 
	 if t>10 and t<80 then
   print("empyrean, capital city",18,48,7)
   line(32,56,92,56,7) 
  end
	end
	
end

function update_level()
 tcard.x1+=2*t
 if t>78 then
  tcard.x2+=t
 end
 
 if level==1 then
 
  planet.y+=.03
  planet.mapy+=.03
  
  junky+=junkspd
  if junky+128>256 then
   junky=0
  end
  
  for d in all(debris) do
   d.y+= d.s
   if d.y>=128 then
    d.y=0
    d.x=rnd(128)
   end
  end
 end
 
 if level==2 then
  clouds1y+=clouds1spd
  if clouds1y+128>256 then
   clouds1y=0
  end
  clouds2y+=clouds2spd
  if clouds2y+128>256 then
   clouds2y=0
  end
  
  for d in all(debris) do
   d.y+= d.s
   if d.y>=128 then
    d.y=0
    d.x=rnd(128)
   end
  end
 end
 
 if level==3 then
  cityy+=cityspd
  if cityy+128>256 then
   cityy=0
  end
  
  cloudsy+=cloudsspd
  if cloudsy+128>256 then
   cloudsy=0
  end
  
  for d in all(debris) do
   d.y+= d.s
   if d.y>=128 then
    d.y=0
    d.x=rnd(128)
   end
  end
 end
 
end
-->8
--player

function make_player()
	player={
	 x=56,
	 y=100,
	 dx=0,
	 dy=0,
	 ax=0,
	 ay=0,
	 h=3,
	 p=0,
	 t=0,
	 imm=false,
	 dead=false,
	 spr=1,
  box = {x1=0,y1=0,x2=7,y2=7},
  }
 helper1={
  alive=false,
  x=player.x-12,
  y=player.y,
  sp=38,
  box={x1=3,y1=0,x2=4,y2=7},
  }
 helper2={
  alive=false,
  x=player.x+12,
  y=player.y,
  sp=38,
  box={x1=3,y1=0,x2=4,y2=7},
  }
 helperb={}
 bullets={}
 powershot={}
 helperup={}
 powerups={}
 health={}
 lpts={}
 bpts={}
end

function fire()
 sfx(0)
  b = {
  sp=19,
  x=player.x,
  y=player.y,
  dy=-5,
  box = {x1=0,y1=0,x2=7,y2=7},
 }
 add(bullets,b)
  
 if helper1.alive==true then
  add(helperb,{
   sp=54,
   x=helper1.x,
   y=helper1.y,
   dy=-5,
   box={x1=3,y1=0,x2=4,y2=7},
  })
 end 
 if helper2.alive==true then
  add(helperb,{
   sp=54,
   x=helper2.x,
   y=helper2.y,
   dy=-5,
   box={x1=3,y1=0,x2=4,y2=7},
  })
 end  
end

function fire_powershot()
 sfx(5)
 player.p=0
 p = {
  sp=35,
  w=3,
  h=2,
  x=player.x,
  y=player.y,
  dy=-7,
  box = {x1=0,y1=0,x2=24,y2=16},
 }
 add(powershot,p)
end

function draw_player()
 
 if not player.imm or t%8 < 4 then
  
  if (btn(0)) then
   spr(player.spr+1,player.x,player.y)
   elseif (btn(1)) then
    spr(player.spr+2,player.x,player.y)
   else spr(player.spr,player.x,player.y) 
  end
 end
 
 for b in all(bullets) do
  spr(b.sp,b.x,b.y)
 end
 
 for h in all(helperb) do
  spr(h.sp,h.x,h.y)
 end
 
 if (btnp(4)) then
  spr(48,player.x-3,player.y-6)
  spr(48,player.x+4,player.y-6) 
 end
 
 for p in all(powershot) do
  spr(p.sp,p.x-8,p.y,p.w,p.h)
 end
 
 for p in all(powerups) do
  if at<18 then
   spr(p.sp,p.x,p.y)
  else
   spr(p.sp+1,p.x,p.y)
  end
 end

 for h in all(health) do
  if at<18 then
   spr(h.sp,h.x,h.y)
  else
   spr(h.sp+1,h.x,h.y)
  end
 end
 
 for l in all(lpts) do
  spr(l.sp,l.x,l.y,2,2)
 end
 
 for b in all(bpts) do
  spr(b.sp,b.x,b.y,2,2)
 end
 
 for h in all(helperup) do
  spr(h.sp,h.x,h.y)
 end
  
 if helper1.alive==true then
  spr(helper1.sp,helper1.x,helper1.y)
 end
 
 if helper2.alive==true then
  spr(helper2.sp,helper2.x,helper2.y)
 end
 
 rectfill(0,116,128,128,0)
 rect(-1,116,128,127,5)
 
 for i=1,3 do
  if i<=player.h then
 		hspr=16
 	else
 		hspr=17
 	end
  spr(hspr,92+6*i,118)
  if i<= player.p then
   pspr=32
  else
   pspr=17
  end
  spr(pspr,64+6*i,118)
 end
  
 --hud
 if t<60 then
  if at<10 then
   print("get ready",42,110,10)
  end
 end
 if player.h<=0 then
  if at<10 then
   print("!!may day!!",42,110,9)
  end 
 end
 
 --health bar
 spr(18,118,118)
 spr(18,90,118,1,1,true,false)
 --power bar
 spr(18,90,118)
 spr(18,62,118,1,1,true,false)
 --score
 print("score:" ..score,2,120,7)
 
end

function control_player()
 helper1.x=player.x-8
 helper1.y=player.y
 helper2.x=player.x+8
 helper2.y=player.y
 
 if (btn(0)) and player.x>8 then
  player.ax=-0.38
 else
  player.ax=0
 end
 if (btn(1)) and player.x+12<128 then
  player.ax=0.38
 end
 if (not btn(0) and not btn(1)) player.ax=0
 if (btn(2)) and player.y>0 then
  player.ay=-0.38
 else
  player.ay=0
 end
 if (btn(3)) and player.y+24<128 then
  player.ay=0.38
 end
 if (not btn(2) and not btn(3)) player.ay=0
 player.dx+=player.ax
 player.dy+=player.ay
 
 --drag
 if player.ax == 0 then
  player.dx*=0.7
 end
 
 if player.ay == 0 then
  player.dy*=0.7
 end
 
 --max speed
 if player.dx>3 then
 	player.dx=3
 elseif player.dx<-3 then
  player.dx=-3
 end
 
 if player.dy>1.5 then
 	player.dy=1.5
 elseif player.dy<-1.5 then
  player.dy=-1.5
 end
 
 player.x+=player.dx
 player.y+=player.dy
 
 if boss.dead==true and boss.y>70 then
  player.y-=5
 end
 
 if boss.dead==true and boss.y==72 then
  sfx(9)
 end
 
 bns=rndb(1,10)
 --fire
 if (btnp(4)) then fire() end
 
 for b in all(bullets) do
  b.y+=b.dy
  if b.y <0 then
   del(bullets,b)
  end
  for e in all(enemies) do
   if coll(b,e) then
    del(enemies,e)
    del(bullets,b)
    score+=3
    explode(e.x,e.y)
    sfx(3)
    if bns==1 then
     add(powerups,{
      sp=33,
      x=e.x,
      y=e.y,   
      dy=1,
      box = {x1=1,y1=1,x2=6,y2=6},
     })
    end
    if bns==2 then
     add(health,{
      sp=49,
      x=e.x,
      y=e.y,   
      dy=1.3,
      box = {x1=1,y1=1,x2=6,y2=6},
     })
    end
    if bns==3 then
     add(lpts,{
      sp=102,
      x=e.x,
      y=e.y,   
      dy=1.7,
      box = {x1=2,y1=5,x2=13,y2=12},
     })
    end
    if bns==4 then
     add(bpts,{
      sp=104,
      x=e.x,
      y=e.y,   
      dy=2,
      box = {x1=1,y1=5,x2=14,y2=12},
     })
    end
    if bns==5 then
     add(helperup,{
      sp=38,
      x=e.x,
      y=e.y,   
      dy=2.5,
      box = {x1=2,y1=1,x2=6,y2=5},
     })
    end
   end
  end
  if coll(boss,b) then
   del(bullets,b)
   explode(b.x,b.y)
   sfx(6)
   boss.l-=1
  end 
 end
 
 for h in all(helperb) do
  h.y+=h.dy
  if h.y <0 then
   del(helperb,h)
  end
  for e in all(enemies) do
   if coll(h,e) then
    del(enemies,e)
    del(helperb,h)
    score+=3
    explode(e.x,e.y)
    sfx(3)
    if bns==1 then
     add(powerups,{
      sp=33,
      x=e.x,
      y=e.y,   
      dy=1,
      box = {x1=1,y1=1,x2=6,y2=6},
     })
    end
    if bns==2 then
     add(health,{
      sp=49,
      x=e.x,
      y=e.y,   
      dy=1.5,
      box = {x1=1,y1=1,x2=6,y2=6},
     })
    end
    if bns==3 then
     add(lpts,{
      sp=102,
      x=e.x,
      y=e.y,   
      dy=1.7,
      box = {x1=2,y1=5,x2=13,y2=12},
     })
    end
    if bns==4 then
     add(bpts,{
      sp=104,
      x=e.x,
      y=e.y,   
      dy=2,
      box = {x1=1,y1=5,x2=14,y2=12},
     })
    end
    if bns==5 then
     add(helperup,{
      sp=38,
      x=e.x,
      y=e.y,   
      dy=2.5,
      box = {x1=2,y1=1,x2=6,y2=5},
     })
    end
   end
  end
  if coll(boss,h) then
   del(helperb,h)
   explode(boss.x,boss.y)
   sfx(6)
   boss.l-=1
  end 
 end
 
 for p in all(powerups) do
  p.y+=p.dy
  if p.y >128 then
   del(powerups,p)
  end
  if coll(player,p) then
   del(powerups,p)
   player.p+=1
   sfx(4)
  end
 end
 
 for h in all(health) do
  h.y+=h.dy
  if h.y >128 then
   del(health,h)
  end
  if coll(player,h) then
   del(health,h)
   player.h+=1
   sfx(4)
  end
 end
 
 for l in all(lpts) do
  l.y+=l.dy
  if l.y >128 then
   del(lpts,l)
  end
  if coll(player,l) then
   del(lpts,l)
   score+=50
   sfx(4)
  end
 end
 
 for b in all(bpts) do
  b.y+=b.dy
  if b.y >128 then
   del(bpts,b)
  end
  if coll(player,b) then
   del(bpts,b)
   score+=100
   sfx(4)
  end
 end
 
 for h in all(helperup) do
  h.y+=h.dy
  if h.y >128 then
   del(helperup,h)
  end
  if coll(player,h) then
   if helper1.alive==true then
    helper2.alive=true
   else
    helper1.alive=true
   end
   del(helperup,h)
   sfx(4)
  end
 end
 
 if player.h>3 then
  player.h=3
 end
 
 if player.h<= 0 then
  player.t+=1
  if player.t<60 then
   player.y+=3
   explode(player.x+rndb(-2,8),player.y+rndb(-2,8))
   sfx(3)
  elseif player.t>60 then
   game_over()
  end
 end
 
 if player.p>=3 and (btn(5)) then fire_powershot() end
 for p in all(powershot) do
  p.y+=p.dy
  if p.y+16 <0 then
   del(powershot,p)
  end
  if coll(p,boss) then
   explode(p.x+4,p.y+4)
   boss.l-=3
   sfx(6)
  end
  for e in all(enemies) do
   if coll(p,e) then
    del(enemies,e)
    score+=5
    explode(e.x,e.y)
    sfx(3)
    if ps==1 then
     add(powerups,{
      sp=33,
      x=e.x,
      y=e.y,   
      dy=1,
      box = {x1=0,y1=0,x2=7,y2=7},
     })
    end
   end
  end
 end
 
 if player.imm then
  player.t+=1
  if player.t>30 then
   player.imm=false
   player.t=0
  end
 end
end


-->8
--enemies

function make_enemies()
 k=0
 st=0
 enemies={}
 if level==1 then
  for i=1,60 do --60
   add(enemies,{
    spr=rndb(4,5),
    y=-40,
    m_x=rndb(40,80),
    m_y=-120-i*rndb(15,30),
    r=rndb(5,30),
    box = {x1=0,y1=0,x2=7,y2=7},
   })
  end
 end
 
 if level==2 then
  for i=1,85 do --85
   add(enemies,{
    spr=rndb(6,7),
    y=-40,
    m_x=rndb(40,80),
    m_y=-120-i*rndb(10,20),
    r=rndb(5,40),
    box = {x1=0,y1=0,x2=7,y2=7},
   })
  end
 end
 
 if level==3 then
  for i=1,110 do --110
   add(enemies,{
    spr=rndb(8,9),
    y=-60,
    m_x=rndb(40,80),
    m_y=-120-i*rndb(10,20),
    r=rndb(5,50),
    box = {x1=0,y1=0,x2=7,y2=7},
   })
  end
 end
 
 shots={}
end

function make_boss()

 bt=0
 boss_shot1={}
 boss_shot2={}
 if level==1 then
  boss={
   sp=64,
   x=100,
   y=-40,
   dx=0,
   dy=0,
   ax=0,
   ay=0,
   tetherx=56,
   tethery=20,
   l=50, --50
   dead=false,
   box = {x1=0,y1=0,x2=15,y2=15}
  }
 end 
 
 if level==2 then
  boss={
   sp=66,
   x=100,
   y=-40,
   dx=0,
   dy=0,
   ax=0,
   ay=0,
   tetherx=20,
   tethery=32,
   tt=0,
   l=100, --100
   dead=false,
   box = {x1=0,y1=0,x2=15,y2=15}
  }
 end 
 
 if level==3 then
  boss={
   sp=68,
   x=100,
   y=-40,
   dx=0,
   dy=0,
   ax=0,
   ay=0,
   tetherx=20,
   tethery=40,
   tt=0,
   l=200, --200
   dead=false,
   box = {x1=0,y1=0,x2=15,y2=15}
  }
 end
end

function draw_enemies()
 if #enemies<bosstrigger then
  draw_boss()
 end
 
 for e in all(enemies) do
  if at<rnd(20) then
   spr(e.spr,e.x,e.y)
  else
   spr(e.spr+16,e.x,e.y)
  end
 end
 
 for s in all(shots) do
  if at<5 then
   spr(s.sp,s.x,s.y)
  else
   spr(s.sp+16,s.x,s.y)
  end
 end
end

function draw_boss()
 if bt<60 then
  if at<10 then
   print("!!boss aproaching!!",26,110,8)
  end
 end
 if boss.y<80 then
  if at<10 then
   spr(boss.sp+32,boss.x,boss.y,2,2)
  else
   spr(boss.sp,boss.x,boss.y,2,2)
  end
 end

 for b in all(boss_shot1) do
  if at<5 then
   spr(b.sp,b.x,b.y)
  else
   spr(b.sp+16,b.x,b.y)
  end
 end
 
 for b in all(boss_shot2) do
   spr(b.sp,b.x,b.y,3,2)
 end
end


function control_enemies()
 k+=1
 if k>75 then
  k=0
 end 
 
 st+=1
 if st>20 then
  st=0
 end
 
 if level==1 then
  for e in all (enemies) do
   if e.spr==4 then
    e.m_y+=rndb(.5,2.5)
    e.x = 40*sin(t/200) + e.m_x
    e.y = 40*cos(t/0) + e.m_y
   else
    e.m_y+=rndb(.5,1)
    e.x = e.r*sin(t/100) + e.m_x
    e.y = e.r*cos(t/100) + e.m_y
   end
  end
 end
 
 if level==2 then
  for e in all (enemies) do
   if e.spr==6 then
    e.m_y+=rndb(.5,1.5)
    e.x = 40*sin(t/300) + e.m_x
    e.y = 40*cos(t/200) + e.m_y
   else
    e.m_y+=rndb(.5,1)
    e.x = e.r*sin(t/150) + e.m_x
    e.y = e.r*cos(t/100) + e.m_y
   end
  end
 end
  
 if level==3 then
  for e in all (enemies) do
   if e.spr==8 then
    e.m_y+=rndb(.5,2)
    e.x = e.r*sin(t/125) + e.m_x
    e.y = 60*cos(t/200) + e.m_y
   else
    e.m_y+=rndb(.5,1)
    e.x = 40*sin(t/300) + e.m_x
    e.y = e.r*cos(t/100) + e.m_y
   end
  end
 end
 
 for e in all(enemies) do
  if k==rndb(25,50) and e.y>0 then
   add(shots,{
    sp=15,
    x=e.x,
    y=e.y,
    dy=rndb(1.5,3),
    box = {x1=3,y1=3,x2=6,y2=6},
   })
   sfx(2)
  end
  if coll(player,e) and not player.imm then
   player.imm=true
   player.h-=1
   sfx(1)
  end
  if coll(helper1,e) and helper1.alive==true then
   del(enemies,e)
   helper1.alive=false
   sfx(1)
  end
  if coll(helper2,e) and helper2.alive==true then
   del(enemies,e)
   helper2.alive=false
   sfx(1)
  end
  if e.y>125 then
   del(enemies,e)
  end
 end
 
 for s in all(shots) do
  s.y+=s.dy
  if s.y >128 then
   if s.x>128 or s.x<0 then
    del(shots,s)
   end
  end
  if coll(player,s) and not player.imm then
   del(shots,s)
   player.imm=true
   player.h-=1
   sfx(1)
  end
  if coll(helper1,s) and helper1.alive==true then
   del(shots,s)
   helper1.alive=false
   sfx(1)
  end
  if coll(helper2,s) and helper2.alive==true then
   del(shots,s)
   helper2.alive=false
   sfx(1)
  end
 end 
end

function control_boss()
 bt+=1
 
 if bt<75 and boss.dead==false then
  boss.y+=1
  boss.x-=1.2
 end
 
 if level==1 then
  if bt>75 and boss.dead==false then
   if boss.x<boss.tetherx then
    boss.ax=.3
   elseif boss.x>boss.tetherx then
    boss.ax=-.3
   end
 
   if boss.y<boss.tethery then
    boss.ay=.05
   elseif boss.y>boss.tethery then
    boss.ay=-.05
   end
   boss.dx+=boss.ax
   boss.dy+=boss.ay
 
   if boss.dx>15 then
    boss.dx=15
   elseif boss.dx<-15 then
    boss.dx=-15
   end
 
   boss.x+=boss.dx
   boss.y+=boss.dy
  end
 end
 
 if level==2 then
  
  if bt>75 and boss.dead==false then
   
   boss.tt+=1
   if boss.tt>320 then
    boss.tt=0
   end
   if boss.tt>160 then
    boss.tetherx-=.5
    boss.tethery-=sin(boss.tt/75)
   else
    boss.tetherx+=.5
    boss.tethery+=sin(boss.tt/75)
   end
    
   if boss.x<boss.tetherx then
    boss.ax=1
   elseif boss.x>boss.tetherx then
    boss.ax=-1
   end
 
   if boss.y<boss.tethery then
    boss.ay=.5
   elseif boss.y>boss.tethery then
    boss.ay=-.5
   end
   boss.dx+=boss.ax
   boss.dy+=boss.ay
 
   if boss.dx>.5 then
    boss.dx=.5
   elseif boss.dx<-.5 then
    boss.dx=-.5
   end
 
   boss.x+=boss.dx
   boss.y+=boss.dy
  
   if k==rndb(10,20) and bt>75 then
    add(boss_shot1,{
     sp=47,
     x=boss.x+4,
     y=boss.y+4,
     dy=rndb(2,3),
     dx=rndb(50,100),
     box = {x1=0,y1=0,x2=7,y2=7},
    })
    sfx(7)
   end
  end
 end
 
 if level==3 then
  
  if bt>75 and boss.dead==false then
   
   boss.tt+=1
   if boss.tt>320 then
    boss.tt=0
   end
   if boss.tt>160 then
    boss.tetherx-=.5
    boss.tethery-=sin(boss.tt/80)
   else
    boss.tetherx+=.5
    boss.tethery+=cos(boss.tt/80)
   end
    
   if boss.x<boss.tetherx then
    boss.ax=.4
   elseif boss.x>boss.tetherx then
    boss.ax=-.4
   end
 
   if boss.y<boss.tethery then
    boss.ay=.4
   elseif boss.y>boss.tethery then
    boss.ay=-.4
   end
   boss.dx+=boss.ax
   boss.dy+=boss.ay
 
   if boss.dx>15 then
    boss.dx=15
   elseif boss.dx<-15 then
    boss.dx=-15
   end
 
   boss.x+=boss.dx
   boss.y+=boss.dy
  
   if k==rndb(10,30) and bt>75 then
    add(boss_shot1,{
     sp=47,
     x=boss.x+4,
     y=boss.y+4,
     dy=rndb(2,3),
     dx=rndb(50,100),
     box = {x1=0,y1=0,x2=7,y2=7},
    })
    sfx(7)
   end
  
   if k==rndb(10,20) and bt>75 then
    add(boss_shot2,{
     sp=39,
     x=boss.x-2,
     y=boss.y+4,
     dy=5,
     box = {x1=0,y1=0,x2=23,y2=15},
    })
    sfx(8)
   end
  end
 end
 
 for b in all(boss_shot1) do
  b.y+=b.dy
  b.x+=sin(t/b.dx)
  if b.y >128 then
   if b.x>128 or b.x<0 then
    del(shots,s)
   end
  end
  if coll(player,b) and not player.imm then
   del(boss_shot1,b)
   player.imm=true
   player.h-=1
   sfx(1)
  end
 end 
 
 for b in all(boss_shot2) do
  b.y+=b.dy
  if b.y >128 then
   if b.x>128 or b.x<0 then
    del(boss_shot2,b)
   end
  end
  if coll(player,b) and not player.imm then
   player.imm=true
   player.h-=1
   sfx(1)
  end
 end
 
 if coll(player,boss) and not player.imm then
  player.imm=true
  player.h-=1
  sfx(1)
 end
  
 if boss.l<=0 then
  boss.dead=true
  score+=2
 end

 if boss.dead==true then
  boss.y+=.5
  boss.x+=0
  if k<75 and boss.y<80 then
   explode(boss.x+rndb(2,14),boss.y+rndb(2,16))
   sfx(3)
  end
  if boss.y>90 then
   if level<3 then
    game_continue()
   else
    game_win()
   end
  end
 end
 
 if k==rndb(20,55) and bt>75 and boss.dead==false then
  for i=1,3 do 
   add(shots,{
    sp=15,
    x=(boss.x-6)+i*8,
    y=boss.y+8,
    dy=rndb(1,3),
    box = {x1=3,y1=3,x2=6,y2=6},
   })
   sfx(2)
  end
 end
end
__gfx__
0000000000066000000660000006600000000000002ee2000c0000c00060060033000033003bb300333333333333333333333333333333330000000000000000
00000000000660000006600000066000099aa9900e6666e001011010066ee660033aa33003bbbb30333333333333333333333333333333330000000000000000
00700700a005500a0a5560a00a0655a099aaaa99e668866e00011000665ee5660a3333a00bb1cbb03333333333333333333333333333333300000000000aa000
00077000a05c750a05c756a00a65c75005666650e268862e00122100652882560173371003b11b30dd1111113333333333333333333333330000000000a77a00
00077000e051c50e051c56e00e651c50056dd650022222200026720052d88d2501a77a10063bb360dd1111113333333333333333333333330000000000a77a00
00700700e851158e051158e00e85115099aaaa99e200002e1025620152d88d25080aa080088788808811111133333333333333333333333300000000000aa000
00000000886556880855688008865580099aa99020000002c002200c052ee250000aa0000368873088111111b3b3b3b3b3b3b3b3b3b3b3b30000000000000000
00000000800660080866008008006680000000000e0000e0c000000c0050050000000000003bb300dd1111113333333333333333333333330000000000000000
00000000000000007000000070000007099aa99000000000000000000060060033000033003bb300dd111188e333333333ddddddd11111330000000000000000
888888885555555567000000a000000a99aaaa99002ee2000c0110c0065ee560033aa33003b1cb30dd11188e663b3b3b3bddddddd111113b0000000000000000
eeeeeeee5d5d5d5d6600000090000009056666500e6666e001011010652882560a3333a003b11b30dd11188ed633333333eeeeedd11111330000000000099000
8e8e8e8edddddddd660000000000000005666650e668866e0012210052d88d2501733710063bb360dd111888ddb3b3b3b3eeeeedd11111b300000000009aa900
88888888dddddddd66000000a000000a056dd650226886221026720152d88d2501a77a1008878880dd111a888b3b3b3b3bddddddd111113b00000000009aa900
888888885d5d5d5d6500000000000000056dd650e222222ec025620c552882550b0aa0b0088888808811a9aaaab3b3b3b3ddddddd11111b30000000000099000
8888888855555555550000000000000099aaaa9922000022c002200c055ee550000aa0000368873088119a9a9abbbbbbbbeeeeeee11111bb0000000000000000
00000000000000005000000090000009099aa99002e00e20000000000050050000000000003bb300dd1e8999a9eb3b3b3beeeeeee111113d0000000000000000
00000000000000007000000700000007777777777000000000000000900000000000000000000009dd1e888aa8ebbb7777ddddddd11111dd00000000000aa000
1111111100111100070cc070000007777777777777700000000aa00000000090000000000900000088e888aa888e777777ddddddd1111dd80000000000a99a00
cccccccc011c711000177100000777cccccccccccc77700000655600a0000000000000000000000a8a9818a98e8a777777eeeeeee111dd88000000000a97a9a0
1c1c1c1c01c777100c7777c00077ccc0000000000ccc770000e55e00900000a0000000000a000009da911a998e99a77777eeeeeee11ddddd00000000a97a7a9a
1111111101cc7c100c7777c0077c0007777777777000c77000855800a90000aa00000000aa00009ad991a9a88e799a7777ddddddd1dddddd00000000a9a7a79a
11111111011cc1100017710077c07c777777777777c70c77000660009900000aaaaaaaaaa000009989a199888e77997777ddddddd8888dd8000000000a9a79a0
1111111100111100070cc0707c07c777cccccccc777c70c700000000a9a00000aaaaaaaa00000a9a881a98e18e77777777ddeeee8888dd880000000000a99a00
0000000000000000700000077c7c7c000000000000c7c7c700000000a99a9000000000000009a99add1918e18e7777dd11ddeeeddddddddd00000000000aa000
0000000000000000700000077cc7c00000000000000c7cc700077000a9a9a90000000000009a9a9add119e118e777ddd11dddddddddddddd0000000000099000
0000000000888800070ee0707c70000077777777000007c7000aa000a90a9aaa99999999aaa9a09add1a8e1118e7ddee11ddd8888888888800000000009aa900
00000000088e788000877800cc00000777777777700000cc00099000aa90a9aaaaaaaaaaaa9a09aadd118e1118eddeee11ee8888888888880000000009aa7a90
0000000008e777800e7777e07c00007700000000770000c7000000000aa9000aaaaaaaaaa0009aa0dd18e91118eddddd11eddddddddddddd000000009aa7a7a9
0009000008ee7e800e7777e0c0000070000000000700000c000aa00000aa9990000000000999aa00dd18e19118eddddd11dddddddddddddd000000009a7a7aa9
00090000088ee8800087780070000000000000000000000700000000000aaa999999999999aaa0008818e111d8edeeee188888888888dd880000000009a7aa90
000a000000888800070ee070000000c0000000000c0000000000000000000aaaaaaaaaaaaaa00000666666656555565656656666668dd88800000000009aa900
0a000a000000000070000007100000000000000000000001000990000000000aaaaaaaaaa000000055555555555555555555555555dddddd0000000000099000
009022eeee2209000000000c70000000990009900990009908800880088888800088880008888880008888000888880008800880000880000000000000000000
099eeeeeeeeee990c700000cc00000c7099003999930099008800880088888800888888008888880088888800888888008800880000880000000000000000000
09a2666666662a90cc0600dddd0060cc059933b99b33995008800880000880000880088000088000088008800880088008800880000880000000000000000000
0aa6667777666aa00066dddddddd6600015993bbbb39951008800880000880000880088000088000088008800880088008800880000880000000000000000000
0aa667d88d766aa00665dd1111dd5660051999bbbb99915008800880000880000880088000088000088008800880088008800880000880000000000000000000
0aa6678dd8766aa006551111111155600153999bb999351008800880000880000880088000088000088008800880088008800880000880000000000000000000
0aa6678dd8766aa0055522222222555006d3199999913d6008800880000880000880000000088000088008800880088008800880000880000000000000000000
09a267d88d762a9005522222222225500d631199991136d008800880000880000880000000088000088008800888880008800880000880000000000000000000
099222222222299005522e8dd8e2255006d3311111133d6008800880000880000880000000088000088008800888880008800880000880000000000000000000
009222222222290005522e8dd8e225500d60331cc13306d008800880000880000880000000088000088008800880088000888800000880000000000000000000
00ee20000002ee00055222222222255006d063bbbb360d6008800880000880000880088000088000088008800880088000088000000880000000000000000000
002e00000000e2000555222222225550055087bbbb68055008800880000880000880088000088000088008800880088000088000000880000000000000000000
002e00000000e2000055111111115500055038887883055008800880000880000880088000088000088008800880088000088000000000000000000000000000
0022ee0000ee2200c7050011110050c7000036888873000000888800000880000880088000088000088008800880088000088000000000000000000000000000
00022e0000e22000cc00000c700000cc0000033bb330000000888800088888800888888000088000088888800880088000088000000880000000000000000000
00000000000000000000000cc0000000000000000000000000088000088888800088880000088000008888000880088000088000000880000000000000000000
009022eeee220900000c7000000c7000990009900990009900000000000000000000000000000000000000000000000000000000000000000000000000000000
099eeeeeeeeee990000cc000000cc000099003999930099000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aeeeeeeeeeea90000600dddd006000059993b99b39995000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa2667777662aa00066dddddddd6600015999bbbb99951000666666066660000066666660666600000000000000000000000000000000000000000000000000
0aa667d88d766aa00665dd1111dd56600513999bb999315000666666666666000666666666666660000000000000000000000000000000000000000000000000
0aa6678dd8766aa00655111111115560015319999991351000666666666666000666666666666660000000000000000000000000000000000000000000000000
0aa2678dd8762aa0055522222222555006d3119999113d6000777777677776000677777776777760000000000000000000000000000000000000000000000000
09a2222222222a90c7522222222225500d631111111136d0007cccc777cc7700077c77cc777cc770000000000000000000000000000000000000000000000000
0992222222222990cc522567765225c706d3311cc1133d60007c77777c77c70007cc7c77c7c77c70000000000000000000000000000000000000000000000000
009e22222222e90005522567765225cc0d60331cc13306d0007cccc77c77c700077c7c77c7c77c70000000000000000000000000000000000000000000000000
002e00000000e200055222222222255006d063bbbb360d60007777c77c77c700007c7c77c7c77c70000000000000000000000000000000000000000000000000
0ee2000000002ee00555222222225550055087bbbb680550007cccc777cc7700007c77cc777cc770000000000000000000000000000000000000000000000000
0ee0000000000ee00055111111115500055088887888055000777777077770000077777770777700000000000000000000000000000000000000000000000000
02e0000000000e200005001111005000000038888883000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02ee00000000ee20000c7000000c7000000036888873000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002e00000000e200000cc000000cc0000000033bb330000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b00b3333b000000b00dd005000000000222222222222222200bbbbb0bbbbb000000b00007777bb33000000000000000033bb7777222222222222222277677676
0033b3333b03b0000d5dd00000000000211122222222211200bbbbbbbbbbb00000bb00007777bbb330000000000000033bbb7777222222222222221176767767
333333b3033b33b3d5d5000000000005211122222111211200bb0bbbbb0bb0000b0b0000777b7bbb3300000000000033bbb7b777222222222222211177777777
0b33b333bb3b3333d05d50d0066000002ddd211221112dd2000bbbbbb0bbb00000bb00007777b7b3b33000000000033b3b7b7777222222112222111177767777
333bb333033333300005d51166650d002eee211228882ed200b0bb0bbb0bb00000bb0b00777b7b3b3330000000000333b3b7b777222221112221111176777777
b33333b033b03b30d00d5886166500002ddd2dd22ddd2dd2000b0bbbb0bbb0000bbb000077b7bbb3b33000000000033b3bbb7b77222211112211111177777677
bb33b33003330b0000d51168665500002eed28822d882ee200b0b0b0bbbbbb000bb0b000777b7b3b3300000000000033b3b7b77722211111211111ee77767776
333b3b003003303000006616655000dd2ddd2dd22ddd2dd2000b0b0b0bbbbb000bbb00007777bbb330000000000000033bbb77772211111111111ddd67777677
00000330000000005005566655dd0d5d22222112222221d20000b0b0bb0bbb000bb0b0007777b3330000000000000000333b7777211111de1111edee00000000
0003b33300300000006665655d55d5dd21d2d11d21122222000bbb0b0bbb0bb00bbb0000777bbb33000000000000000033bbb77711111ddd111ddddd00000000
003b030000b30b0006666555d50ddd5d22222dd22dd211120000bbb0b0bbb0b00bb00000777bb3300000000000000000033bb7771111deee11deeede00000000
0b000b0b0030b00000565550d05d50dd21122222222111110000b0bb0bbb0b000bb00000777bbb30000000000000000003bbb777111ddddd1ddddddd00000000
00330300000003000005500000d5000011112212222111110000bbb0b0bbb0b00bb00000777bb3300000000000000000033bb77711deeedeeeeddeee00000000
3bb30000030b000000000000d00dd000d11d2112222d111d0000b0bbbbbb0b0000bb0000777bb3330000000000000000333bb7771ddddddddddddddd00000000
3003bb0000000b30000000dd000000502dd221d22112ddd20000bbbbbbbbb0b000bb00007777bb33300000000000000333bb7777deeedeedeedeeede00000000
3300b00000000000000000000050000022222d222dd222220000bbbbb0bbbb00000b00007777bbb330000000000000033bbb7777dddddddddddddddd00000000
000660760000000700000000000000000000000000000000000bbbbbbbbbbb00000b00007777bbb330000000000000033bbb7777222222222222222200000000
077766776607067600000005566550000000060006000060000bbbb0bbbbbb00000b00b077777bbb3300000000000033bbb77777222222222222221100000000
0766776776070670006550006d6600000000000000005560000bbb0b0bbbbb00000b0000777b7bb333000000000000333bb7b777222222222222211100000000
0667706760600006005665006d660000000000000000565000bbbbb0bbbbb000000bb000777777bb3330000000000333bb777777222222112222111100000000
70766667006076600056650066650000006500000005d60000bbbb0b0bbb0b00000b0b007777b7b3b33300000000333b3b7b7777222221112221111100000000
776760707670706700566550550000000056000000566d0000bbbbbbbbb0b000000bb000777b7b7b3b333000000333b3b7b7b777222211112211111100000000
07606770670007060056dd5000000050005000000066550000bbbbb0bbbb0b00000bbb007777b7bbb3b3330000333b3bbb7b7777222111112111118800000000
0677700000000070005d666000000000000006000000000000bb0bbbbbb0b0000000bb0077777b7b3b3b33000033b3b3b7b777772211111111111ddd00000000
0607000000000006222221112222222291159115559555a500bbbbbbbbbb0b000b00bb007777b7bbb3b3330000333b3bbb7b7777211111d81111d88800000000
0660000000067070222211112222111151155115111111110bb0bbb0bbbbb000000bbb0077777b7b3b333000000333b3b7b7777711111ddd111ddddd00000000
00660060000000002221111122211111511a5119111111110b0bbb0b0bbbb0000b00bb007777b7bbb3b3300000033b3bbb7b77771111d8d8118888d800000000
070600000606606022111ddd221111115115511595559555b0b0bbb0bbbbb0000000bb0b777777bb3333000000003333bb777777111ddddd1ddddddd00000000
00677600070000702111ddee21118d88a115911555a555950b0bbbbb0bbbb000000bbb00777b7bb333300000000003333bb7b7771188d88888d8d88800000000
0000076006707060111ddddd111ddddd5115511511111111b0b0bbbbbb0b00000000b00077777bb330000000000000033bb777771ddddddddddddddd00000000
700000700066070011edeede11d8d8885119511a111111110b0bbb0bbbbb0000000bb0b07777bb33000000000000000033bb777788d888d88d888d8800000000
00060000000000001ddddddd1ddddddd511551159555a55500bbbbbbbbbb0000000b00007777bb30000000000000000003bb7777dddddddddddddddd00000000
00000000000000000000000000000000000000000000000000000000088108810888888108810881008888100888881000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000008810881088888810881088108888881088888810000000000111ccc7000000000000000
0000000000000000000000000000000000000000000000000000000008810881088100000881088108810881088108810000000051111111cc70000000000000
00000000000000000000000000000000000000000000000000000000088108810881000008810881088108810881088100066666551111111117c00000000000
000000000000000000000000000000000000000000000000000000000881088108810000088108810881088108810881006666666551111111111c5000000000
000000000000000000000000000000000000008ee000000000000000088108810881000008810881088108810881088100666666888885555555555666600000
00000000000000000000000000000000000008d66600000000000000088108810881000008881881088108810881088100d66682888888855555556666666000
00000000000000000000000000000000000008ddd600000000000000008888100888810008881881088108810888881000dd682828eeeeeeeaaaaaa666666600
00000000000000000000000000000000000008dddd00000000000000008888100888810008818881088108810888881000ddd2828eeeeeeeaaaaaaa666666600
0000000000000000011111110000000000000a888a99900009a9a9090881088108810000088188810881088108810000000dd2228e8e8e8e9a9a9a6d6d6d6d00
000000000000005111cc1ccccc10000000009aa9aa99999a9a90909008810881088100000881088108810881088100000000dd222222dddddddddddddddddd00
0000000000005511c1c11c7c77cc1000000089aaae000999a00000000881088108810000088108810881088108810000000000ddddddddddddddddddddddd000
0000000000555111111111ccc77cc100000e889998e0000000000000088108810881000008810881088108810881000000000000022228888889999990000000
000000000555111111111111cc777c10000e888888e0000000000000088108810881000008810881088108810881000000000000002222220000000000000000
0000066665551111111111111ccc77c100e88888e08e000000000000088108810888888108810881088888810881000000000000000000000000000000000000
000066666555111111111111111cc7cc1a908888ee9a000000000000088108810888888108810881008888100881000000000000000000000000000000000000
0000666665555111111111111111cc7c1a90888888a9000000000000188018800188880018888800188888800188880000000000000000000000000000000000
0000d666655555511111111111111cc1a95588888a98e0000000000018801880188888801888888018888880188888800000000000011ccc0000000000000000
00006d66665555555551111111111111995588e80998e000000000001880188018801880188018800018800018801880000000005111111c7700000000000000
0000d6d6d66655555555555555555555555568e66668e00000000000188018801880188018801880001880001880188000066666511111111c77aaaaaa000000
0000ddddd88888888555555555555555555668e66668e0000000000018801880188018801880188000188000188018800066666655111111111c7759a9000000
00000d828888888882885555555555556666668e66666600000000001880188018801880188018800018800018801880006666666555111111111c5666600000
000008288888888888828666666666666666668e6666666000000000188018801880188018801880001880001880188000666666888555111111155666666000
000082888888888828286666666666666666668e6666666000000000188888801880188018888800001880001888888000d66668888885555555555666666600
000828288888888282d6d6d6d66666666666668e6666666000000000188888801880188018888800001880001888888000dd6688888888555555556666666600
00828288888888282d6d6d6d6d6d6d6d6d666668e6666660000000001880188018801880188888800018800018801880000dd828888888866666666666666600
0828288888eeeeeeeeeeeeaaaaaaaa99d6d6d668e666666aaaaaa990188018801880188018801880001880001880188000002282888888dd6d6d6d6d6d6d6d00
828282888eeeeeeeeeeeeaaaaaaaa9999ddd6d6d6d6d6d6aaaaa999918801880188018801880188000188000188018800000282828288dddddddddddddddd000
282828288eeeeeeeeeeeeaaaaaaaa9009dddddddddddddaaaaaa90091880188018801880188018800018800018801880000022828eeeeeeeaaaaaa0000000000
2222228288e8e8e8e8e8e9a9a9a9a99992222e8e8e8e9a9a9a9a9999188018801880188018801880001880001880188000002828eeeeeeeaaaaaaa0000000000
02222222288888888888889999999999222222888888899999999990188018801888888018888880188888801880188000002228e8e8e8e9a9a9a00000000000
00222222222222000000000002222222222220000000000000000000188018800188880018888800188888801880188000000222222000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000009100b000008687b8008687a8000000868700888687898a8b8c00000000949585b494949495959495b400008585b000000000000000000000000000a18f000000a4000000a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b1b090818100009697b8009697b8000000969700009697999a9b9c00000000b5b5b5b494848584adae95b4948d8e00b1b000000000000000000000000000a000000000000092000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a000b180a0a100a6a7b800a6a700000088a6a700b8a6a7a9aaabac00000000858594b485850084bdbe84b4959d9e958fa1000000000000000000000000b0b000820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000081a1b090b000b6b7b800b6b7a80000a8b6b700a8b6b7b9babbbc00000000b5b5b5b5b5b5b5b5b5b5b5b484008485a0a0000000000000000000000000b1a000a30000000000a20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0091a0a000809000868700008687980000a8868700008687898a8b8c00000000958585b494959495b49595b484849594000000000000000000000000000000b0a300000000a400a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a1a0009080a1009697a8009697000000b8969700009697999a9b9c00000000b2b200b49400b2b2b48d8eb4b5b5b5b500b0000000000000000000000000000000a40000000082000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b1900081b00000a6a7a800a6a788000000a6a70098a6a7a9aaabac0000000000adaeb484b300b3b49d9eb495949495b10000000000000000000000000000a1a49300000000a4830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000b6b78800b6b7980000b8b6b700a8b6b7b9babbbc00000000b2bdbeb485858485b48485b5b5b5b5b5a0a1000000000000000000000000b0a0a500a400000092930000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008687a800868788000000868700888687898a8b8c00000000b5b5b5b49484b3b3b3b285adaeadae008fb0000000000000000000000000a18f00a40000000000a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009697b8009697980000a8969700989697999a9b9c00000000940085b4b5b5b3b200b384bdbebdbe95a000000000000000000000000000a08f00a5000000a400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000a6a79800a6a7a8000098a6a70000a6a7a9aaabac0000000094b2b2b4948d8eadae008400b3b39400b1b0000000000000000000000000b0a183a40000000000a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000b6b78800b6b7000000b8b6b70000b6b7b9babbbc00000000b5b5b5b4849d9ebdbe0085b3b2b39495000000000000000000000000000000a000a20000a400a4a50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000868700008687880000a8868700a88687898a8b8c00000000009494b48485b4b4009494b4b49595b5b00000000000000000000000000000000000a400000000a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009697b8009697880000a8969700989697999a9b9c00000000948485b4b5b5b5b4b5b5b5b4b4b5b5b5a0b0000000000000000000000000a1a0a4000000000092a30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000a6a70000a6a7a80000b8a6a700a8a6a7a9aaabac000000008584adae85840084958d8eb4848500948fa0000000000000000000000000b08f82a5000000a400a50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000b6b78800b6b7b8000000b6b70088b6b7b9babbbc00000000b3b2bdbe94848485949d9eb4b5b5b5b5a1b000000000000000000000000000a092930000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01060000163101b3300a3200031003400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000027650166201e6500e630146500661029600196001e6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000e1501d15015150121500b130081200511000110004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000365011650086501364004620006100160016500185001b5001f500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000c32418334243540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000131004330083500a3500a350127500a350093500c73008330063200a7300532005720037200132000310033000130000300000000000000000000000000000000000000000000000000000000000000
0006000002320123500a3400131000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000145501f550185501c5501a5501b5501c5501c5501c5501a55019550175501455012550105500b55005550015500050000500005000050000500005000040000400000000000000000000000000000000
00050000161501e1501515018150131501115010150101500e1500b150081500515004150021500015000100111000d1000a10007100011000210000000000000000000000000000000000000000000000000000
000400000e41010450124401343012430114300e4300e4300c4300943008430044200342002420014100041000410004100540005400054000370005400044000440003700044000440004400000000440000000
0116002002573186131165518613045731761310655186130057318613136551761302573186131165518613045731761311655186130557317613106551861302573176131165518613045730a6331365511655
011600200a070090600000009060000000906000000090600a070090600000009060000000907000000090600a070090600000009060000000906000000090600a07009060000000906000000090700000009060
01160020090500705000000070500000007050000000705000000070500405009050000000905000000090500a050090500000009050000000905000000090500a05009050000000905000000090500000009050
0116000015550155501555015555000000000000000000000000000000000000000000000095500e5501355015550155501555015555000000000000000000000000000000185501855018550165501655016550
01160000155501555015550155550000000000000000000000000000000000000000000000955018550135501555015550155501555500000000000000000000000000955018550155501a5500e5501855013550
011600200a0700906000000090600000009060000000906000000090600000009060000000907000000090600a070090600000009060000000906000000090600000009060000000906000000090700000009060
01160020025731861300000186130457317613000001861300573186130000017613025731861300000186130457317613000001861305573176130000018613025730f65502573186130d6550a6330f6550d655
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000200c773000000061300000266330000002613000000e7730000002613000002863300000006130000010773000000461300000246330000002613000000e77300000006130000028633000000261300000
012000000c7620c762000000f7620f76200000000000e7620c7620c762000000f7620f76200000000000e7620c7620c762000000f7620f76200000000000e7620c7620c7620c7620c76500000000000000000000
012000001176211762000001476214762000000000016762117621176200000147621476200000000001676211762117620000014762147620000000000137621176211762117621176500000000000000000000
012000000000022122201221f1221d122000001f122000000000000000000000000000000000000000000000000001b1221d1221f1221a122000001b122181221812500000000000000000000000000000000000
012000001a1221a122000001b1221b122000001d1221d1221a1221a122000001b1221b12200000000001d1221a1221a122000001b1221b122000001d1221d1221f1221f125000000000000000000000000000000
012000000000022122201221f1221d122000001f1221a1221b122000001d1221f1221f125000000000000000000001b1221d1221f1221a122000001b122181221812500000000000000000000000000000000000
011000200c773000000061300000266330000002613000000e7730000002613000002863300000006130000010773000000461300000246330000002613000000e77300000006130000028633000000e77328633
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000c7530e75330615107530c7230e753326150e7530c7530e75334615107530c7130e753306150e7530c7530e75332615107530c7230e753346150e7530c7530e75330615107530c7130e753326150e753
011400000043500000074352660000435004250742500435266000042503435004350242500435034250041500435000000743526600004350042507425004350000000425034350043502425004350342502415
011400000542500000084350000005425054350a4250543500000054350b4350000005425054350c4200c4300542500000084350000005425054350a4250543500000054350b4350000005425054350c4200c430
011400000c7530e75330615107530c7230e753326150e7530c7530e7533061510753306150e753306150e7530c7530e75330615107530c7230e753326150e7530c7530e75330615107530c7230e753326150e753
011400002472024720247202472526720267202672026725277202772027720277252672026720267202672524720247252472024725267202672026720267202972029720297202972527720277202772027725
011400002472024720247202472526720267202672026725277202772027720277252672026720267202672524720247202472024725000000000000000187201b7201a7201d7201b7201f720297202c7202b720
01140000297202972029720297250000000000297202b7202c7202c7202c7202c72500000000002b7202c7202e720167252c7201472530720187252e720227253172025725307202472533720277253272026725
011400000e4150c4150f4150c4150e4150c4250f4250c4250e4150c4150f4150c4150e4150c4250f4250c4250e4150c4150f4150c4150e4150c4250f4250c4250e4150c4150f4150c4150e4150c4250f4250c425
012000001a042000001f042000001b0420000018042000001a042000001f042000001b0420000018042000001a042000001f042000001b0420000018042000001a042000001f042000001b042000001804200000
012000000332403322033220332203322033220332203325023240232202322023220232202322023220232503324033220332203322033220332203322033250032400322003220032200322003220032200325
012000000077400770007700077000770007700077000770027700277002770027700277002770027700277000770007700077000770007700077000770007700277002770027700277002770027700277002770
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000c5200e5201052011520135201552017520185200e5301053011530135301553017530185301a5301053011530135301553017530185301a5301c53011540135401554017540185401a5401c5401d550
011800001c5401c5401c5401c5401c5401c5401c5401c5401f5401f5401f5401f5401f5401f540135401d5401c5401c5401c5401c5401c545000001c540185401a5401a5401a5401a5401a5401a5401a5401a540
011800001014004140101400414010140041401014004140131400c140131400c140131400c140131400c14015140051401514005140151400514015140051401314004140131400414013140041401314004140
0118000018530185301853018530185301853018530185301a5301a5301a5301a5301a5301a530185301a5301c5301c5301c5301c5301c5301c5301d5301c5301a5301a5301a5301a5301a5301a5301a5301a535
011800001014004140101400414010140041401014004140111400c140111400c140111400c140111400c140111400e140111400e140111400e140111400e1401314005140131400514013140051401314005140
01060000137511375113751137511375113751137511375115751157511575115751157511575115751157510c7510c7510c7510c7510c7510c7510c7510c7510e7510e7510e7510e7510e7510e7510e7510e751
011800003071032710347103271030710327103571034710307103271034710327103071032710377103571030710327103471032710307103271035710377103971037710357103471035710347103271034710
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c623000000000000000296160000028612000000e623000000000000000286160000000000000001062300000000000000026616000002b612000000c62300000000000000029616000000000000000
0110000021720217202172021720217202172021720217201f7201f7201f7201f7201f7201f7201f7201f7201c7201c7201c7201c7201c7201c7201c7201c7201f7201f7201f7201f7201f7201f7201f7201f720
0110000010720107201072010720107201072010720107200c7200c7200c7200c7200c7200c7200c7200c72015720157201572015720157201572015720157201072010720107201072010720107201072010720
0110000018720187201872018720187201872018720187201c7201c7201c7201c7201c7201c7201c7201c7201d7201d7201d7201d7201d7201d7201d7201d7201f7201f7201f7201f7201f7201f7201f7201f720
011000001072010720107201072010720107201072010720117201172011720117201172011720117201172013720137201372013720137201372013720137201572015720157201572015720157201572015720
011000001053010530115301153013530135301553015530000000000015530155301353000000185300000000000000001153011530105301053000000000000c5300c5300e5300e53010530105301353013530
011000000000000000135301353011530115301853018530000000000015530155301753017530185301853000000000001c5301c5301a530000000000000000155301553017530175301c5301c5301f5301f530
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 0f 10 43 44
01 0a 0b 0d 44
02 0a 0c 0e 44
00 41 42 43 44
01 14 15 43 44
01 14 15 17 44
00 14 15 17 44
00 1a 16 18 44
02 1a 15 19 44
01 1e 1f 22 44
00 1e 1f 23 44
00 21 20 24 25
02 1e 1f 23 44
00 41 42 43 44
01 26 42 43 44
01 26 42 43 28
02 26 27 43 28
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 2a 2f 43 44
01 2b 2c 30 44
02 2d 2e 30 44
00 41 42 43 44
01 32 35 34 37
02 32 33 36 38
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
