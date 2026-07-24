pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--base

--const

allobj={}

frames=30
dt=1/frames

eps=0.01

str_color=7

levels={}
max_lvl=13
cur_lvl=0*3+1

--sfx
sfx_talk={0,1}
sfx_dot=2
sfx_not=3

function init_levels()
	
 for i=1,max_lvl do
		add(levels,create_levelp(i))
		add(levels,create_level(i))
		add(levels,create_leveln(i,
		           i*3-1))
 end
 
 add(levels,create_credit())
	
	levels[cur_lvl].init
	       (levels[cur_lvl])
end

function _init()
	cls()
end

timeinit=0

function _update()
 if (timeinit<0.75) return
 
	local is_over=
	      levels[cur_lvl].update
	       (levels[cur_lvl])
 if(is_over) then
 	cur_lvl %= #levels
 	cur_lvl +=1
 	if levels[cur_lvl].init then 	
	  levels[cur_lvl].init
	   (levels[cur_lvl])
	 end
 end
end

function _draw()  
 if timeinit<0.75 then
 	timeinit+=dt
 	if (timeinit>=0.75)	init_levels()
 	return
 else 	
	 levels[cur_lvl].draw
		  (levels[cur_lvl])
 end
end
-->8
--common

des_com=
{
 ne_x=10,
 ne_y=24
}

function collide(a,b)
	local boxa=a.hitbox(a)
	local boxb=b.hitbox(b)
 
 if boxa.x1>boxb.x0 and 
    boxa.x0<boxb.x1 and
    boxa.y1>boxb.y0 and 
    boxa.y0<boxb.y1 then
  return true  	
 end
 
 return false
end

function load_lvl(lvl,fast)
 allobj={}
 load_timer(lvl,fast)
 load_wall(lvl,fast)
 load_e_wall(lvl,fast)
 load_but(lvl,fast)
 load_trap(lvl,fast)
 load_coin(lvl,fast)
 load_price(lvl,fast)
 loadplayer(lvl)
end

function draw_all(lvl)

 mr_not.draw(mr_not)
 
 foreach(backs,function(w)
  w.draw(w)	
 end) 
	foreach(e_walls,function(w)
  w.pre_draw(w)	
 end)
	foreach(walls,function(w)
  w.pre_draw(w)	
 end)
 foreach(traps,function(w)
  w.draw(w)	
 end)
 foreach(buts,function(w)
  w.draw(w)	
 end)
 foreach(coins,function(w)
  w.draw(w)	
 end)
 foreach(prices,function(w)
  w.draw(w)	
 end)
 
 player.draw(player)
 
	foreach(e_walls,function(w)
  w.post_draw(w)	
 end)
	foreach(walls,function(w)
  w.post_draw(w)	
 end)
 
 timer.draw(timer)

 draw_speech_border() 
end

function draw_speech_border()
	
 local dist=4
 local disp=1
 local spessore=1
 rectfill(0,111+dist-disp,127,227,0)
 rectfill(0,111+dist-disp,127,127-disp,1)
 rectfill(spessore,111+spessore+dist-disp
     ,127-spessore,127-spessore-disp,2)
 rectfill(spessore+1,111+spessore+1+dist-disp
 ,127-spessore-1
 ,127-spessore-1-disp,0)

end

--not enough
function not_enough_camera(ne)
	if ne then
		camera(-2+rnd(5),-2+rnd(5))
	else
		camera()
	end
end

function not_enough(ne)
	not_enough_ex(ne,0,
	                 0)
end

function not_enough_ex(ne,x,y)
	if ne then		
	 local xw1=0
	 local xw2=0
	 local dispy=1
	 rectfill(x+15+xw1,y+19+10-dispy,
	     x+127-15-1-xw2,y+19+10+4-dispy,1)
	 circfill(x+15-1,y+19+10+2-dispy,2,1)
	 circfill(x+127-15+1,y+19+10+2-dispy,2,1)
	 sspr(0,8*8,13*8,3*8,x+14,y+19-dispy)
	end
end

--speech

standard_chr_t=0.1
dot_chr_t=0.3

