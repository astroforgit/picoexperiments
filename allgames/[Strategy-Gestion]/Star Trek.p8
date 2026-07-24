pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- star trek p8
-- by emanuele bolognesi
-- port of the 1978 super star trek game written
-- in basic by bob leedom / david ahl

------------------------------
function math_random(a,b)
	a = a or 1
	b = b or 8
	return flr(rnd(b-a)+a+0.5)
end

function localtoglobalcoord(sx,sy,x,y)
	return (sx-1)*8+x, (sy-1)*8+y
end

function sectorfromglobalcx(gx,gy)
	if gx<0.5 or gx>64.5 or gy<0.5 or gy>64.5 then return 0,0 end
	return flr((gx-0.5)/8+1),flr((gy-0.5)/8+1)
end

function sectornumberfromglobalcx(gx,gy)
	local sx,sy = sectorfromglobalcx(gx,gy)
	if sx == 0 or sy == 0 then return 0 end
	return (sx-1)*8+sy
end

function globaltolocalcoord(gx,gy)
	local sx,sy = sectorfromglobalcx(gx,gy)
	local lx = flr(gx+0.5) % 8
	local ly = flr(gy+0.5) % 8
	if lx == 0 then lx = 8 end
	if ly == 0 then ly = 8 end
	return lx,ly,sx,sy
end

function mapcell(gx,gy)
	-- for historical reason, gx = row, gy = col
	return globalmap[flr(gx+0.5)][flr(gy+0.5)]
end

function updatemapcell(gx,gy,element)
	globalmap[flr(gx+0.5)][flr(gy+0.5)] = element
end

function foundstarbaseincell(x,y)
	if mapcell(x,y)>9 and mapcell(x,y)<100 then return true
	else return false end
end

function foundklingonincell(x,y)
	if mapcell(x,y)>99 and mapcell(x,y)<1000 then return true
	else return false end
end

function foundstarincell(x,y)
	if mapcell(x,y)>999 then return true
	else return false end
end

function foundenterpriseincell(x,y)
	if mapcell(x,y) == 1 then return true
	else return false end
end

-- place the object in a random free location of the sector specified
function placeelementinsector(sector_row,sector_col,element)
	local row,col = 0,0
	repeat 
		local rx,ry = math_random(),math_random()
		row,col = localtoglobalcoord(sector_row,sector_col,rx,ry)
	until globalmap[row][col] == 0
	globalmap[row][col] = element
	return row,col
end

-- trasform the value into an element on the screen
function getelementofmap(x,y)
	if foundenterpriseincell(x,y) then return 1
	elseif foundstarbaseincell(x,y) then return 4
	elseif foundklingonincell(x,y) then return 3
	elseif foundstarincell(x,y) then return 2
	else return 0
	end
end

-- perform a scan of current sector
function currentsectorscan(row,col)
	sector.k3,sector.b3,sector.s3 = 0,0,0
	for i=(row-1)*8+1,row*8 do
		for j=(col-1)*8+1,col*8 do
			local elem = globalmap[i][j]
			if foundstarbaseincell(i,j) then
				sector.b3+=1
				sector.currentbase = elem-10
			elseif foundklingonincell(i,j) then
				sector.k3+=1
				add(enemyships,elem-100)	-- add the ship data to the current sector enemies array
			elseif foundstarincell(i,j) then
				sector.s3+=1
			end
		end
	end
end

-- returns the string kbs (klingons+stabases+stars) for selected sector
function sectorrecord(row,col)
	local kk,bb,ss = 0,0,0
	for i=(row-1)*8+1,row*8 do
		for j=(col-1)*8+1,col*8 do
			local elem = globalmap[i][j]
			if foundstarbaseincell(i,j) then
				bb=bb+1
			elseif foundklingonincell(i,j) then
				kk=kk+1
			elseif foundstarincell(i,j) then
				ss=ss+1
			end
		end
	end
	return kk*100+bb*10+ss
end

-- names utilities ===========================================================

function read_captain_name()
	local cap1,cap2,cap3,cap4 = peek(0x5e00),peek(0x5e01),peek(0x5e02),peek(0x5e03)
	if cap1>96 and cap2>96 and cap3>96 and cap4>96 then
		return chr(cap1)..chr(cap2)..chr(cap3)..chr(cap4)
	end
	return ''
end

function generate_captain_name()
	local cap1,cap2,cap3,cap4 =flr(rnd(26))+97,flr(rnd(26))+97,flr(rnd(26))+97,flr(rnd(26))+97
	while cap2 !=97 and cap2 !=101 and cap2 !=105 and cap2 !=111 and cap2 !=117 do
		cap2 =flr(rnd(26))+97
	end
	game.captain = chr(cap1)..chr(cap2)..chr(cap3)..chr(cap4)

	poke(0x5e00,cap1)
	poke(0x5e01,cap2)
	poke(0x5e02,cap3)
	poke(0x5e03,cap4)
end


function getquadrantname(x,y)
	return 'sector '..x..','..y
end

-- math functions to calculate distance and direction ==================

function distance_calc(x1,y1,x2,y2)
	local dx,dy = x1-x2,y1-y2
	return sqrt(dx^2 + dy^2)
end

-- main commands of the game =======================================

function generate_galaxy_and_objects()

	exploredspace = {{},{},{},{},{},{},{},{}} -- a copy of galaxy, but only with sectors explored/scanned

	-- initialize global map (coordinates of all the 64 sectors)
	for i=1,64 do
		globalmap[i] = {}
		for j=1,64 do
			globalmap[i][j] =0
		end
	end
	
	local galaxy = {{},{},{},{},{},{},{},{}} -- used only during generation of map

	for i=1,8 do
		for j=1,8 do
			local numofstars = math_random(1,game.maxstars)
			exploredspace[i][j],galaxy[i][j]=0,0  -- hidden
			for s=1,numofstars do
				local xx,yy = placeelementinsector(i,j,1001)	-- place a star in random coordinates of sector
			end
		end
	end

-- place and create starbases
	local addedbases =0
	while addedbases<game.totalbases do
		local x,y=math_random(),math_random()
		if galaxy[x][y] < 10 then					-- only if there are no starbases
			addedbases = addedbases+1
			galaxy[x][y]= galaxy[x][y] + 10
			local bx,by = placeelementinsector(x,y,10+addedbases)	-- place a starbase in random coordinates of sector

			local basename,baseenergy = "starbase "..addedbases,math_random(9000,15000)
			allstarbases[addedbases] = {x=bx,y=by,name=basename,energy=baseenergy}
		end
	end

	-- place klingons
	local addedklingons =0
	while addedklingons<game.totalklingons do
		local x,y=math_random(),math_random()
		if galaxy[x][y] < 100 then					-- only if there are no klingons in this sector
			r1=math_random(1,20)
			local fleetsize = 1
			if r1>18 then
				fleetsize = 3
			elseif r1>15 then
				fleetsize = 2
			end
			if addedklingons + fleetsize > game.totalklingons then
				fleetsize = game.totalklingons - addedklingons
			end
			galaxy[x][y]= galaxy[x][y] + fleetsize*100
			
			for k=1,fleetsize do
				addedklingons = addedklingons+1
				local kv,kh = placeelementinsector(x,y,100+addedklingons)	-- place a klingon in random coordinates of sector
				local kenergy = game.klingonpower*(0.5+rnd(1))
				add(allklingons,{v=kv,h=kh,energy=kenergy,maxenergy=kenergy})
			end
		end	
	end
end

-----------------------------------
-- common

