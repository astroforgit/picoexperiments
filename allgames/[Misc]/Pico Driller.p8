pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- pico driller 
-- by @johanpeitz & @johanvinet
-- demake of the namco classic

-- internal data structs
_glyphs,_kerning={},{}
_alphabet="  ! \" # $ % & ' ( ) * + , - . / "..
     "0 1 2 3 4 5 6 7 8 9 : ; < = > ? "..
     "@ ^a^b^c^d^e^f^g^h^i^j^k^l^m^n^o"..
     "^p^q^r^s^t^u^v^w^x^y^z[ \\ ] ^^_ "..
     "` a b c d e f g h i j k l m n o "..
     "p q r s t u v w x y z { | } ~ ^*"

-- loads a font which will then be used by
-- all pr operations
function load_font(fnt)
 _current_font=fnt

 for i=0,#fnt.data/11 do
  local p=1+i*11
  local char=sub(fnt.data,p,p+1)
  _glyphs[char]=
   tonum("0x"..sub(fnt.data,p+2,p+10))
   -- force kerning calculation
   -- makes tlen work without rendering first
   pr(char,-9,-9) 
 end
end

-- prints a string at x0 y0
-- with color c1
-- if c2 is specified a shadow is added of that color
function pr(str,x0,y0,c1,c2)
 local x1,i=x0,1
 
 while i<=#str do
  local char=sub(str,i,i)
  
  if char=="\n" then
   y0+=_current_font.gh+1
   x1=x0
  else
   if char=="^" then
    char=sub(str,i,i+1)
    i+=1
   else
    char=char.." "
   end
   
   local px,k=_glyphs[char],_current_font.gw+1

   -- handle kerning
   for j=1,2 do
    px=shr(px,1)
    if (band(px,0x0.0001)>0) k-=j
   end
   _kerning[char]=k

   -- draw glyph
   for y=0,_current_font.gh-1 do
    for x=0,_current_font.gw-1 do
     px=shr(px,1)
     if band(px,0x0.0001)>0 then
      pset(x1+x,y0+y,c1)
      if (c2) pset(x1+x,y0+y+1,c2)
     end
    end
   end 
   
   x1+=k
  end
  
  i+=1
 end
end

-- custom font text length
-- kerning is calculated on first draw
function tlen(str)
 local l,i=0,1
 while i<=#str do
  local char=sub(str,i,i)
  if char=="^" then
   char=sub(str,i,i+1)
   i+=1
  else
   char=char.." "
  end
  if (_kerning[char]) l+=_kerning[char]
  i+=1
 end
 return l
end

-- returns position of first occurence 
-- of char c in string str
-- or 0 if not found
function indexof(str,c) 
 for i=1,#str do
  if (sub(str,i,i)==" ") return i
 end
 return 0
end



