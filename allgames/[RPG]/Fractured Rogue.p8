pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- fractured rogue  v1.0
-- by xanthus1@gmail.com

char = ' 0123456789abcdefghijklmnopqrstuvwxyz'..
	'‡:!+’‹Ž?–„%()”ƒ‘†Ž—-.\\“'

function lwrds(addr)
	wrd={}
	repeat
		local s=""
		local c=""
  repeat
 		s=s..c
 		c=sub(char,peek(addr),peek(addr))
 		addr+=1
 	until c=='–' or c=='„'
 	add(wrd,s)
 until c=='„'
end

lwrds(0x1a00)
e_stats={}
for i=48,76 do
	e_stats[i]={}
	for j=1,6 do
		e_stats[i][j]=wrd[(i-48)*6+j]
	end
end
-- ranged enem 2nd spr
e_stats[92]=e_stats[76]
e_stats[80]=e_stats[54]

lwrds(0x3b00)
c_stats={}
num_items=25
for i=0,num_items do
	c_stats[i+1]={}
	for j=1,10 do
		c_stats[i+1][j]=wrd[i*10+j]
	end
end 

-- pallet
pals={}
for i=0,7 do
	pals[i+1]={}
	for j=0,2 do
		pals[i+1][j+1]=peek(0x008+i*64+j)	
	end
end

-- area defs
area_loc = 0x00c+3*64
areas = {}
for i=0,10 do
	areas[i+1]={}
	for j=0,3 do
		areas[i+1][j+1]=peek(area_loc+i*64+j)
	end
end

msgcolors={ 
		’=10,
		†=12,
		…=14,
		Ž=12,
		‡=8}
msgcolors["!"]=8

st_start=0
st_start_sel=1
st_game=2
st_menu=3
st_wait_dir=5
st_wait_sel=6
st_dead=7
st_end=8
state = st_start
actions = {}

wipe_screeny=0

dirs = {}
function makedir(v,x,y)
	d={}
	d.v=v
	d.x=x
	d.y=y
	add(dirs,d)
end
local l = makedir(0,-1,0)
local r = makedir(1,1,0)
local d = makedir(2,0,1)
local u = makedir(3,0,-1)

cartdata("xanthus_fractured_rogue")
hi=dget(0)

function _init()
	sfx(-1)
	music(1)
	state = st_start 
	wipe_screeny=0
	p1 = nil 
	objs = {}
	enems = {}
	items = {}
	efx = {}
	init_items()
	init_items2()
	near={}
	t=0
	ht=1 -- height timer (bob)
	score = 0
	board = {}
	area = 0
	brd_timer = 0
	msg = {"","","",""}
	loot=2
				
	menu=0
	choice=1
	choice_offset=1
	choices={}
	sub_menus={}
	my_items={}
	my_skills={}
	
	pstats_txt={
			{8,1,"1-2"},
			{7,2,"1-3"},
			{5,4,"1"}}
			
	skills = {12,13,14,15,26,27,28,29,30,31,40,41,42,43,44,45,46,81,82,85,86,87,88}
	add(sub_menus,my_skills)
	add(sub_menus,my_items)
	local c = {}
	c.text="close (z/Ž)"
	c.mana=0
	c.utext=""
	c.num=-1
	c.cd=0
	c.maxcd=0
	c.act=function() end
	add_item(c)
	add_skill(c)
end

