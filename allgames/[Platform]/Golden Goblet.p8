pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--golden goblet
--by niall chandler

--toy box jam 2020 game

--start date: 19/12/2020

--ABCDEFGHIJKLMNOPQRSTUVWXYZ

--variables

--64x64
--poke(0x5f2c,3)

poke(0x5f5c,255)

music(0)

  player={
    sp=1,
    x=8,
    y=104,
    w=8,
    h=8,
    flp=false,
    dx=0,
    dy=0,
    max_dx=2,
    max_dy=3,
    acc=0.5,
    boost=4.6,
    anim=0,
    running=false,
    jumping=false,
    falling=false,
    sliding=false,
    landed=false,
    deaths=0,
    jumps=0,
  }

  gravity=0.3
  friction=0.85
  airtime=0

--fire top
  firea={
    x=0,
    y=0,
    sp=28,
    anim=0,
 }
--fire bottom
  fireb={
    x=0,
    y=8,
    sp=44,
    anim=0,
 }

  --level
  level=1
  if level>5 then
    level=5
  end

  --simple camera
  cam_x=0
  cam_y=0

  --map limits
  map_start=0
  map_end=1024

  --time
  milliseconds=0
  seconds=0
  minutes=0
  hours=0
  sprun=0

  --timer
function updateplaytime()
 milliseconds+=1
 
 if milliseconds==30 then
  seconds+=1
  milliseconds=0
  if seconds==60 then
   minutes+=1
   seconds=0
   if minutes==60 then
    hours+=1
    minutes=0
   end
  end
 end
end

--toggle jump btn in pause menu
menuitem(1,"swap —/",function() —,=,— end)
 function btnr(b)
  return not btn(b) and f_btn[b]
 end
 
function _init()
  init_menu()
end
-->8
--update and draw

function init_game()
  music(10)

function _update()
  player_update()
  player_animate()
  updateplaytime()

  if not player.landed then
   airtime+=1
   else
   airtime=0
  end
 
  if player.deaths>9999 then
    player.deaths=9999
  end

  if player.jumps>9999 then
    player.jumps=9999
  end

  --simple camera
  cam_x=player.x-64+(player.w/2)
  if cam_x<map_start then
     cam_x=map_start
  end
  if cam_x>map_end-128 then
     cam_x=map_end-128
  end
  camera(cam_x,cam_y)
end

function _draw()
 if level==1 then
  cls(12)
 elseif level==2 then
  cls(1)
 elseif level==3 then
  cls(0)
 elseif level==4 then
  cls()
 end
 rectfill(0,96,23,111,1)
 rectfill(48,96,71,111,1)
 rectfill(32,104,39,109,1)
 rectfill(80,96,103,111,1)
 rectfill(112,96,135,111,1)
 
  map(0,0,0,0,128,64)
  spr(player.sp,player.x,player.y,1,1,player.flp)
  
--fire top
  spr(firea.sp,firea.x+168,firea.y+368)
  spr(firea.sp,firea.x+176,firea.y+368)
  spr(firea.sp,firea.x+184,firea.y+368)
  spr(firea.sp,firea.x+192,firea.y+368)
  --
  spr(firea.sp,firea.x+216,firea.y+368)
  spr(firea.sp,firea.x+224,firea.y+368)
  --
  spr(firea.sp,firea.x+248,firea.y+368)
  spr(firea.sp,firea.x+256,firea.y+368)
  spr(firea.sp,firea.x+264,firea.y+368)
  --
  spr(firea.sp,firea.x+288,firea.y+368)
  spr(firea.sp,firea.x+296,firea.y+368)
  spr(firea.sp,firea.x+304,firea.y+368)
  --
  spr(firea.sp,firea.x+328,firea.y+368)
  spr(firea.sp,firea.x+336,firea.y+368)
  spr(firea.sp,firea.x+344,firea.y+368)
  spr(firea.sp,firea.x+352,firea.y+368)
  spr(firea.sp,firea.x+360,firea.y+368)
  spr(firea.sp,firea.x+368,firea.y+368)
  --
  spr(firea.sp,firea.x+440,firea.y+368)
  spr(firea.sp,firea.x+448,firea.y+368)
  spr(firea.sp,firea.x+456,firea.y+368)
  spr(firea.sp,firea.x+464,firea.y+368)
  spr(firea.sp,firea.x+472,firea.y+368)
  spr(firea.sp,firea.x+480,firea.y+368)
  spr(firea.sp,firea.x+488,firea.y+368)
  --
  spr(firea.sp,firea.x+528,firea.y+368)
  spr(firea.sp,firea.x+536,firea.y+368)
  --
  spr(firea.sp,firea.x+560,firea.y+368)
  spr(firea.sp,firea.x+568,firea.y+368)
  spr(firea.sp,firea.x+576,firea.y+368)
  --
  spr(firea.sp,firea.x+600,firea.y+368)
  spr(firea.sp,firea.x+608,firea.y+368)
  spr(firea.sp,firea.x+616,firea.y+368)
  spr(firea.sp,firea.x+624,firea.y+368)
  --
  spr(firea.sp,firea.x+664,firea.y+368)
  --
  spr(firea.sp,firea.x+688,firea.y+368)
  spr(firea.sp,firea.x+696,firea.y+368)
  --
  spr(firea.sp,firea.x+720,firea.y+368)
  spr(firea.sp,firea.x+728,firea.y+368)
  --
  spr(firea.sp,firea.x+1016,firea.y+496)
  spr(firea.sp,firea.x+1008,firea.y+496)
  spr(firea.sp,firea.x+1000,firea.y+496)
  spr(firea.sp,firea.x+992,firea.y+496)
  spr(firea.sp,firea.x+984,firea.y+496)
  spr(firea.sp,firea.x+976,firea.y+496)
  spr(firea.sp,firea.x+968,firea.y+496)
  spr(firea.sp,firea.x+960,firea.y+496)
  spr(firea.sp,firea.x+952,firea.y+496)
  spr(firea.sp,firea.x+944,firea.y+496)
  spr(firea.sp,firea.x+936,firea.y+496)
  spr(firea.sp,firea.x+928,firea.y+496)
  spr(firea.sp,firea.x+920,firea.y+496)
  spr(firea.sp,firea.x+912,firea.y+496)
  spr(firea.sp,firea.x+904,firea.y+496)
  spr(firea.sp,firea.x+896,firea.y+496)
  --
  spr(firea.sp,firea.x+928,firea.y+464)
  spr(firea.sp,firea.x+936,firea.y+464)
  spr(firea.sp,firea.x+944,firea.y+464)
  spr(firea.sp,firea.x+952,firea.y+464)
  spr(firea.sp,firea.x+960,firea.y+464)
  spr(firea.sp,firea.x+968,firea.y+464)
  spr(firea.sp,firea.x+976,firea.y+464)
  spr(firea.sp,firea.x+984,firea.y+464)
  spr(firea.sp,firea.x+992,firea.y+464)
  spr(firea.sp,firea.x+1000,firea.y+464)
  spr(firea.sp,firea.x+1008,firea.y+464)
  spr(firea.sp,firea.x+1016,firea.y+464)
  --
  spr(firea.sp,firea.x+744,firea.y+496)
  spr(firea.sp,firea.x+752,firea.y+496)
  spr(firea.sp,firea.x+760,firea.y+496)
  spr(firea.sp,firea.x+768,firea.y+496)
  spr(firea.sp,firea.x+776,firea.y+496)
  spr(firea.sp,firea.x+784,firea.y+496)
  spr(firea.sp,firea.x+792,firea.y+496)
  spr(firea.sp,firea.x+800,firea.y+496)
  spr(firea.sp,firea.x+808,firea.y+496)
  spr(firea.sp,firea.x+816,firea.y+496)
  spr(firea.sp,firea.x+824,firea.y+496)
  spr(firea.sp,firea.x+832,firea.y+496)
  spr(firea.sp,firea.x+840,firea.y+496)
  spr(firea.sp,firea.x+848,firea.y+496)
  spr(firea.sp,firea.x+856,firea.y+496)
  spr(firea.sp,firea.x+864,firea.y+496)
  spr(firea.sp,firea.x+872,firea.y+496)
  spr(firea.sp,firea.x+880,firea.y+496)
  --
  spr(firea.sp,firea.x+648,firea.y+496)
  spr(firea.sp,firea.x+656,firea.y+496)
  spr(firea.sp,firea.x+664,firea.y+496)
  spr(firea.sp,firea.x+672,firea.y+496)
  --
  spr(firea.sp,firea.x+704,firea.y+496)
  spr(firea.sp,firea.x+712,firea.y+496)
  --
  spr(firea.sp,firea.x+528,firea.y+496)
  spr(firea.sp,firea.x+536,firea.y+496)
  spr(firea.sp,firea.x+560,firea.y+496)
  spr(firea.sp,firea.x+568,firea.y+496)
  --
  spr(firea.sp,firea.x+416,firea.y+496)
  spr(firea.sp,firea.x+424,firea.y+496)
  spr(firea.sp,firea.x+432,firea.y+496)
  spr(firea.sp,firea.x+440,firea.y+496)
  spr(firea.sp,firea.x+448,firea.y+496)
  spr(firea.sp,firea.x+456,firea.y+496)
  spr(firea.sp,firea.x+464,firea.y+496)
  spr(firea.sp,firea.x+472,firea.y+496)
  spr(firea.sp,firea.x+480,firea.y+496)
  spr(firea.sp,firea.x+488,firea.y+496)
  spr(firea.sp,firea.x+496,firea.y+496)
  spr(firea.sp,firea.x+504,firea.y+496)
  --
  spr(firea.sp,firea.x+192,firea.y+472)
  spr(firea.sp,firea.x+232,firea.y+496)
  spr(firea.sp,firea.x+240,firea.y+496)
  spr(firea.sp,firea.x+256,firea.y+424)
  spr(firea.sp,firea.x+264,firea.y+424)
  spr(firea.sp,firea.x+320,firea.y+488)
  spr(firea.sp,firea.x+328,firea.y+488)
  spr(firea.sp,firea.x+368,firea.y+416)
  spr(firea.sp,firea.x+376,firea.y+416)
