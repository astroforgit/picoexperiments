pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--stuck in the sewers
--by julio maass and bonevolt

cartdata("stuck_in_the_sewers")

poke(0x5f5c, 255)

function _init()
 heartcolor=0
 endingmessage=0
 charmax=dget(20)
 showtimer=dget(30)
 changechar=false
 char=0
 textcolor=0
 pipelist={}
 mousebestclock=dget(0)
 mousebestminute=dget(1)
 mousebeststeps=dget(2)
 mousebestclock100=dget(3)
 mousebestminute100=dget(4)
 mousebeststeps100=dget(5)
 
 girlbestclock=dget(6)
 girlbestminute=dget(7)
 girlbeststeps=dget(8)
 girlbestclock100=dget(9)
 girlbestminute100=dget(10)
 girlbeststeps100=dget(11)
 
 icebestclock=dget(12)
 icebestminute=dget(13)
 icebeststeps=dget(14)
 icebestclock100=dget(15)
 icebestminute100=dget(16)
 icebeststeps100=dget(17)

 if charmax>0 then
  mset(6,0,25)
  mset(9,0,25)
  mset(6,1,25)
  mset(9,1,25)
  mset(6,2,21)
  mset(9,2,21)
 end
	
	savesteps=0
	saveminutes=0
	saveclock=0
	savetrigger=false
	steps=0
 startclock=false
 dt=0
 clock=0
	minutes=0
 level=0//16
 playerx=8
 playery=24
 sprite=1
 fliped=true 
 freezefeet=false
 coins=0
 levelx=0
 levely=0
 tim=0
 dx1=0
 dy1=0
 music(1)
 scr_frame=0
end

function _update()
 if btnp(”) and (playerx==48 or playerx==72) and playery==24 then 
  changechar=true
 end
 if playerx==144 and playery==312 and savetrigger==false then
  savetrigger=true
 	savesteps=steps
 	saveminutes=minutes
 	saveclock=clock
 	
 	if char==0 then
	  if mousebeststeps == 0 
	   or savesteps<mousebeststeps then 
	    mousebeststeps=savesteps 
	  end
	  if (mousebeststeps100 == 0 
	   or savesteps<mousebeststeps100) 
	   and coins==100 
	  then mousebeststeps100=savesteps 
	  end
	  if (mousebestclock == 0 
	   and mousebestminute == 0)
	   or (saveminutes < mousebestminute)
	   or (saveminutes == mousebestminute
	   and saveclock < mousebestclock)
	  then mousebestclock=saveclock
	   mousebestminute=saveminutes
	  end
	  if ((mousebestclock100 == 0 
	   and mousebestminute100 == 0)
	   or (saveminutes < mousebestminute100)
	   or (saveminutes == mousebestminute100
	   and saveclock < mousebestclock100))
	   and coins==100
	  then mousebestclock100=saveclock
	   mousebestminute100=saveminutes
	  end
  end
  
	dset(0,mousebestclock)
	dset(1,mousebestminute)
	dset(2,mousebeststeps)
	dset(3,mousebestclock100)
	dset(4,mousebestminute100)
	dset(5,mousebeststeps100)

 	if char==1 then
	  if girlbeststeps == 0 
	   or savesteps<girlbeststeps then 
	    girlbeststeps=savesteps 
	  end
	  if (girlbeststeps100 == 0 
	   or savesteps<girlbeststeps100) 
	   and coins==100 
	  then girlbeststeps100=savesteps 
	  end
	  if (girlbestclock == 0 
	   and girlbestminute == 0)
	   or (saveminutes < girlbestminute)
	   or (saveminutes == girlbestminute
	   and saveclock < girlbestclock)
	  then girlbestclock=saveclock
	   girlbestminute=saveminutes
	  end
	  if ((girlbestclock100 == 0 
	   and girlbestminute100 == 0)
	   or (saveminutes < girlbestminute100)
	   or (saveminutes == girlbestminute100
	   and saveclock < girlbestclock100))
	   and coins==100
	  then girlbestclock100=saveclock
	   girlbestminute100=saveminutes
	  end
  end
  
	dset(6,girlbestclock)
	dset(7,girlbestminute)
	dset(8,girlbeststeps)
	dset(9,girlbestclock100)
	dset(10,girlbestminute100)
	dset(11,girlbeststeps100)

 	if char==2 then
	  if icebeststeps == 0 
	   or savesteps<icebeststeps then 
	    icebeststeps=savesteps 
	  end
	  if (icebeststeps100 == 0 
	   or savesteps<icebeststeps100) 
	   and coins==100 
	  then icebeststeps100=savesteps 
	  end
	  if (icebestclock == 0 
	   and icebestminute == 0)
	   or (saveminutes < icebestminute)
	   or (saveminutes == icebestminute
	   and saveclock < icebestclock)
	  then icebestclock=saveclock
	   icebestminute=saveminutes
	  end
	  if ((icebestclock100 == 0 
	   and icebestminute100 == 0)
	   or (saveminutes < icebestminute100)
	   or (saveminutes == icebestminute100
	   and saveclock < icebestclock100))
	   and coins==100
	  then icebestclock100=saveclock
	   icebestminute100=saveminutes
	  end
  end
  
	dset(12,icebestclock)
	dset(13,icebestminute)
	dset(14,icebeststeps)
	dset(15,icebestclock100)
	dset(16,icebestminute100)
	dset(17,icebeststeps100)


 end
 if level>0 then
		if btn(0) or btn(1) or btn(2) or btn(3) then
			startclock=true
		end
	 if steps>9999 then steps=9999 end
 	if	startclock==true then
   dt+=1
   if dt%3==0 then clock+=1 end
 		if clock==600 then
 		 minutes+=1
    clock=0
 		end
  end
 end
 tim+=1
 if btnp(”) and not fget(mget(playerx/8,playery/8-1),0) and not fget(mget(playerx/8,playery/8-1),7) then playery-=8 sprite=2 dy1=-1 sfx(1) steps+=1 end
 if btnp(ƒ) and not fget(mget(playerx/8,playery/8+1),0) and not fget(mget(playerx/8,playery/8+1),7) then playery+=8 sprite=1 dy1= 1 sfx(1) steps+=1 end
 if btnp(‹) and not fget(mget(playerx/8-1,playery/8),0) and not fget(mget(playerx/8-1,playery/8),6) then playerx-=8 sprite=1 dx1=-1 sfx(1) steps+=1 fliped=false end
 if btnp(‘) and not fget(mget(playerx/8+1,playery/8),0) and not fget(mget(playerx/8+1,playery/8),6) then playerx+=8 sprite=1 dx1= 1 sfx(1) steps+=1 fliped=true end
 --if btnp(—) then nextlevel(1) end
 
 if level == 0 then steps = 0 end
 
 function fade()
	 for i=0,20 do
	  for n=0,7 do
	  circ(old_playerx%128+4,old_playery%128+4,160-i*8+n,0)
	  circ(old_playerx%128+4,old_playery%128+3,160-i*8+n,0)
	  end
	  flip()
	 end
	 scr_frame=1
 end
 
 function nextlevel(n)
	 level+=n
  if level==17 then music(18) end
	 levelx=level%8
	 levely=flr(level/8)
	 sfx(3)
	 for i=0,15 do
	  for j=0,15 do
	   if fget(mget(i+levelx*16,j+levely*16),1) then
	    rplayerx=i*8
	    rplayery=j*8
	    freezefeet=true
	   end
	  end
	 end
	 fade()
 end

 function prevlevel()
	 level-=1
	 levelx=level%8
	 levely=flr(level/8)
	 sfx(2)
  for i=0,15 do
   for j=0,15 do
    lookbluespot=mget(i+levelx*16,j+levely*16)
    if lookbluespot==51 then
     rplayerx=i*8
     rplayery=j*8
     freezefeet=true
    end
   end
  end
	 for i=0,20 do
	  for n=0,7 do
	  circ(old_playerx%128+4,old_playery%128+4,160-i*8+n,0)
	  circ(old_playerx%128+4,old_playery%128+3,160-i*8+n,0)
	  end
	  flip()
	 end
	 scr_frame=1
 end

 rplayerx=playerx%128
 rplayery=playery%128

-- if level==0 then
--  if playerx==112 and playery==24 then nextlevel() end
-- end
 