function create_speech(str,x,y)
	local speech=
	{
	 x=x,
	 y=y,
	 str=str,
	 cur=0,
	 last=0,
	 time=0,
	 chr_t=0,
	 done=false
	}
	
	speech.str=speech.str.." "
	speech.last=#speech.str
	
	if(#str==0) speech.done=true
	
	return speech
end

function create_speech_ex(str)
 local x=(128-#str*4)/2
	return create_speech(str,x,
	       mr_not_speech_y)
end

function create_speech_y(str,y)
 local x=(128-#str*4)/2
	return create_speech(str,x,y)
end

function update_speech(speech)
 if(speech.done) return
 
	speech.time+=dt
	if(speech.time>speech.chr_t) then
		speech.cur+=1
		local cur_chr=sub(speech.str,
		       speech.cur,
		       speech.cur)
		if(cur_chr==".")then		 
		 sfx(sfx_dot)
		 speech.chr_t=dot_chr_t
  else
		 if(cur_chr!=" ")then	
		  sfx(sfx_talk[speech.cur%2+1])
		 end
		 speech.chr_t=standard_chr_t
  end
	speech.time=0
	end
	
	if(speech.cur==speech.last) then
		speech.done=true
	end
end

function draw_speech(speech)
 if(speech.cur==0) return
	for i=1,speech.cur do
	 print(sub(speech.str,i,i),
		      speech.x+i*4-4,
		      speech.y,
		      str_color)
	end
end

function print_speech(str)
 local disp=1
 rectfill(3,114+4-disp,124,124-disp,0)
 if(#str==0) return
 local x=(128-#str*4)/2
	print(str,
	      x,
	      mr_not_speech_y,
	      str_color)
end

function returnall()
 local alls={}
 
	foreach(backs,function(w)
  add(alls,w)
 end) 
	foreach(walls,function(w)
  add(alls,w)
 end)
 foreach(buts,function(w)
  add(alls,w)
 end)
 foreach(traps,function(w)
  add(alls,w)
 end) 
 foreach(coins,function(w)
  add(alls,w)
 end)
 foreach(prices,function(w)
  add(alls,w)
 end)
 
 return alls
end
-->8
--level preparation

--design values
mr_not_speech_y=118
maxst=dt*1.5
sds=4

des_p=
{
 max_t=0
}

function create_levelp(lvl)
	local level=
	{
	 lvl=lvl,
	 init=lp_init,
	 update=lp_update,
	 draw=lp_draw	 
	}
	
	return level
end

function lp_init(this)
 sfx(17,-2)
 mr_not.init(mr_not)
 
 if this.lvl==1 then
 	player.init(player)
 end
 
 --load
 if(this.lvl==3)then
  load_lvl(this.lvl,true)
 else 
  load_lvl(this.lvl,false)
  load_back(this.lvl,false)
 end
 
	this.toshow=returnall()
 
	this.shown=false
	
	this.time=0
	this.rumblefx=false
	
	this.maxst=maxst
	this.stime=this.maxst
	
	this.speech=
	     create_speech_ex(
	       lvl_request[this.lvl])
end

function lp_update(this)
 check_shown(this)
 
 if this.shown then
 	music(-1)
  if(this.lvl>=2)then
   if(not player.shown)then
    player.show()
   end
  end	
  
  if(player.shown or
     this.lvl==1)then
		 if this.speech.done then
		  this.time+=dt
		 else
		 	update_speech(this.speech)
		 end 
		end
  return this.time>des_p.max_t
 end
 
 if #this.toshow>0 then
  this.stime+=dt
  if(this.stime>this.maxst) then
  	this.stime-=this.maxst
	  for i=1,sds do
	   if #this.toshow>0 then
		  	local h=rnd(this.toshow)
		  	del(this.toshow,h)
		  	wstart(h)
	  	end
	  end
	 end
 end
 
 foreach(allobj,function(w)
  show_w(w)	
 end)
 
 player.repos()
 
 if not this.rumblefx then
 	this.rumblefx=true 	
   	--music(0)
 end
 
 return false
end

function lp_draw(this)	
 cls()
 
 not_enough_camera(
    not this.shown)
 
 if(this.lvl>3)then
  draw_all()
 else
  if(this.lvl>1) then
 	 draw_speech_border()
 	 player.draw(player)
 	else
 	 draw_speech_border()
		end
 end
 
 print_speech("")
 draw_speech(this.speech)
end

function check_shown(t)
 t.shown=false
 
 local shown=true
	for i=1,#allobj do
	 local w=allobj[i]
  if not wshown(w) then
  	shown=false
  	break
  end
 end
 
 t.shown=shown
end

--not enough

--design values
des_n=
{
 pren_t=1,
 ne_t=2.0
}

lvl_request=
{
 "press z to start",
 "use the arrow keys to move",
 "turn on the lights",
 "activate the traps",
 "get the prize you deserve",
 "get it first",
 "now, pay the bills",
 "happy birthday",
 "first the bills,than glory",
 "it's black friday",
 "success is hard to sustain",
 "you are going to love this",
 "cage yourself",
}

lvl_answer=
{
 "",
 "good...but",
 "i see you clearly now...but",
 "you love challenges...but",
 "you deserve it...but",
 "marvellous...but",
 "you've done your duty...but",
 "that was a bit weird...still",
 "you get it...but", 
 "you have them all...but",
 "i'm totally speechless...but", 
 "you can bear everything...but", 
 "you are my best puppet...but"    
}

function create_leveln(lvl,prev)
	if(lvl==max_lvl) then
		return create_lastn(lvl,prev)
	end
	
	local level=
	{
	 lvl=lvl,
	 prev=prev,
	 init=ln_init,
	 update=ln_update,
	 draw=ln_draw
	}
	
	return level
end

function ln_init(this)
 
 sfx(17,-2)
 	
	player.dx=0
	player.dy=0
	
	this.time=0
	this.time_pren=0
	
	this.n_sfx=false	
	
	this.speech=
	     create_speech_ex(
	       lvl_answer[this.lvl])
	       
	if(this.lvl==1) then 
	 this.time_pren=des_n.pren_t
	 
	 this.speech=
	     create_speech_ex(
	       lvl_request[this.lvl])
	 this.speech.cur=this.speech.last
	 this.speech.done=true
	end
	
	this.start_hide=false
	this.hidden=false
	
	this.maxst=maxst
	this.stime=this.maxst
	
	this.tohide=returnall()
	local count=0
	while #this.tohide>0 and
	      count <10 do
 	local h=rnd(this.tohide)
 	del(this.tohide,h)
 	wstart(h)
 	count+=1
 end
	
	this.mul=1
end

function ln_update(this)
 updatecircles()
 if this.start_hide then
  this.time+=dt
  if #this.tohide>0 then
	  this.stime+=dt
	  if(this.stime>this.maxst) then
	  	this.stime-=this.maxst
	   for i=1,sds do
	    if #this.tohide>0 then
			  	local h=rnd(this.tohide)
			  	del(this.tohide,h)
			  	wstart(h)
		  	end
		  end
		 end
  end
 
	 foreach(allobj,function(w)
	  hide_w(w,this.mul)	
	 end)
	 
  check_hidden(this)
	 
 	return this.hidden
 end
 
 if this.time_pren>=des_n.pren_t then
  if this.speech.done then
   this.time+=dt
   if this.time>des_n.ne_t-1 then
   	this.start_hide=true
   	music(0)
   end
  else
   update_speech(this.speech)
  end
 else
  this.time_pren+=dt
 end
 
 if this.speech.done and
    not this.n_sfx then
  mr_not.init(mr_not)
  this.n_sfx=true
  sfx(sfx_not)  	
 end
 
 return false
end

function ln_draw(this) 
 cls()
 
 if this.time_pren<des_n.pren_t then
  draw_all_n(this)
 	return
 end
 
 not_enough_camera(
     this.start_hide or (
     this.speech.done))
	
 draw_all_n(this)
	
	if this.time<=des_n.ne_t then
	 not_enough(this.speech.done)
	end
	
 print_speech("")
	draw_speech(this.speech)
 
end

function draw_all_n(this)
	if(this.lvl>2)then
  draw_all()
 else
  if(this.lvl>1) then
 	 draw_speech_border()
 	 player.draw(player)
 	else
 	 draw_speech_border()
		end
 end
end

function check_hidden(t)
 t.hidden=false
 
 local hidden=true
	for i=1,#allobj do
	 local w=allobj[i]
  if not whidden(w) then
  	hidden=false
  	break
  end
 end
 
 t.hidden=hidden
end
-->8
--level exe

--design values
des_lvl=
{
 max_t=3,
 max_at=1.5,
 ne_t=1.25,
 shake_stop=0
}

function create_level(lvl)
	local level=
	{
	 lvl=lvl,
	 init=l_init,
	 update=l_update,
	 draw=l_draw,
	 not_enough=false,
	 ne_t=0,
	 e_walls=false
	}
	
	return level
end

function l_init(this)
 sfx(17,-2)
 camera()
 
 player.dx=0
 player.dy=0
 this.player_x=player.x
 this.player_y=player.y

--z btn
 this.z_done=false
 if(this.lvl!=1) this.z_done=true
 
--arrow
 this.arrow_pressed=false
 this.arrow_done=false
 this.a_time=0
 if(this.lvl!=2) this.arrow_done=true

--buttons
 this.but_done=false
 
--trap
 this.trap_hurt=false
 
--coin
 this.coin_done=false
 
--price
 this.price_done=false
 this.price_hurt=false

--common
 this.time=0
 this.is_over=false
 
	this.not_enough=false
	this.ne_t=0
	
	this.e_walls=false
	
	this.timer_done=false
end
 
function l_update(this)
 if(this.not_enough) then
  lvl_not_enough(this)
		return false
 end
 
	if(this.lvl>3)then
  mr_not.update(mr_not)
 end
 
 foreach(coins,function(w)
  w.update(w)	
 end)
 foreach(prices,function(w)
  w.update(w)	
 end)
 foreach(buts,function(w)
  w.update(w)	
 end)
 foreach(traps,function(w)
  w.update(w)	
 end)
 
 timer.update(timer)
 
 if this.lvl!=1 then
  player.update(player)
 end
 
 check_timer(this) 
 check_trap(this) 
 check_z_done(this)
 check_arrow(this)
 check_but(this)
 check_coin(this) 
 check_price(this) 
 
 if(should_reset(this)) then
 	lvl_reset(this)
 end
 
 check_is_over(this)
 
 return this.is_over
end

function l_draw(this)	
 cls()
 
 if(not this.is_over) then
 	 not_enough_camera(
       this.not_enough and
 	     this.ne_t<des_lvl.ne_t
 	     -des_lvl.shake_stop)
 
 end
 
 if(this.lvl>3)then
  draw_all()
 else
 	if(this.lvl>2) then
 	 foreach(buts,function(w)
		  w.draw(w)	
		 end)	 
 	end
 	if(this.lvl>1) then
 	 draw_speech_border()
		 player.draw(player)
 	else
 	 draw_speech_border()
		end
 end
 if(this.not_enough)then 
		 player.draw(player)
 end
 
 not_enough(this.not_enough)
 
 local str=lvl_request[this.lvl]
 print_speech(str)
end

--reset

function should_reset(this)
	return this.trap_hurt or
	       this.price_hurt or
	       this.timer_done
end

function lvl_reset(this) 
 this.not_enough=true
 sfx(sfx_not)  
end

function lvl_not_enough(this)

	player.repos()
	
	this.ne_t+=dt
	if(this.ne_t>des_lvl.ne_t-0.25) then		  
	 player.resetpos()
	end	 
	if(this.ne_t>des_lvl.ne_t) then		  
	 
	 load_lvl(this.lvl,true)
	 
	 l_init(this) 
	end
end

--check

function check_is_over(this)
	this.is_over= this.z_done and
	       this.arrow_done and
	       this.but_done and
	       this.coin_done and
	       this.price_done 
end

function check_timer(this)
	this.timer_done=timer.done
end

function check_but(this)
 if(this.but_done) return
 
 for i=1,#buts do
  local w=buts[i]
  
  if collide(player,
             w) then
  	w.press(w)
  end
 end
 
	this.but_done=true
 foreach(buts,function(w)
	 this.but_done=
	    this.but_done and
	    w.pressed	 
 end)
end

function check_coin(this)
 if(this.coin_done) return
 
 for i=1,#coins do
  local w=coins[i]
  
  if collide(player,
             w) then
  	w.grab(w)
  end
 end
 
	this.coin_done=true
 foreach(coins,function(w)
	 this.coin_done=
	    this.coin_done and
	    w.grabbed	 
 end)
end

function check_price(this)
 if(this.price_done) return
 
 for i=1,#prices do
  local w=prices[i]
  
  if collide(player,
             w) then
   if this.coin_done then
  	 w.grab(w)
  	else
  	 this.price_hurt=true
			end
  end
 end
 
	this.price_done=true
 foreach(prices,function(w)
	 this.price_done=
	    this.price_done and
	    w.grabbed	 
 end)
end

function check_trap(this) 
 if(this.trap_hurt) return
 
 local collided=false
 
 local index=0
 for i=1,#traps do
  local w=traps[i]
  
  if(w.is_active(w)) then
	  if collide(player,
	             w) then
	  	collided=true
	  	--sfx
	  	break
	  end
  end
 end
 
 this.trap_hurt=collided
end

function check_arrow(this)
 if(this.arrow_done) return
 
	if not this.arrow_pressed then
		this.arrow_pressed = 
		     btn(0,0) or
		     btn(1,0) or
		     btn(2,0) or
		     btn(3,0)		
	end
	
	if this.arrow_pressed then
	 this.a_time+=dt
	end
	
	if this.a_time>des_lvl.max_at then
		this.arrow_done=true
	end
end

function check_z_done(this)
 if(this.z_done) return
 
	this.z_done=btnp(4,0)
end
-->8
--player

player_start={8*8,8*12}

player=
{
 shown=false,
 x=13,
 y=16,
 sx1=13,
 sy1=16,
 sx2=13,
 sy2=16,
 w=6,
 h=6,
 dx=0,
 dy=0,
 spr=1,
 startx=0,
 starty=0,
 d_state=0,
 d_time=0,
 disttime=0,
 sprtime1=0.25,
 sprtime2=0,
 sprdist1=0,
 sprdist2=0,
 sfxp=false
}

--design values
des_pl=
{
 d_extra_acc=0.25,
 d_acc=0.15,
 d_brake=0.25,
 spd_max=70*dt, --seconds to frame
 coll_brake=0.3
}

player.show=
function()
	player.start_shown=true
end

player.init=
function(this)
 this.x=player_start[1]
 this.y=player_start[2]
 this.sx1=this.x
 this.sy1=this.y
 this.sx2=this.x
 this.sy2=this.y
end

player.update=
function(this)
 this.update_dv(this)
 
 this.move(this)
 updatecircles()
 
 this.disttime+=dt
 this.sprtime1+=dt
 this.sprtime2+=dt
	this.sprdist1=0.1+
	   abs(1*sin(this.disttime/1.5))
	this.sprdist2=0.1+
	   abs(1*sin(this.disttime/1.75))

 this.sprtime1=0
 this.sprtime2=0
	this.sprdist1=0
	this.sprdist2=0
end

--update velocity
player.update_dv=
function(this)
 --update dx
 local xdir=0
 if( btn(1,0)) xdir+=1
 if( btn(0,0)) xdir-=1
 
 local dx=this.dx
	if xdir !=0 then
	 if sgn(xdir)!=sgn(dx) then
	  --slow faster if changed dir
	  dx+=des_pl.d_extra_acc*xdir
  end
	 dx+=des_pl.d_acc*xdir
 else
  dx-=dx*des_pl.d_brake
  if(abs(dx)<eps) dx=0
 end      
 
 --update dy
 local ydir=0
 if( btn(3,0)) ydir+=1
 if( btn(2,0)) ydir-=1
 
 local dy=this.dy
	if ydir !=0 then
	 if sgn(ydir)!=sgn(dy) then
	  --slow faster if changed dir
	  dy+=des_pl.d_extra_acc*ydir
  end
	 dy+=des_pl.d_acc*ydir
 else
  dy-=dy*des_pl.d_brake
  if(abs(dy)<eps) dy=0
 end 
 
 local speed=sqrt(dx*dx+dy*dy)
 if speed>des_pl.spd_max then
 	local diff=des_pl.spd_max/speed
  dx*=diff
  dy*=diff
 end
  
 this.dx=dx
 this.dy=dy
 
 if(abs(this.dx)<0.25 and 
    abs(this.dy)<0.25)then
 	sfx(17,-2)
 	this.sfxp=false
 elseif not this.sfxp then
 	this.sfxp=true
 	sfx(17,3)
 end
end

--move
player.move=
function(this)
 if(this.dx==0 and this.dy==0) return
 
 local oldx=this.x
 local oldy=this.y
 
 this.x+=this.dx
 
 local collided=false
 for i=1,#walls do
  local w=walls[i]
  
  if collide(this,w) then
  	collided=true
  	break
  end
 end
 
 if collided then
  this.x=oldx
  this.dx-=this.dx*des_pl.coll_brake
  if(abs(dx)<eps) dx=0
 end
 
	this.y+=this.dy
 
 local collided=false
 for i=1,#walls do
  local w=walls[i]
  
  if collide(this,w) then
  	collided=true
  	break
  end
 end
 
 if collided then
  this.y=oldy
  this.dy-=this.dy*des_pl.coll_brake
  if(abs(dy)<eps) dx=0
 end
 
 
 
end

--draw

player.draw=
function(this)
 if (not this.start_shown) return
	
	if this.start_shown and
	   not this.shown then
	 local maxtas=0.75
		this.d_time+=dt
		if this.d_time>maxtas then
			this.d_time-=maxtas
			this.d_state+=1
			if(this.d_state==3)then
				this.shown=true
			end
		end
	end
	
	if (this.d_state==0) return
	
	if this.d_state==1 then
		pal(2,0)
		pal(12,0)
		pal(9,1)
	elseif this.d_state==2 then
		pal(2,1)
		pal(12,1)
	end
	
	spr(2,this.x-3,this.y-3)
	spr(3,this.sx1-3,this.sy1-3)
	spr(4,this.sx2-3,this.sy2-3) 
	
 pal()
end

player.hitbox=
function(this)
	local x0=this.x-this.w/2+1
 local x1=this.x+this.w/2 
 local y0=this.y-this.h/2+1
 local y1=this.y+this.h/2
 
 return {x0=x0,
         y0=y0,
         x1=x1,
         y1=y1}
end

function loadplayer(lvl)
 lvl-=1
	for y=0,15 do
	 for x=0,15 do
	 local tile=mget(
			(lvl%8)*16+x,y+flr(lvl/8)*16)
		
			if tile==1 then
			 player.startx=x*8+3
			 player.starty=y*8+3
			end
		end
	end
end


player.resetpos=
function ()
 player.x=player.startx
 player.y=player.starty
 player.sx1=player.x
 player.sy1=player.y
 player.sx2=player.x
 player.sy2=player.y
end

player.repos=
function ()
 local damp=0.125
	player.x+=(player.startx-player.x)*damp
	player.y+=(player.starty-player.y)*damp
	          
	updatecircles_ex(0.50)
	
 if(abs(player.startx-
	          player.x)<0.75)then
 	player.x=player.startx
 end
 
 if(abs(player.starty-
	          player.y)<0.5)then
 	player.y=player.starty
 end
 
 player.sprtime1=rnd(1)
 player.sprtime2=rnd(1)
	player.disttime=0
 
end

function updatecircles()
	local damp=0.35
	updatecircles_ex(damp)
end

function updatecircles_ex(damp)
	player.sx1+=(player.x-player.sx1)*damp
	player.sy1+=(player.y-player.sy1)*damp
 
 if(abs(player.sx1-player.x)<0.1)then
 	player.sx1=player.x
 end
  if(abs(player.sy1-player.y)<0.1)then
 	player.sy1=player.y
 end
 
	player.sx2+=(player.sx1-player.sx2)*damp
	player.sy2+=(player.sy1-player.sy2)*damp

 if(abs(player.sx2-player.sx1)<0.1)then
 	player.sx2=player.sx1
 end
 if(abs(player.sy2-player.sy1)<0.1)then
 	player.sy2=player.sy1
 end
end
-->8
--wall

wall_tile=16
walls={}

e_wall_tile=18
e_walls={}

function create_wall
         (x,y,fast)
	local wall=
	{
	 special=false,
	 stt=4,
	 v_max=1,
	 x=x,
	 y=y,
	 spr=16,
	 pre_draw=wall_pre_draw,
	 post_draw=wall_post_draw,
	 hitbox=wall_hitbox,
	 state=0,
	 v_state=0,
	 time=0,
	 start=false,
	}
	
	if(fast) then
		_wshow(wall)
	end
	
	return wall
end

function wall_pre_draw(w)
 if(w.v_state==4) then
  spr(w.spr+1,w.x,w.y+8)
 else
 	if(w.v_state==1) then
 	 pal(1,0)
 	 pal(2,1)
   spr(w.spr,w.x,w.y+2)
   pal()
		elseif w.v_state==2 then
   spr(w.spr,w.x,w.y+2)
		elseif w.v_state==3 then
   spr(w.spr+1,w.x,w.y+8)
   spr(w.spr,w.x,w.y+1)
		end
 end
end

function wall_post_draw(w)
 if(w.v_state==4) then
  spr(w.spr,w.x,w.y)
 else
 	if(w.v_state==1) then
 	 pal(1,0)
 	 pal(2,1)
   spr(w.spr,w.x,w.y+2)
   pal()
		elseif w.v_state==2 then
   spr(w.spr,w.x,w.y+2)
		elseif w.v_state==3 then
   spr(w.spr,w.x,w.y+1)
		end
 end
end

function load_wall(lvl,fast)
 lvl-=1 
 walls={}
	for y=0,15 do
	 for x=0,15 do
			local tile=mget(
			(lvl%8)*16+x,y+flr(lvl/8)*16)
			if tile==wall_tile then
				local w=create_wall
				      (x*8,y*8,fast)
				add(walls,w)
				add(allobj,w)
			end
		end
	end
end

function wall_hitbox(this)
	local x0=this.x 
 local x1=this.x+8 
 local y0=this.y+1  
 local y1=this.y+8
 
 return {x0=x0,
         y0=y0,
         x1=x1,
         y1=y1}
end

function load_e_wall(lvl)
 lvl-=1 
 e_walls={}
	for y=0,15 do
	 for x=0,15 do
			local tile=mget(
			(lvl%8)*16+x,y+flr(lvl/8)*16)
		
			if tile==e_wall_tile then
				local w=create_wall
				      (x*8,y*8)
				add(e_walls,w)
			end
		end
	end
end

--show hide
function wstart(w)
	w.start=true
end

function show_w(w)
 if(w.special) then
 	return w.show(w)
 end
 
 if(not w.start) return
 if(w.state>=1) return
 
 if(w.v_state==0) then
 	w.v_state=1
 else
	 w.time+=dt
		if(w.time>w.v_max) then
			w.time-=w.v_max
		 w.v_state+=1
			if(w.v_state==w.stt)then
				_wshow(w)
			end
		end
	end
end

function wshown(w)
 if(w.special) then
 	return w.shown(w)
 end
 
	return w.state==1
end

function _wshow(w) 
	w.state=1
	w.v_state=w.stt
	w.time=0
	w.start=false
end

function hide_w(w)

 if(w.special) then
 	return w.hide(w)
 end
 
 if(not w.start) return
 if(w.state<1) return
 
 if(w.v_state==w.stt) then
 	w.v_state-=1
 else
	 w.time+=dt
		if(w.time>w.v_max) then
			w.time-=w.v_max
		 w.v_state-=1
			if(w.v_state==0)then
				_whide(w)
			end
		end
	end
end

function whidden(w)
 if(w.special) then
 	return w.dx==w.sdx and 
         w.dy==w.sdy
 end
 
	return w.state==0
end

function _whide(w)
	w.state=0
	w.v_state=0
	w.time=0
	w.start=false
end
-->8
--button

buts={}

function create_but
         (x,y,fast)
	local but=
	{
	 special=false,
  v_max=1,
  stt=3,
	 x=x,
	 y=y,
	 w=2,
	 h=2,
	 spr=32,
	 spr_dx=0,
	 spr_dy=0,
	 pressed=false,
	 press=but_press,
	 update=but_update,
	 draw=but_draw,
	 hitbox=but_hitbox,
	 state=0,
	 v_state=0,
	 time=0,
	 start=false,
	 fstart=but_start
	}
	
	but.sprtime=flr(rnd(2))
	
	but.x+=but.spr_dx
	but.y+=but.spr_dy
	
	if(fast) then
		_wshow(but)
	end
	
	return but
end

function but_update(w)
 w.sprtime+=dt
end
	 
function but_draw(w)
 if w.pressed and 
    w.v_state>=1then 	
  spr(101,
     w.x-w.spr_dx,
     w.y-w.spr_dy+2)
 end
 if(w.v_state==3) then
	 local wspr=w.spr
	 if w.pressed then
	 	wspr+=2
	 end
	 
	 local sprn=w.sprtime
	 
	  spr(101,
	     w.x-w.spr_dx,
	     w.y-w.spr_dy+2)
	     
	 spr(wspr+sprn%2,
	     w.x-w.spr_dx,
	     w.y-w.spr_dy)
	else
		if(w.v_state==1) then
 	 pal(1,0)
 	 pal(2,1)
 	 pal(9,0)
		 spr(w.spr+2,
		     w.x-w.spr_dx,
		     w.y-w.spr_dy)
   pal()
		elseif w.v_state==2 then
		 spr(w.spr+2,
		     w.x-w.spr_dx,
		     w.y-w.spr_dy)
		end
	end
end

function load_but(lvl,fast)
 lvl-=1 
 buts={}
	for y=0,15 do
	 for x=0,15 do
			local tile=mget(
			(lvl%8)*16+x,y+flr(lvl/8)*16)
			if tile==32 then
				local w=create_but
				      (x*8,
				       y*8,fast)
				add(buts,w)
				add(allobj,w)
			end
		end
	end
end

function but_press(this)
	this.pressed=true
	this.v_state=this.stt-1
	sfx(16,1)
end

function but_hitbox(this)
	local x0=this.x+1 
 local x1=this.x+6 
 local y0=this.y+2 
 local y1=this.y+6
 
 return {x0=x0,
         y0=y0,
         x1=x1,
         y1=y1}
end
-->8
--trap

trap_tile=48
traps={}

des_trap=
{
 state_maxt={1,0.5,0.5},
 hurt_s=3
}

function create_trap
         (x,y,fast)
	local trap=
	{
	 special=false,
  v_max=1,
  stt=3,
	 x=x,
	 y=y,
	 w=8,
	 h=8,
	 spr=48,
	 spr_dx=0,
	 spr_dy=0,
	 state_t=0,
	 state_c=1,
	 is_active=is_active,
	 update=trap_update,
	 draw=trap_draw,
	 hitbox=trap_hitbox,
	 state=0,
	 v_state=0,
	 time=0,
	 start=false,
	 fstart=trap_start
	}
	
	trap.x+=trap.spr_dx
	trap.y+=trap.spr_dy
	
	if(fast)then
		_wshow(trap)
	end
	
	return trap
end

function trap_update(w)
 w.state_t+=dt
 
 local news=0
 
 local incr_t=0
 local state_maxt=des_trap.state_maxt
 for i=1,#state_maxt do
 	if w.state_t<=
 	     incr_t+state_maxt[i] then
 		news=i
 		break
		end
		incr_t+=state_maxt[i]
 end
 
 if news==0 then
 	w.state_t-=incr_t
 	news=1
 end
 
 if news!=w.state_c then
 	if (news == 3) sfx(20,1)
 	if (news == 2) sfx(19,1)
 	w.state_c=news
 end
 
end

function is_active(w)
	return w.state_c==des_trap.hurt_s
end

function trap_draw(w)     
 if(w.v_state==3) then
 
	  spr(101,
	     w.x-w.spr_dx,
	     w.y-w.spr_dy+2)
	     
	 spr(w.spr+w.state_c-1,
     w.x-w.spr_dx,
     w.y-w.spr_dy)
	else
		if(w.v_state==1) then
 	 pal(2,0)
 	 pal(8,1)
		 spr(w.spr,
		     w.x-w.spr_dx,
		     w.y-w.spr_dy)
   pal()
		elseif w.v_state==2 then
		 pal(2,1)
 	 pal(8,2)
		 spr(w.spr,
		     w.x-w.spr_dx,
		     w.y-w.spr_dy)
   pal()
		end
	end
end

function load_trap(lvl,fast)
 lvl-=1 
 traps={}
	for y=0,15 do
	 for x=0,15 do
			local tile=mget(
			(lvl%8)*16+x,y+flr(lvl/8)*16)
			if tile==trap_tile then
				local w=create_trap
				      (x*8,y*8,fast)
				add(traps,w)
				add(allobj,w)
			end
		end
	end
end

function trap_hitbox(this)
	local x0=this.x+2
 local x1=this.x+5 
 local y0=this.y+3  
 local y1=this.y+6
 
 return {x0=x0,
         y0=y0,
         x1=x1,
         y1=y1}
end
-->8
--coin

coin_tile=64
coins={}

function create_coin
         (x,y,fast)
	local coin=
	{
	 special=false,
  v_max=1,
  stt=3,
	 x=x,
	 y=y,
	 spr=64,
	 spr_dx=0,
	 spr_dy=0,
	 grabbed=false,
	 grab=coin_grab,
	 update=but_update,
	 draw=coin_draw,
	 hitbox=coin_hitbox,
	 state=0,
	 v_state=0,
	 time=0,
	 start=false,
	 fstart=coin_start
	}
	
	coin.sprtime=flr(rnd(2))
	
	coin.x+=coin.spr_dx
	coin.y+=coin.spr_dy
	
	if(fast)then
		_wshow(coin)
	end
	
	return coin
end

function coin_draw(w)
 if w.grabbed and 
    w.v_state>=1then 	
  spr(101,
     w.x-w.spr_dx,
     w.y-w.spr_dy+2)
 end
 if not w.grabbed then
	 if(w.v_state==3) then
	 
	 local sprn=w.sprtime
	 
  spr(101,
     w.x-w.spr_dx,
     w.y-w.spr_dy+2)
	     
	 spr(w.spr+sprn%2,
	     w.x-w.spr_dx,
	     w.y-w.spr_dy)
		else
			if(w.v_state==1) then
	 	 pal(15,1)
	 	 pal(9,1)
	 	 pal(2,0)
			 spr(w.spr,
			     w.x-w.spr_dx,
			     w.y-w.spr_dy)
	   pal()
			elseif w.v_state==2 then
	 	 pal(15,2)
	 	 pal(9,2)
	 	 pal(2,1)
			 spr(w.spr,
			     w.x-w.spr_dx,
			     w.y-w.spr_dy)
	   pal()
			end
		end
 end
end

function load_coin(lvl,fast)
 lvl-=1 
 coins={}
	for y=0,15 do
	 for x=0,15 do
			local tile=mget(
			(lvl%8)*16+x,y+flr(lvl/8)*16)
			if tile==coin_tile then
				local w=create_coin
				      (x*8,
				       y*8,fast)
				add(coins,w)
				add(allobj,w)
			end
		end
	end
end

function coin_grab(this)
if not this.grabbed then	
	sfx(14,1)
end

	this.grabbed=true
end

function coin_hitbox(this)
	local x0=this.x+2 
 local x1=this.x+5 
 local y0=this.y+1  
 local y1=this.y+6
 
 return {x0=x0,
         y0=y0,
         x1=x1,
         y1=y1}
end
-->8
--prize, typo now its there

price_tile=80
prices={}

function create_price
         (x,y,fast)
	local price=
	{
	 special=false,
  v_max=1,
  stt=3,
	 x=x,
	 y=y,
	 spr=80,
	 spr_dx=0,
	 spr_dy=0,
	 grabbed=false,
	 grab=price_grab,
	 update=but_update,
	 draw=price_draw,
	 hitbox=price_hitbox,
	 state=0,
	 v_state=0,
	 time=0,
	 start=false
	}
	
	price.sprtime=flr(rnd(2))
	
	price.x+=price.spr_dx
	price.y+=price.spr_dy
	
	if(fast) then
		_wshow(price)
	end
	
	return price
end

function price_draw(w)
 if w.grabbed and 
    w.v_state>=1then 	
  spr(101,
     w.x-w.spr_dx,
     w.y-w.spr_dy+2)
 end
 if not w.grabbed then	     
	 if(w.v_state==3) then
	 
		 local sprn=w.sprtime
	 
	  spr(101,
	     w.x-w.spr_dx,
	     w.y-w.spr_dy+2)
		 spr(w.spr+sprn%5,
		     w.x-w.spr_dx,
		     w.y-w.spr_dy)
		else
			if(w.v_state==1) then
	 	 pal(15,1)
	 	 pal(9,1)
	 	 pal(2,0)
			 spr(w.spr+5,
			     w.x-w.spr_dx,
			     w.y-w.spr_dy)
	   pal()
			elseif w.v_state==2 then
			 spr(w.spr+5,
			     w.x-w.spr_dx,
			     w.y-w.spr_dy)
			end
		end
 end
end

function load_price(lvl,fast)
 lvl-=1 
 prices={}
	for y=0,15 do
	 for x=0,15 do
			local tile=mget(
			(lvl%8)*16+x,y+flr(lvl/8)*16)
			if tile==price_tile then
				local w=create_price
				      (x*8,
				       y*8,fast)
				add(prices,w)
				add(allobj,w)
			end
		end
	end
end

function price_grab(this)
	if not this.grabbed then	
		sfx(13,1)
	end
	this.grabbed=true	
end

function price_hitbox(this)
	local x0=this.x+1
 local x1=this.x+6 
 local y0=this.y+2  
 local y1=this.y+6
 
 return {x0=x0,
         y0=y0,
         x1=x1,
         y1=y1}
end
-->8
--last level not enough

des_last=
{
 down=6,
 start_down=11,
 n_maxt=1.25,
 n_mint=0.10,
 brake=0.15,
 brake_d=0.12,
 random_pos={
            {10,20},
            {23,15},
            {17,-16},
            {5,-7},
            {13,-23},
            {7,15},
            {2,24},
            {21,3},
            {19,-4},
            {-5,21},
            {-10,18},
            {-20,-15},
            {-2,-17},
            {-13,-12},
            {-8,17}
            }
}

last_answer=
 "you are a good puppet...but"

function create_lastn(lvl,prev)
	
	local level=
	{
	 lvl=lvl,
	 prev=prev,
	 init=last_init,
	 update=last_update,
	 draw=last_draw
	}
	
	return level
end

function last_init(this)
 sfx(17,-2)
	player.dx=0
	player.dy=0
	
	this.timestart=0
	this.time=0
	this.time_pren=0
	
	this.rpos=des_last.random_pos
	
	this.ne={}
	this.n_time=0
	this.n_maxt=0
	this.n_sfx=false
	
	this.speech=
	     create_speech_ex(last_answer)
	       
 this.start_ex=false
	this.is_over=false
	
 this.vai=false
	
	this.last_y=des_last.down
	
	local prev=levels[this.prev]
	prev.e_walls=true
	 	
	foreach(e_walls,function(w)
  wstart(w)	
 end)
end

function last_update(this)
 if(this.timestart<1)then
 	this.timestart+=dt
 	if(this.timestart>=1)then
 	 music(0)
 		this.vai=true
		end
  updatecircles()	 
 	return false
 end 
 
 if(this.shown_ex) then
	 if this.time_pren>=des_n.pren_t then
	  if this.speech.done then
	   this.time+=dt
	  else
 	  music(-1)
	   update_speech(this.speech)
	  end
	 else
	  this.time_pren+=dt
	 end
	 
	 if not this.start_ex then
		 if this.time_pren>=des_n.pren_t
		    and this.speech.done then
		  
    mr_not.init(mr_not)
		  last_ne_update(this)	
		 end
	 else
	 	if not this.n_sfx then
		  this.n_sfx=true
		  sfx(-1,0)
		  this.is_over=true
		 end
	 end
 
  return this.is_over
 else
  updatecircles()	 	
 	foreach(e_walls,function(w)
	  show_w(w)	
	 end)
	 
	 check_shown_last(this)
 end
end

function check_shown_last(t)
 t.shown_ex=false
 
 local shown=true
	for i=1,#e_walls do
	 local w=e_walls[i]
  if not wshown(w) then
  	shown=false
  	break
  end
 end
 
 t.shown_ex=shown
end

function last_draw(this) 
 if this.time_pren<des_n.pren_t then
		local prev=levels[this.prev]
		
		if(this.vai)then
	  not_enough_camera(true)
		end		
		
		prev.draw(prev)
		print_speech("")
 	return
 end
 
 not_enough_camera(
    not this.shown_ex or
    this.speech.done)
	
	local prev=levels[this.prev]
	prev.draw(prev)
	
	last_ne_draw(this)	
 
end

function last_ne_update(this)
 if(this.last_y>80) then
   this.start_ex=true
  	return
 end

 local ne_x=0
 local ne_y=0
 
	if #this.ne==0 then
	 sfx(sfx_not,0)
	 add(this.ne,{ne_x,ne_y})
	 this.n_maxt=des_last.n_maxt
	else
	 this.n_time+=dt
  if(this.n_time>this.n_maxt) then
			local brake=0
			if #this.ne<des_last.start_down 
			   and #this.rpos>0then
				
				local rposi=rnd(this.rpos)
				del(this.rpos,posi)
				local r_x=ne_x+rposi[1]+rnd(10)-5
				local r_y=ne_y+rposi[2]+rnd(10)-5
				
			 add_ne(this,r_x,r_y,false)
			 brake=des_last.brake
			else
				local last_y=this.last_y
				last_y+=des_last.down
			 add_ne(this,ne_x,last_y,true)
				this.last_y=last_y
			 brake=des_last.brake_d
			end
		
		 this.n_time-=this.n_maxt
		 this.n_maxt-=this.n_maxt*brake
		 this.n_maxt=max(this.n_maxt,
		              des_last.n_mint)
		end
	end
end

function add_ne(this,x,y,last)
	sfx(sfx_not,0)
	
	local add_last=rnd(1)
	if(add_last<=1.2 or last) then
	 add(this.ne,{x,y})
	else
	 add(this.ne,{x,y},
			     flr(rnd(#this.ne))+1)
	end
	
end

function last_ne_draw(this)
	
	for i=1,#this.ne do
	 local x=this.ne[i][1]
	 local y=this.ne[i][2]
		not_enough_ex(true,x,y)
	end

 draw_speech_border()

 print_speech("")
	draw_speech(this.speech)
end
-->8
-- credit

des_cre=
{
 start_max=3,
 next_max=1,
 endt=1.25,
 speech_t={60,70,80}
}

cre_game_by_me=
 "a game made by elia"
cre_enough=
 "i hope it was enough for you"
cre_but=
 "...but"

function create_credit()
	
	local level=
	{
	 init=credit_init,
	 update=credit_update,
	 draw=credit_draw
	}
	
	return level
end

function credit_init(this)
	this.is_over=false
	
	this.state=0
	this.time=0
	this.next_t=0
	this.time_f=0
	this.fin=false
	
	this.speech1=
	     create_speech_y(
	       cre_game_by_me,
	       des_cre.speech_t[1])
	this.speech2=
	     create_speech_y(
	       cre_enough,
	       des_cre.speech_t[2])
	this.speech3=
	     create_speech_y(
	       cre_but,
	       des_cre.speech_t[3])
	this.speech4=
	     create_speech_y(
	       "     ",
	       des_cre.speech_t[3]+10)
	       
	this.n_sfx=false
end

function credit_update(this)
 
 if(this.fin) return this.is_over
 
 if this.speech4.done then
  this.time_f+=dt
  if(this.time_f>des_cre.endt) then
  	this.fin=true
  end
  return this.is_over
 end
 
 if this.time<des_cre.start_max then
 	this.time+=dt
 else
  if this.state==3 then
 	 update_speech(this.speech4)
  elseif this.state==2 then
 	 update_speech(this.speech3)
 	 if this.speech3.done then
 	 	this.state+=1
   end
  elseif this.state==1 then
 	 update_speech(this.speech2)
 	 if this.speech2.done then
 	 	this.next_t+=dt
 	 	if this.next_t>des_cre.next_max then
 	 		this.next_t-=des_cre.next_max
 	 		this.state+=1
				end
   end
 	elseif this.state==0 then
 		update_speech(this.speech1)
 	 if this.speech1.done then
 	 	this.next_t+=dt
 	 	if this.next_t>des_cre.next_max then
 	 		this.next_t-=des_cre.next_max
 	 		this.state+=1
				end
   end
		end
 end
 
 if this.speech4.done and
	    not this.n_sfx then
	  this.n_sfx=true
	  sfx(sfx_not) 
 end
 
 return this.is_over
end

function credit_draw(this)
 cls()
 
 if(this.fin) then
 	camera()
 	return
 end
 
 not_enough_camera(this.speech4.done)
		
	not_enough(this.speech4.done)
	
	draw_speech(this.speech1)
	draw_speech(this.speech2)
	draw_speech(this.speech3)
end
-->8
--mr not

mr_not=
{
 dx=0,
 dy=0,
 time=0
}

mr_not.init=
function(this)
	this.time=0
	this.dx=0
	this.dy=0
end

mr_not.update=
function(this)
	this.time+=dt
	
	local dist=0
	dist=min(10,10*this.time/2)
	
	this.dx=flr((cos(
	     this.time/5.5))*dist)
	this.dy=flr(sin(
	     this.time/5.5)*dist)
end

mr_not.draw=
function(this)
	
	draw_face(this)
	draw_hands(this)
end

function draw_face(this,x,y)

	local x=(128-46)/2-1+this.dx
	local y=16+this.dy+3-1
	
	sspr(9*8,0,3*8,6*8,x,y)
	sspr(9*8,0,3*8,6*8,x+3*8,y,
	     3*8,6*8,true)
	
	--hair  
	local hx=x   
	local hy=y   
	sspr(13*8,0,3*8,2*8,hx,hy)
	sspr(13*8,0,3*8,2*8,hx+3*8,hy,
	     3*8,2*8,true)
	     
	--eyes
	local elx=x+6
	local ely=y+10
	sspr(13*8,2*8,2*8,2*8,elx,ely)
	
	local erx=x+6+2*8+4
	local ery=y+10
	sspr(13*8,2*8,2*8,2*8,erx,
	     ery,2*8,2*8,true)
	     
	--pupil
	local plx=x+7+4
	local ply=y+10+6
	sspr(15*8,2*8,8,8,plx,ply)
	
	local prx=x+6+2*8+4+3
	local pry=y+10+6
	sspr(15*8,2*8,8,8,prx,
	     pry,8,8,true)	     
	     
	--dmouth
	local dmlx=x+9
	local dmly=y+31
	sspr(14*8,6*8,2*8,2*8,dmlx,dmly)
	
	local dmrx=x+9+14
	local dmry=y+31
	sspr(14*8,6*8,2*8,2*8,dmrx,
	     dmry,2*8,2*8,true)
	     
	--upmouth
	local umlx=x
	local umly=y+24
	sspr(13*8,4*8,3*8,2*8,umlx,umly)
	
	local umrx=x+3*8
	local umry=y+24
	sspr(13*8,4*8,3*8,2*8,umrx,
	     umry,3*8,2*8,true)
	     
	--chin
	local cx=x+20
	local cy=y+41
	sspr(12*8,4*8,8,8,cx,cy)
	
	
end

function draw_hands(this)

	local lx=(128-64)/2-this.dx
	local ly=72-this.dy-2
	
	sspr(5*8,0,4*8,5*8,lx,ly)
	
	
	local rx=(128-64)/2+32-this.dx
	local ry=72-this.dy-2
	sspr(5*8,0,4*8,5*8,rx,ry,
	     4*8,5*8,true)
end



-->8
--back

backs={}

des_back=
{
 col=1,
 max_b=80, --100
 size=8,
 damp=0.95,
 bdamp=0.95,
 maxm=5
}

function create_back
         (x,y,spr_r,fast)
 
	local back=
	{
	 special=true,
	 x=x,
	 y=y+2,
	 sdx=0,
	 sdy=0,
	 dx=0,
	 dy=0,
	 stime=0,
	 time=0,
	 
	 spr=99+spr_r,
	 draw=back_draw,
	 hide=hide_back,
	 hidden=back_hidden,
	 show=show_back,
	 shown=back_shown,
	 state=0,
	 v_state=0,
	 time=0,
	 start=false
	}
	
	back.stime=rnd(0.2)
	
	local disp=200
	
	if(x<64) then
		back.sdx=disp
	else
		back.sdx=-disp
	end
	
	if(y<64) then
		back.sdy=disp
	else
		back.sdy=-disp
	end
	
	if(rnd(2)<1) then
		back.sdy=0
	else
		back.sdx=0
	end
	
	back.dx=back.sdx
	back.dy=back.sdy
	
	if(fast) then
		back_show(back)
	end
	
	return back
end

function show_back(w)
 if(not w.start) return
 if(w.dx==0 and w.dy==0) return
 
 if(w.time<w.stime)then
 	w.time+=dt
 	return
 end
 
 local ndx=w.dx-w.dx*des_back.damp
 local ddx=min(abs(ndx),
               des_back.maxm)
 
 w.dx+=(sgn(w.dx)*-1)*ddx
 
 local ndy=w.dy-w.dy*des_back.damp
 local ddy=min(abs(ndy),
               des_back.maxm)
 
 w.dy+=(sgn(w.dy)*-1)*ddy
 
 if(abs(w.dx)<1)then
 	w.dx=0
 end
 
 if(abs(w.dy)<1)then
 	w.dy=0
 end
 
 if(w.dx==0 and w.dy==0)then
 	back_show(w)
 end
end

function back_shown(w)
	return w.dx==0 and w.dy==0
end

function back_show(w)
	w.start=false
	w.dx=0
	w.dy=0
	w.time=0
end

function hide_back(w)
 if(not w.start) return
 if(w.dx==w.sdx and w.dy==wsdy) return

 if(w.time<w.stime)then
 	w.time+=dt
  if(w.time>=w.stime)then
   w.dx=w.sdx/100
   w.dy=w.sdy/100
  end
 	return
 end
 
 local ndx=w.dx/des_back.bdamp
 
 local ddx=min(abs(ndx),
               des_back.maxm)
 
 w.dx+=sgn(w.sdx)*ddx
 
 local ndy=w.dy/des_back.bdamp
 
 local ddy=min(abs(ndy),
               des_back.maxm)
 
 w.dy+=sgn(w.sdy)*ddy
 
 if(abs(w.dx-w.sdx)<10)then
 	w.dx=w.sdx
 end
 
 if(abs(w.dy-w.sdy)<10)then
 	w.dy=w.sdy
 end
 
 if abs(w.dx)>=abs(w.sdx) and 
    abs(w.dy)>=abs(w.sdy) then
 	back_hide(w)
 end
end

function back_hidden(w)
 return w.dx==w.sdx and 
        w.dy==w.sdy
end

function back_hide(w)
	w.start=false
	w.dx=w.sdx
	w.dy=w.sdy
	w.time=0
end

function back_draw(w)
 spr(w.spr,w.x+w.dx,w.y+w.dy)
end

function load_back(lvl,fast)
 backs={}
 
 if(lvl<=2 or lvl==max_lvl) return
 
 local pos_l=create_positions()
	while(#backs<des_back.max_b) do
	 if(#pos_l==0) break
	 local pos=rnd(pos_l)
	 del(pos_l,pos)
	 
	 local spr_r=flr(rnd(1))
	 
	 local temp=create_back(pos[1],
	       pos[2],spr_r,fast)
	 add(backs,temp)
	 add(allobj,temp)
	end
end

function create_positions()
	local positions={}
	local off=flr(rnd(0))
	local s=des_back.size
	
	local xend=flr(14*8/s)
	local yend=flr(12*8/s)
	
	for x=1,xend do
		for y=1,yend do
		 add(positions,{(x)*s+off,
		                (y)*s+off})
	 end
	end
	return positions
end
-->8
-- timer almost forgot lol

timer_t_s=112
timer_t_e=123
timer=
{
 valid=false
}

function create_timer(t)
 timer.maxt=t
 timer.time=0
 timer.done=false
 timer.valid=true
end

timer.update=
function(w)
 if (not timer.valid) return
 if (timer.done) return

 timer.time+=dt
 if(timer.time>timer.maxt+dt*3) then
 	timer.done=true
 end
end

timer.draw=
function(w)
 if(not w.valid) return
 
 local x=64-9-1
 local y=0
 rectfill(x,y,x+18,y+12,1)
 rectfill(x+1,y+1,x+16+1,y+10+1,2)
 rectfill(x+2,y+2,x+15+1,y+9+1,0)
 
 local t=ceil(w.maxt-
            w.time)
 t=max(t,0)
 local str=""
 if(t<10) then
 	str="0"..t
 else
 	str=t
 end
 
 print(str,60,4,str_color)
end

function load_timer(lvl)
 create_timer(0) --init timer, i'm running out of time soz
 timer.valid=false
 
 lvl-=1 
 coins={}
	for y=0,15 do
	 if(timer.valid) break
	 for x=0,15 do
			local tile=mget(
			(lvl%8)*16+x,y+flr(lvl/8)*16)
			if tile>=timer_t_s and
			   tile<=timer_t_e then
				local w=create_timer
				      ((tile-timer_t_s+1)*5+15)
				break
			end
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000066500000000000000000000066666600000000000000000000000222220000
00000000002222000022220000000000000000000000000000000000000000000666650000000000000000066666666600000000000000000000022000022220
00700700029999200200002000999900000000000000001000000000000000000666665000000000000006666666666600000000000000000000200000000022
00077000029cc9200200002000900900000cc0000000000000100000000000000666666000000000000666666666666600000000000222000022000000222222
00077000029cc9200200002000900900000cc0000000101110001111000000000666666500000000006666666666666600000000002002000220000022200002
00700700029999200200002000999900000000000000010000101111111000000666666500000000066666666666666600000000002022002000002200002222
00000000002222000022220000000000000000000000101001010111111188800666666500000006666666666666666600000000002000020000220000220000
00000000000000000000000000000000000000000000110110111111188888266666666500000006666666666666666600000000000222200000000222000000
222222221d1d1d1d2222222222222222000000000010010010110111888882666666665000000066666666666666666600000000000000000002222000000000
21111112d1d1d1d12111111221111112000000000000111111011111888826666666650000000666666666666666666600000000000000000220000000000000
21222212000000002122221221222212000000000000011111111118888826666666650000006666666666666666666600000000000000022000000000000000
2121121200000000212cc21221211212000000000000011111111118888266666666600000006666666666666666666600000000000000000000000000000000
2121121200000000212cc21221211212000000000000000111111118888266666666550000066666666666666666666600000000000000000000000000000000
21222212000000002122221221222212000000000000000001111118888266665565115000066666666666666666666600000000000000000000000000000000
21111112000000002111111221111112000000000000000000111118888266666651111500666666666666666666666600000000000000000000000000000000
22222222000000002222222222222222000000000000000000001118888266666651115100666666666666666666666600000000000000000000000000000000
0000000000000000000000001d1d1d1d000000000000000000000018888266666665111500666666666666666666666600000000000000000000000001100000
000000000000000000000000d1d1d1d1000000000000000000000000888826666666515106666666666666666666666600000000000011111770000011010000
02222220022222200000000000000000000000000000000000000000888882666666511506666666666666666666666600000000000111177777700010000000
02199120021dd1200222222000000000000000000000000000000000000882666666651106666666666666666666666600000000001117777777770011000000
02111120021111200219912000000000000000000000000000000000000008266666651506666666666666666666666600000000011177777777770001100000
02222220022222200211112000000000000000000000000000000000000000826666661106666666666666666666666600000000011777777777777000000000
0dddddd00dddddd00222222000000000000000000000000000000000000000006666665106666666666666666666666600000000011777777777777000000000
00000000000000000000000000000000000000000000000000000000000000006666665106666666666666666666666600000000017777777777771000000000
00000000000000000000000000000000000000000000000000000000000000000666665106666666666666666666666600000000017777777777771000000000
00000000000000000000000000000000000000000000000000000000000000000666666506666666666666666666666600000000017777777777711000000000
00000000000000000000d00000000000000000000000000000000000000000000666666506666666666666666666666600000000077777777777711000000000
0000000000000000000dd00000000000000000000000000000000000000000000666666506666666666666666666666600000000007777777777111000000000
000000000000d000000dd00000000000000000000000000000000000000000000666666506666666666666666666666600000000007777777771110000000000
02888820028858200285582000000000000000000000000000000000000000000666666500666666666666666666666600000000000777777111100000000000
02222220022222200222222000000000000000000000000000000000000000000666665000666666666666666666666600000000000007711110000000000000
00000000000000000000000000000000000000000000000000000000000000006666665000666666666666666666666600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000006666665000066666666666666666666655000055000000500000000000000000
00022000000200000000000000000000000000000000000000000000000000006666665000066666666666666666666600555500000000500000000000000000
002ff20000f2f0000000000000000000000000000000000000000000000000006666650000006666666666666666666600000000000005000000000000000000
00299200009290000000000000000000000000000000000000000000000000000666500000006666666666666666666600000000000055200000000000000000
00299200009290000000000000000000000000000000000000000000000000000000000000000666666666666666666600000000000000020000000000000000
00299200009290000005500000000000000000000000000000000000000000000000000000000066666666666666666600000000000000022000000000222200
00022000000200000055550000000000000000000000000000000000000000000000000000000006666666666666666600000000000000002220000022222220
00000000000000000005500000000000000000000000000000000000000000000000000000000006666666666666666600000000000000002222222222222222
00000000000000000000000000000000000000000000000000000000000000000000000000000000066666666666666600000000000000000222222222222222
00000000000000000009f00000000000000000000000000000000000000000000000000000000000006666666666666600000000000000000012222221112222
0009f00000000000000990000009f000000000000000000000000000000000000000000000000000000666666666666600000000000000000011122111011112
221991222219f12222122122221991222219f1220009f00000000000000000000000000000000000000006666666666600000000000000000000111100000011
21111112211111122111111221111112211111122219912200000000000002220000000000000000000000066666666600000000000000000000000000000000
222222222222222222222222222222222222222221111112000000000000ccccacc0000000000000000000000066666600000000000000000000000000000000
dddddddddddddddddddddddddddddddddddddddd22222222000000000000cdcccdc0000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000ccccccc0000000000000000000000000000000000000000000000000000000000000
000100000000000000100000111111111111111111111111000000000000cc111cc0000000000000000000000000000000000000000000008000000001000000
011111000555555001110000101111011001100110111101000000000000ccccccc0000000000000000000000000000000000000000000008000000111101000
010001000500005011011000111111111011110111111111000000000000c02220c0000000000000000000000000000000000000000000000810000111111100
110001100500005001110000111111111111111111111111000000000000c00400c0000000000000000000000000000000000000000000000811111118111110
01000100050000500010000011111111111111111111111100000000000000000000000000000000000000000000000000000000000000000081111888888110
01111100050000500000000011111111101111011111111100000000000000000000000000000000000000000000000000000000000000000008888888888880
00010000055555500000000010111101100110011011110100000000000000000000000000000000000000000000000000000000000000000000088888888880
00000000000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000888000880
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080
66606660666066606660666066606660606066606060666066606660666066606660666066606660666066606660666066606660000000000000000000000000
00606060006060000060606000606000606060606060600060006060600060006000606060006000006060600060600060606060000000000000000000000000
66606060666066600660606006606660666060606660666066606060666066606660606066606660006060600060666066606060000000000000000000000000
60006060600000600060606000600060006060600060006000606060006000606060606060600060006060600060006060606060000000000000000000000000
66606660666066606660666066606660006066600060666066606660666066606660666066606660006066600060666066606660000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000082000000000000000720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000082000000000000007820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00788800000082000000000000007820077882000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000
00788880000082000000000000008200088220000000000000000000000000000000000000000000000000000007800000000000000000000000000000000000
00788880000088200000000000008808882200000000000000000000000000000000000000000000000000000007820000000000000000000000000000000000
07788888000088200000000000778888222000000000782200000000000000000000000000000000000000000000720000000000000000000000000000000000
07888888000088200000000000888882200000000077888220000000000000000000007000082000000782000000720000000000000000000000000000000000
07882888800088200007778200008882000000000778820022000000000000007222007880088200000788200000720000000000000000000000000000000000
07882888880088200077888820000880000000008888888002008000000000078882207780008200007808200000720000000000000000000000000000000000
07882088888088200078888820000880000000008820088882007800222000788008200780008200078008200000720082200000000000000000000000000000
08882008888888200088208820000888000000008820008880007888882000820008200880008200078008220007820888220000000000000000000000000000
08882000888888200088200820000882000000000822000000007888882200820008200882088200088228820007888888820000000000000000000000000000
08820000888888200882000820000882000000000882200000007880088200822288200888888200088888820008888008820000000000000000000000000000
88820000088882000882000820000082000000000088222000008800088200888882000088888000008800820008880000820000000000000000000000000000
88200000008882000882008820000082000000000008888000008800088200088880000000080000000000820000880000820000000000000000000000000000
88200000000882000088888800000002000000000000800000008800008200000000000000000000008888200000800000820000000000000000000000000000
82000000000000000000888000000000000000000000000000008000008800000000000000000000088888800000000000000000000000000000000000000000
20000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
0000000000000000000000000000000010000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000001010000000000000000000000000000010100000000000000000000000000000101010100000003000004000000000001010000000000000000000000000000010
0000000000000000000000000000000010000000000000000000000000000010100020000000000000000000000000101000010000000000000000000000001010000010101010101010303030000010100010101000000000000010101000101010000030003000404040000001001010000000400000000000004000000010
0000000000000000000000010000000010000000000000000000000000000010100000000000000000000000000000101010101010101010101010101000001010000010101000000010000000000010100000303000100000100030300000101000000030000000004000000000001010000000100040000040001000000010
0000000000000000000000000000000010000000000000000000000000000010100000000000000000000000000000101000000000000000000000001000001010000010101000300010100000000010100000303000103030100030300000101000001010101010101010101010101010000000100010000010001000000010
0000000000000000000000000000000010000000000000000000000000000010100000000000000000000000000000101000000000000000000000001000001010000000000000300010100030303010100000303000103030100030300000101000300000001010101000003030401010000000100010000010001000000010
0000000000000000000000000000000010000000000000000000000000000010100000000000000000000000000000101000001010101010101000001000001010101010101010100010100000000010100000303000100000100030300000101000000000000000000000003030401010000010101010101010101010000010
0000000000000000000000000000000010000000000000000000000000000010100000000000000000000000000000101000001000000000001000001000001010101010000000100010000000000010100000303000100000100030300000101010101010101000001010101010101010000010303030575830303010000010
0000000000000000000000000000000010000000000000000000000000000010100000000000000000000000000000101000001000200000001000001000001010101010000100100010003030300010100000000010100000101000000000101000000000101000001010000000001010000010303030676830303010000010
0000000000000000000000000000000010000000000000000000000000000010100000000000000000000000000000101000001000000010001000001000001010101010000000100010000000000010101010103010000100001030101010101000403040101000001010403040001010000010101010101010101010000010
0000000000000000000000000000000010000000000010101010000000000010100000000000000000000000000000101000001010101010001000001000001010101010000000300010100000000010100000000010101010101000000000101000000000101000001010000000001010000000000000000000000000000010
0000000000000000000000000000000010000000000010000010000000000010100000000000000000000000000000101000000000000000001000000000001010101010000000300010303030303010100000300000000050000000300000101000001010101000001010101000001010000000000000000100000000000010
0000000000000000000000000000000010000000000010000110000000000010100000000000000001000000000000101000000000000000001000000000001010101010000000300010000050000010100000003030303030303030000000101000000000000000000000000000001010000000000000000000000000000010
0000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000
1010000040000040400000404000001010004000000000000000000000101010105050000000300000400000000000101050505040400000505040405040401010303030303000000000303030303010103030303030100000103030303030101000000000000000000000000000001000000000000000000000000000000000
1010301000303000003030000030301010404040000000404000000000001010105000003000300040404000000100101050405050505000505040405040401010303030300000010000003030303010103030303030100100103030303030101000000000000000000000000000001000000000000000000000000000000000
1000001000303000003030000030301010404040303010505010303000000010100000003000000000400000000000101050405040000000505000000000001010303030000000000000000030303010103010301030100000103010301030101000000000000000000000000000001000000000000000000000000000000000
1030101040000040400000404000001010004000101010101010101000400010100000505050505050505050505050101050405050505000505050505050001010303030000000000000000030303010103010301030100000103010301030101000000000000000000000000000001000000000000000000000000000000000
1000001010101010101010101010101010004000100010000010504000400010100030000000505050500000303040101050405050505000505050505050401010303030000000000000000030303010103030303030100000103030303030101000000000000000000000000000001000000000000000000000000000000000
1010001000000000003000000000001010004000100010000010504000400010100000000000000000000000303040101050405050505000505050505050401010303030300000000000003030303010101030303010100000101030303010101000000000000000000000000000001000000000000000000000000000000000
1000001000500001003000400040001010004000101010101010101000400010105050505050500000505050505050101050005040405000505050505050001010303030300000000000003030303010103010101030100000103010101030101000000000000000000000000000001000000000000000000000000000000000
1000101000000000003000404040001010004000405010000010001000400010100000000050500000505000000000101050004040404000000040404000001010303030303000000000303030303010103030303030100000103030303030101000000000000000000000000000001000000000000000000000000000000000
1000001010101010101000004000001010000000405010000010001040404010100040304050500000505040304000101050505050505050505050505050001010303030303000000000303030303010103030303030100000103030303030101000000000000000000000000000001000000000000000000000000000000000
1000003000404040003000000000001010000000101010101010101040404010100000000050500000505000000000101050505050505050505050505050401010303030303010121210303030303010103030303030101212103030303030101000000000001010101000000000001000000000000000000000000000000000
1000000030000000300000000000001010100100303010505010303000400010100000505050500000505050500000101000010000004040404000000040401010303030303010000010303030303010103030303030100000103030303030101000000000001000001000000000001000000000000000000000000000000000
1000003030303030303000000000001010101000000000404000000000000010100000000000000000000000000000101050505050505050505050505050501010303030303010002010303030303010103030303030100020103030303030101000000000001000011000000000001000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000
000000000000000000000000000000000078000000000000000000000000000000000000000000000000000000000000007b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000023050000002e0500000000000120500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000114501b450204502a4502b4502b4501445007450094501045015450194501c45010450024500145004450104501945021450164500245001450084501345021450134500b4500e45019450204501d450
0002002010623106001160312620136230f6001560313620106230f6200e6030f600106231262012623126000f6030e6200f62310600106030f6200e6230e6200f60310620106230f6000e6030e6200e60312620
000300212462500005000050f6250e62500005000051862516625166250000500005256252662500005000052462500005000050f6250e6250000500005186251662516625000050000525625266250000500005
000300212462500005000050f6250e62500005000051862516625166250000500005256252662500005000052462500005000050f6250e6250000500005186251662516625000050000525625266250000500005
000a00200663006630066300563005630056300563004630046300563006630066300663005630066300663006630066300563005630046300463004630046300563005630046300363003630036300363004630
0008000000000000000b6500b6501f6500b6500b650000002060015600000000665019650066500665000000000000b6500b650216500b650000000000009600000000000007650076501e65007650000000e600
000800000000000000086501b650086500865000000000000d6500d6500d65021650000000000000000056500565018650056500565000000000000b6500b6500b650216500b65000000000000e6501965000000
00080000000000000000000000000d6501f6500d6500d6500000000000000000000000000056501b6500565005650000000000000000126501f6501265000000000000000000000046501e650046500465000000
000a00200663006600066000563005630056300560004600046000560006600066300663005630066000660006630066300560005600046000460004630046300563005600046000360003630036300360004600
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001f0401c0401f0402200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001854013540185402250000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400000e5500e550005000955000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000300001575015750187501875019700197000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001000040b0260d0260e026100260e0060c0060a0060a0060a0060a0060b0060c0060c0060d0060e0061000611006100060e0060c0060a0060a0060b0060c0060d0060f00610006100060c006090060900600006
0010011f000060b0560e056100561205614056080560805608056080560b0560f0560f0560705607056080560405604056080560b0561005615056090560805607056070561a0561b0561c056070560705608056
000200001c1211c121001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101
000200001212112121001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101
010800000b6500b6501f6500b6500b650000000b600000000665019650066500665006600066000660000000000000b6500b650216500b650000000000009600000000000007650076501e65007650000000e600
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
01 08 42 43 44
00 08 42 43 44
02 0a 42 43 44
00 15 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
