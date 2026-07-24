pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- quasar kid
-- by picoter8
-- todo:
-- - boss fights?
-- - 
-- - todo: lock player if just arrived at planet.
-- - 
-- - different planet types?
-- - - cloudy
-- - - night sky
-- - - desert
-- - - forest
-- - - water?
-- - - ice?
-- - - mountain?
-- - - bouncy plants?
-- - more backgrounds? horizontal oval transparent clouds?
-- - upside down clouds?
-- - volcanic smoke flying upward getting bigger

game_starting,game_starting_t,game_saved_t,ui_radar_upgrade_t=true,0,0,0
level_starting=false

total_captures,total_planets,game_time,player_hits=0,0,0,0

has_save_data=cartdata("quasarkid")

function save_game()
  game_saved_t=2
  has_save_data=true
  dset(0,pmaxquasar)
  dset(1,pdamage)
  dset(2,bs_shield_maxsize)
  dset(3,level_seed)
  dset(4,game_time)
  dset(5,total_captures)
  dset(6,total_planets)
  dset(7,player_hits)

  for i=16,63 do
    dset(i,-1)
  end

  for i=1,#bs_collection do
    local e=bs_collection[i]
    dset(15+i,e.s)
  end
end

function recompute_upgrades()
  reset_upgrades()

  for k,e in pairs(bs_collection) do
    pmaxquasar+=e.up_pmaxquasar
    pdamage+=e.up_pdamage
    bs_shield_maxsize+=e.up_bs_shield_maxsize
  end
end

function load_game()
  pmaxquasar,pdamage,bs_shield_maxsize,level_seed,game_time,total_captures,total_planets,player_hits=dget(0),dget(1),dget(2),dget(3),dget(4),dget(5),dget(6),dget(7)

  level_pcluster,level_planet=flr(level_seed/100),level_seed%100

  bs_collection={}

  for i=16,63 do
    local s=dget(i)
    if s!=nil and s!=-1 then
      local e=make_enemy(s,i*40%128,flr(i*40/128))
      e:init()
      bs_collection[i-15]=e
    end
  end

  recompute_upgrades()
end

function reset_upgrades()
  pmaxquasar,pdamage,bs_shield_maxsize=10,.5,25
end

function reset_game()
  reset_upgrades()

  game_time,total_captures,total_planets,player_hits=0,0,0,0

  level_seed=flr(rnd(320))*100
  level_pcluster,level_planet=level_seed/100,0

  bs_collection={}

  save_game()
  run()
end

function galaxy_jump()
  level_seed=flr(rnd(320))*100
  level_pcluster,level_planet=level_seed/100,0

  save_game()
  run()
end

align_c,align_r=1,2

function printb(text,x,y,c,bc,a)
 local ox=(a==align_c) and #text*2 or
          (a==align_r) and #text*4 or
          0
 local tx=x-ox
  
 for i=tx-1,tx+1 do
  for j=y-1,y+1 do
   print(text,i,j,bc)
  end
 end
 
 print(text,tx,y,c)
end

function printa(text,x,y,c,a)
 local ox=(a==align_c) and #text*2 or
          (a==align_r) and #text*4 or
          0
 print(text,x-ox,y,c)
end

function roundrect(x,y,x2,y2,r,c)
  circfill(x+r,y+r,r,c)
  circfill(x2-r,y+r,r,c)
  circfill(x+r,y2-r,r,c)
  circfill(x2-r,y2-r,r,c)

  rectfill(x+r,y,x2-r,y2,c)
  rectfill(x,y+r,x2,y2-r,c)
end

function time_to_text(time)
 local hours,mins,secs,fsecs=flr(time/3600),flr(time/60%60),flr(time%60),flr((time%60)*10)%10
 if(hours<0 or hours>9)return "8:59:59"
 local txt=hours>0 and hours..":" or ""
 txt=txt..((mins>=10 or hours==0) and mins or "0"..mins)
 txt=txt..(secs<10 and ":0"..secs or ":"..secs)--.."."..fsecs
 return txt
end

function rnd_i(v)
  return 1+flr(rnd(v))
end

function polar_to_xy(r,a)
 return r*cos(a),r*sin(a)
end

function decimal_text(n)
  local nn=flr(n*10)/10
  if nn%1==0 then
    return nn..".0"
  else
    return nn
  end
end

function normalize(x,y)
  local d=max(abs(x),abs(y))
  local n=min(abs(x),abs(y))/d
  local m=sqrt(n*n+1)*d
  return x/m,y/m,m
end

function round(v)
  return flr(v+.5)
end

function flr10(v)
  return flr(v*10)/10
end

function flr_map(x)
 return flr(x/8)*8
end

function check_flag(x,y,f)
 return fget(mget(flr(x/8)%128,flr(y/8)),f or 1)
end

function set_map(x,y,s)
 return mset(flr(x/8)%128,flr(y/8),s)
end

-- requires o:aabox
function collision_checks(o,ddx,ddy,other_layers,exclude_callback)
  local x1,y1,x2,y2=o:aabox()
  x1+=ddx
  y1+=ddy
  x2+=ddx
  y2+=ddy

  if(y1<8)return 0,0,nil

  -- world tiles collision checks
  for i=flr_map(x1),flr_map(x2),8 do
    for j=flr_map(y1),flr_map(y2),8 do
      local spri=mget(i/8%128,j/8)
      if fget(spri,1) then
        return 0,0,nil
      end
    end
  end

  if other_layers then
    for kl,layer in pairs(other_layers) do
      for k,enemy in pairs(entities[layer]) do
        if enemy!=o then
          local exclude=exclude_callback and exclude_callback(enemy)

          if not exclude then
            local ex1,ey1,ex2,ey2=enemy:aabox()

            if x2<ex1 or x1>ex2 or y2<ey1 or y1>ey2 then
            else
              return 0,0,enemy
            end
          end
        end
      end  
    end
  end

  return ddx,ddy,nil
end

function pal_fill(c)
  for i=0,15 do
    pal(i,c or 0)
  end
end

function pal_clear()
  pal()pal(14,0)
end

