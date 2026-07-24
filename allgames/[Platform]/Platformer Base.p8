pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--platformer base

--by remagamer

function _init()
 --initializes the game.
 --change the palette a bit.
 pal(13,0)
 --put together the menu.
 menuitem(1,"stage select",selector)
 menuitem(2,"sfx",sfxer)
 menuitem(3,"debug",debugger)
 menuitem(4,"corrupt",corruptor)
 --variables and such.
 entitylist={} --list of entities.
 visuallist={} --list of visuals.
 initcourses() --sets up courselist.
 initplayer(0,0,1) --sets up player.
 cam={x1=0,x2=0,y1=0,y2=0} --the camera.
 menuchoice=1 --menu choice.
 inputdelay=0 --delay inputs.
 dead=0 --a thing for death.
 dead2=0 --another thing for death.
 --modes.
 mode=0
 --0 is title
 --1 is menu
 --2 is game
 --3 is death screen
 --4 is game over screen
 --5 is credits screen
 sfxtoggle=1 -- sfx toggle.
 debug=-1 --debug toggle.
 corrupt=-1 --corrupt toggle.
end

function _update()
 --the code bits.
 if inputdelay>0 then
  inputdelay-=1
 end
 if mode==0 then
  --title code.
  if btn(4) and inputdelay<=0 then
   mode=1
   inputdelay=15
  end
 end
 if mode==1 then
  --menu code.
  if btnp(3) and menuchoice<#courselist then
   menuchoice+=1
  end
  if btnp(2) and menuchoice>1 then
   menuchoice-=1
  end
  if btnp(4) and inputdelay<=0 then
   mode=2
   startcourse(menuchoice)
   inputdelay=15
  end
 end
 if mode==2 then
  --game code.
  
  --check if dead.
  death()
  --do the game stuff.
  player1()
  entities()
  visuals()
 end
 
 if mode==3 then
  --death code.
  if btn(4) and inputdelay<=0 then
   startcourse(menuchoice)
   player.hp=3
   inputdelay=15
   mode=2
  end
 end
 
 if mode==4 then
  --game over code.
  if btn(4) and inputdelay<=0 then
   _init()
   inputdelay=15
  end
 end
 
end

function _draw()
 --the graphics bit.
 cls()
 camera()
 if mode==0 then
  --title draw.
  rectfill(0,0,128,128,12)
  map()
  print2("platformer base",2,2)
  print2("by remagamer",2,10)
  print2("press Ž",2,18)
  print2("v1.2",1,122)
 end
 if mode==1 then
  --menu draw.
  rectfill(0,0,128,128,courselist[menuchoice].bg)
  rectfill(1,9,126,16,0)
  rectfill(2,10,125,15,7)
  rectfill(1,111,126,118,0)
  rectfill(2,112,125,117,7)
  print2("select your course",2,2)
  local n=1
  for i in all(courselist) do
   print2(i.t,11,10+10*n)
   n+=1
   spr(75,103,10*n-2,1,1)
   spr(75,119,10*n-2,1,1,true)
   if i.clr==1 then
    spr(76,111,10*n-2)
   else
    spr(77,111,10*n-2)
   end
  end
  spr(74,1,8+menuchoice*10)
  print2(courselist[menuchoice].d,2,121)
 end
 if mode==2 then
  --game draw.
  
  --set the camera up.
  procam()
  --draw the bg color.
  rectfill(-2048,-2048,2048,2048,courselist[menuchoice].bg)
  --draw the map and sprites.
  map(0,0,0,0,128,64)
  spr(player.s+player.f,player.x,player.y,1,1,player.fx)
  if player.inv>0 then
   spr(73,player.x,player.y)
  end
  dentities()
  map(0,0,0,0,128,64,2)
  dvisuals()
  --draw ui.
  ui()
  --draw death.
  if dead==1 then
   rectfill(player.x-128,player.y-128,player.x-128+dead2,player.y+128,0)
  end
  
 end
 
 if mode==3 then
  --death draw.
  map(25,0)
  rectfill(15,31,113,65,5)
  rectfill(16,32,112,64,1)
  print2("you died",48,34)
  print2("lives remaining: "..player.lv,30,45)
  print2("press Ž to continue",25,56)
 end
 
 if mode==4 then
  --game over draw.
  map(103,0)
  --paint over that sun lol
  rectfill(88,32,104,48,0)
  spr(116,88,32,2,1)
  spr(118,88,40,2,1)
  --back to business
  print2("game over",2,2)
  print2("your score was: "..player.scr,2,10)
  print2("press Ž to restart",2,18)
 end
 
 if mode==5 then
  --credits draw
  rectfill(0,0,128,128,1)
  map(64,16)
  print2("thank you for playing!",2,2)
  print2("your score: "..player.scr,2,10)
  print2("a game by remagamer",2,18)
  print2("made in 2018",2,26)
 end
 
 --debug stuff.
 if debug==1 then
  if mode==2 then
  debugui()
  debugmove()
  end
 end
 --corrupt stuff.
 if corrupt==1 then
  for i=1,5 do
   poke(rnd(0x8000),rnd(0x100))
  end
 end
end
-->8
--functions

function player1()
 --this controls everything relating
 --to the player.
 --tick the player's animation.
 if player.f>=3 then
 player.f=0
 end
 player.f+=.4
 --check for level clear.
 if fget(mget((player.x+4)/8,(player.y+4)/8),3)==true then
  mode=1
  courselist[menuchoice].clr=1
  inputdelay=15
 end
 --check for instakill.
 if fget(mget((player.x+4)/8,(player.y+4)/8),4)==true then
  burst(72,player.x+4,player.y+4)
  player.hp=0
 end
 --check the grounded state.
 if fget(mget((player.x+4)/8,(player.y+8)/8),0)==true then
  player.g=1
  player.vy=0
  player.jg=5
 else
  player.g=0
  player.vy+=.2
  player.jg-=1
 end
 --limit vy speed.
 if player.vy>=7 then
  player.vy=7
 end
 --check if idle.
 if player.g==1 then
  player.s=16
 end
 --take inputs.
 if inputdelay<=0 then
  if btn(0) and fget(mget((player.x)/8,(player.y+4)/8),0)~=true then
   player.x-=1
   player.s=32
   player.fx=true
  end
  if btn(1) and fget(mget((player.x+8)/8,(player.y+4)/8),0)~=true then
   player.x+=1
   player.s=32
   player.fx=false
  end
  if btn(4) and player.g==1 and player.jc==0 or btn(4) and player.jg>0 and player.jc==0 then
   player.vy=-3
   player.jg=0
   player.jc=1
   sfx2(0,-1)
  end
 end
 --check if the player let go of jump.
 if btn(4)==false then
  player.jc=0
 end
 --try to keep player inside the level.
 if player.x<cam.x1-60 then
  player.x=cam.x1-60
 end
 if player.x>cam.x2+60 then
  player.x=cam.x2+60
 end
 if player.y<cam.y1-60 then
  player.y=cam.y1-60
  player.vy=1
 end
 if player.y>cam.y2+61 then
  player.y=cam.y2+61
  player.vy=0
 end
 --check for head collisions.
 if fget(mget((player.x+4)/8,(player.y)/8),0)==true and fget(mget((player.x+4)/8,(player.y)/8),2)==false then
  player.vy=1
 end
 --do gravity.
 player.y+=player.vy
 --check if idle.
 --falling animation.
 if player.g==0 then
  player.s=48
 end
 --try to keep player at the top of the block.
 if fget(mget((player.x+4)/8,(player.y+7)/8),0)==true then
  player.y-=1
 end
 --collisions.
 if player.inv>0 then
  player.inv-=1
 end
 for i in all(entitylist) do
  if cld(player.x)==cld(i.x) and cld(player.y)==cld(i.y) then
   if i.d==true and player.inv<=0 then
    player.hp-=1
    player.inv=30
    splash(72,player.x+4,player.y+4)
    sfx2(4,-1)
   end
  end
 end
