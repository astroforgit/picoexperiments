pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

event_message,emticks,l_zombies,glob_p = "",0,{},nil
psun_dest,music_off,max_plants = -1,false,8
game_seed,plants,zombies,level,ticks,next_m_ticks,menu,mticks  = "",{},{},1,0,6,0,0
default_freeze,pause_menu_select = 4,1
px,py,eclipse_ticks,pause_menu = 0,0,0,{"resume","quit"}
p_as,p_spr = {0,20,20,20,0,0,0,0},{5,19,21,23,25,29,34,41,9,45,10}
cards,card_master,cards_ct = {1,2,3,4,5,6,7,8,10},{1,2,6,5,8,7,3,4,10},{}
p_c = {240,450,600,800,500,600,800,450,5,5,5}
p_cost = {10,20,35,40,20,10,30,20,0,0,0}
--top left of board and grid size
xo,yo,gx,gy,draw_r = 8,42,8,10,0 
message,bullets = "",{}
global_sun,score,psun,pstate,zticks,pselect = 150,0,15,0,0,0
mower_stat,wave,sun,mowers,hud_flags = {},{},{},{},{}
ltimer,ltma,hud_z_comp,hud_z_tot,hud_x = 0,false,0,1,121

fade = {{0,5,5,5,5,5,5,5,2,6,9,3,1,1,14,6},{0,0,0,0,0,0,0,0,5,5,5,5,5,5,14,5},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0}}

wcards = {2,2,3,4,5,6,6,7,8,8,8,8}

title_menu = {}
title_menu_select,level_seed,mess_ticks = 1,0,3


zt = {}
btn4_up = false
           
zt[1] = {10,0,0,0,0,0,0,0}
zt[2] = {10,0,0,0,0,0,0,0}
zt[3] = {10,4,0,0,0,0,0,0}
zt[4] = {9,4,3,0,0,0,0,0}
zt[5] =  {8,4,4,3,0,0,0,0}
zt[6] =  {8,4,5,4,2,0,0,0}
zt[7] =  {7,5,5,5,3,1,0,0}
zt[8] =  {7,5,4,4,5,3,0,0}
zt[9] =  {6,5,4,4,5,4,3,0}
zt[10] = {6,5,5,3,2,4,2,3}
zt[11] = {6,5,4,2,3,5,3,3}
zt[12] = {6,5,3,2,1,3,2,2}
zt[13] = {6,5,6,2,2,5,5,2}
zt[14] = {6,5,4,2,1,2,3,3}
zt[15] = {6,5,4,3,2,2,2,4}
--              p n f t m

hex = "0123456789abcdef"
seed_c = 1
seed_m = {1,1,1,1,1,1,1,1}

meteors = {}

function add_meteor(x,y)
  local m = {}
  m.x,m.y,m.sx,m.sy,m.dx,m.dy = x,y,x*gx+xo + 120,y*gy+yo-120,-4,4
  m.ex = x*gx+xo
  m.sb,m.f = 14,0
  m.life = 7200 + rnd(3600)
  add(meteors,m)
end

function gen_seed()
  local sd = ""
  for i = 1,8 do
    c = flr(rnd(16)) + 1
    sd = sd..sub(hex,c,c)
  end
  return sd
end

function new_game()
  game_seed = gen_seed()
  start_game(game_seed)
end

function start_game(seed)
  
  if (music_off == false) then
    music(0)
  else
    music(-1)
  end
  
  lss = "0x"..sub(seed,1,4).."."..sub(seed,5,8)
  level_seed = lss + 0
  srand(level_seed)
  level,score,psun_dest,meteors = 1,0,-1,{}
  wave,bullets,sun,plants,zombies = {},{},{},{},{}
  zticks,ticks,next_m_ticks,mticks = 0,0,6,0
  mower_stat,mowers,message = {1,1,1,1,1,1,1},{},""
  global_sun,px,py,pselect,psun,pstate,cards_ct = 145,0,0,0,15,0,{0,0,0,0,0,0,0,0,0,0}  
		next_level()

end

function do_eclipse()
  add_event_message("eclipse! sun production slowed.")
  g_eclipse = true
end

function get_smallest(list)
  local ly = list[1]
  for li in all(list) do
    if (li.y < ly.y) ly = li
  end
  return ly
end

