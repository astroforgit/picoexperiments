pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- selene's slumber
-- by sean manget

--variables

function _init()
 i=0
 clock_time=0
 checkpoint={
  x=8,
  y=96
 }
 state="intro"
 invin_time=0
 player={
  life=2,
  sp=1,
  x=4,
  y=104,  
  w=8,
  h=8,
  flp=false,
  dx=0,
  dy=0,
  max_dx=1,
  max_dy=3.5,
  acc=0.25,
  boost=4,
  --base settings
  --[[
  max_dx=2,
  max_dy=4,
  acc=0.25,
  boost=4,
  
  
  ]]
  anim=0,
  running=false,
  jumping=false,
  falling=false,
  sliding=false,
  landed=false
 }
 tile=8
 player_useda_be_x=-8
 player_useda_be_y=-8
 wing_anim=0
 legs_anim=0
 dead_time=0
 enemies={
  --[[ {name="clock",x=208,y=104,dx=0,
   dy=0, going="down", wings="out",friction=.99,speed=.85},
   {name="clock",x=208,y=150,dx=0,
   dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.85},
  {name="clock",x=136,y=24,dx=0,
   dy=0, acc=0.25, going="left", wings="out",friction=.99,speed=.85},
   {name="clock",x=104,y=24,dx=0, 
    dy=0,max_dx=4, max_dy=4, 
    acc=0.25, going="left", 
    wings="out",friction=.99,
    speed=.85},
   {name="electronic",x=128,y=104,going="left",
    speed=.85,h=1,w=1},
   {name="electronic",x=168,y=24,going="left",
    speed=1.5,h=1,w=1},
   {name="electronic",x=104,y=32,going="left",
    speed=.5,h=1,w=1}  ]] 
   {name="electronic",x=616,y=104,going="left",
    speed=.5,h=1,w=1},
    {name="clock",x=968,y=120,dx=0,
   dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.65},
   {name="electronic",x=696,y=104,going="left",
    speed=.8,h=1,w=1}
  }
 gravity=0.2
 --gravity=0.3
 friction=.82
 
 --simple camera
 
 cam_x=player.x-60
 cam_y=0 
 level=1
 --map limits
 map_start=0
 map_end=1024
 
 ----test--------
 x1r=0 y1r=0 x2r=0 y2r=0
 collide_l="no"
 collide_r="no"
 collide_u="no"
 collide_d="no"
 ----------------

 sheep={{x=tile*22,y=tile*13,message="welcome to your dream! \n‹”ƒ‘ to move, \nz to jump, x to run"},
 {x=tile*35,y=tile*13,message="what a dreamy night!\nhope those alarm clocks\ndon't ruin your sleep!"}, 
 {x=tile*72,y=tile*13,message="alarm clocks are baaaaad!"},
 {x=tile*98,y=tile*7,message="i can see my barn from \nhere!"},
 {x=tile*10,y=tile*25,message="things get a bit wooly\nfrom here! good luck!"},
 {x=tile*43,y=tile*26,message="we're 'counting' on you,\nselene!‡‡‡"},
 {x=tile*118,y=tile*29,message="i heard that in the\nreal world, sheep go\n'moooo!'"},
 {x=tile*13,y=tile*61,message="sometimes, you gotta take\na leap of faith!"},
 {x=tile*33,y=tile*62,message="whew, you made it!\nyou're almost there!"},
 {x=tile*119,y=tile*62,message="excellent job!\nrise and shine!"}
 }
 
end



-->8
--update and draw

function _update60() 
 
 player.pos={x=player.x,y=player.y}
 player.hitbox={x=2,y=0,w=4,h=8}
 
 player_update()
 player_animate()
 
 enemy_update()
 
 --simple camera
 cam_x=player.x
 
  
 if (cam_x-60)<map_start then
  cam_x=map_start+60
 end
 if (cam_x-60)>map_end-128 then
  cam_x=map_end-68
 end
 camera(cam_x-60,cam_y)
end

function _draw()
 
 --background
 
 rectfill(0,0,cam_x+132,cam_y+128,1)

 
--[[ line(40,40,44,44,7)
 line(40,44,44,40,7)
 line(56,56,60,60,7)
 line(56,60,60,56,7)
 line(60,42,64,46,12)
 line(60,46,64,42,12)]]
 
 
 --[[circfill(64,0,40,2)  
 circfill(64,0,38,8)
 circfill(64,0,36,9)
 circfill(64,0,34,10)
 circfill(64,0,32,3)
 circfill(64,0,30,11)
 circfill(64,0,28,1)]]
 
 if level==1 then
 circfill(64+(cam_x-60),cam_y+0,70,2)
 circfill(64+(cam_x-60),cam_y+0,65,13)
 circfill(64+(cam_x-60),cam_y+0,60,12)
 circfill(64+(cam_x-60),cam_y+0,55,3)
 circfill(64+(cam_x-60),cam_y+0,50,1)
 
 circfill(-2+(cam_x-60),cam_y+60,12,13)
 circfill(8+(cam_x-60),cam_y+70,10,13)
 circfill(18+(cam_x-60),cam_y+80,10,13)
 circfill(28+(cam_x-60),cam_y+90,10,13)
 circfill(38+(cam_x-60),cam_y+100,10,13)
 circfill(48+(cam_x-60),cam_y+110,10,13)
 circfill(58+(cam_x-60),cam_y+120,10,13)
 rectfill(0+(cam_x-60),cam_y+128,20+(cam_x-60),cam_y+70,13)
 rectfill(0+(cam_x-60),cam_y+128,40+(cam_x-60),cam_y+90,13)
 
 circfill(130+(cam_x-60),cam_y+60,12,13)
 circfill(120+(cam_x-60),cam_y+70,10,13)
 circfill(110+(cam_x-60),cam_y+80,10,13)
 circfill(100+(cam_x-60),cam_y+90,10,13)
 circfill(90+(cam_x-60),cam_y+100,10,13)
 circfill(80+(cam_x-60),cam_y+110,10,13)
 circfill(70+(cam_x-60),cam_y+120,10,13)
 rectfill(128+(cam_x-60),cam_y+128,108+(cam_x-60),cam_y+70,13)
 rectfill(128+(cam_x-60),cam_y+128,88+(cam_x-60),cam_y+90,13)
 

circfill(2+(cam_x-60),cam_y+62,10,1)
 circfill(12+(cam_x-60),cam_y+52,10,1)
 circfill(22+(cam_x-60),cam_y+42,10,1)
 circfill(32+(cam_x-60),cam_y+32,10,1)
 circfill(42+(cam_x-60),cam_y+22,10,1)
 circfill(52+(cam_x-60),cam_y+12,10,1)
 circfill(62+(cam_x-60),cam_y+2,10,1)
 
 circfill(126+(cam_x-60),cam_y+62,10,1)
 circfill(116+(cam_x-60),cam_y+52,10,1)
 circfill(106+(cam_x-60),cam_y+42,10,1)
 circfill(96+(cam_x-60),cam_y+32,10,1)
 circfill(86+(cam_x-60),cam_y+22,10,1)
 circfill(76+(cam_x-60),cam_y+12,10,1)
 circfill(66+(cam_x-60),cam_y+2,10,1)

 circfill(128+(cam_x-60),cam_y+60,10,2)
 circfill(118+(cam_x-60),cam_y+50,10,2)
 circfill(108+(cam_x-60),cam_y+40,10,2)
 circfill(98+(cam_x-60),cam_y+30,10,2)
 circfill(88+(cam_x-60),cam_y+20,10,2)
 circfill(78+(cam_x-60),cam_y+10,10,2)
 circfill(68+(cam_x-60),cam_y+0,10,2)
 

 
 
 rectfill(128+(cam_x-60),cam_y+0,80+(cam_x-60),cam_y+20,2)
 rectfill(128+(cam_x-60),cam_y+20,102+(cam_x-60),cam_y+48,2)
 
 
 
 
 
 circfill(0+(cam_x-60),cam_y+60,10,2)
 circfill(10+(cam_x-60),cam_y+50,10,2)
 circfill(20+(cam_x-60),cam_y+40,10,2)
 circfill(30+(cam_x-60),cam_y+30,10,2)
 circfill(40+(cam_x-60),cam_y+20,10,2)
 circfill(50+(cam_x-60),cam_y+10,10,2)
 circfill(60+(cam_x-60),cam_y+0,10,2)
 
 
 