function increment_msg_string()
	local msg = gui.messages[#gui.messages]
	if msg.len < #msg.txt then msg.len +=1 end
end

function set_message_lines(len)
	if len<gui.maxmsg then
		local oldlen = #gui.messages
		for i=0,len-1 do
			gui.messages[len-i] = gui.messages[gui.maxmsg-i]
		end
		for i=len,gui.maxmsg-1 do
			gui.messages[i+1] = nil
		end
	end
	gui.maxmsg = len
end

function add_new_message(text,color)
	if #gui.messages == gui.maxmsg then
		for i=2,gui.maxmsg do
			gui.messages[i-1] = gui.messages[i]
		end
		gui.messages[gui.maxmsg] = nil
	end
	add(gui.messages,{txt=text,col=color,len=1})
end

function clean_bottom_bar()
	rectfill(0,119,127,127,1)
end

function show_press_key(double)
	clean_bottom_bar()
	if double then
		print ("Ž to confim  — to cancel",10,121,13)
	else 
		print ("press Ž to continue",25,121,13)
	end
end

function sleep(s)
	for i=1,s*30 do
		increment_msg_string()
		draw_messages()
		flip()
	end
end

--====================================
-- init ------------------------------
function generate_new_game()
	-- init date
	music(-1)
	game.date = 5943+math_random(1,1000) -- stardate 5943 is the date of the last episode, the game starts after tos
	game.t0 = game.date
	
	-- generate no of bases and enemies
	game.totalbases=math_random(5,6)-game.difficulty
	game.totalklingons=game.difficulty+10+math_random(game.difficulty*3,game.difficulty*6)
	game.maxdays = game.totalklingons + (2-game.difficulty)*math_random(3,9)+ math_random(4,7)
	game.klingonpower = game.klingonpower * 1+(game.difficulty/10*2)
	
	-- init enterprise object
	ent.energy = game.maxenergy
	ent.torpedoes=game.maxtorpedoes
	ent.shields=0
	ent.condition = 'green'
	ent.isdocked = false
	
	allklingons = {}
	allstarbases = {}
	globalmap = {}
	ent.damage =  {}

	-- reset devices damage
	for i=1,#devicenames do
		ent.damage[i] = 100
	end
	
	-- init galaxy
	generate_galaxy_and_objects()
		
	ent.sy,ent.sx = math_random(),math_random()	-- initial sector of the enterprise
	prev_q1,prev_q2 = 0,0						-- previous position of enterprise
	ent.row,ent.col = placeelementinsector(ent.sy,ent.sx,1)
	ent.ly,ent.lx,q1b,q2b = globaltolocalcoord(ent.row,ent.col)
	
	game.initklingons=game.totalklingons

	-- init gui
	gui.command,gui.maxmsg = 1,3
	gui.messages = {}
	
	-- check if an old captain is in memory
	game.captain = read_captain_name()
	
	if game.captain == '' then
		generate_captain_name()
		gui.messages[1] = {txt="welcome, captain "..game.captain..'!',col=12,len=1}
	else
		gui.messages[1] = {txt="welcome back, captain "..game.captain,col=11,len=1}
	end

	-- init particles
	particles={}
	for i=1,100 do
	add(particles, {x=0,y=0,velx=0,vely=0,r=0,r_i=0,alive=false})
	end
end


function _init()
	ent = {}
	-- game settings
	game.difficulty = 3 -- number between 1 (very easy) and 4 (very hard)
	game.maxenergy = 3000	-- enterprise max energy
	game.maxtorpedoes=10
	game.klingonpower=160	-- klingon ship energy range from 0.5x to 1.5x this value
	game.maxstars = 7
	
	cartdata("emabolo_startrek_1")
	--for i=1,120 do flip() end
	
	menuitem(1, " new captain", function() dset(0,0) dset(1,0) generate_new_game() changestate_titlescreen() end)
	menuitem(2, " less difficult", function() if game.difficulty>1 then game.difficulty-=1 generate_new_game() changestate_titlescreen() end end)
	menuitem(3, " more difficult", function() if game.difficulty<4 then game.difficulty+=1 generate_new_game() changestate_titlescreen() end end)
	-- devices names
	devicenames = {"warp engines","short range sensors","long range sensors","phaser control","photon tubes","docking port","shields control","library computer"}

	-- gui settings
	gui.maxbarsize = 124
	gui.barx,gui.bary = 2,7*14+7
	gui.commands = {'imp','wrp','lrs','she','pha','tor','dam','dck'}
	gui.description = {'impulse speed','warp speed / map','long-range sensor scan','shields control','phasers control','photon torpedoes','damage control','docking procedures'}
	
	-- sprites, starfield and particles
	p_colors = {5,6,7,10,9,5}
	ent.sprites = {1,22,18,23,19,21,17,20}
	
	sf = {
		stars={},
		starcount=128,
		maxd=150
	}

	generate_new_game()
	changestate_startscreen()
end

--====================================
-- state: state wait button   -------

function changestate_wait_button()
	game.upd=wait_button_update
	game.drw=wait_button_draw
end

function wait_button_update()
	increment_msg_string()
	if btnp(4) then
		changestate_mainscreen()
	end
end

function wait_button_draw()
	draw_messages()
	show_press_key()
end

---- time advancement -------------------

function time_advances(days)
	game.date = game.date+days
	for i=1,8 do
		if ent.damage[i]<76 and rnd()>.7 then
			local fixed = flr((100-ent.damage[i])*0.2)
			ent.damage[i] = ent.damage[i]+fixed
			add_new_message("improved "..devicenames[i] ..' status',15)
			break
		elseif ent.damage[i]>75 and rnd()>.9 then
			local randomdamage = flr(rnd(game.difficulty*10))
			ent.damage[i] = ent.damage[i]-randomdamage
			add_new_message(devicenames[i]..' damaged',15)
			break
		end
	end
end

-----------------------------------------
function changestate_popup()
	game.upd=popup_update
	game.drw=popup_draw
end

function popup_update()
	if btnp(4) then
		game.nextstate()
	end
end

function popup_draw()
	rectfill(6,45,122,64,14)
	print(game.popuptext,10,52,7)
	if game.popuptext2 then
		rectfill(6,64,122,72,14)
		print(game.popuptext2,10,60,7)
	end
	show_press_key()
end

--=============================================
-- particle effects

function changestate_ship_exploded(x,y)
	game.delay = 40
 	game.upd=ship_exploded_upd
	game.drw=ship_exploded_drw
	for part in all(particles) do
		part.alive = false
	end
	sfx(1)
	particle_explode(x,y,5,80)
end

function ship_exploded_upd()
	increment_msg_string()
 for part in all(particles) do
  if part.alive then
   part.x += part.velx / part.mass*2
   part.y += part.vely / part.mass
   part.r -= 0.1
   if (part.r < 0.1) part.alive = false
  end
 end
 game.delay-=1
 if (game.delay<1) game.nextstate()
end

function ship_exploded_drw()
 draw_sectorscreen()
 clean_bottom_bar()
 for part in all(particles) do
  if part.alive then
   local fraction_of_r = part.r_i / #p_colors
   local p_color = flr(part.r * fraction_of_r)+1
   if (part.x>1 and part.x<16*4+3 and part.y>6 and part.y<9*7+2) pset(part.x,part.y,p_colors[p_color])
  end
 end
end

function particle_explode(x,y,r,num_particles)
 local p_count = 0
 for part in all(particles) do
  if not part.alive then
   part.x,part.y = x,y
   part.velx,part.vely = -1 + rnd(2),-1 + rnd(2)
   part.mass,part.r = 0.5 + rnd(2),0.5 + rnd(r)
   part.r_i = part.r
   part.alive = true

   p_count += 1
   if p_count == num_particles then
    break
   end
  end
 end
end

--====================================
-- state: game_lost   -------

function changestate_game_lost(message)
	game.delay = 120
	if (message != nil) game.endmessage = message
	game.upd=game_lost_update
	game.drw=game_lost_draw
end

function game_lost_update()
	if game.delay>0 then 
		game.delay-=1
	end
	if btnp(4) then
		if game.delay>0 then game.delay=0
		else 
			generate_new_game()
			changestate_titlescreen()
		end
	end
end

function game_lost_draw()
	if game.delay==0 then cls(0) end
	if game.delay<90 then
		rectfill(6,45,122,83,5)
		print(game.endmessage,10,52,7)
		print("sir, we failed our mission",10,60,7)
		print("the federation is lost",10,68,15)
	end
	if game.delay==0 then
		print("thank you for playing",(128-21*4)/2,104,11)
		print("press Ž to try again",(128-21*4)/2,112,13)
	end
end

--====================================
-- state: game_won   -------

function changestate_game_won()
	game.delay = 240
	game.score = game.initklingons*100+(game.maxdays+game.t0 - game.date)*550-game.totalbases*100+ent.energy+ent.shields+ent.torpedoes*20
	game.score = flr(game.score * (1+(game.difficulty-1)*2/10))
	game.hiscore = dget(1)
	if game.score > game.hiscore then
		dset(1,game.score)
		game.hiscore = game.score
	end
	print_cover()

	game.upd=game_won_update
	game.drw=game_won_draw
end

function game_won_update()
	if game.delay>0 then 
		game.delay-=1
	end
	if btnp(4) then
		if game.delay>0 then game.delay=0
		else 
			generate_new_game()
			changestate_titlescreen()
		end
	end
end

function game_won_draw()
	print("congratulations, captain!",(128-25*4)/2,68,7)
	print("you saved the federation",(128-24*4)/2,76,7)
	local strscore = "final score: "..tostring(game.score)
	print(strscore,(128-#strscore*4)/2,88,10)
	if game.hiscore == game.score then
		print("this is your new hi-score!",(128-26*4)/2,96,11)
	else
		print("your best score is: "..game.hiscore,(128-25*4)/2,96,12)
	end
	
	if game.delay==0 then
		print("thank you for playing",(128-21*4)/2,110,7)
		print("press Ž to try again",(128-21*4)/2,118,13)
	end


end


--====================================
-- state: klingons_attack   -------------

function changestate_klingons_attack()
	game.upd=klingons_attack_update
	game.drw=klingons_attack_draw
end

function klingons_attack_update()
	increment_msg_string()
	local distance = distance_calc(allklingons[k].v,allklingons[k].h,ent.row,ent.col)
	local hits=flr((klingon_energy/distance)*(rnd()+2))+1	-- klingon is firing with all its energy

	ent.shields = ent.shields - hits

	allklingons[k].energy = klingon_energy/(3+rnd()) -- clearly this must be improved
	
	local kv,kh,ksx,ksy = globaltolocalcoord(allklingons[k].v,allklingons[k].h)
	local cols = {3,11,7,3,11,7,3,11,7}
	for i=1,#cols do
		draw_laser(kh,kv,ent.lx,ent.ly,cols[i])
		sleep(0.15)
	end
	draw_sectorscreen() -- to remove laser
	
	if ent.shields < 0 then
		add_new_message("direct hit! shields are down",8)
		draw_messages()
		game.endmessage = "enterprise destroyed!"
		
		game.nextstate=changestate_game_lost
		updatemapcell(ent.row,ent.col,0)
		changestate_ship_exploded((ent.lx-1)*8+5,ent.ly*7+4)
		return false
	end
	
	add_new_message("direct hit! shields at "..tostring(flr(ent.shields/ent.initialshields*100+.5))..' %',8)
		
	if hits>10 and rnd() < hits/120 and (ent.shields==0 or hits/ent.shields > 0.05) then
		local sysdamaged=math_random()
		local damage =  flr((game.difficulty+1)*20*(hits/ent.shields)+rnd(10))
		if damage > ent.damage[sysdamaged] then damage = ent.damage[sysdamaged] end
		ent.damage[sysdamaged]= ent.damage[sysdamaged] - damage
		add_new_message("damage to "..devicenames[sysdamaged],9)
		sleep(1)
	end
	
	klingon_attacking+=1

	if klingon_attacking > #enemyships then
		game.nextstate()
	else
		changestate_klingons_hold()
	end
end

function klingons_attack_draw()
	draw_messages()
	clean_bottom_bar()
end


-- state: klingons_hold   -------------
-- temporary state, used before/after fire to avoid repetition

function changestate_klingons_hold()
	k = enemyships[klingon_attacking]
	klingon_energy = allklingons[k].energy
	
	while klingon_energy == 0 and klingon_attacking<#enemyships do
		klingon_attacking+=1
		k = enemyships[klingon_attacking]
		klingon_energy = allklingons[k].energy
	end

	if klingon_energy>0 then
		add_new_message("klingon vessel "..klingon_attacking.." is firing",6)
	end
	game.upd=klingons_hold_update
	game.drw=klingons_hold_draw
end

function klingons_hold_update()
	increment_msg_string()
	if klingon_energy == 0 then
		game.nextstate()
	elseif btnp(4) then
		changestate_klingons_attack()
	end
end

function klingons_hold_draw()
	draw_maindata()
	draw_sectorscreen()
	show_press_key()
end

--====================================
-- state: docking   ------------------

function dock_is_possible()
	local ispossible = false
	
	for i=ent.row-1,ent.row+1 do
		for j=ent.col-1,ent.col+1 do
			local checkingsector = sectornumberfromglobalcx(i,j)	-- 0 if outside borders
			if sectornumberfromglobalcx(ent.row,ent.col) == checkingsector and foundstarbaseincell(i,j) then
				ispossible = true
				break
			end
		end
	end
	return ispossible
end

function changestate_docking()
	if sector.b3<1 then
		add_new_message("no starbases in this sector",4)
		changestate_mainscreen()
		return false
	elseif ent.damage[6]<25 then
		add_new_message("docking port is damaged, sir",4)
		changestate_mainscreen()
		return false
	elseif sector.k3>0 then
		add_new_message("ship cannot dock during attack",4)
		changestate_mainscreen()
		return false
	elseif dock_is_possible() == false then
		add_new_message("starbase still too far, sir",4)
		changestate_mainscreen()
		return false
	end
	game.upd=docking_update
	game.drw=docking_draw

end

function docking_update()
	ent.isdocked=true
	ent.energy,ent.torpedoes=game.maxenergy,game.maxtorpedoes
	ent.shields=0
	increment_msg_string()
	for i=1,8 do ent.damage[i]=100 end		-- temporary!!!!
	
	if btnp(4) then
		changestate_mainscreen()
	end
	
end

function docking_draw()
	game.popuptext = 'welcome to starbase, captain'
	game.popuptext2 = 'resupply is in progress.'
	popup_draw()
end

--====================================
-- state: torpedoes_load   -------

function changestate_torpedo_fire()
	torp.distance = 5
	torp.row,torp.col = ent.row,ent.col
	torp.step = 0
	game.upd=torpedo_fire_update
	game.drw=torpedo_fire_draw
end

function torpedo_fire_update()
	increment_msg_string()
	local torpedo_stop,kling_exploded = false,false
	torp.distance += 1.5
	torp.dx = torp.cx+cos(torp.angle)*torp.distance
	torp.dy = torp.cy+sin(torp.angle)*torp.distance*(7/8)
	torp.row = ent.row + sin(torp.angle)*(torp.distance/8)
	torp.col = ent.col + cos(torp.angle)*(torp.distance/8)
	
	if torp.row<1 or torp.row>64 or torp.col<1 or torp.col>64 or torp.dx<1 or torp.dy<7 or torp.dx>66 or torp.dy>64 then
		torpedo_stop = true
	elseif foundklingonincell(torp.row,torp.col) then
		add_new_message("klingon warship destroyed!",8)
		klingon_ship_destroyed(mapcell(torp.row,torp.col)-100)
		kling_exploded = true
	elseif foundstarbaseincell(torp.row,torp.col) then
		add_new_message("we destroyed a starbase!",14)
		updatemapcell(torp.row,torp.col,0)
		sector.b3=sector.b3-1
		exploredspace[ent.sy][ent.sx]=exploredspace[ent.sy][ent.sx]-10
		torpedo_stop = true
	elseif foundstarincell(torp.row,torp.col) then
		add_new_message("star absorbed torpedo energy",14)
		torpedo_stop = true
	else
		torp.step+=1
	end
	
	if kling_exploded then
		game.nextstate = changestate_after_explosion
		changestate_ship_exploded(torp.dx,torp.dy)
		
	elseif torpedo_stop then
		klingon_attacking = 1
		ent.initialshields = ent.shields
		game.nextstate = changestate_mainscreen
		changestate_klingons_hold()
	end
end

function torpedo_fire_draw()
	draw_sectorscreen()
	spr(5,torp.dx-4, torp.dy-3)
end

--- after klingon explosion --------------

function changestate_after_explosion()
	game.upd=after_explosion_update
	game.drw=after_explosion_draw
end

function after_explosion_update()
	if game.totalklingons < 1 then
		sleep(1)
		changestate_game_won()
	elseif sector.k3 == 0 then
		changestate_mainscreen()
	else
		klingon_attacking = 1	-- codice doppio - ugly
		ent.initialshields = ent.shields
		game.nextstate = changestate_mainscreen
		changestate_klingons_hold()
	end
end

function after_explosion_draw()
--
end

--====================================
-- state: torpedoes_load   -------

function changestate_torpedoes_load()
	torp =  {}
	if ent.damage[5]<25 then
		add_new_message("torpedoes are inoperative, sir",4)
		changestate_mainscreen()
		return false
	elseif sector.k3<1 then
		add_new_message("no enemy ships in this sector",4)
		changestate_mainscreen()
		return false
	elseif ent.torpedoes < 1 then
		add_new_message("all torpedoes fired, sir",4)
		changestate_mainscreen()
		return false
	end
	
	torp.cx,torp.cy = (ent.lx - 1)*8+5,ent.ly*7+4
	torp.course,torp.angle = 10,0
	torp.dx,torp.dy,torp.dx2,torp.dy2 = 0,0,0,0 -- to avoid null
	
	game.upd=torpedoes_load_update
	game.drw=torpedoes_load_draw
end

function torpedoes_load_update()
	increment_msg_string()
	torp.angle = (torp.course-10) / 80
	torp.dx = torp.cx+cos(torp.angle)*5
	torp.dx2 = torp.cx+cos(torp.angle)*10
	torp.dy = torp.cy+sin(torp.angle)*5
	torp.dy2 = torp.cy+sin(torp.angle)*8.75
	
	if (torp.dx<0) torp.dx = 0
	
	if btn(1) and torp.course > 10 then
		torp.course-=1
	elseif btn(1) and torp.course == 10 then
		torp.course = 89
	elseif btn(0) and torp.course < 89 then
		torp.course+=1
	elseif btn(0) and torp.course == 89 then
		torp.course = 10
	elseif btnp(4) then
		ent.torpedoes-=1
		add_new_message("torpedo fired!",9)
		draw_messages()
		changestate_torpedo_fire()
	elseif btnp(5) then
		changestate_mainscreen()
	end
end

function torpedoes_load_draw()
	draw_sectorscreen()
	if (torp.dx>1 and torp.dx<67 and torp.dy>6 and torp.dy<65) pset(torp.dx, torp.dy, 12)
	if (torp.dx2>1 and torp.dx2<67 and torp.dy2>6 and torp.dy2<65) pset(torp.dx2, torp.dy2, 12)
	rectfill(0,7*14-1,127,127,1)
	print("torpedo course: "..torp.course/10,2,7*14,6)
	show_press_key(true)
end

--====================================
-- state: phasers_fire   -------------
-- this will be run for every enemy ship

function draw_laser(x1,y1,x2,y2,col)
	line((x1-1)*8+5,y1*7+4,(x2-1)*8+5,y2*7+4,col)
end

function klingon_ship_destroyed(k)
	allklingons[k].energy = 0
	updatemapcell(allklingons[k].v,allklingons[k].h,0)
	game.totalklingons=game.totalklingons-1
	sector.k3=sector.k3-1
	exploredspace[ent.sy][ent.sx]=exploredspace[ent.sy][ent.sx]-100
end

function changestate_phasers_fire()
	game.upd=phasers_fire_update
	game.drw=phasers_fire_draw
end

function phasers_fire_update()
	increment_msg_string()
	local k = enemyships[ships_to_attack]
	local klingon_energy = allklingons[k].energy
	if klingon_energy == 0 then stop("kling energy cant be 0 here") end
	local distance = distance_calc(allklingons[k].v,allklingons[k].h,ent.row,ent.col)
	local hitpoints=flr((phasers_hit/distance)*(rnd()+2))
	local kv,kh,ksx,ksy = globaltolocalcoord(allklingons[k].v,allklingons[k].h)
	add_new_message("fire to enemy "..enemy_targeted.." at "..kv..','..kh,7)
	draw_messages()
	local cols = {13,12,7,13,12,7,13,12,7}
	for i=1,#cols do
		draw_laser(ent.lx,ent.ly,kh,kv,cols[i])
		sleep(0.15)
	end
	
	if hitpoints <= (.15*klingon_energy) then
		add_new_message("phasers ineffectual, sir.",15)
		hitpoints = 0
	else
		klingon_energy=klingon_energy-hitpoints
		add_new_message("direct hit! enemy damage: "..hitpoints,9)
	end
	draw_sectorscreen()

	if klingon_energy > 0 then
		add_new_message("enemy shields at "..tostring(flr(klingon_energy/allklingons[k].maxenergy*100+.98))..' %',12)
		allklingons[k].energy = klingon_energy
		sleep(0.7)
		changestate_phaser_iteration()
	else
		add_new_message("klingon warship destroyed!",8)
		klingon_ship_destroyed(k)
		update_shipstatus()
		game.nextstate=changestate_phaser_iteration
		changestate_ship_exploded((kh-1)*8+5,kv*7+4)
	end
end

function phasers_fire_draw()
	-- most of drawing is done in update, to allow delays
	clean_bottom_bar()
end

-- state: phaser_iteration   -------------


function changestate_phaser_iteration()
	game.upd=phaser_iteration_update
	game.drw=phaser_iteration_draw
end

function phaser_iteration_update()
	increment_msg_string()
	ships_to_attack = ships_to_attack -1
	enemy_targeted = enemy_targeted +1

	-- check if game.totalklingons == 0 the game is won
	if ships_to_attack>0 then
		-- the enterprise can fire again
		changestate_phasers_hold()
	elseif game.totalklingons < 1 then
		-- game won
		sleep(1)
		changestate_game_won()
	elseif sector.k3 == 0 then
		-- if sector has no more klingons
		changestate_wait_button()
	elseif ent.isdocked then
		add_new_message('klingons attacking but we are',14)
		add_new_message("protected by starbase shields",14)
		changestate_mainscreen()
	else
		klingon_attacking = 1
		ent.initialshields = ent.shields
		game.nextstate = changestate_mainscreen
		changestate_klingons_hold()
	end
end

function phaser_iteration_draw()
	draw_sectorscreen()
end


-- state: phasers_hold   -------------
-- temporary state, used before/after fire to avoid repetition

function changestate_phasers_hold()
	if enemy_targeted == 1 then add_new_message("ready to fire, sir",6) end
	game.upd=phasers_hold_update
	game.drw=phasers_hold_draw
end

function phasers_hold_update()
	increment_msg_string()
	if btnp(4) then
		changestate_phasers_fire()
	end
end

function phasers_hold_draw()
	draw_maindata()
	draw_sectorscreen()
	show_press_key()
end

--====================================
-- state: phasers_load   -------------

function phaser_prepare_attack()
	ships_to_attack = sector.k3
	if phaser_energy>ent.energy or ships_to_attack == 0 then stop("this should not happen") end
	ent.energy = ent.energy - phaser_energy
		
	if ent.damage[4]<90 then
		phaser_energy = phaser_energy - (100-ent.damage[4])*rnd(0.9)
	end
	phasers_hit = flr(phaser_energy/ships_to_attack)
end

function changestate_phasers_load()
	if ent.damage[4]<25 then
		add_new_message("phasers are inoperative, sir",4)
		changestate_mainscreen()
		return false
	end
	
	if sector.k3<1 then
		add_new_message("no enemy ships in this sector",4)
		changestate_mainscreen()
		return false
	end

	if ent.damage[4]<90 then
		add_new_message("phasers accuracy compromised",4)
		draw_messages()
	end

	phaser_energy = 0
	enemy_targeted = 1
	gui.shieldbar = flr((ent.energy+ent.shields)/game.maxenergy*gui.maxbarsize)
	gui.energybar = flr(ent.energy/game.maxenergy*gui.maxbarsize)
	phaserbarsize = flr(phaser_energy/game.maxenergy*gui.maxbarsize)

	game.upd=phasers_load_update
	game.drw=phasers_load_draw
end

function phasers_load_update()
	increment_msg_string()
	phaserbarsize = flr(phaser_energy/game.maxenergy*gui.maxbarsize)
	if btn(0) and phaser_energy>4 then
		phaser_energy = phaser_energy-5
	elseif btn(1) and phaser_energy<ent.energy-4 then
		phaser_energy = phaser_energy+5
	elseif btnp(4) then
		if phaser_energy==0 then changestate_mainscreen()
		else
			if phaser_energy > ent.energy then phaser_energy=ent.energy end	-- can happen for some decimals
			phaser_prepare_attack()	-- calc main data of phasers attack
			set_message_lines(6)
			changestate_phasers_hold()	-- ready to fire
		end
	elseif btnp(5) then
		changestate_mainscreen()
	end
end

function phasers_load_draw()
	rectfill(0,7*14-1,127,127,1)
	print("energy to phasers: "..phaser_energy,2,7*14,6)
	rectfill(gui.barx,gui.bary,gui.barx+gui.maxbarsize,gui.bary+7,5) -- grey
	rectfill(gui.barx,gui.bary,gui.barx+gui.shieldbar,gui.bary+7,12) -- blue
	rectfill(gui.barx,gui.bary,gui.barx+gui.energybar,gui.bary+7,10) -- yellow
	rectfill(gui.barx,gui.bary,gui.barx+phaserbarsize,gui.bary+7,9)	-- red
	print("phasers",gui.barx,gui.bary+10,9)
	print("energy",50,gui.bary+10,10)
	print("shields",100,gui.bary+10,12)
	draw_messages()
end


--====================================
-- state: nav  -------

function move_enterprise_tosector()
	updatemapcell(ent.row,ent.col,0)
	ent.sy,ent.sx = ent.toy,ent.tox
	ent.row,ent.col = placeelementinsector(ent.sy,ent.sx,1)
	time_advances(1)
end

function changestate_warp_speed()
	game.upd=warp_speed_update
	game.drw=warp_speed_draw
end

function warp_speed_update()
	move_enterprise_tosector()
	changestate_mainscreen()
end

function warp_speed_draw()
--
end

--=====================================
-- state starfield show
function changestate_starfield(delay)
	local range=2500
	sf.stars={}
	if delay<40 then delay = 40 end
	game.delay = delay

	for i=1,sf.starcount do
		xp,yp=flr(range-rnd(range*2)),flr(range-rnd(range*2))
		zp=rnd(sf.maxd)
		add(sf.stars,{x=xp,y=yp,z=zp})
	end

	game.upd=starfield_update
	game.drw=starfield_draw
end

function starfield_update()
	if game.delay>0 then game.delay = game.delay -1
	else game.nextstate() end
end

function starfield_draw()
	cls(0)
    for i=1,#sf.stars do
        sf.stars[i].z=sf.stars[i].z-3
        if sf.stars[i].z<=0 then
            sf.stars[i].z=sf.maxd
        end
    end
    --iterate all the stars
    for i=1,#sf.stars do
        --calc star pos xp=x/z yp=y/z
        local cz=sf.stars[i].z
        local cx=sf.stars[i].x/cz
        local cy=sf.stars[i].y/cz
        --if star is outside sceen
        --set z position to max dist
        if cx<-64 or cx>64 then
            sf.stars[i].z=sf.maxd
        end
        if cy<-64 or cy>64 then
            sf.stars[i].z=sf.maxd
        end
        --set the color of the star
        local cols={7,6,5}
        local ci=1+flr(cz/sf.maxd*#cols)
        --plot the star
        pset(64+cx,64+cy,cols[ci])
    end
	print("warp speed activated",(128-20*4)/2,7*16,flr(game.delay/5)%2+6)
end

--====================================
-- state: warp speed   ---------------

function changestate_warp()

	add_new_message(flr(map.energyrequired).." units of energy consumed.",4)
	ent.energy = ent.energy-map.energyrequired
	ent.toy,ent.tox = map.row,map.col
			
	game.upd=warp_update
	game.drw=warp_draw
end

function warp_update()
	game.popuptext = " warping to sector "..ent.toy..","..ent.tox
	game.nextstate = changestate_warp_speed
	changestate_starfield(map.energyrequired)
end

function warp_draw()
--
end
--====================================
-- state: map   ----------------------


function changestate_map()
	map = {}
	if ent.damage[8] <1 then
		add_new_message("library computer is inoperative",4)
		changestate_mainscreen()
		return false
	end
	map.row,map.col = ent.sy,ent.sx
	game.popuptext2 = nil
	game.upd=map_update
	game.drw=map_draw
end

function map_update()
	if sector.k3>0 and sector.warning == false then
		game.popuptext ="captain, klingons will fire"
		game.popuptext2 ="before warp is activated"
		game.nextstate = changestate_map
		sector.warning = true		
		changestate_popup()
	end

	if btnp(0) and map.col>1 then
		map.col = map.col -1
	elseif btnp(1) and map.col<8 then
		map.col = map.col +1
	elseif btnp(2) and map.row>1 then
		map.row = map.row -1
	elseif btnp(3) and map.row<8 then
		map.row = map.row +1
	elseif btnp(4) and (map.row != ent.sy or map.col !=ent.sx) then
		local dist = distance_calc(map.row,map.col,ent.sy,ent.sx)
		map.energyrequired = (dist^2)*2
		local maxspeed = (ent.damage[1]/100)*8

		if ent.damage[1]<90 and dist>maxspeed then
			game.popuptext ="warp engines are damaged"
			if flr(maxspeed) == 0 then
				game.popuptext2 ="warp speed not available"
			else
				game.popuptext2 ="warp factor limited to "..flr(maxspeed)
			end
			game.nextstate = changestate_map			
			changestate_popup()
		elseif sector.k3>0 then
			klingon_attacking = 1
			ent.initialshields = ent.shields
			game.nextstate = changestate_warp			
			changestate_klingons_hold()
		elseif map.energyrequired > ent.energy then
			if ent.shields+ent.energy > map.energyrequired then
				game.popuptext = "not enough energy, sir"
				game.popuptext2 ="but we can reduce shields"
			else
				game.popuptext = "not enough energy, sir!"-- for warp "..flr(dist)
			end
			game.nextstate = changestate_map			
			changestate_popup()
		else
			changestate_warp()
		end
	elseif btnp(5) or (btnp(4) and map.row == ent.sy and map.col ==ent.sx) then
		changestate_mainscreen()
	end
end

function map_draw()
	cls(0)
	local x,y = 9,8
	for j=1,8 do
		print(tostring(j),4+x+(j-1)*15,y,13)
		print(tostring(j),0,y+j*10,13)
	end
	for i=1,8 do
		for j=1,8 do
			local sectordata = exploredspace[i][j]
			local klcol,basecol,starcol = 6,6
			
			if sectordata == 0 then
				print("...",x+(j-1)*15,y+i*10,6)	
			else
				local kling,bases,stars = flr(sectordata/100), flr(sectordata/10) % 10, sectordata % 10
				if kling>0 then klcol = 8 end
				if bases>0 then basecol = 12 end
				print(kling,x+(j-1)*15,y+i*10,klcol)
				print(bases,4+x+(j-1)*15,y+i*10,basecol)
				print(stars,8+x+(j-1)*15,y+i*10,9)
			end
		end
	end
	local currcell = exploredspace[map.row][map.col]
	if currcell == 0 then
		print("unexplored sector",6,106,6)
	else
		local kk,bb,ss = flr(currcell/100), flr(currcell/10) % 10, currcell % 10
		local klcol,basecol,starcol = 6,6
		if kk>0 then klcol = 8 end
		if bb>0 then basecol = 12 end
		print("klingons:   bases:    stars:",6,106,6)
		print(kk,9*4+6,106,klcol)
		print(bb,18*4+6,106,basecol)
		print(ss,28*4+6,106,9)
	end
	rect(x-2+(ent.sx-1)*15, y-2+ent.sy*10, 12+x+(ent.sx-1)*15, 6+y+ent.sy*10, 13)
	rect(x-2+(map.col-1)*15, y-2+map.row*10, 12+x+(map.col-1)*15, 6+y+map.row*10, 12)
	
	show_press_key(true)
end

--====================================
-- state: shield  --------------------

function changestate_she()
	if ent.damage[7]<25 then
		add_new_message("shields control is frozen, sir",4)
		changestate_mainscreen()
		return false
	end
	gui.prevshields = ent.shields
	gui.energybar = flr((ent.energy+ent.shields)/game.maxenergy*gui.maxbarsize)
	gui.shieldbar=flr(ent.shields/game.maxenergy*gui.maxbarsize)
	
	game.upd=she_update
	game.drw=she_draw
end

function she_update()
	increment_msg_string()
	gui.shieldbar=flr(ent.shields/game.maxenergy*gui.maxbarsize)
	if btn(0) and ent.shields>4 then
		ent.shields,ent.energy = ent.shields-5,ent.energy+5
	elseif btn(1) and ent.shields<(ent.energy+ent.shields)-4 then
		ent.shields,ent.energy = ent.shields+5,ent.energy-5
	elseif btn(3) and ent.shields>14 then
		ent.shields,ent.energy = ent.shields-15,ent.energy+15
	elseif btn(2) and ent.shields<(ent.energy+ent.shields)-14 then
		ent.shields,ent.energy = ent.shields+15,ent.energy-15
	elseif btnp(4) then
		if gui.prevshields != ent.shields then
			if ent.shields == 0 then add_new_message('deflector shields dropped',9)
			else add_new_message('shields now at '..ent.shields,12) end
		end
		changestate_mainscreen()
	end
end

function she_draw()
	draw_maindata()
	rectfill(0,7*14-1,127,127,1)
	print("level of shields:",2,7*14,6)
	rectfill(gui.barx,gui.bary,gui.barx+gui.maxbarsize,gui.bary+7,5)
	rectfill(gui.barx,gui.bary,gui.barx+gui.energybar,gui.bary+7,10)
	rectfill(gui.barx,gui.bary,gui.barx+gui.shieldbar,gui.bary+7,12)
	print("shields",gui.barx,gui.bary+10,12)
	print("energy",100,gui.bary+10,10)
	draw_sectorscreen()
end



--====================================
-- state: damage  -----------------------

function changestate_damage()
	game.upd=damage_update
	game.drw=damage_draw
end

function damage_update()
	if btnp(4) then
		changestate_mainscreen()
	end
end

function damage_draw()
	cls(0)
	local x,y = 6,10
	--rectfill(x-4,y-4,120,88,0)
	print("device",x,y-2,9)
	print("health",x+90,y-2,9)
	for i=1,8 do
		print(devicenames[i],x,i*8+y,12)
		local col = 15
		if ent.damage[i] < 25 then col = 8
		elseif ent.damage[i] < 50 then col = 14
		elseif ent.damage[i] == 100 then col = 11
		end
		print(ent.damage[i]..'%',x+90,i*8+y,col)
	end
	show_press_key()
end


--====================================
-- state: lrs  -----------------------

function update_longrangesensorscan()
	for i=ent.sy-1,ent.sy+1 do
		for j=ent.sx-1,ent.sx+1 do
			if i>0 and i<9 and j>0 and j<9 then
				if exploredspace[i][j] == 0 then
					exploredspace[i][j]=sectorrecord(i,j)
				end
				add(lrs_array[i-ent.sy+2],sub(tostring(exploredspace[i][j]+1000),2,4))
			else
				add(lrs_array[i-ent.sy+2],"***")
			end
		end
	end
end

function changestate_lrs()
	lrs_array = {{},{},{}}
	if ent.damage[3]<25 then
		add_new_message("long range sensors inoperative",4)
		changestate_mainscreen()
		return false
	end
	add_new_message("long range sensors scan for "..ent.sy..","..ent.sx,12)
	
	game.upd=lrs_update
	game.drw=lrs_draw
end

function lrs_update()
	increment_msg_string()
	update_longrangesensorscan()
	if btnp()>0 then
		changestate_mainscreen()
	end
end

function lrs_draw()
	rectfill(1,6,16*4,9*7,0)
	for i=1,3 do
		print(tostring(lrs_array[i][1])..' '..tostring(lrs_array[i][2])..' '..tostring(lrs_array[i][3]),8+4,i*2*7+4,7)
	end
	draw_messages()
	show_press_key()
end


--====================================
-- draw state: mainscreen  -----------

function draw_sectorscreen()
	rectfill(1,6,16*4+2,9*7+1,0)
	print("1 2 3 4 5 6 7 8",4,0,0)

	if ent.damage[2] < 10 then
		print('short sensors',6+2,30,8)
		print('scan failure',8+2,36,8)
	else
	for i=1,8 do
		for j=1,8 do
			local row,col = localtoglobalcoord(ent.sy,ent.sx,i,j)
			local spritenum = getelementofmap(row,col)
			local px,py = (j-1)*8+2,i*7+1
			local kspr,sa = 3,0/360
			if spritenum == 1 then
				spr(ent.sprites[ent.spr],px,py)
			elseif spritenum == 3 then
				if (px > ent.dx) kspr =6
				spr(kspr,px,py)
			else
				spr(spritenum,px,py)
			end
		end
	end
	end
	draw_messages()
end

function draw_maindata()
	local tabx = 17*4+1
	cls(1)
	
	rectfill(tabx,6,127,63,1)
	print("stardate ",tabx,7+1,6)
	print("cond.    ",tabx,7*2+1,6)
	print("sector   ",tabx,7*3+1,6)
	print("torpedoes",tabx,7*4+1,6)
	print("energy   ",tabx,7*5+1,6)
	print("shields  ",tabx,7*6+1,6)
	print("klingons ",tabx,7*7+1,6)
	print("days left",tabx,7*8+1,6)
	
	tabx = 27*4-1
	local defcolor,shieldcolor = 12,11
	if (ent.shields <100) shieldcolor = 10
	
	print(flr(game.date),tabx,7+1,defcolor)
	print(ent.condition,tabx,7*2+1,ent.condcolor)
	print(ent.sy..","..ent.sx,tabx,7*3+1,defcolor)
	print(ent.torpedoes,tabx,7*4+1,defcolor)
	print(flr(ent.energy+ent.shields),tabx,7*5+1,defcolor)
	print(flr(ent.shields),tabx,7*6+1,shieldcolor)
	print(game.totalklingons,tabx,7*7+1,defcolor)
	print(flr(game.maxdays+game.t0 - game.date),tabx,7*8+1,defcolor)
	
end

function draw_messages()
	rectfill(0,7*10,128,7*(10+gui.maxmsg),1)
	for i,msg in ipairs(gui.messages) do
		if i==#gui.messages then
			print(sub(msg.txt,1,msg.len),2,7*(9+i),msg.col)
		else
			print(msg.txt,2,7*(9+i),msg.col)
		end
	end
end

function draw_commands_bar()
	print("command?",2,7*14,6)
	print(gui.description[gui.command],37,7*14,13)
	
	for i,com in ipairs(gui.commands) do
		local col =14
		if gui.command == i then col=7 end
		print(com,2+(i-1)*16,7*15+1,col)
	end
	
end

-- update state: mainscreen  --

function update_shipstatus()
	ent.condcolor,ent.condition = 11,'green'
	
	if (dock_is_possible() == false) ent.isdocked = false
	
	if ent.isdocked then
		ent.condcolor,ent.condition=3,'dockd'
	elseif sector.k3>0 then
		ent.condcolor,ent.condition=8,'red'
	elseif ent.energy < (game.maxenergy/10) then
		ent.condcolor,ent.condition=10,'yellw'
	end
end


function update_sector()
	-- reset current base data
	sector = {}
	enemyships = {}		-- indexes of the enemy ships present in this sector
 	
	currentsectorscan(ent.sy,ent.sx)
	sector.warning = false
	
	if exploredspace[ent.sy][ent.sx] == 0 then
		exploredspace[ent.sy][ent.sx] = sector.k3*100+sector.b3*10+sector.s3
	end
	
	-- only when just entered
	if ent.sy != prev_q1 or ent.sx != prev_q2 then
		add_new_message('sir, we are entering '..getquadrantname(ent.sy,ent.sx),6)

		if sector.k3>0 then
			add_new_message('we are under attack. red alert!',8)
			if ent.shields==0 then
				add_new_message('captain, shields are down.',10)
			end
		end
		
		prev_q1,prev_q2 = ent.sy,ent.sx
	end
end

-- 	gui.commands = {'imp','wrp','lrs','she','pha','tor','dam','dck'}

function select_commands()
	if btnp(0) and gui.command>1 then
		sfx(0)
		gui.command = gui.command -1
	elseif btnp(1) and gui.command<#gui.commands then
		sfx(0)
		gui.command = gui.command +1
	elseif btnp(4) and gui.command == 1 then
		changestate_nav()
	elseif btnp(4) and gui.command == 2 then
		changestate_map()
	elseif btnp(4) and gui.command == 3 then
		changestate_lrs()
	elseif btnp(4) and gui.command == 4 then
		changestate_she()
	elseif btnp(4) and gui.command == 5 then
		changestate_phasers_load()
	elseif btnp(4) and gui.command == 6 then
		changestate_torpedoes_load()
	elseif btnp(4) and gui.command == 7 then
		changestate_damage()
	elseif btnp(4) and gui.command == 8 then
		changestate_docking()
	end
end

--====================================
-- state: ship_movement   -------

function changestate_moving()
	game.nextstate = changestate_mainscreen
	updatemapcell(ent.row,ent.col,0)
	ent.ly,ent.lx,ssy,ssx = globaltolocalcoord(ent.row,ent.col)
	ent.dx,ent.dy = (ent.lx - 1)*8+5,ent.ly*7+4
	ent.step = 3
	ent.angle = atan2(ent.newx-ent.col, -ent.newy+ent.row)
	ent.spr = (flr(ent.angle*8+0.5)%8)+1

	add_new_message('impulse engines activated',6)
	game.upd=moving_update
	game.drw=moving_draw
end

function moving_update()
	increment_msg_string()
	ent.dx = ent.dx+cos(ent.angle)*ent.step
	ent.dy = ent.dy-sin(ent.angle)*ent.step*(7/8)
	ent.row = ent.row - sin(ent.angle)*(ent.step/8)
	ent.col = ent.col + cos(ent.angle)*(ent.step/8)
			
	if flr(ent.row+0.5) == ent.newy and flr(ent.col+.5) == ent.newx then
		ent.row,ent.col = ent.newy,ent.newx
		updatemapcell(ent.row,ent.col,1)
		ent.ly,ent.lx,ssy,ssx = globaltolocalcoord(ent.row,ent.col)
		if sector.k3>0 then
			klingon_attacking = 1
			ent.initialshields = ent.shields
			changestate_klingons_hold()
		else
			game.nextstate()
		end
		
	end
end

function moving_draw()
	draw_sectorscreen()
	spr(ent.sprites[ent.spr],ent.dx-4, ent.dy-3)
	clean_bottom_bar()
	--print("ang,distance="..ent.angle.." "..distance_calc(ent.newx,ent.newy,ent.col,ent.row),2,120,7)
end

-- state: nav ---------

function changestate_nav()
	game.navactive = true
	ent.newx,ent.newy = ent.col,ent.row
	ent.ly,ent.lx,ssy,ssx = globaltolocalcoord(ent.row,ent.col)
	game.upd=mainscreen_update
	game.drw=mainscreen_draw
end


function impulse_move()
	ent.ly,ent.lx,ssy,ssx = globaltolocalcoord(ent.newy,ent.newx)
	if btnp(0) and ent.lx>1 then
		ent.newx = ent.newx -1
	elseif btnp(1) and ent.lx<8 then
		ent.newx = ent.newx +1
	elseif btnp(2) and ent.ly>1 then
		ent.newy = ent.newy -1
	elseif btnp(3) and ent.ly<8 then
		ent.newy = ent.newy +1
	elseif btnp(4) and (ent.newy != ent.row or ent.newx !=ent.col) then
		if mapcell(ent.newy,ent.newx)>0 then
			add_new_message("collision course, captain",8)
			ent.newy,ent.newx = ent.row,ent.col
		else	
			changestate_moving()
		end
	elseif btnp(5) then
		changestate_mainscreen()
	end
end

function draw_shipcursor()
	local px,py = (ent.lx - 1)*8+1,ent.ly*7+1
	rect(px,py,px+8,py+7,13)
end

-- state: mainscreeen ---------

function changestate_mainscreen()
	game.navactive = false
	set_message_lines(3)
	ent.ly,ent.lx,ssy,ssx = globaltolocalcoord(ent.row,ent.col)
	ent.dx,ent.dy = (ent.lx - 1)*8+1,ent.ly*7+1
	ent.spr =1
	if (ent.lx>4) ent.spr =5
	game.upd=mainscreen_update
	game.drw=mainscreen_draw
end

function mainscreen_update()
	increment_msg_string()
	update_sector()
	update_shipstatus()

	if game.date >= game.t0+game.maxdays then
		changestate_game_lost("too late, captain!")
	elseif ent.shields<1 and ent.energy<1 then
		changestate_game_lost("no energy. we are stranded!")
	elseif ent.damage[1]/100*8<1 and sector.b3 == 0 then
		changestate_game_lost("engine down. we are stranded")
	end
	if game.navactive then impulse_move()
	else select_commands() end
end

function mainscreen_draw()
	draw_maindata()
	draw_sectorscreen()
	if game.navactive then draw_shipcursor()
	else draw_commands_bar() end
end

--=============================
-- state: titlescreen ---------

function addr_col(val8)
	local bc={0,5,6,7} -- grey
	return bc[band(flr(val8),0x03)+1]
end

function print_cover()
 -- map: 0x2000 to 0x2fff (4096 bytes)
 --  expand (1 byte = 4 pixels (col 0..3 each))
 --  to display real colors (1 byte = 2 pixels)
	local addr_src,addr_dst=0x2000,0x6000
	local max_bytes=4096
	local i, val_src8, val_dst8
	cls(0)
	for i=1,max_bytes do
		val_src8 = peek(addr_src)
		val_dst8 = addr_col(val_src8   ) + 16*addr_col(val_src8/4 )
		poke(addr_dst, val_dst8)
		val_dst8 = addr_col(val_src8/16) + 16*addr_col(val_src8/64)
		poke(addr_dst+1, val_dst8)
		addr_src+=1
		addr_dst+=2
	end
end

function changestate_titlescreen(printcover)
	local basename = ' base'
	if printcover == nil then
		music(0)
		print_cover()
	end
	title = {}
	if (game.totalbases > 1) basename = ' bases'
	title.txt ="captain's log, stardate "..game.date..".\nklingons attacked the federation\nwe need to stop them before they\nreach starfleet headquarters.\n"
	title.txt2 ="there are "..game.totalklingons.." enemy ships and\n"..game.totalbases .. basename.." in the area. we have\n"..game.maxdays.." days before it's too late."
	title.idx = 1
	
	game.upd=titlescreen_update
	game.drw=titlescreen_draw
end

function titlescreen_update()
	if (title.idx<1000) title.idx+=1
	if btnp(4) then
	 if title.idx<280 then
		title.idx = 280
	 else
		music(-1, 1300)
		changestate_mainscreen()
	 end
	end
end

function titlescreen_draw()
	rectfill(0,0,128,6,0)
	rectfill(0,60,128,128,0)
	print("uss enterprise ncc-1701",(128-23*4)/2+1,1,1)
	print("uss enterprise ncc-1701",(128-23*4)/2,0,10)
	if title.idx>32 then
		print(sub(title.txt,1,title.idx-32),0,62,12)
	end
	if title.idx>180 then
		print(sub(title.txt2,1,title.idx-180),0,94,9)
	end
	if (title.idx>280) show_press_key()
end



function changestate_startscreen()
	music(0)
	print_cover()
	gui.txtcolor = 5
	game.delay = 1
	game.upd=startscreen_update
	game.drw=startscreen_draw
end

function startscreen_update()
	game.delay = game.delay+1
	local intrv = flr(game.delay/8) % 2
	if intrv == 0 then gui.txtcolor= 6
	elseif intrv == 1 then gui.txtcolor= 12
	end
	if btnp(4) then
		changestate_titlescreen(false)
	end
end

function startscreen_draw()
	for i=0,7 do spr(32+i,32+i*8,60) end
	for i=0,7 do spr(48+i,32+i*8,68) end
	print("emabolo presents",(128-64)/2+1,1,1)
	print("emabolo presents",(128-64)/2,0,11)
	print("conversion to pico-8 of the 1978",0,80,13)
	print("game 'super star trek' by bob",(128-29*4)/2,88,13)
	print("leedom and david ahl",(128-20*4)/2,96,13)
	print("press Ž (keyboard: z)",(128-21*4)/2,110,gui.txtcolor)
end

--====================================================
function _update()
	game.upd()
end

function _draw()
	game.drw()
end
--====================================================

game = {}
gui = {}
__gfx__
0000000000000000000000000033000001cccd100000000000003300000000000000000000000000000000000000000000000000000000000000000000000000
00000000776e0661010a010003b000001c6cccd10000000000000b30000300000338330000000000000000000000000000000000000000000000000000000000
0000000000706776009a90000330030001cccd100008000000300330003b30003b3b3b3000000000000000000000000000000000000000000000000000000000
00000000016777770aa9aa0008bbbb30000cd0000087800003bbbb80000b0000300b003000000000000000000000000000000000000000000000000000000000
0000000000706776009a900003300300000cc0000008000000300330300b0030000b000000000000000000000000000000000000000000000000000000000000
00000000776e1661010a010003b00000000cd0000000000000000b303b3b3b30003b300000000000000000000000000000000000000000000000000000000000
00000000111101100000000000330000000d10000000000000003300033833000003000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000016761000700071000000000000057611675000000760000000067000000000000000000000000000000000000000000000000000000000000000000
0000000006777610070107101660e677000177766777100000076000000670000000000000000000000000000000000000000000000000000000000000000000
0000000006777610067676106776070000106777777601007000e100001e00070000000000000000000000000000000000000000000000000000000000000000
00000000006761000e070e007777761006e6567557656e6057076010010670750000000000000000000000000000000000000000000000000000000000000000
000000000e070e100067600067760700670761511516707615e6567557656e510000000000000000000000000000000000000000000000000000000000000000
0000000006767610067776101661e6777000e000000e000701016777777610100000000000000000000000000000000000000000000000000000000000000000
00000000070107100677761001101111000751000015700000057776677750000000000000000000000000000000000000000000000000000000000000000000
00000000070007100067600000000000007510000001570000015761167510000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000004aaaa0aaaaa90aaaa409aaaa500004aaaaa59aaaa50aaaa45a909a500000000000000000000000000000000000000000000000000000000000000000000
00005aa9aa59aaa959aaaa40aa9aa5000099aa990aa9aa54aa9904a54a4000000000000000000000000000000000000000000000000000000000000000000000
00009a5040009a000aa04a55a40aa0000005a9005a40aa09a0000aa5a90000000000000000000000000000000000000000000000000000000000000000000000
0000aa004500a9005a40aa09a55a90000004a5009a05a40a90005a9aa00000000000000000000000000000000000000000000000000000000000000000000000
0005a99aa005a4009a54a90aa09a5000000aa000a909a54a99a09aaa500000000000000000000000000000000000000000000000000000000000000000000000
0009aaaa9009a000aaaaa55aaaaa0000005a9005aaaa909aaa40aaaa000000000000000000000000000000000000000000000000000000000000000000000000
000aa49a500a9005aaaaa09aaa400000004a5009aaa500aa4005aaaa000000000000000000000000000000000000000000000000000000000000000000000000
005400aa004a4009a55a40aa9a50000000aa000aaaa504a50009a99a000000000000000000000000000000000000000000000000000000000000000000000000
000455a9009a000aa09a55a44a40000005a9004a49a509a0000aa09a000000000000000000000000000000000000000000000000000000000000000000000000
00aa54a500a9005a40aa09a54a40000004a5009a04a50aa5505a409a500000000000000000000000000000000000000000000000000000000000000000000000
05aaaaa004a4009a05a40aa05a4000000aa000a904a44aaaa09a509a500000000000000000000000000000000000000000000000000000000000000000000000
00999900049000940595595059400000094005950595499940990049500000000000000000000000000000000000000000000000000000000000000000000000
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
0000000004004000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000054aabbabab5a01000000000000000000000000000000000000000000000080feffffffffffffffaf15000000000000000000000000000000000000000090ffffffffffffffffffffff0600000000000000000000000000000000000090ffffffffffffffffffffffffbf050000
000000000000000000000000000040feffffffbf66165565a6eaffffff6f00000000000000000000000094010000e4ffffbf1a0000000000040094ffffff020000000000000000000040ff0b0040feff6b0100000000500005000090ffff1f00000000000000000050dfff0f00d0ff2f200000000000155554000000d4ff3f00
0000000000000040fdebff1f00a0bf011400000010415599aa55050000fdbf0000000000000000f9ffd7ff1f00e40b945a0100005540aabeeabe160000d0ff00000000000000e4ffffdbff1f00e41051660100005495aafaffefba0100407f00000000000090ffeeffebff0b006440d99b05000051a5bafefffaab0200003c00
0000000080ff9bfeffaba501001060ba6b0100004094faffabffaf050000180000000000feafffffbf160000000094fe5b9545005094babfffffbb02000005000000bdf9bffeffff164000000000a4feefab5a411460feffffff6a010040000000a4feffeeffff5b100000000000e4ffffff5f040054feffef5b010000000000
00eaffffffff2f0028000000000050faffbfa6010050faffaf0000000000000000f8faffff6b00807f00000000400abdbe6a79000000a5bf050000000000000000fdffff6f0100c0bf00000000fdaa9696aa7e5600402a05000000000000000020fcff6f01000000ff000000b9e9fe1f94e56f1101e00f000000000000000000
10fd5a0000000000fe0200b5a657a93a40ea170000e0020000000000000000004001000000000000fc2ba90659f9afbd65f902000000000000000000000000000000000000000000f8af1200e5bf16feffba00000000000000000000000000000000000000000040f62f00a46a15d0ffff3f0000000000000000000000000000
0000000000000050e93fa46a0000b0ffff0b0000000000000000000000000000010100101010006098ff16000000f8ffff0300000000000000000000000000000000000000000020a4ff00000000fbefbe000000000000000000000000000000000000000000000000fe02000080fb6f1a000000000000100000000000000000
000000000000000000fc03000094ada65a010000000000000000000000000000000050000000000000f40b00807d9abaab060000000000000000000000000000000000000000000000f00f00905efafffa030000000000000000000000000000000000000000000000d02f0090aafffffe000000000000000000000000000000
000000000000000000c03b40e9ffffffff00100000000000000000000000000000000000000000000040bbf8ffffffffbf0060000000000000000000000000000000000000000000000056ffffbf6aaeb901540000000000000000000000000000000000000000000069a5ffef5a95afba000000040000000000000000000000
0000100000400000c0ffffeabb96a5beb90000000000000000000000000040000000000000000000c0ffffaf6a5665a6a90000400010040000000000000000000000000010000000d0ffabaa5a495050550000000000000000000000000000000000000000000000c0ae9a151000000000000000000000000000000000000000
0000000000000000005555050000000000000000000000000000000000000000000000000000000000000000000000004001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000004000004000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000004000000
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
000300000d52013000100000d00008000060000400003000010000000009600076000660004600036000360003600036000060003600036000360003600036000180001800018000180001800018000180001800
000500001f353226531e3531d65318353166531434311643123430f6430b343086230732303623043230261302313006130131300613003130230302303033030230301303013030030300302003020130201300
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400003904039040390403904039040390403904039040390403904039040390403904039040390403904039040390403904039040390403904039040390403904039040390403904039040390403904039040
010400002d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d1402d140
010400002133021330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021330213302133021330
010400003904039040390403904039040390403904039040390403904039040390403904039040390403904039040390403904039040390403904039040390403904039040390400000034040340403404034040
010400002d1402d1402d1402d1402d1402d1402d1402d1402d1402d14000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000028140281402814028140
010400003404034040340403404034040340403404034040340403404034040340403404034040340403404034040340403404034040340403404034040340403404034040340403404034040340403404034040
010400002814028140281402814028140281402814028140281402814028140281402814028140281402814028140281402814028140281402814028140281402814028140281402814028140281402814028140
010400003404034040340403404034040340403404034040340403404034040340403404034040340403404034040340403404034040340403404034040000003704037040370403704037040370403704037040
01040000281402814028140281402814028140281402814028140281402814028140281402814028140281402814000000000000000000000000000000000000000002b1502b1502b1502b1502b1502b1502b150
010400003704037040370403704037040370403704037040370403704037040370403704037040370403704037040370403704037040370403704037040370403704037040370403704037040370403704037040
010400002b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b150
010400003704037040370403704037040370403704037040370403704037040370403704037040370403704037040370403704000000000002f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f040
010400002b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b1502b150000000000000000000000000000000000000000023140231402314023140231402314023140231402314023140
010400002f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f040
010400002314023140231402314023140231402314023140231402314023140231402314023140231402314023140231402314023140231402314023140231402314023140231402314023140231402314023140
010400002f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f0402f04000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002314023140231402314023140231402314023140231402314023140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000152601526015260152601526015260152601526015260152601526015260152601526015260
010400002133021330213302133021330213302133021330213302133021330213302133021330213301536015360153601536015360153601536015360153601536015360153601536015360153601536000000
01040000000000000000000000000000000000000000000000000000001a2601a2601a2601a260000001f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f260
0104000000000000000000000000000000000000000000001a3601a3601a3601a360000001f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f360
010400001f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2601f2600000000000000000000000000000000000000000000001e2601e2601e260
010400001f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3601f3600000000000000000000000000000000000000000000001e3601e3601e3601e3601e360
010400001e2601e2601e2601e2601e2601e2600000000000000000000000000000001a2601a2601a2601a2601a2601a2601a26000000000000000017260172601726017260172601726000000000000000000000
010400001e3601e36000000000000000000000000000000000000000001a3601a3601a3601a3601a3601a3601a3601a3600000000000173601736017360173601736000000000000000000000000001c3601c360
010800001c2601c260000000000000000212602126021260212602126021260212602126021260212602126021260212602126021260212602126021260212602126021260212602126000000000000000000000
010800001c36000000000000000021360213602136021360213602136021360213602136021360213602136021360213602136021360213602136021360213602136021360213602136000000000000000000000
010400000000000000000000000000000000000000000000311503115031150311503115031150311503115031150311503115031150311503115031150311503115031150311503115031150311503115031150
010400000000021260212602126000000000002526025260252602526025260252602526025260252602526025260252602526025260252602526025260252602526025260252602526025260252602526025260
010400002136021360213600000000000253602536025360253602536025360253602536025360253602536025360253602536025360253602536025360253602536025360253602536025360253602536025360
010400003115031150311503115031150311503115031150311503115031150311503115031150311503115031150311503115031150311503115031150311503115031150311503115031150000000000000000
010400002526025260252602526025260252602526025260252602526025260252602526025260252602526025260252602526025260252602526025260252602526025260252602526025260252602526025260
010400002536025360253602536025360253602536025360253602536025360253602536025360253602536025360253602536025360253602536025360253602536025360253602536025360253602536025360
010400002526025260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400002536025360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 04 05 06 44
00 07 08 06 44
00 09 0a 06 44
00 0b 0c 06 44
00 0d 0e 06 44
00 0f 10 06 44
00 11 12 06 44
00 13 14 15 16
00 17 18 43 44
00 19 1a 43 44
00 1b 1c 43 44
00 1d 1e 43 44
00 1f 20 21 44
00 22 23 24 44
00 25 26 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
