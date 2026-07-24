pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- cosmo boing! deluxe v1.0
-- by minsoft (2017)

function _init()
 l_str,l_pln,l_stg="0-0",0,0
 
 debug=false
 creds=0
 hi=0
 d_cred=0
 d_gpio=0
 d_sfx=1
 if cartdata("cosmo_boing_deluxe") then
  hi=dget(0)
  d_cred=dget(1)
  d_gpio=dget(2)
  d_sfx=dget(3) 
 end
 
 if (d_cred==0) creds=9999
 
 coin_drop=0
 
 demo=1
 
 gpio={}
 gpio_off(false)
  
 --starfield
 star={}
 star_col={1,2,5,6,7} 
 for i=1,75 do
  star[i]={}
  star[i].y=rnd(127)
  init_star(i)
 end
 
 --palette fade lookup
 pal_fade={
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
 
 --start w. black screen
 local i
 for i=1,15 do
  pal(i,0,1)
 end

 populate_menu()
 
 p1={}
 p1.scr=0
 p1.bon=0
 p1.pfx="!"
 p1.ch=3
 p1.s=-1
 p1.ico=118
 
 p2={}
 p2.scr=0
 p2.bon=0
 p2.pfx="@"
 p2.ch=1
 p2.s=-1
 p2.ico=119
 
 --demos
 p1.dem={
  0,0,0,1,0,0,0,0,2,2,
  0,0,0,2,0,0,2,1,0,0,
  0,0,0,1,1,2,2,1,32,0,
  0,0,4,2,0,2,1,0,2,0,
  0,34,0,0,0,0,0,2,2,0,4
 }
 p2.dem={
  0,1,0,0,4,2,0,0,0,0,
  2,1,2,2,0,2,0,4,1,0,
  0,1,2,0,2,0,0,4,2,0,
  0,1,2,1,2,0,0,2,1,1,
  0,0,1,0,0,0,0,0,0,0
 }
 
 p1.dem2={
  0,0,0,1,0,1,0,0,0,4,
  0,4,0,0,2,0,2,2,0,2,
  0,0,2,1,0,0,0,2,0,0,
  0,4,2,0,0,0,2,2,0,0,
  2,2,2,0,0,0,0,0,1,0
 }
 p2.dem2={
  0,1,0,0,2,2,0,0,0,0,
  0,0,1,1,4,0,0,1,0,2,
  32,0,2,1,0,4,2,0,4,2,
  0,0,1,0,0,2,0,0,0,0,
  0,0,0,0,0,0,0,0,1,4,
  1,1,1,0,2,0,2,0,0,0,
  0,1,0,0,2,0,1,2,0,1,
  2,0,0,1,0,0,0,0,0,0
 }
 
 --tiles
 t_gap=0
 t_n1=1
 t_n2=2
 t_h1=3
 t_h2=4
 t_h3=5
 t_h4=6
 t_a=7
 
 t={}

 t[t_gap]={}
 t[t_gap].spx=0
 t[t_gap].die=true

 t[t_n1]={}
 t[t_n1].spx=8
 t[t_n1].die=false

 t[t_n2]={}
 t[t_n2].spx=24
 t[t_n2].die=false

 t[t_h1]={}
 t[t_h1].spx=40
 t[t_h1].die=false

 t[t_h2]={}
 t[t_h2].spx=56
 t[t_h2].die=false

 t[t_h3]={}
 t[t_h3].spx=72
 t[t_h3].die=false

 t[t_h4]={}
 t[t_h4].spx=88
 t[t_h4].die=true
 
 t[t_a]={}
 t[t_a].spx=8
 t[t_a].die=false


 --power ups & hazards...
 p_blnk=0
 p_mys=1
 p_jump=2
 p_life=3 
 p_sj=4
 p_left=5
 p_right=6
 p_up=7
 p_fin=8
 
 p={}
 
 p[p_blnk]={}
 p[p_blnk].spt=0
 p[p_blnk].typ=0
  
 --mystery
 p[p_mys]={}
 p[p_mys].spt=96
 p[p_mys].typ="pup"
 p[p_mys].frm=4
 
 --extra jump
 p[p_jump]={}
 p[p_jump].spt=80
 p[p_jump].typ="pup"
 p[p_jump].frm=4
 
 --extra life
 p[p_life]={}
 p[p_life].spt=64
 p[p_life].typ="pup"
 p[p_life].frm=4
 
 --super jump
 p[p_sj]={}
 p[p_sj].spt=120
 p[p_sj].typ="pup"
 p[p_sj].frm=2
 
 --left
 p[p_left]={}
 p[p_left].spt=72
 p[p_left].typ="haz"
 p[p_left].frm=2
 
 --right
 p[p_right]={}
 p[p_right].spt=88
 p[p_right].typ="haz"
 p[p_right].frm=2
 
 --up (jump)
 p[p_up]={}
 p[p_up].spt=104
 p[p_up].typ="haz"
 p[p_up].frm=2
 
 --finish (far left/right)
 p[p_fin]={}
 p[p_fin].spt=112
 p[p_fin].typ=""
 p[p_fin].frm=6
 
 init_title()
 
 if (d_sfx==1 or d_sfx==3) music(0,0,1+2+4)
end

function gpio_off(r)
 if (d_gpio==0 and not r) return
 
 for i=1,4 do
  gpio[i]=0
  poke(0x5f80+i,gpio[i])
 end
end

function populate_menu()

 local cred="free"
 if (d_cred==1) cred="”"
 if (d_cred==2) cred="gpio"
 
 local gpio="off"
 if (d_gpio==1) gpio="on"
 
 local attr="none"
 if (d_sfx==1) attr="all"
 if (d_sfx==2) attr="sfx"
 if (d_sfx==3) attr="mus"
 
 menuitem(1,"reset hiscore",function() m_hi() end)
 menuitem(2,"credits:"..cred,function() m_cred() end)
 menuitem(3,"gpio outputs:"..gpio,function() m_gpio() end)
 menuitem(4,"attract sfx:"..attr,function() m_sfx() end)
end

function m_hi()
 hi=0
 dset(0,hi)
end

function m_cred()
 d_cred+=1
 if (d_cred==3) d_cred=0
 dset(1,d_cred)
 run()
end

function m_gpio()
 d_gpio=1-d_gpio
 if (d_gpio==0) gpio_off(true)
 dset(2,d_gpio)
 run()
end

function m_sfx()
 d_sfx+=1
 if (d_sfx==4) d_sfx=0
 dset(3,d_sfx)
 run()
end

function init_star(i)
 --set star x-pos, speed, colour etc
 star[i].x=rnd(127)
 star[i].sp=rnd(3)
 star[i].col=star_col[1+flr(star[i].sp*2)]
 --shooting star?
 star[i].sht=false
 if (star[i].sp>2 and rnd(100)<10) star[i].sht=true 
end

function update_stars()
 --update star y-pos
 for i=1,75 do
  star[i].y+=star[i].sp/2
  if star[i].y>127 then
   star[i].y=0-rnd(64)
   init_star(i)   
   if (rnd(100)<50) star[i].sp+=1
  end
 end 
end

function update_system()
 --sun position
 sun_y+=0.002
 
 --planet...
	--orbit
	plan_x=40*cos(plan_ang)
	plan_y=10*sin(plan_ang)
	--tilt
	--cos(0.54)=-0.9686
	--sin(0.54)= 0.2486
	plan_x=plan_x*-0.9686-plan_y*0.2486
 plan_y=plan_x*0.2486+plan_y*-0.9686
 --offset
 plan_x+=sun_x-4
 plan_y+=sun_y-4
 
	plan_ang+=0.0025
	if (plan_ang>1) plan_ang-=1	
	plan_fr+=0.25
	if (plan_fr==8) plan_fr=0
	
	--moon
	moon_x=plan_x+4+13*cos(moon_ang)
	moon_y=plan_y+4+3*sin(moon_ang)
	moon_ang+=0.025
	if (moon_ang>1) moon_ang-=1	
	
end

function update_logo()	
	--slide 'cosmo' into place
	if (tick<15 and logo_cos_x>36) logo_cos_x-=2
	--wobble 'cosmo'
	if (tick>15 and tick<19) logo_cos_x=36+(5*sin(anim/31))
	
	--slide 'deluxe' into place
	if (gametick>=4 and gametick<=6 and logo_dlx_x<32) logo_dlx_x+=1
	--wobble 'deluxe'
	if (gametick>6 and gametick<15) logo_dlx_x=32-(5*sin(anim/31))
	
	--zoom 'boing' in
	if gametick==2 then
	 logo_w=(88/32)*anim
	 logo_h=anim
	end
	
	--pulsate logo
	if gametick>=3 and gametick<=6 then
	 logo_w=88+(9.78*sin(anim/31))
	 logo_h=32+(3.55*sin(anim/31))
	end
	
	--zoom 'boing' out
	if gametick==15 and anim>0 then
	 logo_w=(88/anim)-1
	 logo_h=(32/anim)-1
	end
	
	--centre logo
	logo_x=64-(logo_w/2)
	logo_y=51-(logo_h/2)
		 
end

function update_gpio12()
 if (waiting=="gameover") return
 
 --press start
 gpio[1],gpio[2]=0,0
 if anim>=16 then
  if (creds>=1 and ((p1.lives==0 and not p1.starting) or scr==2)) gpio[1]=255
  if (creds>1 and ((p2.lives==0 and not p2.starting) or scr==2)) gpio[2]=255
 end
 
 --no jumps!
 if (scr<3) return
 if anim<8 or (anim>=16 and anim<24) then
  if (p1.jumps<10) gpio[1]=255
  if (p2.jumps<10) gpio[2]=255
 end
end

function update_gpio()
 if (d_gpio==0) return
 
 update_gpio12()

 if (scr<3) gpio[3]=0 gpio[4]=0 
 for i=1,4 do
  poke(0x5f80+i,gpio[i])
 end
 
 --debug=" "..(gpio[1]/255)..(gpio[2]/255)..(gpio[3]/255)..(gpio[4]/255)
end

function draw_stars()
 local c,i,j
 local trail_col={6,15,12,13,5,2,1}
 
 for i=1,75 do
  c=star[i].col
  if star[i].sht then
		 circfill(star[i].x,star[i].y,1,5+rnd(2))
		 pset(star[i].x,star[i].y,7)
		 for j=1,7 do
		  pset(star[i].x,star[i].y-j,trail_col[j])
		 end
  else
   
   if (c==1 and star[i].sp>=1 and flr(star[i].y)%2==0) c=13
   if (c==2 and star[i].sp>=1 and flr(star[i].y)%8==0) c=8
   if (c==5 and star[i].sp>=1 and flr(star[i].y)%25==0) c=7
   
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
 
 --planet (over sun)
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
 local c=5
 if (l_no<=10) c=6
 circfill(moon_x,moon_y,1,c) 
end

function get_colour(theme)
 --used for colour cycling...
 local t
 if (theme=="y") t={0,0,4,4,9,9,10,10,7,7,10,10,9,9,4,4}   
 if (theme=="g") t={0,0,3,3,11,11,11,7,7,7,7,11,11,11,3,3}
 if (theme=="b") t={0,0,12,12,12,12,15,15,7,7,15,15,12,12,12,12}
 if (theme=="r") t={0,0,2,2,8,8,14,14,15,15,14,14,8,8,2,2}
 
 local step=flr(anim/2)+1
 
 if (step>16) step-=16
 if (step<1) step+=16
 
 return t[step]
end
 
function printc(str,x,y,align,colour,theme,outline)
 --print string centred or 
 -- left/right aligned
	
	local len,xp,sx,sy
 	
	--string length in chars
	len=#str
	
	--alignment
	xp=x-len*2 --centre
	if (align==1) xp=x --left
	if (align==2) xp=x-len*4	--right
	
	--don't print off-screen
 if (xp<2) xp=2
	
	--cycled colours?
	if (theme and theme~="") colour=get_colour(theme)
  	
 --outline
 if outline>-1 then
  for sx=xp-1,xp+1 do
   for sy=y-1,y+1 do
    if (not (sx==xp and sy==y)) print(str,sx,sy,outline)
   end
  end
 end
 	
 --main text
 print(str,xp,y,colour)
end
 
function get_cell_text_colour(str)
 --determine colour for cell text
 -- ie player colour scheme
 
 local chr=sub(str,1,1)
 local c="y"
 if (chr==p1.pfx) c="g"
 if (chr==p2.pfx) c="b"
  
 return c
end
 
function trim_text(str)
 --remove first char (if special)
 local chr=sub(str,1,1)
 if (chr=="#" or chr==p1.pfx or chr==p2.pfx) str=sub(str,2)
 return str
end
 
function add_combo(pl)
 pl.combo+=1
 if (pl.combo>1) text[pl.hit]="#"..pl.combo.."x"
end

function get_combo_score(combo)
 --5 pts per combo hit
 -- +25 pts for every 5x
  
 return combo*5 + flr(combo/5)*25
end

function get_combo_jumps(combo)
 --0.1 per combo hit
 -- +1 for every 10x
 
 if (combo<=1) return 0

 return (combo-1)+10*(flr(combo/10))
end


function reset_combo(pl)
 --cash in the combo and reset count
 if pl.combo>1 then
	 local cs=get_combo_score(pl.combo)
		add_score(pl,cs)		
		pl.jumps+=get_combo_jumps(pl.combo)
		if (pl.jumps>50) pl.jumps=50
		text[pl.hit]=pl.pfx.."+"..cs
 end
	pl.combo=0
end

function add_score(pl,points)  
 if (scr<3) return
  
 --add to score
 pl.scr+=points
 
 --bonus life?
 if pl.scr>=pl.next_life then
 	pl.lives+=1
  pl.next_life+=3000
  play_sfx(6,pl.ch)
 end
  
 --hiscore?
 if pl.scr>hi then
  hi=pl.scr
  p1.hiscore,p2.hiscore=false,false
  if p1.scr==p2.scr then
   p1.hiscore,p2.hiscore=true,true
  else
   pl.hiscore=true
  end
 end
end
 	
function init_title()
 scroll=0
 anim=0
 gametick=0
 tick=0
 
 p1.lives=0
 p2.lives=0
 
 logo_cos_x=188
 logo_dlx_x=-64
 logo_x=18
 logo_y=35
 logo_w=0
 logo_h=0
 
 --0 title 1 readme 2 demo 3 game
 scr=0 
 waiting="readme"
 
 gpio[3]=0
 
 --reset palette
 l_no=0
 set_palette()
end

function init_demo()
 --ensure demo level is always the same
 srand(5) 
 
 demo=abs(demo-1)
 
 l_no=21
 if (demo==1) l_no=41
 waiting="" 
 demo_step=1
  
 init_game(2)
	init_life()
end
	
function player_start_game(pl)
 --dont reset score etc on title screen
 -- (so last score remains)
 if scr==3 then
  pl.scr=0
  creds-=1
 end
 pl.lives=3
 pl.dead=false
	pl.next_life=3000
	pl.combo=0
	pl.glint=false
	pl.starting=false
end
	
function player_start_life(pl)  
 --p1 position
 if pl==p1 then
  pl.x,pl.y=55,104
	 if (p2.lives>0) pl.x=39
	end
	--p2 position
	if (pl==p2) pl.x,pl.y=87,106
	
	pl.size=15
	pl.inc=-l_speed
	pl.jump=0
	pl.jmp_press=false
	pl.move=0
	pl.combo=0
 if (pl.jumps<l_jumps) pl.jumps=l_jumps

 if (pl.lives>0) pl.dead=false
 if (pl.dead) pl.bon=0
 
 l_addtiles=0
end
	
function init_game(no_players)
 --just used for game over
 -- hiscore message
 p1.hiscore=false
 p2.hiscore=false

	player_start_game(p1)
	if no_players==2 then
	 player_start_game(p2)
	else
  p2.lives=0
  p2.dead=true
 	p2.next_life=3000
 	p2.combo=0
 	p2.glint=false
 	p2.starting=false
 end
		
	make_level()
	
end
	
function init_level()
	scroll=0
	draw=0		 
 cell=1
 anim=0
 gametick=0
 no_jump=false
	 
	set_p2_ch()
	
 if (scr==3) l_str=l_pln.."-"..l_stg
end

function set_p2_ch()
 if (p2.dead) p2.ch=-1 return
 
 --ch 2
 p2.ch=2
 
 --p1 alive / death sfx playing
 if (p1.s>-1 or not p1.dead or stat(19)==5) return
 
 --ch3 - ideal!
 p2.ch=3
end

function init_life()
	
 local i
	 
	player_start_life(p1)
	player_start_life(p2)

 --clear powerups
 clear_pups()
	 
 --add new powerups
 add_pups(p_life,0,l_pup_life)
 add_pups(p_jump,0,l_pup_jump)
 add_pups(p_mys,0,l_pup_mys)
 add_pups(p_sj,0,l_pup_sj)
	
	--revert holes
 for i=1,l_len do
  if (cells[i]==t_h4) cells[i]=t_h1
 end
 
 gpio[3]=0
     		
end

function clear_cell_text(a)
 for i=1,l_len-8 do
  --player text
  if (a and sub(text[i],1,1)==p1.pfx or sub(text[i],1,1)==p2.pfx) text[i]=""
  --non player-specific
	 if (sub(text[i],1,1)=="#") text[i]=""
 end
end

function _update60()
	update_counters()
 update_stars()
	check_title_inputs()
 update_gpio()
 next_event()
	
	--title screen only
	if scr==0 then
  update_logo()
 end	
 
 --demo/game only
 if scr>=2 then
  update_system()
  update_tiles()
  update_ball(p1)
  update_ball(p2)
	 check_contact()
	 bounce_sfx()
	 check_finish()
	end
 
end

function update_tiles()
 --disappearing tiles
	if rnd(10)<6 and l_dis>0 and anim>=16-l_dis and anim<=16+l_dis then
	 --pick random cell (onscreen!)
	 cell=(draw+4)*8+flr(rnd(40))
  
  --set tile to vibrate
  if (cell<l_len and cells[cell]>=t_h1 and cells[cell]<=t_h3) vibr[cell]=32
	end
end

function update_ball(pl)
 if (not eval_ball_in_play(pl)) return
		 
 pl.size+=pl.inc
		
	bounce_ball(pl)
 drop_ball(pl)
 check_inputs(pl) 
end
 
function bounce_ball(pl)
 --see if ball has hit ground...
  
 if (pl.size~=0) return
  
 --bounce
	pl.inc=-pl.inc
			
	--collision not required
	-- while waiting
	if (waiting~="" and waiting~="demo") return
		
	--see what we hit
	pl.hit=get_cell_over(pl)   
			
	--note tile/power up hit
	local chit=cells[pl.hit]
	local phit=pups[pl.hit]
	local cdie=t[chit].die
	local ptyp=p[phit].typ
			
	--hit a good tile
	
	--hazard + 2 pts (already +1 above)
	if ptyp=="haz" then 
	 add_score(pl,1)
	 add_combo(pl)			   
	end
	--reset combo if non-hazard hit
	if (not cdie and ptyp~="haz" and (pups[pl.hit]==p_blnk or p[pups[pl.hit]].spt~=p[p_sj].spt)) reset_combo(pl)
		
	--sfx...
			
	--hit a gap
	if cdie then  	
	 --play_sfx(5,pl.ch)
	 pl.s=5
 	
	 pl.lives-=1
		pl.dead=true
	 pl.bon=0
	 pl.combo=0
	 
	 if p1.dead and p2.dead then
	  clear_cell_text(true)
	  waiting="death"
	  if (scr==2) waiting="leveldone"
		 tick=0
		end
		
		return
	else
	 --normal bounce
	 if (pl.jump==0) pl.s=0
 end
		 
	--power ups...
	--extra life		 
 if phit==p_life then
		pups[pl.hit]=p_blnk
  if (pl==p1) text[pl.hit]=pl.pfx.."1up"
  if (pl==p2) text[pl.hit]=pl.pfx.."2up"
	 pl.lives+=1
		l_pup_life-=1
		pl.s=6
		--play_sfx(6,pl.ch)
	end
	--extra jump
	if phit==p_jump then
		pups[pl.hit]=p_blnk
	 text[pl.hit]=pl.pfx.."+jmp"
	 pl.jumps+=10
	 if (pl.jumps>50) pl.jumps=50
	 l_pup_jump-=1
	 pl.s=6
	 --play_sfx(6,pl.ch)
	end
	--add tiles
	if phit==p_mys then
	 pups[pl.hit]=p_blnk
	 text[pl.hit]=pl.pfx.."!"
	 l_addtiles+=25
	 l_pup_mys-=1
	 pl.s=6
	 --play_sfx(6,pl.ch)
	end
	--super jump
	if phit==p_sj then
		pl.jump=3
	 add_combo(pl)
		l_pup_sj-=1
		pl.s=4
		--play_sfx(4,pl.ch)
	end

	--hit a left/right
	if phit==p_left then
	 pl.move=-16
	 if (pl.jump==0) pl.s=1 --play_sfx(1,pl.ch)
	end
	if phit==p_right then
		pl.move=16
		if (pl.jump==0) pl.s=1 --play_sfx(1,pl.ch)
	end
		 
	--hit a jump
	if phit==p_up then
	 if (pl.jump==1) pl.jump=2 pl.s=3 --play_sfx(3,pl.ch)
	 if (pl.jump==0) pl.jump=1 pl.s=2 --play_sfx(2,pl.ch)
	end
			 
end 

function bounce_sfx()
 --always play p1 sfx 
 if (p1.s>-1) play_sfx(p1.s,p1.ch)
 
 set_p2_ch()

 --only play p2 sfx if different
 if p2.s==-1 or p2.s==p1.s then
  p1.s=-1
  p2.s=-1 
  return
 end
 
 play_sfx(p2.s,p2.ch) 
 
 p1.s=-1
 p2.s=-1
end

function drop_ball(pl)
 --reached highest point		
	if pl.jump==0 and pl.inc>0 and pl.size==8 then 
		pl.inc=-pl.inc
  return
 end
 --jump
	if pl.jump==1 and pl.size>=16 then
		pl.inc=-pl.inc
		pl.jump=0
		pl.jmp_press=false
		pl.glint=true --annoying but easiest
	 return
	end
	--double jump
	if pl.jump==2 and pl.size>=24 then
		pl.inc=-pl.inc
		pl.jump=0
		pl.jmp_press=false
		pl.glint=true --annoying but easiest
	 return
	end
 --super jump  
	if pl.jump==3 and pl.size>=48 then
	 pl.inc=-pl.inc
	 pl.jump=0
	 pl.jmp_press=false
	 return
	end
			
end
 
function get_cell_over(pl)
 local oncell
 local hit
  
 --see what we hit
	if (pl.x>=0 and pl.x<16) hit=1
	if (pl.x>=16 and pl.x<32) hit=2
	if (pl.x>=32 and pl.x<48) hit=3
	if (pl.x>=48 and pl.x<64) hit=4
	if (pl.x>=64 and pl.x<80) hit=5
	if (pl.x>=80 and pl.x<96) hit=6
	if (pl.x>=96 and pl.x<112) hit=7
	if (pl.x>=112 and pl.x<=128) hit=8

 oncell=((draw+2)*8)+hit 
  
 return oncell
end
 
function check_contact()
 --check if players have bumped
 if (p1.dead or p2.dead or p1.size~=p2.size) return	
 
 --bumped - p1=left
 local sz=p1.size-1
 if p1.x<p2.x and (p1.x+sz)-(p2.x-sz)>0 then
	 p1.move=-p1.size
  p2.move=p1.size
  play_sfx(1,2)
	end 
	--bumped - p2=left
	if p2.x<p1.x and (p2.x+sz)-(p1.x-sz)>0 then
	 p1.move=p1.size
	 p2.move=-p1.size
	 play_sfx(1,2)
	end 
end
 
function check_finish()
 if (waiting~="") return
	
	--don't let player jump right 
	-- at the end
	if (draw*8==l_len-24 and p1.inc<0) no_jump=true
	
	--reached finish line
	--nb players reach finish at
	-- same time (if alive)
 if (draw*8~=l_len-16) return
 
 --stop super jump
 p1.inc=-l_speed
 p2.inc=-l_speed
 p1.jump=0
 p2.jump=0
 p1.jmp_press=false
 p2.jmp_press=false
 
 reset_combo(p1)
 reset_combo(p2)
 if (p1.jumps>l_jumps and not p1.dead) p1.bon+=(p1.jumps-l_jumps)*5
 if (p2.jumps>l_jumps and not p2.dead) p2.bon+=(p2.jumps-l_jumps)*5
 add_score(p1,p1.bon)
 add_score(p2,p2.bon)
 clear_cell_text(false)
 play_sfx(7,p1.ch)
 waiting="leveldone"
 tick=0
end

function check_title_inputs()
 --credit (up)
 if check_coin() then
  sfx(9,3)
  if scr==1 or scr==2 then
   palette_fade("out")
   init_title()
  end
 end
 
 if (creds==0) return
 
 --start pressed?
 local p1_start=false
 local p2_start=false
 local players=1
 if (btnp(4,0) or btnp(5,0)) p1_start=true
 if (btnp(4,1) or btnp(5,1)) p2_start=true
 
	--start game from title screen  
 if scr<3 and ((p1_start and creds>=1) or (p2_start and creds>=2)) then 
  if (p2_start) players=2
  
  scr=3
  waiting="start"
  tick=0
  palette_fade("out")
  
  play_sfx(-1,p1.ch)
  play_sfx(-1,p2.ch)
  
  l_no=1
  srand(rnd(100))
  init_game(players)
	 init_life()
	 
	 return
 end
 
 --continue (wait until level
 -- over, or other played dies)
 if (p1.lives==0 and p1.dead and creds>=1 and p1_start) p1.starting=true
 if (p2.lives==0 and p2.dead and creds>=1 and p2_start) p2.starting=true
 
 --start now
 if (waiting=="start" and p1.starting) player_start_game(p1) p1.size=p2.size p1.inc=p2.inc
	if (waiting=="start" and p2.starting) player_start_game(p2) p2.size=p1.size p2.inc=p1.inc
 
end

function next_event()
 if (waiting=="" or anim>0) return
 	
 --waited 1 ticks...do stuff
 if tick==1 then  
  if waiting=="start" or waiting=="readme" or waiting=="demo" then 
   palette_fade("in")
   if (waiting=="start" and l_no==1 and p1.lives==3 and (d_sfx==0 or d_sfx==2)) music(0,0,1+2+4) 
   return
  end
  if waiting=="demostart" then
   palette_fade("in")
   waiting=""
   tick=0
   return
  end
  if scr==1 and waiting=="demo" then
   palette_fade("in")
   waiting=""
   tick=0
  end 
 end
 
 if (tick==3 and waiting=="death") gpio[4]=255
 
	--waited 4 ticks...
	if tick==4 then 
	 --game start - get cracking
	 if waiting=="start" then  
	  scr=3
	  waiting=""
	  tick=0
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
   if scr==2 then
    init_title()
    return
   end
   
   l_no+=1
	  make_level()
	  if (p1.starting) player_start_game(p1)
 	 if (p2.starting) player_start_game(p2)
 	 init_life()
   waiting="start"
   tick=0
   
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
 	
	--waited 32 ticks...
	if tick==32 then
 
  --title screen - now on to readme
	 if waiting=="readme" and scr==0 then
	  palette_fade("out")
		 scr=1
		 waiting="demo"
			tick=0
			return
		end
		
  --readme screen - onto demo
	 if waiting=="demo" and scr==1 then
	  palette_fade("out")
		 scr=2
		 init_demo()
		 waiting="demostart"
			tick=0
			return
		end
 
 end
 	
end

function check_coin()
 --no point for free play
 if (d_cred==0) return false
 
 --coin up (with up)
 if d_cred==1 and (btnp(2,0) or btnp(2,1)) then
  creds+=1
  return true
 end
 
 --coin up (with gpio pin 0)
 if d_cred==2 and coin_drop==0 and peek(0x5f80)==0 then
  creds+=1
  coin_drop=15
  return true
 end
 
 return false
end

function check_inputs(pl)

 if (waiting~="") return

 local pn=0
 if (pl==p2) pn=1
 
	--move left/right 
	if pl.move>=-10 and pl.move<=10 then 
	 if scr==3 then
	  if (btn(0,pn)) pl.x-=l_speed
	  if (btn(1,pn)) pl.x+=l_speed
	 else
	  demo_play(pl)
	 end
	end
		
	if pl.move<0 then
		pl.x-=1	
		pl.move+=1
	end
	if pl.move>0 then
		pl.x+=1
		pl.move-=1
	end
		
	--prevent moving offscreen	
	if pl.x<0 then
	 pl.move=8
	 if (pl.jump==0) play_sfx(1,pl.ch)
	end
	if pl.x>127 then
	 pl.move=-8 
	 if (pl.jump==0) play_sfx(1,pl.ch)
	end
	
	--jump
	if (btnp(4,pn) or btnp(5,pn)) and pl.jumps>=10 and pl.jump<2 and not no_jump and pl.size<=8 and not pl.jmp_press then
  pl.jumps-=10
  pl.jmp_press=true
	 
	 --jump
	 if (pl.jump==1) pl.jump=2 pl.s=3 --play_sfx(3,pl.ch)
	 if (pl.jump==0) pl.jump=1 pl.s=2 --play_sfx(2,pl.ch)
	end
		
end
 
function demo_play(pl)
 --this controls the players
 -- during the demo
 if (scr~=2 or scroll~=12) return
 
 local d=pl.dem
 if (demo==1) d=pl.dem2

 --left
 if (band(d[demo_step],1)==1) pl.move-=16
 if (band(d[demo_step],16)==16) pl.move-=8
 --right
 if (band(d[demo_step],2)==2) pl.move+=16
 if (band(d[demo_step],32)==32) pl.move+=8
 --jump
 if (band(d[demo_step],4)==4) pl.jump=1 pl.s=2
 --long jump
 if (band(d[demo_step],8)==8) pl.jump=2 pl.s=3
end
 
function update_counters()
 --advance counters etc...
 
	anim+=1
	if (anim==32) anim=0 gametick+=1
	if (gametick==16) gametick=0		
	if (waiting~="" and anim==31) tick+=1
	
	if (coin_drop>0) coin_drop-=1
	
	--demo counter
	if (scr==2 and scroll==8) demo_step+=1
   
 --dont scroll title screen
	-- or while waiting
	-- (scroll after game over)
	if (scr==0 or (waiting~="" and waiting~="gameover" and waiting~="demoover")) return
		
	--scroll
	scroll+=l_speed
	if scroll==16 then
	 scroll=0	
	 draw+=1		
	end
		
end
 
function update_death()

 gpio[4]=0
  	
	if p1.lives>0 or p2.lives>0 then
  --restart level
  if (p1.starting) player_start_game(p1)
 	if (p2.starting) player_start_game(p2)
  init_level()
  init_life()
   
  waiting="start"
  tick=0
  
  palette_fade("out")
 else 	  
  --game over
 	if (d_sfx==0 or d_sfx==2) music(-1,10000)
 	dset(0,hi)
	 waiting="gameover"
	 tick=0
	end
 	
end
 
function _draw()
   
 cls()
 
 --title screen...
 if scr<2 then
  draw_stars()
  draw_scores()
  if (scr==0) draw_logo()
  if (scr==1) draw_readme()
  draw_minsoft()
  draw_credits()
 end
 
 --demo/game...
 if scr>=2 then
  draw_system()
  draw_stars()
  draw_map()
	 
  --draw highest ball on top
  if p1.size>p2.size then
   draw_ball(p2)
   draw_ball(p1)
  else
   draw_ball(p1)
   draw_ball(p2)
 	end
 	
 	draw_scores()
 	draw_status()
  draw_credits()
  draw_message()
	 
  draw_kill_screen()
  
 end

end
 
function draw_map()
 local x,y,xpos,ypos,sx,sprite,sprite_frm,powerup
  
 --draw map
 cell=1+(8*draw)
 for y=7,-1,-1 do
	 for x=0,7,1 do
	  --this stops trying to draw
	  -- tiles past the end of the level
	  -- when scrolling
	  if (cell>l_len) return
	  
		 --add tiles powerup
	  if l_addtiles>0 and y>=4 and y<=5 and anim==0 and cells[cell]==t_gap then
	   cells[cell]=t_a
	   l_addtiles-=1
	  end
	  
	  --position (& size)
	  xpos=x*16
	  ypos=(y*16)+scroll
		 sx=16
		 
	  if cells[cell]==t_a then
	   sx=1+(anim/2)
	   if (sx==16) cells[cell]=t_n1
	   play_sfx(8,2)
	  end
	  
	  if sx<16 then
	   xpos=xpos+(16-sx)/2
	   ypos=ypos+(16-sx)/2
	  end
	  
	  
	  --hole appearing
	  if vibr[cell]>0 then
	   --vibrate tile
	   xpos=xpos-1+flr(rnd(2.5))
	   vibr[cell]-=1
	   play_sfx(8,2)
	   if (scr==3) gpio[3]=255
	   --advance sprite
	   if vibr[cell]==0 then
	    cells[cell]=cells[cell]+1
	    gpio[3]=0
	   end
	   --remove powerup for holes
	   if (cells[cell]==t_h4) pups[cell]=p_blnk
	  end
	 		
		 sprite=t[cells[cell]].spx
		  		  
	  --draw 2x2 tiles
		 if sprite>t_gap then
		 	--spr(sprite,xpos,ypos,2,2)
		 	--sspr(8,0,sx,sx,xpos,ypos)
		 	sspr(sprite,0,sx,sx,xpos,ypos)
 	 end
			 			 
		 --power ups
		 powerup=p[pups[cell]]
		 sprite=powerup.spt
		 
		 --draw powerup
		 if sprite>p_blnk then
		 	sprite_frm=((anim/2)%8)
				if (sprite_frm>powerup.frm) sprite_frm=0
	   spr(sprite+sprite_frm,xpos+4,ypos+4)   
		 end
				
	  --draw text
	  --note: if text is wider than
	  -- cell then it will be drawn
	  -- over by next cell
	  -- (move to separate loop if critical)
		 if (text[cell] and text[cells]~="" and (y<7 or scroll<3)) printc(trim_text(text[cell]),xpos + 8,ypos+5,0,0,get_cell_text_colour(text[cell]),0)
				
			cell+=1
		
		end --x
	end --y
		
end
 
function eval_ball_in_play(pl)
 --ball never visible on death/gameover 
 if (waiting=="death" or waiting=="gameover") return false
 
 --ball dead (on current level)
 if (pl.dead) return false
  
 --no lives left
 if (pl.lives==0) return false
  
 return true
end
 
function draw_ball(pl)
 --no ball visible on life lost / game over    
 if (not eval_ball_in_play(pl)) return
     
 local c=3
 if (pl==p2) c=12
   
 --draw player ball
 d_size=pl.size
 circfill(pl.x,pl.y,d_size,c)
	circfill(pl.x+(d_size/3),pl.y-(d_size/3),d_size/4,15)
	draw_glint(pl)
end
 
function draw_glint(pl)
	
 --glint centre
 local cx=pl.x+(pl.size/2.5)
 local cy=pl.y-(pl.size/2.5)
	
 --glint line length
 local dist=0
 if pl.jump==1 or pl.glint then
  if (pl.size==12) dist=1
  if (pl.size==13) dist=2
  if (pl.size==15) dist=4
  if (pl.size==16) dist=8 pl.glint=false
 end
 if pl.jump==2 or pl.glint then
  if (pl.size==21) dist=2
  if (pl.size==22) dist=4
  if (pl.size==23) dist=8
  if (pl.size==24) dist=12 pl.glint=false
 end
 if (pl.size==45) dist=2
 if (pl.size==46) dist=5
 if (pl.size==47) dist=10
 if (pl.size==48) dist=16
	 
 if (dist==0) return
	 
 circfill(cx,cy,dist/3,7)
	line(cx-dist,cy,cx+dist,cy,7)
 line(cx,cy-dist,cx,cy+dist,7)
  
end

function draw_scores()
 --score
	printc("1up "..p1.scr,4,2,1,3,"",0)
 printc("2up "..p2.scr,125,2,2,12,"",0)
 
 --hiscore
 printc("hi "..hi,64,2,0,8,"",0)
	 
 --level
 if (scr<3) printc(l_str,5,120,1,7,"",0)
 
 --debug
 if (debug) printc(debug,80,2,1,7,"",0)
end

function draw_credits()
 if (scr==3) return
 
 --free play / credit count
	if (d_cred==0) printc("free play",124,120,2,7,"",0)
	if (d_cred>0 and creds>0) printc("credits "..creds,124,120,2,7,"",0)
	
	--insert coin
	local yp=91
	if (scr==1) yp=108
	if (scr==2) yp=66
 if (creds==0) printc("insert coin",64,yp,0,0,"y",0) 
 if (creds>=1) printc("press Ž or —",61,yp,0,0,"y",0)
 
end
	
function draw_status()
 if (scr<3) return
 --lives & jumps remaining
 draw_lives(p1)
 draw_lives(p2)
 draw_jumps(p1)
 draw_jumps(p2)
 draw_continue()
 draw_progress()
end

function draw_progress()
 if (waiting=="gameover") return

 --progress
 local perc=((draw*8)+flr(scroll/2)) / (l_len-16)
 local x=3+121*perc
 local c=8
 if (perc>0.5) c=9
 if (perc>0.9) c=3
 line(3,127,x,127,c)
 pset(x,127,flr(rnd(16)))	 
end
	
function draw_lives(pl)
 if (pl.lives==0) return
 
 --display 6 lives max
 local dl=pl.lives
 if (dl>6) dl=6
 
 local x=3
 if (pl==p2) x=117
 
 local i,j
  
	for i=0,dl-1 do
	 j=i*9
	 if (pl==p2) j=-j
  spr(pl.ico,x+j,9)
 end
end

function draw_continue() 
 local txt="insert coin"
 local col="y"
 if creds>0 then
  txt="press jump"
  if (p1.lives==0) col="g"
  if (p2.lives==0) col="b"
 end
 if p1.lives==0 and p2.lives>0 then
  if p1.starting then
   txt="please wait"
   col="g"
   if (waiting=="death" or waiting=="leveldone") txt="get ready"
  end
  printc(txt,5,10,1,7,col,0)
 end
 if p2.lives==0 and p1.lives>0 then
  if p2.starting then
   txt="please wait"
   col="b"
   if (waiting=="death" or waiting=="leveldone") txt="get ready"
  end
  printc(txt,124,10,2,7,col,0)
 end
end

function draw_jumps(pl)
 if (pl.lives==0 or scr<3) return
 
 local x1,x2,c=3,43,3
 if (pl==p2) x1,x2,c=84,124,12
 
 --actual
 local full=flr(pl.jumps/10)
 local part=(pl.jumps/10)-full
 --potential
 local pot=get_combo_jumps(pl.combo)
 --sum
 local sfull=flr((pl.jumps+pot)/10)
 local spart=(pl.jumps+pot)/10-sfull 
 --limit to 5
 if (sfull>5) sfull,spart=5,0

	--grey background
 rectfill(x1,117,x2,124,0)
 
 --jumps
 if (anim%3==0) rectfill(x1,118,x1+(sfull*8),121,8)
 rectfill(x1,118,x1+(full*8),121,c)
 --partial jumps
 if (anim%3==0) rectfill(x1,122,x1+(spart*40),124,8)
 rectfill(x1,124,x1+(part*40),122,c)
    
 --grid
 rect(x1,117,x2,125,15)
 line(x1,121,x2,121,15)
 --jump dividers
 for i=x1+8,x2-8,8 do
  line(i,118,i,121,15)
 end
 --partial jump marks
 for i=x1+4,x2-4,4 do
  line(i,123,i,124,15)
 end

end
	
function draw_minsoft()
 local i
  
 --normal sprites
 for i=76,79 do
  spr(i,40+((i-75)*8),118)
 end
  
 if gametick==5 or gametick==13 then
 
  --'in'
  if (anim>=4 and anim<=9) spr(93,56,118) 
  if (anim>=6 and anim<=7) spr(109,56,118)
   
  --'so'
  if (anim>18) spr(94,64,118) 
  if (anim>=24 and anim<=25) spr(110,64,118) 
 end
	 
 if gametick==7 or gametick==15 then
  --'m'
  if (anim>=4 and anim<=9) spr(92,48,118) 
  if (anim>=6 and anim<=7) spr(108,48,118)
   
  --'ft'
  if (anim>18) spr(95,72,118) 
  if (anim>=24 and anim<=25) spr(111,72,118) 
 end
	 
 --year
 if (creds==0) printc("-2017-",127,120,2,12,"",0)
 
end

function draw_logo()
  --'cosmo'
  map(2,0,logo_cos_x,25,7,1)
  
  --'boing'
  sspr(0,64,88,32,logo_x,logo_y,logo_w,logo_h)
	 
	 --'deluxe'  
  map(2,5,logo_dlx_x,69,8,1)
end
	
function draw_message()
 if (scr<3) return
	 
 if waiting=="start" then
  local dots=""
  for i=1,tick do
   dots=dots.."."
  end
  printc("get ready"..dots,44,42,1,0,"y",0) 
  printc("planet "..l_pln.."-"..l_stg,64,58,0,7,"",0)
  --printc("starting jumps: "..l_jumps/10,64,74,0,8,"",0)  
 end
 if waiting=="gameover" then
	 printc("game over",64,42,0,0,"y",0)
  
  local p2_ypos=58
  if (p1.hiscore) printc("1up high score!",64,58,0,3,"",0) p2_ypos=74
  if (p2.hiscore) printc("2up high score!",64,p2_ypos,0,12,"",0)  
 end
 if waiting=="leveldone" then
  printc("level clear!",64,42,false,0,"y",0)
  local p2_ypos=58
  if (p1.lives>0) printc("1up bonus "..p1.bon,64,58,0,3,"",0) p2_ypos=74
  if (p2.lives>0) printc("2up bonus "..p2.bon,64,p2_ypos,0,12,"",0)
 end	
end
	
function draw_kill_screen()
 --kill screen
 if (l_no<51) return
  
 --mess up sprites
 poke(rnd(0x3100),rnd(16))
 --mess up sfx
 if (gametick%8==0) poke(0x3200+rnd(0x1100),rnd(0x100))
end

function draw_readme()
 if tick<15 then
  --page 1...
  --text
  printc("move ball left ‹ and right ‘",61,17,0,11,"",0) 
  printc("               ‹           ‘",61,17,0,11,"r",0)
  printc("press Ž or — to jump",61,32,0,3,"",0)
  printc("      Ž    —        ",61,32,0,3,"r",0)
  printc("press jump on     for long jump",64,47,0,11,"",0)
  printc("hit             for points",64,67,0,3,"",0)
  printc("hit consecutively for combo",64,82,0,11,"",0)
  printc("combos earn points and jumps",64,97,0,3,"",0)
 
  --tiles
  sspr(t[t_h1].spx,0,16,16,55,42)
  sspr(t[t_n2].spx,0,16,16,25,62)
  sspr(t[t_n1].spx,0,16,16,41,62)
  sspr(t[t_h2].spx,0,16,16,57,62)
 
  --arrows
  local sprite_frm=((anim/2)%8)
	 if (sprite_frm>p[p_left].frm) sprite_frm=0
	 spr(p[p_up].spt+sprite_frm,59,46)
  spr(p[p_up].spt+sprite_frm,45,66)
  spr(p[p_left].spt+sprite_frm,29,66)
  spr(p[p_right].spt+sprite_frm,61,66)
 end
 if tick>16 then
  --page 2...
  --text
  printc("avoid     ",64,17,0,11,"",0)
  printc("hit     for super jump",64,32,0,3,"",0)
  printc("collect     for extra life",64,52,0,11,"",0)
  printc("collect     for extra jump",64,72,0,3,"",0)
  printc("collect     to fill gaps",64,92,0,11,"",0)
  
  --tiles
  local x=65
  local s=t_h4
  if (gametick<4 or (gametick>7 and gametick<12)) then
   x=64+flr(rnd(2.5))
   s=t_h3
   play_sfx(8,3)
  end
  
  sspr(t[s].spx,0,16,16,x,12)
  sspr(t[t_h1].spx,0,16,16,33,27)
  sspr(t[t_n2].spx,0,16,16,41,47)
  sspr(t[t_n1].spx,0,16,16,41,67)
  sspr(t[t_h2].spx,0,16,16,45,87)
  
  --powerups
  local sprite_frm=((anim/2)%8)
	 if (sprite_frm>p[p_sj].frm) sprite_frm=0
  spr(p[p_sj].spt+sprite_frm,37,31)
  
  sprite_frm=((anim/2)%8)
	 if (sprite_frm>p[p_life].frm) sprite_frm=0
  spr(p[p_life].spt+sprite_frm,45,51)
  spr(p[p_jump].spt+sprite_frm,45,71)
  spr(p[p_mys].spt+sprite_frm,49,91)
 end
end

function make_level() 
 local i
	 
 init_level()
  
 --change palette
 set_palette()
 	 
 --set level length/bonus etc
	set_level_params()
	 
	--level clear bonus
 p1.bon=l_bonus
 p2.bon=l_bonus
 
 --starting jumps
 p1.jumps=l_jumps
 p2.jumps=l_jumps
 if p1.lives>0 and p2.lives>0 then
  p1.jumps=l_jumps*2
  p2.jumps=l_jumps*2
 end
	  	
	--make empty level
	clear_level()
		
	--add tiles...
	
	--safe tiles
	local good_x_hol=flr((l_safe-l_hole)/2)	
	add_cells(t_n1,good_x_hol)
	add_cells(t_n2,good_x_hol)
	
	--holes-to-be
	if l_hole>0 then
	 add_cells(t_h1,flr(l_hole/3))
	 add_cells(t_h2,flr(l_hole/3))
	 add_cells(t_h3,flr(l_hole/3))
	end
			 
 --first 4 rows safe
 for i=1,8 do
  cells[i]=t_gap
 end
 for i=9,32 do 
  cells[i]=t_n1
  if (rnd(2)<0.5) cells[i]=t_n2
 end
	 
 --add hazards
 add_pups(p_up,l_haz,0)
 add_pups(p_left,l_haz,0)
 add_pups(p_right,l_haz,0)
 
 --finish line
 for i=l_len-7,l_len do 
  cells[i]=t_n1
  pups[i]=p_blnk 
 end
 pups[l_len-7]=p_fin
 pups[l_len]=p_fin 
 text[l_len-6]="f"
 text[l_len-5]="i"
 text[l_len-4]="n"
 text[l_len-3]="i"
 text[l_len-2]="s"
 text[l_len-1]="h"
   	
end
		
function clear_level()
 local i
 cells={}
 pups={}
 text={}
 vibr={}
	 
 --fill tables with blanks
 for i=1,l_len do
		add(cells,t_gap)
	 add(pups,p_blnk)
	 add(text,"")
	 add(vibr,0)
	end
end	
	
function clear_pups()
 --clear power ups
 -- (not hazards!)
 local i
 for i=1,l_len do
  if (p[pups[i]].typ=="pup") pups[i]=p_blnk
 end
end
		
function set_level_params()
 --planet=1-5, stage=1-10
 local l=l_no
 if (l>50) l-=50
 l_pln=flr((l-1)/10)+1
 l_stg=l-((l_pln-1)*10)
 
	--set level details...
 l_len=8*(38+(l_pln-1)*10+(l_stg-1)*5)
 l_safe=75-(l_pln*2)-(l_stg/2)
 l_haz=5+rnd((l_safe/5)) 
 l_hole=10+l/3
 l_dis=flr(0.5+(l/20))
 if (scr==2) l_dis=1
 
 --go easy for a few levels
 if (l_no<4) l_safe+=10
 
 --powerups
 l_pup_life=0
 l_pup_jump=0
 l_pup_mys=0
 l_pup_sj=0
 if (l_safe<70 and l_haz<8) l_pup_jump=flr((1/l_haz)*15)
 if (l_safe<70) l_pup_mys=flr(l_no/10)
 if (l_safe<70) l_pup_sj=flr(l_no/10)

 --level clearance bonus
 l_bonus=l_pln*50
 
 --starting jumps
 l_jumps=l_pln*5
 if (l_jumps<10) l_jumps=10
 
 --last stage of planet
 if l_stg==10 then
  l_safe=90
  l_haz=15
  l_hole=50+l_pln*2
  l_dis=flr(0.5+(l/10))

  l_pup_life=1
  l_pup_jump=0
  l_pup_mys=0
  l_pup_sj=0  
 end
 
 --speed (0.5 or 1)
 l_speed=0.5
 l_addtiles=0
end
	
function add_cells(t_type,per)
 local cnt,i
 cnt=0
	while(cnt<flr(l_len*(per/100))) do
	 i=1+flr(rnd(l_len))  
	 if cells[i]==t_gap then
		 cells[i]=t_type
		 cnt+=1
		end
	end
end
	
function add_pups(p_type,per,no)
 local cnt,i,des
 cnt=0
 	 
 --desired about by %
 des=l_len*(per/100)	 
 --desired amount specified
 if (no>0) des=no
 
 local ignore=33
 if (p_type~=p_up and p_type~=p_left and p_type~=p_right) ignore=49
	 
 while(cnt<des) do
	 i=ignore+flr(rnd(l_len-ignore-8)) --exclude finish line  
	 if cells[i]>t_gap and not t[cells[i]].typ then
	  pups[i]=p_type
	  cnt+=1
	 end
	end
end		
	
function set_palette()
 local p
 	 
 --blue
 if l_no<2 then 
  p={1,2,5,6,13}
  plan_spr=208
 end
	 
 --red
 if l_no==11 then 
  p={2,2,7,14,8} 
  plan_spr=224
 end

 --yellow
 if l_no==21 then
  p={4,2,6,10,9}
  plan_spr=192
 end
	 
 --green
 if l_no==31 then 
  p={1,2,6,3,11} 
  plan_spr=240
 end

 --white
 if l_no==41 then
 	p={5,2,13,6,7}
 	plan_spr=200
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
 sun_x=44+rnd(40)
	sun_y=30
	
 plan_ang=0
	plan_fr=0
	moon_ang=0
	 
end

function palette_fade(direction)
 local i,j,from,to,step
 
 gpio_off(false)
 
 from,to,step=1,7,1
 if (direction=="in") from,to,step=7,1,-1
 
 --levels
 for j=from,to,step do
  --inks
  for i=1,15 do
   pal(i,pal_fade[i][j],1)
  end
  for i=1,3 do
   flip()
  end
 end
end

function play_sfx(sound,channel)
	--attract settings
	if (scr<3 and (d_sfx==0 or d_sfx==3)) return
	
	--sacrifice 'rumble' if both
	-- players are alive
 if sound==8 then
  --use a music channel on demo
  if channel==2 and scr==2 and d_sfx==2 then
   sfx(8,1)
   return
  end
  
  --p2 using ch2
  if (p2.ch==2) return  
  
 end
 
	sfx(sound,channel)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000056666666666666005666666666666600566666666666660056666666666666005666666666666600566666666666660000000000000000000000000
0070070001ddddddddd6dd6001d66ddddddddd60016dddddddddd660016dddddddddd660011dddddddd6d660016dddddddd6d660000000000000000000000000
0007700001dddddddddddd6001ddddddd66ddd6001d6dddddddd6d6001d66ddddddd6d6001d61ddddd6d6d6001d66dd0000d6d60000000000000000000000000
0007700001dddddddddddd6001ddddddddd6dd6001dddddddddddd6001ddd6dddddd6d6001ddd6dd66dd6d6001ddd00000006d60000000000000000000000000
0070070001dddddddddddd6001dddddddddddd6001dddddddddddd6001ddddddddd6dd6001dd6d6dddd6dd6001dd00000000dd60000000000000000000000000
0000000001dddddddddddd6001dddddddddddd6001dddddddddddd6001dddddddddddd6001dd6dd6ddd1dd6001dd000000000d60000000000000000000000000
0000000001dddddddddddd6001dddddddddddd6001dddddddddddd6001dddddddddddd6001ddddddddd6dd6001dd000000000d60000000000000000000000000
0000000001dddddddddddd6001dddddddddddd6001dddddddddddd6001dddddddddddd6001ddddddd6dddd6001dd000000000d60000000000000000000000000
0000000001dddddddddddd6001dddddddddddd6001dddddddddddd6001dddddddddddd6001dd6dddd6ddd66001dd000000000660000000000000000000000000
00000000011ddddddddddd6001dddddddddddd6001dddddddddddd6001dddddddd6d6d6001ddd6dddd6d1d6001dd000000006d60000000000000000000000000
00000000011ddddddddddd6001d1ddddddddd66001dddddddddddd6001ddd1ddddd6dd6001ddd1ddddd6dd6001dd01000006dd60000000000000000000000000
0000000001dddddddddddd6001dd11dddddddd6001d1dddddddd6d6001d11ddddddd6d6001d11d1ddddd6d6001d11d100ddd6d60000000000000000000000000
0000000001dddddddddddd6001dddddddddddd60011dddddddddd160011dddddddddd160011dddddddddd160011dddddddddd160000000000000000000000000
00000000051111111111115005111111111111500511111111111150051111111111115005111111111111500511111111111150000000000000000000000000
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
00ffff00000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
0f3333f000ffff000000000000ffff00000000000000000000000000000000001555551001111110000000000000000000000000000000000000000000000000
f3333f3f0f3333f0000ff0000f3333f0000000000000000000000000000000001555510001555100001110000000000004404400400440004440044004440444
f333333f0f33f3f000f33f000f33f3f0000000000000000000000000000000001555551001555100001551000000000090090090909009090000900909000090
f333333f0f3333f000f33f000f3333f00000000000000000000000000000000015555551015555100015510000000000a00a00a0a0a00a00aa00a00a0aa000a0
f333333f0f3333f0000ff0000f3333f0000000000000000000000000000000001515551001115100000110000000000090090090909009000090900909000090
0f3333f000ffff000000000000ffff00000000000000000000000000000000001101510001001000000000000000000040040040404004044400044004000040
00ffff00000000000000000000000000000000000000000000000000000000001000100000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111111100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000155555101111110000000000000000000000000000000000000000000000000
000ff000000ff000000ff000000ff000000000000000000000000000000000000015555100155510000111000000000007404400400470004440047004440474
00fbbf0000f33f0000f33f0000f33f00000000000000000000000000000000000155555100155510001551000000000090090090909009090000900909000090
00fbbf0000f33f0000f33f0000f33f000000000000000000000000000000000015555551015555100015510000000000a00a00a0a0a00a00aa00a00a0aa000a0
000ff000000ff000000ff000000ff000000000000000000000000000000000000155515100151110000110000000000090090090909009000090900909000090
00000000000000000000000000000000000000000000000000000000000000000015101100010010000000000000000040040040404004044400044004000040
00000000000000000000000000000000000000000000000000000000000000000001000100000000000000000000000000000000000000000000000000000000
ffffffff00ff0000000ff0000000ff00000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000
f333333f00f3ff0000f33f0000ff3f00000000000000000000000000000000000015510000011000000000000000000007000000000070000000007000000070
f333333f0f3333ff0f3333f0ff3333f000000000000000000000000000000000015555100015510000011000000000007f7044004007f700444007f7044407f7
f333333f0f33333ff333333ff33333f0000000000000000000000000000000001555555101555510001551000000000097090090909079090000907909000070
f333333ff33333f0f333333f0f33333f0000000000000000000000000000000015555551011551100015510000000000a00a00a0a0a00a00aa00a00a0aa000a0
f333333fff3333f00f3333f00f3333ff000000000000000000000000000000001115511100011000000110000000000090090090909009000090900909000090
f333333f00ff3f0000f33f0000f3ff00000000000000000000000000000000000015510000011000000000000000000040040040404004044400044004000040
ffffffff0000ff00000ff00000ff0000000000000000000000000000000000000011110000000000000000000000000000000000000000000000000000000000
004444000099990000aaaa000077770000aaaa000099990000ffff0000ffff00000ff00000000000000000000000000000000000000000000000000000000000
0499994009aaaa900a7777a007aaaa700a9999a0094444900f3333f00fccccf000f33f00000ff000000000000000000000000000000000000000000000000000
499aa9949aa77aa9a77aa77a7aa99aa7a994499a94499449f333f33ffcccfccf0f3333f000f33f00000ff0000000000000000000000000000000000000000000
49a77a949a7aa7a9a7a99a7a7a9449a7a949949a949aa949f333333ffccccccff333333f0f3333f000f33f000000000000000000000000000000000000000000
49a77a949a7aa7a9a7a99a7a7a9449a7a949949a949aa949f333333ffccccccff333333f0ff33ff000f33f000000000000000000000000000000000000000000
499aa9949aa77aa9a77aa77a7aa99aa7a994499a94499449f333333ffccccccffff33fff000ff000000ff0000000000000000000000000000000000000000000
0499994009aaaa900a7777a007aaaa700a9999a0094444900f3333f00fccccf000f33f00000ff000000000000000000000000000000000000000000000000000
004444000099990000aaaa000077770000aaaa000099990000ffff0000ffff0000ffff0000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000005d00330000000000000000000000000000000000000000022222000222200002222200022022000000000
000000000000000000000000000000000000000000000033f3000000000000000000000000000000000000000288888202888820028888820288288200000000
00000000000077777700000000000033333300000000d03333000000000000000000000000000000000000002822222028222282282222222822822800222200
00000077777766666677000000003333333333000005000330000000000000000000000000000000000000002e2000002e2002e202eeee202e22e22e02eeee20
000007666666cccccc66700000033333333ff3300000077000770000000000000000000000000000000077002e2000002e2002e2002222e22e22e22e02eeee20
000076cccccccccccccc67000033333333ff7f330000766707667007777770000000000000000000000766702822222028222282022222822822822800222200
000076c7cccccccccccc67000033333333ffff3300076cc676cc67766666677000000777770000000076cc670288888202888820288888202822822800000000
00076c7ccc666666cccc670003333333333ff33330076cc676ccc66cccccc66700077666667007770076cc670022222000222200022222000200200200000000
00076c7cc67777776cccc670033333333333333330076cc676ccccc66cc77cc67076cccccc677666776ccc670111110001111110010000000100001011000011
00076ccc6770000776ccc67003333333333333333076ccc676cccc6776ccc7c6776cc77cccc66ccc676ccc671333331013333331131000001310013113100131
00076ccc6700000076ccc67003333333333333333076cc6776ccc670076cccc676cc7cc66ccccccc676ccc671311113113111110131000001310013101311310
00076ccc677007776cccc6700333f333333333333076cc6776ccc670076ccc6776c7cc6776cccccc676ccc671b1001b11bbbbb101b1000001b1001b1001bb100
00076cccc6777666cccc67000333f333333333333076cc6776cc67000076cc676cccc670076cccc6776ccc671b1001b11b1111001b1000001b1001b1001bb100
000076cccc666ccccccc670000333f33333333330076cc676ccc67000076cc676ccc67000076ccc676ccc6701311113113111110131111101311113101311310
000076ccccccccccccccc670003333ff333333330076cc676cc670000076cc676ccc67000076ccc676ccc6701333331013333331133333310133331013100131
000076cccccccccccccccc6700033333333333300076cc676cc670000076cc676ccc67000076ccc676ccc6700111110001111110011111100011110001000011
000076ccccc6666666ccccc670003333333333000076cc676cc670000076cc676ccc67000076ccc676cc67000000000000000000000000000000000000000000
000076cccc677777776cccc670000033333300005076cc676cc670000076cc676cccc6700076ccc6776c67000001100000000000000000000000000000000000
000076ccc67700000076ccc67005d0000000000d5076cc676cc670000076cc676cccc670076cccc6776670000013310000000000000000000000000000000000
0000076cc67000000776ccc67005d0000000d00d50076c676cc670000076cc6776cccc6776ccccc677667000013bb31000000000000000000000000000000000
0000076cc6770077776cccc67005d00d0000d005000766706cc670000076cc6776ccccc66cccccc677667000013bb31000000000000000000000000000000000
0000076ccc67776666ccccc670005d0d000d00d500007700766700000076cc67076cccccccccccc6776700000013310000000000000000000000000000000000
0000076cccc666cccccc7c6700005d00d0000d500000000007700000000766700076666cccccccc6707000000001100000000000000000000000000000000000
0000076ccccccccccc77cc67000005d0000000000000000000000000000077000777777666cccc67000000000000000000000000000000000000000000000000
00000076cccccccccc6667700000005d0000000000077777777000000000000076cc6777776ccc67000000000000000000000000000000000000000000000000
00000076cccc6666667770000000000000077777777eeeeeeee77777700000076cccc66776cccc67033000000000000000000000000000000000000000000000
00000007666677777700000000000777777eeeeeeee88888888eeeeee77000076cccccc66cccc67033f300000000000000000000000000000000000000000000
00000000777700000000000007777eeeeee8888888888888888888888ee70000766cccccccc7c670333300000000000000000000000000000000000000000000
0000000000000000000777777eeee888888eeeeeeeeeeeeeeeee8888888e70000776666cc77c6700033000000000000000000000000000000000000000000000
0000000000000007777eeeeeeeeeeeeeee777777777777777777eeeee88e700000077776666670000000d0000000000000000000000000000000000000000000
000000000000000000077777777777777700000000000000000077777ee70000000000077777000000d00d000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000077000000000000000000000005000500000000000000000000000000000000000000000
009889000099a9000099880000988800009889000089a900009988000099880000ccc700006cc700007cc70000ccc70000ccc70000ccc700007cc70000ccc700
09999a90099a988009a9888009a9889009a99a90099a988009aa988009a988900cc6cc700677cc700ccccc7006cccc7007cccc700cc7cc700ccccc700ccccc70
89a9a98899aa9888999a9889889a99a989a9a98899aaa988999a9889889a99a9cc677cc7c6ccccc7cc6cccc7777cccc777cc7cc7ccccccc7ccccccc767cc6cc7
999aa9889a99a9889899a99a889a9a98889aaa988899a9888899a99a889a9a98cc6cccc7ccc6ccccc777cccc67ccc7cc7cccccccccccccccc67cc6ccc6c677cc
9aa99a9899899a988889a9a98889aaa988899a9888899a998889a9a98999aa98cccc6ccccc777cccc67ccc7ccccccccccccccccccc67cc6ccc6c677cccc6cccc
a99899a998889a9889889aa989889999898899a998889a9998999aa999aa99a97cc777cc7c67cccc7ccccccc7ccccccc7cc67cc67cc6c6777ccc6ccc7cccc6cc
09888990099889900a9889900a9888900a98899009899990089aa9900a99899007c67cc007ccccc007ccccc007cc67c007cc6c6007ccc6c007cccc7007cc7770
00a8890000a8880000a9880000a98800009899000089990000a998000098880000cccc0000cccc0000ccc60000ccc60000cccc0000cccc0000ccc70000cc6700
005555000011550000d1550000155500005555000055500000551000001001000000000000000000000000000000000000000000000000000000000000000000
0555555001dd155006d155500d15551005555510055510100551001001d115500000000000000000000000000000000000000000000000000000000000000000
555511551d6dd155dd155551d15551005555510055510155551d11551d1555550000000000000000000000000000000000000000000000000000000000000000
5551dd151dddd155115555101555510155551015551d155551d15555015555550000000000000000000000000000000000000000000000000000000000000000
551d6dd151dd15555555551055551d155551d1555101555510155551015555110000000000000000000000000000000000000000000000000000000000000000
551dddd155115555555551d15511d15555101555001555550015551d155551dd0000000000000000000000000000000000000000000000000000000000000000
0551dd100555555005511d10010015500101555001555550015551d005551d600000000000000000000000000000000000000000000000000000000000000000
0055110000555500001001000001550000055500005555000055510000551d000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00008f8b8c8d8e8c8f0000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ab9b9c9d9e9f9cab00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010100000000000000000000000000000032540425106251082510a2510b2510e2510f251112511125112251112510f2510c25105251002510025100000000000000000000000000000000000000000000000000
0101000002254082510e25113251162511a2511c2511f2512025121251222512325124251232512225121251202511f2511c2511a25116251132510e2510825102251132000e2000920004200012000120002205
0105000002254082510e25113251162511a2511c2511f2512025121251222512325124251232512225121251202511f2511c2511a25116251132510e2510825102251132000e2000920004200012000120002205
0108000002254082510e25113251162511a2511c2511f2512025121251222512325124251232512225121251202511f2511c2511a25116251132510e2510825102251132000e2000920004200012000120002205
0110000002254082510e25113251162511a2511e25122251272512b2512d2512f251302512f2512d2512b25127251222511e2511a25116251132510e2510825102251135000e2000920004200012000120002205
0104000026254262512525125251242512425123251232512225122251212512125120251202511f2511f2511e2511d2511c2511a25118251172511525113251112510f2510d2510b25108251052510225126773
0103000037350303512b35125351223511e351193511335112351153511f35127351303513435137351383552a3002e3003330039300313002b30026300263002a3002c300303003630000000000000000000000
010800003235032350323503235232352323523235232355323023230232305294002940229405294000000000000000000000000000000000000000000000000000000000000000000000000000000000000400
010400000017000004186000000018600000001860000000186000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000263502535124351233512235121351203511f3511e3511d3511c3511b3511a351193511835117351163511535114351133511235111351103510e3510935102351303003630000000000000000000000
011000000e4220e3320e2420e1520e1620e1700e2700e3700e4700e5720e7720e5720e4720e3620e2520e1420e2320e3220e4120e5120e7120e5120e4100e3100e2100e1100e2100e3100e4100e5120e7120e512
0120000002450024710247002470024700245002431024110e3020e2020e1020e2020e3020e4020e5020e7020e5020e4000e3000e2000e1000e2000e3000e4020e5020e7020e5020e4020e3020e2020e1020e102
012000000e4500e4710e4700e4700e4700e4510e4310e4110e3020e2020e1020e2020e3020e4020e5020e7020e5020e4000e3000e2000e1000e2000e3000e4020e5020e7020e5020e4020e3020e2020e1020e102
01100010024350243502455024500245502455024550245502450024550245002455024550245502450024300e5020e4000e3000e2000e1000e2000e3000e4020e5020e7020e5020e4020e3020e2020e1020e102
011000100e5020e4000e3000e2000e1000e2000e3000e4020e5020e7020e5020e4020e3020e2020e1020e10200000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003e605114000e400114001340013405114001140011405114001140211402114050e4000e4000e4000e405000000000000000000000000000000000000000000000000000000000000000000000000000
011000200e40500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000e4220e3320e2420e1520e1620e1700e2700e3700e4700e5720e7720e5720e4720e3620e2520e142264511a456264561a4562d456214562d45621456294561d456294561d456264561a456264561a436
011000000067000655024503f655024350245502455024550245002455006700065502455024553f655024300245502455024551a4501a45502455024550245500670006550260000670006500e6000067000655
01100000184001a4701a470184701a4701847015472154750e4001a4701a470184701a4701847015472154750e4001a4701a470184701a4701847015472154721d4701a4701d4701f4701a4701d4701f4721f452
0110000021470214721f4701f4701d4701a4701a4721a47221470214721f4701f4701d4701a4701a4721a4721d4701a4701d4701e4701f4701747018470194701a4701a4721a4721a4551a1001a1051a1051a105
012000001a3101a3301a3501a3701a3701a3701a3701a3701a3701a3701a3701a3701a3701a3501a3301a3101d3101d3301d3501d3701d3701d3701d3701d3701d3701d3701d3701d3701d3701d3501d3301d310
012000001f3101f3301f3501f3701f3701f3701f3701f3701f3701f3701f3701f3701f3701f3501f3301f3101a3101a3301a3501a3701a3701a3701a3701a3701a3701a3701a3701a3701a3701a3501a3301a310
012000100e3100e3310e3510e3710e3700e3700e3700d3710e3710e3700e3700e3700e3700e350023310231526200262002620026200262002620026200262002620026200262002620026200262002620026200
011000001a2611d2601f2601a2601d2601f2601a2601d2601f2601f260212612126221262202312120221205212501d2601f260212601f2601d2601a260182601a2611a2621a2621a2620223102200182001a200
011000002626126260262601a26019261192601a2611a2602626126260254612620526260262600e2001a2022626024260212601f2601d2601a2601d2601f260212611f2601d2601f2601d2601a2601d2601f260
0110000021261212652120021260212651f20020260202621d2601d2601a2601a2601d2601f2601f2601f260212672d267212672d26724266302662426630266262622626226262262600e2610e2351a20529200
011000000243502435024550e4500e4550245502455024550245002455024500245502455024550e4500e4301a4101a4301a4501a4701a4701a4701a4701a4701247112472124721247212472124501243012410
011000000e4220e3320e2420e1520e1620e1700e2700e3700e4700e5720e7720e5720e4720e3620e2520e14215110151301515015170151701517015170151701a1711a1721a1721a1721a1721a1501a1301a110
011000001200012000120001200012000120001200012000120001200012000120001200012000120001200012010120301205012070120701207012070120701507115072150721507215072150501503015010
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001a4660e4661a4760e4761a4060c60530605186051a4660e4661a4760e4760e4060c6053060518605114071d407114771d477114071d4071d40611406134771f477134761f47618605186051860518605
011000000e4671a467264770e477114771d47729467114670e4501a460264600e460114601d46029460114500e4661a466264760e476114761d47629466114660e4561a4660e4661a466114661d466114661d456
01100000154662146615476214760e4571a4570e4571a457154662146615476214760e4561a4560e4561a456114661d466114761d476134671f467134671f4670e4661a4660e4661a466024311a4002640032400
0110000032405264051a4050e40535405294051d40511405000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000001000c1000c100001000c1000c1002440318105001000c1000c100001000c1000c100001000c100001000c10007100001000c100071002440318100001000c10007100001000c10007100001000c100
011000000810014100081000810014100081001410018105081001410008100081001410008100081001410008100141000810008100141000810009100151000810014100051000810014100051000810014100
0110000026205000001a200000001a2001a2002620500000252050000000000000000000000000252050000024205000000000000000000000000024205000002320500000000000000000000000000000000000
0110000022205000000000000000000001f205222050000021205000000000000000000000000021205000001d205000000000000000000001a2051d205000001a2051a2061a206000001a2061a2061a20600000
011000000067000655024503f655024350245502455024550245002455006700065502455024553f6550243002435024350245502450024550245502455024550245002455024500245502455024550245002430
011000000067000655024503f655024350245502455024550245002455006700065502455024553f655024300067000675024553f65502435024551a2530245502450024551a2531a2531a253024553f65502430
011000200067000655024303f655024350245502455024550245002455006700065502455024553f655024300067000675024553f65502435024551a2530245502450024551a2531a2531a253024553f65502430
011000001f4071a40717407134071f4071a40717207134071f4061a20617406134061f4001a40017400134001f4001f4001f4001f4001f4021f4021f4021f4021f4001a400174001340013405212052320223205
011000001b1001d1001b4001d4001f4001d4001b4001f4001f4021f4021b4001d4001f4001d4001b4001b4001b4051f4021a4001b4001d4001b4001a4001d4001d402164021a4001b4001d4001b4001a4001a400
011000001a40516400184001a4001b4001a400184001b4001b4021b402184001a4001b4001a400184001b4001b4021b402184001a4001b4001a400184001b4001b4021a400184001a4001b4001a400184001a400
01100000134001340013200134001340013200134001340017400174021740217402174021740217402174001a4001a4001a2001a4001a4001a2001a4001a4001d4001d4021d4021d4021d4021d4021d4021d400
01100000204002040020400204002040220402204022040220400204002240022400204002040020400204001f4071a40717407134071f4061a40617406134061f4001a40017400134001f4021f4021f4021f405
011000001b10027400264002740024400274001f40024400274022740227402244002440524400184031b4001b40527400264002740024400274001f400244002740227402274022440024405184031840318403
011000000000026400244002640023400264001d4002040026402264022640223400234050000018403000000000026400244002640023400264001d400204002640226402264022340023400184031840318403
011000000000024400224002440020400244001b4002040024402244022440220400204052140018403000000000024400224002440020400244001b400204002440224402244022040020405184031840318403
011000001f4002340021400234001f400234001a400214002340223402234021f4001f4051f40518403264061f4062340021400234001f400234001a400234002b4002b4022b4022b4022b405184031840318403
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b10024005241052470524505243052440524005241052470524505243002430524405244002440524405244052410524705245052430524405240052410524705245052430024305244052440524405
011000001b5001f0051f1051f7051f5051f305245051f0051f1051f7051f5051f3001f305245051f4001f40524505245051f1051f7051f5051f305245051f0051f1051f7051f5051f3001f3051f4051f4051f405
011000001b50020005201052070520505203052450520005201052070520505203002030524505204002040524505245052010520705205052030524505200052010520705205052230022305224052240522405
011000001b5001f0051f1051f7051f5051f305245051f0051f1051f7051f5051f3001f305245051f4001f40524505245051d1051d7051d5051d305245051d0051d1051d7051d5051d3001d3051d4051d4051d405
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a000002204082000e20013200162001a2001c2001f2002020021200222002320024200232002220021200202001f2001c2001a20016200132000e2000820002200132000e2000920004200012000120002205
__music__
00 0a 42 43 44
00 0a 42 43 44
00 0a 42 43 44
00 0a 42 43 44
00 0a 0b 43 44
00 0a 0b 43 44
00 0a 0b 43 44
00 0a 0b 43 44
00 0a 0c 43 44
00 0a 0b 43 44
00 0a 0c 43 44
00 0a 0b 43 44
01 0a 0d 43 44
00 0a 0d 43 44
00 0a 0d 43 44
00 0a 0d 43 44
00 0a 28 43 44
00 0a 28 43 44
00 0a 28 43 44
00 0a 28 43 44
00 0a 29 43 44
00 0a 29 43 44
00 0a 29 43 44
00 12 13 43 44
00 14 29 43 44
00 14 29 43 44
00 15 29 43 44
00 15 29 43 44
00 16 2a 43 44
00 17 2a 43 44
00 18 29 43 44
00 19 29 43 44
00 19 29 43 44
00 1a 29 43 44
00 1b 29 43 44
00 0a 0d 43 44
00 0a 0d 43 44
00 0a 0d 43 44
00 1d 1c 1e 44
00 20 29 43 44
00 20 29 43 44
00 21 0d 43 44
00 20 29 43 44
00 20 29 43 44
00 22 29 43 44
02 22 29 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
02 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
