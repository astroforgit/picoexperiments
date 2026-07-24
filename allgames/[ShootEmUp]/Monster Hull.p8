pico-8 cartridge // http://www.pico-8.com
version 7
__lua__
-- monster hull
-- by william anderson
-- code + art: 
--    william anderson
--    twitter: @thewaanderson
-- music and sfx:
-- 			brendan byrne
--    twitter: @bigwetdognose

function set_globals()
 -- title screen
 titley = 24
 titled = true
 tstars = {}
 transition = 0

	-- global groups
 actors = {}
 bullets = {}
 stars = {}
 flares = {}
 mons = {}

 -- time
 met = 0
 met_c = 0
 met_inc = 10
 tur_c = 0
 tur_i = 0
 met_freeze = false

 -- global objects
 pl = {}

 -- screen
 screenr = true
 screenx = 0
 screenc = 0
 is_shake = false
 left_ui = 128-52
 score = 0
 state = "title"
 flash_mon = false
 lva = 40 -- level up animation
 lvac = 40
 lvai = 0
 lvat = ""

 -- consts
 bnds = {}
 bnds.l = -7
 bnds.r = 79
 bnds.b = 1
 bnds.w = bnds.r - 4
 edge = bnds.w-11

 -- ship stats
 ship = {}
 ship.forms = {"base", "heart"}
 ship.unlocks = {"star","diamond","comet"}
 ships = {}
 ship.form = 1

 -- enemy units
 en = {}
 fire = {}
 queue = {}
 hitmarks = {}
 diff = 1

 -- ng+
 ng = 0

 -- game over
 go = {}
 go.x = -60
 go.y = 60
 go.sx = -8
 go.color = 7
 go_confirm = false

 set_soundmap()
end

function set_soundmap()
	snds = {}
	snds.pshoot = 1
 snds.eshoot = 2
 snds.cannon = 13
 snds.laser = 8
 snds.hit = 3
 snds.phit = 6
 snds.death = 7
 snds.kill = 4
 snds.confirm = 3
 snds.drop = 12
 snds.capture = 15
 snds.levelup = 11
 snds.absorb = 0--5
 snds.switch = 0
 snds.bossd = 14
 snds.burst = 13
 snds.shield = 10
 snds.start = 9
end

function psfx(key)
	if snds[key] then
		local snd = snds[key]
		if snd > -1 then
			sfx(snd)
		end
	end
end

function _init()
 delay = 0
 set_globals()
 create_ships()
 create_pl()
 create_stars()
 create_armada()
 create_tstars()
 music(-1)
end

function _update()
 ctrl_in()

 if state == "title" then
  update_title()
  foreach(tstars,update_tstar)
  update_trans()
 end
 if state != "title" then
		update_play()
	end
end

function update_play()
 shake()
 check_damages()
 foreach(hitmarks, update_hitmark)
 if pl.active then
 	update_met()
 	adj_pl()
 	foreach(mons,update_mon)

 	if tur_c == 1 then
 		fire_turrets()
 		tur_c = 0
 	end

 	if count(queue) == 0 and count(en) == 0 then
 	 create_armada()
 	 met = 0
 		met_c = 0
 	 ng += 1
 	 music(4)
 	elseif count(en) == 0 and met_freeze then
 	 met_freeze = false
 	else
 	 foreach(queue,check_queue)
 	end
 end
	update_bullets()
	foreach(flares, update_flare)
	foreach(fire, update_fire)
	update_stars()
	foreach(en,step_en)
	update_lva()

	if state == "gameover" then
	 update_go()
	end
end

function _draw()
 cls()
 if state == "title" then
  draw_title()
  if transition == 0 then
  	foreach(tstars,draw_actor)
  end
 else
  draw_game()
 end
end

function draw_game()
 if is_shake and screenx == 1 then
  rectfill(0,0,85,128,8)
 end
 camera(screenx,0)
 draw_stars()
	draw_pl()
	foreach(en,draw_en)
	draw_bullets()
	draw_fire()
	foreach(flares, draw_flare)
	foreach(hitmarks, draw_hitmark)

	pal(11,pl.color)
	palt(0,false)
	map(0,0, 0,0, 16,16)
	pal() palt()
	draw_interface()
	if pl.active then
		foreach(mons,draw_actor)
	end

	draw_lva()

	if state == "gameover" then
	 draw_go()
	end
end


function update_hitmark(sh)
	if sh.r > 0 then
		sh.w += 1
	else
		sh.w -= 1
	end
end

function draw_hitmark(sh)
	local colk = sh.r + 2
	local cols = {7,0,9,8}
	local x = sh.x - 3

	if sh.r > 0 then
		circfill(sh.x,sh.y,sh.w*.75,cols[colk])
	else
		circ(sh.x,sh.y,sh.w,cols[colk])
	end

	if sh.w <= 0 then del(hitmarks,sh) end
	if sh.r > 0 and sh.w > 2 then
		del(hitmarks,sh)
	end
end

function add_hitmark(bul,en,r)
	local sh = {}
	sh.x = bul.x
	sh.y = bul.y -- en.y + en.h*8
	sh.w = 0
	if r < 0 then sh.w = 3 end
	sh.r = r
	add(hitmarks,sh)
end

function update_title()
 update_logo()
 update_stars()
end

function lva_anim(icn,t)
	lva = 0
	lvac = 0
	lvai=icn
	lvat=t
end

function update_lva()
	lvac += 1

	if lvac < 40 then
		lva += 1
	end
end