-- if mget(playerx/8,playery/8)==33 then nextlevel() end
 if mget(playerx/8,playery/8)>=44
 and mget(playerx/8,playery/8)<=47
 and mget(old_playerx/8,old_playery/8)==51 then
--cano rosa
	 if char==1 and level==0 then
			level=17
			prevlevel(1)
	 elseif char==1 and level==16 then
			level=1
			prevlevel(1)
		else
	  nextlevel(1)
	 end 
 end

 old_playerx=playerx
 old_playery=playery
 
 tilescan=mget(playerx/8,playery/8)
 greenpipe=fget(mget(playerx/8,playery/8),2)
 redpipe=fget(mget(playerx/8,playery/8),3)
 yellowpipe=fget(mget(playerx/8,playery/8),4)
 bluepipe=fget(mget(playerx/8,playery/8),5)
 
 if tilescan==35 then
  mset(playerx/8,playery/8,19)
  coins+=1
  sfx(0)
 end 
 
 --cano preto
 if tilescan==58 or tilescan==59 or tilescan==60 or tilescan==61 and freezefeet==false then
  if char==1 and level==1 then
   level=16
   nextlevel(1)
  elseif char==1 and level == 17 then
  	level=0
   nextlevel(1)
  else
   prevlevel(1)
  end
  if char==2 then
   unpaint()
  end
 end

 --cano verde
 if greenpipe==true and freezefeet==false then
  if char==2 then
   paintblack()
  end
  if tilescan==6 or tilescan==7 then
   rplayerx=120-rplayerx
  end
  if tilescan==4 or tilescan==5 then
   rplayery=120-rplayery
  end
 end

 --cano vermelho
 if redpipe==true and freezefeet==false then
  if char==2 then
   paintblack()
  end
  if tilescan==20 or tilescan==21 then
   rplayerx=120-rplayerx
  end
  if tilescan==22 or tilescan==23 then
   rplayery=120-rplayery
  end
 end

 --cano amarelo
 if yellowpipe==true and freezefeet==false then
  if char==2 then
   paintblack()
  end
  rplayerx=120-rplayerx
  rplayery=120-rplayery
 end

 --cano azul
 if bluepipe==true and freezefeet==false then
  if char==2 then
   paintblack()
  end
  rplayerytemp=rplayerx
  rplayerx=120-rplayery
  rplayery=rplayerytemp
 end
 
 playerx=rplayerx+levelx*128
 playery=rplayery+levely*128
 tilescan=mget(playerx/8,playery/8)

 --cano cuspir
 if freezefeet==false then
	 if tilescan==4 or
	    tilescan==20 or
	    tilescan==36 or
	    tilescan==52 or 
	    tilescan==44 or 
	    tilescan==58 then 
	    rplayery-=8 sprite=2 sfx(2) dx=0 dy=-1 end 
	 if tilescan==5 or
	    tilescan==21 or
	    tilescan==37 or
	    tilescan==53 or 
	    tilescan==45 or 
	    tilescan==59 then 
	    rplayery+=8 sprite=1 sfx(2) dx=0 dy=1  end 
	 if tilescan==6 or
	    tilescan==22 or
	    tilescan==38 or
	    tilescan==54 or 
	    tilescan==46 or 
	    tilescan==60 then 
	    rplayerx-=8 sprite=1 sfx(2) fliped=false dx=-1 dy=0  end 
	 if tilescan==7 or
	    tilescan==23 or
	    tilescan==39 or
	    tilescan==55 or 
	    tilescan==47 or 
	    tilescan==61 then 
	    rplayerx+=8 sprite=1 sfx(2) fliped=true dx=1 dy=0  end 
 end

--[[ if level==1 then
  if rplayerx==96 and rplayery==8 then nextlevel() end
  if rplayerx==8 then rplayerx=104 end 
  if rplayerx==112 then rplayerx=16 end 
  if rplayery==8 then rplayery=104 end 
  if rplayery==112 then rplayery=16 end 
 end
 
 if level==2 then 
  if playerx==8+level*128 then
   playerx=16+level*128
   if playery==24 then playery=96
   elseif playery==48 then playery=72
   elseif playery==72 then playery=48
   elseif playery==96 then playery=24 end
  end 
  if playerx==112+level*128 then
   playerx=104+level*128
   if playery==24 then playery=96
   elseif playery==48 then playery=72
   elseif playery==72 then playery=48
   elseif playery==96 then playery=24 end
  end
  if playery==8 then
   playery=16
   if playery==24 then playery=96
   elseif playery==48 then playery=72
   elseif playery==72 then playery=48
   elseif playery==96 then playery=24 end
  end
 end]]

 playerx=rplayerx+levelx*128
 playery=rplayery+levely*128
 freezefeet=false
end