end

function debugger()
 --this function turns on and off
 --the debug stuff.
 --that's it :)
 debug=debug*-1
end

function entities()
 --this function handles all entities.
 for i in all(entitylist) do
  --1 is robot.
  if i.t==1 then
   --tick animation.
   if i.f>=3 then
    i.f=0
   end
   i.f+=.4
   --check the grounded state.
   if fget(mget((i.x+4)/8,(i.y+8)/8),0)==true then
    i.g=1
    i.vy=0
   else
    i.g=0
    i.vy+=.2
   end
   --limit vy speed.
   if i.vy>=7 then
    i.vy=7
   end
   --move code.
   if i.g==1 then
    if i.fx==false then
     i.x+=1
    else
     i.x-=1
    end
   end
   if fget(mget((i.x+4)/8,(i.y+4)/8),0)==true then
    if i.fx==false then
     i.fx=true
    else
     i.fx=false
    end
   end
   --do gravity.
   i.y+=i.vy
   --falling animation.
   if i.g==0 then
    i.s=52
   else
    i.s=36
   end
   --stay at top of the block.
   if fget(mget((i.x+4)/8,(i.y+7)/8),0)==true then
    i.y-=1
   end
   --check if stomped.
   if cld(i.x)==cld(player.x) and cld(i.y)==cld(player.y+8) and player.g==0 and player.vy>0 then
    --delete entity
    del(entitylist,i)
    --make player bounce.
    player.vy=-1.5
    if btn(4) then
     player.vy=-3
    end
    --give score.
    player.scr+=50
    --vfx.
    splash(68,i.x+4,i.y+4)
    --sfx.
    sfx2(3,-1)
   end
  end
  --2 is coin.
  if i.t==2 then
   --tick animation.
   if i.f>=3 then
    i.f=0
   end
   i.f+=.2
   --check if touched.
   if cld(i.x)==cld(player.x) and cld(i.y)==cld(player.y) then
    --delete entity
    del(entitylist,i)
    --increase score.
    player.scr+=100
    --visual effect.
    burst(69,i.x+4,i.y+4)
    --sfx.
    sfx2(1,-1)
   end
  end
  --3 is health.
  if i.t==3 then
   --tick animation.
   if i.f>=3 then
    i.f=0
   end
   i.f+=.1
   --check if touched.
   if cld(i.x)==cld(player.x) and cld(i.y)==cld(player.y) then
    --delete entity
    del(entitylist,i)
    --increase hp.
    player.hp+=1
    --increase score.
    player.scr+=500
    --visual effect.
    burst(70,i.x+4,i.y+4)
    --sfx.
    sfx2(2,-1)
   end
  end
  --4 is extra life.
  if i.t==4 then
   --tick animation.
   if i.f>=3 then
    i.f=0
   end
   i.f+=.2
   --check the grounded state.
   if fget(mget((i.x+4)/8,(i.y+8)/8),0)==true then
    i.g=1
    i.vy=0
   else
    i.g=0
    i.vy+=.2
   end
   --limit vy speed.
   if i.vy>=7 then
    i.vy=7
   end
   --move code.
   if i.g==1 then
    if i.fx==false then
     i.x+=1
    else
     i.x-=1
    end
   end
   if fget(mget((i.x+4)/8,(i.y+4)/8),0)==true then
    if i.fx==false then
     i.fx=true
    else
     i.fx=false
    end
   end
   --do gravity.
   i.y+=i.vy
   --stay at top of the block.
   if fget(mget((i.x+4)/8,(i.y+7)/8),0)==true then
    i.y-=1
   end
   --check if touched.
   if cld(i.x)==cld(player.x) and cld(i.y)==cld(player.y) then
    --delete entity
    del(entitylist,i)
    --give life.
    player.lv+=1
    --give score.
    player.scr+=1000
    --vfx.
    burst(71,i.x+4,i.y+4)
    --sfx.
    sfx2(2,-1)
   end
  end
  --5 is roomba.
  if i.t==5 then
   --tick animation.
   if i.f>=3 then
    i.f=0
   end
   i.f+=.4
   --check the grounded state.
   if fget(mget((i.x+4)/8,(i.y+8)/8),0)==true then
    i.g=1
    i.vy=0
   else
    i.g=0
    i.vy+=.2
   end
   --limit vy speed.
   if i.vy>=7 then
    i.vy=7
   end
   --move code.
   if i.g==1 then
    if i.fx==false then
     i.x+=.4
    else
     i.x-=.4
    end
   end
   if fget(mget((i.x+4)/8,(i.y+4)/8),0)==true then
    if i.fx==false then
     i.fx=true
    else
     i.fx=false
    end
   end
   --do gravity.
   i.y+=i.vy
   --stay at top of the block.
   if fget(mget((i.x+4)/8,(i.y+7)/8),0)==true then
    i.y-=1
   end
   --check if it would fall.
   if i.fx==false then
    if fget(mget((i.x+8)/8,(i.y+12)/8),0)==false then
     i.fx=true
    end
   end
   if i.fx==true then
    if fget(mget((i.x)/8,(i.y+12)/8),0)==false then
     i.fx=false
    end
   end
   --check if stomped.
   if cld(i.x)==cld(player.x) and cld(i.y)==cld(player.y+8) and player.g==0 and player.vy>0 then
    --delete entity
    del(entitylist,i)
    --make player bounce.
    player.vy=-1.5
    if btn(4) then
     player.vy=-3
    end
    --give score.
    player.scr+=50
    --vfx.
    splash(68,i.x+4,i.y+4)
    --sfx.
    sfx2(3,-1)
   end
  end
  --6 is cannon.
  if i.t==6 then
   --tick animation.
   if i.f>=3 then
    i.f=0
   end
   i.f+=.1
   --count for fireball.
   i.c+=1
   if i.c>=90 then
    --spawn a fireball.
    i.c=0
    fireball(i.x,i.y,i.fx)
   end
   --check if stomped.
   if cld(i.x)==cld(player.x) and cld(i.y)==cld(player.y+8) and player.g==0 and player.vy>0 then
    --make player bounce.
    player.vy=-1.5
    if btn(4) then
     player.vy=-3
    end
    --sfx.
    sfx2(5,-1)
   end
  end
  --7 is fireball.
  if i.t==7 then
   --tick animation.
   if i.f>=3 then
    i.f=0
   end
   i.f+=.2
   --countdown expiration.
   i.c+=1
   if i.c>=256 then
    del(entitylist,i)
   end
   --move.
   if i.fx==true then
    i.x-=2
   end
   if i.fx==false then
    i.x+=2
   end
   --visual effect.
   add(visuallist,{t=1,s=88,x=i.x+4,y=i.y+4,vx=rnd(2)-1,vy=rnd(2)-1,l=10})
  end
  --8 is drone.
  if i.t==8 then
   --tick animation.
   if i.f>=3 then
    i.f=0
   end
   i.f+=.8
   --move.
   if i.fx==true then
    i.x-=.5
   end
   if i.fx==false then
    i.x+=.5
   end
   --flip if at the end.
   if i.x<=i.lx1 then
    i.fx=false
   end
   if i.x>=i.lx2 then
    i.fx=true
   end
   --check if stomped.
   if cld(i.x)==cld(player.x) and cld(i.y)==cld(player.y+8) and player.g==0 and player.vy>0 then
    --delete entity
    del(entitylist,i)
    --make player bounce.
    player.vy=-1.5
    if btn(4) then
     player.vy=-3
    end
    --give score.
    player.scr+=50
    --vfx.
    splash(68,i.x+4,i.y+4)
    --sfx.
    sfx2(3,-1)
   end
  end
  --9 is boss.
  if i.t==9 then 
   --tick animation.
   if i.f>=3.9 then
    i.f=0
   end
   i.f+=.2
   --mode 0
   --wait 60 frames
   if i.md==0 then
    i.c+=1
    if i.c>=30 then
     i.c=0
     i.md=flr(rnd(3)+1)
    end
   end
   --mode 1
   --move to above the player
   if i.md==1 then
     if player.x>i.x+4 then
      i.x+=1
     end
     if player.x<i.x+4 then
      i.x-=1
     end
     if i.y>=400 then
      i.y-=2
     end
     if player.x==i.x+4 then
      i.md=4
     end
   end
   --mode 2
   --drop roombas.
   if i.md==2 then
    burst(89,i.x+8,i.y)
    roomba(912,384,false)
    roomba(1000,384,true)
    i.c=0
    i.md=0
    sfx2(6,-1)
   end
   --mode 3
   --signal fireballs.
   if i.md==3 then
    if i.c==0 then
     sfx2(9,-1)
    end
    i.c+=1
    if i.c>=30 then
     i.md=5
     i.c=0
    end
    add(visuallist,{t=1,s=88,x=i.x+rnd(16),y=i.y+rnd(16),vx=rnd(2)-1,vy=rnd(2)-1,l=20})
   end
   --mode 4
   --drop to ground level.
   if i.md==4 then
    i.y+=4
    if i.y>=472 then
     i.y=472
     i.md=0
     i.c=0
     for wow=1,3 do
      splash(68,i.x+8,i.y+16)
      sfx2(3,-1)
     end
    end
   end
   --mode 5
   --spawn fireballs.
   if i.md==5 then
    local dr=false
    if i.x>player.x then
     dr=true
    end
    i.c+=1
    fireball(i.x+8,i.y+rnd(16)-4,dr)
    if i.c>=10 then
     i.md=0
     i.c=0
    end
   end
   --mode 6
   --die.
   if i.md==6 then
    i.c+=1
    burst(68,i.x+8,i.y+8)
    i.y-=.33
    i.x=952
    if i.c>=180 then
     mode=5
    end
   end
   --check if touched.
   if cld(i.x)==cld(player.x) and cld(i.y)==cld(player.y) or cld(i.x+8)==cld(player.x) and cld(i.y)==cld(player.y) or cld(i.x)==cld(player.x) and cld(i.y+8)==cld(player.y) or cld(i.x+8)==cld(player.x) and cld(i.y+8)==cld(player.y) then
    --check if jumping.
    if player.g==0 and player.vy>0 then
     --bounce player.
     player.vy=-5
     player.y-=5
     --vfx.
     splash(68,i.x+8,i.y+8)
     --sfx.
     sfx2(3,-1)
     --take damage.
     i.hp-=1
     --spawn drones.
     drone(896,384+flr(rnd(8))*8,896,1016,false)
    else
     --player takes damage.
     if player.inv<=0 then
      player.hp-=1
      player.inv=30
      splash(72,player.x+4,player.y+4)
     end
    end
   end
   if i.hp<=0 then
    --kill boss.
    i.md=6
    player.inv=99
    sfx2(13,-1)
   end
   --end of boss
  end  
  --end of for loop.
 end
