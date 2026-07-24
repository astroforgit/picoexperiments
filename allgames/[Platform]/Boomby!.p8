pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- boomby
-- by picoter8
-- description:
-- - "You are the weapon" and "you are terrifying"ly cute and you're "always exploding".
-- todo:
-- - sfx for destroying blocks and squashing bugs
-- keep the palette in the editor
-- todo: remove once game is finished
poke(0x5f2e,1)

one_frame=1/60

poke(0x5f2c,3)

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

--[[
function mag(x,y)
  local d=max(abs(x),abs(y))
  local n=min(abs(x),abs(y))/d
  return sqrt(n*n+1)*d
end

function normalize(x,y)
  local m=mag(x,y)
  return x/m,y/m,m
end
--]]

function polar_to_xy(r,a)
 return r*cos(a),r*sin(a)
end

function flr_map(x)
 return flr(x/8)*8
end

function mxy(x,y)
 return flr(x/8),flr(y/8)
end

function map_i(x,y)
 return mget(flr(x/8),flr(y/8))
end

function check_solid(x,y)
 return fget(mget(flr(x/8),flr(y/8)),1)
end

function check_map_flag(x,y,f)
 return fget(mget(flr(x/8),flr(y/8)),f)
end

function time_to_text(time)
 local hours,mins,secs,fsecs=flr(time/3600),flr(time/60%60),flr(time%60),flr((time%60)*10)%10
 if(hours<0 or hours>9)return "8:59:59"
 local txt=hours>0 and hours..":" or ""
 txt=txt..((mins>=10 or hours==0) and mins or "0"..mins)
 txt=txt..(secs<10 and ":0"..secs or ":"..secs)--.."."..fsecs
 return txt
end

--enemy_colors={2}
explosion_colors={10,10,9,9,8,8,5,5,5,5}
explosion_colors_lines={10,9,9,9,8,8,5,5,5,5}

smoke_colors={10,10,6,6,5,5}
debris_colors={13,13,4,4,1,1}

red_debris_colors={13,8,8,8,1,1}
blue_debris_colors={13,12,12,12,1,1}
green_debris_colors={13,11,11,11,1,1}

green_goo_colors={15,15,15,11,11,3}

function explode_bug(x,y)
  sfx(1)
  for i=2,6 do
    local vx,vy=polar_to_xy(0.6+rnd(.4),.5-(i-1)/12+.025-rnd(.05))
    make_circle(layer_player_postfx,.6,x,y,vx,vy,.02+rnd(.02),4,0,green_goo_colors)
  end
end