function _draw()

 scr_frame=min(scr_frame+1,8)
 for i=0,15 do
  pal(i,sget(48+i,40-scr_frame))
 end
 
 for walk_pipe=0,15,1.5 do
  cls()
	 camera(levelx*128,levely*128) 
	 map(0,0,0,0,128,64)
	 for i=0,128 do
	  for j=0,128 do
	   if mget(i,j)==35 then
	    spr(64+tim\3%6,i*8,j*8)
	   end
	  end
	 end
	 
 	if level==25 then
	 	if char==1 then
	 	 mset(24,54,89)
	 	 mset(25,54,89)
	 	 mset(24,55,89)
	 	 mset(25,55,89)
			 pal({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}) 
			 for i=-1,1 do
			  for j=-1,1 do
			   if abs(i+j)==1 then
		     sspr(0,40,12,12,24*8+4+i,55*8-4+j)
			   end
			  end
			 end
			 pal()
	 	 sspr(0,40,12,12,24*8+4,55*8-4)
	 	end
	 end
 	if level==25 then
	 	if char==2 then
	 	 mset(23,59,89)
	 	 mset(23,60,89)
	 	 mset(22,54,127)
	 	 mset(22,55,127)
			 pal({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}) 
			 for i=-1,1 do
			  for j=-1,1 do
			   if abs(i+j)==1 then
		     sspr(0,40,12,12,23*8-4+i,55*8-5+j,12,12,true)
			   end
			  end
			 end
			 pal()
	 	 sspr(0,40,12,12,23*8-4,55*8-5,12,12,true)
    heartcolor+=1
				if heartcolor\2%2==0 then
 				print("‡",23*8+6,55*8-9,8)
				end
				if heartcolor\2%2==1 then
 				print("‡",23*8+6,55*8-9,14)
    end
    rectfill(23*8-4,59*8+2,23*8,59*8+15,15)    
	 	end
	 end
	 
	 --spr(sprite,playerx,playery,1,1,fliped)
	 if walk_pipe<8 then
	  if walk_pipe>0 then
		  if dy1==-1 then
		   clip(0,old_playery+8-levely*128,9999,16)
		  elseif dy1==1 then
		   clip(0,old_playery-16-levely*128,9999,16)
		  elseif dx1==-1 then
		   clip(old_playerx+8-levelx*128,0,16,9999)
		  elseif dx1==1 then
		   clip(old_playerx-16-levelx*128,0,16,9999)
		  end
	  end
	  local s
	  local f
	  if dy1==1 then
	   s=1
	  elseif dy1==-1 then
	   s=2
	  else
	   s=sprite
	  end
	  if dx1==1 then
	   f=true
	  elseif dx1==-1 then
	   f=false
	  else
	   f=fliped
	  end
  	draw_char(old_playerx,old_playery,walk_pipe*dx1-dx1*8,walk_pipe*dy1-dy1*8,s,f)
 	else
	  if dy==-1 then
	   clip(0,playery-8-levely*128,9999,16)
	  elseif dy==1 then
	   clip(0,playery-levely*128,9999,16)
	  elseif dx==-1 then
	   clip(playerx-8-levelx*128,0,16,9999)
	  elseif dx==1 then
	   clip(playerx-levelx*128,0,16,9999)
	  end
	  if changechar==true then 
    char+=1
    if char>charmax then char=0 end
    changechar=false
   end
 	 draw_char(playerx,playery,walk_pipe*dx-dx*16,walk_pipe*dy-dy*16,sprite,fliped)
 	end
 	clip()
  
  if level < 16 then 
		 rectfill(levelx*128,levely*128,levelx*128+35,levely*128+7,0)
		 rectfill(levelx*128+88,levely*128,levelx*128+128,levely*128+7,0)
   if char == 1 and level > 0 then
 		 print("level "..-1*(level-17),levelx*128+1,levely*128+1,7)
		 else
 		 print("level "..level,levelx*128+1,levely*128+1,7)
   end
		 print("coins "..coins,levelx*128+90,levely*128+1,7)
			if showtimer==1 then
				if minutes<100 then
				 rectfill(levelx*128,levely*128+120,levelx*128+48,levely*128+7+120,0)
				else
				 rectfill(levelx*128,levely*128+120,levelx*128+52,levely*128+7+120,0)
				end
			 rectfill(levelx*128+86,levely*128+120,levelx*128+35+100,levely*128+7+120,0)
			 print("time "..(minutes\10)..(minutes%10)..":"..(clock\100%6)..(clock\10%10).."."..(10*clock\10)%10,levelx*128+1,levely*128+1+120,7)
			 print("steps "..steps,levelx*128+88,levely*128+1+120,7)
   end
  elseif level == 16 then 
		 rectfill(levelx*128+5,levely*128+60,levelx*128+35+15,levely*128+7+60,0)
		 rectfill(levelx*128+88-30,levely*128+60,levelx*128+128-30,levely*128+7+60,0)
		 if char == 1 then
		  print("  level 1 ",levelx*128+1+5,levely*128+1+60,7)
		 else
		  print("last level",levelx*128+1+5,levely*128+1+60,7)
		 end
		 print("coins "..coins,levelx*128+90-30,levely*128+1+60,7)
			if showtimer==1 then
		  print("time "..(minutes\10)..(minutes%10)..":"..(clock\100%6)..(clock\10%10).."."..(10*clock\10)%10,levelx*128+1,levely*128+1,7)
		  print("steps "..steps,levelx*128+88,levely*128+1,7)
			end
  else
		 rectfill(levelx*128,levely*128,levelx*128+29,levely*128+7,0)
		 rectfill(levelx*128+88,levely*128,levelx*128+128,levely*128+7,0)
		 print(" beach",levelx*128+1,levely*128+1,7)
		 print("coins "..coins,levelx*128+90,levely*128+1,7)
			if showtimer==1 then
				if minutes<100 then
				 rectfill(levelx*128,levely*128+120,levelx*128+48,levely*128+7+120,0)
				else
				 rectfill(levelx*128,levely*128+120,levelx*128+52,levely*128+7+120,0)
				end
			 rectfill(levelx*128+86,levely*128+120,levelx*128+35+100,levely*128+7+120,0)
			 print("time "..(saveminutes\10)..(saveminutes%10)..":"..(saveclock\100%6)..(saveclock\10%10).."."..(10*saveclock\10)%10,levelx*128+1,levely*128+1+120,7)
			 print("steps "..savesteps,levelx*128+88,levely*128+1+120,7)
			end
  end 
	 --print(level,50+level*128,80,7)
	 --print(rplayerx,50+level*128,90,7)
	 --print(rplayery,50+level*128,100,7)
	 --print(tilescan,50+level*128,110,7)
	 if mget(playerx/8,playery/8)==33 then spr(33,playerx,playery) end
	 camera()
	 if tilescan%16>3
	 and tilescan%16<8
	 or tilescan>=44
	 and tilescan<=47
	 or tilescan>=58
	 and tilescan<=62 then
   flip()
  else
   break
  end
 end
 dx1=0
 dy1=0
 camera()
 
 scr_frame=min(scr_frame+1,8)
 for i=0,15 do
  pal(i,sget(48+i,40-scr_frame))
 end
 
 if level==17
 and playerx>210 then
  nextlevel(8)
  playerx=144
 end
 
 if level==25
 and playerx>180 then
  dset(30,1)
  for i=0,30 do
		 for i=0,15 do
		  pal(i,sget(48+i,40-scr_frame),1)
		 end
	  flip()
	  scr_frame=max(scr_frame-.2,1)
	 end
	 
  for i=0,20 do
   flip()
  end
  
	 pal()
	 
	 if char==0 and charmax==0 and coins<100 then
   endingmessage=1
  end
	 if char==0 and charmax==0 and coins==100 then
   charmax=1
   endingmessage=2
  end
	 if char==1 and charmax==1 and coins<100 then
   endingmessage=3
  end
	 if char==1 and charmax==1 and coins==100 then
   charmax=2
   endingmessage=4
  end

  dset(20,charmax)
  		
  --photo
  for i=1,10,.5 do
   cls(({7,7,7,6,6,13,13,5,5,1})[i\1])
   flip()
  end
		
		for i=96*64,104*64,64 do
 		memset(i,0,16)
		end
		
		for i=104*64,128*64,64 do
 		memset(i+12,0,20)
		end
		
		n=0
		endingtimer=0
	 while true do
 		endingtimer+=1
	  n=min(50,n+1)
		 a=a and a*.9 or .25
		 if (a<.005) a=0
		 
		 xoff=8
		 yoff=yoff and (yoff*.9+.5) or 20
		 yoff=max(yoff,5.25)
		 
		 cls()
		 if endingtimer<100 then
			 ?"  thanks for playing\n\na game by julio maass\n    and bonevolt\n\n    total coins: ",20,90,({1,5,13,6,7})[n\5-5]
			 if n>=30 then
			  ?coins,88,120,({1,5,13,6})[n\5-5] or coins<100 and 7 or 8+tim%8
			 end
   elseif endingtimer<105 then print("  thanks for playing\n\na game by julio maass\n    and bonevolt\n\n    total coins: "..coins,20,90,7)
   elseif endingtimer<110 then print("  thanks for playing\n\na game by julio maass\n    and bonevolt\n\n    total coins: "..coins,20,90,6)
   elseif endingtimer<115 then print("  thanks for playing\n\na game by julio maass\n    and bonevolt\n\n    total coins: "..coins,20,90,13)
   elseif endingtimer<120 then print("  thanks for playing\n\na game by julio maass\n    and bonevolt\n\n    total coins: "..coins,20,90,5)
   elseif endingtimer<125 then print("  thanks for playing\n\na game by julio maass\n    and bonevolt\n\n    total coins: "..coins,20,90,1)
			else
			 if endingtimer<155 then textcolor=7 end
			 if endingtimer<150 then textcolor=6 end
			 if endingtimer<145 then textcolor=13 end
			 if endingtimer<140 then textcolor=5 end
			 if endingtimer<135 then textcolor=1 end
			 if endingtimer<130 then textcolor=0 end
				
	   if char==0 then
				 if endingmessage==1 then
				  print("   collect all coins to",12,84,textcolor)
				  print("   unlock mademouselle",14,92,textcolor)
     end
				 if endingmessage==2 then
				  print("mademouselle unlocked!",22,92)
     end
				 if coins==100 then
				 print("you got all coins!",28,84,textcolor)
					 print("  steps: "..savesteps..
					       "\ntime: "..(saveminutes\10)..(saveminutes%10)..":"..(saveclock\100%6)..(saveclock\10%10).."."..((10*saveclock\10)%10)
					       ,2,108,textcolor)
					 print("best: "..mousebeststeps100..
					       "\nbest: "..(mousebestminute100\10)..(mousebestminute100%10)..":"..(mousebestclock100\100%6)..(mousebestclock100\10%10).."."..((10*mousebestclock100\10)%10)
					       ,66,108,textcolor)
     else
					 print("  steps: "..savesteps..
					       "\ntime:  "..(saveminutes\10)..(saveminutes%10)..":"..(saveclock\100%6)..(saveclock\10%10).."."..((10*saveclock\10)%10)
					       ,2,108,textcolor)
					 print("best: "..mousebeststeps..
					       "\nbest: "..(mousebestminute\10)..(mousebestminute%10)..":"..(mousebestclock\100%6)..(mousebestclock\10%10).."."..((10*mousebestclock\10)%10)
					       ,66,108,textcolor)
     end
     
		   if endingtimer>155 then
			   if coins<100 then 
			    if savesteps==mousebeststeps then
				    ?mousebeststeps,90,108,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
			    if saveclock==mousebestclock and saveminutes==mousebestminute  then
				    ?(mousebestminute\10)..(mousebestminute%10)..":"..(mousebestclock\100%6)..(mousebestclock\10%10).."."..((10*mousebestclock\10)%10),90,114,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
			   end
			   if coins==100 then
			    if savesteps==mousebeststeps100 then
				    ?mousebeststeps100,90,108,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
			    if saveclock==mousebestclock100 and saveminutes==mousebestminute100  then
				    ?(mousebestminute100\10)..(mousebestminute100%10)..":"..(mousebestclock100\100%6)..(mousebestclock100\10%10).."."..((10*mousebestclock100\10)%10),90,114,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
						end
					end
	   end
	   
	   if char==1 then
				 if endingmessage==3 then
				  print("   collect all coins to",12,84,textcolor)
				  print("   unlock mousefredini",14,92,textcolor)
     end
				 if endingmessage==4 then
				  print("mousefredini unlocked!",22,92)
     end
				 if coins==100 then
				 print("you got all coins!",28,84,textcolor)
					 print("  steps: "..savesteps..
					       "\ntime: "..(saveminutes\10)..(saveminutes%10)..":"..(saveclock\100%6)..(saveclock\10%10).."."..((10*saveclock\10)%10)
					       ,2,108,textcolor)
					 print("best: "..girlbeststeps100..
					       "\nbest: "..(girlbestminute100\10)..(girlbestminute100%10)..":"..(girlbestclock100\100%6)..(girlbestclock100\10%10).."."..((10*girlbestclock100\10)%10)
					       ,66,108,textcolor)
     else
					 print("  steps: "..savesteps..
					       "\ntime:  "..(saveminutes\10)..(saveminutes%10)..":"..(saveclock\100%6)..(saveclock\10%10).."."..((10*saveclock\10)%10)
					       ,2,108,textcolor)
					 print("best: "..girlbeststeps..
					       "\nbest: "..(girlbestminute\10)..(girlbestminute%10)..":"..(girlbestclock\100%6)..(girlbestclock\10%10).."."..((10*girlbestclock\10)%10)
					       ,66,108,textcolor)
     end
		   if endingtimer>155 then
			   if coins<100 then 
			    if savesteps==girlbeststeps then
				    ?girlbeststeps,90,108,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
			    if saveclock==girlbestclock and saveminutes==girlbestminute  then
				    ?(girlbestminute\10)..(girlbestminute%10)..":"..(girlbestclock\100%6)..(girlbestclock\10%10).."."..((10*girlbestclock\10)%10),90,114,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
			   end
			   if coins==100 then
			    if savesteps==girlbeststeps100 then
				    ?girlbeststeps100,90,108,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
			    if saveclock==girlbestclock100 and saveminutes==girlbestminute100  then
				    ?(girlbestminute100\10)..(girlbestminute100%10)..":"..(girlbestclock100\100%6)..(girlbestclock100\10%10).."."..((10*girlbestclock100\10)%10),90,114,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
						end
					end
	   end

	   if char==2 then
				 if coins==100 then
				 print("you got all coins!",28,84,textcolor)
					 print("  steps: "..savesteps..
					       "\ntime: "..(saveminutes\10)..(saveminutes%10)..":"..(saveclock\100%6)..(saveclock\10%10).."."..((10*saveclock\10)%10)
					       ,2,108,textcolor)
					 print("best: "..icebeststeps100..
					       "\nbest: "..(icebestminute100\10)..(icebestminute100%10)..":"..(icebestclock100\100%6)..(icebestclock100\10%10).."."..((10*icebestclock100\10)%10)
					       ,66,108,textcolor)
     else
					 print("  steps: "..savesteps..
					       "\ntime:  "..(saveminutes\10)..(saveminutes%10)..":"..(saveclock\100%6)..(saveclock\10%10).."."..((10*saveclock\10)%10)
					       ,2,108,textcolor)
					 print("best: "..icebeststeps..
					       "\nbest: "..(icebestminute\10)..(icebestminute%10)..":"..(icebestclock\100%6)..(icebestclock\10%10).."."..((10*icebestclock\10)%10)
					       ,66,108,textcolor)
     end
		   if endingtimer>155 then
			   if coins<100 then 
			    if savesteps==icebeststeps then
				    ?icebeststeps,90,108,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
			    if saveclock==icebestclock and saveminutes==icebestminute  then
				    ?(icebestminute\10)..(icebestminute%10)..":"..(icebestclock\100%6)..(icebestclock\10%10).."."..((10*icebestclock\10)%10),90,114,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
			   end
			   if coins==100 then
			    if savesteps==icebeststeps100 then
				    ?icebeststeps100,90,108,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
			    if saveclock==icebestclock100 and saveminutes==icebestminute100  then
				    ?(icebestminute100\10)..(icebestminute100%10)..":"..(icebestclock100\100%6)..(icebestclock100\10%10).."."..((10*icebestclock100\10)%10),90,114,({1,5,13,6})[n\5-5] and 7 or 8+tim%8
						 end
						end
					end
	   end

	   --reset de fim de jogo
    if endingtimer == 300 then
     scr_frame=8
				end
    if endingtimer > 300 then
				 scr_frame=min(scr_frame-0.25,8)
				 for i=0,15 do
				  pal(i,sget(48+i,40-scr_frame))
				 end
    end
    if endingtimer == 330 then
     run()
				end

	   
		 end
		 tim+=1
		 for y=0,127 do
		  local a=a+.75
		  tline(0,y,127,y,
		  5+y/8*cos(a)-yoff*8*cos(a)/8-xoff*8*sin(a)/8,
		  59+y/8*sin(a)-yoff*8*sin(a)/8-xoff*8*-cos(a)/8,
		  sin(a)/8,-cos(a)/8
		  ,2
		  )
		 end

		 flip()
		 if btn(4) or btn(5) then cls() end
		end
 end