function layout_l_zombies(w)
  l_zombies = {}
  local temp,cnt = {},{0,0,0,0,0,0,0,0,0,0}
  for zw in all (w) do
    cnt[zw[1]+1] += 1
  end
  
  for i = 0,7 do
    if (cnt[i+1] > 0) then
      local c = mid(1,1+flr(cnt[i+1]/10),3)
      for j = 1,c do
        local z = make_zombie(i,2,1)
        z.x += rnd(64) + 7
        z.y += rnd(18) + 12
        add(temp,z)
      end
    end
  end
  
  while (#temp > 0) do
    local tz = get_smallest(temp)
    add(l_zombies,tz)
    del(temp,tz)
  end
  
end

function next_level()
  level_seed += 0.1
  ltimer,ltma,pstate,ticks,g_eclipse = 1050,false,8,0,false
  srand(level_seed)
  setup_wave_proc(level)
  cards_ct = {0,0,0,0,0,0,0,0,0,0}
  global_sun += 5

  if (level > 3) then
    local rm = max(100-level,75)
    if (#plants > 38) rm = 75
    if (#plants < 15) rm += 25
    local r = rnd(rm)
    if r < 12 then
      if (#plants > 10 and psun > 50) do_eclipse()
    elseif r < 22 then
      add_event_message("sun flower plague!")
      for p in all(plants) do
         if (p.id == 1 and rnd(10) > 5.5) wither_plant(p)
      end
    elseif (r < 35 and psun > 20) then
      add_event_message("the zombies stole your sun!")
      psun_dest = 20
    elseif r < 45 then
      add_event_message("garden plague strikes!")
      local i = 0
      for p in all(plants) do
        if (rnd(10) < 3.2 and p.id < 9) wither_plant(p)
      end
    elseif r < 55 then
      add_event_message("potato mines get bored!")
      for p in all(plants) do
        if (p.id == 6) p.state = 42
      end
    elseif r < 65 then
      --meteor shower
      add_event_message("meteor shower")
      local n = flr(rnd(5)) + 3
      for i = 1,n do
        add_meteor(flr(rnd(9)),flr(rnd(7)))
      end  
    end
  end
  layout_l_zombies(wave)
end

function add_event_message(msg)
  event_message = msg
  evmx = (128 - #msg*4)/2
  emticks = 100
end

function clear_event_message()
  event_message = ""
  emticks = 0
end

function add_message(msg)
  message = message.."                                     " .. msg
end

function pick_z_row(rv)
  local rw = -1
  while (rw < 0) do
    rw = flr(rnd(7))
    if(rv[rw+1] == 1) return rw
  end
  return 3
end

function setup_wave_proc(l)
 
  hud_flags = {}
  szc = 0
  
  local num_waves = 1
  if (l > 2) num_waves += 1
  if (l > 5) num_waves += 1
  if (l > 11) num_waves += 1
  
  local wc = {min(15,l+(l-1)*2),min(25,l*4)}
  if (l > 8) wc[2] += flr(rnd(15) + 5)
  wc[3] = flr(wc[2] * 1.25)
  wc[4] = flr(wc[3] * (1.1 + rnd(0.25)))

  --setup rows
  for p in all(plants) do
    if (p.id == 9) kill_plant(p)
  end
          
  local g_rows = {1,1,1,1,1,1,1}
  if (l == 1) g_rows = {0,0,0,1,0,0,0}
  if (l == 2) g_rows = {0,0,1,1,1,0,0}
  if (l > 2 and l < 8) g_rows = {0,1,1,1,1,1,0}
  for y = 0,6 do
    for x = 0,13 do
      if (g_rows[y+1] == 0) add_plant(9,x,y)
    end
  end
  
  local zc = 0
  for w = 1,num_waves do
    local tm,zfm = 35,0
    if (l > 1) tm = 12
    if l < 16 then
      zf = zt[l]
    else
      zf = zt[15-flr(rnd(3))]
      for i = 1,#zf do
        if i > 3 then
          zf[i] = max(rnd(zf[i]),0.25)
        end
      end
    end
    
    for i = 1,#zf do
      zfm += zf[i]
    end
    
    if (w > 2) then
      add(wave,{8,pick_z_row(g_rows),-1})
      zc += 1
      add(hud_flags,zc)
      tm -= 7
    elseif (w == 2) then
      add(hud_flags,zc+1)
      tm -= 4
    end

    for zw = 1,wc[w] do
      -- add zombies
      local r = rnd(zfm)
      local zid = 0
      for id = 1,#zf do
        if zf[id] > 0 then
          if r < zf[id] then
            zid = id
            break
          else
            r -= zf[id]
          end
        end
      end
      
      local row = pick_z_row(g_rows)
      add(wave,{zid-1,row,tm})
      zc += 1 -- zombie count
      
      if (zid == 6) then
        --football strategy
        r = rnd(100)
        if (r < 10 and zf[4] > 0) then
          add(wave,{3,row,3})
          zc += 1
        elseif (r < 17 and zf[8] > 0) then
          add(wave,{7,row,1})
          zc += 1
        elseif (r < 20 and zf[8] > 0) then
          add(wave,{5,row,3})
          add(wave,{7,row,1})
          zc += 2
        end
      elseif (zid == 7) then
        --garbage can strategy
        r = rnd(100)
        if (r < 15 and zf[8] > 0) then
          add(wave,{7,row,3})
          zc += 1
        end
      end
      
      tm -= rnd(2)
      if (level > 2 and tm > 8) tm -= rnd(2)
      if (tm < 1) tm = rnd(3)+1
      
    end 
  end
 
  -- setup plants/cards
  cards = {0,0,0,0,0,0,0,0,0}
  local lc = min(12,l)
  for i = 1,wcards[lc] do
    cards[i] = card_master[i]
  end
  
  max_plants = wcards[lc]-1
  
  --shovel
  if (level > 2) then
    cards[wcards[lc]+1] = 10
    max_plants += 1
  end
  
  if (max_plants > 8) max_plants = 8

  hud_z_comp,hud_z_tot = 0,#wave
  
end

function add_plant(id,x,y)
  local p = {}
  p.sun,p.fade,p.gone = p_cost[id],0,false
  p.x,p.y,p.id,p.f,p.sb = x,y,id,0,p_spr[id]
  p.atk_state = p_as[id] -- single shot
  p.atk_bspd,p.atk_sb,p.dmgf = 2,3,0
  p.atk_nb,p.atk_delay,p.atk_cb,p.hp,p.dmg = 1,60,0,8,0

  if (id == 3) p.atk_sb,p.atk_delay,p.atk_bspd = 4,70,1.5
  if (id == 4) p.atk_nb = 2
  if (id == 6) p.atk_delay,p.atk_state,p.sb,p.dmg,p.hp = 450,40,27,90,500
  if (id == 7) p.atk_delay,p.atk_state,p.dmg,p.hp = 40,50,90,500
  if (id == 8) p.atk_delay,p.atk_state,p.hat_state = 15,60,0   
  if (id == 1) p.atk_state,p.atk_delay = 30,660
  if (id == 5) p.hp = 35
  if (id == 11) p.gone,p.life = true,7000+flr(rnd(900))
  
  p.ticks,p.state,p.sx,p.sy = 0,0,p.x*gx+xo,p.y*gy+yo+2
  add(plants,p)
end

function empty_plant(x,y)
  for p in all(plants) do
    if p.x == x and p.y == y then
      glob_p = p
      return false
    end
  end
  return true
end

function plant(x,y)
   local id = cards[pselect+1]
   if (cards_ct[pselect+1] > 0) then
     sfx(4)
   elseif (p_cost[id] > psun) then
     sfx(4)
   elseif (empty_plant(x,y)) then
     add_plant(id,x,y)
     cards_ct[pselect+1] = p_c[id]
     change_sun(-p_cost[id])
     sfx(8)
     return true
   else
     sfx(4)
   end
   return false
end

function add_sun(x,y)
  local s = {}
  s.x,s.y,s.sb,s.dx,s.dy,s.ticks,s.state = x*gx+xo,y*gy+yo,1,rnd(1)-0.5,rnd(1)-0.5,0,0 
  add(sun,s)
end

function add_bullet(sb,x,y,sp)
  local b = {}
  b.dmg,b.freeze,b.freeze_c = 1,default_freeze,0
  if (sb == 4) b.freeze,b.freeze_c = 45,12
  b.x,b.y,b.sb,b.dx = x*gx+xo+3,y*gy+yo,sb,sp
  add(bullets,b)
end

function set_z_sprite(bs,hs,z)
  z.by = flr(bs / 16)
  z.bx = (bs - z.by * 16) * 8
  z.by *= 8
  
  z.hy = flr(hs / 16)
  z.hx = (hs - z.hy * 16)*8
  z.hy *= 8
 
end

function make_zombie(id,x,r)
  local z = {}
  z.p,z.burn,z.sc,z.fc = nil,0,1,0
  z.r,z.x,z.y,z.f,bs,hs,bw,bh,hw,hh,z.state,z.ticks = r,x*8+xo,r*10+yo,0,80,64,8,8,8,8,0,0
  z.hp,z.dmg,z.id,z.in_hit,z.freeze = 12,1,id,0,0
  z.has_pole,z.hat,z.hathp,z.hatof,z.hatxof = false,0,0,-5,1
  
  --pole vault
  if (id == 3) z.hp,bs,hs,z.has_pole,z.sc = 18,160,70,true,2
		--newspaper
		if (id == 4) z.hp,bs,hs,z.hat,z.hathp,z.hatof,z.hatxof = 15,112,96,100,5,5,-4
	 --football
	 if (id == 5) bs,hs,z.hat,z.hathp,z.hatof,z.hatxof,z.sc = 118,74,78,80,1,0,5
	 --garbage can
	 if (id == 6) z.hat,z.hathp,z.hatof,z.hatxof = 105,30,6,-5
	 --miner
	 if (id == 7) z.hp,bs,hs = 30,144,128
	 z.es = bs + 3
	 --flag
	 if (id == 8) z.hat,z.hathp,z.hatof,z.hatxof = 79,4,4,-2
	 
	 
  set_z_sprite(bs,hs,z)
  
  z.bw,z.bh,z.hw,z.hh = bw,bh,hw,hh
  z.hxo,z.hyo = 0,-z.hh+2
  
  z.y += 2
  z.dx,z.jy,z.dy = 0.075,0,0
  
  if (id == 1) z.hat,z.hathp,z.sc = 68,8,100
  if (id == 2) z.hat,z.hathp,z.hatof,z.sc = 69,15,-1,150
  if (id == 3) z.dx = 0.15
  if (id == 5) z.hp,z.dx = 20,0.2
  if (id == 6) z.dx = 0.025
  if (id == 7) z.hxo,z.dx = 1,0.1
 
		z.hp += z.hathp
		z.bs = bs
		z.hs = hs
		
		return z
end

function add_zombie(id,x,r)
  add(zombies,make_zombie(id,x,r))
end

function _init()
  game_seed = gen_seed()
  pstate = -1
  title_menu = {"new game","enter seed","music: on"}
  music(0)
end


-->8
function set_col_fade(f)
  for i = 0,15 do
    if (i != 14) pal(i,fade[f][i+1])
  end
end

function draw_plant(p)
  if (pexpdraw and not (p.state == 43 or p.state == 53)) return
  if (pexpdraw or p.y == draw_r) then
   if (p.dmgf > 0) then
     p.dmgf -= 1
     hit_color()
   else
     reset_color()
   end
   
   if (p.fade > 0) set_col_fade(p.fade)
   
   spr(p.sb+flr(p.f),p.sx,p.sy)
   if (p.id == 5) then
     p.f += rnd(0.05)
     if (p.f > 1.99) p.f = 0
   elseif p.id == 6 or p.id == 7 then
     p.f += rnd(0.15)
     if (p.f > 1.99) p.f = 0
     if p.state == 43 then
       spr(204,p.sx-12,p.sy-8,4,1)
     elseif p.state == 53 then
       for x = -1,1 do
         for y = -1,1 do
           if (p.y + y >= 0 and p.y + y < 8 and p.x + x < 14 and p.x + x >= 0) spr(36 + p.f,p.sx+x*8,p.sy+y*8)
         end
       end
       print("chabuf",p.sx - 7,p.sy+2,0)
     end
   elseif p.id == 8 then
     p.f += rnd(0.1)
     if (p.f > 1.99) p.f = 0
     if p.hat != nil then
       spr(p.hat[1],p.hat[2],p.hat[3])
     end
   end
 end
end

function reset_color()
  pal()
  palt(0,false)
  palt(14,true)
end

function burn_color()
  pal(5,0)
  pal(6,0)
  pal(4,5)
  pal(8,5)
  pal(9,6)
  pal(12,6)
  pal(7,6)
end

function draw_pole(z)
  if z.has_pole then
   if z.state == 60 then
     line(z.px-3,z.py+8,z.px+4,z.py-2,7)
   elseif z.state == 61 then
     line(z.px-3,z.py+8,z.px+1,z.py-6,7)
   elseif z.state == 62 then
     line(z.px-3,z.py+8,z.px-2,z.py-5,7)
   elseif z.state > 62 then
     line(z.px-3,z.py+8,z.px-5,z.py-4,7)
   else
    if z.f < 1 then
      line(z.x-8,z.y-1,z.x+9,z.y-1,7)
    else
      line(z.x-8,z.y,z.x+9,z.y,7)
    end
   end
  end
end

function hit_color()
  pal(5,9)
  pal(6,10)
  pal(4,9)
  pal(11,10)
  pal(8,10)
  pal(12,10)
end

function draw_zombie(z)
		if (z.r != draw_r) return
		local ly = z.y
		if (z.bh > 8) ly -= (z.bh-8)
		if z.state < 100 then
		  if z.in_hit > 0 then
		    hit_color()
		  else
		    reset_color()
		    if z.freeze > 0 and z.fc > 0 then
		      pal(6,z.fc)
		    end  
		  end
    sspr(z.bx+flr(z.f)*8,z.by,z.bw,z.bh,z.x,ly+z.jy)
    if (z.id == 3) draw_pole(z)
    sspr(z.hx,z.hy,z.hw,z.hh,z.x+z.hxo,ly+z.hyo+z.jy)
    if z.hat > 0 then
      spr(z.hat,z.x+z.hxo+z.hatxof,ly+z.hyo+z.hatof)
    end
    if z.state == 40 then
      spr(101,z.x,ly-16)
    end
  else
    if (z.burn == 1) burn_color()
    sspr(z.bx+flr(z.f)*8,z.by,z.bw,z.bh,z.x,ly)
    sspr(z.hx+flr(z.hf)*8,z.hy,z.hw,z.hh,z.headx,z.heady)
    reset_color()
  end
end


function draw_bullet(b)
  spr(b.sb,b.x,b.y)
  circfill(b.x+4,b.y+8,1,0)
end

function draw_sun(b)
  spr(b.sb,b.x,b.y)
end

function _draw()
  reset_color()
  if pstate == -5 then
    cls(1)
    print("enter game seed",32,16,7)
    local yy,xx = 52,34
    for i = 1,8 do
      local cc = 7
      if seed_c == i then
        cc = 10
        if (ticks % 10 == 0) cc = 1
      end
      
      if seed_m[i] < 1 then
        print("_",i*6+xx,yy,cc)
      else
        print(sub(hex,seed_m[i],seed_m[i]),i*6+xx,yy,cc)
      end
    end
    
    print("‹ / ‘ to move cursor",20,yy + 28,7)
    print("” / ƒ to change digit",18,yy + 36,7)
    print("— to start seed",30,yy + 48,7)
    print("Ž cancel back to title screen",4,yy + 56,7)
    return
  elseif pstate == -1 then
    map(16,0,0,0)
    spr(226,86,54,2,2)
    spr(195,64,56,1,2)
    spr(195,51,54,1,2)
    spr(194,43,57,1,2)
    spr(195,25,54,1,2)
    
    print("endless plants vs. zombies",12,6,8)
    print("endless plants vs. zombies",11,5,7)
  
    local yy = 79
    for i = 1,#title_menu do
      local cc = 7
      if (title_menu_select == i) cc = 10
      print(title_menu[i],16,yy,cc)
      yy += 8
    end
    return
  end
  
  local bc,ac = 3,15
  cls(12)
  --palt(0,false)
  --palt(14,true)
  print("endless plants vs. zombies",12,2,8)
  print("endless plants vs. zombies",11,1,7)
  
  if pstate != 8 then
    if #event_message > 0 then
      local evc = 0
      if (ticks % 4 == 0) evc = 10
      print(event_message,evmx,9,evc)
    else
      print(message,-6,9,0)
    end
  end
  
  map(0,0,0,2)
  local i,ccx,ccy = 0,0,0
  for x = 0,13 do
    for y = 0,6 do
    		local xx,yy,c = x*gx+xo,y*gy+yo,bc
      if (i % 2 == 0) c = ac
      if px == x and py == y then
          if (ticks % 4 < 2 and pstate == 0) c = 10
          ccx,ccy = xx,yy
      end

      rectfill(xx,yy,xx+gx-1,yy+gy-1,c)   
      i += 1
      curs = false
    end
    i += 2
  end

  pexpdraw = false
  for dr = 0,6 do
    draw_r = dr
    reset_color()
    foreach(plants,draw_plant)
    for zi = #zombies,1,-1 do
      draw_zombie(zombies[zi])
    end
    --foreach(zombies,draw_zombie)
    reset_color()
    if (mower_stat[dr+1] == 1) then
      spr(192,-1,dr*gy+yo+2)
    else
      for m in all(mowers) do
        if (m[3] == dr) then
          spr(192,m[1],m[2])
        end
      end
    end
  end
  
  pexpdraw = true
  foreach(plants,draw_plant)
  
  reset_color()
  
  --if (ccx > 0) rect(ccx,ccy,ccx+gx-1,ccy+gy-1,9)
  rect(ccx,ccy,ccx+gx-1,ccy+gy-1,9)
      
  foreach(bullets,draw_bullet)
  
  for m in all(meteors) do
    spr(m.sb+m.f,m.sx,m.sy)
  end
  
  --hud
  spr(2,4,18)
  local psx = 10
  if (psun > 10) psx += 2
  if (psun > 95) psx += 2
  print(""..psun,16-psx,27,7)
  for i = 0,max_plants do
    if cards[i+1] > 0 then
      xx = 20 + i*12
      
      if cards_ct[i+1] > 0 then
        local hp = cards_ct[i+1]
        hp = hp / p_c[cards[i+1]]
        hp = hp * 17
        rectfill(xx-2,33-hp,xx+8,33,8)
      end
      
      if p_cost[cards[i+1]] == 0 then
        print(p_cost[cards[i+1]],xx+1,27,7)
      else
        print(p_cost[cards[i+1]],xx,27,7)
      end
      spr(p_spr[cards[i+1]],xx-1,18)
      if pselect == i then
        rect(xx-3,16,xx+8,33,10)  
      end
      local psc = 10
      if (pstate == 10) then
        if (ticks % 4 < 1) psc = 0
      end
      if pselect == i then
        rect(xx-3,16,xx+8,33,psc)  
      end
    end
  end
  
  foreach(sun,draw_sun)
  
  --rectfill(79,122,128,128,0)
  line(0,122,128,122,0)
  print("score: "..score,1,116,0)
  --rectfill(0,122,37,128,0)
  print("level: "..level,1,123,7)

  for f in all (hud_flags) do
    spr(200,hud_x-(f/hud_z_tot)*76+1,121)
  end
  
  spr(64,hud_x-(hud_z_comp/hud_z_tot)*76,121)
  
  if g_eclipse and eclipse_ticks > 0 then
    eclipse_ticks -= 1
    if (eclipse_ticks % 5 == 0) then
      rectfill(0,32,128,121,0)
    end
  end
  
  if pstate == 5 then
    rectfill(32,48,96,86,0)
    print("game paused",42,54,7)
    local yy = 68
    for i = 1,#pause_menu do
      local cc = 7
      if (pause_menu_select == i) cc = 10
      print(pause_menu[i],52,yy,cc)
      yy += 8
    end
  end
  
  if pstate == 6 then
    --won level
    rectfill(20,46,108,104,0)
    print("level completed!",34,52,7)
    if ticks > 30 then
      local pd = ""
      if (level_bonus < 1000) pd = pd .. " "
      if (level_bonus < 10000) pd = pd .. " "
      print("bonus: " .. pd .. level_bonus,40,72,7)
    end
    if (ticks > 60) print("next level",44,92,10)
  elseif pstate == 8 then
    rectfill(20,46,108,104,0)
    print("zombies approach",32,52,7)
    draw_r = 1
    for z in all(l_zombies) do 
      draw_zombie(z)
    end
    if (ticks > 30) print("get planting",40,96,10)
  end
  
  if pstate > 99 then
    rectfill(20,46,108,108,0)
    print("the zombies ate your",24,50,7)
    print("brains!",52,58,7)
    spr(220,48,70,4,3)
    print("press any button",32,93,10)
    print("seed: "..game_seed,36,101,7)
  end
  
  if ltma then
    local cc = 0
    if (ltimer % 4 == 0) cc = 10
    print(flr(ltimer/30),64,116,cc)
  end
end
-->8
function update_plant(p)
  p.ticks += 1
  pt = p.ticks
  if (p.id == 11) then
    if (pt == 1800) p.sb += 1
    if (pt == 3600) p.sb += 1
    if (pt == 5400) p.sb += 1
    if (pt > p.life) kill_plant(p)
    return
  end
  if (p.state == 0) then
    if (p.id == 1) then
      p.f += rnd(0.1)
      if (p.f > 1.99) p.f = 0
    end
    if (pt > p.atk_delay) p.ticks,p.state = 0,p.atk_state
  elseif (p.state == 20) then
    --shoot bullet
    p.f = 1
    if (pt > 5) p.ticks,p.state = 0,25
  elseif (p.state == 25) then
    p.f,p.state = 0,0
    add_bullet(p.atk_sb,p.x,p.y,p.atk_bspd)
    sfx(0,2)
    p.atk_cb += 1
    if (p.atk_cb < p.atk_nb) then
      p.ticks = p.atk_delay - 3
    else
      p.atk_cb = 0
    end
  elseif (p.state == 30) then
    --flower
    if (p.f < 1) p.f = 1
    p.f += 0.01
    if (p.f > 2.5) p.f += 0.09
    if (p.f > 3.99) p.state,p.f = 31,2
  elseif (p.state == 31) then
    add_sun(p.x,p.y)
    p.state = 32
  elseif (p.state == 32) then
    p.f -= 0.1
    if (p.f < 1) then
      p.f,p.state,p.ticks = 0,0,0
      if (g_eclipse) p.ticks = -300
    end
  elseif (p.state == 40) then
    --pop up
    p.sb,p.state = 29,41
    sfx(9,0)
  elseif (p.state == 41) then
  
  elseif (p.state == 42) then
    -- explode
    p.f,p.sb,p.ticks,p.state = 0,32,0,43
    sfx(7,0)
    for z in all(zombies) do
      if z.r == p.y then
        if (z.x + z.bw - 1 >= p.sx and z.x <= p.sx + 12) damage_zombie(p.dmg,z,1)
      end
    end
  elseif (p.state == 43) then
    if (pt > 40) then
      kill_plant(p)
    end
  elseif (p.state == 50) then
    --pop up
    p.sb,p.state = 36,52
  elseif (p.state == 52) then
    -- explode
    p.f,p.sb,p.ticks,p.state = 0,36,0,53
    sfx(7,0)
    for z in all(zombies) do
      if (abs(z.r - p.y) < 2) then
        if (z.x + z.bw - 1 >= (p.sx - 10) and z.x <= p.sx + 18) damage_zombie(p.dmg,z,1)
      end
    end
  elseif (p.state == 53) then
    if (pt > 40) then
      kill_plant(p)
    end
  elseif (p.state == 60) then
    --check if can grab metal
    
    p.state = 0
    for z in all(zombies) do
      if abs(z.r-p.y) < 3 then
        if abs(p.sx-z.x) < 72 then
          if (z.hat == 69 or z.hat == 78 or z.hat == 105) then
            p.hat = {z.hat,z.x+z.hxo+z.hatxof,z.y+z.hyo+z.hatof}
            p.hat_state,p.state,p.ticks = 1,61,0
            p.hatdx = p.sx - p.hat[2]
            p.hatendticks = abs(p.hatdx/2)-1
            p.hatdy = p.sy -5 - p.hat[3]
            p.hatdy = p.hatdy * 2 / abs(p.hatdx)
            p.hatdx = p.hatdx * 2 / abs(p.hatdx)
            z.hat = 0
            z.hp -= z.hathp
            break
          end
        end
      end
    end
  elseif (p.state == 61) then
    --hat traveling
    p.hat[2] += p.hatdx
    p.hat[3] += p.hatdy
    if (pt >= p.hatendticks) p.ticks,p.state,p.hat[2],p.hat[3] = 0,62,p.sx,p.sy-5
  elseif (p.state == 62) then
      -- has hat
    if (pt > 450) then
      p.state,p.ticks,p.hat_state,p.hat = 0,0,0,nil
    end
  elseif (p.state == 80) then
    --wither and die
    p.fade,p.state = 1,81   
  elseif (p.state == 81) then
    if (pt > 45) then
      p.fade += 1
      p.ticks = 10
      if (p.fade == 3) p.ticks = 25
      if (p.fade > 3) kill_plant(p)
    end
  end
end

function update_sun(s)
  s.ticks += 1
  if (s.state < 10) then
   if (s.ticks == 3) s.sb = 2
   s.x += s.dx
   s.y += s.dy
   if (rnd(10) > 9.25) then
     s.dx,s.dy = rnd(0.5) - 0.25,rnd(0.5) - 0.25
   end
   if (s.x < 9) s.dx = 0.25
   if (s.y < 43) s.dy = 0.25
   if (s.x > 110) s.dx = -0.25
   if (s.y > 109) s.dy = -0.25
   
   if pstate == 0 and hit_cursor(s) then
     --pick up sun
     change_sun(5)
     
     s.state,s.ticks = 10,0
     s.dx = 4 - s.x
     s.dy = 20 - s.y
     local m = sqrt(s.dx*s.dx + s.dy*s.dy)
     s.dy = s.dy * 4 / m
     s.dx = s.dx * 4 / m
     s.sb = 2
     sfx(6,0)
   end
   
   if (s.ticks > 345) del(sun,s)
  elseif (s.state == 10) then
    s.sb = 2
    s.x += s.dx
    s.y += s.dy
    if (s.x < 4 or s.y < 21) then
      s.sb = 1
      s.state,s.ticks = 11,0
    end
  elseif (s.state == 11) then
    if (s.ticks > 4) del(sun,s)
  end
end

function update_meteor(m)
  m.sx += m.dx
  m.sy += m.dy
  m.f += 0.25
  if (m.f > 1.99) m.f = 0
  if (m.sx <= m.ex) then
    -- hit
    del(meteors,m)
    if empty_plant(m.x,m.y) == false then
      if (glob_p.id < 9) then
        kill_plant(glob_p)
      else
        return
      end 
    end
    add_plant(11,m.x,m.y)
  end
end

function update_bullet(b)
  b.x += b.dx
  if (b.x > 120) del(bullets,b)
end

function update_mower(m)
  m[1] += 2
  if (m[1] > 120) del(mowers,m)
  for p in all(plants) do
   if p.y == m[3] and p.gone == false then
     if (m[1] >= p.sx - 3) kill_plant(p)
   end
  end
  for z in all(zombies) do
    if (hitc(m[1],m[2],z)) then
     kill_zombie(z)
    end
  end
end

function hit(a,b)
 local x,y,bx,by = a.x + 3,a.y,b.x,b.y
 return ((x <= bx + 8) and (bx <= x) and (y <= by + 8) and (by <= y))
end

function hit_cursor(b)    
 local x,y,bx,by = px*gx+xo,py*gy+yo,b.x,b.y
 return ((x <= bx + 8) and (bx <= x+8) and (y <= by + 8) and (by <= y+8))
end

function hitc(x,y,b,bx,by)
 if (bx != 0) bx = b.x
 if (by != 0) by = b.y
 return ((x <= bx + 8) and (bx <= x) and (y <= by + 8) and (by <= y))
end

function kill_plant(p)
  p.gone = true
  del(plants,p)
end

function do_plant()
  local id = cards[pselect+1]
  if id != 10 then
    return plant(px,py)
  else
    if empty_plant(px,py) == false then
     --dig up plant
     if glob_p.id < 9 then
       kill_plant(glob_p)
       change_sun(flr(glob_p.sun/2))
       sfx(14,1)
       return true
     end
    end
  end
  return false
end

function wither_plant(p)
  p.state = 80
  p.ticks = 0
end

function damage_zombie(dmg,z,burn)
	local bu = 0
	if (burn != nil) bu = burn
	z.hp -= dmg
 if (z.hat > 0) then
   z.hathp -= dmg
   if (z.hathp < 0.1) then
     if (z.id == 4) z.state,z.ticks = 40,0
     z.hat = 0
     if (z.id == 6) z.dx = 0.075
     --todo animation
   end
 end
 
 if (z.hp < 0.1) then
   z.burn = bu
   kill_zombie(z)
 end

end

function back_to_title()
  local t4 = "music: on"
  if (music_off) t4 = "music: off"
  title_menu = {"try again : "..game_seed, "new game","enter seed",t4}
  pstate,title_menu_select = -1,1
  music(0)
end

function kill_zombie(z)
  if (z.state > 99) return
  z.ticks = 0
  z.in_hit = 0
  z.state = 100
  z.headx = z.x - 3
  if (z.hs == 132) z.headx = z.x + 3
  z.heady = z.y - z.bh+2
  z.hdy = 0
  z.hf = 1
  score += z.sc
  hud_z_comp += 1
end

function update_zombie(z)
  z.ticks += 1
  if (z.in_hit > 0) z.in_hit -= 1
  if (z.freeze > 0) z.freeze -= 1
  if (z.state == 0) then
    --moving
    if (z.freeze < 1) then
      z.x -= z.dx
      z.f += abs(z.dx)
      if (z.f > 1.99) z.f = 0
      if (z.dx < 0.25) then
        if (rnd(100) < 3) z.freeze = flr(rnd(6))
      end
    end
    if (z.x < -7) then
      pstate,ticks = 100,0
    elseif (z.x < 6) then
      if (mower_stat[z.r+1] == 1) then
        kill_zombie(z)
        add(mowers,{-1,z.r*10+yo+2,z.r})
        mower_stat[z.r+1] = 0
        sfx(13,0)
      end
    end
    if z.freeze < 1 then
      for p in all (plants) do
        if p.y == z.r and p.id < 9 then
          local offx = 7
          if (z.id == 3 and z.has_pole) offx = 10
          if (z.dx < 0) offx = 3
          if hitc(p.sx+offx,p.sy,z) then
            if z.id == 3 and z.has_pole then
              --pole vault
              z.state,z.ticks = 60,0
              z.px,z.py,z.f = z.x,z.y,0
            elseif z.id == 7 and z.dx > 0 then
              --dig
              z.state,z.ticks = 70,0
              set_z_sprite(147,128,z)
            else
              z.p = p
              z.state = 50
              set_z_sprite(z.es,z.hs,z)
              z.f = 0
            end
          end
        end
      end
    end
  elseif (z.state == 40) then
    --enrage
    z.dmg,z.dx = 4,0.25
    if (z.ticks > 35) z.state,z.ticks = 0,0
  elseif (z.state == 50) then
    --eating plant
    z.f += rnd(0.2)
    if (z.f > 1.99) z.f = 0
      
    if ((z.p.id == 6) and (z.p.state > 40)) then
      if (z.p.state < 42) z.p.state = 42
    end
    
    if (ticks % 30 == 10) then
      sfx(2,3)
      if (z.p.gone) then
        z.p = nil
        z.state = 0
        set_z_sprite(z.bs,z.hs,z)
      else
       z.p.hp -= z.dmg
       z.p.dmgf = 2
       if (z.p.hp < 0.1) then
         kill_plant(z.p)
         z.p = nil
         z.state = 0
         set_z_sprite(z.bs,z.hs,z)
       end
      end
    end
  elseif z.state == 60 then
  	-- start of pole vault
  	z.x -= 0.5
  	if (z.ticks > 1) z.f,z.ticks,z.state,z.dy = 0,0,61,0
  elseif z.state == 61 then
   set_z_sprite(163,73,z)
   z.hxo,z.hyo = 5,-2
   z.x -= z.dx
   z.dy -= 0.025
   if (z.dy < -0.5) z.dy = -0.5
   z.jy += z.dy
   if (z.ticks > 25) z.ticks,z.state = 0,62
  elseif z.state == 62 then
   z.x -= (z.dx*2)
   if (z.ticks > 11) then
     z.ticks,z.state = 0,63
     set_z_sprite(164,70,z)
     z.hxo,z.hyo = 0,-z.hh+2
   end
  elseif z.state == 63 then
   z.x -= (z.dx * 2)
   z.dy += 0.1
   if (z.dy > 1) z.dy = 1
   z.jy += z.dy
   if (z.jy >= 0) then
     z.jy = 0
     z.state,z.ticks,z.dx,z.has_pole = 0,0,0.075,false
     set_z_sprite(165,70,z)
     z.es = 168
   end
  elseif z.state == 70 then
   -- digging
   z.f += 0.25
   if (z.f > 1.99) z.f = 0
   if z.ticks > 89 then
     z.state,z.ticks = 71,0
     z.f = 3
     z.oldhyo = z.hyo
     z.hyo += 3
   end
  elseif z.state == 71 then
    if (z.ticks >= 3) then
      z.f += 1
      z.hyo += 3
      z.ticks = 0
      if (z.f == 5) then
        set_z_sprite(147,136,z)
      elseif (z.f >= 6) then
        z.f,z.state = 0,72
        set_z_sprite(153,136,z)
      end
    end
  elseif z.state == 72 then
    -- moving underground
    z.x -= z.dx*2
    z.f += 2*abs(z.dx)
    if (z.f > 1.99) z.f = 0
    if (z.x <= 6.25) then
      set_z_sprite(155,136,z)
      z.ticks,z.state,z.f = 0,73,0
    end
  elseif z.state == 73 then
    --coming up
    if z.ticks > 2 then
      z.f += 1
      z.hyo -= 3
      z.ticks = 0
      if (z.f == 1) then
        set_z_sprite(155,132,z) 
      end
      if z.f >= 3 then
        z.state,z.f = 74,0
        set_z_sprite(176,132,z)
        z.bs,z.es,z.hs = 176,179,132
        z.hyo = z.oldhyo
      end
    end
  elseif z.state == 74 then
    -- pause then keep walking
    --but to the right
    if (z.ticks > 30) then
      z.ticks,z.state,z.dx = 0,0,-0.075
    end
  elseif z.state == 100 then
    --start death
    if (z.ticks > 5) z.state,z.ticks = 101,0
    z.f += 0.05
    if (z.f > 1.99) z.f = 0
  elseif z.state == 101 then
    z.f += 0.05
    if (z.f > 1.99) z.f = 0
    z.hf += 0.25
    if (z.hf > 3.99) z.hf = 0
    if z.hs != 132 then
      z.headx -= 0.15
    else
      z.headx += 0.15
    end
    
    z.hdy += 0.015
    if (z.hdy > 0.7) z.hdy = 0.7
    z.heady += z.hdy
    if (z.heady > z.y) z.ticks,z.state, z.f = 0,102,2
  elseif (z.state == 102) then
    if (z.ticks > 37) then
      del(zombies,z)
    end
  end
  
  if (z.state < 100 and z.state != 72) then
     for b in all(bullets) do
      if (hit(z,b)) then
        damage_zombie(b.dmg,z)
        sfx(1,2)
        del(bullets,b)
        if (z.hp < 0.1) then
          kill_zombie(z)
        else
          z.in_hit = 5
          if (z.hat == 100 or z.hat == 105) then
            z.freeze,z.fc = default_freeze,0
          else
            if (z.freeze < b.freeze) z.freeze = b.freeze
            if (z.fc == 0) z.fc = b.freeze_c
          end
        end
      end
    end
  end
end

function change_sun(amt)
  if (psun_dest < 0) then
    psun_dest = psun + amt
  else
    psun_dest += amt
  end
end

function _update()
 ticks += 1
 
 if (pstate == -5) then
   if (btnp(0) and seed_c > 1) seed_c -= 1
   if (btnp(1) and seed_c < 8) seed_c += 1
   if (btnp(2) and seed_m[seed_c] < 16) seed_m[seed_c] += 1
   if (btnp(3) and seed_m[seed_c] > 1) seed_m[seed_c] -= 1
   if (btnp(5)) pstate,title_menu_select = -1,1
   if (btnp(4)) then
     local sd = ""
     for i = 1,8 do
       c = seed_m[i]
       sd = sd..sub(hex,c,c)
     end
     game_seed = sd
     start_game(game_seed)
   end
   return
 end
 if (pstate == -1) then
   -- title screen
   if (btnp(2) and title_menu_select > 1) title_menu_select -= 1
   if (btnp(3) and title_menu_select < #title_menu) title_menu_select += 1
   if btnp(4) or btnp(5) then
     if (#title_menu == 3) title_menu_select += 1
     if (title_menu_select == 1) start_game(game_seed)
     if (title_menu_select == 2) new_game()
     if (title_menu_select == 3) pstate = -5
     if (title_menu_select == 4) then
       music_off = not music_off
       if (music_off) title_menu[#title_menu] = "music: off"
       if (music_off == false) title_menu[#title_menu] = "music: on"
     end
     if (#title_menu == 3) title_menu_select -= 1
   end
   return
 end
 
 if pstate == 5 then
   if (btnp(2) and pause_menu_select > 1) pause_menu_select -= 1
   if (btnp(3) and pause_menu_select < 2) pause_menu_select += 1
   if btnp(4) or btnp(5) then
     if pause_menu_select == 1 then
       pstate = 0
     else
       back_to_title()
     end
   end
   return
 end
 
 if pstate == 6 then
   if ticks > 30 then
    if score < score_final then
      score += score_delta
      sfx(11,1)
      if (score > score_final) score = score_final
    end
   end
   if (ticks > 59 and (btnp(4) or btnp(5))) next_level()
   return
 elseif pstate == 8 then
   for z in all(l_zombies) do
     z.f += z.dx
     if (z.f > 1.99) z.f = 0
   end
   if ticks > 30 and (btnp(4) or btnp(5)) then
     pstate,ticks = 0,0
     if (g_eclipse) eclipse_ticks = 100
   end
   return
 end
 --pstate = 100 --testing
 global_sun -= 1
 if global_sun < 1 then
   global_sun = 360 + flr(rnd(200))
   add_sun(6+flr(rnd(4)),0)
 end
 
 if emticks > 0 then
   emticks -= 1
   if (emticks < 1) event_message = ""
 end
 
 if psun_dest >= 0 then
   if psun < psun_dest then
     psun += 1
   elseif psun > psun_dest then
     if psun - psun_dest > 30 then
       psun -= 5
     else
       psun -= 1
     end
   end
   sfx(11)
   if psun == psun_dest then
     psun_dest = -1
   end
 end
 
 if (mess_ticks > 0) mess_ticks -= 1
 if mess_ticks < 1 and #message > 0 then
   message = sub(message,2,#message)
   mess_ticks = 3
 elseif #message == 0 and #zombies > 0 then
   if (rnd(100) > 99) then
     if (rnd(10) > 6) then
       add_message("brains...")
     elseif (rnd(10) > 6) then
       add_message("arrgghhh...need brains!")
     elseif (rnd(10) > 5) then
       add_message("mmmhhmm. brains good...")
     end
   end
 end
 
 for i = 1,8 do
   if (cards_ct[i] > 0) cards_ct[i] -= 1
 end
 
 if pstate == 100 then
   if (btnp(4)) back_to_title()
   return
 end
 
 if pstate == 10 then
   --pick what to plant
  if (btn4_up == false) btn4_up = not btn(4)
  if mticks < 1 then
   
    if btn(1) then
      if pselect < max_plants then
        pselect += 1
        sfx(10,1)
        mticks = next_m_ticks
      end
    elseif btn(0) then
      if (pselect > 0) then
        pselect -= 1
        sfx(10,1)
        mticks = next_m_ticks
      end
    elseif btn(3) then
      px,py,pstate,mticks = flr((pselect*12+16)/8),0,0,4
      if (px > 13) px = 13
      sfx(11,1)
    elseif btn(4) and btn4_up then
      if (do_plant()) pstate,mticks = 0,4
    elseif btnp(5) then
      pstate,mticks = 0,4
    end
    
    if (pstate == 10 and mticks > 0) next_m_ticks = 2
  else
    mticks -= 1
    if not (btn(0) or btn(1) or btn(2) or btn(3)) then
      mticks,next_m_ticks = 0,4
    end
  end
 else
  if mticks < 1 then
   if btn(0) then
     if (px > 0) px -= 1
     mticks,ticks = next_m_ticks,0
   elseif btn(1) then
     if (px < 13) px += 1
     mticks,ticks = next_m_ticks,0
   end
   if btn(2) then
     if (py > 0) then
       py -= 1
     end
       --pstate,mticks,next_m_ticks = 10,4,2
       --sfx(11,1)
       --pselect = mid(0,flr((px - 1.5) / 1.5),7)
       --if (px == 13) pselect = 8
       --if (pselect > max_plants) pselect = max_plants
     --end
     mticks,ticks = next_m_ticks,0
   elseif btn(3) then
     if (py < 6) py += 1
     mticks,ticks = next_m_ticks,0
   end
   if (mticks > 0) next_m_ticks = 2
  else
    mticks -= 1
    if not (btn(0) or btn(1) or btn(2) or btn(3)) then
      mticks = 0
      next_m_ticks = 4
    end
  end
  
  if btnp(4) then
    pstate,mticks,btn4_up = 10,4,false
    sfx(11,1)
  elseif btnp(5) then
    pstate,pause_menu_select = 5,1
    sfx(11,1)
  end
 end
 
 zticks += 1
  
 foreach(plants,update_plant)
 foreach(zombies,update_zombie)
 foreach(bullets,update_bullet)
 foreach(sun,update_sun)
 foreach(mowers,update_mower)
 foreach(meteors,update_meteor) 
 
 for w in all(wave) do
   if (zticks > (w[3]*30)) then
     if (w[3] < 0 and #zombies > 0) then
       break
     else
      if (szc == 0) add_message("the zombies are coming...")
      if (w[3] < 0) add_message("a huge wave of zombies are approaching...")
      add_zombie(w[1],15,w[2])
      zticks = 0
      del(wave,w)
      szc += 1
     end
   else
     break
   end
 end
 
 if #wave == 0 and ltimer > 0 and #zombies < 4 and level > 2 then
   ltimer -= 1
   ltma = true
 end
 
 if #wave == 0 and (#zombies == 0 or ltimer < 1) then
   pstate,ticks,messages = 6,0,""
   level_bonus = level * 25
   score_final = score + level_bonus
   score_delta = ceil(level_bonus / 20)
   level += 1
 end
 
end
__gfx__
00000000eeeeeeeeeaeeaeeeeeeeeeeeeeeeeeeeeee9a9eeee9a9eeeeeeaaaeeeee7a7eeee44ee4e0ee0e00eeee0e0eeeeeee0eeeeeeeeeeeeeeeea8eeeeee8a
00000000eeeeeeeeeeaaaaeaeeeeeeeeeeeeeeeeeea040aeea040aeeeea545aeeea6f6aee4444444e0000080e0000000e000000eeeeeeeeeeee88a8eeeea88ae
00700700eeeaaeeeeaaaaaaeeee50eeeeee10eeee94444499444449eea44444ae7fffff74440444400800000e0800080e0800000eeee00eee8a8888ee888808e
00077000eea99aeeaaa99aaeee5bb0eeee1cc0eeeea000aeea000aeeeea555aeeea666ae4444440400008000000080000000800eee00800ee88808eee888089e
00077000eea99aeeeaa99aaaee5bb0eeee1cc0eeeee9a9eeee9a9eeeeeeaaaeeebb7a7bee44404440008000000000000e0000000e00000ee8800889e8800889e
00700700eeeaaeeeeaaaaaaeeee50eeeeee10eeeebbe3ebebbe3eebbebbb3ebbebbb3bbee404444ee080080ee000080ee000080eee0e000e800089ee880088ee
00000000eeeeeeeeaeaaaaeeeeeeeeeeeeeeeeeeebbb3bbbebbb3bbeeebb3bbeeeeb3bbe4444044e00000000000000eeee0000eeeee00eee88008eee88888eee
00000000eeeeeeeeeeeaeeaeeeeeeeeeeeeeeeeeee5bb00eee5bb00eee50b00eee00b00e4e444eeeee000e0eeeeeeeeeeeeeeeeeeeeeeeeee8888eeee8888eee
ddddddddddddddddddddddddeeebbebeeebbebeeececcecececceceebbbbbebebbbbebeeee4444eeee4444eeeeeeeeeeeeeeeeeeeee78eeeeee76eeeeee999ee
ddddddddddddddddddddddddebbb0b0bbbb0b0beeecc0c0cecc0c0ceeebb2b2bebb2b2bee444444ee444444eee0760eeee07a0eeee7888eeee7666eeee9999ee
ddddddddddddddddddddddddeebbbb0bebbbb0beeccccc0cccccc0ceebbbbb2bbbbbb2bee4444477e4444470e076660ee07a990eee4784eeee4764eeee9ff99e
ddddddddddddddddddddddddeeebbebeeebbebeeeeecceceeecceceebeebbebebebbebee44774470447044775047600050479000e444444ee444444ee949ff9e
ddddddddddddddddddddddddeeeebeeeeeebeeeeeeeeceeeeeeceeeeeebebeeeeeebeeeb44704444447744445446640054466400444444044444440499fffff9
ddddddddddddddddddddddddebbe3ebebbb3eebbeebe3eebebe3eebeebbe3ebbbbb3eebb44444444444444445504400055044000444044444440444499fffff9
ddddddddddddddddddddddddbbbb3bbbebbb3bbbebbb3bbeebbb3bbbeebb3bbbebbb3bbe4444444444444444e550000ee550000e544444445444444459ffff49
dddddddddddddddddddddddde55bbb0be55bbb0ee55bbb0ee55bbb0ee50bbb00e55bbb0e0444444004444440eee50eeeeee50eee555444405554444055594990
eee999eeeee999eeebbbbbbbebbbbbbb8888e88ee888e88eeeeeeeeeeeeeeeee00000000666e666e666ee66600000000fff77777ee6655ee0000000033777777
ee9999eeee9999eeebbbbbeeebbbbbee8888e88888888888eeeeeeeeeeeeeeee00000000888e888e888ee88800000000ff666666ee7ee5ee0000000033636666
ee9ff99eee9ff99ebbeeeeeebbeeeeeee888888888888888eeeeeeeeeeeeeeee00000000888e808e888e878e00000000ff7f7777eee65eee0000000033777777
e949ff9ee949ff9eebb8888eebb9999ee8888888ee888888eeeeeeeeeeeeeeee00000000880e878e887e808e00000000ffff7777eee65eee0000000033377777
99fffff999fffff9ee877888ee9779998888888e8888888eeeeeeeeeeeeeeeee00000000e878888ee808888e00000000ff777776e766655e0000000033777776
99fffff999fffff9ee870887ee9709978888888888888888eeeeeeeeeeeeeeee00000000e588885ee588885e00000000fff76677e766665e0000000033376677
59ffff4959ffff49ee888888ee999999888888888888888e777775777577577700000000500bb005500bb00500000000ff777777ee7665ee0000000077777777
5559499055594990ee88888eee99999eee8e888e88ee888e777767677767676700000000e500005ee500005e00000000fff77777eee75eee0000000076777777
ccccc0ccccccc0cccccccccc777777777777777777777777777757777775677722222222eeeeeeeeeeeeeeee000000003377777733777777ff77777733777777
cccc770ccccc770ccccccccc776666666777777777677777777767777777677722222222eeeeeeeeeeeeeeee000000003363666633666666ff66666633636666
ccc77770ccc77770cccccccc667777777767667777777777767767777677677722222222eeeeeeeeeeeeeeee0000000033377777ff777777fff7777733777777
ccc7777077777770cccccccc777777777777777677777777777767777777677722222222eeeeeeeeeeeeeeee0000000033777777fff77777ff77777733377777
bcc7777000077770cccccccc777777767777777777777777777767777777676722222222eeeeeeeeeeeeeeee0000000033777776ff7777763377777633777776
bbb77770bbb77770bccccbbc776766776677777777677767777677777777677722222222eeeeeeeeeeeeeeee0000000033376677fff766773337667733376677
bbb7777077777770bbccbbbb67777777776666667777777777767767767776772222222222222222222222220000000033337777ff77777733777777ffff7777
bbb7777000077770bbbcbbbb77777777777777777777777777777777777777772222222222222222222222220000000033777777fff7777733377777fff77777
eee6665eeeeeeeeeee66eeeeeeeeeeeeeeeeeeeeeeeeeeeeee66999eeeeeeeeeeee66eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8888ee88888eee
ee666665e5555eeee7005eeeeee5555eeeeeeeeeee77755eecccccceee99e9eeee5000eeee6607ceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee877878e88f88eee
e7766775567765ee600765eeee567765ee9aeeeee7666115e77607999c9999ee9960706ee00677c6ee6665eeeee5555eee5666eee6607eee888888888f4f8eee
e70660756670665e6666665ee5660766ee99aeeee7666115e07677999c77665ee966666e607666c9e776775eee577665e566706e606776ee8eeeee8788888eee
e6666665666667067066075e60766666ee99aeee06661105e666669e9c0760069977670e600670c9e076075eee670666e566666e676666ee5eeeee58eeee1eee
e600765e666660067766775e60066666e9999aee7066105ee60706999c6667069970677ee56677c9e666665eee666676e570670e666076ee55555587eeee1eee
ee7005eee670607ee666665ee706076ee9999aee7600015eee0005ee6c77600eecccccceee9999c9e607665eee677606e577677e566775ee5eee5e8eeeee1eee
eee66eeeee7766eeee6665eeee6677ee999999ae7775555eeee66eeeec7066eee99996eeee9e99eeee6665eeeee7066eee5666eee5555eeee55555eeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeee
ee6844eeee6844eeeeeeeeeeee6844ee546844eeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeee
ee48444eeee8444eeee45eee5448444eee48444eeee45eeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeee
e4e8440eee854444ee444664eee5000eee50004eee444664ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeee
e5e4504eeee44445e4444664eee4444eeee4444ee4444664ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeee
ee11466eeee1166ee4444164eee1166eeee1166ee4444164ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeee
e411e66eee41666ee8854114ee41666eee41666ee8854114ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeee
e444e444ee44444ee6e8ee44ee44444eee44444ee6e8ee44ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeee
eee660e00e6055eeee58766eee660eee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77755eeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddd
ee00660ee067065ee568866e666076ee060eee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7700055eeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddd
e666666606677665566666666667760e060e0060eee88eeeeeeeeeeeeeeeeeeeeeeeeeee7000005eeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddd
0776677066660688507007067860660605606660eee88eeeeeeeeeeeeeeeeeeeeeeeeeee7600065eeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddd
6070070560660687077667708860666606666560eee88eeeeeeeeeeeeeeeeeeeeeeeeeee7766655eeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddd
66666665e06776666666666e5667766006565660eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7675565eeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddd
e668865eee670666e06600eee560760ee066600eeee88eeeeeeeeeeeeeeeeeeeeeeeeeee7666665eeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddd
e66785eeeee066ee0e066eeeee5506e0ee000eeeeeeeeeeee8866777e8866777eeeeeeee7777555eeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddd
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5888877e5888877eeeeeeeee588887785888877eeeeeeee00000000000000000000000000000000
eee111eeeee111eeeeeeeeeeeee111eeeee111eeeeeeeeeee5e7888eee57888e7eeeeeee8ee7888eeee7888e7eeeeeee00000000000000000000000000000000
ee55155eee55155eeeeeeeee6555155eee55155eeeeeeeee8ee7858eee87858e788eeeeeee85558ee855588e788eeeee00000000000000000000000000000000
e5e5150eee55600eee505eeeeee5600ee5e5505eee505eeeeee857eeeee885ee88558785eee88eeeee8888ee8855878500000000000000000000000000000000
e6e5605eee65555ee1505765eee5555ee6e6005ee1505765ee77e77eeee778ee888877e5eee777eeeee7777e8888eee500000000000000000000000000000000
ee77577eeee777eee11657e5eee777eeeee777eee11657e5ee77e77eeee777ee87787785eee777eeeee7e77e8778778500000000000000000000000000000000
e56eee6eeee6e6eee1555765eee6e6eeeee6e66ee15557656e8e6e8ee6e8e8ee858eeee5e6e8e8eee6e86e8e858eeee500000000000000000000000000000000
e555e55eee5555eeee556ee5ee5555eeee55e55eee556ee5555e555ee55555ee5eeeee65e55555eee555e55e5eeeee6500000000000000000000000000000000
eeeeeeeeee8855eeee5007eeeeeeeaaeeeeeeeeeeaaeeeeeee7005eeee5588eeeeeeeeee00000000000000000000000000000000000000000000000000000000
aa08888ee888765ee560066ee6677aaee88880aaeaa7766ee660065ee567888eeeeeeeee00000000000000000000000000000000000000000000000000000000
aa088888e88706655666666e7660700e888880aae0070667e66666655660788eeeeeeeee00000000000000000000000000000000000000000000000000000000
e7766788e88666005706607e0066688e8876677ee8866600e70660750066688eeeeeeeee00000000000000000000000000000000000000000000000000000000
e7066075e88666008876677e0066688e5706607ee8866600e77667880066688eeeeeeeee00000000000000000000000000000000000000000000000000000000
e6666665e0070667888880aa5660788e5666666ee8870665aa0888887660700eeeeeeeee00000000000000000000000000000000000000000000000000000000
e660065eeaa7766ee88880aae567888ee560066ee888765eaa08888ee6677aaeeeeeeeee00000000000000000000000000000000000000000000000000000000
ee7005eeeaaeeeeeeeeeeeeeee5588eeee5007eeee8855eeeeeeeeeeeeeeeaaeeeeeeeee00000000000000000000000000000000000000000000000000000000
e00eeeeee0eeeeeeeeeeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
00e1888e0ee1888eeeeeeeee0ee1888eeee1888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
0e01888800e18888ee81811500e18888e0e18888ee818115eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000
0e1005110e008881e88181150e0088810ee58881e8818115eee1888eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8881eeeeeeee00000000
0e5e88880ee80518e88588ee0ee805180ee00518e88588eeeee18888eeeeeeeeaa08888eeeeeeeeeeeeeeeeee88880aaeeeeeeeeeee88881eeeeeeee00000000
eee118110eee111ee88e81150eee111ee00e111ee88e8115eee58881eeeeeeeeaa088888eeeeeeeeeee4eeee888880aaeeeeeeeeeee18885eeeeeeee00000000
ee511e11eeee111ee1115115eeee111ee0ee111ee1115115e4ee8518e4e18881e7766788e4eeee4eee4ee4ee8876677e4e18881ee4e8158eeeeeeeee00000000
ee555e55eee5555eeeeeee55eee5555eee05555eeeeeee554e4411144514888547066075444444444444444457066074545888414e441114eeeeeeee00000000
5eeeeeeee5eeeeeeeeeeeeeeeeeeeeeee5eeeee5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
ec5555eeec5555eeeeeeeeeeeeee5ceeec5555eceee555eeeee555eeeeeeeeeeeee555eeeee555eeeeeeeeee0000000000000000000000000000000000000000
eee8588eeee8588eeeeeeeee88eec5eeeee85885ee58588eee58588eeeeeeeee5c58588eee58588eeeeeeeee0000000000000000000000000000000000000000
eee8885eeee8885eee85c5e88758585eeee8888eece8885eee58885eee85c5e8eee5c58eece85c5eee85c5e80000000000000000000000000000000000000000
eee85c8eeee888cee58885788758555eeee8888ee5e85c8eeee888cee5888578eee888ee5ee888eee58885780000000000000000000000000000000000000000
ee55855eeee5555ee55885788758885eee55855eee55855eeee5555ee5588578eee555eeeee555eee55885780000000000000000000000000000000000000000
e877e77eee8777eee58885788e8888eee877e77ee877e77eee8777eee5888578ee8777eeee8777eee58885780000000000000000000000000000000000000000
e888e888ee88888ee5c5ee88eeeeeeeee888e888e888e888ee88888ee5c5ee88ee88888eee88888ee5c5ee880000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee8881eeee8881eeeeeeeeeeee8881eeee8881eeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee88881eee88881eeeeeeeeeee888881ee88881eeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee115881ee18885eeee818eeee111585ee81115eeee818ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee888885ee81588e5111888eee88888eee88888e5111888e00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee11811eeee111ee5115888eee1111eeeee111ee5115888e00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee11e115eee111ee5118888eee11e11eeee111ee5118888e00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee55e555eee5555e5ee8511eee55e555eee5555e5ee8511e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeeeeeeeee6665ee88880aae5666eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88888eee01111111111111111111111077777777777777777777777777777777
0eeeeeeeee666665888880aa566666eeeeeeeeeee55555555555555eeeeeeeee88f88eee1dddddddddddddddddddddd177777777777777777777777777777877
e0eeeeeee77667758876677e5776677eeeeeeee556666666666666655eeeeeee8f4f8eee1d00000000000000000000d177888788878787888778787777787877
e0eeeeeee70660755706607e5706607eeeeee5566666666666666666655eeeee88888eee1d00000000000000000000d177877787878787878787878777877877
ee0e888ee66666655666666e5666666eeeee566666666666666666666665eeee1eeeeeee1dddddddddddddddddddddd177888788878787878787878787877877
ee888888e600765ee560066ee567006eeee56666666666666666666666665eee1eeeeeee01111111111111111111111077778787778787878787878787877777
ee888888ee7005eeee50070eee5007eeee5666666656665666566566666665ee1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77888787778887887778777878777877
ee808808ee6844eee8881ee0ee4486eeee5666666666666666666666666665eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77777777777777777777777777777777
ee48444eeee8444e88881e00e4448eeeee5666666666666666666666666665eecccccccc33333333cccccccccccccccceeeeeeeeeee44444eeeeeeeeeeeeeeee
e4e8440eee854444188800e0444458eeee5666666666666666666666666665eecccccccc33333333cccccccccccccccceeeeeeeeee44fff44e444eeeeeeeeeee
e5e4504eeee4444581508ee054444eeeee5666665665656665665665666665eecccccccc33333333cccccccccccccccceeeeeeee444fffff444f4444eeeeeeee
ee11466eeee1166ee111eee0e6611eeeee5666666666666566666666656665eecccccccc33333333cccccccccccccccceeeeeee44ff44fff4ffffff44eeeeeee
e411e66eee41666ee111eeeee66614eeee5666656656666666566666666665eecccccccc33333333cccccccccccccccceeee44444f44fffffff44fff4e444eee
e444e444ee44444ee5555eeee44444eeee5666666666566656666656666665eecccccccc33333333cccccccccccccccceee44fffff4ffffffffffff444fff44e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5666666666666666666666666665eecccccccc33333333cccccccccccccccceee4fffffffff444fffff4ffff4fff44
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee5666666666666666666666666665eecccccccc33333333cccccccccccccccceee4ff4ffffffffffffffff4ff44fff4
0000000000000000eeeee555777eeeeeee5666666666666666666666666665eeccccccccccccccccccccccccccccccccee4ffffffffffff4ffff444ffff4fff4
0000000000000000eee5566666677eeeee5666666666666666666666666665eeccccccccccccccccccccccccccccccccee4fffffff44ff4f4ff4ffff4ff4ff44
0000000000000000ee566666666667eeee5666666666665666665666666665eeccccccccccccccccccccccccccccccccee444fff44ffffffffffffff4fffff4e
0000000000000000ee566666666667eeee5666665665666666566665666665eecccccccccccccccccccccccccccccccce4f4ffff4fffffffffffffffffff444e
0000000000000000ee566656567667eeee5666666666666566666666656665eecccccccccccccccccccccccccccccccce444ffffffff44ffff444ffffffffff4
0000000000000000ee566666656667eeee5666666665666666666566666665eecccccccccccccccccccccccccccccccce4fff4ffff44ff4fff4ffffff44ffff4
00000000eeeeee0eee566665666667eeee5666656666666665666665666665eecccccccccccccccccccccccccccccccce4fffffff44ffffff4ffffff44fffff4
00000000e8881ee0ee566666666667eeee5666666666666666666666666665eecccccccccccccccccccccccccccccccce44fffffffffffffffffffffffffff4e
00000000eeeeeeeeee566666666667eeee5666666666666666666666666665eecccccccccccccccccccccccccccccccc55555555555555555555555555555555
00000000e88880aaee565656665667eeee5666666666666666666666666665eecccccccccccccccccccccccccccccccce666666666666666666666666666666e
00000000888880aaee566666566667eeee5666666666666666666666666665eecccccccccccccccccccccccccccccccceeeee6666666666666666666666eeeee
000000008876677eee066666666665eeee5666666666666666666666666665eecccccccccccccccccccccccccccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
000000005706607eee066666666665eeee5666555555555555555555556665eecccccccccccccccccccccccccccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
000000005666666eee066565565665eeee5666666666666666666666666665eecccccccccccccccccccccccccccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000e560066eee066666666665eeee5666666666666666666666666665eecccccccccccccccccccccccccccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000ee5007eeee000005555555eeee5555555555555555555555555555eecccccccccccccccccccccccccccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000000000000000d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
39393939393939393939393939393939d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
38383838383838383838383838383838d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
38383838383838383838383838383838d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30313131313131313131313131313132d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8d8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3400000000000000000000000000003c32323031313131313131313131313132000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3400000000000000000000000000003dd9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3400000000000000000000000000003ed9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3400000000000000000000000000003fd9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3400000000000000000000000000002cd9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3300000000000000000000000000003cd9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3300000000000000000000000000003dd9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3300000000000000000000000000003ed9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3326272627262727262627272627262fd9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3336373637363737363637373637363436363636363636363737373737373737000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
282828282828c9cacacacacacacacacb35353535353535353535353535353535000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000011450124501345017450194501b4401d43020420234102441021300243002530027300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000196550d65009655096050a6000e6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002b635306353c635346353462532605341052a635306352c625336052f10530635366353063532605000052f60531635366303363033300000002e630316302b640000002563025630216300000033600
000200002235022360223602236022360223602236022360223602236022360223602235022350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002725027250272502725027250272502725027250272502725027250272500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001e6502365024650296502e650346503b6503f650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000324503445036450394503c4503d4500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000236502365023650236502365023650236502365024650256502665027650286502b6502d65032610386503e6503e6503c65039650326502a650236501a650196501b6001760014600116001060000000
00010000082500b2500f25014250192501c2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000036350383403a3403c3303e3303f3203f3203f310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002732000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002e3302e320133200b3200b3500b3500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600003763037630346303664000040366400004036640000403664036640000400004036640000003763000030356400004000040376403764000040000003863000030376300003038630000400004038630
00020000211301c1301913015130121300d1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0011000007730077350e7300e7350d7300d7350e7300e735137301373510730107301073010730107301073010730107301073010730107301073010730107301073010730107301073010730107301073010730
001100002574025745267402674525740257452674026745227402274022745220002200022000220002200022740227402274522700227002600026000260002674026740267450070000700007000000000000
001100000070000000000000000000000000001700017000170001f0001f740007001f720007001f71000700177001f7001f740007001f720007001f710170001f0001f0001f740007001f720007001f71000700
0012000007730077350e7300e7350d7300d7350e7300e73513730137351073010730107301073010730107301073010730107301073010730107301070010700107001070010730107300e7300e7300a7300a730
001200000c7300c7300c7300c7300c7300c7300c7300c7300c7300c7300c7300c7350a7300a735097300973009730097300973009730097300973009730097300973009730097300973009730097300900009000
0012000021740217402274022740217402174022740227401f7401f7401a7401a7401874018740167401674019740197401a7401a7401f7401f7402274022740257402574026740267402b7402b7402e7402e740
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001055010550105501055010550105501355013550135501355013550135500b5500b5500b5500b5500b5500b5501355013550135501355013550135501055010550105501055010550105501355013550
000c00000000000000000000000000000000001755017550175501755017550175500000000000000000000000000000001755017550175501755017550175500000000000000000000000000000001755017550
000c0000135501355013550135500b5500b5500b5500b5500b5500b5501355013550135501355013550135500955009550095500955009550095501055010550105501055010550105500b5500b5500b5500b550
000c00001755017550175501755000000000000000000000000000000017550175501755017550175501755000000000000000000000000000000015550155501555015550155501555000000000000000000000
000c00000b5500b550125501255012550125501255012550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00000000000000165501655016550165501655016550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00001055410550105551355413550135551055410550105551355413550135500b5540b5500b5551355413550135550000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 18 19 1a 44
00 18 19 1a 44
00 1b 19 1a 44
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
01 20 21 43 44
00 22 23 43 44
02 24 25 43 44
00 30 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
