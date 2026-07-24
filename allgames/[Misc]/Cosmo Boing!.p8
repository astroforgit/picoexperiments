pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- cosmo boing! v1.0
-- by minsoft (2016)

function _init()
 lvl_no = 0
 lvl_str = "00"
 lvl_vibrate = 0
 
 debug = false
 credits = 0
 hi = 0
 if (cartdata("min_boing")) hi = dget(0)
  
 --starfield stuff
 star = {}
 star_col = {1,2,5,6,7} 
 
 local i
 for i = 1,75 do
  star[i] = {}
  star[i].y = rnd(127)
  init_star(i)
 end
 
 --palette fade lookup
 pal_fade = {
  {1,1,1,0,0,0,0},
  {2,2,1,1,1,0,0},
  {3,3,3,1,1,0,0},
  {4,4,4,4,1,1,0},
  {5,1,1,1,0,0,0},
  {6,6,5,5,5,1,0},
  {7,7,6,5,5,1,0},
  {8,8,8,8,2,1,0},
  {9,9,4,4,1,1,0},
  {10,9,4,4,1,1,0},
  {11,3,3,3,1,1,0},
  {12,13,13,5,5,1,0},
  {13,5,5,1,1,0,0},
  {14,14,8,8,2,1,0},
  {15,15,6,5,5,1,0}
 }
 
 --start with black screen
 local i
 for i = 1,15 do
  pal(i,0,1)
 end

 --reset hiscore menu option
 menuitem(1,"reset hiscore",function() reset_hiscore() end)
 
 --player stuff
 p1 = {}
 p1.score = 0
 p1.bonus = 0
 p1.msgtick = 0
 p1.prefix = "!"
 p1.ch = 3
 p1.demo = {6,0,0,0,0,1,0,0,1,2,0,2,0,2,1,1,1,1,1,1,0,1,1,2,2,2,0,1,0,1,0,1,0,2,0,0,0,0,0,1,0,1,0,0,2,0,0,0,0,1,0,0}

 p2 = {}
 p2.score = 0
 p2.bonus = 0
 p2.msgtick = 0
 p2.prefix = "@"
 p2.demo = {2,2,0,1,1,1,0,0,6,2,0,0,0,0,1,2,2,0,5,1,2,0,2,0,0,2,1,0,1,1,0,0,0,0,0,0,2,0,0,0,2,0,1,1,0,0,0,1,0,2,2,0}

 --icons
 icon_life = 65
 icon_lif2 = 113
 icon_jump = 81
 icon_jmp2 = 114
 
 --tiles...
 tile_blnk = 0
 tile_norm = 1
 tile_nor2 = 2
 tile_hol1 = 3
 tile_hol2 = 4
 tile_hol3 = 5
 tile_hole = 6
 
 tile = {}

 tile[tile_blnk]	= {}
 tile[tile_blnk].spt = 0
 tile[tile_blnk].typ = "dead"

 tile[tile_norm]	= {}
 tile[tile_norm].spt = 3
 tile[tile_norm].typ = "good"

 tile[tile_nor2]	= {}
 tile[tile_nor2].spt = 19
 tile[tile_nor2].typ = "good"

 tile[tile_hol1]	= {}
 tile[tile_hol1].spt = 35
 tile[tile_hol1].typ = "good"

 tile[tile_hol2]	= {}
 tile[tile_hol2].spt = 51
 tile[tile_hol2].typ = "good"

 tile[tile_hol3]	= {}
 tile[tile_hol3].spt = 39
 tile[tile_hol3].typ = "good"

 tile[tile_hole]	= {}
 tile[tile_hole].spt = 55
 tile[tile_hole].typ = "dead"


 --power ups & hazards...
 pup_blnk = 0
 pup_pts = 1
 pup_jump = 2
 pup_life = 3 
 pup_super = 4
 pup_left = 5
 pup_right = 6
 pup_up = 7
 pup_fin = 8
 
 pup	= {}
 
 pup[pup_blnk] = {}
 pup[pup_blnk].spt = 0
 pup[pup_blnk].typ = 0
  
 --bonus points
 pup[pup_pts] = {}
 pup[pup_pts].spt = 96
 pup[pup_pts].typ = "pup"
 pup[pup_pts].frm = 8
 pup[pup_pts].frq = 8
 
 --extra jump
 pup[pup_jump] = {}
 pup[pup_jump].spt = 80
 pup[pup_jump].typ = "pup"
 pup[pup_jump].frm	= 8
 pup[pup_jump].frq = 8
 
 --extra life
 pup[pup_life] = {}
 pup[pup_life].spt = 64
 pup[pup_life].typ = "pup"
 pup[pup_life].frm = 8
 pup[pup_life].frq = 8
 
 --super jump
 pup[pup_super] = {}
 pup[pup_super].spt = 120
 pup[pup_super].typ = "pup"
 pup[pup_super].frm = 2
 pup[pup_super].frq = 8 
 
 --left
 pup[pup_left] = {}
 pup[pup_left].spt = 72
 pup[pup_left].typ = "haz"
 pup[pup_left].frm = 2
 pup[pup_left].frq = 8
 
 --right
 pup[pup_right] = {}
 pup[pup_right].spt = 88
 pup[pup_right].typ = "haz"
 pup[pup_right].frm = 2
 pup[pup_right].frq = 8
 
 --up (jump)
 pup[pup_up] = {}
 pup[pup_up].spt  = 104
 pup[pup_up].typ  = "haz"
 pup[pup_up].frm  = 2
 pup[pup_up].frq  = 8
 
 --finish (far left/right)
 pup[pup_fin] = {}
 pup[pup_fin].spt = 7
 pup[pup_fin].typ = ""
 pup[pup_fin].frm = 6
 pup[pup_fin].frq = 8

 init_title()
end

function get_bonus_channel()
 --if only 1 player alive,
 -- use music embelishment ch.
	if (p1.dead or p2.dead) return 2
	--otherwise, use music 
	-- melody ch. as last resort
	return 1
end

function init_star(i)
 --set star x-pos, speed, colour etc
 star[i].x = rnd(127)
 star[i].sp = rnd(3)
 star[i].col = star_col[1+flr(star[i].sp*2)]
 --shooting star?
 star[i].sht = false
 if star[i].sp>2 then
  if (rnd(100)<10 or lvl_endzone) star[i].sht = true
 end 
end

function update_stars()
 --update star y-pos
 for i = 1,75 do
  star[i].y += star[i].sp
  if star[i].y>127 then
   star[i].y = 0-rnd(64)
   init_star(i)   
   if (rnd(100)<50) star[i].sp += 1
  end
 end 
end

function draw_stars()
 local c,i,j
 local trail_col = {6,15,12,13,5,2,1}
 
 for i = 1,75 do
  c = star[i].col
  if star[i].sht then
		 circfill(star[i].x,star[i].y,1,5+rnd(2))
		 pset(star[i].x,star[i].y,7)
		 for j = 1,7 do
		  pset(star[i].x,star[i].y-j,trail_col[j])
		 end
  else
   
   if (c==1 and star[i].sp>=1 and flr(star[i].y)%2==0) c = 13
   if (c==2 and star[i].sp>=1 and flr(star[i].y)%8==0) c = 8
   if (c==5 and star[i].sp>=1 and flr(star[i].y)%25==0) c = 7
   
   pset(star[i].x,star[i].y,c)
  end
 end
 
end

function draw_system()
 --draw solar system
 
 --planet (behind sun)
 if (plan_ang>0.5) draw_planet()
 
 --draw sun
 circfill(sun_x,sun_y,15,2)
 circfill(sun_x,sun_y,14,4)
 circfill(sun_x,sun_y,13,9)
 circfill(sun_x,sun_y,10,10)
 
 --planet (on top of sun)
 if (plan_ang<0.5) draw_planet()
 
end

function draw_planet()
 --moon (behind planet)
 if (moon_ang<0.5) draw_moon()
 
 --planet sprite
 spr(plan_spr+plan_fr,plan_x,plan_y)
 
 --moon (on top of planet)
 if (moon_ang>0.5) draw_moon()
end

function draw_moon()
 --draw moon
 circfill(moon_x,moon_y,1,moon_col) 
end

function reset_hiscore()
 hi = 0
 dset(0,hi)
end

function get_level_str(l)
 if (l>=100) l -= 100
	if (l<10) l = "0" .. l

	return l
end

function get_colour(theme)
 --used for colour cycling...
 local t
 if (theme=="yel") t = {0,0,4,4,9,9,10,10,7,7,10,10,9,9,4,4}   
 if (theme=="grn") t = {0,0,3,3,11,11,11,7,7,7,7,11,11,11,3,3}
 if (theme=="blu") t = {0,0,12,12,12,12,15,15,7,7,15,15,12,12,12,12}   
 
 local step = anim+1
 
 if (step>16) step -= 16
 if (step<1) step += 16
 
 return t[step]
end
 
