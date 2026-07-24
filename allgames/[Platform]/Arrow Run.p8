pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--arrow run

version="v1.3"
v_color=6

t=0
lives=0

win_texts={
"you won!",
"you did it!",
"let's gooooo!",
"nice!",
"hell yeah!"
}
fail_texts={
"you lost.",
"better luck next time.",
"you dun goofed.",
"oh, shit!",
"damn it!"
}

function _init()
 -----------------------
 cartdata("arrow_run")
 --save_data(0,0)
 --save_data(0,1)
 --save_data(0,2)
 --save_data(0,3)
 if load_data(2)==0 then
  save_data(1,2)
 end
 lives=load_data(3)
 -----------------------
 cls()
 init_transition()
 while true do
  --if load_data(1)==1 then
  -- music(3,100)
  --elseif load_data(1)==2 then
  -- music(3,100)
  --elseif load_data(1)==3 then
  -- music(8,100)
  --else
  -- music(8,100)
  --end
  -----
  if load_data(2)%2==0 then
   if flr(rnd(2))==0 then
    music(3,100)
   else
    music(8,100)
   end
  elseif load_data(1)==3 then
   music(8,100)
  else
   music(3,100)
  end
  --music(3,100)
  -----
  --music(0,100)
  ---------
  opt=do_start()
  ---------
  if opt=="new game" then
   lives=0
   save_data(lives,3)
   do_game(1)
  elseif opt=="continue" then
   do_game(load_data(0))
  end
  ---------
		music(0,500)
		do_start(1)
	end
end

function do_game(level)
 if level<=1 then
  do_w(1)
 end
 for lv_num=level,6 do
	 plat_state=""
	 repeat
	   do_plat(lv_num)
	   if plat_state=="lost" then
	    lives-=1
	   end
	 until plat_state=="won"
	end
	if level<=6 then
  do_w(2)
  level=7
 end
 for lv_num=level,12 do
	 plat_state=""
	 repeat
	   do_plat(lv_num)
	   if plat_state=="lost" then
	    lives-=1
	   end
	 until plat_state=="won"
	end
	if level<=12 then
	 music(-1,3000)
  do_w(3)
  music(8,400)
  level=13
 end
 for lv_num=level,18 do
	 plat_state=""
	 repeat
	   do_plat(lv_num)
	   if plat_state=="lost" then
	    lives-=1
	   end
	 until plat_state=="won"
	end
end

function _update()
 t+=1
end

function _draw()
 cls()
end

function do_start(over)
 if over!=nil then
  save_data(0,0)
  if load_data(2)%2==0 then
   save_data(load_data(2)*5,2)
  else
   save_data(load_data(2)*2,2)
  end
  if lives==0 then
   save_data(load_data(2)*3,2)
  end
 end
 -------------------
 --creating menu varibles
 menu={}
 menu.open=false
 menu.ybars=32
 menu.t=0
 menu.h=0
 menu.w=0
 menu.options=
 {"continue",
	 "new game",
  "controls",
  --"endless",
  --options?
  --config?
  --settings?
  "quit"}
 menu.selected=1
 menu.blocked_options=
 {true,
  false,
  true,
  --true,
  false}
	if load_data(0)==0 then
	 menu.blocked_options[1]=true
	else
	 menu.blocked_options[1]=false
	end
 while menu.blocked_options[menu.selected] do
	 menu.selected+=1
	end
 -----------------------------
 c_color={6,12}
 y=12
 bg_color=13
 init_stars()
 init_waves()
 init_objects(-999)
 init_landscape("plat")
 -----------------------------
	if load_data(1)==1 or load_data(1)==0 then
	 waves={}
	 stars={}
	elseif load_data(1)==2 then
	 stars={}
	 c_color={7,7}
	 for r in all (roads) do
   r.s=103
   r.bottom=127
  end
	elseif load_data(1)==3 then
	 bg_color=1
	 waves={}
	 v_color=6
	 c_color={6,7}
	 for r in all (roads) do
   r.s=102
   r.bottom=127--pqqqqq????
  end
  for b in all (buildings) do
   b.s=64
  end
	end
 -----------------------------
 msg={}
	msg.t=380
 
 t=0
 while true do
  t+=1
	 
	 cls(bg_color)
	 update_landscape("plat")
	 update_waves()
	 update_stars()
	 
	 rectfill(0,90,127,127,2)
	 draw_stars()
	 draw_landscape("plat")
	 draw_waves()
	 
  if over!=nil then
   --update_stars()
   --print(msg.text,msg.x,msg.y,7)
   ------
	  rectfill(0,0,127,31,0)
   rectfill(0,96,127,127,0)
	  ------
   if t>msg.t then
    print("failed attempts:"..(-lives),2,25,6)
    print("x:back to menu",2,98,6)
		  if btn(5) then
	    return
	   end
   end
   
		 x=21
		 y=47
		 text="thank you for playing!"
   c_border=7
   c_text=5
   c_shadow=6
	  write_text_with_border(
	  text,x,y,c_shadow,
	  c_border,c_text)
	  
	  x=51
	  y=37
	  c_text=8
	  text="you won!"
	  write_text_with_border(
	  text,x,y,c_shadow,
	  c_border,c_text)
	  ------
	  draw_transition()
	  ------
  end
  
	 if over==nil then
   spr(104,46,y,5,3)
   spr(152,46,27+y,5,1)
   spr(224,30,21+y,9,1)

   if not menu.open then
		  write_text_box(
		  "press ‹ and ‘ to start "
		  ,2,8,7)
		 end
		 
		 --write_text_box(
		 --"2017",2,37,c_color[1])
		 write_text_box(
		 "by guimm",2,46,c_color[1])
		 write_text_box(
		 "  @guimm12",2,55,c_color[2])
		 pal(12,c_color[2])
		 spr(109,40,116)
		 pal()
		 
		 --achievements
		 print("’",102,1,0)
			print("’",101,1,0)
			print("’",111,1,0)
			print("’",110,1,0)
			print("’",120,1,0)
			print("’",119,1,0)
		 if load_data(2)!=0 then
			 if load_data(2)%2==0 then
			  print("’",102,1,9)
			  print("’",101,1,10)
			 end
			 if load_data(2)%5==0 then
			  print("’",111,1,9)
			  print("’",110,1,10)
			 end
			 if load_data(2)%3==0 then
			  print("’",120,1,9)
			  print("’",119,1,10)
			 end
			end
		 --------------
		 
		 print(version,1,1,v_color)
		 
		 if btn(0) and btn(1) and not menu.open then
	   menu.open=true
	   menu.close=false
	   menu.ybars=32
	   menu.t=0
	   menu.h=0
	   menu.w=0
	   y=12
	  end
	  if menu.close then
	   menu.h*=0.6
	   menu.w*=0.5
	   
	   if menu.h>0.6 then
	    rectfill(64+menu.w,63+menu.h,63-menu.w,64-menu.h,0)
	    rect(64+menu.w,63+menu.h,63-menu.w,64-menu.h,7)
	   end
	   
	   menu.ybars*=0.6
	   y*=1.2
	   y+=2
	   if y>12 then
	    y=12
	   end
	   rectfill(0,-2,127,-1+menu.ybars,0)
    rectfill(0,129-menu.ybars,127,130,0)
	  end
	  if menu.open then
	   menu.t+=1
	   menu.ybars*=0.6
	   y*=0.8
	   y-=2
	   rectfill(0,-1,127,31.9-menu.ybars,0)
    rectfill(0,96+menu.ybars,127,127,0)
	   if menu.t>=1 then
	    --rectfill(64-menu.w,63-menu.h,63+menu.w,64+menu.h,0)
	    --rect(64-menu.w,63-menu.h,63+menu.w,64+menu.h,7)
	    if menu.h<26 then --26
	     menu.h+=2
	     menu.h*=1.09
	    end
	    if menu.h>=26 then
	     menu.h=27
	    end
	    if menu.w<59 then --59
	     menu.w+=4
	     menu.w*=1.1
	    end
	    if menu.w>=59 then
	     menu.w=60
	    end
	    rectfill(64-menu.w,63-menu.h,63+menu.w,64+menu.h,0)
	    rect(64-menu.w,63-menu.h,63+menu.w,64+menu.h,7)
	    
	   end
	   if menu.w>=59 and menu.h>=26 then
	    --------------------
				 --key handling
				 if not dkeydown and btn(3) then
				  dkeyup=true
				 end
				 if dkeydown and btn(3) then
				  dkeyup=false
				 end
				 --key handling
				 if not ukeydown and btn(2) then
				  ukeyup=true
				 end
				 if ukeydown and btn(2) then
				  ukeyup=false
				 end
				 --key handling
				 if not zkeydown and btn(4) then
				  zkeyup=true
				 end
				 if zkeydown and btn(4) then
				  zkeyup=false
				 end
				 -----------------------
	    if not trans.doing then
	     if dkeyup then
	     sfx(31)
	     if menu.selected<#menu.options then
	      menu.selected+=1
	     else
	      menu.selected=1
	     end
		    end
		    if ukeyup then
		     sfx(31)
		     if menu.selected<=1 then
		      menu.selected=#menu.options
		     else
		      menu.selected-=1
		     end
		    end
	     -------------
	     -------------
	     --actual important stuff
		    if load_data(0)==0 then
		     menu.blocked_options[1]=true
		    else
		     menu.blocked_options[1]=false
		    end
		    if zkeyup and menu.blocked_options[menu.selected] then
		     --load("mfgj")
		     sfx(33)
		    else
			    if zkeyup and menu.options[menu.selected]=="new game" then
			     save_data(0,0)
	       save_data(0,1)
	       start_transition("new game")
			    end
			    if zkeyup and menu.options[menu.selected]=="continue" then
			     start_transition("continue")
			    end
			    if zkeyup and menu.options[menu.selected]=="quit" then
			     menu.t=0
			     menu.open=false
			     --menu.h=0
			     --menu.w=0
			     menu.ybars=32
			     menu.close=true
			     y=0
			    end
			   end
			  end
	    draw_menu()
	    
	    -----------------------
	    --key handling
				 if btn(3) then
				  dkeydown=true
				 else
				  dkeydown=false
				 end
				 dkeyup=false
				 --key handling
				 if btn(2) then
				  ukeydown=true
				 else
				  ukeydown=false
				 end
				 ukeyup=false
				 --key handling
				 if btn(4) then
				  zkeydown=true
				 else
				  zkeydown=false
				 end
				  zkeyup=false
				 -----------------------
	   end
	  end
		end
	 -------
	 if trans.halfdone then
	  return trans.text
	 end
	 draw_transition()
	 -----
	 flip()
 end