--fire bottom
  spr(fireb.sp,fireb.x+168,fireb.y+368)
  spr(fireb.sp,fireb.x+176,fireb.y+368)
  spr(fireb.sp,fireb.x+184,fireb.y+368)
  spr(fireb.sp,fireb.x+192,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+216,fireb.y+368)
  spr(fireb.sp,fireb.x+224,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+248,fireb.y+368)
  spr(fireb.sp,fireb.x+256,fireb.y+368)
  spr(fireb.sp,fireb.x+264,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+288,fireb.y+368)
  spr(fireb.sp,fireb.x+296,fireb.y+368)
  spr(fireb.sp,fireb.x+304,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+328,fireb.y+368)
  spr(fireb.sp,fireb.x+336,fireb.y+368)
  spr(fireb.sp,fireb.x+344,fireb.y+368)
  spr(fireb.sp,fireb.x+352,fireb.y+368)
  spr(fireb.sp,fireb.x+360,fireb.y+368)
  spr(fireb.sp,fireb.x+368,fireb.y+368)
--
  spr(fireb.sp,fireb.x+440,fireb.y+368)
  spr(fireb.sp,fireb.x+448,fireb.y+368)
  spr(fireb.sp,fireb.x+456,fireb.y+368)
  spr(fireb.sp,fireb.x+464,fireb.y+368)
  spr(fireb.sp,fireb.x+472,fireb.y+368)
  spr(fireb.sp,fireb.x+480,fireb.y+368)
  spr(fireb.sp,fireb.x+488,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+528,fireb.y+368)
  spr(fireb.sp,fireb.x+536,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+560,fireb.y+368)
  spr(fireb.sp,fireb.x+568,fireb.y+368)
  spr(fireb.sp,fireb.x+576,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+600,fireb.y+368)
  spr(fireb.sp,fireb.x+608,fireb.y+368)
  spr(fireb.sp,fireb.x+616,fireb.y+368)
  spr(fireb.sp,fireb.x+624,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+664,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+688,fireb.y+368)
  spr(fireb.sp,fireb.x+696,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+720,fireb.y+368)
  spr(fireb.sp,fireb.x+728,fireb.y+368)
  --
  spr(fireb.sp,fireb.x+1016,fireb.y+496)
  spr(fireb.sp,fireb.x+1008,fireb.y+496)
  spr(fireb.sp,fireb.x+1000,fireb.y+496)
  spr(fireb.sp,fireb.x+992,fireb.y+496)
  spr(fireb.sp,fireb.x+984,fireb.y+496)
  spr(fireb.sp,fireb.x+976,fireb.y+496)
  spr(fireb.sp,fireb.x+968,fireb.y+496)
  spr(fireb.sp,fireb.x+960,fireb.y+496)
  spr(fireb.sp,fireb.x+952,fireb.y+496)
  spr(fireb.sp,fireb.x+944,fireb.y+496)
  spr(fireb.sp,fireb.x+936,fireb.y+496)
  spr(fireb.sp,fireb.x+928,fireb.y+496)
  spr(fireb.sp,fireb.x+920,fireb.y+496)
  spr(fireb.sp,fireb.x+912,fireb.y+496)
  spr(fireb.sp,fireb.x+904,fireb.y+496)
  spr(fireb.sp,fireb.x+896,fireb.y+496)
  --
  spr(fireb.sp,fireb.x+928,fireb.y+464)
  spr(fireb.sp,fireb.x+936,fireb.y+464)
  spr(fireb.sp,fireb.x+944,fireb.y+464)
  spr(fireb.sp,fireb.x+952,fireb.y+464)
  spr(fireb.sp,fireb.x+960,fireb.y+464)
  spr(fireb.sp,fireb.x+968,fireb.y+464)
  spr(fireb.sp,fireb.x+976,fireb.y+464)
  spr(fireb.sp,fireb.x+984,fireb.y+464)
  spr(fireb.sp,fireb.x+992,fireb.y+464)
  spr(fireb.sp,fireb.x+1000,fireb.y+464)
  spr(fireb.sp,fireb.x+1008,fireb.y+464)
  spr(fireb.sp,fireb.x+1016,fireb.y+464)
  --
  spr(fireb.sp,fireb.x+744,fireb.y+496)
  spr(fireb.sp,fireb.x+752,fireb.y+496)
  spr(fireb.sp,fireb.x+760,fireb.y+496)
  spr(fireb.sp,fireb.x+768,fireb.y+496)
  spr(fireb.sp,fireb.x+776,fireb.y+496)
  spr(fireb.sp,fireb.x+784,fireb.y+496)
  spr(fireb.sp,fireb.x+792,fireb.y+496)
  spr(fireb.sp,fireb.x+800,fireb.y+496)
  spr(fireb.sp,fireb.x+808,fireb.y+496)
  spr(fireb.sp,fireb.x+816,fireb.y+496)
  spr(fireb.sp,fireb.x+824,fireb.y+496)
  spr(fireb.sp,fireb.x+832,fireb.y+496)
  spr(fireb.sp,fireb.x+840,fireb.y+496)
  spr(fireb.sp,fireb.x+848,fireb.y+496)
  spr(fireb.sp,fireb.x+856,fireb.y+496)
  spr(fireb.sp,fireb.x+864,fireb.y+496)
  spr(fireb.sp,fireb.x+872,fireb.y+496)
  spr(fireb.sp,fireb.x+880,fireb.y+496)
  --
  spr(fireb.sp,fireb.x+648,fireb.y+496)
  spr(fireb.sp,fireb.x+656,fireb.y+496)
  spr(fireb.sp,fireb.x+664,fireb.y+496)
  spr(fireb.sp,fireb.x+672,fireb.y+496)
  --
  spr(fireb.sp,fireb.x+704,fireb.y+496)
  spr(fireb.sp,fireb.x+712,fireb.y+496)
  --
  spr(fireb.sp,fireb.x+528,fireb.y+496)
  spr(fireb.sp,fireb.x+536,fireb.y+496)
  spr(fireb.sp,fireb.x+560,fireb.y+496)
  spr(fireb.sp,fireb.x+568,fireb.y+496)
