pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--rymdhulk
--by mikael brassman ‚

function _init()
 cls()
 t=0
 debug,winds,floats,fog,entities,heroes={},{},{},{},{},{}
 static_camera=false
 map_max_dim=40
 reset_fog()

 moves=explode("4,1,0;2,-1,0;1,0,1;3,0,-1") --dir,dx,dy
 
 fog_octets=explode("3,5,7,2;0,2,4,5;0,1,6,4;1,3,6,7") --n;e;s;w
 dirx=split("-1,1,0,0,1,1,-1,-1")
 diry=split("0,0,-1,1,-1,1,1,-1")
 dir_opposite=split("2,1,4,3")

 level=0
 level_data={
  -- num_rooms, num_chests, num_eggs, num_mob2, num_mob3
  split("6,4,5,1,0"),
  split("10,6,3,4,0"),
  split("10,8,6,4,2"),
  split("10,6,10,2,4"),
 }

 items=split("stim pack,ammo mag.,meatballs,tetra mag")
 items_short=split("STIM,AMMO,MEATBALLS,TETRA")
 inv_descr={
  split("heal 1 hp. use,sreloads weapon,raise max hp +1,raise max ammo +1"),
  split("swedish tiger blood,lasers use bullets?!,w. ball bearings,by folding space")
 }

 inv=split("0,0,0,0")

 mob_name=split("egg,hugger,critter,xenomorph")
 mob_hp=split("1,1,2,4")
 mob_moves=split("0,1,1,2")
 mob_listen=split("0,5,10,20")
 mob_start_frame=split("200,202,212,217")
 mob_frames=split("1,3,4,4")
 mob_kill_frame=split("201,205,216,216")
 mob_start_head_frame=split("0,0,0,233")
 mob_head_frames=split("0,0,0,1")
 laser_cols=split("8,9,10,6,5")

 hero_colors=split("4,7,8,9,10,11,12,14")
 hero_names=split("algot,axted,billy,bror,brimnes,ektorp,eket,delaktig,galant,gistad,gurli,gersby,hult,havsta,hemnes,hejne,ivar,jonaxel,kallax,kivik,lack,lommarp,lankmoj,lerboda,lurvig,lidhult,laiva,liatorp,metod,morliden,nockeby,oxberg,omar,poang,pivring,ringhult,stursk,skynke,skultorp,tisken,tiphede,ullvide,voxtorp,vimle,viltorp,yngvar,zamioculcas")
 --head front
 anim_hero_hf=split("208,209,210,211")
 --head back
 anim_hero_hb=split("192,193,194,195")
   
 --body front
 anim_hero_bf=split("240,241,242,243")
 --body back
 anim_hero_bb=split("224,225,226,227")
 -- direction arrows -- for each: sprite,offsetx,offsety,dx,dy
 dirs=explode("196,0,-10,0,1;197,8,0,-1,0;198,0,8,0,-1;199,-8,0,1,0")
 

 wall_sig=split("251,233,253,84,146,80,16,144,112,208,241,248,210,177,225,120,179,0,124,104,161,64,240,128,224,176,242,244,116,232,178,212,247,214,254,192,48,96,32,160,245,250,243,249,246,252")
 wall_msk=split("0,6,0,11,13,11,15,13,3,9,0,0,9,12,6,3,12,15,3,7,14,15,0,15,6,12,0,0,3,6,12,9,0,9,0,15,15,7,15,14,0,0,0,0,0,0")
 crv_sig=split("255,214,124,179,233")
 crv_msk=split("0,9,3,12,6")
 cam_shake=0
 cam_int=10
 cam_off_x=0
 cam_off_y=0
 
 --map_debug=true
 --if map_debug then
 --   roll_heroes()
 --   uncover_fog(0,0,map_max_dim,map_max_dim)
 --   _upd=map_update
 --   _drw=map_draw
 --else
 reset_game()
 --end
end

function _update60()
 update_floats()
 update_windows()
 update_buttons()
 if #lasers > 0 then
  update_pew_pew()
 else
  _upd()
 end
 t+=1
 if shero_wind then
  update_hero_window()
 end
end

btnb={0,0,0,0,0,0}
btn_s={}--short-press
btn_l={}--long-press
btn_p={}--pressed
function update_buttons()
 -- update button buffer
 for i=1,#btnb do
   if btn(i-1) then
     -- when pressed
     btnb[i]+=1
     btn_p[i]=true
     
     if btnb[i] > 15 then
       -- when pressing long
       btn_l[i]=true
       btnb[i]=0
     end
   elseif btnb[i] >= 1 and not btn_l[i] then
     -- when released short
     btn_s[i]=true
     btnb[i]=0
   else
    -- reset
    btn_l[i]=false
    btn_s[i]=false
    btn_p[i]=false
    btnb[i]=0
   end
 end
end

is_fading,fade_val,fade_dir,fade_y,fade_x = false,0,0,-1,0
function _draw()
 _drw()
 draw_windows()
 draw_title()
 if cam_shake>=0 then
  cam_shake-=1
 end
 -- fade
 if is_fading then
  rectfill(0,0,128,fade_y,0)
  rectfill(0,128,128,128-fade_y,0)
  line(fade_x,fade_y,128-fade_x,fade_y,7)
  line(fade_x,128-fade_y,128-fade_x,128-fade_y,7)
 end
 -- debug
 if debug != nil then
  camera()
  for i=1,#debug+1 do
   if debug[i] != nil then
    print(debug[i],2,8*i+2,8)
   end
  end
 end
end

function update_fade(next, keep_fade)
 return function()
  fade_val += fade_dir
  if fade_val >= -0.2 and fade_val <= 2.2 then
   fade_y = lerp(0,64,mid(0,fade_val,1))
   fade_x = lerp(0,64,mid(0,fade_val-1,1))
  else 
   is_fading=keep_fade
   _upd = next or game_update
  end
 end
end
function fade_in(next)
 sfx(14)
 is_fading,fade_val,fade_dir=true,2,-0.1
 _upd = update_fade(next, false)
end
function fade_out(next)
 sfx(13)
 is_fading,fade_val,fade_dir=true,0,0.1
 _upd = update_fade(next, true)
end

-->8
--tools

function setup_game()
  sheroidx=1
  shero=heroes[sheroidx]
  if not shero_wind then
    shero_wind=
      add_window(1,1,50,{""})
  end
  if not shero_hp_wind then
    shero_hp_wind=add_window(51,1,20,{""})
  end
  if not shero_ammo_wind then
    shero_ammo_wind=add_window(71,1,32,{""})
  end
  if not seen_wind then
    seen_wind=add_window(103,1,23,{""})
    seen_wind.icon=252
  end
  did_win=false
end

function setup_next_level(keep_level,do_fade)
 entities={}  
 if not keep_level then
   level+=1
 end
 if level>#level_data then
  did_win=true
  setup_game_over()
  return
 end
 reset_heroes()
 setup_game()
 create_map()
 update_fog()
 if do_fade then
  fade_in(do_backoff(game_update))
 else
  do_backoff(game_update)
 end
end

function reset_game(start_level)
 seen_enemies={}
 inv={1,1,0,0}
 roll_heroes()
 level=start_level == nil and 0 or start_level
 setup_next_level(true)
 kills=0
 _drw=game_draw 
 _upd=level>0 and game_update or title_update
end

function roll_heroes()
 heroes={}
 shuffle(hero_colors)
 shuffle(hero_names)
 for i=1,3 do
  spawn_hero(
   0,
   0,
   hero_colors[i],
   hero_names[i]
  )
 end
end

function setup_game_over()
 shero_wind.visible=false
 set_shero_wind_hidden(true)
 do_backoff(ko_update)
 _drw=ko_draw
end

function create_map()
 reset_fog()  
 if level==0 then
  -- intro
  copy_map(112,0,13,10,0,0)
  copy_map(120,3,6,1,0,5)
  uncover_fog(0,0,6,6)
  place_heroes({x=2,y=4,w=3,h=1})
  -- debug mob on intro
  --spawn_mob(4,7,1)
  --spawn_mob(7,9,4)
 elseif level>=1 then
  gen_map(level_data[level])
 end
end

function all_exit()
  for h in all(heroes) do
    if is_active(h) then
      return false
    end
  end
  return true
end
function all_dead()
  for h in all(heroes) do
    if not h.dead then
      return false
    end
  end
  return true
