pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--by @jlalleve


m_debug=false

m_x=32

m_roomw=112 --14*8
m_mapx=8
m_spd=1
m_step=0
m_step_anim=12
m_player_backwards=false
m_talk_target=nil
m_pickup_target=nil
m_curse_target=nil
m_statue_target=nil
m_dlg=nil
m_room_triggers={}
m_line=1
m_inventory_blocked=false
m_move_blocked=false

m_splash_screen=true
m_end_screen=-1
m_car_available=false

m_framerate=60

m_eye_frame=0
m_eye_timer=0
m_eye_t_closed=.5
m_eye_t_opening=1
m_eye_t_open=3.5
m_eye_solved=false

m_time=0
m_frame=0

m_music_paused=false

m_road_room = 2

black=0
navy=1
purple=2
green=3
brown=4
grey=5
gray=5
lightgrey=6
lightgray=6
white=7
red=8
orange=9
yellow=10
lightgreen=11
lightblue=12
teal=13
pink=14
beige=15

-- notable rooms 
--2f
room_police=1
room_road=2
room_end_door=5
room_head=6
--1f
room_start=9
room_hall=10
room_bats_pattern=11
room_eye_puzzle=12
room_dream=13
room_tongue_door=14
--b1
room_b1_doors=19
room_bats_puzzle=20
room_crane_puzzle=21
room_start_investigation=22
room_curse_puzzle=23
room_key_3=24
--b2
room_b2_doors=27
room_dance_puzzle=28
room_anti_curse=29
room_curse=18

room_end_stay=30
room_end=31
room_end_leave=32

room_none=33

--

es_jack=1
es_jack_and_ghost=2
es_end=3

function upd_time()
 m_frame+=1
 if m_frame == m_framerate then
  m_frame=0
  m_time+=1
 end
end

function _update60()
 upd_time()
 btnupd()
 if not m_splash_screen then
	 move()
	 update_targets()
	 update_interaction()
	 upd_puzzles()
	else
	 if btnjp[5] then
	  m_splash_screen=false
   start_music()
	 end
	end
end

function _draw()
 cls(0)
 if not m_splash_screen then
  if not ended() then
   draw_room()
   draw_npcs()
   draw_room_texts()
   draw_puzzles()
   draw_player()
   draw_cart()
  else
   draw_es()  
   draw_cart()
  end
 else
  draw_room()
  draw_room_texts()
  draw_splash()
  draw_cart()
 end
end

function ended()
 return m_end_screen != -1
end

---- ***** ----
-- columns start at zero not one!
function col_x(col, centered)
 local x=m_mapx+col*8
 if centered then
  x+=4
 end
 return x
end

function collider_check(oldx, newx)
 if m_room.colliders != nil then
  xstart=2+m_room.colliders[1].xstart
  xend=6+m_room.colliders[1].xend
  if newx > xstart 
   and oldx <= xstart then
   newx=xstart
  elseif newx < xend 
   and oldx >= xend then
   newx=xend
  end
 end
 return newx
end

function coltriggers_check(oldx, newx)
 if m_room.coltriggers != nil then
  for coltrigger in all(m_room.coltriggers) do
   xstart=2+coltrigger.xstart
   xend=6+coltrigger.xend
   if coltrigger.side==1
    and newx > xstart 
    and oldx <= xstart then
    coltrigger.trigger()
   elseif coltrigger.side==0
    and newx < xend 
    and oldx >= xend then
    coltrigger.trigger()
   end
  end
 end
end

function any_move()
 return btn(0) or btn(1) 
  or btn(2) or btn(3) 
end

function move()
 if m_dlg != nil 
  or m_crane_ctrl
  or m_move_blocked then
  return
 end
 oldx=m_x
	if (btn(0)) then 
	 m_x=max(m_x-m_spd,0) 
	 m_player_backwards=true
	end
	if (btn(1)) then 
	 m_x=m_x+m_spd 
	 m_player_backwards=false
	end
	if btn(0) or btn(1) then 
		m_step=m_step+1
		m_step=m_step%m_step_anim
	else
		m_step=0
	end
	
	if m_x != oldx then
	 m_x = collider_check(oldx, m_x)
	 coltriggers_check(oldx, m_x)
	end
	ld=room_get_door(m_room,0)
	rd=room_get_door(m_room,1)
	
	max_x=m_mapx+m_roomw
	min_x=m_mapx
	if ld == nil then min_x+=10 end
	if rd == nil then max_x-=10 end
	if (m_x+4 > max_x) then 
	 if rd != nil then
	  dest=door_get_destination(rd)
	  enter_destination(dest)
	 else
	  m_x=max_x-4
	 end
	elseif (m_x+4 < min_x) then
	 if ld != nil then
	  dest=door_get_destination(ld)
	  enter_destination(dest)
	 else
	  m_x=min_x-4
	 end
	elseif m_room.md != nil then
	 for md in all(m_room.md) do
	  doorx = door_get_x(md)
	  if btnjp[5] and 
	   player_near(doorx,4) and
	   md.locked == nil then
	   dest=door_get_destination(md)
	   enter_destination(dest)
	  end
	 end
	end
end

function enter_destination(dest)
 same_room=m_room!=nil
  and m_room.id==dest.room
 
 m_room=rooms[dest.room]
 
 if dest.side == 0 then
  m_x=m_mapx
 elseif dest.side == 1 then
  m_x=m_mapx+m_roomw - 8 
 --elseif dest.side == 2
 -- nothing to do! we keep x
 end
 
 if not same_room then
  if m_room.init_trigger != nil then
   m_room.init_trigger()
   m_room.init_trigger=nil
  end
  run_room_exit_triggers()
 end
 reinit_puzzles()
end

function run_room_exit_triggers()
 for t in all(m_room_triggers) do
  t()
 end
 m_room_triggers={}
end

function update_targets()
 --find someone to talk to
 m_talk_target=nil
 for t in all(npcs) do
  if m_room.id==t.room then
   if t.dlg and abs(m_x-4-t.x) < 16 then
    m_talk_target=t
   end 
  end
 end
 m_pickup_target=nil
 for p in all(pickups) do
  if m_room.id==p.room then
   local x=col_x(p.column)
   if abs(m_x-4-x) < 16 then
    m_pickup_target=p
   end
  end
 end
end

function obj_near(ax, aw, bx, bw, d)
 return abs((bx+bw/2)-(ax+aw/2))<d
end

function player_near(x, w)
	--return abs(m_x-4-x) < w
	return obj_near(m_x,8,x,8,8)
end

function update_interaction()
 action_pressed=btnjp[5]
 use_pressed=btnjp[4]
 if action_pressed then
  if m_dlg then
	  m_line=m_line+1
  	if not m_dlg[m_line] then
	   if ended() then
	    m_line=m_line-1
	   else
	    m_dlg=nil
	   end
	  end
 	elseif m_talk_target then
	 	talk()
 	elseif m_pickup_target then
	 	pickup_object()
	 elseif m_statue_target then
	  rotate_statue_target()
		elseif m_crane_target then
		 toggle_crane_ctrl()
		elseif m_rythm_target then
		 toggle_rythm()
	 end
	elseif use_pressed then
		p = inventory.items[inventory.cur_item]
 	if p != nil and p.can_use(p) then 
	  p.use(p)
	 end
	end 
	-- auto talk 
	if not action_pressed
	 and not use_pressed 
	 and m_talk_target 
	 and m_talk_target.dlg!=nil
	 and not m_talk_target.dlg.read
	 then
	  talk()
	end

	if not m_inventory_blocked then
	 if btnjp[2] or btnjp[3] then
	  local cur=inventory.cur_item
	  if btnjp[3] then
	   cur-=1
	   if cur<0 then
	    cur=inventory.count
	   end
	  else
	   cur+=1
	   if cur>inventory.count then
	    cur=0
	   end
	  end 
	  inventory.cur_item=cur
	 end
	end
	m_curse_target=nil
 if m_room.ld != nil then
  if player_near(door_get_x(m_room.ld),16) then
   m_curse_target=m_room.ld
  end
 end
 if m_room.rd != nil then
  if player_near(door_get_x(m_room.rd),16) then
   m_curse_target=m_room.rd
  end
 end
end

function start_dialog(dlg)
 m_dlg=dlg
	m_line=1
	if m_dlg.room_trigger != nill then
	 add(m_room_triggers,m_dlg.room_trigger)
	end
end

function talk()
	start_dialog(m_talk_target.dlg)
	if	m_talk_target.dlg!=nil then
	 m_talk_target.dlg.read=true
	end
end

function pickup_object()
	add(inventory.items,m_pickup_target)
	del(pickups,m_pickup_target)
	m_pickup_target=nil
	inventory.count+=1
end

--- puzzles

m_bats_spr=104

m_bats={
	{x=24, room=room_bats_pattern, f=false},
	{x=48, room=room_bats_pattern, f=false},
	{x=62, room=room_bats_pattern, f=true},
	{x=72, room=room_bats_pattern, f=false}
}

m_statues_puz_r1={
 {x=24, f=true, s=false},
 {x=48, f=true, s=false},
 {x=72, f=true, s=true},
 {x=96, f=true, s=false}
}