function init_game()
	t=0
	gen_board()
	make_player()
		
	-- update enem stats
	update_near()
	
	-- start w/ pot 
	local i = make_item(p1.x,p1.y,9)
	i.act()
	if(p_sel==1) i.act()
	i.die()

	-- wiz
	spells = {26,29,30,41,45,46}
	if p1.spr%16==2 then
		local rndspell=spells[ceil(rnd(#spells))]
		del(skills,rndspell) 
		local i = make_item(p1.x,p1.y,rndspell)
		i.act()
		i.die()	
	end
		
	msg[4] = "z/Ž- open/close menu"
	msg[3] = "x/—- wait 1“/select"
	msg[2] = "!escape the fractured!"
	msg[1] = "!dimension: start!"
end

function _update()
	if wipe_screeny>0 then
		wipe_screeny+=8
	end
	
	-- current choice selection
	local ch = choices[choice]
	
	if state==st_end then
		if btnp(5) and wipe_screeny==0 then
			wipe_screeny=1
		end		
		if wipe_screeny>=168 then
			state=st_start
			if score>hi then
				dset(0,score)
				hi=score
			end
			_init()
			wipe_screeny=0
			return
		end
		return
	end
	-- process actions/efx
	if(#efx>0 and p1.act) then
		p1.d=2
		return
	end
	if (p1!=nil) p1.d=max(p1.d-1,0)
	if p1 and p1.hp>0 then
 	for a in all(actions) do
   a()
 		del(actions,a)
		 return
 	end
 end
 
		
	-- hit button to start
	if state==st_start then
		if btnp(5) and wipe_screeny==0 then
			sfx(2)
			wipe_screeny=1
		end		
		if wipe_screeny>=168 then
			state=st_start_sel
			p_sel=1
			p_pal=1
			wipe_screeny=0
			return
		end
		return
	end
	
	-- select character
	if state==st_start_sel then
		if(btnp(0)) p_sel=max(1,p_sel-1) sfx(0)
		if(btnp(1)) p_sel=min(6,p_sel+1) sfx(0)
		if(btnp(2)) p_pal=max(1,p_pal-1) sfx(0)
		if(btnp(3)) p_pal=min(#pals,p_pal+1) sfx(0)
		if btnp(5) and wipe_screeny==0 then
			sfx(2)
			wipe_screeny=1
		end		
		if wipe_screeny>=168 then
			state=st_game
			music(0)
			init_game()
			wipe_screeny=0
			return
		end
		return
	end
	
	if state==st_wait_dir then
		-- loop until direction chosen
		local dir = -1
		if(btnp(0)) dir=0
		if(btnp(1)) dir=1
		if(btnp(2)) dir=2
		if(btnp(3)) dir=3
		if btnp(4) then
			state=st_game
			cancel()
			return
		end

		-- if direction chosen, do
		-- skill function
		if dir!=-1	then
			if inter(dir) then			
				p1.d=15
				if(ch.num==0) del(my_items,ch)
			end
			state=st_game
			inter=nil
		end
	end
	
	if state==st_wait_sel then
  if tgt==nil then
  	tgt={}
  	tgt.x=p1.x
  	tgt.y=p1.y
  	
  	-- make efx 
   tgt.efx=make_efx(p1.x,p1.y,140,4,true)
  end
  
  -- keep tgt in range
  local prev_x=tgt.x
  local prev_y=tgt.y
		if(btnp(0)) tgt.x=bound(prev_x-1)
		if(btnp(1)) tgt.x=bound(prev_x+1)
		if(btnp(2)) tgt.y=bound(prev_y-1)
		if(btnp(3)) tgt.y=bound(prev_y+1)
		if(abs(tgt.x-p1.x)+abs(tgt.y-p1.y)>sel_range) then
			tgt.x=prev_x
			tgt.y=prev_y
			message("! outside of range:"..sel_range)
		end
		
		tgt.efx.x=tgt.x
		tgt.efx.y=tgt.y
		if btnp(5) then
			-- only move on if successful
			-- selection
			if inter(tgt) then
				p1.d=15
				if(ch.num==0) del(my_items,ch)
				state=st_game
				inter=nil
				del(efx,tgt.efx)
				tgt=nil
			end
		end
		if btnp(4) then
			state=st_game
			p1.d=15
			inter=nil
			del(efx,tgt.efx)
			tgt=nil
			cancel()
			return
		end	
	end
	
	if state==st_game then
		for o in all(objs) do
			o.u()
		end
		
		-- open menu
 	if btnp(4) then
 		menu=1
 		state=st_menu
 		choices=my_skills
 		choice=1
 		choice_offset=1
 		return
 	end	
 	if p1.hp<=0 then
 		message("! you died !")
 		actions = {}
 		state=st_dead
			deadcirc=1
 		p1.die()
 		music(-1)
 		sfx(22)
 	end
	end
	
	if state==st_menu then
		menu_update()
		-- close menu
 	if btnp(4) then
 		state=st_game
 		menu=0
 	end	
	end
	
	if state==st_dead then
		if btnp(5) and wipe_screeny==0 and deadcirc>=40 then
			wipe_screeny=1
		end		
		if wipe_screeny>=168 then
			state=st_start
			if score>hi then
				dset(0,score)
				hi=score
			end
			_init()
			wipe_screeny=0
			return
		end
		return
	end

end

function menu_update()	
	-- up
	if btnp(2) then
		choice-=1
		
		-- loop to bottom
		if(choice<1) choice=#choices
	end
	-- down
	if btnp(3) then
		choice+=1
		
		--loop to top
		if(choice>#choices) choice=1
	end
	
	-- changing menu left/right
	if btnp(0) then
	 menu=1
	 choices = sub_menus[menu]
	 choice=1
	end
	if btnp(1) then
		menu=2
	 choices = sub_menus[menu]
		choice=1
	end
	if choice>choice_offset+3 then
		choice_offset+=1
	end
	if choice<choice_offset then
		choice_offset-=1
	end
	
	if btnp(5) then
		-- do action based on selection
		-- check cooldown	
		if ch.cd>0 then
			sfx(5)
		else
			use(ch)
			
			menu = 0
			-- if state wasn't changed by 
			-- skill, go back to game
			if state==st_menu then
				state=st_game		
			end
		end
	end
end

function _draw()
	if(state<st_game or state>st_dead) cls()

	if state==st_start then
		map()
		t+=1
		print("fractured rogue",33,15,7+(t%28)/4)
		print("— to start",46,85)
		print("hiscore:"..hi,46,110)

		for i=0,1 do
			spr(23+t%16/8,20+77*i,13)		
		end
		
		for i=2,13 do
			camera(4,sin(t%60/60+i/13)*2.5)
			map(i,16,i*8,40,1,10)
		end	
		camera()
	end
	if state==st_start_sel then
		map(32,0,0,0,16,16,0x1)
		t+=1
		print("‹ ‘ : character",20,12,7+(t%28)/4)
		print("” ƒ : color",20,22)
		print("—/x : start",20,32)
			
		local p =(p_sel-1)%3+1
		local s ={"‡","†","’"}
		for i=1,3 do
			print(pstats_txt[p][i]..s[i],30+i*15,55,msgcolors[s[i]])
		end
		if p_pal!=1 then
			for i=1,3 do
				pal(pals[1][i],pals[p_pal][i])
			end		
		end

		if(p==1) start_txt="start with extra potion"
		if(p==2) start_txt=""
		if(p==3) start_txt="start with random spell"
		
		print(start_txt,16,62,7)

		print("ƒ",9+p_sel*16,82,12)
		spr(ceil(p_sel/3)*16+(p_sel-1)%3,64,70)
		map(32,0,0,0,16,16,0x2)
		pal()
	end
	if state==st_end then
		print("you have escaped the",15,40,7)
		print("fractured dimension!",25,47,7)
		map(16,0)
		print("press — to play again",15,90)
	end	
	
	if state>st_start_sel and state<st_end then
		draw_board()
		for o in all(objs) do
			draw_obj(o)
 	end
 	
 	for e in all(efx) do
 		draw_efx(e)
 		e.u()
 	end
 	
 	if menu>0 then
 		draw_menu()
 	end

		-- blinking arrows
 	if state==st_wait_dir then
			if ht%20/10>1 then
				for d in all(dirs) do
					for i=1,sel_range do
						spr(109+d.x+d.y*16,(bound(p1.x+i*d.x))*8,(bound(p1.y+i*d.y))*8)
					end
				end
			end
		end
	end
	
	if deadcirc and deadcirc<40 then
		circ(p1.x*8+4,p1.y*8+4,deadcirc/2,8)
		deadcirc+=1
 end
	
	if wipe_screeny>0 then
		for i=0,128 do
			if i<wipe_screeny then
				rectfill(60-i/2,60-i/2,68+i/2,68+i/2,14)
				rectfill(64-i/2,64-i/2,64+i/2,64+i/2,0)
			end
		end
	end
end

function draw_menu()
	rectfill(0,64,128,128,9)
	rectfill(2,66,125,125,0)
	
	print(">",4,61+(choice-choice_offset+1)*8,3)
	
	for i=choice_offset,min(choice_offset+5,#choices) do
		local ch = choices[i]
		spr(ch.spr,9,61+(i-choice_offset+1)*8-2)
		
		local choicecolor=7
		if ch.cd>0 or p1.mana<ch.mana	then
			choicecolor=8
		end

		local txt = ch.text
		if(ch.dmg and ch.dmg>0) txt=txt.." ’1-"..ch.dmg
		if(ch.mana>0) txt=txt.." †"..ch.mana
		if(ch.maxcd>0) txt=txt.." cd:"..ch.maxcd
		if(ch.num>0) txt=txt.." ("..ch.num..")"
		print(txt,18,61+(i-choice_offset+1)*8,choicecolor)
	end
	ch = choices[choice]
	if ch.descr then
		rectfill(0,54,128,63,3)
		print(ch.descr,2,57,7)
	end
	if ch.cd>0 then
		rectfill(0,44,128,53,8)
		print("cooldown: "..ch.cd.."“",2,47,7)
	end
	
	-- different sub menus
	local item_txt = "items"
	local item_clr = 7
	local skill_txt = "skills"
	local skill_clr = 7
	if menu==1 then
		skill_txt = ">skills"
		skill_clr = 11
	end
	if menu==2 then
		item_txt = ">items"
		item_clr = 11
	end
	
	line(0,116,128,116,10)
	print(skill_txt,10,119,skill_clr)
	print(item_txt,54,119,item_clr)
end

function draw_board() 
	rectfill(96,0,128,128,0)
	rectfill(0,96,96,128,0)
	color(7)
	print("score:",99,2,7)
	print(score,99,9,7) 
	print("area "..area,99,18,7)
	print("lvl  "..p1.lvl,99,25,7)
	print("xp ",99,32,7)
	rectfill(108,33,123,35,1)
	rectfill(109,34,(p1.xp/(p1.lvl*2+3))*14+109,34,11)
	print("‡:"..p1.hp.."/"..p1.maxhp,97,41,8)	
	print("†:"..p1.mana.."/"..p1.maxmana,97,49,12)	
	print(d_rng(p1.dmg),97,57,10)	
	
	-- message area
	print(">",3,120,3)
	-- change based on message 
	for i=1,4 do
		local c=msgcolors[sub(msg[i],0,1)]
		-- if colors were not found
		-- change to white
		if(c==nil) c=7
		local xoff=5
		if(i==1) xoff=8
		print(msg[i],xoff,127-7*i,c)
	end	
	
	-- seperator line
	line(97,65,128,65,2)
	-- show nearby enem stats	
	for i=1,#near do
		local dy=(i-1)*18
		spr(near[i].spr,99,68+dy)
		print("‡:"..near[i].hp,108,69+dy,8)
		print(d_rng(near[i].dmg),99,78+dy,10)			
	end

	-- blue bg, black lines
	t+=2
	ht=(ht+1)%40
	if(t==9) t=0
	if(t==8) t=1
	for i=0,11 do
		line(i*8+t,0,i*8+t,95,1)
		line(0,i*8+t,95,i*8+t,1)
	end
	color(0)
	for i=0,11 do
		line(i*8,0,i*8,96)
		line(0,i*8,96,i*8)
	end	

	for i=0,12 do
		for j=0,12 do
			local y=j*8
			local x=i*8
			local b = board[j][i]
			-- bpit
			if b==1 then
				rectfill(x,y,x+8,y+8,1)
			else
				--blank
				if b==2 then
					rectfill(x,y,x+8,y+8,0)
				else
					--fire / water
					if b==5 or b==20 then
						spr(b,x+1-flr(ht/20),y,1,1,ht/20<1)
					else
						spr(board[j][i],x,y)
					end
				end
			end
		end
	end
end

function brd()
	return board[j][i]
end

function draw_obj(o)
	palt(0,true)	
	-- alt skins for player
	if o==p1 and p_pal!=1 then
		for i=1,3 do
			pal(pals[1][i],pals[p_pal][i])
		end
		spr(o.spr,o.x*8,o.y*8+ht/20)
		pal()
	else
		spr(o.spr,o.x*8,o.y*8+ht/20)
	end
end

function draw_efx(e)
	spr(e.spr,e.x*8,e.y*8,1,1)
end

function d_rng(d)
	if(d<=1) return "’:"..d
	return "’:1-"..d
end

function cancel()
	if(ch.num>-1) ch.num+=1
	ch.cd=0
	p1.mana+=ch.mana
	message("!cancelled")
end
-->8
-- make functions
-- defines objects

function make_player()
	p1 = make_obj()
	rndxy(0)
	p1.x=xx
	p1.y=yy
	p1.name = "you"
	p1.spr=ceil(p_sel/3)*16+(p_sel-1)%3
	rndxy(0)
	p1.maxhp=7
	p1.maxmana=2
	p1.dmg=3
	p1.lvl=1
	p1.xp=0
	p1.act=false
	p1.d=0
	p1.delay=0
	
	p1.efx(192,12)
	if p1.spr%16==2 then
		p1.maxmana=4
		p1.maxhp=5
		p1.dmg=1
	end
	if p1.spr%16==0 then
		p1.maxmana=1
		p1.maxhp=8
		p1.dmg=2
	end
	p1.hp=p1.maxhp
	p1.mana=p1.maxmana
	 	
	p1.u = function()
		p1.act=false
		-- movement
		nx = p1.x
		ny = p1.y
		if p1.delay>0 then -- delayed by web/swim
			enem_act()
			p1.delay-=1
			return
		end
		if p1.d>0 then -- input delay
			return
		end
		if btn(0) then
			nx= p1.x-1
		end
		if btn(1) then
			nx =p1.x+1
		end
		
		-- only move one dir
		if nx==p1.x  then
			if btn(2) then
				ny = p1.y-1
			end
			if btn(3) then
				ny = p1.y+1
			end
		end
					
		-- stand still
		if btnp(5) then
			sfx(0)
			message("wait 1“")
			enem_act()
			return 
		end
		
		-- no movement
		if nx==p1.x and ny==p1.y then
			p1.act=false
			return
		else
			p1.d=7
		end
				
		-- enemy collision
		local e = check_enemy(nx,ny)
		if e then
			-- don't move, attack!
			p1.act=true
			nx=p1.x
			ny=p1.y
			local dmg = rnddmg(p1.dmg)
			message("you hit "..e.name.." "..dmg.."‡")
			e.efx(128)
			hurt(e,dmg)		
		else				
			-- move 
			p1.act = mov_obj(nx,ny,p1)
		end
			
		-- enems act
		if p1.act then
			sfx(0)
			enem_act()
		end	
	end
	
	p1.addxp = function(xp)
		p1.xp+=xp
		message("gained "..xp.." xp!")
		
		-- level up
		if p1.xp/(p1.lvl*2+3)>=1 then
 		p1.xp-=p1.lvl*2+3
 		p1.lvl+=1
 		p1.maxhp+=1
   heal(p1,99)
 		-- mana on even levels
 		if(p1.lvl%2==0) p1.maxmana+=1
			charge(p1,99)
			
			-- increase dmg on odd
			if(p1.lvl%2==1) p1.dmg+=1
			message("’ you leveled up! ’")
		end
	end
end

function make_enemy(x,y,ty)
	local e = make_obj()
	if x!=nil then
		e.x=x
	 e.y=y
	end
	e.spr=48+flr(rnd(29))
	if ty then
		e.spr=ty
	end
	
	local s=e_stats[e.spr]

 e.name = s[1]
 e.hp=tonum(s[2])
 e.dmg=tonum(s[3])
 e.spd= tonum(s[4])
 e.xp=tonum(s[5])
 --e.tier = tonum(s[6]) 
 
 e.delay=0
 
 e.special = function() end 
 e.special2 = function() end 
 
	local name = e.name 
 if name=="spider" or name=="widow" then
 	e.special = function()
 		-- web
 		if(flr(rnd(2))==0 and board[e.y][e.x]==0) board[e.y][e.x]=6
 	end
 end
 if name=="demon" or name=="dragon" or e.name=="elemental" then
		e.burn=false
		e.special_t = 0
 	e.special = function()
 		-- fire / 5“
 		e.special_t+=1
 		if e.special_t>=5 and board[e.y][e.x]!=20 then
				board[e.y][e.x]=5
 		 e.special_t=0
 		end
 	end
 end
 if name=="cultist" then
 	e.special_t=0
 	e.special = function()
 		-- portal after 13“
 		if e.special_t<13 then
 			e.special_t+=1
 			if e.special_t==12 then
					message("… cultist opened portal")
 				make_spawner(e.x,e.y)
 			end
 		end
 	end
 end

 if name=="knight" then
 	e.def+=.15
 end
 
 -- stats for ranged enems
 e_stats["wizard"]={6,5,3,"bolted",80,54}
 e_stats["archer"]={2,5,2,"shot",92,76}
	local stats = e_stats[name]
 if stats then
 	e.special_t=stats[1] -- starts with blast
 	e.special= function()
 		-- shoot freq
 		if e.special_t<stats[1] then
 			e.special_t+=1
 		end
 		if e.special_t==stats[1] then
 			e.spr=stats[6]
 			if (e.x==p1.x or e.y==p1.y)
 				and get_dist(e,p1)>1 and  get_dist(e,p1)<=stats[2] then

					-- see if there is a wall in the way
					-- get direction
					local di=-1
					for d in all(dirs) do
						if sgnz(e.x-p1.x)==d.x 
							and sgnz(p1.y-e.y)==d.y then
							di=d.v
						end
					end

     local t = ranged(p1,e,di,stats[2])

    	if t!=nil and t.name==e.name then
						local d = rnddmg(stats[3])
						message(e.name.." "..stats[4].." you "..d.."‡")
						sfx(10)
						e.efx(136)
      p1.efx(160)
						hurt(p1,d) 
						e.spr=stats[5]
						e.special_t=0   	
						e.delay = 1 
    	end
 			end
 		end
 	end
 end
 if name=="cold slime" then
 	e.special_t = 1
 	e.special2 = function()
 		-- when hit by slime, frozen 1 turn
 		if e.special_t==1 and abs(e.x-p1.x)+abs(e.y-p1.y)<=1 then
 			p1.delay+=1 -- turn
 			p1.d=15 -- input delay
 			message("! frozen 1“ by slime")
 			e.special_t=0
 			p1.act=true
 		else
 			e.special_t=1
 		end
 	end
 end
 if name=="bat" or name=="fury bat" then
 	e.fly=true
 end
	if name=="ghost"or name=="banshee" then
		e.fly=true
		e.thru=true
	end
	if(name=="miner") e.thru=true
			
	e.act = function()				
		if e.delay>0 then
			e.delay-=1
			return
		end
		
		-- special actions
		e.special()
		
		-- delay can also be set
		-- during special
		if e.delay>0 then
			e.delay-=1
			return
		end
		
		-- attack when close enough
		local dx = abs(e.x-p1.x)
		local dy = abs(e.y-p1.y)
		
		if dx+dy==1 then
			-- attacking]
			local dmg = rnddmg(e.dmg)
			message(e.name.." hit you "..dmg.."‡")
			hurt(p1,dmg)
			p1.efx(160)
			e.special2()
		else	
			-- movement
			local step = path(e.x,e.y,p1.x,p1.y,e.fly,e.thru,e.burn)
				
			-- if no path valid path found
			-- try thru walls
			if e.x==step.x and e.y==step.y then
				step = path(e.x,e.y,p1.x,p1.y,fly,true)
			end
			-- miner move
			if e.name=="miner" and check_wall(step.x,step.y) then
				-- mine, don't move thru
				hit_wall(step.x,step.y,10)
			end
				
			mov_obj(step.x,step.y,e)			
			
		end
	end
		
	e.die = function()
		del(enems,e)
		del(objs,e)
		score+=100
		message(e.name.." killed")
		
		-- adds xp = (hp+dmg)/4
		p1.addxp(e.xp)
		e.efx(132)
		
		do_loot(e.x,e.y,1)
	end

	add(enems,e)
	return e
end

function make_item(x,y,s)
	local i = {}
	if x==nil then
		rndxy(0)
		x=xx
		y=yy
	end
	
	-- make a copy of the object
	tablecopy(item_list[s],i)
	
 i.u = function() end
	i.x=x
	i.y=y
	
	i.die = function()
		del(items,i)
		del(objs,i)
	end
	
	add(items,i)
	add(objs,i)
	
	return i 
end

function make_portal(x,y)
	local p = make_obj()
	p.x=x
	p.y=y
	p.t=0
	p.spr=7
	p.efx(136)
	
	p.act = function()
		if area==10 then
			music(1)
			state=st_end
			p1.act=false
			return
		end
		gen_board()
		
		-- update nearest enemy stats
 	update_near()
		p1.addxp(2)
		sfx(3)
		message("entered area: "..area)
		p1.x=x
		p1.y=y
		board[y][x]=0 -- land on blank
		
		-- delay enems 1 turn on new board
		for e in all(enems) do
			e.delay=1
		end
	end	
	
	p.u = function()
		p.t+=1
		p.spr=7+(p.t%20)/10
	end
	
	add(items,p)
	
	message("Ž exit portal opened!")
end

function make_spawner(x,y)
	local p = make_obj()
	p.x=x
	p.y=y
	p.t=0
	p.name="enemy portal"
	p.delay=10
	p.spr=23
	p.efx(176)
	
	-- needed for near stats
	p.hp=1
	p.dmg=0
	
	p.act = function()
		p.delay-=1
		if p.delay==0 then
			local e = make_enemy(p.x,p.y)
			update_near()
			p.die()
		end
	end	
		
	p.u = function()
		p.t+=1
		p.spr=23+(p.t%20)/10
	end
	
	p.die = function()		
		del(enems,p)
		del(objs,p)
		rndxy(0)
		make_spawner(xx,yy)
		
		if(p.hp<=0)	do_loot(p.x,p.y,1)
	end
	
	add(enems,p)
	
	message("… enemy portal opening")
end

function make_obj()
 local o = {}
 o.hp=0
 o.maxhp=0
 o.mana=0
 o.maxmana=0
 
 o.def=.05 -- 5% block 
 o.burn=true
 o.fly=false
 o.thru=false
 o.swim=false
 
 -- blank update by default
 o.u = function()
 end
   
 -- simple 4 frame efx
 o.efx = function(e,l,loop)
 	if(loop==nil) loop=false
 	if l==nil then
 		return make_efx(o.x,o.y,e,4,loop)
 	else
 		return make_efx(o.x,o.y,e,l,loop)
 	end
 end
  
 o.die = function()
 	del(objs,o)
 end
 
 add(objs,o)
	return o 
end

function make_efx(x,y,s,l,loop)
	local e = {}
	if(loop==nil) loop=false
	e.start=s -- starting 
	e.spr=s -- current
	e.len=s+l -- ending sprite
	e.t=0
	e.spd=1
	e.x=x
	e.y=y
	
	e.dir=false
	if(p1.x>e.x) e.dir=true
	
	e.u = function()
		-- increase timer
		e.t+=1
			
		-- increase frame based on spd
		if e.t>e.spd then
			e.t=0
			e.spr+=1
			
			-- if reached last frame, end
			if e.spr>=e.len then
				if loop then
					e.spr=e.start
				else	
					e.die()
				end
			end
		end
	end
	
	e.die = function()
		del(efx,e)
	end
	
	add(efx,e)
	return e
end

heal = function(o,h)
 	o.hp=min(o.maxhp,o.hp+h)
end

charge = function(o,m)
 	o.mana=min(o.maxmana,o.mana+m)
end


-->8
-- check functions for board

function check_wall(x,y)
	if (not check_bounds(x,y)) return false
	
	local v = board[y][x]
	return (v>=35 and v<=39)
		or (v>=112 and v<=116)
end

function check_bounds(x,y)
	return(bound(x)==x and bound(y)==y)
end

function check_pit(x,y)
	-- no pit out of bounds
	if not check_bounds(x,y) then
		return false
	end
	
	return board[y][x]==2
end


function check_item(x,y)
	local list={}
	for i in all(items) do
		if i.x==x and i.y==y then
			add(list,i)
		end
	end
	return list
end

function check_fire(x,y)
	if(bound(x)!=x or bound(y)!=y) return false
	return board[y][x]==5
end

function check_enemy(x,y)
	for e in all(enems) do
		if e.x==x and e.y==y 
			and e.spr!=25 and e.spr!=26 then
			-- spawners dont count
			return e
		end
	end	
	return nil
end

function check_free(x,y)
	return board[y][x]==0 and
		not check_enemy(x,y) and
		#check_item(x,y)==0 
end
-->8
-- helper functions
function dxdy_from_dir(dir)
	for d in all(dirs) do
		if d.v==dir then
			dx=d.x
			dy=d.y*-1
		end
	end
end

-- returns p with x/y coords
function path(sx,sy,ex,ey,fly,thru,burn)
	-- start with curr sq
	-- make a-star grid
	local q = {} -- queue
	local st = {} -- starting square
	
	local effort = 0
	
	st.x=sx
	st.y=sy
	st.h=abs(sx-ex)+abs(sy-ey) -- heuristic
	local astar={}
	for i=0,12 do
		astar[i]={}
		for j=0,12 do
			astar[i][j]=999
		end
	end
	astar[sy][sx]=0
	add(q,st)
	
	-- loop to fill astar grid
	while #q!=0 do
		-- give up after 10 checks
		effort+=1
		if(effort==10) return st
		
  -- dequeue 
		local n = q[1]
		del(q,n)
		
		--check in 4 directions
		-- add valid nodes
		
		-- cycle to vary first direction
		add(dirs,dirs[1])
		del(dirs,dirs[1])
		for d in all(dirs) do
			local sq ={}
			sq.x=n.x+d.x
			sq.y=n.y+d.y
			sq.h=abs(ex-sq.x)+abs(ey-sq.y)
			sq.prev=n
			
			local x=sq.x
			local y=sq.y
			
			-- if we found end, return
			-- the first step 
			if x==ex and y==ey then
				-- loop to find first step
				local sq_first_step = {}
				while sq.prev!=nil do
					sq_first_step.x=sq.x
					sq_first_step.y=sq.y
					sq = sq.prev
				end
				return sq_first_step
			end
			if check_bounds(x,y) 
			 and astar[y][x]==999 then
			 -- thru walls / fire 
				if (thru or not (check_wall(x,y) or (burn and board[y][x]==5)))
					and (fly or not check_pit(x,y))
					and not check_enemy(x,y) then					
				
					astar[y][x]=sq.h

					-- add to q (sorted by h)
					enqueue(q,sq)
				end
			end			
		end
	end
	-- didn't find path: return start
	return st
end

function enqueue(q,sq) 
	for i=1,#q do
		if q[i].h>sq.h then
			j = #q+1
			repeat
				q[j]=q[j-1]
				j-=1
			until j==i
			q[i]=sq
			return
		end
	end
	add(q,sq)
end

-- dmg is 1-d
function rnddmg(d)
	if (d==0) return 0
	return flr(rnd(d))+1
end

function enem_act()
	-- player cooldown
	for menu in all(sub_menus) do
		for c in all(menu) do
			if(c.cd>0)	c.cd-=1
		end
	end
	
	-- enemies move
	for e in all(enems) do
		local turns = flr(rnd(e.spd))+1
		for i=1,turns do
			add(actions,e.act)
		end
	end
	
	-- portal / spawner 
	-- appearance
	brd_timer-=1
	rndxy(0)
	if (brd_timer==0) make_portal(xx,yy)
	if(brd_timer==-10) make_spawner(xx,yy)
	
	-- update nearest enemy stats
	update_near()
end


function rndxy(r)
	local rr=12-r
 xx = flr(rnd(rr))
 yy = flr(rnd(rr))
 while not check_free(xx,yy) do
	 xx = flr(rnd(rr))
 	yy = flr(rnd(rr))
 end
end

function rndxy_box(r)
	free=false
	local try=0
	while not free and try!=15 do
		try+=1
		
		rndxy(r)
		free=true
		
		for i=0,2 do
			for j=0,2 do
				if board[yy+i][xx+j]!=0 then
					free=false				
				end
			end
		end
	end
end

function message(s)
	for i=4,2,-1 do
		msg[i]=msg[i-1]
	end
	msg[1]=s
end

function add_item(it)
	sfx(2)
	
	message("’ got "..it.text.."!")
	--update num/text if you already have
	for itt in all(my_items) do
		if itt.spr==it.spr then
			itt.num+=it.num
			it_text_u(itt)
			return
		end
	end
		
	itt={}
	tablecopy(it,itt)
	
	if #my_items==0 then
		add(my_items,itt)
	else
 	-- add to the bottom, above 'close'
 	add(my_items,my_items[#my_items])
  my_items[#my_items-1]=itt
 end
end

function it_text_u(itt) 
	for j=1,#itt.text do
		if sub(itt.text,j,j)=="(" then
			itt.text=sub(itt.text,1,j)..itt.num..")"
			return
		end
	end
end

function add_skill(sk)
	sfx(2)
	sk.cd=0
	
	if #my_skills==0 then
		add(my_skills,sk)
	else	
 	-- add to the bottom, above 'close'
 	add(my_skills,my_skills[#my_skills])
  my_skills[#my_skills-1]=sk
 end
 
 message("’ learned "..sk.text.."!")
end

function update_near()
 -- update stat info
	-- for 3 nearest enemies
	near = {}

	-- add all enems (not portals)
	for e in all(enems) do
		if(e.name!="enemy portal")	add(near,e)
	end
	while #near>3 do
		-- remove furthest
		local far=0
		local remove={}
		for e in all(near) do
			local dist = get_dist(e,p1)
			if dist>far then
				remove=e
				far= dist
			end
		end
		del(near,remove)
	end
end

-- function for ranged targeting
function ranged(source,ignore,dir,range)
	-- hit the closest one only
	close_dist=999
	local closest=nil
	for e in all(enems) do
		-- based on dir
		if (dir==0 and e.y==p1.y and e.x<source.x)
			or (dir==1 and e.y==p1.y and e.x>source.x)
			or (dir==2 and e.x==p1.x and e.y<source.y)
			or (dir==3 and e.x==p1.x and e.y>source.y) then
			local dist = get_dist(e,source)
			if dist<close_dist 
				and dist<=range then
				closest=e
				close_dist=dist
			end
		end				
	end
	
	-- test for walls
	local xx = source.x
	local yy = source.y
	dxdy_from_dir(dir)
	-- loop until range/ out of bounds, you found a wall, or the distance is 
	-- past an enemy you already found 
	while check_bounds(xx,yy) 
		and (abs(xx-source.x)+abs(yy-source.y)<close_dist)
		and (abs(xx-source.x)+abs(yy-source.y)<range) do 
		xx+=dx
		yy+=dy
		if check_wall(xx,yy) then
			closest = make_obj()
			closest.x = xx
			closest.y = yy
			closest.name= get_wall_type(xx,yy)
			closest.hp = 40-board[yy][xx]
			close_dist = get_dist(closest,source)
		end
	end
	
	return closest
end

-- x,y, range
function aoe(x,y,r)
	-- find all targets in range
	-- makes a square.
	local targets = {}
	for e in all(enems) do
		if abs(e.x-x)<=r and abs(e.y-y)<=r then
			add(targets,e)
		end
	end
	
	-- make wall targets
	for i=x-r,x+r do
		for j=y-r,y+r do
			if check_wall(i,j) then
				local wall = make_obj()
				wall.x=i
				wall.y=j
				wall.spr=8
				wall.name="wall"
				add(targets,wall)
				wall.die()
			end
		end
	end
	return targets
end

--returns true on a move/wall attack
function mov_obj(x,y,o)
	-- check for bounds
	if x!=bound(x) or y!=bound(y) then
		return false
	end
	
	-- check for walls
	if check_wall(x,y) and not o.thru then
		local	dmg = rnddmg(o.dmg)
		local wall = get_wall_type(x,y)
		-- text for player
		local destroyed=hit_wall(x,y,dmg)
		if o==p1 then
			if destroyed then
				message("broke "..wall)
			else
				message("you damaged "..wall.." "..dmg.."‡")
			end
		end
		
		make_efx(x,y,128,4)
		return true
	end
	
	-- pit
	if check_pit(x,y) then
		if o!=p1 then
			if not o.fly then
				message(o.name.." fell into pit")
		  hurt(o,999)
		 end
		else
			if not o.fly then
		 	return false
		 end
	 end
	end

	-- clear webs when leaving
	-- if not a spider
	if board[o.y][o.x]==6 and
		o.name!="spider" and
		o.name!="widow" then
		board[o.y][o.x]=0
	end
	
	-- web
	if board[y][x]==6 then
		o.delay=1
		message(o.name.." stuck 1“")
	end	
	
	-- move
	o.x=bound(x)
	o.y=bound(y)
		
	-- water/swim
	if not o.fly and board[y][x]==20 then
		if(o==p1)	sfx(4) -- sound for player
		o.delay=1
		message(o.name.." swam 1“")
		make_efx(x,y,168,4)
	end
	
	-- fire
	if board[y][x]==5 then
		if o.burn then
			local dmg = rnddmg(2)
			hurt(o,dmg)
			message(o.name.." burned for "..dmg.."‡")
			o.efx(184)
			board[y][x]=0 
		else
			if o.name=="you" then
				heal(p1,2)
				charge(p1,1)
				sfx(2)
				board[y][x]=0 
				message("’ amulet: +2‡ and 1†")
			end
		end
	end
	
 -- item pickup for player
 if o==p1 then
		local itz = check_item(x,y)
		for pickup in all(itz) do
			pickup.act()
			pickup.die()
			o.efx(136)
			-- amulet
			if(pickup.spr==15) p1.burn=false
		end
	end
	
	return true
end

function sgnz(n)
	if(n==0) return 0
	return sgn(n)
end

-- returns true if destroyed
function hit_wall(x,y,d)
	d = min(d,10) -- limit for logic below
	sfx(9)
	local v = board[y][x]
	if (v+d>39 and v+d<112)
		or (v+d>116) then
		board[y][x]=0
		-- ice->water
		if (v+d>116) board[y][x]=20
		return true
	end
	board[y][x]+=d
	return false
end

function bound(n)
	if(n<0) return 0
	if(n>11) return 11
	return n
end

function get_dist(o1,o2)
	return (abs(o1.x-o2.x)+abs(o1.y-o2.y))
end

function do_loot(x,y,l)
	loot-=l
	if loot<=0 and board[y][x]==0 then
		if rnd(1)<.25 and #skills>0 then
			-- 25% chance skill
			local rndskill=skills[ceil(rnd(#skills))]
			del(skills,rndskill) -- remove from game
			make_item(x,y,rndskill)
		else
			--75% potion
			make_item(x,y,9+flr(rnd(3)))
		end
		loot=3
	end
end

function get_wall_type(x,y) 
	if(board[y][x]<=39) return "wall"
	return "ice"
end

function tablecopy(a,b)
	for k,v in pairs(a) do
		b[k]=v
	end
end

hurt = function(o,d)
	if o.name=="wall" or o.name=="ice" then
		hit_wall(o.x,o.y,d)
		sfx(9)
		return
	end
	if rnd(1)<o.def and d!=999 then
		message("’ "..o.name.." blocked!")
		sfx(11)
		return
	end
	sfx(1)
	o.hp=max(0,o.hp-d)
	if o.hp==0 then
		if(o.die) o.die()
	end
end
-->8
-- board generation
function gen_board()
	-- reset
	objs = {}
	enems = {}
	items = {}
	add(objs,p1)
	area+=1
	
	for i=0,12 do
		board[i]={}
		for j=0,12 do
			board[i][j]=0
		end
	end
	
	-- #actions before portal
	brd_timer = 20
	
	--lines
	local j=0
	while j<2 do
	 rndxy(3)
	 for i=0,3 do
	 	board[yy][xx+i]=35
	 end
	 j+=1
	end
  		
	-- boxes
	for i=1,areas[area][1] do
		gen_struct()
	end
	
	-- pits
	for i=1,areas[area][2] do
		gen_box(2,2)
	end
	
	-- water
	for i=1,areas[area][3] do
		gen_box(2,20)
	end

	-- fire
	for i=1,areas[area][4] do
		gen_box(2,5)
	end
	
	-- fire
	rndxy(1)
	board[yy][xx]=5
	 
	-- more enemies later
	local num_enem=flr(area/4)+2
	for i=1,num_enem do
		rndxy(0)
		while check_wall(xx,yy) or
			check_pit(xx,yy) do
			rndxy(0)
		end
		if area==1 then
			make_enemy(xx,yy,flr(rnd(5))+48)
		else
			make_enemy(xx,yy)
		end
	end
	-- gold
	rndxy(0)
	make_item(xx,yy,4)
	--rnd potion odd floors
	if area%2==1 then
		rndxy(0)
		make_item(xx,yy,9+flr(rnd(3)))
	end
	-- rnd skill/3rd area
	if area%3==1 and #skills>0 then 
		rndxy(0)
		local rndskill=skills[ceil(rnd(#skills))]
		del(skills,rndskill) -- remove from game
		make_item(xx,yy,rndskill)
	end	
end

function gen_box(size,ty)
	rndxy_box(size)
	for i=yy,yy+size-1 do
		for j=xx,xx+size-1 do
			board[i][j]=ty
		end
	end
end

function gen_struct()
	rndxy_box(2)

	-- corners
 board[yy][xx]=37
 board[yy][xx+2]=37
 board[yy+2][xx]=37
 board[yy+2][xx+2]=37
 
 -- close one random side
 local x =0
 local y =1
 if flr(rnd(2))==0 then
 	x = 1
 	y = 0
 end 
 if flr(rnd(2))==0 then
 	x+=1
 	y+=1
 end
 board[y+yy][x+xx]=37
end
-->8
-- init items/skills

function init_choice(n)
	local s= c_stats[n]
	local c = {}
	c.cd=0
	c.spr=tonum(s[1])
	c.text=s[2]
	c.descr=s[3]
	c.dmg=tonum(s[4])
	c.mana=tonum(s[5])
	c.maxcd=tonum(s[6])
	c.ranged=sub(s[7],1,1)
	c.range=tonum(sub(s[7],2,2))
	c.num=tonum(s[8])
	c.utext=s[9]
	c.def=tonum(s[10])
	
	c.act2=function() 
		enem_act()
		return true
	end
	
	c.act=function()
		sel_range = c.range
		if c.ranged=="d" then
			state=st_wait_dir
		end
		if c.ranged=="t" then
			state=st_wait_sel
		end
		if c.ranged!="n" then
			-- sel is a dir or tgt point
			inter = function(sel)
				targets= {}
				if c.ranged=="d" then
			 	add(targets,ranged(p1,"t",sel,c.range))
			 else
			 	targets = aoe(sel.x,sel.y,1)
			 end
			
				if c.dmg>0 then
					sfx(1)
 				local dmg
 				if c.dmg=="d" then
 					dmg=p1.dmg
 				else
 				 dmg = rnddmg(c.dmg)
 				end
 				for t in all(targets) do
 					message(c.text.." hit "..t.name.." "..dmg.."‡")
 					hurt(t,dmg) 
 				end
 				if(#targets==0)	message(c.text.." missed")
 			end
 			return c.act2(sel,targets)
			end
		end
	end
	return c
end

-- init items based on
-- data from memory
function init_items()
	item_list ={}
	for i=0,num_items do
		local it= {}
		it.ch = init_choice(i+1)
		it.act = function() --pickup
			ch=it.ch
			if ch.mana<=0 and ch.spr!=27 then
				if ch.def>0 then
					p1.def+=ch.def
				end
				
				add_item(ch)
			else
				add_skill(ch)
			end
		end
		
		it.spr = it.ch.spr
		if(it.ch.mana!=0 or it.ch.spr==27) it.spr=25
		item_list[it.ch.spr] = it
	end
end

-- finalize item actions 
function init_items2()
	-- pots
	item_list[9].ch.act = function()
		heal(p1,4)
  p1.efx(144,6)
		sfx(2)
	end
	item_list[10].ch.act = function()
		charge(p1,2)
		manaefx()			
		sfx(2)			
	end
	item_list[11].ch.act = function()
		heal(p1,2)
		charge(p1,1)
  p1.efx(144,6)
		manaefx()		
		sfx(2)			
	end
	item_list[85].ch.act = function()
		p1.maxhp+=1
		p1.hp=p1.maxhp
  p1.efx(144,6)
		sfx(2)			
	end
	
	-- gold
	local i ={}
	i.spr=4
	i.act = function()
		score+=100
		xpbonus=ceil(area/2)
		message("’ picked up gold +"..xpbonus.." xp")
		p1.xp+=xpbonus
		sfx(2)
	end
	item_list[i.spr]=i
		
	--gust
	item_list[30].ch.act2 = function(dir)
		sfx(1)
		
		local power=3
		
	 closest = ranged(p1,"t",dir,power)
		
		dxdy_from_dir(dir)
		
		if closest!=nil then					
			-- push into hit or until power is gone
			message(closest.name.." pushed")
			power-=abs(closest.x-p1.x)+abs(closest.y-p1.y)-1
			repeat
				mov_obj(closest.x+dx,closest.y+dy,closest)
				power-=1
			until power==0
			closest.delay=1
		else
			-- ending coords if nothing hit
			closest= {}
			closest.x=p1.x+dx*power
			closest.y=p1.y+dy*power
		end
		
		-- clear fire / efx 
		-- p1<-->gust's end
		local gx = p1.x
		local gy = p1.y
		repeat
			gx+=dx
			gy+=dy
			if(check_fire(gx,gy)) board[gy][gx]=0
			make_efx(gx,gy,164,4)
		until gx==closest.x and gy==closest.y
		
		sfx(7) 
		p1.act=true
		enem_act()				
		return true
	end
	
	--freeze
	item_list[46].ch.act2 = function(sel,t)										
		sfx(1)
	 closest = t[1]				
		if closest then						
			message(closest.name.." is frozen 3“!")
			
			-- freeze nearby water
			for d in all(dirs) do
				if board[bound(closest.y+d.y)][bound(closest.x+d.x)]==20 then
					board[bound(closest.y+d.y)][bound(closest.x+d.x)]=112
				end
			end
			board[closest.y][closest.x]=112			
			
			closest.delay=3 --2 turns 	
			closest.efx(180)
		else
			message("freeze hit nothing")
		end
		enem_act()
		return true
	end
	
	-- fairy bolt
	item_list[41].ch.act2 = function(sel,t)
	 closest = t[1]				
		if closest and closest.dmg then
			closest.dmg-=1
			message(closest.name.." dmg -1")			
			closest.efx(176)
		else
			message("fairy bolt missed")
		end
		enem_act()
		return true
	end
	
	-- pickax
	item_list[43].ch.act2 = function(sel)	
		dxdy_from_dir(sel)
		local x = p1.x+dx
		local y = p1.y+dy
		
		if check_wall(x,y) then
			message("pickax broke wall")
   board[y][x]=0
   do_loot(x,y,2)
			sfx(1)
			make_efx(x,y,128,4)
		else
			enem_act() -- only if hit enem			
		end
		return true
	end	
	
	-- spinslice
	local i={}
	i.spr=25
	i.act = function()
		local c = init_choice(8)
		c.act = function()	
			targets = aoe(p1.x,p1.y,1)
			local dmg = rnddmg(p1.dmg)
			for t in all(targets) do
				hurt(t,dmg)
				message("you hit "..t.name.." "..dmg.."‡")
				t.efx(128,4)
				sfx(1)
			end	
			enem_act()
		end	
  add_skill(c)
	end
	item_list[13]=i
	
	-- teleport
	item_list[28].ch.act2 = function(sel)		
		if check_enemy(sel.x,sel.y) or check_pit(sel.x,sel.y) or check_wall(sel.x,sel.y) then
			message("! please choose open space")
			return false
		end
						
		sfx(3)

		p1.efx(176)
		mov_obj(sel.x,sel.y,p1)				
		p1.efx(176)
		
		enem_act()
		return true
	end	
	
	-- scroll blink
	item_list[87].ch.act2 = item_list[28].ch.act2

	-- scroll haste
	item_list[88].ch.act = function()
		for e in all(enems) do
			e.delay=3
			sfx(12)
		end
	end
 
 -- polymorph
	item_list[31].ch.act2 = function(sel)
		local e = check_enemy(sel.x,sel.y)
		if not e then
			message("! please choose enemy")
			return false
		end
						
		sfx(3)
		new = make_enemy(sel.x,sel.y)
		del(enems,e)
		del(objs,e)
		-- enem doesn't move while changing
		new.delay=2 				
		
		new.efx(176)
  p1.delay=1 -- lets enemies act again
  
		return true
	end
 
 -- build
	item_list[27].ch.act2 = function(sel)				
		if check_enemy(sel.x,sel.y) or check_wall(sel.x,sel.y) then
			message("! please choose open space")
			return false
		end
						
		sfx(3)
		board[sel.y][sel.x]=35
		
		enem_act()
		return true
	end	
	
		
	-- bombs
	item_list[44].ch.act2 = function(sel)											
		enem_act()
		sfx(8)
		return true
	end
	
	-- scrl:meteor
	item_list[81].ch.act2 = function(sel)											
		enem_act()
		sfx(8)
		return true
	end
	 
 -- flood
	item_list[29].ch.act2 = function(sel,targets)						
		local x=sel.x
		local y=sel.y
						
		sfx(7)
		for i=-1,1 do
			for j=-1,1 do
				local bx = bound(x+i)
				local by = bound(y+j)
				if(not check_wall(bx,by)) board[by][bx]=20
			end
		end
				
		for t in all(targets) do
			hurt(t,1)
			message("you hurt "..t.name.." 1‡")
		end	
		
		enem_act()
		return true
	end
end

function has_mana(m)
	if p1.mana<m then
		message("! not enough mana")
		p1.d=15
		sfx(5)
		state=st_game
		menu=0
		return false
	end
	return true
end

function use(c)
	c.cd=c.maxcd
	
	if (not has_mana(c.mana)) return
	p1.mana-=c.mana
	
	if(c.utext!="") message(c.utext)
	
	-- only decrease certain items
	if c.num>0 then
		c.num-=1
		it_text_u(c)
	end
	
	c.act()
	if(not inter and c.num==0) del(my_items,c)
end 

function manaefx()
	for d in all(dirs) do
		make_efx(p1.x+d.x,p1.y+d.y,152,6)
	end
end
__gfx__
0000000000000000c0d09000d707c787000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d0c0e00077777777000000000000000006007006000ccc00000aaa0000004000000440000000000000040000000677000000000000000cc0
000000000000000020e040000000000000000000000000000060706000caaac000accca00006060000600600000444000006400000065770000000000000c00c
00000000000000003040f00040300000000a0000000080000006760000caaac000accca000068600006c760000600060006004000006057700aaaa70000c000c
000000000000000090c0400030401000009ba900000090000777077700caaac000accca000688760006cc600006bb760069994970006005700aaaaa000c0000c
00000000000000006050b000402040000aaa98a00009a8000006760000caaac000accca000688860006cc600006bbb600060040000444057009aaaa000c0a0c0
000000000000000050d08000302000100ac9aaa0008aa9000060706000caaac000accca000066600000660000006660000064000000200500009aa00000a9a00
0000000000000000b0b0b0003020002000000000089aa98006007006000ccc00000aaa000000000000000000000000000004000000020500000090000000a000
00000000000000000000000030201010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070000000000074700000000205030000000000000000000000000000ee000de0dd000ed0470007400000000000440000ee000de000000000000000000000000
070cc000000cc747000cc04b302010100c00c0000880880000ccc0000dde0de00eed0ed00477677400000cc0066446600dde0de00000000000007770000e0e00
070c9044000c9040000c9044205010200c6cc6cc088888000ccc0c00000dde00000eed0004776774000dc67c06644660000dde000c00c000000755700ee5e5ee
09cccc4400cccc9000cccc90203010400cc6cc6c088888000ccccc0000edd00000dee000047767740dd6677c0dd44dd000edd0000c6cc6c00075000005575755
040dd044090dd040090dd040777777770ccccccc008880000ccccc000ed0edd00de0dee004476744000dc67c000440000ed0edd00cc6cc60007500000edd5dde
000cc040000cc000000cc040000000000ccccccc0008000000ccc000ed000ee0de000dd00004440000000cc000044000ed000ee00cccccc00007505000edede0
000cc000000cc000000cc040000000000ccccccc00000000000000000000000000000000000000000000000000044000000000000000000000000000000e0e00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0700000000000747000000000666666d0616666d0616666d0616666d0616661d0000000000000000000000000000000000000a00000000000c00c00c00000000
070cc000000cc747000cc04b06ddddd506d1ddd506d1ddd506d1d1d506d1d1d50656765000000ee000aa00aa00077700000040000000088000cc7cc0660cc066
070c9044000c9040000c904406ddddd506ddddd506ddddd106dd1dd1061d1dd1076567600002ef7e000a55a00000067000006000000289a800c060c0776c9677
09cccc4400cccc9000cccc9006ddddd506ddddd506dddd1506dddd1501dddd1500765600022ff77e000667700000046700055d0002299aa80c76667c079cc970
040dd044090dd040090dd04006ddddd506ddddd5061dddd50611d1d50611d1d1006765000002ef7e0056006500004006002555d0000289a800c060c0000dd000
00cccc4000cccc0000cccc4006ddddd506dd1dd501dd1dd501dd1dd501dd1d150056760000000ee00056006500040006002555d00000088000cc7cc0000cc000
00cccc0000cccc0000cccc400d5555550d5551550d5551550d5551550d5151550000000000000000000000000040000000025500000000000c00c00c00000000
0000000000000000000000000000000000bbbb0000000000000000000000000000000000000000000000000000000000004a4a40000000000000000000000700
000000000000000000000000000000000b3003b000505000008000bb0070070000000000000000440000000000d0d00004a000a0020000d00000000000500070
00000000000000000000000000077000b30000b0505050500008804b0079978000077700000bb04460006006d0d0d0d04a000a4000220ded0000000000055070
000bb000000505000003300000078000b0000bb0555555500008f044000998a800787800000bb040d6000767ddd8ddd0a0000400002e00d0000c700000059070
000bb00005575755003bb30007767770b0b07b70005550000f8888f009922990007777000bb22bb00d66666500d8d00040407470e2222e0000ccc70000055590
00b22b0000dd5dd003b3bb30000670000b00bbb0575557500008804000022000007777000002204000666600d7ddd7d00a004440002200000cc1cc7000055040
00022000000d0d00036bbb3000700700000008005075705000888840009009000077770000b00b0000600600d07d70d000000800022220000c6cc1c000555500
00b00b0000000000003bb30000700700000080800500050000888840009009000707070000b00b00006706700d000d00000080800222200000cccc0000555500
00000000000000000008000000200200000000000000000007002200005507700000000000000000033333300c00c000000000000000000000000000eeeeeeee
0000667008000070000880000020026000000a000000000070028e800587870700333000000000003b3bbb6300c00c00003064000006560000000046eeeeeeee
00b6040608660767008988000008986600000400000000002002ee000577040000073700007007003bbbbbb3000ccc000006304000086800000ff046ee8ee8ee
00bb040000640070008999800009906000bbddd000080800200022000055040003033000007aa7003bb6b3b30cc8c8000063800400566660000ff046eeeeeeee
bb22bb006666664008a9a9804444406000bbddd00887878822222200005777003b33ba90000aa00033bbb6b3c0cccc0008333384060566050ff22ff0eeeeeeee
002204000066004008a9a980444444400022bb00002282202222222000550400bb3bb99800a22a003bb3bbb300cccc00006330040006650000222240eeeeeeee
0b00b00006006000089999804004006000220000000202002020200705550400033b3088000220003b6bb3b300cccc00003633400060005000222200eeeeeeee
0b00b0000600600000888800400400600b00b0000000000070707000555504003330300000a00a00033333300c0c0c00003364000050006000f00f00eeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000
008000660fffff0000000067000000000000000000004000000076000fffff000fffff00000ccc0000008800000099000030040000007000e000220000000000
0008804604fffff00000cc460000000000004b00000606000006007004fffff004fffff000007c700008787000097970000330400007c7000002cc2000000000
0008f04404f828f0000004c00000000000004000000676000070000604fedef004f99ff00cc0cc00088088800990999000038004007ccc700ee2cc2000055000
0f8888f000fffff0000040c00070049900088e000006e6000060000700fffff000faaaf0cddccda9822882a9922992a80833338407c0c0c7edde220200566500
0008804000ff82f00004000000074444008888e00006e6000007006000ffedf000ff99f00ddcdd880228228802292288000330040000c000edde000005667650
0088884000fffff0004000000050022400288880000060000004007000fffff000fffff000ccdc000088280000992900003333400000c0000ee00020056d6650
00888840000fffff0400000000000000000288000000000000040006000fffff000fffffcccc0c00888808009999090000333400000000000000e00000566500
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa90a1aaaa90a1aaaa90a1aaaa90a1aaa190099aaa000000550000000000000000000ccc000008880000099900000007000000000000000700000000000
0a9999940a9199940a9199940a9191940a9191940944444a0000500500000000000000000007c70000078700000797000007c000000000000000c70000000000
0a9999940a9999940a9999910a9919910a191991094414490005000500000000000000000c0cc0000808800009099000007c00000000000000000c7000000000
0a9999940a9999940a9999140a9999140199991402221222005000050000000000000000cdccda9082882a9092992a9007ccccc00000000000ccccc700000000
0a9999940a9999940a1999940a1191940a11919102444442005070500000000000000000ddcdd9982282299822922998007c00000000000000000c7000000000
0a9999940a991994019919940199199401991914024444420007870000000000000000000ccdc08808828088099290880007c000000000000000c70000000000
094444440944414409444144094441440941414402222222000070000000000000000000ccc0c000888080009990900000007000000000000000700000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0777777c0717777c0717777c0717777c0717771c0000000005565565051655650516556505165565051655150000000000000000000000000000000000000000
076c6cc107616cc107616cc1076161c1076161c100000000066666660661666606616666066161660661616600000000000000000000c0000000000000000000
07c6ccc107c6ccc107c6ccc107c61cc107161cc100000000056556550565565505655651056516510515165100000000000000000000c0000000000000000000
076cccc1076cccc1076ccc11076ccc11016ccc11000000000666666606666666066666160666661601666616000000000000000007c0c0c70000000000000000
07ccccc107ccccc1071cccc10711c1c10711c1c10000000006556556065565560615655606116156061161510000000000000000007ccc700000000000000000
07ccccc107cc1cc101cc1cc101cc1cc101cc1c1100000000066666660666166601661666016616660166161600000000000000000007c7000000000000000000
0c1111110c1111110c1111110c1111110c1111110000000005565565055651650556516505565165055151650000000000000000000070000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000008800000000000000000000000000000aa00000000000000000000000000000000000
00000000000000000070000700700007000000000000000000008800000888800000000000000000000aa00000a00a0000700007007000070000000000000000
000000000007007000070070000500500000000000008800000888800088008800000000000aa00000aaaa000a0000a0000c00c0000c00c00007007000070070
0000770000007700000055000000000000008800000800800088008800880088000aa00000aaaa000aa00aa00a0000a000000000000000000000cc000000cc00
0000770000007700000055000000000000008800000800800088008800880088000aa00000aaaa000aa00aa00a0000a000000000000000000000cc000000cc00
000000000007007000070070000500500000000000008800000888800008888000000000000aa00000aaaa0000a00a00000c00c0000c00c00007007000070070
00000000000000000070000700700007000000000000000000008800000088000000000000000000000aa000000aa00000700007007000070000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000ccc0000000000000ccc0000000000000ccc0000000000000ccc0000000000
008808800000000000880880000000000088088000000000008808800000000000ccc0c00000000000ccc0c00000000000ccc0c00000000000ccc0c000000000
008808800000000000880880000000000088088000000000008808800000000000ccccc00000000000ccccc00000000000ccccc00000000000ccccc000000000
008888800000000000888880000000000088888000000000008888800000000000ccccc00000000000ccccc00000000000ccccc00000000000ccccc000000000
0008880000000000000888000000000000088800000000000008880000000000000ccc0000000000000ccc0000000000000ccc0000000000000ccc0000000000
00008000000000000000800000000000000080000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000007700000000000000000000000000000055000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000770000070070000000000000000000007700000500700000000000000000000000000000000000000000000000000000000000000000
00000000000077000007777000700007000000000000000000075570000000070000000000000000000000000000000000000000000000000000000000000000
0000770000077770007700770070000700000700000005500075000000000007000000000000000000c0000c00c0000c00000000000000000000000000000000
000077000007777000770077007000070000070000077750007500000000000000000000000c00c0007c00c70070000700000000000000000000000000000000
00000000000077000007777000070070000000000000770000075000000000000000cc000007cc70000700700000000000000000000000000000000000000000
00000000000000000000770000007700000000000000000000007500000000000000770000007700000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000ee00000000000000000000000000000cc0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000ee00000e00e00000000000000000000cc00000c00c0000000000000000000080000800a0000a00000000000000000000000000000000
000000000000ee00000eeee000e0000e00000000000cc00000cccc000c0000c00000000000080080000a00a00000000000000000000000000000000000000000
0000ee00000eeee000ee00ee00e0000e000cc00000cccc000cc00cc00c0000c0000088000000aa00000000000000000000000000000000000000000000000000
0000ee00000eeee000ee00ee00e0000e000cc00000cccc000cc00cc00c0000c0000088000000aa00000000000000000000000000000000000000000000000000
000000000000ee00000eeee0000e00e000000000000cc00000cccc0000c00c000000000000080080000a00a00000000000000000000000000000000000000000
00000000000000000000ee000000ee000000000000000000000cc000000cc00000000000000000000080000800a0000a00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000ee000000000000000000000000000000ee000000000000000000000000000000ee0000000000000000000000000000000000
00000000000000000000ee00000e00e000000000000000000000ee00000e00e000000000000000000000ee00000e00e000000000000000000000000000000000
000000000000ee00000eeee000e0000e000000000000ee00000eeee000e0000e000000000000ee00000eeee000e0000e00000000000000000000000000000000
0000ee00000eeee000ee00ee00e0000e0000ee00000eeee000ee00ee00e0000e0000ee00000eeee000ee00ee00e0000e00000000000000000000000000000000
0000ee00000eeee000ee00ee00e0000e0000ee00000eeee000ee00ee00e0000e0000ee00000eeee000ee00ee00e0000e00000000000000000000000000000000
000000000000ee00000eeee0000e00e0000000000000ee00000eeee0000e00e0000000000000ee00000eeee0000e00e000000000000000000000000000000000
00000000000000000000ee000000ee0000000000000000000000ee000000ee0000000000000000000000ee000000ee0000000000000000000000000000000000
21a1d0714191f250f230f230f230f230f2d0c0f1f250f230f230f230f230f2e171418101f260f230f230f230f230f2e161017101f1a191f260f230f230f230f2
30f2e191c06101f250f240f230f230f230f2e1b141f001d1f250f230f230f230f230f2224152c0d1f0f250f230f230f240f240f2f00181a191f280f240f230f2
40f240f22131a1e1f1f260f230f230f240f240f2a1d1e0f260f240f230f230f230f222a17111f260f240f240f240f240f22241f0a122f250f270f230f240f240
f2e0a1d0d1c0f250f260f230f240f240f2e00271f141e1f1f260f230f230f230f240f2e0a171f010e171418101f270f230f230f240f240f291419151c0f260f2
60f230f250f240f281419101d1f260f230f230f230f230f26191412131f1f2b0f250f230f250f240f2017101810191f1c071f260f260f230f240f240f2e00191
f1c002d1f2a0f250f230f250f240f2d0a181d001d1f250f270f230f240f240f21102d14210d0c0f1f250f240f240f240f240f2b2c2d2e2f25020f270f230f230
70f260f2f001c0f131f2b0b0f2b0b0f230f24020f260f2f0d1c021a191f23070f270f230f23020f260f211c0e1f1104181b1f250f230f250f240f240f2d04121
10e171418101f23050f250f230f2a0f260f2d0c091e1310101f260f240f240f250f240f2c0d1e03101d1f260f230f230f240f240030000000000000000000000
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
0000000000000000000000000000000002020200000000000000000000000000020202010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2323242326232324232323262324232323232323232323232323232323232323232324232623232423232326232423230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002423141414000000000000000000000023240000000000000000000000000000240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2300000000000000000000000000002323141414002323232323000000000023230000000000000000000000000000230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2323262324232323232624232324232623141400002314071423000000000023230000000000000000000000000000260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2300000000000000000000000000002323000000000000000000000000000023230000000000000000000000000000230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002323000000000000000000000000000023242623242323232326242323242326230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2300000000000000000000000000002423000000000000000000000000000000230000000000000000000000000000240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2600000000000000000000000000002323000000000000005300000000000000260000000000000000000000000000230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2300000000000000000000000000002423000000002000000010000000000023230000000000000000000000000000240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2300000000000000000000000000002323000000005300050000540000000023230000000000000000000000000000230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2400000000000000000000000000002623000000000011002254000000000023240000000000000000000000000000260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2300000000000000000000000000002323000000000000000000000000000423230000100011001200200021002200230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2600000000000000200000000000002423000000000000000000000000040423260000000000000000000000000000240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2300000000000000000000000000002323232323232300002323232323232323230000000000000000000000000000230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2300000000000000000000000000002400000000000000000000000000000000260000000000000000000000000000240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2324262324232300000026242323232600000000000000000000000000000000232423232623242323232324232623230000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000048004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000300032003400360038003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000310033003500370039003d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000100001c0501b0501b050000000000000000000000000000000000000000000000000000000000000000003b000000000000000000000000000000000000000000200003000000000000000000000000000000
000500002465023450226501f4500d650074500000000000000000000000000000003f60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002b15027150241502315024150281502b150301502210004100281002b1002d1002e100011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000083500f350153500c350133501b35015350193501e350243502b3500f100131001e100171001c1001d10026100073000d300103000000000000000000000000000000000000000000000000000000000
000a00001562022620196201460014600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000315003100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000d0501005015050100501030006300083000b3000e3001030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00000c664186640c664186640c6640c6640066400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0009000015650225002b6502e65024640175001d6301c70017620000000d610000000961000000046100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002765024650216500965005650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001335014350153501735018350193502e2000f20022650243502665023650216501e6501c6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000013350153501635017300123500e350073000f20015300123000c3000a3002140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500001c0500040020050000001c0501c400180501b0001c0500000023050000002905000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000101321013210132101321c1321c1321a1321a1321a1321a1321a1321a13218132181321313213132101321013210132101321c1321c1321a1321a1321a1321a1321a1321a1321c1321c1321a1321a132
011400001013210132131321313217132171321a1321a1321a1321a1321a1321a1321d1321d1321f1321d1321c1321d1321c1321a132181321813218132181321a1321a1321c1321c1321a1321a1321813218132
01120000181521a1521c1521c1421c1321c1221a1521a1421a1321a12218152181421715217142171321712217112171020510005700057000570005700000000000000000000000000000000000000000000000
00140000125000c5000b5000a50000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000004003000000a0030a003106030000004003000000a003070000a003000001360300000040030600004003010000a0030a00310603000000a003000000a003000000a0030000010603156031060315603
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c171f130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b47213001
1d10120c014511a4711405119472130010c4310103026472024720247202472190102f4102f052014701d02119031014511a471140511943201442040322f0102f410024721806019060014511a4711405119472
0731010d144410102037472024720247202472190102f4102f052014701d02119031014511a471140511943201442044332f0102f4100647212051174700107113021104310f4721b0601e071144021040029020
2f042f0f170510e0312f0102f0102f0102f441024723a4102f0131b0601e07114402104000c4601443114471244132f0103b02007472040402f4601a4311f4721d0601901110400074002a4103a4202f4202f410
062f0f05074723a4102f4330105301070130511a071104000f0211d0010e471140511947202472050102f011200711f4721d0601901110400054001b0021e4110100119001180223c0120c431174720347203472
37013a012f05303472374003a4000e4111a0511e0010147014461100701f0211a4412f0102f410044720d051224721d0601901110400074000f041124001044110041244720447202472064720f4302f05303472
2f37013a0e4111a0511e0010147014461100701f0211a4412f0102f030054721b0210e0310c4122f0202a4000d4611006016071010120c43117071010211940003400130211f4720347202472024720f4102f430
2f2a011e01070130511a071104000f0211d0010e471140511947202472034202f0711b021194001e43114070104720f04112400190010c4610d022010011900118021100712f4702f0102f4302f441024723a410
032f37011b021194001e43114070100422f0102f0200a4721f001170011b0511d4712f4610c44112001014400147110431104511a4611f4001f051014311a0700c47114051194720247204472074721f4402f053
2f37013a3a4000e4111a0511e001014311a0700c471140511947202472054102f4511a431240411a4611b4112f4610c4411200101440010411a4611b4110100119001180222f0102f0202f4302f471094723a410
1a1e100101070130511a0711040010441100412447202472044402f46020021174702f4610c44112001014100146020021174701e40022060174312f0102f0102f4302f471034723a4102f433010530107013051
1001171a170510e0601f0211a4412f0102f030064720d051184601e4721d06019011104000540006052010211940005412054000c46110060014720647202472024721f4302f4202f4330105301070130511a071
1b0c1e1e0e0601f0211a4412f0102f41007472110211d0010106018002170011f4721b0601e071144021043201442040320141037400114611a0410140114461100712f0102f0102f0102f441024723a4102f013
0c19160114402104000c4601443114471244132f0102f4100347218021230010f4001b0511f0211a4412f41110060174000403201461100110c02119400034332f0102f0102f0102f44102472034722a4000f461
3a010e131b0511f0211a441014420403201442034332f0102f0200b472114311a0510f4721d060190111040005400114311a0510f0710142023420010601d0010c4720347203472074721f4202f0530347237400
032f37011a0511e001014311a0700c471140511947202472060402f4011d00110422104721d060190111040004400114611000125001010011900118022014011a461010203d4720247203472094720f0202f053
0c1e1e143a4000e4111a0511e0010147014461100701f0211a4412f0102f030044721300117041104712f4510c0711e021210010144203010314000d4311a07016472024720247202472190102f0530347232451
010f141d21001010600d021170211f022334720245303472064302f40114461104600c431174721d06019011104000740003053070520047207472034720a4720f4302f05303472374003a4000e4111a0511e001
000e131a100701f0211a4412f0102f030034721106014461244000d051174712f4610c4411200101430014102a4003a410014711a400104411004101470180112f4102f4102f4402f470074723a4102f43300053
1e1e14211a071104000f0211d0010e471140511947202472060102f0701306014441010410c021174721b0601e0711440210400294100740301460170510e0312f0102f0102f0102f441024723a4102f0131b060
0f141d10104000c4601443114471244132f0103b410074720a0202f4311a441124001e451100601d4721d060190111040004400040522f0202f0102f0102f470044723a4102f4330105301070130511a07110400
0e0c1f140e4711405119472024720a4102f0710e46117432180011f0011a4612f4610c4411200101440014402a00005412054000c461100602f4402f0102f0102f471094720347237070130511a0711040017051
092f1e0e1a4412f0102f050074721043114412104612f442034001806023032000631100217431014111006017472024720247202472190102f4102f052104311441210461014420340018060230322f0102f050
141b2f1d1d4312747110431104511a4611f4721d0601901110400094001f001170011b0511d4712f0102f0102f0102f471094720347237070130511a07110400170510e0601f0211a4412f0102f0500847222411
1f201d190c4411200101420014102a0002f4102f0102f4202f470054723a4102f4330e4111a0511e0010147014461100701f0211a4412f0102f0500a4721e0701d431274110c0711f0012f4710c0311040005400
000000001e472024720247202472190102f0102f4332007110470014110c0711f00101442054632f0103000000000000000000000000000000000000000100000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000
__music__
06 41 42 43 44
01 14 42 43 44
02 15 42 43 44
02 0a 0b 0c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