function make_player()

 return
 {
  x=16,
  y=-16,
  vx=0,
  vy=0,
  evx=0,
  flip=false,
  onground=false,
  offground_t=0,
  onwater=false,
  bomb_t=8*15*one_frame,
  music_t=0,
  shake_ground_t=0,

  coin_count=0,

  bouncer_t=0,
  bouncer_x={-1,-1,-1},
  bouncer_y={-1,-1,-1},

  destroys_blocks={[11]=11},

  touchers={},
  
  destroy_aabox=function(p)
    local x1,y1,x2,y2=p:aabox()
    return x1-10,y1-10,x2+10,y2+10
  end,

  aabox=function(p)
    local x1,y1=p.x-6,p.y-10
    local x2,y2=p.x+5,p.y+1
    return x1,y1,x2,y2
  end,

  check_bounds=function(p,ex1,ey1,ex2,ey2)
    local x1,y1,x2,y2=p:aabox()

    if x1>ex2 or
       x2<ex1 or
       y1>ey2 or
       y2<ey1 then
     return false
    end

    return true
  end,

  check_destroy_bounds=function(p,ex1,ey1,ex2,ey2)
    local x1,y1,x2,y2=p:destroy_aabox()

    if x1>ex2 or
       x2<ex1 or
       y1>ey2 or
       y2<ey1 then
     return false
    end

    return true
  end,

  collision_checks=function(p,ddx,ddy)
    local x1,y1,x2,y2=p:aabox()
    x1+=ddx
    y1+=ddy
    x2+=ddx
    y2+=ddy

    -- check map bounds
    if x1>8*128-12 or x2<12 then
     return
    end

    -- world tiles collision checks
    for i=flr_map(x1),flr_map(x2),8 do
      for j=flr_map(y1),flr_map(y2),8 do
        local spri=mget(i/8,j/8)
        if fget(spri,1) then
         return
        end
      end
    end

    --[[ collision checks against touchers]]
    for k,e in pairs(p.touchers) do
      if x1>e.x2 or
         x2<e.x1 or
         y1>e.y2 or
         y2<e.y1 then
      else
       return
      end
    end
    --]]

    p.x+=ddx
    p.y+=ddy
  end,  

  destructible_checks=function(p)
    local x1,y1,x2,y2=p:destroy_aabox()

    -- check destroy bugs
    for k,e in pairs(entities[layer_enemies]) do
      if e.si==88 then
        if p:check_destroy_bounds(e.x,e.y,e.x+7,e.y+6) then
          explode_bug(e.x+4,e.y+4)
          e.l[e.mi]=nil
        end
      end
    end

    -- check destroy blocks
    for i=flr_map(x1),flr_map(x2),8 do
      for j=flr_map(y1),flr_map(y2),8 do
        local mx,my=i/8,j/8
        local spri=mget(mx,my)
        if fget(spri,2) then

         if p.destroys_blocks[spri]!=nil then
          sfx(2)
          mset(mx,my,0)

          local bomb_colors=(spri==12 and red_debris_colors) or 
                            (spri==10 and blue_debris_colors) or 
                            (spri==26 and green_debris_colors) or
                            debris_colors

          for k=1,6 do
            local vx,vy=1-rnd(2),-.5-rnd()
            local x,y=i+4+3-rnd(6),j+4+3-rnd(6)
            make_circle(layer_player_fx,.4+rnd(.4),x,y,vx,vy,.05+rnd(.05),4,0,bomb_colors)
          end          
         end
        end
      end
    end
  end,  

  check_onground=function(p)
   p.onground=check_solid(p.x-4,p.y+3) or check_solid(p.x+3,p.y+3)

   if not p.onground then
    -- didn't find regular floor, check solid creatures
    for k,e in pairs(p.touchers) do
      if p.y+3>=e.y1 then
       p.onground=true
       return
      end
    end
   end
  end,

  update=function(p)
   p.shake_ground_t=max(0,p.shake_ground_t-one_frame)
   p.bomb_t=max(0,p.bomb_t-one_frame)
   p.music_t=max(0,p.music_t-one_frame)
   p.bouncer_t=max(0,p.bouncer_t-one_frame)

   -- check if on ground
   p:check_onground()

   p.onwater=check_map_flag(p.x,p.y,6)

   -- controls
   local cx,cy=0,0
   
   local crouched_onground=p.onground and btn(3)
   if(btn(0) and not crouched_onground) cx-=1
   if(btn(1) and not crouched_onground) cx+=1

   if(btn(0))p.flip=true
   if(btn(1))p.flip=false

   if(btn(2))cy-=1
   if(btn(3))cy+=1

   -- check if on conveyor belt
   local g1,g2=map_i(p.x-6,p.y+3),map_i(p.x+5,p.y+3)
   if g1==114 or g1==115 or g1==116 or
      g2==114 or g2==115 or g2==116 then
    if(p.evx==0)sfx(8)
    p.evx=.4
   elseif g1==117 or g1==118 or g1==119 or
          g2==117 or g2==118 or g2==119 then
    if(p.evx==0)sfx(8)
    p.evx=-.4
   else
    sfx(8,-2)
    p.evx=0
   end

   -- check if on bouncer
   if p.onground then
    local g1,g2,g3=map_i(p.x-6,p.y),map_i(p.x,p.y),map_i(p.x+5,p.y)
    if g1==13 or g1==29 then
      sfx(6)
      p.bouncer_x[1],p.bouncer_y[1]=p.x-6,p.y
      p.bouncer_t=.2
      p.vy=-1.6
    else
     p.bouncer_x[1],p.bouncer_y[1]=-1,-1
    end

    if g2==13 or g2==29 then
      sfx(6)
      p.bouncer_x[2],p.bouncer_y[2]=p.x,p.y
      p.bouncer_t=.2
      p.vy=-1.6
    else
     p.bouncer_x[2],p.bouncer_y[2]=-1,-1
    end
    
    if g3==13 or g3==29 then
      sfx(6)
      p.bouncer_x[3],p.bouncer_y[3]=p.x+5,p.y
      p.bouncer_t=.2
      p.vy=-1.6
    else
     p.bouncer_x[3],p.bouncer_y[3]=-1,-1
    end
   end

   if p.onground then
    if p.offground_t>.1 and p.vy>1.2 then
     sfx(4)
     p.shake_ground_t=.1
    end
   
    p.offground_t=0
   
   else
    p.offground_t+=one_frame
   end

    -- jumping!
    if p.bomb_t<=0 then

     --if stat(24)==-1 then
     if p.music_t<=0 then
      p.music_t=4*8*15*one_frame
      g_current_music+=2
      g_current_music%=8
      music(g_current_music,0,3)
     end

     p.bomb_t=8*15*one_frame

     if not p.onwater then
      sfx(3)
 
      p:destructible_checks()
      p.vy=p.bugged and -.5 or -1.6

      if p.bugged then
        explode_bug(p.x,p.y-4)
      end

      p.bugged=false

      -- jump explosion particles
      for i=2,10 do
        local x,y=p.x+2,p.y

        local vx,vy=polar_to_xy(.5+rnd(.5),.5-(i-1)/20+.01-rnd(.02))
        make_line(layer_player_fx,.5+rnd(.25),p.x,p.y,3*vx,3*vy,4,explosion_colors_lines)

        make_circle(layer_player_fx,.5+rnd(.5),x,y,vx,-1+vy,.04+rnd(.04),8,0,explosion_colors)

        local vx,vy=.3-rnd(.6),-.3-rnd(.3)
        make_circle(layer_player_fx,.5+rnd(.5),x+2-rnd(4),y-4+1-rnd(2),vx,vy,0,8,0,smoke_colors)
      end
    end
   end
   
   if p.vy<2 then
    p.vy+=.065
   else
    p.vy=2
   end

   if p.onground then
    p.vx+=.1*cx
   else
    p.vx+=.05*cx
   end
  
   local maxvx=p.bugged and .1 or .6
   if p.vx>maxvx then
    p.vx-=.5*(p.vx-maxvx)
   elseif p.vx<-maxvx then
    p.vx-=.5*(p.vx+maxvx)
   end
   
   if p.onground then
    p.vx*=.9
   else
    p.vx*=.99
   end
   
   if(abs(p.vx)<.01)p.vx=0
   
   local dx,dy=p.vx+p.evx,p.vy

   --[[ collision checks]]
   while abs(dx)>0 or abs(dy)>0 do
    local ddx=dx>=1 and 1 or dx<=-1 and -1 or dx
    p:collision_checks(ddx,0)
    dx-=ddx
  
    local ddy=dy>=.5 and .5 or dy<=-.5 and -.5 or dy
    p:collision_checks(0,ddy)
    dy-=ddy  
   end
   --]]

   p.touchers={}
  end,

  draw=function(p)

    local c=(p.onwater) and 0 or
            (p.bomb_t<1 and p.bomb_t>.8) and 2 or
            (p.bomb_t<.5 and p.bomb_t>.4) and 2 or
            (p.bomb_t<.3 and p.bomb_t>.2) and 2 or
            (p.bomb_t<.1) and 2 or
            0

    pal(7,c==2 and 8 or 7)
    pal(6,c==2 and 8 or 6)
    pal(5,c==2 and 10 or 5)

    pal(12,7)

   local bounce=not btn(3) and p.bomb_t%.25>.125
   
   local spr_i=(btn(3) and 38) or
               (not p.onground and 34) or 
               (btn(0) or btn(1)) and (bounce and 34 or 36) or
               (bounce and 14 or 32)

   spr(spr_i,p.x-8,p.y-13,2,2,p.flip)               


   local ox=p.flip and -1 or 0
   local ooy=btn(3) and 3 or 0
   local boy=p.onground and ((bounce and -1 or 0) or 0) or 
             (p.vy<0 and -1 or 0)
   local oy=ooy+boy

   local by=p.y+oy-5
   local eye_blink=btn(3) and 0 or p.bomb_t%2<.15 and 0 or 1

   rectfill(p.x-2+ox,by-eye_blink,p.x-1+ox,by+eye_blink,c)
   rectfill(p.x+1+ox,by-eye_blink,p.x+2+ox,by+eye_blink,c)

   --[[draw bugs]]
   if p.bugged then
    spr(t()%.4>.2 and 88 or 89,p.x-4,p.y-8)
   end

   reset_pal()

  --circ(p.x,p.y,1,8)

  --[[ player's aabox
  local x1,y1,x2,y2=p:aabox()
  rect(x1,y1,x2,y2,8)
  --]]

  --[[ map checks
  for i=flr(x1/8)*8,flr(x2/8)*8,8 do
   for j=flr(y1/8)*8,flr(y2/8)*8,8 do
    local spri=mget(i/8,j/8)
    if fget(spri,1) then
     rect(i,j,i+7,j+7,9)
    end
   end
  end
  --]]

  end,
 }
end

function make_camera()
 return
 {
   x=0,
   y=0,
   tx=0,
   ty=0,
   spawned_x=-1,
   spawned_y=-1,

   check_spawn_enemies=function(e)
    if e.spawned_x==flr_map(e.x) and
       e.spawned_y==flr_map(e.y) then
     return
    end

    local sx,sy=flr_map(e.x),flr_map(e.y)
    e.spawned_x,e.spawned_y=sx,sy
    
    for i=sx,sx+127,8 do
     for j=sy,sy+127,8 do
      local mx,my=mxy(i,j)
      local si=mget(mx,my)
      if fget(si,7) then
       make_enemy(layer_enemies,si,i,j)
       mset(mx,my,0)
      end
     end
    end
   end,
   
   update=function(c)
    if p.x+24>c.tx+64 then
     c.tx=p.x+24-64
    elseif p.x-24<c.tx then
     c.tx=p.x-24
    end

    c.tx=mid(0,c.tx,8*128-64)
    
    if abs(c.tx-c.x)>1 then
     c.x+=.1*(c.tx-c.x)
    else
     c.x=c.tx
    end

    local maxy=btn(3) and 40 or 24
    
    if p.y+maxy>c.ty+64 then
     c.ty=p.y+maxy-64
    elseif p.y-24<c.ty then
     c.ty=p.y-24
    end

    c.ty=mid(0,c.ty,4*128-64+6)  --+6 for the rhythm bar
    
    if abs(c.ty-c.y)>1 then
     c.y+=.1*(c.ty-c.y)
    else
     c.y=c.ty
    end
    
    c:check_spawn_enemies()

   end,
 }