function upd_puzzles()
 m_crane_target=false
 if m_room.id == room_eye_puzzle then
  upd_eye_puzzle()
 elseif m_room.id == room_eye_puzzle + 1 then
  m_eye_solved = true
 elseif is_statue_room(m_room.id) then
  upd_statue_puzzle()
 elseif m_room.id==room_crane_puzzle then 
  upd_decorator()
 elseif m_room.id==room_dance_puzzle then
  upd_rythm()
 end 
end

function reinit_puzzles()
 if m_room.id==room_eye_puzzle then
  reinit_eye()
 elseif is_statue_room(m_room.id) then
  reinit_statues()
 elseif m_room.id==room_crane_puzzle then
  reinit_decorator()
 elseif m_room.id==room_dance_puzzle then
  reinit_rythm()
 elseif m_room.id==room_end then
  stop_music()
 elseif m_music_paused then
  start_music()
 end
end

function is_bat_room(room)
 return room==room_bats_pattern
end

function is_statue_room(room)
 return room==room_bats_puzzle
end

function draw_puzzles()
 if is_bat_room(m_room.id) then
  draw_bats()
 elseif is_statue_room(m_room.id) then
  draw_statues()
 elseif m_room.id==room_crane_puzzle then
  draw_decorator()
 elseif m_room.id==room_dance_puzzle then
  draw_rythm()
 end
end

function reinit_statues()
 m_statue_target=nil
end

function rotate_statue_target() 
 m_statue_target.f=not m_statue_target.f
 local statues = get_room_statues()
 
 solved=true
 for s in all(statues) do
  solved = solved and s.f == s.s
 end
 
 if solved then
  m_room.rd.cursed=nil
 end
end

function draw_bats() 
 for bat in all(m_bats) do
  if bat.room == m_room.id then
   spr(104,bat.x,8,1,1,bat.f)
  end
 end
end

function get_room_statues()
 return m_statues_puz_r1
end

function draw_statues()
 local statues = get_room_statues()
 for s in all(statues) do
  local x = s.x
  spr(121,x,40,1,1,false,false)
  spr(121,x,48,1,1,false,true)
  spr(106,x,32,1,1,s.f,false)
 end
end

function upd_statue_puzzle()
 m_statue_target=nil
 local statues = get_room_statues()
 for s in all(statues) do
  local x = s.x
  if player_near(x, 4) then
   m_statue_target=s
  end
 end
end

function reinit_eye()
 m_eye_timer=0
 m_eye_frame=0
 m_eye_seen=false
 rooms[room_eye_puzzle].rd.cursed=nil
end

function upd_eye_puzzle()
 m_eye_frame+=1
 m_eye_timer=m_eye_frame/m_framerate
 tile=166
 if m_eye_solved then
  tile=166
 elseif m_room.rd.cursed != nil then
  tile=183
 elseif m_eye_timer>m_eye_t_open then
  tile=166
  m_eye_timer=0
  m_eye_frame=0
 elseif m_eye_timer>m_eye_t_opening then
  tile=183
  if btn(0) or btn(1) then
   if m_room.rd.cursed == nil then
    m_room.rd.cursed={
    	room=room_eye_puzzle,
  	 	side=0}
   end
  end
 elseif m_eye_timer>m_eye_t_closed then
  tile=167
 else
  tile=166
 end
 mset(49,9,tile)
end

--- decorator

decorators={
 {room=21,x=col_x(12),y=40,id=0,sx=48,sy=24},
 {room=21,x=col_x(10),y=40,id=1,sx=56,sy=24},
 {room=21,x=col_x(5),y=40,id=2,sx=64,sy=24},
 {room=21,x=col_x(7),y=40,id=3,sx=72,sy=24}
}

m_decorators_solved=false

crane={
 x=col_x(5), y=16
}

m_crane_ctrl=false
m_crane_target=false

m_crane_object=nil
m_crane_caught_y=0


function reinit_decorator()
 
end

function toggle_crane_ctrl()
 m_crane_ctrl=not m_crane_ctrl
 m_inventory_blocked=m_crane_ctrl
end

m_crane_slower=0
m_crane_slowdown=4

function upd_decorator()
 
 if player_near(col_x(2),8) then
  m_crane_target=true
  if any_move() then
   if m_crane_slower != 0 then
    m_crane_slower-=1
   else
    if m_crane_slowdown > 0 then
     m_crane_slower=m_crane_slowdown
     m_crane_slowdown-=1
    end
   end
  else
   m_crane_slower=0
   m_crane_slowdown=4
  end  
  
  if m_crane_slower!=0 then
   return 
  end
  
  if m_crane_ctrl then
   local xdiff=-crane.x
   local ydiff=-crane.y
   if btn(0) then
    crane.x-=1
   elseif btn(1) then
    crane.x+=1
   end
   if btn(2) then
    crane.y-=1
   elseif btn(3) then
    crane.y+=1
   end
   clamp_crane()
   if m_crane_object!=nil then
    xdiff+=crane.x
    ydiff+=crane.y
    if xdiff!=0 or ydiff!= 0 then
     move_crane_object(xdiff,ydiff)
    end
   end
  end
  upd_crane_catch()
 end
end

function decorator_solved()
 
end

function move_crane_object(x,y)
 m_crane_object.x+=x
 m_crane_object.y+=y
end

function upd_crane_catch()
 if btnjp[4] then 

  if m_crane_object then
   m_crane_object=nil
   
   if not m_decorators_solved then
    local solved=true
    for d in all(decorators) do
     solved=solved and d.x==d.sx and d.y==d.sy
    end
    if solved then
     m_decorators_solved=true
     rooms[21].rd.cursed=nil
    end
   end
  else
   for d in all(decorators) do
    local x=crane.x
    local y=crane.y
    if x==mid(d.x,x,d.x+8)
     and y==mid(d.y,y,d.y+16) then
      m_crane_object=d
      m_crane_caught_y=16-(y-d.y)
     break
    end 
   end
  end
 end
end

function clamp_crane()
 crane.x=mid(col_x(1),crane.x,col_x(13))
 if m_crane_object != nil then
  crane.y=mid(8,crane.y,
   55-m_crane_caught_y+1)
 else
  crane.y=mid(8,crane.y,55)
 end
end

function draw_decorator()
 for x in all(decorators) do
  if m_room.id==x.room then
   spr(136+x.id,x.x,x.y,
    1,2,false,false)
  end
 end
 --draw crane
 line(crane.x,8,crane.x,crane.y,8)
end

-- rythm 

m_note1="‹"
m_note2="‘"

m_rythm_active=false

m_rythm_start_time=0.0
m_rythm_time=0.0

m_inst_y = 50
m_top_y = 8

m_tolerance=1.0/4

m_rythm_success=false

m_sheet={
 {m=1 , b=1, s=1},
 {m=2 , b=1, s=1},
 {m=3 , b=1, s=1},
 {m=4 , b=1, s=1},
 {m=5 , b=1, s=0},
 {m=6 , b=1, s=0},
 {m=7 , b=1, s=1},
 {m=7 , b=2, s=1},
 {m=7 , b=3, s=1},
 {m=8 , b=1, s=2},
 {m=10, b=1, s=2},
 {m=12, b=1, s=1},
 {m=13, b=1, s=1},
 {m=14, b=1, s=1},
 {m=15, b=1, s=0},
 {m=15, b=2, s=0},
 {m=15, b=3, s=0},
 {m=16, b=1, s=2},
 {m=18, b=1, s=2}
}

m_rythm_score=0
m_rythm_hi_score=0
m_rythm_max_score=0

m_time_to_y=20.0

--times
-- 4 second intro
m_intro_t=4
-- 8 second page (32 notes)
m_beat_t=8/32
-- 3 beats per bar
m_bar_t=m_beat_t*3

for n in all(m_sheet) do
 m_rythm_max_score+=1
 n.t=m_intro_t
  +(n.m-1)*m_bar_t
  +(n.b-1)*m_beat_t 
end

m_sheet_end_time=m_intro_t
 +m_bar_t*20

m_dance_frames=m_framerate/4

m_r_elapsed=1000
m_l_elapsed=1000
m_double_elapsed=1000

function rythm_fail_notes()
 for n in all(m_sheet) do
  if n.p==nil then
   if m_rythm_time>n.t+m_tolerance then
    n.p=0
   end
  end
 end
end

function rythm_process_input(side)
 for n in all(m_sheet) do
  if n.p==nil then
   if n.t > m_rythm_time-m_tolerance
   and n.t < m_rythm_time+m_tolerance
   and n.s==side then
    n.p=1
   end
  end 
 end
end

function upd_rythm_inputs()
 if m_rythm_active then
  if btnjp[0] or btnjp[1] then
   local backwards = false
   if btnjp[0] then
    backwards=true
    m_l_elapsed=0
   end
   if btnjp[1] then
    m_r_elapsed=0
   end
   if m_l_elapsed
     < m_dance_frames
    and m_r_elapsed
     < m_dance_frames then
    m_double_elapsed=0
   end
   if m_double_elapsed != 0 and m_player_backwards!=backwards then
    m_player_backwards=backwards
   end
   if m_double_elapsed==0 then
    rythm_process_input(2)
   elseif m_r_elapsed==0 then
    rythm_process_input(1)
   elseif m_l_elapsed==0 then
    rythm_process_input(0)
   end
  end
 end
