pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- debris
-- by donswelt

 cartdata("donswelt_debris_v1") 
 hiscore=dget(0)
 tries=dget(1)

function _init()

stars={}
bullets={}
tangos={}
debris={}
projectiles={}
particles={}
bossalien={}
score=0
wrote=0
-- reset hiscore
-- hiscore=1000
-- dset(0,hiscore)
music(0)
cls()

hitzone={
x=0,
y=0,
update=function(self)
self.x=player.x+6
self.y=player.y+6
end,
draw=function(self)
  pset(self.x,self.y,9)
end
}

player={
 	x=56,
 	y=128,
 	speed=2,
 	sp=44,
 	update=function(self)
 	
 	if explode==0 then
 		if btn(0) and self.x>1 then
 			self.x-=self.speed
 			self.sp=42
 		elseif btn(1) and self.x<114 then
 			self.x+=self.speed
 			self.sp=46
 		else
 		 self.sp=44
 		end
 		
 		if btn(3) and self.y<112 then
 			self.y+=self.speed
 		elseif btn(2) and self.y>1 then
 			self.y-=self.speed
 		end
 	
 		if btn(5) then
 		 sfx(0)
 		 fire()
 		 self.speed=1
 		else
 		 self.speed=2
 		end
 		
 	else
 	 player.y-=1
 	 if player.y<=90 then
 	  player.y=90
 	  explode=0
 	 end 
 	end
 	 		 	
 	end,
 
 draw=function(self)
  	spr(self.sp,self.x,self.y,2,2)
 end
}

 titleinit() 
  
