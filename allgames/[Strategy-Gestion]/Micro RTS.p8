pico-8 cartridge // http://www.pico-8.com
version 10
__lua__
-- todo
-- fog of war
-- icons for resources/status
-- construction icon when leveling up
-- more fanfare when win or lose
-- tutorial
-- allow to replay a map
-- menu option to restart map
-- stalemate ending?


buildings = {}
minions = {}
game_ticks = 0
min_max = {0,2,2,3}
min_effic = {0,0.1,0.3,0.4}
war_max = {4,6,8}
wood_req = {2,4,8}  -- 5
wood_max = {8,12,16}
cfog = {}
build_ticks = {300,1000,2400}
war_ticks = 240 -- 150
bmsg = ""
battle_dmg = 1
war_hp_max = 15
diff = 1
difft = {"  daddy can i play?", "    don't hurt me","i am death incarnate"}
moff = 0
omsg = "                                defeat all enemy towers to win. build towers to expand. attack enemies by selecting your tower, then the enemy tower you wish to attack. half your troops will attack. press twice to send more. upgrade your towers to increase productivity and defences. good luck!!                                "
cab = 0
last_attack = 0
chop_wood_time = 150 -- 150
deliver_wood_time = 60 -- 60
minion_speed = 0.2 -- 0.2
war_speed = 0.2

cs = {}
cs.x = 0
cs.y = 0
cs.st = 0
cs.b = nil
cs.bt = 0
cs.ab = {}
cs.sb = nil
cs.tb = nil
game_state = 0
imsg = ""
smsg = {}
smsg[1] = ""
smsg[2] = ""

nodes = {}
gls = 0

function init_nodes()
  for x = 1,17 do
    nodes[x] = {}
    for y = 1,15 do
      nodes[x][y] = 0
    end
  end
end

function new_ps(sx,sy,tx,ty,par)
  ps = {}
  ps.x = sx
  ps.y = sy
  ps.g = 0
  ps.h = abs(tx-sx) + abs(ty-sy)
  ps.parent = par
  if (par != nil) then
    ps.g = 10 + par.g
  end
  ps.f = ps.g+ps.h
  return ps
end

function get_lowest_node(o)
  rn = nil
  for n in all(o) do
    if ((rn == nil) or (n.f < rn.f)) then
      rn = n
    end
  end
  return rn
end

function close_node(o,n)
  nodes[n.x+1][n.y+1] = gls+2
  del(o,n)
end

function passable(x,y)
  if ((x < 0) or (x > 15)) return false
  if ((y < 0) or (y > 13)) return false
  return (not (impassable(x*8,y*8)))
end

function search_nodes(o,sx,sy)
  for n in all(o) do
    if((sx == n.x) and (sy == n.y)) then
      return n
    end
  end
  return nil
end

function is_open(sx,sy)
  if (nodes[sx+1][sy+1] == (gls + 1)) return true
  return false
end

function is_closed(sx,sy)
  if (nodes[sx+1][sy+1] == (gls + 2)) return true
  return false
end

function add_to_open(o,par,sx,sy,tx,ty)
  if (is_closed(sx,sy)) return
  ps = new_ps(sx,sy,tx,ty,par)
  on = nil
  if (is_open(sx,sy)) then
    on = search_nodes(o,sx,sy)
  end
  if (on == nil) then
    add(o,ps) 
    nodes[sx+1][sy+1] = gls+1 
  else
    if ((ps.g < on.g) or ((ps.g == on.g) and (rnd(1) > 0.49)))  then
      on.parent = par
      on.g = 10 + par.g
      on.f = on.g + on.h     
    end
  end
end

function find_path_a(o,tx,ty)
  
  while (true) do
  n = get_lowest_node(o)
  if (n == nil) then
    --failed to find
    return nil
  elseif ((n.x == tx) and (n.y == ty)) then
    --found target
    close_node(o,n)
    path = {}
    --printh("found target","path.txt",false)
    while (n.parent != nil) do
      ps = {}
      ps.x = n.x - n.parent.x
      ps.y = n.y - n.parent.y
      ps.mx = n.x
      ps.my = n.y
      --("add path:"..ps.x..","..ps.y ,"path.txt",false)
      add(path,ps)
      n = n.parent
    end
    return path
  else
    --printh("lowest node: "..n.f.." ("..n.x..","..n.y,"path.txt",false)
    close_node(o,n)
    -- up
    sx = n.x
    sy = n.y-1
    if (passable(sx,sy)) then
      add_to_open(o,n,sx,sy,tx,ty)
    end
    --right
    sx = n.x+1
    sy = n.y
    if (passable(sx,sy)) then
      add_to_open(o,n,sx,sy,tx,ty)
    end
    -- down
    sx = n.x
    sy = n.y+1
    if (passable(sx,sy)) then
      add_to_open(o,n,sx,sy,tx,ty)
    end
    --left
    sx = n.x-1
    sy = n.y
    if (passable(sx,sy)) then
      add_to_open(o,n,sx,sy,tx,ty)
    end   
  end
  end
end

function find_path(sx,sy,tx,ty)
  --printh("find path start ("..sx..","..sy..") - ("..tx..","..ty..")","path.txt",false)
  gls += 3
  if (sx < 0) sx = 0
  if (sy < 0) sy = 0
  
  if (sx > 15) sx = 15
  if (sy > 13) sy = 13
  
  ps = new_ps(sx,sy,tx,ty,nil)
  o = {}
  add(o,ps)

  
  nodes[sx+1][sy+1] = gls+1
  return find_path_a(o,tx,ty)
end


function dist(sx,sy,tx,ty)
  dx = abs(tx-sx)
  dy = abs(ty-sy)
  return sqrt(dx*dx+dy*dy)
end

function place_random(c,mc)
  for i = 1,c do
    x = flr(rnd(16))
    y = flr(rnd(14))
    mset(x,y,mc) 
  end
end

function random_dir()
  r = flr(rnd(6))
  if (r < 3 ) then
    return -1
  end
  return 1
end

function random_seg(s)
 s.dx = 0
 s.dy = 0
 
 s.dc = flr(rnd(3)+1)
 
 if (flr(rnd(6)) < 3) then
   s.dx = random_dir()
 else
   s.dy = random_dir()
 end
  
end

function make_simple_path(x1,y1,x2,y2)
  --printh("msp p start","rts_log.txt",false)
  cx = x1
  cy = y1
  dx = 0
  dy = 0
  mx = 0
  my = 0
  while (not((cx == x2) and (cy == y2))) do
    dx = x2 - cx
    dy = y2 - cy
    mx = 0
    my = 0
    --printh("msp delta="..dx..", "..dy,"rts_log.txt",false)
    
    if (dx == 0) then
      my = abs(dy)/dy
    elseif (dy == 0) then
      mx = abs(dx)/dx  
    else
      if (rnd(1) > 0.5) then
        my = abs(dy)/dy
      else
        mx = abs(dx)/dx
      end
    end
    
    --printh("msp d="..mx..", "..my,"rts_log.txt",false)
    
    cx += mx
    cy += my
    
    if (mget(cx,cy) < 16) then
      mset(cx,cy,1)
    end
  end    

end

function make_random_path(x1,y1,x2,y2)
  nx = flr(rnd(16))
  ny = flr(rnd(14))
  make_simple_path(x1,y1,nx,ny)
  make_simple_path(nx,ny,x2,y2)   
end