end

function upd_rythm()
 m_rythm_target=false
 if player_near(col_x(7),8) then
  m_rythm_target=true
 end
 m_inventory_blocked=m_rythm_target
 if m_rythm_active then
  -- time
  m_rythm_time=0.5*(time()-m_rythm_start_time)
  m_double_elapsed+=1
  m_l_elapsed+=1
  m_r_elapsed+=1
  -- inputs and scoring
  upd_rythm_inputs()
  rythm_fail_notes()
  upd_rythm_score()
  -- auto end
  if m_rythm_time > m_sheet_end_time then
   toggle_rythm()
  end
 end
end

function upd_rythm_score()
 m_rythm_score=0
 for n in all(m_sheet) do
  if n.p != nil then
   m_rythm_score+=n.p
  end
 end
 if m_rythm_score > m_rythm_hi_score then
  m_rythm_hi_score=m_rythm_score
 end
end

function check_rythm_success()
 upd_rythm_score()
 for n in all(m_sheet) do
  if n.p != nil then
   n.p=nil
  end
 end
 if m_rythm_hi_score >= m_rythm_max_score * 0.7 then
  m_rythm_success=true
  rooms[room_dance_puzzle].rd.cursed=nil
 end
end

function toggle_rythm()
 if m_rythm_active then
  m_rythm_active=false
  check_rythm_success()
  music(-1, 1000)
 else
  m_rythm_active=true
  m_rythm_start_time=time()
  m_rythm_time=0.0
  music(5)
 end
 m_move_blocked=m_rythm_active
end

function draw_rythm()
 if m_rythm_active then
  local screen_h=m_inst_y-m_top_y
  for n in all(m_sheet) do
   local delay=m_rythm_time-n.t
   local n_y=delay*m_time_to_y
    +m_inst_y
   if n_y > 0
    and n_y<m_inst_y+8 then
    local status=grey
    if n.p!=nil then
     if n.p == 1 then
      status=lightgreen
     else
      status=red
     end
    else
     if n.t > m_rythm_time-m_tolerance
      and n.t < m_rythm_time+m_tolerance then
      status=white
     end
    end
    
    if n.s==0 or n.s==2 then
     print(m_note1,col_x(5),
      n_y,status)
    end
    if n.s==1 or n.s==2 then
     print(m_note2,col_x(8),
      n_y,status)     
    end
   end
  end
 end
end

function start_music()
 m_music_paused=false
 if m_room.id == room_end_leave
  or m_room.id==room_end_stay then
  music(10,3000)
 else
  music(8,3000)
 end
end

function stop_music()
 m_music_paused=true
 music(-1,1000)
end

function reinit_rythm()
 stop_music()
end

---- draw

room_texts={
 {room=room_start, text="forever lost in the\nnever ending museum\nof    still    life"}
}

function draw_room_texts()
 for t in all(room_texts) do
  if m_room.id == t.room then
 	 print(t.text,24,22,8)
  end
 end
end

function draw_splash()
 print("press —",44, 90, 7)
end	

function draw_npcs()
 for t in all(npcs) do
  if m_room.id==t.room then
   local h=2
   if t.small then
    h=1
   end
  	spr(t.sprite,t.x,40,1,h,t.back,false)
  	--if t.dlg and not t.dlg.read then
  	-- spr(107,t.x+5,39,1,1,false,false)
  	--end
  end
 end
end

function draw_room()
 -- draw map
 map((m_room.i)*14,m_room.j*7,
  m_mapx,m_mapx,
  14,7)
 -- draw back of car
 if m_room.id==9 
  and m_car_available == true then
  spr(70,8,40,1,2,true,false)
 end
 -- draw pickups
 for p in all(pickups) do
  if m_room.id==p.room then
   local x=col_x(p.column)
   spr(p.sprite,x,47)
  end
 end
 -- draw curses
 if m_room.ld != nil 
  and m_room.ld.cursed != nil then
  spr(113,m_mapx+5,36+time()%2) 
 end
 if m_room.rd != nil
  and m_room.rd.cursed != nil then
  spr(113,m_mapx+m_roomw-12,36+time()%2)
 end
 -- draw doors
 if m_room.md != nil then
  for md in all(m_room.md) do
   if md.locked != nil then
    x=door_get_x(md)
    
    door_spr = 203
    if md.locked==2 then
     door_spr=204
    elseif md.locked==3 then
     door_spr=205
    end
    
    spr(door_spr,x+4,40,1,2,false,false)
   end
  end
 end
end

function smap(
 cel_x, cel_y, 
 s_x, s_y, 
 cel_w, cel_h,
 scale_w ,scale_h, 
 flip_x, flip_y, 
 layer)
 for i=0,cel_w-1 do
  for j=0,cel_h-1 do
   cx=cel_x+i
   cy=cel_y+j
   tile =mget(cx,cy)
   skip=tile==0
   if not skip and layer != -1 then
    t_layer = fget(tile)
    skip=t_layer != layer
   end
   if not skip then
    w=flr(8*scale_w)
    h=flr(8*scale_h)
    sx=s_x+i*w
    sy=s_y+j*h
    sspr(
     (tile%16)*8,
     flr(tile/16)*8
     ,8,8
     ,sx,sy,
	    w,
	    h)
	  end
  end
 end
end

function get_player_spr()
 if m_rythm_active then
  if m_double_elapsed < m_dance_frames then
   return 77
  elseif m_l_elapsed < m_dance_frames
   or m_r_elapsed < m_dance_frames then
   return 76
  end
  return 75
 else
  local character=64+m_step/(m_step_anim/3)
 	return character
 end
end

function draw_player()
 --draw monkey
 local player_spr=get_player_spr()
 
 if m_room.id == m_road_room then
  spr(70,m_x-16,40,4,2,
   m_player_backwards,false)
 else 
  spr(player_spr,m_x,40,1,2,
   m_player_backwards,false)
 end
end

function draw_cart()
 if m_dlg then
 	draw_dialog()
 else
  local md_target=false
  if m_room.md != nil then
   for md in all(m_room.md) do
    if player_near(door_get_x(md),4) then
     md_target=true
     if md.locked != nil then
      print("locked ("..md.locked..")",24,81,5)
     else
      print("— enter",24,81,7)
     end
    end
   end
  end
  if not md_target then
	  if m_talk_target  then
	 	 print("— talk",24,81,7) 
	 	elseif m_pickup_target then
	 		print("— take",24,81,7)
	  elseif m_statue_target then
	   print("— rotate",24,81,7)
	  elseif m_crane_target then
	   if not m_crane_ctrl then
	    print("— use crane",24,81,7)
	   else
	    print("— release crane\n”ƒ‹‘ move crane\nŽ catch/release",24,81,7)
	   end
	  elseif m_rythm_target then
	   print("— start/stop",24,81,7)
	    score_color=white
	    if m_rythm_success then
	     score_color=green
	    elseif m_rythm_hi_score >0 then
	     score_color=orange
	    end
		   print("score   : "..m_rythm_score*50,24,94,white)
	    print("hi-score: "..m_rythm_hi_score*50,24,102,score_color)
	  end
	 end
 end
 p = inventory.items[inventory.cur_item]
 if p then
  if not m_dlg 
   and not m_inventory_blocked then
   sspr(
    (p.sprite%16)*8,
    flr(p.sprite/16)*8
    ,8
    ,8
    ,104,72,16,16)
   
   show_action=p.can_use(p)
   col=5
   if show_action then
  	 col = 7 
  	end
   print("Ž "..p.action,24,88,col)
  end
 end
 map(112,16,0,0,16,16)
end

function draw_dialog()
 if m_dlg then
  spk=m_dlg[m_line][1]
  msg=m_dlg[m_line][2]
  if spk.back then
   dx=24
   dw=-16
  else
   dx=8
   dw=16
  end
  sspr((spk.sprite%8)*8,flr(spk.sprite/16)*8,8,8
   ,dx,72+spk.faceyoff,dw,16)
  print(spk.name,24,81,10)
  print(msg,17,88,7) 
 end
end

function draw_sroom( 
 roomi, roomj,
 offx,offy)
 smap(roomi*14+offx,
   roomj*7+offy,
   5,12,
   7,2,
   2,2,
   false,false
   ,-1)
end

function draw_es()
 if m_end_screen == es_jack_and_ghost then
  map(7*14,0*7,
   m_mapx,m_mapx,
   14,7)
 elseif m_end_screen==es_jack then
  map(7*14,1*7,
   m_mapx,m_mapx,
   14,7) 
 end
 if m_end_screen == es_jack or 
  m_end_screen == es_jack_and_ghost then
  sspr((player.sprite%8)*8,flr(player.sprite/16)*8,8,8
   ,16,16,48,48)
 end
 if m_end_screen == es_jack_and_ghost then
  sspr((ghost.sprite%8)*8,flr(ghost.sprite/16)*8,8,9
   ,64,16-6,48,9*6,true,false)
 elseif m_end_screen == es_end then
 
 end