function printc(str,x,y,align,colour,theme,outline)
 --print string centred or 
 -- left/right aligned
	
	local len,xp,sx,sy
 	
	--string length in chars
	len = #str
	
	--alignment
	xp = x-len*2 --centre
	if (align==1) xp = x --left
	if (align==2) xp = x-len*4	--right
	
	--don't print off-screen
 if (xp<2) xp = 2
	
	--cycled colours?
	if (theme and theme~="") colour = get_colour(theme)
  	
 --outline
 local oc = 0 --black
 --alt colour for 'finish'
 if (#str==1) oc = 1
 if outline then
  for sx = xp-1,xp+1 do
   for sy = y-1,y+1 do
    if (not (sx==xp and sy==y)) print(str,sx,sy,oc)
   end
  end
 end
 	
 --main text
 print(str,xp,y,colour)
end
 
function get_cell_text_colour(str)
 --determine colour for cell text
 -- ie player colour scheme
 
 local chr = sub(str,1,1)
 local c = "yel"
 if (chr==p1.prefix) c = "grn"
 if (chr==p2.prefix) c = "blu"
  
 return c
end
 
function trim_text(str)
 --remove first char (if special)
 local chr = sub(str,1,1)
 if (chr=="#" or chr==p1.prefix or chr==p2.prefix) str = sub(str,2)
 return str
end
 
function add_combo(pl,hitcell)
 pl.combo += 1
 if (pl.combo>1) add_player_msg(pl,pl.combo.."x")  	
end

function get_combo_score(combo)
 --5 pts per combo hit
 local sc = combo*5
  
 --bonus 25 for every 5x
 sc += flr(combo/5)*25
  
 return sc
end

function reset_combo(pl)
 --cash in the combo and reset count
 if pl.combo>1 then
	 local cs = get_combo_score(pl.combo)
		add_score(pl,cs)		
		local ms = "+"..cs.."!"
		add_player_msg(pl,ms)
		text[pl.hitcell] = pl.prefix..ms
 end
	pl.combo = 0
end

function get_bonus_point_score()
 local i = 1+flr(rnd(3))
 local b = {5,10,25,50}
	 
 return b[i]
end

function add_score(pl,points)  
 if (screen ~= "game") return
  
 --add to score
 pl.score += points
  
 --bonus life?
 if pl.score>=pl.next_life then
 	pl.lives += 1
  pl.next_life += 2000
  sfx(04,get_bonus_channel())
 end
  
 --hiscore?
 if pl.score>hi then
  hi = pl.score
  p1.hiscore,p2.hiscore = false,false
  if p1.score==p2.score then
   p1.hiscore,p2.hiscore = true,true
  else
   pl.hiscore = true
  end
 end
end
 
function add_player_msg(pl,text)
 pl.msg = text
 pl.msgtick = gametick 
end
	
function init_title()
 scroll	= 0
 anim = 0
 gametick = 0
 tick = 0

 screen = "title"
 waiting = "attract"
 
 --reset palette
 lvl_no = 0
 set_palette()
end
	
function init_demo()
 --ensure demo level is always the same
 srand(1) 
 
 lvl_no = 61
 waiting = "" 
 demo_step = 1
  
 init_game(2)
	init_life()
end
	
function player_start_game(pl)
 --dont reset score etc on title screen
 -- (so last score remains)
 if screen=="game" then
  pl.score = 0
  credits -= 1
 end
 pl.lives = 3
 pl.dead = false
	pl.next_life = 1000
	pl.combo = 0
	pl.glint = false
	pl.msg = ""
	pl.starting = false
end
	
function player_start_life(pl)  
 --p1 position
 if pl==p1 then
  pl.x,pl.y	= 55,104
	 if (p2.lives>0) pl.x = 39
	end
	--p2 position
	if (pl==p2) pl.x,pl.y	= 87,106
	
	pl.size	= 15
	pl.direc = -1
	pl.jump	= 0
	pl.move	= 0
	pl.combo = 0
	pl.msg = ""

 if (pl.lives>0) pl.dead = false
 if (pl.dead) pl.bonus = 0
end
	
function init_game(no_players)
 --just used for game over
 -- hiscore message
 p1.hiscore = false
 p2.hiscore = false

	player_start_game(p1)
	if no_players==2 then
	 player_start_game(p2)
	else
  p2.lives = 0
  p2.dead = true
 	p2.next_life = 1000
 	p2.combo = 0
 	p2.glint = false
 	p2.msg = ""
 	p2.starting = false
 end
		
	make_level()
end
	
function init_level()
	scroll	= 0
	draw = 0		 
 cell = 1
 anim = 0
 gametick = 0
 no_jump = false
	 
 p1.jumps = 3
 p2.jumps = 3
 if p1.lives>0 and p2.lives>0 then
  p1.jumps = 5
  p2.jumps = 5
 end
 p2.ch = 2
 if (p1.lives==0) p2.ch = 3
	 
 if (screen == "game") lvl_str = get_level_str(lvl_no)
end

function init_life()
	
 local i
	 
	player_start_life(p1)
	player_start_life(p2)

 --clear powerups
 clear_pups()
	 
 --add new powerups
 add_pups(pup_life,0,lvl_lives)
 add_pups(pup_jump,0,lvl_jumps)
 add_pups(pup_pts,0,lvl_pts)
 add_pups(pup_super,0,lvl_supers)
	
	--revert 'hits'
 for i = 1,lvl_len do
  --clear leftover powerup text
  if (sub(text[i],1,1)=="#" or sub(text[i],1,1)==p1.prefix or sub(text[i],1,1)==p2.prefix) text[i] = ""
   
  --revert holes
  if (cells[i] == tile_hole) cells[i] = tile_hol1
 end
    		
end

function _update()
 --draw ball etc
 update_ball(p1)
 update_ball(p2)
 
 --check if finish reached
 check_finish()
  
 --check player collisions
	check_contact()
		
	--check for start press
	check_title_inputs()
	 
	--increment scroll & animation counters
	scroll_level()
	 
 --check if stuff needs doing
 do_stuff()
 
 --move stars
 update_stars()
end

function update_ball(pl)
 if (not eval_ball_in_play(pl)) return
		 
 pl.size += pl.direc
		
	bounce_ball(pl)
 drop_ball(pl)
 check_inputs(pl) 
end
 
function bounce_ball(pl)
 --see if ball has hit ground...
  
 if (pl.size~=0) return
  
 --bounce
	pl.direc = -pl.direc
			
	--collision not required
	-- while waiting
	if (waiting~="" and waiting~="attract") return
		
	--see what we hit
	pl.hitcell = get_cell_over(pl)   
			
	--note tile/power up hit
	local chit = cells[pl.hitcell]
	local phit = pups[pl.hitcell]
	local ctyp = tile[chit].typ
	local ptyp = pup[phit].typ
			
	--hit a good tile
	
 --standard tile + 1 pt
	if (ctyp=="good") add_score(pl,1)
	--hazard + 2 pts (already +1 above)
	if ptyp=="haz" then 
	 add_score(pl,1)
	 add_combo(pl,pl.hitcell)			   
	end
	--reset combo if non-hazard hit
	if (ctyp=="good" and ptyp~="haz" and (pups[pl.hitcell]==pup_blnk or pup[pups[pl.hitcell]].spt~=pup[pup_super].spt)) reset_combo(pl)
		
	--sfx...
	
	--bounce
	if (ctyp=="good" and pl.jump==0) sfx(01,pl.ch)
	
	--jump noise
	-- this takes care of sfx
	-- if button pressed when
	-- ball on way down
	if pl.jump==1 and not no_jump then
	 sfx(02,pl.ch)			
	 pl.jumps -= 1
	end
 	
		
	--hit a gap
	if ctyp=="dead" then  	
	 sfx(03,pl.ch)
 	
	 pl.lives -= 1
		pl.dead = true
	 pl.bonus = 0
	 if (pl.combo>1) add_player_msg(pl,"lost!")
	 pl.combo = 0
	 if p1.dead and p2.dead then
	  waiting = "death"
	  if (screen=="demo") waiting = "leveldone"
		 tick = 0
		end			 
 end
		 
	--power ups...
	--extra life		 
 if phit==pup_life then
		pups[pl.hitcell] = pup_blnk
  if (pl==p1) text[pl.hitcell] = pl.prefix.."1up!"
  if (pl==p2) text[pl.hitcell] = pl.prefix.."2up!"
	 pl.lives += 1
		lvl_lives -= 1
		sfx(04,get_bonus_channel())
	end
	--extra jump
	if phit==pup_jump then
		pups[pl.hitcell] = pup_blnk
	 text[pl.hitcell] = pl.prefix.."+jmp!"
	 pl.jumps += 1
	 lvl_jumps -= 1
	 sfx(07,get_bonus_channel())
	end
	--bonus points
	if phit==pup_pts then
	 pups[pl.hitcell] = pup_blnk
	 local b = get_bonus_point_score()
	 text[pl.hitcell] = pl.prefix.."+"..b.."!"
	 add_score(pl,b)
	 lvl_pts -= 1
	 sfx(07,get_bonus_channel())
	end
	--super jump
	if phit==pup_super then
		pl.jump = 2
	 add_combo(pl,pl.hitcell)
		lvl_supers -= 1
		sfx(00,pl.ch)
	end

	--hit a left/right
	if phit==pup_left then
	 pl.move = -16
	 if (pl.jump==0) sfx(06,pl.ch)
	end
	if phit == pup_right then
		pl.move = 16
		if (pl.jump==0) sfx(06,pl.ch)
	end
		 
	--hit a jump
	if phit==pup_up then
	 pl.jump = 1
		sfx(02,pl.ch)
	end
			 
end
 
function drop_ball(pl)
 --reached highest point		
	if pl.jump==0 and pl.direc==1 and pl.size==8 then 
		pl.direc = -pl.direc
  return
 end
 --jump
	if pl.jump==1 and pl.size>=16 then
		pl.direc = -pl.direc
		pl.jump = 0
		pl.glint = true --annoying but easiest
	 return
	end
 --super jump  
	if pl.jump==2 and pl.size>=48 then
	 pl.direc = -pl.direc
	 pl.jump = 0
	 return
	end
			
end
 
function get_cell_over(pl)
 local oncell
 local hit
  
 --see what we hit
	if (pl.x>=0 and pl.x<=15) hit = 1
	if (pl.x>=16 and pl.x<=31) hit = 2
	if (pl.x>=32 and pl.x<=47) hit = 3
	if (pl.x>=48 and pl.x<=63) hit = 4
	if (pl.x>=64 and pl.x<=79) hit = 5
	if (pl.x>=80 and pl.x<=95) hit = 6
	if (pl.x>=96 and pl.x<=111) hit = 7
	if (pl.x>=112 and pl.x<=128) hit = 8

 oncell = ((draw+2)*8)+hit 
  
 return oncell
end
 
function check_contact()
 --check if players have bumped
 if (screen=="title") return
 if (p1.dead or p2.dead or p1.size~=p2.size) return	
 
 --bumped - p1=left
 local sz = p1.size-1
 if p1.x<p2.x and (p1.x+sz)-(p2.x-sz)>0 then
	 p1.move = -p1.size
  p2.move = p1.size
  sfx(06,p2.ch)
	end 
	--bumped - p2=left
	if p2.x<p1.x and (p2.x+sz)-(p1.x-sz)>0 then
	 p1.move = p1.size
	 p2.move = -p1.size
	 sfx(06,p2.ch)
	end 
end
 
function check_finish()
 if (waiting~="") return
	
	--don't let player jump right 
	-- at the end
	if (draw*8==lvl_len-24 and p1.direc==-1) no_jump = true
	
	--reached finish line
	--nb players reach finish at
	-- same time (if alive)
 if (draw*8~=lvl_len-16) return
 
 --stop super jump
 p1.direc = -1
 p2.direc = -1
 p1.jump = 0
 p2.jump = 0
 
 reset_combo(p1)
 reset_combo(p2)
 add_score(p1,p1.bonus)
 add_score(p2,p2.bonus)
 sfx(05,p2.ch)
 waiting = "leveldone"
 tick = 0
end

function check_title_inputs()
 --credit (up)
 if check_coin() then
  sfx(07,0)
  if screen=="demo" then
   palette_fade("out")
   init_title()
  end
 end
 
 if (credits==0) return
 
 --start pressed?
 local p1_start = false
 local p2_start = false
 local players = 1
 if (btnp(4,0) or btnp(5,0)) p1_start = true
 if (btnp(4,1) or btnp(5,1)) p2_start = true
 
	--start game from title screen  
 if (screen=="title" or screen=="demo") and ((p1_start and credits>=1) or (p2_start and credits>=2)) then 
  if (p2_start) players = 2
  
  screen = "game"
  waiting = "start"
  tick = 0
  palette_fade("out")
  
  sfx(-1,p1.ch)
  sfx(-1,p2.ch)
  sfx(09,1)  
  
  lvl_no = 1
  srand(rnd(100))
  init_game(players)
	 init_life()
	 
	 return
 end
 
 --continue (wait until level
 -- over, or other played dies)
 if (p1.lives==0 and p1.dead and credits>=1 and p1_start) p1.starting = true
 if (p2.lives==0 and p2.dead and credits>=1 and p2_start) p2.starting = true
 
 --start now
 if (waiting=="start" and p1.starting) player_start_game(p1) p1.size = p2.size p1.direc = p2.direc
	if (waiting=="start" and p2.starting) player_start_game(p2) p2.size = p1.size p2.direc = p1.direc
 
end

function do_stuff()
 if (waiting=="" or anim>0) return
 	
  --waited 1 ticks...do stuff
 if tick==1 then
  if waiting=="start" or waiting=="attract" then 
   palette_fade("in")
   return
  end
  if waiting=="demostart" then
   palette_fade("in")
   waiting = ""
   tick = 0
   return
  end
 end
 
	--waited 4 ticks...
	if tick==4 then 
	 --game start - get cracking
	 if waiting=="start" then
	  --if (lvl_no==1 and p1.lives==3) music(00,0,1+2+4)	  	  	  	  
	  if bg_music>-1 then
	   music(bg_music,0,1+2+4) 
	   bg_music = -1
	  end
	  screen = "game"
	  waiting = ""
	  tick = 0
	  return
	 end
  --dead - new life or game over	 
	 if waiting=="death" then
	  update_death() 		  
	  return
	 end
	 --level complete - start new level...
	 if waiting=="leveldone" then
   palette_fade("out")
   
	  --...or back to title screen   
   if screen=="demo" then
    init_title()
    return
   end
   
   lvl_no += 1
	  make_level()
	  if (p1.starting) player_start_game(p1)
 	 if (p2.starting) player_start_game(p2)
 	 init_life()
   waiting = "start"
   tick = 0

   --start boss music
   if (lvl_endzone) music(13,0,1+2+4) 	   
   --start normal music   
   if bg_music>-1 then
    music(bg_music,0,1+2+4)
    bg_music = -1
   end
   
   return
	 end
	end
 
	--waited 8 ticks...
	if tick==8 then 
	 --game over - back to title
	 if waiting=="gameover" or waiting=="demoover" then
	  palette_fade("out")
	  init_title()
			return 		 
	 end
	end
 	
	--waited 24 ticks...
	if tick==24 then
  --title screen - now on to demo
	 if waiting=="attract" and screen=="title" then
	  palette_fade("out")
		 screen = "demo"
		 init_demo()
		 waiting = "demostart"
			tick = 0
			return
		end
	end
 	
end

function check_coin()
 --coin up
 if btnp(2,0) or btnp(2,1) then
  credits += 1
  return true
 end
 
 return false
end

function check_inputs(pl)

 if (waiting~="") return

 local pn = 0
 if (pl==p2) pn = 1
 
	--move left/right 
	if pl.move>=-10 and pl.move<=10 then 
	 if screen == "game" then
	  if (btn(0,pn)) pl.x -= 1
	  if (btn(1,pn)) pl.x += 1
	 else
	  demo_play(pl)
	 end
	end
		
	if pl.move<0 then
		pl.x -= 1	
		pl.move += 1
	end
	if pl.move>0 then
		pl.x += 1
		pl.move -= 1
	end
		
	--prevent moving offscreen	
	if (pl.x<=3) pl.x = 3
	if (pl.x>=123) pl.x = 123

		
	--jump
	if (btnp(4,pn) or btnp(5,pn)) and pl.jumps>0 and pl.jump==0 and not no_jump and pl.size<=12 then
	 --jump noise
	 -- this takes care of sfx
	 -- if button pressed when
	 -- ball on way up
	 if pl.direc==1 then
	  sfx(02,pl.ch)
	  pl.jumps -= 1
	 end
	 pl.jump = 1
	 if not lvl_boss then
	  pl.bonus -= 5
	  if (pl.bonus<0) pl.bonus = 0
  end
	end
		
end
 
function demo_play(pl)
 --this controls the players
 -- during the demo
 
 if (screen~="demo") return
 if (scroll~=8) return
 
 --left
 if (band(pl.demo[demo_step],1)==1) pl.move -= 16
 --right
 if (band(pl.demo[demo_step],2)==2) pl.move += 16
 --jump
 if (band(pl.demo[demo_step],4)==4) pl.jump = 1
 
end
 
function scroll_level()
 --advance counters etc...
 
	anim += 1
	if (anim==16) anim = 0 gametick += 1
	if (gametick==16) gametick = 0		
	if (waiting~="" and anim==15) tick += 1
	
	--demo counter
	if (screen=="demo" and scroll==8) demo_step += 1
	
	--vibrate (hole developing)	
	if lvl_vibrate~=0 then
	 lvl_vibrate = -lvl_vibrate
	 vib_cnt += 1
	end
	if (vib_cnt==3) lvl_vibrate = 0 vib_cnt = 0
	
	
	--planet stuff...
	if (screen~="title") sun_y += 0.01
	
	--planet
	--orbit
	plan_x = 40*cos(plan_ang)
	plan_y = 10*sin(plan_ang)
	--tilt
	--cos(0.54) = -0.9686
	--sin(0.54) =  0.2486
	plan_x = plan_x*-0.9686 - plan_y*0.2486
 plan_y = plan_x*0.2486 + plan_y*-0.9686
 --offset
 plan_x += sun_x-4
 plan_y += sun_y-4
 
	plan_ang += 0.005
	if (plan_ang>1) plan_ang-=1	
	plan_fr += 0.5
	if (plan_fr == 8) plan_fr = 0
	
	--moon
	moon_x = plan_x+4 + 13*cos(moon_ang)
	moon_y = plan_y+4 + 3*sin(moon_ang)
	moon_ang += 0.05
	if (moon_ang>1) moon_ang-=1	
	
   
 --dont scroll title screen
	-- or while waiting
	-- (scroll after game over)
	if (screen=="title" or (waiting~="" and waiting~="gameover" and waiting~="demoover")) return

 --clear the combo popup
 clear_player_msg(p1)
 clear_player_msg(p2)

		
	--scroll
	scroll += 1
	if scroll==16 then
	 scroll = 0	
	 draw += 1		
	end
			
	--disappearing tiles
	if lvl_dis>0 and (scroll+1)%lvl_dis==0 then
	 --pick random cell
	 cell = 32+flr(rnd(lvl_len-39))
		  
	 --crumble on
	 --(play sfx if cell is onscreen,
	 -- or end of zone level)
	 if cells[cell]==tile_hol1 and cell >= draw*8 then
	 	if cell<=(draw+8)*8 or lvl_endzone then
	 	 sfx(08,0)
	 	 lvl_vibrate = 1
	 	 vib_cnt = 0
	 	end
	 	cells[cell] = tile_hol2
   return
  end
	 if cells[cell]==tile_hol2 and cell >= draw*8 then		 	
   if cell<=(draw+8)*8 or lvl_endzone then
    sfx(08,0)
    lvl_vibrate = 1
	 	 vib_cnt = 0
	 	end
	 	cells[cell] = tile_hol3
	  return
	 end
	 if cells[cell]==tile_hol3 and cell >= draw*8 then
   if cell<=(draw+8)*8 or lvl_endzone then
    sfx(08,0)
    lvl_vibrate = 1
	 	 vib_cnt = 0
	  end
	 	cells[cell] = tile_hole
  	pups[cell] = pup_blnk
  	return
  end
	end
	
end
 
function clear_player_msg(pl)
 local cnt = gametick-pl.msgtick
 if (cnt<0) cnt += 16
 --clear after 3 ticks
	if (cnt==4 and (sub(pl.msg,1,1)=="+" or pl.msg=="lost!")) pl.msg = ""
end
 
function update_death()
  	
	if p1.lives>0 or p2.lives>0 then
  --restart level
  if (p1.starting) player_start_game(p1)
 	if (p2.starting) player_start_game(p2)
  init_level()
  init_life()
   
  waiting = "start"
  tick = 0
  
  palette_fade("out")
 else 	  
  --game over
 	music(-1,5000)
 	dset(0,hi)
	 waiting = "gameover"
	 tick = 0
	 p1.msg = ""
	 p2.msg = ""
	end
 	
end
 
function _draw()
   
 cls()
 
 draw_system()
 draw_stars()
 draw_map()
	 
 --draw highest ball on top
 if screen~="title" then
  if p1.size>p2.size then
   draw_ball(p2)
   draw_ball(p1)
  else
   draw_ball(p1)
   draw_ball(p2)
 	end
 end
		
	draw_status()
 draw_message()
	 
 draw_kill_screen()
	 
 --debug = stat(1)
end
 
function draw_kill_screen()
 --'kill' screen (passable!)
 if (lvl_no<100) return
  
 --mess up gfx (red bits)
 poke(rnd(0x3100),8)
 --mess up sfx (less often)
 if (gametick%8==0) poke(0x3200+rnd(0x1100),rnd(0x100))
end
 
function draw_map()
 if (screen=="title") return
 
 local x,y,xpos,ypos,sprite,sprite_frm,powerup
  
 --draw map
 cell = 1 + (8 * draw)
 for y = 7,-1,-1 do
	 for x = 0,7,1 do
	  --this stops trying to draw
	  -- tiles past the end of the level
	  -- when scrolling
	  if (cell>lvl_len) return
		 
	  xpos = (x*16)+lvl_vibrate
	  ypos = (y*16)+scroll
		
		 sprite = tile[cells[cell]].spt
		  		  
	  --draw 2x2 tiles
		 if sprite>tile_blnk then
		 	spr(sprite,xpos,ypos)
				spr(sprite+1,xpos+8,ypos)
				spr(sprite+2,xpos,ypos+8)
				spr(sprite+3,xpos+8,ypos+8)
 	 end
			 			 
		 --power ups
		 powerup = pup[pups[cell]]
		 sprite  = powerup.spt
		 
		 --draw powerup
		 if sprite>pup_blnk then
		 	sprite_frm = ((anim+2) % powerup.frq)
				if (sprite_frm>powerup.frm) sprite_frm = 0
	   spr(sprite+sprite_frm,xpos+4,ypos+4)   
		 end
				
	  --draw text
	  --note: if text is wider than
	  -- cell then it will be drawn
	  -- over by next cell
	  -- (move to separate loop if critical)
		 if (text[cell] and text[cells] ~= "") printc(trim_text(text[cell]),xpos + 8,ypos+5,0,0,get_cell_text_colour(text[cell]),true)
				
			cell += 1
		
		end --x
	end --y
		
end
 
function eval_ball_in_play(pl)
 --no balls on title screen
 if (screen=="title") return false
  
 --ball never visible on death/gameover 
 if (waiting=="death" or waiting=="gameover") return false
 
 --ball dead (on current level)
 if (pl.dead) return false
  
 --no lives left
 if (screen=="game" and pl.lives==0) return false
  
 return true
end
 
function draw_ball(pl)
 --no ball visible on life lost / game over    
 if (not eval_ball_in_play(pl)) return
     
 local c = 3
 if (pl==p2) c = 12
   
 --draw player ball
 d_size = pl.size
 circfill(pl.x,pl.y,d_size,c)
	circfill(pl.x+(d_size/3),pl.y-(d_size/3),d_size/4,15)
	draw_glint(pl)
end
 
function draw_glint(pl)
	
 --glint centre
 local cx = pl.x+(pl.size/2.5)
 local cy = pl.y-(pl.size/2.5)
	
 --glint line length
 local dist = 0
 if pl.jump==1 or pl.glint then
  if (pl.size==12) dist = 1
  if (pl.size==13) dist = 2
  if (pl.size==15) dist = 4
  if (pl.size==16) dist = 8 pl.glint = false
 end
 if (pl.size==45) dist = 2
 if (pl.size==46) dist = 5
 if (pl.size==47) dist = 10
 if (pl.size==48) dist = 16
	 
 if (dist==0) return
	 
 circfill(cx,cy,dist/3,7)
	line(cx-dist,cy,cx+dist,cy,7)
 line(cx,cy-dist,cx,cy+dist,7)
  
end
	
function draw_status()
	
	--score
	printc("1up "..p1.score,5,2,1,3,"",true)
 printc("2up "..p2.score,124,2,2,12,"",true)
  
 --lives & jumps remaining
 if screen=="game" then 
  draw_lives()
  draw_jumps()
  draw_continue()
  draw_player_msg()
 end
  
 --hiscore
 printc("hi "..hi,64,2,0,8,"",true)
	 
 --level
 printc("l"..lvl_str,5,121,1,7,"",true)
	 
 --progress
 if screen=="game" and waiting~="gameover" then
  local perc = (draw*8) / (lvl_len-16)
  local y = 127-(127*perc) -- -scroll
  line(0,127,0,y,7)
  pset(0,y,0+anim)	 
 end
	 
 --debug
 if (debug) print(debug,78,2)

 --title screen
	if screen=="title" or screen=="demo" then
  if (credits==0) printc("insert coin",64,66,0,0,"yel",true) 
  if (credits==1) printc("press p1 jump",64,66,0,0,"yel",true)
  if (credits>1) printc("press p1/p2 jump",64,66,0,0,"yel",true)
 end
		 
	if screen=="title" then
  map(2,0,36,15,7,1)  --cosmo
  map(0,1,18,25,11,4) --boing
  
  draw_minsoft()   
	end
	
	--credit count
	if (screen~="game" and credits > 0) printc("credits "..credits,124,121,2,7,"",true)

end
	
function draw_lives()
 --player 1
 local dl = p1.lives
 if (p1.lives>6) dl = 6
	for i = 0,dl-1 do
  spr(icon_life,4+(i*9),9)
	end
 	
	--player 2
	if (p2.lives==0) return
	dl = p2.lives
	if (p2.lives>6) dl = 6 
	for i = dl-1,0,-1 do
  spr(icon_lif2,115-(i*9),9)
	end	
end

function draw_continue() 
 local txt = "insert coin"
 local col = "yel"
 if credits>0 then
  txt = "press jump"
  if (p1.lives==0) col = "grn"
  if (p2.lives==0) col = "blu"
 end
 if p1.lives==0 and p2.lives>0 then
  if p1.starting then
   txt = "please wait"
   col = "grn"
   if (waiting=="death" or waiting=="leveldone") txt = "get ready"
  end
  printc(txt,5,10,1,7,col,true)   
 end
 if p2.lives==0 and p1.lives>0 then
  if p2.starting then
   txt = "please wait"
   col = "blu"
   if (waiting=="death" or waiting=="leveldone") txt = "get ready"
  end
  printc(txt,124,10,2,7,col,true)   
 end
end

function draw_jumps()
 local dj
	 
 --player 1
 if p1.lives>0 then
  dj = p1.jumps
	 if (p1.jumps>9) dj = 9
  for i = 0,dj-1 do
 	 spr(icon_jump,2+(i*6),17)
  end
 end
  
	--player 2
	if (p2.lives==0) return
	
	dj = p2.jumps
 if (p2.jumps>9) dj = 9
 for i = dj-1,0,-1 do
  spr(icon_jmp2,116-(i*6),17)
	end
		
end
	
function draw_player_msg()
 --combo popup thing
 local s
 if p1.msg~="" then
  s = anim*1.3
  if (sub(p1.msg,1,1) == "+" or p1.msg=="lost!") s = 25
  rectfill(44-s/2,9,44+s/2,17,3)
  rect(44-s/2,9,44+s/2,17,15)
  printc(p1.msg,45,11,0,0,"yel")
 end
 if p2.msg~="" then
  s = anim*1.3
  if (sub(p2.msg,1,1) == "+" or p2.msg=="lost!") s = 25
  rectfill(83-s/2,9,83+s/2,17,12)
  rect(83-s/2,9,83+s/2,17,15)
  printc(p2.msg,84,11,0,0,"yel")
 end
end
	
function draw_minsoft()
 local i
  
 --normal sprites
 for i = 76,79 do
  spr(i,40+((i-75)*8),119)
 end
  
 if gametick==5 or gametick==13 then
 
  --'in'
  if (anim>=2 and anim<=4) spr(93,56,119) 
  if (anim==3) spr(109,56,119)
   
  --'so'
  if (anim>9) spr(94,64,119) 
  if (anim==12) spr(110,64,119) 
 end
	 
 if gametick==7 or gametick==15 then
  --'m'
  if (anim>=2 and anim<=4) spr(92,48,119) 
  if (anim==3) spr(108,48,119)
   
  --'ft'
  if (anim>9) spr(95,72,119) 
  if (anim==12) spr(111,72,119) 
 end
	 
 --year
 if (credits==0) printc("-2016-",127,121,2,3,"",true)
 
end
	
function draw_message()
 if (screen~="game") return
	 
 if waiting=="start" then
  local dots = ""
  for i = 1,tick do
   dots = dots.."."
  end
  printc("get ready"..dots,44,42,1,0,"yel",true) 
  printc("level "..lvl_str,64,58,0,7,"",true)	 
 end
 if waiting=="gameover" then
	 printc("game over",64,42,0,0,"yel",true)
  
  local p2_ypos=58
  if (p1.hiscore) printc("1up high score!",64,58,0,3,"",true) p2_ypos=74
  if (p2.hiscore) printc("2up high score!",64,p2_ypos,0,12,"",true)  
 end
 if waiting=="leveldone" then
  --fade out music prior to
  -- 'end zone' level
  if ((lvl_no+1)%20==0) music(-1,1000)
  --fade out boss music
  if (lvl_endzone) music(-1,1000)	  
	  
  printc("level "..lvl_str .. " complete!",64,42,false,0,"yel",true)
  local p2_ypos=58
  if (p1.lives>0) printc("1up bonus "..p1.bonus,64,58,0,3,"",true) p2_ypos=74
  if (p2.lives>0) printc("2up bonus "..p2.bonus,64,p2_ypos,0,12,"",true)
 end	
end
	
function make_level()
	 
 local i
	 
 init_level()
 
 bg_music = -1
	 
 --change palette
 set_palette()
	 
 --set level length/bonus etc
 if (set_level_params()) return
	 
 p1.bonus = lvl_bonus
 p2.bonus = lvl_bonus
	  	
	--make empty level
	clear_level()
		
	--add tiles
	local good_x_hol = flr((lvl_good-lvl_hols)/2)
		
	add_cells(tile_norm,good_x_hol)
	add_cells(tile_nor2,good_x_hol)
	if lvl_hols>0 then
	 add_cells(tile_hol1,flr(lvl_hols/3))
	 add_cells(tile_hol2,flr(lvl_hols/3))
	 add_cells(tile_hol3,flr(lvl_hols/3))
	end
		 
 --first 4 rows safe
 for i = 1,8 do cells[i] = tile_blnk end
 for i = 9,32 do cells[i] = tile_norm end
	 
 --add hazards
 add_pups(pup_left,lvl_haz,0)
 add_pups(pup_right,lvl_haz,0)
 add_pups(pup_up,lvl_haz-2,0) --less 'ups'

 --finish line
 for i = lvl_len-7,lvl_len do 
  cells[i] = tile_norm
  pups[i] = pup_blnk 
 end
 pups[lvl_len-7] = pup_fin
 pups[lvl_len] = pup_fin 
 text[lvl_len-6] = "f"
 text[lvl_len-5] = "i"
 text[lvl_len-4] = "n"
 text[lvl_len-3] = "i"
 text[lvl_len-2] = "s"
 text[lvl_len-1] = "h"
   	
end
		
function clear_level()
 local i
 cells = {}
 pups  = {}
 text  = {}
	 
 --fill tables with blanks
 for i = 1,lvl_len do
		add(cells,tile_blnk)
	 add(pups,pup_blnk)
	 add(text,"")
	end
end	
	
function clear_pups()
 --clear power ups
 -- (not hazards!)
 local i
 for i = 1,lvl_len do
  if (pup[pups[i]].typ=="pup") pups[i] = pup_blnk
 end
end
		
function set_level_params()
	 
 --is this boss level?
 lvl_boss = false
 lvl_endzone = false
 if lvl_no%10==0 then 
  lvl_boss = true
  if (lvl_no%20==0) lvl_endzone = true
  make_boss_level()
 else
	 
	 --set level details...
  lvl_len = get_level_len()
  lvl_bonus = get_level_bonus()
  lvl_lives = get_level_lives()
  lvl_jumps = get_level_jumps()
  lvl_pts = get_level_bonuses()
  lvl_supers = get_level_superjumps()
  lvl_good	= get_level_good_per()
  lvl_haz = get_level_hazards_per() 
  lvl_hols	= get_level_holes_per() 
  lvl_dis = get_level_dis_freq()
   
  if (lvl_no<=2) lvl_good = 95
 end

 return
end
	
function get_level_band()
 local i = flr(lvl_no/10)+1
 if (i>10) i = 10
  
 return i
end
	
function get_level_len()	
	--nb must be divisible by 8
	local l = {80+(lvl_no*8),200,248,296,344,392,440,488,536,584}  
  
 return l[get_level_band()]
end
	
function get_level_good_per()
 local l = {75,70,67,66,65,64,63,62,61,60}  
  
 return l[get_level_band()]
end
	
function get_level_hazards_per()
 local l = {7,10,11,11,12,12,13,13,14,15}  
  
 return l[get_level_band()]
end
	
function get_level_holes_per()
 local l = {0,0,5,10,15,17,19,21,23,25}  
  
 return l[get_level_band()]
end

function get_level_dis_freq()
 local l = {0,0,4,4,4,4,4,2,2,2}  
 if (screen=="demo") return 1+flr(rnd(8)) 
 return l[get_level_band()]
end
	
function get_level_bonus() 
 return (flr(lvl_no/10)+1)*10
end
	
function get_level_lives()
 local ma = {0,0,1,1,1,1,1,2,2,2}
  
 return get_no_items(0,ma[get_level_band()])
end
	
function get_level_jumps()
 local mi = {0,0,0,0,1,2,3,4,5,6}
 local ma = {0,0,1,2,3,4,6,8,10,12}
 local i = get_level_band()
    	 
 return get_no_items(mi[i],ma[i])
end
	
function get_level_bonuses()
 local mi = {0,1,2,2,3,3,4,4,5,6}
 local ma = {0,2,3,4,5,6,7,8,9,10}
 local i = get_level_band()
    	 
 return get_no_items(mi[i],ma[i])
end

function get_level_superjumps()
 local mi = {0,0,0,1,2,2,3,3,4,5}
 local ma = {0,1,1,2,3,4,5,6,7,8}
 local i = get_level_band()
  	 
 return get_no_items(mi[i],ma[i])
end
 
function get_no_items(mi,ma)
 local i = mi+flr(rnd(ma-mi))
	 
 return i
end

function add_cells(tile_type,per)
 local cnt,i
 cnt = 0
	while(cnt<flr(lvl_len*(per/100))) do
	 i = 1+flr(rnd(lvl_len))  
	 if cells[i] == 0 then
		 cells[i] = tile_type
		 cnt += 1
		end
	end
end
	
function add_pups(pup_type,per,no)
 local cnt,i,des
 cnt = 0
	 
 --desired about by %
 des = lvl_len*(per/100)	 
 --desired amount specified
 if (no>0) des = no
	 
 while(cnt < des) do
	 i = 25+flr(rnd(lvl_len-33)) --exclude finish line  
	 if cells[i]>0 and tile[cells[i]].typ=="good" then
	  pups[i] = pup_type
	  cnt += 1
	 end
	end
end		
	
function make_boss_level()
	 
 --set level details...
 lvl_len = get_level_len()
 lvl_bonus = get_level_bonus()
 lvl_lives = 0
 if (lvl_endzone) lvl_lives = 1
 lvl_pts = get_level_bonuses()
  
 gd  = {55,20,55,15,55,10,54,5,54,0}
 haz = {2,10,3,5,4,5,5,5,6,10}
 hol = {0,80,10,85,15,90,20,95,25,100}
 dis = {16,16,8,8,4,4,4,2,2,1}
 jmp = {0,0,2,0,4,0,6,0,15,0}
 sj  = {0,0,0,0,1,0,2,0,6,0}
	 
 local i = flr(lvl_no/10)
	
 lvl_good	= gd[i]
 lvl_haz = haz[i]
 lvl_hols	= hol[i]
 lvl_dis = dis[i]
 lvl_jumps = jmp[i]
 lvl_supers = sj[i]
  
end
	
function set_palette()
 local p
 --p = colours 1,2,5,6,13
 	 
 --blue
 if lvl_no==0 or lvl_no==1 then 
  bg_music = 0
  p = {1,2,5,6,13}
  lvl_bg = 2
  plan_spr = 208
  moon_col = 6
 end
	 
 --red
 if lvl_no==21 then 
  bg_music = 14
  p = {2,2,7,14,8} 
  lvl_bg = 1
  plan_spr = 224
  moon_col = 5
 end

 --yellow
 if lvl_no==41 then
  bg_music = 0
  p = {4,2,6,10,9}
  lvl_bg = 0
  plan_spr = 192
  moon_col = 5
 end
	 
 --green
 if lvl_no==61 then 
  bg_music = 14
  p = {1,2,6,3,11} 
  lvl_bg = 1
  plan_spr = 240
  moon_col = 5
 end

 --white
 if lvl_no==81 then
  bg_music = 0
 	p = {5,2,13,6,7}
 	lvl_bg = 2
 	plan_spr = 216
 	moon_col = 5
 end
	 
 --bail if nothing to do
 if (not p) return
	 
 --do the palette changes
 pal(1,p[1])
 pal(2,p[2])
 pal(5,p[3])
 pal(6,p[4])
 pal(13,p[5])
 
 --setup startup pos of planet/sun
 sun_x = 44+rnd(40)
	sun_y = -20
	if (lvl_no==0) sun_x,sun_y = 64,95
	if (screen=="demo") sun_y = 40
	
 plan_ang = 0
	plan_fr = 0
	moon_ang = 0
	 
end

function palette_fade(direction)
 local i,j,from,to,step
 
 from,to,step = 1,7,1
 if (direction=="in") from,to,step = 7,1,-1
 
 --levels
 for j = from,to,step do
  --inks
  for i = 1,15 do
   pal(i,pal_fade[i][j],1)
  end
  flip()
 end
end
__gfx__
000000000000000000000000000000000000000001dddddddddddd60004444000099990000aaaa000077770000aaaa0000999900000000000000000000000000
000000000000000000000000056666666666666001dddddddddddd600499994009aaaa900a7777a007aaaa700a9999a009444490000000000000000000000000
00700700000000000000000001ddddddddd6dd60011ddddddddddd60499aa9949aa77aa9a77aa77a7aa99aa7a994499a94499449000000000000000000000000
00077000000000000000000001dddddddddddd60011ddddddddddd6049a77a949a7aa7a9a7a99a7a7a9449a7a949949a949aa949000000000000000000000000
00077000000000000000000001dddddddddddd6001dddddddddddd6049a77a949a7aa7a9a7a99a7a7a9449a7a949949a949aa949000000000000000000000000
00700700000000000000000001dddddddddddd6001dddddddddddd60499aa9949aa77aa9a77aa77a7aa99aa7a994499a94499449000000000000000000000000
00000000000000000000000001dddddddddddd6005111111111111500499994009aaaa900a7777a007aaaa700a9999a009444490000000000000000000000000
00000000000000000000000001dddddddddddd600000000000000000004444000099990000aaaa000077770000aaaa0000999900000000000000000000000000
000000000000000000000000000000000000000001dddddddddddd60000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000056666666666666001dddddddddddd60000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001d66ddddddddd6001dddddddddddd60000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001ddddddd66ddd6001d1ddddddddd660000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001ddddddddd6dd6001dd11dddddddd60000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001dddddddddddd6001dddddddddddd60000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001dddddddddddd600511111111111150000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000001dddddddddddd600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000001dddddddddddd60000000000000000001ddddddd6dddd600000000000000000000000000000000000000000
000000000000000000000000056666666666666001dddddddddddd60056666666666666001dd6dddd6ddd6600000000000000000000000000000000000000000
000000000000000000000000016dddddddddd66001dddddddddddd60011dddddddd6d66001ddd6dddd6d1d600000000000000000000000000000000000000000
00000000000000000000000001d6dddddddd6d6001dddddddddddd6001d61ddddd6d6d6001ddd1ddddd6dd600000000000000000000000000000000000000000
00000000000000000000000001dddddddddddd6001d1dddddddd6d6001ddd6dd66dd6d6001d11d1ddddd6d600000000000000000000000000000000000000000
00000000000000000000000001dddddddddddd60011dddddddddd16001dd6d6dddd6dd60011dddddddddd1600000000000000000000000000000000000000000
00000000000000000000000001dddddddddddd60051111111111115001dd6dd6ddd1dd6005111111111111500000000000000000000000000000000000000000
00000000000000000000000001dddddddddddd60000000000000000001ddddddddd6dd6000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000001dddddddddddd60000000000000000001dd000000000d600000000000000000000000000000000000000000
000000000000000000000000056666666666666001dddddddddddd60056666666666666001dd0000000006600000000000000000000000000000000000000000
000000000000000000000000016dddddddddd66001dddddddd6d6d60016dddddddd6d66001dd000000006d600000000000000000000000000000000000000000
00000000000000000000000001d66ddddddd6d6001ddd1ddddd6dd6001d66dd0000d6d6001dd01000006dd600000000000000000000000000000000000000000
00000000000000000000000001ddd6dddddd6d6001d11ddddddd6d6001ddd00000006d6001d11d100ddd6d600000000000000000000000000000000000000000
00000000000000000000000001ddddddddd6dd60011dddddddddd16001dd00000000dd60011dddddddddd1600000000000000000000000000000000000000000
00000000000000000000000001dddddddddddd60051111111111115001dd000000000d6005111111111111500000000000000000000000000000000000000000
00000000000000000000000001dddddddddddd60000000000000000001dd000000000d6000000000000000000000000000000000000000000000000000000000
00ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff001111111100000000000000000000000000000000000000000000000000000000
0f3333f00f3333f00f3333f00f3333f00f3333f00f3333f00f3333f00f3333f01555551001111110000000000111111000000000000000000000000000000000
f3333f3ff333f33ff33f333ff333333ff333333ff333333ff333333ff333333f1555510001555100001110000155510004404400400440004440044004440444
f333333ff333333ff333333ff3f3333ff333333ff333333ff333333ff3333f3f1555551001555100001551000155510090090090909009090000900909000090
f333333ff333333ff333333ff333333ff33f333ff333f33ff3333f3ff333333f15555551015555100015510001555510a00a00a0a0a00a00aa00a00a0aa000a0
f333333ff333333ff333333ff333333ff333333ff333333ff333333ff333333f1515551001115100000110000111510090090090909009000090900909000090
0f3333f00f3333f00f3333f00f3333f00f3333f00f3333f00f3333f00f3333f01101510001001000000000000100100040040040404004044400044004000040
00ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff001000100000000000000000000000000000000000000000000000000000000000
000fff00000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00f333f0000fff000000000000000000000000000000000000000000000fff000155555101111110000000000111111000000000000000000000000000000000
000f3f0000f333f0000fff00000000000000000000000000000fff0000f333f00015555100155510000111000015551007404400400470004440047004440474
000f3f00000f3f0000f333f00000f000000000000000f00000f333f0000f3f000155555100155510001551000015551090090090909009090000900909000090
000f3f00000f3f00000f3f00000f3f000000f000000f3f00000f3f00000f3f0015555551015555100015510001555510a00a00a0a0a00a00aa00a00a0aa000a0
000f3f0000f33f0000f33f000000f000000000000000f00000f33f0000f33f000155515100151110000110000015111090090090909009000090900909000090
00f33f00000ff000000ff000000000000000000000000000000ff000000ff0000015101100010010000000000001001040040040404004044400044004000040
000ff000000000000000000000000000000000000000000000000000000000000001000100000000000000000000000000000000000000000000000000000000
00ffff00000000000000000000000000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000
00f33f00000ff0000000000000000000000000000000000000000000000ff0000015510000011000000000000001100007000000000070000000007000000070
fff33fff000ff000000ff000000000000000000000000000000ff000000ff000015555100015510000011000001551007f7044004007f700444007f7044407f7
f333333f0ff33ff000f33f00000ff00000000000000ff00000f33f000ff33ff01555555101555510001551000155551097090090909079090000907909000070
f333333f0ff33ff000f33f00000ff00000000000000ff00000f33f000ff33ff015555551011551100015510001155110a00a00a0a0a00a00aa00a00a0aa000a0
fff33fff000ff000000ff000000000000000000000000000000ff000000ff0001115511100011000000110000001100090090090909009000090900909000090
00f33f00000ff0000000000000000000000000000000000000000000000ff0000015510000011000000000000001100040040040404004044400044004000040
00ffff00000000000000000000000000000000000000000000000000000000000011110000000000000000000000000000000000000000000000000000000000
0000000000ffff00000000000000000000000000000000000000000000000000000ff00000000000000000000000000000000000000000000000000000000000
000000000fccccf0000fff00000000000000000000000000000000000000000000f33f00000ff00000000000000ff00000000000000000000000000000000000
00000000fcccfccf00fcccf000000000000000000000000000000000000000000f3333f000f33f00000ff00000f33f0000000000000000000000000000000000
00000000fccccccf000fcf000000000000000000000000000000000000000000f333333f0f3333f000f33f000f3333f000000000000000000000000000000000
00000000fccccccf000fcf000000000000000000000000000000000000000000f333333f0ff33ff000f33f000ff33ff000000000000000000000000000000000
00000000fccccccf00fccf000000000000000000000000000000000000000000fff33fff000ff000000ff000000ff00000000000000000000000000000000000
000000000fccccf0000ff000000000000000000000000000000000000000000000f33f00000ff00000000000000ff00000000000000000000000000000000000
0000000000ffff0000000000000000000000000000000000000000000000000000ffff0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000005d00330000000000000000000000000000000000000000022222000222200002222200022022000000000
000000000000000000000000000000000000000000000033f3000000000000000000000000000000000000000288888202888820028888820288288200000000
00000000000077777700000000000033333300000000d03333000000000000000000000000000000000000002822222028222282282222222822822800222200
00000077777766666677000000003333333333000005000330000000000000000000000000000000000000002e2000002e2002e202eeee202e22e22e02eeee20
000007666666cccccc66700000033333333ff3300000077000770000000000000000000000000000000077002e2000002e2002e2002222e22e22e22e02eeee20
000076cccccccccccccc67000033333333ff7f330000766707667007777770000000000000000000000766702822222028222282022222822822822800222200
000076c7cccccccccccc67000033333333ffff3300076cc676cc67766666677000000777770000000076cc670288888202888820288888202822822800000000
00076c7ccc666666cccc670003333333333ff33330076cc676ccc66cccccc66700077666667007770076cc670022222000222200022222000200200200000000
00076c7cc67777776cccc670033333333333333330076cc676ccccc66cc77cc67076cccccc677666776ccc670000000000000000000000000000000000000000
00076ccc6770000776ccc67003333333333333333076ccc676cccc6776ccc7c6776cc77cccc66ccc676ccc670000000000000000000000000000000000000000
00076ccc6700000076ccc67003333333333333333076cc6776ccc670076cccc676cc7cc66ccccccc676ccc670000000000000000000000000000000000000000
00076ccc677007776cccc6700333f333333333333076cc6776ccc670076ccc6776c7cc6776cccccc676ccc670000000000000000000000000000000000000000
00076cccc6777666cccc67000333f333333333333076cc6776cc67000076cc676cccc670076cccc6776ccc670000000000000000000000000000000000000000
000076cccc666ccccccc670000333f33333333330076cc676ccc67000076cc676ccc67000076ccc676ccc6700000000000000000000000000000000000000000
000076ccccccccccccccc670003333ff333333330076cc676cc670000076cc676ccc67000076ccc676ccc6700000000000000000000000000000000000000000
000076cccccccccccccccc6700033333333333300076cc676cc670000076cc676ccc67000076ccc676ccc6700000000000000000000000000000000000000000
000076ccccc6666666ccccc670003333333333000076cc676cc670000076cc676ccc67000076ccc676cc67000000000000000000000000000000000000000000
000076cccc677777776cccc670000033333300005076cc676cc670000076cc676cccc6700076ccc6776c67000000000000000000000000000000000000000000
000076ccc67700000076ccc67005d0000000000d5076cc676cc670000076cc676cccc670076cccc6776670000000000000000000000000000000000000000000
0000076cc67000000776ccc67005d0000000d00d50076c676cc670000076cc6776cccc6776ccccc6776670000000000000000000000000000000000000000000
0000076cc6770077776cccc67005d00d0000d005000766706cc670000076cc6776ccccc66cccccc6776670000000000000000000000000000000000000000000
0000076ccc67776666ccccc670005d0d000d00d500007700766700000076cc67076cccccccccccc6776700000000000000000000000000000000000000000000
0000076cccc666cccccc7c6700005d00d0000d500000000007700000000766700076666cccccccc6707000000000000000000000000000000000000000000000
0000076ccccccccccc77cc67000005d0000000000000000000000000000077000777777666cccc67000000000000000000000000000000000000000000000000
00000076cccccccccc6667700000005d0000000000077777777000000000000076cc6777776ccc67000000000000000000000000000000000000000000000000
00000076cccc6666667770000000000000077777777eeeeeeee77777770000076cccc66776cccc67033000000000000000000000000000000000000000000000
00000007666677777700000000000777777eeeeeeee88888888eeeeeee7000076cccccc66cccc67033f300000000000000000000000000000000000000000000
00000000777700000000000007777eeeeee88888888888888888888888e70000766cccccccc7c670333300000000000000000000000000000000000000000000
0000000000000000000777777eeee888888eeeeeeeeeeeeeeeee8888888e70000776666cc77c6700033000000000000000000000000000000000000000000000
0000000000000007777eeeeeeeeeeeeeee777777777777777777eeeee88e700000077776666670000000d0000000000000000000000000000000000000000000
000000000000000000077777777777777700000000000000000077777ee70000000000077777000000d00d000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000077000000000000000000000005000500000000000000000000000000000000000000000
009889000099a9000099880000988800009889000089a9000099880000998800006666000066660000666600006666000066660000666600006dd60000dd6600
09999a90099a988009a9888009a9889009a99a90099a988009aa988009a988900666666006666660066666600666666006666d600666dd6006d666600d666660
89a9a98899aa9888999a9889889a99a989a9a98899aaa988999a9889889a99a96666666666666666666666d6666666d66666d666666d66666d666666d6666666
999aa9889a99a9889899a99a889a9a98889aaa988899a9888899a99a889a9a98666666666666666d666666d666666d66666d666666d66666d6666666d6666666
9aa99a9899899a988889a9a98889aaa988899a9888899a998889a9a98999aa986666666d6666666d66666d666666d66666d666666d666666d666666666666666
a99899a998889a9889889aa989889999898899a998889a9998999aa999aa99a96666666d666666d66666d666666d66666d6666666d6666666666666666666666
09888990099889900a9889900a9888900a98899009899990089aa9900a998990066666d006666d6006dd666006d6666006666660066666600666666006666660
00a8890000a8880000a9880000a98800009899000089990000a99800009888000066dd00006dd600006666000066660000666600006666000066660000666600
005555000011550000d15500001555000055550000555000005510000010010000ccc700006cc700007cc70000ccc70000ccc70000ccc700007cc70000ccc700
0555555001dd155006d155500d15551005555510055510100551001001d115500cc6cc700677cc700ccccc7006cccc7007cccc700cc7cc700ccccc700ccccc70
555511551d6dd155dd155551d15551005555510055510155551d11551d155555cc677cc7c6ccccc7cc6cccc7777cccc777cc7cc7ccccccc7ccccccc767cc6cc7
5551dd151dddd155115555101555510155551015551d155551d1555501555555cc6cccc7ccc6ccccc777cccc67ccc7cc7cccccccccccccccc67cc6ccc6c677cc
551d6dd151dd15555555551055551d155551d155510155551015555101555511cccc6ccccc777cccc67ccc7ccccccccccccccccccc67cc6ccc6c677cccc6cccc
551dddd155115555555551d15511d15555101555001555550015551d155551dd7cc777cc7c67cccc7ccccccc7ccccccc7cc67cc67cc6c6777ccc6ccc7cccc6cc
0551dd100555555005511d10010015500101555001555550015551d005551d6007c67cc007ccccc007ccccc007cc67c007cc6c6007ccc6c007cccc7007cc7770
0055110000555500001001000001550000055500005555000055510000551d0000cccc0000cccc0000ccc60000ccc60000cccc0000cccc0000ccc70000cc6700
00222200002222000092220000922200002222000022220000292200002222000000000000000000000000000000000000000000000000000000000000000000
022222900229229009a9229009222290022222900222929002222290022222900000000000000000000000000000000000000000000000000000000000000000
22229222229a92222292222222222222222229229222222222222222222222220000000000000000000000000000000000000000000000000000000000000000
2229a922222922222222222222222292292222222222222222222222222229220000000000000000000000000000000000000000000000000000000000000000
2222922222222222222222292292222222222222222222222222229222229a920000000000000000000000000000000000000000000000000000000000000000
222222222222222222292222222222222222222222222229222229a9222229220000000000000000000000000000000000000000000000000000000000000000
09222220092292200922222009222220092222200922229009222290092222200000000000000000000000000000000000000000000000000000000000000000
00222900002222000022220000222200002222000022220000222200002222000000000000000000000000000000000000000000000000000000000000000000
0011110000b1110000111100003b110000b111000011110000bb110000b111000000000000000000000000000000000000000000000000000000000000000000
011b1170011111700133b1700bb111700b111170011bb1700b3b11700b1111700000000000000000000000000000000000000000000000000000000000000000
1111111111133b1113bb1111b11111111111bb1111b3b1111b3b11111111b1110000000000000000000000000000000000000000000000000000000000000000
111133b1113bb1111b11111111111bb1111b3b1111b3b11111b11b11111111110000000000000000000000000000000000000000000000000000000000000000
1113bb1111b11111111111bb1111b3b1111b3b11111b11b1111111111111133b0000000000000000000000000000000000000000000000000000000000000000
711b11117111111b71111b3b7111b3b17111b111761111117611113371113bb10000000000000000000000000000000000000000000000000000000000000000
07111110071111b007111b3007111b100711111007111130071113b00711b1100000000000000000000000000000000000000000000000000000000000000000
00111100001111000011110000111100001111000011130000111b00001111000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000101000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00008f8b8c8d8e8c8f0000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
808182838485868788898a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
909192939495969798999a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a2a3a4a5a6a7a8a9aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0b1b2b3b4b5b6b7b8b9ba000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
011000000e254142511a2511f25122251262512a2512e2513325137251382513b2513c2513b2513825137251332512e2512a25126251222511f2511a251142510e251132010e2010920104201012010120102205
0101000000000000000000000000000000f25010250122501425016250172501a2501b2501d2501d2501e2501d2501b25018250112500c2500c25000000000000000000000000000000000000000000000000000
010600000e254142511a2511f25122251262512a2512e2513325137251382513b2513c2513b2513825137251332512e2512a25126251222511f2511a251142510e251132010e2010920104201012010120102205
010400003e2543d2513c2513b2513a251392513825137251362513525134251332513225131251302512d2512b2512925128251262512425123251212511f2511d251212511a251152510e251092510225126773
0103000037350303512b35125351223511e351193511335112351153511f351273513035134351373513835138350383553830238302383543835238352383553835238352383523835238352383523835238355
010800003235032350323503235232352323523235232355323023230232305294002940229405294000000000000000000000000000000000000000000000000000000000000000000000000000000000000400
010100000e254142511a2511f25122251262512a2512e2513325137251382513b2513c2513b2513825137251332512e2512a25126251222511f2511a251142510e251132010e2010920104201012010120102205
0103000037350303512b35125351223511e351193511335112351153511f35127351303513435137351383552a3002e3003330039300313002b30026300263002a3002c300303003630000000000000000000000
010500001866000000186600000018600000001860000000186000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000104701147111470114701147011470114751d4050e4700e4700e4700e4720e4720e4720e4720e4751a4021a4021a4021a405181000000018100000001810000000181000000000000000000000000000
01080008021700217002170021750e1700e1700e1751d6030240018407184071d1030e40018407184071d1030e40018407184071d1030e40018407184071d1030e40018407184071d1030e40018407184071d400
0110002000170001750c1700c17500170001750c1700c17500170001750c1700c17500170001750c1700c17502170021750e1700e17502170021750e1700e17502170021750e1700e17502170021750e1700e175
011000200e17102171021710217102171021710217102171021720217202172021720217202172021720217202171021710217102171021710217102171021710217202172021720217202172021720217202172
0110002002450024550945009455084500845509450094550a4500a45509450094550545005455094500945502450094070945000202084500940709450002020845009407094500000008450094070945000000
011000001300011000130000000013000000000000000000130000000000000000001300000000000000000013000000000000000000130000000000000000001300000000000000000013000000000000000000
01100000104701147111470114750e47011470114750e4701147011470114750d4700d47511470114750e470114700e470114701347013475114701147011475114701147211472114750e4700e4700e4700e475
011000001147011470114750e4700e4751147011470114750e4700e4720e4750c4700c4750e4700e4700e4750c4700c4700c47509470094750c4700c4700c4750e4700e4720e4720e47517400184000000000000
0110000015270152751527015272152751827018270182751a2701a2751a2701a2721a27518270182701827515270152701527015275102701127111270112750e2700e2700e2700e2751a100132701527115275
0110000015270152751527015270152751827018270182751a2701a2701a27518270182751a2701a2701a2751d2701f2711d2711d2751a2701a2701a2701a2751a2701a2721a2721a27500000000000000000000
011000001d2701d2751a270182701827515270152701527513270132721327515270152751827018270182751a2701a275182701527015275132701327013275102701127111272112750e2700e2700e2700e275
01100000181701817018175151701517015170181701510018170151701117013170131701117011170111750e1700e1700e1720e1720e1720e1720e1520e1350e1010e1020e1020e1051a1011a1051a1051a105
01100000181701817018175151701517015170181701510018170151701817015170151701817018170181751a1701a1701a1721a1721a1721a1721a1521a1350e1010e1020e1020e1051a1011a1051a1051a105
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000026255000001a200000001a2001a2002625500000252550000000000000000000000000252550000024255000000000000000000000000024255000002325500000000000000000000000000000000000
0110000022255000000000000000000001f255222550000021255000000000000000000000000021255000001d255000000000000000000001a2551d255000001a2551a2061a206000001a2561a2561a25600000
011000001a255212551d2551a255212551d2551a255212551d25526255212551d25526255212551d255262551a255212551d2551a255212551d2551a255212551c2551d2551a255152551a255212551d2551a255
011000001a255212551d2551a255212551d2551a255212551d25526255212551d25526255212551d2552625521255292552625521255292552625521255292551a255212551d2551a2551a255212551d2551a255
0110000029255262552125526255292552625521255262552d2552925526255292552d255292552625529255262552925526255292552b255292552625524255262572125726257212551a2501a2551a20500000
011000002625521255262551d2552125532255212551a2552525521255252552925521255312551c2551d2552425521255242551f255212553025529255242552325521255232551d25523255212552325223255
01100000222551f255222551f255242552e255212551d255212551d255212551d255202552d2551d2551a2551d2551a2551d2551a2551d2551f2551d255182551a255192551a255192551a257212571a25721255
01100000181001725018251182551725017255152501525518250152501725013250152501025011252112520e256152561a256002001a257152570e257212060e257152571a257322571a2551a2551a2551a255
011000001140011400114050e4000e4051140011400114050e4000e4020e4050c4000c4050e4000e4000e4050c4000c4000c40509400094050c4000c4000c4050e4000e4020e4020e40517400184000000000000
011000100c6250c62530625306250c6250c62530625186050c6250c62530625306250c6250c62530625186050c6050c6050c6050c605186051860518605186050c6050c6050c6050c60518605186051860518605
011000000c170181700c1000c170181700c10018403181050c170181700c1000c170181700c1000c1701817007170131700710007170131700710024403181000717013170071000717013170071000717013170
011000000817014170081000817014170081001410018105081701417008100081701417008100081701417008170141700810008170141700810009170151700a17016170051000a17016170051000a17016170
01100000071701317007100071701317007100131001810507170131701d100071700517011170061701217007170131700710007170131700710013100181000717013170071000717013170071000717013170
01100000001700c1700c100001700c1700c1002440318105001700c1700c100001700c1700c100001700c170001700c17007100001700c170071002440318100001700c17007100001700c17007100001700c170
011000000817014170081000817014170081001410018105081701417008100081701417008100081701417008170141700810008170141700810009100151000817014170051000817014170051000817014170
0110000026205000001a200000001a2001a2002620500000252050000000000000000000000000252050000024205000000000000000000000000024205000002320500000000000000000000000000000000000
0110000022205000000000000000000001f205222050000021205000000000000000000000000021205000001d205000000000000000000001a2051d205000001a2051a2061a206000001a2061a2061a20600000
011000001b1001d1001b4601d4601f4601d4601b4601f4601f4621f4621b4601d4601f4601d4601b4601f4601f4621f4621a4601b4601d4601b4601a4601d4601d4621d4621a4601b4601d4601b4601a4601d460
011000001d4621d462184601a4601b4601a460184601b4601b4621b462184601a4601b4601a460184601b4601b4601b4621b4621a4601a4601a46018460184601646016462164621446014460144601646014460
01100000134601346013260134601346013260134601346017461174621746217462174621746217462174601a4611a4601a2601a4601a4601a2601a4601a4602046120462204622046220462204622046220460
011000001f4671a46717467134671f4671a46717267134671f4661a26617466134661f4601a46017460134601f4601f4601f4601f4601f4621f4621f4621f4621f4601a461174611346113465212052320223205
011000001b1001d1001b4601d4601f4601d4601b4601f4601f4621f4621b4601d4601f4601d4601b4601b4501b4551f4021a4601b4601d4601b4601a4601d4601d462164621a4601b4601d4601b4601a4601a460
011000001a46516400184601a4601b4601a460184601b4601b4621b462184601a4601b4601a460184601b4601b4621b462184501a4601b4601a460184601b4601b4621a460184601a4601b4601a460184601a460
01100000134611346013260134601346013260134601346017461174621746217462174621746217462174601a4611a4601a2601a4601a4601a2601a4601a4601d4611d4621d4621d4621d4621d4621d4621d460
01100000204602046020460204602046220462204622046220460204602246122461204612046020460204601f4671a46717467134671f4661a46617466134661f4501a45017450134501f4521f4521f4521f455
011000001b10027460264602746024460274601f46024460274622746227462244602446524400184731b4001b40527460264602746024460274601f460244602746227462274622446024465184731847318473
011000000000026460244602646023460264601d4602046026462264622646223460234650000018473000000000026460244602646023460264601d460204602646226462264622346023460184731847318473
011000000000024460224602446020460244601b4602046024462244622446220460204652140018473000000000024460224602446020460244601b460204602446224462244622046020465184731847318473
011000001f4002346021460234601f460234601a460214602346223462234621f4601f4651f40518473264061f4062346021460234601f460234601a460234602b4612b4622b4622b4622b465184731847318473
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b10024065241652476524565243652440524065241652476524565243502436524405244502446524405244052416524765245652436524405240652416524765245652435024365244552445524465
011000001b5001f0651f1651f7651f5651f365245051f0651f1651f7651f5651f3501f365245051f4501f46524505245051f1651f7651f5651f365245051f0651f1651f7651f5651f3501f3651f4551f4551f465
011000001b50020065201652076520565203652450520065201652076520565203502036524505204502046524505245052016520765205652036524505200652016520765205652235022365224552245522465
011000001b5001f0651f1651f7651f5651f365245051f0651f1651f7651f5651f3501f365245051f4501f46524505245051d1651d7651d5651d365245051d0651d1651d7651d5651d3501d3651d4551d4551d465
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 0a 0f 17 44
00 0a 10 18 44
00 0a 0f 1c 44
00 0a 10 1d 44
00 0a 11 19 44
00 0a 12 1a 44
00 0a 13 1b 44
00 0a 0f 1c 44
00 0a 10 1d 44
00 0b 14 1e 44
00 0b 14 1e 44
00 0b 14 1e 44
02 0b 15 1e 44
03 0c 0d 43 44
00 41 20 43 44
00 41 20 43 44
00 24 20 43 44
01 24 20 43 44
00 21 28 20 44
00 22 29 20 44
00 23 2a 20 44
00 23 2b 20 44
00 21 28 20 44
00 22 29 20 44
00 23 2a 20 44
00 23 2b 20 44
00 21 2c 20 44
00 25 2d 20 44
00 23 2e 20 44
00 23 2f 20 44
00 24 35 20 44
00 23 36 20 44
00 22 37 20 44
00 23 38 20 44
00 24 30 20 44
00 23 31 20 44
00 25 32 20 44
02 23 33 20 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