end

function dentities()
 --this function draws the entities.
 for i in all(entitylist) do
  --you should probably simplify
  --this if you reuse the code
  --for something else.
  if i.t==9 then
   --the boss needs a bigger sprite.
   spr(i.s+flr(i.f)*2,i.x,i.y,2,2,i.fx)
   --draw his hp.
   local cx=player.x
   local cy=player.y
   if cx<cam.x1 then
    cx=cam.x1
   end
   if cx>cam.x2 then
    cx=cam.x2
   end
   if cy<cam.y1 then
    cy=cam.y1
   end
   if cy>cam.y2 then
    cy=cam.y2
   end
   for i=1,i.hp do
    spr(91,cx-59+i*6-6,cy-50)
   end
  else
   spr(i.s+i.f,i.x,i.y,1,1,i.fx)
  end
 end
end

function hitboxes()
 --this function outlines the
 --effective hitbox of every entity
 --and the player.
 spr(64,flr((4+player.x)/8)*8,flr((4+player.y)/8)*8)
 if player.g==0 and player.vy>0 then
  spr(65,flr((4+player.x)/8)*8,flr((12+player.y)/8)*8)
 end
 for i in all(entitylist) do
  if i.t==9 then
   --boss hitbox is funky.
   spr(64,flr((4+i.x)/8)*8,flr((4+i.y)/8)*8)
   spr(64,flr((4+i.x)/8)*8,flr((12+i.y)/8)*8)
   spr(64,flr((12+i.x)/8)*8,flr((4+i.y)/8)*8)
   spr(64,flr((12+i.x)/8)*8,flr((12+i.y)/8)*8)
  end
  spr(64,flr((4+i.x)/8)*8,flr((4+i.y)/8)*8)
 end
end

function cld(v)
 --this function returns the
 --tile that the xy coords
 --fall under. for collisions.
 return flr((4+v)/8)*8
end

function ui()
 --this function draws the ui
 --overlay for gameplay.
 local cx=player.x
 local cy=player.y
 if cx<cam.x1 then
  cx=cam.x1
 end
 if cx>cam.x2 then
  cx=cam.x2
 end
 if cy<cam.y1 then
  cy=cam.y1
 end
 if cy>cam.y2 then
  cy=cam.y2
 end
 for i=1,player.hp do
  spr(66,cx-59+i*8-8,cy-59)
 end
 spr(67,cx-59,cy+59)
 print2("x"..player.lv,cx-51,cy+61)
 print2("score",cx+47,cy-58)
 print2(player.scr,cx+47,cy-50)
end

function print2(text,x,y)
 --simplification of an outline
 --effect.
 print(text,x+1,y,0)
 print(text,x-1,y,0)
 print(text,x,y+1,0)
 print(text,x,y-1,0)
 print(text,x+1,y+1,0)
 print(text,x-1,y-1,0)
 print(text,x+1,y-1,0)
 print(text,x-1,y+1,0)
 print(text,x,y,7)
end

function burst(id,x,y)
 --this function creates a
 --burst of the specified sprite.
 for i=1,20 do
  add(visuallist,{t=1,s=id,x=x,y=y,vx=rnd(2)-1,vy=rnd(2)-1,l=15})
 end
end

function splash(id,x,y)
 --this function creates a 
 --splash of the specified sprite.
 for i=1,20 do
  add(visuallist,{t=2,s=id,x=x,y=y,vx=rnd(2)-1,vy=-1-rnd(2),l=20})
 end
end

function visuals()
 --this function handles visual fx.
 for i in all(visuallist) do
  --tick lifetime.
  if i.l<=0 then
   del(visuallist,i)
  end
  i.l-=1
  --1 is burst.
  if i.t==1 then
   i.x+=i.vx
   i.y+=i.vy
  end
  --2 is splash.
  if i.t==2 then
   i.x+=i.vx
   i.y+=i.vy
   i.vy+=.4
  end
  --end of for loop.
 end
