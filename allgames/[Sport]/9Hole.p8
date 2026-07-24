pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- giga golf  v0.1
-- by palo blanco games
-- rocco panella

function init_menu()
	-- use this to initialise
	-- the main menu
end

function init_level(level)
	-- pass an antry from the level
	-- list to start the level
	menu_mode = false
	clock = back_key[level_current]
	if (hard_mode) clock += 3
	t = 0 -- timer
	a = {} -- actor list
	b = {} -- thing list
	lev = 1 -- swing strength
	face = 1 -- hero's direction
	clubs = {} -- club list
	cx = 0 -- camerax
	cy = 0 -- cameray
	control_ball = false -- flag for ball or hero
	ball_in = false -- is the ball in the hole?
	hero_in = false -- hero at flag?
	hero_dead = false -- hero got killed
	lose_ball = false
	lose_life = false
	draw_lose = false
	button_push = false -- used for buttons
	button_count = 0 -- track how many buttons are in the level
	fset(62,2)
	--hard mode spikes
	hard_mask = 0
	if (hard_mode) hard_mask=10
	fset(107,hard_mask)
	fset(108,hard_mask)
	fset(123,hard_mask)
	fset(124,hard_mask)
	end_timer = 0
	cam_timer = 0
	tm = {} -- map array, may not get used yet
	crawl_map(level[2],level[3],level[4],level[5])
	par = level[1]
	par_old = par
	music(12)
	menuitem(1,'restart hole',function() init_level(level) lives+=-1  end)
	--menuitem(2,'next hole',function() next_level()  end)
end

function next_level()
	-- use to cheat
	level_current += 1
	init_level(ll[level_current])
end

function hard_start()
	ll = {}
	ll[0] = {0,0,0,0,0,'9hole v0.1',''}
	ll[1] = {2,16,16,0,0,"hmm, this looks a",'little tough today...'}
	ll[2] = {2,32,16,0,16,'i wasted my good shots','on the driving range!'}
	ll[3] = {3,32,16,32,0,"be quiet!! i'm trying",'to tee off here!'}
	ll[4] = {3,16,16,16,0,'when was the last time',"they cut this grass??"}
	ll[5] = {6,16,32,64,0,'how could anyone be in',"a bad mood out here?"}
	ll[6] = {4,32,16,32,16,"have they ever golfed","before? so slow!"}
	ll[7] = {6,48,16,80,0,"relax, buddy! we're","moving!"}
	ll[8] = {7,64,16,0,32,"that's it,i'm out","of good shots"}
	ll[9] = {8,48,32,80,16,"i'm done. i'll watch","this one."}
	ll[10] = {8,16,32,64,32,"whew. done. never","golfing again."}
	ll[11] = {0,0,0,0,0,'wow! thanks!'}
end

function _init()
	music(19)
	t = 0
	score = 0
	ycount = 0
	yshake = 0
	ymove = 0
	spspd = 0.75 -- spike speed in hard mode
	hard_mode = false -- use for back 9
	clock = 0 -- use for time of day for scenery
	back_info = {}
	back_info[0] = {12,10,16,0} -- sky color, sun color, sun offset, back offset
	back_info[1] = {9,7,80,16} -- sky color, sun color, sun offset, back offset
	back_info[2] = {1,6,16,32} -- sky color, sun color, sun offset, back offset
	back_info[3] = {0,8,16,32} -- sky color, sun color, sun offset, back offset
	back_info[4] = {15,7,80,16} -- sky color, sun color, sun offset, back offset
	back_info[5] = {13,6,16,0} -- sky color, sun color, sun offset, back offset
	--level information
	ll = {}
	ll[0] = {0,0,0,0,0,'9hole v0.1',''}
	ll[1] = {9,16,16,0,0,'beautiful day for golf!',' '}
	ll[2] = {4,32,16,0,16,'isnt this just great?',''}
	ll[3] = {4,32,16,32,0,'this is just the best,','i mean, really'}
	ll[4] = {4,16,16,16,0,'you can take a mulligan,',"we're just having fun"}
	ll[5] = {7,16,32,64,0,'how could anyone be in',"a bad mood out here?"}
	ll[6] = {5,32,16,32,16,"we don't even need to","keep score"}
	ll[7] = {7,48,16,80,0,'this sure beats the',"office!"}
	ll[8] = {8,64,16,0,32,'just drop a ball here,',"i won't tell"}
	ll[9] = {9,48,32,80,16,"last one! leave it all","out here!"}
	ll[10] = {9,16,32,64,32,"we did it! bonus","hole time!"}
	ll[11] = {0,0,0,0,0,'thanks! that was great.'}
	
	back_key = {}
	back_key[0] = 0
	back_key[1] = 0
	back_key[2] = 0
	back_key[3] = 0
	back_key[4] = 1
	back_key[5] = 1
	back_key[6] = 1
	back_key[7] = 2
	back_key[8] = 2
	back_key[9] = 2
	back_key[10] = 2
	back_key[11] = 0
	
	level_current = 0
	level_total = 10
	
	par = ll[level_current][0]
	-- key used to reformat grass
	tmap = {}
	tmap[0] = 16
	tmap[1000] = 32
	tmap[1100] = 40
	tmap[1110] = 45
	tmap[1111] = 44
	tmap[1101] = 46
	tmap[1010] = 33
	tmap[1001] = 34
	tmap[1011] = 35
 tmap[0100] = 36
 tmap[0110] = 37
 tmap[0101] = 38
 tmap[0111] = 39
 tmap[0010] = 41
 tmap[0001] = 42
 tmap[0011] = 43   	       
	
	--playing state or menu
	menu_mode = false --menus
	menu_start = true -- title screen
	menu_end = false -- end screen
	
	--freeze frame
 freeze = false	
 
 --player info
 lives = 5
 coins = 0
 strokes = 0
	lose_ball = false
	lose_life = false
	draw_lose = false
 	
end


