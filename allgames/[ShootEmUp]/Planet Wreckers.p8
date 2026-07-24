pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- planet wreckers
-- started:  2019-04-15
-- finished: 2019-12-01
-- tokens:   7816
-- twitter:  @arashi256

version="1.0"

function init_player()
 plyr_w,plyr_h,plyr_xv=9,8,0
 plyr_x,plyr_y=64,127+30
 plyr_speed=1.5
 plyr_thrust_pcount,plyr_thrust_timer,plyr_laser_pcount,plyr_thrust_pmax,plyr_thrust_inc=0,0,0,250,.5
 plyr_has_control,plyr_invinc,plyr_invinc_tmer=false,false,0
 plyr_max_laser_counter=2
 plyr_scale,plyr_health,plyr_lasers=6,3,{}
 plyr_dmg_flash_tmr=0
end

function add_explosion(_x,_y,it,d)
 do_later(function()
  add(explosions,{x=_x,y=_y,r=0,is_expanding=true,etype=it})
 end,d)
end

function update_explosions()
 for e in all(explosions) do
  if e.is_expanding then
   e.r+=2
   if e.r>=15 then
    for a=0,1,0.025 do
     create_particle(e.x,e.y,2,ptype_explosion,a,e.etype)
    end
    shake_val+=0.1
    e.is_expanding=false
    sfx(4)
   end
  else
   e.r-=2
   if e.r<=0 then
    del(explosions,e)
   end
  end
 end
end

function draw_explosions()
 for e in all(explosions) do
  circfill(e.x,e.y,e.r,rnd(14)+2)
 end
end

function create_plyr_laser(_x,_y)
 add(plyr_lasers,{x=_x,y=_y,speed=2,w=1,h=7,sx=29,sy=0})
 sfx(3)
end

function update_inv_slots(r)
 grid_origin.x+=speed
 for i in all(inv_slots) do
  local xx=grid_origin.x-(grid_width/2)+((i.col-1)*i.w)+(invader_spacer*(i.col-1))+(i.w/2)
  local yy=grid_origin.y-(grid_height/2)+((i.row-1)*i.h)+(invader_spacer*(i.row-1))+(i.h/2)
  local dist=distance(grid_origin.x,grid_origin.y,xx,yy)
  i.x=grid_origin.x+cos(angle-i.angle)*dist
  i.y=grid_origin.y+sin(angle-i.angle)*dist
  if ((i.x+speed)+(i.w/2)>=140 or (i.x+speed)-(i.w/2)<=-12) and i.is_alive then
   speed=-speed
   return
  end
 end
 if r then 
  angle+=forma_rinc
  if angle>1 then angle=0 end
 end
end

function update_plyr_lasers()
 for l in all(plyr_lasers) do
  l.y-=l.speed
  if not worm_sector then
   for i in all(invaders) do
    if box_collide(l.x,l.y+(l.h/2),l.w,l.h,i.x-((i.w/2)*i.scale),i.y-((i.h/2)*i.scale),i.w*i.scale,i.h*i.scale) and i.is_alive then
     i.hp-=1
     sfx(5)
     if i.hp<=0 or (i.is_diving and not i.aim_slot) then
      i.is_alive=false
      inv_slots[i.num].is_alive=false
      add_explosion(i.x-(i.w/2),i.y-(i.h/2),i.type,0)
      if i.is_diving then
       dive_num-=1
       for a=0,1,0.33 do
        add_explosion(i.x-(i.w/2)+cos(a)*rnd(5)+3,i.y-(i.h/2)+sin(a)*rnd(5)+3,i.type,0.2)
       end
      end
      if i.is_diving and #saucers<1 then
       create_fadetext(i.x,i.y,"x2",100,true,0.1,true)
       bonus_kills+=1
       sfx(13)
       plyr_score+=(1*plyr_multiplier)
       if bonus_kills>=3 and count_dead_invaders()<total_invaders-2 then
        bonus_kills=0
        sfx(14)
        init_saucer(flr(rnd(2)))
       end 
      end
      plyr_score+=(1*plyr_multiplier)
     else
      i.flash_tmr=time()
     end
     del(plyr_lasers,l)
    end
   end
   for s in all(saucers) do
    if box_collide(l.x,l.y+(l.h/2),l.w,l.h,s.x-(s.w/2),s.y-(s.h/2),s.w,s.h) and not s.is_dying then
     s.is_dying=true
     add_explosion(s.x-(s.w/2),s.y-(s.h/2),s.type,0)
     if s.tx<0 then
      s.tx=flr(rnd(10)+20)
     else
      s.tx=127-flr(rnd(10)+10)
     end
     s.ty=flr(70)
     destroy_saucer(s,3)
    end
   end
  else
   if box_collide(l.x,l.y+(l.h/2),l.w,l.h,the_worm.x-(the_worm.w/2),the_worm.sine_y-(the_worm.h/2),the_worm.w,the_worm.h) then
    sfx(5)
    -- worm head collide.
    if the_worm.is_alive then
     if worm_count_alive_segs()<1 then
      the_worm.hp-=1
      the_worm.flash_tmr=time()
      if the_worm.hp<=0 then
       the_worm.is_alive=false
       add_explosion(the_worm.x,the_worm.y,19,0)
      end
     end 
     del(plyr_lasers,l)
    end
   end
   for seg in all(the_worm.segs) do
    if box_collide(l.x,l.y+(l.h/2),l.w,l.h,seg.x-(the_worm.w/2),seg.sine_y-(seg.h/2),seg.w,seg.h) and seg.is_alive then
     sfx(5)
     -- worm body collide.
     seg.hp-=1
     seg.flash_tmr=time()
     if seg.hp<=0 then
      seg.is_alive=false
      add_explosion(seg.x,seg.y,19,0)
     end
     del(plyr_lasers,l)
    end
   end
  end
  if l.y<-5 then
   del(plyr_lasers,l)
  end
  if plyr_laser_pcount<30*#plyr_lasers then
   plyr_laser_pcount+=1
   create_particle(l.x,l.y+(l.h/2),1,ptype_laser)
  end
 end
end

function destroy_saucer(s,d)
 local c=flr(rnd(3)+1)
 do_later(function()
  add_explosion(s.x-(s.w/2),s.y-(s.h/2),s.type,0)
  for a=0,1,0.33 do
   add_explosion(s.x-(s.w/2)+cos(a)*rnd(5)+3,s.y-(s.h/2)+sin(a)*rnd(5)+2,s.type,0.2)
  end
  if c==1 then
   plyr_multiplier=10
   create_fadetext(s.x,s.y,"x10 multiplier!",100,true,0.1,true)
   end_multiplier(5)
  elseif c==2 then
   plyr_health=3
   create_fadetext(s.x,s.y,"shield recharge!",100,true,0.1,true)
  else
   plyr_lives=mid(0,plyr_lives+1,3)
   create_fadetext(s.x,s.y,"+1 life!",100,true,0.1,true)
  end
  sfx(13)
  del(saucers,s)
 end,d)
end

function end_multiplier(d)
 do_later(function()
  plyr_multiplier=1
 end,d)
end

function rspr(sx,sy,sw,sh,px,py,r,s)
 for y=sy,sy+sh,1 do
  for x=sx,sx+sw,1 do
   col=sget(x,y)
   if col~=0 then
    local xx=(x-sx)-sw/2
    local yy=(y-sy)-sh/2
    local x2=(xx*cos(r)-yy*sin(r))*s
    local y2=(yy*cos(r)+xx*sin(r))*s
    local x3=flr(x2+px)
    local y3=flr(y2+py)
    if s>=1 then
     local w=flr(x2+px+s)
     local h=flr(y2+py+s)
     rectfill(x3,y3,w,h,col)
    else
     pset(x3,y3,col)
    end
   end
  end
 end
end

function init_saucer(r)
 local spath
 if r<1 then
  spath=3
 else
  spath=4
 end
 gen_invader(false,spath,6,false,0,0,1,1)
end

function update_saucers()
 for s in all(saucers) do
  update_invader_steer(s)
  if s.is_dying then 
   s.srotation+=0.02
   if s.srotation>1 then s.srotation=0 end
  end
 end
end

function draw_saucers()
 for s in all(saucers) do
  draw_invader(s)
 end
end

function whiteout(b,c)
 for i=1,15 do
  pal(i,b and c or i) 
 end