end

function dvisuals()
 --this function draws visual fx.
 for i in all(visuallist) do
  spr(i.s,i.x,i.y)
 end
end

function startcourse(n)
 --this function starts a course.
 initplayer(courselist[n].x,courselist[n].y,0)
 initentities(menuchoice)
 visuallist={}
 cam.x1=courselist[n].cx1
 cam.x2=courselist[n].cx2
 cam.y1=courselist[n].cy1
 cam.y2=courselist[n].cy2
end

function procam()
 --this function makes the camera
 --follow the player, within the
 --camera bounds.
 local cx=player.x
 local cy=player.y
 if cx<cam.x1 then
  cx=cam.x1
 end
 if cx>cam.x2 then
  cx=cam.x2
 end
 if cy<cam.y1 then
  cy=cam.y1
 end
 if cy>cam.y2 then
  cy=cam.y2
 end
 camera(cx-60,cy-60)
end

function debugui()
 --this function draws debug ui.
 local cx=player.x
 local cy=player.y
 if cx<cam.x1 then
  cx=cam.x1
 end
 if cx>cam.x2 then
  cx=cam.x2
 end
 if cy<cam.y1 then
  cy=cam.y1
 end
 if cy>cam.y2 then
  cy=cam.y2
 end
 hitboxes()
 print2("fps:"..stat(7).." cpu:"..stat(1),cx-1,cy+61,7)
 print2("x:"..flr(player.x).." y:"..flr(player.y),cx-58,cy-49)
 print2("cx:"..flr((player.x+4)/8)*8 .." cy:"..flr((player.y+4)/8)*8,cx-58,cy-41)
end

function death()
 --this function handles the
 --oh no, you're dead! sequence.
 if player.hp<=0 and dead==0 then
  dead2=0
  dead=1
  player.lv-=1
 end
 if dead==1 then
  inputdelay=30
  dead2+=8
  player.vy=0
 end
 if dead2>=246 then
  if player.lv==0 then
   mode=4
  else
   mode=3
   dead=0
   dead2=0
  end
 end
end

function debugmove()
 --this function lets you
 --noclip using 2p controls.
 --also add hp and lives.
 if btn(0,1) then
  player.x-=2
  player.vy=-.2
 end
 if btn(1,1) then
  player.x+=2
  player.vy=-.2
 end
 if btn(2,1) then
  player.y-=2
  player.vy=-.2
 end
 if btn(3,1) then
  player.y+=2
  player.vy=-.2
 end
 if btnp(4,1) then
  player.hp+=1
 end
 if btnp(5,1) then
  player.lv+=1
 end
end

function corruptor()
 --this function turns on and off
 --corrupt mode.
 corrupt=corrupt*-1
end

function selector()
 --this just sets the mode to stage
 --select.
 mode=1
end

function sfx2(n,c)
 --this function plays a sound effect
 --but first it checks if sfx is muted.
 if sfxtoggle==1 then
  sfx(n,c)
 end
end

function sfxer()
 --this function turns on and off
 --sfx!
 sfxtoggle=sfxtoggle*-1
end
-->8
--long setup functions

function initcourses()
 --this function sets up the courselist.
 courselist={}
 add(courselist,{t="fields 1",d="seems familiar...",x=32,y=96,cx1=60,cx2=444,cy1=60,cy2=60,bg=12,clr=0})
 add(courselist,{t="fields 2",d="two towers",x=562,y=96,cx1=572,cx2=956,cy1=60,cy2=60,bg=12,clr=0})
 add(courselist,{t="ocean 1",d="caution: wet",x=8,y=208,cx1=60,cx2=444,cy1=188,cy2=188,bg=1,clr=0})
 add(courselist,{t="ocean 2",d="don't get seasick",x=568,y=200,cx1=572,cx2=956,cy1=188,cy2=188,bg=1,clr=0})
 add(courselist,{t="cave 1",d="to the core",x=16,y=288,cx1=60,cx2=188,cy1=316,cy2=444,bg=0,clr=0})
 add(courselist,{t="cave 2",d="bejeweled",x=368,y=480,cx1=316,cx2=428,cy1=316,cy2=444,bg=0,clr=0})
 add(courselist,{t="castle 1",d="gauntlet",x=544,y=360,cx1=572,cx2=956,cy1=316,cy2=316,bg=2,clr=0})
 add(courselist,{t="castle 2",d="final rush",x=536,y=480,cx1=572,cx2=828,cy1=444,cy2=444,bg=2,clr=0})
 add(courselist,{t="boss",d="big bad",x=920,y=480,cx1=956,cx2=956,cy1=444,cy2=444,bg=2,clr=0})
end