-- circfill(0+(cam_x-62),50,10,14)
-- circfill(10+(cam_x-62),40,10,14)
-- circfill(20+(cam_x-62),30,10,14)
-- circfill(30+(cam_x-62),20,10,14)
-- circfill(40+(cam_x-62),10,10,14)
-- circfill(50+(cam_x-62),0,10,14)
 spr(75,61+(cam_x-60),cam_y+72,1,1,false,false)
 spr(74,61+(cam_x-60),cam_y+80,1,1,false,false)
 spr(73,61+(cam_x-60),cam_y+88,1,1,false,false)
 
 
 rectfill(0+(cam_x-60),cam_y,50+(cam_x-60),cam_y+20,2)
 rectfill(0+(cam_x-60),cam_y,24+(cam_x-60),cam_y+50,2)
 
 for i=0,8 do
  circfill((i*16)+(cam_x-60),cam_y+109,10,1)
 end
 for i=0,8 do
  circfill((i*16)+(cam_x-60),cam_y+112,10,2)
 end
  
 
 spr(120,61+(cam_x-60),cam_y+40)
 spr(119,61+(cam_x-60),cam_y+32)
 spr(115,53+(cam_x-60),cam_y+24)
 spr(116,61+(cam_x-60),cam_y+24)
 spr(117,69+(cam_x-60),cam_y+24)
 rectfill((cam_x-60),cam_y+110,128+(cam_x-60),cam_y+128,2)
 end
 if level==2 then
 
 --rainbow
  
  
 circfill((cam_x+40),cam_y+36,70,2)
 circfill((cam_x+40),cam_y+36,65,13)
 circfill((cam_x+40),cam_y+36,60,12)
 circfill((cam_x+40),cam_y+36,55,3)
 circfill((cam_x+40),cam_y+36,50,1)
 
 --moon
  circfill(cam_x+36,cam_y+40,12,14)
  circfill(cam_x+40,cam_y+36,10,1)
  
  --lower left
  circfill(cam_x+16,cam_y+60,4,2)
  circfill(cam_x+10,cam_y+66,6,2)
  circfill(cam_x+4,cam_y+72,8,2)
  circfill(cam_x-8,cam_y+84,16,2)
  circfill(cam_x-24,cam_y+102,28,2)
  circfill(cam_x-32,cam_y+126,36,2)
  circfill(cam_x-32,cam_y+106,36,2)
 --down
 
  circfill(cam_x+36,cam_y+66,4,2)
  circfill(cam_x+36,cam_y+72,6,2)
  circfill(cam_x+36,cam_y+78,8,2)
  circfill(cam_x+36,cam_y+96,16,2)
  circfill(cam_x+36,cam_y+118,28,2)
  circfill(cam_x+38,cam_y+126,36,2)

