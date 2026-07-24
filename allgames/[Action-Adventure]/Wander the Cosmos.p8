pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--wander the cosmos
--by niall chandler

--hello :)

--dev start date: 10 jan 2021

--ABCDEFGHIJKLMNOPQRSTUVWXYZ

 --palette swap in menu
--poke(0x5f2e,1)
 --my colour palette
pal({7,6,135,12,140,1,131,3,139,11,13,137,8,136,2,0},1)
 --normal palette
--pal({1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0},1)
 --alternative palette
--pal({129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,128},1)
 --gameboy palette by @rAINDEIR1
--pal({131,139,138,129,131,138,138,129,131,139,138,139,139,139,138,129},1)
 --by @trasevol_dog for explorers
--pal({1,140,12,132,4,142,15,131,3,11,138,135,9,8,130,0},1)

 --player 1
  player={
    sp=1,
   --note: 508 is center of map
    x=60,
   --note: 252 is center of map
    y=60,
    dx=0,
    dy=0,
    w=8,
    h=8,
    anim=0,
    speed=0.5,
    scanned=0,
    scanned1=0,
    scanned2=0,
    scanned3=0,
    scanned4=0,
    scanned5=0,
    scanned6=0,
    scanned7=0,
    scanned8=0,
  }
  
 --player 2
  player2={
    sp=17,
   --note: 508 is center of map
    x=player.x,
   --note: 252 is center of map
    y=player.y+9,
    dx=0,
    dy=0,
    w=8,
    h=8,
    anim=0,
    speed=0.5,
  }
  
 --planet 1 
  target={
   x=184,
   y=16,
  }
  --planet 2
  target1={
   x=360,
   y=200,
  }
  --planet 3
  target2={
   x=392,
   y=400,
  }
  --planet 4
  target3={
   x=848,
   y=72,
  }
  --planet 5
  target4={
   x=576,
   y=24,
  }
  --planet 6
  target5={
   x=880,
   y=408,
  }
  --planet 7
  target6={
   x=136,
   y=352,
  }
  --planet 8
  target7={
   x=552,
   y=296,
  }
  
 --planet 9
  target8={
   x=720,
   y=248,
  }
  
 --star
  target9={
   x=504,
   y=248,
  }
  
  title=1
  collision = false
  collision1 = false
  collision2 = false
  collision3 = false
  collision4 = false
  collision5 = false
  collision6 = false
  collision7 = false
  collision8 = false
  collision9 = false
  
  ticks=0
  scant=0
  p2cam=0
  
  --time
  milliseconds=0
  seconds=0
  minutes=0
  hours=0
  
--ABCDEFGHIJKLMNOPQRSTUVWXYZ
  
 --multiplayer toggle
  menuitem(2,"pLAY mULTIPLAYER",
  function()
  multip=not multip
    if multip then
      multi=1
    else
      multi=0
    end
  end)
  
 --display hud
  menuitem(1,"tOGGLE hud",
  function()
  speedrun=not speedrun
    if speedrun then
      sprun=1
    else
      sprun=0
    end
  end)
  
--ABCDEFGHIJKLMNOPQRSTUVWXYZ
  
 --minigames
  menuitem(3,"pLAY mINIGAME",function() init_mini() music(16) end)

  
  
  --timer
function updateplaytime()
 milliseconds+=1
 
 if milliseconds==60 then
  seconds+=1
  milliseconds=0
  if seconds==60 then
   minutes+=1
   seconds=0
   if minutes==60 then
    hours+=1
    minutes=0
    if hours==10 then
    hours=0
    end
   end
  end
 end
end
  
 --print outlined text
--instead of print type printo--
function printo(str, x, y, c0, c1)
for xx = -1, 1 do
 for yy = -1, 1 do
 print(str, x+xx, y+yy, c1)
 end
end
print(str,x,y,c0)
end

function offset_stuff()
	ox={[0]=-1,1,0,0}
	oy={[0]=0,0,-1,1}
	sfh={[0]=true,false,false,false}
	sfv={[0]=false,false,true,false}
end

--debug
 x1r=0 y1r=0 x2r=0 y2r=0

function _init()
cartdata("wander_the_cosmos_niall_chandler_v1")
  init_game()
end

-->8
--update and draw
function init_game()

  music(0)
  offset_stuff()
  make_stars()

--ABCDEFGHIJKLMNOPQRSTUVWXYZ
--‹‘”ƒ—Ž
--pUSH Ž TO CONTINUE

 --to autoplay add ,true
  dialog:queue("tHE YEAR IS 50xx. yOU ARE THE PILOT OF A UNIQUE SPACECRAFT KNOWN ONLY AS: the discovery                                           pUSH Ž TO CONTINUE")
  dialog:queue("yOU HAVE BEEN SENT ON A SPACE OBSERVATION MISSION BY THE GALACTIC FEDERATION.                                                   pUSH Ž TO CONTINUE")
  dialog:queue("yOUR MISSION IS TO WANDER THE COSMOS, GATHERING DATA ON ALL CELESTIAL OBJECTS YOU COME ACROSS.                                  pUSH Ž TO CONTINUE")
  dialog:queue("iF YOU COME ACROSS ANY SUCH OBJECTS, YOU ARE TO SCAN THEM IN ORDER TO GATHER AS MUCH DATA ON THEM AS YOU CAN.                 pUSH Ž TO CONTINUE")
  dialog:queue("tHIS DATA WILL AUTOMATICALLY BE SAVED AND SENT TO GALACTIC FEDERATION H.Q. FOR ANALYSIS.                                          pUSH Ž TO CONTINUE")
  dialog:queue("tHE discovery's SCANNERS HAVE DETECTED 9 NEARBY CELESTIAL OBJECTS THAT HAVE YET TO BE SCANNED.                                 pUSH Ž TO CONTINUE")
  dialog:queue("oNCE THESE OBJECTS ARE SCANNED, YOU ARE TO RETURN TO GALACTIC FEDERATION H.Q.                                               pUSH Ž TO CONTINUE")
  dialog:queue("gOOD LUCK OUT THERE, PILOT.                                                                                                        pUSH Ž TO CONTINUE")
  dialog:queue("           controls:          mOVE:  p1:‹‘”ƒ  p2:s f e d  sCAN:  p1:—     p2:cAN'T SCAN pAUSE: p/eNTER                           pUSH Ž TO CONTINUE")
  dialog:queue("                          ’’’commencing mission’’’                                  !push Ž to wander the cosmos!")