function initentities(n)
 --this function adds
 --entities to the level.
 entitylist={}
 if n==1 then
  life(8,88,true)
  robot(248,104,true)
  robot(272,96,false)
  robot(304,104,true)
  coin(136,80)
  coin(144,80)
  coin(152,80)
  coin(160,80)
  coin(168,80)
  roomba(200,88,false)
  roomba(136,104,true)
  roomba(192,80,true)
  roomba(176,80,true)
  health(152,32)
  robot(424,104,false)
  coin(448,72)
  coin(456,72)
  coin(448,64)
  coin(456,64)
  coin(368,72)
  coin(376,72)
  coin(368,64)
  coin(376,64)
 end
 if n==2 then
  coin(624,32)
  coin(632,32)
  coin(640,32)
  coin(648,32)
  coin(656,32)
  coin(664,32)
  coin(672,32)
  health(520,32)
  roomba(664,80,true)
  roomba(632,56,false)
  life(760,48,true)
  coin(864,104)
  coin(872,104)
  roomba(896,104,false)
  robot(720,32,false)
  robot(768,32,true)
  coin(960,96)
  coin(968,96)
  coin(960,88)
  coin(968,88)
 end
 if n==3 then
  cannon(352,192,true)
  cannon(408,232,true)
  roomba(328,160,true)
  roomba(384,160,false)
  life(368,192,true)
  drone(56,192,56,104,false)
  drone(144,200,128,144,true)
  drone(256,144,208,256,false)
  coin(352,176)
  coin(352,184)
  coin(344,176)
  coin(344,184)
  coin(336,176)
  coin(336,184)
  coin(64,208)
  coin(72,208)
  coin(80,208)
  coin(88,208)
  coin(96,208)
  coin(168,224)
  coin(168,216)
  coin(176,224)
  coin(176,216)
  coin(184,224)
  coin(184,216)
  health(328,224)
  coin(440,216)
  coin(448,216)
  coin(456,216)
  coin(464,216)
  coin(472,216)
 end
 if n==4 then
  robot(664,240,true)
  robot(696,240,false)
  drone(856,224,760,856,false)
  drone(760,224,760,856,true)
  health(992,240)
  life(736,200,true)
  coin(784,232)
  coin(816,232)
  robot(832,200,true)
  robot(872,200,false)
  coin(912,200)
  coin(912,192)
  coin(920,200)
  coin(920,192)
  coin(928,200)
  coin(928,192)        
  drone(904,184,904,936,true)
 end
 if n==5 then
  cannon(24,424,false)
  cannon(16,416,false)
  cannon(8,408,false)
  roomba(96,296,true)
  drone(104,280,64,104,true)
  coin(64,320)
  coin(72,320)
  coin(80,320)
  coin(88,320)
  coin(96,320)
  coin(104,320)
  coin(216,288)
  coin(224,288)
  coin(232,288)
  life(120,392,true)
  health(48,376)
  coin(40,376)
  coin(32,376)
  coin(24,376)
  coin(56,376)
  coin(64,376)
  coin(72,376)
  coin(104,488)
  coin(112,488)
  coin(144,480)
  coin(152,480)
  coin(176,480)
  coin(184,480)
  coin(208,480)
  coin(216,480)
  coin(224,480)
  coin(224,480)
 end
 if n==6 then
  coin(368,424)
  coin(376,424)
  coin(368,416)
  coin(376,416)
  coin(280,408)
  coin(288,408)
  cannon(272,288,false)
  cannon(280,296,false)
  cannon(288,304,false)
  cannon(432,304,true)
  cannon(440,296,true)
  cannon(448,288,true)
  roomba(312,440,true)
  roomba(280,416,true)
  robot(272,448,false)
  roomba(312,400,true)
  roomba(336,392,false)
  coin(432,456)
  coin(440,456)
  coin(464,448)
  coin(472,448)
  health(272,496)
  coin(312,432)
  coin(320,432)
  life(416,312,false)
  robot(328,336,false)
  robot(392,336,true)
 end
 if n==7 then
  cannon(872,312,true)
  cannon(728,360,false)
  cannon(720,352,false)
  cannon(872,288,true)
  cannon(880,280,true)
  life(520,312,true)
  health(976,368)
  cannon(696,360,true)
  cannon(704,352,true)
  coin(664,312)
  coin(672,312)
  coin(664,304)
  coin(672,304)
  coin(664,336)
  coin(672,336)
  coin(664,328)
  coin(672,328)
  roomba(592,288,false)
  roomba(688,360,true)
  roomba(672,360,true)
  drone(832,352,832,848,false)
  roomba(952,344,false)
  coin(776,320)
  coin(784,320)
  coin(824,320)
  coin(832,320)
  coin(776,360)
  coin(784,360)
  coin(816,360)
  coin(824,360)
  coin(856,360)
  coin(864,360)
 end
 if n==8 then
  cannon(616,440,false)
  cannon(616,424,false)
  cannon(616,408,false)
  cannon(880,432,true)
  cannon(880,416,true)
  cannon(880,400,true)
  life(600,400,true)
  robot(592,400,true)
  robot(584,400,true)
  robot(576,400,true)
  robot(568,400,true)
  robot(560,400,true)
  robot(552,400,true)
  robot(544,400,true)
  robot(536,400,true)
  robot(592,424,false)
  robot(584,424,false)
  robot(576,424,false)
  robot(568,424,false)
  robot(560,424,false)
  robot(552,424,false)
  robot(544,424,false)
  robot(536,424,false)
  robot(592,448,true)
  robot(584,448,true)
  robot(576,448,true)
  robot(568,448,true)
  robot(560,448,true)
  robot(552,448,true)
  robot(544,448,true)
  robot(536,448,true)
  health(872,464)
 end
 if n==9 then
  boss(984,472)
 end
 --end of ifs.
end

function initplayer(x,y,mode)
 --this function sets up the player.
 if mode==0 then
  --keep score.
  player.x=x
  player.y=y
  player.vy=0
  player.g=1
  player.s=16
  player.f=0
  player.fx=false
  player.inv=0
  player.jg=5
  player.jc=0
 end
 if mode==1 then
  --reset everything.
  player={x=x,y=y,vy=0,g=1,s=16,f=0,fx=false,hp=3,scr=0,lv=3,inv=0,jg=5,jc=0}
 end
 --x=x position.
 --y=y position.
 --vy=y velocity.
 --g=grounded or not.
 --s=sprite to use.
 --f=frame of animation.
 --fx=flip x or not.
 --hp=hit points of player.
 --scr=score of player.
 --lv=lives of player.
 --inv=invulnerability.
 --jg=jump grace period.
 --jc=jump cancel.
end
-->8
--storage of add functions
--for every entity in the game

function robot(x,y,dr)
 --adds a robot.
 add(entitylist,{t=1,x=x,y=y,vy=0,g=0,s=36,f=0,fx=dr,d=true})
end

function coin(x,y)
 --adds a coin.
 add(entitylist,{t=2,x=x,y=y,f=0,s=28})
end

function health(x,y)
 --adds a health.
 add(entitylist,{t=3,x=x,y=y,f=0,s=44})
end

function life(x,y,dr)
 --adds a life.
 add(entitylist,{t=4,x=x,y=y,vy=0,g=0,s=60,f=0,fx=dr})
end

function roomba(x,y,dr)
 --adds a roomba.
 add(entitylist,{t=5,x=x,y=y,vy=0,g=0,s=20,f=0,fx=dr,d=true})
end

function cannon(x,y,dr)
 --adds a cannon.
 add(entitylist,{t=6,x=x,y=y,s=92,f=0,fx=dr,c=0})
end

function fireball(x,y,dr)
 add(entitylist,{t=7,x=x,y=y,s=108,f=0,fx=dr,c=0,d=true})
end

function drone(x,y,lx1,lx2,dr)
 add(entitylist,{t=8,x=x,y=y,s=124,f=0,fx=dr,lx1=lx1,lx2=lx2,d=true})
end

function boss(x,y)
 add(entitylist,{t=9,x=x,y=y,s=80,f=0,hp=15,c=0,md=0})
end

--here's what all of them do
 --t=what it is. its id.
 --x=x position.
 --y=y position.
 --vy=y velocity.
 --g=grounded or not.
 --s=sprite to use.
 --f=frame of animation.
 --fx=flip x or not.
 --hp=hit points of player.
 --scr=score of player.
 --lv=lives of player.
 --inv=invulnerability.
 --c=timer count
 --d=damages player or not.
 --lx1= the farthest left patrol point.
 --lx2= the farthest right patrol point.
-->8
--boss variables