end

function draw_menu()
 if not menu.blocked_options[menu.selected] then
  print("z:confirm",2,98,6)
 end
 --------------------
 --options
 local col_text_s=0
 local col_back_s=6
 local col_text=6
 local col_back=0
 local col_text_b=5
 local oy=0
 local i=1
 for o in all (menu.options) do
  oy+=8
  if o==menu.options[menu.selected] then
   if menu.blocked_options[i] then
    rectfill(8,33+oy,40,39+oy,col_text_b)
   else
    rectfill(8,33+oy,40,39+oy,col_back_s)
   end
   print(o,9,34+oy,col_text_s)
  else
   rectfill(8,33+oy,40,39+oy,col_back)
   if menu.blocked_options[i] then
    print(o,9,34+oy,col_text_b)
   else
    print(o,9,34+oy,col_text)
   end
  end
  i+=1
 end
 line(44,39,44,88,6)
 -------------------
 if menu.options[menu.selected]=="endless" then
  write_text_box("          "..
  "work in progress",2,0,5)
  spr(54,79,50)
 elseif menu.options[menu.selected]=="quit" then
  print("quit to start",49,42,6)
  print("screen.",49,50,6)
 elseif menu.options[menu.selected]=="continue" then
  if load_data(0)==0 then
   print("you don't have",49,42,5)
   print("saved data.",49,50,5)
  else
   print("continue from",49,42,6)
   print("world "..load_data(1).."-"..(load_data(0)-(load_data(1)-1)*6)..".",49,50,6)
  end
 elseif menu.options[menu.selected]=="new game" then
  print("start a new game.",49,42,6)
  --print("collect all coins.",49,50,6)
  --print("hit all targets.",49,58,6)
  --print("avoid all spikes.",49,66,6)
  if load_data(0)!=0 then
	  print("(this will clear",49,74,5)
	  print("your saved data)",49,82,5)
	 end
 elseif menu.options[menu.selected]=="controls" then
  print("‹‘:move",49,42,6)
  print("z:jump",49,50,6)
  print("x:shoot",49,58,6)
  print("p:pause",49,66,6)
 end
 ----------------------
 --rectfill(47,60,120,88,6)
end
-------------------------------
function write_text_with_border(text,x,y,c_shadow,c_border,c_text)
 print(text,x,y+2,c_shadow)
 print(text,x+1,y+2,c_shadow)
 print(text,x-1,y+2,c_shadow)
 print(text,x+1,y,c_border)
 print(text,x-1,y,c_border)
 print(text,x,y+1,c_border)
 print(text,x,y-1,c_border)
 print(text,x+1,y+1,c_border)
 print(text,x-1,y-1,c_border)
 print(text,x+1,y-1,c_border)
 print(text,x-1,y+1,c_border)
 print(text,x,y,c_text)
end
-------------------------------
function do_w(w)
 ------------------------
 --saving
 save_data(w,1)
 if w==1 then
  save_data(1,0)
 elseif w==2 then
  save_data(7,0)
 elseif w==3 then
  save_data(13,0)
 end
 ------------------------
 init_objects(-999)
 
 init_stars()
 init_clouds()
 init_landscape("plat")
 init_waves()
 
	if w==1 then
	 txt="first world"
	 w_spr=112
	 bg_c=13
	 stars={}
	 waves={}
	elseif w==2 then
	 txt="water world"
	 w_spr=103
	 bg_c=13
	 stars={}
	 for r in all (roads) do
   r.s=103
  end
	elseif w==3 then
	 txt="dream world"
	 w_spr=151
	 bg_c=1
	 waves={}
	 clouds={}
  for r in all (roads) do
   r.s=102
  end
  for b in all (buildings) do
   b.s=64
  end
	end
	
	i=0
	done=false
	while not done do
	 update_stars()
	 update_clouds()
	 update_landscape("plat")
	 update_waves()
	
	 cls(bg_c)
	 draw_stars()
	 draw_clouds()
	 draw_landscape("plat")
	 draw_waves()
	 
	 write_text_box(txt,0,-8,7)
	 
  if i>=80 then
   if trans.halfdone then
    done=true
   end
   start_transition()
  end
  -------
	 draw_transition()
	 -------
	 
	 rectfill(0,0,127,31,0)
  rectfill(0,96,127,127,0)
	 print("$ 0/0",2,25,7)
  print(" 0/0",103,25,7)
  
	 -------
	 i+=1
	 flip()
	end
end

function init_particle(x0,y0,xs,ys)
 add(p1,{x=x0,y=y0,
	 xspd=xs,yspd=ys,t=rnd(30)+5})
end

function update_particle()
 for p in all (p1) do
  if plat_state=="lost" then
   --p.x-=2
  else
   p.t-=1
   p.x-=2
   if p.y<80 then
    p.x+=p.xspd*rnd(10)/10
    p.y+=p.yspd*rnd(10)/10
   end
  end
  if p.t<=0 then
   del(p1,p)
  end
 end
end

function draw_particle()
 for p in all (p1) do
  pset(p.x,p.y,6)
 end
end

function init_arrow(x0,y0,spd)
 arrow_g=-0.05
 if spd>=3 then
  sfx(34)
  spd+=p.xspd
	 if spd>8 then
	  spd=8
	 end
	 add(arrows,{x=x0,y=y0,
	 xspd=spd,yspd=0-p.yspd/20,hit=false})
	else
	 
	end
end