end

-- door api

function room_get_door(room, side) 
 door = room.ld
 if side == 1 then 
  door = room.rd 
 elseif side>1 then
  side -= 1
  if m_room.md != nil then
   door = m_room.md[side]
  end
 end
 if door != nil and door.dest != nil then
  return door
 end
end

function door_get_destination(door)
 if door.cursed != nil then
   return door.cursed
 end
 return door.dest
end

function door_get_x(door)
 if door.side == 0 then
  return m_mapx+8
 elseif door.side == 1 then
  return m_mapx+m_roomw-8
 else
  return m_mapx+door.column*8-4
 end
end

-- input

function btnupd()
 for i=0,5 do
  btnjp[i]=false
  if btn(i) then
   if not btnjp[i] 
    and not btnmute[i] then
     btnjp[i]=true
     btnmute[i]=true
   end
  else
   btnmute[i]=false
  end
 end
end

btnjp={}
btnmute={}
for i=0,5 do
 btnjp[i]=false
 btnmute[i]=false
end

-- create characters
player={}
ghost={}
cop={}
cop_ps={}
dream={}
heart={}
archives={}

-- create dialogs
dlg_intro={
{cop,"you the one they send?"},
{cop,"as you know we have a\nghost situation here."},
{cop,"find out what it wants\nand make it leave."},
{cop,"builders are afraid to\ntear the place down."},
{cop,"we need the space,\nfor whatever.\nor something.\ngood luck."}
}
	
dlg_meeting_ghost={ 
{player,"i'm here to help.\ni'm jack.\nwhat's your name?"},
{ghost,"my name..."},  
{player,"don't worry.\nit'll come back."},
{player,"how do you feel?" }, 
{ghost,"i got the millenial\nblues."},
{player,"what's that?"},
{ghost,"craving for love"},
{ghost,"when all you get"},
{ghost,"is likes."}
}

dlg_meeting_ghost.room_trigger=function () 
 ghost.room=room_start_investigation
 ghost.x=56
 ghost.dlg=dlg_shawn
end

dlg_dream={
 {dream, "i wake up and\ni watch you sleep."},
 {dream, "knowing my eyes\nwill not always\nopen on you."},
 {dream, "i have loved you,\nshawn."},
 {dream, "but i feel i must go."} 
}

dlg_dream.room_trigger=function()
 dream.room=room_none
end

dlg_shawn={
	{player,"i think i saw\nan old lover of yours."},
	{player,"he whispered a name."},
	{player,"shawn.\nis that you?"},
	{ghost, "oh..."},
	{ghost, "that's right, shawn."},
	{ghost,"little shawn who died\nfrom love."},
	{ghost,"shawn was in nobody's\nheart, and so shawn's\nheart stopped beating"},
	{ghost,"that's what happened."},
	{player,"shawn then.\ni'll go to the police\nstation do some\nresearch."},
	{player,"i'll see if i can\nget something to\nhelp your memory."},
	{player,"the law can drive\nme there.\n"}
}

dlg_shawn.room_trigger= function()
 cop.dlg=dlg_lets_investigate
 connect_road()
end

dlg_lets_investigate={
{player,"i need to look up\nsome of your files."},
{cop,"sure get in the car."}
}

dlg_life_of_shawn={
{player,"so..."},
{player,"shawn, gotcha."},
{player,"died in an accident\nlast year."},
{player,"single at the time.\n"},
{player,"his obituary said:"},
{player,"always between lovers\nand heartbreaks, shawn\nwill be remembered for\nhis love of love."},
{player,"...\noh."},
{player,"i should talk to him."}
}

dlg_life_of_shawn.room_trigger=function()
 ghost.room=room_hall
 ghost.dlg=dlg_truth
 keys[2].room=room_hall
 cop.dlg=nil
end

dlg_truth={
{player,"you did not live without\nlove. in fact you had\nlots of romances."},
{ghost,"but... he left me.\nand left a hole."},
{ghost,"and i watched him go on.\nbut i couldn't move."},
{player,"for your life to be\nfilled with heartbreaks\nit had to be filled\nwith love."},
}

dlg_truth.room_trigger=function()
 ghost.room=room_key_3
 ghost.x=col_x(5)
 ghost.dlg=dlg_still_lives
end

dlg_still_lives={
	{ghost,"i miss the one i loved\nwhen i..."},
  {ghost,"died."},
	{ghost,"but he didn't love me\nanymore."},
	{ghost,"and so i stick around\nthose paintings. those\nstill lives."},
	{player,"maybe it's time\nto let go."},
	{ghost,"i wish i could...\n"},
	{ghost,"didn't you recently\nbreak up too?"},
	{player,"...\n\nyes i did."},
	{player,"my lover found a new\nlover."},
	{player,"and i know he makes him\nhappier than i ever\ncould."},
	{player,"but my heart still\nhurts every day."},
	{ghost,"had we met each other,\nin better conditions."},
	{ghost,"maybe we'd have been\nlovers?"},
	{player,"that's possible."}
}

dlg_still_lives.room_trigger=function()
 ghost.room=room_end
 ghost.x=col_x(8)
 ghost.dlg=dlg_deal
end

dlg_deal={
	{ghost,"i know your heart\nknows my pain."},
	{ghost,"and i'm tired of mine."},
  {ghost,"i'll make a deal\nwith you."},
	{player,"tell me."},
	{ghost,"two options,\nyour choice."},
	{ghost,"stay here with me\nforever."},
	{ghost,"we will become\npaintings."},
	{ghost,"or prove you can defeat\nyour past and leave."},
	{ghost,"go on to love again.\nor try."},
	{ghost,"i will leave this world.\nand continue my path."}
}

dlg_warn_ending_1={
	{ghost,"come this way and we'll\nstay here forever."},
	{ghost,"in the never ending\nmuseum of still life."},
	{ghost,"together until the end\nof times."},
	{ghost,"never lonely,\namong these paintings."}
}

dlg_warn_ending_2={
	{ghost,"leave this way and\nthere's no coming back."},
	{ghost,"i will leave.\nthe museum will be torn\ndown."},
	{ghost,"of it nothing\nwill remain."},
	{ghost,"we'll walk off our past."},
 {ghost,"and into the unknown.\ngood or bad."}
}

dlg_ending_1={
	{heart,"jack disappeared that\nnight."},
	{heart,"the construction company\nwent bankrupt,\nand the project was\nabandoned."},
	{heart,"the haunted museum\nstill stands."},
	{heart,"it is said jack & shawn\nare forever lost, in\nthe never ending museum\nof still life."},
	{heart,"young lovers come visit\nthe museum, for spooks\non romantic dates."},
	{heart,"they do not remain long\nfor it is said watching\nthe still lives, only\nbrings them down."},
	{heart,"the end"}
}

dlg_ending_2={
	{heart,"as jack came out, the\nghost vanished."},
	{heart,"some time later, the\nmuseum was destroyed."},
	{heart,"jack watched it go down,\nand felt some kind of\nrelief."},
	{heart,"he met a construction\nworker that day, and\nthey got on well."},
	{heart,"they went on a few\nnice dates, but then\nstopped seeing each\nother."},
	{heart,"and moved on to other\nthings."},
	{heart,"the end"}
}

dlgs={
	dlg_intro,
	dlg_meeting_ghost,
	dlg_dream,
	dlg_shawn,
	dlg_lets_investigate,
	dlg_life_of_shawn,
	dlg_truth,
	dlg_still_lives,
	dlg_deal,
	dlg_ending_1,
	dlg_ending_2
}

-- fill character data
player.sprite=64
player.faceyoff=0
player.name="jack"

ghost.room=room_hall
ghost.x=70
ghost.back=true
ghost.sprite=68
ghost.faceyoff=-3
ghost.dlg=dlg_meeting_ghost
ghost.name="the ghost"

cop.room=room_start
cop.x=64
cop.back=true
cop.sprite=67
cop.faceyoff=0
cop.name="the law"
cop.dlg = dlg_intro

cop_ps.room=room_police
cop_ps.x=88
cop_ps.back=false
cop_ps.sprite=67
cop_ps.faceyoff=0
cop_ps.dlg=nil
cop_ps.name="the law"

archives.room=room_police
archives.x=24
archives.sprite=11
archives.faceyoff=0
archives.dlg=dlg_life_of_shawn
archives.name="the data"
archives.small=true

dream.room=room_dream
dream.x=28
dream.back=true
dream.sprite=69
dream.faceyoff=-3
dream.dlg=dlg_dream
dream.name="the dream"

heart.room=room_none
heart.x=0
heart.back=true
heart.sprite=69
heart.faceyoff=-3
heart.dlg=dlg_dream
heart.name="the heart"

npcs={ghost,
 cop, 
 cop_ps, 
 archives,
 dream,
 heart}

--- create items ---

inventory={}
inventory.items={}
inventory.count=0
inventory.cur_item=1