function make_circle(el,t,x,y,vx,vy,g,d,s1,s2,colors,update_callback)
 local l=entities[el]
 
 local e=
 {
  tt=t,
  t=t,
  x=x,
  y=y,
  vx=vx,
  vy=vy,
  g=g,
  d=d,
  s1=s1,
  s2=s2,
  sc=s1,
  l=l,
  colors=colors,
  
  update=function(e)
   if(g_paused)return

   e.t-=one_frame
   if e.t<=0 then
    del(e.l,e)
   else
    e.sc+=one_frame*(e.s2-e.s1)/e.tt
    e.x+=e.vx
    e.y+=e.vy

    e.vx*=d
    e.vy*=d
    e.vy+=e.g

    if(update_callback)update_callback(e)
   end
  end,
 
  draw=function(e)
   local ci=flr(1+#e.colors*(1-e.t/e.tt))
   circfill(e.x,e.y,e.sc,e.colors[ci])
  end,
 }
 
 add(l,e)
 
 return e
end

function make_line(el,t,x,y,vx,vy,s,colors)
 local l=entities[el]
 
 local e=
 {
  tt=t,
  t=t,
  x=x,
  y=y,
  vx=vx,
  vy=vy,
  s=s,
  l=l,
  colors=colors,
  
  update=function(e)
   if(g_paused)return

   e.t-=one_frame
   if e.t<=0 then
    del(e.l,e)
   else
    e.x+=e.vx
    e.y+=e.vy
   end
  end,
 
  draw=function(e)
   local colors,bc=e.colors,flr(#colors*(1-e.t/e.tt))
   line(e.x,e.y,e.x+2*e.s*e.vx,e.y+2*e.s*e.vy,colors[min(#colors,bc)])
   line(e.x,e.y,e.x+e.s*e.vx,e.y+e.s*e.vy,colors[1+bc])
  end,
 }
 
 add(l,e)
 
 return e
end

function explode(x,y,size,vel,damp,colors)
  for i=1,8 do
    local vx,vy=polar_to_xy(vel,i/8)
    make_circle(layer_player_postfx,.5,x,y,vx,vy,0,damp,size,0,colors[1])
    make_circle(layer_player_postfx,.5,x,y,vx,vy,0,damp,size-4,0,colors[2])
    make_circle(layer_player_postfx,.5,x,y,vx,vy,0,damp,size-8,0,colors[3])
    make_circle(layer_player_postfx,.5,x,y,vx,vy,0,damp,size-12,0,colors[4])
  end
end

red_colors={8}
yellow_colors={10}
green_colors={11}
blue_colors={12}
rainbow_colors={split"10,7,12,12,12,12",split"10,7,11,11,11,11",split"10,7,10,10,10,10",split"10,7,8,8,8,8"}
rev_rainbow_colors={split"10,7,7,2,2,2,2",split"10,7,7,8,8,8,8",split"10,7,7,9,9,9,9",split"10,7,7,10,10,10,10"}

function rainbow_particles_callback(e)

  local hit_enemy=false

  if e.sc>=1 then
    for k,enemy in pairs(entities[layer_enemies]) do
      local x1,y1,x2,y2=enemy:aabox()
      if e.x>=x1 and e.x<=x2 and e.y>=y1 and e.y<=y2 then
        hit_enemy=true
        if enemy.hit_t<=0 then
          enemy.text_hit_t,enemy.hit_t=1,.2
          enemy.hit_vx,enemy.hit_vy=normalize(e.vx,e.vy)
          local h=enemy.health
          enemy.health=max(0,enemy.health-pdamage)

          if h>0 and enemy.health<=0 then
            sfx(4)
            explode(enemy.x,enemy.y,20,3.5,.9,rainbow_colors)
          else
            local rsfx=rnd()
            sfx(rsfx>.7 and 6 or rsfx>.3 and 7 or 8)
          end
        end
      end
    end
  end
  
  if rnd()>0.5 and e.sc>=2.25 and check_flag(e.x,e.y,2) then
    local rsfx=rnd()
    sfx(rsfx>.7 and 1 or rsfx>.3 and 2 or 3)

    e.t=0 -- kill particle
    set_map(e.x,e.y,0)
    
    for i=1,6 do
      local x,y=(flr_map(e.x)+4)%1024,flr_map(e.y)+4
      local vx,vy=polar_to_xy(1+rnd(2),i/6+rnd(.1))
      make_circle(layer_player_postfx,.2,x,y,vx,vy,0,.9,4,0,level_ground_colors)
      make_line(layer_player_postfx,.1,x,y,vx,vy,2,level_ground_colors)
    end


  end

  if hit_enemy or e.sc>=1.5 and check_flag(e.x,e.y) then
    e.x-=e.vx
    e.y-=e.vy
    e.vx=-e.vx+2-rnd(4)
    e.vy=-e.vy
    e.g=.1
  end
end

function rainbow_particles(x,y)
  --[[]]
  local vx,vy=.15-rnd(.3),1+rnd()
  local tt=.2+rnd(.8)
  local yy=y+rnd(2)
  make_circle(layer_player_blue_fx  ,tt-.3,x-3,yy,vx,vy   ,0,1,4   ,.5,blue_colors,rainbow_particles_callback)
  make_circle(layer_player_blue_fx  ,tt-.3,x+3,yy,vx,vy   ,0,1,4   ,.5,blue_colors,rainbow_particles_callback)
  make_circle(layer_player_green_fx ,tt-.2,x-2,yy,vx,vy+.1,0,1,4   ,.5,green_colors,rainbow_particles_callback)
  make_circle(layer_player_green_fx ,tt-.2,x+2,yy,vx,vy+.1,0,1,4   ,.5,green_colors,rainbow_particles_callback)
  make_circle(layer_player_yellow_fx,tt-.1,x-1,yy,vx,vy+.2,0,1,3.5 ,.5,yellow_colors,rainbow_particles_callback)
  make_circle(layer_player_yellow_fx,tt-.1,x+1,yy,vx,vy+.2,0,1,3.5 ,.5,yellow_colors,rainbow_particles_callback)
  make_circle(layer_player_red_fx   ,tt   ,x  ,yy,vx,vy+.3,0,1,3.25,.5,red_colors,rainbow_particles_callback)
  --]]
end

function color_of_most_friends()
  if(#bs_collection<24)return -1

  --local ci=bs_collection[1].ci

  local totals=split"0,0,0,0,0,0"

  for i=1,#bs_collection do
    local eci=bs_collection[i].ci
    totals[eci]+=1
  end

  local max,mci=24,-1
  for i=1,#totals do
    local tot=totals[i]
    if(tot>=max) max,mci=tot,i
  end

  return mci
end

player_mod_colors=split"11,12,14,10,6,1"

function make_player()
  return
  {
    init=function()
      pt=0
      px,py,pvx,pvy,pevx,pevy=512,240,0,0,0,0
      pax=0
      pflip=false
      p_onground=false
      pquasar=10

      p_hitt=0
      p_aboard=false
      pmotorsound=false

      sfx(0,-2)
    end,

    aabox=function(p)
      return px-3,py-14,px+3,py
    end,

    helmet_aabox=function(p)
      return px-5,py-15,px+5,py-6
    end,

    update=function()
      if not btn(5) then
        if pmotorsound then
          pmotorsound=false
          sfx(0,-2)
        end
      end

      if(g_paused)return
      if(game_starting or level_starting)return

      pt+=one_frame

      game_time+=one_frame

      p_hitt=max(0,p_hitt-one_frame)

      if bs_takeoff then
        px+=(bs_x-px)*.2
        py+=(bs_y-py)*.2

        if abs(bs_x-px)<1 and abs(bs_y-py)<1 then
          p_aboard=true
        end
        return
      end

      pax=0

      p_onground=check_flag(px-2,py+1) or check_flag(px+2,py+1)
      pvx*=p_onground and .9 or .995

      if btn(0) then
        pax=p_onground and -.2 or -.075
        pflip=true
      end
    
      if btn(1) then
        pax=p_onground and .2 or .075
        pflip=false
      end

      pvx+=pax

      if(pvx>1)pvx=1
      if(pvx<-1)pvx=-1
      if(abs(pvx)<.05)pvx=0

      if pvy<2 then
        pvy+=.065
      else
        pvy=2
      end

      pevx*=.925
      pevy*=.925

      if btn(5) and p_hitt<=1 then
        if pquasar>0 then
          if not pmotorsound then
            pmotorsound=true
            sfx(0)
          end

          pvy-=.5
          pquasar=max(0,pquasar-one_frame)
        else
          if pmotorsound then
            pmotorsound=false
            sfx(0,-2)
          end
        end
      else
        if(p_onground and pquasar<1)pquasar=1
        if(p_onground and pquasar<10)pquasar=min(pmaxquasar,pquasar+.5*one_frame)
      end

      if pvy<-.5 then
        pvy=-.5
      end

      --[[ collision checks]]
      local exclude_callback=function(e) return e.abducted_t>0 end
      local dx,dy=pvx+pevx,pvy+pevy
      while abs(dx)>0 or abs(dy)>0 do
        local ddx=dx>=1 and 1 or dx<=-1 and -1 or dx
        local rx,ry,re=collision_checks(p,ddx,0,{layer_enemies},exclude_callback)
        px+=rx
        dx-=ddx

        local ddy=dy>=.5 and .5 or dy<=-.5 and -.5 or dy
        local rx,ry,re=collision_checks(p,0,ddy,{layer_enemies},exclude_callback)
        if(ddy>0 and ry==0 and abs(pevy)<2)pevy=-2
        if(ddy>0 and re and abs(pevy)<4)pevy=-4
        py+=ry
        dy-=ddy
      end
      --]]

--[[]]
      if px<0 then
        px=px%1024
        cam:snap(px,-1)
      elseif px>1024 then
        px=px%1024
        cam:snap(px,1)
      end
    --]]  

      -- rainbow boost particles
      if pt%.05>0.02 and pquasar>0 and btn(5) and p_hitt<=1 then
        rainbow_particles(px+1.5-rnd(3),py+1.5-rnd(3))
      end

    end,

    draw=function()
      if(p_aboard)return
      if(game_starting or level_starting)return
      if(g_paused)return

      if(p_hitt<1.5 and p_hitt%.1>.05)return

      local psprite=72

      if p_onground and abs(pvx)>.1 then
        psprite=game_time%.2>.1 and 72 or 74
      end

      if not p_onground then
       psprite=pvy>0 and 76 or 74
      end
      
      pal_clear()

      local ca=color_of_most_friends()
      if ca!=-1 then
        pal(7,ca==6 and 7+pt*8%7 or player_mod_colors[ca])
      end

      if prefilling then
        pal(7,game_time%.2>.1 and 10 or 11)
      elseif pquasar<=pmaxquasar/10 then
        pal(14,game_time%.1>.05 and 0 or 9)
      elseif pquasar<=pmaxquasar/5 then
        pal(14,game_time%.2>.1 and 0 or 9)
      end

      if p_hitt>1.5 then 
        psprite=78
        pal(7,8)
      end

      spr(psprite,px-8,py-16,2,3)

      pal_clear()

      --[[
      local x1,y1,x2,y2=p:aabox()
      circ(px,py,1,8)
      rect(x1,y1,x2,y2,12)

      local x1,y1,x2,y2=p:helmet_aabox()
      rect(x1,y1,x2,y2,8)
      --]]
    end,
  }
end

function shield_circ(os,c1,c2,c3)
  local ptdiv=pt%.4
  circ(bs_x,bs_y,bs_shield_size-os,ptdiv>.3 and c1 or ptdiv>.2 and c2 or ptdiv>.1 and c3 or 10)
end

function make_baseship()
  return 
  {
    init=function()
      bs_takeoff=false
      bs_ay,bs_vx,bs_vy,bs_x,bs_y=0,0,0,512,235
      bs_shield_size=bs_shield_maxsize
    end,

    update=function()
      if(g_paused)return

      -- check if close to ship
      if abs(px-bs_x)<=bs_shield_maxsize and abs(py-bs_y)<=bs_shield_maxsize and pquasar<pmaxquasar then
        prefilling=true
        pquasar=min(pmaxquasar,pquasar+40*one_frame)
      else
        prefilling=false
      end

      if #bs_collection<48 then
        -- check if converted enemies are close to ship
        for k,e in pairs(entities[layer_enemies]) do
          if e.text_hit_t<=.5 and e.abducted_t<=0 and e.health<=0 then
            if abs(e.x-bs_x)<=bs_shield_maxsize and abs(e.y-bs_y)<=bs_shield_maxsize then
              sfx(13)
              e.abducted_t=1
              total_captures+=1

              if check_enemy_reveal_radar(total_captures-1)!=check_enemy_reveal_radar(total_captures) then
                ui_radar_upgrade_t=2
              end

              add(bs_collection,e)

              recompute_upgrades()
              break
            end
          end
        end
      end

      -- check if takingoff
      if btnp(5) then
        if not game_starting then
          if not bs_takeoff and btn(2) and player_close_to_ship() then
            -- check for early takeoff too
            bs_takeoff=true
            music(32,0,3)
          end
        end

        if game_starting or level_starting then
          game_starting=false level_starting=false
        end
      end

      if bs_takeoff then
        bs_ay,bs_vy,bs_vx=min(1,bs_ay-.001),min(2,bs_vy+bs_ay),.5-rnd()
        
        bs_x+=bs_vx
        bs_y+=bs_vy
        bs_shield_size-=bs_shield_size*.2

        rainbow_particles(bs_x,bs_y+8)
      else
        bs_shield_size=bs_shield_maxsize
      end

    end,

    draw=function()
      spr(1,bs_x-8,bs_y-19,2,4)

      if bs_shield_size>1 then
        shield_circ(4,11,10,10)
        shield_circ(2,10,11,10)
        shield_circ(0,10,10,11)
        --circ(bs_x,bs_y,bs_shield_size-4,ptdiv>.3 and 11 or ptdiv>.2 and 10 or ptdiv>.1 and 10 or 10)
        --circ(bs_x,bs_y,bs_shield_size-2,ptdiv>.3 and 10 or ptdiv>.2 and 11 or ptdiv>.1 and 10 or 10)
        --circ(bs_x,bs_y,bs_shield_size  ,ptdiv>.3 and 10 or ptdiv>.2 and 10 or ptdiv>.1 and 11 or 10)
      end
    end,
  }