end

function make_ui(cam,p)
 return
 {
  cam=cam,
  p=p,
  game_started=false,
  --game_finished=false,
  game_time=0,

  destroy_message_t=0,
  destroy_message_si=-1,

  
  update=function(e)
   e.destroy_message_t=max(0,e.destroy_message_t-one_frame)

   if btn()!=0 then
    e.game_started=true
   end
   
   --[[
   if not e.game_finished then
    e.game_finished=(e.cam.tx==448 and e.cam.ty==192)
   else
    if t()%.1<=one_frame then
     explode_enemy(e.cam.x+rnd(64),e.cam.y+rnd(64))
    end
   end
   --]]

   if e.game_started and not p.onwater then
    e.game_time+=one_frame
   end
  end,
 
  draw=function(e)
   if not p.onwater then
    if(p.bomb_t>1.6)print("boom!",p.x-8,p.y-4+1,0)print("boom!",p.x-8,p.y-4,p.bomb_t%.1>.05 and 8 or 10)
   end

   camera()

   -- draw the timer hud
   local c=p.bomb_t<.2 and 9 or 1
   rectfill(0,58,63,63,c)
   local timer=32*p.bomb_t/2
   rect(32-timer,59,33-timer,62,8)
   rect(32+timer,59,33+timer,62,8)
   pset(8,62,7)
   rect(16,60,16,62,7)
   pset(24,62,7)
   rect(32,60,33,62,7)
   pset(40,62,7)
   rect(48,60,48,62,7)
   pset(56,62,7)
   rect(0,58,63,63,7)

   -- destroy messages
   if e.destroy_message_t>0 and e.destroy_message_t%.4>.1 then
    printb("destroy blocks:",32,8,7,0,align_c)
    rect(27,14,36,23,0)
    spr(e.destroy_message_si,32-4,15)
   end


   -- draw coin count
   spr(86,0,0)
   printb(tostr(p.coin_count),8,1,10,0)

   spr(87,56,0)
   local ft=time_to_text(e.game_time)
   printb(ft,56,1,7,0,align_r)

   if p.onwater then
    local c=t()%.2>.1 and 7 or 10
    local x,y=8,4
    
    printb("you made it!",32,12,c,0,align_c)
   end
  end,
 }
end

function etype_bug()
  return
  {
    init=function(e)
    end,

    update=function(e)
     if p:check_bounds(e.x,e.y,e.x+7,e.y+6) then
      sfx(0)
      p.bugged=true
      e.l[e.mi]=nil
     end
    end,

    draw=function(e)
     spr(e.t%.4>.2 and 88 or 89,e.x,e.y)
    end,
  }
end

function etype_blockdude()
  return
  {
    init=function(e)
     e.flip=false
     e.vx=-.1
    end,

    update=function(e)
     if p:check_bounds(e.x-2,e.y-1,e.x+17,e.y+15) then
      e.vx=0
      e.x1,e.y1,e.x2,e.y2=e.x,e.y,e.x+15,e.y+15
      add(p.touchers,e)
     else
      e.vx=e.flip and .1 or -.1
     end

     if not e.flip and check_solid(e.x-1,e.y+12) then
      e.flip=true
      e.vx=-e.vx
     elseif e.flip and check_solid(e.x+15,e.y+12) then
      e.flip=false
      e.vx=-e.vx
     end

     e.x+=e.vx
    end,

    draw=function(e)
     local spri=(e.vx==0 and 78) or (e.t%.6>.3 and 74) or 76
     spr(spri,e.x,e.y,2,2,e.flip)
    end,
  }
end

local yellow_coin_colors={7,10,10,10,10}
local white_coin_colors={7}
local green_coin_colors={7,15,15,15,15}

function etype_coin(cc)
  return
  {
    init=function(e)
    end,

    update=function(e)
     if p:check_bounds(e.x-1,e.y-1,e.x+7,e.y+7) then
      sfx(5)

      e.l[e.mi]=nil

      p.coin_count+=cc

      -- flash pickup particles
      local colors=(e.si==22 and yellow_coin_colors) or 
                   (e.si==84 and white_coin_colors) or 
                   green_coin_colors

      for i=1,6 do
        local vx,vy=polar_to_xy(.4,i/6)
        make_circle(layer_player_postfx,.6,e.x+4,e.y+4,vx,vy,0,3,0,colors)
      end
     end
    end,

    draw=function(e)
     local s=sin(e.t)
     spr(e.t%.4>.2 and e.si or e.si+1,e.x,e.y+1.5*s)
    end,
  }
end

local red_bomb_colors={7,8,8,8,8}
local blue_bomb_colors={7,12,12,12,12}
local green_bomb_colors={7,11,11,11,11}

function etype_bombpower(block)
  return
  {
    init=function(e)
    end,

    update=function(e)
     if p:check_bounds(e.x-1,e.y-1,e.x+7,e.y+7) then
      e.l[e.mi]=nil

      sfx(7)

      -- destroy color blocks ui message
      ui.destroy_message_t=5
      ui.destroy_message_si=(e.si==27 and 12) or
                            (e.si==60 and 10) or
                            26

      -- flash pickup particles
      local colors=(e.si==27 and red_bomb_colors) or 
                   (e.si==60 and blue_bomb_colors) or 
                   green_bomb_colors

      for i=1,12 do
        local vx,vy=polar_to_xy(.6,i/12)
        make_circle(layer_player_postfx,1.4,e.x+4,e.y+4,vx,vy,0,5,0,colors)
      end

      p.destroys_blocks[block]=block
     end
    end,

    draw=function(e)
     local s=sin(e.t)
     spr(e.t%.4>.2 and e.si or e.si+1,e.x,e.y+1.5*s)
    end,
  }
end

enemy_types=
{
  [22]=etype_coin(1), -- yellow coin
  [27]=etype_bombpower(12), -- red bomb
  [60]=etype_bombpower(10), -- blue bomb
  [62]=etype_bombpower(26), -- green bomb
  [74]=etype_blockdude(),
  [84]=etype_coin(5), -- platinum coin
  [88]=etype_bug(),
  [106]=etype_coin(20), -- green coin
}

function make_enemy(el,si,x,y)
 
 local mx,my=mxy(x,y)
 local mi=my*128+mx
 
 local l=entities[el]
 
 if(l[mi])return
 
 local e=
 {
  l=l,
  et=enemy_types[si],
  mi=mi,
  si=si,
  t=x/64+y/32,
  x=x,
  y=y,
  
  update=function(e)
   e.t+=one_frame
   if(e.et and e.et.update)e.et.update(e)
  end,
 
  draw=function(e)
   if(e.et and e.et.draw)e.et.draw(e)
  end,
 }
 
 if(e.et and e.et.init)e.et.init(e)
 
 l[mi]=e
 
 return e
