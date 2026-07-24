pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--lepicons
--by andre castel @andrecastel

--constants-
_w=128 --map width
_h=120 --map height
_max_once=20 --actors can be in the level at once

--levels (for an easy access)
function add_level(id,name,x,y,rate,max,goal,actions,enabled)
  local lev={}
  lev.id=id
  lev.name=name
  lev.sprx=x
  lev.spry=y
  lev.spawn_rate=rate --30=1sec
  lev.max_actors=max --maximum actors at level
  lev.goal=goal
  lev.actions=actions
  lev.enabled=enabled --to be implemented when level selector is done
  levels[id]=lev
end

function setup_levels()
  levels={}
  --tutorials
  add_level(1,"1",33,0,200,30,5,{0,0,4,4,0,0,0,0,8},true)
  add_level(2,"2",50,0,200,30,10,{3,1,0,0,4,4,0,0,8},true)
  add_level(3,"3",67,0,200,30,10,{0,0,0,0,0,0,6,6,8},true)
  add_level(4,"4",84,0,200,50,10,{0,8,0,0,8,8,0,4,8},true)
  --levels
  add_level(5,"5",33,16,150,30,20,{1,2,2,2,2,1,1,2,8},true)
  add_level(6,"6",50,16,150,30,15,{2,2,4,4,2,2,2,1,8},true)
  add_level(7,"7",67,16,100,20,10,{4,4,3,3,2,1,4,3,8},true)
  add_level(8,"8",84,16,100,20,15,{4,4,2,3,2,1,3,2,8},true)
end

--helpers
function dist(x1,y1,x2,y2)
  return sqrt((x1-x2)^2 + (y1-y2)^2)
end

function clamp(v,vmin,vmax)
  v=max(v,vmin)
  v=min(v,vmax)
  return v
end

function centre_string(txt,y,color,x)
  txt=""..txt
  if x==nil then x=64 end
  local newx= x-#txt*2
  print(txt,newx,y,color)
end

-- timers
function add_timer(name,step,length,step_cb,end_cb)
  local t={}
  t.length=length -- how many times : 0=infinite
  t.step=step -- 30 steps = 1 second
  t.step_cb=step_cb
  t.end_cb=end_cb
  t.active=true
  t.tim=0
  t.taken=0 -- steps taken
  t.name=name
  add(timers,t)
  --printh("timer "..name.." added.")
  return t
end

function update_timer(t)
  if t.active then
    t.tim += 1
    --printh("time "..time().." | gone: "..t.tim)
    if t.taken<t.length or t.length==0 then
      if t.tim%t.step == 0 then
        --printh("timer "..t.name.." | step! ")
        t.taken+=1
        if t.step_cb then t.step_cb() end
      end
    else
      t.active=false
      if t.end_cb then t.end_cb() end
      del(timers,t)
    end
  end
end

function get_timer(name)
  for t in all(timers) do
    if t.name==name then return t end
  end
end

function change_timer(t,step)
  t.step=step
  t.tim=0
end

function stop_timer(t)
  t.active = false
end

function resume_timer(t)
  t.active = true
end

-- generate map
function get_layout(x,y)
  local mtile, mx, my, newx, newy
  for sx=0,_w-1 do
    cave[sx]={}
    for sy=0,_h-1 do
      if sx==0 or sx==_w-1 or sy==0 or sy==_h-1 then
        cave[sx][sy] = 1
      else
        mtile = mget(x+flr(sx/8), y+flr(sy/8))
        --printh("mtile: "..mtile)
        mx= (mtile%16)*8
        my= flr(mtile/16)*8
        newx=mx+sx%8
        newy=my+sy%8
        if sget(newx,newy)==0 then
          cave[sx][sy]=0
        elseif sget(newx,newy)==7 then
          cave[sx][sy]=1
        else
          if mtile==33 and spawnp.x == 0 then spawnp.x=sx spawnp.y=sy end
          if mtile==34 and pend.x == 0 then pend.x=sx pend.y=sy end
          cave[sx][sy] = 0
        end
      end
    end
  end
end

function fill_map(fpercent)
  for sx=0,_w-1 do
    for sy=0,_h-1 do
      if cave[sx][sy]==0 then
        if rnd(100) < fpercent then
          cave[sx][sy] = 1
        else
          cave[sx][sy] = 0
        end
      else
        cave[sx][sy] = 1
      end
    end
  end
  if spawnp.x>0 or spawnp.y>0 then
    make_space(spawnp.x, spawnp.y,8,4)
    make_space(pend.x, pend.y,8,4)
  end
end

function make_space(px,py,size,margin)
  for x=px-margin,px+margin+size do
    for y=py-margin,py+margin+size do
      cave[x][y]=0
    end
  end
end

function smooth_map()
  local dummy_map = {}
  for sx=0,_w-1 do
    dummy_map[sx] = cave[sx]
    for sy=0,_h-1 do
      nwalls = get_surround(sx,sy)
      if nwalls > 4 then
        dummy_map[sx][sy] = 1
      elseif nwalls < 4 then
        dummy_map[sx][sy] = 0
      end

    end
  end
  for sx=0,_w-1 do
    for sy=0,_h-1 do
      cave[sx][sy] = dummy_map[sx][sy]
    end
  end
end

function paint_map()
  cave_color={}
  local c,m
  for sx=0,_w-1 do
    cave_color[sx]={}
    for sy=0,_h-1 do
      --if sx%8==0 and sy%8==0 then spr(11,sx,sy) end
      if cave[sx][sy] == 1 then
        c=-1
        if sy<_h-3 then
          if cave[sx][sy+1] == 0 then c=5
          elseif (cave[sx][sy+2] == 0 or cave[sx][sy+3] == 0) and (sx+sy)%2!=0
            then c=5
          end
        elseif (sx+sy)%2!=0
          then c=5
        end
        if sy>3 then
          if cave[sx][sy-1] == 0 then c=3
          elseif (cave[sx][sy-2] == 0 or cave[sx][sy-3] == 0) and (sx+sy)%2==0
            then c=3
          end
        --elseif not dist_map(sx,sy,6,0) then c=2 --it adds 9 seconds to loading
        end
      else
        c=0
      end
      if sx==0 or sy==0 or sx==_w-1 or sy==_h-1 then c=15 end --1px border
      if c>=0 then cave_color[sx][sy]=c else cave_color[sx][sy]=sget(88+sx%8,sy%8) end
    end
  end