end

function draw_char(x,y,ox,oy,s,f)
 pal({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}) 
 for i=-1,1 do
  for j=-1,1 do
   if abs(i+j)==1 then
    if char == 0 then
     sspr(-16+s*16,40,12,12,x-2+i+ox,y-2+j+oy,12,12,f)
    end
   end
  end
 end
 pal()
 if char == 0 then
  sspr(-16+s*16,40,12,12,x-2+ox,y-2+oy,12,12,f)
 end
 palt(15,true)
 palt(0,false)
 if char == 1 then
  sspr(106,34,12,13,x-2+ox,y-3+oy,12,13,f)
 end
 if char == 2 then
  sspr(116,0,12,14,x-2+ox,y-4+oy,12,14,f)
 end
 palt(15,false)
 palt(0,true)
end
-->8
function paintblack()
 pipe={ //salvando pra depois dar respawn
	t=mget(playerx/8,playery/8),
 x=playerx/8,
 y=playery/8,
 }
 add(pipelist,pipe)
 local nextpiece = 1
 if level > 0 then
		if mget (playerx/8,playery/8)<64 then
		 if mget (playerx/8,playery/8)%16==4 then
		  mset(playerx/8,playery/8,58)
				while mget (playerx/8,playery/8+nextpiece)%16==9 do
     if (playery/8)\16 == (playery/8+nextpiece)\16 then
		    mset(playerx/8,playery/8+nextpiece,63)
					end
			  nextpiece += 1
				end
		 end
		 if mget (playerx/8,playery/8)%16==5 then
		  mset(playerx/8,playery/8,59)
				while mget (playerx/8,playery/8-nextpiece)%16==9 do
     if (playery/8)\16 == (playery/8-nextpiece)\16 then
			   mset(playerx/8,playery/8-nextpiece,63)
					end
			  nextpiece += 1
				end
		 end
		 if mget (playerx/8,playery/8)%16==6 then
		  mset(playerx/8,playery/8,60)
				while mget (playerx/8+nextpiece,playery/8)%16==8 do
     if (playerx/8)\16 == (playerx/8+nextpiece)\16 then
			   mset(playerx/8+nextpiece,playery/8,62)
		   end
			  nextpiece += 1
				end
		 end
		 if mget (playerx/8,playery/8)%16==7 then
		  mset(playerx/8,playery/8,61)
				while mget (playerx/8-nextpiece,playery/8)%16==8 do
     if (playerx/8)\16 == (playerx/8-nextpiece)\16 then
			   mset(playerx/8-nextpiece,playery/8,62)
				 end
			  nextpiece += 1
				end
		 end
		end
	end
end