keys={}
for i=1,4 do
 key={}
 key.action="unlock door "..i
 key.sprite=117+i-1
 key.lock=i
 key.can_use=function(p)
   if m_room.md != nil then
    for md in all(m_room.md) do
     if md.locked == p.lock then
      x=door_get_x(md)
      return player_near(x,4)
     end
    end
   end
   return false
  end
 key.use=function(p)
   for md in all(m_room.md) do
    if md.locked == p.lock then
     x=door_get_x(md)
     if player_near(x,4) then
      md.locked = nil
     end
    end
   end
  end
 if i == 1 then
  key.room=room_dream
  key.column=7
 elseif i == 2 then
  --key.room=14
  -- spawned by a dialog
  key.room=room_none
  key.column=10
 elseif i == 3 then
  key.room=room_key_3
  key.column=9
 else
  -- ???
  key.room=room_none
  key.column=7
 end
 add(keys,key)
end

function room_has_opposite_door(room, side) 
 if side==0 then
  return rooms[room].rd!=nil
 elseif side==1 then
  return rooms[room].ld!=nil
 end
 return true
end

function room_blocks_curse()
 if m_room.id == room_end then
  return true
 end
 return false
end

anti_curse={}
anti_curse.action="lift curse"
anti_curse.sprite=112
anti_curse.room=room_anti_curse
anti_curse.column=6.5
anti_curse.can_use = function (p) 
 return m_curse_target != nil
  and m_curse_target.cursed != nil
end  
anti_curse.use = function(p)
 m_curse_target.cursed=nil
end

curse_charm={}
curse_charm.action="cast curse"
curse_charm.sprite=113
curse_charm.room=room_curse
curse_charm.column=7
curse_charm.can_use = function (p)
 return m_curse_target != nil 
  and m_curse_target.cursed == nil
  and room_has_opposite_door(m_curse_target.room, m_curse_target.side)
  and not room_blocks_curse() 
end
curse_charm.use = function (p)
 _room=m_curse_target.room
 _side=m_curse_target.side
 if _side == 1 then
  _side = 0
 else
  _side = 1
 end
 m_curse_target.cursed={
  room=_room,
  side=_side}
end

pickups={
 anti_curse,
 curse_charm
}
pickups.count=2
for key in all(keys) do
 add(pickups,key)
 pickups.count+=1
end

if m_debug then
 -- cheat code only
 for p in all(pickups) do
  add(inventory.items,p)
 	 del(pickups,p)
 inventory.count+=1
 end
end

-- create extra colliders

row_length=8
rooms={}

for i=1,32 do
 room={}
 room.ld={room=i, side=0}
 room.rd={room=i, side=1}
 room.j=flr((i-1)/row_length)
 room.i=flr((i-1)%row_length)
 room.id=i
 rooms[i]=room
end

for i=1,7 do
 for j=0,3 do
  rooms[i+j*row_length].rd.dest=
   rooms[i+1+j*row_length].ld  
 end
end

for i=2,8 do
 for j=0,3 do
  rooms[i+j*row_length].ld.dest=
   rooms[(i-1)+j*row_length].rd
 end
end

function end_in_life()
 start_dialog(dlg_ending_2)
 m_end_screen=es_jack
end

function end_in_death()
 start_dialog(dlg_ending_1)
 m_end_screen=es_jack_and_ghost
end

rooms[room_end_leave].init_trigger=function()
 end_in_life()
end

rooms[room_end_stay].init_trigger=function()
 end_in_death() 
end


if m_debug then
 m_room=rooms[room_dance_puzzle]
 player.room=room_dance_puzzle
else
 m_room=rooms[room_start]
end
-- curse some doors
-- puzzle curses 
rooms[room_bats_puzzle].rd.cursed=
 {room=room_bats_puzzle, side=0}
 
rooms[room_crane_puzzle].rd.cursed=
 {room=room_crane_puzzle, side=0}
 
rooms[room_dance_puzzle].rd.cursed=
 {room=room_dance_puzzle, side=0}
-- anti curse req blocker
rooms[room_dance_puzzle].ld.cursed=
 {room=room_dance_puzzle, side=1}
 -- access to curse charm
rooms[room_b1_doors].ld.cursed=
 {room=room_b1_doors, side=1}
-- remove doors to unused rooms
-- 2f
rooms[room_end_door].ld=nil
rooms[room_head].rd=nil
-- 1f
rooms[room_tongue_door].rd=nil
-- b1
rooms[room_curse].ld=nil
rooms[room_key_3].rd=nil
-- b2
rooms[room_b2_doors].ld=nil
rooms[room_anti_curse].rd=nil
rooms[room_end_stay].ld=nil
-- create middle doors

rooms[room_bats_pattern].md={
 {room=room_bats_pattern, 
 side=2,
 locked=1,
 column=11, 
 dest={room=room_b1_doors, side=2}}
}
rooms[room_b1_doors].md={
 {room=room_b1_doors, 
 side=2,
 column=11, 
 dest={room=room_bats_pattern, side=2}},
 {room=room_b1_doors,
 side=3,
 locked=2,
 column=2,
 dest={room=room_b2_doors,side=3}}
}
rooms[room_b2_doors].md={
 {room=room_b2_doors,
 side=2,
 column=2,
 dest={room=room_b1_doors,side=2}}
}

rooms[room_tongue_door].md={
{room=room_tongue_door,
 side=2,
 column=2,
 locked=3,
 dest={room=room_head,side=2}}
}
rooms[room_head].md={
{room=room_head,
 side=2,
 column=2,
 dest={room=room_tongue_door,side=2}}
}

rooms[room_end_door].md={
{room=room_end_door,
 side=2,
 column=6,
 dest={room=room_end,side=2}}
}
rooms[room_end].md={
{room=room_end,
 side=3,
 column=6,
 dest={room=room_end_door,side=3}}
}

-- connect the road

function connect_road()
 m_car_available=true
 rooms[room_start].ld={room=room_start, side=0,
	 dest={room=room_road,side=1}}
 rooms[room_road].rd={room=room_road, side=1,
  dest={room=room_start,side=0}}
end 

if m_debug then
 connect_road()
end

-- create extra collisions

rooms[room_curse_puzzle].colliders={}
rooms[room_curse_puzzle].colliders[1]=
 {xstart=48, xend=64}

rooms[room_head].colliders={}
rooms[room_head].colliders[1]=
 {xstart=48, xend=64}
 
rooms[room_end].coltriggers={}
rooms[room_end].coltriggers[1]=
 {xstart=8, xend=16, side=0, trigger=function()
   start_dialog(dlg_warn_ending_1)
  end}
rooms[room_end].coltriggers[2]=
 {xstart=96, xend=104, side=1, trigger=function()
   start_dialog(dlg_warn_ending_2)
  end}