end

function get_surround(gx,gy)
  local wallcount=0
  for nx=gx-1, gx+1 do
    for ny=gy-1, gy+1 do
      if nx>0 and nx<_w-1 and ny>0 and ny<_h-1
      then
        if nx!=gx or ny!=gy then wallcount += cave[nx][ny] end
      else
        wallcount += 1
      end
    end
  end
  return wallcount
end

function dist_map(x,y,d,c) --returns true if there is a color near
  local is_dist=false
  for dx=x-d, x+d do
    for dy=y-d, y+d do
      if dx>=0 and dx<_w and dy>=0 and dy<_h and dist(dx,dy,x,y)<d then
        if cave[dx][dy]==c then is_dist=true end
      end
    end
  end
  return is_dist
end

function change_map(x,y,n)
  cave[x][y] = n
  local c
  if n==0 then c=0
  elseif n==1 then c=4
  elseif n==2 then c=5
  end
  cave_color[x][y]=c
end

function draw_cave()
  if cave_color != nil
  then
    for sx=0,_w-1 do
      for sy=0,_h-1 do
        pset(sx,sy,cave_color[sx][sy])
      end
    end
  end
end

-- cave map codes
-- 0 = empty
-- 1 = cave (wall, floor, ceiling)
-- 2 = stair and bridge
-- 3 = actor stopping
function generate_map(x,y,lv_id,fpercent)
  cave = {}
  if fpercent==nil then fpercent=35 end
  srand(time())
  map(x,y,128,0,16,15)
  get_layout(x,y)
  cls()
  loading_msg(lv_id)
  fill_map(fpercent)
  for i=0,6 do smooth_map() end
  paint_map()
end

function loading_msg(lv_id)
  if lv_id==0 then centre_string("loading",64,7)
  else
    centre_string("loading level "..levels[lv_id].name, 48,7)
    print("\x8b\x91\x94\x83 - move cursor",20,72,15)
    print("\x8e z - change action",20,80,15)
    print("\x97 x - apply action",20,88,15)
  end
end

--cursor
function init_cursor()
  crs={}
  crs.x=64
  crs.y=64
  crs.dirx=0
  crs.diry=0
  crs.speed=0
  crs.acc=1.5
  crs.enabled=true
end

function enable_cursor(e)
  crs.enabled=e
end

function move_cursor()
  if not crs.enabled then return end
  crs.dirx=0
  crs.diry=0
  if btn(0) then crs.dirx =-1 crs.speed+=crs.acc
  elseif btn(1) then crs.dirx=1 crs.speed+=crs.acc
  end
  if btn(2) then crs.diry=-1 crs.speed+=crs.acc
  elseif btn(3) then crs.diry=1 crs.speed+=crs.acc
  end
  crs.speed= min(crs.speed, 5)
  if crs.speed > 0 then crs.speed -= 0.5 end
  crs.speed= max(crs.speed, 0)
  crs.x += crs.dirx * crs.speed * 0.5
  crs.y += crs.diry * crs.speed * 0.5

  crs.x=clamp(crs.x,0,_w-1)
  crs.y=clamp(crs.y,0,_h-1)
end

function draw_cursor()
  sspr(0,16,5,5,crs.x-2,crs.y-2)
end

--animations
function init_animations()
  animations={}
  st={}
  st.fall=0
  st.walk=1
  st.hitfloor=2
  st.die=3
  st.dead=4
  st.stop=5
  st.explode=6
  st.stairs=7
  st.bridge=8
  st.tunnel=9
  st.dig=10
  st.objtramp=11
  st.objbean=12
  st.cancel=13
  st.jump=14
  st.beanbag=15
  set_animations()
end

function set_animations()
  add_animation(st.walk,0,4,0) --walk
  add_animation(st.fall,1,2,0) --fall
  add_animation(st.hitfloor,1,2,2) --hit floor
  add_animation(st.die,2,4,0) --die
  add_animation(st.stop,3,4,0,48,"stop") --action stop
  add_animation(st.explode,4,4,0,50,"explode") --action explode
  add_animation(st.stairs,5,4,0,52,"stairs") --action build stair
  add_animation(st.bridge,5,4,0,54,"bridge") --action build bridge
  add_animation(st.tunnel,6,4,0,56,"tunnel") --action dig tunnel
  add_animation(st.dig,7,4,0,58,"dig") --action dig down
  add_animation(st.objtramp,1,2,2,60,"trampoline") --action jump
  add_animation(st.objbean,1,2,2,62,"bean bag") --action beanbag
  add_animation(st.cancel,1,2,2,43,"cancel") --cancel
  add_animation(st.jump,8,2,0,60) --action jump
  add_animation(st.beanbag,1,2,2,62) --action beanbag
end

--actors
function add_actor(x, y)
  a={}
  a.x=x
  a.y=y
  a.dir=1
  a.airvel=0 --move when falling (if after jump)
  a.spr=0
  a.frame=0--animation frame
  a.state=1 --type of animation
  a.nextst=-1 --next animation to be played
  a.aftst=-1 --store action to be played later (ie. after big fall)
  a.t=0 --animation timer
  a.w=4 --in pixels
  a.h=4
  a.speed=rnd(0.25)+0.25
  a.anim=animations[0]
  a.sel=false
  a.bcount=0
  add(actors,a)
  return a
end

function add_animation(state,spr,frames,start,thumb,name)
  --(number, sprite no, total frames, starting frame, thumbnail sprite)
  anim = {}
  anim.spr = spr
  anim.frames = frames
  anim.startat = start --which quarter the animation starts at
  anim.thumb = thumb
  anim.name = name
  animations[state] = anim
end