end

function make_circle(el,t,x,y,vx,vy,g,s1,s2,colors)
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
  s1=s1,
  s2=s2,
  sc=s1,
  l=l,
  colors=colors,
  
  update=function(e)
  
   e.t-=one_frame
   if e.t<=0 then
    del(e.l,e)
   else
    e.sc+=one_frame*(e.s2-e.s1)/e.tt
    e.x+=e.vx
    e.y+=e.vy
    e.vy+=e.g
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
  
   e.t-=one_frame
   if e.t<=0 then
    del(e.l,e)
   else
    e.x+=e.vx
    e.y+=e.vy
   end
  end,
 
  draw=function(e)
   local ci=flr(1+#e.colors*(1-e.t/e.tt))
   local ci2=min(#e.colors,flr(2+#e.colors*(1-e.t/e.tt)))
   line(e.x,e.y,e.x+2*e.s*e.vx,e.y+2*e.s*e.vy,e.colors[ci2])
   line(e.x,e.y,e.x+e.s*e.vx,e.y+e.s*e.vy,e.colors[ci])
  end,
 }
 
 add(l,e)
 
 return e
end

function make_gimmicks()
 return 
 {
  update=function(e)
  end,
  
  draw=function(e)
    local x1,y1,x2,y2=cam.x,cam.y,cam.x+63,cam.y+63

    for i=flr_map(x1),flr_map(x2),8 do
      for j=flr_map(y1),flr_map(y2),8 do
        local spri=mget(i/8,j/8)

        if spri==13 or spri==29 then
         -- bouncers
         if p.bouncer_t>0 then
          local found=false
          for k=1,3 do
            if flr_map(p.bouncer_x[k])==i and flr_map(p.bouncer_y[k])==j then
              found=true
              spr(13,i,j)
            end
          end

          if not found then
           spr(29,i,j)
          end
         else
          spr(29,i,j)
         end
        elseif spri==114 or spri==115 or spri==116 or
               spri==117 or spri==118 or spri==119 then
         -- conveyor belts
         local ti=one_frame/.1
         local ti4=ti*.25
         local tv=t()%ti
         pal(7,tv>3*ti4 and 7 or tv>2*ti4 and 0 or tv>ti4 and 5 or 6)
         pal(6,tv>3*ti4 and 6 or tv>2*ti4 and 7 or tv>ti4 and 0 or 5)
         pal(5,tv>3*ti4 and 5 or tv>2*ti4 and 6 or tv>ti4 and 7 or 0)
         pal(14,tv>3*ti4 and 0 or tv>2*ti4 and 5 or tv>ti4 and 6 or 7)
         spr(spri,i,j)
         reset_pal()
        end
      end
    end

    
  end,
 }
end

layer_gimmicks,layer_player_fx,layer_enemies,layer_player,layer_player_postfx,layer_camera,layer_ui=1,2,3,4,5,6,7

entities={}

entities[layer_gimmicks]={}
entities[layer_player_fx]={}
entities[layer_player]={}
entities[layer_player_postfx]={}
entities[layer_enemies]={}
entities[layer_camera]={}
entities[layer_ui]={}

function _init()
 g_current_music=0

 p=make_player()
 add(entities[layer_player],p)
 
 cam=make_camera()
 add(entities[layer_camera],cam)

 gimmicks=make_gimmicks()
 add(entities[layer_gimmicks],gimmicks)
 
 ui=make_ui(cam,p)
 add(entities[layer_ui],ui)
end

function _update60()
 one_frame=1/stat(8)

 for i=1,#entities do 
  for k,v in pairs(entities[i]) do
   if(v.update)v.update(v)
  end
 end
 
 --[[debug teleport
 if btnp(0,1) then
  if(p.x>=64)p.x-=64
 elseif btnp(1,1) then
  if(p.x<64*15)p.x+=64
 end
 
 if btnp(2,1) then
  if(p.y>=64)p.y-=64
 elseif btnp(3,1) then
  if(p.y<64*7)p.y+=64
 end 
 --]]
end

--
function reset_pal()
 pal()
 pal(14,0)
 pal(15,0xfa,1)
 pal(13,0xf9,1)
end

function _draw()
 cls()

 reset_pal()
 
 camera()

 -- draw background bricks
 for i=0,64,8 do
  for j=0,64,8 do
   spr(1,i,j)
  end
 end
 
 local camx,camy=cam.x,cam.y
 if(p.shake_ground_t>0)camx+=1-rnd(2) camy+=1-rnd(2)

 camera(camx,camy)
 reset_pal()
 
 map(0,0,0,0,128,64,0x01)

 -- title drawing
 local oy=mid(0,t()*t(),.5)*54*2-54
 line(25,oy,25,oy+10,7)
 line(40,oy,40,oy+10,7)
 rect(18,oy+10,47,oy+18,7)
 rectfill(19,oy+11,46,oy+17,0)
 print("boomby!",20,oy+12,7)

 rectfill(5,-oy+47,57,-oy+53,0)
 print("picoter8 2020",6,-oy+48,7)

 for i=1,#entities do 
  for k,v in pairs(entities[i]) do
   if(v.draw)v.draw(v)
  end
 end
 
 camera()
 
 --print("mem:"..stat(0),0,0,7)
 --print("cpu:"..stat(1),0,6,7)

end
__gfx__
eeeeeeee10115001b3b3b3b3b499a44d9499a44d9499a443b3b3b3b003b3b3b3b499a44d9499a4439c99ac4d9099a04d9499a48d2888888200000ccc00000000
eeeeeeee000000004444444434444444444444444444444b4444444b34444444344444444444444b44c444c44404440448448844288888820000ceeec0000000
eeeeeeee11150150999a49a4b49a49a4999a49a4999a4a43999a4a43b49a49a4b49a49a4999a4a43999ac9a4999a09a4999a49a8000050000000ce7eec000000
eeeeeeee011101104dd94d9434d94d944dd94d944dd9494b4dd9494b34d94d9434d94d944dd9494b4dd94d9c4dd94d908dd98d9400060000000ccee7eecc0000
eeeeeeee0000001044444494b4444494444444944444444344444443b4444494b444449444444443c44c449404404494484848980000700000ceee555eeec000
eeeeeeee001150004499a4443499a4444499a4444499a44b44999a4b3499a4443499a4444499a44b4c99a4c44099a4044899a484000600000cee5667777eec00
eeeeeeee50011011a44d9499b44d949944444444a44d9443a44dd943b44d9499b444444444444443a4cd9499a40d9499a84d9899000070000ce566777777ec00
eeeeeeee100000019444444d3444444d3b3b3b3b9444444b9444444b3444444d0b3b3b3b3b3b3b3094c44c4d9404404d9484884d005675000ce566777777ec00
00000000000000009499a44d03b3b3b3b3b3b3b0b3b3b3b30eeeeee00eeeeee000000000000000009b99ab4d0000000000000000000000000ce566777777ec00
000000000000000044444444344444444444444b44444444eeaaadeeee7779ee00000000000000004b444b4b0eeeeeee0eeeeeee000000000ce566777777ec00
0000000000f0f000999a49a4b49a49a4999a4a43999a49a4ead99adee79aa79e0000000000000000999a49abeea8567eee88567e000000000cee5667777eec00
00000000000b00004dd94d9434d94d944dd9494b4dd94d94eadadadee797979e00000000000000004dd9bd94ea7a85e7e87885e70000000000ceeeeeeeeec000
00f00f00000b0f0044444494b44444944444444344444494eadadadee797979e0000000000000000b444b49be8a888eee88888ee0000000000ceeeeceeeec000
000bb0000000b00f4499a4443499a44444999a4b4499a444ead99adee79aa79e0000000000000000b499ab4be88888e0e88888e00000000000ce56ece66ec000
0f00b00f0000b0b0a44d9499b44444444444444344444444eeaaadeeee7779ee0000000000000000a4bd9b99ee888ee0ee888ee02888888200ceeeeceeeec000
00303030003b3b309444444d0b3b3b3b3b3b3b303b3b3b3b0eeeeee00eeeeee0000000000000000094b4444d0eeeee000eeeee0000567500000cccc0cccc0000
000000000000000000000ccc00000000000000000000000000000000000000004d4d4d4dd3fbafbdd33db3b333db3b54d4d4d4d00d4d4d4dd3fbafbdd33dbb3d
00000ccc000000000000ceeec000000000000ccc0000000000000000000000005353535345bbbb33b33bfda3ba33bf3d3535353dd353535345bbbb33b33bff54
0000ceeec00000000000ce7eec0000000000ceeec00000000000000000000000bfbfbfbfd3ffbd33fbdbb33d3d3bbb54bfbfbb5445bfbfbfd3ffbd33fbdbbb3d
0000ce7eec000000000ccee7eecc00000000ce7eec00000000000ccc00000000bbbfbfbb45bbbbbdabbbbb3bbfbbff34bfbbff3dd3bfbfbb45bbbbbdabbbbf54
000ccee7eecc000000ceee555eeec000000ccee7eecc00000000ceeec0000000b3bbbbbad3ffbbfbbbfbfbbbdbbbbb54dbbbbb5445fbbbbad3ffbbfbbbfbfb3d
00ceee555eeec0000cee5667777eec0000ceee555eeec0000000ce7eec000000d33bbdbf45bbb3d3fbfbfbfb33ddff3d33dbff3dd3bbbdbf45bbfbfbfbfbfb54
0cee5667777eec000ce566777777ec000cee5667777eec00000ccee7eecc00003adfb33bd3fb33ab3535353533bfbb5433bbbb5445ffb33bd35353533535353d
0ce566777777ec000ce566777777ec000ce566777777ec0000ceee555eeec0003b3bd33d45bbbd33d4d4d4d4dbfabf3ddbfabf3dd3bbd33d0d4d4d4dd4d4d4d0
0ce566777777ec000ce566777777ec000ce566777777ec000cee5667777eec00d33ddaa30d4d4d4dd4d4d4d04d4d4d4d00000000000000000000000000000000
0ce566777777ec00cee566777777eec00ce566777777ec000ce566777777ec00fad3bfd3d35353533535353d535353530eeeeeee0eeeeeee0eeeeeee0eeeeeee
0ce566777777ec00ce5e5667777e6ec00ce566777777ec000ce566777777ec00bfa3b33d45bfbfbfbfbfbb54fbfbbffbeeac567eeecc567eeeab567eeebb567e
0cee5667777eec00cee6eeeeeee6eec00cee5667777eec000ce566777777ec003bfd33add3bfbfbbbfbbff3dabbbbbabea7ac5e7ec7cc5e7ea7ab5e7eb7bb5e7
00ceeeeeeeeec0000ceeeccccceeec0000ceeeeeeeeec0000ce566777777ec00d3bd3dfa45fbbbbafbbbbb54bbfbfbbbecaccceeeccccceeebabbbeeebbbbbee
00ce56ece66ec00000ccc00000ccc000000ce56e66ec00000cee5667777eec00d333adbfd3bbbfbfbbfbff3dfbfbfbfbeccccce0eccccce0ebbbbbe0ebbbbbe0
00ceeeeceeeec0000000000000000000000ceeeeeeec000000ceeeeeeeeec0003adfb33b453535355353535435353535eecccee0eecccee0eebbbee0eebbbee0
000cccc0cccc000000000000000000000000ccccccc00000000ccccccccc00003b3bd33d04d4d4d44d4d4d40d4d4d4d40eeeee000eeeee000eeeee000eeeee00
76767676745544445455444454554446767676000076767674554444545544460000000000000000000000000000000000000000000000000000000000000000
444444446444467444444674444447474444447006444444644446744444474707777650000000000eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeeeeeeeeeeee0
66674674746745646667456466674546666744467444467474674564666745460707065007777650ee777777777665eeee777777777665eeee777777777665ee
66674454646744546667445466674447666744476467445464674454666744470077650007070650e77777777777665ee77777777777665ee77777777777665e
55667444746674445566744455667446556674467466744474467444556674460000000000776500e77eee7eee77665ee77eee7eee77665ee77777777777665e
44555467645554674455546744555447445554476455546764455467445554470000000000000000e77eee7eee77665ee77eee7eee77665ee77777777777665e
74444466744444664444444474444446744444467444446607444444444444600770055000775500e77eee7eee77665ee77eee7eee77665ee77eee7eee77665e
64674455646744556767676764674447646744476467445500676767676767000000000000000000e77eee7eee77665ee77eee7eee77665ee777777eee77665e
545544440076767676767600767676760eeeeee00eeeeee00eeeeee00eeeeee0eeeeeeee0eeeeee0e77eee7eee77665ee77eee7eee77665ee77777777777665e
44444674064444444444447044444444ee7775eeee7776eeeeaaadeeee7775eee3effe3e0e3ee3e0e77777777777665ee77777777777665ee77777777777665e
66674564744446746667444666674674e756675ee767776eead99adee76e675eeef88beeeeeffeeeee777777777665eeee777777777665eeee777777777665ee
66674454646744546667444766674454e757575ee767676eeadadadee767e75ee3fbbb3eeef88bee0ee5555555555ee00ee5555555555ee00ee5555555555ee0
55667444745674445566744655667444e757575ee767676eead99adee766675eeeebbeeee3fbbb3eee66eeeeeeee66ee00ee66eeee66ee00ee66eeeeeeee66ee
44555467644554674455544744555467e756675ee767776eeeaaadeeee7775ee0e5ee5e0e5ebbe5ee7765e0000e7765e00e7765ee7765e00e7765e0000e7765e
74444466074444444444446044444444ee7775eeee7776ee0eeeeee00eeeeee00eeeeee0eeeeeeeee7765e0000e7765e00e7765ee7765e00e7765e0000e7765e
646744550067676767676700676767670eeeeee00eeeeee000000000000000000000000000000000eeeeee0000eeeeee00eeeeeeeeeeee00eeeeee0000eeeeee
007676007455444674554446007676007777777777777777700000000d4d4d4000077777777700000eeeeee00eeeeee000000000000000000000000000000000
06444470644447476444474706444470000000077000000070600000d35353540071111111117000eefff3eeee7773ee00000000000000000677760006777600
7444464674674546746745467467444606066607706006607060000045bfbf3d0711a77766511700ef3bbf3ee73bb73e000000000000000077c7c77777c7c777
64674447646744476467444764674447000606077060000070000000d3bfbf54071acc7cc6651700ef3f3f3ee737373e00000000000000007ccccc7c7ccccc7c
7456744674667446746674467466744600066607700000507000000045fbbb3d071acc7cc6651700ef3f3f3ee737373e0000000000000000cccccccccccc7ccc
64455447645554476455544764555447000000077000500070660060d3bbbf54071acc7cc6651700ef3bbf3ee73bb73e0000000000000000c7cccccccccccccc
074444607444444607444460744444460005060770600000700000004535353d071a777776651700eefff3eeee7773ee0000000000000000cccccccccccccccc
0067670064674447006767006467444700000007700000007777777704d4d4d00711a777665117000eeeeee00eeeeee00000000000000000cccccccccccccccc
03b3b3b0b499a443007e567e567e567e567e56000065e765e765e765e765e700711111665111117000000067000000076000000000000000cccccccccccccccc
3444444b3444444b06111111111111111111117007111111111111111111116071a717766516517000000056770007765000000000000000cccccc7ccccccccc
b49a4a43b49a4a4351122222222222222222211ee1122222222222222222211571a717766516517000000005677777650000000000000000cccccccccc7ccccc
34d94d4b34d94d4be1228888888888888888221551228888888888888888221e711111111111117000000000576767500000000000000000ccccccccccccc7cc
b4444443b44444437112222222222222222221166112222222222222222221170771a7171651770000000000076767000000000000000000cccc7ccccccccccc
3499a44b3499a44b0611111111111111111111700711111111111111111111600071a7171651700000000000577777500000000000000000ccccccccc7cccccc
b4444443b44d944300765e765e765e765e765e0000e567e567e567e567e56700007111171111700000000005776767750000000000000000cccccccccccccccc
0b3b3b303444444b000000000000000000000000000000000000000000000000000777707777000000000577676767677500000000000000cccccccccccccccc
000061610000000000000000a4b492b2000000000000a4b417000000000000000000000000000000616192b20000000093a30000000092b20534000000000000
00000000000000000000000000000014340000000000a5b500001434000000000000000000000000000000000000000000000000000000000000000000000000
0000d2c20011010000010000a5b592b2000001110100a5b517d1d1d10000000000000000000000006161e2f20000000000000000000092b20534000000000000
00000000000000000000000000000014340404040404040404040404044400000000000000454500000000454500000000000000008585153525000000001504
00009283828282828282828282828383828282828282828282b3b3a3000000000000000000000000d2c26161000000000000000093a392b20534000000000000
00000000000000000000858500000014342424242424242424242424247400000000000000454500000000454500000000000000008585153525616100000014
0000e2a2a2a2a2a2a2a2a2a2a2a2a2a28383838383838383b2006161000000000000000000000000e2f261610000000001000000616192b20534000000000000
00000000000000858500858500000014346161000000616100000000540404440000000000000000000000000000000000008515353535353525616100000064
00000000000000000000000000006161e2a2a2a2a2a2a2a2f200616100000057676767770000d2c2b3b3b3a30000000093a30000616192b20534000000000000
00000000000000858500000000000014346161000000616100000000642424340000000000000000000000000000000000001535353535353525000000000000
0000000000000000616100000000616100000000616100000000000000000000000000000000e2f2a30000000000000000000000616192b20534000000000000
00000000000000000000000000000014340000000000544400000000006161540444000000000000a4b400000000008515353525000000a6a616042500000000
000000000000000061610000000000000000000061610000000000000000000000000000d1d17600000000000000000000000000000092b20534000000000000
00000000000000000000000054040405748585000000647400000000006161642405044400000000a5b500000000153535250000000000a6a616340000006161
37373737374700000000000000000000000000000000000000000000d1d1d100000000d2c2b3a3000000000011d1d10000000000000092b20534000000000000
00000000000000000000540405050574008585000054440000d1d1d1000000000064242435353535353535353535352500000000000000000016740000006161
6161000000000000000000002737373737374700000000576767677793b3a300000000e2f200000000000093b3b3b3b3a3000000000092b20534000000008585
85000000000000000000140505057400000000000064740000153525000000000000000000000000006161610000000000000000000000000016000000000000
616100000000000000000000000061610000000000000000000000000000006161d2c2f200000000000000000000000000000000000092b22474000000000000
00b0b0b0000000000000140505740000000000005444000000000000000000000000000000000000006161610000000000000000003600000016000000001504
000000000000002737373737374761610000000061610000000000000000006161e2f20000000000000000000000000000000000000092b20000b0b000000000
00b0b0b0000085855404050574000000000000006474000000000000d1d1d100000000616100000000d1d1d10000000000000000001600000016000000000014
00000000000000000000616100000000000000006161000000000000006161d2c2000000000011d1d100000000000000000000d1d10192b20000b0b000000000
54040444858585851405057400000085856161544400000000000000153525000000006161000000001535250000000000000015351600000016000000000064
37373737470000000000616100000000000000000000000000000000006161e2f2000000000093b3a30000000000000000000093b3a392b20000b0b000000000
14050534858554040505740000000085856161647400000061610000616100000000000000000000000000000000000000000000001600000016000000000000
b20000000000000000000000000000000027373737374757676767677793d2c20000000000000000000000000000000000000000000092b20000001535353535
242424243504052424740000000000000000005444000000616100006161000000d1d100000000a4b40000000000d1d100000000001600000026000000000000
b20027373737373747000000000000000000000000000000006161616161e2f20000000000000000000000576777273747000000000092b20000006161616161
616161b0b014340000000000000000000000006474000000000000000000000000152561615444a5b50000000000544400616161001600000000000000000000
b2000000616100000000002737374700000000000000000000616161616176000000000000000000000000006161616100000000000092b20000006161616161
616161b0b01434000000000000616100000000544400000000000000000000000000006161143435353535353535143400616161001661616100000000000000
b20000006161000000010000000000000000010100000100006161616161760000000000000000000000000061616161000000000000e2f23535353535353535
35352500001434616161000000616100000000647400000000a4b400000000000000000000647400006161610000647400000000001661616100000000006161
b200000093b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3a300000000000000000100d1d1006161616100d1d1000000a0a00000006161616161
616161b0b01434616161000000000085850054440000000600a5b500000000060000000000000000006161610000454500000000006435353535250000006161
b20000009283b20061616100000000000000000000000000000000000000000000001100000093b3b3b3b3b3b3b3b3b3b3b3b3a30000a0a00000006161616161
616161b0b01434616161000000000085850064740000001535353535353535250000000000000000000000000000000000000000000000454516000000000000
b20000009283b261a6a6a66100000000000000a1a10000a1a1a1a1a1a1a1a100000093b3b3b3b3a30000000000000000000000000000d2c2a1a1a1a115353535
3535353535243461616100000000005444544400000000000000000000000000000000d1d1d10000000000000000000000000000000000454516000000001504
b20000009283b2006161610000000000000000a1a10000a1a1a1a18585a1a193b3b3b3a300000000000000000000000000004500004592b2a1a1a1a100000000
00000000000064353525b0b0b0544464746474000061610000000000000000000000001535250000000000000000000000000015353535353516000000000014
b20000009283b2000000000001011100000000a1a10000a1a1a1a18585a1a1000000000000000000000000000000000000000000000092b25444616100000000
00000000000000000000b0b0b0647400a1a0c000006161000000000000544400005444000000000000d1d1d1000000000000000000a600006416616100000064
b200000093b3b3b3b3b3b3b3b3b3b3b3a3b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000a1a1a1a1a1a1a1a1a1a100000000000092b26474544400000000
00000000000000000000000054440000a1a0c00000000000000000000064740000647400000000000015352500000000000000000000a6000016616100000000
b200000000000000000000000000000000000000000000b0b0b0b0b0b0d1d100000000000000a1a1a1a11525a1a1152500000000000092b20000143461610000
0000000000000000000061611434a6a6a1a0c0000000000000d1d100000000616100000000616100000000000000000000000000000000a60016000000000000
b200000000000000000000000000000000000000000000b0b085851535352554440000000000a1a1a1a1a1a1a1a1a1a1000000000000e2f20000143454440000
000000a6a6000000000054441434a6a6a1a0c0000000000000544400000000616100000000616100000000000000d1d1d1000000000000000016042500000000
b20000000000000000000000000000000000000000d1d1b0b08585b0b0b0b01434000000d1d1a1a16161a1a16161a1a1000000000000a1a1a6a6143414346161
000000a6a6000000616114341434a6a6a65444000000000000647400000000000000000000000000000000000000153525000000000000000016340000000000
b200000000000000000000000000000000000000005444b0b0b0b0b0b0b0b014340000001525a1a16161a1a16161a1a1000000000000a1a1a6a6143414345444
0000000000000000544414341434a6a6a6647400000000000000000000544400005444000000000000d1d1d10000000000000000000000000016740000006161
b200000000000000000000008585000000544485851434b0b0b0b0616161611434d100000000a1a16161a1a16161a1a1000000000000d2c2a6a6143414341434
6161000000006161143414341434a6a6a654440000d1d10000000000006474000064740000000000001535250000000000000000000000000026000000006161
b200000000005444000000000000000000647400001434b08585b0b0b0b0b064742500000000a1a10000a1a10000a1a100000000000092b2a6a6143414341434
544400000000544414341434143400d1d16474616154440000000000000000858500000000d1d1d1000000000000000000d1d1d1d10000000000000000000000
b20000000000143400000000a4b4000000000000001434b08585b0b0b0000000000000000000a1a10000a1a10000a1a1000000e3000092b2a6a6143414341434
1434f6f6e6e6143414341434143400544454446161647400005444008585008585000061611535250000000061616100005404044400000000000000a4b45404
b20011d1d100143400000100a5b5000011010000001434b0b0b0b0b0b00001000000d1d10100a1a1d1d1a1a1d1d1a1a10011a7b7c71192b2d1d1143414341434
1434f7e7e7f714341434143414340064746474d1d1000000006474008585000000000061610000000000000061616100001405053400000000000000a5b51405
82828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828282828292b20404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
__gff__
0001030303030303030307070700000001010303030380800000078000000000000000000000000003030303030303030000000000000000030303038000800003030303030303038000800000008000030303038080808080000000000000000303030303030303000080800000414103030303030303030000010101004141
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000161600001616000000000000000000001616160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003121212121212121212121205000000000000000000000000000000000000000000
0000000000000000000016160000000000000000000000000000000000161600001616000000000000000000001616160000000000000000000000000000000000000000000000000000000000001616000000000000000000000000000003120404040404040404040405000000000000000000000000000000000000000000
0000000000000000000016160000000000000000000000000000000000000000000000000000000000000000000000001000000007020206000000000000000000000000000000000000000000001616000000000000000000000000001603050000000000000000000071161616160000000000000000001616000000000000
000000000000000000000000000016160000000000000000000000000007060000000000000000000000000702020202020616160312120500000000000000070206000000000000000000000000000000000000000011000000000000160305000054546a6a5454000071166a6a160000000000000000001616000000000000
001000110000111000000000001016161100161616000000111000000003050000100000000000100000000312121212120516160312120500001000000000031205000000000000000000000010000011000000000702020214000000000305000054546a6a5454000071166a6a160000000000000000001616000000000000
0202020202020202020202020202020202061616160702020202020202020202020202020202020202020202121204041202020202121202020202060016160312050000070600003c00000702020202020658585803121212160000000003051100545454545454001071161616160000100000000000001616000000000000
12121212121212120202121212121212120202020202121212121212020212121212121204040412121204041212121212121212120404041212120500161603120516160305107a7b7c110312121212120558585803121212160000001303051514545454545454131512020202020202140000161600000706000016000000
1212121212121212121212120212040412121212121212121212040404040404040404040404040404040404040404040404040404041212121212050000000312051616070202020202021212121212121202020212121212000000000008090000545454545454000003121212121209000000161600000305000016000000
120404040404040404040404040916160804040404040404040900000000000000000000000000000000000000000000000000000000031212040405000000031205000008040404040404040404040404040404040404040414000000001a1a000054545454545400000312121212090000000000000000030500001d000000
050000000000000000000000000016160000000000000b0b0000001616000000000000000000000000000000000000000000000000000804040404090000000312050000000000000000161600000000161600000c0c00000000000000001a1a00101d1d1d1d1d1d0011031212120900000000001d1d00000305000070000000
05000000000000000000001000000b0b0000000000000b0b0000001616000000000000000000000000161600000000161600000000000000000000000000000804090000000000000000161600000000161600000c0c000000000000070202020202020202020202020212121209000016160000131400000305160000000000
05000000001616161607020202060b0b0000000000110b0b0000110000000000000000000000000000161600000000161600000016160000000000000016160c0c000000001000000000000000000000000000000c0c000000000011031212121212040404040404040404040900000016160000000000000305160000000000
05001b00001616161603121212050b0b0b0b0b0b070202020202020202060000000000000000000000000000001100000000000016160000000010000016160c0c00000000070215140b0b0b0b0b0b0b0b0b0b0b07020206161607021212120404090000000000000000000000000000000000000000000003051d0000000000
057a7b7c1000000000030202121202060b0b0b0b0312120212121212120500000000001315151515140b0b131515140b0b131515151400000007020202020202020610000003050b0b0b0b0b0b0b0b0b0b0b0b0b031212051616080404040900000000000000000000000000000000001d1d0000000000000305140000000000
12020202060c0c0c0c03121202021212020616160312121212120202120415140000000000000000000000000000000000000000000000000008040404040404041202020212050b0b0b0b0b0b0b0b0b0b0b0b0b0312120500000000000000000000000000000000000000001616000013140000000000000305000000001600
12121212050c0c0c0c080404040404040409161608040404040404040900000000001100000000000000161600000000000000001616000000001a1a00000000000312121212050b0b0b0b0b0b0b0b0b0b0b0b0b031212051d1d0000000000000000000000000000000000001616000000000000000000000305000000001600
121212121202060000000000000000000000000000000000000000000000000000001314000000000000161600000011001100001616000011001a1a00000000000312040412050b0b0b0b0b0b0b0b0b0b0b0b0b031212120202020600000000004a4b0000000000000000000000000000000000000000000305000000001d00
12121212121205001000000000000000000000000000000000000000000000000000000000000011000013151515151515151515151502020202020600100000000312121212050b0b0b0b0b0b0b0b0b0b0b0b0b031212121212120500001000005a5b0000001170000000001d1d000000000000000000000305000000007000
1212121212121202060000000000000707060a0a07020202020202060000000000000000000013140000000000000000000000000a0a0804040404041514000000031212121212020616161616161616161616160804040404040404151515151515151515151514000000001314000016160000161600000305001600000000
0404040404040412050000000000000712050a0a03120202120404090000000000001000000000000000000000001616000000000a0a0000000000000000000000031212121212120516161616161616161616160000000000000000000000000000000000000000000000000000000016160000161600000305001600000000
000000000000000812020616160707121205000003121212051616000000000000001314000000000000000000001616000011000a0a0010000000000000001d1d031212120202120516161616161616161616160000000000000000000000000000000000000000000000000000000000000000000000000305001d00000000
0000161616000000081205161607120212050000030404040516160000000010000000000000000000000a0a000000000000070202020202060000000000001315040404040412120516161616161616161616160010000016000016100016000016000016000000001d1d1d0000000010000011001000000309007000000000
0016000000160000000804151504040404090000000000007100000000001314000000000000000016160a0a000000000000031212120202050010000000000000000000000008040415151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515150900000000001616
0016001600160000000000000000161600000000000000007100000000000000000000001000000016160a0a00101d1d00000312020404040415151514000000000000000000000000000a0a00000000000000000000000000004143000000000000000000000000000000000000000000000000000000000000000000001616
001600000016000000000000000016160000000000000000710c0c07020202020202020202020202020202020202020202021204090000000000000000000000000000000000000000000a0a0000000000000000000000000000414300000000000000000000000000000000000000000000000000000000000000001d1d4540
000016161600000000001100100016160000001100000000710c0c0804040404040404040404040404040404040404040404091a1a0000000000000000004a4b000000000000000000000a0a00000000000000000000000000004143000000000000000000000000000000565656565656000000000000000000004540404040
001d1d1d1d1d00102d28282828282828282828282c0016167116160000000000000000000000000000001616161600000000001a1a0000000000454400005a5b00454400004a4b000000454040404040404040404040440000004143000000005656000000000000000000565656565656000000000000454040404040405050
2828282828282828382a2a2a2a2a2a2a2a2a2a2a2f0016167116160000000000000000000000000000001616161600000000001a1a001045404040404040404040404044005a5b000000415042424242424242424242470000004143000000565656000000000000000000000000000000000000000000415050505050505050
38383838383838382b1616000000000000001616000000007172737373737373737400000000000000002d2c161600000000393b3b3b2d2c505050505050505050505050404040404040504300000000000000585800000000004143000056565600000000000000000000000000585800000045404040404040505050505050
3838383838382a2a2f161600000000000000161600000000711616161600000000000000000000000000292b16160000393b3a000000292b505050505050505050505050505050505050504300000000000000585800000000004143005656560000000000005858000000454040404040404040404242424242424242424242
2a2a2a2a2a2f161600000000000000100000000000000000711616161600000000000000757676767677292b16160000000016161616292b505050505050505050505050505050505050504300000000000000000000000000004143005656000000454040404040404040404040504242424242470000000000000000001616
00001616000016160000000000002d2c000000000000000071161616160000393b3b3b3a00000000161629383b3a0000001016161616292b4242424242424242424242424242424242424247000000454400000000004a4b00004143000000000000464242424242424242424242470000000000000000000000000000001616
__sfx__
010500000823319233262540e2521c232172320e2220521214203132030f2030c2030720301203002030b2030e203092030b20308203092030720305203022030120300203002030020300203002030020300203
010500001d2531d2531d253192531d2431725216232162521422213222122220e21208212042120e2030b20308203052030320303203002030020300203002030020300203002030020300203002030020300203
000a000028643244331f43317433154230f6230c623096230561303613054030540302403044030e4030b40308403054030340303403004030040300403004030040300403004030040300403004030040300403
00050000393532264410445266430a7431f64509733166340973313635097330e6240772511613076140671305615007130560400603006030060300603006030060300603006030060300603006030060300603
000200000732105321063110331102311003110530105301043010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301003010030100301
0006000005540115401b54018540135200c5200551000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00040000065750a5750d5751056513565175551655521505215052550523505225051e50500505005050050500505005050050500505005050050500505005050050500505005050050500505005050050500505
0008000006560085600b5600d56010550125501455016540195401b5301d5302152022510225200f5002550000500005000050000500005000050000500005000050000500005000050000500005000050000500
000601080444103421034210743109431084310642100411004010040100401004010040100401004010040100401004010040100401004010040100401004010040100401004010040100401004010040100401
010400001d3531a3531a3431734315333113310f3310b3210831105311053020530202302043020e3030b30308303053030330303303003030030300303003030030300303003030030300303003030030300303
010f00001075300703095540955224615007030b5500b55510753007030955409552246150070307550075551075300703095540955224615007030b5500b5551075300703095540955224615007030555005555
010f00002175200702247520070228752007022475200702217520070224752007022d752007020070200702217520070224752007022875200702247520070221752007021d752007021c752007020070200702
010f00002175200702247520070228752007022475200702217520070224752007022d752007020070200702217520070224752007022875200702247520070221752007021d752007021c752007021d75200702
010f00001c752000001f7520000023752000001f752000001c752000001f75200000287520000000000000001c752000001f75200000237520000021752000001f752000001d7520000024752000002375200000
010f00001c752000001f7520000023752000001f752000001c752000001f75200000287520000000000000001c752000001f7520000023752000001f752000001d752000001c752000001a752000001875200000
010f00002132200302233220030221322003022432200302213220030226322003022132200302283220030221322003022332200302213220030224322003022132200302283220030229322003022832200302
010f0000263220030228322003022632200302293220030226322003022b3220030226322003022d3220030226322003022832200302263220030229322003022e3222d3222b322293222d3222b3222932228322
010f000015324153201532215322153221532215322153121c3241c3201c3221c3221c3221c3221c3221c3121a3241a3201a3221a3221a3221a3221a3221a3221a3221a3221a3221a3221a3221a3221a3221a312
010f00001a3241a3201a3221a3221a3221a3221a3221a3122d3242d3202d3222d3222d3222d3222d3222d3122b3242b3202b3222b3222b3222b3222b3222b3122e3222d3222b322293222d3222b3222932228322
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00001075300703045540455224615007030555005555107530070304554045522461500703095500955510753007030455404552246150070305550055551075300703045540455224615007030255002555
010f00001075300703025540255224615007030455004555107530070302554025522461500703095500955510753007030255402552246150070304550045551075300703025540255224615007030055000555
010f00001075300703095550955524615095550b555007031075300703095550955524615095550c555007031075300703095550955524615095550b555007031075300703095550955524615095550555500703
010f00001075300703025550255524615025550455500703107530070302555025552461502555055550070310753007030255502555246150255507555007031075300703025550255524615025550955500703
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 0a 0b 43 44
04 0a 0c 43 44
00 14 0d 43 44
04 14 0e 43 44
00 0a 0f 43 44
04 15 10 43 44
00 16 11 43 44
04 17 12 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