--t=id.
--x=x position.
--y=y position.
--s=sprite to use.
--f=frame of animation.
--hp=hit points of boss.
--c=timer count.
--md=mode it's currently in.
--d=damages player or not.
__gfx__
00000000655d655d55555555600000057666555d000000007777777600000000aa99aa99aa990000bbbbbbbb7766665500065000000000000000000077dd77dd
00000000555d555d7765776566000055776565dd00000000779999650a900000a994a994a99400003b3b3b3b7d6d6d5d00065000000990000000000077dd77dd
00700700dddddddd76657665606005057666555d00000000797996450940000099449944994400003b3b3b3bd7d6d6d5000650000098890000bb3300dd77dd77
00077000d655d6555555555560066005776565dd0000000079966445000000009444944494440000934393437766665500065000009889000bb3b330dd77dd77
00077000d555d55557765776600650057666555d000000007996644500000000aa99aa990000aa99aa99aa99dddddddd0006500009aaaa90bb8b434377dd77dd
00700700dddddddd5766576660500505776565dd000000007964454500000a90a994a9940000a994a994a994dddddddd0006500009a88a90bbb3b33377dd77dd
0000000055d655d655555555650000557666555d007a95007644445500000940994499440000994499449944dddddddd0006500009999990b8bb3343dd77dd77
00000000dddddddd6657665760000005776565dd076666506555555500000000944494440000944494449444dddddddd00665500000650000bb38330dd77dd77
00000000000000000000000000000000008600000086000000000000000000000000000000000000000000006655665500000000000000000000000000000000
0003333000033330000333300003333000006000000060000086000000860000000000000000000000000000776677660007a000000070000007700000070000
0003333300033333000333330003333300666660006666600000600000006000006000600000000000000000d776d776007aa9000007aa00000aa000007aa000
00033ff000033ff000033ff000033ff006668890066688900066666000666660006000600077007700000000d776d77600aaa900000aa900000aa00000aa9000
00bbbb0000bbbb0000bbbb0000bbbb00066688900666889006668890066688900776077677cc77cca989a989dd6ddd6d00a99900000a99000009900000a99000
00bbbb0000bbbb0000bbbb0000bbbb000666666006666660066688900666889007760776cccccccc98889888dd6ddd6d00a99400000994000009900000994000
003f33f0003f33f0003f33f0003f33f00d5d5d5005d5d5d0066666600666666077667766cc11cc1188988898dddddddd00094000000040000004400000040000
0030030000300300003003000030030005d5d5d00d5d5d500d5d5d5005d5d5d0665566551111111198899889dddddddd00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006000000555555555655d655d7777676600000000000000000077760000777600
00033330000333300003333000033330000066000000660000006600000066006600005557655765dddddddd7776767600777600007776000777666007776660
00033333000333330003333300033333000666600006666000066660000666606060050556655665dd6ddd6d77676766077766600777666000e8f40000ef8400
00033ff000033ff000033ff000033ff0000668900006689000066980000669806077607755555555dd6ddd6d7676766600e8f40000ef840000e8840000e88400
00bbbb0000bbbb000bbbbb0000bbbb000056660000566600055666000056660077cc77cc5d655d65d776d7766767666600e8840000e8840000ef840000e8f400
00bbfb0000bbbb00f0bbbbbf00bbbb0000655600005666005066665500566600ccccccccddddddddd776d7760676666000ef840000e8f4000666555006665550
03333300003f33f000333300003f33f006666600006566500066660000656650cc11cc11d655d655776677660000000006665550066655500065550000655500
000000300030030000030000003003000000006000600600000600000060060011111111dddddddd665566550000000000655500006555000000000000000000
000333300003333000033330000333300006600000066000000660000006600000000000bbbb3b3300000000bbbb000000000000000000000000000000000000
0f0333330f0333330f0333330f0333330066660000666600006666000066660000000000bbb3b333000000003b3b0000007bb300007bb3000000000000000000
0b033ff00b033ff00b033ff00b033ff0009898000089890000888900009888000000000003333330000000003b3b0000077b3b30077b3b30007bb300007bb300
00bbbb0000bbbb0000bbbb0000bbbb000566665005666650056666500566665000000000009445000bbbbbb093430000bbb377b3bbb377b3077b3b30077b3b30
00bbbbbf00bbbbbf00bbbbbf00bbbbbf506666055066660550666605506666050000000000944500b77bbbb30000aa99773b7733773b7733bbb377b3bbb377b3
00333300003333000033330000333300506666055066660550666605506666050000000000944500b7bbbbb30000a9940733333007333330773b7733773b7733
00300030003000300030003000300030006006000060060000600600006006000777776000944500bbbbbb3300009944007ff700007ff7000733333007333330
00000000000000000000000000000000000000000000000000000000000000007777767609444450bbbbb3b30000944400ffff0000ffff0000ffff0000ffff00
88888888aaaaaaaa0dddddd0000000000760000007000000e808800073300000ddd000000777777000000000000000000000000000000000077665505d5ddddd
80000008a000000addeddedd0dddddd0765000007a900000e8888000bb700000d8d0000077000077dddd000000000ddddddddddddddddddd0979454055dddddd
80000008a000000ade8ee84ddd3333dd65000000090000000e8800000f000000d8d0000070770007d77ddd00000ddd777dbbbbd77d8888d7097945405d5ddddd
80000008a000000ade88884dd333333d000000000000000000e0000000000000ddd0000070700007d7777ddddddd7777dbbbbbbdd888888d9799445455dddddd
80000008a000000ade88884dd3ffff3d00000000000000000000000000000000d8d0000070000007d777777dd7777777dbbbbbbdd888888d979944545d5ddddd
80000008a000000add4884ddd3ffff3d00000000000000000000000000000000ddd0000070000007d7777ddddddd7777dbbbbbbdd888888d0979454055dddddd
80000008a000000a0dd44dd0ddbbbbdd000000000000000000000000000000000000000077000077d77ddd00000ddd777dbbbbd77d8888d7097945405d5ddddd
88888888aaaaaaaa00dddd000dddddd0000000000000000000000000000000000000000007777770dddd000000000ddddddddddddddddddd0776655055dddddd
00000000000000000000000000000000000000000000000000000000000000000a00000000bb3300000000000dddddd000000000000000000000000000000000
0000666666660000000066666666000000006666666600000000666666660000a98000000b00003007666500dd7dd7dd66666605666666056666665066666650
000068666686000000006866668600000000686666860000000068666686000008000000000b300076655650d767765d66666656666666566666656066666560
00006988889600000000698888960000000069888896000000006988889600000000000000b0030077666550d766665d66896656668966566689656066896560
0000699889960000006669988996660000006998899600000066699889966600000000000000000076565650d766665d66896656668966566689656066896560
0666666666666660066666666666666006666666666666600666666666666660000000000000000077666550dd5665dd66666656666666566666656066666560
066665d5d5d66660066665d5d5d66660066665d5d5d66660066665d5d5d666600000000000000000765566500dd55dd055655605556556055565565055655650
06666d5d5d56666006666dddddd6666006666d5d5d56666006666dddddd6666000000000000000007766655000dddd0055055000550550005505500055055000
066666666666666006666d5d5d566660066666666666666006666d5d5d566660000f000000000000000000000000000000000000000000000000000000000000
066666666666666006666666666666600666666666666660066666666666666000fe200000007b00000000000000000000088800000888000008880000088800
066006666660066006600666666006600660066666600660066006666660066000fe20000007b300777777767777777608899980088999800889998008899980
066006666660066006600666666006600660066666600660066006666660066000fe20fe007bb30077b37b357b37b3658999aa988999aa988999aa988999aa98
066006666660066066600666666006660660066666600660666006666660066600fe2fe207bbbb307b37b35577b36b358999aa98899aaa9889aaaa988a99aa98
66600660066006666660066006600666666006600660066666600660066006660fee2e2007bb7b307b36b35577b35b3508899980088999800889998008899980
66606660066606666660666006660666666066600666066666606660066606660fee2e200bb7b33076b35b357b35b35500088800000888000008880000088800
66606660066606660000666006660000666066600666066600006660066600000fee22000b7bbb30655555556555555500000000000000000000000000000000
000000000000000007aaaaaaaaaaaa90000000000000000007777765ddddddd00000000000000000555555556000000505577770077777700775555005555550
000000777700000007aaaaaaaaaaaa90000000dddd0000000777777655ddddd00000000000000000500500056600005555566777777665557776655555566777
000077aaaaaa000000aaaaaaaaaaa90000005ddddddd0000007777776655dd000000000000079000500500056060050505555770055555500777755007777770
0007aaaaaaaaa00000aaaaaaaaaaa90000065dddddddd00000777777776655000000e800007aa900500500056006600500660000006600000066000000660000
007aaaaaaaaaaa00000aaaaaaaaa9000007765dddddddd000007777777776000000ee88007a79a9055555555a989a98906886660068866600688666006886660
007aaaaaaaaaaa000000aaaaaa990000007765dddddddd00000077777777000000088440077aa990500050059888988806896660068966600689666006896660
07aaaaaaaaaaaa9000000099990000000777765dddddddd0000000777700000000e8848807a79a90500050058898889806666000066660000666600006666000
07aaaaaaaaaaaa9000000000000000000777765dddddddd000000000000000000ee88844077aa990555555559889988900000000000000000000000000000000
808080808080808080808080808080808080808080808080808080808080808080808080808080808080f0f0f0f0f0f0f0808080808080808080808080808080
00000000000000000000000020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020
808080808080808080808080808080808080808080808080808080808080808080808080808080808080f0f0f0f0f0f0f0808080808080808080808080808080
00000000000000000000000020202020202020202020202020201010101010101010101010101010102020202020202020202020202020202020202020202020
70707070707070707070707070707070707070707070707070707070909080808080808080808080808070707070707070808080808080808080808080808080
000000000000000000000000101010101010101010101010101010a7a71010a7a710a7a71010a7a7101010101020202020202020202020202020202020202020
70707070707070707070707070707070707070707070707070707090709080808080808080808070707070707070707070707070808080808080808080808080
0000000000000000000000001010101010a7a71010a7a710101010a7a71010a7a710a7a71010a7a71010101010101020202010101010b1b1b1101010b1b1f0f0
70707070707070707070707070707070707070707070707070707090907080808080f4f470707070707070707070707070707070707070f4f480808080808080
0000000000000000202010101010101010a7a71010a7a710101010101010101010101010101010101010101010102020201010a7a7a7101010a7a7a71010f0f0
7070707070707070707070707070707070707070707070707070708080808080808040f4f47070707070707070407070707070707070f4f44080808080808080
0000000000000000202020202020201010a7a71010a7a710102020202020202020202020202020202020101010202020101010101010a7a7a7101010a7a7f0f0
808080808090909090808080809090909080808080808080707070808080808080804040f47070707070707040404070707070707070f4404080808080808080
000000000000000000202020202020201010101010101010202020202020202020202020202020202020202010202020101010a2a2a2101010a2a2a21010f0f0
80808080808090909090909090909090808080808080808070707080808080808080404040a1a1808080b0b0404040b0b0808080707040404080808080808080
a0000000a00000000000002020202020201010101010102020201010101010101010101010101010101010101010202010929220202020202020202020202020
8080808080808080909090909090808080808080808080807070708080808080808080808080808080907070f4f4f47070908080808080808080808080808080
80a0a0a080a0000000000000202020202020109292102020202010101020202020101020202020101020202020202010a7a7a710202020202020202020202020
8080808080808080808080808080808080808080808080807070708080808080807070708080808090707070f4f4f47070709080808080808080808080808080
808080808080a00000000000202010101010101010101010202010101020202020202020202020202020202010101010a7a7a710101010101010101010102020
8080808080808080808080808080808080808080808080807070708080808080707070707080808080907070f4f4f47070908080808080808080808080808080
8080808080808080000000002020101010a7a71010a7a710202010101010101010101010101010101010101010a7a71092929210a7a7101010a7a710a7a72020
8080808080808080808080808080808080808080808080807070708080808080a1a180707080808080808080b0b0b08080808080808080808080807070808080
8080808080808070000000001010101010a7a79292a7a710202020921010a7a7a71010a7a7a71010a7a7a71010a7a71010101010a7a7101010a7a710a7a72020
8080808080808080808080808080808080808080808080907070708080808080808080707080808080807070f4f4f47070808080808080808080707070708080
9070907070707070000000001010101010a7a71010a7a710102010101010a7a7a71010a7a7a71010a7a7a7101092921010101010929210202092922010102020
8080808080808080808080808080808080808080808090907070708080808080808080a1a180808070707070f4f4f47070707070707070808080a1a180708080
909070907070707000000000101010101010101010101010202020101010a7a7a71010a7a7a71010a7a7a71010101010101010101010102020a7a710a7a72020
8080909090909090909080808080808080808080809090907070708080808080808080808080807070707070f4f4f47070707070707070707080808080a18080
9090907090707070a0a0a0a0202020202020202020202020202020202020a2a2a22020a2a2a22020a2a2a22020a2a2a2a2a2a2a2a2a2a22020a7a710a7a72020
80909070707070707070908080808080808080809090908070707080808080808080808080707070707070704040407070867070707070707070808080808080
808080808080808080808080202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020a2a22020
8090909090909090909080808080808090909090909080707070708080808080808080807070707070707087404040a1a1808070709796707070708080808080
2020202020202020202020202020f0f0f0f020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000
807090808080808080808080808070707080808080807070707070808080808080808070707070707096868080408080808080a1a18080877070707080808080
2020202020202020202020202020f0f0f0f020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000
80f47070707070707070708080808080808080808070705070705070808080808080707070707097708080808080808080808080808080807070707070808080
20201010101010101010101020201010101010101010101010101010101010101010101010101010101010101010102000000000000000000000000000000000
80f4f470707070707070707070707070707070707070704040404070808080808080707070707080808080707070707070708080808070707070709670708080
20201020202020202020202020101010101010101010101010101010101010101010101010101010101010101010202000000000000000000000000000000000
8040f4f4707070707070707070707070707070707070707030307070808080808080709687707070707070707070707070707070707070707070808070708080
20201020202020202020202020201092921010101010101010101010101010101010101010101010101010101010102000000000000000000000000000000000
804040f4707070707070707070707070707070707070707030307070808080808080708080907070707070707070707070707070707086707070909070708080
20201010101010101010101020101010101010101010101010101010101010101010101010101010101010101010202000000000000000000000000000000000
804040407070706060609090906060609090906060607070303070708080808080807070709090707070707070a67070b6707070707080807070909070708080
20202020202020202020201020201092921010101010101010101010101010101010101010101010101010101010102000000000000000000000000000000000
808080807070808080809090908080809090908080808080808080808080808080807070707090908670707070c07070c0707070707090907070909070708080
20202020202020202020201020101010101010101010101010101010101010101010101010101010101010101010202000000000071700000000475700000000
80808070707080808080808080808080808080808080808080808080808080808090967070707080807086808040b0b040707070707090907070909070708080
20201010101010101010101020202020202020202020202020202020202020202020202020202020202092929292202000000000273700000000677700000000
80807070707080808080807070709070707090707070709070707090707080808090809670707070707080808040f4f4408097707070909070708080a1a18080
2020102020202020202020202020202020b1b1b1b1b1202020b1b1b1b1b1202020b1b1b1b1b1b1b1b1b110101010202000000000000000000000000000000000
80707070808080807070707070907070707070907070907070709070907070808090808086709770868080808040f4f440808080a1a18080a1a1808080808080
2020102020202020202020202020b1b1b11010101010b1b1b11010101010b1b1b110101010101010101010101010202000000000000000000000000000000000
80707070708080707070707070709070707090707070709070707090707070808090908080808080808070707040b0b040707080808080808080808070808080
202010b1b1b1b1b1b1b1b1b1b1b11010101010101010101010101010101010101010101010101010101010109292202000000000000000000000000000000000
80707070d09070d07070707070907070707070907070907070709070907070808080908080807070707070707070707070707070707080808080807070708080
20201010101010101010101010101010101010101010101010101010101010101010101010101010101010101010202000005000000000000000000000500000
80807070c07090c0707070707070907070708080a1a18080a1a1808080707080808090707070707070867070708770709770707087707070808080a1a1a18080
202010101010101010101010101010101010a2a2a21010101010a2a2a210101010a2a21010a2a210a210a210a210202000004040404040404040404040400000
80808080808080808080a1a1a18080a1a1a18080808080808080808080f0f08080809090707070707080a1a1a180808080a1a1a1807070707070808080808080
20202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202000003030303030303030303030300000
8080808080808080808080808080808080808080808080808080808080f0f08080808080a1a1a1a180808080808080808080808080a1a1a1a1a1a1a180808080
202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020a1a1b7b7a1a1a1a1a1a1a1a1b7b7a1a1
__gff__
0000010201020100010201050202000800000000000000001010101000000000000000000000000012051007000000000000000000000000020000020000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000002020000000000000000000000000000001200000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020f0f
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f00000000003838000038380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f
00000000000000000000707100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f01010200002b2b00002b2b0000020101010101010102000000020101010101010102000000000000000000000000000000007071000000000000000000000f0f
00000000000000000000727300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f02020200000000000000000000020229292929290202000000020229020202020202000000000000000000000000000000007273000000000000000000000f0f
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f02020000000000000000000000000201010101010200000000000201010101010200000000000000000000000000000000000000000000000000000000000f0f
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f02020000000000000000000000000201010101010200000000000229292929290200000000000000000000000000000000000000000000000000000000000f0f
00000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f02020000000000000000000000000229290101010200000000000201010101010200000000000000000000000000000000000000000000000000000000000f0f
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f02020000000000000000000000000201010101010200000000000201010129010200000000000000000000000000000000000000000000000000000000000f0f
0e000e0000000000000000000000000000000000000000000000000000000000050500000000000505000000000000000000000000000d000000000d00000f0f0202000000000000000000000000020101010101020000000000010101010101020000003a000000000000000000000000000000000000000000000000000f0f
0a000a0000000000000000000000060000060606060600000005050000000000040400000000000404000000000a00000a00000000000c0a00000a0c00000f0f0202000000000000000000000000020101012929020000000000010101010101020e0e0039000000000000000000000000000000000000000000000000000f0f
080a0800003a0000003a0000000000000000000000000000000404000000000004040e0e00000004040000000a080000080a000000000a080000080a00000f0f0202003a003a000000003a003a00010101010101020000000000010129010101020a0a0a0a0a00000d0000000000000000000000000000000000000000000f0f
0808080e0039000e0039000e0000000000000000000000000e040400000e000e04040a0a0a0a0a04040e00000808000008080e00000008080000080800000f0f020200390039000000003900390001010101010102005a005a00022a2a2a2a2a0208080808080a000c0000000000000000000000005a000000005a005a000f0f
0808080a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a04040a0a0a0a0a0404080808080804040a0a0a08080a0a08080a0a0a0a0808181808080a0a0a0a02020a0a0a0a0a0a0a0a0a0a0a0a020202020202020a0a0a0a0a020202020202020808080808080a0a0a00000a0a00000a0a00000a0a0a0a0a0a0a0a0a0a0a0a
0808080808080808080808080808080808080808080808080804040808080808040408080808080404080808080808080808080808080808020208080808080802020808080808080808080808080202020202020208080808080202020202020208080808080808080819190808191908081919080808080808080808080808
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808080808080808080808
00000000000000000000000000000000000000000000000000000000000000000000000404040404040404040404040404000000000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080808080808080808
00000000000000000000000000000000000000000000000000000000000000000000004f4f4f044f4f4f4f4f4f4f4f4f4f000000000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080808080808080808
00000000000000000000000000000000000000000000000000000000000000000000004f4f4f044f4f4f4f4f4f4f4f4f4f000000000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000747500000000070908080808080808
00000000000000000000000000000000000000000000000000000005000000050000004f4f4f044f4f4f4f4f4f4f4f4f4f000000000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000767700000000090709070908080808
00000000000000000000000074750000000000000000000000000404040404040400004f4f4f044f4f0b040404040b0404000005000000000000000000000f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070907090709070808
0000000000000000000000007677000000000000006b00000000000300000003000000044f4f040b4f4f4f4f4f044f4f04000404040000000000000000000f0f00000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000709070907090f0f
0000000000000000000000000000000000000000000c05000000000300000003000000044f4f4f4f4f4f4f4f4f044f4f04000003000000000000000000000f0f00000000000000030000000000000000000000000000000000000000000018000000000000000000000000000000000000000005000000000907090709070f0f
0000000000000000000000000000000000000000000404040000000300000003000000044f4f4f4f4f4f4f4f4f044f4f04004e03000000000000000000000f0f0000000000000003000000000000000000000000000000000000000500000400001800000000000d000000000000000000000003000000000808080807090f0f
0000000000000000000000000000000000000000004f4f4f000000036a0000030000000404040404040404040404040b04000404040000000000000000000f0f0000000000000003000000000000000000000000000000000000000403030400180418000000000c000000000000050000050003000500000808080808070f0f
0000000000000005000000000005000000000000004f4f4f000000030c0000030000000303030303030303030303030304000003000000000000000000000f0f0000000000050003000500000000000000000000000000000000004f040404040404040418181804030303030303040000040b0b0b0400000808080808080808
0000000000000004040404040404000000050000004f4f4f00000404040000030000000303030303030303030303030304000003060000000000000000000f0f00000000000b040b040b00000000000000000000000500000000004f4f04040404040404040404040b0b04040404040000000003000000000008080808080808
0a0a0a0a0a000000030000000300000004040400004f4f4f0000000300000003000d000003030000000000000000000404000404040000064e4e064e00000f0f00054e4e0000030003000000000500000000000000030000000000004f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f04040000000000034e0000000009090808080808
08080808080a0a00030000000300000000030000000404040000000300000003000c00000303030303030303030303030300000300054e06064e06064e050f0f00040406064f034f034f4f4f040400000005000000030000000500004f4f4f0606064f0606064f06060606060400054e4e004e034e4e4e000500090908080808
080808080808080a0a00000003000000000300000004040400000003000000030004000003040303030403030304030303000004000404040404040404040f0f000404040404040404040404040400000004044f4f034f4f040400000b0406060606060606060606060606040000040406060606060606040400080909080808
0808080808080808080a191928191919192819191904040419191928191919281928191928281919192819191928192828191928191928191919191928190f0f19190404040404040404040404191919191904040404040404191919190404040404040404040404040404191919190404040404040404041919080808080808
__sfx__
000200000d01012020190301e0401e04022000230003b0001d0003f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000033720367303a7403d7503d7403d7301d700377003a7003e7003f7003e7003d7003d700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000800001e01023020270302c0402f050310603407034070340703406034050340403403034020340100600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000018660126600c6500a65007640056400363001630016200162001610016100010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000800003003033030340403504035050350503500035000000003500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700003f7703f7503f7303f7103f7003f7003f7003f7003f7000160027700016000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0005000036370383703a37036370383703a3703f3003e3003f3003f30034300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0020000a0371005710087100b7100e71011710117100e7100c7100a71000700007000070000700007000370004700047002170020700007000070000700007000070000700007000070000700007000070000700
00200020257402573023720237102370024700287302c7402f7503676036760367603676033750307502c7502f7502c7502c7502c7502c7502f75036760367603676036760347502f7502c7502a7502a7502a740
001000000161002620046300564003650026600167002670016700266001650026400163002620016100160001600006000060000600006000060000600006000060000600006000060000600006000060000600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000164002650046600567005670046600265001640016000260001600026000160002600016000160001600006000060000600006000060000600006000060000600006000060000600006000060000600
000800000161002620046300564005640046300262001610016000260001600026000160002600016000160001600006000060000600006000060000600006000060000600006000060000600006000060000600
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
01 07 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