function spawn_actor()
  if #actors<_max_once and mngr.n_actors<mngr.max_actors then
    mngr.n_actors+=1
    add_actor(spawnp.x+2, spawnp.y+2)
    fx_circle(spawnp.x+4,spawnp.y+4,7,1)
    play_sfx(snd.spawn)
    --printh("added actor. | "..#actors.." total")
  end
end

function random_spawn()
  local x=flr(rnd(_w-8)+4)
  local y=flr(rnd(_h-8)+4)
  --printh("random actor "..x.." | "..y)
  if get_surround(x+2,y+2)<2 then
    add_actor(x,y)
  else
    random_spawn()
  end
end

function check_hit(a,side,ad) -- returns true if there is a hit
  if ad==nil then ad=0 end
  local check=false
  local h
  if side=="down" then
    for i=0,a.w-1 do
      h=hitwall(flr(a.x)+i,flr(a.y)+a.h+ad)
      if h==1 or h==2 then check=true end
    end
  elseif side=="front" then
    local sx = flr(a.x)+3+ad
    if a.dir==-1 then sx=flr(a.x)-ad end
    for i=0,2 do
      h=hitwall(sx,flr(a.y)+i)
      if h==1 or h==3 then check=true end
    end
  elseif side=="up" then
    for i=0,a.w-1 do
      h=hitwall(flr(a.x)+i,flr(a.y)-1-ad)
      if h==1 or h==3 then check=true end
    end
  elseif side=="climb" then --if there is one pixel height obstacle
    local sx = flr(a.x)+3+ad
    if a.dir==-1 then sx=flr(a.x)-ad end
    if hitwall(sx,flr(a.y)+3)>0 then check=true end
  elseif side=="tunnel" then
    local sx = flr(a.x)+3+ad
    if a.dir==-1 then sx=flr(a.x)-ad end
    for i=0,2 do
      h=hitwall(sx,flr(a.y)+i)
      if h==1 then check=true end
    end
  else
    return false
  end
  return check
end

function hitwall(px,py)
  if px<=0 or px>=_w-1 or py<=0 or py>=_h-1 then
    return 1
  end
  return cave[flr(px)][flr(py)] --hit wall or other obstacle
end

function closest_actor(x,y,on_action)
  if on_action==nil then on_action=false end
  if #actors>0 and crs.enabled then
    local cldist, clact, ac
    for a in all(actors) do
      d = dist(x,y,a.x,a.y)
      ac=true
      if on_action then
        if a.state < st.stop then ac=false end
      end
      if (cldist==nil or d<cldist) and ac then
        cldist=d
        clact=a
      end
    end
    return clact
  else
    return nil
  end
end

function select_actor(a)
  if selected!= a then
    if selected != nil then selected.sel=false end
    if a!= nil then a.sel=true end
    selected=a
  end
end

function kill_actor(a)
  if a==selected then selected=nil end
  del(actors,a)
end

function move_actor(a)
  if a.state==st.objbean or a.state==st.objtramp then
    turn_obj(a)
    return
  end
  --animate sprite
  a.anim = animations[a.state]
  a.frame=(flr(a.t) % a.anim.frames) + a.anim.startat

  if a.nextst >= 0 then --play whole animation before going to the next
    if flr(a.t)>= a.anim.frames then
      a.state = a.nextst
      a.nextst = -1
      t=0
    end
  else
    if not check_hit(a,"down") and a.state!=st.jump then -- fall
      if a.state != st.fall then
        a.t=0
        a.state = st.fall
      end
      a.y+=1
      if check_hit(a,"front") then a.airvel=0 end
      a.x+=a.dir*a.airvel
    else
      if a.state == st.fall then --hit floor
        if a.aftst==st.objbean then
          change_state(a,st.objbean)
        elseif flr(a.t)>7 then --too high dies
          a.t=0
          a.state=st.die
          a.nextst=st.dead
          play_sfx(snd.hit_die)
          a.aftst=-1
        elseif flr(a.t)>3 then --medium play animation
          a.t=0
          a.state=st.hitfloor
          a.nextst = st.walk
          a.aftst=-1
          play_sfx(snd.hit)
        else --low height just walks
          if a.aftst>6 and a.aftst<11 then
            change_state(a,a.aftst)
          else
            play_sfx(snd.soft_hit)
            a.state=st.walk
          end
          a.nextst = -1
        end
      end
    end
  end

  if a.state == st.walk then --walk
    --if flr(a.t) > a.anim.frames then
    --  a.state = st.walk
    --end
    action_walk(a)
  elseif a.state==st.dead then -- dead
    kill_actor(a)
  elseif a.state==st.stop then
    action_stop(a)
  elseif a.state==st.explode then -- to explode
    action_explode(a)
  elseif a.state==st.stairs or a.state == st.bridge then -- build stairs or bridges
    action_build(a)
  elseif a.state==st.tunnel then
    action_tunnel(a)
  elseif a.state==st.dig then
    action_dig(a)
  elseif a.state==st.jump then
    action_jump(a)
  end
  a.t+=0.5
end

function draw_actor(a)
  local sx = (a.spr + a.anim.spr)*8 + ((a.frame%2)*a.w)
  local sy = (flr(a.frame/2)*a.h)
  sspr(sx,sy,a.w,a.h, a.x,a.y,a.w,a.h, a.dir==-1)
  --draw selector
  if a.sel then
    sspr(1,22,1,2, a.x+1,a.y-3)
  end
  --print(a.t, 2,122,7)
end

--actor actions
function change_state(a,act)
  a.t=0
  a.state = act
  a.aftst = act
  --printh("changed to state: "..act)
end

function cancel_action(a)
  if a.state>=st.stop and a.state<=st.dig then
    change_state(a, st.walk)
    fx_circle(a.x+2,a.y+2,6,14)
  end
end

function action_walk(a)
  a.airvel=0
  if check_hit(a,"front") then
    a.dir*=-1 --invert direction if hit wall
  elseif check_hit(a,"climb") and not check_hit(a,"up") then --climb 1 pixel
    a.y-=1
  end
  a.x+=a.dir*a.speed
end

function action_stop(a)
  if t==0 then
    for x=a.x+1, a.x+2 do
      for y=a.y, a.y+3 do
        change_map(flr(x),flr(y),3)
      end
    end
  end
end

function action_stop_end(a)
  for x=a.x+1, a.x+2 do
    for y=a.y, a.y+3 do
      change_map(flr(x),flr(y),0)
    end
  end
  change_state(a,st.walk)
end

function action_jump(a)
  local isdone=false
  local jumpvel=3
  local sp
  if a.t==0 then a.bcount=0 end
  if not check_hit(a,"up") and not check_hit(a,"front") then
    a.x+=a.dir*0.6
    sp=jumpvel-a.bcount
    sp = clamp(sp,-1,3)
    a.y-=sp
    a.bcount+=0.2
    a.airvel=0.4
    if a.bcount>=jumpvel then --starts falling
      isdone=true
    end
  else
    isdone=true
  end
  if isdone then
    change_state(a,st.walk)
  end
end

function action_explode(a)
  if flr(a.t)>30 then
    fx_explosion(flr(a.x)+2, flr(a.y)+2)
    play_sfx(snd.explosion)
    add_timer("expld",4,1,
              function() explode_map(flr(a.x), flr(a.y), 10) end,
              nil)
    a.state=st.die
    a.nextst=st.dead
  end
end

function action_build(a)
  if a.t==0 then a.bcount=0 end
  if check_hit(a,"front") or a.bcount>=10 then
    --a.dir *=-1
    a.bcount = 0
    change_state(a,st.walk)
  else
    if a.t>6 then --give some pause between steps
      local th=a.state-st.stairs
      if a.bcount==0 then
        a.y-=1
        build_step(a.x+1,a.y+4,3)
      else
        build_step(a.x+2+(2*a.dir),a.y+3+th,2+th)
        a.x+=2*a.dir
        if a.state==st.stairs then a.y-=1 end
      end
      a.bcount+=1
      a.t=1
    end
  end
end

function build_step(x,y,size)
  play_sfx(snd.build)
  for i=0,size-1 do
    change_map(flr(x)+i,flr(y),2)
  end
end

function explode_map(x,y,size) --size=radius
  for sx=x-size, x+size do
    for sy=y-size, y+size do
      if sx>0 and sx<_w-1 and
        sy>0 and sy<_h-1 then
        if dist(sx,sy,x,y)<=size then
          if cave[sx][sy]<=2 then change_map(sx,sy,0) end
        end
      end
    end
  end
end

function action_tunnel(a)
  local isdone=false
  if a.t==0 then a.bcount=0 end
  if a.bcount==0 then --walks until hit a wall
    if a.t>80 then isdone=true end --cancel if it doesn't hit a wall for a while
    if check_hit(a,"tunnel")
      then a.bcount+=1
      else action_walk(a)
    end
  end
  if a.bcount>0 and a.t>6 then
    --starts digging the tunnel
    local sx = flr(a.x)+3
    if a.dir==-1 then sx=flr(a.x) end
    if sx<=0 or sx>=_h-1 then isdone=true
    else
      for i=0,3 do
        change_map(sx,flr(a.y)+i,0)
      end
      a.x+=a.dir
      a.bcount+=1
      a.t=1
      play_sfx(snd.dig)
    end
    if not check_hit(a,"tunnel",1) then a.bcount+=1 end
    if a.bcount>15 then isdone=true end
  end
  if isdone then
    change_state(a,st.walk)
  end
end

function action_dig(a)
  local isdone=false
  if a.t==0 then a.bcount=0 end
  if a.t>6 then
    --starts digging
    local sy = flr(a.y)+4
    if sy>=_h-1 then isdone=true
    else
      a.y+=1
      for i=0,3 do
        change_map(flr(a.x)+i,sy,0)
      end
      a.bcount+=1
      a.t=1
      play_sfx(snd.dig)
    end
    if a.bcount>15 then isdone=true end
  end
  if isdone then
    change_state(a,st.walk)
  end
end

--objs
function add_obj(x,y,spr,act_st,fx_cb,sound)
  o={}
  o.x=flr(x)
  o.y=flr(y)
  o.spr=spr
  o.frame=0
  o.t=0
  o.act_st=act_st
  o.anim=false
  o.fx_cb=fx_cb
  o.sound=sound
  add(objs,o)
  return o
end

function turn_obj(a)
  if a.state==st.objtramp then
    add_obj(a.x,a.y,9,st.jump,fx_jump,snd.jump)
  elseif a.state==st.objbean then
    fx_circle(a.x+2, a.y+2, 5, 9)
    add_obj(a.x,a.y,10,st.walk,fx_bean,snd.beanbag)
  end
  kill_actor(a)
end

function animate_obj(o)
  if o.t%5==0 then
    o.anim=false
    o.t=0
    o.frame=0
  else
    o.frame=flr(o.t%4)
  end
end

function update_obj(o)
  for a in all(actors) do
    if a.x>=o.x and a.x<=o.x+3 and a.y>=o.y-2 and a.y<=o.y+3 then
      if a.state<o.act_st then
        o.anim=true
        change_state(a,o.act_st)
        o.fx_cb(o.x+2,o.y+2)
        play_sfx(o.sound)
      end
    end
  end
  if o.anim then
    o.t+=1
    animate_obj(o)
  end
end

function draw_obj(o)
  local sx = o.spr*8 + ((o.frame%2)*4)
  local sy = (flr(o.frame/2)*4)
  sspr(sx,sy,4,4, o.x,o.y)
end

function add_goal()
  mngr.reached+=1
  play_sfx(snd.goal)
  fx_rays(pend.x+4, pend.y+4)
  fx_circle(pend.x+4,pend.y+4,9,10)
  mngr.spawn_rate=max(mngr.spawn_rate-5, 30)
  change_timer(get_timer("spawn"),mngr.spawn_rate)
  --check end of game
  if mngr.reached>=mngr.goal then
    if not mngr.game_done then
      stop_timer(get_timer("spawn"))
      sound_on=false
      music(1,600)
    end
    mngr.game_done=true
  end
end

function update_goal_place(a)
  if a.x>=pend.x and a.x<=pend.x+7 and a.y>=pend.y+3 and a.y<=pend.y+6 then
    if a.state==st.fall or a.state==st.walk then
      add_goal()
      kill_actor(a)
    end
  end
end

--fx
function add_fx(x,y,spr,f,cb)
  fx={}
  fx.x=x
  fx.y=y
  fx.spr=spr
  fx.t=0
  fx.frames=f
  fx.cb=cb --play something different than sprites
  add(fxs,fx)
  return fx
end

function remove_fx(fx)
  del(fxs,fx)
end

function fx_explosion(x,y)
  add_fx(x-4,y-4,64,8)
end

function fx_jump(x,y)
  add_fx(x-3,y-7,96,5)
end

function fx_bean(x,y)
  add_fx(x-3,y-7,80,6)
end

function fx_rays(x,y)
  add_fx(x-4,y-4,112,7)
end

function fx_circle(x,y,size,color)
  add_fx(x,y,0,size,
  function(t)
    circ(x,y,t*1.5,color)
  end
    )
end

function draw_fx(fx)
  local s=fx.spr + flr(fx.t)
  if flr(fx.t)<fx.frames then
    if fx.cb!=nil then
      fx.cb(s)
    else
      spr(s,fx.x,fx.y)
    end
  else
    remove_fx(fx)
  end
  fx.t+=0.5
end

--sfx
function init_sfx()
  snd={}
  snd.spawn=0
  snd.hit=1
  snd.hit_die=2
  snd.build=3
  snd.explosion=4
  snd.dig=5
  snd.jump=6
  snd.beanbag=7
  snd.goal=8
  snd.soft_hit=9
  snd.win=10
end

function play_sfx(fx, change)
  if sound_on then
    sfx(fx)
    if change!=nil then sound_on=change end
  end
end

--input
function change_selection()
  if (crs.x>=spawnp.x and crs.x<=spawnp.x+7 and
      crs.y>=spawnp.y and crs.y<=spawnp.y+4) then
    spawn_actor()
  else
    sel_action+=1
    sel_action=sel_action%#mngr.actions
    --if action is empty move to next
    if mngr.actions[sel_action+1]==0 then
      --only if there are more actions available
      if any_action_left() then change_selection() end
    end
  end
end

function any_action_left()
  for act in all(mngr.actions) do
    if act>0 then return true end
  end
  return false
end

function pick_action()
  if selected==nil then return end
  local act=5+sel_action
  printh("picked action: "..act)
  if act==st.objbean and selected.state==st.fall then
    selected.aftst=st.objbean
    fx_circle(selected.x+2,selected.y+2,6,9)
  elseif mngr.actions[sel_action+1]>0 then
    if act==st.cancel then
      cancel_action(selected)
    elseif selected.state==st.walk then
      change_state(selected, act)
      fx_circle(selected.x+2,selected.y+2,6,9)
    end
    mngr.actions[sel_action+1] -= 1
  end
end

function check_input()
  if game_state==0 then
    if btnp(4) or btnp(5)then --level_select_screen()end
      done_title_screen()
    end
  elseif game_state==1 then
    --select level

  elseif game_state==2 then
    if mngr.game_done then
      if btnp(4) then restart_level()
      elseif btnp(5)then load_next_level() end
    else
      if btnp(4) then change_selection()
      elseif btnp(5) then pick_action() end
    end
  elseif game_state==3 then --end of game
    if btnp(4) or btnp(5) then title_screen() end
  end
end

--gui
function draw_gui()
  map(0,16,0,112,16,2)
  --spawn and end points
  if spawnp.x>0 and spawnp.y>0 then
    spr(35+flr(main_t/4)%4,spawnp.x,spawnp.y)
    spr(39+flr(main_t/4)%4,pend.x,pend.y)
  end
  --numbers on spawn and end points
  if not mngr.game_done then
    centre_string(mngr.max_actors-mngr.n_actors, spawnp.y-6, 15, spawnp.x+4)
    centre_string(mngr.goal-mngr.reached, pend.y+9, 15, pend.x+4)
  end
  local s
  for i=0,8 do
    s=animations[5+i].thumb
    if mngr.actions[i+1]<=0 then s+=1 end
    spr(s, i*8, 15*8)
  end
  print(animations[5+sel_action].name,9*8+3,15*8+1,7)--draw name
  local n=mngr.actions[sel_action+1]
  local spc=10
  if n>=10 then spc=6 end
  print(""..n,14*8+spc,15*8+1,8)--draw amount
  spr(23+(main_t/4)%2, sel_action*8, 15*8) --draw selector

  draw_time()
end

function draw_time()
  if not mngr.game_done then
    game_time.time=flr(time()-mngr.ini_time)
    local min,sec
    game_time.min=flr(game_time.time/60)
    min=game_time.min
    if min<10 then min="0"..min end
    game_time.sec=game_time.time%60
    sec=game_time.sec
    if sec<10 then sec="0"..sec end
    game_time.text=(min..":"..sec)
  end
  centre_string(game_time.text,14*8+1,7)
end

function draw_text_box(x,y,w,h)
  local s,fx,fy,sw,sh
  sw=x+w-1
  sh=y+h-1
  for sx=x,sw do
    for sy=y,sh do
      s=12
      fx=false
      fy=false
      if sx==x or sx==sw then s=14 end
      if sy==y or sy==sh then s=15 end
      if ((sx==x and sy==y) or (sx==sw and sy==sh) or
        (sx==sw and sy==y) or (sx==x and sy==sh)) then s=13 end
      if sx==sw then fx=true end
      if sy==sh then fy=true end

      spr(s,sx*8,sy*8,1,1,fx,fy)
    end
  end
end

--initialize level
function init_game()
  spawnp={x=0,y=0}
  pend={x=0,y=0}
  main_t=0
  timers={}
  actors={}
  fxs={}
  objs={}
  sel_action=0
  selected=nil
  sound_on=false
  init_cursor()
end

function init_level(lev)
  init_game()
  generate_map(lev.sprx,lev.spry,lev.id)
  mngr={}
  mngr.id=lev.id
  mngr.levname=lev.name
  mngr.spawn_rate=lev.spawn_rate
  mngr.max_actors=lev.max_actors
  mngr.goal=lev.goal
  mngr.n_actors=0 --actors have spawned in the level
  mngr.reached=0 --actors have reached end
  mngr.actions=lev.actions
  mngr.ini_time=time()
  mngr.game_done=false
  init_game_time()
  sound_on=true
  if lev.actions[sel_action+1]==0 then
    change_selection() end
  add_timer("spawn",lev.spawn_rate,0,spawn_actor,nil)
end

function init_game_time()
  game_time={}
  game_time.time=0
  game_time.min=0
  game_time.sec=0
  game_time.text="00:00"
end

function load_level(id)
  setup_levels()
  cls()
  game_state=2
  init_level(levels[id])
  music(-1, 800)
  spawn_actor()
  menuitem(1, "restart level", restart_level)
end

function restart_level()
  load_level(mngr.id)
end

function load_next_level()
  id=mngr.id + 1
  if id<=#levels then
    load_level(id)
  else
    end_of_game()
  end
end

function title_screen()
  game_state=0
  music(0)
  init_game()
  enable_cursor(false)
  generate_map(0,0,0,30)
  add_timer("random_spawn",200,40,random_spawn,nil)
  random_spawn()
end

function done_title_screen()
  --music(-1, 2400)
  load_level(1)
end

function draw_title_screen()
  map(0,18,24,30,10,4)
  local c=4
  if flr(main_t/16)%3!=0 then c=6 end
  centre_string("press \x8e z or \x97 x",88,c)
  centre_string("to start",96,c)
end

function level_select_screen()
  game_state=1
end

function draw_select_screen()

end

function draw_end_box()
  draw_text_box(2,3,12,10)
  centre_string("congratulations!",34,7)
  centre_string("you completed",44,7)
  centre_string("level "..mngr.levname,52,7)
  centre_string(game_time.min.." min "..game_time.sec.." sec",60,9)
  centre_string("\x8e z to retry",80,7)
  centre_string("\x97 x to continue",88,7)
end

function end_of_game()
  game_state=3
  init_game()
  enable_cursor(false)
end

function draw_end_game_screen()
  cls()
  draw_text_box(2,3,12,10)
  centre_string("you've done it!",34,9)
  centre_string("congratulations",44,7)
  centre_string("and thank you",52,7)
  centre_string("for playing lepicons!",60,7)
  centre_string("\x8e z or \x97 x",80,7)
  centre_string("to continue",88,7)
end


function _init()
  t_start= time()
  game_state=0 --0:title | 1:level select | 2:levels | 3:end of game
  cls()
  setup_levels()
  init_animations()
  init_sfx()
  title_screen()
end

function _update()
  main_t+=1 --main timer
  move_cursor()
  if #actors > 0 and crs.enabled then select_actor(closest_actor(crs.x,crs.y,sel_action+5==st.cancel)) end
  if main_t%2 == 0 then
    foreach(actors,move_actor)
    foreach(objs,update_obj)
  end
  foreach(timers, update_timer)
  foreach(actors,update_goal_place)
  check_input()
end

function _draw()
  if t_end==nil then t_end=time() printh("it took "..t_end-t_start.."s to load the game") end
  cls()
  draw_cave()
  foreach(actors,draw_actor)
  foreach(objs,draw_obj)
  foreach(fxs,draw_fx)

  if game_state==0 then draw_title_screen()
  elseif game_state==1 then draw_select_screen()
  elseif game_state==2 then
    draw_gui()
    draw_cursor()
    if mngr.game_done then draw_end_box() end
  elseif game_state==3 then
    draw_end_game_screen()
  end
end


__gfx__
00000b1b0b1b0b1b000000000b1b0b1b0b1b0bbb0b1b0b1b0b1b0b1b000000000b1b0b1b0000000000000000444454445555555500fffffff4f55555ffffffff
0b1b0bb00bb00bb0000000000bb00bb00bb00bb00bbb0bb00bbb0bb00b1b0b1bbbb0bbb00000000009900000454444455555555500f44444f4f5555544444444
0bb00bb00eb00bb000800080bbbbbbbb0bb00bb00bb00bbb0bb00bbb0bb00bb00eb00eb088880000999999994444444455555555fff4fffff4f55555ffffffff
02ee0ee00e2002e00bbb08880ee00ee00ee00ee00ee00ee00ee00ee00eeb0eb00e200e200dd08888999999995444444455555555f444f555f4f5555555555555
00000b1b000000000080000091909190099909190000000009190919000000000bbb0b1b00000000000000004444544455555555f4fff555f4f5555555555555
0b1b0bb00b1b00008000008009900990999999990919091909900990091909190bb00bb088888888000000004544444455555555f4f55555f4f5555555555555
0bb00bb00bb00bbb00080000999999999999999909900990099009900990099002e002e00dd00dd0900999994444445455555555f4f55555f4f5555555555555
0ee20ee002e002ee080080080ee00ee00ee00ee00ee90e920ee90ee009e00ee0000000000dd00dd0999999994454444455555555f4f55555f4f5555555555555
00000000777777770077770000000000ffffffff00000000ffffffff99000099aa0000aaffffffffff55555555555555555555ff000003333333333333300000
00000000777777770077770000000000ffffffff00000000ffffffff90000009a000000afffffffff5555555555555555555555f000044444444444444440000
000000007777777700777700777777770fffffff00000000fffffff090000009a000000afffffffff5555555555555555555555f000444444444444444444000
0000000077777777007777007777777700000fff00000000fff0000090000009a000000afffffffff5555555555555555555555f000444444444444444444000
000000007777777700777700777777770fff0fff00000000fff0fff090000009a000000afffffffff5555555555555555555555f000444444444444444444000
000000007777777700777700777777770fff0fff00000000fff0fff090000009a000000afffffffff5555555555555555555555f000444444444444444444000
000000007777777700777700000000000fff0fff00000000fff0fff099000099aa0000aaffffffffff55555555555555555555ff000044444444444444440000
00000000777777770077770000000000000000ffffffffffff0000000000000000000000ffffffffffffffffffffffffffffffff000005555555555555500000
0070000088888888aaaaaaaa04444440044444400444444004444440000001000000000001010001100010000000000000000000fff0000000000fff00888200
0070000081111118a111111a455555544555555445555554455555540d00d00000000d000000000000d000d00800008005000050f00000000000000f06666650
7707700081888818a1aaaa1a551111555511115555d1115555111155006000d00d00600000000d00000d00000080080000500500f00000000000000f66777665
0070000081811118a1a1111a5d111d1551111115511111d55111d115055655500565556005555550055555500008800000055000f00000000000000f67787765
0070000081888818a1aaa11a055d55500d5551500555555005d555d0577777755776777556776775577776750008800000055000f00000000000000f67788765
000a000081111818a1a1111a00001000000d00000100010000000000557777555577775555777755557777550080080000500500f00000000000000f67777765
0a09900081888818a1aaaa1a00100010000010000001000000000100455555544555555445555554455555540800008005000050f00000000000000f66777665
0a0aaa0088888888aaaaaaaa00000000001000100000100001010000044444400444444004444440044444400000000000000000f00000000000000f06666650
00888800005555000000900000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880055555500908a0900505605000bb0040006600500000bb00000066000444444005555550040000400500005000000000000000000000000000000000
088888800555555000a82a000065560000bb0440006605500000bb00000066000000044000000550040000400500005000888800005555000000000000000000
0877778005666650098aa2800556655000bb4440006655500000bb0000006600000bb04000066050040bb04005066050088ff880055665500099990000555500
0888888005555550002aaa900056665000044440000555500444444005555550000bb04000066050040bb04005066050008888000055550009aaaa9005666650
0888888005555550090a2a000506560000444440005555500440044005500550000bb44000066550044bb440055665500d0000d005000050099aa99005566550
00888800005555000008a00000056000044444400555555004000040050000500444444005555550044444400555555000dddd00005555000099990000555500
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000009080080008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000090000090900000908a090080000800000020000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009900000aaa900000aa00000a82a00000898080020980000000020000000000000000000000000000000000000000000000000000000000000000000000000
009aa90009aaaa0009a88a00098aa288009228900800000000208000000000000000000000000000000000000000000000000000000000000000000000000000
009aa90009aaaa9000988a908a2aaa90898229000090208000800000000000000000000000000000000000000000000000000000000000000000000000000000
00099000009aa900009aa000008a2a00008988000020090000020008002000000000000000000000000000000000000000000000000000000000000000000000
0000000000099000009090900908a090080000808000000802000000000020000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000008008008000080000000000000000000020000200000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000a000000a900000099000000900000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a00a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006600000a00a000aa00aa0a900009a900000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000060000060a006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000006a0600000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a0600000000000a000600000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000600000a0060000000000a00000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000009000000990000009a000900a0000a000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000090000900a0000a00a0090a00000900000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a00a0000a00a0000a09a00000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006600000066000000000000000090000000990000000990000000a000000000000000000000000000000000000000000000000000000000000000000000000
0006600000066a0000000a0000900a000990000099000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a0000000a0009000a090a0000090a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000090000000a0000090a0090090000900a00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000009000000090000000a00090000000a000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03330000000333333000033333330003333333000333333300033333330003300033000333333300000000000000000000000000000000000000000000000000
03430000000343434000043434340003434343000434343400034343430003400043000434343400000000000000000000000000000000000000000000000000
04340000000434555000034355430005543455000343555500043555340004300034000345555500000000000000000000000000000000000000000000000000
04440000000444000000044400440000044400000444000000044000440004430044000440000000000000000000000000000000000000000000000000000000
04440000000444000000044400440000044400000444000000044000440004430044000440000000000000000000000000000000000000000000000000000000
04440000000444000000044400440000044400000444000000044000440004440044000440000000000000000000000000000000000000000000000000000000
04440000000444000000044400440000044400000444000000044000440004440044000440000000000000000000000000000000000000000000000000000000
04440000000444000000044400440000044400000444000000044000440004443044000440000000000000000000000000000000000000000000000000000000
04440000000444000000044400440000044400000444000000044000440004443044000440000000000000000000000000000000000000000000000000000000
04440000000444000000044400440000044400000444000000044000440004444044000440000000000000000000000000000000000000000000000000000000
04440000000444330000044433440000044400000444000000044000440004444344000443333300000000000000000000000000000000000000000000000000
04440000000444340000044434540000044400000444000000044000440004444344000543434300000000000000000000000000000000000000000000000000
04440000000444550000044455550000044400000444000000044000440004444444000555553400000000000000000000000000000000000000000000000000
04440000000444000000044400000000044400000444000000044000440004444444000000004400000000000000000000000000000000000000000000000000
04440000000444000000044400000000044400000444000000044000440004444444000000004400000000000000000000000000000000000000000000000000
04440000000444000000044400000000044400000444000000044000440004445444000000004400000000000000000000000000000000000000000000000000
04440000000444000000044400000000044400000444000000044000440004440444000000004400000000000000000000000000000000000000000000000000
04443333000444333300044400000003344433000444333300044333440004440444000333334400000000000000000000000000000000000000000000000000
04543434000545434300045400000003454543000454343400054343450004540545000343434400000000000000000000000000000000000000000000000000
05454545000454545400054500000004545454000545434300045434540005450054000434345400000000000000000000000000000000000000000000000000
05555555000555555500055500000005555555000555555500055555550005550055000555555500000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11e0000000000000000000000000e01111110000000000000000000000001111000000000000000000000000000000000000000000000000000000000000000000000000210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e00000000000000000101000000000e011000000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100101010100000000000000000000000000000000000000000000000000000000000000000000000000000
e00011131313131313131313131100e011100000000000000000000000000011000000000000000000000000000000000000000000000000001111000000000000000011111110100000000000000000000000001111002110100011000000000000000000000000000000000000000000000000000000000000000000000000
e00012101010101010101010101200e011000011111111000011111111000011000000000000000000000000000000000000000000000000001111000000000000000011111110100000000000000000000000001111000000000011110011111100000000000000000000000000000000000000000000000000000000000000
e00012101010101010101010101200e011000000000000000000000000000011000000000000000000000000000000100000000000000000001111000000000000000000000010100000000000000000000000001111111111110011110011110000000000000000000000000000000000000000000000000000000000000000
e00012101010101010101010101200e011000011111111000011111111000011000021001010100010000010101010220000000000000000001111000000000000000000000000000000000000000000000000001111111100111111111111110000000000000000000000000000000000000000000000000000000000000000
e00012101010101010101000101200e011000000000000000000000000000011000000000011111111000010101010101000000000000000111111110021000000000000000000000000000000000000000000001111110000001111000011111111000000000000000000000000000000000000000000000000000000000000
e00011131313131313131313131110e011000011111111000011111111000011001111111111111111000011111111111100001100000000111111110000000000000000000000000000000000000000002200001111111111111111000011110011110000000000000000000000000000000000000000000000000000000000
e0100000d0d1d2d3d4d5d6d7000010e011000000000000000000000000000011001111111111111010101011111111111100001113131313111111111111111100000000000000000000000000000000000000001111000000111111111111110011111100000000000000000000000000000000000000000000000000000000
11101000e0e1e2e3e4e5e6e71010101111000011111111000011111111000011001111111111111010101011111111111100000010101010111111111111111100000000000000000000000000111111111111001111000000001111111111111111111100000000000000000000000000000000000000000000000000000000
11111010f0f1f2f3f4f5f6f71010111111000000000000000000000000000011001111111111111010101011111111111100000000101010111111111111110000000000000000000000000000111111111111001100110000111111000011000000000000000000000000000000000000000000000000000000000000000000
1111111010101010101010101011111111000000000000000000000000000011001111111111111010101011111111111100000000220010111111111111111100000000000000000011111111111111111111001111111111111111000011002200000000000000000000000000000000000000000000000000000000000000
1111111010101010101010101011111111110000000000000000000000001111001111111111111111111111111111111100000000000000111111111111110000000000000000000011111111111111111111001111111100111111111111000000001100000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111111111111111111111111001111111111111111111111111111111100000000000000001111000000000000000011111111111111111111111111111111001111111111111111111111111111111100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000190000000000000000000000000000000019000000000000000000000000000000001900000000000000000000000000000000190000000000000000000000000000000019000000000000000000000000000000001900000000000000000000
0000000000102d00002e00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000011110000000000000000001100000000000000000000000000001100000000000000000000000000000000000000000000000000000000
1515151515151515151a1b1b1b1b1b1c00000000000000000000000000000000000000211010101010000000000000000000000000000000000000000000000000000000000000111111110000000021000000001100000000000021000000000000001100000000000000000000000000000000000000000000000000000000
808182838485868788898a8b1010101000000000000000000000000000000000001110101010101111000011110000000000000000002200000000000010101010100000000000111111110000101010100000001100000000000000000000000000001100000000000000000000000000000000000000000000000000000000
909192939495969798999a9b1010000000000000000000000000000000000000001113131311111111000011111113131300000000000000001110000010101010100000000000110011110000131313130000001100000011131313131313131300001100000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7a8a9aaab1010000000000000000000000000000000000000000000000000000000001111000000001100000000000000111111131313131010100000000011111111111100000000000000001113000011000000000000000000131100000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b8b9babb9c10000000000000000000000000000000000000000000000000000000001111000000001100000000001111111100000000000000000000111111111111111110101011111011001100000011000000000000000000001100000000000000000000000000000000000000000000000000000000
1010101010101010000010100000000000000000000000000000000000000000000000000000000000111100000000111100000000111111111100000000000000000000110000111111110000131311111111001100001111131313131311111300001100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000001113131311111100001111111100000000101111111100001313131111110000110000110011111010101010101011001100000000000000000011110000001100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111100110010101010111100000000000010110000000000110010111010101010101011001113000000000000001111110000131100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111110101111111111000000001010110011111111110000110011111111111111001100000013131113131111111300001100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000111100000000000000000000000000110010101111111111111313131010110000000011000000110000000000000011001100000000001100000000000000001100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000111100000000000000000022000000110010101010101010101010101010110000220010000011110000000000000011001100000000001100000022000000001100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000001100001100000000110000000000111111102110101000000000111111110000000010111111111100111111001111001113000000001100000000000000131100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000001100001200000011111111000000111111101010101011111111111111110000111111111111111111111111111111001100000013111111131313131300001100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000001111111111111111111111111111111100111111111111111111111111111111110011111111111111111111111111111111001100000000000000000000000000001100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000019000000000000000000000000000000001900000000000000000000000000000000190000000000000000000000000000000019000000000000000000000000000000001900000000000000000000
__sfx__
00030000220502b0502f05031050310502d05027050220501d050190501705017050190501d0501c0501a0501605014050120501203010030100300d0200c0200b0100a010090100801008010080003600037000
000300002663024630216301d1301d1301b1201b1201a120191201810018100161001810017500161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002a6402764025640246401b14017130151301513014130131301313014130121300b1300c130111300e130091300713008130051300413000000000000000000000000000000000000000000000000000
000400001c6301d6301d6301c1301e130211302413027130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001d650213602067022370216702267023660236502364024640256302563026630266302663026630266302663026630266302663025620246202362022620206201e6201c6101b610196101761016610
000300001a230192301923019630186301863018620176201662015620146201362011610116100f6100e6000e600000000000000000000000000000000000000000000000000000000000000000000000000000
000400002b1302913025130221200c1200d1300e1301013011130131301613017130181301a1401e1401f14022140251502a1502f150321503315037100391003b10000000000000000000000000000000000000
000300001a6301863016630156301362013620126201162011620116201612017120191201c1201e1201d1201f120201202112000000000000000000000000000000000000000000000000000000000000000000
000400001b0501d0501f06021060210702207023070240602606028060290602a0602c0502e05033050340502a0402d0403003034030390203a0203202034020380103b01025000280002b0002d0003100037000
00030000146101161011610102100f210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000021052210021e0521e0021c0571c0521e0571e05719057190521c0522105228052280521900031000350003a0003d0003f000130001400016000190001b0001f000230002700027000260000000000000
011a00002d0521a0001c0002a050280501a000210521d000250501d000230501d00028050280002505031000210523a0003d0001e05019050140001c0521c0021b000210501e0502700028052280522a00000000
011a001000100211501915000100001001c1500010021150001001e1500010017150001001c1501c1001e1501e100001000010000100001000010000100001000010000100001000010000100001000010000100
011a0010091500b15006150041000415006150091500b1500b150001000d150001001015012150121500010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011a00100060321653216530060317653006032a6532a6531d6530060316653006031d6031d6531c6530060300603006030060300603006030060300603006030060300603006030060300603006030060300603
011a0000091520b1000610006150041500415009150091520b1020b1520d1000d1500d150121001015200100091500010000100101520915200100041500415009150001000d1520010010150101501015000100
001a0000006033f6233f6230060317603006033f6232a6031d603006033f623006031d6031d6033f623006030060321623216230060317633006032a6332a6331d6330060316633006031d6331d6531c65300603
011a00001c0521a0001c0001e05021050210501c0521d0001e0501d0001c0501905015042150421503215032210023a0003d0001e00019000140001c0021c0021b000210001e0002700028002280022a00000000
011a000009150091500415004152041000615004150041500915009150061520d10004152041521010200100091000010000100101020910200100041000410009100001000d1020010010100101001010000100
011a0000091032165321653006031d6031d603166531c6531d6030f65313603176531d6030f6531c603006032165321653216030060317603006032a6032a6031d6030060316603006031d6031d6031c60300603
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 0f 10 43 44
03 0b 0c 0d 0e
04 11 12 13 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