end

function box_collide(x1,y1,w1,h1,x2,y2,w2,h2)
 local outside_bottom=(y1+h1)<y2
 local outside_top=y1>(y2+h2)
 local outside_left=x1>(x2+w2)
 local outside_right=(x1+w1)<x2
 return not (outside_bottom or outside_top or outside_left or outside_right)
end

function draw_invaders()
 for i in all(invaders) do
  if i.is_alive then
   draw_invader(i)
  end
 end
end

function draw_invader(i)
 local flash,y_offset,spritesht_x,spritesht_y,ix,iy
 if i.flash_tmr>0 then flash=true else flash=false end
 if i.ani_flip then
  spritesht_x=i.s1_x
  spritesht_y=i.s1_y 
 else 
  spritesht_x=i.s2_x
  spritesht_y=i.s2_y 
 end
 ix=i.x-(i.scale*(i.w/2))
 iy=i.y-(i.scale*(i.h/2))
 if flash then 
  whiteout(true,rnd(15)+1)
  y_offset=iy-4
 else
  y_offset=iy 
 end
 if not i.is_dying then 
  sspr(spritesht_x,spritesht_y,i.w,i.h,ix,y_offset,i.scale*i.w,i.scale*i.h)
 else
  rspr(spritesht_x,spritesht_y,i.w-1,i.h,ix,iy,i.srotation,i.scale)
 end
 if flash then whiteout(false) end
 --pset(i.x,i.y,8)
end

function draw_plyr_lasers()
 for l in all(plyr_lasers) do
  sspr(l.sx,l.sy,l.w,l.h,l.x,l.y)
 end
end

function update_2dstars()
 local star_speed={0.5*lvl_star_speed,0.25*lvl_star_speed,0.13*lvl_star_speed}
 if not lvl_is_warping then
  if lvl_star_speed>2 then
   lvl_star_speed=lvl_star_speed/1.02
  end
 else
  if lvl_star_speed<6 then
   lvl_star_speed=lvl_star_speed*1.02
  end
 end
 for s in all(lvl_starfield) do
  if (plyr_x>0 and (plyr_x+plyr_w)<(127-plyr_w)) then s.x+=-plyr_xv/4 end
  s.y+=star_speed[s.t]
  if s.y>=127 then
   s.y=1
   s.x=flr(rnd(127)+1)
  end
 end
end

function draw_2dstars()
 for s in all(lvl_starfield) do
  pset(s.x,s.y,s.clr)
  if lvl_is_warping or lvl_warp_stars then
   stars_warp(lvl_warp_in)
   line(s.x,s.y,s.x,s.y+lvl_warp_stars_len,s.clr)
  end
 end
end

function stars_warp(_is_warp_in)
 if lvl_warp_stars then
  if _is_warp_in then
   lvl_warp_stars_len-=0.001
   if lvl_warp_stars_len<1 then
    lvl_warp_stars_len=1
    lvl_warp_stars,lvl_warp_in=false,false
    lvl_warp_angle=0
   end
  else
   lvl_warp_stars_len+=0.001
   lvl_warp_stars_len=mid(1,lvl_warp_stars_len,10)
  end
 end
end

function create_particle(_x,_y,_s,_t,_a,_it)
 local speed,angle,_age,_maxage
 speed=0.01+rnd(1)+0.1
 _age=flr(rnd(20))
 if _t==ptype_thrust then
  angle=rnd(0.15)+0.92
  _maxage=120
 elseif _t==ptype_laser then
  angle=rnd(0.10)+0.95
  _maxage=40
 elseif _t==ptype_explosion then
  angle=_a
  speed=2
  _maxage=20
 elseif _t==ptype_invlaser then
  angle=rnd(0.10)+0.45
  _maxage=40
 end
 add(particles,{x=_x,y=_y,dx=sin(angle)*speed,dy=cos(angle)*speed,s=_s,age=_age,type=_t,maxage=_maxage,it=_it})
end

function draw_particles()
 local c
 for p in all(particles) do
  if p.type==ptype_thrust then
   if p.age>80 then c=2
   elseif p.age>60 then c=8
   elseif p.age>40 then c=9
   elseif p.age>20 then c=10
   else c=7 end
  elseif p.type==ptype_laser then
   if p.age<20 then c=11
   else c=10 end
  elseif p.type==ptype_explosion then
   if p.age>28 then c=2
   elseif p.age>15 then c=inv_ex_colour[p.it][2]
   elseif p.age>8 then c=inv_ex_colour[p.it][1]
   else c=7 end
  elseif p.type==ptype_invlaser then
   if p.age<20 then c=14
   else c=8 end
  end
  rectfill(p.x-flr(p.s/2),p.y-flr(p.s/2),p.x+flr(p.s/2),p.y+flr(p.s/2),c)
 end
end

function update_particles()
 if plyr_thrust_pcount<plyr_thrust_pmax then
  if lvl_is_warping and plyr_y>-(plyr_h*plyr_scale*2) then
   create_particle(plyr_x+1,plyr_y+(plyr_scale*plyr_h)/2-plyr_scale,plyr_scale,ptype_thrust)
   plyr_thrust_pcount+=1
  end
 end
 for p in all(particles) do
  p.age+=1
  if p.age>p.maxage or p.y>127 or p.x>127 or p.x<0 then
   if p.type==ptype_thrust then 
    plyr_thrust_pcount-=1
   elseif p.type==ptype_laser then
    plyr_laser_pcount-=1
   elseif p.type==ptype_invlaser then
    inv_laser_pcount-=1
   end
   del(particles,p)
  else
   p.x+=p.dx*plyr_scale
   p.y+=p.dy*plyr_scale
  end
 end
end

function update_player()
 plyr_x+=plyr_xv
 plyr_x=mid(1+(plyr_w/2),plyr_x,127-(plyr_w/2))
 if lvl_is_warping then
  shake_val+=0.01
  plyr_warp(lvl_warp_in)
 end
 plyr_xv=plyr_xv/1.2
 plyr_thrust_timer+=1
 if plyr_thrust_timer>30 then
  plyr_thrust_timer=0
  plyr_thrust_inc=-plyr_thrust_inc
 end
 if plyr_disabled then
  if time()-plyr_disabled_tmr>=3 then
   plyr_disabled=false
   plyr_has_control=true
   sfx(7)
  end
 end
 if time()-plyr_dmg_flash_tmr>.2 then
  plyr_dmg_flash_tmr=0
 end
 if plyr_invinc and not plyr_disabled then
  plyr_invinc_tmr+=1
  if plyr_invinc_tmr>250 then
   plyr_invinc,plyr_invinc_flash,plyr_flash_tmr,plyr_invinc_tmr=false,false,0,0
  else
   plyr_flash_tmr+=1
   if plyr_flash_tmr>5 then
    plyr_invinc_flash=not plyr_invinc_flash
    plyr_flash_tmr=0
   end
  end
 end
end

function plyr_warp(_is_warp_in)
 local pylevel=127-plyr_h-2
 if lvl_warp_angle>1 then lvl_warp_angle=0 end
 if _is_warp_in then
  lvl_warp_angle+=0.002
  plyr_scale-=0.03
  plyr_scale=mid(1,plyr_scale,6)
  plyr_y=sin(lvl_warp_angle)*100+127+plyr_h*2
  if lvl_warp_angle>0.2 then
   lvl_warp_stars=true
  end
  if plyr_y>pylevel and lvl_warp_stars then 
   lvl_is_warping,plyr_has_control,aliengen_timer_paused=false,true,false
   plyr_y=pylevel
  end
 else
  if el_timer==0 then 
   lvl_warp_angle-=0.002
   plyr_scale+=0.01
  end
  plyr_scale=mid(1,plyr_scale,6)
  plyr_y=sin(lvl_warp_angle)*(200)+(127-(plyr_h/2*plyr_scale))
  if plyr_y>pylevel then plyr_y=pylevel end
  lvl_warp_stars=true
  if plyr_y<(-(plyr_h*plyr_scale)*2) then
   if el_timer==0 then el_timer=time() end
   if time()-el_timer>3 then
    -- will be next level.
    current_level+=1
    load_level(current_level)
   end
  end
 end
end