end
function reset_heroes()
 htail={}
 for h in all(heroes) do
  h.exit=false
  if h.dead then
   del(heroes,h)
  else
   add(entities,h)
   add(htail,h)
  end
 end
end


function pretty_tiles()
  for x=1,map_max_dim do
    for y=1,map_max_dim do
      local tx,ty=x-1,y-1
      local tile=mget(tx,ty)
      -- is a wall
      if fget(tile,0) then
        local tsig=tilesig(tx,ty)
        for i=1,#wall_sig do
          if bcomp(tsig,wall_sig[i],wall_msk[i]) then
            mset(tx,ty,i+15)
          end
        end
        local t = mget(tx,ty+1)
        if is_passable(tx,ty+1) and t >= 80 then
          mset(tx,ty+1,t+1)
        end
      end
    end
  end
end

function bcomp(sig,match,mask)
  local mask=mask and mask or 0
  return sig|mask == match|mask
end

prev_seen=0
function update_hero_window()
  local cols=shero_wind.cols or {}
  shero_wind.texts[1] = shero.name
  cols[1] = shero.c
  shero_hp_wind.texts[1] = "HP "..shero.hp
  shero_ammo_wind.texts[1] = "AMMO "..shero.ammo
  if prev_seen < #seen_enemies then
   sfx(16)
  end
  prev_seen = #seen_enemies
  seen_wind.texts[1] = #seen_enemies
  seen_wind.bg = #seen_enemies > 0 and 8 or nil
end

function set_shero_wind_hidden (b)
  shero_wind.hidden=b
  shero_hp_wind.hidden=b
  shero_ammo_wind.hidden=b
  seen_wind.hidden=b
end

function spawn_hero(tx,ty,c,name)
  local hero={
    etype="hero",
    name=name,
    tx=tx,
    ty=ty,
    --tile x and y     
    ox=0,
    oy=0,
    -- offset x and y
    cur_dur=0,
    tot_dur=0,
    -- animation timers (durations)
    danger=true,
    -- is dangerous (to aliens)
    c=c,
    --color
    dead=false,
    draw=draw_hero,
    d=3,
    animate=false,
    flip=true,
    hb_p=3+rnd(5),
    --headbob-period
    hb_o=rnd(12),
    --headbob-offset
    hb_ox=0,
    hb_oy=0,
    flash=0,
    exit=false,
    kill_frame=244,
    hp=3,
    max_hp=3,
    ammo=5,
    max_ammo=5,
  }
  add(heroes,hero)
  add(entities,hero)
  return hero
end

function spawn_mob(tx,ty,no)
  local mob = {
    etype="mob",
    no=no,
    name=mob_name[no],
    danger=no>1 and true or false,
    -- heroes won't auto fire on eggs
    tx=tx,
    ty=ty,
    ox=0,
    oy=0,
    c=2,
    animate=true,
    flip=false,
    draw=draw_mob,
    hp=mob_hp[no],
    max_hp=mob_hp[no],
    frames=make_range(mob_start_frame[no],mob_frames[no]),
    head_frames=make_range(mob_start_head_frame[no],mob_head_frames[no]),
    kill_frame=mob_kill_frame[no],
    max_moves=mob_moves[no],
    dead=false,
    exit=false,
    flash=0,
    hb_p=3+rnd(5),
    hb_o=rnd(12),
    hb_ox=1,
    hb_oy=2,
    --headbob-period
    --headbob-offset,
    hearing_radius=mob_listen[no]
  }
  add(entities,mob)
  return mob
end

function shuffle(t)
  -- fisher-yates
  for i=#t,1,-1 do
    local j=flr(rnd(i)) + 1
    t[i],t[j] = t[j],t[i]
  end
  return t
end

function lerp(
  a, -- target
  b, -- source
  t  -- percent 0.0-1.0
)
  return (1-t)*a + t*b
end

function is_opaque(x,y)
  if not in_bounds(x,y) then
    return true
  end
  
  local tile=mget(x,y)
  if fget(tile,1) then
    return true
  end
  for i=1,#heroes do
    local h = heroes[i]
    if 
      i != sheroidx and
      h.tx == x and
      h.ty == y
    then
      return true
    end
  end
  return false
end

function is_passable(x,y)
 return in_bounds(x,y) and not flag_at(x,y,0)
end
function is_walkable(x,y)
 return is_passable(x,y) and not flag_at(x,y,5)
   or flag_at(x,y,6)
end
function is_placeable(x,y)
 return is_walkable(x,y) and entity_at(x,y) == nil and not flag_at(x,y,1)
end

function entity_at(tx,ty)
  for entity in all(entities) do
    if entity.tx==tx and entity.ty==ty then
      return entity
    end
  end
  return nil
end

function flag_at(tx,ty,f)
  return fget(mget(tx,ty),f)
end

function open_door(tx,ty)
  mset(tx,ty,6)
  sfx(6)
end