function draw_lva()
	local lva_ys = {12,8,9,10,14,12}
	local lva_xs = {-4,0,4,7,10,12}
	local lva_sp = {1,.5,.7,1.25,1,.75}
	local txt = lvat.." up!!"
	local txtl = (edge-(#txt-2)*4)/2
	--lva_ys = {-3,0,4,7,10,14,15,16,18}
	for i=1,count(lva_xs),1 do
		local y = pl.y+(lva_ys[i]+4)-lva*lva_sp[i]
		if y > pl.y - 5 then
			pal(11,pl.color)
			spr(105,pl.x+lva_xs[i],y)
			palt()

			spr(lvai,txtl-6,28)
			print(txt,txtl+6,30)
		end
	end
end

function fire_turrets()
 local turx = {-5,20}

	if pl.tur > 0 then
		psfx('pshoot')
  for i=1,pl.tur,1 do
  	local b = make_actor(0,pl.x+turx[i],pl.y+3,1,2)
	 	b.drift = 0
	 	b.sp = 5
	 	b.color = pl.color
	 	b.turret = true
	 	pl.xtraammo += 1
	 	add(bullets,b)
  end
 end
end

function create_tstars()
 local tsx = {40,65,80}
 local tsy = {30,55,45}
 local ssp = {0,2,3}
 local bdel = {2,15,8}
 for i=1,count(tsx),1 do
  local s = {}
  s.x = tsx[i]
  s.y = tsy[i]
  s.w = 1
  s.h = 1
  s.bdel = bdel[i]
  s.cnt = 0
  s.sprite = 136 + ssp[i]
  s.sspr = 136
  s.sprm = 140

  add(tstars,s)
 end
end

function update_tstar(s)
 if s.bdel > 0 then
  s.bdel -= 1
  s.sprite = 135
 else
  s.cnt += 1
  if s.sprite == 135 then
   s.sprite = s.sspr
  end
  if s.cnt == 3 then

   if s.spd then
    s.sprite -=1
   else
    s.sprite +=1
   end

   if s.sprite == s.sprm
   or s.sprite == s.sspr then
    s.spd = not s.spd
   end

   if s.sprite == s.sspr then
    s.bdel = 15
   end

   s.cnt = 0
  end
 end
end


function draw_title()
 foreach(stars,draw_title_star)
 spr(128,65-32,titley,8,6)
 print("press z+x to play",30,100,12)

 print("code+art @thewaanderson",19,128-20,1)
 print("music @bigwetdognose",25,128-14,1)

 print("(c)2016 william anderson",16,128-5,1)
 if transition > 0 then
  draw_trans()
 end
end

function update_trans()
 if transition > 0 and transition < 20 then
  transition += 1
 else
  if transition == 20 then
   state = "play"
  end
 end

end

function draw_trans()
 palt(0,false)

 if transition > 15 then
  rectfill(0,0,128,128,0)
 else
  tfr = flr(transition/3)

  palt(11,true)
  for i=1,4,1 do
   map(16+(tfr*4),0, (i-1)*4*8,0, 4,16)
  end
 end
 palt()
end

function update_logo()
	if titled then
  titley += .1
 else
  titley -= .1
 end
 if titley >= 28 or titley <= 24 then
  titled = not titled
 end
end
function draw_title_star(s)
	local x = s.x*1.75
 rectfill(x,s.y,x+s.w-1,s.y+s.h-1,s.color)
end

function draw_interface()
 draw_st()

 -- draws ships
	for i=1,count(ship.forms),1 do
 	foreach(ships,
  function (s)
   if s.model == ship.forms[i] then
    draw_ship_stats(s,i,i==count(ship.forms))
   end
  end)
 end

 if ng > 0 then
  print("ng+",1,1,7)
  if ng > 1 then print(ng,13,1,7) end
 end
end

function draw_st()
 local y = 13

 print("ship stats",left_ui+4,4,13)

 spr(102,left_ui,y-1)
 local hpc = 8
 if pl.hp == 2 then hpc = 9 end
 if pl.hp > 2 then hpc = 11 end
 for i=1,pl.maxhp,1 do
  local color = 5
  if i<= pl.hp then color = hpc end
  circ(left_ui+(i*4)+7,y,1,color)
 end

 spr(118,left_ui,y+5)
 for i=1,pl.powt,1 do
 	circ(left_ui+(i*4)+7,y+6,1,7)
 end

 spr(103,left_ui,y+11)
 for i=1,pl.blastt,1 do
 	circ(left_ui+(i*4)+7,y+12,1,7)
 end

 for i=0,pl.shield-1,1 do
  local lb = left_ui+(i*4)
  rectfill(lb,y+17,lb+2,y+19,12)
 end

 spr(119,left_ui+24,y+17,2,1)
 spr(121+pl.icn,left_ui+39,25)
end

function draw_ship_stats(s,i,l)
  local y = (i-1)*18 + 40
  local lper = s.percent_xp()

 	if flash_mon and l then
 	 rectfill(left_ui-2,y-2,left_ui+48,y+11,7)
 	 flash_mon = false
 	end

 	if s.active then
 		rectfill(left_ui-2,y-2,left_ui+48,y+11,1)
 	end

 	--name+icon
 	spr(67+(s.icn*2), left_ui,y-1, 2,2)
 	print(s.name,left_ui+14,y,7)

 	-- lv + xp
 	if lper != 0 then
 	 local bw = (lper*19)
 	 if bw > 19 then bw = 19 end
 	 if s.lv == s.mlv then bw = 19 end
 	 rectfill(left_ui+25,y+7,
 	 	left_ui+25+bw,y+9,s.color)
 	end
 	rect(left_ui+24,y+6,left_ui+45,y+10,6)
 	spr(113,left_ui+14,y+6)
 	local lv = s.lv
 	if lv == s.mlv then lv = "m" end
 	print(lv,left_ui+20,y+6)

 	-- indicator
 	if s.active then
 	 spr(114,left_ui-9,y+1)
 	 spr(114,left_ui+48,y+1,1,1,true)
 	end
end

-- updates metronome
function update_met()
 if not met_freeze then
  met_c += 1
 end

 tur_i += 1

 if met_c == met_inc then
 	met += 1
 	met_c = 0
 end

 if tur_i == met_inc then
 	tur_c += 1
 	tur_i = 0
	end
end

-- handles controller inputs
function ctrl_in()
 if state == "title" and transition == 0 then
  if btn(4) and btn(5) then
   transition = 1
   psfx('confirm')
   music(3)
  end
 end

	if pl.active and state != "title" then
 	-- z
 	if btnp(4) then pl.shoot() end

 	-- x
 	if btnp(5) then switch_ship() end

 	-- left/right
		if btn(0) then pl.x -= pl.sp end
 	if btn(1) then pl.x += pl.sp end
	end

	if go.x == 17 and btnp(4) then
	 go_confirm = true
	 psfx('confirm')
	end
end

-- shakes screen

function shake()
 if is_shake then
 	if screenr then
  	screenx += 1
  	if screenx > 2 then screenr = false end
 	else
  	screenx -= 1
  	if screenx < -2 then screenr = false end
 	end

 	if screenx < -2 then
  	screenx = 0
  	screenr = true
  	is_shake = false
 	end
 end
end

-- adjusts player position
function adj_pl()
	if pl.x < bnds.l then
	 pl.x = bnds.l
	end

	if pl.x > bnds.r - 16 then
	 pl.x = bnds.r - 16
	end

	pl.refill_hp()
end

-- creates all gameplay
function create_armada()
 w1(0+delay) --0
 w2(20+delay)--30
 w3(45+delay)--55
 w4(80+delay)--90
	w5(140+delay)--150
	boss(190+delay)--200
end

function train()
	met_freeze = true


	for i=0,18,1 do
		local e = make_enemy(9,1,1,1,1)
		e.hp = 1
		e.xp = 100
		e.drops = true
		e.move = function() end
		e.fire = function() end
		add(en,e)
	end

end

function boss(t)
 q_e("boss",0+t,true)
end


function w5(t)
	q_e("mant",0+t,false,0)
	q_e("mant",0+t,false,edge-8)

 for i=1,3,2 do
 	q_e("pwog",2+t,false,(((edge+16)/5)*i),0)
 end

 q_e("horse",6+t)
 q_e("hor-r",6+t)
 q_e("mant",8+t,false,(edge-8)/2)

	w2(16+t,true)
	w1(16+t,true)
end

function w4(t)
	q_e("snap",0+t,false)
	q_e("snap",5+t,true)

	q_e("beet",6+t,false,1,16)
	q_e("beet",6+t,false,-1,16)
	q_e("pwog",6+t,true,edge/2,0)

	q_e("pwog",13+t,false,0,20)
	q_e("pwog",13+t,false,edge,20)

	local mantc = 3
	for i=0,mantc-1,1 do
		q_e("mant",13+i*5+t,false,i*(edge+8)/mantc)
	end

	q_e("beet",22+t,false,1,32)
	q_e("beet",22+t,false,-1,32)
	q_e("pwog",29+t,false,0,50)
	q_e("pwog",29+t,true,edge,50)

	for i=1,3,2 do
 	q_e("pwog",30+t,false,(((bnds.w+8)/5)*i),0)
 end

 for i=0,4,2 do
 	q_e("tad",i*2+t+30)
 	q_e("tad-i",i*2+t+30)
 end
 q_e("tad",t+39,true)

 q_e("tort",40+t,false,0)
 q_e("tort-d",40+t,false,edge-8)
 q_e("pede",40+t,false)
 q_e("pede",50+t,false)
 q_e("pede",55+t,true)
end

function w3(t)
 q_e("horse",2+t)
 q_e("hor-r",2+t)
 q_e("snap",2+t,false)
 q_e("pwog",1+t,false,0,40)
	q_e("pwog",1+t,false,edge,40)

 for i=2,6,1 do
 	q_e("tad",15+i+t)
 end

 q_e("tad",22+t,true)

 q_e("tort",31+t,true,0)
 q_e("tort",31+t,false,edge-8)
end

function w2(t,skip)
	for i=0,4,2 do
 	q_e("tad",i*2+t)
 	q_e("tad-i",i*2+t)
 end

	for i=1,5,2 do
	 local f = false
	 if i==5 then f=true end
 	q_e("pwog",12+i+t,f,(bnds.w/5)*(i-1),0)
 end
 q_e("pede",12+t,false)

 for i=1,3,2 do
 	q_e("pwog",10+t,false,((bnds.w/5)*i),0)
 end

 q_e("beet",20+t,false,1,16)
	q_e("beet",20+t,false,-1,16)
	q_e("snap",20+t,true)

	local boss = "tort-d"

	q_e(boss,21+t,false,(edge/2)-4)
	q_e("pwog",23+t,false,16,40)
	q_e("pwog",23+t,true,edge-16,40)
end

function w1(t)
	q_e("tad",1+t,true)
 for i=2,6,1 do
 	q_e("tad",i+t)
 end
 q_e("tad",7+t,true)
 for i=1,6,2 do
 	local freeze = false
 	if i==5 then freeze = true end
 	q_e("pwog",7+i+t,freeze,(bnds.w/5)*(i-1),(5*i))
 end

	q_e("tort",14+t,true,(edge/2)-4)
end

-- queues an enemy for play
function q_e(t,d,f,x,y)
 local qe = {}
 qe.type = t
 qe.delay = d
 qe.freeze = f
 qe.x = x
 qe.y = y

 add(queue,qe)
end

-- checks enemy queue
function check_queue(qe)
 -- adds enemy for queue
 if qe.delay == met then
  add_enemy_unit(qe)
  if qe.freeze then
  	met_freeze = true
  end
  del(queue,qe)
 end
end

-- creates an enemy unit
function add_enemy_unit(u)
	local e = {}

	local t = u.type

	if t == "boss" then
		e = make_boss()
		pl.rec = pl.maxhp - pl.hp
		music(25)
	end

 if t == "tad" then
  e = make_tp()
 elseif t=="tad-i" then
  e = make_tp(true)
 end

 if t == "pede" then
  e = make_cp()
 end

 if t == "pwog" then
  e = make_pw(u.x,u.y)
 end

 if t == "tort" then
  e = make_to(false,u.x)
 end

 if t == "horse" then
  e = make_sh(1)
 elseif t == "hor-r" then
 	e = make_sh(-1)
 end

 if t == "snap" then
  e = make_snap()
 end

 if t == "mant" then
  e = make_mant(u.x)
 end

 if t == "beet" then
  e = make_beet(u.x,u.y)
 end

 if t == "tort-d" then
  e = make_to(true,u.x)
 end

 add(en,e)
end

-- game boss
function make_boss()
 local e = make_enemy(200,4,-32,4,4,true)

 e.ymax = 0
 e.sp = .4
 e.hp = 1250 + (ng*100)
 e.mhp = e.hp
 e.xp = 200 + ng*20
 e.color = 8
 e.boss = true
 e.weak=7

 e.can = 1
 e.cand = {-1.5,-.5,0,.5,1.5}
 e.altbur = true

 e.burctr = 0
 e.lctr = 0
 e.llap = 6
 e.lfir = 1
 e.lazs = {e.llap,e.llap}

 e.shs = 2 -- sea horses
 e.hshs = false
 --
 e.phase = 0
 e.f1rythm = 1
 e.f2rythm = 0

 e.flame = true
 e.f1 = 9
 e.f2 = 8
 e.f3 = 8

 e.move = function()
  if e.y<e.ymax then
 		e.y += e.sp
 	else
  	e.lazers()
 	end
 end

 e.drop = function()
  if ng == 0 then
			local d = ship.unlocks[1]
			del(ship.unlocks,d)
			drop_mon(d,e)
		end
 end

 e.next_can = function()
  e.can += 1
  if e.can > 5 then e.can = 1 end
 end

 e.fire = function()

  -- tortoiuse cannon
 	if e.y >= e.ymax then
 	 local per = (e.hp/e.mhp) - .001
 		e.phase_atk(5 - flr(per*6))
		end

		e.phase_atk = function(p)
		 if p == 0 then
		 	e.phase0()
		 elseif p == 1 then
		  e.phase1()
		 elseif p == 2 then
		  e.phase2()
		 elseif p == 3 then
		  e.phase3()
		 elseif p == 4 then
		  e.phase4()
		 elseif p == 5 then
		  e.phase5()
		 end
		end

		e.phase5 = function()
			e.to_can(1)
			e.to_can(2)
			e.next_can()
			if e.lctr == 0 then
 		 e.f_laz(1)
 		 e.f_laz(2)
 		end
		end

		e.phase4 = function()
			if e.burctr == 0 then
 			e.phase0()
 		end
			e.to_can(1)
			e.to_can(2)
			e.next_can()
		end

		e.phase3 = function()
			if e.burctr == 0
			or e.burctr == 2 then
 			e.burst()
 		end
 		e.to_can(1)
 		e.next_can()
		end

		e.phase1 = function()
			e.phase0()
			if e.f1rythm == 1 then
				e.burst()
			end
		end

		e.phase2 = function()
			e.phase0()
			if e.hshs == false then
				e.shs = 0
				e.hshs = true
			end
		end

		e.phase0 = function()
			e.f1rythm += 1

			e.tur(e.f1rythm)

			if e.f1rythm == 4 then e.f1rythm = 0 end
		end


		if e.shs == 0 then
 		e.callsh()
 	end

 	e.ctr = 0
 	e.cntrs()
 end

 e.tur = function(t)
 	e.tursx = {2,24,39,61}
 	e.tursy = {26,16,16,26}
 	psfx('eshoot')

 	local b = make_actor(0,e.x+e.tursx[t],e.y+e.tursy[t],1,1)
		b.sp = e.sp + 2
 	b.color = 12
 	add(fire,b)
 end

 e.callsh = function()
 	local sh1 = make_sh(-1)
 	local sh2 = make_sh(1)
 	sh1.y = 40
 	sh2.y = 40
 	sh1.hp = 30
 	sh2.hp = 30
 	add(en,sh1)
 	add(en,sh2)
 	e.shs += 2
	end

 e.f_laz = function(l)
 	e.lazs[l] = 0
 	psfx('laser')
 end

 e.lazers = function()
 	e.lazer(1)
  e.lazer(2)
 end

 e.lazer = function(l)
 	if e.lazs[l] < e.llap then
 		e.lazs[l] += 1
  	local xs = {e.x+23,e.x+40}
 		local b = make_actor(0,xs[l],e.y+26,2,1)
			b.sp = e.sp + 3
 		b.color = 7
 		b.drift = d
 		add(fire,b)
 	end
 end

 e.cntrs = function()
 	e.burctr += 1
 	if e.burctr == 3 then
 		e.burctr = 0
 	end

 	e.lctr += 1
 	if e.lctr == e.llap then
 	 e.lctr = 0
 	end
 end

 e.burst = function()
 	psfx('burst')
 	e.altbur = not e.altbur
 	e.burdri = {-1.25,-.25,.25,1.25}
 	if e.altbur then
 		e.burdri = {-.75,0,0,.75}
 	end

 	foreach(e.burdri, function(d)
 		local b = make_actor(0,e.x+32,e.y+32,1,1)
			b.sp = e.sp + 2
 		b.color = 10
 		b.drift = d
 		add(fire,b)
 	end)
 end

 e.to_can = function(wc)
 	psfx('cannon')
 	e.canx = {6,11,13,16,22}
 	e.cany = {30,32,27,32,30}
 	if wc == 2 then
 		for i=1,count(e.canx),1 do
 			e.canx[i] = e.canx[i] + 38
 		end
 	end

 	local b = make_actor(0,e.x+e.canx[e.can],e.y+e.cany[e.can],2,1)
		b.sp = e.sp + 2
 	b.color = 11
 	b.drift = e.cand[e.can]
 	add(fire,b)
 end

 return e
end

-- makes a pollywog
function make_pw(x,y)
 local e = make_enemy(53,x,-8,1,1)

 e.fire_rate = 50
 e.hp = 6 + (ng*2)
 e.xp = 3 + ng*2
 e.color = 10
 e.weak = 7
 e.sp = .5
 e.my = y
 e.res = 10

 e.move = function()
  if e.y < e.my then
 		e.y += e.sp
 	end
 end

 e.fire = function()
 	local b = make_actor(0,e.x+e.fire_x,e.y+e.fire_y,2,1)
		b.sp = (e.sp + 1) * (e.sp + 1)
 	b.color = e.color
 	add(fire,b)
 	psfx('cannon')

 	e.y -= 1
 	e.ctr = 0
 end

 return e
end

-- makes a beetle turret
function make_beet(d,y)
	local x = 0
	if d == -1 then x = bnds.w end
 local e = make_enemy(52,x+(-8*d),y,1,1)

 e.fire_rate = 30
 e.hp = 2 + (ng*2)
 e.xp = 1 + ng*2
 e.color = 10
 e.weak = 10
 e.dir = d
 e.sp = .2

 if d == -1 then e.flip = true end


 e.move = function()
  if e.dir == 1 and e.x<0
  or e.dir == -1 and e.x>bnds.w-11 then
 	 e.x += e.dir
 	end

 	e.y += e.sp
 end

 e.fire = function()
  local fx = e.x+8
  if e.dir == -1 then fx = e.x end
 	local b = make_actor(0,fx,e.y+8,1,1)
		b.sp = e.sp + 2
 	b.color = e.color
 	b.drift = 1.1 * e.dir
  add(fire,b)
  psfx('eshoot')

  e.ctr = 0
 end

 return e
end

-- makes a seashorse
function make_sh(d)
	local x = -16
	local y = 1
	if d == -1 then x = bnds.w-3 end
 local e = make_enemy(6,x,1,2,2)

 e.fire_rate = 100
 e.hp = 60 + (ng*2)
 e.xp = 1 + ng*2
 e.color = 10
 e.weak = 10
 e.dir = d
 e.cl = false
 if d == -1 then e.flip = true end


 e.move = function()
  if d == 1 then
 	 if e.x < -3 then
  	 e.x += .25
  	else e.cl = true
   end
  else
  	if e.x > bnds.w-16 then
  	 e.x -= .25
  	else e.cl = true
   end
  end
 end

 e.fire = function()
  if e.cl then
 	 local bsh = make_bsh(e)
 	 add(en,bsh)
 	end
 	e.ctr = 0
 end

 return e
end

-- make a baby seahorse
function make_bsh(l)
 local hbx = 0
 if l.dir == 1 then hbx = 9 end
 local e = make_enemy(39,l.x+hbx,l.y+4,1,1)

 e.fire_rate = 40
 e.hp = 1
 e.xp = 1
 e.color = 10
 e.weak = 4
 e.dir = l.dir
 e.sp = .2

 e.move = function()
		e.x += e.dir
		e.y += .2

		if e.x <= 0 then e.dir = 1 end
		if e.x >= bnds.w-10 then e.dir = -1 end
	end

	return e
end

-- makes a centipede
function make_cp()
	local x = -24
	local y = 1
 local e = make_enemy(36,x,1,3,1,false)

 e.fire_rate = 28
 e.hp = 22 + (ng*2)
 e.xp = 8 + ng*2
 e.color = 10
 e.weak = 7
 e.flip = false
 e.sp = 2 + (ng-1)
 if e.sp > 3 then e.sp = 3 end
 e.res = 14

 e.move = function()
  if e.flip then
 		e.x -= e.sp
 		if e.x < -36 then
 		 e.flip = false
 		 e.y += 16
 		end
 	else
 		e.x += e.sp
 		if e.x > bnds.w + 12 then
 			e.flip = true
 			e.y += 16
 		end
 	end
 end

 e.fire = function()
 end

 return e
end

-- makes a tortoise unit
function make_to(dd,x)
 local e = make_enemy(34,x,-16,1,2,true)

 e.ymax = 30
 e.sp = .4
 e.hp = 28 * (ng+1) * (count(ship.forms))
 e.xp = 6 + ng
 e.color = 8
 e.res = 14
 e.weak = 12

 e.can = 1
 e.canx = {0,5,8,10,16}
 e.cany = {11,13,11,13,11}
 e.cand = {-.75,-.25,0,.25,.75}
 e.recoil = 0

 e.flame = true
 e.f1 = 9
 e.f2 = 8
 e.f3 = 12

 e.drops = dd

 e.move = function()
  if e.y<e.ymax then
 		e.y += e.sp
 	elseif e.recoil == 2 then
 	 e.y -= 4
 	 e.recoil = 1
 	end
 end

 e.next_can = function()
  e.can += 1
  if e.can > 5 then e.can = 1 end
 end

 e.fire = function()
  if e.recoil == 1 then
   e.y += 2
   e.recoil = 0
  end

 	if e.y >= e.ymax then
 		local b = make_actor(0,e.x+e.canx[e.can],e.y+e.cany[e.can],2,1)
			b.sp = e.sp + 2
 		b.color = e.color
 		b.drift = e.cand[e.can]
 	 add(fire,b)

 	 e.recoil = 2
 	 e.next_can()
 	 psfx('cannon')
		end

 		e.ctr = 0
 end

 return e
end

-- drop down low, drop bombs, exit
function make_mant(x)
	local e = make_enemy(49,x,-8,1,1,true)

 e.sp = .8
 e.fire_rate = 2
 e.hp = 24.0 * (count(ship.forms)/2)
 e.xp = 8 + ng*3
 e.ey = 128 - 55
 e.can_m = true
 e.shots = 0
 e.maxs = 20
 e.color = 7
 e.ret = false
 e.weak = 14

 e.move = function()
 	local ease = (e.ey-e.y)/10
 	if ease > 4 then ease = 4 end
		if ease < .5 then ease = .5 end

  if e.ret then
  	if e.y > -8 then
  	 e.y -= ease
  	else
  	 e.y = 200
  	end
  end

  if e.can_m then
 		if e.y < e.ey - 1 then
  		e.y += ease
 		else
  		e.y = e.ey
  		e.can_m = false
 		end
 	end
 end

 e.fire = function()

 	if not e.can_m and e.shots < e.maxs then
 	 e.shoot()
 	 e.shots += 1
 	 psfx('laser')
 	end

 	if e.shots == e.maxs then
 		e.ret = true
 	end

 	e.ctr = 0
 end

 e.shoot = function()
 	local b = make_actor(
			0,
			e.x+7,
			e.y+12,
			4,
			4)
		b.sp = (e.sp + 1) * (e.sp + 1)
 	b.color = e.color
 	add(fire,b)
 end

 return e
end

-- makes a snapper unit
function make_snap()
 local e = make_enemy(35,1,1,1,2)

 e.curve = .2
 e.sp = .8
 e.fire_y = 16
 e.fire_rate = 20
 e.hp = 10 + (ng*2)
 e.xp = 5 + ng
 e.color = 9
 e.weak = 10
 e.dir = 1

 e.can = 1
 e.cans = {}
 e.cansd = {}
 e.cans[0] = {0,4}
 e.cans[1] = {8,5}
 e.cansd[0] = {-.75,-.65}
 e.cansd[1] = {.75,.65}
 e.can_s = 0

 e.move = function()
 	e.curve -= .009
  if e.curve > 360 then e.curve = 0 end
  e.y = sin(e.curve) * bnds.w/3 + bnds.w/2 - 8
  e.x = cos(e.curve) * bnds.w/3 + bnds.w/2 - 8

 	e.can_s += 1
 	if e.can_s == 10 then
 	 e.can += 1
 	 if e.can > count(e.cans[0]) then
 	  e.can = 1
 	 end

 	 e.can_s = 0
  end
  if e.x < 1 then
  	e.x = 1
  	e.dir = 1
  end
 	if e.x > bnds.r - 16 then
 		e.x = bnds.r - 16
 		e.dir = -1
 	end
 end

 return e
end

-- makes a tadpole unit
function make_tp(inv)
	local x = 1
	local y = 1
	if inv then x = bnds.w end
 local e = make_enemy(33,x,1)

 e.curve = .2
 e.sp = .4
 e.fire_rate = 28
 e.hp = 2 + (ng*2)
 e.xp = 3 + ng
 e.color = 10
 e.weak = 7
 e.inv = inv

 e.move = function()
 	e.curve += .01
  if e.curve > 360 then e.curve = 0 end
  e.y += e.sp
  local sc = sin(e.curve)

  e.x = sc * (bnds.w/3) + (bnds.w-8)/2
  if e.inv then
  	e.x = bnds.w - e.x -8
  end

  if e.x < 1 then e.x = 1 end
 	if e.x > bnds.w - 12 then e.x = bnds.w-12 end
 end

 return e
end

-- drops a mon for capture
function drop_mon(mon,e)
 local k = {}
 k.heart = 12
 k.star = 13
 k.diamond = 14
 k.comet = 15

 local m = make_actor(k[mon],20,20,1,1)
	m.mon = mon
	add(mons,m)
	psfx('drop')
end

function update_mon(m)
 local y = (count(ship.forms))*18 + 40
 local addm = 0

 if m.x < left_ui+12 then m.x +=2 else addm += 1 end
 if m.y < y + 2 then m.y +=2 else addm += 1 end

 if addm == 2 then
  del(mons,m)
  if m.mon == "diamond" then
   pl.mshield = 1
  end
  add(ship.forms,m.mon)
  flash_mon = true
  psfx('capture')
 end
end

-- draw for enemies
function draw_en(e)
 adjust_engine(e)

 draw_actor(e,e.flip)

 if e.m == true then
  e.x += e.w*8
  draw_actor(e, true)
  e.x -= e.w*8
 end
 pal()
end

-- updates enemy fire
function update_fire(f)
 if f then
		f.y += f.sp

		if f.drift then
		 f.x += f.drift
		end

 	if f.y > 128 then
 	 del(fire, f)
 	end
 end
end

-- makes a generic enemy
function make_enemy(s,x,y,w,h,m)
 if not w then w=1 end
 if not h then h=1 end
 if not m then m=false end
 local e = make_actor(s,x,y,w,h)

 e.curve = 0
 e.ctr = 0
 e.fire_rate = 10
 e.fire_x = 4
 e.fire_y = 8
 e.hp = 10
 e.blink = 0
 e.xp = 0
 e.color = 9
 e.m = m
 e.weak = 0

 -- flames
 e.flame = false
 e.flacnt = 0
 e.flamax = 3

 e.step = function()
  if e.y > 128 then
   del(en,e)
  elseif e.hp <= 0 then
   get_kill(e)
  else
   e.move()
   if pl.hp > 0 then e.check_fire() end
  end
 end

 e.check_fire = function()
 	e.ctr += 1

 	if e.ctr == e.fire_rate then
 		e.fire()
		end
 end

 e.fire = function()
 	local b = make_actor(
			0,
			e.x+e.fire_x,
			e.y+e.fire_y,
			1,
			1)
		b.sp = (e.sp + 1) * (e.sp + 1)
 	b.color = e.color
 	add(fire,b)
 	psfx('eshoot')

 	e.ctr = 0
 end

 e.drop = function()
  if ng == 0 and count(ship.unlocks) != 0 then
			local d = ship.unlocks[1]
			del(ship.unlocks,d)
			drop_mon(d,e)
		end
 end

 return e
end

function get_kill(e)
 for i=1,count(ships),1 do
  if ships[i].active then
   ships[i].add_xp(e.xp)
   score += e.xp
  end
 end

 if not e.bonus then
  if e.drops then e.drop() end

  del(en,e)
  explode(e)
  psfx('kill')
 end
end

-- steps enemy
function step_en(e)
 e.step()

 if pl.hp > 0 then
 	local er = {x=e.x,y=e.y,w=8,h=8}
 	local px = {x=pl.x,y=pl.y,w=16,h=16}
 	if rect_intersect(er,px) then
 		pl.hp = 1
 		pl.hit()
 		e.hp = 0
	 end
 end
end

-- checks for collisions and dmg
function check_damages()
 check_en_fir_dmg()
 check_bul_hit()
end

-- checks for pl bullet collisions
function check_bul_hit()
 foreach(en, function(e)
  local w = e.w*8
  local h = e.h*8
  if e.m then w = w*2 end
  local r1 = {x=e.x,y=e.y,w=w,h=h}

 	foreach(bullets, function(bul)
  	r2 = {x=bul.x,y=bul.y,w=bul.w,h=bul.h}

 		if rect_intersect(r1,r2) then
 	 	if bul.color != e.res then
 	 		e.hp -= pl.pow
 	 		if e.weak == bul.color
 	 		then e.hp -= 1
 	 			add_hitmark(bul,e,2)
 	 		else
 	 			add_hitmark(bul,e,1)
 	 		end
 	 		psfx('hit')

				else
					add_hitmark(bul,e,-1)
					psfx('absorb')
				end

 	 	if bul.turret == true then
   		pl.xtraammo -= 1
  		end

 	 	del(bullets,bul)
 		end
  end)
 end)
end

-- checks for collisions with
--  enemy bullets
function check_en_fir_dmg()
	foreach(fire, function(f)
 	local r1 = {x=f.x,y=f.y,w=f.w,h=f.h}
  local r2 = {}

  if r1.y > 128 - 16 - bnds.b then
   if not pl.active then
  		return
 		end

   r2 = {x=pl.x+2,y=pl.y,w=12,h=8}
  	if rect_intersect(r1,r2) then
  	 del(fire,f)
  	 if pl.current != "diamond" or pl.shield==0 then
  	  pl.hit()
  	  psfx('phit')
  	 else
  	  local e = {xp=4,bonus=true}
  	  pl.shield -= 1
  	  get_kill(e)
  	  psfx('shield')
  	 end
  	end
  end
 end)
end

-- creates stars
function create_stars()
 local colors = {6,5}

 for i=1,32 do
  local x = rnd(bnds.r)
		local y = rnd(128-bnds.b)
		local r = rnd(2)+1
  s = make_actor(0,x,y,1,1)
  s.sp = (4 - r)
  s.color = colors[flr(r)]

  add(stars,s)
 end
end

--updates and draw stars
function update_stars()
 foreach(stars,up_star)
end
function up_star(s)
 s.y += s.sp
 if s.y > 128 then
  s.y = 0 - s.w/2
 end
end
function draw_stars()
	foreach(stars,draw_rect)
end

-- creates explosion for actor
function explode(a)
 local runs = {0,1.73,1.73,0,-1.73,-1.73}
	local rise = {-1.73,-1,1,1.73,1,-1}

 if a.boss then
 	psfx('bossd')
 	delay = 10
  for i=0,8,1 do
 		for j=1,6,1 do
  		local f = make_flare(a.x+(8*i),a.y,rise[j],runs[j])
  		add(flares,f)
  		local f2 = make_flare(a.x+(8*(i+1)),a.y+16,rise[j],runs[j])
 			add(flares,f2)
 		end
 	end
 else
 	for i=1,6,1 do
  	local f = make_flare(a.x,a.y,rise[i],runs[i])
  	add(flares,f)
 	end
 end
end

function make_flare(x,y,ri,ru)
 local f = {}
 f.x = x
 f.y = y
 f.xinc = ru
 f.yinc = ri
 f.color = 8
 f.count = 0
 f.rad = 1

 return f
end

function update_flare(f)
 f.x += f.xinc
 f.y += f.yinc
 f.count += 1
 if f.count == 6 then
  f.color = 9
  f.rad +=1
 elseif f.count == 14 then
  f.color = 10
  f.rad +=1
 elseif f.count == 22 then
  del(flares,f)
 end

 if f.count != 22 and f.y > 128 - 16 - bnds.b then
  if not pl.active then
  	return
 	end
 	local fr = {x=f.x,y=f.y,w=f.rad,h=f.rad}
 	local pr = {x=pl.x,y=pl.y,w=16,h=16}

 	if rect_intersect(fr,pr) then
 		pl.hit()
 		del(flares,f)
	 end
 end
end

function draw_flare(f)
 circ(f.x,f.y,f.rad,f.color)
end


-- creates the player
function create_pl()
	pl = make_pl(1,1,128-16-bnds.b,1,2)
	pl.right = make_actor(1,pl.x+8,pl.y,1,2)
 set_ship("base")
end

-- create player ships ships
function create_ships()
	ships = {}

	-- base model
 local base = create_ship(
  "base",
  1,
  9,8,8,
  {7},
  {0},
  7,
  3,
  9
 )
 base.name = "jakrabit"
 base.icn = 0
 add(ships,base)

 -- heart
 local heart = create_ship(
  "heart",
  2,
  1,12,11,
  {3,12},
  {0,0},
  14,
  8,
  9
 )
 heart.name = "heartwal"
 heart.icn = 1
 add(ships,heart)

 -- star
 local star = create_ship(
  "star",
  3,
  1,12,11,
  {0,15},
  {-1,1},
  10,
  8,
  9
 )
 star.name = "onistar"
 star.icn = 2
 add(ships,star)

 -- diamond
 local dia = create_ship(
  "diamond",
  4,
  1,12,11,
  {},
  {},
  12,
  0,
  3
 )
 dia.name = "tentagem"
 dia.icn = 3
 dia.shield = 1
 add(ships,dia)

 -- comet
 local comet = create_ship(
  "comet",
  5,
  9,8,8,
  {6,9},
  {0,0},
  4,
  12,
  9
 )
 comet.name = "meteoth"
 comet.icn = 4
 comet.shield = 0
 add(ships,comet)
end

-- creates data for a player ship class
function create_ship(t,sp,f1,f2,f3,can,cand,c,a,mlv)
	local s = {}
 s.model = t
 s.sprite = sp
 s.f1 = f1
 s.f2 = f2
 s.f3 = f3
 s.cannons = can
 s.candrif = cand
 s.color = c
 s.exp = 0
	s.lv = 1
	s.ammo = a
	s.shield = 0
	s.mlv = mlv

	s.percent_xp = function()
	 local xp_curve = {15,24,34,45,57,68,80,99,120}--{15,18,24,28,34,45,55,60,90}
	 local prev = 0
	 if s.lv != 1 then
	 	prev = xp_curve[s.lv-1]
	 end

	 return (s.exp-prev)/xp_curve[s.lv]
	end

	s.add_xp = function(xp)
		if s.exp < 200 then
	 	s.exp += xp
	 end
	 if s.percent_xp() then
	 	if s.percent_xp() >= 1 and s.lv < s.mlv then
	  	s.lv += 1
	  	level_up(s.model)
	 	end
	 end
	end

 return s
end

-- stat increases
function level_up(t)
	local icn = 11
	local lt = "hp"

 if t == "base" then
  pl.hp += 1
  pl.maxhp += 1
 end

 if t == "heart" then
  pl.powt +=1
  if pl.powt == 3
  or pl.powt == 6
  or pl.powt == 9 then
   pl.pow +=1
  end
  icn = 12
  lt = "power"
 end

 if t == "star" then
  pl.blastt +=1
  if pl.blastt == 3
  or pl.blastt == 6
  or pl.blastt == 9 then
   pl.blast +=1
  end
  icn = 13
  lt = "blast"
 end

 if t == "diamond" then
  pl.mshield +=1
  pl.shield +=1
  icn = 14
  lt = "shield"
 end

 if t == "comet" then
  pl.turc +=1
  if pl.turc == 5
  or pl.turc == 9
  then
   pl.tur += 1
  end
  icn = 15
  lt = "turret"
 end

 lva_anim(icn,lt)
 psfx('levelup')
end

-- function switch ship
function switch_ship()
 local fcount = count(ship.forms)

 if ship.form < fcount  then
  ship.form += 1
 else
  ship.form = 1
 end

 set_ship(ship.forms[ship.form])
	psfx('switch')
end

-- switches player ship
function set_ship(s)
 for i=1,count(ships),1 do
  ships[i].active = false
  if s == ships[i].model then
   ships[i].active = true
   pl.current = s
   pl.icn = ships[i].icn
  	pl.sprite = ships[i].sprite
  	pl.f1 = ships[i].f1
  	pl.f2 = ships[i].f2
  	pl.f3 = ships[i].f3
  	pl.cannons = ships[i].cannons
  	pl.candrif = ships[i].candrif
   pl.color = ships[i].color
   pl.ammo = ships[i].ammo
   pl.shield = pl.mshield
  end
 end
end

-- draws the player sprite
function draw_pl()
 if not pl.active then
  return
 end
 --adjusts flames
 adjust_engine(pl)

 if is_shake then
  pal(7,8)
  pal(6,8)
  pal(15,8)
 end

 -- draws halfs of ship
 draw_actor(pl)
 pl.right.sprite = pl.sprite
 pl.right.x = pl.x + 8
 pl.right.y = pl.y
 draw_actor(pl.right, true)

 if pl.current == "diamond" and pl.shield > 0 then
  local s = make_actor(16,pl.x,pl.y-4,1,2)
  local sl = make_actor(16,pl.x+8,pl.y-4,1,2)
  draw_actor(s)
  draw_actor(sl,true)
 end

 local turx = {-8,16}
 local turf = {false,true}
 if pl.tur > 0 then
  for i=1,pl.tur,1 do
   spr(32,pl.x+turx[i],pl.y,1,2,turf[i])
  end
 end

 -- resets colors
 pal()
end

-- adjusts player flames
function adjust_engine(a)
	a.flacnt += 1
 if a.flacnt == a.flamax then
 	a.flame = not a.flame
 	a.flacnt = 0
 end
 if a.flame then
 	pal(a.f1,a.f2)
 	pal(a.f3,a.f1)
 else
 	pal(a.f3,a.f2)
 end
end

-- makes an actor and adds it
--  to the global actors array
--  returns actor
function make_actor(s,x,y,w,h)
	local a = {}

	-- draw
	a.sprite = s
	a.x = x
	a.y = y
	a.w = w
	a.h = h

	-- movement
	a.sp = 2

	return a
end

-- makes ship object
function make_pl(s,x,y,w,h)
 local a = make_actor(s,x,y,w,h)

 -- flames
 a.flame = true
 a.flacnt = 0
 a.flamax = 3

 -- player stats
 a.hp = 1
 a.maxhp = 1
 a.rec = 0
 a.pow = 1
 a.powt = 1
 a.blast = 1
 a.blastt = 1
 a.mshield = 0
 a.tur = 0
 a.turc = 1
 a.xtraammo = 0

 -- player states
 a.active = true


	-- methods
	a.shoot = function()
	 if a.ammo + a.xtraammo > count(bullets) then
	 	for i=1,count(pl.cannons),1 do
	 		local b = make_actor(0,a.x+pl.cannons[i],a.y+a.sp,a.blast,2)
	 		b.drift = pl.candrif[i]
	 		b.sp = 5
	 		b.color = pl.color
	 		add(bullets,b)
	 	end
	 	psfx('pshoot')
	 end
	end

	-- take damage
	a.hit = function()
		is_shake = true
		a.hp -= 1

  if a.hp == 0 then
   explode({x=a.x+8,y=a.y+8})
   a.active = false
   game_over()
   psfx('death')
  end
	end

	a.refill_hp = function()
	 if a.maxhp <= a.hp then
	 	a.rec = 0
	 	return
	 end
		if a.rec > 0 then
			a.hp += 1
			a.rec -= 1
		end
	end

	return a
end

-- updates all bullet locations
function update_bullets()
	foreach(bullets, update_bullet)
end
function update_bullet(b)
	b.y -= b.sp
	b.x += b.drift

 if b.y < 0 - b.w then
  if b.turret == true then
   pl.xtraammo -= 1
  end
  del(bullets, b)
 end
end

-- draws all bullets to screen
function draw_bullets()
 foreach(bullets, draw_circ)
end

-- draws enemy attacks
function draw_fire()
 foreach(fire, draw_circ)
end

-- draws a circle from actor
function draw_circ(b)
 circfill(b.x,b.y,b.w,b.color)
end

-- draws a rect from actor
function draw_rect(b)
 rectfill(b.x,b.y,b.x+b.w-1,b.y+b.h-1,b.color)
end

-- draws an actor to stage
function draw_actor(a, flipx)
 spr(a.sprite,a.x,a.y,a.w,a.h,flipx)
end

-- checks if two rects inter
function rect_intersect(r1,r2)
	if  r1.x < r2.x + r2.w
	and r1.x+r1.w > r2.x
	and r1.y < r2.y + r2.h
	and r1.y+r1.h > r2.y then
  return true
 end

 return false
end

--end game
function game_over()
 state = "gameover"
 music(-1)
end


function update_go()
	if go.sx < 45 then
 	go.sx += .5
 else
 	if go.x < 17 then
 		go.x += 1
 	elseif go_confirm then
 	 if go.y < 75 then
  	 go.y += 1
  	 if go.y == 65 then go.color = 6 end
  	 if go.y == 70 then go.color = 5 end
  	end
 	end
 end
end

function draw_go()
	local scx = 15
	local score_text = "score:"..(score*10)
 if go.y < 75 then
 	--print(,scx,go.sx,go.color)
 	print(score_text,(((bnds.w-8)-((#score_text*4-1)))/2)+1,go.sx,go.color)
	 print("game over",go.x,go.y,go.color)
	else
	 reset()
	end
end

--reset game to starting state
function reset()
 _init()
end
__gfx__
0000000000000005000500025000000405500000000000a000111000000000000000005088000088000000000056600000c1ffaa008a4800000ddd00008a0900
000000000000000c000200225000004756650000000000ad0016c1000000000000000051800000080000000000006660cc1873ef000aa00000dd7d00077898a8
0070070000000057000202ef440004aa57750000000005d70001cc1111000000000001d7000aa00000000000056600661f88eef20899998000d7470008777a9a
0007700000000567002f2e2f494449a205500000000005d7111c6c166c100000000001d700aaaa0000000000567665602eeeef20a499994a01cddc1076667778
0007700000050567002d2e2f0477aa275dd5000d0000055dc1c6661111115a5a0000011d000aa0000000000067c766602edef000aa4994aa1ccddcc177a77767
00700700000557c7002d2e2f049aa27c566522dc00005675c1c6676c16666666000011410000000000000000657656600ddeef009aa99aa91cb11bc17a676677
00000000005656c7022e282f00449a2c577502ce00056567616c1116166666660001515f8000000800000000506605600dd222229aa44aa9bccbbccb77676567
0000000005675dcc022e22f200004aa251550def00567567611166c1177677670015f1548800008800000000000000000d000220093003901cb11bcb06775670
0000111105765d1c2f2e222540447aa200b0dcef06777756611166c117767767054f441500000000000000000000000000000000000000000000000000000000
0001ddc7556950552e2d200d049999a20b100dce57766565616c11161666666614f5511100000000000000000000000000000000000000000000000000000000
0117111105980000222d200500444492001000dc56555856c1c6676c166666661511101500000000000000000000000000000000000000000000000000000000
1cc10000008000000d2f20d600055042b10000dc56958959c1c6661111115a5a1105005600000000000000000000000000000000000000000000000000000000
01100000000000000b020d700056d50200b0000d55898858111c6c166c1000001509015100000000000000000000000000000000000000000000000000000000
0000000000000000010200b0000bb000010b0000980895900001cc11110000000500059000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b100000090909800016c100000000000900098000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000001000000000080000111000000000000000080000000000000000000000000000000000000000000000000000000000
00060000001551000090222200444400000880000008800000088000001111000000000000000000000000000000000000000000000000000000000000000000
0005000006c55c6009c5882e04a44a40888dd800088dd880088de880012cc2100000000000000000000000000000000000000000000000000000000000000000
000500006ccddcc60565882e4a9449a40008ed808deeed888dee1688125dd5210000000000000000000000000000000000000000000000000000000000000000
005650000dddddd025d5e8f24a9999a4000087e8ee77eee877e1c10012cddc210000000000000000000000000000000000000000000000000000000000000000
006560005c5dd5c525652e8f4994499400008ee28ee77ee287e1c1001ccddcc10000000000000000000000000000000000000000000000000000000000000000
00565000d566665d2e588222494cc4940008ee2082eeee28822e1e8801cccc100000000000000000000000000000000000000000000000000000000000000000
05d6d500055665502eeffff204c77c40888228000882288008822880001111000000000000000000000000000000000000000000000000000000000000000000
00898000005775002e22222555577555000880000008800000088000000110000000000000000000000000000000000000000000000000000000000000000000
009900000022333302e88f5d00555500000222000075570000000000000000000000000000000000000000000000000000000000000000000000000000000000
00089000027e2bbb02ee8856056d5650022fdd2006a55a6000000000000000000000000000000000000000000000000000000000000000000000000000000000
0089000027ee23332edf88d70d6d565002fd22f06aa77aa600000000000000000000000000000000000000000000000000000000000000000000000000000000
000900002eee2b3b055dffff0d75d6d02fd2ffd20777777000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000800032e2abb35d5585d80d65d6d02d2f25525a5775a500000000000000000000000000000000000000000000000000000000000000000000000000000000
009000000333babad7d556550d6d57502d2f5665a566665a00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000005dddd0d5057520075d70002fd57650556655000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005d670000d75005555550000225770057750000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d00000000000d600000000000007777000000000000777700a00000008077770800000000c077770000b0000000777780a00000000077770000000000000000
6d00000000000d6000000000007711117700000000771111aa00000000781111870000000c671111770c100000771a98a9089000007700007700000000000000
6d00000000000d6000000000071111111170660007c1cddaaa70000007118aa811700000cc11111111c100000711a98998000000070000000070000000000000
6d00000000000d60000000000751111551766060071cceeaa17000000711aaaa11700000bc11ddd1cccc0000071897a877aa8080070000000070000000000000
6d00000000000d6000000000715566566566060071cee77ee11700007111a44a111700007cc1dd751cc100007167777777760000700000000007000000000000
6d00000000000d600000000075577776656706007ceee73eee1700007119aaaa911700007bccd7775c1700007667776777760000700000000007000000000000
6d00000000000d60000000007577c7775657055072ee8eeeed17000078197aa79187000071c27747751700007678787557777000700000000007000000000000
6d00000000000d60000000007557c77d565757d572e88eeed21700007aa999999aa700007112d747dd1706c07667777757776000700000000007000000000000
6d00000000000000dddddddd05d666665650576507deeed221700000079aaaaaa970000007122d7dcd76ccb00667777757776000070000000070000000000000
6d000000000000006666666605dd6665665000000722dd21117000000749aaaa9470000001cc2ddccc7cc11c0767776656776000070000000070000000000000
6d00000000000000000000000055111156500000007722227700000000779999770000000ccc2222cc0cb00007a776a775660000007700007700000000000000
66666666000000000000000000577777050000000000777700000000000077770000000001c077771cccc10000776aa700000000000077770000000000000000
6ddddddd0000000000000000000000000000000000000000000000000000000000000000001b000001bcb00000760a0000000000000000000000000000000000
6d000000000000000000000000000000000000000000000000000000000000000000000000cc000000111000a07a7a0000000000000000000000000000000000
6d00000000000000000000000000000000000000000000000000000000000000000000000cc1bc00000000000a07a66000000000000000000000000000000000
6d000000000000000000000000000000000000000000000000000000000000000000000000c11000000000000000070000000000000000000000000000000000
00000d60000000000000000000d61000ddddddddddddddd07070770077007000000000000000b000000000000000000000000000000000000000000000000000
00000d60000000000000000000d261006666666666666660777076007560700000000000000bbb00000000000000000000000000000000000000000000000000
00000d60000000000000000000dd21106d00000000000d6070757050777577500000000000b0b0b0000000000000000000000000000000000000000000000000
666666606666666600000000066dd6116d00000000000d600000000000000000000000000000b000000000000000000000000000000000000000000000000000
dddddd60dddddddd000000002261d2616d00000000000d600000000000000000000000000000b000000000000000000000000000000000000000000000000000
00000d6000000000000000006221d2216d00000000000d600000000000000000000000000000b000000000000000000000000000000000000000000000000000
00000d60000000006666666605211d216d00000000000d6000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000d6000000000dddddddd005211d16d00000000000d6000000000000000000000000000000000000000000000000000000000000000000000000000000000
007777007000000000004aa4005221116d00000000000d6077070700770700770777000000777700077007700007000000070000008808090000000000000000
07500570707070000000a7a90d6522616d00000000000d607607670076070076076700000757757077e77e77007a7000007c7000094a89980000000000000000
75000057707070000000a7a900d652216d00000000000d60705777507757757757075000757777577eeeeee7079a970007ccc70008a8a4890000000000000000
70000007700700000000a7a905dd65226d00000000000d60000000000000000000000000777777777eeeeee77aaaaa7071ccc170144498980000000000000000
70000007777050000000a7a95dd655526d00000000000d600000000000000000000000007777777772eeee2707aaa7007ccccc70454449800000000000000000
75000057000000000000a7a95ddd66556d00000000000d6000000000000000000000000075677657772ee2777a979a7007ccc700145454800000000000000000
0750057000000000000097a905dddd666666666666666660000000000000000000000000075665700772277079707970007c7000514541000000000000000000
00777700000000000000499455555dddddddddddddddddd000000000000000000000000000777700007777000700070000070000051110000000000000000000
00000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000070007007000000000000000000000000
00000000000000000000000700000000000000000000000000000000000000000000000000000000000000000700007007077070000000000000000000000000
00000000000000000000007709000000000000000000090000000000000000000000000000000700007007000076070000750700000000000000000000000000
0000000000000000000009a709000000000000700000090000000000000000000007000000007000000770000067600077575070000000000000000000000000
0000000000000000000009a709700000000000700000097000000000000000000000700000070000000770000006760007057577000000000000000000000000
0000000000000000000009a709a7000090000770000009a700000000000000000000000000700000007007000070670000705700000000000000000000000000
0000000000000007000009a709aa000097000a70000009a700000000000000000000000000000000000000000700007007077070000000000000000000000000
000000000000007a000009a709aa00009a709a70000009a700000000000000000000000000000000000000000000000070070007000000000000000000000000
00000000000009aa00000aa709aa00009aa09a70000009aa0000000000000000bbbbbbbb0bbbbbb00bb00bb000b00b0000000000000000000000000000000000
00000000000009aa00000aa709aa0000daa09aa0000009aa0000000000000000bbbbbbbbbbbbbbbbbbbbbbbbbb0bb0bbb00bb000000b00000000000000000000
00000000000009aa00000aa709aa000d7da09aa0000009aa0000000000000000bbbbbbbbbbbbbbbb0bbbbbb0000bbb000000b0000000b0000000000000000000
00000000000d09ad0000aaa709aa000d7da09aa00000ddaa0000dd0000000000bbbbbbbbbbb0bbbbbbbb0bbbbbbb0bb00bb00b000b0000000000000000000000
000000000d7d09d7d0aaaaaa09aa00d76da09adddddd76da0ddd77d000000000bbbbbbbbbbbb0bbbbbb0bbbb0bb0bbbb00b00bb000000b000000000000000000
000000000d77dd77daaaa9aa09da00d7daa09d7777776daad777777d00000000bbbbbbbbbbbbbbbb0bbbbbb000bbb000000b0000000b00000000000000000000
000000000d77dd77daadddda0d7d00d7daa0ddddd7ddddddd67d5d7d00000000bbbbbbbbbbbbbbbbbbbbbbbbbb0bb0bb000bb00b000000000000000000000000
00111111d777d777d1d7777d1d76d1d7d11d777dd7dd7776dd75157d11111000bbbbbbbb0bbbbbb00bb00bb000b00b0000000000000000000000000000000000
0000ccccd7d777d7dd7d55d7dd77dcd7dcd7ddd6d7d77dddcd75c56dcccc00000000000000000000000000000000000000000000000000000000000000000000
00000011d7d676d7dd75cc57dd777dd7dd7dcccdd7d57555cd7d5d6d110000000000000000000000000000000000000000000000000000000000000000000000
0000000d76dd6dd77d751157dd7d7dd7d1d7dd11d7d5776d1d77766d000000000000000000000000000000000000000000000000000000000000000000000000
0000000d6d00d9d67d7d55d6dd7d67d6d9d676d0d6d57555dd7d67d0000000000000000000000000000000000000000000000000000000000000000000000000
000000d7d00009ad7dd7666d0d7dd67d995ddd7dd6d577766d7dd67d000000000000000000000000000000000000000000000000000000000000000000000000
000000d7d00009ad7d9dddd90d6d0d6d9d75556dd6d566ddd66d0d67d00000000000000000000000000000000000000000000000000000000000000000000000
00000d76d00009ad66d009aa0d6d0d6d99d6666dd6d0dd990dd000d6d00000000000000000000000000000000000000000000000000000000000000000000000
00000d6d000009aa66d009a70d6d0d6da9adddd0d6d009aa0000000d000000000000000000000000000000000000000000000000000000000000000000000000
000000d0000009aad6d009a709da00d0aaa099a00d0009aa00077000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009a7d6d009aa09aaa000aa709aa0000009aa007aa000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009a70d0009a9099aaaa0aa709aa0000009aa07a99000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009a7000009990099aaaaaa709aa0007709aaaa990000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009aa0000099000099aaaaaa09aa007a909aaa9900000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009aa000009000000999aaaa09aa07a9909aa99000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009a900000000000000999aa09aaaa99009a990000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000999000000000000000999a09aaa9900099900000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000990000000000000000009909aa99000099000000000000000001000000089800000000000001000000100000000000000000000000000000000
0000000000000900000000000000000000909a990000000000000000000000001100000598950000000000001000010100000000000000000000000000000000
00000000000000000000000000000000000099900000000000000000000000001d110055d9d5500100011111c111111c00000000000000000000000000000000
00000000000000000000000000000000000099000000000000000000000000001dcd105d666d5001111cc7cc1c7c71c700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001dccd155d7d5501c7771c7c15ddcc1dc00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000117ccd15666501dcccc71c1c5dddc1dc00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001d177cd5d33333333dcc71c55511115500000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001dd1c7c33337bb73333cc15d6d5cc5ee00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001dcd1c73ffbb33bbff3dc1c565cc5ee700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001dccd1c3fbbb33bbbf3dd1c656dd5efe00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001dc7ed1e3fbb33bbfecedec565e5eff700000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001dcefeefe3f3333fefefefef5ef5ef7e00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001dcefe1ede3f33f3ce1ecece5ce5ef7e00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000016ce1d111373373c71dcc77677c5efe00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000005161d71dd373373dc71dc7ccc75eeee00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000551d7c1d73f33f3ddcc1dddddd5eff700000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000005d61cc1113f33f3111dc111111c5eff00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000056d51c1dc3f33f3ddd117cccc71c5ee00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005d6d5011c33b33b33ccd11111111dd5500000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000056500013fb3bb3bf37c1d1cc1d1dc1100000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000006560003fbb7337bbf371cc11cc1d1d600000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000005650003bb775577bb31cdc77cdc1d6d00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000005000033b35dd53b335dddddddd5dd700000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000500003b3b5dd5b3b335d6776d5056d00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000600033bbf5dd5fbb3300000000005600000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000003b3335665333b300000000005600000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000003bbf77d77d77fbb30000000005600000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000055bff3333ffb5500000000005600000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000005d55b5b33b5355d5000000005d700000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000d7d5565555655d7d000000005d700000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000d505753357505d000000005dd700000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000d750057d00000000000055500000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000006452525252526598989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000005061616161616098989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000004051515151514198989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000007462626262627598989898999999999a9a9a9a9b9b9b9b9c9c9c9c9d9d9d9d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100003c1703d130351503f0003f0003f0000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001d3401f350234702640031400344001710021100271002b1002d1002b100261001f100161001d10022100000000000000000000000000000000000000000000000000000000000000000000000000000
000200000407008070251401a0702207011070112700c070050700207002000010000200001000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000022270192701227022270252000c200172001b200202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001d3301f3700a070244701507026470140700e070060700400001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000171701a1701f1702317026170291702d170301702d1702b1702917026170211701d1701717010170011000f7000b7000a7000c70018100191001b1001d1001f100261003210035100000000000000000
000300001a6771a6773467734646346273460009600086000860008600086000a6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000030671200712c6711d071296711907124671150711f671120711a6610f061176510d051146510a05111641070410e631050310a6310303108621010210562101011026110101101011010120100501600
00030000334713d67119371344713f471064713b471376711237137371053713b6713d66124351226410d631273133f601296002a6001f6002160022601356003460033600366002e60022600146000760002600
000300003077132771347713577137771397713b7713c7713e77128371293712b3712d3712f3713037132371343713537137371393713b3711837118360183501834018330183201831100000000000000000000
0003000022541255512a5612f5712a561081510515103141021210111101001023010130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001f4741d4741f4742147421451214312141521505241062610628106000003010632106341060000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800001f37521375263751f37521375263751f37521375263751f3752137526375293752b375393753247032350324413232132415324003240000000000000000000000000000000000000000000000000000
0001000002071070710b0710f07113071170710766107651076410763107621076110730105201023010120101101003000030000000000000000000000000000000000000000000000000000000000000000000
000900000767713677206772a67732677386773b6673b6673b6573b65739647346472c637256371d6271362706617026070160700000000000000000000000000000000000000000000000000000000000000000
000800001337029371000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01090000130731b0033c003016033e633016030000000000130730000000000000003e633000030000300003130730000300003000033e633000030000300003130730000300003000033e633000030000300003
010900000934009300093400930009340093000934002300023400030002340003000234000300023400030000340003000034000300003400030000340003000734000300073401830007340003000734000300
0109000021340213401f300003001f3401f34000300003001c3401c34000300003001a3401a3401c3401c34000300003001a3401a34000300003001c3401c3401a3401a340003000030015340153400030000300
010900001c3401c34000000000001a3401a34000000000001f3401f34000000000001c3401c3401a3401a34000000000001c3401c34000000000001a3401a3401334013340153401534013340133401534015340
010900000934000000093400000009340000000934000000093400000009340000000934000000093400000007340000000734000000073400000007340000000734000000073400000007340000000734000000
010900000234000000023400000002340000000234000000023400000002340000000234000000023400000002340023000234000000023400000002340000000734007340073400000007340073400734000000
01090000000000000000000000001c3401c34000000000001c3401c34000000000001c3401c3001c3401c34000000000001c3401c34000000000001c340000001c3401c340000001a3001a3401a3400000000000
01090000000000000018300183001834018340000000000018340183400000000000183400000018340183401830000000183401834000000000001834000000183401834000000000001a3401a3400000000000
010900000000000000000000000015340153400c0000c00015340153400c0000c000153400c00015340153400c0000c00015340153400c0000c000153400c000153401534000000000001a3401a3400000000000
01090000130730c0030c0030c0033e6330c0030c0030c003130730c0030c0030c0033e6330c0030c0030c003130730c0030c0030c0033e6330c0030c0030c0033e6330c003130730c0033e6330c003130730c003
01090000130730000000000000003e633000030000300003130730000300003000033e633000030000300003130730000300003000033e6330000300003000033e6333c6033e6333e6333e6331a3003e6333e603
010900000934000000093400000009340000000934000000093400000009340000000934000000093400000009340000000934000000093400000009340000000934000000093400000009340000000934000000
010900000c3400c0000c3400c0000c3400c0000c3400c0000c3400c0000c3400c0000c3400c0000c3400c0000e3400e3000e3400c0000e3400c0000e3400c0000e3400c0000e3400c0000e3400c0000e3400c000
01090000103400c000103400c000103400c000103400c000103400c000103400c000103400c000103400c000103400c000103400c000103400c000103400c000103400c000103400c000103400c000103400c000
010900000934000000093400000009340000000934000000093400000009340000000934000000093400c0000c3400c0000c3400c0000c3400c0000c3400c0000c3400c0000c3400c0000c3400c0000c34000000
010900000934000000093400000009340000000934000000093400000009340000000934000000093400c0000c3400c3400c0000c0000e3400e3400c0000c00010340103400c0000c00013340133400000000000
0109000013340153401a3401c340213402134021340213402134021340213402134021340213401c3401c3401a3401a3401834018340153401534015340153401534015340153401534015340153401534015340
01090000183401a3401c3401f340243402434024340243401a3401c3401f34021340263402634026340263401c3401c34021340213401f3401f34024340243402134021340283402834026340263402b3402b340
010900002834528345283452834528345283452834528345283452834528345283452634024340213401f3401c3401c3401c3401c3401c3401c3401c3401c3401c3401c3401c3401c3401a3401a3401834018340
0109000015340153401534015340153401534015340153401534015340153401534015340153401534015340183401834000000000001a3401a34000000000001c3401c34000000000001f3401f3400000000000
01090000130730000000000000003e633000000000000000130730000000000000003e6330000000000000001307300000000000000013073000000000000000130730000000000000003e633000000000000000
01090000130730c003130030c003130730c003130030c003130730c003130030c003130730c003130030c003130730c003130030c003130730c003130030c003130730c0031300300603130731a0003e6030c003
01090000130730c0030c0030c003130730c0030c0030c003130730c0030c0030c003130730c0030c0030c003130730c0030c0030c003130730c0030c0030c003130730c0033e6030c0033e6330c0030c00000000
01090000130730c0030c0030c0033e6330c003130730c0030c0030c00300003000033e6330c0030c0030c003130730c0030c0030c0033e6330c0030c0030c003130730c0030c0030c0033e6330c0030c0030c003
01090000130733c0030c0030c0033e6330c0033e6330c003130030c003130730e0033e6330c0030c0030c003130730c0030c0030c0033e6330c0033e6330c0033e6033c603130733c6033e6333c6033e6033c003
01090000130730c003130730c003130730c003130730c0033e6330c003130730c003130730c003130730c003130730c003130730c003130730c003130730c0033e6330c003130730c003130730c003130730c003
01090000130730c003130730c003130730c003130730c0033e6330c003130730c003130730c003130730c0031307313003130730c003130730c003130730c0033e6330c0033e6333c6033e6333c6033e6330c003
010900000934009340093400934009340093400c3400c3400c3400c3400c3400c3400834008340083400030009340093400030000300093400934009340003000c3400c3400c3400c34008340083400030000300
010900000934009340093400934009340093400c3400c3400c3400c3400c3400c3400834008340083400030007340073400030000300073400734007340003000734007340073400734008340083400030000300
01090000103401034010340103401034010340103401034010340103401034010340103401034010340103400f3400f3400f3400f3400f3400f3400f3400f3400f3400f3400f3400f3400f3400f3400f3400f340
010900000934009340093000000009340093400930000000093400934009300000000934009340093000000009340093400930000000093400934009300000000934009340093000000009340093400830000000
010900000934009340000000000009340093400000000000093400934000000000000934009340000000000008340083400000000000083400834000000000000834008340000000000008340083400000000000
010900000934009345153401534509340093451834018345093400934515340153450934009345143401434509340093451534015345093400934518340183450934009345153401534509340093451434014345
01090000093400934015340153400934009340183401834009340093401534015340093400934013340133400834008340143401434008340083401a3401a3400834008340143401434008340083401834018340
01090000213401800021340180001f340180001f3401800021300180002134018000213401800021340180001f340180001f34018000213402130021340180001f340180001f3401800021340213002134018000
01090000213400000021340000001f340000001f3400000000000000002134021300213402130021340000001f340000002134021340213400000024340243402434024000263402634026340263400000000000
01090000283402400028340240002434024000243402400028340240002834024000243402400024340240002b340240002b34024000283402400028340240002b340240002b3402400028340240002834024000
010900002834024000243402400028340240002434024000283402400024340240002834024000243402400028340240002434024000283402400024340240002834024000243402400028340240002434024000
010900002834024000243402400028340240002434024000283402400024340240002834024000243402400028340240002634024000283402400026340240002834024000263402400028340240002634024000
01090000283402400027340240002434018000213402400027340240002634024000243401800020340240002634024000213401800020340180001c340180002134018000203400c00028340283402834028340
010900002834027340243402134028340273402434021340283402734024340213402834027340243402134028340273402434021340283402734024340213402834027340243402134028340273402434021340
010900002834027340243402134028340273402434021340283402734024340213402834027340243402134028340273402634020340283402734026340203402834027340263402034028340273402634020340
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 19 11 12 44
00 10 11 13 44
00 19 11 12 44
00 09 42 43 44
01 10 11 12 44
00 10 11 13 44
00 10 11 12 44
00 19 11 13 44
00 10 14 16 44
00 19 15 17 44
00 10 14 17 44
00 19 15 18 44
00 10 14 16 44
00 19 15 17 44
00 10 14 17 44
00 1a 15 18 44
00 10 1b 43 44
00 10 1c 43 44
00 10 1d 43 44
00 10 1e 43 44
00 10 1b 20 44
00 10 1c 21 44
00 10 1d 22 44
02 24 1f 23 44
01 3a 42 43 44
00 25 2b 43 44
00 25 2c 43 44
00 25 2b 43 44
00 26 2d 43 44
01 27 2b 32 44
00 27 2c 33 44
00 27 2b 32 44
00 28 2d 34 44
00 25 2e 35 44
00 25 2f 36 44
00 25 2e 35 44
00 26 2f 37 44
00 29 30 38 44
00 2a 31 39 44
00 29 30 38 44
02 2a 31 39 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
