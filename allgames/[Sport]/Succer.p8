pico-8 cartridge // http://www.pico-8.com
version 5
__lua__
-- succer
-- by rylauchelmi

menu_offset=128
menu_inc=1
demo=true
timer=10
blink=false
mode=1
full_time=2700
half_time=full_time/2

max_val = 32767
cos22_5 = 0.9239
sin22_5 = 0.3827

fh = 384
fw = 256
fh2 = fh/2
fw2 = fw/2
penaltyw2 = 64
fh2_penaltyh = fh2-60
goalw=60
goalh=20
goall=10
goalx2 =  goalw/2
goalx1 = -goalx2
border = 20

teamcolors={1,5}
teamcolors[0]=0
shirtcolors={{8,2}, {9,8}, {10,9}, {11,3}, {12,1}, {13,5}, {6,13}, {7,6}, {15,14}}
shirtcolors[0]={1,2}
skincolors={{4,5,0},{15,14,4},{15,14,4},{15,14,9}}

throwin=
{
 pos={x=0,y=0},
 ballpos={x=0,y=0},
 timer=0,
 balld={x=0,y=0}
}

max_kick = 20
dribbledist=4

camtarget = {x=fw2, y=0}

startpos =
{
	{x=0,y=0.2},
	{x=0.4,y=0.2},
	{x=-0.4,y=0.2},
	{x=0.35,y=0.5},
	{x=-0.35,y=0.5},
	{x=0,y=0.90},
}

attackpos =
{
 {x=0,y=-0.2},
 {x=0.4,y=-0.1},
 {x=-0.4,y=-0.25},
 {x=0.3,y=0.1},
 {x=-0.3,y=0.2},
 {x=0,y=0.90},
}


vel_inc = 0.2
min_vel = 0.1
ball_dist_thres = 64

menu = { timer=10}


function print_outlined(t,x,y,c,oc)
	for i=x-1,x+1 do
	 for j=y-1,y+1 do
	  print(t,i,j,oc)
	 end
	end
 print(t,x,y,c)
end


function dist_manh(a,b)
	return abs(b.x-a.x)+abs(b.y-a.y)
end


function draw_marker(f)
 local sp=29
 if (can_kick(f)) sp=30
 if (f.hasball) sp=31
 spr(sp, f.x-4, f.y-6)
end


function jersey_color(f)
 local shirt=shirtcolors[teamcolors[f.teamcolors]]
	pal(8, shirt[1])
	pal(2, shirt[2])
 pal(4,  skincolors[f.skin][3])
 pal(14, skincolors[f.skin][2])
 pal(15, skincolors[f.skin][1])
end


function spr_from_dir(f)
 f.lastflip = true
 local fdirx=f.dir.x
 local fdiry=f.dir.y
 if fdirx<-cos22_5 then -- full left
  f.lastspr=2
 else
  if fdirx<-sin22_5 then -- diag left...
   if fdiry<0 then -- ...and up
    f.lastspr=1
   else -- ...and down
    f.lastspr=3
   end
  else
   f.lastflip = false
   if fdirx<sin22_5 then -- full...
    if fdiry<0 then -- ...up
     f.lastspr=0
    else -- ...down
     f.lastspr=4
    end
   else
    if fdirx<cos22_5 then -- diag right...
     if fdiry<0 then -- ...and up
      f.lastspr=1
     else -- ...and down
      f.lastspr=3
     end
    else -- full right
     f.lastspr=2
    end
   end
  end
 end
end


function draw_footballer(f)
 local animfactor = 1
 local animoffset = 20
 local anim_end = 1

 jersey_color(f)

 if (f.vel>min_vel) then
 	animfactor = 4
 	animoffset = 0
  anim_end = 4
  spr_from_dir(f)
 end

 f.animtimer += f.vel * 0.25
 while (flr(f.animtimer)>=anim_end) do
  f.animtimer -= anim_end
 end

 local pos = sprite_pos(f)
 spr(animoffset+f.lastspr*animfactor+f.animtimer,pos.x,pos.y,1,1,f.lastflip)
end


function sprite_pos(f)
	return { x = f.x-f.w, y = f.y-f.h }
end