function draw_player()
 local px,py,is_mirrored,flash
 if not plyr_disabled then
  px=plyr_x-(plyr_scale*flr(plyr_w/2))
  py=plyr_y-(plyr_scale*flr(plyr_h/2))
  if (lvl_is_warping) then
   pal(9,11)
   pal(8,3)
  else
   if not plyr_invinc_flash then sspr(30,0,3,4,plyr_x-1,plyr_y+(plyr_h/2)-1-plyr_thrust_inc,3,4) end
  end
  if plyr_dmg_flash_tmr>0 then 
   flash=true
   py+=3 
  else 
   flash=false 
  end
  if flash then 
   whiteout(true,rnd(15)+1)
  end
  if not plyr_is_moving then
   if not plyr_invinc_flash then sspr(0,0,plyr_w,plyr_h,px,py,plyr_scale*plyr_w,plyr_scale*plyr_h) end
  else
   if plyr_xv>0 then
    is_mirrored=false
   elseif plyr_xv<0 then
    is_mirrored=true
   end
   if not plyr_invinc_flash then sspr(9,0,5,8,px,py,5,8,is_mirrored,false) end
  end
  pal()
  if flash then 
   whiteout(false)
  end
 end
end

function plyr_input()
 if plyr_has_control then
  plyr_is_moving=false
  plyr_w=9
  if btn(1) then
   if plyr_x+(1+plyr_w/2)<127 then
    plyr_xv=plyr_speed
    plyr_w=5
    plyr_is_moving=true
   end
  end
  if btn(0) then
   if (plyr_x-2)-flr(plyr_w/2)>0 then
    plyr_xv=-plyr_speed
    plyr_w=5
    plyr_is_moving=true
   end
  end
  if btnp(5) then
   if #plyr_lasers<plyr_max_laser_counter then
    create_plyr_laser(plyr_x,plyr_y-plyr_h-1)
   end
  end
 end
end

function screenshake()
 local shakex=16-rnd(32)
 local shakey=16-rnd(32)
 shakex*=shake_val
 shakey*=shake_val
 camera(shakex,shakey)
 shake_val*=0.90
 if (shake_val<0.02) shake_val=0
end