--
  spr(fireb.sp,fireb.x+416,fireb.y+496)
  spr(fireb.sp,fireb.x+424,fireb.y+496)
  spr(fireb.sp,fireb.x+432,fireb.y+496)
  spr(fireb.sp,fireb.x+440,fireb.y+496)
  spr(fireb.sp,fireb.x+448,fireb.y+496)
  spr(fireb.sp,fireb.x+456,fireb.y+496)
  spr(fireb.sp,fireb.x+464,fireb.y+496)
  spr(fireb.sp,fireb.x+472,fireb.y+496)
  spr(fireb.sp,fireb.x+480,fireb.y+496)
  spr(fireb.sp,fireb.x+488,fireb.y+496)
  spr(fireb.sp,fireb.x+496,fireb.y+496)
  spr(fireb.sp,fireb.x+504,fireb.y+496)
  --
  spr(fireb.sp,fireb.x+192,fireb.y+472)
  spr(fireb.sp,fireb.x+232,fireb.y+496)
  spr(fireb.sp,fireb.x+240,fireb.y+496)
  spr(fireb.sp,fireb.x+256,fireb.y+424)
  spr(fireb.sp,fireb.x+264,fireb.y+424)
  spr(fireb.sp,fireb.x+320,fireb.y+488)
  spr(fireb.sp,fireb.x+328,fireb.y+488)
  spr(fireb.sp,fireb.x+368,fireb.y+416)
  spr(fireb.sp,fireb.x+376,fireb.y+416)
--timer
  print("“"..hours..":"..minutes..":"..seconds..":"..milliseconds,camera(cam_x+0),2,2)
  print("“"..hours..":"..minutes..":"..seconds..":"..milliseconds,camera(cam_x+0),1,10)  
  
 --level
  if level==1 then
    print("MEADOW VILLAGE",camera(cam_x+0),122,2)
    print("MEADOW VILLAGE",camera(cam_x+0),121,10)
  elseif level==2 then
    print("SLEET SIERRA",camera(cam_x+0),122,2)
    print("SLEET SIERRA",camera(cam_x+0),121,10)
  elseif level==3 then
    print("PRIMEVAL FOREST",camera(cam_x+0),122,2)
    print("PRIMEVAL FOREST",camera(cam_x+0),121,10)
  elseif level==4 then
    print("GOBLET PALACE",camera(cam_x+0),122,2)
    print("GOBLET PALACE",camera(cam_x+0),121,10)
  end
  
--ABCDEFGHIJKLMNOPQRSTUVWXYZ
  
  --debug--
 --print("jumps:"..player.jumps,camera(cam_x+0),14)
 --print("cpu:"..flr(stat(1)*100).."%",camera(cam_x+0),20)
 --print("target fps:"..flr(stat(8)),camera(cam_x+0),26)
 --print("pico-8 fps:"..flr(stat(9)),camera(cam_x+0),32)
 --print("mem:"..flr(stat(0)),camera(cam_x+0),38)
 --print("x pos:".. player.x,camera(cam_x+0),44)
 --print("y pos:".. player.y,camera(cam_x+0),50)
 --print("x tile:".. ((player.x - (player.x % 8)) / 8),camera(cam_x+0),56)
 --print("y tile:".. ((player.y - (player.y % 8)) / 8),camera(cam_x+0),62)
 --print("music ticks:"..flr(stat(26)),camera(cam_x+0),68)
 --print("deaths:"..player.deaths,camera(cam_x+0),74)
 --print("airtime="..airtime,camera(cam_x+0),110)
  ---------
end

end
-->8
--collisions

function collide_map(obj,aim,flag)
 --obj = table needs x,y,w,h
 --aim = left,right,up,down

 local x=obj.x  local y=obj.y
 local w=obj.w  local h=obj.h

 local x1=0	 local y1=0
 local x2=0  local y2=0

 if aim=="left" then
   x1=x-1  y1=y
   x2=x    y2=y+h-1

 elseif aim=="right" then
   x1=x+w-1    y1=y
   x2=x+w  y2=y+h-1

 elseif aim=="up" then
   x1=x+2    y1=y-1
   x2=x+w-3  y2=y

 elseif aim=="down" then
   x1=x+2      y1=y+h
   x2=x+w-3    y2=y+h
 end

 --pixels to tiles
 x1/=8    y1/=8
 x2/=8    y2/=8

 if fget(mget(x1,y1), flag)
 or fget(mget(x1,y2), flag)
 or fget(mget(x2,y1), flag)
 or fget(mget(x2,y2), flag) then
   return true
 else
   return false
 end

end
-->8
--player

function player_update()
  --flag 2 = spikes
  if collide_map(player,"down",2) then
    init_death()
    player.deaths+=1
    sfx(9)
  elseif collide_map(player,"up",2) then
    init_death()
    player.deaths+=1
    sfx(9)
  elseif collide_map(player,"left",2) then
    init_death()
    player.deaths+=1
    sfx(9)
  elseif collide_map(player,"right",2) then
    init_death()
    player.deaths+=1
    sfx(9)
  --flag 3 = ice
  elseif collide_map(player,"down",3) then
    friction=0.97
    player.max_dx=2.7
  --flag 4 = honey
  elseif collide_map(player,"down",4) then
    friction=0.1
    player.boost=2.3
  --flag 6 = win
  elseif collide_map(player,"down",6) then
    init_win()
  elseif collide_map(player,"left",6) then
    init_win()
  elseif collide_map(player,"right",6) then
    init_win()
    
  --flag 7 = next level
  elseif collide_map(player,"down",7) then
    level+=1
      if level==1 then
        cam_y+=0
        player.x=8
        player.y=104
      elseif level==2 then
        cam_y+=128
        player.x=16
        player.y=216
      elseif level==3 then
        cam_y+=128
        player.x=24
        player.y=360
      elseif level==4 then
        cam_y+=128
        player.x=1008
        player.y=488
      end
    sfx(10)
  else
    --default
    friction=0.85
    player.max_dx=2
    player.boost=4.6
    gravity=0.3
  end


  --physics
  player.dy+=gravity
  player.dx*=friction

  --controls
  if btn(‹) then
    player.dx-=player.acc
    player.running=true
    player.flp=true
  end
  if btn(‘) then
    player.dx+=player.acc
    player.running=true
    player.flp=false
  end

  --slide
  if player.running
  and not btn(‹)
  and not btn(‘)
  and not player.falling
  and not player.jumping then
    player.running=false
    player.sliding=true
  end

  --crouch
  if btn(ƒ)
  and not player.running
  and not player.sliding then
    player.sp=11
    if time()-player.anim>.05 then
      player.anim=time()
    end
  end

  --jump
  if btnp(—)
  and player.landed then
    player.dy-=player.boost
    player.landed=false
    player.jumps+=1
    sfx(7)
  elseif not player.landed and airtime<3 and btnp(—) then
    player.dy-=player.boost*1.1
    player.landed=false
    player.jumps+=1
    sfx(7)
  end

  --check collision up and down
  if player.dy>0 then
    player.falling=true
    player.landed=false
    player.jumping=false

    player.dy=limit_speed(player.dy,player.max_dy)

    if collide_map(player,"down",0) then
      player.landed=true
      player.falling=false
      player.dy=0
      player.y-=((player.y+player.h+1)%8)-1
    end
  elseif player.dy<0 then
    player.jumping=true
    if collide_map(player,"up",1) then
      player.dy=0
    end
  end

  --check collision left and right
  if player.dx<0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"left",1) then
      player.dx=0
    end
  elseif player.dx>0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"right",1) then
      player.dx=0
    end
  end

  --stop sliding
  if player.sliding then
    if abs(player.dx)<.2
    or player.running then
      player.dx=0
      player.sliding=false
    end
  end

  player.x+=player.dx
  player.y+=player.dy

  --limit player to map
  if player.x<map_start then
    player.x=map_start
  end
  if player.x>map_end-player.w then
    player.x=map_end-player.w
  end