function unpaint()
 for pipe in all(pipelist) do
	 local nextpiece=1
		mset(pipe.x,pipe.y,pipe.t)
  if pipe.t%16==4 then
			while mget (pipe.x,pipe.y+nextpiece)==63 do
    if (pipe.y)\16 == (pipe.y+nextpiece)\16 then
 	   mset(pipe.x,pipe.y+nextpiece,pipe.t+5)
			 end
			 nextpiece += 1
			end
  end
  if pipe.t%16==5 then
			while mget (pipe.x,pipe.y-nextpiece)==63 do
    if (pipe.y)\16 == (pipe.y-nextpiece)\16 then
 	   mset(pipe.x,pipe.y-nextpiece,pipe.t+4)
			 end
			 nextpiece += 1
			end
		end
  if pipe.t%16==6 then
			while mget (pipe.x+nextpiece,pipe.y)==62 do
    if (pipe.x)\16 == (pipe.x+nextpiece)\16 then
 	   mset(pipe.x+nextpiece,pipe.y,pipe.t+2)
			 end
			 nextpiece += 1
			end
  end
  if pipe.t%16==7 then
			while mget (pipe.x-nextpiece,pipe.y)==62 do
    if (pipe.x)\16 == (pipe.x-nextpiece)\16 then
 	   mset(pipe.x-nextpiece,pipe.y,pipe.t+1)
			 end
			 nextpiece += 1
			end
  end
		del(pipelist,pipe)
 end