-- font data
font={
 name="font_playful",
 author="johan peitz",
 gw=4,
 gh=7,
 data=[[  0000.0004! 0080.888e" 0000.02aa# 007c.cf80$ 0013.9392% 00d1.22c0& 03eb.9300' 0000.008e( 0108.8894) 0091.110c* 0029.2802+ 0013.9002, 0900.0004- 0003.8002. 0080.0006/ 0091.22400 034c.ccb01 0111.11942 0788.b4303 034c.24304 0447.ccc05 03c4.38b86 034c.b8887 0112.24788 034c.b4b09 0447.4cb0: 0080.0806; 0900.1004< 0210.9202= 0038.3802> 0092.1082? 0103.4438@ 030e.ecb0^a04cf.ccb0^b03cc.bcb8^c0708.88f0^d03cc.ccb8^e0788.b8f8^f008b.88f8^g034c.e8b0^h04cc.fcc8^i0391.113a^j034c.4470^k04a9.9ac8^l0788.8888^m04cc.cfc8^n04cc.edc8^o034c.ccb0^p008b.ccb8^q434c.ccb0^r04cb.ccb8^s03c4.30b0^t0111.113a^u034c.ccc8^v012c.ccc8^w04fc.ccc8^x04cc.b4c8^y0447.4cc8^z0789.2478[ 0188.889c\ 0422.1108] 0191.111c^^0000.0292_ 0780.0000` 0000.010ca 074f.4300b 03cc.cb88c 0308.8b02d 074c.cf40e 070f.cb00f 1113.9122g 3474.cf00h 04cc.cb88i 0088.880ej 1a22.2022k 04a9.ac88l 0108.888cm 04cc.fc80n 04cc.cb80o 034c.cb00p 0bcc.cb80q 474c.cf00r 0088.9e80s 03c3.0f00t 0211.1392u 034c.cc80v 012c.cc80w 04fc.cc80x 02a9.2a82y 1a74.cc80z 0389.2382{ 3110.9132| 0888.888e} 1912.111a~ 0000.6d80^*0024.0900]]
}



-- good things
tilesize=16 					 -- pixels
fall_speed=0.125  -- tiles
move_speed=0.125  -- tiles
climb_speed=0.124 -- seconds
climb_delay=6  			-- frames
fall_align_speed=0.25 --seconds
drop_delay=1 				 -- seconds
blink_delay=0.5   -- seconds

-- title waves
wave_sync=0.37 -- (0-1)
title_music_start=66 -- frames until music starts
bpm=0.83333333
-- algo: 60 / (8 / (120 / 9))/120


function _init()
 cartdata("jppicodriller")
 
 pal_reset()
 load_font(font)
 start_intro()
 
 hiscores={}
 for i=1,8 do
  hiscores[i]=dget(i)
 end
end

function start_title(_tick)
 retry=false
 new_best=false
 game_state=0
 -- 0 = title
 -- 1 = transition to play
 -- 2 = playing
 -- 3 = game over
 -- 4 = win!!!
 menu=menues["title"]
 menu_slot=1
 menu_hint_y=1000
 desc_text1=""
 desc_text2=nil
 bg_col=1
 
 camy=-128
 tick=_tick
 title_tick=_tick
 parallax_y=0

	clusters={}
	pl=nil
 screenshake=0
 
 btnbits=0 
end

function start_game()
 camy=-128

 title_tick=0
 game_state=2
 
 started_drilling=false
 next_air_x=3
 next_air_y=6
 last_air_x=-999
 last_air_y=-999
 player_level=1
 world_level=1
 current_ld=level_data[world_level]
 screenshake=0
 depth_indicator=nil
 lives_shake=0
 air_shake=0
 
 airtank_sx=0
 airtank_sy=0
 airtank_t=-1
 
	pl={
	 x=3,x0=3,x1=3,
	 y=-7,
	 max_y=0,
	 dir=4,
	 wall=0,
	 wall_count=0,
	 speed=move_speed,
	 air=101,
	 state=0,
	 lives=3,
	 -- 0-falling
	 -- 1-on ground - idle
	 -- 2-climbing	
	 -- 3-squashed
	 -- 4-asphyxiated
	 drilling=0, 
	 walking=0,
	 beam_count=0
	}
 	
	-- other things
	static_block=make_block(-1,-1)
	static_block.cluster={state=0}
	static_block.col=-1
	static_block.static=true
	
	drill_penalty=0
	drill_pressed=false

	clusters={}
	cluster_count=0
 
 blocks={}
 for x=0,7 do
	 blocks[x]={}
 end
	last_row=0
	
	last_cpu=0
	
 music(22)
end

function add_row()
 last_row += 1

	if last_row%level_length==0 then
		world_level+=1
	 current_ld=level_data[min(#level_data, world_level)]

		next_air_y=last_row+current_ld.c_freq
	 next_air_x=flr(rnd()*8)
	end

	-- level variables
	local tot_levels=#level_data
	local ld=current_ld
	local num_colors=ld.cols
 local max_x_per_line=ld.max_x
 local air_freq=ld.c_freq
 local x_freq=ld.x_freq

 local max_x = max_x_per_line

 for x=0,7 do
  local type="color"
  local col=flr(1+rnd()*num_colors)
  
  -- start area
  if last_row<6 then
   if x-4-((last_row-1)/2)>0 then
    type="x"
 		end
   if ((last_row-1)/2)+x<3 then
    type="x"
 		end
  end

		-- random x's
  if rnd()<x_freq and max_x>0 and last_row>7 and last_row%2==0 then
   type="x"
   max_x-=1
   
   -- make sure we don't surround a capsules
   if ld.c_prot==2 or ld.c_prot==0 then
    if last_row==last_air_y and x==last_air_x+1 then
     local b=get_block(x-2,last_row) 
    	if b and b.hits then
    	 -- revert to color
    	 type="color"
    	 max_x+=1
    	end
    end
   end
   
  end
  
  -- nice rows in the beginning
  if last_row<8 then
   local lr=last_row
   if last_row>5 then 
   	lr-=1
   end
   col = 1+lr%num_colors
  end

		-- air protection
		-- 0 - x on top, not surrounded
		-- 1 - x on top
		-- 2 - x on top&below, not surrounded
  -- 3 - x on all sides
  if last_row>6 then
   -- top block
	  if last_row+1==next_air_y and x==next_air_x then
	   type="x"
	   max_x-=1
	  end
  	-- side blocks
  	if ld.c_prot==3 then
    if last_row==next_air_y and x==next_air_x-1 then 
 	   type="x"
     max_x-=1
    end
    if last_row==last_air_y and x==last_air_x+1 then 
 	   type="x"
     max_x-=1
    end 	 
  	end
	  -- btm block
	  if ld.c_prot>1 then
		  if last_row-1==last_air_y and x==last_air_x then
 	   type="x"
	    max_x-=1
				end
  	end  	

  end
  
  if last_row==next_air_y and x==next_air_x then
  	type="a"
  	last_air_x=x
  	last_air_y=last_row

 		next_air_y+=ld.c_freq
 	 next_air_x=flr(rnd()*8) 		
	 end

  -- separators (always override)
  local lr=last_row%(level_length)
  if lr>level_length-5 or lr==0 then
  	type="-"
  end
  
  if last_row>=max_depth+1 then
   type="s"
  end
  
  -- add the block
  if last_row<=max_depth+2 then
	  add_block(make_block(type,col),x,last_row)
  end
 end
 
 
end

function _update()
 tick+=1
 title_tick+=1
 
 if title_tick==20 and game_state==0 then
	 sfx(32,3)
 end

 if game_state==1 then
  if title_tick-transition_tick>15 then
   start_game()
  end
 elseif game_state==0 then
 	-- title
 	 
 	if tick==title_music_start then
 	 music(0)
 	end
 	
  parallax_y+=fall_speed*tilesize
  if tick>60 then
   update_menu()
		end
 elseif game_state==3 then
  update_menu()
 elseif game_state==4 and tick-gameover_tick>60 then
  update_menu()
 end
 
 if game_state>1 then
  -- game
  update_game()
 end
 
 
end

function update_game()
 btnbits=0
 for i=0,5 do
  if btn(i) then
   btnbits+=2^i
  end
 end

 -- update clusters
 update_clusters()
 
	-- reached the goal?
 if game_state<3 and pl.y==max_depth then
  reach_bottom()
	end
 
 
 -- victory animation
 if game_state==4 then
  local dirs={1,4,2,4}
  pl.dir=dirs[1+flr(tick/8)%4]

  if pl.x>1 and pl.x<4 then
   pl.x-=pl.speed/2
   pl.dir=1
   pl.walking=2
  end
  if pl.x>=4 and pl.x<6 then
   pl.x+=pl.speed/2
   pl.dir=2
   pl.walking=2
  end
 end
 -- update player
 if drill_penalty<2 then
	 if pl.state>=3 then
	  if tick-pl.death_tick>45 then
	   if game_state!=3 then
 	   respawn()
	   end
	  end
	 elseif pl.state==0 then
	  -- falling  
	  pl.y += fall_speed*(pl.y<0 and 2 or 1)
	  if pl.x!=pl.x1 then
		  pl.t+= fall_align_speed
		  pl.x = ease_outquad(pl.t,pl.x0,pl.x1-pl.x0,1)
		 elseif pl.x != flr(pl.x) then
	   -- center player?
	   center_player(flr(pl.y)+1)
		 end  
		 
		 if pl.drilling<=4 then
		  pl.dir=4
			end
	  -- landed?
	  local px=flr(pl.x+0.5)
	  local py=flr(pl.y)+1
	  local b=get_block(px,py)
	  local land=false
	  if (b and b.blocking) land=true
		 if land then
		 	pl.y=flr(pl.y)
		 	pl.state=1
		 	if pl.y>pl.max_y then
		 		pl.max_y=pl.y
					if pl.max_y%level_length==0 then
						player_level+=1
			  end
			 end 
		 end
	 elseif pl.state==1 then 
	  -- standing
	  
	  if pl.tt then
	   pl.tt+=0.25
    pl.x = ease_inquad(pl.tt,pl.x0,pl.x1-pl.x0,0.5)
	   if pl.tt>=1 then
	    pl.tt=nil
	   end
	  end
	  
	  if drill_penalty==0 and pl.beam_count==0 and game_state<3 then
			 if band(btnbits,1)>0 then
			 	pl.x -= pl.speed
			 	if (pl.dir!=1) pl.drilling=0
			 	pl.dir = 1
			 	pl.walking=2
			 elseif band(btnbits,2)>0 then
			 	pl.x += pl.speed
			 	if (pl.dir!=2) pl.drilling=0
			 	pl.dir = 2
			 	pl.walking=2
			 elseif band(btnbits,4)>0 then
			 	if (pl.dir!=3) pl.drilling=0
			  pl.dir = 3
			 elseif band(btnbits,8)>0 then
			 	if (pl.dir!=4) pl.drilling=0
			  pl.dir = 4
			 end
	  end
	  
			-- trying to climb?
			if pl.wall != 0 then
			 -- make sure no
			 -- cluster is falling into
			 -- player target tile
			 local try_climb = true
				local px=flr(pl.x+0.5)
				local destb=get_block(px+pl.wall,pl.y-1)
	 		if not get_block(px,pl.y-1) and
	 		   (not destb or destb.air) then
				 if destb and destb.cluster and destb.cluster.state>=3 then
				  pl.wall_count = 0
				 else
				  -- make sure no cluster 
				  -- is falling into
			   -- player target tile
			   local stop_climb=false
				  for c in all(clusters) do
				   if c.state==2 then
				    for b in all(c.blocks) do
				     if not b.air then
				      if flr(b.y+c.y+2)>=flr(pl.y-0.1) then
				       stop_climb=true
				       pl.wall_count=0
				      end
				     end
				    end
				   end
				  end
				 
				  -- looks like all is well
				  if not stop_climb then
				  	pl.wall_count += 1
				 	end
				 end
				end
			else
				pl.wall_count = 0
		 end
		
			local climbing=false
	 	if pl.wall_count>climb_delay then
				pl.y0 = pl.y
				pl.y1 = pl.y - 1
				pl.x0 = pl.x
				
				pl.x1 = pl.x+1*(pl.dir==1 and -1 or 1)
				pl.t=0
				
				pl.wall_count = 0
				climbing=true
				pl.state=2
	 	end
			
			if not climbing then
			 -- move left/right
				local px=flr(pl.x)
				local py=flr(pl.y)
				local bl=get_block(px,py)
				local br=get_block(px+1,py)
				
				if band(btnbits,1)>0 and bl and bl.blocking and bl.cluster.state<4 then
					pl.x=flr(pl.x+1)
					pl.wall=-1	
				elseif band(btnbits,2)>0 and br and br.blocking and br.cluster.state<4 then
					pl.x=flr(pl.x)
					pl.wall=1
				else
					pl.wall=0
				end
			
			 -- start falling?
	   local py=flr(pl.y)+1
	   local px=flr(pl.x+0.5)
	   local b=get_block(px,py)
	   local fall=true
	   if not (b and b.blocking) then
	    -- start falling
	    pl.state=0
	    -- center player?
	    center_player(py)
    end
		 end	
		 			
	 	-- drilling?
	 	if (band(btnbits,16)>0 or band(btnbits,32)>0) and not drill_pressed and not climbing then
		 	pl.drilling=12
		 	pl.wall_count=-16 -- don't climb straight after
		 	if drill() then
		 	 started_drilling=true
		 	 drill_penalty=4
		  end
		  drill_pressed=true 
		 end
		 

	 elseif pl.state==2 then
	  -- climbing
	  pl.y = ease_outquad(pl.t,pl.y0,pl.y1-pl.y0,1)
   pl.x = ease_inquart(pl.t,pl.x0,pl.x1-pl.x0,1)
	  
	  pl.t += climb_speed
	  if pl.t >= 1 then
	  	pl.y = pl.y1
	  	pl.x = flr(pl.x+0.5)
	  	pl.state = 1
	  end
	 end
	end
 
	-- should any clusters fall?
 while check_clusters()>0 do
	end 
 -- only do this once if low cpu
 -- check_clusters()
 
 -- move counters
 if (pl.drilling>0) pl.drilling-=1
 if (pl.walking>0) pl.walking-=1
 if (drill_penalty>0) drill_penalty-=1
 if (lives_shake>=0) lives_shake-=1
 if (air_shake>=0) air_shake-=1
 if (airtank_t>=0) airtank_t+=1
 if (not btn(—) and not btn(Ž)) drill_pressed=false

 if depth_indicator and depth_indicator.move then 
  depth_indicator.dy-=2
  if depth_indicator.dy<-64 then
   depth_indicator=nil
  end

 end
 
 -- new blocks?
 if pl.y+16>last_row then
  --local cpu=stat(1)
 	add_row()
 end
 
 -- pick something up?
 local b=get_block(flr(pl.x+0.5), flr(pl.y))
	if b then
		if b.air then
			del(clusters, b.cluster)
			blocks[b.x][b.y]=nil
			sfx(26,2)
			
			airtank_sx=b.x*tilesize
			airtank_sy=b.y*tilesize-camy
			airtank_t=0
		end
	end
	 
 -- air decrease
 local oxy_usage=level_data[min(#level_data,player_level)].air_usage-less_air
 if airtank_t<0 and started_drilling and tick%oxy_usage==0 then
 	if pl.air>0 and pl.state<3 and game_state<3 then
 	 pl.air-=1
 	end
 end

 -- out of air?
 if pl.state<3 then
	 if pl.air<=0 then
	  knock_out(4)
	  sfx(35,3)
	 end
 end
	-- camera
 -- autoscroll 
 for y=40,72,8 do
  if camy<pl.y*16-y then
   camy+=0.5
  end
 end
 
 camy=min(camy,max_depth*16-80)

end

function center_player(py)
 local pxl=flr(pl.x+1/16)
 local pxr=flr(pl.x+15/16)

 local bl=get_block(pxl,py)
 local br=get_block(pxr,py)

 local bl=(bl and bl.blocking)
 local br=(br and br.blocking)

	pl.x0 = pl.x
	pl.x1 = pl.x
	pl.t=0

 if bl then
 	pl.x1=flr(pl.x+1)
 elseif br then
 	pl.x1=flr(pl.x)
 end
 
end

function wipe_blocks_above(y, spd)
 for c in all(clusters) do
  if c.state!=4 then
  	if c.blocks[1].y<y then
  	 wipe_cluster(c, spd)
	 	end
	 end
 end 		
end


function drill()
	-- drill what?
	local dx=flr(pl.x+0.5+0.6*dirx[pl.dir])
	local dy=flr(pl.y+0.5+0.6*diry[pl.dir])
	
	-- drilled block
	local b=get_block(dx,dy)
	if b then
		
		-- blow away all clusters above
 	if b.separator then
   wipe_blocks_above(b.y, 1)
   depth_indicator.move=true
 	end

		-- remove cluster
	 if b.blocking and not b.hits and not b.static then
	  remove_cluster(b.cluster, true, true)
 		if b.separator then
    set_sfx_speed(27,6)
 			sfx(27,3)
 		else
  		sfx(25,3)
   end
 		return true
 	end
	 if b.hits then
	  b.hits+=1
	  if b.hits>=5 then
    set_sfx_speed(27,3)
 			sfx(27,3)
		  remove_block(b)
		  pl.air=max(0, pl.air-20)
 			return true
 		else
 			sfx(28,3)
 		end
 	end
 	
 end
 
 return false -- nothing was drilled
 
end

function draw_bg_slice(s,y)
 for tx=s*2,s*2+1 do
  for ty=0,3 do
   local tile=ty*16+tx+1
  
	  spr(32+parallax[tile],
	      tx*8,
	      y+ty*8,
	      1,1,tile>32 )
  end
 end
end

function draw_depth_indicator()
 local y=depth_indicator.y+depth_indicator.dy
 palt(0,false)
 palt(10,true)
 pal(8,palette[3])
 pal(14,palette[11])
 pal(15,palette[7])
 pal(2,palette[3])

 spr(158,25,y,1,2)
 spr(158,96,y,1,2,true)
 sspr(127,80,1,12,32,y,64,12)
 spr(143,32,y+2)
 spr(143,89,y+2)

 pr_c(depth_indicator.depth.." ft",64,y+3,7)

 pal()
end

function _draw() 

 cls()
 camera()
 
 if game_state>0 then
  pal_set(bg_pal)
 end
 if game_state==3 then
	 pal_shift(1, dark_pal) 
	 go_fade_steps=min(3,max(0,flr(tick-gameover_tick)/2)) 
 end
 
 -- draw bg tile
 
	-- colors for bg tiles
	if game_state!=1 then
		if tick<30 then
   -- fade in if in title
	 	local steps=max(0,15-flr(tick/1.5))
 	 pal_shift(steps, dark_pal)
	 end
	else
	 -- flash to correct color
	 local steps=5-flr(min(5,(title_tick-transition_tick)/3))
 	pal_shift(steps, light_pal)
	end
 
 palt(0,false)
 for y=0,4 do
	 for s=0,7 do
	 	local cy=flr((camy+parallax_y)/p_speeds[s+1])%32
	 	draw_bg_slice(s,y*32-cy)
	 end
	end
 palt(0,true)

 -- draw game world
 if screenshake>0 then
  screenshake-=1
  camera(rnd(6)-3,camy+rnd(6)-3)
 else
  camera(0,camy)
 end
 pal_reset()
 
 -- draw blocks
 for c in all(clusters) do
	 draw_cluster(c)
 end
	 
 if depth_indicator then	
	 if game_state==3 then
	  pal_reset()
 		pal_shift(go_fade_steps, dark_pal)  
		end
  draw_depth_indicator()
	end
	
	-- tutorial
	if game_state==2 and pl.y<5 then
 	
 	print_s("  move\n‹‘”ƒ",8,2,7,5)
	 print_s("drill\nŽ/—",94,2,7,5)
	end
 -- draw player & hud
 if pl then
  draw_pl(pl.x*tilesize, pl.y*tilesize)
  draw_hud()
	end

 -- draw ui	
	camera()
	tt=title_tick
	if game_state>=3 then
		tt=tick-gameover_tick
	end

 -- draw menu
 if game_state!=2 then
 	draw_menu(tt-30)
 end
 
 -- draw waves
	if game_state!=2 then
		wave_y=ease_outquad(tt/10, -50, 50, 3)
	else
 	wave_y=ease_inquad(tt/10, 0, -50, 3)
 end
 if wave_y>-50 then
  draw_waves(wave_y)
 end
 
 -- draw logo
 if not retry then
		if game_state<2 then
	 	logo_y1=ease_outbounce(max(0, (tt-27))/10, -50, 50, 2)
	 	logo_y2=ease_outbounce(max(0, (tt-15))/10, -50, 50, 2)
		else
	 	logo_y1=ease_inquad(tt/10, 0, -70, 5)
	 	logo_y2=ease_inquad(tt/10, 0, -70, 5)
		end
		if logo_y1>-60 and game_state<3 then
	  draw_logo(logo_y2,logo_y1)
	 end
	end
 
 -- draw menu description
 if game_state==0 then
  local x1=63-2*#desc_text1
  if desc_text2 then
   x1=10
   local x2=127-4*#desc_text2
   print(desc_text2,
         x2,menu_hint_y,15)
  
   spr(92,1,menu_hint_y)
   spr(93,x2-8,menu_hint_y)
  end
  print(desc_text1,
        x1,menu_hint_y,15)
 end 

 last_cpu=stat(1)
	
end

function prep_hud_pal()
 pal()
 palt(10,true)
 palt(0,false)
end


function draw_hud()
 camera()
 
 local cap_x=ease_outquad(max(0,tick-90)/5,-100,100,4)

 -- lives
 prep_hud_pal()
 pal(12,14)
 if (lives_shake>5) pal(white_pal) 
 draw_capsule(1+cap_x+lives_shake%2,116,20,pl.lives)

 
 -- depth
 prep_hud_pal()
 pal(12,9)
 draw_capsule(2+cap_x,2,42,max(0,flr(pl.y*5)),6)
 -- air
 if pl.air>=30 or tick%10>=2 then
		pal(12,12)
		if (air_shake>5) pal(white_pal)
	 draw_capsule(102-cap_x+air_shake%2,2,23,min(100,pl.air).."%")
		sspr(0,32,5,10,98-cap_x+air_shake%2,2)
	end
 palt()

	if airtank_t>=0 then
	 spr(135,
	     ease_inquad(airtank_t/15,airtank_sx,112-airtank_sx,1),
	     ease_inquart(airtank_t/15,airtank_sy,-airtank_sy,1),
	     2,2)
	 if airtank_t>15 then
	  airtank_t=-1
	  -- tank arrived - give air
 	 pl.air = min(101, pl.air+20)	  
	  air_shake=10
	 end
	end
	

 --icons
 pal()
 spr(82,5+cap_x,2) -- drill
 spr(67,35+cap_x,6) -- ft
 if pl.air<30 then
 	pal(15,12)
 	pal(9,13)
 end	
 if (lives_shake>5) pal(white_pal)
	spr(66,4+cap_x+lives_shake%2,116) -- head
end

function draw_capsule(x,y,w,str,pad)
 pad=pad or 0 
 sspr(5,32,5,16,x,y)
 sspr(11,32,1,16,x+5,y,w-10,16)
 sspr(11,32,5,16,x+w-5,y)
 
 str=""..str
 print(str,x+w-#str*4-3-pad,y+3,10)
end

-->8
-- blocks & clusters

function make_block(block_type,col)
 if block_type=="s" then
	 return {
	 	basetile=78, 
	 	tile=0,
	 	single_tile=true,
	 	static=true,
	 	blocking=true,	
	 	col=5
	 }
 elseif block_type=="a" then
	 return {
	 	basetile=135, 
	 	tile=0,
	 	air=20,
	 	col=7,
	 	single_tile=true
	 }
 elseif block_type=="x" then
	 return {
	 	basetile=128, 
	 	tile=0,
	 	col=5,
	 	sticky=true,
	 	hits=0,
	 	blocking=true,
	 	single_tile=true,
	 }
	elseif block_type=="-" then
	 return {
	 	basetile=232, 
	 	tile=0,
	 	autotile=true,
	 	col=6,
	 	sticky=true,
	 	separator=true,
	 	blocking=true
	 }
	end
	
	-- return regular
	return {
 	basetile=current_ld.tileset,
 	tile=0, 
 	autotile=true,
 	draw_block=true,
	 sticky=true,
 	blocking=true,
 	col=col,
 }
 
end

_lb=nil
function add_block(b,x,y)
 b.x=x
 b.y=y
 blocks[x][y]=b
 
 if _lb and _lb.separator and b.separator then
  b.cluster=_lb.cluster
  add(_lb.cluster.blocks, b)
  update_block_tile(b,b.x,b.y)
  
  for d=1,4 do
   local bb=get_block(b.x+dirx[d], b.y+diry[d])
	 	if (bb and not bb.static) update_block_tile(bb,bb.x,bb.y)
	 end 

 else
	 
	 -- check for clusters
	 local friends={b}
	 for d=1,4 do
		 local b2=get_block(x+dirx[d], y+diry[d])
	  if b2 then
				if b.col == b2.col then
				 add(friends, b2)
				end
		 end
		end
		
		-- do autotiling
		for b2 in all(friends) do
	 	update_block_tile(b2,b2.x,b2.y)
	 end 
	 
		-- merge clusters
		local new_cluster=make_cluster()
		
		local new_blocks={}
		if b.sticky then
			for f in all(friends) do
		 	if f.cluster then
		 	 for bb in all(f.cluster.blocks) do
				 	if not contains(new_blocks, bb) then
				 		add(new_blocks, bb)
						end
		 	 end
		 	else
			 	if not contains(new_blocks, f) then
			 		add(new_blocks, f)
					end
		  end
			end
		else
	 	if not contains(new_blocks, b) then
	 		add(new_blocks, b)
			end
		end
	
		for nb in all(new_blocks) do
		 if nb.cluster then
		 	del(clusters, nb.cluster)
		 end
		 nb.cluster=new_cluster
			add(new_cluster.blocks, nb)
	 end
	
		add(clusters, new_cluster)
	end
	
	--if bg_col==5 then -- test_mode
	 _lb=b
	--end
	
end

function make_cluster()
	cluster_count += 1
	
	return {
	 id=cluster_count,
	 blocks={},
	 y=0,
	 drop_timer=-1,
	 state=0
	 -- 0 = stuck
	 -- 1 = shaking
	 -- 2 = falling
	 -- 3 = blinking
	 -- 4 = exploding
	 -- 5 = flying away
	}
end


function get_block(x,y)
 if (x<0 or x>7) return static_block
 if (y<0) return nil

	if (not blocks[x]) return nil
	
	return blocks[x][y]
end


function update_block_tile(b,x,y)
	if b.autotile then
		local bitmask={2,4,1,8}
	 b.tile=0
	 for d=1,4 do
	  local xx=x+dirx[d]
	  local yy=y+diry[d]
	 	local b2=get_block(xx,yy)
	  if b2 then
	   if b.col==b2.col then
		   b.tile += bitmask[d]
	 	 end
	  end
		end
	end
end

function remove_block(b)
 -- remove from current cluster
 
 -- leave statics alone
 if b.static then
  return
 end
 
 local old_cluster=nil
 -- remove it from its cluster
 del(b.cluster.blocks, b)
 if #b.cluster.blocks == 0 then
  del(clusters, b.cluster)
 else
  old_cluster=b.cluster
 end
 
 -- add to a new cluster
 local c=make_cluster()
 add(c.blocks, b)
 b.cluster=c
 -- add new cluster to game
 add(clusters, c)	
 -- remove new cluster
 remove_cluster(c, true, false, true)


 if old_cluster then
  -- autotile old cluster
  for b2 in all(old_cluster.blocks) do
   update_block_tile(b2,b2.x,b2.y)
  end
  -- check if cluster has 
  -- been split and make 
  -- new ones if so
  local new_cluster=make_cluster()
  move_blocks(old_cluster.blocks[1], new_cluster)
  add(clusters, new_cluster)
  if #old_cluster.blocks==0 then
   del(clusters, old_cluster)
  end
 
 end
 
end

function move_blocks(b, c)
 -- move to new cluster
 local oc=b.cluster
 del(oc.blocks, b)
 b.cluster=c
 add(c.blocks, b)
 b.moved=true
 
 -- check neighbours
 for d=1,4 do
  local bb=get_block(b.x+dirx[d], b.y+diry[d])
  if bb and 
     bb.cluster==oc and 
     not bb.moved then
   move_blocks(bb, c)
  end
 end
 
 b.moved=nil
end

function delete_cluster(c)
	for b in all(c.blocks) do
 	blocks[b.x][b.y]=nil 
 end
 del(clusters, c)
end


function remove_cluster(c, instantly, delayed_effect, skip_sound)
	if instantly then
	 -- explode
	 c.state=4
	 local deepy=0
	 for b2 in all(c.blocks) do
	  b2.explode_frame=0
	  if delayed_effect then
		  local dist=distance(pl.x,pl.y,b2.x,b2.y)
	   b2.explode_frame=-flr(dist-1)
	  end
	 	blocks[b2.x][b2.y]=nil 
	 	if b2.y>deepy then
	 	 deepy=b2.y
	 	end
	 end
	 if deepy>pl.y-5 and not skip_sound then
 	 sfx(29,3)
	 end
	else
	 -- blink first
	 c.state=3
	 c.blink_timer=0
 end
end

function drop_cluster(c)
 -- start shaking
 c.state=1
 c.drop_timer=0
end

function check_clusters()
	local count = 0

 -- check if clusters should 
 for c in all(clusters) do
	 if c.state==0 then
		 c.drop_count=0
	  
	 	for b in all(c.blocks) do
	 		if not b.static then
		 		local b2=get_block(b.x,b.y+1)
		 		
		 		if b.y<last_row-2 then
			 		if not b2 then
			 		 -- no block beneath
			 		 -- no support!
			 		 c.drop_count += 1
			 		elseif b2.cluster == b.cluster then
			 		 -- same cluster
			 		 -- no support!
			 		 c.drop_count += 1
		 	  elseif b2.cluster.state==2 then
			 		 -- already falling
			 		 -- no support!
			 		 c.drop_count += 1
			 		elseif b2.cluster.state==1 then
			 		 -- already shaking
			 		 -- no support!
			 		 c.drop_count += 1
			 		end
		 		end
			 end
	 	
	 	end
	 	
	 	if c.drop_count==#c.blocks then
	 		drop_cluster(c)
	 		count += 1
	 	end

	 end
 	
 end
 
 return count
 
end

function reattach_cluster(c)
	local new_cluster=nil

	c.state=0
	del(clusters, c)
	
	for b2 in all(c.blocks) do
		b2.y+=flr(c.y)
		add_block(b2, b2.x, b2.y)
		new_cluster=b2.cluster
	end
	c.y=0
	
	if #new_cluster.blocks > 3 then
		remove_cluster(new_cluster,false,false)
	end
	
end



function update_clusters()

 for c in all(clusters) do
 
 	if c.state==0 then -- normal
 	 -- cull clusters if too far above
 	 local limit=25
 	 -- cull more if cpu is high!
 	 if last_cpu>0.8 then
 	  limit=15
 	 end
 	 if #c.blocks>0 then
  	 if c.y+c.blocks[1].y<pl.y-limit then
  	  delete_cluster(c)
 	  end 
   end
  elseif c.state==1 then 
   -- shaking
  	c.drop_timer+=1/30
  	if c.drop_timer>=drop_delay then
   	c.drop_timer=-1
	  	c.state=2
 		 for b in all(c.blocks) do
		  	blocks[b.x][b.y]=nil
 			end
			end
  elseif c.state==3 then 
   -- blink
			c.blink_timer+=1/30
			if c.blink_timer>=blink_delay then
				remove_cluster(c, true, false)
			end 
		elseif c.state==5 then 
		 -- wipe
			for b in all(c.blocks) do
				b.x+=b.dx
				b.y+=b.dy
			end
			c.wipe_timer+=1/30
			if c.wipe_timer>1 then
				del(clusters, c)
			end 
  elseif c.state==4 then 
   -- explode
			local done_blocks=0
			for b in all(c.blocks) do
			 if tick%2==0 then
					b.explode_frame+=1
				end
				if b.explode_frame>4 then
				 done_blocks+=1
				end
	  end
			if #c.blocks==done_blocks then
				del(clusters, c)
			end
		elseif c.state==2 then 
		 -- falling
			c.y += fall_speed
			
			for b in all(c.blocks) do

				if c.blocks[1].sticky then
					-- check blocks on the right
					if c.state==2 then	
					 local br=get_block(b.x+1,flr(b.y+c.y))
						if br and br.col==b.col and
					   (br.cluster.state==0 or 
						   br.cluster.state==1 or 
						   br.cluster.state==3)
						then
						 reattach_cluster(c)
						end
					end
				
					-- check blocks on the left
					if c.state==2 then	
					 local bl=get_block(b.x-1,flr(b.y+c.y))
						if bl and bl.col==b.col and
					   (bl.cluster.state==0 or 
						   bl.cluster.state==1 or 
						   bl.cluster.state==3)
						then
						 reattach_cluster(c)
						end
					end
				end
			
				-- check ground
				if c.state==2 then		
				 local bd=get_block(b.x,flr(b.y+c.y+1))
					if bd and 
				   (bd.cluster.state==0 or 
					   bd.cluster.state==1 or 
					   bd.cluster.state==3)
					then
					 reattach_cluster(c,true)
					end

				end
				
				-- did we squash the player?
			 local dx=pl.x-b.x
			 if b.sticky and abs(dx)<1 then
			  local by=b.y+c.y
			  if by>pl.y-0.5 and by<pl.y then		     
			   -- squash opportunity
	     if abs(dx)<0.5 then
							-- squash!
							knock_out(3)
	     else
	      -- push out of block
	      pl.tt=0
	      pl.x0=pl.x
	      if dx<0 then
	       pl.x1=flr(pl.x)
	      else
	       pl.x1=flr(pl.x+1)
	      end
	     end
	    end
			 end
			end
		end
 end
  
end


function wipe_cluster(c, spd)
 c.state=5
 c.wipe_timer=0
 for b in all(c.blocks) do
	 blocks[b.x][b.y]=nil
 	b.dx=0.06*(b.x-pl.x)+0.03*(b.y-pl.y)
 	b.dy=spd*(-0.05+0.03*(b.y-pl.y))
 end
end

function draw_cluster(c)

 local cy=tilesize*c.y

 -- draw blocks
 local first=true
	for b in all(c.blocks) do

  local by=b.y*tilesize
  local bx=b.x*tilesize

		if cy+by>camy-16 and
					cy+by<camy+128 then

	  local cx=c.state==1 and 1.5*sin(b.cluster.blocks[1].y/5+t()*4) or 0

		 -- set colors
		 if first then
			 pal_reset()
			 pal_pal(12,block_pals[1][c.blocks[1].col])
			 pal_pal(13,block_pals[2][c.blocks[1].col])
			 if game_state==3 then
					pal_shift(go_fade_steps, dark_pal)  
				end
				first=false
			end
		
			if c.state==4 then
				-- explosion
				local tile=160
				if b.explode_frame>=0 then
				 tile=160+2*b.explode_frame
				 if tile<170 then
						spr(tile, cx+bx, cy+by, 2, 2)
				 end
				else
					draw_block(b,cx+bx, cy+by) 
				end
			else
			
				-- regular
				if c.state!=3 or sin(t()*10)>0 then
					if b.autotile then
					 -- color block
					 draw_block(b,cx+bx, cy+by) 
					end
						
					if b.single_tile then
					 spr(b.basetile, 
			 							cx+bx,
			 							cy+by,
					      2, 2)
					end	
					
					if b.air then
							spr(148+(tick/4)%4, 
		 				    cx+bx, cy+by+8)
					end	
				           
			  if b.hits then            	 
			  	if b.hits>0 then
			  	 spr(130, cx+bx, cy+by) 
			  	end
			  	if b.hits>1 then
			  	 spr(131, 8+cx+bx, cy+by) 
			  	end
			  	if b.hits>2 then
			  	 spr(146, cx+bx, 8+cy+by) 
			  	end
			  	if b.hits>3 then
			  	 spr(147, 8+cx+bx, 8+cy+by) 
			  	end
			  end
			  
			 end
			  
  	end
 		
 	end 		
	end
end

function draw_block(b,x,y)
	local td=tiles[b.tile+1]
	spr(b.basetile+td[1], x,y)
	spr(b.basetile+td[2], x+8,y)
	spr(b.basetile+td[3], x,y+8)
	spr(b.basetile+td[4], x+8,y+8)
	
	if not depth_indicator and b.basetile+td[2]==239 then
  depth_indicator={dy=0,depth=b.y*5+20,y=y+4}
	end
end
-->8
-- helpers

function contains(a,e1)
	for e2 in all(a) do
		if (e1==e2) return true 
	end
	return false
end

function distance(ax,ay,bx,by)
 local dx,dy=ax-bx,ay-by
 return sqrt(dx*dx+dy*dy)
end


function pr_c(str,x,y,c1,c2)
 local w=tlen(str)/2
 pr(str,x-w,y,c1,c2)
 return w
end

function print_s(str,x,y,c1,c2)
 print(str,x,y+1,c2)
 print(str,x,y,c1)
end

-- explode strings into arrays
function explode(s,delim)
 if (not delim) delim=","
 local retval,lastpos={},1
 for i=1,#s do
  if sub(s,i,i)==delim then
   add(retval,sub(s, lastpos, i-1))
   i+=1
   lastpos=i
  end
 end
 add(retval,sub(s,lastpos,#s))
 return retval
end


function explodekv(s)
 local r,a={},explode(s)
 for e in all(a) do
  local kv=explode(e,"=")
  if sub(kv[2],1,1)=="\"" then
   kv[2]=sub(kv[2],2,#kv[2]-1)
  else
   kv[2]=tonum(kv[2])
  end
  
  r[kv[1]]=kv[2]
 end
 return r
end

function explodeval(_arr)
 return toval(explode(_arr))
end

function toval(_arr)
 local _retarr={}
 for _i in all(_arr) do
  add(_retarr,flr(_i+0))
 end
 return _retarr
end


function tsspr(tx,ty,tw,th,dx,dy)
 for x=tx,tx+tw-1 do
  for y=ty,ty+th-1 do
   local c=mget(x,y)
   if c!=9 then
    pset(dx+x-tx,dy+y-ty,mget(x,y))
   end
  end
 end
end


function set_sfx_speed(id, speed)
 poke(0x3200 + 68*id + 65, speed)
end


-->8
-- draw player & respawn


	 -- 0-falling
	 -- 1-on ground - idle
	 -- 2-climbing	
	 -- 3-squashed
	 -- 4-asphyxiated

function draw_pl(px,py)
 pal_reset()
 if pl.air<30 then
 	pal_pal(15,12)
 	pal_pal(9,13)
	end
 if game_state==3 then
		pal_shift(go_fade_steps, dark_pal)  
	end
 
 if pl.state>=3 then
  -- dead
  local st=min(7,(pl.state==3 and 4 or 1)*flr(tick-pl.death_tick))
		if (st<4)	spr(18,px,py+8,2,1)
		spr(0+st>4 and 14 or 0,px,py+2+st,2,1) 
		if st<4 then
			spr(20,px,py+10,2,1) 
 	end 
 	
 elseif pl.state==2 then
		spr(12, px, py, 2, 2, pl.dir==2)
		spr(5,px+(pl.dir==1 and 8 or 0),
		      py+5,
		      1,1,pl.dir==2)
 else 
	 if pl.dir>2 then
		 local dy=py+8
	  if pl.state==0 and pl.drilling==0 then
	   local t2=flr(tick/2)
	   -- falling
			 -- legs
	  	spr(18+66*(t2%2),px,py+6,2,1)
	  	-- head
	  	spr(88+t2%4,px,py)
	  	spr(4,px+8,py)
	  	-- drill
	  	spr(20+66*(t2%2),px,py+8,2,1)
	  	dy=nil
	  else
			 local hy=py + (pl.dir==3 and 2 or 0)
			 if pl.drilling>0 then
			 	dy+=tick%2
			 	if (pl.dir==4) hy+=(tick+1)%2
			 end
			 if pl.dir==3 then
			 	dy-=9
			 end
			 
			 spr(0,px,hy,2,1) 
			 local bt=flr(tick/3)%20
			 if pl.drilling==0 and (bt==15 or bt==17) then
			  -- blink
			  spr(2,px,hy,2,1)
			 end
			 
			 spr(pl.dir==4 and 16 or 18,
			     px,py+8,2,1)
			
				-- drill
			end
			if dy then
			 spr(20,px,dy,2,1,false,pl.dir==3)
		 end
		else
		 -- dir 1&2
			if pl.drilling>0 then
				spr(8, px, py, 2, 1, pl.dir==2)
				spr(30, px, py+8, 2, 1, pl.dir==2)
				-- drill
			 local dx=px+(tick%2)*(pl.dir==1 and -1 or 1)
	 		spr(5,dx+(pl.dir==1 and 0 or 8),
	 		      py+5+tick%2,
	 		      1,1,pl.dir==1)
			else
			 local frame=6
			 if (pl.walking>0) frame+=2*(flr(tick/4)%4)
				spr(frame, px, py, 2, 2, pl.dir==2)
	
	 		spr(20,px+(pl.dir==1 and 1 or -1),py+8,2,1,false,pl.dir==3)
			end
		end
 end

 pal()
 if pl.air<11 and pl.air>0 then
  spr(137,px+1,py-16,1,2)
  spr(137,px+8,py-16,1,2,true)
  if pl.air<6 then
   print(pl.air.."",px+7,py-11,13)
  else
   spr(134,px+4,py-12)
  end
 end 
 
 if pl.beam_count>0 then
  pl.beam_count-=1
  local id=25-pl.beam_count
  local r1=beam_ray[id]
  local r2=beam_ball[id]
  if id==1 then
  	sfx(33,3)
  	-- remove blocks above
  	-- sorry for doing this in draw
  	-- but who cares? :)
  	for x=-1,1 do
  	 for y=0,-50,-1 do
  	  local b=get_block(flr(pl.x+x+0.5),flr(pl.y+y+0.5))
  	  if b then
  	  	remove_block(b)
  	  end
  	 end
  	end
  	-- also check for falling clusters
   for c in all(clusters) do
    if c.state==2 then
     for b in all(c.blocks) do
      if b.x>=flr(pl.x-0.5) and
         b.x<=flr(pl.x+1.5) and
         b.y<=pl.y then
       remove_block(b)
      end
     end
    end
   end
     	
  end
  if r2 then
   if r1>0 then
    screenshake=2
    rectfill(px+8-r1-2,-16,
         px+7+r1+2,py+7,10)
   end
   circfill(px+7,py+7,r2+2,10)
  end
  if r2 then
   if r1>0 then
    rectfill(px+8-r1,-16,
         px+7+r1,py+7,7)
   end
   circfill(px+7,py+7,r2,7)
  end
 end
 
end

 
function respawn()
 if pl.lives>0 then
	 pl.air=101
	 pl.state=1
	 pl.dir=4
	else
	 local dp=flr(pl.y*5)
  if register_result(dp) then
   game_over_str="^new record!"
  else
   game_over_str="^best: "..hiscores[game_mode].." ft"
  end
	 game_state=3
	 gameover_tick=tick
	 menu=menues["gameover"]
	 menu_hint_y=1000
	 menu_slot=1
	 retry=true
	 music(38)
	end
end

function knock_out(new_state)
 if pl.state<3 then
 	sfx(34,3)
		pl.state=new_state
  pl.death_tick=tick
  pl.lives = max(0, pl.lives-1)
		lives_shake=10
		if pl.lives>0 then
		 pl.beam_count=55
  end 
 end
end



function reach_bottom()
 register_result(flr(pl.y*5))
 game_over_str="^congratulations!"
 game_state=4
 gameover_tick=tick
 wipe_blocks_above(pl.y+1, 3)
 menu=menues["gameover"]
 menu_hint_y=1000
 menu_slot=1
 retry=true
 music(40)
end


function register_result(y)
 if y>hiscores[game_mode] then
  hiscores[game_mode]=y
  dset(game_mode,y)
  new_best=true  
  return true
 end
 
 return false
end
-->8
-- lookup
menues={
 title={
  explodekv'txt="^arcade",desc="BITE SIZED CHALLENGES",cmd="menu",menu="arcade",slot=1',
  explodekv'txt="^marathon",desc="DRILL FOREVER",cmd="start",depth=30000,ll=100,bg=6,mode=1',
  explodekv'txt="^credits",desc="WHO DUNNIT?",cmd="menu",menu="credits",slot=5'
 },
 arcade={
  explodekv'txt="^beginner",desc="1000 FT",cmd="start",depth=200,ll=100,bg=1,mode=5,less_air=-1',
  explodekv'txt="^intermediate",desc="2500 FT",cmd="start",depth=500,ll=100,bg=5,mode=3,less_air=0',
  explodekv'txt="^expert",desc="5000 FT",cmd="start",depth=1000,ll=100,bg=4,mode=4,less_air=1',
  explodekv'txt="^back",desc="",cmd="menu",menu="title",slot=1',
 }, 
 credits={
  explodekv'txt="^a ^p^i^c^o-8 demake"',
  explodekv'txt="of the ^n^a^m^c^o classic!"',
  explodekv'txt="^art+^audio: @^johan^vinet"',
  explodekv'txt="^code: @^johan^peitz"',
  explodekv'txt="^back",desc="",cmd="menu",menu="title",slot=3,locked=1',
 },
 gameover={
  explodekv'txt="^retry",desc="PLAY AGAIN!",cmd="start"',
  explodekv'txt="^title",desc="RETURN TO TITLE",cmd="menu",cmd="title"',
 }
}

level_data={
 explodekv'tileset=192,cols=4,x_freq=0.15,max_x=3,air_usage=23,c_freq=6,c_prot=0',
 explodekv'tileset=192,cols=3,x_freq=0.17,max_x=3,air_usage=23,c_freq=8,c_prot=2',
 explodekv'tileset=200,cols=4,x_freq=0.2,max_x=3,air_usage=19,c_freq=10,c_prot=2',
 explodekv'tileset=200,cols=4,x_freq=0.23,max_x=4,air_usage=19,c_freq=10,c_prot=3',
 explodekv'tileset=224,cols=2,x_freq=0.15,max_x=4,air_usage=19,c_freq=10,c_prot=1',
 explodekv'tileset=104,cols=4,x_freq=0.25,max_x=4,air_usage=17,c_freq=12,c_prot=3',
 explodekv'tileset=104,cols=3,x_freq=0.26,max_x=5,air_usage=17,c_freq=14,c_prot=3',
 explodekv'tileset=96,cols=3,x_freq=0.26,max_x=5,air_usage=17,c_freq=14,c_prot=3',
 explodekv'tileset=96,cols=4,x_freq=0.26,max_x=5,air_usage=15,c_freq=16,c_prot=3',
 explodekv'tileset=200,cols=4,x_freq=0.26,max_x=5,air_usage=15,c_freq=16,c_prot=3',
 explodekv'tileset=96,cols=4,x_freq=0.26,max_x=5,air_usage=12,c_freq=18,c_prot=3',
}
  

-- background cols
bg_cols={
 explodeval"0,1,2,3,4",  -- brown
 explodeval"0,1,5,3,13", -- blue/grey
 explodeval"0,1,5,3,4",  -- blue/brown
 explodeval"0,1,2,3,8",  -- red
 explodeval"0,0,1,3,5",  -- dark blue
 explodeval"0,0,1,3,3",  -- dark green
}

-- fade pal
dark_pal=explodeval"0,0,1,5,2,1,13,6,4,4,9,3,13,5,4,4"
light_pal=explodeval"1,5,4,11,9,13,7,7,14,10,7,10,6,6,15,7"
white_pal=explodeval"7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7"

-- parallax speeds
-- higher = slower
p_speeds=explodeval"2,3,4,4,4,4,3,2"

-- parallax tiles
parallax=explodeval"0,1,2,3,4,5,6,7,8,9,10,11,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,14,13,12,10,11,10,9,8,7,31,5,4,3,2,1,0,30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15"

-- cardinal offsets
dirx=explodeval"-1,1,0,0"
diry=explodeval"0,0,-1,1"

-- autotile data
tiles={
 explodeval"0,1,16,17", explodeval"4,5,16,17",
 explodeval"6,1,22,17", explodeval"2,5,22,17",
 explodeval"0,7,16,23", explodeval"4,3,16,23",
 explodeval"6,7,22,23", explodeval"2,3,22,23",
 explodeval"0,1,20,21", explodeval"4,5,20,21",
 explodeval"6,1,18,21", explodeval"2,5,18,21",
 explodeval"0,7,20,19", explodeval"4,3,20,19",
 explodeval"6,7,18,19", explodeval"2,3,18,19",
}

-- palette swaps
block_pals={
 explodeval"12,8,11,9,14,11,12",
 explodeval"13,2, 3,4,4,3,13",
}

beam_ray=explodeval"1,2,7,11,12,12,11,7,7,11,12,12,11,7,2,0,0,0,0,0,0,0,0,0,0"
beam_ball=explodeval"3,7,12,14,15,15,14,13,13,14,15,15,14,13,13,14,15,15,14,12,7,3"




-->8
-- title & menus
ltrs={}
ltrs[3]=explodeval"68,69,70,71,-1,72,73,71,74"
ltrs[4]=explodeval"75,76,77,77,71,75,75"

function draw_logo(y1,y2)
	-- pico
	tsspr(104,0,17,15,13,6+y1)
	tsspr(104,16,24,15,30,6+y1)
	-- dr + iller
	tsspr(0,0,37,29,18,20+y2)
	tsspr(37,0,49,28,62,11+y2)
	-- driller dude
 if game_state<2 then
 	tsspr(86,0,18,31,48,11+y2)
 end
 
 if game_state==2 then
  circfill(55,28+y2,16-title_tick*2,7)
 end
 
end

function update_menu()
 menu_hint_y += (121-menu_hint_y)*0.5

 local m=menu[menu_slot]
 
 if btnp(—) or btnp(Ž) then
  sfx(31,3)
  if m.cmd=="start" then
   game_state=1
   if (m.mode) game_mode=m.mode
   less_air = m.less_air or 0
   clusters={}
   pl=nil
   camy=-128
   bg_col=m.bg or bg_col
   
   -- set mode specific bg colors
	  for i=1,5 do
	   pal_pal(bg_cols[1][i], 
	           bg_cols[bg_col][i]) 
	  end
   bg_pal=pal_get()
   
   transition_tick=title_tick
		 max_depth=m.depth or max_depth
			level_length=m.ll or level_length
			if (m.seed) srand(m.seed)
	 elseif m.cmd=="menu" then
	  menu=menues[m.menu]
	  menu_slot=m.slot
   menu_hint_y=1000
	 elseif m.cmd=="title" then
	  music(-1)
	  start_title(15)
	  return
	 end
 end
 
 if not m.locked then
  if btnp(”) then
   menu_slot-=1
   sfx(30,3)
   menu_hint_y=1000
  elseif btnp(ƒ) then
   menu_slot+=1
   sfx(30,3)
   menu_hint_y=1000
  end
 end
 menu_slot=(menu_slot-1)%#menu+1
 desc_text1=menu[menu_slot].desc
 if menu[menu_slot].mode then
  desc_text2=hiscores[menu[menu_slot].mode].." FT"
 else
  desc_text2=nil
 end 
end


function draw_menu(mt)
	 
 for i=1,#menu do
  local mdesty=51+i*10-#menu*2
  if game_state>=3 then
   mdesty+=20
  end
  
  local my=ease_outquad(mt/10,128+mdesty,-128,1+i)
  local nx
  
  if game_state==0 or game_state>=3 or (i==menu_slot and tick%4>1) then
   nx=pr_c(menu[i].txt,64,my,i==menu_slot and 10 or 7,0)
	 end    
  
  if i==menu_slot and (game_state==0 or game_state>=3) then
   local adj=3.1*sin(wave_sync+time()*bpm)
   palt(9,true)
   palt(0,false)
   spr(83,63-nx-adj-3-10,my-1)
   spr(83,63+nx+adj-3+10,my-1,1,1,true)
   palt(9,false)
   palt(0,true)
  end
 end
 
 if game_state>=3 then
  draw_results(ease_outquad(mt/10,-43,86,2))
 end
 
 palt()
end

function draw_results(y)
 palt(0,false)
 palt(10,true)
 if game_state==3 then
  pal(8,3)
  pal(14,11)
  pal(15,7)
  pal(2,3)
 end
 spr(158,16,y,2,3)
 spr(158,95,y,2,3,true)
 sspr(127,80,1,12,32,y+8,64,12)
 spr(139+game_state,32,y+10)
 spr(139+game_state,89,y+10)
 pal()
 pr_c("^you've reached",64,y,7,1)
 pr_c(flr(pl.y*5).." ft",64,y+11,7)
 if game_state>=3 then
  pr_c(game_over_str,64,y+21,9,1)
 end
end

function draw_waves(y)
 pal_reset()
	local amp=7.2*sin(wave_sync+time()*bpm)
	
	for x=0,127 do
	 local tt=x/125+time()/2
		-- black
	 line(x,y+35+amp*sin(0.56+tt),
	      x,-10,0)
		-- orange
		local aa=amp*sin(0.5+tt)
	 line(x,y+31+aa,
	      x,-9,9)

		-- white
	 line(127-x,-y+106+amp*sin(0.441+tt),
	      127-x,128,7)
		-- red
	 line(127-x,-y+110+aa,
	      127-x,128,8)
	end
	
	if game_state>=3 then
 	local header=ltrs[game_state]
	 for i=1,#header do
	  spr(header[i],
	      57-4*#header+i*8,
	      y+10)
	 end
	end
	
end
-->8
-- easing

-- easing functions by robert penner
-- http://robertpenner.com/easing/

-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

function ease_inquad(t,b,c,d)
 if (t>=d) return b+c
	t=t/d
	return c * (t^2) + b
end

function ease_outquad(t,b,c,d)
 if (t>=d) return b+c
	t=t/d
	return -c * t * (t-2) + b
end

function ease_inquart(t,b,c,d)
 if (t>=d) return b+c
	t=t/d
	return c * (t^4) + b
end

function ease_outbounce(t, b, c, d)
 if (t>=d) return b+c
 t = t / d
 if t < 1 / 2.75 then
  return c * (7.5625 * t * t) + b
 elseif t < 2 / 2.75 then
  t = t - (1.5 / 2.75)
  return c * (7.5625 * t * t + 0.75) + b
 elseif t < 2.5 / 2.75 then
  t = t - (2.25 / 2.75)
  return c * (7.5625 * t * t + 0.9375) + b
 else
  t = t - (2.625 / 2.75)
  return c * (7.5625 * t * t + 0.984375) + b
 end
end


-->8
-- palette manipulation

function pal_reset()
 palette={}
 for i=0,15 do
  palette[i]=i
 end
 pal()
end

function pal_set(p)
 for i=0,15 do
  palette[i]=p[i]
  pal(i,palette[i])
 end
end

function pal_pal(c1,c2)
 palette[c1] = c2
 pal( c1, palette[c1] )
end

function pal_get()
 local p={}
 for i=0,15 do
  p[i]=palette[i]
 end
 
 return p
end


function pal_shift(iterations, ref_pal, scr)
 scr=scr or 0
 for i=0,15 do
  for j=1,iterations do
   palette[i]=ref_pal[palette[i]+1]
  end
  pal(i, palette[i], scr)
 end
end


-->8
-- intro
intro_fade_cols=explodeval"1,1,5,13,6,7,7"
intro_y=30
it=0
function start_intro()
 cls()
 sleep"15"
 fadetext(1,#intro_fade_cols)
 for i=0,1,0.05 do
  local x=min(1,i*3)
  pal()
  rectfill(0,44,127,72,0)
  if flr(i*100)==34 then
   pal(white_pal)
  end
  spr(138,48*x-16*(1-x),44,2,4)
  spr(140,128-64*x,44,2,4)
  flip()
  if (flr(i*100)==24) sfx"26"
 end
 sleep"5"
 spr(132,56,52,2,1)
 sleep"5"
 spr(155,56,52,2,1)
 sleep"45"

 for j=0,5 do
  pal_shift(1,dark_pal,1)
	 flip()
 end
 start_title"0"
end

function fadetext(a,b)
 for i=a,b,sgn(b-a) do
  cls()
  pr_c("made by",64,intro_y,intro_fade_cols[i])
  pr_c("johan & johan",64,intro_y+44,intro_fade_cols[i])
  sleep"2"
  intro_y+=0.5
 end
end

function sleep(ticks)
 for i=1,ticks do
  flip()
 end
end
__gfx__
00000e7e8880000000000e7e88800000888000000000088c00000000000000000000087ee8800000000000000000000000000e7ee88000000000e77ee8880000
0000e222222800000000e222222800002228000000002de200000e7ee880000000008222888800000000087ee88000000000822228880000000e222222228000
00082444494280000008244449428000994280000007c72000008222288800000002444928888000000082228888000000022444928880008282444449942828
0828444497748280082844449ff48280fff4828000cc776000022444928880000024449748ee880000024449288880000082444f748ee800e8844149ff1f488e
0e884419f11788e00e884449ffff88e0f77f88e00dc67d700082444f748ee8000024491178e888000024449748ee880000844491178e88008289111ff111f828
0828711ff11782800828e22ff22e8280f11782808d66d67600844491178e880000221f11782888000024491178e88800008211f117828800228fe1ffff1ef822
0228feffffef82200228feffffef8220f11782208e2566d7008211f1178288000022fffef822220000221f11782888000022efffef8222003328fffeefff8233
00028ffeeff8200000028ffeeff82000eff82000c2005d660022efffef82220000028fef888220000022fffef822220000028ffef88220000000000ee0000000
00002888888200000000000000000000000000000000000000028ffef8822000000028888822000000028fef8882200000002888882200000000288888220000
00000232232000000000000000000000008882d7cd28880000002888882200000000002322200000000028888822000000000032322000000000002322200000
000002b22b20000000022888888220000ce88dccccde88c0000000323220000000000387333300000000002322200000000003b8733300000000038732220000
00000bbbbbb0000000002232232200000022277766622200000003b873330000000003bbb33300000000038733330000000003bbb3330000000003bbbb330000
000003bbbb30000000000333333000000000066dd5500000000003bbb333000000000033bb300000000003bbb3330000000031333330000000000033bb330000
0000013333100000000003bbbb3000000000067766d0000000000033333bb00000000011b7b00000000000333330000000003310033000000000001133300000
000033100133000000033133331330000000006dd5000000000003110007b000000003310bb0000000000001b7b00000000003100b7b000000000331137b3000
000bb330033bb00000bb33100133bb0000000007600000000000333100bb000000003333000000000000001bbbb0000000000000bbbb00000000333303bbb300
11110001444222201224211200000221111111111001111012111111111112222222222221100111112222222244421144444222100000000122244444422212
10000012444222201224111100000221244422222221111010211111111122111111111142000111121111111124211124422221111000000122244444422212
21000122444222201224111100001421124211111112110010011111111021111111111112001111011111111112211114222221122100000122244444422212
44444222444222201224111100014211122111111111000011000000000021111111111112001111011111111112211114222221122110000122244444422212
44442422444222201224111111222111122111111111000111101222222221111111111111122211011111111112211114222221124211001122244444422212
44422212444222201224111100111111122111111111001111114422222222111111111111012421011111111112211114222221112421011122244444422212
44422212444222201224111100111111122111111111001111124111111112211111111111011221011111111112211114222221111222111122244444422212
44422212444222201224111112442221122111111111000111122111111111211111111111011121011111111112211112222221111111111122244444422212
44422220122411110122111012211111111100011112111111111121111111111101112101111111111222110111111111222221124444211122244412111111
44422220122211110122111012211111111100111112111111111111111111111001112100111111110121110111111111222221142244421122244410211111
44422220122211110122111012111111111101211112111111111110111111110001112100011111100011110011111101122211022224421122244410011111
44212210122111110122111011101111111000111112111111111110000000000011112100000000000010011001111001111111022224421122244410000000
42111110111101100122111011000111110001111112111111111110000000000111112110000000000111001000000000111111022224421122244411001222
21111100111000000111110010000000000011111212111111111110000011111111112101222100001121101000000000000111022224421122224411114422
11111000110000000100000010000000000111112412111111111110001111111111112102112200011122111100000000000111022224421012112411124111
01110000111000000110000111000000001111112110211111111100001111111111112101111200111112211210000002244422022224421001111211122111
aaaaaaa0000000aa000000000404000007777770077777700770077007777770077777600770077007777770077777700770077007777770f799f799fff79999
00000a017777710a0000000040044000778888667788886678867886778888867788886678867886788888867788888678867886778888669944994499994444
0777001700000710000000004404000078e6688678e6688678e8888678e6666678e6688678e6788678e6688678e8666678e6788678e668869944994499994444
0777d07000000070002e882040004000788676667886788678866886788886607886788678867886788888607688866078867886788666609944994499944444
0777d070000000700284448200000000788688867888888678867886788666707886788678866886788668860668886678867886788667709944994499944444
0777d070000000700e44417e000000007886788678866886788678867886777678867886068888607886788677668886788668867886788621119944999f9444
077710c0000000c00871f17800000000768888667886788678867886768888867688886600688600788678867888886676888866768888662211994499994444
0ccc10c0000000c0028fff8200000000066666600666666006600660066666600666666000066000066006600666666006666660066666602222994499994444
0ccc001c00000c10000000006d99999900000000000000000000000000000000000044420000444200000444000004440ee00fe0000f0000fff79999f7994444
00000a01ccccc10a000000007679999900000000000000000ce882d7cd2e88c0000044420000244400002444000044420efefef00effee009999444499444444
aaaaaaa0000000aa0000000076769999000228888882200000888dccccd88800000824440008244400082444000824440eefefe002eee2009999444499444444
aaaaaaaaaaaaaaaa067776dd7d7d799900002232232200000002277766622000082849ff082849ff082849ff082849ff0efefef000e2e0009999444499444444
aaaaaaaaaaaaaaaa0d66dd556d65099900000333333000000000066dd55000000e88f77f0e88f77f0e88f77f0e88f77f0e2fe220002020009999444499444444
aaaaaaaaaaaaaaaa007776d0d5d09999000003bbbb3000000000067766d000000828711f0828711f0828711f0828711f02022000000000009999444421114444
aaaaaaaaaaaaaaaa0006d500d509999900bb31333313bb000000006dd50000000228711f0228711f0228711f0228711f00000000000000009999444422114444
aaaaaaaaaaaaaaaa00007000009999990003331001333000000000076000000000028ffe00028ffe00028ffe00028ffe00000000000000009999444422224444
00cccccc7777fe000dcccccc777777e00dcccccc777777e00dcccccc777777f000000cccccd00000000dccccccfe4000000dccccccfe400000000cccccd00000
0c77cccc77777fe0dccccccc7777777edccccccc777777e4dccccccc7777777f000ccccccccf4000000cccccccff4000000cccccccff4000000ccccccccf4000
c777cccc777777e4cc7ccccc77777777cc7ccccc777777e4cc7ccccc7777777700ccccccccccf40000cccccccccff40000cccccccccff40000ccccccccccf400
c77ccccc777777e4cccccccc77777777cccccccc777777e4cccccccc777777770cc777ccccccfe40ecc777ccccccffee0cc77cccccccfe40ecc77cccccccffee
cccccccc777777e4cccccccc77777777cccccccc777777e4cccccccc777777770c77777ccccccfe0cc77777ccccccffc0c7777ccccccffe0cc7777cccccccffc
ccccccddff7777e4ccccccddff777777ccccccddff7777e4ccccccddff777777cc77777ccccccff4cc77777ccccccccccc7777cccccccff4cc7777cccccccccc
cccccdddfff777e4cccccdddfff77777cccccdddfff777e4cccccdddfff77777cc77777ccffccf74cc77777ccffcccccccc77ccccffccf74ccc77ccccffccccc
cccccddccff777e4cccccddccff77777cccccddccff777e4cccccddccff77777ccc777ccffffcf74ccc777ccffffccccccccccccffffcf74ccccccccffffcccc
77777ffcc77cccdd77777ffcc77ccccc77777ffcc77cccdd77777ffcc77cccccccccccccffffcf74ccccccccffffccccccccccccffffcf74ccccccccffffcccc
77777fff777cccdd77777fff777ccccc77777fff777cccdd77777fff777ccccccccccccccffcf7f4cccccccccffccccccccccccccffcf7f4cccccccccffccccc
777777ff77ccccdd777777ff77cccccc777777ff77ccccdd777777ff77ccccccccccccfcccccf7e4ccccccfccccccfffccccccccccccf7e4ccccccfccccccfff
77777777ccccccdd77777777cccccccc77777777ccccccdd77777777cccccccc0ccccccccccf7f40fcccccccccccffee0ccccccccccc7f40fcccccccccccffee
77777777ccccccdd77777777cccccccc77777777ccccccdd77777777cccccccc0dccccccccf7fe404dcccccccccf7e440dccccfccccf7e404dccccccccff7e44
f7777777cccccfdd77777777cccccccc77777777ccccccdd77777777cccccccc00ddccccffffe40000dccccccccfe40000dcccccccc7e40000ddccccfff7e400
0e777777cccccdd0e7777777cccccccd77777777ccccccdde7777777cccccccd000ddfffffe44000000dccccccff4000000dccccccff4000000ddfffffe44000
00444444dddddd000e777777ccccccd007777777ccccccd004444444ddddddd00000044444400000000dccccccfe4000000dccccccfe40000000044444400000
0eeeeeeeeeeeeee00eeeee4fee4feee0fffff1100055ffff00000e8000000000000000000000000000000000000000000000000000000000a777766aaaaaaaaa
e7ffeeeeeeeeef44e7ffe27eee27ef44fffffe10005dffff000087880000000000e88000000000000000000000000000000000000000000060066006aaafaaaa
ef41111111111444ef41112111221444f111111000dfffff000712e8000000000e78880000d777770000015dd100000000000505555100006aa66aa6a9f799aa
ef12222222222e42ef12224221422e421eeee1f000111111007cf15000000000082788800d766666000115d11d1100000000515d5111100007700660a09990aa
ee12114444114e22ee1211e444112222f1ffe14e00d1eeef077cef00000000771222e8800766666600115d112ee110000001515511111100a067760aaa909aaa
ee12122441224e22421112244122ef12f2111d4e00f1fff107cef00000000777e1222250076666660115d12efffe110000515ee511111110aa7777aaaa0a0aaa
ee124222122e4e22f7224222122e4e417feffde000ff111400ff000000007c77f1122500076666660151d2eeffffe1000015effffee21100aa0000aaaaaaaaaa
ee12442222e44e22ee12442222e44e2452eef50000efffff000000000007ccc77e110000076666660111deefff7ff1000015f7fffffee110aaaaaaaaaaaaaaaa
ee12441222444e22ee12441222444e22007ccccc007cccc6007ccccc007cc6cc7fee0000076666660115deeffffff1100055ffffffffee10feeeeeeeeaaaaaaa
ee12412222244e224e12412222144e2207c77cc707c77ccc07c777cc07c77cccceef000007666666015deefffffffe10005dffffffffee50e88888888efaaaaa
ee12122e42224e22f211122e422122117c777ccc7c7777cc7c777ccc7c777cc7ee700000076666660011111ff111111000dfd5dffffd52500e88888888efaaaa
ee1212e444224e22e72412e444224e44fc77c6cefc77cccefc77ccc6fc77ccceef0000000d7666660e1e74f11e74f1f000111111fe111110a0e8888888efaaaa
ee12444444444f22ee12414444244f22fcc6cceefccccceefccccceefccccceef000000000d77766421eff1ef1ffe14e00d1f47f11f47e10aa0e88888ef2aaaa
ee4eeeeeeeeef742ee4ee2fe2fe2f742ffccceefffccceefffccceefffc6ceef000000000000007642d1112ef2111d4e00f1fff1fe1fee10aaa0e888e722aaaa
e422222222222422e4221422212144220ffeeef00ffeeef00ff6eef00ffeeef0000000000000000704defeef7feffde000ff1114fe411140aaaae888f722aaaa
0222222222222220022214222214222000ffff0000ffff0000ffff0000ffff000000000000000000001eee2552eef50000efffff7fefee40aaaf8888ffe2aaaa
000000000000000000000000000000000000000000000000000000000000000000000000000000000004f2dddd5fe000000ffffe442eee00aaf88888fefeeeee
0000000cc00000000c000002200000c000000000000dcd000000000d02000cd0000000000000002000014167771e50000004feffffeee400af888888fee88888
0000000770000000007c000dd000c700000ccc2c020c7cd000cc20002d200d2000cd000000000000000115eeeed510000000fffeee44e000e8888888fee88888
000c00c77c00c00000c7cc2dd2c77c0000c77cd02c2dcc2000c7d0000200000000d20000000000000000115ffd5500000000efff444e400000000000fee88888
0000ccc77ccc0000000c777cc777700000c77c200200d220002d20000000000000000000000000000000215ffd5f00000000f4ffffe40000aaaaaaaafee88888
0000cc7777cc0000000c77777777c00000cccd2ccc200000000000dcd0000000000000cd000000000000221555efe000000aff4effe20000aaaaaaaafee88888
000cc777777cc0000002777777772000002d22c77cc2000000d000c7c0000000000000d200000000000822224eff8e0000a9fff422229000aaaaaaaafee88888
0c777777777777c002ddc777777cdd20000c00c77cc20d00000000dcd220002000000000000000000082224efff8880000999fffe2224900aaaaaaaafee88888
0c777777777777c002ddc777777cdd200c0000ccccc20020200000002d200000000000000d200000002244efff888800009999fffe444400aaaaaaaa0ee88888
000cc777777cc0000002777777772000000000dcccd202d2000000002220000d000000000220000000222efff88880000009999fffe44400aaaaaaaa0ee88888
0000cc7777cc0000000c77777777c00000dcc00dd22000200000000000000000000000000000000000022888888800000000999999944000aaaaaaaaa0e88888
0000ccc77ccc00000007777cc777700000c7cd00000d22000000000000000000000000000000000000008888880000000000009999990000aaaaaaaaaa000000
000c00c77c00c00000c77c2dd2c77c0000ccc200c0dcd20000cd000000000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaa
0000000770000000007c000dd000c700000d2200002d220000d20000d000cd00002000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaa
0000000cc00000000c000002200000c00000000d00222000000000000000d200000000000000020000000000000000000000000000000000aaaaaaaaaaaaaaaa
0000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000aaaaaaaaaaaaaaaa
00cccccccccccd000cccccccccccccc00cccccccccccccc00cccccccccccccd000cccccdfffffe000ccccccddf7777f00ccccccddf7777400ccccccdfffffed0
0c77ccccccccccd0cc7ccccccccccccccc7ccccccccccccdcc7ccccccccccccc0c77ccdf77777fe0ccccccdf7777777ecc7cccdf777777edcc7cccdf777777ff
c777cccccccccccdcccccccccccccccccccccccccccccccdccccccccccccccccc777cdf7777777edcccccdf77777777ccccccdf7777777edcccccdf77777777c
c77ccccccccccccdcccccccccccccccccccccccccccccccdccccccccccccccccc77ccd7777777cddcccccd7777777ccccccccd7777777cddcccccd7777777ccc
cccccccccccccccdcccccccccccccccccccccccccccccccdccccccccccccccccccccdf77777cccddccccdf77777cccccccccdf77777cccddccccdf77777ccccc
cccccccccccccccdcccccccccccccccccccccccccccccccdccccccccccccccccccccd77777ccccddccccd77777ccccccccccd77777ccccddccccd77777cccccc
cccccccccccccccdcccccccccccccccccccccccccccccccdcccccccccccccccccccdf7777cccccddcccdf7777ccccccccccdf7777cccccddcccdf7777ccccccc
cccccccccccccccdcccccccccccccccccccccccccccccccdcccccccccccccccccddf77777cccccddcddf77777ccccccccddf77777cccccddcddf77777ccccccc
c7cccccdcccccccdc7cccccdccccccccc7cccccdcccccccdc7cccccdccccccccdf777777ccccccd4df777777cccccccddf777777ccccccd4df777777cccccccd
c77ccccdc7cccccdc77ccccdc7ccccccc77ccccdc7cccccdc77ccccdc7ccccccf7777777ccccccd477777777ccccccdff7777777ccccccd477777777ccccccdf
fc77ccdfc77ccccdfc77ccdfc77ccccdfc77ccdfc77ccccdcc77ccdfc77ccccdf777777ccccccde47777777ccccccdf7f777777ccccccde47777777ccccccdf7
ffcccdf7fc77ccd47fcccdf7fc77ccdfffcccdf7fc77ccd4fccccdf7fc77ccdff7777ccccccccde477777ccccccccd77f7777ccccccccde477777ccccccccd77
f7feef777fccdde477feef777fccddf7f7feef777fccdde47feeef777fccddf7f77cccccccccdfe4777cccccccccdf77f77cccccccccdfe4777cccccccccdf77
4777777777feefe47777777777feef77f777777777feefe47777777777feef774fccccccccccdfe477ccccccccccd777f7ccccccccccd7e477ccccccccccd777
0e77777777777e40f7777777777777eef7777777777777e4f77777777777777e0dcccccccccdfe40fccccccccccdf7eefccccccccccdf7e4cccccccccccdf77f
00444444444444000fcccccffccccf400fcccccffccccfe0044444444444444000dddddddd4444000ccccccccddf77400ccccccccddf77e00ddddddddd444440
00777777f7777d0007ccccccdeff7cd007ccccccdeff7cd007777777f77777d00bbb77777bbb7750b333bbbbb333bbbb7333bbbbb333bb357bbb77777bbb7777
07ccccccc777cdd07cccccccc777cccd7cccccccc777ccdd7cccccccc777cccdb33bbbbb3333bb35333bbbbb3333bbbbb33bbbbb3333bb35333bbbbb3333bbbb
7cddccccccccccddccddcccccccccccc7cddccccccccccddccddccccccccccccb33bbbb333333b32333bbbb333333bb3b33bbbb333333b32333bbbb333333bb3
7dee7ccccccccdedcdee7ccccccccdfc7dee7ccccccccdedcdee7ccccccccdfcb333bb333bb333523333bb333bb33333b333bb333bb333523333bb333bb33333
7def7ccdddcccfedcdef7ccdddcccf7c7def7ccdddcccfedcdef7ccdddcccf7c7b333333bbbb3352bb333333bbbb33337b333333bbbb3352bb333333bbbb3333
7c77ccdeeefcccddcc77ccdeeefccccc7c77ccdeeefcccddcc77ccdeeefccccc7bb3333bbbbb3355bbb3333bbbbb333b7bb3333bbbbb3355bbb3333bbbbb333b
7ccccdeefff7ccddcccccdeefff7cccc7ccccdeefff7ccddcccccdeefff7cccc7bb333bbbbb33335bbb333bbbbb333bb7bb333bbbbb33335bbb333bbbbb333bb
fccccdeffff7ccdddccccdeffff7cccdfccccdeffff7ccdddccccdeffff7cccd7b333bbbbb333b35bb333bbbbb333bbb7b333bbbbb333b35bb333bbbbb333bbb
77cccdeffff7ccd4e7cccdeffff7ccde77cccdeffff7ccd4e7cccdeffff7ccde7333bbbbb333bb35b333bbbbb333bbbb7333bbbbb333bb35b333bbbbb333bbbb
77ccccffff7cccd4f7ccccffff7cccde77ccccffff7cccd4f7ccccffff7cccdeb33bbbbb333bbb35333bbbbb333bbbbbb33bbbbb333bbb35333bbbbb333bbbbb
fcccccc777ccccde7cccccc777ccccc7fcccccc777ccccde7cccccc777ccccc7b3bbbbb333bbbb3233bbbbb333bbbbb3b3bbbbb333bbbb3233bbbbb333bbbbb3
7ccddcccccccccddcccddccccccccccc7ccddcccccccccddcccddcccccccccccbbbbbb3333bbbb523bbbbb3333bbbb33bbbbbb3333bbbb523bbbbb3333bbbb33
7cdee7ccccccccddccdee7cccccccccc7cdee7ccccccccddccdee7cccccccccc7bbbb333333bb352bbbbb333333bb3337bbbb333333bb352bbbbb333333bb333
dcdef7cccdddccddccdef7cccdddccccdcdef7cccdddccddccdef7cccdddccccbbbb333bb3333352bbbb333bb333333b7bbb333bb3333355bbbb333bb333333b
0dc77cccdeee7dd0dcc77cccdeee7ccddcc77cccdeee7ccddcc77cccdeee7ccd3335553333555522bbb333bbbb3333bb7bb333bbbb3333353335553333555533
00ddddddd444ed000dccccccdeef7cd00dccccccdeef7cd00dddddddd444edd00522255555222220bb333bbbbb333bbb7b333bbbbb333b355522255555222555
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0907070707070707070707070707070909090909070707070707070707070707070909090909090909090909090909090909090909090707070707070707070707070707090909090909090909090909090909090909090909090907070707070709090909090909090909070707070707070707070707070709090909090909
0707070707070707070707070707070707090907070707070707070707070707070709090909090909090909090909090909090909070707070707070707070707070707070d0607070707070707070707070909090909090909070e080808080e07090909090909090907020202020202020e07020202020709090909090909
0707060e0e0e080808080808080e0e0707070906070e0e08080808080808080e07070709090909090909090909090909090909090907070e0e0808080808080808080e07070d0d06070707070707070707070709090909090907080808080808080807090909090909070e020202020202020207020202020709090909090909
07070e07070e0e0808080808080808080707070d060e070e08080808080808080e070709090909090909090909090707070707070707070e070e08080808080808080807070d0d0e08080808080808080e07070709090907070808040404040f040808070709090907020202020e070202020207020202020709090909090909
07070e07070e0e080808080808080808080707070d080e0e08080808080808080807070009090909090909090907070707070707070706080e0e08080808080808080807070d02070e08080808080808080e07070909070e0808040404040f07070408080e070909070202020207070202020207020202020709090909090909
07070e0e0e0e08080808080808080808080807070602080808080808080808080807070000090909090909090907070e0e08080e07070d02080808080808080808080e06070d020e0e08080808080808080807070009070808080404010f0f010107080808070909070202020202020202020207020202020709090909090909
0707080e0e0808080606060e0808080808080e07070208080808060e080808080807070000090707070707070707070e070e080807070d02080808080606060606060606060d02080808080808080808080807070000070808080701010f0f010107080808070d0d070202020202020202020e07020202020709090909090909
0707080808080808060606060e08080808080e07070202080808060708080808080707000007070707070707070706080e0e080807070d020808080807070707070706060d0d0208080808060e080808080807070000070e08080f0e0f0f0f0f0e0f08080e070d0d07020202020e060606060607020202020709090909090909
0707080808080808060606060e08080808080807070202080808060e08080808080607000007070e0e08080e07070d020808080807070d0208080808080808080e0707000d0d0808080808060708080808080707000009070708080f0f0e0e0f0f08080707060909070202020206000000000007020202020709090909090909
07070808080808080606000706080808080808070702020808080808080808080e0606000007070e070e080807070d020808080807070d020808080808080808080707000d060808080808060e08080808080607000009070e0e0e0808080808080e0e0e07060909070202020206000000000007020202020709090909090909
070708080808080806060007070808080808080707020208080808080808080e06060000000707080e0e080807070d020808080807070d0208080808080808080e0607000d0708080808080808080808080e06060000070c0e08080c0c0c0c0c0c0e08080c070209070202020206000000000007020202020709090909090909
07070808080808080606000707080808080808070702020808080e08080808080e060700000707080808080807070d020808080807070d020808080806060606060607070606080808080808080808080e0606000000070c080808060c0c0c0c060808080c070209060606060606000009090906060606060609090909090909
0707080808080808060600070708080808080807070202080808060e0808080808070700000707080808080807070d020808080807070d02080808080707070707070707070d08080808080e08080808080e060700000e070707070c060c0c0c0c07070707060202090900000000000009090909090000000009090909090909
070708080808080806060007070808080808080707020208080806060808080808070700090707080808080807070d020808080807070d02080808080808080808080e07070d0208080808060e08080808080707000009090907060c070c0c0c0c06070d0d0d0202090900000000000009090909090000000009090909090909
070708080808080806060007070808080808080707020208080806070808080808070700000707080808080807070d020808080807070d02080808080808080808080807070d0208080808060608080808080707000909090e070c07060c0c0c0c0c07060d0d0209090900000000000009090909090000000009090909090909
070708080808080806060007070808080808080707020208080806070808080808070700000707080808080807070d02080808080707070707070e080808080808080807070d02080808080607080808080807070000090907060c060c0c0c0c0c0c06070d0d0909090909090909090909090909090909090909090909090909
070708080808080806060007070808080808080707020208080e06070e0808080e060700000707080808080807070d020808080807070707070707020808080808080e06070d02080808080607080808080807070000090e070c0c0c0c0c0c0c0c0c0c07060d0909090907070707070707070909090707070707070707090909
0707080808080808060607070e08080808080807070d0d06060606060606060606060600000707080808080807070d0208080808080808080e07070d0d06060606060606060d020808080e06070e0808080e060700000907060c0c0607070707060c0c06070d02090907020202020202020e070907020202020202020e070909
0707080808080808060607070e08080808080e07060d0d0606060606060606060606000000070708080808080707070707070e08080808080807070d0d060606060606060d0d0d0606060606060606060606060600000e070c060707070606070707060d07060209070e020202020202020207070e0202020202020202070909
07070808080808080607070e0808080808080e060600000000000000000000000000000000070708080808080707070707070702080808080e0607000000000000000000000d06060606060606060606060606000000070706070706060707070706060d07060202020202020e070202020207020202020e0702020202070009
0707080808080808080808080808080808080606000000000000000000000000000000000007070808080808080808080e07070d0d060606060606000000000000000000000000000000000000000000000000000000070706070607070707060606060d06060202020202020707020202020702020202070702020202070000
0707080808080808080808080808080808060606000000000000000000000000000000000907070808080808080808080807070d0d0606060606000000000000000000000000000000000000000000000000000000000e07070607070706060706060d06060d0202020202020707070707070702020202070702020202070000
0707080808080808080808080808080806060600000000090909090909090909090909090907070e08080808080808080e06070000000000000000000009090909090909090909000000000000000000000000000009090e0707060706070706060d06060d0d0209020202020707070707070702020202070702020202070000
07070e080808080808080808080e0e060606000000000909090909090909090909090909090706060606060606060606060606000000000000000000000909090909090909090909090909090909090909090909090909090d070706070706060d0606000d0d0609020202020707020202020702020202070702020202070000
07060606060606060606060606060606060000000000090909090909090909090909090909090606060606060606060606060000000000000000000009090909090909090909090909090909090909090909090909090909090d07070606060d060600000006060902020202070e020202020702020202070e02020202070000
0906060606060606060606060606060000000000000909090909090909090909090909090909090000000000000000000000000000090909090909090909090909090909090909090909090909090909090909090909090909090d07070d0d06060000000000090902020202020202020e06070202020202020202020e070000
09090000000000000000000000000000000000000909090909090909090909090909090909090900000000000000000000000000000909090909090909090909090909090909090909090909090909090909090909090909090909090606060600000000000909090e020202020202020600060e020202020202020206000000
0909000000000000000000000000000000000009090909090909090909090909090909090909090900000000000000000000000009090909090909090909090909090909090909090909090909090909090909090909090909090909090606000000000009090909060606060606060600000006060606060606060600000000
0909090000000000000000000000000000090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090900000000000909090909000000000000000000000000000000000000000000000000
0909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909000000090909090909000000000000000000000009000000000000000000000009
0909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090009090909090909000000000000000000000909090000000000000000000909
0909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909
__sfx__
000900001f56500700007001e5051f565000001f5051e5051f5652150523565215052150520505215650270502700027002156500505345052050521565005052156500505005051f50520565335053450500505
010900001f56500700007001e5051f565000001f5051e5051f565215052356521505215052050521565215000270002700057030e602057030f6001d703005051d703005001a7031f5001a703335001570300505
000900001c565000001f5051e5051c565000001f5051e5051c565215051f5652150521505205051d5652050500505205051d5650050534505205051d565005051d56500505005051f5051d565335053450500505
010900001c565000001f5051e5051c565000001f5051e5051c565215051f5652150521505205051d5651d50500505205051d5050050034505205051d505005050500006000070000800013000100010e0010c001
000900000c0500c0400c0400c0350c0000c0000c0250c005070500704007040070350e0000e0000e0000e0000e0500e0400e0400e03510000100000a0430e000070500704007040070350a043000000000000000
000900000c0500c0400c0400c0350c0000c0000c0250c005070500704007040070350e0000e0000e0000e0000e0500e0400e0400e03510000100000a0430e000090500904009040090350a043000000000000000
00090000100501004010040100350c0000c000100250c0050b0500b0400b0400b0350e0000e0000e0000e0001105011040110401103510000100000a0430e0001105011040100410f0410e0310d0310c0210c001
00090000100501004010040100350c0000c000100250c0050b0500b0400b0400b0350e0000e0000e0000e0000e0500e0400e0400e03510000100000a0430e0000d0500d0400d0400d0350a043000000d0250d000
000900001c7301c7151f7001e7001c7201c7151f5051e5051c7301c7111c7211c73521700207001d7401d7351d705205051d505005003450520505000050000007010070110702108021090210b0210c0310c001
000900001c7301c7151f7001e7001c7201c7151f7001e7001c7301c7111c7211c73521700207001d7401d7351d705207001d7401d72534700207001d7301d7151d7201d7111d7111d71520700337003470000700
000900001c7301c7151f7001e7001c7201c7151f7001e7001c7301c7111c7211c73521700207001d7401d7351d705207001d7001d70534700207001d7001d7051d7001d7011d7011d70520700337003470000700
00090000236352360000614006003f015000050a033000053f0150000523635236000a0330000523605236053f0153f005236000060023635006003f0150a005226002260023635006003f0150a0050060000005
00090000236002360023600006003f000000000a000000053f0000000023600236000a0000000523605236050a0333f00523655186350d61500600326650a00512615226000a03300600236550a0050662500005
00090000231072310723107001073f107001070a107001073f1070010723107231070a10700107381073810738107361042a5242b53538407381072b530381042b5302b5202b5222b5122b515371003710035100
01090000230072300723007000073f007000070a007000073f0070000723007230070a0070000738007380073800736004190141a02538007380071a010380041a0201a0201a0121a0121a015370003700035000
01090000050500504005040050350c0000c000050250c0050c0500c0400c0400c0350e0000e0000c0200c000110501104011040110351000010000110430e0000c0500c0400c0400c0350a043000000000000000
0009000004050040400404004035150000c000040250c0050b0500b0400b0400b0350e0000e0000b0200c000030500304003040030351000010000110430e0000a0500a0400a0400a0350a043110001103011020
000900000e0500e0400e0400e0350c0000c0000e0050c0050700007000070000700511050110401104011030070500704007040070351000010000110430e0000e0500e0400e0400e03507050070400704007035
00090000000500004000040000350c0000c000000250c005020500204002040020350e0000e000020200c000030500304003040030351000010000110430e0000405004040040400403511043000000402003000
01090000007040070400704387002d7502d7302d725307042b750297142974029700287300e704297502973229725037042874028720287151070426740267302672504704267302871128740007042975003704
01090000287502b704247402472024715217051f7401f7321f725027041f74024711247400e7042674029705277502671126750287002574010704247402472024715047041f7302471124740217042675003704
0109000028750007042474024730247252d7052175021732217250270421730247112474024704267502970527750037042474024730247251070420740207222071504704287202b7112b730007042d74003704
0109000026750267402673226725267002d705247402472024715237042473026711267402670028750287352770403704267302871128740107042975026705287302971129740047042b750007042474024745
01090000007040070400704387002d7502d7402d735307042b750307113074002704287300e704297502970028750287402873228725287051070426750267402673504704267402871128750007042975003704
01090000307503074030735267053075030750307452470024705237043373034711347402670030750307503074230732307323072030710307103071526705287040470429704047042b704007042470424705
010300000f03322061210502101529005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000167703a7512e1603a0652e1403a0402e1203a0202e1103a015040001e0000000002000000000900000000040000900004000000000000005000040000000006000000000200000000000000000000000
01030000197142462126630016701b3732d3631d4632e4531e3532e3431a4432a43316333253230f3231e31313313060030600307003000030000300003000030000300003000030000300003000030000300003
0102000023633246432665336773367513f2313f1213f1113f1113f1013f1013f1053f10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000f0232e0312d0202d015190001b0001e7001d7001b00500000000000000000000000000000000000000000000000000000000000000000100002200021000217002e7000000000000000000000000000
000300002157421770217550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000015574217702d7502d745000002d7302d7252d7002d7102d7152d7002d7002d70500300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000957111571115611d5311c5111c5051c5001e5000953111531115211d5111c5150a07107071070710d0611d0311c0111c005115000a02107031070210d0211d0110a0240702107011070110750500000
00020000104730b4630845307443084430c45313761187611e77123771237711e761187511e751237612877128771237611e75123751287612d7712d7712876123751287412d73132721327212d7112871123711
000200003306032071300712d0612a051260412403123025011140124301373013630136301353012530124301343013330133301323013230131301313011050f1030e1030c1030b1030a1030a1030010300103
0002000033060310712e0712a0612705126041270312a0312c0412c0512a0512805124041200311d0211c0211d0211f02120031200311f0411d0411a041170411403112031011440124301333013330132301315
000700200a033006000a614006003f015000050a0330000523635000053f015236000a0330000523605236053f0153f00523635035000a033006003f0150a005236350a6000a615006003f0150a5050a6150a503
000e00001877017701000002c7002d7702d73500000000002b7702b7312976500000287650000029770297350000029700287602873500000007052676026735000000a705267702673128765000002976500000
000e00002877500000247602472500000007051f7601f725000000070524770247250000021705227712276022762227522275222742227422274222732227322273222722227222272222712227122271500000
000e000028765000002b7702b72500000007052476024725000000070528770287250000025705267712676026762267522675226742267422674226732267322673226722267222672226712267122671500000
000e0000001300011500100001000010000100001200c1300c1150010000100001000010000100021200013000115001000c13000120041300411510130001200513005115111300012006130061150012002130
000e00000913009115091300911507130091300a120161300a1151610016130161153f100001000c1300a1200a11500100091300a130001300c135001300c1301113011115131301310007130051300013002130
000e00000512405130051300513005130051300513005130051300512005120051200511005110051150510004124041300413004120041250f10510131101301013010120101201011504134041300412004115
000e000002130021150e1300213002130021200212002120021100211002110021150413002120001200212004130041251013010115051300512511130111150713007125131301311500130001250c1300c115
000e0000071300711502100071300610002130071300712006101021300d1300e135021200211000120021200c1300013510100001250c13000135111000c1100e1350e1300c1350c110001350b1050c1450c115
000e00002d7402d7152f7402f7102f7152f70030750307102f7012c7002d7512d7402b7302b70029740007002b7400070028740287202871500700247502472024715007001f7441f72021740217252475024715
000e00002974029715287402872028715007002975029720297152d70024740247402d7512d7152b7402b7402b7402b7402b7302b7302b7322b7322b7222b7222b7222b7122b7102b71521700247102b7202c730
000e00002d7402d7152f7402f7102f7152f70030750307102f7012c7002d7512d7402f7302b70030750337003475134730327500070030750007003275032740327323272030750307152b7502b7303075000700
000e000035740347503471530740307122b74035750347500070030740307122b74032750327003374133750337303371535740357503374033715327503270030750307302b7403170132750327153074030710
000e00002b7402b7302d7503670030740307103474000700357503474024700307502d7002d7403274032730327303272030750307503074030740307303072030710007001f7002470021700217002b7302c740
000e0000071300711502100071300610002130071300712006101021000e1300e1250713007125081310813008130081250313003125081300812509130091200a1350a13007101091000b1450b1050b1450c155
001c00001c5341c5301c5301c5301c5321c5321c5321c5221b5311b5301b5301b5301b5321b5321b5321b5221a5311a5301a5301a5301a5321a5321a5321a5221953119530195301953019532195321953219525
001c000018534185301853018530185221852218522185121a5311a5301a5301a5301a5221a5221a5221a51218531185301853018530185221852218522185121753117530175301753017522175221752217515
001c00000b5340b5300b5300b5300b5220b5220b5220b5120b5310b5300b5300b5300b5220b5220b5220b5120b5310b5300b5300b5300b5220b5220b5220b5120953109530095300953009522095220952209515
011c00000953409530095300953009522095220952209512095310953009530095300952209522095220951207531075300753007530075220752207522075120753107530075300753007522075220752207515
001c00001f7751f7151f7751f7151f75023775237152177521715217752171521775217552171520775207151f7751f7151f7551f7151f7502377523715217702173521755217452173521725217150070000700
001c00001f7751f7151f7751f7151f75023775237152177521715217752171521775217552171520775207151f7751f7151f7751f7151e7651e7751e7101f7701f7301f7551f7451f7351f7251f7150070000700
000e00200a033006000a614006003f015000050a0330000523635000053f015236000a0330000523605236053f0153f00523635035000a033006003f0150a005236350a6000a615006003f0150a5050a6150a503
0010000024560245151f5402454026550265152b5502b51529560285502654026515285602851524540245151f5601f5501f5501f5401f5421f5321f5321f5321f5321f5321f5321f5321f5211f5151f5501f515
001000001c0501c015180301c0301f0401f0152404024015240401f0351f0301f01524040240151f0301f015180001f0001f0001f000240502405024040240252405224052240412402523040230152305023025
000800200a0630a0003f000236003e6250563500625026253e645000053f000236000a063000053f000236053c6250563500625026253e645006003f0150a0053d6651e63531625296353d6151e6253163529645
001000000c1440c1151840009400071440711524400004000c1440c1151f4000740007144071151f400244000c1440c1410c1310c1310c1210c1210c1110c1152905029050290422902528040280152605026015
001000000c1440c1151840009400071440711524400004000c1440c1151f4000740007144071151f400244000e1440e1410e1310e1310e1210e1210e1110e1152605026050260522604226035260002600026000
001000001c0501c015180301c0301f0401f0152404024015240501f0451f0401f01524050240151f0301f015180001f0001f0001f000240502405024040240252305023050230422304223031230152103023040
__music__
00 00 09 43 44
00 01 0a 0d 0e
01 00 02 09 44
00 01 03 08 0c
01 00 02 04 0b
00 01 03 04 0b
00 00 02 05 0b
00 01 03 06 0b
00 00 02 05 0b
00 01 03 07 0b
00 00 02 05 0b
00 01 03 06 0b
00 00 02 05 0b
00 01 03 07 0b
00 13 0f 0b 44
00 14 10 0b 44
00 15 11 0b 44
00 16 12 0b 44
00 17 0f 0b 44
00 14 10 0b 44
00 15 11 0b 44
02 18 04 0b 08
01 25 28 24 44
00 26 28 24 44
00 25 28 24 44
00 27 29 24 44
00 25 28 24 44
00 26 28 24 44
00 25 28 24 44
00 27 29 24 44
00 2d 2a 24 44
00 2e 2b 24 44
00 2f 2a 24 44
00 31 2c 24 44
00 2d 2a 24 44
00 2e 2b 24 44
00 2f 2a 24 44
02 30 32 24 44
01 33 35 37 39
02 34 36 38 39
01 3a 3b 3d 3c
02 3a 3f 3e 3c
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