end

function make_camera()
 return
 {
   tx=0,
   ty=0,

   init=function()
    camx,camy=px-64,py-112
    lcamx=camx
   end,

   snap=function(c,x,dx)
      local adjust_x=(dx<0 and 1024 or -1024)
      local diffx=cam.tx-camx
      cam.tx+=adjust_x
      camx=c.tx-diffx

      for i=1,#entities do 
        for k,v in pairs(entities[i]) do
        if(v.x)v.x+=adjust_x
        end
      end       
   end,
   
   update=function(c)
    if(g_paused)return

    lcamx=camx

    local edgex,edgey=56,64

    if px+edgex>c.tx+128 then
     c.tx=px+edgex-128
    elseif px-edgex<c.tx then
     c.tx=px-edgex
    end

    --c.tx=mid(0,c.tx,8*128-128)
    
    if abs(c.tx-camx)>1 then
     camx+=.1*(c.tx-camx)
    else
     camx=c.tx
    end
--[[]]
    local maxy=edgey
    
    if py+maxy>c.ty+128 then
     c.ty=py+maxy-128
    elseif py-edgey<c.ty then
     c.ty=py-edgey
    end

    c.ty=mid(0,c.ty,128)
    
    if abs(c.ty-camy)>1 then
     camy+=.1*(c.ty-camy)
    else
     camy=c.ty
    end
--]]

   end,
 }
end

function bg_clouds_init()
  bg_t=0
  bg_clouds,bg_clouds2={},{}

  for i=1,32 do
    bg_clouds2[i]={ds=0,s=0,rx=i*20,r=6+rnd(8),p=.1+rnd(.2)}
  end
  for i=1,32 do
    bg_clouds[i]={ds=0,s=0,rx=i*20,r=2+rnd(8),p=.1+rnd(.2)}
  end
end

function bg_clouds_update()
  bg_t+=one_frame
  local tt=1+bg_t*.5

  for i=1,#bg_clouds2 do
    local cloud=bg_clouds2[i]
    cloud.rx-=(camx-lcamx)*.2
    if cloud.rx>32*20 then
      cloud.rx=0
    elseif cloud.rx<-20 then
      cloud.rx=31*20
    end

    cloud.ds=cloud.r*sin(tt*.5*cloud.p+cloud.p)
    cloud.s=8+8*cos(i/12+tt/16)+4*sin(i/7+tt/7)

  end

  for i=1,#bg_clouds do
    local cloud=bg_clouds[i]
    cloud.rx-=(camx-lcamx)*.5
    if cloud.rx>32*20 then
      cloud.rx=0
    elseif cloud.rx<-20 then
      cloud.rx=31*20
    end

    cloud.ds=cloud.r*sin(tt*cloud.p+cloud.p)
    cloud.s=8+8*cos(i/16+tt/10)+4*sin(i/5+tt/4)

  end
end

function bg_clouds_draw()
  local cloud_c=level_colors1

  cls(cloud_c[1])
  camera(camx,0)

  local clouds_x=camx-64

  --[[]]
  local cloud_line=100-camy/4
  for i=1,#bg_clouds2 do
    local cloud=bg_clouds2[i]
    
    local w=20+cloud.ds
    local cx,cy=clouds_x+cloud.rx,cloud_line+cloud.s

    if abs(cx-camx-64)<128 then
      rectfill(cx,cy,cx+20,127,cloud_c[2])
      circfill(cx,cy,w,cloud_c[2])
    end
  end
  --]]

  local cloud_line=170-camy/2
  for i=1,#bg_clouds do
    local cloud=bg_clouds[i]
    
    local w=20+cloud.ds
    local cx,cy=clouds_x+cloud.rx,cloud_line+cloud.s

    if abs(cx-camx-64)<128 then
      rectfill(cx,cy,cx+20,127,cloud_c[4])
      circfill(cx,cy,w,cloud_c[4])

      clip(cx-camx-w*(.3+cloud.p),cy-w,w*2,w*.5)
      circ(cx,cy,w,cloud_c[3])
      clip()
    end
  end
end

function bg_stars_init()
  bg_clouds,bg_clouds2={},{}

  bg_stars_minv=.01+rnd(4)
  bg_stars_maxv=bg_stars_minv+.01+rnd(4)

  for i=1,150 do
    bg_clouds[i]={x=rnd(256)-64,y=rnd(256-32),vx=bg_stars_minv+rnd(bg_stars_maxv-bg_stars_minv),t=rnd()}
  end
end

function bg_stars_update()
  for i=1,#bg_clouds do
    local cloud=bg_clouds[i]
    cloud.t+=one_frame
    cloud.x-=cloud.vx
    if(cloud.x>=192)cloud.x-=256 cloud.y=rnd(256-32) cloud.vx=bg_stars_minv+rnd(bg_stars_maxv-bg_stars_minv)
    if(cloud.x<-64)cloud.x+=256 cloud.y=rnd(256-32) cloud.vx=bg_stars_minv+rnd(bg_stars_maxv-bg_stars_minv)
  end
end

function bg_stars_draw()
  local cloud_c=level_colors1

  cls(cloud_c[1])
  camera(0,0)

  local maxv=bg_stars_maxv-bg_stars_minv
  for i=1,#bg_clouds do
    local cloud=bg_clouds[i]
    local nvx=(cloud.vx-bg_stars_minv)/maxv
    local c=nvx>.5 and cloud_c[3] or cloud_c[4]
    line(cloud.x,cloud.y-camy*nvx,cloud.x+2*cloud.vx,cloud.y-camy*nvx,c)
  end
end

function bg_bubbles_init()
  bg_clouds,bg_clouds2={},{}

  bg_stars_minv=.01+rnd(.1)
  bg_stars_maxv=bg_stars_minv+.01+rnd()

  for i=1,120 do
    bg_clouds[i]={x=rnd(256)-64,y=rnd(256-32),vy=bg_stars_minv+rnd(bg_stars_maxv-bg_stars_minv),t=rnd(),s=1+rnd(9)}
  end
end

function bg_bubbles_update()
  for i=1,#bg_clouds do
    local cloud=bg_clouds[i]
    cloud.t+=one_frame
    cloud.y-=cloud.vy
    cloud.x+=.5-rnd()
    if(cloud.y<-32)cloud.y+=256+32 cloud.x=rnd(256)-64 cloud.vy=bg_stars_minv+rnd(bg_stars_maxv-bg_stars_minv) cloud.s=1+rnd(6)
  end
end

function bg_bubbles_draw()
  local cloud_c=level_colors1

  cls(cloud_c[1])
  camera(0,0)

  local maxv=bg_stars_maxv-bg_stars_minv
  for i=1,#bg_clouds do
    local cloud=bg_clouds[i]
    local s=cloud.vy*10
    local nvy=(cloud.vy-bg_stars_minv)/maxv
    local c=cloud.vy>maxv*.5 and cloud_c[4] or cloud_c[3]
    circ(cloud.x,cloud.y-camy*nvy,s,c)
  end
end

bg_types=
{
  {init=bg_clouds_init,update=bg_clouds_update,draw=bg_clouds_draw},
  {init=bg_stars_init,update=bg_stars_update,draw=bg_stars_draw},
  {init=bg_bubbles_init,update=bg_bubbles_update,draw=bg_bubbles_draw},
}

level_tilesets=
{
  {
    solids=split"128,129,130",
    breakables=split"131,132,133",
    grass=split"134,135",
  },
  {
    solids=split"144,145,146",
    breakables=split"147,148,149",
    grass=split"150,151,152",
  },
  {
    solids=split"160,161,162",
    breakables=split"163,164,165",
    grass=split"166,167,168",
  },
  {
    solids=split"176,177,178",
    breakables=split"179,180,181",
    grass=split"182,183,184",
  },
  {
    solids=split"192,193,194",
    breakables=split"195,196,197",
    grass=split"198,199,200,201",
  },
}

bg_colors1=
{
  --[[]]
  split"12,15,6,7",
  split"1,2,6,7",
  split"0,1,2,5",
  split"2,4,10,8",
  split"8,2,8,1",
  split"8,10,11,12",
  split"12,11,10,8",
  --]]
}

bg_ground_colors=
{
  --[[]]
  split"5,11,3,9",
  split"5,4,3,11",
  split"2,4,9,10",
  split"5,13,12,7",
  split"2,10,11,12",
  split"2,12,11,10",
  --]]
}

bg_grass_colors=
{
  --[[]]
  split"3,11",
  split"13,12",
  split"4,10",
  --]]
}