end

 -----------------------------!

 function _update60()
  if (mode==0) then
   titleupdate()
   elseif (mode==2) then
    overupdate()
  elseif (mode==3) then
    pawupdate()
   else
    gameupdate()
  end
 end

 -----------------------------!
 -- update
 -----------------------------!

 function titleupdate()
 
  if hiscore==0 then
   hiscore=1000
  end
  
 	if btnp(4) and coin==0 then
 	 music(-1)
 	 sfx(18)
 	 coin=1
 	end

 	if btnp(3) then
   pawinit()
 	end
  
  if coin==1 then
   coinup+=1
    if coinup>50 then
   	 gameinit()
    end
  end
    
  tt+=1
   if tt>=8 then
    tt=0
    add_star()
   end

  for s in all(stars) do
 	 s.y+=s.speed
 			if s.y>128 then
 				del(stars,s)
 			end
	 end

  press()
 	  
 end

 -----------------------------!

 function overupdate()
		
		if btnp(4) then
		 music(0)
		 titleinit()
		end
		
		if tries>=20 and wrote==0 then
		 wrote=1
		 dset(13,1)
  end
  
  tt+=1
   if tt>=8 then
    tt=0
    add_star()
   end

  for s in all(stars) do
 	 s.y+=s.speed
 			if s.y>128 then
 				del(stars,s)
 			end
	 end

  press()
 
 end
 
 -----------------------------!
 
 function gameupdate()
  
  if bossdone!=1 then
  times=120-flr(time()-timesup)
   if times<0 then
     whatover="time over"
     gameover=1
     --pawchievement
     set(11,1)
   		--

     overinit()
   end
  end

  if times<31 and bossactive==0 then
   bossactive=1
   boom=1
   tt=0
		 --pawchievement
		 if fired==0 then dset(16,1) end
   --
   add_bossalien()
  end
  
  -- no damage after respawn
  blinking-=1
   if blinking<=0 then
    blinking=0
   end
   
  tt+=1
  if tt>=8 then
   tt=0
   boom=0
   add_star()
  end
  
  for s in all(stars) do
 	 s.y+=s.speed
 			if s.y>128 then
 				del(stars,s)
 			end
	 end
	 
	 for p in all(projectiles) do
 	 p.x+=p.xs
 	 p.y+=p.ys
 	  
 	  if boom==1 then
 				del(projectiles,p)   
 	   add_coin(p.x+-2,p.y-2)
 	  end
 	  
 			if p.y>128 or p.y<-8 or p.x>128 or p.x<-8 or bossdone==1 then
 				del(projectiles,p)
 			end
 				if hitzone.x>p.x and hitzone.x<p.x+4 and hitzone.y>p.y and hitzone.y<p.y+4 and blinking==0 then
      sfx(1+flr(rnd(3)))
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
      explode=1
      blinking=100
      bonus=10
      anim=0
      player.x=56
      player.y=128
      sfx(6)
      del(projectiles,p)
      life-=1
       if life==2 then
        lifeosd="‡‡"
       elseif life==1 then
        lifeosd="‡"
       else
        lifeosd=""
       end
       if life<0 then
        survived=flr(time()-timesup)
         if survived==0 then
          survived=120
         end 
      		 --pawchievement
      		 if survived>=90 then dset(11,1) end
   		    --
        gameover=1
        overinit()
       end  
     end
	 end
	
	 for b in all(bullets) do
 		b.y-=b.speed
 			if b.y<0 then
 			  del(bullets,b)
 			end
  end
  
  for pa in all(particles) do
   pa.x+=pa.sx
   pa.y+=pa.sy
   pa.i+=1
    if pa.i>20 then
     del(particles,pa)
    end
  end
  
  for d in all(debris) do
   d.y+=d.speedy
   d.speedy+=d.addspeedy
    if d.y>128 then
     del(debris,d)
    end
	 end

  for co in all(coins) do
   co.y+=co.speed
   co.speed+=.05
   
   co.i+=1
    if co.i>10 then
     co.i=0
     co.sp+=1
      if co.sp>143 then
       co.sp=140
      end
    end
    
    if co.x+4<hitzone.x and player.speed==2 then
     co.x+=1
     elseif co.x+4>hitzone.x and player.speed==2 then
     co.x-=1
    end
    
				if hitzone.x>co.x-1 and hitzone.x<co.x+9 and hitzone.y-1>co.y and hitzone.y<co.y+8 then
     score+=75
     sfx(20)
      
	     if score>32000 then
	      score=32000
	     end
	     -- pawchievement
	     if score>=7500 then dset(14,1) end
		    --
		    if score>hiscore then
		     hiscore=score
		     dset(0,hiscore)
		    end
     del(coins,co)
    end
    
    if co.y>128 then
     del(coins,co)
    end
	 end
	 
  -- all the tangos!
  timer+=1
  if timer>=25 then
    i+=1
     if i>45 then
		    maxspeed+=1
		     if maxspeed>3 then
		      maxspeed=3
		     end
		    i=0
	    end
    timer=0
    if bossactive==0 then
     add_tango()
     tangowave+=1
      if tangowave>=8 then
       tangowave=0
       tangotype=flr(rnd(4))
       timer=-250
       tangostart_x=flr(rnd(110))+5
      end
    end
  end

	 for t in all(tangos) do
	  
	  -- they're shooting now!?
	  shottimer+=1
	  if shottimer>shotamount and t.move!=99 then
	   shottimer=0
	    if shotamount>100 then
	     shotamount-=2
	    end  
	   if t.sp==10 then

	    -- always target the
	    -- player. beware
	    -- of my math!
	    if t.x>=player.x then
	     distancex=t.x-player.x
	    else
	     distancex=player.x-t.x
	    end
	    if t.y>=player.y then
	     distancey=t.y-player.y
	    else
	     distancey=player.y-t.y
	    end
	   
	    if distancex>distancey then
	     prozenty=distancey*100/distancex
	     prozentx=100
     else
	     prozentx=distancex*100/distancey
	     prozenty=100
	    end
	  
	    if t.x>player.x then
	     t.xs=-((1/100)*prozentx)
	    else
	     t.xs=((1/100)*prozentx)
	    end
	    if t.y>player.y then
	     t.ys=-((1/100)*prozenty)
	    else
	     t.ys=((1/100)*prozenty)
	    end
	   add_projectiles(t.x+6,t.y+4,t.xs,t.ys,48)
	   sfx(0)
   elseif t.sp==36 and t.y<90 then
	   sfx(0)
	   add_projectiles(t.x+8,t.y+8,1,0,49)
	   add_projectiles(t.x+8,t.y+8,.75,.75,49)
    add_projectiles(t.x+8,t.y+8,0,.85,49)
	   add_projectiles(t.x+8,t.y+8,-.75,.75,49)
    add_projectiles(t.x+8,t.y+8,-1,0,49)
	   add_projectiles(t.x+8,t.y+8,-.75,-.75,49)
    add_projectiles(t.x+8,t.y+8,0,-1,49)   
	   add_projectiles(t.x+8,t.y+8,.75,-.75,49)
   else
  end
 end
   	 
	  -- moving right
	  if t.move==0 then
	   t.x+=t.speed
		   if t.x>112 then
		    t.x=112
		    t.move=1
		   end
	  -- moving down
	  elseif t.move==1 then
	   t.y+=1
	    if t.y>80 then
	     t.move=99
	    end
	   t.shift+=1
		   if t.shift>16 then
		    t.shift=0
		     if t.x<64 then
		      t.move=0
	 	    else
	 	     t.move=2
	 	    end
	 	   end 	 
		 -- moving left
		 elseif t.move==2 then
	   t.x-=t.speed
		   if t.x<2 then
 	    t.x=2
 	    t.move=1
 	   end
 	 -- moving down and out
 	 elseif t.move==3 then
	   t.y+=t.speed
	   t.x+=t.xs
	    if t.y<-24 then
 	    del(tangos,t)
 	   end
 	  t.speed-=t.ys
 	 -- random position on x
 	 elseif t.move==11 then
 	  t.x=flr(rnd(110))+2
 	  t.diff=flr(rnd(40))
 	  t.move=12
 	 -- moving down to center
 	 elseif t.move==12 then
    if t.y<(38+t.diff) then
 	   t.y+=1
 	  else
     sfx(0)
	    add_projectiles(t.x+8,t.y+8,1,0,49)
	    add_projectiles(t.x+8,t.y+8,.75,.75,49)
     add_projectiles(t.x+8,t.y+8,0,.85,49)
	    add_projectiles(t.x+8,t.y+8,-.75,.75,49)
     add_projectiles(t.x+8,t.y+8,-1,0,49)
	    add_projectiles(t.x+8,t.y+8,-.75,-.75,49)
     add_projectiles(t.x+8,t.y+8,0,-1,49)   
	    add_projectiles(t.x+8,t.y+8,.75,-.75,49)
     t.move=13
    end
 	 elseif t.move==13 then
 	  t.pause+=1
 	   if t.pause>80 then
 	    t.pause=0
 	    t.move=14
 	   end
 	 -- moving up and out
 	 elseif t.move==14 then
	   t.y-=1
	    if t.y<-24 then
 	    del(tangos,t)
	    end
 	 -- random position on y
 	 elseif t.move==21 then
 	  t.x=-24
 	  t.y=flr(rnd(64))
 	  t.diff=flr(rnd(40))
 	  t.move=22
 	 -- moving down to center
 	 elseif t.move==22 then
 	  if t.x<(48+t.diff) then
 	   t.x+=1
 	  else
     sfx(0)
     add_projectiles(t.x+8,t.y+8,1,0,49)
	    add_projectiles(t.x+8,t.y+8,.75,.75,49)
     add_projectiles(t.x+8,t.y+8,0,.85,49)
	    add_projectiles(t.x+8,t.y+8,-.75,.75,49)
     add_projectiles(t.x+8,t.y+8,-1,0,49)
	    add_projectiles(t.x+8,t.y+8,-.75,-.75,49)
     add_projectiles(t.x+8,t.y+8,0,-1,49)   
	    add_projectiles(t.x+8,t.y+8,.75,-.75,49)
     t.move=23
    end
 	 elseif t.move==23 then
 	   t.pause+=1
 	    if t.pause>80 then
 	     t.pause=0
 	     t.move=24
 	    end
 	 -- moving up and out
 	 elseif t.move==24 then
 	   t.x-=1
 	    if t.x<-24 then
  	    del(tangos,t)
 	    end
 	 -- random position on y
 	 elseif t.move==31 then
 	  t.x=128
 	  t.y=flr(rnd(64))
 	  t.diff=flr(rnd(40))
 	  t.move=32
 	 -- moving down to center
 	 elseif t.move==32 then
 	  if t.x>(80-t.diff) then
 	   t.x-=1
 	  else
 	   sfx(0)
     add_projectiles(t.x+8,t.y+8,1,0,49)
	    add_projectiles(t.x+8,t.y+8,.75,.75,49)
     add_projectiles(t.x+8,t.y+8,0,.85,49)
	    add_projectiles(t.x+8,t.y+8,-.75,.75,49)
     add_projectiles(t.x+8,t.y+8,-1,0,49)
	    add_projectiles(t.x+8,t.y+8,-.75,-.75,49)
     add_projectiles(t.x+8,t.y+8,0,-1,49)   
	    add_projectiles(t.x+8,t.y+8,.75,-.75,49)
     t.move=33
    end
 	 elseif t.move==33 then
 	   t.pause+=1
 	    if t.pause>80 then
 	     t.pause=0
 	     t.move=34
 	    end
 	 -- moving up and out
 	 elseif t.move==34 then
 	   t.x+=1
 	    if t.x>128 then
  	    del(tangos,t)
 	    end
 	 -- falling down as debris
 	 elseif t.move==99 then
	   t.y+=t.speed
	   t.speed+=.05
	    if t.speed>fallspeed then
	     t.speed=fallspeed
	    end
		   if t.y>128 then
 	    del(tangos,t)
 	   end
   end
	 
	  -- danger close!   	 
	  if hitzone.x>t.x+3 and hitzone.x<t.x+13 and hitzone.y>t.y+4 and hitzone.y<t.y+12 and blinking==0 then
      sfx(1+flr(rnd(3)))
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
      explode=1
      blinking=100
      player.x=56
      player.y=128
      bonus=10
      anim=0
      sfx(6)
      del(tangos,t)
      life-=1
       if life==2 then
        lifeosd="‡‡"
       elseif life==1 then
        lifeosd="‡"
       else
        lifeosd=""
       end
       if life<0 then
        survived=flr(time()-timesup)
         if survived==0 then
          survived=120
         end
      		 --pawchievement
      		 if survived>=90 then dset(11,1) end
   		    --
        gameover=1
        overinit()
       end  
   end
   
   for b in all(bullets) do
 	  if b.x>=t.x-1 and b.x<t.x+14 and b.y>=t.y and b.y<t.y+12 then
    	add_debris(b.x,b.y)
    	
    	if t.move==99 then
    	 bonus+=.2
    	 --pawchievement
      if bonus>=200 then dset(15,1) end
   		 --
    	  if flr(bonus%50)==0 then
    	   boom=1
    	   tt=1
    	   sfx(21)
    	  end
    	 anim=120
    	 t.speed=0
    	 sfx(5)
    	else
    	 sfx(4)
    	end
    	
 	   del(bullets,b)
 	   t.damage+=1
 	    if t.damage==10 then
 	     t.state=2
 	    end
 	   t.x+=flr((-1+rnd(3)))
 	   t.y-=1
 		   if t.y<3 then
 		    t.y=3
 		   end
   		if t.damage>t.maxdamage and t.move!=99 then
   		 sfx(1+flr(rnd(3)))
   		 
      add_coin(t.x+4,t.y+4)
   		 
   		 add_particles(t.x+8,t.y+8)
   		 add_particles(t.x+8,t.y+8)
   		 add_particles(t.x+8,t.y+8)
   		 add_particles(t.x+8,t.y+8)
   		 add_particles(t.x+8,t.y+8)
   		 add_particles(t.x+8,t.y+8)
   		 add_particles(t.x+8,t.y+8)
 		   t.move=99
 		   t.state=4
 		   t.speed=0
 		   score+=flr(bonus)
 		    add_bonus(t.x+6,t.y,flr(bonus))
 		     if score>32000 then
 		      score=32000
 		     end
 		     -- pawchievement
	       if score>=7500 then dset(14,1) end
		      --
 		    if score>hiscore then
 		     hiscore=score
 		     dset(0,hiscore)
 		    end
 		  end
		  end 
	  end
	 end 
	 
	 for bo in all(bonusshow) do
   bo.y+=1
   bo.timer+=1
    if bo.timer>45 then
     del(bonusshow,bo)
    end
  end
  
  for boss in all(bossalien) do
   
   --animation (boss only, yet)
   boss.anima+=1
   if boss.anima>40 and bossdone==0 then
    boss.anima=0
     boss.sp+=120
      if boss.sp>192 then
       boss.sp=72
      end
   end   
   
   if boss.sp==134 then
    boss.sp=72
   end
   
   if gameover==1 then
    del(bossalien,boss)
   end
   
   if player.y<boss.y and bossdone==0 and boss.anima%4==0 then
     add_projectiles(boss.x+22,boss.y+1,0,-2,49)
     add_projectiles(boss.x+22,boss.y+1,2,-1.75,49)
     add_projectiles(boss.x+22,boss.y+1,-2,-1.75,49)
   end
   
   if boss.move==1 then
    boss.y+=1
     if boss.y>20 then 
      boss.y=20
      boss.move=2
     end
   elseif boss.move==2 and boss.anima<21 then
    boss.x+=1
     if boss.x>80 then 
      boss.x=80
      boss.move=3
     end
   elseif boss.move==3 and boss.anima<21  then
    boss.x-=1
     if boss.x<0 then 
      boss.x=0
      boss.move=2
     end
    elseif boss.move==99 then
     boss.y+=.5
     -- boss.x+=flr((-1+rnd(3)))
      if boss.y>128 then
       del(bossalien,boss)
       overinit()
      end
   end
   
   if boss.move==2 or boss.move==3 then
   boss.i+=1
    if boss.i>20 then
     boss.i=0
     bossbullets+=1
      if bossbullets<10 then
       sfx(0)
	      add_projectiles(boss.x+22,boss.y+24,0,1,49)
	      add_projectiles(boss.x+22,boss.y+24,.25,.85,49)
       add_projectiles(boss.x+22,boss.y+24,.45,.75,49)
	      add_projectiles(boss.x+22,boss.y+24,.65,.65,49)
       add_projectiles(boss.x+22,boss.y+24,-.65,.65,49)
	      add_projectiles(boss.x+22,boss.y+24,-.45,.75,49)
       add_projectiles(boss.x+22,boss.y+24,-.25,.85,49)   
      elseif bossbullets>16 then
       bossbullets=0
      elseif bossbullets==15 then
       sfx(0)
	      add_projectiles(boss.x+22,boss.y+24,0,2,48)
	      add_projectiles(boss.x+22,boss.y+24,.25,1.75,48)
       add_projectiles(boss.x+22,boss.y+24,-.25,1.75,48)
      end
    end
   end
   
	  if hitzone.x>boss.x+3 and hitzone.x<boss.x+45 and hitzone.y>boss.y+3 and hitzone.y<boss.y+29 and blinking==0 and boss.move<4 then
      sfx(1+flr(rnd(3)))
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
   		 add_particles(player.x+8,player.y+8)
      explode=1
      blinking=100
      player.x=56
      player.y=128
      bonus=10
      anim=0
      sfx(6)
      life-=1
       if life==2 then
        lifeosd="‡‡"
       elseif life==1 then
        lifeosd="‡"
       else
        lifeosd=""
       end
       if life<0 then
        survived=flr(time()-timesup)
         if survived==0 then
          survived=120
         end
      		 --pawchievement
      		 if survived>=90 then dset(11,1) end
   		    --
        gameover=1
        overinit()
       end  
   end

   for b in all(bullets) do
 	  if b.x>=boss.x-1 and b.x<boss.x+48 and b.y>=boss.y and b.y<boss.y+32 and boss.move<4 then
    	add_debris(b.x,b.y)
     boss.sp=134
    	bonus+=.2
    	 --pawchievement
      if bonus>=200 then dset(15,1) end
   		 --
    	anim=120
    	--boss.x+=flr((-1+rnd(3)))
   	 del(bullets,b)
 	   sfx(5)
 	   boss.damage+=1
   		if boss.damage>boss.maxdamage and boss.move!=99 then
   		 sfx(1+flr(rnd(3)))
   		 
   		 --pawchievement
   		 dset(12,1)
   		 --
   		 
   		 boss.sp=128
   		 add_particles(boss.x+8,boss.y+8)
   		 add_particles(boss.x+8,boss.y+8)
   		 add_particles(boss.x+8,boss.y+8)
   		 add_particles(boss.x+8,boss.y+8)
   		 add_particles(boss.x+8,boss.y+8)
   		 add_particles(boss.x+8,boss.y+8)
   		 add_particles(boss.x+8,boss.y+8)
 		   add_coin(boss.x-14,boss.y+2)
 		   add_coin(boss.x-10,boss.y+4)
 		   add_coin(boss.x-4,boss.y+6)
 		   add_coin(boss.x+8,boss.y+8)
 		   add_coin(boss.x+12,boss.y+6)
 		   add_coin(boss.x+16,boss.y+4)
 		   add_coin(boss.x+20,boss.y+2)
 		   boom=1
 		   tt=0
 		   boss.move=99
 		   boss.speed=0
 		   whatover="stage cleared!"
 		   survival="time left:"
      bossdone=1
      survived=times
      score+=250+flr(bonus)+(survived*100)
 		    add_bonus(b.x+6,boss.y,250+flr(bonus)+(survived*100))
 		     if score>32000 then
 		      score=32000
 		     end
 		    -- pawchievement
	      if score>=7500 then dset(14,1) end
		     --
 		    if score>hiscore then
 		     hiscore=score
 		     dset(0,hiscore)
 		    end
 		  end  
 		  end
 		  
		  end 

  end

   
	 -- the sopihisticaded
	 -- score system. yeah sure.
	 if anim>=0 then
   anim-=1
    if anim<=0 then
     anim=0
     bonus=10
    end
  end

	 player:update()
  hitzone:update()

  -- thrusters retro fx!
  pal(14,flr(rnd(15)))
 
 end
 
 -----------------------------!
 -- draw
 -----------------------------!

 function _draw()
  if (mode==0) then
    titledraw()
  elseif (mode==2) then
    overdraw()
  elseif (mode==3) then
    pawdraw()
  else
    gamedraw()
  end
 end
 
 -----------------------------!
 
 function gamedraw()

 cls()
 
	for s in all(stars) do
		pset(s.x,s.y,2)
	end
	
	for boss in all(bossalien) do
  spr(boss.sp,boss.x,boss.y,6,4)	
	end
	
	for b in all(bullets) do
 	spr(32,b.x,b.y)
	end
	
 for t in all(tangos) do
 	spr(t.sp+t.state,t.x,t.y,2,2)
	end

	for pa in all(particles) do
	 pset(pa.x,pa.y,9)
	end
	
	for d in all(debris) do
 	pset(d.x,d.y,9)
	end

 for bo in all(bonusshow) do
 	print(bo.is,bo.x,bo.y,8)
	end
	
 for co in all(coins) do
 	spr(co.sp,co.x,co.y)
	end
		
 for p in all(projectiles) do
  spr(p.sp,p.x,p.y) 
 end

	hitzone:draw()
 player:draw()
 
 print(""..score.."",hcenter(""..score..""),3,8)
 print(lifeosd,4,3,8)
 print(times,114,3,8)
 print("+"..flr(bonus).."",4,11,8)
 --print(anim,2,19,8)
 rect(1,128-anim,1,128,8)
 end

 -----------------------------!
 
 function titledraw()

  cls()
  
  for s in all(stars) do
	 	pset(s.x,s.y,2)
 	end

  print(""..score.."",hcenter(""..score..""),3,8)
  print("try to survive",hcenter("try to survive"),51,8)
  print("120 seconds",hcenter("120 seconds"),58,8)
  print("shoot debris",hcenter("shoot debris"),68,8)
  print("to raise bonus",hcenter("to raise bonus"),75,8)
  print("beat the",hcenter("beat the"),85,8)
  print("hiscore: "..hiscore.."",hcenter("hiscore: "..hiscore..""),92,8)
  print("press Ž to start",hcenter("press Ž to start")-2,105+pressfire,9)
  print("2021 ‡ donswelt.de ’ v1.1",hcenter("2021 ‡ donswelt.de ’ v1.2")-4,118,8)
 
  map(0,0,32,13,8,4)
 end

 -----------------------------!

 function overdraw()
  
  cls()
  
 	for s in all(stars) do
	 	pset(s.x,s.y,2)
 	end

  print(""..score.."",hcenter(""..score..""),3,8)
  print(""..whatover.."",hcenter(""..whatover..""),45,8)
  print(""..survival.." "..survived.." seconds",hcenter(""..survival.." "..survived.." seconds"),60,8)
  
  print("press Ž to continue",hcenter("press Ž to continue")-2,85+pressfire,9)

 end

 -----------------------------!
 -- functions
 -----------------------------!

 function add_star(x,y)
	 local s={
		 x=flr(rnd(128)),
		 y=0,
		 speed=flr(1+rnd(3)),
  }
  add(stars,s)
 end
 
 function add_projectiles(x,y,a,b,c)
  local p={
   x=x,
   y=y,
   xs=a,
   ys=b,
   sp=c,
   }
  add(projectiles,p)
 end
 
 function fire()
  fired=1
  local b={
		 x=player.x+flr(rnd(3)+5),
		 y=player.y-(3+flr(rnd(2))),
		 speed=5,
  }
	 add(bullets,b)
 end

 function add_tango()
	 local t={
		 x=tangostart_x,
		 y=-24,
		 move=1+(tangotype*10),
		 sp=4+(flr(rnd(2))*(6+(((flr(rnd(2)))*26)))),
		 speed=1+flr(rnd(maxspeed)),
		 shift=shiftstart,
		 damage=0,
		 maxdamage=20,
		 state=0,
		 pause=0
		 }
		add(tangos,t)
	end
	
	 function add_bossalien()
	 local boss={
		 x=39,
		 y=-32,
		 move=1,
		 sp=72,
		 i=0,
		 anima=0,
		 damage=0,
		 maxdamage=1200,
		 }
		add(bossalien,boss)
	end
	
 function add_debris(x,y)
  local d={
   x=x,
   y=y,
   speedx=0,
   speedy=0,
   addspeedy=((rnd(5)+1)/10)
   }
  add(debris,d)
 end
 
 function add_particles(x,y)
  local pa={
   x=x,
   y=y,
   i=0,
   sx=rnd(3)-rnd(4),
   sy=rnd(3)-rnd(4),
   sxx=sgn(sx)/10,
   syy=sgn(sy)/10,
   }
  add(particles,pa)
 end
 
 function add_bonus(x,y,is)
  local bo={
   x=x,
   y=y,
   is=is,
   timer=0,
   }
  add(bonusshow,bo)
 end
 
 function add_coin(x,y)
  local co={
   x=x,
   y=y,
   speed=-1,
   i=0,
   sp=140
   }
  add(coins,co)
 end

 function titleinit()
  mode=0
  timer=0
  shift=0
  shiftstart=-20
  pressfire=0
  anim=0
  bossbullets=0
  gameover=0
  bossdone=0
  animseq=0
  fallspeed=2
  maxspeed=1
  tangotype=0
  i=0
  coin=0
  coinup=0
  smartup=0
  tt=0
  tangowave=0
  tangostart_x=58
  shottimer=0
  shotamount=300
 end
 
 function gameinit()
  mode=1
  fired=0
  boom=0
  i=0
  life=3
  bossactive=0
  lifeosd="‡‡‡"
  explode=1
  blinking=100
  score=0
  bonus=10
  timesup=time()
  survived=0
  whatover="game over"
  survival="you survived"
  stars={}
  bullets={}
  tangos={}
  debris={}
  projectiles={}
  particles={}
  bonusshow={}
  coins={}
  music(-1)
  music(6)
 end
 
 function overinit()
  mode=2
  i=0
  coin=0
  tries+=1
  dset(1,tries)
  music(-1)
 end
 
 function hcenter(s)
  -- screen center minus the
  -- string length times the 
  -- pixels in a char's width,
  -- cut in half
  return 64-#s*2
 end
 
 function press()
 i+=1
   if i>=36-(coin*30) then
    i=0
    pressfire+=128
     if pressfire>128 then
      pressfire=0
     end
   end
 end
 
 -- pawchievements 
 
 function pawinit()
  mode=3
  paw1=dget(11) paw2=dget(12) paw3=dget(13) paw4=dget(14) paw5=dget(15) paw6=dget(16)
  paws1="--" paws2="--" paws3="--" paws4="--" paws5="--" paws6="--"
  pawc1=0 pawc2=0 pawc3=0 pawc4=0 pawc5=0 pawc6=0
 end
 
 function pawupdate()
  if paw1==1 then paws1="‡" pawc1=3 end
  if paw2==1 then paws2="‡" pawc2=3 end
  if paw3==1 then paws3="‡" pawc3=3 end
  if paw4==1 then paws4="‡" pawc4=3 end
  if paw5==1 then paws5="‡" pawc5=3 end
  if paw6==1 then paws6="‡" pawc6=3 end 
  if btnp(3) then titleinit()	end
 end
 
 function pawdraw()
  cls(0)
  print("pawchievements!",10,15,9)
  print(paws1.." survive 90 seconds",10,35,6+pawc1)
  print(paws2.." kill the boss",10,45,6+pawc2)
  print(paws3.." just another try",10,55,6+pawc3)
  print(paws4.." beat a score of 7500",10,65,6+pawc4)
  print(paws5.." get a multiplier of 200",10,75,6+pawc5)
  print(paws6.." artful dodger",10,85,6+pawc6)
  print("press ƒ to return!",10,105,9)
 end