--lower right 
  circfill(cam_x+56,cam_y+60,4,2)
  circfill(cam_x+62,cam_y+66,6,2)
  circfill(cam_x+68,cam_y+72,8,2)
  circfill(cam_x+80,cam_y+84,16,2)
  circfill(cam_x+96,cam_y+102,28,2)
  circfill(cam_x+96,cam_y+126,36,2)

   
 --[[circfill(cam_x+16,cam_y+60,4,2)
  circfill(cam_x+10,cam_y+66,6,2)
  circfill(cam_x+4,cam_y+72,8,2)
  circfill(cam_x-8,cam_y+84,16,2)
  circfill(cam_x-24,cam_y+102,28,2)
  circfill(cam_x-32,cam_y+126,36,2)
  
  ]] 
   --upper left
  circfill(cam_x+16,cam_y+20,4,2)
  circfill(cam_x+10,cam_y+14,6,2)
  circfill(cam_x+4,cam_y+8,8,2)
  circfill(cam_x-8,cam_y-4,16,2)
  circfill(cam_x-24,cam_y+102,28,2)
  circfill(cam_x-32,cam_y+126,36,2)
 --up
  
  --[[circfill(cam_x+36,cam_y+66,4,2)
  circfill(cam_x+36,cam_y+72,6,2)
  circfill(cam_x+36,cam_y+78,8,2)
  circfill(cam_x+36,cam_y+96,16,2)
  circfill(cam_x+36,cam_y+118,28,2)
  circfill(cam_x+38,cam_y+126,36,2)]]
  
  circfill(cam_x+36,cam_y+14,4,2)
  circfill(cam_x+36,cam_y+8,6,2)
  circfill(cam_x+36,cam_y+2,8,2)
  circfill(cam_x+36,cam_y-16,16,2)
 
 --upper right
 
  circfill(cam_x+56,cam_y+20,4,2)
  circfill(cam_x+62,cam_y+14,6,2)
  circfill(cam_x+68,cam_y+8,8,2)
  circfill(cam_x+80,cam_y-10,16,2)
 
 -- left
  
  --[[circfill(cam_x+36,cam_y+66,4,2)
  circfill(cam_x+36,cam_y+72,6,2)
  circfill(cam_x+36,cam_y+78,8,2)
  circfill(cam_x+36,cam_y+96,16,2)
  circfill(cam_x+36,cam_y+118,28,2)
  circfill(cam_x+38,cam_y+126,36,2)]]
  
  
  circfill(cam_x+10,cam_y+40,4,2)
  circfill(cam_x+4,cam_y+40,6,2)
  circfill(cam_x+-2,cam_y+40,8,2)
  circfill(cam_x+-20,cam_y+40,16,2)
  circfill(cam_x+-42,cam_y+40,28,2)
  circfill(cam_x+-48,cam_y+46,28,2)
  circfill(cam_x+-48,cam_y+34,28,2)
  circfill(cam_x+-46,cam_y+34,28,2)
  circfill(cam_x+-28,cam_y-20,28,2)
  rectfill(cam_x-60,cam_y,cam_x-40,cam_y+128,2)
  
  circfill(cam_x+62,cam_y+40,4,2)
  circfill(cam_x+68,cam_y+40,6,2)
  circfill(cam_x+74,cam_y+40,8,2)
 
  line(cam_x+45,cam_y+18,cam_x+49,cam_y+22,12)
  line(cam_x+45,cam_y+22,cam_x+49,cam_y+18,12)
 
  line(cam_x+22,cam_y+14,cam_x+25,cam_y+17,12)
  line(cam_x+22,cam_y+17,cam_x+25,cam_y+14,12)
  
  line(cam_x+52,cam_y+32,cam_x+55,cam_y+35,12)
  line(cam_x+52,cam_y+35,cam_x+55,cam_y+32,12)
  rect(cam_x+18,cam_y+8,cam_x+19,cam_y+7,12)
 
 end
 if level==3 then
  
  circfill((cam_x+30),cam_y+80,70,2)
 circfill((cam_x+30),cam_y+80,65,13)
 circfill((cam_x+30),cam_y+80,60,12)
 circfill((cam_x+30),cam_y+80,55,3)
 circfill((cam_x+30),cam_y+80,50,1)  
  
  circfill(cam_x+30,cam_y+25,4,1)
  
  line(cam_x+30,cam_y+55,cam_x+30,cam_y+20,1)
  line(cam_x+29,cam_y+55,cam_x+29,cam_y+22,1)
  line(cam_x+31,cam_y+55,cam_x+31,cam_y+22,1)
  circfill(cam_x+30,cam_y+55,20,3)
  circfill(cam_x+25,cam_y+62,24,1)
  rectfill(cam_x+20,cam_y+70,cam_x+40,cam_y+120,2)
  circfill(cam_x+20,cam_y+65,20,1)
  circfill(cam_x+20,cam_y+90,20,1) 
  rectfill(cam_x-60,cam_y+100,cam_x+68,cam_y+138,2)
  
  circfill(cam_x-45,cam_y+20,5,14) 
  circfill(cam_x-43,cam_y+18,3,1)
   
  for i=0,13 do 
   circfill((cam_x-60)+(10*i),cam_y+94,7,1)
  end 
  for i=0,13 do 
   circfill((cam_x-60)+(10*i),cam_y+103,7,13)
  end
  
  rectfill(cam_x+20,cam_y+88,cam_x+40,cam_y+110,1)
  
  for i=0,13 do
   
   circfill((cam_x-60)+(10*i),cam_y+110,7,2)
   
  end
 end
 if level==4 then
 
  
  
  rectfill(cam_x-64,cam_y,cam_x+68,cam_y+128,2)
  circfill(cam_x+30,cam_y+312,250,14)
  
  circ(cam_x+30,cam_y+312,255,14)
  circ(cam_x+30,cam_y+312,260,14)
  circ(cam_x+30,cam_y+312,270,14)
  circfill((cam_x+30),cam_y+130,70,2)
 circfill((cam_x+30),cam_y+130,65,13)
 circfill((cam_x+30),cam_y+130,60,3)
 circfill((cam_x+30),cam_y+130,55,12)
 circfill((cam_x+30),cam_y+130,50,14)
 circfill((cam_x+30),cam_y+130,45,15)
  
  circfill(cam_x-40,cam_y+90,6,1)
  circfill(cam_x-49,cam_y+92,6,1)
  circfill(cam_x-36,cam_y+92,6,1)
  
  rectfill(cam_x-64,cam_y+90,cam_x+80,cam_y+140,1)
 
 line(cam_x-45,cam_y+18,cam_x-41,cam_y+22,14)
  line(cam_x-45,cam_y+22,cam_x-41,cam_y+18,14)
 
 line(cam_x-50,cam_y+22,cam_x-54,cam_y+26,14)
  line(cam_x-50,cam_y+26,cam_x-54,cam_y+22,14)
 
 line(cam_x-44,cam_y+26,cam_x-47,cam_y+29,14)
  line(cam_x-44,cam_y+29,cam_x-47,cam_y+26,14) 
 
 line(cam_x+11,cam_y+90,cam_x+49,cam_y+90,12)
 line(cam_x+9,cam_y+92,cam_x+51,cam_y+92,12)
 line(cam_x+9,cam_y+94,cam_x+51,cam_y+94,12)
 line(cam_x+8,cam_y+96,cam_x+52,cam_y+96,12)
 line(cam_x+8,cam_y+98,cam_x+52,cam_y+98,12)
 line(cam_x+7,cam_y+100,cam_x+53,cam_y+100,12)
 line(cam_x+7,cam_y+102,cam_x+53,cam_y+102,12)
 line(cam_x+6,cam_y+104,cam_x+54,cam_y+104,12)
 line(cam_x+6,cam_y+106,cam_x+54,cam_y+106,12)
 line(cam_x+5,cam_y+108,cam_x+55,cam_y+108,12)
 line(cam_x+5,cam_y+110,cam_x+55,cam_y+110,12)
 line(cam_x+4,cam_y+112,cam_x+56,cam_y+112,12)
 line(cam_x+4,cam_y+114,cam_x+56,cam_y+114,12)
 line(cam_x+3,cam_y+116,cam_x+57,cam_y+116,12)
 line(cam_x+3,cam_y+118,cam_x+57,cam_y+118,12)
 line(cam_x+2,cam_y+120,cam_x+58,cam_y+120,12)
 line(cam_x+2,cam_y+122,cam_x+58,cam_y+122,12)
 line(cam_x+1,cam_y+124,cam_x+59,cam_y+124,12) 
 line(cam_x+1,cam_y+126,cam_x+59,cam_y+126,12)
 line(cam_x,cam_y+128,cam_x+60,cam_y+128,12)
 
 
  
 end
 --map
 
 map( 0, 0, 0, 0, 128, 64)
 
 if level==1 then
 cam_y=0
 elseif level==2 then
 cam_y=128
 elseif level==3 then
 cam_y=256
 elseif level==4 then
 cam_y=384
 end
 rectfill(0,0,128,8,1)
 rectfill(0,112,128,127,1)
 rectfill(1000,112,1024,127,1)
  sheep_add()
 if time()-invin_time>1 or time()<1 then
  spr(player.sp,player.x,player.y,1,1,player.flp,false)
 elseif time()-invin_time>.2 and time()-invin_time<.4  then
  spr(player.sp,player.x,player.y,1,1,player.flp,false)
 elseif time()-invin_time>.6 and time()-invin_time<.8  then
  spr(player.sp,player.x,player.y,1,1,player.flp,false)
 end
 
 for enemy in all (enemies) do
  if enemy.name=="clock" then
   if enemy.wings=="out" then
    spr(34,enemy.x-4,enemy.y-4)
    spr(35,enemy.x+4,enemy.y-4) 
   elseif enemy.wings=="in" then
    spr(36,enemy.x-4,enemy.y+4)
    spr(37,enemy.x+4,enemy.y+4)
   end
   if time()-wing_anim<.4 then
    enemy.wings="out"
   elseif time()-wing_anim<.8 then
    enemy.wings="in"
   else
    wing_anim=time()
   end
  
   spr(16,enemy.x,enemy.y)
  --print(enemy.dy,0,16,7)
  
  else
   
   if time()-legs_anim<.2 then
    spr(48,enemy.x-6,enemy.y)
    spr(53,enemy.x+6,enemy.y)
   elseif time()-legs_anim<.4 then
    spr(50,enemy.x-6,enemy.y)
    spr(32,enemy.x+6,enemy.y)
   elseif time()-legs_anim<.6 then
    spr(51,enemy.x-6,enemy.y)
    spr(49,enemy.x+6,enemy.y)
   else
    legs_anim=time()
   end
   spr(58,enemy.x,enemy.y)
   
  end
  
 end
 
 -----------test------------
 --rect(x1r,y1r,x2r,y2r,7)
 --print("‹= "..collide_l,player.x,player.y-10)
 --print("‘= "..collide_r,player.x,player.y-16)
 --print("”= "..collide_u,player.x,player.y-22)
 --print("ƒ= "..collide_d,player.x,player.y-28)
 ---------------------------
 for i=1,player.life do
  spr(15,(cam_x-60)+(i*8),cam_y+4)
 end
 