function gen_map(t,m,w)
  -- set all grass
		for x = 0, 15 do
		  cfog[x] = {}
		  for y = 0, 13 do
		    mset(x,y,1)
		    mset(x+32,y,144+15) --fog
		    cfog[x][y] = 1
		    if (x == 15) mset(x+33,y,144+15) --fog
		    if (y == 13) then
		      mset(x+32,y,144+15)
		      if (x == 15) mset(x+33,y,144+15) --fog
		    end  
		  end
		end
		
		place_random(w,7)
		place_random(m,9)
		place_random(t,2)
		
		x1 = flr(rnd(16))
  y1 = flr(rnd(14))
  mset(x1,y1,17)

		x2 = flr(rnd(16))
  y2 = flr(rnd(14))
      
  while (dist(x1,y1,x2,y2) < 6) do
		  x2 = flr(rnd(16))
    y2 = flr(rnd(14))
    --printh("gm l="..x2..", "..y2,"rts_log.txt",false)
    
  end
  
  mset(x2,y2,33)
  
  make_simple_path(x1,y1,x2,y2)
  make_random_path(x1,y1,x2,y2)
  place_random(12,2)
  make_random_path(x1,y1,x2,y2)
  
end


function building_ok(b)
  return ((b != nil) and (b.dead == false))
end

function closest_building_room(x,y,p)
  tb = nil
  td = 10001
  for b in all (buildings[p]) do
    d = dist(x,y,b.x*8,b.y*8)
    if (b.dead == false) then
      if ((b.l > 0) and (b.wc < war_max[b.l]) and (d < td)) then
        tb = b
        td = d
      end
    end
  end
  return tb
end

function find_wpos(b)
  n = 8/war_max[b.l] 
  pos = 0
  i = 1
  while (pos == 0) do
    if (b.warriors[i].a == 0) then
      pos = i
    else
      i = flr(i+0.5+n)
      if (i > 8) then
        i = i - 8
        i = i + 1
      end 
    end   
  end
  
  return pos
end

function transfer_warrior_to(w,b)
  b.wc += 1
  pos = find_wpos(b)
  dw = b.warriors[pos]
  dw.x = w.x
  dw.y = w.y
  dw.a = w.a
  dw.st = w.st
  dw.ticks = w.ticks
  dw.hp = w.hp
  w.a = 0 
end

function transfer_warrior(w)
  b = closest_building_room(w.x,w.y,w.p)
  if (b == nil) then
    return
  end 
  transfer_warrior_to(w,b)
end

function transfer(towers,tb)
		numt = 0
		fs = war_max[tb.l] - tb.wc
		--printh("tt fs="..fs,"rts_log.txt",false)
		if (fs > 0) then
    for t in all (towers) do
      if (t != tb) then 
        ib = get_half_warriors(t)
        --printh("tt ib="..ib,"rts_log.txt",false)
        if (ib > 0) then
            for w in all (t.warriors) do
              if ((w.a == 1) and (w.st == 2)) then
                w.a = 1
                w.st = 0
                w.b.wc -= 1
                w.b.wd -= 1
                transfer_warrior_to(w,tb)
                w.a = 0
                w.st = 0
                numt += 1
                ib -= 1
                --printh("transfered! : "..numt,"rts_log.txt",false)
                w.ticks = flr(rnd(15))
                if (numt >= fs) break
                if (ib == 0) break
              end
            end      
        end
        if (numt >= fs) break   
      end
    end
  end
  return numt
end

function update_fogc(blds)
		for x = 0, 15 do
		  for y = 0, 13 do
		    if (cfog[x][y] == 1) then
		      --check if near any buildings
		      for b in all(blds) do
		        if (dist(b.x,b.y,x,y) < 5) then
		          cfog[x][y] = 0
		        end
		      end
		    end
		  end
		end
end

function update_fog(blds)
		for x = 0, 16 do
		  for y = 0, 14 do
		    if (mget(x+32,y) != 144) then
		      --check if near any buildings
		      for b in all(blds) do
		        if (dist(b.x,b.y,x,y) < 5) then
		          mset(x+32,y,144)
		        end
		      end
		    end
		  end
		end
end

function fget(x, y)
  x=mid(x,0,15)
  y=mid(y,0,13)
  --printh("pf ("..x..","..y..") - "..mget(x+32,y),"rts_log.txt",false)
  return band(1,mget(x+32,y))
end

function pretty_fog()
		for x = 0, 16 do
		  for y = 0, 14 do
		    t=144+
		      8*(fget(x-1,y-1))+
		      4*(fget(x,y-1))+
		      2*(fget(x-1,y))+
		      1*(fget(x,y))
		    mset(x+32,y,t) --fog
		    --printh("pf="..t,"rts_log.txt",false)
		  end
		end
end


function update_fogm(mns)
		for m in all(mns) do
		  cx = flr((m.x+3)/8)
		  cy = flr((m.y+3)/8)
		  if(fget(cx,cy) > 0) then
		    mset(cx+32,cy,0)
		    if (cx > 0) then
		      mset(cx+31,cy,0)
		    end
		    if (cx < 15) then
		      mset(cx+33,cy,0)
		    end
		    if (cy > 0) then
		      mset(cx+32,cy-1,0)
		    end
		    if (cy < 13) then
		      mset(cx+32,cy+1,0)
		    end
		  end
		end
		pretty_fog()
end


function update_fogw(ws)
		for m in all(ws) do
		  if (ws.a == 2) then
		  cx = flr((m.x+3)/8)
		  cy = flr((m.y+3)/8)
		  if(fget(cx,cy) > 0) then
		    mset(cx+32,cy,0)
		    if (cx > 0) then
		      mset(cx+31,cy,0)
		    end
		    if (cx < 15) then
		      mset(cx+33,cy,0)
		    end
		    if (cy > 0) then
		      mset(cx+32,cy-1,0)
		    end
		    if (cy < 13) then
		      mset(cx+32,cy+1,0)
		    end
		  end
		  end
		end
		pretty_fog()
end

function init_game()
  -- copy map to display
  -- todo procedurally generate
  -- for now it copies the first 16x14 map
		init_nodes()
  gls = 0
  cfog = {}
  bmsg = ""
		last_attack = 0
		cab = 0
		cdiff = 4-diff
		--for x = 0, 15 do
		--  for y = 0, 13 do
		--    mset(x,y,mget(x+16,y))
		--    mset(x+32,y,10) --set fog
		--  end
		--end
		
		--trees, mountains, waters
		gen_map(94,18,22)
		
		buildings = {}
  buildings[1] = {}
  buildings[1][1] = {}
  buildings[2] = {}
  buildings[2][1] = {}
  
  minions = {}
  minions[1] = {}
  minions[2] = {}
  
  game_state = 0
  game_ticks = 0
  
  bmsg = ""
  
		for x = 0, 15 do
		  for y = 0, 13 do
		    if (mget(x,y) == 17) then
		      buildings[1][1].x = x
		      buildings[1][1].y = y
		      buildings[1][1].l = 1
		      -- state = 0 under construction
		      -- state = 1 built but spawning minions
		      -- state = 2 fully done
		      buildings[1][1].st = 1
		      buildings[1][1].ticks = 15
		      -- minions alive
		      buildings[1][1].m = 0
		      buildings[1][1].p = 1
		      buildings[1][1].builders = 0
		     
		      buildings[1][1].wood = 1 -- 1
							 buildings[1][1].dead = false
        init_warriors(buildings[1][1])
        buildings[1][1].enemies = {}
		    elseif (mget(x,y) == 33) then
		      buildings[2][1].x = x
		      buildings[2][1].y = y
		      buildings[2][1].l = 1
		      buildings[2][1].st = 1
		      buildings[2][1].ticks = 15
		      buildings[2][1].builders = 0
		      buildings[2][1].m = 0
		      buildings[2][1].p = 2
		      buildings[2][1].wood = 0    
		      if (diff == 3) then
		        buildings[2][1].wood = 2
		      elseif (diff == 2) then
		        buildings[2][1].wood = 1
		      end
		      buildings[2][1].enemies = {}
		      buildings[2][1].dead = false
		      init_warriors(buildings[2][1])
		    end
		  end
		end
		
		-- calculate what should be visible
		update_fog(buildings[1])
		pretty_fog()
		
		cs = {}
  cs.x = 0
  cs.bt = 0
  cs.y = 0
  cs.st = 0
  cs.b = nil
  cs.ab = {}
  cs.sb = nil
  cs.tb = nil