function create_footballer(p,i)
 return
	{
	 x = 0,
		y = 0,
		w = 4,
		h = 8,
		d={x=0,y=0},
		vel = 0,
		dir = {x=0, y=1},
--  prevdir={x=0, y=1},
		lastspr = 4,
	 hasball = false,
	 animtimer = 0,
	 timer = 0,
		damp = 0.9,
		lastflip = false,
		justshot = 0,
	 ball_dist = max_val,
		startposidx = i,
		side = p*2-1,
	 keeper = false,
  teamcolors = p+1,
  skin = flr(rnd(#skincolors))+1,

	 draw = function(fo)
	  fo.state.draw(fo) 
  end,
 
	 update = function(fo)
		 fo.state.update(fo) 
	 end,

		drawshadow = function(t)
			spr(46, t.x-2, t.y-2)
		end,
		
		state = fstate_ok,
		
		set_state=function(fo,st)
		 fo.state = st
		 if (st.start!=nil) st.start(fo)
	 end
 }
end


men = {}


ball=
{
 x=0,
 y=0,
 z=0,
 w=2,
 h=4,
 d={x=0,y=0,z=0},
 damp=0.975,
-- damp=0.95,
 dampair=0.985,
 draw = function(b)
  spr(44, b.x-b.w, b.y-b.h-b.z)
 end,
 drawshadow = function(b)
  spr(45, b.x-b.w+1, b.y-b.h+1)
 end
}

balllasttouchedside=0
dribble={x=0,y=0}
dribblen=0


function touch_ball(m,dist)
 return (m.x-dist<ball.x and ball.x<m.x+dist and m.y-dist<ball.y and ball.y<m.y+dist and ball.z<8)
end


function dribble_ball(m)
	if (m.justshot>0) then
		m.justshot-=1
  m.hasball=false
		return
	end
-- m.hasball = not m.keeper and touch_ball(m, dribbledist)
 m.hasball = touch_ball(m, dribbledist)
 if m.hasball then
  plus_in_place(dribble,muls(m.d,1.1))
 	dribblen += 1
  balllasttouchedside=m.side
  man_with_ball=m
 end
end


function checktimer(a)
	a.timer-=1
	return a.timer<0
end


function dot(a,b)
	return a.x*b.x+a.y*b.y
end


function minus(a,b)
	return { x=a.x-b.x, y=a.y-b.y }
end


function plus(a,b)
	return { x=a.x+b.x, y=a.y+b.y }
end


function plus_in_place(a,b)
	a.x+=b.x
	a.y+=b.y
end


function mulv(a,b)
 return { x=a.x*b.x, y=a.y*b.y }
end


function muls(a,b)
	return { x=a.x*b, y=a.y*b }
end


function muls_in_place(a,b)
	a.x*=b
	a.y*=b
end


function copy(a)
	return { x=a.x, y=a.y }
end


function unit(a)
	-- if abs(a.x) > 32 or abs(a.y) > 32 then
	-- 	a.x/=32
	-- 	a.y/=32
 -- end
 local len = sqrt(dot(a,a))
	return { x=a.x/len, y=a.y/len }
end


function clamp(x,lo,hi)
	return min(max(x,lo),hi)
end


function clampsym(x,hi)
	return min(max(x,-hi),hi)
end


function segment_intersect(a1,a2,b1,b2)
	local ax=a2.x-a1.x
	local ay=a2.y-a1.y
	local bx=b2.x-b1.x
	local by=b2.y-b1.y
	local a1x=a1.x-b1.x
 local den = ax*by-ay*bx
 if (den == 0) return { r=false }
 local a1y=a1.y-b1.y
	local r = (a1y*bx-a1x*by) / den
	local s = (a1y*ax-a1x*ay) / den
	-- if 0<=r<=1 & 0<=s<=1, intersection exists
	if (r<0 or 1<r or s<0 or 1<s) return { r=false }
 return { r=true, x=a1.x+r*ax, y=a1.y+r*ay }
end



function check_net(ball, prevball, goal1, goal2)
 local res = segment_intersect(prevball, ball, goal1, goal2)
 if res.r then
  if goal1.x==goal2.x then
   ball.d.x = -ball.d.x
  else
   ball.d.y = -ball.d.y
  end
  muls_in_place(ball.d,0.25)
  ball.x=res.x
  ball.y=res.y
 end
end


ballsfxtime=0
function ballsfx()
 if (ballsfxtime<=0) sfx(5) ballsfxtime=7
end


function check_post(p, prevball)
 local d = distance(ball, p)
 if d<ball.w then
 	local delta = minus(p,ball)
 	local ballspeed = distance(ball, prevball)
 	plus_in_place(ball,muls(delta,-1/d*ball.w))
 	plus_in_place(ball.d,muls(delta,-1/d*ballspeed))
  ballsfx()
 end
end


function playing()
 return game_state==game_state_playing
end


function is_throwin()
 return game_state==game_state_ballin
end


function init_throwin(t,p,v,m)
 throwintype=t
 throwin.kickmax=m
 throwinside=-balllasttouchedside
 throwin.ballpos = p
 if (ball.x<0) throwin.ballpos.x*=-1
 if (ball.y<0) throwin.ballpos.y*=-1
 throwin.pos = mulv(throwin.ballpos,v)
 local idx=side_to_idx(throwinside)
 if t==fstate_goalkick then
  throwin_f=men[#men+idx-2] -- keeper
  throwin_f:set_state(keeper_state_run)
 else
  throwin_f=players[idx].man
 end
 throwin.dist=distance(throwin.pos,throwin_f)
 camlastpos=copy(camtarget)
 set_game_state(game_state_toballout)
 sfx(0)
end


function update_cam()
 if (playing()) camtarget = copy(ball)
 local bx=fw2+border-64
 local by=fh2+border-64
 camtarget.x = flr(clampsym(camtarget.x, bx))
 camtarget.y = flr(clampsym(camtarget.y, by))
end


function update_ball()
	local prevball = { x = ball.x, y = ball.y }
	plus_in_place(ball,ball.d)
 local gravity = 0.1
 if ball.z > 0 then
  ball.d.z -= gravity
 else
  ball.z = 0
  if abs(ball.d.z) < 2*gravity then
	  ball.d.z = 0
	 else
	  ball.d.z = abs(ball.d.z) * 0.5
   ballsfx()
	 end
 end
 ball.z += ball.d.z

 local post1 = { x=goalx1, y=fh2 }
 local post1_ = { x=goalx1, y=fh2+goalh/2 }
 local post2 = { x=goalx2, y=fh2 }
 local post2_ = { x=goalx2, y=fh2+goalh/2 }
 local fieldw2 = fw2+border
 local fieldh2 = fh2+border

 if ball.y<0 then
  post1.y = -post1.y
  post1_.y = -post1_.y
  post2.y = -post2.y
  post2_.y = -post2_.y
 end

	-- goal col
	if ball.z<=goall then 
  -- nets
	 check_net(ball, prevball, post1, post1_)
	 check_net(ball, prevball, post2, post2_)
	 check_net(ball, prevball, post1_, post2_)

	 -- posts
 	check_post(post1, prevball)
 	check_post(post2, prevball)
  -- todo check horiz post
 end
 
 -- touch lines
 if playing() and abs(ball.x)>fw2 then
  init_throwin(fstate_throwin,{x=fw2,y=clampsym(abs(ball.y),fh2)},{x=1,y=1}, 1)
 end

  -- scoring_team
  -- todo check ball really entering the goal...
 if playing() and scoring_team==0 and ball.z<goall and post1.x<ball.x and ball.x<post2.x and fh2+goalh>abs(ball.y) and abs(ball.y)>fh2 then
  scoring_team = side_to_idx(ball.y>0 and 1 or -1)
  kickoff_team = scoring_team
  score[scoring_team] += 1
  camlastpos = copy(ball)
  set_game_state(game_state_goalmarked)
  sfx(0)
  sfx(15)
 end

  -- corner/goal kick
 if playing() and abs(ball.y)>fh2 then
  throwinside=-balllasttouchedside
  if throwinside*ball.y<0 then
   init_throwin(fstate_corner,{x=fw2, y=fh2},{x=1.1,y=1.03}, 5)
  else  
   init_throwin(fstate_goalkick,{x=rnd(penaltyw2), y=fh2_penaltyh}, {x=1,y=1.15}, 25)
--   init_throwin(fstate_goalkick,{x=penaltyw2, y=fh2_penaltyh}, {x=1,y=1.15}, 25)
  end
 end

 -- field borders
 local bd=ball.d
 if (ball.x<-fieldw2) bd.x=abs(bd.x)*0.5 ball.x=-fieldw2
 if (ball.x>fieldw2) bd.x=-abs(bd.x)*0.5 ball.x=fieldw2
 if (ball.y<-fieldh2) bd.y=abs(bd.y)*0.5 ball.y=-fieldh2
 if (ball.y>fieldh2) bd.y=-abs(bd.y)*0.5 ball.y=fieldh2

 -- damping
 if ball.z<0.1 then
  damp(ball)
 else
		muls_in_place(ball.d,ball.dampair)
	end 	
 bd.z *= ball.damp
end


function bubble_sort(t)
	local len = #t
	local active = true
	local tmp = nil
	while active do
		active = false
		for i=1,len-1 do
			if t[i+1].y<t[i].y then
				tmp = t[i]
				t[i] = t[i+1]
				t[i+1] = tmp
				active = true
			end
		end
	end
end


players = {}


function create_player(i)
	local player =
	{
		man = nil,
		num = i,
		but = 0,
		ai = false
 }
	add(players,player)
end


function distance(a, b)
-- return sqrt((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y))
	-- local d={x = a.x-b.x, y = a.y-b.y}
	-- if (d.x*d.x < 0 or d.y*d.y < 0 or d.x*d.x+d.y*d.y < 0) return	max_val
 -- return sqrt(d.x*d.x + d.y*d.y)
 local dx = a.x-b.x
 local dy = a.y-b.y
 dx*=dx
 dy*=dy
 local sum=dx+dy
 if (dx<0 or dy<0 or sum<0) return max_val
 return sqrt(sum)
end


function kick(p)
 --pass
 local passed = false
 if (p.but<5) passed = pass(p.man)

 if not passed then
  local kickfactor= 1.0+0.1*p.but
  plus_in_place(ball.d,muls(p.man.dir,kickfactor))
  ball.d.z+=kickfactor*0.5
  balllasttouchedside=p.man.side
 end

 p.man.justshot = 5
 ballsfx()
end


function tackle(p)
 p.man:set_state(fstate_tackle)
end


function can_kick(f)
	local kickdist=8
	return touch_ball(f, kickdist)
end


function button_released(p)
 local f=p.man
	if can_kick(f) then
		kick(p)
  balllasttouchedside=f.side
 else
 	if (f.justshot==0) tackle(p)
	end
	p.but = 0
end


function player_input(p)
	if p.ai or demo then
		if (p.man.state.ai!=nil) p.man.state.ai(p)
 else
 	if (p.man.state.input!=nil) p.man.state.input(p)
 end
end


function damp(m)
	muls_in_place(m.d,m.damp)
end


function clampvec_getlen(v,n)
 local l = sqrt(dot(v,v))
 if l>n then
 	muls_in_place(v,n/l)
 	l=n
 end
 return l
end


function man_update(f)
	-- update state : draw, input or ai
	if (f.state.update != nil) f.state.update(f)

 -- update position & check borders
 local newposx = f.x+f.d.x
 local newposy = f.y+f.d.y
 if abs(newposx)>fw2+border then
  newposx = f.x 
  f.d.x = 0
 end
 if abs(newposy)>fh2+border then
  newposy = f.y
  f.d.y = 0
 end
 f.x = newposx
 f.y = newposy

 if (not playing()) f.hasball=false

 -- velocity clamp
 if (f.state!=fstate_tackle) f.vel = clampvec_getlen(f.d, f.hasball and 1.4 or 1.6)
-- if (f.vel>min_vel) f.dir=unit(f.d)
 if (f.vel>min_vel) f.dir=muls(f.d, 1/f.vel)
end


function nothing(t)
end


goal_up = 
{
 y = -fh2,
 draw = function(this)
  local clipstartx=goalx1-camtarget.x+1+64
  local clipstarty=-camtarget.y+64-fh2
  local clipendx=goalx2-goalx1
  local clipendy=goalh/2+1
  spr(60,goalx2,-fh2-17)
  clip(clipstartx, clipstarty-10, clipendx+8, clipendy)
  for x=goalx1-1,goalx2+8,8 do
   for y=-11,7,8 do
     spr(61,x,y-fh2)
   end
  end
  clip(clipstartx, clipstarty-goalh, clipendx-1, clipendy)
  for x=goalx1-1,goalx2+8,8 do
   for y=-goalh+1,8,8 do
     spr(62,x,y-fh2)
   end
  end
  clip()
  local a = -goall-fh2
  line(goalx1, a, goalx1, -fh2)
  line(goalx1, a, goalx2, a)
  line(goalx2, a, goalx2, -fh2)
 end,
 drawshadow = nothing
}


goal_down = 
{
 y = fh2+goalh,
 draw = function(this)
  spr(60,goalx2,fh2, 1, 1, false, true)
  color(7)
  rect(goalx1, -goall+fh2, goalx2, fh2)
  clip(goalx1-camtarget.x+64+1, -goall-camtarget.y+64+fh2+1, goalx2-goalx1-1, goalh-1)
  for x=goalx1,goalx2+7,8 do
   for y=-goall,goall,8 do
     spr(62,x,y+fh2)
   end
  end
  clip()
 end,
 drawshadow = nothing
}


-- -1 => 1 and 1 => 2
function side_to_idx(s)
-- return flr((s+1)/2+1)
 return ((matchtimer>=half_time and -s or s)+1)/2+1
end


function idx_to_side(i)
 return (matchtimer>=half_time and -1 or 1)*(2*i-3)
end


function distance_men_ball()
	local nearestdist = {max_val,max_val}
	for m in all(men) do
  if (not m.keeper and m.state!=fstate_down and m.state!=fstate_tackle) then
 	 local d = dist_manh(m,ball)
   m.ball_dist = d
   if playing() then
	 	 local p = side_to_idx(m.side)
	 	 if d<nearestdist[p] then
	 	 	players[p].man = m
	 	 	nearestdist[p] = d
	 	 end
	 	end
  end
	end
end


function is_pass_ok(f,relpos,dist,dir)
 if (is_throwin()) return true
 for m in all(men) do
  local side = (m.side != f.side)
  if side then
   local relpos2 = minus(m,f)
   local dist2 = max(sqrt(dot(relpos2,relpos2)),1)
   local dir2 = {x=relpos2.x/dist2, y=relpos2.y/dist2 }
   if (dot(dir,dir2)>cos22_5 and dist2/dist<1.1) return false
  end
 end
 return true
end


function pass(f)
	-- find the nearest teammate
 -- in the right direction
 local maxd = 0
 local target = nil

 for m in all(men) do
 	if m.side == f.side and not m.keeper and m!=f then
   local front = 20
   local futm=plus(m,muls(m.d,front))
   local dist = distance(f,futm)
   if dist<96 then
    local relpos = minus(futm,f)
 	 	local dir = muls(relpos, 1/dist)
 	 	local dirw = dot(f.dir, dir)
  	 if dirw>sin22_5 then 
 	   local distw = clamp(-dist/32+2,0,1)
 	   local w=dirw*distw
 	   -- todo: add obstruction consideration
 		 	if (w>maxd and is_pass_ok(f,relpos,dist,dir)) maxd=w target=dir
    end
   end
	 end
	end

 if target!=nil then 
  -- kick the ball in his direction
 	local pass_strength = 3.0
  ball.d=muls(target,pass_strength)
 	ball.d.z = 1
 	return true
 end
 return false
end


function start_match(dem)
 score = {0,0}
 demo=dem
 matchtimer=0
 camlastpos=copy(camtarget)
 scoring_team=0
 starting_team=flr(rnd(2))+1
 kickoff_team=starting_team
 set_game_state(game_state_tokickoff)
end


function print_mode(m,t)
 if (m==mode) print_outlined(t, 32-menu_offset, 75, 6, 5)
end


function change_side(f)
 f.side=-f.side
end


function set_state_ok(f)
 if f.keeper then
  f:set_state(keeper_state_ok)
 else
  f:set_state(fstate_ok)
 end
end


keeper_state_dive = 
{
 draw = function(k)
		jersey_color(k)
  local pos = sprite_pos(k)
  spr(k.lastspr,pos.x,pos.y,1,1,k.d.x<0)
 end,

	start=function(k)
	 k.timer=30
 end,

 update = function(k)
  k.lastspr=k.timer>25 and 55 or 56
  if checktimer(k) then
   k.lastspr=0
  	k:set_state(keeper_state_ok)
  	return
  end
  if touch_ball(k, 5) and playing() then
   ball.d.y = 3.0 * (-k.y/abs(k.y))
   ball.d.x += k.d.x
   sfx(15)
   balllasttouchedside=k.side
   end
 end
}


function draw_keeper_ok(k)
 local pos = sprite_pos(k)
 local sp = pos.y<0 and 57 or 54
 jersey_color(k)
 spr(sp,pos.x,pos.y)
end


keeper_state_ok = 
{
 draw = draw_keeper_ok,

 update = function(k)
  -- try to stay in front of the ball
 -- dive?
  local future=7
 	local futureball = plus(ball,muls(ball.d,future))
  local res = segment_intersect(ball, futureball, { x=goalx1, y=fh2*k.side }, { x=goalx2, y=fh2*k.side })
  if res.r then -- and abs(ball.dx)>0.15 then
  	local divefactor = 0.99
  	local divemax = 10
   k.d.x = clampsym((res.x-k.x)*divefactor, divemax)
   k:set_state(keeper_state_dive)
   return
  else -- just move
   local wantedx = clampsym(ball.x, goalx2)
   local mx = 1.0 -- max move per frame
   k.x = clamp(wantedx, k.x-mx, k.x+mx)
   if (abs(k.y) < fh2-4) k.y += k.side
  end  

  if (touch_ball(k, 5) and playing()) ball.d.y = -3.0 * k.side balllasttouchedside=k.side
 end
}


function create_keeper(p,i)
	local k = create_footballer(p,i)
	k.state = keeper_state_ok
	k.y = (p - 0.5) * (fh-8)
 k.keeper = true
 k.teamcolors = 0
	return k
end


function go_to(f,x,y,min_dist,steps)
 if abs(f.x-x) < min_dist and abs(f.y-y) < min_dist then
  return true
 end

 local tmp=f.x+f.d.x*steps
 if f.x<x then
  if (tmp<x) f.d.x+=vel_inc
 else
  if (tmp>x) f.d.x-=vel_inc
 end
 tmp=f.y+f.d.y*steps
 if f.y<y then
  if (tmp<y) f.d.y+=vel_inc
 else
  if (tmp>y) f.d.y-=vel_inc
 end
 return false
end


function run_to(f,x,y)
 return go_to(f,x,y,dribbledist-1,0)
end


function look_at(f,b)
 f.dir = unit(minus(b,f))
 spr_from_dir(f)
end


function set_game_state(newstate)
 if newstate.init!=nil then
  newstate:init()
 end
 game_state = newstate
end

game_state_playing =
{
 init = function(this)
  players[1].ai = (mode == 2)
  players[2].ai = (mode > 0)
 end
}

game_state_goalmarked =
{
 timer = 60,

 init = function(this)
  this.timer = 60
 end,

 update = function(this)
   if (checktimer(this)) set_game_state(game_state_tokickoff)
 end
}


game_state_tokickoff =
{
 timer = 60,

 init = function(this)
  this.timer = 60
  for m in all(men) do
   set_state_ok(m)
  end
  -- keepers
  men[#men-1]:set_state(keeper_state_run)
  men[#men]:set_state(keeper_state_run)
 end,

 update = function(this)
  -- scroll to the center of the field
  l = max(this.timer/60, 0)
  camtarget = muls(camlastpos, l)

  local to_exit = matchtimer>full_time

--  if (to_exit) plus_in_place(camtarget, muls({x=fw2,y=0}, 1-l))

  local allok = true
  for m in all(men) do
   local i = m.startposidx 
   --if not m.keeper then
    local dest = to_exit and {x=1,y=0} or startpos[i]
--    if 2*kickoff_team-3 == m.side then
    if idx_to_side(kickoff_team) == m.side and not to_exit then
     if (i==1) dest = {x=0, y=0.01}
     if (i==2 or i==3) dest={ x=dest.x, y=0.02 }
    end
    local ok = run_to(m,dest.x*fw2,dest.y*m.side*fh2)
    ok = ok and (m.vel < min_vel)
    allok = ok and allok
--    if (ok) look_at(m, ball)
   --end
  end

  if (checktimer(this) and allok) then
   if to_exit then
    start_match(true)
   else
    -- keepers
		  set_state_ok(men[#men-1])
		  set_state_ok(men[#men])
    set_game_state(game_state_kickoff)
   end
  end
 end
}

game_state_kickoff =
{
 init = function(this)
  muls_in_place(ball, 0)
  muls_in_place(ball.d, 0)
  scoring_team = 0
  changing_side=false
  for m in all(men) do
   look_at(m, ball)
  end
 end,

 update = function(this)
  --debug("kickoff")
  -- wait for the player to kick off
  -- he can't move just kick in the direction he wants
  set_game_state(game_state_playing)

  -- local p = players[kickoff_team]

  -- local dir = {x=0, y=-p.man.side}
  -- if (btn(0,p.num)) dir.x=-fw
  -- if (btn(1,p.num)) dir.x=fw
  -- local do_kick=btn(4,p.num)--kickoff_team)

  -- if (p.ia or demo) do_kick=true --dir.x=rnd(1)<=0.5 and fw or -fw

 	-- look_at(p.man, dir)
 	-- if (do_kick) then
 	--  kick(p)
  --  sfx(0)
  --  kickoff_team = 0
		-- 	ball_thrown(p.man)
  -- end
 end
}

game_state_toballout =
{
 update = function(this)
  -- todo : tout le monde se met en place
  local l = distance(throwin_f,throwin.pos)/throwin.dist
  camtarget = plus(muls(throwin.ballpos,1-l), muls(camlastpos,l))
  if (go_to(throwin_f,throwin.pos.x,throwin.pos.y,2,10)) set_game_state(game_state_ballin)
 end
}

game_state_ballin =
{
 init=function(this)
  ball.x=throwin.ballpos.x
  ball.y=throwin.ballpos.y
  muls_in_place(ball.d, 0)
  throwin_f:set_state(throwintype)
 end,
}


function _init()
	music(0, 0, 6)
	create_player(0)
	create_player(1)

 local fieldplayercount = 5
	for p=0,1 do
	 for i=1,fieldplayercount do
			local man = create_footballer(p,i)
			man.x = fw2
			man.y = 0
--			if (p == 0) man.y = -man.y
			add(men,man)
	 end
 end

 fieldplayercount+=1
	players[1].man = men[1]
	players[2].man = men[fieldplayercount]

 add(men,create_keeper(0,fieldplayercount))
	add(men,create_keeper(1,fieldplayercount))

 start_match(true)
end


function ball_thrown(f)
 f.lastspr=2
 set_state_ok(f)
 balllasttouchedside=f.side
 f.justshot = 10
 set_game_state(game_state_playing)
end


function throw_in(dy)
 local dx=-1
 if (throwin.ballpos.x<0) dx=-dx
 if (dy!=0) dx/=2
 local power=3
 local d=unit({x=dx,y=dy})
 ball.d=muls(d,power)
 ball.d.z=1.5
end


function fs_throwin_ai(p)
	local f=p.man
	local dy=0
	if ball.y*f.side>0 then
	 dy=-2
	else	
		if (ball.y*f.side>-fh2/2) dy=-1
	end
	dy*=f.side

 if checktimer(throwin) then
  throw_in(dy)
  ball_thrown(f)
  return
 end
 f.lastspr = 2+dy
 if (pass(f)) ball_thrown(f)
end


function fs_throwin_input(p)
 local dy=0
 if (btn(2,p.num)) dy-=2
 if (btn(3,p.num)) dy+=2
 if (btn(0,p.num) or btn(1,p.num)) dy/=2
 p.man.lastspr = 2+dy
 if btn(4,p.num) then
  --if (not pass(p.man)) throw_in(dy)
  throw_in(dy)
  ball_thrown(p.man)
 end
end


function fs_throwin_draw(f)
 jersey_color(f)
 local pos = sprite_pos(f)
 f.lastflip = f.x>0
 spr(48+f.lastspr,pos.x,pos.y,1,1,f.lastflip)
 ball.x=f.x
 ball.y=f.y
 ball.z=7
 ball.d.z=0
end


function throwin_start(this)
 throwin.timer=35
 throwin_f.x=throwin.pos.x
 throwin_f.y=throwin.pos.y
 muls_in_place(throwin_f.d, 0)
end


fstate_throwin =
{
 start=throwin_start,
 ai=fs_throwin_ai,
 input=fs_throwin_input,
 draw=fs_throwin_draw
}


function kicking(p)
 if (run_to(throwin_f,throwin.ballpos.x,throwin.ballpos.y)) then
  ball_thrown(throwin_f)
  ball.d.x = throwin.balld.x
  ball.d.y = throwin.balld.y
  ball.d.z=5
 end
end


fstate_running =
{
 ai=kicking,
 input=kicking,
 draw=draw_footballer
}


function kick_dir()
 throwin.balld = muls({x=throwin.ballpos.x-throwin_f.x, y=throwin.ballpos.y-throwin_f.y},0.25)
 clampvec_getlen(throwin.balld,throwin.kickmax)
 look_at(throwin_f, ball)
end


function fs_corner_ai(p)
	-- todo : move the player
 if checktimer(throwin) then
  kick_dir()
  throwin_f:set_state(fstate_running)
 end
end


function fs_corner_input(p)
 if (btn(0,p.num)) throwin_f.d.x-=vel_inc
 if (btn(1,p.num)) throwin_f.d.x+=vel_inc
 if (btn(2,p.num)) throwin_f.d.y-=vel_inc
 if (btn(3,p.num)) throwin_f.d.y+=vel_inc

 kick_dir()
 if (btn(4,p.num)) throwin_f:set_state(fstate_running)
end


fstate_corner =
{
 start=throwin_start,
 ai=fs_corner_ai,
 input=fs_corner_input,
 draw=draw_footballer
}


fstate_goalkick =
{
 start=throwin_start,
 ai=fs_corner_ai,
 input=fs_corner_input,
 draw=draw_footballer
}


function get_controlled(side)
 return players[side_to_idx(side)].man
end


function findpos2(f,t)
 if (f==throwin_f) return
 local dest = attackpos[f.startposidx]
 local sid=1
 if (is_throwin() and t.x*dest.x<0) sid=-0.5
 local x = sid*dest.x*fw2 + t.x/2 
-- x = clampsym(x, is_throwin() and fw2/2 or fw2)
 x = clampsym(x, fw2)
 local y = f.side*dest.y*fh2+t.y
 y = clampsym(y, fh2*0.8)
 run_to(f,x,y)
end


function findpos(f)
-- if not is_controlled(f) then
 if f!=get_controlled(f.side) then
  -- local futurme = plus(f,muls({x=f.d.x,y=f.d.y},10))
  -- local futurcon = plus(fcon,muls({x=fcon.d.x,y=fcon.d.y},10))
  -- local futurball = plus(ball,muls({x=ball.d.x,y=ball.d.y},10))
  -- local closer=dist_manh(futurme, futurball) < dist_manh(futurcon, futurball)
  -- if(dist and don or closer) then
  if playing() and f.ball_dist<ball_dist_thres and get_controlled(f.side).ball_dist>ball_dist_thres/2 then
   run_to(f,ball.x,ball.y)
  else
  	findpos2(f,ball)
  end
 end
end


keeper_state_run = 
{	
 draw=draw_footballer,
}


fstate_ok =
{
	ai=function(p)
	 local f=p.man
	 if (f==nil) return

	-- if (is_throwin()) findpos2(f,ball)
	 if (is_throwin()) findpos2(f,{x=0,y=0})

	 if playing() then
	-- if running after the ball and it's going to leave the field on the throwin side
	-- and a team mate is in front of the ball... let him handle the situation

			if (f.hasball or run_to(f,ball.x,ball.y)) and ball.z<8 and f.justshot<=0 then
		-- try to shoot
		  local goal = {x=0,y=-f.side*fh2}
	   if dist_manh(goal,f)<75 then
     f.dir = unit(minus(goal,f))
				 p.but = rnd(max_kick/2)+max_kick/3
				 kick(p)
     return
		  end
		-- try to pass
				if not pass(f) then
	    -- try to get near the goal
	    if f.hasball then
      local togoal = minus(goal,f)--unit(minus(goal,f))
      if dot(f.dir,togoal)<sin22_5 then
       local side={x=-f.dir.y,y=f.dir.x}
       local turn=plus(f,muls(side,35))
       run_to(f,turn.x,turn.y)
      else
 	     run_to(f,0,goal.y*0.75)
      end
	    end
		  end
		 end
		end
	end,

	input=function(p)
	 if (p.man==nil or (not playing() and not is_throwin())) return
	 local man = p.man

		if (btn(0,p.num)) man.d.x -= vel_inc
		if (btn(1,p.num)) man.d.x += vel_inc
		if (btn(2,p.num)) man.d.y -= vel_inc
		if (btn(3,p.num)) man.d.y += vel_inc

	 if (playing()) then
	 	if (btn(4,p.num)) then
	 		p.but += 1
	   if (p.but >= max_kick) button_released(p)
	  else
	   if (p.but > 0) button_released(p)
	  end
	 end
	end,

 draw=draw_footballer,

 update=function(f)
  if (playing()) findpos(f)
  if is_throwin() or game_state==game_state_toballout then
	  if (throwintype==fstate_throwin)  findpos(f)
	  if (throwintype==fstate_goalkick) findpos2(f,{x=0,y=0})
	  if (throwintype==fstate_corner)   findpos2(f,{x=0,y=-fh2*throwinside})
  end
 end
}

fstate_down =
{	
		start=function(f)
		 f.timer=60
   if (f.keeper) f.lastspr=0
	 end,

	 draw=function(f)
	  local down_spr = 37
	  local pos = sprite_pos(f)
			jersey_color(f)
	  spr(down_spr+f.lastspr, pos.x, pos.y, 1, 1, f.lastflip)
	 end,

	 update = function(f)
   if checktimer(f) then
    set_state_ok(f)
		 else
		  damp(f)
		 end
		end
}

fstate_tackle =
{
	start=function(f)
	 f.timer=45
  plus_in_place(f.d,muls(f.dir,3.0))
 end,

 draw=function(f)
  local pos = sprite_pos(f)
  jersey_color(f)
  spr(32+f.lastspr, pos.x, pos.y, 1, 1, f.lastflip)
 end,

 update = function(f)
  if checktimer(f) then
  	set_state_ok(f)
  else
   damp(f)
   -- check collision
   for m in all(men) do
   	check_tackle(f, m)
   end
  end
 end
}


function check_tackle(tackler,other)
	if tackler != other then
		local dist = distance(tackler, other)
		local tackle_dist = 5
		if (dist < tackle_dist) other:set_state(fstate_down)
	end
end


function stick_ball(f)
local prevball=muls(ball,1)
 muls_in_place(ball, 0.8)
 plus_in_place(ball, muls(plus(f, muls(f.dir,3)), 0.2)) -- + lerp to wanted_ball
end


function _update()
 ballsfxtime-=1
 if playing() then
  -- time management
  local first_half = not (matchtimer>=half_time)
  if (not demo) matchtimer+=1
  if first_half and matchtimer>=half_time or matchtimer>full_time then 
   changing_side=first_half
   foreach(men,change_side)
   camlastpos=copy(camtarget)
   set_game_state(game_state_tokickoff)
   kickoff_team=3-starting_team
   sfx(matchtimer>full_time and 1 or 0)
   return
  end

  dribblen = 0
  foreach(men, dribble_ball)
  if dribblen>0 then
   ball.d.x = dribble.x / dribblen
   ball.d.y = dribble.y / dribblen
   muls_in_place(dribble,0)

   -- improving ball control
   if (dribblen==1) stick_ball(man_with_ball)

   if (clampvec_getlen(ball.d,10)>1) ballsfx()
 end

  distance_men_ball()
 end

 foreach(men, damp)
 foreach(players, player_input)
 foreach(men, man_update)
 update_ball()

 if (is_throwin()) players[side_to_idx(throwinside)].man = throwin_f
 if (game_state.update!=nil) game_state:update()

 update_cam()

 if (demo) then
  if checktimer(menu) then
   menu.timer = 10
   blink = not blink
  end
  if (btnp(0)) mode-=1
  if (btnp(1)) mode+=1
  if (mode<0) mode=2
  if (mode>2) mode=0
  if (btnp(2)) changeshirt(1)
  if (btnp(3)) changeshirt(2)
  if (btn(4)) start_match(false)
 end
end


function changeshirt(i)
 teamcolors[i]+=1
 if (teamcolors[i]>=#shirtcolors) teamcolors[i]=1
 if (teamcolors[i]==teamcolors[3-i]) teamcolors[i]+=1
end


function _draw()
 camera()
 rectfill(0,0,127,127,3)  

 camera(camtarget.x-64, camtarget.y-64)

 for y=-fh2,fh2-1,32 do
  rectfill(-fw2,y,fw2,y+16,3)
  rectfill(-fw2,y+16,fw2,y+32,11)
 end

 color(7)
 rect(-fw2, -fh2, fw2, fh2)
 line(-fw2, 0, fw2, 0)

 rect(-penaltyw2, -fh2, penaltyw2, -fh2_penaltyh)
 rect(-penaltyw2, fh2, penaltyw2, fh2_penaltyh)
 
 circ(0, 0, 30)

 palt(3, true)
 palt(0, false)

 local draw_list = {}
 add(draw_list, goal_up)
 add(draw_list, ball)
 for i in all(men) do
  add(draw_list, i)
 end
 add(draw_list, goal_down)
 bubble_sort(draw_list)

 for i in all(draw_list) do
  i:drawshadow()
 end

 for i in all(draw_list) do
  i:draw()
 end

 draw_marker(players[1].man)
 draw_marker(players[2].man)

-- for i in all(men) do
--  line(i.x,i.y,i.x+10*i.dir.x,i.y+10*i.dir.y,10)
-- end

 pal()
 palt()
 camera()

 if (scoring_team != 0) print_outlined("goal!", 55, 6, 7, 0)
 if (matchtimer>full_time) print_outlined("game over", 47, 16, 7, 0)
 if (changing_side) print_outlined("half time", 47, 16, 7, 0)

 print_outlined(score[1], 116, 1, 12, 0)
 print_outlined("-", 120, 1, 7, 0)
 print_outlined(score[2], 124, 1, 8, 0)
 if demo then
  menu_offset=max(menu_offset/2,1)
 else
  menu_offset=min(menu_offset*2,128)
  print_outlined(flr(matchtimer/30), 1, 122, 7, 0)
 end
 print_outlined("succer", 51+menu_offset, 40, 7, 0)
 print_mode(0,"player vs player")
 print_mode(1,"player vs cpu")
 print_mode(2,"   cpu vs cpu")
 draw_button(0,20,74)
 draw_button(1,100,74)
 print_outlined("team colors", 42+menu_offset, 90, 6, 5)
 draw_button(2,20,89)
 draw_button(3,100,89)
 if (blink) print_outlined("press z to start", 32-menu_offset, 110, 6, 5)
end


function draw_button(s,x,y)
 spr(64+s,x-menu_offset,y+(btnp(s) and 1 or 0))
end

__gfx__
33444433334444333344443333444433333444333334443333344433333444333334443333344433333444333334443333344433333444333334443333344433
33444433334444333344443333444433334444333344443333444433334444333344443333444433334444333344443333444433334444333344443333444433
f8444433384444833344448f3844448333444f3333444f3333444f3333444f3333444f3333444f3333444f3333444f33334fff33334fff33334fff33334fff33
f8444483f844448f3844448ff844448f3344ff333344ff333344ff3f3344ff33334fff33334fff33334fff33334fff3333ffff3333ffff3333ffff3333ffff33
3388828333888233382882333388823333888833328888833288888f3288888333388333333883f33338833333f883f3338888e3388888e338888833388888f3
33dd11f3331d11333f11dd333311d13333118ff33f8118f33f8118333f8118f330ef833333f883333338f33333388f3338f811333f8111f3f38118e33f8118e3
33fe3333333355333333fe333355333333ee1003333ef3333feef003333ef3333031ff333f311f3333e11f3330e1100330f1df33330fef33333ef3f333ffee33
33003333333333333333003333333333300333333330033333003333333003333333300333330033330033333033333333333003333300333330033333003333
33444433334444333344443333444433334444333334443333344433333444333344443300000000000000000000030033333333363333633a3333a339333393
3344443333444433334444333344443333444433334444333344443333444433334444330000000000000000030b00003333333363333336a333333a93333339
f8fffe3338fffe8333fffe8f38fffe833344443333444f3333444f33334fff3333fffe3300000000000000000000000033333333333333333333333333333333
f8fffe83f8fffe8f38fffe8ff8fffe8f384444833244ff33334fff3333ffff8338fffe8300000000000000000000000033333333333333333333333333333333
3388828ff388823ff8888233f388823f3f8882f33f88888333388333328888f33f8882f300000000000000000b00300b33333333333333333333333333333333
33dd113f331d1133f311dd333311d1333f1111f333f118f3333f13333f811f333f1111f300000000000000000000000033333333333333333333333333333333
33fe3333335533333333fe333333553333fefe333300fe33333fe53333ef003333fefe330000000000000000030000003333333363333336a333333a93333339
3300333333333333333300333333333333000033333300333330003333003333330000330000000000000000000b000033333333363333633a3333a339333393
33330033344433333444333333444333334444333f4444f3333344433333333330e3333333000033000000000000000037733333355333333555553333333333
3333fe33444433334444333334444333334444333f4444f33334444f333333330ef2333333fefe33000000000000000077773333555533335555555333333333
3333fe33444f3333444f333334fff33338fffe8338544583333444ef333334440fd1833333111133000000000000000077763333555533333555553333333333
3344443344ff3e304fff33333ffff3333efffe8338888823338888f30f1844443e18844433888233000000000000000037633333355333333333333333333333
334444f33888e3f03888333338888f333f8888f333888233321288830f18444f3328444438844823000000000000000033333333333333333333333333333333
f84444e3f88f8fe33ff883333ff888333311113333111133efd113330e1885ee3338544438444483000000000000000033333333333333333333333333333333
f8444483f3811e333311ff333311ffe333fe333333fefe330efe33333333efff3332fe543f4444f3000000000000000033333333333333333333333333333333
338888333333333333333e0033333e003300333333000033300333333333333333333ff33f5445f3000000000000000033333333333333333333333333333333
3f4444f33f3444333334443333344433334444333344443333444433333344433333333333444433334444333344443353333333353535353030303037373737
3f4444f33f4444f333444f33334444f33f4444f33344443333444433333444453333333333444433334444333344443335333333535353530303030373737373
385445833e444ef333444f333f4fffe33feffef33344443333444433333444ef3333344433fffe3333fffe3333fffe3353533333353535353030303037373737
388888233244e8e33348fe333effff8338effe833844448338444483338888f30f18444438fffe8338fffe8338fffe8335353333535353530303030373737373
3388823333888833333883333288883333888233f888828ff888828f321288830f18444ff888828ff888828ff888828f53535333353535353030303037373737
3311113333f118333331133333811f33331111335311113553111135efd113330e1885ee53111135531111355311113535353533535353530303030373737373
33fefe333300fe33333ff53333ff003333fefe33333f3f3333f33f330efe33333333eff533f33f3333f33f33333f3f3353535353353535353030303037373737
33000033333300333330003333003333330000333300300330033003300333333333333330033003300330033300300335353535535353530303030373737373
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00007d00007d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000765000076d0000007d000077777d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0076650000766d0000766d000d666650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d6650000766500076666d000d66500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d6500007650000d555550000d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000d50000d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08800880388338830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880388888830000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800338888330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30888803338888330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30888803338888330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30000003333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000006900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010700003905004000390503905039050390503905039050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700003905004000390503905039050390503905039050040000400039000390503905039050390503905039050390500400004000390003905039050390503905039050390503905039050390403903039010
011000000e610116101161011610136100e61010610136101161013610136100e61010610106100e610136100c6100c6100c6100e6100c610106100c61010610106100e610106101161011610106100e6100e610
010d0018301043c1010c10124100000003c1143c114301113c1043c1010000000000000000000000000000003c1043c1043010100000000000000000000000000000000000000000000000000000000000000000
01100000306101a611186013460000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036600
011000000c06300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000015770117700e7700b7700977007770067700477003770027700177001770017700177001770097000870004700017001430012300103000e3000c3000b30009300073000530003300023000130001300
000100003e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7703e7603e7603e7603e7603e7503e7503e7403e7403e7303e720
00010000127700c7700877006770047700377002770027700277004770067700a7700f77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000027500235001d50014500115000f5000e5001c5001b5001a5001b5001050011500120001e000115001a000107000e00011000107001a0001b00007700127000b70016700167000c700107000d70011700
00100000190001b0001d0001e00016000180001a0001a0000f0001300015000150001c00019000160001200016000120000000000000000000000000000000000000000000000000000000000000000000000000
00050000075701157007570027002c000260001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000157700f7701f7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000a77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000461004640046600367003670036700267003660046600666005660046600565006650036500365003650036400464005640096400964006630046300563004630046200562006620056200561007610
0010000012610136401566013670136701467012670136601166013660136600e66010650106500e650136500c6500c6400c6400e6400c640106400c63010630106300e630106201162011620106200e6100e610
001000100f6300f63500000146000f6300f63514600000000f635016050f635000050f63500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000f6200f62500000000000f6200f61500000000000f615000050f615000050f61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000f6300f63500000000000f6200f62500000000000f625000050f615000050f61500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000307003070050700507003000050000000000000030700507005070000000307005070050700000003070050700507005070000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 02 43 44
00 41 02 43 44
01 41 02 03 44
00 41 02 10 44
00 41 02 10 44
00 41 02 11 44
00 41 02 43 44
00 41 02 10 44
02 41 02 11 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