function format_number(s,n)
 local display=""..s
 local display_count=flr(#display)
 for i=flr(display_count),n do
  display="0"..display
 end
 return display
end

function draw_hud()
 local hlth_x=38
 local display_score=format_number(plyr_score,4)
 local x=1
 palt(0,false)
 rectfill(0,-4,127,8,0)
 palt(0,true)
 for l=1,plyr_lives do
  sspr(14,0,7,7,x,1,7,7,false,false)
  x+=10
 end
 for i=1,plyr_health do
  sspr(88,122,18,7,hlth_x,1)
  hlth_x+=20
 end
 print(display_score,127-(#display_score*4),3,7)
end
 
function _init()
 load_hiscore()
 boot_title()
end

function boot_title()
 sfx(8)
 t_flash_start=0
 title_colours={9,10,11,12,13,14}
 title_colour_count=1
 title_pal=title_colours[title_colour_count]
 t_start_text="press \142 or z to start"
 t_title_text="from the depths of space!"
 t_display_start=false
 t_starfield={}
 t_maxd=150
 for i=1,127 do
  local xp,yp=get_star_range(),get_star_range()
  local zp=rnd(t_maxd)
  add(t_starfield,{x=xp,y=yp,z=zp})
 end
 display_score="hiscore: "..format_number(""..high_score,4)
 _upd=update_title
 _drw=draw_title
end

function load_hiscore()
 cartdata("arashi256_the_node_planetwreckers_1_0")
 local hs=dget(0)
 if hs>0 then high_score=hs else high_score=0 end
end

function save_hiscore(hs)
 dset(0,hs)
end

function get_star_range()
 return flr(2500-rnd(2500*2))
end

function init_2dstars()
 local cols={13,5,1}
 for s=0,50 do
  local _t=flr(rnd(3)+1)
  add(lvl_starfield,{ x=flr(rnd(127)+1),y=flr(rnd(127)+1),t=_t,clr=cols[_t] })
 end
end

function update_title()
 if btnp(4) then
  start_game()
 end
 t_flash_start+=1
 if t_flash_start>10 then
  t_flash_start=0
  title_pal=title_colours[title_colour_count]
  title_colour_count+=1
  if title_colour_count>#title_colours then title_colour_count=1 end
  t_display_start=not t_display_start
 end
end

function start_game()
 current_level=1
 plyr_score,plyr_lives=0,3
 game_complete=false
 load_level(current_level)
 _upd=update_game
 _drw=draw_game
end

function clear_vars()
 lvl_starfield,particles,inv_slots,invaders,explosions,fadetext,inv_lasers,alive_invaders={},{},{},{},{},{},{},{}
 dive_num=0
 enable_worm=false
 worm_sector=false
 ptype_thrust,ptype_laser,ptype_explosion,ptype_invlaser=1,2,3,4
 grid_origin={x=64,y=50}
 angle,grid_width,grid_height=0,0,0
 dive_num=0
 default_speed=0.25
 gameover=false
 invader_turnspeed=0.85
 waypoint_radius=5
 pi=3.14159
 num_invader_rows=5
 num_invader_cols=8
 gen_num_invaders=num_invader_rows*num_invader_cols
 space_worm_spr={
  {44,24,52,24,8,10,76,24,86,24,10,8}, -- worm head
  {60,24,68,24,8,10}                   -- worm body
 }
 inv_type={
  {33,0,42,0,9,7},    --1 
  {51,0,60,0,9,7},    --2
  {69,0,78,0,9,7},    --3 
  {87,0,96,0,9,7},    --4
  {105,0,114,0,9,7},  --5
  {0,8,9,8,9,7},      --6
  {18,8,27,8,9,7},    --7
  {36,8,45,8,9,7},    --8
  {54,8,63,8,9,7},    --9
  {72,8,81,8,9,7},    --10
  {90,8,99,8,9,7},    --11
  {108,8,117,8,9,7},  --12
  {0,16,9,16,9,7},    --13
  {18,16,27,16,9,7},  --14
  {36,16,45,16,9,7},  --15
  {54,16,63,16,9,7},  --16
  {72,16,81,16,9,7},  --17
  {90,16,99,16,9,7},  --18
  {108,16,117,16,9,7} --19
 }
 inv_ex_colour={
  {12,13},            --1
  {11,3},             --2
  {10,9},             --3
  {14,8},             --4
  {12,13},            --5
  {6,5},              --6
  {11,3},             --7
  {11,12},            --8
  {14,13},            --9
  {9,12},             --10
  {10,9},             --11
  {12,3},             --12
  {8,11},             --13
  {12,4},             --14
  {14,9},             --15
  {2,14},             --16
  {10,13},            --17
  {6,3},              --18
  {11,9}              --19
 }
end

function update_timers()
 for t in all(timers) do
  if(not t()) del(timers,t)
 end
end

function do_later(fn,t)
 t+=time()
 add(timers, function()
  if (time()>t) fn() return
  return true
 end)
end

function load_level(level)
 if not game_complete then
  clear_vars()
  current_formation,current_mirror,current_loop,formarotate,forma_rinc,max_waves,type_offset,forma_rev,current_path_num,current_hp,current_scale,current_invader_fire_max,current_invader_fire_min,current_invader_dive_time=init_formation(level)
  --current_path,current_poffset=init_path(tonum(current_path_num))
  if current_path_num==-1 or current_formation==-1 or current_mirror==-1 or current_loop==-1 or formarotate==-1 or forma_rinc==-1 or max_waves==-1 or type_offset==-1 or forma_rev==-1 then
   -- the worm!
   init_worm(-30,30,8,10)
   worm_sector=true
   create_fadetext(64,64,"kill master space worm!",300,false,0,false)
  else
   invader_spacer=5
   saucers={}
   bonus_kills=0
   plyr_multiplier=1
   total_invaders=#current_formation/2
   init_inv_slots(num_invader_rows,num_invader_cols,invader_spacer)
   create_fadetext(64,64,"sector "..format_number(level,1),300,false,0,false)
  end
  sfx(-1)
  sfx(11)
  init_level_vars()
  sfx(0)
 else
  boot_title()
 end
end

function init_level_vars()
 inv_laser_pcount=0
 timers={}
 current_wave=1
 --speed=default_speed
 speed=0.25
 init_2dstars()
 init_player()
 lvl_warp_in,lvl_is_warping,aliengen_timer_paused=true,true,true
 lvl_warp_stars,plyr_has_control=false,false
 lvl_warp_stars_len=10
 lvl_star_speed=6
 aliengen_timer,shake_val,el_timer,lvl_warp_angle,end_level_tmr,alienshoot_timer=0,0,0,0,0,0
end

function reset_wave()
 for i in all(inv_slots) do
  i.is_alive=true
 end
 grid_origin={x=64,y=54}
 dive_num=0
 total_invaders=#current_formation/2
 aliengen_timer_paused=false
 invaders={}
 -- reverse current_loop string here.
 current_loop=reverse_data(current_loop)
 -- reverse current path mirror here. 
 current_mirror=reverse_data(current_mirror) 
end

function reverse_data(cloop)
 local nloop=""
 for i=1,#cloop do
  d=sub(cloop,i,i)
  if d=="0" then d="1" else d="0" end
  nloop=nloop..d
 end
 return nloop
end

function create_fadetext(x,y,nt,a,float,spd,r)
 add(fadetext,{x=flr(x-((#nt*4)/2))+3,y=y,text=nt,age=a,is_floating=float,speed=spd,rand=r})
end

function update_fadetext()
 for t in all(fadetext) do
  if t.is_floating then t.y-=t.speed end
  t.age-=1
  if t.age<=0 then
   del(fadetext,t)
  end
 end
end

function draw_fadetext()
 local c
 for t in all(fadetext) do
  if t.age>50 then if t.rand then c=rnd(5)+8 else c=7 end 
  elseif t.age>40 then c=6
  elseif t.age>30 then c=5
  elseif t.age>20 then c=2
  else c=1
  end
  print(t.text,t.x,t.y,c)
 end
end

function count_dead_invaders()
 local num=0
 for i in all(invaders) do
  if not i.is_alive then num+=1 end 
 end
 return num
end

function getbool(s)
 return s == "1"
end

function get_str_index(v,s,e,t)
 if t==1 then
  return getbool(sub(v,s,e))
 elseif t==2 then
  return tonum(sub(v,s,e))
 end
end

function update_game()
 if not gameover then
  if not worm_sector then
   update_invaders()
   update_saucers()
   update_inv_slots(formarotate)
   if not aliengen_timer_paused then
    aliengen_timer+=1
    if (aliengen_timer%30==0) then
     aliengen_timer=0
     if #invaders<gen_num_invaders then
      local ii=#invaders+1
      gen_invader(get_str_index(current_mirror,ii,ii,1),get_str_index(current_path_num,ii,ii,2),get_str_index(current_formation,(ii*2)-1,ii*2,2),get_str_index(current_loop,ii,ii,1),get_str_index(type_offset,ii,ii,2),get_str_index(forma_rev,ii,ii,2),get_str_index(current_hp,ii,ii,2),get_str_index(current_scale,ii,ii,2))
     else
      aliengen_timer_paused=true
     end
    end
   end
   if count_dead_invaders()>=total_invaders and end_level_tmr==0 then
    if current_wave==max_waves then
     end_level_tmr=time()
     create_fadetext(64,64,"invaders eliminated!",220,true,0.1,false)
     sfx(9)
    else
     current_wave+=1
     reset_wave()
    end
   end
  else
   if plyr_has_control and not enable_worm then enable_worm=true end
   if enable_worm then update_worm() end
  end
  update_timers()
  update_plyr_lasers()
  update_invader_fire()
  plyr_input()
  update_player()
  if end_level_tmr>0 and not lvl_is_warping then
   if time()-end_level_tmr>4 then
    lvl_warp_in,plyr_is_moving,plyr_has_control=false,false,false
    plyr_w=9
    lvl_is_warping=true
    sfx(0)
   end
  end
 else
  if time()-end_level_tmr>8 then
   boot_title()
  end
 end
 update_2dstars()
 update_fadetext()
 animate_invaders()
 animate_saucers()
 if worm_sector then animate_worm() end
 update_explosions()
 update_particles()
end

function draw_game()
 screenshake()
 draw_2dstars()
 draw_particles()
 if not gameover then
  draw_invader_fire()
  draw_plyr_lasers()
 end
 draw_explosions()
 if not worm_sector then
  draw_invaders()
  draw_saucers()
 else
  draw_worm()
 end
 draw_player()
 draw_fadetext()
 draw_hud()
 --debug
 --draw_inv_slots() 
 --print(current_poffset,1,120,7)
end

function draw_title()
 local offset
 local cols={13,5,1}
 for i=1,#t_starfield do
  t_starfield[i].z=t_starfield[i].z-1
  if t_starfield[i].z<=0 then
   t_starfield[i].z=t_maxd
  end
  local cz=t_starfield[i].z
  local cx=t_starfield[i].x/cz
  local cy=t_starfield[i].y/cz
  if cx<-64 or cx>64 then
   t_starfield[i].z=t_maxd
  end
  if cy<-64 or cy>64 then
   t_starfield[i].z=t_maxd
  end
  local ci=1+flr(cz/t_maxd*#cols)
  pset(64+cx,64+cy,cols[ci])
 end
 sspr(21,0,8,6,127-43,1,8,6)
 print("nodesoft",127-32,1,12)
 pal(9,title_pal)
 print(t_title_text,64-((#t_title_text*4)/2-1),30,9)
 sspr(0,97,87,31,64-(87/2)+2,64-(31/2)-6)
 pal()
 print("v"..version,1,1,7)
 if t_display_start then
  shadow_text_centered(t_start_text,80)
 end
 shadow_text_centered(display_score,100)
end

function shadow_text_centered(str,y)
 for t=0,1 do
  print(str,64-(#str*4)/2+t,y,5+(2*t))
 end
end

function init_path(l)
 local paths={
  {
   {0,5,-5,23,-28,33,-46,46,-57,68,-52,87,-36,97,-15,97,-5,79,7,65,32,61},
   {64}
  },
  {
   {0,5,-14,12,-35,19,-49,34,-45,52,-19,62,15,79,40,94,60,79,51,48,24,36,0,55,-19,84,-45,92},
   {64}
  },
  {
   {-20,20,137,20},
   {0}
  },
  {
   {137,20,-20,20},
   {0}
  },
  {
   {0,6,35,17,55,38,39,66,9,59,-14,38,-35,17,-57,35,-55,66,-17,85,31,102},
   {64}
  },
  {
   {0,6,-8,17,-15,36,-32,56,-52,59,-61,39,-48,25,-31,33,-15,64,-16,87,-30,106,-54,110,-58,90,-41,80},
   {64}
  },
  {
   {0,6,-22,15,-50,21,-56,43,-31,55,31,55,52,74,34,95,-16,96,-52,84},
   {64}
  },
  {
   {0,6,-23,16,-54,35,-56,67,-35,100,0,109},
   {64}
  },
  {
   {0,4,-21,23,-40,48,-35,77,-12,96,26,103,49,75,54,39,31,29,6,43,-9,68,13,80,30,60},
   {64}
  }
 }
 if l>#paths then
  return -1,-1
 else
  return paths[l][1],paths[l][2][1]
 end
end

function init_formation(l)
  -- 1  invader type formation with 00 as empty.
  -- 2  use mirrored path = 1, use normal path = 0
  -- 3  loop on path, don't join formation (0 = no, 1 = yes).
  -- 4  rotate formation.
  -- 5  formation rotation speed (usual 0.001).
  -- 6  waves per level.
  -- 7  path offset -5 offset = 1, +5 offset = 2, no offset = 0.
  -- 8  reverse path = 1, lap path = 2.
  -- 9  invaders path.
  -- 10 invader hp.
  -- 11 invader scale (usual = 1).
  -- 12 invader shoot frequency max. 
  -- 13 invader shoot frequency min.
  -- 14 invader dive time minimum time.
local formations={
  -- sector 01
  {
   "01010101010101010202020202020202030303030303030304040404040404040000000000000000",
   "1111111100000000111100001111000000000000",
   "1111111111111111111111111111111111111111",
   false,0,2,
   "1111111111111111222222221111222222222222",
   "1111111122222222111111112222222211111111",
   "1111111111111111111111111111111111111111",
   "3333333333333333333333333333333333333333",
   "1111111111111111111111111111111111111111",
   120,20,15
  },
  -- sector 02
  {
   "05050505050505050202020202020202040404040404040407070707070707070000000000000000",
   "1100110011110000111100000101010100000000",
   "1111111111111111111111111111111111111111",
   false,0,2,
   "1111111111111111222222221111222222222222",
   "1111111122222222111111112222222211111111",
   "2222222222222222222222222222222222222222",
   "3333333333333333333333333333333333333333",
   "1111111111111111111111111111111111111111",
   120,20,15
  },
  -- sector 03
  {
   "03030303030303030000000000000000000800080008000800000000000000001010101010101010",
   "1111000000000000010001000000000000001111",
   "1111111111111111111111111111111111111111",
   false,0,2,
   "1111111100000000010101010000000022222222",
   "1111111111111111111111111111111111111111",
   "1111555555555555555555555555555555555555",
   "3333333333333333360606060000000033333333",
   "1111111111111111121212121111111111111111",
   100,20,13
  },
  -- sector 04
  {
   "00000202020200000000090909090000000011111111000000000101010100000000000000000000",
   "1111111110101010111100001111000000000000",
   "0000000000000000000000000000000000000000",
   false,0,2,
   "1111111100000000010101010000000022222222",
   "2222222211111111222222221111111111111111",
   "6666666666666666666666666666666666666666",
   "3333333333333333336666333333333333333333",
   "1111111111111111112222111111111111111111",
   100,20,14
  },
  -- sector 05
  {
   "12121212121212120505050505050505080808080808080804040404040404040000000000000000",
   "1111111110000000111100001111000000000000",
   "0000000000000000000000001111111100000000",
   false,0,2,                                                                       
   "1111111122222222010101010101010100000000",
   "1111111111111111111111111111111111111111",
   "7777777777777777777777777777777711111111",
   "3333333333333333333333333333333333333333",
   "1111111111111111111111111111111111111111",
   110,20,12 
  },
  -- sector 06
  {
   "19191919191919191600160000160016101010101010101000160001010016000000000000000000",  
   "1111000010100000111111110101000000000000",  
   "1111111111111111111111111111111111111111",  
   false,0,3,                                                                          
   "0000000000000000000000000000000000000000",   
   "2222222222222222222222222222222222222222",   
   "1111111151511515111111111511115111111111",  
   "3333333360600606333333330603306000000000",  
   "1111111121211212111111111211112111111111",  
   110,20,12                                                                           
  },
  -- sector 07
  {
   "13131313131313130101010202010101111111111111111102080808080808020000000000000000",
   "1111111100000000010101011111000011111111",
   "1111111111111111111111111111111111111111",
   false,0,3,
   "1212121211122111212121212111111200000000",
   "1111111111111111111111111111111111111111",
   "2222222222299222999999999222222911111111",
   "3333333333333333333333333333333333333333",
   "1111111111111111111111111111111111111111",
   100,20,14
  },
  -- sector 08
  {
   "16161616161616160707070707070707181805050505181819001900001900190000190000190000",
   "1111000000001111111100000000111111110000",
   "1111111111111111111111111111111111111111",
   false,0,2,
   "1111222222221111111122222222111111110000",
   "2222222222222222222222222222222222222222",
   "6666666666666666111111119191191911911911",
   "3333333333333333333333339393393933933933",
   "1111111111111111111111112121121211211211",
   105,25,12
  },
  -- sector 09
  {
   "14141414151515151515151514141414020202020202020212121212121212121313131313131313",
   "0000111111110000010101011111000011110000",
   "1111111111111111111111111111111111111111",
   false,0,2,
   "1111222222221111111122222222111111110000",
   "1111111111111111111111111111111111111111",
   "8888888888888888888888888888888888888888",
   "3333333333333333999999993333333333333333",
   "1111111111111111222222221111111111111111",
   110,20,12  
  },
  -- sector 10
  {
   "11111111111111111212121212121212171717171717171719191919191919191818181818181818",
   "1111111100000000111100001111000011110000",
   "1111111111111111111111111111111111111111",
   false,0,2,
   "1111222211112222111122221111222211112222",
   "2222222222222222222222222222222222222222",
   "9999999922222222999999992222222299999999",
   "3333333399999999333333339999999933333333",
   "1111111122222222111111112222222211111111",
   110,20,12
  },
  -- sector 11
  {
   "00001511111500000015110909111500151109080809111500151109091115000000151111150000",
   "1111111100000000111100001111000000000000",
   "1111111111111111111111111111111111111111",
   false,0.001,3,
   "1212121211122111212121212111111200000000",
   "2222222222222222222222222222222222222222",
   "1111111111111111111111111111111111111111",
   "4444444444499444449999444449944444444444",
   "1111111111122111112222111112211111111111",
   110,20,12
  }
 }
 if l>#formations then
  return -1,-1,-1,-1,-1,-1,-1,-1
 else
  return formations[l][1],formations[l][2],formations[l][3],formations[l][4],formations[l][5],formations[l][6],formations[l][7],formations[l][8],formations[l][9],formations[l][10],formations[l][11],formations[l][12],formations[l][13],formations[l][14]
 end
end

function draw_inv_slots()
 local col
 for i in all(inv_slots) do
  if i.is_alive then col=7 else col=8 end
  rect(i.x-(i.w/2),i.y-(i.h/2),i.x+(i.w/2),i.y+(i.h/2),col)
 end
 pset(grid_origin.x, grid_origin.y,8)
end

function init_inv_slots(nr,nc,s)
 local i_num=1
 local width=8
 local height=7
 local num_rows=nr
 local num_cols=nc
 grid_width=(num_cols*width)+(s*(num_cols-1))
 grid_height=(num_rows*height)+(s*(num_rows-1))
 for r=1,num_rows do
  for c=1,num_cols do
   local i={
   col=c,
   row=r,
   x=grid_origin.x-(grid_width/2)+((c-1)*width)+(s*(c-1))+(width/2),
   y=grid_origin.y-(grid_height/2)+((r-1)*height)+(s*(r-1))+(height/2),
   w=width,
   h=height,
   is_alive=true,
   num=i_num
  }
  i.angle=atan2(grid_origin.x-i.x,grid_origin.y-i.y)
  add(inv_slots,i)
  i_num+=1
  end
 end
end

function gen_invader(mirror,p,t,l,toffset,p_rev,invader_hp,invader_scale)
 local c=1
 local local_path,local_offset=0,0
 local tx1,startx,starty,spd,toff=0,0,0,0,0
 local not_empty,s1x,s1y,s2x,s2y,w,h
 if toffset==1 then toff=-6 elseif toffset==2 then toff=6 else toff=0 end
 local_path,local_offset=init_path(p)
 if mirror then
  tx1=-local_path[2*c-1]+local_offset 
 else
  tx1=local_path[2*c-1]+local_offset
 end
 if t==0 then
  not_empty=false 
  s1x,s1y,s2x,s2y,sw,sh=0,0,0,0,0,0
 else
  not_empty=true
  s1x=inv_type[t][1]
  s1y=inv_type[t][2]
  s2x=inv_type[t][3]
  s2y=inv_type[t][4]
  sw=inv_type[t][5]
  sh=inv_type[t][6]
 end
 if t~=6 then
  --spd=0.5
  spd=0.70 
  starty=-30
 else
  spd=0.3
 end
 local i={
  x=local_path[2*c-1]+local_offset+startx,
  current_node=c,
  saved_node=0,
  saved_mirror=0,
  saved_poffset=0,
  y=local_path[2*c]+starty,
  tx=tx1,
  ty=local_path[2*c],
  type=t,
  path_num=p,
  path=local_path,
  poffset=local_offset+toff,
  path_mirror=mirror,
  path_rev=p_rev,
  ploop=l,
  s1_x=s1x,s1_y=s1y,s2_x=s2x,s2_y=s2y,
  w=sw,h=sh,
  ani_tmr=0,ani_flip=false,
  speed=spd,
  turnspeed=invader_turnspeed*(pi/180),
  rotation=0,diff=0,tangle=0,inc=1,
  num=#invaders+1,
  in_slot=false,aim_slot=false,
  is_alive=not_empty,flash_tmr=0,
  do_scale=false,scale=invader_scale,default_scale=invader_scale,scale_tmr=0,hp=invader_hp,
  dive_time=get_dive_time(),dive_tmr=0,diveshoot_tmr=0,is_diving=false,
  is_dying=false,srotation=0
 }
 if i.type~=6 then
  if l or t==0 then
   inv_slots[#invaders+1].is_alive=false
  else
   inv_slots[#invaders+1].is_alive=true
  end 
  add(invaders,i)
  sfx(1)
 else
  add(saucers,i)
 end
end

function update_invaders()
 alive_invaders={}
 for i in all(invaders) do
  if i.is_alive then
   if i.do_scale then
    if time()-i.scale_tmr>.1 then
     i.scale_tmr=0
     i.scale=i.default_scale
     i.do_scale=false
    end
   end
   process_dive(i)
   if not i.in_slot then
    update_invader_steer(i)
   else
    i.x=inv_slots[i.num].x
    i.y=inv_slots[i.num].y
   end
   add(alive_invaders,i)
  end
 end
end

function process_dive(i)
 if not i.is_diving then
  if i.dive_time==0 then
   dive_bomb(i)
  else
   i.dive_tmr+=1
   if (i.dive_tmr%60==0) then
    i.dive_time-=1
    i.dive_tmr=0
   end
  end
 end
end

function get_dive_time()
 return flr(rnd(total_invaders*1.2)-count_dead_invaders()+current_invader_dive_time)
end

function dive_bomb(i)
 if dive_num<2 then
  create_dive_path(i)
 else
  i.dive_time=get_dive_time()
 end
end

function update_invader_steer(inv)
 local dx=inv.tx-inv.x
 local dy=inv.ty-inv.y
 inv.tangle=atan2(dx,dy)
 inv.diff=(inv.tangle-inv.rotation)%1
 if inv.diff<=inv.turnspeed then
  inv.rotation=inv.tangle
 elseif inv.diff<0.5 then
  inv.rotation+=inv.turnspeed
 else
  inv.rotation-=inv.turnspeed
 end
 inv.rotation%=1
 inv.x+=cos(inv.rotation)*inv.speed
 inv.y+=sin(inv.rotation)*inv.speed
 if inv.aim_slot then
  inv.tx=inv_slots[inv.num].x
  inv.ty=inv_slots[inv.num].y
  if distance(inv.x,inv.y,inv.tx,inv.ty)<=1.5 and not inv.in_slot then
   inv.in_slot=true
   inv.x=inv_slots[inv.num].x
   inv.y=inv_slots[inv.num].y
  end
 else
  if distance(inv.x,inv.y,inv.tx,inv.ty)<=waypoint_radius then
   next_node(inv,inv.path,inv.poffset)
  end
 end
end

function next_node(e,p,off)
 if e.current_node+e.inc<(#p/2)+1 and e.current_node+e.inc>0 then
  e.current_node+=e.inc
 else
  -- reset dive bombing to normal mode.
  if e.is_diving then
   e.path=init_path(e.path_num)
   e.current_node=e.saved_node
   e.poffset=e.saved_poffset
   e.path_mirror=e.saved_mirror
   dive_num-=1
   e.is_diving=false
   e.dive_time=get_dive_time()
   return
  end
  if e.type~=6 then
   if not e.ploop then
    e.aim_slot=true
    e.tx=inv_slots[e.num].x
    e.ty=inv_slots[e.num].y
   else
    if e.path_rev==1 then
     e.inc=-e.inc
     e.current_node+=e.inc
    elseif e.path_rev==2 then
     e.current_node=1
    end
   end
  else
   if not e.ploop then
    del(saucers,e)
   else
    e.inc=-e.inc
    e.current_node+=e.inc
   end
  end
 end
 if not e.in_slot and not e.aim_slot then
  if e.path_mirror then
   e.tx=-p[2*e.current_node-1]+e.poffset
   e.ty=p[2*e.current_node]
  else
   e.tx=p[2*e.current_node-1]+e.poffset
   e.ty=p[2*e.current_node]
  end
 end
end

function create_dive_path(inv)
 local dpath={}
 inv.is_diving=true
 inv.in_slot=false
 inv.aim_slot=false
 inv.saved_node=inv.current_node
 inv.saved_mirror=inv.path_mirror
 inv.saved_poffset=inv.poffset
 inv.current_node=1
 inv.poffset=0
 if plyr_x<inv.x then
  dpath={inv.x+10,inv.y-10,inv.x+20,inv.y,inv.x+10,inv.y+10,plyr_x-20,plyr_y}
 else
  dpath={inv.x-10,inv.y-10,inv.x-20,inv.y,inv.x-10,inv.y+10,plyr_x+20,plyr_y}
 end
 inv.path_mirror=false
 inv.path=dpath
 sfx(12)
 dive_num+=1
end

function init_worm(sx,sy,_w,_h)
 local vel=0
 if sx<63 and sx>0 then vel=-1 else vel=1 end
 if sx<0 then 
  vel=1
 elseif sx>127 then 
  vel=-1
 end
 the_worm={
  x=sx,
  y=sy,
  ani_tmr=0,
  ani_flip=false,
  head_tmr=flr(rnd(540)+120),
  shoot_tmr=0,
  head_flip=false,
  w=_w,
  h=_h,
  speed=vel,
  y_inc=10,
  is_alive=true,
  is_killed=false,
  killed_tmr=0,
  on_screen=false,
  hp=20,
  flash_tmr=0,
  is_visible=true,
  sine_y=0,
  segs={}
 }
 local start_x
 for s=1,11 do
  if the_worm.speed>0 then
   start_x=sx-(the_worm.w*s)
  else
   start_x=sx+(the_worm.w*s)
  end
  add(the_worm.segs,{x=start_x,y=sy,ani_flip=false,w=the_worm.w,h=the_worm.h,ani_tmr=0,speed=vel,y_inc=10,sine_y=0,is_alive=true,hp=10,flash_tmr=0,on_screen=false,is_visible=true})
 end
end

function worm_count_alive_segs()
 local c=0
 for seg in all(the_worm.segs) do
  if seg.is_alive then c+=1 end
 end
 return c
end

function update_worm()
 local dead_count=0
 if worm_is_alive() then
  update_segment(the_worm)
  the_worm.head_tmr-=1
  if the_worm.head_tmr<=0 then
   the_worm.head_flip=not the_worm.head_flip
   the_worm.head_tmr=flr(rnd(360)+120)
   sfx(16)
  end
  if the_worm.head_flip and the_worm.is_alive then
   the_worm.shoot_tmr+=1
   if the_worm.shoot_tmr>=12 then
    the_worm.shoot_tmr=0
    add(inv_lasers,{x=the_worm.x,y=the_worm.y,sx=123,sy=0,w=1,h=7,speed=2})
    sfx(2)
   end
  else
   the_worm.shoot_tmr=0
  end
  for seg in all(the_worm.segs) do
   update_segment(seg)
  end
 else
  the_worm.flash_tmr=0
  the_worm.killed_tmr+=1
  if the_worm.killed_tmr>=15 then
   the_worm.killed_tmr=0
   for s in all(the_worm.segs) do
    if not s.is_alive and s.is_visible then
     s.is_visible=false
     add_explosion(s.x,s.y,19,0)
     return
    end
   end
   for s in all(the_worm.segs) do
    if not s.is_alive and not s.is_visible then
     dead_count+=1
    end
   end
   if dead_count==#the_worm.segs and the_worm.is_visible then
    the_worm.is_visible=false
    add_explosion(the_worm.x,the_worm.y,19,0)
    shake_val+=0.3
    for i=0,1,0.20 do
     add_explosion(the_worm.x+cos(i)*rnd(5)+3,the_worm.y+sin(i)*rnd(5)+3,19,rnd(1)+0.5)
    end
    create_fadetext(64,64,"invader master worm defeated!",220,true,0.1,true)
    create_fadetext(64,73,"+2000 score bonus",220,true,0.1,true)
    plyr_score+=2000
    if plyr_score>high_score then
     save_hiscore(plyr_score)
     high_score=plyr_score
     create_fadetext(64,89,"new high score",300,true,0.1,true)
    end
    end_level_tmr=time()
    game_complete=true
    sfx(15)
   end
  end
 end
end

function worm_is_alive()
 if the_worm.is_alive or worm_count_alive_segs()>0 then 
  return true
 else
  return false
 end
end

function update_segment(s)
 if time()-s.flash_tmr>.1 then
  s.flash_tmr=0
 end
 s.sine_y=3*sin(s.x/127*3)+(s.y)
 if s.on_screen then
  if s.x-(s.w/2)+s.speed<-s.w or s.x+(s.w/2)+s.speed>127+s.w then
   s.y+=s.y_inc
   if s.y-(s.h/2)>100 or s.y-(s.h/2)<20 then 
    s.y_inc=-s.y_inc 
   end
   s.speed=-s.speed
  else
   s.x+=s.speed
  end
 else
  s.x+=s.speed
  if s.x>0 and s.x<127 then s.on_screen=true end
 end
end

function animate_worm()
 if worm_is_alive() then
  animate_segment(the_worm)
  for seg in all(the_worm.segs) do
   animate_segment(seg)
  end
 end
end

function animate_segment(s)
 s.ani_tmr+=1
 if s.ani_tmr>=15 then
  s.ani_tmr=0
  if s.is_alive then 
   s.ani_flip=not s.ani_flip
  end
 end
end

function draw_worm()
 for seg in all(the_worm.segs) do
  if seg.is_visible then
   if not seg.is_alive then
    whiteout(true,rnd(15)+1)
   end
   draw_segment(seg,space_worm_spr[2],false)
   whiteout(false)
  end
 end
 if the_worm.is_visible then
  if not the_worm.is_alive then
   whiteout(true,rnd(15)+1)
  end
  draw_segment(the_worm,space_worm_spr[1],the_worm.head_flip)
  whiteout(false)
 end
end

function draw_segment(s,frames,hf)
 local sx,sy,do_ani_flip,do_head_flip,sw,sh,flash
 local fos=0
 if s.flash_tmr>0 then flash=true else flash=false end
 sx,sy,sw,sh=get_worm_frame(s.ani_flip,hf,s,frames)
 if s.speed>0 then do_ani_flip=true else do_ani_flip=false end
 if flash then
  fos=3 
  whiteout(true,rnd(15)+1)
 end
 sspr(sx,sy,sw,sh,s.x-(sw/2),s.sine_y-(sh/2)-fos,sw,sh,do_ani_flip,false)
 whiteout(false)
end

function get_worm_frame(af,hf,s,frames)
 local sx,sy,sw,sh
 if hf then
  if af then
   sx=frames[7]
   sy=frames[8]
  else
   sx=frames[9]
   sy=frames[10]
  end
  sw=s.w+2
  sh=s.h-2
 else
  if af then
   sx=frames[1]
   sy=frames[2]
  else
   sx=frames[3]
   sy=frames[4]
  end
  sw=s.w
  sh=s.h
 end
 return sx,sy,sw,sh
end

function animate_invaders()
 for i in all(alive_invaders) do
  anim(i)
 end
end

function animate_saucers()
 for s in all(saucers) do 
  anim(s)
 end
end

function anim(i)
 if time()-i.flash_tmr>.1 then
  i.flash_tmr=0
 end
 i.ani_tmr+=1
 if i.ani_tmr>=15 then
  i.ani_flip=not i.ani_flip
  i.ani_tmr=0
 end
end

function invader_fire(f)
 f.scale_tmr=time()
 f.do_scale=true
 f.scale=f.default_scale*1.5
 add(inv_lasers,{x=f.x,y=f.y,sx=123,sy=0,w=1,h=7,speed=2})
 sfx(2)
end

function update_invader_fire()
 if #invaders>4 and #alive_invaders>0 then
  alienshoot_timer+=1
  if (alienshoot_timer%flr(rnd(current_invader_fire_max)+current_invader_fire_min)==0) then
   local f=alive_invaders[flr(rnd(#alive_invaders)+1)]
   if f then
    if f.y>0 and not f.is_diving then
     invader_fire(f)      
    end
   end
  end
 end
 for i in all(alive_invaders) do
  if i.is_diving then
   i.diveshoot_tmr+=1
   if (alienshoot_timer%40==0) then
    invader_fire(i)
   end
  end
 end
 for f in all(inv_lasers) do
  f.y+=f.speed
  if f.y>127+(f.h/2) then
   del(inv_lasers,f)
  end
  if inv_laser_pcount<30*#inv_lasers then
   inv_laser_pcount+=1
   create_particle(f.x,f.y-(f.h/2),1,ptype_invlaser)
  end
  if not plyr_invinc and not plyr_disabled then
   if box_collide(f.x,f.y-(f.h/2),f.w,f.h/2,plyr_x-(plyr_w/2),plyr_y,plyr_w,plyr_h) or 
    box_collide(f.x,f.y-(f.h/2),f.w,f.h/2,plyr_x-1,plyr_y-(plyr_h/2),3,plyr_h) then
    del(inv_lasers,f)
    plyr_dmg()
   end
  end
 end
end

function plyr_dmg()
 shake_val+=0.4
 plyr_health-=1
 sfx(6)
 if plyr_health<=-1 then
  plyr_health=3
  plyr_lives-=1
  bonus_kills=0
  shake_val+=0.3
  add_explosion(plyr_x,plyr_y,6,0)
  for i=0,1,0.20 do
   add_explosion(plyr_x+cos(i)*rnd(5)+3,plyr_y+sin(i)*rnd(5)+3,6,rnd(1)+0.5)
  end
  plyr_invinc,plyr_disabled,plyr_has_control=true,true,false
  plyr_invinc_tmr,plyr_flash_tmr=0,0
  plyr_disabled_tmr=time()
  plyr_x=64
  sfx(4)
  if plyr_lives<=-1 then
   plyr_xv=0
   end_level_tmr=time()
   create_fadetext(64,80,"g a m e   o v e r",300,true,0.1,true)
   if plyr_score>high_score then
    save_hiscore(plyr_score)
    high_score=plyr_score
    create_fadetext(64,89,"new high score",300,true,0.1,true)
   end
   gameover=true
   sfx(10)
  end
 else
  plyr_dmg_flash_tmr=time()
 end 
end

function draw_invader_fire()
 for f in all(inv_lasers) do
  sspr(f.sx,f.sy,f.w,f.h,f.x,f.y-(f.h/2))
 end
end

function distance(x1,y1,x2,y2)
 local dx=(x1-x2)/10
 local dy=(y1-y2)/10
 return 10*sqrt(dx*dx+dy*dy)
end

function _update60()
 _upd()
end

function _draw()
 cls()
 _drw()
end
__gfx__
000060000006000000000cc0cc0cc79798c00000c8000000000c0bbbbb0c00bbbbb0000800080000e000e00008eee800008eee800080dcd080800dcd00880000
000575000057500006000cc0cc0cc79a9800808008000808000ccb8b8bccccbababcca083a380a00e3a3e00888ccc888c888c888ce09d9d90ee09d3d90e80000
00076700007770006760000000000a9a98cc8c8cc80cc8c8cc0c0bbbbb0c00bbbbb003300a0033a300a003a8a80008a808a808a80eaacacaaeeaacbcaaee0000
0606c6060756c66067606000cc000a0908cacccac88c9ccc9c8000c0c0000bbb0bbb0a3aaaaa3a33aaaaa33888ccc888c888c888ce00cac00ee00cbc00ea0000
5756c6575756c67677767000cc000b0000cccaccc08ccc9ccc80bbb0bbb00c0c0c0c003a88ca30a3ac88a3a08e000e80008e0e800080c9c080800c3c008a0000
57576757575776767776700000000b000000ccc000800ccc0080c0c0c0c00c00000c0003aaa300003aaa30008e000e80008e0e800000ddd000000ddd00070000
89057509885758606760600000000b0000080008008c08080c80c00000c00000000000003330000003330000800000800080008000000d00000000d000070000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d7d000000d7d0000333333303033333030d03330d000033300020002000202002002000c000c000000000008008080080000000000c00000c000c000c0000
00d77cd0000d77cd00339a3a933339a3a933dcd3b3dcd0003b3000d02dcd20d0d2dcd2d0008000800c0c000c0ca0890980a000808000c8c000c8c0cac0cac000
00dcccd0000dcccd0033bb3bb3333bb3bb33dccdbdccd0d03b30d00d2dcd2d00d2dcd2d0c8999998c8899999889009090090089098000c00000c000c000c0000
5667776655667776653003b3003b003b300b0c33b33c0dcc3b3ccd00dcdcd0000dcdcd00899a9a998c99b9b99c98090908998090908900300030000303030000
99aa9988888899aa99b033b330b0033b33000038b8300ccdabadcc0d0ddd0d00d0ddd0d0c0999990cc0999990c089cac980989bab9890dbc3cbd000bcbcb0000
5667776655667776650030003000300000300003330000d03330d0d02ada20d0d28d82d0c0c808c0c00c808c000099a9900a099a990a0c30b03c00c30303c000
00567650000567650000b000b00b0000000b00b000b00000b0b000200ddd002020ddd02000c000c000c00000c00a90009a080a909a080000300000d00000d000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00b333b0000b333b0000088800080000000880003000800003000000088800000088800000a000a009000a0009600333006000333000000000000000a0a00000
8830303880332823308cd8a8dc88cd888dc89003b30090003b3000088888880088888880000a0a000a00a0a00a603b3b306603b3b306000a8a00000008000000
0300300308808c808880dcccd0880d898d08936666639a3666663a88aa8aa8888bb8bb8890ccccc0990ccccc09073b3b370673b3b3760c8e6e8c00c8e6e8c000
0b02820b00b02820b08008a8008800ccc008a36d6d63aa3676763a888888888888888888a8c33bc8a98cb33c89073bbb370073bbb370cc9a6a9cccc9a6a9cc00
8808a80880b80308b080d888d0800d898d0000666660090666660900e080e0000e080e0090ccccc09a0ccccc0a00a8a8a0000a8a8a000c8e6e8c00c8e6e8c000
03028203088003008800d000d000d08880d00003030009030003090e00000e0000e0e0009008080090008080000600a0060060aaa06000088800000088800000
0b80308b00300b003000c000c00c0000000c000b0b00080b000b08e0000000e0000e0000a0000000a000000000600a0a0060060006000bb000bb0000b0b00000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0333333300333333300333333300333333300333333300003330000033300000099000aa00000333bb33300333bb333000000000000000000000000000000000
3aaaaaaa33777777733bbbbbbb33bbbbbbb33bbbbbbb00038833000311330000aa0000099000338bbbb833331bbbb13300000000000000000000000000000000
3bbbbbbb33aaaaaaa33777777733bbbbbbb33bbbbbbbb338a9830331cd130033333000333330389baab98331dbaabd1300000000000000000000000000000000
3bbbbbbb33bbbbbbb33aaaaaaa33777777733bbbbbbb03bbbbb3b3bbbbb303bbbbb303bbbbb338abaaba8331cbaabc1300000000000000000000000000000000
3bbbbbbb33bbbbbbb33bbbbbbb33aaaaaaa3377777770bbaaabb0bbaaabb3bbaaabb3bbaaabb0386aa68300316aa613000000000000000000000000000000000
03333333003333333003333333003333333003333333066aaa66066aaa66366aaa66366aaa660036666300003666630000000000000000000000000000000000
0000000000000000000000000000000000000000000003666663b366666303666663036666630033663300003366330000000000000000000000000000000000
00000000000000000000000000000000000000000000b338a9830331cd13003333300033333000b0000b00000b00b00000000000000000000000000000000000
0000000000000000000000000000000000000000000000038833000311330000aa00000990000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000003330000033300000099000aa00000000000000000000000000000000000000000000000000000000
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
00000000000000000000000999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000998899909990000000000000000000000000000099000000000000000000000000000000000000000000000000000000000000000
00000000000000000000009998899808990009999900099999900099999009999999000000000000000000000000000000000000000000000000000000000000
00000000000000000000009999998809990008888999099999990999889908889988000000000000000000000000000000000000000000000000000000000000
00000000000000000000099988888809990009999999099888990999999998889998000000000000000000000000000000000000000000000000000000000000
00000000000000000000099888888809980099888999099888990999888888888998000000000000000000000000000000000000000000000000000000000000
00000000000000000000999888888999990099999998099888990899999988888999990000000000000000000000000000000000000000000000000000000000
00000000000000000000999888888999990089999998099888999889999988888889999000000000000000000000000000000000000000000000000000000000
00000000000000000000888888888888880088888888088888888888888888888888888000000000000000000000000000000000000000000000000000000000
00000009990000999000888888888888880088888888088888888888888888888888888000000000000000000000000000000000000000000000000000000000
00000099980009998000888888888888880088888888099888888888888888888888888000000000000000000000000000000000000000000000000000000000
00000099880099988999999988889999990088999998099988888888999999889999999000099999999000000000000000000000000000000000000000000000
00000999880099989999999888889999999088999998099988888888999999888999999900089999999000000000000000000000000000000000000000000000
00009998890999889998889998999888999099988888099989998889998889998999888999099988888000000000000000000000000000000000000000000000
00009998990999899988899988999889998099988888099989998889998889998999888999099998888000000000000000000000000000000000000000000000
00099999999999899988888889999999998099988888099999988889999999998899988888088999999900000000000000000000000000000000000000000000
00999999999998999988888889999999998099988880099999998889999999999899988888088899999999000000000000000000000000000000000000000000
00999988999988999888888889998888888099988880099989999888999888888899988888088888888999900000000000000000000000000000000000000000
09998888899989999888888888999999888089999990099988999988899999998889998888088899999999900000000000000000000000000000000000000000
99998888999989998888888888999999888089999990099988899988899999998889998888088899999999800000000000000000000000000000000000000000
88888888888888888888888888888888888088888880088888888888888888888888888888088888888888800000000000000000000000000000000000000000
88888888888888888888888888888888888088888880088888888808888888888888888888188888888888800000000000000000000000000000000000000000
88888888888888888888888088888888888088888880088888888808888888888888888888088888888888800000000000000000000000000000000000000000
88888888888888888880000088888888888088888880088888888808888888880888888888088888888888800000000000000000000000000000000000000000
88888888888888888880000088888888888088888880088888888808888888880088880888088888888888800000000000000000000000000000000000000000
8888888888888888888000000888888888008888888008888888880888888888008888000000088888888880bbbbbbbbbbbbbbbbbb0000000000000000000000
88888888888888888800000008888888880088888880088888888808888888880088880000000888888888003aaaa77aaaaaa77aab0000000000000000000000
88888880888888888800000008888888800088888880088808888808888888880088880000000888888888003aaa77aaaaaa77aaab0000000000000000000000
88888880888888888000000008888888800088888880088808888808888888880088880000000888888888003aa77aaaaaa77aaaab0000000000000000000000
88888000888808888000000000888888800008888880088800088800088888880088880000000888888888003a77aaaaaa77aaaaab0000000000000000000000
888800008888088800000000008888880000088888800888000888000888888800088800000000888888880033333333333333333b0000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001400000061000620006300064000650006500065000650006500065000650006500065000650006500065000650006500065000650006500065000650006500065000650006500065000640006300062000610
00060000087100b7200e7100d7100871008710107001070010700107001070019700197001970019700197001970019700107000e7000d7000b70009700097000670005700047000370002700027000270002700
000200001671016720167300f74016730167201671000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001772004730147501d03015720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001267002650056600665003640026300162000610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000002020081300d1400815008040047300002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000066600e1200a1201011007010071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000107501575014750187501a7501a7401a7301a0201a0101a0101a010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f000013040130501305013050130400d0300d0400d0500d0400d03017040170501704017030170401105011050110501105011040110301102011010110001100011000110001100011000110001100011000
000600000574005740057500875008750087500e7500e7500e7500e7500e7500e750000000e0500e050000000e0500e050171000e0500e0500000000000000000000000000000000000000000000000000000000
000a0000317102c7202973025770227701f7301c7301a7301704014050120500f0500b05009050070500505003050020500105000050000500005000050000500005000050000500005000050000500005000050
000a0000167501975016750197501b750197401b0301b0201b0101b0101b0101b0201b0301b0201b0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f0000165101552015530145301353013530125301153010530105300f5300f5300e5300d5300d5300c5300b5300b5300a53009530095300853007530065300653005530045300453003530025300152000510
000d0000137101b720177301b740177301b7301b740177301b7201b7101b7101b7100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002800000351003510035200353003530035400354003530035300354003540035300353003540035400353003530035400354003530035300354003540035300353003540035400353003530035200351003510
000600001b7201b7301b7401b7501b7501b7501b75000000217502175021750217500000021750217502175021750000002575025750257502575025750257502575025750257502575025750257502574025730
001000000205002050050500505003050030500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