end

function player_animate()
  if player.jumping then
    player.sp=7
  elseif player.falling then
    player.sp=8
  elseif player.sliding then
    player.sp=9
  elseif player.running then
    if time()-player.anim>.1 then
      player.anim=time()
      player.sp+=1
      if player.sp>6 then
        player.sp=3
      end
    end
  else --player idle
    if time()-player.anim>.3 then
      player.anim=time()
      player.sp+=1
      if player.sp>2 then
        player.sp=1
      end
    end
  end
--fire top
  if time()-firea.anim>.1 then
    firea.anim=time()
    firea.sp+=1
      if firea.sp>31 then
        firea.sp=28
      end
  end
--fire bottom
  if time()-fireb.anim>.1 then
    fireb.anim=time()
    fireb.sp+=1
      if fireb.sp>47 then
        fireb.sp=44
      end
  end
end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end
-->8
--menu

function init_menu()
  _update=update_menu
  _draw=draw_menu
end

function update_menu()
 if btnp() or btnp(—) then
   init_plot()
 end
end

function draw_menu()
 cls(1)
 print("for toy box jam 2020",2,2,2)
 print("for toy box jam 2020",1,1,10)
 
 print("by niall chandler",2,9,2)
 print("by niall chandler",1,8,10)
 
 print("press —/ to continue",19,122,2)
 print("press —/ to continue",18,121,10)
 
--title screen text
rectfill(40,40,87,55,2)
 --goblet
 spr(54,40,40)
 spr(55,48,40)
 spr(57,56,40)
 spr(62,64,40)
 spr(58,72,40)
 spr(63,80,40)
 --palace
 spr(54,40,48)
 spr(55,48,48)
 spr(56,56,48)
 spr(57,64,48)
 spr(58,72,48)
 spr(59,80,48)
 --cup
 spr(52,30,44)
 spr(52,90,44)
--between fill
rectfill(40,40,87,40,5)
rectfill(40,47,87,48,5)
rectfill(40,55,87,55,5)
rectfill(39,40,39,55,5)
rectfill(40,39,87,39,5)
rectfill(40,56,87,56,5)
rectfill(88,40,88,55,5)
 
  --time
 print(""..stat(93)..":"..stat(94)..":"..stat(95),96,9,2)
 print(""..stat(93)..":"..stat(94)..":"..stat(95),95,8,10)
   --date
 print(""..stat(92).."/"..stat(91).."/"..stat(90),88,2,2)
 print(""..stat(92).."/"..stat(91).."/"..stat(90),87,1,10)
end
-->8
--plot

function init_plot()
  _update=update_plot
  _draw=draw_plot
end

function update_plot()
 if btnp() or btnp(—) then
   init_game()
 end
end

function draw_plot()
 cls(2)
 print("the plot",49,2,1)
 print("the plot",48,1,10)
 print("",1,6,7)
 print(" you are ninjoe, a ninja from",1,10,7)
 print("meadow village. one day, your",1,16,7)
 print("friend adam falls ill with an",1,22,7)
 print("unknown illness.",1,28,7)
 print(" the village elder suggests you",1,34,7)
 print("journey to acquire the golden",1,40,7)
 print("goblet of legend, said to cure",1,46,7)
 print("those who drink from it of any",1,52,7)
 print("and all sickness!",1,58,7)
 print(" the elder claims the goblet is",1,64,7)
 print("located in an underground palace",1,70,7)
 print("engulfed by the primeval forest.",1,76,7)
 print(" it is a dangerous place. no one",1,82,7)
 print("who has journeyed to the palace",1,88,7)
 print("of the goblet has ever returned!",1,94,7)
 print(" good luck, and return soon... ",1,100,7)
 print("else you may not get back in",1,106,7)
 print("time to save your friend.",1,112,7)
 print("",1,117,7)
 print("press —/ to continue",19,122,1)
 print("press —/ to continue",18,121,10)
end
-->8
--dead

function init_death()
  _update=update_death
  _draw=draw_death
end

function update_death()
 player.sp=10
  if btnp(—) or btnp() then
    init_game()
      if level==1 then
        cam_x=0
        cam_y=0
        player.x=8
        player.y=104
      elseif level==2 then
        cam_x=0
        cam_y=128
        player.x=16
        player.y=216
      elseif level==3 then
        cam_x=0
        cam_y=256
        player.x=24
        player.y=360
      elseif level==4 then
        cam_x=0
        cam_y=384
        player.x=1008
        player.y=488
      end
    end
end

function draw_death()
  cls()
  camera(cam_x,cam_y)
  music(-1)
  spr(player.sp,player.x,player.y,1,1,player.flp) 
  print(" you died. press —/ to retry",camera(cam_x+0),1,1)
  print(" you died. press —/ to retry",camera(cam_x+1),0,8)

end
-->8
--win
--activates upon beating lv4

--ABCDEFGHIJKLMNOPQRSTUVWXYZ

function init_win()
  _update=update_win
  _draw=draw_win
   music(19)
end

function update_win()

end

function draw_win()
 cls(1)
 camera(0,0)
 
 print("’’’’congradulations’’’’",2,1,10)
 print("’’’’’’you win’’’’’’",2,7,10)

 print("",0,11,7)
 if player.deaths==0 then
 print("number of deaths:"..player.deaths,24,15,10)
 else
 print("number of deaths:"..player.deaths,24,15,8)
 end
 if minutes <3 then
 print("end time:"..hours.."h "..minutes.."m "..seconds.."s "..milliseconds.."f",24,21,10)
 else
 print("end time:"..hours.."h "..minutes.."m "..seconds.."s "..milliseconds.."f",24,21,8)
 end
 print("",0,25,7)
 
   print(" well done! you've succeeded in",0,29,7)
   print("the task of acquiring the",0,35,7)
   print("legendary golden goblet!",0,41,7)
   if minutes<3 then
   print(" you return to meadow village to ",0,47,7)
   print("find your friend adam still",0,53,7)
   print("alive. hopeful, you give him the",0,59,7)
   print("golden goblet to drink from.",0,65,7)
   print(" upon drinking from it, he is",0,71,7)
   print("cured of his illness, and the",0,77,7)
   print("village celebrates this miracle!",0,83,7)
   print("GOOD ENDING",42,92,11)
   spr(26,31,91)
   spr(26,88,91)
   else
   print(" you return to meadow village,",0,47,7)
   print("only to find that sadly, your",0,53,7)
   print("friend adam is already dead.",0,59,7)
   print(" though the goblet can now be",0,65,7)
   print("used in the future to cure",0,71,7)
   print("anyone in the village, it can",0,77,7)
   print("never bring your friend back.",0,83,7)
   print("BAD ENDING",44,92,8)
   spr(25,31,91)
   spr(25,88,91)
   end

 print("",0,101,7)
 print("thank you so much for playing my",0,106,7)
 print("game! you are a super player!!",4,113,7)
 print("",0,118,7)
 print("ctrl+r TO RETURN TO TITLE SCREEN",0,123,1)
 print("ctrl+r TO RETURN TO TITLE SCREEN",0,122,10)