end

function _init()
  game_state = 20
end

function upgrade_building(b)
  b.st = 0
  b.ticks = build_ticks[1]
end

function add_building(cx,cy, p)
--printh("add_building p ="..p,"rts_log.txt",false)
b = {}
b.x = cx
b.y = cy
b.l = 0
b.dead = false
b.st = 0
b.ticks = build_ticks[1]
b.m = 0
b.p = p
b.wood = 0
b.builders = 0
b.wd = 0
init_warriors(b)
b.enemies = {}
add(buildings[p],b)
mset(cx,cy,16 + ((p-1)*16))
end

function release_builder(m)
  m.a = 1
  m.st = 0
  m.ticks = flr(rnd(7)) + 3
  m.tb.builders -= 1
end

function release_builders(b)
 -- printh("release builders called","rts_log.txt",false)
  for m in all (minions[b.p]) do
    if (m.tb == b) then
      m.a = 1
      m.st = 0
      m.ticks = 10
      b.builders -= 1
   --   printh("release done","rts_log.txt",false)
    end
  end  
end

function assign_builder(b)
  --printh("b.p = "..b.p,"rts_log.txt",false)
  --finds closest
  --non building minion
  --if success increases builder count
  tb = nil
  td = 10001
  mm = nil
  for m in all (minions[b.p]) do
    d = dist(m.x,m.y,b.x*8,b.y*8)
    if ((m.a != 2) and (d < td)) then
      --printh("found builder p ="..m.p,"rts_log.txt",false)
      tb = b
      td = d
      mm = m
    end
  end
  
  if (td < 10000) then
   -- printh("assign_builders d:"..td,"rts_log.txt",false)
    b.builders += 1
    mm.tb = b
    mm.a = 2
    mm.ticks = 5 + flr(rnd(20))
    mm.st = 0
  end
end

function spawn_minion(b)
 -- printh("spawn_minions called: "..b.p,"rts_log.txt",false)
  b.m += 1
  m = {}
  m.x = b.x * 8 + 4
  m.y = b.y * 8
  m.a = 1 --foraging
  m.st = 0
  m.ticks = 0
  m.searching = 0
  m.b = b
  m.p = b.p
  m.tb = b -- target base for build
  m.tt = 0
  m.wood = 0
  m.mx = 0
  m.my = 0
  m.mc = 0
  m.f = 0
  m.gx = -1
  m.gy = -1
  m.path = nil
  add (minions[b.p], m)
end

function defend_dmg_enemy(w)
  --defending tower
  
  for e in all(w.b.enemies) do
    if (e.a == 2) then
      e.hp -= battle_dmg
      if (e.hp < 0.5) then
        e.a = 0
        e.b.wc -= 1
        del(w.b.enemies,e)
      end
      break
    end
  end
end

function dmg_enemy(w)
  --attacking tower
  if (w.tb == nil) return
  for e in all(w.tb.warriors) do
    if ((e.a == 1) and (e.st == 2)) then
      e.hp -= battle_dmg
      if (e.hp < 0.5) then
       --printh("killed enemy:"..e.b.p,"rts_log.txt",false)
       e.a = 0
      	e.b.wc -= 1
      	e.b.wd -= 1
      end
      break
    end
  end
end

function kill_enemy(w)
  --attacking tower
  for e in all(w.tb.warriors) do
    if ((e.a == 1) and (e.st == 2)) then
      e.a = 0
      e.b.wc -= 1
      break
    end
  end
end