if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
0000000066666666eeeeeeee212121222222222122222221ddd1111dddd1111ddddddddd22222221922222214444444444444444499999942212222299999999
0000000065555556eeeeeeee122222122222222222222222d55d111dd55d111d1d5111d522222222922222224555555555555554499999942122222299999999
0070070065555556eeeeeeee222222212222222122212221d115d1ddd115d1dd11d51d51222222219222222143355223355522544a9999941222222299991199
0007700065555556eeeeeeee222222222222222212121212d1115d5dd1115d5d111dd51122222222922222224a311993311129e4444444442122212299911111
0007700065555556eeeeeeee222222212222222121222122d11ddd1dd11ddd1d1111111122222221922222214339122aa99122a4499999942222221299111111
0070070065555556eeeeeeee222222222222222212121212d1d555ddd1d555ddd511111d222222229222222243311223311d22e4499999942222212299111111
0000000066555556eeeeeeee222222212222222122212221dd51115ddd51115d1d5111d522222221922222214331122331dd22e4499999a42222122299911111
0000000066666666eeeeeeee222222222222222222222222d511111ddddddddd11dddd5199999999922222224444444444444444444444442122212299911111
ffffffff33333333888888880000000011111111222222222222222155555555bbbbbbbb99999999222222298eeeeeea331333130000000dcccccccc99911111
ffffffff333333338888888800000007111111122222222222222222111151513b3333332222222222222229e8e8eaee3133333100000dd5cccccccc99911111
ffffffff3333333388888888000000001111111122222222222222211511151133333b332222222122222229ee8ea9ae133313330000d551cccccccc99911111
ffffffff3333333388888888000000071111111222222222eeeeeeee11511111333333b32222222222222229e8eeeaee333133330000d1d1cccccccc11111111
ffffffff3333333388888888000000001111111122222222888888881115111533b3b3332222222122222229eeaeee8e33133313000d515dcccccccc11111111
ffffffff3333333388888888000000071111111222222222eeeeeeee11111111333333332222222222222229ea9ae8ee33333133000d1115cccccccc99911111
ffffffff3333333388888888000000001111111122222222eeeeeeee1111111133b333332222222122222229eeae8e8a13331333000d1111cccccccc99911111
ffffffff33333333888888880000000711111112222222222228822211111111333333b32222222222222229aeeeeea931333333000d1111cccccccc99911111
ffffffff9999999911111111111111199111111133333333aaaa5555dddddddd1111119999111111111111119999999911111111111119999991111111111111
ffffffff99999999111111121111111991111112333555b3555555551111d1111111119999111111111111119999999911111111111119999991111111111111
ffffffff9999999911111111111111199111111133355bb355555555111dd1111111199999911111111111111199119911111111111119999991111111111111
ffffffff999999991111111211111119911111123335bbb35555555511ddd1111111199999911111111111111111111111111111111111111111111111111111
ffffffff99999999111111111111111991111111333bbbb355555555dddddddd1111119999111111111111111111111111111111111111111111111111111111
ffffffff9999999911111112111111199111111233333333555555551111111d1111119999111111991199111111111111111999111111111111111199911111
ffffffff999999991111111111111119911111113333333355555555111111dd1111199999911111999999991111111111111999111111111111111199911111
ffffffff9999999999999999111111199111111233333aa35555555511111ddd1111199999911111999999991111111111111999111111111111111199911111
d000000077777775999999995555555544444444333aaaa399999999000000000000000011111111111111999999999911111999991111119999999999999999
5d000000555555551111111255555555400000043333359399999999000000000000000011111111111111999999999911111999991111119999999999999999
15d000004444444411111111555555554061000433333aa311991199007000000000000011111111111119991199119911111999999111111199119911991999
115d00004444494411111112dddddddd401000043333333311111111000000000070000011111111111119991111111111111111999111111111111111111999
1115d000494444441111111155555555400000043333333311111111000000000000000011111111111111991111111111111111991111111111111111111199
11115d00444944441111111255555555400000043333333311111999000000000000007011111111991199991199119911111999991199119991111111111199
111115d0444444441111111155555555400000043333333311111999000000000000000011111111999999999999999911111999999999999991111111111999
111111564444494411111112dddddddd444444443333333311111999000000000000000011111111999999999999999911111999999999999991111111111999
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004400000044000000000000011a100000000000000000000000000000000000011a10000000000000000000000000000000000000000000000000000000000
094444000944440000044000001110000000000000e00e000000000000044000001110000000000000e00e000004400000044000000440000000000000000000
094a4a00094a4a0009444400004444000499994000dd5d000000000009444400004444000010000000dd5d000944440009444400094444000000000000000000
0044940000449400094a4a00004a4a00049a9a4000dada0000000000094a4a00004a4a000010000000dada00094a4a00094a4a00094a4a000000000000000000
04099900040999000044940000444400009949000055e500000000000044940000444400001100000055e5000044940000449400004494000000000000000000
4449990044499900040999000004400000044400000d6d0000000006040999000604400000010000000d6d000409990004099900040999000000000000000000
40444400404444004449990000111100000444000006660000000006404999000611110000d10000000666004449990044499909944999090000000000000000
4094490040944900404444000041a40000999900050550000000006d404444006d41a4000ddd0000050550004044440040444490494444900000000000000000
40944900409449004094490000411400004994005d06d600000adddd5dddddd5ddddd5ddddd650005d06d6004094490040944900409449000000000000000000
4094490040944900409449000041140090499400d0565600000a6666d666666d66666d6666666500d05656004994499049444400404444000000000000000000
444440004444440040944900004114009949940050ddd00000877777d6777aad677aad777777765a50ddd0004044440090444400404444000000000000000000
0040400000040400444440000010100000909000d5555000008677655777776d77776d777557777ad55550004444444044444444444444000000000000000000
00404000000404000040400000101000009090000060600000dddd5aa566666d6666d6665aa5666d006060000004004000400004004004000000000000000000
0040400000040400004040000010100000909000005050000055505aa50dddd5dddd55505aa505d5005050000004000000400000004004000000000000007000
00404000000404000040400000101000009090000065650000000005500000000000000005500000006565000004000000400000004004000000000000000000
00000000111111110000000700000000070007077000007009080b00e00000e000a0a00000000000006060000000000000000000000000000000000000000000
000000001111111270000070070000077000007007000707e00000c009000c0000d0d00000000000008680000000000000000000000000000000000000000000
0000000012111211070007000000000000e0e0070007000000000007000700000eedee0000000000006666600000000000000000000000000000000000000000
0000000011111112007070000007000700090000070007070000000008000b000eedee0000000000026220000000000000000000000000000000000000000000
0000000011212111000700000000000000e0e0070007000000000007000700000edee00000000000022622000000000000000000000000000000000000000000
000000001211121200707000000007077000007007000707000000000b00080000ddddd000577700022622000000000000000000000000000000000000000000
0000000011111111070007000000000007000707007070000000000700c09000008d800005666660006060000000000000000000000000000000000000000000
00000000111111127000007000000007000000000007000700000000000e000000d0d0005777777700a0a0000000000000000000000000000000000000000000
a000000000000000000000000000000000000000000a0000000a0000000a0000000a000066666666722222722222222722222222000000000000000000000000
0a0008000000080000000707000000000000000000ac900000ae900000a8900000ab900007676760272227277222227022222227000000000000000000000000
00a08e8000808e800000000000000000000000000ac8ca000ae8ea000a828a000ab8ba0007676760222722220722270022222222000000000000000000000000
08eae0e808e8e0e8000700070000000000000000009ca000009ea0000098a000009ba00007676760272227270072700022222227000000000000000000000000
8e0ea08e8e0e808e0000000000000000000000000009000000090000000900000009000007676760222722220007000022222222000000000000000000000000
e808eae0e808e8e007000007000000000000000000099a0000099a0000099a0000099a0007676760272227270072700022222227000000000000000000000000
0e8e0ea00e8e0e000000000000000000000000000009000000090000000900000009000007676760227272220722270022222222000000000000000000000000
00e0000a00e0000000000007000000000000000000099a0000099a0000099a0000099a0007676760222722277222227022222227000000000000000000000000
eeeeeeeeeeeeeeee888888fff488888833333333333333331111111111111111eeeeeeeeeeeeeeeeeee2ee2eeeeeee7e00009a0000000000eeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee88888ffffff4888833333331133333331111110000001111e2229992272227222228ee827222222e00009a0000000000eeeeeeeeeeeeeeee
eee3eeeeeeeeeeee8888ffffffff488833333311cc333333111110dddddd0111e7294a492222d6d222eeaaee2227722700099aa000000000eeeeeeeeeeee3eee
eeee33eeeeeeaeee888ffffffffff4883333311cccc3333311110dddddddd011e229a9a922276a6722eeaaee22d77d2e009999a000000000eeeaeeeeee33eeee
eeee403eeeeeeaee888fffffffffff48333311cccacc333311110dddddddd011e2294a492222d6d42228ee82277aa77e0009899000000000eeaeeeeee304eeee
eee999eeeeeeeaae88f444f4444f4ff833311cccaaaccc33111110aaaaaa0111e2229992b2222754272bee22277aa77e0009889000000000eaaeeeeeee999eee
ee98899eeeeea0ae88f004ff000f4ff83311cccaa9aaccc31111110aaaa01111722725b23b222b5422b3322252d77dbe0000a00000000000ea0aeeeee99889ee
ee98999eeeea0aae88f00fff000f4ff8311cccccaa9aaccc11111110aa011111e22225b33b223b542b3373b5522773bb0007670000000000eaa0aeeee99989ee
ee99999555a0aaae8ff00f0f000f44f83117cccccaaaccc111111110a0011111322253bb3bb33b555b37e7b5b32253b3000d670000000000eaaa0a55599999ee
e559995aaa0aaaee8ffff00ffffff48831757cccccaccc1311111110d001111133b553bb33b333bbb37e73b3b32253b50007d70000000000eeaaa0aaa599955e
55555555aaaaa56e8ffff00fffffff88331757ccccccc13311111110a0011111333533bb333bb33b37e733bbb333b3b50007770000000000e65aaaaa55555555
66555555566666de888ffffffffff8883331757ccccc13331111110dddd01111eb353bbbb333bb3377733777773333750007670000000000ed66666555555566
e666666666ddddee88876ffff4ff888833331757ccc13333111110ddaddd0111e3333b33b333bbb77773777777733773000d670000000000eedddd666666666e
eedddddddddeeeee8887677644f88888333331757c13333311110dddddddd011e333bb33bb333b7177777777577737730007d70000000000eeeeedddddddddee
eee6666666eeeeee8886776744888888333333177133333311110aaaaaaaa011e23bbb33bb3b33e777557775577577730a07d700a0000000eeeeee6666666eee
e55555555555eeee888fffffff88888833333331133333331111100000000111e23b33333b3333e7757775577775773300aaaaaa00000000eeee55555555555e
ccccccccccccc5cc0000000011111111111111111111111111111111111111110000000099999999777000077777777700000000000000000000000000000000
cccccccc77ccc55c0000000011111112111111121111111118888111188881110000000700000007755700070750007500000000000000000000000000000007
cccccc77777cc55c0000000011111111111110111111111888888811888888110000000000000000700570770075075000000000000000000000000000000000
ccccc7757577555c0000000011111112101111121111118888888881888888810000000700000007700057570007750000000000000000000000000700000007
ccccc7775777c5cc0000000015111151111101111111118888888881000000810000000000000000700777070000000055555550555555550000000770000000
ccccc975757757cc000000001d1771d21110111211111188088888810707708100000007000000077075557775000007ddddddd5dddddddd0000000777000007
ccccc9997775777c000000001ddbbdd111111111111111880000008100000081000000000000000077500057075000751111111d111111110000000707700000
cccc999999c777770000000015dbbd52110111121111199888888881888888819999999900000007750000070077775011111112999999990000000700770007
cccc9a9c99c888877ccccccc11d75d11111111111111199988888221111111119000000000000009777000077bbbbbbb00000000000000050000000700077000
cccc99cc99c7887777cccccc1117d112110111121111994988822221188881119000000700000009755700070733333500000000500000500000070700000007
cccc99cc99c7787777cccccc1117d111111011111119949982222221888888119000000000000009700570770075333300000000050005000000707700000000
cccccccc9cc77877777ccccc1117d112111111121199499122222222800008819000000700000009700057570007753300000000005050000007070700000007
cccccccc9cc778777777cccc1117d111111010111194911222222222077770819000000000000009700777070000033305555555000500000000707000000000
cccccccccc7878777777cccc1117d11211111112111111222222222207077081900000070000000970755577750000375ddddddd005050000000070000000007
ccccccccc778777877777ccc1167d5111101111111111222222222220000008190000000000000097750005707500075d1111111050005000000000000000000
ccccccccc778777877777ccc16777d52111111121111122222222222888888819000000700000009777777770077775311111111500000500000000000000007
00044444444444444444444444444000000000000000000088888888ffffffff0000000021111111111111113333333333333333333333333333333300000000
0044eee444444404404444444eee4400000000000000000088888888ffffffff000000001111111211111112333555c3333555e333355583333555b300000000
004eeee444000004400000444eeee400000000000000000088888888ffffffff00000000121111111111111133355cc333355ee33335588333355bb300000000
004eeee444000004400000444eeee400000000000000000088888888ffffffff0000000011111111111211123335ccc33335eee3333588833335bbb300000000
0044eee4444aa444444aa4444eee4400000000000000000088888888ffffffff000000001121111111212111333cccc3333eeee333388883333bbbb300000000
000444e4444aa444444aa4444e444000000000000000000088888888ffffffff0000000011111111111211123333333333333333333333333333333300000000
00000444444884444448844444400000000000000000000088888888ffffffff0000000011112111111111113333333333333333333333333333333300000000
00000044444884444448844444000000000000000000000088888888ffffffff00000000111111211111111233333aa333333aa333333aa333333aa300000000
0000000444422444444224440000000000000000000000000000777777777777777700001111111111111111333aaaa3333aaaa3333aaaa3333aaaa300000000
0000000444444444444444444000000000000000000000000077777777777777777777001211111211111112333335c3333335e333333583333335b300000000
000000044444444444444444400000000000000000000000077777777777777777707770211111111111111133333aa333333aa333333aa333333aa300000000
00000044444499999999444440000000000000000000000007777777777777777777077011121112111111123333333333333333333333333333333300000000
00000044444999999999944444000000000000000000000077077777777777777770707711211111111211113333333333333333333333333333333300000000
00000044449990009000994444000000000044444444000077777777777777777777777711111212111111123333333333333333333333333333333300000000
00000044499900022200099444000000044444444444444077777777777777777777777711112111121112113333333333333333333333333333333300000000
00000049992222888882222994000000444444444444444477777777777777777777777711111112111111123333333333333333333333333333333300000000
00000099e88888888888888e99000000effffffffffffffe77777777000000007777777700000000000000000000000000000000000000000000000000000000
00000999e88888888888888e99000000effffffffffffffe77777777000000007777777700000000000000000000000000000000000000000000000000000000
00009999e88888888888888e99900000effffffffffffffe77777777000000007777777700000000000000000000000000000000000000000000000000000000
00009999e88888888888888e99900000effffffffffffffe77077777000000007777707700000000000000000000000000000000000000000000000000000000
00009999e88888888888888e99900000effffffffffffffe07777777000000007777077000000000000000000000000000000000000000000000000000000000
00009999e88888888888888e99900000effffffffffffffe07770777000000007770777000000000000000000000000000000000000000000000000000000000
00009999e88888888888888e99900000effffffffffffffe00777777000000007777770000000000000000000000000000000000000000000000000000000000
00000999e88888888888888e99900000effffffffffffffe00007777000000007777000000000000000000000000000000000000000000000000000000000000
00000099e88888888888888e99000000effffffffffffffe22222222000000002222222200000000000000000000000000000000000000000000000000000000
00000009e88888888888888e90000000effffffffffffffe72222270000000007222227000000000000000000000000000000000000000000000000000000000
00000000e88888888888888e00000000effffffffffffffe07222700000000000722270000000000000000000000000000000000000000000000000000000000
000000002e888888888888e2000000001effffffffffffe200727000000000000072700000000000000000000000000000000000000000000000000000000000
000000002e888888888888e1000000001effffffffffffe1000a0a0a0a0a0a0a0a0a000000000000000000000000000000000000000000000000000000000000
0000000022e8888888888e220000000011effffffffffe1200727000000000000072700000000000000000000000000000000000000000000000000000000000
00000000222e88888888e22100000000111effffffffe11107222700000000000722270000000000000000000000000000000000000000000000000000000000
000000002222eeeeeeee2222000000001111eeeeeeee111272222270000000007222227000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e34340e34340e0d0000000000000000000000380000003700000000000000000000000000000000000000000000000000000000000000000000380000000037000000370000003700000000d4d50037000000370f2b2b2b2b2b2b2b2b2b2b2b2b3fe2bdbdbdbdbdbdbdbdbdbdbdbde400000000000000000000000000000000
0e34340e34340e0d00380000000037003700000000000000000037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000370037c0c1c2c300000000002939393939393939141439393928e2bdbdbdbdbdbdbdbdbdbdbdbde400000000000000000000000000000000
0e0e0e0e0e0e0e0d00000000000037000000000000373700000000000000000000000000000000000000000000000000000000000000000000000000000038003700000000370000000000d0d1d2d300003700002939393939393939141439393928e2bdbdbdbdbdbdbdbdbdbdbdbde400000000000000000000000000000000
0c0e0b0c0e0e0e0d00003700000000370000003700000000383700000000000000001212000000000000000000000000121200000000000000000000bcadac0000000000000000bcadac00e0e1e2e300003800372939393939393939141439393928e2bdbdbdbdbdbdbdbdbdbdbdbde400000000000000000000000000000000
0c0e0b0c0e0e0e0300000000004600000000000000000000000000370000000000000000000000000000000000000000000000000000000000000000230024000000000000000023002400f0e1e2f300370000002939393939393939141439393928e2bdbdbdbdbdbdbdbdbdbdbdbde400000000000000000000000000000000
0c0e0b0c0e0e0e040000000000560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000023002400000000000000002300240000e1e20000000000002939393939393939141439393928e2bdbdbdbdbdbdbdbdbdbdbdbde400000000000000000000000000000000
31313131313131312626262626262626262626262626262626262626000000000000000000000000000000000000000000000000000000001d08080808080808080808080808080808080808e1e20808080808083d2a2a2a2a2a2a2a2a2a2a2a2a3ae2bdbdbdbdbdbdbdbdbdbdbdbde400000000000000000000000000000000
00000000000000370000000000060605050505050505050505050506060505050505050505050505050606040404040404040404040404060603050503030505050305050306060404040404f1f20404040404060000000000000000000000000000d7d7e800380037000000e6d7d7e800000000000000000000000000000000
3800000000000000000000003706060404040909090909090404040606030304090909090404030303060604040409090909090904040406060404040909090909090404040606040404040405050404040404060000000000000000000000000000000000000000000037000000000000000000000000000000000000000000
00000000000000000000000000060604031a1e1ea0a11e1e0a0304060604041a028081020a04040404060604031a3939a5a639390a0304060604041a1111848511110a04040606040304040304040304040304060000000000000000000000000000003700000000d6d7d7d80037000000000000000000000000000000000000
00000000000000000000000000070703041a1e1eb0b1b21e0a0403070703031a029091020a04030303070703041a3939b5b639390a0403070703041a1111949511110a04030707030404030404040403040403060000000000001212000000000000370000000037e6d7d7d7d7d8000000000000000012120000000000000000
003700000000380000000037000004040404191919191919040404040404040419191919040404000404040404041919191919190404040404040404191919191919040404040404000404040404040404040406000000000000000000000000000000d6d7d800000000e6d7d7e8000000000000000000000000000000000000
0000000000000000000000000000040404040404040404040404040404040404041616160404040004040404040404040404040404040404040404040404040404040404040404040004040404040404040404060000000000000000000000000000d6d7d7d7d7d8000000e6e800370000000000000000000000000000000000
1818181818181818181818181818080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080000000000000000000000000000e6d7d7d7d7e8003700000000380000000000000000000000000000000000
00000000000000000000000000000614141414141414141414141406061414141414141414141414140606141414142222222214141414060614141414141414141414a4140606141414c914141414c9141414060614ca141414e4e5141414ca1406061414141414141414141414140600000000000000000000000000000000
0000000000000000000000000000061414d9141414d9141414141406061414ca222222222222ca1414060614ca1423028081022414ca14060614141414222222221414b414060614141414c914141414c9141406061414ca1414e4e51414ca1414060614da141414da141414da14140600000000000000000000000000000000
00000000000000000000000000000614d914d914d914d914d914140606141423121282831212241414060614ca1423029091022414ca1406061414142363636363241414140606c914141414c914141414c91406061414ca1414e4e51414ca14140606141414da141414da14141414062c2a2a2a2a2a2a2a2a2a2a2a2a2a2a2f
0000000000001212000000000000061414d914d914d914d914d914070714142312129293121224141407071414ca143232323214ca14140707141414236363636324141414070714c914141414c914141414c90707141414ca14e4e514ca141414070714141414dadada14141414140628000000000000000000000000000029
000000000000000000000000000006141414d9141414d9141414d914141400143232323232321400141414141414141414141414141414141414a31414323232321414141414141414c914141414c91414141414141414141414e4e5141414141414141414141414141414141414140628000000000000000000000000000029
00000000000000000000000000000614141414141414141414141414141400141414141414141400141414141414141414141414141414141414b3141414141414141414141414141414c914141414c914141414141414141414f4f5141414141414141414141414141414141414140628000000000000000000000000000029
0000000000000000000000000000080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080828000000000000000000000000000029
00000000000000000000000000000000000000000000000000000000aa131313a8a8a8a8a8a8131313aaaa131313137c00137c13131313aaaa131313137c13137c13131313aa13631313721313131363131372131313130037000000000000000037000000000000000000000000000028000000000000000000000000000029
00000000000000000000000000000000000000000000000000000000aa1313b9000000000000b81313aaaa136372137c00137c13637213aaaa131364137a13137a13641313aa13136565131366661313656513131313131300370038000000000000000000380000003800000000000028000000000000000000000000000029
00000000000000000000000000000000000000000000000000000000aa1313b90000008c0000b81313aaaa13aeaf137a00137a13aeaf13aaaa131365137c66667c13651313aa64130013136665656613001313641313131313133700000000370000370000000000000000003700000028000000000000000000000000000029
00000000000012120000000000000000000000001212000000000000aa13a8b90000009c0000b81313baba13bebf137c00137c13bebf13baba131313137b13137b13131313aa13006262131313131300626213131313131313a8000000370000000000003700000000000000000000003c3b3b3e2b2b2b2b2b2b2b2b363b3b1f
00000000000000000000000000000000000000000000000000000000aab900b8a9a9a9a9a9a91313130013136565137c00137c136565131313131313137c13137c13131313aa641313131313131313131313136413131313b900b83700003700003700000000000037000000000000462800003d2a2a2a2a2a2a2a2a3a000029
00000000000000000000000000000000000000000000000000000000aab900b8131313131313131313001313131300f6f7f7f8131313131313131313137c13137c13131313aa131313131313131313131313131313131313b900b800380000000000003700000000000000000000005628000000000000000000000000000029
00000000000000000000000000000000000000000000000000000000baababababababababababababababababababababababababababababababababababababababababababababababababababababababababababababababbb18181818181818181818181818181818181818182d3f0000000000000000000000000f2e
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000039280000000000000000000000002939
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000039280000000000000000000000002939
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000392d2b2b2b2b2b2b2b2b2b2b2b2b2e39
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000039393939393939393939393939393939
__sfx__
013700002000525005290052000525005290052000525005290052000525005290052000525005290052000525005290052000525005290052000525005290052200525005290052200525005290052200526005
013c00001c5401c5401c5401c5401c5401c5401c5401c5451e5401e5401e5401e5401e5401e5401e5401e5401c5401c5401c5401c5401c5401c5401c5401c5451e5401e5401e5401e5401e5401e5401e5401e545
013c00001a7401a7401a7401a7401a7401a7401a7401a740210402104021040210402104021040210402104521740217402174021740217402174021740217401a0401a0401a0401a0401a0401a0401a0401a040
013c00001e7401e7401e7401e7401e7401e7401e7401e7401c0401c0401c0401c0401c0401c0401c0401c0401c7401c7401c7401c7401c7401c7401c7401c7401e0401e0401e0401e0401e0401e0401e0401e040
013c00002104021040210402104021040210402104021045197401974019740197401974019740197401974519040190401904019040190401904019040190452174021740217402174021740217402174021740
013c00001c5401c5401c5401c5401c5401c5401c5401c5451e7401e7401e7401e7401e7401e7401e7401e7401c5401c5401c5401c5401c5401c5401c5401c5451e7401e7401e7401e7401e7401e7401e7401e745
013c00001a7401a7401a7401a7401a7401a7401a7401a740215402154021540215402154021540215402154521040210402104021040210402104021040210401a0401a0401a0401a0401a0401a0401a0401a040
013c00001e7401e7401e7401e7401e7401e7401e7401e7401c0401c0401c0401c0401c0401c0401c0401c0401c7401c7401c7401c7401c7401c7401c7401c7401e0401e0401e0401e0401e0401e0401e0401e040
013c00002104021040210402104021040210402104021045195401954019540195401954019540195401954519540195401954019540195401954019540195452174021740217402174021740217402174021740
013c00002170523705237052a7002a705287052a705267052570523705257052670528700287052a7052570523705217051e7051e70523700237052570523705217052070521705207051e7001e7001e7052a705
013c000017705177051e7001e7051c7051e7051a7051970517705197051a7051c7001c7051c7051e7051970517705157051270512705177051770519705177051570514705157051470512705127051270514705
013c00001570517705177051e7001e7051c7051e7051a7051970517705197051a7051c7001c7051e705197051770515705127051270517700177051970517705157051470515705147051270012700127052a705
011e00000005500055000550005500055000550005500055000550505505055050550505505055050550505505055050550505505055050550505505055050550505505055050550a0550a0550a0550a0550a055
011e00000000004055040550400504055040550400504055040550400500055000550000000055000550000500055000550000500055000550000500055000550000000055000550000505055050550000505055
011e00000c00007055070550700507055070550700507055070550700507055070550000009055090550900509055090550900509055090550900509055090550000009055090550900502055020550900502055
011e00000c7600c7600c7651076010760107651376013760137651576015760157651376013760137651176011760117651076511765137601076010760107601075010750107551375013750137501375013750
011e00000a0550a0550a0550a0550a0550a0550a0550a0550a0550a0550a0550a0550a0550505505055050550505505055050550505505055050550505505055050550000000000000000000000000000000c000
011e00000505500000050550505500000050550505500000050550505500000050550505500000000550005500000000550005500000000550005500000000550005500000000000000000000000000000000000
011e00000205500000020550205500000020550205500000020550205500000020550205500000070550705500000070550705500000070550705500000070550705500000000000000000000000000000000000
011e0000137551575015750157551375013750137551175011750117551075511755137550e7500e7500e7500e7500e7500e7551375013750137501375013750137550c7000c7000c0000c000000000000000000
010f00000005002050040500505007050090500b0500c0500e0501005011050130501505017050180501a0501c0501d0501f0502105023050240502605028050290502b0502d0502f05030050320503405035050
013c00001074010740107401074010740107401074010745127401274012740127401274012740127401274010740107401074010740107401074010740107451274012740127401274012740127401274012745
013c00000e7400e7400e7400e7400e7400e7400e7400e740150401504015040150401504015040150401504515740157401574015740157401574015740157400e0400e0400e0400e0400e0400e0400e0400e040
013c00001274012740127401274012740127401274012740100401004010040100401004010040100401004010740107401074010740107401074010740107401204012040120401204012040120401204012040
013c000015040150401504015040150401504015040150450d7400d7400d7400d7400d7400d7400d7400d7450d0400d0400d0400d0400d0400d0400d0400d0451574015740157401574015740157401574015740
013c00001054010540105401054010540105401054010545127401274012740127401274012740127401274010540105401054010540105401054010540105451274012740127401274012740127401274012745
013c00000e7400e7400e7400e7400e7400e7400e7400e740155401554015540155401554015540155401554515040150401504015040150401504015040150400e0400e0400e0400e0400e0400e0400e0400e040
013c00001274012740127401274012740127401274012740100401004010040100401004010040100401004010740107401074010740107401074010740107401204012040120401204012040120401204012040
013c000015040150401504015040150401504015040150450d5400d5400d5400d5400d5400d5400d5400d5450d5400d5400d5400d5400d5400d5400d5400d5451574015740157401574015740157401574015740
010f00000000000000000000000000000000000000000000000000000000000000000000000000000500005500050000550005000055000500005500050000550005000055000500005500050000550005000055
010f00000000000000000000000000000000000000000000000000000000000000000000000000000000000004050040550405004055040050400504050040550405004055040050400504050040550405004055
010f00000000000000000000000000000000000000000000000000000000000000000000000000000000000007050070550705007055070000700507050070550705007055070050700507050070550705007055
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
04 41 42 43 44
00 41 42 43 44
04 41 42 43 44
00 41 42 43 44
00 1d 1e 1f 44
00 0c 0d 0e 0f
04 10 11 12 13
01 15 16 17 18
02 19 1a 1b 1c
01 01 02 03 04
02 05 06 07 08
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