end

--ABCDEFGHIJKLMNOPQRSTUVWXYZ
__gfx__
000000002002821000028210002821002000000000282100220000000006822d22000000000000000077770000000000002ee20000000000007aaa00000a0000
000000000211111122111111021111102228210002111110022821000026cdcd820d000020222100076666700202221002222220002ee2000a999aa000079000
0070070011ddcdcd01ddcdcdd21ddcd60111111021ddcdcd011111100216dddd612d0000022822107116611700228221047ff740022222200a9aaa90000a9000
00077000006ddddd106dddddd1dd66660ddddcd0666ddddd0dddcdc00016dddd611c0200111111107126621701111111471ff17404ffff400a9aaaa000099000
00077000006d5ddd006d5ddd00d66d00066dddd06066dd00066dddd00015ddd06cdd52010ddcdcd00661166006ddcdcd0ffffff0471ff1740a9aaa90000a9000
007007000065111d0065111d202211000066dd00001221000066dd0000521110d66652116d5dddd00566665060d5dddd002222000ffffff00a9aaa9000099000
00000000005200100052001002000010002212000110020000221100005200100dd652106522dd11006116006552ddd100eeee0000eeee0009aaaa9000099000
000000000502001005020010000000010001200000000020000210000502001000dd510052220001005665005220011100400400004004000099990000009000
00dddd00656565650bb3b3b030bbb003606660669999999960666066166666616066606600766500004aa4000000000000000000000000000000000000000000
0dddddd066666665bb3b3b350bbb33000000000090040405000000006d6666d6007777000766665044a77a440000000000020000000200000000000000000000
dddddddd66222665b3b33333bb3bbb30603333069444444560888806624444266676d75076666665aa7777aa0000000000022020000000000000000000020000
0555555066666665b3333335b3b3b3350033330090004005008888006422224600777700765655654aa77aa40000000000000000000000000028200000022020
06666660665556650b4334503bbb3b3560333306944444456088880664442446067d67567666666504a77a400007d00000000000002888002089800000082022
06dd6c60661116650009450033b3b35500331300955555550088180064222a9600777700765565654a7aa7a400766d0002228800228988000089808000282000
06dd6c606611166500094500033355506033130600055000608818066442444666055506766666654aa44aa4076666d028988800228998200288888802882000
06dd6660cc444ccc0954545400333503003333000506400500888800642222460000000065555555aa4004aa0004400088999820022898820228889828998800
00a7777d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028899982028898982288882289999820
0a6666dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002899998088999882999982089999980
a7777d5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008999998099999828999998028999982
76666d5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028999798099999820897998208899998
76666d5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029977992089779900899779808997798
76666d5d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028977792029777900897779008977792
76666dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002977792009777900097779002977792
6ddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000897980008979800089798000897980
0077770000aaa9007507056000000000a7a999996666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
076566d000666d00565656500000000004a994405555555555777755557777555777775557755555557777755777777555777755557777555777775557755775
7665666d067176d00577750000000000097999405555555557700005577007755770077557705555577000005557700057700775577007755770077557775770
7665556d6771766d767766600000800009a999905555555557707775577057705777770057705555577777555557705557777700577777705770577057777770
7666666d6771116d0576650000088800099a99405555555557705770577057705770077557705555577000055557705557700005577007705770577057707770
076666d06777766d5656565000008000009994005555555555777700557777005777770055777775557777755557705557705555577057705777770057705770
00dddd00067766d07506056000000000000a90005555555555500005555000055500000555500000555000005555005555005555550055005500000555005500
0000000000666d00000000000000000007a999406666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
00bbbbbbbbbbbbbbbbbbbb0022222222222222227776777677777776777777767777777677777776333333333333333333333333333333330000000075757575
0b333b333b333b3333b333b042244224422442247665766576666665766666657766665576666665313335ddddddd55335dddd3dddddd5330330000060606060
0b34333433343334433343b04444444444444444766576657655556576677665767665657666666515533ddddddddd511ddddd5ddddddd310033000057575757
b3444444444444444444443b444444444444442265556555765667657676656576675665766666651dd35ddddddddd511ddddd5ddddddd510003000006060606
b3344444444444444444433b444444444444442276777677765667657676656576675665766666651d55dddddddddd511ddddd5ddddddd510003303375757575
bb34444444444444444443bb444444444222444465766576765777657665566576766565766666651555dddddddddd5115555555d51155500333330360606060
b3344224422442244224433b4224422442224224657665767666666576666665776666557666666515555ddddddddd511dd155555d15dd513033330057575757
b3222222222222222222223b222222222222222255655565655555556555555565555555655555551dddd5ddddddd5511dd55ddddd5d5d510033333006060606
b3b00b3b000000000000090000000000cccccccc60666066606660665555755555555555555755551dddddddddd55d511d555555555ddd513333333301000010
b039930b0000000000009a9000000000cccccccc00000000000000005657556666666666665575651ddddddddd55dd51155d5d555ddddd51355d335301000010
00999200000000000000090000000000cccccccc6660666066605660565757676767676767657565011d5d5dd5dd5d5115d5ddd5d5d5dd5115dd535101000010
009442000000090000e00b000b000000cccccccc00000000000000005757577777777777777575751551d5d515ddd551015d5d5d1515555115d5d55101000010
0099920000909a900eae0300b0b0bb00cccccccc06660666066605665757567676767676767575751555551155d5d5511555d5d15555555115dddd5101000010
0999992009a9090000e0030000b0b0b0cccccccc0000000000000000565756666666666666657565151555555d5d5551115555555dd5d55115dd555101000010
0444992000900b0000b00300000b00001cc11cc16606660666066606565755666666666666557565115115555555551111115555555555111555555101000010
0299922000b0030000300300000b0000111111110000000000000000555575555555555555575555011111111111111001111111111111100111111001000010
000000075000000066666666666d6666999999997ccc7cc700000000556676550001111100000000333333333333333333333333333333333333333311111111
00000076650000006d6666d66dd666d64444444477ccc7cc00000000555555550001111100000000335555513133315333d553333533dd5335dddd5110000001
00000766665000006666666666dd6d6605500550c77ccc7c0000000065655656000111111111110013dddd553535355113ddd331153dd5111dd11d5111111111
0000766666650000666666666d66666604500450cc77ccc70000000075767557000111111111110015ddddd55d353d5115dddd511d5ddd511d15515101000010
00076666666650006666666666666dd6045004507cc77ccc000000006557675600000000111111001dddddd5dd3d5d511ddddd511dd5d5511d55555101111110
0076666666666500666666666666d66604500450c7cc77cc000000006565565611111000000000001ddddd5ddd5ddd5115dddd5115dd5d5115d5d55101000010
07666666666666506d6666d66dd666dd44444444cc7cc77c077707705555555511111000000011111ddddd55dddddd5115555551155555511555555101000010
766666666666666566666666d666666d999999997cc7cc777777777755676655000000000000111115ddd5d5dd5ddd5101111110011111100111111001000010
33333333131313131313131333333333333333337999a999777677766776d77600000000000000001d5d55dd5ddddd5100000000000000000000000001000010
33333333313131313131313133113333333333339999979a766576657667566500000111011111101dd51155555dd55100001110000001100111100001000010
333333333333333333333313333113333333333399a9999976657665766756651110000001111110015555d5ddd5555100011011001011001111110001000010
33333333333333333113313131331333333333339999799765556555766756651110000001111110155d5d5d5ddd555100111101000110001001011001111110
3333333333333333331131331313133133333333a99999797677767776675665000000000000000015d555d5d5d5555100111110110111010111111001000010
3333333333333333333133333313331333333333999a999965766576766756650011111000011100155555555555515101001111011111101111111111111111
33333333333333333331333333333313333333339999979965766576766756650011111000000000115151115555511100000000011111100000000110000001
bbbbbbbb33333333333333333333333333333333979999a955655565655215560000000000000000011111111111111000000000111111110000000011111111
00000000000000d70000000000000000000000a7b7a6b6a4b4e6e5a6b6a4b4c4d4e6e5a4b4c4d4c5d5a4b4c4d4a6b6d7d6c4d4a6b6a4b400000000d70000a4d4
c4b60000000000d700000000000000000000c7f5000000000000f600a4b6c5d5a4b4a5b7c4d4a7b7d7d6a6b6e5e6d7c654545454545467546754676767545454
e7000000000000f60000000000000000000000f696a7b7a5b5d7c6a7b7a5b5c5d5c6d7a5b5c5d58797a5b5c5d5a7b7c6e6c5d5a7b7a5b500000000f60000a5b7
a7d50000000000f60000000000000000000000f50000d70000c7f5e7a7b58696a5b58696c5d5c4d4c4d4a5d5c4d4a4b454545454545467676754546754545454
00000000d70000f50000000000000000d70000f5978696e5c6a6b4d6e68696e5e6a4b4c6e5869686968696e5c6d6e6c4b6c6e5869686f6000000c7f50000f686
96f600000000c7f5000000000000d700000000f5e700f6000000f500f6878797879787978797c5d5c5d5c4b4c5d5a5b554545454545467546754676767545454
00000000f600c7f50000000000000000f60000f59687978797a5b7879787978797c5b7879787978797879787978797a7d58797879787f50000d700f5e700f587
97f50000000000f5e70000000000f600000000f50000f5000000f5c7f58686968696869686968696c6d6a7b7c4d4e5e654545454545454545454545454545454
e70000c7f50000f500000000000000c7f50000f597869686968696869686968696869686968696869686968696869686968696869686f5e700f600f50000f586
96f5e7000000c7f5000000000000f5e70000c7f50000f5e70000f500f58787978797879787978797e6d7c6d6c5d5e7d654545454545454545454545454545454
00000000f50000f5e700000000000000f50000f596879787978797879787978797879787978797879787978797879787978797879787f50000f5c7f500c7f587
97f50000000000f5000000d700c7f500000000f50000f50000c7f500f58686968696869686968696c4d4e7c6e5a4b4d7f6545454545454545454545454545454
000000c7f50000f50000000000000000f5e700f7d7869686968696869686968696869686968696869686968696869686968696869686f500c7f500f50000f586
96f50000000000f5e70000f60000f500000000f50000f5000000f5e7f7878797879787978797c4d4c5d5e6e5d7a5b5c6f555f655f665f665f655f655f6556554
00000000f5e700f500000000000000c7f50000a4b4879787975757879757578696879787978797879787978797879787c7d7d7e797d7f70000f500f50000f587
97f5e700000000f5000000f5e700f5e70000c7f55757f5005757f500a4d4a6b4c6e6a6b6c4d4c5d5c6e5d6c7e5e6c4d4f565f565f565f555f565f565f5556554
e7000000f50000f50000000000000000f50000a5b5e796869657578696575787978657578696865757968696464646a4b6e6e6a6b6a4b40000f5e7f500c7f586
96f50000000000f5e700c7f50000f500000000f55757f5005757f500c5b7c5d5c6c7a7b7c5d5e6d6e5d7e6e5a6b4c5d5f555f555f565f555f555f565f5655554
000000c7f500c7f500e400000000e400f500c7a6b6879787975757879757578696875757879787f6f6978797f6f6f6a7b7f6f6a7b7a5b500c7f500f50000f587
97f500000000c7f5000000f500c7f500006666f55757f5e75757f5e7a4b4d6d7e5e6d6c6e6e5c6d6c7d6c4d4a7b7a6b6f565f565f755f765f765f755f5556554
e7000000f50000f5c7e5e70000c7e5e7f50000a7b7869686965757869657578797865757868696f5f5869687f5f5f5f6f6f5f7a6b4c4d40000f500f5e700f586
96f5e700000000f50000c7f50000f500005656f55757f5005757f500c5b5e5e6e5c6d7d6e5d6e7e5a4b6c5d5c6e5a5b5f565f7545454545454545465f5655554
00000000f5e700f500f600000000f600f500c7c4d4e79787975757879757578696875757878797f5f5879786f5f5f5f5f5f5c6c5d5c5d50000f500f50000f587
97f50000000000f5e70000f50000f5e7005656f55757f5005757f5c7d6e6d6e5c6a6b6e5a4b4a6b6a5b7e6c6e7c6e6d6f75554545454545454545454f7656554
00000000f50000f500f5000000c7f500f50000c5d5869686965757869657578797865757868786f5f5968696f5f5f5f5f5f5f6a4b4a6b60000f5e7f500c7f586
96f50000666600f5006666f5e700f566665656f55757f5e75757f500e5d6c7a4b4a7b7c6a5b5c5b5e5c7d6e5c6e6a4b654545454545454545454545454546554
00e400c7f7e700f500f5e7000000f500f5e700c4d4879787975757879757578797875757879787f7f7978797f5f5f5f7f7f7f7a5b5a5b700c7f500f50000f787
97f700005656c7f5005656f500c7f556565656f55757f5005757f5e7c6e7e5a5b5c6d6c7c6e5d7d6e6c6a4b6e5d7a5d554545454545454545454545454546554
a4b4e6e5c4d400f700f700000000f700f70000c5d5869686965757869657578696865757968696a4d4869686f5f5f5c4b4a6d4c6d7a6b60000f500f50000a4b6
c4b40000565600f5005656f50000f556565656f55757f5005757f500a4b6d7e6e5d7a4b6d6e6d6d7a4d4c5b7a4d4c4b45454545454545454545454545454f454
a5b5a6b6c5d557575757575757575757575757e6c6333333335757333357573333335757333333a7b7333333333333a7d5a5b5e5d6a7b733333333333333a7d5
a7d53333565633333356563333333356565656335757333357573333a7b7c6e6a4b6a7b7a4b4e5e6a5b7c4d4a7b5c5d55454545454545454545454545454f454
54545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
54545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454545454
54f6f6f6f6f66555655565555454545454545454a4b4a6b6c4d4a6b6e6d7a4b4c4b6d6d7e5e6e5c6e6e5c6e6e5d7c4d454545465555565555555556555555565
55655454545454545454545423235555555555655555655555556565655555556555655565655565555555656565556555556565556555655555655555655555
54f5f5f5f5f56555556555555565545454545454a5b5a7b7c5d5a7b7a6b6a5b5c5d5e6e5d6c7c4b4e5d7e6c6e5e6c5d554545455556555555555655555655555
55555454545454545454545455656565655565656565656565655555556555555565556555555555655565556555655454565656565656565656565656565655
54f5f5f5f5f55454655555656555555554545454a6b6a4b4d7c4d4e6a7b5e6c6e5d6e5d7a6b6a5b7c4d4e5e6d6e7000054545455555555655565555555555555
65555454545454545454545455655555656565656555556565555454545565655555655565556555555555655565555454555565655555655555655555556565
54f5f5f5f5f55454545455555555655565555454a7b7a5b5e5c5d5a4b4e5c6e7c6e6c7d6a7b7e7c6c5d5e7e6a4b4000054545465556555555555555555655555
55555555652354545454545465655656565655555556565656565454548595556557575565555656556556565655555454655555655555555555655565556575
54f5f5f5f5f55454545454546555655555655565f6e5a6b6a4b4c6a5b5c7a4b60000a4b4e5d6e6d7c7d6c6d7a5b5333354545455555555556565555555555565
55655555555554545454545465655555565623232356565623235454546555555555655555656565555565656555655454556555656555556555555555555565
54f5f5f5f5f55454545454545454555565555565f5c7a7b7a5b5a6b6c6d7a7b73333a5b5d7e5c6d6e5e6a6b6c4d4e5c654545455655555555555556555555555
65555565555554545454545465656565656555556565656565555454545565656555555565555555655555555555555454555565555565555565556555655555
54f5f5f5f5f55454545454545454545455655565f7d6e6c6c7e5a7b7e7e6e5c4d4c4d4d6c6e6d7c6a6b4c5b5c5d5c4d454545455555555655555555565556555
54545555556555555523545455655565556565656555555555655454545565555565555555555555555565556555555454656555555554555555545555555554
54f5f5f5f5f55454545454545454545454545454a4b4a6b6c6e7d6d6c4d4e7c5d5c5d5c4d4e7c4b4a7b7c4d4e5e6c5d554545455655555555555555555555555
54545565555555556555545455555656565656565656565655655454546555655555556555656565656555555565555454555565655555655565555555655555
54f5f5f5f5f55454545454545454545454545454a5b5a7b7e5e5d7e6c5d5d6c7d6e6c6c5d5c7c5b7d6e5a5d5a4b4e7f654545455555565555555556555655555
54545555555565555555545423235656556565655555565665655454545555655565556565555555556555556555555454555555555565555565555565655565
54f5f5f5f5f55454545454545454545454545454a6b6a4b4c6c7d6c6a4b4c4d4e6d7e6c6d6d7e7c6e7c6e5c6a5b5c6f554545465555555556555556555555555
54546555545455555565555565555565656565656565656565555454546565555555556555555555555555655555555454858554556555556555556555555555
54f5f5f5f5f55454545454545454545454545454a7b7a5b500a6b6e7a5b5c5d5c6d6d6d6e6e5e5e6d6d7e6e5c6d7c7f565656555555555555555555555555565
54545555545455555565556555656565555565655555556565555454545555556555655565556565556555555565555454556554333333333333333333333333
54f5f543f5f55454545454545454545454545454c4d4c4d433a7b7e5c6c7d7e6c6e5d6c7c6d6c4d4e7c6c4d4d7e6e7f565656555555565555555556555556555
54546555545465556555555555556565555565655555556555555454546555655555556565556555555555656555555454858554545454545454545454545454
54f5f776f7f55454545454545454545454545454c5d5c5d5c6c4d4d7d6e6c6e5d6e6d7e6a4b4c5d50000c5b7e5d6d7f765656555556555555565555555556555
54545565545455555656565656565656565565655556565655655454545555555555655555555555655565555555655455655565555565555565655565556565
54f7758595f75454545454545454545454545454a6b6a6b6e6c5d5a6b60000c4d4e6a6b6a5b5a4b43333a6b6c4d4e55454545454555555555565555555655555
54545555545455655454545454545454545555555554545465555454546555555565555555655555655555555565555465545455546554555455546554545454
5475858585955454545454545454545454545454a7b7a7b7c7d7e7a7b73333c5d5c6a7b7c6e6a5b5a6b6a7b7c5d5e65454545454333333333333333333333333
54543333545433335454545454545454543333333354545433335454543333333333333333333333333333333333335433333333333333333333333333333333
__gff__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000704400303030303030303030303030303030303000000000303030300830000000000000001010103030303010000000000010b0003000003030101010000000000001300000000030300000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000660000000000000000000000000000006600000000000000000000006600000000000000000066000000000000000000000000000000000000000000006600000000000000000000000000000000000000660000000000000000000066000000000000000000000000660000000000000000
0000000000000000660000000000000000000000000066000000000000000000000000000066000000000000000000660000000000000000000000000000000000660000000000000000000000535200000000000000000000660000000000000000000066005152510000005350125200000000000000000000000000006600
0000000066000000000000000000000000000066000000000000660000000000000066000000000000000053125251000000000000000066000000000000000000000000000052510000660000404200000000660000000000000000000000000000000000004041420000004041414200000000660000000000000000000000
0000000000000000000066000000000000000000000000000000000000000000000000000000000000005140414142000000000000535100005352006600000000000000000040420000000000434364646400000000000000006400000000000000006464644343446464644343444300000000000000000000000000000000
0066000000000000000000000000000000000000000000006600000000000053525100000000005250534043444343000000000000404200004042000000000000000064646443430000000000444300000000000000660000000000000000000066000000000000000000004443434300000000000000000000660000000000
0000000000000000000000000000000066000000000000000000000000000040414200006600004041414344434343323232323232434364644443000000000000000000000044430000000000434300000000000000000000000000000000000000000000000000000066004343434300006600000000000000000000000000
0000000000006600000000000000000000000000006600000000000066000043434400000000004344434343434344414141414141444300004343000000000066000000000000000000000000000000000066000000000000000000006600000000000000000000000051134344434300000000000000000000000000000066
0000000000000000000000006600000000000000000000525053000000000044434300000000004300000000006600000000000000000000524344000000000000000000000000000066000000000000000000000000000000000000000000000000000000006600000040414343434400000000000000000000006600000000
0000000066000000000000000000000000000000000000404142000000000043434300000000004300000000000000000000000066000000404343000000000000000000660000000000000000000066000000000000000066000000000000000000000000000000000043434443434300000000006600000000000000000000
0000000000000000000000000000000000000000000000444343000000000043444432323232324400660000000000000000000000000000434343000066000000000000000000000000000000000000000000000000000000000000000000000000660053125100000043434343444300000000000000000000000000000000
001b00000000001b0000001b0000001b00525351000000434343000000000043434341414141414300000000000000000000000000000000444343000000000000000000000000000000000075757575000000000066000000000000000000000000000040414200000044434343434300660000000000000000000000000000
6077610000006077610060776100607761404142000000434344000000000043444343444343434300005350510000535212530000005213434343000000000000000000000000007575757575757575007575750000000000006600000000000000000043444300000043434344434300006666666666000066666666660000
5656560000005656560056565600565656434344000000434443000000000043434332323243444300004041420000404141420000004041434344000000000000005351125300007575757575757575007575750000000000000000000052505300000044434300000043434343434400006565656565000065656565650000
1817561215121816561218145612181756444343000000434343000000000000000000000000000000004344430000434443430000004343434443000000000000004041414200007575757575757575007575750000757575007575750040414200000043434300000043444343434300006565656565000065656565650000
41414141414141414141414141414141414344435113524343445350525053535000000000005350521343434432324343444332323243444343433232323232323243434443323275757575757575753275757532327575753275757532434343323232434344323232434344434343323265656565654f4f65656565653232
43444343434343444343434344434343444343434141414343434141414141414175757575754141414144434354544443434354545443434343445454545454545444434344545475757575757575755475757554547575755475757554434443545454434343545454444343434443545465656565654f4f65656565655454
00000000000000000000000000000000000000006600000000000000000065656565656565656565656565656565656565656565656565656565656565656565656565656565323232323265656565656500000000000000000000000000000000000000000000000000000000006565000000007a7b4a4b4c4d7d5e4c4d4a4b
00000000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006565320000000000000000000000000000006500000000000066000000000000000000660000000000000000006600006565000000006f795a5b5c5d5e6e5c5d5a5b
00660000000000000000000000000000000000000000000000000066000000000000000000000000000000000066000000000000000000000000000000006565320000006666666666666666660000006500000000000000000000660000000000000000000000000000000000006565000000005f6968696a6b6c7c4a4b6a6b
00000000000000000000000000000000660000000000000000000000000066666600000066660000000000000000000000000000000000000000000000006565320000006565656565656565650000006500006600000000000000000000000000000000000066000000000000006565000000005f7978797a7b78795a5b7a7b
00000000000066000000000000000000000000000000000000000000000065656500000065650000000000000000000066666666000000666666660000006565320000006565656565656565650000006500000000606100000000000000660000000000000000000000000000006565000000005f6968696869686968696d5e
00000000000000000060610000000000000000000000000000000000000000000000000000000000006600000000000065656565000000656565650000006565320000666565656565656565650000006500000060636361000000000000000000006666660000000000666600006565000000005f797879787978797879786f
00006600000000006063636100000000000066666666666666660000000000000000000000000000000000000000000065656565323232656565650000666565320000646565656565656565650000006500006063636363610000000000000000006565650000000000656500006565000000005f696869686968696869685f
00000000006061606363636361000000000065656565656565650000000000660000000000000000000000606100000065656565323232323265650000646565320000000000000000003265650000006500606363636263636100000000006666666565653232323232656500006565000000005f797879787978797879785f
00000000606363636363636363610000000000000000000000000000000000000000000066000000000060636261660065650000000000000000000000006565320000000000000000003265650000006560636363636363636361606100006575756565650000006061000000006565000000005f696869686968696869685f
61000060636362636363626363636100000000000060610000006600000000000000000000000060616063636565650065650000666666666666666666666565326666606166660000003265650000006563636363636363636363636361666575756565650000606363616666006565000000007f4e7879784e78794e794e7f
63616063636363636363636362636361000000006062636100000000000000006061000000006063636263636565656165650000757564646464646464646565656565656565656600003265650000606563636363636363636263636575756575756565650060656565656565006565000000004c4d4e696a6b68694c4d4a4b
6363636263656565656565656565656561000060636363626100006061000060626361000060656565656363656565636565000075753232323232323232656565656565656565640000326565006063636363626363636363636363657575657575656565606365656565656532656500004e4e5c5d5e6e7a7b78795c5d5a5b
6565656565656565656565656565656563616063626363636361606363616063636362616063656565656363656565626565000000000000000000000000000060636362636363610000326565606363636363636363636363656575657575657575656565636363636362636361000000006a6b4a4b4c4d4a4b68696a6b5e6c
656565656565656565656565656565656363656565656565656563626363656565656565636365656565626365656563656561666666666666666666666666606363636363636263616632656563636363636363636363636265657565757565757565656563636263636363636361664e4e7a7b5a5b5c5d5a5b78797a7b6d6e
656565656565656565656565656565656363656565656565656563636363656565656565636365656565636365656563656563656565646464646464646465656565656565656565656565656563626365646464656565757565657565757565757565656563656565656565656565654a4b4c4d6a6b6c6d4c4d4f4f6e6d6a6b
656565656565656565656565656565653232656565656565656532323232656565656565323265656565323265656532656532656565000000000000000065656565656565656565656565656532323265636363656565757565657565757565757565656532656565656565656565655a5b5c5d7a7b6d6c5c5d4f4f5e6c7a7b
__sfx__
010f00000007400041000001c7441c7451c54510001237040707007041000001c7441c745000001c545237040507405041000001c7441c7452354510001240450207002041000001c7441c745000001c54523744
010f00000c07300000000001874418745185451c0001c700246450000000000187441874500000185451f7040c07300000000001f7441f7451f745100001f045246450000000000187441874500000245451f744
010f00000307403041000001b7441b7451b54510001237040707007041000001b7441b745000001b5452370405074050410000020744207452454510001240450a0700a041000001a54526545225451d54522744
010f00000c073287402b7401874418745185452474024702246452f7402b74018744187452b740185452b7400c0732d740307401f7441f7451f745247401f04524645347402b745187441874500000245451f744
010f00000c07324540275401874418745185451b54033700246452c5402b540187441874527540185451f7040c07327540245401f7441f7451f745245401f045246452454022540187441874522540245451f744
010f00000807408041000001b7441b7451b54510001237040807008041000001b7441b745000001b5452370407074070410000022744227452754513001270450707007041000001a54526545225451d54522744
010f00000c07330700337001874430740307452e7402e745246452e7402e74518744187452e700185451f7040c07333700307001b5442c5402c5452b5402b545246452754027545337051a74526745227451d745
000200000b3240d331103411c341233412634127341293412c3312e32500300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000200002f3402f3412f33136334363413634136331363313632136321363213631136315383003f3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000400000024000231062002100000240002310022100213190001a00023000280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000019150201501c150231502313519130201301c130231302312519120201201c120231202311519110201101c1102311023115001000010000100001000010000100001000010000100001000010000100
010e00002042524325293252c4251d3252032524425293252c3251d4252032524325294252c3251d3252042524325293252c4251d3252032524412293252c3251d4252032524325294252c3251d3252042524325
010e00000c0430544505435054450543505445054350544501435014450143501445014350144501435014450c0430344503435034450343503445034350344500435004450043500445004350c0430043500445
010e0000184251d3252032524425356152c325184251d32520325184251d3252c325356151d32520325184251d32520325184251d32535615244251d32520325184251d3252c3252442535615203251842529325
010e00000c043014350144501435014450143520415014350c04320415014350143501435014451d415204150c043014350144501435014450143501445014350c04300445004350044500435004350043500445
010e0000182151d3251d3251d325356151d325304201d3252e4202e4201d3251d325356151d325292202c2202c2201d3251d3251d325356151d3252e4201d325294201b3251b32527420356151b3251b3251b325
010e00000c043014450143501425034450343503425034150c04305445054350542508445084350842508415356150a4450a4350a425356150c4350c4250c4150c04300445004450044500445004450043500435
010e000029420294112941229415356152b4202b4112b4122d4202d4112d4122d4123561530420304123041232411324103241032412354113541235412294163541635416294162941635416354162941629416
000c00001077513775187651c7651f755247452b73512775157751a7651e76521755267452d73514775177751c7652076523755287452f7353474500000000000000000000000000000000000000000000000000
000c0000000001074513745187451c7451f745247452b70512745157451a7451e74521745267452d70514745177451c7452074523745287452f74534705000001ca051ca051ca051ca051ca051ca051ca051ca05
001000003c60500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 00 01 43 44
00 00 01 43 44
00 02 01 43 44
00 02 01 43 44
00 00 03 43 44
00 00 03 43 44
00 02 04 43 44
00 02 04 43 44
00 05 06 43 44
02 02 06 43 44
01 0b 0c 43 44
00 0b 0c 43 44
00 0d 0c 43 44
00 0d 0c 43 44
00 0e 0f 43 44
00 0e 0f 43 44
00 0e 0f 43 44
00 0c 0f 43 44
02 10 11 43 44
04 12 13 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