end
__gfx__
000000007777cccccccccccc5d66d665babbb33b03b33310bbb1000000001bbb0000000003b33310550000000000005555555555ffffffffffffffffff0fffff
00000000c777777ccccccccc55d65d65babbb33b03b33310aaa1333333331aaa3333333303b333105003333333331005555d55ddffffffffffffffff0030ffff
000000007777777777cccc7766d11d66babbb33b03b33310bbb1bbbbbbbb1bbbbbbbbbbb03b333100033bbbbb333310055500000fffffffffffffff0dbbb000f
00000000cccccccc77777777d61111d61111111103b33310bbb1333333331bbb3333333303b33310033b33333b33331055000000f0000000000fff00bbbbbdd0
00000000cccccccccc77777c5d11115d03b3331011111111bbb1333333331bbb3333333303b3331003b3333333b3331055000000067777777760f0bbbbbb3ee0
00000000777cccccccccc7776611116603b33310babbb33b33313333333313333333333303b3331003b3333333b33310550000000677777767600b333bb5dee0
00000000777777ccccc77777d62211d603b33310babbb33b33311111111113331111111103b3331003b3331113b333105d000000067777776760f04eddd00d0f
00000000cc7777777777cccc5d22225d03b33310babbb33bbbb1000000001bbb0000000003b3331003b3331003b3331055000000067777776760f024ddddd50f
555555554451d444000000005555555589888228028222108881000000001888000000000282221003b3331003b3331055000050067777777760ff005ddd50ff
555d55dd4521444404444440555d55dd898882280282221099912222222219992222222202822210033b33333b333310550000dd0d66666666d0ff0d0666660f
555555dd2221522204544540555555dd8988822802822210888188888888188888888888028222100333bbbbb3333310550000dd0d56556556d0fff0777766d0
555555551111111104444440555555551111111102822210888122222222188822222222028222100333333333333310550000550d56566556d0ffff0cccc00f
555dd555d444445104444440555dd5550282221011111111888122222222188822222222028222100133333333333310550000550d56566566d0fff0d000d0ff
555dd5554444452104544540555dd5550282221089888228222122222222122222222222028222100013333333333100555005550d56556556d0ffff0fff0fff
5d55555552222221044444405d55555502822210898882282221111111111222111111110282221050011111111110055d5555550d66666666d0ffffffffffff
55555555111111100000000055555555028222108988822888810000000018880000000002822210550000000000005555555555f0000000000fffffffffffff
885555884451d4445555555555599555a7aaa99a09a99940aaa4000000004aaa0000000009a9994003b3331003b33310f7fffeef0efeee20fff2000000002fff
888d588845214444555d55dd5597a455a7aaa99a09a9994077749999999947779999999909a999403b3333103b333333f7fffeef0efeee207772eeeeeeee2777
5888888d22215222555500dd59799a45a7aaa99a09a99940aaa4aaaaaaaa4aaaaaaaaaaa09a99940b3333105b333333bf7fffeef0efeee20fff2ffffffff2fff
55888855111111115550000559a99a454444444409a99940aaa4999999994aaa9999999909a999403333105533333333222222220efeee20fff2eeeeeeee2fff
55888855d44444515550000559a94a4509a9994044444444aaa4999999994aaa9999999909a9994033331055333113330efeee2022222222fff2eeeeeeee2fff
58888885444445215550000559aaa94509a99940a7aaa99a99949999999949999999999909a9994033333105331001330efeee20f7fffeefeee2eeeeeeee2eee
88855888522222215d5000055549945509a99940a7aaa99a99944444444449994444444409a9994013333310110550110efeee20f7fffeefeee2222222222eee
8855558811111110555000055554455509a99940a7aaa99aaaa4000000004aaa0000000009a9994003b33310005555000efeee20f7fffeeffff2000000002fff
55500005555555550000005555555555c7cccddc0dcddd10ccc1000000001ccc000000000dcddd10d7ddd55d05d55510ddd1000000001ddd0000000005d55510
5550000d555d55dd000000dd555d55ddc7cccddc0dcddd107771dddddddd1777dddddddd0dcddd10d7ddd55d05d5551077715555555517775555555505d55510
5550000d555505dd000000dd555555ddc7cccddc0dcddd10ccc1cccccccc1ccccccccccc0dcddd10d7ddd55d05d55510ddd1dddddddd1ddddddddddd05d55510
55500005055000550000005555555555111111110dcddd10ccc1dddddddd1cccdddddddd0dcddd101111111105d55510ddd1555555551ddd5555555505d55510
555000050550005550000055555dd5550dcddd1011111111ccc1dddddddd1cccdddddddd0dcddd1005d5551011111111ddd1555555551ddd5555555505d55510
555500550550005555000555555dd5550dcddd10c7cccddcddd1dddddddd1ddddddddddd0dcddd1005d55510d7ddd55d55515555555515555555555505d55510
5d555555005000555d5555555d5555550dcddd10c7cccddcddd1111111111ddd111111110dcddd1005d55510d7ddd55d55511111111115551111111105d55510
555555550050005555555555555555550dcddd10c7cccddcccc1000000001ccc000000000dcddd1005d55510d7ddd55dddd1000000001ddd0000000005d55510
5559a555559999555559455555594555555aa555555a95550123456789abcdef000000000efeee20000000000000000000000000ffffffffffffffffffffffff
559997555999999555999455559994555557755555799955001122d64493d54eeeeeeeee0efeee20000000000000000000000000ffffffffffffffffffffffff
599999a5999999995999994555999255555aa55555a999550000115d22455554ffffffff0efeee20000000000000000000000000fffff00ffffffffffffff9ff
599999a5999999995999994555999255555aa55555a999550000001511211112eeeeeeee0efeee20000000000000000000000000ffff07700f00ffff00ffffff
599999a59999999959999925559992555559955555a999550000000100100001eeeeeeee0efeee20000077777777777777770000ffff0faaa0770fffaa0fffff
599999a59999999959999925559992555559955555a999550000000000000000eeeeeeee0efeee20000077777777777777770000fff09a99aaee0fff990ffff9
5599995559999995559991555599915555544555559999550000000000000000222222220efeee20000077777777777777770000fff0ac6669ee0fff870fffff
5559955555999955555925555559255555599555555995550000000000000000000000000efeee20000077777777777777770000fff0e877c7aa0fff8770ffff
000000000000111100000000000011114441699999426999aa956aaaffa47fff77f97777ffff9fff000077770000000077770000fff08877ee6a90ff87770fff
00dd44400000111100044dd00000111144214444445294449945a999aa94faaaffa97fffffffffff000077770000000077770000ffff0677760a90ff877770ff
0044244dd00011110dd444dd000011112221455555524555444594449994a999aaa9faaafffffff9000077770000000077770000fffff088820f0fff877770ff
0044444ee0001111edd444d5000011111112222222222222555555554444444499999999ffffffff000077770000000077770000ffff08888820ffff8777770f
0d0555dee0001111e5dddd5100001111d444445164444451699999427aaaaa957fffffa4ff9fffff000077770000000077770000fff0628882260fff7777770f
efddd0dd0000111105ddddd500001111444445214444452199999452aaaaa945fffffa94ffffffff000077770000000077770000ffff00d00d00ffff77777770
4eddddd5000011110ddddd55d0d0111152222221522222214555555294444445a9999994fffff9ff000077770000000077770000ffffff0ff0ffffff77777770
005ddd500000111100555550044d11111111111011111110222222215555555244444445ffffffff000077770000000077770000ffffffffffffffffdddd7770
0d03333900d011110003333944421111005555555d5dddddd6d666666767777777777777ffff777c000077777777777777770000fffffffffff0420ddddddd70
00bb9b33d44d11110dbb9b3304201111005d55ddd5d6dd666d6766777677777777777777f9f77777000077777777777777770000fff9fff9ff0442000000ddd0
0d0555504442111100055550d0001111005555dd5d5ddd66d6d666776767777777777777fff77777000077777777777777770000ffffffffff0420ffffff000f
000000d004201111000d0000000011110055555555dd5ddddd66d6666677677777777777fff77777000077777777777777770000ffffffffff0420ff9fffffff
11111111111111111111111111111111005dd5555d566dddd6d776666767777777777777ff7777cc000000000000000000000000ffffffffff0420ffffffffff
11111111111111111111111111111111055dd555d5d66ddd6d6776667677777777777777ff777ccc000000000000000000000000fffffffff0420fffffffffff
111111111111111111111111111111115d555555565dddddd7d666666767777777777777fff77ccc000000000000000000000000ffffffffff420fffffffffff
111111111111111111111111111111115555555555dd5ddddd66d6666677677777777777fff777cc0000000000000000000000009ffffffffffffffffffffff9
55555555555555555555555555555555445144444442444499949999aaa4aaaaaaa4aaaaccc7777ccccccccc000000000005550000005555ffff77ccffff9fff
555d55dd555d55dd555d55dd555d55dd45219444444294449994a999aaa4faaaaaa4faaacccc7777cccccccc000055d0000d5500055d55ddf9ff777cffffffff
500555dd005555dd000000dd000005dd2221999999926999aaa46aaafff47ffffff46fffccccc777777ccccc000055d0000555000555500dffff7777fffffff9
00005550000555500000000500000055111111112222222244444444444444444444444477777777777777cc000055500005550000000005fffff777ffffffff
0000d550000dd5000000000500000055d444445194444442a9999994faaaaaa4faaaaaa9777ccccccc7777770000d550000dd50000000005fffff77cff9fffff
0000d550000dd50000000005000005554444452194444442a9999994faaaaaa4faaaaaa9ccccccccccc77777500dd555005dd55000000055fffff77cffffffff
00000000000555000d5550050055555552222221699999926aaaaaa47ffffff46ffffff97cccccccccccc777555555555d5555555d5555559ffff777fffff9ff
000000000005550000005555005555551111111022222222444444444444444499999999777cccccccccccc7555555555555555555555555ffff7777ffffffff
1111b3111150511111501111505111111111111111111111114757575767677777771111111111111111111111111155555551d66ddddd111111111111777777
000000000000000000000000000000000000000000000000000000000000000077761111111111111111111111111555555216666dddddd11111111111677777
1131313111313111113132113131311111111111111111475757576767777787776111111111111111111111111155555521d66dddddddd5111111111766776d
00000000000000000000000000000000000000000000000000000000000000006771111111111111111111112444444444425ddddddddddd1114411177777661
113132311131321111313111313131621111313131313131313131315666768667771111111111111111124eeeee444444445ddddddddddd5444441177777611
00000000000000000000000000000000000000000000000000000000000000001677111111111111111124eeee44444444442555555dddd44444421117777d11
703131421142311111a34211313101c31111313131313131313131315666768611111111d6666d51111144444444444444222255555244444444221117776111
000000000000000000000000000000000000000000000000000000000000000011171116666666dd522224444444444424222222224444444422221177761111
1111111111111111111111111111111111113131313131313131313156667686711161d6ddddddd6d55522222222224444444444422222eeeee111117d111777
00000000000000000000000000000000000000000000000000000000000000007771116dd555555dddd55122224444444444444222222ee77eee111611117777
11313231113331111132311131b332111111313131313131313131315666768677771ddeeeeeee45dddd5551222222244422222222211ef77feee1d111177777
000000000000000000000000000000000000000000000000000000000000000077771deeeeeeeee445ddd55551112255511111155555eefffeeee11111177777
7031316311c2421111414011703131621111313131313131313131315666768677771deeeeeeeeeee45ddd5555555500055555555555eeefeeefe11111167777
000000000000000000000000000000000000000000000000000000000000000077611deeeeeeeeeeee45ddd55555000000555555dddd4eeeeeeee11117766777
11111111111111111111111111401111e3d3013131313131313131315666768676111deeeeeee44444444ddd55510660000ddddddddd54eeeeffe11177777776
000000000000000000000000000000000000000000000000000000000000000067711deeeeee44eeee4445ddd5500660000dddddddddd54eeee5111177777761
111111111111111111111111115011111111313131313131313131315666768616711d5eeeee4eeeeee444ddddd00011100dddddddddddd555221111777d6d11
000000000000000000000000000000000000000000000000000000000000000011661155eeeeeeeeee44445ddd510111d00dddddddddddd55552111117761111
7331316211525011115151313131311111113131313131313131313156667686111d11555eeeeeeeee44dddddddd0000001ddddddddddddd5555111177611111
000000000000000000000000000000000000000000000000000000000000000011116115555eeeeeee4dddddddddddddddddddddddddddd5555211176111111c
1132423111313111113131313241311111113131313131313131313156667686c1111111255555eee4ddddddddddddddddddddddddddddd555511161111111cc
0000000000000000000000000000000000000000000000000000000000000000cc1111d12255555eeedddddddddddddddddddddddddddd555521d1111111cccc
1111111111111111111111111111111111113131313131313131313156667686ccc111112221155555ddddddddddddddddddddddddddd5555511111111ccccc1
0000000000000000000000000000000000000000000000000000000000000000ccddc1112222211111dddddddd0ddddddddddddddddd5555521111111cccc111
713111503150521111535011b3313161111131313131313131313131566676861dddddc122222221111dddddddd01dddddddddddddd555552111111cccc111cc
0000000000000000000000000000000000000000000000000000000000000000dd5c5ddcc22222222215dddddddd10000dddddddd55555521111cccccc11cccc
d331113132313111113231113132316011113131313131313131313156667686dc1115dccc22222121155dddddddddddddddddd55555523331cccccc1cccccc6
0000000000000000000000000000000000000000000000000000000000000000dcccccddccccc222222255dddddddddddddddd55555233331cccc1cccccc6666
703111313131311111313111313131c3111111111111114555555565657575855ccccc5dcccccccccccc555dddddddddd555555552b3331ccccccccccc666666
000000000000000000000000000000000000000000000000000000000000000066ccccc5dcccccccccccc55555555555555555523bbbb3cccccccccc66666666
111111a311414311114142114142a311111111111111111111455555556565756666ccc555dccccccccccc255555555555552233bb9bb3ccccccc6666666cccc
0000000000000000000000000000000000000000000000000000000000000000666666ccf755ccccccc3333222255552222233bbb99b3333ccc666cccdddddd6
ffffffff778888880000000055555555475767f7f7f7f7f7f7f7f7f796a797a7ccc6666777ee4ccc3333bbb33322222223333b99a999b3333cccccccddddddd6
ffffffff7888888800000000555d55dd0000000000000000000000000000000066cccceff7ffee4d553bbbbb33333333333bbbbaaaabb33b33cccc6ddddd555d
ffffff9f8888888800000000555000005767f7f7f7f7f7f7f7f7f7f7e72010206666cef4e7f444ddd55bbb944333333bbbbbbbb9aaabbbbbb3c6666ddddd555d
ffffffff222288880000000055000000000000000000000000000000000000006666e4444f744dddd533b9443bbbbb999bbbbbb9b99bbbbbbbb366ddddd55555
fffffff02222248800000000550000009595953e0cf495959595959596a797a7666ef4444ef44dddddddddd5443bbb9a999bbbbbbb9bbbb99b3366ddddd55555
f000000022222448000000005550000000000000000000000000000000000000666f444444ee45dddddddddd44bbbbaaa9bbbbbbbbbbbbb9993336ddddd55555
077777780022442d000000005d5555009595953f1cf5959595959595e72010206694444444ef445ddddddddddbbb99aaa99bbbbbbbbbb9994443365dddd55555
77778888ff00442d00000000555555000000000000000000000000000000000069444444444f44255dddddddd5bbbba9999bbbb99b9bbb44499b33555dd55555
0000000000000000000000005555550095959595e6f69595953e0cf496a797a7e4444444444e4445ddddddddd533bba9bbbbbbb9999b3bb9b994335555555555
000000000000000000000000555d550000000000000000000000000000000000444444444444f445ddddddddd53bbb99bbbbb9aaa9bbbbb9bb44322555555552
000000000000000000000000555555009595959595959595953f1cf5e7201020444444eee444e4455ddddddd5233bbbbbbbbbbaaa99bbbbbbbb2222255555526
000000000000000000000000555555000000000000000000000000000000000044444444ee44444255d55ddd5333bbbbbbbbbbaa999bbbbbb332222225555566
a4b4b4b4b4b4b4b4b4c40000555dd5009595959595959595d4e4e6f696a797a7444e44444e44444225555555533bbbbbb9bbbb99b99bbbbb3222222666666666
000000000000000000000000555dd55000000000000000000000000000000000444444444e44444442555555333bbbb999bbbbbbbbbbbb332222777776666666
a58898a8b8c8d8e8f8c500005d5555559595959595959595d5e59595e72010202442444444e444444422211131b3bbb9444bbbbbbb3333322227777777777777
00000000000000000000000055555555000000000000000000000000000000002442444444444444d4444441333322222222222222222222222aaaa777777777
a58999a9b9c9d9e9f9c50000ffffffff95959595959595959595959596a797a72242244444444444d444444413222222222255555555222222aaaaaaaaaaa777
000000000000000000000000ffffffff0000000000000000000000000000000072442444442444444d4444441222222225555555555555222aaaaaaaaaaaaaaa
a58a9aaabacadaeafac50000fffffff9959595959595959595959595e7201020a2442244222444444dd222442222222255555555555555529a9a9aaaaaaaaaaa
000000000000000000000000ffffffff00000000000000000000000000000000a2444242244444444dd222222222222555555555555552999999a9a9a9aaaaaa
a58b9babbbcbdbebfbc50000ffffffff95959595959595953e0cf49596a797a7a22442244444444ddd222222222552225555555552229999499999999a9a9a9a
0000000000000000000000009fffffff00000000000000000000000000000000a9244444444444dd2244442155555555555555222949949499949999999999a9
a58c9cacbcccdcecfcc50000fffffff09595959595d0e0f03f1cf595e72010209a24444444444d22444444155555555552222949444444444449499949999999
000000000000000000000000fffff00700000000000000000000000000000000a91244444444424444422125dddddd5522444444444444444444444499494999
a58d9dadbdcdddedfdc50000ffff07779595959595d1e1f195e6f69596a797a79992444444422444442122255dddd55224444444222224444444444444449999
000000000000000000000000fff0dddd00000000000000000000000000000000999124444424444421999222555dd55444444222222222222444444444444499
a58e9eaebecedeeefec50000ffff0ddd959595959595959595959595e72010209999222244442211944442555dddddd522222222222222222244444444444949
000000000000000000000000fffff0d20000000000000000000000000000000099999122411444444444255ddddddddd52222222222222222444444444449499
a58f9fafbfcfdfefffc50000ffffff025565f7f7f7f7f7f7f7f7f7f796a797a79999999494444444444455dddddddddd52222222222244444444444444994999
000000000000000000000000f9fffff00000000000000000000000000000000099999499444444444444255ddddddddd52244444444444444444494999499999
a6b6b6b6b6b6b6b6b6c60000ffffffff455565f7f7f7f7f7f7f7f7f7e72010209999994444444444444422555ddddd5544444444444444444494949949999999
000000000000000000000000ffffffff000000000000000000000000000000009999499444444444444442255555555444444444444449494949499999999999
__gff__
000000004444848401010000000101010201010048488888010100000001010100010000505090900101000040408080000000006060a0a0010140408080010100000000000000000101020202010101000000000101010100000202020101010000000000000000000002020200010100000000010101010100000000000001
0000000000000000020202020202020200000000000000000202020202020202000000000000000002020202020202020000000000000000020202020202020201010000000000000202020202020202000000000000000002020202020202020000000102000000020202020202020200000001000000000202020202020202
__map__
1111111111111111111111111111111111111109111109111109111149111111111111091111091111091111091111111111110911110911110911110911111111111119111119111119111119111111111111091111491111091111091111111111110911111911110911111911111111111111091111111111111109111111
111111111111111111111111111111111111110511110511110511112d1111111111110511110511110511110511111111111105111105111109111105111111111111151111151111151111151111111111110511112d1111051111051111111111110511111511110511111511111111111111091111111111111105111111
1111131313131313131313131313111111111313131313131113131333111111111113131313131113131113131311111111131313111313130913111311111111111313131313131113111113131111111123131113331311131313131311111111131313131313131313111313111111111313051313131113131313131111
11031313131313132313231323332e480807131313131313111313131123060808071313231313111313111313130608080713231311131313091311131306081817131313231313111311112313161818171313111313131113132313131618181713131313131323131311131306083e3d1013131313131113131313131111
111113131313131313131313131311113e3d1013131313131111111111111111111113131313131113131111111111111111131313111313130913111323111111111313131313131113111111111111111111111113131311131313131311111111131313131313131313112313111111111313131313131113231313131111
1111111111111111111111111111111111111313131313131113131313131111111111111111111113131113131311111111111104111323130513111313111111111111111111111113111111111111111113131113131311111111111111111111111111111111131313111313111108071313131316121113131313131618
111111111111111111111111111111110807131313131313111313131313060808071313131313132313111313130608482f33130911131313131311111121111121131313131313111313131313161818171313111313131313131313131618482f331313131612121713111313211111111313131313191112181713131111
11130a0706120704040a07040413111111111111111111111113132313131111111113131313131313131113131311111111131309111313131313111313111111111313131313131113131313103c3e3e3d10131113131323131313131311111111131323131312121313111313111111111306080808120812080807131111
11131a0b13091309090913122a13111111111111111111111113131313131111111111111111111111111113131311111111130612080808080808080713111111111313131313131113131313131111111111111111111111111111111111111111131313131312121111111111111111111111111111191119111111111111
1113061b1305131a1b1a070505131111080713131313131311131313131306080807132313111313131311131313060811111111091313131313131313131111482f3313131323131113131313131618181713131313131313131311131316181817131313130612120713131313060811111313131313191112181713131111
111313220c3113c3737071721313111111111313131313131111111111111111111113131311132313131113131311111111131105131323130413131313111111111313131313131111111111111111111113131313131313131311131311111111111111111111131313131313111111111313131316121113131313131618
111313301c3213d3647b7c7d1313111111111313132313131113131313131111111111111111131313131113131311111111131113131313130911111111111111111111111313131113131313131111111113132313132313131311231311111111131313131311131313231313111111111313132313131113231313131111
110a070a070413040a070a0b0a07111108071313131313131113132313130608482f33131311131313131113131321110807131111111111110913131313060818171323111313131113132313131618181713131313131313131311131316180807131313131311131313131313161811111313131313131113131313131111
111a0b12070904091207122a1a0b1111111113131313131311131313131311111111131313111313131311101313111111111313231313131309131313103c3e11111313111313131113131313131111111113131313131313131311131311111111131313101311131313131313111111111313041313131113131333131111
11061b1a071a2b1b1a070505061b11111111110411110411110411112111111111111104111104111104113a0411111111111104111104111109111104111111111111141111141111141111141111111111110411112111110411110411111111111114113a041111141111041111111111112109111411111411112c111111
111111111111111111111111111111111111110911110911110911111111111111111109111109111109113f0911111111111109111109111109111109111111111111191111191111191111191111111111110911111111110911110911111111111119113f0911111911110911111111111111091119111119111149111111
1111112911112911112911112911111111111111291129111149112911111111111119112911291111291129110911111111191129110911112911291109111111113911391139111139113911391111111119112911091111091129111911111111111111111111111111391111111111111111111111111111291111111111
111111251111251111251111251111111111111125112511112d112511111111111115112511251111251125110511111111151125110511112511251105111111113511351135111135113511351111111115112511051111051125111511111111111111111111111111351111111111111111111111111111251111111111
1111131313111313131311131313111111111313131313111333111313131111111113111313131113131313131311111111132313111313131311132313111138371311131313131313111323133638383713131313131311131313111336381111131313111313131313131313111108071313111313131113131323130608
2827131313111313131311131313262811111323131313111313111323131111111123111323131113131323131311111111111111111111111311111111111111112311131323131313111111111111111111111111112311131313111311111111131313111313111713231313111111111313111313161113041313131111
1111132313111313131311132313111128271313131304111314111313132628282713111313131113131313131326281817131313131311111313131313060838371311131313341111111113133638383713131313111311132313111306083837332e1111111111111111111111113e3d1013112313131111111111111111
1111131313111313131311131313111111111111111111111311111111111111111111111111111111111111111111113e3d101313131311111313231313111111111111111111111113231123131111111113132313113411341313111311111111131315112313111313151113111111111313111313131113231137131111
2827131306111313231311171313211128271313131113131313131313132628282713332e11271313061121131326282827131313131311111313131313262838371313332e1113131321111313363818171313332e111111112111111316183e3d101313111304111323131113111108071316111304131104131107130608
1111131313111313131311131313111111111323131113132313131313131111111113131311131323131113131311111111111111111111111111111111111111111313131311111324113713131111111111111111111111113713231311111111131313111311113713131123111111111111111111111111111123131111
111111111111131313131113131311111111131313111313131311111111111111111111111111111111111313231111111111111111111111111111111111111111131323132511111111111111111111111323133611111111111111111111111111111111111111111111111311110807132111131113131113112f330608
482f331306111313131311171313262828271313131113131313111313132628282713131311171313061113131326282827131313131311111313131313161838371313131313113713132313133638080713111111111111113713131336381111132313111305151313111313111111231326111325231325131111111111
1111131313111313131311131313111111111311111111111111111313131111111113131311131313131111111111111111131313231311111313231313111111111111111111111111111111131111111113111313351135111323131311111111130608111313131313110713111108071326111313131313131113130608
1111132313111313111111111111111128271311131305131305111313132628282713131311131313131113131326280807131313131311111313131313262838371313131113051513131311133638282713111323131113111313131316181111111111111313231313112113363811111111111111111113111123131111
282713131311131311131313131326281111131113131323131311131313111111111323131113131313111323131111111111111111111111111111111111113e3d10131311131313132313111311113e3d10111313131123111111111111111111131513111313111713111513111108071323112313161113351113130608
1111131313111313111313101313111111111311131313131313111313103c3e1111131313111313101311131313111111211323131313111113131323332e4838371313131113131313131311133638181713111313131113131313131336381111231313111313131313111313111128271313111313131113131113131618
11111124111124111124113a241111111111111124112111112411241111111111111411241124113a241124110411111111141104112411110411241124111111113411341134111134113411341111111134110411141111241104111411111111111134111111111111111111111111111111111411111111041111111111
11111129111129111129113f291111111111111129111111112911291111111111111911291129113f291129110911111111191109112911110911291129111111113911391139111139113911391111111139110911191111291109111911111111111139111111111111111111111111111111111911111111091111111111
__sfx__
0002000025320253402534025340253402e3402e3402e3402e3402e3402e3402e3402e3322e3322e3222e3222e3122e3122e3122e3122e3002e30000000000000000000000000000000000000000000000000000
000200000d0400d0401b0401d0301d030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001f0701f0701f0701a0701a0701a0701407014070140701f0701f0701f0701a0701a0701a0701407014070140700000000000000000000000000000000000000000000000000000000000000000000000
000300001707017070170701c0701c0701c0702107021070210701907019070190701f0701f0701f0702307023070230701c0701c0701c0702107021070210702507225072250722506225052250422503225000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0130000029500295002950029500295002950029500295002950029500295002b5002b5002b5002b5002b5002b5002b5002b5002b5002b5002950029500295002950029500295002950029500295002950029500
010c00200424000000042400444004240000000424004440042400000004240044400424000000042400444006240000000624006440062400000006240064400224000000022400244002240000000224002440
010c00200024000200002400044000240002000024000440002400020000240004400024000200002400044006240002000624006440062400020006240064400224000200022400244002240002000224002440
011800201c420104201c400104201e420124001f420134201e420114001c4201e4201c4001c420214001c4201f4201a40023400214201f420184001e4201c4001f4201a420214201e400214201f4001c4201a420
0106002009433094030940309403094330940309433094030c6530940309403094030943309403094330940309433094030940309403094330940309433094030c65309403094030940309433094030943309403
010300201843130431184312f431184312d431184312b4311843129431184312843118431264311843124431244310c431234310c431214310c4311f4310c4311d4310c4311c4310c4311a4310c431184310c431
01180020093300933000000093300c330093300b3300b33000000093300c330093300b330000000733008330093300933000000093300c330093300b3300b3300000009330103300e3300c330000000e3300c330
011800201d420184201f4201842021420184201f420184201d420184201f4201842021420184201f420184201f4201a420214201a420234201a420214201a4201f4201a420214201a420234201a420214201a420
01180020053400534000000053400b340053400c3400c34000000053400c340053400b340045000534006347073400734000000073400c340073400e3400e34000000073400c3400734010340000000e3400c340
013000001d2001c2001d2261c2001c2001d2001c2001d2261d2001f2001d2261f2001f2001d2261f2001d2261d200212001d226212001d200212261d200212001f200232001f226232001f200212001f22623226
010300201707017070170701c0701c0701c0702107021070210701907019070190701f0701f0701f0702307023070230701c0701c0701c0702107021070210702507225072250722506225052250422503225000
011a00001c322183221c3221d3221d3221c3221c322183221a3221d322213221f3221f3221d3221d3221f3221a3221d322213221f3221f3221d3221d3221f322213222132222322213221f3221f3221d3221f322
011a00002132221322213222132221322213221d3221f3222132222322213221f3221f3221d3221d3221f3222132221322213222132221322213221d3221f322213222232224322223222232221322213221f322
010d00200527300000000000000005673000000527300000000000000005673000000567300000052730000005273000000000000000056730000005273000000000000000056730000005673000000567305673
011a00001c3221c3221c3221c3221c322173221d322173221f322173221d322173221c322173221a322173221c3221c3221c3221c3221a3221a3221a3221c3221c3221f3221f3221f3221832218322183221a322
001a000021320183201d3201832021320183201d3201832021320183201d3201832021320183201d3201832021320193201c3201932021320193201c3201932021320193201c3201932021320193201c32019320
001a0000213221f3221d32218322183221832218322183221832218322183221832218322183221832218322213221f3221d3221a3221a3221a3221a3221a3221a3221a3221a3221a3221a3221a3221a3221a322
001a000018322183221832218322000000000000000000000000000000000000000000000000000000000000173221a3221d3221732215322183221c32217322173221a3221a3221a32218322183221832200000
001a0020213201b3201e3201b320213201b3201e3201b320213201b3201e3201b320213201b3201e3201b3201e320173201b320173201e320173201b320173201e320173201b320173201e320173201b32017320
001a00001e3221e3221e3221e3221e3221e32221322233222432223322213221f3221f32221322213221f3221e3221e3221e3221e3221e3121e3121e3121e3120000000000000000000000000000000000000000
001a00001c3201432017320143201c3201432017320143201c3201432017320143201c3201432017320143201c3201532018320153201c3201532018320153201c3201532018320153201c320153201832015320
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 0e 42 43 44
00 09 0f 0d 44
01 09 0f 0d 0c
00 09 11 0d 10
00 09 0f 0d 44
02 09 11 0d 12
00 41 42 43 44
01 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
01 41 42 43 44
00 41 42 43 44
01 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 13 42 43 44
01 14 16 43 44
00 14 16 43 44
00 15 16 18 44
00 17 16 1d 44
00 14 16 43 44
00 14 16 43 44
00 15 16 18 44
02 1c 16 1b 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