function update_warrior(w)
  if (w.a == 1) then
    if (w.st == 0) then
      w.ticks -= 1
      if (w.ticks < 1) then
        w.ticks = 0
        w.f = 0
        if (dist(w.x+1,w.y+6,w.b.x*8+4,w.b.y*8+4) < 9) then
          target_building_n(w,w.b,true)
        else
          target_building_n(w,w.b,false)
        end
        w.st = 1
        if (w.path == nil) then
          -- can't get home
          -- bad transfer?
          -- find closest base
          bb = find_closest_base(w)
          if (bb != nil) then
            w.st = 0
            w.ticks = flr(rnd(5))
            transfer_warrior_to(w,bb)
          else
            w.ticks = 90 + flr(rnd(120))
            w.st = 0
          end
        else
          get_move(w)
        end
      end
    elseif (w.st == 1) then
      if (move_step(w) == true) then
        w.st = 2
        set_wpos(w,w.b,w.pos)
        w.b.wd += 1
      end 
    elseif (w.st == 2) then
      w.ticks -= 1
      if (w.ticks < 1) then
        defend_dmg_enemy(w)
        w.ticks = 5 + flr(rnd(6)) 
      end
      if (#w.b.enemies < 1) then
        w.hp += 0.0075
        if (w.hp > war_hp_max) w.hp = war_hp_max
      end
    end
  elseif (w.a == 2) then
    --battle
    if (w.st == 0) then
      -- target building
      w.ticks -= 1
      if (w.ticks < 1) then
        w.ticks = 0
        w.f = 0
        if (building_ok(w.tb)) then
          target_building_n(w,w.tb,true)
          w.st = 2
          w.searching = 0
          if (w.path == nil) then
            --bad target no path
            sfx(11)
            imsg = "can't reach!"
            w.a = 1
            w.st = 0
            w.ticks = flr(rnd(15))
          else
            get_move(w)
          end
        else
          w.a = 1
          w.st = 0
          w.ticks = flr(rnd(15))
        end
      end
    elseif (w.st == 2) then
      -- moving to target
      w.searching += 1
      if (building_ok(w.tb)) then
        if (move_step(w) == true) then
          w.st = 4
          w.ticks = 0 + flr(rnd(2))
          add(w.tb.enemies,w)
        end
          --if (w.searching > 720) then
          --  w.a = 1
          --  w.st = 0
          --  w.ticks = 5
          --  w.searching = 0
          --end
        --end
      else
        w.a = 1
        w.st = 0
        w.ticks = flr(rnd(15))
      end
    elseif (w.st == 4) then
      -- battling at tower
      if (building_ok(w.tb) == false) then
        w.a = 1
        w.st = 0
        w.ticks = flr(rnd(15))
      end
      
      w.ticks -= 1
      if ((w.ticks % 6) == 1) then
        w.f = w.f + 1
        if (w.f > 2) w.f = 1
      end
      
      if ((w.ticks % 48) == 1) then
        sfx(8)
      end
      
      if (w.ticks < 1) then
          dmg_enemy(w)
          w.ticks = 3 + flr(rnd(5))
      end  
    end
  end
end

function init_warriors(b)
		b.warriors = {}
		b.wc = 0
		b.wd = 0
		b.wticks = 0
		for i = 1,8 do
		  w= {}
		  w.a = 0
		  w.pos = i
    w.p = b.p
    w.x = b.x * 8
    w.y = b.y * 8
    w.st = 0
    w.ticks = 0
    w.b = b
    w.tb = nil
    w.mx = 0
    w.my = 0
    w.tx = 0
    w.ty = 0
    w.mc = 0
    w.f = 0
    w.gx = -1
    w.gy = -1
    w.searching = 0
    w.path = nil
    add (b.warriors,w)
		end
end

function set_wpos(w,b,pos)

  cx = b.x*8 + 2.5
  cy = b.y*8 - 2.5
  
  an = 0
  
  for i = 1,pos do
    w.x = flr(cx + sin(an) * 4.5)
    w.y = flr(cy - cos(an) * 4.5)
    an += (1/8)    
  end
  
end

function spawn_warrior(b)
  b.wc += 1
  b.wd += 1
  pos = find_wpos(b)
  
  if (b.p == 1) sfx(5)
  
  w = b.warriors[pos]
  set_wpos(w,b,pos)
  w.a = 1 --at base
  w.st = 2
  w.searching = 0
  w.ticks = 15
  w.tb = nil
  w.hp = war_hp_max
  w.mx = 0
  w.my = 0
  w.mc = 0
  w.f = 0
  w.gx = -1
  w.gy = -1
  
end

function destroy_building(b)
  if (b == nil) return
  mset(b.x,b.y,1)
  if (b == cs.tb) then
    cs.tb = nil
  end
  
  if ((b.p == 1) and (b.l > 0)) sfx(3)
  p = b.p
  release_builders(b)
  for m in all(minions[p]) do
    if (m.b == b) then
      if (m.a == 2) then
        release_builder(m)
      end
      del(minions[p],m)
    end
  end
  for e in all (b.enemies) do
    e.a = 1
    e.st = 0
    e.tb = nil
    e.ticks = flr(rnd(10))
  end
  
  b.dead = true
  
  for w in all (b.warriors) do
    if (w.a > 0) then
      w.a = 1
      w.st = 0
      w.ticks = flr(rnd(10))
      transfer_warrior(w)
    end
  end
  
  del(buildings[p],b)
end

function update_building(b)

  if (b.st == 0) then
    if (b.ticks < 1) then
      -- finished construction
      b.l += 1
      b.st = 1
      b.ticks = 15
      if (b.p == 1) then
        update_fog(buildings[1])
      end
      release_builders(b)
      b.builders = 0
      mset(b.x,b.y,16+b.l+(16*(b.p-1)))
      if (b.p == 1) sfx(1)
    else 
      if (b.builders < 2) then
        assign_builder(b)
      end
    end
  elseif (b.st == 1) then
    -- spawning minions
    b.ticks -= 1
    if (b.ticks < 1) then
      -- must spawn minions
      if (b.m < min_max[b.l+1]) then
        spawn_minion(b)
        if (m.p == 1) sfx(4)
        b.ticks = 90
      else
        b.st = 2 -- fully done
      end
    end
  elseif (b.st == 2) then
    --spawn warriors
    if (#b.enemies > 0) then
      b.wticks = 0
      if (b.wd < 1) then
        --gonzo
        destroy_building(b)
      end
    else
      if (b.wc < war_max[b.l]) then
				    b.wticks += 1
				    if (b.wticks > war_ticks) then
				      if (b.wood > 0) then
				        b.wood -= 1
				        spawn_warrior(b)
				        b.wticks = 0 
				      end
				    end
				  else
				    b.wticks = 0
				  end
				end
  end
  
  foreach(b.warriors,update_warrior)
  if ((game_ticks % 15) == 0) then
    recalc_warriors(b)
  end
end

function handle_buildings(blds)
  foreach (blds,update_building)
end

function impassable(x,y)

  cx = flr((x+1)/8)
  cy = flr((y+6)/8)

  mc = mget(cx,cy)
  if ((mc > 6) and (mc < 15)) return true
  
  if ((cx < 0) or (cx > 15)) return true
  
  if ((cy < 0) or (cy > 13)) return true
    
  
  return false
end

function hit_wood(x,y,m)

  cx = flr((x+2)/8)
  cy = flr((y+4)/8)

  mc = mget(cx,cy)
  if ((mc > 1) and (mc < 7)) then
    if (m != nil) then
      m.gx = cx
      m.gy = cy
    end
    return true
  end
  return false
end

function get_move(p)
 pn = #p.path
 if (pn > 0) then
   cp = p.path[pn]
   del(p.path,cp)
   p.tx = cp.mx*8 + 1 + flr(rnd(4))
   p.ty = cp.my*8 - 1 - flr(rnd(4))
   return true
 end
 return false
end

function move_step(p)

  dx = abs(p.tx - p.x)
  dy = abs(p.ty - p.y)
  
  if ((dx < 0.1) and (dy < 0.1)) then
    return (not (get_move(p)))
  end
  
  p.mx = 0
  p.my = 0
  
  if (p.tx > p.x) then
    p.mx = 1
  elseif (p.tx < p.x) then
    p.mx = -1
  end
  
  if (dx < 0.1) p.mx = 0
  
  if (p.ty > p.y) then
    p.my = 1
  elseif (p.ty < p.y) then
    p.my = -1
  end
  
  if (dy < 0.1) p.my = 0
  
  if (flr(rnd(10)) > 0.75) then
    p.x += p.mx*minion_speed
    p.y += p.my*minion_speed
  end
  
  return false
  
end

function move(m)
    --printh("move called mx="..m.mx.." my="..m.my,"rts_log.txt",false) 
    if impassable(m.x + (m.mx*minion_speed), m.y) then
      m.mx = 0
    end
    
    if impassable(m.x, m.y + (minion_speed * m.my)) then
      m.my = 0
    end

				m.x += (m.mx * minion_speed)
				m.y += (m.my * minion_speed)
				--printh("move returning mx="..m.mx.." my="..m.my,"rts_log.txt",false)
				--printh("move c ("..m.x..","..m.y..") t ("..m.tx..","..m.y..")","rts_log.txt",false)
				if ((m.mx == 0) and (m.my == 0)) return false
				return true
end

function update_wood(m)
  cx = m.gx
  cy = m.gy
  if (cx < 0) then
    cx = flr((m.x+1)/8)
    cy = flr((m.y+6)/8)
  end

  mc = mget(cx,cy)
  if ((mc > 1) and (mc < 7)) then
    mc = mc + 1
    if (mc > 6) then
      mc = 1
    end
    mset(cx,cy,mc)
  end
end

function pick_random_dir(m)   
      rn = rnd(2)
      if (rn > 1.25) then
        m.mx = 1
      elseif (rn > 0.5) then
        m.mx = -1
      end
						rn = rnd(2)
      if (rn > 1.25) then
        m.my  = 1
      elseif (rn > 0.5) then
        m.my = -1
      end
      m.mc = flr(rnd(100)) + 30
end

function build_tower(b,m)
  b.ticks -= 1
end

function target_building_n(m,b,ub)
	m.tx = m.x
	m.ty = m.y
	m.gx = b.x
	m.gy = b.y
	if (ub) then
	  m.path = find_path(m.b.x,m.b.y,m.gx,m.gy)
	else
	  m.path = find_path(flr((m.x+1)/8),flr((m.y+6)/8),m.gx,m.gy)
 end
 m.mc = 0
end

function pick_target(m,t,r)

  md = 100
  mx = 0
  my = 0
  
  for x = 0, 15 do
		  for y = 0, 13 do
		    mc = mget(x,y)
		    if ((t == 1) and (mc > 1) and (mc < 7)) then
		      mn = dist(x,y,flr(m.x/8),flr(m.y/8))
		      if ((mn < r) and (mn < md)) then
		      	md = mn
		      	mx = x
		      	my = y
		      end
		    end
		  end
		end
		
		if (md < 100) then
		  m.tx = m.x
		  m.ty = m.y
		  m.gx = mx
		  m.gy = my
		  m.mc = 0
		  m.path = find_path(flr((m.x+1)/8),flr((m.y+6)/8),m.gx,m.gy)
		  if (m.path == nil) then
		    m.a = 1
		    m.st = 0
		    m.ticks = flr(rnd(15))
		  else
		    get_move(m)
		  end

		else
		  --todo - no target found
		  m.tx = -100
		  m.ty = -100
		  m.gx = -2
		  m.gy = -2
		  m.mc = 10
		end
end


function move_minion(m)

--printh("move_minions m.a = "..m.a.." st ="..m.st.." p="..m.p,"rts_log.txt",false)
  if (m.a == 1) then
    -- foraging
    if (m.st == 0) then
      -- pick target forest
      if (m.b.wood < wood_max[m.b.l]) then
        pick_target(m,1,8)
        m.st = 2
        m.f = 0
        if (m.tx < 0) then
          m.a = 3
          m.ticks = 90 + flr(rnd(90))
        end
      else
        m.a = 3
        m.ticks = 30 + flr(rnd(90))      
      end
    elseif (m.st == 2) then
      -- moving to target
      if (move_step(m) == true) then
        m.st = 4
        m.ticks = chop_wood_time
      elseif (hit_wood(m.x,m.y,m)) then
        m.st = 4
        m.ticks = chop_wood_time
      else
        if ((m.mc > 1) and (m.mc < 5)) then
          if (rnd(2) > 1) then
            pick_target(m,1,6)
            if (m.tx < -50) then
             m.ticks = 15
        					m.st = 6
        					m.tx = m.b.x * 8 + 2
        					m.ty = m.b.y * 8 - 2
        					m.mc = 0 
            end
          end
        end
      end
    elseif (m.st == 4) then
      -- working at forest
      m.ticks -= 1
      if ((m.ticks % 6) == 1) then
        m.f = m.f + 1
        if (m.f == 3) m.f = 1
      end
      
      if ((m.ticks % 15) == 0) then
        if (m.p == 1) sfx(0)
      end
      
      if (m.ticks < 1) then
        m.wood += 1
        if (rnd(1) < min_effic[m.b.l]) m.wood += 1
        m.ticks = 15
        m.st = 6
        m.tx = m.b.x * 8 + 2
        m.ty = m.b.y * 8 - 2
        update_wood(m)
      end
    elseif (m.st == 6) then
      -- moving to tower
      m.f = 0
      if (move_step(m) == true) then
        m.st = 8
        m.ticks = deliver_wood_time
      end
    elseif (m.st == 8) then
      -- reached tower
      m.f = 0
      m.ticks -= 1
      if (m.ticks < 1) then
        m.b.wood += m.wood
        m.wood = 0
        m.ticks = 30
        m.st = 0
      end
    end
  elseif (m.a == 2) then
    -- building
    if (m.st == 0) then
      -- target building
      m.ticks -= 1
      if (m.ticks < 1) then
        m.ticks = 0
        m.f = 0
        target_building_n(m,m.tb,false)
        m.st = 2
        m.searching = 0
        if (m.path == nil) then
          release_builder(m)
        else
          get_move(m)
        end
      end
    elseif (m.st == 2) then
      -- moving to target
      m.searching += 1
      if (move_step(m) == true) then
        m.st = 4
        m.ticks = 2000
      else
        if (m.searching > 450) then
          m.tb.builders -= 1
          m.a = 1
          m.st = 0
          m.ticks = 5
          m.searching = 0
        end
      end
    elseif (m.st == 4) then
      -- building tower
      build_tower(m.tb,m)
      m.ticks += 1
      if ((m.ticks % 6) == 1) then
        m.f = m.f + 1
        if (m.f > 2) m.f = 1
      end
      
      if ((m.ticks % 18) == 0) then
        if (m.p == 1) sfx(0)
      end
    end    
  else
   m.ticks -= 1
   if (m.ticks < 1) then
     m.a = 1
     m.st = 0
   end
  end 
end

function recalc_warriors(b)
  wd = 0
  wc = 0
  for w in all (b.warriors) do
    if ((w.a == 1) and (w.st == 2)) then
      wd += 1
      wc += 1
    elseif (w.a > 0) then
      wc += 1
    end
  end
  
  b.wc = wc
  b.wd = wd
  
end

function set_info_message(b)
  if (b.l < 1) then
    imsg = "in construction"
  else
    imsg = "l:"..b.l.." wd:"..b.wood.." wa:"..b.wc
    recalc_warriors(b)
  end
end

function get_building(cx,cy)
  for b in all(buildings[1]) do
    if ((cx == b.x) and (cy == b.y)) return b
  end
  
  for b in all(buildings[2]) do
    if ((cx == b.x) and (cy == b.y)) return b
  end
  
end

function get_total_wood(p)
  w = 0
  for b in all(buildings[p]) do
    if (b.wood != nil) w = w + b.wood
  end
  return w
end
function get_total_warriors(p)
  wa = 0
  for b in all(buildings[p]) do
    if (b.wc != nil) wa += b.wc
  end
  return wa
end

function set_status(p)
  wd = get_total_wood(p)
  wa = get_total_warriors(p)
  cc = "p"
  if (p == 2) cc = "c"
  smsg[p] = ""..cc.." wd:"..wd.." wa:"..wa  
end

function get_wood(l,p,x,y)
  wr = wood_req[l]
  wm = wr
  if (get_total_wood(p) >= wr) then
    cb = nil
    d = {}
    li = 0
    i = 1
    for b in all(buildings[p]) do
      dd = dist(b.x,b.y,x,y)
      add(d,dd)
      if ((li == 0) or (d[li] > dd)) then
        li = i
      end
      i = i + 1
    end
    
    oi = -1
    
    while (wr > 0) do
      --printh("get_wood wr="..wr.." li="..li.." oi="..oi,"rts_log.txt",false)
      if (buildings[p][li].wood > 0) then
        buildings[p][li].wood -= 1
        wr -= 1
        --printh("get_wood dec wr="..wr.." li="..li.." bw="..buildings[p][li].wood,"rts_log.txt",false)
      else
        -- pick next building
        oi = li
        li = 0
        i = 1
        for ds in all(d) do
          if (i != oi) then
            if ((ds >= d[oi]) and (buildings[p][i].wood > 0)) then
              if ((li == 0) or (ds <= d[li])) li = i
            end 
          end
          i += 1  
        end
      end
    end
    return wm 
  end
  return 0
end

function warrior_attack(w,tb)
   w.a = 2
   w.st = 0
   w.b.wd -= 1
   w.tb = tb
   w.ticks = flr(rnd(15))
end

function get_half_warriors(sb)
  ib = 0
  for w in all(sb.warriors) do
    if ((w.a == 1) and (w.st == 2)) ib += 1
  end
  return flr(ib/2)
end

function attack(sb,tb)
  ib = get_half_warriors(sb)
  if (ib > 0) then
    for w in all(sb.warriors) do
      if ((w.a == 1) and (w.st == 2)) then
        ib = ib - 1
        warrior_attack(w,tb)
        if (ib < 1) break
      end
    end    
  end
end

function computer_upgrade(b)
  if ((b.l < 3) and (b.st > 1)) then
    wu = get_wood(b.l+1,b.p,b.x,b.y)
    if (wu > 0) then
      upgrade_building(b)
    end
  end
end

function not_too_close(x,y,b,r)
  for c in all (buildings[b.p]) do
    if (dist(c.x,c.y,x,y) < r) return false
  end
  return true
end

function computer_build(b)
  --build nearish this one
  bd = 3
  if (#buildings[b.p] > 3) bd += 1
  if (#buildings[b.p] > 5) bd += 1
  
  for i = 1,100 do
    x = flr(rnd(16))
    y = flr(rnd(14))
    if (mget(x,y) == 1) then
      if (cfog[x][y] == 0) then
        if (not_too_close(x,y,b,bd)) then
          wu = get_wood(1,b.p,x,y)
          if (wu > 0) then
            add_building(x,y,b.p)
          end
          break
        end
      end
    end
  end
end

function find_closest_base(w)
  
  p1 = 1
  p2 = 2
  b = nil
  td = 10001
  
  if (w.p == 1) then
    p1 = 2
    p2 = 1
  end
  
  for b1 in all(buildings[p1]) do
      if (b1.l > 0) then
        for b2 in all(buildings[p2]) do
          if (b2.l > 0) then
            d = dist(b1.x,b1.y,b2.x,b2.y)
            if (d < td) then
              td = d 
              b = b1
            end
          end
        end   
      end
  end
  
  return b
end

function get_unf_count(blds)
  u = 0
  for b in all(blds) do
    if (b != nil) then
      if ((b.l != nil) and (b.st != nil)) then
        if ((b.l == 0) or (b.st < 2)) then
          u +=1
        end
      end
    end
  end
  return u
end

function computer_move(p)

  --todo
  -- warrior count
  -- need an accurate defending count
  -- warriors seem to get stuck
  -- mainly for computer though
  if ((game_ticks % (100 * cdiff)) == 0) then
    tw = get_total_wood(p)
    bc = #buildings[p]
    bu = get_unf_count(buildings[p])
    l = flr(rnd(bc)+1)
    b = buildings[p][l]
    if (bc < 3) then
      if (tw > 2) then
        computer_build(b)
        update_fogc(buildings[2])
      end
    else
    		if ((tw > 12) and (bu < 2)) then
        if (rnd(10) < 2+cdiff) then
          computer_build(b)
          update_fogc(buildings[2])
        else
          computer_upgrade(b)
        end
      end
    end
  end
 
  if (game_ticks < 1400) return
  
  if (#buildings[2] > (#buildings[1]+3)) cab = 8
  if ((game_ticks % (100*cdiff)) == 0) then
    --attack
    ak = 0
    for b1 in all(buildings[p-1]) do
      if ((b1.l > 0) and (cfog[b1.x][b1.y] == 0)) then
        for b2 in all(buildings[p]) do
          if ((b2.l > 0) and (b2.wd > 1) and (b2.st > 0)) then
            if (dist(b1.x,b1.y,b2.x,b2.y) < 7+diff+cab) then
              if (b2.wd >= b1.wd) then
                attack(b2,b1)
                if (rnd(1) > 0.3) attack(b2,b1)
                ak += 1
                last_attack = game_ticks
                if (ak > (diff*3)) then
                  break
                end
              end
            end
          end
        end   
      end
      if (ak > (diff*3)) then
        break
      end
    end
    
    if ((game_ticks - last_attack) > 400) then
      cab += 1
      if (cab > 7) cab = 7 
    else
      cab = 0
    end
  end   
end

function check_lost(p)
  
  if (#buildings[p] == 0) then
    return true
  elseif (get_unf_count(buildings[p]) == #buildings[p]) then
    if (#minions[p] == 0) return true
  end
  
  return false
end

function _update()
  
  game_ticks += 1
  if (game_state == 10) then
    if (game_ticks > 90) then
      init_game()
      game_state = 0
      return
    end
    return
  end
  
  if (game_state == 20) then
    if (btnp(0)) then
      diff = diff -1
      if (diff < 1) diff = 3
    elseif (btnp(1)) then
      diff = diff + 1
      if (diff > 3) diff = 1   
    end
    if (btnp(4)) then
      init_game()
      game_state = 1
    end
    return
  end
  
  handle_buildings(buildings[1])
  handle_buildings(buildings[2])
		foreach(minions[1],move_minion)
		foreach(minions[2],move_minion)		
  if ((game_ticks % 30) == 0) then
    update_fogm(minions[1])
  end
  
  if ((game_ticks % 28) == 0) then
    for b in all (buildings[1]) do
      update_fogw(b.warriors)
    end
  end
  
  if ((game_ticks % 20) == 0) then
    for x = 0, 15 do
		    for y = 0, 13 do
		    if (mget(x,y) == 7) then
		      mset(x,y,8)
		    elseif (mget(x,y) == 8) then
		      mset(x,y,11)
		    elseif (mget(x,y) == 11) then
		      mset(x,y,7)
		    end
		  end
		  end
  end
  
  if ((game_ticks % 15) == 0) then
    set_status(1) 
  end
  
  if ((game_ticks % 16) == 0) then
    set_status(2) 
  end
  
  computer_move(2)
  
  if (((game_ticks % 45) == 0) and (game_ticks > 300)) then
  
  if (check_lost(1)) then
    bmsg = "you lost!"
    game_state = 10
    game_ticks = 0
    return
  elseif (check_lost(2)) then
    bmsg = "you won!"
    game_state = 10
    game_ticks = 0
    return 
  end
  
  end
  
  mv = false
  if (btnp(0)) then
    cs.x = cs.x - 8
    if (cs.x < 0) then
      cs.x = 0
    else sfx(9) end
    mv = true
  elseif (btnp(1)) then
    cs.x = cs.x + 8
    if (cs.x > 120) then
      cs.x = 120
    else sfx(9) end
    mv = true  
  end
  if (btnp(2)) then
    cs.y = cs.y - 8
    if (cs.y < 0) then
      cs.y = 0
    else sfx(9) end
    mv =true
  elseif (btnp(3)) then
    cs.y = cs.y + 8
    if (cs.y > 104) then 
      cs.y = 104
    else sfx(9) end
    mv = true  
  end
  if ((mv) or ((game_ticks%20) == 0)) then
    cx = cs.x/8
    cy = cs.y/8
    mc = mget(cx,cy)
    if (mget(cx+32,cy) != 159) then
      cs.mc = mc
      if (mc > 15) then
        b = get_building(cx,cy)
        if (b != nil) then
          set_info_message(b)
          cs.b = b
        else
          imsg = "weird - missing building"
        end
      else
        imsg = ""
        cs.b = nil
      end
    else
      cs.mc = 0
      imsg=""
      cs.b = nil
    end
  end
  
  if (cs.bt > 0) then
    cs.bt -= 1  
    --printh("btnp4-cs.bt="..cs.bt,"rts_log.txt",false) 
  end
  
  if (btnp(4)) then
    if (cs.b != nil) then
      if (cs.st == 0) then
        if (cs.b.p == 1) then
          if ((cs.b.wd > 0) and (cs.b.st > 0)) then
            cs.st = 2
            cs.sb = cs.b
            cs.tb = nil
            bmsg = "sel target"
            sfx(10)
            add(cs.ab,cs.b)
          end 
        end
      elseif (cs.st == 2) then
        if ((cs.b.p == 2) and (cs.b.l > 0)) then
         -- attack
         cs.tb = cs.b
         cn = 0
         for atb in all (cs.ab) do
           if (atb.wd > 0) then
             attack(atb,cs.tb)
             cn += 1
           end
         end
         if (cn > 0) sfx(12)
         if (cn == 0) then
           sfx(11)
           cs.st = 0
           cs.sb = nil
           cs.tb = nil
           imsg = "no warriors"
           cs.ab = {}
         end
        else  
          if ((cs.b == cs.sb) and (cs.bt > 0)) then
            --transfer
            printh("btnp4 transfer"..cs.bt,"rts_log.txt",false)
            cnt = transfer(cs.ab, cs.b)
            if (cnt > 0) then
              bmsg = "transfer"
              sfx(10)
            else
              bmsg = "not able to"
              sfx(11)
            end 
          elseif (cs.b.st > 0) then
            cs.st = 2
            cs.sb = cs.b
            bmsg = "sel target"
            sfx(10)
            if (cs.tb != nil) cs.ab = {}
            cs.tb = nil
            add(cs.ab,cs.b)
            cs.bt = 30
          else
            sfx(11)
            imsg = "in construction"
          end  
        end
      end
    elseif (cs.mc == 1) then
      --assume build for now
      if (cs.st == 0) then
        cs.st = 0
        cs.sb = nil
        cs.tb = nil
        wu = get_wood(1,1,cs.x/8,cs.y/8)
        if (wu > 0) then
          add_building(cs.x/8,cs.y/8,1)
          imsg = "-"..wu.." wd:bld" 
          cs.mc = 17
          sfx(10)
        else
          imsg = "short wood"
          sfx(11)
        end
      else
          imsg = "invalid target"
          sfx(11)
      end
    end
  elseif (btnp(5)) then
    cs.bt = 0
    if (cs.st == 2) then
      --cancel
      cs.st = 0
      cs.sb = nil
      cs.tb = nil
      bmsg = ""
      cs.ab = {}
    elseif (cs.b != nil) then
      --upgrade
      cs.st = 0
      cs.sb = nil
      cs.tb = nil
      cs.ab = {}
      if (cs.b.st > 1) then
        if (cs.b.l < 3) then
          wu = get_wood(cs.b.l+1,1,cs.x/8,cs.y/8)
          if (wu > 0) then
            upgrade_building(cs.b)
            imsg = "-"..wu.." wd:upg" 
            sfx(10)
          else
            imsg = "short wood"
            sfx(11)
          end
        else
          imsg = "maxxed out"
          sfx(11)
        end
      else
        if (cs.b.l == 0) then
          imsg = "cancelled"
          sfx(13)
          destroy_building(cs.b)
        else
          imsg = "in construction"
          sfx(11)
        end
      end  
    end
  end
end

function draw_fog()
  map(32,0,-4,4,17,15)
end

function draw_warriors(bld,p)
  for b in all(bld) do
    for w in all(b.warriors) do
      if (w.a > 0) then
        spr(23+(16*(p-1))+w.f,w.x,w.y+8)
      end
    end
  end
end

function draw_sel_blds()

  if ((game_ticks % 20) > 3) then
  
  for b in all(cs.ab) do
    spr(131,b.x*8,b.y*8+8)
  end
  if (cs.tb != nil) then
    if (cs.tb.p == 2) then
      spr(132,cs.tb.x*8,cs.tb.y*8+8)
    end
  end
  
  end
end

function draw_minions(mns,p)
  b = 28 + (16 * (p-1))
  for m in all(mns) do
    spr(b+m.f,m.x,m.y+8)
  end
end

function _draw()
  cls()
  
  if (game_state == 20) then
    map (16,0,0,8,16,14)
    color(7)
    print ("micro rts",44,1)
    rectfill(16,24,(128-16),88,0)
    spr(60+4*diff,48,41,4,4)
    color(7)
    print("choose your difficulty",20,30)
    print(difft[diff],24,78)
    rectfill(16,96,(128-16),112,0)
    color(7)
    
    print (sub(omsg,moff,moff+31),0,121)
    if ((game_ticks % 5) == 0) then
       moff += 1
       if ((moff + 32) > #omsg) then
         m0ff = 0
       end
    end  
    
    print ("but. a -   select/build",19,98)
    print ("but. b - cancel/upgrade",19,106)
    
  else
    map (0,0,0,8,16,14)
    draw_warriors(buildings[1],1)
    draw_warriors(buildings[2],2)
    
    draw_minions(minions[1],1)
    draw_minions(minions[2],2)

    draw_sel_blds()
  
    draw_fog()
    
    rectfill(0,0,128,7,0)
    rectfill(0,120,128,128,0)
    color(7)
  
    if ((game_ticks % 20) > 3) spr(128+cs.st,cs.x,cs.y+8)
  
    --draw any text or menus?
    print(imsg,0,1)
    print(bmsg,0,121)
    print(smsg[1],64,121)
    print(smsg[2],64,1)
  end
end
__gfx__
000000003333333333b333b3333333b333333333333333333333333333ccccc333ccccc3333563335555555533ccccc300000000000000000000000000000000
00000000333333333b4b3bbb334b3bbb33333bb33333333333333333cc7ccccccccc7ccc3355663356555655cccccc7c00000000000000000000000000000000
0070070033333333bbbbb34b3bbbb34b3bbb334b33bb333333333333c7c7ccccccc7c7cc3505563355555555ccccc7c700000000000000000000000000000000
00077000333333333b4b3b433b4b3b433b4b3b433b4b333333333333cccccccccccccccc3555066355556555cccccccc00000000000000000000000000000000
0007700033333333bb43bbb33b43bbb33b43bbb33b43b3333b433333cccccc7c7ccccccc5555555655555555cc7ccccc00000000000000000000000000000000
0070070033333333334334b3334334b3334334b33343343333433433ccccc7c7c7ccccc75505555655555565c7c7cccc00000000000000000000000000000000
0000000033333333333bb4bb3333b4bb3333b4bb3333b4b33333b4b3cc7cccc3cccc7cc35555555655655555cccccc7300000000000000000000000000000000
0000000033333333333334333333343333333433333334333333343337c7ccc33cc7c7c355555055555555553cccc7c300000000000000000000000000000000
33333333666666656666666566666665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333367777775677777756cccccc5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
336665336777777567cccc756cccccc5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
336cc533677cc77567cccc756cccccc5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
336cc533677cc77567cccc756cccccc5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
336555336777777567cccc756cccccc500000000000000000000000007000000070600000700000000000000000000000c0000000c5600000c00000000000000
3333333367777775677777756cccccc50000000000000000000000000c0000000c6000000c660000000000000000000005000000055000000555600000000000
333333336555555565555555655555550000000000000000000000000c0000000c0000000c000000000000000000000005000000050000000500000000000000
33333333666666656666666566666665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333677777756777777568888885000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33666533677777756788887568888885000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33688533677887756788887568888885000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33688533677887756788887568888885000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33655533677777756788887568888885000000000000000000000000070000000706000007000000000000000000000008000000085600000800000000000000
33333333677777756777777568888885000000000000000000000000080000000860000008660000000000000000000005000000055000000555600000000000
33333333655555556555555565555555000000000000000000000000080000000800000008000000000000000000000005000000050000000500000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000cc000000cc060000cc00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000cccc0000cccc0000cccc6600000000000000000000000000000000000000000000000000
c0000000cc000000ccc00000cccc00000000000000000000000000000cc000000cc000000cc00000000000000000000000000000000000000000000000000000
00000000000077777777700000000000000000000000444444444000000000000000000000004444444440000000000000000000000000000000000000000000
00000000777777777777777000000000000000004444444444444440000000000000000044444444444444400000000000000000000000000000000000000000
00000077777667777767777777000000000000444444444444444444440000000000004444444444444444444400000000000000000000000000000000000000
00000077777567657757766777700000000000444444444544444644444000000000004444444445444446444440000000000000000000000000000000000000
00000777776577757557557777700000000004444444444544445444444000000000044444444445444454444440000000000000000000000000000000000000
00000765777757757677577667770000000004444400004004444004644400000000044444000040444440046444000000000000000000000000000000000000
000077757ffffff44fff4f76577700000000444400fffff400ff4f40044400000000444444444444044444400444000000000000000000000000000000000000
0000775fffffffff44ffffff777700000000445fffffffff4000ffff004400000000444440000044044040000044000000000000000000000000000000000000
000777fffffff77fff44f4ff77570000000444fffffff77fff44f4ff400400000004444400fff000004000ff0004000000000000000000000000000000000000
00077f7fffffff777fffffff7f07000000040fffffffff777fffffffff04000000040f00ffffff777f4ffffff004000000000000000000000000000000000000
00000f74ffff0fffff00ffff7f00000000000ff4ffff0fffff00ffffff00000000000f04ffff0ff00f00ffffff00000000000000000000000000000000000000
00000f744f505ffff5555ff47f00000000000ff44f505ffff5555fffff00000000004ff44f0000fff0000fffff00000000000000000000000000000000000000
0000047ff551c557551c55ff74000000000004fff551c557551c55fff4000000000044fff0088057008800fff400000000000000000000000000000000000000
00000f7fff71178487117ff47f00000000000fffff71178487117ff4ff000000000044ffff78878487887ff4ff00000000000000000000000000000000000000
0000047fffffffffffffffff74000000000004ffffffffffffffffff440000000000044fffffffffffffffff4400000000000000000000000000000000000000
00000f7fff77fff7ff77ffff7f00000000000fffff77fff7ff77ffff4f0000000000044fff77fff7ff77ffff4f00000000000000000000000000000000000000
00000f7ffffff9f7f9ffffff7f00000000000ffffffff9f7f9ffffffff0000000000044ffffff9f7f9ffffffff00000000000000000000000000000000000000
0000007fffffff444fffffff70000000000000ffffffff444ffffffff000000000000044ffffff444ff4fffff000000000000000000000000000000000000000
0000007f4ffffff9ffffff4f70000000000000fffffffff9ffffff4ff00000000000004f4ffffff9ff474ff4f000000000000000000000000000000000000000
0000007f44ff6666666ff44f70000000000000fff4fffffffffffff4f00000000000004f44ffffff47774f4ff000000000000000000000000000000000000000
0000007ff4ff7777777ff4ff70000000000000ff4ff444444444ff4ff0000000000000444ff444444444fffff000000000000000000000000000000000000000
0000007fffff77aaa77fffff70000000000000fff4ff9999999fffff40000000000000444fff99999999ffff4000000000000000000000000000000000000000
0000007fffff66aa966ffff670000000000000fffffffffffffffff440000000000000444ffffff999fffff44000000000000000000000000000000000000000
0000000776ffffaa9fffff66700000000000000444f7ffffffff7f44400000000000000444f7ffffffff7f444000000000000000000000000000000000000000
000000007667fffffffff77700000000000000004447fffffffff74400000000000000004447fffffffff7440000000000000000000000000000000000000000
0000000044466fffff7777f000000000000000004444444444444440000000000000000044444444444444400000000000000000000000000000000000000000
000000004400777777fffff000000000000000004f0f00000000f0f000000000000000004f0f00000000f0f00000000000000000000000000000000000000000
000000004770006776ff77500000000000000000444ffffffffffff00000000000000000444ffffffffffff00000000000000000000000000000000000000000
00000000577777677777777000000000000000004444fffffff7fff000000000000000004444fffffff7fff00000000000000000000000000000000000000000
0000000077766666766667700000000000000000444f6ffffffffff00000000000000000444f6ffffffffff00000000000000000000000000000000000000000
000000007777777777777770000000000000000044fffffffffffff0000000000000000044fffffffffffff00000000000000000000000000000000000000000
00000000577777770066775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa0000aabb0000bb88000088b0b00b0b808008080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a000000ab000000b8000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000b000000b800000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000b000000b800000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a000000ab000000b8000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa0000aabb0000bb88000088b0b00b0b808008080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000055550000555500005555000055555550500055505000555050005550500055555555555555555555555555555555
00000000000000000000000000000000000505550005055500050555000505555555000055550000555500005555000055555555555555555555555555555555
00000000000000000000000000000000000055550000555500005555000055555550000055505000555050005555500055555555555555555555555555555555
00000000000000050500000005050505000005050005055505050505050555550500000005050505555500005555550505050505055555555555550555555555
00000000000000505050000050505050000000500000555550505050505555555000000050505050555050005555555050505050505555555555505055555555
00000000000005555555000055555555000000000005055555550000555555550000000000050555555500005555555500000000000555555555000055555555
00000000000055555550500055555555000000000000555555505000555555550000000000005555555050005555555500000000000055555550500055555555
00000000000505555555000055555555000000000005055555550000555555550000000000050555555500005555555500000000000505555555000055555555
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
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000002010702010101010101010202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002010102012101010101010202020902000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000001010701010101010101010101020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000001010107010102020101010101010102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000001010101070707070101010901010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002010901020207070701010707010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000001020101010107070201010102070101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000009010101010101010101090202070101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000001011109020101010101010107010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000009010101090109020101010101010201000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002020201010101010101010107020101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002020201010101090101020102070101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002070201010101010102010107020101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000002020202010101010901010701010102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0001000032630316202462019620136200d6200862004620016200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000020300403006030080400a0400d04013050170501b05021050280502f0502f05002000310000c00001000380003f00000000000000000000000000000000000000000000000000000000000000000000
000c000026050260502505025050250501905019050190500f0500f0500f0500f0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000011650126501465018650126500f6501065012650126501965016650196501865017650176501965016650196501565016650166501865013650176501664014640106400d6200b620086100361001600
000300002872028710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001872007400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000003045024450244503040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000306502b650236401b640156400f6400a640026300263000000000000000000000000000000000000176000e6000460001600216501d6501864014640106400d6400b6400a64008640056400164000000
0001000034640326402f6402a640296402f6402a64026630256302163021630206301e6301e6301f63022630266302f6201e6301b63015640236401f6401a630186301f6301e6301c6301b6301d6201f62024610
0001000039310013000a3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003725037250372303722000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002024020240202402024020240202502025020250202502025020250202502125022550215502055004600196000000000000000000000000000000000000000000000000000000000000000000000000
000200002135022350223502235023350243502435025320253103630039300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000260502405022050200501e0501d0501b0501705014050110500e0500b0500a05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