function _update60()
  player_update()
 --multiplayer
 if multi==1 then
  player2_update()
 end
  updateplaytime()
  
  ticks+=3
  
  if ticks>60 then
   ticks=0
  end
  
  if player.scanned>1 then
   player.scanned=1
  end
  if player.scanned1>1 then
   player.scanned1=1
  end
  if player.scanned2>1 then
   player.scanned2=1
  end
  if player.scanned3>1 then
   player.scanned3=1
  end
  if player.scanned4>1 then
   player.scanned4=1
  end
  if player.scanned5>1 then
   player.scanned5=1
  end
  if player.scanned6>1 then
   player.scanned6=1
  end
  if player.scanned7>1 then
   player.scanned7=1
  end
  if player.scanned8>1 then
   player.scanned8=1
  end
  
  
 --camera
  sx,sy=flr(player.x-60),flr(player.y-60)
  foreach(s,move_star)
  
    dialog:update()

 --when dialog runs out
  if (#dialog.dialog_queue == 0) then
   title=0
  end
  
end

function _draw()
 cls()
 camera(sx,sy)
 draw_map()
 foreach(s,draw_star)
 draw_fx()
 
 if title==1 then
  rectfill(player.x-59,player.y+34,player.x+66,player.y+66,5)
  rect(player.x-60,player.y+33,player.x+67,player.y+67,6)
  --logo part 1
  spr(34,28,22)
  spr(35,36,22)
  spr(36,44,22)
  spr(48,52,22)
  spr(9,60,22)
  spr(10,68,22)
  spr(11,76,22)
  spr(12,84,22)
  spr(13,92,22)
  --logo part 2
  spr(49,28,30)
  spr(50,36,30)
  spr(51,44,30)
  spr(52,52,30)
  spr(25,60,30)
  spr(26,68,30)
  spr(27,76,30)
  spr(28,84,30)
  spr(29,92,30)
  --logo part 3
  spr(37,28,38)
  spr(38,36,38)
  spr(39,44,38)
  spr(40,52,38)
  spr(41,60,38)
  spr(42,68,38)
  spr(43,76,38)
  spr(44,84,38)
  spr(45,92,38)
  --logo part 4
  spr(53,28,46)
  spr(54,36,46)
  spr(55,44,46)
  spr(56,52,46)
  spr(57,60,46)
  spr(58,68,46)
  spr(59,76,46)
  spr(60,84,46)
  spr(61,92,46)
  --copyright
  spr(16,1,0)
  printo("2021",11,1,1,0)
  printo("nIALL",28,1,1,0)
  printo("cHANDLER",49,1,1,0)
  --pico 8 logo
  --ABCDEFGHIJKLMNOPQRSTUVWXYZ
  printo("MADE",96,1,1,0)
  printo("WITH",113,1,1,0)
  spr(14,97,7)
  spr(15,103,7)
  spr(30,108,7)
  spr(31,113,7)
  spr(46,119,7)
  spr(47,122,7)
 end
 
 dialog:draw()
 
 if ticks>=30 then
  circfill(512,256,14,13)
  circfill(512,256,12,12)
  circfill(512,256,10,3)
  circfill(512,256,8,1)
 elseif ticks<=30 then
  circfill(512,256,16,13)
  circfill(512,256,14,12)
  circfill(512,256,12,3)
  circfill(512,256,10,1)
 end
 
 spr(player.sp,player.x,player.y,1,1)
--multiplayer
if multi==1 then
 spr(player2.sp,player2.x,player2.y,1,1)
end
  
 if title==0 then
  if sprun!=1 then
  rectfill(player.x-60,player.y-52,player.x+68,player.y-60,5)
  rect(player.x-60,player.y-51,player.x+68,player.y-51,6)
  printo(""..stat(93)..":"..stat(94)..":"..stat(95),player.x-58,player.y-58,1,0)
   printo("“"..hours.."h "..minutes.."m "..seconds.."s ",player.x-24,player.y-58,1,0)
  printo(""..stat(92).."/"..stat(91).."/"..stat(90),player.x+27,player.y-58,1,0)
  rectfill(player.x-60,player.y+59,player.x+68,player.y+68,5)
  rect(player.x-60,player.y+58,player.x+68,player.y+58,6)
  printo("‹‘”ƒmOVE|—sCAN|sCANNED:"..(player.scanned+player.scanned1+player.scanned2+player.scanned3+player.scanned4+player.scanned5+player.scanned6+player.scanned7+player.scanned8).."/9",player.x-58,player.y+61,1,0)
  end
   if (player.scanned+player.scanned1+player.scanned2+player.scanned3+player.scanned4+player.scanned5+player.scanned6+player.scanned7+player.scanned8)==9 then
    printo("Ž rETURN TO g.f.h.q.",player.x-37,player.y+51,3,15)
   end
 end
 
 --ABCDEFGHIJKLMNOPQRSTUVWXYZ
 
 if collision==true then
  if ticks>=30 then
  printo("—",player.x+1,player.y-6,1,0)
  elseif ticks<=30 then
  printo("—",player.x,player.y-6,1,0)
  end
 elseif collision1==true then
  if ticks>=30 then
  printo("—",player.x+1,player.y-6,1,0)
  elseif ticks<=30 then
  printo("—",player.x,player.y-6,1,0)
  end
 elseif collision2==true then
  if ticks>=30 then
  printo("—",player.x+1,player.y-6,1,0)
  elseif ticks<=30 then
  printo("—",player.x,player.y-6,1,0)
  end
 elseif collision3==true then
  if ticks>=30 then
  printo("—",player.x+1,player.y-6,1,0)
  elseif ticks<=30 then
  printo("—",player.x,player.y-6,1,0)
  end
 elseif collision4==true then
  if ticks>=30 then
  printo("—",player.x+1,player.y-6,1,0)
  elseif ticks<=30 then
  printo("—",player.x,player.y-6,1,0)
  end
 elseif collision5==true then
  if ticks>=30 then
  printo("—",player.x+1,player.y-6,1,0)
  elseif ticks<=30 then
  printo("—",player.x,player.y-6,1,0)
  end
 elseif collision6==true then
  if ticks>=30 then
  printo("—",player.x+1,player.y-6,1,0)
  elseif ticks<=30 then
  printo("—",player.x,player.y-6,1,0)
  end
 elseif collision7==true then
  if ticks>=30 then
  printo("—",player.x+1,player.y-6,1,0)
  elseif ticks<=30 then
  printo("—",player.x,player.y-6,1,0)
  end
 elseif collision8==true then
  if ticks>=30 then
  printo("—",player.x+1,player.y-6,1,0)
  elseif ticks<=30 then
  printo("—",player.x,player.y-6,1,0)
  end
 elseif collision9==true then
  if ticks>=30 then
  printo("cAN'T SCAN STAR",player.x-25,player.y-6,1,0)
  elseif ticks<=30 then
  printo("cAN'T SCAN STAR",player.x-26,player.y-6,1,0)
  end
 end
 
 --ABCDEFGHIJKLMNOPQRSTUVWXYZ
 
 if scant>0 and collision==true then
  printo("sCANNING..."..(scant/1.8).."/100%",player.x-43,player.y-12,1,0)
 elseif scant>0 and collision1==true then
  printo("sCANNING..."..(scant/1.8).."/100%",player.x-43,player.y-12,1,0)
 elseif scant>0 and collision2==true then
  printo("sCANNING..."..(scant/1.8).."/100%",player.x-43,player.y-12,1,0)
 elseif scant>0 and collision3==true then
  printo("sCANNING..."..(scant/1.8).."/100%",player.x-43,player.y-12,1,0)
 elseif scant>0 and collision4==true then
  printo("sCANNING..."..(scant/1.8).."/100%",player.x-43,player.y-12,1,0)
 elseif scant>0 and collision5==true then
  printo("sCANNING..."..(scant/1.8).."/100%",player.x-43,player.y-12,1,0)
 elseif scant>0 and collision6==true then
  printo("sCANNING..."..(scant/1.8).."/100%",player.x-43,player.y-12,1,0)
 elseif scant>0 and collision7==true then
  printo("sCANNING..."..(scant/1.8).."/100%",player.x-43,player.y-12,1,0)
 elseif scant>0 and collision8==true then
  printo("sCANNING..."..(scant/1.8).."/100%",player.x-43,player.y-12,1,0)
 end
 
--ABCDEFGHIJKLMNOPQRSTUVWXYZ
--debug---------------------------
 --printo(collision,camera(sx+0),10,1)
 --printo(collision1,camera(sx+0),16,1)
 --printo(collision2,camera(sx+0),22,1)
 --printo(collision3,camera(sx+0),28,1)
 --printo(collision4,camera(sx+0),34,1)
 --printo(collision5,camera(sx+0),40,1)
 --printo(collision6,camera(sx+0),46,1)
 --printo(collision7,camera(sx+0),52,1)
 --printo(collision8,camera(sx+0),58,1)
 --printo(collision9,camera(sx+0),64,1)
  --
 --printo("x:".. player.x,camera(sx+0),16,1)
 --printo("y:".. player.y,camera(sx+0),22,1)
 --printo("tx:".. ((player.x - (player.x % 8)) / 8),camera(sx+0),28,1)
 --printo("ty:".. ((player.y - (player.y % 8)) / 8),camera(sx+0),34,1)
 --printo("cpu:"..flr(stat(1)*100).."%",camera(sx+0),40,1)
 --printo("fps:"..flr(stat(8)),camera(sx+0),46,1)
 --printo("mem:"..flr(stat(0)),camera(sx+0),52,1)
 --printo("title:"..title,camera(sx+0),58,1)
 --printo("ticks:"..ticks,camera(sx+0),64,1)
 --printo("scanned:"..player.scanned,camera(sx+0),70,1)
 --printo("scant:"..scant,camera(sx+0),76,1)
 --printo("f="..milliseconds,camera(sx+0),82,1)
 --printo("s="..seconds,camera(sx+0),88,1)
 --printo("m="..minutes,camera(sx+0),94,1)
 --printo("h="..hours,camera(sx+0),100,1)
 --printo("p2cam="..p2cam,camera(sx+0),106,1)
 --printo("finishes="..finishes,camera(sx+0),112,1)
 --printo("sprun="..sprun,camera(sx+0),118,1)
 ---------------------------------
end
end

function draw_map()
 map(0,0,0,0,128,64)
    if (player.x>944) map(0,0,1024,0,10,64)
    if (player.x<80) map(118,0,-80,0,10,64)
    if (player.y<80) map(0,54,0,-80,128,10)
    if (player.y>432) map(0,0,0,512,128,10)
    if (player.x<80 and player.y<80) map(118,54,-80,-80,10,10)
    if (player.x<80 and player.y>432) map(118,0,-80,512,10,10)
    if (player.x>944 and player.y<80) map(0,54,1024,-80,10,10)
    if (player.x>944 and player.y>432) map(0,0,1024,512,10,10)
end
-->8
--collisions

function checkcollision()
	if player.x+7<target.x or 
				player.x>target.x+15 or
				player.y+7<target.y	or
				player.y>target.y+15 then
					collision = false
				elseif player.scanned==1 then
				 collision = false
				else
					collision = true
				end
end

function checkcollision1()
	if player.x+7<target1.x or 
				player.x>target1.x+15 or
				player.y+7<target1.y	or
				player.y>target1.y+15 then
					collision1 = false
				elseif player.scanned1==1 then
				 collision1 = false
				else
					collision1 = true
				end
end

function checkcollision2()
	if player.x+7<target2.x or 
				player.x>target2.x+15 or
				player.y+7<target2.y	or
				player.y>target2.y+15 then
					collision2 = false
				elseif player.scanned2==1 then
				 collision2 = false
				else
					collision2 = true
				end
end

function checkcollision3()
	if player.x+7<target3.x or 
				player.x>target3.x+15 or
				player.y+7<target3.y	or
				player.y>target3.y+15 then
					collision3 = false
				elseif player.scanned3==1 then
				 collision3 = false
				else
					collision3 = true
				end
end

function checkcollision4()
	if player.x+7<target4.x or 
				player.x>target4.x+15 or
				player.y+7<target4.y	or
				player.y>target4.y+15 then
					collision4 = false
				elseif player.scanned4==1 then
				 collision4 = false
				else
					collision4 = true
				end
end

function checkcollision5()
	if player.x+7<target5.x or 
				player.x>target5.x+15 or
				player.y+7<target5.y	or
				player.y>target5.y+15 then
					collision5 = false
				elseif player.scanned5==1 then
				 collision5 = false
				else
					collision5 = true
				end
end

function checkcollision6()
	if player.x+7<target6.x or 
				player.x>target6.x+15 or
				player.y+7<target6.y	or
				player.y>target6.y+15 then
					collision6 = false
				elseif player.scanned6==1 then
				 collision6 = false
				else
					collision6 = true
				end
end

function checkcollision7()
	if player.x+7<target7.x or 
				player.x>target7.x+15 or
				player.y+7<target7.y	or
				player.y>target7.y+15 then
					collision7 = false
				elseif player.scanned7==1 then
				 collision7 = false
				else
					collision7 = true
				end
end

function checkcollision8()
	if player.x+7<target8.x or 
				player.x>target8.x+15 or
				player.y+7<target8.y	or
				player.y>target8.y+15 then
					collision8 = false
				elseif player.scanned8==1 then
				 collision8 = false
				else
					collision8 = true
				end
end

function checkcollision9()
	if player.x+7<target9.x or 
				player.x>target9.x+15 or
				player.y+7<target9.y	or
				player.y>target9.y+15 then
					collision9 = false
				else
					collision9 = true
				end
end
-->8
--player

function player_update()
 
 --adds the fx update to player
 update_fx()
 
 --controls
if title==0 then
	 if btn(‹) then
		player.x-=player.speed
	end
		if btn(‘) then
		player.x+=player.speed
	end
		if btn(”) then
		player.y-=player.speed
	end
		if btn(ƒ) then
		player.y+=player.speed
	end
 
   --player loops at edge of map
   --code by mboffin
    player.x=(1024+player.x)%1024
    player.y=(512+player.y)%512
 
 --add trail to player
  if btn(‹) or btn(‘) or btn(”) or btn(ƒ) then
      trail(player.x,player.y,trail_width,trail_colors,trail_amount)
      sfx(trail_sfx)
  end
  
 checkcollision()
 checkcollision1()
 checkcollision2()
 checkcollision3()
 checkcollision4()
 checkcollision5()
 checkcollision6()
 checkcollision7()
 checkcollision8()
 checkcollision9()
 
 --scanning
  if collision==true then
   if btn(—) then
    scant+=1
    sfx(4)
    if scant==180 then
     player.scanned+=1
     scant=0
     sfx(1)
    end
   end
  end
  
  if collision1==true then
   if btn(—) then
    scant+=1
    sfx(4)
    if scant==180 then
     player.scanned1+=1
     scant=0
     sfx(1)
    end
   end
  end
  
  if collision2==true then
   if btn(—) then
    scant+=1
    sfx(4)
    if scant==180 then
     player.scanned2+=1
     scant=0
     sfx(1)
    end
   end
  end
  
  if collision3==true then
   if btn(—) then
    scant+=1
    sfx(4)
    if scant==180 then
     player.scanned3+=1
     scant=0
     sfx(1)
    end
   end
  end
  
  if collision4==true then
   if btn(—) then
    scant+=1
    sfx(4)
    if scant==180 then
     player.scanned4+=1
     scant=0
     sfx(1)
    end
   end
  end
  
  if collision5==true then
   if btn(—) then
    scant+=1
    sfx(4)
    if scant==180 then
     player.scanned5+=1
     scant=0
     sfx(1)
    end
   end
  end
  
  if collision6==true then
   if btn(—) then
    scant+=1
    sfx(4)
    if scant==180 then
     player.scanned6+=1
     scant=0
     sfx(1)
    end
   end
  end
  
  if collision7==true then
   if btn(—) then
    scant+=1
    sfx(4)
    if scant==180 then
     player.scanned7+=1
     scant=0
     sfx(1)
    end
   end
  end
  
  if collision8==true then
   if btn(—) then
    scant+=1
    sfx(4)
    if scant==180 then
     player.scanned8+=1
     scant=0
     sfx(1)
    end
   end
  end
  
 --number of scanned to win
  if (player.scanned+player.scanned1+player.scanned2+player.scanned3+player.scanned4+player.scanned5+player.scanned6+player.scanned7+player.scanned8)==9 then
   if btn(Ž) then
    init_win()
   end
  end
  
end
 
 --player animation
 if time()-player.anim>.15 then
  player.anim=time()
  player.sp+=1
   if player.sp>8 then
    player.sp=1
   end
 end

end

--player 2

function player2_update()

 --adds the fx update to player
 update_fx()
 
 --limit player 2 to camera
 if player2.x>=player.x+60 then
  p2cam=1
 elseif player2.x<=player.x-60 then
  p2cam=1
 elseif player2.y>=player.y+51 then
  p2cam=1
 elseif player2.y<=player.y-50 then
  p2cam=1
 else
  p2cam=0
 end
 
 if p2cam==1 then
  player2.x=player.x
  player2.y=player.y
 end
 
--player 2 movement
if title==0 then
	 if btn(‹,1) then
		player2.x-=player2.speed
	end
		if btn(‘,1) then
		player2.x+=player2.speed
	end
		if btn(”,1) then
		player2.y-=player2.speed
	end
		if btn(ƒ,1) then
		player2.y+=player2.speed
	end
 
   --player loops at edge of map
   --code by mboffin
    player2.x=(1024+player2.x)%1024
    player2.y=(512+player2.y)%512
    
 --add trail to player
  if btn(‹,1) or btn(‘,1) or btn(”,1) or btn(ƒ,1) then
      trail(player2.x,player2.y,trail_width,trail_colors,trail_amount)
      sfx(trail_sfx)
  end
end

 --player 2 animation
 if time()-player2.anim>.15 then
  player2.anim=time()
  player2.sp+=1
   if player2.sp>24 then
    player2.sp=17
   end
 end

end
-->8
--effects
--code by nerdy teachers

    --particles
    effects = {}
    
    --effects settings
    trail_width = 2
    trail_colors = {12,13,14,15}
    trail_amount = 2
    
    --sfx
    trail_sfx = 3
    
-- core particle functions
function add_fx(x,y,die,dx,dy,grav,grow,shrink,r,c_table)
    local fx={
        x=x+4,
        y=y+4,
        t=0,
        die=die,
        grav=grav,
        grow=grow,
        shrink=shrink,
        r=r,
        c=0,
        c_table=c_table
    }
    add(effects,fx)
end

--updating the fx
function update_fx()
    for fx in all(effects) do
        --lifetime
        fx.t+=1
        if fx.t>fx.die then del(effects,fx) end
        
        --color depends on lifetime and num colors
        if fx.t/fx.die < 1/#fx.c_table then
            fx.c=fx.c_table[1]
            
        elseif fx.t/fx.die < 2/#fx.c_table then
            fx.c=fx.c_table[2]
            
        elseif fx.t/fx.die < 3/#fx.c_table then
            fx.c=fx.c_table[3]
            
        else
            fx.c=fx.c_table[4]
        end
    end
end

--drawing the fx
function draw_fx()
    for fx in all(effects) do
        --draw pixel for size 1, draw circle for larger
        if fx.r<=1 then
            pset(fx.x,fx.y,fx.c)
        else
            circfill(fx.x,fx.y,fx.r,fx.c)
        end
    end
end

-- motion trail effect
function trail(x,y,w,c_table,num)

    for i=0, num do 
        --settings
        add_fx(
            x+rnd(w)-w/2,  -- x
            y+rnd(w)-w/2,  -- y
            40+rnd(30),  -- die
            0,         -- dx
            0,         -- dy
            false,     -- gravity
            false,     -- grow
            false,     -- shrink
            1,         -- radius
            c_table    -- color_table
        )
    end
end

--make stars
function make_stars()
	s={}
	for i=1,50 do
		local ns={}
		ns.x=flr(rnd(128))
		ns.y=flr(rnd(128))
		ns.s=rnd(3)+2
		ns.c=flr(rnd(3))+1
 	add(s,ns)
	end
end

function move_star(str)
	str.x+=0.75/str.s
	str.y+=0.75/str.s
	
	if (str.x<0) then
	 re_star(0,str)
	elseif (str.x>127) then
		re_star(1,str)
	elseif (str.y<0) then
		re_star(2,str)
	elseif (str.y>127) then
		re_star(3,str)
	end
end

function draw_star(str)
	pset(sx+str.x,sy+str.y,str.c)
end

function re_star(d,str)
	if (d<2) then
		str.x=d==0 and 127 or 0
		str.y=flr(rnd(128))
	else
		str.x=flr(rnd(128))
		str.y=d==2 and 127 or 0
	end
 str.s=rnd(3)+2
	str.c=flr(rnd(3))+1
end
-->8
--dialog

-- dialog box
-- by rusty bailey

dialog = {
  x = player.x-56,
  y = player.y+36,
  color = 1,
  max_chars_per_line = 30,
  max_lines = 5,
  dialog_queue = {},
  init = function(self)
  end,
  queue = function(self, message, autoplay)
    -- default autoplay to false
    autoplay = type(autoplay) == "nil" and false or autoplay
    add(self.dialog_queue, {
      message = message,
      autoplay = autoplay
    })

    if (#self.dialog_queue == 1) then
      self:trigger(self.dialog_queue[1].message, self.dialog_queue[1].autoplay)
    end
  end,
  trigger = function(self, message, autoplay)
    self.autoplay = autoplay
    self.current_message = ''
    self.messages_by_line = nil
    self.animation_loop = nil
    self.current_line_in_table = 1
    self.current_line_count = 1
    self.pause_dialog = false
    self:format_message(message)
    self.animation_loop = cocreate(self.animate_text)
  end,
  format_message = function(self, message)
    local total_msg = {}
    local word = ''
    local letter = ''
    local current_line_msg = ''

    for i = 1, #message do
      -- get the current letter add
      letter = sub(message, i, i)

      -- keep track of the current word
      word ..= letter

      -- if it's a space or the end of the message,
      -- determine whether we need to continue the current message
      -- or start it on a new line
      if letter == ' ' or i == #message then
        -- get the potential line length if this word were to be added
        local line_length = #current_line_msg + #word
        -- if this would overflow the dialog width
        if line_length > self.max_chars_per_line then
          -- add our current line to the total message table
          add(total_msg, current_line_msg)
          -- and start a new line with this word
          current_line_msg = word
        else
          -- otherwise, continue adding to the current line
          current_line_msg ..= word
        end

        -- if this is the last letter and it didn't overflow
        -- the dialog width, then go ahead and add it
        if i == #message then
          add(total_msg, current_line_msg)
        end

        -- reset the word since we've written
        -- a full word to the current message
        word = ''
      end
    end

    self.messages_by_line = total_msg
  end,
  animate_text = function(self)
    -- for each line, write it out letter by letter
    -- if we each the max lines, pause the coroutine
    -- wait for input in update before proceeding
    for k, line in pairs(self.messages_by_line) do
      self.current_line_in_table = k
      for i = 1, #line do
        self.current_message ..= sub(line, i, i)

        -- press btn 5 to skip to the end of the current passage
        -- otherwise, print 1 character per frame
        -- with sfx about every 5 frames
        if (not btnp(Ž)) then
          if (i % 5 == 0) sfx(0)
          yield()
        end
      end
      self.current_message ..= '\n'
      self.current_line_count += 1
      if ((self.current_line_count > self.max_lines) or (self.current_line_in_table == #self.messages_by_line and not self.autoplay)) then
        self.pause_dialog = true
        yield()
      end
    end

    if (self.autoplay) then
      self.delay(60)
    end
  end,
  shift = function (t)
    local n=#t
    for i = 1, n do
      if i < n then
        t[i] = t[i + 1]
      else
        t[i] = nil
      end
    end
  end,
  -- helper function to add delay in coroutines
  delay = function(frames)
    for i = 1, frames do
      yield()
    end
  end,
  update = function(self)
    if (self.animation_loop and costatus(self.animation_loop) != 'dead') then
      if (not self.pause_dialog) then
        coresume(self.animation_loop, self)
      else
        if btnp(Ž) then
          self.pause_dialog = false
          self.current_line_count = 1
          self.current_message = ''
        end
      end
    elseif (self.animation_loop and self.current_message) then
      if (self.autoplay) self.current_message = ''
      self.animation_loop = nil
    end

    if (not self.animation_loop and #self.dialog_queue > 0) then
      self.shift(self.dialog_queue, 1)
      if (#self.dialog_queue > 0) then
        self:trigger(self.dialog_queue[1].message, self.dialog_queue[1].autoplay)
        coresume(self.animation_loop, self)
      end
    end

  end,
  draw = function(self)
    local screen_width = 128

    -- display message
    if (self.current_message) then
      printo(self.current_message, self.x, self.y, self.color)
    end

  end
}

-->8
--win screen

function init_win()
  _update60=update_win
  _draw=draw_win
end

function update_win()
 if btn(—) then
  stop()
 end
end

function draw_win()
 cls(0)
 camera(0,0)
 
--ABCDEFGHIJKLMNOPQRSTUVWXYZ
 
 print("’’’’mission complete’’’’",0,0,13)
 print("",0,4,13)
 print("credits",50,9,12)
 print("gAME BY nIALL cHANDLER",1,16,12)
 print("mUSIC BY gRUBER",1,22,12)
 print("special thanks to:",28,29,12)     
 print("nERDY tEACHERS",1,36,12)     
 print("rUSTY bAILEY",1,42,12)     
 print("dYLAN bENNETT",1,48,12)     
 print("rEMY dEVAUX",1,54,12)     
 print("tOM hALL",1,60,12)     
 print("aNDROYD",1,66,12) 
 print("wENCESLAO vILLANEUVA jR.",1,72,12) 
 print("",0,77,3)    
 print("tHANK YOU SO MUCH FOR PLAYING MY",0,81,3)     
 print("GAME!! yOU ARE A SUPER PLAYER!!!",0,87,3)
 print("",0,91,9)
 print("TOTAL PLAYTIME:",34,94,9)
 print("“"..hours.."h "..minutes.."m "..seconds.."s "..milliseconds.."f",32,100,9)
 print("",0,104,5)
 print("    CTRL+R TO REPLAY MISSION",0,107,5)
 print("    pRESS — TO END THE GAME",0,113,5)
 print("’’                        ’’",0,110,5)
 print("",0,117,11)
 spr(32,19,121)   
 print("2021 nIALL cHANDLER",32,122,11)  
end
-->8
--minigame

--ABCDEFGHIJKLMNOPQRSTUVWXYZ

 --flappy birdish thing
function init_mini()
 _update60=update_mini
 _draw=draw_mini
 playing=false
 --music(0)
end

function restart()
 highscore = dget(0)
 game_over=false
 make_cave()
 make_player()
end

function update_mini()
  if (playing==true) then 
    _update_game()
  else
    _update_menu()
  end
end

function _update_menu()
  if (btnp(Ž,1)) then
    playing=true
    restart()
  end
end

function _update_game()
 if (not game_over) then
  update_cave()
  move_player()
  check_hit()
 elseif (btnp(Ž,1)) then 
  restart()
 end

end

function draw_mini()
 if (playing) then
		 _draw_game()
		
	else 
	  _draw_menu()
	end
end

--ABCDEFGHIJKLMNOPQRSTUVWXYZ

function _draw_menu()
 cls(0)
 camera(0,0)
 
 --title
 spr(96,28,28)
 spr(97,36,28)
 spr(98,44,28)
 spr(99,52,28)
 spr(100,60,28)
 spr(101,68,28)
 spr(11,76,28)
 spr(12,84,28)
 spr(13,92,28)
 --
 spr(112,28,36)
 spr(113,36,36)
 spr(114,44,36)
 spr(115,52,36)
 spr(116,60,36)
 spr(117,68,36)
 spr(27,76,36)
 spr(28,84,36)
 spr(29,92,36)
	cta="pUSH tab/w TO START"
	cta2="pUSH q/a TO JUMP"
	
 printo(cta,hcenter(cta),96,1,6)
 printo(cta2,hcenter(cta2),104,1,6)
 spr(1,60,60)
 
end

--ABCDEFGHIJKLMNOPQRSTUVWXYZ

function _draw_game()
 cls(0)
 camera(0,0)
 if (playing==true) then
   draw_cave()
   draw_player()
   if (game_over) then
     printo("gAME OVER!",44,40,1,6)
     printo("yOUR sCORE:"..play.score,34,50,1,6)
     printo("pUSH tab/w TO TRY AGAIN!",14,70,3,15)
     printo("cTRL+r TO RESTART MISSION",12,80,3,15)
     printo("pUSH q/a TO JUMP",30,110,3,15)
     if (play.score > highscore) then
       dset(0, play.score)
     end
   else
     printo("sCORE:"..play.score,2,2,1,6)
     if highscore<30000 then
      printo("hI sCORE:"..highscore,2,121,3,15)
     else
      printo("hI sCORE:"..highscore.."’",2,121,3,15)
     end
   end
 end
end

function make_player()
 play={}
 play.x=60
 play.y=60
 play.dy=0
 play.rise=1
 play.fall=1
 play.dead=1
 play.speed=1
 play.score=0
end

function draw_player()
 if (game_over) then
  spr(play.dead, play.x, play.y,1,1,false,true)
 elseif (player.dy<0) then
  spr(play.rise, play.x, play.y)
 else
  spr(play.fall, play.x, play.y)
 end
end

function move_player()
 gravity=0.1
 play.dy+=gravity
 
 -- jump
 if (btnp(—,1) 

 ) then
  play.dy-=2.5
  sfx(2)
 end
 
 -- move player
 play.y+=play.dy
 
 -- prevent getting outside screen
 if (play.y < 0) then
  play.y =0
  play.dy=0
 end
 if (play.y > 127) then
  play.y=127
  play.dy=0
 end
 
 --score
 play.score+=play.speed/2
 if (play.score == highscore) then
   sfx(1)
 end
 if play.score>=30000 then
  play.score=30000
 end
end

function make_cave()
 cave={{["top"]=5,["btm"]=119}}
 top=50
 btm=80
end

function update_cave()
 -- remove back of the cave
 if (#cave>play.speed) then
  for i=1, play.speed do
   del(cave,cave[1])
  end
 end
 
 -- add cave
 while (#cave<128) do
  local col={}
  local up=flr(rnd(7)-3)
  local dwn=flr(rnd(7)-3)
  col.top=mid(3, cave[#cave].top+up,top)
  col.btm=mid(btm, cave[#cave].btm+dwn,124)
  add(cave,col)
 end
end

function draw_cave()
  top_color=8
  btm_color=7
  for i=1, #cave do
   line(i-1,0,i-1,cave[i].top,top_color)
   line(i-1,127,i-1,cave[i].btm,btm_color)
  end
end

function check_hit()
 for i=play.x,play.x+7 do
  if (cave[i+1].top>play.y
   or cave[i+1].btm<play.y+7
  ) then
   game_over=true
   sfx(10)
  end
 end
end



-- horizontal centering
function hcenter(s)
  return 64-#s*2
end

function rectfill_p(x0,y0,x1,y1,p,c0,c1)
 fill_pattern(p)
 col=color_pattern(c0,c1)
 rectfill(x0,y0,x1,y1,col)
end
__gfx__
00000000000660000006600000066000000660000006600000066000000660000006600000000000000000000000000000000000000000000111100011110000
00000000006146000061460000614600006146000061460000614600006146000061460001100111111110000111111111100111111110001101100001100000
00700700064445600644456006444560064445600644456006444560064445600644456001100111111110000111111111100111111110001111100001100000
00077000066556600665566006655660066556600665566006655660066556600665566001100110000001100110000000000110000001101100000001100000
000770006e6666e66e6666f66d6666f66d6666e66e6666e66e6666d66f6666d66f6666f601100110000001100110000000000110000001101100000011110000
007007006eeddee66eddeef66ddeeff66deeffe66eeffee66effeed66ffeedd66feeddf601100110000001100111111110000111111110000000000000000000
0000000006edde6006ddee6006deef6006eeff6006effe6006ffee6006feed6006eedd6001100110000001100111111110000111111110000000000000000000
00000000006666000066660000666600006666000066660000666600006666000066660011100110000001100110000000000111111000000000000000000000
00011100000770000007700000077000000770000007700000077000000770000007700011100110000001100110000000000111111000000111000001111000
00100010007127000071270000712700007127000071270000712700007127000071270001100111111110000111111111100110000111101100000011011000
0101110107222b7007222b7007222b7007222b7007222b7007222b7007222b7007222b7001100111111110000111111111100110000111101100000011011000
01010001077bb770077bb770077bb770077bb770077bb770077bb770077bb770077bb77000000000000000000000000000000000000000001100000011011000
01011101797777977a7777977a777787797777877977779778777797787777a7797777a710100101110000000000000000000000000000001111000011110000
00100010799889977a9988977aa9988779aa9987799aa9977899aa9778899aa7798899a700100101100000000000000000000000000000000000000000000000
00011100079889700799887007a9987007aa9970079aa9700799aa7007899a700788997000111101000000000000000000000000000000000000000000000000
00000000007777000077770000777700007777000077770000777700007777000077770000100100110000000000000000000000000000000000000000000000
000bbb002b1111b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111000
00b000b0b021120b0110000001100001111110000001111111100001111110000001111111100110000001100001111110000001111111100000000001001000
0b0bbb0bb021120b0110000001100001111110000001111111100001111110000001111111100110000001100001111110000001111111101100000011111000
0b0b000b6b2112b60110000001100110000001100110000000000110000001100110000000000111100111100110000001100110000000000000000011001000
0b0bbb0b06b22b600110000001100110000001100110000000000110000001100110000000000111100111100110000001100110000000000000000011111000
00b000b0006bb6000110011001100111111111100110000000000110000001100001111110000110011001100110000001100001111110000000000000000000
000bbb0000b22b000110011001100111111111100110000000000110000001100001111110000110011001100110000001100001111110000000000000000000
000000000b2112b00111100111100110000001100110000000000110000001100000000001100110000001100110000001100000000001100000000000000000
00000000011110011110011000000110011000010110000000000110000001100000000001100110000001100110000001100000000001100000000000000000
01100000011000000110011000000110011000000001111111100001111110000111111110000110000001100001111110000111111110000000000000000000
01100000011000000110011000000110011000000001111111100001111110000111111110000110000001100001111110000111111110000000000000000000
01111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100110000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100110000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100001000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000f0000000000000000000000000000000b00000000000000000000000000000002000000000000000000000000000000000000000
000001821555000000000ccdddcd00000000034443390000000002222222000000000fdfcffe0000000001bbbb11000000001211111b00000000000000000000
000a441111155600000cccccdccccd000005397444387500000222b222222b00000dcccdcceeef00000211111112150000088888111180000000000000000000
00a44448aa82546000ccccccccccccf00053987b43337b6000b222222222226000dffcfffdcefee000122224424151500012111aa411b7000000111100000000
00a11844444aa98000ccc33cc333ccd00034447343339850002222222226b22000cffffffccceee00042222222241510011822111a1847700001211100000000
0a89aaaaaa4498760ccc333cccccccdc0239334484338455022222222226bb620ccccffffdcfefee011422222211555502811112128777600021011100000000
0a84aaaaaa9488870cccc333ccccccdc0333333944442bb602b22222222222260dcccfffdcfdefee01111422222255652788aa11188884b60120111100000000
08aaa4a8888448880ccc333ccccccccd0339333344444b5502bbb222222222bb0ccdcffdcfffeefe041bb1114111112118a21111288814b62200121000000000
0488488118288487fccc333cccccdddd02b9998444442bb5b22bb2bb2226222b0ecfdcdcfcfeefee1211bbb11114121200000000000000211000210000000000
06788824488848680c3ccc3ccccddddd0788844444333b54022222bbb2222b220eecfccffddeeeef011bbbb111212126000007bb2bbbb2220001100000000000
04288888888888870cccccccccccdded077744444333b3450222222b222222260eecfccccffefff601111bb11212122b00077b77bbb222200012000000000000
0412188aaa8258670dcdddccccc3ceee075744445333385502222222222222b20eeefefeeeeffef6011111bb112125b600f77f7f777b22200120000000000000
0044488aa425968000cddddcccc3dee0004775453333975000222222222b222000efffefeeffee600051114b52122b60006ff7777bb222202200000000000000
008446221555566000dddddccdccdef0005377545339776000222b22622222b000efffffffeee6f00025555b2125b660077fb7bbbbb2222b2000000000000000
0007445555568600000ddcddedeeff00000355454377770000022222222b6b00000fffffeeee660000025555552666000b7b7bb222b2222b0000000000000000
000004666678000000000deeefff00000000055757770000000002222262000000000efeeeee000000000155b66600000777bbbbbb2222b20000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff7777777bb2b7b0000000060000000
0111111111100110000001100110000001100111111111100000000000000000000000000000000000000000000000000677777fbb7bbbbb0000066b6b660000
01111111111001100000011001100000011001111111111000000000000000000000000000000000000000000000000006677b7777bbbbb7000ccbbcb6666e00
0000011000000110000001100111100111100110000001100000000000000000000000000000000000000000000000007666f66f7bb77ff600cccbcccb6dd660
000001100000011000000110011110011110011000000110000000000000000000000000000000000000000000000007b06f77ffbff7776000ccccccccb66660
0000011000000110000001100110011001100111111111100000000000000000000000000000000000000000000000770ffff6fff666ff700cccccccbccdde66
0000011000000110000001100110011001100111111111100000000000000000000000000000000000000000000007707ffffff66ff777000cccccccccbdd666
000001100000011000000110011000000110011000000000000000000000000000000000000000000000000000007707ff00f7ffffff00000ccccccccc66de66
0000011000000110000001100110000001100110000000000000000000000000000000000000000000000000000770771192111288718476ccccccccccddee66
011111100000000111111000011000000110011000000000000000000000000000000000000000000000000000777770b4118188888a98680ccccccccdde6ee6
011111100000000111111000011000000110011000000000000000000000000000000000000000000000000007777700b1477888a82ab8660dd6ccc6ddde6e6e
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f7770000417798484ab76600dddddddd6ee66ee
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006ff700000b86188881b86660006dd666eeeeee60
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff00000000b6621bbbb7660000e6ee66eee6e6e0
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7666b66670000006e666e6eee600
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666067740000000006ee66660000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000c7d7000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000e6f6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000e7f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000e40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000c5d5e50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000b6c6d6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000b70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000445400000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000455500000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a4b400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a5b500000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000404100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000505100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004849000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005859000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000046470000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056570000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004243000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005253000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004c4d000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010300000a740167400a7401674016700267000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00070000247572475724747247471f7571f7572475724757247572475724757247572475724757247472474724747247071d707167070d707067071b7071b7071a7071a7071a7071f7071f7071f7072370723707
000100001f0551f0551f0551f0551f0551f0552005521055220452303524025250153600534005340053400534005340053400534005340053400534005340053400534005340053400534005340053400534005
002d00000961001611156011c6012c6013160131601236011b6010d6010d6010c6010b6010a601096010860107601096010b6010160106601076010f601186011c60125601256011c60116601126010d60109601
010200001d7272a7271c707147071a7072270718707257072b707217071970728707317072b707217071f7072c7073070725707217071b7072070725707297072c7071f7071b707227072f707247072970719707
001400001054512545150451a5451054512545150451a5451054512545150451a5451054512545150451a5451054512545170451c5451054512545170451c5451054512545160451c5451054512545160451c545
001400000c0630256502555020750e6450255502075025550c0630256502555020750e6450255502075025550c0630255502075025650e6450207502565025550c0630256502555020750e645025550207502555
001400002c7552c0452c7452a0552a7452a0452a7452f0452c7552c0452c7452804525755250452a7552a0452075520745207451e7551e7451e7451e745217452075520745207451e7551e7451e7451e7451e745
001400000c0630656506555060750e6450655506075065550c0630656506555060750e6450655506075065550c0630955509075095650e6450907509565095550c0630956509555090750e645095550907509555
0014000020755200452074520045217552104521745210452c7552c0452c7452c0452a7552a0452a7452a045257552504525745250452675526045267453404532755310452d745280452675525045217451c045
001000001a050180501605013050100500e0400b03008020080200801008010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001a00000174401035117441103512744120350874408035127441203501744010351174411035087440803505744050350d7440d035147441403506744060350874408035127441203511744110350d7440d035
000d00200c0431b52119525195252072220722145251452518625317251d5251d525125050c04314525145250c0430150519525195250d527205261452514525186253172520525205250d5210c043145250c043
001a00000a7440a03511744110350d7440d03505744050350674406035147441403511744110350d7440d0350a7440a03511744110350d7440d03508744080350374403035127441203511744110350d7440d035
000d00200c0431b521295222952220722207222c5202c52018625315243152531524295250c04329525295250c0430150525525255250d527205262052520525186253172520525205250d5210c043145250c043
0016002006055061550d055061550d547061550d055061550d055060550615501155065470d15504055041550b055041550b547041550b055041550b0550b155040550b155045460b1550b055041550b0550b155
00160000190241902506535135000653500505065351a0241a025065351a0250653506404065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
000b00201e4321e4221f4161e4161c4221c4121e4321e4221e4121e4121f4161e4161c4321c4221c4121c4121c4121c4121c4121c4121c4121c4121c4121c4121c4121c4121c4121c41510115101051011510105
000b00201e4321e4261f4161e4161c4321c4321a4351c4351e4351f43521435234352643528435254322542219432194222543225422264262542623432234222143221422234372342625430234302143520435
001600001e4401e4321e4221e4250653500505065351a0241a025065351a0250653500505065351902419025045351702404535005050453500505045351e0241e025045351e0240453504535005050453504535
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 06 42 43 44
01 06 05 43 44
00 06 05 43 44
00 06 07 43 44
00 08 07 43 44
02 08 09 43 44
00 41 42 43 44
00 41 42 43 44
01 0b 42 43 44
01 0b 0c 43 44
00 0b 0c 43 44
00 0d 0c 43 44
00 0b 0e 43 44
02 0d 0e 43 44
00 41 42 43 44
00 41 42 43 44
01 0f 10 43 44
01 0f 10 43 44
00 0f 11 43 44
00 0f 11 43 44
00 0f 12 43 44
00 0f 12 43 44
02 0f 13 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