function crawl_map(xmax,ymax,x0,y0)
	--use this to crawl the map
 for x = x0,xmax+x0 do
		for y = y0,ymax+y0 do
			val = mget(x,y)
			if (val == 1) then
			-- do a crawl to get the hero
			-- first thing
				make_actor(x*8,y*8,val)
				--mset(x,y,0)
			end			
		end
	end
	-- do a second crawl for everything else
	for x = x0,xmax+x0 do
		for y = y0,ymax+y0 do
			val = mget(x,y)
			if (val == 17) then
			-- golf ball
				make_actor(x*8,y*8,val)
				a[#a].ms = 5 -- increase top speed
				a[#a].f = a[#a].ac*0.1
				a[#a].bounce = true
				a[#a].grav = 0.05
				--mset(x,y,0)
			elseif (val == 21) then
			--flag
				make_thing(x*8,y*8,val,-1)
			--fix grass tiling
			elseif (val == 16) then
			 tnew = 0
			 if (not fget(mget(x,y-1),1)) tnew += 1000
				if (not fget(mget(x,y+1),1)) tnew += 100
				if (not fget(mget(x-1,y),1)) tnew += 10
				if (not fget(mget(x+1,y),1)) tnew += 1
				mset(x,y,tmap[tnew])
			--turtles
			elseif val == 26 then
				make_thing(x*8,y*8,val,-1) 
				b[#b].sx = 0.3
			--bubbles
			elseif val == 23 then
				make_thing(x*8,y*8,val,-1) 
				b[#b].timer = flr(rnd(230))
			--fireball
			elseif val == 56 then
				make_thing(x*8,y*8,val,-1) 
				b[#b].timer = flr(rnd(230))
			-- range balls
			elseif val == 11 then
				make_thing(x*8,y*8,val,-1) 
			-- ball regenerator
			elseif val == 47 then
				make_thing(x*8,y*8,val,-1)
			--buttons
			elseif val == 14 then
				make_thing(x*8,y*8,val,-1)
				button_count += 1 
				if (fget(mget(x,y-1),1)) b[#b].flipy = true
				if fget(mget(x-1,y),1) then
					b[#b].pic = 30 
					b[#b].flipx = true
				end
				if (fget(mget(x+1,y),1)) b[#b].pic = 30 
			--end
			--hard mode additions
			elseif hard_mode then
				-- moving spikes
				-- up
				if val == 105 then
					make_thing(x*8,y*8,val,-1) 
					b[#b].sy = -spspd
				end 
				-- down
				if val == 121 then
					make_thing(x*8,y*8,val,-1) 
					b[#b].sy = spspd
				end
				-- left
				if val == 106 then
					make_thing(x*8,y*8,val,-1) 
					b[#b].sx = -spspd
				end
				-- right
				if val == 122 then
					make_thing(x*8,y*8,val,-1) 
					b[#b].sx = spspd
				end
				--turtle
				if val == 55 then
					make_thing(x*8,y*8,26,-1) 
					b[#b].sx = 0.3
				end 
			end			
		end
	end
end

function make_thing(x,y,kind,life)
	local thing={}
	thing.x = x
	thing.y = y
	thing.x0 = x
	thing.y0 = y
	thing.sx = 0
	thing.sy = 0
	thing.grav = 0
	thing.kind = kind
	thing.pic = kind
	thing.flipx = false
	thing.flipy = false
	thing.wi = 6
	thing.hi = 6
	--kill flag
	thing.die = false
	thing.timer = 0
	thing.life = life
	thing.collide = 0
	thing.freezeme = false
	thing.drawme = true
	-- for extra variables
	thing.extra = 0
	add(b,thing)
end

function process_turtle(h)
	if h.sx >= 0 then
		if get_collide(h.x+7,h.y+4) then
			snap(h,0) 
			h.sx = -0.3
		elseif not get_collide(h.x+7,h.y+10) then
			snap(h,0) 
			h.sx = -0.3
		end
	else
		if get_collide(h.x,h.y+4) then
			snap(h,1) 
			h.sx = 0.3
		elseif not get_collide(h.x,h.y+10) then
			snap(h,1) 
			h.sx = 0.3
		end
	end
	if (t % 10 == 1) h.flipx = not h.flipx		
end

function process_things()
 -- generic handler for things
 for h in all(b) do
 	kk = h.kind
 	hm = fget(kk)
 	if not h.freezeme then
 		-- special item codes
	 	if h.kind == 18 then
	 		process_club(h)
	 	elseif h.kind == 9 then
	 		process_stream(h)
	 	elseif h.kind == 26 then
	 		process_turtle(h) 
	 	end
	 	if (h.timer > h.life and h.life != -1) then h.die = true end
	 	if h.die then
	 		del(b,h)
	 	else
	 		h.timer += 1
	 		h.sy += h.grav
	 		h.x += h.sx
	 		h.y += h.sy
	 	end
	 	-- special thing behavior
	 	-- confetti 
	 	if h.kind == 8 then
	 		if (h.timer % 3 == 1) h.flipx = not h.flipx
	 	end
	 	-- bubbles
	 	if h.kind == 23 or h.kind == 47 or h.kind == 56 then
	 		if (h.timer % 240 == 239) h.drawme = true
	 		if (h.timer % 15 == 1) h.flipx = not h.flipx
	 	end
	 	-- coins
	 	if h.kind ==11 then
	 		if (h.timer % 16 == 1) h.flipx = not h.flipx
	 		if (h.timer % 16 == 8) h.flipy = not h.flipy
	 	end
	 	--moving spikes
	 	if kk == 105 or kk == 106 or kk == 121 or kk == 122 then
	 		if h.sx > 0 then
					if get_collide(h.x+7,h.y+4) then
						snap(h,0) 
						h.sx = -spspd
					end
				elseif h.sx < 0 then
					if get_collide(h.x,h.y+4) then
						snap(h,1) 
						h.sx = spspd
					end
				elseif h.sy > 0 then
					if get_collide(h.x+4,h.y+7) then
						snap(h,2) 
						h.sy = -spspd
					end
				elseif h.sy < 0 then
					if get_collide(h.x+4,h.y) then
						snap(h,3) 
						h.sy = spspd
					end
				end
	 	end 
		end
	end
end


function process_club(h)
	-- add extra behavior
	-- for processing a club
	xoff = 3
	if (h.flipx) then xoff = -3 end
	if h.timer == 6 then
		h.flipy = true
		h.y += -2
		make_thing(h.x + xoff,h.y,20,2)
		b[#b].flipx = h.flipx
	elseif h.timer == 9 then
		make_thing(h.x + xoff,h.y,19,2)
		b[#b].flipx = h.flipx
	elseif h.timer > 12 then
		h.die = true
		--h.myclub = 0
	end
end	

function process_stream(h)
 if (h.timer % h.extra.freq) == 0 then
 	make_confetti(h,h.extra.speed,h.extra.direct,h.extra.grav,h.extra.std,h.extra.life,h.extra.pic)
 end
end

function make_stream(h,speed,direct,grav,std,life,pic,timer,freq)
	make_thing(h.x,h.y,9,timer*1.5)
	b[#b].drawme = false
	local stream = {}
	stream.speed = speed
	stream.direct = direct
	stream.grav = grav
	stream.std = std
 stream.life = life*1.5
 stream.pic = pic
 stream.freq = freq
	--add(b[#b],stream)
	b[#b].extra = stream
end

function make_confetti(h,speed,direct,grav,std,life,pic)
	make_thing(h.x,h.y,8,life)
	direct = direct + rnd(std)-0.5*std
	b[#b].sx = speed*cos(direct)
	b[#b].sy = speed*sin(direct)
	b[#b].grav = grav
	if (pic == 8) then
 	roll = flr(rnd(3))
 	if (roll == 1) pic = 7
 	if (roll == 2) pic = 58  
 end
	b[#b].pic = pic
end

function bubble_recharge()
	for h in all(b) do
		if (h.kind == 23) h.drawme = true
	end
end

function make_actor(x,y,kind)
	local actor={}
	actor.x = x
	actor.y = y
	actor.x0 = x
	actor.y0 = y
	actor.sx = 0
	actor.sy = 0
	actor.kind = kind
	actor.ms = 0.8
	actor.grav = 0.1
	actor.j = 1.5
	actor.ac = 0.2
	actor.f = actor.ac*0.5
	actor.fm = 1
	actor.pic = kind
	actor.g = false
	actor.r = false
	actor.flipy = false
	actor.wi = 6
	actor.hi = 6
	actor.animate = 2
	actor.animatetime = 0
	-- wall touching and hanging vars
	actor.lw = false
	actor.rw = false
	actor.uw = false
	actor.dw = false
	actor.hang = false
	--golf swing
	actor.charge = false
	actor.swing = false
	actor.swt = 0
	actor.lev = 0
	--kill flag
	actor.die = false
	actor.freezeme = false
	actor.drawme = true
	actor.myclub = 0
	actor.vibx = 0
	actor.viby = 0
	actor.killed = 0
	--ball flags
	actor.bounce = false
	actor.collide = 0
	actor.confetti_timer = 0
	add(a,actor)
end

function get_collide(x,y)
 -- receives x and y pixels 
 -- returns bit 1, solid flag
 xx = flr(x / 8)
 yy = flr(y / 8)
 local ind = mget(xx,yy)
 local val = fget(ind,1)
 return val
end

function get_collide_all(x,y)
 -- receives x and y pixels 
 -- returns bit 1, solid flag
	local col ={}
 xx = flr(x / 8)
 yy = flr(y / 8)
 col.ind = mget(xx,yy)
 col.val0 = fget(col.ind,0)
 col.val1 = fget(col.ind,1)
 col.val2 = fget(col.ind,2)
 col.val3 = fget(col.ind,3)
 col.val4 = fget(col.ind,4)
 return col
end

function collide_objects(h,t)
	-- pass two actors or things
	-- to check for collision
	-- returns true or false
	-- everything has 8x8 box
	boxw = 8
	boxh = 8
	-- adjustments for specific objects
	-- golf flag
	if (t.kind == 21) boxw = 4 
	if fget(t.kind,7) then
		boxw = 4
		boxh = 4
	end
	
	-- end adjustments

	if h.x < t.x + boxw and h.x > t.x - boxw then
		if h.y < t.y + boxh and h.y > t.y - boxh then
			return true
		else 
			return false
		end
	else
		return false
	end
end

function collide_actors(h)
	-- returns a list of all objects
	-- that h has collided with
	hitlist = {}
	for t in all(a) do
	 other = -1
	 cc = collide_objects(h,t)
	 if cc and t.drawme then 
 	 collision = true
 	 other = t
		end
		if (other != -1) add(hitlist,t)
	end
	for t in all(b) do
	 other = -1
	 cc = collide_objects(h,t)
	 if cc and t.drawme then 
 	 collision = true
 	 other = t
		end
		if (other != -1) add(hitlist,t)
	end
	return hitlist
end

function collision_thing(h,kind)
 -- check a and b lists for
 -- a collision of h (self)
 -- with actor or thing of kind
 collision = false
 other = -1
 for t in all(a) do
 	if t.kind == kind then
 		cc = collide_objects(h,t)
 		if cc and t.drawme then 
 		 collision = true
 		 other = t
 		end
 	end
 end
 for t in all(b) do
 	if t.kind == kind then
 		cc = collide_objects(h,t)
 		if cc and t.drawme then 
 		 collision = true
 		 other = t
 		end
 	end
 end
 return other
end

function snap (h,d)
 -- receives an actor and 
 -- the direction to be snapped
 -- 0123 is lrud
 if d == 0 then
 	h.x = flr(h.x / 8)*8 + (0.5*(8-h.wi))
 	h.rw = true
	elseif d == 1 then
		h.x = flr(h.x / 8)*8 + 8 - (0.5*(8-h.wi)) 
		h.lw = true
	elseif d == 2 then
		h.y = flr(h.y / 8)*8
		h.dw = true
	elseif d == 3 then
		h.y = flr(h.y / 8)*8 + 8 - (8-h.hi)
		h.uw = true
	end
end

function hangme(h,f)
	--makes actor hang
	--f is direction, false right
	h.hang = true
	h.g = false
	h.r = f
	h.sy = 0
	h.y = flr((h.y+4)/8)*8
end

function move_actor(h)
	--call this after ai or
	--button presses for physics
	-- returns killme
	
	
	--reset side collisions
	h.dw = false
	h.uw = false
	h.lw = false
	h.rw = false
	
	--adjust horizontal speed
	h.fm = 1
	if (abs(h.sx)>h.ms) h.fm = 2
	if (h.bounce and h.g) h.fm = 2
	h.sx += -sgn(h.sx)*h.f*h.fm
	if (abs(h.sx) <= h.f*h.fm) h.sx = 0
	if not h.hang then
		h.x += h.sx
	else
		h.sx = 0
	end
	
	--collide with walls and snap
	killme = false --check spikes
	-- x first
	if h.sx >= 0 then
		y1 = h.y + 2
		y2 = h.y + 7
		x1 = h.x + 7
		c1 = get_collide_all(x1,y1)
		c2 = get_collide_all(x1,y2)
		killme = killme or c1.val3 or c2.val3
		if (c1.val1) or (c2.val1) then
		 snap(h,0)
		 -- check for bouncing and sand
		 if (h.bounce and ((not c1.val2) or (not c2.val2))) then
		 	h.sx = -h.sx
		 	if h.sx != 0 then
		 		sfx(17)
		 		make_stream(h,2,0.25,0.15,0.2,10,94,3,1)
		 	end
		 else
		 	h.sx = 0
		 	y3 = h.y - 1
		 	c3 = get_collide(x1,y3)
		 	if (h.bounce) sfx(18)
		 	if (not c3 and c1.val1 and h.sy > 0 and not h.bounce) then
		 		hangme(h,false)
		 	end
		 end
		end
	end
	if h.sx <= 0 then
		y1 = h.y + 2
		y2 = h.y + 7
		x1 = h.x
		c1 = get_collide_all(x1,y1)
		c2 = get_collide_all(x1,y2)
		killme = killme or c1.val3 or c2.val3
		if (c1.val1) or (c2.val1) then
		 snap(h,1)
		 -- check for bouncing and sand
		 if (h.bounce and ((not c1.val2) or (not c2.val2))) then
		 	h.sx = -h.sx
		 	if h.sx != 0 then
		 		sfx(17)
		 		make_stream(h,2,0.25,0.15,0.2,10,94,3,1)
		 	end
		 else
		 	h.sx = 0
		  y3 = h.y - 1
		  if (h.bounce) sfx(18)
		 	c3 = get_collide(x1,y3)
		 	if (not c3 and c1.val1 and h.sy > 0 and not h.bounce) then
		 		hangme(h,true)
		 	end
		 end
		end		
	end
	
	--adjust vertical speed
	if not h.hang then
		h.sy += h.grav
		h.y += h.sy
		--dont disable jumping 
		--for 4 frames
		if (h.sy > 8*h.grav) h.g = false  
	end
	
	--y collisions next
	if h.sy >= 0 then
		x1 = h.x + 1
		x2 = h.x + 6
		y1 = h.y + 8
		c1 = get_collide_all(x1,y1)
		c2 = get_collide_all(x2,y1)
		killme = killme or c1.val3 or c2.val3
		if (c1.val1) or (c2.val1) then
		 snap(h,2)
		 --check for spring
		 if (c1.val4 or c2.val4) then
		 	sfx(16)
		 	if (not h.bounce) h.sy = -2*h.j
		 	if h.bounce then 
		 	 
		 		h.sy = -2
		 		if control_ball then
		 			if (btn(0)) h.sx = -1
		 			if (btn(1)) h.sx = 1
		 		end
		 	end
		 --check for bouncing and sand
		 elseif (h.bounce and h.sy > 1 and ((not c1.val2) or (not c2.val2))) then
		 	sfx(17)
		 	h.sy = -h.sy*0.5
		 	make_stream(h,2,0.25,0.15,0.2,10,94,3,1)
		 else
		 	h.sy = 0
		 	h.g = true
		 	--sfx(18)
		 end
		end
	elseif h.sy < 0 then
		x1 = h.x + 1
		x2 = h.x + 6
		y1 = h.y + 1
		c1 = get_collide_all(x1,y1)
		c2 = get_collide_all(x2,y1)
		killme = killme or c1.val3 or c2.val3
		if (c1.val1) or (c2.val1) then
		 snap(h,3)
		 if h.bounce then
		  h.sy = -h.sy * 0.5
		  sfx(17)
		  make_stream(h,2,0.25,0.15,0.2,10,94,3,1)
		 else
		 	h.sy = 0
		 --h.g = true
		 end
		end
	end
	
	return killme
	
	
end

function teleport_ball(x,y)
	for h in all(a) do
		if h.kind == 17 and not ball_in then
			h.sx = 0
			h.sy = 0
			h.x = x
			h.y = y
		end
	end
end

	
function move_hero(h)
	-- button inputs
	--l and r movement
	if not control_ball then
		if (btn(0)) h.sx += -h.ac	
		if (btnp(0) and not h.hang) h.r = true
		if (btn(1)) h.sx += h.ac
		if (btnp(1) and not h.hang) h.r = false
	end
	-- toggle global face value
	if (h.r) face = -1
	if (not h.r) face = 1

	if not control_ball then
	--drop from a hang
		if (btnp(3) and h.hang) then
			h.hang = false
			if (h.r) h.x += 1
			if (not h.r) h.x += -1
		end
	
		-- jumping
		if (btnp(4) and h.g) then
			h.g = false
			h.sy = -h.j
			sfx(14)
		elseif (btnp(4) and h.hang) then
			h.hang = false
			h.sy = -0.9*h.j
			sfx(15)
		elseif (not btn(4) and not h.g) then
			h.sy = max(-0.5,h.sy)
		end
		
		--club swinging
 	if not h.hang then
 		if (btnp(5) and not h.charge and h.myclub <= 0 ) then
 			h.charge = true
 			--h.swt += 1
 		end
 	end
 end
 --charge behavior
 if h.charge then
 	make_thing(h.x+h.vibx,h.y+h.viby-2,6,1)
 	b[#b].flipy = true
 	b[#b].flipx = not h.r
 	h.sx = 0
 	if ((h.swt < 15 or btn(5)) and h.swt <= 60 ) then
 		h.swt += 1
 		lev=1
 		if (h.swt >= 20 and h.swt < 40) then
 			lev = 2
 			if (h.swt % 4 == 1) h.viby = 1-h.viby
 		elseif (h.swt >= 40 and h.swt < 45) then
 			lev = 3
 			if (h.swt % 2 == 1) h.viby = 1-h.viby
 		elseif (h.swt >= 45) then
 			lev = 3
 			if (h.swt % 2 == 1) h.viby = 1-h.viby
 		end
 	if (h.swt == 1) sfx(1,2)
 	if (h.swt == 20) sfx(29,2)
 	if (h.swt == 45) sfx(28,2)
 	elseif ((not btn(5)) or (h.swt >= 45)) then
 		h.swt = 0
 		h.viby = 0
 		make_thing(h.x,h.y,18,12)
 		sfx(18,2)
 		h.myclub = #b
 		h.charge = false
 		if h.r == false then 
 			b[h.myclub].sx = 0.6
 			b[h.myclub].flipx = false
 		else 
 			b[h.myclub].sx = -0.6 
 			b[h.myclub].flipx = true
 		end
 		h.myclub = 15 -- temporary
 	end
 end
 
 --club call
 if h.myclub > 0 then
 	if h.myclub % 3 == 1 then
 		h.viby = 1 - h.viby
 	end
 	h.sx = 0
 	h.sy = 0
 	h.myclub += -1
 elseif not h.charge then
 	h.viby = 0
 end
 	--b[h.myclub].sx = 1.0
 	--b[h.myclub].timer += 1
 	--if b[h.myclub].timer == 6 then
 		--b[h.myclub].flipy = true
 		--b[h.myclub].y += -2
 		--make_thing(b[h.myclub].x,b[h.myclub].y,20,2)
 		--b[#b].flipx = b[h.myclub].flipx
 	--elseif b[h.myclub].timer == 9 then
 		--make_thing(b[h.myclub].x,b[h.myclub].y,19,2)
 		--b[#b].flipx = b[h.myclub].flipx
 	--elseif b[h.myclub].timer > 12 then
 		--b[h.myclub].die = true
 		--h.myclub = 0
 	--end
 --end		
 		
	-- corrections of status
	--if (h.pic > 3) h.pic = 0
	
	--collision stuff
	
	----trying to replace collision code 
	----with more efficient algorithm
	hitlist = collide_actors(h)
	for other in all(hitlist) do
	 kk = other.kind
	 --flag
	 if kk == 21 then
	 	if ball_in then
	 		hero_in = true
				h.freezeme = true
				make_stream(h,2,0.25,0.05,0.25,90,8,120,2)
				music(-1)
				sfx(23,1)
				sfx(24,2)
	 	end
	 end
	 --turtles
	 if kk == 26 then
	 	if h.y < other.y - 2 then
		 	sfx(25)
		 	make_stream(other,2,0.25,0.15,0.2,10,94,3,1)
				h.sy = -h.j
				if (other.flipy) h.sy = -1.5*h.j
			elseif not other.flipy then
				hero_die(h)
			end
	 end	
	 --fireball and moving spikes
	 if kk == 56 or kk == 105 or kk == 106 or kk == 121 or kk == 122 then
	 	hero_die(h)
			sfx(20)
			make_stream(other,2,0,0.0,1,3,95,5,1)
	 end
	 --bubbles
	 if kk == 23 then
	 	if other.drawme then
				h.sy = -1.5*h.j
				other.drawme = false
				other.timer = 0
				sfx(19)
				make_stream(other,2,0,0.0,1,3,109,5,1)
			end
	 end
	 --regen
	 if kk == 47 then
	 	if other.drawme then
				teleport_ball(other.x,other.y-8)
				make_stream(other,1.6,0,0.0,3,10,7,5,1)
				other.drawme = false
				other.timer = 0
				sfx(31)
			end
	 end
	 --coins
	 if kk == 11 then
	 	if other.drawme then
				--h.sy = -1.5*h.j
				other.drawme = false
				coins += 1
				sfx(6)
				make_stream(other,2,0.25,0.15,0.2,15,110,3,1)
			end
	 end
	 --buttons
	 if kk == 14 then
	 	button_count += -1
			other.pic += 1
			other.kind += 1
			sfx(21)
			if button_count <= 0 then
			 button_push = true
			 fset(62,0)
			end
	 end
	end
	--end new collisions
	
	if (par <= 0 and (not control_ball) and not ball_in) hero_die(h)
	
	killme = move_actor(h)
	
	if (killme) hero_die(h)
	
	--animate
	if h.charge then
		h.pic = 3
	elseif h.myclub > 0 then
		h.pic = 2 
	elseif not h.g then
	 h.pic = 5
	 if (h.sy < 0) h.pic = 4
	 if (h.hang) h.pic = 4
	--end
	elseif h.g then
	 if h.sx == 0 then 
	 	h.pic = 0
	 	h.animatetime = 0
	 else
	 	h.animatetime += abs(h.sx)
	 	if h.animatetime >= h.animate then
	 		h.pic += 1
	 		if (h.pic > 3) h.pic = 0
	 		h.animatetime = 0
	 	end
	 end
	end
	if hero_dead then
		h.y += -2
		h.pic = 5
		h.flipy = true 
	end	 
end

function hero_die(h)
	hero_dead = true
	h.freezeme = true
	lose_life = true
	music(-1)
 sfx(27)	
	lives += -1
end

function ball_die(h)
	--h.x = h.x0
	--h.y = h.y0
	--if a[#a].r then
	--sfx(-1,3)
	sfx(26,0)
	cam_timer = 50
	for hh in all(a) do
		if hh.kind == 1 then
			h.x = hh.x
			h.y = hh.y
		end 
	end
	
	control_ball = false
	h.sy = -0.3
	h.sx = 0
end

function move_ball(h)
	-- button inputs
	--l and r movement
	x_drag = 0.1
	if (abs(h.sx) < 0.2 and not h.g) x_drag = 0.2
	y_drag = 0.1
	if control_ball then
		spark = (t % 5 == 1)
		if btn(0) then
		 h.sx += -h.ac*x_drag
		 if (spark) then
		  make_stream(h,2,0,0.0,0.15,3,93,1,2)
		  h.vibx = 1 - h.vibx
		  sfx(30)
		 end
		end
		if (btnp(0) and not h.hang) h.r = true
		if btn(1) then 
		 h.sx += h.ac*x_drag
		 if (spark) then
		  make_stream(h,2,0.5,0.0,0.15,3,93,1,2)
		  h.vibx = 1 - h.vibx
		  sfx(30)
		 end
		end
		if (btnp(1) and not h.hang) h.r = false
		if btn(2) then
		 h.sy += -h.ac*y_drag
		 if (spark) then
		  make_stream(h,2,0.75,0.0,0.15,3,93,1,2)
		  h.viby = 1 - h.viby
		  sfx(30)
		 end
		end
		if btn(3) then
		 h.sy += h.ac*y_drag
		 if (spark) then
		  make_stream(h,2,0.25,0.0,0.15,3,93,1,2)
		  h.viby = 1 - h.viby
		  sfx(30)
		 end
		end
		--sounds
		--if (btnp(0) or btnp(1) or btnp(2) or btnp(3)) sfx(30,3)
		--if (not (btn(0) or btn(1) or btn(2) or btn(3))) sfx(-1,3)
 end
 
 if (not control_ball) then 
 	--sfx(-1,3)
 	h.vibx = 0
 	h.viby = 0
 end
 
	-- check collisions
	-- club first
	
	----trying to replace collision code 
	----with more efficient algorithm
	hitlist = collide_actors(h)
	for other in all(hitlist) do
	 kk = other.kind
		--club
		if kk == 18 and h.collide <= 0 then
			h.sx = (1+((lev-1)/2))*sgn(face)
			h.sy = -1*(1+((lev-1)/2))
			control_ball = true
			strokes += 1
			par += -1
			lose_ball = true
			cam_timer = 60
			h.collide = 100
			sfx(5)
			make_stream(h,1.5,0,0.0,1,6,109,5,1)
		elseif h.collide > 0 then
			h.collide += -1
		end
		--turtle
		if kk == 26 then
			if (abs(h.sy) > 0.5 or abs(h.sx) > 0.5) then
				other.flipy = true
				other.sx = 0
				h.sy = -2
				if (btn(0)) h.sx = -1
				if (btn(1)) h.sx = 1
				sfx(25)
				make_stream(other,2,0.25,0.15,0.2,10,94,3,1)
			end
		end
		
		--bubbles
		if kk == 23 then
			if other.drawme then
				h.sy = -1.5
				other.drawme = false
				other.timer = 0
				if (btn(0)) h.sx = -1
				if (btn(1)) h.sx = 1
				sfx(19)
				make_stream(other,2,0,0.0,1,3,109,5,1)
			end
		end
		
		--fireball
		if kk == 56 then
			if other.drawme then
				h.sy = -1.5
				other.drawme = false
				other.timer = 200
				other.kind = 23
				other.pic = 23 
				if (btn(0)) h.sx = -1
				if (btn(1)) h.sx = 1
				sfx(20)
				make_stream(other,2,0,0.0,1,3,95,5,1)
			end
		end
		
		--coins
		if kk == 11 then
			if other.drawme then
			--	h.sy = -1.5*h.j
				other.drawme = false
				coins += 1
				sfx(6)
				make_stream(other,2,0.25,0.15,0.2,15,110,3,1)
			end
		end
		
		--hard mode fire
		if kk == 105 or kk == 106 or kk == 121 or kk == 122 then
			ball_die(h)
			make_stream(other,2,0,0.0,1,3,95,5,1)		
		end
		--buttons
		
		if kk == 14 then
			button_count += -1
			other.pic += 1
			other.kind += 1
			if button_count <= 0 then
	 		button_push = true
	 		fset(62,0)
	 		sfx(21)
	 	end
	 end

		--hole
		if kk == 21 then
			ball_in = true
			h.freezeme = true
			--sfx(-1,3)
			sfx(22,0)
			h.drawme = false
			control_ball = false
			cam_timer = 100
			--par += -1
			--lose_ball = true
			other.pic = 22
			make_stream(other,1.6,0.25,0.03,0.15,60,8,60,5)
		end
	end
		
			

	killme = move_actor(h)
	
	if (killme) ball_die(h)
	
	-- fix grounded state
	if (h.sy != 0) h.g = false
	
	--check if stopped moving
	if control_ball then
		if  h.sx == 0 and h.sy == 0 then
			h.swt += 1
		else
			h.swt = 0
		end
		if h.swt >= 30 or btnp(4) then
			control_ball = false
			--par += -1
			--lose_ball = true
			cam_timer = 60
			h.swt = 0
		end
	end
	--animate		 
end

-- add for web compatibility
function _update()_update60()_update_buttons()_update60()end


function _update60()
 t += 1
  
 if menu_start then
 	if btnp(4) or btnp(5) then
 		if (hard_mode) hard_start()
 		menu_start = false
 		menu_mode = true
 	end
 	-- hard mode toggler
 	if btnp(2) or btnp(3) then
			if ycount < 4 then
				ycount += 1
				yshake += 1
				sfx(20)
			elseif (not hard_mode) then
				hard_mode = true
				clock = 1
				sfx(22)
				ycount += 1
			else
				hard_mode = false
				clock = 0
				sfx(6)				
				ycount +=1
			end
		end
 elseif menu_end then
 	if btnp(4) or btnp(5) then
 		menu_end = false
 		run() --restart the game
 	end
 elseif menu_mode then
 	if btnp(4) or btnp(5) then
 		level_current += 1
 		init_level(ll[level_current])
 	end
 
 elseif hero_in then
 	end_timer += 1
 	if end_timer >= 120 then
			if level_current < level_total then
				menu_mode = true
				music(19)
			else
				menu_end = true
			end
 	end
	--end
	
	elseif hero_dead then
 	end_timer += 1
 	if (end_timer % 5 == 1) a[1].drawme = not a[1].drawme
 	if end_timer >= 110 then
			--if lives >= 0 then
			init_level(ll[level_current])
 		
 	end
	end
	--else
	 --move_hero(a[1])
	 for h in all(a) do
	 	if not h.freezeme then
		 	if (h.kind == 1) move_hero(h) 
		 	if (h.kind == 17) move_ball(h)
			end
		end 	
	 --update the things
	 process_things()
 	
 	-- account if hero is at flag
 	--if hero_in then
 	--	end_timer += 1
 	--	if end_timer >= 60 then
 	--		menu_mode = true
 	--	end
 	--end
 	
	end
--end

function camera_follow(h)
	--force the camera to follow
	--an instance. optionally
	--lock y or x
	tx = h.x-64
	ty = h.y-64
	cam_speed = 1
	if (cam_timer >= 0) cam_speed = 4
	if (cam_timer >= 20) cam_speed = 6
	if (cam_timer >= 40) cam_speed = 8
	if (cam_timer >= 60) cam_speed = 200
	if (cam_timer >= 0) cam_timer += -1
	if (cam_timer <= 0) lose_ball = false
	addx = -(cx - tx)/cam_speed
	addy = -(cy - ty)/cam_speed
	xhi =8*(ll[level_current][2]-16 + ll[level_current][4])
	xlo =8*(ll[level_current][4]) 
	yhi =8*(ll[level_current][3]-16 + ll[level_current][5])
	ylo =8*(ll[level_current][5]) 
	cx += addx
	cy += addy
	cx = max(xlo,cx)
	cx = min(xhi,cx)
	cy = max(ylo,cy)
	cy = min(yhi,cy)
	camera(cx,cy)
end	

function draw_back(clock)
	if (menu_mode or menu_start or menu_end) then
		cx = 0
		cy = 0
	end
	back_c = back_info[clock][1]
	sun_c = back_info[clock][2]  
	sun_h = back_info[clock][3]
	back_o = back_info[clock][4]  
	rectfill(cx+0,cy+0,cx+128,cy+128,back_c)
	circfill(cx+12,cy+sun_h,10,sun_c)
	map(back_o,48,cx,cy,16,16)
end

function draw_pad()
	--rectfill(0,0,128,128,12)
	--circfill(12,16,10,10)
	--map(0,48,0,0,16,16)
	draw_back(clock)
	rectfill(4,19,109,109,0)
	rectfill(5,20,108,108,15)
end

function draw_tut()
	tc = 7 
	if (t%60 > 30) tc = 0
	if control_ball then
		print('”ƒ‹‘',cx+35,cy+45,0)
		print('move the ball!',cx+25,cy+37,0)
	else
		print('‹   ‘', cx+7,cy+105,tc)
		print('move', cx+15, cy+113, tc)
		print('Ž  jump ',cx+65,cy+105,tc)
		print('—',cx+17,cy+74,tc)
		print('swing',cx+15,cy+66,tc)
	end
end

function _draw()
 cls()
 
 --if menu_mode then
 camera()
 if menu_start then
		--draw_pad()
		draw_back(clock)
		rectfill(19,9,109,41,0)
		rectfill(20,10,108,40,15)
		for xout = -1,1 do
			for yout = -1,1 do
				print('9hole',54+xout,15+yout,0)
				--print('press x (btn 5) to begin',15+xout,60+yout,0)
			end
		end 
 	print('9hole',54,15,7)
		print('by palo blanco games',25,27,0)
		-- hard mode toggler
		ystart = 44
		if yshake > 0 then
			yshake += 1
			if yshake > 10 then
				yshake = 0
				ymove = 0
			else
				if (yshake%2 == 1) ymove = 1 - ymove
			end
		end
		--ymove=0
		print('press — to start!',30,ystart+ymove,0)
		if ycount >= 5 then
			if (hard_mode) print('back 9 activated',34,ystart+6+ymove,0)
			if (not hard_mode) print('front 9 activated',32,ystart+6+ymove,0)
		end
		palt(0,false)
		palt(9,true)
		jit = 2*flr((t%60)/30)
		ang = -(t%100)*.01
		rectfill(0,120,128,128,11)
		line(0,120,128,120,3)
		sspr(0,32,32,32,0,60+jit,64,64)
		palt()
		bx = 100
		by = 74 + 3*sin(ang)
		circfill(bx,by,16,0)
		circfill(bx,by,15,7)
		for ap = 0,5 do
			circ(bx+6*cos(ang+0.2*ap),by+6*sin(ang+0.2*ap),1.5,6)
			circ(bx+10*cos(ang+0.1+0.2*ap),by+10*sin(ang+0.1+0.2*ap),1.5,6)
			circ(bx+13*cos(ang+0.2*ap),by+13*sin(ang+0.2*ap),1.5,6)
		--	circfill(100+7*cos(ang-.2),74+7*sin(ang-.2),1,6)
		--	circfill(100+0*cos(ang-.2),74+0*sin(ang-.2),1,6)
		end
		--line(100,74,100+14*cos(ang),74+14*sin(ang),6)
		--line(
	elseif menu_mode then
		draw_pad()
 	print(ll[level_current+1][6],8,40,0)
		print(ll[level_current+1][7],8,47,0)
		print('next up, hole '..level_current+1,16,60,0)	
		print('par '..ll[level_current+1][1],16,68,0)
		print('current score: '..strokes,16,84,0)
		print('current coins: '..coins,16,92,0)
	elseif menu_end then
		draw_pad()
		print('thanks for playing!',20,40,0)
		print('final strokes: '..strokes,16,66,0)
		print('coins (-.05 each): '..coins,16,74,0)
 	print('lives lost (+3 each): '..(5-lives),16,82,0)
 	print('final score: '..flr(strokes+3*(5-lives)-.05*coins),16,90,0)
 		--print('press x (btn 5) to begin',15,40)			 
 else
 	if control_ball then
 		camera_follow(a[2])
 	else
 		camera_follow(a[1])
 	end
 	
 	--rectfill(cx,cy+104,cx+128,cy+128,1)
 	--sky
 	--rectfill(cx,cy,cx+128,cy+128,1)
 	--scenery
 	--map(32,48,cx,cy,16,16)
 	--circfill(cx+12,cy+16,10,7)
 	--circfill(cx+12,cy+16,8,7)
 	--level
 --	pal(3,11)
 --	pal(11,3)
 	draw_back(clock)
 	map(ll[level_current][4],ll[level_current][5],xlo,ylo,ll[level_current][2],ll[level_current][3],2)
 	--tutorial
 	if (level_current == 1 and not hard_mode) draw_tut()
 	--draw status bar
 	rectfill(cx+3,cy,cx+35,cy+6,15)
 	rectfill(cx+43,cy,cx+76,cy+6,15)
 	rectfill(cx+91,cy,cx+128-9,cy+6,15)
		--statistics
		--print('lives: '..lives..'  par: '..par..'/'..par_old..'    hole: '..level_current,cx+4,cy+1,0)
		print('lives:'..lives,cx+4,cy+1,0)
		print('par: '..par,cx+46,cy+1,0)
		print('hole: '..level_current,cx+92,cy+1,0)
		color()
		if (t % 15 == 1) draw_lose = not draw_lose
		if draw_lose then
			if (lose_life) print('-1',cx+32,cy+8*(end_timer/60),8)
		 if (lose_ball) print('-1',cx+63,cy+8*(1-(cam_timer/45)),8)
		end
		
		--draw actors
		palt(0,false)
		palt(9,true)
		for h in all(a) do 
			if (h.drawme) spr(h.pic,h.x + h.vibx,h.y + h.viby,1,1,h.r,h.flipy)
		end
		palt()
 	--draw things
 	for th in all(b) do
 		if th.kind == 26 then
 			palt(0,false)
				palt(9,true)
 		end 
 		if (th.drawme) spr(th.pic,th.x,th.y,1,1,th.flipx,th.flipy)
			palt()
		end
	
 end
end

if(_update60)_update=function()_update60()_update_buttons()_update60()end 
__gfx__
99999999999999999922229999999999992222999999999900500000000000000000000000000000999999990000000000000000000000000000000000000000
99222299992222999244442299222299924444219922229900550000000d0000000a000000000000992222990000000000000000000000000222222000000000
92444422924444221cc7cc71924444221c70c70c924444220066000000ddd00000aaa00000999a00924444220009900000000000000000000288892000000000
1cc7cc711cc7cc711c71c70c11c7cc7111c7cc711c77c77100060000000dd000000aa00000999a001cc7cc7100a9a90000000007770000000288892000000000
1170c7011c7017011c1c1cc11c7017011c1cccc11170c70100066000000ddd00000aaa0000999a001c70c70100aa990000000077777700000288892000000000
1c1cccc11cc1c1c1955151191c11c1c1915550091c1ddd1c000065500000d0000000a00000999a001cccccc1000aa00000777777777770000288892002222220
91555559055510099009555991001559900999999100555100005555000000000000000000999a00911111190000000007777677777770000288892002888920
900990090099999999990099999009999999999999999009000022220000000000000000099999a0999999990000000077777677777677701111111111111111
33333333999999995000000000066700000000000688000006ee0000007777008888888800000000999999996700007677776777777677760000000100000001
33b333b3999999995000000000006670000000000688880006eeee00070000705000000500000000990000997770077777667777776777760222222100000221
3b5b3353990000996600000000000076000000000687788806e77eee700070070505505000000000904554090670076007777777667777760299999100000291
35353333906766090660000000000077000000000688880006eeee00700007070056650088888888045445400767767000777777777776660288888100000281
33333333907676090066000000000077000000000688000006ee0000505000070056650050055005054554507777777700000776666666000288888100000281
3b333b33907767090006655000000670060000000600000006000000500500070505505005566550033bb4400767767000000000000000000288888100000281
3533b5b3907776090000555500000770077006700611110006111100050000705000000550055005900993390070070000000000000000000222222100000221
33335353990000990000222200007700007777001222222112222221005577008888888888888888999990090000000000000000000000000000000100000001
55555555555555555555555555555555333333335553333333333335555333355555555553333333333335555333355555555555555555555555555500100000
53b353b353b353b353b353b553b353b533b333b353b333b333b335b553b335b553b353b355b333b333b333b555b333b553b355b553b355b353b355b501c11100
5b5b53535b5b53535b5b53555b5b53553b5b33535b5b33533b5b33555b5b33555b5b53535b5b33533b5b35555b5b35555b5b53555b5b53535b5b53551ccccc10
35353333553533333535355555353555353533335535333335353555553535553535333355353333353533355555333555353555553535533535355501c111c1
3333333355533333333333355553333533333333555333333333333555533335333333335333333333333555533335555553333555533333355333351c111c10
3b333b335b333b333b333b555b333b553b353b355b353b353b353b555b353b553b353b355b333b333b333b355b533b355b353b555b353b553b353b5501ccccc1
3533b5b35553b5b33533b5b55553b5b53535b5b55555b5b53535b5b55555b5b53535b5b55533b5b33533b5b55533b5b55555b5b55555b5b53555b5b500111c10
33335353533353533333555553335555555555555555555555555555555555555555555555535353333353555553535555555555555555555555555500000100
0000000650000000666666665000000656666666ffffffff00e000e0909999090098880066666655000000000eee666eeeeeeeeeeeee00000888888000000000
0000006655000000666666665500006655666666fafaffff0e7e0e7e06099060098889906666666500080000e777777e677e677ee777eee08892298800000000
0000066655500000666666665550066655566666f6a6ffaf0e7e0e7e067007608989988966666666008880000eee777e677e677ee777777e8922229800000000
0000666665550000666666666555666665556666ff6fff6f0e7e0e7e09788790889aa98866666666000880000000eeee677e677ee666eee08922229800000000
0006666666555000666666666655566666555666ffffffffe776e77609899890889aa98866666666000888000eee666ee7e0e7e0eeee00008992299800000000
0066666666655500666666666665556666655566faffafafe776e776033bb880988998986666666600008000e777777ee7e0e7e0e777eee08992229800000000
0666666666665550666666666666555666665556f6ff6a6fe776e776900993390998889066666666000000000eee777ee7e0e7e0e777777e8992299800000000
6666666666666555666666666666655566666555fffff6ffeeeeeeee999990090088890066666666000000000000eeee0e000e00e666eee00888888000000000
999999999999999999999999999999999999999999999999999999999999999900c8880000000000000000000000000000000000055555000000000099999999
999995526999999999999999999999999999999999999999999999999999999908c888800000000000000000055555000555550055c7cc700055555099222299
999225556699999999999999999999999999999999999999999999999999999988888888000000000000000055c7cc7055c7cc705c75c750055c7cc792444422
99255555966992229922299999999999999999999999977777799999999999998888888800000000000000005c75c7505c75c7500cccccc005c75c751cc7cc71
92555559996228882282822229999999999999999997777799779999999999990888888000000000000000000cccccc00cccccc0008888c000cccccc1170c701
9255559999288882282828282999999999999999997799997777779999999999008888800000000000000000008888000088c800008c880000c888c01c1cccc1
99255599928882228282828229999999999999977777777799999779999999990000088000000000000000000c8888c0008885c0005088000008588091555559
9992299992882828282cc82999999999999999977999999999999977999999990008888000000000000000000050050005000000000005000000050090099009
999999992888828cccccccc999999999999999799999999999999999779999990000000000000000000000000555550000000000000000000000000000000000
999999992888ccccccccc77c99999999999999799999999999999999979999990000000000000000000000005575c75005555500000000000000000000000000
99999999288cccc777ccc70799999999999999799999999999999999997999990000000000000000000000005cc7cc705577c770000000000000000000000000
99999999281ccc7707ccc70799999999999997999999999999999999997999990000000000000000000000000cccccc05c75c750000700000003b00000088000
9999999991c1cc7707ccc7779999999999999799999999999999999999779999000000000000000000000000008888c00cccccc000000000000b300000088000
999999999c1ccc7777cccccc99999999999997999999999999999999999799990000000000000000000000000c888500008888c0000000000000000000000000
9999999991c1cccccccccccc9999999999999799999999999999999999979999000000000000000000000000050000000c858800000000000000000000000000
99999999911c1c00ccccccc999999999999997999999999999999999999799990000000000000000000000000000000000000500000000000000000000000000
999999999911cc000cccccc99999999999999799999999999999999999979999000000000008e000000000000080008008886668000000000000000000000000
9999999999111cc000cccc99999999999999979999999999999999999997999900000000008e68000008800008e808e88eeeeee8000000000000000000000000
99999999999991cccccc6999999999999999979999999999999999999997999900000000008e68000886688008e808e80888eee8000000000000000000000000
9999999999992828888916c999999999999997799999999999999999999799990000000008eee680e66ee66808e808e800008888000770000009a00000000000
999999999992c1ccccc1115999999999999999799999999999999999999799990000000008eee6808eeeeee88ee68ee60888666800077000000a900000000000
9999999999981c1cccccc555999999999999997999999999999999999997999900000000008e6800088ee8808ee68ee68eeeeee8000000000000000000000000
999999999992811111899955999999999999999799999999999999999979999900000000008e6800000880008ee68ee60888eee8000000000000000000000000
99999999999828288889999999999999999999977999999999999999977999990000000000088000000000008888888800008888000000000000000000000000
99999999999282888889999999999999999999997777999999999999779999990000000000088000000000008888888888880000000000000000000000000000
999999999992255555299999999999999999999999977799999999977999999900000000008e6800000880006ee86ee88eee8880000000000000000000000000
999999999992525525529999999999999999999999999777999997779999999900000000008e6800088668806ee86ee88eeeeee8000666666666600666000000
99999999992525525555299999999999999999999999999777777799999999990000000008eee680866ee66e6ee86ee886668880066777777777766777666660
99999999925255292255009999999999999999999999999999999999999999990000000008eee6808eeeeee88e808e8088880000677777777777777777777776
999999950005529992200009999999999999999999999999999999999999999900000000008e6800088ee8808e808e808eee8880777777777777777777777777
999999500002299999000009999999999999999999999999999999999999999900000000008e6800000880008e808e808eeeeee8077777777777777777777770
9999995000999999995555599999999999999999999999999999999999999999000000000008e000000000000800080086668880000777777777777770000000
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101e3010101010100000001010071007100000001010101000000a1000000000101010000000000000000000000e3b001
01000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001
01b0b0b00000000000000000b0b0b00101e30101010101000000010100000000000000010101010000010101000000010101000000f200000000000000e37101
01000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000001
01b0b0b00000000000000000b0b0b00101e301010101010000000101000000000000000101010100000101010000000101010000000000000000000000e3e301
010000000000000000000000000000000000000000010100000000000000000000b0000000000000000000000000000000000000000000000000000000000001
01b0b0b00000001011000000b0b0b00101e301010101016363630101636363636363630101010163630101016363630101018100000000000000000000000001
0100000000000000b0b0b000000000000000000000e3e3b0000000000000000000b0000000000000000000f20000b0b0b0b0b0b0b0b0b0b0b0b0b00000510001
0100000000000000000000000000000101e301010101010101010101010101010101010101010101010101010101010101010101010101000000000000a60001
0100000000000000b0b0b000000000000000000000e3e3b0000000000000000000b0000000000000000000000000000000000000000000000000000001010101
010000000000010101010000000000010100000000000000000000010000b301d3000000b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7b7007100710071000001
0100000000000000b0b0b000000000000000000000e3e3b000000000000000000001000000000000535353530000000000000000000000000000000000000001
0100000000000000000000b0000000010100000000000000000000b7000000c30000000000000000000000000000000000000000000000000000000000000001
0100b000b0000000717171630000000000000000000101000000000000000000000100000000000001010101000083000000000083000000000083b000b00001
010000b0000000b00000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001
01b000b0000000960000000100960000e00000960001010000000000000000a10001009600a10096010101010000000000000000a6000000000000b000b00001
0100000000b00000000000710000000101000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000001
0100b000b000000000000001000000535353000000010100000000b000000101010100000101000001010101000000000083000000000083000000b000b00001
01007100b000b0007100000000b0000101000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000001
010101010183838383838301007100010101000000e3e300a6000000000000000001000001010000010101010000000000000000a700000000000000b000b001
0100000000b00000000000000000000101000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000008101
010000000000000000000001000000010101000000e3e30000000001010000b000010000010100000101010100008300000000008300000000008300b000b001
010000b0000000b000b0b00071000001010000000000000000000000000000000000000000000096000000009600000000960000000096000000010101010101
01000000000000000000000100000001010100000001010000000001000000a100010000010100000101010100000000000000000000000000000000b000b001
0100000000710000b00000000000000101000000000000b00000a100000053535300000000830000000083000000008300000000830000000083010101010101
010010001100000000000001000000010101000000010100b0000000000001010101000001010000010101010000000000000000000000000000000000000001
01000000000000b000b0000000000001010010001100b00000010101b6b601010100000000000000710000000071000000007100000000710000010101010101
0100000000000000818181016363630101016363630101000000a100000001010101636301016363010101016363636363636363636363636363638181818101
010071000000000071000000b0000001010000000000000101010101636301010100810063636363636363636363636363636363636363636363010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0100000000b000000000b00000000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000b000b0000000000071000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100007100b000007100000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000d7e7e7e7e7f700000000000000000000d500000000d500000000d5000000000000000000000000000000000000
01b0b0b0000071000000b00000b00001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01b000b00000000000b000b000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c1d1000000000000c0d000000000000000000000d7f70000000000d500000000d5000000000000000000d500000000000000000000000000000000
01b0b0b0000000b00000b00071000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000c1d10000000000d7e7e7f700000000000000000000000000000000000000d50000000000000000000000000000000000000000
01000071000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000e7f70000000000000000d7e7e7e7e7f700d50000000000d5000000000000000000000000000000000000000000000000
010000000000710000007100b0b0b001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000313000000c0d000000000000000000003130000000000000000000000000000031300000000000000d5000000000000000000000000000000000000
01007100b00000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000032393130000c1d100000000000000000323931300d7e7f700000000000000000323931300000000000000000000000000000000000000000000000000
01000000000000f2b000000071000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000323232393130000000000000000000003232323931300000000000000000000032323239313000000d5000000d500000000000000000000000000000000
010000b0000000510000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003232323232393130000000313000000032323232323931300000003130000d503232323232393130000000313000000000000000000000000000000000000
0100b000b00001010101b000b000b001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03232323232323239313000323931300032323232323232393130003239313000323232323232323931300032393130000000000000000000000000000000000
01b000b000b00101010100b000b00001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23232323232323232393332323239333232323232323232323933323232393332323232323232323239333232323933300000000000000000000000000000000
0100b000b00001010101b000b000b001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23232323232323232323934323232393232323232323232323239343232323932323232323232323232393432323239300000000000000000000000000000000
01b000b000b00101010100b000b00001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23232323232323232323239343232323232323232323232323232393432323232323232323232323232323934323232300000000000000000000000000000000
01818181818101010101818181818101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23232323232323232323232393432323232323232323232323232323934323232323232323232323232323239343232300000000000000000000000000000000
01010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000010000000002000000000000001212000000000000020202020202020202020202020202000000000000060a000000000a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000008080888800000000000000000000000080808888000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10000000000000000000000000000010107c000000000000007b7b7b7b7b7b10100000000000000000000000000000000000000000000000000000101010001010000000000000000000000000000010100000000000000000000b000b000b000b000b0000000000000000000000000000000000000000000000000000000010
10000000000000000000000000000010107c0000000b0b0000000b0b0b0b00101000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000101000000000000000000b690b000b690b000b69000b000000000000000000000000000000000000000000000000000010
10000000000000000000007900000010107c0000000b0b000000000000000010100000000000000000000000000000000000000000000000000000000000001010000000000000006a00000000000010100000000000000000000b000b000b000b000b000b002f00000000000000000000000000000000000000000000000010
10000000000000000000790000000010107c0000000000000000000000170010100000000000000000000000000000000000000000000000000000000000001010000000000000006a0000000000001010101010101010101010101010101010101010000b101000000000000000000000000000000000000000000000000010
10000011000000006979000000000010107c001500001a000000170000000010100000000000000000000000000000000000000000000000000000000000001010000000000000006a000000000000101000000000000000007b7b7b7b7b7b7b7b7b7b000b0000000000000b0000000b0000000b0000000b0000000000000010
100000000000000b0b0b000000000010101010101010101010000000001700101000001100000000000000000b0b0b0b000000000b0b0b0b0b000000000000101000000000000000000015000000171010000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000010
10000000000000000000000000000010100b0b7a0000000000001700000000101000000000000000000000000b0b0b0b696969690b0b0b0b0b000000000000103500000000000000103535351000001010000000000000000000000000000000000000000b000000000b0069000b0069000b0069000b00690000000000000010
10000000000000000000000000000010100b0b007a0000000000000000170010101010101069170000000000000000000000000000000000000000000000001035000000000000000000000000000010100000170000170000000000000000000000000000000000000000000000000000000000000000000000000000000010
1000000000000b00000000000015001010000000007a0000000017000000001010000000000000000000000000000000000000000000000000000000000000103500000000000000000000000000171010000000000000003e00000000000000000000000000000b0000000b0000000b0000000b0000000b0000000000000010
101010101010100000101010101010101000000000007a00000000000017001010000000000000000000000000001a000000000000001a0000000000000000101010101010000000000000000000001010000000170000693e690000000000000000000018000000000000000000000000000000000000000000000000000010
10000000000000000b10101010101010100000001100007a0000170000000010100000007a0017006a0000001010101000000000101010101000006a0000001010000000000000006a0000000000001010000000000011003e000000000000000000101010100000000000000000000000000000000000000000000015000010
1000010000000000101010101010101010000000000000000000000000000010100000000100000000000000101010100000000010101010100000000000001010000000000000006a0000000000171010000000000000003e000000000000000010101010100000001a00000000001a00000000001a00000010101010101010
10000000370b00001010101010101010101800000000000100000037000000101000000000000000000018001010101000001a0010101010100000000000001010000000000000006a000000000000101000010000002f003e000000000000001010101010103535353535353535353535353535353535353510101010101010
101010101010101010101010101010101010101010101010106b10101010101010101010101010101010101010101010101010101010101010000015000000101000000000000000000000000000001010000000000000003e00000e000010101010101010103535353535353535353535353535353535353510101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010001700170017000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010170017001700170000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1000000000000000000000000000000000000000000000000000000000000010100000000000007900000000000000000000000000000000000000000000001010001700170017006a00000000000035100000380000000000000b00000000003800000000000000000000380000000038000000000000000000003500000010
1000000000000000000000000000000000000000000000000000000000000010107c00000000000079000000000000000000000000000000000000000000001010000000000000006a000000000000351000000000000b000b00380b000b000000000000000b380b000b000000000000000b000b000b000b00000e3500000010
1000000000000000000000000000000b0b0b0000000000000000000000000010107c00000000000000000000000000000079000000000000000000000000001010170000000000006a000000000000351038000000380000000000000038000b000b000b000000000000000b000b000b00003800000000353500003500000010
1000000000000000000000000000000b0b0b0000000000000000000000000010107c000000000079000000000000000079000000000000000000000000110010100000000000000000000000000e0035100000000000000038000000000000000000003800000000380000000038000000000000003800353500150000000010
1000000000110000000000000000690b0b0b69000000000000000000000000101000000000000000790000000000000000000000006969000000000010101010100000000000000000000000101010101000001700001010101010101010101010101010101010101010101010101010101010101010101010101010103e3e10
1000000000000000000000000000000000000000000000000000000000150010100e000000000000000000000000000000790000000000000000170000000010100000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000101000003e0b10
10000b000010100000000000000000006a0000000000000000000010101010101000000000000079000000000000000079000000000000000000000000000010103e3e00000000000000000b000b00101017000000170000000000000000000000000000000000000000000000000000000000000000000000000000003e1710
100000001010100000000000000000006a00000000000000000000101010101010000000000000007900000000000000000000000000001010101000006a001010183e0000000000000000000b000b101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e0b10
10000b00101010100000000037000018181800000000370000001810101010101000000000000000000000000000000000790000000000000000003e3e3e3e1010101035353510101010180b000b00101000001700000000000000000000000000000000000000000000000000000000000000000000000000000000003e1710
10000000101010101010106b10101010101010106b1010106b10101010101010100000000000007900000000001a0000790000001a0000000000000b0b0b0b10100000006a000000006a00000b000b101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e0b10
10000b00101010101010101010101010101010101010101010101010101010101000000000000000790000001010101000001010101010000000000b0b0b0b10100000006a000000006a000b000b00101017000000170000000000000000000000000000000000000000000000000000000000000000000000000000003e1710
10000000000000000000000b00000000000b00000000000000000000000000101000010000000000000000001010101000791010101010000000000b0b0b0b10100000006a001100006a0000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e0b10
10000b000000000000000b000b0000000b000b000000000000000000000000101000000000101000001010101010101079001010101010000000000b0b0b0b1010000001000000000000000000000010100b0b0b0b0b0b000000001a0000000000000000000000000000000000000000000000000000000017000000003e1710
100018007a00000000007a000000000000006a000000000001007a00000000101000001500101036361010101010101036361010101010363636360b180b0b1010000000000000000000001818181810100b0b0b0b0b0b00000010100000000000000010101010000000000000000000000000000000000000000000003e0b10
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100b0b0b0b0b0b00000010106900000000690010101010690000000000690035353500000000000000000000003e1710
__sfx__
011400000f37513305183051d3051b3751d3051b3051e305183751f3751e3051e3751e3051d3751b3751b305183751e305133751d30516375133751b30513375163751b37516305183751830513305163051b305
010c00001f2362223624236272363c60539403185032b503184033940318403394033c605306053940339403184033940318403394033c605394031840321403184033940318403394033c605394033940339403
0110000018576195761b5761c5763c50539403185032b503184033940318403394033c605306053940339403184033940318403394033c605394031840321403184033940318403394033c605394033940339403
010e00000c0730c600306130f0730c07313000306130f0730e00013000306130c0000c0730e0003061330613130730f000306130f073130731f000306130f0730c0031f000306130c0000c0730c0002461330613
010e00002455524505245052450524555295052950529505295552755527505205552050520505205552250522555225052255524505205552255522505245052455527507295052e5071d70514705227052e705
01030000261722616232362323623235232352323523234232342323423233232332323323232232322323223231232312323123231232312263051a30526305263052620526205262052e7072b507305062e702
01090000243752b37524305243052b305243052d305243052b305243052b305243052b3052770224002275021b4021b5051b5021b4021d502295071d402295022440624506245072440727506275062940729507
011000201b4741d4751e400184002247522405224751840018400184002447424471244751c4001c400224711f4721f475244001d4001d4001d4001d4701f4001f4041f4011f4741f4711d4751f4001d40507407
010e00201d3741d371243752430018300183001d3741d3002437024375183001830027370273751830018300223742237129375183001f3001830022370223752937029305273702730524370243052737027305
010e002005040050410500000343286430500005000050000c343050003a646225031c643050003a644050000a0400a0410a000005431c6430a0000a0000a0000c3430a0003a6460a0001c6430a0003a6440a000
010e00200c0400c0410500000343286430500005000050000c343050003a646225031c643050003a644050000a0400a04128643286430704007041286412864505040050413a6460a0001c6430a0003a6440a000
010e00200c0400c0410500000343286430500005000050000c343050003a646225031c643050003a644050000a0400a0410a000005431c6430a0000a0000a0000c3430a0003a6460a0001c6430a0003a6440a000
010e0020243742437124371243751830027300273701d300243702937518300183002437029375183001830029374223012737518300243701830022370223052237029305243702730527370293702737029370
010e0020243742437122375243001d374183001d3741d30022370223751830018300243702437518300183001d3741d37127375183001f3001830022370223752937427375273002730524374223752730027305
010400001b0541f05123051270612a5712a5712a57100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001b0541f05123051270612a5712a5712a57100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102000020275272712c2712c2711d2611a2611a261252612a2512e2512d2512c2511f2411c24121241262412b2412c24128241172311c23122231282312b2312b20128201192011a201262012f2012f20000100
010300000467104641046310462100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300002867128641286312862100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002b2752b2632b2532b0522b0422b0422b0422b0322b0322b0222b0122b0122400100700004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001f6741f6611f6511f6521f4421f4421f4421f4321f4321f4221f4121f4121840118700004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001f6733c673000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00002947529405274752740524475294752747529475000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00002917029100271702710029170241702717029100241702917027170291702917029170290002910000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000c343050003a646225031c643050003a644050000c3430c3433a646225031c6431c6433a6440500000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200002b2751f2611f2511f7511f7411f7411f7411f7311f7311f7211f7111f7112470100700005000050000500005000050000500005000000000000000000000000000000000000000000000000000000000
010a0000294722947227472274722447224402224721d471244722447224402291002910029100290002910000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000297702970027770277002477024705227721d7721d7721d7721d772291002910029100290002910000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c000027236292362b2362e2363c60539403185032b503184033940318403394033c605306053940339403184033940318403394033c605394031840321403184033940318403394033c605394033940339403
010c0000222362423627236292363c20539403185032b503184033940318403394033c605306053940339403184033940318403394033c605394031840321403184033940318403394033c605394033940339403
01020000006250c625186252462530625006250c62518625000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a0000295712950127571275012957229572295721d575005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 03 42 43 44
00 03 04 43 44
02 03 04 43 44
00 00 01 03 04
01 00 01 02 03
00 00 01 02 03
00 00 01 03 05
00 00 01 03 06
00 00 01 03 05
00 00 01 03 06
00 00 01 02 44
03 09 42 43 44
01 08 09 43 44
00 08 09 43 44
00 0d 0b 43 44
00 0d 0b 43 44
00 08 09 43 44
00 08 09 43 44
02 0c 0a 43 44
03 09 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