function open_chest(tx,ty)
  mset(tx,ty,12)
  local r=flr(rnd(#items)+1)
  add_float(items_short[r],tx,ty,7,50)
  inv[r]+=1
  sfx(6)
end

-- common comparators
function  ascending(a,b) return a<b end
--function descending(a,b) return a>b end

-- a: array to be sorted in-place
-- c: comparator (optional, defaults to ascending)
-- l: first index to be sorted (optional, defaults to 1)
-- r: last index to be sorted (optional, defaults to #a)
function qsort(a,c,l,r)
    c,l,r=c or ascending,l or 1,r or #a
    if l<r then
        if c(a[r],a[l]) then
            a[l],a[r]=a[r],a[l]
        end
        local lp,rp,k,p,q=l+1,r-1,l+1,a[l],a[r]
        while k<=rp do
            if c(a[k],p) then
                a[k],a[lp]=a[lp],a[k]
                lp+=1
            elseif not c(a[k],q) then
                while c(q,a[rp]) and k<rp do
                    rp-=1
                end
                a[k],a[rp]=a[rp],a[k]
                rp-=1
                if c(a[k],p) then
                    a[k],a[lp]=a[lp],a[k]
                    lp+=1
                end
            end
            k+=1
        end
        lp-=1
        rp+=1
        a[l],a[lp]=a[lp],a[l]
        a[r],a[rp]=a[rp],a[r]
        qsort(a,c,l,lp-1       )
        qsort(a,c,  lp+1,rp-1  )
        qsort(a,c,       rp+1,r)
    end
    return a
end

function zcomp(a,b) return a.ty<b.ty end

function zsort_entities() qsort(entities, zcomp) end

-- init array
function init_arr(w,h,d)
  local d=d or 0
  local a={}
  for x=0,w-1 do
    a[x+1]={}
    for y=0,h-1 do
      a[x+1][y+1]=d
    end
  end
  return a
end
function init_arr_1d(w,d)
  local d=d or 0
  local a={}
  for x=0,w-1 do
    add(a, d)
  end
  return a
end

function in_bounds(x,y)
  return x >= 0 and y >= 0 and x < 127 and y < 127
end

function tilesig(x,y)
 local sig,digit=0
 for i=1,8 do
  local dx,dy=x+dirx[i],y+diry[i]
  --’
  digit=is_passable(dx,dy) and 0 or 1
  sig|=digit<<8-i
 end
 return sig
end

function tilesigarray(sig,arr,marr)
  for i=1,#arr do
    if bcomp(sig,arr[i],marr[i]) then return i end
  end
  return 0
end

-- splits 2 dim array
function explode(str)
  local a = split(str, ";")
  for i=1,#a do
   a[i]=split(a[i])
  end
  return a
end

function toval(_arr)
 local _retarr={}
 for _i in all(_arr) do
  add(_retarr,flr(tonum(_i)))
 end
 return _retarr
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end 
 print(_t,_x,_y,_c)
end
-- print center x
function oprintc(_t,_y,_c,_c2)
 oprint8(_t,64-flr((#_t*4)/2),_y,_c,_c2)
end

-- in-place reverse
function reverse(t)
  local n,i=#t,1
  while i<n do
    t[i],t[n]=t[n],t[i]
    i=i+1
    n=n-1
  end
  return t
end

function make_range(start,c)
 local t={}
 if c == 0 then
    return t
 end
 for i=0,c-1 do
   add(t,start+i)
 end
 return t
end


function get_diff(x0,y0,x1,y1)
  return x0-x1,y0-y1
end

function get_distance(x0,y0,x1,y1)
  local dx,dy=get_diff(x0,y0,x1,y1)
  return sqrt(dx*dx+dy*dy)
end

function get_manhattan(x0,y0,x1,y1)
  local dx,dy=get_diff(x0,y0,x1,y1)
  return abs(dx)+abs(dy)
end

function copy_map(sx,sy,w,h,tx,ty)
 for x=0,w do
   for y=0,h do
     mset(x+tx,y+ty,mget(sx+x,sy+y))
   end
 end
end

function fill_map(_x,_y,w,h,t)
 for x=0,w-1 do
   for y=0,h-1 do
     mset(x+_x,y+_y,t)
   end
 end
end
-->8
--updates, gameplay

function game_update()
 if ai_turn then
  ai_update()
  ai_turn=false
  return
 end
 if overwatch_turn then
  overwatch_update()
  overwatch_turn=false
  return
 end
 if all_dead() then
   setup_game_over()
   return
 end
 if all_exit() then
   fade_out(function() setup_next_level(false,true) end)
   return
 end
 if shero.dead==true then
  if any_button() then
    del(heroes,shero)
    switch_hero()
  end
  return
 end
 set_shero_wind_hidden(false)
 local d,strafing=shero.d,btn_p[6]
 for i=1,#moves do
   local m=moves[i]
   if btn_l[i] or btn_s[i] then
     if d!=m[1] and not strafing then
       turn_shero(m[1])
     else
       move_shero(m[2],m[3])
     end
   end
 end
 if btnp(4) then
   target_mode()
-- switch hero
 elseif btn_s[6] then
   switch_hero()
   sfx(0)
 end
end

function title_update()
 title_pos=0
 title_col=7
 set_shero_wind_hidden(true)
 for i=0,5 do
  if btnp(i) then
   introcount=0
   _upd=intro_update
  end
 end
 title_cam_off(1)
end

function title_cam_off(str)
 cam_off_y,cam_off_x=sin(time()*0.2)*3-4,sin(time()*0.1)*5+10
 cam_off_y*=str
 cam_off_x*=str
end

function intro_update()
 title_pos-=0.5
 introcount+=1
 title_cam_off(mid(0,(70-introcount)/70,1))
 if introcount == 80 then
   copy_map(112,5,6,1,0,5)
   _upd=game_update
   title_pos=nil
   update_fog()
   sfx(6)
   set_shero_wind_hidden(false)
 elseif introcount == 40 then
   copy_map(120,1,6,1,0,5)
   title_col=2   
 elseif introcount == 20 then
   title_col=4
 elseif introcount == 10 then
   title_col=6
 elseif introcount == 1 then
   cam_shake=35
   sfx(12)
 end
end

function target_mode()
 _upd=aim_update
 aimx=shero.tx
 aimy=shero.ty
 aiming=true
 sfx(8)
end

function aim_update()
 if tarwin==nil then
   tarwin=add_window(4,9,100,split(",,,"))
   update_tarwin()
   return
 end
 for i=1,4 do
  if btnp(i-1) then
   aimx=mid(0,aimx+dirx[i],map_max_dim)
   aimy=mid(0,aimy+diry[i],map_max_dim)
   update_tarwin()
  end
 end
 if btnp(4) then
   -- select
   if tentity == nil then
    return
   elseif tentity==shero then
    -- open inventory
    open_inventory()
    return
   elseif tentity.etype=="mob" and shero.ammo >= 1 then
    -- fire at enemy
     sfx(10)
     queue_pew_pew(shero,tentity)
     ai_turn=true
     shero.ammo-=1
     exit_aim()
   elseif tentity.etype=="hero" then
    switch_hero(tentity)
    open_inventory()
   end
 elseif btnp(5) then
   -- exit
   exit_aim()
   sfx(9)
 end
end

function open_inventory()
  sfx(8) 
  invwin=add_window(16,16,90,split(",,,"))
  invdescwin=add_window(16,#invwin.texts*8+18,90,split(","))
  invwin.cur=1
  invwin.cols[2]=5
  invwin.olabel="exit"
  aiming=true
  _upd=inventory_update
end

function inventory_update()
  for i=1,#inv do
    invwin.texts[i]=items[i].." "..inv[i]
    invwin.cols[i]=inv[i]>0 and 7 or 5
  end
  if shero.hp==shero.max_hp then
    invwin.cols[1]=5
  end
  if shero.ammo == shero.max_ammo then
    invwin.cols[2]=5
  end
  invdescwin.texts[1]=inv_descr[1][invwin.cur]
  invdescwin.texts[2]=inv_descr[2][invwin.cur]
  
  if btnp(2) then
    wincur(invwin,-1)
  elseif btnp(3) then
    wincur(invwin,1)
  elseif btnp(5) then
    exit_inv()
    sfx(9)
  elseif btnp(4) then
    if invwin.cols[invwin.cur] == 5 then
      return
    end
    if invwin.cur==1 then
     -- stim pack
     shero.hp=shero.max_hp
    elseif invwin.cur==2 then
     -- reload ammo
     shero.ammo=shero.max_ammo
    elseif invwin.cur==3 then
     -- meat balls
     shero.max_hp+=1
     shero.hp+=1
    elseif invwin.cur==4 then
     -- tetra
     shero.max_ammo+=1
     shero.ammo+=1
    end
    inv[invwin.cur]-=1
    sfx(10)
    exit_inv()
  end
end

function exit_inv()
  invwin.close=4
  invwin=nil
  invdescwin.close=4
  invdescwin=nil
  do_backoff(aim_update)
  update_tarwin()
end

function exit_aim()
   aiming=false
   tarwin.close=4
   tarwin=nil
   do_backoff(game_update)
end

function do_backoff(next_upd, dur)
 next_upd=next_upd or _upd
 function cb()
  if any_button() then
   return
  end
  _upd=next_upd
 end
 _upd=cb
end

function any_button()
 for i=0,5 do
  if btn(i) then
   return true
  end
 end
 return false 
end

function update_tarwin()
  local texts,cols=
    tarwin.texts,
    tarwin.cols
  tarwin.labelx="exit"
  tarwin.labelo=nil
  --reset
  for i=1,4 do
	  texts[i]=""
	  cols[i]=i==1 and 7 or 6
  end
  if fog[aimx+1][aimy+1] == 0 then
    return
  end
  local found=entity_at(aimx,aimy)
  tentity=found
  if found then
    if found.etype=="hero" then
      texts[1]=found.name
      cols[1]=found.c
      texts[2]="hp:   "..found.hp.."/"..found.max_hp
      texts[3]="ammo: "..found.ammo.."/"..found.max_ammo
      texts[4]=on_overwatch(found) and "on overwatch" or ""
      tarwin.labelo=found!=shero and "sel & open menu" or "open menu"
    elseif found.etype=="mob" then
      texts[1]=found.name
      texts[2]="hp: "..found.hp.."/"..found.max_hp
      tarwin.labelo="fire"
    end
    return
  end
  found=mget(aimx,aimy)
  if found==4 then
    texts[1]="stairs"
    texts[2]="will take you to the"
    texts[3]="next level"
  elseif found==5 or found==6 then
    texts[1]="door"
    texts[2]="it is heavy but"
    texts[3]="hardly a push-over"
  else
    -- for debugging, show map tile index
    --texts[1]=found
  end
end

function on_overwatch(hero)
 return incl(htail, hero) != true and shero != hero
end

function switch_hero(hero)
 sfx(0)
 if hero then
  shero=hero
  sheroidx=findidx(heroes,hero)
  return
 end
 sheroidx =
   ((sheroidx)%#heroes)+1
 shero=heroes[sheroidx]
 -- update htail
 if not incl(htail, shero) then
  -- if selected hero is not in tail, recreate tail
  htail={shero}
 else
  -- make sure selected hero is first in tail 
  add(htail, del(htail, shero) ,1)
 end
 add_float("!",shero.tx,shero.ty,shero.c)
end

function findidx(t,item)
 for i=1,#t do
  if t[i]==item then
   return i
  end
 end
 return -1
end

function turn_shero(nd)
 if shero.exit or shero.dead then
   return
 end
 shero.d=nd
 if nd == 2 then shero.flip=false end
 if nd == 4 then shero.flip=true end
 sfx(2)
 update_fog()
end

function move_shero(dx,dy)
 if shero.exit or shero.dead then
  return
 end
 local tx,ty=shero.tx-dx,shero.ty-dy
 local target=entity_at(tx,ty)
 static_camera=false
 if target!=nil then
  local etype=target.etype
  if etype=="mob" then
   -- close quarters attack on mob
   atk(target)
   ai_turn=true
  elseif etype=="hero" then
   tap(target)
   ai_turn=true
  end
 elseif flag_at(tx,ty,5) then
  -- chest
  bounce_unit(shero,tx,ty,true)
  open_chest(tx,ty)
  ai_turn=true
 elseif flag_at(tx,ty,6) then
  -- open door
  open_door(tx,ty)
  bounce_unit(shero,tx,ty,true)
  update_fog()
  ai_turn=true
 elseif is_passable(tx,ty) then
  -- oscar tango mike
  local isexit=flag_at(tx,ty,7)
  sfx(isexit and 7 or 1)
  function upd_ce() --check exit
    if isexit then
      for h in all(htail) do
        del(entities,h)
        h.exit=true
      end
      if #heroes > 0 then
        switch_hero(heroes[1])
      end
      update_fog()
    end
    ai_turn=true
    _upd=game_update
  end
  move_units(htail,tx,ty,upd_ce,isexit)
 else
  -- impassable
  sfx(3)
  bounce_unit(shero,tx,ty)
 end
end

function offset_unit(unit,ox,oy)
  unit.ox=ox
  unit.oy=oy
end

function bounce_unit(unit,
  tx,ty,dur,use_static_camera
)
  static_camera=use_static_camera
  queue_bounce(unit,tx,ty,7)
  perform_move()
end

function move_units(units,tx,ty,n_upd,is_exit)
  local dx,dy=units[1].tx-tx,units[1].ty-ty

  for i=#units,1,-1 do
    local unit,nunit = units[i],units[i-1]
    local targetx,targety,dur=
      is_exit and tx or nunit and nunit.tx or tx,
      is_exit and ty or nunit and nunit.ty or ty,
      is_exit and 10*i or 6 
    queue_move(unit,targetx,targety)
  end
  perform_move(n_upd,is_exit)
end

moving={}
-- entity, targetx, targety, duration in frames
function queue_move(e,tx,ty,dur)
  e.ox,e.oy,e.tx,e.ty,e.cur_dur,e.tot_dur=
    (e.tx-tx)*8,
    (e.ty-ty)*8,
    tx,ty,0,dur or 7
  add(moving, e)
end
function queue_bounce(e,tx,ty,dur)
  e.ox,e.oy,e.cur_dur,e.tot_dur=(e.tx-tx)*2,(e.ty-ty)*2,0,dur
  add(moving,e)
end
function perform_move(n_upd,remove_on_end)
  function walk_update()
    for unit in all(moving) do
      if unit.cur_dur == 0 then
        unit.sox,unit.soy=unit.ox,unit.oy
      end
      local t= mid(0,unit.cur_dur/unit.tot_dur,1)
      unit.ox=lerp(unit.sox,0,t)
      unit.oy=lerp(unit.soy,0,t)
      if t==1 then 
        del(moving,unit)
        if remove_on_end then
            del(entities,unit)
        end
        unit.animate=false
      else
        unit.animate=true
      end
      unit.cur_dur+=1
    end
    if #moving == 0 then
      zsort_entities()
      _upd=n_upd or game_update
    end
    update_fog()
  end
  _upd=walk_update
end

function atk(target)
  do_backoff()
  target.hp-=1
  target.flash=50
  add_float("-1",target.tx,target.ty,8)
  if target.hp == 0 then
    del(entities,target)
    mset(target.tx,target.ty,target.kill_frame)
    target.dead=true
    sfx(4)
  else
    sfx(5)
  end
  if target.dead then
   if target.etype=="hero" then
    del(htail, target)
   elseif target.etype=="mob" and target.no==1 then
    spawn_huggers(target)
   end
  end
end

function tap(target)
  do_backoff()
  local msg="tap"
  if incl(htail, target) then
   msg="stay"
   del(htail, target)
  else
   add(htail, target)
  end
  add_float(msg,target.tx,target.ty,target.c)
end

function incl(arr,item)
 for i in all(arr) do
  if i == item then
   return true
  end
 end
 return false
end

-->8
--draw


function follow_unit(unit)
  local _x,_y=unit.tx*8-64,unit.ty*8-64
  if aiming then
    _x,_y=aimx*8-64,aimy*8-64
  elseif not static_camera then
    _x,_y=_x+unit.ox,_y+unit.oy
  end
  if cam_shake>0 then
   _x+=flr(rnd(cam_int)-cam_int/2)
   _y+=flr(rnd(cam_int)-cam_int/2)
  end
  _x+=cam_off_x
  _y+=cam_off_y
  camera(_x,_y)  
end

function game_draw()
 cls()
 if shero.dead then
   draw_dead_screen()
 else
	  follow_unit(shero)
	  draw_map()
	  for i=1,#entities do
	    local e = entities[i]
	    e.draw(e)
	  end
	  for i=1,#heroes do
      local h = heroes[i]
	    draw_direction(h)
	  end
	  draw_reticule()
	  draw_pew_pew()
	  draw_floats()
   camera()
	end
end

noise_cols={0,1,5,6,7}
function draw_dead_screen()
 cls()
 local size=128/4
 for x=0,size do
  for y=0,size do
   local _x,_y=x*4,y*4
   rectfill(_x,_y,_x+4,_y+4,rndarr(noise_cols))
  end  
 end
 oprintc("signal lost",60,8,0)
end

function rndarr(t)
 return t[flr(rnd(#t) + 1)]
end

function draw_title()
  if title_pos then
    oprintc("rymdhulken",
      47+title_pos,
      title_col
    )
  end
  if title_pos==0 then
    oprintc(
      "press any button",
      87,5)
  end
end

function draw_map()
  for x=1,map_max_dim do
    for y=1,map_max_dim do
      local f=fog[x][y]
      if aiming and f>1 then
        f=aimx==x-1 and aimy==y-1 and 2 or 1
      end
      pal()
      pal(2,0)
      if f < 2 then
        palswap(f>0 and 1 or 0)
      end
      local px,py=x-1,y-1
      map(px,py,px*8,py*8,1,1)
    end
  end
  pal()
end

function palswap(to)
  pal(5,to)
  pal(6,to)
  pal(9,to)
end

function draw_hero(h)
  local px,py,anim_body,anim_head=h.tx*8+h.ox,h.ty*8+h.oy,anim_hero_bf,anim_hero_hf
  if h.exit then
     return
  elseif h.d == 1 then
    anim_body,anim_head = anim_hero_bb,anim_hero_hb
  end
  for t in all(h.targets) do
   if is_active(t) then
    fillp(flr(time()*5) % 2 == 0 and 0b1010010110100101 or 0b0101101001011010)
    line(px+4,py+4,t.tx*8+4,t.ty*8+4,8)
    fillp()
   end
  end
  draw_entity(
   h,
   h.animate and get_frame(anim_body,h.hb_o) or anim_body[1],
   h.animate and get_frame(anim_head) or anim_head[1]
  )
end

function draw_mob(m)
  if in_fog(m.tx,m.ty) then
    return
  end
  draw_entity(m,
   get_frame(m.frames,0,5),
   #m.head_frames > 0 and get_frame(m.head_frames,0,5)
  )
end

function draw_entity(e,body_frame,head_frame)
  local px,py=e.tx*8+e.ox,e.ty*8+e.oy
  palt(0,false)
  pal(9,e.c)
  if e.flash>0 then
    e.flash -= 1
    if (e.flash\3)%2==0 then
      pal(5,8)
      pal(9,8)
      pal(15,8)
    end
  end
  spr(body_frame,px,py,1,1,e.flip)
  if head_frame then
   palt(0,true)
   local bob=flr(sin(time()/e.hb_p+e.hb_o))
   spr(head_frame,px+e.hb_ox,py-1+bob-e.hb_oy,1,1,e.flip)
  end
  pal()
end

function draw_direction(h)
  if not is_active(h) then
   return
  end
  local d=dirs[h.d]
  local px,py=
    h.tx*8+h.ox,
    h.ty*8+h.oy
  local c=shero==h and h.c or 5
  local dx,dy=h.tx-d[4],h.ty-d[5]
  local obs=entity_at(dx,dy)
  local show=1
  if obs then
    show=sin(time()*2)
  end
  
  pal(5,c)
  if show>0 then
	  spr(
	    d[1],
	    px+d[2],
	    py+d[3]
	  )
  end
  pal()
end

function get_frame(anim,offset,speed)
  local off=offset or 0
  local speed=speed or 2
  local frame=
  	 flr(t/speed+off)%#anim+1
  return anim[frame]
end

function draw_reticule()
  if not aiming then
    return
  end
  local blink=flr(sin(time()*1.5))
  if blink >= 0 then
   spr(254,aimx*8+1,aimy*8+1)
  end
end

-- x0,y0,x1,y1,target_to_atk
lasers={}
function queue_pew_pew(from, to)
  add(lasers,{from,to})
  -- enemies that can hear you will come for you
  ai_hear(to.tx,to.ty)
end

function update_pew_pew()
 if laser_cur!=nil then
  laser_cur+=1
 else
  laser_cur=0
  local b,t=lasers[1][1],lasers[1][2]
  laser_bx,laser_by,laser_tx,laser_ty=
  b.tx*8+4,b.ty*8+4,t.tx*8+4,t.ty*8+4
  atk(t)
  sfx(11)
 end
 if laser_cur==#laser_cols*3 then
  laser_cur=nil
  del(lasers,lasers[1])
  if #lasers==0 then
   _upd=game_update
   return
  end
 end
end

function draw_pew_pew()
  if laser_cur!=nil then
	  line(
	    laser_bx,laser_by,laser_tx,laser_ty,
	    laser_cols[flr(laser_cur/3)]
	  )
  end
end

-- ko
function ko_update()
  if any_button() then
    reset_game()
  end
end
function ko_draw()
 cls()
 is_fading=false
 local lines={}
 if did_win then
    add(lines, "mission completed")
    add(lines, "thanks for playing")
 else
    add(lines, "it's game over man!")
    add(lines, "you reached level "..level)
 end
 for i=1,#lines do
    oprintc(lines[i], 42+(8*i), i>1 and 6 or 7, 1)
 end
end

-->8
-- ui

function add_float(text,x,y,col,duration,puny)
  add(floats,{
    x=x*8,
    y=y*8,
    col=col,
    text=text,
    puny=puny or false,
    oy=0,  --offset y
    ty=4, --target y
    t=duration or 16   --timer
  })
end

function update_floats()
 for f in all(floats) do
   if f.oy < f.ty then
     f.oy+=2
   end
   if f.t==0 then
     del(floats,f)
   else
     f.t-=1
   end
 end
end

function draw_floats()
 for f in all(floats) do
   local text=f.text
   oprint8(text,f.x-flr(#text*4/2)+4,f.y-f.oy,f.col,0)
 end
end

function add_window(x,y,w,texts,cols)
  local w={
    x=x,
    y=y,
    texts=texts,
    cols=cols or {},
    w=w,
    vh=0,       --visual height
    mh=#texts*8 --max height
  }
  add(winds,w)
  return w
end

function update_windows()
  for w in all(winds) do
    if w.close!=nil then
      -- close window
      w.st=w.cs or flr(w.vh/w.close)
      w.close-=1
      w.vh=max(0,w.vh-w.st)
      if w.close<0 then
        del(winds,w)
      end
    elseif w.vh<w.mh then
      -- open window
      w.st=w.st or flr(w.mh/4)
      w.vh=min(w.mh,w.vh+w.st)
    end
  end
end

function draw_windows()
 for w in all(winds) do
  if not w.hidden then
   local x1,y1,texts,cols=w.x,w.y,w.texts,w.cols
   local x2,y2=x1+w.w,y1+w.vh+2
   rectfill(x1,y1,x2,y2,0)
   rectfill(x1+1,y1+1,x2-1,y2-1,7)
   rectfill(x1+2,y1+2,x2-2,y2-2,w.bg or 1)
   -- draw texts (omit outside)
   for i=0,min(flr(w.vh/8-1),#texts-1) do
    local col,x,y=7,x1+3,y1+3+8*i
    if cols!=nil and cols[i+1]!=nil then
     col=cols[i+1]
    end
    if w.cur or w.icon then
     x+=10
    end
    if w.icon then
     spr(w.icon,x1+3,y1+2)
    end
    print(
     texts[i+1],
     x,
     y,
     col
    )
    if w.cur == i+1 then
     spr(255,x-8+sin(time()),y)
    end
   end
   if w.labelo then
    oprint8("Ž",x1+1,y2,6,0)
    oprint8(w.labelo,x1+10,y2,6,0)
   end
   if w.labelx then
    local lwidth=#(w.labelx)*3+3
    oprint8("—",x2-lwidth-9,y2,6,0)
    oprint8(w.labelx,x2-lwidth,y2,6,0)
   end
  end
 end
end

function wincur(w,dif)
  if w.cur == nil then
    w.cur=dif
    return
  end
  w.cur=(w.cur+dif-1)%(#w.texts)+1
end

-->8
--fog-of-war, los

function reset_fog()
  fog=init_arr(map_max_dim,map_max_dim,0)
end

-- updates fog of war and line of sight to targets
function update_fog()
  -- reset 2 (uncovered) to 1
  for x=1,#fog do
    local fogx=fog[x]
    for y=1,#fogx do
      if fogx[y] == 2 then
        fogx[y] = 1
      end
    end
  end
  seen_enemies={}
  local h
  function on_uncover(mapx,mapy)
   uncover_fog(mapx,mapy,1,1)
   local e = entity_at(mapx,mapy)
   if e and e.etype=="mob" and e.danger then
    add(h.targets,e)
    if findidx(seen_enemies, e) < 0 then
     add(seen_enemies, e)
    end
   end
  end
  -- determine visible
  for i=1,#heroes do
    h=heroes[i]
    h.targets={}
    if not h.exit then
	    for x=-1,1 do
	     for y=-1,1 do
	      local _x = mid(0,#fog,h.tx+x)
       local _y = mid(0,#fog,h.ty+y)
       on_uncover(_x,_y)
	     end
	    end
	    local dir_oct=fog_octets[h.d]
     for i=1,#dir_oct do
      cast(h.tx,h.ty,1,0,1,dir_oct[i],on_uncover)
	    end
    end
  end
end

function uncover_fog(x,y,w,h)
  for _x=1,w do
   for _y=1,h do
    fog[x+_x][y+_y]=2
   end
  end
end

function in_fog(x,y)
  return fog[x+1][y+1]<2
end

-- shadow cast
-- recursive octant
function cast(ox,oy,d,lo_slp,hi_slp,oct,uncover_cb)
  -- distance from unit
  -- to map xy
  -- flips/transposes per octant
  function dhtoxy(d,h)
    local x,y=ox,oy
    if oct&0x1>0 then d=-d end
    if oct&0x2>0 then h=-h end
    if oct&0x4>0 then
      return x+h,y+d
    end
    return x+d,y+h
  end
  
  if d>16 then
    return
  end
  local mapx,mapy,lo,hi,in_gap
  lo=flr(lo_slp*d+0.5)
  hi=flr(hi_slp*d+0.5)
  
  for h=lo,hi do
    mapx,mapy=dhtoxy(d,h)
    if not in_bounds(mapx,mapy) then
      return
    end
    uncover_cb(mapx,mapy)
    if is_opaque(mapx,mapy) then
      if in_gap then
        --reached end of gap
        cast(ox,oy,d+1,lo_slp,(h-0.5)/d,oct,uncover_cb)
      end
      lo_slp=(h+0.5)/d
      in_gap=false
    else
      in_gap=true
      if h==hi then
        --end of gap
        cast(ox,oy,d+1,lo_slp,hi_slp,oct,uncover_cb)
      end
    end
  end
end

-- line of sight
-- dda algorithm
-- returns cells along the LOS
--   or bool if flag is set
function los(x0,y0,x1,y1,flag)
  local dx,dy,t=x1-x0,y1-y0,{}
  local sx,sy=sgn(dx),sgn(dy)
  local ax,ay=abs(dx),abs(dy)
  local x,y=x0,y0
  local step=ax>=ay and ax or ay
  local sx,sy=dx/step,dy/step
  
  for i=1,step do
    local flx,fly=flr(x+0.5),flr(y+0.5)
    if flag!=nil then
      if flag_at(flx,fly,flag) then
        return false
      end
    end
    if i!= 1 then
      add(t,{flx,fly})
    end
    x+=sx
    y+=sy
  end
  if flag then
    return true
  end
  return t
end

function can_see(x0,y0,x1,y1)
  return los(x0,y0,x1,y1,1)
end
-->8
-- ai

function ai_update()
  for e in all(entities) do
    if e.etype=="mob" then
      do_ai(e)
    end
  end
  perform_move()
  overwatch_turn=true
  update_fog()
end

function ai_hear(x,y)
 for e in all(entities) do
  local d = get_distance(x,y,e.tx,e.ty)
  if e.etype=="mob" and d <= e.hearing_radius then
   e.last_seen={x,y}
  end
 end
end

function overwatch_update()
  for h in all(heroes) do
   do_overwatch(h)
  end
  update_fog()
end

function do_ai(e)
 local moves=e.max_moves
 for i=1,moves do
  local h=find_closest_entity(e, "hero")
  if h!=nil then
   e.last_seen={h.tx,h.ty}
  end
  if e.last_seen == nil then
   return
  end
  local path = find_path(e.tx, e.ty, e.last_seen[1], e.last_seen[2], is_walkable)
  if #path > 1 then 
   local _x,_y=path[1].x,path[1].y
   if flag_at(_x,_y,6) then
    open_door(_x,_y)
   else
    queue_move(e,_x,_y,in_fog(_x,_y) == false and 6 or 0)
   end
  elseif h!= nil then
   atk(h)
   e.last_seen=nil
   -- atk ends the ai turn
   return
  end
 end
end

function do_overwatch(h)
  if on_overwatch(h) and h.ammo >= 1 then
   local t = h.targets[1]
   if t then
     queue_pew_pew(h, t)
     h.ammo-=1
   end
  end
end

function find_closest_entity(from, etype)
 local preventity,prevdist
 for e in all(entities) do
  if e.etype == etype and e.danger and
    is_active(e) and
    can_see(from.tx,from.ty,e.tx,e.ty) then
   local dist=
      get_distance(from.tx,from.ty,e.tx,e.ty)
   if prevdist == nil or
     prevdist >= dist then
    preventity=e
    prevdist=dist
   end
  end
 end
 return preventity
end

function is_active(h)
  return h.dead == false and h.exit == false
end
-->8
-- procgen
function spawn_huggers(t)
  local cand,amount={},2
  for x=-1,1 do
    for y=-1,1 do
      add(cand,{x=t.tx+x,y=t.ty+y})
    end
  end
  shuffle(cand)
  for c in all(cand) do
    if amount == 0 then
      return
    end
    if is_placeable(c.x,c.y) then
        amount -= 1
        local m = spawn_mob(t.tx,t.ty,2)
        queue_move(m,c.x,c.y,4)
    end
  end
  perform_move()
end

function gen_map(data)
  -- clear map
  fill_map(0,0,map_max_dim+1,map_max_dim+1,2)
  yield()
  rooms={}
  
  local num_rooms,num_chests,num_eggs,num_mob2,num_mob3=
    data[1],data[2],data[3],data[4],data[5]

  local quad=map_max_dim\4
  local offsx,offsy=map_max_dim\2,map_max_dim\2
  generate_room(offsx,offsy,true)

  -- maze worm
  for i=1,num_rooms do
   local room = generate_room(offsx,offsy)
   yield()
   local j=i
   repeat
    worm_from(room, rooms[j])
    check_reach_start(room)
    j-=1
   until room.reach_start or j<1
  end

  -- place chests and mobs
  r=shuffle(get_all_placeable_tiles())
  for t in all(shuffle(get_all_placeable_tiles())) do
   if num_chests > 0 and mget(t.x,t.y) != 82 then
    mset(t.x,t.y,11)
    num_chests -= 1
   elseif num_eggs > 0 then
    spawn_mob(t.x,t.y,1)
    num_eggs -= 1
   elseif num_mob2 > 0 then
    spawn_mob(t.x,t.y,3)
    num_mob2 -= 1
   elseif num_mob3 > 0 then
    spawn_mob(t.x,t.y,4)
    num_mob3 -= 1
   end
  end
  pretty_tiles()
  place_exit()
end

function place_exit()
 local r,exit
 for _r in all(rooms) do
   if r == nil then
    r=_r
   elseif _r.reach_start and r.start_d <= _r.start_d then
    r=_r
   end
 end
 local exits=shuffle(get_all_placeable_tiles(r), true)
 for e in all(exits) do
  if next_to_door(e.x,e.y) == false then
   mset(e.x,e.y,4)
   return
  end
 end
end

function get_all_placeable_tiles(r)
 local t={}
 for x=(r and r.x or 1),(r and r.x+r.w or map_max_dim-2) do
  for y=(r and r.y or 1),(r and r.y+r.h or map_max_dim-2) do
   if is_placeable(x,y) then
    add(t, point(x,y))
   end
  end
 end
 return t
end

function next_to_room(x,y) 
 local s = tilesig(x,y)
 return tilesigarray(s,crv_sig,crv_msk) == 0
end

function next_to_door(x, y)
 for i=1,8 do
  if mget(x+dirx[i],y+diry[i]) == 5 then
   return true
  end
 end
 return false
end

function check_reach_start(room)
 if not room.reach_start then
  local p = find_path(room.x+1, room.y+1, startx, starty, is_walkable)
  if #p > 0 then
   room.reach_start=true
  end
 end
end

function place_heroes(room)
 for i=1,#heroes do
  local h=heroes[i]
  h.tx=room.x+((i-1)%room.w)
  h.ty=room.y+i\(room.w+1)
 end
end

function generate_room(offsx,offsy,is_start)
 local room={
  x=offsx,
  y=offsy,
  w=flr(rnd(2)+1)*flr(rnd(3))+2,
  h=flr(rnd(2)+1)*flr(rnd(3))+2,
  tile=80,
  carpet=flr(rnd(3))*2+80,
  reach_start=is_start,
  start_d=0
 }
 add(rooms,room)
 move_until_fit(room)
 carve_room(room)
 if is_start then
  place_heroes(room)
  startx,starty=room.x+1,room.y+1
 else
  room.start_d=get_manhattan(startx,starty,room.x,room.y)
 end
 return room
end

function carve_room(room)
  -- carve room
  fill_map(room.x,room.y,room.w,room.h,room.tile)
  -- carpet
  fill_map(room.x+1,room.y+1,room.w-2,room.h-2,room.carpet)
  -- carve doors
  local doors,ds,door=shuffle(get_cdoors(room)),{0,0,0,0}
  while #doors > 0 do
   door=deli(doors,1)
   if door.is_connected then
    ds[door.tile]+=1
    if ds[door.tile] == 1 then
     mset(door.x,door.y,5)
    end
   end
  end
end

function get_cdoors(room)
 local doors,rw,rh,p={},room.w,room.h
 function a(p) --add to output
   tsig=tilesig(p.x,p.y)
   if next_to_door(p.x,p.y) then return end
   add(doors,p)
   p.is_connected=bcomp(tsig,0b110000,0b1111) or bcomp(tsig,0b11000000,0b1111) 
 end
 for i=1,2 do
  for _y=0,room.h-1 do
   a(point(
    room.x+dirx[i]-2+((rw+3)*(i%2)),
    room.y+diry[i]+_y,
    i
   ))
  end
 end
 for i=3,4 do
  for _x=0,room.w-1 do
   a(point(
    room.x+dirx[i]+_x,
    room.y+diry[i]-2+((rh+3)*(i%2)),
    i
   ))
  end
 end
 return doors
end

function move_until_fit(room)
 local iter,lastd=0,rnddir(0)
 while iter<1000 and overlaps_floor(room) do
  if rnd(2) > 0.5 then
   lastd=rnddir(lastd)
  end
  room.x,room.y=
    mid(1, room.x+dirx[lastd], map_max_dim-room.w-1),
    mid(1, room.y+diry[lastd], map_max_dim-room.h-1)
  iter+=1
 end
end

function room_can_connect(room)
  for x=room.x,room.w do
    if is_floor(x, room.y-1) or
      is_floor(x,room.y+room.h+1) then
      return true
    end
  end
  for y=room.y,room.h do
    if is_floor(room.x-1, y) or
      is_floor(room.x+room.w+1,y) then
        return true
    end
  end
  return false
end 

function overlaps_floor(room) 
 local sx,sy=room.x,room.y
 if sx <= 0 or sy <= 0 then
  return false
 end
 for x=0,room.w-1 do
  for y=0,room.h-1 do
   if is_floor(x+sx,y+sy) then
    return true
   end
   for i=1,8 do
    if is_floor(x+sx+dirx[i],y+sy+diry[i]) then
     return true
    end
   end
  end
 end
 return false
end

function is_floor(x,y)
 local tile = mget(x,y)
 return fget(tile, 0) == false and fget(tile, 6) == false
end

function point(x,y,tile) return {x=x,y=y,tile=tile} end

function get_unconnected_door(room) 
 local doors = shuffle(get_cdoors(room))
 for d in all(doors) do
  local od = dir_opposite[d.tile]
  local nx,ny = d.x+dirx[od],d.y+diry[od]
  if d.is_connected != true and next_to_room(nx,ny) == false then
    return d,point(nx, ny)
  end  
 end
end

function is_carvable(x, y)
 return x > 1 and x < map_max_dim - 2 and y > 1 and y < map_max_dim - 2
   and not is_floor(x,y) and not next_to_room(x,y) or mget(x,y) == 82
end

function worm_from(room1, room2)
 local door1,start = get_unconnected_door(room1)
 local room2doors = get_cdoors(room2)
 if door1 != nil then
  local ps = find_path(start.x,start.y,room2.x,room2.y,
    is_carvable,
    function (p) 
     for d in all(room2doors) do
      if d.x == p.x and d.y == p.y then
       return true
      end
     end
    end,
    true
  )
  if #ps==0 then
   return
  end
  carve({door1,door2},5)
  carve({start},82)
  for p in all(ps) do
   carve({p},82)
  end
 end
end

function carve(ps,tile)
 for p in all(ps) do
  mset(p.x,p.y,tile)
 end
end

-- function load_prefab_room(p)
--  local _x,_y,w,h,tiles,doors = p[1],p[2],p[3],p[4],{},{}
--  for x=0,w-1 do
--   for y=0,h-1 do
--    local px,py=_x+x,_y+y
--    local tile=mget(px,py)
--    if fget(tile, 6) then --door
--     add(doors, point(x,y,tile))
--    else 
--     add(tiles, point(x,y,tile))
--    end
--   end
--  end
--  return {
--   tiles=tiles,doors=shuffle(doors),
--   x=0,y=0,w=w,h=h
--  }
-- end

function rnddir(prevd)
  local backd,d=dir_opposite[prevd]
  repeat
    d=flr(rnd(4))+1
  until backd != d
  return d
end

-- debugp={}
-- cr=nil
-- function map_update()
--  if cr and costatus(cr) != 'dead' then
--   coresume(cr)
--  end
--  for i=1,4 do
--   if btn(i-1) then
--    cam_off_x+=dirx[i]*2
--    cam_off_y+=diry[i]*2
--   end
--  end
--  if btnp(4) then
--   entities={}
--   debugp={}
--   level=(level%#level_data)+1
--   reset_heroes()
--   cr=cocreate(function() gen_map(level_data[level]) end)
--  end
-- end

-- function map_draw()
--   cls()
--   camera(cam_off_x,cam_off_y)
--   map(0,0,0,0,map_max_dim,map_max_dim)
--   local a
--   for e in all(entities) do
--     e.draw(e)
--   end
--   for r in all(rooms) do
--    local c = r.reach_start and 7 or 8
--    rect(r.x*8,r.y*8,(r.x+r.w)*8,(r.y+r.h)*8,c)
--   end
--   for p in all(debugp) do
--    spr(253, p.x*8,p.y*8, 1, 1)
--   end
-- end

-->8
-- pathfinding

function has_node(arr, n)
 for e in all(arr) do
  if e.x==n.x and e.y==n.y then
   return true
  end
 end
 return false
end

-- a* path finding
function find_path(sx,sy,ex,ey,can_pass,found_goal,get_next_best)
 local start={x=sx,y=sy,f=0,g=0}
 local open,visited={start},{}
 while #open>0 and #visited < 100 do
  qsort(open, function(a,b) return a.f <= b.f end)
  local current = add(visited, deli(open, 1))
  if current.x==ex and current.y==ey or (found_goal and found_goal(current)) then
   -- success
   local result={}
   while current.parent != nil do
     add(result, current,1)
     current = current.parent
   end
   return result
  end
  for i=1,4 do
   local child={x=current.x+dirx[i],y=current.y+diry[i],f=0}
   if can_pass(child.x,child.y) and has_node(visited,child)==false then
    child.g=current.g+1
    local h=get_manhattan(child.x,child.y,ex,ey)
    child.f=child.g+h
    child.parent=current
    local add_to_open=true
    for n in all(open) do
     if n.x==child.x and n.y==child.y then
      if n.g >= child.g then
       del(open,n)
      else
       add_to_open=false
      end
     end
    end
    if add_to_open then
     add(open,child)
    end
   end
  end
 end
 return get_next_best and open[1] or {}
end
__gfx__
00000000000000002222222055555550000009909999099055000000999999900000000099999990000000000000000055555550000000000000000000000000
00000000000000002222222000000000009909900000000000000000000000005500000000000000000000500999990050555050000000000000000000000000
00700700000000002222222055000000909909909999099055000000999999900000000099999990000005009999999050000050000000000000000000000000
00077000000000002222222055055000909909909999099055000050999990005500000099999990000000500099900000000000000000000000000000000000
00077000000000002222222055055050909909909990999050000500999990995000000099999990000005509099909050555050000000000000000000000000
00700700000000002222222055055050909909909909999000000050999990005000000099999990000005509000009050000050000000000000000000000000
00000000000500002222222055055050909909909909999000000550999999905500000099999990000000500999990005555500000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222220222222202222222006666660666666000666666006666600666666006662666066666660222266606662222066666660222266602222666066622220
22222220222222202222222066666660666666606666666066666660666666606662666066666660222266606662222066666660222266602222666066622220
22222220222222202222222066666660666666606666666066666660666666606662266066666660222226606622222066666660222266602222266066622220
22222220222222202222222066622220222266606662222066626660222266606662222022222220222222202222222022222220222266602222222066622220
22222660666666606622222066622220222266606662666066626660666266606662266066222660662226606622266022222660662266606666666066622660
22226660666666606662222066622220222266606662666066626660666266606662666066626660666266606662666022226660666266606666666066626660
22226660666666606662222066622220222266606662666066626660666266606662666066626660666266606662666022226660666266606666666066626660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22226660066666006662222066622220222266600666666066626660666666006662666066626660666266606662666066626660666222206662666066666660
22226660666666606662222066622220222266606666666066626660666666606662666066626660666266606662666066626660666222206662666066666660
22226660666666606662222066622220222266606666666066222660666666606622266066226660662226606622266066622660662222206622666066666660
22226660666266606662222066622220222266606662222022222220222266602222222022226660222222202222222066622220222222202222666022222220
22226660666666606662222066666660666666606666666066222660666666606666666066226660222226606622222066622220666666602222666066222220
22226660666666606662222066666660666666606666666066626660666666606666666066626660222266606662222066622220666666602222666066622220
22226660066666006662222006666660666666000666666066626660666666006666666066626660222266606662222066622220666666602222666066622220
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22226660666666606662222066666660666266606662666066626660666266602222666066622220222266602222222066626660666222205999995050000550
22226660666666606662222066666660666266606662666066626660666266602222666066622220222266602222222066626660666222209055009000000050
22222660666666606622222066666660666266606662666066626660666266602222266066222220222226602222222066222660662222209550009000000000
22222220222222202222222022222220666266606662222066626660222266602222222022222220222222202222222022222220222222209500009000000000
22222220222222202222222066666660666266606666666066666660666666606622222022222660222226606622266022222220662222209000059055000050
22222220222222202222222066666660666266606666666066666660666666606662222022226660222266606662666022222220666222209000509050500500
22222220222222202222222066666660666266600666666006666600666666006662222022226660222266606662666022222220666222205999995055555550
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550555555000666666066666600000000000000000000000000000000000000000000000000666666606666666066666660666666609999099055555550
50000000000000506606666066666060005550000055500000000000000000000000000000000000600060606060606066000660666666609090909050555550
50000000000000506606666066666060000500000005000000000000000000000000000000000000600066606666666060606060666666609990009055500050
50000000000000506060666060606060005550000055500000000000000000000000000000000000600066606060606060000060666666609099999050505050
50000000000000506666666066666660005550000055500000000000000000000000000000000000666666606666666066666660666666609999999055550550
50000000000000500000000000000000000005000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555550555555505555555055555550000550000055000000000000000000000000000000000000555555505555555055555550555555509999999055555550
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555505555555055555550555000005555555055555550555555505050505055555550555050505555555050505050555555500000000000000000
00000000555555505000005055555550555000005555555005050500555555500000000055555550000050505555555005050500555555500000000000000000
00000000555555505555555055555550555000005555555055555550555555505050505055555550555050505555555050505050555555500000000000000000
00000000000000005000005000000000000000000000000005050500000000000000000000000000000000000000000005050500000000000000000000000000
00000000000000005555555055555550000055500000555055555550555555505050505050505050505055505050555050505050505050500000000000000000
00000000000000005000005050000050000055500000555005050500050505000000000000000000505000005050000005050500050505000000000000000000
00050000000500005550555055505550000055500000555055505550555055505050505050505050505055505050555050505050505050500000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555550555555505555555055555550555555505555555055555550555555505555555050555050505055505550505055555550505050505555555055505550
05555550555555505555550005555550555555505555550055555550555555505555555050555050505055505550505055555550505050500000000000000000
00555550555555505555500000555550555555505555500005555550555555505550005050555050505055505500505055555500555555505555555055505550
00000000000000000000000000000000000000000000000000000000000000000005550000055500005000000055500000000000000000005505055050505050
00000000000000000000000000055550555555505555000000005550555555505055505055500050505055505500055055500000000000005550505055505550
00000000000000000000000000050500050505000505000000005550555555505055505055555550505055505555555055500000000000000555555005500550
00050000000500000005000000000000000000000000000000000550555555505055505055555550550505505555555055000000000000005555555055505550
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006660666666606660000000066660666600000506000000060500000000000000000000000000000000000000000000000000000000000000000000000000
00060000000600000006000005060000000605000006000000060000000000000000000000000000000000000000000000000000000000000000000000000000
00066660666666606666000000066660666600000506000000060500000000000000000000000000000000000000000000000000000000000000000000000000
00060000000600000006000005060000000605000006000000060000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000600000006000000060000000600000506000000060500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000005000000000005000006000000060000000000000000000000000000000000000000000000000000000000000000000000000000
00505050505050505050500000505050505050000506000000060500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550555555505555550005555550555555505555550000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050088880888888808888005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050080000000000000008005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050080000000000000008005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050080000800880000008005000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050080000080808000008005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050080000800080000008005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050080000000000000008005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050088880888888808888005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000000000000000000005050000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555550555555505555555055555550555555505555555000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00555500005555000000000000555500000000000000000001111100000000000099000000000000000000000000000000000000000000000000000000000000
05555550005555000055550005555550000000001100000001555100000000110900900000000000000000000000000000000000000000000000000000000000
05555550055555500555555005555550000000001510000000151000000001519099090000000000090000000000000000000000000000000000000000000000
05555550055555500555555005555550000000001551000000010000000005519999990050500500900000000900000009000000050005000000000000000000
00000000000000000000000000000000000100001510000000000000000001519999990055005500900990009000000090000000005555500000000000000000
00000000000000000000000000000000001510001100000000000000000000110999900005555050099999000999990009999900050005000000000000000000
00000000000000000000000000000000015551000000000000000000000000000099000050550000009090000009000000099000005500000000000000000000
00000000000000000000000000000000011111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555500005555000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05555550055555500055550005555550000999000009990000000000000999000000000000099000000990000009900000099000000000000000000000000000
05555550055555500555555005555550009909900099099000099900009909900000000000099000000999900009999000099000000000000000000000000000
05f1f150055151500555555005f1f150009990000099900000990990009990000000000000099990000990000009900000099990000000000000000000000000
00ffff0005f1f15005f1f15000f1f100909999009099990000999900009999000555005000999000009990000099900000999000000000000000000000000000
0000000000ffff0000ffff0000ffff00099990000999900099999000999990005555500509999900999990009999990009999000000000000000000000000000
00000000000000000000000000000000009090000009000000900000090009000550055090900900000090000009900090900900000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000990000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000009999000000000000000000000000000000000000000000000000000
09999900099999000999990009999900000000000000000000000000000000000000000000999900000000000000000000000000000000000000000000000000
09999500099995110999951109999500000000000000000000000000000000000000000000090990000000000000000000000000000000000000000000000000
099995110999955f0999955f09999511000000000000000000000000000000000000000000009900000000000000000000000000000000000000000000000000
0999995f09999900099999000999995f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555500005555500055550000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00500500000005000000500000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888888800111000077000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077770000800000801171100077700000
00999900009999000099990000999900000000000000000000000000000000000000000000000000000000000000000057070000808080801777100077770000
09999900091111100911111009999900000005500000000000000000000000000000000000000000000000000000000066600000800800801171100077700000
09111110059f99f0099f99f009111110055505000000000000000000000000000000000000000000000000000000000050070000808080800111000077000000
099f99f00555500005555500059f99f0555550500000000000000000000000000000000000000000000000000000000006700000800000800000000000000000
05555500005550000055500000555000500050000000000000000000000000000000000000000000000000000000000060060000888888800000000000000000
00500500000050000005000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000030082420042004200220000000003030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303000001010101010101010101010101014101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020000001011111111111112101111120202020202101111120202020202020202020202
0201010101020202010102010101010202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020000002083848484848522204e5d220202020202204041220202023a330709332d0202
0201010101020202010102010101010202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020000002093949494949522205c5c220202020210244243231202020202020202020202
02010101010501050101020101010102020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202020202020202020200000020424a4e4c4d4322205c5c220202020220624445602202023031070931320202
0201010101020202010102010101010202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020202020202020202020000002001545454540122200709220202020220010101012220020202020202020202
020202020202020201010501010101020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202000000205054545454502220010122020202023a33080a332d1a333333332f02020202
0201010101050101010102010101010202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002050505050505022000000000000000020620101606134606161622311120202
0202020202020202020202020205020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020709020202000000000000000020010101010105010101010504220202
0201010101010101010101010101010202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020010101010b34010101011331320202
020205020202020202020202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003031313131312e010b0b012202020202
020101010102020201010501010101020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202020202023a333333332d02020202
0201010101020202010102010101010202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020220020202020202020202
0201010101050105010102020502020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
0201010101020202010102010101010202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101010201010101020101010102
0201010101020202010102010101040202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101010202020101020101010102
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010301010501050101020101010102
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101010202020101020101010102
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020201010101050101010102
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101010501010101020101010102
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202050202
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101010101010101010101010102
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020502020202020202020202020202
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101010102020202020202020202
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101010102010101010101010202
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101020202010101020205020202
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101050101010101020101010202
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101020202010101020101010402
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002010101020202010101020101010202
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002020202020202020202020202020202
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400002152023530235100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000300000a73014610007000a70006700036000173011610027000460000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000200000371005720087300e740157500d7000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000200000975007750057000570005750067500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002e3102731010310203202132011320103301d7301873015750117500b7400773002720003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000200000f740157401a73008630076200662005610220501d0500700003000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000019530175301553008610086102b5202f52032510086100861000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000200001d6201c6203d61000600006000c600346001f6001f6003d60005600296000060000600006001161011620326200060000600006000b60000600006000160028600016000060000600006000162022620
000400000f51012520165400050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00040000165500f5300c5200050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400001355000500165500050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
0001000032370373703836035360323602c350243301a330093301b6501b6501b6501b6501b6001b6001c6001c6001c6001c6001c6001b6001b6001b600003000030000300003000030000300003000030000300
000600001b440184301643013420114200f4100d4100c4100b4100a4100a41022400004001c4101c4202143000400004000040000400004000040000400004000040000400004000040000400004000040000400
000500002d14024630166300e63009630056200162000610001200012000120006000060002600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000500000014000610006100162003620076200a63010630176302513000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000604006720067100671006700067000670007700067000670007700067000670006700067000170006000067000070000700007000070000700007000070000700007000070000700007000070000700
010a000000000000003b7223b7503b725000003b7223b7253b7243b72500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 0f 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