function update_arrow()
 if arrow_power>=2.8 and t%4==0 then
  sfx(32)
 end
 for a in all (arrows) do
  if a.y>78 or a.hit then
   a.x-=2
   a.hit=true
   if a.hit_static_target then
    a.x+=2
   end
   if a.hit_slowed_target and a.x<130 then
    a.x+=1
   end
  else
	  a.yspd-=arrow_g
	  a.xspd-=0.02
	  a.y+=a.yspd
	  a.x+=a.xspd-2
	  --create particle
	  if t%1==0 then
	   init_particle(a.x-5+1*rnd(10)/10,a.y-1,0,1)
	  end
	 end
 end
end

function draw_arrow()
 update_particle()
 for a in all (arrows) do
  line(a.x-5,a.y,
       a.x,a.y+a.yspd,4)
  --pset(a.x-5,a.y,8)
  pset(a.x,a.y+a.yspd,6)
 end
 draw_particle()
end

function do_plat(dif)
 ---------------
 --saving
 if load_data(0)<dif then
  save_data(dif,0)
 end
 save_data(lives,3)
 ---------------
 init_stars()
 init_clouds()
 --music(3)
 init_landscape("plat")
 init_objects(dif)
 init_player()
 arrows={}
 p1={}
 init_waves()

 --changes on difficult
 if dif>0 then
  plat_state="playing"
  qtcoins=0
  qttargets=0
  p.spritespd=2
  p.ground=64
  p.x=30
  bg_color=13
  obj={}
  obj.text=""
  obj.text2=""
  obj.x=32
  obj.y=98
  for r in all (roads) do
   r.s=112
  end
  for b in all (buildings) do
   b.s=160
  end
 end
 if dif<=6 then
  waves={}
  stars={}
 end
 if dif>6 and dif<=12 then
  stars={}
  for r in all (roads) do
   r.s=103
  end
 end
 if dif>12 then
  bg_color=1
  clouds={}
  waves={}
  for s in all (spikes) do
   s.s=145
  end
  for r in all (roads) do
   r.s=102
  end
  for b in all (buildings) do
   b.s=64
  end
 end
 
 win_text=win_texts[flr(rnd(#win_texts)+1)]
 fail_text=fail_texts[flr(rnd(#fail_texts)+1)]
 
 totaltargets=#targets
 totalcoins=#coins
 end_state=0
 done=false
 target_text_col=7
 coin_text_col=7
 ---------------------------
 if dif==18 then
   targets[3].x=1000
 end
 -------------------------]
 save_data(dif,0)
 while not done do
  if dif==1 then
   obj.text="collect all coins!"
   obj.text2="press z to jump"
  end
  if dif==2 then
   obj.text="also avoid all spikes!"
   obj.text2="use ‹ and ‘ to move   "
  end
  if dif==3 then
   obj.text2="use ‹ and ‘ to move   "
   if targets[1].x<120 then
    obj.text="and hit all targets too!"
    obj.text2="hold x to shoot"
   end
  end
  if dif==4 then
   obj.text="that's all!"
  end
  if dif==5 then
   obj.text="oh, arrows collect coins too!"
  end
  if dif==6 then
   obj.text="anyway, good luck!"
  end
  if dif==15 then
   obj.text="hey, i'm back!"
  end
  if dif==16 then
   obj.text="you are almost there!"
  end
  if dif==17 then
   obj.text="next one is the last!"
  end
  if dif==18 then
   if targets[3].x<500 and targets[3].x>=130 then
    obj.text="wait for it"
    music(-1,2200)
   elseif targets[3].x<130 then
    obj.text="there we go"
   end
  end
  t+=1
  cls(bg_color)
  update_stars()
  update_clouds()
  update_landscape("plat")
  update_objects()
  update_player()
  update_waves()
  
  draw_stars()
  draw_clouds()
  draw_landscape("plat")
  draw_player()
  draw_waves()
   
  --gui
  if plat_state=="won" then
   coin_text_col=3
  end
  if qtcoins>=totalcoins and qttargets>=totaltargets then
   if plat_state=="playing" then
    sfx(15)
   end
   plat_state="won"
   write_text_box(win_text)
  end
  
  if plat_state=="lost" then
   p.sprite=101
   write_text_box(fail_text)
  end
  -------
  draw_transition()
  -------
  rectfill(0,0,127,31,0)
  rectfill(0,96,127,127,0)
  write_text_box(obj.text,1)
  write_text_box(obj.text2,2,59,5)
  if totaltargets==0 then
   target_text_col=0
  elseif qttargets==totaltargets then
   target_text_col=3
  end
  if totalcoins==0 then
   coin_text_col=0
  elseif qtcoins==totalcoins then
   coin_text_col=3
  end
  print("$ "..qtcoins.."/"..totalcoins,2,25,coin_text_col)
  if qttargets>9 then
   print(" "..qttargets.."/"..totaltargets,100,25,target_text_col)
  else
   print(" "..qttargets.."/"..totaltargets,103,25,target_text_col)
  end
  
  if plat_state=="won" or
     plat_state=="lost" then
   end_state+=1
   if end_state>=45 then
    if plat_state=="lost" or
      (dif!=6 and
       dif!=12 and
       dif!=18) then
     return
    end
    if trans.halfdone then
     done=true
    end
    start_transition()
   end
  end
  -------
  --draw_transition()
  -------
  flip()
 end
end

function init_objects(lv)
 coins={}
 spikes={}
 targets={}
 misc1={}
  local xmapmin=0
  local xmapmax=39
  local ymapmin=lv*5-5
  local ymapmax=lv*5-1
 if lv>6 and lv<=12 then
  xmapmin=40
  xmapmax=79
  ymapmin-=30
  ymapmax-=30
 elseif lv>12 then 
  xmapmin=80
  xmapmax=119
  ymapmin-=60
  ymapmax-=60   
 end
 for y=ymapmin,ymapmax do
  for x=xmapmin,xmapmax do
   local id=mget(x,y)
   local y0=y-(5*lv-5)
   local x0=x
   if lv>6 and lv<=12 then
    y0=y-(5*(lv-6)-5)
    x0=x-40
   elseif lv>12 then
    y0=y-(5*(lv-12)-5)
    x0=x-80
   end
   if id==129 then
    add(coins,
    {x=x0*8+140,y=y0*8+40,s=129,spd=2})
   elseif id==132 then
    add(coins,
    {x=x0*8+140,y=y0*8+40,s=129,spd=1})
   elseif id==144
       or id==145 then
    add(spikes,
    {x=x0*8+140,y=y0*8+40,s=id})
   elseif id==133
       or id==134
       or id==150
       or id==148
       or id==135
       or id==147
       or id==146  then
    local m0=false
    local d0=-1
    local w0=false
    local spd0=1
    local a0=0.1 
    local slw0=false
    local what0=false
    if id==134 then m0=true end
    if id==150 then w0=true end
    if id==148 then m0=true w0=true end
    if id==135 then slw0=true end
    if id==147 then m0=true slw0=true end
    if id==146 then w0=true what0=true end
    
    add(targets,
    {x=x0*8+140,y=y0*8+40,
    s=133,m=m0,d=d0,w=w0,
    spd=spd0,a=a0,slw=slw0,what=what0})
   elseif id!=0 then
    add(misc1,{x=x0*8+140,
    y=y0*8+40,s=id})
   end
  end
 end
end

function update_objects()
 if plat_state=="lost" then
  return
 end
 ----------------
 local lost_coin=false
 local ended_without_coins=true
 for c in all (coins) do
  if c.x<-20 then
   lost_coin=true
  end
  if c.x>-10 then
   ended_without_coins=false
  end
  c.x-=2
  if c.spd==1 and c.x<130 then
   c.x+=1
  end
  if c.s<132 and t%2==0 then
   c.s+=1
  elseif t%2==0 then
   c.s=129
  end
  if c.x<p.x+4 and
     c.x>p.x-8 and
     c.y<p.y+16 and
     c.y>p.y-8 then
   sfx(13)
   del(coins,c)
   qtcoins+=1
  end
  for a in all (arrows) do
	  if c.x<a.x+6 and
	     c.x>a.x-6 and
	     c.y<a.y+6 and
	     c.y>a.y-9 and
	     a.hit==false then
	   sfx(13)
	   del(coins,c)
	   qtcoins+=1
	  end
	 end
 end
 if ended_without_coins and #coins>0 and plat_state!="won" then
  sfx(14)
  plat_state="lost"
  coin_text_col=8
 end
 ---end faster
 if lost_coin then
  sfx(14)
  plat_state="lost"
  coin_text_col=8
 end
 -----
 for s in all (spikes) do
  s.x-=2
  if s.x<p.x+1 and
     s.x>p.x-6 and
     s.y<p.y+10 and
     s.y>p.y and
     plat_state!="won" then
   sfx(14)
   plat_state="lost"
  end
 end
 -----
 local lost_target=false
 local not_hit={}
 local did_not_hit_all=true
 for t in all (targets) do
  -----------what is true
  
  --if t.what==true then

  --end
  
  -------------
  if t.x<-20 and t.s==133 then
   lost_target=true
  end
  if t.s==133 and t.x>-10 then
   did_not_hit_all=false
  end
  if t.s==133 then
   add(not_hit,{1})
  end
  ----------spd treatment
  t.x-=2
  if t.w==true and t.x<120 then
   t.x+=2
   t.spd-=t.a
   if t.spd>0 then
    t.x-=t.spd
   end
  end
  if t.slw and t.x<130 then
   t.x+=1
  end
  ---------------
  if t.m and t.s==133 then
   t.y+=1*t.d
   if t.y>70 then
    t.y=70
    t.d=-t.d
   end
   if t.y<38 then
    t.y=38
    t.d=-t.d
   end
  end
  for a in all (arrows) do
	  if t.x<a.x-1 and
	     t.x>a.x-10 and
	     t.y<a.y and
	     t.y>a.y-7 and
	     t.s==133 and a.hit==false then
	   sfx(35)
	   t.s=149
	   a.hit=true
	   qttargets+=1
	   if t.w==true then
	    a.hit_static_target=true
	   end
	   if t.slw then
     a.hit_slowed_target=true
    end
	  end
	 end
 end
 if did_not_hit_all and #not_hit>0 and #targets>0 and plat_state!="won" then
  sfx(14)
  plat_state="lost"
  target_text_col=8
 end
 ---end faster
 if lost_target then
  sfx(14)
  plat_state="lost"
  target_text_col=8
 end
 ------ misc1
 for m in all (misc1) do
  m.x-=2
  if m.x<130 then
   m.x+=1
  end
 end
end

function draw_objects()
 for t in all (targets) do
  if t.m then
   line(t.x+3,0,t.x+3,127,4)
   line(t.x+4,0,t.x+4,127,2)
  else
   line(t.x+3,t.y+8,t.x+3,127,4)
   line(t.x+4,t.y+8,t.x+4,127,2)
  end
  spr(t.s,t.x,t.y)
 end
 for m in all (misc1) do
  spr(m.s,m.x,m.y)
 end
 for c in all (coins) do
  spr(c.s,c.x,c.y)
 end
 for s in all (spikes) do
  spr(s.s,s.x,s.y)
 end
 for t0 in all (targets) do
  if t0.x>128 and t0.x<200 and t0.s==133 and plat_state!="lost" then
   if t0.x<160 and t%4==0 then
    --spr(53,119,t0.y)
    sfx(36)
   else
    spr(53,119,t0.y)
   end
  end
 end
end

function init_player()
--to do:

--fazer a funcionalidade
--de se agachar
 
 p={}
 p.sprite=97
 p.spritespd=2
 
 p.x=64
 p.xspd=0
 p.xmaxspd=2
 p.xa=0.5
 p.xvariant=0
 p.ground=77
 p.y=p.ground
 p.yspd=0
 p.ya=0.8
 p.maxjspd=7.4--7
 p.minjspd=2
 
 zkeyup=false
 zkeydown=false
 arrow_power=0
 xpress=false
 xrelease=false
end

function update_player()
 if plat_state=="lost" then
  return
 end
 ----------------arrows
 if xpress==true and not btn(5) then
  xrelease=true
 else
  xrelease=false
 end
 if btn(5) then
  xpress=true
 else
  xpress=false
 end
 if xpress then
  arrow_power+=0.4
 end
 if arrow_power>0 and xrelease then
  init_arrow(p.x+5,p.y+6,arrow_power)
  arrow_power=0
 end
 
 update_arrow()
 ----------------
 if p.y==p.ground then
  if t%p.spritespd==0 then
   if p.sprite<100 then
    p.sprite+=1
   else
    p.sprite=97
   end
  end
 elseif p.y<p.ground then
  p.sprite=98
 end
 ---------
 if btn(0) and p.x>0 and not btn(1) then
  p.xspd-=p.xa
 elseif btn(1) and p.x<121 then
  p.xspd+=p.xa
 else
  if p.xspd>=-0.2 and p.xspd<=0.2 then
   p.xspd=0
  elseif p.xspd>0 then
   p.xspd-=p.xa
  elseif p.xspd<0 then
   p.xspd+=p.xa
  end
 end
 if p.xspd>p.xmaxspd then
  p.xspd=p.xmaxspd
 elseif p.xspd<-p.xmaxspd then
  p.xspd=-p.xmaxspd
 end
 p.x+=p.xspd
 if p.xspd>0 then
  p.x+=-p.xspd*0.2
 end
 if p.y<p.ground then
  p.x+=p.xspd*0.4
 end
 p.x-=p.xvariant
 ----with bow
 if arrow_power>0 and p.y==p.ground then
 p.x-=0.5
 end
 
 --left/right borders
 if p.x<0 then
  p.x=0
 elseif p.x>120 then
  p.x=120
 end
 --------------------
 --z key handling
 if btn(4) and zkeyup==true then
  zkeyup=false
 end
 if (not btn(4)) and zkeydown==true then
  zkeyup=true
 end
 if not zkeydown and zkeyup then
  zkeyup=false
 end
 --------------------
 --start the jump with max speed
 if btn(4) and not zkeydown and p.yspd>=0 then
  if p.y==p.ground then
   	p.yspd=p.maxjspd
   	sfx(12)
  end
 end
 --------------------
 --z key handling
 if btn(4) then
  zkeydown=true
 else
  zkeydown=false
 end
 -----------------------
 --end the jump (subtracting some speed)
 if zkeyup and p.yspd>=p.minjspd then
  p.yspd=p.minjspd
 end
 p.yspd-=p.ya
 p.y-=p.yspd
 if p.y>=p.ground then
  p.y=p.ground
  p.yspd=0
 end
end

bow_spr=192
function draw_player()
 draw_arrow()
 if p.sprite==101 then
  p.spritespd=2
  bow_spr=192
  palt(13,true)
  palt(0,false)
  spr(p.sprite,p.x,p.y,1,2)
  palt()
 elseif arrow_power>0 then
  p.spritespd=4
  if t%4==0 and bow_spr<196 then
   bow_spr+=2
  end
  palt(13,true)
  palt(0,false)
  spr(bow_spr,p.x,p.y,2,2)
  --
  palt(1,true)
  palt(5,true)
  palt(15,true)
  palt(9,true)
  palt(6,true)
  palt(7,true)
  spr(p.sprite,p.x,p.y,1,2)
  palt()
 else
  if xrelease==true then
   palt(13,true)
   palt(0,false)
   spr(198,p.x,p.y,2,2)
   --
   palt(1,true)
   palt(5,true)
   palt(15,true)
   palt(9,true)
   palt(6,true)
   palt(7,true)
   spr(p.sprite,p.x,p.y,1,2)
   palt()
  else
   p.spritespd=2
   bow_spr=192
   palt(13,true)
   palt(0,false)
   spr(p.sprite,p.x,p.y,1,2)
   palt()
  end
 end
end


function init_landscape(lv)
 if lv=="build" then
	 --pal(14,5)
	 --buildings
	 buildings={}
	 for i=1,2 do
	  add(buildings,{x=(i-1)*127,y=48,spd=1})
	 end
	 --roads
	 roads={}
	 for i=1,17 do
	  add(roads,{s=96,x=(i-1)*8,y=88})
	 end
	elseif lv=="plat" then
	 --grass
	 roads={}
	 for i=1,17 do
	  add(roads,{s=112,x=(i-1)*8-2,y=80,bottom=126})
	 end
	 --pal(14,5)
	 --buildings
	 buildings={}
	 for i=1,2 do
	  add(buildings,{s=160,x=(i-1)*127,y=64,spd=1})
	 end
	end
end

function update_landscape(lv)
 if plat_state=="lost" then
  return
 end
 ----------------
 if lv=="build" then
	 --buildings
	 for b in all (buildings) do
	  if b.x<-127 then
	   b.x=127
	  end
	  b.x-=b.spd
	 end
	 --roads
	 local spd=2
	 for r in all (roads) do
	  if r.s==103 then
	   r.bottom=127
	  end
	  if r.x<-8 then
	   r.x=128-spd
	  end
	  r.x-=spd
	 end
	elseif lv=="plat" then
	 --buildings
	 for b in all (buildings) do
	  if b.x<-127 then
	   b.x=127
	  end
	  b.x-=b.spd
	 end
	 --roads
	 local spd=2
	 for r in all (roads) do
	  if r.x<-8 then
	   r.x=128-spd
	  end
	  r.x-=spd
	 end
	end
end

function draw_landscape(lv)
 if lv=="build" then
	 --buildings
	 for b in all (buildings) do
	  spr(b.s,b.x,b.y,16,3)
	  rectfill(0,87,127,71,5)
	  rectfill(0,71,127,92,5)
	  rectfill(0,96,127,127,6)
	 end
	 --roads
	 for r in all (roads) do
	  spr(r.s,r.x+4,r.y)
	 end
	elseif lv=="plat" then
	 --buildings
	 for b in all (buildings) do
	  spr(b.s,b.x,b.y,16,2)
	  --rectfill(0,87,127,71,5)
	  --rectfill(0,71,127,92,5)
	  --rectfill(0,96,127,127,6)
	 end
	 --objects
	 draw_objects()
	 --roads
	 for r in all (roads) do
	  spr(r.s,r.x+4,r.y,1,2)
	  map(r.bottom,0,r.x+4,r.y+16,1,4)
	 end
	end
end

function update_clouds(menu)
 if plat_state=="lost" then
  return
 end
 ----------------
 if menu!=nil then
  for c in all (clouds) do
	  if c.x<-64 then
	   c.x=164
	   c.y=rnd(84)-20
	   c.spd=0.1--(rnd(4)+5)/10
	  else
	   c.x-=c.spd
	  end
  end
 else
	 for c in all (clouds) do
	  if c.x<-64 then
	   c.x=164
	   c.y=rnd(84)-20
	   c.spd=0.1--(rnd(4)+5)/10
	  else
	   c.x-=c.spd
	  end
	 end
	end
end

function draw_clouds()
 for c in all (clouds) do
  local x=c.x
  local y=c.y
	 for h=1,c[2] do
	  for w=1,c[1] do
	 	 spr(c[3][h][w],x,y)
	 	 x+=8
	 	end
	 	x-=8*c[1]
	 	y+=8
	 end
	end
end

function init_clouds(menu)
 clouds={}
 if menu!=nil then
  for i=1,1 do
	  add(clouds,{8,3,{{0,1,2,3,4,5,6,7},{16,3,3,3,3,3,3,23},{32,33,34,35,36,37,38,39}}})
	 end
	 for i=1,1 do
	  add(clouds,{7,2,{{24,25,26,27,3,29,30},{40,41,42,43,44,45,46}}})
	 end
	 for i=1,5 do
	  add(clouds,{2,1,{{8,9}}})
	 end
	 for c in all (clouds) do
	  c.x=rnd(140)-20
	  c.y=rnd(76)-30
	  c.spd=0.1
	 end
 else
	 for i=1,2 do
	  add(clouds,{8,3,{{0,1,2,3,4,5,6,7},{16,3,3,3,3,3,3,23},{32,33,34,35,36,37,38,39}}})
	 end
	 for i=1,3 do
	  add(clouds,{7,2,{{24,25,26,27,3,29,30},{40,41,42,43,44,45,46}}})
	 end
	 for i=1,5 do
	  add(clouds,{2,1,{{8,9}}})
	 end
	 for c in all (clouds) do
	  c.x=rnd(140)-20--rnd(164)
	  c.y=rnd(94)-30
	  c.spd=0.1--(rnd(2)+3)/10
	 end
	end
end

function write_text_box(text,mode,yoff,c)
local x=64-flr((#text*4)/2)
if mode==1 then
 print(text,x,98,6)
 return
elseif mode==2 then
 print(text,x,64-flr(5/2)+yoff,c)
 return
elseif mode==3 then
 local y=64-flr(5/2)
	local x1=x-9
	local y1=y-5
	local x2=x+flr((#text*4))+7
	local y2=y+10
	rectfill(x1-1,y1-1+yoff,x2+1,y2+1+yoff,7)
	rectfill(x1,y1+yoff,x2,y2+yoff,0)
	
	print(text,x,y+yoff,7)
 return
end 

local y=64-flr(5/2)
local x1=x-9
local y1=y-5
local x2=x+flr((#text*4))+7
local y2=y+10
rectfill(x1-1,y1-1,x2+1,y2+1,7)
rectfill(x1,y1,x2,y2,0)

print(text,x,y,7)
end

function init_waves()
 waves={}
 for i=1,17 do
  add(waves,{x=i*8-8,y=90,s=18})
 end
 w1=8
 w2=32
 w3=64
 w4=96
 wspd=1
 wt=0
end

function update_waves()
 if plat_state=="lost" then
  return
 end
 ----------------
 wt+=1
 w1+=wspd
 w2+=wspd
 w3+=wspd
 w4+=wspd
 w1=get_back(w1)
 w2=get_back(w2)
 w3=get_back(w3)
 w4=get_back(w4)
 for w in all (waves) do
  
  w.x-=1
  if w.x==-8 then
   w.x=128
  end
  if w.x==w1 or w.x==w2 then
   w.y+=1
  end
  if w.x==w3 or w.x==w4 then
   w.y-=1
  end
  w.y-=sin(wt/70)/6
 end
end

function get_back(x)
 if x>128 then
  return -7
 elseif x==-8 then
  return 128
 end
  return x
end

function draw_waves()
 for w in all (waves) do
  spr(w.s,w.x,w.y)
  rectfill(w.x,w.y+8,w.x+7,128,12)
 end
end

function init_stars(menu)
 stars={}
 if menu!=nil then
  for i=1,20 do
  add(stars,{x=rnd(127),
             y=rnd(127),
             spd=rnd(2)+0.6})
  end
 else
	 for i=1,30 do
	  add(stars,{x=rnd(127),
	             y=rnd(127),
	             spd=rnd(0.8)+0.2})
	 end
	end
end

function update_stars(menu)
 if plat_state=="lost" then
  return
 end
 ----------------
 if menu!=nil then
  for s in all (stars) do
	  s.x-=s.spd
	  if s.x<0 then
	   s.x=128
	   s.y=rnd(127)
	   s.spd=rnd(2)+0.6
	  end
	 end
 else
	 for s in all (stars) do
	  s.x-=s.spd
	  if s.x<0 then
	   s.x=128
	   s.y=rnd(127)
	   s.spd=rnd(0.8)+0.2
	  end
	 end
	end
end

function draw_stars(menu)
 if menu!=nil then
  for s in all (stars) do
	  if s.spd<1.4 then
	   pset(s.x,s.y,5)
	  else
	   pset(s.x,s.y,6)
	  end
	 end
 else
	 for s in all (stars) do
	  if s.spd<0.5 then
	   pset(s.x,s.y,5)
	  else
	   pset(s.x,s.y,6)
	  end
	 end
 end
end
-----------------------------
function init_transition(text)
 trans={}
 trans.x=138
 trans.y=0
 trans.x0=138
 trans.y0=138
 trans.doing=false
 trans.halfdone=false
 trans.done=false
 trans.text=text
end

function start_transition(text)
 if not trans.doing then
  trans.doing=true
  trans.text=text
 end
end

function draw_transition()
 if trans.doing then
  rectfill(trans.x-10,trans.y,
  trans.x0-10,trans.y0,0)
  trans.x0-=2
  if trans.x0>0 then
   trans.x0*=0.8
  elseif not trans.halfdone then
   trans.halfdone=true
  else
   trans.halfdone=false
  end
  if trans.x>0 and trans.x0<=-3 then
   trans.x-=2
   trans.x*=0.8
  end
  if trans.x<=0 and trans.x0<=0 then
   init_transition()
   trans.doing=false
  end
 end
end
-----------------------------
--save
--byte 0 -> level
--byte 1 -> world
--byte 2 -> achievements:
--2:completed the game
--3:0 deaths!
--5:completed the game 2 times
--byte 3 -> lives
function save_data(data,byte)
 dset(byte, data)
end

function load_data(byte)
  return dget(byte)
end
__gfx__
00000000000000000077777777777777777770000000000000000000000000000000000777000000000000004244424400444244424442007666666722222222
00000000000077777777777777777777777777777770000000000000000000000000077777777700000000004244424400444244424442007777777722222222
00000007777777777777777777777777777777777000000000000000000000000007777777777000000000004244424400444244424442007777777722222222
00000000077777777777777777777777777777777777777777700000000000000000777777777777000000004244424400444244424442007777777722222222
00007777777777777777777777777777777777777777777700000000000000000777777777777700444444444244424400444244424442007777777622222222
00000077777777777777777777777777777777777777777777777770000000000006777777777770222222224244424400444244424442007777766622222222
00777777777777777777777777777777777777777777777777777000000000000066666677777000424242424244424400444244424442006666666622222222
00007777777777777777777777777777777777777777777777777777770000000000666666600000424442444244424400444244424442006666666622222222
077777777777777777777777000000000000000077777777777777770000000000000000000000000000000000000777000420007700000000000000d666666d
0007777777777777cccccccc000000000000000077777777777777777777700000000000000000000000777777777777004442007777777000000000dddddddd
7777777777777777cccccccc000000000000000077777777777777777770000000000000007777777777777777777777000420007777700000000000dddddddd
0077777777777777cccccccc000000000000000077777777777777777777777700000000000000777777777777777777044444207777777777777000dddddddd
7777777777777777cccccccc044444444444442077777777777777777700000000000077777777777777777777777777000220007777777700000000dddddddd
0777777777777777cccccccc002222222222220077777777777777777777770000000000077777777777777777777777000420007777777777777777dddddddd
7777777777777777cccccccc004242424242420077777777777777770000000000007777777777777777777777777777000420007777777777000000dddddddd
0077777777777777cccccccc004442444244420077777777777777777777700000000077777777777777777777777777000420007777777777777700dddddddd
077777777777777777777777777777777777777777777777777770000000000000777777777777777777777777777777777777777777777700000000dddddddd
000666666666677777777777777777777777777777777777777777777700000000077777777777777777777777777777777777777777777777770000dddddddd
006666666777777777777777777777777777777777777777770000000000000007777777777777777777777777777777777777777777770000000000dddddddd
000000666666666666666666677777777777777777777777777777700000000077777777777777777777777777777777777777777777777700000000dddddddd
000006666666666666677777777777777777777777777770000000000000000006666777777777777777777777777777777777777700000000000000dddddddd
000000000000066666666666666666677777777777777777770000000000000000006666677777777777777777777777777777777777700000000000dddddddd
000000000066666666666666667777777777777700000000000000000000000000066666666666666666666677777777777770000000000000000000dddddddd
000000000000000000006666666666666660000000000000000000000000000000000000666666666666666666666666600000000000000000000000dddddddd
00444244424442004244424400444244424442000000000000005000000770000000000000000000000000000000000000000000000000000000000000000000
00444244424442004244424400444244424442008888820000055500007777000000000000000000000000000000000000000000000000000000000000000000
00444244424442004244424400444244424442008777882000050500777777770000000000000000000000000000000000000000000000000000000000000000
00222222222222002222222200444244424442008787888200550550077777700000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444244424442448777882000550550077777700000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222444244424442228888820005555555070000700000000000000000000000000000000000000000000000000000000000000000
42424242424242424242424242444244424442420000000005550555000000000000000000000000000000000000000000000000000000000000000000000000
42444244424442444244424442444244424442440000000000555550000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000dddd000000000000000000000000ddddd000000000000000000000000000000000ddddd0000000000000000000000000000000000000ddddddd000000000
0dddddddddd0000000000000000000ddddddddd0000000dddd000000000000000000ddddddddd0000000000000000000ddddd000000000dddddddddddd000000
ddddddddddddd000000dddd000000ddddddddddd000dddddddddd00000dddd00000ddddddddddd000000dddd000000ddddddddd00000dddddddddddddddd000d
dddddddddddddd00dddddddddd000dddddddddddd0dddddddddddd0dddddddddd0dddddddddddd000dddddddddd00ddddddddddd000dddddddddddddddddd0dd
dddddddddddddd0dddddddddddd0ddddddddddddddddddddddddddddddddddddddddddddddddddd0dddddddddddd0dddddddddddd0dddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
77777777dddddddddddddddddddddddddddddddddddddddd777777773333333307777777777777777777777777777777777000000000ccc00000000000000000
66666666ddddddddddd555ddddd555dddddddddddddddddd77777777bbbbbbbb7778888888888887777788888888888887770000000ccccc0000000000000000
55555555ddd555dddd55ffdddd55ffddddd555dddddddddd77777777dddddddd7788888888888888777888888888888888770000ccccccc00000000000000000
55555555dd55ffdddd5fffdfdd5fffdfdd55ffdddf555fdd777777776d666d6678888888888888888778888888888888888700000cccccc00000000000000000
55777755dd5fffdddddf9dd5dddf9dd5dd5fffddd5fff5dd7777777666666666788888222222888887788888222222888887000000ccccc00000000000000000
55555555dddf9dddd55171d5d55171d5dddf9dddd5fff5dd777776666666666678888277777728888778888277777728888700000ccccc000000000000000000
55555555dd1157dd5d11615d5d11615ddd5171ddd51715dd66666666666d6666788887777777788887788887777777788887000000ccc0000000000000000000
77777777dd1516dd5d1111dd5d1111dddd5161ddd51615dd666666666666666d7888877777777888877888877777777888870000000000000000000000000000
33333333dd1511ddfd1111ddfd1111ddd511115dd5111ddd76666667666666667888877777777888877888877777777888870000000000000000000000000000
bbbbbbbbdd11f15fdd1111dddd1111ddd511115ddd111ddd77777777666666667888877777777888877888877777778888870000000000000000000000000000
22222222dd1111dddd1111dddd1111dddf1111dfdd111ddd777777776d666d667888888888888888877888888888888888270000000000000000000000000000
42444244dd0000dddd0000dddd0000dddd0000dddd000ddd77777777dddddddd7888888888888888877888888888888882770000000000000000000000000000
44444444ddd0dd0dddd0dd0dddd0dd0ddddd0ddddd0d0ddd67777777dddddddd7888822222222888877888888888882227770000000000000000000000000000
44444444ddd0d0dddd0ddd0ddd0ddd0ddddd0ddddd0d0ddd66677777dddddddd7888877777777888877888822888887777770000000000000000000000000000
44424444dd0ddddddd0ddddd00ddddd0d000d0ddd0ddd0dd66666666ddd6dddd7888877777777888877888877288888777770000000000000000000000000000
44444442dd0dddddd0ddddddddddddd0ddddd0ddd0ddd0dd66666666ddddddd67888877777777888877888877728888877770000000000000000000000000000
44444444000000000000000000000000000000000888882008820000000000007888877777777888877888877772888887770000000000000000000000000000
44444444000a9000000a90000009a0000009a0008777778288882000066666657888877777777888877888877777288888770000000000000000000000000000
4244424400aaa900000a90000009a000009aaa008788878208820000006666507888877777777888877888877777728888870000000000000000000000000000
2222222200a9a900000a90000009a000009a9a008787878208828820000665007888877777777888877888877777772888870000000000000000000000000000
2222222200a9a900000a90000009a000009a9a008788878208828820000665007222277777777222277222277777777222270000000000000000000000000000
2222222200aaa900000a90000009a000009aaa008777778200008820006666507777777777777777777777777777777777770000000000000000000000000000
22242222000a9000000a90000009a0000009a0000888882000088882066666656666666666666666666666666666666666660000000000000000000000000000
22222224000000000000000000000000000000000002200000008820000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000088882008206665082082820bbbbb3000000000077777707777777777777777777770077777777777700000000000000000000000000000
0000000000000000088888828882065088828282b77777b300000000777777777888755575557755757570078887575755770000000000000000000000000000
0000000000000000088008820820666508208282b7bbb7b308208200777777777878757575757575757570078787575757570000000000000000000000000000
0060000000000000000088200828200008282000b7b7b7b308208200777777777888755775577575757570078877575757570000000000000000000000000000
0060600000700000000882000008200000082000b7bbb7b308208200677777777878757575757575755570078787575757570000000000000000000000000000
6060600000707000000882000088820000888200b77777b308208200666777777878757575757557755570078787755757570000000000000000000000000000
60606060077777700000000000082000000820000bbbbb3000000000666666667777777777777777777770077777777777770000000000000000000000000000
60606060777777770008820000000000000000000002200000000000066666606666666666666666666660066666666666660000000000000000000000000000
00000000000000000000000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000005555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000055550000000000000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000555555000000000000000555555555500000005555000000000000000000000000000000000000000000000000000000000000000000000000
00000000000005555555500000000000005555555555550000055555500000000000000000000000000000000055550000000000000000000055550000000000
00000000000055555555550000000000055555555555555000555555550000000000000000000000555500000555555000000000000000000555555000000000
00000000000555555555555000000000555555555555555505555555555000000000000000000005555550005555555500000000000000005555555555000000
00000000005555555555555500000005555555555555555555555555555500000000000000000055555555055555555550000000000000055555555555500000
00000000055555555555555550000055555555555555555555555555555550000055550000000555555555555555555555000000000000555555555555550000
00000000555555555555555555000555555555555555555555555555555555000555555000005555555555555555555555555500000005555555555555555000
00000005555555555555555555505555555555555555555555555555555555505555555500055555555555555555555555555550000055555555555555555500
00005555555555555555555555555555555555555555555555555555555555555555555550555555555555555555555555555555000555555555555555555550
00055555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555505555555555555555555555
50555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
ddd55574ddddddddddd55574ddddddddddd555d4ddddddddddd555d74ddddddd0000000000000000000000000000000000000000000000000000000000000000
dd55ff7d4ddddddddd55f7dd4ddddddddd55f77d4ddddddddd55ffd7d4dddddd0000000000000000000000000000000000000000000000000000000000000000
dd5ff7dd4ddddddddd5f7fdd4ddddddddd577fdd4ddddddddd5fffd7d4dddddd0000000000000000000000000000000000000000000000000000000000000000
dddf97dd4dddddddddd79ddd4ddddddddd7f9ddd4ddddddddddf9dd7d4dddddd0000000000000000000000000000000000000000000000000000000000000000
dd555f44446dddddd55f444446dddddd55f444446ddddddd5f5171575fdddddd0000000000000000000000000000000000000000000000000000000000000000
dd1167dd4ddddddddd1761dd4ddddddddd7161dd4ddddddddd1161d7d4dddddd0000000000000000000000000000000000000000000000000000000000000000
dd1117dd4ddddddddd1171dd4ddddddddd1771dd4ddddddddd1111d7d4dddddd0000000000000000000000000000000000000000000000000000000000000000
dd11117d4ddddddddd1117dd4ddddddddd11177d4ddddddddd1111d7d4dddddd0000000000000000000000000000000000000000000000000000000000000000
dd111174dddddddddd111174dddddddddd1111d4dddddddddd1111d74ddddddd0000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
88888880000000000000000000000000000000000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000
28888888880000000000000000000000000000000000000000000000007777000000000000000000000000000000000000000000000000000000000000000000
02228888888800000000000000000000000000000000000000000000007777770000000000000000000000000000000000000000000000000000000000000000
00002288444444444444444444444444444444444444444444444444777777777700000000000000000000000000000000000000000000000000000000000000
00008888888855555555555555555555555555555555555555555555667777776600000000000000000000000000000000000000000000000000000000000000
08888888882200000000000000000000000000000000000000000000007777660000000000000000000000000000000000000000000000000000000000000000
88888882220000000000000000000000000000000000000000000000007766000000000000000000000000000000000000000000000000000000000000000000
22222220000000000000000000000000000000000000000000000000006600000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000111222333444555000666777888999aaabbbccceeefff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000111222333444555000666777888999aaabbbccceeefff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000111222333444555000666777888999aaabbbccceeefff
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000081000000001f0f1f
000000000000818181810000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c0000000000000000000000000000000000000000000000000000000081818181850000000000000000000000000000000000000000000000000081000000002f0f2f
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000818100000000000000000000870000000000000000000000000000000000000000000000000000000000000000000000008181818185000000000000000000000000000000000081000000002f0f2f
00000000000000000000000081818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000084008400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000081000000002f0f2f
818181810000000000000000000000000000000000000000000000000000000000000000000000008181810000909000000000009090909000000013000a000a00140000000000000081818181000000000081818181850000000000000000000000000000000000000000000000000000000000000000008100000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009300000000000000000000000000000000001c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008100000000000000
00818100000000000000000000000000000000000000000000000000000000000000000000000000000000001c0000000000000000000000000000000000000000000000870000008400840084008400000000008181810000850000000000000000000000000000000000000000000000000000000000008100000000000000
81000000000000000000000000000000000000000000000000000000000000000000000000000000000084008700000000000000000000000000000000000000000013000a0014008400840084008400000000000000000000000000000000000000008181810085000000000000000000000000000000008100000000000000
00000000000000000000000000810000000000000000000000000000000000000000000000000000000013000a0014000000000000000000000000000000000000000c000b0034001400840084008400000000000000000000000000000000000000000000000000000000000000000000000086000000008100000000000000
0090900000818100009090900000818100000000000000000000000000000000000000000000000013003000320031000a000a00140000000000000081818181130030003200320031000a000a001400000000919191919100000000000000000000000000000091919100000000008181009191910081818100000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000000000000085000000000000000000000000000000000000000000000000008100000000000000
0000008181810000000000000000000000000000000000000000000000000000000000000000000084008400840084008400840084008400000087000000000000001c00000000000000000000930000000000008500000000000000000000000000000000000000000000000000000000000000000000008100000000000000
000000000000000000000000000000000000000000000000000000960000000000000000000000008400840084008400840084008400840013000a001400000000008700000000000000000000000000000000000000000000000000000000000000000000000000850000000000000000000000000000008100000000000000
0000000000000000000000000000000000810000000000000000000000000000000000000000000084008400840084008400840084001300300032003100140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008100000000000000
0090909090909090000081818100009090008181000000000000000000000000000000000000000013000a000a000a000a000a000a00300032003200320031000a000a001400000000000013000a0014000000909090008181000000009090900081810000000090909000008181810000000000000000008100000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c00000000000000000093000000000000000000000000001c00000000000000000000000000000000001c0000000000000000000000001c000000000000000000000000000000001c00008100000000000000
0000000000000000000000000000000000008181000000008181810000000000000000000096000000000000008700000000000000000000000000000000000000000000008700000000000000000000000000000000008700000000000000000000000087000000000000008400840084008400008700008100000000000000
0000000000000000000000000000000000000000000000000000000000000000009600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c00000000000087000000000000008400840084008400008700008100000000000000
0000000000000000810000000081000000000000000000000000000000008100000000000000000000000013000a000a0014000000000000000000000093000000000013000a00140000000000000000000000000013000a001400000087000000000000000000000000000013000a000a001400008700008100000000000000
0090900081009090008100009000000090909000810000909090909000000081810000000000009600130030003200320031000a000a000a000a000a000a000a000a003000320031001400008181818100000013003000320031000a000a0014000013000a0014000000130030003200320031000a0014008100000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000093000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000000000860000000000000000000000000000000000008100000000000000
0000000000000000000000000000000081810000000000000000000000008181000000000000000000000000000000000000000000000000000000000000000000008700000000000000840084008400000000860000000000000000000000000000000000000000000000000000000000000085000000008100000000000000
8181818185000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008700000000008400840084008400000000000000000000000000000000000000000000000000000000000000000000000000000000008100000000000000
0000000000000000000000000000000000000000000000000000000000000000000081000000009400000000000000000000000000000093000000000000000013000a00140084008400840084008400000000000000000000000085000000000000000000000000000000000000000000000000000000008100000000000000
000000000000000000909000008100909090900000008181818100009090900000000081818100009090900013000a00148181818113000a00140000000013003000320031900a000a000a000a001490000000000000000000000090909000000081818100000000000090000081810000000090900000818100000000000000
00000000000000000000008600000000000000000000000000000000000000000000000000000000000000001c0000000000930000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008100000000000000
0081810000000000000000000000000000000000000000000000000000000000000081810000000000000000870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000085000000000000000000000000000000000000000085000000000000008100000000000000
81000000000000000000000000000000000000000000000000000000000000000000000000000000000013000a0014000000000000000000000093000000000000000000000000000000008181818185000000000000000000000000000000000000000000000000000000000000000000000000000000928100000000000000
00000000000000000000000000000000000086000000000000000000000000000000000000000000001330000b000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000850000000000000000000000000000000000008100000000000000
0090900000008181818100000081818181000000000090900081810090008100909090909090008113303200320031000a000a000a000a000a000a001400000000000000000000000000000000000000818181818590909090000000000090909000810090909000008181000000000090900000000000008100000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0110000028035270352803527035280352703528035230552605524055210551b0050c005180551c055210552305513005130051c0552005523055240552f0052800528005280352703528035270352803527035
0110000000000000000000000000000000000000000000000000000000090551005515055110050d0050f0050405510055140552000500000000000905510055150551c0550d0051c00521005110050000000000
0110000028035230552605524055210551800518005180551c0552105523055000001c0051c055240552305521055000002300523055240552605528055000001f0051f055290552805526055000001d0051d055
01100000280452605524055000001d0051d05526055240552305500000000000000000000000000000000000330053300534005330053400533005340052f00532005300052d0052d00500000000000000000000
011000000000000000000000900509055100551505500000000000400504055100551405500000090050900509055100551505500000000000c0050c055130551805500000000000700507055130551705500000
0110000013005090050905510055150550f005100050400504055100551c0551c055280551c055280552805534065340653405534055340453404534045340353403534025340253401534015000050000500005
011000000410004100041000410004150041400413004120041100410009150091400913009120091100910004150041400413004120041100410009150091400913009120091100910004100041000410004100
01100000006051560500605006050060500605006050060500605006051563515625156151c605146051462510635106251061500605006051462515635156251561500605006050060500605006050060500605
011000000000000000000001560515635156251561514605146051462510635106251061500000146051462515635156251561500000146051462518635186251861500000146051462507635076250761500000
011000000410004100000000910009150091400913009120091100410004150041400413004120041100910009150091400913009120091100c1000c1500c1400c1300c1200c1100710007150071400713007120
0110000007110091000915009140091300912009110041000415004140041300412004110000000000000000000000000000000000001d0001c000130001d0000000000000000000000000000000000000000000
011000002360514625096350962509615000001460514625046350462504615000000000000000000000000000000000000000000000000000000000000000003460034605346003460412600206001b60018600
00010000197301d73020730227302473026720287202a7202a7202a7202a7202972027720257201d700127000a7000670001700017000170002700037000470016700077000c7001070012700167002170038700
000400002c4102f5201c7001870016700127001470014700137000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001605016050160501605010050100501005010050090500905009050090500905009050090000900009000090000900009000090000900000000000000000000000000000000000000000000000000000
000800001c0551c0551c05528055280552805534055340553405534055340551c0052d005370052b005280051f0051d005210051e0052d005270052e0052f0052c00529005280053200507005190051800512005
011e0000051751210513105131050410513105041050f105041051010504105121050410513105041050f1050410517105041050c105041050d105041050e105041051010504105121050410513105041050e105
011e00001f5051c5051f5451c5451f5451f5051e5451e5001b545005051c545005051a5451a5451a545005051954519545195450050518545185451854500505175451c545185451c54517545005050050500505
011e000004040040451004504000040400404512045040000404004045130450000004040040450f0451000504040040451004513005040400404512045120050404004045130450400004040040450f04500000
011e000004050040550b0450c00504040040450c0450e00504040040450d0450000004040040450e0450000004040040451004504000040400404512045000000404004045130450400004040040451200513000
010f0020106151860517605186051c615186050060000600106150060000600006001e6150c6000060000600106150060000600006001f615006000060000600106151060504605126051b61513605046050f605
010f00000b000090000700006000040000400004000040050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100500e0500c0500b050
010f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001954519545195450050518545185451854500505175451c545185451c5451754517505005050050500000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00000a0500a0550c0450a00509040090450c0450000007040070450b0450000006040060450a0450000012005000001700500000120050000019005000001700017005160001600517000170050000012000
011e00000404004045100450400004040040451204500000040400404513045040000404004045120051300000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e000006040060450b0450000006040060450d045000000b0400b0450a0400a0450b0400b045000001200000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001f5051c5051f5451c5451f545005001e54500500245450050023545005002b5452b5452b545005002a5052a5052a505005002850528505285052a505275052a505285052a50527505005000050000500
011e00002a5452a5452a545005002854528545285452a505275452a545285452a5452754500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b060090600706006060
011e00001110500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001573500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
011000001510500005000050000500005000050000500005157050000500005000050000500005000050000505506000050000500005000050000500005000050000500005000050000500005000050000500005
011000000555609706097060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706
011000002113300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103001030010300103
01040000227661e766007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706007060070600706
010800002153500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
011400000c0350f03513035180350c0351103513035170350c0350f03513035180351b0351f0351b0351a035180351f0351b0351f0351a0351f035180351f03513035170351a0351f03513035170351a0351f035
011400001103514035170351a0351103514035170351a0350f03513035180351b03514035180351b0351e03513035180351b0351f03513035170351a0351f0350c0050c0350f0351303518030180350000500005
011400001b5301b5301b5351d5351a5301a5301a5351b535185301853018530185351a53517535185351a5351b5351a5351b5351d5351f535005051f535005051f5301f5301f5301f5301f5301f5351d5351f535
01140000205302053020530205351a5301a5351b5351d5351f5301f5301f5301f5351853018535185351a5351b535005001b5351d5351a535005001a5351b5351853018535005000050000500005001d5351f535
01020000135051350513530135301353013530135301353013530135301353013535185301853018530185301853018530185301853018530185351a5301a5301a5301a5301a5301a5301a5301a5301a5301a535
01140000205302053020530205351a5301a5351b5351d5351f5301f5301f5301f5351853018535185351a5351b535005001b5351d5351a535005001a5351b5351853518505225302253022530225352253022530
0114000018000050350b0350e035110351403513035110350000003035070350c0350f03513035140351203507035130351803513035070351303517035130350c03518035170351803510035180351303518035
0114000011035180351403518035130351d035170351d035140351b035180351b035130351c035180351c035110351d035180351d035130351f035130351f035180351820517035170051803513005130350c005
0114000022535205351f5351d5351b5351a5351853517535185351850524530245302453024535225302253022535205351f5351d5351b5351a5351853517535185351a5351b535185351b5351b5052353500505
011400000c0350c0000c0000c0000c0000c0000c0050c0050c0000c0000c0000c0000c0000c0000c0000c00500000000000000000000000000000000000000000000000000000000000000000000000000000000
011400002453524500245002450024500245002450524505245002450024500245002450024500245002450500500005000050000500005000050000500005000050000500005000050000500005000050000500
010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000157050000000000000000000000000000000000005506000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 00 01 06 44
00 02 04 09 44
04 03 05 0a 44
01 41 12 43 44
01 16 13 11 44
00 15 19 17 44
00 16 18 1b 44
02 1d 1a 1c 44
01 41 42 29 44
00 41 25 27 44
00 41 26 28 44
00 41 2b 2a 44
00 41 2c 2d 44
02 30 2e 2f 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