__gfx__
0000006000000000a700000000000000000000000000000000000000000000000000000000000000000056677700000000005667000000000000000000000000
000001d6000000008900000000000000000055666600000000005566660000000000056000000000000500000670000000050000067000000000000000000000
00001ddd600000000000000000000000005556565666000000055656566000000000065650600000005008008067000000005200206700000000002000000000
00001d6d600000000000000000000000055565656566600000056565656000000000656565000000005007287067000000050128106700000000022280000000
0001d1c6d60000000000000000000000055556565656660005005656565666000000565656000000005001221007000000500222200700000088012210000000
101d1c7c6d6060000000000000000000555555556565660055555555656566005005555565000000005002228006000000500211800600000002822220000000
1ddd1cc76dd660000000000000000000155555555656560015555555565656001555555556565600005522222856000000552211285600000000220028000000
1d2d1ccc6d2d60000000000000000000151555555565650015155555556565000005555555056500051122222816700005552211281670000002200228880000
1dddd1c6dddd60000000000000000000115555555556500011555555555650000005555555500000055d111111dd600005dd555555ddc0000002200222200000
0111dd1dd111000000000000000000000151555555555000015155555505500000005555555550000555dddddd5dd0000555dddddd5060000022222220000000
00095555590000000000000000000000001151515555000000005151555000000000515100550000005555dd5ddd0000000055dd5dd000000020028000000000
0005ddd66700000000000000000000000001115555500000000011555500000000001100055000000005555dd55000000000555dd50000000000028000000000
00055d5d560000000000000000000000000001111000000000000011100000000000010000000000000005555000000000000505500000000000220000000000
00001151500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
800000000000000000000000000000000000999aaa0000e00000049a000000000000019a00000000000000600000000000000060000000000000006000000000
90000000000000000000000000000000000444999aa0050000004449900005000000014990000500000001d600000000000001d600000000000001d600000000
800000000000000000000000000000000054444449aa60000001444449aa60e000090144900a60e000001ddd6000000000001ddd6000000000001dd660000000
9000000000000000000000000000000005455555554aa00000015555554aa00000090055504aa00000001d6d6000000000001d6d6000000000001dd660000000
00000000000000000000000000000000054444444449a900011444444449a400011490490149a90001011c66d60600000001d1c6d60000000605dd17d6050000
000000000000000000000000000000001544888888449900154448888844990015444949014900000111c7c6dd660000101d1c7c6d606000066dd1cc7d550000
000000000000000000000000000000001552212212894900155921221289490000594591445990000111cc76ddd600001ddd1cc76dd6600006ddd1cc7d550000
000000000000000000000000000000001422251152284900151525115228440000054150141549000151ccc6d8d600001d2d1ccc6d2d600006d8d1cccd250000
03330000022200000077770000000000142221111228440015559111112490001555400005549000011d1c66ddd600001dddd1c6dddd600006dddd1cdd550000
3bbb30002888200009999970000000000144111111455000155549999995000015554999500500000011dd1dd16000000111dd1dd11100000065ddddd5500000
3b7b3000287820004994499700000000015599999994400001155555555000000111555555000000000015559000000000095555590000000000955590000000
3bbb300028882000497994970000000000155544444400000001554444900000000011544490000000001dd6700000000005ddd66700000000006dd660000000
0333000002220000497994970000000000011554444000000000155444900000000000154490000000001d5d6000000000055d5d5600000000005d5d10000000
00000000000000004997799700000000000001111000000000000111110000000000001111000000000011515000000000001151500000000000115110000000
0000000000000000049999900000000000000000000000000000000000000000000000000000000000000eee0000000000000eee0000000000000eee00000000
00000000000000000044440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
088888888888888888888888888888888888888888888888888888888888800000000000011111111111111111c111c1ccccccc0000000000000000000000000
8888888888888888888888888888888888888888888888888888888888888800000000111000000000000000000000000000000ccc0000000000000000000000
8888888888888888888888888888888888888888888888888888888888888800000001000000000000001000000000000007770000c000000000000000000000
88888888888888888888888888888888888888888888888888888888888888000000100000000001000010001000000011000077000c00000000000000000000
888888880000000880000000080000000880000000880880000000888888880000010000110101010011100010100001111000077000c0000000000000000000
888888880888888080888888880888888080888888080808888888888888880000010011111111111111111111111111111111117700c0000000000000000000
888888880888888080888888880888888080888888080808888888888888880000010111111111111111122118811111111111111710c0000000000000000000
8888888808888880808888888808888880808888880808088888888888888800001011818191e1d1315117228871113181e1c191e1710c000000000000000000
8888888808888880808888888808888880808888880808088888888888888800001011111111111111111122281111111111111111710c000000000000000000
8888888808888880808888888808888880808888880808088888888888888800001011111211211211211222228112112111111111110c000000000000000000
8888888808888880808888888808888880808888880808088888888888888800001012111722711722712222222817227121121111110c000000000000000000
8888888808888880808888888808888880808888880808088888888888888800001017221122111122122222222881221172271112110c000000000000000000
8888888808888880808888888808888880808888880808088888888888888800001011212222221221222222222288122112211227110c000000000000000000
8888888808888880808888888808888880808888880808088888888888888800001012212222212221222222222288121222221221110c000000000000000000
8888888808888880808888888808888880808888880808088888888888888800001022212222212212222222222888812222222122110c000000000000000000
8888888808888880800000008800000008800000008808800000088888888800001022212222212212222222228888812222222122210c000000000000000000
88888888088888808088888888088888808088888808088888888088888888000111111111111111111111111111111111111111111111600000000000000000
88888888088888808088888888088888808088888808088888888088888888001111155555555555555555555555555556565656565666660000000000000000
88888888088888808088888888088888808088888808088888888088888888001111515511111111111111111111111166666665656566660000000000000000
88888888088888808088888888088888808088888808088888888088888888001111555555555555555555555555555555555556565666660000000000000000
88888888088888808088888888088888808088888808088888888088888888001115151556666666555115556665515566666665656566660000000000000000
88888888088888808088888888088888808088888808088888888088888888001111515515555555656cc151bb76515155555556565656660000000000000000
88888888088888808088888888088888808088888808088888888088888888001115151515565665656cc1513bb6515158585556556566660000000000000000
88888888088888808088888888088888808088888808088888888088888888001111515551555555656cc1551115515155555565555656660000000000000000
88888888088888808088888888088888808088888808088888888088888888000111151551556655656cc1556665515158855565156566600000000000000000
88888888088888808088888888088888808088888808088888888088888888000111515155155555656cc15199a6515155555155555666600000000000000000
88888888088888808088888888088888808088888808088888888088888888000011151515511555656cc1514996515155511551156666000000000000000000
88888888000000088000000008000000088088888808080000000888888888000011115151555111555665551115515511155551155666000000000000000000
88888888888888888888888888888888888888888888888888888888888888000001111515155555555555555555555555555555556660000000000000000000
88888888888888888888888888888888888888888888888888888888888888000000111111515151555111115551511515111155566600000000000000000000
88888888888888888888888888888888888888888888888888888888888888000000001111151515515555555155555555555556660000000000000000000000
08888888888888888888888888888888888888888888888888888888888880000000000011111111111111111111111151565666000000000000000000000000
00000000011111111111111111c111c1ccccccc00000000000000000022222222222222222822282888888800000000000777700000770000007700000077000
000000111000000000000010000000000100000ccc00000000000022200000000000000000000000000000088800000009999970009997000009700000999700
000001000100000000000010800000000107770000c0000000000200000000000000100000000000000777000080000049944997049449700009900004944970
0000100000100000000001010000000001000077000c000000002000000000010000100010000000110000770008000049700497049709700009900004904970
00010000001111010008000100008000010000077000c00000020000110101010011100010100001111000077000800049700497049709700004900004904970
00010000001000100000000000000000101100007700c00000020011111111111111111111111111111111117700800049977997049779700004900004977970
00010000001000000000022008800001000011000700c00000020111111111111111122118811111111111111710800004999990004999000004900000499900
001000000010000000000722887000000000000000700c00002011818191e1d1315117228871113181e1c191e171080000444400000440000004400000044000
001000000100000000000722287000000000000000700c0000201111111111111111112228111111111111111171080000000000000000000000000000000000
001000000200200200200222228002002000000000000c0000201111121121121121122222811211211111111111080006666660000000000000000000000000
001002001722700722702221122807227020020000000c0000200211172271172271222222281722712112111111080015555556000000000000000000000000
001007221722700722122221122881227072271002000c0000200722112211112212222112288122117227111211080015ee5e56000000000000000000000000
001007212222221221222221122288122172271227000c0000200121222222122122222112228812211221122711080015555556000000000000000000000000
001002212211212221222221122288121222221227000c0000200221221121222122222112228812122222122111080015e5ee56000000000000000000000000
001022212211212212222221122888812221122122000c0000202221221121221222222112288881222112212211080015555556000000000000000000000000
001022212222212212222222228888812221122122200c0000202221222221221222222112888881222112212221080001111110000000000000000000000000
01111111111111111111111111111111111111111111116001111111111111111111111111111111111111111111116000000000000000000000000000000000
11111555555555555555555555555555565656565656666011111888888888888888888888888888868686868686666600000000000000000000000000000000
01111155111111111111111111111111666666656565660011118188111111111111111111111111666666686868666600000000000000000000000000000000
00110155555555555555555555555555555555565656600011118888888888888888888888888888888888868686666600000000000000000000000000000000
0e150e15566666665551155566655155666666656565600011181888866666668881188866688188666666686868666600000000000000000000000000000000
011100e115555555656111511116515155555556565656001111818818888888686cc181bb768181888888868686866600000000000000000000000000000000
1115001515565665656111511116515150505556556566601118888818868668686cc1813bb68181888888868868666600000000000000000000000000000000
1115015551555555656111551115515155000565555656601118188881888888686cc18811188181888888688886866600000000000000000000000000000000
0111011551556655656111556665515150005565151116000111881881886688686cc18866688181888888681868666000000000000000000000000000000000
011111551515555565611151111651515555515556e010000111818888188888686cc18199a68181888881888886666000000000000000000000000000000000
0011e0001551155565611151111651515551115116e000000011188188811888686cc18149968181888118811866660000000000000000000000000000000000
0011000151551111555665551e15515511151e111560000000111118818881118886688811188188111888811886660000000000000000000000000000000000
000100001551e155555555551e155555155100001160000000011118188888888888888888888888888888888866600000000000000000000000000000000000
00000000111e001555e1555510015111e11e00000000000000001111188188818881111188818118181111888666000000000000000000000000000000000000
00000001100000015100155100011110001000000000000000000011111881888188888881888888888888866600000000000000000000000000000000000000
00000000000000001000011000000100000000000000000000000000111111111111111111111111818686660000000000000000000000000000000000000000
00000000011111111111111111c111c1ccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000111000000000000000000000000000000ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000001000000000000001000000000000007770000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000100000000001000010001000000011000077000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000110101010011100010100001111000077000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010011111111111111111111111111111111117700c00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010111111111111111111111111111111111111710c00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010118191e1d13151811281188111e1e1c191e131710c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001011111211211111111728887111111111111111710c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001011111722711211211122281112112111111111110c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001012111122111722711222288117227121121112110c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001017221222211122112222228811221172271227110c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001011212222221222122222222881222112211221110c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001012212222212222122222222881221222221222110c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001022212222212221222222222888112222222122210c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
001022212222212212222222228888812222222122210c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111111111111111111111111116000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111555555555555555555555555555565656565656666600000000000000000000000000000000000000000000000000000000000000000000000000000000
11115155111111111111111111111111666666656565666600000000000000000000000000000000000000000000000000000000000000000000000000000000
11115555555555555555555555555555555555565656666600000000000000000000000000000000000000000000000000000000000000000000000000000000
11151515566666665551155566655155666666656565666600000000000000000000000000000000000000000000000000000000000000000000000000000000
1111515515555555656cc151bb765151555555565656566600000000000000000000000000000000000000000000000000000000000000000000000000000000
1115151515565665656cc1513bb65151585b55565565666600000000000000000000000000000000000000000000000000000000000000000000000000000000
1111515551555555656cc15511155151555555655556566600000000000000000000000000000000000000000000000000000000000000000000000000000000
0111151551556655656cc15566655151588555651565666000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111515155155555656cc15199a65151555551555556666000000000000000000000000000000000000000000000000000000000000000000000000000000000
0011151515511555656cc15149965151555115511566660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111151515551115556655511155155111555511556660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011115151555555555555555555555555555555566600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001111115151515551111155515115151111555666000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000011111515155155555551555555555555566600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111111111111111111111515656660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4041424344454647000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051525354555657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6061626364656667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071727374757677000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8081828384858687000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9091929394959697000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100000376010700047000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700001765013650096500465002650016500160001600006000060000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c000004660056500a6000360016600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700002e6401c6400f6401b64011640096400460010640086400000000000036000000000000006000000000000000000060000000000000000000000000000000000000000000000000000000000000000000
000200000d63000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000026730217201f7301e730217300b7300a730097300773006730057300573004730037300273001730007300f600236000f6000f6000f600236000f6000f6000f600236000f600236000f6000f6000f600
000300002d7502d7502d7502d7502d7502c7502d7502b7502c7502a7502b7502a75027750287502575026750257502275023750217501f7501d750187501a7501775014750107500f7500c7500a7500875004750
00060000177401b1402e740147400a740017400b70005700027000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d0000002600000000000000000e670000000000000000002600020000000000000e670000000000000000002600000000000000000e670000000000000000002600020000000000000e670000000e67000000
000d00000c2550c25518255102550c2551825510255182550c2550c25518255102550c255182550c255182550925509255152550c255092551525509255152550e2550e2551a255112550e2501a2500e2501a250
000d000018360000000000000000000000000015360000001836000000000000000000000000000000000000000000000021360000000000000000000000000000000000001a3600000021360000000000000000
000d00000c375000000c3750c375000000c3750c375000000c375000000c3750c375000000c3750c3750000015375000001537515375000001537515375000000e375000000e3750e375000000e3750e37500000
000d00001825518255242551c25518255242551c255242551825518255242551c255182552425518255242551525515255212550c255152552125515255212551a2551a255262551d2551a250262501a25026250
000d00000c1550c15518155101550c1551815510155181550c1550c15518155101550c155181550c155181550915509155151550c155091551515509155151550e1550e1551a155111550e1551a1550e1551a155
000d00000c1150c11518115101250c1251812510135181350c1350c14518145101450c155181550c155181550915509155151550c155091551515509155151550e1550e1551a155111550e1551a1550e1551a155
000d00000c2100c21018210102200c2201822010220182200c2200c22018220102200c220182200c220182200922009220152200c220092201522009220152200e2200e2201a220112200e2201a2200e2201a220
000d00000c2200c22018220102200c2201822010220182200c2200c22018220102200c220182200c220182200922009220152200c220092201522009220152200e2200e2201a220112200e2201a2200e2201a220
000d0000002650000500005000050000000005000050e6750026500205000050000500000000050000500005002650000500005000050000000005000050e675002650020500265000050e675000050e67500005
000700002c0503a0502005032050300402a030250202001018710137100b71005710150001000005000000000b00000000000001a0003700014000370000d0000000009000040000200002000000000000000000
c90d00001803018750187501875018750187501875018050180501805018050180501805018050180501805015050150501505015050150501505015050150501a0501a0501a0501a0501a0501a0501a0501a050
0004000027020257202c02031020277201f0200e72005020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000023002230042302463007230092300e2301523025230262300a700076000370007500075000750007500075000750007500075000750011700075000750007500075000850008500085000850016100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 08 09 43 0b
00 08 09 43 0b
00 08 09 43 0b
00 08 09 43 0b
00 08 0c 43 0b
02 08 0c 43 0b
01 41 42 43 0e
00 41 42 43 0d
00 41 42 43 0d
00 41 42 43 0d
00 41 42 43 0f
00 41 42 43 10
00 41 42 11 0d
00 41 42 11 0d
00 41 42 11 0d
00 41 42 11 0d
00 41 42 08 09
00 41 42 08 09
00 41 42 08 0c
00 41 42 11 0c
00 41 42 13 0d
00 41 42 13 0d
00 41 42 13 0d
02 41 42 13 0d
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