function make_level()
 return
 {
    init=function(e)
      entities[layer_enemies]={} -- clear all enemies

      srand(level_seed)

      local hplanet=level_planet*.5

      level_colors1,
      level_ground_colors,
      level_grass_colors,
      level_bg_type,
      level_tileset=
      bg_colors1[rnd_i(min(hplanet,#bg_colors1))],
      bg_ground_colors[rnd_i(min(hplanet,#bg_ground_colors))],
      rnd(bg_grass_colors),
      bg_types[rnd_i(min(hplanet,#bg_types))],
      level_tilesets[rnd_i(min(hplanet,#level_tilesets))]

      -- bg init
      level_bg_type.init()

      -- make level mountains
      local maxh,minh,maxp,minp,noise=2+rnd(12),1+rnd(6),flr(.5+rnd(2)),flr(2+rnd(4)),1+rnd(2)

      for i=0,127 do
        local h=maxh*cos(i/128*maxp)+minh*cos(i/128*minp)+rnd(noise)
        local ship_dist=abs(i-64)
        h*=min(1,ship_dist<=2 and 0 or ship_dist/16)
        for j=0,31 do
          if j==31 then
            mset(i,j,rnd(level_tileset.solids))
          elseif j>=31-h then
            mset(i,j,rnd(level_tileset.breakables))
          elseif j==30 and rnd()>.7 then
            mset(i,j,rnd(level_tileset.grass))
          else
            mset(i,j,0)
          end
        end
      end

      local enemy_count=min(10,4+rnd(min(10,level_planet)))

      --[[enemies in the level]]
        for i=1,enemy_count do
          local x,y=rnd(1024),16+rnd(256-48)
          enemy=make_enemy(level_seed+rnd(),x,y)
          add(entities[layer_enemies],enemy)
        end
      --]]

    end,

    update=function()
      if(g_paused)return
      level_bg_type.update()
    end,

    draw=function()
      level_bg_type.draw()
      
      camera(camx,camy)
      local mpx=flr(px/(8*128))

      pal(2,level_ground_colors[1])
      pal(4,level_ground_colors[2])
      pal(9,level_ground_colors[3])
      pal(10,level_ground_colors[4])
      pal(3,level_grass_colors[1])
      pal(11,level_grass_colors[2])

      map(0,0,(mpx-1)*1024,0,128,64)
      map(0,0,mpx*1024,0,128,64)
      map(0,0,(mpx+1)*1024,0,128,64)

      pal_clear()
    end,
 }
end

core_types=split"11,12,13,14,15,27,28,29,30,31"
limb_types=split"38,39,40,41,42,43,44,45,46,47,52,53,54,55,56,57,58,59,60,61,62,63"
enemy_colors=
{
  split"3,11", -- green (common)
  split"13,12", -- blue (rare)
  split"2,14", -- pink (rare)
  split"9,10", -- yellow (ultra rare)
  split"6,7", -- white (mega ultra rare)
  split"1,0", -- black (uber ultra mega rare)
}

function enemy_upgrades_table(maxq,maxq_r,dmg,dmg_r,maxs,maxs_r)
  return
  {
    maxq=maxq,
    maxq_r=maxq_r,
    dmg=dmg,
    dmg_r=dmg_r,
    maxs=maxs,
    maxs_r=maxs_r,
  }
end

upgrade_table=
{
  enemy_upgrades_table(unpack(split"0.2, 0.2, 0.1, 0.1, 0.3, 0.3")), -- green
  enemy_upgrades_table(unpack(split"0.5, 0.5, 0.2, 0.2, 0.5, 1.0")),  -- blue
  enemy_upgrades_table(unpack(split"0.8, 0.8, 0.3, 0.3, 1.0, 2.0")),  -- pink
  enemy_upgrades_table(unpack(split"2.0, 4.0, 0.5, 0.5, 3.0, 5.0")),  -- yellow
  enemy_upgrades_table(unpack(split"4.0, 8.0, 1.0, 1.0, 5.0, 8.0")),  -- white
  enemy_upgrades_table(unpack(split"8.0,12.0, 2.0, 2.0, 8.0,16.0")), -- black
}

function make_enemy(s,x,y)
 local e=
 {
    init=function(e)
      e.s=s
      srand(e.s)
      e.x,e.y,e.vx,e.vy=x,y,0,0
      e.lapsed_t=0
      e.t=x/64+y/32

      e.hit_t,e.text_hit_t=0,0
      e.hit_vx,e.hit_vy=0,0

      e.abducted_t=0

      -- make sure there are no tiles in the way...
      local x1,y1,x2,y2=e:aabox()

      for j=y1-1,y2+1,4 do
        for i=x1-1,x2+1,4 do
          if(check_flag(i,j,2))set_map(i,j,0)
        end
      end

      local planet,pcluster=flr(s%100),flr(s/100)

      local level_max_core,level_max_limb=flr(min(#core_types,2+planet*.5)),flr(min(#limb_types,4+planet*.5))

      local c=rnd()+.01*planet/100
      local ci=c>.999 and 6 or  -- black   1/1000
               c>.99 and 5 or   -- white   1/100
               c>.97 and 4 or   -- yellow  2/100
               c>.9  and 3 or   -- pink    7/100
               c>.75 and 2 or 1 -- blue   15/100

      if planet==99 then
        ci=c>.75 and 6 or 
           c>.5  and 5 or 4
      end

      local ut=upgrade_table[ci]

      e.up_pmaxquasar=flr10(ut.maxq+rnd(ut.maxq_r))
      e.up_pdamage=ut.dmg+rnd(ut.dmg_r)
      e.up_pdamage=flr(e.up_pdamage*100)/100
      e.up_bs_shield_maxsize=flr10(ut.maxs+rnd(ut.maxs_r))

      e.ci=ci
      e.colors=enemy_colors[ci]

      -- tunables:
      e.health=2*ci*(ceil((planet+1)+rnd(planet+1)))
      e.range_r=24+rnd(40+ci*5) --detection range in x
      e.range_av=.5+rnd(.5+ci*.1)--.75-rnd(1.5)

      e.mvx,e.mvy=rnd(.2),rnd(.2)
      e.pvx,e.pvy=rnd(.2),rnd(.2)
      local core_count=1+flr(rnd(3))

      e.cores={}

      for j=1,core_count do
        local size=1+flr(rnd(4))
        local rel_x,rel_y=1+flr(rnd(size)),flr(rnd(size*1.5))
        local core={type=core_types[1+flr(rnd(level_max_core))],rel_x=rel_x,rel_y=rel_y,limbs={}}
        core.odd=(core.type>=27)
        add(e.cores,core)

        local limb_count=1+flr(rnd(size/2))

        core.limbs={}

        for i=1,limb_count do
          add(core.limbs,{type=limb_types[1+flr(rnd(level_max_limb))],len=2+rnd(core.odd and 3 or 5),a=rnd(.5),da=.01+rnd(.09)})
        end

      end      

    end,

    aabox=function(e)
      return e.x-6,e.y-4,e.x+4,e.y+6
    end,

    update=function(e)
      if(g_paused)return

      e.lapsed_t+=one_frame
      e.hit_t=max(0,e.hit_t-one_frame)
      e.text_hit_t=max(0,e.text_hit_t-one_frame)
      e.t+=one_frame

      if e.abducted_t>0 then
        e.abducted_t=max(0,e.abducted_t-one_frame)

        local nx,ny,m=normalize(bs_x-e.x,bs_y-e.y)
        e.x+=m*nx*.1
        e.y+=m*ny*.1

        if e.abducted_t<=0 then
          e.hit_t=0
          del(entities[layer_enemies],e)
        end

        return
      end

      e.vx,e.vy=e.mvx*cos(e.t*e.pvx),e.mvy*cos(e.t*e.pvy)

      if e.hit_t>0 then
        local m=e.hit_t*10
        e.vx+=e.hit_vx*m
        e.vy+=e.hit_vy*m
      end

      if not game_starting and not level_starting then

        if e.health>0 then
          -- angry
          e.vx+=.5-rnd()
          e.vy+=.5-rnd()

          -- check if inside range of the player
          if abs(e.x-px)<=e.range_r then
            local nx,ny,m=normalize(e.x-px,e.y-py)
            e.range_mul=mid(.2,1-(m-16)/(e.range_r-16),1)*(ny>0 and e.range_av or -e.range_av)
            e.vx+=2*nx*e.range_mul
            e.vy+=ny*e.range_mul

            -- check if hitting the helmet of the player
            if not prefilling and p_hitt<=0 then
              
              local px1,py1,px2,py2=p:helmet_aabox()
              local ex1,ey1,ex2,ey2=e:aabox()

              if px2<ex1 or px1>ex2 or py2<ey1 or py1>ey2 then
              else
                sfx(5)

                --damage player: takes 5 quasar energy
                pevx+=4*(nx>0 and -1 or 1)
                pevy-=4*ny
                p_hitt=2
                player_hits+=1
                pquasar=max(0,pquasar-10)
                explode(px,py,24,8,.8,rev_rainbow_colors)
              end
            end
          else
            -- not in range of the player, try to get it back in a comfy spot in y
            if e.y>256-48 then
              e.vy-=.1
            elseif e.y<48 then
              e.vy+=.1
            end
          end

        else
          -- following you to ship
          local distx=abs(e.x-px)
          local followx=24
          if distx>followx+8 or distx<followx-8 then
            local nx,ny,m=normalize(e.x-px,e.y-py)
            e.range_mul=mid(-1,(m-16)/(followx-16),1)
            e.vx-=nx*e.range_mul
            e.vy-=ny*e.range_mul
          end
        end
      end

      local rvx,rvy=collision_checks(e,e.vx,0,{layer_player})
      e.x+=rvx

      local rvx,rvy=collision_checks(e,0,e.vy,{layer_player})
      e.y+=rvy

--[[ make sure enemies are always in the relative space of the player]]
      while (e.x-px)>(1024-256) do
        e.x-=1024
      end

      while (e.x-px)<-(1024-256) do
        e.x+=1024
      end      
--]]
    end,

    draw_impl=function(e,time,ox,oy,shadow)
      local cos_t=cos(time)
      local x,y=flr(ox)-4,flr(oy)-4
      ovalfill(x,y+1,x+6,y+7,3)
      if(not shadow)ovalfill(x+1,y+2,x+5,y+6,11)
--[[]]
      for k,core in pairs(e.cores) do
        local cx1,cx2,cy=x+core.rel_x,x-core.rel_x,y+core.rel_y
        local odd=core.odd and 1 or 0

        for k2,limb in pairs(core.limbs) do
          local a=limb.a+limb.da*cos_t
          local x1,y1=polar_to_xy(limb.len,a+.75)
          local x2,y2=polar_to_xy(limb.len,-a-.25)
          spr(limb.type,cx1+x1+odd,cy+y1,1,1,true)
          spr(limb.type,cx2+x2-odd,cy+y2)
        end
      end
--]]
      for k,core in pairs(e.cores) do
        local cx,cy=x+core.rel_x+(core.odd and 1 or 0),y+core.rel_y
        spr(core.type,cx,cy)
        cx=x-core.rel_x-1
        spr(core.type,cx,cy)
      end

      if not shadow then
        for k,core in pairs(e.cores) do
          local cx,cy=x+core.rel_x+(core.odd and 1 or 0),y+core.rel_y
          local blink=time%4<.2 or e.hit_t>0
          local eyespr=core.odd and (blink and 22 or 21) or (blink and 6 or 5)
          spr(eyespr,cx,cy)
          cx=x-core.rel_x-1
          spr(eyespr,cx,cy)
        end
      end
    end,

    draw=function(e)
      if e.abducted_t>0 then
        local s=6*e.abducted_t
        local x,y=flr(e.x),flr(e.y)
        pal(3,e.colors[1])pal(11,e.colors[2])
        ovalfill(x-s,y-s+1,x+s,y+s+1,0)
        ovalfill(x-s,y-s,x+s,y+s,3)
        ovalfill(x-s+1,y-s+1,x+s-1,y+s-1,11)
        return
      end

      pal_fill()
      
      e:draw_impl(e.t,e.x,e.y+1,true)

      pal_clear()

      local bad=e.health>0

      if bad then
        if e.hit_t>0 then
          local damage_c=e.colors
          local c=rnd(damage_c)
          pal(11,c)
          local bc=rnd(damage_c)
          pal(3,bc)
        else
          local c=e.t%.2>.1 and 8 or 10
          local bc=e.t%.2>.1 and 2 or 8
          pal(14,c)
          pal(3,bc)
          pal(11,c)
        end
      else
        pal(3,e.colors[1])pal(11,e.colors[2])
      end

      e:draw_impl(e.t,e.x,e.y)
      
      pal_clear()

      local x1,y1,x2,y2=e:aabox()
      if(e.health>0 and e.text_hit_t>0)printb(""..ceil(e.health),(x1+x2)*.5+1,y2+2,7,0,align_c)
      
      --[[
      circ(e.x,e.y,e.range_r,8)
      circ(e.x,e.y,1,e.t%.2>.1 and 1 or 12)
      rect(x1,y1,x2,y2,8)
      
      if(e.range_mul)printb(""..flr(e.range_mul*100)/100,(x1+x2)*.5+1,y1-6,7,0,align_c)

      --printb(""..e.x,e.x,e.y,7,0)
      --]]
    end,
 }

 e.s=s

 return e
end

inv_y=128
inv_selection=0
consume_selection=1

function draw_consume_screen()
  local oc=0

  draw_console()  

  printb("- "..tostr(enemy.s,true).." -",64,inv_y+8,oc,7,align_c)


  local y=inv_y+41
  printb("RELEASE YOUR FRIEND",64,y,oc,7,align_c)y+=7
  printb("UPON THE UNIVERSE?",64,y,oc,7,align_c)y+=10

  local enemy=bs_collection[inv_selection+1]
  draw_inventory_enemy(enemy,-1,64,inv_y+26,8,4,8,10)

  local sy=inv_y+55+consume_selection*10
  roundrect(40,sy,87,sy+10,1,12)
  roundrect(41,sy+1,86,sy+9,1,13)

  printb("do it!",64,y,oc,7,align_c)y+=10
  printb("cancel",64,y,oc,7,align_c)

  pal_clear()
end

function draw_inventory_enemy(enemy,i,ii,jj,w,h,c,bc)
  pal_fill(inv_selection==i and bc or 0)
  local tt=t()+enemy.t
  local x,y=ii+2*cos(tt/3),jj+3*sin(tt/2)
  enemy:draw_impl(tt,x,y+1,true)

  pal_clear()
  pal(3,enemy.colors[1])pal(11,enemy.colors[2])

  enemy:draw_impl(tt,x,y)
end

function draw_console()
  roundrect(9,inv_y,118,inv_y+102,8,1)
  roundrect(2,inv_y+80,125,inv_y+137,8,1)

  roundrect(10,inv_y+1,117,inv_y+101,8,7)
  roundrect(3,inv_y+81,124,inv_y+136,8,7)

  roundrect(14,inv_y+5,113,inv_y+88,8,6)
  roundrect(15,inv_y+6,112,inv_y+87,8,5)

  roundrect(7,inv_y+93,118,inv_y+126,8,6)
  roundrect(8,inv_y+94,117,inv_y+125,8,5)

  local enemy=bs_collection[inv_selection+1]
  
  if enemy then
    local sym,c="+",10
    if g_consume_screen then
      sym,c="-",9
    end

    printb("r:"..sym..enemy.up_bs_shield_maxsize,20,inv_y+78,c,1)
    printb("p:"..sym..enemy.up_pmaxquasar,64,inv_y+78,c,1,align_c)
    printb("d:"..sym..flr10(enemy.up_pdamage),109,inv_y+78,c,1,align_r)
  end  
end

function draw_inventory()

  draw_console()

  local pages=ceil(#bs_collection/16)
  local cur_page=flr(inv_selection/16)
  local screen_selection=inv_selection%16

  if cur_page>0 then
    printb("\148 prev page \148",61,inv_y+3,7,1,align_c)
  end

  if cur_page<pages-1 then
    printb("\131 next page \131",61,inv_y+86,7,1,align_c)
  end

  local blinkc=t()%.3>.1 and 10 or 4

  for index=cur_page*16+1,cur_page*16+16 do
    local i=(index-1)%16

    local c=screen_selection==i and 8 or 6
    local bc=screen_selection==i and blinkc or 1

    local ii,jj=29+i%4*24,inv_y+15+flr(i/4)*16
    local w=screen_selection==i and 8 or 4
    local h=screen_selection==i and 4 or 2

    local enemy=bs_collection[index]
    if enemy then
      ovalfill(ii-2-w,jj+8-h,ii+w,jj+8+h,c)
      oval(ii-2-w,jj+8-h,ii+w,jj+8+h,bc)
      draw_inventory_enemy(enemy,(index-1),ii,jj,w,h,c,bc)
    end
  end

  pal_clear()
end

enemy_shows_on_radar=split("50,100,200,300,500,1000") --green,blue,pink,yellow,white,black

function check_enemy_reveal_radar(n)
  for i=1,#enemy_shows_on_radar do
    if n<enemy_shows_on_radar[i] then
      return i-1
    end
  end

  return #enemy_shows_on_radar
end

function draw_radar()
  fillp(0b0101101001011010.1)
  local x1,y1=32,12
  local x2,y2=96,29
  rectfill(x1,y1,x2,y2,0)
  fillp()
  rect(x1-1,y1-1,x2+1,y2+1,1)
  rect(x1-2,y1-2,x2+2,y2+2,2)

  local bt=t()%.2>.1

  -- ship
  local shipx,shipy=(bs_x-px)/1024*(x2-x1),mid(0,bs_y/256,1)*(y2-y1)
  pset(64+shipx,y1+shipy,bt and 7 or 10)
  pset(64+shipx,y1+1+shipy,bt and 7 or 10)

  -- player
  if(not p_aboard)pset(64,y1+(y2-y1)*(py/256),bt and 7 or 5)

  pal()

  for k,e in pairs(entities[layer_enemies]) do
    local tex=(e.x-px)/1024
    if(tex>.5)tex-=1
    if(tex<-.5)tex+=1
    local ex,ey=tex*(x2-x1),e.y/256*(y2-y1)
    local c=e.health<=0 and e.colors[2] or bt and 8 or 10

    if enemy_shows_on_radar[e.ci]<=total_captures then
      c=e.colors[2]
    end

    pset(64+ex,y1+ey,c)
  end

  if ui_radar_upgrade_t>0 and t()%.4>.1 then
    printb("- radar upgraded -",64,y2+6,7,1,align_c)
  end  

  pal_clear()
end

function goto_next_level()
  p:init()
  bs:init()

  level_planet+=1
  if level_planet>99 then
    level_pcluster,level_planet=flr(rnd(320)),0
  end

  level_seed=100*level_pcluster+level_planet

  total_planets+=1

  save_game()
  _init()

  level_starting=true
end

function player_close_to_ship()
  return abs(px-bs_x)<=32 and abs(py-bs_y)<=32
end

function make_ui()
  return
  {
    update=function()

      if g_paused then
        inv_y+=(3-inv_y)*.2
      else
        inv_y+=(128-inv_y)*.2
      end
      --inv_y=11+3.5*cos(t()*.5)

      ui_radar_upgrade_t=max(0,ui_radar_upgrade_t-one_frame)
      game_saved_t=max(0,game_saved_t-one_frame)

      -- check if level is cleared
      if bs_y<-100 then
        goto_next_level()
      end

      if g_consume_screen then
        -- consume enemy screen
        if(btnp(4))g_consume_screen=false sfx(11)

        if btnp(5) then
          local e=bs_collection[inv_selection+1]
          if(consume_selection==0)deli(bs_collection,inv_selection+1)

          sfx(consume_selection==1 and 11 or 12)

          inv_selection=min(#bs_collection-1,inv_selection)
          
          g_consume_screen=false

          recompute_upgrades()
        end

        if(btnp(2))consume_selection=max(0,consume_selection-1) sfx(9)
        if(btnp(3))consume_selection=min(1,consume_selection+1) sfx(9)
      else
        
        if g_paused then
          local maxi=max(0,#bs_collection-1)
          if(btnp(0))inv_selection=max(0,inv_selection-1) sfx(9)
          if(btnp(1))inv_selection=min(maxi,inv_selection+1) sfx(9)
          if(btnp(2))inv_selection=max(0,inv_selection-4) sfx(9)
          if(btnp(3))inv_selection=min(maxi,inv_selection+4) sfx(9)

          -- check if player has selected a victim
          if btnp(5) then
            local e=bs_collection[inv_selection+1]
            if e!=nil then
              sfx(10)
              consume_selection=1
              g_consume_screen=true
            end
          end
        end

        if g_paused and btnp(4) then
          -- unpause
          sfx(11)
          g_paused=false
        end

        if not bs_takeoff and not level_starting and not g_paused and btnp(5) and btn(3) then
          if player_close_to_ship() then
            -- check inventory only close to the ship
            sfx(10)
            g_paused=true
          end
        end
      end
    end,

    draw=function()
      camera()

      local oc=1

      if game_starting_t<.2 then
        -- title screen
        local gt=game_starting_t/.2
        local oy=-gt*gt*60

        printb("- picoter8 2020 -",64,2,7,1,align_c)

        pal_fill(0)
        for i=-1,1 do
          for j=-1,1 do
            spr(224,2+i,30+j+oy,10,2)
            spr(66,26+i,50+j+oy,4,2)
          end
        end

        pal_clear()

        spr(224,2,30+oy,10,2)
        spr(66,26,50+oy,4,2)

        spr(138,80+4*cos(t()*.3),20+2*sin(t()*.5)+oy,6,7)
      end

      --if not game_starting and not level_starting then
      if not game_starting then
        -- quasar meter
        rectfill(0,0,127,8,0)
        rect(0,0,127,8,2)

        if pquasar>=0 then
          local c=split"12,11,10,8,10,11,12"
          for i=1,7 do
            line(1,i,1+pquasar,i,c[i])
          end
        end

        print("quasar kid",2,2,1)
        printa(""..decimal_text(pquasar),127,2,1,align_r)
      end

      --if((not game_starting and not level_starting) and (pt<5 or player_close_to_ship()))printb("- planet "..level_pcluster.."-"..level_planet.." -",64,34,7,oc,align_c)
      if(not game_starting  and (pt<5 or player_close_to_ship()))printb("- planet "..level_pcluster.."-"..level_planet.." -",64,34,7,oc,align_c)

      if game_saved_t>0 then
        if(t()%.4>.1)printb("- game saved -",64,121,7,oc,align_c)
      end

      if g_paused or inv_y<127.5 then
        if g_consume_screen then
          draw_consume_screen()
        else
          draw_inventory()
        end
      end

      if g_paused or inv_y<127.5 then
        local oc=1
        printb("hits:"..player_hits,64,inv_y+96,7,oc,align_c)

        printb("radius:"..round(bs_shield_maxsize),14,inv_y+104,7,oc)
        printb("power:"..round(pmaxquasar),14,inv_y+110,7,oc)
        printb("damage:"..round(pdamage),14,inv_y+116,7,oc)

        printb(total_planets.." planets",113,inv_y+104,7,oc,align_r)
        printb(time_to_text(game_time).." time",113,inv_y+110,7,oc,align_r)
        printb(total_captures.." aliens",113,inv_y+116,7,oc,align_r)
      else
        if(not game_starting)draw_radar()

        if game_starting then
          if(t()%.4>.1)printb(" start game:\151",62,75,7,oc,align_c)
        elseif level_starting then
          printb("leave planet:\148+\151",bs_x-camx-2,74,7,oc,align_c)
          printb("explore planet:\151",bs_x-camx-2,82,7,oc,align_c)
        elseif not bs_takeoff then

          if player_close_to_ship() then
            printb("leave planet:\148+\151",bs_x-camx-2,74,7,oc,align_c)
            printb("enter ship:\131+\151",bs_x-camx-2,82,7,oc,align_c)
          elseif #entities[layer_enemies]==0 and t()%.4>.1 then
            --if abs(px-bs_x)<=bs_shield_maxsize and abs(py-bs_y)<=bs_shield_maxsize then
            --  printb("- ready for takeoff? -",64,54,7,oc,align_c)
            --  printb("press \151",64,62,7,oc,align_c)
            --else
              printb("- all aliens collected -",64,54,7,oc,align_c)
              printb("return to ship for takeoff",64,62,7,oc,align_c)
            --end
          elseif #bs_collection>=48 and t()%.4>.1 then
            -- warn player he has too many friends
            printb("- warning: too many friends -",64,54,7,oc,align_c)
            printb("release some to the universe",64,62,7,oc,align_c)
          end
        end
      end      
    end,
  }
end

layer_background,
layer_enemies,
layer_player_blue_fx,
layer_player_green_fx,
layer_player_yellow_fx,
layer_player_red_fx,
layer_player,
layer_camera,
layer_player_postfx,
layer_baseship,
layer_ui=1,2,3,4,5,6,7,8,9,10,11


function _init()

  music(0,0,3)

  if has_save_data then
    load_game()
  else
    reset_game()
  end

  menuitem(1,"galaxy jump!?",galaxy_jump)
  menuitem(2,"reset progress!?",reset_game)

  entities={}

  entities[layer_background],
  entities[layer_player_blue_fx],
  entities[layer_player_green_fx],
  entities[layer_player_yellow_fx],
  entities[layer_player_red_fx],
  entities[layer_player],
  entities[layer_player_postfx],
  entities[layer_baseship],
  entities[layer_camera],
  entities[layer_enemies],
  entities[layer_ui]
  ={},{},{},{},{},{},{},{},{},{},{}
  
  p=make_player()
  add(entities[layer_player],p)

  cam=make_camera()
  add(entities[layer_camera],cam)

  level=make_level()
  add(entities[layer_background],level)

  bs=make_baseship()
  add(entities[layer_baseship],bs)

  ui=make_ui()
  add(entities[layer_ui],ui)

 for i=1,#entities do 
  for k,v in pairs(entities[i]) do
   if(v.init)v.init(v)
  end
 end 
end


function _update60()
 one_frame=1/stat(8)

 if(not game_starting)game_starting_t=min(1,game_starting_t+one_frame)

 for i=1,#entities do 
  for k,v in pairs(entities[i]) do
   if(v.update)v.update(v)
  end
 end

 --[[debug planets
 if btnp(0,1) then
  level_planet=max(0,level_planet-1)
  level_seed=100*level_pcluster+level_planet
  save_game()
  _init()
 elseif btnp(1,1) then
  goto_next_level()
 end

 if btnp(2,1) then
  level_pcluster=flr(rnd(320))
  level_seed=100*level_pcluster+level_planet
  save_game()
  _init()
 end 
 --]]
end

function _draw()
  pal_clear()

  for i=1,#entities do 
    for k,v in pairs(entities[i]) do
      if(v.draw)v.draw(v)
    end
  end

  --camera()
  --y=115
  --print(""..(p_onground and "ground" or "air"),0,0,7)
  --print("mem:"..stat(0),0,y,0)y-=6
  --print("shield:"..bs_shield_maxsize,0,y,0)y-=6
  --print("count:"..(#bs_collection),0,y,0)y-=6
  --print("px:"..px,0,y,0)y-=6
  --print("("..pvx..","..(pvy+pevy)..")",0,y,0)y-=6
  --print(""..pevy,0,y,0)

end
__gfx__
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb000b0000b00000000000b00b0000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b3333b0003bb300000bb0000b3bb3b030033003
0070070000000000000000000000000000000000000770000000000000000000000000000000000000000000b333333bb0bbbb0b00b33b00b333333b0b3333b0
0007700000000000000000000000000000000000007ee7000007700000000000000000000000000000000000b333333b0bbbbbb00b3333b00b3333b003333330
000770000000000ee00000000000000000000000007ee7000000000000000000000000000000000000000000b333333b0bbbbbb00b3333b00b3333b03b3333b3
00700700000000edde0000000000000000000000000770000000000000000000000000000000000000000000b333333bb0bbbb0b00b33b00b333333b00333300
0000000000000edddde0000000000000000000000000000000000000000000000000000000000000000000000b3333b0003bb300000bb0000b3bb3b000b33b00
0000000000000edddde00000000000000000000000000000000000000000000000000000000000000000000000bbbb000b0000b00000000000b00b0003000030
000000000000edddddde0000000000000000000000000000000000000000000000000000000000000000000000000000b00b00b0000000000000000000000000
000000000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000003bbb3000b0b0b000b0b0b00000b000000000000
000000000000eaaaaaae000000000000000000000007000000000000000000000000000000000000000000003b333b30003330000033300000b3b00000b3b000
00000000000eaaaaaaaae0000000000000000000007e70000077700000000000000000000000000000000000bb333bb0bb333bb00b333b000b333b0000333000
00000000000eaaaeeaaae00000000000000000000007000000000000000000000000000000000000000000000b333b00003330000033300000b3b00000b3b000
00000000000eaae77eaae000000000000000000000000000000000000000000000000000000000000000000000bbb0000b0b0b000b0b0b00000b000000000000
0000000000eaaae77eaaae00000000000000000000000000000000000000000000000000000000000000000000000000b00b00b0000000000000000000000000
0000000000eaaaaeeaaaae0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000eaaaaaaaaaae00000000000000000000000000000333300003333000003bbb0007b000000033bb000003b300003bbb0000bbb300bbbbb00000bbbb
0000000000eaaaaeeaaaae00000000000000000000000000003bbbbb003bbbb3003bbbb300003b0003bbbb3b000bbbbb003bbb3b000b300b0b33333b000bb33b
0000000000eaeae77eaeae0000000000000000000000000003bb333303bbbbbb03bb30b307b333b00b0b0b0b03b3bbbb3bbb333b000b000070333bbb00bb3003
0000000000ee8ae77ea9ee000000000000000000000000000bb000000bb303bb0bb000b0003b33b00b07070b0700b3b3700033bb003b3000000bb33b0bb3b700
0000000000e88aaeeaa99e000000000000000000000000000b3000700b3000330bb007307b33b3b007000007000b30b0000003b33bbbbb30007033b0bb300000
000000000e888aaaaaa999e00000000000000000000000000bb003b00b3000000bb3000000b3b3b30000000000b300b000000bb0b0b0b0b000000b00b3b70000
00000000e8888aaeeaa9999e00000000000000000000000003bb3b3003b3070003bb0070000bbbbb0000000000700b3000000b30b07070b000007000b3300000
00000000e8888ae77ea9999e000000000000000000000000003bb300003bb000003bbb30000003bb00000000000007000000070070000070000000003bb70000
00000000e8888ae77ea9999e000d000003bbb0000003bb3000000000000003b300000b30000000b300bbbb0000000700000003b003b700000000bbb30003bbb3
00000000e8888aaeeaa9999e00aaa0000b003b00000b00b303bbb30303bbbb3000003b000bbb000b0b3003b00000bb0000003bbb3b3003b3003b300b03bb000b
00000000e888eaaaaaae999e00a7a0000b000b00000b300b07003bbb3b003b000000b300b300b00bb30370b00000bb300000bbbbbb33bbbb00b000000b000000
00000000e888eaaaaaae999e00aaa00003700b000000b300000003b3b30003b00000b000b070b00bb00b00b00000bbb30000bbb3bbbbbb3300b30000b303bb00
00000000e88e0e3333e0e99e00a7a0000000b30003700b00000000b0b00000b0003bbb30b03b30b3b303bb000000bbbb0000bb30bbbb3300000b0000b00b00b0
00000000e8e000e33e000e9e08aaa900000b300b0b000b00000000b0b00000b003b000b3b30000b00b00000000003bbb0000bb00bb3300000003b000b30370b0
00000000e8e000e33e000e9e08aba900000b00b30b003b0007003b3037000730007000700b303b3003bb000b000003b0000007003bb300000000b0000b3003b0
000000000e00000ee00000e0080b09000003bb3003bbb00003bbb300000000000000000000bbb0000003bbb30000000000000000033b70000007300000bbbb00
000d0000000000007070000070700070700077777777000000000000000000000000000000000000000000eeeee00000000000eeeee00000000000eeeee00000
00aaa0000daa0000707000007070007070007000000070000000000000000000000000eeeee0000000000e77777e000000000e77777e000000000e77777e0000
00a7a0000aaaa00070700007007000707000707777700700000000000000000000000e77777e00000000e7eeeee7e0000000e7eeeee7e0000000e7eeeee7e000
00aaa0000aa7aa907070007007000070700070700007007000000000000000000000e7eeeee7e000000e7e0e9e0e7e00000e7e0e9e0e7e00000e7e0e9e0e7e00
00a7a00000aa7aa9707007007000007070007070000070700000000000000000000e7e0e9e0e7e0000e7e07e9e00e7e000e7e07e9e00e7e000e7e07e9e00e7e0
08aaa900000aab0070707007000000707000707000007070000000000000000000e7e07e9e00e7e00e7e9ee999ee9e7e0e7e9ee999ee9e7e0e7e9ee999ee9e7e
08aba9000008a0007077007000000070700070700000707000000000000000000e7e9ee999ee9e7e0e7e99e999e99e7e0e7e99e999e99e7e0e7e99e999e99e7e
080b0900000080007000070000000070700070700000707000000000000000000e7e99e999e99e7e0e7e999999999e7e0e7e999999999e7e0e7e999999999e7e
00000000000090007077007000000070700070700000707000000000000000000e7e999999999e7e0e7e99e999e99e7e0e7e99e999e99e7e0e7e9ee999ee9e7e
000000000009a0007070700700000070700070700000707000000000000000000e7e99e999e99e7e0e7ee9999999ee7e0e7ee9999999ee7e0e7ee999e999ee7e
00000999000aab007070070070000070700070700000707000000000000000000e7ee9999999ee7e00e7e9eeeee9e7e000e7e9eeeee9e7e000e7e99e9e99e7e0
0aaaaaa000aa7aa870700070070000707000707000070070000000000000000000e7e9eeeee9e7e0000e759e8e957e0000ee759e8e957ee000ee759999957ee0
da7a7abb0aa7aa80707000070070007070007077777007000000000000000000000e759e8e957e0000e75777777757e00e7757777777577e0e7757777777577e
0aaaaaa00aaaa00070700000707000707000700000007000000000000000000000e75777777757e00e7ee727b787ee7e00eee727b787eee000eee727b787eee0
000008880daa000070700000707000707000777777770000000000000000000000e7e727b787e7e000e0e7777777e0e0000e777777777e00000e777777777e00
0000000000000000000000000000000000000000000000000000000000000000000ee7777777ee00000e7eeeeeee7e000000eeeeeeeee0000000eeeeeeeee000
0090b0800008000000077777000000007777700000000000000000755700000000000e7eee7e00000000e0000000e00000000000000000000000000000000000
009aba80000a8000007755550000000055557700000000000000007557000000000000e000e00000000000000000000000000000000000000000000000000000
009aaa8000baa0000775511100000000111557700000000000000775577000000000000000000000000000000000000000000000000000000000000000000000
000a7a009aa7aa000755111100000000111155700000000000000755557000000000000000000000000000000000000000000000000000000000000000000000
000aaa0009aa7aa07751111100000000111115770000000000007755557700000000000000000000000000000000000000000000000000000000000000000000
000a7a00000aaaa07551111100000000111115570000000000077555555770000000000000000000000000000000000000000000000000000000000000000000
000aaa000000aad07511111100000000111111570000000077775555555577770000000000000000000000000000000000000000000000000000000000000000
0000d000000000007511111100000000111111570000000055555555555555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888000000000aad00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa0000aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bba7a7ad08aa7aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa08aa7aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9990000000baa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444404aaaaa004aaaaa004aaaaa0000000000000000000000000000000000000000000000000000eeee0000000000000000000000000
444444444444944444494444499499aa499499aa494999aa00000000000000000000000000000000000000000000000eeee7777eeee000000000000000000000
94994999949999499499994949499a9a494a999a4999a99a00000000000000000000000000000000000000000000eee7777eeee7777eee000000000000000000
9999499994999999999999994994949a49999a9a49a4949a000000000000000000000000000000000000000000ee777eeee0000eeee777ee0000000000000000
a9a9999a999a9aaaaaa99aaa4499499a44994a9a4994999a0b000000000000b00000000000000000000000000e77eee77e000000000eee77e000000000000000
aaaa9a9aa9aa9aaaaaaa9aaa494949aa4994999a4999a94a0bb00b00000b0bb000000b000000000000000000e7eeee7777e00000000000ee7e00000000000000
aaaaaaaaaaaaaaaaaaaaaaaa449494944499949444999994bbb0bbb0b0bbbbb000b00bb0000000000000000e7e0e7ee77e00000000000000e7e0000000000000
aaaaaaaaaaaaaaaaaaaaaaaa044444400444444004444440b3bbb3bbbbb3b3bbbb3bb3bb00000000000000e7e000e00ee0000000000000000e7e000000000000
4444444444444444444444440aaaaaa00aaaaaa00aaaaaa00000000000000000000000000000000000000e7e00000000000000000000000000e7e00000000000
999999999999999999999999a4444aaaaa44444aaa4444aa000000000000000000000000000000000000e7e0000000000000000000000000000e7e0000000000
94449949949994999499444994a4aa4a9aaa4a4a9aaa4a4a0000b000003b00000000000000000000000e7e000000000000000000000000000000e7e000000000
94949999999a949a999949499444444a9444444a9444444a0000030003000b000000000000000000000e7e000000000000000000000000000000e7e000000000
94449a9aa9aa949aa9a9494999994a4a94949aaa99494aaa0000003000300030000000000000000000e7e00000000000000000000000000000000e7e00000000
99999aaaaaaa999aaaa944494499444a4444444a4444444a00b00030003000300b0000000000000000e7e000000000000000ee000000000000000e7e00000000
aaaaaaaaaaaaaaaaaaa999999999999999999999999999990300030000030300003000b0000000000e7e000000000000000e99e000000000000000e7e0000000
aaaaaaaaaaaaaaaaaaaaaaaa094499400944994009449940030003000030030000300300000000000e7e000000000000000e99e000000000000000e7e0000000
4494944444944944444444440aaaaaa00aaaaaa00aaaaaa000000000000000000000000000000000e7e0000000000000000e99e0000000000000000e7e000000
944444999449944999999449aa4444aaaa4444aaaa44a4aa00000000000000000000000000000000e7e000000000000000e9999e000000000000000e7e000000
9999999999999999aa9999999aaaaaaa9aaaaaaa9aaaaaaa00000000000b00000000000000000000e7e000000000000000e9999e000000000000000e7e000000
a999999aa999999aaaa999aa94444a4a9444444a9444a44a000000b0000b00000000000000000000e7e000000000000000e9999e000000000000000e7e000000
a99999aaaa9a99aaaaaa9aaa99999aaa99999aaa99999aaa0b0000b0000b00000000000000000000e7e000000000000000e9999e000000000000000e7e000000
aa9a9aaaaaaaa9aaaaaaaaaa9494444a9444444a9444494a0b00b0b00b0b000000b0000000000000e7e00000000000000e999999e00000000000000e7e000000
aa9aaaaaaaaaaaaaaaaaaaaa9999999999999999999999990300b0300b0300b000b000b000000000e7e000ee000000000e999999e000000000ee000e7e000000
aaaaaaaaaaaaaaaaaaaaaaaa09449940094499400944994003003030030300300030003000000000e7e000e9eee000000e999999e000000eee9e000e7e000000
94949494949494949494949409a9a9a009a9a9a009a9a9a000000000000000000000000000000000e7e000e9999ee000e99999999e000ee9999e000e7e000000
44444444444444444444444444999999494949994499499900000000000bb000bb00000000000000e7e000e999999ee0e99999999e0ee999999e000e7e000000
4949494949494949494949494949499a4949494a4949994a0000000000b33b00b3b0000000000000e7e0000e9999999ee99999999ee9999999e0000e7e000000
4a4a9a4a9a4a4a4a4a9a9a4a4a4a4a9a4a4a4a4a4a4a4a4a0000000000b33b000bb000bb000000000e7e000e99999999999999999999999999e000e7e0000000
9a4aaa9aaa9a4a4a4a9aaa9a4a4a4a4a4a4a4a4a4a9a4a4a00000000000bb00000300b3b000000000e7e0000e999999999999999999999999e0000e7e0000000
aa9aaaaaaaaa4a9a4aaaaa9a4a4a4a4a9a9a4a4a4a4a4a9a000000000003000000300bb00000000000e7e000e999999999999999999999999e000e7e00000000
aa9aaaaaaaaa9a9a9aaaaaaa4a4a9a4a4a9a9a9a4a4a9a4a00bbb00000300000030003000000000000e7e000e999eeee9999999999eeee999e000e7e00000000
aaaaaaaaaaaa9aaaaaaaaaaa0444444004444440044444400b3b3bb00bbbb000bbb0bbb000000000000e7e000e99eeee9999999999eeee99e000e7e000000000
444a4a4a444a44a44a444a4404aaaaa004aaaaa004aaaaa000000000000000000000000000000000000e7e000e99eeee9999999999eeee99e000e7e000000000
aa4444a49a444949a49aa49a4944a4aa49a499aa4a449aaa000000000000000000000000000000000000e7e00e99eeee9999999999eeee99e00e7e0000000000
9a4aaa44949aa49449999a4949aa4a4a449a44aa49aa49aa0000000000000000000000000000000000000e7e00e99999999999999999999e00e7e00000000000
94999a4a49999a4a49999949499a494a4a44a49a4999499a000000000000000000b0000000000000000000e7e0e999999eeeeeeee999999e0e7e000000000000
4499994949999949499999494499449a49a4949a4944499a00000000000000000b3b0000000000000000000e7ee999999eeeeeeee999999ee7e0000000000000
a49994a4a49994a4a49994a44a449a4a4994949a449aa44a00bb00000000bb000b3b00000000000000000000e7ee999999ee88ee999999ee7e00000000000000
4a444aaaaa444aaaaa444aaa499a44a9499a4949499994990b33b00000bb33b00b3b00b000000000000000000e7e999999988889999999e7e000000000000000
aaaaaaaaaaaaaaaaaaaaaaaa0444444004444440044444400b33b0b00b33b3b00b3b00b00000000000000000e767ee99999999999999ee767e00000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e77e677eeeeee99eeeeee776e77e0000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000e777e777777777ee777777777e777e000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000e77ee77777222277b77877777ee77e000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000e77ee77777222277b77877777ee77e000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000e7777e77777777777777777777e7777e00000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000e7777e77777777777777777777e7777e00000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000e77ee77777777777777777777ee77e000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee0e77777777777777777777e0ee0000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e6666eeeeeeeeee6666e00000000000000000
00000088880000000990000009900000000a000000000033330000000000c000000002222200000000000000000e7777e00000000e7777e00000000000000000
0000888888880000099000000990000000aaa0000000033333330000000ccc000000022222220000000000000000e77e0000000000e77e000000000000000000
0008880000888000099000000990000000aaa0000000333000330000000ccc0000000220002220000000000000000ee000000000000ee0000000000000000000
008800000000880009900000099000000aaaaa00000033000000000000ccccc00000022000022000000000000000000000000000000000000000000000000000
088800000000888009900000099000000aa0aa00000033000000000000cc0cc00000022000022000000000000000000000000000000000000000000000000000
08800000000008800990000009900000aaa0aaa000000333000000000ccc0ccc0000022000022000000000000000000000000000000000000000000000000000
08800000000008800990000009900000aa000aa000000033330000000cc000cc0000022000222000000000000000000000000000000000000000000000000000
0880000000000880099000000990000aaa000aaa0000000333330000ccc000ccc000022222220000000000000000000000000000000000000000000000000000
0880000000000880099000000990000aa00000aa0000000003333000ccc000ccc000022222200000000000000000000000000000000000000000000000000000
088000088800088009900000099000aaaaaaaaaaa000000000333000ccccccccc000022222000000000000000000000000000000000000000000000000000000
088800008880888009900000099000aaaaaaaaaaa00033000003300ccccccccccc00022022200000000000000000000000000000000000000000000000000000
008800000088880009990000999000aa0000000aa00333000033300cc0000000cc00022002220000000000000000000000000000000000000000000000000000
00088800008880000099900999000aaa0000000aaa003330033300ccc0000000ccc0022000222000000000000000000000000000000000000000000000000000
00008888888888000009999990000aa000000000aa000333333300cc000000000cc0022000022200000000000000000000000000000000000000000000000000
0000008888008880000099990000aaa000000000aaa0003333000ccc000000000ccc022000002220000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030707070101000000000000000003030307070701010100000000000000030303070707010101000000000000000303030707070101010000000000000003030307070701010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000616161610000000000000000000000000000
0000000000000000000000616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070707070707070000000000000000000000000
0000000000000000707070707070700000000000000000000000707070707000000061000000000000000000000000000000000000616161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070707070707070707070707070707000000000000000
0000000000000070707070707070707070000061616100000070707070707070707070707070000000616161000000007070707070707070700000000000000000000000000000000000000000000000000000000000000061000000000000616161610000000070707070707070707070707070707070707070000000610000
7070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070000000000000000000007070707070707070707070707070707070707070707070707070707070707070707070707070707070707070
0000000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000007070707070707070707070000000000000000000000000000000000000000000000000000000000000007070707070000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000707000000070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000070007070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
7070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070707070
__sfx__
000304093b023340233202327023220132b013250132e01321013110130d0130b0130701303013000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
00050000071250f1250f125111250e115061151b10519105171050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
00050000071250f125171250b12510115061151b10519105171050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
000500000712512125061250f125081150c1151b10519105171050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105001050010500105
0005000014555145550e55512555105450e54508535085350a5350552506525075150451505515035050350501505035050350503505005050350502505015050050500505005050050500505005050050500505
000500002c635246351663512335146350e33510625083250e625053250c625073150831505315033050330501305033050330503305003050330502305013050030500305003050030500305003050030500305
000500000f1211d121151210611107111051110010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101
0005000008121101211e121181110e111051110010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101
000500000b12116121091211d11115111051110010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101001010010100101
000200001f0301f0201f0100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001e7301e730257302572025710257100070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000300000a7300a7301d7301d7201d7101d7100070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000300001e7351e73525735257252a7352a7352d7552d755337453374533735337253371500705007050070500705007050070500705007050070500705007050070500705007050070500705007050070500705
00030000130250a025190250e0351e04515045210551b055270551f0552a055230552d04525045200451c0351803515035110250c0250a0250701503015020150000500005000050000500005000050000500005
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018035180351c0351d0321f0321d0321c0351803500002180351c0351d0321f0321d0321c035000021a0351a0351d0351f032210321f0321d0351a035000021a0351d0351f032210321f0321d03500002
011000001803318033180330033518633000030023200003000030033500003180331863300003002320000318033180331803302335186330000302232000030000302335000031803318633022350223218633
011000001d0351d0351f0351d0351c0351c0351d035000051f0351f035210351f0351d0351d0351f035000051d0351d0351f0351d035000051d0351f0351d035000051f035210351f035000051f035210351f035
01100000180331803318633053351863300003052320000318033180331863307335186330000307232000031803318033186331803305335180331863318033072351803318633180330c235180331863318033
011000001c0351c0351c0221c012180351803518022180121d0351d0351d0221d012170351703517022170121f0351f0351f0221f0121c0351c0351c0221c012210352103521022210121a0351a0351a0221a012
011000001803304335180330000018633002351863300003180330533518033000001863302235186330000318033073351803300000186330423518633000031803309335180330000018633022351863300003
0110000018535185351a531185321553015522155121551218535185351a531185321753017522175121751218535185351a535185351c535185351d535185351f53518535215351853223532215321f5321d532
011000001803318033003351803318633000000033500000180331803302335180331863318033023351863318033180330433518033186330000004335000001803318033053351803318633180331803318633
011000001c0351c035000001c012180351803500000000000000000000052350723509235022350723500000110351f035000001f0121c0351c0350000000000000000000005235072350923502235072350c235
011000001803304335180330000018633002351863300003180330533518033000001863309235186330e23518033073351803300000186330423518633000031803309335180330000018633092351863313235
01100000305352f535305352f535305352d5352d5350050029535285352953528535295352653526535005002653528535265352853526535265352853526535295352b535295352b535295352b5352d53530535
01100000180331803300235180331863300235186330000318033180330523518033186330523518633000031803318633000031803318633022351863302235180331863318633180331863318633186330c235
0110000024734287302b730287302b7302f7302b7302f730347303073030732307323073230732307223071200700007000070200702007020070200702007020070200702007020070200702007020070200702
011000001803318033186331803318033186331803318033186330023100232002320023200222002220021200003000030000300003000030000300003000030000300003000030000300003000030000300003
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 14 15 43 44
00 16 17 43 44
00 14 15 43 44
00 1a 1b 43 44
00 14 15 43 44
00 18 19 43 44
00 14 15 43 44
00 1e 1f 43 44
00 1a 1b 43 44
00 18 19 43 44
00 1e 1f 43 44
00 14 15 43 44
00 16 17 43 44
00 18 19 43 44
02 1c 1d 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 20 21 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