-- print(player.x,cam_x,cam_y+8,10)
-- print(player.y,cam_x,cam_y+16,10)
 if time()-dead_time<=.2 then
  spr(17,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=.4 then
  spr(18,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=.6 then
  spr(19,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=.8 then
  spr(20,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=1 then
  
  spr(21,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=1.2 then
  spr(22,player_useda_be_x,player_useda_be_y)
 end
 
 if state=="ending" then
  cls()
  
  print("the end!",cam_x-10,cam_y+60,14)
  print("maybe i'll sleep in\njust a bit longer...", cam_x-30,cam_y+72,14)
 end

 if state=="intro" then
  
  rectfill(0,0,128,128,1)
 -- make_grid()
  make_big_s(14,20,14)
  
  make_e(30,26,14)
  make_l(43,22,14) 
  make_e(52,26,14)
  make_n(64,26,14)
  make_e(80,26,14)
 
  circfill(96,24,4,14)
  circfill(93,22,4,1)
  
  make_little_s(103,26)
  
  make_big_s(14,40,14)
  make_l(30,42,14)
  make_u(38,46,14)
  make_n(54,46,14)
  make_n(62,46,14) 
  make_b(77,42,14)
  make_e(93,46,14)
  make_r(106,46,14)
  
  print("press — to begin",31,tile*9)
  
  spr(103,6*tile,12*tile)
  spr(122,tile*7,tile*12)
  spr(52,tile*8,tile*12)
  spr(54,tile*9,tile*12)
  spr(80,tile*6,tile*13)
  spr(28,tile*7,tile*13)
  spr(55,tile*8,tile*13)
  spr(56,tile*9,tile*13)
  spr(67,tile*2,tile*1.9)
 end
   
end

function collide(obj, other)
  if
   other.pos.x+other.hitbox.x+other.hitbox.w > obj.pos.x+obj.hitbox.x and 
   other.pos.y+other.hitbox.y+other.hitbox.h > obj.pos.y+obj.hitbox.y and
   other.pos.x+other.hitbox.x < obj.pos.x+obj.hitbox.x+obj.hitbox.w and
   other.pos.y+other.hitbox.y < obj.pos.y+obj.hitbox.y+obj.hitbox.h 
  then
   return true
  end
end

function make_big_s(x,y,clr)
 line(x,y+13,x,y+18,clr)
 line(x+1,y+14,x+1,y+17,clr)
 line(x+2,y+16,x+1,y+17,clr)
 line(x+3,y+17,x+1,y+17,clr)
 line(x+3,y+18,x+8,y+18,clr)
 line(x+9,y+17,x+10,y+17,clr)
 rectfill(x+10,y+16,x+11,y+10,clr)
 line(x+12,y+11,x+12,y+15,clr)
 rectfill(x+9,y+9,x+11,y+12)
 rectfill(x+7,y+8,x+9,y+11)
 rectfill(x+5,y+7,x+7,y+10)
 rectfill(x+4,y+6,x+6,y+9)
 line(x+3,y+9,x+3,y+3)
 line(x+1,y+8,x+1,y+5)
 line(x+2,y+3,x+2,y+8)
 line(x+4,y+3,x+4,y+7)
 line(x+5,y+2,x+5,y+3)
 line(x+4,y+2,x+10,y+2)
 rectfill(x+11,y+3,x+12,y+4)
 line(x+12,y+2,x+12,y+5)
end

function make_e(x,y,clr)
 rectfill(x,y+4,x+2,y+8,clr)
 rectfill(x+1,y+9,x+3,y+10,clr)
 line(x+2,y+11,x+4,y+11)
 line(x+3,y+12,x+7,y+12)
 line(x+8,y+11,x+9,y+11)
 line(x+9,y+10,x+9,y+10)
 line(x+10,y+9,x+10,y+9)
 rectfill(x+1,y+2,x+2,y+3)
 rectfill(x+2,y+1,x+3,y+2)
 line(x+3,y,x+7,y)
 line(x+7,y+1,x+7,y+1)
 rectfill(x+8,y+1,x+9,y+5)
 line(x+10,y+3,x+10,y+5)
 line(x,y+5,x+10,y+5)
end

function make_l(x,y,clr)
 rectfill(x+2,y,x+4,y+16,14)
 line(x,y+16,x+6,y+16)
 line(x,y,x+4,y)
 line(x+1,y+1,x+4,y+1)
end

function make_n(x,y,clr)
 rectfill(x+2,y,x+4,y+12,14)
 line(x,y,x+4,y)
 line(x,y+12,x+6,y+12)
 rectfill(x+10,y+2,x+12,y+12,14)
 line(x+8,y+12,x+14,y+12)
 rectfill(x+9,y+1,x+11,y+2)
 rectfill(x+7,y,x+10,y+1)
 line(x+5,y+2,x+6,y+1)
end

function make_u(x,y,clr)
 line(x,y,x+3,y)
 rectfill(x+2,y,x+3,y+10)
 line(x+3,y+11,x+4,y+11)
 line(x+4,y+12,x+8,y+12)
 line(x+9,y+11,x+9,y+11)
 rectfill(x+10,y,x+11,y+12)
 line(x+12,y+12,x+13,y+12)
 line(x+8,y,x+9,y)
end

function make_b(x,y,clr)
 make_l(x,y,14)
 rectfill(x+4,y,x+6,y+16,1)
 rectfill(x,y+1,x+1,y+16,1)
 circ(x+7,y+10,6,14)
 circ(x+7,y+10,5,14)
 rectfill(x,y+1,x+1,y+16,1)
end

function make_r(x,y,clr)
 line(x,y,x+3,y,14)
 line(x,y+12,x+5,y+12,14)
 rectfill(x+2,y,x+3,y+12,14)
 line(x+4,y+1,x+5,y+1,14)
 line(x+6,y,x+8,y,14)
 rectfill(x+7,y+1,x+8,y+2,14)
end

function  make_little_s(x,y)
 line(x,y+9,x,y+12,14)
 line(x+1,y+10,x+1,y+11,14)
 line(x+2,y+11,x+2,y+12)
 line(x+2,y+12,x+6,y+12)
 line(x+5,y+11,x+7,y+11)
 rectfill(x+6,y+7,x+8,y+10)
 rectfill(x+5,y+6,x+7,y+8)
 rectfill(x+4,y+5,x+5,y+7)
 rectfill(x+1,y+4,x+3,y+6) 
 rectfill(x,y+2,x+2,y+4)
 line(x+1,y+1,x+2,y+1)
 line(x+2,y,x+5,y)
 line(x+6,y+1,x+7,y+1)
 line(x+7,y,x+7,y+3)
end
function make_grid()
 for i=1,16 do
  line(0,(i*8)-4,128,(i*8)-4,2)
  line(0,i*8,128,i*8,5)
  line((i*8)-4,0,(i*8)-4,128,2)
  line(i*8,0,i*8,128,5)
 end
end
-->8
--collisions

function collide_map(obj,aim,flag)
 --obj = table needs x,y,w,h
 --aim = left,right,up,down
 
 local x=obj.x  local y=obj.y
 local w=obj.w  local h=obj.h
 
 local x1=0  local y1=0
 local x2=0  local y2=0

 if aim=="left" then
  x1=x-1  y1=y
  x2=x-1  y2=y+h-1
 
 elseif aim=="left_e" then
  x1=x  y1=y
  x2=x  y2=y+7 
 
 elseif aim=="right" then
  x1=x+w  y1=y
  x2=x+w  y2=y+h-1
 
 elseif aim=="right_e" then
  x1=x+8  y1=y
  x2=x+8  y2=y+7
 
 elseif aim=="up" then
  x1=x+3  y1=y-1
  x2=x+w-3  y2=y
 
 elseif aim=="down" then
  x1=x+3  y1=y+h
  x2=x+w-3  y2=y+h
 
 end
 ----test----
 x1r=x1 y1r=y1
 x2r=x2 y2r=y2
 
 --pixels to tiles
 x1/=8  y1/=8
 x2/=8  y2/=8
 
 if fget(mget(x1,y1), flag)
 or fget(mget(x1,y2), flag)
 or fget(mget(x2,y1), flag)
 or fget(mget(x2,y2), flag) 
 then
  return true
 else
  return false
 end
end



-->8
--player

function player_update()
 --physics
 player.dy+=gravity
 player.dx*=friction
  
 --controls
 
 if btn(5) and state=="intro" then
  
  state="game"
 end 
 
 if btn(‹) and state!="intro" then
  player.dx-=player.acc
  player.running=true
  player.flp=true
 end
 if btn(‘) and state!="intro" then
  player.dx+=player.acc
  player.running=true
  player.flp=false
 end
 
 --slide
 if player.running
 and not btn(‹)
 and not btn(‘)
 and state!="intro"
 and not player.falling
 and not player.jumping then
  player.running=false
  player.sliding=true
 end
 
 --jump
 
 if btnp(4)
 and player.landed and state!="intro" then
  sfx(0)
  player.dy-=player.boost
  player.landed=false
 end
 if btn(5) and btn(‹) and state!="intro" then
  
  max_dx=3
  player.dx-=.2
  
 elseif btn(5) and btn(‘) and state!="intro" then
  
  max_dx=3
  player.dx+=.2
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
  
   ------test-------
   collide_d="yes"
  else
   collide_d="no"
   
   -----------------
  
  end
   
 elseif player.dy<0 then
  player.jumping=true
  
  player.dy=limit_speed(player.dy,player.max_dy)
  
  
  if collide_map(player,"up",1) then
   player.dy=0
  ------test-------
   collide_u="yes"
  else
   collide_u="no"
   
   -----------------
  
  end
  
 end
 
 --check collision left and right
 if player.dx<0 then
   if collide_map(player,"left",1) then
    player.dx=0
   ------test-------
   collide_l="yes"
   else
   collide_l="no"
   
   -----------------
   end
  
 elseif player.dx>0 then
  if collide_map(player,"right",1) then
   player.dx=0
  ------test-------
   collide_r="yes"
  else
   collide_r="no"
  
   -----------------
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
 
 if player.x<map_start then
  player.x=map_start
 end
 if player.x>map_end-player.w then
  player.x=map_end-player.w 
 end
 
 if player.x>=1008 then
  
  level+=1
  player.x=8
  player.y+=128
  create_enemies()
  checkpoint.x=player.x
  checkpoint.y=player.y
 end


 --if player.x==0 then
  
  --level+=1
  --player.x=16
  --player.y+=128
  --create_enemies()
  --checkpoint.x=player.x
  --checkpoint.y=player.y
 --end 

 if player.y>120 and level==1 then
  player.life=0
 elseif player.y>248 and level==2 then
  player.life=0
 elseif player.y>376 and level==3 then
  player.life=0
 elseif player.y>504 and level==4 then
  player.life=0
 end
 for enemy in all (enemies) do
  
  enemy.pos={x=enemy.x,y=enemy.y}
  enemy.hitbox={x=0,y=0,w=8,h=8}
  
  if collide(player,enemy) and time()-invin_time>1 then
   
   
   
   
   if player.flp==true then
    player.dy=0
    player.dx=0
    player.dy-=2
    player.dx+=4
   else
    
    player.dy=0
    player.dx=0
    player.dy-=2
    player.dx-=4
   end
   if player.life>1 then
    sfx(5) 
   end
   player.life-=1 
   if player.life==0 then
    player_useda_be_y=player.y
    player_useda_be_x=player.x
    player.y-=128
    sfx(4)
    dead_time=time()
   end
   if player.life>=1 then
    invin_time=time()
   end
  end
  
 end
 if player.life<=0 then
  
  
  player_dead()
  
  
 end
 if level==5 then
  state="ending"
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
 else --player.idle
  if time()-player.anim>.3 then
   player.anim=time()
   player.sp+=1
   if player.sp>2 then
    player.sp=1
   end
  end
 end
end
function limit_speed(num,maximum)
 return mid(-maximum,num,maximum)
end
-->8
--enemies

function enemy_update()
 for enemy in all (enemies) do
    
  if enemy.name=="clock" then
  if enemy.going=="down" and enemy.dy==-0 then
   enemy.going="up"
   enemy.dy=enemy.speed   
   clock_time=time()
  end
  
  if enemy.going=="right" and enemy.dx==0 then
   enemy.going="left"
   enemy.dx=enemy.speed
   clock_time=time()
  end
  
  if enemy.going=="left" and enemy.dx==0 then
   enemy.going="right"
   enemy.dx=enemy.speed
   clock_time=time()
  end
  
  if enemy.going=="up" and enemy.dy==0 then
   enemy.dy=enemy.speed
   enemy.going="down"
   clock_time=time()
  end
  
  if enemy.going=="down" then
   enemy.y+=enemy.dy
  elseif enemy.going=="up" then
   enemy.y-=enemy.dy
  elseif enemy.going=="left" then
   enemy.x-=enemy.dx 
  elseif enemy.going=="right" then
   enemy.x+=enemy.dx
  end
  
  if time()-clock_time>.5 then
   enemy.dy*=enemy.friction
   enemy.dx*=enemy.friction
   if enemy.dy<.3 then
    enemy.dy=0
   end
   if enemy.dx<.3 then
    enemy.dx=0
   end
  end
  
  
  end
  if enemy.name=="electronic" then
   if enemy.going=="left" then
    enemy.x-=enemy.speed
    if collide_map(enemy,"left_e",1) or collide_map(enemy,"left_e",3) then
     enemy.x+=enemy.speed
     enemy.going="right"
    end
    
   elseif enemy.going=="right" then
    enemy.x+=enemy.speed
    if collide_map(enemy,"right_e",1) or collide_map(enemy,"right_e",3)  then
     enemy.x-=enemy.speed
     enemy.going="left"
    end
   end
  end
 end
end
function create_enemies()
 enemies={}
 if level==2 then
  enemies={
   {name="electronic",x=188,y=184,going="left",
    speed=.7,h=1,w=1},
    {name="clock",x=312,y=208,dx=0,
    dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.65},
    {name="clock",x=312,y=200,dx=0,
    dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.65},
    {name="clock",x=312,y=192,dx=0,
    dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.65},
    {name="electronic",x=672,y=224,going="left",
    speed=.8,h=1,w=1},
    {name="electronic",x=584,y=232,going="left",
    speed=.8,h=1,w=1},
    {name="clock",x=56*tile,y=tile*29,dx=0,
    dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.65},
    {name="clock",x=56*tile,y=tile*24,dx=0,
    dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.65},
    {name="clock",x=96*tile,y=tile*28.4,dx=0,
    dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.75},
    {name="clock",x=99*tile,y=tile*24,dx=0,
    dy=0, acc=0.25, going="up", wings="out",friction=.99,speed=.75},
    {name="clock",x=101*tile,y=tile*28.4,dx=0,
    dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.75},
    {name="clock",x=103*tile,y=tile*24,dx=0,
    dy=0, acc=0.25, going="up", wings="out",friction=.99,speed=.75}
   --{name="electronic",x=696,y=104,going="left",
    --speed=.8,h=1,w=1} 
    }
  elseif level==3 then   
  enemies={
    {name="electronic",x=tile*24,y=tile*43,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*23,y=tile*39,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*21,y=tile*36,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*27,y=tile*37,going="left",
    speed=.4,h=1,w=1},
    {name="electronic",x=tile*27,y=tile*39,going="left",
    speed=.4,h=1,w=1},
    {name="electronic",x=tile*27,y=tile*41,going="left",
    speed=.4,h=1,w=1},
    {name="electronic",x=tile*36,y=tile*46,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*38,y=tile*46,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*40,y=tile*46,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*48,y=tile*46,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*50,y=tile*46,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*68,y=tile*44,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*82,y=tile*41,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*75,y=tile*41,going="left",
    speed=.7,h=1,w=1},
    {name="electronic",x=tile*84,y=tile*38,going="left",
    speed=1.2,h=1,w=1},
    {name="electronic",x=tile*94,y=tile*41,going="left",
    speed=.9,h=1,w=1},
    {name="clock",x=101*tile,y=tile*45,dx=0,
    dy=0, acc=0.25, going="down", wings="out",friction=.99,speed=.75},
    {name="clock",x=103*tile,y=tile*36,dx=0,
    dy=0, acc=0.25, going="up", wings="out",friction=.99,speed=.75}
    }
    elseif level==4 then
     enemies={
    {name="clock",x=42*tile,y=tile*62,dx=0,
    dy=0, acc=0, going="down", wings="out",friction=.99,speed=0},
    {name="clock",x=43*tile,y=tile*61,dx=0,
    dy=0, acc=0, going="down", wings="out",friction=.99,speed=0},
    {name="clock",x=44*tile,y=tile*60,dx=0,
    dy=0, acc=0, going="down", wings="out",friction=.99,speed=0},
    {name="clock",x=49*tile,y=tile*62,dx=0,
    dy=0, acc=0, going="down", wings="out",friction=.99,speed=0},
    {name="clock",x=48*tile,y=tile*61,dx=0,
    dy=0, acc=0, going="down", wings="out",friction=.99,speed=0},
    {name="clock",x=47*tile,y=tile*60,dx=0,
    dy=0, acc=0, going="down", wings="out",friction=.99,speed=0}
    }
   
  end
end
-->8
--player death

function player_dead()
 
  
  player.dx=0
  player.dy=0
   
  
 if time()-dead_time<=.2 then
  
  
  gravity=0
  player.acc=0
  player.max_dx=0
  player.max_dy=0
  spr(17,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=.4 then
  gravity=0
  player.acc=0
  player.max_dx=0
  player.max_dy=0
  spr(18,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=.6 then
  gravity=0
  player.acc=0
  player.max_dx=0
  player.max_dy=0
  spr(19,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=.8 then
  gravity=0
  player.acc=0
  player.max_dx=0
  player.max_dy=0
  spr(20,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=1 then
  gravity=0
  player.acc=0
  player.max_dx=0
  player.max_dy=0
  spr(21,player_useda_be_x,player_useda_be_y)
 elseif time()-dead_time<=1.2 then
  gravity=0
  
  player.acc=0
  player.max_dx=0
  player.max_dy=0
  spr(22,player_useda_be_x,player_useda_be_y)
 else
  gravity=0.2
  player.acc=.25
  player.max_dx=1
  player.max_dy=3.5
  player.x=checkpoint.x
  player.y=checkpoint.y 
  create_enemies()
  player.life+=2
  
 end
end
-->8
--sheep

function  sheep_add()
 player.pos={x=player.x+2,y=player.y}
 player.hitbox={x=0,y=0,w=4,h=8}
 
 for sheepies in all (sheep) do
  sheepies.pos={x=sheepies.x,y=sheepies.y}
  sheepies.hitbox={x=0,y=0,w=16,h=8}
 
  spr(93,sheepies.x,sheepies.y)
  spr(94,sheepies.x+8,sheepies.y)
  spr(78,sheepies.x-6,sheepies.y-2)
  spr(79,sheepies.x+2,sheepies.y-2)
  spr(67,sheepies.x-4,sheepies.y-8) 
  if collide(player,sheepies) then
   rectfill(cam_x-52,cam_y+16,cam_x+60,cam_y+48,1)
   rect(cam_x-52,cam_y+16,cam_x+60,cam_y+48,14)
   
   circfill(cam_x-52,cam_y+16,5,14)
   circfill(cam_x+60,cam_y+48,5,14)
   
  -- circfill(cam_x-52,cam_y+42,2,14)
   circfill(cam_x-52,cam_y+48,3,14)
  -- circfill(cam_x-46,cam_y+48,2,14)
  -- circfill(cam_x-42,cam_y+48,1,14)
  -- line(cam_x-46,cam_y+49,cam_x-48,cam_y+49,14)
  -- line(cam_x-45,cam_y+50,cam_x-48,cam_y+50,14)
  
   circfill(cam_x+60,cam_y+16,3,14)
  -- circfill(cam_x+57,cam_y+17,2,14)
  -- line(cam_x+54,cam_y+18,cam_x+57,cam_y+18,14)
  -- line(cam_x+53,cam_y+19,cam_x+56,cam_y+19,14)
  
   
   spr(29,cam_x-55,cam_y+13)
   spr(29,cam_x+57,cam_y+45)
   
   print(sheepies.message,cam_x-44,cam_y+24,14)
  end 
 
  
   
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000a0000000000000022111111111111111112112122111111111111220000a900
00000000000aaa00000aaa00000aaa000aaaaa00000aaa000aaaaa00000aaa000aaaaa0000000000222221222111111111111121eee222222212222200000a90
0070070000aaa90000aaa90000aaa900aaaaa90000aaa900aaaaa90000aaa90000aaa900000aaa0022111111111111111111112202221111111111220000aa90
0007700000aa9f0000aa9e000aaa9f00000a9f000aaa9f00000a9f000aaa9f00000a9f000aaaa90022122222221211111112112100eee222222221220000a990
0007700000adcc0000adcc000afdcc00000dcc000a0dcc9000fdcc900afdcc00000dcc90aaaa9f002211111111111111111211210002221111111122a0aaa990
0070070000afcc0000afcc00000ccc9000fccc9000fccc00000ccc0000dccc9000fcccc0000dcc902222212222111111111122210000eee2221222229aa99900
00000000000ccc00000ccc0000ccc000000cc00000dcc000000cc00000ccc0000000ccd0000cfcc0221111111111111111121121000002221111112209999000
00000000000c0d00000c0d000000d000000cd000000c0000000dc00000000000000000000000ccd0221222221111111111111121000000ee2222212200000000
0aa00aa0000000000000000000000000000000000000000007000070ee2e22e2121121112e22e2ee12112111111111112dcdcdcd000100001112112111111111
aa4444aa000777000007770000077700000777000007700000700700ee2e22e2121111112e22e2ee12111111221222222d2cdddc001110001111112111111112
a466669a007777000077770000777700007777000077000000000000eeee22ee22111111ee22eeee2211111111111111d2dddddd111111101111112211111111
04616790007777000077770000777700007770000070000077000077ee2e22e2121121112e22e2ee12112111222221224222dddd011111001112112111112122
9461779a007777000077770000777700007700000000000000000000ee2e22e2121121112e22e2ee12112111111111112222222d001110001112112111111111
04611790007777000077770000777000007000000000000000700700ee2eeee2122211112eeee2ee12221111ee2eeeee11111111010001001111222111111122
04777790000777000007770000070000000000000000000007000070ee2e22e222222221eeeeeeee121121112222222211111111000000001222222211111111
80999908000707000007000000000000000000000000000000000000ee2e22e222222111eeeeeee012111111eeeee2ee11111111000000001112222211111111
0a9000001111112206606600006606600066666666666600ee2e22e2111111112e22e2ee777777771111111122211111eeeeeeee111111112222222211111122
a9a900002212222267767760067767760666666666666660ee2e22e2221111112e22e2ee7777777721111111eee2212222222222221111111121111122222eee
90a900001111112267776776677677760666666666666660eeee22ee11111111ee22e2ee77777777111111112221111122222222111111112222222211112220
000a90002222212206777776677777760066666666666600ee2e22e2222111112e22e2ee7777777722121111eee22222121212122221111111111211222eee00
000a09001111112267677766667776760666666666666660ee2e22e2111111112e22e2ee77777777111111112221111111111111111111112222222211222000
0000a9002212222267777766667777760666666666666660ee2eeee2221221112eeee2ee7777777722111111eee221221111111122122111112111112eee0000
0000a0001111112206776666666677600066066006606600eeeeeeee221111112e22e2ee777777771111111122211111111111112211111122222eee22200000
0000a00022222122006666666666660000000000000000000eeeeeeee22222112e22e2ee7777777711111111eee22222111111112222221111111e22ee000000
0000a900009a000000000a00000009a01111111100a0000011111241cdcdcdcdcdddd221111112220000000011121121eeeeeee100000000111111111eeeeeee
000a0a9009a0a0000000a0a000009a9a111111110a0a000011112224dddcdddcddddd22122122eee00000000111111212222222e0000000011111122e2222222
00a090a99a090a000000a0a900009a09111111119a0a000011112222ddcdddcdddddd22111111222666666651111112112121211000000001111111112121212
0a09000aa00090a0000a000a0009a00011111111a000a00011111241ddddddddddddd22122222eee618148151112112111111111000000001111122211111112
0a090000000090a0000a00000090a000cccccccc0000a000cccdc241ddddddddd222222111111222618184151112112111111111000000001111111111111111
a00900000000900a009a0000009a0000cccccccc0000a900ccdcd241111111111111122122122eee655555551122222111111111000000001112212211111111
a09000000000090a00900000000a0000cdcdcdcd00000900cdcdc241111111111111121111111222000000001112112111111111000000001111112211111111
a09000000000090a00900000000a0000dcdcdcdc00000900dcdcd241111111111111111122222eee000000001111112211111111000000001122222e11111111
ee777eeeeeeeeeeeeeeeeeee0000000000eeeeeeeeeeee0055ee777e77777eeeeee77777022000222220022200000000eeeeeeeeeeeeeeee0000007770000000
f77777ffffefffffffe777ff0ddddd000eeeeeeeeeeeeee05ef77777777777ffff777777022000222220022200200002eefffefffffffeee0006677777660000
77777777eeeeeeeeee77777edcccccd0eeeeeeeeeeeeeeeeff7777777777777ee7777777002000022220022200000000eeeeeeeeeeeeeeee0067761716776000
77777777777ffe7777777777770dcccdeeefffffffefffeeee7777777777777ff7777777002000022220022202000020eeefffffffefffee0006667776660000
777777777777e77777777777760dcccdeeeeeeeeeeeeeeeeff7777777777777ee7777777020000202220022200200002eeeeeeeeeeeeeeee0000056165000000
77777777777777777777777700d7777deefffefffffffeeeeef77777777777ffff777777000000002220022200200002eefffefffffffeee0000005550000000
77777777777777777777777700ddddddeeeeeeeeeeeeeeeeffff777777777eeeeee77777002000022220022202200022eeeeeeeeeeeeeeee0000000000000000
77777777777777777777777700000000eeefffffffefffeeeee7777777779e9ff9e97777000000002220022202200022eeefffffffefffee0000000000000000
1222d2d2eeeeee00eeefffffffefffeeeee7777777777eee5557777777777777777e2211eeeee211000000001122e777eeeeeeee000777777777000722212111
122d2d2deeeeeee0eeeeeeeeeeeeeeeeff777777777777ff667777777777777777e22111ff7eee210000000011122e77fffffeff007777777777777722212111
1222d2d2e7777eeeeefffefffffffeee7777777777777777777777777777777777e22211e7eeeee20000000011222e77eeeeeeee077777777777776622211111
12244444777777eeeeeeeeeeeeeeeeee777777777777777777777777777777777eee2221777eee21000000001222eee7ffefffff077777777777776022211111
12222222777777eeeeefffffffefffee7777777777777777777777777777777777eee22277eee21100000000222eee77eeeeeeee077777767777766022111111
12211111777777eeeeeeeeeeeeeeeeee777777777777777777777777777777777ee22221777e21110000000012222ee7fffffeff077777676777760021111111
12111111777777ee0eeeeeeeeeeeeee077777777777777777777777777777777ee22221177eee21100000000112222eeeeeeeeee006776666677660011111111
1111111177777fee00eeeeeeeeeeee0077777777777777777777777777777777e22221117eee2111000000001112222effefffff004400000004400011111111
2222222225555533333333332222222222222222333333333333333312211111666666666666766666666666112eeeee11111111111111112221211111111111
8888888888666bbbbbbbbbbb8888882002888888bbbbbb3003bbbbbb2224111166666666666777666666666612eee7ff11111111111111112221211111111111
999999999886bbaaaaaaaaaa9999990000999999aaaaa900009aaaaa222211116666666677777777776666672eeeee7e11111111111111112221211121111111
99999999998bbaaaaaaaaaaa9999900000099999aaaa90000009aaaa1241111176666677777707777776667712eee77711111111111111112221211122111111
aaaaaaaaaabb899999999999aaa9000000009aaa999900000000999912416666776667777770007777777777112eee7711111111111111112221211122211111
aaaaaaaaabb6889999999999aa900000000009aa9990000000000999124666777777777700000000007777701112e77711111111111111112221211122211111
bbbbbbbbbb66688888888888b30000000000003b820000000000002812466777077777000000000000077700112eee7711111111111111112221211122212111
33333333355555222222222230000000000000032000000000000002124666660077700000000000000000001112eee711111111111111112221211122212111
333b3aa8555555555556566600000000000000000000000022200222ee200ee20e2000e2000000001111111122222222222e2eee111212221111111111121222
333b9a88555555555556566600000000000000000000000022200222ee200ee20e2000e2002000021111111122222222222e2eee111212221111111111121222
333a9886555555565556566600000000000000000000000022200222ee200ee20020000200000000111111112222222e222e2eee111212221111111211111222
339a28665555556655565666000000000000000000000000e2200e22ee200ee2002000020200002011111111222222ee222e2eee111212221111112211111222
3998266655555666555656660eeeeeeeeeeeee2222222220e2200e22ee200ee202000020002000026111cccc22222eee222e2eee111212221111122211111122
992856665555566655565666002222222222222222222200e2200e22ee200ee2000000000020000266cccccc22222eee222e2eee111212221111122211111112
922656665556566655565666000e2e2ee2ee222222222000ee200ee2ee200ee2002000020e2000e276cdcdcd222e2eee222e2eee111212221112122211111111
225656665556566655565666000222222222222222222000ee200ee2ee200ee2000000000e2000e266dcdcdc222e2eee222e2eee111212221112122211111111
c6c6c0828696a68696a686968696c4d4c5c5c5c5c5c5c5c5c5c5c5c5c5c5c4d48696a68696a6869686c4d48696a68696a68696a68696a68696a68696a696a686
96a68696a68696a696a68696a68696a68696a696a68696a68696a68696a696a68696a68696a68696a696a68696a68696a68696a696a68696a68696a671a1c6c6
d6d6c082d3d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d3000000000000d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d3d3d3d34454d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3c4d4060606060606060606c4d4d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d3d3d307c4d4d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3a5d3d3d3d3d3d3d3d3d3d3a5d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3c4d4a5d3d3d3d3d3d3d327c4d4d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d346060606060606060636d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3c4d4a54606060606060606c4d4d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d327d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6e191d3d3d3d34454d3d3d3d3c4d4d3d3d3d3d3d3d3d307c4d4d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3d3d3d3d3d3a5d3d3d3d3d3d3d3d3d327d3a5d3d3d3d3d3a5d3d3d3d3d3d3d3d3d3a5d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6f112d3d3d3d3c4d4d3d3d3d3c4d4d3d3d3d3d3d3d3d327c4d4d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d34606060606060606060636d3d3d3d3d3d3d3460606060606060636d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6f112d3d34606c4d4d3d3d3d32535a5d3d3d3d3d3d3d327c4d4d3d3d3c4d4d3d3d3d3d3d3d3d3d3c4d4d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d317d3d327d3d3d3d3d3d3d3d3d3d3d3d307d3d3d3d3d3d3d3d3d3d307d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d36281d6d6
d6d6f112d3d3d307c4d4d3d3d3d3d3d3a54606060606060606c4d4d3d3d32535d3d3d3d3d3d3d3d3d32535d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3a5d3d3d3d3d3d3a5d3d3d3d3d327d3d327d3d3d3d3d3d3d3d3d3d3d3d327d3d3d3d3d3d3d3d3d3d327d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3a0b0d6d6
d6d6f112d3d3d327c4d4d3d3d3d3d3a5d3d3d3d3d3d3d3d307c4d4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d30000000000000000d3d3d3d3d3d3d3
d3d3460606060636d3d3d3d3d3d327d3d327d3d3d3d3d3d3d3d3d3d3d3d327d3d3d3d3d3d3d3d3d3d327d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3a0b0d6d6
c6c6b6042404142404142404142415d3d3d3d3d3d3d3d3d3278404240414240414240415d300d3d3d3d3d3d3d3d3d3d3d300000000004454d30000d3d3d3d3d3
d3d3d3d30707d3d3d3d3d3d3d3d327d3d327d3d3d3d3d3d3d3d3d3d3d3d327d3d3d3d3d3d3d3d3d3d327d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3a0b0d6d6
c6c6b575757575757575757575755504142404142404142404757575757575757575757524142404142404142404142404142404142404142404142404142415
d3d3d3d32727d3d3d3d3d3d3d3d327d3d327d3d3d3d3d3d3d3d3d3d3d3d327d3d3d3d3d3d3d3d3d3d36414240414041414240414240414240414240495c6c6c6
c6c6c082d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1c6c6
d6d6c082d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6c082d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6e191d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6f112d3d3d3d34454d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d371a1d6d6
d6d6f112d3d34606c4d4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d36281d6d6
d6d6f112d3d3d307c4d4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3a0b0d6d6
d6d6f112d3d3d327c4d4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d346060636d3d3d3d3d3d3d3460636d3d3d3d3d34606d306d306d306d306d306d336d3d3d3d3d3d3d3d3d3d3d3a0b0d6d6
d6d6f112d3d3d3278404142404142404142415d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3
d3d3d3d3460606060636d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3a0b0d6d6
c6c6b604142404144575757575757575757574d3d3d3d3d3d3d3d3d3d3460606060606060606060636d3d3d3d3d3d3d3d3d3d346060606060606060636d3d3d3
d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d36404142404142495c6c6c6
__gff__
0000000000000000000000000000000004000000000000030003000000000000000000000000030003000000000000000000000000000000000004000000000003030300030303030300000003030000000303030303030303030803030000000101010101010100000000030300000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000040000000000000000000000000000030000000000000000000000000000000300000000080000000000000000000000
__map__
68696a68696a68696a68696a68696a3d0c2869686a68696a68696a68696a68696a68696a68696a68696a68696a686968696a68696a68696a68696a68696a696a686968686a696a68696a68696a68696a68696a68696a68696a68696a68696a68696a68696a68696a68696a68696a68696a68696a68696a68696a6869171a6c6c
7e6d6d6d6d6d3e1b1b276d6d6d6d6d6f0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d000000003d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
7d7e6d6d6d3e2f3d3d0d276d6d6d6f6e0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d646060606060633d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
7d7d6d6d1f393d3d3d3d2b2a6d6d6e6e0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d723d3d3d3d44453d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
7d7d6d6d1f393d3d3d3d2b2a6d6d6e6e0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d723d3d3d3d4c4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
7d7d6d6d1f393d3d3d3d2b2a6d6d6e6e0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d6460606060606060633d3d3d3d3d723d3d3d3d4c4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
7d7d6d6d1f393d3d3d3d2b2a6d6d6e6e0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d703d3d3d3d3d3d3d3d3d723d3d3d3d4c4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
7d7d6d6d1f393d3d3d3d2b2a6d6d6e6e0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d723d3d3d3d3d3d3d3d3d723d3d3d3d4c4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
7d7d6d6d1f393d3d3d3d2b2a6d6d6e6e0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d723d3d3d6460606060606060633d3d4c4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d646060606060633d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
7d7d6d6d6d3f2c2c2c2c3c6d6d6d6e6e1e193d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d44453d3d3d3d3d3d3d3d3d723d3d3d3d3d3d3d703d723d3d3d3d4c4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d000072003d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
7d7d6d6d6d6d6d6d6d6d6d6d6d6d6e6e1f213d3d3d3d3d3d3d3d3d3d3d3d3d44453d3d3d3d3d3d3d00004c4d3d3d3d3d3d3d3d3d3d723d3d3d3d3d3d3d723d723d3d3d004c4d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d0000000072003d3d3d3d3d6460606060633d3d3d3d3d3d3d3d3d3d3d3d26186d6d
7d7d6d6d6d6d6d6d6d6d6d6d6d6d6e6e1f213d3d3d3d3d3d3d3d3d3d3d3d3d4c4d3d3d3d3d3d646060634c4d3d3d3d3d3d3d3d3d3d723d64606060633d723d723d3d3d004c4d3d3d3d3d3d3d3d3d3d3d646060606060633d3d3d3d3d6460606060606060633d3d3d3d3d3d0070703d3d3d3d3d3d3d3d3d3d3d3d3d3d0a0b6d6d
7d7f6d6d6d6d677a34366d6d6d6d5f6e1f213d3d3d3d3d3d3d3d3d3d3d445c5c4d3d3d3d3d3d3d3d70004c4d3d3d3d3d3d3d3d3d3d723d3d3d70000000723d723d3d3d004c4d3d3d3d3d3d3d003d3d3d3d3d3d70003d3d3d3d3d3d3d3d3d3d0072000072003d3d3d3d3d3d3d72723d3d3d3d3d3d3d3d3d3d3d3d3d3d0a0b6d6d
7f6d6d6d6d6d501c37386d6d6d6d6d5f1f213d3d3d3d3d3d3d3d3d3d3d4c5c5c4d3d3d3d3d3d3d3d72004c4d3d3d3d3d3d3d3d3d3d723d3d3d723d3d3d723d723d3d3d004c4d3d3d3d3d3d44453d3d3d3d3d3d720044453d3d3d3d3d3d3d3d5a72003d723d3d3d3d3d3d3d3d72723d3d3d3d3d3d3d3d3d3d3d3d3d3d0a0b6d6d
4042404140424041404254575755406c6b4241424140424142424041424040404041424140404241404240404140424041424240414240404142414042404042404142404240404140424241404242414041424140404040404240404140515a723d3d723d3d3d3d3d3d3d3d72723d3d3d444241404241404241424059424141
5757575757575757575757575757576c5b5757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757473d723d3d723d3d3d3d3d3d3d3d72723d3d3d485757575757575757575758575757
6c6c0c28696a68696a696a68696a696a68696a696a68696a696a68696a6868696a68696a68696a686968696a68696a68696a6868696a68696a68696a68696a68696a68696a686968696a68696a68696a68696a68696a68696a68696a68696a68696a68696a686968696a68696a68696a6868696a68696a68696a6868171a6c6c
6d6d0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
6d6d0c283d3d3d3d3d3d3d3d3d3d5a3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
6d6d0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
6d6d0c283d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
6d6d0c283d3d3d3d3d3d3d3d3d3d5a3d5a3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
6d6d0c283d3d3d3d3d3d3d3d3d5a5a3d5a3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
6d6d0c283d3d3d3d3d3d3d3d3d5a44455a3d3d3d5a3d3d3d3d3d3d3d5a3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
6d6d0c283d3d3d3d3d3d3d3d3d3d4c4d3d3d3d3d3d646060606060633d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d171a6d6d
6d6d1e193d3d5a3d3d3d3d3d3d3d4c4d3d3d3d3d3d3d3d3d723d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d44453d3d3d3d3d3d3d3d171a6d6d
6d6d1f213d3d5a646060606060604c4d3d3d3d3d3d3d3d3d723d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d4c4d3d3d3d3d3d3d3d3d26186d6d
6d6d1f213d3d3d3d3d3d703d3d704c4d3d3d646060606063723d3d3d3d3d646060606060633d3d3d3d3d64606060633d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d64606060606060606060606060633d646060606060633d3d4c4d3d3d3d3d3d3d3d3d0a0b6d6d
6d6d1f213d3d3d3d3d3d723d3d724c4d3d3d3d3d703d3d3d723d3d3d3d3d3d3d3d703d3d3d3d3d3d3d3d3d3d703d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d5a003d3d3d3d3d3d3d5a00003d3d3d3d3d3d3d70703d3d3d3d3d3d3d3d3d3d703d3d3d3d3d4c4d3d3d3d3d3d3d3d3d0a0b6d6d
6d6d1f213d3d3d3d3d3d723d3d724c4d3d3d3d3d723d3d3d723d3d3d3d3d3d3d3d723d3d3d3d3d3d3d3d3d3d723d3d3d3d6460606060633d3d3d3d3d3d3d3d3d3d3d3d44453d3d3d3d3d3d3d5a3d64606060606060633d00003d3d3d3d3d3d3d72723d3d3d3d3d3d3d3d3d3d723d3d3d3d3d4c4d3d3d3d3d3d3d3d3d0a0b6d6d
6c6c6b40414240414240414240414140513d3d3d723d3d3d723d3d3d3d3d3d3d3d723d3d3d3d3d3d3d3d3d3d723d3d3d3d3d3d3d3d3d3d3d3d3d4641404140414240414240414240414242513d3d3d3d3d3d703d3d3d3d00003d3d3d3d3d3d3d72723d3d3d3d3d3d3d3d3d3d723d3d3d3d3d48474041424041424041596c6c6c
6c6c5b57575757575757575757575757473d3d3d723d3d3d723d3d3d3d3d3d3d3d723d3d3d3d3d3d3d3d3d3d723d3d3d3d3d3d3d3d3d3d3d3d3d4857575757575757575757575757575757473d3d3d3d3d3d723d3d3d3d00003d3d3d3d3d3d3d72723d3d3d3d3d3d3d3d3d3d723d3d3d3d3d48575757575757575757586c6c6c
__sfx__
000200002101024010290102c0102f0102f0103d000110003d0003c0003b0003a0003a0003b000390003800014000140000000000000000000000000000000000000000000000000000000000000000000000000
0002000015750147500e7500e75000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0105000006710067100070000700127101271000700007002871028710267003a7003b7103b71038700007002871028710007003f7003b7103b71001700007000671006710017000170012710127100270008700
000a00001450014573145001457314500145731450014573145001457314500145731450014573145001457314573145731457314573145731457314573145731457314573145731457314573145731457314573
0110000027751277011e7511f701167511f7010f75115701097510a7010a701007010470104701007010070104701047010070100701007010070100701007010070100701007010070100701007010070100701
010600001915519155181551815500105191050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
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
02 02 42 03 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
